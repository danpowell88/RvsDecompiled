#include "EnginePrivate.h"
struct FPropertyRetirement;

static INT  s_prevViewTarget = 0;
static BYTE s_prevViewState  = 0;

// FUN_10370830 (59 bytes): check whether an object reference changed for replication.
// Returns TRUE when the property should be added to the rep list:
//   - If newObj is already mapped on this connection → FALSE (client already knows).
//   - If not mapped → mark channel dirty and return (newObj != NULL).
static UBOOL RepObjectChanged( INT newObj, INT /*oldObj*/, UPackageMap* Map, UActorChannel* Chan )
{
	DWORD* vtbl = *(DWORD**)Map;
	typedef INT (__thiscall* MapObjectFn)(UPackageMap*, INT);
	if ( ((MapObjectFn)vtbl[25])( Map, newObj ) != 0 )
		return 0;
	*(INT*)((BYTE*)Chan + 0x8c) = 1;
	return (newObj != 0);
}

// --- APlayerController ---
IMPL_MATCH("Engine.dll", 0x104201f0)
void APlayerController::SpecialDestroy()
{
	UObject* Player = *(UObject**)((BYTE*)this + 0x5b4);
	if (Player && Player->IsA(UNetConnection::StaticClass()))
	{
		INT driver = *(INT*)((BYTE*)Player + 0x7c);
		if (driver != 0)
			*(INT*)((BYTE*)Player + 0x80) = 1;
	}
}

