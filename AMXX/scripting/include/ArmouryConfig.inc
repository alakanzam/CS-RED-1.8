#if defined _csred_ArmouryConfig_included
  #endinput
#endif
#define _csred_ArmouryConfig_included

#define CSRED_DEFAULT_W_MODEL "models/default_weapon.mdl"

new const DEFAULT_WEAPON_CLASSNAME[][] = 
{
	"NULL",	// ---
	"weapon_p228",	// P228
	"weapon_shield",	// ---
	"weapon_scout",	// SCOUT
	"weapon_hegrenade",	// HIGH EXPLOSIVE GRENADE
	"weapon_xm1014",	// XM1014
	"weapon_c4",	// C4 PLASTIC BOMB
	"weapon_mac10",	// MAC10
	"weapon_aug",	// AUG
	"weapon_smokegrenade",	// SMOKE GRENADE
	"weapon_elite",	// ELITE
	"weapon_fiveseven",	// FIVESEVEN
	"weapon_ump45",	// UMP45
	"weapon_sg550",	// SG550
	"weapon_galil",	// GALIL
	"weapon_famas",	// FAMAS
	"weapon_usp",	// USP
	"weapon_glock18",	// GLOCK18
	"weapon_awp",	// AWP
	"weapon_mp5navy",	// MP5NAVY
	"weapon_m249",	// M249
	"weapon_m3",	// M3
	"weapon_m4a1",	// M4A1
	"weapon_tmp",	// TMP
	"weapon_g3sg1",	// G3SG1
	"weapon_flashbang",	// FLASH GRENADE
	"weapon_deagle",	// DEAGLE
	"weapon_sg552",	// SG552
	"weapon_ak47",	// AK47
	"NULL",	// ---
	"weapon_p90",	// P90
	"ARMOR_1",
	"ARMOR_2"
}

new ArmouryItemList[] = 
{
	CSW_USP,
	CSW_GLOCK18,
	CSW_DEAGLE,
	CSW_P228,
	CSW_ELITE,
	CSW_FIVESEVEN,
	CSW_M3,
	CSW_XM1014,
	CSW_MP5NAVY,
	CSW_TMP,
	CSW_P90,
	CSW_MAC10,
	CSW_UMP45,
	CSW_FAMAS,
	CSW_GALIL,
	CSW_AK47,
	CSW_M4A1,
	CSW_SG552, 
	CSW_AUG,
	CSW_SCOUT,
	CSW_AWP,
	CSW_G3SG1,
	CSW_SG550,
	CSW_M249,
	CSW_HEGRENADE,
	CSW_SMOKEGRENADE,
	CSW_HEGRENADE,
	CSW_VEST,
	CSW_VESTHELM
}

new ArmouryItemModel[][] = 
{
	CSRED_DEFAULT_W_MODEL,	// ---
	CSRED_DEFAULT_W_MODEL,	// P228
	CSRED_DEFAULT_W_MODEL,	// ---
	CSRED_DEFAULT_W_MODEL,	// SCOUT
	CSRED_DEFAULT_W_MODEL,	// HIGH EXPLOSIVE GRENADE
	CSRED_DEFAULT_W_MODEL,	// XM1014
	CSRED_DEFAULT_W_MODEL,	// C4 PLASTIC BOMB
	CSRED_DEFAULT_W_MODEL,	// MAC10
	CSRED_DEFAULT_W_MODEL,	// AUG
	CSRED_DEFAULT_W_MODEL,	// SMOKE GRENADE
	CSRED_DEFAULT_W_MODEL,	// ELITE
	CSRED_DEFAULT_W_MODEL,	// FIVESEVEN
	CSRED_DEFAULT_W_MODEL,	// UMP45
	CSRED_DEFAULT_W_MODEL,	// SG550
	CSRED_DEFAULT_W_MODEL,	// GALIL
	CSRED_DEFAULT_W_MODEL,	// FAMAS
	CSRED_DEFAULT_W_MODEL,	// USP
	CSRED_DEFAULT_W_MODEL,	// GLOCK18
	CSRED_DEFAULT_W_MODEL,	// AWP
	CSRED_DEFAULT_W_MODEL,	// MP5NAVY
	CSRED_DEFAULT_W_MODEL,	// M249
	CSRED_DEFAULT_W_MODEL,	// M3
	CSRED_DEFAULT_W_MODEL,	// M4A1
	CSRED_DEFAULT_W_MODEL,	// TMP
	CSRED_DEFAULT_W_MODEL,	// G3SG1
	CSRED_DEFAULT_W_MODEL,	// FLASH GRENADE
	CSRED_DEFAULT_W_MODEL,	// DEAGLE
	CSRED_DEFAULT_W_MODEL,	// SG552
	CSRED_DEFAULT_W_MODEL,	// AK47
	CSRED_DEFAULT_W_MODEL,	// ---
	CSRED_DEFAULT_W_MODEL,	// P90
	CSRED_DEFAULT_W_MODEL,
	CSRED_DEFAULT_W_MODEL
}

new ArmouryItemSubModel[] = 
{
	0,	// ---
	21,	// P228
	0,	// ---
	32,	// SCOUT
	23,	// HIGH EXPLOSIVE GRENADE
	15,	// XM1014
	27,	// C4 PLASTIC BOMB
	13,	// MAC10
	3,	// AUG
	24,	// SMOKE GRENADE
	18,	// ELITE
	20,	// FIVESEVEN
	12,	// UMP45
	31,	// SG550
	6,	// GALIL
	1,	// FAMAS
	22,	// USP
	20,	// GLOCK18
	4,	// AWP
	14,	// MP5NAVY
	9,	// M249
	7,	// M3
	8,	// M4A1
	11,	// TMP
	5,	// G3SG1
	25,	// FLASH GRENADE
	17,	// DEAGLE
	10,	// SG552
	2,	// AK47
	2,	// ---
	2,	// P90
	2,
	2
}

new ArmouryItemFileName[][] = 
{
	"NULL",	// ---
	"weapon_p228",	// P228
	"weapon_shield",	// ---
	"weapon_scout",	// SCOUT
	"weapon_hegrenade",	// HIGH EXPLOSIVE GRENADE
	"weapon_xm1014",	// XM1014
	"weapon_c4",	// C4 PLASTIC BOMB
	"weapon_mac10",	// MAC10
	"weapon_aug",	// AUG
	"weapon_smokegrenade",	// SMOKE GRENADE
	"weapon_elite",	// ELITE
	"weapon_fiveseven",	// FIVESEVEN
	"weapon_ump45",	// UMP45
	"weapon_sg550",	// SG550
	"weapon_galil",	// GALIL
	"weapon_famas",	// FAMAS
	"weapon_usp",	// USP
	"weapon_glock18",	// GLOCK18
	"weapon_awp",	// AWP
	"weapon_mp5navy",	// MP5NAVY
	"weapon_m249",	// M249
	"weapon_m3",	// M3
	"weapon_m4a1",	// M4A1
	"weapon_tmp",	// TMP
	"weapon_g3sg1",	// G3SG1
	"weapon_flashbang",	// FLASH GRENADE
	"weapon_deagle",	// DEAGLE
	"weapon_sg552",	// SG552
	"weapon_ak47",	// AK47
	"NULL",	// ---
	"weapon_p90",	// P90
	"item_kevlar",
	"item_kevlar+helmet"
}


