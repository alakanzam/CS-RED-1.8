/* - NO INFORMATION AVAILABLE - */

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <hamsandwich>
#include <fakemeta>

#include <CHARACTER_MOD_INFO>

#include <cstrike_pdatas>

#include <celltrie>

#define PLUGIN "Character System"
#define VERSION "1.7"
#define AUTHOR "Nguyen Duy Linh"


#define TASK_CZ_BOT_FUNCTION 2000



#define SOUND_FEMALE_DIE	"player/Die_HighDamage_GR.wav"
#define SOUND_FEMALE_HURT	"player/Die_LowDamage_GR.wav"




#define SECTION_NAME	"CHARACTER_NAME"

#define SECTION_MODEL_BL "CHARACTER_MODEL_BL"
#define SECTION_MODEL_GR "CHARACTER_MODEL_GR"


#define SECTION_MODEL_INDEX_BL "CHARACTER_MODEL_INDEX_BL"
#define SECTION_MODEL_INDEX_GR "CHARACTER_MODEL_INDEX_GR"

#define SECTION_HP_BL	"CHARACTER_HEALTH_BL"
#define SECTION_HP_GR 	"CHARACTER_HEALTH_GR"

#define SECTION_SPEED_BL	"CHARACTER_SPEED_BL"
#define SECTION_SPEED_GR	"CHARACTER_SPEED_GR"

#define SECTION_COST_TYPE "CHARACTER_COST_TYPE"
#define SECTION_COST	"CHARACTER_COST"

#define SECTION_HUD_BL	"CHARACTER_HUD_BL"
#define SECTION_HUD_GR	"CHARACTER_HUD_GR"

#define SECTION_GENDER_BL "CHARACTER_GENDER_BL"
#define SECTION_GENDER_GR "CHARACTER_GENDER_GR"

#define SECTION_HAND_BL "CHARACTER_HAND_BL"
#define SECTION_HAND_GR	"CHARACTER_HAND_GR"

#define SECTION_GRAVITY_BL "CHARACTER_GRAV_BL"
#define SECTION_GRAVITY_GR "CHARACTER_GRAV_GR"

#define SECTION_SERIAL	"CHARACTER_SERIAL"
#define SECTION_SPECIAL_CHARACTER "SPECIAL_CHARACTER"


new Trie:iCharacterInfo[MAX_CHARACTER]


new has_character[33]
new iOverrideMode[33]



new iHamCz



new iCharacterCount

new Trie:iRoundMessageRadio

#define CHARACTER_CONFIG_DIR	"CHARACTER_MOD/CONFIGS"
#define CHARACTER_SPEC_DIR	"CHARACTER_MOD/SPEC"
#define CHARACTER_ADD_DIR	"CHARACTER_MOD/ADD"

#define CHARACTER_MANAGER_DIR	"CHARACTER_MOD"
#define	CHARACTER_MANAGER_FILE	"MANAGER.CFG"


//	FORWARDS

new ifw_Result


new ifw_CheckRadioCondition
new ifw_PlayCSRadioCode


/****************************************** DEFAULT CONFIGURATION *********************************************/

#define DEFAULT_SPEED 230
#define DEFAULT_HEALTH 100
#define DEFAULT_GRAVITY 1.0
#define DEFAULT_HAND 0




/**************************************************************************************************************/

#define FEMALE_RADIO "radio/FEMALE" // Directory stores Radio sound of Femal Soilder
#define MALE_RADIO "radio"

#define WomanRealRadioDirectory "radio/real_sound/FEMALE" // Directory stores Real Radio sound of Female Soldier
#define ManRealRadioDirectory "radio/real_sound/MAN" // Directory stores Real Radio sound of Male Soldier

/**************************************************************************************************************/

public plugin_natives()
{
	register_native("get_user_character", "nt_get_user_character", 1)
	register_native("get_user_character_2", "nt_get_user_character_2", 1)
	
	register_native("get_character_health", "nt_get_character_health", 1)
	register_native("get_character_speed", "nt_get_character_speed", 1)
	register_native("get_character_gender", "nt_get_character_gender", 1)
	register_native("get_character_hand", "nt_get_character_hand", 1)
	register_native("set_user_character", "nt_set_user_character", 1)
	register_native("get_character_number", "nt_get_character_number", 1)
	register_native("get_character_hud", "nt_get_character_hud", 1)
	register_native("get_character_gravity", "nt_get_character_gravity", 1)
	
	register_native("get_character_id_by_model", "nt_get_character_id_by_model", 1)
	register_native("get_character_id_by_serial", "nt_get_character_id_by_serial", 1)
	
	register_native("get_character_cost_type", "nt_get_character_cost_type", 1)
	register_native("get_character_cost", "nt_get_character_cost", 1)
	
	register_native("is_special_character", "nt_is_special_character", 1)
	
	register_native("play_radio_code", "nt_play_radio_code", 1)
	register_native("load_character_file", "nt_load_character_file", 1)
	
}


public nt_get_user_character(id)
{
	if (!is_user_connected(id))
		return -1
		
	if (iOverrideMode[id] > -1)
		return iOverrideMode[id]
		
	return has_character[id]
}

public nt_get_user_character_2(id)
{
	if (!is_user_connected(id))
		return -1
		
	return has_character[id]
}

