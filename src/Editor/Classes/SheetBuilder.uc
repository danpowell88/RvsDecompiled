//=============================================================================
// SheetBuilder - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// SheetBuilder: Builds a simple sheet.
//=============================================================================
class SheetBuilder extends BrushBuilder;

enum ESheetAxis
{
	AX_Horizontal,                  // 0
	AX_XAxis,                       // 1
	AX_YAxis                        // 2
};

// NEW IN 1.60
var() SheetBuilder.ESheetAxis Axis;
var() int Height;
// NEW IN 1.60
var() int Width;
// NEW IN 1.60
var() int HorizBreaks;
// NEW IN 1.60
var() int VertBreaks;
var() name GroupName;

event bool Build()
{
	local int X, Y, XStep, YStep, idx, Count;

	// End:0x39
	if(((((Height <= 0) || (Width <= 0)) || (HorizBreaks <= 0)) || (VertBreaks <= 0)))
	{
		return BadParameters();
	}
	BeginBrush(false, GroupName);
	XStep = (Width / HorizBreaks);
	YStep = (Height / VertBreaks);
	Count = 0;
	X = 0;
	J0x77:

	// End:0x45A [Loop If]
	if((X < HorizBreaks))
	{
		Y = 0;
		J0x8D:

		// End:0x450 [Loop If]
		if((Y < VertBreaks))
		{
			// End:0x1C7
			if((int(Axis) == int(0)))
			{
				Vertex3f((float((X * XStep)) - float((Width / 2))), (float((Y * YStep)) - float((Height / 2))), 0.0000000);
				Vertex3f((float((X * XStep)) - float((Width / 2))), ((float((Y + 1)) * float(YStep)) - float((Height / 2))), 0.0000000);
				Vertex3f(((float((X + 1)) * float(XStep)) - float((Width / 2))), ((float((Y + 1)) * float(YStep)) - float((Height / 2))), 0.0000000);
				Vertex3f(((float((X + 1)) * float(XStep)) - float((Width / 2))), (float((Y * YStep)) - float((Height / 2))), 0.0000000);				
			}
			else
			{
				// End:0x2F2
				if((int(Axis) == int(1)))
				{
					Vertex3f(0.0000000, (float((X * XStep)) - float((Width / 2))), (float((Y * YStep)) - float((Height / 2))));
					Vertex3f(0.0000000, (float((X * XStep)) - float((Width / 2))), ((float((Y + 1)) * float(YStep)) - float((Height / 2))));
					Vertex3f(0.0000000, ((float((X + 1)) * float(XStep)) - float((Width / 2))), ((float((Y + 1)) * float(YStep)) - float((Height / 2))));
					Vertex3f(0.0000000, ((float((X + 1)) * float(XStep)) - float((Width / 2))), (float((Y * YStep)) - float((Height / 2))));					
				}
				else
				{
					Vertex3f((float((X * XStep)) - float((Width / 2))), 0.0000000, (float((Y * YStep)) - float((Height / 2))));
					Vertex3f((float((X * XStep)) - float((Width / 2))), 0.0000000, ((float((Y + 1)) * float(YStep)) - float((Height / 2))));
					Vertex3f(((float((X + 1)) * float(XStep)) - float((Width / 2))), 0.0000000, ((float((Y + 1)) * float(YStep)) - float((Height / 2))));
					Vertex3f(((float((X + 1)) * float(XStep)) - float((Width / 2))), 0.0000000, (float((Y * YStep)) - float((Height / 2))));
				}
			}
			Poly4i(1, Count, (Count + 1), (Count + 2), (Count + 3), 'Sheet', 264);
			Count = GetVertexCount();
			(Y++);
			// [Loop Continue]
			goto J0x8D;
		}
		(X++);
		// [Loop Continue]
		goto J0x77;
	}
	return EndBrush();
	return;
}

defaultproperties
{
	Height=256
	Width=256
	HorizBreaks=1
	VertBreaks=1
	GroupName="Sheet"
	BitmapFilename="BBSheet"
	ToolTip="Sheet"
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var h
// REMOVED IN 1.60: var s
// REMOVED IN 1.60: var ESheetAxis
