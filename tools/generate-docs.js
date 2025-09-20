const fs = require('fs/promises');
const path = require('path');

const repoRoot = path.resolve(__dirname, '..');
const scriptsDir = path.join(repoRoot, 'scripts');
const objectsDir = path.join(repoRoot, 'objects');
const docsDir = path.join(repoRoot, 'docs', 'documentation');

function escapeHtml(value) {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

function slugify(value) {
  return value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

function countLines(text, index) {
  return text.slice(0, index).split(/\r?\n/).length;
}

function extractCommentMetadata(content, fnIndex) {
  const before = content.slice(0, fnIndex);
  const commentEnd = before.lastIndexOf('*/');
  if (commentEnd === -1) {
    return { name: null, description: null, raw: null };
  }
  const commentStart = before.lastIndexOf('/*', commentEnd);
  if (commentStart === -1) {
    return { name: null, description: null, raw: null };
  }

  const between = before.slice(commentEnd + 2);
  if (!/^\s*$/.test(between)) {
    return { name: null, description: null, raw: null };
  }

  const commentText = content.slice(commentStart, commentEnd + 2);
  const lines = commentText.split(/\r?\n/).map((line) => line.trim());

  let name = null;
  const descriptionParts = [];
  let inDescription = false;

  for (const line of lines) {
    if (!line.startsWith('*')) {
      inDescription = false;
      continue;
    }
    const body = line.slice(1).trim();
    if (body === '/') {
      inDescription = false;
      continue;
    }
    if (body.startsWith('Name:')) {
      name = body.slice('Name:'.length).trim();
      inDescription = false;
    } else if (body.startsWith('Description:')) {
      const desc = body.slice('Description:'.length).trim();
      descriptionParts.push(desc);
      inDescription = true;
    } else if (inDescription && body.length > 0) {
      descriptionParts.push(body);
    } else {
      inDescription = false;
    }
  }

  const description = descriptionParts
    .map((part) => part.replace(/\s+/g, ' ').trim())
    .filter(Boolean)
    .join(' ');

  return { name, description: description || null, raw: commentText };
}

async function readScriptFunctions() {
  const entries = await fs.readdir(scriptsDir, { withFileTypes: true });
  const functions = [];

  for (const entry of entries) {
    if (!entry.isDirectory()) continue;
    const scriptName = entry.name;
    const gmlPath = path.join(scriptsDir, scriptName, `${scriptName}.gml`);
    try {
      const content = await fs.readFile(gmlPath, 'utf8');
      const relativePath = path.relative(repoRoot, gmlPath).replace(/\\/g, '/');
      const regex = /function\s+([A-Za-z0-9_]+)\s*\(([^)]*)\)/g;
      let match;
      while ((match = regex.exec(content)) !== null) {
        const name = match[1];
        const paramsRaw = match[2].trim();
        const params = paramsRaw
          ? paramsRaw.split(',').map((p) => p.trim()).filter(Boolean)
          : [];
        const line = countLines(content, match.index);
        const meta = extractCommentMetadata(content, match.index);
        functions.push({
          name,
          params,
          script: scriptName,
          relativePath,
          line,
          description: meta.description,
          docName: meta.name,
          slug: slugify(name),
        });
      }
    } catch (err) {
      if (err.code !== 'ENOENT') {
        throw err;
      }
    }
  }

  return functions;
}

function stripComments(text) {
  return text
    .replace(/\/\*[\s\S]*?\*\//g, '')
    .replace(/\/\/.*$/gm, '');
}

async function buildObjectScriptMap(functionMap) {
  const entries = await fs.readdir(objectsDir, { withFileTypes: true });
  const objects = [];

  for (const entry of entries) {
    if (!entry.isDirectory()) continue;
    const objectName = entry.name;
    const objectPath = path.join(objectsDir, objectName);
    const relativeObjectPath = path.relative(repoRoot, objectPath).replace(/\\/g, '/');
    const eventEntries = await fs.readdir(objectPath, { withFileTypes: true });
    const events = [];

    for (const eventEntry of eventEntries) {
      if (!eventEntry.isFile() || !eventEntry.name.endsWith('.gml')) continue;
      const eventName = path.basename(eventEntry.name, '.gml');
      const eventPath = path.join(objectPath, eventEntry.name);
      const relativeEventPath = path.relative(repoRoot, eventPath).replace(/\\/g, '/');
      const content = await fs.readFile(eventPath, 'utf8');
      const stripped = stripComments(content);
      const used = new Set();

      for (const [fnName, fnInfo] of functionMap.entries()) {
        const regex = new RegExp(`\\b${fnName}\\s*\\(`);
        if (regex.test(stripped)) {
          used.add(fnInfo);
        }
      }

      const usedFunctions = Array.from(used).sort((a, b) => a.name.localeCompare(b.name));
      events.push({
        name: eventName,
        displayName: formatEventName(eventName),
        relativePath: relativeEventPath,
        functions: usedFunctions,
      });
    }

    events.sort((a, b) => a.name.localeCompare(b.name));
    const uniqueFunctions = new Map();
    for (const event of events) {
      for (const fn of event.functions) {
        uniqueFunctions.set(fn.name, fn);
      }
    }
    objects.push({
      name: objectName,
      relativePath: relativeObjectPath,
      events,
      functions: Array.from(uniqueFunctions.values()).sort((a, b) => a.name.localeCompare(b.name)),
    });
  }

  objects.sort((a, b) => a.name.localeCompare(b.name));
  return objects;
}

function formatEventName(name) {
  if (!name.includes('_')) return name;
  const [first, ...rest] = name.split('_');
  if (rest.length === 0) return first;
  return `${first} \u2192 ${rest.join('_')}`;
}

function renderPage({ title, description, body, generatedAt }) {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>${escapeHtml(title)}</title>
  <style>
    :root {
      color-scheme: light;
    }
    * {
      box-sizing: border-box;
    }
    body {
      margin: 0;
      font-family: 'Segoe UI', Roboto, sans-serif;
      background: #f5f6fa;
      color: #1f2430;
      line-height: 1.6;
    }
    header {
      background: linear-gradient(135deg, #2a3d66, #403f7a);
      color: #fff;
      padding: 2.5rem 1.5rem;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
    }
    header h1 {
      margin: 0;
      font-size: 2.2rem;
      letter-spacing: 0.03em;
    }
    header p {
      margin: 0.75rem 0 0;
      max-width: 70ch;
    }
    main {
      max-width: 1100px;
      margin: -3rem auto 2rem;
      padding: 0 1.25rem 2.5rem;
    }
    .card {
      background: #fff;
      border-radius: 12px;
      box-shadow: 0 12px 30px rgba(18, 21, 34, 0.08);
      padding: 2rem;
      margin-bottom: 2rem;
      border: 1px solid rgba(66, 71, 112, 0.08);
    }
    nav ul {
      list-style: none;
      padding: 0;
      margin: 0;
      display: flex;
      flex-wrap: wrap;
      gap: 0.5rem 1rem;
    }
    nav a {
      text-decoration: none;
      color: #2a3d66;
      background: rgba(42, 61, 102, 0.08);
      padding: 0.35rem 0.75rem;
      border-radius: 999px;
      font-weight: 600;
      transition: background 0.2s ease, color 0.2s ease;
    }
    nav a:hover,
    nav a:focus {
      background: #2a3d66;
      color: #fff;
    }
    section + section {
      margin-top: 3rem;
    }
    h2 {
      margin-top: 0;
      font-size: 1.75rem;
      color: #2a3d66;
    }
    h3 {
      font-size: 1.25rem;
      margin: 0 0 0.5rem;
      color: #3a3f63;
    }
    .meta {
      display: flex;
      flex-wrap: wrap;
      gap: 0.75rem 1.5rem;
      font-size: 0.95rem;
      color: #4c5270;
      margin-top: 0.75rem;
    }
    .meta span {
      display: inline-flex;
      align-items: center;
      gap: 0.35rem;
    }
    .badge {
      background: rgba(64, 63, 122, 0.12);
      color: #403f7a;
      padding: 0.1rem 0.65rem;
      border-radius: 999px;
      font-size: 0.85rem;
      font-weight: 600;
    }
    code {
      background: rgba(42, 61, 102, 0.08);
      padding: 0.1rem 0.3rem;
      border-radius: 4px;
      font-family: 'Fira Code', 'SFMono-Regular', Consolas, monospace;
      font-size: 0.95rem;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      margin-top: 1rem;
      overflow: hidden;
      border-radius: 10px;
      box-shadow: inset 0 0 0 1px rgba(42, 61, 102, 0.08);
    }
    thead {
      background: rgba(42, 61, 102, 0.08);
    }
    th, td {
      padding: 0.75rem 1rem;
      text-align: left;
      vertical-align: top;
    }
    tbody tr:nth-child(even) {
      background: rgba(42, 61, 102, 0.03);
    }
    a.inline-link {
      color: #2a3d66;
      font-weight: 600;
      text-decoration: none;
      border-bottom: 1px solid rgba(42, 61, 102, 0.35);
      transition: color 0.2s ease, border-color 0.2s ease;
    }
    a.inline-link:hover,
    a.inline-link:focus {
      color: #111b36;
      border-color: #111b36;
    }
    .empty {
      color: #6d728b;
      font-style: italic;
    }
    footer {
      font-size: 0.85rem;
      color: #6d728b;
      margin-top: 2rem;
      text-align: right;
    }
    @media (max-width: 768px) {
      header {
        padding: 2rem 1rem;
      }
      main {
        margin-top: -2.5rem;
        padding: 0 1rem 2rem;
      }
      .card {
        padding: 1.5rem;
      }
      nav ul {
        flex-direction: column;
        gap: 0.25rem;
      }
      .meta {
        flex-direction: column;
        gap: 0.4rem;
      }
      table, thead, tbody, th, td, tr {
        display: block;
      }
      thead {
        display: none;
      }
      tr {
        margin-bottom: 1rem;
        background: #fff;
        border-radius: 8px;
        box-shadow: 0 8px 18px rgba(18, 21, 34, 0.08);
        padding: 0.75rem 1rem;
      }
      td {
        padding: 0.35rem 0;
      }
      td::before {
        content: attr(data-label);
        display: block;
        font-weight: 600;
        color: #2a3d66;
        margin-bottom: 0.25rem;
      }
    }
  </style>
</head>
<body>
  <header>
    <h1>${escapeHtml(title)}</h1>
    <p>${escapeHtml(description)}</p>
  </header>
  <main>
    ${body}
    <footer>Generated on ${escapeHtml(generatedAt)}</footer>
  </main>
</body>
</html>`;
}

function renderFunctionsPage(functions) {
  const scripts = new Map();
  for (const fn of functions) {
    if (!scripts.has(fn.script)) {
      scripts.set(fn.script, []);
    }
    scripts.get(fn.script).push(fn);
  }

  for (const fnList of scripts.values()) {
    fnList.sort((a, b) => a.name.localeCompare(b.name));
  }

  const scriptEntries = Array.from(scripts.entries()).sort((a, b) => a[0].localeCompare(b[0]));

  const tocLinks = scriptEntries
    .map(([scriptName, fnList]) => `<li><a href="#script-${slugify(scriptName)}">${escapeHtml(scriptName)} <span class="badge">${fnList.length}</span></a></li>`)
    .join('\n');

  const sections = scriptEntries
    .map(([scriptName, fnList]) => {
      const functionsMarkup = fnList
        .map((fn) => {
          const signature = `function ${fn.name}(${fn.params.join(', ')})`;
          const description = fn.description || 'No description available.';
          const location = `${fn.relativePath}:${fn.line}`;
          const paramMarkup = fn.params.length
            ? `<ul>${fn.params.map((param) => `<li><code>${escapeHtml(param)}</code></li>`).join('')}</ul>`
            : '<p class="empty">No parameters</p>';

          return `<article class="card" id="function-${fn.slug}">
  <h3>${escapeHtml(fn.name)}</h3>
  <p>${escapeHtml(description)}</p>
  <p><code>${escapeHtml(signature)}</code></p>
  ${paramMarkup}
  <div class="meta">
    <span title="Source path">📁 ${escapeHtml(location)}</span>
    <span title="Script asset">📄 ${escapeHtml(scriptName)}</span>
  </div>
</article>`;
        })
        .join('\n');

      return `<section id="script-${slugify(scriptName)}">
  <h2>${escapeHtml(scriptName)}</h2>
  ${functionsMarkup || '<p class="empty">No functions documented.</p>'}
</section>`;
    })
    .join('\n');

  const body = `
    <section class="card">
      <h2>Overview</h2>
      <p>This reference covers <strong>${functions.length}</strong> documented functions across <strong>${scriptEntries.length}</strong> script assets.</p>
      <nav aria-label="Function groups">
        <ul>
          ${tocLinks}
        </ul>
      </nav>
    </section>
    ${sections}
  `;

  return renderPage({
    title: 'Slime Game Function Reference',
    description: 'Annotated list of helper scripts and runtime functions available in the project.',
    body,
    generatedAt: new Date().toISOString(),
  });
}

function renderObjectMapPage(objects) {
  const tocLinks = objects
    .map((obj) => `<li><a href="#object-${slugify(obj.name)}">${escapeHtml(obj.name)} <span class="badge">${obj.functions.length}</span></a></li>`)
    .join('\n');

  const sections = objects
    .map((obj) => {
      const tableRows = obj.events.map((event) => {
        const functionsMarkup = event.functions.length
          ? `<ul>${event.functions
              .map((fn) => `<li><a class="inline-link" href="functions.html#function-${fn.slug}">${escapeHtml(fn.name)}</a> <span class="badge">${escapeHtml(fn.script)}</span></li>`)
              .join('')}</ul>`
          : '<span class="empty">No script functions</span>';

        return `<tr>
  <td data-label="Event"><span title="${escapeHtml(event.relativePath)}">${escapeHtml(event.displayName)}</span></td>
  <td data-label="Script calls">${functionsMarkup}</td>
</tr>`;
      }).join('\n');

      return `<section id="object-${slugify(obj.name)}">
  <h2>${escapeHtml(obj.name)}</h2>
  <div class="meta">
    <span>📁 ${escapeHtml(obj.relativePath)}</span>
    <span>🧩 ${obj.events.length} events</span>
    <span>🛠️ ${obj.functions.length} unique script functions</span>
  </div>
  ${obj.events.length
    ? `<table>
      <thead>
        <tr>
          <th>Event</th>
          <th>Script calls</th>
        </tr>
      </thead>
      <tbody>
        ${tableRows}
      </tbody>
    </table>`
    : '<p class="empty">No events found for this object.</p>'}
</section>`;
    })
    .join('\n');

  const body = `
    <section class="card">
      <h2>Overview</h2>
      <p>Script usage across <strong>${objects.length}</strong> objects. Each badge indicates the script asset providing the function.</p>
      <nav aria-label="Object list">
        <ul>
          ${tocLinks}
        </ul>
      </nav>
    </section>
    ${sections}
  `;

  return renderPage({
    title: 'Slime Game Object ↔ Script Map',
    description: 'Cross-reference of object events and the helper scripts they rely on.',
    body,
    generatedAt: new Date().toISOString(),
  });
}

async function main() {
  await fs.mkdir(docsDir, { recursive: true });

  const functions = await readScriptFunctions();
  const functionMap = new Map(functions.map((fn) => [fn.name, fn]));
  const objects = await buildObjectScriptMap(functionMap);

  const functionsHtml = renderFunctionsPage(functions);
  const objectMapHtml = renderObjectMapPage(objects);

  await fs.writeFile(path.join(docsDir, 'functions.html'), functionsHtml, 'utf8');
  await fs.writeFile(path.join(docsDir, 'object-script-map.html'), objectMapHtml, 'utf8');
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
