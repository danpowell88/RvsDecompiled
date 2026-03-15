/*=============================================================================
	UnMaterial.cpp: UMaterial, UTexture, UShader, UModifier hierarchy.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.
	Reconstructed for Ravenshield decompilation project.

	Provides IMPLEMENT_CLASS() registrations and decompiled method
	bodies for the material/texture class hierarchy. The material
	system is how Unreal Engine manages surface rendering — textures,
	shaders, combiners, modifiers and constant colours all derive from
	UMaterial and override virtual methods for rendering.

	This file is permanent and will grow as more material code is
	decompiled.
=============================================================================*/

#include "EnginePrivate.h"

/*-----------------------------------------------------------------------------
	Class registration.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(UMaterial);
IMPLEMENT_CLASS(URenderedMaterial);
IMPLEMENT_CLASS(UBitmapMaterial);
IMPLEMENT_CLASS(UTexture);
IMPLEMENT_CLASS(UShader);
IMPLEMENT_CLASS(UModifier);
IMPLEMENT_CLASS(UCombiner);
IMPLEMENT_CLASS(UFinalBlend);
IMPLEMENT_CLASS(UConstantMaterial);
IMPLEMENT_CLASS(UConstantColor);
IMPLEMENT_CLASS(UPalette);
IMPLEMENT_CLASS(UTexCoordMaterial);
IMPLEMENT_CLASS(UTexMatrix);
IMPLEMENT_CLASS(UTexOscillator);
IMPLEMENT_CLASS(UTexPanner);
IMPLEMENT_CLASS(UTexRotator);
IMPLEMENT_CLASS(UTexScaler);
IMPLEMENT_CLASS(UTexEnvMap);
IMPLEMENT_CLASS(UColorModifier);
IMPLEMENT_CLASS(UOpacityModifier);
IMPLEMENT_CLASS(UVertexColor);
IMPLEMENT_CLASS(UProceduralTexture);
IMPLEMENT_CLASS(UScriptedTexture);
IMPLEMENT_CLASS(UCubemap);
IMPLEMENT_CLASS(UPlayerLight);

/*=============================================================================
	UMaterial implementation.
=============================================================================*/

IMPL_MATCH("Engine.dll", 0x103c78b0)
void UMaterial::Serialize( FArchive& Ar )
{
	guard(UMaterial::Serialize);
	UObject::Serialize( Ar );
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103c8a60)
UBOOL UMaterial::CheckCircularReferences( TArray<UMaterial*>& History )
{
	guard(UMaterial::CheckCircularReferences);
	// If we are already in the traversal history this is a cycle.
	for( INT i = 0; i < History.Num(); i++ )
		if( History(i) == this )
			return 0;
	if( !FallbackMaterial )
		return 1;
	INT idx = History.AddItem( this );
	if( !FallbackMaterial->CheckCircularReferences( History ) )
		return 0;
	History.Remove( idx, 1 );
	return 1;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10303970)
INT UMaterial::GetValidated()
{
	guard(UMaterial::GetValidated);
	// Retail Engine.dll 0x3970: returns bit 1 (Validated) of the bitfield DWORD at this+0x34.
	return Validated;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10303980)
void UMaterial::SetValidated( UBOOL InValidated )
{
	guard(UMaterial::SetValidated);
	// Retail Engine.dll 0x3980: sets or clears the Validated bit at this+0x34.
	Validated = InValidated ? 1 : 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10414310)
UBOOL UMaterial::IsTransparent()
{
	guard(UMaterial::IsTransparent);
	// Retail: 0x114310 shared null-stub (xor eax,eax; ret). Base returns 0; subclasses override.
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10414310)
INT UMaterial::MaterialUSize()
{
	guard(UMaterial::MaterialUSize);
	// Retail: 0x114310 shared null-stub. Base returns 0; subclasses override.
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10414310)
INT UMaterial::MaterialVSize()
{
	guard(UMaterial::MaterialVSize);
	// Retail: 0x114310 shared null-stub. Base returns 0; subclasses override.
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10414310)
UBOOL UMaterial::RequiresSorting()
{
	// Retail: 33 C0 C3 — direct return 0, does NOT call IsTransparent().
	return 0;
}

