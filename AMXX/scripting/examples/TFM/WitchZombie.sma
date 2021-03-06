/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <engine>
#include <hamsandwich>
#include <csred_MsgTool>
#include <cstrike>
#include <csred_MsgTool>
#include <chr_engine>

#include <GamePlay_Included/GamePlay_ZM.inc>

#define PLUGIN "Witch Zombie"
#define VERSION "1.0"
#define AUTHOR "Nguyen Duy Linh"

#define TASK_OUT_OF_CONFUSION 1000
#define TASK_CZBOT_FUNCTION 3000
#define TASK_DISABLE_SKILL 5000
#define TASK_RELEASE_BAT 7000
#define TASK_BAT_SEARCH_ENERMY 10000

#define GRENADE_MAX_RANGE 300.0
#define CONFUSED_TIME 10.0
#define GRENADE_EXPLODE_SOUND "weapons/g4u_wpn/ConfusedBombExplode.wav"
#define LAUGH_VOICE "zombiemod/Banshee_LaughVoice.wav"

const UNIT_SECOND = (1<<12)
const FFADE_IN = 0x0000

#define ZOMBIE_NAME "WITCH_ZOMBIE"
#define ZOMBIE_MODEL "witch_zombie"
#define ZOMBIE_HAND "witch_knife"
#define ZOMBIE_HEALTH_HUD "WITCH"
#define ZOMBIE_HUD_KILL "WITCH_HAND"
#define ZOMBIE_HUD_GRENADE "WITCH_GRENADE"
#define SOUND_DIRECTORY "default_zombie"
#define ZOMBIE_GRENADE_NAME "Confused Bomb"

#define ZOMBIE_COST_TYPE  1
#define ZOMBIE_COST 35500

#define ZOMBIE_GENDER ZB_GENDER_FEMALE

new iClass = -1

#define V_GRENADE_MODEL "models/g4u_wpn/witch_grenade/v_witch_grenade.mdl"
#define P_GRENADE_MODEL "models/g4u_wpn/witch_grenade/p_witch_grenade.mdl"
#define W_GRENADE_MODEL "models/g4u_wpn/witch_grenade/w_witch_grenade.mdl"
#define BANSHEE_SKILLTIME 12.0
#define BANSHEE_SKILDURATION 4.5
#define SKILL_HEALTH_COST 500


#define BAT_MODEL "models/g4u_wpn/Bats/w_Bats.mdl"
#define BAT_CLASS "Bats"
#define BAT_LIFE 3.0
#define BAT_SPEED 500
#define BAT_CATCH_HUMAN_SPEED 170.0
#define BAT_SPRITE "sprites/BatDestroyed.spr"

new iBatSpriteIndex, iBatModelIndex

#define RELEASE_BAT_WAIT 1.0



new g_msgScreenFade
new iMaxPlayers
new iHamCZ
new Float:fSkillTime[33]
new g_exploSpr

new iInSkill[33], iBatEnt[33], iTouchedEnt[33]

new WeaponClass[][] = {"weapon_glock18", "weapon_usp", "weapon_deagle", "weapon_p228", "weapon_elite", "weapon_fiveseven",
			"weapon_m3", "weapon_xm1014",
			"weapon_mp5navy", "weapon_tmp", "weapon_p90", "weapon_mac10", "weapon_ump45",
			"weapon_famas", "weapon_galil", "weapon_ak47" ,"weapon_sg552", "weapon_m4a1", "weapon_aug", "weapon_scout", "weapon_awp", "weapon_g3sg1", "weapon_sg550",
			"weapon_m249"
}
			
const m_flNextAttack		= 83
	
new Float:fStoreSpeed[33]

#define ANIM_IDLE 1
#define ANIM_START_SKILL 151
#define ANIM_HOLD_SKILL 152

//	BIT TOOLS

#define SetPlayerBit(%1,%2)      (%1 |= (1<<(%2&31)))
#define ClearPlayerBit(%1,%2)    (%1 &= ~(1 <<(%2&31)))
#define CheckPlayerBit(%1,%2)    (%1 & (1<<(%2&31)))

new b_IsBeingConfused
new b_SetSequence

