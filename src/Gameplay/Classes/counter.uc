//=============================================================================
// counter - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// Counter: waits until it has been triggered 'NumToCount' times, and then
// it sends Trigger/UnTrigger events to actors whose names match 'EventName'.
//=============================================================================
class counter extends Triggers;

var() byte NumToCount;  // Number to count down from.
var byte OriginalNum;  // Number to count at startup time.
var() bool bShowMessage;  // Display count message?
var() localized string CountMessage;  // Human readable count message.
var() localized string CompleteMessage;  // Completion message.

//
// Init for play.
//
function BeginPlay()
{
	OriginalNum = NumToCount;
	return;
}

function Reset()
{
	NumToCount = OriginalNum;
	return;
}

//------------------------------------------------------------------
// ResetOriginalData
//	
//------------------------------------------------------------------
simulated function ResetOriginalData()
{
	// End:0x10
	if(m_bResetSystemLog)
	{
		LogResetSystem(false);
	}
	super(Actor).ResetOriginalData();
	NumToCount = OriginalNum;
	return;
}

//
// Counter was triggered.
//
function Trigger(Actor Other, Pawn EventInstigator)
{
	local string S, Num;
	local int i;

	// End:0x175
	if((int(NumToCount) > 0))
	{
		// End:0x5F
		if((int((--NumToCount)) == 0))
		{
			// End:0x47
			if((bShowMessage && (CompleteMessage != "")))
			{
				EventInstigator.ClientMessage(CompleteMessage);
			}
			TriggerEvent(Event, Other, EventInstigator);			
		}
		else
		{
			// End:0x175
			if((bShowMessage && (CountMessage != "")))
			{
				switch(NumToCount)
				{
					// End:0x90
					case 1:
						Num = "one";
						// End:0x106
						break;
					// End:0xA3
					case 2:
						Num = "two";
						// End:0x106
						break;
					// End:0xB8
					case 3:
						Num = "three";
						// End:0x106
						break;
					// End:0xCC
					case 4:
						Num = "four";
						// End:0x106
						break;
					// End:0xE0
					case 5:
						Num = "five";
						// End:0x106
						break;
					// End:0xF3
					case 6:
						Num = "six";
						// End:0x106
						break;
					// End:0xFFFF
					default:
						Num = string(NumToCount);
						// End:0x106
						break;
						break;
				}
				S = CountMessage;
				J0x111:

				// End:0x161 [Loop If]
				if((InStr(S, "%i") >= 0))
				{
					i = InStr(S, "%i");
					S = ((Left(S, i) $ Num) $ Mid(S, (i + 2)));
					// [Loop Continue]
					goto J0x111;
				}
				EventInstigator.ClientMessage(S);
			}
		}
	}
	return;
}

defaultproperties
{
	NumToCount=2
	CountMessage="Only %i more to go..."
	CompleteMessage="Completed!"
	Texture=Texture'Gameplay.S_Counter'
}
