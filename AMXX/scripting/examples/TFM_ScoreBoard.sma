#include <amxmodx>
#include <amxmisc>
#include <TFM_WPN>

#include <SDK_Hook>

#include <GamePlay_Included/Tools.inc>
#include <GamePlay_Included/Manager.inc>
#include <GamePlay_Included/IntegerConstant.inc>

#include <fakemeta>
#include <Configs_Included/Scoreboard.inc>
#include <csred_Ace>
#include <mmcl_util>
#include <player_api>

//#include <hamsandwich> 
#include <cstrike>
#include <engine>
#include <csx>
#include <hamsandwich>


#define PLUGIN_NAME	"SCORE DISPLAY"
#define PLUGIN_VERSION	"-[No Info]-"
#define PLUGIN_AUTHOR	"REDPLANE"



#define TASK_COUNT_DOWN 1000
#define TASK_DRAW_SCOREBOARD	5000
#define TASK_DRAW_SCORE_TEXT	10000

#define SetPlayerBit(%1,%2)      (%1 |= (1<<(%2&31)))
#define ClearPlayerBit(%1,%2)    (%1 &= ~(1 <<(%2&31)))
#define CheckPlayerBit(%1,%2)    (%1 & (1<<(%2&31)))



//new HUDSYNC_HPAC



new iSecondRemain 




enum
{
	GAMEPLAY_NONE,
	GAMEPLAY_DM,
	GAMEPLAY_TDM,
	GAMEPLAY_ESC,
	GAMEPLAY_SM,
	GAMEPLAY_ZM,
	GAMEPLAY_GHOST,
	GAMEPLAY_GUNGAME
}

new iGamePlay = GAMEPLAY_NONE

/*			TRIE SECTION			*/

new Trie:iHudPosition[33]

/*			TRIE KEY			*/

#define SECTION_BOARD_X_TGA	"BOARD_X_TGA"
#define SECTION_BOARD_Y_TGA	"BOARD_Y_TGA"

#define SECTION_SCORE_X_TGA	"SCORE_X_TGA"
#define SECTION_SCORE_Y_TGA	"SCORE_Y_TGA"

#define SECTION_TIME_X_TGA	"TIME_X_TGA"
#define SECTION_TIME_Y_TGA	"TIME_Y_TGA"


#define SECTION_NAME_X_TGA	"NAME_X_TGA"
#define SECTION_NAME_Y_TGA	"NAME_Y_TGA"

#define SECTION_LEVEL_X_TGA	"LEVEL_X_TGA"
#define SECTION_LEVEL_Y_TGA	"LEVEL_Y_TGA"



#define TEXT_DISPLAY_TIME -1.0
#define TEXT_DISPLAY_TIME_TGA 9999.0

