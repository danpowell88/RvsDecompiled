/*=============================================================================
KarmaSupport.cpp: Karma physics actors and geometry elements
Reconstructed for Ravenshield decompilation project.
=============================================================================*/
#pragma optimize("", off)
#include "ImplSource.h"

// Placement new for placement-new stubs in this TU.
#include "EnginePrivate.h"
#pragma warning(push)
#pragma warning(disable: 4291)
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EngineDecls.h"

// --- AKActor ---
IMPL_MATCH("Engine.dll", 0x62160)
void AKActor::Spawned()
{
// Ghidra 0x62160: if KParams (this+0x18C) is NULL and not an AKConstraint,
// construct a new UKarmaParams via StaticConstructObject and assign to KParams.
// Retail does NOT call AActor::Spawned() (super is empty at 0x176d60 anyway).
guard(AKActor::Spawned);
if (KParams == NULL && !IsA(AKConstraint::StaticClass()))
    KParams = (UKarmaParamsCollision*)UObject::StaticConstructObject(
        UKarmaParams::StaticClass(), GetOuter(), NAME_None, 0, NULL, GError, (INT)0);
unguard;
}


// --- AKConeLimit ---
IMPL_DIVERGE("Karma MeSDK not integrated: calls FUN_104969c0/e0/c0/a10 in Karma SDK range")
void AKConeLimit::KUpdateConstraintParams()
{
guard(AKConeLimit::KUpdateConstraintParams);
unguard;
}


// --- AKConstraint ---
IMPL_MATCH("Engine.dll", 0x59d20)
MdtBaseConstraint * AKConstraint::getKConstraint() const
{
// Retail 0x59d20: 7b. MOV EAX, [ECX+0x418]; RET — returns the Karma constraint pointer.
return *(MdtBaseConstraint**)((BYTE*)this + 0x418);
}

IMPL_MATCH("Engine.dll", 0x114310)
_McdModel * AKConstraint::getKModel() const
{
guard(AKConstraint::getKModel);
// Ghidra 0x114310: shared zero-return vtable stub.
return NULL;
unguard;
}

IMPL_DIVERGE("Karma MeSDK not integrated: physKarma uses RDTSC profiling and Karma SDK calls (0x5a510)")
void AKConstraint::physKarma(float)
{
guard(AKConstraint::physKarma);
unguard;
}

IMPL_EMPTY("Ghidra 0x176d60: retail body is empty (shared stub for many no-op virtuals)")
void AKConstraint::postKarmaStep()
{
}

IMPL_EMPTY("Ghidra 0x1651d0: retail body is empty (shared stub for many no-op virtuals)")
void AKConstraint::preKarmaStep(float)
{
}

IMPL_DIVERGE("Karma MeSDK not integrated: editor constraint rendering requires Karma SDK (0x10c6c0)")
void AKConstraint::RenderEditorSelected(FLevelSceneNode *,FRenderInterface *,FDynamicActor *)
{
guard(AKConstraint::RenderEditorSelected);
unguard;
}

IMPL_EMPTY("Ghidra 0x176d60: retail body is empty (shared stub for many no-op virtuals)")
void AKConstraint::KUpdateConstraintParams()
{
}

IMPL_MATCH("Engine.dll", 0x59d30)
void AKConstraint::PostEditChange()
{
// Ghidra 0x59d30: if GIsEditor, call vtable[+0x80]; always call vtable[+0x188].
// Both are thiscall virtual dispatches through this's vtable.
guard(AKConstraint::PostEditChange);
typedef void (__thiscall *VFn)(AKConstraint*);
if (GIsEditor)
    ((VFn)(((DWORD*)*(DWORD*)this)[0x80/sizeof(DWORD)]))(this);
((VFn)(((DWORD*)*(DWORD*)this)[0x188/sizeof(DWORD)]))(this);
unguard;
}

IMPL_DIVERGE("Karma MeSDK not integrated: PostEditMove uses KU2METransform/KU2MEPosition/KME2UVecCopy to update constraint body transforms (0x5a710)")
void AKConstraint::PostEditMove()
{
guard(AKConstraint::PostEditMove);
unguard;
}

