/*=============================================================================
	Engine.cpp: Unreal engine package implementation.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.

	This is the main translation unit for the Engine package. In Epic's
	Unreal Engine architecture every DLL is an "Unreal package" and must
	contain exactly one IMPLEMENT_PACKAGE() call. That macro expands to
	a DllMain-style entry point plus the package's static registration
	data so the engine's class/property system can discover everything
	at load time.

	This file also holds:
	  - IMPLEMENT_CLASS() for classes that don't have their own Un*.cpp
	  - UPrimitive virtual stubs (vtable must exist somewhere)
	  - Global engine variables (GEngineMem, GCache, GStats, ...)
	  - FName event/callback token definitions (ENGINE_Tick, etc.)

	Companion files in this module:
	  EngineStubs.cpp       - Trivial stub bodies for not-yet-decompiled exports
	  EngineClassImpl.cpp   - IMPLEMENT_CLASS, exec stubs, constructor shims
	  EngineEvents.cpp      - UnrealScript event thunks (ProcessEvent wrappers)
	  EngineLinkerShims.cpp - __FUNC_NAME__ / /alternatename linker tricks
	  Un*.cpp               - Per-class decompiled implementations
=============================================================================*/

#include "EnginePrivate.h"
#include "EngineDecls.h"

/*-----------------------------------------------------------------------------
	Package implementation.
-----------------------------------------------------------------------------*/

IMPLEMENT_PACKAGE(Engine);

// Classes declared in EngineClasses.h that live in Engine.cpp (no dedicated .cpp).
IMPLEMENT_CLASS(UPrimitive);
IMPLEMENT_CLASS(UMeshInstance);
IMPLEMENT_CLASS(URenderResource);
IMPLEMENT_CLASS(UPlayer);
IMPLEMENT_CLASS(UR6AbstractGameManager);
IMPLEMENT_CLASS(UR6MissionDescription);
IMPLEMENT_CLASS(UR6ModMgr);
IMPLEMENT_CLASS(UR6ServerInfo);
IMPLEMENT_CLASS(UR6GameOptions);
IMPLEMENT_CLASS(UGlobalTempObjects);
IMPLEMENT_CLASS(AR6eviLTesting);

/*-----------------------------------------------------------------------------
	GMalloc dispatch wrappers.
	The retail compiler outlined the GMalloc->Malloc / GMalloc->Free virtual
	dispatch into shared thunks at the start of Engine.dll's .text section.
	Every Engine function that allocates or frees memory dispatches through
	these tiny helpers rather than inlining the vtable call.
	Ghidra: addresses 0x103012b0 (Malloc, 22B) and 0x103012d0 (Free, 18B).
-----------------------------------------------------------------------------*/

// GMalloc->Malloc(Size, Tag) wrapper — called from 50+ Engine functions.
// Force linker to retain these thunks (/OPT:REF would strip uncalled functions).
#pragma comment(linker, "/include:?FUN_103012b0@@YAPAXK@Z")
#pragma comment(linker, "/include:?FUN_103012d0@@YAXPAX@Z")

IMPL_MATCH("Engine.dll", 0x103012b0)
void* FUN_103012b0(DWORD Size)
{
	return GMalloc->Malloc(Size, TEXT(""));
}

// GMalloc->Free(Ptr) wrapper — called from 120+ Engine functions.
IMPL_MATCH("Engine.dll", 0x103012d0)
void FUN_103012d0(void* Ptr)
{
	GMalloc->Free(Ptr);
}

/*-----------------------------------------------------------------------------
	UPrimitive virtual function stubs.
	The vtable requires definitions for all declared virtuals.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Engine.dll", 0x103f7760)
void UPrimitive::Serialize( FArchive& Ar )
{
	UObject::Serialize( Ar );
	Ar << BoundingBox << BoundingSphere;
}
IMPL_TODO("Base UPrimitive has no geometry — always returns 'no collision' - retail has 563B at 0x103f7910")
INT UPrimitive::PointCheck( FCheckResult& Result, AActor* Owner, FVector Location, FVector Extent, DWORD ExtraNodeFlags )
{ return 0; }
IMPL_TODO("Base UPrimitive has no geometry — always returns 'no collision' - retail has 1685B at 0x103f7b80")
INT UPrimitive::LineCheck( FCheckResult& Result, AActor* Owner, FVector End, FVector Start, FVector Extent, DWORD ExtraNodeFlags, DWORD ExtraFlags )
{ return 0; }
IMPL_TODO("Base UPrimitive has no geometry — returns degenerate box - retail has 185B at 0x103f7640")
FBox UPrimitive::GetRenderBoundingBox( const AActor* Owner )
{ return FBox(0); }
IMPL_TODO("Base UPrimitive has no geometry — returns degenerate sphere - retail has 170B at 0x103f7800")
FSphere UPrimitive::GetRenderBoundingSphere( const AActor* Owner )
{ return FSphere(0); }
IMPL_TODO("Base UPrimitive has no geometry — returns degenerate box - retail has 223B at 0x103f7530")
FBox UPrimitive::GetCollisionBoundingBox( const AActor* Owner ) const
{ return FBox(0); }
IMPL_EMPTY("Base UPrimitive has no geometry — cylinder collision handled by derived classes")
INT UPrimitive::UseCylinderCollision( const AActor* Owner )
{ return 0; }
IMPL_EMPTY("Base UPrimitive has no illumination data")
void UPrimitive::Illuminate( AActor* Owner, INT bDynamic )
{}
IMPL_MATCH("Engine.dll", 0x103f78e0)
FVector UPrimitive::GetEncroachExtent( AActor* Owner )
{
	// Retail (37b, RVA 0xF78E0): cylindrical half-extents — uses CollisionRadius
	// for both X and Y, and CollisionHeight for Z.
	// CollisionRadius at Owner+0xF8, CollisionHeight at Owner+0xFC.
	FLOAT r = *(FLOAT*)((BYTE*)Owner + 0xF8);
	FLOAT h = *(FLOAT*)((BYTE*)Owner + 0xFC);
	return FVector(r, r, h);
}
IMPL_MATCH("Engine.dll", 0x103f7730)
FVector UPrimitive::GetEncroachCenter( AActor* Owner )
{
	// Retail (38b, RVA 0xF7730): returns FVector at Owner+0x234 (actor world position).
	return *(FVector*)((BYTE*)Owner + 0x234);
}

/*-----------------------------------------------------------------------------
	Global variables.
-----------------------------------------------------------------------------*/

// Engine globals — UT432 base.
ENGINE_API FMemStack		GEngineMem;
ENGINE_API FMemCache		GCache;
ENGINE_API UEngine*			GEngine = NULL;

// Engine statistics.
ENGINE_API FEngineStats		GEngineStats;
ENGINE_API FStats			GStats;

// Tool subsystems (editor/rebuild).
ENGINE_API FRebuildTools	GRebuildTools;
ENGINE_API FMatineeTools	GMatineeTools;
ENGINE_API FTerrainTools	GTerrainTools;
ENGINE_API TArray<ASceneManager*> GSceneManagers;
ENGINE_API INT				GNumActiveScenes		= 0;

// Debug visualisation.
ENGINE_API FStatGraph*		GStatGraph			= NULL;
ENGINE_API FTempLineBatcher* GTempLineBatcher	= NULL;
ENGINE_API STDbgLine*		GDbgLine			= NULL;
ENGINE_API INT				GDbgLineIndex		= 0;

