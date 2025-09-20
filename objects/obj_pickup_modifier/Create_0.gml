/*
* Name: obj_pickup_modifier.Create
* Description: Marks pickup as modifier class and updates tint.
*/
event_inherited();
pickup_kind = PickupClass.Modifier;
pickupRefreshAppearance(id);

