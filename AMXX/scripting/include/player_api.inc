/* Core functions
*
* (c) Copyright 1998-2003, ITB CompuPhase
*
* This file is provided as is (no warranties).
*/

#if defined _player_api_included
  #endinput
#endif
#define _player_api_included

#define STATION_USING 2
#define STATION_STOPPED 0

forward csred_PlayerSpawnPre(id)
forward csred_PlayerSpawnPost(id)

forward csred_PlayerKilledPre(iVictim, iKiller)
forward csred_PlayerKilledPost(iVictim, iKiller)

forward csred_PlayerUseStationPre(iEnt, iCaller, iActivator, iUSE_TYPE)
forward csred_PlayerUseStationPost(iEnt, iCaller, iActivator, iUSE_TYPE)

forward csred_PlayerStripWeapons(id)

forward csred_ResetHud(id)

native UT_RemoveDeathFrag(id, iEngineMessage)
native UT_UpdateScoreBoard(id ,iFrags, iDeaths, iEngineMessage)

native UT_SetPlayerFOV(id, iFOV)
native UT_GetPlayerFOV(id)

native UT_IsUsingStationaryWeapon(id)
native UT_SetUserNVG_State(id, iToggle, iEngineMSG)
native UT_GetUserNVG_State(id)

native UT_RadarFakeHostagePos(id, iHostageID, iOrigin[3], iEngineMessage)
native UT_RadarFakeHostageKilled(id, iHostageID, iEngineMessage)
native UT_RespawnPlayer(id)
native UT_GetUserInternalModel(id)
native UT_SetUserInternalModel(id, iInternalModel)
native UT_IsUserFlashed(id)

/*	UPDATE TEAM	*/
/*
0 - UNASSIGNED
1 - TERRORIST
2 - CT
3 - SPECTATOR
*/

native UT_UpdatePlayerTeam(id, iTeam, iEngineMessage)


native UT_GetSpecPlayer(id)
native UT_IsFirstPersonSpec(id)