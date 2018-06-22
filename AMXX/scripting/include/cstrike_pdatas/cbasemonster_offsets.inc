#if defined _cbasemonster_included
  #endinput
#endif
#define _cbasemonster_included

#tryinclude "cstrike_pdatas/cbasetoggle_offsets.inc"

// CBaseEntity -> CBaseDelay -> CBaseAnimating -> CBaseToggle -> CBaseMonster
// Linux +5
#define		m_Activity								73
#define		m_IdealActivity						74
#define		m_LastHitGroup					75
#define		m_bitsDamageType				76


// NOT OFFSETS LOL
#define	itbd_Paralyze		0		
#define	itbd_NerveGas		1
#define	itbd_Poison			2
#define	itbd_Radiation		3
#define	itbd_DrownRecover	4
#define	itbd_Acid			5
#define	itbd_SlowBurn		6
#define	itbd_SlowFreeze		7
#define CDMG_TIMEBASED		8
stock const m_rgbTimeBasedDamage[CDMG_TIMEBASED] = {308,309,...}
// Usage get_pdata_char(id, m_rgbTimeBasedDamage[ itbd_DrownRecover ] )
// set_pdata_char(id, m_rgbTimeBasedDamage[ itbd_Poison ] , 200)

#define		m_MonsterState					79
#define		m_IdealMonsterState				80
#define		m_afConditions						81
#define		m_afMemory							82
#define		m_flNextAttack						83
#define		m_hEnemy_pent					336	// linux +20	// get_pdata_ent is (char) based		// 84
#define		m_hEnemy_serialnumber		85
#define		m_hTargetEnt_pent				344	// linux +20	// get_pdata_ent is (char) based		// 86
#define		m_hTargetEnt_serialnumber	87
#define		m_flFieldOfView						88
#define		m_bloodColor						89
#define		m_HackedGunPos_x				90
#define		m_HackedGunPos_y				91
#define		m_HackedGunPos_z				92
stock const m_vecEnemyLKP[3] = {93,94,95}