#if defined _cbaseplayer_included
  #endinput
#endif
#define _cbaseplayer_included

#tryinclude "cstrike_pdatas/cbasemonster_offsets.inc"

// CBaseEntity -> CBaseDelay -> CBaseAnimating -> CBaseToggle -> CBaseMonster -> CBasePlayer
// Linux +5

#define        random_seed                                    96    //    See    that    is    shared    between    client    &    server    for    shared    weapons    code
//    97    unknown
#define        m_hSpectatedTarget_pent                    392    //    linux    +20    //    m_hSpectatedTarget    takes    98    and    99    normally    //    get_pdata_ent,    no    set
#define        m_hSpectatedTarget_serialnumber        99
#define        m_flNextSpecButtonTime                    100
#define        m_iSpectatedPlayerWeaponId            101
#define        m_fHasSpectatedPlayerC4                    102
#define        m_fHasSpectatedPlayerDefuseKit        103
#define        m_iObserverMode                                104
#define        m_flAnimationTimeDummy                    105
//    106    unknown
#define        m_fHasTakenHighDamage                    107        //    Last    damage    >    60    ?
#define        m_flPainShock                                    108
#define        m_iLastZoom                                    109
#define        m_fResumeZoom                                110
#define        m_flEjectBrass                                    111
#define        m_iKevlarType                                    112
#define        m_fHasSurvivedLastRound                    113
#define        m_iTeam                                            114
#define        m_iAccount                                        115
#define        m_fHasPrimary                                    116
//    int        _dummy_117        //    animation    //    117    unknown
#define        m_iAnimationInCaseDie                        118    //    set    according    to    hitplace    and    random    values    //    used    when    dies    to    set    some    properties    (velocity,    that    kind    of    stuff)
#define        m_flNextChatTime                                119                        
//    #define        m_bHasReceivedDefItems                    120    //    (1<<0)
#define        m_bHasReceivedDefItems                    480    //    [g/s]et_pdata_bool
#define        m_iJoinedState                                    121
#define        m_pLastCamera                                122
#define        m_flNextCameraTime                            123
#define        m_flLastActivityTime                            124
//    #define        m_bools125                                        125    //    m_bHasBeenShownBriefing    (1<<0)            //    m_bHasChangeTeamThisRound    (1<<8)
#define        m_bHasBeenShownBriefing                500    //    [g/s]et_pdata_bool
#define        m_bHasChangeTeamThisRound            501    //    [g/s]et_pdata_bool
#define        m_iInternalModel                                126
#define        m_iTeamMateKills                                127
#define        m_iIgnoreMessages                            128
//    #define        m_boolsNVG                                        129    //    m_bGotNVG    (1<<0)        //    m_bIsNVGSwitchedOn    (1<<8)
#define        m_bGotNVG                                        516    //    [g/s]et_pdata_bool
#define        m_bIsNVGSwitchedOn                        517    //    [g/s]et_pdata_bool
//    BIG    HOLE
#define        m_flNextIdleCheckTime                        190
#define        m_flNextRadioGameTime                    191
#define        m_iRadiosLeft                                    192
//    #define        m_bools193                                        193    //    m_bHasSilentRadio    (1<<0)    //    m_bHasC4    (1<<8)    //    m_bHasDefuser    (1<<16)        //    m_bBlastDamaged    (1<<24)
#define        m_bHasSilentRadio                            772    //    [g/s]et_pdata_bool
#define        m_bHasC4                                        773    //    [g/s]et_pdata_bool
#define        m_bHasDefuser                                    774    //    [g/s]et_pdata_bool
#define        m_bBlastDamaged                            775    //    [g/s]et_pdata_bool
stock const m_vecRelativeInflictorOrigin[3] = {194,195,196}
#define        m_bTruOnHeDamage                            197                //    CBasePlayer::SetAnimation
#define        m_fNextHudTextArgsGameTime            198
//    LITTLE    HOLE    HudTextArgs    RELATED
#define        m_bitHudTextArgsDontResend            204
#define        m_iMenu                                            205
//    206    unknown
//    207    unknown
#define        m_fIsVIPRescued                                208
//    #define        m_boolsAsEscape                                209    //    m_bHasReachRescueEscapePoint    (1<<0)    //    m_bIsVip    (1<<8)
#define        m_bHasReachRescueEscapePoint        836        //    [g/s]et_pdata_bool
#define        m_bIsVip                                            837        //    [g/s]et_pdata_bool
#define        m_flNextRadarUpdateTime                    210
stock const m_vecLastPosition[3] = {211,212,213}
#define        m_iVoteKickUserId                            214
#define        m_flNextVote                                    215    //    votemap    votekick
#define        m_iTeamKills                                    216
#define        m_iHostageKills                                217
#define        m_iVotedMapIndex                            218
#define        m_bIsPrimaryFireAllowed                    219
#define        m_flLastAttackTime                            220    //    not    sure
#define        m_flNextTeammateAttackAlert            221
//    #define        m_boolsKilled                                    222    //    m_bKilledByHeadShot    (1<<0)    //    m_bKilledBecauseTeamKill    (1<<8)    //    m_bNotReceivingMoneyNextRound    (1<<16)
#define        m_bKilledByHeadShot                        888    //    [g/s]et_pdata_bool
#define        m_bKilledBecauseTeamKill                889    //    [g/s]et_pdata_bool
#define        m_bNotReceivingMoneyNextRound        890    //    [g/s]et_pdata_bool
#define        m_flNextTimeleft                                223
#define        m_boolChangeNameAtRespawn            896    //    [g/s]et_pdata_bool
#define        m_szNewName                                    897    //    (224*4    +    1)    [g/s]et_pdata_string    //    char    m_szNewName[32]
#define        m_fBombDefusing                                232    //    m_bBombDefusing    (1<<8)
#define        m_flNextMapZoneTime                        233
#define        m_fMapZone                                        234
#define        m_fClientMapZone                                235
#define        m_pentBombTarget                            236
#define        m_iPlayerSound                                237    //    the    index    of    the    sound    list    slot    reserved    for    this    player
#define        m_iTargetVolume                                238    //    ideal    sound    volume.    
#define        m_iWeaponVolume                            239    //    how    loud    the    player's    weapon    is    right    now.
#define        m_iExtraSoundTypes                            240    //    additional    classification    for    this    weapon's    sound
#define        m_iWeaponFlash                                241    //    brightness    of    the    weapon    flash
#define        m_flStopExtraSoundTime                    242    //    
#define        m_flFlashLightTime                            243    //    Time    until    next    battery    draw/Recharge
#define        m_iFlashBattery                                244    //    Flashlight    Battery    Draw
#define        m_afButtonLast                                    245
#define        m_afButtonPressed                            246
#define        m_afButtonReleased                            247
#define        m_pentSndLast                                    248    //    last    sound    entity    to    modify    player    room    type
#define        m_flSndRoomtype                                249    //    last    roomtype    set    by    sound    entity
#define        m_flSndRange                                    250    //    dist    from    player    to    sound    entity
#define        m_flFallVelocity                                    251

