#if defined _Tools_included
  #endinput
#endif
#define _Tools_included

#include <GamePlay_Included/IntegerConstant.inc>
#include <GamePlay_Included/Manager.inc>

#include <GamePlay_Included/GamePlay_DM.inc>
#include <GamePlay_Included/GamePlay_ESC.inc>
#include <GamePlay_Included/GamePlay_FFA.inc>
#include <GamePlay_Included/GamePlay_GG.inc>
#include <GamePlay_Included/GamePlay_TDM.inc>
#include <GamePlay_Included/TFM_ZombieMod.inc>

stock is_deathmatch_on(&iWeaponMode, &iIsFightYard)
{
	if (get_current_gameplay() != GAMEMODE_DM && get_current_gameplay() != GAMEMODE_BY_PREFIX)
		return 0
	
	if (!DM_get_game_mode())
		return 0

	new iMode = DM_get_game_mode()
	
	if (iMode == CS_DM_FY)
		iIsFightYard = 1
	else
		iWeaponMode = DM_get_weapon_mode()
	
	return iMode
}

stock is_escape_on()
{
	if (get_current_gameplay() != GAMEMODE_ESCAPE)
		return 0
	return EM_GetGameState()
}

stock is_ffa_on(&iWeaponMode)
{
	if (get_current_gameplay() != GAMEMODE_FFA)
		return 0

	iWeaponMode = FFA_get_weapon_mode()
	return FFA_get_game_state()
}

stock is_gungame_on()
{
	if (get_current_gameplay() != GAMEMODE_GUNGAME)
		return 0

	return 1
}

stock is_tdm_on(&iWeaponMode)
{
	if (get_current_gameplay() != GAMEMODE_TDM)
		return 0

	iWeaponMode = TDM_get_weapon_mode()
	
	return TDM_get_game_state()
}

stock is_zombie_on()
{
	if (get_current_gameplay() != GAMEMODE_ZM)
		return 0
	
	return zp_is_mode_on()
}

stock is_user_zombie(id)
{
	if (!is_zombie_on())
		return 0

	return get_user_zombie(id)
}


