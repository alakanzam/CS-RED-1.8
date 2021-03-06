/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <cstrike>
#include <engine>
#include <cvar_util>
#include <infinitive_round>
#include <player_api>
#include <round_terminator>
#include <SDK_Hook>
#include <RespawnBar>
#include <fakemeta_util>

#include <GamePlay_Included/IntegerConstant.inc>
#include <GamePlay_Included/Manager.inc>


/*******************************************************************/

#define TASK_END_ROUND	5000
#define TASK_END_GAME	5000
#define TASK_RESPAWN	6000

/*******************************************************************/



/*******************************************************************/

#define ROUND_TIME 2.5 // Minutes
#define ROUND_FREEZE_TIME 0.0 // Seconds
#define ROUND_WEAPON_STAY_TIME	5.0 // Seconds
#define AS_RESPAWN_TIME	5.0

/*******************************************************************/


/*******************************************************************/

new iMaxRound 
new iTerroristScore, iCtScore

new iWeaponMode
new iValidMap

/*******************************************************************/

/*******************************************************************/

new ifw_RoundEnd
new ifw_RoundExit

new ifw_Result

/*******************************************************************/


/*******************************************************************/
	
enum
{
	CS_DM_FY = 1,
	CS_DM_DE,
	CS_DM_CS,
	CS_DM_NORMAL,
	CS_DM_AS,
	CS_DM_KA
}

/*******************************************************************/

new bool:bRoundEnd
new bool:bRoundBegin = false

public plugin_natives()
{
	register_native("DM_get_game_mode", "_get_game_mode", 1)
	register_native("DM_get_weapon_mode", "_get_game_type", 1)
	register_native("DM_get_CT_score", "_get_CT_score", 1)
	register_native("DM_get_T_score", "_get_T_score", 1)
	register_native("DM_get_max_round", "_get_max_round", 1)
	register_native("DM_get_round_time", "_get_round_time", 1)
}

/*********************************************************************/

public _get_game_mode()
	return iValidMap
	
public _get_game_type()
	return iWeaponMode

public _get_CT_score()
	return iCtScore
	
public _get_T_score()
	return iTerroristScore
	
public _get_max_round()
	return iMaxRound
	
public Float:_get_round_time()
	return ROUND_TIME

/*********************************************************************/
	
public GamePlay_Initilizing(iCurrentGamePlay)
{
	
	if (iCurrentGamePlay != GAMEMODE_BY_PREFIX)
		iValidMap = 0
	else	
	{
		iValidMap = is_valid_map()
		
		if (iValidMap)
			register_gameplay_id(GAMEMODE_DM)
	}
	
	
	new iCvarRoundLimit // Maximum Round Limitation
	new iCvarWeaponMode // Weapons can be used
	
	//			Convar Registration
	iCvarRoundLimit = register_cvar("DeathMatch/MaxRound", "9")
	iCvarWeaponMode = register_cvar("DeathMatch/WeaponMode", "1")
	
	if (!iValidMap)
		return
		
	

	new szCfgDir[128], szCfgFile[256]
	get_configsdir(szCfgDir, sizeof szCfgDir - 1)
		
	register_forward(FM_GetGameDescription, "fw_GetGameDescription")	
	formatex(szCfgFile, sizeof szCfgFile - 1, "%s/GamePlay_DeathMatch.cfg", szCfgDir)
		
	if (file_exists(szCfgFile))
	{
		server_cmd("exec %s", szCfgFile)
		server_exec()
			
		iWeaponMode = get_pcvar_num(iCvarWeaponMode)
		
		if (iWeaponMode < 1 || iWeaponMode > 4)
			iWeaponMode = 1
			
		if (iMaxRound < 0)
			iMaxRound = 9
			
	}
	new iCvarPointer
	
	iCvarPointer = get_cvar_pointer("mp_roundtime")
	CvarLockValue(iCvarPointer, "", ROUND_TIME)
	CvarEnableLock(iCvarPointer)
	
	iCvarPointer = get_cvar_pointer("mp_freezetime")
	CvarLockValue(iCvarPointer, "", ROUND_FREEZE_TIME)
	CvarEnableLock(iCvarPointer)
	
	
	iMaxRound = get_pcvar_num(iCvarRoundLimit)
}

public fw_GetGameDescription()
{
	
	new DM_DESCRIPTION[] =	"Death Match"
	forward_return(FMV_STRING, DM_DESCRIPTION)
	return FMRES_SUPERCEDE;
}

public plugin_init() 
{
	if (!iValidMap)
	{
		set_fail_state("[Game-Play] Death Match is OFF")
		return
	}
		
	new PLUGIN[] = "[GAME-PLAY] Death Match"
	new VERSION[] = "-No Info-"
	new AUTHOR[] ="Nguyen Duy Linh"
	
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	ifw_RoundEnd = CreateMultiForward("DM_RoundEnd", ET_IGNORE, FP_CELL, FP_CELL)
	ifw_RoundExit = CreateMultiForward("DM_RoundExit", ET_IGNORE, FP_CELL)
	
	
	//register_event("SendAudio", "RoundEvent_TerroristWin", "a", "2&%!MRAD_terwin")
	//register_event("SendAudio", "RoundEvent_CtWin", "a", "2&%!MRAD_ctwin")
	//register_event("TextMsg","RoundEvent_Restart","a","2=#Game_Commencing","2=#Game_will_restart_in")
	
	if (iValidMap == CS_DM_AS)
	{
		ir_block_round_end(FLAG_ALL)
		register_forward(FM_SetModel, "fw_SetModelPost", 1)
		register_message(get_user_msgid("ClCorpse"), "message_ClCorpse")
		
		register_touch("func_vip_safetyzone", "player", "fw_ReachVipZone") 
		//register_event("TextMsg", "Event_Vip_Escaped", "a", "2&#VIP_Escaped")
	}
}