new iHUD_COLOR[3] = {255, 255, 255}

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);	
	
	// We have to know What gameplay we are playing
	
	new iRealGamePlay = get_current_gameplay()
	
	switch (iRealGamePlay)
	{
		case GAMEMODE_BY_PREFIX, GAMEMODE_DM: // Death Match is on
		{
			iGamePlay = GAMEPLAY_DM
			clcmd_deathmatch()
		}
		case GAMEMODE_TDM:
		{
			iGamePlay = GAMEPLAY_TDM
			clcmd_deathmatch()
		}
		case GAMEMODE_ESCAPE: // Escape mode is on
		{
			iGamePlay = GAMEPLAY_ESC
		
			register_concmd("ScoreBoard/Board/EscapeMode_X", "TGA_BOARD_X")
			register_concmd("ScoreBoard/Board/EscapeMode_Y", "TGA_BOARD_Y")
			
			register_concmd("ScoreBoard/Score/EscapeMode_X", "TGA_SCORE_X")
			register_concmd("ScoreBoard/Score/EscapeMode_Y", "TGA_SCORE_Y")
			
			register_concmd("ScoreBoard/Time/EscapeMode_X", "TGA_TIME_X")
			register_concmd("ScoreBoard/Time/EscapeMode_Y", "TGA_TIME_Y")
		}
		case GAMEMODE_FFA: // Individual Fight Mode is on
		{
			iGamePlay = GAMEPLAY_SM
				
			register_concmd("ScoreBoard/Board/SingleMode_X", "TGA_BOARD_X")
			register_concmd("ScoreBoard/Board/SingleMode_Y", "TGA_BOARD_Y")
			
			register_concmd("ScoreBoard/Score/SingleMode_X", "TGA_SCORE_X")
			register_concmd("ScoreBoard/Score/SingleMode_Y", "TGA_SCORE_Y")
			
			register_concmd("ScoreBoard/Time/SingleMode_X", "TGA_TIME_X")
			register_concmd("ScoreBoard/Time/SingleMode_Y", "TGA_TIME_Y")
		}
		case GAMEMODE_GUNGAME:
		{
			iGamePlay = GAMEPLAY_GUNGAME
			
			register_concmd("ScoreBoard/Board/GunGameMode_X", "TGA_BOARD_X")
			register_concmd("ScoreBoard/Board/GunGameMode_Y", "TGA_BOARD_Y")
			
			register_concmd("ScoreBoard/Score/GunGameMode_X", "TGA_SCORE_X")
			register_concmd("ScoreBoard/Score/GunGameMode_Y", "TGA_SCORE_Y")
			
			register_concmd("ScoreBoard/Time/GunGameMode_X", "TGA_TIME_X")
			register_concmd("ScoreBoard/Time/GunGameMode_Y", "TGA_TIME_Y")
			
			register_concmd("ScoreBoard/Name/GunGameMode_X", "TGA_NAME_X")
			register_concmd("ScoreBoard/Name/GunGameMode_Y", "TGA_NAME_Y")
			
			register_concmd("ScoreBoard/Level/GunGameMode_X", "TGA_LEVEL_X")
			register_concmd("ScoreBoard/Level/GunGameMode_Y", "TGA_LEVEL_Y")
			
		}
		case GAMEMODE_ZM: // Zombie mode is on
		{
			iGamePlay = GAMEPLAY_ZM
			
			register_concmd("ScoreBoard/Board/ZombieMode_X", "TGA_BOARD_X")
			register_concmd("ScoreBoard/Board/ZombieMode_Y", "TGA_BOARD_Y")
			
			register_concmd("ScoreBoard/Score/ZombieMode_X", "TGA_SCORE_X")
			register_concmd("ScoreBoard/Score/ZombieMode_Y", "TGA_SCORE_Y")
			
			register_concmd("ScoreBoard/Time/ZombieMode_X", "TGA_TIME_X")
			register_concmd("ScoreBoard/Time/ZombieMode_Y", "TGA_TIME_Y")
		}
	}
		
	register_concmd("RDR_HUD/ScoreBoard", "clcmd_RedrawScoreBoard")
	
	register_event("ResetHUD", "Event_ResetHUD", "be")  
	
	
	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawnPost", 1)
}


/*				SCORE BOARD				*/

//	Score Board [TGA]
public TGA_BOARD_X(id, iLevel, iCid)
{
	if (!cmd_access(id, iLevel, iCid, 2))
		return
		
	new szArg[10]
	read_argv(1, szArg, sizeof szArg - 1)
	set_trie_key_value(id, SECTION_BOARD_X_TGA, szArg)
}

public TGA_BOARD_Y(id, iLevel, iCid)
{
	if (!cmd_access(id, iLevel, iCid, 2))
		return
		
	new szArg[10]
	read_argv(1, szArg, sizeof szArg - 1)
	set_trie_key_value(id, SECTION_BOARD_Y_TGA, szArg)
}


/************************************************************************/

/*				SCORE TEXT				*/

//	Score Text [TGA]
public TGA_SCORE_X(id, iLevel, iCid)
{
	if (!cmd_access(id, iLevel, iCid, 2))
		return
		
	new szArg[10]
	read_argv(1, szArg, sizeof szArg - 1)
	set_trie_key_value(id, SECTION_SCORE_X_TGA, szArg)
}

public TGA_SCORE_Y(id, iLevel, iCid)
{
	if (!cmd_access(id, iLevel, iCid, 2))
		return
		
	new szArg[10]
	read_argv(1, szArg, sizeof szArg - 1)
	set_trie_key_value(id, SECTION_SCORE_Y_TGA, szArg)
}

/************************************************************************/

/*				TIME TEXT				*/


//	TIME TEXT [TGA]
public TGA_TIME_X(id, iLevel, iCid)
{
	if (!cmd_access(id, iLevel, iCid, 2))
		return
		
	new szArg[10]
	read_argv(1, szArg, sizeof szArg - 1)
	set_trie_key_value(id, SECTION_TIME_X_TGA, szArg)
}