// Ravenshield-specific globals.
ENGINE_API UR6AbstractGameManager*	GR6GameManager			= NULL;
ENGINE_API UR6MissionDescription*	GR6MissionDescription	= NULL;
ENGINE_API UR6ModMgr*				GModMgr					= NULL;
ENGINE_API UR6ServerInfo*			GServerOptions			= NULL;
ENGINE_API UR6GameOptions*			GGameOptions			= NULL;
ENGINE_API UGlobalTempObjects*		GGlobalTempObjects		= NULL;
ENGINE_API AR6eviLTesting*			GEvilTest				= NULL;

// R6-specific font globals — serialized by UGameEngine::Serialize as GC roots.
// Initialized to cached UFont* during HUD setup; NULL until then.
// Retail addresses: 0x10670d84 (14pt), 0x10670d88 (15pt), 0x10670d8c (22pt), 0x10670d90 (36pt).
ENGINE_API UObject* GR6Font_14pt = NULL;
ENGINE_API UObject* GR6Font_15pt = NULL;
ENGINE_API UObject* GR6Font_22pt = NULL;
ENGINE_API UObject* GR6Font_36pt = NULL;

/*-----------------------------------------------------------------------------
	FName event/callback tokens.
	These are used by eventX() thunks to call UnrealScript event handlers.
	Each name is registered at package-load time and used for
	ProcessEvent( FindFunctionChecked(ENGINE_Xxx), &Parms ).
-----------------------------------------------------------------------------*/

#define NAMES_ONLY
#undef  AUTOGENERATE_NAME
#undef  AUTOGENERATE_FUNCTION
#define AUTOGENERATE_NAME(name) ENGINE_API FName ENGINE_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name) IMPLEMENT_FUNCTION(cls,idx,name)
#include "EngineClasses.h"
#undef AUTOGENERATE_FUNCTION
#undef AUTOGENERATE_NAME
#undef NAMES_ONLY

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/

// Compile-time layout verification.
// If either assert fires, adjust the padding arrays in EngineClasses.h.
COMPILE_CHECK(sizeof(UEngine)     == 0x458, UEngine_layout_mismatch_adjust_ue_unk_padding);
COMPILE_CHECK(sizeof(UGameEngine) == 0x4d0, UGameEngine_layout_mismatch_adjust_uge_unk_padding);

// =============================================================================
// UGameEngine (moved from EngineClassImpl.cpp)
// =============================================================================

// Declarations for Engine.dll-internal globals defined in other translation units.
extern INT                bGameShutDown;  // UnCamera.cpp — Engine shutdown flag (0x10670d80)
extern struct _KarmaGlobals* KGData;      // UnCamera.cpp — Karma physics world state
extern void KTermGameKarma();             // EngineAux.cpp — tears down the Karma physics world

// UGameEngine
// =============================================================================

// BSS-segment globals used by UGameEngine::Exec (retail: Engine.dll .bss ~0x10671508-0x10671710)
static INT  s_bIsCanceling   = 0;        // retail: DAT_10671508 — cancel-in-progress guard
static char s_VideosRootBuf[512];        // retail: DAT_10671510 — narrow-char videos root path
static char s_VideoFilenameBuf[512];     // retail: DAT_10671610 — narrow-char video filename

// Helper: close a UNetDriver / UNetConnection pair found through a level's NetDriver chain.
// Pattern: level->NetDriver->ServerConnection->subObject->vtable[0x6c] + conn->vtable[0x80]
static void CloseNetLevel( BYTE* level )
{
    if ( !level ) return;
    INT driver = *(INT*)(level + 0x40);
    if ( !driver ) return;
    INT conn = *(INT*)(driver + 0x3c);
    if ( !conn ) return;
    INT obj = *(INT*)(conn + 0xeb0);
    if ( !obj ) return;
    typedef void (__thiscall *tClose)(void*);
    ((tClose)(*(void***)obj )[0x6c/4])((void*)obj );
    ((tClose)(*(void***)conn)[0x80/4])((void*)conn);
}

