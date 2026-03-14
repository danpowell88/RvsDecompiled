//=============================================================================
//  R6PlayerInput.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/05/07 * Created by Aristomenis Kolokathis
//=============================================================================
class R6PlayerInput extends PlayerInput
    transient
    config(User);

// --- Variables ---
var bool m_bWasFluidMovement;
var bool m_bFluidMovement;
var bool m_bIgnoreInput;

// --- Functions ---
event PlayerInput(float DeltaTime) {}
function UpdateMouseOptions() {}
// check for double click move
function EDoubleClickDir CheckForDoubleClickMove(float DeltaTime) {}
// ^ NEW IN 1.60

defaultproperties
{
}
