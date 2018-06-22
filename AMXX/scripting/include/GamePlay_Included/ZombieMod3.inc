
#if defined _ZombieMod3_included
  #endinput
#endif
#define _ZombieMod3_included

/*	Get Damage Plus	*/
native ZM3_get_damage_plus()

/*	Check if player is a Hero	*/
native ZM3_is_user_hero(id)

/*	Retrieve evolution stage		*/
native ZM3_get_evolution_stage(id)





/*			FORWARD		*/

/*	Called when a player become Hero		*/
forward ZM3_PlayerBecomeHero(id)

/*	Called when damage plus is updated	*/
forward ZM3_DamageUpdated(iPercentage)

/*	Called when evolution is updated		*/
forward ZM3_EvolutionUpdated(id, iStage)