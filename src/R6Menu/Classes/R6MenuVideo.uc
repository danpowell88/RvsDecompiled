//=============================================================================
// R6MenuVideo - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6MenuVideo.uc : Draw a simple window (opportunity to create a empty box) and play a video inside it
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/26 * Created by Yannick Joly
//=============================================================================
class R6MenuVideo extends UWindowWindow;

var int m_iCentered;  // the video is center at 1, 0 none
var int m_iXStartPos;  // the start pos in x
var int m_iYStartPos;  // the start pos in y
var bool m_bAlreadyStart;  // the video is is already playing
var bool m_bPlayVideo;  // the video is playing
var bool bShowLog;
var string m_szVideoFilename;  // the name of the video to play

function PlayVideo(int _iXStartPos, int _iYStartPos, string _szVideoFileName)
{
	m_szVideoFilename = _szVideoFileName;
	// End:0x35
	if((m_szVideoFilename != ""))
	{
		m_bPlayVideo = true;
		m_iXStartPos = _iXStartPos;
		m_iYStartPos = _iYStartPos;
	}
	// End:0x81
	if(bShowLog)
	{
		Log("PlayVideo");
		Log(((("m_szVideoFilename" @ m_szVideoFilename) @ "m_bPlayVideo") @ string(m_bPlayVideo)));
	}
	return;
}

function StopVideo()
{
	local Canvas C;

	// End:0x30
	if(bShowLog)
	{
		Log("StopVideo");
		Log(("m_bPlayVideo" @ string(m_bPlayVideo)));
	}
	// End:0x67
	if(m_bPlayVideo)
	{
		C = Class'Engine.Actor'.static.GetCanvas();
		m_bPlayVideo = false;
		m_bAlreadyStart = false;
		C.VideoStop();
	}
	// End:0xA7
	if(bShowLog)
	{
		Log(("m_bPlayVideo" @ string(m_bPlayVideo)));
		Log(("m_bAlreadyStart" @ string(m_bAlreadyStart)));
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	// End:0x87
	if(m_bPlayVideo)
	{
		// End:0x87
		if((!m_bAlreadyStart))
		{
			// End:0x52
			if(bShowLog)
			{
				Log("Paint m_bPlayVideo = true m_bAlreadyStart = false");
			}
			C.VideoOpen(m_szVideoFilename, 0);
			m_bAlreadyStart = true;
			C.VideoPlay(m_iXStartPos, m_iYStartPos, m_iCentered);
		}
	}
	DrawSimpleBorder(C);
	return;
}

