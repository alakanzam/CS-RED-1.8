/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <GamePlay_Included/GamePlay_ZM.inc>
#include <fakemeta_util>
#include <hamsandwich>
#include <csred_MsgTool>
#include <metahook>
#include <mmcl>

#define PLUGIN "NURSE Zombie"
#define VERSION "1.0"
#define AUTHOR "Nguyen Duy Linh"

#define CLASS_NAME "NURSE Zombie"


#define FIRST_MODEL "NurseZombie_2"
#define SECOND_MODEL "NurseZombie_2"
#define THIRD_MODEL "NurseZombie_3"

#define NURSE_FIRST_CLAW_MODEL "NURSE_HAND"
#define NURSE_SECOND_CLAW_MODEL "NURSE_HAND"
#define NURSE_THIRD_CLAW_MODEL "NURSE_HAND"

#define NURSE_WEAPON_HUD "NURSE-HAND"

new const Float:NURSE_HEALTH[3] = {3000.0, 4000.0, 6200.0}
new const Float:NURSE_GRAVITY[3] = {0.85, 0.83, 0.79}
new const Float:NURSE_KNOCKBACK[3] = {3.25, 3.15, 2.77}
new const Float:NURSE_SPEED[3] = {267.0, 270.0, 273.0}

new const Float:NURSE_DEFENSIVE[3] = {0.0, 0.0, 7.0}
new const Float:NURSE_DMG_ARMOR[3] = {60.0, 62.5, 63.0}

#define NURSE_HEALTH_SKILL 500

new NURSE_NVG_COLOR[3] = {17, 124, 239}
#define NURSE_NVG_ALPHA  50
#define NURSE_NVG_RADIUS 40

#define NURSE_GENDER ZB_GENDER_FEMALE

#define NURSE_COST_TYPE 2
#define NURSE_COST 120

#define NURSE_SOUND_DIRECTORY "default_zombie"
#define NURSE_HUD_CHAR "ZOMBIE_Y_TA"



#define TASK_DISABLE_SKILL 2000
#define SKILL_TIME 12

#define TASK_CZ_FUNCTION 3000


#define START_INVIS_SOUND "zombiemod/StartInvisible.wav"
#define START_VIS_SOUND "zombiemod/StartVisible.wav"

new iNurseClass

new iHamCz = 0


//	BIT TOOLS

#define SetPlayerBit(%1,%2)      (%1 |= (1<<(%2&31)))
#define ClearPlayerBit(%1,%2)    (%1 &= ~(1 <<(%2&31)))
#define CheckPlayerBit(%1,%2)    (%1 & (1<<(%2&31)))

new bHandInvis
new bUseSkill

public ZmMain_StartRegisterClass()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	iNurseClass = g4u_create_zombie_class(CLASS_NAME)
	if (iNurseClass < 0)
		return
		
	g4u_set_class_model(iNurseClass, FIRST_MODEL, SECOND_MODEL, THIRD_MODEL)
	g4u_set_zombie_hand(iNurseClass, NURSE_FIRST_CLAW_MODEL, NURSE_SECOND_CLAW_MODEL, NURSE_THIRD_CLAW_MODEL)
	g4u_set_zombie_hud(iNurseClass, NURSE_WEAPON_HUD, NURSE_HUD_CHAR)
	g4u_set_zombie_health(iNurseClass, NURSE_HEALTH[0], NURSE_HEALTH[1], NURSE_HEALTH[2])
	g4u_set_zombie_gravity(iNurseClass, NURSE_GRAVITY[0], NURSE_GRAVITY[1], NURSE_GRAVITY[2])
	g4u_set_zombie_speed(iNurseClass, NURSE_SPEED[0], NURSE_SPEED[1], NURSE_SPEED[2])
	g4u_set_zombie_damage(iNurseClass, NURSE_DEFENSIVE[0], NURSE_DEFENSIVE[1], NURSE_DEFENSIVE[2])
	g4u_set_zombie_sound(iNurseClass, NURSE_SOUND_DIRECTORY)
	g4u_set_zombie_price(iNurseClass, NURSE_COST_TYPE, NURSE_COST)
	g4u_set_zombie_knockback(iNurseClass, NURSE_KNOCKBACK[0], NURSE_KNOCKBACK[1], NURSE_KNOCKBACK[2])
	
	g4u_set_zombie_dmg_armor(iNurseClass, NURSE_DMG_ARMOR[0], NURSE_DMG_ARMOR[1], NURSE_DMG_ARMOR[2])
	g4u_set_zombie_NVG_Option(iNurseClass, NURSE_NVG_COLOR[0], NURSE_NVG_COLOR[1], NURSE_NVG_COLOR[2], NURSE_NVG_ALPHA, NURSE_NVG_RADIUS)
	g4u_set_zombie_gender(iNurseClass, NURSE_GENDER)
	
	register_forward(FM_CmdStart, "fw_CmdStart")
	
	RegisterHam(Ham_Spawn, "player", "fw_PlayerRespawn", 1)
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled", 1)
	
	
	
}

public plugin_cfg()
{
	if (!g4u_get_zombie_toggle())
	{
		set_fail_state("Can't create Zombie Class because Zombie Mod is OFF")
		return
	}
}