public nt_get_character_health(iCharacterId, CsTeams:iTeam, iInternalModel)
{	
	if (iCharacterId < 0 || iCharacterId > iCharacterCount - 1)
	{
		if (iInternalModel >= 0)
		{
			new CS_INTERNAL_HP[] = {DEFAULT_HEALTH, DEFAULT_HEALTH, DEFAULT_HEALTH, DEFAULT_HEALTH, DEFAULT_HEALTH, 
				DEFAULT_HEALTH, DEFAULT_HEALTH, DEFAULT_HEALTH, DEFAULT_HEALTH, 
				500, DEFAULT_HEALTH, DEFAULT_HEALTH}
			
			return CS_INTERNAL_HP[iInternalModel]
		}
		return DEFAULT_HEALTH
	}
	
	new iHealth = 100
	
	if (iTeam == CS_TEAM_CT)
		TrieGetCell(iCharacterInfo[iCharacterId], SECTION_HP_GR, iHealth)
	else	TrieGetCell(iCharacterInfo[iCharacterId], SECTION_HP_BL, iHealth)
	
	return iHealth
}

public nt_get_character_speed(iCharacterId, CsTeams:iTeam, iInternalModel)
{
	
	if (iCharacterId < 0 || iCharacterId > iCharacterCount - 1)
	{
		if (iInternalModel >= 0)
		{
			new CS_INTERNAL_SPEED[] = {DEFAULT_SPEED, DEFAULT_SPEED, DEFAULT_SPEED, DEFAULT_SPEED, DEFAULT_SPEED, 
				DEFAULT_SPEED, DEFAULT_SPEED, DEFAULT_SPEED, DEFAULT_SPEED, DEFAULT_SPEED + 20, DEFAULT_SPEED, 
				DEFAULT_SPEED}
			
			return CS_INTERNAL_SPEED[iInternalModel]
		}
		return DEFAULT_SPEED
	}
	
	
	new iSpeed
	
	if (iTeam == CS_TEAM_CT)	
		TrieGetCell(iCharacterInfo[iCharacterId], SECTION_SPEED_GR, iSpeed)
	else	TrieGetCell(iCharacterInfo[iCharacterId], SECTION_SPEED_BL, iSpeed)
	
	return iSpeed
}

public nt_get_character_gender(iCharacterId, CsTeams:iTeam)
{
	
	if (iCharacterId < 0 || iCharacterId > iCharacterCount - 1)
		return GENDER_MALE
			
	new iGender = GENDER_MALE
	
	if (iTeam == CS_TEAM_CT)
		TrieGetCell(iCharacterInfo[iCharacterId], SECTION_GENDER_GR, iGender)
	else	TrieGetCell(iCharacterInfo[iCharacterId], SECTION_GENDER_BL, iGender)
		
	return iGender
}

public nt_get_character_hand(iCharacterId, CsTeams:iTeam)
{
	if (iCharacterId < 0 || iCharacterId > iCharacterCount - 1)
		return DEFAULT_HAND
		
	new iSubHand
		
	if (iTeam == CS_TEAM_T)
		TrieGetCell(iCharacterInfo[iCharacterId], SECTION_HAND_BL, iSubHand)
	else if (iTeam == CS_TEAM_CT)
		TrieGetCell(iCharacterInfo[iCharacterId], SECTION_HAND_GR, iSubHand)
			
	return iSubHand
}

public nt_set_user_character(id, iCharacterID, iUpdateId, iUpdateHealth)
{
	if (iCharacterID < 0 || iCharacterID > iCharacterCount - 1)
		return 
		
	_set_user_character(id, iCharacterID, iUpdateId, iUpdateHealth)
}

public nt_get_character_number()
	return iCharacterCount

public nt_get_character_hud(iCharacterId, CsTeams:iTeam, szHud[], iLen, iInternalModel)
{
	param_convert(3)
	
	if (iCharacterId < 0 || iCharacterId > iCharacterCount - 1)
	{
		if (iInternalModel >= 0)
		{
			new CS_INTERNAL_HUD[][] = {"ARCTIC", "SEAL", "TERROR", "LEET", "ARCTIC", 
				"GSG9", "GIGN", "SAS", "GUERILLA", "VIP", "MILITIA", "SPETSNAZ"}
			
			formatex(szHud, iLen, CS_INTERNAL_HUD[iInternalModel])
		}
		return
	}
	
	
	
	if (iTeam == CS_TEAM_T)
		TrieGetString(iCharacterInfo[iCharacterId], SECTION_HUD_BL, szHud, iLen)
	else if (iTeam == CS_TEAM_CT)
		TrieGetString(iCharacterInfo[iCharacterId], SECTION_HUD_GR, szHud, iLen)
	
}

public Float:nt_get_character_gravity(iCharacterId, CsTeams:iTeam, iInternalModel)
{
	if (iCharacterId < 0 || iCharacterId > iCharacterCount - 1)
	{
		if (iInternalModel >= 0)
		{
			
			new Float:CS_INTERNAL_GRAVITY[] = {DEFAULT_GRAVITY, DEFAULT_GRAVITY, DEFAULT_GRAVITY, DEFAULT_GRAVITY, 
				DEFAULT_GRAVITY, DEFAULT_GRAVITY, DEFAULT_GRAVITY, DEFAULT_GRAVITY, 
				DEFAULT_GRAVITY, DEFAULT_GRAVITY, DEFAULT_GRAVITY, DEFAULT_GRAVITY}
				
			return CS_INTERNAL_GRAVITY[iInternalModel]
		}
		return DEFAULT_GRAVITY
	}
	
	new Float:fGravity = DEFAULT_GRAVITY
	
	if (iTeam == CS_TEAM_T)
		fGravity = get_trie_float(iCharacterInfo[iCharacterId], SECTION_GRAVITY_BL, DEFAULT_GRAVITY)
	else if (iTeam == CS_TEAM_CT)
		fGravity = get_trie_float(iCharacterInfo[iCharacterId], SECTION_GRAVITY_GR, DEFAULT_GRAVITY)
	 
	return fGravity
}

