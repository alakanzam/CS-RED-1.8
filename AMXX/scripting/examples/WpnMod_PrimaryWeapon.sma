
/*
[WPN_FUNC]
a - Aim Down Sight
b - Grenade Launcher
c - Laser Sight
*/





enum ( <<= 1)
{
	FUNC_ADS = 1, // a
	FUNC_GRENADE_LAUNCHER, // b
	FUNC_LASER_SIGHT // c
}

enum ( <<= 1)
{
	ST_NO_CROSSHAIR = 1, // a
	ST_DUAL_WEAPON, // b
	ST_ADDITION_BULLET, // c
	ST_ACTIVE_DEFAULT_FUNC, // d
	ST_NO_MANUAL_RELOAD, // e
	ST_ANIM_DRAW_NO_AMMO, // f
	ST_ANIM_IDLE_NO_AMMO, // g
	ST_NEW_RELOAD, // h
	ST_ZOOM_SUPPORTED, // i
}

enum ( <<=1)
{
	SP_EXTENDED_CLIP  = 1, // a [ +5 Bullets]
	SP_ADJUSTABLE_STOCK, // b [ -15% Recoil]
	SP_LONG_BARREL, // c [+ 15 % Accuracy | - 10% Damage]
	SP_RAPID_FIRE, // d [+20% ROF]
	SP_FMJ // e [+ 15% Damage]
}

enum
{
	SPECIAL_NONE,
	SPECIAL_REACTIVE_ZOOM	
}

enum
{
	BULLET_TYPE_NONE,
	BULLET_TYPE_SHIELD_DESTRUCTION,
	BULLET_TYPE_SHOTGUN,
	BULLET_TYPE_EXPLOSIVE
}

enum
{
	GRENADE_START_RELOAD,
	GRENADE_INSERT,
	GRENADE_ADD_AMMO,
	GRENADE_AFTER_INSERT
}

enum
{
	GRENADE_NONE,
	GRENADE_UNDER_BARREL,
	GRENADE_BARREL
}

enum ( <<= 1 )
{
	DETONATE_ONTOUCH = 1, // a
	DETONATE_NO_SPR, // b
	DETONATE_NO_SOUND, // c
	TRAIL_ON_DETONATE, // d
	TRAIL_ON_MOVE, // e
	ACTIVE_ON_TOUCH, // f
	ATTACH_ON_TOUCH, //g
	DIRECTION_BY_TRACE	// h
	
}

enum ( <<= 1)
{
	THERMAL_ON = 1, // a
	THERMAL_NVG_SCREEN, // b
	THERMAL_NVG_LIGHT, // c
	THERMAL_TOGGLE, // d
	THERMAL_TEAM // e
}

enum ( <<= 1 )
{
	FIRE_MINIGUN = 1, // a
	FIRE_DRAW_SPIN_ANIM, // b
	FIRE_DRAW_AFTER_SPIN_ANIM, // c 
	FIRE_ON_RELEASE // d
}

enum ( <<= 1)
{
	ADS_NO_CS_CROSSHAIR = 1, //a
	ADS_NO_HL_CROSSHAIR, // b
	ADS_NO_INTRO_ANIM, // c
	ADS_NO_OUT_ANIM, // d
	ADS_ALTERNATIVE_MODEL, // e
	ADS_NEW_ROF, // f
	ADS_NEW_RECOIL // g
}

/********************************************/

/********************************************/

/********************************************/


enum (<<= 1)
{
	BFUNC_THERMAL_ON = 1, // a
	BFUNC_SEMI_ON,
	BFUNC_BURST_ON,
	BFUNC_FBURST_ON
}

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta_util>
#include <hamsandwich>
#include <xs>
#include <mmcl_util>
#include <engine>

#include <weaponbox_info>
#include <ArmouryManager>
#include <cswpn_ultilities>
#include <player_api>
#include <celltrie>
#include <cstrike_pdatas>


#include <WpnMod_Included/WM_COMMAND.inc>
#include <WpnMod_Included/LineInfo_PrimaryWpn.inc>
#include <WpnMod_Included/WM_GlobalConstant.inc>

#include <WpnMod_Included/WM_BackWeapon.inc>
#include <WpnMod_Included/WM_DefaultArmoury>



#define max_wpn 64
#define MAX_SPAWN_POINT 32


#define PRIMARY_WEAPONS_BITSUM  ((1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90))
#define SHOTGUN_BITSUM ((1<<CSW_M3)|(1<<CSW_XM1014))
#define SNIPER_BITSUM	((1<<CSW_SCOUT)|(1<<CSW_AWP)|(1<<CSW_G3SG1)|(1<<CSW_SG550))	



stock is_shotgun(iWeaponId)
	return (SHOTGUN_BITSUM & (1<<iWeaponId))

stock is_sniper(iWeaponId)
	return (SNIPER_BITSUM & (1<<iWeaponId))



/*		TASK SECTION		*/

#define TASK_FINISH_RELOAD_GREN 38000
#define TASK_GRENADE_LAUNCHER_READY 39000
#define TASK_PREPARE_RELOAD_GREN 37000
#define TASK_ATTACK_MELEE 40000
#define TASK_IRON_SIGHT 44000
#define TASK_INSERT_AMMO 36000
#define TASK_FINISH_RELOAD_AMMO 42000
#define TASK_SHOW_FAKE_NVG 35000
#define TASK_ADD_WEAPON_AMMO 41000
#define TASK_SHOW_LASER 30000
#define TASK_CROSSHAIR_TOGGLE 46000
#define TASK_NORMAL_IRONSIGHT 48000
#define TASK_FAMAS_BURST	49000
#define TASK_OPEN_FIRE	51000
#define TASK_CALL_THINK	53000


#define TASK_REGISTER_CZ_FUNCTION 43000

/**************************************/

#define BURST_CYCLE	0.1

#define INFINITIVE_RELOAD_TIME 9999.0

#define HIT_SHIELD 8


#define ZOOM_DELAYED 0.5



/*			TRIE SECTION			*/

new Trie:weapon_StringInfo[max_wpn]
new Trie:iBulletConfig[max_wpn]
new Trie:iPlayerInfo[33]

new Trie:iPrecachedModel
new Trie:iLoadedFile
new Trie:iThermalClass
new Trie:iThermalModel
new Trie:iWeaponBoxInfo
/********************************************************/

new Float:cl_pushangle[33][3]


new g_weapon_count = 0

new laser
new bool:bHamCZ


new g_LoadType


new TYPE_FULL	=	1000


#define MAX_CLASS 64


new iMaxPlayers






//	FOR SPAWN

new iTotalSpawnPoint = 0
new Float:fSpawnVecs[MAX_SPAWN_POINT][3]
new iSpawnWeaponId[MAX_SPAWN_POINT]

//	BIT TOOLS

#define SetPlayerBit(%1,%2)      (%1 |= (1<<(%2&31)))
#define ClearPlayerBit(%1,%2)    (%1 &= ~(1 <<(%2&31)))
#define CheckPlayerBit(%1,%2)    (%1 & (1<<(%2&31)))


#define SetBit(%1,%2)      (%1[%2>>5] |= (1<<(%2 & 31)))
#define ClearBit(%1,%2)    (%1[%2>>5] &= ~(1<<(%2 & 31)))
#define CheckBit(%1,%2)    (%1[%2>>5] & (1<<(%2 & 31)))  


//	BIT FIELD

new g_LauncherModeActivated // Check if player has activated Grenade Launcher mode
new g_SemiAutomaticMode // Check the if player is using Semi Automatic mode or not
new g_SpecialBurstMode // Check if the player is using Special Burst mode (Burst type of AN94 - Not Famas's)
new g_SpecialBurstFamas
new g_ReloadingGrenadeLauncher // Check if player is reloading his/her grenade launcher weapons
new g_CancelReloading // Check if player cancels reloading his/her Shotgun like weapon
new g_UsingZoomLen		// Check if player is zooming
new g_TurnOnThermal
new g_TurnOnNVG_BeforeThermal
new g_LaserSightON
new bit_NormalIronSight
new b_ExtraBulletInChamber
new b_KilledByExplosion




const UNIT_SECOND = (1<<12)



#define SECTION_DMG_RADIUS "DAMAGE_RADIUS"

#define SECTION_BULLET_SOUND "BULLET_SOUND"
#define SECTION_BULLET_GREN_TYPE	"BULLET_GREN_TYPE"
#define SECTION_P_MODEL "SECTION_P_MODEL"
#define SECTION_WPN_NAME "WEAPON_NAME"
#define SECTION_HUD_KILL "HUD_KILL"
#define SECTION_V_MODEL "VIEW_MODEL"
#define SECTION_W_MODEL "WORLD_MODEL"
#define SECTION_ADS_V_MODEL "SPECIAL_ADS_V_MODEL"
#define SECTION_GREN_V_MODEL	"GREN_V_MODEL"
#define SECTION_BACK_MODEL	"BACK_MODEL"
#define SECTION_GRENADE_DEATHMSG "GREN_DEATHMSG"

#define SECTION_WEAPON_CLASS "WEAPON_CLASS"

#define SECTION_LAUNCH_SOUND	"LAUNCH_SOUND"
#define SECTION_MELEE_SOUND	"MELEE_SOUND"


#define SECTION_FIRE_SOUND_ID "FIRE_SOUND_ID"
#define SECTION_SILENCER_SOUND_ID "SILENCER_SOUND_ID"
#define SECTION_BURST_SOUND_ID "BURST_SOUND_ID"

#define	SECTION_SPAWN_FILE	"SPAWN_FILE"
#define SECTION_UPDATE_HUD_KILL	"UPDATE_HUD_KILL"
#define SECTION_WEAPON_SERIAL	"WEAPON_SERIAL"


#define SECTION_DOUBLE_FILE	"DOUBLE_WPN_FILE"
#define SECTION_DOUBLE_SERIAL	"DOUBLE_WPN_SERIAL"
#define SECTION_WEAPON_SOUND	"WEAPON_SOUND"

/*		INTEGER			*/

#define SECTION_WEAPON_ID_1	"WEAPON_ID_1"
#define SECTION_WEAPON_ID_2	"WEAPON_ID_2"
#define SECTION_WEAPON_MAX_CLIP	"WEAPON_MAX_CLIP"
#define SECTION_WEAPON_BPA	"WEAPON_BPA"
#define SECTION_WEAPON_FUNC	"WEAPON_FUNC"
#define SECTION_WEAPON_SPECIAL	"WEAPON_SPECIAL"
#define SECTION_WEAPON_COST	"WEAPON_COST"
#define SECTION_WEAPON_COST_TYPE	"WEAPON_COST_TYPE"

#define SECTION_ALTER_FIREMODE	"ALTER_FIREMODE"
#define SECTION_ORIGIN_FIREMODE "ORIGIN_FIREMODE"

#define SECTION_WEAPON_LEVEL	"WEAPON_LEVEL"
#define SECTION_AMMO_COST	"AMMO_COST"
#define SECTION_AMMO_COST_TYPE	"AMMO_COST_TYPE"
#define SECTION_WEAPON_GRENADE_CLIP	"GRENADE_CLIP"
#define SECTION_WEAPON_GRENADE_BPA	"GRENADE_BPA"
#define SECTION_WEAPON_TYPE	"WEAPON_TYPE"
#define SECTION_WPN_EQUIP_METHOD "WPN_EQUIP_METHOD"

#define SECTION_GRENADE_COST	"GRENADE_COST"
#define SECTION_GRENADE_COST_TYPE "GRENADE_COST_TYPE"
#define SECTION_GRENADE_RADIUS	"GRENADE_RADIUS"

#define SECTION_THERMAL_RADIUS "THERMAL_RADIUS"
#define SECTION_THERMAL_ALPHA	"THERMAL_ALPHA"

#define SECTION_BACKWPN_SUB "BACKWPN_SUB"
#define SECTION_W_SUB "W_MODEL_SUB"
#define SECTION_P_SUB "P_MODEL_SUB"
#define SECTION_V_SUB	"V_MODEL_SUB"

#define SECTION_KNOCKBACK_RANGE "KNOCK_BACK_RANGE"

#define SECTION_FIRST_FOV	"FIRST_FOV"
#define SECTION_SECOND_FOV	"SECOND_FOV"

#define SECTION_SHOTGUN_PIECE	"SHOTGUN_PIECE"
#define SECTION_SPR_INDEX "SPRITE_INDEX"

#define SECTION_BULLET_GRENADE_MODEL	"BULLET_GRENADE_MODEL"
#define SECTION_BULLET_GRENADE_SUB	"BULLET_GRENADE_SUB"
#define SECTION_BULLET_SPR_FRAME "BL_SPR_FRAME"
#define SECTION_BULLET_SPR_SCALE "BL_SPR_SCALE"
#define SECTION_BULLET_SPR_BN	"BL_SPR_BN"
#define SECTION_BULLET_VELOCITY	"BULLET_VELOCITY"
#define SECTION_BULLET_FLAG	"BULLET_FLAG"
#define SECTION_BULLET_DMGBIT	"BULLET_DMGBIT"


#define SECTION_BURST_BULLET	"BURST_BULLET"

#define SECTION_ADS_FLAG	"ADS_FLAG"
#define SECTION_BASIC_SETTING	"BASIC_SETTING"

#define SECTION_BULLET_RED	"BL_R"
#define SECTION_BULLET_GREEN	"BL_G"
#define SECTION_BULLET_BLUE	"BL_B"
#define SECTION_BULLET_TW	"BL_TW"
#define SECTION_BULLET_TRBN	"BL_BN"
#define SECTION_BULLET_TSPR	"BL_TSPR"
#define SECTION_BULLET_TRL	"BL_TRL"

#define SECTION_BULLET_RED_2	"BL_R_2"
#define SECTION_BULLET_GREEN_2	"BL_G_2"
#define SECTION_BULLET_BLUE_2	"BL_B_2"
#define SECTION_BULLET_TW_2	"BL_TW_2"
#define SECTION_BULLET_TRBN_2	"BL_BN_2"
#define SECTION_BULLET_TSPR_2	"BL_TSPR_2"
#define SECTION_BULLET_TRL_2	"BL_TRL_2"

#define SECTION_THERMAL_FLAG	"THERMAL_FLAG"

#define SECTION_THERMAL_RED	"THERMAL_RED"
#define SECTION_THERMAL_GREEN	"THERMAL_GREEN"
#define SECTION_THERMAL_BLUE	"THERMAL_BLUE"

/*		FLOAT			*/

#define SECTION_BULLET_FALL_TIME	"BULLET_FALL_TIME"
#define SECTION_WEAPON_FIRE_RATE	"WEAPON_FIRE-RATE"
#define SECTION_WEAPON_SPEED_REDUCTION "WEAPON_SPEED_REDUCTION"
#define SECTION_WEAPON_RECOIL	"WEAPON_RECOIL"
#define SECTION_WEAPON_RELOAD_TIME "WEAPON_RELOAD_TIME"
#define SECTION_WEAPON_INSERT_TIME "WEAPON_INSERT_TIME"
#define SECTION_WEAPON_AF_INSERT_TIME "WEAPON_AF_INSERT_TIME"
#define SECTION_WEAPON_ACCURATE "WEAPON_ACCURATE"
#define SECTION_WEAPON_DEPLOY "WEAPON_DEPLOY_TIME"
#define SECTION_SHOTGUN_SPREAD	"SHOTGUN_SPREAD"

#define SECTION_WEAPON_DAMAGE "WEAPON_DAMAGE"
#define SECTION_WEAPON_WEIGHT	"WEAPON_WEIGHT"


#define SECTION_GRENADE_RECOIL	"GRENADE_RECOIL"
#define SECTION_GRENADE_ACTIVE_TIME "GRENADE_ACTIVE_TIME"
#define SECTION_GRENADE_DEACTIVE_TIME	"GRENADE_DEACTIVE_TIME"
#define SECTION_GRENADE_DELAY	"GRENADE_DELAY"

#define SECTION_WPN_FIRE_FLAG	"FIRE_FLAG"
#define SECTION_SPIN_TIME	"SPIN_TIME"
#define SECTION_DEACTIVE_SPIN	"DEACTIVE_SPIN"

#define SECTION_TIME_FM_CHANGE	"CHANGE_FM_TIME"
#define SECTION_TIME_FM_DELAY	"CHANGE_FM_DELAY"

#define SECTION_BULLET_TYPE	"BULLET_TYPE"

#define SECTION_BULLET_ACTIVE_TIME	"ACTIVE_TIME"
#define SECTION_BULLET_REMOVE_TIME	"REMOVE_TIME"


#define SECTION_TIME_GREN_START_REL	"GREN_START_REL"
#define SECTION_GREN_DMG	"GREN_DMG"
#define SECTION_TIME_GREN_FIN	"GREN_FIN"
#define SECTION_TIME_GREN_INS	"GREN_INS"

#define SECTION_TIME_ADS_IN	"TIME_ADS_IN"
#define SECTION_TIME_ADS_OUT	"TIME_ADS_OUT"
#define SECTION_ADS_ROF		"ADS_ROF"
#define SECTION_ADS_RECOIL	"ADS_RECOIL"

#define SECTION_CHANGE_DB_TIME	"CHANGE_DB_TIME"

#define SECTION_KNOCKBACK_POWER	"KNOCKBACK_POWER"


//		PLAYER TRIE SECTION

#define SECTION_GRENADE_CLIP	"GRENADE_CLIP"
#define SECTION_GRENADE_BPA	"GRENADE_BPA"
#define SECTION_GRENADE_CLIP_STORE	"GRENADE_CLIP_STORE"
#define SECTION_GRENADE_BPA_STORE	"GRENADE_BPA_STORE"

#define SECTION_ATTACK_STAGE	"ATTACK_STAGE"

#define SECTION_USER_WPN_ID	"USER_WPN_ID"
#define SECTION_USER_ZOOM_LVL	"USER_ZOOM_LVL"
#define SECTION_ATTACK_TIME	"USER_ATK_TIME"
#define SECTION_USER_WPN_FLAG	"USER_WPN_FLAG"

/****************************************/

#define PREFIX_SLOT_EQUIPMENT_FLAG	"SLOT_EQUIPMENT_FLAG"
#define PREFIX_SLOT_GRENADE_AMMO	"SLOT_AMMO_"
#define PREFIX_SLOT_GRENADE_BPA	"SLOT_BPA_"
#define PREFIX_SLOT_GRENADE_AMMO_STORE	"SLOT_AMMO_STORE_"
#define PREFIX_SLOT_GRENADE_BPA_STORE	"SLOT_BPA_STORE_"
#define PREFIX_SLOT_FLAG	"SLOT_WPNBOX_FLAG"
#define PREFIX_SLOT_CLIP	"SLOT_CLIP"
#define PREFIX_SLOT_BPA		"SLOT_BPA"

/****************************************/
#define MOD_EXTENDED_CLIP	"MD_EXT_CLIP"
/****************************************/

#define SOUND_CHANNEL	CHAN_STREAM

#define clamp_byte(%1)     ( clamp( %1, 0, 255 ) ) 
#define write_coord_f(%1)  ( engfunc( EngFunc_WriteCoord, %1 ) )



new iFM_AddToFullPack = 0

enum
{
	GRENADE_NONE,
	GRENADE_EXPLOSION,
	GRENADE_FLASH
}

#define GRENADE_CLASS "grenade"

//	ANIMATION

/***************************************************/

#define ANIMATION_START_IRONSIGHT	1
#define ANIMATION_STOP_IRONSIGHT	3

#define ANIMATION_INSERT_BULLET	5
#define ANIMATION_FINISH_RELOAD	7

#define ANIMATION_IDLE_IRONSIGHT_3	9
#define ANIMATION_SHOOT_IRONSIGHT_3	11

#define ANIM_SILENCER_ADD	1

#define ANIM_SPIN_PRE	13
#define ANIM_SPIN_POST	15

#define ANIMATION_CHANGE_GREN	17
#define ANIMATION_CHANGE_GREN_BACK	1

#define ANIMATION_CHANGE_DOUBLE	19

/***************************************************/


new iDecal

#define LASER_DRAW_TIME	0.3

enum
{
	STAGE_NONE,
	STAGE_SPIN,
	STAGE_FIRE,
	STAGE_FIRE_RELEASE
}

enum
{
	FIRE_DEFAULT,
	FIRE_AUTO_SEMI,
	FIRE_AUTO_BURST,
	FIRE_AUTO_FAMAS,
	FIRE_AUTO_SEMI_BURST,
	FIRE_AUTO_SEMI_BURST_FAMAS
}

enum
{
	FIRE_DEFAULT,
	FIRE_SEMI,
	FIRE_BURST,
	FIRE_BURST_FAMAS
}

enum
{
	FUNC_OFF,
	FUNC_ON
}


//		MENU
new iArmouryMenuId

//		FORWARDS
/********************************************************************/
new ifw_CheckPrimaryWpnSerial
new ifw_FuncActivated
new ifw_ArmouryPickedUp
new ifw_StartLoadData
new ifw_WpnLoadedSucccessful

new ifw_UserCanTouchWpnBox
new ifw_UserCanTouchArmoury
new ifw_UserCanUseSecFunc
new ifw_UserCanEquipWpn
new ifw_ArmouryEntitySpawn

new ifw_GrenadeDamage

/********************************************************************/


new ifw_Result



enum {
	idle,
	shoot1,
	shoot2,
	insert,
	after_reload,
	start_reload,
	draw
}

#define	m_flNextPrimaryAttack		46
#define	m_flNextSecondaryAttack	47

#define WPN_CONFIG_DIR	"WPN_MOD/PRIMARY_WPN/CONFIGS"
#define WPN_SPAWN_DIR	"WPN_MOD/PRIMARY_WPN/SPAWN"
#define WPN_SPEC_DIR	"WPN_MOD/PRIMARY_WPN/SPEC"
#define WPN_ADD_DIR	"WPN_MOD/PRIMARY_WPN/ADD"
#define WPN_MANAGER_DIR	"WPN_MOD/PRIMARY_WPN"
#define	WPN_MANAGER_FILE	"MANAGER.CFG"


/*********************************************************/
#define SP_RECOIL_DOWN_ADS	0.25
#define SP_RECOIL_DOWN_STOCK	0.15
#define SP_DMG_DOWN_BARREL	0.1
#define SP_DMG_UP_FMJ	0.15
#define SP_SPEED_UP_RP	0.2
#define SP_ACCURACY_UP_LB	0.15
/*********************************************************/

/*			MSG ID			*/
new iMSGID_DeathMSG
new iMsgScreenFade

/************************************************/


	
public plugin_natives()
{
	register_native("get_user_pw", "native_get_user_primary_id", 1)
	register_native("set_user_pw", "native_set_user_primary_id", 1)
	register_native("get_pw_real_id", "native_get_primary_real_id", 1)
	register_native("get_pw_real_id_2", "native_get_primary_real_id_2", 1)
	register_native("get_pw_number", "native_get_primary_number", 1)
	register_native("give_user_pw", "native_give_user_primary_wpn", 1)
	register_native("get_pw_hud", "native_get_primary_wpn_hud", 1)
	register_native("get_pw_name", "native_get_primary_wpn_name", 1)
	register_native("get_pw_weight", "native_get_primary_wpn_weight", 1)
	register_native("find_pw_by_model", "native_find_wpn_by_model", 1)
	register_native("get_pw_speed", "native_get_primary_wpn_speed", 1)
	register_native("get_pw_cost", "native_get_primary_wpn_cost", 1)
	register_native("get_pw_cost_type", "native_get_wpn_cost_type", 1)
	register_native("get_pw_bpammo", "native_get_primary_wpn_bpammo", 1)
	register_native("set_pw_load_type", "native_set_wpn_load_type", 1)
	register_native("get_pw_ammo", "native_get_primary_wpn_ammo", 1)
	register_native("pw_user_using_grenadier", "player_using_grenadier", 1)
	register_native("get_pw_grenade_clip", "native_get_primary_grenade_clip", 1)
	register_native("get_pw_grenade_bpa", "native_get_primary_grenade_bpa", 1)
	register_native("is_pw_grenadier", "native_is_primary_wpn_grenadier",1 )
	register_native("set_user_pw_grenade", "set_user_wpn_grenade",1 )
	register_native("get_pw_type", "native_get_primary_wpn_type", 1)
	register_native("get_pw_function", "native_get_primary_wpn_func", 1)
	register_native("get_pw_special", "native_get_primary_wpn_special", 1)
	register_native("pw_user_attack_stage", "native_get_minigun_attack_stage", 1) 
	register_native("set_pw_spawn", "native_set_primary_wpn_spawn", 1)
	register_native("get_pw_world_model", "native_get_primary_world_model", 1)
	register_native("get_pw_equiptype", "native_get_primary_equiptype", 1)
	register_native("is_valid_pw", "native_is_valid_pw", 1)
	
	register_native("get_pw_serial", "native_get_primary_wpn_serial", 1)
	register_native("find_pw_by_serial", "native_find_wpn_by_serial", 1)
	
	
	register_native("set_pw_load_file", "native_set_wpn_load_file", 1)
	
	register_native("get_pw_kb_power", "native_get_primary_kb_power", 1)
	register_native("get_pw_kb_distance", "native_get_primary_kb_distance", 1)
	
	register_native("pw_is_ads", "native_is_primary_wpn_ads", 1)
	
	register_native("get_pw_back_model", "native_get_wpn_back_model", 1)
	register_native("get_pw_back_sub", "native_get_primary_wpn_back_sub", 1)
	register_native("set_user_pw_flag", "native_set_user_pw_flag", 1)
}


public native_get_user_primary_id(id)
	return get_trie_int(iPlayerInfo[id], SECTION_USER_WPN_ID, -1)

public native_set_user_primary_id(id, iPrimaryWpnId)
{
	if (!native_is_valid_pw(iPrimaryWpnId))
	{
		delete_trie_key(iPlayerInfo[id], SECTION_USER_WPN_ID)
		return
	}
	
	set_trie_int(iPlayerInfo[id], SECTION_USER_WPN_ID, iPrimaryWpnId)
}

public native_get_primary_real_id(iPrimaryWpnId)
{
	if (!native_is_valid_pw(iPrimaryWpnId))
		return -1
	
	return get_trie_int(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_ID_1)
}

public native_get_primary_real_id_2(iPrimaryWpnId)
{
	if (!native_is_valid_pw(iPrimaryWpnId))
		return -1
	
	return get_trie_int(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_ID_2)
}

public native_get_primary_number()
	return g_weapon_count
	
public native_give_user_primary_wpn(id, iPrimaryWpnId)
{
	if (!native_is_valid_pw(iPrimaryWpnId))
	{
		native_set_user_primary_id(id, -1)
		return 0
	}
	
	if (!is_user_alive(id)) 
		return 0
	
	if (!can_player_equip_prim_wpn(id))
		return 0
		
	new iVip = cs_get_user_vip(id)
	
	new iEquipMethod = native_get_primary_equiptype(iPrimaryWpnId)
	
	if ((!iVip && iEquipMethod == EQ_VIP_ONLY) || (iVip && iEquipMethod == EQ_PLAYER_ONLY))
		return 0
		
	if (iVip)
		cs_set_user_vip(id, 0, 0, 0)
		
	new iWPN_ID = native_get_primary_real_id(iPrimaryWpnId)
	
	new szWeaponName[32]
	
	UT_DropPrimaryWeapon(id)
	
	
	get_weaponname(iWPN_ID, szWeaponName, sizeof szWeaponName - 1)
	
	native_set_user_primary_id(id, iPrimaryWpnId)
	if (CheckPlayerBit(g_LauncherModeActivated, id))	ClearPlayerBit(g_LauncherModeActivated, id);
	if (CheckPlayerBit(g_SpecialBurstMode, id))	ClearPlayerBit(g_SpecialBurstMode, id);
	if (CheckPlayerBit(g_SemiAutomaticMode, id))	ClearPlayerBit(g_SemiAutomaticMode, id);
	if (CheckPlayerBit(g_SpecialBurstFamas, id))	ClearPlayerBit(g_SpecialBurstFamas, id);
	
	new iEnt = fm_give_item(id, szWeaponName)
	
	if (iEnt < 0 || !pev_valid(iEnt))
		return 0
		
	UT_SetWeaponSpecialFunction(iPrimaryWpnId, iEnt)
	
	new iOriginalFireMode
	TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_ORIGIN_FIREMODE, iOriginalFireMode)
	
	if (iOriginalFireMode == FIRE_SEMI)
	{
		UT_set_weapon_burst(iEnt, 0)
		if (!CheckPlayerBit(g_SemiAutomaticMode, id))	SetPlayerBit(g_SemiAutomaticMode, id)
	}
	else if (iOriginalFireMode == FIRE_BURST)
	{
		UT_set_weapon_burst(iEnt, 0)
		if (!CheckPlayerBit(g_SpecialBurstMode, id))	SetPlayerBit(g_SpecialBurstMode, id)
	}
	else if (iOriginalFireMode == FIRE_BURST_FAMAS)
	{
		if (!CheckPlayerBit(g_SpecialBurstFamas, id))	SetPlayerBit(g_SpecialBurstFamas, id)
		UT_set_weapon_burst(iEnt, 0)
	}
	
	cs_set_weapon_ammo(iEnt, native_get_primary_wpn_ammo(iPrimaryWpnId, 0))
	UT_SetUserBPA(id, iWPN_ID, native_get_primary_wpn_bpammo(iPrimaryWpnId))
	
	
	new iGrenadeClip, iGrenadeBpa
	
	if (native_get_primary_wpn_func(iPrimaryWpnId) & FUNC_GRENADE_LAUNCHER)
	{
		iGrenadeClip = native_get_primary_grenade_clip(iPrimaryWpnId)
		iGrenadeBpa = native_get_primary_grenade_bpa(iPrimaryWpnId)
	
		set_grenade_launcher_ammo(id, iGrenadeClip,  iGrenadeBpa)
	}
	
	
	if (iVip)
	{
		iVip = 0
		cs_set_user_vip(id, 1, 1, 1)
	}
		
	ExecuteHamB(Ham_Item_Deploy, iEnt)
	
	return iEnt
}

public native_get_primary_wpn_hud(iPrimaryWpnId, szOutput[], iLen)
{
	param_convert(2)
	if (!native_is_valid_pw(iPrimaryWpnId))
		return
	
	TrieGetString(weapon_StringInfo[iPrimaryWpnId], SECTION_HUD_KILL, szOutput, iLen)
	
}

public native_get_primary_wpn_name(iPrimaryWpnId, szName[], iLen)
{
	param_convert(2)
	if (!native_is_valid_pw(iPrimaryWpnId))
		return
		
	TrieGetString(weapon_StringInfo[iPrimaryWpnId], SECTION_WPN_NAME, szName, iLen)

}


public Float:native_get_primary_wpn_weight(iPrimaryWpnId)
{
	if (!native_is_valid_pw(iPrimaryWpnId))
		return 0.0
		
	new Float:fWeight
	TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_WEIGHT, fWeight)
	return fWeight
}

public Float:native_get_primary_wpn_speed(iPrimaryWpnId)
{
	if (!native_is_valid_pw(iPrimaryWpnId))
		return 0.0
	
	new Float:fSpeedReduction
	TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_SPEED_REDUCTION, fSpeedReduction)
	return fSpeedReduction
}


public native_find_wpn_by_model(szModel[])
{
	param_convert(1)
	for (new i = 0; i < g_weapon_count; i++)
	{
		new szWorldModel[128]
		TrieGetString(weapon_StringInfo[i], SECTION_W_MODEL, szWorldModel, sizeof szWorldModel - 1)
		
		if (equal(szModel, szWorldModel))
			return i
	}
	return -1
}

public native_get_primary_wpn_cost(iPrimaryWpnId)
{
	if (!native_is_valid_pw(iPrimaryWpnId))
		return -1
		
	return get_trie_int(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_COST)
}

public native_get_wpn_cost_type(iPrimaryWpnId)
{
	if (!native_is_valid_pw(iPrimaryWpnId))
		return -1
		
	return get_trie_int(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_COST_TYPE)
}

public native_get_primary_wpn_bpammo(iPrimaryWpnId)
{
	if (!native_is_valid_pw(iPrimaryWpnId))
		return 0
		
	return get_trie_int(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_BPA)
}

public native_set_wpn_load_type(loadtype)
	g_LoadType = loadtype

public native_get_primary_wpn_ammo(iPrimaryWpnId, id)
{
	if (!native_is_valid_pw(iPrimaryWpnId))
		return 0
		
	if (id)
	{
		if (get_trie_int(iPlayerInfo[id], SECTION_USER_WPN_FLAG) & SP_EXTENDED_CLIP)
		{
			new iExtendedClip = get_trie_int(weapon_StringInfo[iPrimaryWpnId], MOD_EXTENDED_CLIP)
			return iExtendedClip
		}
	}
	
	return get_trie_int(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_MAX_CLIP)
}

public player_using_grenadier(id)
{
	if (!is_user_alive(id))
		return 0
		
	new iPrimaryWpnId = native_get_user_primary_id(id)
	
	if (!native_is_valid_pw(iPrimaryWpnId))
		return 0
	
	new iWPN_ID = native_get_primary_real_id(iPrimaryWpnId)
	
	if (get_user_weapon(id) != iWPN_ID)
		return 0
		
	if (CheckPlayerBit(g_LauncherModeActivated, id))
		return 1
		
	return 0
}

public native_get_primary_grenade_clip(iPrimaryWpnId)
{
		
	if (!native_is_valid_pw(iPrimaryWpnId))
		return 0
	
	return get_trie_int(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_GRENADE_CLIP)
}


public native_get_primary_grenade_bpa(iPrimaryWpnId)
{
	if (!native_is_valid_pw(iPrimaryWpnId))
		return 0
		
	return get_trie_int(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_GRENADE_BPA)
}

public native_is_primary_wpn_grenadier(iPrimaryWpnId)
{
	if (!native_is_valid_pw(iPrimaryWpnId))
		return 0
		
	new iWPN_FUNC = native_get_primary_wpn_func(iPrimaryWpnId)
	
	if (!(iWPN_FUNC & FUNC_GRENADE_LAUNCHER))
		return 0
		
	return 1
}

public set_user_wpn_grenade(id, iPrimaryWpnId, iClip, iBpa)
{
	if (iPrimaryWpnId< 0 || iPrimaryWpnId > g_weapon_count - 1)
		return
		
	new iWPN_FUNC = native_get_primary_wpn_func(iPrimaryWpnId)
	
	if (!(iWPN_FUNC & FUNC_GRENADE_LAUNCHER))
		return
		
	set_grenade_launcher_ammo(id,  iClip, iBpa)
	return 
}

public native_get_primary_wpn_type(iPrimaryWpnId)
{
	if (!native_is_valid_pw(iPrimaryWpnId))
		return 0
		
	return get_trie_int(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_TYPE)
}


public native_get_primary_wpn_func(iPrimaryWpnId)
{
	if (!native_is_valid_pw(iPrimaryWpnId))
		return 0
		
	return get_trie_int(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_FUNC)
}

public native_get_primary_wpn_special(iPrimaryWpnId)
{
	if (!native_is_valid_pw(iPrimaryWpnId))
		return SPECIAL_NONE
		
	return get_trie_int(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_SPECIAL)
}

public native_get_minigun_attack_stage(id)
	return get_trie_int(iPlayerInfo[id], SECTION_ATTACK_STAGE)

public native_set_primary_wpn_spawn(iPoint, iPrimaryWpnId, Float:fOrigin[3])
	CreateArmoury(iPoint, iPrimaryWpnId, fOrigin)
	
public native_get_primary_world_model(iPrimaryWpnId, szOutput[], iLen)
{
	param_convert(2)
	if (!native_is_valid_pw(iPrimaryWpnId))
		return 0
		
	TrieGetString(weapon_StringInfo[iPrimaryWpnId], SECTION_W_MODEL, szOutput, iLen)
	
	return 1
}

public native_get_primary_equiptype(iPrimaryWpnId)
{
	if (!native_is_valid_pw(iPrimaryWpnId))
		return 0
		
	return get_trie_int(weapon_StringInfo[iPrimaryWpnId], SECTION_WPN_EQUIP_METHOD)
}

public native_is_valid_pw(iPrimaryWpnId)
{
	if (iPrimaryWpnId < 0 || iPrimaryWpnId > g_weapon_count - 1)
		return 0
		
	return 1
}

public native_get_primary_wpn_serial(iPrimaryWpnId, szSerial[], iLen)
{
	if (!native_is_valid_pw(iPrimaryWpnId))
		return
		
	param_convert(2)
	TrieGetString(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_SERIAL, szSerial, iLen)
}


public native_find_wpn_by_serial(szSerial[])
{
	param_convert(1)
	return _find_primary_wpn_by_serial(szSerial)
}


public native_set_wpn_load_file(szFile[], szExtension[], iIgnoreCondition)
{		
	param_convert(1)
	param_convert(2)
	
	if (TrieKeyExists(iLoadedFile, szFile))
		return
	
	load_primary_wpn_file(WPN_CONFIG_DIR, szFile, szExtension, iIgnoreCondition)
	
}

public Float:native_get_primary_kb_power(iPrimaryWpnId)
{
	if (!native_is_valid_pw(iPrimaryWpnId))
		return 0.0
		
	if (!TrieKeyExists(weapon_StringInfo[iPrimaryWpnId], SECTION_KNOCKBACK_POWER))
		return 0.0
		
	new Float:fKnockBackPower
	TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_KNOCKBACK_POWER, fKnockBackPower)
	return fKnockBackPower
}

public Float:native_get_primary_kb_distance(iPrimaryWpnId)
{
	if (!native_is_valid_pw(iPrimaryWpnId))
		return 0.0
		
	if (!TrieKeyExists(weapon_StringInfo[iPrimaryWpnId], SECTION_KNOCKBACK_RANGE))
		return 0.0
		
	new Float:fKnockBackRange
	TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_KNOCKBACK_RANGE, fKnockBackRange)
	return fKnockBackRange
}

public native_is_primary_wpn_ads(id)
{		
	new iPrimaryWpnId = native_get_user_primary_id(id)
	if (!native_is_valid_pw(iPrimaryWpnId))
	{
		if (CheckPlayerBit(bit_NormalIronSight, id))
			return 1
		return 0
	}
	
	new iWPN_FUNC = native_get_primary_wpn_func(iPrimaryWpnId)
	
	if (!(iWPN_FUNC & FUNC_ADS))
		return 0
	
	if (CheckPlayerBit(g_UsingZoomLen, id))
		return 1
	
	return 0
}

