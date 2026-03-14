//=============================================================================
//  R6AbstractCorpse.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/12 * Created by Guillaume Borgia
//=============================================================================
class R6AbstractCorpse extends Actor
    native;

// --- Functions ---
final native function RenderBones(Canvas C) {}
// ^ NEW IN 1.60
final native function FirstInit(R6AbstractPawn pawnOwner) {}
// ^ NEW IN 1.60
final native function AddImpulseToBone(int iTracedBone, Vector vMomentum) {}
// ^ NEW IN 1.60
function RenderCorpseBones(Canvas C) {}
function TakeAHit(int iBone, Vector vMomentum) {}

defaultproperties
{
}
