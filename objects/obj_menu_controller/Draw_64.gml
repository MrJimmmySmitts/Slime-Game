// Centered menu in GUI space
var W = display_get_gui_width();
var H = display_get_gui_height();

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(W*0.5, H*0.25, "PLOP");

// List items
for (var i = 0; i < array_length(menu_items); i++) {
    var _y = H*0.4 + i * 28;
    var label = (i == sel) ? "> " + string(menu_items[i]) + " <" : string(menu_items[i]);
    draw_text(W*0.5, _y, label);
}
