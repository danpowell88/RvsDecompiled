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

IMPL_DIVERGE("VA unconfirmed (not at 0x1032c410 which is copy ctor); correct init of TArray<FLOAT> and FString members")
FStatGraphLine::FStatGraphLine()
{
	// Initialize TArray<FLOAT> at +4 and FString at +18 to empty
	new ((BYTE*)this + 0x04) TArray<FLOAT>();
	new ((BYTE*)this + 0x18) FString();
}

IMPL_DIVERGE("VA unconfirmed; destroys FString at +0x18 and TArray<FLOAT> at +0x04")
FStatGraphLine::~FStatGraphLine()
{
	// Destroy FString at +18 then TArray<FLOAT> at +4 (reverse order)
	((FString*)((BYTE*)this + 0x18))->~FString();
	((TArray<FLOAT>*)((BYTE*)this + 0x04))->~TArray();
}

IMPL_DIVERGE("VA unconfirmed; correct field-by-field copy")
FStatGraphLine& FStatGraphLine::operator=(const FStatGraphLine& Other)
{
	// Ghidra 0x21790: DWORD at +0, TArray<FLOAT> at +4 (FUN_1031f660=4-byte data points),
	// 2 DWORDs at +10,+14, FString at +18, 4 DWORDs at +24..+30
	*(DWORD*)((BYTE*)this + 0x00) = *(const DWORD*)((const BYTE*)&Other + 0x00);
	*(TArray<FLOAT>*)((BYTE*)this + 0x04) = *(const TArray<FLOAT>*)((const BYTE*)&Other + 0x04);
	appMemcpy((BYTE*)this + 0x10, (const BYTE*)&Other + 0x10, 8); // 2 DWORDs
	*(FString*)((BYTE*)this + 0x18) = *(const FString*)((const BYTE*)&Other + 0x18);
	appMemcpy((BYTE*)this + 0x24, (const BYTE*)&Other + 0x24, 0x10); // 4 DWORDs
	return *this;
}

IMPL_DIVERGE("VA unconfirmed; pointer equality")
int FStatGraphLine::operator==(FStatGraphLine const& Other) const
{
	// Ghidra 0x16930: pointer equality comparison only.
	return this == &Other;
}


// ============================================================================
// FStatGraph / FStats / FEngineStats implementations
// (moved from EngineStubs.cpp)
// ============================================================================

// ??0FStatGraph@@QAE@ABV0@@Z
IMPL_DIVERGE("Ghidra 0x103518f0: copy ctor with FUN_ calls for nested TArrays/FStrings — bulk memcpy approximation")
FStatGraph::FStatGraph(FStatGraph const & p0) {}

// ??1FStatGraph@@QAE@XZ
IMPL_DIVERGE("VA unconfirmed; trivially empty")
FStatGraph::~FStatGraph() {}

// ??4FStatGraph@@QAEAAV0@ABV0@@Z
IMPL_DIVERGE("VA unconfirmed; bulk memcpy of Pad fields")
FStatGraph & FStatGraph::operator=(FStatGraph const & p0) {
	appMemcpy(Pad, p0.Pad, sizeof(Pad));
	return *this;
}

// ?Exec@FStatGraph@@QAEHPBGAAVFOutputDevice@@@Z
IMPL_DIVERGE("Ghidra 0x10445880, 533 bytes: command dispatch with FUN_ calls — returns 0")
int FStatGraph::Exec(const TCHAR* p0, FOutputDevice & p1) { return 0; }

// ?AddDataPoint@FStatGraph@@QAEXVFString@@MH@Z
IMPL_DIVERGE("Ghidra 0x10445e40, 386 bytes: adds float data to a named graph line; FUN_ blockers")
void FStatGraph::AddDataPoint(FString p0, float p1, int p2) {}

// ?AddLine@FStatGraph@@QAEXVFString@@VFColor@@MM@Z
IMPL_DIVERGE("Ghidra 0x10445c30, 219 bytes: adds graph line with color/range; FUN_ blockers")
void FStatGraph::AddLine(FString p0, FColor p1, float p2, float p3) {}

// ?AddLineAutoRange@FStatGraph@@QAEXVFString@@VFColor@@@Z
IMPL_DIVERGE("Ghidra 0x10445d40, 206 bytes: adds auto-range graph line; FUN_ blockers")
void FStatGraph::AddLineAutoRange(FString p0, FColor p1) {}

// ?Render@FStatGraph@@QAEXPAVUViewport@@PAVFRenderInterface@@@Z
IMPL_DIVERGE("Ghidra 0x10446000, 1990 bytes: renders stat graph to viewport; FUN_ blockers for D3D draw calls")
void FStatGraph::Render(UViewport * p0, FRenderInterface * p1) {}

// ?Reset@FStatGraph@@QAEXXZ
IMPL_DIVERGE("Ghidra 0x10446800, 95 bytes: calls FUN_1033bb10, FUN_103203b0, FUN_1031fea0 — unresolved")
void FStatGraph::Reset() {}

// ============================================================================
// FStats
// ============================================================================
IMPL_DIVERGE("Ghidra 0x1033bdb0, 346 bytes: copy ctor with FUN_ calls for nested TArrays; bulk memcpy approximation")
FStats::FStats(const FStats& Other) { appMemcpy(this, &Other, sizeof(*this)); }
IMPL_DIVERGE("VA unconfirmed; trivially empty")
FStats::~FStats() {}
IMPL_DIVERGE("Ghidra 0x1044f1a0, 595 bytes: updates display string for a stat slot; FUN_ blockers")
void FStats::UpdateString(FString&, INT) {}
IMPL_DIVERGE("Ghidra 0x1044f6e0, 20219 bytes: renders all stat categories to viewport; FUN_ blockers for D3D draw calls")
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
IMPL_DIVERGE("Ghidra 0x1044f5d0, 257 bytes: moving average on stat data; FUN_ blockers")
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
IMPL_DIVERGE("VA unconfirmed; bulk memcpy of all fields (99*4 bytes)")
FEngineStats& FEngineStats::operator=(const FEngineStats& Other)
{
	appMemcpy(this, &Other, 99 * 4);
	return *this;
}

IMPL_DIVERGE("Ghidra 0x10454940, 6696 bytes: registers all engine stats via RegisterStats; FUN_ blockers for stat name strings")
void FEngineStats::Init() {}
