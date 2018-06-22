/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <fakemeta_util>

#include <celltrie>
#include <cswpn_ultilities>
#include <hamsandwich>
#include <cstrike>
#include <engine>

#include <GamePlay_Included/Tools.inc>
#include <mmcl>

#include <cstrike_pdatas>

#define PLUGIN "Model Replacement"
#define VERSION "1.0"
#define AUTHOR "Nguyen Duy Linh"



#define TASK_CHANGE_ENTITY_MODEL 2000


new iModelCount = 0

//	BIT TOOLS


#define SetBit(%1,%2)      (%1[%2>>5] |= (1<<(%2 & 31)))
#define ClearBit(%1,%2)    (%1[%2>>5] &= ~(1<<(%2 & 31)))
#define CheckBit(%1,%2)    (%1[%2>>5] & (1<<(%2 & 31)))  


new Trie:iPreventModel
new Trie:iPreventModelPrecache
new Trie:iPreventModelSub

enum
{
	SECTION_UNPRECACHE,
	SECTION_SUB
}

public plugin_natives()
	register_native("UT_SetEntityModel", "_SetEntityModel", 1) 

public _SetEntityModel(iEnt, szModel[], iSubBody)
{
	if (!pev_valid(iEnt))
		return 0
		
	param_convert(2)
	
	if (iSubBody < 0 /*Auto Detection Mode*/)
	{
		if (TrieKeyExists(iPreventModel, szModel))
		{
			new szReplacedModel[128], iModelSub
		
			TrieGetString(iPreventModel, szModel, szReplacedModel, sizeof szReplacedModel - 1)
			TrieGetCell(iPreventModelSub, szModel, iModelSub)
			
			engfunc(EngFunc_SetModel, iEnt, szReplacedModel)
			set_pev(iEnt, pev_body, iModelSub)
			return 1
		}
	}
	engfunc(EngFunc_SetModel, iEnt, szModel)
	return 1
}

public plugin_precache()
{
	new szConfigDir[128], szConfigFile[256]
	
	iModelCount = 0
	
	get_configsdir(szConfigDir, sizeof szConfigDir - 1)
	
	new CONFIGURATION_FILE[] =  "ModelReplacement.cfg"
	formatex(szConfigFile, sizeof szConfigFile - 1, "%s/%s", szConfigDir, CONFIGURATION_FILE)
	
		
	if (!iPreventModel)
		iPreventModel = TrieCreate()
		
	if (!iPreventModelPrecache)
		iPreventModelPrecache = TrieCreate()
		
	if (!iPreventModelSub)
		iPreventModelSub = TrieCreate()
	
	if (!file_exists(szConfigFile))
	{
		TrieDestroy(iPreventModel)
		TrieDestroy(iPreventModelPrecache)
		TrieDestroy(iPreventModelSub)
		
		pause("a")
		return
	}
	
	for (new i = 0; i < file_size(szConfigFile, 1); i++)
	{
		new TXT[1024], iTRASH
		
		read_file(szConfigFile, i, TXT, sizeof TXT - 1, iTRASH)
		
		if (containi(TXT, "//") != -1 || containi(TXT, ";") != -1)
			continue
			
		new szPreventedModel[128], szReplacedModel[128], szUnprecache[32], szSubModel[32]
		parse(TXT, szPreventedModel,  sizeof szPreventedModel - 1,  szReplacedModel, sizeof szReplacedModel - 1, szUnprecache, sizeof szUnprecache - 1, szSubModel, sizeof szSubModel - 1)
		
		replace(szPreventedModel, sizeof szPreventedModel - 1, "[Replace]", "")
		replace(szReplacedModel, sizeof szReplacedModel - 1, "[With]", "")
		replace(szUnprecache, sizeof szUnprecache - 1, "[UnprecacheModel]", "")
		replace(szSubModel, sizeof szSubModel - 1, "[SubOfReplacement]", "")
		
		if (TrieKeyExists(iPreventModel, szPreventedModel))
			continue
		
		TrieSetCell(iPreventModel,  szPreventedModel, iModelCount)
		TrieSetString(iPreventModel, szPreventedModel, szReplacedModel)
		
		new iSubModel = str_to_num(szSubModel)
		TrieSetCell(iPreventModelPrecache, szPreventedModel, str_to_num(szUnprecache))
		TrieSetCell(iPreventModelSub, szPreventedModel, iSubModel)
		
		if (iSubModel > -1)
			engfunc(EngFunc_PrecacheModel, szReplacedModel)
		iModelCount++
	}
	
	
	register_forward(FM_PrecacheModel, "fw_PrecacheModelPre")
	register_forward(FM_SetModel, "fw_SetModelPre")
	register_forward(FM_SetModel, "fw_SetModelPost", 1)
	
}

public fw_PrecacheModelPre(szModel[])
{
	if (TrieKeyExists(iPreventModel, szModel))
	{
		new iPrecacheStatus 
		
		TrieGetCell(iPreventModelPrecache, szModel, iPrecacheStatus)
		
		if (iPrecacheStatus)
			return FMRES_SUPERCEDE
	}
	return FMRES_IGNORED
}

public fw_SetModelPre(iEnt, szModel[])
{	
	if (!pev_valid(iEnt))
		return FMRES_IGNORED;
		
	if (TrieKeyExists(iPreventModel, szModel))
	{
		new szClassName[32]
		pev(iEnt, pev_classname, szClassName, sizeof szClassName - 1)
				
		if (is_prevent_class(szClassName))
			return FMRES_IGNORED
				
		return FMRES_SUPERCEDE
	}
	
	return FMRES_IGNORED
}

public fw_SetModelPost(iEnt, szModel[])
{
	if (!pev_valid(iEnt))
		return
		
	if (!TrieKeyExists(iPreventModel, szModel))
		return
		
	new szClassName[32]
	pev(iEnt, pev_classname, szClassName, sizeof szClassName - 1)
		
	if (is_prevent_class(szClassName))
		return
			
	new szReplacedModel[128], iModelSub
	
	TrieGetString(iPreventModel, szModel, szReplacedModel, sizeof szReplacedModel - 1)
	TrieGetCell(iPreventModelSub, szModel, iModelSub)
	
	engfunc(EngFunc_SetModel, iEnt, szReplacedModel)
	set_pev(iEnt, pev_body, iModelSub)
			
	return		
	
}

stock is_prevent_class(szClassName[])
{
	new PREVENT_CLASS[][] = {"weaponbox", "grenade"}
	
	
	for (new i = 0; i < sizeof PREVENT_CLASS; i++)
		if (equal(szClassName, PREVENT_CLASS[i]))
			return 1
			
	return 0
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
