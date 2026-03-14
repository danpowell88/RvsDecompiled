//================================================================================
// R6AbstractEviLPatchService.
//================================================================================
class R6AbstractEviLPatchService extends Object
    native;

// --- Enums ---
enum PatchState
{
    // enum values not recoverable from binary — see 1.56 source
};

// --- Functions ---
static native function PatchState GetState() {}

defaultproperties
{
}
