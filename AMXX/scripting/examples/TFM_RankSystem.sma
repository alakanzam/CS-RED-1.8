/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>
#include <RankManagement/TFM_LevelSystem>
#include <TFM_WPN>

#include <csx>

#include <GamePlay_Included/Tools.inc>
#include <cstrike>


#include <celltrie>

#define PLUGIN "Rank Information"
#define VERSION "-[No Info]-"
#define AUTHOR "Nguyen Duy Linh"

#define TASK_UPDATE_CLIENT_DEATH	5000


#define NVAULT_DIRECTORY "addons/amxmodx/data/vault"

#define MAX_PLAYER 33




enum
{
	LINE_TOTAL_KILL,
	LINE_HEADSHOT,
	LINE_KNIFE_KILL,
	LINE_GRENADE_KILL,
	LINE_DEATH,
	LINE_BOMB_PLANT,
	LINE_BOMB_DEFUSE,
	LINE_NONE,
	LINE_LR_TOTAL_KILL,
	LINE_LR_HEADSHOT,
	LINE_LR_KNIFE_KILL,
	LINE_LR_GRENADE_KILL,
	LINE_LR_DEATH,
	LINE_LR_BOMB_PLANT,
	LINE_LR_BOMB_DEFUSE,
}

/*		  TRIE SECTION			*/

new Trie:iPlayerRankInfo[MAX_PLAYER]

/************************************************/
/*		TRIE DATA FIELD			*/

#define SECTION_TEMP_KILL	"TEMP_KILL"
#define SECTION_TEMP_HEADSHOT	"TEMP_HEADSHOT"
#define SECTION_TEMP_KNIFE	"TEMP_KNIFE"
#define SECTION_TEMP_GRENADE	"TEMP_GRENADE"
#define SECTION_TEMP_DEATH	"TEMP_DEATH"
#define SECTION_TEMP_PLANT	"TEMP_PLANT"
#define SECTION_TEMP_DEFUSE	"TEMP_DEFUSE"


#define SECTION_KILL	"ST_KILL"
#define SECTION_HEADSHOT	"ST_HEADSHOT"
#define SECTION_KNIFE	"ST_KNIFE"
#define SECTION_GRENADE	"ST_GRENADE"
#define SECTION_PLANT	"ST_PLANT"
#define SECTION_DEFUSE	"ST_DEFUSE"
#define SECTION_DEATH	"ST_DEATH"

/************************************************/

#define SECTION_RANK_NAME "RANKINFO_NAME"
#define RANK_LOG_FILE "is_stop.txt"

public plugin_natives()
{
	register_native("TFM_get_user_rank", "native_get_user_rank", 1)
	register_native("TFM_set_user_rank", "native_set_user_rank", 1)
	
	register_native("TFM_save_user_rankinfo", "native_save_user_rankinfo", 1)
	register_native("TFM_load_user_rankinfo", "native_load_user_rankinfo", 1)
}

// ************************** NATIVE *******************************

public native_get_user_rank(id, szOutput[], iTextLen)
{
	if (!is_valid_player(id))
		return
	
	if (!iPlayerRankInfo[id])
		return
		
	param_convert(2)
	
	TrieGetString(iPlayerRankInfo[id], SECTION_RANK_NAME, szOutput, iTextLen)
	
}

public native_set_user_rank(id, szRankName[])
{
	if (!is_valid_player(id))
		return
	
	if (!iPlayerRankInfo[id])
		return
		
	param_convert(2)
	
	TrieSetString(iPlayerRankInfo[id], SECTION_RANK_NAME, szRankName)
}

public native_save_user_rankinfo(id, szNickName[])
{
	if (!is_valid_player(id))
		return
		
	param_convert(2)
	
	save_user_rank_info(id, szNickName)
}

public native_load_user_rankinfo(id, szNickName[])
{
	if (!is_valid_player(id))
		return
		
	param_convert(2)
	load_user_rank_info(id, szNickName)
}

public plugin_init() 
{
	
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	new szCfgDir[64], szCfgFile[128]
	

	
	get_configsdir(szCfgDir, sizeof szCfgFile - 1)
	formatex(szCfgFile, sizeof szCfgFile - 1, "%s/%s", szCfgDir, RANK_LOG_FILE)
	
	if (file_exists(szCfgFile))
		delete_file(szCfgFile)		
}
	
	
public TM_PlayerLoggedIn(id, szNickName[])	
	load_user_rank_info(id, szNickName)


