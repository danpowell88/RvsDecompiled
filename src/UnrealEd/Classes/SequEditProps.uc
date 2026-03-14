//=============================================================================
// SequEditProps - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// Object to facilitate properties editing
//=============================================================================
//  Sequence / Mesh editor object to expose/shuttle only selected editable 
//
class SequEditProps extends Object
    native
    hidecategories(Object);

var const int WBrowserAnimationPtr;
var(SequenceProperties) float Rate;
var(SequenceProperties) float Compression;
var(SequenceProperties) name SequenceName;
var(Groups) array<name> Groups;