public nt_get_character_id_by_model(szModel[])
{
	param_convert(1)
	
	for (new i = 0; i < iCharacterCount; i++)
	{
		if (TrieKeyExists(iCharacterInfo[i], szModel))	
			return i
	}
	return -1
}

public nt_get_character_id_by_serial(szSerial[])
{
	param_convert(1)
	
	for (new i = 0; i < iCharacterCount; i++)
	{
		if (TrieKeyExists(iCharacterInfo[i], szSerial))
			return i
	}
	
	return -1
}

public nt_get_character_cost_type(iCharacterID)
{
	if (iCharacterID < 0 || iCharacterID > iCharacterCount - 1)
		return -1
		
	new iCharacterCostType 
	TrieGetCell(iCharacterInfo[iCharacterID], SECTION_COST_TYPE, iCharacterCostType)
	
	return iCharacterCostType
}

public nt_get_character_cost(iCharacterID)
{
	if (iCharacterID < 0 || iCharacterID > iCharacterCount - 1)
		return -1
		
	new iCharacterCost
	TrieGetCell(iCharacterInfo[iCharacterID], SECTION_COST_TYPE, iCharacterCost)
	return iCharacterCost
}

public nt_is_special_character(iCharacterID)
{
	if (iCharacterID < 0 || iCharacterID > iCharacterCount - 1)
		return 0
		
	new iIsSpecialCharacter
	TrieGetCell(iCharacterInfo[iCharacterID], SECTION_SPECIAL_CHARACTER, iIsSpecialCharacter)
	return iIsSpecialCharacter
		
}
public nt_play_radio_code(iSender, szAudioCode[], iCustomGender, iGenderId, iCustomRadioDirectory, szMaleRadioDirectory[], szFemaleRadioDirectory[])
{
	param_convert(2)
	param_convert(6)
	param_convert(7)
	
	play_radio_code(iSender, szAudioCode, iCustomGender, iGenderId, iCustomRadioDirectory, szMaleRadioDirectory, szFemaleRadioDirectory)
}

public nt_load_character_file(szFileName[], szExtension[])
{
	param_convert(1)
	param_convert(2)
	
	return load_character_config(CHARACTER_CONFIG_DIR, szFileName, szExtension)
}

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	forward_register()
	
	if (!iRoundMessageRadio)
		iRoundMessageRadio = TrieCreate()
	
	new RCODE_GR_WIN[] =  "%!MRAD_CTWIN"
	new RCODE_BL_WIN[] =  "%!MRAD_TERWIN"
	new RCODE_ROUND_DRAW[] = "%!MRAD_ROUNDDRAW"

	if (!TrieKeyExists(iRoundMessageRadio, RCODE_BL_WIN))
		TrieSetCell(iRoundMessageRadio, RCODE_BL_WIN, 1)
	if (!TrieKeyExists(iRoundMessageRadio, RCODE_GR_WIN))
		TrieSetCell(iRoundMessageRadio, RCODE_GR_WIN, 1)
	if (!TrieKeyExists(iRoundMessageRadio, RCODE_ROUND_DRAW))
		TrieSetCell(iRoundMessageRadio, RCODE_ROUND_DRAW, 1)
	
	register_message(get_user_msgid("SendAudio"), "fw_MessageSendRadio")
	register_event("SendAudio", "Event_Terrorists_Win", "a", "2&%!MRAD_terwin")
	register_event("SendAudio", "Event_Counter_Terrorist_Win", "a", "2&%!MRAD_ctwin")
	register_logevent("Event_RoundDraw" , 4, "1=Round_Draw" ); 
	register_forward(FM_EmitSound, "fw_EmitSound")
	register_forward(FM_ClientUserInfoChanged, "fw_ClientUserInfoChanged")
	
	RegisterHam(Ham_Spawn, "player","fw_PlayerSpawnPost", 1)
		
	iHamCz = 0
	
	// Start loading Character informations
	
	iCharacterCount = 0
	
	new szCfgDir[128] 
	new szManagerFile[256]
	new szMapName[32]
	
	get_configsdir(szCfgDir, sizeof szCfgDir - 1)
	get_mapname(szMapName, sizeof szMapName - 1)
	
	formatex(szManagerFile, sizeof szManagerFile - 1, "%s/%s/%s.cfg", szCfgDir, CHARACTER_SPEC_DIR, szMapName)
	
	if (file_exists(szManagerFile))
	{
		for (new i = 0; i < file_size(szManagerFile, 1); i++)
		{
			new szTextInfo[32], iTextLen
			
			read_file(szManagerFile, i, szTextInfo, sizeof szTextInfo - 1, iTextLen)
			
			load_character_config(CHARACTER_CONFIG_DIR, szTextInfo, "ini")
		}
	}
	else
	{
		formatex(szManagerFile, sizeof szManagerFile - 1,"%s/%s/%s", szCfgDir, CHARACTER_MANAGER_DIR, CHARACTER_MANAGER_FILE)
		
		if (file_exists(szManagerFile))
		{
			for (new i = 0; i < file_size(szManagerFile, 1); i++)
			{
				new szTextInfo[32], iTextLen
				
				read_file(szManagerFile, i, szTextInfo, sizeof szTextInfo - 1, iTextLen)
				
				load_character_config(CHARACTER_CONFIG_DIR, szTextInfo, "ini")
			}
		}
		
	}
	
	formatex(szManagerFile, sizeof szManagerFile - 1, "%s/%s/%s.cfg", szCfgDir, CHARACTER_ADD_DIR, szMapName)
		
	if (file_exists(szManagerFile))
	{
		for (new i = 0; i < file_size(szManagerFile, 1); i++)
		{
			new szTextInfo[32], iTextLen
				
			read_file(szManagerFile, i, szTextInfo, sizeof szTextInfo - 1, iTextLen)
				
			load_character_config(CHARACTER_CONFIG_DIR, szTextInfo, "ini")
		}
	}
}

