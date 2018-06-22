/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <fakemeta_util>
#include <cstrike>
#include <hamsandwich>
#include <cvar_util>

#include <cstrike_pdatas>

#include <infinitive_round>
#include <round_terminator>

#include <RandomRespawn>
#include <SDK_Hook>
#include <player_api>

#include <GamePlay_Included/TFM_ZombieMod.inc>
#include <GamePlay_Included/IntegerConstant.inc>


#define PLUGIN "[GAME-PLAY] Zombie Mod 3"
#define VERSION "-No Info-"
#define AUTHOR "Redplane"


new GAMEPLAY_NAME[] =	"Zombie Mod 3"
new GAMEPLAY_MAP_PREFIX[] = "zm3_"

#define TASK_BOT_FUNC	1000
#define TASK_ZOMBIE_SELECTION	2000
#define TASK_HERO_SELECTION	3000
#define TASK_RESET_MODEL	4000
#define TASK_ZOMBIE_RESPAWN	5000
#define TASK_ZOMBIE_HEAL	6000

/*	Constant	*/
new ZB_SELECTION_TIME	= 20
#define ZB_ROUND_TIME	3.0
#define ZB_HP_BONUS	300.0
#define ZB_HEALING_TIME	3.0

#define MAX_EVOLUTION_LEVEL	11




#define SOUND_EVOLUTION_FEMALE	"TFM_Zombie/EVOLUTION/ZombieEvolution_Female.wav"
#define SOUND_EVOLUTION_MALE	"TFM_Zombie/EVOLUTION/ZombieEvolution_Male.wav"

#define SOUND_HEALTH_REGAIN_MALE	"TFM_Zombie/HealthRegain/RegainHealthMale-1.wav"
#define SOUND_HEALTH_REGAIN_FEMALE	"TFM_Zombie/HealthRegain/RegainHealthFemale-1.wav"


/************************/
new iCvar_MaxRound



new iMaxRound
new iGameExit
new iHamCz


new iBonus_Damage
new iMaxPlayers

//	Forwards

new ifw_PlayerBecomeHero
new ifw_UpgradeDamage
new ifw_UpgradeEvolutionLevel

new ifw_Result

stock const LOCKED_CVAR[][] = {
	"mp_friendlyfire",
	"mp_freezetime"
}
	
stock const LOCKED_VALUE[][] = {
	"0",
	"1.0"
}
	
	
#define SetPlayerBit(%1,%2)      (%1 |= (1<<(%2&31)))
#define ClearPlayerBit(%1,%2)    (%1 &= ~(1 <<(%2&31)))
#define CheckPlayerBit(%1,%2)    (%1 & (1<<(%2&31)))	

/*		BIT FIELD		*/
new bit_IsHero
new bit_RespawnAsZombie

/*		SPRITE INDEX		*/

new iSPRID_Respawn

/*		MESSAGE ID		*/
new iMSGID_ScreenFade

/*		SPRITE FILE		*/
#define RESPAWN_SPRITE "sprites/ZombieMod3/ZM3_RESPAWN.spr"

/*		ARRAY			*/
new iArray_Level[33]

/*			NATIVE SECTIONS			*/
public plugin_natives()
{
	register_native("ZM3_get_damage_plus", "nt_ZM3_get_damage_plus", 1)
	register_native("ZM3_is_user_hero", "nt_ZM3_is_user_hero", 1)
	register_native("ZM3_get_evolution_stage", "nt_ZM3_get_evolution_stage", 1)
	
}

public nt_ZM3_get_damage_plus()
	return iBonus_Damage

public nt_ZM3_is_user_hero(id)
	return CheckPlayerBit(bit_IsHero ,id)
	
public nt_ZM3_get_evolution_stage(id)
	return iArray_Level[id]
	
/********************************************************/

