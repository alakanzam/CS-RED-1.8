/* NO COMMENTS */

#if defined _ArmouryManager_included
  #endinput
#endif
#define _ArmouryManager_included

#include <fakemeta>

#define pev_ArmouryId	pev_iuser1
#define pev_ArmouryType	pev_iuser2
#define pev_ArmouryStatus	pev_iuser3
#define pev_ArmouryPoint	pev_iuser4

enum
{
	ARMOURY_DEFAULT = 100,
	ARMOURY_SECONDARY,
	ARMOURY_PRIMARY,
	ARMOURY_MELEE,
	ARMOURY_GRENADE,
	ARMOURY_ARMOR,
	ARMOURY_SUPPLY
}
	
enum
{
	ARMOURY_DISABLED,
	ARMOURY_ENABLED
}

stock csred_SetArmouryStatus(iEnt, iStatus)
{
	if (iStatus == ARMOURY_DISABLED)
	{
		set_pev(iEnt, pev_ArmouryStatus, ARMOURY_DISABLED)
		set_pev(iEnt, pev_effects,  EF_NODRAW)
		return
	}
	
	set_pev(iEnt, pev_ArmouryStatus, ARMOURY_ENABLED)
	set_pev(iEnt, pev_effects, pev(iEnt, pev_effects) &~ EF_NODRAW)	
}


