/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <cstrike>
#include <fakemeta_util>


#include <cswpn_ultilities>

#include <celltrie>

#include <ArmouryManager>
#include <player_api>

#define PLUGIN "[EQUIPMENT MOD] ARMOR"
#define VERSION "1.0"
#define AUTHOR "Redplane"



#define TASK_CZ_FUNCTION	1000

#define MAX_ARMOR	32
#define MAX_ARMOR_SPAWN_POINT	10

#define SetPlayerBit(%1,%2)      (%1 |= (1<<(%2&31)))
#define ClearPlayerBit(%1,%2)    (%1 &= ~(1 <<(%2&31)))
#define CheckPlayerBit(%1,%2)    (%1 & (1<<(%2&31)))


enum
{
	LINE_ARMOR_NAME,
	LINE_ARMOR_TYPE,
	LINE_ARMOR_TEAM,
	LINE_ARMOR_AMOUNT,
	LINE_ARMOR_COST,
	LINE_ARMOR_MODEL,
	LINE_ARMOR_SUB_BODY,
	LINE_ARMOR_SERIAL,
	LINE_ARMOR_DAMAGE,
	LINE_PROVEN_DAMAGE,
	LINE_ARMOR_WEIGHT,
	LINE_ARMOR_SPEED
}



#define DMG_GRENADE	(1<<24)

new Trie:iArmorInfo[MAX_ARMOR]
new Trie:iArmorLoaded

#define SECTION_ARMOR_NAME	"ARMOR_NAME"
#define SECTION_ARMOR_REAL_ID	"ARMOR_REAL_ID"
#define SECTION_ARMOR_TEAM	"ARMOR_TEAM"
#define SECTION_ARMOR_AMOUNT	"ARMOR_AMOUNT"
#define SECTION_ARMOR_SERIAL	"ARMOR_SERIAL"
#define SECTION_ARMOR_MODEL	"ARMOR_MODEL"
#define SECTION_ARMOR_SUB_BODY	"ARMOR_SUB_BODY"
#define SECTION_ARMOR_SPAWN_FILE	"ARMOR_SPAWN_FILE"
#define SECTION_ARMOR_COST	"ARMOR_COST"
#define SECTION_ARMOR_COST_TYPE	"ARMOR_COST_TYPE"

new Float:ARMOR_DAMAGE[MAX_ARMOR]
new Float:ARMOR_WEIGHT[MAX_ARMOR]
new Float:ARMOR_SPEED[MAX_ARMOR]

#define SECTION_ARMOR_PROOF_TYPE	"ARMOR_PROOF_TYPE"

#define ARMOR_CONFIG_DIR	"EQ_MOD/ARMOR/CONFIGS"
#define ARMOR_SPAWN_DIR	"EQ_MOD/ARMOR/SPAWN"
#define ARMOR_SPEC_DIR	"EQ_MOD/ARMOR/SPEC"
#define ARMOR_ADD_DIR	"EQ_MOD/ARMOR/ADD"
#define ARMOR_MANAGER_DIR	"EQ_MOD/ARMOR"
#define	ARMOR_MANAGER_FILE	"MANAGER.CFG"

new iHasArmor[33]

new iSpawnWeaponId[MAX_ARMOR_SPAWN_POINT]
new Float:fSpawnVecs[MAX_ARMOR_SPAWN_POINT][3]


/*	INTEGER		*/
new iArmorCount
new iTotalSpawnPoint
new iHamCz
/*	MENU ID		*/
new iArmouryMenuID


/*	BIT FIELD	*/
new bit_iHitHead


/*	FORWARD	*/
new ifw_Result

new ifw_CanUserEquipArmor
new ifw_CanUserPickArmor

new ifw_ArmorPrecache
new ifw_ArmorCheckModel

new ifw_ArmorCreating
new ifw_ArmorCalculating

#define DEFAULT_DMG_PROOF (DMG_BLAST|DMG_BULLET|DMG_GRENADE)