public ZmMain_StartRegisterClass()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	if (!g4u_get_zombie_toggle())
		return
	iClass = g4u_create_zombie_class(ZOMBIE_NAME)
	if (iClass < 0)
		return
	g4u_set_class_model(iClass, ZOMBIE_MODEL, ZOMBIE_MODEL, ZOMBIE_MODEL)
	g4u_set_zombie_hand(iClass, ZOMBIE_HAND, ZOMBIE_HAND, ZOMBIE_HAND)
	g4u_set_zombie_hud(iClass, ZOMBIE_HUD_KILL, ZOMBIE_HEALTH_HUD)
	g4u_set_zombie_health(iClass, 2700.0, 3500.0, 4000.0)
	g4u_set_zombie_gravity(iClass, 1.0, 0.95, 0.9)
	g4u_set_zombie_speed(iClass, 250.0, 260.0, 275.0)
	g4u_set_zombie_damage(iClass, 25.0, 30.0, 35.0)
	g4u_set_zombie_sound(iClass, SOUND_DIRECTORY)
	g4u_set_zombie_price(iClass, ZOMBIE_COST_TYPE, ZOMBIE_COST)
	g4u_set_zombie_knockback(iClass, 3.15, 2.75, 1.885)
	csred_set_zb_set_gren_hud(iClass, ZOMBIE_HUD_GRENADE, 127)
	csred_set_gren_name(iClass, ZOMBIE_GRENADE_NAME)
	g4u_set_zombie_dmg_armor(iClass, 80.0, 100.0, 125.0)
	g4u_set_zombie_NVG_Option(iClass, 26, 226, 230, 56, 50)
	g4u_set_zombie_gender(iClass, ZOMBIE_GENDER)
	
	g_msgScreenFade = get_user_msgid("ScreenFade")
	iMaxPlayers = get_maxplayers()
	iHamCZ = 0
	//register_clcmd("drop", "clcmd_DropWeapon")
	//register_clcmd("confusedme", "test")
	register_event("CurWeapon", "fw_checkweapon", "b", "1=1")
	
	register_touch(BAT_CLASS, "*", "fw_BatTouched")
	register_think("WitchGrenade", "fw_WitchGrenadeThink")
	register_think(BAT_CLASS, "fw_BatThink")
	
	register_forward(FM_SetModel, "fw_SetModelPost", 1)
	register_forward(FM_AddToFullPack, "fw_AddToFullPackPost", 1)
	register_forward(FM_PlayerPreThink, "fw_PlayerPostThink")
	
	RegisterHam(Ham_Spawn, "player", "fw_SpawnPost", 1)
	RegisterHam(Ham_Killed, "player", "fw_KilledPost", 1)
	
	engfunc(EngFunc_PrecacheSound, GRENADE_EXPLODE_SOUND)
	engfunc(EngFunc_PrecacheModel, V_GRENADE_MODEL)
	engfunc(EngFunc_PrecacheModel, P_GRENADE_MODEL)
	engfunc(EngFunc_PrecacheModel, W_GRENADE_MODEL)
	g_exploSpr = engfunc(EngFunc_PrecacheModel, "sprites/shockwave.spr")
	iBatModelIndex = engfunc(EngFunc_PrecacheModel, BAT_MODEL)
	iBatSpriteIndex = engfunc(EngFunc_PrecacheModel, BAT_SPRITE)
	engfunc(EngFunc_PrecacheSound, LAUGH_VOICE)
	register_clcmd("lastinv", "CmdINV")
	register_clcmd("invpev", "CmdINV")
	register_clcmd("invnext", "CmdINV")
}

public plugin_cfg()
{
	if (!g4u_get_zombie_toggle())
	{
		set_fail_state("Can't create Zombie Class because Zombie Mod is OFF")
		return
	}
}

public CmdINV(id)
{
	if (!is_user_alive(id))
		return PLUGIN_CONTINUE
	
	if (!g4u_get_user_zombie(id))
		return PLUGIN_CONTINUE
		
	if (g4u_get_zombie_class(id) != iClass)
		return PLUGIN_CONTINUE
		
	if (!iInSkill[id])
		return PLUGIN_CONTINUE
		
	return PLUGIN_HANDLED
}

public client_putinserver(id)
{
	
	if (is_user_bot(id))
		set_task(0.1, "RegisterCZFunction", id + TASK_CZBOT_FUNCTION)
}

public RegisterCZFunction(TASKID)
{
	new id = TASKID - TASK_CZBOT_FUNCTION	
	if (!is_user_connected(id))
		return
	
	if (!is_user_bot(id))
		return
		
	if (!get_cvar_num("bot_quota"))
		return
		
	if (iHamCZ)
		return
		
	RegisterHamFromEntity(Ham_Spawn, id, "fw_SpawnPost", 1)
	RegisterHamFromEntity(Ham_Killed, id, "fw_KilledPost", 1)
	iHamCZ = 1
}

