//=============================================================================
// TetrahedronBuilder - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// TetrahedronBuilder: Builds an octahedron (not tetrahedron) - experimental.
//=============================================================================
class TetrahedronBuilder extends BrushBuilder;

var() int SphereExtrapolation;
var() float Radius;
var() name GroupName;

function Extrapolate(int A, int B, int C, int Count, float Radius)
{
	local int ab, bc, ca;

	// End:0x11D
	if((Count > 1))
	{
		ab = Vertexv((Radius * Normal((GetVertex(A) + GetVertex(B)))));
		bc = Vertexv((Radius * Normal((GetVertex(B) + GetVertex(C)))));
		ca = Vertexv((Radius * Normal((GetVertex(C) + GetVertex(A)))));
		Extrapolate(A, ab, ca, (Count - 1), Radius);
		Extrapolate(B, bc, ab, (Count - 1), Radius);
		Extrapolate(C, ca, bc, (Count - 1), Radius);
		Extrapolate(ab, bc, ca, (Count - 1), Radius);		
	}
	else
	{
		Poly3i(1, A, B, C);
	}
	return;
}

function BuildTetrahedron(float R, int SphereExtrapolation)
{
	Vertex3f(R, 0.0000000, 0.0000000);
	Vertex3f((-R), 0.0000000, 0.0000000);
	Vertex3f(0.0000000, R, 0.0000000);
	Vertex3f(0.0000000, (-R), 0.0000000);
	Vertex3f(0.0000000, 0.0000000, R);
	Vertex3f(0.0000000, 0.0000000, (-R));
	Extrapolate(2, 1, 4, SphereExtrapolation, Radius);
	Extrapolate(1, 3, 4, SphereExtrapolation, Radius);
	Extrapolate(3, 0, 4, SphereExtrapolation, Radius);
	Extrapolate(0, 2, 4, SphereExtrapolation, Radius);
	Extrapolate(1, 2, 5, SphereExtrapolation, Radius);
	Extrapolate(3, 1, 5, SphereExtrapolation, Radius);
	Extrapolate(0, 3, 5, SphereExtrapolation, Radius);
	Extrapolate(2, 0, 5, SphereExtrapolation, Radius);
	return;
}

event bool Build()
{
	// End:0x21
	if(((Radius <= float(0)) || (SphereExtrapolation <= 0)))
	{
		return BadParameters();
	}
	BeginBrush(false, GroupName);
	BuildTetrahedron(Radius, SphereExtrapolation);
	return EndBrush();
	return;
}

defaultproperties
{
	SphereExtrapolation=1
	Radius=256.0000000
	GroupName="Tetrahedron"
	BitmapFilename="BBSphere"
	ToolTip="Tetrahedron (Sphere)"
}
