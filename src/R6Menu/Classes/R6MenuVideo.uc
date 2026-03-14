//=============================================================================
//  R6MenuVideo.uc : Draw a simple window (opportunity to create a empty box) and play a video inside it
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/26 * Created by Yannick Joly
//=============================================================================
class R6MenuVideo extends UWindowWindow;

// --- Variables ---
// var ? bShowlog; // REMOVED IN 1.60
// the video is playing
var bool m_bPlayVideo;
// the name of the video to play
var string m_szVideoFilename;
// the video is is already playing
var bool m_bAlreadyStart;
var bool bShowLog;
// ^ NEW IN 1.60
// the start pos in y
var int m_iYStartPos;
// the start pos in x
var int m_iXStartPos;
// the video is center at 1, 0 none
var int m_iCentered;

// --- Functions ---
function StopVideo() {}
function Paint(Canvas C, float X, float Y) {}
function PlayVideo(int _iXStartPos, int _iYStartPos, string _szVideoFileName) {}

defaultproperties
{
}