IMPL_MATCH("Engine.dll", 0x59dc0)
void AKConstraint::CheckForErrors()
{
// Ghidra 0x59dc0: call super, then warn if neither constraint actor is set.
AActor::CheckForErrors();
if (*(INT*)((BYTE*)this + 0x3C0) == 0 && *(INT*)((BYTE*)this + 0x3C4) == 0)
GWarn->Logf(TEXT("KConstraint which does not point to any Actors."));
}

IMPL_MATCH("Engine.dll", 0x5A410)
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
IMPL_DIVERGE("Karma MeSDK not integrated: preKarmaStep calls FUN_104935c0/FUN_10505fc0/FUN_10496720 in Karma SDK range (0x59c20)")
void AKHinge::preKarmaStep(float)
{
guard(AKHinge::preKarmaStep);
unguard;
}

IMPL_DIVERGE("Karma MeSDK not integrated: KUpdateConstraintParams calls FUN_104935c0/FUN_104961e0/FUN_10496120 in Karma SDK range (0x5a250)")
void AKHinge::KUpdateConstraintParams()
{
guard(AKHinge::KUpdateConstraintParams);
unguard;
}


// --- FKAggregateGeom ---
IMPL_MATCH("Engine.dll", 0x3cc00)
FKAggregateGeom::FKAggregateGeom(FKAggregateGeom const &Other)
{
// Ghidra 0x3cc00: no vtable; 4 TArrays at +0, +0xC, +0x18, +0x24
new ((BYTE*)this + 0x00) TArray<FKSphereElem>(*(const TArray<FKSphereElem>*)((const BYTE*)&Other + 0x00));
new ((BYTE*)this + 0x0C) TArray<FKBoxElem>(*(const TArray<FKBoxElem>*)((const BYTE*)&Other + 0x0C));
new ((BYTE*)this + 0x18) TArray<FKCylinderElem>(*(const TArray<FKCylinderElem>*)((const BYTE*)&Other + 0x18));
new ((BYTE*)this + 0x24) TArray<FKConvexElem>(*(const TArray<FKConvexElem>*)((const BYTE*)&Other + 0x24));
}

IMPL_MATCH("Engine.dll", 0x3caf0)
FKAggregateGeom::FKAggregateGeom()
{
// Ghidra 0x3caf0: calls FArray::FArray (TArray default ctor) at +0,+0xC,+0x18,+0x24.
// FKAggregateGeom has no named members; placement-new initialises each sub-array explicitly.
new ((BYTE*)this + 0x00) TArray<FKSphereElem>();
new ((BYTE*)this + 0x0C) TArray<FKBoxElem>();
new ((BYTE*)this + 0x18) TArray<FKCylinderElem>();
new ((BYTE*)this + 0x24) TArray<FKConvexElem>();
}

IMPL_MATCH("Engine.dll", 0x3cb90)
FKAggregateGeom::~FKAggregateGeom()
{
// Ghidra 0x3cb90: destroys the 4 TArrays in reverse construction order.
((TArray<FKConvexElem>*)  ((BYTE*)this + 0x24))->~TArray();
((TArray<FKCylinderElem>*)((BYTE*)this + 0x18))->~TArray();
((TArray<FKBoxElem>*)     ((BYTE*)this + 0x0C))->~TArray();
((TArray<FKSphereElem>*)  ((BYTE*)this + 0x00))->~TArray();
}

IMPL_MATCH("Engine.dll", 0x3cc80)
FKAggregateGeom& FKAggregateGeom::operator=(const FKAggregateGeom& Other)
{
// Ghidra 0x3cc80: 4 TArrays at +0,+0xC,+0x18,+0x24
*(TArray<FKSphereElem>*)((BYTE*)this + 0x00) = *(const TArray<FKSphereElem>*)((const BYTE*)&Other + 0x00);
*(TArray<FKBoxElem>*)((BYTE*)this + 0x0C) = *(const TArray<FKBoxElem>*)((const BYTE*)&Other + 0x0C);
*(TArray<FKCylinderElem>*)((BYTE*)this + 0x18) = *(const TArray<FKCylinderElem>*)((const BYTE*)&Other + 0x18);
*(TArray<FKConvexElem>*)((BYTE*)this + 0x24) = *(const TArray<FKConvexElem>*)((const BYTE*)&Other + 0x24);
return *this;
}

