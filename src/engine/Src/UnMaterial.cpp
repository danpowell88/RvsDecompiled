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

void UMaterial::Serialize( FArchive& Ar )
{
	guard(UMaterial::Serialize);
	UObject::Serialize( Ar );
	unguard;
}

UBOOL UMaterial::CheckCircularReferences( TArray<UMaterial*>& History )
{
	guard(UMaterial::CheckCircularReferences);
	return 0;
	unguard;
}

INT UMaterial::GetValidated()
{
	guard(UMaterial::GetValidated);
	// Retail Engine.dll 0x3970: returns bit 1 (Validated) of the bitfield DWORD at this+0x34.
	return Validated;
	unguard;
}

void UMaterial::SetValidated( UBOOL InValidated )
{
	guard(UMaterial::SetValidated);
	// Retail Engine.dll 0x3980: sets or clears the Validated bit at this+0x34.
	Validated = InValidated ? 1 : 0;
	unguard;
}

UBOOL UMaterial::IsTransparent()
{
	return 0;
}

INT UMaterial::MaterialUSize()
{
	return 0;
}

INT UMaterial::MaterialVSize()
{
	return 0;
}

UBOOL UMaterial::RequiresSorting()
{
	return IsTransparent();
}

BYTE UMaterial::RequiredUVStreams()
{
	return 1;
}

UMaterial* UMaterial::CheckFallback()
{
	return NULL;
}

UBOOL UMaterial::HasFallback()
{
	// Retail: 8B 51 2C 33 C0 85 D2 0F 95 C0 C3 = return FallbackMaterial != NULL
	return FallbackMaterial != NULL;
}

UMaterial* UMaterial::GetDiffuse()
{
	return this;
}

/*=============================================================================
	UBitmapMaterial implementation.
=============================================================================*/

INT UBitmapMaterial::MaterialUSize()
{
	return USize;
}

INT UBitmapMaterial::MaterialVSize()
{
	return VSize;
}

/*=============================================================================
	UTexture implementation.
=============================================================================*/

void UTexture::PostLoad()
{
	guard(UTexture::PostLoad);
	UObject::PostLoad();
	unguard;
}

void UTexture::Destroy()
{
	guard(UTexture::Destroy);
	UObject::Destroy();
	unguard;
}

void UTexture::Serialize( FArchive& Ar )
{
	guard(UTexture::Serialize);
	UBitmapMaterial::Serialize( Ar );
	unguard;
}

UBOOL UTexture::RequiresSorting()
{
	return UBitmapMaterial::RequiresSorting();
}

UBOOL UTexture::IsTransparent()
{
	return bAlphaTexture || bMasked;
}

/*=============================================================================
	UShader implementation.
=============================================================================*/

void UShader::PostEditChange()
{
	guard(UShader::PostEditChange);
	UObject::PostEditChange();
	unguard;
}

UBOOL UShader::CheckCircularReferences( TArray<UMaterial*>& History )
{
	guard(UShader::CheckCircularReferences);
	return 0;
	unguard;
}

INT UShader::MaterialUSize()
{
	return Diffuse ? Diffuse->MaterialUSize() : 0;
}

INT UShader::MaterialVSize()
{
	return Diffuse ? Diffuse->MaterialVSize() : 0;
}

UBOOL UShader::RequiresSorting()
{
	return IsTransparent();
}

UBOOL UShader::IsTransparent()
{
	return Opacity != NULL;
}

BYTE UShader::RequiredUVStreams()
{
	return 1;
}

UMaterial* UShader::CheckFallback()
{
	return NULL;
}

UBOOL UShader::HasFallback()
{
	return (FallbackMaterial != NULL) || (Diffuse != NULL);
}

UMaterial* UShader::GetDiffuse()
{
	return Diffuse;
}

/*=============================================================================
	UModifier implementation.
=============================================================================*/

void UModifier::PostEditChange()
{
	guard(UModifier::PostEditChange);
	UObject::PostEditChange();
	unguard;
}

UBOOL UModifier::CheckCircularReferences( TArray<UMaterial*>& History )
{
	guard(UModifier::CheckCircularReferences);
	return Material ? Material->CheckCircularReferences( History ) : 0;
	unguard;
}

INT UModifier::MaterialUSize()
{
	return Material ? Material->MaterialUSize() : 0;
}

INT UModifier::MaterialVSize()
{
	return Material ? Material->MaterialVSize() : 0;
}

UBOOL UModifier::RequiresSorting()
{
	return Material ? Material->RequiresSorting() : 0;
}

UBOOL UModifier::IsTransparent()
{
	return Material ? Material->IsTransparent() : 0;
}

BYTE UModifier::RequiredUVStreams()
{
	return Material ? Material->RequiredUVStreams() : 1;
}

/*=============================================================================
	UCombiner implementation.
=============================================================================*/

void UCombiner::PostEditChange()
{
	guard(UCombiner::PostEditChange);
	UObject::PostEditChange();
	unguard;
}

UBOOL UCombiner::CheckCircularReferences( TArray<UMaterial*>& History )
{
	guard(UCombiner::CheckCircularReferences);
	return 0;
	unguard;
}

INT UCombiner::MaterialUSize()
{
	// Retail: max(Material2->MaterialUSize(), Material1->MaterialUSize())
	INT usize2 = Material2 ? Material2->MaterialUSize() : 0;
	INT usize1 = Material1 ? Material1->MaterialUSize() : 0;
	return usize2 > usize1 ? usize2 : usize1;
}

INT UCombiner::MaterialVSize()
{
	// Retail: max(Material2->MaterialVSize(), Material1->MaterialVSize())
	INT vsize2 = Material2 ? Material2->MaterialVSize() : 0;
	INT vsize1 = Material1 ? Material1->MaterialVSize() : 0;
	return vsize2 > vsize1 ? vsize2 : vsize1;
}

UBOOL UCombiner::IsTransparent()
{
	return 0;
}

UBOOL UCombiner::RequiresSorting()
{
	return IsTransparent();
}

BYTE UCombiner::RequiredUVStreams()
{
	return 2;
}

/*=============================================================================
	UFinalBlend implementation.
=============================================================================*/

void UFinalBlend::PostEditChange()
{
	guard(UFinalBlend::PostEditChange);
	UModifier::PostEditChange();
	unguard;
}

INT UFinalBlend::GetValidated()
{
	// Retail: delegate to Material->GetValidated() if present, else return 1.
	// Pattern matches UTexModifier::GetValidated.
	return Material ? Material->GetValidated() : 1;
}

void UFinalBlend::SetValidated( UBOOL InValidated )
{
	// Retail: delegate to Material->SetValidated() if present.
	// Pattern matches UTexModifier::SetValidated.
	if (Material)
		Material->SetValidated(InValidated);
}

UBOOL UFinalBlend::RequiresSorting()
{
	// Retail: if m_bForceNoSort → return 0;
	// else: return FrameBufferBlending in range [FB_Modulate, FB_Brighten]
	if (m_bForceNoSort) return 0;
	BYTE fb = FrameBufferBlending;
	return (fb >= FB_Modulate && fb <= FB_Brighten) ? 1 : 0;
}

UBOOL UFinalBlend::IsTransparent()
{
	// Retail: JMP vtable[30] = tail-call to RequiresSorting()
	return RequiresSorting();
}

/*=============================================================================
	UPalette implementation.
=============================================================================*/

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
