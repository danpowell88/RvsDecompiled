/*=============================================================================
	UnTex.cpp: Texture and material system (UTexture hierarchy)
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

// --- UMaterial ---




void UMaterial::ClearFallbacks()
{
}

// (merged from earlier occurrence)
UMaterial * UMaterial::ConvertPolyFlagsToMaterial(UMaterial *,DWORD)
{
	return NULL;
}


// --- UTexture ---


void UTexture::Prime()
{
	// Retail: 49b. Loops while PrimeCurrent < PrimeCount, calling vtable[42]
	// (prime-one-mip callback) each iteration.
	// PrimeCount BYTE at this+0xAC, PrimeCurrent BYTE at this+0xAD.
	while (PrimeCurrent < PrimeCount)
	{
		++PrimeCurrent;
		void** vtbl = *(void***)this;
		typedef void (__thiscall *PrimeFn)(UTexture*);
		((PrimeFn)vtbl[42])(this);
	}
}

// (merged from earlier occurrence)
void UTexture::SetLastUpdateTime(double Time)
{
	// Ghidra (13B): __LastUpdateTime at offset 0xD0 as double
	*(double*)((BYTE*)this + 0xD0) = Time;
}
int UTexture::Compress(ETextureFormat,int,FDXTCompressionOptions *)
{
	return 0;
}
ETextureFormat UTexture::ConvertDXT(int,int,int,void * *)
{
	return TEXF_P8;
}
ETextureFormat UTexture::ConvertDXT()
{
	return TEXF_P8;
}
void UTexture::CreateColorRange()
{
}
void UTexture::CreateMips(int,int)
{
}
int UTexture::Decompress(ETextureFormat)
{
	return 0;
}
int UTexture::DefaultLOD()
{
	return 0;
}
FColor * UTexture::GetColors()
{
	// Ghidra (14B): if Palette (0x70) non-null, return Colors data at Palette+0x2C
	void* Pal = *(void**)((BYTE*)this + 0x70);
	if (Pal)
		return *(FColor**)((BYTE*)Pal + 0x2C);
	return NULL;
}
DWORD UTexture::GetColorsIndex()
{
	// Ghidra (9B): return Palette->GetIndex()
	UObject* Pal = *(UObject**)((BYTE*)this + 0x70);
	return Pal->GetIndex();
}
FString UTexture::GetFormatDesc()
{
	return FString();
}
double UTexture::GetLastUpdateTime()
{
	// Ghidra (7B): return double at offset 0xD0
	return *(double*)((BYTE*)this + 0xD0);
}
FMipmapBase * UTexture::GetMip(int MipIndex)
{
	// Ghidra (19B): Mips at 0xBC, element stride 0x28
	BYTE* MipsData = *(BYTE**)((BYTE*)this + 0xBC);
	return (FMipmapBase*)(MipsData + MipIndex * 0x28);
}
int UTexture::GetNumMips()
{
	return Mips.Num();
}
FColor UTexture::GetTexel(float,float,float,float)
{
	return FColor(0,0,0,0);
}
void UTexture::Tick(float)
{
}
void UTexture::ArithOp(UTexture *,ETextureArithOp)
{
}
void UTexture::Clear(DWORD)
{
}
void UTexture::Clear(FColor)
{
}
void UTexture::ConstantTimeTick()
{
	// Retail: 45b. Advances the circular linked-list for realtime texture ticking.
	// this+0xA8 = "current" pointer; object+0xA4 = "next" pointer in each node.
	// If current is null, initializes to self. Then advances current to next.
	void* cur = *(void**)((BYTE*)this + 0xA8);
	if (!cur)
		cur = this;
	void* nxt = *(void**)((BYTE*)cur + 0xA4);
	*(void**)((BYTE*)this + 0xA8) = nxt ? nxt : this; // advance or wrap to self
}
UBitmapMaterial * UTexture::Get(double,UViewport *)
{
	return NULL;
}
FBaseTexture * UTexture::GetRenderInterface()
{
	return reinterpret_cast<FBaseTexture*>(RenderInterface);
}
void UTexture::Init(int,int)
{
}


// --- FDXTCompressionOptions ---
FDXTCompressionOptions::FDXTCompressionOptions()
{
}

FDXTCompressionOptions& FDXTCompressionOptions::operator=(const FDXTCompressionOptions& Other)
{
	// Ghidra 0x14390: 9 DWORDs, no vtable. Shares address with CCompressedLipDescData.
	appMemcpy(this, &Other, 36);
	return *this;
}


// --- FMipmap ---
FMipmap::FMipmap(FMipmap const &)
{
}

FMipmap::FMipmap(BYTE,BYTE)
{
}

FMipmap::FMipmap(BYTE,BYTE,int)
{
}

FMipmap::FMipmap()
{
}

FMipmap::~FMipmap()
{
}

FMipmap& FMipmap::operator=(const FMipmap& Other)
{
	// Ghidra 0x27790: FMipmapBase 4 DWORDs at +0..+0C, skip FLazyLoader vtable at +10,
	// deep-copy TArray<BYTE> at +1C, then SavedAr at +14 and SavedPos at +18
	appMemcpy(this, &Other, 0x10); // FMipmapBase data
	*(TArray<BYTE>*)((BYTE*)this + 0x1C) = *(const TArray<BYTE>*)((const BYTE*)&Other + 0x1C);
	*(DWORD*)((BYTE*)this + 0x14) = *(const DWORD*)((const BYTE*)&Other + 0x14);
	*(DWORD*)((BYTE*)this + 0x18) = *(const DWORD*)((const BYTE*)&Other + 0x18);
	return *this;
}

void FMipmap::Clear()
{
}


// --- FMipmapBase ---
FMipmapBase::FMipmapBase(BYTE,BYTE)
{
}

FMipmapBase::FMipmapBase()
{
}

FMipmapBase& FMipmapBase::operator=(const FMipmapBase& Other)
{
	appMemcpy( this, &Other, sizeof(FMipmapBase) );
	return *this;
}


// --- UBitmapMaterial ---


UBitmapMaterial * UBitmapMaterial::Get(double,UViewport *)
{
	return this;
}


// --- UCombiner ---








// --- UConstantColor ---
FColor UConstantColor::GetColor(float)
{
	return Color;
}


// --- UConstantMaterial ---
FColor UConstantMaterial::GetColor(float)
{
	return FColor(0,0,0,0);
}


// --- UCubemap ---
void UCubemap::Destroy()
{
}

FBaseTexture * UCubemap::GetRenderInterface()
{
	// Retail: 8B 81 F0 00 00 00 C3 = return *(this+0xF0) — UCubemap's own render interface
	return *(FBaseTexture**)((BYTE*)this + 0xF0);
}


// --- UFadeColor ---
FColor UFadeColor::GetColor(float)
{
	return FColor(0,0,0,0);
}


// --- UFinalBlend ---






// --- UMaterialSwitch ---
void UMaterialSwitch::PostEditChange()
{
}

int UMaterialSwitch::CheckCircularReferences(TArray<UMaterial *> &)
{
	return 0;
}


// --- UModifier ---








// --- UPalette ---
UPalette * UPalette::ReplaceWithExisting()
{
	return NULL;
}


BYTE UPalette::BestMatch(FColor,int)
{
	return 0;
}

void UPalette::FixPalette()
{
}


// --- UProxyBitmapMaterial ---
void UProxyBitmapMaterial::SetTextureInterface(FBaseTexture * Interface)
{
	TextureInterface = Interface;
}

UBitmapMaterial * UProxyBitmapMaterial::Get(double,UViewport *)
{
	return this;
}

FBaseTexture * UProxyBitmapMaterial::GetRenderInterface()
{
	return TextureInterface;
}


// --- UShader ---




// --- UShadowBitmapMaterial ---
void UShadowBitmapMaterial::Destroy()
{
	// Retail: 0x12e3f0, 125 bytes. Free two render buffers at +0x9C and +0xA0 then
	// call Super::Destroy(). Uses GMalloc->Free (vtable[2]) for deallocation.
	void** buf0 = (void**)((BYTE*)this + 0x9C);
	void** buf1 = (void**)((BYTE*)this + 0xA0);
	if (*buf0) { appFree(*buf0); *buf0 = NULL; }
	if (*buf1) { appFree(*buf1); *buf1 = NULL; }
	UObject::Destroy();
}

UBitmapMaterial * UShadowBitmapMaterial::Get(double,UViewport *)
{
	return NULL;
}

FBaseTexture * UShadowBitmapMaterial::GetRenderInterface()
{
	// Retail: 8B 81 9C 00 00 00 C3 = return *(this+0x9C) — render interface pointer in shadow bitmap
	return *(FBaseTexture**)((BYTE*)this + 0x9C);
}


// --- UTexCoordMaterial ---
INT UTexCoordMaterial::MaterialUSize()
{
	return Material ? Material->MaterialUSize() : 0;
}

INT UTexCoordMaterial::MaterialVSize()
{
	return Material ? Material->MaterialVSize() : 0;
}


// --- UTexCoordSource ---
void UTexCoordSource::PostEditChange()
{
	// Retail: 25b. Call parent, then clamp TexCoordCount at this+0x64 to 0 if negative.
	// Also zeroes mode byte at this+0x5C when clamping.
	UModifier::PostEditChange();
	INT& coordCount = *(INT*)((BYTE*)this + 0x64);
	if (coordCount < 0)
	{
		coordCount = 0;
		*(BYTE*)((BYTE*)this + 0x5C) = 0;
	}
}


// --- UTexEnvMap ---
FMatrix * UTexEnvMap::GetMatrix(float)
{
	// Retail: 21b. When env mapping mode (this+0x64) == 1: set coord-generation
	// mode byte at this+0x5C = 0x0B (GL_REFLECTION_MAP). Returns NULL always.
	BYTE envMode = *(BYTE*)((BYTE*)this + 0x64);
	if (envMode == 1)
		*(BYTE*)((BYTE*)this + 0x5C) = 0x0B;
	return NULL;
}


// --- UTexMatrix ---
FMatrix * UTexMatrix::GetMatrix(float)
{
	return &Matrix;
}


// --- UTexModifier ---
void UTexModifier::SetValidated(int x)
{
	// Delegate to Material via virtual call if present.
	// Retail: 8B 41 58 85 C0 74 07 8B C8 8B 01 FF 60 6C C2 04 00
	if (Material)
		Material->SetValidated(x);
}

BYTE UTexModifier::RequiredUVStreams()
{
	// Retail: when TexCoordSource <= 7 and Material present: (1<<src)|Material->RequiredUVStreams()
	// When TexCoordSource <= 7 and no Material: (1<<src)|1
	if (TexCoordSource <= 7)
	{
		if (Material)
		{
			BYTE matResult = Material->RequiredUVStreams();
			return (BYTE)((1 << TexCoordSource) | matResult);
		}
		return 0; // Retail: JZ to RET with EAX=0 when Material is NULL
	}
	// TexCoordSource > 7 (world/camera coords etc.): retail cross-function-jump (divergence)
	if (Material)
		return Material->RequiredUVStreams();
	return 1;
}

int UTexModifier::MaterialUSize()
{
	// Retail: 17b. Delegates to Material->MaterialUSize(); returns 0 if null.
	if (!Material) return 0;
	return Material->MaterialUSize();
}

int UTexModifier::MaterialVSize()
{
	// Retail: 17b. Delegates to Material->MaterialVSize(); returns 0 if null.
	if (!Material) return 0;
	return Material->MaterialVSize();
}

FMatrix * UTexModifier::GetMatrix(float)
{
	return NULL;
}

int UTexModifier::GetValidated()
{
	// Retail: if Material -> tail-call Material->GetValidated(); else return 1
	// 8B 41 58 85 C0 74 07 8B C8 8B 01 FF 60 68 B8 01 00 00 00 C3
	if (Material)
		return Material->GetValidated();
	return 1;
}


// --- UTexOscillator ---
FMatrix * UTexOscillator::GetMatrix(float)
{
	return NULL;
}


// --- UTexPanner ---
FMatrix * UTexPanner::GetMatrix(float)
{
	return NULL;
}


// --- UTexRotator ---
void UTexRotator::PostLoad()
{
	// Retail: 28b. Call parent PostLoad (imports UObject::PostLoad from Core.dll),
	// then convert legacy bit 0 of this+0x68: if set, clear it and set this+0x64=1.
	Super::PostLoad();
	DWORD& flags = *(DWORD*)((BYTE*)this + 0x68);
	if (flags & 1)
	{
		flags &= ~1u;
		*(BYTE*)((BYTE*)this + 0x64) = 1;
	}
}

FMatrix * UTexRotator::GetMatrix(float)
{
	return NULL;
}


// --- UTexScaler ---
FMatrix * UTexScaler::GetMatrix(float)
{
	return NULL;
}

