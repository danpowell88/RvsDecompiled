//=============================================================================
// R6WindowListAreaItem - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6WindowListAreaItem.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowListAreaItem extends UWindowListBoxItem;

var R6WindowArea m_Area;

function SetFront()
{
	// End:0x1A
	if((m_Area != none))
	{
		m_Area.BringToFront();
	}
	return;
}

function SetBack()
{
	// End:0x1A
	if((m_Area != none))
	{
		m_Area.SendToBack();
	}
	return;
}