public TGA_TIME_Y(id, iLevel, iCid)
{
	if (!cmd_access(id, iLevel, iCid, 2))
		return
		
	new szArg[10]
	read_argv(1, szArg, sizeof szArg - 1)
	set_trie_key_value(id, SECTION_TIME_Y_TGA, szArg)
}

/************************************************************************/

public clcmd_RedrawScoreBoard(id)
	draw_scoreboard_by_gameplay(id)
	
/*				NAME TEXT				*/

//	NAME TEXT [TGA]
public TGA_NAME_X(id, iLevel, iCid)
{
	if (!cmd_access(id, iLevel, iCid, 2))
		return
		
	new szArg[10]
	read_argv(1, szArg, sizeof szArg - 1)
	set_trie_key_value(id, SECTION_NAME_X_TGA, szArg)
}

public TGA_NAME_Y(id, iLevel, iCid)
{
	if (!cmd_access(id, iLevel, iCid, 2))
		return
		
	new szArg[10]
	read_argv(1, szArg, sizeof szArg - 1)
	set_trie_key_value(id, SECTION_NAME_Y_TGA, szArg)
}

/************************************************************************/

/*				LEVEL TEXT				*/

//	LEVEL TEXT [TGA]
public TGA_LEVEL_X(id, iLevel, iCid)
{
	if (!cmd_access(id, iLevel, iCid, 2))
		return
		
	new szArg[10]
	read_argv(1, szArg, sizeof szArg - 1)
	set_trie_key_value(id, SECTION_LEVEL_X_TGA, szArg)
}

public TGA_LEVEL_Y(id, iLevel, iCid)
{
	if (!cmd_access(id, iLevel, iCid, 2))
		return
		
	new szArg[10]
	read_argv(1, szArg, sizeof szArg - 1)
	set_trie_key_value(id, SECTION_LEVEL_Y_TGA, szArg)
}

/************************************************************************/


public Event_ResetHUD(id)
{
	if (is_user_bot(id))
		return
		
	draw_scoreboard_by_gameplay(id)
}

public client_putinserver(id)
{
	if (is_user_bot(id))
		return
	
	if (!iHudPosition[id])
		iHudPosition[id] = TrieCreate()
}

public client_disconnect(id)
{
	if (iHudPosition[id])
		TrieDestroy(iHudPosition[id])
		
	remove_task(id + TASK_DRAW_SCORE_TEXT)
	remove_task(id + TASK_DRAW_SCOREBOARD)
	remove_task(id + TASK_COUNT_DOWN)

}

	
public RoundEvent_Begin()
{
	if (task_exists(TASK_COUNT_DOWN))
		remove_task(TASK_COUNT_DOWN)
		
	new iPlayers[32], iNumber
	get_players(iPlayers, iNumber, "c")
	for (new i = 0; i < iNumber; i++)
	{
		new id = iPlayers[i]
		draw_scoretext_by_gameplay(id)
	}
		
	new Float:fSecondRemain
	
	if (iGamePlay == GAMEPLAY_DM)
		fSecondRemain =  DM_get_round_time() * 60
	else if (iGamePlay == GAMEPLAY_TDM)
		return
	else if (iGamePlay == GAMEPLAY_SM)
		fSecondRemain = FFA_get_round_time() * 60
	else if (iGamePlay == GAMEPLAY_ESC)
		fSecondRemain = EM_GetRoundTime() * 60
	else if (iGamePlay == GAMEPLAY_ZM)
		fSecondRemain = zp_get_round_time() * 60
	else if (iGamePlay == GAMEPLAY_GUNGAME)
		fSecondRemain = GG_GetRoundTime() * 60
		
	iSecondRemain = floatround(fSecondRemain)
	
	set_task(1.0, "TimeCountDown_TASK", TASK_COUNT_DOWN, _, _, "b")
	
}

public TDM_game_start()
{
	new Float:fSecondRemain
	
	fSecondRemain = TDM_get_round_time() * 60
	iSecondRemain = floatround(fSecondRemain)
	
	set_task(1.0, "TimeCountDown_TASK", TASK_COUNT_DOWN, _, _, "b")
}

