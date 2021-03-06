/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fakemeta>

#include <mmcl_util>
#include <player_api>
#include <celltrie>


#include <GamePlay_Included/Tools.inc>

/*		MINI GAMEPLAY OF ZOMBIE MOD		*/
#include <GamePlay_Included/SurvivorMode.inc>
#include <GamePlay_Included/ZombieMod3.inc>


/********************************************************/

#define PLUGIN "[ZM] HUD ICON"
#define VERSION "-[No Info]-"
#define AUTHOR "Nguyen Duy Linh"


#define HUD_DISPLAY_TIME -1.0


new Trie:iHudPosition[33]

/*		TRIE KEY		*/

//	[HUD] Damage plus
#define KEY_DAMAGE_PLUS_X	"DAMAGE_PLUS_X"
#define KEY_DAMAGE_PLUS_Y	"DAMAGE_PLUS_Y"

#define KEY_DAMAGE_PLUS_X_TGA	"DAMAGE_PLUS_X_TGA"
#define KEY_DAMAGE_PLUS_Y_TGA	"DAMAGE_PLUS_Y_TGA"

//	[HUD] Evolution Ladder

#define KEY_EVOLUTION_X		"EVOLUTION_X"
#define KEY_EVOLUTION_Y		"EVOLUTION_Y"

#define KEY_EVOLUTION_X_TGA	"EVOLUTION_X_TGA"
#define KEY_EVOLUTION_Y_TGA	"EVOLUTION_Y_TGA"

new iZM_Toggle


#define TGA_DIR "mh_tga"

#define TASK_DRAW_HUD	5000


public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	
	iZM_Toggle = is_zombie_on()
	
	if (!iZM_Toggle)
	{
		set_fail_state("TURN OFF BECAUSE ZOMBIE MOD OFF")
		return
	}
		
		
	new iZM_Toggle = zp_get_current_gameplay()
	
	switch (iZM_Toggle)
	{
		case ZB_GAMEPLAY_SURVIVOR:
		{
			register_concmd("ZM_HUD/SPR/DamagePlus_X", "fw_DamagePlus_X")
			register_concmd("ZM_HUD/SPR/DamagePlus_Y", "fw_DamagePlus_Y")
			register_concmd("ZM_HUD/TGA/DamagePlus_X", "fw_DamagePlus_X_TGA")
			register_concmd("ZM_HUD/TGA/DamagePlus_Y", "fw_DamagePlus_Y_TGA")
		}
		case ZB_GAMEPLAY_ZM3:
		{
			register_concmd("ZM_HUD/SPR/DamagePlus_X", "fw_DamagePlus_X")
			register_concmd("ZM_HUD/SPR/DamagePlus_Y", "fw_DamagePlus_Y")
			register_concmd("ZM_HUD/TGA/DamagePlus_X", "fw_DamagePlus_X_TGA")
			register_concmd("ZM_HUD/TGA/DamagePlus_Y", "fw_DamagePlus_Y_TGA")
			
			register_concmd("ZM_HUD/SPR/Evolution_X", "fw_Evolution_X")
			register_concmd("ZM_HUD/SPR/Evolution_Y", "fw_Evolution_Y")
			register_concmd("ZM_HUD/TGA/Evolution_X", "fw_Evolution_X_TGA")
			register_concmd("ZM_HUD/TGA/Evolution_Y", "fw_Evolution_Y_TGA")
		}
	}
	
	
	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawnPost", 1)
}

public client_putinserver(id)
{
	if (is_user_bot(id))
	{
		if (iHudPosition[id])
			TrieDestroy(iHudPosition[id])
			
		return
	}
	
	
	if (!iHudPosition[id])
		iHudPosition[id] = TrieCreate()
}

public client_disconnect(id)
{
	if (!iHudPosition[id])
		return
		
	TrieDestroy(iHudPosition[id])
}




/*		CONSOLE COMMAND		*/

/*		PERCENTAGE OF DAMAGE PLUS		*/

