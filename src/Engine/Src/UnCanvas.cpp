/*=============================================================================
	UnCanvas.cpp: 2D canvas rendering (UCanvas, FCanvasUtil)
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

// --- FCanvasUtil ---
FCanvasUtil::FCanvasUtil(FCanvasUtil const &Other)
{
	// Ghidra 0x18c10: vtable set by compiler; same copy regions as operator= (0x18cb0):
	// scalar state +4..+53, skip transient +54..+93, big vertex batch +94..+CA7
	appMemcpy((BYTE*)this + 0x04, (const BYTE*)&Other + 0x04, 0x50);
	appMemcpy((BYTE*)this + 0x94, (const BYTE*)&Other + 0x94, 0xC14);
}

FCanvasUtil::FCanvasUtil(UViewport *,FRenderInterface *,int,int)
{
}

FCanvasUtil::~FCanvasUtil()
{
}

FCanvasUtil& FCanvasUtil::operator=(const FCanvasUtil& Other)
{
	// Ghidra 0x18cb0: vtable at +0 skipped. Copy +4..+53, skip +54..+93 (transient state),
	// then copy +94..+CA7 (includes big vertex batch + 3 trailing DWORDs)
	appMemcpy((BYTE*)this + 0x04, (const BYTE*)&Other + 0x04, 0x50);
	appMemcpy((BYTE*)this + 0x94, (const BYTE*)&Other + 0x94, 0xC14);
	return *this;
}

// (merged from earlier occurrence)
void FCanvasUtil::BeginPrimitive(EPrimitiveType,UMaterial *)
{
}
void FCanvasUtil::DrawLine(float,float,float,float,FColor)
{
}
void FCanvasUtil::DrawPoint(float,float,float,float,float,FColor)
{
}
void FCanvasUtil::DrawTile(float,float,float,float,float,float,float,float,float,UMaterial *,FColor)
{
}
void FCanvasUtil::DrawTileRotated(float,float,float,float,float,float,float,float,float,UMaterial *,FColor,float)
{
}
void FCanvasUtil::Flush()
{
}
unsigned __int64 FCanvasUtil::GetCacheId()
{
	// Ghidra: CacheId QWORD at this+0xc9c = Pad+0xc98
	return *(QWORD*)(Pad + 0xc98);
}
int FCanvasUtil::GetComponents(FVertexComponent* C)
{
	C[0].Type = 1; C[0].Function = 0;
	C[1].Type = 4; C[1].Function = 2;
	C[2].Type = 2; C[2].Function = 4;
	return 3;
}
void FCanvasUtil::GetRawStreamData(void * *,int)
{
}
int FCanvasUtil::GetRevision()
{
	return 1;
}
int FCanvasUtil::GetSize()
{
	// Ghidra: count at this+0x98 = Pad+0x94, times stride 0x18
	return *(INT*)(Pad + 0x94) * 0x18;
}
void FCanvasUtil::GetStreamData(void * Dest)
{
	// Ghidra: memcpy from inline vertex buffer at this+0x9c = Pad+0x98
	INT Size = *(INT*)(Pad + 0x94) * 0x18;
	appMemcpy(Dest, Pad + 0x98, Size);
}
int FCanvasUtil::GetStride()
{
	return 0x18;
}


// --- UCanvas ---
void __cdecl UCanvas::WrappedPrint(ERenderStyle,int &,int &,UFont *,int,const TCHAR*)
{
}

void UCanvas::WrappedPrintf(UFont *,int,const TCHAR*,...)
{
}

void UCanvas::WrappedStrLenf(UFont *,int &,int &,const TCHAR*,...)
{
}

// (merged from earlier occurrence)
void UCanvas::SetVirtualSize(FLOAT SizeX, FLOAT SizeY)
{
	// Retail: 59b. Only stores new virtual size if current virtual dims >= origin dims.
	// this+0x40=OrgX, this+0x44=OrgY, this+0xA4=VirtualX, this+0xA8=VirtualY.
	// Retail uses FUCOMPP+TEST AH,0x44+JP to compare -- divergence: uses < instead.
	if (*(FLOAT*)((BYTE*)this + 0xA4) < *(FLOAT*)((BYTE*)this + 0x40)) return;
	if (*(FLOAT*)((BYTE*)this + 0xA8) < *(FLOAT*)((BYTE*)this + 0x44)) return;
	*(FLOAT*)((BYTE*)this + 0x9C) = SizeX;
	*(FLOAT*)((BYTE*)this + 0xA0) = SizeY;
}
void UCanvas::StartFade(FColor EndColor, FColor FromColor, FLOAT Time, INT Flags)
{
	// Retail: 47b. Stores fade parameters and updates fade state word at this+0xB8.
	// State: sets bit 1 from Flags&1, ensures bit 0 is set, clears this+0xC8.
	*(DWORD*)((BYTE*)this + 0xC4) = *(DWORD*)&Time;
	*(DWORD*)((BYTE*)this + 0xC0) = *(DWORD*)&FromColor;
	*(DWORD*)((BYTE*)this + 0xBC) = *(DWORD*)&EndColor;
	DWORD state = *(DWORD*)((BYTE*)this + 0xB8);
	state = (state & ~2u) | ((Flags & 1) << 1);
	state |= 1u;
	*(DWORD*)((BYTE*)this + 0xC8) = 0;
	*(DWORD*)((BYTE*)this + 0xB8) = state;
}
void UCanvas::UseVirtualSize(int bEnable, float SizeX, float SizeY)
{
	// Retail: 0x89fd0, ordinal 4960. Two modes:
	// bEnable==0: restore — set OrgX/OrgY from VirtualX/VirtualY (or viewport dims if virtual is 0),
	//             reset StretchX/StretchY to 1.0.
	// bEnable!=0: save — store current OrgX/OrgY into VirtualX/VirtualY;
	//              if SizeX/SizeY are non-zero, store into m_fSizeX/m_fSizeY;
	//              set OrgX/OrgY = m_fSizeX/m_fSizeY;
	//              compute StretchX = ViewportW / m_fSizeX, StretchY = ViewportH / m_fSizeY.
	// Offsets: OrgX=0x40, OrgY=0x44, HalfClipX=0x48, HalfClipY=0x4C,
	//          Viewport*=0x7C, m_fSizeX=0x9C, m_fSizeY=0xA0,
	//          StretchX=0x94, StretchY=0x98, VirtualX=0xA4, VirtualY=0xA8.
	if (bEnable == 0) {
		// Restore mode: use VirtualX/VirtualY if > 0, else read viewport dims.
		FLOAT vx = *(FLOAT*)((BYTE*)this + 0xA4);
		FLOAT vy = *(FLOAT*)((BYTE*)this + 0xA8);
		if (vx <= 0.0f || vy <= 0.0f) {
			// Read viewport native size (stored as INT at viewport+0xA4)
			INT* Viewport = *(INT**)((BYTE*)this + 0x7C);
			FLOAT w = (FLOAT)*(INT*)((BYTE*)Viewport + 0xA4);
			*(FLOAT*)((BYTE*)this + 0x40) = w;
			*(FLOAT*)((BYTE*)this + 0x44) = w; // Ghidra: both use +0xA4
		} else {
			*(FLOAT*)((BYTE*)this + 0x40) = vx;
			*(FLOAT*)((BYTE*)this + 0x44) = vy;
		}
		*(FLOAT*)((BYTE*)this + 0x94) = 1.0f;
		*(FLOAT*)((BYTE*)this + 0x98) = 1.0f;
	} else {
		// Save current OrgX/OrgY into VirtualX/VirtualY.
		FLOAT orgX = *(FLOAT*)((BYTE*)this + 0x40);
		FLOAT orgY = *(FLOAT*)((BYTE*)this + 0x44);
		*(FLOAT*)((BYTE*)this + 0xA8) = orgY;
		*(FLOAT*)((BYTE*)this + 0xA4) = orgX;
		// If new size parameters are non-zero, store them; otherwise keep current m_fSizeX/Y.
		if (SizeX != 0.0f && SizeY != 0.0f) {
			if (orgX == *(FLOAT*)((BYTE*)this + 0x40) || orgY == *(FLOAT*)((BYTE*)this + 0x44)) {
				// OrgX/OrgY unchanged: recurse with enable (mirrors retail's recursive call).
				UseVirtualSize(1, SizeX, SizeY);
			} else {
				*(FLOAT*)((BYTE*)this + 0x9C) = SizeX;
				*(FLOAT*)((BYTE*)this + 0xA0) = SizeY;
			}
		}
		// Set OrgX/OrgY = m_fSizeX/Y and compute stretch ratios.
		INT* Viewport = *(INT**)((BYTE*)this + 0x7C);
		INT vpW = *(INT*)((BYTE*)Viewport + 0xA4);
		INT vpH = *(INT*)((BYTE*)Viewport + 0xA8);
		*(FLOAT*)((BYTE*)this + 0x40) = *(FLOAT*)((BYTE*)this + 0x9C);
		*(FLOAT*)((BYTE*)this + 0x44) = *(FLOAT*)((BYTE*)this + 0xA0);
		*(FLOAT*)((BYTE*)this + 0x94) = (FLOAT)vpW / *(FLOAT*)((BYTE*)this + 0x9C);
		*(FLOAT*)((BYTE*)this + 0x98) = (FLOAT)vpH / *(FLOAT*)((BYTE*)this + 0xA0);
	}
	// Always recompute HalfClipX/Y.
	*(FLOAT*)((BYTE*)this + 0x48) = *(FLOAT*)((BYTE*)this + 0x40) * 0.5f;
	*(FLOAT*)((BYTE*)this + 0x4C) = *(FLOAT*)((BYTE*)this + 0x44) * 0.5f;
}
void UCanvas::SetStretch(float stretchX, float stretchY)
{
	// Retail (23b): stores both params directly into m_fStretchX (0x94) and m_fStretchY (0x98)
	m_fStretchX = stretchX;
	m_fStretchY = stretchY;
}
void UCanvas::DrawTileClipped(UMaterial *,float,float,float,float,float,float)
{
}
int UCanvas::_DrawString(UFont *,int,int,const TCHAR*,FPlane,int,int,int)
{
	return 0;
}
void UCanvas::WrappedDrawString(ERenderStyle,int &,int &,UFont *,int,const TCHAR*)
{
}
void UCanvas::SetClip(INT X, INT Y, INT W, INT H)
{
  // Retail (59b, RVA 0x881D0): set clip origin and size, compute half-sizes,
  // reset cursor. Global constant at data+0x22C608 = 0.5f.
  OrgX      = (FLOAT)X;
  OrgY      = (FLOAT)Y;
  ClipX     = (FLOAT)W;
  ClipY     = (FLOAT)H;
  HalfClipX = W * 0.5f;
  HalfClipY = H * 0.5f;
  CurX      = 0.0f;
  CurY      = 0.0f;
}
void UCanvas::DrawIcon(UMaterial *,float,float,float,float,float,FPlane,FPlane)
{
}
void UCanvas::DrawPattern(UMaterial *,float,float,float,float,float,float,float,float,FPlane,FPlane)
{
}
void UCanvas::DrawTile(UMaterial *,float,float,float,float,float,float,float,float,float,FPlane,FPlane,float)
{
}


// --- FCanvasVertex ---
FCanvasVertex::FCanvasVertex(FVector InPoint, FColor InColor, float InU, float InV)
:	Point(InPoint)
,	Color(InColor)
,	U(InU)
,	V(InV)
{
}

FCanvasVertex::FCanvasVertex()
{
}

FCanvasVertex& FCanvasVertex::operator=(const FCanvasVertex& Other)
{
	Point = Other.Point;
	Color = Other.Color;
	U     = Other.U;
	V     = Other.V;
	return *this;
}


// =============================================================================
// UCanvas (moved from EngineClassImpl.cpp)
// =============================================================================

// UCanvas
// ---------------------------------------------------------------------------
void UCanvas::Destroy()
{
	Super::Destroy();
}

void UCanvas::Serialize(FArchive& Ar)
{
	Super::Serialize(Ar);
}

UBOOL UCanvas::Exec(const TCHAR* Cmd, FOutputDevice& Ar)
{
	return 0;
}

// ---------------------------------------------------------------------------