public client_putinserver(id)
{
	
	if (!iPlayerRankInfo[id])
		iPlayerRankInfo[id] = TrieCreate()
		
	if (is_user_bot(id))
	{
		new szName[32]
		get_user_name(id, szName, sizeof szName - 1)
		
		load_user_rank_info(id, szName)
		
	}
}

public client_disconnect(id)
{
	if (iPlayerRankInfo[id])
		TrieDestroy(iPlayerRankInfo[id])
}

public UpdateMyList(TEAM_WIN)
{
	
	new cfgdir[64], cfgfile[128]
	
	get_configsdir(cfgdir, sizeof cfgdir - 1)
	formatex(cfgfile, sizeof cfgfile - 1, "%s/%s", cfgdir, RANK_LOG_FILE)
	
	if (file_exists(cfgfile))
		delete_file(cfgfile)
	
	
	//	Create a new one
	write_file(cfgfile, "1", 0)
	
	new szInfo[256]
	
	new iPlayerCount = 0
	
	new iPlayers[32], iNumber
	get_players(iPlayers, iNumber)
	
	
	
	for (new i = 0; i < iNumber; i++)
	{
		new id = iPlayers[i]
		
		if (!is_user_connected(id))
			continue
			
		
		new szName[32]
		get_user_name(id, szName, sizeof szName - 1)
		
		save_user_rank_info(id, szName)
		
		new szRankFile[256]
		formatex(szRankFile, sizeof szRankFile - 1, "%s/%s.ini", NVAULT_DIRECTORY, szName)
		
		
		new IS_ADMIN
		if (is_user_admin(id))
			IS_ADMIN = 1
		else IS_ADMIN = 0
		
		new iLine 
		
		
		iLine = 1
		
		formatex(szInfo, sizeof szInfo - 1, "[name]%s", szName)
		write_file(cfgfile, szInfo, iPlayerCount * 8 + iLine)
		
		iLine = 2
		formatex(szInfo, sizeof szInfo - 1, "[team]%d", get_user_team(id))
		write_file(cfgfile, szInfo, iPlayerCount * 8 + iLine)
		
		iLine = 3
		formatex(szInfo, sizeof szInfo - 1, "[gp]%d", TFM_get_awarded_gp(id))
		write_file(cfgfile, szInfo, iPlayerCount * 8 + iLine)
		
		iLine = 4
		formatex(szInfo, sizeof szInfo - 1, "[coin]%d", TFM_get_awarded_coin(id))
		write_file(cfgfile, szInfo, iPlayerCount * 8 + iLine)
		
		iLine = 5
		formatex(szInfo, sizeof szInfo - 1, "[level_up]%d", TFM_is_user_promoted(id))
		write_file(cfgfile, szInfo, iPlayerCount * 8 + iLine)
		
		iLine = 6
		formatex(szInfo, sizeof szInfo - 1, "[admin]%d", IS_ADMIN)
		write_file(cfgfile, szInfo, iPlayerCount * 8 + iLine)
		
		new iTempData
		
		iLine = 7c
		TrieGetCell(iPlayerRankInfo[id], SECTION_TEMP_KILL, iTempData)
		formatex(szInfo, sizeof szInfo - 1, "[kill]%d", iTempData)
		write_file(cfgfile, szInfo, iPlayerCount * 8 + iLine)
		
		iLine = 8
		TrieGetCell(iPlayerRankInfo[id], SECTION_TEMP_DEATH, iTempData)
		formatex(szInfo, sizeof szInfo - 1, "[death]%d", iTempData)
		write_file(cfgfile, szInfo, iPlayerCount * 8 + iLine)
		
		iPlayerCount++
		
	}
	
	new szTeamWin[32]
	formatex(szTeamWin, sizeof szTeamWin - 1, "[TEAM_WIN]%d", TEAM_WIN)
	write_file(cfgfile, szTeamWin, iPlayerCount * 8 + 1)
	
	
	
	
	
}

/************************************************************************************/

public DM_RoundExit(TEAMWIN)
	UpdateMyList(TEAMWIN)
	
public TDM_game_over(iWinTeam)
	UpdateMyList(iWinTeam)
	
public FFA_game_over(iAcer)
{
	
	if (!is_user_admin(iAcer))
		UpdateMyList(0)
	else	
	{
		new CsTeams:iTeam = cs_get_user_team(iAcer)
		
		if (iTeam == CS_TEAM_T)
			UpdateMyList(1)
		else if (iTeam == CS_TEAM_CT)
			UpdateMyList(2)
		else	UpdateMyList(0)
	}
	
}

