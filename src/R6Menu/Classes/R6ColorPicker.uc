//=============================================================================
// R6ColorPicker - Color picker for the writable map
//=============================================================================
class R6ColorPicker extends UWindowDialogControl;

#exec OBJ LOAD FILE="..\textures\Color.utx" Package="Color.Color"

// --- Constants ---
const PICKHEIGHT =  20;
const PICKWIDTH =  40;
const NUM_COLOR =  5;

// --- Variables ---
var int m_iSelectedColorIndex;
var Color m_aColorChoice[5];

// --- Functions ---
function Paint(Canvas C, float Y, float X) {}
function LMouseDown(float Y, float X) {}
function Color GetSelectedColor() {}
// ^ NEW IN 1.60

defaultproperties
{
}