public plugin_natives()
{
	register_native("give_user_armor", "nt_give_user_armor", 1)
	register_native("get_user_armor_id", "nt_get_user_armor_id", 1)
	register_native("get_armor_real_id", "nt_get_armor_real_id", 1)
	register_native("get_armor_amount", "nt_get_armor_amount", 1)
	register_native("get_armor_team", "nt_get_armor_team", 1)
	register_native("get_armor_cost", "nt_get_armor_cost", 1)
	register_native("get_armor_speed", "nt_get_armor_speed", 1)
	register_native("get_armor_weight", "nt_get_armor_weight", 1)
	
	register_native("find_armor_by_model", "nt_find_armor_by_model", 1)
	register_native("find_armor_by_serial", "nt_find_armor_by_serial", 1)
	
	register_native("set_armor_spawn", "nt_set_armor_spawn", 1)
	register_native("set_armor_load_file", "nt_set_armor_load_file", 1)
}

public nt_give_user_armor(id, iArmorId, iAmount)
{
	if (iArmorId < 0 || iArmorId > iArmorCount - 1)
	{
		iHasArmor[id] = -1
		return 0
	}
	
	if (!can_player_equip_armor(id, iArmorId))
		return 0
		
	iHasArmor[id] = iArmorId
	
	new iArmorRealId = nt_get_armor_real_id(iArmorId)
	new CsArmorType:iArmorType = CS_ARMOR_KEVLAR
	
	if (iArmorRealId == CSW_VESTHELM)
		iArmorType = CS_ARMOR_VESTHELM
		
	cs_set_user_armor(id, (iAmount < 1)?nt_get_armor_amount(iArmorId):iAmount, iArmorType)
	
	return 1
	
}

public nt_get_user_armor_id(id)
{
	if (!is_user_connected(id))
		return -1
		
	return iHasArmor[id]
}

public nt_get_armor_real_id(iArmorId)
{
	if (iArmorId < 0 || iArmorId > iArmorCount - 1)
		return 0
		
	new iArmorRealId
	TrieGetCell(iArmorInfo[iArmorId], SECTION_ARMOR_REAL_ID, iArmorRealId)
	return iArmorRealId
}

public nt_get_armor_amount(iArmorId)
{
	if (iArmorId < 0 || iArmorId > iArmorCount - 1)
		return 0
		
	new iArmorAmount
	TrieGetCell(iArmorInfo[iArmorId], SECTION_ARMOR_AMOUNT, iArmorAmount)
	return iArmorAmount
}

public nt_get_armor_team(iArmorId)
{
	if (iArmorId < 0 || iArmorId > iArmorCount - 1)
		return 0
		
	new iArmorTeam
	TrieGetCell(iArmorInfo[iArmorId], SECTION_ARMOR_TEAM, iArmorTeam)
	return iArmorTeam
}

public nt_get_armor_cost(iArmorId, &iCostType, &iCost)
{
	if (iArmorId < 0 || iArmorId > iArmorCount - 1)
		return 0
		
	TrieGetCell(iArmorInfo[iArmorId], SECTION_ARMOR_COST_TYPE, iCostType)
	TrieGetCell(iArmorInfo[iArmorId], SECTION_ARMOR_COST, iCost)
	return 1
}

public Float:nt_get_armor_speed(iArmorId)
{
	if (iArmorId < 0 || iArmorId > iArmorCount - 1)
		return 0.0
		
	return ARMOR_SPEED[iArmorId]
}

public Float:nt_get_armor_weight(iArmorId)
{
	if (iArmorId < 0 || iArmorId > iArmorCount - 1)
		return 0.0
		
	return ARMOR_WEIGHT[iArmorId]
}

public nt_find_armor_by_model(szModel[])
{
	param_convert(1)
	
	for (new i = 0; i < iArmorCount; i++)
	{
		new szArmorModel[128]
		TrieGetString(iArmorInfo[i], SECTION_ARMOR_MODEL, szArmorModel, sizeof szArmorModel - 1)
		
		if (equal(szModel, szArmorModel))
			return i
	}
	return -1
}

