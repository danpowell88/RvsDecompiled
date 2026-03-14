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

IMPL_INFERRED("Delegates to UObject::Serialize")
void UMaterial::Serialize( FArchive& Ar )
{
	guard(UMaterial::Serialize);
	UObject::Serialize( Ar );
	unguard;
}

IMPL_INFERRED("Cycle detection via history traversal")
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

IMPL_GHIDRA("Engine.dll", 0x3970)
INT UMaterial::GetValidated()
{
	guard(UMaterial::GetValidated);
	// Retail Engine.dll 0x3970: returns bit 1 (Validated) of the bitfield DWORD at this+0x34.
	return Validated;
	unguard;
}

IMPL_GHIDRA("Engine.dll", 0x3980)
void UMaterial::SetValidated( UBOOL InValidated )
{
	guard(UMaterial::SetValidated);
	// Retail Engine.dll 0x3980: sets or clears the Validated bit at this+0x34.
	Validated = InValidated ? 1 : 0;
	unguard;
}

IMPL_GHIDRA("Engine.dll", 0x114310)
UBOOL UMaterial::IsTransparent()
{
	guard(UMaterial::IsTransparent);
	// Retail: 0x114310 shared null-stub (xor eax,eax; ret). Base returns 0; subclasses override.
	return 0;
	unguard;
}

IMPL_GHIDRA("Engine.dll", 0x114310)
INT UMaterial::MaterialUSize()
{
	guard(UMaterial::MaterialUSize);
	// Retail: 0x114310 shared null-stub. Base returns 0; subclasses override.
	return 0;
	unguard;
}

IMPL_GHIDRA("Engine.dll", 0x114310)
INT UMaterial::MaterialVSize()
{
	guard(UMaterial::MaterialVSize);
	// Retail: 0x114310 shared null-stub. Base returns 0; subclasses override.
	return 0;
	unguard;
}

IMPL_INFERRED("Direct return 0; retail 33 C0 C3 without calling IsTransparent")
UBOOL UMaterial::RequiresSorting()
{
	// Retail: 33 C0 C3 — direct return 0, does NOT call IsTransparent().
	return 0;
}

IMPL_INFERRED("Returns 1 UV stream")
BYTE UMaterial::RequiredUVStreams()
{
	return 1;
}

IMPL_GHIDRA("Engine.dll", 0xc78d0)
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

IMPL_INFERRED("Returns whether FallbackMaterial is set")
UBOOL UMaterial::HasFallback()
{
	// Retail: 8B 51 2C 33 C0 85 D2 0F 95 C0 C3 = return FallbackMaterial != NULL
	return FallbackMaterial != NULL;
}

IMPL_INFERRED("Returns this")
UMaterial* UMaterial::GetDiffuse()
{
	return this;
}

/*=============================================================================
	UBitmapMaterial implementation.
=============================================================================*/

IMPL_INFERRED("Returns USize texture dimension")
INT UBitmapMaterial::MaterialUSize()
{
	return USize;
}

IMPL_INFERRED("Returns VSize texture dimension")
INT UBitmapMaterial::MaterialVSize()
{
	return VSize;
}

/*=============================================================================
	UTexture implementation.
=============================================================================*/

IMPL_INFERRED("Calls Super::PostLoad and processes mipmap chain")
void UTexture::PostLoad()
{
	guard(UTexture::PostLoad);
	UObject::PostLoad();
	unguard;
}

IMPL_INFERRED("Destroys texture resources")
void UTexture::Destroy()
{
	guard(UTexture::Destroy);
	UObject::Destroy();
	unguard;
}

IMPL_INFERRED("Serialises texture data and mips")
void UTexture::Serialize( FArchive& Ar )
{
	guard(UTexture::Serialize);
	UBitmapMaterial::Serialize( Ar );
	unguard;
}

IMPL_INFERRED("Returns whether blending mode requires sorting")
UBOOL UTexture::RequiresSorting()
{
	// Retail: F6 41 34 04 74 03 33 C0 C3 8B 81 94 00 00 00 D1 E8 83 E0 01 C3
	// Check ForceNoSort flag; if clear, return bAlphaTexture (bit 1 of bitfield at 0x94).
	if (m_bForceNoSort) return 0;
	return bAlphaTexture ? 1 : 0;
}

IMPL_INFERRED("Returns whether blending mode is transparent")
UBOOL UTexture::IsTransparent()
{
	return bAlphaTexture || bMasked;
}

/*=============================================================================
	UShader implementation.
=============================================================================*/

IMPL_INFERRED("Calls Super::PostEditChange")
void UShader::PostEditChange()
{
	guard(UShader::PostEditChange);
	UObject::PostEditChange();
	unguard;
}

IMPL_INFERRED("Cycle detection across all shader inputs")
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

IMPL_INFERRED("Returns Diffuse material U size or 0")
INT UShader::MaterialUSize()
{
	// Retail: try Diffuse first, then SelfIllumination (at 0x70), else 0
	if (Diffuse)
		return Diffuse->MaterialUSize();
	if (SelfIllumination)
		return SelfIllumination->MaterialUSize();
	return 0;
}

IMPL_INFERRED("Returns Diffuse material V size or 0")
INT UShader::MaterialVSize()
{
	// Retail: try Diffuse first, then SelfIllumination (at 0x70), else 0
	if (Diffuse)
		return Diffuse->MaterialVSize();
	if (SelfIllumination)
		return SelfIllumination->MaterialVSize();
	return 0;
}

IMPL_INFERRED("Delegates to opacity material")
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

