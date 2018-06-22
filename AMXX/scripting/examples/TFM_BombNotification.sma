/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <mmcl_util>
#include <csx>
#include <GamePlay_Included/Tools.inc>
#include <celltrie>

#define PLUGIN "[EF] Bomb Notification"
#define VERSION "1.0"
#define AUTHOR "Nguyen Duy Linh"


#define TASK_BOMB_HUD_DISPLAY	2000
#define TASK_REACTIVE_TIME	1.0

#define TGA_BOMB_HUD "TFM_TGA/NOTIFY_BOMB.tga"

#define PREFIX_HUD_X	"HUD_X_"
#define PREFIX_HUD_Y	"HUD_Y_"

#define INFO_PLANTED_TIME	"PLANTED_TIME"
#define INFO_EXPLOSION_TIME	"EXPLOSION_TIME"

new Trie:iHudInformation





new iBombPlanted
new iMaxPlayers

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	new iWeaponMode, iIsFightYard, iGamePlay
	
	iGamePlay = is_deathmatch_on(iWeaponMode, iIsFightYard)
	if (!iGamePlay)
	{
		set_fail_state("Game-Play : Death Match is off")
		return
	}
	
	if (iGamePlay != CS_DM_DE)
	{
		set_fail_state("Game-Play : Death Match [Bomb Defuse] is off")
		return
	}
	
	if (!iHudInformation)
		iHudInformation = TrieCreate()
		
	register_concmd("TFM_HUD/BOMB_X", "TGA_HUD_X")
	register_concmd("TFM_HUD/BOMB_Y", "TGA_HUD_Y")
	
	
	register_logevent("logevent_RoundEnd", 2, "1=Round_End", "1=Round_Draw")
	
}

public plugin_cfg()
	iMaxPlayers = get_maxplayers()
	
public TGA_HUD_X(id, level, cid)
{
	if (!is_user_connected(id))
		return
		
	if (is_user_bot(id))
		return
		
	if (!cmd_access(id, level, cid, 2))
		return
		
	if (!iHudInformation)
		return
		
	new szArg[10]
	read_argv(1, szArg, sizeof szArg - 1)
	
	new szKey[128]
	formatex(szKey, sizeof szKey - 1, "%s_%d", PREFIX_HUD_X, id)
	TrieSetCell(iHudInformation, szKey, str_to_float(szArg))
}

public TGA_HUD_Y(id, level, cid)
{
	if (!is_user_connected(id))
		return
		
	if (is_user_bot(id))
		return
		
	if (!cmd_access(id, level, cid, 2))
		return
		
	if (!iHudInformation)
		return
		
	new szArg[10]
	read_argv(1, szArg, sizeof szArg - 1)
	
	new szKey[128]
	formatex(szKey, sizeof szKey - 1, "%s_%d", PREFIX_HUD_Y, id)
	TrieSetCell(iHudInformation, szKey, str_to_float(szArg))
}


public client_disconnect(id)
{
	remove_task(id + TASK_BOMB_HUD_DISPLAY)
	
	if (is_user_bot(id))
		return
		
	new szKey[128]
	
	formatex(szKey, sizeof szKey - 1, "%s_%d", PREFIX_HUD_X, id)
	TrieDeleteKey(iHudInformation, szKey)
	
	formatex(szKey, sizeof szKey - 1, "%s_%d", PREFIX_HUD_Y, id)
	TrieDeleteKey(iHudInformation, szKey)
}

public bomb_defused(iDefuser)
{

	for (new id = 1; id <= iMaxPlayers; id++)
	{
		if (!is_user_connected(id))
			continue
			
		if (is_user_bot(id))
			continue
			
		remove_task(id + TASK_BOMB_HUD_DISPLAY)	
	}
	
	if (iBombPlanted)
		iBombPlanted = 0
}

public bomb_explode(iPlanter, iDefuser)
{
	for (new id = 1; id <= iMaxPlayers; id++)
	{
		if (!is_user_connected(id))
			continue
			
		if (is_user_bot(id))
			continue
			
		remove_task(id + TASK_BOMB_HUD_DISPLAY)
	}
	
	if (iBombPlanted)
		iBombPlanted = 0
}

