/*
* Name: EnemyType
* Description: Enumerations for enemy behaviour archetypes.
*/
enum EnemyType
{
    Melee  = 0,
    Ranged = 1,
}

/*
* Name: EnemyToughness
* Description: Enumerations for scaling health/damage tiers.
*/
enum EnemyToughness
{
    Normal = 0,
    Elite  = 1,
    Boss   = 2,
}

/*
* Name: Enemy configuration macros
* Description: Centralised tuning values for each enemy archetype and toughness scaling.
*/
#macro ENEMY_IDLE_PAUSE_MIN           18
#macro ENEMY_IDLE_PAUSE_MAX           54
#macro ENEMY_IDLE_TOLERANCE           4        // pixels before considering wander target reached

#macro ENEMY_MELEE_BASE_HP            35
#macro ENEMY_MELEE_MOVE_SPEED         1.65
#macro ENEMY_MELEE_IDLE_SPEED         1.1
#macro ENEMY_MELEE_ACTIVATION_RANGE   200
#macro ENEMY_MELEE_LEASH_RANGE        320
#macro ENEMY_MELEE_WANDER_RADIUS      96
#macro ENEMY_MELEE_ACTIVE_DELAY       12
#macro ENEMY_MELEE_ATTACK_RANGE       40
#macro ENEMY_MELEE_ATTACK_DISTANCE    24
#macro ENEMY_MELEE_ATTACK_COOLDOWN    42
#macro ENEMY_MELEE_ATTACK_DURATION    12
#macro ENEMY_MELEE_ATTACK_DAMAGE      10
#macro ENEMY_MELEE_BOSS_EXTRA_ATTACKS 1

#macro ENEMY_RANGED_BASE_HP           28
#macro ENEMY_RANGED_MOVE_SPEED        1.35
#macro ENEMY_RANGED_IDLE_SPEED        0.9
#macro ENEMY_RANGED_ACTIVATION_RANGE  260
#macro ENEMY_RANGED_LEASH_RANGE       360
#macro ENEMY_RANGED_WANDER_RADIUS     128
#macro ENEMY_RANGED_ACTIVE_DELAY      18
#macro ENEMY_RANGED_RETREAT_RADIUS    96
#macro ENEMY_RANGED_RETREAT_SPEED     1.5
#macro ENEMY_RANGED_PROJECTILE_COOLDOWN 70
#macro ENEMY_RANGED_PROJECTILE_SPEED  5.2
#macro ENEMY_RANGED_PROJECTILE_DAMAGE 7
#macro ENEMY_RANGED_PROJECTILE_RANGE  360
#macro ENEMY_RANGED_PROJECTILE_LIFETIME 120
#macro ENEMY_RANGED_BOSS_EXTRA_PROJECTILES 1
#macro ENEMY_RANGED_BOSS_SPREAD_ANGLE 12
#macro ENEMY_MELEE_ATTACK_SPRITE_NAME "spr_attack"
#macro ENEMY_MELEE_ATTACK_SPRITE_FALLBACK_NAME "spr_enemy_slash"
#macro ENEMY_MELEE_BOSS_SPREAD 24

#macro ENEMY_TOUGHNESS_HP_NORMAL      1.0
#macro ENEMY_TOUGHNESS_HP_ELITE       1.6
#macro ENEMY_TOUGHNESS_HP_BOSS        2.5

#macro ENEMY_TOUGHNESS_DAMAGE_NORMAL  1.0
#macro ENEMY_TOUGHNESS_DAMAGE_ELITE   1.35
#macro ENEMY_TOUGHNESS_DAMAGE_BOSS    1.75

/*
* Name: enemyConfigResolveAttackSprite
* Description: Resolve the melee attack sprite, falling back gracefully if unavailable.
*/
function enemyConfigResolveAttackSprite()
{
    var _sprite = asset_get_index(ENEMY_MELEE_ATTACK_SPRITE_NAME);
    if (_sprite == -1)
    {
        _sprite = asset_get_index(ENEMY_MELEE_ATTACK_SPRITE_FALLBACK_NAME);
    }
    return _sprite;
}