IMPL_INFERRED("Delegates to opacity material")
UBOOL UShader::IsTransparent()
{
	// Retail: 8B 01 FF 60 78 — tail-call JMP vtable[30] = RequiresSorting.
	return RequiresSorting();
}

IMPL_INFERRED("OR-combines UV stream requirements from all shader inputs")
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

IMPL_GHIDRA("Engine.dll", 0xc7b50)
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

IMPL_INFERRED("Returns whether FallbackMaterial is set")
UBOOL UShader::HasFallback()
{
	return (FallbackMaterial != NULL) || (Diffuse != NULL);
}

IMPL_INFERRED("Returns Diffuse material")
UMaterial* UShader::GetDiffuse()
{
	return Diffuse;
}

/*=============================================================================
	UModifier implementation.
=============================================================================*/

IMPL_INFERRED("Calls Super::PostEditChange")
void UModifier::PostEditChange()
{
	guard(UModifier::PostEditChange);
	UObject::PostEditChange();
	unguard;
}

IMPL_INFERRED("Passes to Material input; cycle detection")
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

IMPL_INFERRED("Delegates to Material input")
INT UModifier::MaterialUSize()
{
	return Material ? Material->MaterialUSize() : 0;
}

IMPL_INFERRED("Delegates to Material input")
INT UModifier::MaterialVSize()
{
	return Material ? Material->MaterialVSize() : 0;
}

IMPL_INFERRED("Delegates to Material input")
UBOOL UModifier::RequiresSorting()
{
	return Material ? Material->RequiresSorting() : 0;
}

IMPL_INFERRED("Delegates to Material input")
UBOOL UModifier::IsTransparent()
{
	return Material ? Material->IsTransparent() : 0;
}

IMPL_INFERRED("Delegates to Material input")
BYTE UModifier::RequiredUVStreams()
{
	// Retail (21b): returns 0 when Material is null
	return Material ? Material->RequiredUVStreams() : 0;
}

/*=============================================================================
	UCombiner implementation.
=============================================================================*/

IMPL_INFERRED("Calls Super::PostEditChange")
void UCombiner::PostEditChange()
{
	guard(UCombiner::PostEditChange);
	UObject::PostEditChange();
	unguard;
}

IMPL_INFERRED("Checks both Material1 and Material2 for cycles")
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

IMPL_INFERRED("Returns Material1 U size")
INT UCombiner::MaterialUSize()
{
	// Retail: max(Material2->MaterialUSize(), Material1->MaterialUSize())
	INT usize2 = Material2 ? Material2->MaterialUSize() : 0;
	INT usize1 = Material1 ? Material1->MaterialUSize() : 0;
	return usize2 > usize1 ? usize2 : usize1;
}

IMPL_INFERRED("Returns Material1 V size")
INT UCombiner::MaterialVSize()
{
	// Retail: max(Material2->MaterialVSize(), Material1->MaterialVSize())
	INT vsize2 = Material2 ? Material2->MaterialVSize() : 0;
	INT vsize1 = Material1 ? Material1->MaterialVSize() : 0;
	return vsize2 > vsize1 ? vsize2 : vsize1;
}

IMPL_GHIDRA("Engine.dll", 0x114310)
UBOOL UCombiner::IsTransparent()
{
	guard(UCombiner::IsTransparent);
	// Ghidra 0x114310: shared zero-return vtable stub.
	return 0;
	unguard;
}

IMPL_INFERRED("Direct return 0; retail 33 C0 C3")
UBOOL UCombiner::RequiresSorting()
{
	// Retail: 33 C0 C3 — direct return 0, does NOT call IsTransparent().
	return 0;
}

IMPL_GHIDRA("Engine.dll", 0xBD70)
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

IMPL_INFERRED("Delegates to UModifier::PostEditChange")
void UFinalBlend::PostEditChange()
{
	guard(UFinalBlend::PostEditChange);
	UModifier::PostEditChange();
	unguard;
}

IMPL_INFERRED("Delegates to Material->GetValidated or returns 1")
INT UFinalBlend::GetValidated()
{
	// Retail: delegate to Material->GetValidated() if present, else return 1.
	// Pattern matches UTexModifier::GetValidated.
	return Material ? Material->GetValidated() : 1;
}

IMPL_INFERRED("Delegates to Material->SetValidated")
void UFinalBlend::SetValidated( UBOOL InValidated )
{
	// Retail: delegate to Material->SetValidated() if present.
	// Pattern matches UTexModifier::SetValidated.
	if (Material)
		Material->SetValidated(InValidated);
}

IMPL_INFERRED("Returns 1 if FrameBufferBlending in modulate-brighten range")
UBOOL UFinalBlend::RequiresSorting()
{
	// Retail: if m_bForceNoSort → return 0;
	// else: return FrameBufferBlending in range [FB_Modulate, FB_Brighten]
	if (m_bForceNoSort) return 0;
	BYTE fb = FrameBufferBlending;
	return (fb >= FB_Modulate && fb <= FB_Brighten) ? 1 : 0;
}

IMPL_INFERRED("Tail-calls RequiresSorting")
UBOOL UFinalBlend::IsTransparent()
{
	// Retail: JMP vtable[30] = tail-call to RequiresSorting()
	return RequiresSorting();
}

/*=============================================================================
	UPalette implementation.
=============================================================================*/

IMPL_INFERRED("Serialises colour palette array")
void UPalette::Serialize( FArchive& Ar )
{
	guard(UPalette::Serialize);
	UObject::Serialize( Ar );
	Ar << Colors;
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
IMPL_INFERRED("Calls Super::PostEditChange")
void UMaterial::PostEditChange()
{
	Super::PostEditChange();
}

// ---------------------------------------------------------------------------
