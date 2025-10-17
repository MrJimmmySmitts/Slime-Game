// (Optional) Draw a tiny aim line to indicate direction
var aim = inputGetAimAxis();
draw_line_width(x, y, x + aim[0]*20, y + aim[1]*20, 2);

if (flash_timer > 0) {
    gpu_set_blendmode(bm_add);
    draw_self();
    gpu_set_blendmode(bm_normal);
} else {
    draw_self();
}