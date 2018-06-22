/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>


#include <GamePlay_Included/GamePlay_ZM.inc>

#define PLUGIN "Smoke Zombie"
#define VERSION "1.0"
#define AUTHOR "Nguyen Duy Linh"

#define SMOKE_ZOMBIE_NAME "Smoke Zombie"
#define SMOKE_ZOMBIE_MODEL_1 "SmokeZombie"
#define SMOKE_ZOMBIE_MODEL_2 "SmokeZombie"
#define SMOKE_ZOMBIE_MODEL_3 "SmokeZombie"
#define SMOKE_HAND "SmokeZombieHand"
#define SMOKE_V_GRENADE "models/g4u_wpn/SmokeZombieGrenade/v_SmokeZombieGrenade.mdl"
#define SMOKE_P_GRENADE "models/g4u_wpn/witch_grenade/p_witch_grenade.mdl"
#define SMOKE_W_GRENADE "models/g4u_wpn/witch_grenade/w_witch_grenade.mdl"

#define SMOKE_ZOMBIE_HUD_KILL "SmokeHand"
#define SMOKE_HEALTH_HUD "SMK_ZOMBIE"

#define SMOKE_HEALTH_1 3000.0
#define SMOKE_HEALTH_2 3500.0
#define SMOKE_HEALTH_3 3700.0

#define SMOKE_GRAVITY_1 1.1125
#define SMOKE_GRAVITY_2 1.1
#define SMOKE_GRAVITY_3 1.05

#define SMOKE_SPEED_1 265.0
#define SMOKE_SPEED_2 275.0
#define SMOKE_SPEED_3 282.0

#define SMOKE_REDUCE_DMG_1 0.0
#define SMOKE_REDUCE_DMG_2 10.0
#define SMOKE_REDUCE_DMG_3 25.0

#define SMOKE_SOUND_DIRECTORY "default_zombie"
#define SMOKE_EXP_SOUND "weapons/flashbang_explode1.wav"
#define SMOKE_COST_TYPE 2
#define SMOKE_COST 60

#define SMOKE_KnockBack_1 2.5
#define SMOKE_KnockBack_2 2.25
#define SMOKE_KnockBack_3 2.05

#define SMOKE_DMG_ARMOR_1 100.0
#define SMOKE_DMG_ARMOR_2 110.0
#define SMOKE_DMG_ARMOR_3 150.0

#define LEVEL_USE_SKILL 1
#define SKILL_HEALTH_1 1720
#define SKILL_HEALTH_2 1250
#define SKILL_HEALTH_3 500

#define SKILL_DURATION 15.0
#define SKILL_ACTIVE_TIME 25.0

#define TASK_CREATE_SMOKE 2500
#define TASK_REMOVE_SMOKE 5000
#define TASK_CZ_FUNCTION 7000

#define LANGUAGE_FILE "SmokeZombie.txt"
#define SMOKE_LIFE_TIME 1
#define SMOKE_ACTIVE_TIME 1.5
#define GRENADE_LIFE_TIME 15.0
#define SMK_GRENADE_ZOMBIE 01041994
#define SMK_CREATE_TIME 0.5

#define pev_iGrenadeId pev_iuser1
#define pev_iFirstTime pev_iuser2
#define pev_fLifeTime pev_fuser1

#define SMK_GRENADE_CLASS "SmkGrenadeZb"
#define SMK_EXP_SOUND "weapons/g4u_wpn/SMK_GRN_EXP.wav"

#define ZOMBIE_GENDER ZB_GENDER_MALE

new SKILL_HEALTH_COST[] = {0, SKILL_HEALTH_1, SKILL_HEALTH_2, SKILL_HEALTH_3}
new SMOKE_NVG_COLOR[] = {236, 156, 18}

new iSmokeClass

