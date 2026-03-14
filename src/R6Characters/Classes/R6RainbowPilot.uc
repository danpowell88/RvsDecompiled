//=============================================================================
//  R6RainbowPilot.uc : Rainbow pawn variant representing the pilot role in Escort Pilot mode;
//                      overrides face texture and supports night-vision attachment.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/15 * Created by Rima Brek
//=============================================================================
class R6RainbowPilot extends R6RainbowPawn;

// --- Functions ---
simulated event PostBeginPlay() {}
// ^ NEW IN 1.60
simulated function SetRainbowFaceTexture() {}
simulated function AttachNightVision() {}

defaultproperties
{
}
