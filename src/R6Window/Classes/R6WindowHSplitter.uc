//=============================================================================
//  R6WindowHSplitter.uc : Horizontal divider that partitions a window into top and bottom regions.
//  Supports three split types: full-top, top-half of a split, and bottom-half of a split.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================
class R6WindowHSplitter extends UWindowLabelControl;

// --- Enums ---
enum ESplitterType
{
    ST_TopWin,
    ST_SplitterTop,
    ST_SplitterBottom
};

// --- Variables ---
var ESplitterType m_eSplitterType;

// --- Functions ---
function Paint(Canvas C, float X, float Y) {}
function BeforePaint(Canvas C, float Y, float X) {}

defaultproperties
{
}
