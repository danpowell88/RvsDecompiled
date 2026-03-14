//=============================================================================
// R6WindowTextureBrowser - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6WindowTextureBrowser.uc : Small widget allowing user to select a texture 
//                              from a texture collection
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/08/04 * Created by Alexandre Dionne
//=============================================================================
class R6WindowTextureBrowser extends UWindowDialogClientWindow;

var int m_iNbDisplayedElement;  // 1 for now
var bool m_bSBInitialized;
var bool m_bBitMapInitialized;
var bool bShowLog;
var R6WindowBitMap m_CurrentSelection;
var UWindowHScrollbar m_HSB;
var R6WindowTextLabelExt m_pTextLabel;
var array<Texture> m_TextureCollection;
var array<Region> m_TextureRegionCollection;

//================================================================
//	CreateBitmap : Create the Bitmap where you want it make sure you leave enough room for the scroll bar
//================================================================
function CreateBitmap(int X, int Y, int W, int H)
{
	// End:0x3E
	if(__NFUN_114__(m_CurrentSelection, none))
	{
		m_CurrentSelection = R6WindowBitMap(CreateControl(Class'R6Window.R6WindowBitMap', float(X), float(Y), float(W), float(H), self));
	}
	m_bBitMapInitialized = true;
	return;
}

function SetBitmapProperties(bool _bStretch, bool _bCenter, int _iDrawStyle, bool _bUseColor, optional Color _TextureColor)
{
	// End:0x75
	if(__NFUN_119__(m_CurrentSelection, none))
	{
		m_CurrentSelection.m_bUseColor = _bUseColor;
		m_CurrentSelection.m_TextureColor = _TextureColor;
		m_CurrentSelection.bStretch = _bStretch;
		m_CurrentSelection.bCenter = _bCenter;
		m_CurrentSelection.m_iDrawStyle = _iDrawStyle;
	}
	return;
}

function SetBitmapBorder(bool _bDrawBorder, Color _borderColor)
{
	// End:0x35
	if(__NFUN_119__(m_CurrentSelection, none))
	{
		m_CurrentSelection.m_bDrawBorder = _bDrawBorder;
		m_CurrentSelection.m_BorderColor = _borderColor;
	}
	return;
}

//================================================================
//	Created: Creates the Horizontal scroll bar
//================================================================
function CreateSB(int X, int Y, int W, int H)
{
	m_HSB = UWindowHScrollbar(CreateControl(Class'UWindow.UWindowHScrollbar', float(X), float(Y), float(W), LookAndFeel.Size_ScrollbarWidth, self));
	m_HSB.SetRange(0.0000000, float(m_TextureCollection.Length), float(m_iNbDisplayedElement));
	m_bSBInitialized = true;
	return;
}

function CreateTextLabel(int X, int Y, int W, int H, string _szText, string _szToolTip)
{
	m_pTextLabel = R6WindowTextLabelExt(CreateWindow(Class'R6Window.R6WindowTextLabelExt', float(X), float(Y), float(W), float(H), self));
	m_pTextLabel.bAlwaysBehind = true;
	m_pTextLabel.SetNoBorder();
	m_pTextLabel.m_Font = Root.Fonts[5];
	m_pTextLabel.m_vTextColor = Root.Colors.White;
	m_pTextLabel.AddTextLabel(_szText, 0.0000000, 0.0000000, 150.0000000, 0, false);
	ToolTipString = _szToolTip;
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	// End:0xBF
	if(__NFUN_154__(int(E), 2))
	{
		switch(C)
		{
			// End:0x26
			case m_HSB.LeftButton:
			// End:0xBC
			case m_HSB.RightButton:
				// End:0x63
				if(bShowLog)
				{
					__NFUN_231__(__NFUN_168__("Yo1 m_HSB.Pos", string(m_HSB.pos)));
				}
				// End:0xB9
				if(__NFUN_151__(m_TextureCollection.Length, 0))
				{
					m_CurrentSelection.t = m_TextureCollection[int(m_HSB.pos)];
					m_CurrentSelection.R = m_TextureRegionCollection[int(m_HSB.pos)];
				}
				// End:0xBF
				break;
			// End:0xFFFF
			default:
				break;
		}
	}
	else
	{
		// End:0x206
		if(__NFUN_154__(int(E), 1))
		{
			switch(C)
			{
				// End:0x203
				case m_HSB:
					// End:0x107
					if(bShowLog)
					{
						__NFUN_231__(__NFUN_168__("Yo2 m_HSB.Pos", string(m_HSB.pos)));
					}
					// End:0x13C
					if(bShowLog)
					{
						__NFUN_231__(__NFUN_168__("Yo2 m_TextureCollection.length", string(m_TextureCollection.Length)));
					}
					// End:0x200
					if(__NFUN_151__(m_TextureCollection.Length, 0))
					{
						m_CurrentSelection.t = m_TextureCollection[int(m_HSB.pos)];
						m_CurrentSelection.R = m_TextureRegionCollection[int(m_HSB.pos)];
						// End:0x1C6
						if(bShowLog)
						{
							__NFUN_231__(__NFUN_168__("m_CurrentSelection.T ", string(m_CurrentSelection.t)));
						}
						// End:0x200
						if(bShowLog)
						{
							__NFUN_231__(__NFUN_168__("m_CurrentSelection.R.W", string(m_CurrentSelection.R.W)));
						}
					}
					// End:0x206
					break;
				// End:0xFFFF
				default:
					break;
			}
		}
		else
		{
			// End:0x2CE
			if(__NFUN_154__(int(E), 12))
			{
				switch(C)
				{
					// End:0x223
					case m_CurrentSelection:
					// End:0x2CB
					case m_HSB:
						// End:0x260
						if(__NFUN_119__(m_pTextLabel, none))
						{
							m_pTextLabel.ChangeColorLabel(Root.Colors.ButtonTextColor[2], 0);
						}
						// End:0x294
						if(__NFUN_119__(m_CurrentSelection, none))
						{
							m_CurrentSelection.m_BorderColor = Root.Colors.ButtonTextColor[2];
						}
						// End:0x2C8
						if(__NFUN_119__(m_HSB, none))
						{
							m_HSB.m_NormalColor = Root.Colors.ButtonTextColor[2];
						}
						// End:0x2CE
						break;
					// End:0xFFFF
					default:
						break;
				}
			}
			else
			{
				// End:0x38D
				if(__NFUN_154__(int(E), 9))
				{
					switch(C)
					{
						// End:0x2EB
						case m_CurrentSelection:
						// End:0x38A
						case m_HSB:
							// End:0x325
							if(__NFUN_119__(m_pTextLabel, none))
							{
								m_pTextLabel.ChangeColorLabel(Root.Colors.White, 0);
							}
							// End:0x356
							if(__NFUN_119__(m_CurrentSelection, none))
							{
								m_CurrentSelection.m_BorderColor = Root.Colors.White;
							}
							// End:0x387
							if(__NFUN_119__(m_HSB, none))
							{
								m_HSB.m_NormalColor = Root.Colors.White;
							}
							// End:0x38D
							break;
						// End:0xFFFF
						default:
							break;
					}
				}
				else
				{
					return;
				}
			}
		}
	}
}

