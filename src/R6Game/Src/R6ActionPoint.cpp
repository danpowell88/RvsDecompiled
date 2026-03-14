/*=============================================================================
	R6ActionPoint.cpp
=============================================================================*/

#include "R6GamePrivate.h"

IMPLEMENT_CLASS(AR6ActionPoint)

// --- AR6ActionPoint ---

IMPL_INFERRED("Ravenshield-specific; reconstructed from context")
void AR6ActionPoint::SetRotationToward(FVector Target)
{
	// Compute direction vector from Location to Target in the XY plane
	FLOAT DirX = Target.X - Location.X;
	FLOAT DirY = Target.Y - Location.Y;
	FVector Dir(DirX, DirY, 0.0f);
	Dir.Normalize();

	// Build an orthonormal coordinate frame aligned to that direction
	FCoords Frame;
	Frame.Origin = FVector(0.0f, 0.0f, 0.0f);
	Frame.XAxis  = FVector( Dir.X,  Dir.Y, 0.0f);
	Frame.YAxis  = FVector(-Dir.Y,  Dir.X, 0.0f);
	Frame.ZAxis  = FVector( 0.0f,   0.0f,  1.0f);

	FRotator Rot = Frame.OrthoRotation();
	INT Yaw = Rot.Yaw;

	// Store compressed yaw byte at the action-point's rotation slot
	*(BYTE*)((BYTE*)this + 0x3f) = (BYTE)(Yaw / 255);
}

IMPL_INFERRED("Ravenshield-specific; reconstructed from context")
void AR6ActionPoint::TransferFile(FArchive& Ar)
{
	// BYTE action/movement fields (0x3A4-0x3A7)
	Ar.Serialize(&m_eMovementMode,  1);
	Ar.Serialize(&m_eMovementSpeed, 1);
	Ar.Serialize(&m_eAction,        1);
	Ar.Serialize(&m_eActionType,    1);

	// Action parameters
	Ar.ByteOrderSerialize(&m_iMileStoneNum,          sizeof(m_iMileStoneNum));
	Ar.ByteOrderSerialize(&m_vActionDirection.X,     sizeof(FLOAT));
	Ar.ByteOrderSerialize(&m_vActionDirection.Y,     sizeof(FLOAT));
	Ar.ByteOrderSerialize(&m_vActionDirection.Z,     sizeof(FLOAT));
	Ar.ByteOrderSerialize(&m_rActionRotation.Pitch,  sizeof(INT));
	Ar.ByteOrderSerialize(&m_rActionRotation.Yaw,    sizeof(INT));
	Ar.ByteOrderSerialize(&m_rActionRotation.Roll,   sizeof(INT));

	// Two AActor base fields at 0x70 / 0x74 (identity unverified)
	Ar.ByteOrderSerialize((BYTE*)this + 0x70, 4);
	Ar.ByteOrderSerialize((BYTE*)this + 0x74, 4);

	// Four single-byte AActor flags at 0x314-0x317 (serialized in Ghidra order)
	Ar.Serialize((BYTE*)this + 0x316, 1);
	Ar.Serialize((BYTE*)this + 0x315, 1);
	Ar.Serialize((BYTE*)this + 0x314, 1);
	Ar.Serialize((BYTE*)this + 0x317, 1);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