public plugin_precache()
{
			
	precache_sound(SOUND_FEMALE_HURT)
	precache_sound(SOUND_FEMALE_DIE)
}

public client_connect(id)
	has_character[id] = -1
	

public client_putinserver(id)
{
	iOverrideMode[id] = -1
	if (!is_user_connected(id))
		return
		
	if (!is_user_bot(id))
		return
		
	if (!get_cvar_num("bot_quota"))
		return
		
	set_task(0.1, "TASK_REGISTER_CZ_FUNCTION", id)
	
	if (iCharacterCount)
	{
		new iRandomCharacter = random(10)
		
		if (iRandomCharacter < 6)
		{
			iRandomCharacter = random(iCharacterCount - 1)
			
			if (!nt_is_special_character(iRandomCharacter))
				nt_set_user_character(id, iRandomCharacter, 1,0)
		}
	}
			
}

public client_disconnect(id)
	iOverrideMode[id] = -1
	
public fw_EmitSound(id, iChannel, szSample[], Float:fVolume, Float:fATTN, iFlags, iPitch)
{
	if (!is_user_connected(id))
		return FMRES_IGNORED
		
	
	new iCharacterId = nt_get_user_character(id)
	
	if (iCharacterId < 0)
		return FMRES_IGNORED
		
	new CsTeams:iTeam = cs_get_user_team(id)
	
	new iGender = nt_get_character_gender(iCharacterId, iTeam)
	
	if (iGender != GENDER_FEMALE)
		return FMRES_IGNORED
		
	new szSoundPlay[128]
	new iUpdateSound = 0
	
	if (equal(szSample[7], "die", 3) || equal(szSample[7], "dea", 3))
	{
		szSoundPlay = SOUND_FEMALE_DIE
		iUpdateSound = 1
	}
	else if (equal(szSample[7], "bhit", 4))
	{
		szSoundPlay = SOUND_FEMALE_HURT
		iUpdateSound = 1
	}
	else if (equal(szSample[10], "fall", 4))
	{
		szSoundPlay = SOUND_FEMALE_HURT
		iUpdateSound = 1
	}
	
	if (iUpdateSound)
	{
		engfunc(EngFunc_EmitSound, id, iChannel, szSoundPlay, fVolume, fATTN, iFlags, iPitch)
		return FMRES_SUPERCEDE
	}
	
	return FMRES_IGNORED
}
		
public fw_PlayerSpawnPost(id)
{
	if (!is_user_connected(id))
		return
	
	new iCharacterId = nt_get_user_character_2(id)
	
	if ( iCharacterId < 0)
	{
		new iInternalModel = fm_get_user_internal_model(id)
		new CsTeams:iTeam = cs_get_user_team(id)
		new Float:flHealth = float(nt_get_character_health(iCharacterId, iTeam, iInternalModel))
		set_pev(id, pev_health, flHealth)
		return
	}
	
	if (cs_get_user_vip(id))
		return
	
	nt_set_user_character(id, iCharacterId , 1, 1)
	
}

public fw_ClientUserInfoChanged(id)
{
	if (!is_user_connected(id))
		return	
	
	if (!is_user_alive(id))
		return
		
	new szModel[128]
	fm_get_user_model(id, szModel, sizeof szModel - 1)
		
	new iCharacterId = nt_get_user_character(id)
	
	if (iCharacterId < 0)
		return 
		
	new CsTeams:iTeam = cs_get_user_team(id)
	
	new szCharacterModel[128]
	new iModelIndex
	
	if (iTeam == CS_TEAM_CT)
	{
		TrieGetString(iCharacterInfo[iCharacterId], SECTION_MODEL_GR, szCharacterModel, sizeof szCharacterModel - 1)
		if (!equal(szModel, szCharacterModel))
		{
			fm_set_user_model(id, szCharacterModel)
			
			TrieGetCell(iCharacterInfo[iCharacterId], SECTION_MODEL_INDEX_GR, iModelIndex)
			set_pev(id, pev_modelindex, iModelIndex)
		}
	}
	else if (iTeam == CS_TEAM_T)
	{
		TrieGetString(iCharacterInfo[iCharacterId], SECTION_MODEL_BL, szCharacterModel, sizeof szCharacterModel - 1)
		
		if (!equal(szModel, szCharacterModel))
		{
			fm_set_user_model(id, szCharacterModel)
			
			TrieGetCell(iCharacterInfo[iCharacterId], SECTION_MODEL_INDEX_BL, iModelIndex)
			set_pev(id, pev_modelindex, iModelIndex)
		}
	}
}


