#!/usr/bin/env python3
"""Insert IMPL_xxx macros before function definitions in UnPawn.cpp."""

import sys

path = r'C:\Users\danpo\Desktop\rvs\src\Engine\Src\UnPawn.cpp'

with open(path, 'r', encoding='utf-8-sig') as f:
    lines = f.readlines()

# Each entry: (stripped_line_prefix, macro_text)
insertions = [
    # APawn exec
    ('void APawn::execReachedDestination(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void APawn::execIsFriend(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void APawn::execIsEnemy(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void APawn::execIsNeutral(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void APawn::execIsAlive(', 'IMPL_INFERRED("reconstructed exec function")'),
    # AController exec
    ('void AController::execMoveTo(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void AController::execPollMoveTo(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void AController::execMoveToward(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void AController::execPollMoveToward(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void AController::execFinishRotation(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void AController::execPollFinishRotation(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void AController::execWaitForLanding(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void AController::execPollWaitForLanding(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void AController::execLineOfSightTo(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void AController::execCanSee(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void AController::execFindPathToward(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void AController::execFindPathTowardNearest(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void AController::execFindPathTo(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void AController::execactorReachable(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void AController::execpointReachable(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void AController::execClearPaths(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void AController::execEAdjustJump(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void AController::execFindRandomDest(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void AController::execPickWallAdjust(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void AController::execAddController(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void AController::execRemoveController(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void AController::execPickTarget(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void AController::execPickAnyTarget(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void AController::execFindBestInventoryPath(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void AController::execEndClimbLadder(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void AController::execInLatentExecution(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void AController::execStopWaiting(', 'IMPL_INFERRED("reconstructed exec function")'),
    # APlayerController exec
    ('void APlayerController::execFindStairRotation(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void APlayerController::execResetKeyboard(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void APlayerController::execUpdateURL(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void APlayerController::execConsoleCommand(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void APlayerController::execGetDefaultURL(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void APlayerController::execGetEntryLevel(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void APlayerController::execSetViewTarget(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void APlayerController::execClientTravel(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void APlayerController::execClientHearSound(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void APlayerController::execGetPlayerNetworkAddress(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void APlayerController::execCopyToClipboard(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void APlayerController::execPasteFromClipboard(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void APlayerController::execSpecialDestroy(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void APlayerController::execPB_CanPlayerSpawn(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void APlayerController::execGetPBConnectStatus(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void APlayerController::execIsPBEnabled(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void APlayerController::execGetKey(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void APlayerController::execGetActionKey(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void APlayerController::execGetEnumName(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void APlayerController::execChangeInputSet(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void APlayerController::execSetKey(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void APlayerController::execSetSoundOptions(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void APlayerController::execChangeVolumeTypeLinear(', 'IMPL_INFERRED("reconstructed exec function")'),
    # AAIController exec
    ('void AAIController::execWaitToSeeEnemy(', 'IMPL_INFERRED("reconstructed exec function")'),
    ('void AAIController::execPollWaitToSeeEnemy(', 'IMPL_INFERRED("reconstructed exec function")'),
    # APawn non-exec
    ('APawn* APawn::GetPawnOrColBoxOwner(', 'IMPL_INFERRED("no Ghidra address; trivial")'),
    ('APawn* APawn::GetPlayerPawn(', 'IMPL_INFERRED("Retail: mov eax,ecx; ret — no explicit address")'),
    ('INT APawn::PlayerControlled(', 'IMPL_INFERRED("no Ghidra address")'),
    ('INT APawn::IsAlive(', 'IMPL_INFERRED("no Ghidra address")'),
    ('INT APawn::IsCrouched(', 'IMPL_INFERRED("no Ghidra address")'),
    ('INT APawn::IsPlayer(', 'IMPL_INFERRED("no Ghidra address")'),
    ('INT APawn::IsHumanControlled(', 'IMPL_INFERRED("no Ghidra address")'),
    ('INT APawn::IsLocallyControlled(', 'IMPL_INFERRED("no Ghidra address")'),
    ('INT APawn::IsFriend( APawn*', 'IMPL_GHIDRA("Engine.dll", 0xE5350)'),
    ('INT APawn::IsFriend( INT', 'IMPL_GHIDRA("Engine.dll", 0xE5370)'),
    ('INT APawn::IsEnemy(', 'IMPL_GHIDRA("Engine.dll", 0xE5420)'),
    ('INT APawn::IsNeutral(', 'IMPL_GHIDRA("Engine.dll", 0xE54D0)'),
    ('FLOAT APawn::GetMaxSpeed(', 'IMPL_INFERRED("no Ghidra address")'),
    ('INT APawn::CheckOwnerUpdated(', 'IMPL_GHIDRA("Engine.dll", 0xC34E0)'),
    ('void APawn::SetPrePivot(', 'IMPL_INFERRED("no Ghidra address")'),
    ('void APawn::CheckForErrors(', 'IMPL_INFERRED("no Ghidra address")'),
    ('FVector APawn::CheckForLedges(', 'IMPL_INFERRED("no Ghidra address; returns delta unchanged as stub")'),
    ('void APawn::Destroy(', 'IMPL_INFERRED("no Ghidra address")'),
    ('FRotator APawn::FindSlopeRotation(', 'IMPL_INFERRED("no Ghidra address")'),
    ('FLOAT APawn::GetNetPriority(', 'IMPL_INFERRED("no Ghidra address")'),
    ('INT* APawn::GetOptimizedRepList(', 'IMPL_INFERRED("no Ghidra address")'),
    ('INT APawn::HurtByVolume(', 'IMPL_INFERRED("DIVERGENCE: APhysicsVolume raw offset access; no explicit address")'),
    ('INT APawn::IsBlockedBy(', 'IMPL_GHIDRA("Engine.dll", 0x79000)'),
    ('INT APawn::IsNetRelevantFor(', 'IMPL_INFERRED("no Ghidra address")'),
    ('void APawn::NotifyAnimEnd(', 'IMPL_INFERRED("no Ghidra address")'),
    ('void APawn::NotifyBump(', 'IMPL_INFERRED("no Ghidra address")'),
    ('void APawn::PostBeginPlay(', 'IMPL_INFERRED("no Ghidra address")'),
    ('void APawn::PostNetReceive(', 'IMPL_INFERRED("no Ghidra address")'),
    ('void APawn::PostNetReceiveLocation(', 'IMPL_INFERRED("no Ghidra address")'),
    ('void APawn::PreNetReceive(', 'IMPL_INFERRED("no Ghidra address")'),
    ('DWORD APawn::R6LineOfSightTo(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('DWORD APawn::R6SeePawn(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('INT APawn::Reachable(', 'IMPL_INFERRED("DIVERGENCE: APhysicsVolume raw offset; approximated reachability check")'),
    ('INT APawn::ReachedDestination(', 'IMPL_INFERRED("no Ghidra address; cylinder radius check")'),
    ('void APawn::RenderEditorSelected(', 'IMPL_INFERRED("no Ghidra address")'),
    ('void APawn::SetBase(', 'IMPL_INFERRED("no Ghidra address")'),
    ('void APawn::SetZone(', 'IMPL_INFERRED("no Ghidra address")'),
    ('INT APawn::ShouldTrace(', 'IMPL_INFERRED("no Ghidra address")'),
    ('void APawn::SmoothHitWall(', 'IMPL_INFERRED("no Ghidra address")'),
    ('void APawn::TickSimulated(', 'IMPL_INFERRED("no Ghidra address")'),
    ('void APawn::TickSpecial(', 'IMPL_INFERRED("no Ghidra address")'),
    ('void APawn::UpdateMovementAnimation(', 'IMPL_TODO("Needs Ghidra analysis; animation blend tree not yet reconstructed")'),
    ('INT APawn::actorReachable(', 'IMPL_INFERRED("no Ghidra address; approximated with line-of-sight trace")'),
    ('void APawn::calcVelocity(', 'IMPL_GHIDRA("Engine.dll", 0xee4b0)'),
    ('INT APawn::moveToward(', 'IMPL_GHIDRA("Engine.dll", 0xe7650)'),
    ('void APawn::performPhysics(', 'IMPL_GHIDRA("Engine.dll", 0xf5350)'),
    ('void APawn::physFalling(', 'IMPL_GHIDRA("Engine.dll", 0xf6410)'),
    ('void APawn::physLadder(', 'IMPL_GHIDRA("Engine.dll", 0xf4810)'),
    ('void APawn::physicsRotation(', 'IMPL_GHIDRA("Engine.dll", 0xf1920)'),
    ('void APawn::processHitWall(', 'IMPL_INFERRED("no Ghidra address")'),
    ('void APawn::processLanded(', 'IMPL_INFERRED("no Ghidra address")'),
    ('void APawn::stepUp(', 'IMPL_INFERRED("DIVERGENCE: delegates to AActor::stepUp without pawn-specific adjustments")'),
    ('INT APawn::CacheNetRelevancy(', 'IMPL_INFERRED("no Ghidra address")'),
    ('INT APawn::CanCrouchWalk(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('INT APawn::CanProneWalk(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('void APawn::ClearSerpentine(', 'IMPL_GHIDRA("Engine.dll", 0xE5260)'),
    ('void APawn::Crouch(', 'IMPL_GHIDRA_APPROX("Engine.dll", 0xE5DE0, "DIVERGENCE: net-channel sync via ctrl vtable omitted")'),
    ('ETestMoveResult APawn::FindBestJump(', 'IMPL_INFERRED("DIVERGENCE: simplified IsWarpZone check; no explicit address")'),
    ('ETestMoveResult APawn::FindJumpUp(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('FVector APawn::NewFallVelocity(', 'IMPL_GHIDRA("Engine.dll", 0xf2090)'),
    ('INT APawn::Pick3DWallAdjust(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('INT APawn::PickWallAdjust(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('void APawn::SpiderstepUp(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('void APawn::StartNewSerpentine(', 'IMPL_GHIDRA_APPROX("Engine.dll", 0xe5b60, "DIVERGENCE: null guard added for safety")'),
    ('FVector APawn::SuggestJumpVelocity(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('FLOAT APawn::Swim(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('void APawn::UnCrouch(', 'IMPL_GHIDRA_APPROX("Engine.dll", 0xE5F90, "DIVERGENCE: collision revert check via ctrl vtable omitted")'),
    ('INT APawn::ValidAnchor(', 'IMPL_GHIDRA("Engine.dll", 0x11C1D0)'),
    ('void APawn::ZeroMovementAlpha(', 'IMPL_INFERRED("DIVERGENCE: vtable[0x100] on USkeletalMeshInstance not mapped; no explicit address")'),
    ('ANavigationPoint* APawn::breadthPathTo(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('INT APawn::calcMoveFlags(', 'IMPL_INFERRED("no Ghidra address")'),
    ('INT APawn::checkFloor(', 'IMPL_INFERRED("no Ghidra address")'),
    ('void APawn::clearPath(', 'IMPL_INFERRED("no Ghidra address")'),
    ('void APawn::clearPaths(', 'IMPL_GHIDRA("Engine.dll", 0x11C170)'),
    ('INT APawn::findNewFloor(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('FLOAT APawn::findPathToward(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('FVector APawn::findWaterLine(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('ETestMoveResult APawn::flyMove(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('INT APawn::flyReachable(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('ETestMoveResult APawn::jumpLanding(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('INT APawn::jumpReachable(', 'IMPL_INFERRED("no Ghidra address; uses jumpLanding + walkReachable")'),
    ('INT APawn::ladderReachable(', 'IMPL_INFERRED("DIVERGENCE: ALadder field raw offset access; no explicit address")'),
    ('void APawn::physFlying(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('void APawn::physSpider(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('void APawn::physSwimming(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('void APawn::physWalking(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('INT APawn::pointReachable(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('void APawn::rotateToward(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('void APawn::setMoveTimer(', 'IMPL_INFERRED("DIVERGENCE: bIsCrouched/bIsWalking via named bitfields; no explicit address")'),
    ('void APawn::startNewPhysics(', 'IMPL_INFERRED("no Ghidra address; dispatch switch")'),
    ('void APawn::startSwimming(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('ETestMoveResult APawn::swimMove(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('INT APawn::swimReachable(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('ETestMoveResult APawn::walkMove(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('INT APawn::walkReachable(', 'IMPL_TODO("Needs Ghidra analysis")'),
    # AController virtual
    ('INT* AController::GetOptimizedRepList(', 'IMPL_INFERRED("no Ghidra address")'),
    ('AActor* AController::GetTeamManager(', 'IMPL_GHIDRA("Engine.dll", 0x114310)'),
    ('INT AController::LocalPlayerController(', 'IMPL_GHIDRA("Engine.dll", 0x114310)'),
    ('INT AController::Tick(', 'IMPL_INFERRED("no Ghidra address")'),
    ('void AController::AdjustFromWall(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('void AController::StartAnimPoll(', 'IMPL_GHIDRA("Engine.dll", 0x1209E0)'),
    ('INT AController::CheckAnimFinished(', 'IMPL_INFERRED("no Ghidra address; stub returns 1")'),
    ('INT AController::AcceptNearbyPath(', 'IMPL_GHIDRA("Engine.dll", 0x4720)'),
    ('INT AController::CanHear(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('void AController::CheckHearSound(', 'IMPL_GHIDRA_APPROX("Engine.dll", 0x12cc70, "DIVERGENCE: Pawn->Location passed as listener location")'),
    ('AActor* AController::GetViewTarget(', 'IMPL_INFERRED("no Ghidra address")'),
    ('void AController::SetAdjustLocation(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('void AController::ShowSelf(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('DWORD AController::SeePawn(', 'IMPL_INFERRED("no Ghidra address")'),
    ('AActor* AController::SetPath(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('void AController::SetRouteCache(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('DWORD AController::LineOfSightTo(', 'IMPL_INFERRED("no Ghidra address")'),
    ('INT AController::CanHearSound(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('void AController::CheckEnemyVisible(', 'IMPL_INFERRED("no Ghidra address")'),
    ('AActor* AController::FindPath(', 'IMPL_TODO("Needs Ghidra analysis")'),
    ('AActor* AController::HandleSpecial(', 'IMPL_INFERRED("no Ghidra address; pass-through")'),
]

output_lines = []
matched = set()

for line in lines:
    stripped = line.rstrip('\r\n').strip()
    inserted = False
    for prefix, macro in insertions:
        if stripped.startswith(prefix):
            output_lines.append(macro + '\n')
            matched.add(prefix)
            inserted = True
            break
    output_lines.append(line)

print(f'Original lines: {len(lines)}')
print(f'Output lines: {len(output_lines)}')
print(f'Matched/inserted: {len(matched)} of {len(insertions)}')

not_matched = [p for p, _ in insertions if p not in matched]
if not_matched:
    print(f'NOT MATCHED ({len(not_matched)}):')
    for nm in not_matched:
        print(f'  {nm!r}')
else:
    print('All patterns matched successfully!')

# Write output
with open(path, 'w', encoding='utf-8') as f:
    f.writelines(output_lines)

print('File written.')
