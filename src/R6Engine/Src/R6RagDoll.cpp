/*=============================================================================
	R6RagDoll.cpp
	AR6RagDoll — Verlet integration ragdoll physics.
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6RagDoll)

static INT  DAT_10074340  = 1; // physics stepping enabled flag
static INT  _DAT_10075508 = 0; // physics step counter

// --- AR6RagDoll ---

IMPL_APPROX("Remaps hit bone to parent ragdoll particle and applies impulse to its position")
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

IMPL_APPROX("Adds a new Verlet spring constraint between two particles with min/max squared distance")
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

IMPL_APPROX("Projects particle back onto a plane when it penetrates it, with 0.2 restitution")
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

IMPL_APPROX("Sweeps each particle against world geometry and resolves penetration via SingleLineCheck")
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

IMPL_APPROX("Initialises all 16 ragdoll particles from the pawn's skeletal reference pose and builds spring constraints")
void AR6RagDoll::FirstInit(AR6AbstractPawn * param_1)
{
	guard(AR6RagDoll::FirstInit);

	*(AR6AbstractPawn**)((BYTE*)this + 0x398) = param_1;
	*(FLOAT*)((BYTE*)this + 0x394) = 0.025f;  // 0x3ccccccd

	// Set bone names for all 16 particles
	*(FName*)((BYTE*)this + 0x3fc) = FName(TEXT("R6 Spine1"), FNAME_Add);
	*(FName*)((BYTE*)this + 0x454) = FName(TEXT("R6 Pelvis"), FNAME_Add);
	*(FName*)((BYTE*)this + 0x4ac) = FName(TEXT("R6 Neck"), FNAME_Add);
	*(FName*)((BYTE*)this + 0x504) = FName(TEXT("R6 Head"), FNAME_Add);
	*(FName*)((BYTE*)this + 0x55c) = FName(TEXT("R6 L UpperArm"), FNAME_Add);
	*(FName*)((BYTE*)this + 0x5b4) = FName(TEXT("R6 L Forearm"), FNAME_Add);
	*(FName*)((BYTE*)this + 0x60c) = FName(TEXT("R6 L Hand"), FNAME_Add);
	*(FName*)((BYTE*)this + 0x664) = FName(TEXT("R6 R UpperArm"), FNAME_Add);
	*(FName*)((BYTE*)this + 0x6bc) = FName(TEXT("R6 R Forearm"), FNAME_Add);
	*(FName*)((BYTE*)this + 0x714) = FName(TEXT("R6 R Hand"), FNAME_Add);
	*(FName*)((BYTE*)this + 0x76c) = FName(TEXT("R6 L Thigh"), FNAME_Add);
	*(FName*)((BYTE*)this + 0x7c4) = FName(TEXT("R6 L Calf"), FNAME_Add);
	*(FName*)((BYTE*)this + 0x81c) = FName(TEXT("R6 L Foot"), FNAME_Add);
	*(FName*)((BYTE*)this + 0x874) = FName(TEXT("R6 R Thigh"), FNAME_Add);
	*(FName*)((BYTE*)this + 0x8cc) = FName(TEXT("R6 R Calf"), FNAME_Add);
	*(FName*)((BYTE*)this + 0x924) = FName(TEXT("R6 R Foot"), FNAME_Add);

	// Particle mass/radius table: 16 entries for mass, 16 entries for bone ref index
	FLOAT massTable[16] = { 3.0f, 3.0f, 3.0f, 1.5f, 2.0f, 1.0f, 0.5f, 2.0f,
	                         1.0f, 0.5f, 2.0f, 1.0f, 0.5f, 2.0f, 1.0f, 0.5f };
	// Bone ref indices: 2,2,3,-1,5,6,-1,8,9,-1,11,12,-1,14,15,-1
	// (stored as floats reinterpreted as ints in Ghidra)
	INT boneRefs[16] = { 2, 2, 3, -1, 5, 6, -1, 8, 9, -1, 11, 12, -1, 14, 15, -1 };

	// Verify pawn's mesh is a USkeletalMesh
	check(*(UObject**)(*(INT*)((BYTE*)this + 0x398) + 0x16c) != NULL);

	// Get the mesh instance
	INT pawnPtr = *(INT*)((BYTE*)this + 0x398);
	USkeletalMeshInstance* MeshInst = (USkeletalMeshInstance*)
		(*(UMeshInstance*(__thiscall**)(UMesh*, AActor*))
		(**(INT**)(pawnPtr + 0x16c) + 0x88))
		(*(UMesh**)(pawnPtr + 0x16c), (AActor*)pawnPtr);

	// Initialize particle positions from bone reference pose
	for (INT i = 0; i < 16; i++)
	{
		INT particleOffset = i * 0x58;
		FVector* ParticlePos = (FVector*)((BYTE*)this + particleOffset + 0x3a8);

		*(FLOAT*)((BYTE*)this + particleOffset + 0x3f0) = 1.0f / massTable[i];

		FName BoneName = *(FName*)((BYTE*)this + particleOffset + 0x3fc);
		INT BoneIdx = MeshInst->MatchRefBone(BoneName);
		*(INT*)((BYTE*)ParticlePos + 0x50) = BoneIdx;

		// Copy initial bone position from ref pose
		INT* BoneData = (INT*)(BoneIdx * 0x30 + *(INT*)((BYTE*)MeshInst + 0xb8));
		*(INT*)ParticlePos = BoneData[0];
		*((INT*)ParticlePos + 1) = BoneData[1];
		*((INT*)ParticlePos + 2) = BoneData[2];

		// Special adjustments for spine/pelvis/head
		if (i == 0)
			ParticlePos->X += 10.0f;
		else if (i == 1)
		{
			INT SpineBoneIdx = *(INT*)((BYTE*)this + 0x3f8);
			FLOAT* SpineData = (FLOAT*)(SpineBoneIdx * 0x30 + *(INT*)((BYTE*)MeshInst + 0xb8));
			ParticlePos->X = SpineData[0] - 10.0f;
			ParticlePos->Y = SpineData[1];
			ParticlePos->Z = SpineData[2];
		}
		else if (i == 3)
			ParticlePos->Z += 10.0f;

		// Transform from bone space to world space
		FVector Transformed = ParticlePos->TransformPointBy(*(FCoords*)((BYTE*)MeshInst + 0xc4));
		*ParticlePos = Transformed;

		// Offset downward by 15 units
		ParticlePos->Z -= 15.0f;

		// Set previous position to current (no initial velocity)
		*(FLOAT*)((BYTE*)ParticlePos + 0x30) = ParticlePos->X;
		*(FLOAT*)((BYTE*)ParticlePos + 0x34) = ParticlePos->Y;
		*(FLOAT*)((BYTE*)ParticlePos + 0x38) = ParticlePos->Z;
	}

	// Create spring constraints between particles
	AddSpring(0xb, 0xc, 43.91f, 0.0f);
	AddSpring(0xa, 0xb, 42.31f, 0.0f);
	AddSpring(0x0, 0xa, 18.94f, 0.0f);
	AddSpring(0xe, 0xf, 43.91f, 0.0f);
	AddSpring(0xd, 0xe, 42.31f, 0.0f);
	AddSpring(0x1, 0xd, 18.94f, 0.0f);
	AddSpring(0x4, 0x5, 32.35f, 0.0f);
	AddSpring(0x5, 0x6, 22.6f, 0.0f);
	AddSpring(0x7, 0x8, 32.35f, 0.0f);
	AddSpring(0x8, 0x9, 22.6f, 0.0f);
	AddSpring(0x2, 0x4, 15.22f, 0.0f);
	AddSpring(0x2, 0x7, 15.22f, 0.0f);
	AddSpring(0x2, 0x3, 21.84f, 0.0f);
	AddSpring(0x0, 0x1, 20.0f, 0.0f);
	AddSpring(0xa, 0xd, 19.06f, 0.0f);
	AddSpring(0x0, 0x2, 31.02f, 0.0f);
	AddSpring(0x1, 0x2, 31.02f, 0.0f);
	AddSpring(0x1, 0xa, 27.2f, 0.0f);
	AddSpring(0x0, 0xd, 27.2f, 0.0f);
	AddSpring(0x0, 0x4, 26.58f, 0.0f);
	AddSpring(0x1, 0x7, 26.57f, 0.0f);
	AddSpring(0x0, 0x7, 36.07f, 0.0f);
	AddSpring(0x1, 0x4, 36.07f, 0.0f);
	AddSpring(0x0, 0x5, 15.0f, -1.0f);
	AddSpring(0x0, 0x6, 15.0f, -1.0f);
	AddSpring(0x1, 0x8, 15.0f, -1.0f);
	AddSpring(0x1, 0x9, 15.0f, -1.0f);
	AddSpring(0x5, 0x8, 25.0f, -1.0f);
	AddSpring(0xb, 0xe, 15.0f, 50.0f);
	AddSpring(0xc, 0xf, 15.0f, 60.0f);
	AddSpring(0x2, 0xc, 100.0f, 160.0f);
	AddSpring(0x2, 0xf, 100.0f, 160.0f);

	unguard;
}

IMPL_APPROX("Editor debug visualisation of ragdoll skeleton via FLineBatcher; unresolved raw call pattern omitted")
void AR6RagDoll::RenderBones(UCanvas * Canvas)
{
	guard(AR6RagDoll::RenderBones);

	// DIVERGENCE: editor/debug visualization function (Ghidra 0x33760, ~1000 bytes).
	// Draws ragdoll skeleton via FLineBatcher — iterates 16 particles, draws lines
	// between connected bone pairs and spheres at particle positions.
	// FLineBatcher raw call pattern not reconstructed; omitted (editor-only path).

	unguard;
}

IMPL_APPROX("Iterates all spring constraints and corrects particle positions to satisfy min/max distance bounds")
void AR6RagDoll::SatisfyConstraints()
{
	guard(AR6RagDoll::SatisfyConstraints);

	// Iterate over all springs and enforce distance constraints
	for (INT i = 0; i < m_aSpring.Num(); i++)
	{
		FSTSpring& s = m_aSpring(i);
		FVector& Pos1 = m_aParticle[s.iFirst].cCurrentPos.Origin;
		FVector& Pos2 = m_aParticle[s.iSecond].cCurrentPos.Origin;

		FLOAT dx = Pos2.X - Pos1.X;
		FLOAT dy = Pos2.Y - Pos1.Y;
		FLOAT dz = Pos2.Z - Pos1.Z;
		FLOAT dist2 = dx * dx + dy * dy + dz * dz;

		FLOAT invMass1 = *(FLOAT*)((BYTE*)this + s.iFirst * 0x58 + 0x3f0);
		FLOAT invMass2 = *(FLOAT*)((BYTE*)this + s.iSecond * 0x58 + 0x3f0);
		FLOAT totalInvMass = invMass1 + invMass2;

		if (totalInvMass == 0.0f)
			continue;

		// Check if distance exceeds max constraint
		if (s.fMaxSquared != -1.0f && dist2 > s.fMaxSquared)
		{
			FLOAT dist = appSqrt(dist2);
			FLOAT maxDist = appSqrt(s.fMaxSquared);
			FLOAT diff = (dist - maxDist) / (dist * totalInvMass);

			Pos1.X += dx * diff * invMass1;
			Pos1.Y += dy * diff * invMass1;
			Pos1.Z += dz * diff * invMass1;
			Pos2.X -= dx * diff * invMass2;
			Pos2.Y -= dy * diff * invMass2;
			Pos2.Z -= dz * diff * invMass2;
		}
		// Check if distance is less than min constraint
		else if (s.fMinSquared != -1.0f && dist2 < s.fMinSquared)
		{
			FLOAT dist = appSqrt(dist2);
			FLOAT minDist = appSqrt(s.fMinSquared);
			FLOAT diff = (dist - minDist) / (dist * totalInvMass);

			Pos1.X += dx * diff * invMass1;
			Pos1.Y += dy * diff * invMass1;
			Pos1.Z += dz * diff * invMass1;
			Pos2.X -= dx * diff * invMass2;
			Pos2.Y -= dy * diff * invMass2;
			Pos2.Z -= dz * diff * invMass2;
		}
	}

	unguard;
}

IMPL_APPROX("Verlet-steps ragdoll physics, updates bone positions on pawn mesh, and snaps pawn to ragdoll root")
INT AR6RagDoll::Tick(FLOAT param_1, enum ELevelTick param_2)
{
	guard(AR6RagDoll::Tick);

	if (*(INT*)((BYTE*)this + 0x398) == 0)
	{
		// No pawn owner — call super Tick
		AActor::Tick(param_1, param_2);
	}
	else if ((*(BYTE*)((BYTE*)this + 0xa2) & 1) == 0)
	{
		// Verify pawn mesh is USkeletalMesh
		{
			UObject* mesh = *(UObject**)((BYTE*)*(INT*)((BYTE*)this + 0x398) + 0x16c);
			if (mesh != NULL && !mesh->IsA(USkeletalMesh::StaticClass()))
				appFailAssert("m_pawnOwner->Mesh->IsA( USkeletalMesh::StaticClass() )",
				              ".\\Src\\AR6RagDoll.cpp", 0x2b0);
		}
		if (*(FLOAT*)((BYTE*)this + 0xbc) <= 3.0f)
		{
			bool bVar2 = false;

			*(FLOAT*)((BYTE*)this + 0xbc) = param_1 + *(FLOAT*)((BYTE*)this + 0xbc);
			FLOAT fVar6 = param_1 + *(FLOAT*)((BYTE*)this + 0x394);

			// Step physics in fixed 0.025-second increments
			while (DAT_10074340 != 0 && (*(FLOAT*)((BYTE*)this + 0x394) = fVar6, 0.025f < *(FLOAT*)((BYTE*)this + 0x394)))
			{
				_DAT_10075508 = _DAT_10075508 + 1;
				VerletIntegration(0.025f);
				SatisfyConstraints();
				CollisionDetection();
				fVar6 = *(FLOAT*)((BYTE*)this + 0x394) - 0.025f;
				bVar2 = true;
			}

			if (bVar2)
			{
				// Update bone positions from Verlet nodes
				void* pawnOwner = *(void**)((BYTE*)this + 0x398);
				void* pMesh = *(void**)((BYTE*)pawnOwner + 0x16c);
				typedef USkeletalMeshInstance* (__thiscall *TGetMeshInst)(void*, void*);
				USkeletalMeshInstance* local_18 = ((TGetMeshInst)*(DWORD*)(*(DWORD*)pMesh + 0x88))(pMesh, pawnOwner);

				BYTE local_38[12];
				for (INT iVar4 = 1; iVar4 < 0x10; iVar4++)
				{
					FCoords* this_00 = (FCoords*)((BYTE*)this + iVar4 * 0x58 + 0x3a8);
					FRotator orthoRot = this_00->OrthoRotation();
					DWORD* puVar5 = (DWORD*)&orthoRot;

					FLOAT local_28 = (FLOAT)puVar5[1];
					DWORD uVar1    = puVar5[0];
					FLOAT local_24 = (FLOAT)puVar5[2];

					*(FLOAT*)((BYTE*)this_00 + 0x44) = *(FLOAT*)((BYTE*)this_00 + 0x44) + 15.0f;

					{
						FName boneName;
						*(DWORD*)&boneName = *(DWORD*)((BYTE*)this_00 + 0x54);
						FRotator boneRot;
						*(DWORD*)&boneRot       = uVar1;
						*(FLOAT*)((BYTE*)&boneRot + 4) = local_28;
						*(FLOAT*)((BYTE*)&boneRot + 8) = local_24;
						FVector bonePos;
						*(DWORD*)&bonePos             = *(DWORD*)((BYTE*)this_00 + 0x3c);
						*(DWORD*)((BYTE*)&bonePos + 4) = *(DWORD*)((BYTE*)this_00 + 0x40);
						*(DWORD*)((BYTE*)&bonePos + 8) = *(DWORD*)((BYTE*)this_00 + 0x44);
						local_18->SetBonePosition(boneName, boneRot, bonePos, 1.0f);
						// DIVERGENCE: original passes extra buffer arg; dropped
					}
				}

				// Check how far the ragdoll root has drifted from the pawn
				INT iVar4b = *(INT*)((BYTE*)this + 0x398);
				FLOAT local_24 = *(FLOAT*)((BYTE*)this + 0x3b0) - *(FLOAT*)(iVar4b + 0x23c);
				FLOAT local_28 = *(FLOAT*)((BYTE*)this + 0x3ac) - *(FLOAT*)(iVar4b + 0x238);
				FLOAT local_2c = *(FLOAT*)((BYTE*)this + 0x3a8) - *(FLOAT*)(iVar4b + 0x234);

				FLOAT fVar6b = ((FVector*)&local_2c)->Size();

				if ((5.0f < fVar6b) && (0.5f < *(FLOAT*)((BYTE*)this + 0xbc)))
				{
					// Snap pawn to ragdoll root position
					iVar4b = *(INT*)((BYTE*)this + 0x398);
					FLOAT save_x = *(FLOAT*)(iVar4b + 0x234);
					FLOAT save_y = *(FLOAT*)(iVar4b + 0x238);
					FLOAT save_z = *(FLOAT*)(iVar4b + 0x23c);

				{
					INT* pXLevel = *(INT**)((BYTE*)this + 0x328);
					typedef INT (__thiscall *TMoveActor)(void*, INT, DWORD, DWORD, DWORD, INT, INT, INT, INT);
					TMoveActor MoveActor = (TMoveActor)*(DWORD*)(*(DWORD*)pXLevel + 0x9c);
					MoveActor(pXLevel, iVar4b,
					          *(DWORD*)((BYTE*)this + 0x3a8),
					          *(DWORD*)((BYTE*)this + 0x3ac),
					          *(DWORD*)((BYTE*)this + 0x3b0),
					          0, 0, 0, 0);
				}

					iVar4b = *(INT*)((BYTE*)this + 0x398);
					FLOAT delta_z = save_z - *(FLOAT*)(iVar4b + 0x23c);
					FLOAT delta_y = save_y - *(FLOAT*)(iVar4b + 0x238);
					FLOAT delta_x = save_x - *(FLOAT*)(iVar4b + 0x234);

					INT iVar3 = ((FVector*)&delta_x)->IsNearlyZero();
					if (iVar3 == 0)
						*(DWORD*)((BYTE*)this + 0xbc) = 0; // reset timer if actually moved
				}
			}
		}
		else
		{
			// Crawling — set bCrawling flag (bit 0x10000) at this+0xa0
			*(DWORD*)((BYTE*)this + 0xa0) = *(DWORD*)((BYTE*)this + 0xa0) | 0x10000;
		}
	}

	return 1;

	unguard;
}

IMPL_APPROX("Standard Verlet integration with gravity; loop matches binary but is clean rather than unrolled")
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
