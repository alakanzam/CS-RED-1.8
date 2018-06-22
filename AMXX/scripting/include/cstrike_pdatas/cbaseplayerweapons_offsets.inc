#if defined _cbaseplayerweapon_included
  #endinput
#endif
#define _cbaseplayerweapon_included

#tryinclude "cstrike_pdatas/cbaseanimating_offsets.inc"

// CBaseEntity -> CBaseDelay -> CBaseAnimating -> CBasePlayerItem
// Linux +4
#define XO_CBASEPLAYERWEAPON	4

// CBasePlayerItem
#define	m_pPlayer						41
#define	m_pNext							42
#define	m_iId								43

// CBaseEntity -> CBaseDelay -> CBaseAnimating -> CBasePlayerItem -> CBasePlayerWeapon
// Linux +4

// CBasePlayerWeapon	
#define	m_iPlayEmptySound			44
#define	m_fFireOnEmpty				45  // True when the gun is empty and the player is still holding down the attack key
#define	m_flNextPrimaryAttack		46	// soonest time ItemPostFrame will call PrimaryAttack
#define	m_flNextSecondaryAttack	47	// soonest time ItemPostFrame will call SecondaryAttack
#define	m_flTimeWeaponIdle			48	// soonest time ItemPostFrame will call WeaponIdle
#define	m_iPrimaryAmmoType		49	// "primary" ammo index into players m_rgAmmo[]
#define	m_iSecondaryAmmoType	50	// "secondary" ammo index into players m_rgAmmo[]
#define	m_iClip								51	// number of shots left in the primary weapon clip, -1 it not used
#define	m_iClientClip						52	// the last version of m_iClip sent to hud dll
#define	m_iClientWeaponState		53	// the last version of the weapon state sent to hud dll (is current weapon, is on target)
#define	m_fInReload						54	// Are we in the middle of a reload;
#define	m_fInSpecialReload			55	// Are we in the middle of a reload for the shotguns
#define	m_iDefaultAmmo				56	// how much ammo you get when you pick up this weapon as placed by a level designer.
#define	m_iShellLate						57
#define	m_flWeaponSpeed				58	// used for guns to restore after shield
#define	m_bDelayFire					236

#define	m_iDirection						60	// The current lateral kicking direction ; 1 = right, 0 = left.

#define	m_flAccuracy					62
#define	m_flLastFire						63
#define	m_iShotFired						64

#define	m_iszViewModel				68
#define	m_flGlock18Shoot				69
#define	m_iGlock18ShotsFired		70
#define	m_flFamasShoot				71
#define	m_iFamasShotsFired			72
#define	m_flFamasBurstSpread		73
#define	m_fWeaponState				74
#define	m_flNextReload					75
#define	m_flDecreaseShotsFired	76
#define	m_usGlock18Event			154	// [g/s]et_pdata_short
#define	m_usFamasEvent				155	// [g/s]et_pdata_short

// Weapon Specific :
// Linux +4

// CHEGrenade
#define	m_usExplo_HEGREN		156

// CAK47
#define	m_iShell_AK47					78
#define	m_fIsDeployed_AK47			79
#define	m_usEvent_AK47				160

// CAUG
#define	m_iShell_AUG					78
#define	m_fIsDeployed_AUG			79
#define	m_usEvent_AUG				160

// CDEAGLE
#define	m_iShell_DEAGLE			78
#define	m_usEvent_DEAGLE			158

// CELITE
#define	m_iShell_ELITE					78
#define	m_usEventLeft_ELITE		158
#define	m_usEventRigth_ELITE		159
	
// CFiveSeven
#define	m_iShell_FiveSeven			78
#define	m_usEvent_FiveSeven		158
	
// CM249
#define	m_iShell_CM249				78
#define	m_fIsDeployed_CM249		79
#define	m_usEvent_CM249			160

// CM4A1
#define	m_iShell_M4A1					78
#define	m_fIsDeployed_M4A1		79
#define	m_usEvent_M4A1				160

// CMAC10
#define	m_iShell_MAC10				78
#define	m_fIsDeployed_MAC10		79
#define	m_usEvent_MAC10			160

// CMP5N
#define	m_iShell_CMP5N				78
#define	m_fIsDeployed_CMP5N		79
#define	m_usEvent_CMP5N			160

// CP228
#define	m_iShell_P228					78
#define	m_usEvent_P228				158
	
// CP90
#define	m_iShell_P90					78
#define	m_fIsDeployed_P90			79
#define	m_usEvent_P90				160

// CSG552
#define	m_iShell_SG552				78
#define	m_fIsDeployed_SG552		79
#define	m_usEvent_SG552			160

// CTMP
#define	m_iShell_TMP					78
#define	m_fIsDeployed_TMP			79
#define	m_usEvent_TMP				160

// CUMP45
#define	m_iShell_UMP45				78
#define	m_fIsDeployed_UMP45		79
#define	m_usEvent_UMP45			160

// CUSP
#define	m_iShell_USP					78
#define	m_usEvent_USP				158
	
// CGalil
#define	m_iShell_Galil					78
#define	m_fIsDeployed_Galil			79
#define	m_usEvent_Galil				160

// CFamas
#define	m_iShell_Famas				78
#define	m_fIsDeployed_Famas		79
	
// CGLOCK18
#define	m_iShell_GLOCK18			78
#define	m_fIsDeployed_GLOCK18	79
	
// CSmokeGrenade
#define	m_usSmokeExplo				156
	
// CSCOUT
#define	m_iShell_SCOUT				78
#define	m_usEvent_SCOUT			158
	
// CAWP
#define	m_iShell_AWP					78
#define	m_usEvent_AWP				158
	
// CSG550
#define	m_iShell_SG550				78
#define	m_usEvent_SG550			158
	
// CG3SG1
#define	m_iShell_G3SG1				78
#define	m_usEvent_G3SG1			158
	
// CFlashbang // no private data

// CXM1014
#define	m_iShell_XM1014				78
#define	m_flPumpTime_XM1014		79
#define	m_usEvent_XM1014			160
	
// CXM3
#define	m_iShell_XM1014				78
#define	m_flPumpTime_XM1014		79
#define	m_usEvent_XM1014			160
	
// CC4
#define	m_bArming_C4					312
#define	m_bInArmingAnimation_C4	313
#define	m_flArmedTime_C4			79

// CKnife
#define	m_fAllSolid_CKnife					78
#define	m_fStartSolid_CKnife				79
#define	m_fInOpen_CKnife					80
#define	m_fInWater_CKnife					81
#define	m_flFraction_CKnife					82
stock const m_vecEndPos_CKnife = {83,84,85}
#define	m_flPlaneDist_CKnife				86
stock const m_vecPlaneNormal_CKnife[3] = {87,88,89}
#define	m_pHit_CKnife							90
#define	m_iHitgroup_CKnife					91
#define	m_usEvent_CKnife					184
	
// CWeaponCycler
#define	m_iszModel_WeaponCycler	78
#define	m_iModel_WeaponCycler		79
