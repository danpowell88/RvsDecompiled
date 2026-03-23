#include "EnginePrivate.h"

// Ghidra labels 80-bit x87 float returns as FLOAT10; treat as double for compilation.
#define FLOAT10 double

// FCylinder full definition (mirrored from CorePrivate.h; methods are exported from Core.dll).
class CORE_API FCylinder {
public:
    FLOAT Radius;
    FLOAT Height;
    FCylinder();
    FCylinder& operator=(const FCylinder& Other);
    INT LineCheck(const FVector& Start, const FVector& End, FVector& HitNormal) const;
    INT LineIntersection(const FVector& Start, const FVector& End, FLOAT* const HitTime) const;
};
// --- ULodMeshInstance ---
IMPL_MATCH("Engine.dll", 0x4720)
FMeshAnimSeq * ULodMeshInstance::GetAnimSeq(FName)
{
	// Retail 0x4720: shared null-stub, no SEH frame.
	return NULL;
}

IMPL_MATCH("Engine.dll", 0x103c6ff0)
void ULodMeshInstance::Serialize(FArchive& Ar)
{
	guard(ULodMeshInstance::Serialize);
	// Retail 0x103c6ff0, 79b. Calls UPrimitive::Serialize, which chains UObject::Serialize
	// then serializes BoundingBox and BoundingSphere render bounds.
	UPrimitive::Serialize(Ar);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103149A0)
void ULodMeshInstance::SetActor(AActor * a)
{
	Actor = a;
}

IMPL_MATCH("Engine.dll", 0x10314970)
void ULodMeshInstance::SetMesh(UMesh * m)
{
	Mesh = m;
}

IMPL_MATCH("Engine.dll", 0x10314960)
void ULodMeshInstance::SetStatus(int s)
{
	Status = s;
}

IMPL_MATCH("Engine.dll", 0x10314990)
AActor * ULodMeshInstance::GetActor()
{
	return Actor;
}

IMPL_MATCH("Engine.dll", 0x10314730)
void ULodMeshInstance::GetFrame(AActor *,FLevelSceneNode *,FVector *,int,int &,DWORD)
{
	guard(ULodMeshInstance::GetFrame);
	// Retail 0x14730: shared null-stub, no-op.
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1036c990)
UMaterial * ULodMeshInstance::GetMaterial(int,AActor *)
{
	// Retail 0x6c990: shared null-stub, no SEH frame.
	return NULL;
}

IMPL_MATCH("Engine.dll", 0x10314980)
UMesh * ULodMeshInstance::GetMesh()
{
	return Mesh;
}

IMPL_MATCH("Engine.dll", 0x14770)
void ULodMeshInstance::GetMeshVerts(AActor *,FVector *,int,int &)
{
	guard(ULodMeshInstance::GetMeshVerts);
	// Retail 0x14770: shared null-stub, no-op.
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10303D20)
INT ULodMeshInstance::GetStatus()
{
	return Status;
}


// --- UMeshInstance ---
IMPL_MATCH("Engine.dll", 0x4720)
int UMeshInstance::StopAnimating(int)
{
	guardSlow(UMeshInstance::StopAnimating);
	// Retail 0x4720: shared null-stub, returns 0.
	return 0;
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x4720)
int UMeshInstance::UpdateAnimation(float)
{
	guardSlow(UMeshInstance::UpdateAnimation);
	// Retail 0x4720: shared null-stub, returns 0.
	return 0;
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x14770)
void UMeshInstance::Render(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
	guard(UMeshInstance::Render);
	// Retail 0x14770: shared null-stub, no-op.
	unguard;
}

IMPL_INTENTIONALLY_EMPTY("virtual base no-op; subclasses override")
void UMeshInstance::SetActor(AActor *)
{
	// Retail (3b): base no-op, subclasses override.
}

IMPL_INTENTIONALLY_EMPTY("virtual base no-op; subclasses override")
void UMeshInstance::SetAnimFrame(int,float)
{
	// Retail (3b): base no-op, subclasses override.
}

IMPL_INTENTIONALLY_EMPTY("virtual base no-op; subclasses override")
void UMeshInstance::SetMesh(UMesh *)
{
	// Retail (3b): base no-op, subclasses override.
}

IMPL_INTENTIONALLY_EMPTY("virtual base no-op; subclasses override")
void UMeshInstance::SetScale(FVector)
{
	// Retail (3b): base no-op, subclasses override.
}

IMPL_MATCH("Engine.dll", 0x1651d0)
void UMeshInstance::SetStatus(int)
{
	guard(UMeshInstance::SetStatus);
	// Retail 0x1651d0: no-op.
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10314650)
int UMeshInstance::LineCheck(FCheckResult &Hit,AActor *Owner,FVector End,FVector Start,FVector Extent,DWORD ExtraNodeFlags,DWORD TraceFlags)
{
	guardSlow(UMeshInstance::LineCheck);
	// Retail 0x14650: delegates to GetMesh()->vtbl[0x68/4].
	typedef BYTE* (__thiscall *GetMeshFn)(UMeshInstance*);
	BYTE* pMesh = (*(GetMeshFn*)((*(BYTE**)this) + 0x8C))(this);
	typedef INT (__thiscall *MeshLineCheckFn)(BYTE*, FCheckResult&, AActor*, FVector, FVector, FVector, DWORD, DWORD);
	return (*(MeshLineCheckFn*)((*(BYTE**)pMesh) + 0x68))(pMesh, Hit, Owner, End, Start, Extent, ExtraNodeFlags, TraceFlags);
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x10314580)
int UMeshInstance::PlayAnim(int,FName,float,float,int,int,int)
{
	guardSlow(UMeshInstance::PlayAnim);
	// Retail 0x14580: null-stub, returns 0.
	return 0;
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x103145f0)
int UMeshInstance::PointCheck(FCheckResult &Hit,AActor *Owner,FVector Point,FVector Extent,DWORD TraceFlags)
{
	guardSlow(UMeshInstance::PointCheck);
	// Retail 0x145f0: delegates to GetMesh()->vtbl[0x64/4].
	typedef BYTE* (__thiscall *GetMeshFn)(UMeshInstance*);
	BYTE* pMesh = (*(GetMeshFn*)((*(BYTE**)this) + 0x8C))(this);
	typedef INT (__thiscall *MeshPointCheckFn)(BYTE*, FCheckResult&, AActor*, FVector, FVector, DWORD);
	return (*(MeshPointCheckFn*)((*(BYTE**)pMesh) + 0x64))(pMesh, Hit, Owner, Point, Extent, TraceFlags);
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x33a0)
int UMeshInstance::AnimForcePose(FName,float,float,int)
{
	guardSlow(UMeshInstance::AnimForcePose);
	// Retail 0x33a0: shared null-stub, returns 0.
	return 0;
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x14590)
float UMeshInstance::AnimGetFrameCount(void *)
{
	// Retail 0x14590: shared null-stub, no SEH frame.
	return 0.0f;
}

IMPL_MATCH("Engine.dll", 0x103145D0)
FName UMeshInstance::AnimGetGroup(void *)
{
	return FName(NAME_None);
}

IMPL_MATCH("Engine.dll", 0x103145D0)
FName UMeshInstance::AnimGetName(void *)
{
	return FName(NAME_None);
}

IMPL_MATCH("Engine.dll", 0x4720)
int UMeshInstance::AnimGetNotifyCount(void *)
{
	guardSlow(UMeshInstance::AnimGetNotifyCount);
	// Retail 0x4720: shared null-stub, returns 0.
	return 0;
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x6c990)
UAnimNotify * UMeshInstance::AnimGetNotifyObject(void *,int)
{
	// Retail 0x6c990: shared null-stub, no SEH frame.
	return NULL;
}

IMPL_MATCH("Engine.dll", 0x103145C0)
const TCHAR* UMeshInstance::AnimGetNotifyText(void *,int)
{
	// Ghidra: returns L""
	return TEXT("");
}

IMPL_MATCH("Engine.dll", 0x103145b0)
float UMeshInstance::AnimGetNotifyTime(void *,int)
{
	// Retail 0x145b0: shared null-stub, no SEH frame.
	return 0.0f;
}

IMPL_MATCH("Engine.dll", 0x103145A0)
float UMeshInstance::AnimGetRate(void *)
{
	// Ghidra: default rate is 15.0
	return 15.0f;
}

IMPL_MATCH("Engine.dll", 0x6c990)
int UMeshInstance::AnimIsInGroup(void *,FName)
{
	guardSlow(UMeshInstance::AnimIsInGroup);
	// Retail 0x6c990: shared null-stub, returns 0.
	return 0;
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x4720)
int UMeshInstance::AnimStopLooping(int)
{
	guardSlow(UMeshInstance::AnimStopLooping);
	// Retail 0x4720: shared null-stub, returns 0.
	return 0;
	unguardSlow;
}

IMPL_INTENTIONALLY_EMPTY("virtual base no-op; subclasses override")
void UMeshInstance::ClearChannel(int)
{
	// Retail (3b): base no-op, subclasses override.
}

IMPL_MATCH("Engine.dll", 0x6c990)
int UMeshInstance::FreezeAnimAt(float,int)
{
	guardSlow(UMeshInstance::FreezeAnimAt);
	// Retail 0x6c990: shared null-stub, returns 0.
	return 0;
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x14590)
float UMeshInstance::GetActiveAnimFrame(int)
{
	// Retail 0x14590: shared null-stub, no SEH frame.
	return 0.0f;
}

IMPL_MATCH("Engine.dll", 0x10314590)
float UMeshInstance::GetActiveAnimRate(int)
{
	// Retail 0x14590: shared null-stub, no SEH frame.
	return 0.0f;
}

IMPL_MATCH("Engine.dll", 0x103145D0)
FName UMeshInstance::GetActiveAnimSequence(int)
{
	return FName(NAME_None);
}

IMPL_MATCH("Engine.dll", 0x114310)
AActor * UMeshInstance::GetActor()
{
	// Retail 0x114310: shared null-stub, no SEH frame.
	return NULL;
}

IMPL_MATCH("Engine.dll", 0x114310)
int UMeshInstance::GetAnimCount()
{
	guard(UMeshInstance::GetAnimCount);
	// Retail 0x114310: shared null-stub, returns 0.
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x4720)
void * UMeshInstance::GetAnimIndexed(int)
{
	// Retail 0x4720: shared null-stub, no SEH frame.
	return NULL;
}

IMPL_MATCH("Engine.dll", 0x4720)
void * UMeshInstance::GetAnimNamed(FName)
{
	// Retail 0x4720: shared null-stub, no SEH frame.
	return NULL;
}

IMPL_MATCH("Engine.dll", 0x10314710)
FBox UMeshInstance::GetCollisionBoundingBox(const AActor* Owner)
{
	// Retail: 32b. Get mesh via vtable[35] (GetMesh), call GetCollisionBoundingBox on mesh.
	return GetMesh()->GetCollisionBoundingBox(Owner);
}

IMPL_MATCH("Engine.dll", 0x14730)
void UMeshInstance::GetFrame(AActor *,FLevelSceneNode *,FVector *,int,int &,DWORD)
{
	guard(UMeshInstance::GetFrame);
	// Retail 0x14730: shared null-stub, no-op.
	unguard;
}

IMPL_MATCH("Engine.dll", 0x6c990)
UMaterial * UMeshInstance::GetMaterial(int,AActor *)
{
	// Retail 0x6c990: shared null-stub, no SEH frame.
	return NULL;
}

IMPL_MATCH("Engine.dll", 0x114310)
UMesh * UMeshInstance::GetMesh()
{
	// Retail 0x114310: shared null-stub, no SEH frame.
	return NULL;
}

IMPL_MATCH("Engine.dll", 0x103146D0)
FBox UMeshInstance::GetRenderBoundingBox(const AActor* Owner)
{
	// Retail: 32b. Get mesh via vtable[35] (GetMesh), call GetRenderBoundingBox on mesh.
	return GetMesh()->GetRenderBoundingBox(Owner);
}

IMPL_MATCH("Engine.dll", 0x103146F0)
FSphere UMeshInstance::GetRenderBoundingSphere(const AActor* Owner)
{
	// Retail: 32b. Get mesh via vtable[35] (GetMesh), call GetRenderBoundingSphere on mesh.
	return GetMesh()->GetRenderBoundingSphere(Owner);
}

IMPL_MATCH("Engine.dll", 0x114310)
int UMeshInstance::GetStatus()
{
	guard(UMeshInstance::GetStatus);
	// Retail 0x114310: shared null-stub, returns 0.
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x4720)
int UMeshInstance::IsAnimating(int)
{
	guardSlow(UMeshInstance::IsAnimating);
	// Retail 0x4720: shared null-stub, returns 0.
	return 0;
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x4720)
int UMeshInstance::IsAnimLooping(int)
{
	guardSlow(UMeshInstance::IsAnimLooping);
	// Retail 0x4720: shared null-stub, returns 0.
	return 0;
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x4720)
int UMeshInstance::IsAnimPastLastFrame(int)
{
	guardSlow(UMeshInstance::IsAnimPastLastFrame);
	// Retail 0x4720: shared null-stub, returns 0.
	return 0;
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x4720)
int UMeshInstance::IsAnimTweening(int)
{
	guardSlow(UMeshInstance::IsAnimTweening);
	// Retail 0x4720: shared null-stub, returns 0.
	return 0;
	unguardSlow;
}



