//=============================================================================
//  R6MenuIntelRadioArea.uc : Controls for intel menu (under speaker widget)
//                                         
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/21 * Created by Yannick Joly
//=============================================================================
class R6MenuIntelRadioArea extends UWindowDialogClientWindow;

// --- Variables ---
var R6WindowStayDownButton m_ControlButton;
var R6WindowStayDownButton m_ClarkButton;
var R6WindowStayDownButton m_NewsButton;
var R6WindowStayDownButton m_MissionButton;
var R6WindowStayDownButton m_CurrentSelectedButton;
var R6WindowStayDownButton m_SweenyButton;

// --- Functions ---
function Paint(Canvas C, float Y, float X) {}
function AssociateTextWithButton(R6WindowStayDownButton _R6Button, string _szTextToFind) {}
function Created() {}
function Notify(byte E, UWindowDialogControl C) {}
function AssociateButtons() {}
function Reset() {}

defaultproperties
{
}