public native_get_wpn_back_model(iPrimaryWpnId, szOutput[], iLen)
{
	param_convert(2)
	
	if (!native_is_valid_pw(iPrimaryWpnId))
		return 0
	
	TrieGetString(weapon_StringInfo[iPrimaryWpnId], SECTION_BACK_MODEL, szOutput, iLen)
	return 1
}

public native_get_primary_wpn_back_sub(iPrimaryWpnId)
{
	if (!native_is_valid_pw(iPrimaryWpnId))
		return -1
		
	return get_trie_int(weapon_StringInfo[iPrimaryWpnId], SECTION_BACKWPN_SUB)
}

public native_set_user_pw_flag(id, iPrimaryWpnId, szFlag[])
{
	param_convert(3)
	set_user_pw_flag(id, iPrimaryWpnId, szFlag)
}

stock set_user_pw_flag(id, iPrimaryWpnId, szFlag[])
{
	if (!is_user_connected(id))
		return
		
	new iFlag = read_flags(szFlag)
	
	if (!native_is_valid_pw(iPrimaryWpnId))
	{
		set_trie_int(iPlayerInfo[id], SECTION_USER_WPN_FLAG, iFlag)
		return
	}
	
	if (iFlag & SP_ADJUSTABLE_STOCK)
	{
		if (!(get_trie_int(iPlayerInfo[id], SECTION_BASIC_SETTING) & ST_ADDITION_BULLET))
			iFlag &= ~SP_ADJUSTABLE_STOCK
	}
	
	set_trie_int(iPlayerInfo[id], SECTION_USER_WPN_FLAG, iFlag)
}

stock load_primary_wpn_file(szWpnDirectory[], szFileName[], szExtension[], iIgnore_AllCondition)
{
	if (g_weapon_count > max_wpn - 1)
		return
		
	new szLoadingFile[256]
	new szCfgDir[128], szMapName[32]
	
	get_configsdir(szCfgDir, sizeof szCfgDir - 1)
	get_mapname(szMapName, sizeof szMapName -1 )
	
	formatex(szLoadingFile, sizeof szLoadingFile - 1, "%s/%s/%s.%s", szCfgDir, szWpnDirectory, szFileName, szExtension)
	
	if (!file_exists(szLoadingFile))
		return
		
	if (TrieKeyExists(iLoadedFile, szFileName))
		return 
		
	if (!iPrecachedModel)
		iPrecachedModel = TrieCreate()
	
	new szText[256], iTextLen
	
	read_file(szLoadingFile, LINE_WPN_TYPE, szText, sizeof szText - 1, iTextLen)
	replace(szText, sizeof szText - 1, "[WPN_TYPE]", "")
	
	
	new szWeaponType[10]
	parse(szText, szWeaponType, sizeof szWeaponType -1)
	
	new iWeaponType = str_to_num(szWeaponType)
	TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_WEAPON_TYPE, iWeaponType)
	
	if (g_LoadType != TYPE_FULL && iWeaponType != g_LoadType)
		return
		
	
	
	read_file(szLoadingFile, LINE_WEAPON_SERIAL, szText, sizeof szText -1, iTextLen)
	replace(szText, sizeof szText - 1, "[iSerial]", "")
	
	if (!iIgnore_AllCondition)
	{
		ExecuteForward(ifw_CheckPrimaryWpnSerial, ifw_Result, szText)
		
		if (ifw_Result != PLUGIN_CONTINUE)
			return 
	}
	
	TrieSetString(weapon_StringInfo[g_weapon_count], SECTION_WEAPON_SERIAL, szText)
	
	read_file(szLoadingFile, LINE_WPN_BASIC_SET, szText, sizeof szText - 1, iTextLen)
	replace(szText, sizeof szText - 1, "[BasicSetting]", "")
	new iBasicSetting = read_flags(szText)
	
	
	TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BASIC_SETTING, iBasicSetting)
	
	read_file(szLoadingFile, LINE_WPN_NAME, szText, sizeof szText - 1, iTextLen)
	replace(szText, sizeof szText - 1, "[WPN_NAME]", "")
	TrieSetString(weapon_StringInfo[g_weapon_count], SECTION_WPN_NAME, szText)
	
	
	read_file(szLoadingFile, LINE_WPN_ID, szText, sizeof szText - 1, iTextLen)
	replace(szText, 255, "[WPN_ID]", "")
	new szFirstChange[3], szSecondChange[3]
	
	parse(szText, szFirstChange, sizeof szFirstChange - 1, szSecondChange, sizeof szSecondChange - 1)
	
	new iWPN_ID_1 = str_to_num(szFirstChange)
	
	if (!is_primary_wpn(iWPN_ID_1))
		return
		
	TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_WEAPON_ID_1, iWPN_ID_1)
	TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_WEAPON_ID_2, str_to_num(szSecondChange))
			
	read_file(szLoadingFile, LINE_WPN_AMMO, szText, sizeof szText - 1, iTextLen)
	replace(szText, sizeof szText - 1, "[WPN_AMMO]", "")
	new szClip[5], szBpa[5]
	parse(szText, szClip, sizeof szClip - 1, szBpa, sizeof szBpa - 1)
	TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_WEAPON_MAX_CLIP, str_to_num(szClip))
	TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_WEAPON_BPA, str_to_num(szBpa))
	
	if (iWeaponType == TYPE_SHIELD)
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_WEAPON_MAX_CLIP, 0)
		
	read_file(szLoadingFile, LINE_BULLET_TYPE, szText, sizeof szText - 1, iTextLen)
	replace(szText, sizeof szText - 1, "[iBulletType]", "")
	new szBulletType[3], szBulletDmgBit[32]
	parse(szText, szBulletType, sizeof szBulletType - 1, szBulletDmgBit, sizeof szBulletDmgBit - 1)
	new iBulletType = str_to_num(szBulletType)
	TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BULLET_TYPE,  iBulletType)
	
	if (iBulletType > 0)
	{
		TrieSetCell(iBulletConfig[g_weapon_count], SECTION_BULLET_DMGBIT, read_flags(szBulletDmgBit))
		
		read_file(szLoadingFile, LINE_BULLET_INFO, szText, sizeof szText - 1, iTextLen)
		replace(szText, sizeof szText - 1, "[iBulletInfo]", "")
		
		load_bulletinfo(szWpnDirectory, szFileName, szExtension, iBulletType, g_weapon_count)
	}
	
	read_file(szLoadingFile, LINE_WPN_DELAY, szText, sizeof szText - 1, iTextLen)
	replace(szText, sizeof szText - 1, "[WPN_DELAY]", "")
	new szDelay[10]
	parse(szText, szDelay, sizeof szDelay - 1)
	
	TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_WEAPON_FIRE_RATE, str_to_float(szDelay))
		
	
	read_file(szLoadingFile, LINE_WPN_RELOADTIME, szText, sizeof szText - 1, iTextLen)
	replace(szText, sizeof szText - 1, "[WPN_Reloadime]", "")
	
	new szReloadTime[10], szInsertTime[10], szFinishTime[10]
	parse(szText, szReloadTime, sizeof szReloadTime - 1, szInsertTime, sizeof szInsertTime - 1, szFinishTime, sizeof szFinishTime - 1)
	TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_WEAPON_RELOAD_TIME, str_to_float(szReloadTime))	
	
	if (iBasicSetting & ST_NEW_RELOAD)
	{
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_WEAPON_INSERT_TIME, str_to_float(szInsertTime))
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_WEAPON_AF_INSERT_TIME, str_to_float(szFinishTime))
	}
	
	read_file(szLoadingFile, LINE_WPN_DEPLOYTIME, szText, sizeof szText - 1, iTextLen)
	replace(szText, sizeof szText - 1, "[WPN_DeployTime]", "")
	TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_WEAPON_DEPLOY, str_to_float(szText))
	
	read_file(szLoadingFile, LINE_WPN_RECOIL, szText, sizeof szText - 1, iTextLen)
	replace(szText, sizeof szText - 1, "[WPN_RECOIL]", "")
	TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_WEAPON_RECOIL, str_to_float(szText))
	
	read_file(szLoadingFile, LINE_WPN_ACCURACY, szText, sizeof szText - 1, iTextLen)
	replace(szText, sizeof szText - 1, "[WPN_ACCURACY]", "")
	TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_WEAPON_ACCURATE, str_to_float(szText))
	
	
	read_file(szLoadingFile, LINE_WPN_ZOOM, szText, sizeof szText - 1, iTextLen)
	replace(szText, sizeof szText - 1, "[WPN_ZOOM]", "")
	
	new szFirstZoom[3], szSecondZoom[3]
	parse(szText, szFirstZoom, sizeof szFirstZoom - 1, szSecondZoom, sizeof szSecondZoom - 1)
	
	if (iBasicSetting & ST_ZOOM_SUPPORTED)
	{
		new iFirstFOV, iSecondFOV
		iFirstFOV = 90 - str_to_num(szFirstZoom)
		iSecondFOV = 90 - str_to_num(szSecondZoom)
		
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_FIRST_FOV, iFirstFOV)
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_SECOND_FOV, iSecondFOV)
		
		if (iFirstFOV == 90)
		{
			iBasicSetting &= ~ST_ZOOM_SUPPORTED
			TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BASIC_SETTING, iBasicSetting)
		}
	}
	
	read_file(szLoadingFile, LINE_WPN_SPECIAL, szText, sizeof szText - 1, iTextLen)
	replace(szText, sizeof szText - 1, "[WPN_SPECIAL]", "")
	new iWPN_SPECIAL = str_to_num(szText)
	TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_WEAPON_SPECIAL, iWPN_SPECIAL)
	
	read_file(szLoadingFile, LINE_WPN_FUNC, szText, sizeof szText - 1, iTextLen)
	replace(szText, sizeof szText - 1, "[WPN_FUNC]", "")
	new iWPN_FUNC = read_flags(szText)
	
	
	
	TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_WEAPON_FUNC, iWPN_FUNC)
	
	read_file(szLoadingFile, LINE_WPN_FIREMODE, szText, sizeof szText - 1, iTextLen)
	replace(szText, sizeof szText - 1, "[WPN_FIREMODE]", "")
	
	new szDefaultFireMode[3], szFireMode[3], szBurstedBullet[3]
	new szTimeChangeFM[10], szTimeDelayFM[10]
	new szSpecialFireMode[10], szSpinTime[10], szAfterSpinTime[10]
	
	parse(szText, szDefaultFireMode, sizeof szDefaultFireMode - 1, szFireMode, sizeof szFireMode - 1, szBurstedBullet, sizeof szBurstedBullet - 1, 
		szTimeChangeFM, sizeof szTimeChangeFM - 1, szTimeDelayFM, sizeof szTimeDelayFM - 1,
	             szSpecialFireMode, sizeof szSpecialFireMode - 1, szSpinTime, sizeof szSpinTime - 1, szAfterSpinTime, sizeof szAfterSpinTime - 1)
	
	new iDefaultFireMode = str_to_num(szDefaultFireMode)
	new iAlterFireMode = str_to_num(szFireMode)
	
	TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_ORIGIN_FIREMODE, iDefaultFireMode)
	TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_ALTER_FIREMODE, iAlterFireMode)
	
	if (iAlterFireMode != FIRE_DEFAULT || iDefaultFireMode != FIRE_DEFAULT)
	{
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BURST_BULLET, str_to_num(szBurstedBullet))
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_TIME_FM_CHANGE, str_to_float(szTimeChangeFM))
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_TIME_FM_DELAY, str_to_float(szTimeDelayFM))
	}
		
	new iTriggerFlag = read_flags(szSpecialFireMode)
	TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_WPN_FIRE_FLAG, iTriggerFlag)
	
	if (iTriggerFlag & FIRE_MINIGUN)
	{	
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_SPIN_TIME, str_to_float(szSpinTime))
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_DEACTIVE_SPIN, str_to_float(szAfterSpinTime))
	}
	
	read_file(szLoadingFile, LINE_WPN_HUD, szText, sizeof szText - 1, iTextLen)
	replace(szText, sizeof szText - 1, "[WPN_HUD]", "")
	new szHud[64], szOriginalHud[10]
	parse(szText, szHud, sizeof szHud - 1, szOriginalHud, sizeof szOriginalHud - 1)
	TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_UPDATE_HUD_KILL	, str_to_num(szOriginalHud))
	TrieSetString(weapon_StringInfo[g_weapon_count], SECTION_HUD_KILL, szHud)
	
	read_file(szLoadingFile, LINE_WPN_DMG, szText, sizeof szText - 1, iTextLen)
	replace(szText, sizeof szText - 1, "[WPN_DAMAGE]", "")
	TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_WEAPON_DAMAGE, str_to_float(szText))
	
	read_file(szLoadingFile, LINE_WPN_COST, szText, sizeof szText - 1, iTextLen)
	replace(szText, sizeof szText - 1, "[WPN_COST]", "")
	
	new szCost[10], szCostType[10], szAmmoCost[10], szAmmoCostType[10], szLevel[10]
	
	parse(szText, szCost, sizeof szCost - 1, szCostType , sizeof szCostType - 1, szAmmoCost, sizeof szAmmoCost - 1, szAmmoCostType, sizeof szAmmoCostType - 1, szLevel, sizeof szLevel - 1)
	
	TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_WEAPON_COST, str_to_num(szCost))
	TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_WEAPON_COST_TYPE, str_to_num(szCostType))
	TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_WEAPON_LEVEL, str_to_num(szLevel))
	TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_AMMO_COST, str_to_num(szAmmoCost))
	TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_AMMO_COST_TYPE, str_to_num(szAmmoCostType))
	
	/*					MODEL SECTION					*/
	
	new szWeaponModel[250], szSubBody[3]
	read_file(szLoadingFile, LINE_WPN_W_MODEL, szText, sizeof szText - 1, iTextLen)
	replace(szText, sizeof szText - 1, "[W_MODEL]", "")
	parse(szText, szWeaponModel, sizeof szWeaponModel - 1, szSubBody, sizeof szSubBody - 1)
	
	TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_W_SUB, str_to_num(szSubBody))
	TrieSetString(weapon_StringInfo[g_weapon_count], SECTION_W_MODEL, szWeaponModel)
	
	if (!TrieKeyExists(iPrecachedModel, szWeaponModel))
	{
		engfunc(EngFunc_PrecacheModel, szWeaponModel)
		TrieSetCell(iPrecachedModel, szWeaponModel, 1)
	}
	
	// Player Model
	read_file(szLoadingFile, LINE_WPN_P_MODEL, szText, sizeof szText - 1, iTextLen)
	replace(szText, sizeof szText - 1, "[P_MODEL]", "")
	parse(szText, szWeaponModel, sizeof szWeaponModel - 1, szSubBody, sizeof szSubBody - 1)
	TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_P_SUB, str_to_num(szSubBody))
	TrieSetString(weapon_StringInfo[g_weapon_count], SECTION_P_MODEL, szWeaponModel)
	
	if (!TrieKeyExists(iPrecachedModel, szWeaponModel))
	{
		engfunc(EngFunc_PrecacheModel, szWeaponModel)
		TrieSetCell(iPrecachedModel, szWeaponModel, 1)
	}
	
	// View Model
	read_file(szLoadingFile, LINE_WPN_V_MODEL, szText, sizeof szText - 1, iTextLen)
	replace(szText, sizeof szText - 1, "[V_MODEL]", "")
	parse(szText, szWeaponModel, sizeof szWeaponModel - 1, szSubBody, sizeof szSubBody - 1)
	TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_V_SUB, str_to_num(szSubBody))
	TrieSetString(weapon_StringInfo[g_weapon_count], SECTION_V_MODEL, szWeaponModel)
	
	if (!TrieKeyExists(iPrecachedModel, szWeaponModel))
	{
		engfunc(EngFunc_PrecacheModel, szWeaponModel)
		TrieSetCell(iPrecachedModel, szWeaponModel, 1)
	}
	
	if (iWPN_FUNC & FUNC_ADS)
	{
		// Special View Model [Aim Down Sight 2]
		read_file(szLoadingFile, LINE_IRONSIGHT_CONFIG, szText, sizeof szText - 1, iTextLen)
		replace(szText, sizeof szText - 1, "[AdsConfig]", "")
	
		new szViewModel[128], szTimeSight[10], szTimeEndSight[10], szAdsFlag[10], szRof[10], szRecoil[10]
		parse(szText, szViewModel, sizeof szViewModel - 1, szTimeSight, sizeof szTimeSight - 1, szTimeEndSight, sizeof szTimeEndSight - 1, szAdsFlag, sizeof szAdsFlag - 1,
			szRof, sizeof szRof - 1, szRecoil, sizeof szRecoil - 1)
		
		new iFlag = read_flags(szAdsFlag)
		
		
		if (iFlag & ADS_ALTERNATIVE_MODEL)
			TrieSetString(weapon_StringInfo[g_weapon_count], SECTION_ADS_V_MODEL, szViewModel)
		else	TrieSetString(weapon_StringInfo[g_weapon_count], SECTION_ADS_V_MODEL, szWeaponModel)
		
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_TIME_ADS_IN, str_to_float(szTimeSight))
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_TIME_ADS_OUT, str_to_float(szTimeEndSight))
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_ADS_FLAG, iFlag )
		
		if (iFlag & ADS_NEW_ROF)
			TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_ADS_ROF, str_to_float(szRof))
			
		if (iFlag & ADS_NEW_RECOIL)
			TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_ADS_RECOIL, str_to_float(szRecoil))
			
	}
	
	if (iWPN_FUNC & FUNC_GRENADE_LAUNCHER)
	{
		// Special View Model [Aim Down Sight 2]
		read_file(szLoadingFile, LINE_LAUNCHER_CONFIG, szText, sizeof szText - 1, iTextLen)
		replace(szText, sizeof szText - 1, "[LauncherConfig]", "")
		TrieSetString(weapon_StringInfo[g_weapon_count], SECTION_GREN_V_MODEL, szText)
		
		if (!TrieKeyExists(iPrecachedModel, szText))
		{
			engfunc(EngFunc_PrecacheModel, szText)
			TrieSetCell(iPrecachedModel, szText, 1)
		}
		
	}
	
	
	/****************************************************************************************/
	
	
	
	read_file(szLoadingFile, LINE_WPN_WEIGHT, szText, sizeof szText - 1, iTextLen)
	replace(szText, sizeof szText - 1, "[WPN_WEIGHT]", "")
	TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_WEAPON_WEIGHT,  str_to_float(szText))
	
	read_file(szLoadingFile, LINE_WPN_SPEED, szText, sizeof szText - 1, iTextLen)
	replace(szText, sizeof szText - 1, "[WPN_SPEED]", "")
	TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_WEAPON_SPEED_REDUCTION, str_to_float(szText))
	
	read_file(szLoadingFile, LINE_WPN_KNOCKBACK, szText, sizeof szText - 1, iTextLen)
	replace(szText, sizeof szText - 1, "[WPN_KB]", "")
	new szKnockBackPower[32], szKnockBackDistance[10]
	parse(szText, szKnockBackPower, sizeof szKnockBackPower - 1, szKnockBackDistance, sizeof szKnockBackDistance - 1)
	
	new Float:fKnockBackBuffer 
	
	fKnockBackBuffer = str_to_float(szKnockBackPower)
	
	if (fKnockBackBuffer > 0.0)
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_KNOCKBACK_POWER, fKnockBackBuffer)
		
	fKnockBackBuffer = str_to_float(szKnockBackDistance)
	
	if (fKnockBackBuffer > 0.0)
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_KNOCKBACK_RANGE, fKnockBackBuffer)
		
	read_file(szLoadingFile, LINE_WPN_SOUND, szText, sizeof szText - 1, iTextLen)
	replace(szText, sizeof szText - 1, "[WPN_SOUND]", "")
	
	new szShotSound[32], szOtherSound[10]
	parse(szText, szShotSound, sizeof szShotSound - 1, szOtherSound, sizeof szOtherSound - 1)
	
	TrieSetString(weapon_StringInfo[g_weapon_count], SECTION_WEAPON_SOUND, szShotSound)
	
	if (str_to_num(szOtherSound))
	{
		new szFullSound[128]	
		formatex(szFullSound, sizeof szFullSound - 1, "weapons/TFM_WPN/default/%s.wav", szShotSound)
		
		new iSoundId = engfunc(EngFunc_PrecacheSound, szFullSound)
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_FIRE_SOUND_ID, iSoundId)
	}
	else
	{
		new szFullSound[128]
		
		formatex(szFullSound, sizeof szFullSound - 1, "weapons/%s/%s.wav", SOUND_DIRECTORY, szShotSound)
		new iSoundId = engfunc(EngFunc_PrecacheSound, szFullSound)
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_FIRE_SOUND_ID, iSoundId)
	}
	
	
	
	new szExtraSound[256]
	
	formatex(szExtraSound, sizeof szExtraSound - 1, "sound/weapons/%s/%s-burst.wav", SOUND_DIRECTORY, szShotSound)
	
	if (file_exists(szExtraSound))
	{
		formatex(szExtraSound, sizeof szExtraSound - 1, "weapons/%s/%s-burst.wav", SOUND_DIRECTORY, szShotSound)
		new iSoundId = engfunc(EngFunc_PrecacheSound, szExtraSound)
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BURST_SOUND_ID, iSoundId)
	}
	
	
	read_file(szLoadingFile, LINE_WPN_CLASS, szText, sizeof szText - 1, iTextLen)
	new szClass[64], szRegisterCommand[3]
	replace(szText, sizeof szText - 1, "[WPN_CLASS]", "")
	parse(szText, szClass, sizeof szClass - 1, szRegisterCommand, sizeof szRegisterCommand - 1)
	
	if (str_to_num(szRegisterCommand))
		register_clcmd(szText, "fw_ChangeWeapon")
	TrieSetString(weapon_StringInfo[g_weapon_count], SECTION_WEAPON_CLASS, szText)
	
	read_file(szLoadingFile, LINE_WPN_AS_MAP, szText, sizeof szText - 1, iTextLen)
	replace(szText, sizeof szText - 1, "[AS-MAP]", "")
	TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_WPN_EQUIP_METHOD, str_to_num(szText))
	
	read_file(szLoadingFile, LINE_WPN_BACKWPN, szText, sizeof szText - 1, iTextLen)
	replace(szText, sizeof szText - 1, "[BACK_WPN]", "")
	
	new szToggle[3], szBackModel[32]
	parse(szText, szToggle, sizeof szToggle - 1, szSubBody, sizeof szSubBody - 1, szBackModel, sizeof szBackModel - 1)
	
	new iToggle = str_to_num(szToggle)
	if (iToggle)
	{
		TrieSetString(weapon_StringInfo[g_weapon_count], SECTION_BACK_MODEL, szBackModel)
	
		if (!TrieKeyExists(iPrecachedModel, szBackModel))
		{
			engfunc(EngFunc_PrecacheModel, szBackModel)
			TrieSetCell(iPrecachedModel, szBackModel, 1)
		}
		
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BACKWPN_SUB, str_to_num(szSubBody))
	
	}
	else
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BACKWPN_SUB, -1)
	
	if (iWPN_FUNC & FUNC_GRENADE_LAUNCHER)
	{
		new szGrenadeBuffer[256]
		
		/***************************************************************************/
		read_file(szLoadingFile, LINE_GREN_INFO, szText, sizeof szText - 1, iTextLen)
		replace(szText, sizeof szText - 1, "[iGrenadeInfo]", "")
		new szGrenadeType[10], szDmgBit[32], szDamage[10] ,szGrenClip[10], szGrenBpa[10], szSpeed[10], szFlag[32]
		parse(szText, szGrenadeType, sizeof szGrenadeType - 1, szDmgBit, sizeof szDmgBit - 1, 
		szDamage, sizeof szDamage - 1,
		szGrenClip, sizeof szGrenClip -1, 
			szGrenBpa, sizeof szGrenBpa - 1, szSpeed, sizeof szSpeed - 1, szFlag, sizeof szFlag - 1)
		
		new iGrenadeFlag = read_flags(szFlag)
		
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BULLET_GREN_TYPE, str_to_num(szGrenadeType))
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BULLET_DMGBIT, read_flags(szDmgBit))
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_GREN_DMG, str_to_float(szDamage))
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_WEAPON_GRENADE_CLIP, str_to_num(szGrenClip))
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_WEAPON_GRENADE_BPA, str_to_num(szGrenBpa))
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BULLET_FLAG, iGrenadeFlag)
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BULLET_VELOCITY, str_to_num(szSpeed))
		
		/***************************************************************************/
		
		new szGrenDelay[10], szGrenChangeTime[10], szGrenChangeBack[10], szActiveTime[10], szRemoveTime[10], szFallTime[10]
		read_file(szLoadingFile, LINE_GREN_DELAY, szText, sizeof szText - 1, iTextLen)
		replace(szText, sizeof szText - 1, "[iGrenadeDelay]", "")
		parse(szText, szGrenDelay, sizeof szGrenDelay - 1, szGrenChangeTime, sizeof szGrenChangeTime - 1, szGrenChangeBack, sizeof szGrenChangeBack - 1, 
		szActiveTime, sizeof szActiveTime - 1, szRemoveTime, sizeof szRemoveTime - 1,
		szFallTime, sizeof szFallTime - 1)
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_GRENADE_DELAY, str_to_float(szGrenDelay))
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_GRENADE_ACTIVE_TIME,  str_to_float(szGrenChangeTime))
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_GRENADE_DEACTIVE_TIME, str_to_float(szGrenChangeBack))
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BULLET_ACTIVE_TIME, str_to_float(szActiveTime))
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BULLET_REMOVE_TIME, str_to_float(szRemoveTime))
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BULLET_FALL_TIME, str_to_float(szFallTime))
		
		/***************************************************************************/
		
		read_file(szLoadingFile, LINE_GREN_RELOAD_CFG, szText, sizeof szText - 1, iTextLen)
		replace(szText, sizeof szText - 1, "[iGrenadeReloadCfg]", "")
		new szStartInsertTime[10], szInsertTime[10], szAfterInsertTime[10]
		parse(szText, szStartInsertTime, sizeof szStartInsertTime - 1, szInsertTime, sizeof szInsertTime - 1, szAfterInsertTime, sizeof szAfterInsertTime - 1)
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_TIME_GREN_START_REL, str_to_float(szStartInsertTime))
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_TIME_GREN_INS, str_to_float(szInsertTime))
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_TIME_GREN_FIN, str_to_float(szAfterInsertTime))
		
		/***************************************************************************/
			
		new szGrenadeModel[64], szGrenadeSub[3], szGrenadeHud[32], szExpSpr[64], szFramerate[3], szScale[3], szBrightness[3]
		new szExpSound[32]
		
		read_file(szLoadingFile, LINE_GREN_EXP_CFG, szText, sizeof szText - 1, iTextLen)
		replace(szText, sizeof szText - 1, "[iGrenadeExpCfg]", "")
		parse(szText, szGrenadeModel, sizeof szGrenadeModel - 1, szGrenadeSub, sizeof szGrenadeSub - 1, szGrenadeHud, sizeof szGrenadeHud - 1,
			szExpSpr, sizeof szExpSpr - 1, 
			szFramerate, sizeof szFramerate - 1, szScale, sizeof szScale - 1, szBrightness, sizeof szBrightness -1,
			szExpSound, sizeof szExpSound - 1)
		
		//				MODEL AND SUB BODY
		formatex(szGrenadeBuffer, sizeof szGrenadeBuffer - 1, "models/%s.mdl", szGrenadeModel)
		TrieSetString(weapon_StringInfo[g_weapon_count], SECTION_BULLET_GRENADE_MODEL, szGrenadeBuffer)
		if (!TrieKeyExists(iPrecachedModel, szGrenadeBuffer))
		{
			engfunc(EngFunc_PrecacheModel, szGrenadeBuffer)
			TrieSetCell(iPrecachedModel, szGrenadeBuffer, 1)
		}
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BULLET_GRENADE_SUB, str_to_num(szGrenadeSub))
		
		//					HUD
		TrieSetString(weapon_StringInfo[g_weapon_count], SECTION_GRENADE_DEATHMSG, szGrenadeHud)
		
		//				EXPLOSION SPRITE
		
		formatex(szGrenadeBuffer, sizeof szGrenadeBuffer - 1, "sprites/%s.spr", szExpSpr)
		
		if (TrieKeyExists(iPrecachedModel, szGrenadeBuffer))
			TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_SPR_INDEX, engfunc(EngFunc_ModelIndex, szGrenadeBuffer))
		else
		{
			TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_SPR_INDEX, engfunc(EngFunc_PrecacheModel, szGrenadeBuffer))
			TrieSetCell(iPrecachedModel, szGrenadeBuffer, 1)
		}
		
		//				FRAMERATE | SCALE | BRIGHTNESS
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BULLET_SPR_FRAME, str_to_num(szFramerate))
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BULLET_SPR_SCALE, str_to_num(szScale))
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BULLET_SPR_BN, str_to_num(szBrightness))
		
		//					EXP SOUND
		formatex(szGrenadeBuffer, sizeof szGrenadeBuffer - 1, "weapons/%s.wav", szExpSound)
		engfunc(EngFunc_PrecacheSound, szGrenadeBuffer)
		TrieSetString(weapon_StringInfo[g_weapon_count], SECTION_BULLET_SOUND, szGrenadeBuffer)
		
		
		/***************************************************************************/
		
		read_file(szLoadingFile, LINE_GREN_COST, szText, sizeof szText - 1, iTextLen)
		replace(szText, sizeof szText - 1, "[iGrenadeCost]", "")
		
		new szGrenadeCost[10], szGrenadeCostType[10]
		parse(szText, szGrenadeCost , sizeof szGrenadeCost - 1, szGrenadeCostType, sizeof szGrenadeCostType - 1)
		
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_GRENADE_COST, str_to_num(szGrenadeCost))
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_GRENADE_COST_TYPE, str_to_num(szGrenadeCostType))
			
		/***************************************************************************/
		
		read_file(szLoadingFile, LINE_GREN_RECOIL, szText, sizeof szText - 1, iTextLen)
		replace(szText, sizeof szText - 1, "[iGrenadeRecoil]", "")
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_GRENADE_RECOIL, str_to_float(szText))
		
		/***************************************************************************/
		
		if (iGrenadeFlag & TRAIL_ON_MOVE)
		{
			
			read_file(szLoadingFile, LINE_GREN_TRAIL_CFG, szText, sizeof szText - 1, iTextLen)
			replace(szText, sizeof szText - 1, "[iGrenadeTrail]", "")
			new szSprite[64], szRed[10], szGreen[10], szBlue[10], szWidth[10], szBrightness[5], szLife[5]
			parse(szText, szSprite, sizeof szSprite - 1  ,szRed, sizeof szRed - 1, szGreen, sizeof szGreen - 1, szBlue, sizeof szBlue - 1, 
			szWidth, sizeof szWidth - 1,
				szBrightness, sizeof szBrightness - 1, szLife, sizeof szLife - 1)
				
				
			TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BULLET_RED, str_to_num(szRed))
			TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BULLET_GREEN, str_to_num(szGreen))
			TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BULLET_BLUE, str_to_num(szBlue))
			TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BULLET_TW, str_to_num(szWidth))
			TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BULLET_TRBN, str_to_num(szBrightness))
			TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BULLET_TRL, str_to_num(szLife))	
				
			new szSprFullName[256]
			formatex(szSprFullName, sizeof szSprFullName - 1, "sprites/%s.spr", szSprite)
				
			if (TrieKeyExists(iPrecachedModel, szSprFullName))
				TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BULLET_TSPR, engfunc(EngFunc_ModelIndex, szSprFullName))
			else
			{
				TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BULLET_TSPR, engfunc(EngFunc_PrecacheModel, szSprFullName))
				TrieSetCell(iPrecachedModel, szSprFullName, 1)
			}
				
		}
		
		if (iGrenadeFlag & TRAIL_ON_DETONATE)
		{
			read_file(szLoadingFile, LINE_GREN_TRAIL2_CFG, szText, sizeof szText - 1, iTextLen)
			replace(szText, sizeof szText - 1, "[iGrenadeTrail2]", "")
			new szSprite[64], szRed[10], szGreen[10], szBlue[10], szWidth[10], szBrightness[5], szLife[5]
			parse(szText, szSprite, sizeof szSprite - 1  ,szRed, sizeof szRed - 1, szGreen, sizeof szGreen - 1, szBlue, sizeof szBlue - 1, 
			szWidth, sizeof szWidth - 1,
				szBrightness, sizeof szBrightness - 1, szLife, sizeof szLife - 1)
				
				
			TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BULLET_RED_2, str_to_num(szRed))
			TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BULLET_GREEN_2, str_to_num(szGreen))
			TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BULLET_BLUE_2, str_to_num(szBlue))
			TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BULLET_TW_2, str_to_num(szWidth))
			TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BULLET_TRBN_2, str_to_num(szBrightness))
			TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BULLET_TRL_2, str_to_num(szLife))	
				
			new szSprFullName[256]
			formatex(szSprFullName, sizeof szSprFullName - 1, "sprites/%s.spr", szSprite)
				
			if (TrieKeyExists(iPrecachedModel, szSprFullName))
				TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BULLET_TSPR_2, engfunc(EngFunc_ModelIndex, szSprFullName))
			else
			{
				TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_BULLET_TSPR_2, engfunc(EngFunc_PrecacheModel, szSprFullName))
				TrieSetCell(iPrecachedModel, szSprFullName, 1)
			}
		}
		
		/***************************************************************************/
	}
	
	
	
	read_file(szLoadingFile, LINE_THERMAL_TG, szText, sizeof szText - 1, iTextLen)
	replace(szText, sizeof szText - 1, "[iThermal]", "")
	new iThermalFlag = read_flags(szText)
	
	if (iThermalFlag & THERMAL_ON)
	{
		if ((iThermalFlag & THERMAL_NVG_SCREEN) || (iThermalFlag & THERMAL_NVG_LIGHT))
		{
			new fArg[10], sArg[10], tArg[10]
			
			read_file(szLoadingFile, LINE_THERMAL_COLOR, szText, sizeof szText - 1, iTextLen)
			replace(szText, sizeof szText - 1, "[iThermalColor]", "")	
			parse(szText, fArg, sizeof fArg - 1, sArg, sizeof sArg - 1, tArg, sizeof tArg - 1)
			
			new iBuffer
			
			iBuffer = str_to_num(fArg)
			if (iBuffer)
				set_trie_int(weapon_StringInfo[g_weapon_count], SECTION_THERMAL_RED, iBuffer)
			
			iBuffer = str_to_num(sArg)
			if (iBuffer)
				set_trie_int(weapon_StringInfo[g_weapon_count], SECTION_THERMAL_GREEN, iBuffer)
				
			iBuffer = str_to_num(tArg)
			if (iBuffer)
				set_trie_int(weapon_StringInfo[g_weapon_count], SECTION_THERMAL_BLUE, iBuffer)
		}
		if (iThermalFlag & THERMAL_NVG_LIGHT)
		{
			read_file(szLoadingFile, LINE_THERMAL_RADIUS, szText, sizeof szText - 1, iTextLen)
			replace(szText, sizeof szText - 1, "[iThermalRadius]", "")	
			TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_THERMAL_RADIUS, str_to_num(szText))
		}
		
		read_file(szLoadingFile, LINE_THERMAL_ALPHA, szText, sizeof szText - 1, iTextLen)
		replace(szText, sizeof szText - 1, "[iThermalAlpha]", "")	
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_THERMAL_ALPHA, str_to_num(szText))
		
		if (!iFM_AddToFullPack)
			iFM_AddToFullPack = register_forward(FM_AddToFullPack, "fw_AddToFullPack", 1)
		
		TrieSetCell(weapon_StringInfo[g_weapon_count], SECTION_THERMAL_FLAG, iThermalFlag)
	}
	
		
	
	
	read_file(szLoadingFile, LINE_MOD_EXTENDED_CLIP, szText, sizeof szText - 1, iTextLen)
	replace(szText, sizeof szText - 1, "[MOD_EXTENDED_CLIP]", "")
	TrieSetCell(weapon_StringInfo[g_weapon_count], MOD_EXTENDED_CLIP, str_to_num(szText))
	
	new szInfo[10]
	formatex(szInfo, sizeof szInfo - 1, "%d", g_weapon_count)
	
	new szWeaponName[64]
	TrieGetString(weapon_StringInfo[g_weapon_count], SECTION_WPN_NAME, szWeaponName, sizeof szWeaponName - 1)
	
	menu_additem(iArmouryMenuId, szWeaponName, szInfo, ADMIN_ALL, -1)
	
	new szSpawnFile[256]
	formatex(szSpawnFile, sizeof szSpawnFile - 1, "%s/%s/%s/%s.cfg", szCfgDir, WPN_SPAWN_DIR, szMapName, szFileName)
	
	TrieSetCell(iLoadedFile, szFileName, 1)
	TrieSetString(weapon_StringInfo[g_weapon_count], SECTION_SPAWN_FILE, szSpawnFile)
	
	if (file_exists(szSpawnFile))
	{
		new Data[124]
		
		new len
		
			
		for (new iSpawnLine = 0; iSpawnLine < file_size(szSpawnFile, 1); iSpawnLine++)
		{
			if (iTotalSpawnPoint > MAX_SPAWN_POINT -1 )
				continue
				
			new fArg[10], sArg[10], tArg[10]
			read_file(szSpawnFile, iSpawnLine, Data, sizeof Data - 1, len)
			
			if (strlen(Data)<2) continue;
			
			parse(Data, fArg, sizeof fArg - 1, sArg, sizeof sArg - 1, tArg, sizeof tArg - 1)
			// Origin
			fSpawnVecs[iTotalSpawnPoint][0] = str_to_float(fArg);
			fSpawnVecs[iTotalSpawnPoint][1] = str_to_float(sArg);
			fSpawnVecs[iTotalSpawnPoint][2] = str_to_float(tArg);
			iSpawnWeaponId[iTotalSpawnPoint] = g_weapon_count
			
			iTotalSpawnPoint++
		}
	}
	
	new iLoadedId = g_weapon_count
	
	g_weapon_count++
	
	ExecuteForward(ifw_WpnLoadedSucccessful, ifw_Result, iLoadedId)
	
}


