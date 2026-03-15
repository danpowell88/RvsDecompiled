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
	if((Lines == 0))
	{
		return;
	}
	bUseAreaFont = false;
	// End:0x37
	if((AbsoluteFont != none))
	{
		C.Font = AbsoluteFont;		
	}
	else
	{
		// End:0x65
		if((TextFontArea[0] != none))
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
	AddLine = int((m_fYOffSet / YL));
	(AddLine += 1);
	(AddLine += Lines);
	VisibleRows = int((WinHeight / YL));
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
	if(((j < VisibleRows) && ((i + j) < Lines)))
	{
		C.SetDrawColor(TextColorArea[(i + j)].R, TextColorArea[(i + j)].G, TextColorArea[(i + j)].B);
		// End:0x1C7
		if(bUseAreaFont)
		{
			C.Font = TextFontArea[(i + j)];
		}
		ClipText(C, m_fXOffSet, (m_fYOffSet + (YL * float(j))), TextArea[(i + j)]);
		(j++);
		// [Loop Continue]
		goto J0x125;
	}
	// End:0x265
	if(((i + j) > Lines))
	{
		j = 0;
		J0x225:

		// End:0x265 [Loop If]
		if((j < AddLine))
		{
			ClipText(C, m_fXOffSet, (m_fYOffSet + (YL * float(j))), "");
			(j++);
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
	if((Lines == 0))
	{
		return;
	}
	i = 0;
	J0x14:

	// End:0x72 [Loop If]
	if((i < Lines))
	{
		TempTextFontArea[i] = TextFontArea[i];
		TempTextColorArea[i] = TextColorArea[i];
		TempTextArea[i] = TextArea[i];
		(i++);
		// [Loop Continue]
		goto J0x14;
	}
	iTempLines = Lines;
	Clear(true);
	i = 0;
	J0x8B:

	// End:0xDA [Loop If]
	if((i < iTempLines))
	{
		AddTextWithCanvas(C, m_fXOffSet, m_fYOffSet, TempTextArea[i], TempTextFontArea[i], TempTextColorArea[i]);
		(i++);
		// [Loop Continue]
		goto J0x8B;
	}
	return;
}

