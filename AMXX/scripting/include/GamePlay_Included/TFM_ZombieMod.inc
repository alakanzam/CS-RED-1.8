
#if defined _TFM_ZombieMod_included
  #endinput
#endif
#define _TFM_ZombieMod_included

enum
{
	ZB_GAMEPLAY_ZM1 = 1,
	ZB_GAMEPLAY_SURVIVOR,
	ZB_GAMEPLAY_ZM3,
	ZB_GAMEPLAY_NEMESIS,
	ZB_GAMEPLAY_UNITED_1,
	ZB_GAMEPLAY_ZM4
}
enum
{
	ROUND_BEGIN,
	ROUND_END
}

enum
{
	ZB_GENDER_MALE,
	ZB_GENDER_FEMALE
}
/*	Set score to a specific team	*/
native zp_set_score(iTeamId, iScore)

/*	Register a game play	*/
native zp_register_gameplay(iGamePlayGlobalId, szGamePlayName[], szMapPrefix[], iPrefixLen)

/*	Set round state - End or Begin	*/
native zp_set_round_state(iState)

/*	Set Round Time	*/
native zp_set_round_time(Float:fTime)

/*	Register a Zombie Class	*/
native create_zombie_class(szClassName[])



/*	Get score of a specific Team	*/
native zp_get_score(iTeamId)

/*	Check if Zombie Mod is on or off	*/
native zp_is_mode_on()

/*	Retrieve Id of current Zombie Game play	*/
native zp_get_current_gameplay()

/*	Retrieve state of round	*/
native zp_get_round_state()

/*	Force game exit 	*/
native zp_force_game_exit(iTeamWin)

/*	Retrieve number of Zombie Classes	*/
native get_class_number()

/*	Set round max score	*/
native zp_set_max_score(iScore)






/*	The model of a Zombie Class	*/
native set_class_model(iClassId, szModel[])

/*	Claw model of a Zombie Class	*/
native set_class_hand(iClassId, szModel[])

native set_class_hud(iClassId, szHudKill[], szHpHud[])

native set_class_health(iClassId, iHealth)

native set_class_gravity(iClassId, Float:fGravity)

native set_class_speed(iClassId, Float:fSpeed)

native set_class_damage(iClassId, Float:fDamage)

native set_class_armor_dmg(iClassId, Float:fArmorDamage)

native set_class_dmg_reduce(iClassId, Float:fDamageReduce)

native set_class_sound(iClassId, szSoundDirectory[])

native set_class_price(iClassId, iCostType, iCost)

native set_class_knockback(iClassId, Float:fKnockBack)

/*	Set Class NVG	*/
native set_class_NVG(iClassId, iColor[3], iAlpha, iRadius)

/*	Which gender of this Zombie Class ? - Male or Female	*/
native set_class_gender(iClassId, iGender)

/*	How can we call the name of weapons which this Zombie Class use ? */
/*	Contact to CSW_	*/

native set_class_wpn_name(iClassId, iWeaponId, szName[])

/*	Set hud to a weapon of zombie	*/
native set_class_wpn_hud(iClassId, iWeaponId, szHud[])

/*	Which weapon can this Zombie Class use ? - Contact to CSW_	*/
native set_class_wpn(iClassId, iWeaponId, iUsable = 1)



/*	Retrieve the price of a Zombie Class	*/
native get_class_price(iClassId, &iCostType, &iCost)

/*	Retrieve speed of a Zombie Class	*/
native Float:get_class_speed(iClassId)

/*	Retrieve gravity of a Zombie Class	*/
native Float:get_class_gravity(iClassId)

/*	Retrieve Damage Proof of a Zombie Class	*/
native Float:get_class_dmg_reduce(iClassId)

/*	Retrieve name of a weapon of a Zombie Class	*/
/*	Contact to CSW_	*/
native get_class_wpn_name(iClassId, iWeaponId, szName[], iLen)

/*	Retrieve gender of a Zombie Class	*/
native get_class_gender(iClassId)

/*	Retrieve knock back of a Zombie Class	*/
native Float:get_class_kb(iClassId)

/*	Retrieve Hp of a Zombie Class	*/
native Float:get_class_health(iClassId)

/*	Retrieve Hud of Weapon	*/
native get_class_wpn_hud(iClassId, iWeaponId, szHud[], iLen)

/*	Retrieve HP HUD	*/
native get_class_hp_hud(iClassId, szHud[], iLen)

/*	Find Class Id of a Zombie by using player model	*/
native find_zombie_by_model(szModel[])

/*	Get round time	*/
native Float:zp_get_round_time()

/*	Get max score	*/
native zp_get_max_score()

/*	Set user to Zombie	*/
native set_user_zombie(id, iClassId, iUpdateClass, iUpdateUserInfo, iNotification)

/*	Check if player is a Zombie	*/
native get_user_zombie(id)

/*	Retrieve class id of a Zombie	*/
native get_user_zombie_class(id)

/*	Infect an user to Zombie	*/
native set_user_infected(iInfector, iVictim, iNotification = 1)


/*	Set count down task to an user	*/
native set_user_countdown(iPlayerId, iTotalTime, iCycle, iPlaySound, iState)

/*	Set User Class	*/
native set_user_class(id, iClassId)




/*	Do knock-back to a player		*/
native zp_do_knockback(iAttacker, iVictim, Float:fDamage, Float:fPower, Float:fEffectiveDistance, iTraceHandle)

/********************** FORWARD	*********************/

/*	Called when an user becomes a Zombie	*/
forward TFM_become_zombie_pre(id, iClassId, iUpdateClass, iUpdateUserInfo, iNotification)
forward TFM_become_zombie_post(id, iClassId, iUpdateClass, iUpdateUserInfo, iNotification)

/*	Called when an user is infected by anothers	*/
forward TFM_user_infected(iInfector, iVictim, iInfectionType)

/*	Scratches but the victim still has armor	*/
forward TFM_user_armor_damaged(iAttacker, iVictim)

/*	Called when plugin is ready to receive Game-Play information	*/
forward TFM_EnableRegisterGamePlay()

/*	Called when plugin is ready to receive Zombie Class Information	*/
forward TFM_EnableClassRegister()

/*	Called when round ends	*/
forward TFM_RoundEnd()

/*	Called when game exits	*/
forward TFM_ZombieModExit(iTeamWin)

/*	Called when a player is being infected	*/
forward TFM_PlayerBeingInfected(iVictim, iAttacker)