public g4u_user_skill_post(id, MyClass)
{
	if (MyClass != iClass)
		return 
		
	new Float:fCurrentTime = get_gametime()
	
	if (fCurrentTime - fSkillTime[id] < BANSHEE_SKILLTIME)
		return 
	
	if (get_user_weapon(id) != CSW_KNIFE)
		engclient_cmd(id, "weapon_knife")
		
	new Float:flNextAttack = get_pdata_float(id, m_flNextAttack, 5)
		
	if (flNextAttack > 0.0)
		return
		
	new iDucking = pev(id, pev_flags) & (FL_DUCKING)
	if (iDucking)
	{
		if (iBatEnt[id] && pev_valid(iBatEnt[id]))
		{
			call_think(iBatEnt[id])
			return
		}
	}
	
	new iFlag = pev(id, pev_flags)
	new iOnGround = ((iFlag & (FL_ONGROUND)) || (iFlag & (FL_ONTRAIN)))
	
	if (!iOnGround)
		return
	
	
	new iEnt = find_ent_by_owner(-1, "weapon_knife", id)
	
	if (!iEnt)
		return
		
	new iHealth = get_user_health(id)
	new iBOT = is_user_bot(id)
	if (iHealth < SKILL_HEALTH_COST && !iBOT)
		return
	
	if (!iBOT)
		set_pev(id, pev_health, float(iHealth - SKILL_HEALTH_COST))
		
	
	set_task(BANSHEE_SKILDURATION, "fw_DisableSkill", id + TASK_DISABLE_SKILL)
	Draw_BarTime(id, floatround(BANSHEE_SKILDURATION))
	fm_set_rendering(id, kRenderFxGlowShell, 200, 0, 0, kRenderNormal, 16)
	
	if (task_exists(id + TASK_RELEASE_BAT))
		remove_task(id + TASK_RELEASE_BAT)
		
	set_task(RELEASE_BAT_WAIT, "fw_ReleaseBat", id + TASK_RELEASE_BAT)
	fSkillTime[id] = get_gametime()
	
	pev(id, pev_maxspeed, fStoreSpeed[id])
	
	set_pev(id, pev_maxspeed, 0.000000001)
	engfunc(EngFunc_SetClientMaxspeed, id, 0.000000001)
	
	//set_pev(id, pev_velocity, {0.0, 0.0, 0.0})
	SendWeaponAnim(id, 2)
	
	ClearPlayerBit(b_SetSequence, id)
	iInSkill[id] = 1
	set_pdata_float(iEnt, 48, BANSHEE_SKILDURATION, 4)
	set_pdata_float(id, 83, BANSHEE_SKILDURATION, 4)
	DisableWeapon(id)
	emit_sound(id, CHAN_VOICE, LAUGH_VOICE, 1.0, ATTN_NORM, 0, PITCH_NORM)
	return 
}

public fw_ReleaseBat(TASKID)
{
	new id = TASKID - TASK_RELEASE_BAT
	
	new iEnt = create_entity("info_target")
	
	if(!pev_valid(iEnt)) 
		return
		
	new Float:vecAngle[3],Float:vecOrigin[3],Float:vecVelocity[3],Float:vecForward[3]
	fm_get_user_startpos(id,5.0,2.0,-1.0,vecOrigin)
	pev(id,pev_angles,vecAngle)
	
	engfunc(EngFunc_MakeVectors,vecAngle)
	global_get(glb_v_forward,vecForward)

	//xs_vec_mul_scalar(vecForward,banchee_skull_bat_speed,vecVelocity)
	velocity_by_aim(id, BAT_SPEED,vecVelocity)
	
	//Entity Statue
	set_pev(iEnt, pev_origin,vecOrigin)
	set_pev(iEnt, pev_angles,vecAngle)
	set_pev(iEnt, pev_classname, BAT_CLASS)
	set_pev(iEnt, pev_movetype,MOVETYPE_FLY)
	set_pev(iEnt, pev_solid,SOLID_BBOX)
	engfunc(EngFunc_SetSize, iEnt , {-20.0,-15.0,-8.0},{20.0,15.0,8.0})

	engfunc(EngFunc_SetModel, iEnt, BAT_MODEL)
	set_pev(iEnt, pev_modelindex, iBatModelIndex)
	
	set_pev(iEnt,pev_animtime, get_gametime())
	
	set_pev(iEnt, pev_framerate,1.0) 
	set_pev(iEnt, pev_owner,id)
	set_pev(iEnt, pev_velocity,vecVelocity)
	set_pev(iEnt, pev_nextthink, get_gametime() + BAT_LIFE)
	set_pev(iEnt, pev_enemy, -1)
	
	set_task(0.1, "fw_BatSearchEnermy", iEnt + TASK_BAT_SEARCH_ENERMY, _, _, "b")
	ClearPlayerBit(b_SetSequence, id)
	iInSkill[id] = 2
	iBatEnt[id] = iEnt
	
}

public fw_BatSearchEnermy(TASKID)
{
	new iEnt = TASKID - TASK_BAT_SEARCH_ENERMY
	
	if (!iEnt || !pev_valid(iEnt))
	{
		remove_task(TASKID)
		return
	}
	
	new iEnemy = pev(iEnt, pev_enemy)
	new id = pev(iEnt, pev_owner)
	
	if (!id)
	{
		engfunc(EngFunc_RemoveEntity, iEnt)
		remove_task(TASKID)
	
		return
	}
		
	if (!IsValidPlayer(iEnemy))
	{
		new iTarget = NpcFindClosestEnemy(iEnt)
		
		if (!IsValidPlayer(iTarget))
			return
			
		set_pev(iEnt, pev_enemy, iTarget)
		
		new Float:fOrigin[3]
		pev(iTarget, pev_origin, fOrigin)
		
		NpcMove(iEnt, fOrigin, BAT_SPEED)
	}
	
	if (!is_user_alive(iEnemy) || get_user_team(iEnemy) == get_user_team(id))
	{
		set_pev(iEnt, pev_enemy, -1)
		return
	}
}

