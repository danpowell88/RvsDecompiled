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
	return 1;
	unguard;
}

void UMaterial::SetValidated( UBOOL InValidated )
{
	guard(UMaterial::SetValidated);
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
	return 0;
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
	return 0; // TODO: return USize;
}

INT UBitmapMaterial::MaterialVSize()
{
	return 0; // TODO: return VSize;
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
	return 0; // TODO: return bAlphaTexture || bMasked;
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
	return 0; // TODO: return Diffuse ? Diffuse->MaterialUSize() : 0;
}

INT UShader::MaterialVSize()
{
	return 0; // TODO: return Diffuse ? Diffuse->MaterialVSize() : 0;
}

UBOOL UShader::RequiresSorting()
{
	return IsTransparent();
}

UBOOL UShader::IsTransparent()
{
	return 0; // TODO: return Opacity != NULL;
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
	return 0;
}

UMaterial* UShader::GetDiffuse()
{
	return NULL; // TODO: return Diffuse;
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
	return 0; // TODO: return Material ? Material->CheckCircularReferences( History ) : 0;
	unguard;
}

INT UModifier::MaterialUSize()
{
	return 0; // TODO: return Material ? Material->MaterialUSize() : 0;
}

INT UModifier::MaterialVSize()
{
	return 0; // TODO: return Material ? Material->MaterialVSize() : 0;
}

UBOOL UModifier::RequiresSorting()
{
	return 0; // TODO: return Material ? Material->RequiresSorting() : 0;
}

UBOOL UModifier::IsTransparent()
{
	return 0; // TODO: return Material ? Material->IsTransparent() : 0;
}

BYTE UModifier::RequiredUVStreams()
{
	return 1; // TODO: return Material ? Material->RequiredUVStreams() : 1;
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
	return 0; // TODO: return Material1 ? Material1->MaterialUSize() : 0;
}

INT UCombiner::MaterialVSize()
{
	return 0; // TODO: return Material1 ? Material1->MaterialVSize() : 0;
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
	return 1;
}

void UFinalBlend::SetValidated( UBOOL InValidated )
{
}

UBOOL UFinalBlend::RequiresSorting()
{
	return IsTransparent();
}

UBOOL UFinalBlend::IsTransparent()
{
	return 0; // TODO: return FrameBufferBlending != FB_Overwrite;
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
