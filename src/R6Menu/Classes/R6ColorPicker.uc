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
	if((i < 5))
	{
		C.SetPos(0.0000000, float((i * 20)));
		C.SetDrawColor(m_aColorChoice[i].R, m_aColorChoice[i].G, m_aColorChoice[i].B);
		C.DrawRect(Texture'Color.Color.White', 40.0000000, 20.0000000);
		(i++);
		// [Loop Continue]
		goto J0x07;
	}
	C.SetDrawColor(m_aColorChoice[m_iSelectedColorIndex].R, m_aColorChoice[m_iSelectedColorIndex].G, m_aColorChoice[m_iSelectedColorIndex].B);
	C.SetPos(1.0000000, float(((m_iSelectedColorIndex * 20) + 1)));
	C.DrawRect(Texture'Color.Color.Black', (40.0000000 - float(2)), (20.0000000 - float(2)));
	C.SetPos(4.0000000, float(((m_iSelectedColorIndex * 20) + 4)));
	C.DrawRect(Texture'Color.Color.White', (40.0000000 - float(8)), (20.0000000 - float(8)));
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
	iSelectedColorIndex = int((Y / float(20)));
	// End:0x47
	if(((iSelectedColorIndex >= 0) && (iSelectedColorIndex < 5)))
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
