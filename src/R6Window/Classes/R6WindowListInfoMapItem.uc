//=============================================================================
// R6WindowListInfoMapItem - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6WindowListServerInfoItem.uc : Class used to hold the values for 
//  the entries in the list of maps in the ServerInfo tab in the multi player menu.
//
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/03 * Created by John Bennett
//=============================================================================
class R6WindowListInfoMapItem extends UWindowListBoxItem;

var float fMapXOff;
var float fTypeXOff;
var float fMapWidth;
var float fTypeWidth;
var string szMap;  // Map name
var string szType;  // Game type

defaultproperties
{
	fMapXOff=5.0000000
	fTypeXOff=68.0000000
	fMapWidth=60.0000000
	fTypeWidth=159.0000000
}
