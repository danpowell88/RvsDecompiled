/*=============================================================================
	UnTerrainTools.cpp: Terrain editor brush hierarchy (UTerrainBrush*)
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

// --- UTerrainBrush ---
IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrush::MouseButtonDown(UViewport *)
{
	guard(UTerrainBrush::MouseButtonDown);
	unguard;
}

IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrush::MouseButtonUp(UViewport *)
{
	guard(UTerrainBrush::MouseButtonUp);
	unguard;
}

IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrush::MouseMove(float,float)
{
	guard(UTerrainBrush::MouseMove);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x104650a0)
UTerrainBrush::UTerrainBrush(UTerrainBrush const &Other)
{
	// Ghidra 0x15690: vtable set by compiler; FString placement new at +4 and +10; 19 DWORDs at +1C..+64
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

IMPL_MATCH("Engine.dll", 0x104650a0)
UTerrainBrush::UTerrainBrush()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
	new ((BYTE*)this + 0x3c) FVector(0,0,0);
	new ((BYTE*)this + 0x48) FVector(0,0,0);
	*(FString*)((BYTE*)this + 0x04) = FString(TEXT("None"));
	*(FString*)((BYTE*)this + 0x10) = FString(TEXT("NONE"));
	*(INT*)((BYTE*)this + 0x28) = 0;
	*(INT*)((BYTE*)this + 0x34) = 0;
	*(INT*)((BYTE*)this + 100) = 0;
	*(INT*)((BYTE*)this + 0x20) = 1;
	*(INT*)((BYTE*)this + 0x24) = 1;
	*(INT*)((BYTE*)this + 0x2c) = 1;
	*(INT*)((BYTE*)this + 0x30) = 1;
	*(INT*)((BYTE*)this + 0x38) = 1;
	*(INT*)((BYTE*)this + 0x1c) = 0xffffffff;
	*(INT*)((BYTE*)this + 0x54) = 0x100;
	*(INT*)((BYTE*)this + 0x58) = 0x400;
	*(INT*)((BYTE*)this + 0x5c) = 100;
	*(INT*)((BYTE*)this + 0x60) = 0x20;
}

IMPL_MATCH("Engine.dll", 0x10465170)
UTerrainBrush::~UTerrainBrush()
{
	// Ghidra 0x165170: ~FString at +10 then +4 (reverse order)
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

IMPL_MATCH("Engine.dll", 0x10315770)
UTerrainBrush& UTerrainBrush::operator=(const UTerrainBrush& Other)
{
	// Ghidra 0x15770: skip vtable +0; FString@+4, FString@+0x10, 19 DWORDs@+0x1C..+0x64
	*(FString*)((BYTE*)this + 0x04) = *(const FString*)((const BYTE*)&Other + 0x04);
	*(FString*)((BYTE*)this + 0x10) = *(const FString*)((const BYTE*)&Other + 0x10);
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C);
	return *this;
}

// Editor globals for the currently-active terrain painting session.
static ATerrainInfo* GCurrentTerrainInfo  = NULL; // DAT_1061b794
static UTexture*     GCurrentAlphaTexture = NULL; // DAT_1061b790
static FVector       GCurrentBrushPos;            // DAT_1061b73c (X,Y,Z)

IMPL_MATCH("Engine.dll", 0x10465a30)
int UTerrainBrush::BeginPainting(UTexture** param_1, ATerrainInfo** param_2)
{
	guardSlow(UTerrainBrush::BeginPainting);

	bool bVar3 = (GCurrentTerrainInfo != NULL);
	*param_2 = GCurrentTerrainInfo;
	UTexture* pUVar1 = GCurrentAlphaTexture;

	if (bVar3)
	{
		*param_1 = GCurrentAlphaTexture;
		if (pUVar1 != NULL)
		{
			// Lock alpha texture for painting if not already locked (bit 0x20 at +0x94)
			if ((*(BYTE*)((BYTE*)pUVar1 + 0x94) & 0x20) == 0)
			{
				// Render device: vtable of render interface at pUVar1+0xbc, slot 0x10/4
				typedef void (__thiscall *TLockTexture)(void*);
			void* renderIface = *(void**)((BYTE*)pUVar1 + 0xbc);
			((TLockTexture)*(DWORD*)(*(DWORD*)renderIface + 0x10))(renderIface);
			}
			return 1;
		}
	}

	return 0;

	unguardSlow;
}

IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrush::EndPainting(UTexture *,ATerrainInfo *)
{
	guard(UTerrainBrush::EndPainting);
	unguard;
}

IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrush::Execute(int)
{
	guard(UTerrainBrush::Execute);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x104651f0)
FBox UTerrainBrush::GetRect()
{
	return FBox();
}


// --- UTerrainBrushColor ---
IMPL_MATCH("Engine.dll", 0x10465330)
UTerrainBrushColor::UTerrainBrushColor(UTerrainBrushColor const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

IMPL_MATCH("Engine.dll", 0x10465330)
UTerrainBrushColor::UTerrainBrushColor()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

IMPL_MATCH("Engine.dll", 0x104653a0)
UTerrainBrushColor::~UTerrainBrushColor()
{
	// Ghidra 0x1653a0: reset vtable (implicit in C++ virtual dtor), then call UTerrainBrush::~UTerrainBrush
	reinterpret_cast<UTerrainBrush*>(this)->UTerrainBrush::~UTerrainBrush();
}

IMPL_MATCH("Engine.dll", 0x10315b20)
UTerrainBrushColor& UTerrainBrushColor::operator=(const UTerrainBrushColor& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator= (shared by all 13 subclasses)
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrushColor::Execute(int)
{
	guardSlow(UTerrainBrushColor::Execute);
	unguardSlow;
}


// --- UTerrainBrushEdgeTurn ---
IMPL_MATCH("Engine.dll", 0x10465900)
UTerrainBrushEdgeTurn::UTerrainBrushEdgeTurn(UTerrainBrushEdgeTurn const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

IMPL_MATCH("Engine.dll", 0x10465900)
UTerrainBrushEdgeTurn::UTerrainBrushEdgeTurn()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

IMPL_MATCH("Engine.dll", 0x10465980)
UTerrainBrushEdgeTurn::~UTerrainBrushEdgeTurn()
{
	// Ghidra 0x165980: reset vtable (implicit), then call UTerrainBrush::~UTerrainBrush
	reinterpret_cast<UTerrainBrush*>(this)->UTerrainBrush::~UTerrainBrush();
}

IMPL_MATCH("Engine.dll", 0x10315b20)
UTerrainBrushEdgeTurn& UTerrainBrushEdgeTurn::operator=(const UTerrainBrushEdgeTurn& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrushEdgeTurn::Execute(int)
{
	guardSlow(UTerrainBrushEdgeTurn::Execute);
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x10466130)
FBox UTerrainBrushEdgeTurn::GetRect()
{
	FBox box(1);
	box += GCurrentBrushPos;
	if (GCurrentTerrainInfo != NULL)
	{
		FVector corner2(
			GCurrentBrushPos.X + *(FLOAT*)((BYTE*)GCurrentTerrainInfo + 0x39c),
			GCurrentBrushPos.Y + *(FLOAT*)((BYTE*)GCurrentTerrainInfo + 0x3a0),
			GCurrentBrushPos.Z);
		box += corner2;
	}
	return box;
}


// --- UTerrainBrushFlatten ---
IMPL_MATCH("Engine.dll", 0x104654b0)
UTerrainBrushFlatten::UTerrainBrushFlatten(UTerrainBrushFlatten const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

IMPL_MATCH("Engine.dll", 0x104654b0)
UTerrainBrushFlatten::UTerrainBrushFlatten()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

IMPL_MATCH("Engine.dll", 0x10465520)
UTerrainBrushFlatten::~UTerrainBrushFlatten()
{
	// Ghidra 0x165520: reset vtable (implicit), then call UTerrainBrush::~UTerrainBrush
	reinterpret_cast<UTerrainBrush*>(this)->UTerrainBrush::~UTerrainBrush();
}

IMPL_MATCH("Engine.dll", 0x10315b20)
UTerrainBrushFlatten& UTerrainBrushFlatten::operator=(const UTerrainBrushFlatten& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrushFlatten::Execute(int)
{
	guardSlow(UTerrainBrushFlatten::Execute);
	unguardSlow;
}


// --- UTerrainBrushNoise ---
IMPL_MATCH("Engine.dll", 0x10465430)
UTerrainBrushNoise::UTerrainBrushNoise(UTerrainBrushNoise const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

IMPL_MATCH("Engine.dll", 0x10465430)
UTerrainBrushNoise::UTerrainBrushNoise()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

IMPL_MATCH("Engine.dll", 0x104654a0)
UTerrainBrushNoise::~UTerrainBrushNoise()
{
	// Ghidra 0x1654a0: reset vtable (implicit), then call UTerrainBrush::~UTerrainBrush
	reinterpret_cast<UTerrainBrush*>(this)->UTerrainBrush::~UTerrainBrush();
}

IMPL_MATCH("Engine.dll", 0x10315b20)
UTerrainBrushNoise& UTerrainBrushNoise::operator=(const UTerrainBrushNoise& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrushNoise::Execute(int)
{
	guardSlow(UTerrainBrushNoise::Execute);
	unguardSlow;
}


// --- UTerrainBrushPaint ---
IMPL_MATCH("Engine.dll", 0x104652b0)
UTerrainBrushPaint::UTerrainBrushPaint(UTerrainBrushPaint const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

IMPL_MATCH("Engine.dll", 0x104652b0)
UTerrainBrushPaint::UTerrainBrushPaint()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

IMPL_MATCH("Engine.dll", 0x10465320)
UTerrainBrushPaint::~UTerrainBrushPaint()
{
	// Ghidra 0x165320: reset vtable (implicit), then call UTerrainBrush::~UTerrainBrush
	reinterpret_cast<UTerrainBrush*>(this)->UTerrainBrush::~UTerrainBrush();
}

IMPL_MATCH("Engine.dll", 0x10315b20)
UTerrainBrushPaint& UTerrainBrushPaint::operator=(const UTerrainBrushPaint& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrushPaint::Execute(int)
{
	guardSlow(UTerrainBrushPaint::Execute);
	unguardSlow;
}


// --- UTerrainBrushPlanningPaint ---
IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrushPlanningPaint::MouseButtonDown(UViewport *)
{
	guardSlow(UTerrainBrushPlanningPaint::MouseButtonDown);
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x10465990)
UTerrainBrushPlanningPaint::UTerrainBrushPlanningPaint(UTerrainBrushPlanningPaint const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

IMPL_MATCH("Engine.dll", 0x10465990)
UTerrainBrushPlanningPaint::UTerrainBrushPlanningPaint()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

IMPL_MATCH("Engine.dll", 0x10465a00)
UTerrainBrushPlanningPaint::~UTerrainBrushPlanningPaint()
{
	// Ghidra 0x165a00: reset vtable (implicit), then call UTerrainBrush::~UTerrainBrush
	reinterpret_cast<UTerrainBrush*>(this)->UTerrainBrush::~UTerrainBrush();
}

IMPL_MATCH("Engine.dll", 0x10315b20)
UTerrainBrushPlanningPaint& UTerrainBrushPlanningPaint::operator=(const UTerrainBrushPlanningPaint& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrushPlanningPaint::Execute(int)
{
	guardSlow(UTerrainBrushPlanningPaint::Execute);
	unguardSlow;
}


// --- UTerrainBrushSelect ---
IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrushSelect::MouseButtonDown(UViewport *)
{
	guardSlow(UTerrainBrushSelect::MouseButtonDown);
	unguardSlow;
}

IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrushSelect::MouseMove(float,float)
{
	guard(UTerrainBrushSelect::MouseMove);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x104656e0)
UTerrainBrushSelect::UTerrainBrushSelect(UTerrainBrushSelect const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

IMPL_MATCH("Engine.dll", 0x104656e0)
UTerrainBrushSelect::UTerrainBrushSelect()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

IMPL_MATCH("Engine.dll", 0x10465790)
UTerrainBrushSelect::~UTerrainBrushSelect()
{
	// Ghidra 0x165790: reset vtable (implicit), then call UTerrainBrush::~UTerrainBrush
	reinterpret_cast<UTerrainBrush*>(this)->UTerrainBrush::~UTerrainBrush();
}

IMPL_MATCH("Engine.dll", 0x10315b20)
UTerrainBrushSelect& UTerrainBrushSelect::operator=(const UTerrainBrushSelect& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrushSelect::Execute(int)
{
	guardSlow(UTerrainBrushSelect::Execute);
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x104657c0)
FBox UTerrainBrushSelect::GetRect()
{
	FBox box(1);
	box += *(FVector*)((BYTE*)this + 0x3c);
	box += *(FVector*)((BYTE*)this + 0x48);
	return box;
}


// --- UTerrainBrushSmooth ---
IMPL_MATCH("Engine.dll", 0x104653b0)
UTerrainBrushSmooth::UTerrainBrushSmooth(UTerrainBrushSmooth const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

IMPL_MATCH("Engine.dll", 0x104653b0)
UTerrainBrushSmooth::UTerrainBrushSmooth()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

IMPL_MATCH("Engine.dll", 0x10465420)
UTerrainBrushSmooth::~UTerrainBrushSmooth()
{
	// Ghidra 0x165420: reset vtable (implicit), then call UTerrainBrush::~UTerrainBrush
	reinterpret_cast<UTerrainBrush*>(this)->UTerrainBrush::~UTerrainBrush();
}

IMPL_MATCH("Engine.dll", 0x10315b20)
UTerrainBrushSmooth& UTerrainBrushSmooth::operator=(const UTerrainBrushSmooth& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrushSmooth::Execute(int)
{
	guardSlow(UTerrainBrushSmooth::Execute);
	unguardSlow;
}


// --- UTerrainBrushTexPan ---
IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrushTexPan::MouseMove(float,float)
{
	guardSlow(UTerrainBrushTexPan::MouseMove);
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x10465530)
UTerrainBrushTexPan::UTerrainBrushTexPan(UTerrainBrushTexPan const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

IMPL_MATCH("Engine.dll", 0x10465530)
UTerrainBrushTexPan::UTerrainBrushTexPan()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

IMPL_MATCH("Engine.dll", 0x104655b0)
UTerrainBrushTexPan::~UTerrainBrushTexPan()
{
	// Ghidra 0x1655b0: reset vtable (implicit), then call UTerrainBrush::~UTerrainBrush
	reinterpret_cast<UTerrainBrush*>(this)->UTerrainBrush::~UTerrainBrush();
}

IMPL_MATCH("Engine.dll", 0x10315b20)
UTerrainBrushTexPan& UTerrainBrushTexPan::operator=(const UTerrainBrushTexPan& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}


// --- UTerrainBrushTexRotate ---
IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrushTexRotate::MouseMove(float,float)
{
	guardSlow(UTerrainBrushTexRotate::MouseMove);
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x104655c0)
UTerrainBrushTexRotate::UTerrainBrushTexRotate(UTerrainBrushTexRotate const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

IMPL_MATCH("Engine.dll", 0x104655c0)
UTerrainBrushTexRotate::UTerrainBrushTexRotate()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

IMPL_MATCH("Engine.dll", 0x10465640)
UTerrainBrushTexRotate::~UTerrainBrushTexRotate()
{
	// Ghidra 0x165640: reset vtable (implicit), then call UTerrainBrush::~UTerrainBrush
	reinterpret_cast<UTerrainBrush*>(this)->UTerrainBrush::~UTerrainBrush();
}

IMPL_MATCH("Engine.dll", 0x10315b20)
UTerrainBrushTexRotate& UTerrainBrushTexRotate::operator=(const UTerrainBrushTexRotate& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}


// --- UTerrainBrushTexScale ---
IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrushTexScale::MouseMove(float,float)
{
	guardSlow(UTerrainBrushTexScale::MouseMove);
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x10465650)
UTerrainBrushTexScale::UTerrainBrushTexScale(UTerrainBrushTexScale const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

IMPL_MATCH("Engine.dll", 0x10465650)
UTerrainBrushTexScale::UTerrainBrushTexScale()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

IMPL_MATCH("Engine.dll", 0x104656d0)
UTerrainBrushTexScale::~UTerrainBrushTexScale()
{
	// Ghidra 0x1656d0: reset vtable (implicit), then call UTerrainBrush::~UTerrainBrush
	reinterpret_cast<UTerrainBrush*>(this)->UTerrainBrush::~UTerrainBrush();
}

IMPL_MATCH("Engine.dll", 0x10315b20)
UTerrainBrushTexScale& UTerrainBrushTexScale::operator=(const UTerrainBrushTexScale& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}


// --- UTerrainBrushVertexEdit ---
IMPL_MATCH("Engine.dll", 0x10465220)
UTerrainBrushVertexEdit::UTerrainBrushVertexEdit(UTerrainBrushVertexEdit const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

IMPL_MATCH("Engine.dll", 0x10465220)
UTerrainBrushVertexEdit::UTerrainBrushVertexEdit()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

IMPL_MATCH("Engine.dll", 0x104652a0)
UTerrainBrushVertexEdit::~UTerrainBrushVertexEdit()
{
	// Ghidra 0x1652a0: reset vtable (implicit), then call UTerrainBrush::~UTerrainBrush
	reinterpret_cast<UTerrainBrush*>(this)->UTerrainBrush::~UTerrainBrush();
}

IMPL_MATCH("Engine.dll", 0x10315b20)
UTerrainBrushVertexEdit& UTerrainBrushVertexEdit::operator=(const UTerrainBrushVertexEdit& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}


// --- UTerrainBrushVisibility ---
IMPL_MATCH("Engine.dll", 0x10465870)
UTerrainBrushVisibility::UTerrainBrushVisibility(UTerrainBrushVisibility const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

IMPL_MATCH("Engine.dll", 0x10465870)
UTerrainBrushVisibility::UTerrainBrushVisibility()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

IMPL_MATCH("Engine.dll", 0x104658f0)
UTerrainBrushVisibility::~UTerrainBrushVisibility()
{
	// Ghidra 0x1658f0: reset vtable (implicit), then call UTerrainBrush::~UTerrainBrush
	reinterpret_cast<UTerrainBrush*>(this)->UTerrainBrush::~UTerrainBrush();
}

IMPL_MATCH("Engine.dll", 0x10315b20)
UTerrainBrushVisibility& UTerrainBrushVisibility::operator=(const UTerrainBrushVisibility& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrushVisibility::Execute(int)
{
	guardSlow(UTerrainBrushVisibility::Execute);
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x10466050)
FBox UTerrainBrushVisibility::GetRect()
{
	FBox box(1);
	box += GCurrentBrushPos;
	if (GCurrentTerrainInfo != NULL)
	{
		FVector corner2(
			GCurrentBrushPos.X + *(FLOAT*)((BYTE*)GCurrentTerrainInfo + 0x39c),
			GCurrentBrushPos.Y + *(FLOAT*)((BYTE*)GCurrentTerrainInfo + 0x3a0),
			GCurrentBrushPos.Z);
		box += corner2;
	}
	return box;
}

