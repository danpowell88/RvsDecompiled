/*=============================================================================
	R6TeamMemberReplicationInfo.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

IMPLEMENT_CLASS(AR6TeamMemberReplicationInfo)

// --- AR6TeamMemberReplicationInfo ---

IMPL_APPROX("Returns relevance only for friendly pawns; checks viewer pawn then falls back to view target")
INT AR6TeamMemberReplicationInfo::IsNetRelevantFor(APlayerController* Viewer, AActor*, FVector)
{
	guard(AR6TeamMemberReplicationInfo::IsNetRelevantFor);

	// Check viewer's pawn directly
	APawn* ViewPawn = Viewer->Pawn;
	if (ViewPawn != NULL)
		return IsRelevantToTeamMember(ViewPawn);

	// Fallback: check cached view target in APlayerController hidden native data
	// APlayerController+0x5B8 holds a ViewTarget actor pointer
	AActor* ViewTarget = *(AActor**)((BYTE*)Viewer + 0x5B8);
	if (ViewTarget != NULL)
	{
		// Original calls vtable[0x68/4] which returns APawn* (GetPlayerPawn)
		ViewPawn = ViewTarget->GetPlayerPawn();
		if (ViewPawn != NULL)
			return IsRelevantToTeamMember(ViewPawn);
	}

	return 0;

	unguard;
}

IMPL_APPROX("Returns 1 if Other pawn has a controller and is a friend of this actor's instigator")
INT AR6TeamMemberReplicationInfo::IsRelevantToTeamMember(APawn* Other)
{
	guard(AR6TeamMemberReplicationInfo::IsRelevantToTeamMember);
	if (Other && Other->Controller)
		return Instigator->IsFriend(Other) ? 1 : 0;
	return 0;
	unguard;
}

IMPL_APPROX("Chains to AActor::TickSpecial with no additional logic")
void AR6TeamMemberReplicationInfo::TickSpecial(FLOAT DeltaTime)
{
	AActor::TickSpecial(DeltaTime);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
