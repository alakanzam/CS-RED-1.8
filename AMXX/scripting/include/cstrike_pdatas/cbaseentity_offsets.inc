#if defined _cbaseentity_included
  #endinput
#endif
#define _cbaseentity_included

// CBaseEntity

#define		vtbl_WINDOWS			0

// LINUX -1
#define		_pev							1
#define		m_pGoalEnt				2
#define		m_pLink					3

#define		m_pfnThink_Flag_LINUX			3	// linux only, diff 0

#define		m_pfnThink				4				// linux diff 0

#define		m_pfnTouch_Flag_LINUX		5	// linux only, diff 0

#define		m_pfnTouch				5				// linux diff +1

#define		m_pfnUse_Flag_LINUX			7	// linux only, diff 0

#define		m_pfnUse					6				// linux diff +2

#define		m_pfnBlocked_Flag_LINUX		9	// linux only, diff 0

// Linux +3
#define		m_pfnBlocked			7
#define		ammo_buckshot		11
#define		ammo_9mm				13
#define		ammo_556nato			15
#define		ammo_556natobox	17
#define		ammo_762nato			19
#define		ammo_45acp			21
#define		ammo_50ae				23
#define		ammo_338magnum	25
#define		ammo_57mm			27
#define		ammo_357sig			29
#define		m_flStartThrow			30
#define		m_flReleaseThrow		31
#define		m_chargeReady		32
#define		m_fInAttack				33

#define		vtbl_LINUX								37


// CBaseEntity -> CArmoury
// Linux + 4
#define XO_CARMOURY	4

#define		m_iItem					34		// weapon ID defined in fgd
#define		m_iCount					35		// item count before entity desappear
#define		m_iSaveCount			36		// saved m_iCount value at Spawn
#define		m_bRestoreCount		148		// if true [g/s]et_pdata_bool