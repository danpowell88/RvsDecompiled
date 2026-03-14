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
	if(__NFUN_129__(m_bInit))
	{
		serverIni = Class'Engine.Actor'.static.__NFUN_1524__().GetServerIni();
		__NFUN_1010__(__NFUN_112__(serverIni, ".ini"));
		m_bInit = true;
	}
	return;
}

//function int GetNextMapIndex(OPTIONAL int iNextMapNum)
function int GetNextMapIndex(int iNextMapNum)
{
	local int iNextNum;

	// End:0x30
	if(__NFUN_150__(iNextMapNum, -1))
	{
		iNextNum = __NFUN_146__(Level.Game.__NFUN_1280__(), 1);		
	}
	else
	{
		iNextNum = __NFUN_147__(iNextMapNum, 1);
	}
	// End:0x4F
	if(__NFUN_151__(iNextNum, __NFUN_147__(32, 1)))
	{
		return 0;
	}
	// End:0x91
	if(__NFUN_150__(iNextNum, 0))
	{
		iNextNum = 0;
		J0x61:

		// End:0x91 [Loop If]
		if(__NFUN_130__(__NFUN_123__(Maps[__NFUN_146__(iNextNum, 1)], ""), __NFUN_150__(iNextNum, __NFUN_147__(32, 1))))
		{
			__NFUN_165__(iNextNum);
			// [Loop Continue]
			goto J0x61;
		}
	}
	// End:0xA5
	if(__NFUN_122__(Maps[iNextNum], ""))
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
	return Maps[GetNextMapIndex(__NFUN_146__(iMapIndex, 1))];
	return;
}

function string CheckNextGameType()
{
	return GameType[GetNextMapIndex(-2)];
	return;
}

function string CheckNextGameTypeIndex(int iMapIndex)
{
	return GameType[GetNextMapIndex(__NFUN_146__(iMapIndex, 1))];
	return;
}

function string CheckCurrentMap()
{
	return Maps[Level.Game.__NFUN_1280__()];
	return;
}

function string CheckCurrentGameType()
{
	return GameType[Level.Game.__NFUN_1280__()];
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
	Level.Game.__NFUN_1281__(_iMapNum);
	return Maps[_iMapNum];
	return;
}

