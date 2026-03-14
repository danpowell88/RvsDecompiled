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
	UPrimitive virtual function stubs.
	The vtable requires definitions for all declared virtuals.
-----------------------------------------------------------------------------*/

void UPrimitive::Serialize( FArchive& Ar )
{
	UObject::Serialize( Ar );
}
INT UPrimitive::PointCheck( FCheckResult& Result, AActor* Owner, FVector Location, FVector Extent, DWORD ExtraNodeFlags )
{ return 0; }
INT UPrimitive::LineCheck( FCheckResult& Result, AActor* Owner, FVector End, FVector Start, FVector Extent, DWORD ExtraNodeFlags, DWORD ExtraFlags )
{ return 0; }
FBox UPrimitive::GetRenderBoundingBox( const AActor* Owner )
{ return FBox(0); }
FSphere UPrimitive::GetRenderBoundingSphere( const AActor* Owner )
{ return FSphere(0); }
FBox UPrimitive::GetCollisionBoundingBox( const AActor* Owner ) const
{ return FBox(0); }
INT UPrimitive::UseCylinderCollision( const AActor* Owner )
{ return 0; }
void UPrimitive::Illuminate( AActor* Owner, INT bDynamic )
{}
FVector UPrimitive::GetEncroachExtent( AActor* Owner )
{
	// Retail (37b, RVA 0xF78E0): cylindrical half-extents — uses CollisionRadius
	// for both X and Y, and CollisionHeight for Z.
	// CollisionRadius at Owner+0xF8, CollisionHeight at Owner+0xFC.
	FLOAT r = *(FLOAT*)((BYTE*)Owner + 0xF8);
	FLOAT h = *(FLOAT*)((BYTE*)Owner + 0xFC);
	return FVector(r, r, h);
}
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

/*-----------------------------------------------------------------------------
	FName event/callback tokens.
	These are used by eventX() thunks to call UnrealScript event handlers.
	Each name is registered at package-load time and used for
	ProcessEvent( FindFunctionChecked(ENGINE_Xxx), &Parms ).
-----------------------------------------------------------------------------*/

#define NAMES_ONLY
#define AUTOGENERATE_NAME(name) ENGINE_API FName ENGINE_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name) IMPLEMENT_FUNCTION(cls,idx,name)
#include "EngineClasses.h"
#undef AUTOGENERATE_FUNCTION
#undef AUTOGENERATE_NAME
#undef NAMES_ONLY

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/

// =============================================================================
// UGameEngine (moved from EngineClassImpl.cpp)
// =============================================================================

// UGameEngine
// =============================================================================

INT UGameEngine::Exec( const TCHAR* Cmd, FOutputDevice& Ar ) { return Super::Exec( Cmd, Ar ); }
void UGameEngine::Destroy() { Super::Destroy(); }
void UGameEngine::Serialize( FArchive& Ar ) { Super::Serialize( Ar ); }
void UGameEngine::Tick( FLOAT DeltaSeconds ) {}
void UGameEngine::UpdateConnectingMessage() {}
void UGameEngine::Init() {}
void UGameEngine::Exit() {}
void UGameEngine::Draw( UViewport* Viewport, INT bFlush, BYTE* HitData, INT* HitSize ) {}
void UGameEngine::MouseDelta( UViewport* Viewport, DWORD Buttons, FLOAT DX, FLOAT DY ) {}
void UGameEngine::MousePosition( UViewport* Viewport, DWORD Buttons, FLOAT X, FLOAT Y ) {}
void UGameEngine::MouseWheel( UViewport* Viewport, DWORD Buttons, INT Delta ) {}
void UGameEngine::Click( UViewport* Viewport, DWORD Buttons, FLOAT X, FLOAT Y ) {}
void UGameEngine::UnClick( UViewport* Viewport, DWORD Buttons, INT MouseX, INT MouseY ) {}
void UGameEngine::SetClientTravel( UPlayer* Viewport, const TCHAR* NextURL, INT bItems, ETravelType TravelType ) {}
INT UGameEngine::ChallengeResponse( INT Challenge ) {
	// Retail: 30b. Mixes high/low halfwords and multiplies by a prime to produce the token.
	// Formula: ((Challenge >> 16) ^ (Challenge * 237) ^ (Challenge << 16)) ^ 0x93FE92CE
	return ((Challenge >> 16) ^ (Challenge * 237) ^ (Challenge << 16)) ^ 0x93FE92CE;
}
FLOAT UGameEngine::GetMaxTickRate() { return 0.0f; }
void UGameEngine::SetProgress( const TCHAR* Str1, const TCHAR* Str2, FLOAT Seconds ) {}
INT UGameEngine::Browse( FURL URL, const TMap<FString,FString>* TravelInfo, FString& Error ) { return 0; }
ULevel* UGameEngine::LoadMap( const FURL& URL, UPendingLevel* Pending, const TMap<FString,FString>* TravelInfo, FString& Error ) { return NULL; }
void UGameEngine::SaveGame( INT Position ) {}
void UGameEngine::CancelPending() {}
void UGameEngine::PaintProgress( const FURL& URL ) {}
void UGameEngine::NotifyLevelChange() {}
void UGameEngine::FixUpLevel() {}