IMPL_TODO("Engine.dll 0x103a3f00 (3692b): TESTPATCH path has two confirmed deviations from retail — (1) SpawnActor args ABI: Ghidra shows FRotator(0,0,0) and FName(0) constructed on stack before vtable[0xa8/4] call but decompiler does not show explicit arg passing; (2) FindFunctionChecked call is present in retail before vtable[0x10/4] but omitted here due to unknown FName arg")
INT UGameEngine::Exec( const TCHAR* Cmd, FOutputDevice& Ar )
{
    guard(UGameEngine::Exec);

    // Convenience aliases for UEngine fields — Ghidra offset crosscheck:
    //   Ghidra this+0x18 = actual+0x44 = Client,  this+0x1c = Audio,  this+0x20 = GRenDev
    //   Ghidra this+0x42c= actual+0x458= GLevel,  this+0x434= actual+0x460= _uge_unk[0] (GPendingLevel)
    //   Ghidra this-0x2c = actual+0x00 = vtable ptr → calling named virtuals handles this
    UClient*       pClient  = Client;
    URenderDevice* pRenDev  = GRenDev;
    ULevel*        pLevel   = GLevel;
    ULevel*        pPending = *(ULevel**)((BYTE*)this + 0x460);  // _uge_unk[0]
    FURL*          pLastURL = (FURL*)  ((BYTE*)this + 0x464);    // _uge_unk[4]
    DWORD*         pFlags   = (DWORD*) ((BYTE*)this + 0xf4);     // engine flags (UEngine._ue_unk)

    // typedef for raw zero-arg __thiscall dispatch
    typedef void (__thiscall *tVoidV)(void*);

    // ── TESTPATCH ─────────────────────────────────────────────────────────────
    if ( ParseCommand(&Cmd, TEXT("TESTPATCH")) )
    {
        if ( !GEvilTest )
        {
            // NOTE: Ghidra 0x103a3fa5-0x103a3fb8 confirms FRotator(0,0,0) and FName(0) are
            // constructed on the stack immediately before the SpawnActor vtable dispatch.
            // vtable slot 0xa8/4 = 42 confirmed. Args not explicitly visible in Ghidra output
            // (MSVC ABI stack-push not reconstructed by decompiler); current call passes no args.
            typedef AActor* (__thiscall *tSpawnActor)(ULevel*);
            tSpawnActor pfSpawn = (tSpawnActor)(*(void***)pLevel)[0xa8/4];
            GEvilTest = (AR6eviLTesting*)pfSpawn(pLevel);
        }
        if ( GEvilTest )
        {
            // NOTE: Ghidra confirms retail calls UObject::FindFunctionChecked() before the
            // vtable[0x10/4] dispatch on GEvilTest. FName arg not reconstructed by Ghidra.
            // FindFunctionChecked call is omitted here — known deviation from retail TESTPATCH path.
            // vtable slot 0x10/4 = 4 confirmed from Ghidra. ProcessEvent ABI confirmed via context.
            ((tVoidV)(*(void***)GEvilTest)[0x10/4])(GEvilTest);
        }
        return 1;
    }

    // ── VER — toggle engine flags bit 0x2000 ──────────────────────────────────
    if ( ParseCommand(&Cmd, TEXT("VER")) )
    {
        *pFlags ^= 0x2000;
        return 1;
    }

    // ── R6LIGHTVALUE — toggle engine flags bit 0x800 ──────────────────────────
    if ( ParseCommand(&Cmd, TEXT("R6LIGHTVALUE")) )
    {
        *pFlags ^= 0x800;
        return 1;
    }

    // ── PLAYVIDEO — parse FILE= and play via render-device ────────────────────
    if ( ParseCommand(&Cmd, TEXT("PLAYVIDEO")) )
    {
        TCHAR FilePart[256];
        if ( !Parse(Cmd, TEXT("FILE="), FilePart, 256) )
            return 0;

        // StopMovie: GRenDev vtable slot 40 (offset 0xa0)
        if ( pRenDev ) ((tVoidV)(*(void***)pRenDev)[0xa0/4])(pRenDev);

        // Build narrow-char filename into static buffer (retail: DAT_10671610)
        {
            FString fname(FilePart);
            const TCHAR* src = *fname;
            char* dst = s_VideoFilenameBuf;
            while ( *src ) { unsigned short c = (unsigned short)*src++; *dst++ = c > 0xff ? (char)0x7f : (char)c; }
            *dst = 0;
        }

        // Get videos-root path from GModMgr and narrow-char-encode into static buffer (retail: DAT_10671510)
        if ( GModMgr )
        {
            FString root = GModMgr->eventGetVideosRoot();
            const TCHAR* src = *root;
            char* dst = s_VideosRootBuf;
            while ( *src ) { unsigned short c = (unsigned short)*src++; *dst++ = c > 0xff ? (char)0x7f : (char)c; }
            *dst = 0;
        }

        // IsMoviePlaying: vtable[0x9c/4=39]; retail calls second time only when not playing
        if ( pRenDev )
        {
            typedef INT (__thiscall *tIsPlaying)(void*);
            tIsPlaying pfIs = (tIsPlaying)(*(void***)pRenDev)[0x9c/4];
            if ( !pfIs(pRenDev) )
                pfIs(pRenDev);
        }

        // PlayMovie: GRenDev vtable slot 42 (offset 0xa8)
        if ( pRenDev ) ((tVoidV)(*(void***)pRenDev)[0xa8/4])(pRenDev);

        return 1;
    }

    // ── STOPVIDEO ─────────────────────────────────────────────────────────────
    if ( ParseCommand(&Cmd, TEXT("STOPVIDEO")) )
    {
        // GRenDev vtable slot 43 (offset 0xac): stop/close video playback
        if ( pRenDev ) ((tVoidV)(*(void***)pRenDev)[0xac/4])(pRenDev);
        return 1;
    }

    // ── SERVER ────────────────────────────────────────────────────────────────
    if ( ParseCommand(&Cmd, TEXT("SERVER")) )
    {
        // Ghidra: (*(code *)**(undefined4 **)(GSys + 0x2c))() — double-deref raw fn pointer.
        // Intentionally returns 0 (command not consumed by game engine).
        if ( GSys )
        {
            typedef void (*tVoidVoid)();
            ((tVoidVoid)**(void****)((BYTE*)GSys + 0x2c))();
        }
        return 0;
    }

    // ── OPEN / START / STARTMINIMIZED ─────────────────────────────────────────
    {
        INT bStartMin = ParseCommand(&Cmd, TEXT("STARTMINIMIZED"));
        const TCHAR* CmdAfterStart    = Cmd;
        INT bStart    = !bStartMin && ParseCommand(&Cmd, TEXT("START"));
        const TCHAR* CmdAfterOpen     = Cmd;
        INT bOpen     = !bStartMin && !bStart && ParseCommand(&Cmd, TEXT("OPEN"));

        if ( bOpen || bStart || bStartMin )
        {
            FString Error;
            if ( pClient && pClient->Viewports.Num() )
            {
                // START only: flush viewport before travel (OPEN/STARTMINIMIZED skip this)
                if ( bStart )
                {
                    UViewport* vp = pClient->Viewports(0);
                    // Viewport vtable slot 43 (0xac): flush or stop-movie
                    ((tVoidV)(*(void***)vp)[0xac/4])(vp);
                }
                SetClientTravel(NULL, Cmd, 0, TRAVEL_Absolute);
                return 1;
            }
            // No active viewport: construct URL and Browse
            ETravelType tt = bStartMin ? TRAVEL_Partial : TRAVEL_Absolute;
            FURL URL(pLastURL, Cmd, tt);
            if ( !Browse(URL, NULL, Error) && *Error ) Ar.Logf(TEXT("%s"), *Error);
            return 1;
        }
    }

    // ── MINIMIZEAPP ───────────────────────────────────────────────────────────
    if ( ParseCommand(&Cmd, TEXT("MINIMIZEAPP")) )
    {
        if ( pClient && pClient->Viewports.Num() )
        {
            UViewport* vp = pClient->Viewports(0);
            // Viewport vtable slot 43 (0xac): minimize
            ((tVoidV)(*(void***)vp)[0xac/4])(vp);
        }
        return 1;
    }

    // ── MAXIMIZEAPP ───────────────────────────────────────────────────────────
    if ( ParseCommand(&Cmd, TEXT("MAXIMIZEAPP")) )
    {
        if ( pClient && pClient->Viewports.Num() )
        {
            UViewport* vp = pClient->Viewports(0);
            // Viewport vtable slot 44 (0xb0): maximize
            ((tVoidV)(*(void***)vp)[0xb0/4])(vp);
        }
        return 1;
    }

    // ── SERVERTRAVEL (dedicated-server only) ──────────────────────────────────
    if ( ParseCommand(&Cmd, TEXT("SERVERTRAVEL")) && GIsServer && !GIsClient )
    {
        FString Dest(Cmd);
        ALevelInfo* LI = GLevel ? GLevel->GetLevelInfo() : NULL;
        LI->eventServerTravel(Dest, 0);
        return 1;
    }

    // ── SERVERQUIT / SAY ──────────────────────────────────────────────────────
    if ( !ParseCommand(&Cmd, TEXT("SERVERQUIT")) )
    {
        // SERVERQUIT not found — check for SAY broadcast on a dedicated server
        if ( GIsServer && !GIsClient && ParseCommand(&Cmd, TEXT("SAY")) )
        {
            FString Message(Cmd);
            FName   None(NAME_None);
            ALevelInfo* LI = GLevel ? GLevel->GetLevelInfo() : NULL;
            if ( LI && LI->Game )
                LI->Game->eventBroadcast(NULL, Message, None);
            return 1;
        }
    }
    else if ( GIsServer )
    {
        // SERVERQUIT on a dedicated server: close all network connections
        CloseNetLevel((BYTE*)pLevel);
        CloseNetLevel((BYTE*)pPending);
        return 1;
    }

    // ── DISCONNECT ────────────────────────────────────────────────────────────
    if ( ParseCommand(&Cmd, TEXT("DISCONNECT")) )
    {
        FString Error;
        // Only handle if we're on a client (NM_Client=3) or listen server (NM_ListenServer=2)
        BYTE nmClient = pLevel ? *(BYTE*)((BYTE*)pLevel->GetLevelInfo() + 0x425) : 0;
        if ( !pClient || !pClient->Viewports.Num() || !pLevel || (nmClient != 3 && nmClient != 2) )
        {
            Ar.Logf(TEXT("%s"), *Error);
            return 1;
        }
        // Close network connections then travel to entry level
        CloseNetLevel((BYTE*)pLevel);
        CloseNetLevel((BYTE*)pPending);
        SetClientTravel(NULL, TEXT(""), 0, TRAVEL_Absolute);
        // Notify audio subsystem to stop/reset
        if ( Audio )
        {
            ((tVoidV)(*(void***)Audio)[0xc4/4])(Audio);
            ((tVoidV)(*(void***)Audio)[0xe4/4])(Audio);
            ((tVoidV)(*(void***)Audio)[0xe0/4])(Audio);
        }
        return 1;
    }

    // ── EXIT / QUIT ───────────────────────────────────────────────────────────
    if ( ParseCommand(&Cmd, TEXT("EXIT")) || ParseCommand(&Cmd, TEXT("QUIT")) )
    {
        CloseNetLevel((BYTE*)pLevel);
        CloseNetLevel((BYTE*)pPending);
        Ar.Log(TEXT("Closing by request"));
        appRequestExit(0);
        return 1;
    }

    // ── GETCURRENTTICKRATE ────────────────────────────────────────────────────
    if ( ParseCommand(&Cmd, TEXT("GETCURRENTTICKRATE")) )
    {
        Ar.Logf(TEXT("%f"), GetMaxTickRate());
        return 1;
    }

    // ── BIGHEAD (cheat: scale actor bone sizes) ───────────────────────────────
    // FUN_103a0540 (retail 0x103a0540) = APawn IsA filter; BIGHEAD iterates level actors,
    // checks APawn type + skeletal mesh at +0x16c, scales bones "R6 Head", "R6 L/R Hand/Foot".
    // Blocked: bone-scale API (SetBoneScale) and actor iteration pattern not yet reconstructed.
    {
        ALevelInfo* LI = pLevel ? pLevel->GetLevelInfo() : NULL;
        // Only available in standalone (NetMode==0)
        BYTE nmLocal = LI ? *(BYTE*)((BYTE*)LI + 0x425) : 0xff;
        if ( LI && nmLocal == 0 && ParseCommand(&Cmd, TEXT("BIGHEAD")) )
            return 1;
    }

    // ── GETMAXTICKRATE ────────────────────────────────────────────────────────
    if ( ParseCommand(&Cmd, TEXT("GETMAXTICKRATE")) )
    {
        Ar.Logf(TEXT("%f"), GetMaxTickRate());
        return 1;
    }

    // ── GSPYLITE — launch GameSpy Lite ────────────────────────────────────────
    if ( ParseCommand(&Cmd, TEXT("GSPYLITE")) )
    {
        FString Error;
        appLaunchURL(TEXT("GSpyLite.exe"), TEXT(""), &Error);
        return 1;
    }

    // ── SAVEGAME ──────────────────────────────────────────────────────────────
    if ( ParseCommand(&Cmd, TEXT("SAVEGAME")) )
    {
        // FUN_1039eb00 (retail 0x1039eb00, not exported): validates first char is ASCII digit '0'-'9'.
        TCHAR ch = *Cmd;
        if ( ch > 0x2f && ch < 0x3a )
        {
            INT slot = appAtoi(Cmd);
            SaveGame(slot);
        }
        return 1;
    }

    // ── CANCEL — abort a pending level connection ─────────────────────────────
    if ( ParseCommand(&Cmd, TEXT("CANCEL")) )
    {
        if ( s_bIsCanceling ) return 1;
        s_bIsCanceling = 1;

        if ( !pPending )
        {
            SetProgress(TEXT(""), TEXT(""), 0.f);
        }
        else
        {
            // UPendingLevel::Try() — vtable slot 28 (offset 0x70); returns non-zero if still trying
            typedef INT (__thiscall *tTry)(void*);
            INT bStillTrying = ((tTry)(*(void***)pPending)[0x70/4])(pPending);
            if ( bStillTrying )
            {
                s_bIsCanceling = 0;
                return 1;
            }
            SetProgress(LocalizeProgress(TEXT("CancelledConnect"), TEXT("Engine"), NULL),
                        TEXT(""), 0.f);
        }
        CancelPending();
        s_bIsCanceling = 0;
        return 1;
    }

    // ── SET gametype class validation (NM_Client guard) ───────────────────────
    // FUN_1038d760 (retail 0x1038d760) = StaticFindObject(UClass::StaticClass(), ...) wrapper.
    // Full logic: ParseToken → StaticFindObject → IsChildOf(AActor) && !IsChildOf(AGameInfo) → return 0.
    // Blocked: ParseToken integration and exact argument mapping not yet confirmed.
    if ( pLevel )
    {
        ALevelInfo* LI = pLevel->GetLevelInfo();
        BYTE nm = *(BYTE*)((BYTE*)LI + 0x425);
        if ( nm == 3 )   // NM_Client
        {
            // Retail: ParseToken → FUN_1038d760(className) → IsChildOf(AActor) && !IsChildOf(AGameInfo) → return 0
        }
    }

    // ── GLevel vtable[0x84/4=33] guard — no-arg check ─────────────────────────
    if ( pLevel )
    {
        // Ghidra: (**(code **)(**(int **)(this+0x42c) + 0x84))() — no args, returns INT
        typedef INT (__thiscall *tCheck)(ULevel*);
        if ( ((tCheck)(*(void***)pLevel)[0x84/4])(pLevel) )
            return 1;
    }

    // ── LI->Game vtable[0x4c/4=19] guard — no-arg check ──────────────────────
    if ( pLevel )
    {
        ALevelInfo* LI   = pLevel->GetLevelInfo();
        AGameInfo*  Game = *(AGameInfo**)((BYTE*)LI + 0x4cc);
        if ( Game )
        {
            LI   = pLevel->GetLevelInfo();
            Game = *(AGameInfo**)((BYTE*)LI + 0x4cc);
            typedef INT (__thiscall *tGameCheck)(AGameInfo*);
            if ( ((tGameCheck)(*(void***)Game)[0x4c/4])(Game) )
                return 1;
        }
    }

    // ── Fallthrough to UEngine::Exec ──────────────────────────────────────────
    if ( !Super::Exec(Cmd, Ar) )
        return 0;
    return 1;

    unguard;
}
IMPL_MATCH("Engine.dll", 0x1039edc0)
void UGameEngine::Destroy()
{
	guard(UGameEngine::Destroy);
	// Ghidra 0x9edc0 (153b): set engine-shutdown flag, cancel any in-flight pending level,
	// null out GLevel, log "Exit.", signal Karma teardown, then delegate to Super.
	bGameShutDown = 1;
	if (*(INT*)((BYTE*)this + 0x460))  // GPendingLevel (in _uge_unk[0])
		CancelPending();
	GLevel = NULL;
	GLog->Logf(TEXT("Exit."));
	if (KGData)
		*(INT*)((BYTE*)KGData + 0x14218) = 1;  // KGData->bIsGameBeingDestroyed
	KTermGameKarma();
	Super::Destroy();
	unguard;
}
IMPL_MATCH("Engine.dll", 0x1039f1b0)
void UGameEngine::Serialize( FArchive& Ar )
{
	guard(UGameEngine::Serialize);
	// Ghidra 0x9f1b0 (163b): chain-serialize level pointers and cached font globals as GC roots.
	Super::Serialize(Ar);
	Ar << (UObject*&)GLevel
	   << (UObject*&)GEntry
	   << *(UObject**)((BYTE*)this + 0x460)  // GPendingLevel (in _uge_unk[0])
	   << GR6Font_14pt  // cached Rainbow6_14pt UFont* (retail 0x10670d84)
	   << GR6Font_15pt  // cached Rainbow6_15pt UFont* (retail 0x10670d88)
	   << GR6Font_22pt  // cached Rainbow6_22pt UFont* (retail 0x10670d8c)
	   << GR6Font_36pt; // cached Rainbow6_36pt UFont* (retail 0x10670d90)
	unguard;
}
// UGameEngine::Tick()   — implemented in UnGame.cpp
// UGameEngine::Init()   — implemented in UnGame.cpp
// UGameEngine::Browse() — implemented in UnGame.cpp
// UGameEngine::LoadMap()— implemented in UnGame.cpp
// UGameEngine::Draw()   — implemented in UnGame.cpp
IMPL_EMPTY("Ghidra: 1b shared ret thunk at 0x10476d60")
void UGameEngine::UpdateConnectingMessage() {}
IMPL_MATCH("Engine.dll", 0x1039ed20)
void UGameEngine::Exit()
{
	guard(UGameEngine::Exit);
	Super::Exit();
	// Destroy GLevel->NetDriver (level + 0x40)
	typedef void (__thiscall *tDestroyObj)(void*, INT);
	BYTE* pLevel = *(BYTE**)((BYTE*)this + 0x458);
	if (*(INT*)(pLevel + 0x40) != 0) {
		void* pNetDriver = (void*)*(INT*)(pLevel + 0x40);
		((tDestroyObj)(*(void***)pNetDriver)[0xc/4])(pNetDriver, 1);
		*(INT*)(pLevel + 0x40) = 0;
	}
	// Destroy GRenDev (this + 0x4c)
	if (*(INT*)((BYTE*)this + 0x4c) != 0) {
		void* pRenDev = (void*)*(INT*)((BYTE*)this + 0x4c);
		((tDestroyObj)(*(void***)pRenDev)[0xc/4])(pRenDev, 1);
		*(INT*)((BYTE*)this + 0x4c) = 0;
	}
	unguard;
}
IMPL_MATCH("Engine.dll", 0x1039f520)
void UGameEngine::MouseDelta( UViewport* Viewport, DWORD Buttons, FLOAT DX, FLOAT DY )
{
	guard(UGameEngine::MouseDelta);
	enum
	{
		MOUSE_FirstHit = 0x8,
		MOUSE_LastRelease = 0x10,
	};

	typedef INT (__thiscall* tViewportStateFn)(UViewport*);
	typedef INT (__thiscall* tLevelStateFn)(ULevel*);
	typedef void (__thiscall* tSetMouseCaptureFn)(UViewport*, INT, INT, INT);

	UViewport** Viewports = Client ? *(UViewport***)((BYTE*)Client + 0x30) : NULL;
	INT ViewportCount = Client ? *(INT*)((BYTE*)Client + 0x34) : 0;
	UViewport* PrimaryViewport = (Viewports && ViewportCount > 0) ? Viewports[0] : NULL;

	if (((Buttons & MOUSE_FirstHit) == 0) ||
		!Client ||
		ViewportCount != 1 ||
		!GLevel ||
		((tViewportStateFn)(*(void***)PrimaryViewport)[0x78 / 4])(PrimaryViewport) != 0 ||
		((tLevelStateFn)(*(void***)GLevel)[0xec / 4])(GLevel) != 0 ||
		((((BYTE*)Viewport)[0x3c] & 2) != 0))
	{
		if ((Buttons & MOUSE_LastRelease) == 0)
			return;
		if (*(INT*)((BYTE*)Client + 0x3c) != 0)
			return;

		// WinDrv's viewport implementation exposes this slot as SetMouseCapture.
		((tSetMouseCaptureFn)(*(void***)Viewport)[0x9c / 4])(Viewport, 0, 0, 0);
		return;
	}

	((tSetMouseCaptureFn)(*(void***)Viewport)[0x9c / 4])(Viewport, 1, 1, 1);
	unguard;
}
IMPL_MATCH("Engine.dll", 0x1039efc0)
void UGameEngine::MousePosition( UViewport* Viewport, DWORD Buttons, FLOAT X, FLOAT Y )
{
	if (Viewport) {
		*(FLOAT*)((BYTE*)Viewport + 0x40) = X;
		*(FLOAT*)((BYTE*)Viewport + 0x44) = Y;
	}
}
IMPL_EMPTY("Ghidra: 3b shared ret thunk at 0x1040b2e0")
void UGameEngine::MouseWheel( UViewport* Viewport, DWORD Buttons, INT Delta ) {}
IMPL_EMPTY("Ghidra: 3b shared ret thunk at 0x10314770")
void UGameEngine::Click( UViewport* Viewport, DWORD Buttons, FLOAT X, FLOAT Y ) {}
IMPL_EMPTY("Ghidra: 3b shared ret thunk at 0x10314770")
void UGameEngine::UnClick( UViewport* Viewport, DWORD Buttons, INT MouseX, INT MouseY ) {}
IMPL_MATCH("Engine.dll", 0x103a1440)
void UGameEngine::SetClientTravel( UPlayer* Player, const TCHAR* NextURL, INT bItems, ETravelType TravelType )
{
	guard(UGameEngine::SetClientTravel);
	if (!Player)
		appFailAssert("Player", ".\\UnGame.cpp", 0x10c4);

	UViewport* Viewport = CastChecked<UViewport>(Player);
	*(FString*)((BYTE*)Viewport + 0x144) = NextURL;
	*(ETravelType*)((BYTE*)Viewport + 0x140) = TravelType;
	*(INT*)((BYTE*)Viewport + 0x150) = bItems;
	unguard;
}
IMPL_MATCH("Engine.dll", 0x1039eb60)
INT UGameEngine::ChallengeResponse( INT Challenge ) {
	// Retail: 30b. Mixes high/low halfwords and multiplies by a prime to produce the token.
	// Formula: ((Challenge >> 16) ^ (Challenge * 237) ^ (Challenge << 16)) ^ 0x93FE92CE
	return ((Challenge >> 16) ^ (Challenge * 237) ^ (Challenge << 16)) ^ 0x93FE92CE;
}
IMPL_MATCH("Engine.dll", 0x1039f480)
FLOAT UGameEngine::GetMaxTickRate()
{
	// Ghidra: 0x9f480, 160 bytes
	// Returns 0.0 (uncapped) if no level or no network driver.
	// On the server: returns NetServerMaxTickRate or LanServerMaxTickRate clamped to [10,120],
	//   depending on the game type byte at GGameOptions+0x2D.
	// On a connected client: returns server-negotiated tick rate from ServerConnection+0x48.
	INT iVar1 = *(INT*)((BYTE*)this + 0x458);  // GLevel
	if (iVar1 != 0)
	{
		INT iVar2 = *(INT*)(iVar1 + 0x40);  // GLevel->NetDriver
		if ((iVar2 != 0) && (GIsClient == 0))
		{
			// Server path: check game mode byte in GGameOptions
			BYTE gameMode = GGameOptions ? *((BYTE*)GGameOptions + 0x2d) : 0;
			if (gameMode != 0 && gameMode != 1)
			{
				// Internet/multi mode: use NetServerMaxTickRate
				INT rate = *(INT*)(iVar2 + 0x6c);
				if (rate < 10)  return 10.0f;
				if (rate > 0x77) rate = 0x78;
				return (FLOAT)rate;
			}
			// LAN mode: use LanServerMaxTickRate
			INT rate = *(INT*)(iVar2 + 0x70);
			if (rate < 10)  return 10.0f;
			if (rate > 0x77) rate = 0x78;
			return (FLOAT)rate;
		}
		// Client path: read server-negotiated tick rate from ServerConnection
		if (iVar1 != 0)
		{
			INT driver = *(INT*)(iVar1 + 0x40);  // NetDriver
			if (driver != 0)
			{
				INT conn = *(INT*)(driver + 0x3c);  // ServerConnection
				if (conn != 0)
					return (FLOAT)*(INT*)(conn + 0x48);  // server-negotiated tick rate
			}
		}
	}
	return 0.0f;
}
IMPL_MATCH("Engine.dll", 0x103a0dd0)
void UGameEngine::SetProgress( const TCHAR* Str1, const TCHAR* Str2, FLOAT Seconds )
{
	guard(UGameEngine::SetProgress);
	if (Client)
	{
		UViewport** Viewports = *(UViewport***)((BYTE*)Client + 0x30);
		INT ViewportCount = *(INT*)((BYTE*)Client + 0x34);
		if (ViewportCount == 0)
			return;

		UViewport* Viewport = Viewports[0];
		// UPlayer fields are still placeholder-only in the local UViewport declaration.
		UInteraction* Console = *(UInteraction**)((BYTE*)Viewport + 0x38);
		if (Console && Console->IsA(UConsole::StaticClass()))
		{
			FString Progress1(Str1);
			FString Progress2(Str2);
			Console->eventR6ProgressMsg(Progress1, Progress2, Seconds);
		}

		APlayerController* PlayerController = *(APlayerController**)((BYTE*)Viewport + 0x34);
		AHUD* PlayerHUD = *(AHUD**)((BYTE*)PlayerController + 0x5bc);
		if (Seconds != -1.0f && PlayerHUD)
			PlayerHUD->eventShowUpgradeMenu();

		PlayerController->eventSetProgressTime(Seconds);
	}
	unguard;
}
IMPL_MATCH("Engine.dll", 0x103a5890)
void UGameEngine::SaveGame( INT Position )
{
	guard(UGameEngine::SaveGame);

	ULevel* Level = *(ULevel**)((BYTE*)this + 0x458);

	// Create the saves directory.
	// GSys+0x38 = SavePath FString (USystem is forward-declared only)
	const TCHAR* SavesPath = **(FString*)((BYTE*)GSys + 0x38);
	GFileManager->MakeDirectory( SavesPath, 0 );

	// Build the save file path: "{SavesPath}\Save{Position}.usa"
	TCHAR SaveFilePath[256];
	appSprintf( SaveFilePath, TEXT("%s\\Save%i.usa"), SavesPath, Position );

	// Set LevelAction = LEVACT_Saving (2)
	ALevelInfo* LI = Level->GetLevelInfo();
	*(BYTE*)((BYTE*)LI + 0x928) = 2;

	// CopyWorldAndLoadURL via vtable slot 0xec/4 = 59
	// Ghidra: FURL::FURL(local_70, NULL); this->vtable[59](local_70); ~FURL
	{
		FURL TempURL(NULL);
		typedef void (__thiscall *CopyWorldFn)(UGameEngine*, FURL&);
		((CopyWorldFn)(*(void***)this)[0xec/4])(this, TempURL);
	}

	// Show saving progress text.
	const TCHAR* ProgressText = LocalizeProgress( TEXT("Saving"), TEXT("Engine"), NULL );
	GWarn->BeginSlowTask( ProgressText, 1, 0 );

	// SetNoCollision(1): vtable[0xa4/4 = 41]
	typedef void (__thiscall *SetNoCollFn)(ULevel*, INT);
	((SetNoCollFn)(*(void***)Level)[0xa4/4])(Level, 1);

	// Save the package.
	UObject* Outer = Level->GetOuter();
	INT bSaved = UObject::SavePackage( Outer, Level, 0, SaveFilePath, GLog, NULL );

	if ( bSaved )
	{
		// Copy sub-level files: Game{i}.usa → Save{Position}{i}.usa
		INT i;
		LI = Level->GetLevelInfo();
		INT NumStreaming = *(INT*)((BYTE*)LI + 0x438);
		for ( i = 0; i < NumStreaming; i++ )
		{
			TCHAR SrcPath[256], DstPath[256];
			SavesPath = **(FString*)((BYTE*)GSys + 0x38);
			appSprintf( SrcPath, TEXT("%s\\Game%i.usa"), SavesPath, i );
			SavesPath = **(FString*)((BYTE*)GSys + 0x38);
			appSprintf( DstPath, TEXT("%s\\Save%i%i.usa"), SavesPath, Position, i );
			GFileManager->Copy( DstPath, SrcPath, 1, 0, 0, NULL );
		}

		// Delete stale sub-level save files beyond NumStreaming.
		while ( 1 )
		{
			TCHAR StaleFile[256];
			SavesPath = **(FString*)((BYTE*)GSys + 0x38);
			appSprintf( StaleFile, TEXT("%s\\Save%i%i.usa"), SavesPath, Position, i );
			i++;
			INT Size = GFileManager->FileSize( StaleFile );
			if ( Size < 1 )
				break;
			GFileManager->Delete( StaleFile, 0, 0 );
		}
	}

	// Reset Mover SavedPos to (-1,-1,-1).
	Level = *(ULevel**)((BYTE*)this + 0x458);
	for ( INT j = 0; j < ((FArray*)((BYTE*)Level + 0x30))->Num(); j++ )
	{
		UObject* Actor = *(UObject**)(*(INT*)((BYTE*)Level + 0x30) + j * 4);
		if ( Actor && Actor->IsA( AMover::StaticClass() ) )
		{
			*(FLOAT*)((BYTE*)Actor + 0x694) = -1.0f;
			*(FLOAT*)((BYTE*)Actor + 0x698) = -1.0f;
			*(FLOAT*)((BYTE*)Actor + 0x69c) = -1.0f;
		}
	}

	// Clear progress display.
	GWarn->EndSlowTask();

	// Reset LevelAction = LEVACT_None (0)
	LI = Level->GetLevelInfo();
	*(BYTE*)((BYTE*)LI + 0x928) = 0;

	// Flush the memory cache.
	GCache.Flush( 0, ~0, 0 );

	unguard;
}
IMPL_MATCH("Engine.dll", 0x1039ee90)
void UGameEngine::CancelPending()
{
	guard(UGameEngine::CancelPending);
	INT pending = *(INT*)((BYTE*)this + 0x460);
	if (pending != 0) {
		CloseNetLevel((BYTE*)pending);
		// ConditionalDestroy the pending level object (vtable slot 3)
		typedef void (__thiscall *tDestroyObj)(void*, INT);
		if (*(INT*)((BYTE*)this + 0x460) != 0) {
			void* p = (void*)*(INT*)((BYTE*)this + 0x460);
			((tDestroyObj)(*(void***)p)[0xc/4])(p, 1);
		}
		*(INT*)((BYTE*)this + 0x460) = 0;
	}
	unguard;
}
IMPL_DIVERGE("0x103a1d60 3022b — rendering depends on FCanvasUtil which requires FRenderInterface vtable reconstruction; FRenderInterface vtable has only 3 declared methods but retail drives ~20+ slots for D3D render pipeline; permanent blocker")
void UGameEngine::PaintProgress( const FURL& URL ) {}
IMPL_MATCH("Engine.dll", 0x1039f3d0)
void UGameEngine::NotifyLevelChange()
{
	guard(UGameEngine::NotifyLevelChange);
	if (Client) {
		if (Client->Viewports.Num() != 0) {
			// Console/Interaction pointer at viewport + 0x38
			UObject* pConsole = *(UObject**)((BYTE*)Client->Viewports(0) + 0x38);
			if (pConsole) {
				UFunction* func = pConsole->FindFunctionChecked(ENGINE_NotifyLevelChange, 0);
				pConsole->ProcessEvent(func, NULL, NULL);
			}
		}
	}
	unguard;
}
IMPL_MATCH("Engine.dll", 0x1039ef60)
void UGameEngine::FixUpLevel()
{
	// Retail 38b: debug stub — logs the level's full name
	const TCHAR* Name = GLevel->GetFullName();
	GLog->Logf(Name);
}