IMPL_MATCH("Engine.dll", 0x3cb60)
void FKAggregateGeom::EmptyElements()
{
// Ghidra 0x3cb60: calls TArray::Empty on each sub-array.
// Retail order: boxes (0x0C), convex (0x24), cylinders (0x18), spheres (0x00).
((TArray<FKBoxElem>*)     ((BYTE*)this + 0x0C))->Empty();
((TArray<FKConvexElem>*)  ((BYTE*)this + 0x24))->Empty();
((TArray<FKCylinderElem>*)((BYTE*)this + 0x18))->Empty();
((TArray<FKSphereElem>*)  ((BYTE*)this + 0x00))->Empty();
}

// Ghidra 0x4b50: sum of FArray::Num() for 4 TArrays at offsets 0x00, 0x0C, 0x18, 0x24.
IMPL_MATCH("Engine.dll", 0x4b50)
int FKAggregateGeom::GetElementCount()
{
INT* Counts = (INT*)this;
// TArray layout: Data(4), ArrayNum(4), ArrayMax(4) = 12 bytes each
// ArrayNum offsets: 0x04, 0x10, 0x1C, 0x28
return Counts[1] + Counts[4] + Counts[7] + Counts[10];
}


// --- FKBoxElem ---
IMPL_MATCH("Engine.dll", 0x4ab0)
FKBoxElem::FKBoxElem(float InSize)
{
// Ghidra 0x4ab0: FMatrix::FMatrix(this) + set TM+0x40/0x44/0x48 = InSize.
// C++ auto-calls TM.FMatrix() as member initialiser before this body.
X = InSize;
Y = InSize;
Z = InSize;
}

IMPL_MATCH("Engine.dll", 0x4ad0)
FKBoxElem::FKBoxElem(float InX, float InY, float InZ)
{
// Ghidra 0x4ad0: FMatrix::FMatrix(this) + set TM+0x40=InX, +0x44=InY, +0x48=InZ.
X = InX;
Y = InY;
Z = InZ;
}

IMPL_MATCH("Engine.dll", 0x4a60)
FKBoxElem::FKBoxElem()
{
// Ghidra 0x4a60: FMatrix::FMatrix(this) only; shared stub with FKCylinderElem/FKSphereElem default ctors.
// C++ auto-calls TM.FMatrix() as member initialiser; body is intentionally empty.
}

IMPL_MATCH("Engine.dll", 0x4b40)
FKBoxElem::~FKBoxElem()
{
// Ghidra 0x4b40: FMatrix::~FMatrix(this); shared stub with FKCylinderElem/FKSphereElem dtors.
// C++ auto-calls TM.~FMatrix() after this body; body is intentionally empty.
}

IMPL_MATCH("Engine.dll", 0x4b00)
FKBoxElem& FKBoxElem::operator=(const FKBoxElem& Other)
{
// Ghidra 0x4b00: loop copying 0x13 DWORDs (76 bytes = sizeof FKBoxElem).
appMemcpy( this, &Other, sizeof(FKBoxElem) );
return *this;
}


// --- FKConvexElem ---
IMPL_MATCH("Engine.dll", 0x27ce0)
FKConvexElem::FKConvexElem(FKConvexElem const &Other)
{
// Ghidra 0x27ce0: no vtable; 16 DWORDs at +0..+3F; TArray<FVector> at +40 (stride 12); TArray<INT> at +4C (stride 4)
appMemcpy(this, &Other, 0x40); // 16 DWORDs
new ((BYTE*)this + 0x40) TArray<FVector>(*(const TArray<FVector>*)((const BYTE*)&Other + 0x40));
new ((BYTE*)this + 0x4C) TArray<INT>(*(const TArray<INT>*)((const BYTE*)&Other + 0x4C));
}

IMPL_MATCH("Engine.dll", 0x27c20)
FKConvexElem::FKConvexElem()
{
// Ghidra 0x27c20: FMatrix::FMatrix(this) + FArray::FArray at +0x40 + FArray::FArray at +0x4C.
// FKConvexElem has no named members; explicit placement-new required for all sub-objects.
new ((void*)this)         FMatrix();
new ((BYTE*)this + 0x40)  TArray<FVector>();
new ((BYTE*)this + 0x4C)  TArray<INT>();
}

