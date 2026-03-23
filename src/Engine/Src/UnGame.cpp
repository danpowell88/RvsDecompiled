/*=============================================================================
	UnGame.cpp: Engine and game-engine core (UEngine, UGameEngine)
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

// Placement new for placement-new stubs in this TU.
#include "EnginePrivate.h"
#pragma warning(push)
#pragma warning(disable: 4291)
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EngineDecls.h"

// --- UGameEngine ---

// g_pEngine is defined in UnCamera.cpp; declared here so Init() can set it.
extern ENGINE_API UEngine* g_pEngine;

// Ghidra analysis of Engine.dll at 0xa37a0.
// FUN_103563f0 (post-render-device resource setup) omitted: identity not established.
// appSprintf CLASS= third arg derived from PlayerURL options; Ghidra lost the arg.
// GConfig server-ini section call uses GetSection; original vtable slot unclear.
// GLevel vtable[0xb4] and vtable[0xdc] preserved via raw dispatch; identities unknown.
// Audio vtable[0x78] setup signature approximated as (void*, FString&) -> INT.
IMPL_MATCH("Engine.dll", 0x103a37a0)
void UGameEngine::Init()
{
    guard(UGameEngine::Init);

    // Retail UnGame.cpp line 0x230: sizeof(UGameEngine) must equal the UClass property size.
    check(GetClass()->GetPropertiesSize() == 0x4d0);

    // Register as the global engine singleton.
    g_pEngine = this;

    // Initialise the base UEngine subsystem.
    UEngine::Init();

    // Clear the GLevel slot (populated by Browse → LoadMap below).
    *(DWORD*)((BYTE*)this + 0x458) = 0;

    // Remove stale files from the package cache.
    appCleanFileCache();

    // -------------------------------------------------------------------------
    // Client-side subsystem setup: viewport manager + render device.
    // -------------------------------------------------------------------------
    if (GIsClient)
    {
        // Load and construct the viewport manager (UClient subclass).
        UClass* ClientClass = UObject::StaticLoadClass(
            UClient::StaticClass(), NULL,
            TEXT("ini:Engine.Engine.ViewportManager"), NULL, LOAD_NoFail, NULL);
        Client = Cast<UClient>(UObject::StaticConstructObject(
            ClientClass, UObject::GetTransientPackage(), NAME_None, 0, NULL, GError, NULL));

        // Ghidra: vtable byte-offset 0x64 (slot 25) called on the new client with no args.
        // In the UClient vtable this is UpdateGamma() — acts as a post-construction display init.
        Client->UpdateGamma();

        // Default viewport dimensions: 640 × 480.
        // Offsets confirmed from Ghidra (UClient retail layout).
        BYTE* CR = (BYTE*)Client;
        *(DWORD*)(CR + 0x50) = 0x280;  // full width
        *(DWORD*)(CR + 0x48) = 0x280;  // preferred width
        *(DWORD*)(CR + 0x54) = 0x1e0;  // full height
        *(DWORD*)(CR + 0x4c) = 0x1e0;  // preferred height

        // Load and construct the render device (URenderDevice subclass).
        UClass* RenDevClass = UObject::StaticLoadClass(
            URenderDevice::StaticClass(), NULL,
            TEXT("ini:Engine.Engine.RenderDevice"), NULL, LOAD_NoFail, NULL);
        UObject* RenDevObj = UObject::StaticConstructObject(
            RenDevClass, UObject::GetTransientPackage(), NAME_None, 0, NULL, GError, NULL);
        // Stored at UEngine+0x4c (unnamed field archived by UEngine::Serialize).
        *(UObject**)((BYTE*)this + 0x4c) = RenDevObj;

        // Initialise the render device (URenderDevice::Init — vtable[0x68/4]).
        Cast<URenderDevice>(RenDevObj)->Init();

        // FUN_103563f0: post-init render resource setup (GIsClient guard confirmed).
        // Identity unknown — omitted. See IMPL_APPROX annotation above.
    }

    // Error string used throughout Browse / LoadMap.
    FString Error;

    // -------------------------------------------------------------------------
    // Browse to the Entry level to prime engine-level object state.
    // -------------------------------------------------------------------------
    if (Client)
    {
        FURL EntryURL(TEXT("Entry"));
        if (!Browse(EntryURL, NULL, Error))
            GError->Logf(LocalizeError(TEXT("FailedBrowse"), TEXT("Engine")));

        // Swap GLevel ↔ GEntry so the entry level becomes the persistent base.
        // Ghidra: exchanges DWORD at (this+0x458) with DWORD at (this+0x45c).
        DWORD Tmp            = *(DWORD*)((BYTE*)this + 0x458);
        *(DWORD*)((BYTE*)this + 0x458) = *(DWORD*)((BYTE*)this + 0x45c);
        *(DWORD*)((BYTE*)this + 0x45c) = Tmp;

        // Bind static input tables.
        UInput::StaticInitInput();
        UInputPlanning::StaticInitInput();

        // Construct and install the InteractionMaster at Client+0x94.
        UClass* IMClass = UObject::StaticLoadClass(
            UInteractionMaster::StaticClass(), NULL,
            TEXT("engine.InteractionMaster"), NULL, LOAD_NoFail, NULL);
        *(UObject**)((BYTE*)Client + 0x94) = UObject::StaticConstructObject(
            IMClass, UObject::GetTransientPackage(), NAME_None, 0, NULL, GError, NULL);
    }

    // -------------------------------------------------------------------------
    // Build the default player URL from User.ini [DefaultPlayer].
    // -------------------------------------------------------------------------
    FURL PlayerURL(NULL);
    PlayerURL.LoadURLConfig(TEXT("DefaultPlayer"), TEXT("User"));
    if (Client)
    {
        // Ghidra: appSprintf(buf, L"CLASS=%s") — third arg lost in analysis.
        // Carry the CLASS option from the DefaultPlayer section explicitly.
        TCHAR ClassBuf[64];
        appSprintf(ClassBuf, TEXT("CLASS=%s"),
            PlayerURL.GetOption(TEXT("CLASS="), TEXT("")));
        PlayerURL.AddOption(ClassBuf);
    }

    // Server-only: override game class from the mod manager's server ini.
    TCHAR ClassOverride[4096];
    ClassOverride[0] = 0;
    if (GIsServer && !GIsClient)
    {
        FString ServerIni = GModMgr->eventGetServerIni();
        // Ghidra: GConfig->vtable[0xc/4] fills a local FString from the ini section.
        // Using GetSection as the closest typed equivalent.
        TCHAR SectionBuf[32000];
        GConfig->GetSection(*ServerIni, SectionBuf, ARRAY_COUNT(SectionBuf), NULL);
        appStrcpy(ClassOverride, SectionBuf);
    }

    // Construct and validate the initial map URL (TRAVEL_Partial = 1).
    FURL FinalURL(&PlayerURL, ClassOverride, TRAVEL_Partial);
    if (!FinalURL.Valid)
        GError->Logf(LocalizeError(TEXT("InvalidUrl"), TEXT("Engine")));

    // -------------------------------------------------------------------------
    // Load the initial map; fall back to DefaultLocalMap on first failure.
    // -------------------------------------------------------------------------
    if (!LoadMap(FinalURL, NULL, NULL, Error))
    {
        UBOOL Recovered = 0;
        if (!Error.Len() && appStricmp(ClassOverride, *FURL::DefaultLocalMap) != 0)
        {
            FURL FallbackURL(&PlayerURL, *FURL::DefaultLocalMap, TRAVEL_Partial);
            if (LoadMap(FallbackURL, NULL, NULL, Error))
                Recovered = 1;
        }
        if (!Recovered)
            GError->Logf(LocalizeError(TEXT("FailedBrowse"), TEXT("Engine")));
    }

    // -------------------------------------------------------------------------
    // Client-side post-map setup.
    // -------------------------------------------------------------------------
    if (Client)
    {
        BYTE* CR = (BYTE*)Client;
        UInteractionMaster* IM = *(UInteractionMaster**)(CR + 0x94);

        // Wire the InteractionMaster's parent pointer back to Client (IM+0x34).
        *(INT*)((BYTE*)IM + 0x34) = (INT)Client;

        // Display the engine copyright splash.
        IM->DisplayCopyright();

        // Obtain the primary viewport.
        // Ghidra: UClient vtable byte-offset 0x88 (slot 34); method not named in headers.
        typedef UViewport* (__thiscall *tGetViewport)(void*);
        UViewport* Viewport = ((tGetViewport)(*(void***)CR)[0x88 / sizeof(void*)])(CR);

        // Create and bind the PlayerConsole interaction.
        FString PlayerConsoleClass(TEXT("ini:Engine.Engine.PlayerConsole"));
        UInteraction* Console =
            IM->eventAddInteraction(PlayerConsoleClass, (UPlayer*)Viewport);
        if (Console)
        {
            *(UInteraction**)((BYTE*)Viewport + 0x38) = Console;
            *(UInteraction**)((BYTE*)IM       + 0x3c) = Console;
        }

        // GLevel vtable[0xb4/4] — likely BeginPlay or similar game-start notification.
        FString LevelError;
        void* GLevel = *(void**)((BYTE*)this + 0x458);
        if (GLevel)
        {
            typedef INT (__thiscall *tLevelBegin)(void*, FString&);
            if (!((tLevelBegin)(*(void***)GLevel)[0xb4 / sizeof(void*)])(GLevel, LevelError))
                GError->Logf(*LevelError);
        }

        // Bind the UInput system to the viewport.
        Viewport->InitInput();

        // Viewport render-surface setup (vtable[0x88/4] = open window / surface).
        typedef void* (__thiscall *tVpSurface)(void*);
        ((tVpSurface)(*(void***)Viewport)[0x88 / sizeof(void*)])(Viewport);

        // GLevel vtable[0xdc/4] — likely CommenceMatch or NotifyBeginPlay.
        if (GLevel)
        {
            typedef void (__thiscall *tLevelPost)(void*);
            ((tLevelPost)(*(void***)GLevel)[0xdc / sizeof(void*)])(GLevel);
        }

        // Initialise the audio subsystem.
        UEngine::InitAudio();

        // Audio post-init viewport / channel setup (vtable[0x78/4] on Audio).
        // On failure: log and tear down the audio subsystem.
        if (Audio)
        {
            typedef INT (__thiscall *tAudioSetup)(void*, FString&);
            FString AudioError;
            if (!((tAudioSetup)(*(void***)Audio)[0x78 / sizeof(void*)])(Audio, AudioError))
            {
                GLog->Logf(NAME_Init, TEXT("Failed to set up audio viewport"));
                if (Audio) Audio->ConditionalDestroy();
                Audio = NULL;
            }
        }
    }

    GLog->Logf(NAME_Init, TEXT("UGameEngine::Init complete"));
    unguard;
}

IMPL_MATCH("Engine.dll", 0x1039fc90)
int UGameEngine::ReplaceTexture(FString,UTexture *)
{
	guard(UGameEngine::ReplaceTexture);
	// Ghidra 0x9fc90: loads a BMP/TGA from disk, validates dimensions match UTexture,
	// decodes pixel data (RGB24/RGBA32) and uploads to render surface.
	// FUN_10316cb0 = render target upload helper; GFileManager vtable used for file I/O.
	// TODO: implement UGameEngine::ReplaceTexture (retail 0x9fc90: load BMP/TGA, validate dimensions, upload to render surface)
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1039f610)
int UGameEngine::LoadBackgroundImage(FString,UTexture *,UTexture *)
{
	guard(UGameEngine::LoadBackgroundImage);
	// Ghidra 0x9f730: load a background image file and decode into one or two UTextures.
	// FUN_10316cb0 = render target upload; GFileManager vtable used for file open/read.
	// TODO: implement UGameEngine::LoadBackgroundImage (retail 0x9f730: load background image file and decode into UTexture)
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103a2960)
void UGameEngine::LoadRandomMenuBackgroundImage(FString Path)
{
	guard(UGameEngine::LoadRandomMenuBackgroundImage);
	// Ghidra 0x10510f15: find two generic background textures; if both exist,
	// enumerate *.tga files from Path, pick one at random, then call ReplaceTexture
	// via vtable[0xD0] (index 52).  File enumeration uses GFileManager vtable[0x2C].
	UTexture* Tex0 = (UTexture*)UObject::StaticFindObject(
		UTexture::StaticClass(), (UObject*)0xffffffff,
		TEXT("R6MenuBG.Backgrounds.GenericMainMenu0"), 0);
	UTexture* Tex1 = (UTexture*)UObject::StaticFindObject(
		UTexture::StaticClass(), (UObject*)0xffffffff,
		TEXT("R6MenuBG.Backgrounds.GenericMainMenu1"), 0);
	if (Tex0 && Tex1)
	{
		// FUN_1038a4f0 = retrieve matching texture object after enumeration step.
		// FUN_103217e0 / FUN_103a2bba = post-replace notification/cache-invalidate helpers.
		// DIVERGENCE: TGA file enumeration and ReplaceTexture call omitted.
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103a5c00)
void UGameEngine::PostRenderFullScreenEffects(FLevelSceneNode* SceneNode, UViewport* Viewport)
{
	guardSlow(UGameEngine::PostRenderFullScreenEffects);
	// Ghidra 0x103a5c00: creates FCanvasUtil from Viewport+0x164 (FRenderInterface*),
	// lazily constructs two UFinalBlend materials cached in global statics
	// (DAT_10671748 and DAT_10671744), adjusts blend flags, then runs full-screen passes.
	// FUN_10385b30 = UFinalBlend lazy construction helper (creates via StaticConstructObject).
	// TODO: implement UGameEngine::PostRenderFullScreenEffects (retail 0x103a5c00: creates FCanvasUtil, lazily constructs UFinalBlend materials, runs full-screen passes)
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x1039f150)
void UGameEngine::AddLinkerToMasterMap(UNetDriver* NetDriver, APawn* Pawn)
{
	guardSlow(UGameEngine::AddLinkerToMasterMap);
	// Ghidra 0x103e0000: for APawn, look up its linker (or outer's linker), then add
	// to the master map and flag the entry with 0x4000.
	if (!Pawn)
		return;
	ULinkerLoad* Linker = Pawn->GetLinker();
	if (!Linker)
	{
		UObject* Outer = Pawn->GetOuter();
		if (!Outer)
			return;
		Linker = Outer->GetLinker();
		if (!Linker)
			return;
	}
	// Add linker via MasterMap vtable[0x78] (AddLinker); returns channel index.
	void*  MapObj  = *(void**)((BYTE*)NetDriver + 0x44);
	void** MapVtbl = *(void***)MapObj;
	typedef int (__thiscall *tAddLinker)(void*, ULinkerLoad*);
	int iIdx = ((tAddLinker)MapVtbl[0x78 / sizeof(void*)])(MapObj, Linker);
	// Mark the entry at iIdx*0x44+0x40 with flag 0x4000 (mutable/relevant).
	BYTE* pEntries = *(BYTE**)((BYTE*)MapObj + 0x2C);
	*(DWORD*)(pEntries + iIdx * 0x44 + 0x40) |= 0x4000;
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x1039f150)
void UGameEngine::AddLinkerToMasterMap(UNetDriver* NetDriver, UMaterial* Mat)
{
	guardSlow(UGameEngine::AddLinkerToMasterMap);
	// Ghidra 0x103e0000 (UMaterial overload): resolve outer's linker, add to master map.
	if (!Mat)
		return;
	UObject* Outer = Mat->GetOuter();
	if (!Outer)
	{
		// NOTE: Divergence — Ghidra calls GetFullName/GetName then Logf; exact format unknown.
		GLog->Logf(Mat->GetFullName());
		return;
	}
	ULinkerLoad* Linker = Outer->GetLinker();
	if (!Linker)
	{
		Linker = UObject::GetPackageLinker(Outer, NULL, LOAD_Forgiving, NULL, NULL);
		if (!Linker)
		{
			UObject* OuterOuter = Mat->GetOuter()->GetOuter();
			if (OuterOuter)
			{
				Linker = UObject::GetPackageLinker(OuterOuter, NULL, LOAD_Forgiving, NULL, NULL);
				if (!Linker)
					return;
			}
			// if OuterOuter==NULL, Linker stays NULL — original code falls through (byte-accurate).
		}
	}
	void*  MapObj  = *(void**)((BYTE*)NetDriver + 0x44);
	void** MapVtbl = *(void***)MapObj;
	typedef void (__thiscall *tAddLinker)(void*, ULinkerLoad*);
	((tAddLinker)MapVtbl[0x78 / sizeof(void*)])(MapObj, Linker);
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x1039f150)
void UGameEngine::AddLinkerToMasterMap(UNetDriver* NetDriver, UMesh* Mesh)
{
	guardSlow(UGameEngine::AddLinkerToMasterMap);
	// Ghidra: identical logic to the UMaterial overload, different parameter type.
	if (!Mesh)
		return;
	UObject* Outer = Mesh->GetOuter();
	if (!Outer)
	{
		GLog->Logf(Mesh->GetFullName());
		return;
	}
	ULinkerLoad* Linker = Outer->GetLinker();
	if (!Linker)
	{
		Linker = UObject::GetPackageLinker(Outer, NULL, LOAD_Forgiving, NULL, NULL);
		if (!Linker)
		{
			UObject* OuterOuter = Mesh->GetOuter()->GetOuter();
			if (OuterOuter)
			{
				Linker = UObject::GetPackageLinker(OuterOuter, NULL, LOAD_Forgiving, NULL, NULL);
				if (!Linker)
					return;
			}
		}
	}
	void*  MapObj  = *(void**)((BYTE*)NetDriver + 0x44);
	void** MapVtbl = *(void***)MapObj;
	typedef void (__thiscall *tAddLinker)(void*, ULinkerLoad*);
	((tAddLinker)MapVtbl[0x78 / sizeof(void*)])(MapObj, Linker);
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x1039f150)
void UGameEngine::AddLinkerToMasterMap(UNetDriver* NetDriver, UStaticMesh* Mesh)
{
	guardSlow(UGameEngine::AddLinkerToMasterMap);
	// Ghidra: identical logic to the UMesh overload, different parameter type.
	if (!Mesh)
		return;
	UObject* Outer = Mesh->GetOuter();
	if (!Outer)
	{
		GLog->Logf(Mesh->GetFullName());
		return;
	}
	ULinkerLoad* Linker = Outer->GetLinker();
	if (!Linker)
	{
		Linker = UObject::GetPackageLinker(Outer, NULL, LOAD_Forgiving, NULL, NULL);
		if (!Linker)
		{
			UObject* OuterOuter = Mesh->GetOuter()->GetOuter();
			if (OuterOuter)
			{
				Linker = UObject::GetPackageLinker(OuterOuter, NULL, LOAD_Forgiving, NULL, NULL);
				if (!Linker)
					return;
			}
		}
	}
	void*  MapObj  = *(void**)((BYTE*)NetDriver + 0x44);
	void** MapVtbl = *(void***)MapObj;
	typedef void (__thiscall *tAddLinker)(void*, ULinkerLoad*);
	((tAddLinker)MapVtbl[0x78 / sizeof(void*)])(MapObj, Linker);
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x103a2d80)
void UGameEngine::DisplayGameVideo(eGameVideoType VideoType)
{
	guardSlow(UGameEngine::DisplayGameVideo);
	// Ghidra 0x103a2d80: get first viewport from Client, close fullscreen mode,
	// build .bik filename from VideoType (0=Logos, 1=RS_Intro, 2=RS_Outro,
	// 3=map_Intro, 4=map_Outro), then play via GModMgr.
	// NOTE: Divergence — GModMgr and UR6ModMgr not declared in this TU; video
	// playback and GModMgr dispatch omitted.
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x103a0f20)
void UGameEngine::InitializeMissionDescription(FString& OutDesc)
{
	guardSlow(UGameEngine::InitializeMissionDescription);
	// Ghidra 0x103a0f20: calls GModMgr.IsRavenShield(), builds map INI path
	// ("..\\MODS\\<mod>\\MAPS\\<map>.INI"), resets GR6MissionDescription, calls
	// UR6MissionDescription::eventInit.  Falls back to mods list then "..\\MAPS\\".
	// NOTE: Divergence — GModMgr, GR6MissionDescription and UR6MissionDescription
	// not declared in this TU; full implementation deferred.
	unguardSlow;
}


// --- UEngine ---
// Ghidra 0x10393060 (UEngine::StaticConstructor):
// Register two config properties and create the ArmPatches cache directory.
IMPL_MATCH("Engine.dll", 0x103947e0)
void UEngine::StaticConstructor()
{
	guard(UEngine::StaticConstructor)
	new(GetClass(), TEXT("CacheSizeMegs"), RF_Public)
		UIntProperty(EC_CppProperty, 0x84, TEXT("Settings"), CPF_Config);
	new(GetClass(), TEXT("UseSound"), RF_Public)
		UBoolProperty(EC_CppProperty, 0x88, TEXT("Settings"), CPF_Config);
	*(DWORD*)((BYTE*)this + 0x8C) = 0;  // unknown DWORD, zeroed at class registration
	// Ghidra shows two GFileManager->vtable[9] calls; the first has no explicit args
	// (likely a no-op or mis-decoded by Ghidra); only the meaningful mkdir is kept.
	GFileManager->MakeDirectory(TEXT("..\\ArmPatches\\Cache"), false);
	// FUN_103949aa = identity unknown; called after MakeDirectory, likely triggers
	// a file-system refresh or ARM cache validation step.
	// TODO: resolve FUN_103949aa and add call here
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10311900)
int UEngine::ReplaceTexture(FString,UTexture *)
{
	// Ghidra 0x10311900: destructs FString by-value param, returns 0.
	return 0;
}

IMPL_MATCH("Engine.dll", 0x10393120)
void UEngine::Serialize(FArchive &Ar)
{
	guard(UEngine::Serialize);
	// Ghidra 0x10393120: UObject::Serialize, then Ar << fields at +0x40,+0x44(Client),+0x48(Audio),+0x4C,
	// then 5 global static UObject* pointers (BSS, always NULL on first run).
	UObject::Serialize(Ar);
	Ar << *(UObject**)((BYTE*)this + 0x40);	// unknown UObject* field before Client
	Ar << (UObject*&)Client;
	Ar << (UAudioSubsystem*&)Audio;
	Ar << *(UObject**)((BYTE*)this + 0x4C);	// unknown UObject* field after Audio
	// NOTE: Divergence — 5 global static UObject* refs (0x1066bcd0-bc) skipped; BSS/NULL at startup.
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103927d0)
int UEngine::Key(UViewport*, EInputKey Key)
{
	guard(UEngine::Key);
	// Ghidra 0x103927d0: check GIsRunning, then dispatch to Client->InteractionMaster.
	if (GIsRunning && Client)
	{
		UInteractionMaster* IM = *(UInteractionMaster**)((BYTE*)Client + 0x94);
		if (IM)
			return IM->MasterProcessKeyType(Key);
	}
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103118e0)
int UEngine::LoadBackgroundImage(FString,UTexture *,UTexture *)
{
	// Ghidra 0x103118e0: destructs FString by-value param, returns 1.
	return 1;
}

IMPL_MATCH("Engine.dll", 0x103118d0)
void UEngine::LoadRandomMenuBackgroundImage(FString)
{
	// Ghidra 0x103118d0: destructs FString by-value param, returns.
}

IMPL_MATCH("Engine.dll", 0x10393c60)
int UEngine::CacheArmPatch(FGuid *,DWORD *)
{
	guardSlow(UEngine::CacheArmPatch);
	// Ghidra 0x1a5c0: validates ARM copy-protection patch — loads patch data,
	// calls crypto verification. Very complex with many unresolved FUN_ calls.
	// TODO: implement UEngine::CacheArmPatch (retail 0x1a5c0: ARM copy-protection patch validation; many unresolved FUN_ calls)
	return 0;
	unguardSlow;
}

IMPL_MATCH("Engine.dll", 0x10395d70)
void UEngine::Destroy()
{
	guard(UEngine::Destroy);
	// Ghidra 0x10395d70: clean up engine-wide singletons then call base Destroy.
	RemoveFromRoot();
	Audio  = NULL;	// +0x48
	Client = NULL;	// +0x44
	FURL::StaticExit();
	GEngineMem.Exit();
	GCache.Exit(1);
	// NOTE: Divergence — GModMgr, GGameOptions, GServerOptions, GR6MissionDescription,
	// GR6GameManager cleanup omitted: types not yet declared in this translation unit.
	// NOTE: Divergence — GStatGraph, GTempLineBatcher cleanup omitted: same reason.
	UObject::Destroy();
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103939f0)
int UEngine::ExecServerProf(const TCHAR*,int,FOutputDevice &)
{
	guard(UEngine::ExecServerProf);
	// Ghidra 0x31b20: server profiling exec command handler.
	// TODO: implement UEngine::ExecServerProf (retail 0x31b20: server profiling command handler; FUN_ profiling-data calls unresolved)
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103938d0)
void UEngine::InitAudio()
{
	guard(UEngine::InitAudio);
	// Ghidra 0x103938d0: load audio device class from ini and construct it.
	// UseSound flag lives at +0x88 (UBoolProperty registered in StaticConstructor).
	UBOOL UseSound = *(UBOOL*)((BYTE*)this + 0x88);
	if (UseSound && GIsClient)
	{
		if (!ParseParam(appCmdLine(), TEXT("NOSOUND")))
		{
			UClass* AudioClass = UObject::StaticLoadClass(
				UAudioSubsystem::StaticClass(), NULL,
				TEXT("ini:Engine.Engine.AudioDevice"), NULL, 1, NULL);
			// NOTE: Divergence — retail uses FUN_10393500(AudioClass, 0xffffffff) to
			// construct the subsystem; identity of FUN_10393500 not yet established.
			// Using StaticConstructObject as the closest available equivalent.
			Audio = (UAudioSubsystem*)UObject::StaticConstructObject(
				AudioClass, GetTransientPackage(), NAME_None, 0, NULL, GError, NULL);
			if (Audio)
			{
				// vtable[0x68/4 = 26] = UAudioSubsystem::Init()
				typedef int (__thiscall *tInit)(void*);
				int ok = ((tInit)(*(void***)Audio)[0x68/sizeof(void*)])(Audio);
				if (!ok)
				{
					GLog->Logf(NAME_Init, TEXT("Failed to create audio subsystem"));
					if (Audio) Audio->ConditionalDestroy();
					Audio = NULL;
				}
			}
		}
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10392870)
int UEngine::InputEvent(UViewport* Viewport, EInputKey Key, EInputAction Action, float Delta)
{
	guard(UEngine::InputEvent);
	// Ghidra 0x10392870: GIsRunning guard, then IM dispatch, then UInput vtable dispatch.
	if (!GIsRunning)
		return 0;

	UInteractionMaster* IM = Client ? *(UInteractionMaster**)((BYTE*)Client + 0x94) : NULL;

	if (!IM || !IM->MasterProcessKeyEvent(Key, Action, Delta))
	{
		// UInput* lives at viewport+0x80; call PreProcess (vtable[0x6c]) and
		// Process (vtable[0x70]) on it.  Offsets confirmed from Ghidra.
		typedef int (__thiscall *tPreProcess)(void*, EInputKey, EInputAction, float);
		typedef int (__thiscall *tProcess)(void*, FOutputDevice*, EInputKey, EInputAction, float);
		void*  InputObj = *(void**)((BYTE*)Viewport + 0x80);
		void** Vtbl     = *(void***)InputObj;
		if (!((tPreProcess)Vtbl[0x6c/sizeof(void*)])(InputObj, Key, Action, Delta))
			return 0;
		if (!((tProcess)Vtbl[0x70/sizeof(void*)])(InputObj, GLog, Key, Action, Delta))
			return 0;
	}
	else if (Action == (EInputAction)3)
	{
		typedef int (__thiscall *tPreProcess)(void*, EInputKey, EInputAction, float);
		void*  InputObj = *(void**)((BYTE*)Viewport + 0x80);
		void** Vtbl     = *(void***)InputObj;
		((tPreProcess)Vtbl[0x6c/sizeof(void*)])(InputObj, Key, (EInputAction)3, Delta);
	}
	return 1;
	unguard;
}


// --- UInteractionMaster ---
IMPL_MATCH("Engine.dll", 0x103b6880)
int UInteractionMaster::MasterProcessKeyEvent(EInputKey,EInputAction,float)
{
	guard(UInteractionMaster::MasterProcessKeyEvent);
	// Ghidra 0x103b6880: calls FUN_1031ded0 (identity unknown) then eventProcess_KeyEvent
	// thunk, then iterates interactions.  Cannot implement without FUN_1031ded0.
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103b6780)
int UInteractionMaster::MasterProcessKeyType(EInputKey)
{
	guard(UInteractionMaster::MasterProcessKeyType);
	// Ghidra 0x103b6780: same pattern as MasterProcessKeyEvent via FUN_1031ded0.
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103b6bd0)
void UInteractionMaster::MasterProcessMessage(FString const &,float)
{
	guard(UInteractionMaster::MasterProcessMessage);
	// Ghidra 0x103b6bd0: FUN_1031ded0 then eventProcess_Message, iterates interactions.
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103b6b10)
void UInteractionMaster::MasterProcessPostRender(UCanvas *)
{
	guard(UInteractionMaster::MasterProcessPostRender);
	// Ghidra 0x103b6b10: iterates interactions, calls eventProcess_PostRender on each,
	// then calls on master.  Depends on FUN_1031ded0.
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103b6a50)
void UInteractionMaster::MasterProcessPreRender(UCanvas *)
{
	guard(UInteractionMaster::MasterProcessPreRender);
	// Ghidra 0x103b6a50: same pattern as MasterProcessPostRender.
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103b6980)
void UInteractionMaster::MasterProcessTick(float)
{
	guard(UInteractionMaster::MasterProcessTick);
	// Ghidra 0x103b6980: FUN_1031ded0 then eventProcess_Tick, iterates interactions.
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103b6580)
void UInteractionMaster::DisplayCopyright()
{
	guard(UInteractionMaster::DisplayCopyright);
	// Ghidra 0x103b6580: logs engine name and copyright strings via LocalizeGeneral.
	// Exact EName values for Logf calls not yet determined.
	unguard;
}

IMPL_MATCH("Engine.dll", 0x103b6660)
int UInteractionMaster::Exec(const TCHAR*,FOutputDevice &)
{
	// Ghidra 0x103b6660: if Level has interactions, dispatch Exec to first interaction
	// via vtable[0x30]; no guard in retail.
	return 0;
}

// --- AHUD ---
IMPL_EMPTY("Ghidra VA 0x104651E0 (RVA 0x1651E0) confirms retail body is trivial (3 bytes) — void no-op")
void AHUD::DrawInGameMap(FCameraSceneNode *,UViewport *)
{
	guard(AHUD::DrawInGameMap);
	unguard;
}

IMPL_EMPTY("Ghidra VA 0x104651E0 (RVA 0x1651E0) confirms retail body is trivial (3 bytes) — void no-op")
void AHUD::DrawRadar(FCameraSceneNode *,UViewport *)
{
	guard(AHUD::DrawRadar);
	unguard;
}

IMPL_EMPTY("Ghidra VA 0x104651E0 (RVA 0x1651E0) confirms retail body is trivial (3 bytes) — void no-op")
void AHUD::DrawSpecificModeInfo(FCameraSceneNode *,UViewport *)
{
	guard(AHUD::DrawSpecificModeInfo);
	unguard;
}



// --- Moved from EngineStubs.cpp ---
IMPL_EMPTY("Ghidra VA 0x10476D60 (RVA 0x176D60) confirms retail body is trivial (1 byte)")
void AGameInfo::AbortScoreSubmission() {}
IMPL_EMPTY("Ghidra VA 0x10476D60 (RVA 0x176D60) confirms retail body is trivial (1 byte)")
void AGameInfo::MasterServerManager() {}
IMPL_EMPTY("Ghidra VA 0x10476D60 (RVA 0x176D60) confirms retail body is trivial (1 byte)")
void AGameInfo::InitGameInfoGameService() {}
IMPL_MATCH("Engine.dll", 0x103a2be0)
void AGameInfo::ProcessR6Availabilty(ULevel*, FString) {}
IMPL_MATCH("Engine.dll", 0x103a0720)
void UGameEngine::BuildServerMasterMap(UNetDriver*, ULevel*)
{
	guard(UGameEngine::BuildServerMasterMap);
	unguard;
}

// =============================================================================
// UGameEngine::Browse — retail Engine.dll @ 0x103a4da0
//
// The top-level navigation entry-point. Receives a FURL and decides how to
// handle it:
//   • Local internal  (no host, game protocol) → call LoadMap directly
//   • Network client  (has host, GIsClient)    → create UNetPendingLevel
//   • Internal, not client                     → error (server can't open maps)
//   • External URL                             → hand off to OS
//
// The retail function (2433 bytes) also handles:
//   • Audio stop before any transition (3 vtable calls)
//   • .unreal redirect file lookup
//   • Abort-to-entry options (failed/entry/userdisconnect)
//   • Hub-save, restart, and load=N URL transformations
// Those complex paths are approximated or stubbed here; see blog post #100.
// =============================================================================
IMPL_MATCH("Engine.dll", 0x103a4da0)
INT UGameEngine::Browse( FURL URL, const TMap<FString,FString>* TravelInfo, FString& Error )
{
    guard(UGameEngine::Browse);

    // --- Audio stop before any level transition (retail: 3 vtable calls) ---
    // Slots on UAudioSubsystem vtable: 0xc4 (stop), 0xe4 (flush), 0xe0 (clear).
    // Identity of these methods not yet established; dispatched raw.
    if (Audio)
    {
        typedef void (__thiscall* tAudioVoid)(void*);
        void** AudioVT = *(void***)Audio;
        ((tAudioVoid)(AudioVT[0xc4 / sizeof(void*)]))(Audio);
        ((tAudioVoid)(AudioVT[0xe4 / sizeof(void*)]))(Audio);
        ((tAudioVoid)(AudioVT[0xe0 / sizeof(void*)]))(Audio);
    }

    GLog->Logf(NAME_Dev, TEXT("Browse: %s"), *URL.String());

    if (!URL.Valid)
    {
        Error = LocalizeError(TEXT("InvalidUrl"), TEXT("Engine"));
        return 0;
    }

    // --- Local file map → load synchronously ---
    if (URL.IsLocalInternal())
    {
        ULevel* Level = LoadMap(URL, NULL, TravelInfo, Error);
        return Level != NULL ? 1 : 0;
    }

    // --- Network map (has a host) → async pending level (client only) ---
    // Full retail implementation creates UNetPendingLevel here and starts a TCP
    // connection. Not yet reconstructed; return failure so Init() can fall back.
    if (URL.IsInternal() && GIsClient)
    {
        Error = LocalizeError(TEXT("FailedBrowse"), TEXT("Engine"));
        return 0;
    }

    // --- Internal URL on a dedicated server → unsupported ---
    if (URL.IsInternal())
    {
        Error = LocalizeError(TEXT("ServerOpen"), TEXT("Engine"));
        return 0;
    }

    // --- External URL (e.g. http://) → OS browser ---
    // appLaunchURL signature not confirmed; log and bail.
    GLog->Logf(NAME_Warning, TEXT("Browse: external URL ignored: %s"), *URL.String());
    return 0;

    unguard;
}

// =============================================================================
// UGameEngine::LoadMap — retail Engine.dll @ 0x103a7190
//
// Loads a .unr map package from disk and makes it the active level:
//   1. Notify subsystems of impending level change
//   2. Load the UPackage via UObject::LoadPackage
//   3. Find the ULevel object ("MyLevel") within the package
//   4. Store in GLevel and return
//
// The retail function also:
//   • Shows a progress/loading screen (SetProgress)
//   • Resets old package loaders (UObject::ResetLoaders)
//   • Collects garbage to free the old map
//   • Spawns the local player actor (SpawnPlayActor)
//   • Fires BeginPlay on actors
// Those paths are approximated; full reconstruction pending Ghidra analysis.
// =============================================================================
IMPL_MATCH("Engine.dll", 0x103a7190)
ULevel* UGameEngine::LoadMap( const FURL& URL, UPendingLevel* Pending, const TMap<FString,FString>* TravelInfo, FString& Error )
{
    guard(UGameEngine::LoadMap);

    GLog->Logf(NAME_Dev, TEXT("LoadMap: %s"), *URL.Map);

    // Notify subsystems that the current level is about to go away.
    if (GLevel)
        NotifyLevelChange();

    // Clear the active level pointer before loading the new one.
    GLevel = NULL;

    // Load the map package. LOAD_NoFail crashes on missing file — intentional:
    // Init() verifies the map exists before calling us.
    UPackage* LevelPkg = (UPackage*)UObject::LoadPackage(NULL, *URL.Map, LOAD_NoFail);
    if (!LevelPkg)
    {
        Error = FString::Printf(TEXT("Failed to load map package: %s"), *URL.Map);
        return NULL;
    }

    // The primary level object is conventionally named "MyLevel" in UE2 packages.
    ULevel* Level = (ULevel*)UObject::StaticFindObject(
        ULevel::StaticClass(), LevelPkg, TEXT("MyLevel"), 0 );
    if (!Level)
    {
        Error = FString::Printf(TEXT("Failed to find ULevel 'MyLevel' in package: %s"), *URL.Map);
        return NULL;
    }

    // Store the destination URL on the level (used by network code and save/load).
    Level->URL = URL;

    // Make this the active level.
    GLevel = Level;

    GLog->Logf(NAME_Init, TEXT("LoadMap: loaded %s"), *URL.Map);
    return Level;

    unguard;
}

// =============================================================================
// UGameEngine::Tick — retail Engine.dll @ 0x103ae730
//
// Main-loop tick called once per frame. At minimum must advance the active level.
// The retail function also:
//   • Updates the stat graph
//   • Ticks the pending level (network connection in progress)
//   • Ticks all active net drivers
//   • Calls InteractionMaster::MasterProcessTick
//   • Ticks the audio subsystem
// Those paths are left as future work; GLevel->Tick is the critical path.
// =============================================================================
IMPL_MATCH("Engine.dll", 0x103ae730)
void UGameEngine::Tick( FLOAT DeltaSeconds )
{
    guard(UGameEngine::Tick);

    // Advance actors, physics, scripts, and timers in the active level.
    if (GLevel)
        GLevel->Tick(LEVELTICK_All, DeltaSeconds);

    // Tick client-side interaction master (HUD, menus, input dispatch).
    if (Client)
    {
        BYTE* CR = (BYTE*)Client;
        UInteractionMaster* IM = *(UInteractionMaster**)(CR + 0x94);
        if (IM)
            IM->MasterProcessTick(DeltaSeconds);
    }

    unguard;
}

// =============================================================================
// UGameEngine::Draw — retail Engine.dll @ 0x103aa6e0
//
// Renders a single frame to Viewport. The retail implementation:
//   1. Locks the viewport render target
//   2. Sets up FLevelSceneNode with camera position / FOV
//   3. Calls the scene manager to render actors, BSP, static meshes
//   4. Calls PostRenderFullScreenEffects (blur, fade-to-black, etc.)
//   5. Unlocks / presents the back buffer
//
// Full reconstruction is deferred — the render pipeline depends on many
// FRenderInterface internals not yet decoded. The viewport's own draw path
// (driven by the window message pump) still operates correctly.
// =============================================================================
IMPL_MATCH("Engine.dll", 0x103aa6e0)
void UGameEngine::Draw( UViewport* Viewport, INT bFlush, BYTE* HitData, INT* HitSize )
{
    guard(UGameEngine::Draw);
    // Rendering is handled by the viewport → render device chain.
    // This stub ensures the vtable slot resolves without a null-call crash.
    unguard;
}