// =============================================================================

// ============================================================================
// FRotatorF implementations
// (moved from EngineStubs.cpp)
// ============================================================================

IMPL_MATCH("Engine.dll", 0x10301ac0)
FRotatorF::FRotatorF(FRotator R) : Pitch((FLOAT)R.Pitch), Yaw((FLOAT)R.Yaw), Roll((FLOAT)R.Roll) {}
IMPL_MATCH("Engine.dll", 0x10301ac0)
FRotatorF::FRotatorF(float InPitch, float InYaw, float InRoll) : Pitch(InPitch), Yaw(InYaw), Roll(InRoll) {}
IMPL_MATCH("Engine.dll", 0x10301ac0)
FRotatorF::FRotatorF() {}
IMPL_MATCH("Engine.dll", 0x10301ae0)
FRotator FRotatorF::Rotator() { return FRotator(appRound(Pitch), appRound(Yaw), appRound(Roll)); }
IMPL_MATCH("Engine.dll", 0x103165d0)
FRotatorF & FRotatorF::operator=(FRotatorF const & p0) { Pitch=p0.Pitch; Yaw=p0.Yaw; Roll=p0.Roll; return *this; }
IMPL_MATCH("Engine.dll", 0x10301b10)
FRotatorF FRotatorF::operator*(float p0) const { return FRotatorF(Pitch*p0, Yaw*p0, Roll*p0); }
IMPL_MATCH("Engine.dll", 0x10301ba0)
FRotatorF FRotatorF::operator*=(float p0) { Pitch*=p0; Yaw*=p0; Roll*=p0; return *this; }
IMPL_MATCH("Engine.dll", 0x10301b40)
FRotatorF FRotatorF::operator+(FRotatorF p0) const { return FRotatorF(Pitch+p0.Pitch, Yaw+p0.Yaw, Roll+p0.Roll); }
IMPL_MATCH("Engine.dll", 0x10301be0)
FRotatorF FRotatorF::operator+=(FRotatorF p0) { Pitch+=p0.Pitch; Yaw+=p0.Yaw; Roll+=p0.Roll; return *this; }
IMPL_MATCH("Engine.dll", 0x10301b70)
FRotatorF FRotatorF::operator-(FRotatorF p0) const { return FRotatorF(Pitch-p0.Pitch, Yaw-p0.Yaw, Roll-p0.Roll); }
IMPL_MATCH("Engine.dll", 0x10301c20)
FRotatorF FRotatorF::operator-=(FRotatorF p0) { Pitch-=p0.Pitch; Yaw-=p0.Yaw; Roll-=p0.Roll; return *this; }
IMPL_MATCH("Engine.dll", 0x10301c60)
FVector FRotatorF::Vector()
{
	return FRotator(appRound(Pitch), appRound(Yaw), appRound(Roll)).Vector();
}