IMPL_MATCH("Engine.dll", 0x27c80)
FKConvexElem::~FKConvexElem()
{
// Ghidra 0x27c80: destroy TArray<INT> at +0x4C, then TArray<FVector> at +0x40, then FMatrix.
((TArray<INT>*)   ((BYTE*)this + 0x4C))->~TArray();
((TArray<FVector>*)((BYTE*)this + 0x40))->~TArray();
((FMatrix*)(void*)this)->~FMatrix();
}

IMPL_MATCH("Engine.dll", 0x27d50)
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
IMPL_MATCH("Engine.dll", 0x4b20)
FKCylinderElem::FKCylinderElem(float InRadius, float InLength)
{
// Ghidra 0x4b20: FMatrix::FMatrix(this) + set TM+0x40=InRadius, +0x44=InLength.
// C++ auto-calls TM.FMatrix() as member initialiser.
Radius = InRadius;
Length = InLength;
}

IMPL_MATCH("Engine.dll", 0x4a60)
FKCylinderElem::FKCylinderElem()
{
// Ghidra 0x4a60: FMatrix::FMatrix(this) only; shared stub with FKBoxElem/FKSphereElem default ctors.
}

IMPL_MATCH("Engine.dll", 0x4b40)
FKCylinderElem::~FKCylinderElem()
{
// Ghidra 0x4b40: FMatrix::~FMatrix(this); shared stub with FKBoxElem/FKSphereElem dtors.
}

IMPL_MATCH("Engine.dll", 0x9810)
FKCylinderElem& FKCylinderElem::operator=(const FKCylinderElem& Other)
{
// Ghidra 0x9810: loop copying 0x12 DWORDs (72 bytes = sizeof FKCylinderElem).
appMemcpy( this, &Other, sizeof(FKCylinderElem) );
return *this;
}


// --- FKSphereElem ---
IMPL_MATCH("Engine.dll", 0x4a70)
FKSphereElem::FKSphereElem(float InRadius)
{
// Ghidra 0x4a70: FMatrix::FMatrix(this) + set TM+0x40=InRadius.
// C++ auto-calls TM.FMatrix() as member initialiser.
Radius = InRadius;
}

IMPL_MATCH("Engine.dll", 0x4a60)
FKSphereElem::FKSphereElem()
{
// Ghidra 0x4a60: FMatrix::FMatrix(this) only; shared stub with FKBoxElem/FKCylinderElem default ctors.
}

IMPL_MATCH("Engine.dll", 0x4b40)
FKSphereElem::~FKSphereElem()
{
// Ghidra 0x4b40: FMatrix::~FMatrix(this); shared stub with FKBoxElem/FKCylinderElem dtors.
}

IMPL_MATCH("Engine.dll", 0x4a90)
FKSphereElem& FKSphereElem::operator=(const FKSphereElem& Other)
{
// Ghidra 0x4a90: loop copying 0x11 DWORDs (68 bytes = sizeof FKSphereElem).
appMemcpy( this, &Other, sizeof(FKSphereElem) );
return *this;
}


// --- UKMeshProps ---
IMPL_DIVERGE("FKAggregateGeom serialization helpers (FUN_10322930/ab0/c70/4f570) not available; TArray at +0x50 not serialized (Ghidra 0x501b0 serializes it)")
void UKMeshProps::Serialize(FArchive& Ar)
{
// Ghidra 0x501b0: UObject::Serialize + 9 FLOAT fields at +0x2C..+0x4C (mass props),
// then calls FUN_10350130(Ar, this+0x50) to serialize the FKAggregateGeom at +0x50.
// DIVERGENCE: FUN_10350130 is an inline FKAggregateGeom serializer using private TArray
// serialization helpers (FUN_10322930 etc.) that are not yet available; omitted.
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
}

IMPL_DIVERGE("Karma mesh props draw - editor visualization requires Karma SDK")
void UKMeshProps::Draw(FRenderInterface *,int)
{
guard(UKMeshProps::Draw);
unguard;
}


// --- UKarmaParams ---
IMPL_DIVERGE("Karma MeSDK not integrated: PostEditChange updates live Karma body params via FUN_104c3660 and MdtBody API (0x62210)")
void UKarmaParams::PostEditChange()
{
guard(UKarmaParams::PostEditChange);
unguard;
}