public plugin_precache()
{
	register_dictionary("TFM_Dictionary.txt")
	ForwardRegister()
}

public plugin_init() 
{
	
	#define PLUGIN "[WPN MOD] PRIMARY WEAPONS"
	#define VERSION "-[No Info]-"
	#define AUTHOR  "Nguyen Duy Linh"

	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	
	
	iDecal = engfunc(EngFunc_DecalIndex, "{shot2")

	
	for (new i = 0; i < max_wpn; i++)
	{
		weapon_StringInfo[i] = TrieCreate()
		iBulletConfig[i] = TrieCreate()
	}
	
	if (!iThermalClass)
		iThermalClass = TrieCreate()
	
	if (!iThermalModel)
		iThermalModel = TrieCreate()
	
	if (!iLoadedFile)
		iLoadedFile = TrieCreate()
	
	if (!iWeaponBoxInfo)
		iWeaponBoxInfo = TrieCreate()
		
	new szThermalClass[][] = {"hostage_entity", "monster_scientist", "light", "light_spot", "env_glow"}
	
	for (new i = 0; i < sizeof szThermalClass; i++)
		TrieSetCell(iThermalClass, szThermalClass[i], 1)
		
	new szConfigDir[128], szThermalConfigFile[256]
	get_configsdir(szConfigDir, sizeof szConfigDir - 1)
	
	formatex(szThermalConfigFile, sizeof szThermalConfigFile - 1, "%s/ThermalModel.redplane", szConfigDir)
	
	if (file_exists(szThermalConfigFile))
	{
		for (new i = 0; i < file_size(szThermalConfigFile, 1) ; i++)
		{
			new TXT[32], iTRASH
			read_file(szThermalConfigFile, i, TXT, sizeof TXT - 1, iTRASH)
			
			if (TrieKeyExists(iThermalModel, TXT))
				continue
				
			TrieSetCell(iThermalModel, TXT, 1)
		}
	}
	
	
	
	iMsgScreenFade = get_user_msgid("ScreenFade")
	iMSGID_DeathMSG = get_user_msgid("DeathMsg")
	
	register_concmd(PRIM_ARMOURY_CMD, "concmd_OpenArmouryMenu", ADMIN_ALL)
	
	register_clcmd("nightvision", "fw_NightVisionToggle")
	register_clcmd(THERMAL_COMMAND, "fw_ThermalToggle")
	register_clcmd(LASER_COMMAND, "fw_LaserToggle")
	register_clcmd(SELECTIVE_FIRE_COMMAND, "fw_SelectiveFireToggle")
	
	//register_event("CurWeapon", "Event_CurWeapon", "b", "1=1")
	register_logevent("round_begin" , 2 , "1=Round_Start")
	
	
	register_touch("weaponbox", "player", "fw_WeaponBoxTouch")
	register_touch(GRENADE_CLASS, "*", "fw_GrenadeTouchesWorld")
	register_touch("armoury_entity", "player", "fw_ArmouryTouch")
	
	register_think(GRENADE_CLASS,"fw_GrenadeThink")
	
	register_message(iMSGID_DeathMSG, "fw_DeathMSG")
	register_message(get_user_msgid("WeapPickup"),"message_weappickup")
		
	iMaxPlayers = get_maxplayers()
	
	
	register_forward(FM_CmdStart, "fw_CmdStart")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
	register_forward(FM_TraceLine, "fw_OnTraceLine")
	register_forward(FM_SetModel, "fw_SetModelPost", 1)
	
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	RegisterHam(Ham_TakeDamage, "hostage_entity", "fw_TakeDamage")
	RegisterHam(Ham_TakeDamage, "monster_scientist", "fw_TakeDamage")
	RegisterHam(Ham_TakeDamage, "func_breakable", "fw_TakeDamage")
	RegisterHam(Ham_TakeDamage, "func_pushable", "fw_TakeDamage")
	
	RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack")
	RegisterHam(Ham_TraceAttack, "hostage_entity", "fw_TraceAttack")
	RegisterHam(Ham_TraceAttack, "monster_scientist", "fw_TraceAttack")
	RegisterHam(Ham_TraceAttack, "func_breakable", "fw_TraceAttack")
	RegisterHam(Ham_TraceAttack, "func_pushable", "fw_TraceAttack")
	
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled", 1)
	
	
	new szMapName[32]
	
	
	get_mapname(szMapName, sizeof szMapName - 1)
	get_configsdir(szConfigDir, sizeof szConfigDir - 1)
	
	iArmouryMenuId = menu_create("[TFM WPN] Weapon spawn list", "fw_ArmouryMenuSelected", -1)
	
	new szManagerFile[256]
	bHamCZ = false
	
	g_LoadType = TYPE_FULL
	
	ExecuteForward(ifw_StartLoadData, ifw_Result)
	
	formatex(szManagerFile, sizeof szManagerFile - 1, "%s/%s/%s.cfg", szConfigDir, WPN_SPEC_DIR, szConfigDir)
	
	new iFileExist = file_exists(szManagerFile)
		
	if (iFileExist)
	{
		for (new i = 0; i < file_size(szManagerFile, 1); i++)
		{
			new szInfo[64], iTextLen
	
			read_file(szManagerFile, i, szInfo, sizeof szInfo - 1, iTextLen)
			
			load_primary_wpn_file(WPN_CONFIG_DIR, szInfo, "ini", 1)
			
		}
	}
	else
	{
		formatex(szManagerFile, sizeof szManagerFile - 1, "%s/%s/%s", szConfigDir, WPN_MANAGER_DIR, WPN_MANAGER_FILE)
		
		for (new i = 0; i < file_size(szManagerFile, 1); i++)
		{
			new szInfo[64], iTextLen
			read_file(szManagerFile, i, szInfo, sizeof szInfo - 1, iTextLen)
			load_primary_wpn_file(WPN_CONFIG_DIR, szInfo, "ini", 0)
			
		}
	}
	
	formatex(szManagerFile, sizeof szManagerFile - 1, "%s/%s/%s.cfg", szConfigDir, WPN_ADD_DIR, szMapName)
	if (file_exists(szManagerFile))
	{
		for (new i = 0; i < file_size(szManagerFile, 1); i++)
		{
			new szInfo[64], iTextLen
			read_file(szManagerFile, i, szInfo, sizeof szInfo - 1, iTextLen)
			
			load_primary_wpn_file(WPN_CONFIG_DIR, szInfo, "redplane", 1)
		}
	}
	
	laser = engfunc(EngFunc_PrecacheModel, "sprites/ledglow.spr")
		
}


public client_putinserver(id)
{
	set_task(0.1, "RegisterBotFunction_TASK", id + TASK_REGISTER_CZ_FUNCTION)
	
	if (!iPlayerInfo[id])
		iPlayerInfo[id] = TrieCreate()
	
	/*
	
	if (!is_user_bot(id))
	{
		
		new szCommand[32]
		
		
		formatex(szCommand, sizeof szCommand - 1, "bind 'F1' '%s'", THERMAL_COMMAND)
		client_cmd(id, szCommand)
		
		formatex(szCommand, sizeof szCommand - 1, "bind 'F2' '%s'", LASER_COMMAND)
		client_cmd(id, szCommand)
		
		formatex(szCommand, sizeof szCommand - 1, "bind 'F3' '%s'", SELECTIVE_FIRE_COMMAND)
		client_cmd(id, szCommand)
		
		formatex(szCommand, sizeof szCommand - 1, "bind 'F4' '%s'", DOUBLE_WEAPON_COMMAND)
		client_cmd(id, szCommand)
	}
	*/
}
	
public client_connect(id)
{
	native_set_user_primary_id(id, -1);
	if (CheckPlayerBit(g_LauncherModeActivated, id))	
		ClearPlayerBit(g_LauncherModeActivated, id);
	
	if (CheckPlayerBit(g_ReloadingGrenadeLauncher, id))	
		ClearPlayerBit(g_ReloadingGrenadeLauncher, id);
	
	ClearPlayerBit(b_KilledByExplosion, id);
	
	if (iPlayerInfo[id])
		TrieDestroy(iPlayerInfo[id])
}

public RegisterBotFunction_TASK(TASKID)
{
	new id = TASKID - TASK_REGISTER_CZ_FUNCTION
	
	if (bHamCZ)
		return
		
	if (!is_user_bot(id))
		return
		
	if (!get_cvar_num("bot_quota"))
		return
		
	RegisterHamFromEntity(Ham_TakeDamage, id, "fw_TakeDamage")
	RegisterHamFromEntity(Ham_Killed, id, "fw_PlayerKilled", 1)
		
	bHamCZ = true
	
}

public concmd_OpenArmouryMenu(id)
{
	if (!is_user_alive(id))
		return
		
	menu_display(id, iArmouryMenuId, 0)
}

public fw_ArmouryMenuSelected(id, iMenuId, iItemId)
{
	if (!is_user_alive(id))
		return
		
	if (iItemId == MENU_EXIT)
		return
	
	if (iTotalSpawnPoint > MAX_SPAWN_POINT - 1)
		return
		
	new szItemName[32], szInfo[3], iCALL_BACK, iACCESS_TYPE
	menu_item_getinfo(iMenuId, iItemId, iACCESS_TYPE, szInfo, sizeof szInfo - 1, szItemName, sizeof szItemName - 1, iCALL_BACK)
	
	new iWeaponId = str_to_num(szInfo)
	
	new szCfgDir[128], szMapName[32]
	
	get_mapname(szMapName, sizeof szMapName - 1)
	get_configsdir(szCfgDir, sizeof szCfgDir - 1)
	
	new szWeaponDirectory[256]
	formatex(szWeaponDirectory, sizeof szWeaponDirectory - 1, "%s/%s/%s", szCfgDir, WPN_SPAWN_DIR, szMapName)
	
	if (!dir_exists(szWeaponDirectory))
		mkdir(szWeaponDirectory)
		
	new iOrigin[3]
	get_user_origin(id, iOrigin, 0)
	
	new line[128]
	format(line, 127, "%d %d %d", iOrigin[0] ,iOrigin[1], iOrigin[2])
	
	new szSpawnFile[256]
	
	TrieGetString(weapon_StringInfo[iWeaponId], SECTION_SPAWN_FILE, szSpawnFile, sizeof szSpawnFile - 1)
	
	write_file(szSpawnFile, line, -1)
	
	IVecFVec(iOrigin, fSpawnVecs[iTotalSpawnPoint])
	
	menu_display(id, iMenuId, 0)
	iSpawnWeaponId[iTotalSpawnPoint] = iWeaponId
	iTotalSpawnPoint++
}

public fw_NightVisionToggle(id)
{
	if (!is_user_alive(id))
		return PLUGIN_CONTINUE
		
	new iPrimaryWpnId = native_get_user_primary_id(id)
	
	if (!native_is_valid_pw(iPrimaryWpnId))
		return PLUGIN_CONTINUE
	
	new iWPN_ID = native_get_primary_real_id(iPrimaryWpnId)
	
	if (get_user_weapon(id) != iWPN_ID)
		return PLUGIN_CONTINUE
		
	new iZoomType = cs_get_user_zoom(id)
		
	if (!native_is_primary_wpn_ads(id) && !(0 < UT_GetPlayerFOV(id) < 90) && iZoomType != CS_SET_AUGSG552_ZOOM && iZoomType != CS_SET_FIRST_ZOOM && iZoomType != CS_SET_SECOND_ZOOM)
		return PLUGIN_CONTINUE
		
	if (!TrieKeyExists(weapon_StringInfo[iPrimaryWpnId], SECTION_THERMAL_FLAG))
		return PLUGIN_CONTINUE
		
	new iThermalFlag
	TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_THERMAL_FLAG, iThermalFlag)
	
	if (!(iThermalFlag & THERMAL_ON))
		return PLUGIN_CONTINUE
		
	if (!CheckPlayerBit(g_TurnOnThermal, id))
		return PLUGIN_CONTINUE
		
	return PLUGIN_HANDLED
}
	
public fw_ThermalToggle(id)
{
	if (!is_user_alive(id))
		return 
		
	new iPrimaryWpnId = native_get_user_primary_id(id)
	
	if (!native_is_valid_pw(iPrimaryWpnId))
		return
		
	new iWPN_ID = native_get_primary_real_id(iPrimaryWpnId)
	
	if (get_user_weapon(id) != iWPN_ID)
		return
	
	if (fm_get_next_attack(id) > 0.0)
		return
		
	if (!TrieKeyExists(weapon_StringInfo[iPrimaryWpnId], SECTION_THERMAL_FLAG))
		return
	
	new iThermalFlag 
	TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_THERMAL_FLAG, iThermalFlag)
	
	if (!(iThermalFlag & THERMAL_ON))
		return
		
	if (!CheckPlayerBit(g_TurnOnThermal, id))
	{
		
		new iZoomType = cs_get_user_zoom(id)
		
		if (native_is_primary_wpn_ads(id) || (0 < UT_GetPlayerFOV(id) < 90) || iZoomType == CS_SET_AUGSG552_ZOOM || iZoomType == CS_SET_FIRST_ZOOM || iZoomType == CS_SET_SECOND_ZOOM)
			SetTaskShowNVG(id)
		else	return
		
		SetPlayerBit(g_TurnOnThermal, id)
		fm_set_next_attack(id, 0.75)
		client_print(id, print_center, "%L", id, "TURN_ON_THERMAL")
							
	}
	else
	{
		remove_task(id + TASK_SHOW_FAKE_NVG)
		fm_set_next_attack(id, 0.75)
		if (CheckPlayerBit(g_TurnOnThermal, id))	
			ClearPlayerBit(g_TurnOnThermal, id)
		
		client_print(id, print_center, "%L", id, "TURN_OFF_THERMAL")
						
	}
}

public fw_LaserToggle(id)
{
	if (!is_user_alive(id))
		return
		
	new iPrimaryWpnId = native_get_user_primary_id(id)
	
	if (!native_is_valid_pw(iPrimaryWpnId))
		return
		
	new iWeaponFunc
	TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BASIC_SETTING, iWeaponFunc)
	
	if (!(iWeaponFunc & FUNC_LASER_SIGHT))
		return
		
	new iWPN_ID = native_get_primary_real_id(iPrimaryWpnId)
	
	if (get_user_weapon(id) != iWPN_ID)
		return
		
	if (fm_get_next_attack(id) > 0.0)
		return
		
	if (!CheckPlayerBit(g_LaserSightON, id))
	{
		remove_task(id + TASK_SHOW_LASER)
		SetPlayerBit(g_LaserSightON, id)
		set_task(LASER_DRAW_TIME, "ShowLaser_TASK", id + TASK_SHOW_LASER, _, _, "b")
	}
	else 
		if (CheckPlayerBit(g_LaserSightON, id))	ClearPlayerBit(g_LaserSightON, id)
	
	fm_set_next_attack(id, ZOOM_DELAYED)
}

public fw_SelectiveFireToggle(id)
{
	if (!is_user_alive(id))
		return
	
	new iPrimaryWpnId = native_get_user_primary_id(id)
	
	if (!native_is_valid_pw(iPrimaryWpnId))
	{
		new iWeaponId = get_user_weapon(id)
		
		if (is_primary_wpn(iWeaponId))
		{	
			if (!UT_Get_CS_SemiWpn(iWeaponId))
			{
				new iEnt = fm_get_active_item(id)
			
				if (!pev_valid(iEnt))
					return
				
				
				fm_set_next_attack(id, 0.35)
			}
		}
		return
	}
	new iWPN_ID = native_get_primary_real_id(iPrimaryWpnId)
	
	if (get_user_weapon(id) != iWPN_ID)
		return
	
	if (fm_get_next_attack(id) > 0.0)
		return
		
	new iEnt = fm_get_active_item(id)

	if (!pev_valid(iEnt))
		return
		
	new iOriginalFireMode, iAlterFireMode
	
	TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_ORIGIN_FIREMODE, iOriginalFireMode)
	TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_ALTER_FIREMODE, iAlterFireMode)
	
		
	if (iAlterFireMode == FIRE_AUTO_SEMI)
	{
		if (iOriginalFireMode == FIRE_SEMI)
			return
			
		if (!CheckPlayerBit(g_SemiAutomaticMode, id))
		{
			SetPlayerBit(g_SemiAutomaticMode, id);
			if (CheckPlayerBit(g_SpecialBurstMode, id))	ClearPlayerBit(g_SpecialBurstMode, id);
			if (CheckPlayerBit(g_SpecialBurstFamas, id))	ClearPlayerBit(g_SpecialBurstFamas, id);
			
			client_print(id, print_center, "%L", id, "CHANGED_TO_ONESHOT_MODE")
		}
		else
		{
			if (CheckPlayerBit(g_SemiAutomaticMode, id))	ClearPlayerBit(g_SemiAutomaticMode, id);
			
			if (iOriginalFireMode == FIRE_BURST)
			{
				UT_set_weapon_burst(iEnt, 0)
				if (!CheckPlayerBit(g_SpecialBurstMode, id))	SetPlayerBit(g_SpecialBurstMode, id);
				if (CheckPlayerBit(g_SpecialBurstFamas, id))	ClearPlayerBit(g_SpecialBurstFamas, id);
				
				client_print(id, print_center, "%L", id, "CHANGED_TO_BURST_MODE")
			}
			else if (iOriginalFireMode == FIRE_BURST_FAMAS)
			{
				UT_set_weapon_burst(iEnt, 0)
				if (CheckPlayerBit(g_SpecialBurstMode, id))	ClearPlayerBit(g_SpecialBurstMode, id);
				if (!CheckPlayerBit(g_SpecialBurstFamas, id))	SetPlayerBit(g_SpecialBurstFamas, id);
				
				client_print(id, print_center, "%L", id, "CHANGED_TO_BURST_FAMAS_MODE")
			}
			else
			{
				
				if (CheckPlayerBit(g_SpecialBurstMode, id))	ClearPlayerBit(g_SpecialBurstMode, id);
				if (CheckPlayerBit(g_SpecialBurstFamas, id))	ClearPlayerBit(g_SpecialBurstFamas, id);
				
				client_print(id, print_center, "%L", id, "CHANGED_TO_AUTO_MODE")
			}
		}
		
		
		
		new Float:fTimeChangeFm
		TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_TIME_FM_CHANGE, fTimeChangeFm)
		fm_set_next_attack(id, fTimeChangeFm)		
				
	}
	else if (iAlterFireMode == FIRE_AUTO_BURST)
	{				
		if (iOriginalFireMode == FIRE_BURST)
			return
			
		if (!CheckPlayerBit(g_SpecialBurstMode, id))
		{
			UT_set_weapon_burst(iEnt, 0)
			if (CheckPlayerBit(g_SemiAutomaticMode, id))	ClearPlayerBit(g_SemiAutomaticMode, id);
			if (CheckPlayerBit(g_SpecialBurstFamas, id))	ClearPlayerBit(g_SpecialBurstFamas, id);
			if (!CheckPlayerBit(g_SpecialBurstMode, id))	SetPlayerBit(g_SpecialBurstMode, id)
			client_print(id, print_center, "%L", id, "CHANGED_TO_BURST_MODE")
		}
		else
		{
			
			if (CheckPlayerBit(g_SpecialBurstMode, id))	ClearPlayerBit(g_SpecialBurstMode, id)
			
			if (iOriginalFireMode == FIRE_SEMI)
			{
				if (!CheckPlayerBit(g_SemiAutomaticMode, id))	SetPlayerBit(g_SemiAutomaticMode, id);
				if (CheckPlayerBit(g_SpecialBurstFamas, id))	ClearPlayerBit(g_SpecialBurstFamas, id);
				client_print(id, print_center, "%L", id, "CHANGED_TO_ONESHOT_MODE")
			}
			else if (iOriginalFireMode == FIRE_BURST_FAMAS)
			{
				UT_set_weapon_burst(iEnt, 0)
				if (!CheckPlayerBit(g_SpecialBurstFamas, id))	SetPlayerBit(g_SpecialBurstFamas, id);
				if (CheckPlayerBit(g_SemiAutomaticMode, id))	ClearPlayerBit(g_SemiAutomaticMode, id);
				client_print(id, print_center, "%L",  id, "CHANGED_TO_BURST_FAMAS_MODE")
			}
			else
			{
				if (CheckPlayerBit(g_SemiAutomaticMode, id))	ClearPlayerBit(g_SemiAutomaticMode, id);
				if (CheckPlayerBit(g_SpecialBurstFamas, id))	ClearPlayerBit(g_SpecialBurstFamas, id);
				
				client_print(id, print_center, "%L", id, "CHANGED_TO_AUTO_MODE")
			}
		}
								
		new Float:fTimeChangeFm
		TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_TIME_FM_CHANGE, fTimeChangeFm)
		fm_set_next_attack(id, fTimeChangeFm)
	}
	else if (iAlterFireMode == FIRE_AUTO_FAMAS)
	{
		if (iOriginalFireMode == FIRE_BURST_FAMAS)
			return
			
		if (!CheckPlayerBit(g_SpecialBurstFamas, id))
		{
			UT_set_weapon_burst(iEnt, 0)
			if (CheckPlayerBit(g_SemiAutomaticMode, id))	
				ClearPlayerBit(g_SemiAutomaticMode, id);
			if (!CheckPlayerBit(g_SpecialBurstFamas, id))	
				SetPlayerBit(g_SpecialBurstFamas, id);
			if (CheckPlayerBit(g_SpecialBurstMode, id))	
				ClearPlayerBit(g_SpecialBurstMode, id)
			
			client_print(id, print_center, "%L", id, "CHANGED_TO_BURST_FAMAS_MODE")
		}
		else
		{
			
			if (CheckPlayerBit(g_SpecialBurstFamas, id))	ClearPlayerBit(g_SpecialBurstFamas, id)
			
			if (iOriginalFireMode == FIRE_SEMI)
			{
				if (!CheckPlayerBit(g_SemiAutomaticMode, id))	
					SetPlayerBit(g_SemiAutomaticMode, id);
					
				if (CheckPlayerBit(g_SpecialBurstMode, id))	
					ClearPlayerBit(g_SpecialBurstMode, id);
					
				client_print(id, print_center, "%L", id, "CHANGED_TO_ONESHOT_MODE")
			}
			else if (iOriginalFireMode == FIRE_BURST)
			{
				UT_set_weapon_burst(iEnt, 0)
				if (CheckPlayerBit(g_SpecialBurstMode, id))	ClearPlayerBit(g_SpecialBurstMode, id);
				if (CheckPlayerBit(g_SemiAutomaticMode, id))	ClearPlayerBit(g_SemiAutomaticMode, id);
				client_print(id, print_center, "%L",  id, "CHANGED_TO_BURST_MODE")
			}
			else
			{
				if (CheckPlayerBit(g_SemiAutomaticMode, id))	ClearPlayerBit(g_SemiAutomaticMode, id);
				if (CheckPlayerBit(g_SpecialBurstMode, id))	ClearPlayerBit(g_SpecialBurstMode, id);
				
				client_print(id, print_center, "%L", id, "CHANGED_TO_AUTO_MODE")
			}
		}
		new Float:fTimeChangeFm
		TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_TIME_FM_CHANGE, fTimeChangeFm)
		fm_set_next_attack(id, fTimeChangeFm)
	}
	else if (iAlterFireMode == FIRE_AUTO_SEMI_BURST)
	{
		if (!CheckPlayerBit(g_SemiAutomaticMode, id) && !CheckPlayerBit(g_SpecialBurstMode,id))
		{
			if (!CheckPlayerBit(g_SemiAutomaticMode, id))	SetPlayerBit(g_SemiAutomaticMode, id);
			if (CheckPlayerBit(g_SpecialBurstMode, id))	ClearPlayerBit(g_SpecialBurstMode, id);
			if (CheckPlayerBit(g_SpecialBurstFamas, id))	ClearPlayerBit(g_SpecialBurstFamas, id);
			client_print(id, print_center, "%L", id, "CHANGED_TO_ONESHOT_MODE")
		}
		else if (CheckPlayerBit(g_SemiAutomaticMode, id) && !CheckPlayerBit(g_SpecialBurstMode, id))
		{
			UT_set_weapon_burst(iEnt, 0)
			if (CheckPlayerBit(g_SemiAutomaticMode, id))	ClearPlayerBit(g_SemiAutomaticMode, id);
			if (!CheckPlayerBit(g_SpecialBurstMode, id))	SetPlayerBit(g_SpecialBurstMode, id);
			if (CheckPlayerBit(g_SpecialBurstFamas, id))	ClearPlayerBit(g_SpecialBurstFamas, id);
			
			client_print(id, print_center, "%L", id, "CHANGED_TO_BURST_MODE")
		}
		else if (CheckPlayerBit(g_SpecialBurstMode, id) && !CheckPlayerBit(g_SemiAutomaticMode, id))
		{
			if (CheckPlayerBit(g_SemiAutomaticMode, id))	ClearPlayerBit(g_SemiAutomaticMode, id);
			if (CheckPlayerBit(g_SpecialBurstMode, id))	ClearPlayerBit(g_SpecialBurstMode, id);
			if (CheckPlayerBit(g_SpecialBurstFamas, id))	ClearPlayerBit(g_SpecialBurstFamas, id);
			client_print(id, print_center, "%L", id, "CHANGED_TO_AUTO_MODE")
		}
		new Float:fTimeChangeFm
		TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_TIME_FM_CHANGE, fTimeChangeFm)
		fm_set_next_attack(id, fTimeChangeFm)
	}
	else if (iAlterFireMode == FIRE_AUTO_SEMI_BURST_FAMAS)
	{
		if (!CheckPlayerBit(g_SemiAutomaticMode, id) && !CheckPlayerBit(g_SpecialBurstFamas,id))
		{
			if (!CheckPlayerBit(g_SemiAutomaticMode, id))	SetPlayerBit(g_SemiAutomaticMode, id);
			if (CheckPlayerBit(g_SpecialBurstMode, id))	ClearPlayerBit(g_SpecialBurstMode, id);
			if (CheckPlayerBit(g_SpecialBurstFamas, id))	ClearPlayerBit(g_SpecialBurstFamas, id);
			client_print(id, print_center, "%L", id, "CHANGED_TO_ONESHOT_MODE")
		}
		else if (CheckPlayerBit(g_SemiAutomaticMode, id) && !CheckPlayerBit(g_SpecialBurstFamas, id))
		{
			UT_set_weapon_burst(iEnt, 0)
			if (CheckPlayerBit(g_SemiAutomaticMode, id))	ClearPlayerBit(g_SemiAutomaticMode, id);
			if (CheckPlayerBit(g_SpecialBurstMode, id))	ClearPlayerBit(g_SpecialBurstMode, id);
			if (!CheckPlayerBit(g_SpecialBurstFamas, id))	SetPlayerBit(g_SpecialBurstFamas, id);
			client_print(id, print_center, "%L", id, "CHANGED_TO_BURST_FAMAS_MODE")
		}
		else if (CheckPlayerBit(g_SpecialBurstFamas, id) && !CheckPlayerBit(g_SemiAutomaticMode, id))
		{
			if (CheckPlayerBit(g_SemiAutomaticMode, id))	ClearPlayerBit(g_SemiAutomaticMode, id);
			if (CheckPlayerBit(g_SpecialBurstMode, id))	ClearPlayerBit(g_SpecialBurstMode, id);
			if (CheckPlayerBit(g_SpecialBurstFamas, id))	ClearPlayerBit(g_SpecialBurstFamas, id);
			client_print(id, print_center, "%L", id, "CHANGED_TO_AUTO_MODE")
		}
		new Float:fTimeChangeFm
		TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_TIME_FM_CHANGE, fTimeChangeFm)
		fm_set_next_attack(id, fTimeChangeFm)
	}
}


public fw_ChangeWeapon(id)
{
	if (!is_user_alive(id))
		return
		
	new iPrimaryWpnId = native_get_user_primary_id(id)
	
	if (!native_is_valid_pw(iPrimaryWpnId))
		return
		
	new iWPN_ID = native_get_primary_real_id(iPrimaryWpnId)
	
	new szWeaponName[32]
	get_weaponname(iWPN_ID, szWeaponName, sizeof szWeaponName - 1)
	client_cmd(id, szWeaponName)
	return
}

public round_begin()
{
	
	for (new i = 0; i < iTotalSpawnPoint; i++)
	{
		new Float:fOrigin[3]
		
		CreateArmoury(i, -1, fOrigin)
	}
	
}

public fw_SetModelPost(iEnt, szModel[])
{
	if (!pev_valid(iEnt))
		return 
		
	new id = pev(iEnt, pev_owner)
	
	if (!is_user_connected(id))
		return
	
	new iWeaponId = UT_WorldModelToWeaponId(szModel)
	
	if (!is_primary_wpn(iWeaponId))
		return
		
	new szClassName[32]
	pev(iEnt, pev_classname, szClassName, sizeof szClassName - 1)
	
	new iPrimaryWpnId = native_get_user_primary_id(id)
	
	if (!equal(szClassName, "weaponbox"))
	{
		return
	}
	
	new iClip, iAmmo
	get_user_ammo(id, iWeaponId, iClip, iAmmo)
			
	
	
	if (iPrimaryWpnId > -1)
	{
		iWeaponId = native_get_primary_real_id(iPrimaryWpnId)
			
		new iWPNBOX_FLAG
		
		if (CheckPlayerBit(g_TurnOnThermal, id))
		{
			if (CheckPlayerBit(g_TurnOnThermal, id))	
				ClearPlayerBit(g_TurnOnThermal, id);
			
			iWPNBOX_FLAG &= BFUNC_THERMAL_ON
			
		}
		
			
		
		
		set_pev(iEnt, pev_iuser2, iAmmo)
		set_pev(iEnt, pev_iuser3, iPrimaryWpnId)
		set_pev(iEnt, pev_iuser4, WpnBoxPrimaryWait)
			
		delete_trie_key(iPlayerInfo[id], SECTION_USER_WPN_FLAG)
		
		set_pev(iEnt, pev_solid, SOLID_TRIGGER)
			
		
		new szModelBuffer[256], iSubBody
		
		TrieGetString(weapon_StringInfo[iPrimaryWpnId], SECTION_W_MODEL, szModelBuffer, sizeof szModelBuffer - 1)
		TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_W_SUB, iSubBody)
		
		engfunc(EngFunc_SetModel, iEnt, szModelBuffer)
		set_pev(iEnt, pev_body, iSubBody)
		
		
		UT_SetUserBPA(id, iWeaponId, 0)
					
		if (CheckPlayerBit(g_SemiAutomaticMode, id))
		{
			if (!(iWPNBOX_FLAG & BFUNC_SEMI_ON))
				iWPNBOX_FLAG &= BFUNC_SEMI_ON
			
			if (iWPNBOX_FLAG & BFUNC_BURST_ON)
				iWPNBOX_FLAG &= ~BFUNC_BURST_ON
				
			if (iWPNBOX_FLAG & BFUNC_FBURST_ON)
				iWPNBOX_FLAG &= ~BFUNC_FBURST_ON
		}
				
		
		cs_set_user_zoom(id, CS_RESET_ZOOM, 0)
		delete_trie_key(iPlayerInfo[id], SECTION_USER_ZOOM_LVL)
		
		if (CheckPlayerBit(g_SemiAutomaticMode, id))	
			ClearPlayerBit(g_SemiAutomaticMode, id);
		
		if (CheckPlayerBit(g_SpecialBurstMode, id))	
			ClearPlayerBit(g_SpecialBurstMode, id);
		
		if (CheckPlayerBit(g_SpecialBurstFamas, id))	
			ClearPlayerBit(g_SpecialBurstFamas, id);
		
		UT_SetPlayerFOV(id, 90)
		
		
		
		//	Store Grenade Clip | Bpa to this dropped weapon
			
		
		new szKey[128]
		new iBufferInfo
			
		formatex(szKey, sizeof szKey - 1, "%s_%d", PREFIX_SLOT_CLIP, iEnt)
		set_trie_int(iWeaponBoxInfo, szKey, iClip)
		
		formatex(szKey, sizeof szKey - 1, "%s_%d", PREFIX_SLOT_BPA, iEnt)
		set_trie_int(iWeaponBoxInfo, szKey, iAmmo)
		
		iBufferInfo = get_trie_int(iPlayerInfo[id], SECTION_GRENADE_CLIP)
		formatex(szKey, sizeof szKey - 1, "%s_%d", PREFIX_SLOT_GRENADE_AMMO, iEnt)
		set_trie_int(iWeaponBoxInfo, szKey, iBufferInfo)
		
			
		iBufferInfo = get_trie_int(iPlayerInfo[id], SECTION_GRENADE_BPA)
		formatex(szKey, sizeof szKey - 1, "%s_%d", PREFIX_SLOT_GRENADE_BPA, iEnt)
		set_trie_int(iWeaponBoxInfo, szKey, iBufferInfo)
		
		iBufferInfo = get_trie_int(iPlayerInfo[id], SECTION_GRENADE_CLIP_STORE)
		formatex(szKey, sizeof szKey - 1, "%s_%d", PREFIX_SLOT_GRENADE_AMMO_STORE, iEnt)
		set_trie_int(iWeaponBoxInfo, szKey, iBufferInfo)
		
		iBufferInfo = get_trie_int(iPlayerInfo[id], SECTION_GRENADE_BPA_STORE)
		formatex(szKey, sizeof szKey - 1, "%s_%d", PREFIX_SLOT_GRENADE_BPA_STORE, iEnt)
		set_trie_int(iWeaponBoxInfo, szKey, iBufferInfo)
		
		formatex(szKey, sizeof szKey - 1, "%s_%d", PREFIX_SLOT_FLAG, iEnt)
		set_trie_int(iWeaponBoxInfo, szKey, iWPNBOX_FLAG)
		
		formatex(szKey, sizeof szKey - 1, "%s_%d", PREFIX_SLOT_EQUIPMENT_FLAG, iEnt)
		set_trie_int(iWeaponBoxInfo, szKey,  get_trie_int(iPlayerInfo[id], SECTION_USER_WPN_FLAG))
		
		
		//	Delete keys of Trie to save memory
		delete_trie_key(iPlayerInfo[id], SECTION_GRENADE_CLIP)
		delete_trie_key(iPlayerInfo[id], SECTION_GRENADE_BPA)
		delete_trie_key(iPlayerInfo[id], SECTION_GRENADE_CLIP_STORE)
		delete_trie_key(iPlayerInfo[id], SECTION_GRENADE_BPA_STORE)
		delete_trie_key(iPlayerInfo[id], SECTION_USER_WPN_FLAG)
		
		
		set_task(WEAPONBOX_ACTIVE_TIME, "fw_ActiveNewRifle", iEnt + TASK_ACTIVE_WEAPONBOX)
		
		native_set_user_primary_id(id, -1)
		
		
	}
	else 
	{
		
		
		
		new szKey[128]
		
		formatex(szKey, sizeof szKey - 1, "%s_-1_%d", PREFIX_SLOT_EQUIPMENT_FLAG, iEnt)
		set_trie_int(iWeaponBoxInfo, szKey, get_trie_int(iPlayerInfo[id], SECTION_USER_WPN_FLAG))
		delete_trie_key(iPlayerInfo[id], SECTION_USER_WPN_FLAG)
		
		formatex(szKey, sizeof szKey - 1, "%s_-1_%d", PREFIX_SLOT_CLIP, iEnt)
		set_trie_int(iWeaponBoxInfo, szKey, iClip)
		
		formatex(szKey, sizeof szKey - 1, "%s_-1_%d", PREFIX_SLOT_BPA, iEnt)
		set_trie_int(iWeaponBoxInfo, szKey, iAmmo)
		
	
		set_pev(iEnt, pev_iuser3, iWeaponId)
		set_pev(iEnt, pev_iuser4, WpnBoxNormalPrimaryWait)
		UT_SetUserBPA(id, iWeaponId, 0)
		
		set_task(WEAPONBOX_ACTIVE_TIME, "fw_ActiveNormalRifle", iEnt + TASK_ACTIVE_WEAPONBOX)
		
		delete_trie_key(iPlayerInfo[id], SECTION_USER_WPN_FLAG)
		return 
				
	}
	
	if (CheckPlayerBit(g_LauncherModeActivated, id))
		ClearPlayerBit(g_LauncherModeActivated, id);
		
	if (CheckPlayerBit(g_ReloadingGrenadeLauncher, id))
		ClearPlayerBit(g_ReloadingGrenadeLauncher, id)
		
	if( CheckPlayerBit(bit_NormalIronSight, id))
		ClearPlayerBit(bit_NormalIronSight, id)
	
	return 
}