public RoundEvent_CtWin()
{
	new iPlayers[32], iNumber
	get_players(iPlayers, iNumber, "c")
	
	for (new i = 0; i < iNumber; i++)
	{
		new id = iPlayers[i]
		draw_scoretext_by_gameplay(id)
	}
}

public RoundEvent_TerWin()
{
	new iPlayers[32], iNumber
	get_players(iPlayers, iNumber, "c")
	
	for (new i = 0; i < iNumber; i++)
	{
		new id = iPlayers[i]
		draw_scoretext_by_gameplay(id)
	}
}
	
public fw_PlayerSpawnPost(id)
{
	if (is_user_bot(id))
		return
		
	set_task(1.5, "TASK_DrawScoreBoard", id + TASK_DRAW_SCOREBOARD, _, _, "b")
		
	if (task_exists(id + TASK_DRAW_SCORE_TEXT))
		remove_task(id + TASK_DRAW_SCORE_TEXT)		
		
	set_task(1.0, "DrawScoreText_TASK", id + TASK_DRAW_SCORE_TEXT)
			
	
}

public TASK_DrawScoreBoard(TASKID)
{
	new id = TASKID - TASK_DRAW_SCOREBOARD
		
	draw_scoreboard_by_gameplay(id)
	remove_task(TASKID)
}

stock draw_scoreboard_by_gameplay(id)
{
	if (iGamePlay == GAMEPLAY_DM)
		draw_ScoreBoard_tga(id, SCOREBOARD_TGA_DM)
	else if (iGamePlay == GAMEPLAY_TDM)
		draw_ScoreBoard_tga(id, SCOREBOARD_TGA_DM)
	else if (iGamePlay == GAMEPLAY_SM)
		draw_ScoreBoard_tga(id, SCOREBOARD_TGA_SM)	
	else if (iGamePlay == GAMEPLAY_ESC)
	{
		draw_ScoreBoard_tga(id, SCOREBOARD_TGA_ESC)
		ShowScore_ESC(id)
	}
	else if (iGamePlay == GAMEPLAY_GHOST)
		draw_ScoreBoard_tga(id, SCOREBOARD_TGA_DM)
	else if (iGamePlay == GAMEPLAY_ZM)
	{
		if ( zp_get_current_gameplay() != ZB_GAMEPLAY_UNITED_1)
			draw_ScoreBoard_tga(id, SCOREBOARD_TGA_ZM)
		else
			draw_ScoreBoard_tga(id, SCOREBOARD_TGA_DM)
	}
	else if (iGamePlay == GAMEPLAY_GUNGAME)
	{
		draw_ScoreBoard_tga(id, SCOREBOARD_TGA_GG)
		ShowScore_GG(id)
	}
	
}

stock draw_scoretext_by_gameplay(id)
{
	
	if (!is_user_connected(id))
		return
		
	if (is_user_bot(id))
		return
		
	if (iGamePlay == GAMEPLAY_DM)
		ShowScore_DM(id)
	else if (iGamePlay == GAMEPLAY_TDM)
		ShowScore_TDM(id)
	else if (iGamePlay == GAMEPLAY_SM)
		ShowScore_SM(id)
	else if (iGamePlay == GAMEPLAY_ESC)
		ShowScore_ESC(id)
	else if (iGamePlay == GAMEPLAY_ZM)
		ShowScore_ZombieMode(id)
	else if (iGamePlay == GAMEPLAY_GUNGAME)
		ShowScore_GG(id)
		
	draw_scoreboard_by_gameplay(id)
}


public TimeCountDown_TASK(TASKID)
{
	if (iSecondRemain)
		iSecondRemain--
		
	new iPlayers[32], iNumber
	get_players(iPlayers, iNumber, "c")
	
	for (new i = 0; i < iNumber; i++)
	{
		new id = iPlayers[i]
		draw_text_time(id, iSecondRemain)
	}
}

public check_weapontype(weaponid)
{
	if (weaponid == CSW_USP || weaponid == CSW_GLOCK18 || weaponid == CSW_DEAGLE || weaponid == CSW_P228 || weaponid == CSW_ELITE || weaponid == CSW_FIVESEVEN)
		return TYPE_PISTOL
	if (weaponid == CSW_XM1014 || weaponid == CSW_M3)
		return TYPE_SHOTGUN
	if (weaponid == CSW_MP5NAVY || weaponid == CSW_TMP || weaponid == CSW_P90 || weaponid == CSW_MAC10 || weaponid == CSW_UMP45)
		return TYPE_RIFLE
	if (weaponid == CSW_M249 || weaponid == CSW_AK47 || weaponid == CSW_SG552 || weaponid == CSW_M4A1 || weaponid == CSW_AUG || weaponid == CSW_SCOUT || weaponid == CSW_AWP || weaponid == CSW_G3SG1 || weaponid == CSW_SG550 || weaponid == CSW_FAMAS || weaponid == CSW_GALIL)
		return TYPE_RIFLE
	return TYPE_NONE
}		


