//=============================================================================
// NavigationPoint.
//
// NavigationPoints are organized into a network to provide AIControllers 
// the capability of determining paths to arbitrary destinations in a level
//
//=============================================================================
class NavigationPoint extends Actor
    native;

#exec Texture Import File=Textures\S_Pickup.pcx Name=S_Pickup Mips=Off MASKED=1
#exec Texture Import File=Textures\SpwnAI.pcx Name=S_NavP Mips=Off MASKED=1
#exec Texture Import File=Textures\SiteLite.pcx Name=S_Alarm Mips=Off MASKED=1

// --- Variables ---
// set when a creature is occupying this spot
var bool taken;
var bool bBlocked;
// ^ NEW IN 1.60
var const NavigationPoint nextNavigationPoint;
//------------------------------------------------------------------------------
// NavigationPoint variables
//index of reachspecs (used by C++ Navigation code)
var const array<array> PathList;
var name ProscribedPaths[4];
// ^ NEW IN 1.60
var name ForcedPaths[4];
// ^ NEW IN 1.60
var int visitedWeight;
var const int bestPathWeight;
// for internal use during route searches
var const NavigationPoint nextOrdered;
// for internal use during route searches
var const NavigationPoint prevOrdered;
var const NavigationPoint previousPath;
// added cost to visit this pathnode
var int cost;
var int ExtraCost;
// ^ NEW IN 1.60
// used by C++ navigation code
var transient bool bEndPoint;
var bool bPropagatesSound;
// ^ NEW IN 1.60
var bool bOneWayPath;
// ^ NEW IN 1.60
var bool bNeverUseStrafing;
// ^ NEW IN 1.60
var bool bAlwaysUseStrafing;
// ^ NEW IN 1.60
// override any LD changes to bNeverUseStrafing
var const bool bForceNoStrafing;
// placed during execution of "PATHS BUILD"
var const bool bAutoBuilt;
// if true, pawn will call SuggestMovePreparation() when moving toward this node
var bool bSpecialMove;
// don't connect this path to others except with special conditions (used by LiftCenter, for example)
var bool bNoAutoConnect;
// used by path builder - if true, no error reported if node doesn't have a valid base
var const bool bNotBased;
// used for incremental path rebuilding in the editor
var const bool bPathsChanged;
// used by path building - means no automatically generated paths are sourced from this node
var bool bDestinationOnly;
// used by path building - means this node is not the destination of any automatically generated path
var bool bSourceOnly;
// paths that are forced should call the SpecialCost() and SuggestMovePreparation() functions
var bool bSpecialForced;
// used for PathReview code
var bool bMustBeReachable;
//#ifdef R6CODE
// used for navigation point we want the pawn to move precisely to the center (like doors)
var const bool m_bExactMove;

// --- Functions ---
event bool SuggestMovePreparation(Pawn Other) {}
// ^ NEW IN 1.60
function bool ProceedWithMove(Pawn Other) {}
// ^ NEW IN 1.60
event int SpecialCost(Pawn Seeker, ReachSpec Path) {}
// ^ NEW IN 1.60
function MoverOpened() {}
function MoverClosed() {}
// Accept an actor that has teleported in.
// used for random spawning and initial placement of creatures
event bool Accept(Actor Incoming, Actor Source) {}
// ^ NEW IN 1.60

defaultproperties
{
}
