
/*
* Name: obj_slime_pickup.Create
* Description: Standardised pickup data used by inventory add logic.
*/

/*
* Name: obj_slime_1.Create (amount)
* Description: Define pickup amount for inventory.
*/
if (!variable_instance_exists(id, "amount")) amount = 1;
    amount = 1;
pick_radius = 16;