public GunGame_GameExit(iAcer)
{
	if (!is_user_admin(iAcer))
		UpdateMyList(0)
	else	
	{
		new CsTeams:iTeam = cs_get_user_team(iAcer)
		
		if (iTeam == CS_TEAM_T)
			UpdateMyList(1)
		else if (iTeam == CS_TEAM_CT)
			UpdateMyList(2)
		else	UpdateMyList(0)
	}
}

public ES_RoundEnd(iTeamWin)
	UpdateMyList(iTeamWin)
	
/************************************************************************************/


public PW_GrenadeDamage(iVictim, iAttacker, iPrimaryWpnId, iAliveStatus)
{
	if (iAliveStatus)
		return
		
	new iTeamKill = 0
	
	if (cs_get_user_team(iVictim)== cs_get_user_team(iAttacker))
		iTeamKill = 1
		
	client_death(iAttacker, iVictim, get_pw_real_id(iPrimaryWpnId), HIT_GENERIC, iTeamKill)
}

public client_death(iKiller, iVictim, iWPN_ID, iHitPlace, iTeamKill)
{
	if (!is_user_connected(iKiller))
		return
		
	if (!is_user_connected(iVictim))
		return	
		
	new iTempData
		
	if (!iTeamKill)
	{
		// 			INCREASE KILL POINT
		
		TrieGetCell(iPlayerRankInfo[iKiller], SECTION_KILL, iTempData)
		iTempData++
		TrieSetCell(iPlayerRankInfo[iKiller], SECTION_KILL, iTempData)
		
		//			INCREASE TEMPORARY KILL
		TrieGetCell(iPlayerRankInfo[iKiller], SECTION_TEMP_KILL, iTempData)
		iTempData++
		TrieSetCell(iPlayerRankInfo[iKiller], SECTION_TEMP_KILL, iTempData)
		//			         END
		
		if (iHitPlace == HIT_HEAD)
		{
			TrieGetCell(iPlayerRankInfo[iKiller], SECTION_TEMP_HEADSHOT, iTempData)
			iTempData++
			TrieSetCell(iPlayerRankInfo[iKiller], SECTION_TEMP_HEADSHOT, iTempData)
			
			TrieGetCell(iPlayerRankInfo[iKiller], SECTION_HEADSHOT, iTempData)
			iTempData++
			TrieSetCell(iPlayerRankInfo[iKiller], SECTION_HEADSHOT, iTempData)
			
			if (iWPN_ID == CSW_KNIFE)
			{
				TrieGetCell(iPlayerRankInfo[iKiller], SECTION_TEMP_KNIFE, iTempData)
				iTempData++
				TrieSetCell(iPlayerRankInfo[iKiller], SECTION_TEMP_KNIFE, iTempData)
				
				
				TrieGetCell(iPlayerRankInfo[iKiller], SECTION_KNIFE, iTempData)
				iTempData++
				TrieSetCell(iPlayerRankInfo[iKiller], SECTION_KNIFE, iTempData)
			}
		}
		else if (iHitPlace != HIT_HEAD)
		{
			if (iWPN_ID == CSW_KNIFE)
			{
				TrieGetCell(iPlayerRankInfo[iKiller], SECTION_TEMP_KNIFE, iTempData)
				iTempData++
				TrieSetCell(iPlayerRankInfo[iKiller], SECTION_TEMP_KNIFE, iTempData)
				
				TrieGetCell(iPlayerRankInfo[iKiller], SECTION_KNIFE, iTempData)
				iTempData++
				TrieSetCell(iPlayerRankInfo[iKiller], SECTION_KNIFE, iTempData)
				
			}
			else if (iWPN_ID == CSW_HEGRENADE)
			{
				
				TrieGetCell(iPlayerRankInfo[iKiller], SECTION_TEMP_GRENADE, iTempData)
				iTempData++
				TrieSetCell(iPlayerRankInfo[iKiller], SECTION_TEMP_GRENADE, iTempData)
				
				TrieGetCell(iPlayerRankInfo[iKiller], SECTION_GRENADE, iTempData)
				iTempData++
				TrieSetCell(iPlayerRankInfo[iKiller], SECTION_GRENADE, iTempData)
			}
		}
	}
	else
	{
		new iWeaponMode
		if (is_ffa_on(iWeaponMode))
		{
			new iParam[5]
			iParam[0] = iKiller
			iParam[1] = iVictim
			iParam[2] = iWPN_ID
			iParam[3] = iHitPlace
			iParam[4] = 0 // No Team Kill
			set_task(0.1, "UpdateClientDeath_TASK", TASK_UPDATE_CLIENT_DEATH, iParam, sizeof iParam)
			return
		}
		
	}
	
	
	TrieGetCell(iPlayerRankInfo[iKiller], SECTION_TEMP_DEATH, iTempData)
	iTempData++
	TrieSetCell(iPlayerRankInfo[iKiller], SECTION_TEMP_DEATH, iTempData)
		
	TrieGetCell(iPlayerRankInfo[iKiller], SECTION_DEATH, iTempData)
	iTempData++
	TrieSetCell(iPlayerRankInfo[iKiller], SECTION_DEATH, iTempData)
		
}

