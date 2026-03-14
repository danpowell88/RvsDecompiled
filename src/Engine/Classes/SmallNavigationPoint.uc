// SmallNavigationPoint — navigation point subtype for tight spaces.
// Marks pathfinding nodes that only small-collision actors can use,
// preventing large pawns from trying to path through narrow gaps.
// Extracted from retail Engine.u.
// SmallNavigationPoint
// Convenience class, to allow single point to specify small navigation point sizes
class SmallNavigationPoint extends NavigationPoint
    native
    abstract;

defaultproperties
{
}
