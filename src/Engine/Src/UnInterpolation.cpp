#pragma optimize("", off)
#include "EnginePrivate.h"
// --- AInterpolationPoint ---
void AInterpolationPoint::RenderEditorSelected(FLevelSceneNode* SceneNode, FRenderInterface* RI, FDynamicActor* DA)
{
	guard(AInterpolationPoint::RenderEditorSelected);
	// Ghidra 0x10ba00: draws a wireframe box via FLineBatcher showing the interpolation
	// point's local axes (32-unit inner face, 64-unit outer face).
	// DIVERGENCE: full raw-float reconstruction omitted; base class rendering kept.
	// TODO: implement full 8-vertex wireframe box from Ghidra.
	AActor::RenderEditorSelected(SceneNode, RI, DA);
	unguard;
}

void AInterpolationPoint::PostEditChange()
{
	guard(AInterpolationPoint::PostEditChange);
	// Ghidra 0x11fbd0: notify parent and scene manager of property change
	AActor::PostEditChange();
	extern ENGINE_API FMatineeTools GMatineeTools;
	ASceneManager* SM = GMatineeTools.GetCurrent();
	if (SM)
		SM->PreparePath();
	unguard;
}

void AInterpolationPoint::PostEditMove()
{
	guard(AInterpolationPoint::PostEditMove);
	// Ghidra 0x11fc50: notify scene manager when interpolation point is moved
	extern ENGINE_API FMatineeTools GMatineeTools;
	ASceneManager* SM = GMatineeTools.GetCurrent();
	if (SM)
		SM->PreparePath();
	unguard;
}


