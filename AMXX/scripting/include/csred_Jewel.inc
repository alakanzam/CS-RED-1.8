
#if defined _csred_Jewel_included
  #endinput
#endif
#define _csred_Jewel_included

native csred_SetUserJewel(id, iJewelId, iCreateEnt)
native csred_HideUserJewel(id)
native csred_ShowUserJewel(id)
native csred_GetHatCostType(iHat)
native csred_GetHatCost(iHat)
native csred_IsModelBanned(iHat, szModel[])
native csred_GetMaxJewel()
native csred_GetJewelName(iHatId, szName[], len)