public TFM_EnableRegisterGamePlay()
{
	zp_register_gameplay(ZB_GAMEPLAY_ZM3, GAMEPLAY_NAME, GAMEPLAY_MAP_PREFIX, sizeof GAMEPLAY_MAP_PREFIX)
	iCvar_MaxRound = register_cvar("ZombieMod/GamePlay/ZM3/MaxRound", "9")
	iGameExit = 0
}

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	
	RegisterHam(Ham_TakeDamage, "player", "fw_PlayerTakeDamage")
	RegisterHam(Ham_TraceAttack, "player", "fw_PlayerTraceAttack")
	
	
	iHamCz = 0
	
}

public plugin_cfg()
{
	if (!is_zm3_on())
	{
		set_fail_state("[GAMEPLAY] Zombie Mod 3 is turned OFF")
		return
	}
	
	/*	Forward creating	*/
	
	ifw_PlayerBecomeHero = CreateMultiForward("ZM3_PlayerBecomeHero", ET_IGNORE, FP_CELL)
	ifw_UpgradeDamage = CreateMultiForward("ZM3_DamageUpdated", ET_IGNORE, FP_CELL)
	ifw_UpgradeEvolutionLevel = CreateMultiForward("ZM3_EvolutionUpdated", ET_IGNORE, FP_CELL, FP_CELL)
	
	/*	Message id retreiving	*/
	iMSGID_ScreenFade = get_user_msgid("ScreenFade")
	
	iMaxRound = get_pcvar_num(iCvar_MaxRound)
	
	if (!iMaxRound)
		iMaxRound = 9
		
	zp_set_round_time(ZB_ROUND_TIME)
	zp_set_max_score(iMaxRound)
	
	for (new iLockedId = 0; iLockedId < sizeof LOCKED_CVAR; iLockedId++)
	{
		new iCvarPointer = get_cvar_pointer(LOCKED_CVAR[iLockedId])
		CvarLockValue(iCvarPointer, LOCKED_VALUE[iLockedId])
		CvarEnableLock(iCvarPointer)
	}
	
	/*	Message section		*/
	register_message(get_user_msgid("ClCorpse"), "message_ClCorpse")
	
	
	/*	Fakemeta section	*/
	register_forward(FM_CmdStart, "fw_CmdStart")
	
	ir_block_round_end(FLAG_ALL)
	
	
	
	
	iMaxPlayers = get_maxplayers()
	
	
	/*	Precache necessary sprites and models		*/
	iSPRID_Respawn = engfunc(EngFunc_PrecacheModel, RESPAWN_SPRITE)
	
	register_dictionary("TFM_Dictionary.txt")
	
}

public client_putinserver(id)
{
	client_disconnect(id)
	
	
	if (!is_user_bot(id))
		return
		
	if (!get_cvar_num("bot_quota"))
		return
		
	if (iHamCz)
		return
		
	remove_task(id + TASK_BOT_FUNC)
	set_task(0.1, "RegisterCzFunction_TASK", id + TASK_BOT_FUNC)
	
}

public client_disconnect(id)
{
	remove_task(id + TASK_RESET_MODEL)
	remove_task(id + TASK_ZOMBIE_RESPAWN);
	remove_task(id + TASK_BOT_FUNC);
	remove_task(id + TASK_ZOMBIE_HEAL);
	
	ClearPlayerBit(bit_IsHero, id);
	ClearPlayerBit(bit_RespawnAsZombie, id)
	
}

public RegisterCzFunction_TASK(TASKID)
{
	if (iHamCz)
		return
		
	new id = TASKID - TASK_BOT_FUNC
	
	if (!is_user_connected(id))
		return
		
	if (!is_user_bot(id))
		return
		
	if (!get_cvar_num("bot_quota"))
		return
		
	if (iHamCz)
		return
		
	RegisterHamFromEntity(Ham_TakeDamage, id, "fw_PlayerTakeDamage")
	RegisterHamFromEntity(Ham_TraceAttack, id, "fw_PlayerTraceAttack")
	iHamCz = 1
	
}


