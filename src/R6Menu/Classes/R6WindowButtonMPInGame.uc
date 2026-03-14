//=============================================================================
// R6WindowButtonMPInGame - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6WindowButtonMPInGame extends R6WindowButton;

enum eButInGameActionType
{
	Button_AlphaTeam,               // 0
	Button_BravoTeam,               // 1
	Button_AutoTeam,                // 2
	Button_Spectator,               // 3
	Button_Play                     // 4
};

// NEW IN 1.60
var R6WindowButtonMPInGame.eButInGameActionType m_eButInGame_Action;
var Texture m_TOverButton;
var Region m_ROverButtonFade;
var Region m_ROverButton;

simulated function Click(float X, float Y)
{
	local R6MenuInGameMultiPlayerRootWindow r6Root;

	super(UWindowButton).Click(X, Y);
	r6Root = R6MenuInGameMultiPlayerRootWindow(Root);
	// End:0x2B
	if(bDisabled)
	{
		return;
	}
	switch(m_eButInGame_Action)
	{
		// End:0x37
		case 4:
		// End:0x6B
		case 0:
			r6Root.m_R6GameMenuCom.PlayerSelection(r6Root.m_R6GameMenuCom.2);
			// End:0x10D
			break;
		// End:0x9F
		case 1:
			r6Root.m_R6GameMenuCom.PlayerSelection(r6Root.m_R6GameMenuCom.3);
			// End:0x10D
			break;
		// End:0xD3
		case 2:
			r6Root.m_R6GameMenuCom.PlayerSelection(r6Root.m_R6GameMenuCom.1);
			// End:0x10D
			break;
		// End:0x107
		case 3:
			r6Root.m_R6GameMenuCom.PlayerSelection(r6Root.m_R6GameMenuCom.4);
			// End:0x10D
			break;
		// End:0xFFFF
		default:
			// End:0x10D
			break;
			break;
	}
	return;
}

defaultproperties
{
	m_TOverButton=Texture'R6MenuTextures.Gui_BoxScroll'
	m_ROverButtonFade=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=63522,ZoneNumber=0)
	m_ROverButton=(Zone=Class'R6Menu.R6MenuOperativeSkillsLabel',iLeaf=64802,ZoneNumber=0)
	bStretched=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var eButInGameActionType