public nt_find_armor_by_serial(szSerial[])
{
	param_convert(1)
	
	for (new i = 0; i < iArmorCount; i++)
	{
		new szArmorSerial[128]
		TrieGetString(iArmorInfo[i], SECTION_ARMOR_SERIAL, szArmorSerial, sizeof szArmorSerial - 1)
		
		if (equal(szSerial, szArmorSerial))
			return i
	}
	return -1
}

public nt_set_armor_spawn(iArmouryPoint, iArmorId, Float:fOrigin[3])
	CreateArmoury(iArmouryPoint, iArmorId, fOrigin)
	
public nt_set_armor_load_file(szFile[], szExtension[], iIgnoreCondition)
{
	param_convert(1)
	param_convert(2)
	
	load_armor_file(ARMOR_CONFIG_DIR, szFile, szExtension, iIgnoreCondition)
}

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	forward_register()
	
	register_event("HLTV", "Event_RoundStart", "a", "1=0", "2=0")
	//	Log Event
	register_logevent("LogEvent_RoundBegin" , 2 , "1=Round_Start")
	
	RegisterHam(Ham_TraceAttack, "player", "fw_PlayerTraceAttack")
	RegisterHam(Ham_TakeDamage, "player", "fw_PlayerTakeDamage")
	
	RegisterHam(Ham_Touch, "armoury_entity", "fw_ArmouryEntityTouched")
	
	
	
	/*
	if (!iArmouryMenuID)
	{
		new szMenuTitle[128]
		formatex(szMenuTitle, sizeof szMenuTitle - 1, "%L", LANG_SERVER, "ARMOURY_ARMOR_TITLE")
		
		iArmouryMenuID = menu_create(szMenuTitle, "fw_ArmouryMenuSelected")
	}
	*/
	
	new szConfigDir[32]
	new szMapName[32]
	get_configsdir(szConfigDir, sizeof szConfigDir - 1)
	get_mapname(szMapName, sizeof szMapName - 1)
	
	ExecuteForward(ifw_ArmorPrecache, ifw_Result)
	
	new szManagerFile[256]
	formatex(szManagerFile, sizeof szManagerFile - 1, "%s/%s/%s.ngocvinh", szConfigDir, ARMOR_SPEC_DIR, szMapName)
	
	if (file_exists(szManagerFile))
	{
		for (new i = 0; i < file_size(szManagerFile, 1); i++)
		{
			new szTextInfo[64], iTextLen
			
			read_file(szManagerFile, i, szTextInfo, sizeof szTextInfo - 1, iTextLen)
			load_armor_file(ARMOR_CONFIG_DIR, szTextInfo, "ini", 1)
		}
	}
	else
	{
		formatex(szManagerFile, sizeof szManagerFile - 1, "%s/%s/%s", szConfigDir, ARMOR_MANAGER_DIR, ARMOR_MANAGER_FILE)
		
		for (new i = 0; i < file_size(szManagerFile, 1); i++)
		{
			new szTextInfo[64], iTextLen
			
			read_file(szManagerFile, i, szTextInfo, sizeof szTextInfo - 1, iTextLen)
			load_armor_file(ARMOR_CONFIG_DIR, szTextInfo, "ini", 0)
		}
	}
	
	
	formatex(szManagerFile, sizeof szManagerFile - 1, "%s/%s/%s.cfg", szConfigDir, ARMOR_ADD_DIR, szMapName)
	
	if (file_exists(szManagerFile))
	{
		for (new i = 0; i < file_size(szManagerFile, 1); i++)
		{
			new szTextInfo[64], iTextLen
			
			read_file(szManagerFile, i, szTextInfo, sizeof szTextInfo - 1, iTextLen)
			load_armor_file(ARMOR_CONFIG_DIR, szTextInfo, "redplane", 1)
		}
	}
}

public client_putinserver(id)
{
	if (iHamCz)
		return
		
	set_task(0.1 , "RegisterCzFunction_TASK", id + TASK_CZ_FUNCTION)
}

