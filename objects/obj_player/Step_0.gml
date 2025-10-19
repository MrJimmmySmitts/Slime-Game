//if (global.isPaused) exit;
    
if keyboard_check(ord("W")) {
    y -= stats.speed;
}
if keyboard_check(ord("A")) {
    x -= stats.speed;
}
if keyboard_check(ord("S")) {
    y += stats.speed;
}
if keyboard_check(ord("D")) {
    x += stats.speed;
}