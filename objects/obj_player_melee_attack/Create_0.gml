/*
 * Name: obj_player_melee_attack.Create
 * Description: Setup default lifespan, damage, and animation for the player's melee slash.
 */
damage = PLAYER_BASE_BULLET_DAMAGE;
life   = PLAYER_MELEE_LIFE;
owner  = noone;

var _sprite = asset_get_index("spr_attack");
if (_sprite != -1)
{
    sprite_index = _sprite;
}

if (sprite_index != -1)
{
    image_index = 0;
    var _frames = max(1, sprite_get_number(sprite_index));
    image_speed = _frames / max(1, life);
}
else
{
    image_speed = 0;
}
