/* G4U DEATH MATCH MODE */

#if defined _death_match_included
  #endinput
#endif
#define _death_match_included

enum
{
	CS_DM_FY = 1,
	CS_DM_DE,
	CS_DM_CS,
	CS_DM_NORMAL,
	CS_DM_AS
}

enum
{
	CS_DM_KNIFE = 1,
	CS_DM_PISTOL,
	CS_DM_SNIPER,
	CS_DM_FULL
}

/*		Retrieve the current Game Play : Contact to CS_DM_FY, CS_DM_DE, ...		*/
native DM_get_game_mode()

/*		What weapon can be used		*/
native DM_get_weapon_mode()

/*		Retrieve CT score			*/
native DM_get_CT_score()

/*		Retrieve T score			*/
native DM_get_T_score()

/*		Retrieve Round Limitation		*/
native DM_get_max_round()

/*		Retrieve Round Time (Minute)		*/
native Float:DM_get_round_time()



/*				FORWARD				*/

/*	Called when round ended	*/
forward DM_RoundEnd(iTeamWin)

/*	Called when game is exiting	*/
forward DM_RoundExit(iTeamWin)
