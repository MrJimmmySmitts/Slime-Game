/*
* Name: obj_pickup_base.Create
* Description: Shared initialisation for all pickup instances.
*/
if (!variable_instance_exists(id, "amount")) amount = 0;
amount = pickupClampAmount(amount);

if (!variable_instance_exists(id, "pickup_kind")) pickup_kind = PickupClass.Stock;
if (!variable_instance_exists(id, "item_id")) item_id = ItemId.None;
if (!variable_instance_exists(id, "combine_radius")) combine_radius = 16;

pickupRefreshAppearance(id);

