
#if defined _WM_DefaultArmoury_included
  #endinput
#endif
#define _WM_DefaultArmoury_included

/*		Spawns a default Armoury Entity			*/
native DFWM_set_armoury_spawn(iPoint, iArmouryId = -1, Float:fOrigin[3])

/*		Called when default Armoury is picked up		*/
forward DFWM_ArmouryPickedUp(id, iEnt)

/*		Called when an Armoury is being created		*/
forward DFWM_ArmouryCreating(iArmouryId)

/*		Called when plugin checks if player can use Armoury Weapon		*/
forward DFWM_CanUserUseArmoury(id, iArmouryId)

/*		Called when armoury set model			*/
forward DFWM_ArmourySetModel(iEnt, iWeaponId, szWorldModel[])