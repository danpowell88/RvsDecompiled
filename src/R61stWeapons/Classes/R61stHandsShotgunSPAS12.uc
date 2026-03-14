//===============================================================================
//  [R61stHandsShotgunSPAS12]   
//===============================================================================
class R61stHandsShotgunSPAS12 extends R61stHandsShotgunM1;

#exec OBJ LOAD FILE=..\Animations\R61stHands_UKX.ukx PACKAGE=R61stHands_UKX

// --- Functions ---
function PostBeginPlay() {}

state Reloading
{
    simulated event AnimEnd(int Channel) {}
    function EndState() {}
    simulated function BeginState() {}
}

defaultproperties
{
}