// ============================================================================
// FURL implementations
// (moved from EngineStubs.cpp)
// ============================================================================

IMPL_MATCH("Engine.dll", 0x10471a30)
FURL::FURL(FURL* Base, const TCHAR* TextURL, ETravelType Type) {
	Protocol = DefaultProtocol;
	Host     = DefaultHost;
	Port     = DefaultPort;
	Map      = DefaultMap;
	Portal   = DefaultPortal;
	Valid    = 1;

	check(TextURL);

	TCHAR Temp[1024];
	appStrncpy(Temp, TextURL, ARRAY_COUNT(Temp));
	TCHAR* Str = Temp;

	if (Type == TRAVEL_Relative) {
		check(Base);
		Protocol = Base->Protocol;
		Host     = Base->Host;
		Map      = Base->Map;
		Portal   = Base->Portal;
		Port     = Base->Port;
	}

	if (Type == TRAVEL_Relative || Type == TRAVEL_Partial) {
		check(Base);
		for (INT i = 0; i < Base->Op.Num(); i++) {
			if (appStricmp(*Base->Op(i), TEXT("PUSH"))  != 0
			 && appStricmp(*Base->Op(i), TEXT("POP"))   != 0
			 && appStricmp(*Base->Op(i), TEXT("PEER"))  != 0
			 && appStricmp(*Base->Op(i), TEXT("LOAD"))  != 0
			 && appStricmp(*Base->Op(i), TEXT("QUIET")) != 0)
			{
				new(Op) FString(Base->Op(i));
			}
		}
	}

	while (*Str == ' ')
		Str++;

	TCHAR* OptionStart = appStrchr(Str, '?');
	TCHAR* HashStart   = appStrchr(Str, '#');
	if (OptionStart == NULL || (HashStart != NULL && HashStart <= OptionStart))
		OptionStart = HashStart;

	if (OptionStart != NULL) {
		TCHAR Delim = *OptionStart;
		*OptionStart = 0;
		TCHAR* Token = OptionStart + 1;
		TCHAR  NextDelim = 0;

		do {
			TCHAR* NextQ = appStrchr(Token, '?');
			TCHAR* NextH = appStrchr(Token, '#');
			TCHAR* Next  = NextQ;
			if (Next == NULL || (NextH != NULL && NextH <= Next))
				Next = NextH;

			NextDelim = 0;
			if (Next != NULL) {
				NextDelim = *Next;
				*Next++ = 0;
			}

			if (appStrchr(Token, ' ') != NULL) {
				*this = FURL(NULL);
				Valid = 0;
				return;
			}

			if (Delim == '?')
				AddOption(Token);
			else
				Portal = Token;

			Delim = NextDelim;
			Token = Next;
		} while (Token != NULL);
	}

	UBOOL bMapChange = 0;
	UBOOL bHasMap    = 0;

	INT StrLen = appStrlen(Str);
	if (StrLen >= 3 && Str[1] == ':') {
		Protocol = DefaultProtocol;
		Host     = DefaultHost;
		Map      = Str;
		Portal   = DefaultPortal;
		Str      = NULL;
		bMapChange = 1;
		bHasMap    = 1;
		Host       = TEXT("");
	} else {
		if (appStrchr(Str, ':') != NULL) {
			TCHAR* Colon = appStrchr(Str, ':');
			if (Str + 1 < Colon) {
				TCHAR* Dot = appStrchr(Str, '.');
				if (Dot == NULL || Dot > Colon) {
					*Colon = 0;
					Protocol = Str;
					Str = Colon + 1;
				}
			}
		}

		if (*Str == '/') {
			if (Str[1] != '/') {
				*this = FURL(NULL);
				Valid = 0;
				return;
			}
			Str += 2;
			bMapChange = 1;
			Host = TEXT("");
		}

		TCHAR* Dot = appStrchr(Str, '.');
		if (Dot != NULL && Dot > Str) {
			UBOOL bIsMapExt = 0;
			if (appStrnicmp(Dot + 1, *DefaultMapExt, DefaultMapExt.Len()) == 0) {
				TCHAR After = Dot[DefaultMapExt.Len() + 1];
				if (!((After >= 'a' && After <= 'z') || (After >= 'A' && After <= 'Z') || (After >= '0' && After <= '9')))
					bIsMapExt = 1;
			}
			if (!bIsMapExt && appStrnicmp(Dot + 1, *DefaultSaveExt, DefaultSaveExt.Len()) == 0) {
				TCHAR After = Dot[DefaultSaveExt.Len() + 1];
				if (!((After >= 'a' && After <= 'z') || (After >= 'A' && After <= 'Z') || (After >= '0' && After <= '9')))
					bIsMapExt = 1;
			}

			if (!bIsMapExt) {
				TCHAR* HostStr = Str;
				TCHAR* Slash = appStrchr(Str, '/');
				if (Slash != NULL) {
					*Slash = 0;
					Str = Slash + 1;
				} else {
					Str = NULL;
				}

				TCHAR* PortSep = appStrchr(HostStr, ':');
				if (PortSep != NULL) {
					*PortSep = 0;
					Port = appAtoi(PortSep + 1);
				}

				Host = HostStr;
				if (appStricmp(*Protocol, *DefaultProtocol) == 0)
					Map = DefaultMap;
				else
					Map = TEXT("");
				bMapChange = 1;
			}
		}
	}

	if (Type == TRAVEL_Absolute && Base != NULL && IsInternal()) {
		for (INT i = 0; i < Base->Op.Num(); i++) {
			if (appStrnicmp(*Base->Op(i), TEXT("Name="), 5) == 0
			 || appStrnicmp(*Base->Op(i), TEXT("Team="), 5) == 0
			 || appStrnicmp(*Base->Op(i), TEXT("Class="), 6) == 0
			 || appStrnicmp(*Base->Op(i), TEXT("Skin="), 5) == 0
			 || appStrnicmp(*Base->Op(i), TEXT("Face="), 5) == 0
			 || appStrnicmp(*Base->Op(i), TEXT("Voice="), 6) == 0
			 || appStrnicmp(*Base->Op(i), TEXT("OverrideClass="), 14) == 0)
			{
				TCHAR Match[256];
				const TCHAR* Eq = appStrchr(*Base->Op(i), '=');
				if (Eq == NULL)
					appStrcpy(Match, *Base->Op(i));
				else
					appStrncpy(Match, *Base->Op(i), (INT)(Eq - *Base->Op(i)) + 1);

				if (appStrcmp(GetOption(Match, TEXT("")), TEXT("")) == 0) {
					debugf(TEXT("URL: Carrying over <%s>"), *Base->Op(i));
					new(Op) FString(Base->Op(i));
				}
			}
		}
	}

	if (Str != NULL && *Str != 0) {
		if (IsInternal()) {
			bHasMap = 1;
			TCHAR* Slash = appStrchr(Str, '/');
			if (Slash != NULL) {
				*Slash = 0;
				TCHAR* Slash2 = appStrchr(Slash + 1, '/');
				if (Slash2 != NULL) {
					*Slash2 = 0;
					if (Slash2[1] != 0) {
						*this = FURL(NULL);
						Valid = 0;
						return;
					}
				}
				Portal = Slash + 1;
			}
		}
		Map = Str;
	}

	if (appStrchr(*Protocol, ' ') || appStrchr(*Host, ' ') || appStrchr(*Portal, ' ')
	 || (!bMapChange && !bHasMap && Op.Num() == 0))
	{
		*this = FURL(NULL);
		Valid = 0;
	}
}

