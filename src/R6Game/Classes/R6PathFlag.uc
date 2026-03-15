//=============================================================================
// R6PathFlag - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6PathFlag.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/30 * Created by Chaouky Garram
//=============================================================================
class R6PathFlag extends R6ReferenceIcons;

var Texture m_pIconTex[3];  // EMovementSpeed

// Set Movement line texture
function SetModeDisplay(Object.EMovementMode eMode)
{
	Texture = m_pIconTex[int(eMode)];
	return;
}

// Set texture color 
function SetDrawColor(Color NewColor)
{
	m_PlanningColor = NewColor;
	return;
}

// Refresh my location to be between previous and next ActionPoint
function RefreshLocation()
{
	local float fEvenCheck;
	local Vector vFirstVector, vSecondVector;
	local int iMiddleNodeIndex;
	local R6ActionPoint OwnerPoint;
	local Actor aMiddlePoint1, aMiddlePoint2, aMiddlePoint3;

	OwnerPoint = R6ActionPoint(Owner);
	// End:0x93
	if((OwnerPoint.prevActionPoint.m_PathToNextPoint.Length == 0))
	{
		__NFUN_267__(((OwnerPoint.Location + OwnerPoint.prevActionPoint.Location) * 0.5000000)) /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/;
		m_iPlanningFloor_0 = Owner.m_iPlanningFloor_0;
		m_iPlanningFloor_1 = OwnerPoint.prevActionPoint.m_iPlanningFloor_0;		
	}
	else
	{
		fEvenCheck = __NFUN_173__(float(OwnerPoint.prevActionPoint.m_PathToNextPoint.Length), float(2));
		// End:0x43F
		if(__NFUN_180__(fEvenCheck, float(0)))
		{
			aMiddlePoint1 = OwnerPoint.prevActionPoint.m_PathToNextPoint[__NFUN_145__(OwnerPoint.prevActionPoint.m_PathToNextPoint.Length, 2)];
			// End:0x1B8
			if(__NFUN_151__(OwnerPoint.prevActionPoint.m_PathToNextPoint.Length, 1))
			{
				aMiddlePoint2 = OwnerPoint.prevActionPoint.m_PathToNextPoint[__NFUN_147__(__NFUN_145__(OwnerPoint.prevActionPoint.m_PathToNextPoint.Length, 2), 1)];
				// End:0x1B8
				if(__NFUN_151__(OwnerPoint.prevActionPoint.m_PathToNextPoint.Length, 3))
				{
					aMiddlePoint3 = OwnerPoint.prevActionPoint.m_PathToNextPoint[__NFUN_147__(__NFUN_145__(OwnerPoint.prevActionPoint.m_PathToNextPoint.Length, 2), 2)];
				}
			}
			// End:0x2A0
			if(__NFUN_132__(__NFUN_130__(aMiddlePoint2.__NFUN_303__('R6Ladder'), aMiddlePoint1.__NFUN_303__('R6Ladder')), __NFUN_130__(aMiddlePoint2.__NFUN_303__('R6Door'), aMiddlePoint1.__NFUN_303__('R6Door'))))
			{
				// End:0x275
				if(__NFUN_154__(OwnerPoint.prevActionPoint.m_PathToNextPoint.Length, 2))
				{
					vFirstVector = OwnerPoint.prevActionPoint.Location;
					vSecondVector = OwnerPoint.prevActionPoint.m_PathToNextPoint[0].Location;					
				}
				else
				{
					vFirstVector = aMiddlePoint3.Location;
					vSecondVector = aMiddlePoint2.Location;
				}				
			}
			else
			{
				vFirstVector = aMiddlePoint1.Location;
				vSecondVector = aMiddlePoint2.Location;
			}
			__NFUN_267__(__NFUN_212__(__NFUN_215__(vFirstVector, vSecondVector), 0.5000000));
			// End:0x37A
			if(__NFUN_130__(aMiddlePoint2.__NFUN_303__('R6Stairs'), __NFUN_129__(aMiddlePoint1.__NFUN_303__('R6Stairs'))))
			{
				// End:0x34F
				if(__NFUN_242__(R6Stairs(aMiddlePoint2).m_bIsTopOfStairs, true))
				{
					m_iPlanningFloor_0 = aMiddlePoint2.m_iPlanningFloor_1;
					m_iPlanningFloor_1 = aMiddlePoint2.m_iPlanningFloor_1;					
				}
				else
				{
					m_iPlanningFloor_0 = aMiddlePoint2.m_iPlanningFloor_0;
					m_iPlanningFloor_1 = aMiddlePoint2.m_iPlanningFloor_0;
				}				
			}
			else
			{
				// End:0x414
				if(__NFUN_130__(aMiddlePoint2.__NFUN_303__('R6Ladder'), aMiddlePoint1.__NFUN_303__('R6Ladder')))
				{
					// End:0x3E9
					if(__NFUN_242__(R6Ladder(aMiddlePoint2).m_bIsTopOfLadder, true))
					{
						m_iPlanningFloor_0 = aMiddlePoint2.m_iPlanningFloor_1;
						m_iPlanningFloor_1 = aMiddlePoint2.m_iPlanningFloor_1;						
					}
					else
					{
						m_iPlanningFloor_0 = aMiddlePoint2.m_iPlanningFloor_0;
						m_iPlanningFloor_1 = aMiddlePoint2.m_iPlanningFloor_0;
					}					
				}
				else
				{
					m_iPlanningFloor_0 = aMiddlePoint2.m_iPlanningFloor_0;
					m_iPlanningFloor_1 = aMiddlePoint2.m_iPlanningFloor_1;
				}
			}			
		}
		else
		{
			iMiddleNodeIndex = __NFUN_145__(OwnerPoint.prevActionPoint.m_PathToNextPoint.Length, 2);
			aMiddlePoint1 = OwnerPoint.prevActionPoint.m_PathToNextPoint[iMiddleNodeIndex];
			// End:0x4EE
			if(__NFUN_151__(OwnerPoint.prevActionPoint.m_PathToNextPoint.Length, 1))
			{
				aMiddlePoint2 = OwnerPoint.prevActionPoint.m_PathToNextPoint[__NFUN_146__(iMiddleNodeIndex, 1)];
				aMiddlePoint3 = OwnerPoint.prevActionPoint.m_PathToNextPoint[__NFUN_147__(iMiddleNodeIndex, 1)];
			}
			// End:0x5D1
			if(aMiddlePoint1.__NFUN_303__('R6Ladder'))
			{
				// End:0x554
				if(__NFUN_154__(OwnerPoint.prevActionPoint.m_PathToNextPoint.Length, 1))
				{
					vFirstVector = OwnerPoint.prevActionPoint.Location;
					vSecondVector = aMiddlePoint1.Location;					
				}
				else
				{
					// End:0x593
					if(aMiddlePoint3.__NFUN_303__('R6Ladder'))
					{
						vFirstVector = aMiddlePoint1.Location;
						vSecondVector = aMiddlePoint2.Location;						
					}
					else
					{
						vFirstVector = aMiddlePoint1.Location;
						vSecondVector = aMiddlePoint3.Location;
					}
				}
				__NFUN_267__(__NFUN_212__(__NFUN_215__(vFirstVector, vSecondVector), 0.5000000));
			}
			// End:0x6B7
			if(aMiddlePoint1.__NFUN_303__('R6Door'))
			{
				// End:0x637
				if(__NFUN_154__(OwnerPoint.prevActionPoint.m_PathToNextPoint.Length, 1))
				{
					vFirstVector = OwnerPoint.prevActionPoint.Location;
					vSecondVector = aMiddlePoint1.Location;					
				}
				else
				{
					// End:0x676
					if(aMiddlePoint3.__NFUN_303__('R6Door'))
					{
						vFirstVector = aMiddlePoint1.Location;
						vSecondVector = aMiddlePoint2.Location;						
					}
					else
					{
						vFirstVector = aMiddlePoint1.Location;
						vSecondVector = aMiddlePoint3.Location;
					}
				}
				__NFUN_267__(__NFUN_212__(__NFUN_215__(vFirstVector, vSecondVector), 0.5000000));				
			}
			else
			{
				__NFUN_267__(aMiddlePoint1.Location);
			}
			m_iPlanningFloor_0 = aMiddlePoint1.m_iPlanningFloor_0;
			m_iPlanningFloor_1 = aMiddlePoint1.m_iPlanningFloor_1;
		}
	}
	return;
}

defaultproperties
{
	m_pIconTex[0]=Texture'R6Planning.Icons.PlanIcon_Assault'
	m_pIconTex[1]=Texture'R6Planning.Icons.PlanIcon_Infiltrate'
	m_pIconTex[2]=Texture'R6Planning.Icons.PlanIcon_Recon'
	m_bSkipHitDetection=false
	m_bSpriteShowFlatInPlanning=false
	DrawScale=1.2500000
}
