/* NO COMMENT */

#if defined _escape_mod_included
  #endinput
#endif
#define _escape_mod_included

/* NATIVE */

/*		Check if Game-Play : Escape is running or not		*/
native EM_GetGameState()

/*		Retrieve Score of Escaping Team			*/
native EM_GetEscapeTeamScore()

/*		How many time does the Escaping Team have to do to win			*/
native EM_GetMaxEscape()

/*		How many minutes per round			*/
native Float:EM_GetRoundTime()

/*		Force player reach Escape Zone			*/
native EM_UserReachEsZone(id)



/* FORWARDS */

/*	Called when player prepare to Escape		*/
forward ES_UserEscapePre(id)
forward ES_UserEscapePost(id)

/*	Called when Round prepares to exit		*/
forward ES_RoundEnd(iTeamWin)