new Float:f_SkillActivatedTime[33]
new bool:bCreatingSmoke[33]
new Float:fSmokeOrigin[33][3]
new iSmokeSpriteId 
new iHamCz // , iHamEnt
public ZmMain_StartRegisterClass() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_dictionary(LANGUAGE_FILE)
	iSmokeClass = g4u_create_zombie_class(SMOKE_ZOMBIE_NAME)
	
	if (iSmokeClass < 0)
		return 
		
	g4u_set_class_model(iSmokeClass, SMOKE_ZOMBIE_MODEL_1, SMOKE_ZOMBIE_MODEL_2, SMOKE_ZOMBIE_MODEL_3)
	g4u_set_zombie_hand(iSmokeClass, SMOKE_HAND, SMOKE_HAND, SMOKE_HAND)
	g4u_set_zombie_hud(iSmokeClass, SMOKE_ZOMBIE_HUD_KILL, SMOKE_HEALTH_HUD)
	g4u_set_zombie_health(iSmokeClass, SMOKE_HEALTH_1, SMOKE_HEALTH_2, SMOKE_HEALTH_3)
	g4u_set_zombie_gravity(iSmokeClass, SMOKE_GRAVITY_1, SMOKE_GRAVITY_2, SMOKE_GRAVITY_3)
	g4u_set_zombie_speed(iSmokeClass, SMOKE_SPEED_1, SMOKE_SPEED_2, SMOKE_SPEED_3)
	g4u_set_zombie_damage(iSmokeClass, SMOKE_REDUCE_DMG_1, SMOKE_REDUCE_DMG_2, SMOKE_REDUCE_DMG_3)
	g4u_set_zombie_sound(iSmokeClass, SMOKE_SOUND_DIRECTORY)
	g4u_set_zombie_price(iSmokeClass, SMOKE_COST_TYPE, SMOKE_COST)
	g4u_set_zombie_knockback(iSmokeClass, SMOKE_KnockBack_1, SMOKE_KnockBack_2, SMOKE_KnockBack_3)
	g4u_set_zombie_dmg_armor(iSmokeClass, SMOKE_DMG_ARMOR_1, SMOKE_DMG_ARMOR_2, SMOKE_DMG_ARMOR_3)
	g4u_set_zombie_NVG_Option(iSmokeClass, SMOKE_NVG_COLOR[0], SMOKE_NVG_COLOR[1], SMOKE_NVG_COLOR[2], 40, 30)
	g4u_set_zombie_gender(iSmokeClass, ZOMBIE_GENDER)
	
	register_event("CurWeapon", "fw_checkweapon", "b", "1=1")
	
	iSmokeSpriteId = engfunc(EngFunc_PrecacheModel, "sprites/gas_smoke4.spr")
	engfunc(EngFunc_PrecacheModel, SMOKE_V_GRENADE)
	engfunc(EngFunc_PrecacheModel, SMOKE_P_GRENADE)
	engfunc(EngFunc_PrecacheModel, SMOKE_W_GRENADE)
	
	engfunc(EngFunc_PrecacheSound, SMOKE_EXP_SOUND)
	engfunc(EngFunc_PrecacheSound, SMK_EXP_SOUND)
	iHamCz = 0
	
	register_forward(FM_SetModel, "fw_SetModelPost", 1)
	
	RegisterHam(Ham_Think, "grenade", "fw_SmkThink")
	RegisterHam(Ham_Spawn, "player", "fw_PlayerRespawnPost", 1)
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilledPost", 1)
	RegisterHam(Ham_TakeDamage, "player", "fw_PlayerTakeDmg")
}

public client_putinserver(id)
	set_task(0.1, "RegisterCzFunction", id + TASK_CZ_FUNCTION)
	
public RegisterCzFunction(TASKID)
{
	new id = TASKID - TASK_CZ_FUNCTION
	
	if (!is_user_bot(id))
		return
		
	if (!get_cvar_num("bot_quota"))
		return
		
	if (iHamCz)
		return
		
	RegisterHamFromEntity(Ham_Spawn, id, "fw_PlayerRespawnPost", 1)
	RegisterHamFromEntity(Ham_Killed, id, "fw_PlayerKilledPost", 1)
	RegisterHamFromEntity(Ham_TakeDamage, id, "fw_PlayerTakeDmg")
	iHamCz = 1
}

public fw_PlayerRespawnPost(id)
{
	bCreatingSmoke[id] = false
	remove_task(id + TASK_CREATE_SMOKE)
	remove_task(id + TASK_REMOVE_SMOKE)
}

public fw_PlayerKilledPost(iVictim, iKiller)
{
	bCreatingSmoke[iVictim] = false
	remove_task(iVictim + TASK_CREATE_SMOKE)
	remove_task(iVictim + TASK_REMOVE_SMOKE)
}

public fw_PlayerTakeDmg(iVictim, iEnt, iAttacker, Float:fDamage, DMG_BIT)
{
	new iMaxPlayers = get_maxplayers()
	
	if (!(1<= iVictim <= iMaxPlayers))
		return HAM_IGNORED
		
	if (!is_user_alive(iVictim))
		return HAM_IGNORED
		
	if (!g4u_get_user_zombie(iVictim))
		return HAM_IGNORED
		
	if (g4u_get_zombie_class(iVictim) != iSmokeClass)
		return HAM_IGNORED
		
	if ((DMG_BIT & DMG_BURN) || (DMG_BIT & DMG_BLAST))
		return HAM_SUPERCEDE
		
	return HAM_IGNORED
}
		
