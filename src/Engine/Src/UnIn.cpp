/*=============================================================================
	UnIn.cpp: Input subsystem (UInputPlanning)
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/
#pragma optimize("", off)

// Placement new for placement-new stubs in this TU.
#pragma warning(push)
#pragma warning(disable: 4291)
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EnginePrivate.h"
#include "EngineDecls.h"

// --- UInputPlanning ---
const TCHAR* UInputPlanning::StaticConfigName()
{
	// Retail: 6b. Returns same hardcoded pointer as UInput::StaticConfigName = L"User".
	return TEXT("User");
}

void UInputPlanning::StaticInitInput()
{
	guard(UInputPlanning::StaticInitInput);
	// TODO: Full UInput property schema registration (Alias struct + properties).
	// Ghidra 0xb47c0 ?StaticInitInput@UInput@@SAXXZ — builds Alias UStruct with
	// FName "Alias" and FString "Command" properties, then registers "Aliases"
	// array property on UInput. Called once at engine startup.
	unguard;
}


// =============================================================================
// UInput (moved from EngineClassImpl.cpp)
// =============================================================================

// UInput
// =============================================================================

INT UInput::Exec( const TCHAR* Cmd, FOutputDevice& Ar ) { return 0; }
void UInput::Serialize( FArchive& Ar ) { Super::Serialize( Ar ); }
void UInput::Init( UViewport* InViewport ) {}
void UInput::ReadInput( FLOAT DeltaSeconds, FOutputDevice& Ar ) {}
void UInput::ResetInput() {}
BYTE UInput::GetKey( const TCHAR* KeyName ) { return 0; }
void UInput::SetKey( const TCHAR* KeyName ) {}
FString UInput::GetActionKey( BYTE Key ) { return FString(); }
BYTE* UInput::FindButtonName( AActor* Actor, const TCHAR* ButtonName ) const { return NULL; }
FLOAT* UInput::FindAxisName( AActor* Actor, const TCHAR* AxisName ) const { return NULL; }
void UInput::ExecInputCommands( const TCHAR* Cmd, FOutputDevice& Ar ) {}
BYTE UInput::KeyDown( INT Key )
{
	BYTE* KeyDownMap = (BYTE*)this + 0xEB4;
	if (Key < 0)
		return KeyDownMap[0];
	if (Key > 0xFD)
		Key = 0xFE;
	return KeyDownMap[Key];
}
void UInput::StaticConstructor() {}

// =============================================================================
