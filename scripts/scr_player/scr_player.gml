//==============================================================================================================
// Name: scr_player
// Desc: Player related function definitions and configuration
//==============================================================================================================

#macro PLAYER_SPEED            2
#macro PLAYER_SLIME_CORES      5
#macro PLAYER_CORE_CAPACITY    10
#macro PLAYER_MELEE_DMG        5
#macro PLAYER_MELEE_CD         20
#macro PLAYER_PROJ_CD          5
#macro PLAYER_PROJ_DMG         10
#macro PLAYER_DASH_DIST        200
#macro PLAYER_DASH_CD          20
#macro PLAYER_BOOST_DURATION   5000
#macro PLAYER_BOOST_CD         20000



function playerInit() {
    stats = {
        speed:              PLAYER_SPEED,
        // Resources (Slime)
        slime_cores:        PLAYER_SLIME_CORES,
        core_capacity:      PLAYER_CORE_CAPACITY,
        // Melee (Slap)
        melee_dmg:          PLAYER_MELEE_DMG,
        melee_cd:           PLAYER_MELEE_CD,
        //Projectile (Splat)
        proj_dmg:           PLAYER_PROJ_DMG,
        proj_cd:            PLAYER_PROJ_CD,
        // Dash
        dash_dist:          PLAYER_DASH_DIST,
        dash_cd:            PLAYER_DASH_CD,
        // Boost
        boost_duration:     PLAYER_BOOST_DURATION,
        boost_cd:           PLAYER_BOOST_CD,
    }    
}