public fw_PlayerTakeDamage(iVictim, iInflictor, iAttacker, Float:fDamage, iDamagebit)
{
	if (!is_zm3_on())
		return HAM_IGNORED
		
	if (!is_user_connected(iVictim))
		return HAM_IGNORED
		
	if (!is_user_connected(iAttacker))
		return HAM_IGNORED
		
	if (get_user_zombie(iVictim) && get_user_zombie(iAttacker))
		return HAM_SUPERCEDE
		
	if (!get_user_zombie(iVictim) && !get_user_zombie(iAttacker))
		return HAM_SUPERCEDE
	
	if (!get_user_zombie(iAttacker) && get_user_zombie(iVictim))
	{
		fDamage += fDamage * (20 * iBonus_Damage) / 100
		SetHamParamFloat(4, fDamage)
	}
	
	return HAM_IGNORED
}

public fw_PlayerTraceAttack(iVictim, iAttacker, Float:fDamage, Float:fDirection[3], tracehandle, damagebits)
{
	if (!is_zm3_on())
		return HAM_IGNORED
		
	if (!is_user_connected(iVictim))
		return HAM_IGNORED
		
	if (!is_user_connected(iAttacker))
		return HAM_IGNORED
		
	if (get_user_zombie(iVictim) && get_user_zombie(iAttacker))
		return HAM_SUPERCEDE
		
	if (!get_user_zombie(iVictim) && !get_user_zombie(iAttacker))
		return HAM_SUPERCEDE
		
	return HAM_IGNORED
}

public csred_PlayerKilledPost(iVictim, iKiller)
{
	if (!is_zm3_on())
		return
		
	if (zp_get_round_state() != ROUND_BEGIN)
		return
		
	if (!get_user_zombie(iVictim))
	{
		// Last soldier is killed
		
		if (fnGetHumans() < 1)
		{
			ir_block_round_end("")
			fnForceRoundEnd(TEAM_TERRORIST)
			ir_block_round_end(FLAG_ALL)
			
			zp_set_round_state(ROUND_END)
		}
		return
	}
	
	//	A Zombie was killed
	
	iBonus_Damage++
	
	if (iBonus_Damage > 5)
		iBonus_Damage = 5
	else	upgrade_damage_plus(iBonus_Damage)
	
	//	Zombie is killed by a HeadShot?
	if (get_pdata_bool(iVictim, m_bKilledByHeadShot, 5))
	{
		if (fnGetZombies() < 1)
		{
			ir_block_round_end("")
			fnForceRoundEnd(TEAM_CT)
			ir_block_round_end(FLAG_ALL)
			
			zp_set_round_state(ROUND_END)
		}
		return
	}
	
	new Float:fOrigin[3]
	pev(iVictim, pev_origin, fOrigin)
	
	fnDrawSprite(fOrigin, iSPRID_Respawn, 13, 200)
	remove_task(iVictim + TASK_ZOMBIE_RESPAWN)
	set_task(5.0, "RespawnZombie_TASK", iVictim + TASK_ZOMBIE_RESPAWN)
	
	/*		Decrease evolution level by 1			*/
	
	iArray_Level[iVictim]--
	
	if (iArray_Level[iVictim] < 0)
		iArray_Level[iVictim] = 0
		
}

/*				MESSAGE SECTION					*/

public message_ClCorpse()
{
	if (!is_zm3_on())
		return PLUGIN_CONTINUE
		
	return PLUGIN_HANDLED
}

/*********************************************************************************/


/*				FAKEMETA SECTION				*/