public fw_MessageSendRadio(msg_id, msg_dest, iRecipient)
{
	new iSender = get_msg_arg_int(1)
	
	new szAudioCode[32]
	
	get_msg_arg_string(2, szAudioCode, sizeof szAudioCode - 1)
	
	new iRadioCode = get_radio_code(szAudioCode)
	
	new INVALID_RADIO_CODE = -1
	
	
	if (iRadioCode == INVALID_RADIO_CODE || iRadioCode > sizeof CS_RADIO_CODE - 1)
	{
		return PLUGIN_HANDLED
	}
	
	
	set_msg_arg_string(2, "")
	
	ExecuteForward(ifw_PlayCSRadioCode, ifw_Result, iSender, iRecipient, szAudioCode)
	
	if (ifw_Result != PLUGIN_CONTINUE)
		return PLUGIN_CONTINUE
		
	new iPlayers[32], iNumber
	
	get_players(iPlayers, iNumber, "ac")
	
	
	for (new i = 0; i < sizeof iNumber; i++)
	{
		new iRecipient = iPlayers[i]
		
		if (can_player_send_radio(iSender, iRecipient, 1))
		{
			new szRadioDirectory[64]
			
			new szRadioSound[256]
			
			new iGender = GENDER_MALE
			
			new iResult = 0
			
			new CsTeams:iTeam 
			
			if (!is_user_connected(iSender)) // Radio messages sent by Engine
			{	
				new iCharacterId = nt_get_user_character(iRecipient)
				
				iTeam = cs_get_user_team(iRecipient)
				
				if (iCharacterId > - 1)
					iGender = nt_get_character_gender(iRecipient, iTeam)
				
				iResult = get_radio_directory(iGender, szRadioDirectory, sizeof szRadioDirectory - 1)
				
				formatex(szRadioSound, sizeof szRadioSound - 1, "%s/%s", szRadioDirectory, szRadioWav[iRadioCode])	
				
			}
			else	
			{
				new iCharacterId = nt_get_user_character(iSender)
				
				iTeam = cs_get_user_team(iSender)
				
				if (iCharacterId > - 1)
					iGender = nt_get_character_gender(iSender, iTeam)
				
				iResult = get_radio_directory(iGender, szRadioDirectory, sizeof szRadioDirectory - 1)
				
			}
			
			if (!iResult)
				continue
			
			formatex(szRadioSound, sizeof szRadioSound - 1, "%s/%s", szRadioDirectory, szRadioWav[iRadioCode])
			client_cmd(iRecipient, "spk %s", szRadioSound)
		}
		else
			continue
	}
	return PLUGIN_CONTINUE
}

public TASK_REGISTER_CZ_FUNCTION(TASKID)
{
	new id = TASKID - TASK_CZ_BOT_FUNCTION
	
	if (!is_user_connected(id))
		return
		
	if (!is_user_bot(id))
		return
	
	if (!get_cvar_num("bot_quota"))
		return
		
	if (iHamCz)
		return
		
	RegisterHamFromEntity(Ham_Spawn, id, "fw_PlayerSpawnPost", 1)
	
	if (is_user_alive(id))
		fw_PlayerSpawnPost(id)
}
			


stock get_radio_code(const radio[])
{	
	for (new i = 0; i < sizeof CS_RADIO_CODE; i++)
		if (equal(radio, CS_RADIO_CODE[i]))
			return i
	return -1
}

stock get_radio_directory(iGender, szOutput[], iLen)
{
	if (iGender == GENDER_FEMALE)
	{
		formatex(szOutput, iLen, FEMALE_RADIO)	
		return 1
	}
		
	formatex(szOutput, iLen, MALE_RADIO)
	return 1
}

stock can_player_send_radio(iSender, iRecipient, iCheckTeam)
{
	
	ExecuteForward(ifw_CheckRadioCondition, ifw_Result, iSender, iRecipient, iCheckTeam)
	
	if (ifw_Result != PLUGIN_CONTINUE)
		return 0
		
	// IF ID IS 0 - MESSAGE SENDS FROM ENGINE ;)
		
	if (!is_user_connected(iSender) && is_user_connected(iRecipient))
		return 1
		
	// IF MESSAGE SENDS FROM INVALID PLAYER 
	
	if (!is_user_connected(iSender))
		return 0
		
	// IF MESSAGE IS RECEIVED BY INVALID PLAYER
	if (!is_user_connected(iRecipient))
		return 0
		
	// CHECK TEAM ? AND NOT IN THE SAME TEAM ?
	
	new CsTeams:iSenderTeam = cs_get_user_team(iSender)
	new CsTeams:iRecipientTeam = cs_get_user_team(iRecipient)
	
	if (iSenderTeam != iRecipientTeam)
	{
		if (iCheckTeam)
			return 0
	}
		
	return 1
}

 
stock CheckBL_ModelPos(szModel[])
{
	for (new i = 0; i < sizeof DEFAULT_BL_MODEL; i++)
		if (equal(szModel, DEFAULT_BL_MODEL[i]))
			return i
	return -1
}

stock CheckGR_ModelPos(szModel[])
{
	for (new i = 0; i < sizeof DEFAULT_GR_MODEL; i++)
		if (equal(szModel, DEFAULT_GR_MODEL[i]))
			return i
	return -1
}