public fw_DamagePlus_X(id, iLevel, iCid)
{
	if (!is_user_connected(id))
		return
		
	if (is_user_bot(id))
		return
		
	if (!cmd_access(id, iLevel, iCid, 2))
		return
		
	new szArg[10]
	read_argv(1, szArg, sizeof szArg - 1)
	
	if (!iHudPosition[id])
		iHudPosition[id] = TrieCreate()
		
	TrieSetString(iHudPosition[id], KEY_DAMAGE_PLUS_X, szArg)
}
 
public fw_DamagePlus_Y(id, iLevel, iCid)
{
	if (!is_user_connected(id))
		return
		
	if (is_user_bot(id))
		return
		
	if (!cmd_access(id, iLevel, iCid, 2))
		return
		
	new szArg[10]
	read_argv(1, szArg, sizeof szArg - 1)
	
	if (!iHudPosition[id])
		iHudPosition[id] = TrieCreate()
		
	TrieSetString(iHudPosition[id], KEY_DAMAGE_PLUS_Y, szArg)
}




public fw_DamagePlus_X_TGA(id, iLevel, iCid)
{
	if (!is_user_connected(id))
		return
		
	if (is_user_bot(id))
		return
		
	if (!cmd_access(id, iLevel, iCid, 2))
		return
		
	new szArg[10]
	read_argv(1, szArg, sizeof szArg - 1)
	
	if (!iHudPosition[id])
		iHudPosition[id] = TrieCreate()
		
	TrieSetString(iHudPosition[id], KEY_DAMAGE_PLUS_X_TGA, szArg)
}

public fw_DamagePlus_Y_TGA(id, iLevel, iCid)
{
	if (!is_user_connected(id))
		return
		
	if (is_user_bot(id))
		return
		
	if (!cmd_access(id, iLevel, iCid, 2))
		return
		
	new szArg[10]
	read_argv(1, szArg, sizeof szArg - 1)
	
	if (!iHudPosition[id])
		iHudPosition[id] = TrieCreate()
		
	TrieSetString(iHudPosition[id], KEY_DAMAGE_PLUS_Y_TGA, szArg)
}

/********************************************************/

/*		    EVOLUTION LADDER			*/

public fw_Evolution_X(id, iLevel, iCid)
{
	if (!is_user_connected(id))
		return
		
	if (is_user_bot(id))
		return
		
	if (!cmd_access(id, iLevel, iCid, 2))
		return
		
	new szArg[10]
	read_argv(1, szArg, sizeof szArg - 1)
	
	if (!iHudPosition[id])
		iHudPosition[id] = TrieCreate()
		
	TrieSetString(iHudPosition[id], KEY_EVOLUTION_X, szArg)
}

public fw_Evolution_Y(id, iLevel, iCid)
{
	if (!is_user_connected(id))
		return
		
	if (is_user_bot(id))
		return
		
	if (!cmd_access(id, iLevel, iCid, 2))
		return
		
	new szArg[10]
	read_argv(1, szArg, sizeof szArg - 1)
	
	if (!iHudPosition[id])
		iHudPosition[id] = TrieCreate()
		
	TrieSetString(iHudPosition[id], KEY_EVOLUTION_Y, szArg)
}


public fw_Evolution_X_TGA(id, iLevel, iCid)
{
	if (!is_user_connected(id))
		return
		
	if (is_user_bot(id))
		return
		
	if (!cmd_access(id, iLevel, iCid, 2))
		return
		
	new szArg[10]
	read_argv(1, szArg, sizeof szArg - 1)
	
	if (!iHudPosition[id])
		iHudPosition[id] = TrieCreate()
		
	TrieSetString(iHudPosition[id], KEY_EVOLUTION_X_TGA, szArg)
}

public fw_Evolution_Y_TGA(id, iLevel, iCid)
{
	if (!is_user_connected(id))
		return
		
	if (is_user_bot(id))
		return
		
	if (!cmd_access(id, iLevel, iCid, 2))
		return
		
	new szArg[10]
	read_argv(1, szArg, sizeof szArg - 1)
	
	if (!iHudPosition[id])
		iHudPosition[id] = TrieCreate()
		
	TrieSetString(iHudPosition[id], KEY_EVOLUTION_Y_TGA, szArg)
}

/********************************************************/
/*			FORWARDS			*/

