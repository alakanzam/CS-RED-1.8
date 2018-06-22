/*	No comments	*/

#if defined _infinitive_round_included
  #endinput
#endif
#define _infinitive_round_included

/*	Prevent round from ending	*/
native ir_block_round_end(szFlag[])


/*	Here are some flags 	*/

#define FLAG_TIME_EXPIRED	"a"
#define FLAG_BOMB_EXPODED	"b" 
#define FLAG_BOMB_DEFUSED 	"c"
#define FLAG_HOSTAGE_RESCUE	"d"
#define FLAG_VIP_ESCAPE   		"e"
#define FLAG_VIP_ASSINATED	 "f" 
#define FLAG_TERRORIST_WIN	"g"
#define FLAG_CT_WIN		"h"
#define FLAG_ROUND_DRAW	 "i"
#define FLAG_TERRORIST_ESCAPED	"j"
#define FLAG_CT_PREVENT_ESCAPE      "k"
#define FLAG_ALL	"*"
#define FLAG_NONE " "

/*	Block game restart by Game Commencing	*/
native ir_block_commencing(iStatus)

/*	Prevent game scoring	*/
native ir_block_scoring(iStatus)