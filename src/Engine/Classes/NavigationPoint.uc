//=============================================================================
// NavigationPoint - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// NavigationPoint.
//
// NavigationPoints are organized into a network to provide AIControllers 
// the capability of determining paths to arbitrary destinations in a level
//
//=============================================================================
class NavigationPoint extends Actor
    native
    notplaceable
    hidecategories(Lighting,LightColor,Karma,Force);

var int visitedWeight;
var const int bestPathWeight;
var int cost;  // added cost to visit this pathnode
var() int ExtraCost;  // Extra weight added by level designer
var bool taken;  // set when a creature is occupying this spot
var() bool bBlocked;  // this path is currently unuseable
var() bool bPropagatesSound;  // this navigation point can be used for sound propagation (around corners)
var() bool bOneWayPath;  // reachspecs from this path only in the direction the path is facing (180 degrees)
var() bool bNeverUseStrafing;  // shouldn't use bAdvancedTactics going to this point
var() bool bAlwaysUseStrafing;  // shouldn't use bAdvancedTactics going to this point
var const bool bForceNoStrafing;  // override any LD changes to bNeverUseStrafing
var const bool bAutoBuilt;  // placed during execution of "PATHS BUILD"
var bool bSpecialMove;  // if true, pawn will call SuggestMovePreparation() when moving toward this node
var bool bNoAutoConnect;  // don't connect this path to others except with special conditions (used by LiftCenter, for example)
var const bool bNotBased;  // used by path builder - if true, no error reported if node doesn't have a valid base
var const bool bPathsChanged;  // used for incremental path rebuilding in the editor
var bool bDestinationOnly;  // used by path building - means no automatically generated paths are sourced from this node
var bool bSourceOnly;  // used by path building - means this node is not the destination of any automatically generated path
var bool bSpecialForced;  // paths that are forced should call the SpecialCost() and SuggestMovePreparation() functions
var bool bMustBeReachable;  // used for PathReview code
//#ifdef R6CODE
var const bool m_bExactMove;  // used for navigation point we want the pawn to move precisely to the center (like doors)
var const NavigationPoint nextNavigationPoint;
var const NavigationPoint nextOrdered;  // for internal use during route searches
var const NavigationPoint prevOrdered;  // for internal use during route searches
var const NavigationPoint previousPath;
var() name ProscribedPaths[4];  // list of names of NavigationPoints which should never be connected from this path
var() name ForcedPaths[4];  // list of names of NavigationPoints which should always be connected from this path
//------------------------------------------------------------------------------
// NavigationPoint variables
var const array<ReachSpec> PathList;  // index of reachspecs (used by C++ Navigation code)
var transient bool bEndPoint;  // used by C++ navigation code

event int SpecialCost(Pawn Seeker, ReachSpec Path)
{
	return;
}

// Accept an actor that has teleported in.
// used for random spawning and initial placement of creatures
event bool Accept(Actor Incoming, Actor Source)
{
	taken = Incoming.__NFUN_267__(Location) /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/ /*unknown*/;
	// End:0x4E
	if(taken)
	{
		Incoming.Velocity = vect(0.0000000, 0.0000000, 0.0000000);
		Incoming.__NFUN_299__(Rotation);
	}
	Incoming.PlayTeleportEffect(true, false);
	TriggerEvent(Event, self, Pawn(Incoming));
	return taken;
	return;
}

event bool SuggestMovePreparation(Pawn Other)
{
	return false;
	return;
}

function bool ProceedWithMove(Pawn Other)
{
	return true;
	return;
}

function MoverOpened()
{
	return;
}

function MoverClosed()
{
	return;
}

defaultproperties
{
	bPropagatesSound=true
	bStatic=true
	bHidden=true
	bNoDelete=true
	bCollideWhenPlacing=true
	CollisionRadius=80.0000000
	CollisionHeight=100.0000000
	Texture=Texture'Engine.S_NavP'
}
