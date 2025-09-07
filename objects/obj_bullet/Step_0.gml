if (on_pause_exit()) exit;

x += dirx * spd;
y += diry * spd;
life -= 1;
if (life <= 0) instance_destroy();