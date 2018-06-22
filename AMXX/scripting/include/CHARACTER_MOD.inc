// ******G4U CHARACTER ******//
#if defined _CHARACTER_MOD_included
  #endinput
#endif
#define _CHARACTER_MOD_included

#include <CHARACTER_MOD_INFO>

/*	Retrieve Character Id of a player	*/
native get_user_character(id)

/*	Retrieve Real Character Id of a player	*/
native get_user_character_2(id)

/*	Retrieve HP of a Character	*/
native get_character_health(iCharacterId, CsTeams:iTeam, iInternalModel)

/* 	Retrieve Speed of a Character	*/
native get_character_speed(iCharacterId, CsTeams:iTeam, iInternalModel)

/*	Retrieve Gender of a Character	*/
native get_character_gender(iCharacterId, CsTeams:iTeam)

/*	Retrieve Sub Hand of a Character	*/
native get_character_hand(iCharacterId, CsTeams:iTeam)

/*	Set Character to an user	*/
native set_user_character(id, iCharacterID, iUpdateId, iUpdateHealth)

/*	Retrieve number of registered Character	*/
native get_character_number()

/*	Retrieve Hud of a Character	*/
native get_character_hud(iCharacterId, CsTeams:iTeam,szHud[], iLen, iInternalModel)

/*	Retrieve Gravity of Character	*/
native Float:get_character_gravity(iCharacterId, CsTeams:iTeam, iInternalModel)

/*	Find Character by using Model	*/
native get_character_id_by_model(szModel[])

/*	Find Character by using Serial	*/
native get_character_id_by_serial(szSerialNumber[])

/*	Retrieve Character Cost Type	*/
native get_character_cost_type(iCharacterId)

/*	Retrieve price of Character Cost	*/
native get_character_cost(iCharacterId)

/* 	Play radio code	*/
native play_radio_code(iSender, szAudioCode[], iCustomGender, iGenderId, iCustomRadioDirectory, szMaleRadioDirectory[], szFemaleRadioDirectory[])

/*	Load character from file	*/
native load_character_file(szFileName[], szExtension[])

/*	Check if character is special or not	*/
native is_special_character(iCharacterId)

/*	Called when plugin check condition if a player can or can not send Radio message to anothers	*/
forward CM_CheckRadioCondition(iSender, iRecipient, iTeamCheck)

/*	Called when plugin prepares for emitiing radio message	*/
forward CM_PlayCsRadioCode(iSender, iRecipient, szAudioCode[])