public RegisterCzFunction_TASK(TASKID)
{
	new id = TASKID - TASK_CZ_FUNCTION
	
	if (!is_user_bot(id))
		return
		
	if (iHamCz)
		return
		
	RegisterHamFromEntity(Ham_TraceAttack, id, "fw_PlayerTraceAttack")
	RegisterHamFromEntity(Ham_TakeDamage, id, "fw_PlayerTakeDamage")
	iHamCz = 1
}

public Event_RoundStart()
{
	new iEnt = -1
	while((iEnt = engfunc(EngFunc_FindEntityByString, iEnt, "classname", "armoury_entity")))
	{
		if(pev_valid(iEnt) && iEnt)
		{
			new iArmouryType = pev(iEnt, pev_ArmouryType)
			if (iArmouryType == ARMOURY_ARMOR)
				engfunc(EngFunc_RemoveEntity, iEnt)
		}
	}
}

public LogEvent_RoundBegin()
{
	for (new i = 0; i < iTotalSpawnPoint; i++)
		CreateArmoury(i, -1, Float:{0.0, 0.0, 0.0})
}

public fw_ArmouryEntityTouched(iEnt, id)
{
	if (!iEnt || !pev_valid(iEnt))
		return HAM_IGNORED
		
	new iArmouryType = pev(iEnt, pev_ArmouryType)
	
	if (iArmouryType != ARMOURY_ARMOR)
		return HAM_IGNORED
		
	if (pev(iEnt, pev_ArmouryStatus) != ARMOURY_ENABLED)
		return HAM_SUPERCEDE
		
	if (get_user_armor(id))
		return HAM_SUPERCEDE
		
		
	new iArmouryId = pev(iEnt, pev_ArmouryId)
	
	if (!can_player_touch_armoury(id, iArmouryId))
		return HAM_IGNORED
		
	nt_give_user_armor(id, iArmouryId, 0)
	engfunc(EngFunc_RemoveEntity, iEnt)
	return HAM_SUPERCEDE
}


public fw_PlayerTraceAttack(iVictim, iAttacker, Float:fDamage, Float:fDirection[3], iTraceResult, iDMG_BIT)
{
	ClearPlayerBit(bit_iHitHead, iVictim)
	
	if (get_tr2(iTraceResult, TR_iHitgroup) == HIT_HEAD)
		SetPlayerBit(bit_iHitHead, iVictim)
	
}
public fw_PlayerTakeDamage(iVictim, inflictor, iAttacker, Float:fDamage, iDamagebit)
{		
	
	new CsArmorType:iArmorType  
	new iArmorAmount = cs_get_user_armor(iVictim, iArmorType)
	
	if (!iArmorAmount)
		return
		
	new Float:fArmorAmount = float(iArmorAmount)
	
	if (CheckPlayerBit(bit_iHitHead, iVictim) && iArmorType != CS_ARMOR_VESTHELM)
	{
		ClearPlayerBit(bit_iHitHead, iVictim)
		return
	}
	
	ClearPlayerBit(bit_iHitHead, iVictim)
	ExecuteForward(ifw_ArmorCalculating, ifw_Result, iVictim, inflictor, iAttacker, fDamage, iDamagebit)
	
	if (ifw_Result != PLUGIN_CONTINUE)
		return
		
	new Float:fLostArmor = fDamage * 1.7
		
	if (iHasArmor[iVictim] > -1 && iHasArmor[iVictim] < iArmorCount)
	{
		new iProvenDamage
		TrieGetCell(iArmorInfo[iHasArmor[iVictim]], SECTION_ARMOR_PROOF_TYPE, iProvenDamage)
			
		if (!(iDamagebit & iProvenDamage))
			return
			
		fLostArmor = fDamage + fDamage * ARMOR_DAMAGE[iHasArmor[iVictim]]
	}
	else
	{
		if (!(iDamagebit & DEFAULT_DMG_PROOF))
			return
	}
	if (fLostArmor <= fArmorAmount)
	{
		fArmorAmount -= fLostArmor
		SetHamParamFloat(4, 0.0)
		
		iArmorAmount = floatround(fArmorAmount)
		cs_set_user_armor(iVictim, floatround(fArmorAmount), iArmorType)
		return
	}
	else
	{
		fLostArmor -= fArmorAmount
		fDamage -= fLostArmor
		
		SetHamParamFloat(4, fDamage)
		
	}
	cs_set_user_armor(iVictim, 0, CS_ARMOR_NONE)
}

