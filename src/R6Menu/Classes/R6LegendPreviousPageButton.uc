//=============================================================================
// R6LegendPreviousPageButton - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6LegendPreviousPageButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/30 * Created by Joel Tremblay
//=============================================================================
class R6LegendPreviousPageButton extends UWindowButton;

function Created()
{
	bNoKeyboard = true;
	ToolTipString = Localize("PlanningLegend", "MainPrevious", "R6Menu");
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	return;
}

function LMouseDown(float X, float Y)
{
	super(UWindowWindow).LMouseDown(X, Y);
	R6WindowLegend(ParentWindow).PreviousPage();
	return;
}

defaultproperties
{
	bStretched=true
	bUseRegion=true
	UpTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	DownTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	OverTexture=Texture'R6MenuTextures.Gui_BoxScroll'
	UpRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=61474,ZoneNumber=0)
	DownRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=61474,ZoneNumber=0)
	OverRegion=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=61474,ZoneNumber=0)
}
