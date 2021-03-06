/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <g4u_wpn>


#define PLUGIN "[TFM] Shop"
#define VERSION "1.0"
#define AUTHOR "Redplane"

/*
- NAME
- PRICE
- POSITION
- TFM <Weapon belongs to TFM plugins>
- TFM ID
*/

/*			TRIE SECTION			*/
new Trie:iItemInfo

/*			  TRIE KEY			*/

#define KEY_ITEM_NAME	"NAME"
#define KEY_ITEM_PRICE	"PRICE"
#define KEY_ITEM_POS	"POS"
#define KEY_ITEM_TFM	"TFM"
#define KEY_ITEM_TFM_ID	"TFM_ID"

/*			  MENU ID			*/

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	if (!iItemInfo)
		iItemInfo = TrieCreate()
}

public PW_WeaponLoaded(iPrimaryWpnId)
{
}

stock SELECTED_SHOP_ITEM(id, fArg[], sArg[], iCOST_TYPE, iCOST, iLEVEL)
{
		
	if (!is_user_alive(id))
		return
	
		
	new szInventoryFile[128], szAccount[64]
	
	TrieGetString(iPersonalInfo[id], INFO_ACCOUNT, szAccount, sizeof szAccount - 1)
	
	formatex(szInventoryFile, sizeof szInventoryFile - 1, "%s/binfo_%s.dlhc", NVAULT_DIRECTORY, szAccount)
	
	
	new Float:origin[3]
	pev(id, pev_origin, origin)
	
	if (vector_distance(fPlayerOrigin[id], origin) >= max_distance)
	{
		client_print(id, print_center, "%L", id, "OUT_OF_BUYZONE")
		return
	}
	
	new iBagSlot = current_bag[id]
	
	if (iBagSlot < 0)
		iBagSlot = 0
	else if (iBagSlot > MAX_BAG - 1)
		iBagSlot = MAX_BAG - 1
		
	
	if (csred_get_user_level(id) < iLEVEL)
	{
		new szLevelName[64]
		csred_get_level_name(iLEVEL, szLevelName, sizeof szLevelName - 1)
		client_print(id, print_center, "%L", id, "CSRED_REACHED_LEVEL_TO_EQUIP", szLevelName)
		return
	}
		
		
	if (iCOST_TYPE == COST_GP)
	{
		if (iCOST > csred_get_user_gp(id))
		{
			client_print(id, print_center, "%L", id, "CSRED_NOT_ENOUGH_GP")
			return
		}
	}
	else
	{
		if (iCOST > csred_get_user_coin(id))
		{
			client_print(id, print_center, "%L", id, "CSRED_NOT_ENOUGH_COIN")
			return
		}
	}
	
	new iSUCCESS = 0
	
	new szFullModel[256]
	new szWeaponName[128]
	new szItemInfo[256]
	
	if (equal(fArg, "NP", 2) ||  equal(fArg, "nP", 2) || equal(fArg, "Np", 2) || equal(fArg, "np", 2))
	{//	DEFAULT PISTOL OF CS
	
		formatex(szFullModel, sizeof szFullModel - 1, "models/w_%s.mdl", sArg)
		
		new iPISTOL_ID = UT_WorldModelToWeaponId(szFullModel)
		
		if (map_type != EQUIP_FULL && map_type != EQUIP_PISTOL)
			return 
			
		if (!iPISTOL_ID)
			return
			
		//client_print(id, print_center, "%d", modelindex)
		
		iSecondaryId[id][iBagSlot] = iPISTOL_ID
		iSecondaryWpnType[id][iBagSlot] = 1
		secondary_wpn_strip(id)
		
		_equip_pistol(id, iBagSlot)
		
		if (!AUTO_LOGIN)
		{
			
			formatex(szItemInfo, sizeof szItemInfo - 1, "[secondary]%s", szFullModel)
			new LinePos = 1 + iBagSlot * 4 
			write_file(szInventoryFile, szItemInfo, LinePos)
		}
		
		formatex(szWeaponName, sizeof szWeaponName - 1, DEFAULT_WEAPON_NAME[iPISTOL_ID])
		
		iSUCCESS = 1
		
	}
	if (equal(fArg, "PS", 2) ||  equal(fArg, "Ps", 2) || equal(fArg, "pS", 2) || equal(fArg, "ps", 2))
	{// WEAPONS OF CSRED PISTOL
	
		formatex(szFullModel, sizeof szFullModel - 1, "models/g4u_wpn/%s/w_%s.mdl", sArg, sArg)
		new iPISTOL_ID = find_sec_wpn_by_model(szFullModel)
		
		if (map_type != EQUIP_FULL && map_type != EQUIP_PISTOL)
			return 
			
		
		SetPlayerBit(g_PlayerDroppingWeapon, id)
		new iResult = give_player_sec_wpn(id, iPISTOL_ID);
		ClearPlayerBit(g_PlayerDroppingWeapon, id)
		
		if (!iResult)
			return
		
		get_sec_wpn_name(iPISTOL_ID, szWeaponName, sizeof szWeaponName - 1)
		secondary_wpn_strip(id)
		
		
		iSecondaryId[id][iBagSlot] = iPISTOL_ID
		iSecondaryWpnType[id][iBagSlot] = 2
		
		
		_equip_pistol(id, iBagSlot)
		
		if (!AUTO_LOGIN)
		{
			
			formatex(szItemInfo, sizeof szItemInfo - 1, "[pistol]%s", szFullModel)
			new LinePos = 1 + iBagSlot * 4 
			write_file(szInventoryFile, szItemInfo, LinePos)
		}
		
		iSUCCESS = 1
	}
	else if (equal(fArg, "NR", 2) ||  equal(fArg, "nR", 2) || equal(fArg, "Nr", 2) || equal(fArg, "nr", 2))
	{//	DEFAULT RIFLE OF CS
	
		formatex(szFullModel, sizeof szFullModel - 1, "models/w_%s.mdl", sArg)
		
		
		if (map_type != EQUIP_FULL)
			return 
			
			
		new iPRIMARY_ID = UT_WorldModelToWeaponId(szFullModel)
			
		if (!iPRIMARY_ID)
			return
		
		if (!IsARifle(iPRIMARY_ID))
			return
		
		client_print(id, print_center, "ID : %d", iPRIMARY_ID)
		iPrimaryId[id][iBagSlot] = iPRIMARY_ID
		iPrimaryWpnType[id][iBagSlot] = 1
		
		primary_wpn_strip(id)
		
		give_primary_weapon(id, iBagSlot)
		
		if (!AUTO_LOGIN)
		{
			formatex(szItemInfo, sizeof szItemInfo - 1, "[primary]%s", szFullModel)
			new LinePos = 0 + iBagSlot * 4 
			write_file(szInventoryFile, szItemInfo, LinePos)
		}
	
		formatex(szWeaponName, sizeof szWeaponName - 1,  DEFAULT_WEAPON_NAME[iPRIMARY_ID])
		
		iSUCCESS = 1

	}
	/*
	if (equal(fArg, "RF", 2) ||  equal(fArg, "Rf", 2) || equal(fArg, "rF", 2) || equal(fArg, "rf", 2))
	{//	WEAPONS OF CSRED RIFLE
	
		formatex(szFullModel, sizeof szFullModel - 1, "models/g4u_wpn/%s/w_%s.mdl", sArg, sArg)
		
		new iRIFLE_ID = g4u_rifle_id_by_model(szFullModel, sizeof szFullModel - 1)
		
		
		if (map_type != EQUIP_FULL)
			return
		
		SetPlayerBit(g_PlayerDroppingWeapon, id);
		new iResult = g4u_equip_riffle(id, iRIFLE_ID, 0, 0);
		ClearPlayerBit(g_PlayerDroppingWeapon, id)
		
		if (!iResult)
			return
			
		
		g4u_set_rifle_full_ammo(id, 0, 0)
		
		g4u_get_riffle_name(iRIFLE_ID, szWeaponName, sizeof szWeaponName - 1)
		
		iPrimaryId[id][iBagSlot] = iRIFLE_ID
		iPrimaryWpnType[id][iBagSlot] = 2
		primary_wpn_strip(id)
		give_primary_weapon(id, iBagSlot)
		
		if (!AUTO_LOGIN)
		{
			
			formatex(szItemInfo, sizeof szItemInfo - 1, "[rifle]%s", szFullModel)
			new LinePos = 0 + iBagSlot * 4 
			write_file(szInventoryFile, szItemInfo, LinePos)
		}
		
		iSUCCESS = 1
	}
	*/
	else if (equal(fArg, "nk", 2) || equal(fArg, "Nk", 2) || equal(fArg, "NK", 2) || equal(fArg, "nK", 2))
	{//	DEFAULT KNIFE OF CS

		
		iMeleeId[id][iBagSlot] = 0
		iMeleeType[id][iBagSlot] = 1
		
		_equip_melee(id, iBagSlot)
		
		if (!AUTO_LOGIN)
		{
			formatex(szItemInfo, sizeof szItemInfo - 1, "[normal]")
			new LinePos = 2 + iBagSlot * 4 
			write_file(szInventoryFile, szItemInfo, LinePos)
		}
		

		formatex(szWeaponName, sizeof szWeaponName, "%L", id, "COMBAT_KNIFE")
		
		iSUCCESS = 1
		
	}
	else if (equal(fArg, "kf", 2) || equal(fArg, "Kf", 2) || equal(fArg, "KF", 2) || equal(fArg, "kF", 2))
	{//	WEAPONS OF CSRED KNIFE
	
		formatex(szFullModel, sizeof szFullModel - 1, "models/g4u_wpn/%s/v_%s.mdl", sArg, sArg)
		new iMelee = find_melee_by_model(szFullModel)
		
		
		get_melee_name(iMelee, szWeaponName, sizeof szWeaponName - 1)
		
		iMeleeId[id][iBagSlot] = iMelee
		iMeleeType[id][iBagSlot] = 2
		
		_equip_melee(id, iBagSlot)
		
		if (!AUTO_LOGIN)
		{
			
			formatex(szItemInfo, sizeof szItemInfo - 1, "[knife]%s", szFullModel)
			new LinePos = 2 + iBagSlot * 4 
			write_file(szInventoryFile, szItemInfo, LinePos)
		}
		
		iSUCCESS = 1
	}
	else if (equal(fArg, "GR", 2) ||  equal(fArg, "gR", 2) || equal(fArg, "Gr", 2) || equal(fArg, "gr", 2))
	{//	DEFAULT GRENADES OF CS
	
		new iGrenadeID
		formatex(szFullModel, sizeof szFullModel - 1, "models/w_%s.mdl", sArg)
		if (equal(szFullModel[7], "w_hegrenade", 11))
		{
			iGrenadeID = CSW_HEGRENADE
			engclient_cmd(id, "drop", "weapon_hegrenade")
			g4u_strip_user_grenade(id)
		}
		else if (equal(szFullModel[7], "w_smokegrenade", 14))
		{
			iGrenadeID = CSW_SMOKEGRENADE
			engclient_cmd(id, "drop", "weapon_smokegrenade")
			g4u_strip_smokegrenade(id)
		}
		else if (equal(szFullModel[7], "w_flashbang", 11))
		{
			iGrenadeID= CSW_FLASHBANG
			engclient_cmd(id, "drop", "weapon_flashbang")
		}
		else	return
			
		
		get_weaponname(iGrenadeID, szWeaponName, sizeof szWeaponName - 1)
		
		fm_give_item(id, szWeaponName)
		engclient_cmd(id, szWeaponName)
		
		iGrenadeId[id][iBagSlot] = iGrenadeID
		iGrenadeType[id][iBagSlot] = 1
		
		
		if (!AUTO_LOGIN)
		{
			formatex(szItemInfo, sizeof szItemInfo - 1, "[normal]%d", iGrenadeID)
			new LinePos = 3 + iBagSlot * 4 
			write_file(szInventoryFile, szItemInfo, LinePos)
		}
		
		
		iSUCCESS = 1
	}
	if (equal(fArg, "HE", 2) ||  equal(fArg, "He", 2) || equal(fArg, "hE", 2) || equal(fArg, "he", 2))
	{//	WEAPONS OF CSRED HEGRENADE
	
		formatex(szFullModel, sizeof szFullModel - 1, "models/g4u_wpn/%s/w_%s.mdl", sArg, sArg)
		
		new iHegrenadeID = g4u_agrenade_id_by_model(szFullModel, sizeof szFullModel - 1)
		
		if (map_type != EQUIP_FULL)
			return 
		
		engclient_cmd(id, "drop", "weapon_hegrenade")
		g4u_strip_user_grenade(id)
		
		new iResult = g4u_equip_nade(id, iHegrenadeID, 0)
		
		if (!iResult)
			return
	
		g4u_get_agrenade_name(iHegrenadeID, szWeaponName, sizeof szWeaponName - 1)
		
		iGrenadeId[id][iBagSlot] = iHegrenadeID
		iGrenadeType[id][iBagSlot] = 2
		
		
		if (!AUTO_LOGIN)
		{
	
			formatex(szItemInfo, sizeof szItemInfo - 1, "[hegrenade]%s", szFullModel)
			new LinePos = 3 + iBagSlot * 4 
			write_file(szInventoryFile, szItemInfo, LinePos)
		}
		
		
		iSUCCESS = 1
	}
	if (equal(fArg, "SM", 2) ||  equal(fArg, "Sm", 2) || equal(fArg, "sM", 2) || equal(fArg, "sm", 2))
	{//	WEAPONS OF CSRED SMOKE GRENADE
	
		formatex(szFullModel, sizeof szFullModel - 1, "models/g4u_wpn/%s/w_%s.mdl", sArg, sArg)
		new iSMK_ID = g4u_smk_id_by_model(szFullModel, sizeof szFullModel - 1)
		
		if (map_type != EQUIP_FULL)
			return 
		
		engclient_cmd(id, "drop", "weapon_smokegrenade")
		g4u_strip_smokegrenade(id)
		
		new iResult = g4u_equip_user_smokegrenade(id, iSMK_ID, 0)
		
		if (!iResult)
			return

		
		g4u_get_smokegrenade_name(iSMK_ID, szWeaponName, sizeof szWeaponName - 1)
		
		iGrenadeId[id][iBagSlot] = iSMK_ID
		iGrenadeType[id][iBagSlot] = 3
		
		if (!AUTO_LOGIN)
		{
			
			formatex(szItemInfo, sizeof szItemInfo - 1, "[smokegrenade]%s", szFullModel)
			new LinePos = 3 + iBagSlot * 4 
			write_file(szInventoryFile, szItemInfo, LinePos)
		}
		
		iSUCCESS = 1
		
	}
	if (equal(fArg, "DF", 2) ||  equal(fArg, "Df", 2) || equal(fArg, "dF", 2) || equal(fArg, "df", 2))
	{
		new CsTeams:team = cs_get_user_team(id)
		if (team != CS_TEAM_CT)
			return
	
		
		if (!AUTO_LOGIN)
		{
			formatex(szItemInfo, sizeof szItemInfo - 1, "[defuser]1")
			write_file(szInventoryFile, szItemInfo, 27)
		}
		cs_set_user_defuse(id, 1, 0, 0, 0, "", 0)
		
		formatex(szWeaponName, sizeof szWeaponName, "%L", id, "ITEM_DEFUSER")
		
		SetPlayerBit(g_HasDefuser, id)
		
		
		iSUCCESS = 1
		
	}
	else if (equal(fArg, "NG", 2) || equal(fArg, "nG", 2) || equal(fArg, "Ng", 2) || equal(fArg, "ng", 2))
	{
		
		
		cs_set_user_nvg(id, 1)
		
		
	
		UT_SetUserNVG_State(id, 1, 1)
		
		formatex(szWeaponName, sizeof szWeaponName - 1, "%L", id, "CSRED_NIGHT_VISION")
		iSUCCESS = 1
		
		if (!AUTO_LOGIN)
			write_file(szInventoryFile, "[NVG]1 0", 30 )
	}
	
	if (iSUCCESS)
	{
		client_print(id, print_center, "%L", id, "CSRED_BOUGHT_ITEM", szWeaponName)
		
		if (iCOST_TYPE == COST_GP)
			csred_set_user_gp(id, csred_get_user_gp(id) - iCOST)
		else
			csred_set_user_coin(id, csred_get_user_coin(id) - iCOST)
	}
	
	if (!AUTO_LOGIN && native_LoginStatus(id))
	{
		new szAccount[32]
		TrieGetString(iPersonalInfo[id], INFO_ACCOUNT, szAccount, sizeof szAccount - 1)
		csred_save_user_level(id, szAccount)
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
