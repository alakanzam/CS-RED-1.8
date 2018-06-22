/* NO COMMENTS */

#if defined _SurvivorMode_included
  #endinput
#endif
#define _SurvivorMode_included


/*	Get percentage of damage plus	*/
native SM_get_damage_plus()

/*	Check if player is Survivor	*/
native SM_is_user_survivor(id)


/*	Called when a player become survivor	*/
forward SM_PlayerBecomeSurvivor(id)

/*	Called when damage plus is updated	*/
forward SM_UpgradeDamage(iDamagePlus)