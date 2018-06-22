/* NO COMMENTS */

#if defined _Manager_included
  #endinput
#endif
#define _Manager_included


/*	Retrieve Id of Game-Play which is running at the moment */
native get_current_gameplay()

/*	Register Id of current Game-Play	*/
native register_gameplay_id(iGamePlayId)

/*	Called when plugin already read the Game-Play configuration file	*/
forward GamePlay_Initilizing(iCurrentGamePlay)