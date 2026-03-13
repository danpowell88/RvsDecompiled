/*=============================================================================
	KarmaSupport.cpp: Karma physics actors and geometry elements
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/
#pragma optimize("", off)

// Placement new for placement-new stubs in this TU.
#pragma warning(push)
#pragma warning(disable: 4291)
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EnginePrivate.h"
#include "EngineDecls.h"

// --- AKActor ---
void AKActor::Spawned()
{
	// Ghidra 0x62160: if PhysicsVolume at this+0x18C is NULL, create Karma body
	// via FUN series. Divergence: Karma body creation not implemented; call super.
	// Karma physics will be unavailable for KActors.
	AActor::Spawned();
}


// --- AKConeLimit ---
void AKConeLimit::KUpdateConstraintParams()
{
	guard(AKConeLimit::KUpdateConstraintParams);
	unguard;
}


// --- AKConstraint ---
MdtBaseConstraint * AKConstraint::getKConstraint() const
{
	// Retail: 7b. MOV EAX, [ECX+0x418]; RET — returns the Karma constraint pointer.
	return *(MdtBaseConstraint**)((BYTE*)this + 0x418);
}

_McdModel * AKConstraint::getKModel() const
{
	return NULL;
}

void AKConstraint::physKarma(float)
{
	guard(AKConstraint::physKarma);
	unguard;
}

void AKConstraint::postKarmaStep()
{
	guard(AKConstraint::postKarmaStep);
	unguard;
}

void AKConstraint::preKarmaStep(float)
{
	guard(AKConstraint::preKarmaStep);
	unguard;
}

void AKConstraint::RenderEditorSelected(FLevelSceneNode *,FRenderInterface *,FDynamicActor *)
{
	guard(AKConstraint::RenderEditorSelected);
	unguard;
}

void AKConstraint::KUpdateConstraintParams()
{
	guard(AKConstraint::KUpdateConstraintParams);
	unguard;
}

void AKConstraint::PostEditChange()
{
	guard(AKConstraint::PostEditChange);
	unguard;
}

void AKConstraint::PostEditMove()
{
	guard(AKConstraint::PostEditMove);
	unguard;
}

void AKConstraint::CheckForErrors()
{
	// Ghidra 0x59dc0: call super, then warn if neither constraint actor is set.
	AActor::CheckForErrors();
	if (*(INT*)((BYTE*)this + 0x3C0) == 0 && *(INT*)((BYTE*)this + 0x3C4) == 0)
		GWarn->Logf(TEXT("KConstraint which does not point to any Actors."));
}

int AKConstraint::CheckOwnerUpdated()
{
	// Retail 0x5A410: same replication-queue logic as AActor, but checks Owner,
	// this+0x3C0 (KConstraintActor1) and this+0x3C4 (KConstraintActor2).
	// If any of the three changes network state, queue this actor and return 0.
	guard(AKConstraint::CheckOwnerUpdated);
	struct OwnedActorLink { void* Actor; OwnedActorLink* Prev; };
	auto tryQueue = [&]() -> INT
	{
		BYTE* ctrl = *(BYTE**)((BYTE*)this + 0x328);
		OwnedActorLink* node = (OwnedActorLink*)appMalloc( sizeof(OwnedActorLink), TEXT("OwnerUpdateNode") );
		if ( !node ) { *(void**)(ctrl + 0xF8) = NULL; return 0; }
		node->Actor = this;
		node->Prev  = *(OwnedActorLink**)(ctrl + 0xF8);
		*(OwnedActorLink**)(ctrl + 0xF8) = node;
		return 0;
	};
	BYTE* ctrl = *(BYTE**)((BYTE*)this + 0x328);
	INT stored = *(INT*)(ctrl + 0x100);
	AActor* owner = *(AActor**)((BYTE*)this + 0x140);
	if ( owner && (*(INT*)((BYTE*)owner + 0x320) & 1) != stored )
		return tryQueue();
	AActor* act2 = *(AActor**)((BYTE*)this + 0x3C0);
	if ( act2  && (*(INT*)((BYTE*)act2  + 0x320) & 1) != stored )
		return tryQueue();
	AActor* act3 = *(AActor**)((BYTE*)this + 0x3C4);
	if ( act3  && (*(INT*)((BYTE*)act3  + 0x320) & 1) != stored )
		return tryQueue();
	return 1;
	unguard;
}


// --- AKHinge ---
void AKHinge::preKarmaStep(float)
{
	guard(AKHinge::preKarmaStep);
	unguard;
}

void AKHinge::KUpdateConstraintParams()
{
	guard(AKHinge::KUpdateConstraintParams);
	unguard;
}


// --- FKAggregateGeom ---
FKAggregateGeom::FKAggregateGeom(FKAggregateGeom const &Other)
{
	// Ghidra 0x3cc00: no vtable; 4 TArrays at +0, +0xC, +0x18, +0x24
	new ((BYTE*)this + 0x00) TArray<FKSphereElem>(*(const TArray<FKSphereElem>*)((const BYTE*)&Other + 0x00));
	new ((BYTE*)this + 0x0C) TArray<FKBoxElem>(*(const TArray<FKBoxElem>*)((const BYTE*)&Other + 0x0C));
	new ((BYTE*)this + 0x18) TArray<FKCylinderElem>(*(const TArray<FKCylinderElem>*)((const BYTE*)&Other + 0x18));
	new ((BYTE*)this + 0x24) TArray<FKConvexElem>(*(const TArray<FKConvexElem>*)((const BYTE*)&Other + 0x24));
}

FKAggregateGeom::FKAggregateGeom()
{
	// Initialize all 4 TArrays to empty
	new ((BYTE*)this + 0x00) TArray<FKSphereElem>();
	new ((BYTE*)this + 0x0C) TArray<FKBoxElem>();
	new ((BYTE*)this + 0x18) TArray<FKCylinderElem>();
	new ((BYTE*)this + 0x24) TArray<FKConvexElem>();
}

FKAggregateGeom::~FKAggregateGeom()
{
	// Destroy 4 TArrays in reverse order
	((TArray<FKConvexElem>*)((BYTE*)this + 0x24))->~TArray();
	((TArray<FKCylinderElem>*)((BYTE*)this + 0x18))->~TArray();
	((TArray<FKBoxElem>*)((BYTE*)this + 0x0C))->~TArray();
	((TArray<FKSphereElem>*)((BYTE*)this + 0x00))->~TArray();
}

FKAggregateGeom& FKAggregateGeom::operator=(const FKAggregateGeom& Other)
{
	// Ghidra 0x3cc80: 4 TArrays at +0,+0xC,+0x18,+0x24
	*(TArray<FKSphereElem>*)((BYTE*)this + 0x00) = *(const TArray<FKSphereElem>*)((const BYTE*)&Other + 0x00);
	*(TArray<FKBoxElem>*)((BYTE*)this + 0x0C) = *(const TArray<FKBoxElem>*)((const BYTE*)&Other + 0x0C);
	*(TArray<FKCylinderElem>*)((BYTE*)this + 0x18) = *(const TArray<FKCylinderElem>*)((const BYTE*)&Other + 0x18);
	*(TArray<FKConvexElem>*)((BYTE*)this + 0x24) = *(const TArray<FKConvexElem>*)((const BYTE*)&Other + 0x24);
	return *this;
}

void FKAggregateGeom::EmptyElements()
{
	// Retail: 44b. Calls TArray::Empty(0) on each sub-array.
	// Retail order: boxes (0x0C), convex (0x24), cylinders (0x18), spheres (0x00).
	((TArray<FKBoxElem>*)     ((BYTE*)this + 0x0C))->Empty();
	((TArray<FKConvexElem>*)  ((BYTE*)this + 0x24))->Empty();
	((TArray<FKCylinderElem>*)((BYTE*)this + 0x18))->Empty();
	((TArray<FKSphereElem>*)  ((BYTE*)this + 0x00))->Empty();
}

// Ghidra: sum of 4 TArray Num() at offsets 0x00, 0x0C, 0x18, 0x24
int FKAggregateGeom::GetElementCount()
{
	INT* Counts = (INT*)this;
	// TArray layout: Data(4), ArrayNum(4), ArrayMax(4) = 12 bytes each
	// ArrayNum offsets: 0x04, 0x10, 0x1C, 0x28
	return Counts[1] + Counts[4] + Counts[7] + Counts[10];
}


// --- FKBoxElem ---
FKBoxElem::FKBoxElem(float InSize)
{
	// Ghidra: FMatrix::FMatrix() + set all 3 dims to same value
	X = InSize;
	Y = InSize;
	Z = InSize;
}

FKBoxElem::FKBoxElem(float InX, float InY, float InZ)
{
	X = InX;
	Y = InY;
	Z = InZ;
}

FKBoxElem::FKBoxElem()
{
	// Ghidra: just calls FMatrix::FMatrix() (default FMatrix ctor is empty)
}

FKBoxElem::~FKBoxElem()
{
	guard(FKBoxElem::~FKBoxElem);
	unguard;
}

FKBoxElem& FKBoxElem::operator=(const FKBoxElem& Other)
{
	appMemcpy( this, &Other, sizeof(FKBoxElem) );
	return *this;
}


// --- FKConvexElem ---
FKConvexElem::FKConvexElem(FKConvexElem const &Other)
{
	// Ghidra 0x27ce0: no vtable; 16 DWORDs at +0..+3F; TArray<FVector> at +40 (stride 12); TArray<INT> at +4C (stride 4)
	appMemcpy(this, &Other, 0x40); // 16 DWORDs
	new ((BYTE*)this + 0x40) TArray<FVector>(*(const TArray<FVector>*)((const BYTE*)&Other + 0x40));
	new ((BYTE*)this + 0x4C) TArray<INT>(*(const TArray<INT>*)((const BYTE*)&Other + 0x4C));
}

FKConvexElem::FKConvexElem()
{
	// Initialize TArray<FVector> at +0x40 and TArray<INT> at +0x4C to empty
	new ((BYTE*)this + 0x40) TArray<FVector>();
	new ((BYTE*)this + 0x4C) TArray<INT>();
}

FKConvexElem::~FKConvexElem()
{
	// Destroy TArray<INT> at +0x4C then TArray<FVector> at +0x40 (reverse order)
	((TArray<INT>*)((BYTE*)this + 0x4C))->~TArray();
	((TArray<FVector>*)((BYTE*)this + 0x40))->~TArray();
}

FKConvexElem& FKConvexElem::operator=(const FKConvexElem& Other)
{
	// Ghidra 0x27d50: 16 DWORDs (64 bytes) at +0..+3F (no vtable),
	// TArray<FVector> at +40 (FUN_10323160=12-byte), TArray<INT> at +4C (FUN_10322870=4-byte)
	appMemcpy(this, &Other, 0x40);
	*(TArray<FVector>*)((BYTE*)this + 0x40) = *(const TArray<FVector>*)((const BYTE*)&Other + 0x40);
	*(TArray<INT>*)((BYTE*)this + 0x4C) = *(const TArray<INT>*)((const BYTE*)&Other + 0x4C);
	return *this;
}


// --- FKCylinderElem ---
FKCylinderElem::FKCylinderElem(float InRadius, float InLength)
{
	Radius = InRadius;
	Length = InLength;
}

FKCylinderElem::FKCylinderElem()
{
	guard(FKCylinderElem::FKCylinderElem);
	unguard;
}

FKCylinderElem::~FKCylinderElem()
{
	guard(FKCylinderElem::~FKCylinderElem);
	unguard;
}

FKCylinderElem& FKCylinderElem::operator=(const FKCylinderElem& Other)
{
	appMemcpy( this, &Other, sizeof(FKCylinderElem) );
	return *this;
}


// --- FKSphereElem ---
FKSphereElem::FKSphereElem(float InRadius)
{
	Radius = InRadius;
}

FKSphereElem::FKSphereElem()
{
	guard(FKSphereElem::FKSphereElem);
	unguard;
}

FKSphereElem::~FKSphereElem()
{
	guard(FKSphereElem::~FKSphereElem);
	unguard;
}

FKSphereElem& FKSphereElem::operator=(const FKSphereElem& Other)
{
	appMemcpy( this, &Other, sizeof(FKSphereElem) );
	return *this;
}


// --- UKMeshProps ---
void UKMeshProps::Serialize(FArchive& Ar)
{
	// Ghidra 0x501b0: UObject::Serialize + 9 FLOAT fields at +0x2C..+0x4C (mass props),
	// then TArray of FKConvexElem at +0x50 (divergence: not serialized, insufficient type info).
	UObject::Serialize(Ar);
	Ar.ByteOrderSerialize((BYTE*)this + 0x2C, 4);
	Ar.ByteOrderSerialize((BYTE*)this + 0x30, 4);
	Ar.ByteOrderSerialize((BYTE*)this + 0x34, 4);
	Ar.ByteOrderSerialize((BYTE*)this + 0x38, 4);
	Ar.ByteOrderSerialize((BYTE*)this + 0x3C, 4);
	Ar.ByteOrderSerialize((BYTE*)this + 0x40, 4);
	Ar.ByteOrderSerialize((BYTE*)this + 0x44, 4);
	Ar.ByteOrderSerialize((BYTE*)this + 0x48, 4);
	Ar.ByteOrderSerialize((BYTE*)this + 0x4C, 4);
	// NOTE: Divergence — TArray at +0x50 (FKConvexElem array) not serialized.
}

void UKMeshProps::Draw(FRenderInterface *,int)
{
	guard(UKMeshProps::Draw);
	unguard;
}


// --- UKarmaParams ---
void UKarmaParams::PostEditChange()
{
	guard(UKarmaParams::PostEditChange);
	unguard;
}

