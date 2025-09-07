// (Optional) Draw a tiny aim line to indicate direction
var aim = input_get_aim_axis();
draw_line_width(x, y, x + aim[0]*20, y + aim[1]*20, 2);
draw_self();