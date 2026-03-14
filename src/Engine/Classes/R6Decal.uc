//============================================================================//
// Class            R6Decal.uc 
// Created By       Cyrille Lauzon
// Date             2001/01/18
// Description      R6 base class for wall Decals made with guns.
//----------------------------------------------------------------------------//
// Modification History
//      2002/04/26  Jean-Francois Dube (added ScaleProjector state)
//============================================================================//
class R6Decal extends Projector
    native;

// --- Variables ---
var bool m_bNeedScale;
var bool m_bActive;

state ScaleProjector
{
    simulated function Tick(float DeltaTime) {}
    function EndState() {}
    function BeginState() {}
}

defaultproperties
{
}
