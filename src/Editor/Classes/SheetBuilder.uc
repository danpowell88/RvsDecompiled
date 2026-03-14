//=============================================================================
// SheetBuilder: Builds a simple sheet.
//=============================================================================
class SheetBuilder extends BrushBuilder;

// --- Enums ---
enum ESheetAxis
{
    // enum values not recoverable from binary — see 1.56 source
};

// --- Variables ---
var int Width;
var int Height;
var int VertBreaks;
var int HorizBreaks;
var ESheetAxis Axis;
var name GroupName;

// --- Functions ---
event bool Build() {}

defaultproperties
{
}
