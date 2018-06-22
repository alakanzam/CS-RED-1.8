
#if defined _WM_GlobalConstant_included
  #endinput
#endif
#define _WM_GlobalConstant_included

enum
{
	EQ_PLAYER_ONLY,
	EQ_VIP_ONLY,
	EQ_PLAYER_N_VIP,
	EQ_HERO_ZM3
}

enum
{
	TYPE_NONE,
	TYPE_PISTOL,
	TYPE_SHOTGUN,
	TYPE_SMG,
	TYPE_RIFLE,
	TYPE_MACHINEGUN,
	TYPE_SNIPER,
	TYPE_RPG,
	TYPE_SHIELD
}

#define MODEL_DIRECTORY "TFM_WPN"
#define  SOUND_DIRECTORY "TFM_WPN"


#define pev_iWeaponFlag	pev_iuser1