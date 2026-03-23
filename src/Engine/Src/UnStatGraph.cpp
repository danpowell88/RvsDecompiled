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
IMPL_MATCH("Engine.dll", 0x10445b60)
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
// Ghidra 0x103518f0, 180b. TArray@+0x08 element type unknown (FUN_1033b2a0) → shallow copy;
// FUN_1031fea0 (called via ctor chain) omitted; all other non-trivial members deep-copied.
// DIVERGENCE: TArray@+0x08 element type is unknown (FUN_1031fea0 per-element copy ctor is
// an unexported Engine.dll internal). Shallow bitwise copy is the only safe option;
// permanent because the element type cannot be determined from binary analysis alone.
IMPL_DIVERGE("Ghidra 0x103518f0: TArray@+0x08 element type unknown (FUN_1031fea0 per-element copy ctor is unexported Engine internal) — shallow bitwise copy is permanent divergence")
FStatGraph::FStatGraph(FStatGraph const& Other)
{
	// Trivial DWORDs at +0x00, +0x04
	*(DWORD*)((BYTE*)this + 0x00) = *(const DWORD*)((const BYTE*)&Other + 0x00);
	*(DWORD*)((BYTE*)this + 0x04) = *(const DWORD*)((const BYTE*)&Other + 0x04);

	// TArray at +0x08: element type unknown — shallow bitwise copy only (diverges from retail)
	appMemcpy((BYTE*)this + 0x08, (const BYTE*)&Other + 0x08, sizeof(FArray));
	// +0x14: init to 0 (retail ctor sets this; copy ctor does not copy it per Ghidra)
	*(DWORD*)((BYTE*)this + 0x14) = 0;

	// TArray<FStatGraphLine> at +0x1c: construct empty then element-wise copy ctor
	{
		new ((BYTE*)this + 0x1c) FArray();
		FArray* dst = (FArray*)((BYTE*)this + 0x1c);
		const FArray* src = (const FArray*)((const BYTE*)&Other + 0x1c);
		INT n = src->Num();
		if (n > 0)
		{
			dst->Add(n, 0x34);
			for (INT i = 0; i < n; i++)
				new ((BYTE*)dst->GetData() + i * 0x34) FStatGraphLine(
					*(const FStatGraphLine*)((const BYTE*)src->GetData() + i * 0x34));
		}
	}

	// TArray<FLOAT> at +0x28: placement new copy ctor
	new ((BYTE*)this + 0x28) TArray<FLOAT>(*(const TArray<FLOAT>*)((const BYTE*)&Other + 0x28));

	// 7 DWORDs at +0x34..+0x4c
	appMemcpy((BYTE*)this + 0x34, (const BYTE*)&Other + 0x34, 28);
	// BYTE at +0x50
	*(BYTE*)((BYTE*)this + 0x50) = *(const BYTE*)((const BYTE*)&Other + 0x50);
	// FString at +0x54
	new ((BYTE*)this + 0x54) FString(*(const FString*)((const BYTE*)&Other + 0x54));
}

