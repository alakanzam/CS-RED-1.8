/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <csx>


#include <RankManagement/TFM_LevelSystem.inc>

#include <GamePlay_Included/Tools.inc>

#include <csred_Ace>
#include <player_api>



#define PLUGIN "[CSRED] AWARD SYSTEM"
#define VERSION "1.0"
#define AUTHOR "Nguyen Duy Linh"




#define VIP_ASSASINATION_COIN	5
#define BOMB_DEFUSION_COIN	10
#define BOMB_PLANT_COIN		10
#define HOSTAGE_RESCUE_COIN	4

#define EXP_NORMAL	 3
#define EXP_KNIFE	7
#define EXP_GRENADE	8
#define EXP_HEADSHOT	5
#define EXP_DEFUSION	15
#define EXP_PLANT	15
#define EXP_ZOMBIE_KILL	50
#define EXP_HOSTAGE_RESCUE	30

#define GP_HEADSHOT	30
#define GP_NORMAL	20
#define GP_GRENADE	42
#define GP_KNIFE	50
#define GP_BOMB_DEFUSION	70
#define GP_BOMB_PLANT	70
#define GP_ZOMBIE_KILL	150

new iAwarded_EXP[33]

#define MAX_EXP	250



public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_logevent("Event_HostageRescued",3,"2=Rescued_A_Hostage")
	
	
}



// *************************** FORWARD OF CSX.INC ******************************

public client_death(iKiller, iVictim, iWPN_ID, iHitPlace, iTeamKilled)
{
	new szKillerName[32], szVictimName[32]
	
	get_user_name(iKiller, szKillerName, sizeof szKillerName - 1)
	get_user_name(iVictim, szVictimName, sizeof szVictimName - 1)
	
	if (!is_user_connected(iKiller))
		return
		
	if (!is_user_connected(iVictim))
		return
		
		
	new iCurrentGamePlay = get_current_gameplay()
	//	NOT IN ZOMBIE GAMEPLAY
	
	if (!iTeamKilled)
	{
			
		if (iHitPlace == HIT_HEAD)
		{
			iAwarded_EXP[iKiller] += EXP_HEADSHOT
			TFM_award_user_gp(iKiller, GP_HEADSHOT)
				
		}
		else
		{
			iAwarded_EXP[iKiller] += EXP_NORMAL
			TFM_award_user_gp(iKiller, GP_NORMAL)	
		}
			
		if (iWPN_ID == CSW_KNIFE)
		{
			iAwarded_EXP[iKiller] += EXP_KNIFE
			TFM_award_user_gp(iKiller, GP_KNIFE)
			
		}
		else if (iWPN_ID == CSW_HEGRENADE)
		{
			iAwarded_EXP[iKiller] += EXP_GRENADE
			TFM_award_user_gp(iKiller, GP_GRENADE)
		}
			
		if (cs_get_user_vip(iVictim))
			TFM_award_user_coin(iKiller, VIP_ASSASINATION_COIN)
	}
	else
	{
		
		if (iCurrentGamePlay == GAMEMODE_FFA)
		{
			client_death(iKiller, iVictim, iWPN_ID, iHitPlace, 0)
			return
		}
	}
	
	if (iCurrentGamePlay == GAMEMODE_ZM)
	{
		if (get_user_zombie(iVictim))
		{
			iAwarded_EXP[iKiller] += EXP_ZOMBIE_KILL
			TFM_award_user_gp(iKiller, GP_ZOMBIE_KILL)
		}
	}	
}

public bomb_defused(iDefuser)
{
	iAwarded_EXP[iDefuser] += EXP_DEFUSION
	TFM_award_user_coin(iDefuser, BOMB_DEFUSION_COIN)
	
}

public bomb_planted(iPlanter)
{
	iAwarded_EXP[iPlanter] += EXP_PLANT
	TFM_award_user_coin(iPlanter, BOMB_PLANT_COIN)
	
}

	
// *************************** END FORWARD OF CSX.INC ******************************	
	

	
// *************************** FUNCTION OF REGISTER EVENT ***************************

public Event_HostageRescued()
{
	new id = get_loguser_index()	
	TFM_award_user_coin(id, HOSTAGE_RESCUE_COIN)
	iAwarded_EXP[id] += EXP_HOSTAGE_RESCUE
}


// **********************************************************************************
	
	



// **************** EVENT ROUND END OF SOME GAMEPLAYS     *************


public TDM_game_over()
	csred_save_level_all_player()
	
public FFA_game_over()
	csred_save_level_all_player()
	
public csred_zm_exiting()
	csred_save_level_all_player()
	
public DM_RoundExit()
	csred_save_level_all_player()
	
public ES_RoundEnd(iTeamWin)
	csred_save_level_all_player()
	
public GunGame_GameExit(iWinner)
	csred_save_level_all_player()
	
// ************************************ SOME USEFULL STOCK **********************************


stock get_loguser_index() 
{
	new loguser[80], name[32]
	read_logargv(0, loguser, 79)
	parse_loguser(loguser, name, 31)
	
	return get_user_index(name)
}





stock csred_save_level_all_player()
{
	new iPlayers[32], iNumber
	
	get_players(iPlayers, iNumber)
	
	for (new i = 0; i < iNumber ; i++)
	{
		new id = iPlayers[i]
		
		new iBOT = is_user_bot(id)
		
		if (!is_user_connected(id))
			continue
			
		new szAccount[128]
		
		if (iBOT)
		{
			get_user_name(id, szAccount, sizeof szAccount - 1)
			
			TFM_award_user_point(id, iAwarded_EXP[id])
		}
		else	
		{
			new iPlayerLevel = TFM_get_user_level(id)
			
			if (iPlayerLevel < 0)
				iPlayerLevel = 0
				
			iPlayerLevel++
			
			if (iAwarded_EXP[id] > MAX_EXP * iPlayerLevel)
				iAwarded_EXP[id] = MAX_EXP * iPlayerLevel
				
			TFM_award_user_point(id, iAwarded_EXP[id])
			TFM_get_user_account(id, szAccount, sizeof szAccount - 1)
		}
		
		TFM_save_user_level(id, szAccount)
	}
}