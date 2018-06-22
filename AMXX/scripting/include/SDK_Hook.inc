/* -[NO COMMENTS]- */

#if defined _SDK_Hook_included
  #endinput
#endif
#define _SDK_Hook_included

/*	Called at HLTV event	*/
forward RoundEvent_PreBegin()

/*	Called at Round Begin	*/
forward RoundEvent_Begin()

/*	Called when round restarts	*/
forward RoundEvent_Restart()

/*	Called when Terrorists Win	*/
forward RoundEvent_TerWin()

/*	Called when Counter-Terrorists Win	*/
forward RoundEvent_CtWin()