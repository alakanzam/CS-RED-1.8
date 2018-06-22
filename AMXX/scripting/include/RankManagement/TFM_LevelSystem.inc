/*================================================================================
	CSRED LEVEL SYSTEM FILE
	
=================================================================================*/
#if defined _csred_LevelSystem_included
  #endinput
#endif
#define _csred_LevelSystem_included
enum
{
	LEVEL_HOCVIEN1,
	LEVEL_HOCVIEN2,
	LEVEL_TANBINH,
	LEVEL_BINHBET,
	LEVEL_BINHNHI,
	LEVEL_BINHNHAT1,
	LEVEL_BINHNHAT2,
	LEVEL_BINHNHAT3,
	LEVEL_BINHNHAT4,
	LEVEL_HASI1,
	LEVEL_HASI2,
	LEVEL_HASI3,
	LEVEL_HASI4,
	LEVEL_HASI5,
	LEVEL_HASI6,
	LEVEL_TRUNGSI1,
	LEVEL_TRUNGSI2,
	LEVEL_TRUNGSI3,
	LEVEL_TRUNGSI4,
	LEVEL_TRUNGSI5,
	LEVEL_TRUNGSI6,
	LEVEL_THUONGSI1,
	LEVEL_THUONGSI2,
	LEVEL_THUONGSI3,
	LEVEL_THUONGSI4,
	LEVEL_THUONGSI5,
	LEVEL_THUONGSI6,
	LEVEL_THIEUUY1,
	LEVEL_THIEUUY2,
	LEVEL_THIEUUY3,
	LEVEL_THIEUUY4,
	LEVEL_THIEUUY5,
	LEVEL_THIEUUY6,
	LEVEL_THIEUUY7,
	LEVEL_THIEUUY8,
	LEVEL_TRUNGUY1,
	LEVEL_TRUNGUY2,
	LEVEL_TRUNGUY3,
	LEVEL_TRUNGUY4,
	LEVEL_TRUNGUY5,
	LEVEL_TRUNGUY6,
	LEVEL_TRUNGUY7,
	LEVEL_TRUNGUY8,
	LEVEL_THUONGUY1,
	LEVEL_THUONGUY2,
	LEVEL_THUONGUY3,
	LEVEL_THUONGUY4,
	LEVEL_THUONGUY5,
	LEVEL_THUONGUY6,
	LEVEL_THUONGUY7,
	LEVEL_THUONGUY8,
	LEVEL_THIEUTA1,
	LEVEL_THIEUTA2,
	LEVEL_THIEUTA3,
	LEVEL_THIEUTA4,
	LEVEL_THIEUTA5,
	LEVEL_THIEUTA6,
	LEVEL_THIEUTA7,
	LEVEL_THIEUTA8,
	LEVEL_TRUNGTA1,
	LEVEL_TRUNGTA2,
	LEVEL_TRUNGTA3,
	LEVEL_TRUNGTA4,
	LEVEL_TRUNGTA5,
	LEVEL_TRUNGTA6,
	LEVEL_TRUNGTA7,
	LEVEL_TRUNGTA8,
	LEVEL_DAITA1,
	LEVEL_DAITA2,
	LEVEL_DAITA3,
	LEVEL_DAITA4,
	LEVEL_DAITA5,
	LEVEL_DAITA6,
	LEVEL_DAITA7,
	LEVEL_DAITA8,
	LEVEL_THIEUTUONG1,
	LEVEL_THIEUTUONG2,
	LEVEL_THIEUTUONG3,
	LEVEL_THIEUTUONG4,
	LEVEL_THIEUTUONG5,
	LEVEL_THIEUTUONG6,
	LEVEL_TRUNGTUONG1,
	LEVEL_TRUNGTUONG2,
	LEVEL_TRUNGTUONG3,
	LEVEL_TRUNGTUONG4,
	LEVEL_TRUNGTUONG5,
	LEVEL_TRUNGTUONG6,
	LEVEL_THUONGTUONG1,
	LEVEL_THUONGTUONG2,
	LEVEL_THUONGTUONG3,
	LEVEL_THUONGTUONG4,
	LEVEL_THUONGTUONG5,
	LEVEL_THUONGTUONG6,
	LEVEL_DAITUONG1,
	LEVEL_DAITUONG2,
	LEVEL_DAITUONG3,
	LEVEL_DAITUONG4,
	LEVEL_DAITUONG5,
	LEVEL_DAITUONG6
}



















/*	Get level of a player             */
native TFM_get_user_level(id)


/*               How many coins player has         */
native TFM_get_user_coin(id)

/*               Set coins to a player              */
native TFM_set_user_coin(id, iCoin)

/*               Add coin to a player              */
native TFM_award_user_coin(id, iCoin)

/*               How many Game points player has         */
native TFM_get_user_gp(id)

/*               Set coins to a player              */
native TFM_set_user_gp(id, iCoin)

/*               Add coin to a player              */
native TFM_award_user_gp(id, iCoin)






/*              What is the highest level        */
native TFM_get_max_level()

/*              Return name of a level            */
native TFM_get_level_name(iLevel, szLevelName[], iTextLen)

/*              Save player's level with an account       */
native TFM_save_user_level(id, szAccount[])

/*             Load level from an account          */
native TFM_load_user_level(id, szAccount[])

/*            Get player's level point                 */
native TFM_get_user_point(id)

/*            Award level point to a player       */
native TFM_award_user_point(id, iPoint)

/*           Get awarded coin of a player       */
native TFM_get_awarded_coin(id)

/*           Get awarded gp of a player       */
native TFM_get_awarded_gp(id)

/*	Get awarded point of a player	*/
native TFM_get_awarded_point(id)

/*           Check if player is promoted      */
native TFM_is_user_promoted(id)

/*          Get account of a player             */
native TFM_get_user_account(id, szAccount[], iLen)

/*          Give player an account - Level information will be saved in it         */
native TFM_set_user_account(id, szAccount[])

/*          Set return of awarded gp   */
native TFM_set_gp_return(id, iGP)

/*          Set return of awarded coin   */
native TFM_set_coin_return(id, iCOIN)

/*          Set return of awarded point  */
native TFM_set_point_return(id, iPOINT)





/*********************** FORWARD *******************/



/*             Called when a player promoted          */
forward TFM_player_promoted(id, iLevel)

/*              Called when a player is awarded GP           */
forward TFM_user_awarded_gp(id, iGP)

/*              Called when a player is awarded COIN           */
forward TFM_user_awarded_coin(id, iCOIN)

/*              Called when a player awarded Point             */
forward TFM_user_awarded_point(id, iPOINT)

/*	Called when a player awarded point	*/
forward TFM_user_awarded_point(id, iPoint)

/*               Called when a player saving his level information        */
forward TFM_saving_level_info(id)