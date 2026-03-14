//=============================================================================
// UWindowPageControlPage - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowPageControlPage extends UWindowTabControlItem;

var UWindowPageWindow Page;

function RightClickTab()
{
	Page.RightClickTab();
	return;
}

function UWindowPageControlPage NextPage()
{
	return UWindowPageControlPage(Next);
	return;
}

