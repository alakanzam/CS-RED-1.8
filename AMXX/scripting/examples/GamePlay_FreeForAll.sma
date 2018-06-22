/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fakemeta_util>

#include <cstrike>
#include <csred_Ace>
#include <RandomRespawn>
#include <RespawnBar>
#include <infinitive_round>
#include <cvar_util>


#include <GamePlay_Included/GlobalConstants.inc>
#include <GamePlay_Included/Manager.inc>

/**********************************************************************/


/**********************************************************************/

#define TASK_PROTECTION 11000

/**********************************************************************/

#define TASK_END_ROUND 7000
#define TASK_END_GAME 9000
#define TASK_CZ_FUNCTION 15000

/**********************************************************************/

#define DEFAULT_ROUND_TIME	15.0


/**********************************************************************/


new bit_InProtect

// Info
new iHighestFrags



new iWeaponMode
new iRoundScore


new bool:ham_cz 
// Forwards

new ifw_RoundEnd
new ifw_MissionEntitySpawn

new ifw_Result


 
new Float:fSecondRemains


new iCvar_RoundTime
new iCvar_WeaponMode
new iCvar_RoundScore




new iRealKill[33]


new iCheckMap

new iRoundEnd 

new iRadarMsgId 


new Float:fRoundMinute




#define SetPlayerBit(%1,%2)      (%1 |= (1<<(%2&31)))
#define ClearPlayerBit(%1,%2)    (%1 &= ~(1 <<(%2&31)))
#define CheckPlayerBit(%1,%2)    (%1 & (1<<(%2&31)))


enum
{
	FFA_MODE_NONE,
	FFA_MODE_NORMAL
}


public plugin_natives()
{
	register_native("FFA_get_game_state", "_get_game_state", 1)
	register_native("FFA_get_max_score", "_get_max_score", 1)
	register_native("FFA_get_highest_score", "_get_highest_score", 1)
	register_native("FFA_get_user_frag", "_get_user_frag", 1)
	register_native("FFA_get_round_time", "_get_round_time", 1)
	register_native("FFA_get_weapon_mode", "_get_weapon_mode", 1)
	
}

public _get_game_state()
	return iCheckMap
	

public _get_max_score()
	return iRoundScore
	
public _get_highest_score()
	return iHighestFrags
	
public _get_user_frag(id)
	return pev(id, pev_frags)
	
public Float:_get_round_time()
	return fRoundMinute
	
public _get_weapon_mode()
	return iWeaponMode


public GamePlay_Initilizing(iRealGamePlay)
{
	if (iRealGamePlay == GAMEMODE_FFA)
		iCheckMap = 1
	else if (iRealGamePlay == GAMEMODE_BY_PREFIX)
	{
		iCheckMap = CheckMap()
		
		if (iCheckMap)
			register_gameplay_id(GAMEMODE_FFA)
	}
	
	if (!iCheckMap)
	{
		pause("a")
		return
	}
	new szCfgDir[128], szCfgFile[256]
	get_configsdir(szCfgDir, sizeof szCfgDir - 1)
	
	new CONFIGURATION_FILE[] = "GamePlay_FreeForAll.cfg"
	
	formatex(szCfgFile, sizeof szCfgFile - 1, "%s/%s", szCfgDir, CONFIGURATION_FILE)
	
	
	ham_cz = false
		
	if (iCheckMap)
	{
	
		if (iRealGamePlay != GAMEMODE_BY_PREFIX && iRealGamePlay != GAMEMODE_FFA)
		{
			iCheckMap = 0
			pause("a")
			return
		}
		
		register_forward(FM_GetGameDescription, "fw_GetGameDescription")
		ifw_MissionEntitySpawn = register_forward(FM_Spawn, "fw_MissionEntSpawn")
		
		cvar_register()
		
		server_exec()
		server_cmd("exec %s", szCfgFile)
		server_exec()
		
		iRoundScore = get_pcvar_num(iCvar_RoundScore)	
		iWeaponMode = get_pcvar_num(iCvar_WeaponMode)
		
	}
}

