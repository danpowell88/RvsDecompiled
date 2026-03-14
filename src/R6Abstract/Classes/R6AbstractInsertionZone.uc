//=============================================================================
//  R6AbstractInsertionZone.uc : Abstract NavigationPoint marking a mission insertion (spawn) area.
//  Each zone has an index (m_iInsertionNumber) used to assign starting positions per team slot.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/06 * Created by Aristomenis Kolokathis
//=============================================================================
class R6AbstractInsertionZone extends PlayerStart
    native
    notplaceable;

// --- Variables ---
var int m_iInsertionNumber;

defaultproperties
{
}
