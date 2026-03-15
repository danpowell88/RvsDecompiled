//=============================================================================
// R6MenuWidget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MenuWidget.uc : Base class for our game menus
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/12 * Created by Alexandre Dionne
//=============================================================================
class R6MenuWidget extends UWindowDialogClientWindow;

var float m_fLeftMouseXClipping;
var float m_fLeftMouseYClipping;
var float m_fRightMouseXClipping;
var float m_fRightMouseYClipping;

function Reset()
{
	return;
}

function SetMousePos(float X, float Y)
{
	Root.Console.MouseX = X;
	Root.Console.MouseY = Y;
	return;
}

function KeyDown(int Key, float X, float Y)
{
	// End:0x1A8
	if((Key == int(Root.Console.27)))
	{
		switch(Root.m_eCurWidgetInUse)
		{
			// End:0x3E
			case Root.5:
			// End:0x4C
			case Root.14:
			// End:0x5A
			case Root.4:
			// End:0x7C
			case Root.15:
				Root.ChangeCurrentWidget(7);
				// End:0x1A8
				break;
			// End:0xE5
			case Root.19:
				// End:0xD1
				if(R6Console(Root.Console).m_bStartedByGSClient)
				{
					Root.ChangeCurrentWidget(20);
					Class'Engine.Actor'.static.GetGameManager().RemoveFromIDList();					
				}
				else
				{
					Root.ChangeCurrentWidget(15);
				}
				// End:0x1A8
				break;
			// End:0x119
			case Root.16:
				R6MenuOptionsWidget(self).m_ButtonReturn.Click(0.0000000, 0.0000000);
				// End:0x1A8
				break;
			// End:0x13B
			case Root.13:
				Root.ChangeCurrentWidget(17);
				// End:0x1A8
				break;
			// End:0x149
			case Root.8:
			// End:0x157
			case Root.12:
			// End:0x194
			case Root.9:
				R6MenuLaptopWidget(self).m_NavBar.m_MainMenuButton.Click(0.0000000, 0.0000000);
				// End:0x1A8
				break;
			// End:0x1A2
			case Root.7:
			// End:0xFFFF
			default:
				// End:0x1A8
				break;
				break;
		}
	}
	return;
}

defaultproperties
{
	m_fRightMouseXClipping=640.0000000
	m_fRightMouseYClipping=480.0000000
	bAcceptsFocus=true
	bAlwaysAcceptsFocus=true
}