IMPL_MATCH("Engine.dll", 0x103039a0)
BYTE UMaterial::RequiredUVStreams()
{
	return 1;
}

IMPL_MATCH("Engine.dll", 0x103c78d0)
UMaterial* UMaterial::CheckFallback()
{
	guard(UMaterial::CheckFallback);
	// Ghidra 0xc78d0: if FallbackMaterial set and bit 0 of flags byte at 0x34 is set,
	// chain to FallbackMaterial->CheckFallback() via vtable[0x21].
	if (FallbackMaterial != NULL && (*(BYTE*)((BYTE*)this + 0x34) & 1) != 0)
		return FallbackMaterial->CheckFallback();
	return this;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103039b0)
UBOOL UMaterial::HasFallback()
{
	// Retail: 8B 51 2C 33 C0 85 D2 0F 95 C0 C3 = return FallbackMaterial != NULL
	return FallbackMaterial != NULL;
}

IMPL_MATCH("Engine.dll", 0x10301a90)
UMaterial* UMaterial::GetDiffuse()
{
	return this;
}

/*=============================================================================
	UBitmapMaterial implementation.
=============================================================================*/

IMPL_MATCH("Engine.dll", 0x10303d20)
INT UBitmapMaterial::MaterialUSize()
{
	return USize;
}

IMPL_MATCH("Engine.dll", 0x10303d30)
INT UBitmapMaterial::MaterialVSize()
{
	return VSize;
}

/*=============================================================================
	UTexture implementation.
=============================================================================*/

IMPL_MATCH("Engine.dll", 0x1046b790)
void UTexture::PostLoad()
{
	guard(UTexture::PostLoad);
	UObject::PostLoad();
	if( Palette == NULL )
	{
		UPalette* Pal = (UPalette*)UObject::StaticConstructObject(
			UPalette::StaticClass(), GetOuter(), NAME_None, 0, NULL, GError, 0 );
		Palette = Pal;
		for( INT i=0; i<256; i++ )
		{
			INT idx = Palette->Colors.Add();
			Palette->Colors(idx) = FColor(i,i,i,0);
		}
	}
	UClamp = Clamp( UClamp, 0, USize );
	VClamp = Clamp( VClamp, 0, VSize );
	Accumulator = 0.f;
	SetLastUpdateTime( appSeconds().GetFloat() + 16777216.0 );
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10467b90)
void UTexture::Destroy()
{
	guard(UTexture::Destroy);
	GMalloc->Free( (void*)RenderInterface );
	RenderInterface = 0;
	UObject::Destroy();
	unguard;
}

IMPL_DIVERGE("FUN_1046b600 (mip-array serializer) and FUN_1046ace0 (per-mip-element serializer) are unexported Engine.dll internals; mip-level TArray serialization permanently omitted")
void UTexture::Serialize( FArchive& Ar )
{
	guard(UTexture::Serialize);
	UBitmapMaterial::Serialize( Ar );
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103044c0)
UBOOL UTexture::RequiresSorting()
{
	// Retail: F6 41 34 04 74 03 33 C0 C3 8B 81 94 00 00 00 D1 E8 83 E0 01 C3
	// Check ForceNoSort flag; if clear, return bAlphaTexture (bit 1 of bitfield at 0x94).
	if (m_bForceNoSort) return 0;
	return bAlphaTexture ? 1 : 0;
}

IMPL_MATCH("Engine.dll", 0x103044e0)
UBOOL UTexture::IsTransparent()
{
	return bAlphaTexture || bMasked;
}

/*=============================================================================
	UShader implementation.
=============================================================================*/

IMPL_MATCH("Engine.dll", 0x103c7a80)
void UShader::PostEditChange()
{
	guard(UShader::PostEditChange);
	UObject::PostEditChange();
	UObject* outer = this;
	while( outer->GetOuter() != NULL )
		outer = outer->GetOuter();
	if( outer->IsA( UPackage::StaticClass() ) )
		*(DWORD*)((BYTE*)outer + 0x38) = 1;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103c8b40)