public fw_DisableSkill(TASKID)
{
	new id = TASKID - TASK_DISABLE_SKILL
	Draw_BarTime(id, 0)
	fm_set_rendering(id, kRenderFxNone, 0, 0, 0, kRenderNormal, 0)
	
	if (pev_valid(iBatEnt[id]))
		call_think(iBatEnt[id])
		
	set_pev(id, pev_maxspeed, fStoreSpeed[id])
	iInSkill[id] = 0
	EnableWeapon(id)
	
}

public fw_SpawnPost(id)
{
	new TASKID = id + TASK_OUT_OF_CONFUSION
	if (task_exists(TASKID))
		remove_task(TASKID)
		
	TASKID = id + TASK_DISABLE_SKILL
	if (task_exists(TASKID))
		remove_task(TASKID)
		
	TASKID = id + TASK_RELEASE_BAT
	if (task_exists(TASKID))
		remove_task(TASKID)
	
	ClearPlayerBit(b_IsBeingConfused, id)
	iInSkill[id] = 0
	iTouchedEnt[id] = 0
	
	if (iBatEnt[id])
	{
		if (pev_valid(iBatEnt[id]))
			call_think(iBatEnt[id])
		iBatEnt[id] = 0
	}
}

public fw_KilledPost(iVictim, iKiller)
{
	new TASKID = iVictim + TASK_OUT_OF_CONFUSION
	if (task_exists(TASKID))
		remove_task(TASKID)
		
	TASKID = iVictim + TASK_DISABLE_SKILL
	if (task_exists(TASKID))
		remove_task(TASKID)
		
	TASKID = iVictim + TASK_RELEASE_BAT
	
	if (task_exists(TASKID))
		remove_task(TASKID)
		
	set_pev(iVictim, pev_effects, pev(iVictim, pev_effects) &~ EF_BRIGHTFIELD)
	ClearPlayerBit(b_IsBeingConfused, iVictim)
	iInSkill[iVictim] = 0
	iTouchedEnt[iVictim] = 0
	if (iBatEnt[iVictim])
	{
		if (pev_valid(iBatEnt[iVictim]))
			call_think(iBatEnt[iVictim])
		iBatEnt[iVictim] = 0
	}
	//if (g4u_get_user_zombie(iVictim) && g4u_get_zombie_class(iVictim) == iClass)
	//	fm_set_rendering(iVictim, kRenderFxNone, 0, 0, 0, kRenderNormal, 0)
}

public client_disconnect(id)
{
	
	
	if (iTouchedEnt[id] && pev_valid(iTouchedEnt[id]))
	{
		call_think(iTouchedEnt[id])
		return
	}
	
	if (iBatEnt[id] && pev_valid(iBatEnt[id]))
	{
		call_think(iBatEnt[id])
		return
	}
}

public g4u_user_become_zombie_post(id)
{
	if (iTouchedEnt[id] && pev_valid(iTouchedEnt[id]))
	{
		call_think(iTouchedEnt[id])
		iTouchedEnt[id] = 0
	}
	
	if (g4u_get_zombie_class(id) != iClass)
		return
		
	fm_give_item(id, "weapon_hegrenade")
	engclient_cmd(id, "weapon_hegrenade")
	
	if (iTouchedEnt[id] && pev_valid(iTouchedEnt[id]))
	{
		call_think(iTouchedEnt[id])
		iTouchedEnt[id] = 0
	}
		
}

public zm3_zombie_touch_weapon(id, iEnt)
{
	if (g4u_get_zombie_class(id) != iClass)
		return PLUGIN_CONTINUE
	
	new iWeaponId = get_pdata_int(iEnt, 43, 4)
	if (iWeaponId != CSW_HEGRENADE)
		return PLUGIN_CONTINUE
		
	return PLUGIN_HANDLED
}

public zm3_zombie_strip_weapon(id, weaponid)
{
	if (g4u_get_zombie_class(id) != iClass)
		return PLUGIN_CONTINUE
		
	if (weaponid != CSW_HEGRENADE)
		return PLUGIN_CONTINUE
		
	return PLUGIN_HANDLED
}

public fw_checkweapon(id)
{
	new iWeaponId = read_data(2)
	
	if (!IsValidPlayer(id))
		return
		
	if (!g4u_get_user_zombie(id))
		return
		
	if (g4u_get_zombie_class(id) != iClass)
		return
		
	if (iWeaponId == CSW_HEGRENADE)
	{
		set_pev(id, pev_weaponmodel2, P_GRENADE_MODEL)
		set_pev(id, pev_viewmodel2, V_GRENADE_MODEL)
	}
	else if (iWeaponId == CSW_KNIFE)
		set_pev(id, pev_weaponmodel2, "")
		
}

public fw_SetModelPost(iEnt, model[])
{
	if (!iEnt)
		return 
		
	if (!equal(model[7], "w_hegrenade", 11))
		return
		
	new id = pev(iEnt, pev_owner)
	
	if (!g4u_get_user_zombie(id))
		return 
	
	if (g4u_get_zombie_class(id) != iClass)
		return
			
	new ClassName[32]
	pev(iEnt, pev_classname, ClassName, 31)
	
	if (!equal(ClassName, "grenade"))
		return

	engfunc(EngFunc_SetModel, iEnt, W_GRENADE_MODEL)
	set_pev(iEnt, pev_classname, "WitchGrenade")
	set_pev(iEnt, pev_nextthink, get_gametime() + 1.5)
	set_pev(iEnt, pev_dmgtime, get_gametime() + 10000000.0)
}