public fw_CmdStart(id, ucHandled, Seed)
{
	
	if (!is_user_connected(id))
		return
		
		
	if (!is_user_alive(id))
		return
		
	if (!g4u_get_user_zombie(id))
		return
		
	if (g4u_get_zombie_class(id) != iNurseClass)
		return
	
	if (!CheckPlayerBit(bUseSkill, id))
	{
		if (CheckPlayerBit(bHandInvis, id))
		{
			ClearPlayerBit(bHandInvis, id)
			if (MMCL_IsClientUsingMMCL(id))
				MMCL_SetViewEntityRenderMode(id, kRenderNormal, kRenderFxNone, 16, 0, 0, 0)
		}
		return
	}
	
	new iButton = get_uc(ucHandled, UC_Buttons)
	
	if (iButton & IN_MOVELEFT || iButton & IN_MOVERIGHT || iButton & IN_FORWARD || iButton & IN_BACK || iButton & IN_JUMP)
	{
		fm_set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 16)
		
		set_pev(id, pev_effects, pev(id, pev_effects) &~ EF_NODRAW)
			
	}
	else	
	{
		fm_set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0)
		
		set_pev(id, pev_effects, pev(id, pev_effects) | EF_NODRAW)
		
		if (is_using_metahook(id) && !is_user_bot(id) && !CheckPlayerBit(bHandInvis, id))
		{
			MMCL_SetViewEntityRenderMode(id,  kRenderTransAdd, kRenderFxSolidSlow, 16, 255, 255, 255)
			SetPlayerBit(bHandInvis, id)
		}
			
	}
}

public fw_PlayerRespawn(id)
{
	if (!is_user_connected(id))
		return
		
	ClearPlayerBit(bUseSkill, id)
	remove_task(id + TASK_DISABLE_SKILL)
	
	if (CheckPlayerBit(bHandInvis, id))
	{
		if (MMCL_IsClientUsingMMCL(id))
		{
			ClearPlayerBit(bHandInvis, id) 
			MMCL_SetViewEntityRenderMode(id, kRenderNormal, kRenderFxNone, 16, 0,0 ,0)
			
		}
	}
	
	if (g4u_get_zombie_toggle() && g4u_get_zombie_class(id) == iNurseClass)
		fm_set_rendering(id)
		
	csred_SetZombieSkillState(id, 0)
}
		
public fw_PlayerKilled(iVictim, iKiller){
	if (CheckPlayerBit(bUseSkill, iVictim))
	{
		Draw_BarTime(iVictim, 0)
		
	}
	ClearPlayerBit(bUseSkill, iVictim)
	remove_task(iVictim + TASK_DISABLE_SKILL)
	ClearPlayerBit(bHandInvis, iVictim)
	csred_SetZombieSkillState(iVictim, 0)
}

public client_putinserver(id)
{
	if (iHamCz)
		return
		
	if (!is_user_connected(id))
		return
		
	if (!is_user_bot(id))
		return
		
	if (!get_cvar_num("bot_quota"))
		return
		
	set_task(0.1, "RegisterCzFunction", id + TASK_CZ_FUNCTION)
}

public RegisterCzFunction(TASKID)
{
	
	new id = TASKID - TASK_CZ_FUNCTION
	
	if (iHamCz)
		return
		
	if (!is_user_connected(id))
		return
		
	if (!is_user_bot(id))
		return
		
	if (!get_cvar_num("bot_quota"))
		return
		
	RegisterHamFromEntity(Ham_Spawn, id, "fw_PlayerRespawn", 1)
	RegisterHamFromEntity(Ham_Killed, id, "fw_PlayerKilled", 1)
	iHamCz = 1
}

	
public g4u_user_skill_post(id, iClass)
{
	if (!is_user_alive(id))
		return 
		
	if (!g4u_get_user_zombie(id))
		return
		
	if (iClass != iNurseClass)
		return
		
	new iLevel = g4u_get_zombie_level(id) 
	if (iLevel < 2)
		return
		
	if (CheckPlayerBit(bUseSkill, id))
		return
		
	new iHealth = get_user_health(id) 
	
	if (!is_user_bot(id))
		iHealth -= NURSE_HEALTH_SKILL
	
	if (!iHealth)
		return
		
	fm_set_user_health(id, iHealth)
	SetPlayerBit(bUseSkill, id)
	
	if (task_exists(id + TASK_DISABLE_SKILL))
		remove_task(id + TASK_DISABLE_SKILL)
		
	new Float:fTime = float(SKILL_TIME)
	
	set_task(fTime, "fw_DisableSkill", id + TASK_DISABLE_SKILL)
	
	client_cmd(id, "spk %s", START_INVIS_SOUND)
	
	Draw_BarTime(id, SKILL_TIME)
	csred_SetZombieSkillState(id, 1)
}

public fw_DisableSkill(TASKID)
{
	new id = TASKID - TASK_DISABLE_SKILL
	
	if (!is_user_alive(id))
		return 
		
	if (!g4u_get_user_zombie(id))
		return
		
	if (g4u_get_zombie_class(id)!= iNurseClass)
		return
		
	if (CheckPlayerBit(bUseSkill, id))
	{
		
		set_pev(id, pev_maxspeed, csred_get_zombie_speed(id))
		ClearPlayerBit(bUseSkill, id)
		Draw_BarTime(id, 0)
		client_cmd(id, "spk %s", START_VIS_SOUND)
		ClearPlayerBit(bUseSkill, id)
		fm_set_rendering(id)
	}
	csred_SetZombieSkillState(id, 0)
}


/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
