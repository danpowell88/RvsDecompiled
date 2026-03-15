//=============================================================================
// UWindowInfo - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  UWindowInfo.uc : Additionnal official informations for mission pack, publicity, etc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/07/24  * Create by Yannick Joly
//=============================================================================
class UWindowInfo extends Object
    config(R6Info);

// mod/mission pack publicity
var config array<string> m_AModsInfo;

defaultproperties
{
	m_AModsInfo[0]="RavenShield"
	m_AModsInfo[1]="AthenaSword"
}
