//=============================================================================
// R6PlayerInput - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6PlayerInput.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/05/07 * Created by Aristomenis Kolokathis
//=============================================================================
class R6PlayerInput extends PlayerInput within R6PlayerController
	transient
 config(User);

var bool m_bIgnoreInput;
var bool m_bFluidMovement;
var bool m_bWasFluidMovement;

function UpdateMouseOptions()
{
	local int iScaledSensitivity;

	bInvertMouse = Outer.m_GameOptions.InvertMouse;
	Outer.m_GameOptions.MouseSensitivity = float(__NFUN_251__(int(Outer.m_GameOptions.MouseSensitivity), 0, 100));
	iScaledSensitivity = __NFUN_146__(int(__NFUN_172__(Outer.m_GameOptions.MouseSensitivity, float(7))), 1);
	Outer.SetSensitivity(float(iScaledSensitivity));
	return;
}

event PlayerInput(float DeltaTime)
{
	// End:0x0B
	if(m_bIgnoreInput)
	{
		return;
	}
	// End:0x7A
	if(__NFUN_130__(__NFUN_119__(Outer.m_GameOptions, none), Outer.m_GameOptions.AlwaysRun))
	{
		// End:0x66
		if(__NFUN_151__(int(Outer.m_bPlayerRun), 0))
		{
			Outer.bRun = 0;			
		}
		else
		{
			Outer.bRun = 1;
		}		
	}
	else
	{
		Outer.bRun = Outer.m_bPlayerRun;
	}
	super.PlayerInput(DeltaTime);
	// End:0xD0
	if(__NFUN_176__(__NFUN_186__(Outer.aStrafe), 1.0000000))
	{
		Outer.aStrafe = 0.0000000;
	}
	m_bFluidMovement = __NFUN_131__(m_bWasFluidMovement, __NFUN_151__(int(Outer.m_bSpecialCrouch), 0));
	m_bWasFluidMovement = __NFUN_151__(int(Outer.m_bSpecialCrouch), 0);
	return;
}

function Actor.EDoubleClickDir CheckForDoubleClickMove(float DeltaTime)
{
	local Actor.EDoubleClickDir DoubleClickMove, OldDoubleClick;

	// End:0x24
	if(__NFUN_154__(int(Outer.DoubleClickDir), int(5)))
	{
		DoubleClickMove = 5;		
	}
	else
	{
		DoubleClickMove = 0;
	}
	// End:0x24E
	if(__NFUN_177__(DoubleClickTime, 0.0000000))
	{
		// End:0x192
		if(__NFUN_150__(int(Outer.DoubleClickDir), int(5)))
		{
			OldDoubleClick = Outer.DoubleClickDir;
			Outer.DoubleClickDir = 0;
			// End:0xA1
			if(__NFUN_130__(m_bFluidMovement, m_bWasFluidMovement))
			{
				Outer.DoubleClickDir = 3;				
			}
			else
			{
				// End:0xC9
				if(__NFUN_130__(bEdgeBack, bWasBack))
				{
					Outer.DoubleClickDir = 4;					
				}
				else
				{
					// End:0xF1
					if(__NFUN_130__(bEdgeLeft, bWasLeft))
					{
						Outer.DoubleClickDir = 1;						
					}
					else
					{
						// End:0x116
						if(__NFUN_130__(bEdgeRight, bWasRight))
						{
							Outer.DoubleClickDir = 2;
						}
					}
				}
			}
			// End:0x146
			if(__NFUN_154__(int(Outer.DoubleClickDir), int(0)))
			{
				Outer.DoubleClickDir = OldDoubleClick;				
			}
			else
			{
				// End:0x17E
				if(__NFUN_155__(int(Outer.DoubleClickDir), int(OldDoubleClick)))
				{
					DoubleClickTimer = __NFUN_174__(DoubleClickTime, __NFUN_171__(0.5000000, DeltaTime));					
				}
				else
				{
					DoubleClickMove = Outer.DoubleClickDir;
				}
			}
		}
		// End:0x1E5
		if(__NFUN_154__(int(Outer.DoubleClickDir), int(6)))
		{
			__NFUN_185__(DoubleClickTimer, DeltaTime);
			// End:0x1E2
			if(__NFUN_176__(DoubleClickTimer, -0.3500000))
			{
				Outer.DoubleClickDir = 0;
				DoubleClickTimer = DoubleClickTime;
			}			
		}
		else
		{
			// End:0x24E
			if(__NFUN_130__(__NFUN_155__(int(Outer.DoubleClickDir), int(0)), __NFUN_155__(int(Outer.DoubleClickDir), int(5))))
			{
				__NFUN_185__(DoubleClickTimer, DeltaTime);
				// End:0x24E
				if(__NFUN_176__(DoubleClickTimer, float(0)))
				{
					Outer.DoubleClickDir = 0;
					DoubleClickTimer = DoubleClickTime;
				}
			}
		}
	}
	return DoubleClickMove;
	return;
}

