//=============================================================================
//  R6CameraSpot.uc : Editor-placed actor that marks a named camera position in a level.
//  Used by the in-game planning/cinematic system to set up fixed camera viewpoints.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/05 * Created by Aristomenis Kolokathis
//=============================================================================
class R6CameraSpot extends Actor;

#exec Texture Import File=Textures\R6CameraSpot.pcx Name=S_CameraSpot Mips=Off MASKED=1

defaultproperties
{
}