public fw_BatTouched(iEnt, iToucher)
{
	if (!iEnt)
		return
		
	if (!iToucher || !IsValidPlayer(iToucher) || !pev_valid(iToucher)) // NOT A PLAYER
	{
		fw_BatThink(iEnt)
		return
	}
	
	new iOwner = pev(iEnt, pev_owner)
	
	if (!iOwner || !IsValidPlayer(iOwner))
	{
		call_think(iEnt)
		return
	}
	
	new CsTeams:iToucherTeam = cs_get_user_team(iToucher)
	new CsTeams:iOwnerTeam = cs_get_user_team(iOwner)
	
	if (iToucherTeam == iOwnerTeam)
	{
		call_think(iEnt)
		return
	}
	
	if (!is_user_alive(iToucher))
		return
		
	if (!is_user_alive(iOwner))
	{
		call_think(iEnt)
		return
	}
	
	pev(iToucher, pev_maxspeed, fStoreSpeed[iToucher])
	
	set_pev(iEnt, pev_aiment, iToucher)
	set_pev(iEnt, pev_movetype, MOVETYPE_FOLLOW)
	set_pev(iEnt, pev_enemy, iToucher)
	set_pev(iEnt, pev_sequence, 1)
	iTouchedEnt[iToucher] = iEnt
}

public fw_WitchGrenadeThink(iEnt)
{
	if (!iEnt)
		return
		
	if (!pev_valid(iEnt))
		return
		
	new iPlayers[32], iNumber
	new Float:fEntOrigin[3]
	
	pev(iEnt, pev_origin, fEntOrigin)
	
	get_players(iPlayers, iNumber, "ae", "CT") // Get all alive humans
	new iCount = 0
	for (new i = 0; i < iNumber; i++)
	{
		new id = iPlayers[i]
		
		new Float:fOrigin[3]
		pev(id, pev_origin, fOrigin)
		
		new Float:fDistance = vector_distance(fEntOrigin, fOrigin)
		
		if (fDistance > GRENADE_MAX_RANGE)
			continue
			
		if (task_exists(id + TASK_OUT_OF_CONFUSION))
			remove_task(id + TASK_OUT_OF_CONFUSION)
			
		set_task(CONFUSED_TIME, "fw_OutOfConfusion", id + TASK_OUT_OF_CONFUSION)
		SetPlayerBit(b_IsBeingConfused, id)
		iCount++
		if (is_user_bot(id))
			continue
			
		message_begin(MSG_ONE_UNRELIABLE, g_msgScreenFade, _, id)
		write_short(UNIT_SECOND*1) // duration
		write_short(UNIT_SECOND*0) // hold time
		write_short(FFADE_IN) // fade type
		write_byte(250) // r
		write_byte(0) // g
		write_byte(0) // b
		write_byte (255) // alpha
		message_end()
		
	}
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, fEntOrigin, 0)
	write_byte(TE_PARTICLEBURST) // TE id
	engfunc(EngFunc_WriteCoord, fEntOrigin[0]) // x
	engfunc(EngFunc_WriteCoord, fEntOrigin[1]) // y
	engfunc(EngFunc_WriteCoord, fEntOrigin[2]) // z
	write_short(floatround(GRENADE_MAX_RANGE)) // radius
	write_byte(70) // color
	write_byte(3) // duration (will be randomized a bit)
	message_end()
		
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, fEntOrigin, 0)
	write_byte(TE_DLIGHT) // TE id
	engfunc(EngFunc_WriteCoord, fEntOrigin[0]) // x
	engfunc(EngFunc_WriteCoord, fEntOrigin[1]) // y
	engfunc(EngFunc_WriteCoord, fEntOrigin[2]) // z
	write_byte(20) // radius
	write_byte(0) // r
	write_byte(255) // g
	write_byte(0) // b
	write_byte(2) // life
	write_byte(0) // decay rate
	message_end()
	
	// Smallest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, fEntOrigin, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, fEntOrigin[0]) // x
	engfunc(EngFunc_WriteCoord, fEntOrigin[1]) // y
	engfunc(EngFunc_WriteCoord, fEntOrigin[2]) // z
	engfunc(EngFunc_WriteCoord, fEntOrigin[0]) // x axis
	engfunc(EngFunc_WriteCoord, fEntOrigin[1]) // y axis
	engfunc(EngFunc_WriteCoord, fEntOrigin[2] + (GRENADE_MAX_RANGE / 2)) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(255) // red
	write_byte(0) // green
	write_byte(0) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	// Medium ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, fEntOrigin, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, fEntOrigin[0]) // x
	engfunc(EngFunc_WriteCoord, fEntOrigin[1]) // y
	engfunc(EngFunc_WriteCoord, fEntOrigin[2]) // z
	engfunc(EngFunc_WriteCoord, fEntOrigin[0]) // x axis
	engfunc(EngFunc_WriteCoord, fEntOrigin[1]) // y axis
	engfunc(EngFunc_WriteCoord, fEntOrigin[2]+ (GRENADE_MAX_RANGE / 1.5)) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(255) // green
	write_byte(0) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	// Largest ring
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, fEntOrigin, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, fEntOrigin[0]) // x
	engfunc(EngFunc_WriteCoord, fEntOrigin[1]) // y
	engfunc(EngFunc_WriteCoord, fEntOrigin[2]) // z
	engfunc(EngFunc_WriteCoord, fEntOrigin[0]) // x axis
	engfunc(EngFunc_WriteCoord, fEntOrigin[1]) // y axis
	engfunc(EngFunc_WriteCoord, fEntOrigin[2]+ GRENADE_MAX_RANGE) // z axis
	write_short(g_exploSpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(4) // life
	write_byte(60) // width
	write_byte(0) // noise
	write_byte(0) // red
	write_byte(0) // green
	write_byte(255) // blue
	write_byte(200) // brightness
	write_byte(0) // speed
	message_end()
	
	emit_sound(iEnt, CHAN_AUTO, GRENADE_EXPLODE_SOUND, 1.0, ATTN_NORM, 0, PITCH_HIGH)
	
	
	remove_entity(iEnt)
	return
}

