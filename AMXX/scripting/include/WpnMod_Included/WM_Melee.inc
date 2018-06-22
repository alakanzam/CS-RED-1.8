#if defined _WM_Melee_included
	#endinput
#endif

#define _WM_Melee_included


/*	Give a Melee to a player	*/

native give_user_melee(id, iMeleeId)

/*	Retrieve Hud of a Melee	*/

native get_melee_hud(iMeleeId, szHud[], iLen)

/*	Retrieve Melee Id of a player	*/

native get_user_melee(id)

/*	Retrieve the name of a Melee	*/

native get_melee_name(iMeleeId, szName[], iLen)

/*	Retrieve the number of registered Melee	*/

native get_melee_number()

/*	Retrieve id of a Melee by finding its View Model	*/
native find_melee_by_model(szViewModel[])

/*	Retrieve id of a Melee by using its Serial	*/
native find_melee_by_serial(szSerial[])

/*	How much does this Melee cost	*/

native get_melee_cost(iMeleeId)

/* 	What type of cost	*/

native get_melee_cost_type(iMeleeId)

/*	Retrieve the weight of a Melee	*/

native Float:get_melee_weight(iMeleeId)

/*	Retrieve the speed of a Melee (how much it decrease your speed)	*/

native Float:get_melee_speed(iMeleeId)

/*	Retrieve the level of Melee	*/

native get_melee_level(iMeleeId)

/*	Make plugin load a melee configuration file	*/

native set_melee_load_file(szFileName[], szExtension[], iIgnore_AllConditions = 1)

/*	Spawn a Melee at a defined point or your origin	*/

native set_melee_spawn(iPoint, iMeleeId = -1, Float:fOrigin[3])

/*	Retrieve knock back power of Melee	*/

native Float:get_melee_kb_power(iMeleeId)

/*	Retrieve effective knock back range of a weapon */

native get_melee_kb_distance(iMeleeId)

/*	Check if weapon is valid Melee	*/
native is_valid_melee(iMeleeId)

/*	Called when Melee prepares loading data	*/

forward MM_MeleeCheckSerial(szSerial[])

/*	Called when an Armoury Entity is picked up	*/
forward MM_ArmouryPickedUp(id, iEnt)

/*	Called when plugin check if player can touch Weapon Box of Melee	*/
forward MM_UserCanTouchWpnBox(id)

/*	Called when plugin check if a player can touch Armoury Entity of Melee	*/
forward MM_UserCanTouchArmoury(id)

/*	Called when plugin check if a player can equip a Melee weapon	*/
forward MM_UserCanEquipMelee(id)

/*	Called when plugin try to spawn an Armoury Entity of a Melee	*/
forward MM_ArmouryEntitySpawn(iMeleeId)

/*	Called when plugin load a Melee weapon successfully	*/
forward MM_WeaponLoaded(iMeleeId)