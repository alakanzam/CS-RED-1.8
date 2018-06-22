/* This file is contact with g4u_pistol.amxx, g4u_riffle.amxx, g4u_hegrenade.amxx, ... */

#if defined _TFM_WPN_included
  #endinput
#endif
#define _TFM_WPN_included

#include <WpnMod_Included/WM_GlobalConstant.inc>
#include <WpnMod_Included/WM_PrimaryWpn.inc>
#include <WpnMod_Included/WM_SecondaryWpn.inc>
#include <WpnMod_Included/WM_Melee.inc>
#include <WpnMod_Included/WM_Grenade.inc>

enum
{
	GRE_LOAD_NONE = 0,
	GRE_LOAD_FULL
}


enum
{
	FUNC_NONE,
	FUNC_ZOOM,
	FUNC_GREN_LAUNCHER,
	FUNC_GREN_IS3,
	FUNC_LASER,
	FUNC_IRON_1ST,
	FUNC_ONE_SHOT,
	FUNC_BURST_SHOT,
	FUNC_BURST_ONE_SHOT,
	FUNC_KNIFE,
	FUNC_IRONSIGHT_1_BURST,
	FUNC_IRONSIGHT_2,
	FUNC_IRONSIGHT_3
}

