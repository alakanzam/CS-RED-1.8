
#if defined _MsgTool_included
  #endinput
#endif
#define _MsgTool_included


#include <amxmodx>
#include <fakemeta>

stock Draw_BarTime(id, total_time)
{
	if (!is_user_connected(id) || is_user_bot(id))
		return

	message_begin(MSG_ONE_UNRELIABLE,108,{0,0,0},id)
	write_short(total_time)
	message_end()
}

stock CreateBeam(iEnt, iSpriteId, iLife,  iWidth, iRed, iGreen, iBlue, iBrightness)
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BEAMFOLLOW) // TE id
	write_short(iEnt) // entity
	write_short(iSpriteId) // sprite
	write_byte(iLife) // life
	write_byte(iWidth) // width
	write_byte(iRed) // r
	write_byte(iGreen) // g
	write_byte(iBlue) // b
	write_byte(iBrightness) // brightness
	message_end()
}

stock RemoveBeam(iEnt)
{
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_KILLBEAM)
	write_short(iEnt)
	message_end()
}

stock Engine_SetFOV(id, FOV)
{
	emessage_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SetFOV"), _, id)
	ewrite_byte(FOV)
	emessage_end()
	set_pev(id, pev_fov, FOV)
}

stock SetFOV(id, FOV)
{
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SetFOV"), _, id)
	write_byte(FOV)
	message_end()
	set_pev(id, pev_fov, FOV)
	
}