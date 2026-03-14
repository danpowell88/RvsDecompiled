//=============================================================================
// R6ClimbablePoint - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6ClimbablePoint extends NavigationPoint
    native
    hidecategories(Lighting,LightColor,Karma,Force);

var R6ClimbableObject m_climbableObj;
var R6ClimbablePoint m_connectedClimbablePoint;
var Vector m_vLookDir;

