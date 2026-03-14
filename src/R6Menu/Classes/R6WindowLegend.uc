//=============================================================================
//  R6WindowLegend.uc : Planning phase legend window.  
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/29/04 * Created by Joel Tremblay
//=============================================================================
class R6WindowLegend extends R6MenuFramePopup;

// --- Variables ---
var R6MenuLegendPage m_LegendPages[5];
var int m_iCurrentPage;
var R6WindowBitMap m_NextBg;
var R6WindowBitMap m_PrevBg;
var int m_NavButtonSize;
var Region ButtonBg;
var bool m_bDisplayWindow;
var bool m_bInitialized;
var UWindowButton m_NextPageButton;
var UWindowButton m_PreviousPageButton;

// --- Functions ---
function Resized() {}
function Created() {}
//Should be before created.  Or add a function to that only once.
function BeforePaint(float Y, float X, Canvas C) {}
function NextPage() {}
function PreviousPage() {}
function ToggleLegend() {}
function CloseLegendWindow() {}

defaultproperties
{
}
