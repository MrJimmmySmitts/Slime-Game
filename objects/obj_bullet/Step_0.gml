if (onPauseExit()) exit;

x += dirx * spd;
y += diry * spd;
life -= 1;
if (life <= 0) instance_destroy();