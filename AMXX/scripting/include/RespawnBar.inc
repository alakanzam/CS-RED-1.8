/* G4U NVG */

#if defined _RespawnBar_included
  #endinput
#endif
#define _RespawnBar_included

native _DrawRespawnNumber(id, iToggle, iTime, iDefault = 0)
native _DrawRespawnBg(id, iToggle, Float:fTime)
native _MakeRespawnTask(id, Float:fTime, iDefaultTime = 1)
native _RemoveRespawnTask(id)
native _ModifyTimeRespawn(id, Float:fTime)
native _ModifyDrawingNumber(id, iTime)

forward Respawn_DrawingNumber( id, iToggle, iTime, iDefault)
forward Respawn_MakingTask(id, Float:fTime, iDefault)