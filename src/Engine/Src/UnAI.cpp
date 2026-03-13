#pragma optimize("", off)
#include "EnginePrivate.h"
// --- AAIController ---
void AAIController::SetAdjustLocation(FVector NewLoc)
{
	bAdjusting = 1;
	AdjustLoc = NewLoc;
}

int AAIController::AcceptNearbyPath(AActor* Goal)
{
	if( Goal && Goal->IsA(ANavigationPoint::StaticClass()) )
		return 1;
	return 0;
}

void AAIController::AdjustFromWall(FVector,AActor *)
{
}


// --- AAIMarker ---
int AAIMarker::IsIdentifiedAs(FName)
{
	return 0;
}


// --- AAIScript ---
void AAIScript::AddMyMarker(AActor *)
{
}