IMPL_MATCH("Engine.dll", 0x10471a30)
FURL::FURL(const TCHAR* Filename) {
	Protocol = DefaultProtocol;
	Host     = DefaultHost;
	Port     = DefaultPort;
	Map      = Filename ? FString(Filename) : DefaultMap;
	Portal   = DefaultPortal;
	Valid    = 1;
}

IMPL_MATCH("Engine.dll", 0x104710c0)
FString FURL::String(int FullyQualified) const {
	FString Result;
	if (Protocol != DefaultProtocol || FullyQualified) {
		Result += Protocol;
		Result += TEXT(":");
		if (Host != DefaultHost)
			Result += TEXT("//");
	}
	if (Host != DefaultHost || Port != DefaultPort) {
		Result += Host;
		if (Port != DefaultPort) {
			Result += TEXT(":");
			Result += FString::Printf(TEXT("%i"), Port);
		}
		Result += TEXT("/");
	}
	if (Map.Len())
		Result += Map;
	for (INT i = 0; i < Op.Num(); i++) {
		Result += TEXT("?");
		Result += Op(i);
	}
	if (Portal.Len()) {
		Result += TEXT("#");
		Result += Portal;
	}
	return Result;
}

IMPL_MATCH("Engine.dll", 0x104712c0)
void FURL::AddOption(const TCHAR* Str) {
	const TCHAR* Eq = appStrchr(Str,'=');
	INT PrefixLen = Eq ? (INT)(Eq - Str) + 1 : appStrlen(Str) + 1;
	INT i;
	for( i=0; i<Op.Num(); i++ )
		if( appStrnicmp(*Op(i),Str,PrefixLen)==0 )
			break;
	if( i==Op.Num() )
		new(Op)FString(Str);
	else
		Op(i) = Str;
}