/*
* Name: enemyConfigBaseStats
* Description: Returns a struct describing base stats for the requested enemy type.
*/
function enemyConfigBaseStats(_type)
{
    switch (_type)
    {
        case EnemyType.Ranged:
            return {
                hp                    : ENEMY_RANGED_BASE_HP,
                move_speed            : ENEMY_RANGED_MOVE_SPEED,
                idle_speed            : ENEMY_RANGED_IDLE_SPEED,
                activation_range      : ENEMY_RANGED_ACTIVATION_RANGE,
                leash_range           : ENEMY_RANGED_LEASH_RANGE,
                wander_radius         : ENEMY_RANGED_WANDER_RADIUS,
                active_delay          : ENEMY_RANGED_ACTIVE_DELAY,
                retreat_radius        : ENEMY_RANGED_RETREAT_RADIUS,
                retreat_speed         : ENEMY_RANGED_RETREAT_SPEED,
                projectile_cooldown   : ENEMY_RANGED_PROJECTILE_COOLDOWN,
                projectile_speed      : ENEMY_RANGED_PROJECTILE_SPEED,
                projectile_damage     : ENEMY_RANGED_PROJECTILE_DAMAGE,
                projectile_range      : ENEMY_RANGED_PROJECTILE_RANGE,
                projectile_life       : ENEMY_RANGED_PROJECTILE_LIFETIME,
                boss_projectiles      : ENEMY_RANGED_BOSS_EXTRA_PROJECTILES,
                boss_spread_angle     : ENEMY_RANGED_BOSS_SPREAD_ANGLE,
                melee_range           : ENEMY_RANGED_RETREAT_RADIUS, // shared var for compatibility
                melee_cooldown        : ENEMY_RANGED_PROJECTILE_COOLDOWN,
                melee_damage          : ENEMY_RANGED_PROJECTILE_DAMAGE,
                melee_duration        : 0,
                melee_distance        : 0,
                melee_extra_attacks   : 0,
            };

        case EnemyType.Melee:
        default:
            return {
                hp                    : ENEMY_MELEE_BASE_HP,
                move_speed            : ENEMY_MELEE_MOVE_SPEED,
                idle_speed            : ENEMY_MELEE_IDLE_SPEED,
                activation_range      : ENEMY_MELEE_ACTIVATION_RANGE,
                leash_range           : ENEMY_MELEE_LEASH_RANGE,
                wander_radius         : ENEMY_MELEE_WANDER_RADIUS,
                active_delay          : ENEMY_MELEE_ACTIVE_DELAY,
                retreat_radius        : 0,
                retreat_speed         : ENEMY_MELEE_MOVE_SPEED,
                projectile_cooldown   : 0,
                projectile_speed      : 0,
                projectile_damage     : 0,
                projectile_range      : 0,
                projectile_life       : 0,
                boss_projectiles      : 0,
                boss_spread_angle     : 0,
                melee_range           : ENEMY_MELEE_ATTACK_RANGE,
                melee_cooldown        : ENEMY_MELEE_ATTACK_COOLDOWN,
                melee_damage          : ENEMY_MELEE_ATTACK_DAMAGE,
                melee_duration        : ENEMY_MELEE_ATTACK_DURATION,
                melee_distance        : ENEMY_MELEE_ATTACK_DISTANCE,
                melee_extra_attacks   : ENEMY_MELEE_BOSS_EXTRA_ATTACKS,
                melee_extra_spread    : ENEMY_MELEE_BOSS_SPREAD,
            };
    }
}

/*
* Name: enemyConfigToughnessHpMultiplier
* Description: Scale factor applied to health per toughness tier.
*/
function enemyConfigToughnessHpMultiplier(_toughness)
{
    switch (_toughness)
    {
        case EnemyToughness.Elite: return ENEMY_TOUGHNESS_HP_ELITE;
        case EnemyToughness.Boss:  return ENEMY_TOUGHNESS_HP_BOSS;
        default:                   return ENEMY_TOUGHNESS_HP_NORMAL;
    }
}

/*
* Name: enemyConfigToughnessDamageMultiplier
* Description: Scale factor applied to outgoing damage per toughness tier.
*/
function enemyConfigToughnessDamageMultiplier(_toughness)
{
    switch (_toughness)
    {
        case EnemyToughness.Elite: return ENEMY_TOUGHNESS_DAMAGE_ELITE;
        case EnemyToughness.Boss:  return ENEMY_TOUGHNESS_DAMAGE_BOSS;
        default:                   return ENEMY_TOUGHNESS_DAMAGE_NORMAL;
    }
}

/*
* Name: enemyConfigAssign
* Description: Apply config values to an enemy instance based on type & toughness.
*/
function enemyConfigAssign(_inst, _type, _toughness)
{
    if (!instance_exists(_inst)) return;

    var _base = enemyConfigBaseStats(_type);
    var _hp_mult = enemyConfigToughnessHpMultiplier(_toughness);
    var _dmg_mult = enemyConfigToughnessDamageMultiplier(_toughness);

    with (_inst)
    {
        enemy_type      = _type;
        enemy_toughness = _toughness;

        enemy_idle_origin_x = x;
        enemy_idle_origin_y = y;

        enemy_idle_target_x = x;
        enemy_idle_target_y = y;

        enemy_idle_pause_min = ENEMY_IDLE_PAUSE_MIN;
        enemy_idle_pause_max = ENEMY_IDLE_PAUSE_MAX;
        enemy_idle_tolerance = ENEMY_IDLE_TOLERANCE;

        enemy_idle_speed = _base.idle_speed;
        enemy_speed      = _base.move_speed;
        enemy_range      = _base.activation_range;
        enemy_activation_range = _base.activation_range;
        enemy_leash_range      = max(_base.leash_range, _base.activation_range);
        enemy_wander_radius    = _base.wander_radius;
        enemy_active_delay_max = _base.active_delay;

        enemy_melee_range           = _base.melee_range;
        enemy_melee_cooldown_max    = _base.melee_cooldown;
        enemy_melee_damage          = round(_base.melee_damage * _dmg_mult);
        enemy_melee_attack_duration = _base.melee_duration;
        enemy_melee_attack_distance = _base.melee_distance;
        enemy_melee_extra_attacks   = _base.melee_extra_attacks;
        enemy_melee_extra_spread    = _base.melee_extra_spread;

        var _attack_sprite = enemyConfigResolveAttackSprite();
        enemy_melee_attack_sprite   = (_attack_sprite != -1) ? _attack_sprite : -1;

        enemy_projectile_cooldown_max = _base.projectile_cooldown;
        enemy_projectile_speed        = _base.projectile_speed;
        enemy_projectile_damage       = round(_base.projectile_damage * _dmg_mult);
        enemy_projectile_range        = _base.projectile_range;
        enemy_projectile_life         = _base.projectile_life;
        enemy_projectile_boss_extra   = _base.boss_projectiles;
        enemy_projectile_boss_spread  = _base.boss_spread_angle;
        enemy_retreat_radius          = _base.retreat_radius;
        enemy_retreat_speed           = _base.retreat_speed;

        hp_max = round(_base.hp * _hp_mult);
        hp     = clamp(hp, 0, hp_max);
    }
}