public SM_UpgradeDamage(iDamagePlus)
{
	
	new iPlayers[32], iNumber
	
	get_players(iPlayers, iNumber, "ae", "CT")
	
	for (new i = 0; i < iNumber; i++)
	{
		new id = iPlayers[i]
		
		if (task_exists(id + TASK_DRAW_HUD))
			return
			
		set_task(1.5, "TASK_DrawHud", id + TASK_DRAW_HUD)
	}
}

public ZM3_DamageUpdated(iDamagePlus)
{
	new iPlayers[32], iNumber
	
	get_players(iPlayers, iNumber, "ae", "CT")
	
	for (new i = 0; i < iNumber; i++)
	{
		new id = iPlayers[i]
		
		if (task_exists(id + TASK_DRAW_HUD))
			return
			
		set_task(1.5, "TASK_DrawHud", id + TASK_DRAW_HUD)
	}
}

public ZM3_EvolutionUpdated(id, iStage)
{
	if (!get_user_zombie(id))
		return
		
	draw_zombie_evolution(id, 0)
}

public TFM_become_zombie_post(iVictim, iClassId, iUpdateClass, iUpdateUserInfo, iNotification)
{
	if (!is_user_connected(iVictim))
		return
	
	if (is_user_bot(iVictim))
		return
		
	if (!MMCL_IsClientUsingMMCL(iVictim))
		return
		
	MMCL_RemoveImage(iVictim, HUDTYPE_TGA, CHANNEL_DMG_BONUS_TGA)
	MMCL_RemoveImage(iVictim, HUDTYPE_SPR, CHANNEL_DMG_BONUS)
	
	draw_zombie_evolution(iVictim, 0)
}
/********************************************************/
/*			HAMSANDWICH			*/

public fw_PlayerSpawnPost(id)
{
	if (is_user_bot(id))
		return
		
	if (!iZM_Toggle)
		return
			
	if (task_exists(id + TASK_DRAW_HUD))
		return
		
	set_task(1.5, "TASK_DrawHud", id + TASK_DRAW_HUD)
	
}


public csred_PlayerKilledPost(iVictim, iKiller)
{
	if (!is_user_connected(iVictim))
		return
		
	if (!MMCL_IsClientUsingMMCL(iVictim))
		return
		
	MMCL_RemoveImage(iVictim, HUDTYPE_TGA, CHANNEL_DMG_BONUS_TGA)
	MMCL_RemoveImage(iVictim, HUDTYPE_SPR, CHANNEL_DMG_BONUS)
}

/********************************************************/


public TASK_DrawHud(TASKID)
{
	new id = TASKID - TASK_DRAW_HUD
	
	if (is_user_bot(id))
		return
		
	if (!iZM_Toggle)
		return
	
	new iGamePlay = zp_get_current_gameplay()
	
	switch (iGamePlay)
	{
		case ZB_GAMEPLAY_SURVIVOR:
			draw_damage_plus_hud(id, SM_get_damage_plus())
		case ZB_GAMEPLAY_ZM3:
		{
			draw_damage_plus_hud(id, ZM3_get_damage_plus())
			
			if (!get_user_zombie(id))
				draw_zombie_evolution(id, 1)
			else	draw_zombie_evolution(id, 0)
		}
	}
}


/*********************************************************/

/*	 	 Draw Damage Plus Hud			*/