stock GetAllPlayers(&iAliveSoldier, &iAliveZombie)
{
	new iPreSoldier, iPreZombie
	
	for (new id = 1  ;id < get_maxplayers() ; id++)
	{
		if (!is_user_connected(id))
			continue
		
		
		if (!is_user_alive(id))
			continue
		
		new CsTeams:Team = cs_get_user_team(id)
		if (Team == CS_TEAM_CT)
			iPreSoldier++
		else if (Team == CS_TEAM_T)
			iPreZombie++
		
	}
	iAliveSoldier = iPreSoldier
	iAliveZombie = iPreZombie
}




/*			STOCK FUNCTION			*/

stock IsValidWeapon(iWeaponId)
{
	if (iWeaponId < CSW_P228)
		return 0
		
	if (iWeaponId > CSW_P90)
		return 0
		
	if (iWeaponId == 2)
		return 0
		
	return 1
}

stock ReformatTime(iTotalTime, Output_Minute[], flen, Output_Second[], slen)
{
	new Minutes, Seconds
	Minutes = iTotalTime / 60
	Seconds = iTotalTime - Minutes * 60
	
	if (Minutes < 0)
		formatex(Output_Minute, flen, "00")
	else
	{
		if (Minutes < 10)
			formatex(Output_Minute, flen, "0%d", Minutes)
		else	formatex(Output_Minute, flen, "%d", Minutes)
		
	}
	
	if (Seconds < 0)
		formatex(Output_Second, slen, "00")
	else
	{
		if (Seconds < 10)
			formatex(Output_Second, slen, "0%d", Seconds)
		else	formatex(Output_Second, slen, "%d", Seconds)
	}
}

stock draw_text_time(id, iSeconds)
{
	
	if (!is_user_connected(id))
		return
		
	if (is_user_bot(id))
		return
		
	if (iSeconds < 0)
		return
		
	new cMinute[10], cSecond[10], cTime[31]
	
	ReformatTime(iSeconds, cMinute, sizeof cMinute - 1, cSecond, sizeof cSecond - 1)
	
	formatex(cTime, sizeof cTime - 1, "%s : %s", cMinute, cSecond)
	
	new iCheckMin, iCheckSec
	
	iCheckMin = str_to_num(cMinute)
	iCheckSec = str_to_num(cSecond)
	
	new Float:fX, Float:fY
	get_float_from_key(id, SECTION_TIME_X_TGA, fX)
	get_float_from_key(id, SECTION_TIME_Y_TGA, fY)
		
	if (!iCheckMin && iCheckSec <= 20)
		MMCL_DrawText(id, cTime, 255, 0, 0, fX, fY, 1, TEXT_DISPLAY_TIME , TEXT_TIME)
	else MMCL_DrawText(id, cTime, iHUD_COLOR[0], iHUD_COLOR[1], iHUD_COLOR[2], fX, fY, 1, TEXT_DISPLAY_TIME , TEXT_TIME)
}

public csred_PlayerKilledPost(iVictim, iKiller)
{
	
	if (iGamePlay == GAMEPLAY_TDM || iGamePlay == GAMEPLAY_SM || iGamePlay == GAMEPLAY_GUNGAME)
	{
		new iPlayers[32], iNumber
		get_players(iPlayers, iNumber, "c")
		
		for (new i = 0; i < iNumber ; i++)
		{
			new id = iPlayers[i]
			
			if (task_exists(id + TASK_DRAW_SCORE_TEXT))
				remove_task(id + TASK_DRAW_SCORE_TEXT)
				
			set_task(1.0, "DrawScoreText_TASK", id + TASK_DRAW_SCORE_TEXT)
			
		}
	}
	else if (iGamePlay == GAMEPLAY_ZM)
	{
		if (zp_get_current_gameplay() == ZB_GAMEPLAY_UNITED_1)
		{
			new iPlayers[32], iNumber
			get_players(iPlayers, iNumber, "c")
			
			for (new i = 0; i < iNumber ; i++)
			{
				new id = iPlayers[i]
				
				if (task_exists(id + TASK_DRAW_SCORE_TEXT))
					remove_task(id + TASK_DRAW_SCORE_TEXT)
					
				set_task(1.0, "DrawScoreText_TASK", id + TASK_DRAW_SCORE_TEXT)
				
			}
		}
	}
}