//================================================================
//	
//================================================================
function int AddTexture(Texture _Texture, Region _Region)
{
	// End:0x2E
	if(bShowLog)
	{
		__NFUN_231__(__NFUN_168__("AddTexture inserting at", string(m_TextureCollection.Length)));
	}
	// End:0x177
	if(__NFUN_119__(_Texture, none))
	{
		m_TextureRegionCollection[m_TextureCollection.Length] = _Region;
		m_TextureCollection[m_TextureCollection.Length] = _Texture;
		// End:0x8B
		if(__NFUN_119__(m_HSB, none))
		{
			m_HSB.SetRange(0.0000000, float(m_TextureCollection.Length), float(m_iNbDisplayedElement));
		}
		// End:0xDD
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_168__("m_TextureCollection[m_TextureCollection.length -1]", string(m_TextureCollection[__NFUN_147__(m_TextureCollection.Length, 1)])));
		}
		// End:0x13C
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_168__("m_TextureRegionCollection[m_TextureCollection.length -1].W", string(m_TextureRegionCollection[__NFUN_147__(m_TextureCollection.Length, 1)].W)));
		}
		// End:0x16D
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_168__("m_TextureCollection.length", string(m_TextureCollection.Length)));
		}
		return __NFUN_147__(m_TextureCollection.Length, 1);
	}
	return -1;
	return;
}

//================================================================
//	
//================================================================
function RemoveTexture(Texture _Texture)
{
	// End:0x34
	if(__NFUN_119__(m_HSB, none))
	{
		m_HSB.SetRange(0.0000000, float(__NFUN_250__(0, __NFUN_147__(m_TextureCollection.Length, 1))), float(m_iNbDisplayedElement));
	}
	return;
	return;
}

//================================================================
//	
//================================================================
function RemoveTextureFromIndex(int _index)
{
	m_TextureCollection.Remove(_index, _index);
	m_TextureRegionCollection.Remove(_index, _index);
	// End:0x54
	if(__NFUN_119__(m_HSB, none))
	{
		m_HSB.SetRange(0.0000000, float(__NFUN_250__(0, __NFUN_147__(m_TextureCollection.Length, 1))), float(m_iNbDisplayedElement));
	}
	return;
}

//================================================================
//	
//================================================================
function int GetTextureIndex(Texture _Texture)
{
	return -1;
	return;
}

//================================================================
//	Returns current selected texture index
//================================================================
function int GetCurrentTextureIndex()
{
	// End:0x30
	if(__NFUN_151__(m_TextureCollection.Length, 0))
	{
		// End:0x2B
		if(__NFUN_119__(m_HSB, none))
		{
			return int(m_HSB.pos);			
		}
		else
		{
			return 0;
		}		
	}
	else
	{
		return -1;
	}
	return;
}

//================================================================
//	Sets current selectd texture if possible
//================================================================
function SetCurrentTextureFromIndex(int _index)
{
	// End:0x26
	if(__NFUN_151__(m_TextureCollection.Length, _index))
	{
		m_HSB.Show(float(_index));
	}
	return;
}

//================================================================
//	
//================================================================
function Texture GetTextureAtIndex(int _index)
{
	return none;
	return;
}

//================================================================
//	
//================================================================
function GetCurrentSelectedTexture()
{
	return;
	return;
}

//================================================================
//	
//================================================================
function Clear()
{
	m_TextureCollection.Remove(0, m_TextureCollection.Length);
	m_TextureRegionCollection.Remove(0, m_TextureCollection.Length);
	m_HSB.SetRange(0.0000000, 0.0000000, float(m_iNbDisplayedElement));
	return;
}

defaultproperties
{
	m_iNbDisplayedElement=1
}
