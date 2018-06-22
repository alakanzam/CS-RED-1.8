
    /*
        AMX Mod X script.

        � Author  : Arkshine
        � Plugin  : Infinite Round
        � Version : v2.0

        (!) Support : http://forums.alliedmods.net/showthread.php?t=120866

        This plugin is free software; you can redistribute it and/or modify it
        under the terms of the GNU General Public License as published by the
        Free Software Foundation; either version 2 of the License, or (at
        your option) any later version.

        This plugin is distributed in the hope that it will be useful, but
        WITHOUT ANY WARRANTY; without even the implied warranty of
        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
        General Public License for more details.

        You should have received a copy of the GNU General Public License
        along with this plugin; if not, write to the Free Software Foundation,
        Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA


        � DESCRIPTION

            With this plugin the round never ends whatever the situation.
            It doesn't use bots like others plugins, it just do some tricks using the CS functions.

            As feature, you can choose what round end type you want to block.

        � REQUIREMENT

            * CS 1.6 / CZ.
            * AMX Mod X 1.8.x or higher.
            * Orpheu 2.3 and higher.
            * Cvar Utilities 1.3.x and higher.

        � CVAR

            * ir_block_roundend <Flags|*> (default: "*" ; meaning block all )

                What round type you wish to block.
                If you want to block all, it's recommended to use "*" as value.

                a - Round Time Expired
                b - Bomb Exploded
                c - Bomb Defused
                d - Hostages Rescued
                e - Vip Escaped
                f - Vip Assassinated
                g - Terrorist Win
                h - CT Win
                i - Round Draw
                j - Terrorists Escaped
                k - CTs Prevent Escape

                Flags are additive. Example : ir_block_roundend "ah"

            * ir_block_gamecommencing 0/1 (default: "0")

                Whether you want to block GameCommencing be triggered.

            * ir_active_api 0/1 (default: "0")

                Whether you want to activate the API or not.

        � API

            * forward OnRoundEnd( const RoundEndType:type );

                A forward called when a round end has been triggered.

        � CHANGELOG

            v2.0   : [ 26 sep 2011 ]

                Rewrite from scratch.

                New change

                    Now you can choose what round end type you want to block.
                    See 'ir_block_roundend' cvar.

                API

                    Added a forward called when a round end has been triggered.

            v1.0.2 : [ 27 jan 2011 ]

                New change

                    Patchs are now done only at server start instead of each map change/restart.

            v1.0.1 : [ 20 mar 2010 ]

                Bug

                    Fixed sv_accelerate/sv_friction/sv_stopspeed were resetted to their original value after using sv_restart[round].
                    Fixed the signature in the ReadMultiplayCvars file was incorrect + another typo. (linux)

            v1.0   : [ 9 mar 2010 ]

                Initial release.

    - - - - - - - - - - - */

    #include <amxmodx>

    #if AMXX_VERSION_NUM < 182
        #assert AMX Mod X 1.8.2+ required ! \
        Download it at : http://www.amxmodx.org/snapshots.php
    #endif

    #include <fakemeta>
    #include <engine>

    #tryinclude <celltravtrie>
    #tryinclude <orpheu>
    #tryinclude <orpheu_memory>
    #tryinclude <orpheu_advanced>
    #tryinclude <cvar_util>

    #if !defined _cell_travtrie_included
        #assert celltravtrie.inc library required ! \
        Download it at : https://forums.alliedmods.net/showthread.php?t=74753
    #endif

    #if !defined _cvar_util_included
        #assert cvar_util.inc library required ! \
        Download it at : https://forums.alliedmods.net/showthread.php?t=154642#InstallationFiles
    #endif

    #if !defined _orpheu_included || !defined _orpheu_memory_included || !defined _orpheu_advanced_included
        #assert orpheu.inc/orpheu_memory.inc/orpheu_advanced.inc libraries required! \
        Download them at https://forums.alliedmods.net/showthread.php?t=116393
    #endif

    /*
        � PLUGIN
    */
        new const PluginName   [] = "Infinite Round";
        new const PluginVersion[] = "2.0";
        new const PluginAuhtor [] = "Arkshine";

    /*
        | GENERAL

    */  #define ArrayCopy(%1,%2,%3)  ( arrayCopy( %1, %2, %3, .intoTag = tagof %1, .fromTag = tagof %2 ) )
        #define IsPlayer(%1)         ( 1 <= %1 <= MaxClients )

        const PrivateDataSafe = 2;

        new MaxClients;

        new CvarActiveAPI;
        new CvarBlockGameCommencing;
        new CvarBlockGameScoring;

    /*
        | MAP TYPE
    */
        enum MapType ( <<= 1 )
        {
            MapType_VipAssasination = 1,
            MapType_Bomb,
            MapType_Hostage,
            MapType_PrisonEscape
        };

        new MapType:CurrentMapType;

    /*
        | ROUND END TYPE
    */
        enum RoundEndType ( <<= 1 )
        {
            RoundEndType_RoundTimeExpired = 1,  // a
            RoundEndType_BombExploded,          // b
            RoundEndType_BombDefused,           // c
            RoundEndType_HostagesRescued,       // d
            RoundEndType_VipEscaped,            // e
            RoundEndType_VipAssassinated,       // f
            RoundEndType_TerroristWin,          // g
            RoundEndType_CTWin,                 // h
            RoundEndType_RoundDraw,             // i
            RoundEndType_TerroristsEscaped,     // j
            RoundEndType_CTsPreventEscape,      // k
        };

        new RoundEndType:BlockRoundEndStatus;

        const RoundEndType:Invalid_RoundEndType = RoundEndType:0;
        const RoundEndType:RoundEndType_All     = RoundEndType - RoundEndType:1;

        const RoundEndType:RoundEndTypes_Bomb   = RoundEndType_BombExploded      | RoundEndType_BombDefused;
        const RoundEndType:RoundEndTypes_Vip    = RoundEndType_VipEscaped        | RoundEndType_VipAssassinated;
        const RoundEndType:RoundEndTypes_Team   = RoundEndType_TerroristWin      | RoundEndType_CTWin;
        const RoundEndType:RoundEndTypes_Prison = RoundEndType_TerroristsEscaped | RoundEndType_CTsPreventEscape;
        const RoundEndType:RoundEndTypes_Others = RoundEndType_HostagesRescued   | RoundEndType_RoundDraw;

    /*
        | ROUND END HANDLING
    */
        new OrpheuHook:HandleHookCheckMapConditions;
        new OrpheuHook:HandleHookHasRoundTimeExpired;
        new OrpheuHook:HandleHookCheckWinConditionsPre;
        new OrpheuHook:HandleHookCheckWinConditionsPos;

        enum GameRulesMembers
        {
            m_iRoundWinStatus,
            m_bFirstConnected,
            m_bMapHasBombTarget,
            m_bBombDefused,
            m_bTargetBombed,
            m_iHostagesRescued,
            m_bMapHasRescueZone,
            m_iMapHasVIPSafetyZone,
            m_bMapHasEscapeZone,
            m_pVIP,
            m_iNumTerrorist,
            m_iNumSpawnableTerrorist,
            m_iNumCT,
            m_iNumSpawnableCT,
            m_iHaveEscaped,
            m_iNumEscapers,
            m_flRequiredEscapeRatio,
        };

        new const GameRulesMI[ GameRulesMembers ][] =
        {
            "m_iRoundWinStatus",
            "m_bFirstConnected",
            "m_bMapHasBombTarget",
            "m_bBombDefused",
            "m_bTargetBombed",
            "m_iHostagesRescued",
            "m_bMapHasRescueZone",
            "m_iMapHasVIPSafetyZone",
            "m_bMapHasEscapeZone",
            "m_pVIP",
            "m_iNumTerrorist",
            "m_iNumSpawnableTerrorist",
            "m_iNumCT",
            "m_iNumSpawnableCT",
            "m_iHaveEscaped",
            "m_iNumEscapers",
            "m_flRequiredEscapeRatio"
        };

        new g_pGameRules;

        #define set_mp_pdata(%1,%2)  ( OrpheuMemorySetAtAddress( g_pGameRules, GameRulesMI[ %1 ], 1, %2 ) )
        #define get_mp_pdata(%1)     ( OrpheuMemoryGetAtAddress( g_pGameRules, GameRulesMI[ %1 ] ) )

        const MaxIdentLength = 64;
        const MaxBytes = 100;

        new Trie:TrieMemoryPatches;
        new Trie:TrieSigsNotFound;

        enum PatchError
        {
            bool:Active,
            bool:SigFound,
            bool:BrokenFlow,
            CurrIdent[ MaxIdentLength ],
            Attempts,
            FuncIndex
        };

        enum PatchFunction
        {
            RoundTime,
        };

        enum _:Patch
        {
            OldBytes[ MaxBytes ],
            NewBytes[ MaxBytes ],
            NumBytes,
            Address
        };

        new ErrorFilter[ PatchError ];
        new bool:SignatureFound[ PatchFunction ];
        new PatchesDatas[ Patch ];

        new NumDeadTerrorist;
        new NumAliveTerrorist;
        new NumDeadCT;
        new NumAliveCT;

        new szRoundEndFlag[32]
        new iBlockRoundEndCvar
    /*
        | API
    */
        new HandleForwardRoundEnd;
        new ForwardResult;

        forward OnRoundEnd( const RoundEndType:objective );


    /*
     �  +-------------------------+
     �  �  PLUGIN MAIN FUNCTIONS  �
     �  +-------------------------+
     �       ? plugin_precache
     �           + OnInstallGameRules
     �       ? plugin_init
     �           + handleCvar �
     �           + handleObjective �
     �           + handleError �
     �           + handleAPI �
     �           + handleConfig �
     �       ? plugin_pause
     �           + undoAllPatches �
     �           + unregisterAllForwards �
     �       ? plugin_unpause
     �           + handleObjective �
     �           + handleForward �
     �       ? plugin_end
     �           + undoAllPatches �
     �           + unregisterAllForwards �
     */

    public plugin_natives()
    {
        register_native("ir_block_round_end", "nt_ir_block_round_end", 1)
    }
    
    public nt_ir_block_round_end(szFlag[])
    {
        param_convert(1)
        formatex(szRoundEndFlag, sizeof szRoundEndFlag - 1, szFlag)
        CvarDisableLock(iBlockRoundEndCvar)
        set_pcvar_string(iBlockRoundEndCvar, szRoundEndFlag)
        CvarLockValue(iBlockRoundEndCvar, szRoundEndFlag)
        CvarEnableLock(iBlockRoundEndCvar)
    }
    public plugin_precache()
    {
        OrpheuRegisterHook( OrpheuGetFunction( "InstallGameRules" ), "OnInstallGameRules", OrpheuHookPost );
    }

    public OnInstallGameRules()
    {
        g_pGameRules = OrpheuGetReturn();
    }

    public plugin_init()
    {
        register_plugin( PluginName, PluginVersion, PluginAuhtor );

        MaxClients = get_maxplayers();

        handleCvar();
        handleObjective();
        handleError();
        handleAPI();
        handleConfig();
    }

    public plugin_pause()
    {
        undoAllPatches();
        unregisterAllForwards();
    }

    public plugin_unpause()
    {
        handleObjective();
        handleConfig();
    }

    public plugin_end()
    {
        undoAllPatches();
        unregisterAllForwards();
    }

    /*
     �  +-------------------+
     �  �  CONFIG HANDLING  �
     �  +-------------------+
     �       ? handleCvar
     �       ? handleObjective
     �       ? handleError
     �       ? handleConfig
     �       ? handleAPI
     */

    handleCvar()
    {
        CvarRegister( "infiniteround_version", PluginVersion, "- Help to track who is using the plugin", FCVAR_SERVER | FCVAR_SPONLY );

        formatex(szRoundEndFlag, sizeof szRoundEndFlag - 1, "|")
        iBlockRoundEndCvar =  CvarRegister( "ir_block_roundend" , szRoundEndFlag)
        CvarHookChange(iBlockRoundEndCvar, "OnCvarChange" )
        CvarLockValue(iBlockRoundEndCvar, szRoundEndFlag)
        CvarEnableLock(iBlockRoundEndCvar)
        CvarCache( CvarRegisterBoolean( "ir_block_gamecommencing", "0", "- Whether you want to block GameCommencing be triggered." ), CvarType_Int, CvarBlockGameCommencing );
        CvarCache( CvarRegisterBoolean( "ir_block_gamescoring"   , "0", "- Whether you want to block GameScoring be triggered." ), CvarType_Int, CvarBlockGameScoring );
        CvarCache( CvarRegisterBoolean( "ir_active_api"          , "0", "- Whether you want to activate or not the API" ), CvarType_Int, CvarActiveAPI );
    }

    handleObjective()
    {
        if( BlockRoundEndStatus )
        {
            static OrpheuFunction:handleFunc; handleFunc || ( handleFunc = OrpheuGetFunctionFromObject( g_pGameRules, "CheckMapConditions", "CGameRules" ) );

            HandleHookCheckMapConditions = OrpheuRegisterHook( handleFunc, "OnCheckMapConditions_Post", OrpheuHookPost );
            OrpheuCallSuper( handleFunc, g_pGameRules );
        }
    }

    // TODO: Is really needed?
    handleError()
    {
        if( !isLinuxServer() )
        {
            set_error_filter( "OnErrorFilter" );
        }
    }

    handleAPI()
    {
        HandleForwardRoundEnd = CreateMultiForward( "OnRoundEnd", ET_STOP, FP_CELL );
    }

    handleConfig()
    {
        if( BlockRoundEndStatus > Invalid_RoundEndType )
        {
            if( BlockRoundEndStatus & RoundEndType_RoundTimeExpired )
            {
                if( isLinuxServer() )
                {
                    HandleHookHasRoundTimeExpired = OrpheuRegisterHook( OrpheuGetFunction( "HasRoundTimeExpired" , "CHalfLifeMultiplay" ), "OnHasRoundTimeExpired" );
                }
                else
                {   // Windows - The constent of CHalfLifeMultiplay::HasRoundTimeExpired() is somehow integrated in CHalfLifeMultiplay::Think(),
                    // the function can't be hook and therefore we must patch some bytes directly into this function to avoid the check.
                    patchRoundTime .undo = false;
                }
            }

            if( BlockRoundEndStatus & ~RoundEndType_RoundTimeExpired )
            {
                static OrpheuFunction:handleFunc; handleFunc || ( handleFunc = OrpheuGetFunctionFromObject( g_pGameRules, "CheckWinConditions", "CGameRules" ) );
                HandleHookCheckWinConditionsPre = OrpheuRegisterHook( handleFunc, "OnCheckWinConditions_Pre" , OrpheuHookPre );
            }
        }
    }


    /*
     �  +---------------------+
     �  �  MAP TYPE HANDLING  �
     �  +---------------------+
     �       ? OnCheckMapConditions_Post()
     */

    public OnCheckMapConditions_Post( const handleGameRules )
    {
        if( get_mp_pdata( m_iMapHasVIPSafetyZone ) == 1 )
        {
            CurrentMapType |= MapType_VipAssasination;
        }

        if( get_mp_pdata( m_bMapHasBombTarget ) )
        {
            CurrentMapType |= MapType_Bomb;
        }

        if( get_mp_pdata( m_bMapHasRescueZone ) )
        {
            CurrentMapType |= MapType_Hostage;
        }

        if( get_mp_pdata( m_bMapHasEscapeZone ) )
        {
            CurrentMapType |= MapType_PrisonEscape;
        }
    }


    /*
     �  +---------------------------+
     �  �  ROUND END TYPE HANDLING  �
     �  +---------------------------+
     �       ? isGameCommencing
     �       ? OnHasRoundTimeExpired
     �       ? OnCheckWinConditions_Pre
     �           + initializePlayerCounts
     �           + VIPRoundEndCheck
     �           + PrisonRoundEndCheck
     �           + BombRoundEndCheck
     �           + TeamExterminationCheck
     �           + HostageRescuedRoundEndCheck
     �       ? patchRoundTime
     �           + getPatchDatas
     �           + prepareData
     �               + arrayCopy �
     �               + getBytes �
     �               + getStartAddress �
     �               + setErrorFilter �
     �           + checkFlow �
     �           + setErrorFilter �
     �           + replaceBytes �
     */

    public OrpheuHookReturn:OnHasRoundTimeExpired( const handleGameRules )
    {
        return OrpheuSupercede;
    }

    public OrpheuHookReturn:OnCheckWinConditions_Pre( const handleGameRules )
    {
        if( get_mp_pdata( m_bFirstConnected ) && get_mp_pdata( m_iRoundWinStatus ) )
        {
            return OrpheuIgnored;
        }

        NumDeadTerrorist  = 0;
        NumAliveTerrorist = 0;
        NumDeadCT         = 0;
        NumAliveCT        = 0;

        initializePlayerCounts( NumDeadTerrorist, NumAliveTerrorist, NumDeadCT, NumAliveCT );

        if( isGameScoring() )
        {
            return CvarBlockGameScoring ? OrpheuSupercede : OrpheuIgnored;
        }
        
        if( isGameCommencing() )
        {
            return CvarBlockGameCommencing ? OrpheuSupercede : OrpheuIgnored;
        }

        if( !CvarActiveAPI && BlockRoundEndStatus == RoundEndType_All )
        {
            return OrpheuSupercede;
        }

        if( vipRoundEndCheck() || prisonRoundEndCheck() || bombRoundEndCheck() || teamExterminationCheck() || hostageRescuedRoundEndCheck() )
        {
            return OrpheuSupercede;
        }

        return OrpheuIgnored;
    }

    initializePlayerCounts( &numDeadTerrorist, &numAliveTerrorist, &numDeadCT, &numAliveCT )
    {
        const TEAM_TERRORIST = 1;
        const TEAM_CT        = 2;

        const m_iTeam = 114;
        const m_iMenu = 205;
        const m_fVIP  = 209;

        const MenuId_ChooseAppearance = 3;
        const VipState_HasEscaped = ( 1<<0 );

        set_mp_pdata( m_iNumTerrorist, 0 );
        set_mp_pdata( m_iNumSpawnableTerrorist, 0 );
        set_mp_pdata( m_iNumCT, 0 );
        set_mp_pdata( m_iNumSpawnableCT, 0 );

        for( new i = 1; i <= MaxClients; i++ )
        {
            if( pev_valid( i ) == PrivateDataSafe && ~pev( i, pev_flags ) & FL_DORMANT )
            {
                switch( get_pdata_int( i, m_iTeam ) )
                {
                    case TEAM_TERRORIST :
                    {
                        set_mp_pdata( m_iNumTerrorist, get_mp_pdata( m_iNumTerrorist ) + 1 );

                        if( get_pdata_int( i, m_iMenu ) != MenuId_ChooseAppearance )
                        {
                            set_mp_pdata( m_iNumSpawnableTerrorist, get_mp_pdata( m_iNumSpawnableTerrorist ) + 1 );
                        }

                        pev( i, pev_deadflag ) ? numDeadTerrorist++ : numAliveTerrorist++;

                        if( get_pdata_int( i, m_fVIP ) & VipState_HasEscaped )
                        {
                            set_mp_pdata( m_iHaveEscaped, get_mp_pdata( m_iHaveEscaped ) + 1 );
                        }
                    }
                    case TEAM_CT :
                    {
                        set_mp_pdata( m_iNumCT, get_mp_pdata( m_iNumCT ) + 1 );

                        if( get_pdata_int( i, m_iMenu ) != MenuId_ChooseAppearance )
                        {
                            set_mp_pdata( m_iNumSpawnableCT, get_mp_pdata( m_iNumSpawnableCT ) + 1 );
                        }

                        pev( i, pev_deadflag ) ? numDeadCT++ : numAliveCT++;
                    }
                }
            }
        }
    }

    bool:isGameScoring()
    {
        return !get_mp_pdata( m_iNumSpawnableTerrorist ) || !get_mp_pdata( m_iNumSpawnableCT );
    }
    
    bool:isGameCommencing()
    {
        return !get_mp_pdata( m_bFirstConnected ) && get_mp_pdata( m_iNumSpawnableTerrorist ) && get_mp_pdata( m_iNumSpawnableCT );
    }

    bool:vipRoundEndCheck()
    {
        if( CurrentMapType & MapType_VipAssasination && get_mp_pdata( m_iMapHasVIPSafetyZone ) )
        {
            new vip = get_mp_pdata( m_pVIP );

            if( IsPlayer( vip ) && pev_valid( vip ) == PrivateDataSafe )
            {
                const m_fVIP  = 209;
                const VipState_HasEscaped = ( 1<<0 );

                if( get_pdata_int( vip, m_fVIP ) & VipState_HasEscaped )
                {
                    return executeForward( RoundEndType_VipEscaped );
                }
                else if( pev( vip, pev_deadflag ) )
                {
                    return executeForward( RoundEndType_VipAssassinated );
                }
            }
        }

        return false;
    }

    bool:prisonRoundEndCheck()
    {
        if( CurrentMapType & MapType_PrisonEscape && get_mp_pdata( m_bMapHasEscapeZone ) )
        {
            new Float:escapeRatio = float( get_mp_pdata( m_iHaveEscaped ) ) / float( get_mp_pdata( m_iNumEscapers ) );
            new Float:requiredEscapeRatio = Float:get_mp_pdata( m_flRequiredEscapeRatio );

            if( escapeRatio >= requiredEscapeRatio )
            {
                return executeForward( RoundEndType_TerroristsEscaped );
            }
            else if( !NumAliveTerrorist && escapeRatio < requiredEscapeRatio )
            {
                return executeForward( RoundEndType_CTsPreventEscape );
            }
        }

        return false;
    }

    bool:bombRoundEndCheck()
    {
        if( CurrentMapType & MapType_Bomb && get_mp_pdata( m_bMapHasBombTarget ) )
        {
            if( get_mp_pdata( m_bTargetBombed ) )
            {
                return executeForward( RoundEndType_BombExploded );
            }
            else if( get_mp_pdata( m_bBombDefused ) )
            {
                return executeForward( RoundEndType_BombDefused );
            }
        }

        return false;
    }

    bool:teamExterminationCheck()
    {
        if( get_mp_pdata( m_iNumCT ) > 0 && get_mp_pdata( m_iNumSpawnableCT ) > 0 && get_mp_pdata( m_iNumTerrorist ) > 0 && get_mp_pdata( m_iNumSpawnableTerrorist ) > 0 )
        {
            if( !NumAliveTerrorist && NumDeadTerrorist != 0 && get_mp_pdata( m_iNumSpawnableCT ) > 0 )
            {
                new grenade;
                new bool:noExplosion;

                const m_fBombState = 96;
                const m_flC4Blow   = 100;
                const BombState_C4Planted = ( 1<<8 );

                while( ( grenade = find_ent_by_class( grenade, "grenade" ) ) )
                {
                    if( get_pdata_int( grenade, m_fBombState ) & BombState_C4Planted && !get_pdata_int( grenade, m_flC4Blow ) )
                    {
                        noExplosion = true;
                    }
                }

                if( !noExplosion )
                {
                    return executeForward( RoundEndType_CTWin );
                }

                return true;
            }

            if( !NumAliveCT && NumDeadCT != 0 && get_mp_pdata( m_iNumSpawnableTerrorist ) > 0 )
            {
                return executeForward( RoundEndType_TerroristWin );
            }
        }
        else if( NumAliveCT <= 0 && NumAliveTerrorist <= 0 )
        {
            return executeForward( RoundEndType_RoundDraw );
        }

        return false;
    }

    bool:hostageRescuedRoundEndCheck()
    {
        static hostage;            hostage       = FM_NULLENT;
        static hostagesCount;      hostagesCount = 0;
        static bool:hostageAlive;  hostageAlive  = false;

        while( ( hostage = find_ent_by_class( hostage, "hostage_entity" ) ) )
        {
            hostagesCount++;

            if( pev_valid( hostage ) && pev( hostage, pev_takedamage ) == DAMAGE_YES )
            {
                hostageAlive = true;
                break;
            }
        }

        if( !hostageAlive && hostagesCount > 0 && get_mp_pdata( m_iHostagesRescued ) >= hostagesCount * 0.5 )
        {
            return executeForward( RoundEndType_HostagesRescued );
        }

        return false;
    }

    // TODO: Check this.
    public patchRoundTime( const bool:undo )
    {
        static const keyName[] = "RoundTime";
        static funcIndex; funcIndex || ( funcIndex = funcidx( "patchRoundTime" ) );

        static bool:hasBackup;
        static bool:patched;

        if( !undo )
        {
            if( !hasBackup )
            {
                if( SignatureFound[ RoundTime ] )
                {
                    return;
                }

                const numBytes = 5;

                new const bytesToPath[ numBytes ] =
                {
                    0x90, 0x90, 0x90, 0x90,  /* nop ...  */
                    0xE9                     /* call ... */
                };

                setErrorFilter( .active = true, .attempts = 2, .functionIndex = funcIndex );

                prepareData( RoundTime, keyName, "RoundTimeCheck_#1", bytesToPath, sizeof bytesToPath );
                prepareData( RoundTime, keyName, "RoundTimeCheck_#2", bytesToPath, sizeof bytesToPath );

                hasBackup = true;
            }

            if( !patched && getPatchDatas( keyName ) )
            {
                replaceBytes( PatchesDatas[ Address ], PatchesDatas[ NewBytes ], PatchesDatas[ NumBytes ] );
                patched = true;

                checkFlow();
            }
        }
        else if( hasBackup && patched && getPatchDatas( keyName ) )
        {
            replaceBytes( PatchesDatas[ Address ], PatchesDatas[ OldBytes ], PatchesDatas[ NumBytes ] );
            patched = false;
        }
    }

    bool:getPatchDatas( const keyName[] )
    {
        return TrieGetArray( TrieMemoryPatches, keyName, PatchesDatas, sizeof PatchesDatas );
    }

    prepareData( const PatchFunction:function, const keyName[], const memoryIdent[], const bytesList[], const bytesCount )
    {
        if( ErrorFilter[ SigFound ] )
        {
            return;
        }

        TrieMemoryPatches || ( TrieMemoryPatches = TrieCreate() );
        TrieSigsNotFound  || ( TrieSigsNotFound  = TrieCreate() );

        if( TrieKeyExists( TrieSigsNotFound, memoryIdent ) )
        {
            return;
        }

        copy( ErrorFilter[ CurrIdent ], charsmax( ErrorFilter[ CurrIdent ] ), memoryIdent );

        new address = getStartAddress( memoryIdent );

        if( address )
        {
            setErrorFilter( .active = false, .sigFound = SignatureFound[ function ] = true );

            getBytes( address, PatchesDatas[ OldBytes ], bytesCount );
            arrayCopy( .into = PatchesDatas[ NewBytes ], .from = bytesList, .len = bytesCount, .ignoreTags = false, .intoSize = sizeof PatchesDatas[ NewBytes ], .fromSize = bytesCount );

            PatchesDatas[ NumBytes ] = bytesCount;
            PatchesDatas[ Address  ] = address;

            TrieSetArray( TrieMemoryPatches, keyName, PatchesDatas, sizeof PatchesDatas );
        }
    }


    /*
     �  +-------------------------+
     �  �  ERROR FILTER HANDLING  �
     �  +-------------------------+
     �       ? OnErrorFilter
     �           + Task_ResumeFlow
     �       ? setErrorFilter
     �       ? checkFlow
     �           + handlePatch �
     */

    public OnErrorFilter( const error, const bool:debugging, const message[] )
    {
        static const messageSigNotFound[] = "[ORPHEU] Signature not found in memory";

        if( error == AMX_ERR_NATIVE && ErrorFilter[ Active ] && equal( message, messageSigNotFound, sizeof messageSigNotFound ) )
        {
            if( --ErrorFilter[ Attempts ] <= 0 )
            {
                plugin_pause();
                pause( "ad" );

                return PLUGIN_CONTINUE;
            }

            ErrorFilter[ BrokenFlow ] = true;

            TrieSetCell( TrieSigsNotFound, ErrorFilter[ CurrIdent ], true );
            set_task( 0.1, "Task_ResumeFlow" );

            return PLUGIN_HANDLED;
        }

        return PLUGIN_CONTINUE;
    }

    public Task_ResumeFlow()
    {
        callfunc_begin_i( ErrorFilter[ FuncIndex ] );
        callfunc_push_int( false );
        callfunc_end();
    }

    setErrorFilter( const bool:active = false, const attempts = 0, const bool:sigFound = false, const functionIndex = 0 )
    {
        if( active && ErrorFilter[ Active ] )
        {
            return;
        }

        ErrorFilter[ Active    ] = active;
        ErrorFilter[ Attempts  ] = attempts;
        ErrorFilter[ FuncIndex ] = functionIndex;
        ErrorFilter[ SigFound  ] = sigFound;
    }

    checkFlow()
    {
        if( ErrorFilter[ BrokenFlow ] )
        {
            ErrorFilter[ BrokenFlow ] = false;
            handleConfig();
        }
    }


    /*
     �  +----------------+
     �  �  API HANDLING  �
     �  +----------------+
     �       ? executeForward
     */

    bool:executeForward( const RoundEndType:objective )
    {
        new bool:shouldBlock;

        if( CvarActiveAPI )
        {
            ExecuteForward( HandleForwardRoundEnd, ForwardResult, objective );

            if( BlockRoundEndStatus & objective || ForwardResult >= PLUGIN_HANDLED )
            {
                shouldBlock = true;
            }
        }
        else if( BlockRoundEndStatus & objective )
        {
            shouldBlock = true;
        }

        if( shouldBlock )
        {
            switch( objective )
            {
                case RoundEndType_BombDefused :
                {
                    set_mp_pdata( m_bBombDefused, false );
                }
                case RoundEndType_BombExploded :
                {
                    set_mp_pdata( m_bTargetBombed, false );
                }
                case RoundEndType_HostagesRescued :
                {
                    set_mp_pdata( m_iHostagesRescued, 0 );
                }
                case RoundEndType_CTsPreventEscape, RoundEndType_TerroristsEscaped :
                {
                    set_mp_pdata( m_iHaveEscaped, 0 );
                    set_mp_pdata( m_iNumEscapers, 0 );
                }
            }

            return true;
        }

        return false;
    }


    /*
     �  +--------------------------+
     �  �  PLUGIN CHANGE HANDLING  �
     �  +--------------------------+
     �       ? OnCvarChange
     �       ? unregisterAllForwards
     �       ? undoAllPatches
     */

    public OnCvarChange( const handleVar, const oldValue[], const newValue[], const cvarName[] )
    {
         
        BlockRoundEndStatus = newValue[ 0 ] == '*' ? RoundEndType_All : RoundEndType:read_flags( newValue );

        static bool:ignoreFirstCall = true;

        if( ignoreFirstCall )
        {
            ignoreFirstCall = false;
            return;
        }

        undoAllPatches();
        unregisterAllForwards();

        if( BlockRoundEndStatus )
        {
            handleObjective();
            handleConfig();
        }
    }

    unregisterAllForwards()
    {
        if( HandleHookCheckMapConditions )
        {
            OrpheuUnregisterHook( HandleHookCheckMapConditions );
        }

        if( HandleHookHasRoundTimeExpired )
        {
            OrpheuUnregisterHook( HandleHookHasRoundTimeExpired );
        }

        if( HandleHookCheckWinConditionsPre )
        {
            OrpheuUnregisterHook( HandleHookCheckWinConditionsPre );
        }

        if( HandleHookCheckWinConditionsPos )
        {
            OrpheuUnregisterHook( HandleHookCheckWinConditionsPos );
        }
    }

    undoAllPatches()
    {
        patchRoundTime .undo = true;
    }


    /*
     �  +----------------------------+
     �  �  GENERIC USEFUL FUNCTIONS  �
     �  +----------------------------+
     �       ? getStartAddress
     �       ? getBytes
     �       ? replaceBytes
     �       ? isLinuxServer
     �       ? arrayCopy
     */

    getStartAddress( const identifier[] )
    {
        new address;
        OrpheuMemoryGet( identifier, address );

        return address;
    }

    getBytes( const startAddress, bytesList[], const numBytes )
    {
        new const dataType[] = "byte";
        new address = startAddress;

        for( new i = 0; i < numBytes; i++ )
        {
            bytesList[ i ] = OrpheuMemoryGetAtAddress( address, dataType, address );
            address++;
        }
    }

    replaceBytes( const startAddress, const bytes[], const numBytes )
    {
        static const dataType[] = "byte";

        new address = startAddress;

        for( new i = 0; i < numBytes; i++)
        {
            OrpheuMemorySetAtAddress( address, dataType, 1, bytes[ i ], address );
            address++;
        }
    }

    bool:isLinuxServer()
    {
        static bool:result;
        return result || ( result = bool:is_linux_server() );
    }

    // Tirant/Emp'.
    arrayCopy( any:into[], const any:from[], len, bool:ignoreTags = false,
                intoTag = tagof into, intoSize = sizeof into, intoPos = 0,
                fromTag = tagof from, fromSize = sizeof from, fromPos = 0 )
    {
        if( !ignoreTags && intoTag != fromTag )
        {
            return 0;
        }

        new i;

        while( i < len )
        {
            if( intoPos >= intoSize || fromPos >= fromSize )
            {
                break;
            }

            into[ intoPos++ ] = from[ fromPos++ ];
            i++;
        }

        return i;
    }

    stock getEngineBuildVersion()
    {
        static buildVersion;

        if( !buildVersion )
        {
            new version[ 32 ];
            get_cvar_string( "sv_version", version, charsmax( version ) );

            new length = strlen( version );
            while( version[ --length ] != ',' ) {}

            buildVersion = str_to_num( version[ length + 1 ] );
        }

        return buildVersion;
    }