stock draw_damage_plus_hud(id, iPercentage)
{
	if (!is_user_connected(id))
		return
		
	if (is_user_bot(id))
		return
	
	new iGamePlay = zp_get_current_gameplay()
	
	if (iGamePlay != ZB_GAMEPLAY_ZM3 && iGamePlay != ZB_GAMEPLAY_SURVIVOR)
		return
		
	if (!MMCL_IsClientUsingMMCL(id))
		return
	
	if (get_user_zombie(id))
	{
		MMCL_RemoveImage(id, HUDTYPE_TGA, CHANNEL_DMG_BONUS_TGA)
		MMCL_RemoveImage(id, HUDTYPE_SPR, CHANNEL_DMG_BONUS)
		return
	}
	
	new PREFIX[] = "DAMAGE_PLUS"
	
	
	
	new szSPR[128]
	
	new iMhType = MMCL_get_user_hud_mode(id)
	
	new Float:HUD_POS_X
	new Float:HUD_POS_Y
	
	
	if (iMhType == 2)
	{
		
		get_float_from_key(id, KEY_DAMAGE_PLUS_X_TGA, HUD_POS_X)
		get_float_from_key(id, KEY_DAMAGE_PLUS_Y_TGA, HUD_POS_Y)
		
		formatex(szSPR, sizeof szSPR - 1, "%s/%s_%d.tga", TGA_DIR, PREFIX, iPercentage)
		
		if (!file_exists(szSPR))		
			return
		
		formatex(szSPR, sizeof szSPR - 1, "%s_%d.tga", PREFIX, iPercentage)
		
		MMCL_DrawTargaImage(id, szSPR, 0, 255, 255, 255, HUD_POS_X, HUD_POS_Y, 0, CHANNEL_DMG_BONUS_TGA, HUD_DISPLAY_TIME)
	
	}
	else
	{
		get_float_from_key(id, KEY_DAMAGE_PLUS_X, HUD_POS_X)
		get_float_from_key(id, KEY_DAMAGE_PLUS_Y, HUD_POS_Y)
		
		formatex(szSPR, sizeof szSPR - 1, "sprites/%s/%s_%d.spr", PREFIX, PREFIX, iPercentage)
		
		if (!file_exists(szSPR))
			return
		
		formatex(szSPR, sizeof szSPR - 1, "%s/%s_%d", PREFIX, PREFIX, iPercentage)
		
		MMCL_DrawHolesImage(id, 0, 1,  szSPR, HUD_POS_X, HUD_POS_Y, 255, 255, 255, 0, HUD_DISPLAY_TIME, CHANNEL_DMG_BONUS, 1)
	}
	
}


stock draw_zombie_evolution(id , iRemove = 0)
{
	if (!is_user_connected(id))
		return
		
	if (is_user_bot(id))
		return
	
	if (!MMCL_IsClientUsingMMCL(id))
		return
		
		
	if (!is_user_alive(id) || iRemove)
	{
		MMCL_RemoveImage(id, HUDTYPE_SPR, CHANNEL_EVOLUTION_SPR)
		MMCL_RemoveImage(id, HUDTYPE_TGA, CHANNEL_EVOLUTION_TGA)
		return
	}
		
	new iMetaType = MMCL_get_user_hud_mode(id)
		
	new iGamePlay = zp_get_current_gameplay()
	
	
	if (iGamePlay == ZB_GAMEPLAY_ZM3)
	{
		new iEvolutionLevel = ZM3_get_evolution_stage(id)
		
		new szSPR[128]
		
		new Float:fX, Float:fY
		
		if (iMetaType == 2)
		{
			get_float_from_key(id, KEY_EVOLUTION_X_TGA, fX)
			get_float_from_key(id, KEY_EVOLUTION_Y_TGA, fY)
			
			formatex(szSPR, sizeof szSPR - 1, "%s/EVOLUTION_%d.tga", TGA_DIR, iEvolutionLevel)
			
			if (!file_exists(szSPR))
				return
				
			formatex(szSPR, sizeof szSPR - 1, "EVOLUTION_%d", iEvolutionLevel)
			
			MMCL_DrawTargaImage(id, szSPR, 1, 255, 255 ,255, fX, fY, 0, CHANNEL_EVOLUTION_TGA, HUD_DISPLAY_TIME)
		}
		else
		{
			
			get_float_from_key(id, KEY_EVOLUTION_X, fX)
			get_float_from_key(id, KEY_EVOLUTION_Y, fY)
			
			formatex(szSPR, sizeof szSPR - 1, "sprites/EVOLUTION/EVOLUTION_%d.spr", iEvolutionLevel)
				
			if (!file_exists(szSPR))
				return
				
			formatex(szSPR, sizeof szSPR - 1, "EVOLUTION/EVOLUTION_%d", iEvolutionLevel)
				
			MMCL_DrawHolesImage(id, 0, 0, szSPR, fX, fY, 255, 255, 255 , 0, HUD_DISPLAY_TIME, CHANNEL_EVOLUTION_SPR, 5)
			
		}
		
	}	
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
