/* This file is contact with g4u_pistol.amxx, g4u_riffle.amxx, g4u_hegrenade.amxx, ... */

#if defined _weaponbox_info_included
  #endinput
#endif
#define _weaponbox_info_included

#include <fakemeta>

#define TASK_ACTIVE_WEAPONBOX 2500
#define WEAPONBOX_ACTIVE_TIME 0.4

#define pev_iWpnBoxState	pev_iuser4
#define pev_iGrenadePosition pev_iuser1
#define pev_iGrenadeId pev_iuser2
#define pev_iGrenadeType	pev_iuser3
#define pev_iGrenadeActive	pev_iuser4

#define pev_fGrenadeActiveTime	pev_fuser1
#define pev_fGrenadeExplodeTime	pev_fuser2
#define pev_fGrenadeFallStatus	pev_fuser3

#define pev_fGrenadeEndOrigin	pev_vuser1


#define GRENADE_CLASS_NORMAL	14000
#define GRENADE_CLASS_NEW	15000
#define PW_CLASS_EXPLOSIVE	16000 // Grenade of Primary Wpn Mod
#define PW_CLASS_FLASH	17000 // Grenade of Primary Wpn Mod
#define SW_CLASS_EXPLOSIVE	18000 // Grenade of Secondary Wpn Mod
#define SW_CLASS_FLASH	19000 // Grenade of Secondary Wpn Mod


enum
{
	WpnBoxNormalSecondaryWait = 2000 ,
	WpnBoxNormalSecondaryReady,
	WpnBoxSecondaryWait,
	WpnBoxSecondaryReady,
	WpnBoxNormalPrimaryWait,
	WpnBoxNormalPrimaryReady,
	WpnBoxPrimaryWait,
	WpnBoxPrimaryReady,
	WpnBoxMeleeWait,
	WpnBoxMeleeReady,
	WpnBoxNormalGrenadeWait,
	WpnBoxNormalGrenadeReady,
	WpnBoxGrenadeWait,
	WpnBoxGrenadeReady,
	WpnBoxC4CanTouch,
	WpnBoxC4WaitTouch,
	WpnBoxShieldCanTouch,
	WpnBoxShieldCantTouch
}
	
stock CheckWpnBoxState(iEnt)
	return pev(iEnt, pev_iuser4)

stock IsWeaponBoxCanTouch(iEnt)
{
	new iState = pev(iEnt, pev_iuser4)
	
	if (iState == WpnBoxNormalSecondaryWait)
		return 0
	if (iState == WpnBoxSecondaryWait)
		return 0
	if (iState == WpnBoxNormalPrimaryWait) 
		return 0
	if (iState == WpnBoxPrimaryWait)
		return 0
	if (iState == WpnBoxMeleeWait)
		return 0
	if (iState == WpnBoxNormalGrenadeWait)
		return 0
	if (iState == WpnBoxGrenadeWait)
		return 0
	if (iState == WpnBoxShieldCantTouch)
		return 0
	if (iState == WpnBoxC4WaitTouch)
		return 0
	return 1
}

stock IsCsRedWpnBox(iEnt)
{
	new iState = pev(iEnt, pev_iuser4)
	
	if (iState == WpnBoxNormalSecondaryReady)
		return 1
		
	if (iState == WpnBoxSecondaryReady)
		return 1
		
	if (iState == WpnBoxNormalPrimaryReady)
		return 1
		
	if (iState == WpnBoxPrimaryReady)
		return 1
		
	if (iState == WpnBoxMeleeReady)
		return 1
	
	if (iState == WpnBoxNormalGrenadeReady)
		return 1
	
	if (iState == WpnBoxGrenadeReady)
		return 1
	
	if (iState == WpnBoxC4CanTouch)
		return 1
	return 0
}

