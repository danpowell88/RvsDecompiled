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
	if(Item.IsA('R6WindowListBoxItem'))
	{
		super.DrawItem(C, Item, X, Y, W, H);
		return;
	}
	pIt = R6WindowListBoxItemExt(Item);
	// End:0x6E
	if(((pIt != none) && (pIt.m_AItemDesc.Length == 0)))
	{
		return;
	}
	// End:0x124
	if(pIt.bSelected)
	{
		// End:0x124
		if((m_BGSelTexture != none))
		{
			C.Style = m_BGRenderStyle;
			C.SetDrawColor(m_BGSelColor.R, m_BGSelColor.G, m_BGSelColor.B);
			DrawStretchedTextureSegment(C, X, Y, W, (H - m_fSpaceBetItem), float(m_BGSelRegion.X), float(m_BGSelRegion.Y), float(m_BGSelRegion.W), float(m_BGSelRegion.H), m_BGSelTexture);
		}
	}
	i = 0;
	J0x12B:

	// End:0x469 [Loop If]
	if((i < pIt.m_AItemDesc.Length))
	{
		pIt.SetItemDescriptionIndex(i);
		// End:0x174
		if((!pIt.m_DescTemp.bDisplay))
		{
			// [Explicit Continue]
			goto J0x45F;
		}
		C.Font = pIt.m_DescTemp.TextFont;
		C.SpaceX = m_fFontSpacing;
		// End:0x1FB
		if(m_bForceCaps)
		{
			szToDisplay = TextSize(C, Caps(pIt.m_DescTemp.szText), tW, tH, int(pIt.m_DescTemp.fWidth));			
		}
		else
		{
			szToDisplay = TextSize(C, pIt.m_DescTemp.szText, tW, tH, int(pIt.m_DescTemp.fWidth));
		}
		// End:0x27D
		if(pIt.m_bDisabled)
		{
			C.SetDrawColor(m_DisableTextColor.R, m_DisableTextColor.G, m_DisableTextColor.B);			
		}
		else
		{
			C.SetDrawColor(TextColor.R, TextColor.G, TextColor.B);
		}
		fYPos = Y;
		// End:0x346
		if((pIt.m_DescTemp.iLineNumber > 0))
		{
			k = pIt.m_DescTemp.iLineNumber;
			j = 0;
			J0x2EB:

			// End:0x332 [Loop If]
			if((j < k))
			{
				pIt.SetItemDescriptionIndex(j);
				(fYPos += pIt.m_DescTemp.fHeigth);
				(j++);
				// [Loop Continue]
				goto J0x2EB;
			}
			pIt.SetItemDescriptionIndex(i);
		}
		fYAdjust = ((pIt.m_DescTemp.fHeigth - tH) / float(2));
		(fYPos += float(int((fYAdjust + 0.5000000))));
		(fYPos += pIt.m_DescTemp.fYPos);
		switch(pIt.m_DescTemp.eAlignment)
		{
			// End:0x3E5
			case 1:
				C.SetPos((pIt.m_DescTemp.fXPos - tW), fYPos);
				// End:0x44E
				break;
			// End:0x41F
			case 2:
				C.SetPos((pIt.m_DescTemp.fXPos - (tW / 2.0000000)), fYPos);
				// End:0x44E
				break;
			// End:0x424
			case 0:
			// End:0xFFFF
			default:
				C.SetPos(pIt.m_DescTemp.fXPos, fYPos);
				// End:0x44E
				break;
				break;
		}
		C.DrawText(szToDisplay);
		J0x45F:

		(i++);
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
	if(_pItem.IsA('R6WindowListBoxItem'))
	{
		return super(R6WindowListBox).GetSizeOfAnItem(_pItem);
	}
	iLineNumber = 0;
	fTotalHeight = m_fSpaceBetItem;
	i = 0;
	J0x39:

	// End:0xB5 [Loop If]
	if((i < R6WindowListBoxItemExt(_pItem).m_AItemDesc.Length))
	{
		// End:0xAB
		if((R6WindowListBoxItemExt(_pItem).m_AItemDesc[i].iLineNumber == iLineNumber))
		{
			(iLineNumber++);
			(fTotalHeight += R6WindowListBoxItemExt(_pItem).m_AItemDesc[i].fHeigth);
		}
		(i++);
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