public csred_PlayerKilledPost(iVictim, iKiller)
{
	if (!is_user_connected(iVictim))
		return
		
	iHasArmor[iVictim] = -1
}

stock load_armor_file(szDirectory[], szFile[], szExtension[], iIgnore_AllConditions)
{
	if (iArmorCount > MAX_ARMOR - 1)
		return
	
	if (TrieKeyExists(iArmorLoaded, szFile))
		return
		
	new szLoadingFile[256]
	new szCfgDir[32]
	get_configsdir(szCfgDir, sizeof szCfgDir - 1)
	
	formatex(szLoadingFile, sizeof szLoadingFile - 1, "%s/%s/%s.%s", szCfgDir, szDirectory, szFile, szExtension)
	
	if (!file_exists(szLoadingFile))
		return
	
	new szTextInfo[256], iTextLen
	
	read_file(szLoadingFile, LINE_ARMOR_NAME, szTextInfo, sizeof szTextInfo - 1, iTextLen)
	replace(szTextInfo, sizeof szTextInfo - 1, "[ARMOR_NAME]", "")
	TrieSetString(iArmorInfo[iArmorCount], SECTION_ARMOR_NAME, szTextInfo)
	
	read_file(szLoadingFile, LINE_ARMOR_TYPE, szTextInfo, sizeof szTextInfo - 1, iTextLen)
	replace(szTextInfo, sizeof szTextInfo - 1, "[ARMOR_ID]", "")
	
	new iArmorRealId = str_to_num(szTextInfo)
	
	if (iArmorRealId != CSW_VEST && iArmorRealId != CSW_VESTHELM)
		return
		
	TrieSetCell(iArmorInfo[iArmorCount], SECTION_ARMOR_REAL_ID, iArmorRealId)
	
	read_file(szLoadingFile, LINE_ARMOR_TEAM, szTextInfo, sizeof szTextInfo - 1, iTextLen)
	replace(szTextInfo, sizeof szTextInfo - 1, "[ARMOR_TEAM]", "")
	TrieSetCell(iArmorInfo[iArmorCount], SECTION_ARMOR_TEAM, str_to_num(szTextInfo))
	
	read_file(szLoadingFile, LINE_ARMOR_AMOUNT, szTextInfo, sizeof szTextInfo - 1, iTextLen)
	replace(szTextInfo, sizeof szTextInfo - 1, "[ARMOR_AMOUNT]", "")
	TrieSetCell(iArmorInfo[iArmorCount], SECTION_ARMOR_AMOUNT, str_to_num(szTextInfo))
	
	read_file(szLoadingFile, LINE_ARMOR_COST, szTextInfo, sizeof szTextInfo - 1, iTextLen)
	replace(szTextInfo, sizeof szTextInfo - 1, "[ARMOR_COST]", "")
	new szCostType[3], szCost[3]
	parse(szTextInfo, szCostType, sizeof szCostType - 1, szCost, sizeof szCost - 1)
	TrieSetCell(iArmorInfo[iArmorCount], SECTION_ARMOR_COST_TYPE, str_to_num(szCostType))
	TrieSetCell(iArmorInfo[iArmorCount], SECTION_ARMOR_COST, str_to_num(szCost))
	
	new szWorldModel[128]
	read_file(szLoadingFile, LINE_ARMOR_MODEL, szTextInfo, sizeof szTextInfo - 1, iTextLen)
	replace(szTextInfo, sizeof szTextInfo - 1, "[ARMOR_MODEL]", "")
	formatex(szWorldModel, sizeof szWorldModel  - 1, "models/w_%s.mdl", szTextInfo)
	TrieSetString(iArmorInfo[iArmorCount], SECTION_ARMOR_MODEL, szWorldModel)
	
	if (!iIgnore_AllConditions)
	{
		ExecuteForward(ifw_ArmorCheckModel, ifw_Result, iArmorCount, szWorldModel)
		
		if (ifw_Result != PLUGIN_CONTINUE)
			return
	}
	engfunc(EngFunc_PrecacheModel, szWorldModel)
	
	read_file(szLoadingFile, LINE_ARMOR_SUB_BODY, szTextInfo, sizeof szTextInfo - 1, iTextLen)
	replace(szTextInfo, sizeof szTextInfo - 1, "[ARMOR_SUB-BODY]", "")
	TrieSetCell(iArmorInfo[iArmorCount], SECTION_ARMOR_SUB_BODY, str_to_num(szTextInfo))
	
	read_file(szLoadingFile, LINE_ARMOR_SERIAL, szTextInfo, sizeof szTextInfo - 1, iTextLen)
	replace(szTextInfo, sizeof szTextInfo - 1, "[ARMOR_SERIAL]", "")
	TrieSetString(iArmorInfo[iArmorCount], SECTION_ARMOR_SERIAL, szTextInfo)
	
	
	read_file(szLoadingFile, LINE_ARMOR_DAMAGE, szTextInfo, sizeof szTextInfo - 1, iTextLen)
	replace(szTextInfo, sizeof szTextInfo - 1, "[ARMOR_DAMAGE]", "")
	ARMOR_DAMAGE[iArmorCount] = str_to_float(szTextInfo)
	
	if (ARMOR_DAMAGE[iArmorCount] < 0.0)
		ARMOR_DAMAGE[iArmorCount] = 0.0
		
	read_file(szLoadingFile, LINE_PROVEN_DAMAGE, szTextInfo, sizeof szTextInfo - 1, iTextLen)
	replace(szTextInfo, sizeof szTextInfo - 1, "[PROVEN_DAMAGE]", "")
	TrieSetCell(iArmorInfo[iArmorCount], SECTION_ARMOR_PROOF_TYPE, read_flags(szTextInfo))
	
	read_file(szLoadingFile, LINE_ARMOR_WEIGHT, szTextInfo, sizeof szTextInfo - 1, iTextLen)
	replace(szTextInfo, sizeof szTextInfo - 1, "[ARMOR_WEIGHT]", "")
	ARMOR_WEIGHT[iArmorCount] = str_to_float(szTextInfo)
	
	read_file(szLoadingFile, LINE_ARMOR_SPEED, szTextInfo, sizeof szTextInfo - 1, iTextLen)
	replace(szTextInfo, sizeof szTextInfo - 1, "[ARMOR_SPEED]", "")
	ARMOR_SPEED[iArmorCount] = str_to_float(szTextInfo)
	
	new szSpawnFile[256], szMapName[32]
	
	get_mapname(szMapName, sizeof szMapName - 1)
	formatex(szSpawnFile, sizeof szSpawnFile - 1, "%s/%s/%s/%s.cfg", szCfgDir, ARMOR_SPAWN_DIR, szMapName, szFile)
	TrieSetString(iArmorInfo[iArmorCount], SECTION_ARMOR_SPAWN_FILE, szSpawnFile)
	
	new szInfo[10]
	formatex(szInfo, sizeof szInfo - 1, "%d", iArmorCount)
	
	new szArmorName[64]
	TrieGetString(iArmorInfo[iArmorCount], SECTION_ARMOR_NAME, szArmorName, sizeof szArmorName - 1)
	
	menu_additem(iArmouryMenuID, szArmorName, szInfo, ADMIN_ALL, -1)
	
	if (file_exists(szSpawnFile))
	{
		new Data[124]
		new pos[11][8]
		new len
		for (new iSpawnLine = 0; iSpawnLine < file_size(szSpawnFile, 1); iSpawnLine++)
		{
			
			if (iTotalSpawnPoint > MAX_ARMOR_SPAWN_POINT - 1)
				continue
				
			read_file(szSpawnFile , iSpawnLine , Data , 123 , len)
			
			parse(Data, pos[1], 7, pos[2], 7, pos[3], 7)
			// Origin
			fSpawnVecs[iTotalSpawnPoint][0] = str_to_float(pos[1]);
			fSpawnVecs[iTotalSpawnPoint][1] = str_to_float(pos[2]);
			fSpawnVecs[iTotalSpawnPoint][2] = str_to_float(pos[3]);
				
				
			iTotalSpawnPoint++
		}
	}
	iArmorCount++
}

