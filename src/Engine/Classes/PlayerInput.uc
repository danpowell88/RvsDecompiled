//=============================================================================
// PlayerInput - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// PlayerInput
// Object within playercontroller that manages player input.
// only spawned on client
//=============================================================================
class PlayerInput extends Object within PlayerController
    transient
    native
    config(User);

// Mouse smoothing
var globalconfig byte MouseSmoothingMode;
var int MouseSamples[2];
//#ifndef R6CODE
//var globalconfig	bool	bInvertMouse;
//#else
var bool bInvertMouse;
var bool bWasForward;  // used for doubleclick move
var bool bWasBack;
var bool bWasLeft;
var bool bWasRight;
var bool bEdgeForward;
var bool bEdgeBack;
var bool bEdgeLeft;
var bool bEdgeRight;
var bool bAdjustSampling;
//#ifndef R6CODE
//var globalconfig float  MouseSmoothingStrength;
//#endif // #ifndef R6CODE
var globalconfig float MouseSensitivity;
var globalconfig float MouseSamplingTime;
var float SmoothedMouse[2];
// NEW IN 1.60
var float ZeroTime[2];
// NEW IN 1.60
var float SamplingTime[2];
// NEW IN 1.60
var float MaybeTime[2];
// NEW IN 1.60
var float OldSamples[4];
var float DoubleClickTimer;  // max double click interval for double click move
var globalconfig float DoubleClickTime;

// Postprocess the player's input.
event PlayerInput(float DeltaTime)
{
	local float FOVScale, MouseScale;

	bEdgeForward = (bWasForward ^^ (Outer.aBaseY > float(0)));
	bEdgeBack = (bWasBack ^^ (Outer.aBaseY < float(0)));
	bEdgeLeft = (bWasLeft ^^ (Outer.aStrafe > float(0)));
	bEdgeRight = (bWasRight ^^ (Outer.aStrafe < float(0)));
	bWasForward = (Outer.aBaseY > float(0));
	bWasBack = (Outer.aBaseY < float(0));
	bWasLeft = (Outer.aStrafe > float(0));
	bWasRight = (Outer.aStrafe < float(0));
	FOVScale = (Outer.DesiredFOV * 0.0111100);
	MouseScale = (MouseSensitivity * FOVScale);
	Outer.aMouseX = SmoothMouse((Outer.aMouseX * MouseScale), DeltaTime, Outer.bXAxis, 0);
	Outer.aMouseY = SmoothMouse((Outer.aMouseY * MouseScale), DeltaTime, Outer.bYAxis, 1);
	(Outer.aLookUp *= FOVScale);
	(Outer.aTurn *= FOVScale);
	// End:0x20A
	if((int(Outer.bStrafe) != 0))
	{
		(Outer.aStrafe += (Outer.aBaseX + Outer.aMouseX));		
	}
	else
	{
		(Outer.aTurn += ((Outer.aBaseX * FOVScale) + Outer.aMouseX));
	}
	Outer.aBaseX = 0.0000000;
	// End:0x2E0
	if(((int(Outer.bStrafe) == 0) && (Outer.bAlwaysMouseLook || (int(Outer.bLook) != 0))))
	{
		// End:0x2BF
		if(bInvertMouse)
		{
			(Outer.aLookUp -= Outer.aMouseY);			
		}
		else
		{
			(Outer.aLookUp += Outer.aMouseY);
		}		
	}
	else
	{
		(Outer.aForward += Outer.aMouseY);
	}
	// End:0x339
	if((int(Outer.bSnapLevel) != 0))
	{
		Outer.bCenterView = true;
		Outer.bKeyboardLook = false;		
	}
	else
	{
		// End:0x374
		if((Outer.aLookUp != float(0)))
		{
			Outer.bCenterView = false;
			Outer.bKeyboardLook = true;			
		}
		else
		{
			// End:0x3BE
			if((Outer.bSnapToLevel && (!Outer.bAlwaysMouseLook)))
			{
				Outer.bCenterView = true;
				Outer.bKeyboardLook = false;
			}
		}
	}
	// End:0x414
	if((int(Outer.bFreeLook) != 0))
	{
		Outer.bKeyboardLook = true;
		(Outer.aLookUp += ((0.5000000 * Outer.aBaseY) * FOVScale));		
	}
	else
	{
		(Outer.aForward += Outer.aBaseY);
	}
	Outer.aBaseY = 0.0000000;
	Outer.HandleWalking();
	return;
}

