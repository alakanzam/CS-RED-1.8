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
#include <cswpn_ultilities>

#include <GamePlay_Included/TFM_ZombieMod.inc>
#include <GamePlay_Included/IntegerConstant.inc>


#define PLUGIN "[GAME-PLAY] Zombie Mod 4"
#define VERSION "-No Info-"
#define AUTHOR "Redplane"


new GAMEPLAY_NAME[] =	"Zombie Mod 4"
new GAMEPLAY_MAP_PREFIX[] = "zm4_"

#define TASK_BOT_FUNC	1000
#define TASK_ZOMBIE_SELECTION	2000
#define TASK_HERO_SELECTION	3000
#define TASK_RESET_MODEL	4000
#define TASK_ZOMBIE_RESPAWN	5000
#define TASK_ZOMBIE_HEAL	6000

/*	Constant	*/
new ZB_SELECTION_TIME	= 20
#define ZB_ROUND_TIME	5.0
#define ZB_HP_BONUS	700.0
#define ZB_HEALING_TIME	3.0
#define ZB_START_DMG_PLUS	240.0	// Start damage is 240 %

#define MAX_EVOLUTION_LEVEL	11
#define MAX_HUMAN_EVOLUTION	10



#define SOUND_EVOLUTION_FEMALE	"TFM_Zombie/EVOLUTION/ZombieEvolution_Female.wav"
#define SOUND_EVOLUTION_MALE	"TFM_Zombie/EVOLUTION/ZombieEvolution_Male.wav"

#define SOUND_HEALTH_REGAIN_MALE	"TFM_Zombie/HealthRegain/RegainHealthMale-1.wav"
#define SOUND_HEALTH_REGAIN_FEMALE	"TFM_Zombie/HealthRegain/RegainHealthFemale-1.wav"


/************************/
new iCvar_MaxRound



new iMaxRound
new iGameExit
new iHamCz


new iMaxPlayers

//	Forwards

new ifw_PlayerBecomeHero
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
new bit_IsTheLastSoldier

/*		SPRITE INDEX		*/

/*		MESSAGE ID		*/
new iMSGID_ScreenFade

/*		SPRITE FILE		*/
#define RESPAWN_SPRITE "sprites/ZombieMod3/ZM3_RESPAWN.spr"

/*		ARRAY			*/
new iArray_Level[33]

/*			NATIVE SECTIONS			*/
public plugin_natives()
{
	register_native("ZM4_is_user_hero", "nt_ZM4_is_user_hero", 1)
	register_native("ZM4_get_evolution_stage", "nt_ZM4_get_evolution_stage", 1)
}

public nt_ZM4_is_user_hero(id)
	return CheckPlayerBit(bit_IsHero ,id)
	
public nt_ZM4_get_evolution_stage(id)
	return iArray_Level[id]
	
/********************************************************/

public TFM_EnableRegisterGamePlay()
{
	zp_register_gameplay(ZB_GAMEPLAY_ZM4, GAMEPLAY_NAME, GAMEPLAY_MAP_PREFIX, sizeof GAMEPLAY_MAP_PREFIX)
	iCvar_MaxRound = register_cvar("ZombieMod/GamePlay/ZM4/MaxRound", "9")
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
	if (!is_zm4_on())
	{
		set_fail_state("[GAMEPLAY] Zombie Mod 4 is turned OFF")
		return
	}
	
	/*	Forward creating	*/
	
	ifw_PlayerBecomeHero = CreateMultiForward("ZM4_PlayerBecomeHero", ET_CONTINUE, FP_CELL)
	ifw_UpgradeEvolutionLevel = CreateMultiForward("ZM4_EvolutionUpdated", ET_IGNORE, FP_CELL, FP_CELL)
	
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
	ClearPlayerBit(bit_RespawnAsZombie, id);
	ClearPlayerBit(bit_IsTheLastSoldier, id)
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
	if (!is_zm4_on())
		return HAM_IGNORED
		
	if (!is_user_connected(iVictim))
		return HAM_IGNORED
		
	if (!is_user_connected(iAttacker))
		return HAM_IGNORED
		
	if (get_user_zombie(iVictim) && get_user_zombie(iAttacker))
		return HAM_SUPERCEDE
		
	if (!get_user_zombie(iVictim) && !get_user_zombie(iAttacker))
		return HAM_SUPERCEDE
	
	if (!get_user_zombie(iAttacker) && get_user_zombie(iVictim) && !nt_ZM4_is_user_hero(iAttacker))
	{
		new Float:fPlusPercentage = ZB_START_DMG_PLUS / 100.0
		fDamage += fDamage * fPlusPercentage
		
		SetHamParamFloat(4, fDamage)
	}
	
	return HAM_IGNORED
}

