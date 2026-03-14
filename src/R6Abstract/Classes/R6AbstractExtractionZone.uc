//=============================================================================
//  R6AbstractExtractionZone.uc : Abstract NavigationPoint marking a mission extraction area.
//  Placed non-interactively; game logic detects pawns entering this zone to trigger extraction.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/06 * Created by Aristomenis Kolokathis
//=============================================================================
class R6AbstractExtractionZone extends NavigationPoint
    native
    notplaceable;

defaultproperties
{
}