public fw_BatThink(iEnt)
{
	if (!iEnt)
		return
		
	if (!pev_valid(iEnt))
		return
		
	remove_task(iEnt + TASK_BAT_SEARCH_ENERMY)
	
	new id = pev(iEnt, pev_owner)
	
	new iOrigin[3], Float:fOrigin[3]
	pev(iEnt, pev_origin, fOrigin)
	FVecIVec(fOrigin, iOrigin)
	
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY); 
	write_byte(TE_EXPLOSION); // TE_EXPLOSION
	write_coord(iOrigin[0]); // origin x
	write_coord(iOrigin[1]); // origin y
	write_coord(iOrigin[2]); // origin z
	write_short(iBatSpriteIndex); // sprites
	write_byte(40); // scale in 0.1's
	write_byte(30); // framerate
	write_byte(0); // flags 
	message_end(); // message end
	
	new iEnemy = pev(iEnt, pev_enemy)
	
	iBatEnt[iEnemy] = -1
	
	engfunc(EngFunc_RemoveEntity, iEnt)
	
	if (is_user_alive(id) && g4u_get_user_zombie(id) && g4u_get_zombie_class(id) == iClass)
	{
		set_pev(id, pev_maxspeed, fStoreSpeed[id])
		
		SendWeaponAnim(id, 0)
		EnableWeapon(id)
		
		new iWpnEnt = find_ent_by_owner(-1, "weapon_knife", id)
		
		if (!iWpnEnt)
			return
			
		
		set_pdata_float(iWpnEnt, 48, 0.15, 4)
		set_pdata_float(id, 83, 0.15, 4)
		Draw_BarTime(id, 0)
	}
	
}

public fw_OutOfConfusion(TASKID)
{
	new id = TASKID - TASK_OUT_OF_CONFUSION;
	
	ClearPlayerBit(b_IsBeingConfused, id)
}

public fw_AddToFullPackPost(es_handled, ient, ent, host, hostflags, player, pSet)
{
	if (CheckPlayerBit(b_IsBeingConfused, host))
	{	
		if (!is_user_alive(host))
			return FMRES_IGNORED
			
		if (is_user_bot(host))
			return FMRES_IGNORED
			
		if (!ent)
			return FMRES_IGNORED
			
		if (!(1 <= ent <= iMaxPlayers))
			return FMRES_IGNORED
			
		if (!is_user_connected(ent))
			return FMRES_IGNORED
		
		set_es(es_handled, ES_Effects, get_es(es_handled, ES_Effects) | EF_NODRAW)
		return FMRES_IGNORED
	}
	if (g4u_get_user_zombie(ent) && g4u_get_zombie_class(ent) == iClass) // Player is Banshee
	{
		if (iInSkill[ent] == 1)
		{
			if (!CheckPlayerBit(b_SetSequence, ent))
			{
				set_es(es_handled, ES_Sequence, ANIM_START_SKILL)
				set_es(es_handled, ES_GaitSequence, ANIM_START_SKILL)
				SetPlayerBit(b_SetSequence, ent)
				return FMRES_IGNORED
			}
			
		}
		else if (iInSkill[ent] == 2)
		{
			set_es(es_handled, ES_Sequence, ANIM_HOLD_SKILL)
			set_es(es_handled, ES_GaitSequence, ANIM_HOLD_SKILL)
			
			return FMRES_IGNORED
			
			
		}
	}
	return FMRES_IGNORED
}
		
		
	

