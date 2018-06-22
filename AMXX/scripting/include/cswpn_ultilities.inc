/* Core functions
*
* (c) Copyright 1998-2003, ITB CompuPhase
*
* This file is provided as is (no warranties).
*/

#if defined _cswpn_ultilites_included
  #endinput
#endif
#define _cswpn_ultilites_included

#define ADS_OPTION	1


/*		ACCURACY CONFIG		*/

#define ACCURACY_CROUCH	0.2
#define ACCURACY_CROUCH_MOVING	-0.185
#define ACCURACY_STAND	0.0
#define ACCURACY_RUNNING	-0.3
#define ACCURACY_ADS	0.25
#define FOV_ACCURACY_INCREASE 	0.0035

/*		RECOIL CONFIG		*/
#define RECOIL_CROUCH	-0.2
#define RECOIL_CROUCH_MOVING	-0.15
#define RECOIL_STAND	0.0
#define RECOIL_RUNNING	-0.3
#define RECOIL_ADS	0.25



/*************************************************/

native UT_MakeWpnPrimAtk(iEnt)
native UT_MakeWpnSecAtk(iEnt)
native UT_MakeWpnReload(iEnt)

native UT_SendCurWeaponMsg(id, iStatus, iWeaponId, iClip, iEngineMessage)
native UT_UpdateWpnList(id, iCsWpnId, iClip, szWpnClass[], iMaxBp ,iSendCurWeaponMsg)

native UT_HL_Crosshair_Toggle(id, iToggle, iEngineMessage)
native UT_CS_Crosshair_Toggle(id, iToggle, iEngineMessage)
native UT_DropPrimaryWeapon(id)
native UT_StripPrimaryWeapon(id)
native UT_DropSecondaryWeapon(id)
native UT_StripPlayerWeapon(id, szWeapon[])

native UT_Get_CS_FireSound(iWeaponId, iInSpecial, szOutput[], iLen)
native UT_Get_CS_SoundIndex(iWeaponId, iInSpecial)

native Float:UT_Get_CS_Reload_Time(iWeaponId)
native Float:UT_Get_CS_Speed(iWeaponId)
native Float:UT_Get_CS_Weight(iWeaponId)
native Float:UT_Get_CS_StartAdsTime(iWeaponId)
native Float:UT_Get_CS_EndAdsTime(iWeaponId)
native Float:UT_Get_CS_ROF(iWeaponId)
native Float:UT_Get_CS_ROF_ADS(iWeaponId)
native Float:UT_Get_CS_Accuracy(iWeaponId)
native Float:UT_Get_CS_Recoil_Ads(iWeaponId)
native Float:UT_Get_CS_Start_IS(iWeaponId)
native Float:UT_Get_CS_Finish_IS(iWeaponId)
native UT_Get_CS_WpnModel(iWeaponId, szOutput[], iLen)
native UT_Get_CS_ReloadType(iWeaponId)
native UT_Get_CS_Crosshair(iWeaponId)
native UT_StripSecondaryWeapon(id)

native Get_CSWPN_StandIdle(iWeaponId)
native Get_CSWPN_StandShoot(iWeaponId)
native Get_CSWPN_StandReload(iWeaponId)

native Get_CSWPN_CrouchIdle(iWeaponId)
native Get_CSWPN_CrouchShoot(iWeaponId)
native Get_CSWPN_CrouchReload(iWeaponId)

native Get_CSWPN_Anim_Shoot1(iWeaponId)
native Get_CSWPN_Anim_Shoot2(iWeaponId)
native Get_CSWPN_Anim_Shoot3(iWeaponId)

native Get_CSWPN_MaxAnimation(iWeaponId)

native UT_WorldModelToWeaponId(szWorldModel[])
native UT_WeaponIdToWorldModel(iWeaponId, szModel[], iLen)


native UT_Get_CS_Name(iWeaponId, szName[], iLen)
native UT_Get_CS_ADS_State(iWeaponId)
native UT_Get_CS_SemiWpn(iWeaponId)
native UT_Get_CS_ADS_FOV(iWeaponId)

native UT_PlayWeaponAnim(id, iAnimation)
native UT_GiveDamageToEntity(iEntity, iDmgInflictor, iId, Float:fDamage, iDMG_TYPE)
native UT_Get_CS_DefaultClip(iWeaponId)
native UT_Get_CS_DefaultBpa(iWeaponId)
native UT_StripWeaponEnt(id, iEnt)

native UT_SetUserBPA(id, iWeaponId, iBpa)
native UT_GetUserBPA(id, iWeaponId)

