//=============================================================================
// R6WindowListButtonItem - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowListButtonItem.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowListButtonItem extends UWindowListBoxItem;

var R6WindowButton m_Button;

function SetFront()
{
	// End:0x1A
	if(__NFUN_119__(m_Button, none))
	{
		m_Button.BringToFront();
	}
	return;
}

function SetBack()
{
	// End:0x1A
	if(__NFUN_119__(m_Button, none))
	{
		m_Button.SendToBack();
	}
	return;
}