public fw_PlayerTraceAttack(iVictim, iAttacker, Float:fDamage, Float:fDirection[3], tracehandle, damagebits)
{
	if (!is_zm4_on())
		return HAM_IGNORED
		
	if (!is_user_connected(iVictim))
		return HAM_IGNORED
		
	if (!is_user_connected(iAttacker))
		return HAM_IGNORED
		
	if (get_user_zombie(iVictim) && get_user_zombie(iAttacker))
		return HAM_SUPERCEDE
		
	if (!get_user_zombie(iVictim) && !get_user_zombie(iAttacker))
		return HAM_SUPERCEDE
	
	new Float:fPlusPercentage = ZB_START_DMG_PLUS / 100.0
	fDamage += fDamage * fPlusPercentage
	
	SetHamParamFloat(3, fDamage)
	return HAM_IGNORED
}

public csred_PlayerKilledPost(iVictim, iKiller)
{
	if (!is_zm4_on())
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
	
	
	new iDamageBit = get_pdata_int( iVictim , m_bitsDamageType, 5)
	
	//	If Zombie is killed by Melee weapons
	if (get_user_weapon(iKiller) == CSW_KNIFE && iDamageBit == (DMG_CLUB|DMG_NEVERGIB))
	{
		remove_task(iVictim + TASK_ZOMBIE_RESPAWN)
		
		if (fnGetZombies() < 1)
		{
			ir_block_round_end("")
			fnForceRoundEnd(TEAM_CT)
			ir_block_round_end(FLAG_ALL)
			
			zp_set_round_state(ROUND_END)
		}
	}
	else
	{
		remove_task(iVictim + TASK_ZOMBIE_RESPAWN)
		iArray_Level[iVictim]++
		
		if (iArray_Level[iVictim] > MAX_EVOLUTION_LEVEL)
			iArray_Level[iVictim] = MAX_EVOLUTION_LEVEL
		
		upgrade_evolution(iVictim, iArray_Level[iVictim])
		
		set_task(1.0, "RespawnZombie_TASK", iVictim + TASK_ZOMBIE_RESPAWN)
	}
}


/*				MESSAGE SECTION					*/

public message_ClCorpse()
{
	if (!is_zm4_on())
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
		
	if (!is_zm4_on())
		return
		
	if (zp_get_round_state() != ROUND_BEGIN)
		return
	
	new iButtonId = get_uc(ucHandle, UC_Buttons)
	
	//	Player is a Soldier
	
	if (!get_user_zombie(id))
	{
		if (iButtonId & IN_USE)
		{
			if (nt_ZM4_is_user_hero(id) || iArray_Level[id] < MAX_HUMAN_EVOLUTION)
				return
				
			iButtonId &= ~IN_USE
			
			set_uc(ucHandle, UC_Buttons, iButtonId)
			console_cmd(id, "-use")
			set_player_hero(id)	
		}
		return
	}
	
	//	Player is a Zombie
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
	if (!is_zm4_on())
		return
		
	zp_set_round_state(ROUND_END)
	set_user_countdown(0, 0, 1, 1, 1)

}

public RoundEvent_Begin()
{
	if (!is_zm4_on())
		return
		
	
	set_user_countdown(0, ZB_SELECTION_TIME, 1, 1, 1)
	new Float:fSelectionTime = float(ZB_SELECTION_TIME)
	
	remove_task(TASK_ZOMBIE_SELECTION)
	
	new iParam[2]
	iParam[0] = 0 // Numbe of created Zombies	
	set_task(fSelectionTime, "ZombieSelection_TASK", TASK_ZOMBIE_SELECTION, iParam, sizeof iParam)
	
	
}

public RoundEvent_CtWin()
{
	if (!is_zm4_on())
		return
	
	ClearZombieRespawnTask()
	
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
	
	new iPlayers[32], iNumber
	get_players(iPlayers, iNumber, "e", "CT")
	
	for (new i = 0; i < iNumber; i++)
	{
		new id = iPlayers[i]
		new iDeath = get_pdata_int(id, m_iDeaths , 5)
		
		UT_UpdateScoreBoard(id, iScore, iDeath, 1)
	}
}

public RoundEvent_TerWin()
{
	if (!is_zm4_on())
		return
	
	ClearZombieRespawnTask()
	
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
	
	
	new iPlayers[32], iNumber
	get_players(iPlayers, iNumber, "e", "TERRORIST")
	
	for (new i = 0; i < iNumber; i++)
	{
		new id = iPlayers[i]
		new iDeath = get_pdata_int(id, m_iDeaths , 5)
		
		UT_UpdateScoreBoard(id, iScore, iDeath, 1)
	}
	
}

public TFM_RoundEnd()
{
	if (!is_zm4_on())
		return PLUGIN_CONTINUE
		
	ir_block_round_end("")
	fnForceRoundEnd(TEAM_CT)
	ir_block_round_end(FLAG_ALL)
	
	zp_set_round_state(ROUND_END)
	
	return PLUGIN_HANDLED
}

public csred_PlayerSpawnPre(id)
{
	if (!is_zm4_on())
		return
	
	if (!CheckPlayerBit(bit_RespawnAsZombie, id))
		set_user_zombie(id, -1, 0, 0, 0)
	
	ClearPlayerBit(bit_IsHero, id);
	ClearPlayerBit(bit_IsTheLastSoldier, id);
}