public fw_CmdStart(id, ucHandle, seed)
{
	if (!is_user_alive(id))
		return 
	
	new iClip
	new iWeaponId = get_user_weapon(id, iClip)
	
	if (!is_primary_wpn(iWeaponId))
		return 
		
	new iPrimaryWpnId = native_get_user_primary_id(id)
	
	new iEnt = fm_get_active_item(id)
	
	if (!pev_valid(iEnt))
		return
		
	new fInReload, iButton
	new Float:flNextAttack
	new iSilentState
	fInReload = fm_get_weapon_reload(iEnt)
	iButton = get_uc(ucHandle, UC_Buttons)
	flNextAttack = fm_get_next_attack(id)
	
	iClip = cs_get_weapon_ammo(iEnt)
	iSilentState = cs_get_weapon_silen(iEnt)
	
							
							
	if (iPrimaryWpnId > -1)
	{
		new iBasicSetting
		TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BASIC_SETTING, iBasicSetting)
	
		new iWPN_ID = native_get_primary_real_id(iPrimaryWpnId)
		
		if (iWeaponId != iWPN_ID)
			return
			
		new iWPN_FUNC = native_get_primary_wpn_func(iPrimaryWpnId)
			
		if (iButton & IN_RELOAD)
		{	
			set_uc(ucHandle, UC_Buttons, iButton &= ~IN_RELOAD)
			console_cmd(id, "-reload")
					
			new iBasicSetting
			TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BASIC_SETTING, iBasicSetting)
			if (!CheckPlayerBit(g_LauncherModeActivated, id) && !(iBasicSetting & ST_NO_MANUAL_RELOAD) && native_get_primary_wpn_type(iPrimaryWpnId) != TYPE_SHIELD)
			{
				if (fInReload)
					return
					
				if (flNextAttack > 0.0)
					return
							
					
				new iDefaultClip = UT_Get_CS_DefaultClip(iWeaponId)
							
				if (iClip >= iDefaultClip)
				{
					cs_set_weapon_ammo(iEnt, iDefaultClip - 1)
					UT_MakeWpnReload(iEnt)
				}
					
					
				cs_set_weapon_ammo(iEnt, iClip)				
				csred_WpnReload_Post(id, iEnt, iWeaponId)			
			}
		}
		else if (iButton & IN_ATTACK)
		{
			if (fInReload)
			{
				
				set_uc(ucHandle, UC_Buttons, iButton &= ~IN_ATTACK)
				console_cmd(id, "-attack")			
				
				if (iBasicSetting & ST_NEW_RELOAD)
				{
					
					if (0< iClip <= native_get_primary_wpn_ammo(iPrimaryWpnId, id) - 1)
					{
						if (!CheckPlayerBit(g_CancelReloading, id))	
							SetPlayerBit(g_CancelReloading, id)
					}
				}		
			}
			else
			{
							
				new iFireFlag 
				TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_WPN_FIRE_FLAG, iFireFlag)
				
				if (iFireFlag & FIRE_ON_RELEASE)
					remove_task(id + TASK_OPEN_FIRE)
				
				if (flNextAttack > 0.0)
					return
					
				if (native_get_primary_wpn_type(iPrimaryWpnId) != TYPE_SHIELD)
				{
					new iOpenFire = 1
					
					if (iFireFlag & FIRE_MINIGUN && iClip)
					{
							
						if (!CheckPlayerBit(g_LauncherModeActivated, id))
						{
							new Float:fSpinTime 
							
							new iAttackStage = get_trie_int(iPlayerInfo[id], SECTION_ATTACK_STAGE)
							
							if (!iAttackStage)
							{
								
								set_uc(ucHandle, UC_Buttons, iButton &= ~IN_ATTACK)
											
								TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_SPIN_TIME, fSpinTime)
								set_trie_float(iPlayerInfo[id], SECTION_ATTACK_TIME, get_gametime() + fSpinTime)
								set_trie_int(iPlayerInfo[id], SECTION_ATTACK_STAGE, STAGE_SPIN)
											
								if (iFireFlag & FIRE_DRAW_SPIN_ANIM)
								{
									new iSpinAnimation = Get_CSWPN_MaxAnimation(iWPN_ID)
													
									iSpinAnimation += ANIM_SPIN_PRE
													
									if (iSilentState)
										iSpinAnimation += 1
							
									UT_PlayWeaponAnim(id, iSpinAnimation)
								}
										
								iOpenFire = 0	
							}
							else if (iAttackStage == STAGE_SPIN)
							{
								set_uc(ucHandle, UC_Buttons, iButton &= ~IN_ATTACK)
								TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_DEACTIVE_SPIN, fSpinTime)
									
								if (get_gametime() >= get_trie_float(iPlayerInfo[id], SECTION_ATTACK_TIME))
								{
									set_trie_float(iPlayerInfo[id], SECTION_ATTACK_TIME, get_gametime() + fSpinTime)
									set_trie_int(iPlayerInfo[id], SECTION_ATTACK_STAGE, STAGE_FIRE)
									
								}
								else	iOpenFire = 0
								
							}
							else if (iAttackStage == STAGE_FIRE && !is_user_bot(id))
							{
								if (iFireFlag & FIRE_ON_RELEASE)
								{
									set_uc(ucHandle, UC_Buttons, iButton &= ~IN_ATTACK)
										
									TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_DEACTIVE_SPIN, fSpinTime)
									set_trie_float(iPlayerInfo[id], SECTION_ATTACK_TIME, get_gametime() + fSpinTime)
										
									set_task(0.25, "OpenReleaseFire_TASK", id + TASK_OPEN_FIRE)//, iParam, sizeof iParam)
									iOpenFire = 0
								}
							}
						}
						
						PW_do_special_attack(id, iEnt, iPrimaryWpnId, ucHandle, iButton, iClip, iOpenFire)
					}
				}
				else
				{
					//	Do Shield Attack
					new iDefaultFireMode
					TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_ORIGIN_FIREMODE, iDefaultFireMode)
					
					if (iDefaultFireMode)
					{
						remove_task(id + TASK_ATTACK_MELEE)
						
						new Float:fDamageTime
						TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_FIRE_RATE, fDamageTime)
						
						UT_PlayWeaponAnim(id, Get_CSWPN_Anim_Shoot1(iWeaponId))
						
						set_task(fDamageTime, "MeleeAttack_TASK", id + TASK_ATTACK_MELEE)
					}
					
				}
				
				if (iWPN_FUNC & FUNC_GRENADE_LAUNCHER)
				{
					if (CheckPlayerBit(g_LauncherModeActivated, id))
					{
						set_uc(ucHandle, UC_Buttons, iButton &= ~IN_ATTACK)
						console_cmd(id, "-attack")
										 
						cs_set_weapon_ammo(iEnt, iClip + 1)
						ExecuteHamB(Ham_Weapon_PrimaryAttack, iEnt)
										
						new iVelocity
						
						TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BULLET_VELOCITY, iVelocity)
										
										
						create_launcher_grenade(id, iPrimaryWpnId, 1, MOVETYPE_FLY, iVelocity, 0)
						cs_set_weapon_ammo(iEnt, iClip)				
					}		
				}
			}
		}
		else if (iButton & IN_ATTACK2)
		{
			set_uc(ucHandle, UC_Buttons, iButton &= ~IN_ATTACK2)
			console_cmd(id, "-attack2")
				
			if (fInReload)
				return
					
			if (flNextAttack > 0.0 || native_get_primary_wpn_type(iPrimaryWpnId) == TYPE_SHIELD)
				return
			
			if (iWPN_FUNC & FUNC_ADS)
			{
				if (!CheckPlayerBit(g_LauncherModeActivated, id))
				{
					new iAdsFlag 
					TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_ADS_FLAG, iAdsFlag)
					
					if (CheckPlayerBit(g_UsingZoomLen, id))
					{
						if (!do_scope_function(id, iPrimaryWpnId))
						{
									
							if (task_exists(id - TASK_IRON_SIGHT))
								remove_task(id - TASK_IRON_SIGHT)
								
							if (!(iAdsFlag & ADS_NO_OUT_ANIM))
							{
								new iPlayedAnimation = Get_CSWPN_MaxAnimation(iWPN_ID) + ANIMATION_STOP_IRONSIGHT
									
								if (iSilentState)
									iPlayedAnimation += 1
												
								UT_PlayWeaponAnim(id, iPlayedAnimation)
							}
							
							new Float:fAdsOut
							TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_TIME_ADS_OUT, fAdsOut)
							
							set_task(fAdsOut, "DeActiveIronSight_TASK", id - TASK_IRON_SIGHT)			
							fm_set_next_attack(id, fAdsOut)
							
							
							if (!(iBasicSetting & ST_NO_CROSSHAIR))
								UT_CS_Crosshair_Toggle(id, 1, 1)
							else	UT_CS_Crosshair_Toggle(id, 0, 1)
										
						}
					}
					else
					{
									
						if (task_exists(id + TASK_IRON_SIGHT))
							remove_task(id + TASK_IRON_SIGHT)
									
						new iParam[6]
								
						iParam[0] = iPrimaryWpnId
						iParam[1] = iAdsFlag
						iParam[2] = 0 // Already Activated ADS?
						iParam[3] = 0 // Zoom Level
						iParam[4] = 1 // Auto update Scope
						iParam[5] = iEnt// Weapon Entity
						
						
						new Float:fAdsIn
						TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_TIME_ADS_IN, fAdsIn)
							
						
						set_task(fAdsIn, "ActiveIronSight_TASK", id + TASK_IRON_SIGHT, iParam, sizeof iParam)			
						fm_set_next_attack(id, fAdsIn)
						
						if (!(iAdsFlag & ADS_NO_INTRO_ANIM))
						{
							new iPlayedAnimation = Get_CSWPN_MaxAnimation(iWPN_ID) +  ANIMATION_START_IRONSIGHT
									
							if (iSilentState)
								iPlayedAnimation += ANIM_SILENCER_ADD
										
							UT_PlayWeaponAnim(id, iPlayedAnimation )
						}
					}
				}
			}
			
		}
		
			
		new iImpulse = get_uc(ucHandle, UC_Impulse)
		if (iImpulse == 201)
		{
			if (flNextAttack > 0.0)
				return
					
			if (native_get_primary_wpn_type(iPrimaryWpnId) == TYPE_SHIELD)
				return 
				
			if (fInReload)
				return
					
			if (iWPN_FUNC & FUNC_GRENADE_LAUNCHER)
			{
				if (!CheckPlayerBit(g_UsingZoomLen, id))
				{
					set_uc(ucHandle, UC_Impulse, -1)
								
					if (CheckPlayerBit(g_LauncherModeActivated, id))
					{	
						if (CheckPlayerBit(g_UsingZoomLen, id))	ClearPlayerBit(g_UsingZoomLen, id)
						UT_SetPlayerFOV(id, 90)
										
									
						new iPlayedAnimation = Get_CSWPN_MaxAnimation(iWPN_ID) + ANIMATION_CHANGE_GREN_BACK
									
						if (iSilentState)
							iPlayedAnimation += ANIM_SILENCER_ADD
											
						UT_PlayWeaponAnim(id, iPlayedAnimation)
									
									
						new Float:fChangeBackTime
						TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_GRENADE_DEACTIVE_TIME, fChangeBackTime)
						
						fm_set_next_attack(id, fChangeBackTime)
						set_task(fChangeBackTime, "DisableGrenadeLauncher_TASK", id - TASK_GRENADE_LAUNCHER_READY)
						
						if (CheckPlayerBit(g_LauncherModeActivated, id))
							ClearPlayerBit(g_LauncherModeActivated, id);
							
										
						ExecuteForward(ifw_FuncActivated, ifw_Result, id, iPrimaryWpnId, FUNC_OFF)
											
						client_print(id, print_center, "%L", id, "DEACTIVE_GLAUNCHER_FUNCTION")		
					}
					else
					{
						
						new iGrenadeClip 
						TrieGetCell(iPlayerInfo[id], SECTION_GRENADE_CLIP, iGrenadeClip)
						
						new iGrenadeBpa
						TrieGetCell(iPlayerInfo[id], SECTION_GRENADE_BPA, iGrenadeBpa)
						
						if (iGrenadeClip || (!iGrenadeClip && iGrenadeBpa))
						{
								
							if (CheckPlayerBit(g_UsingZoomLen, id))	
								ClearPlayerBit(g_UsingZoomLen, id)
								
							UT_SetPlayerFOV(id, 90)
										
							new iPlayedAnimation = Get_CSWPN_MaxAnimation(iWPN_ID) + ANIMATION_CHANGE_GREN
								
							if (iSilentState)
								iPlayedAnimation += ANIM_SILENCER_ADD
												
							UT_PlayWeaponAnim(id, iPlayedAnimation)
											
												
							new Float:fChangeTime 
							TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_GRENADE_ACTIVE_TIME, fChangeTime)
								
							set_task(fChangeTime, "GrenadeLauncherReady_TASK", id + TASK_GRENADE_LAUNCHER_READY)
												
							fm_set_next_attack(id, fChangeTime)
							if (!CheckPlayerBit(g_LauncherModeActivated, id))	
								SetPlayerBit(g_LauncherModeActivated, id)
											
							client_print(id, print_center, "%L", id, "OPEN_GLAUNCHER_FUNCTION")
								
							ExecuteForward(ifw_FuncActivated, ifw_Result, id, iPrimaryWpnId, FUNC_ON)
						}
					}
				}			
			}			
		}
	}
	else
	{
		
		if (UT_IsUsingStationaryWeapon(id))
			return
			
			
		if (iButton & IN_RELOAD)
		{
			set_uc(ucHandle, UC_Buttons , iButton &~ IN_RELOAD)
			console_cmd(id, "-reload")	
			
				
			if (flNextAttack > 0.0)
				return
						
			if (fInReload)
				return
			
											
			UT_SetPlayerFOV(id, 90)
			if (CheckPlayerBit(bit_NormalIronSight, id))
				ClearPlayerBit(bit_NormalIronSight, id)
							
			new iDefaultClip = UT_Get_CS_DefaultClip(iWeaponId)
									
			if (iClip >= iDefaultClip)
				cs_set_weapon_ammo(iEnt, iDefaultClip - 1)
								
							
			UT_MakeWpnReload( iEnt)
			
			
			cs_set_weapon_ammo(iEnt, iClip)
						
		}
		else if (iButton & IN_ATTACK2)
		{
			if (!UT_Get_CS_ADS_State(iWeaponId))
			{
				if (iWeaponId == CSW_M4A1 || iWeaponId == CSW_FAMAS)
				{
					set_uc(ucHandle, UC_Buttons , iButton &~ IN_ATTACK2)
					console_cmd(id, "-attack2")
					
					cs_set_weapon_silen(iEnt, 0, 0)
					UT_set_weapon_burst(iEnt, 0)
				}
				return
			}
			set_uc(ucHandle, UC_Buttons , iButton &~ IN_ATTACK2)	
			console_cmd(id, "-attack2")
					
			if (flNextAttack > 0.0)
				return
			
			if (CheckPlayerBit(bit_NormalIronSight, id))
			{			
				cs_set_user_zoom(id, CS_RESET_ZOOM, 0)
							
				if (task_exists(id - TASK_NORMAL_IRONSIGHT))
					remove_task(id - TASK_NORMAL_IRONSIGHT)
											
											
				// UT_SendCurWeaponMsg(id, 1, iWeaponId, iClip 1)
											
											
				new iPlayedAnimation = Get_CSWPN_MaxAnimation(iWeaponId) + ANIMATION_STOP_IRONSIGHT
										
				if (iSilentState)
					iPlayedAnimation += 1
													
				UT_PlayWeaponAnim(id, iPlayedAnimation)
									
				new Float:flEndAdsTime = UT_Get_CS_EndAdsTime(iWeaponId)
				set_task(flEndAdsTime, "DeActiveNormalIronSight_TASK", id - TASK_NORMAL_IRONSIGHT)
				fm_set_next_attack(id, flEndAdsTime)
				
				UT_SetPlayerFOV(id, 90)
				
				UT_CS_Crosshair_Toggle(id, UT_Get_CS_Crosshair(iWeaponId), 1)
				ClearPlayerBit(bit_NormalIronSight, id);
				//UT_HL_Crosshair_Toggle(id, 0, 1)
											
			}			
			else
			{
										
				UT_SetPlayerFOV(id, 90)
										
										
				if (task_exists(id + TASK_NORMAL_IRONSIGHT))
					remove_task(id + TASK_NORMAL_IRONSIGHT)
							
				new Float:flStartAdsTime = UT_Get_CS_StartAdsTime(iWeaponId)
				
				set_task(flStartAdsTime , "ActiveNormalIronSight_TASK", id + TASK_NORMAL_IRONSIGHT)
				fm_set_next_attack(id, flStartAdsTime )
				new iPlayedAnimation = Get_CSWPN_MaxAnimation(iWeaponId) +  ANIMATION_START_IRONSIGHT
										
				if (iSilentState)
					iPlayedAnimation += ANIM_SILENCER_ADD
											
				UT_PlayWeaponAnim(id, iPlayedAnimation )
			}
		}
		else if (iButton & IN_ATTACK)
		{
			if (fInReload)
			{
				set_uc(ucHandle, UC_Buttons, iButton &= ~IN_ATTACK)
				console_cmd(id, "-attack")			
				
				if (is_shotgun(iWeaponId))
				{
					if (!CheckPlayerBit(g_CancelReloading, id))
						SetPlayerBit(g_CancelReloading, id)	
				}
			}
			
		}
	}
	
	return
}

public MeleeAttack_TASK(TASKID)
{
	new id = TASKID - TASK_ATTACK_MELEE
	
	if (!is_user_alive(id))
		return
	
	new iPrimaryWpnId = native_get_user_primary_id(id)
	
	if (!native_is_valid_pw(iPrimaryWpnId))
		return
		
	if (get_user_weapon(id) != native_get_primary_real_id(iPrimaryWpnId))
		return
		
	new Float:fDamage
	TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_DAMAGE, fDamage)
	
	new szWeaponSound[32]
	TrieGetString(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_SOUND, szWeaponSound, sizeof szWeaponSound -1 )
	
	new szHitWallSound[128]
	new szHitBodySound[128]
	
	formatex(szHitWallSound, sizeof szHitWallSound - 1, "weapons/%s/%s-HitWall.wav", SOUND_DIRECTORY, szWeaponSound)
	formatex(szHitBodySound, sizeof szHitBodySound - 1, "weapons/%s/%s-HitBody.wav", SOUND_DIRECTORY, szWeaponSound)
	
	UT_MeleeAttack(id, 1, fDamage, 50.0, DMG_CRUSH, 1, szHitWallSound, szHitBodySound)
		
}

public DoFamasBurst_TASK(iParam[3], TASKID)
{
	new id = TASKID - TASK_FAMAS_BURST
	
	if (!is_user_alive(id))
	{
		remove_task(TASKID)
		return
	}
	
	
	new iPrimaryWpnId = iParam[0]
	new iEnt = iParam[1]
	new iShot = iParam[2]
	
	if (native_get_user_primary_id(id) < 0)
	{
		remove_task(TASKID)
		return
	}
	
	if (native_get_user_primary_id(id) != iPrimaryWpnId)
	{
		remove_task(TASKID)
		return
	}
	
	if (!CheckPlayerBit(g_SpecialBurstFamas, id))
	{
		remove_task(TASKID)
		return
	}
	
	if (!iShot)
	{
		if (cs_get_weapon_ammo(iEnt))
		{
			new Float:fTimeDelayFm
			TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_TIME_FM_DELAY, fTimeDelayFm)
			fm_set_next_attack(id, fTimeDelayFm)
		}
		else	ExecuteHamB(Ham_Weapon_Reload, iEnt)
		
		remove_task(TASKID)
		return
	}
	
	if (!cs_get_weapon_ammo(iEnt))
	{
		ExecuteHamB(Ham_Weapon_Reload, iEnt)
		remove_task(TASKID)
		return
	}
	
	//set_pdata_float(id, m_flNextAttack, 0.0, 5)
	ExecuteHamB(Ham_Weapon_PrimaryAttack, iEnt)
	fm_set_next_attack(id, 9999.0)
	iParam[2]--
	
	
	set_task(BURST_CYCLE, "DoFamasBurst_TASK", id + TASK_FAMAS_BURST, iParam, sizeof iParam)
}


public ActiveIronSight_TASK(iParam[6], TASKID)
{
	new id = TASKID - TASK_IRON_SIGHT
	
	if (!is_user_alive(id))
		return
	
	new iPrimaryWpnId = native_get_user_primary_id(id)	
			
	if (!native_is_valid_pw(iPrimaryWpnId) || iPrimaryWpnId != iParam[0])
		return
		
	new iEnt = fm_get_active_item(id)
			
	if (!iEnt || !pev_valid(iEnt) || iEnt != iParam[5])
		return
	
	new iWeaponId = cs_get_weapon_id(iEnt)
	
	if (iWeaponId != native_get_primary_real_id(iPrimaryWpnId))
		return
		
	if (!iParam[3])
		delete_trie_key(iPlayerInfo[id], SECTION_USER_ZOOM_LVL)
	else	
		set_trie_int(iPlayerInfo[id], SECTION_USER_ZOOM_LVL , iParam[3])							
		
	/*
	if (iParam[2])
	{
		SetPlayerBit(g_UsingZoomLen, id)
		
		new iFOV
		
		switch (iParam[3])
		{
			case 1 : 
			{
				TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_FIRST_FOV, iFOV)
				UT_SetPlayerFOV(id, iFOV)
			}
			case 2:
			{
				TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_SECOND_FOV, iFOV)
				UT_SetPlayerFOV(id, iFOV)
			}
			default:
				UT_SetPlayerFOV(id, 90)
		}
	}
	*/
	
	new iWPN_FUNC = native_get_primary_wpn_func(iPrimaryWpnId)
	
	if (!(iWPN_FUNC & FUNC_ADS))
		return
	
	new iAdsFlag = iParam[1]
	
	do_scope_function(id, iPrimaryWpnId)
	SetPlayerBit(g_UsingZoomLen, id)
	
	
	show_specific_view_model(id, iPrimaryWpnId, FUNC_ADS)
		
	if (iAdsFlag & ADS_NO_HL_CROSSHAIR)
		UT_HL_Crosshair_Toggle(id, 0, 1)
	else	UT_HL_Crosshair_Toggle(id, 1, 1)
		
	if (!iCheckSniper(iWeaponId))
	{
		if (iAdsFlag & ADS_NO_CS_CROSSHAIR)
			UT_CS_Crosshair_Toggle(id, 0, 1)
		else	UT_CS_Crosshair_Toggle(id, 1, 1)
	}
			
		
		
	
	new iAnimation = Get_CSWPN_MaxAnimation(iWeaponId) + ANIMATION_IDLE_IRONSIGHT_3 
			
	if (cs_get_weapon_silen(iEnt))
		iAnimation += 1
					
	UT_PlayWeaponAnim(id, iAnimation)
			
	if (CheckPlayerBit(g_TurnOnThermal, id))
	{
		if (!is_user_bot(id))
			SetTaskShowNVG(id)
		
	}
}

public ActiveNormalIronSight_TASK(TASKID)
{
	new id = TASKID - TASK_NORMAL_IRONSIGHT
	
	if (!is_user_alive(id))
		return
		
	new iClip
	new iWeaponid = get_user_weapon(id, iClip)
	
	if (!CheckPlayerBit(bit_NormalIronSight, id))	
		SetPlayerBit(bit_NormalIronSight, id)
	
		
		
	new iEnt = fm_get_active_item(id)
			
	if (!iEnt || !pev_valid(iEnt))
		return
		
	
	new iAnimation = Get_CSWPN_MaxAnimation(iWeaponid) + ANIMATION_IDLE_IRONSIGHT_3
			
	if (cs_get_weapon_silen(iEnt))
		iAnimation += 1
				
	UT_PlayWeaponAnim(id, iAnimation)
	set_pev(id, pev_weaponanim, iAnimation)
	
	UT_SetPlayerFOV(id, UT_Get_CS_ADS_FOV(iWeaponid))
		
	UT_CS_Crosshair_Toggle(id, 0, 1)
	UT_HL_Crosshair_Toggle(id, 1, 1)
}

public DeActiveIronSight_TASK(TASKID)
{
	new id = TASKID + TASK_IRON_SIGHT
	
	if (!is_user_alive(id))
		return
		
	new iPrimaryWpnId = native_get_user_primary_id(id)
	
	if (!native_is_valid_pw(iPrimaryWpnId))
		return
		
	if (CheckPlayerBit(g_UsingZoomLen, id))	
		ClearPlayerBit(g_UsingZoomLen, id)
		
	new iWPN_FUNC = native_get_primary_wpn_func(iPrimaryWpnId)
	
	if (!(iWPN_FUNC & FUNC_ADS))
		return
	
		
	new iEnt = fm_get_active_item(id)
			
	if (!iEnt || !pev_valid(iEnt))
		return
			
	new iWeaponId = native_get_primary_real_id(iPrimaryWpnId)  
	UT_PlayWeaponAnim(id, Get_CSWPN_Anim_Idle(iWeaponId, false))
	
	UT_SendCurWeaponMsg(id, 1, iWeaponId, cs_get_weapon_ammo(iEnt), 1)
}

public DeActiveNormalIronSight_TASK(TASKID)
{
	new id = TASKID + TASK_NORMAL_IRONSIGHT
	
	if (!is_user_alive(id))
		return
		
	if (CheckPlayerBit(bit_NormalIronSight, id))	ClearPlayerBit(bit_NormalIronSight, id)
		
	new iEnt = fm_get_active_item(id)
		
	if (!iEnt || !pev_valid(iEnt))
		return
		
	new iWeaponId = cs_get_weapon_id(iEnt)
	
	
	UT_PlayWeaponAnim(id, Get_CSWPN_Anim_Idle(iWeaponId, false))
		
	UT_SendCurWeaponMsg(id, 1, iWeaponId, cs_get_weapon_ammo(iEnt), 1)
	
	
}

public fw_UpdateClientData_Post(id, iSendWeapon, cd_handle)
{
	if (!is_user_alive(id))
		return FMRES_IGNORED
	
	new iWeaponId = get_user_weapon(id)
	
	if (!iWeaponId)
		return FMRES_IGNORED
	
	new iPrimaryWpnId = native_get_user_primary_id(id)
	
	new iEnt = fm_get_active_item(id)
	
	if (!iEnt || !pev_valid(iEnt))
		return FMRES_IGNORED
		
	if (!native_is_valid_pw(iPrimaryWpnId))
	{
		
		if (!UT_Get_CS_ADS_State(iWeaponId))
			return FMRES_IGNORED
			
		if( CheckPlayerBit(bit_NormalIronSight, id))
			set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.1)
		
		
		return FMRES_IGNORED
	}
	
	if ( iWeaponId != native_get_primary_real_id(iPrimaryWpnId))
		return FMRES_IGNORED
		
		
	
	new iFireFlag
	TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_WPN_FIRE_FLAG, iFireFlag)
	
	if (iFireFlag & FIRE_MINIGUN)
	{
		new iAttackStage = get_trie_int(iPlayerInfo[id], SECTION_ATTACK_STAGE)
		
		if (iAttackStage == STAGE_FIRE)
		{
			if (get_gametime() >= get_trie_float(iPlayerInfo[id], SECTION_ATTACK_TIME))
				set_trie_int(iPlayerInfo[id], SECTION_ATTACK_STAGE, STAGE_NONE)
				
			if (iFireFlag & FIRE_ON_RELEASE)
				set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0,01)
		}
		else
		{
			if (iAttackStage != STAGE_FIRE_RELEASE)
				set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0,01)
			else
			{
				if (get_gametime() >= get_trie_float(iPlayerInfo[id], SECTION_ATTACK_TIME))
					set_trie_int(iPlayerInfo[id], SECTION_ATTACK_STAGE, STAGE_NONE)
			}
		}
		
	}
	
	new iWPN_FUNC = native_get_primary_wpn_func(iPrimaryWpnId)
	
	if (iWPN_FUNC & FUNC_GRENADE_LAUNCHER)
	{
		if (CheckPlayerBit(g_LauncherModeActivated, id))
			set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.1)
	}
	
	if (native_is_primary_wpn_ads(id))
	{
		new iAdsFlag
		TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_ADS_FLAG, iAdsFlag)
		
		
		set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.1)
	}
	
	new iBulletType
	TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BULLET_TYPE, iBulletType)
	
	if (iBulletType == BULLET_TYPE_EXPLOSIVE)
		set_cd(cd_handle, CD_flNextAttack, get_gametime() + 0.1)
	
	return FMRES_IGNORED
}
	
	
public OpenReleaseFire_TASK(TASKID)
{
	new id = TASKID - TASK_OPEN_FIRE
	
	if (!is_user_alive(id))
		return
									
	new iPrimaryWpnId = native_get_user_primary_id(id)  
	if (!native_is_valid_pw(iPrimaryWpnId))
		return
	
	new iEnt = fm_get_active_item(id)
	
	if (!iEnt || !pev_valid(iEnt))
		return
	
	new iWeaponId = cs_get_weapon_id(iEnt)
	
	if (iWeaponId != native_get_primary_real_id(iPrimaryWpnId))
		return
		
	if (!CheckPlayerBit(g_SpecialBurstFamas, id) && !CheckPlayerBit(g_SpecialBurstMode, id))
	{
		set_trie_int(iPlayerInfo[id], SECTION_ATTACK_STAGE, STAGE_FIRE_RELEASE)
		ExecuteHamB(Ham_Weapon_PrimaryAttack, iEnt)
		set_trie_int(iPlayerInfo[id], SECTION_ATTACK_STAGE, STAGE_NONE)
	}
	else
	{
		set_trie_int(iPlayerInfo[id], SECTION_ATTACK_STAGE, STAGE_FIRE_RELEASE)
		PW_do_special_attack(id, iEnt, iPrimaryWpnId, 0, IN_ATTACK , cs_get_weapon_ammo(iEnt), 1)
		set_trie_int(iPlayerInfo[id], SECTION_ATTACK_STAGE, STAGE_NONE)
	}
	
}


