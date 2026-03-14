//=============================================================================
//  R6WindowListServerInfoItem.uc : Class used to hold the values for 
//  the entries in the list of maps in the ServerInfo tab in the multi player menu.
//
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/03 * Created by John Bennett
//=============================================================================
class R6WindowListInfoMapItem extends UWindowListBoxItem;

// --- Variables ---
var float fTypeWidth;
var float fMapWidth;
var float fTypeXOff;
var float fMapXOff;
// Game type
var string szType;
// Map name
var string szMap;

defaultproperties
{
}
