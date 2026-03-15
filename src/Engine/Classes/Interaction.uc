//=============================================================================
// Interaction - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
// ====================================================================
//  Class:  Engine.Interaction
//  
//  Each individual Interaction is a jumping point in UScript.  The should
//  be the foundatation for any subsystem that requires interaction with
//  the player (such as a menu).  
//
//  Interactions take on two forms, the Global Interaction and the Local
//  Interaction.  The GI get's to process data before the LI and get's
//  render time after the LI, so in essence the GI wraps the LI.
//
//  A dynamic array of GI's are stored in the InteractionMaster while
//  each Viewport contains an array of LIs.
//
//
// (c) 2001, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class Interaction extends Interactions
    native;

var bool bActive;  // Is this interaction Getting Input
var bool bVisible;  // Is this interaction being Displayed
var bool bRequiresTick;  // Does this interaction require game TICK
var Player ViewportOwner;  // Pointer to the ViewPort that "Owns" this interaction or none if it's Global
var InteractionMaster Master;  // Pointer to the Interaction Master

// Export UInteraction::execInitialize(FFrame&, void* const)
native function Initialize();

// Export UInteraction::execConsoleCommand(FFrame&, void* const)
native function bool ConsoleCommand(coerce string S);

// Export UInteraction::execWorldToScreen(FFrame&, void* const)
// ====================================================================
// WorldToScreen - Returns the X/Y screen coordinates in to a viewport of a given vector
// in the world. 
// ====================================================================
native function Vector WorldToScreen(Vector Location, optional Vector CameraLocation, optional Rotator CameraRotation);

// Export UInteraction::execScreenToWorld(FFrame&, void* const)
// ====================================================================
// ScreenToWorld - Converts an X/Y screen coordinate in to a world vector
// ====================================================================
native function Vector ScreenToWorld(Vector Location, optional Vector CameraLocation, optional Rotator CameraRotation);

event Initialized()
{
	return;
}

event ServerDisconnected()
{
	return;
}

//#ifdef R6CODE
event UserDisconnected()
{
	return;
}

//#endif // #ifdef R6CODE
event ConnectionFailed()
{
	return;
}

//#ifdef R6CODE
event R6ConnectionFailed(string szError)
{
	return;
}

event R6ConnectionSuccess()
{
	return;
}

event R6ConnectionInterrupted()
{
	return;
}

event R6ConnectionInProgress()
{
	return;
}

event R6ProgressMsg(string _Str1, string _Str2, float Seconds)
{
	return;
}

function Object SetGameServiceLinks(PlayerController _localPlayer)
{
	return;
}

event NotifyLevelChange()
{
	return;
}

event NotifyAfterLevelChange()
{
	return;
}

event MenuLoadProfile(bool _bServerProfile)
{
	return;
}

event LaunchR6MainMenu()
{
	return;
}

// NEW IN 1.60
event string GetStoreGamePwd()
{
	return;
}

function SendGoCode(Object.EGoCode eGo)
{
	return;
}

function Message(coerce string Msg, float MsgLife)
{
	return;
}

function bool KeyType(out Interactions.EInputKey Key)
{
	return false;
	return;
}

function bool KeyEvent(out Interactions.EInputKey Key, out Interactions.EInputAction Action, float Delta)
{
	return false;
	return;
}

function PreRender(Canvas Canvas)
{
	return;
}

function PostRender(Canvas Canvas)
{
	return;
}

function SetFocus()
{
	Master.SetFocusTo(self, ViewportOwner);
	return;
}

function Tick(float DeltaTime)
{
	return;
}

//#ifdef R6CODE
// ====================================================================
// ConvertKeyToLocalisation: This is convert a key to the name of the key localization
// Ex: english to french : A is A -- Space is Espace -- Backspace is reculer etc...
//	   the localization is in R6Menu.int 
// ====================================================================
event string ConvertKeyToLocalisation(byte _Key, string _szEnumKeyName)
{
	local string szResult;

	// End:0x40
	if(((int(_Key) > (int(48) - 1)) && (int(_Key) < (int(57) + 1))))
	{
		szResult = string((int(_Key) - int(48)));		
	}
	else
	{
		// End:0x7A
		if(((int(_Key) > (int(65) - 1)) && (int(_Key) < (int(90) + 1))))
		{
			szResult = Chr(int(_Key));			
		}
		else
		{
			// End:0xC2
			if(((int(_Key) > (int(112) - 1)) && (int(_Key) < (int(135) + 1))))
			{
				szResult = ("F" $ string(((int(_Key) - int(112)) + 1)));				
			}
			else
			{
				szResult = Localize("Interactions", ("IK_" $ _szEnumKeyName), "R6Menu");
				// End:0x127
				if((szResult == Localize("Interactions", "IK_None", "R6Menu")))
				{
					szResult = "";
				}
			}
		}
	}
	return szResult;
	return;
}

defaultproperties
{
	bActive=true
}
