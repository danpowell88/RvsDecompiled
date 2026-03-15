//=============================================================================
// R6MapList - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MapList.uc : Map List
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//  Used to create a list of maps to cycyle through in adversarial mode.
//
//  Revision history:
//    2002/04/22 * Created by John Bennett
//=============================================================================
class R6MapList extends MapList
    native
    config
    notplaceable
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

var bool m_bInit;
var config string GameType[32];

event PreBeginPlay()
{
	local string serverIni;

	super(Actor).PreBeginPlay();
	// End:0x45
	if((!m_bInit))
	{
		serverIni = Class'Engine.Actor'.static.GetModMgr().GetServerIni();
		LoadConfig((serverIni $ ".ini"));
		m_bInit = true;
	}
	return;
}

//function int GetNextMapIndex(OPTIONAL int iNextMapNum)
function int GetNextMapIndex(int iNextMapNum)
{
	local int iNextNum;

	// End:0x30
	if((iNextMapNum < -1))
	{
		iNextNum = (Level.Game.GetCurrentMapNum() + 1);		
	}
	else
	{
		iNextNum = (iNextMapNum - 1);
	}
	// End:0x4F
	if((iNextNum > (32 - 1)))
	{
		return 0;
	}
	// End:0x91
	if((iNextNum < 0))
	{
		iNextNum = 0;
		J0x61:

		// End:0x91 [Loop If]
		if(((Maps[(iNextNum + 1)] != "") && (iNextNum < (32 - 1))))
		{
			(iNextNum++);
			// [Loop Continue]
			goto J0x61;
		}
	}
	// End:0xA5
	if((Maps[iNextNum] == ""))
	{
		return 0;
	}
	return iNextNum;
	return;
}

function string CheckNextMap()
{
	return Maps[GetNextMapIndex(-2)];
	return;
}

function string CheckNextMapIndex(int iMapIndex)
{
	return Maps[GetNextMapIndex((iMapIndex + 1))];
	return;
}

function string CheckNextGameType()
{
	return GameType[GetNextMapIndex(-2)];
	return;
}

function string CheckNextGameTypeIndex(int iMapIndex)
{
	return GameType[GetNextMapIndex((iMapIndex + 1))];
	return;
}

function string CheckCurrentMap()
{
	return Maps[Level.Game.GetCurrentMapNum()];
	return;
}

function string CheckCurrentGameType()
{
	return GameType[Level.Game.GetCurrentMapNum()];
	return;
}

//------------------------------------------------------------------
// GetNextMapIndex: Get the next map, increase the counter and save
//	the setting
//------------------------------------------------------------------
function string GetNextMap(int iNextMapNum)
{
	local int _iMapNum;

	_iMapNum = GetNextMapIndex(iNextMapNum);
	Level.Game.SetCurrentMapNum(_iMapNum);
	return Maps[_iMapNum];
	return;
}