IMPL_MATCH("Engine.dll", 0x103c3c80)
int APlayerController::Tick(float DeltaSeconds, ELevelTick TickType)
{
	guard(APlayerController::Tick);
	// Ghidra 0xc3c80 (~350 bytes): main controller tick — returns 1 on all paths.
	typedef void (__thiscall* VoidFn0)(APlayerController*);
	typedef void (__thiscall* VoidFnF)(APlayerController*, FLOAT);
	typedef void (__thiscall* VoidFnFT)(APlayerController*, FLOAT, ELevelTick);
	typedef int  (__thiscall* IntFn0)(APlayerController*);
	typedef int  (__thiscall* IntVFn)(void*);

	// Toggle bDeleteMe bit based on level pending-delete flag at level+0x100
	*(DWORD*)((BYTE*)this + 0x320) ^=
		(*(DWORD*)(*(INT*)((BYTE*)this + 0x328) + 0x100) ^ *(DWORD*)((BYTE*)this + 0x320)) & 1;

	// vtable[99] = per-tick reset (e.g. ClearButtons)
	(*(VoidFn0*)(*(INT*)this + 0x18c))(this);

	// Initialise movement cache on first tick
	if (!(*(DWORD*)((BYTE*)this + 0x524) & 0x400000))
	{
		*(INT*)((BYTE*)this + 0x53c) = 0;
		*(INT*)((BYTE*)this + 0x540) = 0;
		*(DWORD*)((BYTE*)this + 0x524) |= 0x400000;
	}

	// Fire script Tick event
	eventTick(DeltaSeconds);

	// Spectator mode (state byte at +0x2e == 3): copy camera if needed, then base tick
	if (((BYTE*)this)[0x2e] == 3)
	{
		// vtable[103] = IsLocalPlayerController
		if (!(*(IntFn0*)(*(INT*)this + 0x19c))(this))
		{
			INT* camPtr = *(INT**)((BYTE*)this + 0x5b8);
			INT* pawnPtr = *(INT**)((BYTE*)this + 0x3d8);
			if (camPtr != pawnPtr && camPtr != NULL)
			{
				// vtable[26] on camPtr — check if camera is moving/valid
				if (((IntVFn)(*(INT*)(*(INT*)camPtr + 0x68)))((void*)camPtr))
				{
					*(FLOAT*)((BYTE*)this + 0x628) = *(FLOAT*)((BYTE*)this + 0x240);
					*(FLOAT*)((BYTE*)this + 0x62c) = *(FLOAT*)((BYTE*)this + 0x244);
					*(FLOAT*)((BYTE*)this + 0x630) = *(FLOAT*)((BYTE*)this + 0x248);
				}
			}
		}
		// vtable[6] = AActor::Tick base
		(*(VoidFnFT*)(*(INT*)this + 0x18))(this, DeltaSeconds, TickType);
		// vtable[58] = TimerTick
		(*(VoidFnF*)(*(INT*)this + 0xe8))(this, DeltaSeconds);
		return 1;
	}

	if (((BYTE*)this)[0x2d] < 2)
	{
		(*(VoidFnFT*)(*(INT*)this + 0x18))(this, DeltaSeconds, TickType);
		(*(VoidFnF*)(*(INT*)this + 0xe8))(this, DeltaSeconds);
		return 1;
	}

	if (IsA(ACamera::StaticClass()))
	{
		if (!(*(DWORD*)((BYTE*)this + 0x4f8) & 0x800))
			return 1;
	}

	if (*(INT*)((BYTE*)this + 0x5b4)) // has viewport Player
	{
		if (!*(INT*)((BYTE*)this + 0x7d8)) // no input system yet
		{
			eventInitInputSystem();
			if (*(SBYTE*)(*(INT*)((BYTE*)this + 0x144) + 0x425))
				eventInitMultiPlayerOptions();
			if (!*(INT*)((BYTE*)this + 0x7d8))
				goto SKIP_INPUT;
		}
		// UPlayer::ProcessInput vtable[25]
		typedef void (__thiscall* ProcessInputFn)(void*, FLOAT);
		void* playerObj = *(void**)((BYTE*)this + 0x5b4);
		((ProcessInputFn)(*(INT*)(*(INT*)playerObj + 100)))(playerObj, DeltaSeconds);
		eventPlayerTick(DeltaSeconds);
		((ProcessInputFn)(*(INT*)(*(INT*)playerObj + 100)))(playerObj, -1.0f); // post-tick reset
	}
SKIP_INPUT:
	(*(VoidFnFT*)(*(INT*)this + 0x18))(this, DeltaSeconds, TickType);
	(*(VoidFnF*)(*(INT*)this + 0xe8))(this, DeltaSeconds);

	if (*(SBYTE*)((BYTE*)this + 0xa0) < 0)
		return 1;

	if (((BYTE*)this)[0x2c] != 0 && ((BYTE*)this)[0x2d] != 3)
		// vtable[72] = MoveSmooth
		(*(VoidFnF*)(*(INT*)this + 0x120))(this, DeltaSeconds);

	// NetDriver section
	INT level = *(INT*)((BYTE*)this + 0x328);
	INT netDriver = *(INT*)(level + 0x8c);
	if (netDriver && *(INT*)(netDriver + 0x3c))
	{
		if (((BYTE*)this)[0x2d] != 4)
			return 1;
		if (!(*(DWORD*)((BYTE*)this + 0x524) & 0x20))
		{
			INT* camPtr2 = *(INT**)((BYTE*)this + 0x5b8);
			if (camPtr2 != NULL)
			{
				if (((IntVFn)(*(INT*)(*(INT*)camPtr2 + 0x68)))((void*)camPtr2))
				{
					*(FLOAT*)((BYTE*)this + 0x628) = *(FLOAT*)((BYTE*)this + 0x240);
					*(FLOAT*)((BYTE*)this + 0x62c) = *(FLOAT*)((BYTE*)this + 0x244);
					*(FLOAT*)((BYTE*)this + 0x630) = *(FLOAT*)((BYTE*)this + 0x248);
				}
			}
		}
	}

	if (((BYTE*)this)[0x2d] == 4 && TickType == 2)
	{
		FLOAT& fadeTimer = *(FLOAT*)((BYTE*)this + 0x3ac);
		if (!(fadeTimer < 0.0f))
			fadeTimer += 0.2f;
		fadeTimer -= DeltaSeconds;
		INT pawn = *(INT*)((BYTE*)this + 0x3d8);
		if (pawn && !(*(BYTE*)(pawn + 0xa0) & 2))
			ShowSelf();
	}

	return 1;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10391550)