public bomb_planted(iPlanter)
{
	
	if (!iHudInformation)
		return
		

	TrieSetCell(iHudInformation, INFO_PLANTED_TIME, get_gametime())
	TrieSetCell(iHudInformation, INFO_EXPLOSION_TIME, get_cvar_float("mp_c4timer"))
	iBombPlanted = 1
	
	for (new id = 1; id <= iMaxPlayers ; id++)
	{	
		if (!is_user_connected(id))
			continue

		if (is_user_bot(id))
			continue
					
		if (task_exists(id + TASK_BOMB_HUD_DISPLAY))
			remove_task(id + TASK_BOMB_HUD_DISPLAY)
			
		set_task(TASK_REACTIVE_TIME, "NotifyTheBomb_TASK", id + TASK_BOMB_HUD_DISPLAY)
		
		
		
	}
	
}


public logevent_RoundEnd()
{
	if (!iBombPlanted)
		return
		
	new iPlayers[32], iNumber
	get_players(iPlayers, iNumber, "c")
		
	for (new i = 0; i < iNumber ; i++)
	{
		new id = iPlayers[i]
		
		if (!is_user_connected(id))
			continue
			
		if (is_user_bot(id))
			continue
				
		remove_task(id + TASK_BOMB_HUD_DISPLAY)
	}
}



public NotifyTheBomb_TASK(TASKID)
{
	new id = TASKID - TASK_BOMB_HUD_DISPLAY
	
	if (!is_user_connected(id))
		return
	
	if (is_user_bot(id))
		return
	
	if (!iBombPlanted)
		return
		
	if (!iHudInformation)
		return
	
	if (!file_exists(TGA_BOMB_HUD))
		return
		
	new Float:fCurrentTime = get_gametime()
	new Float:fBombPlantedTime = get_float_from_key(iHudInformation, INFO_PLANTED_TIME)
	new Float:fBombDetonationTime = get_float_from_key(iHudInformation, INFO_EXPLOSION_TIME)
	
	new iPercent = 100 - floatround(((fCurrentTime - fBombPlantedTime) / fBombDetonationTime) * 100)
	
	new szKey[128]
	
	formatex(szKey, sizeof szKey - 1, "%s_%d", PREFIX_HUD_X, id)
	new Float:fX = get_float_from_key(iHudInformation, szKey)
	
	formatex(szKey, sizeof szKey - 1, "%s_%d", PREFIX_HUD_Y, id)
	new Float:fY = get_float_from_key(iHudInformation, szKey)
	
	formatex(szKey, sizeof szKey - 1, TGA_BOMB_HUD)
	replace(szKey, sizeof szKey - 1, ".tga", "")
	
	if (0 <= iPercent <= 20)
		MMCL_DrawTGA(id, szKey, 255, 0, 0, 255, fX, fY, 1, 0, TASK_REACTIVE_TIME / 2, TASK_REACTIVE_TIME/ 2, 0.0,  CHANNEL_NOTIFY_BOMB_TGA)
	else if (20 < iPercent <= 40)
		MMCL_DrawTGA(id, szKey, 255, 127, 0, 255, fX, fY, 1, 0, TASK_REACTIVE_TIME / 2, TASK_REACTIVE_TIME/ 2, 0.0,  CHANNEL_NOTIFY_BOMB_TGA)
	else if (40 < iPercent <= 60)
		MMCL_DrawTGA(id, szKey, 255, 255, 0, 255, fX, fY, 1, 0, TASK_REACTIVE_TIME / 2, TASK_REACTIVE_TIME/ 2, 0.0,  CHANNEL_NOTIFY_BOMB_TGA)
	else if (60 < iPercent <= 80)
		MMCL_DrawTGA(id, szKey, 144, 248, 8, 255, fX, fY, 1, 0, TASK_REACTIVE_TIME / 2, TASK_REACTIVE_TIME/ 2, 0.0,  CHANNEL_NOTIFY_BOMB_TGA)
	else if (80 < iPercent)
		MMCL_DrawTGA(id, szKey, 0, 255, 0, 255, fX, fY, 1, 0, TASK_REACTIVE_TIME / 2, TASK_REACTIVE_TIME/ 2, 0.0,  CHANNEL_NOTIFY_BOMB_TGA)

	set_task(TASK_REACTIVE_TIME, "NotifyTheBomb_TASK", id + TASK_BOMB_HUD_DISPLAY)
		
}

stock Float:get_float_from_key(Trie:iTrieId, szKey[])
{
	if (!iTrieId)
		return 0.0
		
	new szArg[10]
	TrieGetString(iTrieId, szKey, szArg, sizeof szArg - 1)
	new Float:fOutput = str_to_float(szArg)
	return fOutput
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
