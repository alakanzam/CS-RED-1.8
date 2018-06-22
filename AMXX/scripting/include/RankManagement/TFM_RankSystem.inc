
#if defined _csred_RankInformation_included
  #endinput
#endif
#define _csred_RankInformation_included




/* Get user rank name */
native TFM_get_user_rank(id, szOutput[], iLen)

/* Set user rank name */
native TFM_set_user_rank(id, szRankName[])

/* Save user rank info by nick name */
native TFM_save_user_rankinfo(id, szNickName[])

/* Load user rank info by nick name */
native TFM_load_user_rankinfo(id, szNickName[])