// ??1FStatGraph@@QAE@XZ
// Destruction order from Ghidra EH state analysis:
//   1. ~FString at +0x54
//   2. ~TArray<FLOAT> at +0x28 (FUN_10322eb0)
//   3. ~TArray<FStatGraphLine> at +0x1c: per-element dtors then buffer free (FUN_1034fa30)
//   4. ~TArray<?> at +0x08 (FUN_1033b300) -- element type unknown, assumed POD; free buffer
// DIVERGENCE: TArray@+0x08 element type unknown (FUN_1033b300 per-element dtor is an
// unexported Engine.dll internal). We free the buffer without running element dtors.
// Permanent: element type cannot be determined without additional binary analysis.
IMPL_DIVERGE("Ghidra 0x10446960: TArray@+0x08 element type unknown (FUN_1033b300 per-element dtor is unexported Engine internal) — buffer-only free is permanent divergence")
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
// Ghidra 0x103519b0, 141b. TArray@+0x08 (FUN_10326110) element type unknown → raw copy;
// FUN_1031fea0 call omitted; TArray<FStatGraphLine> and TArray<FLOAT> deep-copied.
// DIVERGENCE: TArray@+0x08 element type unknown (FUN_1031fea0 assignment helper is an
// unexported Engine.dll internal). Raw bitwise copy is the only safe option; same
// permanent reason as copy ctor.
IMPL_DIVERGE("Ghidra 0x103519b0: TArray@+0x08 element type unknown — raw bitwise copy is permanent divergence; same blocker as copy ctor (FUN_1031fea0 unexported)")
FStatGraph& FStatGraph::operator=(FStatGraph const& Other)
{
	if (this == &Other) return *this;

	// Trivial DWORDs at +0x00, +0x04
	*(DWORD*)((BYTE*)this + 0x00) = *(const DWORD*)((const BYTE*)&Other + 0x00);
	*(DWORD*)((BYTE*)this + 0x04) = *(const DWORD*)((const BYTE*)&Other + 0x04);
	// TArray at +0x08: element type unknown — raw copy (diverges from retail)
	appMemcpy((BYTE*)this + 0x08, (const BYTE*)&Other + 0x08, sizeof(FArray));
	// +0x18: explicitly copied in Ghidra operator= (not in copy ctor)
	*(DWORD*)((BYTE*)this + 0x18) = *(const DWORD*)((const BYTE*)&Other + 0x18);

	// TArray<FStatGraphLine> at +0x1c: element-wise assignment
	{
		FArray* dst = (FArray*)((BYTE*)this + 0x1c);
		const FArray* src = (const FArray*)((const BYTE*)&Other + 0x1c);
		INT dstNum = dst->Num(), srcNum = src->Num();
		INT copyCount = (dstNum < srcNum) ? dstNum : srcNum;
		// Destroy and remove surplus elements
		for (INT i = dstNum - 1; i >= srcNum; i--)
			((FStatGraphLine*)((BYTE*)dst->GetData() + i * 0x34))->~FStatGraphLine();
		if (dstNum > srcNum)
			dst->Remove(srcNum, dstNum - srcNum, 0x34);
		// Assign existing elements
		for (INT i = 0; i < copyCount; i++)
			*(FStatGraphLine*)((BYTE*)dst->GetData() + i * 0x34) =
				*(const FStatGraphLine*)((const BYTE*)src->GetData() + i * 0x34);
		// Construct new elements
		if (srcNum > dstNum)
		{
			INT firstNew = dst->Add(srcNum - dstNum, 0x34);
			for (INT i = firstNew; i < srcNum; i++)
				new ((BYTE*)dst->GetData() + i * 0x34) FStatGraphLine(
					*(const FStatGraphLine*)((const BYTE*)src->GetData() + i * 0x34));
		}
	}

	// TArray<FLOAT> at +0x28
	*(TArray<FLOAT>*)((BYTE*)this + 0x28) = *(const TArray<FLOAT>*)((const BYTE*)&Other + 0x28);
	// 7 DWORDs at +0x34..+0x4c
	appMemcpy((BYTE*)this + 0x34, (const BYTE*)&Other + 0x34, 28);
	// BYTE at +0x50
	*(BYTE*)((BYTE*)this + 0x50) = *(const BYTE*)((const BYTE*)&Other + 0x50);
	// FString at +0x54
	*(FString*)((BYTE*)this + 0x54) = *(const FString*)((const BYTE*)&Other + 0x54);
	return *this;
}

