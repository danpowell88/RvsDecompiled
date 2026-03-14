//=============================================================================
//  R6InteractiveObjectActionLoopRandomAnim.uc : Interactive object action that plays random
//  animations in a loop. m_aAnimName holds the set of animation names to choose from.
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/23 * Created by Guillaume Borgia
//=============================================================================
class R6InteractiveObjectActionLoopRandomAnim extends R6InteractiveObjectAction;

// --- Variables ---
var array<array> m_aAnimName;

// --- Functions ---
function name GetNextAnim() {}

defaultproperties
{
}