public g4u_user_skill_post(id, iClass)
{
	if (!is_user_alive(id))
		return 
	
	if (iClass != iSmokeClass)
		return
		
	new iLevel = g4u_get_zombie_level(id)
	if ( iLevel < LEVEL_USE_SKILL)
	{
		client_print(id, print_center, "%L", id, "NOT_ENOUGH_LEVEL_TO_USE")
		return
	}
	
	new iHealth = get_user_health(id)
	
	if (iHealth < SKILL_HEALTH_COST[iLevel])
	{
		client_print(id, print_center, "%L", id, "NOT_ENOUGH_HP", SKILL_HEALTH_COST[iLevel])
		return
	}
	
	new Float:fCurrentTime = get_gametime()
	
	if (fCurrentTime - f_SkillActivatedTime[id] < SKILL_ACTIVE_TIME)
	{
		client_print(id, print_center, "%L", id, "WAIT_TO_REACTIVE_SKILL", floatround(SKILL_ACTIVE_TIME - (fCurrentTime - f_SkillActivatedTime[id])))
		return
	}
	
	if (task_exists(id + TASK_CREATE_SMOKE))
		remove_task(id + TASK_CREATE_SMOKE)
		
	if (task_exists(id + TASK_REMOVE_SMOKE))
		remove_task(id + TASK_REMOVE_SMOKE)
		
	set_task(SKILL_DURATION, "fw_DeactiveSkill", id + TASK_REMOVE_SMOKE)
	set_task(float(SMOKE_LIFE_TIME), "fw_CreateSmoke", id + TASK_CREATE_SMOKE, _, _, "b")
	pev(id, pev_origin, fSmokeOrigin[id])
	
	f_SkillActivatedTime[id] = fCurrentTime
	bCreatingSmoke[id] = true
	emit_sound(id, CHAN_AUTO, SMOKE_EXP_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	
	
}

public zm3_zombie_strip_weapon(id, iWeaponId)
{
	if (g4u_get_zombie_class(id) != iSmokeClass)
		return PLUGIN_CONTINUE
		
	if (iWeaponId != CSW_HEGRENADE)
		return PLUGIN_CONTINUE
		
	return PLUGIN_HANDLED
}

public g4u_user_become_zombie(id)
{
	if (g4u_get_zombie_class(id) != iSmokeClass)
		return PLUGIN_CONTINUE
		
	fm_give_item(id, "weapon_hegrenade")
	engclient_cmd(id, "weapon_hegrenade")
	
	return PLUGIN_CONTINUE
}

public zm3_zombie_touch_weapon(id, iEnt)
{
	if (g4u_get_zombie_class(id) != iSmokeClass)
		return PLUGIN_CONTINUE
	
	new iWeaponId = get_pdata_int(iEnt, 43, 4)
	if (iWeaponId != CSW_HEGRENADE)
		return PLUGIN_CONTINUE
		
	return PLUGIN_HANDLED
}

public fw_DeactiveSkill(TASKID)
{
	new id = TASKID - TASK_REMOVE_SMOKE
	
	bCreatingSmoke[id] = false
}

public fw_CreateSmoke(TASKID)
{
	new id = TASKID - TASK_CREATE_SMOKE
	
	if (!(1<= id <= get_maxplayers()) || !is_user_alive(id) || !g4u_get_user_zombie(id) || g4u_get_zombie_class(id) != iSmokeClass || !bCreatingSmoke[id])
	{
		remove_task(TASKID)
		bCreatingSmoke[id] = false
		return
	}
	
	Create_Smoke_Group(fSmokeOrigin[id])
}

public fw_checkweapon(id)
{
	new iWeaponId = read_data(2)
	
	if (iWeaponId != CSW_HEGRENADE)
		return
		
	if (!g4u_get_user_zombie(id))
		return
		
	if (g4u_get_zombie_class(id) != iSmokeClass)
		return
		
	set_pev(id, pev_viewmodel2, SMOKE_V_GRENADE)
	set_pev(id, pev_weaponmodel2, SMOKE_P_GRENADE)
}

public fw_SetModelPost(iEnt, const Model[])
{
	if (!iEnt || !pev_valid(iEnt))
		return
		
	new id = pev(iEnt, pev_owner)
	
	if (!is_user_connected(id))
		return
		
	if (!g4u_get_user_zombie(id))
		return
		
	if (g4u_get_zombie_class(id) != iSmokeClass)
		return
		
	engfunc(EngFunc_SetModel, iEnt, SMOKE_W_GRENADE)
	set_pev(iEnt, pev_iGrenadeId, SMK_GRENADE_ZOMBIE)
	//set_pev(iEnt, pev_classname, SMK_GRENADE_CLASS)
	set_pev(iEnt, pev_nextthink, get_gametime() + SMOKE_ACTIVE_TIME)
	set_pev(iEnt, pev_fLifeTime, get_gametime() + GRENADE_LIFE_TIME)
	set_pev(iEnt, pev_iFirstTime, 1)
	/*if (!iHamEnt)
	{
		RegisterHamFromEntity(Ham_Think, iEnt, "fw_SmkThink")
		iHamEnt = 1
	}*/
	return
}

public fw_SmkThink(iEnt)
{
	if (!iEnt || !pev_valid(iEnt))
		return HAM_IGNORED
	
	if (pev(iEnt, pev_iGrenadeId) != SMK_GRENADE_ZOMBIE)
		return HAM_IGNORED
		
	new Float:fCurrentTime = get_gametime()
	new Float:fLifeTime 
	pev(iEnt, pev_fLifeTime, fLifeTime)
	
	if (fCurrentTime > fLifeTime)
	{
		engfunc(EngFunc_RemoveEntity, iEnt)
		return HAM_SUPERCEDE
	}
	
	if (pev(iEnt, pev_iFirstTime))
	{
		set_pev(iEnt, pev_iFirstTime, 0)
		emit_sound(iEnt, CHAN_AUTO, SMK_EXP_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
	}
	new Float:fOrigin[3]
	pev(iEnt, pev_origin, fOrigin)
	
	Create_Smoke_Group(fOrigin)
	//CreateSmoke(fOrigin)
	set_pev(iEnt, pev_nextthink, fCurrentTime + SMK_CREATE_TIME)
	return HAM_SUPERCEDE
}

stock CreateSmoke(Float:fOrigin[3])
{
	new iOrigin[3]
	
	FVecIVec(fOrigin, iOrigin)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_SMOKE)
	write_coord(iOrigin[0])
	write_coord(iOrigin[1])
	write_coord(iOrigin[2] + random_num(10, 75)) 
	write_short(iSmokeSpriteId)
	write_byte(random_num(100, 175))
	write_byte(0)
	message_end()
}
	
stock Create_Smoke_Group(Float:position[3])
{
	new Float:origin[12][3]
	get_spherical_coord(position, 40.0, 0.0, 0.0, origin[0])
	get_spherical_coord(position, 40.0, 90.0, 0.0, origin[1])
	get_spherical_coord(position, 40.0, 180.0, 0.0, origin[2])
	get_spherical_coord(position, 40.0, 270.0, 0.0, origin[3])
	get_spherical_coord(position, 100.0, 0.0, 0.0, origin[4])
	get_spherical_coord(position, 100.0, 45.0, 0.0, origin[5])
	get_spherical_coord(position, 100.0, 90.0, 0.0, origin[6])
	get_spherical_coord(position, 100.0, 135.0, 0.0, origin[7])
	get_spherical_coord(position, 100.0, 180.0, 0.0, origin[8])
	get_spherical_coord(position, 100.0, 225.0, 0.0, origin[9])
	get_spherical_coord(position, 100.0, 270.0, 0.0, origin[10])
	get_spherical_coord(position, 100.0, 315.0, 0.0, origin[11])
	
	for (new i = 0; i < 12; i++)
		create_Smoke(origin[i], iSmokeSpriteId, random_num(50, 75), 0)
}
stock create_Smoke(Float:position[3], sprite_index, iScale, framerate)
{
	//position[2] += random_float(-20.0, 10.0)
	// Alphablend sprite, move vertically 30 pps
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_SMOKE) // TE_SMOKE (5)
	engfunc(EngFunc_WriteCoord, position[0]) // position.x
	engfunc(EngFunc_WriteCoord, position[1]) // position.y
	engfunc(EngFunc_WriteCoord, position[2]) // position.z
	write_short(sprite_index) // sprite index
	write_byte(iScale) // scale in 0.1's
	write_byte(framerate) // framerate
	message_end()
}