public fw_CmdStart(id, ucHandle, iSeed)
{
	if (!is_user_connected(id))
		return
		
	if (!is_user_alive(id))
		return
		
	if (!is_zm3_on())
		return
		
	if (!get_user_zombie(id))
		return
		
	if (zp_get_round_state() != ROUND_BEGIN)
		return
	
	new iButtonId = get_uc(ucHandle, UC_Buttons)
	
	if (iButtonMoving(iButtonId))
	{
		/* This zombie is now moving - Delete his/her Healing Task */
		if (task_exists(id + TASK_ZOMBIE_HEAL))
			remove_task(id + TASK_ZOMBIE_HEAL)
	}
	else
	{
		/* This zombie does no movements - Set healing task if he/she doesn't have */
		if (!task_exists(id + TASK_ZOMBIE_HEAL))
			set_task(ZB_HEALING_TIME, "ZombieHealing_TASK", id + TASK_ZOMBIE_HEAL)
	}
}

/*********************************************************************************/
public RoundEvent_PreBegin()
{
	if (!is_zm3_on())
		return
		
	zp_set_round_state(ROUND_END)
	set_user_countdown(0, 0, 1, 1, 1)

}

public RoundEvent_Begin()
{
	if (!is_zm3_on())
		return
		
	
	set_user_countdown(0, ZB_SELECTION_TIME, 1, 1, 1)
	new Float:fSelectionTime = float(ZB_SELECTION_TIME)
	
	remove_task(TASK_ZOMBIE_SELECTION)
	remove_task(TASK_HERO_SELECTION)
	
	set_task(fSelectionTime , "HeroSelection_TASK", TASK_HERO_SELECTION)
	
	iBonus_Damage = 0
	upgrade_damage_plus(iBonus_Damage)
	
}

public RoundEvent_CtWin()
{
	if (!is_zm3_on())
		return
	
	if (iGameExit)
		return
		
	new iScore = zp_get_score(TEAM_CT)
	iScore++
	zp_set_score(TEAM_CT, iScore)
	
	if (iScore > iMaxRound)
	{
		zp_force_game_exit(TEAM_CT)
		iGameExit = 1
	}
	
}

public RoundEvent_TerWin()
{
	if (!is_zm3_on())
		return
		
	if (iGameExit)
		return
		
	new iScore = zp_get_score(TEAM_TERRORIST)
	iScore++
	zp_set_score(TEAM_TERRORIST, iScore)
	
	if (iScore > iMaxRound)
	{
		zp_force_game_exit(TEAM_TERRORIST)
		iGameExit = 1
	}
	
}

public TFM_RoundEnd()
{
	if (!is_zm3_on())
		return PLUGIN_CONTINUE
		
	ir_block_round_end("")
	fnForceRoundEnd(TEAM_CT)
	ir_block_round_end(FLAG_ALL)
	
	return PLUGIN_HANDLED
}

public csred_PlayerSpawnPre(id)
{
	if (!is_zm3_on())
		return
	
	if (!CheckPlayerBit(bit_RespawnAsZombie, id))
		set_user_zombie(id, -1, 0, 0, 0)
	
	ClearPlayerBit(bit_IsHero, id)
}

public csred_PlayerSpawnPost(id)
{
	if (!is_zm3_on())
		return
	
	remove_task(id + TASK_ZOMBIE_RESPAWN)
	remove_task(id + TASK_RESET_MODEL)
	
	do_random_spawn(id)
	
	if (!CheckPlayerBit(bit_RespawnAsZombie, id))
	{
		if (is_user_connected(id))
			cs_set_user_team(id, CS_TEAM_CT)
		else	fm_set_user_team(id, TEAM_CT)
		
		UT_UpdatePlayerTeam(id, 2, 1)
		
		remove_task(id + TASK_RESET_MODEL)
		set_task(0.25, "ResetModel_TASK" , id + TASK_RESET_MODEL)
		
		iArray_Level[id] = 0
		upgrade_evolution(id, iArray_Level[id])
	}
	else
	{
		new iClassId = get_user_zombie_class(id)
		
		set_user_zombie(id, iClassId, 0, 1, 0)
		
		if (cs_get_user_team(id) != CS_TEAM_T)
		{
			//	Move Zombie to Terrorist Team
			
			if (is_user_connected(id))
				cs_set_user_team(id, CS_TEAM_T) 
			else	fm_set_user_team(id, TEAM_TERRORIST)
			UT_UpdatePlayerTeam(id, TEAM_TERRORIST, 1)
		}
		
		upgrade_evolution(id, iArray_Level[id])
	}
	
	
}