public fw_WeaponBoxTouch(iEnt, id)
{
	if (!is_user_alive(id))
		return PLUGIN_CONTINUE
		
	if (!iEnt || !pev_valid(iEnt))
		return PLUGIN_CONTINUE
	
	if (!IsWeaponBoxCanTouch(iEnt))	
		return PLUGIN_HANDLED
		
	if (!IsCsRedWpnBox(iEnt))
		return PLUGIN_CONTINUE
		
	new iState = pev(iEnt, pev_iuser4)
	if (iState == WpnBoxPrimaryReady)
	{
		if (!can_player_touch_wpnbox(id))
			return PLUGIN_HANDLED
		
		if (cs_get_user_hasprim(id))
			return PLUGIN_HANDLED;
		
		
		//	Give player Primary Weapon
		/*****************************************************/
		
		new iPrimaryWpnId = pev(iEnt, pev_iuser3)
		
		new iWeaponEnt = native_give_user_primary_wpn(id, iPrimaryWpnId)
		
		if (!iWeaponEnt || !pev_valid(iEnt))
			return PLUGIN_HANDLED
		
		/*****************************************************/
		
		new szKey[128]
		new iBufferInfo
		
		//	Retrieve the flag of the dropped weapon
		formatex(szKey, sizeof szKey - 1, "%s_%d", PREFIX_SLOT_FLAG, iEnt)
		iBufferInfo = get_trie_int(iWeaponBoxInfo, szKey)
		delete_trie_key(iWeaponBoxInfo, szKey)
		
		//	Set the Fire Mode
		if (iBufferInfo & BFUNC_BURST_ON)
			SetPlayerBit(g_SpecialBurstMode, id)
		else if (iBufferInfo & BFUNC_FBURST_ON)
			SetPlayerBit(g_SpecialBurstFamas, id)
		else if (iBufferInfo & BFUNC_SEMI_ON)
			SetPlayerBit(g_SemiAutomaticMode, id)
		
		//	Theral Function is already on ?
		if (iBufferInfo & BFUNC_THERMAL_ON)
		{
			if (!CheckPlayerBit(g_TurnOnThermal, id))	
				SetPlayerBit(g_TurnOnThermal, id)
		}
		
		/*****************************************************/
		
		//	Set Clip | Ammo 
		
		formatex(szKey, sizeof szKey - 1, "%s_%d", PREFIX_SLOT_CLIP, iEnt)
		cs_set_weapon_ammo(iWeaponEnt, get_trie_int(iWeaponBoxInfo, szKey))
		delete_trie_key(iWeaponBoxInfo, szKey)
		
		formatex(szKey, sizeof szKey - 1, "%s_%d", PREFIX_SLOT_BPA, iEnt)
		UT_SetUserBPA(id, native_get_primary_real_id(iPrimaryWpnId), get_trie_int(iWeaponBoxInfo, szKey))
		delete_trie_key(iWeaponBoxInfo, szKey)
		
		/*****************************************************/
		formatex(szKey, sizeof szKey - 1, "%s_%d", PREFIX_SLOT_GRENADE_AMMO_STORE, iEnt)
		iBufferInfo = get_trie_int(iWeaponBoxInfo, szKey)
		if (iBufferInfo)
			set_trie_int(iPlayerInfo[id], SECTION_GRENADE_CLIP_STORE, iBufferInfo)
		delete_trie_key(iWeaponBoxInfo, szKey)
		
		formatex(szKey, sizeof szKey - 1, "%s_%d", PREFIX_SLOT_GRENADE_BPA_STORE, iEnt)
		iBufferInfo = get_trie_int(iWeaponBoxInfo, szKey)
		if (iBufferInfo)
			set_trie_int(iPlayerInfo[id], SECTION_GRENADE_BPA_STORE ,iBufferInfo)
		delete_trie_key(iWeaponBoxInfo, szKey)
		
		formatex(szKey, sizeof szKey - 1, "%s_%d", PREFIX_SLOT_EQUIPMENT_FLAG, iEnt)
		iBufferInfo = get_trie_int(iWeaponBoxInfo, szKey)
		set_trie_int(iPlayerInfo[id], SECTION_USER_WPN_FLAG, iBufferInfo)
		delete_trie_key(iWeaponBoxInfo, szKey)
		/*****************************************************/
		
		//	Set flag
		set_trie_int(iPlayerInfo[id], SECTION_USER_WPN_FLAG, pev(iEnt, pev_iWeaponFlag))
		
		/*****************************************************/
		fm_remove_weaponbox(iEnt)
		
		return PLUGIN_HANDLED
	}
	else if (iState == WpnBoxNormalPrimaryReady)
	{
		
		/*****************************************************/
		
		if (!can_player_touch_wpnbox(id))
			return PLUGIN_HANDLED
		
		if (cs_get_user_hasprim(id))
			return PLUGIN_HANDLED;
			
		/*****************************************************/
		
		new szKey[128]
		new iWeaponId = pev(iEnt, pev_iuser3)
		
		new szWeaponName[32]
		get_weaponname(iWeaponId, szWeaponName, sizeof szWeaponName - 1)
		
		new iWeaponEnt = fm_give_item(id, szWeaponName)
		
		if (!iWeaponEnt || !pev_valid(iWeaponEnt))
			return PLUGIN_HANDLED
		
		/*****************************************************/
		
		engclient_cmd(id, szWeaponName)
		
		/*****************************************************/
		
		formatex(szKey, sizeof szKey - 1, "%s_-1_%d", PREFIX_SLOT_CLIP, iEnt)
		cs_set_weapon_ammo(iWeaponEnt, get_trie_int(iWeaponBoxInfo, szKey))
		delete_trie_key(iWeaponBoxInfo, szKey)
		
		formatex(szKey, sizeof szKey - 1, "%s_-1_%d", PREFIX_SLOT_BPA, iEnt)
		UT_SetUserBPA(id, iWeaponId, get_trie_int(iWeaponBoxInfo, szKey))
		delete_trie_key(iWeaponBoxInfo, szKey)
		
		//	Set flag
		formatex(szKey, sizeof szKey - 1, "%s_-1_%d", PREFIX_SLOT_EQUIPMENT_FLAG, iEnt)
		set_trie_int(iPlayerInfo[id], SECTION_USER_WPN_FLAG, get_trie_int(iWeaponBoxInfo, szKey))
		delete_trie_key(iWeaponBoxInfo, szKey)
		
		/*****************************************************/
		ExecuteHamB(Ham_Item_Deploy, iWeaponEnt)
		
		fm_remove_weaponbox(iEnt)
		
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}	

public fw_GrenadeTouchesWorld(iGrenadeEnt, iToucher)
{
	if (!iGrenadeEnt || !pev_valid(iGrenadeEnt))
		return PLUGIN_CONTINUE
		
	new iGrenadeId = pev(iGrenadeEnt, pev_iGrenadeId)
	new iGrenadeType = pev(iGrenadeEnt, pev_iGrenadeType)
	
	if (!is_valid_grenade(iGrenadeType))
		return PLUGIN_CONTINUE
			
	new id = pev(iGrenadeEnt, pev_owner)
	
	if (id == iToucher)
		return PLUGIN_HANDLED

	if (iGrenadeId < 0 || iGrenadeId > g_weapon_count - 1)
	{
		engfunc(EngFunc_RemoveEntity, iGrenadeEnt)
		return PLUGIN_HANDLED
	}
	
	
	new iDamageType = 1
	
	if (iGrenadeType == PW_CLASS_FLASH)	
		iDamageType = 2
	
	new Float:fCurrentTime = get_gametime()
	
	new iMoveType = pev(iGrenadeEnt, pev_movetype)
	
	switch (pev(iGrenadeEnt, pev_iGrenadePosition))
	{
		case GRENADE_UNDER_BARREL:
		{
			new szGrenadeHud[32], szGrenadeSound[128]
			TrieGetString(weapon_StringInfo[iGrenadeId], SECTION_GRENADE_DEATHMSG, szGrenadeHud, sizeof szGrenadeHud - 1)
			TrieGetString(weapon_StringInfo[iGrenadeId], SECTION_BULLET_SOUND, szGrenadeSound, sizeof szGrenadeSound - 1)
				
			new iSPR_ID, iFramerate, iScale
			TrieGetCell(weapon_StringInfo[iGrenadeId], SECTION_SPR_INDEX, iSPR_ID)
			TrieGetCell(weapon_StringInfo[iGrenadeId], SECTION_BULLET_SPR_FRAME, iFramerate)
			TrieGetCell(weapon_StringInfo[iGrenadeId], SECTION_BULLET_SPR_SCALE, iScale)
				
			new iExplosionFlag
			TrieGetCell(weapon_StringInfo[iGrenadeId], SECTION_BULLET_FLAG, iExplosionFlag)
				
			new Float:fDamage
			TrieGetCell(weapon_StringInfo[iGrenadeId], SECTION_GREN_DMG, fDamage)
			
			new iRemoveEntity = 1
			new iDropGrenadeToFloor = 1
			
			if (iExplosionFlag & ACTIVE_ON_TOUCH)
				iRemoveEntity = 0
				
			if (iExplosionFlag & DETONATE_ONTOUCH)
			{
				set_pev(iGrenadeEnt, pev_fGrenadeFallStatus, 1.0)
					
				new Float:fGrenadeActiveTime 
				pev(iGrenadeEnt, pev_fGrenadeActiveTime, fGrenadeActiveTime)
					
				if (fCurrentTime >= fGrenadeActiveTime)
				{
					new iDamageBit
					TrieGetCell(weapon_StringInfo[iGrenadeId], SECTION_BULLET_DMGBIT, iDamageBit)
					
					new Float:fRadius 
					TrieGetCell(weapon_StringInfo[iGrenadeId], SECTION_DMG_RADIUS, fRadius)
					
					GrenadeDamage(iDamageType, -1, iGrenadeEnt, fRadius, fDamage, iDamageBit, szGrenadeHud , szGrenadeSound, iSPR_ID, iScale, iFramerate, iExplosionFlag, 1)
					iDropGrenadeToFloor = 0
				}
				else
				{
					new iCanDoDamage = 1
					if (is_user_alive(iToucher))
					{
						if (cs_get_user_team(iToucher) == cs_get_user_team(id) && !get_cvar_num("mp_friendlyfire"))
							iCanDoDamage = 0
							
						if (!is_movement_cause_damage(iMoveType))
							iCanDoDamage = 0
					}
					
					if (iCanDoDamage)
						GrenadeDamage(iDamageType, iToucher, iGrenadeEnt, 20.0, fDamage, DMG_CRUSH, szGrenadeHud , szGrenadeSound, iSPR_ID, iScale, iFramerate, iExplosionFlag, iRemoveEntity)
					
				}
			}
			
			if ((iExplosionFlag & ACTIVE_ON_TOUCH) && !iRemoveEntity)
			{
				set_pev(iGrenadeEnt, pev_fGrenadeFallStatus, 1.0)
					
				new Float:fTime
				TrieGetCell(weapon_StringInfo[iGrenadeId], SECTION_BULLET_ACTIVE_TIME, fTime)
					
				set_pev(iGrenadeEnt, pev_nextthink, fCurrentTime + fTime)
			}
			
			if ((iExplosionFlag & ATTACH_ON_TOUCH) && !iRemoveEntity)
			{
				iDropGrenadeToFloor = 0
				
				if (ExecuteHamB(Ham_IsPlayer, iToucher))
				{
					if (pev(iGrenadeEnt, pev_movetype) != MOVETYPE_FOLLOW)
						set_pev(iGrenadeEnt, pev_movetype, MOVETYPE_FOLLOW)
					
					
					if (pev(iGrenadeEnt, pev_aiment) != iToucher && !pev(iGrenadeEnt, pev_iGrenadeActive))
					{
						set_pev(iGrenadeEnt, pev_aiment, iToucher)
						set_pev(iGrenadeEnt, pev_effects, EF_NODRAW)
						
						
						new Float:fNextThink
						pev(iGrenadeEnt, pev_nextthink, fNextThink)
						
						new Float:fTaskTime = fNextThink - fCurrentTime
						remove_task(iGrenadeEnt + TASK_CALL_THINK)
						
						set_task(fTaskTime, "CallEntityThink_TASK", iGrenadeEnt + TASK_CALL_THINK)
						set_pev(iGrenadeEnt, pev_iGrenadeActive, 1)
					}
						
				}
				else
				{
					set_pev(iGrenadeEnt, pev_movetype, MOVETYPE_NONE)
				}
			}
			
			if (iDropGrenadeToFloor)
			{
				if (!pev(iGrenadeEnt, pev_iGrenadeActive))
				{
					set_pev(iGrenadeEnt, pev_movetype, MOVETYPE_NONE)
					set_pev(iGrenadeEnt, pev_gravity, 0.1)
					engfunc(EngFunc_DropToFloor, iGrenadeEnt)
					set_pev(iGrenadeEnt, pev_iGrenadeActive, 1)
				}
			}
			
			return PLUGIN_HANDLED
		}
		case GRENADE_BARREL:
		{
			new Float:fRadius
			new Float:fDamage
				
			TrieGetCell(weapon_StringInfo[iGrenadeId], SECTION_WEAPON_DAMAGE, fDamage)
				
			new iSPR_INDEX, iSCALE, iFRAMERATE
			new szDeathHud[64]
			new szGrenadeSound[128]
				
			TrieGetCell(iBulletConfig[iGrenadeId], SECTION_DMG_RADIUS, fRadius)
				
			TrieGetCell(iBulletConfig[iGrenadeId], SECTION_SPR_INDEX, iSPR_INDEX)
			TrieGetCell(iBulletConfig[iGrenadeId], SECTION_BULLET_SPR_FRAME, iFRAMERATE)
			TrieGetCell(iBulletConfig[iGrenadeId], SECTION_BULLET_SPR_SCALE, iSCALE)
			TrieGetString(iBulletConfig[iGrenadeId], SECTION_BULLET_SOUND, szGrenadeSound, sizeof szGrenadeSound - 1)
			TrieGetString(weapon_StringInfo[iGrenadeId], SECTION_HUD_KILL, szDeathHud, sizeof szDeathHud - 1)
				
			new iExplosionFlag
			TrieGetCell(iBulletConfig[iGrenadeId], SECTION_BULLET_FLAG, iExplosionFlag)
				
			new iRemoveEntity = 1
			new iDropGrenadeToFloor = 1
			
			if (iExplosionFlag & ACTIVE_ON_TOUCH)
				iRemoveEntity = 0
			
			if (iExplosionFlag & DETONATE_ONTOUCH)
			{
				set_pev(iGrenadeEnt, pev_fGrenadeFallStatus, 1.0)
					
				new Float:fGrenadeActiveTime 
				pev(iGrenadeEnt, pev_fGrenadeActiveTime, fGrenadeActiveTime)
					
				if (fCurrentTime >= fGrenadeActiveTime)
				{
					new iDamageBit
					TrieGetCell(iBulletConfig[iGrenadeId], SECTION_BULLET_DMGBIT, iDamageBit)
					
					new Float:fRadius 
					TrieGetCell(iBulletConfig[iGrenadeId], SECTION_DMG_RADIUS, fRadius)
					
					GrenadeDamage(iDamageType, -1, iGrenadeEnt, fRadius , fDamage, iDamageBit, szDeathHud, szGrenadeSound, iSPR_INDEX, iSCALE, iFRAMERATE, iExplosionFlag, 1)
					iDropGrenadeToFloor = 0
					iRemoveEntity = 1
				}
				else
				{
					new iCanDoDamage = 1
					
					if (is_user_alive(iToucher))
					{
						if (cs_get_user_team(iToucher) == cs_get_user_team(id) && !get_cvar_num("mp_friendlyfire"))
							iCanDoDamage = 0
							
						if (!is_movement_cause_damage(iMoveType))
							iCanDoDamage = 0
					}
					
					if (iCanDoDamage)
						GrenadeDamage(iDamageType, iToucher, iGrenadeEnt, 20.0, fDamage, DMG_CRUSH, szDeathHud, szGrenadeSound, iSPR_INDEX, iSCALE, iFRAMERATE, iExplosionFlag, iRemoveEntity)
				}
			}
			
			if ((iExplosionFlag & ACTIVE_ON_TOUCH) && !iRemoveEntity)
			{
				set_pev(iGrenadeEnt, pev_fGrenadeFallStatus, 1.0)
					
				new Float:fTime
				TrieGetCell(iBulletConfig[iGrenadeId], SECTION_BULLET_ACTIVE_TIME, fTime)
					
				set_pev(iGrenadeEnt, pev_nextthink, fCurrentTime + fTime)
			}
			
			if ((iExplosionFlag & ATTACH_ON_TOUCH) && !iRemoveEntity)
			{
				iDropGrenadeToFloor = 0
				
				if (ExecuteHamB(Ham_IsPlayer, iToucher))
				{
					if (pev(iGrenadeEnt, pev_movetype) != MOVETYPE_FOLLOW)
						set_pev(iGrenadeEnt, pev_movetype, MOVETYPE_FOLLOW)
					
					
					if (pev(iGrenadeEnt, pev_aiment) != iToucher && !pev(iGrenadeEnt, pev_iGrenadeActive))
					{
						set_pev(iGrenadeEnt, pev_aiment, iToucher)
						set_pev(iGrenadeEnt, pev_effects, EF_NODRAW)
						
						
						new Float:fNextThink
						pev(iGrenadeEnt, pev_nextthink, fNextThink)
						
						new Float:fTaskTime = fNextThink - fCurrentTime
						remove_task(iGrenadeEnt + TASK_CALL_THINK)
						
						set_task(fTaskTime, "CallEntityThink_TASK", iGrenadeEnt + TASK_CALL_THINK)
						set_pev(iGrenadeEnt, pev_iGrenadeActive, 1)
					}
						
				}
				else
				{
					set_pev(iGrenadeEnt, pev_movetype, MOVETYPE_NONE)
				}
			}
			
			if (iDropGrenadeToFloor && !iRemoveEntity)
			{
				if (!pev(iGrenadeEnt, pev_iGrenadeActive))
				{
					set_pev(iGrenadeEnt, pev_movetype, MOVETYPE_NONE)
					set_pev(iGrenadeEnt, pev_gravity, 0.1)
					engfunc(EngFunc_DropToFloor, iGrenadeEnt)
					set_pev(iGrenadeEnt, pev_iGrenadeActive, 1)
				}
			}
			
			return PLUGIN_HANDLED
		}
	}
	
	set_pev(iGrenadeEnt, pev_nextthink, fCurrentTime + 0.1)
	return PLUGIN_HANDLED
}

public CallEntityThink_TASK(TASKID)
{
	new iGrenadeEnt = TASKID - TASK_CALL_THINK
	
	if (!iGrenadeEnt || !pev_valid(iGrenadeEnt))
		return
	
	new szClassName[32]
	pev(iGrenadeEnt, pev_classname, szClassName, sizeof szClassName - 1)
	
	if (!(equal(szClassName, GRENADE_CLASS)))
		return
	
	
	new iGrenadeType = pev(iGrenadeEnt, pev_iGrenadeType)
	if (iGrenadeType != PW_CLASS_EXPLOSIVE && iGrenadeType != PW_CLASS_FLASH)
		return
	
	if (pev(iGrenadeEnt, pev_aiment))
		set_pev(iGrenadeEnt, pev_aiment, 0)
	
	if (pev(iGrenadeEnt, pev_movetype) == MOVETYPE_FOLLOW)
		set_pev(iGrenadeEnt, pev_movetype, MOVETYPE_NONE)
		
	new Float:fCurrentTime = get_gametime()
	
	set_pev(iGrenadeEnt, pev_fGrenadeActiveTime, fCurrentTime)
	set_pev(iGrenadeEnt, pev_nextthink, fCurrentTime + 0.1)
}

public fw_ArmouryTouch(iEnt, id)
{
	if (!is_user_alive(id))
		return PLUGIN_CONTINUE
			
	if (!iEnt || !pev_valid(iEnt))
		return PLUGIN_CONTINUE
		
	new iArmouryId = fm_get_weapon_id(iEnt)
	new iArmouryType = pev(iEnt, pev_ArmouryType)

	if (iArmouryType != ARMOURY_PRIMARY)
		return PLUGIN_CONTINUE
			
	if (cs_get_user_hasprim(id))
		return PLUGIN_HANDLED;
		
	if (!can_player_touch_armoury(id))
		return PLUGIN_HANDLED
		
	native_give_user_primary_wpn(id, iArmouryId)
	
	ExecuteForward(ifw_ArmouryPickedUp, ifw_Result, id, iEnt)
	engfunc(EngFunc_RemoveEntity, iEnt)
	return PLUGIN_HANDLED
}


public fw_GrenadeThink(iGrenadeEnt)
{
	if (!iGrenadeEnt || !pev_valid(iGrenadeEnt))
		return PLUGIN_CONTINUE
		
	new iGrenadeId = pev(iGrenadeEnt, pev_iGrenadeId)
	new iGrenadeType = pev(iGrenadeEnt, pev_iGrenadeType)
	
	
	if (!is_valid_grenade(iGrenadeType))
	{
		return PLUGIN_CONTINUE
	}
		
	new iDamageType = 1
		
	if (iGrenadeType == PW_CLASS_FLASH)	
		iDamageType = 2
	
	remove_task(iGrenadeEnt + TASK_CALL_THINK)
	
	switch (pev(iGrenadeEnt, pev_iGrenadePosition))
	{
		case GRENADE_UNDER_BARREL:
		{
			
			new Float:fIsFallDown
			pev(iGrenadeEnt, pev_fGrenadeFallStatus, fIsFallDown)
			
			if (fIsFallDown <= 0.0)
			{
				new Float:fThinkTime, Float:fFallDownTime
				
				TrieGetCell(weapon_StringInfo[iGrenadeId], SECTION_BULLET_REMOVE_TIME, fThinkTime)
				TrieGetCell(weapon_StringInfo[iGrenadeId], SECTION_BULLET_FALL_TIME, fFallDownTime)
				
				
				set_pev(iGrenadeEnt, pev_movetype, MOVETYPE_BOUNCE)
				set_pev(iGrenadeEnt, pev_nextthink, get_gametime() + (fThinkTime - fFallDownTime))
				set_pev(iGrenadeEnt, pev_fGrenadeFallStatus, 1.0)
				
				//	Set Angle
				new Float:fOrigin[3]
				pev(iGrenadeEnt, pev_origin, fOrigin)
				new Float:fEndOrigin[3]
				pev(iGrenadeEnt, pev_fGrenadeEndOrigin, fEndOrigin)
				
				new Float:fVecAngle[3]
				xs_vec_sub(fEndOrigin, fOrigin, fVecAngle)
				xs_vec_normalize(fVecAngle, fVecAngle)
				engfunc(EngFunc_MakeVectors, fVecAngle)
				vector_to_angle(fVecAngle, fVecAngle)
				set_pev(iGrenadeEnt, pev_angles, fVecAngle)
				
				return PLUGIN_HANDLED
			}
			
			new szGrenadeHud[32], szGrenadeSound[128]
			TrieGetString(weapon_StringInfo[iGrenadeId], SECTION_GRENADE_DEATHMSG, szGrenadeHud, sizeof szGrenadeHud - 1)
			TrieGetString(weapon_StringInfo[iGrenadeId], SECTION_BULLET_SOUND, szGrenadeSound, sizeof szGrenadeSound - 1)
				
			new iSPR_ID, iFramerate, iScale
			TrieGetCell(weapon_StringInfo[iGrenadeId], SECTION_SPR_INDEX, iSPR_ID)
			TrieGetCell(weapon_StringInfo[iGrenadeId], SECTION_BULLET_SPR_FRAME, iFramerate)
			TrieGetCell(weapon_StringInfo[iGrenadeId], SECTION_BULLET_SPR_SCALE, iScale)
			
			new Float:fRadius
			TrieGetCell(weapon_StringInfo[iGrenadeId], SECTION_GRENADE_RADIUS, fRadius)
			
			new Float:flDamage
			TrieGetCell(weapon_StringInfo[iGrenadeId], SECTION_GREN_DMG, flDamage)
					
			new iGrenadeFlag
			TrieGetCell(weapon_StringInfo[iGrenadeId], SECTION_BULLET_FLAG, iGrenadeFlag)
			
			new iDamageBit
			TrieGetCell(weapon_StringInfo[iGrenadeId], SECTION_BULLET_DMGBIT, iDamageBit)
			
			GrenadeDamage(iDamageType, -1, iGrenadeEnt, fRadius, flDamage, iDamageBit, szGrenadeHud, szGrenadeSound, iSPR_ID, iScale, iFramerate, iGrenadeFlag, 1)
		}
		case GRENADE_BARREL:
		{
			new Float:fIsFallDown
			pev(iGrenadeEnt, pev_fGrenadeFallStatus, fIsFallDown)
			
			if (fIsFallDown <= 0.0)
			{
				new Float:fThinkTime, Float:fFallDownTime
				
				TrieGetCell(iBulletConfig[iGrenadeId], SECTION_BULLET_REMOVE_TIME, fThinkTime)
				TrieGetCell(iBulletConfig[iGrenadeId], SECTION_BULLET_FALL_TIME, fFallDownTime)
				
				
				set_pev(iGrenadeEnt, pev_movetype, MOVETYPE_BOUNCE)
				set_pev(iGrenadeEnt, pev_nextthink, get_gametime() + (fThinkTime - fFallDownTime))
				set_pev(iGrenadeEnt, pev_fGrenadeFallStatus, 1.0)
				
				//	Set Angle
				new Float:fOrigin[3]
				pev(iGrenadeEnt, pev_origin, fOrigin)
				new Float:fEndOrigin[3]
				pev(iGrenadeEnt, pev_fGrenadeEndOrigin, fEndOrigin)
				
				new Float:fVecAngle[3]
				xs_vec_sub(fEndOrigin, fOrigin, fVecAngle)
				xs_vec_normalize(fVecAngle, fVecAngle)
				engfunc(EngFunc_MakeVectors, fVecAngle)
				vector_to_angle(fVecAngle, fVecAngle)
				set_pev(iGrenadeEnt, pev_angles, fVecAngle)
				
				return PLUGIN_HANDLED
			}
			
			new Float:fRadius
			new Float:fDamage
			
			TrieGetCell(weapon_StringInfo[iGrenadeId], SECTION_WEAPON_DAMAGE, fDamage)
			
			new iSPR_INDEX, iSCALE, iFRAMERATE
			new szDeathHud[64]
			new szGrenadeSound[128]
				
			TrieGetCell(iBulletConfig[iGrenadeId], SECTION_DMG_RADIUS, fRadius)
			TrieGetCell(iBulletConfig[iGrenadeId], SECTION_SPR_INDEX, iSPR_INDEX)
			TrieGetCell(iBulletConfig[iGrenadeId], SECTION_BULLET_SPR_FRAME, iFRAMERATE)
			TrieGetCell(iBulletConfig[iGrenadeId], SECTION_BULLET_SPR_SCALE, iSCALE)
			TrieGetString(iBulletConfig[iGrenadeId], SECTION_BULLET_SOUND, szGrenadeSound, sizeof szGrenadeSound - 1)
			TrieGetString(weapon_StringInfo[iGrenadeId], SECTION_HUD_KILL, szDeathHud, sizeof szDeathHud - 1)
				
			new iBulletFlag
			TrieGetCell(iBulletConfig[iGrenadeId], SECTION_BULLET_FLAG, iBulletFlag)
			
			if (iBulletFlag & ACTIVE_ON_TOUCH)
				set_pev(iGrenadeEnt, pev_fGrenadeActiveTime, get_gametime())
			
			
			new iDamageBit
			TrieGetCell(iBulletConfig[iGrenadeId], SECTION_BULLET_DMGBIT, iDamageBit)
			
			GrenadeDamage(iDamageType, -1, iGrenadeEnt, fRadius, fDamage, iDamageBit, szDeathHud, szGrenadeSound, iSPR_INDEX, iSCALE, iFRAMERATE, iBulletFlag , 1)
		}
	}
	
	return PLUGIN_HANDLED
}


public fw_DeathMSG(msg_id, msg_dest, msg_entity)
{
	new szTruncatedWeapon[33], iAttacker , iVictim
	get_msg_arg_string(4, szTruncatedWeapon, charsmax(szTruncatedWeapon))
	
	iAttacker = get_msg_arg_int(1)
	iVictim = get_msg_arg_int(2)
	
	if(!is_user_connected(iAttacker))
		return PLUGIN_CONTINUE
	
	if (!is_user_connected(iVictim))
		return PLUGIN_CONTINUE
		
	if (CheckPlayerBit(b_KilledByExplosion, iVictim))
	{
		if (equal(szTruncatedWeapon, GRENADE_CLASS))
		{
			ClearPlayerBit(b_KilledByExplosion, iVictim)
			return PLUGIN_HANDLED
		}
	}
	
	new iPrimaryWpnId = native_get_user_primary_id(iAttacker)
		
	if (iPrimaryWpnId > -1 )
	{
		new iWPN_ID = native_get_primary_real_id(iPrimaryWpnId)
		
		new iOriginalHud
		TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_UPDATE_HUD_KILL, iOriginalHud)
		
		if (iOriginalHud || get_user_weapon(iAttacker) != iWPN_ID)
			return PLUGIN_CONTINUE
			
		
		new szWeaponName[32]
		get_weaponname(iWPN_ID, szWeaponName, sizeof szWeaponName - 1)
		replace(szWeaponName, sizeof szWeaponName - 1, "weapon_", "")
		
		if(equal(szTruncatedWeapon, szWeaponName))
		{
			new szHudKill[64]
			TrieGetString(weapon_StringInfo[iPrimaryWpnId], SECTION_HUD_KILL, szHudKill, sizeof szHudKill - 1)
			set_msg_arg_string(4, szHudKill)
			return PLUGIN_CONTINUE
		}
	}
	
	return PLUGIN_CONTINUE
}

public message_weappickup(msg_id, msg_dest, msg_entity)
	return PLUGIN_HANDLED


public fw_OnTraceLine(Float:vector_start[3], Float:vector_end[3], ignored_monster, id, tracehandle)
{
	if (!is_user_alive(id))
		return
	
	new iPrimaryWpnId = native_get_user_primary_id(id)
	
	if (!native_is_valid_pw(iPrimaryWpnId))
		return
		
	if (get_user_weapon(id) != iPrimaryWpnId)
		return
		
	new iBulletType
	TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BULLET_TYPE, iBulletType)
	
	if(iBulletType == BULLET_TYPE_SHIELD_DESTRUCTION)
	{
		if (get_tr2(tracehandle, TR_iHitgroup) == HIT_SHIELD)
			set_tr2(tracehandle, TR_iHitgroup, HIT_GENERIC)
	}
}

public fw_PlayerKilled(iVictim, iKiller)
{
	if (!IsValidPlayer(iVictim))
		return
	
	remove_all_tasks(iVictim)
}

public fw_TakeDamage(iVictim, iInflictor, iAttacker, Float:fDamage, iDMG_BIT)
{
	
	if (!IsValidPlayer(iAttacker))
		return HAM_IGNORED
		
	if (!IsValidPlayer(iVictim))
		return HAM_IGNORED
		
	new iWeaponId = get_user_weapon(iAttacker)
	new iPlayerWpnFlag = get_trie_int(iPlayerInfo[iAttacker], SECTION_USER_WPN_FLAG)
	new iPrimaryWpnId = native_get_user_primary_id(iAttacker)
	
	if (!native_is_valid_pw(iPrimaryWpnId))
	{
		if (is_primary_wpn(iWeaponId))
		{
			new Float:fMulti = 1.0
			
				
			if (iPlayerWpnFlag & SP_LONG_BARREL)
				fMulti -=  SP_DMG_DOWN_BARREL
				
			if (iPlayerWpnFlag & SP_FMJ)
				fMulti += SP_DMG_UP_FMJ
				
			if (fMulti < 0.0)
				fMulti = 0.0
				
			if (is_user_bot(iAttacker) && !is_user_bot(iVictim))
				fMulti += random_float(1.0, 2.0)
		
			SetHamParamFloat(4, fDamage * fMulti)
		}
		return HAM_IGNORED
	}
	
	
	if (iWeaponId != native_get_primary_real_id(iPrimaryWpnId))
		return HAM_IGNORED
	
	new Float:fMulti = 1.0
	TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_DAMAGE, fMulti)
	
	new iBulletType 
	TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BULLET_TYPE, iBulletType)
	
	if (iPlayerWpnFlag & SP_LONG_BARREL)
		fMulti -=  SP_DMG_DOWN_BARREL
				
	if (iPlayerWpnFlag & SP_FMJ)
		fMulti += SP_DMG_UP_FMJ
				
	if (fMulti < 0.0)
		fMulti = 0.0
	
	if (!(iDMG_BIT & DMG_BULLET))
		return HAM_IGNORED
	else
	{	
		
		if (iBulletType  == BULLET_TYPE_SHOTGUN )
		{
			SetHamParamFloat(4, fMulti)
			
			new iDamageBit
			TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BULLET_DMGBIT, iDamageBit)
			SetHamParamInteger(5, iDamageBit)
			return HAM_IGNORED
		}
		else if (iBulletType  == BULLET_TYPE_EXPLOSIVE)
			return HAM_SUPERCEDE
	}
		
	
	
	if (is_user_bot(iAttacker) && !is_user_bot(iVictim))
		fMulti += random_float(1.0, 2.0)
	SetHamParamFloat(4, fDamage * fMulti)
	
	return HAM_IGNORED
}

public fw_TraceAttack(iVictim, iAttacker, Float:fDamage, Float:fDirection[3], iTraceResult, iDMG_BIT)
{
	if (!IsValidPlayer(iAttacker))
		return HAM_IGNORED
		
		
	new iPrimaryWpnId = native_get_user_primary_id(iAttacker)
	
	if (!native_is_valid_pw(iPrimaryWpnId))
		return HAM_IGNORED
		
	new iWeaponId = get_user_weapon(iAttacker)
	
	if (iWeaponId != native_get_primary_real_id(iPrimaryWpnId))
		return HAM_IGNORED
	
	new Float:fWpnDamage
	TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_DAMAGE, fWpnDamage)
			
	new iBulletType 
	TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BULLET_TYPE, iBulletType)
	
	if (!(iDMG_BIT & DMG_BULLET))
		return HAM_IGNORED
	else
	{	
		if (iBulletType == BULLET_TYPE_SHOTGUN )
		{
			SetHamParamFloat(3, fWpnDamage)
			return HAM_IGNORED
		}
		else if (iBulletType == BULLET_TYPE_EXPLOSIVE)
		{
			new Float:fVecEnd[3]
			get_tr2(iTraceResult, TR_vecEndPos, fVecEnd)
			
			new iBulletSpeed 
			TrieGetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_VELOCITY, iBulletSpeed)
			create_launcher_grenade(iAttacker, iPrimaryWpnId, 0, MOVETYPE_FLY, iBulletSpeed, iTraceResult)
			
			set_tr2(iTraceResult, TR_flFraction, 1.0)
			return HAM_SUPERCEDE
		}
	}
		
	new Float:fMulti = 1.0
	
	if (!is_user_bot(iAttacker) && is_user_bot(iVictim))
		fMulti *= random_float(0.67, 0.9)
	else if (is_user_bot(iAttacker) && !is_user_bot(iVictim))
		fMulti *= random_float(1.5, 2.0)
	SetHamParamFloat(3, fDamage * fWpnDamage * fMulti)
	return HAM_IGNORED
}

public WU_WpnPlayAnim_Pre(id, iEnt, iWeaponId, iAnim)
{
	if (!is_primary_wpn(iWeaponId))
		return PLUGIN_CONTINUE
		
	new iPrimaryWpnId = native_get_user_primary_id(id)
	
	if(iPrimaryWpnId > -1)
	{
		
		//new iBasicSetting
		//TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BASIC_SETTING, iBasicSetting)
		
		if (!native_is_primary_wpn_ads(id))
		{
			
			return PLUGIN_CONTINUE
		}
		
		new iAdsFlag 
		TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_ADS_FLAG, iAdsFlag)
		
		new iSilentState = cs_get_weapon_silen(iEnt)
		
		
			
		new iIdleAnimation = 0
		if (iWeaponId == CSW_M4A1 && !iSilentState)	
			iIdleAnimation = 7
			
		if (iAnim != iIdleAnimation)
			return PLUGIN_CONTINUE
			
			
		new iAnimation = Get_CSWPN_MaxAnimation(iWeaponId) + ANIMATION_IDLE_IRONSIGHT_3
					
		if (iSilentState)
			iAnimation += 1
										
		UT_PlayWeaponAnim(id, iAnimation)
			
		return PLUGIN_HANDLED
			
	}
	else
	{
		if (!CheckPlayerBit(bit_NormalIronSight, id))
			return PLUGIN_CONTINUE
			
		new iSilentState = cs_get_weapon_silen(iEnt)
			
		new iIdleAnimation = 0
		if (iWeaponId == CSW_M4A1 && !iSilentState)	
			iIdleAnimation = 7
			
		if (iAnim != iIdleAnimation)
			return PLUGIN_CONTINUE
			
			
		new iAnimation = Get_CSWPN_MaxAnimation(iWeaponId) + ANIMATION_IDLE_IRONSIGHT_3
					
		if (iSilentState)
			iAnimation += 1
										
		UT_PlayWeaponAnim(id, iAnimation)
			
		return PLUGIN_HANDLED
	}
	
	return PLUGIN_CONTINUE
}

public csred_WpnPrimAtk_Pre(id, iEnt, iWeaponId)
{
	if (!is_primary_wpn(iWeaponId))
		return PLUGIN_CONTINUE
		
	new iClip = cs_get_weapon_ammo(iEnt)
	
	if (iClip <= 0)
		return PLUGIN_CONTINUE
		
	new Float:fOrigin[3]
	pev(id, pev_origin, fOrigin)
	
	new iPrimaryWpnId = native_get_user_primary_id(id)
	
	new Float:fMulti_BulletSpread = 1.0

	if (!is_sniper(iWeaponId))
	{
		new iFlag = pev(id, pev_flags)
		
		new Float:fVelocity[3]							
		pev(id, pev_velocity, fVelocity)
			
		if (iFlag & FL_DUCKING)
		{			
			if (!fVelocity[0] && !fVelocity[1])
				fMulti_BulletSpread -= ACCURACY_CROUCH // Increase weapon's accuracy when you crouch
			else	fMulti_BulletSpread -= ACCURACY_CROUCH_MOVING // Decrease weapon's accuracy when you move			
		}
		else
		{
								
			if (!fVelocity[0] && !fVelocity[1])
				fMulti_BulletSpread -= ACCURACY_STAND // Default weapon accuracy
			else	fMulti_BulletSpread -= ACCURACY_RUNNING // Decrease accuracy by 15%					
		}
				
		new iFov = UT_GetPlayerFOV(id)
		
		if (iFov > 90)
			iFov = 90
		else if (iFov < 1)
			iFov = 90
			
		
		fMulti_BulletSpread -= FOV_ACCURACY_INCREASE * (90 - iFov)
		
		if (native_is_primary_wpn_ads(id))
			fMulti_BulletSpread -= ACCURACY_ADS
	}
	
	if (get_trie_int(iPlayerInfo[id], SECTION_USER_WPN_FLAG) & SP_LONG_BARREL)
		fMulti_BulletSpread -= SP_ACCURACY_UP_LB
			
	if (fMulti_BulletSpread < 0.0)
		fMulti_BulletSpread = 0.0
		
	if(iPrimaryWpnId > -1)
	{
		new iWPN_ID = native_get_primary_real_id(iPrimaryWpnId)
		
		if (iWeaponId  != iWPN_ID)
			return PLUGIN_CONTINUE
			
		
		new Float:fDelay 
		TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_FIRE_RATE, fDelay)	
			
		if (!is_sniper(iWeaponId) && !is_user_bot(id))
		{
			new Float:fBulletSpread
			TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_ACCURATE, fBulletSpread)
				
			if (fBulletSpread <= 0.0)
				fBulletSpread = UT_Get_CS_Accuracy(iWeaponId)
				
			fm_set_accuracy(iEnt, fBulletSpread * fMulti_BulletSpread)
		}
		
		
		
		if (native_is_primary_wpn_ads(id))
		{
			new iAdsFlag 
			TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_ADS_FLAG, iAdsFlag)
					
				
			new iShotAnimation = Get_CSWPN_MaxAnimation(iWeaponId) + ANIMATION_SHOOT_IRONSIGHT_3
					
			if (cs_get_weapon_silen(iEnt))
				iShotAnimation += 1
						
			UT_PlayWeaponAnim(id, iShotAnimation)
						
		}
						
		
			
		
			
			
			
			
		new iSoundId = get_trie_int(weapon_StringInfo[iPrimaryWpnId], SECTION_FIRE_SOUND_ID)
			
			
		if (!cs_get_weapon_silen(iEnt))
		{
			if (cs_get_weapon_burst(iEnt))
			{
				iSoundId = get_trie_int(weapon_StringInfo[iPrimaryWpnId], SECTION_BURST_SOUND_ID)
				spawnStaticSound( 0, fOrigin, iSoundId, VOL_NORM, ATTN_NORM, PITCH_NORM, 0)
			}
			else
			{
				spawnStaticSound( 0, fOrigin, iSoundId, VOL_NORM, ATTN_NORM, PITCH_NORM, 0)
			}	
		}
		else 
		{
			iSoundId = get_trie_int(weapon_StringInfo[iPrimaryWpnId], SECTION_SILENCER_SOUND_ID)
			spawnStaticSound( 0, fOrigin, iSoundId, VOL_NORM, ATTN_NORM, PITCH_NORM, 0)
		}
	}
	else 
	{
		new iInSpecial 
			
		if (iWeaponId == CSW_FAMAS)
		{
			iInSpecial = cs_get_weapon_burst(iEnt)
				
			spawnStaticSound( 0, fOrigin, UT_Get_CS_SoundIndex(iWeaponId, iInSpecial), VOL_NORM, ATTN_NORM, PITCH_NORM, 0)
			
		}
		else if (iWeaponId == CSW_M4A1)
		{
			iInSpecial = cs_get_weapon_silen(iEnt)
				
			spawnStaticSound( 0, fOrigin, UT_Get_CS_SoundIndex(iWeaponId, iInSpecial), VOL_NORM, ATTN_NORM, PITCH_NORM, 0)
			
		}
		else
			spawnStaticSound( 0, fOrigin, UT_Get_CS_SoundIndex(iWeaponId, 0), VOL_NORM, ATTN_NORM, PITCH_NORM, 0)
				
		if (!is_sniper(iWeaponId) && !is_user_bot(id))
		{
			new Float:fBulletSpread = UT_Get_CS_Accuracy(iWeaponId)
				
			fm_set_accuracy(iEnt, fBulletSpread * fMulti_BulletSpread)
		}
		
		if (UT_Get_CS_ADS_State(iWeaponId) && CheckPlayerBit(bit_NormalIronSight, id))
		{
			
			new iShotAnimation = Get_CSWPN_MaxAnimation(iWeaponId) + ANIMATION_SHOOT_IRONSIGHT_3
						
			if (cs_get_weapon_silen(iEnt))
				iShotAnimation += 1
							
			UT_PlayWeaponAnim(id, iShotAnimation)
		}
	}
	
	pev(id,pev_punchangle,cl_pushangle[id])	
	
	return PLUGIN_CONTINUE
}


public csred_WeaponTraceAttack(iVictim, iAttacker, Float:fDamage, Float:X, Float:Y, Float:Z, tracehandle, damagebits)
{
	new iWeaponId = get_user_weapon(iAttacker)
	
	if (!is_primary_wpn(iWeaponId))
		return
		
	new iPrimaryWpnId = native_get_user_primary_id(iAttacker)
	
	if(!native_is_valid_pw(iPrimaryWpnId))
	{
		if (UT_Get_CS_ADS_State(iWeaponId) && CheckPlayerBit(bit_NormalIronSight, iAttacker))
		{
			new Float:fOrigin[3]
			get_tr2(tracehandle, TR_vecEndPos, fOrigin)
					
			new iOrigin[3]
					
			FVecIVec(fOrigin, iOrigin)
					
			
			emessage_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			ewrite_byte(TE_WORLDDECAL)
			ewrite_coord(iOrigin[0])
			ewrite_coord(iOrigin[1])
			ewrite_coord(iOrigin[2])
			ewrite_byte(iDecal)
			emessage_end()
						
						
			emessage_begin(MSG_BROADCAST, SVC_TEMPENTITY)
			ewrite_byte(TE_GUNSHOTDECAL)
			ewrite_coord(iOrigin[0])
			ewrite_coord(iOrigin[1])
			ewrite_coord(iOrigin[2])
			ewrite_short(iAttacker)
			ewrite_byte(iDecal)
			emessage_end()
			
		}
		return
	}
	
	if (iWeaponId != native_get_primary_real_id(iPrimaryWpnId))
		return
	
	new iBulletType 
	TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BULLET_TYPE, iBulletType )
	
	if (iBulletType == BULLET_TYPE_EXPLOSIVE)
		return
		
	if (native_is_primary_wpn_ads(iAttacker))
	{
		new iAdsFlag
		TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_ADS_FLAG, iAdsFlag)
		
		
		new Float:fOrigin[3]
		get_tr2(tracehandle, TR_vecEndPos, fOrigin)
					
		new iOrigin[3]
					
		FVecIVec(fOrigin, iOrigin)
					
					
		emessage_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		ewrite_byte(TE_WORLDDECAL)
		ewrite_coord(iOrigin[0])
		ewrite_coord(iOrigin[1])
		ewrite_coord(iOrigin[2])
		ewrite_byte(iDecal)
		emessage_end()
					
					
		emessage_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		ewrite_byte(TE_GUNSHOTDECAL)
		ewrite_coord(iOrigin[0])
		ewrite_coord(iOrigin[1])
		ewrite_coord(iOrigin[2])
		ewrite_short(iAttacker)
		ewrite_byte(iDecal)
		emessage_end()
		return
		
	}
			
	if (CheckPlayerBit(g_SpecialBurstFamas, iAttacker))
	{
				
		new Float:fOrigin[3]
		get_tr2(tracehandle, TR_vecEndPos, fOrigin)
				
		new iOrigin[3]				
		FVecIVec(fOrigin, iOrigin)
					
					
		emessage_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		ewrite_byte(TE_WORLDDECAL)
		ewrite_coord(iOrigin[0])
		ewrite_coord(iOrigin[1])
		ewrite_coord(iOrigin[2])
		ewrite_byte(iDecal)
		emessage_end()
					
					
		emessage_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		ewrite_byte(TE_GUNSHOTDECAL)
		ewrite_coord(iOrigin[0])
		ewrite_coord(iOrigin[1])
		ewrite_coord(iOrigin[2])
		ewrite_short(iAttacker)
		ewrite_byte(iDecal)
		emessage_end()
	}
}
	
