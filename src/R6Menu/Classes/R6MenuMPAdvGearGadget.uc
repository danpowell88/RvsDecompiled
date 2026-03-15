//=============================================================================
// R6MenuMPAdvGearGadget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuMPAdvGearGadget.uc : This will display the current 2D model
//                        of one of the 2 gadgets selected for the current 
//                        operative in adversial
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/14 * Created by Alexandre Dionne
//=============================================================================
class R6MenuMPAdvGearGadget extends R6MenuGearGadget;

function Created()
{
	m_2DGadgetWidth = WinWidth;
	super.Created();
	return;
}

//=================================================================
// SetBorderColor: set the border color
//=================================================================
function SetBorderColor(Color _NewColor)
{
	m_BorderColor = _NewColor;
	return;
}

defaultproperties
{
	m_bAssignAllButton=false
	m_bCenterTexture=true
}
