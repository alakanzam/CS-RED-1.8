#if defined _WM_Grenade_included
	#endinput
#endif

#define _WM_Grenade_included


/*	Give a player Grenade	*/
native give_user_grenade(id, iGrenadeId)

/*	Get real id of grenade (Contact to CSW_*	)	*/
native get_grenade_real_id(iGrenadeId)

/*	Get grenade id of a player	*/
native get_user_grenade(id, SLOT_ID)

/*	Find grenade id by using World Model	*/
native find_grenade_by_model(szWorldModel[])

/*	Find grenade id by using Serial	*/
native find_grenade_by_serial(szSerial[])

/*	Retrieve grenade level	*/
native get_grenade_level(iGrenadeId)

/*	Retrieve grenade price	*/
native get_grenade_cost(iGrenadeId)

/*	Retrieve cost type of Grenade	*/
native get_grenade_cost_type(iGrenadeId)

/*	Retrieve HUD of Grenade	*/
native get_grenade_hud(iGrenadeId, szHud[], iLen)

/*	Retrieve Weight of Grenade	*/
native Float:get_grenade_weight(iGrenadeId)

/*	Retrieve Effective range of Grenade	*/
native Float:get_grenade_radius(iGrenadeId)

/*	Retrieve Speed of Grenade */
native Float:get_grenade_speed(iGrenadeId)

/*	Retrieve Knock Back power of Grenade	*/
native Float:get_grenade_kb_power(iGrenadeId)

/*	Set load type of Grenade	*/
native set_grenade_load(iLoadType)

/*	Make plugin load weapon files	*/
native load_grenade_file(szFile[], szExtension[], iIgnoreCondition = 1)

/*	Retrieve number of Registered Grenade	*/
native get_grenade_count()

/*	Retrieve name of grenade	*/
native get_grenade_name(iGrenadeId, szName[], iLen)

/*	Reset Grenade Id of a Slot	*/
native reset_grenade_slot(id, iSlotId)

/*	Set grenade spawn at a defined Amoury point or your defined origin	*/
native set_grenade_spawn(iArmouryPointed, iGrenadeId, Float:fOrigin[3])

/*	Check if weapon is valid Grenade	*/
native is_valid_grenade(iGrenadeId)

/*	Called when plugin tries to load grenade data	*/
forward GM_WeaponLoadData()

/*	Called when plugin checks if the models of grenades are usable	*/
forward GM_CheckWeaponSerial(szSerial[])

/*	Called when plugin tries to create Armoury Entity of Grenades	*/
forward GM_ArmouryCreating(iGrenadeId)

/*	Called when Grenade cause damage to a player	*/
forward GM_GrenadeDamage(iVicitm, iKiller, iGrenadeId)

/*	Called when plugin tries to check if player can equiped a grenade	*/
forward GM_UserCanEquipWpn(id)

/*	Called when plugin checks if a player can touch an Armoury of grenade	*/
forward GM_UserCanTouchArmoury(id)

/*	Called when plugin check if player can touch weapon box of grenade 	*/
forward GM_UserCanTouchWpnBox(id)

/*	Called when Armoury Entity of a Grenade is picked up	*/
forward GM_ArmouryPickedUp(id, iEnt)

/*	Called when plugin load a Grenade successfully	*/
forward GM_WeaponLoaded(iGrenadeId)