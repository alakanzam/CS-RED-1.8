/*================================================================================
	
	
=================================================================================*/

#if defined _csred_GhostMode_included
  #endinput
#endif
#define _csred_GhostMode_included

/*			Check if Ghost is on / off			*/
native GM_get_game_state()

/*			Highest score team has to reach to win			*/
native GM_get_max_score()

/*			Retrieve Score of a Team			*/
native GM_get_team_score(iTeamId)

/*			Check if player is a Ghost			*/
native GM_is_user_ghost(id)

/*			Retrieve Round time (minute)			*/
native Float:GM_get_roundtime()




/*				FORWARD			*/

/*	Called when Round / Game ends		*/
forward GMFW_round_result(iTeamId)