native Get_CSWPN_Anim_Draw(iWeaponId, iSilencer = 0, iHasShield = 0)
native Get_CSWPN_Anim_Reload(iWeaponId, iSilencer = 0, iShield = 0)
native Get_CSWPN_Anim_Idle(iWeaponId, bool:Silencer)

native UT_CreateShotgunBullet(id, iWeaponEnt, cShots, Float:flSpread, DMG_TYPE, Float:fDamage, Float:fPropertyDistance)
native UT_CreateBullet(id, iWeaponEnt, Float:flSpread, DMG_TYPE, Float:fDamage, Float:fPropertyDistance)

native UT_DrawPickUpHud(id, szHudItem[], iEngineMsg)
native UT_DrawAmmoPickUp(id, iWeaponId, iAmount, iEngineMessage)
native UT_IsBombTargetedEnt(iEnt)
native UT_GetWeaponExtension(iWeaponId, iIsShield, szExtension[], iLen)
native UT_SetPlayerSequence(id, szSequence[])
native UT_GetPlayerSequence(id, szSequence[], iLen)
native UT_IsBrushEnt(szClassName[])
native UT_MeleeAttack(iPlayer,  iStab, Float:fDamage, Float:fRange, iDamageBit, iCreateSpark, szWallSound[], szBodySound[])
native UT_Get_CS_Hud(iWeaponId, szHud[], iLen)
native UT_GiveUserWeapon(id, iWeaponId, iGiveAmmo = 0)
native UT_Get_CS_Cost(iWeaponId)
native UT_Get_CS_CostType(iWeaponId)
native Float:UT_Get_CS_DeployTime(iWeaponId)

forward csred_ItemDrop_Pre(id, iEnt, iWeaponId)

forward csred_WpnPrimAtk_Pre(id, iEnt, iWeaponId)

forward csred_WpnPrimAtk_Post(id, iEnt, iWeaponId)

forward csred_WpnSecAtk_Pre(id, iEnt, iWeaponId)

forward csred_WpnSecAtk_Post(id, iEnt, iWeaponId)

forward csred_WpnReload_Pre(id, iEnt, iWeaponId)

forward csred_WpnReload_Post(id, iEnt, iWeaponId)

forward csred_WpnPostFrame(id, iEnt, iWeaponId)

forward csred_WpnDeploy_Pre(id, iEnt, iWeaponId)

forward csred_WpnDeploy_Post(id, iEnt, iWeaponId)

forward csred_WpnAttachToPlayer(id, iEnt, iWeaponId)
forward csred_WpnAttachToPlayerPost(id, iEnt, iWeaponId)
forward csred_ShieldAttached(id, iEnt)
forward csred_ShieldTouched(id, iEnt)
forward csred_WpnIdle_Pre(id, iEnt, iWeaponId)
forward csred_WpnIdle_Post(id, iEnt, iWeaponId)
forward WU_WpnPlayAnim_Pre(id, iEnt, iWeaponId, iAnim)
forward WU_WpnPlayAnim_Post(id, iEnt, iWeaponId, iAnim)
forward csred_WpnBoxThink_Pre(id, iEnt)
forward csred_WpnBoxThink_Post(id, iEnt)

forward csred_WpnHolster_Pre(id, iEnt)
forward csred_WpnHolster_Post(id, iEnt)
forward TFM_RemovePlayItem_Pre(id, iEnt, iWeaponId)

forward csred_EventPlaying(id, iWeaponId, iEventId, iWeaponEnt)
forward csred_WeaponTraceAttack(iVictim, iAttacker, Float:fDamage, Float:X, Float:Y, Float:Z, tracehandle, damagebits)



#define PRIMARY_WEAPONS_BITSUM	((1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90))
#define SECONDARY_WEAPONS_BITSUM 	((1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE)|(1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN))	
#define GRENADES_BITSUM  ((1<<CSW_HEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_SMOKEGRENADE))	
#define WEAPONS_BITSUM  ((1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE)|(1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_HEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_SMOKEGRENADE))	

stock is_primary_wpn(iWeaponId)
	return (PRIMARY_WEAPONS_BITSUM & (1<<iWeaponId))

stock is_secondary_wpn(iWeaponId)	
	return (SECONDARY_WEAPONS_BITSUM & (1<<iWeaponId))

stock is_grenade(iWeaponId)	
	return (GRENADES_BITSUM & (1<<iWeaponId))

stock is_valid_weapon(iWeaponId)
{
	if (iWeaponId < CSW_P228 || iWeaponId > CSW_P90 || iWeaponId == 2)
		return 0
	return 1
}
	
