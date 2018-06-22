#if defined _AccountManager_included
  #endinput
#endif
#define _AccountManager_included

enum
{
	EQUIP_FULL = 1,
	EQUIP_KNIFE,
	EQUIP_PISTOL,
	EQUIP_SNIPER
}

enum
{
	LINE_INVENTORY_POS = 24,
	LINE_CHARACTER,
	LINE_ARMOR,
	LINE_DEFUSER,
	LINE_TEAM,
	LINE_ZOMBIE_CLASS,
	LINE_NVG,
	LINE_JEWEL,
	LINE_GHOST_SPEED,
	LINE_GHOST_HEALTH,
	LINE_GHOST_SKILL1,
	LINE_GHOST_SKILL2,
	LINE_GHOST_SKILL3,
	LINE_QUICK_RESPAWN,
	LINE_SILENCER
	
}

#define LINE_MEDKIT 49
/*	Check if player logged in	*/
native is_user_online(id)

/*	Retrieve account of a player	*/
native get_user_account(id, szAccount[], iLen)

/*	Retrieve nick name of a player	*/
native get_user_nickname(id, szNickName[], iLen)

/*	Get the equiptype of map	*/
native get_map_equip_type()

/*	Check if auto login is enabled	*/
native is_autologin_enabled()

/*	Check if launcher is running	*/
native is_launcher_running()

/*	Check if player can open inventory menu	*/
native can_user_use_inventory(id)

/*	Return current inventory slot*/
native get_user_current_slot(id)

/*	Check if player is in Equip Zone	*/
native is_user_in_equip_zone(id)

/*	Get max inventory slot	*/
native get_max_inventory_slot()

/****************************************************************************************/

/*	Set primary weapon to inventory slot	*/
native set_inventory_primary(id, iInventoryId, iPrimaryWpnType, iPrimaryWpnId)

/*	Set secondary weapon to inventory slot	*/
native set_inventory_secondary(id, iInventoryId, iSecondaryWpnType, iSecondaryWpnId)

/*	Set melee to inventory slot	*/
native set_inventory_melee(id, iInventoryId, iMeleeType, iMeleeId)

/*	Set grenade to inventory slot	*/
native set_inventory_grenade(id, iInventoryId, iGrenadeType, iGrenadeId)

/****************************************************************************************/


/*	Read info of an account file	*/
native read_account_file(id, iLine, szOutput[], iLen)

/*	Called when player successfully sign in	*/
forward TM_PlayerLoggedIn(id, szNickName[])