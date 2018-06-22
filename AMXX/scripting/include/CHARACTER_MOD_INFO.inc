#if defined _csred_CharacterConfig_included
  #endinput
#endif
#define _csred_CharacterConfig_included

#include <amxmodx>

#define MAX_CHARACTER 64 // The maxium number of character can be registered


enum
{
	LINE_NAME,
	LINE_MODEL,
	LINE_HP,
	LINE_SPEED,
	LINE_GRAVITY,
	LINE_COST,
	LINE_GENDER,
	LINE_SUBHAND,
	LINE_HEALTH_HUD,
	LINE_SERIAL,
	LINE_SPECIAL_CHARACTER
}


enum
{
	GENDER_MALE,
	GENDER_FEMALE
}



/********************************************************************************/

/*			RADIO CODE AND THE WAV FILE			*/

stock CS_RADIO_CODE[][] = {"%!MRAD_COVERME","%!MRAD_POSITION","%!MRAD_REGROUP","%!MRAD_FOLLOWME" ,"%!MRAD_HITASSIST","%!MRAD_GO","%!MRAD_STICKTOG","%!MRAD_GETINPOS","%!MRAD_STORMFRONT","%!MRAD_ROGER"
,"%!MRAD_BACKUP" ,"%!MRAD_CLEAR","%!MRAD_INPOS","%!MRAD_BLOW","%!MRAD_NEGATIVE" ,"%!MRAD_ENEMYDOWN", "%!MRAD_FIREINHOLE", "%!MRAD_ENEMYSPOT", "%!MRAD_AFFIRM", "%!MRAD_GO",
"%!MRAD_CTWIN", "%!MRAD_TERWIN", "%!MRAD_ROUNDDRAW", "%!MRAD_BOMBPL", "%!MRAD_BOMBDEF",
"%!MRAD_REPORTIN", "%!MRAD_TAKEPOINT", "%!MRAD_LETSGO",
"%!MRAD_LOCKNLOAD", "%!MRAD_MOVEOUT", "%!MRAD_VIP", "%!MRAD_rescued"}

stock szRadioWav[][] = {"ct_coverme.wav","position.wav","regroup.wav","followme.wav", "hitassist.wav","go.wav", "sticktog.wav","com_getinpos.wav","stormfront.wav",
			"roger.wav","ct_backup.wav","clear.wav","ct_inpos.wav","blow.wav","negative.wav","enemydown.wav", "ct_fireinhole.wav", "ct_enemys.wav", "ct_affirm.wav", "go.wav",
			"ctwin.wav", "terwin.wav", "rounddraw.wav", "bombpl.wav", "bombdef.wav",
"ct_reportingin.wav", "takepoint.wav", "letsgo.wav" ,
"locknload.wav", "moveout.wav", "vip.wav", "rescued.wav"}

/************************************************************************/

/*			ROUND MESSAGE RADIO - PLAYED WHEN ROUND ENDS		*/

// Round message - Male Soldier
#define M_BL_LOOSE  	"radio/message/M_BL_LOOSE.wav"
#define M_GR_LOOSE	"radio/message/M_GR_LOOSE.wav"
#define M_BL_WIN 	"radio/message/M_BL_WIN.wav"
#define M_GR_WIN 	"radio/message/M_GR_WIN.wav"
#define M_MSG_DRAW 	"radio/message/M_MSG_DRAW.wav"

// Round message - Female Soldier

#define W_BL_LOOSE 	"radio/message/W_BL_LOOSE.wav"
#define W_GR_LOOSE 	"radio/message/W_GR_LOOSE.wav"
#define W_BL_WIN  	"radio/message/W_BL_WIN.wav"
#define W_GR_WIN 	"radio/message/W_GR_WIN.wav"
#define W_MSG_DRAW	"radio/message/W_MSG_DRAW.wav"
#define W_MSG_BOMB_PL "radio/message/WM_Bomb_Plant_GR.wav"


stock find_internal_model_pos(iInternalModel, &iTeam)
{
	if (iInternalModel == MODEL_DONT_CHANGE)
		return 0

	for (new iTerroristIndexPos = 0;  iTerroristIndexPos < sizeof T_INTERNAL_MODEL_INDEX; iTerroristIndexPos++)
	{
		if (iInternalModel = T_INTERNAL_MODEL_INDEX[iTerroristIndexPos])
		{
			iTeam == 1
			return iTerroristIndexPos
		}
	}
	
	for (new iCtIndexPos = 0;  iCtIndexPos < sizeof T_INTERNAL_MODEL_INDEX; iCtIndexPos++)
	{
		if (iInternalModel = T_INTERNAL_MODEL_INDEX[iCtIndexPos])
		{
			iTeam == 2
			return iCtIndexPos
		}
	}
	return 0
}