// =============================================================================

// ============================================================================
// FRotatorF implementations
// (moved from EngineStubs.cpp)
// ============================================================================

FRotatorF::FRotatorF(FRotator R) : Pitch((FLOAT)R.Pitch), Yaw((FLOAT)R.Yaw), Roll((FLOAT)R.Roll) {}
FRotatorF::FRotatorF(float InPitch, float InYaw, float InRoll) : Pitch(InPitch), Yaw(InYaw), Roll(InRoll) {}
FRotatorF::FRotatorF() {}
FRotator FRotatorF::Rotator() { return FRotator(appRound(Pitch), appRound(Yaw), appRound(Roll)); }
FRotatorF & FRotatorF::operator=(FRotatorF const & p0) { Pitch=p0.Pitch; Yaw=p0.Yaw; Roll=p0.Roll; return *this; }
FRotatorF FRotatorF::operator*(float p0) const { return FRotatorF(Pitch*p0, Yaw*p0, Roll*p0); }
FRotatorF FRotatorF::operator*=(float p0) { Pitch*=p0; Yaw*=p0; Roll*=p0; return *this; }
FRotatorF FRotatorF::operator+(FRotatorF p0) const { return FRotatorF(Pitch+p0.Pitch, Yaw+p0.Yaw, Roll+p0.Roll); }
FRotatorF FRotatorF::operator+=(FRotatorF p0) { Pitch+=p0.Pitch; Yaw+=p0.Yaw; Roll+=p0.Roll; return *this; }
FRotatorF FRotatorF::operator-(FRotatorF p0) const { return FRotatorF(Pitch-p0.Pitch, Yaw-p0.Yaw, Roll-p0.Roll); }
FRotatorF FRotatorF::operator-=(FRotatorF p0) { Pitch-=p0.Pitch; Yaw-=p0.Yaw; Roll-=p0.Roll; return *this; }
FVector FRotatorF::Vector()
{
	return FRotator(appRound(Pitch), appRound(Yaw), appRound(Roll)).Vector();
}

// ============================================================================
// FURL implementations
// (moved from EngineStubs.cpp)
// ============================================================================

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

FURL::FURL(const TCHAR* Filename) {
	Protocol = DefaultProtocol;
	Host     = DefaultHost;
	Port     = DefaultPort;
	Map      = Filename ? FString(Filename) : DefaultMap;
	Portal   = DefaultPortal;
	Valid    = 1;
}

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

void FURL::LoadURLConfig(const TCHAR* Section, const TCHAR* Filename) {
	TCHAR Buffer[32000];
	GConfig->GetSection( Section, Buffer, ARRAY_COUNT(Buffer), Filename );
	const TCHAR* Ptr = Buffer;
	while( *Ptr ) {
		AddOption( Ptr );
		Ptr += appStrlen(Ptr) + 1;
	}
}

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

int FURL::HasOption(const TCHAR* Test) const {
	for( INT i=0; i<Op.Num(); i++ )
		if( appStricmp(*Op(i),Test)==0 )
			return 1;
	return 0;
}

int FURL::IsInternal() const {
	return Protocol == DefaultProtocol;
}

int FURL::IsLocalInternal() const {
	return IsInternal() && Host.Len()==0;
}

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

const TCHAR* FURL::GetOption(const TCHAR* Match, const TCHAR* Default) const {
	for( INT i=0; i<Op.Num(); i++ )
		if( appStrnicmp(*Op(i),Match,appStrlen(Match))==0 )
			return *Op(i) + appStrlen(Match);
	return Default;
}
