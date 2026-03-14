//============================================================================//
//  R6Magazine.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Class used to regoup the Magazines in the editor.
//
//============================================================================//

class R6Magazine extends actor
    Abstract;

var (R6Magazine)  BOOL bDisplayedOnceInserted;   //????  Might be useful?

defaultproperties
{
     bDisplayedOnceInserted=True
     RemoteRole=ROLE_AutonomousProxy
     DrawScale3D=(X=-1.000000,Y=-1.000000)
}