public csred_PlayerSpawnPost(id)
{
	if (!is_zm4_on())
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
		
		new Float:fHealth = get_class_health(iClassId)
		fHealth += ZB_HP_BONUS * iArray_Level[id]
		set_pev(id, pev_health, fHealth)
		
		if (cs_get_user_team(id) != CS_TEAM_T)
		{
			//	Move Zombie to Terrorist Team
			
			if (is_user_connected(id))
				cs_set_user_team(id, CS_TEAM_T) 
			else	fm_set_user_team(id, TEAM_TERRORIST)
			UT_UpdatePlayerTeam(id, TEAM_TERRORIST, 1)
		}
		
		
	}
	
	
}

public csred_WpnAttachToPlayerPost(id, iEnt, iWeaponId)
{
	if (!is_zm4_on())
		return
		
	if (!nt_ZM4_is_user_hero(id))
		return
		
	if (iWeaponId != CSW_KNIFE)
	{
		UT_StripWeaponEnt(id, iEnt)
		return
	}
}

//	Called when a soldier is infected

public TFM_user_infected(iInfector, iVictim, iInfectionType)
{
	if (!is_zm4_on())
		return PLUGIN_CONTINUE
		
	if (!is_user_connected(iVictim))	
		return PLUGIN_CONTINUE
	
	if (nt_ZM4_is_user_hero(iVictim))
		return PLUGIN_HANDLED
	
	iArray_Level[iVictim] = 0
		
	remove_task(iInfector + TASK_ZOMBIE_HEAL)
	ZombieHealing_TASK(iInfector + TASK_ZOMBIE_HEAL)
	
	new iPlayers[32], iNumber
	get_players(iPlayers, iNumber, "a")
	
	for (new i = 0; i < iNumber; i++)
	{
		new id = iPlayers[i]
		
		if (id == iVictim)
			continue
			
		iArray_Level[id]++
		
		
		
		if (get_user_zombie(id))
		{
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
		else
		{
			if (!nt_ZM4_is_user_hero(id))
			{
				if (iArray_Level[id] > MAX_HUMAN_EVOLUTION)
					iArray_Level[id] = MAX_HUMAN_EVOLUTION	
				else	upgrade_evolution(id, iArray_Level[id])
				
				if (is_user_bot(id))
				{
					if (iArray_Level[id] >= MAX_HUMAN_EVOLUTION)
						set_player_hero(id)
				}
			}
		}
	}
	
	if (iInfectionType == 2)
		SetPlayerBit(bit_IsTheLastSoldier, iVictim)
	
	return PLUGIN_CONTINUE
}



/*			TASK SECTION				*/


public ResetModel_TASK(TASKID)
{
	new id = TASKID - TASK_RESET_MODEL
	
	if (!is_zm4_on())
		return
		
	if (!is_user_connected(id))
		return
		
	
	
	cs_reset_user_model(id)
	//cs_set_user_team(id, CS_TEAM_CT)
	
	
}

public ZombieSelection_TASK(iParam[2], TASKID)
{
	if (!is_zm4_on())
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
	
	if (nt_ZM4_is_user_hero(id) || get_user_zombie(id) || !is_user_connected(id) || !is_user_alive(id))
	{
		set_task(1.0 , "ZombieSelection_TASK", TASK_ZOMBIE_SELECTION, iParam, 2)
		return
	}
	
	
	new iClassId = get_user_zombie_class(id)
	
	set_user_zombie(id, iClassId, 0, 1, 1)
	
	new Float:fClassHealth = get_class_health(iClassId)
	
	fClassHealth += (iNumber - iParam[0]) * ZB_HP_BONUS
	
	if (fClassHealth > 10000.0)
		fClassHealth = 10000.0
		
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
	if (!is_zm4_on())
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


stock is_zm4_on()
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


stock upgrade_evolution(id, iStage)
	ExecuteForward(ifw_UpgradeEvolutionLevel, ifw_Result, id, iStage)
	
stock set_player_hero(id)
{
	fm_strip_user_weapons(id)
	ExecuteForward(ifw_PlayerBecomeHero, ifw_Result, id)
	if (ifw_Result == PLUGIN_CONTINUE)
		fm_give_item(id, "weapon_knife")
		
	new iPlayers[32], iNumber
	get_players(iPlayers, iNumber, "c")
	
	new szName[32]
	get_user_name(id, szName, sizeof szName - 1)
	
	for (new i = 0; i < iNumber; i++)
	{
		new iPlayer = iPlayers[i]
		
		if (iPlayer == id)
			continue
			
		client_print(iPlayer, print_center, "%L", iPlayer, "BECAME_HERO", szName)
	}
}

stock ClearZombieRespawnTask()
{
	new iMAX_PLAYER = 33
	for (new id = 1; id < iMAX_PLAYER; id++)
	{
		remove_task(id + TASK_ZOMBIE_RESPAWN)
		ClearPlayerBit(bit_RespawnAsZombie, id)
	}
}

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
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
