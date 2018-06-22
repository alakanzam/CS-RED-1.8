#if defined _GamePlay_TDM_included
  #endinput
#endif
#define _GamePlay_TDM_included

enum
{
	TMD_MODE_NONE,
	TDM_MODE_NORMAL
}

/*	Gets gameplay state	*/
native TDM_get_game_state()

/*	Retrieve gameplay weapon mode	*/
native TDM_get_weapon_mode()

/*	Retrieve score of Terrorist team	*/
native TDM_get_score_terrorist()

/*	Retrieve score of Counter Terrorist team	*/
native TDM_get_score_ct()

/*	Retrieve the score that team has to reach to win	*/
native TDM_get_round_score()

/*	Return the minutes of Team Death Match round	*/
native Float:TDM_get_round_time()


/*	Called when Team Death Match ends	*/
forward TDM_game_over(iWinTeam)

/*	Called when Team Death Match starts	*/
forward TDM_game_start()