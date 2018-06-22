#if defined _cbasetoggle_included
  #endinput
#endif
#define _cbasetoggle_included

#tryinclude "cstrike_pdatas/cbaseanimating_offsets.inc"

// CBaseEntity -> CBaseDelay -> CBaseAnimating -> CBaseToggle
// Linux + 4
#define		m_toggle_state							41
#define		m_flActivateFinished					42
#define		m_flMoveDistance						43
#define		m_flWait									44
#define		m_flLip										45
#define		m_flTWidth								46
#define		m_flTLength								47
stock const m_vecPosition1[3] = {48,49,50}
stock const m_vecPosition2[3] = {51,52,53}
stock const m_vecAngle1[3] = {54,55,56}
stock const m_vecAngle2[3] = {57,58,59}
#define		m_cTriggersLeft							60
#define		m_flHeight									61
#define		m_hActivator_pent						248		// linux + 16	// get_pdata_ent is (char) based		// 62
#define		m_hActivator_serialnumber			63		// 63

#define		m_pfnCallWhenMoveDone_Flag_LINUX		68	// linux only, diff 0

// Linux +5
#define		m_pfnCallWhenMoveDone			64
stock const m_vecFinalDest[3] = {65,66,67}
stock const m_vecFinalAngle[3] = {68,69,70}
#define		m_bitsDamageInflict					71
#define		m_sMaster								72