public DrawScoreText_TASK(TASKID)
{
	new id = TASKID - TASK_DRAW_SCORE_TEXT
	
	draw_scoretext_by_gameplay(id)
}

/*		SOME SHOW SCORE BOARD STOCKS			*/

// 	DEATH MATCH - ORIGINAL
stock ShowScore_DM(id)
{
	
	new iBL_Score = DM_get_T_score()
	new iMaxRound = DM_get_max_round()
	new iGR_Score = DM_get_CT_score()
	
	//	Score Info - Store here
	new cScoreInfo[32]
	
	//	Score Position - Store here
	new Float:fX
	new Float:fY
	
	
		
	new fOutput[3], sOutput[3], tOutput[3]
			
	parse_number(iBL_Score, fOutput)
	parse_number(iMaxRound, sOutput)
	parse_number(iGR_Score, tOutput)
			
	formatex(cScoreInfo, 31, "%d%d%d        %d%d%d        %d%d%d", fOutput[0], fOutput[1], fOutput[2], sOutput[0], sOutput[1], sOutput[2], tOutput[0], tOutput[1], tOutput[2])
		
			
	get_float_from_key(id, SECTION_SCORE_X_TGA, fX)
	get_float_from_key(id, SECTION_SCORE_Y_TGA, fY)
			
			
	//	DRAW SCORE INFORMATION
	meta_DrawText(id, cScoreInfo, fX, fY, iHUD_COLOR[0], iHUD_COLOR[1], iHUD_COLOR[2] , TEXT_DISPLAY_TIME)
			
}

//	TEAM DEATH MATCH

stock ShowScore_TDM(id)
{
	new cScoreInfo[128]
	
	new iBlScore = TDM_get_score_terrorist()
	new iGrScore = TDM_get_score_ct()
	new iMaxScore = TDM_get_round_score()
	
	new Float:fX
	new Float:fY
	
			
	new fOutput[3], sOutput[3], tOutput[3]
			
	parse_number(iBlScore, fOutput)
	parse_number(iMaxScore, sOutput)
	parse_number(iGrScore, tOutput)
			
	formatex(cScoreInfo, sizeof cScoreInfo - 1, "%d%d%d        %d%d%d        %d%d%d",  fOutput[0], fOutput[1], fOutput[2], sOutput[0], sOutput[1], sOutput[2], tOutput[0], tOutput[1], tOutput[2])
				
			
	get_float_from_key(id, SECTION_SCORE_X_TGA, fX)
	get_float_from_key(id, SECTION_SCORE_Y_TGA, fY)
			
	
			
	//	DRAW SCORE INFORMATION
	meta_DrawText(id, cScoreInfo, fX, fY, iHUD_COLOR[0], iHUD_COLOR[1], iHUD_COLOR[2] , TEXT_DISPLAY_TIME)
		
}

//	ESCAPE MODE

stock ShowScore_ESC(id)
{
	new iESC_Score = EM_GetEscapeTeamScore()
	new iESC_MaxEscape = EM_GetMaxEscape()
	
	
	new fOutput[3], sOutput[3]
	new cScoreInfo[32]
	
	new Float:fX, Float:fY
	
	parse_number(iESC_Score, fOutput)
	parse_number(iESC_MaxEscape, sOutput)
	
	formatex(cScoreInfo, sizeof cScoreInfo - 1, "%d%d%d  %d%d%d",  fOutput[0], fOutput[1], fOutput[2], sOutput[0], sOutput[1], sOutput[2])
			
	get_float_from_key(id, SECTION_SCORE_X_TGA, fX)
	get_float_from_key(id, SECTION_SCORE_Y_TGA, fY)
			
	
		
	//	DRAW SCORE INFORMATION
	meta_DrawText(id, cScoreInfo, fX, fY, iHUD_COLOR[0], iHUD_COLOR[1], iHUD_COLOR[2] , TEXT_DISPLAY_TIME)
}