//#ifdef R6CODE
function UpdateMouseOptions()
{
	return;
}

exec function SetSmoothingMode(byte B)
{
	MouseSmoothingMode = B;
	Log(("Smoothing mode " $ string(MouseSmoothingMode)));
	return;
}

exec function SetSmoothingStrength(float f)
{
	return;
}

function float SmoothMouse(float aMouse, float DeltaTime, out byte SampleCount, int Index)
{
	local int i, sum;

	// End:0x13
	if((int(MouseSmoothingMode) == 0))
	{
		return aMouse;
	}
	// End:0x11B
	if((aMouse == float(0)))
	{
		(ZeroTime[Index] += DeltaTime);
		// End:0x7F
		if((ZeroTime[Index] < MouseSamplingTime))
		{
			(SamplingTime[Index] += DeltaTime);
			(MaybeTime[Index] += DeltaTime);
			aMouse = SmoothedMouse[Index];			
		}
		else
		{
			// End:0xE9
			if((bAdjustSampling && (MouseSamples[Index] > 9)))
			{
				(SamplingTime[Index] -= MaybeTime[Index]);
				MouseSamplingTime = ((0.9000000 * MouseSamplingTime) + ((0.1000000 * SamplingTime[Index]) / float(MouseSamples[Index])));
			}
			SamplingTime[Index] = 0.0000000;
			SmoothedMouse[Index] = 0.0000000;
			MouseSamples[Index] = 0;
		}		
	}
	else
	{
		MaybeTime[Index] = 0.0000000;
		// End:0x1C5
		if((SmoothedMouse[Index] != float(0)))
		{
			(MouseSamples[Index] += int(SampleCount));
			// End:0x18E
			if((DeltaTime > (MouseSamplingTime * float((int(SampleCount) + 1)))))
			{
				(SamplingTime[Index] += (MouseSamplingTime * float(SampleCount)));				
			}
			else
			{
				(SamplingTime[Index] += DeltaTime);
				aMouse = ((aMouse * DeltaTime) / (MouseSamplingTime * float(SampleCount)));
			}			
		}
		else
		{
			SamplingTime[Index] = (0.5000000 * MouseSamplingTime);
		}
		SmoothedMouse[Index] = (aMouse / float(SampleCount));
		ZeroTime[Index] = 0.0000000;
	}
	SampleCount = 0;
	// End:0x31A
	if((int(MouseSmoothingMode) > 1))
	{
		// End:0x29E
		if((aMouse == float(0)))
		{
			i = 0;
			J0x231:

			// End:0x28D [Loop If]
			if((i < 3))
			{
				(sum += int((float((i + 1)) * 0.1000000)));
				(aMouse += (float(sum) * OldSamples[i]));
				OldSamples[i] = 0.0000000;
				__NFUN_165__(i);
				// [Loop Continue]
				goto J0x231;
			}
			OldSamples[3] = 0.0000000;			
		}
		else
		{
			aMouse = __NFUN_171__(0.4000000, aMouse);
			OldSamples[3] = aMouse;
			i = 0;
			J0x2C5:

			// End:0x31A [Loop If]
			if(__NFUN_150__(i, 3))
			{
				__NFUN_184__(aMouse, __NFUN_171__(__NFUN_171__(float(__NFUN_146__(i, 1)), 0.1000000), OldSamples[i]));
				OldSamples[i] = OldSamples[__NFUN_146__(i, 1)];
				__NFUN_165__(i);
				// [Loop Continue]
				goto J0x2C5;
			}
		}
	}
	return aMouse;
	return;
}

function UpdateSensitivity(float f)
{
	MouseSensitivity = __NFUN_245__(0.0000000, f);
	__NFUN_536__();
	return;
}

function ChangeSnapView(bool B)
{
	Outer.bSnapToLevel = B;
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
			if(__NFUN_130__(bEdgeForward, bWasForward))
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

defaultproperties
{
	MouseSmoothingMode=1
	bAdjustSampling=true
	MouseSensitivity=3.0000000
	MouseSamplingTime=0.0110640
	DoubleClickTime=0.2500000
}
