/*=============================================================================
	R6RagDoll.cpp
	AR6RagDoll — Verlet integration ragdoll physics.
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6RagDoll)

// --- AR6RagDoll ---

void AR6RagDoll::AddImpulseToBone(INT BoneIndex, FVector Impulse)
{
	// Remap certain bone indices to their parent ragdoll particle
	switch (BoneIndex)
	{
	case 2: case 4:
		BoneIndex = 3;
		break;
	case 7: case 8: case 9:
		BoneIndex = 6;
		break;
	case 10: case 15:
		BoneIndex = 5;
		break;
	case 14: case 19: case 23: case 27:
		BoneIndex = BoneIndex - 1;
		break;
	}

	for (INT i = 0; i < 16; i++)
	{
		if (m_aParticle[i].iRefBone == BoneIndex)
		{
			m_aParticle[i].cCurrentPos.Origin.X += Impulse.X;
			m_aParticle[i].cCurrentPos.Origin.Y += Impulse.Y;
			m_aParticle[i].cCurrentPos.Origin.Z += Impulse.Z;
			return;
		}
	}
}

void AR6RagDoll::AddSpring(INT idx1, INT idx2, FLOAT dist, FLOAT maxDist)
{
	INT i = m_aSpring.Add(1);
	FSTSpring& s = m_aSpring(i);
	s.iFirst = idx1;
	s.iSecond = idx2;

	if (dist != -1.0f)
		s.fMinSquared = dist * dist;
	else
		s.fMinSquared = -1.0f;

	if (maxDist == 0.0f)
		s.fMaxSquared = s.fMinSquared;
	else if (maxDist == -1.0f)
		s.fMaxSquared = -1.0f;
	else
		s.fMaxSquared = maxDist * maxDist;
}

void AR6RagDoll::ClipParticleToPlane(INT particleIdx, FVector const & Normal, FVector const & PlanePoint)
{
	FVector& Origin = m_aParticle[particleIdx].cCurrentPos.Origin;
	FLOAT dist = (Origin.X * Normal.X + Origin.Y * Normal.Y + Origin.Z * Normal.Z)
	            - (PlanePoint.X * Normal.X + PlanePoint.Y * Normal.Y + PlanePoint.Z * Normal.Z);
	if (dist < 0.0f)
	{
		dist *= 0.2f;
		Origin.X -= dist * Normal.X;
		Origin.Y -= dist * Normal.Y;
		Origin.Z -= dist * Normal.Z;
	}
}

void AR6RagDoll::CollisionDetection()
{
	guard(AR6RagDoll::CollisionDetection);
	for (INT i = 0; i < 16; i++)
	{
		FSTParticle& p = m_aParticle[i];
		FVector CurrentPos = p.cCurrentPos.Origin;
		FCheckResult Hit(1.0f);
		XLevel->SingleLineCheck(Hit, this, CurrentPos, p.vPreviousOrigin, 0x86, FVector(0,0,0));
		if (Hit.Time != 1.0f)
			p.cCurrentPos.Origin = Hit.Location;
	}
	unguard;
}

void AR6RagDoll::FirstInit(AR6AbstractPawn *)
{
}

void AR6RagDoll::RenderBones(UCanvas *)
{
}

void AR6RagDoll::SatisfyConstraints()
{
}

INT AR6RagDoll::Tick(FLOAT, enum ELevelTick)
{
	return 0;
}

void AR6RagDoll::VerletIntegration(FLOAT dt)
{
	// Standard Verlet integration: newPos = 2*pos - prevPos + accel*dt^2
	// Gravity is (0, 0, -600) in Unreal units
	FLOAT gravZ = -600.0f * dt * dt;
	for (INT i = 0; i < 16; i++)
	{
		FSTParticle& p = m_aParticle[i];
		FVector save = p.cCurrentPos.Origin;
		p.cCurrentPos.Origin.X += (p.cCurrentPos.Origin.X - p.vPreviousOrigin.X);
		p.cCurrentPos.Origin.Y += (p.cCurrentPos.Origin.Y - p.vPreviousOrigin.Y);
		p.cCurrentPos.Origin.Z += (p.cCurrentPos.Origin.Z - p.vPreviousOrigin.Z) + gravZ;
		p.vPreviousOrigin = save;
	}
	// NOTE: Original binary has this loop fully unrolled (8 particles per iteration, 2 iterations).
	// This clean loop produces identical results but different machine code.
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