stock load_character_config(szDirectory[], szFile[], szExtension[])
{
	
	if (iCharacterCount > MAX_CHARACTER - 1)
		return -1
		
	new szCharacterFile[256]
	new szCfgDir[128]
	
	formatex(szCharacterFile, sizeof szCharacterFile - 1, "%s/%s/%s.%s", szCfgDir, szDirectory, szFile, szExtension)
	
	if (!file_exists(szCharacterFile))
		return -1
		
		
	if (!iCharacterInfo[iCharacterCount])
		iCharacterInfo[iCharacterCount] = TrieCreate()
		
	new szInfo[256], iTextLen
	
	read_file(szCharacterFile, LINE_NAME, szInfo, sizeof szInfo - 1, iTextLen)
	replace(szInfo, sizeof szInfo - 1, "[NAME]", "")
	
	TrieSetString(iCharacterInfo[iCharacterCount], SECTION_NAME, szInfo)
	
	new szModel[64], szPrefix[5]
	read_file(szCharacterFile, LINE_MODEL, szInfo, sizeof szInfo - 1, iTextLen)
	replace(szInfo, sizeof szInfo - 1, "[MODEL]", "")
	parse(szInfo, szModel, sizeof szModel - 1, szPrefix, sizeof szPrefix - 1)
	
	new szSpecificModel[128]
	
	if (str_to_num(szPrefix))
	{
		formatex(szSpecificModel, sizeof szSpecificModel - 1, "%s_gr", szModel)
		TrieSetString(iCharacterInfo[iCharacterCount], SECTION_MODEL_GR, szSpecificModel)
		TrieSetCell(iCharacterInfo[iCharacterCount], szModel, 1)
		
		formatex(szSpecificModel, sizeof szSpecificModel - 1, "%s_bl", szModel)
		TrieSetString(iCharacterInfo[iCharacterCount], SECTION_MODEL_BL, szSpecificModel)
		TrieSetCell(iCharacterInfo[iCharacterCount], szModel, 1)
		
		new szPrecachedModel[256], iModelIndex
	
		formatex(szPrecachedModel, sizeof szPrecachedModel - 1, "models/player/%s_gr/%s_gr.mdl", szModel, szModel)
		iModelIndex = engfunc(EngFunc_PrecacheModel, szPrecachedModel)
		TrieSetCell(iCharacterInfo[iCharacterCount], SECTION_MODEL_INDEX_GR, iModelIndex)
		
		formatex(szPrecachedModel, sizeof szPrecachedModel - 1, "models/player/%s_bl/%s_bl.mdl", szModel, szModel)
		iModelIndex = engfunc(EngFunc_PrecacheModel, szPrecachedModel)
		TrieSetCell(iCharacterInfo[iCharacterCount], SECTION_MODEL_INDEX_BL, iModelIndex)
	}
	else
	{
		formatex(szSpecificModel, sizeof szSpecificModel - 1, "%s", szModel)
		TrieSetString(iCharacterInfo[iCharacterCount], SECTION_MODEL_GR, szSpecificModel)
		TrieSetCell(iCharacterInfo[iCharacterCount], szModel, 1)
		
		formatex(szSpecificModel, sizeof szSpecificModel - 1, "%s", szModel)
		TrieSetString(iCharacterInfo[iCharacterCount], SECTION_MODEL_BL, szSpecificModel)
		TrieSetCell(iCharacterInfo[iCharacterCount], szModel, 1)
		
		new szPrecachedModel[256], iModelIndex
	
		formatex(szPrecachedModel, sizeof szPrecachedModel - 1, "models/player/%s/%s.mdl", szModel, szModel)
		iModelIndex = engfunc(EngFunc_PrecacheModel, szPrecachedModel)
		TrieSetCell(iCharacterInfo[iCharacterCount], SECTION_MODEL_INDEX_GR, iModelIndex)
		TrieSetCell(iCharacterInfo[iCharacterCount], SECTION_MODEL_INDEX_BL, iModelIndex)
	}
	
	read_file(szCharacterFile, LINE_HP, szInfo, sizeof szInfo - 1, iTextLen)
	replace(szInfo, sizeof szInfo - 1, "[HP]", "")
	new szHP_BL[10], szHP_GR[10]
	parse(szInfo, szHP_BL, sizeof szHP_BL - 1, szHP_GR, sizeof szHP_GR - 1)
	
	TrieSetCell(iCharacterInfo[iCharacterCount], SECTION_HP_BL, str_to_num(szHP_BL))
	TrieSetCell(iCharacterInfo[iCharacterCount], SECTION_HP_GR, str_to_num(szHP_GR))
	
	read_file(szCharacterFile, LINE_SPEED, szInfo, sizeof szInfo - 1, iTextLen)
	replace(szInfo , sizeof szInfo - 1, "[SPEED]", "")
	new szSPEED_BL[10], szSPEED_GR[10]
	
	TrieSetCell(iCharacterInfo[iCharacterCount], SECTION_SPEED_BL, str_to_num(szSPEED_BL))
	TrieSetCell(iCharacterInfo[iCharacterCount], SECTION_SPEED_GR, str_to_num(szSPEED_GR))
	
	read_file(szCharacterFile, LINE_GRAVITY, szInfo, sizeof szInfo - 1, iTextLen)
	replace(szInfo, sizeof szInfo - 1, "[GRAVITY]", "")
	new szGravityBl[10] ,szGravityGr[10]
	parse(szInfo, szGravityBl, sizeof szGravityBl - 1, szGravityGr, sizeof szGravityGr - 1)
	
	set_trie_float(iCharacterInfo[iCharacterCount], SECTION_GRAVITY_BL, str_to_float(szGravityBl))
	set_trie_float(iCharacterInfo[iCharacterCount], SECTION_GRAVITY_GR, str_to_float(szGravityGr))
	
	read_file(szCharacterFile, LINE_COST, szInfo, sizeof szInfo - 1, iTextLen)
	replace(szInfo, sizeof szInfo - 1, "[COST]", "")
	new szCostType[10], szCost[10]
	parse(szInfo, szCostType, sizeof szCostType - 1, szCost , sizeof szCost - 1)
	TrieSetCell(iCharacterInfo[iCharacterCount], SECTION_COST_TYPE, str_to_num(szCostType))
	TrieSetCell(iCharacterInfo[iCharacterCount], SECTION_COST, str_to_num(szCost))
	
	read_file(szCharacterFile, LINE_GENDER, szInfo, sizeof szInfo - 1, iTextLen)
	replace(szInfo, sizeof szInfo - 1, "[GENDER]", "")
	new szGENDER_BL[10], szGENDER_GR[10]
	parse(szInfo, szGENDER_BL, sizeof szGENDER_BL - 1, szGENDER_GR, sizeof szGENDER_GR - 1)
	
	TrieSetCell(iCharacterInfo[iCharacterCount], SECTION_GENDER_BL, str_to_num(szGENDER_BL))
	TrieSetCell(iCharacterInfo[iCharacterCount], SECTION_GENDER_GR, str_to_num(szGENDER_GR))
	
	read_file(szCharacterFile, LINE_SUBHAND, szInfo, sizeof szInfo - 1, iTextLen)
	new GR_HAND[10], BL_HAND[10]
	replace(szInfo, sizeof szInfo - 1, "[SUB_HAND]", "")
	parse(szInfo, BL_HAND, sizeof BL_HAND - 1, GR_HAND, sizeof GR_HAND - 1)
	
	TrieSetCell(iCharacterInfo[iCharacterCount], SECTION_HAND_GR, str_to_num(GR_HAND))
	TrieSetCell(iCharacterInfo[iCharacterCount], SECTION_HAND_BL, str_to_num(BL_HAND))
	
	read_file(szCharacterFile, LINE_HEALTH_HUD, szInfo, sizeof szInfo - 1, iTextLen)
	replace(szInfo, sizeof szInfo - 1, "[HUD]", "")
	
	new BL_HUD[32], GR_HUD[32]
	parse(szInfo, BL_HUD, sizeof BL_HUD - 1, GR_HUD, sizeof GR_HUD - 1)
	
	TrieSetString(iCharacterInfo[iCharacterCount], SECTION_HUD_BL, BL_HUD)
	TrieSetString(iCharacterInfo[iCharacterCount], SECTION_HUD_GR, GR_HUD)
	
	read_file(szCharacterFile, LINE_SERIAL, szInfo, sizeof szInfo - 1, iTextLen)
	replace(szInfo, sizeof szInfo - 1, "[SERIAL]", "")
	TrieSetString(iCharacterInfo[iCharacterCount], SECTION_SERIAL, szInfo)
	
	read_file(szCharacterFile, LINE_SPECIAL_CHARACTER, szInfo, sizeof szInfo-  1, iTextLen)
	replace(szInfo, sizeof szInfo - 1, "[SpecialCharacter]", "")
	TrieSetCell(iCharacterInfo[iCharacterCount], SECTION_SPECIAL_CHARACTER, str_to_num(szInfo))
	
	new iReturnId = iCharacterCount
	
	iCharacterCount++
	
	return iReturnId
}

