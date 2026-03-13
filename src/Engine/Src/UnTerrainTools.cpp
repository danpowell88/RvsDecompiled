/*=============================================================================
	UnTerrainTools.cpp: Terrain editor brush hierarchy (UTerrainBrush*)
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

// --- UTerrainBrush ---
void UTerrainBrush::MouseButtonDown(UViewport *)
{
	guard(UTerrainBrush::MouseButtonDown);
	unguard;
}

void UTerrainBrush::MouseButtonUp(UViewport *)
{
	guard(UTerrainBrush::MouseButtonUp);
	unguard;
}

void UTerrainBrush::MouseMove(float,float)
{
	guard(UTerrainBrush::MouseMove);
	unguard;
}

UTerrainBrush::UTerrainBrush(UTerrainBrush const &Other)
{
	// Ghidra 0x15690: vtable set by compiler; FString placement new at +4 and +10; 19 DWORDs at +1C..+64
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

UTerrainBrush::UTerrainBrush()
{
	// Initialize 2 FStrings to empty
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

UTerrainBrush::~UTerrainBrush()
{
	// Ghidra 0x165170: ~FString at +10 then +4 (reverse order)
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

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

void UTerrainBrush::EndPainting(UTexture *,ATerrainInfo *)
{
	guard(UTerrainBrush::EndPainting);
	unguard;
}

void UTerrainBrush::Execute(int)
{
	guard(UTerrainBrush::Execute);
	unguard;
}

FBox UTerrainBrush::GetRect()
{
	return FBox();
}


// --- UTerrainBrushColor ---
UTerrainBrushColor::UTerrainBrushColor(UTerrainBrushColor const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

UTerrainBrushColor::UTerrainBrushColor()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

UTerrainBrushColor::~UTerrainBrushColor()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

UTerrainBrushColor& UTerrainBrushColor::operator=(const UTerrainBrushColor& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator= (shared by all 13 subclasses)
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

void UTerrainBrushColor::Execute(int)
{
	guard(UTerrainBrushColor::Execute);
	unguard;
}


// --- UTerrainBrushEdgeTurn ---
UTerrainBrushEdgeTurn::UTerrainBrushEdgeTurn(UTerrainBrushEdgeTurn const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

UTerrainBrushEdgeTurn::UTerrainBrushEdgeTurn()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

UTerrainBrushEdgeTurn::~UTerrainBrushEdgeTurn()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

UTerrainBrushEdgeTurn& UTerrainBrushEdgeTurn::operator=(const UTerrainBrushEdgeTurn& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

void UTerrainBrushEdgeTurn::Execute(int)
{
	guard(UTerrainBrushEdgeTurn::Execute);
	unguard;
}

FBox UTerrainBrushEdgeTurn::GetRect()
{
	return FBox();
}


// --- UTerrainBrushFlatten ---
UTerrainBrushFlatten::UTerrainBrushFlatten(UTerrainBrushFlatten const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

UTerrainBrushFlatten::UTerrainBrushFlatten()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

UTerrainBrushFlatten::~UTerrainBrushFlatten()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

UTerrainBrushFlatten& UTerrainBrushFlatten::operator=(const UTerrainBrushFlatten& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

void UTerrainBrushFlatten::Execute(int)
{
	guard(UTerrainBrushFlatten::Execute);
	unguard;
}


// --- UTerrainBrushNoise ---
UTerrainBrushNoise::UTerrainBrushNoise(UTerrainBrushNoise const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

UTerrainBrushNoise::UTerrainBrushNoise()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

UTerrainBrushNoise::~UTerrainBrushNoise()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

UTerrainBrushNoise& UTerrainBrushNoise::operator=(const UTerrainBrushNoise& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

void UTerrainBrushNoise::Execute(int)
{
	guard(UTerrainBrushNoise::Execute);
	unguard;
}


// --- UTerrainBrushPaint ---
UTerrainBrushPaint::UTerrainBrushPaint(UTerrainBrushPaint const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

UTerrainBrushPaint::UTerrainBrushPaint()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

UTerrainBrushPaint::~UTerrainBrushPaint()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

UTerrainBrushPaint& UTerrainBrushPaint::operator=(const UTerrainBrushPaint& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

void UTerrainBrushPaint::Execute(int)
{
	guard(UTerrainBrushPaint::Execute);
	unguard;
}


// --- UTerrainBrushPlanningPaint ---
void UTerrainBrushPlanningPaint::MouseButtonDown(UViewport *)
{
	guard(UTerrainBrushPlanningPaint::MouseButtonDown);
	unguard;
}

UTerrainBrushPlanningPaint::UTerrainBrushPlanningPaint(UTerrainBrushPlanningPaint const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

UTerrainBrushPlanningPaint::UTerrainBrushPlanningPaint()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

UTerrainBrushPlanningPaint::~UTerrainBrushPlanningPaint()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

UTerrainBrushPlanningPaint& UTerrainBrushPlanningPaint::operator=(const UTerrainBrushPlanningPaint& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

void UTerrainBrushPlanningPaint::Execute(int)
{
	guard(UTerrainBrushPlanningPaint::Execute);
	unguard;
}


// --- UTerrainBrushSelect ---
void UTerrainBrushSelect::MouseButtonDown(UViewport *)
{
	guard(UTerrainBrushSelect::MouseButtonDown);
	unguard;
}

void UTerrainBrushSelect::MouseMove(float,float)
{
	guard(UTerrainBrushSelect::MouseMove);
	unguard;
}

UTerrainBrushSelect::UTerrainBrushSelect(UTerrainBrushSelect const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

UTerrainBrushSelect::UTerrainBrushSelect()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

UTerrainBrushSelect::~UTerrainBrushSelect()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

UTerrainBrushSelect& UTerrainBrushSelect::operator=(const UTerrainBrushSelect& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

void UTerrainBrushSelect::Execute(int)
{
	guard(UTerrainBrushSelect::Execute);
	unguard;
}

FBox UTerrainBrushSelect::GetRect()
{
	return FBox();
}


// --- UTerrainBrushSmooth ---
UTerrainBrushSmooth::UTerrainBrushSmooth(UTerrainBrushSmooth const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

UTerrainBrushSmooth::UTerrainBrushSmooth()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

UTerrainBrushSmooth::~UTerrainBrushSmooth()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

UTerrainBrushSmooth& UTerrainBrushSmooth::operator=(const UTerrainBrushSmooth& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

void UTerrainBrushSmooth::Execute(int)
{
	guard(UTerrainBrushSmooth::Execute);
	unguard;
}


// --- UTerrainBrushTexPan ---
void UTerrainBrushTexPan::MouseMove(float,float)
{
	guard(UTerrainBrushTexPan::MouseMove);
	unguard;
}

UTerrainBrushTexPan::UTerrainBrushTexPan(UTerrainBrushTexPan const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

UTerrainBrushTexPan::UTerrainBrushTexPan()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

UTerrainBrushTexPan::~UTerrainBrushTexPan()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

UTerrainBrushTexPan& UTerrainBrushTexPan::operator=(const UTerrainBrushTexPan& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}


// --- UTerrainBrushTexRotate ---
void UTerrainBrushTexRotate::MouseMove(float,float)
{
	guard(UTerrainBrushTexRotate::MouseMove);
	unguard;
}

UTerrainBrushTexRotate::UTerrainBrushTexRotate(UTerrainBrushTexRotate const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

UTerrainBrushTexRotate::UTerrainBrushTexRotate()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

UTerrainBrushTexRotate::~UTerrainBrushTexRotate()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

UTerrainBrushTexRotate& UTerrainBrushTexRotate::operator=(const UTerrainBrushTexRotate& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}


// --- UTerrainBrushTexScale ---
void UTerrainBrushTexScale::MouseMove(float,float)
{
	guard(UTerrainBrushTexScale::MouseMove);
	unguard;
}

UTerrainBrushTexScale::UTerrainBrushTexScale(UTerrainBrushTexScale const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

UTerrainBrushTexScale::UTerrainBrushTexScale()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

UTerrainBrushTexScale::~UTerrainBrushTexScale()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

UTerrainBrushTexScale& UTerrainBrushTexScale::operator=(const UTerrainBrushTexScale& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}


// --- UTerrainBrushVertexEdit ---
UTerrainBrushVertexEdit::UTerrainBrushVertexEdit(UTerrainBrushVertexEdit const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

UTerrainBrushVertexEdit::UTerrainBrushVertexEdit()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

UTerrainBrushVertexEdit::~UTerrainBrushVertexEdit()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

UTerrainBrushVertexEdit& UTerrainBrushVertexEdit::operator=(const UTerrainBrushVertexEdit& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}


// --- UTerrainBrushVisibility ---
UTerrainBrushVisibility::UTerrainBrushVisibility(UTerrainBrushVisibility const &Other)
{
	// Same layout as UTerrainBrush; vtable set by compiler
	new ((BYTE*)this + 0x04) FString(*(const FString*)((const BYTE*)&Other + 0x04));
	new ((BYTE*)this + 0x10) FString(*(const FString*)((const BYTE*)&Other + 0x10));
	appMemcpy((BYTE*)this + 0x1C, (const BYTE*)&Other + 0x1C, 0x4C); // 19 DWORDs
}

UTerrainBrushVisibility::UTerrainBrushVisibility()
{
	new ((BYTE*)this + 0x04) FString();
	new ((BYTE*)this + 0x10) FString();
}

UTerrainBrushVisibility::~UTerrainBrushVisibility()
{
	((FString*)((BYTE*)this + 0x10))->~FString();
	((FString*)((BYTE*)this + 0x04))->~FString();
}

UTerrainBrushVisibility& UTerrainBrushVisibility::operator=(const UTerrainBrushVisibility& Other)
{
	// Ghidra 0x15b20: delegates to UTerrainBrush::operator=
	*reinterpret_cast<UTerrainBrush*>(this) = *reinterpret_cast<const UTerrainBrush*>(&Other);
	return *this;
}

void UTerrainBrushVisibility::Execute(int)
{
	guard(UTerrainBrushVisibility::Execute);
	unguard;
}

FBox UTerrainBrushVisibility::GetRect()
{
	return FBox();
}

