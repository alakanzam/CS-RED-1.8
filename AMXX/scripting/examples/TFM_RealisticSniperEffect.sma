/* AMX Mod script.
*
* Sniper Realism 1.2
* &copy; 2003, SuicideDog
* This file is provided as is (no warranties).
*
*  BASED ON CODE FROM *BMJ* -- thanks man
*
* Ok.. works for scout, awp, g3sg1, sig550, sig552, and aug
*
* Features:
* Fadein like DOD (thanks to BMJ)
* Scope jiggles if scoped, and you move
* Unscopes you if you jump/fall (also prevents scoping in the air)
*/

/* CVARS:
* amx_snipe_realism (1)|0
* turns it off and on
* amx_scopetime1 "1"
* 1 being the time it takes to fade in at level 1 scope
* amx_scopetime2 "4"
* 4 being the time it takes to fade in at level 2 scope
*/

/* TO DO:
*  Add recoil of some kind
*/

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <cswpn_ultilities>
#include <player_api>


#define PLUGIN  "Sniper Realism"
#define VERSION "-No Info-"
#define AUTHOR "SuicideDog"

new iMsgScreenFadeID

#define FIRST_SCOPE_TIME	1
#define SECOND_SCOPE_TIME	2

public plugin_init()
{
	register_plugin ( PLUGIN, VERSION, AUTHOR )
	
	
	register_event ( "SetFOV", "Scope_Activated", "be", "1<90" )
	//register_event ( "SetFOV", "Scope_DeActivated", "be", "1=90" )
       	
	iMsgScreenFadeID = get_user_msgid("ScreenFade")

}	
	
	
public Scope_Activated(id)
{
	     	
	if (is_user_bot(id))
		return
	
	
	if (UT_IsUserFlashed(id))
		return
	
	new iFov
     
       
	iFov   = read_data(1)
   
	message_begin(MSG_ONE_UNRELIABLE, iMsgScreenFadeID, {0,0,0}, id)
	if (iFov > 20)
	{
		write_short(FIRST_SCOPE_TIME<<12)
	} else {
		write_short(SECOND_SCOPE_TIME<<12)
	}
	write_short(1<<16)
	write_short(1<<1)
	write_byte(0)
	write_byte(0)
	write_byte(0)
	write_byte(255)
	message_end()
	
	
	return
}

public Scope_DeActivated(id)
{
	if (is_user_bot(id))
		return
		
	if (UT_IsUserFlashed(id))
		return
		
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), {0,0,0}, id)
	write_short(1<<1)
	write_short(1<<1)
	write_short(1<<1)
	write_byte(0)
	write_byte(0)
	write_byte(0)
	write_byte(0)
	message_end()
	
	
	
	return 
}
