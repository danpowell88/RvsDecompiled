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

IMPL_MATCH("Engine.dll", 0x15690)
UTerrainBrush::UTerrainBrush(UTerrainBrush const &Other)
{
	// Ghidra 0x15690: vtable set by compiler; FString placement new at +4 and +10; 19 DWORDs at +1C..+64
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

IMPL_DIVERGE("stub body (2 line(s)) — Ghidra 0x10315690 is 217 bytes, not fully reconstructed")
UTerrainBrush::UTerrainBrush()
{
	// Initialize 2 FStrings to empty
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

IMPL_MATCH("Engine.dll", 0x165170)
UTerrainBrush::~UTerrainBrush()
{
	// Ghidra 0x165170: ~FString at +10 then +4 (reverse order)
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

IMPL_MATCH("Engine.dll", 0x15770)
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

IMPL_MATCH("Engine.dll", 0x10465a30)
int UTerrainBrush::BeginPainting(UTexture** param_1, ATerrainInfo** param_2)
{
	guard(UTerrainBrush::BeginPainting);

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

	unguard;
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
IMPL_MATCH("Engine.dll", 0x10315980)
UTerrainBrushColor::UTerrainBrushColor(UTerrainBrushColor const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

IMPL_MATCH("Engine.dll", 0x10315980)
UTerrainBrushColor::UTerrainBrushColor()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

IMPL_DIVERGE("UTerrainBrushColor::~UTerrainBrushColor not found in Ghidra export — cannot confirm VA")
UTerrainBrushColor::~UTerrainBrushColor()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

IMPL_MATCH("Engine.dll", 0x15b20)
UTerrainBrushColor& UTerrainBrushColor::operator=(const UTerrainBrushColor& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator= (shared by all 13 subclasses)
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrushColor::Execute(int)
{
	guard(UTerrainBrushColor::Execute);
	unguard;
}


// --- UTerrainBrushEdgeTurn ---
IMPL_MATCH("Engine.dll", 0x10315e20)
UTerrainBrushEdgeTurn::UTerrainBrushEdgeTurn(UTerrainBrushEdgeTurn const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

IMPL_MATCH("Engine.dll", 0x10315e20)
UTerrainBrushEdgeTurn::UTerrainBrushEdgeTurn()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

IMPL_DIVERGE("UTerrainBrushEdgeTurn::~UTerrainBrushEdgeTurn not found in Ghidra export — cannot confirm VA")
UTerrainBrushEdgeTurn::~UTerrainBrushEdgeTurn()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

IMPL_MATCH("Engine.dll", 0x15b20)
UTerrainBrushEdgeTurn& UTerrainBrushEdgeTurn::operator=(const UTerrainBrushEdgeTurn& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrushEdgeTurn::Execute(int)
{
	guard(UTerrainBrushEdgeTurn::Execute);
	unguard;
}

IMPL_DIVERGE("stub body (1 line(s)) — Ghidra 0x10466130 is 172 bytes, not fully reconstructed")
FBox UTerrainBrushEdgeTurn::GetRect()
{
	return FBox();
}


// --- UTerrainBrushFlatten ---
IMPL_MATCH("Engine.dll", 0x10315b00)
UTerrainBrushFlatten::UTerrainBrushFlatten(UTerrainBrushFlatten const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

IMPL_MATCH("Engine.dll", 0x10315b00)
UTerrainBrushFlatten::UTerrainBrushFlatten()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

IMPL_DIVERGE("UTerrainBrushFlatten::~UTerrainBrushFlatten not found in Ghidra export — cannot confirm VA")
UTerrainBrushFlatten::~UTerrainBrushFlatten()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

IMPL_MATCH("Engine.dll", 0x15b20)
UTerrainBrushFlatten& UTerrainBrushFlatten::operator=(const UTerrainBrushFlatten& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrushFlatten::Execute(int)
{
	guard(UTerrainBrushFlatten::Execute);
	unguard;
}


// --- UTerrainBrushNoise ---
IMPL_MATCH("Engine.dll", 0x10315a80)
UTerrainBrushNoise::UTerrainBrushNoise(UTerrainBrushNoise const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

IMPL_MATCH("Engine.dll", 0x10315a80)
UTerrainBrushNoise::UTerrainBrushNoise()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

IMPL_DIVERGE("UTerrainBrushNoise::~UTerrainBrushNoise not found in Ghidra export — cannot confirm VA")
UTerrainBrushNoise::~UTerrainBrushNoise()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

IMPL_MATCH("Engine.dll", 0x15b20)
UTerrainBrushNoise& UTerrainBrushNoise::operator=(const UTerrainBrushNoise& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrushNoise::Execute(int)
{
	guard(UTerrainBrushNoise::Execute);
	unguard;
}


// --- UTerrainBrushPaint ---
IMPL_MATCH("Engine.dll", 0x10315900)
UTerrainBrushPaint::UTerrainBrushPaint(UTerrainBrushPaint const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

IMPL_MATCH("Engine.dll", 0x10315900)
UTerrainBrushPaint::UTerrainBrushPaint()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

IMPL_DIVERGE("UTerrainBrushPaint::~UTerrainBrushPaint not found in Ghidra export — cannot confirm VA")
UTerrainBrushPaint::~UTerrainBrushPaint()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

IMPL_MATCH("Engine.dll", 0x15b20)
UTerrainBrushPaint& UTerrainBrushPaint::operator=(const UTerrainBrushPaint& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrushPaint::Execute(int)
{
	guard(UTerrainBrushPaint::Execute);
	unguard;
}


// --- UTerrainBrushPlanningPaint ---
IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrushPlanningPaint::MouseButtonDown(UViewport *)
{
	guard(UTerrainBrushPlanningPaint::MouseButtonDown);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10315ea0)
UTerrainBrushPlanningPaint::UTerrainBrushPlanningPaint(UTerrainBrushPlanningPaint const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

IMPL_MATCH("Engine.dll", 0x10315ea0)
UTerrainBrushPlanningPaint::UTerrainBrushPlanningPaint()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

IMPL_DIVERGE("UTerrainBrushPlanningPaint::~UTerrainBrushPlanningPaint not found in Ghidra export — cannot confirm VA")
UTerrainBrushPlanningPaint::~UTerrainBrushPlanningPaint()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

IMPL_MATCH("Engine.dll", 0x15b20)
UTerrainBrushPlanningPaint& UTerrainBrushPlanningPaint::operator=(const UTerrainBrushPlanningPaint& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrushPlanningPaint::Execute(int)
{
	guard(UTerrainBrushPlanningPaint::Execute);
	unguard;
}


// --- UTerrainBrushSelect ---
IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrushSelect::MouseButtonDown(UViewport *)
{
	guard(UTerrainBrushSelect::MouseButtonDown);
	unguard;
}

IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrushSelect::MouseMove(float,float)
{
	guard(UTerrainBrushSelect::MouseMove);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10315d20)
UTerrainBrushSelect::UTerrainBrushSelect(UTerrainBrushSelect const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

IMPL_MATCH("Engine.dll", 0x10315d20)
UTerrainBrushSelect::UTerrainBrushSelect()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

IMPL_DIVERGE("UTerrainBrushSelect::~UTerrainBrushSelect not found in Ghidra export — cannot confirm VA")
UTerrainBrushSelect::~UTerrainBrushSelect()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

IMPL_MATCH("Engine.dll", 0x15b20)
UTerrainBrushSelect& UTerrainBrushSelect::operator=(const UTerrainBrushSelect& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrushSelect::Execute(int)
{
	guard(UTerrainBrushSelect::Execute);
	unguard;
}

IMPL_DIVERGE("stub body (1 line(s)) — Ghidra 0x104657c0 is 113 bytes, not fully reconstructed")
FBox UTerrainBrushSelect::GetRect()
{
	return FBox();
}


// --- UTerrainBrushSmooth ---
IMPL_MATCH("Engine.dll", 0x10315a00)
UTerrainBrushSmooth::UTerrainBrushSmooth(UTerrainBrushSmooth const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

IMPL_MATCH("Engine.dll", 0x10315a00)
UTerrainBrushSmooth::UTerrainBrushSmooth()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

IMPL_DIVERGE("UTerrainBrushSmooth::~UTerrainBrushSmooth not found in Ghidra export — cannot confirm VA")
UTerrainBrushSmooth::~UTerrainBrushSmooth()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

IMPL_MATCH("Engine.dll", 0x15b20)
UTerrainBrushSmooth& UTerrainBrushSmooth::operator=(const UTerrainBrushSmooth& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrushSmooth::Execute(int)
{
	guard(UTerrainBrushSmooth::Execute);
	unguard;
}


// --- UTerrainBrushTexPan ---
IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrushTexPan::MouseMove(float,float)
{
	guard(UTerrainBrushTexPan::MouseMove);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10315ba0)
UTerrainBrushTexPan::UTerrainBrushTexPan(UTerrainBrushTexPan const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

IMPL_MATCH("Engine.dll", 0x10315ba0)
UTerrainBrushTexPan::UTerrainBrushTexPan()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

IMPL_DIVERGE("UTerrainBrushTexPan::~UTerrainBrushTexPan not found in Ghidra export — cannot confirm VA")
UTerrainBrushTexPan::~UTerrainBrushTexPan()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

IMPL_MATCH("Engine.dll", 0x15b20)
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
	guard(UTerrainBrushTexRotate::MouseMove);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10315c20)
UTerrainBrushTexRotate::UTerrainBrushTexRotate(UTerrainBrushTexRotate const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

IMPL_MATCH("Engine.dll", 0x10315c20)
UTerrainBrushTexRotate::UTerrainBrushTexRotate()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

IMPL_DIVERGE("UTerrainBrushTexRotate::~UTerrainBrushTexRotate not found in Ghidra export — cannot confirm VA")
UTerrainBrushTexRotate::~UTerrainBrushTexRotate()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

IMPL_MATCH("Engine.dll", 0x15b20)
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
	guard(UTerrainBrushTexScale::MouseMove);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10315ca0)
UTerrainBrushTexScale::UTerrainBrushTexScale(UTerrainBrushTexScale const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

IMPL_MATCH("Engine.dll", 0x10315ca0)
UTerrainBrushTexScale::UTerrainBrushTexScale()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

IMPL_DIVERGE("UTerrainBrushTexScale::~UTerrainBrushTexScale not found in Ghidra export — cannot confirm VA")
UTerrainBrushTexScale::~UTerrainBrushTexScale()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

IMPL_MATCH("Engine.dll", 0x15b20)
UTerrainBrushTexScale& UTerrainBrushTexScale::operator=(const UTerrainBrushTexScale& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}


// --- UTerrainBrushVertexEdit ---
IMPL_MATCH("Engine.dll", 0x10315880)
UTerrainBrushVertexEdit::UTerrainBrushVertexEdit(UTerrainBrushVertexEdit const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

IMPL_MATCH("Engine.dll", 0x10315880)
UTerrainBrushVertexEdit::UTerrainBrushVertexEdit()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

IMPL_DIVERGE("UTerrainBrushVertexEdit::~UTerrainBrushVertexEdit not found in Ghidra export — cannot confirm VA")
UTerrainBrushVertexEdit::~UTerrainBrushVertexEdit()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

IMPL_MATCH("Engine.dll", 0x15b20)
UTerrainBrushVertexEdit& UTerrainBrushVertexEdit::operator=(const UTerrainBrushVertexEdit& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}


// --- UTerrainBrushVisibility ---
IMPL_MATCH("Engine.dll", 0x10315da0)
UTerrainBrushVisibility::UTerrainBrushVisibility(UTerrainBrushVisibility const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

IMPL_MATCH("Engine.dll", 0x10315da0)
UTerrainBrushVisibility::UTerrainBrushVisibility()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

IMPL_DIVERGE("UTerrainBrushVisibility::~UTerrainBrushVisibility not found in Ghidra export — cannot confirm VA")
UTerrainBrushVisibility::~UTerrainBrushVisibility()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

IMPL_MATCH("Engine.dll", 0x15b20)
UTerrainBrushVisibility& UTerrainBrushVisibility::operator=(const UTerrainBrushVisibility& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

IMPL_EMPTY("Editor terrain tool — not needed for runtime gameplay")
void UTerrainBrushVisibility::Execute(int)
{
	guard(UTerrainBrushVisibility::Execute);
	unguard;
}

IMPL_DIVERGE("stub body (1 line(s)) — Ghidra 0x10466050 is 172 bytes, not fully reconstructed")
FBox UTerrainBrushVisibility::GetRect()
{
	return FBox();
}

