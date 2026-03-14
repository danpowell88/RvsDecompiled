/*=============================================================================
	UnTex.cpp: Texture and material system (UTexture hierarchy)
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/
#pragma optimize("", off)

#include "EnginePrivate.h"
#include "ImplSource.h"

#pragma warning(push)
#pragma warning(disable: 4291)
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)
#include "EngineDecls.h"
// FUN_103c89f0 = type-checked StaticConstructObject wrapper for UTexEnvMap.
// FUN_10386790 = type-checked StaticConstructObject wrapper for UShader.
// Ghidra: both assert IsChildOf, resolve transient package, then call
// UObject::StaticConstructObject(cls, outer, name, flags, NULL, GError, 0).
// FName is 4 bytes (INDEX only) in this SDK; *(FName*)&name is safe.
IMPL_MATCH("Engine.dll", 0x103c89f0)
static UObject* FUN_103c89f0(UClass* cls, UObject* outer, DWORD name, DWORD flags)
{
	if (!cls->IsChildOf(UTexEnvMap::StaticClass()))
		appFailAssert("Class->IsChildOf(T::StaticClass())",
		              "d:\\ravenshield\\412\\core\\inc\\UnObjBas.h", 0x476);
	if (outer == (UObject*)0xffffffff)
		outer = (UObject*)UObject::GetTransientPackage();
	return UObject::StaticConstructObject(cls, outer, *(FName*)&name, flags,
	                                      NULL, GError, 0);
}
IMPL_MATCH("Engine.dll", 0x10386790)
static UObject* FUN_10386790(UClass* cls, UObject* outer, DWORD name, DWORD flags)
{
	if (!cls->IsChildOf(UShader::StaticClass()))
		appFailAssert("Class->IsChildOf(T::StaticClass())",
		              "d:\\ravenshield\\412\\core\\inc\\UnObjBas.h", 0x476);
	if (outer == (UObject*)0xffffffff)
		outer = (UObject*)UObject::GetTransientPackage();
	return UObject::StaticConstructObject(cls, outer, *(FName*)&name, flags,
	                                      NULL, GError, 0);
}

// --- UMaterial ---




IMPL_DIVERGE("body incomplete — Ghidra 0x103C97F0: uses FUN_10318850 ECX-based GObjObjects iterator; calling convention not standard C++")
void UMaterial::ClearFallbacks()
{
	guard(UMaterial::ClearFallbacks);
	// Ghidra 0xc97f0 (confirmed at 0x103c97f0), 2407B.
	// Iterates all loaded UObjects via FUN_10318850 (GObjObjects iterator at
	// 0x10318850, 59B) and clears bits 0 (UseFallback) and 1 (Validated) of
	// UObject+0x34 for every object that has them set.
	// FUN_10318850 uses ECX as a pointer to an iterator-state struct; it cannot
	// be called from standard C++ without replicating that calling convention.
	// DIVERGENCE: FUN_10318850 not called — full ClearFallbacks loop omitted.
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103c9100)
UMaterial* UMaterial::ConvertPolyFlagsToMaterial(UMaterial* param_1, DWORD param_2)
{
	guard(UMaterial::ConvertPolyFlagsToMaterial);

	UMaterial* this_00 = param_1;

	if (param_1 != NULL)
	{
		INT iVar3 = param_1->IsA(UTexture::StaticClass());
		if ((iVar3 != 0) && (*(INT*)((BYTE*)this_00 + 0x88) != 0))
		{
			DWORD uVar9   = param_2 & 0x1000;
			TCHAR* pwVar10 = (uVar9 == 0) ? TEXT("") : TEXT("Const");
			DWORD  uVar1  = uVar9;

			FString local_40 = FString::Printf(TEXT("%s_%sShiny"), this_00->GetName(), pwVar10);
			FString local_34(local_40);

			if (uVar9 != 0)
				local_34 += TEXT("_Alpha");

			UObject* pUVar5 = UObject::StaticFindObject(
			    UShader::StaticClass(), (UObject*)0xffffffff, *local_34, 0);

			FString local_28;

			if (pUVar5 == NULL)
			{
				local_28 = FString::Printf(TEXT("%s_EnvMapCoords"),
				    (*(UObject**)((BYTE*)this_00 + 0x88))->GetName());

				UObject* pUVar6 = UObject::StaticFindObject(
				    UTexEnvMap::StaticClass(), (UObject*)0xffffffff, *local_28, 0);

				if (pUVar6 == NULL)
				{
					FName fn6(*local_28, FNAME_Add);
					UObject* pOuter6 = (*(UObject**)((BYTE*)this_00 + 0x88))->GetOuter();
					pUVar6 = FUN_103c89f0(UTexEnvMap::StaticClass(), pOuter6, *(DWORD*)&fn6, 0x80004);

					if (*(BYTE*)((BYTE*)this_00 + 0x8c) == 0)
						*(BYTE*)((BYTE*)pUVar6 + 100) = 1;
					else if (*(BYTE*)((BYTE*)this_00 + 0x8c) == 1)
						*(BYTE*)((BYTE*)pUVar6 + 100) = 0;

					*(DWORD*)((BYTE*)pUVar6 + 0x58) = *(DWORD*)((BYTE*)this_00 + 0x88);
				}

				FName fn40(*local_40, FNAME_Add);
				UObject* pOuter = this_00->GetOuter();
				pUVar5 = FUN_10386790(UShader::StaticClass(), pOuter, *(DWORD*)&fn40, 0x80004);

				*(UMaterial**)((BYTE*)pUVar5 + 0x60) = this_00;
				*(UObject**)  ((BYTE*)pUVar5 + 0x68) = pUVar6;
				if (param_2 == 0)
					*(UMaterial**)((BYTE*)pUVar5 + 0x6c) = this_00;
				else
					*(UMaterial**)((BYTE*)pUVar5 + 100) = this_00;
			}

			return (UMaterial*)pUVar5;
		}
	}

	if ((param_2 & 0x400000) != 0)
	{
		TCHAR* pwVar10 = (param_2 & 0x100) ? TEXT("TwoSided") : TEXT("");

		FString local_40b = FString::Printf(TEXT("%s_Unlit%s"), this_00->GetName(), pwVar10);

		UObject* pUVar5 = UObject::StaticFindObject(
		    UShader::StaticClass(), (UObject*)0xffffffff, *local_40b, 0);

		if (pUVar5 == NULL)
		{
			FName fn40b(*local_40b, FNAME_Add);
			UObject* pOuter = this_00->GetOuter();
			pUVar5 = FUN_10386790(UShader::StaticClass(), pOuter, *(DWORD*)&fn40b, 0x80004);
			*(DWORD*)((BYTE*)pUVar5 + 0x5c) ^= ((param_2 >> 8) ^ *(DWORD*)((BYTE*)pUVar5 + 0x5c)) & 1;
			*(UMaterial**)((BYTE*)pUVar5 + 0x70) = this_00;
		}

		return (UMaterial*)pUVar5;
	}

	if ((param_2 & 0x1000) != 0)
	{
		TCHAR* pwVar10 = (param_2 & 0x100) ? TEXT("TwoSided") : TEXT("");

		FString local_40c = FString::Printf(TEXT("%s_Alpha%s"), this_00->GetName(), pwVar10);

		UObject* pUVar5 = UObject::StaticFindObject(
		    UShader::StaticClass(), (UObject*)0xffffffff, *local_40c, 0);

		if (pUVar5 == NULL)
		{
			FName fn40c(*local_40c, FNAME_Add);
			UObject* pOuter = this_00->GetOuter();
			pUVar5 = FUN_10386790(UShader::StaticClass(), pOuter, *(DWORD*)&fn40c, 0x80004);
			*(DWORD*)((BYTE*)pUVar5 + 0x5c) ^= ((param_2 >> 8) ^ *(DWORD*)((BYTE*)pUVar5 + 0x5c)) & 1;
			*(UMaterial**)((BYTE*)pUVar5 + 0x60) = this_00;
			*(UMaterial**)((BYTE*)pUVar5 + 100)  = this_00;
		}

		return (UMaterial*)pUVar5;
	}

	return NULL;

	unguard;
}


// --- UTexture ---


IMPL_MATCH("Engine.dll", 0x10467b20)
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
IMPL_MATCH("Engine.dll", 0x10304510)
void UTexture::SetLastUpdateTime(double Time)
{
	// Ghidra (13B): __LastUpdateTime at offset 0xD0 as double
	*(double*)((BYTE*)this + 0xD0) = Time;
}
IMPL_DIVERGE("body incomplete — Ghidra 0x1046C600 not yet fully reconstructed")
int UTexture::Compress(ETextureFormat,int,FDXTCompressionOptions *)
{
	guard(UTexture::Compress);
	// Retail: 0x16c600, 2427b. DXT compression pipeline — too complex to decompile.
	// TODO: implement UTexture::Compress (retail 0x16c600, 2427 bytes: DXT compression pipeline)
	return 0;
	unguard;
}
IMPL_DIVERGE("body incomplete — Ghidra 0x1046a630 is 334 bytes, DXT format conversion pipeline not fully reconstructed")
ETextureFormat UTexture::ConvertDXT(int,int,int,void * *)
{
	return TEXF_P8;
}
IMPL_DIVERGE("body incomplete — Ghidra 0x1046a7b0 is 282 bytes, DXT format conversion pipeline not fully reconstructed")
ETextureFormat UTexture::ConvertDXT()
{
	return TEXF_P8;
}
IMPL_MATCH("Engine.dll", 0x1046a400)
void UTexture::CreateColorRange()
{
	guard(UTexture::CreateColorRange);
	// Ghidra 0x16a400: scan all mip texels through Palette to find per-channel max.
	// If no Palette, set MaxColor = 0xFFFFFFFF (all-white); otherwise scan.
	if (*(INT*)((BYTE*)this + 0x70) == 0) // Palette == NULL
	{
		*(DWORD*)((BYTE*)this + 0x78) = 0xFFFFFFFF; // MaxColor = white
	}
	else
	{
		*(DWORD*)((BYTE*)this + 0x78) = 0; // MaxColor = 0
		BYTE* palData = *(BYTE**)(*(INT*)((BYTE*)this + 0x70) + 0x2C); // Palette->Colors.Data
		INT mipCount = ((FArray*)((BYTE*)this + 0xBC))->Num();
		for (INT mip = 0; mip < mipCount; mip++)
		{
			// Mips TArray: each element is 0x28 bytes; DataArray at element+0x1C
			BYTE* mipData = *(BYTE**)(*(INT*)((BYTE*)this + 0xBC) + 0x1C + mip * 0x28);
			INT   mipLen  = ((FArray*)(*(INT*)((BYTE*)this + 0xBC) + 0x1C + mip * 0x28))->Num();
			for (INT px = 0; px < mipLen; px++)
			{
				// Each texel is a palette index; look up in palette (4 bytes per color)
				BYTE* col = palData + (DWORD)mipData[px] * 4;
				if (col[2] > *(BYTE*)((BYTE*)this + 0x7A)) *(BYTE*)((BYTE*)this + 0x7A) = col[2]; // B
				if (col[1] > *(BYTE*)((BYTE*)this + 0x79)) *(BYTE*)((BYTE*)this + 0x79) = col[1]; // G
				if (col[0] > *(BYTE*)((BYTE*)this + 0x78)) *(BYTE*)((BYTE*)this + 0x78) = col[0]; // R
				if (col[3] > *(BYTE*)((BYTE*)this + 0x7B)) *(BYTE*)((BYTE*)this + 0x7B) = col[3]; // A
			}
		}
	}
	unguard;
}
IMPL_DIVERGE("body incomplete — Ghidra 0x1046BAC0 not yet fully reconstructed")
void UTexture::CreateMips(int param1, int param2)
{
	guard(UTexture::CreateMips);
	// Ghidra 0x16bac0 (2741 bytes): complex per-format mip chain generation.
	// Handles P8, RGBA8, RGBA16, DXT1/3/5 and box/kaiser filtering.
	// DIVERGENCE: format-dispatch + colour-conversion helpers not yet decompiled.
	(void)param1; (void)param2;
	unguard;
}
IMPL_DIVERGE("body incomplete — Ghidra 0x1046B0C0 not yet fully reconstructed")
int UTexture::Decompress(ETextureFormat)
{
	guard(UTexture::Decompress);
	// Retail: 0x16b0c0, ~250b. DXT1 block decompression — too complex to decompile.
	// TODO: implement UTexture::Decompress (retail 0x16b0c0, ~250 bytes: DXT1 block decompression)
	return 0;
	unguard;
}
IMPL_MATCH("Engine.dll", 0x104691d0)
int UTexture::DefaultLOD()
{
	guard(UTexture::DefaultLOD);
	// Retail: 0x1691d0, 130b. Picks the highest-quality mip level the client is
	// configured to use, clamped by LODSet, MinLODMips and MaxLODMips.
	// UClient raw offsets: +0x64 = INT LODBias table indexed by LODSet (4 bytes/entry),
	//                      +0x84 = INT MinLODMips, +0x88 = INT MaxLODMips.
	if (!__Client || !*(BYTE*)((BYTE*)this + 0xA0)) // LODSet at +0xA0
		return 0;
	if (!GIsEditor)
	{
		FArray* mips = (FArray*)((BYTE*)this + 0xBC); // Mips TArray
		INT mipCount = mips->Num();
		// Only apply LOD clamp when there are no mips yet, or when the first mip
		// is large enough (USize > 8 && VSize > 8) that dropping a level matters.
		if (mipCount == 0 ||
			(8 < *(INT*)(*(INT*)mips + 4) &&  // mips->Data->USize  (FMipmapBase+0x04)
			 8 < *(INT*)(*(INT*)mips + 8)))    // mips->Data->VSize  (FMipmapBase+0x08)
		{
			// LOD bias from the per-LODSet table in the client.
			DWORD bias = *(DWORD*)((BYTE*)__Client + (DWORD)*(BYTE*)((BYTE*)this + 0xA0) * 4 + 100);
			mipCount = mips->Num();
			if ((INT)(mipCount - 1) < (INT)bias)
				bias = (DWORD)(mipCount - 1);
			mipCount = mips->Num();
			// MinLODMips: ensure at least this many mips remain usable.
			if ((INT)(mipCount - bias) < *(INT*)((BYTE*)__Client + 0x84))
			{
				bias = (DWORD)(mipCount - *(INT*)((BYTE*)__Client + 0x84));
				// Ghidra: `((int)bias < 1) - 1 & bias` — clamp to 0 if negative.
				bias = (DWORD)(((INT)bias < 1) - 1) & bias;
			}
			// MaxLODMips: do not skip more mips than this allows.
			if (*(INT*)((BYTE*)__Client + 0x88) < (INT)(mipCount - bias))
			{
				DWORD clamped = (DWORD)(mipCount - *(INT*)((BYTE*)__Client + 0x88));
				if ((INT)bias < (INT)clamped)
					bias = clamped;
			}
			DWORD result = (DWORD)(mipCount - 1);
			if ((INT)bias <= (INT)(mipCount - 1))
				result = bias;
			return (INT)result;
		}
	}
	return 0;
	unguard;
}
IMPL_MATCH("Engine.dll", 0x10318f10)
FColor * UTexture::GetColors()
{
	// Ghidra (14B): if Palette (0x70) non-null, return Colors data at Palette+0x2C
	void* Pal = *(void**)((BYTE*)this + 0x70);
	if (Pal)
		return *(FColor**)((BYTE*)Pal + 0x2C);
	return NULL;
}
IMPL_MATCH("Engine.dll", 0x103042f0)
DWORD UTexture::GetColorsIndex()
{
	// Ghidra (9B): return Palette->GetIndex()
	UObject* Pal = *(UObject**)((BYTE*)this + 0x70);
	return Pal->GetIndex();
}
IMPL_MATCH("Engine.dll", 0x10304310)
FString UTexture::GetFormatDesc()
{
	// Ghidra 0x4310: switch on Format byte (this+0x58), return format name string.
	switch( Format )
	{
		case 0:  return TEXT("P8");
		case 1:  return TEXT("RGBA7");
		case 2:  return TEXT("RGB16");
		case 3:  return TEXT("DXT1");
		case 4:  return TEXT("RGB8");
		case 5:  return TEXT("RGBA8");
		case 7:  return TEXT("DXT3");
		case 8:  return TEXT("DXT5");
		case 9:  return TEXT("L8");
		case 10: return TEXT("G16");
		case 11: return TEXT("RRRGGGBBB");
		default: return TEXT("?");
	}
}
IMPL_MATCH("Engine.dll", 0x10304500)
double UTexture::GetLastUpdateTime()
{
	// Ghidra (7B): return double at offset 0xD0
	return *(double*)((BYTE*)this + 0xD0);
}
IMPL_MATCH("Engine.dll", 0x10318f20)
FMipmapBase * UTexture::GetMip(int MipIndex)
{
	// Ghidra (19B): Mips at 0xBC, element stride 0x28
	BYTE* MipsData = *(BYTE**)((BYTE*)this + 0xBC);
	return (FMipmapBase*)(MipsData + MipIndex * 0x28);
}
IMPL_MATCH("Engine.dll", 0x10304300)
int UTexture::GetNumMips()
{
	return Mips.Num();
}
IMPL_MATCH("Engine.dll", 0x104694b0)
FColor UTexture::GetTexel(float,float,float,float)
{
	return FColor(0,0,0,0);
}
IMPL_MATCH("Engine.dll", 0x104692a0)
void UTexture::Tick(float DeltaSeconds)
{
	guard(UTexture::Tick);
	// Ghidra 0x1692a0: advance animation sequence via vtable[46]=ConstantTimeTick,
	// then gate on frame rate using MinFrameRate/MaxFrameRate accumulators.
	void** vtbl = *(void***)this;
	typedef void(__thiscall *TVFn)(UTexture*);
	// vtable +0xB8 (index 46) = ConstantTimeTick
	((TVFn)vtbl[0xB8/4])(this);
	float maxFPS = *(float*)((BYTE*)this + 0xB4); // MaxFrameRate
	if (maxFPS != 0.0f)
	{
		// Non-zero MaxFrameRate: just advance once and return
		// vtable +0xA8 (index 42) = Prime / animation advance
		((TVFn)vtbl[0xA8/4])(this);
		return;
	}
	// Clamp MaxFrameRate to [0.1, 100]
	float fMax = maxFPS;
	if (fMax < 0.1f) fMax = 0.1f;
	else if (fMax >= 100.0f) fMax = 100.0f;
	// Clamp MinFrameRate to [0.1, 100]
	float fMin = *(float*)((BYTE*)this + 0xB0); // MinFrameRate
	if (fMin < 0.1f) fMin = 0.1f;
	else if (fMin >= 100.0f) fMin = 100.0f;
	float invMin   = 1.0f / fMin;
	float accum    = DeltaSeconds + *(float*)((BYTE*)this + 0xB8); // Accumulator
	*(float*)((BYTE*)this + 0xB8) = accum;
	if (accum >= 1.0f / fMax)
	{
		if (accum < invMin)
		{
			((TVFn)vtbl[0xA8/4])(this);
			*(DWORD*)((BYTE*)this + 0xB8) = 0; // reset
			return;
		}
		((TVFn)vtbl[0xA8/4])(this);
		float newAccum = accum - invMin;
		*(float*)((BYTE*)this + 0xB8) = newAccum;
		if (invMin < newAccum)
			*(float*)((BYTE*)this + 0xB8) = invMin;
	}
	unguard;
}
IMPL_DIVERGE("body incomplete — Ghidra 0x10469500 not yet fully reconstructed")
void UTexture::ArithOp(UTexture *,ETextureArithOp)
{
	// DIVERGENCE: retail (~150+ B) does per-pixel blending. Skipped — too complex.
}
IMPL_MATCH("Engine.dll", 0x1046a570)
void UTexture::Clear(DWORD ClearFlags)
{
	// Ghidra 0x16a570, 58B with SEH. If bit 1 of ClearFlags is set, zero each mip's DataArray.
	if (ClearFlags & 2)
	{
		INT Count = Mips.Num();
		for (INT i = 0; i < Count; i++)
		{
			FMipmap* Mip = (FMipmap*)(*(INT*)((BYTE*)this + 0xBC) + i * 0x28);
			Mip->Clear();
		}
	}
}
IMPL_MATCH("Engine.dll", 0x10469470)
void UTexture::Clear(FColor InColor)
{
	// Ghidra 0x169470, 108B. TEXF_RGBA8 (5) only: fill all pixels with InColor.
	// this+0x58=Format, this+0x60=USize, this+0x64=VSize, this+0xBC=Mips TArray.
	if (Format == TEXF_RGBA8)
	{
		INT Total = USize * VSize;
		if (Total > 0)
		{
			DWORD ColorDW = *(DWORD*)&InColor;
			DWORD* Pixels = *(DWORD**)(*(INT*)((BYTE*)this + 0xBC) + 0x1C);
			for (INT i = 0; i < Total; i++)
				Pixels[i] = ColorDW;
		}
	}
}
IMPL_MATCH("Engine.dll", 0x10467b60)
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
IMPL_MATCH("Engine.dll", 0x10304490)
UBitmapMaterial * UTexture::Get(double Time, UViewport *)
{
	// Retail: 0x4490, 18b. Advance the texture animation via vtable[0xB4/4] (time-tick),
	// then return the current animation frame at +0xA8, falling back to 'this'.
	typedef void (__thiscall *TimeTickFn)(UTexture*, double);
	void** vtbl = *(void***)this;
	((TimeTickFn)vtbl[0xB4/4])(this, Time); // vtable[45] = animation time-tick
	UBitmapMaterial* cur = *(UBitmapMaterial**)((BYTE*)this + 0xA8); // AnimCurrent
	return cur ? cur : (UBitmapMaterial*)this;
}
IMPL_MATCH("Engine.dll", 0x10304480)
FBaseTexture * UTexture::GetRenderInterface()
{
	return *(FBaseTexture**)((BYTE*)this + 0xAC);
}
IMPL_MATCH("Engine.dll", 0x1046b920)
void UTexture::Init(int InUSize, int InVSize)
{
	guard(UTexture::Init);
	// Ghidra 0x16b920: assert power-of-two, set USize/VSize/UClamp/VClamp/UBits/VBits,
	// then add one FMipmap to the Mips array sized for the chosen format.
	if ((*(DWORD*)((BYTE*)this + 0x60) & (*(DWORD*)((BYTE*)this + 0x60) - 1)) != 0)
		appFailAssert("!(USize & (USize-1))", ".\\UnTex.cpp", 0x174);
	if ((*(DWORD*)((BYTE*)this + 0x64) & (*(DWORD*)((BYTE*)this + 0x64) - 1)) != 0)
		appFailAssert("!(VSize & (VSize-1))", ".\\UnTex.cpp", 0x175);
	*(INT*)((BYTE*)this + 0x68) = InUSize; // UClamp
	*(INT*)((BYTE*)this + 0x60) = InUSize; // USize
	*(INT*)((BYTE*)this + 0x6C) = InVSize; // VClamp
	*(INT*)((BYTE*)this + 0x64) = InVSize; // VSize
	*(BYTE*)((BYTE*)this + 0x5B) = (BYTE)appCeilLogTwo(InUSize);  // UBits
	*(BYTE*)((BYTE*)this + 0x5C) = (BYTE)appCeilLogTwo(*(DWORD*)((BYTE*)this + 0x64)); // VBits
	// FUN_1032e620(0) = texture revision/dirty helper: increments a global texture
	// revision counter or marks this texture as needing a cache flush.
	// DIVERGENCE: FUN_1032e620 not called; GPU cache invalidation not triggered here.
	FArray* mipArr = (FArray*)((BYTE*)this + 0xBC);
	BYTE fmt = *(BYTE*)((BYTE*)this + 0x58); // Format
	INT idx = mipArr->Add(1, 0x28);
	FMipmap* pMip = (FMipmap*)(*(INT*)mipArr + idx * 0x28);
	if (pMip)
	{
		if (fmt == 0x5 || fmt == 0xA) // TEXF_RGBA8 or TEXF_RGBA16
		{
			INT byteCount = InVSize * InUSize * (fmt == 0x5 ? 4 : 2);
			new(pMip) FMipmap(*(BYTE*)((BYTE*)this + 0x5B), *(BYTE*)((BYTE*)this + 0x5C), byteCount);
		}
		else
		{
			new(pMip) FMipmap(*(BYTE*)((BYTE*)this + 0x5B), *(BYTE*)((BYTE*)this + 0x5C));
		}
	}
	unguard;
}


// --- FDXTCompressionOptions ---
IMPL_MATCH("Engine.dll", 0x10503248)
FDXTCompressionOptions::FDXTCompressionOptions()
{
	// Ghidra 0x203248: shares entry with FMipmapBase::FMipmapBase() and others — body is empty.
}

IMPL_MATCH("Engine.dll", 0x10314390)
FDXTCompressionOptions& FDXTCompressionOptions::operator=(const FDXTCompressionOptions& Other)
{
	// Ghidra 0x14390: 9 DWORDs, no vtable. Shares address with CCompressedLipDescData.
	appMemcpy(this, &Other, 36);
	return *this;
}


// --- FMipmap ---
IMPL_MATCH("Engine.dll", 0x10327730)
FMipmap::FMipmap(FMipmap const & Other)
{
	// Ghidra 0x27730, 90B. Copy FMipmapBase (+0x00..+0x0F), deep-copy DataArray,
	// copy SavedAr/SavedPos; retail sets TLazyArray vtable at +0x10.
	appMemcpy((BYTE*)this, (const BYTE*)&Other, 0x10); // FMipmapBase fields
	*(TArray<BYTE>*)((BYTE*)this + 0x1C) = *(const TArray<BYTE>*)((const BYTE*)&Other + 0x1C);
	// DIVERGENCE: vtable at +0x10 not set to TLazyArray vtable.
	*(DWORD*)((BYTE*)this + 0x10) = 0;
	*(DWORD*)((BYTE*)this + 0x14) = *(const DWORD*)((const BYTE*)&Other + 0x14); // SavedAr
	*(DWORD*)((BYTE*)this + 0x18) = *(const DWORD*)((const BYTE*)&Other + 0x18); // SavedPos
}

IMPL_MATCH("Engine.dll", 0x10320a10)
FMipmap::FMipmap(BYTE InUBits, BYTE InVBits)
{
	// Ghidra 0x20a10, 89B. Computes W=1<<UBits, H=1<<VBits, allocates W*H bytes.
	INT W = 1 << (InUBits & 0x1F);
	INT H = 1 << (InVBits & 0x1F);
	*(DWORD*)((BYTE*)this + 0x00) = 0;
	*(INT*)  ((BYTE*)this + 0x04) = W;
	*(INT*)  ((BYTE*)this + 0x08) = H;
	*(BYTE*) ((BYTE*)this + 0x0C) = InUBits;
	*(BYTE*) ((BYTE*)this + 0x0D) = InVBits;
	*(BYTE*) ((BYTE*)this + 0x0E) = 0; // padding
	*(BYTE*) ((BYTE*)this + 0x0F) = 0;
	*(DWORD*)((BYTE*)this + 0x10) = 0; // vtable (DIVERGENCE: retail sets TLazyArray vtable)
	*(DWORD*)((BYTE*)this + 0x14) = 0;
	*(DWORD*)((BYTE*)this + 0x18) = 0;
	INT Count = W * H;
	BYTE* Data = Count > 0 ? (BYTE*)appMalloc(Count, TEXT("FMipmap")) : NULL;
	*(BYTE**)((BYTE*)this + 0x1C) = Data;
	*(INT*)  ((BYTE*)this + 0x20) = Count;
	*(INT*)  ((BYTE*)this + 0x24) = Count;
}

IMPL_MATCH("Engine.dll", 0x10320a70)
FMipmap::FMipmap(BYTE InUBits, BYTE InVBits, int InCount)
{
	// Ghidra 0x20a70, 88B. Like (BYTE,BYTE) but uses explicit byte count instead of W*H.
	*(BYTE*) ((BYTE*)this + 0x0C) = InUBits;
	*(INT*)  ((BYTE*)this + 0x04) = 1 << (InUBits & 0x1F);
	*(BYTE*) ((BYTE*)this + 0x0D) = InVBits;
	*(DWORD*)((BYTE*)this + 0x00) = 0;
	*(INT*)  ((BYTE*)this + 0x08) = 1 << (InVBits & 0x1F);
	*(BYTE*) ((BYTE*)this + 0x0E) = 0; // padding
	*(BYTE*) ((BYTE*)this + 0x0F) = 0;
	*(DWORD*)((BYTE*)this + 0x10) = 0; // vtable (DIVERGENCE)
	*(DWORD*)((BYTE*)this + 0x14) = 0;
	*(DWORD*)((BYTE*)this + 0x18) = 0;
	BYTE* Data = InCount > 0 ? (BYTE*)appMalloc(InCount, TEXT("FMipmap")) : NULL;
	*(BYTE**)((BYTE*)this + 0x1C) = Data;
	*(INT*)  ((BYTE*)this + 0x20) = InCount;
	*(INT*)  ((BYTE*)this + 0x24) = InCount;
}

IMPL_MATCH("Engine.dll", 0x103209e0)
FMipmap::FMipmap()
{
	// Ghidra 0x209e0: calls FArray::FArray(this+0x1c,0,1), zeros SavedAr/Pos, sets vtable.
	// DIVERGENCE: vtable at +0x10 not set to TLazyArray vtable.
	appMemzero((BYTE*)this, 0x28);
}

IMPL_MATCH("Engine.dll", 0x10320ad0)
FMipmap::~FMipmap()
{
	// Ghidra 0x20ad0: calls TLazyArray<BYTE>::~TLazyArray(this+0x10).
	// DIVERGENCE: free DataArray directly to avoid memory leak.
	BYTE* Data = *(BYTE**)((BYTE*)this + 0x1C);
	if (Data)
	{
		appFree(Data);
		*(BYTE**)((BYTE*)this + 0x1C) = NULL;
		*(INT*)((BYTE*)this + 0x20) = 0;
		*(INT*)((BYTE*)this + 0x24) = 0;
	}
}

IMPL_MATCH("Engine.dll", 0x10327790)
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

IMPL_MATCH("Engine.dll", 0x10318e10)
void FMipmap::Clear()
{
	// Ghidra 0x18e10, ~40B. Zeroes all bytes in DataArray (at +0x1C).
	BYTE* Data = *(BYTE**)((BYTE*)this + 0x1C);
	INT   Num  = *(INT*) ((BYTE*)this + 0x20);
	if (Data && Num > 0)
		appMemzero(Data, Num);
}


// --- FMipmapBase ---
IMPL_MATCH("Engine.dll", 0x10304260)
FMipmapBase::FMipmapBase(BYTE InUBits, BYTE InVBits)
{
	// Ghidra 0x4260, 49B.
	*(DWORD*)((BYTE*)this + 0x00) = 0;
	*(BYTE*) ((BYTE*)this + 0x0C) = InUBits;
	*(INT*)  ((BYTE*)this + 0x04) = 1 << (InUBits & 0x1F);
	*(BYTE*) ((BYTE*)this + 0x0D) = InVBits;
	*(INT*)  ((BYTE*)this + 0x08) = 1 << (InVBits & 0x1F);
}

IMPL_MATCH("Engine.dll", 0x10503248)
FMipmapBase::FMipmapBase()
{
	// Ghidra 0x203248: merged entry — body is empty (zero-initialisation from callsite).
	appMemzero((BYTE*)this, sizeof(_Data));
}

IMPL_MATCH("Engine.dll", 0x10304570)
FMipmapBase& FMipmapBase::operator=(const FMipmapBase& Other)
{
	// Ghidra 0x4570: copies 4 DWORDs (16 bytes = sizeof FMipmapBase).
	appMemcpy( this, &Other, sizeof(FMipmapBase) );
	return *this;
}


// --- UBitmapMaterial ---


IMPL_MATCH("Engine.dll", 0x10303f80)
UBitmapMaterial * UBitmapMaterial::Get(double,UViewport *)
{
	return this;
}


// --- UCombiner ---








// --- UConstantColor ---
IMPL_MATCH("Engine.dll", 0x1030a090)
FColor UConstantColor::GetColor(float)
{
	return Color;
}


// --- UConstantMaterial ---
IMPL_MATCH("Engine.dll", 0x10309db0)
FColor UConstantMaterial::GetColor(float)
{
	return FColor(0,0,0,0);
}


// --- UCubemap ---
IMPL_MATCH("Engine.dll", 0x10468e20)
void UCubemap::Destroy()
{
	guard(UCubemap::Destroy);
	// Ghidra 0x168e20: free the render interface buffer at +0xF0 via GMalloc, then super.
	void** pBuf = (void**)((BYTE*)this + 0xF0);
	if (*pBuf)
	{
		GMalloc->Free(*pBuf);	// vtable[2] = Free
		*pBuf = NULL;
	}
	UTexture::Destroy();
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10468e10)
FBaseTexture * UCubemap::GetRenderInterface()
{
	// Retail: 8B 81 F0 00 00 00 C3 = return *(this+0xF0) — UCubemap's own render interface
	return *(FBaseTexture**)((BYTE*)this + 0xF0);
}


// --- UFadeColor ---
IMPL_DIVERGE("stub body (1 line(s)) — Ghidra 0x103c8d80 is 411 bytes; FColor/FPlane cosine-blend pipeline not yet reconstructed")
FColor UFadeColor::GetColor(float)
{
	// Ghidra 0xc8d80, 411B. Three-mode colour animation:
	//   Mode 0 (linear):  fmod((Time + phase) / period, 1.0) lerp between Color1 and Color2.
	//   Mode 1 (cosine):  appCos(t * PI/2) blend between Color1 (this+0x68) and Color2 (this+0x64).
	//   Default:          return Color2 (this+0x64).
	// Requires FColor::Plane() → FPlane and FPlane arithmetic not yet exposed in headers.
	// DIVERGENCE: returns black/transparent as safe fallback.
	return FColor(0,0,0,0);
}


// --- UFinalBlend ---






// --- UMaterialSwitch ---
IMPL_MATCH("Engine.dll", 0x103c8920)
void UMaterialSwitch::PostEditChange()
{
	guard(UMaterialSwitch::PostEditChange);
	// Ghidra 0xc8920: call parent, then sync CurrentMaterial from Materials[CurrentIndex].
	UModifier::PostEditChange();
	INT idx = *(INT*)((BYTE*)this + 0x5C); // CurrentIndex
	if (idx >= 0)
	{
		FArray* matArr = (FArray*)((BYTE*)this + 0x60); // Materials TArray
		if (idx < matArr->Num())
		{
			*(DWORD*)((BYTE*)this + 0x58) = // CurrentMaterial
				*(DWORD*)(*(INT*)matArr + idx * 4);
			return;
		}
	}
	*(DWORD*)((BYTE*)this + 0x58) = 0; // CurrentMaterial = NULL
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103c9020)
UBOOL UMaterialSwitch::CheckCircularReferences( TArray<UMaterial*>& History )
{
	guard(UMaterialSwitch::CheckCircularReferences);
	if( !UModifier::CheckCircularReferences( History ) )
		return 0;
	INT idx = History.AddItem( this );
	for( INT i = 0; i < Materials.Num(); i++ )
		if( Materials(i) && !Materials(i)->CheckCircularReferences( History ) )
			return 0;
	History.Remove( idx, 1 );
	return 1;
	unguard;
}


// --- UModifier ---








// --- UPalette ---
IMPL_DIVERGE("body incomplete — Ghidra 0x1046AEA0: uses FUN_10318850 ECX-based GObjObjects iterator; not standard-callable")
UPalette * UPalette::ReplaceWithExisting()
{
	// Retail 0x16aea0, 297B with SEH. Iterates all loaded UObjects via
	// FUN_10318850 (GObjObjects iterator), finds a UPalette with the same outer
	// and identical 256-entry color data, logs the match and returns it.
	// Falls through to return 'this' if no duplicate found.
	// DIVERGENCE: FUN_10318850 uses non-standard ECX calling convention —
	// returns this unchanged as "no duplicate found" safe fallback.
	return this;
}


IMPL_MATCH("Engine.dll", 0x10469890)
BYTE UPalette::BestMatch(FColor InColor, int StartIdx)
{
	guard(UPalette::BestMatch);
	// Retail: 0x169890, ~70b. Returns the palette index (>= StartIdx) with the
	// smallest weighted color distance to InColor.
	// FColor memory layout: [B=byte0, G=byte1, R=byte2, A=byte3] (BGRA).
	// Distance metric: dB^2 + (dR^2 + dG^2*2) * 4  (G weighted x8, R x4, B x1).
	DWORD cB = InColor.B;
	DWORD cG = InColor.G;
	DWORD cR = InColor.R;
	INT  bestDist  = 0x7FFFFFFF;
	INT  pruneDist = 0x7FFFFFFF; // fast-prune: skip entry if dG^2 >= last bestDist/8
	INT  bestIdx   = StartIdx;
	INT  curIdx    = StartIdx;
	if (StartIdx < 0x100)
	{
		BYTE* pal = (BYTE*)(*(INT*)((BYTE*)this + 0x2C)) + StartIdx * 4; // Colors.Data
		do
		{
			INT dG  = (INT)(DWORD)pal[1] - (INT)cG;
			INT dG2 = dG * dG;
			if (dG2 < pruneDist)
			{
				INT dR   = (INT)(DWORD)pal[2] - (INT)cR;
				INT dB   = (INT)(DWORD)pal[0] - (INT)cB;
				INT dist = dB * dB + (dR * dR + dG2 * 2) * 4;
				if (dist < bestDist)
				{
					bestIdx   = curIdx;
					pruneDist = (dist + 7) >> 3;
					bestDist  = dist;
				}
			}
			curIdx++;
			pal += 4;
		} while (curIdx < 0x100);
		return (BYTE)bestIdx;
	}
	return (BYTE)bestIdx;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10469770)
void UPalette::FixPalette()
{
	guard(UPalette::FixPalette);
	// Ghidra 0x169770: remap a 256-entry BGRA palette to a specific Quake-style
	// layout; set alpha channel indices from entry number + base offset.
	DWORD* colData = *(DWORD**)((BYTE*)this + 0x2C); // Colors.Data
	DWORD  tmp[0x100];
	// Fill temp array with first colour entry
	DWORD fill = colData[0];
	for (INT i = 0; i < 0x100; i += 4)
	{
		tmp[i] = fill; tmp[i+1] = fill; tmp[i+2] = fill; tmp[i+3] = fill;
	}
	// Per Ghidra: for each of 8 rows, copy colour pairs into strided positions in tmp
	for (INT row = 0; row < 8; row++)
	{
		INT iVar6 = (row == 0) ? 1 : (row << 5);
		DWORD* puVar5 = colData + 2 + iVar6; // colData[2+iVar6]
		DWORD* puVar7 = colData + 1 + iVar6; // colData[1+iVar6]
		DWORD* puVar4 = tmp + row + 0x18;
		for (INT j = 7; j != 0; j--)
		{
			puVar4[-8]  = puVar5[-2];
			*puVar4     = *puVar7;
			puVar4[8]   = *puVar5;
			puVar4[0x10]= puVar5[1];
			puVar7 += 4;
			puVar5 += 4;
			puVar4 += 0x20;
		}
	}
	// Write back with alpha channel set to entry-index-based value
	for (INT i = 0; i < 0x100; i += 4)
	{
		colData[i]   = tmp[i];
		((BYTE*)colData)[i * 4 + 3]   = (BYTE)i + 0x10;
		colData[i+1] = tmp[i+1];
		((BYTE*)colData)[(i+1) * 4 + 3] = (BYTE)i + 0x11;
		colData[i+2] = tmp[i+2];
		((BYTE*)colData)[(i+2) * 4 + 3] = (BYTE)i + 0x12;
		colData[i+3] = tmp[i+3];
		((BYTE*)colData)[(i+3) * 4 + 3] = (BYTE)i + 0x13;
	}
	((BYTE*)colData)[3] = 0; // first entry alpha = 0
	unguard;
}


// --- UProxyBitmapMaterial ---
IMPL_MATCH("Engine.dll", 0x10303f00)
void UProxyBitmapMaterial::SetTextureInterface(FBaseTexture * Interface)
{
	// Ghidra 0x3f00, 101B. Store Interface then query its vtable for
	// Format, UBits, VBits, USize, VSize; compute log2 of dimensions.
	// FBaseTexture vtable offsets (all __thiscall on the Interface object):
	//   +0x1c → USize() → DWORD
	//   +0x20 → VSize() → DWORD
	//   +0x2c → GetFormat() → BYTE (ETextureFormat)
	//   +0x30 → GetUBits() → BYTE
	//   +0x34 → GetVBits() → BYTE
	typedef BYTE  (__thiscall *ByteGetFn)(FBaseTexture*);
	typedef DWORD (__thiscall *DWordGetFn)(FBaseTexture*);

	*(FBaseTexture**)((BYTE*)this + 0x70) = Interface;

	void** vtbl = *(void***)Interface;
	*(BYTE*)((BYTE*)this + 0x58) = ((ByteGetFn)vtbl[0x2c/4])(Interface);   // Format

	FBaseTexture* iface = *(FBaseTexture**)((BYTE*)this + 0x70);
	vtbl = *(void***)iface;
	*(BYTE*)((BYTE*)this + 0x59) = ((ByteGetFn)vtbl[0x30/4])(iface);       // UBits
	*(BYTE*)((BYTE*)this + 0x5a) = ((ByteGetFn)vtbl[0x34/4])(iface);       // VBits

	DWORD uSize = ((DWordGetFn)vtbl[0x1c/4])(iface);
	*(DWORD*)((BYTE*)this + 0x60) = uSize;   // USize
	*(DWORD*)((BYTE*)this + 0x68) = uSize;   // UClamp

	DWORD vSize = ((DWordGetFn)vtbl[0x20/4])(iface);
	*(DWORD*)((BYTE*)this + 0x64) = vSize;   // VSize
	*(DWORD*)((BYTE*)this + 0x6c) = vSize;   // VClamp

	*(BYTE*)((BYTE*)this + 0x5b) = (BYTE)appCeilLogTwo(*(DWORD*)((BYTE*)this + 0x68)); // UBits_log2
	*(BYTE*)((BYTE*)this + 0x5c) = (BYTE)appCeilLogTwo(*(DWORD*)((BYTE*)this + 0x6c)); // VBits_log2
}

IMPL_MATCH("Engine.dll", 0x10303f80)
UBitmapMaterial * UProxyBitmapMaterial::Get(double,UViewport *)
{
	// Ghidra 0x3f80 shared entry: ?Get@UBitmapMaterial and ?Get@UProxyBitmapMaterial
	// both resolve to this 5-byte stub that just returns this.
	return (UBitmapMaterial*)this;
}

IMPL_MATCH("Engine.dll", 0x10303f70)
FBaseTexture * UProxyBitmapMaterial::GetRenderInterface()
{
	return TextureInterface;
}


// --- UShader ---




// --- UShadowBitmapMaterial ---
IMPL_MATCH("Engine.dll", 0x1042e3f0)
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

IMPL_DIVERGE("body incomplete — Ghidra 0x1042E6E0 not yet fully reconstructed")
UBitmapMaterial * UShadowBitmapMaterial::Get(double,UViewport *)
{
	// Retail: 0x12e3e0, 2594b. Shadow map rendering pipeline — too complex to decompile.
	// TODO: implement UShadowBitmapMaterial::Get (retail 0x12e3e0, 2594 bytes: shadow map rendering pipeline)
	return NULL;
}

IMPL_MATCH("Engine.dll", 0x1042e360)
FBaseTexture * UShadowBitmapMaterial::GetRenderInterface()
{
	// Retail: 8B 81 9C 00 00 00 C3 = return *(this+0x9C) — render interface pointer in shadow bitmap
	return *(FBaseTexture**)((BYTE*)this + 0x9C);
}


// --- UTexCoordMaterial ---
IMPL_MATCH("Engine.dll", 0x1030a480)
INT UTexCoordMaterial::MaterialUSize()
{
	// Ghidra 0xa480: if Material != NULL, tail-call Material->MaterialUSize() via vtable+0x70; else return 0.
	return Material ? Material->MaterialUSize() : 0;
}

IMPL_MATCH("Engine.dll", 0x1030a4a0)
INT UTexCoordMaterial::MaterialVSize()
{
	// Ghidra 0xa4a0: if Material != NULL, tail-call Material->MaterialVSize() via vtable+0x74; else return 0.
	return Material ? Material->MaterialVSize() : 0;
}


// --- UTexCoordSource ---
IMPL_MATCH("Engine.dll", 0x103c88f0)
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
IMPL_MATCH("Engine.dll", 0x103c8380)
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
IMPL_MATCH("Engine.dll", 0x1030ad20)
FMatrix * UTexMatrix::GetMatrix(float)
{
	// Ghidra 0xad20: returns (FMatrix*)(this + 100) = &Matrix.
	return &Matrix;
}


// --- UTexModifier ---
IMPL_MATCH("Engine.dll", 0x103c8480)
void UTexModifier::SetValidated(int x)
{
	// Ghidra 0xc8480: if Material != NULL, tail-call Material->SetValidated(x) via vtable+0x6c.
	if (Material)
		Material->SetValidated(x);
}

IMPL_MATCH("Engine.dll", 0x103c7db0)
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

IMPL_MATCH("Engine.dll", 0x103c7d70)
int UTexModifier::MaterialUSize()
{
	// Retail: 17b. Delegates to Material->MaterialUSize(); returns 0 if null.
	if (!Material) return 0;
	return Material->MaterialUSize();
}

IMPL_MATCH("Engine.dll", 0x103c7d90)
int UTexModifier::MaterialVSize()
{
	// Retail: 17b. Delegates to Material->MaterialVSize(); returns 0 if null.
	if (!Material) return 0;
	return Material->MaterialVSize();
}

IMPL_MATCH("Engine.dll", 0x10304720)
FMatrix * UTexModifier::GetMatrix(float)
{
	guard(UTexModifier::GetMatrix);
	// Retail: 0x4720 shared null-stub. Base UTexModifier returns NULL; subclasses override.
	return NULL;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103c7e10)
int UTexModifier::GetValidated()
{
	// Ghidra 0xc7e10: if Material != NULL, tail-call Material->GetValidated() via vtable+0x68; else return 1.
	if (Material)
		return Material->GetValidated();
	return 1;
}


// --- UTexOscillator ---
IMPL_MATCH("Engine.dll", 0x10304720)
FMatrix * UTexOscillator::GetMatrix(float)
{
	// No guard/unguard — retail is a bare null stub; compiler deduplicates 4 identical copies
	return NULL;
}


// --- UTexPanner ---
IMPL_MATCH("Engine.dll", 0x10304720)
FMatrix * UTexPanner::GetMatrix(float)
{
	return NULL;
}


// --- UTexRotator ---
IMPL_MATCH("Engine.dll", 0x1030b3a0)
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

IMPL_MATCH("Engine.dll", 0x10304720)
FMatrix * UTexRotator::GetMatrix(float)
{
	return NULL;
}


// --- UTexScaler ---
IMPL_MATCH("Engine.dll", 0x10304720)
FMatrix * UTexScaler::GetMatrix(float)
{
	return NULL;
}