public csred_WpnPrimAtk_Post(id, iEnt, iWeaponId)
{
	if (!is_primary_wpn(iWeaponId))	
		return
		
	//new clip, ammo
	new Float:push[3]
	pev(id,pev_punchangle,push)
	xs_vec_sub(push,cl_pushangle[id],push)
	
	new iPrimaryWpnId = native_get_user_primary_id(id)
	new iPlayerWpnFlag = get_trie_int(iPlayerInfo[id], SECTION_USER_WPN_FLAG)
	
	new iFlag = pev(id, pev_flags)
			
	new Float:fRecoil_Multi = 1.0
	new Float:fDelay_Multi = 1.0
	
	if (iFlag & FL_DUCKING)
	{
		new Float:fVelocity[3]
								
		pev(id, pev_velocity, fVelocity)
							
		if (!fVelocity[0] && !fVelocity[1])
			fRecoil_Multi -= RECOIL_CROUCH // Decrease recoil by 20% when you crouch
		else	fRecoil_Multi -= RECOIL_CROUCH_MOVING// Increase recoil by 15% when you crouch and move			
	}
	else
	{
		new Float:fVelocity[3]
							
		pev(id, pev_velocity, fVelocity)
						
		if (!fVelocity[0] && !fVelocity[1])
			fRecoil_Multi -= RECOIL_STAND // Weapon recoil doesn't change when you stand without moving
		else	fRecoil_Multi -= RECOIL_RUNNING // Weapon recoil increase by 25% when you running					
	}
			
	if(iPrimaryWpnId > -1)
	{
		if (iWeaponId == native_get_primary_real_id(iPrimaryWpnId))
		{
			new Float:fRecoil 
			TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_RECOIL, fRecoil)
			
			new Float:fDelay 
			TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_FIRE_RATE, fDelay)
			
			new iAdsConfig
			TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_ADS_FLAG, iAdsConfig)
			
			if (!CheckPlayerBit(g_LauncherModeActivated, id))
			{
				
				/*				RECOIL STUFF				*/
					
				if (iPlayerWpnFlag & SP_ADJUSTABLE_STOCK)
					fRecoil_Multi -= SP_RECOIL_DOWN_STOCK
						
					
				if (fRecoil_Multi < 0.0)
					fRecoil_Multi = 0.0
							
				if (native_is_primary_wpn_ads(id))
				{
					if (iAdsConfig & ADS_NEW_RECOIL)
						TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_ADS_RECOIL, fRecoil)
					else
						fRecoil_Multi -= SP_RECOIL_DOWN_ADS
					
					if (iAdsConfig & ADS_NEW_ROF)
						TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_ADS_ROF, fDelay)
				}
					
				if (fRecoil_Multi < 0.0)
					fRecoil_Multi = 0.0
						
				xs_vec_mul_scalar(push, fRecoil * fRecoil_Multi,push)
					
				/************************************************************************/
					
				/*				SPECIAL BULLETS				*/
				new iBulletType 
				TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BULLET_TYPE, iBulletType)
						
				switch (iBulletType )
				{
					case  BULLET_TYPE_SHOTGUN:
					{
						new iShotgunPiece
						new Float:fShotgunSpread
						new Float:fWpnDamage
								
						TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_DAMAGE, fWpnDamage)
						TrieGetCell(iBulletConfig[iPrimaryWpnId], SECTION_SHOTGUN_PIECE, iShotgunPiece)
						TrieGetCell(iBulletConfig[iPrimaryWpnId], SECTION_SHOTGUN_SPREAD, fShotgunSpread)
								
						new iDamageBit
						TrieGetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_DMGBIT, iDamageBit)
						UT_CreateShotgunBullet(id, iEnt, iShotgunPiece, fShotgunSpread, iDamageBit, fWpnDamage, 500.0)
					}
					case BULLET_TYPE_EXPLOSIVE:
					{
						new iBulletFlag 
						TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BULLET_FLAG, iBulletFlag)
								
						if (!(iBulletFlag & DIRECTION_BY_TRACE))
						{
							new iVelocity
								
							TrieGetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_VELOCITY, iVelocity)
							create_launcher_grenade(id, iPrimaryWpnId, 0, MOVETYPE_FLY, iVelocity, 0)
						}
					}
				}
				
				/************************************************************************/
				
				new iBasicSetting
				TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BASIC_SETTING, iBasicSetting)
				
					
						
				if (iPlayerWpnFlag & SP_RAPID_FIRE)
					fDelay_Multi -= SP_SPEED_UP_RP
						
				if (fDelay_Multi <= 0.0)
					fDelay_Multi = 1.0
						
				fm_set_next_attack(id, fDelay * fDelay_Multi)
				set_pdata_float(iEnt, m_flNextPrimaryAttack, fDelay, 4)
					
					
				/*					MINIGUN STUFF					*/
					
				new iFireFlag
				TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_WPN_FIRE_FLAG, iFireFlag)
					
				if (iFireFlag & FIRE_MINIGUN)
				{
					new Float:fSpinTime 
					TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_SPIN_TIME, fSpinTime)
						
					set_trie_float(iPlayerInfo[id], SECTION_ATTACK_TIME, get_gametime() + fSpinTime)
						
					if (iFireFlag & FIRE_DRAW_AFTER_SPIN_ANIM)
					{
						new iSpinAnimation = Get_CSWPN_MaxAnimation(iWeaponId)
										
						iSpinAnimation += ANIM_SPIN_POST
										
						if (cs_get_weapon_silen(iEnt))
							iSpinAnimation += 1
											
						UT_PlayWeaponAnim(id, iSpinAnimation)
					}
				}
					
				/****************************************************************************************/
					
				if (CheckPlayerBit(g_SemiAutomaticMode, id))
				{
					client_cmd(id, "-attack")
					engclient_cmd(id, "-attack")
						
				}
					
				if (native_get_primary_wpn_special(iPrimaryWpnId) == SPECIAL_REACTIVE_ZOOM)
				{
					fm_set_last_zoom(id, UT_GetPlayerFOV(id))
					fm_set_resume_zoom(id, true)
					UT_SetPlayerFOV(id, 90)
				}
					
					
			}
			else	
			{
				new Float:fRecoil
				TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_GRENADE_RECOIL, fRecoil)
					
				xs_vec_mul_scalar(push, fRecoil,push)
			}
			
			
			xs_vec_add(push,cl_pushangle[id],push)
			set_pev(id,pev_punchangle,push)
			
		}
	}
	else
	{
		new Float:fRecoil = 1.0
		new Float:fDelay = UT_Get_CS_ROF(iWeaponId)
		
		if (native_is_primary_wpn_ads(id))
		{
			fRecoil = UT_Get_CS_Recoil_Ads(iWeaponId)
			fDelay = UT_Get_CS_ROF_ADS(iWeaponId)
		}
			
		if (iPlayerWpnFlag & SP_ADJUSTABLE_STOCK)
			fRecoil_Multi -= SP_RECOIL_DOWN_STOCK
			
		if (fRecoil_Multi < 0.0)
			fRecoil_Multi = 0.0
			
		xs_vec_mul_scalar(push, fRecoil * fRecoil_Multi ,push)
		xs_vec_add(push,cl_pushangle[id],push)
		set_pev(id,pev_punchangle,push)
		
		if (UT_Get_CS_SemiWpn(iWeaponId))
		{
			console_cmd(id, "-attack")
			engclient_cmd(id, "-attack")
		}
		
		if (iPlayerWpnFlag & SP_RAPID_FIRE)
			fDelay_Multi -= SP_SPEED_UP_RP
		
		if (fDelay_Multi <= 0.0)
			fDelay_Multi = 1.0
			
		fm_set_next_attack(id, fDelay * fDelay_Multi)
				
	}
	return
}

public csred_WpnAttachToPlayerPost(id, iEnt, iWeaponId)
{
	if (!is_user_alive(id))
		return
		
	if (!is_primary_wpn(iWeaponId))
		return
		
	new iPrimaryWpnId = native_get_user_primary_id(id)
	
	if (iPrimaryWpnId > -1 &&  iWeaponId == native_get_primary_real_id(iPrimaryWpnId))
	{
		new iBackSub = get_trie_int(weapon_StringInfo[iPrimaryWpnId], SECTION_BACKWPN_SUB)
		
		if (iBackSub > -1)
		{
			new szBackModel[128]
			TrieGetString(weapon_StringInfo[iPrimaryWpnId], SECTION_BACK_MODEL, szBackModel, sizeof szBackModel - 1)
			
			engfunc(EngFunc_SetModel, iEnt, szBackModel)
			set_pev(iEnt, pev_body, iBackSub)
			fm_set_entity_visibility(iEnt, 1)
		}
		
		new iClip = native_get_primary_wpn_ammo(iPrimaryWpnId, id)
		new iBpa = native_get_primary_wpn_bpammo(iPrimaryWpnId)
		new szWeaponClass[64]
		TrieGetString(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_CLASS, szWeaponClass, sizeof szWeaponClass - 1)
		UT_UpdateWpnList(id, iWeaponId, iClip , szWeaponClass, iBpa, 0)
		
	}
	else
	{
		new szWeaponName[32]
	
		get_weaponname(iWeaponId, szWeaponName, sizeof szWeaponName - 1)
	
		new iClip =  UT_Get_CS_DefaultClip(iWeaponId)
		cs_set_weapon_ammo(iEnt, iClip)
		new iBpa = UT_Get_CS_DefaultBpa(iWeaponId)
		UT_UpdateWpnList(id, iWeaponId, iClip  , szWeaponName, iBpa, 0)
	}
}

public csred_WpnDeploy_Pre(id, iEnt, iWeaponId)
{
	if (!is_user_alive(id))
	{
		if (is_primary_wpn(iWeaponId))
			return PLUGIN_HANDLED
			
		return PLUGIN_CONTINUE
	}
	if (!is_primary_wpn(iWeaponId))
	{
		delete_trie_key(iPlayerInfo[id], SECTION_ATTACK_STAGE)
		delete_trie_key(iPlayerInfo[id], SECTION_USER_ZOOM_LVL)
		
		
		ClearPlayerBit(g_UsingZoomLen, id);
		ClearPlayerBit(g_LaserSightON, id);
		ClearPlayerBit(bit_NormalIronSight, id);
		ClearPlayerBit(g_CancelReloading, id);	
		
		
		remove_all_tasks(id)
		
		do_active_nvg(id, 0)
		
		return PLUGIN_CONTINUE
	}
	
	delete_trie_key(iPlayerInfo[id], SECTION_USER_ZOOM_LVL)
	
	if (UT_GetPlayerFOV(id) != 90)
		UT_SetPlayerFOV(id, 90)
	
	remove_task(id + TASK_CROSSHAIR_TOGGLE)
	
	//	Weapon is just only deployed | Engine knows that it cant be reloaded right now
	
	fm_set_weapon_reload(iEnt, 0)
	
	new iParam[3]	
	
	/*	NORMAL PRIMARY WPN	*/
	
	new iPrimaryWpnId = native_get_user_primary_id(id)
	
	if (!native_is_valid_pw(iPrimaryWpnId) || native_get_primary_real_id(iPrimaryWpnId) != iWeaponId)
	{
		//	Minigun is not ready
		delete_trie_key(iPlayerInfo[id], SECTION_ATTACK_STAGE)
		
		ClearPlayerBit(g_UsingZoomLen, id);
		ClearPlayerBit(g_LaserSightON, id);
		ClearPlayerBit(bit_NormalIronSight, id);
		ClearPlayerBit(g_CancelReloading, id);	
		
		remove_all_tasks(id)
		
		do_active_nvg(id, 0)
		
		iParam[0] =~ ST_NO_CROSSHAIR
		iParam[1] = iWeaponId
		iParam[2] = iEnt
		
		UT_CS_Crosshair_Toggle(id, UT_Get_CS_Crosshair(iWeaponId), 1)
		remove_task(id + TASK_CROSSHAIR_TOGGLE)
		set_task(0.1, "ToggleCrosshair_TASK", id + TASK_CROSSHAIR_TOGGLE, iParam, 3)
		
		DefaultDeploy(id, iEnt, iWeaponId)
		
		return PLUGIN_HANDLED
	}
	
	//	Minigun is not ready
	delete_trie_key(iPlayerInfo[id], SECTION_ATTACK_STAGE)
		
	ClearPlayerBit(g_UsingZoomLen, id);
	ClearPlayerBit(g_LaserSightON, id);
	ClearPlayerBit(bit_NormalIronSight, id);
	ClearPlayerBit(g_CancelReloading, id);	
	
	remove_all_tasks(id)

	do_active_nvg(id, 0)		
	
	new iBasicSetting
	TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BASIC_SETTING, iBasicSetting)
	
	iParam[0] = iBasicSetting
	iParam[1] = iWeaponId
	iParam[2] = iEnt
	
	remove_task(id + TASK_CROSSHAIR_TOGGLE)
	set_task(0.1, "ToggleCrosshair_TASK", id + TASK_CROSSHAIR_TOGGLE, iParam, 3)
	
	
	/*******************************************/
	//	From DefaultDeploy
	
	new iShield = cs_get_user_shield(id)
	new iSilen = cs_get_weapon_silen(iEnt)
	
	new szSequence[32]
	UT_GetWeaponExtension(iWeaponId, 0, szSequence, sizeof szSequence - 1)			
	UT_SetPlayerSequence(id, szSequence)
	
	new iDrawAnimation = Get_CSWPN_Anim_Draw(iWeaponId, iSilen, iShield)
	UT_PlayWeaponAnim(id, iDrawAnimation)
	
	new Float:fDeployTime 
	TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_DEPLOY, fDeployTime)
	
	fm_set_next_attack(id, fDeployTime)
	set_pdata_float(iEnt, m_flNextPrimaryAttack, fDeployTime, 4)
	set_pdata_float(iEnt, m_flTimeWeaponIdle, fDeployTime, 4)
	set_pdata_float(iEnt, m_flDecreaseShotsFired, get_gametime(), 4)
	
	set_pdata_bool(id, m_fResumeZoom, false, 5)
	set_pdata_int(id, m_iLastZoom, 90, 5)
	
	/*******************************************/
	
	set_pev(id, pev_weaponmodel2, "")
	
	new szModelBuffer[256], iModelSubBody
	
	TrieGetString(weapon_StringInfo[iPrimaryWpnId], SECTION_V_MODEL, szModelBuffer, sizeof szModelBuffer - 1)
	set_pev(id, pev_viewmodel2, szModelBuffer)
	
	
	TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_V_SUB, iModelSubBody)
	set_v_SubBody(id, iModelSubBody)
		
	TrieGetString(weapon_StringInfo[iPrimaryWpnId], SECTION_P_MODEL, szModelBuffer, sizeof szModelBuffer - 1)
	engfunc(EngFunc_SetModel, iEnt, szModelBuffer)
	fm_set_entity_visibility(iEnt, 1)					
	
	TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_P_SUB, iModelSubBody)
	set_pev(iEnt, pev_body,  iModelSubBody)
	
	if (native_get_primary_wpn_type(iPrimaryWpnId) == TYPE_SHIELD)
		set_user_shield(id, iEnt, 1)
		
	return PLUGIN_HANDLED
}

public TFM_RemovePlayItem_Pre(id, iEnt, iWeaponId)
{
	if (!is_primary_wpn(iWeaponId))
		return
		
	
	ClearPlayerBit(g_CancelReloading, id);	
	
	new iPrimaryWpnId = native_get_user_primary_id(id)
	
	if (iPrimaryWpnId > -1)
	{
		if (native_get_primary_real_id(iPrimaryWpnId) != iWeaponId)
			do_active_nvg(id, 0)
		else	do_active_nvg(id, 1)
		
		ClearPlayerBit(g_UsingZoomLen, id);
		ClearPlayerBit(g_LaserSightON, id);
		remove_all_tasks(id)
		
		
		delete_trie_key(iPlayerInfo[id], SECTION_ATTACK_STAGE)
		delete_trie_key(iPlayerInfo[id], SECTION_ATTACK_TIME)
	
	
	}
	else
	{
		ClearPlayerBit(bit_NormalIronSight, id);
		remove_all_tasks(id)
	}
	
	fm_set_entity_visibility(iEnt, 0)
}

public csred_WpnHolster_Post(id, iEnt)
{
	new iWeaponId = cs_get_weapon_id(iEnt)
	
	if (!is_primary_wpn(iWeaponId))
		return
	
	new iPrimaryWpnId = native_get_user_primary_id(id)
	
	if (iPrimaryWpnId > -1 && native_get_primary_real_id(iPrimaryWpnId) == iWeaponId)
	{
		delete_trie_key(iPlayerInfo[id], SECTION_ATTACK_STAGE)
		delete_trie_key(iPlayerInfo[id], SECTION_ATTACK_TIME)
		
		ClearPlayerBit(g_UsingZoomLen, id);
		ClearPlayerBit(g_LaserSightON, id);	
		ClearPlayerBit(g_LauncherModeActivated, id);
		
		
		remove_all_tasks(id)
		
		do_active_nvg(id, 0)
		
		new iBackSub = get_trie_int(weapon_StringInfo[iPrimaryWpnId], SECTION_BACKWPN_SUB)
		if (iBackSub > -1)
		{
			new szBackModel[128]
			TrieGetString(weapon_StringInfo[iPrimaryWpnId], SECTION_BACK_MODEL, szBackModel, sizeof szBackModel - 1)
			
			engfunc(EngFunc_SetModel, iEnt, szBackModel)
			set_pev(id, pev_body, iBackSub)
			fm_set_entity_visibility(iEnt, 1)
		}
		else	fm_set_entity_visibility(iEnt, 0)
		
		if (native_get_primary_wpn_type(iPrimaryWpnId) == TYPE_SHIELD)
			set_user_shield(id, iEnt, 0)
			
		
	}
	else
	{
		
		ClearPlayerBit(bit_NormalIronSight, id);
		ClearPlayerBit(g_CancelReloading, id);
		remove_task(id + TASK_NORMAL_IRONSIGHT)
		remove_task(id - TASK_NORMAL_IRONSIGHT)
		
		if (BackWeapon_iSubBody[iWeaponId] > -1)
		{
			engfunc(EngFunc_SetModel, iEnt, BackWeapon_szModel[iWeaponId])
			set_pev(id, pev_body, BackWeapon_iSubBody[iWeaponId])
			fm_set_entity_visibility(iEnt, 1)
		}
		else
			fm_set_entity_visibility(iEnt, 0)
	}
}


public ToggleCrosshair_TASK(iParam[3], TASKID)
{
	new id = TASKID - TASK_CROSSHAIR_TOGGLE
	
	if (!is_user_alive(id))
		return
		
	new iEnt = fm_get_active_item(id)
	
	if (!pev_valid(iEnt))
		return
		
	new iWeaponId = cs_get_weapon_id(iEnt)
	
	if (iEnt != iParam[2])
		return
		
	if (!is_primary_wpn(iWeaponId))
		return
	
	new iPrimaryWpnId = native_get_user_primary_id(id) 
	if (iPrimaryWpnId < - 1 || native_get_primary_real_id(iPrimaryWpnId) != iWeaponId)
	{
		return
		
	}
	if (iCheckSniper(iWeaponId))
		return
	
	new iHideEngineCrosshair = 1
	
	
	if (!(iParam[0] & ST_NO_CROSSHAIR))
		UT_CS_Crosshair_Toggle(id, 1, iHideEngineCrosshair)
	else	UT_CS_Crosshair_Toggle(id, 0, 1)
	
	UT_SendCurWeaponMsg(id, 1, iWeaponId, cs_get_weapon_ammo(iEnt), 1)
}

public csred_WpnSecAtk_Pre(id, iEnt, iWeaponId)
{
	if (!is_primary_wpn(iWeaponId))
		return PLUGIN_CONTINUE
	
	if (native_get_user_primary_id(id) < 0)
	{
		if (iWeaponId != CSW_FAMAS && iWeaponId != CSW_M4A1)
			return PLUGIN_CONTINUE
		else	
		{
			cs_set_weapon_silen(iEnt, 0, 0)
			UT_set_weapon_burst(iEnt, 0)
		}
	}
	return PLUGIN_HANDLED
}

public csred_WpnReload_Post(id, iEnt, iWeaponId)
{
	if (!is_primary_wpn(iWeaponId))
		return 
		
		
	ClearPlayerBit(b_ExtraBulletInChamber, id)
	
	UT_SetPlayerFOV(id, 90)
	
	fm_set_weapon_reload(iEnt, 1)
	fm_set_resume_zoom(id, false)
	
	ClearPlayerBit(g_UsingZoomLen, id)
	
	remove_task(id + TASK_FAMAS_BURST)
	
	UT_CS_Crosshair_Toggle(id, 0, 1)
	
	new iPrimaryWpnId = native_get_user_primary_id(id)
	
	if (iPrimaryWpnId >= 0)
	{
		delete_trie_key(iPlayerInfo[id], SECTION_ATTACK_STAGE)
		
		
		new Float:fReloadTime 
		TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_RELOAD_TIME, fReloadTime)
		
		new iBasicSetting
		TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BASIC_SETTING, iBasicSetting)
		
		if (iWeaponId == native_get_primary_real_id(iPrimaryWpnId))
		{
			
			
			if (!(iBasicSetting & ST_NEW_RELOAD) && (iBasicSetting & ST_ADDITION_BULLET))
			{
				if (cs_get_weapon_ammo(iEnt))
				{
					if (!CheckPlayerBit(b_ExtraBulletInChamber, id))	
						SetPlayerBit(b_ExtraBulletInChamber, id)
				}
			}
			if (CheckPlayerBit(g_CancelReloading, id))
				ClearPlayerBit(g_CancelReloading, id)
			
			delete_trie_key(iPlayerInfo[id], SECTION_USER_ZOOM_LVL)
			
			
			new iWPN_FUNC = native_get_primary_wpn_func(iPrimaryWpnId)
			
			
			if (iWPN_FUNC & FUNC_ADS)
				reset_view_model(id, iPrimaryWpnId)
			
			if (is_shotgun(iWeaponId))
				fm_set_weapon_special_reload(iEnt, 0)
				
			if (!(iBasicSetting & ST_NEW_RELOAD))
			{
				fm_set_next_attack(id, fReloadTime)
				set_pdata_float(iEnt, m_flNextPrimaryAttack, fReloadTime, 4)
			}
			else
			{
				if (CheckPlayerBit(g_CancelReloading, id))	
					ClearPlayerBit(g_CancelReloading, id)
					
				fm_set_next_attack(id, INFINITIVE_RELOAD_TIME)
				set_pdata_float(iEnt, m_flNextPrimaryAttack, INFINITIVE_RELOAD_TIME, 4)
				
				if (task_exists(id + TASK_INSERT_AMMO))
					remove_task(id + TASK_INSERT_AMMO)
					
				if (task_exists(id + TASK_ADD_WEAPON_AMMO))
					remove_task(id + TASK_ADD_WEAPON_AMMO)
					
				set_task(fReloadTime, "InsertAmmo_TASK", id + TASK_INSERT_AMMO)
				
			}
			
			UT_PlayWeaponAnim(id, Get_CSWPN_Anim_Reload(iWeaponId, 0, 0))
		}
	}
	else
	{
		if (cs_get_weapon_ammo(iEnt))
		{
			if (!is_shotgun(iWeaponId))
			{
				if (!CheckPlayerBit(b_ExtraBulletInChamber, id))	
					SetPlayerBit(b_ExtraBulletInChamber, id)
			}
		}
			
		if (UT_Get_CS_ADS_State(iWeaponId))
			ClearPlayerBit(bit_NormalIronSight, id)
		
		if (UT_Get_CS_ReloadType(iWeaponId) != 0)
		{
			
			if (CheckPlayerBit(g_CancelReloading, id))	
				ClearPlayerBit(g_CancelReloading, id)
				
			fm_set_weapon_reload(iEnt, 0)
			fm_set_next_attack(id, 	INFINITIVE_RELOAD_TIME)
			set_pdata_float(iEnt, m_flTimeWeaponIdle, INFINITIVE_RELOAD_TIME, 4)
			set_pdata_float(iEnt, m_flNextPrimaryAttack, INFINITIVE_RELOAD_TIME, 4)
			
			if (task_exists(id + TASK_INSERT_AMMO))
				remove_task(id + TASK_INSERT_AMMO)
					
			if (task_exists(id + TASK_ADD_WEAPON_AMMO))
				remove_task(id + TASK_ADD_WEAPON_AMMO)
				
			  
			new Float:fStartReloadTime = UT_Get_CS_Reload_Time(iWeaponId)
			
			set_task(fStartReloadTime, "InsertAmmo_TASK", id + TASK_INSERT_AMMO)
			fm_set_weapon_reload(iEnt, 1)
				
		}
		else
		{
			new Float:flReloadTime = UT_Get_CS_Reload_Time(iWeaponId)
			fm_set_next_attack(id, flReloadTime)
			set_pdata_float(iEnt, m_flNextPrimaryAttack, flReloadTime, 4)
		}
		
		UT_PlayWeaponAnim(id, Get_CSWPN_Anim_Reload(iWeaponId, 0, 0))
	}
	return 
}
	
	
/*					RELOAD [SHOTGUN]				*/

public InsertAmmo_TASK(TASKID)
{
	new id = TASKID - TASK_INSERT_AMMO
	
	if (!is_user_alive(id) )
		return
	
	
	
	new iWeaponId = get_user_weapon(id)
	
	new Float:fInsertTime
	new iMaxClip
	
	new iAnim_InsertBullet
	
	new iPrimaryWpnId = native_get_user_primary_id(id)
	
	new iEnt = fm_get_active_item(id)
	
	if (!pev_valid(iEnt))
		return
	
	if (!CheckPlayerBit(g_CancelReloading, id))
	{
		if (is_shotgun(iWeaponId))
			iAnim_InsertBullet = insert
		else iAnim_InsertBullet = Get_CSWPN_MaxAnimation(iWeaponId) + ANIMATION_INSERT_BULLET
			
		if (!native_is_valid_pw(iPrimaryWpnId))
		{
			new iPlayerWpnFlag = get_trie_int(iPlayerInfo[id] , SECTION_USER_WPN_FLAG)
			
			iMaxClip = UT_Get_CS_DefaultClip(iWeaponId)
			if (iPlayerWpnFlag & SP_EXTENDED_CLIP)
				iMaxClip += 5
			
			fInsertTime = UT_Get_CS_Start_IS(iWeaponId)
			
				
		}
		else
		{
			if (iWeaponId != native_get_primary_real_id(iPrimaryWpnId))
				return
				
			TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_INSERT_TIME, fInsertTime)
			iMaxClip = native_get_primary_wpn_ammo(iPrimaryWpnId, id)
			
		}
		
		
		
		if (cs_get_weapon_ammo(iEnt) >= iMaxClip)
		{
			AddAmmoToWeapon_TASK(id + TASK_ADD_WEAPON_AMMO)
			return
		}
		
		
		if (cs_get_weapon_silen(iEnt))
			iAnim_InsertBullet += ANIM_SILENCER_ADD
			
		UT_PlayWeaponAnim(id, iAnim_InsertBullet)
		
		
		set_task(fInsertTime, "AddAmmoToWeapon_TASK", id + TASK_ADD_WEAPON_AMMO)
	}
	else
	{
		new iAnimation_Finish
		new Float:fFinishTime
		
		if (is_shotgun(iWeaponId))
			iAnimation_Finish = after_reload
		else
		{
			iAnimation_Finish = Get_CSWPN_MaxAnimation(iWeaponId) + ANIMATION_FINISH_RELOAD
			if (cs_get_weapon_silen(iEnt))
				iAnimation_Finish += ANIM_SILENCER_ADD
		}
			
		if (!native_is_valid_pw(iPrimaryWpnId))
			fFinishTime = UT_Get_CS_Finish_IS(iWeaponId)
		else
		{
			if (iWeaponId != native_get_primary_real_id(iPrimaryWpnId))
				return
			
			TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_AF_INSERT_TIME, fFinishTime)
		}
		tfm_start_finish_reload_task(id, iEnt, iAnimation_Finish, fFinishTime)
		return
	}
	
}

public AddAmmoToWeapon_TASK(TASKID)
{
	new id = TASKID - TASK_ADD_WEAPON_AMMO
	
	if (!is_user_alive(id))
		return
	
	new iEnt = fm_get_active_item(id)
	
	if (!pev_valid(iEnt))
		return
		
	new iWeaponId = get_user_weapon(id)
	
	new Float:fInsertTime
	new Float:fFinishTime
	
	new iMaxClip
	
	new iAnimation_Insert
	new iAnimation_Finish
	
	new iPrimaryWpnId = native_get_user_primary_id(id)
	
	if (is_shotgun(iWeaponId))
	{
		iAnimation_Insert = insert
		iAnimation_Finish = after_reload
	}
	else
	{
		iAnimation_Insert = Get_CSWPN_MaxAnimation(iWeaponId) + ANIMATION_INSERT_BULLET
		iAnimation_Finish = Get_CSWPN_MaxAnimation(iWeaponId) + ANIMATION_FINISH_RELOAD
		if (cs_get_weapon_silen(iEnt))
			iAnimation_Finish += ANIM_SILENCER_ADD
	}
		
	if (!native_is_valid_pw(iPrimaryWpnId))
	{
		new iPlayerWpnFlag = get_trie_int(iPlayerInfo[id] , SECTION_USER_WPN_FLAG)
		
		iMaxClip = UT_Get_CS_DefaultClip(iWeaponId)
		if (iPlayerWpnFlag & SP_EXTENDED_CLIP)
			iMaxClip += 5
			
		fInsertTime = UT_Get_CS_Start_IS(iWeaponId)
		fFinishTime = UT_Get_CS_Finish_IS(iWeaponId)
	}
	else
	{
		if (iWeaponId != native_get_primary_real_id(iPrimaryWpnId))
			return
			
		iMaxClip = native_get_primary_wpn_ammo(iPrimaryWpnId, id)
		TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_INSERT_TIME, fInsertTime)
		TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_AF_INSERT_TIME, fFinishTime)
		
		
		
	}
	
		
	new iBpAmmo ; iBpAmmo = UT_GetUserBPA(id, iWeaponId)
	new iClip ; iClip = cs_get_weapon_ammo(iEnt)
	
		
	if (iClip + 1 <= iMaxClip && iBpAmmo)
	{
		cs_set_weapon_ammo(iEnt, iClip + 1)
		UT_SetUserBPA(id, iWeaponId,  iBpAmmo-1)
		
		iClip++
		
		if (iClip >= iMaxClip)
		{
			tfm_start_finish_reload_task(id, iEnt, iAnimation_Finish, fFinishTime)
			return
		}
		
		if (cs_get_weapon_silen(iEnt))
			iAnimation_Insert += ANIM_SILENCER_ADD
		
		UT_PlayWeaponAnim(id, iAnimation_Insert)
		
		
		set_task(fInsertTime, "AddAmmoToWeapon_TASK", id + TASK_ADD_WEAPON_AMMO)
	}
	else
		tfm_start_finish_reload_task(id, iEnt, iAnimation_Finish, fFinishTime)
}

stock tfm_start_finish_reload_task(id, iEnt, iAnimation_Finish, Float:fFinishTime)
{
	UT_PlayWeaponAnim(id, iAnimation_Finish)
			
	fm_set_next_attack(id, INFINITIVE_RELOAD_TIME)
			
	if (task_exists(id + TASK_FINISH_RELOAD_AMMO))
		remove_task(id + TASK_FINISH_RELOAD_AMMO)
			
	set_task(fFinishTime, "FinishReloadWeapon_TASK", id + TASK_FINISH_RELOAD_AMMO)
	set_pdata_float(iEnt, m_flTimeWeaponIdle,  fFinishTime, 4)
}

public FinishReloadWeapon_TASK(TASKID)
{
	new id = TASKID - TASK_FINISH_RELOAD_AMMO
	
	if (!is_user_alive(id))
		return
		
	new iWeaponId = get_user_weapon(id)
	
	new iPrimaryWpnId = native_get_user_primary_id(id)
	
	if (!native_is_valid_pw(iPrimaryWpnId))
	{
		if (!is_shotgun(iWeaponId))
			return
			
		UT_CS_Crosshair_Toggle(id, UT_Get_CS_Crosshair(iWeaponId), 1)
	}
	else
	{
		if (iWeaponId != native_get_primary_real_id(iPrimaryWpnId))
		{
			UT_CS_Crosshair_Toggle(id, UT_Get_CS_Crosshair(iWeaponId), 1)
			return
		}
	}
	
	new iEnt = fm_get_active_item(id)
	
	if (!pev_valid(iEnt))
		return
	
	
	fm_set_next_attack(id, 0.5)
	set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.5, 4)
	set_pdata_float(iEnt, m_flNextSecondaryAttack, 0.5, 4)
	
	fm_set_weapon_reload(iEnt, 0)
	
	if (is_shotgun(iWeaponId))
		fm_set_weapon_special_reload(iEnt, 0)
	
	if (CheckPlayerBit(g_CancelReloading, id))	
		ClearPlayerBit(g_CancelReloading, id)
		
	if (!iCheckSniper(iWeaponId) && iPrimaryWpnId > -1)
	{
		new iBasicSetting
		TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BASIC_SETTING, iBasicSetting)
		
		new iHideEngineCrosshair = 1
		
			
		if (!(iBasicSetting & ST_NO_CROSSHAIR))
			UT_CS_Crosshair_Toggle(id, 1, iHideEngineCrosshair)
		else
			UT_CS_Crosshair_Toggle(id, 0, 1)
			
			
		
	}
}

/****************************************************************************************/

public csred_WpnPostFrame(id, iEnt, iWeaponId)
{
	if (!is_primary_wpn(iWeaponId))
		return
			
	new fInReload ; fInReload = fm_get_weapon_reload(iEnt)
	new Float:flNextAttack ; flNextAttack = fm_get_next_attack(id)

	
	new iBpAmmo ; iBpAmmo = UT_GetUserBPA(id, iWeaponId)
	new iClip ; iClip = cs_get_weapon_ammo(iEnt)
	
	new iPrimaryWpnId = native_get_user_primary_id(id)
	
	if (!native_is_valid_pw(iPrimaryWpnId))
	{
		new iMaxClip ; iMaxClip = UT_Get_CS_DefaultClip(iWeaponId)
		if(fInReload && flNextAttack <= 0.0 )
		{
			if (CheckPlayerBit(b_ExtraBulletInChamber, id))
			{
				if (iWeaponId != CSW_M249 && iWeaponId != CSW_M3 && iWeaponId != CSW_XM1014)
					iMaxClip += 1
			}
			new j = min(iMaxClip - iClip, iBpAmmo)
			
			cs_set_weapon_ammo(iEnt, iClip + j)
			
			if (j < 0)
				j = 0
			
			if (!is_user_bot(id))
				UT_SetUserBPA(id, iWeaponId, iBpAmmo-j)
			
			if (is_shotgun(iWeaponId))
				fm_set_weapon_special_reload(iEnt, 0)
				
			fm_set_weapon_reload(iEnt, 0)
			
			fInReload = 0
			
			if (!iCheckSniper(iWeaponId))
				UT_CS_Crosshair_Toggle(id, UT_Get_CS_Crosshair(iWeaponId), 1)
				
			
				
		}
		
		/*
		new szSequence[32]
		UT_GetWeaponExtension(iWeaponId, 0, szSequence, sizeof szSequence - 1)
		UT_SetPlayerSequence(id, szSequence) 
		*/
		
	}
	else
	{
		new iMaxClip 
		
		iMaxClip = native_get_primary_wpn_ammo(iPrimaryWpnId, id)
		
		if (get_trie_int(iPlayerInfo[id], SECTION_USER_WPN_FLAG) & SP_EXTENDED_CLIP)
			iMaxClip += 5
			
		if (native_get_primary_wpn_type(iPrimaryWpnId) == TYPE_SHIELD)
		{
			cs_set_weapon_ammo(iEnt, 0)
			UT_SetUserBPA(id, iWeaponId, 0)
		}
		
		if(fInReload && flNextAttack <= 0.0)
		{
			new iBasicSetting 
			TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BASIC_SETTING, iBasicSetting)
			
			if (CheckPlayerBit(b_ExtraBulletInChamber, id) && (iBasicSetting & ST_ADDITION_BULLET))
			{
				if (!(iBasicSetting & ST_DUAL_WEAPON))
					iMaxClip += 1
				else	iMaxClip += 2
			}
			
			new j = min(iMaxClip - iClip, iBpAmmo)
			
			cs_set_weapon_ammo(iEnt, iClip + j)
			
			if (j < 0)
				j = 0
			
			
			if (!is_user_bot(id))	
				UT_SetUserBPA(id, iWeaponId,  iBpAmmo-j)
			
			if (is_shotgun(iWeaponId))
				fm_set_weapon_special_reload(iEnt, 0)
				
			fm_set_weapon_reload(iEnt, 0)
			
			fInReload = 0
				
			if (!iCheckSniper(iWeaponId))
			{
				
				new iParam[3]
				iParam[0] = iBasicSetting
				iParam[1] = iWeaponId
				iParam[2] = iEnt
				
				if (!(iBasicSetting & ST_NO_CROSSHAIR))
					UT_CS_Crosshair_Toggle(id, 1, 0)
				
				remove_task(id + TASK_CROSSHAIR_TOGGLE)
				set_task(0.1, "ToggleCrosshair_TASK", id + TASK_CROSSHAIR_TOGGLE, iParam, 3)
							
				
			}
		}	
		/*
		iWeaponId = native_get_primary_real_id_2(iPrimaryWpnId)
	
		if (iWeaponId == 2) // Holding as Shield
			UT_SetPlayerSequence(id, "shielded")
		else	
		{
			new szSequence[32]
			UT_GetWeaponExtension(iWeaponId, 0, szSequence, sizeof szSequence - 1)
				
			UT_SetPlayerSequence(id, szSequence)
		}
		*/
	}	
}



public fw_ActiveNewRifle(TASKID)
{
	new iEnt = TASKID - TASK_ACTIVE_WEAPONBOX
	if (!pev_valid(iEnt))
		return
		
	set_pev(iEnt, pev_iuser4, WpnBoxPrimaryReady)
}

public fw_ActiveNormalRifle(TASKID)
{
	new iEnt = TASKID - TASK_ACTIVE_WEAPONBOX
	
	if (!pev_valid(iEnt))
		return
	set_pev(iEnt, pev_iuser4, WpnBoxNormalPrimaryReady)
}

