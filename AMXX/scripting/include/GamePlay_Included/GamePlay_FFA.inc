#if defined _GamePlay_FFA_included
  #endinput
#endif
#define _GamePlay_FFA_included

#include <GamePlay_Included/FloatConstant.inc>
#include <GamePlay_Included/IntegerConstant.inc>

enum
{
	FFA_MODE_NONE,
	FFA_MODE_NORMAL
}

native FFA_get_game_state()
native FFA_get_map_type()
native FFA_get_max_score()
native FFA_get_highest_score()
native FFA_get_user_frag(id)
native Float:FFA_get_round_time()
native FFA_get_weapon_mode()

/*	Called when round ends	*/
forward FFA_game_over(iWinner)