stock BL_InternalIdToPos(iInternalModel)
{
	for (new i = 0; i < sizeof DEFAULT_BL_INTERNAL_MODEL; i++)
		if (iInternalModel == DEFAULT_BL_INTERNAL_MODEL[i])
			return i
	return -1
}

stock GR_InternalIdToPos(iInternalModel)
{
	for (new i = 0; i < sizeof DEFAULT_GR_INTERNAL_MODEL; i++)
		if (iInternalModel == DEFAULT_GR_INTERNAL_MODEL[i])
			return i
			
	return -1
}

stock play_radio_code(iSender, szAudioCode[], iCustomGender, iGenderId, iCustomRadioDirectory, szMaleRadioDirectory[], szFemaleRadioDirectory[])
{
	
	new iRadioCode = get_radio_code(szAudioCode)
	
	new INVALID_RADIO_CODE = -1
	
	if (iRadioCode == INVALID_RADIO_CODE || iRadioCode > sizeof CS_RADIO_CODE - 1)
	{
		return
	}
		
	new iPlayers[32], iNumber
	
	get_players(iPlayers, iNumber, "c")
	
	
	for (new i = 0; i < sizeof iNumber; i++)
	{
			
		new iRecipient = iPlayers[i]
		
		if (!is_user_connected(iRecipient))
			continue
			
		if (can_player_send_radio(iSender, iRecipient, 1))
		{
			new szRadioDirectory[64]
			
			new szRadioSound[256]
			
			new iGender = GENDER_MALE
			
			new iResult = 0
			
			new CsTeams:iTeam
			
			if (!iSender)
			{
				iTeam = cs_get_user_team(iRecipient)
				
				new iCharacterId = nt_get_user_character(iRecipient)
				
				if (!iCustomGender)
				{
					if (iCharacterId > -1)
						iGender = nt_get_character_gender(iRecipient, iTeam)
				}
				else	
					iGender = iGenderId
					
				if (iCustomRadioDirectory)
				{
					if (iGender == GENDER_MALE)
						formatex(szRadioDirectory, sizeof szRadioDirectory - 1, szMaleRadioDirectory)
					else	formatex(szRadioDirectory, sizeof szRadioDirectory - 1, szFemaleRadioDirectory)
					
					iResult = 1
				}
				else	iResult = get_radio_directory(iGender, szRadioDirectory, sizeof szRadioDirectory - 1)
			}
			else	
			{
				iTeam = cs_get_user_team(iSender)
				
				new iCharacterId = nt_get_user_character(iSender)
				
				
				if (iCustomGender)
					iGender = iGenderId
				else
				{
					if (iCharacterId > -1)
						iGender = nt_get_character_gender(iSender, iTeam)	
				}
					
				if (iCustomRadioDirectory)
				{
					if (iGender == GENDER_MALE)
						formatex(szRadioDirectory, sizeof szRadioDirectory - 1, szMaleRadioDirectory)
					else	formatex(szRadioDirectory, sizeof szRadioDirectory - 1, szFemaleRadioDirectory)
					
					iResult = 1
				}
				else	iResult = get_radio_directory(iGender, szRadioDirectory, sizeof szRadioDirectory - 1)
			}
			
			if (!iResult)
				return
				
			formatex(szRadioSound, sizeof szRadioSound - 1, "%s/%s", szRadioDirectory, szRadioWav[iRadioCode])
			client_cmd(iRecipient, "spk %s", szRadioSound)
		}
	}
	
}