public plugin_init() 
{
	
	if (iCheckMap)
	{
		new PLUGIN[] = "[GAME PLAY] Free For All"
		new VERSION[] =  "- No Info -"
		new AUTHOR[] =  "Redplane"
		
		register_plugin(PLUGIN, VERSION, AUTHOR)
		
		fRoundMinute = get_pcvar_float(iCvar_RoundTime)
		
		if (fRoundMinute < 1.0)
			fRoundMinute = DEFAULT_ROUND_TIME
			
		fSecondRemains = fRoundMinute * 60.0
		
		register_message(get_user_msgid("SendAudio"), "message_sendaudio")
		register_message(get_user_msgid("TextMsg"), "message_textmsg")
		
		register_message(get_user_msgid("ClCorpse"), "message_body")
		
		iRadarMsgId = get_user_msgid("Radar")
		set_msg_block(iRadarMsgId, BLOCK_SET)
		register_message(iRadarMsgId, "message_UpdateRadar")
		
		ifw_RoundEnd = CreateMultiForward("FFA_game_over", ET_IGNORE, FP_CELL)
		
		register_logevent("round_begin" , 2 , "1=Round_Start")
		
		register_forward(FM_SetModel, "fw_SetModelPost", 1)
		
		RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawnPost", 1)
		RegisterHam(Ham_TakeDamage, "player", "fw_PlayerTakeDamage")
		RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack")
		RegisterHam(Ham_Killed, "player", "fw_PlayerKilled", 1)
		
		unregister_forward(FM_Spawn, ifw_MissionEntitySpawn)
		set_cvar_num("mp_freezetime", 0)
		
		new szCvarName[][] =
		{
			"pb_ffa",
			"mp_autokick",
			"mp_friendlyfire",
			"mp_fadetoblack",
			"mp_forcechasecam",
			"mp_chasecam",
			"mp_freezetime"
		}
		
		new szCvarValue[][] =
		{
			"1",
			"0",
			"1",
			"1",
			"2",
			"0",
			"0"
		}

		for (new iCvarId = 0; iCvarId < sizeof szCvarName; iCvarId++)
		{
			new iCvarPointer = get_cvar_pointer(szCvarName[iCvarId])
			
			if ( !iCvarPointer)
				continue
			CvarLockValue(iCvarPointer, szCvarValue[iCvarId])
			CvarEnableLock(iCvarPointer)
			
		}
		
		ir_block_round_end(FLAG_ALL)
	}
	
}

public fw_GetGameDescription()
{
	new FFA_DESCRIPTION[] =	"Free For All"
	forward_return(FMV_STRING, FFA_DESCRIPTION)
	return FMRES_SUPERCEDE;
}
public fw_MissionEntSpawn(entity)
{
	// Invalid entity
	if (!pev_valid(entity)) return FMRES_IGNORED;
	
	// Get classname
	new classname[32]
	pev(entity, pev_classname, classname, sizeof classname - 1)
	
	new MISSION_ENTITY[][] = {"func_bomb_target", "info_bomb_target", "info_vip_start", "func_vip_safetyzone", "func_escapezone", "hostage_entity",
		"monster_scientist", "func_hostage_rescue", "info_hostage_rescue"}
		
	// Check whether it needs to be removed
	for (new i = 0; i < sizeof MISSION_ENTITY; i++)
	{
		if (equal(classname, MISSION_ENTITY[i]))
		{
			engfunc(EngFunc_RemoveEntity, entity)
			return FMRES_SUPERCEDE;
		}
	}
	
	return FMRES_IGNORED;
}

public client_putinserver(id)
{
	
	if (!iCheckMap)
		return
		
	if (is_user_bot(id))
		set_task(0.1, "TASK_RegisterCzFunction", id + TASK_CZ_FUNCTION)
	
	iRealKill[id] = 0
}

public client_disconnect(id)
	iRealKill[id] = 0

