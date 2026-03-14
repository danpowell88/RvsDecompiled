//=============================================================================
// UWindowWrappedTextArea - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowWrappedTextArea extends UWindowTextAreaControl;

function BeforePaint(Canvas C, float X, float Y)
{
	// End:0x1C
	if(m_bWrapClipText)
	{
		m_bWrapClipText = false;
		NewAddText(C);
	}
	return;
}

function Paint(Canvas C, float X, float Y)
{
	local float XL, YL;
	local int i, j, AddLine;
	local bool bUseAreaFont;

	// End:0x0D
	if(__NFUN_154__(Lines, 0))
	{
		return;
	}
	bUseAreaFont = false;
	// End:0x37
	if(__NFUN_119__(AbsoluteFont, none))
	{
		C.Font = AbsoluteFont;		
	}
	else
	{
		// End:0x65
		if(__NFUN_119__(TextFontArea[0], none))
		{
			bUseAreaFont = true;
			C.Font = TextFontArea[0];			
		}
		else
		{
			C.Font = AbsoluteFont;
		}
	}
	TextSize(C, "TEST", XL, YL);
	AddLine = int(__NFUN_172__(m_fYOffSet, YL));
	__NFUN_161__(AddLine, 1);
	__NFUN_161__(AddLine, Lines);
	VisibleRows = int(__NFUN_172__(WinHeight, YL));
	i = 0;
	// End:0x11E
	if(bScrollable)
	{
		VertSB.SetRange(0.0000000, float(AddLine), float(VisibleRows), 0.0000000);
		i = int(VertSB.pos);
	}
	j = 0;
	J0x125:

	// End:0x208 [Loop If]
	if(__NFUN_130__(__NFUN_150__(j, VisibleRows), __NFUN_150__(__NFUN_146__(i, j), Lines)))
	{
		C.__NFUN_2626__(TextColorArea[__NFUN_146__(i, j)].R, TextColorArea[__NFUN_146__(i, j)].G, TextColorArea[__NFUN_146__(i, j)].B);
		// End:0x1C7
		if(bUseAreaFont)
		{
			C.Font = TextFontArea[__NFUN_146__(i, j)];
		}
		ClipText(C, m_fXOffSet, __NFUN_174__(m_fYOffSet, __NFUN_171__(YL, float(j))), TextArea[__NFUN_146__(i, j)]);
		__NFUN_165__(j);
		// [Loop Continue]
		goto J0x125;
	}
	// End:0x265
	if(__NFUN_151__(__NFUN_146__(i, j), Lines))
	{
		j = 0;
		J0x225:

		// End:0x265 [Loop If]
		if(__NFUN_150__(j, AddLine))
		{
			ClipText(C, m_fXOffSet, __NFUN_174__(m_fYOffSet, __NFUN_171__(YL, float(j))), "");
			__NFUN_165__(j);
			// [Loop Continue]
			goto J0x225;
		}
	}
	return;
}

// INTERN FONCTION FOR THIS CLASS ONLY, see before paint comment
function NewAddText(Canvas C)
{
	local int i, iTempLines;
	local Font TempTextFontArea[80];
	local Color TempTextColorArea[80];
	local string TempTextArea[80];

	// End:0x0D
	if(__NFUN_154__(Lines, 0))
	{
		return;
	}
	i = 0;
	J0x14:

	// End:0x72 [Loop If]
	if(__NFUN_150__(i, Lines))
	{
		TempTextFontArea[i] = TextFontArea[i];
		TempTextColorArea[i] = TextColorArea[i];
		TempTextArea[i] = TextArea[i];
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x14;
	}
	iTempLines = Lines;
	Clear(true);
	i = 0;
	J0x8B:

	// End:0xDA [Loop If]
	if(__NFUN_150__(i, iTempLines))
	{
		AddTextWithCanvas(C, m_fXOffSet, m_fYOffSet, TempTextArea[i], TempTextFontArea[i], TempTextColorArea[i]);
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x8B;
	}
	return;
}