public TFM_user_infected(iInfector, iVictim, iInfectionType)
{
	if (!is_zm3_on())
		return PLUGIN_CONTINUE
		
	if (!is_user_connected(iVictim))	
		return

	remove_task(iVictim + TASK_ZOMBIE_HEAL)
	ZombieHealing_TASK(iVictim + TASK_ZOMBIE_HEAL)
	
	new iPlayers[32], iNumber
	get_players(iPlayers, iNumber, "ae", "TERRORIST")
	
	for (new i = 0; i < iNumber; i++)
	{
		new id = iPlayers[i]
		
		if (id == iVictim)
			continue
			
		iArray_Level[id]++
		
		if (iArray_Level[id] > MAX_EVOLUTION_LEVEL)
			iArray_Level[id] = MAX_EVOLUTION_LEVEL
		else	upgrade_evolution(id, iArray_Level[id])
		
		
		new iClassId = get_user_zombie_class(id)
		
		switch (iClassId)
		{
			case ZB_GENDER_MALE:
				client_cmd(id, "spk %s", SOUND_EVOLUTION_MALE)
			case ZB_GENDER_FEMALE:
				client_cmd(id, "spk %s", SOUND_EVOLUTION_FEMALE)
		}
	}
}



/*			TASK SECTION				*/


public ResetModel_TASK(TASKID)
{
	new id = TASKID - TASK_RESET_MODEL
	
	if (!is_zm3_on())
		return
		
	if (!is_user_connected(id))
		return
		
	
	
	cs_reset_user_model(id)
	//cs_set_user_team(id, CS_TEAM_CT)
	
	
}

public HeroSelection_TASK(TASKID)
{
	if (!is_zm3_on())
		return
		
	new iPlayers[32], iNumber, iAlivePeople
	
	get_players(iPlayers, iAlivePeople, "a")
	get_players(iPlayers, iNumber)
	
	
	if (iAlivePeople < 2)
	{
		set_task(1.0 , "HeroSelection_TASK", TASK_HERO_SELECTION)
		return
	}
	else if (2<= iAlivePeople < 5)
	{
		new iParam[2]
		iParam[0] = 0 // Created Class
		
		set_task(0.1, "ZombieSelection_TASK", TASK_ZOMBIE_SELECTION, iParam, sizeof iParam)
		return
	}
	else
	{
		new iHeroId = iPlayers[random(iNumber)]
		
		if (get_user_zombie(iHeroId) || !is_user_alive(iHeroId))
		{
			set_task(1.0 , "HeroSelection_TASK", TASK_HERO_SELECTION)
			return
		}
		
		ExecuteForward(ifw_PlayerBecomeHero, ifw_Result, iHeroId)
		SetPlayerBit(bit_IsHero, iHeroId);
		
		cs_set_user_team(iHeroId, CS_TEAM_CT)
		UT_UpdatePlayerTeam(iHeroId, TEAM_CT, 1)
		
		new szName[32]
		get_user_name(iHeroId, szName, sizeof szName - 1)
		
		client_print(0, print_center, "%L", LANG_SERVER, "BECAME_HERO", szName)
		
		new iParam[2]
		iParam[0] = 0 // Created Class
		
		set_task(0.1, "ZombieSelection_TASK",  TASK_ZOMBIE_SELECTION, iParam, sizeof iParam)
	}
}