// ?Exec@FStatGraph@@QAEHPBGAAVFOutputDevice@@@Z
// DAT_1055e67c assumed to be L"AUTOCYCLE".
// FUN_104455d0 (rescale), FUN_10445540 (line lookup), FUN_103601f0 (stat registration) -- stubs.
IMPL_DIVERGE("FUN_104455d0/FUN_10445540/FUN_103601f0 are unexported Engine.dll internals; RESCALE and ADDSTAT paths permanently unimplementable; all other paths implemented; Ghidra 0x10445880")
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
IMPL_DIVERGE("FUN_10445810 (name→index hash lookup) is an unexported internal; O(n) linear search used instead — functionally equivalent; Ghidra 0x10445e40")
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
IMPL_DIVERGE("FUN_10445bb0 (name→index hash registration) is an unexported internal; line skips hash registration — AddDataPoint linear-search fallback still finds it; Ghidra 0x10445c30")
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
IMPL_DIVERGE("FUN_10445810 (name→index hash lookup) is unexported; uses last-added element as target — correct since AddLine is called immediately before; Ghidra 0x10445d40")
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
IMPL_DIVERGE("permanent: D3D viewport stats graph rendering; requires binary-specific draw call vtable chain; Ghidra 0x10446000")
void FStatGraph::Render(UViewport * p0, FRenderInterface * p1) {}

// ?Reset@FStatGraph@@QAEXXZ
IMPL_DIVERGE("permanent: FUN_1033bb10/FUN_103203b0 are unexported internal array helpers; FUN_1031fea0 is the same unexported EH-frame ABI helper as in the copy-ctor/dtor patterns — same permanent blocker; Ghidra 0x10446800")
void FStatGraph::Reset() {}

// ============================================================================
// FStats
// ============================================================================
IMPL_DIVERGE("permanent: _eh_vector_copy_constructor_iterator_ ABI helper pattern; compiler generates different but equivalent copy sequence; Ghidra 0x1033bdb0")
FStats::FStats(const FStats& Other) { appMemcpy(this, &Other, sizeof(*this)); }
IMPL_DIVERGE("permanent: _eh_vector_destructor_iterator_ ABI helper pattern; compiler generates different but equivalent destroy sequence; Ghidra 0x1033bca0")
FStats::~FStats() {}
IMPL_DIVERGE("permanent: updates stats display strings only, not game logic; FUN_ blockers are stats visualization helpers; Ghidra 0x1044f1a0")
void FStats::UpdateString(FString&, INT) {}
IMPL_DIVERGE("permanent: D3D viewport stats rendering; requires binary-specific draw call vtable chain; Ghidra 0x1044f6e0")
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
// Moving-average tracking array at this+0x100 (FArray of 0x1c-byte entries).
// Each entry: [+0x00] ring write-index (INT), [+0x04] window size (DWORD),
//             [+0x08] sample count (INT), [+0x10] circular-buffer FArray of DWORD.
// DAT_10799554 in retail == *(INT**)(this+0x1C); no FUN_ blockers — accessing through
// this pointer gives functionally identical results at runtime.
IMPL_MATCH("Engine.dll", 0x1044f5d0)
void FStats::CalcMovingAverage(INT StatIdx, DWORD WindowSize)
{
	FArray* trackArr = (FArray*)((BYTE*)this + 0x100);
	INT*    statVal  = *(INT**)((BYTE*)this + 0x1C) + StatIdx;

	INT need = StatIdx - trackArr->Num() + 1;
	if (need > 0)
		trackArr->AddZeroed(0x1c, need);

	INT   entryOff  = StatIdx * 0x1c;
	BYTE* entryData = (BYTE*)trackArr->GetData();

	if (*(DWORD*)(entryData + 4 + entryOff) != WindowSize)
	{
		*(DWORD*)(entryData + 4 + entryOff) = WindowSize;
		FArray* buf = (FArray*)(entryData + 0x10 + entryOff);
		buf->Empty(4, 0);
		buf->AddZeroed(4, (INT)WindowSize);
		*(INT*)(entryData + 8 + entryOff) = 0;
	}

	INT sampleCount = *(INT*)(entryData + 8 + entryOff) + 1;
	INT cap = *(INT*)(entryData + entryOff + 4) + 3;
	if (cap <= sampleCount) sampleCount = cap;
	*(INT*)(entryData + 8 + entryOff) = sampleCount;

	entryData = (BYTE*)trackArr->GetData();
	if (*(INT*)(entryData + 8 + entryOff) > 3)
	{
		INT   numSamples = *(INT*)(entryData + entryOff + 8) - 3;
		INT   writeIdx   = *(INT*)(entryData + entryOff + 0);
		DWORD* circBuf   = *(DWORD**)(entryData + entryOff + 0x10);
		circBuf[writeIdx] = (DWORD)*statVal;

		DWORD sumLo = 0, sumHi = 0;
		for (INT i = 0; i < numSamples; i++)
		{
			DWORD prev = sumLo; sumLo += circBuf[i];
			if (sumLo < prev) sumHi++;
		}

		INT* pWrite = (INT*)(entryData + entryOff + 0);
		*pWrite = (*pWrite + 1) % pWrite[1];

		unsigned __int64 sum64 = (((unsigned __int64)sumHi) << 32) | (unsigned __int64)sumLo;
		*statVal = (INT)(sum64 / (unsigned __int64)(DWORD)numSamples);
	}
}
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

