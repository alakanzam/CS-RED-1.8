#if defined _cgrenade_included
  #endinput
#endif
#define _cgrenade_included

#tryinclude "cstrike_pdatas/cbasemonster_offsets.inc"

//    CBaseEntity    ->    CBaseDelay    ->    CBaseAnimating    ->    CBaseToggle    ->    CBaseMonster    ->    CGrenade

#define        m_bStartDefuse                384    //    [g/s]et_pdata_bool
#define        m_bIsC4                        385    //    [g/s]et_pdata_bool
#define        m_hDefuser_pent            388    //    LINUX    +    20                    //    offset    97
#define        m_hDefuser_serial            98
#define        m_flDefuseCountDown    99
#define        m_flC4Blow                    100
#define        m_flNextFreqInterval        101
#define        m_flNextBeep                102
#define        m_flNextFreq                    103
#define        m_sBeepName                104
#define        m_fAttenu                        105
#define        m_flNextBlink                106
#define        m_flNextDefuseCheck    107
#define        m_bJustBlew                    108
#define        m_iGrenadeTeam            109
#define        m_iC4Hurry                    110
#define        m_pentCurBombTarget    444    //    LINUX    +    20    get_pdata_ent
#define        m_SGSmoke                112

//    int                    _dummy_113;    //    unknown    offset

#define        m_usEvent_Grenade        228    //    [g/s]et_pdata_short
#define        m_bLightSmoke            458    //    [g/s]et_pdata_bool
//    bool                    m_b459;        //    set    to    1    on    smoke    explode

stock const m_vecAngles[3] = {115,116,117}

#define        m_iRebundsCount            118
#define        m_fSoundSet                119