UBOOL UShader::CheckCircularReferences( TArray<UMaterial*>& History )
{
	guard(UShader::CheckCircularReferences);
	if( !UMaterial::CheckCircularReferences( History ) )
		return 0;
	INT idx = History.AddItem( this );
	if( Diffuse              && !Diffuse->CheckCircularReferences( History ) )              return 0;
	if( Opacity              && !Opacity->CheckCircularReferences( History ) )              return 0;
	if( Specular             && !Specular->CheckCircularReferences( History ) )             return 0;
	if( SpecularityMask      && !SpecularityMask->CheckCircularReferences( History ) )      return 0;
	if( SelfIllumination     && !SelfIllumination->CheckCircularReferences( History ) )     return 0;
	if( SelfIlluminationMask && !SelfIlluminationMask->CheckCircularReferences( History ) ) return 0;
	if( Detail               && !Detail->CheckCircularReferences( History ) )               return 0;
	History.Remove( idx, 1 );
	return 1;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103c7a40)
INT UShader::MaterialUSize()
{
	// Retail: try Diffuse first, then SelfIllumination (at 0x70), else 0
	if (Diffuse)
		return Diffuse->MaterialUSize();
	if (SelfIllumination)
		return SelfIllumination->MaterialUSize();
	return 0;
}

IMPL_MATCH("Engine.dll", 0x103c7a60)
INT UShader::MaterialVSize()
{
	// Retail: try Diffuse first, then SelfIllumination (at 0x70), else 0
	if (Diffuse)
		return Diffuse->MaterialVSize();
	if (SelfIllumination)
		return SelfIllumination->MaterialVSize();
	return 0;
}

IMPL_MATCH("Engine.dll", 0x103c7a00)
UBOOL UShader::RequiresSorting()
{
	// Retail: F6 41 34 04 75 1E 8A 41 58 84 C0 75 07 8B 51 64 85 D2 75 13
	//         3C 02 74 0F 3C 05 74 0B 3C 06 74 07 3C 03 74 03 33 C0 C3 B8 01...
	// ForceNoSort flag → return 0 immediately.
	if (m_bForceNoSort) return 0;
	// OB_Normal: sort only if there is an Opacity channel.
	if (OutputBlending == OB_Normal)
		return (Opacity != NULL);
	// OB_Modulate, OB_Translucent, OB_Brighten, OB_Darken require sorting.
	return (OutputBlending == OB_Modulate || OutputBlending == OB_Translucent ||
	        OutputBlending == OB_Brighten  || OutputBlending == OB_Darken);
}

IMPL_MATCH("Engine.dll", 0x103c7a30)
UBOOL UShader::IsTransparent()
{
	// Retail: 8B 01 FF 60 78 — tail-call JMP vtable[30] = RequiresSorting.
	return RequiresSorting();
}

IMPL_MATCH("Engine.dll", 0x103c7960)
BYTE UShader::RequiredUVStreams()
{
	// Retail: aggregates all 7 material slots with OR.
	// Diffuse is special: its result replaces the default, but UV0 is always forced.
	// All other slots OR their streams into the accumulator.
	BYTE result = 1;
	if (Diffuse)
	{
		result = Diffuse->RequiredUVStreams();
		result |= 1; // Shader always needs at least UV stream 0
	}
	if (Opacity)           result |= Opacity->RequiredUVStreams();
	if (Specular)          result |= Specular->RequiredUVStreams();
	if (SpecularityMask)   result |= SpecularityMask->RequiredUVStreams();
	if (SelfIllumination)  result |= SelfIllumination->RequiredUVStreams();
	if (SelfIlluminationMask) result |= SelfIlluminationMask->RequiredUVStreams();
	if (Detail)            result |= Detail->RequiredUVStreams();
	return result;
}

