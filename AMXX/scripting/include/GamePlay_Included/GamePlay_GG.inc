/* CS RED GUNGAME
*/

#if defined _GamePlay_GG_included
  #endinput
#endif
#define _GamePlay_GG_included


native GG_GameModeToggle()
native GG_GetPlayerLevel(id)
native GG_FFA_ON()
native GG_GetPlayerKills(id)
native GG_GetPlayerKillReq(id)
native GG_MakePlayerRespawn(id, Float:fTime)
native Float:GG_GetRoundTime()
native GG_GetMaxLevel()

forward GunGame_PlayerSpawn(id)
forward GunGame_PlayerLevelUp(id, iLevel)
forward GunGame_GameExit(iWinner)
forward GunGame_PlayerRespawing(id, Float:fTime)