public ShowLaser_TASK(TASKID)
{
	new id = TASKID - TASK_SHOW_LASER
	
	new iPrimaryWpnId = native_get_user_primary_id(id)
	
	if (!is_user_alive(id))
	{
		remove_task(TASKID)
		return
	}
	if (!CheckPlayerBit(g_LaserSightON, id))
	{
		remove_task(TASKID)
		return
	}
	
	if (!native_is_valid_pw(iPrimaryWpnId))
	{
		remove_task(TASKID)
		return
	}
	
	new iWeaponFunc
	TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_FUNC, iWeaponFunc)
	
	if (!(iWeaponFunc & FUNC_LASER_SIGHT))
	{
		remove_task(TASKID)
		return
	}
		
	new iEndOrigin[3]
	get_user_origin(id, iEndOrigin, 3)
	
	message_begin(MSG_ALL, SVC_TEMPENTITY)
	write_byte(TE_SPRITE)
	write_coord(iEndOrigin[0])
	write_coord(iEndOrigin[1])
	write_coord(iEndOrigin[2])
	write_short(laser) 
	write_byte(1) 
	write_byte(200)
	message_end()
	
}
public GrenadeLauncherReady_TASK(TASKID)
{
	new id = TASKID - TASK_GRENADE_LAUNCHER_READY
	
	if (!is_user_alive(id))
		return
		
	new iPrimaryWpnId = native_get_user_primary_id(id)
	
	if (!native_is_valid_pw(iPrimaryWpnId))
		return	
		
	new iWeaponEnt = fm_get_active_item(id)
	
	if (!iWeaponEnt || !pev_valid(iWeaponEnt))
		return
		
	new iWPN_ID = native_get_primary_real_id(iPrimaryWpnId)
	if (cs_get_weapon_id(iWeaponEnt) != iWPN_ID)
		return
		
	UT_SendCurWeaponMsg(id, 1, iWPN_ID, cs_get_weapon_ammo(iWeaponEnt), 1)
	
	new szSpecialViewModel[128]
	
	TrieGetString(weapon_StringInfo[iPrimaryWpnId], SECTION_GREN_V_MODEL, szSpecialViewModel, sizeof szSpecialViewModel - 1)
	
	set_pev(id, pev_viewmodel2, szSpecialViewModel)
	
	
	if (CheckPlayerBit(g_UsingZoomLen, id))	
		ClearPlayerBit(g_UsingZoomLen, id);
	
	if (CheckPlayerBit(g_ReloadingGrenadeLauncher, id))	
		ClearPlayerBit(g_ReloadingGrenadeLauncher, id);
	
	if (!native_get_primary_grenade_clip(iPrimaryWpnId))
	{
		remove_task(id + TASK_PREPARE_RELOAD_GREN)
		
		new iParam[3]
		iParam[0] = id
		iParam[1] = iPrimaryWpnId
		iParam[2] = GRENADE_START_RELOAD
		
		new Float:fGrenadeDelay
		TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_GRENADE_DELAY, fGrenadeDelay)
		
		set_task(fGrenadeDelay, "GrenadeLauncherReload_TASK", id + TASK_PREPARE_RELOAD_GREN, iParam, sizeof iParam)
	}
}

public DisableGrenadeLauncher_TASK(TASKID)
{
	new id = TASKID + TASK_GRENADE_LAUNCHER_READY
	
	new iPrimaryWpnId = native_get_user_primary_id(id)
	
	if (!native_is_valid_pw(iPrimaryWpnId))
		return
		
	new iWPN_ID = native_get_primary_real_id(iPrimaryWpnId)
	
	if (iWPN_ID != get_user_weapon(id))
		return
		
	new iEnt = fm_get_active_item(id)
	
	if (!iEnt || !pev_valid(iEnt))
		return
	
	new szWeaponName[32]
	get_weaponname(iWPN_ID, szWeaponName, sizeof szWeaponName - 1)
	
	engclient_cmd(id, szWeaponName)
	
	
	UT_SendCurWeaponMsg(id, 1, iWPN_ID , cs_get_weapon_ammo(iEnt), 1)
	
	new szViewModel[128]
	TrieGetString(weapon_StringInfo[iPrimaryWpnId], SECTION_V_MODEL, szViewModel, sizeof szViewModel - 1)									
	set_pev(id, pev_viewmodel2, szViewModel)
	UT_PlayWeaponAnim(id, Get_CSWPN_Anim_Idle(iWPN_ID, false))
	
	if (CheckPlayerBit(g_UsingZoomLen, id))	
		ClearPlayerBit(g_UsingZoomLen, id);
}

stock player_buy_weapon(id, iPrimaryWpnId)
{ 
	if (!is_user_alive(id))
		return
			
	if (!native_is_valid_pw(iPrimaryWpnId))
		return
		
	
	new szWeaponName[64]
	TrieGetString(weapon_StringInfo[iPrimaryWpnId], SECTION_WPN_NAME, szWeaponName, sizeof szWeaponName - 1)
		
	if (csred_get_user_level(id) < weapon_level[iPrimaryWpnId])
		return 
	
	
	new iMoney = cs_get_user_money(id)
	
	if (weapon_cost_type[iPrimaryWpnId] == 2)
	{
		new iCoin = csred_get_user_coin(id)
		if (iCoin < weapon_cost[iPrimaryWpnId])
			return
			
		native_give_user_primary_wpn(id, iPrimaryWpnId)
		csred_set_user_coin(id, csred_get_user_coin(id) - weapon_cost[iPrimaryWpnId])
			
			
	}
	else
	{
		if (iMoney < weapon_cost[iPrimaryWpnId])
			return
			
		native_give_user_primary_wpn(id, iPrimaryWpnId)
		cs_set_user_money(id, iMoney - weapon_cost[iPrimaryWpnId], 1)
			
	}
	
}
	
stock str_count(const str[], searchchar)
{
	new count, i
	//count = 0
	
	for (i = 0; i <= strlen(str); i++)
	{
		if(str[i] == searchchar)
			count++
	}
	
	return count;
}

stock GrenadeDamage(iDMG_TYPE, iSpecificVictim, iGrenadeEnt, Float:fRadius, Float:fDMG, iDamageBit, szGrenadeHud[], szGrenadeSound[], iSPR_ID, iScale, iFramerate, iExplosionFlag, iRemoveEntity)
{
	if (!iGrenadeEnt || !pev_valid(iGrenadeEnt))
		return
	
	new id = pev(iGrenadeEnt, pev_owner)
	
	new iGrenadeId = pev(iGrenadeEnt, pev_iGrenadeId)
	
	if (iGrenadeId < 0 || iGrenadeId > g_weapon_count - 1)
	{
		engfunc(EngFunc_RemoveEntity, iGrenadeEnt)
		return
	}
	
	new Float:fOrigin[3]
	
	pev(iGrenadeEnt, pev_origin, fOrigin)
	
	
	if (!IsValidPlayer(id))
	{
		engfunc(EngFunc_RemoveEntity, iGrenadeEnt)
		return
	}
	
	
	new iEntityId = 0
	
	if (iDMG_TYPE)
	{
		//while ((iEntityId = find_ent_in_sphere(iEntityId, fOrigin, fRadius)))
		//{
		for (iEntityId = 0; iEntityId < entity_count(); iEntityId++)
		{
			if (!iEntityId || !pev_valid(iEntityId))
				continue
				
			if (iEntityId == iGrenadeEnt)
				continue
				
			if (!is_Ent_Breakable(iEntityId))
				continue
				
			if (IsValidPlayer(iEntityId))
			{
				if (!is_user_alive(iEntityId))
					continue
				
				new Float:fVictimOrigin[3]
				pev(iEntityId, pev_origin, fVictimOrigin)
				new Float:fDistance = get_distance_f(fOrigin, fVictimOrigin)
				
				if (iSpecificVictim != -1)
				{
					if (iEntityId == iSpecificVictim)
						fDistance = 0.0
					else
						continue
				}
				
				if (fDistance >= fRadius)
					continue
					
				new CsTeams:iOwnerTeam = cs_get_user_team(id)
				new CsTeams:iVictimTeam = cs_get_user_team(iEntityId)
				
				if (!get_cvar_num("mp_friendlyfire"))
				{
					if (iOwnerTeam == iVictimTeam)
					{	
						continue
					}
				}
				
				new Float:fTmpDmg = fDMG - (fDMG / fRadius) * fDistance;	
				
				if (fTmpDmg <= 0.0)
					continue
				
				
				new iTr = create_tr2()
				engfunc(EngFunc_TraceLine, fOrigin, fVictimOrigin, DONT_IGNORE_MONSTERS, iGrenadeEnt, iTr)
				
				if (get_tr2(iTr, TR_pHit) == iEntityId)
				{
				
					new Float:fDirection[3]
					xs_vec_sub(fVictimOrigin, fOrigin, fDirection)
					xs_vec_normalize(fDirection, fDirection)
					
					ExecuteHamB(Ham_TraceAttack, iEntityId, iGrenadeEnt, fTmpDmg, fDirection, iTr, iDamageBit)
				}
				
				free_tr2(iTr)
				
				
				SetPlayerBit(b_KilledByExplosion, iEntityId)
				
				ExecuteHamB(Ham_TakeDamage, iEntityId, iGrenadeEnt, id, fTmpDmg, iDamageBit)
				
				new iAlive = 1
				
				if (!is_user_alive(iEntityId))
				{
					make_deathmsg(id, iEntityId, 0, szGrenadeHud)
					iAlive = 0
				}
				
				ExecuteForward(ifw_GrenadeDamage , ifw_Result, iEntityId, id, iGrenadeId, iAlive)
				
				ClearPlayerBit(b_KilledByExplosion, iEntityId);
				//free_tr2(iTr)
			}
			else
			{
				 
						
				new szClassName[32]
				pev(iEntityId, pev_classname, szClassName, sizeof szClassName - 1)
				
				new Float:fVictimOrigin[3]
				if (UT_IsBrushEnt(szClassName))
					get_brush_entity_origin(iEntityId, fVictimOrigin)
				else	pev(iEntityId, pev_origin, fVictimOrigin)
				
				new Float:fDistance = get_distance_f(fOrigin, fVictimOrigin)
					
				if (iSpecificVictim != -1)
				{
					if (iEntityId == iSpecificVictim)
						fDistance = 0.0
					else
						continue
				}
				
				if (fDistance > fRadius)
					continue
				
				
				new Float:fTmpDmg = fDMG - (fDMG / fRadius) * fDistance;	
				
				if (fTmpDmg <= 0.0)
					continue
				
				
				new iTr = create_tr2()
				engfunc(EngFunc_TraceLine, fOrigin, fVictimOrigin, DONT_IGNORE_MONSTERS, iGrenadeEnt, iTr)
				
				if (get_tr2(iTr, TR_pHit) == iEntityId)
				{
				
					new Float:fDirection[3]
					xs_vec_sub(fVictimOrigin, fOrigin, fDirection)
					xs_vec_normalize(fDirection, fDirection)
					
					ExecuteHamB(Ham_TraceAttack, iEntityId, iGrenadeEnt, fTmpDmg, fDirection, iTr, iDamageBit)
				}
				
				free_tr2(iTr)
				
				ExecuteHamB(Ham_TakeDamage, iEntityId, id , id, fTmpDmg , iDamageBit)
							
				if (pev(iEntityId, pev_spawnflags) & SF_BREAK_TOUCH)
					fm_fake_touch(id, iEntityId)
					
			}
		}
	}
	else if (iDMG_TYPE == 2)
	{
					
		new CsTeams:iOwnerTeam = cs_get_user_team(id)
				
		new iPlayers[32], iNumber
		
		if (!get_cvar_num("mp_friendlyfire"))
		{
			if (iOwnerTeam == CS_TEAM_T)
				get_players(iPlayers, iNumber, "ace", "CT")
			else if (iOwnerTeam == CS_TEAM_T)
				get_players(iPlayers, iNumber, "ace", "TERRORIST")
				
		}
		
		for (new i = 0; i < iNumber ; i++)
		{
			new iVictim = iPlayers[i]
			
			new iEyeOrigin[3], Float:fEyeOrigin[3]
			get_user_origin(iVictim, iEyeOrigin, 1)
			IVecFVec(iEyeOrigin, fEyeOrigin)
			
			
			new iTr
			engfunc(EngFunc_TraceLine, fOrigin, fEyeOrigin, IGNORE_GLASS|DONT_IGNORE_MONSTERS, iGrenadeEnt, iTr)	
			new Float:fVecEnd[3]
			get_tr2(iTr, TR_vecEndPos, fVecEnd)
			
				
			new Float:fDistance = get_distance_f(fOrigin, fVecEnd)
					
			if (fDistance > fRadius)
				continue
			
			new Float:fGrenadeDelay
			TrieGetCell(weapon_StringInfo[iGrenadeId], SECTION_GRENADE_DELAY, fGrenadeDelay)
			
			ScreenBlind(iVictim, 255, floatround(fGrenadeDelay))
		}
		
	}
	
	new Float:fActiveTime
	pev(iGrenadeEnt, pev_fGrenadeActiveTime, fActiveTime)
	
	if (fActiveTime <= get_gametime())
	{
		if (!(iExplosionFlag & DETONATE_NO_SPR))
		{
			new iGrenOrigin[3]
			
			FVecIVec(fOrigin, iGrenOrigin)
			
	
			
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY, iGrenOrigin)
			write_byte(TE_EXPLOSION)
			write_coord(iGrenOrigin[0])
			write_coord(iGrenOrigin[1])
			write_coord(iGrenOrigin[2])
			write_short(iSPR_ID)
			write_byte(iScale)
			write_byte(iFramerate) 
			write_byte(TE_EXPLFLAG_NOSOUND|TE_EXPLFLAG_NOPARTICLES)
			message_end()
			
			
		}
		
		if (!(iExplosionFlag & DETONATE_NO_SOUND))
			emit_sound(iGrenadeEnt, CHAN_AUTO, szGrenadeSound, 1.0, ATTN_NORM, 0, PITCH_HIGH)
		
		if (iExplosionFlag & TRAIL_ON_DETONATE)
		{
			new iGrenadePosition = pev(iGrenadeEnt, pev_iGrenadePosition)
				
			new iSpriteId, iRed, iGreen, iBlue, iWidth, iBrightness, iLife
			if (iGrenadePosition == GRENADE_UNDER_BARREL)
			{
				TrieGetCell(weapon_StringInfo[iGrenadeId], SECTION_BULLET_TSPR_2, iSpriteId)
				TrieGetCell(weapon_StringInfo[iGrenadeId], SECTION_BULLET_RED_2, iRed)
				TrieGetCell(weapon_StringInfo[iGrenadeId], SECTION_BULLET_GREEN_2, iGreen)
				TrieGetCell(weapon_StringInfo[iGrenadeId], SECTION_BULLET_BLUE_2, iBlue)
				TrieGetCell(weapon_StringInfo[iGrenadeId], SECTION_BULLET_TW_2, iWidth)
				TrieGetCell(weapon_StringInfo[iGrenadeId], SECTION_BULLET_TRBN_2, iBrightness)
				TrieGetCell(weapon_StringInfo[iGrenadeId], SECTION_BULLET_TRL_2, iLife)
			}
			else
			{
				TrieGetCell(iBulletConfig[iGrenadeId], SECTION_BULLET_TSPR_2, iSpriteId)
				TrieGetCell(iBulletConfig[iGrenadeId], SECTION_BULLET_RED_2, iRed)
				TrieGetCell(iBulletConfig[iGrenadeId], SECTION_BULLET_GREEN_2, iGreen)
				TrieGetCell(iBulletConfig[iGrenadeId], SECTION_BULLET_BLUE_2, iBlue)
				TrieGetCell(iBulletConfig[iGrenadeId], SECTION_BULLET_TW_2, iWidth)
				TrieGetCell(iBulletConfig[iGrenadeId], SECTION_BULLET_TRBN_2, iBrightness)
				TrieGetCell(iBulletConfig[iGrenadeId], SECTION_BULLET_TRL_2, iLife)
			}
			
			engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, fOrigin, 0)
			write_byte(TE_BEAMCYLINDER) // TE id
			engfunc(EngFunc_WriteCoord, fOrigin[0]) // x
			engfunc(EngFunc_WriteCoord, fOrigin[1]) // y
			engfunc(EngFunc_WriteCoord, fOrigin[2]) // z
			engfunc(EngFunc_WriteCoord, fOrigin[0]) // x axis
			engfunc(EngFunc_WriteCoord, fOrigin[1]) // y axis
			engfunc(EngFunc_WriteCoord, fOrigin[2] + (fRadius / 2)) // z axis
			write_short(iSpriteId) // sprite
			write_byte(0) // startframe
			write_byte(0) // framerate
			write_byte(iLife) // life
			write_byte(iWidth) // width
			write_byte(0) // noise
			write_byte(iRed) // red
			write_byte(iGreen) // green
			write_byte(iBlue) // blue
			write_byte(iBrightness) // brightness
			write_byte(0) // speed
			message_end()
		}
	}
	
	if (iRemoveEntity)
		engfunc(EngFunc_RemoveEntity, iGrenadeEnt)
}


stock UpdateFrags(attacker, victim, frags, deaths, scoreboard)
{
	set_pev(attacker, pev_frags, float(pev(attacker, pev_frags) + frags))
	cs_set_user_deaths(victim, cs_get_user_deaths(victim) + deaths)
	if (scoreboard)
	{
		emessage_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"))
		ewrite_byte(attacker) // id
		ewrite_short(pev(attacker, pev_frags)) // frags
		ewrite_short(cs_get_user_deaths(attacker)) // deaths
		ewrite_short(0) // class?
		ewrite_short(get_user_team(attacker)) // team
		emessage_end()
		
		emessage_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"))
		ewrite_byte(victim) // id
		ewrite_short(pev(victim, pev_frags)) // frags
		ewrite_short(cs_get_user_deaths(victim)) // deaths
		ewrite_short(0) // class?
		ewrite_short(get_user_team(victim)) // team
		emessage_end()
	}
}

stock ScreenBlind(id,iAmount, iSecond) 
{	
	
	emessage_begin(MSG_ONE_UNRELIABLE, iMsgScreenFade, _, id)
	ewrite_short((1<<12)*iSecond) // duration
	ewrite_short((1<<12)*iSecond) // hold time
	ewrite_short(0x0000) // fade type
	ewrite_byte(255) // red
	ewrite_byte(255) // green
	ewrite_byte(255) // blue
	ewrite_byte(iAmount) // alpha
	emessage_end()
	
	
	set_pdata_float(id, m_flFlashedUntil, get_gametime() + float(iSecond))  
}


stock UT_DrawGrenadeTrail(iGrenadeEnt, iSpriteId, iRed, iGreen, iBlue, iWidth, iBrightness, iLife)
{
	if (!iGrenadeEnt || !pev_valid(iGrenadeEnt))
		return
		
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW) // TE id
	write_short(iGrenadeEnt) // entity
	write_short(iSpriteId) // sprite
	write_byte(iLife) // life
	write_byte(iWidth) // width
	write_byte(iRed) // r
	write_byte(iGreen) // g
	write_byte(iBlue) // b
	write_byte(iBrightness) // brightness
	message_end()
}

stock UT_SetWeaponSpecialFunction(iPrimaryWpnId, iEnt)
{
	new iBasicSetting
	TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BASIC_SETTING, iBasicSetting)
		
	if (!(iBasicSetting & ST_ACTIVE_DEFAULT_FUNC))
		return
		
	switch (native_get_primary_real_id(iPrimaryWpnId))
	{
		case CSW_M4A1:
		{
			cs_set_weapon_silen(iEnt, 1, 0)
			fm_set_weapon_reload(iEnt, 0)
		}
		case CSW_FAMAS :
		{
			UT_set_weapon_burst(iEnt, 1)
			fm_set_weapon_reload(iEnt, 0)
		}
	}
}

stock create_launcher_grenade(id, iPrimaryWpnId, iUnderBarrel, iMoveType, iSpeed, iTraceResult)
{		
	if (!is_user_alive(id))
		return
		
	if (!native_is_valid_pw(iPrimaryWpnId))
		return
	
	new iWPN_ID = native_get_primary_real_id(iPrimaryWpnId)
	
	new iWeaponEnt = fm_get_active_item(id)
	
	if (!iWeaponEnt || !pev_valid(iWeaponEnt))
		return
		
	
	if (iWPN_ID != cs_get_weapon_id(iWeaponEnt))
		return
		
		
	if (iUnderBarrel)
	{
		if (!native_get_primary_grenade_clip(iPrimaryWpnId))
			return
		
		if (CheckPlayerBit(g_ReloadingGrenadeLauncher, id))
			return
			
		
		if (CheckPlayerBit(g_ReloadingGrenadeLauncher, id))	
			ClearPlayerBit(g_ReloadingGrenadeLauncher, id);
	}
	
	new Float:fEndOrigin[3]
		
	if (iWPN_ID == CSW_M4A1)
	{
		if(!cs_get_weapon_silen(iWeaponEnt))
			UT_PlayWeaponAnim(id, Get_CSWPN_Anim_Shoot1(iWPN_ID))
		else	UT_PlayWeaponAnim(id, Get_CSWPN_Anim_Shoot1(iWPN_ID) - 7)
	}
	else	UT_PlayWeaponAnim(id, Get_CSWPN_Anim_Shoot1(iWPN_ID))
		
	
	new iGrenadeEnt = create_entity(GRENADE_CLASS)
	
	if (!iGrenadeEnt || !pev_valid(iGrenadeEnt)) 
	{
		return 
	}
	
	new iGrenadeType 
	
	if (iUnderBarrel)
		TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BULLET_GREN_TYPE, iGrenadeType)
	else	TrieGetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_GREN_TYPE, iGrenadeType)
	
	new Float:fCurrentTime = get_gametime()
	
	switch (iGrenadeType)
	{
		case GRENADE_EXPLOSION	:
			set_pev(iGrenadeEnt, pev_iGrenadeType, PW_CLASS_EXPLOSIVE)
		case GRENADE_FLASH:
			set_pev(iGrenadeEnt, pev_iGrenadeType, PW_CLASS_FLASH)
		default:
		{
			return
		}
	}
	
	set_pev(iGrenadeEnt, pev_iGrenadeId, iPrimaryWpnId)
	
	if (iUnderBarrel)
	{
		set_pev(iGrenadeEnt, pev_iGrenadePosition, GRENADE_UNDER_BARREL)
		
		new Float:fTime
		
		TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BULLET_ACTIVE_TIME, fTime)
		set_pev(iGrenadeEnt, pev_fGrenadeActiveTime, fCurrentTime + fTime)
		
		TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BULLET_REMOVE_TIME, fTime)
		
		new Float:fFallTime
		TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BULLET_FALL_TIME, fFallTime)
		
		if (fFallTime < fTime)
		{
			set_pev(iGrenadeEnt, pev_fGrenadeFallStatus, 0.0)
			set_pev(iGrenadeEnt, pev_nextthink, fCurrentTime + fFallTime) // Falldown Time
		}
		else	
		{
			set_pev(iGrenadeEnt, pev_fGrenadeFallStatus, 1.0)
			set_pev(iGrenadeEnt, pev_nextthink, fCurrentTime + fTime) // Explode time
		}
		
		new iBulletFlag
		TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BULLET_FLAG, iBulletFlag)
		
		
		//			Draw projectile trail
		if (iBulletFlag & TRAIL_ON_MOVE)
		{
			new iSpriteId, iRed, iBlue, iGreen, iWidth, iBrightness, iLife
			
			TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BULLET_TSPR, iSpriteId)
			TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BULLET_RED, iRed)
			TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BULLET_GREEN, iGreen)
			TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BULLET_BLUE, iBlue)
			TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BULLET_TW, iWidth)
			TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BULLET_TRBN, iBrightness)
			TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BULLET_TRL, iLife)
			
			UT_DrawGrenadeTrail(iGrenadeEnt, iSpriteId, iRed, iGreen, iBlue, iWidth, iBrightness, iLife)
		}
		
		if (!(iBulletFlag & DIRECTION_BY_TRACE))
		{
			new iEndOrigin[3]
			get_user_origin(id, iEndOrigin, 3)
			IVecFVec(iEndOrigin, fEndOrigin)
		}
		else	get_tr2(iTraceResult, TR_vecEndPos, fEndOrigin)
	}
	else	
	{
		set_pev(iGrenadeEnt, pev_iGrenadePosition, GRENADE_BARREL)
		
		new Float:fTime
		
		TrieGetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_ACTIVE_TIME, fTime)
		set_pev(iGrenadeEnt, pev_fGrenadeActiveTime, fCurrentTime + fTime)
	
		TrieGetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_REMOVE_TIME, fTime)
		
		new Float:fFallTime
		TrieGetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_FALL_TIME, fFallTime)
		
		if (fFallTime < fTime)
		{
			set_pev(iGrenadeEnt, pev_fGrenadeFallStatus, 0.0)
			set_pev(iGrenadeEnt, pev_nextthink, fCurrentTime + fFallTime) // Falldown Time
		}
		else	
		{
			set_pev(iGrenadeEnt, pev_fGrenadeFallStatus, 1.0)
			set_pev(iGrenadeEnt, pev_nextthink, fCurrentTime + fTime) // Explode time
		}
		
		//	TRAIL
		
		new iBulletFlag
		TrieGetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_FLAG, iBulletFlag)
		
		if (iBulletFlag & TRAIL_ON_MOVE)
		{
			new iSpriteId, iRed, iBlue, iGreen, iWidth, iBrightness, iLife
			
			TrieGetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_TSPR, iSpriteId)
			TrieGetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_RED, iRed)
			TrieGetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_GREEN, iGreen)
			TrieGetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_BLUE, iBlue)
			TrieGetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_TW, iWidth)
			TrieGetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_TRBN, iBrightness)
			TrieGetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_TRL, iLife)
			
			UT_DrawGrenadeTrail(iGrenadeEnt, iSpriteId, iRed, iGreen, iBlue, iWidth, iBrightness, iLife)
		}
		
		if (iBulletFlag & ACTIVE_ON_TOUCH)
			set_pev(iGrenadeEnt, pev_fGrenadeActiveTime, fCurrentTime + INFINITIVE_RELOAD_TIME)
			
		if (!(iBulletFlag & DIRECTION_BY_TRACE))
		{
			new iEndOrigin[3]
			get_user_origin(id, iEndOrigin, 3)
			IVecFVec(iEndOrigin, fEndOrigin)
		}
		else	get_tr2(iTraceResult, TR_vecEndPos, fEndOrigin)
	}
	
	
	
	set_pev(iGrenadeEnt , pev_iGrenadeActive, 0)	// Grenade isn't activated

	
			
	
	
	new Float:MinBox[3] = {-10.0, -10.0, -10.0}
	new Float:MaxBox[3] = {10.0, 10.0, 10.0}
	
	entity_set_vector(iGrenadeEnt, EV_VEC_mins, MinBox)
	entity_set_vector(iGrenadeEnt, EV_VEC_maxs, MaxBox)
	set_pev(iGrenadeEnt, pev_solid, SOLID_TRIGGER ) 
	set_pev(iGrenadeEnt, pev_owner, id)
	
	/****************************************************/
	
	
	new iOrigin[3]
	new Float:fOrigin[3]
	

	/****************************************************/
	
	//	Retrieve Origin (Weapon Origin | End Origin)
	
	get_user_origin(id, iOrigin, 1)
	
	IVecFVec(iOrigin, fOrigin)
	
	set_pev(iGrenadeEnt, pev_origin, fOrigin)
	set_pev(iGrenadeEnt, pev_fGrenadeEndOrigin, fEndOrigin)
	/****************************************************/
	
	//	Calculate Velocity
	
	new Float:fVelocity[3]
	xs_vec_sub(fEndOrigin, fOrigin, fVelocity)
	xs_vec_normalize(fVelocity, fVelocity)
	
	new Float:fSpeed = float(iSpeed)
	xs_vec_mul_scalar(fVelocity, fSpeed, fVelocity)  
	
	set_pev(iGrenadeEnt, pev_velocity, fVelocity)
	set_pev(iGrenadeEnt, pev_movetype, iMoveType)
	
	/****************************************************/
	
	//	Calculate Angle
	
	new Float:fVecAngle[3]
	xs_vec_sub(fEndOrigin, fOrigin, fVecAngle)
	xs_vec_normalize(fVecAngle, fVecAngle)
	engfunc(EngFunc_MakeVectors, fVecAngle)
	vector_to_angle(fVecAngle, fVecAngle)
	set_pev(iGrenadeEnt, pev_angles, fVecAngle)
	
	//	Calculate A velocity
	fVecAngle[0] = 0.0
	fVecAngle[1] = 0.0
	fVecAngle[2] = 10.0
	
	set_pev(iGrenadeEnt, pev_avelocity, fVecAngle)
	/****************************************************/
	
	remove_task(id + TASK_PREPARE_RELOAD_GREN)
	
	new szGrenadeModel[128]
	
	if (!iUnderBarrel)
	{
		TrieGetString(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_GRENADE_MODEL, szGrenadeModel, sizeof szGrenadeModel - 1)
		entity_set_model(iGrenadeEnt, szGrenadeModel)
		
		new iGrenadeSub
		TrieGetCell(iBulletConfig[iPrimaryWpnId],SECTION_BULLET_GRENADE_SUB, iGrenadeSub)
		set_pev(iGrenadeEnt, pev_body, iGrenadeSub)
		
		new Float:fDelay
		TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_WEAPON_FIRE_RATE, fDelay)
		
		
	}
	else
	{
		TrieGetString(weapon_StringInfo[iPrimaryWpnId], SECTION_BULLET_GRENADE_MODEL, szGrenadeModel, sizeof szGrenadeModel - 1)
		entity_set_model(iGrenadeEnt, szGrenadeModel)
		new iGrenadeSub 
		TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BULLET_GRENADE_SUB, iGrenadeSub)
		set_pev(iGrenadeEnt, pev_body, iGrenadeSub)
		
		new iGrenadeClip = get_trie_int(iPlayerInfo[id], SECTION_GRENADE_CLIP)
		iGrenadeClip--
		set_trie_int(iPlayerInfo[id], SECTION_GRENADE_CLIP, iGrenadeClip)
		
		new iGrenadeBpa = get_trie_int(iPlayerInfo[id], SECTION_GRENADE_BPA)
		iGrenadeBpa--
		set_trie_int(iPlayerInfo[id], SECTION_GRENADE_BPA, iGrenadeBpa)
		
		
		if (iGrenadeClip)
		{
			new Float:fGrenadeDelay
			TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_GRENADE_DELAY, fGrenadeDelay)
			
			fm_set_next_attack(id, fGrenadeDelay)
		}
		else
		{
			if (iGrenadeBpa)
			{
				new iParam[3]
				iParam[0] = id
				iParam[1] = iPrimaryWpnId
				iParam[2] = GRENADE_START_RELOAD
				
				new Float:fGrenadeDelay
				TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_GRENADE_DELAY, fGrenadeDelay)
			
				set_task(fGrenadeDelay, "GrenadeLauncherReload_TASK", id + TASK_PREPARE_RELOAD_GREN, iParam, sizeof iParam)
				fm_set_next_attack(id, fGrenadeDelay)
				
			}
			else
			{
				if (CheckPlayerBit(g_UsingZoomLen, id))
					ClearPlayerBit(g_UsingZoomLen, id)
				
				UT_SetPlayerFOV(id, 90)
									
								
				new iPlayedAnimation = Get_CSWPN_MaxAnimation(iWPN_ID) + ANIMATION_CHANGE_GREN_BACK
								
				if (cs_get_weapon_silen(iWeaponEnt))
					iPlayedAnimation += ANIM_SILENCER_ADD
										
				UT_PlayWeaponAnim(id, iPlayedAnimation)
							
							
				new Float:fChangeBackTime
				TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_GRENADE_DEACTIVE_TIME, fChangeBackTime)
				
				fm_set_next_attack(id, fChangeBackTime)
				
				set_task(fChangeBackTime, "DisableGrenadeLauncher_TASK", id - TASK_GRENADE_LAUNCHER_READY)
				
				if (CheckPlayerBit(g_LauncherModeActivated, id))	
					ClearPlayerBit(g_LauncherModeActivated, id);
									
										
				client_print(id, print_center, "%L", id, "DEACTIVE_GLAUNCHER_FUNCTION")	
				
					
			}
		}
	}
	
	return 
}


/*	GRENADE LAUNCHER RELOAD TASK	*/

public GrenadeLauncherReload_TASK(iParam[3], TASKID)
{
	new id = iParam[0]
	new iPrimaryWpnId = iParam[1]
	new iReloadStage = iParam[2]
	
	if (!is_user_alive(id))
		return
		
	if (native_get_user_primary_id(id) != iPrimaryWpnId)
		return
		
	if (!native_is_valid_pw(iPrimaryWpnId))
		return
	
	if (!CheckPlayerBit(g_LauncherModeActivated, id))
		return
	
	
	new iGrenadeClip = get_trie_int(iPlayerInfo[id], SECTION_GRENADE_CLIP)
	new iGrenadeBpa = get_trie_int(iPlayerInfo[id], SECTION_GRENADE_BPA)
	
	if (!iGrenadeBpa || CheckPlayerBit(g_ReloadingGrenadeLauncher, id))
		return 
	
	new iWeaponEnt = fm_get_active_item(id)
	
	if (!iWeaponEnt || !pev_valid(iWeaponEnt))
		return
		
	new iWPN_ID = native_get_primary_real_id(iPrimaryWpnId)
	
	if (cs_get_weapon_id(iWeaponEnt) != iWPN_ID)
		return
	
	new iSilentStatus = cs_get_weapon_silen(iWeaponEnt)
	
	switch (iReloadStage)
	{
		case GRENADE_START_RELOAD:
		{
			if (!iGrenadeBpa)
				return
				
			if (!CheckPlayerBit(g_ReloadingGrenadeLauncher, id))	
				SetPlayerBit(g_ReloadingGrenadeLauncher, id)
			
			UT_PlayWeaponAnim(id, Get_CSWPN_Anim_Reload(iWPN_ID))
			
			iParam[2] = GRENADE_INSERT
			
			new Float:flStartInsert
			TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_TIME_GREN_START_REL, flStartInsert)
			
			set_task(flStartInsert, "GrenadeLauncherReload_TASK", TASKID, iParam, sizeof iParam)
			fm_set_next_attack(id, INFINITIVE_RELOAD_TIME)
			
		}
		case GRENADE_INSERT:
		{
			new iInsertAnimation = Get_CSWPN_MaxAnimation(iWPN_ID) + ANIMATION_INSERT_BULLET
			
			if (iSilentStatus)
				iInsertAnimation += 1
				
			UT_PlayWeaponAnim(id, iInsertAnimation)
			
			iParam[2] = GRENADE_ADD_AMMO
			
			new Float:fInsertTime
			TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_TIME_GREN_INS, fInsertTime)
			set_task(fInsertTime, "GrenadeLauncherReload_TASK", TASKID, iParam, sizeof iParam)
			fm_set_next_attack(id, INFINITIVE_RELOAD_TIME)
			
		}
		case GRENADE_ADD_AMMO:
		{
			iGrenadeClip++
			set_trie_int(iPlayerInfo[id], SECTION_GRENADE_CLIP, iGrenadeClip)
			
			iGrenadeBpa--
			set_trie_int(iPlayerInfo[id], SECTION_GRENADE_BPA, iGrenadeBpa)
			
			//	Fully Reloaded or your Grenade Ammo runs out
			if (iGrenadeClip >= native_get_primary_grenade_clip(iPrimaryWpnId) || !iGrenadeBpa)
			{
				remove_task(id + TASK_FINISH_RELOAD_GREN)
				new iAfterInsertAnimation = Get_CSWPN_MaxAnimation(iWPN_ID) + ANIMATION_INSERT_BULLET
			
				if (iSilentStatus)
					iAfterInsertAnimation += 1
					
				UT_PlayWeaponAnim(id, iAfterInsertAnimation)
				
				new Float:fAfterInsertTime
				TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_TIME_GREN_FIN, fAfterInsertTime)
			
				set_task(fAfterInsertTime, "GrenadeLauncherActive_TASK", id + TASK_FINISH_RELOAD_GREN, iParam, sizeof iParam)
				fm_set_next_attack(id, INFINITIVE_RELOAD_TIME)
				return
			}
			
			new iInsertAnimation = Get_CSWPN_MaxAnimation(iWPN_ID) + ANIMATION_INSERT_BULLET
			UT_PlayWeaponAnim(id, iInsertAnimation)
			
			new Float:fInsertTime
			TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_TIME_GREN_INS, fInsertTime)
			set_task(fInsertTime, "GrenadeLauncherReload_TASK", TASKID, iParam, sizeof iParam)
			fm_set_next_attack(id, INFINITIVE_RELOAD_TIME)
			
		}
	}
}

public GrenadeLauncherActive_TASK(iParam[3], TASKID)
{
	new id = iParam[0]
	new iPrimaryWpnId = iParam[1]
	
	if (!is_user_alive(id))
		return
		
	if (native_get_user_primary_id(id) != iPrimaryWpnId)
		return
		
	if (!native_is_valid_pw(iPrimaryWpnId))
		return
	
	if (!CheckPlayerBit(g_LauncherModeActivated, id))
		return
	
	new iGrenadeBpa = get_trie_int(iPlayerInfo[id], SECTION_GRENADE_BPA)
	
	if (!iGrenadeBpa)
		return 
	
	
	if (!CheckPlayerBit(g_ReloadingGrenadeLauncher, id))
		return
	
	new iWeaponEnt = fm_get_active_item(id)
	
	new iWPN_ID = native_get_primary_real_id(iPrimaryWpnId)
	
	if (cs_get_weapon_id(iWeaponEnt) != iWPN_ID)
		return
	
	if (CheckPlayerBit(g_ReloadingGrenadeLauncher, id))	
		ClearPlayerBit(g_ReloadingGrenadeLauncher, id)
	
}
	

/****************************************/


stock iCheckSniper(iWeaponId)
{
	if (iWeaponId == CSW_SCOUT)
		return 1
	if (iWeaponId == CSW_AWP)
		return 1
	if (iWeaponId == CSW_G3SG1)
		return 1
	if (iWeaponId == CSW_SG550)
		return 1
	return 0
}

stock IsValidPlayer(id)
{
	if (!(1<= id <= iMaxPlayers))
		return 0
		
	if (!is_user_connected(id))
		return 0
		
	return 1
}

stock CreateArmoury(iPoint, iPrimaryWeaponId, Float:fOrigin[3])
{
	ExecuteForward(ifw_ArmouryEntitySpawn, ifw_Result, iPrimaryWeaponId)
	
	if (ifw_Result != PLUGIN_CONTINUE)
		return 0
		
	new iEnt = create_entity("armoury_entity")
	
	if (!iEnt || !pev_valid(iEnt))
		return 0
		
	dllfunc( DLLFunc_Spawn, iEnt );
	
	
	set_pev(iEnt, pev_solid, SOLID_TRIGGER)
	set_pev(iEnt, pev_mins, {-3.0, -3.0, -3.0})
	set_pev(iEnt, pev_maxs, {3.0, 3.0, 3.0})
	set_pev(iEnt, pev_ArmouryType, ARMOURY_PRIMARY)
	
	new iWeaponId
	
	if (iPoint < 0)
	{
		iWeaponId = iPrimaryWeaponId	
		set_pev(iEnt, pev_origin, fOrigin)
	}
	else	
	{
		iWeaponId = iSpawnWeaponId[iPoint]
		set_pev(iEnt, pev_origin, fSpawnVecs[iPoint])
	}
	
	fm_set_weapon_id(iEnt, iWeaponId)
	csred_SetArmouryStatus(iEnt, ARMOURY_ENABLED)
				
	
	new szModelBuffer[256], iSubBody
		
	TrieGetString(weapon_StringInfo[iWeaponId], SECTION_W_MODEL, szModelBuffer, sizeof szModelBuffer - 1)
	TrieGetCell(weapon_StringInfo[iWeaponId], SECTION_W_SUB, iSubBody)
		
	engfunc(EngFunc_SetModel, iEnt, szModelBuffer)
	set_pev(iEnt, pev_body, iSubBody)

	set_pev(iEnt, pev_ArmouryPoint, iPoint)
	return 1
}