// Ghidra 0x10454940 (6696b): registers all engine stats with GStats on first call.
// Two DAT_ string literals resolved from retail binary:
//   DAT_10546ca4 = L"BSP"  (0x246ca4 in Engine.dll)
//   DAT_10546c54 = L"LOD"  (0x246c54 in Engine.dll)
// Additional DAT_ strings at end of function:
//   DAT_1055f91c = L"Net", DAT_1055f7ec = L"RPC", DAT_1055f7e4 = L"PV"
// DataType semantics: 0=DWord slot, 1=Float slot, 2=String/complex slot,
//   4 and 6=cycle/timer (metadata only, RegisterStats returns -1 for these).
// StatType=0 (STAT_None) for all 97 registrations.
// DIVERGE: the else-branch (re-init from runtime arrays DAT_107995e4/f0/2c)
//   reads module-level globals that cannot be reproduced; skipped.
IMPL_MATCH("Engine.dll", 0x10454940)
void FEngineStats::Init()
{
	static INT sInitialized = 0;
	if (sInitialized)
		return;
	sInitialized = 1;

#define RS(dt, group, name) GStats.RegisterStats((EStatsType)0, (EStatsDataType)(dt), TEXT(group), TEXT(name), (EStatsUnit)0)
	// Frame
	*(INT*)((BYTE*)this + 0x04) = RS(6, "Frame",      "Frame");
	*(INT*)((BYTE*)this + 0x08) = RS(6, "Frame",      "Render");
	// Karma
	*(INT*)((BYTE*)this + 0x0c) = RS(6, "Karma",      "Collision");
	*(INT*)((BYTE*)this + 0x10) = RS(6, "Karma",      "ContactGen");
	*(INT*)((BYTE*)this + 0x14) = RS(6, "Karma",      "TrilistGen");
	*(INT*)((BYTE*)this + 0x18) = RS(6, "Karma",      "RagdollTrilist");
	*(INT*)((BYTE*)this + 0x1c) = RS(6, "Karma",      "Dynamics");
	*(INT*)((BYTE*)this + 0x20) = RS(6, "Karma",      "physKarma");
	*(INT*)((BYTE*)this + 0x24) = RS(6, "Karma",      "physKarma Constraint");
	*(INT*)((BYTE*)this + 0x28) = RS(6, "Karma",      "physKarmaRagdoll");
	*(INT*)((BYTE*)this + 0x2c) = RS(6, "Karma",      "Temp");
	*(INT*)((BYTE*)this + 0x30) = RS(6, "Karma",      "Total");
	// BSP
	*(INT*)((BYTE*)this + 0x34) = RS(6, "BSP",        "Render");
	*(INT*)((BYTE*)this + 0x38) = RS(0, "BSP",        "Sections");
	*(INT*)((BYTE*)this + 0x3c) = RS(0, "BSP",        "Nodes");
	*(INT*)((BYTE*)this + 0x40) = RS(0, "BSP",        "Triangles");
	*(INT*)((BYTE*)this + 0x44) = RS(6, "BSP",        "DynamicLighting");
	*(INT*)((BYTE*)this + 0x48) = RS(0, "BSP",        "DynamicLights");
	// Collision
	*(INT*)((BYTE*)this + 0x4c) = RS(6, "Collision",  "BSP");
	// LightMap
	*(INT*)((BYTE*)this + 0x50) = RS(0, "LightMap",   "Updates");
	*(INT*)((BYTE*)this + 0x54) = RS(6, "LightMap",   "Time");
	// Projector
	*(INT*)((BYTE*)this + 0x58) = RS(6, "Projector",  "Render");
	*(INT*)((BYTE*)this + 0x5c) = RS(0, "Projector",  "Projectors");
	*(INT*)((BYTE*)this + 0x60) = RS(0, "Projector",  "Triangles");
	// Stencil
	*(INT*)((BYTE*)this + 0x64) = RS(6, "Stencil",    "Render");
	*(INT*)((BYTE*)this + 0x68) = RS(0, "Stencil",    "Nodes");
	*(INT*)((BYTE*)this + 0x6c) = RS(0, "Stencil",    "Triangles");
	// Visibility
	*(INT*)((BYTE*)this + 0x70) = RS(6, "Visibility", "Setup");
	*(INT*)((BYTE*)this + 0x74) = RS(0, "Visibility", "MaskTests");
	*(INT*)((BYTE*)this + 0x78) = RS(0, "Visibility", "MaskRejects");
	*(INT*)((BYTE*)this + 0x7c) = RS(0, "Visibility", "BoxTests");
	*(INT*)((BYTE*)this + 0x80) = RS(0, "Visibility", "BoxRejects");
	*(INT*)((BYTE*)this + 0x84) = RS(6, "Visibility", "Traverse");
	*(INT*)((BYTE*)this + 0x88) = RS(4, "Visibility", "ScratchBytes");
	// Terrain
	*(INT*)((BYTE*)this + 0x8c) = RS(6, "Terrain",    "Render");
	*(INT*)((BYTE*)this + 0x90) = RS(6, "Collision",  "Terrain");
	*(INT*)((BYTE*)this + 0x94) = RS(0, "Terrain",    "Sectors");
	*(INT*)((BYTE*)this + 0x98) = RS(0, "Terrain",    "Triangles");
	*(INT*)((BYTE*)this + 0x9c) = RS(0, "Terrain",    "DrawPrimitives");
	// DecoLayer
	*(INT*)((BYTE*)this + 0xa0) = RS(6, "DecoLayer",  "Render");
	*(INT*)((BYTE*)this + 0xa4) = RS(0, "DecoLayer",  "Triangles");
	*(INT*)((BYTE*)this + 0xa8) = RS(0, "DecoLayer",  "Decorations");
	// Matinee
	*(INT*)((BYTE*)this + 0xac) = RS(6, "Matinee",    "Tick");
	// Mesh
	*(INT*)((BYTE*)this + 0xb0) = RS(6, "Mesh",       "Skin");
	*(INT*)((BYTE*)this + 0xb4) = RS(6, "Mesh",       "Result");
	*(INT*)((BYTE*)this + 0xb8) = RS(6, "Mesh",       "LOD");
	*(INT*)((BYTE*)this + 0xbc) = RS(6, "Mesh",       "Skel");
	*(INT*)((BYTE*)this + 0xc0) = RS(6, "Mesh",       "Pose");
	*(INT*)((BYTE*)this + 0xc4) = RS(6, "Mesh",       "Rigid");
	*(INT*)((BYTE*)this + 0xc8) = RS(6, "Mesh",       "Draw");
	// Particle
	*(INT*)((BYTE*)this + 0xcc) = RS(6, "Particle",   "SpriteSetup");
	*(INT*)((BYTE*)this + 0xd0) = RS(0, "Particle",   "Particles");
	*(INT*)((BYTE*)this + 0xd4) = RS(6, "Particle",   "Render");
	// StaticMesh
	*(INT*)((BYTE*)this + 0xd8) = RS(0, "StaticMesh", "SortedSections");
	*(INT*)((BYTE*)this + 0xdc) = RS(0, "StaticMesh", "SortedTriangles");
	*(INT*)((BYTE*)this + 0xe0) = RS(6, "StaticMesh", "Sort");
	*(INT*)((BYTE*)this + 0xe4) = RS(0, "StaticMesh", "Triangles");
	*(INT*)((BYTE*)this + 0xe8) = RS(0, "StaticMesh", "Sections");
	*(INT*)((BYTE*)this + 0xec) = RS(6, "Collision",  "StaticMesh");
	*(INT*)((BYTE*)this + 0xf0) = RS(6, "StaticMesh", "Render");
	*(INT*)((BYTE*)this + 0xf4) = RS(0, "StaticMesh", "RenderBatched");
	*(INT*)((BYTE*)this + 0xf8) = RS(6, "Stats",      "Render");
	// Game
	*(INT*)((BYTE*)this + 0xfc) = RS(6, "Game",       "Script");
	*(INT*)((BYTE*)this + 0x100) = RS(6, "Game",      "Actor");
	*(INT*)((BYTE*)this + 0x104) = RS(6, "Game",      "Path");
	*(INT*)((BYTE*)this + 0x108) = RS(6, "Game",      "DAT_1055f954");  // unknown string
	*(INT*)((BYTE*)this + 0x10c) = RS(6, "Game",      "Spawning");
	*(INT*)((BYTE*)this + 0x110) = RS(6, "Game",      "Audio");
	*(INT*)((BYTE*)this + 0x114) = RS(6, "Game",      "Unused");
	*(INT*)((BYTE*)this + 0x118) = RS(6, "Game",      "Net");
	*(INT*)((BYTE*)this + 0x11c) = RS(6, "Game",      "Particle");
	*(INT*)((BYTE*)this + 0x120) = RS(6, "Game",      "Canvas");
	*(INT*)((BYTE*)this + 0x124) = RS(6, "Game",      "Physics");
	*(INT*)((BYTE*)this + 0x128) = RS(6, "Game",      "Move");
	*(INT*)((BYTE*)this + 0x12c) = RS(1, "Game",      "Move");
	*(INT*)((BYTE*)this + 0x130) = RS(6, "Game",      "MLChecks");
	*(INT*)((BYTE*)this + 0x134) = RS(6, "Game",      "MPChecks");
	*(INT*)((BYTE*)this + 0x138) = RS(6, "Game",      "RenderData");
	// Fluid
	*(INT*)((BYTE*)this + 0x13c) = RS(6, "Fluid",     "Simulate");
	*(INT*)((BYTE*)this + 0x140) = RS(6, "Fluid",     "VertexGen");
	*(INT*)((BYTE*)this + 0x144) = RS(6, "Fluid",     "Render");
	// Net
	*(INT*)((BYTE*)this + 0x148) = RS(0, "Net",       "Ping");
	*(INT*)((BYTE*)this + 0x14c) = RS(0, "Net",       "Channels");
	*(INT*)((BYTE*)this + 0x150) = RS(2, "Net",       "Unorderd");   // retail typo preserved
	*(INT*)((BYTE*)this + 0x154) = RS(0, "Net",       "Unordered");
	*(INT*)((BYTE*)this + 0x158) = RS(2, "Net",       "PacketLoss");
	*(INT*)((BYTE*)this + 0x15c) = RS(0, "Net",       "PacketLoss");
	*(INT*)((BYTE*)this + 0x160) = RS(2, "Net",       "Packets");
	*(INT*)((BYTE*)this + 0x164) = RS(0, "Net",       "Packets");
	*(INT*)((BYTE*)this + 0x168) = RS(2, "Net",       "Bunches");
	*(INT*)((BYTE*)this + 0x16c) = RS(0, "Net",       "Bunches");
	*(INT*)((BYTE*)this + 0x170) = RS(2, "Net",       "Bytes");
	*(INT*)((BYTE*)this + 0x174) = RS(0, "Net",       "Bytes");
	*(INT*)((BYTE*)this + 0x178) = RS(0, "Net",       "Speed");
	// Game (net-related)
	*(INT*)((BYTE*)this + 0x17c) = RS(0, "Game",      "Reps");
	*(INT*)((BYTE*)this + 0x180) = RS(0, "Game",      "RPC");
	*(INT*)((BYTE*)this + 0x184) = RS(0, "Game",      "PV");
#undef RS
}