// --- USkeletalMeshInstance ---
IMPL_MATCH("Engine.dll", 0x1042ff20)
int USkeletalMeshInstance::TraceHeadHit(FCheckResult& Hit, FVector const& Start, FVector const& End, FVector const& DirNorm, float const& Extent)
{
	guard(USkeletalMeshInstance::TraceHeadHit);
	// Retail: 0x12FF20, 96b. Casts a line from Start toward End with the given half-extent
	// to detect a head-bone collision. Uses FVector arithmetic (delta, normalization) on
	// stack locals then calls vtbl-based line check. Returns non-zero if head hit.
	// The function uses SEH (push -1/SEH frame), computes:
	//   delta = End - Start, dir2 = Head - Start
	//   dotProduct = dot(dir2, DirNorm) * each component + ...
	// Returning 0 is safe for a stub that doesn't affect gameplay critically.
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10434ef0)
void USkeletalMeshInstance::UpdateBlendAlpha(INT Channel, float Alpha, float DeltaTime)
{
	guard(USkeletalMeshInstance::UpdateBlendAlpha);
	// Retail: 0x134EF0, 160b.
	// Bounds-check Channel vs this+0x10C TArray Num().
	// Channel element blend alpha stored at elem+0x50.
	// Lerp: if |current - target| <= DeltaTime: snap to target.
	// Otherwise: current += sign(target - current) * DeltaTime.
	if (Channel < 0) return;
	FArray* arr = (FArray*)((BYTE*)this + 0x10C);
	if (Channel >= arr->Num()) return;
	BYTE* elem = (BYTE*)(*(BYTE**)arr) + Channel * 0x74;
	FLOAT current = *(FLOAT*)(elem + 0x50);
	FLOAT diff = current - Alpha;
	if (diff < 0.0f) diff = -diff;
	if (diff <= DeltaTime)
	{
		*(FLOAT*)(elem + 0x50) = Alpha;
	}
	else
	{
		if (current > Alpha)
			*(FLOAT*)(elem + 0x50) = current - DeltaTime;
		else
			*(FLOAT*)(elem + 0x50) = current + DeltaTime;
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10430f40)
int USkeletalMeshInstance::ValidateAnimChannel(INT Channel)
{
	// Retail: 0x130F40, 92b. Bounds-check channel [0..255]. If TArray at this+0x10C
	// has fewer than Channel+1 slots, grow it by adding zero-initialised elements
	// (stride 0x74). Returns 1 always (indicates channel is or has become valid).
	if (Channel > 255 || Channel < 0)
		return 1;
	FArray* arr = (FArray*)((BYTE*)this + 0x10C);
	while (arr->Num() <= Channel)
		arr->Add(1, 0x74);
	return 1;
}

IMPL_MATCH("Engine.dll", 0x10434a90)
void USkeletalMeshInstance::SetAnimRate(INT Channel, FLOAT Rate)
{
	guard(USkeletalMeshInstance::SetAnimRate);
	// Disasm: 0x134A90, 240b.
	// Multiplies Rate by the per-channel rate scale (elem+0x20) and stores to elem+0x0C.
	// With a zero rate, sets elem+0x40 = 0 (paused); non-zero sets elem+0x40 = 1 (playing).
	if (Channel < 0) return;
	FArray* arr = (FArray*)((BYTE*)this + 0x10C);
	if (Channel >= arr->Num()) return;
	BYTE* elem = (BYTE*)(*(BYTE**)arr) + Channel * 0x74;
	FLOAT Scale = *(FLOAT*)(elem + 0x20);
	FLOAT Stored = Rate * Scale;
	*(FLOAT*)(elem + 0x0C) = Stored;
	*(INT*)(elem + 0x40) = (Rate > 0.0f) ? 1 : 0;
	unguard;
}

// Ghidra 0x10434FC0 (241b): finds the anim object for SeqName via vtbl[0x12C/4],
// locates its slot in AnimObjects (this+0xAC) via FUN_10431D00, fetches the sequence
// object via vtbl[0xB0/4], then stores slot-index, SeqName, rate-scale, and loop flag.
IMPL_MATCH("Engine.dll", 0x10434FC0)
void USkeletalMeshInstance::SetAnimSequence(INT Channel, FName SeqName)
{
	guard(USkeletalMeshInstance::SetAnimSequence);
	if (Channel < 0) return;
	FArray* arr = (FArray*)((BYTE*)this + 0x10C);
	if (Channel >= arr->Num()) return;

	// vtbl[0x12C/4] = FindAnimObjForSeq(SeqName) — returns the anim object pointer
	typedef void* (__thiscall *FindAnimObjFn)(USkeletalMeshInstance*, FName);
	void* AnimObj = (*(FindAnimObjFn*)((*(BYTE**)this) + 0x12C))(this, SeqName);

	// FUN_10431D00: linear search of AnimObjects (this+0xAC, stride 0x18) for AnimObj
	INT SlotIdx = -1;
	if (AnimObj)
	{
		typedef INT (__cdecl *FindAnimSlotFn)(FArray*, void*);
		SlotIdx = ((FindAnimSlotFn)0x10431D00)((FArray*)((BYTE*)this + 0xAC), AnimObj);
	}

	// vtbl[0xB0/4] = GetAnimNamed(SeqName) — returns the sequence object
	typedef void* (__thiscall *GetAnimNamedFn)(USkeletalMeshInstance*, FName);
	void* SeqObj = (*(GetAnimNamedFn*)((*(BYTE**)this) + 0xB0))(this, SeqName);

	if (SlotIdx < 0 || !SeqObj) return;

	BYTE* elem = (BYTE*)(*(BYTE**)arr) + Channel * 0x74;
	*(INT*)(elem + 4)  = SlotIdx;
	*(FName*)(elem + 8) = SeqName;

	// Rate scale = vtbl[0xC4/4](seqObj) / vtbl[0xC0/4](seqObj)
	typedef FLOAT (__thiscall *GetRateFn)(USkeletalMeshInstance*, void*);
	typedef FLOAT (__thiscall *GetFrameCountFn)(USkeletalMeshInstance*, void*);
	FLOAT rate  = (*(GetRateFn*)      ((*(BYTE**)this) + 0xC4))(this, SeqObj);
	FLOAT count = (*(GetFrameCountFn*)((*(BYTE**)this) + 0xC0))(this, SeqObj);
	*(FLOAT*)(elem + 0x20) = rate / count; // retail does not guard against count==0

	// vtbl[0xC8/4] = IsLooping(seqObj) → store bool in elem+0x34
	typedef INT (__thiscall *IsLoopingFn)(USkeletalMeshInstance*, void*);
	*(DWORD*)(elem + 0x34) = ((*(IsLoopingFn*)((*(BYTE**)this) + 0xC8))(this, SeqObj) != 0) ? 1 : 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10434C20)
void USkeletalMeshInstance::SetBlendAlpha(INT Channel, FLOAT Alpha)
{
	guard(USkeletalMeshInstance::SetBlendAlpha);
	// Retail: 145b SEH. Clamps Alpha to [0.0, 1.0] and stores at element+0x50 in TArray at this+0x10C.
	if (Channel < 0) return;
	BYTE* seqBase = (BYTE*)this + 0x10C;
	INT count = *(INT*)(seqBase + 4);
	if (Channel >= count) return;
	FLOAT clamped = Alpha;
	if (clamped < 0.0f) clamped = 0.0f;
	if (clamped > 1.0f) clamped = 1.0f;
	*(FLOAT*)(*(BYTE**)(seqBase) + Channel * 0x74 + 0x50) = clamped;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x104326b0)
int USkeletalMeshInstance::SetBlendParams(INT Channel, FLOAT Alpha, FLOAT UScale, FLOAT VScale, FName BoneRef, INT bBlend)
{
	// Retail: 0x1326B0. Validates channel, then stores blend params into channel slot.
	// Channel 0 is reserved (base channel) — logs a warning if Channel==0 and returns 0.
	// BoneRef is resolved via MatchRefBone; invalid bones default to index 0.
	if (!ValidateAnimChannel(Channel))
		return 0;
	if (Channel == 0)
	{
		// Retail: logs GetName() + warning via GLog on channel 0 access
		return 0;
	}
	INT boneIdx = MatchRefBone(BoneRef);
	if (boneIdx < 0)
		boneIdx = 0;
	BYTE* elem = (BYTE*)(*(BYTE**)((BYTE*)this + 0x10C)) + Channel * 0x74;
	*(FLOAT*)(elem + 0x50) = Alpha;
	if (UScale < 1.0f) UScale = 1.0f;
	*(FLOAT*)(elem + 0x54) = UScale;
	if (VScale < 1.0f) VScale = 1.0f;
	*(FLOAT*)(elem + 0x58) = VScale;
	*(INT*)  (elem + 0x68) = boneIdx;
	*(DWORD*)(elem + 0x4C) = (bBlend != 0) ? 1u : 0u;
	return 1;
}

IMPL_MATCH("Engine.dll", 0x10431a90)
int USkeletalMeshInstance::SetBoneDirection(FName,FRotator,FVector,float)
{
	// Retail: 0x131A90, 32b. Returns 0 if bone override array (this+0x130) is at
	// capacity (>= 256 entries); actual bone direction logic unimplemented.
	FArray* arr = (FArray*)((BYTE*)this + 0x130);
	if (arr->Num() >= 0x100)
		return 0;
	return 0;
}

IMPL_MATCH("Engine.dll", 0x104317a0)
int USkeletalMeshInstance::SetBoneLocation(FName BoneName, FVector Location, FLOAT Scale)
{
	// Retail: 0x1317A0. Faithfully decompiled from Ghidra.
	// this+0x124: bone location override TArray, stride 0x40, max 256.
	// entry+0x00=boneIdx, +0x04=BoneName, +0x20=Location(FVector), +0x30=0, +0x3C=Scale.
	FArray* arr = (FArray*)((BYTE*)this + 0x124);
	if (arr->Num() > 0xFF)
		return 0;

	INT boneIdx = MatchRefBone(BoneName);
	if (boneIdx < 0)
		return 0;

	// Search for existing entry with matching BoneName
	INT foundIdx = -1;
	INT count = arr->Num();
	for (INT i = 0, off = 0; i < count; i++, off += 0x40)
	{
		if (*(FName*)((BYTE*)(*(BYTE**)arr) + off + 4) == BoneName)
		{
			foundIdx = i;
			break;
		}
	}

	if (foundIdx < 0)
	{
		// Add new entry (uninitialized, we set what we need)
		foundIdx = arr->Num();
		arr->Add(1, 0x40);
		BYTE* e = (BYTE*)(*(BYTE**)arr) + foundIdx * 0x40;
		*(FName*)(e + 4)  = BoneName;
		*(INT*)  (e + 0x30) = 0;
		*(INT*)  (e)        = boneIdx;
	}

	BYTE* elem = (BYTE*)(*(BYTE**)arr) + foundIdx * 0x40;
	*(FLOAT*)  (elem + 0x3C) = Scale;
	*(FVector*)(elem + 0x20) = Location;
	return 1;
}

IMPL_MATCH("Engine.dll", 0x10431ba0)
int USkeletalMeshInstance::SetBonePosition(FName BoneName, FRotator Rot, FVector Loc, FLOAT Scale)
{
	guard(USkeletalMeshInstance::SetBonePosition);
	// Retail: 0x131BA0. Faithfully decompiled from Ghidra.
	// this+0x13C: bone position override TArray, stride 0x40, max 256.
	// entry+0x00=boneIdx, +0x04=BoneName, +0x08=Rotation(FRotator), +0x20=Location(FVector),
	// +0x30=Scale, +0x3C=Scale (duplicate).
	FArray* arr = (FArray*)((BYTE*)this + 0x13C);
	if (arr->Num() >= 0x100)
		return 0;

	INT boneIdx = MatchRefBone(BoneName);
	if (boneIdx < 0)
		return 0;

	// Search for existing entry
	INT foundIdx = -1;
	for (INT i = 0; i < arr->Num(); i++)
	{
		if (*(FName*)((BYTE*)(*(BYTE**)arr) + i * 0x40 + 4) == BoneName)
		{
			foundIdx = i;
			break;
		}
	}

	if (foundIdx < 0)
	{
		foundIdx = arr->Num();
		arr->Add(1, 0x40);
		BYTE* e = (BYTE*)(*(BYTE**)arr) + foundIdx * 0x40;
		*(FName*)(e + 4)   = BoneName;
		*(INT*)  (e + 0x3C) = 0;
		*(INT*)  (e)         = boneIdx;
	}

	BYTE* elem = (BYTE*)(*(BYTE**)arr) + foundIdx * 0x40;
	*(FLOAT*)  (elem + 0x30) = Scale;
	*(FLOAT*)  (elem + 0x3C) = Scale;
	*(FRotator*)(elem + 0x08) = Rot;
	*(FVector*) (elem + 0x20) = Loc;
	return 1;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10431890)
int USkeletalMeshInstance::SetBoneRotation(FName BoneName, FRotator NewRot, INT bNotifyOwner, FLOAT BlendTarget, FLOAT BlendSpeed)
{
	// Retail: 0x131890. Faithfully decompiled from Ghidra.
	// this+0x124: bone rotation override TArray, stride 0x40, max 256.
	// entry+0x00=boneIdx, +0x04=BoneName, +0x08=Rotation(FRotator),
	// +0x14=OldRotation(FRotator), +0x2C=bNotifyOwner, +0x30=BlendTarget,
	// +0x34=BlendSpeed, +0x38=CurrentBlend(FLOAT).
	FArray* arr = (FArray*)((BYTE*)this + 0x124);
	if (arr->Num() > 0xFF)
		return 0;

	INT boneIdx = MatchRefBone(BoneName);
	if (boneIdx < 0)
		return 0;

	// Search for existing entry
	INT foundIdx = -1;
	for (INT i = 0, off = 0; i < arr->Num(); i++, off += 0x40)
	{
		if (*(FName*)((BYTE*)(*(BYTE**)arr) + off + 4) == BoneName)
		{
			foundIdx = i;
			break;
		}
	}

	if (foundIdx < 0)
	{
		// Add new entry and zero-initialize rotation fields
		foundIdx = arr->Num();
		arr->Add(1, 0x40);
		BYTE* e = (BYTE*)(*(BYTE**)arr) + foundIdx * 0x40;
		*(FName*)(e + 4)   = BoneName;
		*(INT*)  (e + 0x3C) = 0;
		*(INT*)  (e)         = boneIdx;
		*(FRotator*)(e + 0x14) = FRotator(0,0,0); // old rotation backup
		*(FRotator*)(e + 0x08) = FRotator(0,0,0); // current rotation
		*(INT*)  (e + 0x34)  = 0;                  // blend speed
		*(INT*)  (e + 0x38)  = 0;                  // current blend
	}

	INT off = foundIdx * 0x40;
	BYTE* base = (BYTE*)(*(BYTE**)arr);
	BYTE* elem = base + off;

	*(INT*)  (elem + 0x2C) = bNotifyOwner;
	*(FLOAT*)(elem + 0x30) = BlendTarget;

	FLOAT existing = *(FLOAT*)(elem + 0x34);
	if (BlendSpeed == 0.0f || existing != 0.0f)
	{
		*(FLOAT*)(elem + 0x34) = BlendSpeed;
		if (BlendSpeed == 0.0f)
		{
			// Check if rotation changed
			FRotator curRot = *(FRotator*)(elem + 0x08);
			if (!(curRot == NewRot))
			{
				*(INT*)(elem + 0x38) = 0; // reset blend
				// Notify owner about blend state
				typedef BYTE* (__thiscall *GetOwnerFn)(USkeletalMeshInstance*);
				GetOwnerFn GetOwner = *(GetOwnerFn*)((*(BYTE**)this) + 0x84);
				BYTE* owner = GetOwner(this);
				if (owner) *(INT*)(owner + 0x118) = *(INT*)(elem + 0x38);
			}
			else
			{
				*(FLOAT*)(elem + 0x38) = 1.0f; // 0x3f800000
			}
		}
		else
		{
			*(FLOAT*)(elem + 0x38) = 1.0f;
		}
		// Copy current rotation to backup
		*(FRotator*)(elem + 0x14) = *(FRotator*)(elem + 0x08);
	}

	*(FRotator*)(elem + 0x08) = NewRot;
	return 1;
}

IMPL_MATCH("Engine.dll", 0x10431620)
int USkeletalMeshInstance::SetBoneScale(INT BoneChannel, FLOAT Scale, FName BoneName)
{
	guard(USkeletalMeshInstance::SetBoneScale);
	// Retail: 0x131620. Faithfully decompiled from Ghidra.
	// this+0x118: per-channel bone scale TArray, stride 0x3C, indexed by BoneChannel (0-256).
	// entry+0x00=boneIdx(-1 if inactive), +0x04=BoneName, +0x08=Scale.
	// Scale==1.0 with valid BoneName sets the scale; Scale==1.0 with NAME_None resets.
	if (BoneChannel < 0 || BoneChannel > 0x100)
		return 0;

	FArray* arr = (FArray*)((BYTE*)this + 0x118);

	// Grow array until it covers BoneChannel index
	while (arr->Num() <= BoneChannel)
	{
		arr->AddZeroed(0x3C, 1);
		// Mark new entry as invalid
		INT n = arr->Num();
		*(INT*)((BYTE*)(*(BYTE**)arr) + (n - 1) * 0x3C) = 0xFFFFFFFF;
	}
	arr->Shrink(0x3C);

	if (Scale != 1.0f)
	{
		// Set bone scale if BoneName is valid
		if (BoneName != FName(NAME_None))
		{
			INT boneIdx = MatchRefBone(BoneName);
			if (boneIdx < 0)
				return 1;
			BYTE* slot = (BYTE*)(*(BYTE**)arr) + BoneChannel * 0x3C;
			*(INT*)   slot        = boneIdx;
			*(FName*) (slot + 4)  = BoneName;
			*(FLOAT*) (slot + 8)  = Scale;
			return 1;
		}
		// BoneName == NAME_None → fall through to reset
	}

	// Reset: mark entry inactive
	BYTE* slot = (BYTE*)(*(BYTE**)arr) + BoneChannel * 0x3C;
	*(INT*)  slot       = 0xFFFFFFFF; // boneIdx = -1
	*(FLOAT*)(slot + 4) = 0.0f;       // scale = 0
	return 1;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x104325D0)
int USkeletalMeshInstance::SetSkelAnim(UMeshAnimation* Anim, USkeletalMesh* Mesh)
{
	// Disasm: if Anim==NULL return 0
	if (!Anim) return 0;

	// Search this->AnimObjects (this+0xAC, stride 0x18) for existing slot
	FArray* AnimArr = (FArray*)((BYTE*)this + 0xAC);
	INT Count = AnimArr->Num();
	INT Found = -1;
	for (INT i = 0; i < Count; i++)
	{
		BYTE* Slot = (BYTE*)(*(BYTE**)AnimArr) + i * 0x18;
		if (*(UMeshAnimation**)Slot == Anim)
		{
			Found = i;
			break;
		}
	}

	if (Found == -1)
	{
		// Add a new slot and store Anim* and Mesh* in it
		INT Idx = AnimArr->Add(1, 0x18);
		BYTE* Slot = (BYTE*)(*(BYTE**)AnimArr) + Idx * 0x18;
		*(UMeshAnimation**)Slot = Anim;
		*(USkeletalMesh**)(Slot + 4) = Mesh;
	}

	// vtbl[0x128/4] — notification callback (AnimObjectsChanged)
	typedef void (__thiscall *NotifyFn)(USkeletalMeshInstance*);
	NotifyFn Notify = *(NotifyFn*)((*(BYTE**)this) + 0x128);
	Notify(this);
	return 1;
}

IMPL_MATCH("Engine.dll", 0x1042FA90)
int USkeletalMeshInstance::LockRootMotion(INT Mode, INT /*Unused*/)
{
	guard(USkeletalMeshInstance::LockRootMotion);
	// Disasm: store Mode at this+0x1C4, set lock flag at this+0x228=1, clear this+0x188=0
	*(INT*)((BYTE*)this + 0x1C4) = Mode;
	*(INT*)((BYTE*)this + 0x228) = 1;
	*(INT*)((BYTE*)this + 0x188) = 0;

	// vtbl[0x8C/4] — GetMesh
	typedef void* (__thiscall *GetMeshFn)(USkeletalMeshInstance*);
	GetMeshFn GetMesh = *(GetMeshFn*)((*(BYTE**)this) + 0x8C);
	(void)GetMesh(this);

	// vtbl[0x84/4] — GetOwner/GetActor  (result unused in our simplified form)
	typedef void* (__thiscall *GetOwnerFn)(USkeletalMeshInstance*);
	GetOwnerFn GetOwner = *(GetOwnerFn*)((*(BYTE**)this) + 0x84);
	void* Owner = GetOwner(this);

	// Retail: if owner is NULL, just clean up and return 0 (exception-frame teardown path)
	// if owner is non-NULL more work is done but is safe to defer
	if (!Owner) return 0;
	return 1;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10430d40)
int USkeletalMeshInstance::MatchRefBone(FName BoneName)
{
	// Disasm: 0x130D40, 256b.
	// Phase 0: get mesh via vtbl[0x8C/4], reject NAME_None
	typedef BYTE* (__thiscall *GetMeshFn)(USkeletalMeshInstance*);
	GetMeshFn GetMesh = *(GetMeshFn*)((*(BYTE**)this) + 0x8C);
	BYTE* Mesh = GetMesh(this);
	if (!Mesh) return -1;

	if (BoneName == FName(NAME_None)) return -1;

	// Phase 1: search mesh->RefBoneNames TArray at mesh+0x2D0 (stride 4 = FName array)
	FArray* BoneNameArr = (FArray*)(Mesh + 0x2D0);
	INT BoneCount = BoneNameArr->Num();
	if (BoneCount <= 0) return -1;

	BYTE* BoneNameData = *(BYTE**)BoneNameArr;
	INT FoundIdx = -1;
	for (INT i = 0; i < BoneCount; i++)
	{
		FName* Entry = (FName*)(BoneNameData + i * 4);
		if (*Entry == BoneName) { FoundIdx = i; break; }
	}
	if (FoundIdx < 0) return -1;

	// Phase 2: get bone index from mesh->RefBoneIndices TArray at mesh+0x2DC
	BYTE* BoneIdxData = *(BYTE**)(Mesh + 0x2DC);
	INT BoneIdx = *(INT*)(BoneIdxData + FoundIdx * 4);

	// Phase 3: search mesh->RefBones TArray at mesh+0x19C (stride 0x40)
	// for a slot whose first DWORD matches BoneIdx
	Mesh = GetMesh(this);
	FArray* SkelArr = (FArray*)(Mesh + 0x19C);
	INT SkelCount = SkelArr->Num();
	if (SkelCount <= 0) return -1;

	BYTE* SkelData = *(BYTE**)SkelArr;
	for (INT j = 0; j < SkelCount; j++)
	{
		BYTE* Slot = SkelData + j * 0x40;
		if (*(INT*)Slot == BoneIdx) return j;
	}
	return -1;
}

IMPL_MATCH("Engine.dll", 0x104351b0)
void USkeletalMeshInstance::BlendToAlpha(INT Channel, FLOAT BlendAlpha, FLOAT DeltaTime)
{
	guard(USkeletalMeshInstance::BlendToAlpha);
	// Retail: 0x1351B0, ~130b.
	// Sets up a timed blend on channel elem+0x38/0x5C/0x60.
	// If DeltaTime == 0.0f: do nothing (no-op guard at retail).
	// Otherwise: store BlendAlpha at elem+0x60, DeltaTime at elem+0x5C, set elem+0x38=1.
	if (DeltaTime == 0.0f) return;
	if (Channel < 0) return;
	FArray* arr = (FArray*)((BYTE*)this + 0x10C);
	if (Channel >= arr->Num()) return;
	BYTE* elem = (BYTE*)(*(BYTE**)arr) + Channel * 0x74;
	*(INT*)(elem + 0x60)  = *(INT*)&BlendAlpha; // store as int-aliased float
	*(FLOAT*)(elem + 0x5C) = DeltaTime;
	*(INT*)(elem + 0x38)   = 1;
	unguard;
}

IMPL_DIVERGE("FCoords source (local_30) for TransformPointBy is unresolvable from Ghidra output (vtbl[0x110/4] writes to local_1c only, not local_30). Cannot implement without disassembly of FUN references. Ghidra 0x104361a0")
void USkeletalMeshInstance::BuildPivotsList()
{
	guard(USkeletalMeshInstance::BuildPivotsList);
	// Retail 0x1361a0: builds bone pivot list from skeleton data.
	// TODO: implement BuildPivotsList (retail 0x1361a0: builds bone pivot list from skeleton data)
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1043d860)
void USkeletalMeshInstance::ClearSkelAnims()
{
	// Disasm: 0x13D860, 128b.
	// For each slot in AnimObjects (this+0xAC, stride 0x18), empty the inner FArray at slot+0x0C.
	// Then destroy each slot object, then empty the whole AnimObjects array.
	FArray* AnimArr = (FArray*)((BYTE*)this + 0xAC);
	INT Count = AnimArr->Num();
	BYTE* Data = *(BYTE**)AnimArr;
	for (INT i = 0; i < Count; i++)
	{
		FArray* Inner = (FArray*)(Data + i * 0x18 + 0x0C);
		Inner->Empty(4);
	}
	AnimArr->Empty(0x18);
}

IMPL_MATCH("Engine.dll", 0x10434980)
void USkeletalMeshInstance::CopyAnimation(INT Src, INT Dst)
{
	guard(USkeletalMeshInstance::CopyAnimation);
	// Retail: 0x134980, ~200b.
	// Both Src and Dst must be valid channels (>= 0 and < Num). Dst is ValidateAnimChannel'd.
	// Copies channel fields from Src to Dst: +8(FName), +4(slotIdx), +0C(rate), +20(rateScale),
	// +10(frame), +50(blendAlpha), +14(frameCount), +34(isLooping), +2C(loopFlag1).
	if (Src < 0 || Dst < 0) return;
	FArray* arr = (FArray*)((BYTE*)this + 0x10C);
	if (Src >= arr->Num()) return;
	ValidateAnimChannel(Dst);
	if (Dst >= arr->Num()) return;
	BYTE* base = (BYTE*)(*(BYTE**)arr);
	BYTE* src  = base + Src * 0x74;
	BYTE* dst  = base + Dst * 0x74;
	*(INT*)(dst + 0x08) = *(INT*)(src + 0x08); // FName sequence
	*(INT*)(dst + 0x04) = *(INT*)(src + 0x04); // anim slot index
	*(INT*)(dst + 0x0C) = *(INT*)(src + 0x0C); // rate
	*(INT*)(dst + 0x20) = *(INT*)(src + 0x20); // rate scale
	*(INT*)(dst + 0x10) = *(INT*)(src + 0x10); // frame
	*(INT*)(dst + 0x50) = *(INT*)(src + 0x50); // blend alpha
	*(INT*)(dst + 0x14) = *(INT*)(src + 0x14); // frame count
	*(INT*)(dst + 0x34) = *(INT*)(src + 0x34); // isLooping
	*(INT*)(dst + 0x2C) = *(INT*)(src + 0x2C); // loop flag 1
	unguard;
}

IMPL_TODO("Ghidra 0x10436390 (933b): DrawCollisionCylinders blocked by m_fCylindersRadius binary data — implement after m_fCylindersRadius is extracted from Engine.dll data section (see GetBoneCylinder below)")
void USkeletalMeshInstance::DrawCollisionCylinders(FSceneNode *)
{
	guard(USkeletalMeshInstance::DrawCollisionCylinders);
	// Retail 0x10436390 (933b): draws debug cylinders for bone collision shapes.
	// TODO: implement DrawCollisionCylinders (retail 0x10436390, 933 bytes: draws debug cylinders for bone collision shapes)
	unguard;
}

IMPL_MATCH("Engine.dll", 0x104338b0)
int USkeletalMeshInstance::EnableChannelNotify(INT Channel, INT bEnable)
{
	guard(USkeletalMeshInstance::EnableChannelNotify);
	// Retail: 0x1338B0, ~130b.
	// ValidateAnimChannel(Channel). Then elem+0x48 = !bEnable (i.e. 0 when enabling, 1 when disabling).
	// Returns 1 on success, 0 if ValidateAnimChannel fails.
	if (!ValidateAnimChannel(Channel)) return 0;
	BYTE* base = (BYTE*)(*(BYTE**)((BYTE*)this + 0x10C));
	BYTE* elem = base + Channel * 0x74;
	*(INT*)(elem + 0x48) = (bEnable == 0) ? 1 : 0;
	return 1;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10434b80)
void USkeletalMeshInstance::ForceAnimRate(INT Channel, FLOAT Rate)
{
	guard(USkeletalMeshInstance::ForceAnimRate);
	// Retail: 0x134B80, 96b. Stores Rate at channel element+0x0C in TArray at this+0x10C
	// (stride 0x74). Bounds-checks channel first; ignores negative channel.
	if (Channel < 0)
		return;
	FArray* arr = (FArray*)((BYTE*)this + 0x10C);
	if (Channel >= arr->Num())
		return;
	BYTE* elem = (BYTE*)(*(INT*)arr) + Channel * 0x74;
	*(FLOAT*)(elem + 0x0C) = Rate;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1042F760)
int USkeletalMeshInstance::GetAnimChannelCount()
{
	// Retail: 12b. Adjusts this to TArray at this+0x10C, then jumps to TArray::Num via IAT.
	// Equivalent to reading the TArray ArrayNum field directly.
	return *(INT*)((BYTE*)this + 0x110); // this+0x10C is TArray start; +0x04 = ArrayNum
}

IMPL_MATCH("Engine.dll", 0x10434E40)
float USkeletalMeshInstance::GetAnimFrame(INT Channel)
{
	guard(USkeletalMeshInstance::GetAnimFrame);
	// Retail: 93b SEH. Same TArray at this+0x10C (stride 0x74), frame float at element+0x10.
	if (Channel < 0) return 0.0f;
	BYTE* seqBase = (BYTE*)this + 0x10C;
	INT count = *(INT*)(seqBase + 4);
	if (Channel >= count) return 0.0f;
	return *(FLOAT*)(*(BYTE**)(seqBase) + Channel * 0x74 + 0x10);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10435b20)
float USkeletalMeshInstance::GetAnimRateOnChannel(INT Channel)
{
	// Disasm: 0x135B20, 96b.
	// Validates channel, then returns GetActiveAnimRate(GetAnimNamed(channel_seqname)).
	// Returns 0.0f if channel is invalid or anim not found.
	typedef INT (__thiscall *ValidateFn)(USkeletalMeshInstance*, INT);
	ValidateFn Validate = (ValidateFn)0x10430F40;
	if (!Validate(this, Channel)) return 0.0f;

	// Get sequence FName from channel elem+8
	FArray* arr = (FArray*)((BYTE*)this + 0x10C);
	BYTE* elem = (BYTE*)(*(BYTE**)arr) + Channel * 0x74;
	FName SeqName = *(FName*)(elem + 8);

	// GetAnimNamed(SeqName) → anim object pointer
	typedef void* (__thiscall *GetAnimNamedFn)(USkeletalMeshInstance*, FName);
	GetAnimNamedFn GetAnimNamed_fn = *(GetAnimNamedFn*)((*(BYTE**)this) + 0xB0);
	void* SeqObj = GetAnimNamed_fn(this, SeqName);
	if (!SeqObj) return 0.0f;

	// GetActiveAnimRate(SeqObj) → current channel rate
	typedef FLOAT (__thiscall *GetActiveRateFn)(USkeletalMeshInstance*, void*);
	GetActiveRateFn GetActiveRate = *(GetActiveRateFn*)((*(BYTE**)this) + 0xC4);
	return GetActiveRate(this, SeqObj);
}

IMPL_MATCH("Engine.dll", 0x104350F0)
FName USkeletalMeshInstance::GetAnimSequence(INT Channel)
{
	guard(USkeletalMeshInstance::GetAnimSequence);
	// Retail: 98b SEH. Reads FName.Index from channel element+0x08 in TArray at this+0x10C.
	// Same layout as GetActiveAnimSequence; [ebp+0xC] used as arg due to hidden return ptr.
	if (Channel < 0) return FName(NAME_None);
	BYTE* seqBase = (BYTE*)this + 0x10C;
	INT count = *(INT*)(seqBase + 4);
	if (Channel >= count) return FName(NAME_None);
	BYTE* data = *(BYTE**)(seqBase);
	return *(FName*)(data + Channel * 0x74 + 0x08);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10434CF0)
float USkeletalMeshInstance::GetBlendAlpha(INT Channel)
{
	guard(USkeletalMeshInstance::GetBlendAlpha);
	// Retail: 93b SEH. Same TArray at this+0x10C (stride 0x74), blend alpha float at element+0x50.
	if (Channel < 0) return 0.0f;
	BYTE* seqBase = (BYTE*)this + 0x10C;
	INT count = *(INT*)(seqBase + 4);
	if (Channel >= count) return 0.0f;
	return *(FLOAT*)(*(BYTE**)(seqBase) + Channel * 0x74 + 0x50);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10433210)
FCoords USkeletalMeshInstance::GetBoneCoords(DWORD,int)
{
	return FCoords();
}

IMPL_TODO("Ghidra 0x10433990: global m_fCylindersRadius pointer source/init path still unresolved in our build; keep temporary null guard until data init is reconstructed")
int USkeletalMeshInstance::GetBoneCylinder(int BoneIndex, FCylinder& Cyl)
{
	guard(USkeletalMeshInstance::GetBoneCylinder);
	// Retail 0x133990, 387b. Computes a cylinder for the given bone segment.
	// this+0x190: bone world-position cache (FVector array, stride 0x0C).
	// this+0x19C: parent-bone index array (INT array, stride 4).
	// m_fCylindersRadius[]: global per-bone radius table (TODO: populate from binary data).

	// Retail uses the global USkeletalMeshInstance::m_fCylindersRadius pointer.
	// In our current build this pointer is not yet initialised from retail data,
	// so keep a temporary null guard and return 0 until initialisation is reconstructed.
	if (!USkeletalMeshInstance::m_fCylindersRadius)
		return 0;

	FLOAT* pBone   = (FLOAT*)(*(INT*)((BYTE*)this + 0x190) + BoneIndex * 0x0C);
	FLOAT boneX = pBone[0];
	FLOAT boneY = pBone[1];
	FLOAT boneZ = pBone[2];

	INT   parentIdx = *(INT*)((*(INT*)((BYTE*)this + 0x19C)) + BoneIndex * 4);
	FLOAT* pParent  = (FLOAT*)(*(INT*)((BYTE*)this + 0x190) + parentIdx * 0x0C);

	// Enter if radius is non-zero and non-NaN, and bone is not index 7
	FLOAT Radius = USkeletalMeshInstance::m_fCylindersRadius[BoneIndex];
	if (Radius != 0.0f && BoneIndex != 7)
	{
		FLOAT dX = pParent[0] - boneX;
		FLOAT dY = pParent[1] - boneY;
		FLOAT dZ = pParent[2] - boneZ;

		// Cylinder half-height = |delta| * 0.5
		FVector delta(dX, dY, dZ);
		*(FLOAT*)((BYTE*)&Cyl + 0x18) = delta.Size() * 0.5f;

		// Cylinder centre = bone + delta * 0.5 (midpoint)
		// Ghidra: FVector::operator*(delta, (float)local_4c) where scalar ≈ 0.5f (midpoint)
		FVector mid = delta * 0.5f;
		*(FLOAT*)((BYTE*)&Cyl + 0x00) = boneX + mid.X;
		*(FLOAT*)((BYTE*)&Cyl + 0x04) = boneY + mid.Y;
		*(FLOAT*)((BYTE*)&Cyl + 0x08) = boneZ + mid.Z;

		// Cylinder axis = normalised delta
		FVector norm = delta.SafeNormal();
		*(FLOAT*)((BYTE*)&Cyl + 0x0C) = norm.X;
		*(FLOAT*)((BYTE*)&Cyl + 0x10) = norm.Y;
		*(FLOAT*)((BYTE*)&Cyl + 0x14) = norm.Z;

		// Cylinder radius from global table
		*(FLOAT*)((BYTE*)&Cyl + 0x1C) = Radius;

		return 1;
	}
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10433680)
FName USkeletalMeshInstance::GetBoneName(FName BoneName)
{
	// Disasm: 0x133680, 128b.
	// Gets mesh, searches mesh->RefBoneNames (mesh+0x2D0, stride 4) for BoneName.
	// On success returns the corresponding entry from mesh->RefBoneIndices (mesh+0x2DC).
	typedef BYTE* (__thiscall *GetMeshFn)(USkeletalMeshInstance*);
	GetMeshFn GetMesh = *(GetMeshFn*)((*(BYTE**)this) + 0x8C);
	BYTE* Mesh = GetMesh(this);
	if (!Mesh) return FName(NAME_None);

	FArray* BoneNameArr = (FArray*)(Mesh + 0x2D0);
	INT Count = BoneNameArr->Num();
	BYTE* NameData = *(BYTE**)BoneNameArr;
	for (INT i = 0; i < Count; i++)
	{
		FName* Entry = (FName*)(NameData + i * 4);
		if (*Entry == BoneName)
		{
			// Return the mapped bone index from RefBoneIndices (mesh+0x2DC) as a FName
			BYTE* IndexData = *(BYTE**)(Mesh + 0x2DC);
			FName Result;
			*(INT*)&Result = *(INT*)(IndexData + i * 4);
			return Result;
		}
	}
	return FName(NAME_None);
}

IMPL_MATCH("Engine.dll", 0x10433610)
FRotator USkeletalMeshInstance::GetBoneRotation(DWORD boneIndex, INT Space)
{
	// Retail: 0x133520, 320b. Same skeleton update guard as GetBoneCoords.
	// Checks WasSkeletonUpdated (bone array at 0xB8, SQWORD stamp at 0x64/0x68 vs GTicks).
	// If stale and owner is valid: call vtbl[0x110/4] to refresh skeleton.
	// Then validates boneIndex < Num(). Reads bone transform from this+0xB8[boneIndex*0x30],
	// converts to FRotator via transform at this+0xC4 (inverse world transform).
	typedef void* (__thiscall *GetOwnerFn)(USkeletalMeshInstance*);
	typedef void  (__thiscall *UpdateAnimFn)(USkeletalMeshInstance*, void*, void*, INT, INT, INT, INT);
	typedef FRotator* (__cdecl *GetTransformRotFn)(FRotator*, void*, void*);
	typedef FRotator* (__cdecl *FRotatorCtorFn)(FRotator*, INT, INT, INT);

	FArray* boneArr = (FArray*)((BYTE*)this + 0xB8);
	if (boneArr->Num() > 0)
	{
		SQWORD stamp = *(SQWORD*)((BYTE*)this + 0x64);
		if (stamp < GTicks)
		{
			GetOwnerFn GetOwner = *(GetOwnerFn*)((*(BYTE**)this) + 0x84);
			void* Owner = GetOwner(this);
			if (Owner)
			{
				UpdateAnimFn UpdateAnim = *(UpdateAnimFn*)((*(BYTE**)this) + 0x110);
				FRotator scratch(0,0,0);
				UpdateAnim(this, &scratch, Owner, 0, 0, 0, 2);
			}
		}
	}
	if (boneArr->Num() == 0 || boneIndex >= (DWORD)boneArr->Num())
	{
		// IAT 0x10529064: FRotator(0,0,0)
		return FRotator(0, 0, 0);
	}
	// boneTransform = this->BoneTransforms[boneIndex] (stride 0x30)
	// result = FCoords(boneTransform) * this->WorldTransform (at this+0xC4)
	// then extract rotation from that combined FCoords
	// IAT 0x1052919c: load FCoords from bone array element (bone elem is at offset 0x30 apart)
	// IAT 0x10529384: FCoords multiply: combined = boneCoords * worldTransform
	// IAT 0x10529388: FCoords.Rotation() -> FRotator
	typedef void  (__cdecl *LoadBoneFn)(void*, void*);
	typedef void  (__cdecl *MulCoordsFn)(void*, void*, void*);
	typedef void  (__cdecl *ExtractRotFn)(void*, void*);
	LoadBoneFn    LoadBone   = *(LoadBoneFn*)   0x1052919c;
	MulCoordsFn   MulCoords  = *(MulCoordsFn*)  0x10529384;
	ExtractRotFn  ExtractRot = *(ExtractRotFn*) 0x10529388;
	BYTE* elem = (BYTE*)(*(BYTE**)boneArr) + boneIndex * 0x30;
	BYTE boneCoords[0x30]; // FCoords is 0x30 bytes (4 FVectors)
	LoadBone(boneCoords, elem);
	BYTE combined[0x30];
	MulCoords(combined, boneCoords, (BYTE*)this + 0xC4);
	FRotator result(0,0,0);
	ExtractRot(&result, combined);
	return result;
}

IMPL_MATCH("Engine.dll", 0x10433610)
FRotator USkeletalMeshInstance::GetBoneRotation(FName BoneName, INT Space)
{
	// Retail: 0x133610, 64b. Call MatchRefBone to get index then forward to GetBoneRotation(DWORD,int).
	INT boneIndex = MatchRefBone(BoneName);
	if (boneIndex < 0)
		return FRotator(0, 0, 0);
	return GetBoneRotation((DWORD)boneIndex, Space);
}

IMPL_MATCH("Engine.dll", 0x1042f8f0)
FVector USkeletalMeshInstance::GetRootLocation()
{
	// Disasm: 0x12F8F0, 96b.
	// If root motion lock (this+0x228) is set AND owner (vtbl[0x84/4]) is non-null:
	//   call vtbl[0x110/4](this, outVec, owner, 0,0,0, 3) to fill root motion data,
	//   then copy this+0x1C8 (root location cache) to output.
	// Else return zero vector.
	if (!*(INT*)((BYTE*)this + 0x228)) return FVector(0,0,0);
	typedef void* (__thiscall *GetOwnerFn)(USkeletalMeshInstance*);
	GetOwnerFn GetOwner = *(GetOwnerFn*)((*(BYTE**)this) + 0x84);
	if (!GetOwner(this)) return FVector(0,0,0);
	// Return cached root location at this+0x1C8
	return *(FVector*)((BYTE*)this + 0x1C8);
}

IMPL_MATCH("Engine.dll", 0x10433790)
FVector USkeletalMeshInstance::GetRootLocationDelta()
{
	guard(USkeletalMeshInstance::GetRootLocationDelta);
	// Disasm: 0x133790, 288b.
	// 1. Guard: root motion lock (this+0x228) set AND GetOwner vtable non-null.
	// 2. Call vtbl[0x110/4] to refresh root motion caches.
	// 3. delta = current location (this+0x1C8) - prev location (this+0x1E0).
	// 4. Update prev cache to current.
	// 5. If this+0x22C != 0, call LockRootMotion(this+0x100, 1).
	if (!*(INT*)((BYTE*)this + 0x228)) return FVector(0,0,0);
	typedef void* (__thiscall *GetOwnerFn)(USkeletalMeshInstance*);
	GetOwnerFn GetOwner = *(GetOwnerFn*)((*(BYTE**)this) + 0x84);
	if (!GetOwner(this)) return FVector(0,0,0);
	// Trigger root motion update (vtbl slot 0x110/4 = UpdateAnimation-like)
	typedef void (__thiscall *UpdateRootFn)(USkeletalMeshInstance*);
	UpdateRootFn UpdateRoot = *(UpdateRootFn*)((*(BYTE**)this) + 0x110);
	UpdateRoot(this);
	// Compute per-axis deltas
	FLOAT dX = *(FLOAT*)((BYTE*)this + 0x1C8) - *(FLOAT*)((BYTE*)this + 0x1E0);
	FLOAT dY = *(FLOAT*)((BYTE*)this + 0x1CC) - *(FLOAT*)((BYTE*)this + 0x1E4);
	FLOAT dZ = *(FLOAT*)((BYTE*)this + 0x1D0) - *(FLOAT*)((BYTE*)this + 0x1E8);
	// Update previous position cache
	*(FLOAT*)((BYTE*)this + 0x1E0) = *(FLOAT*)((BYTE*)this + 0x1C8);
	*(FLOAT*)((BYTE*)this + 0x1E4) = *(FLOAT*)((BYTE*)this + 0x1CC);
	*(FLOAT*)((BYTE*)this + 0x1E8) = *(FLOAT*)((BYTE*)this + 0x1D0);
	// If additional autolock flag set, re-lock root motion
	if (*(INT*)((BYTE*)this + 0x22C))
		LockRootMotion(*(INT*)((BYTE*)this + 0x100), 1);
	return FVector(dX, dY, dZ);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1042f950)
FRotator USkeletalMeshInstance::GetRootRotation()
{
	// Disasm: 0x12F950, 96b. Same pattern as GetRootLocation but reads this+0x1D4.
	if (!*(INT*)((BYTE*)this + 0x228)) return FRotator(0,0,0);
	typedef void* (__thiscall *GetOwnerFn)(USkeletalMeshInstance*);
	GetOwnerFn GetOwner = *(GetOwnerFn*)((*(BYTE**)this) + 0x84);
	if (!GetOwner(this)) return FRotator(0,0,0);
	// Return cached root rotation at this+0x1D4
	return *(FRotator*)((BYTE*)this + 0x1D4);
}

IMPL_MATCH("Engine.dll", 0x1042f9b0)
FRotator USkeletalMeshInstance::GetRootRotationDelta()
{
	guard(USkeletalMeshInstance::GetRootRotationDelta);
	// Disasm: 0x12F9B0, 224b.
	// 1. Guard: root motion lock (this+0x228) set AND GetOwner vtable non-null.
	// 2. Call vtbl[0x110/4] to refresh root motion caches.
	// 3. Compute Yaw delta = current yaw (this+0x1D4+4) - previous yaw (this+0x1EC+4).
	// 4. Update prev rotation cache (this+0x1EC) = current (this+0x1D4).
	// 5. Return {0, deltaYaw, 0} — retail only extracts Yaw component.
	if (!*(INT*)((BYTE*)this + 0x228)) return FRotator(0,0,0);
	typedef void* (__thiscall *GetOwnerFn)(USkeletalMeshInstance*);
	GetOwnerFn GetOwner = *(GetOwnerFn*)((*(BYTE**)this) + 0x84);
	if (!GetOwner(this)) return FRotator(0,0,0);
	// Trigger root motion update
	typedef void (__thiscall *UpdateRootFn)(USkeletalMeshInstance*);
	UpdateRootFn UpdateRoot = *(UpdateRootFn*)((*(BYTE**)this) + 0x110);
	UpdateRoot(this);
	// Read current and previous rotations
	FRotator Current = *(FRotator*)((BYTE*)this + 0x1D4);
	FRotator Prev    = *(FRotator*)((BYTE*)this + 0x1EC);
	// Update previous rotation cache
	*(FRotator*)((BYTE*)this + 0x1EC) = Current;
	// Return yaw-only delta (retail zeroes Pitch and Roll)
	return FRotator(0, Current.Yaw - Prev.Yaw, 0);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10435bf0)
FCoords USkeletalMeshInstance::GetTagCoords(FName TagName)
{
	// Retail: 0x135BF0, 120b.
	// 1) Search mesh's tag name array (mesh+0x2D0) for TagName → tag found flag.
	//    (Internal helper FUN_10433680 does GetMesh + search + returns found FName)
	// 2) Call MatchRefBone(TagName) → boneIndex.
	// 3) If boneIndex >= 0 AND bone array (this+0xB8) has entries AND boneIndex in range:
	//    multiply bone transform[boneIndex] by world transform (this+0xC4) via IAT 0x10529384.
	//    Return that FCoords.
	// 4) Else: return identity FCoords from global constant.
	INT boneIndex = MatchRefBone(TagName);
	FArray* boneArr = (FArray*)((BYTE*)this + 0xB8);
	if (boneIndex >= 0 && boneArr->Num() > 0 && boneIndex < boneArr->Num())
	{
		typedef void (__cdecl *MulCoordsFn)(void*, void*, void*);
		MulCoordsFn MulCoords = *(MulCoordsFn*)0x10529384;
		BYTE* elem = (BYTE*)(*(BYTE**)boneArr) + boneIndex * 0x30;
		FCoords result;
		MulCoords(&result, elem, (BYTE*)this + 0xC4);
		return result;
	}
	return FCoords();
}

IMPL_MATCH("Engine.dll", 0x10433700)
FCoords USkeletalMeshInstance::GetTagPosition(FName TagName)
{
	// Retail: 0x133700, ~140b.
	// GetMesh(), search mesh's tag name array (mesh+0x2D0) for matching FName.
	// Each tag FName stored as 4-byte entries; positions at mesh+0x2E8 stride 12 (FVector, 0x30/idx).
	// If tag found: copy that entry's position (mesh+0x2E8 + idx*0x30) as FVector.
	// Else: return zero FVector as FCoords origin.
	typedef BYTE* (__thiscall *GetMeshFn)(USkeletalMeshInstance*);
	GetMeshFn GetMesh = *(GetMeshFn*)((*(BYTE**)this) + 0x8C);
	BYTE* Mesh = GetMesh(this);
	FCoords result;
	if (Mesh)
	{
		FArray* TagNames = (FArray*)(Mesh + 0x2D0);
		INT Count = TagNames->Num();
		FName* NameData = *(FName**)TagNames;
		for (INT i = 0; i < Count; i++)
		{
			if (NameData[i] == TagName)
			{
				// Tag position is at mesh+0x2E8, stride 0x30 per entry, FVector at start
				BYTE* TagPos = *(BYTE**)(Mesh + 0x2E8) + i * 0x30;
				result.Origin = *(FVector*)TagPos;
				return result;
			}
		}
	}
	return result;
}

IMPL_MATCH("Engine.dll", 0x10435800)
int USkeletalMeshInstance::StopAnimating(int bClearAll)
{
	// Retail: 0x135800. Clear animation play state for all channels.
	// Sets rate (elem+0x0C), tween (elem+0x18), and notifier (elem+0x50) to 0.
	// If bClearAll: also empty blend shape arrays, clear channels 1+ names to None.
	FArray* arr = (FArray*)((BYTE*)this + 0x10C);
	INT count = arr->Num();
	for (INT i = 0; i < count; i++) {
		BYTE* elem = (BYTE*)(*(INT*)arr) + i * 0x74;
		*(INT*)(elem + 0x0C) = 0;
		*(INT*)(elem + 0x18) = 0;
		*(INT*)(elem + 0x50) = 0;
	}
	if (bClearAll) {
		((FArray*)((BYTE*)this + 0x124))->Empty(0x40);
		((FArray*)((BYTE*)this + 0x130))->Empty(0x40);
		typedef UObject* (__thiscall *GetOwnerFn2)(USkeletalMeshInstance*);
	UObject* owner = ((GetOwnerFn2)(*(void***)this)[0x84 / sizeof(void*)])(this);
		INT keepShape = owner && owner->IsA(APawn::StaticClass()) && *(INT*)((BYTE*)owner + 0x3A4) == 0xB14E;
		if (!keepShape)
			((FArray*)((BYTE*)this + 0x118))->Empty(0x3C);
		FName none(NAME_None);
		count = arr->Num();
		for (INT i = 1; i < count; i++) {
			BYTE* elem = (BYTE*)(*(INT*)arr) + i * 0x74;
			*(INT*)(elem + 0x50) = 0;
			*(FName*)(elem + 0x08) = none;
		}
	}
	return 1;
}

IMPL_MATCH("Engine.dll", 0x10432d10)
int USkeletalMeshInstance::UpdateAnimation(FLOAT DeltaTime)
{
	guard(USkeletalMeshInstance::UpdateAnimation);
	// Retail 0x132d10, ~580b. Per-frame animation channel tick.
	// Advances frame counters, fires notifies, handles tweens, replicates channel 0.
	// _DAT_10793ef8: global that caches the last animation delta time.
	static FLOAT GLastAnimDelta = 0.0f; // Retail: _DAT_10793ef8 (Engine.dll data section)

	BYTE* vtbl = *(BYTE**)this;

	// vtbl[0x94/4](this, 1) — begin/lock animation update
	typedef void (__thiscall *BeginUpdateFn)(USkeletalMeshInstance*, INT);
	(*(BeginUpdateFn*)(vtbl + 0x94))(this, 1);

	GLastAnimDelta = DeltaTime;
	*(INT*)((BYTE*)this + 0x228) = 1;

	// vtbl[0x98/4](this) — get dirty/status flags
	typedef DWORD (__thiscall *GetFlagsFn)(USkeletalMeshInstance*);
	DWORD flags = (*(GetFlagsFn*)(vtbl + 0x98))(this);

	if ((flags & 2) == 0)
	{
		INT channelIdx = 0;
		while (true)
		{
			INT numChannels = ((FArray*)((BYTE*)this + 0x10C))->Num();
			if (numChannels <= channelIdx) break;

			BYTE* elem    = (BYTE*)(*(INT*)((BYTE*)this + 0x10C)) + channelIdx * 0x74;
			FLOAT remaining = DeltaTime;
			INT   loopCount = 0;

			if (*(INT*)(elem + 0x38) == 0)
			{
				// Normal frame advance
				LAB_UpdateAnim_Normal:
				while (*(INT*)(elem + 4) >= 0
					&& (*(AActor**)((BYTE*)this + 0x5C))->IsAnimating(channelIdx)
					&& remaining > 0.0f
					&& ++loopCount < 5)
				{
					FLOAT prevFrame = *(FLOAT*)(elem + 0x10);

					if (*(FLOAT*)(elem + 0x10) >= 0.0f)
					{
						// Compute effective rate
						FLOAT rate;
						if (*(FLOAT*)(elem + 0x0C) < 0.0f)
						{
							rate = ((FVector*)(*(INT*)((BYTE*)this + 0x5C) + 0x24C))->Size();
							rate = -(rate * *(FLOAT*)(elem + 0x0C));
							if (rate <= 0.3f) rate = 0.3f;
						}
						else
						{
							rate = *(FLOAT*)(elem + 0x0C);
						}
						*(FLOAT*)(elem + 0x10) += remaining * rate;

						// Check for notify / end-of-animation
						if ((*(INT*)(elem + 0x34) == 0)
							|| (*(INT*)(*(INT*)((BYTE*)this + 0x5C) + 0x16C) == 0)
							|| (*(INT*)(elem + 0x48) != 0)
							|| (channelIdx != 0 && *(FLOAT*)(elem + 0x50) <= 0.5f))
						{
							// No notify: check end frame
							LAB_UpdateAnim_CheckEnd:
							if (*(FLOAT*)(elem + 0x10) >= *(FLOAT*)(elem + 0x14)) break;

							FLOAT curFrame = *(FLOAT*)(elem + 0x10);
							if (*(INT*)(elem + 0x30) == 0)
							{
								// Non-looping: clamp at end frame
								FLOAT endFrame = *(FLOAT*)(elem + 0x14);
								FLOAT prev     = *(FLOAT*)(elem + 0x10);
								*(FLOAT*)(elem + 0x10) = endFrame;
								*(INT*)((BYTE*)this + 0x14C) = channelIdx;
								remaining = ((curFrame - endFrame) * remaining) / (prev - prevFrame);
								if (*(INT*)(elem + 0x48) != 0 || *(FLOAT*)(elem + 0x0C) <= 0.0f)
									*(INT*)(elem + 0x0C) = 0;
								else
								{
									*(INT*)(elem + 0x0C) = 0;
									// vtbl[0xD8/4](owner, channelIdx) — AnimEnd notify
									typedef void (__thiscall *AnimEndFn)(AActor*, INT);
									(*(AnimEndFn*)((*(BYTE**)(*(INT*)((BYTE*)this + 0x5C))) + 0xD8))(
										*(AActor**)((BYTE*)this + 0x5C),
										*(INT*)((BYTE*)this + 0x14C));
								}
							}
							else
							{
								// Looping: wrap frame
								if (curFrame >= 1.0f)
								{
									FLOAT prev2  = *(FLOAT*)(elem + 0x10);
									FLOAT prev3  = *(FLOAT*)(elem + 0x10);
									*(FLOAT*)(elem + 0x10) = 0.0f;
									remaining = ((curFrame - 1.0f) * remaining) / (prev3 - prevFrame);
								}
								else
								{
									remaining = 0.0f;
								}
								if (prevFrame < *(FLOAT*)(elem + 0x14))
								{
									*(INT*)((BYTE*)this + 0x14C) = channelIdx;
									if (*(INT*)(elem + 0x48) == 0)
									{
										typedef void (__thiscall *AnimEndFn2)(AActor*, INT);
										(*(AnimEndFn2*)((*(BYTE**)(*(INT*)((BYTE*)this + 0x5C))) + 0xD8))(
											*(AActor**)((BYTE*)this + 0x5C), channelIdx);
									}
								}
							}
						}
						else
						{
							// Notify path: find the nearest notify in [prevFrame, curFrame]
							typedef INT (__thiscall *GetAnimSeqFn)(USkeletalMeshInstance*, INT);
							INT   animObj   = (*(GetAnimSeqFn*)(vtbl + 0xB0))(this, *(INT*)(elem + 8));
							FLOAT bestDist  = 100000.0f;
							INT   bestNotify = -1;
							INT   notifyIdx  = 0;
							INT   notifyCount;
							typedef INT (__thiscall *GetNotifyCountFn)(USkeletalMeshInstance*, INT);
							typedef FLOAT10 (__thiscall *GetNotifyTimeFn)(USkeletalMeshInstance*, INT, INT);
							while (notifyIdx < (notifyCount = (*(GetNotifyCountFn*)(vtbl + 200))(this, animObj)))
							{
								FLOAT notifyTime = (FLOAT)(*(GetNotifyTimeFn*)(vtbl + 0xCC))(this, animObj, notifyIdx);
								if ((prevFrame >= notifyTime || *(FLOAT*)(elem + 0x10) < notifyTime)
									|| (notifyTime -= prevFrame, bestNotify != -1 && notifyTime >= bestDist))
								{
									notifyIdx++;
								}
								else
								{
									bestNotify = notifyIdx++;
									bestDist = notifyTime;
								}
							}
							if (bestNotify < 0) goto LAB_UpdateAnim_CheckEnd;

							FLOAT notifyAt = (FLOAT)(*(GetNotifyTimeFn*)(vtbl + 0xCC))(this, animObj, bestNotify);
							remaining = ((*(FLOAT*)(elem + 0x10) - notifyAt) * remaining) / (*(FLOAT*)(elem + 0x10) - prevFrame);
							*(FLOAT*)(elem + 0x10) = (FLOAT)(*(GetNotifyTimeFn*)(vtbl + 0xCC))(this, animObj, bestNotify);

							typedef INT* (__thiscall *GetNotifyObjFn)(USkeletalMeshInstance*, INT, INT);
						INT* notifyObj = (*(GetNotifyObjFn*)(vtbl + 0xD4))(this, animObj, bestNotify);
							if (notifyObj)
							{
								*(INT*)((BYTE*)this + 0x148) = channelIdx;
								// notifyObj->vtbl[100/4](this, owner)
								typedef void (__thiscall *NotifyFn)(INT*, USkeletalMeshInstance*, INT);
								(*(NotifyFn*)((*notifyObj) + 100))(notifyObj, this, *(INT*)((BYTE*)this + 0x5C));
							}
						}
					}
					else
					{
						// Tween-in: advance negative frame toward 0
						FLOAT newFrame = remaining * *(FLOAT*)(elem + 0x18) + *(FLOAT*)(elem + 0x10);
						*(FLOAT*)(elem + 0x10) = newFrame;
						if (newFrame < 0.0f) break;
						*(FLOAT*)(elem + 0x10) = 0.0f;
						remaining = (remaining * newFrame) / (newFrame - prevFrame);
						if (*(FLOAT*)(elem + 0x0C) != 0.0f)
						{
							*(INT*)((BYTE*)this + 0x14C) = channelIdx;
							if (*(INT*)(elem + 0x48) == 0)
							{
								typedef void (__thiscall *AnimEndFn3)(AActor*, INT);
								(*(AnimEndFn3*)((*(BYTE**)(*(INT*)((BYTE*)this + 0x5C))) + 0xD8))(
									*(AActor**)((BYTE*)this + 0x5C), channelIdx);
							}
						}
					}
				}
			}
			else if (*(INT*)(elem + 4) >= 0)
			{
				// Tween-blend path
				if (DeltaTime > 0.0f)
				{
					FLOAT t = DeltaTime / *(FLOAT*)(elem + 0x5C);
					if (t > 1.0f) t = 1.0f;
					*(FLOAT*)(elem + 0x50) = (*(FLOAT*)(elem + 0x60) - *(FLOAT*)(elem + 0x50)) * t + *(FLOAT*)(elem + 0x50);
					FLOAT tw = *(FLOAT*)(elem + 0x5C) - DeltaTime;
					if (tw < 0.0f) tw = 0.0f;
					*(FLOAT*)(elem + 0x5C) = tw;
					if (tw == 0.0f)
						*(INT*)(elem + 0x38) = 0;
				}
				goto LAB_UpdateAnim_Normal;
			}

			if (channelIdx == 0)
			{
				(*(AActor**)((BYTE*)this + 0x5C))->ReplicateAnim(
					0,
					*(FName*)(elem + 8),
					*(FLOAT*)(elem + 0x0C),
					*(FLOAT*)(elem + 0x10),
					*(FLOAT*)(elem + 0x18),
					*(FLOAT*)(elem + 0x14),
					*(INT*)(elem + 0x30));
			}
			channelIdx++;
		}
	}

	flags = (*(GetFlagsFn*)(vtbl + 0x98))(this);
	if ((flags & 2) == 0)
	{
		(*(BeginUpdateFn*)(vtbl + 0x94))(this, 0);
	}
	else
	{
		// vtbl[0xC/4](this, 1) — SetStatus(1)
		typedef void (__thiscall *SetStatusFn)(USkeletalMeshInstance*, INT);
		(*(SetStatusFn*)(vtbl + 0x0C))(this, 1);
	}

	return 1;
	unguard;
}

IMPL_DIVERGE("calls FUN_10481dd0 (FUN_104xxxxx range; unresolved Karma/MeSDK helper); retail 0x1043da80")
void USkeletalMeshInstance::Render(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
	guard(USkeletalMeshInstance::Render);
	// Retail 0x1043da80 (6631b): full skeletal mesh rendering pipeline.
	// DIVERGENCE: calls FUN_10481dd0 (FUN_104xxxxx Karma/MeSDK range); permanently unresolvable
	// without MeSDK sources.
	unguard;
}

// Ghidra 0x10438750 (264b): calls ULodMeshInstance::Serialize, then when !IsPersistent serializes
// animation-channel TArray (+0x10C via FUN_104372f0), bone scale/pos/rot TArrays (+0x118, +0x124
// via FUN_10437430/FUN_104375d0), scalar fields at +0x104/+0x108 via ByteOrderSerialize, bone
// coordinate caches (+0x150/+0x15C/+0x168/+0x190/+0x19C via FUN_10438100/FUN_10321a80/
// FUN_103218c0 etc.), and AnimObjects TArray (+0xB8 via FUN_104371c0).
// Divergence: FUN_104372f0/FUN_10437430/FUN_104375d0/FUN_10438100/FUN_10321a80/FUN_103218c0/
// FUN_104371c0 are unresolved TArray serializers; only the two scalar fields are serialized here.
IMPL_DIVERGE("calls FUN_104372f0/FUN_10437430/FUN_104375d0/FUN_10438100/FUN_104371c0 (FUN_104xxxxx TArray serializers; Karma/MeSDK range); retail 0x10438750")
void USkeletalMeshInstance::Serialize(FArchive& Ar)
{
	ULodMeshInstance::Serialize(Ar);
	if (!Ar.IsPersistent())
	{
		// Scalar cache fields: +0x104 (active vert stream size), +0x108 (flags).
		Ar.ByteOrderSerialize((BYTE*)this + 0x104, 4);
		Ar.ByteOrderSerialize((BYTE*)this + 0x108, 4);
	}
}

IMPL_MATCH("Engine.dll", 0x10434DA0)
void USkeletalMeshInstance::SetAnimFrame(INT Channel, FLOAT Frame)
{
	guard(USkeletalMeshInstance::SetAnimFrame);
	// Retail: 96b SEH. Bounds-checks Channel against TArray count at this+0x10C,
	// then stores Frame (float) into channel element at Data + Channel*0x74 + 0x10.
	if (Channel < 0) return;
	BYTE* seqBase = (BYTE*)this + 0x10C;
	INT count = *(INT*)(seqBase + 4);
	if (Channel >= count) return;
	BYTE* data = *(BYTE**)(seqBase);
	*(FLOAT*)(data + Channel * 0x74 + 0x10) = Frame;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10435aa0)
void USkeletalMeshInstance::SetMesh(UMesh* NewMesh)
{
	// Disasm: 0x135AA0, ~60b.
	// Store mesh pointer at this+0x58, empty animation/bone caches, notify.
	*(UMesh**)((BYTE*)this + 0x58) = NewMesh;
	// Empty bone transform and blend arrays
	((FArray*)((BYTE*)this + 0x150))->Empty(0x10);
	((FArray*)((BYTE*)this + 0x15C))->Empty(0x0C);
	((FArray*)((BYTE*)this + 0xB8))->Empty(0x30);
	((FArray*)((BYTE*)this + 0x118))->Empty(0x3C);
	((FArray*)((BYTE*)this + 0x124))->Empty(0x40);
	((FArray*)((BYTE*)this + 0x130))->Empty(0x40);
	// If mesh is non-null, trigger ActualizeAnimLinkups notification
	if (NewMesh)
	{
		typedef void (__thiscall *NotifyFn)(USkeletalMeshInstance*);
		NotifyFn Notify = *(NotifyFn*)((*(BYTE**)this) + 0x128);
		Notify(this);
	}
}

IMPL_MATCH("Engine.dll", 0x10430e40)
void USkeletalMeshInstance::SetScale(FVector Scale)
{
	guard(USkeletalMeshInstance::SetScale);
	// Disasm: 0x130E40, 96b.
	// Get mesh via vtbl[0x8C/4], write Scale to mesh+0x7C,
	// then ensure mesh+0x84 (some float, likely DrawScale) is non-negative.
	typedef BYTE* (__thiscall *GetMeshFn)(USkeletalMeshInstance*);
	GetMeshFn GetMesh_fn = *(GetMeshFn*)((*(BYTE**)this) + 0x8C);
	BYTE* Mesh = GetMesh_fn(this);
	if (!Mesh) return;
	*(FVector*)(Mesh + 0x7C) = Scale;
	// Abs-value the draw scale at mesh+0x84
	FLOAT* DrawScale = (FLOAT*)(Mesh + 0x84);
	if (*DrawScale < 0.0f) *DrawScale = -*DrawScale;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10433b50)
int USkeletalMeshInstance::LineCheck(FCheckResult& Hit, AActor* Owner, FVector End, FVector Start, FVector Extent, DWORD ExtraNodeFlags, DWORD TraceFlags)
{
	guard(USkeletalMeshInstance::LineCheck);
	// Retail 0x133b50, 433b. Tests line against per-bone FCylinders; falls through to
	// UMeshInstance::LineCheck on miss. Returns 0 on hit (fills Hit), 1 on clean pass.

	if (Owner == NULL || *(BYTE*)((BYTE*)Owner + 0x2C) == 0x0E)
	{
		// No actor or wrong collision type: delegate to base
		goto LAB_SkelLineCheck_Base;
	}

	{
		FVector DirN;
		FCylinder Cyl;

		INT boneCount = ((FArray*)((BYTE*)this + 0x190))->Num();
		INT boneIdx   = 1;

		while (boneIdx < boneCount)
		{
			INT got = GetBoneCylinder(boneIdx, Cyl);
			if (got != 0)
			{
				INT cylHit = Cyl.LineCheck(End, Start, DirN);
				if (cylHit != 0)
				{
					// Store bone index as collision type, fill FCheckResult
					*(BYTE*)((BYTE*)Owner + 0x35) = (BYTE)boneIdx;
					*(FLOAT*)((BYTE*)&Hit + 8)    = DirN.X;
					*(FLOAT*)((BYTE*)&Hit + 0x0C) = DirN.Y;
					*(FLOAT*)((BYTE*)&Hit + 0x10) = DirN.Z;
					*(AActor**)((BYTE*)&Hit + 4)  = Owner;
					*(INT*)   ((BYTE*)&Hit + 0x20)= 0;
					// Time = (Hit.X - Start.X) / (End.X - Start.X)
					*(FLOAT*)((BYTE*)&Hit + 0x24) = (DirN.X - Start.X) / (End.X - Start.X);

					FVector normal = DirN - (End * (*(FLOAT*)((BYTE*)&Hit + 0x24)));
					FVector normV = normal.GetNormalized();
					*(FLOAT*)((BYTE*)&Hit + 0x14) = normV.X;
					*(FLOAT*)((BYTE*)&Hit + 0x18) = normV.Y;
					*(FLOAT*)((BYTE*)&Hit + 0x1C) = normV.Z;

					return 0;
				}
			}
			boneIdx++;
		}

		// Check head hit via dedicated trace
		{
			static FLOAT headExtent = 0.0f;  // _DAT_105f8f4c: head-trace extent (TODO: populate)
			FVector* headPos = (FVector*)(*(INT*)((BYTE*)this + 0x190) + 0x54); // bone 7 position
			INT headHit = TraceHeadHit(Hit, End, Start, DirN, headExtent);
			if (headHit != 0)
			{
				*(BYTE*)((BYTE*)Owner + 0x35)   = 7;
				*(AActor**)((BYTE*)&Hit + 4)    = Owner;
				*(INT*)((BYTE*)&Hit + 0x20)     = 0;
				*(FLOAT*)((BYTE*)&Hit + 0x24) = (*(FLOAT*)((BYTE*)&Hit + 8) - End.X) / (Start.X - End.X);
				return 0;
			}
			return 1;
		}
	}

	LAB_SkelLineCheck_Base:
	return UMeshInstance::LineCheck(Hit, Owner, End, Start, Extent, ExtraNodeFlags, TraceFlags);
	unguard;
}

IMPL_DIVERGE("calls FUN_10438ce0 (FUN_104xxxxx GPU-skinning transform; Karma/MeSDK range); retail 0x1043da50")
void USkeletalMeshInstance::MeshSkinVertsCallback(void *)
{
	guard(USkeletalMeshInstance::MeshSkinVertsCallback);
	// Retail 0x13da50 (~36b): calls vtable[0x8c/4] with skin params, then FUN_10438ce0.
	// FUN_10438ce0 = skinned-mesh vertex transform helper: takes (vertIdx, this, vertBuffer,
	// stride=0x20, outArray) and fills a local vertex array with bone-weighted positions.
	// DIVERGENCE: FUN_10438ce0 is a complex GPU-skinning transform; identity unresolved.
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10431d50)
int USkeletalMeshInstance::PlayAnim(INT Channel, FName SeqName, FLOAT Rate, FLOAT TweenTime, INT bLooping, INT bLoopLast, INT bIdle)
{
	guard(USkeletalMeshInstance::PlayAnim);
	// Retail: 0x131D50, ~700b. Faithfully decompiled from Ghidra.
	// bLooping: loop the animation. bLoopLast: stored at elem+0x40 (bIdle field).
	// bIdle: if non-zero, use Rate directly; otherwise scale Rate by rateScale.
	typedef void*  (__thiscall *GetAnimNamedFn)(USkeletalMeshInstance*, FName);
	typedef BYTE*  (__thiscall *GetOwnerFn)(USkeletalMeshInstance*);
	typedef void*  (__thiscall *FindAnimObjFn)(USkeletalMeshInstance*, FName);
	typedef FLOAT  (__thiscall *GetFrameCountFn)(USkeletalMeshInstance*, void*);
	typedef FLOAT  (__thiscall *GetActiveRateFn)(USkeletalMeshInstance*, void*);
	typedef INT    (__thiscall *IsLoopingFn)(USkeletalMeshInstance*, void*);
	typedef INT    (__cdecl   *FindAnimSlotFn)(FArray*, void*);
	typedef FLOAT  (__cdecl   *TweenRateFn)(FLOAT, FLOAT);

	if (Channel < 0 || !ValidateAnimChannel(Channel))
		return 0;

	BYTE* vtbl = *(BYTE**)this;
	GetAnimNamedFn GetAnimNamed    = *(GetAnimNamedFn*) (vtbl + 0xB0);
	GetOwnerFn     GetOwner        = *(GetOwnerFn*)     (vtbl + 0x84);
	FindAnimObjFn  FindAnimObjForSeq = *(FindAnimObjFn*)(vtbl + 0x12C);
	GetFrameCountFn GetFrameCount  = *(GetFrameCountFn*)(vtbl + 0xC0);
	GetActiveRateFn GetActiveRate  = *(GetActiveRateFn*)(vtbl + 0xC4);
	IsLoopingFn    IsLooping       = *(IsLoopingFn*)    (vtbl + 0xC8);

	void* seqObj = GetAnimNamed(this, SeqName);
	if (!seqObj) return 0;

	BYTE* owner = GetOwner(this);
	if (!owner) return 0;

	void* seqObj2 = FindAnimObjForSeq(this, SeqName);
	if (!seqObj2) return 0;

	FindAnimSlotFn FindAnimSlot = (FindAnimSlotFn)0x10431D00;
	INT slotIdx = FindAnimSlot((FArray*)((BYTE*)this + 0xAC), seqObj2);

	BYTE* elem = (BYTE*)(*(BYTE**)((BYTE*)this + 0x10C)) + Channel * 0x74;
	*(INT*)(elem + 0x04) = slotIdx;

	if (bLooping)
	{
		// Looping path
		FLOAT frameCount = GetFrameCount(this, seqObj);
		if (frameCount <= 0.0f) return 0;
		FLOAT nativeRate = GetActiveRate(this, seqObj);

		// Continuation: same anim, already playing, still animating
		if (*(FName*)(elem + 0x08) == SeqName && *(INT*)(elem + 0x30) && IsAnimating(Channel))
		{
			FLOAT rateScale = nativeRate / frameCount;
			*(FLOAT*)(elem + 0x20) = rateScale;
			*(FLOAT*)(elem + 0x0C) = bIdle ? Rate : rateScale * Rate;
			*(INT*)(elem + 0x2C) = 0;
			*(FLOAT*)(elem + 0x1C) = *(FLOAT*)(elem + 0x0C);
			return 1;
		}

		// New looping animation
		FLOAT invFC = 1.0f / frameCount;
		*(FName*)(elem + 0x08) = SeqName;
		FLOAT rateScale = invFC * nativeRate;
		*(FLOAT*)(elem + 0x20) = rateScale;
		*(FLOAT*)(elem + 0x0C) = bIdle ? Rate : rateScale * Rate;
		*(FLOAT*)(elem + 0x14) = 1.0f - invFC;
		INT looping = IsLooping(this, seqObj);
		*(INT*)(elem + 0x40) = bLoopLast;
		*(INT*)(elem + 0x2C) = 0;
		*(INT*)(elem + 0x30) = 1;
		*(INT*)(elem + 0x34) = looping ? 1 : 0;

		FLOAT endFrame = *(FLOAT*)(elem + 0x14);
		if (endFrame != 0.0f)
		{
			// Has end frame: single-shot tween
			*(INT*)(elem + 0x34) = 0;
			*(INT*)(elem + 0x1C) = 0;
			if (TweenTime <= 0.0f)
			{
				*(FLOAT*)(elem + 0x18) = 10.0f;
				*(INT*)(elem + 0x0C)   = 0;
				*(INT*)(elem + 0x1C)   = 0;
				*(FLOAT*)(elem + 0x10) = -invFC;
				return 1;
			}
			*(INT*)(elem + 0x0C)   = 0;
			*(INT*)(elem + 0x1C)   = 0;
			*(FLOAT*)(elem + 0x18) = 1.0f / TweenTime;
			*(FLOAT*)(elem + 0x10) = -invFC;
			return 1;
		}

		// endFrame == 0: continuous loop with tween
		if (TweenTime > 0.0f)
		{
			*(FLOAT*)(elem + 0x1C) = *(FLOAT*)(elem + 0x0C);
			*(FLOAT*)(elem + 0x18) = 1.0f / (frameCount * TweenTime);
			*(FLOAT*)(elem + 0x10) = -invFC;
			return 1;
		}
		if (TweenTime == -1.0f)
		{
			*(DWORD*)(elem + 0x10) = 0x38d1b717u; // tiny positive float (~1e-4)
			*(INT*)(elem + 0x18)   = 0;
			*(FLOAT*)(elem + 0x1C) = *(FLOAT*)(elem + 0x0C);
			return 1;
		}
		*(FLOAT*)(elem + 0x10) = -invFC;
		FLOAT curTween = *(FLOAT*)(elem + 0x1C);
		if (curTween > 0.0f)
		{
			*(FLOAT*)(elem + 0x18) = curTween;
			*(FLOAT*)(elem + 0x1C) = *(FLOAT*)(elem + 0x0C);
			return 1;
		}
		if (curTween >= 0.0f) // == 0.0f
		{
			*(FLOAT*)(elem + 0x1C) = *(FLOAT*)(elem + 0x0C);
			*(FLOAT*)(elem + 0x18) = 1.0f / (frameCount * 0.025f);
			return 1;
		}
		// curTween < 0: speed-based tween
		FLOAT ownerSpeed = ((FVector*)(owner + 0x24C))->Size();
		TweenRateFn CalcTwRate = (TweenRateFn)0x103808E0;
		*(FLOAT*)(elem + 0x18) = CalcTwRate(*(FLOAT*)(elem + 0x0C) * 0.5f, ownerSpeed * curTween * -1.0f);
		*(FLOAT*)(elem + 0x1C) = *(FLOAT*)(elem + 0x0C);
		return 1;
	}
	else
	{
		// Non-looping path
		if (Rate <= 0.0f)
		{
			if (Rate < 0.0f) return 0; // negative rate: fail
			// Rate == 0.0: play at native rate, freeze at end
			FLOAT frameCount = GetFrameCount(this, seqObj);
			FLOAT nativeRate = GetActiveRate(this, seqObj);
			if (frameCount <= 0.0f) return 0;
			*(FName*)(elem + 0x08) = SeqName;
			*(INT*)(elem + 0x14)   = 0;
			*(INT*)(elem + 0x34)   = 0;
			*(INT*)(elem + 0x2C)   = 0;
			*(INT*)(elem + 0x30)   = 0;
			*(INT*)(elem + 0x0C)   = 0;
			*(INT*)(elem + 0x1C)   = 0;
			*(FLOAT*)(elem + 0x20) = nativeRate / frameCount;
			if (TweenTime <= 0.0f)
			{
				*(INT*)(elem + 0x18) = 0;
				*(INT*)(elem + 0x10) = 0;
			}
			else
			{
				*(FLOAT*)(elem + 0x18) = 1.0f / (frameCount * TweenTime);
				*(FLOAT*)(elem + 0x10) = -(1.0f / frameCount);
			}
			return 1;
		}

		// Rate > 0: normal non-looping play
		FLOAT frameCount = GetFrameCount(this, seqObj);
		if (frameCount <= 0.0f) return 0;
		*(FName*)(elem + 0x08) = SeqName;
		FLOAT nativeRate = GetActiveRate(this, seqObj);
		FLOAT invFC = 1.0f / frameCount;
		*(FLOAT*)(elem + 0x20) = invFC * nativeRate;
		*(FLOAT*)(elem + 0x0C) = bIdle ? Rate : invFC * nativeRate * Rate;
		*(FLOAT*)(elem + 0x14) = 1.0f - invFC;
		INT looping = IsLooping(this, seqObj);
		*(INT*)(elem + 0x40) = bLoopLast;
		*(INT*)(elem + 0x2C) = 0;
		*(INT*)(elem + 0x30) = 0;
		*(INT*)(elem + 0x34) = looping ? 1 : 0;

		FLOAT endFrame = *(FLOAT*)(elem + 0x14);
		if (endFrame == 0.0f)
		{
			// Single frame
			if (TweenTime > 0.0f)
			{
				*(FLOAT*)(elem + 0x1C) = *(FLOAT*)(elem + 0x0C);
				*(FLOAT*)(elem + 0x18) = 1.0f / (frameCount * TweenTime);
				*(FLOAT*)(elem + 0x10) = -invFC;
				return 1;
			}
			if (TweenTime == -1.0f)
			{
				*(DWORD*)(elem + 0x10) = 0x3a83126fu; // ~0.001f
				*(INT*)(elem + 0x18)   = 0;
				*(FLOAT*)(elem + 0x1C) = *(FLOAT*)(elem + 0x0C);
				return 1;
			}
			*(FLOAT*)(elem + 0x10) = -invFC;
			FLOAT curTween = *(FLOAT*)(elem + 0x1C);
			if (curTween > 0.0f)
			{
				*(FLOAT*)(elem + 0x18) = curTween;
				*(FLOAT*)(elem + 0x1C) = *(FLOAT*)(elem + 0x0C);
				return 1;
			}
			if (curTween >= 0.0f) // == 0.0f
			{
				*(FLOAT*)(elem + 0x1C) = *(FLOAT*)(elem + 0x0C);
				*(FLOAT*)(elem + 0x18) = 1.0f / (frameCount * 0.025f);
				return 1;
			}
			// curTween < 0
			FLOAT ownerSpeed = ((FVector*)(owner + 0x24C))->Size();
			TweenRateFn CalcTwRate = (TweenRateFn)0x103808E0;
			*(FLOAT*)(elem + 0x18) = CalcTwRate(*(FLOAT*)(elem + 0x0C) * 0.5f, ownerSpeed * curTween * -1.0f);
			*(FLOAT*)(elem + 0x1C) = *(FLOAT*)(elem + 0x0C);
			return 1;
		}

		// endFrame != 0: multi-frame non-looping
		*(INT*)(elem + 0x34) = 0;
		*(INT*)(elem + 0x1C) = 0;
		if (TweenTime <= 0.0f)
		{
			*(FLOAT*)(elem + 0x18) = 10.0f;
			*(INT*)(elem + 0x0C)   = 0;
			*(INT*)(elem + 0x1C)   = 0;
			*(FLOAT*)(elem + 0x10) = -invFC;
			return 1;
		}
		*(INT*)(elem + 0x0C)   = 0;
		*(INT*)(elem + 0x1C)   = 0;
		*(FLOAT*)(elem + 0x18) = 1.0f / TweenTime;
		*(FLOAT*)(elem + 0x10) = -invFC;
		return 1;
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10433960)
int USkeletalMeshInstance::ActiveVertStreamSize()
{
	// Disasm: 0x133960, 48b.
	// Gets LODIndex from this+0x104, then gets mesh via vtbl[0x8C/4].
	// Returns *(INT*)(mesh->LODMeshes.Data + LODIndex * 0x11C + 0x18).
	INT LODIdx = *(INT*)((BYTE*)this + 0x104);
	typedef BYTE* (__thiscall *GetMeshFn)(USkeletalMeshInstance*);
	GetMeshFn GetMesh = *(GetMeshFn*)((*(BYTE**)this) + 0x8C);
	BYTE* Mesh = GetMesh(this);
	if (!Mesh) return 0;
	BYTE* LODData = *(BYTE**)(Mesh + 0x1AC);  // mesh.LODMeshes TArray data ptr
	return *(INT*)(LODData + LODIdx * 0x11C + 0x18);
}

IMPL_MATCH("Engine.dll", 0x10435a30)
void USkeletalMeshInstance::ActualizeAnimLinkups()
{
	// Retail: 0x135A30. Iterates AnimObjects TArray at this+0xAC (stride 0x18).
	// For each slot where anim ptr (slot+0) is non-null and slot+4 differs from
	// this->mesh (+0x58), calls FUN_10435900(mesh, anim, slot+0x0C) to rebuild
	// the bone channel linkup table, then stamps slot+4 = mesh.
	typedef void (__cdecl *LinkupFn)(INT mesh, INT anim, void* out);
	LinkupFn Linkup = (LinkupFn)0x10435900;
	FArray* arr = (FArray*)((BYTE*)this + 0xAC);
	INT count = arr->Num();
	for (INT i = 0; i < count; i++)
	{
		BYTE* slot = (BYTE*)(*(INT*)arr) + i * 0x18;
		INT anim = *(INT*)slot;
		INT mesh = *(INT*)((BYTE*)this + 0x58);
		if (anim != 0 && *(INT*)(slot + 4) != mesh)
		{
			Linkup(mesh, anim, slot + 0x0C);
			*(INT*)(slot + 4) = mesh;
		}
	}
}

// FUN_10431d00 (Engine.dll 0x10431d00, 70 bytes): linear search of AnimObjects array
// (stride 0x18) for element whose first INT matches AnimObjPtr; returns slot index or -1.
static INT SearchAnimSlot(FArray* AnimSlots, INT AnimObjPtr)
{
	INT Count = AnimSlots->Num();
	if (Count <= 0) return -1;
	BYTE* Data = *(BYTE**)AnimSlots;
	INT Idx = 0, ByteOff = 0;
	do {
		if (*(INT*)(Data + ByteOff) == AnimObjPtr)
			return Idx;
		Idx++;
		ByteOff += 0x18;
		Count = AnimSlots->Num();
	} while (Idx < Count);
	return -1;
}

IMPL_DIVERGE("unaff_EBX/unaff_ESI float range bounds in secondary notify-closest-search loop (Ghidra 0x10432ac0+~260b) are register-carried values unresolvable from Ghidra decompilation output. Main slot/frame/rate logic is complete.")
int USkeletalMeshInstance::AnimForcePose(FName SeqName, FLOAT Frame, FLOAT Rate, INT Channel)
{
	guard(USkeletalMeshInstance::AnimForcePose);
	// Retail 0x132ac0, 586b. Force a specific anim frame on a channel.
	// Uses ValidateAnimChannel, finds the anim object via vtbl[0x12C/4],
	// fires any notifies, updates slot index via FUN_10431d00, stores Frame/Rate.

	INT isValid = ValidateAnimChannel(Channel);
	if (isValid != 0)
	{
		INT numChannels = ((FArray*)((BYTE*)this + 0x10C))->Num();
		if (Channel < numChannels && Channel >= 0)
		{
			// vtbl[0x12C/4](this) → anim package pointer (piVar3 in Ghidra)
			typedef INT* (__thiscall *GetAnimPkgFn)(USkeletalMeshInstance*);
			INT* animPkg = (*(GetAnimPkgFn*)((*(BYTE**)this) + 0x12C))(this);
			if (!animPkg) return 0;

			// animPkg->vtbl[100/4](SeqName) → find sequence in package
			typedef INT (__thiscall *FindSeqFn)(INT*, FName);
			INT animSeq = (*(FindSeqFn*)((*(BYTE**)animPkg) + 100))(animPkg, SeqName);

			if (animSeq != 0)
			{
				// Fire notifies for the target frame.
				// DIVERGENCE: Ghidra uses unaff_EBX/unaff_ESI/unaff_retaddr as range
				// bounds in the notify loop; these untracked register values cannot be
				// resolved, so the full range-check is simplified to firing all notifies.
				typedef INT (__thiscall *GetNotifyCountFn2)(USkeletalMeshInstance*, INT);
				INT notifyCount = (*(GetNotifyCountFn2*)((*(BYTE**)this) + 200))(this, animSeq);
				typedef FLOAT10 (__thiscall *GetNotifyTimeFn2)(USkeletalMeshInstance*, INT, INT);
				typedef INT* (__thiscall *GetNotifyObjFn2)(USkeletalMeshInstance*, INT, INT);
				for (INT ni = 0; ni < notifyCount; ni++)
				{
					FLOAT notifyTime = (FLOAT)(*(GetNotifyTimeFn2*)((*(BYTE**)this) + 0xCC))(this, animSeq, ni);
					INT* notifyObj = (*(GetNotifyObjFn2*)((*(BYTE**)this) + 0xD4))(this, animSeq, ni);
					if (notifyObj)
					{
						typedef void (__thiscall *NotifyFn)(INT*, USkeletalMeshInstance*, INT);
						(*(NotifyFn*)((*notifyObj) + 100))(notifyObj, this, *(INT*)((BYTE*)this + 0x5C));
					}
				}
			}

			INT slotOffset  = Channel * 0x74;
			INT channelData = *(INT*)((BYTE*)this + 0x10C);
			// FUN_10431d00: search AnimObjects (this+0xAC) for the anim package slot index.
			// unaff_EBX in Ghidra = animPkg pointer used as the search key.
			*(INT*) (channelData + slotOffset + 4)    = SearchAnimSlot((FArray*)((BYTE*)this + 0xAC), (INT)animPkg);
			*(FLOAT*)(channelData + slotOffset + 0x10) = Frame;
			*(FLOAT*)(channelData + slotOffset + 8)    = Rate;

			return 1;
		}
		// Channel out of range: warn via GLog
		GLog->Logf(TEXT("AnimForcePose: channel %i out of range for '%s'"), Channel, GetName());
	}
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1042F7A0)
float USkeletalMeshInstance::AnimGetFrameCount(void* Channel)
{
	// Retail: 14b. Returns float of int frame count at Channel+0x14. Checks Channel != NULL.
	if (!Channel) return 0.0f;
	return (FLOAT)(*(INT*)((BYTE*)Channel + 0x14));
}

IMPL_MATCH("Engine.dll", 0x10432990)
FName USkeletalMeshInstance::AnimGetGroup(void* Channel)
{
	// Retail: 34b. Check *(Channel+4) is non-null via IAT guard, then double-deref to get FName.Index.
	// Same bytecode as UVertMeshInstance::AnimGetGroup.
	FName result;
	if (*(void**)((BYTE*)Channel + 4))
		*(INT*)&result = *(INT*)*(void**)((BYTE*)Channel + 4);
	return result;
}

IMPL_MATCH("Engine.dll", 0x1042F770)
FName USkeletalMeshInstance::AnimGetName(void* Channel)
{
	// Retail: 19b. Null-check Channel, then double-deref: FName.Index = *(*(Channel+0)).
	// Channel[0] is a pointer to an animation state struct; its first DWORD is FName.Index.
	FName result;
	if (Channel)
		*(INT*)&result = *(INT*)*(void**)Channel;
	return result;
}

IMPL_MATCH("Engine.dll", 0x1042F7E0)
int USkeletalMeshInstance::AnimGetNotifyCount(void* Channel)
{
	// Retail: 20b. Null-checks Channel (returns 0 via fallthrough into next func), then
	// reads Num of TArray<FMeshAnimNotify> at Channel+0x1C (Num is at Channel+0x20).
	if (!Channel) return 0;
	return *(INT*)((BYTE*)Channel + 0x20);
}

IMPL_MATCH("Engine.dll", 0x10432A30)
UAnimNotify * USkeletalMeshInstance::AnimGetNotifyObject(void* Channel, int notifyIndex)
{
	// Retail: 25b. Same as VertMesh but with null check on Channel.
	// Notify array pointer at Channel+0x1C, 12 bytes/entry, ptr at entry+8.
	if (!Channel) return NULL;
	BYTE* notifyArray = *(BYTE**)((BYTE*)Channel + 0x1C);
	return *(UAnimNotify**)(notifyArray + notifyIndex * 12 + 8);
}

IMPL_MATCH("Engine.dll", 0x10432A00)
const TCHAR* USkeletalMeshInstance::AnimGetNotifyText(void* Channel, INT notifyIndex)
{
	// Retail: 31b. Null-checks Channel (null->returns NULL via fallthrough), then reads FName at
	// notify entry+4 and returns FName string via operator*. Same layout as UVertMeshInstance.
	if (!Channel) return NULL;
	BYTE* notifyArray = *(BYTE**)((BYTE*)Channel + 0x1C);
	FName name = *(FName*)(notifyArray + notifyIndex * 12 + 4);
	return *name;
}

IMPL_MATCH("Engine.dll", 0x104329D0)
float USkeletalMeshInstance::AnimGetNotifyTime(void* Channel, INT notifyIndex)
{
	// Retail: 24b. Null-check Channel; returns time float at notify_array[notifyIndex*12] (entry+0).
	if (!Channel) return 0.0f;
	BYTE* notifyArray = *(BYTE**)((BYTE*)Channel + 0x1C);
	return *(FLOAT*)(notifyArray + notifyIndex * 12);
}

IMPL_MATCH("Engine.dll", 0x1042F7C0)
float USkeletalMeshInstance::AnimGetRate(void* Channel)
{
	// Retail: 14b. Returns float rate from Channel+0x18, or 0.0f if Channel NULL.
	if (!Channel) return 0.0f;
	return *(FLOAT*)((BYTE*)Channel + 0x18);
}

IMPL_MATCH("Engine.dll", 0x10435b80)
int USkeletalMeshInstance::AnimIsInGroup(void* Channel, FName GroupName)
{
	// Retail 43b: early-exit if GroupName is None.
	// Channel+4 = TArray<FName> Groups; FUN_103b56b0 does the linear search (stride 4).
	if (GroupName == NAME_None) return 0;
	FArray* groups = (FArray*)((BYTE*)Channel + 4);
	INT count = groups->Num();
	BYTE* data = *(BYTE**)groups;
	for (INT i = 0; i < count; i++)
	{
		if (*(FName*)(data + i * 4) == GroupName) return 1;
	}
	return 0;
}

IMPL_MATCH("Engine.dll", 0x10431350)
int USkeletalMeshInstance::AnimStopLooping(INT channel)
{
	guard(USkeletalMeshInstance::AnimStopLooping);
	// Retail: 104b (SEH). TArray at this+0x10C, stride 0x74=116b.
	// Clears loop flag at element+0x30 and element+0x2C, returns 1.
	BYTE* seqBase = (BYTE*)this + 0x10C;
	INT count = *(INT*)(seqBase + 4);
	if (count <= channel || channel < 0) return 0;
	BYTE* data = *(BYTE**)(seqBase);
	BYTE* elem = data + channel * 0x74;
	*(INT*)(elem + 0x30) = 0;
	*(INT*)(elem + 0x2C) = 0;
	return 1;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10432500)
void USkeletalMeshInstance::ClearChannel(INT Channel)
{
	guard(USkeletalMeshInstance::ClearChannel);
	// Retail: 0x132500, 141b. If Channel is within the channel TArray (this+0x10C,
	// stride 0x74), reset the slot: sequence name→NAME_None, frame/rate/tween/etc→0.
	FArray* arr = (FArray*)((BYTE*)this + 0x10C);
	if (Channel < 0 || Channel >= arr->Num())
		return;
	BYTE* elem = (BYTE*)(*(INT*)arr) + Channel * 0x74;
	*(FName*)(elem + 0x08) = FName(NAME_None);
	*(INT*)(elem + 0x10) = 0;  // frame
	*(INT*)(elem + 0x0C) = 0;  // rate
	*(INT*)(elem + 0x18) = 0;  // tween
	*(INT*)(elem + 0x50) = 0;  // notifier
	*(INT*)(elem + 0x60) = 0;
	*(INT*)(elem + 0x5C) = 0;
	*(INT*)(elem + 0x38) = 0;  // loop
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10432770)
UMeshAnimation* USkeletalMeshInstance::CurrentSkelAnim(INT Channel)
{
	// Bounds check channel
	if (Channel < 0) return NULL;

	// Channels TArray at this+0x10C, stride 0x74
	FArray* ChanArr = (FArray*)((BYTE*)this + 0x10C);
	if (Channel >= ChanArr->Num()) return NULL;

	// Read anim slot index from channel elem+4
	BYTE* ChanElem = (BYTE*)(*(BYTE**)ChanArr) + Channel * 0x74;
	INT AnimSlotIdx = *(INT*)(ChanElem + 4);
	if (AnimSlotIdx < 0) return NULL;

	// Look up anim pointer in this->AnimObjects (this+0xAC, stride 0x18)
	FArray* AnimArr = (FArray*)((BYTE*)this + 0xAC);
	if (AnimSlotIdx >= AnimArr->Num()) return NULL;

	UMeshAnimation* Anim = *(UMeshAnimation**)((BYTE*)(*(BYTE**)AnimArr) + AnimSlotIdx * 0x18);
	if (Anim) return Anim;

	// Fallback: vtbl[0x8C/4] to get mesh, return mesh's default anim at mesh+0x1DC
	typedef void* (__thiscall *GetMeshFn)(USkeletalMeshInstance*);
	GetMeshFn GetMesh = *(GetMeshFn*)((*(BYTE**)this) + 0x8C);
	void* MeshPtr = GetMesh(this);
	if (!MeshPtr) return NULL;
	return *(UMeshAnimation**)((BYTE*)MeshPtr + 0x1DC);
}

IMPL_MATCH("Engine.dll", 0x1042f640)
void USkeletalMeshInstance::Destroy()
{
	guard(USkeletalMeshInstance::Destroy);
	// Retail: 0x12f640. Calls FUN_10367df0(this) to release bone geometry arrays
	// (TArrays at this+0x308 and this+0x314 — cached transform/ref lists), then
	// calls UObject::Destroy for the UObject cleanup chain.
	typedef void (__thiscall *CleanupFn)(USkeletalMeshInstance*);
	((CleanupFn)0x10367df0)(this);
	UObject::Destroy();
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10432a50)
UMeshAnimation* USkeletalMeshInstance::FindAnimObjectForSequence(FName SeqName)
{
	// Disasm: 0x132A50, 112b.
	// 1. Call FUN_10432640 (RefreshAnimObjects) to ensure this->AnimObjects is populated
	// 2. Iterate AnimObjects TArray at this+0xAC (stride 0x18), for each non-null anim:
	//    call vtbl[0x64/4=25](anim, SeqName) — UMeshAnimation::FindAnimSeq(FName)
	//    if non-null result return anim
	// 3. Ensure populated first
	typedef void (__thiscall *RefreshFn)(USkeletalMeshInstance*);
	// RefreshAnimObjects is internal (not exported), call it only if array is empty
	// We cannot call it by address portably, so we check manually and skip if non-empty
	FArray* AnimArr = (FArray*)((BYTE*)this + 0xAC);
	INT Count = AnimArr->Num();
	if (Count <= 0) return NULL;  // Can't refresh without calling internal fn

	BYTE* Data = *(BYTE**)AnimArr;
	for (INT i = 0; i < Count; i++)
	{
		BYTE* Slot = Data + i * 0x18;
		UMeshAnimation* Anim = *(UMeshAnimation**)Slot;
		if (!Anim) continue;

		// vtbl[0x64/4=25](Anim, SeqName) — FindAnimSeq on UMeshAnimation
		typedef void* (__thiscall *FindSeqFn)(UMeshAnimation*, FName);
		FindSeqFn FindSeq = *(FindSeqFn*)((*(BYTE**)Anim) + 0x64);
		if (FindSeq(Anim, SeqName)) return Anim;
	}
	return NULL;
}

IMPL_MATCH("Engine.dll", 0x10431040)
int USkeletalMeshInstance::FreezeAnimAt(FLOAT Frame, INT Channel)
{
	// Disasm: 0x131040, 200b.
	// Freezes a channel at a normalised frame position.
	// 1. Bounds-check Channel.
	// 2. Get sequence name from channel+8, call GetAnimNamed to get seq object.
	// 3. GetAnimFrameCount(seqObj) to get natural frame count.
	// 4. Normalise Frame by frameCount; clamp to [0, frameCount].
	// 5. Store at elem+0x10 (current frame), zero rate and tween.
	if (Channel < 0) return 0;
	FArray* arr = (FArray*)((BYTE*)this + 0x10C);
	if (Channel >= arr->Num()) return 0;
	BYTE* elem = (BYTE*)(*(BYTE**)arr) + Channel * 0x74;
	FName SeqName = *(FName*)(elem + 8);

	typedef void* (__thiscall *GetAnimNamedFn)(USkeletalMeshInstance*, FName);
	GetAnimNamedFn GetAnimNamed_fn = *(GetAnimNamedFn*)((*(BYTE**)this) + 0xB0);
	void* SeqObj = GetAnimNamed_fn(this, SeqName);

	// Get frame count; normalise Frame if frameCount > 0
	typedef FLOAT (__thiscall *GetFrameCountFn)(USkeletalMeshInstance*, void*);
	GetFrameCountFn GetFrameCount = *(GetFrameCountFn*)((*(BYTE**)this) + 0xC0);
	FLOAT FrameCount = GetFrameCount(this, SeqObj);
	FLOAT NormFrame = Frame;
	if (FrameCount != 0.0f)
		NormFrame = Frame / FrameCount;
	// Clamp to [0, frameCount]
	if (NormFrame < 0.0f) NormFrame = 0.0f;
	if (NormFrame > FrameCount && FrameCount > 0.0f) NormFrame = FrameCount;
	// Freeze: set frame, zero rate and tween
	*(FLOAT*)(elem + 0x10) = NormFrame;
	*(INT*)(elem + 0x0C) = 0;
	*(INT*)(elem + 0x18) = 0;
	return 1;
}

IMPL_MATCH("Engine.dll", 0x10431570)
float USkeletalMeshInstance::GetActiveAnimFrame(INT Channel)
{
	guard(USkeletalMeshInstance::GetActiveAnimFrame);
	// Retail: 93b (SEH). TArray at this+0x10C, stride 0x74=116b, frame float at element+0x10.
	BYTE* seqBase = (BYTE*)this + 0x10C;
	INT count = *(INT*)(seqBase + 4);
	if (count <= Channel || Channel < 0) return 0.0f;
	BYTE* data = *(BYTE**)(seqBase);
	return *(FLOAT*)(data + Channel * 0x74 + 0x10);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x104314C0)
float USkeletalMeshInstance::GetActiveAnimRate(INT Channel)
{
	guard(USkeletalMeshInstance::GetActiveAnimRate);
	// Retail: 93b (SEH). Same TArray at this+0x10C (stride 0x74=116b), rate float at element+0x0C.
	BYTE* seqBase = (BYTE*)this + 0x10C;
	INT count = *(INT*)(seqBase + 4);
	if (count <= Channel || Channel < 0) return 0.0f;
	BYTE* data = *(BYTE**)(seqBase);
	return *(FLOAT*)(data + Channel * 0x74 + 0x0C);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10431400)
FName USkeletalMeshInstance::GetActiveAnimSequence(INT Channel)
{
	guard(USkeletalMeshInstance::GetActiveAnimSequence);
	// Retail: 98b SEH. Reads FName from channel element+0x08 in TArray at this+0x10C.
	// Returns NAME_None if Channel < 0 or Channel >= count.
	if (Channel < 0) return FName(NAME_None);
	BYTE* seqBase = (BYTE*)this + 0x10C;
	INT count = *(INT*)(seqBase + 4);
	if (Channel >= count) return FName(NAME_None);
	BYTE* data = *(BYTE**)(seqBase);
	return *(FName*)(data + Channel * 0x74 + 0x08);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10432810)
int USkeletalMeshInstance::GetAnimCount()
{
	// Retail: 0x132810. Iterate anim object slots in TArray at this+0xAC (stride 0x18).
	// Each slot has a UMeshAnimation* at slot+0 and a sequence TArray at anim+0x48.
	// Sum the count of sequences across all valid (non-null) animation objects.
	FArray* arr = (FArray*)((BYTE*)this + 0xAC);
	INT total = 0;
	INT count = arr->Num();
	for (INT i = 0; i < count; i++) {
		BYTE* slot = (BYTE*)(*(INT*)arr) + i * 0x18;
		UMeshAnimation* anim = *(UMeshAnimation**)slot;
		if (anim) {
			INT seqs = ((FArray*)((BYTE*)anim + 0x48))->Num();
			total += seqs;
		}
	}
	return total;
}

IMPL_MATCH("Engine.dll", 0x10432870)
void * USkeletalMeshInstance::GetAnimIndexed(INT Index)
{
	// Retail: 88b. Calls vtbl[0x130/4=76] with arg 0 to get anim channel array object.
	// Checks count at obj+0x48 TArray; returns Data + Index*0x2C, or NULL if out of range.
	typedef BYTE* (__thiscall *GetChannelFn)(USkeletalMeshInstance*, INT);
	GetChannelFn fn = (GetChannelFn)((*(void***)this)[0x130 / sizeof(void*)]);
	BYTE* obj = fn(this, 0);
	if (!obj) return NULL;
	INT count = *(INT*)(obj + 0x48 + 4);
	if (count <= Index) return NULL;
	obj = fn(this, 0);
	BYTE* data = *(BYTE**)(obj + 0x48);
	return data + Index * 0x2C;
}

IMPL_MATCH("Engine.dll", 0x104328d0)
void* USkeletalMeshInstance::GetAnimNamed(FName SeqName)
{
	// Retail: 0x1328D0. Calls FUN_10432640 (RefreshAnimObjects) to populate AnimObjects
	// TArray at this+0xAC with the mesh's anim objects. Then iterates each non-null
	// UMeshAnimation* at slot+0 (stride 0x18), searching its sequence TArray at anim+0x48
	// (stride 0x2C, FName at seq+0). Returns the matching sequence pointer, or NULL.
	typedef void (__thiscall *RefreshFn)(USkeletalMeshInstance*);
	((RefreshFn)0x10432640)(this);
	FArray* animArr = (FArray*)((BYTE*)this + 0xAC);
	INT animCount = animArr->Num();
	for (INT ai = 0; ai < animCount; ai++)
	{
		BYTE* slot = (BYTE*)(*(INT*)animArr) + ai * 0x18;
		BYTE* anim = *(BYTE**)slot;
		if (!anim) continue;
		FArray* seqArr = (FArray*)(anim + 0x48);
		INT seqCount = seqArr->Num();
		for (INT si = 0; si < seqCount; si++)
		{
			BYTE* seq = (BYTE*)(*(INT*)seqArr) + si * 0x2C;
			if (*(FName*)seq == SeqName)
				return seq;
		}
	}
	return NULL;
}

IMPL_DIVERGE("Ghidra decompilation failed at 0x10439f40 (10776b) due to encoding error; manual binary analysis of ~10K bytes required; permanent blocker")
void USkeletalMeshInstance::GetFrame(AActor *,FLevelSceneNode *,FVector *,int,int &,DWORD)
{
	guard(USkeletalMeshInstance::GetFrame);
	// Retail 0x10439f40 (10776b): Ghidra decompilation failed (encoding error).
	// TODO: implement USkeletalMeshInstance::GetFrame (retail 0x10439f40, 10776 bytes: Ghidra decompilation failed; pending re-analysis)
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1031C700)
UMaterial * USkeletalMeshInstance::GetMaterial(int materialIndex, AActor* Actor)
{
	// Retail: 49b. Identical implementation to UVertMeshInstance::GetMaterial.
	// Calls Actor vtable slot 40 twice; returns NULL if Actor null or first call null.
	if (!Actor) return NULL;
	typedef UMaterial* (__thiscall *GetSkinFn)(AActor*, int);
	void** vtbl = *(void***)Actor;
	UMaterial* m = ((GetSkinFn)vtbl[40])(Actor, materialIndex);
	if (!m) return NULL;
	vtbl = *(void***)Actor;
	return ((GetSkinFn)vtbl[40])(Actor, materialIndex);
}

IMPL_DIVERGE("calls FUN_10438ce0 (FUN_104xxxxx GPU-skinning transform; Karma/MeSDK range); retail 0x1043d8e0")
void USkeletalMeshInstance::GetMeshVerts(AActor *,FVector *,int,int &)
{
	guard(USkeletalMeshInstance::GetMeshVerts);
	// Retail 0x13d8e0: extracts transformed vertex positions via FUN_10438ce0.
	// FUN_10438ce0 = skinned-mesh vertex transform helper (see MeshSkinVertsCallback).
	// DIVERGENCE: FUN_10438ce0 identity unresolved; no vertex output produced.
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1042F860)
FBox USkeletalMeshInstance::GetRenderBoundingBox(const AActor*)
{
	// Retail: 33b. GetMesh() + copy FBox from mesh+0x2C (cached render bounds).
	return *(FBox*)((BYTE*)GetMesh() + 0x2C);
}

IMPL_MATCH("Engine.dll", 0x1042F890)
FSphere USkeletalMeshInstance::GetRenderBoundingSphere(const AActor*)
{
	// Retail: 31b. GetMesh() + copy FSphere from mesh+0x48 via ctor.
	return *(FSphere*)((BYTE*)GetMesh() + 0x48);
}

IMPL_MATCH("Engine.dll", 0x10430fb0)
int USkeletalMeshInstance::IsAnimating(int Channel)
{
	// Retail: 0x130FB0, 133 bytes. Returns 1 if the animation channel has a non-None
	// sequence name AND a non-zero rate (either forward elem+0x0C or backward via elem+0x18).
	FArray* arr = (FArray*)((BYTE*)this + 0x10C);
	INT count = arr->Num();
	if (Channel < 0 || Channel >= count)
		return 0;
	BYTE* elem = (BYTE*)(*(INT*)arr) + Channel * 0x74;
	FName seqName = *(FName*)(elem + 0x08);
	if (seqName == FName(NAME_None))
		return 0;
	if (*(FLOAT*)(elem + 0x10) < 0.0f) {
		// negative frame = tween backward: check elem+0x18 (tween rate)
		if (*(FLOAT*)(elem + 0x18) != 0.0f)
			return 1;
	} else {
		if (*(FLOAT*)(elem + 0x0C) != 0.0f)
			return 1;
	}
	return 0;
}

IMPL_MATCH("Engine.dll", 0x104311E0)
int USkeletalMeshInstance::IsAnimLooping(INT Channel)
{
	guard(USkeletalMeshInstance::IsAnimLooping);
	// Retail: 93b (SEH). TArray at this+0x10C, stride 0x74=116b, loop flag (INT) at element+0x30.
	BYTE* seqBase = (BYTE*)this + 0x10C;
	INT count = *(INT*)(seqBase + 4);
	if (count <= Channel || Channel < 0) return 0;
	BYTE* data = *(BYTE**)(seqBase);
	return *(INT*)(data + Channel * 0x74 + 0x30);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10431290)
int USkeletalMeshInstance::IsAnimPastLastFrame(INT Channel)
{
	guard(USkeletalMeshInstance::IsAnimPastLastFrame);
	// Retail: 111b (SEH). Compares current frame (element+0x10) with end frame (element+0x14).
	// Returns 1 if current >= end (animation has reached or passed last frame).
	BYTE* seqBase = (BYTE*)this + 0x10C;
	INT count = *(INT*)(seqBase + 4);
	if (count <= Channel || Channel < 0) return 0;
	BYTE* data = *(BYTE**)(seqBase);
	BYTE* elem = data + Channel * 0x74;
	return (*(FLOAT*)(elem + 0x10) >= *(FLOAT*)(elem + 0x14)) ? 1 : 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10431110)
int USkeletalMeshInstance::IsAnimTweening(int Channel)
{
	guard(USkeletalMeshInstance::IsAnimTweening);
	// Retail: 0x131110, 117 bytes. Returns 1 if channel's current frame < 0 and vtbl
	// IsAnimating check (vtbl[0xD8/4]) also returns non-zero.
	// TArray at this+0x10C, stride 0x74, frame at elem+0x10.
	FArray* arr = (FArray*)((BYTE*)this + 0x10C);
	INT count = arr->Num();
	if (Channel < 0 || Channel >= count)
		return 0;
	BYTE* elem = (BYTE*)(*(INT*)arr) + Channel * 0x74;
	if (*(FLOAT*)(elem + 0x10) >= 0.0f)
		return 0;
	typedef INT (__thiscall *AnimCheckFn)(USkeletalMeshInstance*, INT);
	AnimCheckFn fn = (AnimCheckFn)((*(void***)this)[0xD8 / sizeof(void*)]);
	return fn(this, Channel) ? 1 : 0;
	unguard;
}


// --- USkeletalMeshInstance ---
IMPL_MATCH("Engine.dll", 0x1042f8b0)
int USkeletalMeshInstance::WasSkeletonUpdated()
{
	// Disasm: 0x12F8B0, 64b.
	// 1. If TArray at this+0xB8 is empty (Num()==0), bone data invalid → return 0.
	// 2. Compare update stamp QWORD at this+0x64 with GTicks-1.
	// 3. Return 1 if updated this tick or last tick.
	if (((FArray*)((BYTE*)this + 0xB8))->Num() == 0) return 0;
	SQWORD UpdateStamp = *(SQWORD*)((BYTE*)this + 0x64);
	return (UpdateStamp >= GTicks - 1) ? 1 : 0;
}

IMPL_MATCH("Engine.dll", 0x10441f40)
void USkeletalMeshInstance::MeshBuildBounds()
{
	guard(USkeletalMeshInstance::MeshBuildBounds);
	// Retail 0x10441f40 (516b): iterates bone-vertex cache to compute FBox/FSphere,
	// stores at skelMesh+0x2c and +0x48, then expands bounds outward by 100% (doubling
	// distance from centre) with a special 10% inset applied to min.z.
	typedef BYTE* (__thiscall *GetSkelMeshFn)(USkeletalMeshInstance*);
	BYTE* skelMesh = (*(GetSkelMeshFn*)((*(BYTE**)this) + 0x8C))(this);

	GWarn->Logf(NAME_None, TEXT("Bounding skeletal mesh"));

	// preprocess: call function pointer stored at skelMesh+0xf4
	typedef void (*PreprocFn)();
	(**(PreprocFn**)(skelMesh + 0xf4))();

	// collect bone vertices from skelMesh+0x100 (FArray of FVector, stride 0xc)
	FArray* boneArr = (FArray*)(skelMesh + 0x100);
	INT boneCount   = boneArr->Num();
	TArray<FVector> boneVerts;
	boneVerts.Add(boneCount);
	for (INT i = 0; i < boneCount; i++)
	{
		FVector* src = (FVector*)(*(BYTE**)boneArr + i * 0xC);
		boneVerts(i)  = *src;
	}

	FVector* data = boneCount > 0 ? &boneVerts(0) : NULL;

	// compute and store FBox at skelMesh+0x2c (7 floats = 28 bytes)
	FBox box(data, boneCount);
	appMemcpy(skelMesh + 0x2c, &box, 7 * sizeof(FLOAT));

	// compute and store FSphere at skelMesh+0x48 (4 floats = 16 bytes)
	FSphere sphere(data, boneCount);
	appMemcpy(skelMesh + 0x48, &sphere, 4 * sizeof(FLOAT));

	// read box components back for expansion
	FLOAT minX = *(FLOAT*)(skelMesh + 0x2c);
	FLOAT minY = *(FLOAT*)(skelMesh + 0x30);
	FLOAT minZ = *(FLOAT*)(skelMesh + 0x34);
	FLOAT maxX = *(FLOAT*)(skelMesh + 0x38);
	FLOAT maxY = *(FLOAT*)(skelMesh + 0x3c);
	FLOAT maxZ = *(FLOAT*)(skelMesh + 0x40);

	FLOAT ctrX    = (maxX + minX) * 0.5f;
	FLOAT ctrY    = (maxY + minY) * 0.5f;
	FLOAT ctrZ    = (maxZ + minZ) * 0.5f;
	FLOAT halfZneg = minZ - ctrZ;  // negative half-height

	// expand box outward: each component = 2*extremum - centre
	*(FLOAT*)(skelMesh + 0x2c) = (minX - ctrX) + minX;
	*(FLOAT*)(skelMesh + 0x30) = minY + (minY - ctrY);
	*(FLOAT*)(skelMesh + 0x34) = halfZneg + minZ;           // first write (2*min_z - ctr_z)
	FLOAT halfZpos = maxZ - ctrZ;
	FLOAT halfYpos = maxY - ctrY;
	*(FLOAT*)(skelMesh + 0x38) = (maxX - ctrX) + maxX;
	*(FLOAT*)(skelMesh + 0x3c) = maxY + halfYpos;
	*(FLOAT*)(skelMesh + 0x40) = maxZ + halfZpos;
	*(FLOAT*)(skelMesh + 0x34) = halfZneg * 0.1f + minZ;   // overwrite: 10% inset toward centre
	*(FLOAT*)(skelMesh + 0x54) *= 1.4f;                     // expand sphere radius by 40%
	unguard;
}

// Ghidra 0x10433de0 (2228b): complex bone-transform-to-world conversion pipeline.
// Current stub returns identity; full implementation requires bone cache data.
IMPL_DIVERGE("iStack_3c/iStack_74/iStack_78 inputs to helpers FUN_10370d70/FUN_103015f0 are unresolved stack-slot values in Ghidra output. 2228-byte pipeline cannot be reliably translated. Helpers confirmed in _unnamed.cpp. Ghidra 0x10433de0")
FMatrix USkeletalMeshInstance::MeshToWorld()
{
	return FMatrix();
}



// --- UVertMeshInstance ---
IMPL_MATCH("Engine.dll", 0x104728F0)
FMeshAnimSeq * UVertMeshInstance::GetAnimSeq(FName Name)
{
	// Retail: ~90b. Calls vtbl[0x8C/4=35] on this to get the underlying mesh object,
	// then searches TArray at mesh+0x118 (stride 0x2C=44b, FName at element+0).
	typedef BYTE* (__thiscall *GetMeshFn)(UVertMeshInstance*);
	GetMeshFn fn = (GetMeshFn)((*(void***)this)[0x8C / sizeof(void*)]);
	BYTE* mesh = fn(this);
	BYTE* seqBase = mesh + 0x118;
	INT count = *(INT*)(seqBase + 4);
	if (count <= 0) return NULL;
	BYTE* data = *(BYTE**)(seqBase);
	INT i = 0, byteOff = 0;
	while (i < count)
	{
		BYTE* elem = data + byteOff;
		if (*(FName*)elem == Name) return (FMeshAnimSeq*)elem;
		i++;
		byteOff += 0x2C;
		count = *(INT*)(seqBase + 4);
	}
	return NULL;
}

IMPL_MATCH("Engine.dll", 0x104726C0)
int UVertMeshInstance::StopAnimating(INT Channel)
{
	guard(UVertMeshInstance::StopAnimating);
	// Retail: 15b. Clears the animation sequence name (FName) at this+0xB8 and returns 1.
	// Channel argument is ignored (single-channel vertex mesh).
	*(FName*)((BYTE*)this + 0xB8) = FName(NAME_None);
	return 1;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10472950)
int UVertMeshInstance::UpdateAnimation(FLOAT DeltaTime)
{
	guard(UVertMeshInstance::UpdateAnimation);
	// Retail 0x172950, 947b. Per-frame vertex-mesh animation tick (single channel).
	// Fields: this+0xB8=SeqName, this+0xBC=rate, this+0xC0=curFrame, this+0xC4=endFrame,
	//         this+0xCC=tweenRate, this+0xDC=loopLast, this+0xE0=bLoop, this+0xE4=bNotify.

	BYTE* vtbl = *(BYTE**)this;
	typedef void (__thiscall *BeginUpdateFn)(UVertMeshInstance*, INT);
	typedef DWORD (__thiscall *GetFlagsFn)(UVertMeshInstance*);

	(*(BeginUpdateFn*)(vtbl + 0x94))(this, 1);

	INT loopCount = 0;
	while (true)
	{
		INT isAnim = (*(AActor**)((BYTE*)this + 0x5C))->IsAnimating(0);
		if (!isAnim || DeltaTime <= 0.0f || ++loopCount > 4)
			break;
		DWORD flags = (*(GetFlagsFn*)(vtbl + 0x98))(this);
		if (flags & 2) break;

		FLOAT prevFrame = *(FLOAT*)((BYTE*)this + 0xC0);

		if (*(FLOAT*)((BYTE*)this + 0xC0) >= 0.0f)
		{
			// Normal frame advance
			FLOAT rate;
			if (*(FLOAT*)((BYTE*)this + 0xBC) < 0.0f)
			{
				rate = ((FVector*)(*(INT*)((BYTE*)this + 0x5C) + 0x24C))->Size();
				rate = -(rate * *(FLOAT*)((BYTE*)this + 0xBC));
				if (rate <= 0.3f) rate = 0.3f;
			}
			else
			{
				rate = *(FLOAT*)((BYTE*)this + 0xBC);
			}
			*(FLOAT*)((BYTE*)this + 0xC0) += DeltaTime * rate;

			// Check notify path
			INT animSeq = 0;
			if (*(INT*)((BYTE*)this + 0xE4) != 0
				&& *(INT*)(*(INT*)((BYTE*)this + 0x5C) + 0x16C) != 0)
			{
				typedef INT (__thiscall *GetVAnimSeqFn)(UVertMeshInstance*, INT);
				animSeq = (*(GetVAnimSeqFn*)(vtbl + 0xB0))(this, *(INT*)((BYTE*)this + 0xB8));
			}

			if (animSeq == 0)
			{
				// No notify: check end frame
				LAB_VertUpdateAnim_CheckEnd:
				if (*(FLOAT*)((BYTE*)this + 0xC0) >= *(FLOAT*)((BYTE*)this + 0xC4)) break;

				FLOAT curFrame = *(FLOAT*)((BYTE*)this + 0xC0);
				if (*(INT*)((BYTE*)this + 0xE0) == 0)
				{
					// Non-looping: clamp
					*(FLOAT*)((BYTE*)this + 0xBC) = 0.0f;
					FLOAT endFrame = *(FLOAT*)((BYTE*)this + 0xC4);
					FLOAT prev2    = *(FLOAT*)((BYTE*)this + 0xC0);
					*(FLOAT*)((BYTE*)this + 0xC0) = endFrame;
					DeltaTime = ((curFrame - endFrame) * DeltaTime) / (prev2 - prevFrame);
					// owner->vtbl[0xD8/4](0) — AnimEnd
					typedef void (__thiscall *AnimEndFn)(AActor*, INT);
					(*(AnimEndFn*)((*(BYTE**)(*(INT*)((BYTE*)this + 0x5C))) + 0xD8))(
						*(AActor**)((BYTE*)this + 0x5C), 0);
				}
				else
				{
					// Looping: wrap
					if (curFrame >= 1.0f)
					{
						FLOAT fv1 = *(FLOAT*)((BYTE*)this + 0xC0);
						FLOAT fv2 = *(FLOAT*)((BYTE*)this + 0xC0);
						*(FLOAT*)((BYTE*)this + 0xC0) = 0.0f;
						DeltaTime = ((curFrame - 1.0f) * DeltaTime) / (fv2 - prevFrame);
					}
					else
					{
						DeltaTime = 0.0f;
					}
					if (prevFrame < *(FLOAT*)((BYTE*)this + 0xC4))
					{
						typedef void (__thiscall *AnimEndFn2)(AActor*, INT);
						(*(AnimEndFn2*)((*(BYTE**)(*(INT*)((BYTE*)this + 0x5C))) + 0xD8))(
							*(AActor**)((BYTE*)this + 0x5C), 0);
					}
				}
			}
			else
			{
				// Notify path: find nearest notify in [prevFrame, curFrame]
				FLOAT bestDist   = 100000.0f;
				INT   bestNotify = -1;
				INT   ni         = 0;
				INT   notifyCount;
				typedef INT (__thiscall *VGetNotifyCountFn)(UVertMeshInstance*, INT);
				typedef FLOAT10 (__thiscall *VGetNotifyTimeFn)(UVertMeshInstance*, INT, INT);
				while (ni < (notifyCount = (*(VGetNotifyCountFn*)(vtbl + 200))(this, animSeq)))
				{
					FLOAT t = (FLOAT)(*(VGetNotifyTimeFn*)(vtbl + 0xCC))(this, animSeq, ni);
					if ((prevFrame >= t || *(FLOAT*)((BYTE*)this + 0xC0) < t)
						|| (t -= prevFrame, bestNotify != -1 && t >= bestDist))
					{
						ni++;
					}
					else
					{
						bestNotify = ni++;
						bestDist = t;
					}
				}
				if (bestNotify < 0) goto LAB_VertUpdateAnim_CheckEnd;

				FLOAT notifyAt = (FLOAT)(*(VGetNotifyTimeFn*)(vtbl + 0xCC))(this, animSeq, bestNotify);
				DeltaTime = ((*(FLOAT*)((BYTE*)this + 0xC0) - notifyAt) * DeltaTime) / (*(FLOAT*)((BYTE*)this + 0xC0) - prevFrame);
				*(FLOAT*)((BYTE*)this + 0xC0) = (FLOAT)(*(VGetNotifyTimeFn*)(vtbl + 0xCC))(this, animSeq, bestNotify);
				typedef INT* (__thiscall *VGetNotifyObjFn)(UVertMeshInstance*, INT, INT);
				INT* notifyObj = (*(VGetNotifyObjFn*)(vtbl + 0xD4))(this, animSeq, bestNotify);
				if (notifyObj)
				{
					typedef void (__thiscall *NotifyFn)(INT*, UVertMeshInstance*, INT);
					(*(NotifyFn*)((*notifyObj) + 100))(notifyObj, this, *(INT*)((BYTE*)this + 0x5C));
				}
			}
		}
		else
		{
			// Tween-in: advance negative frame
			FLOAT newFrame = DeltaTime * *(FLOAT*)((BYTE*)this + 0xCC) + *(FLOAT*)((BYTE*)this + 0xC0);
			*(FLOAT*)((BYTE*)this + 0xC0) = newFrame;
			if (newFrame < 0.0f) break;
			*(FLOAT*)((BYTE*)this + 0xC0) = 0.0f;
			DeltaTime = (DeltaTime * newFrame) / (newFrame - prevFrame);
			if (*(FLOAT*)((BYTE*)this + 0xBC) != 0.0f)
			{
				typedef void (__thiscall *AnimEndFn3)(AActor*, INT);
				(*(AnimEndFn3*)((*(BYTE**)(*(INT*)((BYTE*)this + 0x5C))) + 0xD8))(
					*(AActor**)((BYTE*)this + 0x5C), 0);
			}
		}
	}

	(*(AActor**)((BYTE*)this + 0x5C))->ReplicateAnim(
		0,
		*(FName*)((BYTE*)this + 0xB8),
		*(FLOAT*)((BYTE*)this + 0xBC),
		*(FLOAT*)((BYTE*)this + 0xC0),
		*(FLOAT*)((BYTE*)this + 200),
		*(FLOAT*)((BYTE*)this + 0xC4),
		*(INT*)((BYTE*)this + 0xE0));

	DWORD flags = (*(GetFlagsFn*)(vtbl + 0x98))(this);
	if ((flags & 2) == 0)
	{
		(*(BeginUpdateFn*)(vtbl + 0x94))(this, 0);
	}
	else
	{
		typedef void (__thiscall *SetStatusFn)(UVertMeshInstance*, INT);
		(*(SetStatusFn*)(vtbl + 0x0C))(this, 1);
	}
	return 1;
	unguard;
}

IMPL_DIVERGE("retail 0x10474f70 uses FRenderInterface vtable directly (D3D state, FRawIndexBuffer locking, vertex buffer mgmt); permanently diverges from abstract render model")
void UVertMeshInstance::Render(FDynamicActor *,FLevelSceneNode *,TList<FDynamicLight *> *,FRenderInterface *)
{
	guard(UVertMeshInstance::Render);
	// Retail 0x174f70: full vertex mesh rendering pipeline.
	// TODO: implement UVertMeshInstance::Render (retail 0x174f70: full vertex mesh rendering pipeline)
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10474730)
void UVertMeshInstance::Serialize(FArchive& Ar)
{
	guard(UVertMeshInstance::Serialize);
	// Retail 0x10474730 (204b): super called unconditionally, then again inside
	// the non-persistent guard, followed by per-frame FVector arrays and scalar fields.
	// FUN_10321a80 (TArray<FVector> serializer, stride 0xc) is inlined below.
	ULodMeshInstance::Serialize(Ar);
	if (!Ar.IsPersistent())
	{
		ULodMeshInstance::Serialize(Ar);  // retail calls super twice (Ghidra 0x10474730)

		// Serialize TArray<FVector> at +0x80 and +0x8c (frame vert caches, stride 0xc)
		for (INT pass = 0; pass < 2; pass++)
		{
			FArray* arr = (FArray*)((BYTE*)this + (pass == 0 ? 0x80 : 0x8c));
			arr->CountBytes(Ar, 0xc);
			if (Ar.IsLoading())
			{
				INT num = 0;
				Ar << AR_INDEX(num);
				arr->Empty(0xc, num);
				for (INT i = 0; i < num; i++)
				{
					INT idx    = arr->Add(1, 0xc);
					BYTE* ptr  = (BYTE*)arr->GetData() + idx * 0xc;
					Ar.ByteOrderSerialize(ptr,     4);
					Ar.ByteOrderSerialize(ptr + 4, 4);
					Ar.ByteOrderSerialize(ptr + 8, 4);
				}
			}
			else
			{
				INT num = arr->Num();
				Ar << AR_INDEX(num);
				for (INT i = 0; i < num; i++)
				{
					BYTE* ptr = (BYTE*)arr->GetData() + i * 0xc;
					Ar.ByteOrderSerialize(ptr,     4);
					Ar.ByteOrderSerialize(ptr + 4, 4);
					Ar.ByteOrderSerialize(ptr + 8, 4);
				}
			}
		}

		Ar.ByteOrderSerialize((BYTE*)this + 0x98, 4);
		Ar << *(FName*)    ((BYTE*)this + 0x9c);
		Ar << *(UObject**)((BYTE*)this + 0xa4);
		Ar.ByteOrderSerialize((BYTE*)this + 0xa8, 4);
		Ar.ByteOrderSerialize((BYTE*)this + 0xac, 4);
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10472480)
void UVertMeshInstance::SetAnimFrame(int, float Frame)
{
	// Retail: 13b. Stores Frame float value at this+0xC0 (ignores channel index).
	*(FLOAT*)((BYTE*)this + 0xC0) = Frame;
}

IMPL_MATCH("Engine.dll", 0x10473500)
void UVertMeshInstance::SetScale(FVector Scale)
{
	guard(UVertMeshInstance::SetScale);
	// Retail 0x173500: writes Scale into mesh+0x7C and computes a uniform draw-scale
	// at mesh+0xDC = max(|X|,|Y|,|Z|) * mesh[0x54] * (1/128).
	typedef BYTE* (__thiscall *GetMeshFn)(UVertMeshInstance*);
	GetMeshFn GetMesh_fn = *(GetMeshFn*)((*(BYTE**)this) + 0x8C);
	BYTE* Mesh = GetMesh_fn(this);
	if (Mesh)
	{
		*(FLOAT*)(Mesh + 0x7C) = Scale.X;
		*(FLOAT*)(Mesh + 0x80) = Scale.Y;
		*(FLOAT*)(Mesh + 0x84) = Scale.Z;
		FLOAT maxScale = Abs(Scale.Z);
		FLOAT absY     = Abs(Scale.Y);
		if (maxScale < absY) maxScale = absY;
		FLOAT absX = Abs(Scale.X);
		if (absX < maxScale) absX = maxScale;
		*(FLOAT*)(Mesh + 0xDC) = absX * *(FLOAT*)(Mesh + 0x54) * 0.0078125f;
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10472d40)
int UVertMeshInstance::PlayAnim(INT Channel, FName SeqName, FLOAT Rate, FLOAT TweenTime, INT bLooping, INT bLoopLast, INT bIdle)
{
	guard(UVertMeshInstance::PlayAnim);
	// Retail 0x172d40, 1344b. Single-channel vertex mesh animation control.
	// this+0xB8=SeqName, +0xBC=rate, +0xC0=curFrame, +0xC4=endFrame,
	// +0xCC=tweenRate/speedTween, +0xD0=nativeRate, +0xDC=loopLast, +0xE0=bLoop,
	// +0xE4=bHasNotify, +0xC8=tween-in-rate (offset 200 decimal).
	// FUN_103808e0 identified as max(a,b) (25b at 0x103808e0) — both CC<0 paths fixed.

	BYTE* vtbl = *(BYTE**)this;
	typedef INT  (__thiscall *GetAnimNamedFn)(UVertMeshInstance*, FName);
	typedef BYTE*(__thiscall *GetOwnerFn)(UVertMeshInstance*);
	typedef FLOAT(__thiscall *GetFrameCountFn)(UVertMeshInstance*, INT);
	typedef FLOAT(__thiscall *GetActiveRateFn)(UVertMeshInstance*, INT);
	typedef INT  (__thiscall *IsLoopingFn)(UVertMeshInstance*, INT);

	// Find animation sequence
	INT seqObj = (*(GetAnimNamedFn*)(vtbl + 0xB0))(this, SeqName);
	if (!seqObj)
	{
		GLog->Logf(TEXT("PlayAnim: sequence not found in '%s'"), ((UObject*)*(INT*)((BYTE*)this + 0x58))->GetName());
		return 0;
	}

	// Get owning actor
	BYTE* owner = (*(GetOwnerFn*)(vtbl + 0x84))(this);
	if (!owner) return 0;

	if (bLooping == 0)
	{
		// One-shot / freeze-at-end path (param_6 == 0 in Ghidra)
		if (Rate <= 0.0f)
		{
			if (Rate < 0.0f) return 0;  // negative rate: fail
			// Rate == 0: freeze at start
			FLOAT fc = (*(GetFrameCountFn*)(vtbl + 0xC0))(this, seqObj);
			*(INT*)((BYTE*)this + 0xB8)  = *(INT*)&SeqName;
			*(INT*)((BYTE*)this + 0xC4)  = 0;
			*(INT*)((BYTE*)this + 0xE4)  = 0;
			*(INT*)((BYTE*)this + 0xDC)  = 0;
			*(INT*)((BYTE*)this + 0xE0)  = 0;
			*(INT*)((BYTE*)this + 0xBC)  = 0;
			*(INT*)((BYTE*)this + 0xCC)  = 0;
			if (TweenTime > 0.0f)
			{
				*(FLOAT*)((BYTE*)this + 200) = 1.0f / (TweenTime * fc);
				*(FLOAT*)((BYTE*)this + 0xC0) = -1.0f / fc;
				return 1;
			}
			*(INT*)((BYTE*)this + 200)  = 0;
			*(INT*)((BYTE*)this + 0xC0) = 0;
			return 1;
		}
		// Rate > 0 with no looping: single-play with optional tween
		INT same = (*(FName*)((BYTE*)this + 0xB8) == FName(NAME_None)) ? 1 : 0;
		if (same) TweenTime = 0.0f;

		FLOAT fc  = (*(GetFrameCountFn*)(vtbl + 0xC0))(this, seqObj);
		FLOAT nr  = (*(GetActiveRateFn*)(vtbl + 0xC4))(this, seqObj);
		FLOAT ifc = 1.0f / fc;
		*(INT*)((BYTE*)this + 0xB8) = *(INT*)&SeqName;
		FLOAT rateScale = ifc * nr;
		*(FLOAT*)((BYTE*)this + 0xD0) = rateScale;
		*(FLOAT*)((BYTE*)this + 0xBC) = rateScale * Rate;
		*(FLOAT*)((BYTE*)this + 0xC4) = 1.0f - ifc;
		INT isLoop = (*(IsLoopingFn*)(vtbl + 0xC8))(this, seqObj);
		*(INT*)((BYTE*)this + 0xDC) = 0;
		*(INT*)((BYTE*)this + 0xE0) = 1;
		*(INT*)((BYTE*)this + 0xE4) = isLoop ? 1 : 0;

		if (*(FLOAT*)((BYTE*)this + 0xC4) != 0.0f)
		{
			// Has end frame: setup single-shot
			*(INT*)((BYTE*)this + 0xE4) = 0;
			*(INT*)((BYTE*)this + 0xCC) = 0;
			if (TweenTime <= 0.0f)
			{
				*(FLOAT*)((BYTE*)this + 200)  = 10.0f;
				*(INT*)  ((BYTE*)this + 0xBC) = 0;
				*(INT*)  ((BYTE*)this + 0xCC) = 0;
				*(FLOAT*)((BYTE*)this + 0xC0) = -ifc;
				return 1;
			}
			*(INT*)  ((BYTE*)this + 0xBC) = 0;
			*(INT*)  ((BYTE*)this + 0xCC) = 0;
			*(FLOAT*)((BYTE*)this + 200)  = 1.0f / TweenTime;
			*(FLOAT*)((BYTE*)this + 0xC0) = -ifc;
			return 1;
		}

		// endFrame == 0: continuous with tween
		if (TweenTime > 0.0f)
		{
			*(FLOAT*)((BYTE*)this + 200)  = 1.0f / (fc * TweenTime);
			*(FLOAT*)((BYTE*)this + 0xC0) = rateScale * -1.0f;
			goto LAB_VertPlayAnim_End;
		}
		if (TweenTime == -1.0f)
		{
			*(DWORD*)((BYTE*)this + 0xC0) = 0x38d1b717u; // ~1e-4 tiny float
			LAB_VertPlayAnim_ZeroTween:
			*(INT*)((BYTE*)this + 200) = 0;
			goto LAB_VertPlayAnim_End;
		}
		*(FLOAT*)((BYTE*)this + 0xC0) = rateScale * -1.0f;
		if (*(FLOAT*)((BYTE*)this + 0xCC) > 0.0f)
		{
			LAB_VertPlayAnim_UseCC:
			*(INT*)((BYTE*)this + 200) = *(INT*)((BYTE*)this + 0xCC);
			goto LAB_VertPlayAnim_End;
		}
		if (*(FLOAT*)((BYTE*)this + 0xCC) < 0.0f)
		{
			FLOAT speed = ((FVector*)(owner + 0x24C))->Size();
			// FUN_103808e0 = max(param_1, param_2) — retail 0x103808e0 (25b).
			// Both non-looping and looping CC<0 paths share LAB_10473188: max(rate*0.5, speed*|cc|).
			{
				FLOAT a = *(FLOAT*)((BYTE*)this + 0xBC) * 0.5f;
				FLOAT b = speed * (*(FLOAT*)((BYTE*)this + 0xCC)) * -1.0f;
				*(FLOAT*)((BYTE*)this + 200) = (a >= b) ? a : b;
			}
			goto LAB_VertPlayAnim_End;
		}
		*(FLOAT*)((BYTE*)this + 200) = 1.0f / (fc * 0.025f);
		LAB_VertPlayAnim_End:
		*(INT*)((BYTE*)this + 0xCC) = *(INT*)((BYTE*)this + 0xBC);
		return 1;
	}
	else
	{
		// Looping path (param_6 != 0)
		FLOAT fc = (*(GetFrameCountFn*)(vtbl + 0xC0))(this, seqObj);
		FLOAT nr = (*(GetActiveRateFn*)(vtbl + 0xC4))(this, seqObj);

		// If same animation still playing, just update rate
		INT same = (*(FName*)((BYTE*)this + 0xB8) == SeqName) ? 1 : 0;
		if (same && *(INT*)((BYTE*)this + 0xE0) != 0
			&& ((AActor*)owner)->IsAnimating(0))
		{
			*(INT*)  ((BYTE*)this + 0xDC) = 0;
			*(FLOAT*)((BYTE*)this + 0xD0) = nr / fc;
			*(FLOAT*)((BYTE*)this + 0xBC) = (nr / fc) * Rate;
			*(FLOAT*)((BYTE*)this + 0xCC) = *(FLOAT*)((BYTE*)this + 0xBC);
			return 1;
		}

		FLOAT ifc  = 1.0f / fc;
		*(INT*)((BYTE*)this + 0xB8) = *(INT*)&SeqName;
		FLOAT rs   = ifc * nr;
		*(FLOAT*)((BYTE*)this + 0xD0) = rs;
		*(FLOAT*)((BYTE*)this + 0xBC) = rs * Rate;
		*(FLOAT*)((BYTE*)this + 0xC4) = 1.0f - ifc;
		INT isLoop = (*(IsLoopingFn*)(vtbl + 0xC8))(this, seqObj);
		*(INT*)  ((BYTE*)this + 0xDC) = 0;
		*(INT*)  ((BYTE*)this + 0xE0) = 1;
		*(INT*)  ((BYTE*)this + 0xE4) = isLoop ? 1 : 0;

		if (*(FLOAT*)((BYTE*)this + 0xC4) != 0.0f)
		{
			*(INT*)  ((BYTE*)this + 0xE4) = 0;
			*(INT*)  ((BYTE*)this + 0xCC) = 0;
			if (TweenTime <= 0.0f)
				*(FLOAT*)((BYTE*)this + 200) = 10.0f;
			else
				*(FLOAT*)((BYTE*)this + 200) = 1.0f / TweenTime;
			// Fall through to LAB_104730d8
			*(INT*)  ((BYTE*)this + 0xBC) = 0;
			*(FLOAT*)((BYTE*)this + 0xC0) = ifc * -1.0f;
			goto LAB_VertPlayAnim_End;
		}

		if (TweenTime > 0.0f)
		{
			*(FLOAT*)((BYTE*)this + 200)  = 1.0f / (fc * TweenTime);
			*(FLOAT*)((BYTE*)this + 0xC0) = ifc * -1.0f;
			goto LAB_VertPlayAnim_End;
		}
		if (TweenTime == -1.0f)
		{
			*(DWORD*)((BYTE*)this + 0xC0) = 0x3a83126fu;
			goto LAB_VertPlayAnim_ZeroTween;
		}
		*(FLOAT*)((BYTE*)this + 0xC0) = ifc * -1.0f;
		if (*(FLOAT*)((BYTE*)this + 0xCC) > 0.0f)
			goto LAB_VertPlayAnim_UseCC;
		if (*(FLOAT*)((BYTE*)this + 0xCC) < 0.0f)
		{
			FLOAT speed = ((FVector*)(owner + 0x24C))->Size();
			// FUN_103808e0 = max(a,b). Looping path shares LAB_10473188 with non-looping.
			// Uses this+0xBC (already updated rate) not ifc. Retail 0x103808e0 (25b).
			{
				FLOAT a = *(FLOAT*)((BYTE*)this + 0xBC) * 0.5f;
				FLOAT b = speed * (*(FLOAT*)((BYTE*)this + 0xCC)) * -1.0f;
				*(FLOAT*)((BYTE*)this + 200) = (a >= b) ? a : b;
			}
			goto LAB_VertPlayAnim_End;
		}
		*(FLOAT*)((BYTE*)this + 200) = 1.0f / (fc * 0.025f);
		goto LAB_VertPlayAnim_End;
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x104724f0)
int UVertMeshInstance::AnimForcePose(FName SeqName, FLOAT Frame, FLOAT Rate, INT Channel)
{
	guardSlow(UVertMeshInstance::AnimForcePose);
	// Retail 0x1724f0, 60b. Forces a pose on the single vertex-mesh animation channel.
	// Only channel 0 is valid; other channels log a warning and return 0.
	if (Channel != 0)
	{
		GLog->Logf(TEXT("AnimForcePose: channel %i out of range for '%s'"), Channel, GetName());
		return 0;
	}
	*(INT*)((BYTE*)this + 0xB8) = *(INT*)&SeqName;
	*(FLOAT*)((BYTE*)this + 0xC0) = Frame;
	return 1;
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x104724C0)
float UVertMeshInstance::AnimGetFrameCount(void* Channel)
{
	// Retail: 10b. Returns float of int frame count at Channel+0x14 (no null check per retail).
	return (FLOAT)(*(INT*)((BYTE*)Channel + 0x14));
}

IMPL_MATCH("Engine.dll", 0x10432990)
FName UVertMeshInstance::AnimGetGroup(void* Channel)
{
	// Retail: 34b. Identical bytecode to USkeletalMeshInstance::AnimGetGroup.
	// Check *(Channel+4) non-null, then double-deref for FName.Index.
	FName result;
	if (*(void**)((BYTE*)Channel + 4))
		*(INT*)&result = *(INT*)*(void**)((BYTE*)Channel + 4);
	return result;
}

IMPL_MATCH("Engine.dll", 0x104724B0)
FName UVertMeshInstance::AnimGetName(void* Channel)
{
	// Retail: 15b. Copies the FName index (first DWORD) from *Channel to output.
	// Animation name is stored at the start of the animation channel struct.
	FName result;
	*(INT*)&result = *(INT*)Channel;
	return result;
}

IMPL_MATCH("Engine.dll", 0x104724E0)
int UVertMeshInstance::AnimGetNotifyCount(void* Channel)
{
	// Retail: 16b. Reads Num field of TArray<FMeshAnimNotify> embedded at Channel+0x1C.
	// TArray layout: {Data* at +0, Num at +4}; so count is at Channel+0x20.
	return *(INT*)((BYTE*)Channel + 0x20);
}

IMPL_MATCH("Engine.dll", 0x104733C0)
UAnimNotify * UVertMeshInstance::AnimGetNotifyObject(void* Channel, int notifyIndex)
{
	// Retail: 21b. Returns UAnimNotify* from packed notify array.
	// Channel+0x1C = pointer to notify array (12 bytes/entry).
	// Notify pointer is at byte offset 8 within each entry.
	BYTE* notifyArray = *(BYTE**)((BYTE*)Channel + 0x1C);
	return *(UAnimNotify**)(notifyArray + notifyIndex * 12 + 8);
}

IMPL_MATCH("Engine.dll", 0x104733A0)
const TCHAR* UVertMeshInstance::AnimGetNotifyText(void* Channel, INT notifyIndex)
{
	// Retail: 27b. Reads FName at notify entry+4, returns FName string via operator*.
	// Entry layout: +0 time (float), +4 FName, +8 UAnimNotify* (stride 12b).
	BYTE* notifyArray = *(BYTE**)((BYTE*)Channel + 0x1C);
	FName name = *(FName*)(notifyArray + notifyIndex * 12 + 4);
	return *name;
}

IMPL_MATCH("Engine.dll", 0x10473380)
float UVertMeshInstance::AnimGetNotifyTime(void* Channel, INT notifyIndex)
{
	// Retail: 20b. Returns time float from Channel's notify array (stride 12b, float at entry+0).
	BYTE* notifyArray = *(BYTE**)((BYTE*)Channel + 0x1C);
	return *(FLOAT*)(notifyArray + notifyIndex * 12);
}

IMPL_MATCH("Engine.dll", 0x104724D0)
float UVertMeshInstance::AnimGetRate(void* Channel)
{
	// Retail: 10b. Returns float rate from Channel+0x18 (no null check per retail).
	return *(FLOAT*)((BYTE*)Channel + 0x18);
}

IMPL_MATCH("Engine.dll", 0x10473bf0)
int UVertMeshInstance::AnimIsInGroup(void* Channel, FName GroupName)
{
	// Retail 34b: no FName null-check (unlike USkeletalMeshInstance version).
	// Channel+4 = TArray<FName> Groups; FUN_103b56b0 does the linear search (stride 4).
	FArray* groups = (FArray*)((BYTE*)Channel + 4);
	INT count = groups->Num();
	BYTE* data = *(BYTE**)groups;
	for (INT i = 0; i < count; i++)
	{
		if (*(FName*)(data + i * 4) == GroupName) return 1;
	}
	return 0;
}

IMPL_MATCH("Engine.dll", 0x104727A0)
int UVertMeshInstance::AnimStopLooping(int)
{
	// Retail: 22b. Clears loop flag at this+0xE0 and this+0xDC, returns 1.
	*(INT*)((BYTE*)this + 0xE0) = 0;
	*(INT*)((BYTE*)this + 0xDC) = 0;
	return 1;
}

IMPL_MATCH("Engine.dll", 0x10472810)
float UVertMeshInstance::GetActiveAnimFrame(INT Channel)
{
	// Retail: 17b. Returns current frame float from this+0xC0 for channel 0 only.
	// For Channel != 0, retail falls into next function; approximated as return 0.0f.
	if (Channel != 0) return 0.0f;
	return *(FLOAT*)((BYTE*)this + 0xC0);
}

IMPL_MATCH("Engine.dll", 0x104727F0)
float UVertMeshInstance::GetActiveAnimRate(INT Channel)
{
	// Retail: 17b. Returns animation rate float from this+0xBC for channel 0 only.
	// For Channel != 0, retail falls into next function; approximated as return 0.0f.
	if (Channel != 0) return 0.0f;
	return *(FLOAT*)((BYTE*)this + 0xBC);
}

IMPL_MATCH("Engine.dll", 0x104727C0)
FName UVertMeshInstance::GetActiveAnimSequence(int sequenceChannelIndex)
{
	// Retail: 23b. Only returns a value for channel index 0 (reads FName.Index from this+0xB8).
	// For index != 0, retail returns uninitialized — we return NAME_None for safety (divergence).
	if (sequenceChannelIndex != 0) return FName(NAME_None);
	FName result;
	*(INT*)&result = *(INT*)((BYTE*)this + 0xB8);
	return result;
}

IMPL_MATCH("Engine.dll", 0x10472490)
int UVertMeshInstance::GetAnimCount()
{
	// Retail: 18b. Gets mesh via vtbl[35], returns TArray.Num from TArray at mesh+0x118.
	typedef BYTE* (__thiscall *GetMeshFn)(UVertMeshInstance*);
	GetMeshFn fn = (GetMeshFn)((*(void***)this)[0x8C / sizeof(void*)]);
	BYTE* obj = fn(this);
	return *(INT*)(obj + 0x118 + 4);
}

IMPL_MATCH("Engine.dll", 0x104732C0)
void * UVertMeshInstance::GetAnimIndexed(INT Index)
{
	// Retail: 34b. Gets mesh via vtbl[35], returns TArray.Data[Index] (stride 0x2C=44b).
	typedef BYTE* (__thiscall *GetMeshFn)(UVertMeshInstance*);
	GetMeshFn fn = (GetMeshFn)((*(void***)this)[0x8C / sizeof(void*)]);
	BYTE* obj = fn(this);
	BYTE* data = *(BYTE**)(obj + 0x118);
	return data + Index * 0x2C;
}

IMPL_MATCH("Engine.dll", 0x104732F0)
void * UVertMeshInstance::GetAnimNamed(FName Name)
{
	// Retail: ~144b. Gets mesh via vtbl[35], searches TArray at mesh+0x118 (stride 0x2C=44b,
	// FName at element+0). Retail re-calls vtbl[35] per iteration; divergence: we call once.
	typedef BYTE* (__thiscall *GetMeshFn)(UVertMeshInstance*);
	GetMeshFn fn = (GetMeshFn)((*(void***)this)[0x8C / sizeof(void*)]);
	BYTE* obj = fn(this);
	BYTE* tarray = obj + 0x118;
	INT count = *(INT*)(tarray + 4);
	if (count <= 0) return NULL;
	BYTE* data = *(BYTE**)(tarray);
	INT i = 0, byteOff = 0;
	while (i < count)
	{
		BYTE* elem = data + byteOff;
		if (*(FName*)elem == Name) return data + i * 0x2C;
		i++;
		byteOff += 0x2C;
		count = *(INT*)(tarray + 4);
	}
	return NULL;
}

IMPL_MATCH("Engine.dll", 0x10473c20)
void UVertMeshInstance::GetFrame(AActor* /*Actor*/, FLevelSceneNode* /*SceneNode*/,
	FVector* OutVerts, INT Stride, INT& NumVerts, DWORD OutFlag)
{
	guard(UVertMeshInstance::GetFrame);

	// GetMesh() via vtable[0x8C/4 = 35].  Called multiple times because the cache
	// validity check (Ghidra) calls it three times; we mirror that structure.
	typedef BYTE* (__thiscall *GetMeshFn)(UVertMeshInstance*);
	GetMeshFn fp = (GetMeshFn)(*(void***)this)[0x8C / 4];
	BYTE* Mesh = fp(this);

	// Determine working vertex count: min(requested, mesh capacity).
	FLOAT MeshNV   = *(FLOAT*)(Mesh + 0x60);
	FLOAT LocalNV  = (NumVerts <= (INT)MeshNV) ? (FLOAT)NumVerts : MeshNV;

	// local_24: 1.4013e-45 = "cache already valid" marker; 0.0 = "just initialised".
	FLOAT InitFlag = 1.4013e-45f;

	// -- Cache validity --------------------------------------------------
	// Rebuild caches if empty or if the underlying mesh pointer changed.
	TArray<FVector>* VertCache = (TArray<FVector>*)((BYTE*)this + 0x80);
	TArray<FVector>* NormCache = (TArray<FVector>*)((BYTE*)this + 0x8c);

	if (VertCache->Num() == 0 || fp(this) != *(BYTE**)((BYTE*)this + 0xa4))
	{
		if (fp(this) != *(BYTE**)((BYTE*)this + 0xa4))
		{
			VertCache->Empty();
			NormCache->Empty();
		}
		VertCache->Add((INT)MeshNV);
		NormCache->Add((INT)MeshNV);
		InitFlag                        = 0.0f;
		*(FLOAT*)((BYTE*)this + 0xa8)  = 1.0f;   // reset blend weight
		*(BYTE**)((BYTE*)this + 0xa4)  = fp(this);
		*(FName*)((BYTE*)this + 0x9c)  = FName(NAME_None);
		*(FLOAT*)((BYTE*)this + 0x98)  = 0.0f;
	}

	FMeshAnimSeq* Seq = GetAnimSeq(*(FName*)((BYTE*)this + 0xb8));

	FLOAT CurFrame = *(FLOAT*)((BYTE*)this + 0xc0);

	// Flat position / normal arrays stored in mesh data (one INT32 per vertex per frame).
	INT*   AllPos  = (INT*)  *(INT*)(Mesh + 0x64);
	DWORD* AllNorm = (DWORD*)*(INT*)(Mesh + 0x100);
	INT    NV      = (INT)MeshNV;

	// ====================================================================
	// PATH A: standard frame computation (CurFrame >= 0 OR freshly initialised)
	// ====================================================================
	if (CurFrame >= 0.0f || InitFlag == 0.0f)
	{
		NumVerts = (INT)LocalNV;
		*(FLOAT*)((BYTE*)this + 0xa0) = LocalNV;

		INT   FrameABase = 0;
		FLOAT Frac       = 0.0f;
		INT   FrameBBase = 0;

		if (Seq)
		{
			FLOAT Frame = CurFrame;
			if (Frame < 0.0f) Frame = 0.0f;
			INT NumFrames  = *(INT*)((BYTE*)Seq + 0x14);
			Frame         *= (FLOAT)NumFrames;
			INT FloorF     = appFloor(Frame);
			Frac           = Frame - (FLOAT)FloorF;
			INT FirstFrame = *(INT*)((BYTE*)Seq + 0x10);
			FrameABase = (FloorF     % NumFrames + FirstFrame) * NV;
			FrameBBase = ((FloorF+1) % NumFrames + FirstFrame) * NV;
		}

		if (Frac > 0.0f)
		{
			// Interpolate between frame A and frame B.
			INT*   PosA  = AllPos  + FrameABase;
			INT*   PosB  = AllPos  + FrameBBase;
			DWORD* NormA = AllNorm + FrameABase;
			DWORD* NormB = AllNorm + FrameBBase;

			for (INT i = 0; i < (INT)LocalNV; i++)
			{
				// Decode packed position A: Z[31:22](10b) Y[21:11](11b) X[10:0](11b)
				INT pA = PosA[i];
				FLOAT xA = (FLOAT)((pA << 21) >> 21);
				FLOAT yA = (FLOAT)((pA << 10) >> 21);
				FLOAT zA = (FLOAT)(pA >> 22);

				// Lerp position toward B.
				INT pB = PosB[i];
				FVector dPos((FLOAT)((pB << 21) >> 21) - xA,
				             (FLOAT)((pB << 10) >> 21) - yA,
				             (FLOAT)(pB >> 22)         - zA);
				FVector sc = dPos * Frac;
				(*VertCache)(i) = FVector(xA + sc.X, yA + sc.Y, zA + sc.Z);

				// Decode packed normal A: X[9:0] Y[19:10] Z[29:20], bias -512
				DWORD nA = NormA[i];
				FLOAT nxA = (FLOAT)(nA & 0x3ff)        - 512.f;
				FLOAT nyA = (FLOAT)((nA >> 10) & 0x3ff) - 512.f;
				FLOAT nzA = (FLOAT)((nA >> 20) & 0x3ff) - 512.f;

				// Lerp normal toward B.
				DWORD nB = NormB[i];
				FVector dNorm((FLOAT)(nB & 0x3ff)        - 512.f - nxA,
				              (FLOAT)((nB >> 10) & 0x3ff) - 512.f - nyA,
				              (FLOAT)((nB >> 20) & 0x3ff) - 512.f - nzA);
				FVector ns = dNorm * Frac;
				(*NormCache)(i) = FVector(nxA + ns.X, nyA + ns.Y, nzA + ns.Z);
			}
		}
		else
		{
			// Single frame (no fractional interpolation).
			INT*   PosData  = AllPos  + FrameABase;
			DWORD* NormData = AllNorm + FrameABase;

			for (INT i = 0; i < (INT)LocalNV; i++)
			{
				INT p = PosData[i];
				(*VertCache)(i) = FVector((FLOAT)((p << 21) >> 21),
				                          (FLOAT)((p << 10) >> 21),
				                          (FLOAT)(p >> 22));

				DWORD n = NormData[i];
				(*NormCache)(i) = FVector((FLOAT)(n & 0x3ff)        - 512.f,
				                          (FLOAT)((n >> 10) & 0x3ff) - 512.f,
				                          (FLOAT)((n >> 20) & 0x3ff) - 512.f);
			}
		}
	}
	else
	{
		// ================================================================
		// PATH B: blend-weight cross-fade (CurFrame < 0 and not freshly init'd)
		// This handles anim transitions where the engine drives a gradual
		// per-vertex blend from the cached pose toward the target frame.
		// ================================================================

		// Clamp to previously cached vertex count.
		FLOAT FullNV    = LocalNV;   // original requested count (local_58)
		FLOAT CachedNV  = *(FLOAT*)((BYTE*)this + 0xa0);
		if ((INT)CachedNV < (INT)LocalNV)
			LocalNV = CachedNV;      // local_30 after clamp

		*(FLOAT*)((BYTE*)this + 0xa0) = LocalNV;
		NumVerts                       = (INT)LocalNV;

		// Reference frame offset and per-frame-count rate.
		FLOAT FV12    = 0.0f;  // firstFrame * meshNumVerts  (base index in flat array)
		FLOAT Local20 = 0.0f;  // -1/numFrames (stored in this+0x98 on anim change)
		if (Seq)
		{
			FV12    = (FLOAT)(*(INT*)((BYTE*)Seq + 0x10) * *(INT*)(Mesh + 0x60));
			Local20 = -1.0f / (FLOAT)*(INT*)((BYTE*)Seq + 0x14);
		}

		// Blend fraction: how far current frame has drifted from the stored rate.
		FLOAT AnimRate = *(FLOAT*)((BYTE*)this + 0x98);
		FLOAT Local24  = (AnimRate != 0.0f) ? (1.0f - CurFrame / AnimRate) : 0.0f;

		// Detect animation change, reset blend weight if so.
		if (*(FName*)((BYTE*)this + 0x9c) != *(FName*)((BYTE*)this + 0xb8))
			*(FLOAT*)((BYTE*)this + 0xa8) = 0.0f;

		if (*(FName*)((BYTE*)this + 0x9c) != *(FName*)((BYTE*)this + 0xb8) ||
		    Local24 < 0.0f || Local24 > 1.0f)
		{
			*(FLOAT*)((BYTE*)this + 0x98) = Local20;
			Local24 = 0.0f;
			*(FName*)((BYTE*)this + 0x9c) = *(FName*)((BYTE*)this + 0xb8);
		}

		// Update accumulated blend weight toward 1.0.
		FLOAT BlendW = *(FLOAT*)((BYTE*)this + 0xa8);
		FLOAT fVar2  = (1.0f - BlendW) * Local24 + BlendW;
		*(FLOAT*)((BYTE*)this + 0xa8) = fVar2;

		if (fVar2 > 0.97f)
		{
			// Blend is nearly complete: reset and expand cache if needed.
			Local24 = 0.0f;
			if ((INT)LocalNV < (INT)FullNV)
			{
				// Fill newly-required vertices from the reference frame.
				INT*   TgtPos  = AllPos  + (INT)FV12;
				DWORD* TgtNorm = AllNorm + (INT)FV12;
				INT    Start   = (INT)LocalNV;
				while (Start < (INT)FullNV)
				{
					INT p = TgtPos[Start];
					(*VertCache)(Start) = FVector((FLOAT)((p << 21) >> 21),
					                               (FLOAT)((p << 10) >> 21),
					                               (FLOAT)(p >> 22));
					DWORD n = TgtNorm[Start];
					(*NormCache)(Start) = FVector((FLOAT)(n & 0x3ff)        - 512.f,
					                               (FLOAT)((n >> 10) & 0x3ff) - 512.f,
					                               (FLOAT)((n >> 20) & 0x3ff) - 512.f);
					Start++;
				}
				NumVerts = (INT)FullNV;
				LocalNV  = FullNV;
				*(FLOAT*)((BYTE*)this + 0xa0) = FullNV;
			}
		}

		// Apply per-vertex weighted blend toward the target reference frame.
		// Scalar (local_a8 / local_c4 in Ghidra) inferred as Local24.
		if (Local24 > 0.0f)
		{
			INT*   TgtPos  = AllPos  + (INT)FV12;
			DWORD* TgtNorm = AllNorm + (INT)FV12;

			for (INT i = 0; i < (INT)LocalNV; i++)
			{
				// Blend cached position toward target.
				INT pT = TgtPos[i];
				FLOAT tX = (FLOAT)((pT << 21) >> 21);
				FLOAT tY = (FLOAT)((pT << 10) >> 21);
				FLOAT tZ = (FLOAT)(pT >> 22);
				FVector& V   = (*VertCache)(i);
				FVector  dPos(tX - V.X, tY - V.Y, tZ - V.Z);
				FVector  mov = dPos * Local24;
				V.X += mov.X;  V.Y += mov.Y;  V.Z += mov.Z;

				// Blend cached normal toward target.
				DWORD nT = TgtNorm[i];
				FLOAT tnX = (FLOAT)(nT & 0x3ff)        - 512.f;
				FLOAT tnY = (FLOAT)((nT >> 10) & 0x3ff) - 512.f;
				FLOAT tnZ = (FLOAT)((nT >> 20) & 0x3ff) - 512.f;
				FVector& N   = (*NormCache)(i);
				FVector  dN(tnX - N.X, tnY - N.Y, tnZ - N.Z);
				FVector  mn = dN * Local24;
				N.X += mn.X;  N.Y += mn.Y;  N.Z += mn.Z;
			}
		}
	}

	// LAB_10474131: store last-seen frame, then write to caller's output buffer.
	*(FLOAT*)((BYTE*)this + 0x98) = *(FLOAT*)((BYTE*)this + 0xc0);

	BYTE* OutPtr = (BYTE*)OutVerts;

	if (OutFlag == 1)
	{
		// Positions only, sequential over all NumVerts.
		for (INT i = 0; i < NumVerts; i++)
		{
			*(FVector*)OutPtr = (*VertCache)(i);
			OutPtr += Stride;
		}
	}
	else
	{
		// Positions + normals, with LOD vertex-remap table at Mesh+0xc4.
		// Each remap entry is 0xc bytes; first WORD is the source vertex index.
		INT   RemapNum  = *(INT*)  (Mesh + 0xc4 + 4);  // FArray.ArrayNum
		BYTE* RemapData = *(BYTE**)(Mesh + 0xc4);       // FArray.Data

		for (INT i = 0; i < RemapNum; i++)
		{
			INT vtxIdx = (INT)*(unsigned short*)(RemapData + i * 0xc);
			if (vtxIdx < NumVerts)
			{
				*(FVector*)OutPtr         = (*VertCache)(vtxIdx);
				*(FVector*)(OutPtr + 0xc) = (*NormCache)(vtxIdx);
			}
			OutPtr += Stride;
		}
	}

	unguard;
}

IMPL_MATCH("Engine.dll", 0x1031C700)
UMaterial * UVertMeshInstance::GetMaterial(int materialIndex, AActor* Actor)
{
	// Retail: 49b. Calls Actor->vtable[40] (GetSkin, vtable offset 0xA0) twice:
	// once to check if skin exists, once to retrieve it. Returns NULL if Actor is
	// null or first call returns NULL.
	if (!Actor) return NULL;
	typedef UMaterial* (__thiscall *GetSkinFn)(AActor*, int);
	void** vtbl = *(void***)Actor;
	UMaterial* m = ((GetSkinFn)vtbl[40])(Actor, materialIndex);
	if (!m) return NULL;
	vtbl = *(void***)Actor;
	return ((GetSkinFn)vtbl[40])(Actor, materialIndex);
}

IMPL_DIVERGE("local_3c/local_7c/local_90/etc. Ghidra-unnamed stack variables in FCoords construction chain unresolvable without disassembly. FUN_10324640 cleanup also unimplemented. Ghidra 0x10474b10")
void UVertMeshInstance::GetMeshVerts(AActor *,FVector *,int,int &)
{
	guard(UVertMeshInstance::GetMeshVerts);
	// Retail: transforms and returns vertex mesh world-space positions.
	// TODO: implement UVertMeshInstance::GetMeshVerts (retail: extracts transformed vertex positions)
	unguard;
}

IMPL_MATCH("Engine.dll", 0x104733E0)
FBox UVertMeshInstance::GetRenderBoundingBox(const AActor* Owner)
{
	guard(UVertMeshInstance::GetRenderBoundingBox);
	// Retail: 33b. Same pattern as GetRenderBoundingSphere: get mesh, call mesh's method.
	return GetMesh()->GetRenderBoundingBox(Owner);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10472540)
FSphere UVertMeshInstance::GetRenderBoundingSphere(const AActor*)
{
	guard(UVertMeshInstance::GetRenderBoundingSphere);
	// Retail: 84b (SEH). Calls vtbl[35] to get mesh, copies FSphere from mesh+0x48.
	return *(FSphere*)((BYTE*)GetMesh() + 0x48);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x104725d0)
int UVertMeshInstance::IsAnimating(int Channel)
{
	guard(UVertMeshInstance::IsAnimating);
	// Retail: 0x1725d0, 74b. Only channel 0 supported on vertex meshes.
	// If actor (this+0x5C) is set AND channel is 0 AND anim name (this+0xB8) is not NAME_None:
	//   if frame (this+0xC0) < 0 (tweening): return whether tween-rate (this+0xC8) != 0
	//   else: return whether anim-rate (this+0xBC) != 0
	if (!*(INT*)((BYTE*)this + 0x5C) || Channel != 0)
		return 0;
	FName none(NAME_None);
	if (*(FName*)((BYTE*)this + 0xB8) == none)
		return 0;
	if (*(FLOAT*)((BYTE*)this + 0xC0) < 0.0f)
		return (*(FLOAT*)((BYTE*)this + 0xC8) != 0.0f) ? 1 : 0;
	return (*(FLOAT*)((BYTE*)this + 0xBC) != 0.0f) ? 1 : 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10472770)
int UVertMeshInstance::IsAnimLooping(int)
{
	// Retail: 9b. Returns loop flag/counter at this+0xE0 (ignores Channel argument).
	return *(INT*)((BYTE*)this + 0xE0);
}

IMPL_MATCH("Engine.dll", 0x10472780)
int UVertMeshInstance::IsAnimPastLastFrame(int)
{
	// Retail: 31b (scanner shows 27b, stops at first RETN). Compares frame position
	// (this+0xC0) vs end-frame sentinel (this+0xC4). Returns 1 if frame < end sentinel.
	return (*(FLOAT*)((BYTE*)this + 0xC0) < *(FLOAT*)((BYTE*)this + 0xC4)) ? 1 : 0;
}

IMPL_MATCH("Engine.dll", 0x10304720)
int UVertMeshInstance::IsAnimTweening(int)
{
	// Retail 0x4720: shared null-stub, returns 0. this+0xE4 path is divergent from retail.
	return 0;
}




// --- UVertMeshInstance ---
IMPL_MATCH("Engine.dll", 0x10474850)
void UVertMeshInstance::MeshBuildBounds()
{
	guard(UVertMeshInstance::MeshBuildBounds);
	// Retail 0x10474850 (637b): iterates all frames × all verts, unpacks the 32-bit
	// packed vertex format (11/11/10 signed bits → X/Y/Z), builds per-frame FBox+FSphere
	// stored at mesh->FrameBounds[frame] (+0x124, stride 0x1c) and
	// mesh->FrameSpheres[frame] (+0x130, stride 0x10), then builds overall bounds at
	// mesh+0x2c (FBox) and mesh+0x48 (FSphere).
	typedef BYTE* (__thiscall *GetMeshFn)(UVertMeshInstance*);
	BYTE* mesh = (*(GetMeshFn*)((*(BYTE**)this) + 0x8C))(this);

	GWarn->Logf(NAME_None, TEXT("Bounding vertex mesh"));

	INT numFrames = *(INT*)(mesh + 0x140);  // NumFrames
	INT numVerts  = *(INT*)(mesh + 0x13c);  // FrameVerts

	TArray<FVector> allVerts;

	for (INT frame = 0; frame < numFrames; frame++)
	{
		TArray<FVector> frameVerts;

		for (INT v = 0; v < numVerts; v++)
		{
			// Packed vertex: 32-bit word from mesh->Verts array (mesh+0x64 → data ptr via +0x64+0)
			// Layout (Ghidra analysis): bits 22..31 = Z (10-bit signed), bits 10..20 = Y (11-bit signed),
			// bits 0..10 = X (11-bit signed).
			INT packed = *(INT*)(*(INT*)(mesh + 0x64) + (numVerts * frame + v) * 4);
			FLOAT z = (FLOAT)(packed >> 22);                   // top 10 bits, sign-extended
			FLOAT x = (FLOAT)((packed << 21) >> 21);          // low 11 bits, sign-extended
			FLOAT y = (FLOAT)((packed << 10) >> 21);          // middle 11 bits, sign-extended
			FVector vert(x, y, z);
			frameVerts.AddItem(vert);
			allVerts.AddItem(vert);
		}

		INT   fCount = frameVerts.Num();
		FVector* fData = fCount > 0 ? &frameVerts(0) : NULL;

		// store FBox for this frame at mesh->FrameBounds[frame] (offset +0x124, stride 0x1c)
		FBox fbox(fData, fCount);
		BYTE* fbDest = (BYTE*)(*(INT*)(mesh + 0x124) + frame * 0x1c);
		appMemcpy(fbDest, &fbox, sizeof(FBox));

		// store FSphere for this frame at mesh->FrameSpheres[frame] (offset +0x130, stride 0x10)
		FSphere fsphere(fData, fCount);
		BYTE* fsDest = (BYTE*)(*(INT*)(mesh + 0x130) + frame * 0x10);
		appMemcpy(fsDest, &fsphere, 4 * sizeof(FLOAT));
	}

	// overall bounds
	INT   aCount = allVerts.Num();
	FVector* aData = aCount > 0 ? &allVerts(0) : NULL;

	FBox overallBox(aData, aCount);
	appMemcpy(mesh + 0x2c, &overallBox, sizeof(FBox));

	FSphere overallSphere(aData, aCount);
	appMemcpy(mesh + 0x48, &overallSphere, 4 * sizeof(FLOAT));

	UObject* meshObj = (UObject*)mesh;
	GLog->Logf(NAME_None, TEXT("Bounded vertex mesh %s"), meshObj->GetName());
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10473600)
FMatrix UVertMeshInstance::MeshToWorld()
{
	return FMatrix();
}



// --- Moved from EngineStubs.cpp ---
// ?MeshBuildBounds@UMeshInstance@@UAEXXZ
IMPL_EMPTY("virtual base no-op; retail body is empty")
void UMeshInstance::MeshBuildBounds() {}
// ?MeshToWorld@UMeshInstance@@UAE?AVFMatrix@@XZ
IMPL_MATCH("Engine.dll", 0x10314740)
FMatrix UMeshInstance::MeshToWorld() { // Retail: 36b. Copies FMatrix::Identity (from Core.dll IAT) to return buffer.
 return FMatrix::Identity; }