IMPL_MATCH("Engine.dll", 0x103c7b50)
UMaterial* UShader::CheckFallback()
{
	guard(UShader::CheckFallback);
	// Ghidra 0xc7b50: if HasFallback bit set (byte 0x34 & 1),
	// try FallbackMaterial then Diffuse (via vtable[0x21] = CheckFallback).
	if (*(BYTE*)((BYTE*)this + 0x34) & 1)
	{
		if (FallbackMaterial != NULL)
			return FallbackMaterial->CheckFallback();
		if (Diffuse != NULL)
			return Diffuse->CheckFallback();
		return NULL;
	}
	return this;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103c7b30)
UBOOL UShader::HasFallback()
{
	return (FallbackMaterial != NULL) || (Diffuse != NULL);
}

IMPL_MATCH("Engine.dll", 0x10303d20)
UMaterial* UShader::GetDiffuse()
{
	return Diffuse;
}

/*=============================================================================
	UModifier implementation.
=============================================================================*/

IMPL_MATCH("Engine.dll", 0x103c7cc0)
void UModifier::PostEditChange()
{
	guard(UModifier::PostEditChange);
	UObject::PostEditChange();
	UObject* outer = this;
	while( outer->GetOuter() != NULL )
		outer = outer->GetOuter();
	if( outer->IsA( UPackage::StaticClass() ) )
		*(DWORD*)((BYTE*)outer + 0x38) = 1;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103c8f50)
UBOOL UModifier::CheckCircularReferences( TArray<UMaterial*>& History )
{
	guard(UModifier::CheckCircularReferences);
	if( !UMaterial::CheckCircularReferences( History ) )
		return 0;
	INT idx = History.AddItem( this );
	if( Material && !Material->CheckCircularReferences( History ) )
		return 0;
	History.Remove( idx, 1 );
	return 1;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1030a480)
INT UModifier::MaterialUSize()
{
	return Material ? Material->MaterialUSize() : 0;
}

IMPL_MATCH("Engine.dll", 0x1030a4a0)
INT UModifier::MaterialVSize()
{
	return Material ? Material->MaterialVSize() : 0;
}

IMPL_MATCH("Engine.dll", 0x1030a440)
UBOOL UModifier::RequiresSorting()
{
	return Material ? Material->RequiresSorting() : 0;
}

IMPL_MATCH("Engine.dll", 0x1030a460)
UBOOL UModifier::IsTransparent()
{
	return Material ? Material->IsTransparent() : 0;
}

IMPL_MATCH("Engine.dll", 0x1030a420)
BYTE UModifier::RequiredUVStreams()
{
	return Material ? Material->RequiredUVStreams() : 1;
}

/*=============================================================================
	UCombiner implementation.
=============================================================================*/

IMPL_MATCH("Engine.dll", 0x103c7c10)
void UCombiner::PostEditChange()
{
	guard(UCombiner::PostEditChange);
	UObject::PostEditChange();
	UObject* outer = this;
	while( outer->GetOuter() != NULL )
		outer = outer->GetOuter();
	if( outer->IsA( UPackage::StaticClass() ) )
		*(DWORD*)((BYTE*)outer + 0x38) = 1;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103c8c90)
UBOOL UCombiner::CheckCircularReferences( TArray<UMaterial*>& History )
{
	guard(UCombiner::CheckCircularReferences);
	if( !UMaterial::CheckCircularReferences( History ) )
		return 0;
	INT idx = History.AddItem( this );
	if( Material1 && !Material1->CheckCircularReferences( History ) ) return 0;
	if( Material2 && !Material2->CheckCircularReferences( History ) ) return 0;
	if( Mask      && !Mask->CheckCircularReferences( History ) )      return 0;
	History.Remove( idx, 1 );
	return 1;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1031aa70)
INT UCombiner::MaterialUSize()
{
	// Retail: max(Material2->MaterialUSize(), Material1->MaterialUSize())
	INT usize2 = Material2 ? Material2->MaterialUSize() : 0;
	INT usize1 = Material1 ? Material1->MaterialUSize() : 0;
	return usize2 > usize1 ? usize2 : usize1;
}

