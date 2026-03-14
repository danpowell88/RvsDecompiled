//=============================================================================
// R6ColorPicker - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// R6ColorPicker - Color picker for the writable map
//=============================================================================
class R6ColorPicker extends UWindowDialogControl;

const NUM_COLOR = 5;
const PICKWIDTH = 40;
const PICKHEIGHT = 20;

var int m_iSelectedColorIndex;
// NEW IN 1.60
var Color m_aColorChoice[5];

function Paint(Canvas C, float X, float Y)
{
	local int i;

	i = 0;
	J0x07:

	// End:0x93 [Loop If]
	if(__NFUN_150__(i, 5))
	{
		C.__NFUN_2623__(0.0000000, float(__NFUN_144__(i, 20)));
		C.__NFUN_2626__(m_aColorChoice[i].R, m_aColorChoice[i].G, m_aColorChoice[i].B);
		C.DrawRect(Texture'Color.Color.White', 40.0000000, 20.0000000);
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x07;
	}
	C.__NFUN_2626__(m_aColorChoice[m_iSelectedColorIndex].R, m_aColorChoice[m_iSelectedColorIndex].G, m_aColorChoice[m_iSelectedColorIndex].B);
	C.__NFUN_2623__(1.0000000, float(__NFUN_146__(__NFUN_144__(m_iSelectedColorIndex, 20), 1)));
	C.DrawRect(Texture'Color.Color.Black', __NFUN_175__(40.0000000, float(2)), __NFUN_175__(20.0000000, float(2)));
	C.__NFUN_2623__(4.0000000, float(__NFUN_146__(__NFUN_144__(m_iSelectedColorIndex, 20), 4)));
	C.DrawRect(Texture'Color.Color.White', __NFUN_175__(40.0000000, float(8)), __NFUN_175__(20.0000000, float(8)));
	return;
}

function Color GetSelectedColor()
{
	return m_aColorChoice[m_iSelectedColorIndex];
	return;
}

function LMouseDown(float X, float Y)
{
	local int iSelectedColorIndex;

	super(UWindowWindow).LMouseDown(X, Y);
	iSelectedColorIndex = int(__NFUN_172__(Y, float(20)));
	// End:0x47
	if(__NFUN_130__(__NFUN_153__(iSelectedColorIndex, 0), __NFUN_150__(iSelectedColorIndex, 5)))
	{
		m_iSelectedColorIndex = iSelectedColorIndex;
	}
	return;
}

defaultproperties
{
	m_aColorChoice[0]=(R=0,G=255,B=0,A=255)
	m_aColorChoice[1]=(R=255,G=255,B=255,A=255)
	m_aColorChoice[2]=(R=255,G=0,B=0,A=255)
	m_aColorChoice[3]=(R=0,G=0,B=255,A=255)
	m_aColorChoice[4]=(R=255,G=255,B=0,A=255)
	bIgnoreLDoubleClick=true
	bIgnoreMDoubleClick=true
	bIgnoreRDoubleClick=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var m_aColorChoiceNUM_COLOR