/********************************************************************************************/

public RoundEvent_Begin()
{
	if (iValidMap != CS_DM_AS)
		return
		
	bRoundEnd = false
	bRoundBegin = true
	remove_task(TASK_END_ROUND)
	set_task(ROUND_TIME * 60.0, "EndRound_TASK", TASK_END_ROUND)
}

public EndRound_TASK()
{
	if (iValidMap != CS_DM_AS)
		return
		
	ir_block_round_end(FLAG_NONE)
	TerminateRound( RoundEndType_Objective, TeamWinning_Terrorist, MapType_AutoDetect)
	ir_block_round_end(FLAG_ALL)
}

public RoundEvent_TerWin()
{
	if (!iValidMap)
		return 0
		
	bRoundBegin = false
	iTerroristScore++
	ExecuteForward(ifw_RoundEnd, ifw_Result, TEAM_TERRORIST, iMaxRound)
	if (iTerroristScore >= iMaxRound)
	{
		ExecuteForward(ifw_RoundExit, ifw_Result, TEAM_TERRORIST)
		set_task(3.0, "EndGame_TASK", TASK_END_GAME)
		return 1
	}
	return 0
}
		
public RoundEvent_CtWin()
{
	if (!iValidMap)
		return 0
		
	bRoundBegin = false
	iCtScore++
	ExecuteForward(ifw_RoundEnd, ifw_Result, TEAM_CT, iMaxRound)
	if (iCtScore >= iMaxRound)
	{
		ExecuteForward(ifw_RoundExit, ifw_Result, TEAM_CT)
		set_task(3.0, "EndGame_TASK", TASK_END_GAME)
		return 1
	}
	return 0
}
		
public RoundEvent_Restart()
{
	if (!iValidMap)
		return
		
	bRoundEnd = true
	bRoundBegin = false
	iCtScore = 0
	iTerroristScore = 0
}

/********************************************************************************************/

public message_ClCorpse()
{
	if (iValidMap != CS_DM_AS)
		return PLUGIN_CONTINUE
		
	return PLUGIN_HANDLED
}

public Event_Vip_Escaped()
{
	if (iValidMap != CS_DM_AS)
		return
		
	ir_block_round_end(FLAG_NONE)
	TerminateRound( RoundEndType_Objective, TeamWinning_Ct, MapType_AutoDetect)
	ir_block_round_end(FLAG_ALL)
	
	bRoundEnd = true
}

public fw_ReachVipZone(iEnt, id)
{
	if (iValidMap != CS_DM_AS)
		return
		
	if (!pev_valid(iEnt))
		return
		
	if (!cs_get_user_vip(id))
		return
		
	if (bRoundEnd)
		return
		
	ir_block_round_end(FLAG_NONE)
	TerminateRound( RoundEndType_Objective, TeamWinning_Ct, MapType_AutoDetect)
	ir_block_round_end(FLAG_ALL)
	cs_set_user_vip(id, 0)
	UT_RespawnPlayer(id)
	bRoundEnd = true
	
}

public fw_SetModelPost(iEnt, szModel[])
{
	if (iValidMap != CS_DM_AS)
		return
		
	if (!pev_valid(iEnt))
		return
		
	new szClassName[32]
	pev(iEnt, pev_classname, szClassName, sizeof szClassName - 1)
	
	if (!equal(szClassName, "weaponbox"))
		return
	
	if (!bRoundBegin)
	{
		fm_remove_weaponbox(iEnt)
		return
	}
	
	set_pev(iEnt, pev_nextthink, get_gametime() + ROUND_WEAPON_STAY_TIME)
	
}


public csred_PlayerKilledPost(iVictim, iKiller)
{
	if (iValidMap != CS_DM_AS)
		return
		
	if (cs_get_user_vip(iVictim))
	{
		ir_block_round_end(FLAG_NONE)
		TerminateRound( RoundEndType_Objective, TeamWinning_Terrorist, MapType_AutoDetect)
		ir_block_round_end(FLAG_ALL)
		return
	}
	
	remove_task(iVictim + TASK_RESPAWN)
	set_task(AS_RESPAWN_TIME, "RespawnPlayer_TASK", iVictim + TASK_RESPAWN)
	_DrawRespawnNumber(iVictim, 1, floatround(AS_RESPAWN_TIME))
}

public RespawnPlayer_TASK(TASKID)
{
	new id = TASKID - TASK_RESPAWN

	if (iValidMap != CS_DM_AS)
		return
		
	UT_RespawnPlayer(id)
}
/********************************************************************************************/

public EndGame_TASK()
{
	client_cmd(0, "quit")
	console_cmd(0, "quit")
}

/********************************************************************************************/


stock is_valid_map()
{
	new szMapName[32]
	get_mapname(szMapName, sizeof szMapName - 1)
	strtoupper(szMapName)
	
	if (equal(szMapName, "FY_", 3))
		return CS_DM_FY
	else if (equal(szMapName, "AIM_", 4))
		return CS_DM_FY
	else if (equal(szMapName, "DE_", 3))
		return CS_DM_DE
	else if (equal(szMapName, "CS_", 3))
		return CS_DM_CS
	else if (equal(szMapName, "DM_", 4))
		return CS_DM_NORMAL
	else if (equal(szMapName, "AS_", 3))
		return CS_DM_AS
		
	return 0
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
