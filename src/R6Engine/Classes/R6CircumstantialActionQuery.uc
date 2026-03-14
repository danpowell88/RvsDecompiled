//=============================================================================
// R6CircumstantialActionQuery - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6CircumstantialActionQuery.uc : describes action that can be performed on an actor
//                                  originally stCircumstantialActionQuery
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/03 * Created by Aristomenis Kolokathis
//=============================================================================
class R6CircumstantialActionQuery extends R6AbstractCircumstantialActionQuery;

var bool bShowLog;
var bool m_bNeedsTick;

simulated event Tick(float fDelta)
{
	local R6PlayerController PlayerController;

	// End:0xF2
	if(m_bNeedsTick)
	{
		// End:0xF2
		if(__NFUN_179__(__NFUN_175__(Level.TimeSeconds, m_fPressedTime), 0.4000000))
		{
			PlayerController = R6PlayerController(aQueryOwner);
			// End:0x6D
			if(__NFUN_130__(__NFUN_154__(int(iInRange), 1), bCanBeInterrupted))
			{
				PlayerController.m_InteractionCA.PerformCircumstantialAction(0);				
			}
			else
			{
				// End:0xEA
				if(__NFUN_130__(__NFUN_130__(__NFUN_154__(int(iInRange), 0), __NFUN_155__(int(iTeamActionIDList[0]), 0)), PlayerController.CanIssueTeamOrder()))
				{
					// End:0xD1
					if(bShowLog)
					{
						__NFUN_231__("**** Displaying rose des vents ! ****");
					}
					PlayerController.m_InteractionCA.DisplayMenu(true);
				}
			}
			m_bNeedsTick = false;
		}
	}
	return;
}

simulated function ClientPerformCircumstantialAction()
{
	// End:0x36
	if(bShowLog)
	{
		__NFUN_231__("R6CAQ **** Executing player action ! ****");
	}
	R6PlayerController(aQueryOwner).m_InteractionCA.PerformCircumstantialAction(0);
	return;
}

simulated function ClientDisplayMenu(bool bDisplay)
{
	// End:0x2B
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_112__("setting DisplayMenu ", string(bDisplay)));
	}
	R6PlayerController(aQueryOwner).m_InteractionCA.DisplayMenu(bDisplay);
	return;
}