stock CreateArmoury(iPoint, iArmouryId, Float:fOrigin[3])
{
	ExecuteForward(ifw_ArmorCreating, ifw_Result, iArmouryId)
	
	if (ifw_Result != PLUGIN_CONTINUE)
		return 0
		
	new iEnt = fm_create_entity("armoury_entity")
	
	dllfunc( DLLFunc_Spawn, iEnt );
	
	
	set_pev(iEnt, pev_solid, SOLID_TRIGGER)
	set_pev(iEnt, pev_mins, {-3.0, -3.0, -3.0})
	set_pev(iEnt, pev_maxs, {3.0, 3.0, 3.0})
	set_pev(iEnt, pev_ArmouryType, ARMOURY_ARMOR)
	
	new iArmorId
	
	if (iPoint < 0)
	{
		iArmorId = iArmouryId
		set_pev(iEnt, pev_origin, fOrigin)
	}
	else	
	{
		iArmorId = iSpawnWeaponId[iPoint]
		set_pev(iEnt, pev_origin, fSpawnVecs[iPoint])
	}
	
	set_pev(iEnt, pev_ArmouryId, iArmorId)
	csred_SetArmouryStatus(iEnt, ARMOURY_ENABLED)
				
	
	new szWorldModel[128]
	new iSubBody
	
	TrieGetString(iArmorInfo[iArmorId], SECTION_ARMOR_MODEL, szWorldModel, sizeof szWorldModel - 1)
	engfunc(EngFunc_SetModel, iEnt, szWorldModel)
	
	TrieGetCell(iArmorInfo[iArmorId], SECTION_ARMOR_SUB_BODY, iSubBody)
	set_pev(iEnt, pev_body, iSubBody)
	
	return 1
}







