//=============================================================================
// UWindowConsoleClientWindow - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowConsoleClientWindow extends UWindowDialogClientWindow;

var UWindowConsoleTextAreaControl TextArea;
var UWindowEditControl EditControl;

function Created()
{
	TextArea = UWindowConsoleTextAreaControl(CreateWindow(Class'UWindow.UWindowConsoleTextAreaControl', 0.0000000, 0.0000000, WinWidth, WinHeight));
	EditControl = UWindowEditControl(CreateControl(Class'UWindow.UWindowEditControl', 0.0000000, __NFUN_175__(WinHeight, float(16)), WinWidth, 16.0000000));
	EditControl.SetFont(0);
	EditControl.SetNumericOnly(false);
	EditControl.SetMaxLength(400);
	EditControl.SetHistory(true);
	return;
}

function Notify(UWindowDialogControl C, byte E)
{
	local string S;

	super.Notify(C, E);
	switch(E)
	{
		// End:0xF3
		case 7:
			switch(C)
			{
				// End:0xED
				case EditControl:
					// End:0xEA
					if(__NFUN_123__(EditControl.GetValue(), ""))
					{
						S = EditControl.GetValue();
						Root.Console.Message(__NFUN_112__("> ", S), 6.0000000);
						EditControl.Clear();
						// End:0xEA
						if(__NFUN_129__(Root.Console.ConsoleCommand(S)))
						{
							Root.Console.Message(Localize("Errors", "Exec", "R6Engine"), 6.0000000);
						}
					}
					// End:0xF0
					break;
				// End:0xFFFF
				default:
					break;
			}
			// End:0x16A
			break;
		// End:0x12D
		case 14:
			switch(C)
			{
				// End:0x127
				case EditControl:
					TextArea.VertSB.Scroll(-1.0000000);
					// End:0x12A
					break;
				// End:0xFFFF
				default:
					break;
			}
			// End:0x16A
			break;
		// End:0x167
		case 15:
			switch(C)
			{
				// End:0x161
				case EditControl:
					TextArea.VertSB.Scroll(1.0000000);
					// End:0x164
					break;
				// End:0xFFFF
				default:
					break;
			}
			// End:0x16A
			break;
		// End:0xFFFF
		default:
			break;
	}
	return;
}

function BeforePaint(Canvas C, float X, float Y)
{
	super(UWindowWindow).BeforePaint(C, X, Y);
	EditControl.SetSize(WinWidth, 17.0000000);
	EditControl.WinLeft = 0.0000000;
	EditControl.WinTop = __NFUN_175__(WinHeight, EditControl.WinHeight);
	EditControl.EditBoxWidth = WinWidth;
	TextArea.SetSize(WinWidth, __NFUN_175__(WinHeight, EditControl.WinHeight));
	return;
}

function Paint(Canvas C, float X, float Y)
{
	DrawStretchedTexture(C, 0.0000000, 0.0000000, WinWidth, WinHeight, Texture'UWindow.BlackTexture');
	return;
}