stock do_scope_function(id, iPrimaryWpnId)
{
	
	if (!native_is_valid_pw(iPrimaryWpnId))
		return 0
	
	new iBasicSetting = get_trie_int(weapon_StringInfo[iPrimaryWpnId], SECTION_BASIC_SETTING)
	
	if (!(iBasicSetting & ST_ZOOM_SUPPORTED))
		return 0
		
	new iCanUpdateScope = 0
		
	new iFirstFOV = get_trie_int(weapon_StringInfo[iPrimaryWpnId], SECTION_FIRST_FOV)
	new iSecondFOV = get_trie_int(weapon_StringInfo[iPrimaryWpnId], SECTION_SECOND_FOV)
	
	
	if (!CheckPlayerBit(g_UsingZoomLen, id))
	{
		if (0 < iFirstFOV < 90)
		{
			UT_SetPlayerFOV(id, iFirstFOV)
		
			SetPlayerBit(g_UsingZoomLen, id);
			set_trie_int(iPlayerInfo[id], SECTION_USER_ZOOM_LVL , 1)
			iCanUpdateScope = 1
		}
	}
	else
	{
		new iZoomLevel = get_trie_int(iPlayerInfo[id], SECTION_USER_ZOOM_LVL, -1)
		
		if (iZoomLevel == 1)
		{
			if ((0 < iSecondFOV < 90) && (iSecondFOV != iFirstFOV))
			{
				UT_SetPlayerFOV(id, iSecondFOV)
				
				set_trie_int(iPlayerInfo[id], SECTION_USER_ZOOM_LVL,  2)
				iCanUpdateScope = 1
				client_cmd(id, "spk weapons/zoom.wav")
			}
		}
		
		if (!iCanUpdateScope)
		{
			if (CheckPlayerBit(g_UsingZoomLen, id))
				ClearPlayerBit(g_UsingZoomLen, id)
			
			UT_SetPlayerFOV(id, 90)
		}
	}
	
	ExecuteForward(ifw_FuncActivated, ifw_Result, id, iPrimaryWpnId, iCanUpdateScope)
	
	return iCanUpdateScope
}


stock DrawLight(id, iOrigin[3], iRadius, iLightColor[3], iLife = 5, iDecay = 0)
{
	if ( is_user_flashed(id))
		return
		
	//	TE_DELIGHT
	message_begin(MSG_ONE_UNRELIABLE,SVC_TEMPENTITY,iOrigin,id) 
	
	write_byte(TE_DLIGHT) // 27
	
	
	write_coord(iOrigin[0]) 
	write_coord(iOrigin[1]) 
	write_coord(iOrigin[2]) 
	
	write_byte(iRadius) // radius
	
	write_byte(iLightColor[0])    // r
	write_byte(iLightColor[1])  // g
	write_byte(iLightColor[2])   // b
	
	write_byte(iLife) // life in 10's
	write_byte(iDecay)  // decay rate in 10's
	
	message_end() 

}

stock DrawNVG(id, iOrigin[3], iLightColor[3], iAlpha, iDuration = 1000, iHoldTime = 1000, iFlag = UNIT_SECOND)
{
		//	SCREEN FADE
	if ( is_user_flashed(id))
		return
		
	message_begin(MSG_ONE_UNRELIABLE,iMsgScreenFade,iOrigin,id) 
	
	write_short(iDuration) 
	write_short(iHoldTime) 
	write_short(iFlag) 
	
	write_byte(iLightColor[0])    // r
	write_byte(iLightColor[1])  // g
	write_byte(iLightColor[2])   // b 
	
	write_byte(iAlpha) 
	
	message_end()
}

stock SetTaskShowNVG(id)
{
	remove_task(id + TASK_SHOW_FAKE_NVG)
	
	set_task(0.2, "ShowFakeNVG", id + TASK_SHOW_FAKE_NVG, _, _, "b")
}

public ShowFakeNVG(TASKID)
{
	new id = TASKID - TASK_SHOW_FAKE_NVG
	
	if (!is_user_alive(id) || is_user_bot(id))
	{
		remove_task(id + TASK_SHOW_FAKE_NVG)
		return
	}
	
	new iPrimaryWpnId = native_get_user_primary_id(id)
	
	if (iPrimaryWpnId  < 0)
	{
		remove_task(id + TASK_SHOW_FAKE_NVG)
		return
	}
	
	new iWPN_ID = native_get_primary_real_id(iPrimaryWpnId)
	
	if (get_user_weapon(id) != iWPN_ID)
	{
		remove_task(id + TASK_SHOW_FAKE_NVG)
		return
	}
	
	new iZoomType = cs_get_user_zoom(id)
	if (!native_is_primary_wpn_ads(id) && !( 0 < UT_GetPlayerFOV(id) < 90) && iZoomType != CS_SET_AUGSG552_ZOOM && iZoomType != CS_SET_FIRST_ZOOM && iZoomType != CS_SET_SECOND_ZOOM)
	{
		remove_task(id + TASK_SHOW_FAKE_NVG)
		return
	}
	
	
	
	if (UT_GetUserNVG_State(id))
	{
		SetPlayerBit(g_TurnOnNVG_BeforeThermal, id)
		UT_SetUserNVG_State(id, 0, 1)
	}
	
	
	
	new iRemoveTask = 1
	
	new iThermalFlag = get_trie_int(weapon_StringInfo[iPrimaryWpnId], SECTION_THERMAL_FLAG)
	
	new iOrigin[3]
	get_user_origin(id, iOrigin, 0)
	
	if (iThermalFlag & THERMAL_NVG_SCREEN)
	{	
		new iThermalAlpha = get_trie_int(weapon_StringInfo[iPrimaryWpnId], SECTION_THERMAL_ALPHA)
		
		new iColor[3]
		
		iColor[0] = get_trie_int(weapon_StringInfo[iPrimaryWpnId], SECTION_THERMAL_RED)
		iColor[1] = get_trie_int(weapon_StringInfo[iPrimaryWpnId], SECTION_THERMAL_GREEN)
		iColor[2] = get_trie_int(weapon_StringInfo[iPrimaryWpnId], SECTION_THERMAL_BLUE)
		
		DrawNVG(id, iOrigin, iColor, iThermalAlpha)
		iRemoveTask = 0
	
		
	}
	if (iThermalFlag & THERMAL_NVG_LIGHT)
	{
		new iThermalRadius = get_trie_int(weapon_StringInfo[iPrimaryWpnId], SECTION_THERMAL_RADIUS)
		
		new iColor[3]
		iColor[0] = get_trie_int(weapon_StringInfo[iPrimaryWpnId], SECTION_THERMAL_RED)
		iColor[1] = get_trie_int(weapon_StringInfo[iPrimaryWpnId], SECTION_THERMAL_GREEN)
		iColor[2] = get_trie_int(weapon_StringInfo[iPrimaryWpnId], SECTION_THERMAL_BLUE)
		DrawLight(id, iOrigin, iThermalRadius, iColor)
		iRemoveTask = 0
	}
	
	if (iRemoveTask)
	{
		remove_task(TASKID)
		return
	}
}


public fw_AddToFullPack(es_handled, ient, ent, host, hostflags, player, pSet)
{	
	if (!is_user_alive(host))
		return FMRES_IGNORED
			
	if (is_user_bot(host))
		return FMRES_IGNORED
			
	if (!CheckPlayerBit(g_TurnOnThermal, host))
		return FMRES_IGNORED
		
	new iPrimaryWpnId = native_get_user_primary_id(host)
	
	if (!native_is_valid_pw(iPrimaryWpnId))
		return FMRES_IGNORED
	
	new iThermalFlag
	TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_THERMAL_FLAG, iThermalFlag)
	
	if (!(iThermalFlag & THERMAL_TOGGLE))
		return FMRES_IGNORED
		
	new iWPN_ID = native_get_primary_real_id(iPrimaryWpnId)
	
	if (get_user_weapon(host) != iWPN_ID)
		return FMRES_IGNORED
	
	if (!ent || !pev_valid(ent))
		return FMRES_IGNORED
		
	if (ent == host)
		return FMRES_IGNORED
		
	if (IsValidPlayer(ent))
	{
		if (!is_user_alive(ent))
			return FMRES_IGNORED
	}
	else
	{
		
		new szClassName[32]
		pev(ent, pev_classname, szClassName, sizeof szClassName - 1)
		
		//if (!equal(szClassName, "hostage_entity") && !equal(szClassName, "monster_scientist") && !equal(szClassName, "light") && !equal(szClassName, "light_spot") && !equal(szClassName, "env_glow"))
		//	return FMRES_IGNORED
		
		if (!TrieKeyExists(iThermalClass, szClassName))
		{
			new szModel[128]
			pev(ent, pev_model, szModel, sizeof szModel - 1)
			
			if (!TrieKeyExists(iThermalModel, szModel))
				return FMRES_IGNORED
			
			if (!fm_get_entity_visibility(ent))
				return FMRES_IGNORED
		}
	}
		
	//if (csred_IsUserGhost(ent))// || g4u_get_user_zombie(ent))
	//	return FMRES_IGNORED
		
	new iZoomType = cs_get_user_zoom(host)
	
	if (!native_is_primary_wpn_ads(host) && !( 0 < UT_GetPlayerFOV(host) < 90) && iZoomType != CS_SET_AUGSG552_ZOOM && iZoomType != CS_SET_FIRST_ZOOM && iZoomType != CS_SET_SECOND_ZOOM)
		return FMRES_IGNORED
		
	if (!task_exists(host + TASK_SHOW_FAKE_NVG))
		SetTaskShowNVG(host)
		
	//ES_SetRendering(es_handled, kRenderFxGlowShell, 250, 0, 0, kRenderNormal, 16)
	
	new iRenderColor[3] 
	
	iRenderColor[0] = 255
	iRenderColor[1] = 255
	iRenderColor[2] = 255
	
	if (iThermalFlag & THERMAL_TEAM)
	{
		if (is_user_alive(ent))
		{
			new CsTeams:iEntTeam = cs_get_user_team(ent)
			
			if (iEntTeam == CS_TEAM_CT)
			{
				iRenderColor[0] = 0
				iRenderColor[1] = 0
				iRenderColor[2] = 255
				
			}
			else
			{
				iRenderColor[0] = 255
				iRenderColor[1] = 0
				iRenderColor[2] = 0
			}
		}
	}
	
	
	// set_es(es_handled,  ES_RenderFx, kRenderFxGlowShell);
	set_es(es_handled,  ES_RenderFx, kRenderFxGlowShell);
	set_es(es_handled, ES_RenderColor, iRenderColor);
	set_es(es_handled, ES_RenderMode, kRenderTransColor);
	set_es(es_handled, ES_RenderAmt, 1.0);
	
	return FMRES_IGNORED
}

stock spawnStaticSound( const index, const Float:origin[3], const soundIndex, const Float:vol, const Float:atten, const pitch, const flags ) 
{ 
	message_begin( index ? MSG_ONE_UNRELIABLE : MSG_ALL, SVC_SPAWNSTATICSOUND, .player = index );
	
	write_coord_f( origin[0] ); 
	write_coord_f( origin[1] ); 
	write_coord_f( origin[2] );
	write_short( soundIndex );
	write_byte( clamp_byte( floatround( vol * 255 ) ) );
	write_byte( clamp_byte( floatround( atten * 64 ) ) );
	write_short( index );        
	write_byte( pitch ); 
	write_byte( flags );   
		
	message_end();
}



stock UT_set_weapon_burst(entity, burstmode=1)
{
	new weapon = cs_get_weapon_id(entity);
	if( weapon != CSW_GLOCK18 && weapon != CSW_FAMAS ) return;
	
	new OFFSET_SILENCER_FIREMODE = 74
	new EXTRAOFFSET_WEAPONS = 4
	new GLOCK18_SEMIAUTOMATIC = 0
	new GLOCK18_BURST = 2
	
	new FAMAS_AUTOMATIC = 0
	new FAMAS_BURST = 16

	new firemode = get_pdata_int(entity, OFFSET_SILENCER_FIREMODE, EXTRAOFFSET_WEAPONS);
	
	switch( weapon )
	{
		case CSW_GLOCK18:
		{
			if( burstmode && firemode == GLOCK18_SEMIAUTOMATIC )
			{
				firemode = GLOCK18_BURST;
			}
			else if( !burstmode && firemode == GLOCK18_BURST )
			{
				firemode = GLOCK18_SEMIAUTOMATIC;
			}
			else return;
		}
		case CSW_FAMAS:
		{
			if( burstmode && firemode == FAMAS_AUTOMATIC )
			{
				firemode = FAMAS_BURST;
			}
			else if( !burstmode && firemode == FAMAS_BURST )
			{
				firemode = FAMAS_AUTOMATIC;
			}
			else return;
		}
	}
	
	set_pdata_int(entity, OFFSET_SILENCER_FIREMODE, firemode, EXTRAOFFSET_WEAPONS);
}

stock is_Ent_Breakable(iEnt)
{
	if (!iEnt || !pev_valid(iEnt))
		return 0
	
	if ((entity_get_float(iEnt, EV_FL_health) > 0.0) && (entity_get_float(iEnt, EV_FL_takedamage) > 0.0) && !(entity_get_int(iEnt, EV_INT_spawnflags) & SF_BREAK_TRIGGER_ONLY))
		return 1
	
	return 0
}

stock DrawSpark(Float:origin[3])
{
	message_begin(MSG_ALL, SVC_TEMPENTITY)
	write_byte(TE_SPARKS)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	message_end()	
}

stock remove_all_tasks(id)
{
	
	remove_task(id + TASK_NORMAL_IRONSIGHT)	
	remove_task(id - TASK_NORMAL_IRONSIGHT)

	remove_task(id + TASK_FINISH_RELOAD_GREN)
	remove_task(id + TASK_GRENADE_LAUNCHER_READY)
	remove_task(id + TASK_PREPARE_RELOAD_GREN)

	remove_task(id + TASK_ATTACK_MELEE)
	remove_task(id + TASK_IRON_SIGHT)
	remove_task(id + TASK_SHOW_FAKE_NVG)
	remove_task(id + TASK_SHOW_LASER)
	remove_task(id + TASK_CROSSHAIR_TOGGLE)
	remove_task(id + TASK_FAMAS_BURST)
	
	remove_task(id + TASK_FAMAS_BURST)
	remove_task(id + TASK_INSERT_AMMO)
	remove_task(id + TASK_ADD_WEAPON_AMMO)
	remove_task(id + TASK_FINISH_RELOAD_AMMO)
}

stock can_weapon_play_sound(id)
{
	if (CheckPlayerBit(g_LauncherModeActivated, id))
		return 0
		
	return 1
}

stock is_this_func_suit_to_minigun(iFunc)
{
	switch(iFunc)	
	{
		
		case SPEC_FUNC_ZOOM	:
			return 1
		case SPEC_MELEE_WPN	:
			return 1
		case SPEC_IRONSIGHT_TYPE_2	:
			return 1
		default	:
			return 0
	}
	return 0
}

stock bool:is_user_flashed(id) 
{     
	return ( get_pdata_float( id, m_flFlashedUntil, 5 ) > get_gametime( ) ); 
}

stock _find_primary_wpn_by_serial(szSerial[])
{
	for (new i = 0; i < g_weapon_count; i++)
	{
		new szWeaponSerial[128]
		TrieGetString(weapon_StringInfo[i], SECTION_WEAPON_SERIAL, szWeaponSerial, sizeof szWeaponSerial - 1)
		
		if (equal(szSerial, szWeaponSerial))
			return i
	}
	return -1
}

stock get_primary_wpn_id_by_model(szModel[])
{
	for (new i = 0; i < g_weapon_count; i++)
	{
		new szWorldModel[128]
		TrieGetString(weapon_StringInfo[i], SECTION_W_MODEL, szWorldModel, sizeof szWorldModel - 1)
		
		if (equal(szModel, szWorldModel))
			return i
	}
	return -1
}

stock can_player_equip_prim_wpn(id)
{
	ExecuteForward(ifw_UserCanEquipWpn, ifw_Result, id)
	
	if (ifw_Result != PLUGIN_CONTINUE)
		return 0
		
	return 1
}

stock can_player_change_double_wpn(id)
{
	ExecuteForward(ifw_UserCanUseSecFunc, ifw_Result, id)
	
	if (ifw_Result != PLUGIN_CONTINUE)
		return 0
		
	return 1
}

stock can_player_touch_wpnbox(id)
{
	ExecuteForward(ifw_UserCanTouchWpnBox, ifw_Result, id)
	
	if (ifw_Result != PLUGIN_CONTINUE)
		return 0
		
	return 1
}

stock can_player_touch_armoury(id)
{
	ExecuteForward(ifw_UserCanTouchArmoury, ifw_Result, id)
	
	if (ifw_Result != PLUGIN_CONTINUE)
		return 0
		
	return 1
}

stock do_active_nvg(id, iClearBit)
{
	
	if (!is_user_alive(id))
		return 
		
	if (is_user_bot(id))
		return
		
	if (!CheckPlayerBit(g_TurnOnNVG_BeforeThermal, id))
		return
		
	if (!fm_get_user_nightvision(id))
		return 
		
	if (iClearBit)
		ClearPlayerBit(g_TurnOnNVG_BeforeThermal, id)
		
	UT_SetUserNVG_State(id, 1, 0)
	
}

stock ForwardRegister()
{
	ifw_CheckPrimaryWpnSerial = CreateMultiForward("PW_WeaponCheckSerial", ET_CONTINUE, FP_STRING)
	ifw_FuncActivated = CreateMultiForward("PW_FunctionActivated", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL)
	ifw_ArmouryPickedUp = CreateMultiForward("PW_ArmouryPickedUp", ET_IGNORE, FP_CELL, FP_CELL)
	ifw_StartLoadData = CreateMultiForward("PW_WeaponLoadData", ET_IGNORE)
	
	
	ifw_UserCanTouchWpnBox = CreateMultiForward("PW_UserCanTouchWpnBox", ET_CONTINUE, FP_CELL)
	ifw_UserCanTouchArmoury = CreateMultiForward("PW_UserCanTouchArmoury", ET_CONTINUE, FP_CELL)
	ifw_UserCanUseSecFunc = CreateMultiForward("PW_UserCanUseSecFunc", ET_CONTINUE, FP_CELL)
	ifw_UserCanEquipWpn = CreateMultiForward("PW_UserCanEquipPrimWpn", ET_CONTINUE, FP_CELL)
	ifw_ArmouryEntitySpawn = CreateMultiForward("PW_ArmouryEntitySpawn", ET_CONTINUE, FP_CELL)
	
	ifw_GrenadeDamage = CreateMultiForward("PW_GrenadeDamage", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL, FP_CELL)
	
	ifw_WpnLoadedSucccessful = CreateMultiForward("PW_WeaponLoaded", ET_IGNORE, FP_CELL)
}

stock show_specific_view_model(id, iPrimaryWpnId, iWPN_FUNC)
{
		
	new szSpecViewModel[256]
	
	if (iWPN_FUNC & FUNC_ADS)
	{
		TrieGetString(weapon_StringInfo[iPrimaryWpnId], SECTION_ADS_V_MODEL, szSpecViewModel, sizeof szSpecViewModel - 1)
		set_pev(id, pev_viewmodel2, szSpecViewModel)
		return
	}
	
	if (iWPN_FUNC & FUNC_GRENADE_LAUNCHER)
	{
		TrieGetString(weapon_StringInfo[iPrimaryWpnId], SECTION_GREN_V_MODEL, szSpecViewModel, sizeof szSpecViewModel - 1)
		set_pev(id, pev_viewmodel2, szSpecViewModel)
		
	}
	
}

stock reset_view_model(id, iPrimaryWpnId)
{
	new szViewModel[256]
	TrieGetString(weapon_StringInfo[iPrimaryWpnId], SECTION_V_MODEL, szViewModel, sizeof szViewModel - 1)
					
	set_pev(id, pev_viewmodel2, szViewModel)
}

stock is_valid_grenade(iGrenadeType)
{
	switch (iGrenadeType)
	{
		case PW_CLASS_EXPLOSIVE:
			return 1
		
		case PW_CLASS_FLASH:
			return 1
	}
	return 0
}

stock get_speed_vector(Float:start[3], Float:stop[3], Float:speed, Float:result[3])
{
	result[0] = stop[0] - start[0];
	result[1] = stop[1] - start[1];
	result[2] = stop[2] - start[2];
    
	new Float:length = vector_length(result);
    
	if(length > 0.0)
	{
		result[0] *= (speed / length);
		result[1] *= (speed / length);
		result[2] *= (speed / length);
	}
}



stock PW_do_special_attack(id, iEnt, iPrimaryWpnId, ucHandle, iButton, iClip, iOpenFire)
{
	if (CheckPlayerBit(g_SpecialBurstMode, id) && iOpenFire)
	{
		set_uc(ucHandle, UC_Buttons, iButton &= ~IN_ATTACK)
		console_cmd(id, "-attack")
		
		if (CheckPlayerBit(g_LauncherModeActivated, id))
			return
			
								
		new iMaxBurstAmmo
		TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BURST_BULLET, iMaxBurstAmmo)
		
		if (iMaxBurstAmmo > iClip)
			iMaxBurstAmmo = iClip
									
		for (new iBulletId = 0; iBulletId < iMaxBurstAmmo; iBulletId++)
			UT_MakeWpnPrimAtk(iEnt)
								
		
		new Float:fTimeDelayFm
		TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_TIME_FM_DELAY, fTimeDelayFm)	
		fm_set_next_attack(id, fTimeDelayFm)
	}
	else if (CheckPlayerBit(g_SpecialBurstFamas, id) && iOpenFire)
	{
		set_uc(ucHandle, UC_Buttons, iButton &= ~IN_ATTACK)
		console_cmd(id, "-attack")
							 
		if (CheckPlayerBit(g_LauncherModeActivated, id))
			return
			
		if (!iClip)
			return
			
		new iMaxBurstAmmo
		TrieGetCell(weapon_StringInfo[iPrimaryWpnId], SECTION_BURST_BULLET, iMaxBurstAmmo)
		
		new iParam[3]
									
		iParam[0] = iPrimaryWpnId
		iParam[1] = iEnt
		iParam[2] = iMaxBurstAmmo - 1
											
										
		ExecuteHamB(Ham_Weapon_PrimaryAttack, iEnt)
		fm_set_next_attack(id, 9999.0)						
		set_task(BURST_CYCLE, "DoFamasBurst_TASK", id + TASK_FAMAS_BURST, iParam, sizeof iParam) 
		
	}
}

stock is_movement_cause_damage(iMoveType)
{
	switch (iMoveType)
	{
		case MOVETYPE_FOLLOW, MOVETYPE_NOCLIP, MOVETYPE_NONE:
			return 0
	}
	return 1
}

stock set_v_SubBody(id, iSubBody)
{
	if (!is_user_connected(id))
		return
		
	if (is_user_bot(id))
		return
		
	MMCL_SetViewEntityBody(id, iSubBody)
}



stock set_user_shield(id, iEnt, iToggle)
{
	if (!iToggle)
	{
		set_pev(id, pev_gamestate, 1) 
		return 
	}
	
	
	
	set_pdata_int(id, m_fHasPrimary, 1)
	set_pev(id, pev_gamestate, 0)
		
	
	//	This function makes your weapon not able to FIRE 
	
	
	const WEAPONSTATE_SHIELD_DRAW = (1<<5)
	set_pdata_int(iEnt, m_fWeaponState, WEAPONSTATE_SHIELD_DRAW, 4)
	
}

stock set_grenade_launcher_ammo(id, iAmmo, iBpa)
{
	if (!is_user_connected(id))
		return
		
	if (iAmmo > -1)
		set_trie_int(iPlayerInfo[id], SECTION_GRENADE_CLIP, iAmmo)
		
	if (iBpa > -1)	
		set_trie_int(iPlayerInfo[id], SECTION_GRENADE_BPA, iBpa)
}




stock get_trie_int(Trie:iTrieId, szKey[], iDefaultOutput = 0)
{
	if (!iTrieId)
		return iDefaultOutput
		
	if (!TrieKeyExists(iTrieId, szKey))
		return iDefaultOutput
		
	new iOutput
	TrieGetCell(iTrieId, szKey, iOutput)
	return iOutput
}

stock set_trie_int(Trie:iTrieId, szKey[], iInput)
{
	if (!iTrieId)
		return
		
	TrieSetCell(iTrieId, szKey, iInput)
}

stock Float:get_trie_float(Trie:iTrieId, szKey[], Float:fDefaultOutput = 0.0)
{
	if (!iTrieId)
		return fDefaultOutput
		
	if (!TrieKeyExists(iTrieId, szKey))
		return fDefaultOutput
		
	TrieGetCell(iTrieId, szKey, fDefaultOutput)
	return fDefaultOutput
}

stock set_trie_float(Trie:iTrieId, szKey[], Float:fInput)
{
	if (!iTrieId)
		return
		
	TrieSetCell(iTrieId, szKey, fInput)
}

stock delete_trie_key(Trie:iTrieId, szKey[])
{
	if (!iTrieId)
		return 0
		
	if (!TrieKeyExists(iTrieId, szKey))
		return 0
		
	TrieDeleteKey(iTrieId, szKey)
	return 1
}



stock fm_get_active_item(id)
	return get_pdata_cbase(id, m_pActiveItem, 5)

stock Float:fm_get_next_attack(id)
	return get_pdata_float(id, m_flNextAttack, 5)

stock fm_set_next_attack(id, Float:fTime)
	set_pdata_float(id, m_flNextAttack, fTime, 5)

stock fm_set_last_zoom(id, iFOV)
	set_pdata_int(id, m_iLastZoom, iFOV, 5)

stock fm_set_resume_zoom(id, bool:bToggle)
	set_pdata_int(id, m_fResumeZoom, bToggle, 5)

stock fm_set_accuracy(iEnt, Float:fAccuracy)
	set_pdata_float(iEnt, m_flAccuracy, fAccuracy, 4)

stock fm_get_weapon_id(iEnt)
	return get_pdata_int(iEnt, m_iId, 4)

stock fm_set_weapon_id(iEnt, iWeaponId)
	set_pdata_int(iEnt, m_iId, iWeaponId, 4)


stock fm_get_weapon_reload(iEnt)
	return get_pdata_int(iEnt, m_fInReload, 4)

stock fm_set_weapon_reload(iEnt, iToggle)
	set_pdata_int(iEnt, m_fInReload, iToggle, 4)


stock fm_set_weapon_special_reload(iEnt, iToggle)
	set_pdata_int(iEnt, m_fInSpecialReload, iToggle, 4)

stock fm_get_weapon_special_reload(iEnt)
	return get_pdata_int(iEnt, m_fInSpecialReload, 4)

stock fm_set_user_nightvision(id, iToggle, iTurnOn = 0)
{
	iToggle?set_pdata_int(id, m_bGotNVG, 1, 5):set_pdata_int(id, m_bGotNVG, 0, 5)
	iTurnOn?set_pdata_int(id, m_bIsNVGSwitchedOn, 1, 5):set_pdata_int(id, m_bIsNVGSwitchedOn, 0, 5)
}

stock fm_get_user_nightvision(id)
	return get_pdata_int(id, m_bGotNVG, 5)
/*************************************************************************************/

stock DefaultDeploy(id, iEnt, iWeaponId)
{	
	new szCsModel[32]
	new szWeaponModel[128]
	
	UT_Get_CS_WpnModel(iWeaponId, szCsModel, sizeof szCsModel - 1)
	
	if (strlen(szCsModel) > 0)
	{
		/*		V MODEL			*/
		formatex(szWeaponModel, sizeof szWeaponModel - 1, "models/v_%s.mdl", szCsModel)
		set_pev(id, pev_viewmodel2, szWeaponModel)
		MMCL_SetViewEntityBody(id, 0)
		
		/*		P MODEL			*/
		set_pev(id, pev_weaponmodel2, "")
		formatex(szWeaponModel, sizeof szWeaponModel - 1, "models/p_%s.mdl", szCsModel)
		engfunc(EngFunc_SetModel, iEnt, szWeaponModel)	
		set_pev(iEnt, pev_body, 0)
		fm_set_entity_visibility(iEnt, 1)
	}
	
	new iShield = cs_get_user_shield(id)
	new iSilen = cs_get_weapon_silen(iEnt)
	
	new szAnimExtension[32]
	UT_GetWeaponExtension(iWeaponId, iShield, szAnimExtension, sizeof szAnimExtension - 1)
	UT_SetPlayerSequence(id, szAnimExtension)
	
	new iDrawAnimation = Get_CSWPN_Anim_Draw(iWeaponId, iSilen, iShield)
	UT_PlayWeaponAnim(id, iDrawAnimation)

	set_pdata_float(id, m_flNextAttack, 0.75, 5)
	set_pdata_float(iEnt, m_flTimeWeaponIdle, 1.5, 4)
	set_pdata_float(iEnt, m_flDecreaseShotsFired, get_gametime(), 4)
	
	set_pdata_int(id, m_iFOV, 90, 5)
	set_pdata_bool(id, m_fResumeZoom, false, 5)
	set_pdata_int(id, m_iLastZoom, 90, 5)
	
}

stock load_bulletinfo(szWpnDirectory[], szFileName[], szExtension[], iBulletType, iPrimaryWpnId)
{
	new szLoadingFile[256]
	new szCfgDir[128]
	
	get_configsdir(szCfgDir, sizeof szCfgDir - 1)
		
	if (iBulletType == BULLET_TYPE_EXPLOSIVE)
	{
		formatex(szLoadingFile, sizeof szLoadingFile - 1, "%s/%s/%s_exp.%s", szCfgDir, szWpnDirectory, szFileName, szExtension)
	
		if (!file_exists(szLoadingFile))
			return 0
			
		/**************************************************************************/
		new szText[64], iTextLen
		
		new szGrenType[3], szSpeed[5], szFallTime[10], szFlag[10]
		read_file(szLoadingFile, LINE_BULLET_INFO_3, szText, sizeof szText - 1, iTextLen)
		parse(szText, szGrenType, sizeof szGrenType - 1, szSpeed, sizeof szSpeed - 1, 
				szFallTime, sizeof szFallTime - 1,
				szFlag, sizeof szFlag - 1)
			
		new iBulletFlag = read_flags(szFlag)
			
		TrieSetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_GREN_TYPE, str_to_num(szText))
		TrieSetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_VELOCITY, str_to_num(szSpeed))
		TrieSetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_FALL_TIME, str_to_float(szFallTime))
		TrieSetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_FLAG, iBulletFlag)
			
		/**************************************************************************/
			
			
		new szModel[200], szSubBody[3]
		read_file(szLoadingFile, LINE_BULLET_INFO_2, szText, sizeof szText - 1, iTextLen)
		replace(szText, sizeof szText - 1, "[iBulletModel]", "")
		parse(szText, szModel, sizeof szModel - 1, szSubBody, sizeof szSubBody - 1)
			
		TrieSetString(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_GRENADE_MODEL, szModel)
		if (!TrieKeyExists(iPrecachedModel, szModel))
		{
			engfunc(EngFunc_PrecacheModel, szModel)
			TrieSetCell(iPrecachedModel, szModel, 1)
		}
		TrieSetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_GRENADE_SUB, str_to_num(szSubBody))
			
		/**************************************************************************/
			
		new szRadius[10], szSprite[32], szFramerate[5], szScale[5], szBrightness[5], szSound[32], szActiveTime[10], szDetonateTime[10]
		read_file(szLoadingFile, LINE_BULLET_INFO_3, szText, sizeof szText - 1, iTextLen)
		replace(szText, sizeof szText - 1, "[iBulletExpCfg]", "")
		parse(szText, szRadius, sizeof szRadius - 1, szSprite, sizeof szSprite - 1,
				szFramerate, sizeof szFramerate - 1, szScale, sizeof szScale - 1,
				szBrightness, sizeof szBrightness - 1,
				szSound, sizeof szSound - 1,
				szActiveTime, sizeof szActiveTime - 1, szDetonateTime, sizeof szDetonateTime - 1)
			
			
		TrieSetCell(iBulletConfig[iPrimaryWpnId], SECTION_DMG_RADIUS, str_to_float(szRadius))
			
		new szBuffer[256]
		formatex(szBuffer, sizeof szBuffer - 1, "sprites/%s.spr", szSprite)
			
		TrieSetCell(iBulletConfig[iPrimaryWpnId], SECTION_SPR_INDEX, engfunc(EngFunc_PrecacheModel, szBuffer))
		TrieSetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_SPR_FRAME, str_to_num(szFramerate))
		TrieSetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_SPR_SCALE, str_to_num(szScale))
		TrieSetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_SPR_BN, str_to_num(szBrightness))
			
		formatex(szBuffer, sizeof szBuffer - 1, "weapons/%s.wav", szSound)
		engfunc(EngFunc_PrecacheSound, szSound)
		TrieSetString(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_SOUND, szSound)
			
		TrieSetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_ACTIVE_TIME, str_to_float(szActiveTime))
		TrieSetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_REMOVE_TIME, str_to_float(szDetonateTime))
			
		/**************************************************************************/
			
		if (iBulletFlag & TRAIL_ON_MOVE)
		{
			read_file(szLoadingFile, LINE_BULLET_INFO_4, szText, sizeof szText - 1, iTextLen)
			replace(szText, sizeof szText - 1, "[iBulletTrail]", "")
			new szSprite[64], szRed[10], szGreen[10], szBlue[10], szWidth[10], szBrightness[5], szLife[5]
			parse(szText, szSprite, sizeof szSprite - 1, 
			szRed, sizeof szRed - 1, szGreen, sizeof szGreen - 1, szBlue, sizeof szBlue - 1, 
			szWidth, sizeof szWidth - 1,
				  szBrightness, sizeof szBrightness - 1, szLife, sizeof szLife - 1)
				
					
			TrieSetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_RED, str_to_num(szRed))
			TrieSetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_GREEN, str_to_num(szGreen))
			TrieSetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_BLUE, str_to_num(szBlue))
			TrieSetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_TW, str_to_num(szWidth))
				
			new szSprFullName[256]
			formatex(szSprFullName, sizeof szSprFullName - 1, "sprites/%s.spr", szSprite)
				
			if (TrieKeyExists(iPrecachedModel, szSprFullName))
				TrieSetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_TSPR, engfunc(EngFunc_ModelIndex, szSprFullName))
			else
			{
				TrieSetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_TSPR, engfunc(EngFunc_PrecacheModel, szSprFullName))
				TrieSetCell(iPrecachedModel, szSprFullName, 1)
			}
				
			TrieSetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_TRBN, str_to_num(szBrightness))
			TrieSetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_TRL, str_to_num(szLife))
		}
			
		if (iBulletFlag & TRAIL_ON_DETONATE)
		{
			read_file(szLoadingFile, LINE_BULLET_INFO_5, szText, sizeof szText - 1, iTextLen)
			replace(szText, sizeof szText - 1, "[iBulletTrail2]", "")
			new szSprite[64], szRed[10], szGreen[10], szBlue[10], szWidth[10], szBrightness[5], szLife[5]
			parse(szText, szSprite, sizeof szSprite - 1, 
				szRed, sizeof szRed - 1, szGreen, sizeof szGreen - 1, szBlue, sizeof szBlue - 1, 
				szWidth, sizeof szWidth - 1,
					  szBrightness, sizeof szBrightness - 1, szLife, sizeof szLife - 1)
				
					
			TrieSetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_RED_2, str_to_num(szRed))
			TrieSetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_GREEN_2, str_to_num(szGreen))
			TrieSetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_BLUE_2, str_to_num(szBlue))
			TrieSetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_TW_2, str_to_num(szWidth))
				
			new szSprFullName[256]
			formatex(szSprFullName, sizeof szSprFullName - 1, "sprites/%s.spr", szSprite)
			
			if (TrieKeyExists(iPrecachedModel, szSprFullName))
				TrieSetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_TSPR_2, engfunc(EngFunc_ModelIndex, szSprFullName))
			else
			{
				TrieSetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_TSPR_2, engfunc(EngFunc_PrecacheModel, szSprFullName))
				TrieSetCell(iPrecachedModel, szSprFullName, 1)
			}
			
			TrieSetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_TRBN_2, str_to_num(szBrightness))
			TrieSetCell(iBulletConfig[iPrimaryWpnId], SECTION_BULLET_TRL_2, str_to_num(szLife))
		}
			
			
		/**************************************************************************/
	}
	else if (iBulletType == BULLET_TYPE_SHOTGUN)
	{
		new szText[64], iTextLen
		
		formatex(szLoadingFile, sizeof szLoadingFile - 1, "%s/%s/%s_sg.%s", szCfgDir, szWpnDirectory, szFileName, szExtension)
	
		if (!file_exists(szLoadingFile))
			return 0
			
		read_file(szLoadingFile, LINE_BULLET_INFO, szText, sizeof szText - 1, iTextLen)
		replace(szText, sizeof szText - 1, "[iBulletInfo]", "")
		new szPiece[5], szSpread[10]
		parse(szText, szPiece, sizeof szPiece - 1, szSpread, sizeof szSpread - 1)
		
		TrieSetCell(iBulletConfig[iPrimaryWpnId], SECTION_SHOTGUN_PIECE, str_to_num(szPiece) - 1)
		TrieSetCell(iBulletConfig[iPrimaryWpnId], SECTION_SHOTGUN_SPREAD, str_to_float(szSpread))
	}
	
	return 1
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