public UpdateClientDeath_TASK(iParam[5], TASKID)
	client_death(iParam[0], iParam[1], iParam[2], iParam[3], 0)

public bomb_defused(iDefuser)
{
	new iTempData
	
	TrieGetCell(iPlayerRankInfo[iDefuser], SECTION_TEMP_DEFUSE, iTempData)
	iTempData++
	TrieSetCell(iPlayerRankInfo[iDefuser], SECTION_TEMP_DEFUSE, iTempData)
	
	
	TrieGetCell(iPlayerRankInfo[iDefuser], SECTION_DEFUSE, iTempData)
	iTempData++
	TrieSetCell(iPlayerRankInfo[iDefuser], SECTION_DEFUSE, iTempData)
}

public bomb_planted(iPlanter)
{
	new iTempData
	
	TrieGetCell(iPlayerRankInfo[iPlanter], SECTION_TEMP_PLANT, iTempData)
	iTempData++
	TrieSetCell(iPlayerRankInfo[iPlanter], SECTION_TEMP_PLANT, iTempData)
	
	TrieGetCell(iPlayerRankInfo[iPlanter], SECTION_PLANT, iTempData)
	iTempData++
	TrieSetCell(iPlayerRankInfo[iPlanter], SECTION_PLANT, iTempData)
	
}

stock load_user_rank_info(id, szNickName[])
{
	new szRankFile[256]
	formatex(szRankFile, sizeof szRankFile - 1, "%s/%s.ini", NVAULT_DIRECTORY, szNickName)
	
	if (!file_exists(szRankFile))
		return
		
	
	new szInfo[64], iTextLen
	
	read_file(szRankFile, LINE_TOTAL_KILL, szInfo, sizeof szInfo- 1, iTextLen)
	replace(szInfo, sizeof szInfo - 1, "[TotalKill]", "")
	TrieSetCell(iPlayerRankInfo[id], SECTION_KILL, str_to_num(szInfo))
	
	read_file(szRankFile, LINE_HEADSHOT, szInfo, sizeof szInfo - 1, iTextLen)
	replace(szInfo, sizeof szInfo - 1, "[Headshot]", "")
	TrieSetCell(iPlayerRankInfo[id], SECTION_HEADSHOT, str_to_num(szInfo))
	
	read_file(szRankFile, LINE_KNIFE_KILL, szInfo, sizeof szInfo - 1, iTextLen)
	replace(szInfo, sizeof szInfo - 1, "[KnifeKill]", "")
	TrieSetCell(iPlayerRankInfo[id], SECTION_KNIFE, str_to_num(szInfo))
	
	read_file(szRankFile, LINE_GRENADE_KILL, szInfo, sizeof szInfo - 1, iTextLen)
	replace(szInfo, sizeof szInfo - 1, "[GrenadeKill]", "")
	TrieSetCell(iPlayerRankInfo[id], SECTION_GRENADE, str_to_num(szInfo))
	
	read_file(szRankFile, LINE_DEATH, szInfo, sizeof szInfo - 1, iTextLen)
	replace(szInfo, sizeof szInfo - 1, "[Death]", "")
	TrieSetCell(iPlayerRankInfo[id], SECTION_DEATH, str_to_num(szInfo))
	
	read_file(szRankFile, LINE_BOMB_PLANT, szInfo, sizeof szInfo - 1 ,iTextLen)
	replace(szInfo, sizeof szInfo - 1, "[BombPlt]", "")
	TrieSetCell(iPlayerRankInfo[id], SECTION_PLANT, str_to_num(szInfo))
	
	read_file(szRankFile, LINE_BOMB_DEFUSE, szInfo, sizeof szInfo - 1, iTextLen)
	replace(szInfo, sizeof szInfo - 1, "[BombDfs]", "")
	TrieSetCell(iPlayerRankInfo[id], SECTION_DEFUSE, str_to_num(szInfo))
	
}

