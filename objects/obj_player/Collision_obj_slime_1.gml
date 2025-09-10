/*
* Name: obj_player.Collision[obj_slime_1]
* Description: Add Slime1 to inventory; if full, spawn drops at pickup position; then destroy pickup.
*/
var qty = (is_undefined(other.amount)) ? 1 : other.amount;
var lay_name = layer_get_name(other.layer);
invAddOrDrop(ItemId.Slime1, qty, other.x, other.y, lay_name);
with (other) instance_destroy();