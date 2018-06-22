/* NO COMMENTS */

#if defined _RandomRespawn_included
  #endinput
#endif
#define _RandomRespawn_included

enum
{
	SPAWN_TYPE_REGULAR,
	SPAWN_TYPE_CSDM
}

native csred_DoRandomSpawn(id, iCSDM_SpawnType)

native csred_CSDM_SpawnNumber()
native csred_Regular_SpawnNumber()