//	INDIVIDUAL FIGHT MODE

stock ShowScore_SM(id)
{
	new iKillScore = FFA_get_user_frag(id)
	new iMaxScore = FFA_get_max_score()
	new iHighestScore = FFA_get_highest_score()
	
	//	Store information of Score here
	new cScoreInfo[128]
	
	//	Store information of Score's position here
	new Float:fX, Float:fY
	
	
			
	new fOutput[3], sOutput[3], tOutput[3]
		
	parse_number(iKillScore, fOutput)
	parse_number(iMaxScore, sOutput)
	parse_number(iHighestScore, tOutput)
			
	formatex(cScoreInfo, 127, "%d%d%d        %d%d%d        %d%d%d", fOutput[0], fOutput[1], fOutput[2], sOutput[0], sOutput[1], sOutput[2], tOutput[0], tOutput[1], tOutput[2])
				
			
	get_float_from_key(id, SECTION_SCORE_X_TGA, fX)
	get_float_from_key(id, SECTION_SCORE_Y_TGA, fY)
	
			
	//	DRAW SCORE INFORMATION
	meta_DrawText(id, cScoreInfo, fX, fY, iHUD_COLOR[0], iHUD_COLOR[1], iHUD_COLOR[2] , TEXT_DISPLAY_TIME)
	
}

//	GUN GAME

stock ShowScore_GG(id)
{
	
	new iLevel = GG_GetPlayerLevel(id)
	new iKillRequire = GG_GetPlayerKills(id)
	
	new fOutput[3], tOutput[3]
	
	parse_number(iLevel, fOutput)
	parse_number(iKillRequire, tOutput)
	
	new cScoreInfo[128]
	formatex(cScoreInfo, sizeof cScoreInfo - 1, "%d%d%d                   %d%d%d", fOutput[0], fOutput[1], fOutput[2], tOutput[0], tOutput[1], tOutput[2])	
			
		
	new Float:fX, Float:fY
	get_float_from_key(id, SECTION_SCORE_X_TGA, fX)
	get_float_from_key(id, SECTION_SCORE_Y_TGA, fY)
			
			
	//	DRAW SCORE INFORMATION
	meta_DrawText(id, cScoreInfo, fX, fY, iHUD_COLOR[0], iHUD_COLOR[1], iHUD_COLOR[2] , TEXT_DISPLAY_TIME)
			
			
	new iAcer = TFM_GetGoldAcer()
			
	new szName[32], szLevel[32]
			
	if (!is_user_connected(iAcer))
	{
		formatex(szName, sizeof szName - 1, "WAITING DATA...")
		formatex(szLevel, sizeof szLevel - 1, "WAITING DATA...")
	}
	else
	{
		get_user_name(iAcer, szName, sizeof szName - 1)
		formatex(szLevel, sizeof szLevel - 1, "%d", GG_GetPlayerLevel(iAcer))
	}
			
	get_float_from_key(id, SECTION_NAME_X_TGA, fX)
	get_float_from_key(id, SECTION_NAME_Y_TGA, fY)
	MMCL_DrawText(id, szName, 255, 255, 0, fX, fY, 0, TEXT_DISPLAY_TIME, TEXT_GG_HIGHEST_NAME)
			
	get_float_from_key(id, SECTION_LEVEL_X_TGA, fX)
	get_float_from_key(id, SECTION_LEVEL_Y_TGA, fY)
	MMCL_DrawText(id, szLevel, 0, 255, 255, fX, fY, 0, TEXT_DISPLAY_TIME, TEXT_GG_HIGHEST_LEVEL)
			
}


// 		ZOMBIE

