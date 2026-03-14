//=============================================================================
//  R6ActionPointAbstract.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/04 * Created by Jean-Francois Dube
//=============================================================================
class R6ActionPointAbstract extends Actor
    native
    abstract;

// --- Variables ---
// previous point in the current planning
var R6ActionPointAbstract prevActionPoint;
// list of navigation point to reach the next Action Point
var array<array> m_PathToNextPoint;

// --- Functions ---
function ResetPathNode() {}
function ResetActionIcon() {}

defaultproperties
{
}
