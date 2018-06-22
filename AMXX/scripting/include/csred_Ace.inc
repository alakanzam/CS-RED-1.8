
#if defined _csred_Ace_included
  #endinput
#endif
#define _csred_Ace_included


enum
{
	ACE_NONE,
	ACE_SILVER,
	ACE_GOLD
}

native TFM_GetUserAceType(id)
native TFM_AceCheckingState(iState)
native TFM_GetHighestScore()
native TFM_GetGoldAcer()
native TFM_GetSilverAcer()