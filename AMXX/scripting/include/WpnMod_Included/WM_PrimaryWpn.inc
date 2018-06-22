#if defined _WM_PrimaryWpn_included
	#endinput
#endif

#define _WM_PrimaryWpn_included

#include <WpnMod_Included/WM_GlobalConstant.inc>

enum
{
	FUNC_OFF,
	FUNC_ON
}

enum
{
	STAGE_NONE,
	STAGE_SPIN,
	STAGE_FIRE
}

enum
{
	PRIM_SPEC_NONE,
	PRIM_SPEC_REACTIVE_ZOOM
}

native get_user_pw(id)

native get_pw_real_id(iPrimaryWpnId)

native get_pw_number()

native give_user_pw(id, iPrimaryWpnId)

native get_pw_hud(iPrimaryWpnId, szHud[], iLen)

native get_pw_name(iPrimaryWpnId, szName[], iLen)

native Float:get_pw_weight(iPrimaryWpnId)

native find_pw_by_model(szModel[])

native Float:get_pw_speed(iPrimaryWpnId)

native get_pw_cost(iPrimaryWpnId)

native get_pw_cost_type(iPrimaryWpnId)

native get_pw_bpammo(iPrimaryWpnId)

native set_pw_load_type(iLoadType)

native get_pw_ammo(iPrimaryWpnId)

native pw_user_using_grenadier(id)

native get_pw_grenade_clip(iPrimaryWpnId)

native get_pw_grenade_bpa(iPrimaryWpnId)

native is_pw_grenadier(iPrimaryWpnId)

native set_user_pw_grenade(id, iPrimaryWpnId, iClip, iBpa) 

native get_pw_type(iPrimaryWpnId)

native get_pw_function(iPrimaryWpnId)

native get_pw_special(iPrimaryWpnId)

native pw_user_attack_stage(id)

native set_pw_spawn(iPoint, iPrimaryWeaponId, Float:fOrigin[3])

native get_pw_world_model(iPrimaryWpnId, szModel[], iLen)

native get_pw_equiptype(iPrimaryWpnId)

native get_pw_serial(iPrimaryWpnId, szSerial[], iLen)

native find_pw_by_serial(szSerial[])

native set_pw_load_file(szFileName[], szExtension[], iIgnoreCondition = 1)

native Float:get_pw_kb_power(iPrimaryWpnId)

native Float:get_pw_kb_distance(iPrimaryWpnId)

/*	Check if player is Aiming Down Sight	*/

native pw_is_ads(id)

/*	Retrieve model of Back Weapon */
native get_pw_back_model(iPrimaryWpnId, szModel[], iLen)

/*	Retrieve sub body of Back Weapon */

native get_pw_back_sub(iPrimaryWpnId)

/*	Check if weapon is valid Primary Wpn*/
native is_valid_pw(iPrimaryWpnId)


forward PW_WeaponCheckSerial(szSerial[])

/*	Called when player actives a Function of Primary Weapon	*/
forward PW_FunctionActivated(id, iPrimaryWpnId, iFunctionStatus)

/*	Called when a player picked an armoury up	*/
forward PW_ArmouryPickedUp(id, iEnt)

/*	Called when plugin prepare for loading new Primary Weapons	*/
forward PW_WeaponLoadData()

/*	Called when plugin check if a player can touch weapon box of Primary Weapons	*/
forward PW_UserCanTouchWpnBox(id)

/*	Called when plugin check if a player can touch amoury entity of Primary Weapon	*/
forward PW_UserCanTouchArmoury(id)

/*	Called when plugin checks if a player can change to second function of Primary Weapon	*/
forward PW_UserCanUseSecFunc(id)

/*	Called when plugins checks if a player can equip Primary Weapon	*/
forward PW_UserCanEquipPrimWpn(id)

/*	Called when plugins tries to spawn an Armoury Entity of Primary Weapon	*/
forward PW_ArmouryEntitySpawn(iPrimaryWpnId)

/*	Called when a Grenade causes damage to a Victim (Launcher / Explosive bullets)	*/
forward PW_GrenadeDamage(iVictim, iAttacker, iPrimaryWpnId, iAliveStatus)

/*	Called when a Primary Weapon is successfully loaded	*/
forward PW_WeaponLoaded(iPrimaryWpnId)