void APlayerController::R6PBKickPlayer(FString KickMsg)
{
	guard(APlayerController::R6PBKickPlayer);
	// Ghidra 0x91550: log the kicker's name, fire client event, then destroy
	GLog->Logf(TEXT("%s"), GetFullName());
	eventClientPBKickedOutMessage(KickMsg);
	SpecialDestroy();
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1037a5c0)
void APlayerController::SetPlayer(UPlayer* InPlayer)
{
	guard(APlayerController::SetPlayer);
	// Ghidra 0x7a5c0: bi-directional controller<->player link, init input if viewport.
	if (!InPlayer)
		appFailAssert("InPlayer!=NULL", ".\\UnActor.cpp", 0x760);

	// Clear old player's back-pointer to this controller
	APlayerController* oldActor = *(APlayerController**)((BYTE*)InPlayer + 0x34);
	if (oldActor)
		oldActor->Player = NULL;

	// Establish bidirectional link
	Player = InPlayer;
	*(APlayerController**)((BYTE*)InPlayer + 0x34) = this;

	// If InPlayer is a viewport, initialise input system
	if (InPlayer->IsA(UViewport::StaticClass()))
		eventInitInputSystem();

	// Log
	debugf(TEXT("%s"), GetFullName());
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1038d7d0)
int APlayerController::LocalPlayerController()
{
	guard(APlayerController::LocalPlayerController);
	UPlayer* PlayerRef = Player; // offset 0x5B4
	return PlayerRef && PlayerRef->IsA(UViewport::StaticClass());
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1037de60)
void APlayerController::PostNetReceive()
{
	guard(APlayerController::PostNetReceive);
	// Ghidra 0x7de60: update client if view target changed since PreNetReceive
	AActor::PostNetReceive();
	if ((*(DWORD*)((BYTE*)this + 0x524) & 0x4000) &&
		(s_prevViewTarget != *(INT*)((BYTE*)this + 0x5b8) ||
		 s_prevViewState  != *(BYTE*)((BYTE*)this + 0x4f7)))
	{
		eventClientSetNewViewTarget();
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103785d0)
void APlayerController::PreNetReceive()
{
	guard(APlayerController::PreNetReceive);
	// Ghidra 0x785d0: save view target state before net updates
	AActor::PreNetReceive();
	s_prevViewState  = *(BYTE*)((BYTE*)this + 0x4f7);
	s_prevViewTarget = *(INT*)((BYTE*)this + 0x5b8);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10427760)
void APlayerController::CheckHearSound(AActor* SoundMaker, INT SoundId, USound* Sound, FVector SoundLoc, FLOAT Volume, INT Flags)
{
	guardSlow(APlayerController::CheckHearSound);
	// Ghidra 0x127760: vtable[0x18c] pre-hook, then dispatch ClientHearSound event
	typedef void (__thiscall* tPreHook)(APlayerController*);
	((tPreHook*)((BYTE*)(*(void**)this) + 0x18c))[0](this);
	eventClientHearSound(SoundMaker, Sound, (BYTE)Volume);
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x10374b00)
INT* APlayerController::GetOptimizedRepList(BYTE* Mem, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Chan)
{
	guard(APlayerController::GetOptimizedRepList);
	// Ghidra 0x74b00 (1025 bytes): R6-extended replication list.
	// Calls parent, then conditionally adds up to 9 R6-specific property indices
	// based on bNetOwner, bNetDirty, Role==ROLE_Authority checks.
	// Static property caches (DAT_1066698c–DAT_106669a4) are function-local statics.
	static DWORD    s_InitFlags              = 0;
	static UObject* s_RadarActiveProp        = NULL;  // DAT_106669a0
	static UObject* s_ViewTargetProp         = NULL;  // DAT_1066699c
	static UObject* s_GameRepInfoProp        = NULL;  // DAT_10666998
	static UObject* s_OnlySpectatorProp      = NULL;  // DAT_10666994
	static UObject* s_TeamSelectionProp      = NULL;  // DAT_10666990
	static UObject* s_CameraModeProp         = NULL;  // DAT_1066698c
	static UObject* s_TargetViewRotProp      = NULL;  // DAT_10666988
	static UObject* s_TargetEyeHeightProp    = NULL;  // DAT_10666984
	static UObject* s_TargetWeaponViewProp   = NULL;  // DAT_10666980

	Ptr = AController::GetOptimizedRepList(Mem, Retire, Ptr, Map, Chan);

	// DAT_10661f94 = APlayerController::PrivateStaticClass.ClassFlags & 0x800 (CLASS_NativeReplication).
	// Always set for this class; gate assumed true per AMover/APhysicsVolume precedent.

	// --- m_bRadarActive: bNetOwner && Role==ROLE_Authority && byte 0x527 bit 0 changed ---
	if ((*(DWORD*)((BYTE*)this + 0xa0) & 0x40000000) &&
		((BYTE*)this)[0x2d] == 4 &&
		((Mem[0x527] ^ ((BYTE*)this)[0x527]) & 1))
	{
		if (!(s_InitFlags & 1)) { s_InitFlags |= 1; s_RadarActiveProp = UObject::StaticFindObjectChecked(UProperty::StaticClass(), StaticClass(), TEXT("m_bRadarActive"), 0); }
		*Ptr++ = (INT)(*(_WORD*)((BYTE*)s_RadarActiveProp + 0x4A));
	}

	// --- bNetDirty && Role==ROLE_Authority block ---
	if ((((BYTE*)this)[0xac] & 0x40) && ((BYTE*)this)[0x2d] == 4)
	{
		// Owner-only properties: bNetOwner gate
		if (*(DWORD*)((BYTE*)this + 0xa0) & 0x40000000)
		{
			// ViewTarget object ref
			if (RepObjectChanged(*(INT*)((BYTE*)this + 0x5b8), *(INT*)(Mem + 0x5b8), Map, Chan))
			{
				if (!(s_InitFlags & 2)) { s_InitFlags |= 2; s_ViewTargetProp = UObject::StaticFindObjectChecked(UProperty::StaticClass(), StaticClass(), TEXT("ViewTarget"), 0); }
				*Ptr++ = (INT)(*(_WORD*)((BYTE*)s_ViewTargetProp + 0x4A));
			}
			// GameReplicationInfo object ref
			if (RepObjectChanged(*(INT*)((BYTE*)this + 0x5cc), *(INT*)(Mem + 0x5cc), Map, Chan))
			{
				if (!(s_InitFlags & 4)) { s_InitFlags |= 4; s_GameRepInfoProp = UObject::StaticFindObjectChecked(UProperty::StaticClass(), StaticClass(), TEXT("GameReplicationInfo"), 0); }
				*Ptr++ = (INT)(*(_WORD*)((BYTE*)s_GameRepInfoProp + 0x4A));
			}
			// bOnlySpectator (bit 0x4000 at offset 0x524)
			if ((*(DWORD*)(Mem + 0x524) ^ *(DWORD*)((BYTE*)this + 0x524)) & 0x4000)
			{
				if (!(s_InitFlags & 8)) { s_InitFlags |= 8; s_OnlySpectatorProp = UObject::StaticFindObjectChecked(UProperty::StaticClass(), StaticClass(), TEXT("bOnlySpectator"), 0); }
				*Ptr++ = (INT)(*(_WORD*)((BYTE*)s_OnlySpectatorProp + 0x4A));
			}
			// m_TeamSelection (byte at 0x4f6)
			if (((BYTE*)this)[0x4f6] != Mem[0x4f6])
			{
				if (!(s_InitFlags & 0x10)) { s_InitFlags |= 0x10; s_TeamSelectionProp = UObject::StaticFindObjectChecked(UProperty::StaticClass(), StaticClass(), TEXT("m_TeamSelection"), 0); }
				*Ptr++ = (INT)(*(_WORD*)((BYTE*)s_TeamSelectionProp + 0x4A));
			}
			// m_eCameraMode (byte at 0x4f7)
			if (((BYTE*)this)[0x4f7] != Mem[0x4f7])
			{
				if (!(s_InitFlags & 0x20)) { s_InitFlags |= 0x20; s_CameraModeProp = UObject::StaticFindObjectChecked(UProperty::StaticClass(), StaticClass(), TEXT("m_eCameraMode"), 0); }
				*Ptr++ = (INT)(*(_WORD*)((BYTE*)s_CameraModeProp + 0x4A));
			}
		}

		// View target spectator props (replicated to all connections, not just owner)
		// vtable[99] (0x18c) returns current controlled actor; compare with Pawn at 0x3d8
		typedef INT (__thiscall* IntFn0)(APlayerController*);
		typedef INT (__thiscall* IntVFn)(void*);
		INT controlled = ((IntFn0)(*(INT*)(*(INT*)this + 0x18c)))(this);
		if (controlled != *(INT*)((BYTE*)this + 0x3d8))
		{
			// vtable[26] (0x68) on ViewTarget: check if view target actor is valid/moving
			INT* vtObj = *(INT**)((BYTE*)this + 0x5b8);
			if (((IntVFn)(*(INT*)(*(INT*)vtObj + 0x68)))((void*)vtObj))
			{
				// TargetViewRotation (FRotator at 0x628, 3 ints)
				if (*(INT*)((BYTE*)this + 0x628) != *(INT*)(Mem + 0x628) ||
					*(INT*)((BYTE*)this + 0x62c) != *(INT*)(Mem + 0x62c) ||
					*(INT*)((BYTE*)this + 0x630) != *(INT*)(Mem + 0x630))
				{
					if (!(s_InitFlags & 0x40)) { s_InitFlags |= 0x40; s_TargetViewRotProp = UObject::StaticFindObjectChecked(UProperty::StaticClass(), StaticClass(), TEXT("TargetViewRotation"), 0); }
					*Ptr++ = (INT)(*(_WORD*)((BYTE*)s_TargetViewRotProp + 0x4A));
				}
				// TargetEyeHeight (float at 0x578)
				if (*(INT*)((BYTE*)this + 0x578) != *(INT*)(Mem + 0x578))
				{
					if (!(s_InitFlags & 0x80)) { s_InitFlags |= 0x80; s_TargetEyeHeightProp = UObject::StaticFindObjectChecked(UProperty::StaticClass(), StaticClass(), TEXT("TargetEyeHeight"), 0); }
					*Ptr++ = (INT)(*(_WORD*)((BYTE*)s_TargetEyeHeightProp + 0x4A));
				}
				// TargetWeaponViewOffset (FVector at 0x634, 3 ints)
				if (*(INT*)((BYTE*)this + 0x634) != *(INT*)(Mem + 0x634) ||
					*(INT*)((BYTE*)this + 0x638) != *(INT*)(Mem + 0x638) ||
					*(INT*)((BYTE*)this + 0x63c) != *(INT*)(Mem + 0x63c))
				{
					if (!(s_InitFlags & 0x100)) { s_InitFlags |= 0x100; s_TargetWeaponViewProp = UObject::StaticFindObjectChecked(UProperty::StaticClass(), StaticClass(), TEXT("TargetWeaponViewOffset"), 0); }
					*Ptr++ = (INT)(*(_WORD*)((BYTE*)s_TargetWeaponViewProp + 0x4A));
				}
			}
		}
	}

	return Ptr;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10425a40)
FString APlayerController::GetPlayerNetworkAddress()
{
	guard(APlayerController::GetPlayerNetworkAddress);
	// Ghidra shows vtable dispatch to LowLevelGetRemoteAddress on the Player connection.
	UNetConnection* Conn = Cast<UNetConnection>( Player ); // offset 0x5B4
	if( Conn )
		return Conn->LowLevelGetRemoteAddress();
	return FString(TEXT(""));
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1038d420)
AActor * APlayerController::GetViewTarget()
{
	if( !ViewTarget )
	{
		if( Pawn && !Pawn->bDeleteMe && !Pawn->bPendingDelete )
		{
			ViewTarget = Pawn;
			return Pawn;
		}
		ViewTarget = this;
	}
	return ViewTarget;
}

IMPL_MATCH("Engine.dll", 0x103c4280)
int APlayerController::IsNetRelevantFor(APlayerController* RealViewer,AActor* Viewer,FVector SrcLocation)
{
	if( this == RealViewer )
		return 1;
	return AActor::IsNetRelevantFor( RealViewer, Viewer, SrcLocation );
}


