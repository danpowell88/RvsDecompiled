//=============================================================================
// R6WindowTextListBoxExt - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// No matching SDK 1.56 source found
//=============================================================================
class R6WindowTextListBoxExt extends R6WindowTextListBox;

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	local R6WindowListBoxItemExt pIt;
	local string szToDisplay;
	local float tW, tH, fYPos, fYAdjust;
	local int i, j, k;

	// End:0x3A
	if(Item.__NFUN_303__('R6WindowListBoxItem'))
	{
		super.DrawItem(C, Item, X, Y, W, H);
		return;
	}
	pIt = R6WindowListBoxItemExt(Item);
	// End:0x6E
	if(__NFUN_130__(__NFUN_119__(pIt, none), __NFUN_154__(pIt.m_AItemDesc.Length, 0)))
	{
		return;
	}
	// End:0x124
	if(pIt.bSelected)
	{
		// End:0x124
		if(__NFUN_119__(m_BGSelTexture, none))
		{
			C.Style = m_BGRenderStyle;
			C.__NFUN_2626__(m_BGSelColor.R, m_BGSelColor.G, m_BGSelColor.B);
			DrawStretchedTextureSegment(C, X, Y, W, __NFUN_175__(H, m_fSpaceBetItem), float(m_BGSelRegion.X), float(m_BGSelRegion.Y), float(m_BGSelRegion.W), float(m_BGSelRegion.H), m_BGSelTexture);
		}
	}
	i = 0;
	J0x12B:

	// End:0x469 [Loop If]
	if(__NFUN_150__(i, pIt.m_AItemDesc.Length))
	{
		pIt.SetItemDescriptionIndex(i);
		// End:0x174
		if(__NFUN_129__(pIt.m_DescTemp.bDisplay))
		{
			// [Explicit Continue]
			goto J0x45F;
		}
		C.Font = pIt.m_DescTemp.TextFont;
		C.SpaceX = m_fFontSpacing;
		// End:0x1FB
		if(m_bForceCaps)
		{
			szToDisplay = TextSize(C, __NFUN_235__(pIt.m_DescTemp.szText), tW, tH, int(pIt.m_DescTemp.fWidth));			
		}
		else
		{
			szToDisplay = TextSize(C, pIt.m_DescTemp.szText, tW, tH, int(pIt.m_DescTemp.fWidth));
		}
		// End:0x27D
		if(pIt.m_bDisabled)
		{
			C.__NFUN_2626__(m_DisableTextColor.R, m_DisableTextColor.G, m_DisableTextColor.B);			
		}
		else
		{
			C.__NFUN_2626__(TextColor.R, TextColor.G, TextColor.B);
		}
		fYPos = Y;
		// End:0x346
		if(__NFUN_151__(pIt.m_DescTemp.iLineNumber, 0))
		{
			k = pIt.m_DescTemp.iLineNumber;
			j = 0;
			J0x2EB:

			// End:0x332 [Loop If]
			if(__NFUN_150__(j, k))
			{
				pIt.SetItemDescriptionIndex(j);
				__NFUN_184__(fYPos, pIt.m_DescTemp.fHeigth);
				__NFUN_165__(j);
				// [Loop Continue]
				goto J0x2EB;
			}
			pIt.SetItemDescriptionIndex(i);
		}
		fYAdjust = __NFUN_172__(__NFUN_175__(pIt.m_DescTemp.fHeigth, tH), float(2));
		__NFUN_184__(fYPos, float(int(__NFUN_174__(fYAdjust, 0.5000000))));
		__NFUN_184__(fYPos, pIt.m_DescTemp.fYPos);
		switch(pIt.m_DescTemp.eAlignment)
		{
			// End:0x3E5
			case 1:
				C.__NFUN_2623__(__NFUN_175__(pIt.m_DescTemp.fXPos, tW), fYPos);
				// End:0x44E
				break;
			// End:0x41F
			case 2:
				C.__NFUN_2623__(__NFUN_175__(pIt.m_DescTemp.fXPos, __NFUN_172__(tW, 2.0000000)), fYPos);
				// End:0x44E
				break;
			// End:0x424
			case 0:
			// End:0xFFFF
			default:
				C.__NFUN_2623__(pIt.m_DescTemp.fXPos, fYPos);
				// End:0x44E
				break;
				break;
		}
		C.__NFUN_465__(szToDisplay);
		J0x45F:

		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x12B;
	}
	return;
}

function float GetSizeOfAnItem(UWindowList _pItem)
{
	local float fTotalHeight;
	local int i, iLineNumber;

	// End:0x20
	if(_pItem.__NFUN_303__('R6WindowListBoxItem'))
	{
		return super(R6WindowListBox).GetSizeOfAnItem(_pItem);
	}
	iLineNumber = 0;
	fTotalHeight = m_fSpaceBetItem;
	i = 0;
	J0x39:

	// End:0xB5 [Loop If]
	if(__NFUN_150__(i, R6WindowListBoxItemExt(_pItem).m_AItemDesc.Length))
	{
		// End:0xAB
		if(__NFUN_154__(R6WindowListBoxItemExt(_pItem).m_AItemDesc[i].iLineNumber, iLineNumber))
		{
			__NFUN_165__(iLineNumber);
			__NFUN_184__(fTotalHeight, R6WindowListBoxItemExt(_pItem).m_AItemDesc[i].fHeigth);
		}
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x39;
	}
	return fTotalHeight;
	return;
}

defaultproperties
{
	ListClass=Class'R6Window.R6WindowListBoxItemExt'
}