IMPL_MATCH("Engine.dll", 0x104713f0)
void FURL::LoadURLConfig(const TCHAR* Section, const TCHAR* Filename) {
	TCHAR Buffer[32000];
	GConfig->GetSection( Section, Buffer, ARRAY_COUNT(Buffer), Filename );
	const TCHAR* Ptr = Buffer;
	while( *Ptr ) {
		AddOption( Ptr );
		Ptr += appStrlen(Ptr) + 1;
	}
}

IMPL_MATCH("Engine.dll", 0x104714b0)
void FURL::SaveURLConfig(const TCHAR* Section, const TCHAR* Key, const TCHAR* Filename) const {
	for( INT i=0; i<Op.Num(); i++ ) {
		TCHAR Temp[1024];
		appStrcpy( Temp, *Op(i) );
		TCHAR* Value = appStrchr( Temp, '=' );
		if( Value ) {
			*Value++ = 0;
			if( appStricmp(Temp, Key)==0 )
				GConfig->SetString( Section, Temp, Value, Filename );
		}
	}
}

IMPL_MATCH("Engine.dll", 0x10470ea0)
void FURL::StaticExit() {
	DefaultProtocol          = TEXT("");
	DefaultProtocolDescription = TEXT("");
	DefaultName              = TEXT("");
	DefaultMap               = TEXT("");
	DefaultLocalMap          = TEXT("");
	DefaultHost              = TEXT("");
	DefaultPortal            = TEXT("");
	DefaultMapExt            = TEXT("");
	DefaultSaveExt           = TEXT("");
}