stock save_user_rank_info(id, szNickName[])
{
	
	if (containi(szNickName, "\") != -1)
		return 
	if (containi(szNickName, "/") != -1)
		return 
	if (containi(szNickName, ":") != -1)
		return
	if (containi(szNickName, "*") != -1)
		return
	if (containi(szNickName, "?") != -1)
		return
	if (containi(szNickName, "<") != -1)
		return
	if (containi(szNickName, ">") != -1)
		return
	if (containi(szNickName, "|") != -1)
		return
		
	new szRankFile[256]
	new szInfo[64]
	new iTempData
	
	formatex(szRankFile, sizeof szRankFile - 1, "%s/%s.ini", NVAULT_DIRECTORY, szNickName)
	
	TrieGetCell(iPlayerRankInfo[id], SECTION_KILL, iTempData)
	formatex(szInfo, sizeof szInfo - 1, "[TotalKill]%d", iTempData)
	write_file(szRankFile, szInfo, LINE_TOTAL_KILL)
	
	TrieGetCell(iPlayerRankInfo[id], SECTION_HEADSHOT, iTempData)
	formatex(szInfo, sizeof szInfo - 1, "[Headshot]%d", iTempData)
	write_file(szRankFile, szInfo, LINE_HEADSHOT)
	
	TrieGetCell(iPlayerRankInfo[id], SECTION_KNIFE, iTempData)
	formatex(szInfo, sizeof szInfo - 1, "[KnifeKill]%d", iTempData)
	write_file(szRankFile, szInfo, LINE_KNIFE_KILL)
	
	TrieGetCell(iPlayerRankInfo[id], SECTION_GRENADE, iTempData)
	formatex(szInfo, sizeof szInfo -1 , "[GrenadeKill]%d", iTempData)
	write_file(szRankFile, szInfo, LINE_GRENADE_KILL)
	
	TrieGetCell(iPlayerRankInfo[id], SECTION_DEATH, iTempData)
	formatex(szInfo, sizeof szInfo - 1, "[Death]%d", iTempData)
	write_file(szRankFile, szInfo, LINE_DEATH)
	
	TrieGetCell(iPlayerRankInfo[id], SECTION_PLANT, iTempData)
	formatex(szInfo, sizeof szInfo - 1, "[BombPlt]%d", iTempData)
	write_file(szRankFile, szInfo, LINE_BOMB_PLANT)
	
	TrieGetCell(iPlayerRankInfo[id], SECTION_DEFUSE, iTempData)
	formatex(szInfo, sizeof szInfo - 1, "[BombDfs]%d", iTempData)
	write_file(szRankFile, szInfo, LINE_BOMB_DEFUSE)
	
	
	
	//		RANK INFORMATION OF LAST ROUND
	
	TrieGetCell(iPlayerRankInfo[id], SECTION_TEMP_KILL, iTempData)
	formatex(szInfo, sizeof szInfo - 1, "[TotalKill]%d", iTempData)
	write_file(szRankFile, szInfo, LINE_LR_TOTAL_KILL)
	
	TrieGetCell(iPlayerRankInfo[id], SECTION_TEMP_HEADSHOT, iTempData)
	formatex(szInfo, sizeof szInfo - 1, "[Headshot]%d", iTempData)
	write_file(szRankFile, szInfo, LINE_LR_HEADSHOT)
	
	TrieGetCell(iPlayerRankInfo[id], SECTION_TEMP_KNIFE, iTempData)
	formatex(szInfo, sizeof szInfo - 1, "[KnifeKill]%d", iTempData)
	write_file(szRankFile, szInfo, LINE_LR_KNIFE_KILL)
	
	TrieGetCell(iPlayerRankInfo[id], SECTION_TEMP_GRENADE, iTempData)
	formatex(szInfo, sizeof szInfo - 1, "[GrenadeKill]%d", iTempData)
	write_file(szRankFile, szInfo, LINE_LR_GRENADE_KILL)
	
	TrieGetCell(iPlayerRankInfo[id], SECTION_TEMP_DEATH, iTempData)
	formatex(szInfo, sizeof szInfo - 1, "[Death]%d", iTempData)
	write_file(szRankFile, szInfo, LINE_LR_DEATH)
	
	TrieGetCell(iPlayerRankInfo[id], SECTION_TEMP_PLANT, iTempData)
	formatex(szInfo, sizeof szInfo - 1, "[BombPlt]%d", iTempData)
	write_file(szRankFile, szInfo, LINE_LR_BOMB_PLANT)
	
	TrieGetCell(iPlayerRankInfo[id], SECTION_TEMP_DEFUSE, iTempData)
	formatex(szInfo, sizeof szInfo - 1, "[BombDfs]%d", iTempData)
	write_file(szRankFile, szInfo, LINE_LR_BOMB_DEFUSE)
}


stock is_valid_player(id)
{
	if (!(1<= id < MAX_PLAYER))
		return 0
		
	return 1
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/