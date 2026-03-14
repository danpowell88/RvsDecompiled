//=============================================================================
// R6AbstractNoiseMgr - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6AbstractNoiseMgr.uc : Store value for sound loudness of MakeNoise
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/15 * Created by Guillaume Borgia
//=============================================================================
class R6AbstractNoiseMgr extends Object
    abstract
    native;

event R6MakeNoise(Actor.ESoundType eType, Actor Source)
{
	return;
}

function R6MakePawnMovementNoise(R6AbstractPawn Pawn)
{
	return;
}

function Init()
{
	return;
}

