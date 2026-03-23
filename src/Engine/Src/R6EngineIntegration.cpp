/*=============================================================================
	R6EngineIntegration.cpp: R6-specific types hosted in Engine.dll
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/
#pragma optimize("", off)

// Placement new for placement-new stubs in this TU.
#include "EnginePrivate.h"
#pragma warning(push)
#pragma warning(disable: 4291)
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EngineDecls.h"

// --- AR6AbstractCircumstantialActionQuery ---
// Lazily-initialised property RepIndex cache (mirrors DAT_10666b28/b24/b20... globals).
// UPackageMap vtable slot 25 (offset 0x64) maps actor-object references.
IMPL_MATCH("Engine.dll", 0x10377620)
INT* AR6AbstractCircumstantialActionQuery::GetOptimizedRepList(BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan)
{
	guard(AR6AbstractCircumstantialActionQuery::GetOptimizedRepList);
static DWORD  s_InitFlags            = 0;
static INT*   s_iHasAction            = NULL;
static INT*   s_iInRange              = NULL;
static INT*   s_aQueryOwner           = NULL;
static INT*   s_aQueryTarget          = NULL;
static INT*   s_textureIcon           = NULL;
static INT*   s_bCanBeInterrupted     = NULL;
static INT*   s_fPlayerActionTime     = NULL;
static INT*   s_iPlayerActionID       = NULL;
static INT*   s_iTeamActionIDList     = NULL;
static INT*   s_iTeamSubActionsIDList = NULL;

typedef INT* (__thiscall *PackageMapFn)(UPackageMap*, INT);
PackageMapFn pfnMap = *(PackageMapFn*)(*(INT*)Map + 0x64);

Ptr = AActor::GetOptimizedRepList(Mem, Retire, Ptr, Map, Chan);

if (*(BYTE*)((BYTE*)this + 0x2d) == 4)
{
if (*(BYTE*)((BYTE*)this + 0x394) != *(BYTE*)(Mem + 0x394))
{
if (!(s_InitFlags & 1)) { s_InitFlags |= 1; s_iHasAction = (INT*)UObject::StaticFindObjectChecked(UProperty::StaticClass(), StaticClass(), TEXT("iHasAction"), 0); }
*Ptr++ = *(unsigned short*)((BYTE*)s_iHasAction + 0x4a);
}
if (*(BYTE*)((BYTE*)this + 0x395) != *(BYTE*)(Mem + 0x395))
{
if (!(s_InitFlags & 2)) { s_InitFlags |= 2; s_iInRange = (INT*)UObject::StaticFindObjectChecked(UProperty::StaticClass(), StaticClass(), TEXT("iInRange"), 0); }
*Ptr++ = *(unsigned short*)((BYTE*)s_iInRange + 0x4a);
}
{
INT iOwner1 = *(INT*)((BYTE*)this + 0x3c0), iOwner2 = *(INT*)(Mem + 0x3c0);
bool bSameOwner = pfnMap(Map, iOwner1) ? (iOwner1 == iOwner2) : (*(INT*)(Chan + 0x8c) = 1, iOwner2 == 0);
if (!bSameOwner) {
if (!(s_InitFlags & 4)) { s_InitFlags |= 4; s_aQueryOwner = (INT*)UObject::StaticFindObjectChecked(UProperty::StaticClass(), StaticClass(), TEXT("aQueryOwner"), 0); }
*Ptr++ = *(unsigned short*)((BYTE*)s_aQueryOwner + 0x4a);
}
}
{
INT iTgt1 = *(INT*)((BYTE*)this + 0x3c4), iTgt2 = *(INT*)(Mem + 0x3c4);
bool bSameTgt = pfnMap(Map, iTgt1) ? (iTgt1 == iTgt2) : (*(INT*)(Chan + 0x8c) = 1, iTgt2 == 0);
if (!bSameTgt) {
if (!(s_InitFlags & 8)) { s_InitFlags |= 8; s_aQueryTarget = (INT*)UObject::StaticFindObjectChecked(UProperty::StaticClass(), StaticClass(), TEXT("aQueryTarget"), 0); }
*Ptr++ = *(unsigned short*)((BYTE*)s_aQueryTarget + 0x4a);
}
}
{
INT iIco1 = *(INT*)((BYTE*)this + 0x3c8), iIco2 = *(INT*)(Mem + 0x3c8);
bool bSameIco = pfnMap(Map, iIco1) ? (iIco1 == iIco2) : (*(INT*)(Chan + 0x8c) = 1, iIco2 == 0);
if (!bSameIco) {
if (!(s_InitFlags & 0x10)) { s_InitFlags |= 0x10; s_textureIcon = (INT*)UObject::StaticFindObjectChecked(UProperty::StaticClass(), StaticClass(), TEXT("textureIcon"), 0); }
*Ptr++ = *(unsigned short*)((BYTE*)s_textureIcon + 0x4a);
}
}
if ((*(DWORD*)((BYTE*)this + 0x3b4) ^ *(DWORD*)(Mem + 0x3b4)) & 1)
{
if (!(s_InitFlags & 0x20)) { s_InitFlags |= 0x20; s_bCanBeInterrupted = (INT*)UObject::StaticFindObjectChecked(UProperty::StaticClass(), StaticClass(), TEXT("bCanBeInterrupted"), 0); }
*Ptr++ = *(unsigned short*)((BYTE*)s_bCanBeInterrupted + 0x4a);
}
if (*(INT*)((BYTE*)this + 0x3b8) != *(INT*)(Mem + 0x3b8))
{
if (!(s_InitFlags & 0x40)) { s_InitFlags |= 0x40; s_fPlayerActionTime = (INT*)UObject::StaticFindObjectChecked(UProperty::StaticClass(), StaticClass(), TEXT("fPlayerActionTimeRequired"), 0); }
*Ptr++ = *(unsigned short*)((BYTE*)s_fPlayerActionTime + 0x4a);
}
if (*(BYTE*)((BYTE*)this + 0x396) != *(BYTE*)(Mem + 0x396))
{
if (!(s_InitFlags & 0x80)) { s_InitFlags |= 0x80; s_iPlayerActionID = (INT*)UObject::StaticFindObjectChecked(UProperty::StaticClass(), StaticClass(), TEXT("iPlayerActionID"), 0); }
*Ptr++ = *(unsigned short*)((BYTE*)s_iPlayerActionID + 0x4a);
}
if (!(s_InitFlags & 0x100)) { s_InitFlags |= 0x100; s_iTeamActionIDList = (INT*)UObject::StaticFindObjectChecked(UProperty::StaticClass(), StaticClass(), TEXT("iTeamActionIDList"), 0); }
for (DWORD i = 0; i < 4; i++)
if (*(BYTE*)((BYTE*)this + 0x398 + i) != *(BYTE*)(Mem + 0x398 + i))
*Ptr++ = *(unsigned short*)((BYTE*)s_iTeamActionIDList + 0x4a) + (INT)i;
if (!(s_InitFlags & 0x200)) { s_InitFlags |= 0x200; s_iTeamSubActionsIDList = (INT*)UObject::StaticFindObjectChecked(UProperty::StaticClass(), StaticClass(), TEXT("iTeamSubActionsIDList"), 0); }
for (DWORD i = 0; i < 16; i++)
if (*(BYTE*)((BYTE*)this + 0x39c + i) != *(BYTE*)(Mem + 0x39c + i))
*Ptr++ = *(unsigned short*)((BYTE*)s_iTeamSubActionsIDList + 0x4a) + (INT)i;
}
return Ptr;
	unguard;
}


// --- AR6ActionSpot ---
IMPL_EMPTY("AR6ActionSpot has no special editor geometry; retail body is guard/unguard only")
void AR6ActionSpot::RenderEditorInfo(FLevelSceneNode *,FRenderInterface *,FDynamicActor *)
{
	guard(AR6ActionSpot::RenderEditorInfo);
	unguard;
}

IMPL_DIVERGE("Ghidra 0x984a0: editor-only MapCheck function; GWarn vtable slot 0x28 (MapCheck) not declared in our headers — permanent divergence; debugf substitute is functionally equivalent for gameplay")
void AR6ActionSpot::CheckForErrors()
{
	guard(AR6ActionSpot::CheckForErrors);
	AActor::CheckForErrors();
	if (m_Anchor == NULL)
	{
		// Deviation: GWarn vtable slot 0x28 (MapCheck) not declared; use debugf.
		debugf(NAME_Warning, TEXT("No paths from %s"), GetName());
	}
	unguard;
}


// --- AR6ColBox ---
IMPL_MATCH("Engine.dll", 0x104766d0)
int AR6ColBox::ShouldTrace(AActor* param_1, DWORD param_2)
{
	guard(AR6ColBox::ShouldTrace);
	typedef INT (__fastcall *FShouldTraceFn)(void*, void*, AActor*, DWORD);
	INT* pOwner;
	FShouldTraceFn fn;

	// this+0x15c = owner actor, this+0x394 = collision flags byte
	if ((*(INT*)((BYTE*)this + 0x15c) != 0) && ((*(BYTE*)((BYTE*)this + 0x394) & 1) != 0))
	{
		// this+0x398 = activation radius; NAN(x)==(x==0.0) means x != 0
		if (*(FLOAT*)((BYTE*)this + 0x398) != 0.0f)
		{
			if (param_1 == NULL) goto LAB_10476755;
			if (*(AR6ColBox**)((BYTE*)param_1 + 0x184) == this)
				return 0;
			if ((*(INT*)((BYTE*)param_1 + 0x140) != 0) &&
				(*(AR6ColBox**)(*(INT*)((BYTE*)param_1 + 0x140) + 0x184) == this))
				return 0;
		}
		if ((param_1 == NULL) || (*(AR6ColBox**)((BYTE*)param_1 + 0x180) != this))
		{
		LAB_10476755:
			pOwner = *(INT**)((BYTE*)this + 0x15c);
			fn = *(FShouldTraceFn*)((BYTE*)*pOwner + 0xbc);
			return fn(pOwner, 0, param_1, param_2);
		}
	}
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10476ae0)
void AR6ColBox::SetBase(AActor* NewBase, FVector FloorNormal, int bNotifyActor)
{
	if (!NewBase) { EnableCollision(0, 0, 0); return; }
	AActor::SetBase(NewBase, FloorNormal, bNotifyActor);
}

IMPL_MATCH("Engine.dll", 0x10476bf0)
int AR6ColBox::CanStepUp(FVector vec)
{
	guardSlow(AR6ColBox::CanStepUp);
	// FVector passed as 3 scalar args in Ghidra; only Z component (vec.Z) is used
	// this+0x15c = owner actor, this+0x394 = collision flags, this+0x23c = CollisionHeight
	INT* pOwner = *(INT**)((BYTE*)this + 0x15c);
	if (((*(DWORD*)((BYTE*)this + 0x394) & 4) != 0) &&
		(pOwner != NULL) &&
		(*(INT*)((BYTE*)pOwner + 0x3a8) == 0) &&
		((*(DWORD*)((BYTE*)this + 0x394) & 1) != 0))
	{
		FLOAT fVar1 = *(FLOAT*)((BYTE*)this + 0x23c);  // this CollisionHeight
		FLOAT stepHeight = 25.0f;
		FLOAT fVar2 = *(FLOAT*)((BYTE*)pOwner + 0x23c);  // owner CollisionHeight
		UObject* pCol = *(UObject**)((BYTE*)pOwner + 0x15c);
		if (pCol != NULL)
		{
			if (pCol->IsA(ATerrainInfo::StaticClass()))
				stepHeight = 50.0f;
		}
		if (stepHeight <= (fVar1 - fVar2) + vec.Z)
			return 0;
	}
	return 1;
	unguardSlow;
}

IMPL_EMPTY("Body unknown; collision enable/disable logic requires Ghidra analysis")
void AR6ColBox::EnableCollision(int,int,int)
{
	guard(AR6ColBox::EnableCollision);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x104764b0)
void AR6ColBox::GetColBoxLocationFromOwner(FVector& result, float height)
{
	guard(AR6ColBox::GetColBoxLocationFromOwner);
	AActor* owner = *(AActor**)((BYTE*)this + 0x140);
	if (owner)
	{
		FVector dir = ((FRotator*)((BYTE*)owner + 0x240))->Vector();
		FVector offset = dir * height;
		result.X = offset.X + *(FLOAT*)((BYTE*)owner + 0x234);
		result.Y = offset.Y + *(FLOAT*)((BYTE*)owner + 0x238);
		result.Z = offset.Z + *(FLOAT*)((BYTE*)owner + 0x23c);
		return;
	}
	result = FVector(0.f, 0.f, 0.f);
	unguard;
}

IMPL_EMPTY("Body unknown; output parameters not populated without Ghidra analysis")
void AR6ColBox::GetDestination(FVector &,FRotator &)
{
	guard(AR6ColBox::GetDestination);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10476b20)
float AR6ColBox::GetMaxStepUp(bool param_1, float param_2)
{
	guardSlow(AR6ColBox::GetMaxStepUp);
	// this+0x15c = owner actor, this+0x394 = collision flags
	INT* pOwner = *(INT**)((BYTE*)this + 0x15c);

	if ((!param_1 &&
		((*(DWORD*)((BYTE*)this + 0x394) & 4) == 0 ||
		 (*(DWORD*)((BYTE*)this + 0x394) & 1) == 0)) ||
		(pOwner == NULL) ||
		(*(INT*)((BYTE*)pOwner + 0x3a8) != 0))
	{
		return 33.0f;
	}

	INT* pBase = *(INT**)((BYTE*)pOwner + 0x180);  // owner's Base (floor actor)
	FLOAT fVar1 = *(FLOAT*)((BYTE*)pBase + 0x23c) - *(FLOAT*)((BYTE*)pOwner + 0x23c);
	if (param_1)
		fVar1 = param_2;  // override with explicit param

	FLOAT stepHeight = 25.0f;
	UObject* pCol = *(UObject**)((BYTE*)pOwner + 0x15c);
	if (pCol != NULL)
	{
		if (pCol->IsA(ATerrainInfo::StaticClass()))
			stepHeight = 50.0f;
	}

	// Ghidra NaN check translates to: fVar1 > 0.0f && stepHeight <= fVar1 → return 0
	if (fVar1 > 0.0f && stepHeight <= fVar1)
		return 0.0f;

	return stepHeight - fVar1;
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x104767c0)
APawn * AR6ColBox::GetPawnOrColBoxOwner() const
{
	guard(AR6ColBox::GetPawnOrColBoxOwner);
	typedef APawn* (__fastcall *FGetPawnFn)(void*, void*);

	// this+0x140 = owner/attached-actor, this+0x398 = activation radius
	INT* piVar1 = *(INT**)((BYTE*)this + 0x140);

	if (*(FLOAT*)((BYTE*)this + 0x398) != 0.0f)  // NAN check => float != 0
	{
		if (piVar1 != NULL)
		{
			FGetPawnFn fn = *(FGetPawnFn*)((BYTE*)*piVar1 + 0x6c);
			return fn(piVar1, 0);
		}
	}
	else if (piVar1 != NULL)
	{
		FGetPawnFn fn = *(FGetPawnFn*)((BYTE*)*piVar1 + 0x68);
		return fn(piVar1, 0);
	}
	return NULL;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x104766a0)
int AR6ColBox::IsBlockedBy(AActor const* param_1) const
{
	guardSlow(AR6ColBox::IsBlockedBy);
	// this+0x15c = owner actor, this+0x394 = collision flags byte
	if ((*(INT*)((BYTE*)this + 0x15c) != 0) && ((*(BYTE*)((BYTE*)this + 0x394) & 1) != 0))
	{
		typedef INT (__fastcall *FIsBlockedByFn)(void*, void*);
		INT* pOwner = *(INT**)((BYTE*)this + 0x15c);
		FIsBlockedByFn fn = *(FIsBlockedByFn*)((BYTE*)*pOwner + 0x70);
		return fn(pOwner, 0);
	}
	return 0;
	unguardSlow;
}


// --- AR6DecalGroup ---
IMPL_EMPTY("Body unknown; decal group spawn initialization requires Ghidra analysis")
void AR6DecalGroup::Spawned()
{
	guard(AR6DecalGroup::Spawned);
	unguard;
}

IMPL_EMPTY("Body unknown; decal deactivation and cleanup require Ghidra analysis")
void AR6DecalGroup::KillDecal(AR6Decal *)
{
	guard(AR6DecalGroup::KillDecal);
	unguard;
}

IMPL_EMPTY("Body unknown; post-destroy decal cleanup requires Ghidra analysis")
void AR6DecalGroup::PostScriptDestroyed()
{
	guard(AR6DecalGroup::PostScriptDestroyed);
	unguard;
}

IMPL_EMPTY("Body unknown; decal group activation logic requires Ghidra analysis")
void AR6DecalGroup::ActivateGroup()
{
	guard(AR6DecalGroup::ActivateGroup);
	unguard;
}

IMPL_DIVERGE("FUN_1050557c (unexported PRNG returning decal ID) and FUN_10301000 (timestamp, possibly appSeconds but unexported) are permanently unresolvable; groupType==2 and main paths implemented; Ghidra 0x10476fb0")
int AR6DecalGroup::AddDecal(FVector* param_1, FRotator* param_2, UTexture* param_3, int param_4,
	float param_5, float param_6, float param_7, float param_8, int param_9)
{
	guard(AR6DecalGroup::AddDecal);
	// this+0x3a0 = group active flag, this+0x3a4 = decal actor array data ptr
	// this+0x39c = current decal index, this+0x398 = group capacity
	if (((*(BYTE*)((BYTE*)this + 0x3a0) & 1) != 0) && (param_3 != NULL))
	{
		AActor* this_00 = *(AActor**)(*(INT*)((BYTE*)this + 0x3a4) + *(INT*)((BYTE*)this + 0x39c) * 4);
		// FUN_1050557c = FString::Format/Printf — sets a formatted string on decal data.
		// Ghidra shows it initialises this_00+0x39c to 0 (already done below).
		DWORD uVar2 = 0;
		*(DWORD*)((BYTE*)this_00 + 0x39c) = uVar2;
		if ((*(BYTE*)((BYTE*)this_00 + 0x51c) & 1) != 0)
		{
			typedef void (__fastcall *FVtFn1)(void*, void*, INT);
			typedef void (__fastcall *FVtFn0)(void*, void*);
			*(DWORD*)((BYTE*)this_00 + 0xa0) |= 2;
			(*(FVtFn1*)((BYTE*)**(INT**)this_00 + 0x188))(this_00, 0, 1);
			(*(FVtFn0*)((BYTE*)**(INT**)this_00 + 0x18c))(this_00, 0);
		}
		*(INT*)((BYTE*)this_00 + 0x398) = param_4;
		// copy Location from param_1, Rotation from param_2
		*(FVector*)((BYTE*)this_00 + 0x234) = *param_1;
		*(FRotator*)((BYTE*)this_00 + 0x240) = *param_2;
		// clear dirty bit, set active bit
		*(DWORD*)((BYTE*)this_00 + 0xa0) &= ~2u;
		*(DWORD*)((BYTE*)this_00 + 0x51c) |= 1;
		// set texture
		*(UTexture**)((BYTE*)this_00 + 0x3a4) = param_3;
		if (param_8 != 0.0f)
			*(FLOAT*)((BYTE*)this_00 + 0xe8) = param_8;

		// Handle by group type (this+0x394 = eDecalType byte)
		BYTE groupType = *(BYTE*)((BYTE*)this + 0x394);
		if (groupType == 3)
		{
			// Blood decal: DIVERGENCE — FName/scale extra init not reconstructed.
		}
		if (groupType == 2)
		{
			// Dirt/impact decal — scale depends on nightmare difficulty.
			FLOAT scale = GIsNightmare ? 2.0f : 0.3f;
			this_00->SetDrawScale(scale);
		}
		if (groupType == 0)
		{
			// Bullet decal — DIVERGENCE: life/randomness flag bytes at unknown offsets not set.
		}
		// groupType == 1: TODO: smoke flag
		*(DWORD*)((BYTE*)this_00 + 0x3a0) ^= (param_9 << 0x11 ^ *(DWORD*)((BYTE*)this_00 + 0x3a0)) & 0x20000;
		typedef void (__fastcall *FVtFn0)(void*, void*);
		(*(FVtFn0*)((BYTE*)**(INT**)this_00 + 0x184))(this_00, 0);
		*(INT*)(*(INT*)((BYTE*)this_00 + 0x48c) + 0x14) = 0;
		if (param_5 != 0.0f)
		{
			// Retail: decalInfo+0x0c = (appSeconds() + param_5) - param_6 (expiry timestamp)
			//         decalInfo+0x14 = param_5 (lifetime in seconds)
			DOUBLE now = appSecondsSlow();
			*(DOUBLE*)(*(INT*)((BYTE*)this_00 + 0x48c) + 0x0c) = (now + param_5) - param_6;
			*(FLOAT*)(*(INT*)((BYTE*)this_00 + 0x48c) + 0x14) = param_5;
		}
		INT iVar3 = *(INT*)((BYTE*)this + 0x39c);
		*(INT*)((BYTE*)this + 0x39c) = iVar3 + 1;
		if (*(INT*)((BYTE*)this + 0x398) <= iVar3 + 1)
			*(INT*)((BYTE*)this + 0x39c) = 0;
		return 1;
	}
	return 0;
	unguard;
}


// --- AR6DecalManager ---
IMPL_EMPTY("Body unknown; decal manager spawn initialization requires Ghidra analysis")
void AR6DecalManager::Spawned()
{
	guard(AR6DecalManager::Spawned);
	unguard;
}

IMPL_DIVERGE("type-1 bullet-decal frequency/distance cull uses DAT_1079dedc/ded8/ded4 (unexported Engine.dll counters) and viewport camera offsets not in our headers; non-type-1 path fully implemented; Ghidra 0x10477880")
int AR6DecalManager::AddDecal(FVector* param_1, FRotator* param_2, UTexture* param_3, eDecalType param_4,
	int param_5, float param_6, float param_7, float param_8, float param_9, int param_10)
{
	guard(AR6DecalManager::AddDecal);
	DWORD uVar4 = 1;

	if (param_4 == 1)
	{
		// Distance/angle culling for type-1 (bullet) decals.
		// DIVERGENCE: requires viewport access (GEngine->Client->Viewports[0]) and
		// global decal counters (DAT_1079dedc/ded8/ded4). Camera-distance cull omitted.
	}

	// this+0x394 = active flag
	if ((*(BYTE*)((BYTE*)this + 0x394) & 1) != 0)
	{
		AR6DecalGroup* this_00 = FindGroup(param_4);
		if (this_00 != NULL)
		{
			this_00->AddDecal(param_1, param_2, param_3, param_5,
				param_6, param_7, param_8, param_9, param_10);
			return uVar4;
		}
	}
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10477820)
AR6DecalGroup * AR6DecalManager::FindGroup(eDecalType type)
{
	// Retail: 0x177820, 66 bytes. Returns the decal group for the given type.
	// 5 types map to fields at this+0x398 through this+0x3A8 (4 bytes apart).
	switch (type)
	{
		case 0: return *(AR6DecalGroup**)((BYTE*)this + 0x398);
		case 1: return *(AR6DecalGroup**)((BYTE*)this + 0x39C);
		case 2: return *(AR6DecalGroup**)((BYTE*)this + 0x3A0);
		case 3: return *(AR6DecalGroup**)((BYTE*)this + 0x3A4);
		case 4: return *(AR6DecalGroup**)((BYTE*)this + 0x3A8);
		default: return NULL;
	}
}


// --- AR6DecalsBase ---
IMPL_MATCH("Engine.dll", 0x104781b0)
int AR6DecalsBase::IsNetRelevantFor(APlayerController* param_1, AActor* param_2, FVector param_3)
{
	guardSlow(AR6DecalsBase::IsNetRelevantFor);
	// param_1 + 0x3d8 = PlayerController's Pawn
	INT* pPawn = (INT*)*(INT*)((BYTE*)param_1 + 0x3d8);
	if (pPawn == NULL)
		return 0;

	// pawn's zone (pawn+0x228 = Region.Zone) team byte at zone+0x397
	BYTE bVar1 = *(BYTE*)(*(INT*)((BYTE*)pPawn + 0x228) + 0x397);
	// this zone team byte
	DWORD uVar3 = (DWORD)*(BYTE*)(*(INT*)((BYTE*)this + 0x228) + 0x397);

	if (uVar3 != (DWORD)bVar1)
	{
		DWORD uVar2 = 1u << (bVar1 & 0x1f);
		// this+0x144 = Level; zone visibility table at Level+0x650/+0x654
		INT* pLevel = *(INT**)((BYTE*)this + 0x144);
		if ((uVar2 & *(DWORD*)((BYTE*)pLevel + 0x650 + uVar3 * 8)) == 0 &&
			((INT)uVar2 >> 0x1f & *(DWORD*)((BYTE*)pLevel + 0x654 + uVar3 * 8)) == 0)
			return 0;
	}
	return 1;
	unguardSlow;
}


// --- AR6EngineWeapon ---
IMPL_MATCH("Engine.dll", 0x10414310)
int AR6EngineWeapon::GetHeartBeatStatus()
{
	// Verified from Ghidra: shared stub at 0x114310 — just returns 0.
	return 0;
}


// --- AR6RainbowStartInfo ---
IMPL_MATCH("Engine.dll", 0x10370940)
void AR6RainbowStartInfo::TransferFile(FArchive& Ar)
{
	guard(AR6RainbowStartInfo::TransferFile);
	Ar.ByteOrderSerialize((BYTE*)this + 0x398, 4);
	Ar << *(FString*)((BYTE*)this + 0x3e0);
	Ar << *(FString*)((BYTE*)this + 0x3f8);
	Ar << *(FString*)((BYTE*)this + 0x404);
	Ar << *(FString*)((BYTE*)this + 0x410);
	Ar << *(FString*)((BYTE*)this + 0x41c);
	Ar << *(FString*)((BYTE*)this + 0x428);
	Ar << *(FString*)((BYTE*)this + 0x434);
	Ar << *(FString*)((BYTE*)this + 0x440);
	Ar << *(FString*)((BYTE*)this + 0x44c);
	if (!Ar.IsSaving() && Ar.Ver() < 5)
	{
		*(FString*)((BYTE*)this + 0x3ec) = TEXT("ASSAULT");
		return;
	}
	Ar << *(FString*)((BYTE*)this + 0x3ec);
	unguard;
}


// --- AR6TeamStartInfo ---
IMPL_EMPTY("Body unknown; team serialization field layout requires Ghidra analysis")
void AR6TeamStartInfo::TransferFile(FArchive &,int)
{
	guard(AR6TeamStartInfo::TransferFile);
	unguard;
}


// --- AR6WallHit ---
IMPL_EMPTY("Body unknown; wall-hit visual effect spawning requires Ghidra analysis")
void AR6WallHit::SpawnEffects()
{
	guard(AR6WallHit::SpawnEffects);
	unguard;
}

IMPL_EMPTY("Body unknown; wall-hit sound spawning requires Ghidra analysis")
void AR6WallHit::SpawnSound()
{
	guard(AR6WallHit::SpawnSound);
	unguard;
}

IMPL_EMPTY("Body unknown; wall-hit post-begin-play initialization requires Ghidra analysis")
void AR6WallHit::PostBeginPlay()
{
	guard(AR6WallHit::PostBeginPlay);
	unguard;
}


// --- AR6eviLTesting ---
IMPL_EMPTY("Debug/testing function; ATS test body requires Ghidra analysis")
void AR6eviLTesting::eviLTestATS()
{
	guard(AR6eviLTesting::eviLTestATS);
	unguard;
}

IMPL_EMPTY("Debug/testing function; update-system test body requires Ghidra analysis")
void AR6eviLTesting::evilTestUpdateSystem()
{
	guard(AR6eviLTesting::evilTestUpdateSystem);
	unguard;
}


// --- UR6AbstractGameManager ---
IMPL_EMPTY("Ghidra 0x1030e7c0: base-class stub; body is empty (FString param cleanup only). Derived class in R6GameService.dll overrides.")
void UR6AbstractGameManager::StartJoinServer(FString,FString,int)
{
	guard(UR6AbstractGameManager::StartJoinServer);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10414310)
int UR6AbstractGameManager::StartLogInProcedure()
{
	// Verified from Ghidra: shared stub at 0x114310 — just returns 0.
	return 0;
}

IMPL_EMPTY("Ghidra 0x104651d0: base-class stub; shared empty-return thunk (3 bytes). Derived class in R6GameService.dll overrides.")
void UR6AbstractGameManager::StartPreJoinProcedure(int)
{
	guard(UR6AbstractGameManager::StartPreJoinProcedure);
	unguard;
}

IMPL_EMPTY("Ghidra 0x10476d60: base-class stub; shared empty-return thunk (1 byte). Derived class in R6GameService.dll overrides.")
void UR6AbstractGameManager::UnInitialize()
{
	guard(UR6AbstractGameManager::UnInitialize);
	unguard;
}

IMPL_EMPTY("Ghidra 0x104651d0: base-class stub; shared empty-return thunk (3 bytes). Derived class in R6GameService.dll overrides.")
void UR6AbstractGameManager::SetGSCreateUbiServer(int)
{
	guard(UR6AbstractGameManager::SetGSCreateUbiServer);
	unguard;
}

IMPL_EMPTY("Ghidra 0x1030e770: base-class stub; body is empty (FString param cleanup only). Derived class in R6GameService.dll overrides.")
void UR6AbstractGameManager::LaunchListenSrv(FString,FString)
{
	guard(UR6AbstractGameManager::LaunchListenSrv);
	unguard;
}

IMPL_EMPTY("Ghidra 0x10476d60: base-class stub; shared empty-return thunk (1 byte). Derived class in R6GameService.dll overrides.")
void UR6AbstractGameManager::ClientLeaveServer()
{
	guard(UR6AbstractGameManager::ClientLeaveServer);
	unguard;
}

IMPL_EMPTY("Ghidra 0x104651d0: base-class stub; shared empty-return thunk (3 bytes). Derived class in R6GameService.dll overrides.")
void UR6AbstractGameManager::ConnectionInterrupted(int)
{
	guard(UR6AbstractGameManager::ConnectionInterrupted);
	unguard;
}

IMPL_EMPTY("Ghidra 0x104651d0: base-class stub; shared empty-return thunk (3 bytes). Derived class in R6GameService.dll overrides.")
void UR6AbstractGameManager::GameServiceTick(UConsole *)
{
	guard(UR6AbstractGameManager::GameServiceTick);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10414310)
int UR6AbstractGameManager::GetGSCreateUbiServer()
{
	// Verified from Ghidra: shared stub at 0x114310 — just returns 0.
	return 0;
}

IMPL_EMPTY("Ghidra 0x104651d0: base-class stub; shared empty-return thunk (3 bytes). Derived class in R6GameService.dll overrides.")
void UR6AbstractGameManager::InitializeGameService(UConsole *)
{
	guard(UR6AbstractGameManager::InitializeGameService);
	unguard;
}


// --- UR6AbstractPlanningInfo ---
IMPL_EMPTY("Body unknown; planning info serialization field layout requires Ghidra analysis")
void UR6AbstractPlanningInfo::TransferFile(FArchive &)
{
	guard(UR6AbstractPlanningInfo::TransferFile);
	unguard;
}

IMPL_EMPTY("Body unknown; path waypoint addition logic requires Ghidra analysis")
void UR6AbstractPlanningInfo::AddPoint(AActor *)
{
	guard(UR6AbstractPlanningInfo::AddPoint);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10414310)
AActor * UR6AbstractPlanningInfo::GetTeamLeader()
{
	// Verified from Ghidra: shared stub at 0x114310 — just returns NULL.
	return NULL;
}


// --- UR6FileManager ---
IMPL_MATCH("Engine.dll", 0x1036cdf0)
int UR6FileManager::FindFile(FString* param_1)
{
	guard(UR6FileManager::FindFile);
	// GFileManager vtable slot 1 (+4 bytes) = CreateFileReader
	const TCHAR* puVar1 = **param_1;
	typedef void* (__fastcall *FCreateReaderFn)(void*, void*, const TCHAR*, INT, INT);
	INT* vtbl = *(INT**)GFileManager;
	FCreateReaderFn createReader = *(FCreateReaderFn*)((BYTE*)vtbl + 4);
	INT* piVar2 = (INT*)createReader(GFileManager, 0, puVar1, 0, 0);
	if (piVar2 != NULL)
	{
		INT* objVtbl = (INT*)*piVar2;
		// vtable[0x4c/4 = 19]: close/release
		typedef void (__fastcall *FCloseFn)(void*, void*);
		FCloseFn closeFn = *(FCloseFn*)((BYTE*)objVtbl + 0x4c);
		closeFn(piVar2, 0);
		// vtable[0]: destructor (arg = 1 to free memory)
		typedef void (__fastcall *FDestructFn)(void*, void*, INT);
		FDestructFn destructFn = *(FDestructFn*)objVtbl;
		destructFn(piVar2, 0, 1);
		return 1;
	}
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1036cff0)
void UR6FileManager::GetFileName(int param_1, FString* param_2)
{
	guard(UR6FileManager::GetFileName);
	// this+0x2c is the Data pointer of a TArray of FStrings (12 bytes each).
	FString* elem = (FString*)(*(INT*)((BYTE*)this + 0x2c) + param_1 * 0xc);
	*param_2 = elem->Caps();
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1036d480)
int UR6FileManager::GetNbFile(FString* param_1, FString* param_2)
{
	guard(UR6FileManager::GetNbFile);
	// FUN_1031f060/103217e0/1031efc0 = FString path/extension helpers.
	// Builds search pattern: dir + (wildcard or "*." + ext), calls GFileManager->FindFiles.

	// Build search pattern: if param_2 contains '*' use it as-is, else prepend "*."
	FString Pattern;
	if (param_2 && appStrchr(**param_2, TEXT('*')))
		Pattern = *param_1 + *param_2;
	else if (param_2 && (*param_2).Len() > 0)
		Pattern = *param_1 + TEXT("*.") + *param_2;
	else
		Pattern = *param_1 + TEXT("*.*");

	// Retrieve this's FString TArray at +0x2c
	TArray<FString>* pArr = (TArray<FString>*)((BYTE*)this + 0x2c);
	pArr->Empty();
	TArray<FString> Found = GFileManager->FindFiles(*Pattern, 1, 0);
	*pArr = Found;
	return pArr->Num();

	unguard;
}


// ============================================================================
// UR6AbstractTerroristMgr constructor
// (moved from EngineStubs.cpp)
// ============================================================================

// ??0UR6AbstractTerroristMgr@@QAE@XZ
IMPL_EMPTY("Default constructor; member initialization layout requires Ghidra analysis")
UR6AbstractTerroristMgr::UR6AbstractTerroristMgr() {}

// --- Moved from EngineStubs.cpp ---
IMPL_EMPTY("Default constructor; member initialization layout requires Ghidra analysis")
AR6AbstractClimbableObj::AR6AbstractClimbableObj() {}