stock get_spherical_coord(const Float:ent_origin[3], Float:redius, Float:level_angle, Float:vertical_angle, Float:origin[3])
{
	new Float:length
	length  = redius * floatcos(vertical_angle, degrees)
	origin[0] = ent_origin[0] + length * floatcos(level_angle, degrees)
	origin[1] = ent_origin[1] + length * floatsin(level_angle, degrees)
	origin[2] = ent_origin[2] + redius * floatsin(vertical_angle, degrees)
}

	
stock fm_give_item(index, const item[]) {
	if (!equal(item, "weapon_", 7) && !equal(item, "ammo_", 5) && !equal(item, "item_", 5) && !equal(item, "tf_weapon_", 10))
		return 0;

	new ent = fm_create_entity(item);
	if (!pev_valid(ent))
		return 0;

	new Float:origin[3];
	pev(index, pev_origin, origin);
	set_pev(ent, pev_origin, origin);
	set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN);
	dllfunc(DLLFunc_Spawn, ent);

	new save = pev(ent, pev_solid);
	dllfunc(DLLFunc_Touch, ent, index);
	if (pev(ent, pev_solid) != save)
		return ent;

	engfunc(EngFunc_RemoveEntity, ent);

	return -1;
}
	
 stock fm_create_entity(const classname[])
	return engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, classname))
	
	
		
