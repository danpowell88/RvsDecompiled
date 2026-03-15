//=============================================================================
// R6WindowRightClickMenu - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowRightClickMenu.uc : This class is used to create a "right-click"
//  menu at a given position.  A drop down menu will appear and the user
//  can select from the list of choices
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/24 * Created by John Bennett
//=============================================================================
class R6WindowRightClickMenu extends R6WindowComboControl;

//------------------------------------------------------------
// Once the user has selected an item from the list, hide this
// menu.
//------------------------------------------------------------
function CloseUp()
{
	super(UWindowComboControl).CloseUp();
	HideWindow();
	// End:0x21
	if((GetValue() != ""))
	{
		Notify(3);
	}
	return;
}

//------------------------------------------------------------
// Display the menu at the position indicated by the function
// arguments
//------------------------------------------------------------
function DisplayMenuHere(float fXPos, float fYPos)
{
	SetValue("");
	List.Selected = none;
	// End:0x4B
	if(((fXPos + WinWidth) > float(640)))
	{
		WinLeft = ((640.0000000 - WinWidth) - float(12));		
	}
	else
	{
		WinLeft = fXPos;
	}
	WinTop = fYPos;
	ShowWindow();
	BringToFront();
	DropDown();
	return;
}

//------------------------------------------------------------
// Called when the window is first created.
//------------------------------------------------------------
function Created()
{
	WinHeight = 0.0000000;
	super.Created();
	return;
}