public message_textmsg()
{
	static textmsg[22]
	get_msg_arg_string(2, textmsg, sizeof textmsg - 1);
	// Game restarting, reset scores and call round end to balance the teams
	// Block round end related messages
	if (iCheckMap)
	{
		if (equal(textmsg, "#Hostages_Not_Rescued") || equal(textmsg, "#Round_Draw") || equal(textmsg, "#Terrorists_Win") || equal(textmsg, "#CTs_Win") || equal(textmsg, "#Target_", 8))
			return PLUGIN_HANDLED
			
		if (equal(textmsg, "#Game_teammate_attack") || equal(textmsg, "#Game_teammate_kills") || equal(textmsg, "#Killed_Teammate"))
			return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public message_sendaudio()
{
	new audio[17]
	get_msg_arg_string(2, audio, sizeof audio - 1)
	if (!iCheckMap)
		return PLUGIN_CONTINUE
		
	if(equal(audio[7], "terwin") || equal(audio[7], "ctwin") || equal(audio[7], "rounddraw"))
		set_msg_arg_string(2, "")
		
	return PLUGIN_CONTINUE;
}

public message_body(msg_id, msg_dest, msg_ent)
{
	if (iCheckMap)
		return PLUGIN_HANDLED
	return PLUGIN_CONTINUE
}

public message_UpdateRadar()
{
	if (!iCheckMap)
		return PLUGIN_CONTINUE
	return PLUGIN_HANDLED
}

public fw_SetModelPost(iEnt, const szModel[])
{
	if (!iCheckMap)
		return 
		
	if (!pev_valid(iEnt))
		return
		
	new szClassName[32]
	pev(iEnt, pev_classname, szClassName, sizeof szClassName - 1)
	
	if (!equal(szClassName, "weaponbox"))
		return
		
	set_pev(iEnt, pev_nextthink, get_gametime() + WEAPON_STAY_TIME)
	
}

public round_begin()
{
	if (!iCheckMap)
		return
		
	if (task_exists(TASK_END_ROUND))
		remove_task(TASK_END_ROUND)
			
	set_task(fSecondRemains, "Func_EndRound", TASK_END_ROUND)
		
	iRoundEnd = 0
}

public TASK_EndGame(TASKID)
{
	new id = TASKID - TASK_END_GAME
	console_cmd(id, "quit")
}

public Func_EndRound(TASKID)
{
	if (iCheckMap)
	{
		iRoundEnd = 1
		
		new iAcer = TFM_GetGoldAcer()
		
		ExecuteForward(ifw_RoundEnd, ifw_Result, iAcer )
		
		new iPlayers[32], iNumber
		get_players(iPlayers, iNumber, "c")
		for (new i = 0; i < iNumber; i++)
			set_task(5.0, "TASK_EndGame", iPlayers[i] + TASK_END_GAME)
			
		
		
	}
}

public fw_PlayerKilled(iVictim, iKiller)
{
	if (!iCheckMap)
		return
		
	if (!is_user_connected(iVictim))
		return
		
	if (is_user_connected(iKiller))
	{
		cs_set_user_tked(iKiller, 0, 0)
		
		if (iVictim != iKiller)
		{
			iRealKill[iKiller]++
			UpdateFrags2(iKiller, iRealKill[iKiller])
		}
	}
		
	if (CheckPlayerBit(bit_InProtect, iVictim))
		ClearPlayerBit(bit_InProtect, iVictim)
		
	if (iRoundEnd)
		return
			
	
	_DrawRespawnNumber(iVictim, 1, 0 , 1)
	_MakeRespawnTask(iVictim, 0.0, 1)
	
	iHighestFrags = TFM_GetHighestScore()
	
	if (iHighestFrags >= iRoundScore)
	{
		if (!iRoundEnd)
		{
			new iAcer = TFM_GetGoldAcer()
			
			iRoundEnd = 1
				
			ExecuteForward(ifw_RoundEnd, ifw_Result, iAcer)
			remove_task(TASK_END_ROUND)
				
			new iPlayers[32], iNumber
				
			get_players(iPlayers, iNumber, "c")
				
			for (new i = 0; i < iNumber; i++)
				set_task(5.0, "TASK_EndGame", iPlayers[i] + TASK_END_GAME)
		}
	}
}
	
	
// Because CZ bot is a strange entity, so we must use this function
public TASK_RegisterCzFunction(TASKID)
{
	new id = TASKID - TASK_CZ_FUNCTION
	
	if (!iCheckMap)
		return
		
	if (!is_user_bot(id))
		return
	
	if (!get_cvar_num("bot_quota"))
		return 
		
	if (ham_cz)
	{
		if (is_user_alive(id))
			fw_PlayerSpawnPost(id)
			
		return
	}
	RegisterHamFromEntity(Ham_Spawn, id, "fw_PlayerSpawnPost", 1)
	RegisterHamFromEntity(Ham_TakeDamage, id, "fw_PlayerTakeDamage")
	RegisterHamFromEntity(Ham_TraceAttack, id, "fw_trace")
	RegisterHamFromEntity(Ham_Killed, id, "fw_PlayerKilled", 1)
	ham_cz = true
	
}

// -----------------Hamsandwich function------------------
// Called when a player respawns
public fw_PlayerSpawnPost(id)
{
	if (!iCheckMap)
		return
	
	if (!is_user_connected(id))
		return
		
	SetPlayerBit(bit_InProtect, id)
	#define PROTECTION_TIME_FFA 3.0
	set_task(PROTECTION_TIME_FFA, "DisableProtection_TASK", id + TASK_PROTECTION)
		
	new iCSDM_SpawnNumber = csred_CSDM_SpawnNumber()
		
	new iSpawnMethod = random(10)
		
	if (iSpawnMethod <= 8)
	{
		if (iCSDM_SpawnNumber)
			csred_DoRandomSpawn(id, SPAWN_TYPE_CSDM)
		else
			csred_DoRandomSpawn(id, SPAWN_TYPE_REGULAR)
	}
	else	csred_DoRandomSpawn(id, SPAWN_TYPE_REGULAR)
	
	
	fm_set_rendering(id, kRenderFxGlowShell, 255, 255, 255, kRenderNormal, 16)
}
	
// Called when a player takes damage
public fw_PlayerTakeDamage(iVictim, inflictor, iAttacker, Float:fDamage, DMGBITS)
{
	if (!is_user_connected(iVictim))
		return HAM_IGNORED
		
	if (!is_user_connected(iAttacker))
		return HAM_IGNORED
		
		
	if (!iCheckMap)
		return HAM_IGNORED
		
	if (iRoundEnd)
		return HAM_SUPERCEDE
		
	if (ClearPlayerBit(bit_InProtect, iVictim))
		return HAM_SUPERCEDE
		
	new CsTeams:iAttackerTeam = cs_get_user_team(iAttacker)
	new CsTeams:iVictimTeam = cs_get_user_team(iVictim)
	
	if (iAttackerTeam == iVictimTeam)
		SetHamParamFloat(4, fDamage * 1.5)
		
	return HAM_IGNORED
}

public fw_TraceAttack(iVictim, iAttacker, Float:fDamage, Float:direction[3], itraceresult, damagebits)
{
	if (!is_user_connected(iVictim))
		return HAM_IGNORED
		
	if (!is_user_connected(iAttacker))
		return HAM_IGNORED
		
	if (!iCheckMap)
		return HAM_IGNORED
		
	
	if (iRoundEnd)
		return HAM_SUPERCEDE
		
	if (CheckPlayerBit(bit_InProtect, iVictim))
		return HAM_SUPERCEDE
		
	
		
	new CsTeams:iAttackerTeam = cs_get_user_team(iAttacker)
	new CsTeams:iVictimTeam = cs_get_user_team(iVictim)
	
	if (iAttackerTeam == iVictimTeam)
		SetHamParamFloat(3, fDamage * 1.5)
		
	return HAM_IGNORED
}


//--------------End Hamsandwich function------------------

// Set this task to disable player's protection
public DisableProtection_TASK(TASKID)
{
	if (!iCheckMap)
		return
		
	new id = TASKID - TASK_PROTECTION;
	ClearPlayerBit(bit_InProtect, id)
	fm_set_rendering(id)
	
}

stock cvar_register()
{
	iCvar_RoundTime = register_cvar("GamePlay_FFA/RoundTime", "15.0")
	iCvar_WeaponMode = register_cvar("GamePlay_FFA/WeaponMode", "1")
	iCvar_RoundScore = register_cvar("GamePlay_FFA/MaxScore", "30")
		
}

stock UpdateFrags2(id, Frags)
{
	if (!is_user_connected(id))
		return
		
	set_pev(id, pev_frags, float(Frags))
	
	emessage_begin(MSG_BROADCAST, get_user_msgid("ScoreInfo"))
	ewrite_byte(id) // id
	ewrite_short(Frags) // frags
	ewrite_short(cs_get_user_deaths(id)) // deaths
	ewrite_short(0) // class?
	ewrite_short(get_user_team(id)) // team
	emessage_end()
}

stock CheckMap()
{
	new szMapName[32]
	get_mapname(szMapName, sizeof szMapName - 1)
	
	strtoupper(szMapName)
	
	if (equal(szMapName, "SM_", 3))
		return FFA_MODE_NORMAL
	
		
	return 0
}