stock can_player_equip_armor(id, iArmorId)
{
	if (!is_user_connected(id))
		return 0
		
	if (!is_user_alive(id))
		return 0
		
	ExecuteForward(ifw_CanUserEquipArmor, ifw_Result, id, iArmorId)
	
	return 1
}

stock can_player_touch_armoury(id, iArmorId)
{
	if (!is_user_connected(id))
		return 0
		
	if (!is_user_alive(id))
		return 0
	
	ExecuteForward(ifw_CanUserPickArmor, ifw_Result, id, iArmorId)
	
	return 1
}


stock forward_register()
{
	ifw_CanUserEquipArmor = CreateMultiForward("AM_CanUserEquipArmor", ET_CONTINUE, FP_CELL, FP_CELL)
	ifw_CanUserPickArmor = CreateMultiForward("AM_CanUserTouchArmor", ET_CONTINUE, FP_CELL, FP_CELL)

	ifw_ArmorPrecache = CreateMultiForward("AM_PrecacheArmor", ET_IGNORE)
	ifw_ArmorCheckModel = CreateMultiForward("AM_CheckArmorModel", ET_CONTINUE, FP_CELL, FP_STRING)
	ifw_ArmorCreating = CreateMultiForward("AM_ArmorBeingCreated", ET_CONTINUE, FP_CELL)
	ifw_ArmorCalculating = CreateMultiForward("AM_CalculatingArmorDmg", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL, FP_FLOAT, FP_CELL)
	
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
