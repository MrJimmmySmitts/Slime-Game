/*
* Name: obj_enemy_melee_attack.Create
* Description: Setup default lifespan, damage, and animation speed for spawned melee hitboxes.
*/
damage = 8;
life   = 8;
owner  = noone;

var _resolved_sprite = enemyConfigResolveAttackSprite();
if (_resolved_sprite != -1)
{
    sprite_index = _resolved_sprite;
}

if (sprite_index != -1)
{
    image_index = 0;
    var frames = max(1, sprite_get_number(sprite_index));
    image_speed = frames / max(1, life);
}
else
{
    image_speed = 0;
}
