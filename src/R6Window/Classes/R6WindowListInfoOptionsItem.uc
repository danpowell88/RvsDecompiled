//=============================================================================
// R6WindowListInfoOptionsItem - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6WindowListServerInfoItem.uc : Class used to hold the values for 
//  the entries in the list of options in the ServerInfo tab in the multi player menu.
//
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/03 * Created by John Bennett
//=============================================================================
class R6WindowListInfoOptionsItem extends UWindowListBoxItem;

var float fOptionsXOff;
var string szOptions;  // ServerOptions

defaultproperties
{
	fOptionsXOff=5.0000000
}