public fw_PlayerPostThink(id)
{
	if (!is_user_alive(id))
		return
		
	if (iTouchedEnt[id] && pev_valid(iTouchedEnt[id]))
	{
		new iOwner = pev(iTouchedEnt[id], pev_owner)
		
		new Float:fOwnerOrigin[3]
		pev(iOwner, pev_origin, fOwnerOrigin)
		
		new Float:fAimVec[3]
		aim_at_origin(id, fOwnerOrigin,fAimVec)
		
		engfunc(EngFunc_MakeVectors, fAimVec)
		
		global_get(glb_v_forward, fAimVec)
		fAimVec[0] *= BAT_CATCH_HUMAN_SPEED
		fAimVec[1] *= BAT_CATCH_HUMAN_SPEED
		fAimVec[2] =0.0
		set_pev(id,pev_velocity, fAimVec)
		
		new Float:fOrigin[3]
		pev(id, pev_origin, fOrigin)
		
		if (get_distance_f(fOrigin, fOwnerOrigin) <= 50.0)
		{
			fw_BatThink(iTouchedEnt[id])
			return
		}
			
		
		new iSequence  = pev(iTouchedEnt[id], pev_sequence)
		
		if (iSequence != 1)
			set_pev(iTouchedEnt[id], pev_sequence, 1)
			
		pev(iTouchedEnt[id], pev_gaitsequence)
		
		if (iSequence != 1)
			set_pev(iTouchedEnt[id], pev_gaitsequence, 1)
			
		if (g4u_get_user_zombie(id))
			call_think(iTouchedEnt[id])
	}
	
	
	
	new iFlag = pev(id, pev_flags)
	
	new iDucking = iFlag & (FL_DUCKING)
	if (iDucking)
	{
		if (iBatEnt[id] && pev_valid(iBatEnt[id]))
		{
			call_think(iBatEnt[id])
			return
		}
	}
	
	new iOnGround = ((iFlag & (FL_ONGROUND)) || (iFlag & (FL_ONTRAIN)))
	
	if (!iOnGround)
	{
		if (iBatEnt[id] && pev_valid(iBatEnt[id]))
		{
			call_think(iBatEnt[id])
			return
		}
	}
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
	
stock IsValidPlayer(id)
{
	if (!(1<= id <= iMaxPlayers))
		return 0
	
	if (!is_user_connected(id))
		return 0
		
	return 1
}

stock fm_set_rendering(index, fx=kRenderFxNone, r=255, g=255, b=255, render=kRenderNormal, amount=16)
{
	set_pev(index, pev_renderfx, fx)
	new Float:RenderColor[3]
	RenderColor[0] = float(r)
	RenderColor[1] = float(g)
	RenderColor[2] = float(b)
	set_pev(index, pev_rendercolor, RenderColor)
	set_pev(index, pev_rendermode, render)
	set_pev(index, pev_renderamt, float(amount))

	return 1
}

stock fm_get_user_startpos(id,Float:forw,Float:right,Float:up,Float:vStart[])
{
	new Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3]
	
	pev(id, pev_origin, vOrigin)
	pev(id, pev_v_angle, vAngle)
	
	engfunc(EngFunc_MakeVectors, vAngle)
	
	global_get(glb_v_forward, vForward)
	global_get(glb_v_right, vRight)
	global_get(glb_v_up, vUp)
	
	vStart[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up
	vStart[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up
	vStart[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up
}

stock aim_at_origin(id, Float:target[3], Float:angles[3])
{
	static Float:vec[3]
	pev(id,pev_origin,vec)
	vec[0] = target[0] - vec[0]
	vec[1] = target[1] - vec[1]
	vec[2] = target[2] - vec[2]
	engfunc(EngFunc_VecToAngles,vec,angles)
	angles[0] *= -1.0
	angles[2] = 0.0
}

stock SendWeaponAnim(player, anim)
{
	set_pev(player, pev_weaponanim, anim)
	message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, {0, 0, 0}, player)
	write_byte(anim)
	write_byte(pev(player, pev_body))
	message_end()
}

stock DisableWeapon(id)
{
	for (new i = 0; i < sizeof WeaponClass; i++)
	{
		new iEnt = find_ent_by_owner(-1, WeaponClass[i], id)
		
		if (iEnt)
		{
			new szNewClassName[32]
			formatex(szNewClassName, 31, "%s_disabled", WeaponClass[i])
			set_pev(iEnt, pev_classname, szNewClassName)
		}
	}
}

stock EnableWeapon(id)
{
	for (new i = 0; i < sizeof WeaponClass; i++)
	{
		new szNewClassName[32]
		formatex(szNewClassName, 31, "%s_disabled", WeaponClass[i])
			
		new iEnt = find_ent_by_owner(-1, szNewClassName, id)
		
		if (iEnt)
		{
			formatex(szNewClassName, 31, "%s", WeaponClass[i])
			set_pev(iEnt, pev_classname, szNewClassName)
		}
	}
}

stock NPC_TurnToTarget(iEnt, iTarget)
{
	
	new Float:fFixedOrigin[3], Float:fOrigin[3], Float:TargetOrigin[3], Float:fAngles[3]
	
	pev(iEnt, pev_origin, fOrigin)
	pev(iTarget, pev_origin, TargetOrigin)
	
	DirectedVec(TargetOrigin,fOrigin,fFixedOrigin)
	
	fFixedOrigin[2]=0.0
	
	vector_to_angle(fFixedOrigin,fAngles)
	
	entity_set_aim(iEnt, TargetOrigin, 0)
	set_pev(iEnt, pev_angles, fAngles)
	set_pev(iEnt, pev_v_angle, fAngles)
	
}

stock DirectedVec(Float:start[3],Float:end[3],Float:reOri[3])
{
//-------code from Hydralisk's 'Admin Advantage'-------//	
	new Float:v3[3]
	v3[0]=start[0]-end[0]
	v3[1]=start[1]-end[1]
	v3[2]=start[2]-end[2]
	new Float:vl = vector_length(v3)
	reOri[0] = v3[0] / vl
	reOri[1] = v3[1] / vl
	reOri[2] = v3[2] / vl
}

stock NpcMove(iEnt, Float:fDestination[3], iSpeed)
{
	if (!is_valid_ent(iEnt))
		return
		
	new Float:fOrigin[3]
	pev(iEnt, pev_origin, fOrigin)
	
	
	new Float:fFixOrigin[3], Float:fAngles[3]
	DirectedVec(fDestination, fOrigin, fFixOrigin)
	fFixOrigin[2] = 0.0
	vector_to_angle(fFixOrigin, fAngles)
	set_pev(iEnt, pev_angles, fAngles)
	set_pev(iEnt, pev_v_angle, fAngles)
	
	VelocityByAim(iEnt, iSpeed, fFixOrigin)
	//fFixOrigin[2] = 0.0
	
	

	
	set_pev(iEnt, pev_velocity, fFixOrigin)
}

stock NpcFindClosestEnemy(iEnt)
{
	new Float:Dist
	new Float:maxdistance = 700.0
	new indexid = 0	
	//new Float:fEntOrigin[3]
	//pev(entid, pev_origin, fEntOrigin)
	
	new iOwner = pev(iEnt, pev_owner)
	
	if (!IsValidPlayer(iOwner))
		return -1
		
	new iPlayers[32], iNumber
	get_players(iPlayers, iNumber, "a")
	
	for(new i = 0;i < iNumber;i++)
	{
		new id = iPlayers[i]
		
		if (id == iOwner)
			continue
		
		new CsTeams:iOwnerTeam = cs_get_user_team(iOwner)
		new CsTeams:iIdTeam = cs_get_user_team(id)
		
		if (iOwnerTeam == iIdTeam)
			continue
		
		new Float:fOrigin[3]
		pev(id, pev_origin, fOrigin)
		
		if (!in_front(iOwner, fOrigin))
			continue
	
		if (!can_see_fm(iOwner, id) && !can_see_fm(iEnt, id))
			continue
				
		Dist = entity_range(iEnt ,id)
		
		if(Dist <= maxdistance)
		{
			maxdistance=Dist
			indexid = id
			
		}	
	}	
	return indexid
}

stock bool:can_see_fm(entindex1, entindex2)
{
	if (!entindex1 || !entindex2)
		return false

		
	if (pev_valid(entindex1) && pev_valid(entindex1))
	{
		new flags = pev(entindex1, pev_flags)
		if (flags & EF_NODRAW || flags & FL_NOTARGET)
		{
			return false
		}

		new Float:lookerOrig[3]
		new Float:targetBaseOrig[3]
		new Float:targetOrig[3]
		new Float:temp[3]

		pev(entindex1, pev_origin, lookerOrig)
		pev(entindex1, pev_view_ofs, temp)
		lookerOrig[0] += temp[0]
		lookerOrig[1] += temp[1]
		//if (IsEntNPC(entindex1))
			//lookerOrig[2] += temp[2] + NPC_EYE
		lookerOrig[2] += temp[2]
		pev(entindex2, pev_origin, targetBaseOrig)
		pev(entindex2, pev_view_ofs, temp)
		targetOrig[0] = targetBaseOrig [0] + temp[0]
		targetOrig[1] = targetBaseOrig [1] + temp[1]
		targetOrig[2] = targetBaseOrig [2] + temp[2]

		engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0) //  checks the had of seen player
		if (get_tr2(0, TraceResult:TR_InOpen) && get_tr2(0, TraceResult:TR_InWater))
		{
			return false
		} 
		else 
		{
			new Float:flFraction
			get_tr2(0, TraceResult:TR_flFraction, flFraction)
			if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
			{
				return true
			}
			else
			{
				targetOrig[0] = targetBaseOrig [0]
				targetOrig[1] = targetBaseOrig [1]
				targetOrig[2] = targetBaseOrig [2]
				engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0) //  checks the body of seen player
				get_tr2(0, TraceResult:TR_flFraction, flFraction)
				if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
				{
					return true
				}
				else
				{
					targetOrig[0] = targetBaseOrig [0]
					targetOrig[1] = targetBaseOrig [1]
					targetOrig[2] = targetBaseOrig [2] - 17.0
					engfunc(EngFunc_TraceLine, lookerOrig, targetOrig, 0, entindex1, 0) //  checks the legs of seen player
					get_tr2(0, TraceResult:TR_flFraction, flFraction)
					if (flFraction == 1.0 || (get_tr2(0, TraceResult:TR_pHit) == entindex2))
					{
						return true
					}
				}
			}
		}
	}
	return false
}
