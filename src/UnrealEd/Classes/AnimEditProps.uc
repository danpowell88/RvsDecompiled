//=============================================================================
// AnimEditProps - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// Object to facilitate properties editing
//=============================================================================
//  Animation / Mesh editor object to expose/shuttle only selected editable 
//  parameters from UMeshAnim/ UMesh objects back and forth in the editor.
//
class AnimEditProps extends Object
	native
 hidecategories(Object);

var const int WBrowserAnimationPtr;
var(Compression) float GlobalCompression;

defaultproperties
{
	GlobalCompression=1.0000000
}
