/*=============================================================================
	UnStatGraph.cpp: Statistics graph rendering (FStatGraphLine)
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

// Forward declaration for FGetHSV defined in UnCamera.cpp
ENGINE_API FPlane FGetHSV(BYTE H, BYTE S, BYTE V);

// --- FStatGraphLine ---
IMPL_MATCH("Engine.dll", 0x1032c410)
FStatGraphLine::FStatGraphLine(FStatGraphLine const &Other)
{
	// Ghidra 0x2c410: no vtable; DWORD at +0; TArray<FLOAT> at +4; 2 DWORDs at +10; FString at +18; 4 DWORDs at +24..+30
	*(DWORD*)this = *(const DWORD*)&Other;
	new ((BYTE*)this + 0x04) TArray<FLOAT>(*(const TArray<FLOAT>*)((const BYTE*)&Other + 0x04));
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 8); // 2 DWORDs
	new ((BYTE*)this + 0x18) FString(*(const FString*)((const BYTE*)&Other + 0x18));
	appMemcpy((BYTE*)this + 0x24, (const BYTE*)&Other + 0x24, 0x10); // 4 DWORDs
}

IMPL_MATCH("Engine.dll", 0x10445b60)
FStatGraphLine::FStatGraphLine()
{
	new ((BYTE*)this + 0x04) TArray<FLOAT>();
	new ((BYTE*)this + 0x18) FString();
}

// FUN_10322eb0 = TArray<FLOAT>::~TArray() instantiation (ECX = this+0x04 before the call)
IMPL_MATCH("Engine.dll", 0x1032c3c0)
FStatGraphLine::~FStatGraphLine()
{
	((FString*)((BYTE*)this + 0x18))->~FString();
	((TArray<FLOAT>*)((BYTE*)this + 0x04))->~TArray();
}

// FUN_1031f660 = TArray<FLOAT> copy assignment (copies 4-byte elements via FArray::Add loop)
IMPL_MATCH("Engine.dll", 0x10321790)
FStatGraphLine& FStatGraphLine::operator=(const FStatGraphLine& Other)
{
	*(DWORD*)((BYTE*)this + 0x00) = *(const DWORD*)((const BYTE*)&Other + 0x00);
	*(TArray<FLOAT>*)((BYTE*)this + 0x04) = *(const TArray<FLOAT>*)((const BYTE*)&Other + 0x04);
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 8);
	*(FString*)((BYTE*)this + 0x18) = *(const FString*)((const BYTE*)&Other + 0x18);
	appMemcpy((BYTE*)this + 0x24, (const BYTE*)&Other + 0x24, 0x10);
	return *this;
}

IMPL_MATCH("Engine.dll", 0x10316930)
int FStatGraphLine::operator==(FStatGraphLine const& Other) const
{
	return this == &Other;
}


// ============================================================================
// FStatGraph / FStats / FEngineStats implementations
// (moved from EngineStubs.cpp)
// ============================================================================

// FStatGraph layout (from Ghidra copy-ctor 0x103518f0 + AddLine analysis):
// +0x00: DWORD, +0x04: DWORD
// +0x08: TArray (stride unknown — FUN_1033b2a0 copies it)
// +0x1c: TArray<FStatGraphLine> (stride 0x34 confirmed from AddLine FArray::Add call)
// +0x28: TArray (stride unknown — FUN_1031ce50 copies it)
// +0x34..+0x4c: 7 DWORDs
// +0x54: FString

// ??0FStatGraph@@QAE@ABV0@@Z
IMPL_TODO("Ghidra 0x103518f0: copy ctor — FUN_1033b2a0/FUN_1032dff0/FUN_1031ce50 per-type TArray copy helpers not yet resolved")
FStatGraph::FStatGraph(FStatGraph const & p0) {}

// ??1FStatGraph@@QAE@XZ
// Destruction order from Ghidra EH state analysis:
//   1. ~FString at +0x54
//   2. ~TArray<FLOAT> at +0x28 (FUN_10322eb0)
//   3. ~TArray<FStatGraphLine> at +0x1c: per-element dtors then buffer free (FUN_1034fa30)
//   4. ~TArray<?> at +0x08 (FUN_1033b300) -- element type unknown, assumed POD; free buffer
IMPL_TODO("Ghidra 0x10446960: +0x08 TArray element type unknown (FUN_1033b300); all other steps implemented")
FStatGraph::~FStatGraph() {
	((FString*)((BYTE*)this + 0x54))->~FString();
	((TArray<FLOAT>*)((BYTE*)this + 0x28))->~TArray();
	FArray* linesArr = (FArray*)((BYTE*)this + 0x1c);
	INT numLines = linesArr->Num();
	BYTE* linesData = (BYTE*)linesArr->GetData();
	for (INT i = numLines - 1; i >= 0; i--)
		((FStatGraphLine*)(linesData + i * 0x34))->~FStatGraphLine();
	linesArr->Empty(0x34, 0);
	// +0x08 TArray: element type unknown (FUN_1033b300); free buffer only
	((FArray*)((BYTE*)this + 0x08))->Empty(4, 0);
}

// ??4FStatGraph@@QAEAAV0@ABV0@@Z
IMPL_TODO("Ghidra 0x103519b0: operator= — TArray@+0x08/+0x1c/+0x28 per-type copy helpers; FStatGraphLine non-trivial copy ctor not yet resolved")
FStatGraph & FStatGraph::operator=(FStatGraph const & p0) {
	appMemcpy(Pad, p0.Pad, sizeof(Pad));
	return *this;
}

// ?Exec@FStatGraph@@QAEHPBGAAVFOutputDevice@@@Z
// DAT_1055e67c assumed to be L"AUTOCYCLE".
// FUN_104455d0 (rescale), FUN_10445540 (line lookup), FUN_103601f0 (stat registration) -- stubs.
IMPL_TODO("Ghidra 0x10445880: DAT_1055e67c=L\"AUTOCYCLE\" assumed; FUN_104455d0/FUN_10445540/FUN_103601f0 are unknown helpers -- rescale and stat-add paths not implemented")
int FStatGraph::Exec(const TCHAR* p0, FOutputDevice& p1) {
	const TCHAR* Cmd = p0;
	if (ParseCommand(&Cmd, TEXT("GRAPH"))) {
		if (ParseCommand(&Cmd, TEXT("SHOW"))) {
			DWORD& show = *(DWORD*)((BYTE*)this + 0x00);
			show = (show == 0) ? 1 : 0;
		} else if (ParseCommand(&Cmd, TEXT("AUTOCYCLE"))) {
			DWORD& ac = *(DWORD*)((BYTE*)this + 0x48);
			ac = (ac == 0) ? 1 : 0;
		} else if (ParseCommand(&Cmd, TEXT("LOCKSCALE"))) {
			DWORD& ls = *(DWORD*)((BYTE*)this + 0x04);
			ls = (ls == 0) ? 1 : 0;
		} else if (ParseCommand(&Cmd, TEXT("RESCALE"))) {
			// FUN_104455d0: rescale helper -- unknown, stub
		} else {
			Parse(Cmd, TEXT("XRANGE="), *(INT*)((BYTE*)this + 0x44));
			Parse(Cmd, TEXT("XSIZE="),  *(FLOAT*)((BYTE*)this + 0x34));
			Parse(Cmd, TEXT("YSIZE="),  *(FLOAT*)((BYTE*)this + 0x38));
			Parse(Cmd, TEXT("XPOS="),   *(FLOAT*)((BYTE*)this + 0x3c));
			Parse(Cmd, TEXT("YPOS="),   *(FLOAT*)((BYTE*)this + 0x40));
			Parse(Cmd, TEXT("ALPHA="),  *(BYTE*)((BYTE*)this + 0x50));
			FString& filter = *(FString*)((BYTE*)this + 0x54);
			Parse(Cmd, TEXT("FILTER="), filter);
			FString none(TEXT("None"));
			if (filter == none) filter = FString(TEXT(""));
			FString addstat;
			Parse(Cmd, TEXT("ADDSTAT="), addstat);
			// FUN_10445540 (line lookup) and FUN_103601f0 (stat registration) -- stubs
		}
		return 1;
	}
	return 0;
}

// ?AddDataPoint@FStatGraph@@QAEXVFString@@MH@Z
// FUN_10445810 (line lookup by name) is unknown -- replaced by linear name search.
// p2 used as HSV hue byte when auto-creating a new line.
IMPL_TODO("Ghidra 0x10445e40: FUN_10445810 (name->index hash lookup) replaced by linear search; otherwise structurally complete")
void FStatGraph::AddDataPoint(FString p0, float p1, int p2) {
	FArray* lines = (FArray*)((BYTE*)this + 0x1c);
	INT lineIdx = INDEX_NONE;
	for (INT i = 0; i < lines->Num(); i++) {
		FStatGraphLine* l = (FStatGraphLine*)((BYTE*)lines->GetData() + i * 0x34);
		if (*(FString*)((BYTE*)l + 0x18) == p0) { lineIdx = i; break; }
	}
	if (lineIdx == INDEX_NONE) {
		if (p0.Len() == 0) return;
		FColor color = FColor(FGetHSV((BYTE)p2, 0x80, 0xFF));
		FString nameCopy(p0);
		AddLineAutoRange(nameCopy, color);
		for (INT i = 0; i < lines->Num(); i++) {
			FStatGraphLine* l = (FStatGraphLine*)((BYTE*)lines->GetData() + i * 0x34);
			if (*(FString*)((BYTE*)l + 0x18) == p0) { lineIdx = i; break; }
		}
		if (lineIdx == INDEX_NONE) return;
	}
	FStatGraphLine* line = (FStatGraphLine*)((BYTE*)lines->GetData() + lineIdx * 0x34);
	check(line != NULL);
	FLOAT* bufData = *(FLOAT**)((BYTE*)line + 0x04);
	INT writeIdx = *(INT*)((BYTE*)line + 0x10);
	bufData[writeIdx] = p1;
	writeIdx++;
	if (writeIdx > 0xFF) writeIdx = 0;
	*(INT*)((BYTE*)line + 0x10) = writeIdx;
	if (*(INT*)((BYTE*)line + 0x30) != 0) {
		if (p1 < *(FLOAT*)((BYTE*)line + 0x24)) *(FLOAT*)((BYTE*)line + 0x24) = p1;
		if (p1 > *(FLOAT*)((BYTE*)line + 0x28)) *(FLOAT*)((BYTE*)line + 0x28) = p1;
	}
}

// ?AddLine@FStatGraph@@QAEXVFString@@VFColor@@MM@Z
// FUN_10445bb0 (name->index registration) is unknown -- line not registered in retail
// hash lookup, but the array structure and all field assignments are complete.
IMPL_TODO("Ghidra 0x10445c30: FUN_10445bb0 (name->index registration) unknown -- line not registered in retail lookup table, but array/field structure is complete")
void FStatGraph::AddLine(FString p0, FColor p1, float p2, float p3) {
	FArray* lines = (FArray*)((BYTE*)this + 0x1c);
	INT idx = lines->Add(1, 0x34);
	FStatGraphLine* newLine = (FStatGraphLine*)((BYTE*)lines->GetData() + idx * 0x34);
	new (newLine) FStatGraphLine();
	*(DWORD*)((BYTE*)newLine + 0x00) = 0;
	((FArray*)((BYTE*)newLine + 0x04))->AddZeroed(4, 0x100);  // 256-entry circular buffer
	*(INT*)((BYTE*)newLine + 0x10) = 0;
	*(FColor*)((BYTE*)newLine + 0x14) = p1;
	*(FString*)((BYTE*)newLine + 0x18) = p0;
	*(FLOAT*)((BYTE*)newLine + 0x24) = p2;
	*(FLOAT*)((BYTE*)newLine + 0x28) = p3;
	*(DWORD*)((BYTE*)newLine + 0x2c) = 0x3e4ccccd;  // 0.2f scale
	*(INT*)((BYTE*)newLine + 0x30) = 0;
	// FUN_10445bb0(name_ptr, &idx): name->index registration -- unknown, skip
}

// ?AddLineAutoRange@FStatGraph@@QAEXVFString@@VFColor@@@Z
// FUN_10445810 (line lookup by name) is unknown -- workaround uses last-added element.
IMPL_TODO("Ghidra 0x10445d40: FUN_10445810 (line lookup) unknown -- workaround sets auto-range on last-added element instead of looking up by name")
void FStatGraph::AddLineAutoRange(FString p0, FColor p1) {
	FString nameCopy(p0);
	AddLine(nameCopy, p1, 0.0f, 0.0f);
	FArray* lines = (FArray*)((BYTE*)this + 0x1c);
	INT lastIdx = lines->Num() - 1;
	if (lastIdx >= 0) {
		FStatGraphLine* line = (FStatGraphLine*)((BYTE*)lines->GetData() + lastIdx * 0x34);
		check(line != NULL);
		*(INT*)((BYTE*)line + 0x30) = 1;
	}
}

// ?Render@FStatGraph@@QAEXPAVUViewport@@PAVFRenderInterface@@@Z
IMPL_TODO("Ghidra 0x10446000: 1990 bytes — renders stat graph to viewport; FUN_ blockers for D3D draw calls")
void FStatGraph::Render(UViewport * p0, FRenderInterface * p1) {}

// ?Reset@FStatGraph@@QAEXXZ
IMPL_TODO("Ghidra 0x10446800: 95 bytes — FUN_1033bb10/FUN_103203b0/FUN_1031fea0 not yet resolved")
void FStatGraph::Reset() {}

// ============================================================================
// FStats
// ============================================================================
IMPL_TODO("Ghidra 0x1033bdb0: copy ctor — FUN_1031ce50/FUN_1031cb20/FUN_1031ded0 for TArrays and _eh_vector_copy_constructor_iterator_ not yet resolved")
FStats::FStats(const FStats& Other) { appMemcpy(this, &Other, sizeof(*this)); }
IMPL_TODO("Ghidra 0x1033bca0: dtor — FUN_1033a7d0/_eh_vector_destructor_iterator_/FUN_103217e0/FUN_10322eb0 per TArray member not yet resolved")
FStats::~FStats() {}
IMPL_TODO("Ghidra 0x1044f1a0: 595 bytes — updates display string for a stat slot; FUN_ blockers")
void FStats::UpdateString(FString&, INT) {}
IMPL_TODO("Ghidra 0x1044f6e0: 20219 bytes — renders all stat categories to viewport; FUN_ blockers for D3D draw calls")
void FStats::Render(UViewport*, UEngine*) {}
IMPL_MATCH("Engine.dll", 0x10454670)
INT FStats::RegisterStats(EStatsType StatType, EStatsDataType DataType,
	FString StatName, FString DisplayName, EStatsUnit Unit)
{
	INT SlotIdx = -1;

	if (DataType == (EStatsDataType)0)
	{
		SlotIdx = ((FArray*)((BYTE*)this + 0x1C))->AddZeroed(4);
		((FArray*)((BYTE*)this + 0x28))->AddZeroed(4);
		INT ni = ((FArray*)((BYTE*)this + 0x34))->AddZeroed(sizeof(FString));
		*(FString*)(*(BYTE**)((BYTE*)this + 0x34) + ni * sizeof(FString)) = StatName;
		INT di = ((FArray*)((BYTE*)this + 0x40))->AddZeroed(sizeof(FString));
		*(FString*)(*(BYTE**)((BYTE*)this + 0x40) + di * sizeof(FString)) = DisplayName + StatName;
	}
	else if (DataType == (EStatsDataType)1)
	{
		SlotIdx = ((FArray*)((BYTE*)this + 0x4C))->AddZeroed(4);
		((FArray*)((BYTE*)this + 0x58))->AddZeroed(4);
		INT ni = ((FArray*)((BYTE*)this + 0x64))->AddZeroed(sizeof(FString));
		*(FString*)(*(BYTE**)((BYTE*)this + 0x64) + ni * sizeof(FString)) = StatName;
		INT di = ((FArray*)((BYTE*)this + 0x70))->AddZeroed(sizeof(FString));
		*(FString*)(*(BYTE**)((BYTE*)this + 0x70) + di * sizeof(FString)) = DisplayName + StatName;
	}
	else if (DataType == (EStatsDataType)2)
	{
		SlotIdx = ((FArray*)((BYTE*)this + 0x7C))->AddZeroed(sizeof(FString));
		((FArray*)((BYTE*)this + 0x88))->AddZeroed(sizeof(FString));
		INT ni = ((FArray*)((BYTE*)this + 0x94))->AddZeroed(sizeof(FString));
		*(FString*)(*(BYTE**)((BYTE*)this + 0x94) + ni * sizeof(FString)) = StatName;
		INT di = ((FArray*)((BYTE*)this + 0xA0))->AddZeroed(sizeof(FString));
		*(FString*)(*(BYTE**)((BYTE*)this + 0xA0) + di * sizeof(FString)) = DisplayName + StatName;
	}
	else
	{
		return -1;
	}
	INT ri = ((FArray*)((BYTE*)this + (INT)StatType * 12 + 0xAC))->Add(1, 12);
	INT* pRec = (INT*)(*(BYTE**)((BYTE*)this + (INT)StatType * 12 + 0xAC) + ri * 12);
	pRec[0] = SlotIdx;
	pRec[1] = (INT)DataType;
	pRec[2] = (INT)Unit;
	return SlotIdx;
}
IMPL_TODO("Ghidra 0x1044f5d0: 257 bytes — moving average on stat data using offset 0x100 array; FUN_ blockers")
void FStats::CalcMovingAverage(INT, DWORD) {}
IMPL_MATCH("Engine.dll", 0x1044f430)
void FStats::Clear()
{
	BYTE* Base = (BYTE*)this;
	INT*   IntData     = *(INT**)(Base + 0x1C);
	INT    IntNum      = *(INT*)(Base + 0x20);
	INT*   PrevIntData = *(INT**)(Base + 0x28);
	INT*   FloatData     = *(INT**)(Base + 0x4C);
	INT    FloatNum      = *(INT*)(Base + 0x50);
	INT*   PrevFloatData = *(INT**)(Base + 0x58);
	BYTE*  StrData      = *(BYTE**)(Base + 0x7C);
	INT    StrNum       = *(INT*)(Base + 0x80);
	BYTE*  PrevStrData  = *(BYTE**)(Base + 0x88);
	if (IntNum > 0)
		appMemcpy(PrevIntData, IntData, IntNum * 4);
	if (FloatNum > 0)
		appMemcpy(PrevFloatData, FloatData, FloatNum * 4);
	for (INT i = 0; i < StrNum; i++)
	{
		FString* Dst = (FString*)(PrevStrData + i * 0xC);
		FString* Src = (FString*)(StrData + i * 0xC);
		*Dst = *Src;
	}
	if (IntNum > 0)
		appMemzero(IntData, IntNum * 4);
	if (FloatNum > 0)
		appMemzero(FloatData, FloatNum * 4);
	for (INT i = 0; i < StrNum; i++)
	{
		FString* Str = (FString*)(StrData + i * 0xC);
		*Str = TEXT("");
	}
}

// ============================================================================
// FEngineStats
// ============================================================================
IMPL_MATCH("Engine.dll", 0x10301de0)
FEngineStats& FEngineStats::operator=(const FEngineStats& Other)
{
	appMemcpy(this, &Other, 99 * 4);
	return *this;
}

IMPL_TODO("Ghidra 0x10454940: 6696 bytes — registers all engine stats via RegisterStats; FUN_ blockers for stat name strings")
void FEngineStats::Init() {}