public ZombieSelection_TASK(iParam[2], TASKID)
{
	if (!is_zm3_on())
		return
		
	new iPlayers[32], iNumber, iAlivePeople
	
	get_players(iPlayers, iAlivePeople, "a")
	get_players(iPlayers, iNumber)
	
	
	if (iAlivePeople < 2)
	{
		set_task(1.0 , "ZombieSelection_TASK", TASK_ZOMBIE_SELECTION, iParam, 2)
		return
	}
	
	new id = iPlayers[random(iNumber)]
	
	if (CheckPlayerBit(bit_IsHero, id) || get_user_zombie(id) || !is_user_connected(id) || !is_user_alive(id))
	{
		set_task(1.0 , "ZombieSelection_TASK", TASK_ZOMBIE_SELECTION, iParam, 2)
		return
	}
	
	
	new iClassId = get_user_zombie_class(id)
	
	set_user_zombie(id, iClassId, 0, 1, 1)
	
	//	Double Hp for this Zombie
	
	new Float:fClassHealth = get_class_health(iClassId)
	
	fClassHealth += (iNumber - iParam[0]) * 200.0
	
	if (fClassHealth > 8000.0)
		fClassHealth = 8000.0
		
	set_pev(id, pev_health, fClassHealth)
	
	//	Move Zombie to Terrorist Team
	cs_set_user_team(id, CS_TEAM_T) 
	UT_UpdatePlayerTeam(id, TEAM_TERRORIST, 1)
	
	iParam[0]++
	
	if (4 < iAlivePeople < 8)
	{
		if (iParam[0] < 2)
		{
			set_task(0.1 , "ZombieSelection_TASK", TASK_ZOMBIE_SELECTION, iParam, 2)
			return
		}
	}
	else if (8 <= iAlivePeople < 20)
	{
		if (iParam[0] < 3)
		{
			set_task(0.1 , "ZombieSelection_TASK", TASK_ZOMBIE_SELECTION, iParam, 2)
			return
		}
	}
	else if (20 <= iAlivePeople) 
	{
		if (iParam[0] < 4)
		{
			set_task(0.1 , "ZombieSelection_TASK", TASK_ZOMBIE_SELECTION, iParam, 2)
			return
		}
	}
	
	for (new i = 0; i < iNumber; i++)
	{
		new iPlayer = iPlayers[i]
		
		if (iPlayer == id)
			continue
		
		if (get_user_zombie(iPlayer))
			continue
			
		//	Move soldiers to CT Team
		cs_set_user_team(iPlayer, CS_TEAM_CT)
		UT_UpdatePlayerTeam(iPlayer, TEAM_CT, 1)
	}
	
	zp_set_round_state(ROUND_BEGIN)
}



public RespawnZombie_TASK(TASKID)
{
	if (!is_zm3_on())
		return
	
	new id = TASKID - TASK_ZOMBIE_RESPAWN;
	
	if (is_user_alive(id))
		return
		
	if (!get_user_zombie(id))
		return
	
	SetPlayerBit(bit_RespawnAsZombie, id);
	ExecuteHamB(Ham_CS_RoundRespawn, id)
	
}


public ZombieHealing_TASK(TASKID)
{
	new id = TASKID - TASK_ZOMBIE_HEAL
	
	if (!is_user_connected(id))
		return
		
	if (!is_user_alive(id))
		return
		
	if (!get_user_zombie(id))
		return
		
	new Float:fHealth = float(get_user_health(id))
	
	new Float:fMaxHealth = get_class_max_health(id)
	
	if (fHealth >= fMaxHealth)
		return
		
	fHealth += ZB_HP_BONUS
	
	if (fHealth > fMaxHealth)
		fHealth = fMaxHealth
		
	set_pev(id, pev_health, fHealth)
	
	
	if (!is_user_bot(id))
	{
		/*	Play Healing Sound	*/
		
		new iClassId = get_user_zombie_class(id)
		
		switch (get_class_gender(iClassId))
		{
			case ZB_GENDER_MALE:
				client_cmd(id, "spk %s", SOUND_HEALTH_REGAIN_MALE)
			case ZB_GENDER_FEMALE:
				client_cmd(id, "spk %s", SOUND_HEALTH_REGAIN_FEMALE)
		}
		
		
		if (!UT_IsUserFlashed(id))
		{
			/*	Send ScreenFade Message */
			message_begin(MSG_ONE_UNRELIABLE, iMSGID_ScreenFade, _, id)
			write_short(1<<12)    // Duration : 1 sec
			write_short(1<<12)    // Hold time : 1 sec
			write_short(0x0000)    // Fade In Mode
			write_byte (150)        // Red
			write_byte (0)    // Green
			write_byte (0)        // Blue
			write_byte (100)    // Alpha
			message_end()
		}
	}
	
}