// constant items
#define ITEM_HEALTHKIT		1
#define ITEM_ANTIDOTE		2
#define ITEM_SECURITY		3
#define ITEM_BATTERY		4
#define MAX_ITEMS				5	// hard coded item types
stock const m_rgItems[MAX_ITEMS] = { 252 , 253 , ... }

#define        m_afPhysicsFlags                                257    //    physics    flags    -    set    when    'normal'    physics    should    be    revisited    or    overriden
#define        m_fNextSuicideTime                            258    //    the    time    after    which    the    player    can    next    use    the    suicide    command
#define        m_flTimeStepSound                            259    //    when    the    last    stepping    sound    was    made
#define        m_flTimeWeaponIdle_PLAYER              260    //    when    to    play    another    weapon    idle    animation.
#define        m_flSwimTime                                    261    //    how    long    player    has    been    underwater
#define        m_flDuckTime                                    262    //    how    long    we've    been    ducking
#define        m_flWallJumpTime                                263    //    how    long    until    next    walljump
#define        m_flSuitUpdate                                    264    //    when    to    play    next    suit    update
stock const m_rgSuitPlayList[4] = {265,266,...}	//[CSUITPLAYLIST]    //    next    sentencenum    to    play    for    suit    update
#define        m_iSuitPlayNext                                269    //    next    sentence    slot    for    queue    storage
stock const m_rgiSuitNoRepeat[32] = {270,271,...}    //    [32]    //[CSUITNOREPEAT]        //    suit    sentence    no    repeat    list
stock const m_rgflSuitNoRepeatTime[32] = {302,303,...}                          //    [32]    //[CSUITNOREPEAT]    //    how    long    to    wait    before    allowing    repeat
#define        m_lastDamageAmount                        334    //    Last    damage    taken
#define        m_tbdPrev                                            335    //    Time-based    damage    timer
#define        m_flgeigerRange                                336    //    range    to    nearest    radiation    source
#define        m_flgeigerDelay                                    337    //    delay    per    update    of    range    msg    to    client
#define        m_igeigerRangePrev                            338
#define        m_iStepLeft                                        339    //    alternate    left/right    foot    stepping    sound
#define        m_szTextureName                                1360    //    440*4        m_szTextureName[19    char]    //HL    13    [CBTEXTURENAMEMAX]    //    current    texture    name    we're    standing    on
#define        m_chTextureType                                1379    //    current    texture    type    //    may    be    use    344    instead
#define        m_idrowndmg                                    345    //    track    drowning    damage    taken
#define        m_idrownrestored                                346    //    track    drowning    damage    restored
#define        m_bitsHUDDamage                            347    //    Damage    bits    for    the    current    fame.    These    get    sent    to    
#define        m_fInitHUD                                        348    //    True    when    deferred    HUD    restart    msg    needs    to    be    sent
#define        m_fGameHUDInitialized                        349
#define        m_iTrain                                            350    //    Train    control    position
#define        m_fWeapon                                        351    //    Set    this    to    FALSE    to    force    a    reset    of    the    current    weapon    HUD    info
#define        m_pTank_pent                                    1408    //    linux    +    20    //    352    //    the    tank    which    the    player    is    currently    controlling,    NULL    if    no    tank
#define        m_pTank_serialnumber                        353    //    the    tank    which    the    player    is    currently    controlling,    NULL    if    no    tank
#define        m_fDeadTime                                    354    //    the    time    at    which    the    player    died    (used    in    PlayerDeathThink())
#define        m_fNoPlayerSound                            355    //    a    debugging    feature.    Player    makes    no    sound    if    this    is    true.    
#define        m_fLongJump                                    356    //    does    this    player    have    the    longjump    module?
#define        m_tSneaking                                        357
#define        m_iUpdateTime                                    358    //    stores    the    number    of    frame    ticks    before    sending    HUD    update    messages
#define        m_iClientHealth                                    359    //    the    health    currently    known    by    the    client.    If    this    changes,    send    a    new
#define        m_iClientBattery                                360    //    the    Battery    currently    known    by    the    client.    If    this    changes,    send    a    new
#define        m_iHideHUD                                        361    //    the    players    hud    weapon    info    is    to    be    hidden
#define        m_iClientHideHUD                                362
#define        m_iFOV                                            363    //    field    of    view
#define        m_iClientFOV                                    364    //    client's    known    FOV
#define        m_iSpawnCount                                365
#define        m_pLinkedEntity                                366
stock const m_rgpPlayerItems_CBasePlayer[6] = { 367 , 368 , ... }
#define        m_pActiveItem                                    373
#define        m_pClientActiveItem                            374    //    client    version    of    the    active    item
#define        m_pLastItem                                        375
stock const m_rgAmmo_CBasePlayer[32] = {376,377,...}                    //   376    //    [MAX_AMMO_SLOTS]    
stock const m_rgAmmoLast[32] = {408,409,...}    //    [MAX_AMMO_SLOTS]    
stock const m_vecAutoAim[3] = {440,441,442}
#define        m_fOnTarget                                        443
#define        m_iDeaths                                        444
#define        m_iRespawnFrames                            445    //    used    in    PlayerDeathThink()    to    make    sure    players    can    always    respawn
#define        m_izSBarState_0                                446    //    [SBAR_END]
#define        m_izSBarState_1                                447    //    [SBAR_END]
#define        m_izSBarState_2                                448    //    [SBAR_END]
#define        m_flNextSBarUpdateTime                    449
#define        m_flStatusBarDisappearDelay                450
#define        m_SbarString0                                    1804    //    [SBAR_STRING_SIZE]    //    128
#define        m_lastx                                            483
#define        m_lasty                                            484    //    483    484    //    These    are    the    previous    update's    crosshair    angles,    DON"T    SAVE/RESTORE
#define        m_nCustomSprayFrames                    485    //    Custom    clan    logo    frames    for    this    player
#define        m_flNextDecalTime                            486    //    next    time    this    player    can    spray    a    decal    //    382
#define        m_szTeamName                                1948    //    m_szTeamName[16]
#define        g_szModelIndexPlayer                        491    //    psz
#define        m_szShieldAnimExt                            1968    //    m_szShieldAnimExt[32]    
#define        m_iGaitSequence                                500
#define        m_flGaitFrame                                    501
#define        m_flGaitYaw                                        502
#define        m_flPrevGaitOrigin_x                            503
#define        m_flPrevGaitOrigin_y                            504
#define        m_flPrevGaitOrigin_z                            505
#define        m_flPitch                                            506
#define        m_flYaw                                            507
#define        m_flGaitMovement                                508
#define        m_fAutoWeaponSwitch                        509
//    #define        m_boolsUserPrefsAndShield                510    //    m_bHasVGUIMenus    (1<<0)    //    m_bHasAutoHelp    (1<<8)    //    m_bUsesShield    (1<<16)    //    m_bHasShield    (1<<24)
#define        m_boolsUserPrefsAndShield                2040        //    [g/s]et_pdata_bool
#define        m_bHasAutoHelp                                2041        //    [g/s]et_pdata_bool
#define        m_bUsesShield                                    2042        //    [g/s]et_pdata_bool
#define        m_bHasShield                                    2043        //    [g/s]et_pdata_bool
#define        m_fObserverHasTarget                        511
#define        m_flFindNextPlayerTime                        512
#define        m_flDtMultiplier                                    513
#define        m_flFlashedUntil                                514
#define        m_flFlashedAt                                    515
#define        m_flFlashHoldTime                            516
#define        m_flFlashDuration                                517
#define        m_iFlashAlpha                                    518
#define        m_flNextAutoFollowTime                    519
#define        m_szAutoBuyData[256]                        2080    //    m_szAutoBuyData[256]
#define        m_pSomeRebuyPointer                        584    //    Rebuy    stuff    CBasePlayer::Rebuy    CBasePlayer::RebuyInitData    ClientPutInServer
#define        m_iRebuyLastPrimaryItemId                585
#define        m_iRebuyLastPrimaryItemAmmo		586
#define        m_iRebuyLastSecondaryItemId			587
#define        m_iRebuyLastSecondaryItemAmmo  588
#define        m_iRebuyHEGrenadeAmmo             589
#define        m_iRebuyFlashbangAmmo				590
#define        m_iRebuySmokeGrenadeAmmo		591
#define        m_iRebuyDefuseKit							592
#define        m_iRebuyNVGoggles						593
#define        m_iRebuyKevlar								594
#define        m_bRebuyStructBuilt                            595
#define        m_flNextLocationUpdateTime                596
#define        m_szLocation                                    2388                //    597-604    m_szLocation[28]    
#define        m_flProgressBarStartTime                    605
#define        m_flProgressBarEndTime                    606
#define        m_boolsObserver607                            607    //    m_bObserverAutoDirector    (1<<0)    //    m_bCanSwitchObserverModes    (1<<8)
#define        m_bObserverAutoDirector                    2428    //    [g/s]et_pdata_bool
#define        m_bCanSwitchObserverModes            2429    //    [g/s]et_pdata_bool
//    608
#define        m_flIntense                                        609    win    //    ?void?    CBasePlayer::Intense()    {    m_flIntense    =    gpGlobals->time    }
//    610
//    611
#define        m_flNextSayTime                                612
#define        m_flNextSayTeamTime                        613
#define        m_flNextFullUpdateTime                        614
#define        m_flNextVoteTimeCmd                        615
#define        m_flNextVoteMapTime                        616
#define        m_flNextListMapsTime                        617
#define        m_flNextListPlayersTime                    618
#define        m_flNextNightVisionTime                    619    