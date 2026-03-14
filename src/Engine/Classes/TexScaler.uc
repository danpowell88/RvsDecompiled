//=============================================================================
// TexScaler - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class TexScaler extends TexModifier
    native
	editinlinenew
    collapsecategories
    hidecategories(Object,Material);

var() float UScale;
var() float VScale;
var() float UOffset;
var() float VOffset;
var Matrix M;

defaultproperties
{
	UScale=1.0000000
	VScale=1.0000000
}
