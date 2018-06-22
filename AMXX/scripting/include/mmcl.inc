// Metamod:Client Include File
 
#if defined _ClientMod_included
        #endinput
#endif
#define _ClientMod_included
 
#if AMXX_VERSION_NUM >= 175
 #pragma reqlib ClientMod
 #if !defined AMXMODX_NOAUTOLOAD
  #pragma loadlib ClientMod
 #endif
#else
 #pragma library ClientMod
#endif
 
#define HUDTYPE_SPR 1
#define HUDTYPE_TGA 2
#define HUDTYPE_TEXT 3
 
#define DRAWMODE_NORMAL 0
#define DRAWMODE_ADDITIVE 1
#define DRAWMODE_ALPHATEST 2
 
native MMCL_DrawSPR(id, const szSpr[], isfile, r, g, b, a, Float:x, Float:y, center, drawmode, Float:fFadeIn, Float:fFadeOut, Float:fHoldTime, iChannel)
native MMCL_DrawTGA(id, const szTga[], r, g, b, a, Float:x, Float:y, iCenter, fullscreen, Float:fFadeIn, Float:fFadeOut, Float:fHoldTime, iChannel)
native MMCL_DrawText(id, const szText[], r, g, b, Float:x, Float:y, center, Float:fHoldTime, iChannel)
native MMCL_RemoveImage(id, iHudType, iChannel)
native MMCL_SetRadarDrawTeam(id, iMode)
native MMCL_HeadName(id, iMode, r, g, b)
native MMCL_SetViewEntityBody(id, iBody)
native MMCL_SetViewEntityRenderMode(id, iMode, iFx, r, g, b, iAmt)