//=============================================================================
// R6MenuUbiComModsWidget - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// No matching SDK 1.56 source found
//=============================================================================
class R6MenuUbiComModsWidget extends R6MenuWidget;

const C_fXSTARTPOS = 189;
const C_fYSTARTPOS = 92;
const C_fWINDOWWIDTH = 422;
const C_fWINDOWHEIGHT = 321;
const C_fHEIGHT_OF_LABELW = 30;

var R6WindowTextLabelCurved m_pOptionsTextLabel;
var R6WindowTextLabel m_LMenuTitle;
var R6WindowSimpleFramedWindowExt m_pOptionsBorder;
var R6MenuOptionsMODSExt m_pListOfMods;
var R6WindowButton m_ButtonQuit;
var R6WindowButton m_ButtonReturnUbiCom;

function Created()
{
	m_ButtonQuit = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', 10.0000000, 425.0000000, 300.0000000, 25.0000000, self));
	m_ButtonQuit.ToolTipString = "";
	m_ButtonQuit.Text = Localize("UbiCom", "ButtonQuit", "R6Menu");
	m_ButtonQuit.Align = 0;
	m_ButtonQuit.m_fFontSpacing = 0.0000000;
	m_ButtonQuit.m_buttonFont = Root.Fonts[15];
	m_ButtonQuit.m_iButtonID = 1;
	m_ButtonQuit.ResizeToText();
	m_ButtonReturnUbiCom = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', 10.0000000, 447.0000000, 300.0000000, 25.0000000, self));
	m_ButtonReturnUbiCom.ToolTipString = "";
	m_ButtonReturnUbiCom.Text = Localize("UbiCom", "ButtonReturn", "R6Menu");
	m_ButtonReturnUbiCom.Align = 0;
	m_ButtonReturnUbiCom.m_fFontSpacing = 0.0000000;
	m_ButtonReturnUbiCom.m_buttonFont = Root.Fonts[15];
	m_ButtonReturnUbiCom.m_iButtonID = 2;
	m_ButtonReturnUbiCom.ResizeToText();
	m_LMenuTitle = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 0.0000000, 18.0000000, __NFUN_175__(WinWidth, float(8)), 25.0000000, self));
	m_LMenuTitle.Text = "CUSTOM MODS";
	m_LMenuTitle.Align = 1;
	m_LMenuTitle.m_Font = Root.Fonts[4];
	m_LMenuTitle.m_BGTexture = none;
	m_LMenuTitle.m_bDrawBorders = false;
	m_pOptionsTextLabel = R6WindowTextLabelCurved(CreateWindow(Class'R6Window.R6WindowTextLabelCurved', 189.0000000, __NFUN_174__(__NFUN_175__(92.0000000, float(30)), float(1)), 422.0000000, 30.0000000, self));
	m_pOptionsTextLabel.bAlwaysBehind = true;
	m_pOptionsTextLabel.Align = 2;
	m_pOptionsTextLabel.m_Font = Root.Fonts[5];
	m_pOptionsTextLabel.SetNewText(Localize("Options", "ButtonCustomGame", "R6Menu"), true);
	m_pOptionsBorder = R6WindowSimpleFramedWindowExt(CreateWindow(Class'R6Window.R6WindowSimpleFramedWindowExt', 189.0000000, 92.0000000, 422.0000000, 321.0000000, self));
	m_pOptionsBorder.bAlwaysBehind = true;
	m_pOptionsBorder.ActiveBorder(0, false);
	m_pOptionsBorder.SetBorderParam(1, 7.0000000, 0.0000000, 1.0000000, Root.Colors.White);
	m_pOptionsBorder.SetBorderParam(2, 1.0000000, 1.0000000, 1.0000000, Root.Colors.White);
	m_pOptionsBorder.SetBorderParam(3, 1.0000000, 1.0000000, 1.0000000, Root.Colors.White);
	m_pOptionsBorder.m_eCornerType = 2;
	m_pOptionsBorder.SetCornerColor(2, Root.Colors.White);
	m_pOptionsBorder.ActiveBackGround(true, Root.Colors.Black);
	m_pListOfMods = R6MenuOptionsMODSExt(CreateWindow(Class'R6Menu.R6MenuOptionsMODSExt', __NFUN_174__(189.0000000, float(1)), 92.0000000, __NFUN_175__(422.0000000, float(2)), 321.0000000, self));
	m_pListOfMods.InitPageOptions();
	return;
}

function Paint(Canvas C, float X, float Y)
{
	Root.PaintBackground(C, self);
	return;
}

function ShowWindow()
{
	Root.SetLoadRandomBackgroundImage("ModSelector");
	super(UWindowWindow).ShowWindow();
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	// End:0x65
	if(C.__NFUN_303__('R6WindowButton'))
	{
		// End:0x65
		if(__NFUN_154__(int(E), 2))
		{
			// End:0x43
			if(__NFUN_114__(C, m_ButtonQuit))
			{
				Root.DoQuitGame();				
			}
			else
			{
				// End:0x65
				if(__NFUN_114__(C, m_ButtonReturnUbiCom))
				{
					Class'Engine.Actor'.static.__NFUN_1551__().__NFUN_1290__();
				}
			}
		}
	}
	return;
}
