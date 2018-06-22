#if defined _ArmorSystem_included
  #endinput
#endif
#define _ArmorSystem_included

enum
{
	ARMOR_TEAM_SOLDIER,
	ARMOR_TEAM_ZOMBIE,
	ARMOR_TEAM_BOTH
}


/*	Give an user a Armor		*/
native give_user_armor(id, iArmorId ,iAmount = 0 /*Auto Detection*/)

/*	Get ArmorId of an user	*/
native get_user_armor_id(id)

/*	Get ArmorId which contact to CSW_*	*/
native get_armor_real_id(iArmorId)

/*	Get amount of an Armor	*/
native get_armor_amount(iArmorId)

/*	Retrieve team id of an Armor	*/
native get_armor_team(iArmorId)

/*	Retrieve armor cost and cost type	*/
native get_armor_cost(iArmorId, iCostType, iCost)

/*	Retrieve decreasing Armor speed	*/
native Float:get_armor_speed(iArmorId)

/*	How heavy the armor is 		*/
native Float:get_armor_weight(iArmorId)

/*	Find armor by using its World Model	*/
native find_armor_by_model(szWorldModel[])

/*	Find armor by using its serial	*/
native find_armor_by_serial(szSerial[])


/*	Spawn an Armor at a defined point or at an Origin	*/
native set_armor_spawn(iArmouryPoint, iArmorId, Float:fOrigin[3])

/*	Load armor from a file	*/
native set_armor_load_file(szFile[], szExtension[], iIgnoreCondition)


/*		FORWARD		*/

//	Called when plugin checks if player can equip armor
forward AM_CanUserEquipArmor(id, iArmorId)

//	Called when plugin checks if player can touch armor
forward AM_CanUserTouchArmor(id, iArmorId)

//	Called when plugin precaches armor	
forward AM_PrecacheArmor()

//	Called when plugin check if the world model of Armor is valid	
forward AM_CheckArmorModel(iArmorId, szWorldModel[])

//	Called when Armoury Entity of Armor is being created	
forward AM_ArmorBeingCreated(iArmorId)

//	Called when plugin calculating damage done to Armor
forward AM_CalculatingArmorDmg(iVictim, inflictor, iAttacker, Float:fDamage, iDamagebit)