#if defined _WM_SecondaryWpn_included
	#endinput
#endif

#define _WM_SecondaryWpn_included



/*	Give a Secondary Weapon to a player	*/

native give_player_sec_wpn(id, iSecondaryWpnId)

/*	Retrieve Hud of Secondary Weapon	*/

native get_sec_wpn_hud(iSecondaryWpnId, szHud[], iLen)

/*	Retrieve Secondary Weapon Id of a player	*/

native get_user_sec_wpn(id)

/*	Retrieve Real Weapon Id of a Secondary Weapon (Contact to CSW_* ) */

native get_sec_wpn_real_id(iSecondaryWpnId)

/*	Retrieve Name of Secondary Weapon	*/

native get_sec_wpn_name(iSecondaryWpnId, szName[], iLen)

/*	Retrieve number of Secondary Weapon	*/

native get_sec_wpn_number()

/*	Retrieve id of Secondary Weapon by find its World Model	*/

native find_sec_wpn_by_model(szModel[])

/*	How much does a Secondary Weapon cost	*/

native get_sec_wpn_cost(iSecondaryWpnId)

/* 	Type of Cost of a Secondary Weapon	*/

native get_sec_wpn_cost_type(iSecondaryWpnId)

/*	Retrieve speed of a Secondary Weapon (How much it decrease your speed) */

native Float:get_sec_wpn_speed(iSecondaryWpnId)

/*	How heavy a Secondary Weapon is 	*/

native Float:get_sec_wpn_weight(iSecondaryWpnId)

/*	How many bullets per clip of a Secondary Weapon	*/

native get_sec_wpn_clip(iSecondaryWpnId)

/*	How many bullets of a Secondary Weapon can a player carry with	*/

native get_sec_wpn_bpa(iSecondaryWpnId)

/*	Decide what type of weapon can be loaded	*/

native set_sec_wpn_load_type(iLoadType)

/*	Retrieve type of a Secondary Weapon	*/

native get_sec_wpn_type(iSecondaryWpnId)


/*	Make a Secondary Weapon spawn at a defined point or at a origin you want */

/*

- iSecondaryWpnId > -1 , spawns a Secondary Weapon at a origin
- iSecondaryWpnId < 0 , spawns a defined Secondary Weapon at defined Origin
*/

native set_sec_wpn_spawn(iPoint, iSecondaryWpnId = -1, Float:fOrigin[3])

/*	Who can equip this Secondary Weapon Id	*/

native get_sec_wpn_equip_type(iSecondaryWpnId)

/*	Retrieve Special Function of a Secondary Weapon	*/

native get_sec_wpn_special(iSecondaryWpnId)

/*	Retrieve Function of a Secondary Weapon */
native get_sec_wpn_func(iSecondaryWpnId)

/*	Load a Secondary Weapon File	*/
native set_sec_wpn_load_file(szFileName[], szExtension[], iIgnoreCondition = 1)

/*	Retrieve Knock Back Power of a Secondary Weapon	*/
native Float:get_sec_wpn_kb_power(iSecondaryWpnId)

/*	Effective range of Knock Back	*/
native get_sec_wpn_kb_distance(iSecondaryWpnId)

/*	Retrieve sub of Back Model of Secondary Weapon	*/
native get_sec_wpn_back_sub(iSecondaryWpnId)

/*	Retrieve name of Back Model of Secondary Weapon	*/
native get_sec_wpn_back_model(iSecondaryWpnId)

/*	Check if player is aiming down sight	*/
native sw_is_user_ads(id)

/*	Retrieve Secondary Weapon id by using its serial */
native find_sec_wpn_by_serial(szSerial[])

/*	Check if weapon is valid Secondary Weapon	*/
native is_valid_sw(iSecondaryWpnId)


/*	Called when plugin prepares for loading Secondary Weapon data	*/
forward SW_WeaponLoadData()

/*	Called when an armoury entity picked up	*/
forward SW_ArmouryPickUp(id, iEnt)

/*	Called when plugin check valid Serial	*/
forward SW_WeaponCheckSerial(szSerial[])

/*	Called when a function of a weapon is activated of de-activated	*/
forward SW_SpecialFuncToggle(id, iSecondaryWpnId, iFuncState)

/*	Called when plugin check if a player can touch a weapon box of Secondary weapon	*/
forward SW_UserCanTouchWpnBox(id)

/*	Called when plugin check if a player can touch an armoury entity of Secondary Weapon	*/
forward SW_UserCanTouchArmoury(id)

/*	Called when plugin check if a player can equip Secondary Weapon	*/
forward SW_UserCanEquipSecWpn(id)

/*	Called when plugin tries to Spawn an Armoury Entity of Secondary Weapon	*/
forward SW_ArmouryEntitySpawn(iSecondaryWpnId)

/*	Called when plugin loaded a Secondary Weapon successfully	*/
forward SW_WeaponLoaded(iSecondaryWpnId)