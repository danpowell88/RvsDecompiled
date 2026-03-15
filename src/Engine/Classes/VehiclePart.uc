//=============================================================================
// VehiclePart — abstract component of a Vehicle, ticked each frame.
// Subclasses implement Update() to animate or simulate the part.
// Activate() can enable/disable the part.
// Extracted from retail Engine.u.
//=============================================================================

class VehiclePart extends Actor
	native
	abstract
	placeable;

var bool bUpdating;		// set true if currently updating

// Update() called each tick by the Vehicle which owns this vehiclepart
function Update(float DeltaTime);

function Activate(bool bActive);

defaultproperties
{
}