IMPL_MATCH("Engine.dll", 0x1031aab0)
INT UCombiner::MaterialVSize()
{
	// Retail: max(Material2->MaterialVSize(), Material1->MaterialVSize())
	INT vsize2 = Material2 ? Material2->MaterialVSize() : 0;
	INT vsize1 = Material1 ? Material1->MaterialVSize() : 0;
	return vsize2 > vsize1 ? vsize2 : vsize1;
}

IMPL_MATCH("Engine.dll", 0x10414310)
UBOOL UCombiner::IsTransparent()
{
	guard(UCombiner::IsTransparent);
	// Ghidra 0x114310: shared zero-return vtable stub.
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10414310)
UBOOL UCombiner::RequiresSorting()
{
	// Retail: 33 C0 C3 — direct return 0, does NOT call IsTransparent().
	return 0;
}

IMPL_MATCH("Engine.dll", 0x1030bd70)
BYTE UCombiner::RequiredUVStreams()
{
	// Retail (80b RVA=0xBD70): OR together Material1 and Material2 stream requirements.
	// Both Material1 and Material2 null default to 1 (MOV EDI/EAX, 1 at both null paths).
	BYTE m1 = Material1 ? Material1->RequiredUVStreams() : 1;
	BYTE m2 = Material2 ? Material2->RequiredUVStreams() : 1;
	return m1 | m2;
}

/*=============================================================================
	UFinalBlend implementation.
=============================================================================*/

IMPL_MATCH("Engine.dll", 0x103c83d0)
void UFinalBlend::PostEditChange()
{
	guard(UFinalBlend::PostEditChange);
	UModifier::PostEditChange();
	UObject* outer = this;
	while( outer->GetOuter() != NULL )
		outer = outer->GetOuter();
	if( outer->IsA( UPackage::StaticClass() ) )
		*(DWORD*)((BYTE*)outer + 0x38) = 1;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103c7e10)
INT UFinalBlend::GetValidated()
{
	// Retail: delegate to Material->GetValidated() if present, else return 1.
	// Pattern matches UTexModifier::GetValidated.
	return Material ? Material->GetValidated() : 1;
}

IMPL_MATCH("Engine.dll", 0x103c8480)
void UFinalBlend::SetValidated( UBOOL InValidated )
{
	// Retail: delegate to Material->SetValidated() if present.
	// Pattern matches UTexModifier::SetValidated.
	if (Material)
		Material->SetValidated(InValidated);
}

IMPL_MATCH("Engine.dll", 0x103c83a0)
UBOOL UFinalBlend::RequiresSorting()
{
	// Retail: if m_bForceNoSort → return 0;
	// else: return FrameBufferBlending in range [FB_Modulate, FB_Brighten]
	if (m_bForceNoSort) return 0;
	BYTE fb = FrameBufferBlending;
	return (fb >= FB_Modulate && fb <= FB_Brighten) ? 1 : 0;
}

IMPL_MATCH("Engine.dll", 0x103c7a30)
UBOOL UFinalBlend::IsTransparent()
{
	// Retail: JMP vtable[30] = tail-call to RequiresSorting()
	return RequiresSorting();
}

/*=============================================================================
	UPalette implementation.
=============================================================================*/

IMPL_MATCH("Engine.dll", 0x1046adf0)
void UPalette::Serialize( FArchive& Ar )
{
	guard(UPalette::Serialize);
	UObject::Serialize( Ar );
	Ar << Colors;
	if( Ar.Ver() < 0x42 )
		for( INT i=0; i<Colors.Num(); i++ )
			Colors(i).A = 0xFF;
	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/

// =============================================================================
// UMaterial (moved from EngineClassImpl.cpp)
// =============================================================================

// UMaterial
// ---------------------------------------------------------------------------
IMPL_DIVERGE("UMaterial does not override PostEditChange in retail; vtable slot resolves to UObject::PostEditChange")
void UMaterial::PostEditChange()
{
	Super::PostEditChange();
}

// ---------------------------------------------------------------------------
