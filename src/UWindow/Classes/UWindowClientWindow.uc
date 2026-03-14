//=============================================================================
// UWindowClientWindow - a blanked client-area window.
//=============================================================================
class UWindowClientWindow extends UWindowWindow;

#exec TEXTURE IMPORT NAME=Background FILE=Textures\Background.pcx GROUP="Icons" MIPS=OFF

// --- Functions ---
function Close(optional bool bByParent) {}

defaultproperties
{
}
