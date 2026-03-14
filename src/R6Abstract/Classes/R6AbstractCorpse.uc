//=============================================================================
// R6AbstractCorpse - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6AbstractCorpse.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/12 * Created by Guillaume Borgia
//=============================================================================
class R6AbstractCorpse extends Actor
	native
 notplaceable;

function RenderCorpseBones(Canvas C)
{
	return;
}

function TakeAHit(int iBone, Vector vMomentum)
{
	return;
}

// Export UR6AbstractCorpse::execRenderBones(FFrame&, void* const)
 native(1802) final function RenderBones(Canvas C);

// Export UR6AbstractCorpse::execFirstInit(FFrame&, void* const)
 native(1803) final function FirstInit(R6AbstractPawn pawnOwner);

// Export UR6AbstractCorpse::execAddImpulseToBone(FFrame&, void* const)
 native(1804) final function AddImpulseToBone(int iTracedBone, Vector vMomentum);

defaultproperties
{
	bHidden=true
}