stock _set_user_character(id, iCharacterID, iUpdateId, iUpdateHealth)
{		
	if (!is_user_alive(id))
		return
		
	if (iCharacterID < 0 || iCharacterID > iCharacterCount - 1)
	{
		if (iUpdateId)
			has_character[id] = iCharacterID
		
		return
	}
	
	new CsTeams:iTeam = cs_get_user_team(id)
	
	new szModel[128]
	new iModelIndex
		
	if (iTeam == CS_TEAM_CT)
	{
		TrieGetString(iCharacterInfo[iCharacterID], SECTION_MODEL_GR, szModel, sizeof szModel - 1)
			
		fm_set_user_model(id, szModel)
		
		TrieGetCell(iCharacterInfo[iCharacterID], SECTION_MODEL_INDEX_GR, iModelIndex)
		set_pev(id, pev_modelindex, iModelIndex)
	}
	else
	{
		TrieGetString(iCharacterInfo[iCharacterID], SECTION_MODEL_BL, szModel, sizeof szModel - 1)
			
		fm_set_user_model(id, szModel)
			
		TrieGetCell(iCharacterInfo[iCharacterID], SECTION_MODEL_INDEX_BL, iModelIndex)
			
		set_pev(id, pev_modelindex, iModelIndex)
	}
	
	if (iUpdateId)
	{
		has_character[id] = iCharacterID
		iOverrideMode[id] = -1
	}
	else
		iOverrideMode[id] = iCharacterID
	
	if (iUpdateHealth)
	{
		new iHealth = nt_get_character_health(iCharacterID, iTeam, fm_get_user_internal_model(id))
		
		set_pev(id, pev_health, float(iHealth))
	}
}


public Event_Terrorists_Win()	
{ 
	new RCODE_BL_WIN[] =  "%!MRAD_TERWIN" 
	play_radio_code(0, RCODE_BL_WIN, 0, 0,0, "", "")
}

public Event_Counter_Terrorist_Win()	
{
	new RCODE_GR_WIN[] =  "%!MRAD_CTWIN" 
	play_radio_code(0, RCODE_GR_WIN, 0, 0, 0,"", "")
}

public Event_RoundDraw()	
{ 
	new RCODE_ROUND_DRAW[] = "%!MRAD_ROUNDDRAW"
	play_radio_code(0, RCODE_ROUND_DRAW, 0, 0, 0,  "", "")
}

	

	
stock forward_register()
{
	ifw_CheckRadioCondition = CreateMultiForward("CM_CheckRadioCondition", ET_CONTINUE, FP_CELL, FP_CELL, FP_CELL)
	ifw_PlayCSRadioCode = CreateMultiForward("CM_PlayCsRadioCode", ET_CONTINUE, FP_CELL, FP_CELL, FP_STRING)
}

	
	
	
	
	
	
	
stock fm_set_user_model(client, const model[])
{
	return engfunc(EngFunc_SetClientKeyValue, client, engfunc(EngFunc_GetInfoKeyBuffer, client), "model", model);
}

stock fm_get_user_model( player, model[], len )
{
	// Retrieve current model
	engfunc( EngFunc_InfoKeyValue, engfunc( EngFunc_GetInfoKeyBuffer, player ), "model", model, len )
}

stock fm_reset_user_model(player) 
{ 
	dllfunc(DLLFunc_ClientUserInfoChanged, player, engfunc(EngFunc_GetInfoKeyBuffer, player)) 
} 

stock fm_get_user_internal_model(player)
	return get_pdata_int(player, m_iInternalModel, 5)

stock Float:get_trie_float(Trie:iTrieId, szKey[], Float:fDefaultOutput = 0.0)
{
	if (!iTrieId)
		return fDefaultOutput
		
	if (!TrieKeyExists(iTrieId, szKey))
		return fDefaultOutput
		
	TrieGetCell(iTrieId, szKey, fDefaultOutput)
	return fDefaultOutput
}

stock set_trie_float(Trie:iTrieId, szKey[], Float:fInput)
{
	if (!iTrieId)
		return
		
	if (!TrieKeyExists(iTrieId, szKey))
		return
		
	TrieGetCell(iTrieId, szKey, fInput)
	
}