/****************************************************************/


stock is_zm3_on()
{
	if (!zp_is_mode_on())
		return 0
		
	if (zp_get_current_gameplay() != ZB_GAMEPLAY_ZM3)
		return 0
		
	return 1
}

stock do_random_spawn(id)
{
	new iCSDM_SpawnNumber = csred_CSDM_SpawnNumber()
		
	new iSpawnMethod = random(10)
		
	if (iSpawnMethod <= 8)
	{
		if (iCSDM_SpawnNumber)
		{
			csred_DoRandomSpawn(id, 1)
			
		}
	}
	else
		csred_DoRandomSpawn(id, 0)
		
}

stock fm_set_user_team(id, iTeam)
{
	if (!is_user_connected(id))
		return
		
	set_pdata_int(id, m_iTeam, iTeam, 5)
}

stock upgrade_damage_plus(iPercentage)
	ExecuteForward(ifw_UpgradeDamage, ifw_Result, iPercentage)
	
stock upgrade_evolution(id, iStage)
	ExecuteForward(ifw_UpgradeEvolutionLevel, ifw_Result, id, iStage)
	
stock fnGetHumans()
{
	new iHumans, id
	iHumans = 0
	for (id = 1; id <= iMaxPlayers; id++)
	{
		if (is_user_alive(id) && !get_user_zombie(id))
			iHumans++
	}
	
	return iHumans;
}

stock fnGetZombies()
{
	new iZombies, id
	iZombies = 0
	for (id = 1; id <= iMaxPlayers; id++)
	{
		if (is_user_alive(id) && get_user_zombie(id))
			iZombies++
	}
	
	return iZombies
}

stock fnForceRoundEnd(iTeamId)
{
	if (iTeamId == TEAM_TERRORIST)
		TerminateRound(RoundEndType_TeamExtermination, TeamWinning_Terrorist)
	else if (iTeamId == TEAM_CT)
		TerminateRound(RoundEndType_TeamExtermination, TeamWinning_Ct)
	else	TerminateRound(RoundEndType_Draw)
}


stock fnDrawSprite(Float:fOrigin[3], iSpriteId, iScale, iBrightness)
{
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
	write_byte(TE_SPRITE)
	engfunc(EngFunc_WriteCoord, fOrigin[0])
	engfunc(EngFunc_WriteCoord, fOrigin[1])
	engfunc(EngFunc_WriteCoord, fOrigin[2])
	write_short(iSpriteId) 
	write_byte(iScale) 
	write_byte(iBrightness)
	message_end()
}

stock iButtonMoving(iButton)
{
	if (iButton & IN_ATTACK)
		return 1
		
	if (iButton & IN_MOVELEFT)
		return 1
	
	if (iButton & IN_MOVERIGHT)
		return 1
	
	if (iButton & IN_BACK)
		return 1
	
	if (iButton & IN_FORWARD)
		return 1
		
	if (iButton & IN_JUMP)
		return 1
		
		
	return 0
	
	
}

stock Float:get_class_max_health(id)
{
	new iClassId = get_user_zombie_class(id)
	
	new Float:fAddition = iArray_Level[id] * ZB_HP_BONUS
	
	return get_class_health(iClassId) + fAddition
}