/*
Copyleft by Johnny got his gun
http://www.amxmodx.org/forums/viewtopic.php?p=22368
*
EDIT BY REDPLANE */

new const PLUGINNAME[] = "Drop all weapons when you die"
new const VERSION[] = "0.1"
new const AUTHOR[] = "JGHG"


#include <amxmodx>
#include <hamsandwich>
#include <player_api>


public plugin_init()
	register_plugin(PLUGINNAME, VERSION, AUTHOR)

public csred_PlayerKilledPost(iVictim, iKiller)
{
	new iWeapons[32]
	new iCounter_Weapon
	
	get_user_weapons(iVictim, iWeapons, iCounter_Weapon)
	for (new i = 0; i < iCounter_Weapon ;i++)
	{
		if (iWeapons[i] == CSW_HEGRENADE || iWeapons[i] == CSW_FLASHBANG || iWeapons[i] == CSW_SMOKEGRENADE)
			continue
			
		new szWeaponName[32]
		get_weaponname(iWeapons[i], szWeaponName, sizeof szWeaponName - 1)
		engclient_cmd(iVictim, "drop", szWeaponName)
	}
}



/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