stock ShowScore_ZombieMode(id)
{
	new cScoreInfo[128]
	
	new iZombieScore = zp_get_score(TEAM_TERRORIST)
	new iHumanScore = zp_get_score(TEAM_CT)
	
	new iMaxScore = zp_get_max_score()

	
	new Float:fX, Float:fY
	
		
	new fOutput[3], sOutput[3], tOutput[3]
			
	parse_number(iHumanScore, fOutput)
	parse_number(iZombieScore, tOutput)
	parse_number(iMaxScore, sOutput)
			
			
	formatex(cScoreInfo, sizeof cScoreInfo - 1, "%d%d%d        %d%d%d        %d%d%d",  fOutput[0], fOutput[1], fOutput[2], sOutput[0], sOutput[1], sOutput[2] ,tOutput[0], tOutput[1], tOutput[2])
				
		
	get_float_from_key(id, SECTION_SCORE_X_TGA, fX)
	get_float_from_key(id, SECTION_SCORE_Y_TGA, fY)
			
			
	//	DRAW SCORE INFO
	set_hudmessage(iHUD_COLOR[0], iHUD_COLOR[1], iHUD_COLOR[2], fX, fY, 0, 0.0, TEXT_DISPLAY_TIME_TGA, 0.0, 0.0, -1)
	//ShowSyncHudMsg(id, HUD_SCORE, cScoreInfo)
}

/*			DRAW TGA AND SPRITE FUNCTION			*/


stock draw_ScoreBoard_tga(id, szHud[])
{
	if (!is_user_connected(id))
		return
		
	if (is_user_bot(id))
		return
		
	new Float:fX
	new Float:fY
	
	get_float_from_key(id, SECTION_BOARD_X_TGA, fX)
	get_float_from_key(id, SECTION_BOARD_Y_TGA, fY)
	
	new szFullTga[256]
	
	formatex(szFullTga, sizeof szFullTga - 1, "%s/SCOREBOARD/%s.tga", TFM_TGA_DIRECTORY, szHud)
	
	
	if (!file_exists(szFullTga))
		return
	
	formatex(szFullTga, sizeof szFullTga - 1, "%s/SCOREBOARD/%s", TFM_TGA_DIRECTORY, szHud)
	
	MMCL_DrawTGA(id, szFullTga, 255, 255, 255, 255, fX, fY, 1, 0, 0.0, 0.0, -1.0, CHANNEL_SCOREBOARD_TGA)
}

/*			DRAW TEXT FUNCTION				*/

stock meta_DrawText(id, TEXT[], Float:fX, Float:fY, iRed, iGreen, iBlue, Float:fDisplayTime)
{
	
	if (!is_user_connected(id))
		return
		
	if (is_user_bot(id))
		return
		
		
	MMCL_DrawText(id, TEXT,  iRed, iGreen, iBlue, fX, fY, 1, fDisplayTime, TEXT_TEAM_SCORE)	
}

stock parse_number(iInput, iOutput[3])
{
	if (iInput > 999)
		iInput = 999
	else if (iInput < 0)
		iInput = 0
		
	new iFirstNum, iSecondNum, iThirdNum
	
	iFirstNum = CheckMaxMulti(iInput, 100)
	
	new iSecond = iInput - 100* iFirstNum
	iSecondNum = CheckMaxMulti(iSecond, 10)
	
	iThirdNum = iInput - (100 * iFirstNum) - (10 * iSecondNum)
	
	iOutput[0] = iFirstNum
	iOutput[1] = iSecondNum
	iOutput[2] = iThirdNum
	
}
	
stock CheckMaxMulti(iInput, Multi)
{
	
	for (new i = 0; i < 10; i++)
	{
		if (iInput - Multi * i >= Multi)
			continue
			 
		return i
		
	}
	return 0
}


stock clcmd_deathmatch()
{
			
	register_concmd("ScoreBoard/Board/DeathMatch_X", "TGA_BOARD_X")
	register_concmd("ScoreBoard/Board/DeathMatch_Y", "TGA_BOARD_Y")
					
	register_concmd("ScoreBoard/Score/DeathMatch_X", "TGA_SCORE_X")
	register_concmd("ScoreBoard/Score/DeathMatch_Y", "TGA_SCORE_Y")
			
	register_concmd("ScoreBoard/Time/DeathMatch_X", "TGA_TIME_X")
	register_concmd("ScoreBoard/Time/DeathMatch_Y", "TGA_TIME_Y")
}




stock set_trie_key_value(id, szKey[], szValue[])
{
	if (is_user_bot(id))
		return
		
	if (!iHudPosition[id])
		return
		
	TrieSetString(iHudPosition[id], szKey, szValue)
}

stock get_float_from_key(id, szKey[], &Float:fOutput)
{
	if (is_user_bot(id))
		return
		
	if (!iHudPosition[id])
		return
		
	new szArg[10]
	TrieGetString(iHudPosition[id], szKey, szArg, sizeof szArg - 1)
	fOutput = str_to_float(szArg)
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