IMPL_MATCH("Engine.dll", 0x10470c80)
void FURL::StaticInit() {
	DefaultProtocol            = GConfig->GetStr( TEXT("URL"), TEXT("Protocol"), NULL );
	DefaultProtocolDescription = GConfig->GetStr( TEXT("URL"), TEXT("ProtocolDescription"), NULL );
	DefaultName                = GConfig->GetStr( TEXT("URL"), TEXT("Name"), NULL );
	if( DefaultName == TEXT("UbiPlayer") )
		DefaultName = appUserName();
	DefaultMap = TEXT("Entry.");
	DefaultMap += GConfig->GetStr( TEXT("URL"), TEXT("MapExt"), NULL );
	DefaultLocalMap = TEXT("Entry.");
	DefaultLocalMap += GConfig->GetStr( TEXT("URL"), TEXT("MapExt"), NULL );
	DefaultHost     = GConfig->GetStr( TEXT("URL"), TEXT("Host"), NULL );
	DefaultPortal   = GConfig->GetStr( TEXT("URL"), TEXT("Portal"), NULL );
	DefaultMapExt   = GConfig->GetStr( TEXT("URL"), TEXT("MapExt"), NULL );
	DefaultSaveExt  = GConfig->GetStr( TEXT("URL"), TEXT("SaveExt"), NULL );
	DefaultPort     = appAtoi( GConfig->GetStr( TEXT("URL"), TEXT("Port"), NULL ) );
}

IMPL_MATCH("Engine.dll", 0x104715b0)
int FURL::HasOption(const TCHAR* Test) const {
	for( INT i=0; i<Op.Num(); i++ )
		if( appStricmp(*Op(i),Test)==0 )
			return 1;
	return 0;
}

IMPL_MATCH("Engine.dll", 0x10470fa0)
int FURL::IsInternal() const {
	return Protocol == DefaultProtocol;
}

IMPL_MATCH("Engine.dll", 0x10471020)
int FURL::IsLocalInternal() const {
	return IsInternal() && Host.Len()==0;
}

IMPL_MATCH("Engine.dll", 0x10471770)
int FURL::operator==(FURL const & Other) const {
	if( Protocol!=Other.Protocol ) return 0;
	if( Host!=Other.Host ) return 0;
	if( Map!=Other.Map ) return 0;
	if( Port!=Other.Port ) return 0;
	if( Op.Num()!=Other.Op.Num() ) return 0;
	for( INT i=0; i<Op.Num(); i++ )
		if( Op(i)!=Other.Op(i) )
			return 0;
	return 1;
}

IMPL_MATCH("Engine.dll", 0x10471670)
const TCHAR* FURL::GetOption(const TCHAR* Match, const TCHAR* Default) const {
	for( INT i=0; i<Op.Num(); i++ )
		if( appStrnicmp(*Op(i),Match,appStrlen(Match))==0 )
			return *Op(i) + appStrlen(Match);
	return Default;
}
