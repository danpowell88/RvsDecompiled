/*=============================================================================
	UnIn.cpp: Input subsystem (UInputPlanning)
	Reconstructed for Ravenshield decompilation project.
=============================================================================*/
#pragma optimize("", off)

// Placement new for placement-new stubs in this TU.
#include "EnginePrivate.h"
#pragma warning(push)
#pragma warning(disable: 4291)
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)

#include "EngineDecls.h"

// --- UInputPlanning ---
IMPL_MATCH("Engine.dll", 0x103116d0)
const TCHAR* UInputPlanning::StaticConfigName()
{
	// Retail: 6b. Returns same hardcoded pointer as UInput::StaticConfigName = L"User".
	return TEXT("User");
}

IMPL_EMPTY("Alias UStruct property registration not yet implemented; requires Alias struct header support")
void UInputPlanning::StaticInitInput()
{
	guard(UInputPlanning::StaticInitInput);
	// TODO: implement UInputPlanning::StaticInitInput (retail 0xb47c0: registers Alias UStruct with FName/FString properties on UInput)
	// GHIDRA REF: 0xb47c0 ?StaticInitInput@UInput@@SAXXZ — builds Alias UStruct with
	// FName "Alias" and FString "Command" properties, then registers "Aliases"
	// array property on UInput. Called once at engine startup.
	// The property registration requires CPP_PROPERTY macros to work correctly
	// with the Alias struct layout, which is not yet part of the reconstructed headers.
	unguard;
}


// =============================================================================
// UInput (moved from EngineClassImpl.cpp)
// =============================================================================

// UInput
// =============================================================================

IMPL_TODO("stub returning 0; retail is 1757-byte command dispatch (0x103b4bd0)")
INT UInput::Exec( const TCHAR* Cmd, FOutputDevice& Ar ) { return 0; }
IMPL_MATCH("Engine.dll", 0x103b4b40)
void UInput::Serialize( FArchive& Ar )
{
	Super::Serialize( Ar );
	// Serialize the UViewport* stored at offset 0xEA8
	Ar << *(UViewport**)((BYTE*)this + 0xEA8);
}
IMPL_EMPTY("viewport initialization no-op")
void UInput::Init( UViewport* InViewport ) {}
IMPL_EMPTY("input polling no-op")
void UInput::ReadInput( FLOAT DeltaSeconds, FOutputDevice& Ar ) {}
IMPL_EMPTY("input state reset no-op")
void UInput::ResetInput() {}
IMPL_MATCH("Engine.dll", 0x103b4130)
BYTE UInput::GetKey( const TCHAR* KeyName )
{
	// Scan bindings array (FString[255] at offset 0x2B0, 0xC bytes each)
	// Returns the key index (0-254) whose binding string matches KeyName,
	// or 0 if not found. Retail exits on first match or after 255 slots.
	BYTE found = 0;
	for (BYTE i = 0; i != 0xFF && found == 0; i++)
	{
		FString& binding = *(FString*)((BYTE*)this + i * 0xC + 0x2B0);
		if (appStricmp(KeyName, *binding) == 0)
			found = i;
	}
	return found;
}
IMPL_EMPTY("key assignment no-op")
void UInput::SetKey( const TCHAR* KeyName ) {}
IMPL_MATCH("Engine.dll", 0x103b4350)
FString UInput::GetActionKey( BYTE Key ) { return *(FString*)((BYTE*)this + Key * 0xC + 0x2B0); }
IMPL_TODO("stub returning NULL; retail 300-byte FName property search (0x103b5870)")
BYTE* UInput::FindButtonName( AActor* Actor, const TCHAR* ButtonName ) const { return NULL; }
IMPL_TODO("stub returning NULL; retail 300-byte FName property search (0x103b59d0)")
FLOAT* UInput::FindAxisName( AActor* Actor, const TCHAR* AxisName ) const { return NULL; }
IMPL_EMPTY("input command execution no-op")
void UInput::ExecInputCommands( const TCHAR* Cmd, FOutputDevice& Ar ) {}
IMPL_MATCH("Engine.dll", 0x1031c190)
BYTE UInput::KeyDown( INT Key )
{
	BYTE* KeyDownMap = (BYTE*)this + 0xEB4;
	if (Key < 0)
		return KeyDownMap[0];
	if (Key > 0xFD)
		Key = 0xFE;
	return KeyDownMap[Key];
}
IMPL_EMPTY("UInput static constructor no-op")
void UInput::StaticConstructor() {}

// =============================================================================

// --- Moved from EngineStubs.cpp ---
IMPL_MATCH("Engine.dll", 0x103b40e0)
INT UInput::PreProcess(EInputKey Key, EInputAction Action, FLOAT Delta)
{
	// KeyDownMap at offset 0xEB4 from this (Ghidra-verified).
	BYTE* KeyDownMap = (BYTE*)this + 0xEB4;
	if (Action == IST_Press)
	{
		if (KeyDownMap[Key] == 0)
		{
			KeyDownMap[Key] = 1;
			return 1;
		}
	}
	else if (Action == IST_Release)
	{
		if (KeyDownMap[Key] != 0)
		{
			KeyDownMap[Key] = 0;
			return 1;
		}
	}
	else
	{
		return 1;
	}
	return 0;
}
IMPL_MATCH("Engine.dll", 0x103b5300)
INT UInput::Process(FOutputDevice& Ar, EInputKey Key, EInputAction Action, FLOAT Delta)
{
	if ((INT)Key < 0 || (INT)Key >= 0xFF)
		appFailAssert("iKey>=0&&iKey<IK_MAX", ".\\UnIn.cpp", 0x1E8);
	// Bindings array at offset 0x2B0 (FString[IK_MAX], 0xC each)
	FString& Binding = *(FString*)((BYTE*)this + (INT)Key * 0xC + 0x2B0);
	if (Binding.Len())
	{
		*(EInputAction*)((BYTE*)this + 0xEAC) = Action;
		*(FLOAT*)((BYTE*)this + 0xEB0) = Delta;
		Exec(*Binding, Ar);
		*(INT*)((BYTE*)this + 0xEAC) = 0;
		*(INT*)((BYTE*)this + 0xEB0) = 0;
		return 1;
	}
	return 0;
}
IMPL_EMPTY("direct axis injection no-op")
void UInput::DirectAxis(EInputKey Key, FLOAT Value, FLOAT Delta) {}

// ?GetKeyName@UInput@@QBEPBGHHPAVEInputKey@@@Z   (returns display name for a virtual-key code)
// Key names match the DefUser.ini binding keys (retail verified).
// Letters A-Z and digits 0-9 are their single character.
// Numpad, Function keys and special keys use the standard Unreal names.
// Unrecognised codes return "Unknown%02X" format (e.g. "Unknown3A").
IMPL_TODO("static lookup table; retail uses FName property array at +0xea8 (0x103b55d0)")
const TCHAR* UInput::GetKeyName(EInputKey Key) const
{
	static TCHAR GenBuf[16]; // used for dynamically generated names
	DWORD k = (DWORD)Key;

	// A–Z  (0x41–0x5A)
	if (k >= 0x41 && k <= 0x5A) { GenBuf[0]=(TCHAR)k; GenBuf[1]=0; return GenBuf; }
	// 0–9  (0x30–0x39)
	if (k >= 0x30 && k <= 0x39) { GenBuf[0]=(TCHAR)k; GenBuf[1]=0; return GenBuf; }
	// NumPad 0–9  (0x60–0x69)
	if (k >= 0x60 && k <= 0x69)
		{ appSprintf(GenBuf, TEXT("NumPad%c"), TEXT('0')+(k-0x60)); return GenBuf; }
	// F1–F24  (0x70–0x87)
	if (k >= 0x70 && k <= 0x87)
		{ appSprintf(GenBuf, TEXT("F%d"), (INT)(k - 0x6F)); return GenBuf; }
	// Joy1–16 (0xC8–0xD7)
	if (k >= 0xC8 && k <= 0xD7)
		{ appSprintf(GenBuf, TEXT("Joy%d"), (INT)(k - 0xC7)); return GenBuf; }

	static const struct { DWORD Code; const TCHAR* Name; } Table[] =
	{
		{ 0x01, TEXT("LeftMouse")      }, { 0x02, TEXT("RightMouse")      },
		{ 0x03, TEXT("Cancel")         }, { 0x04, TEXT("MiddleMouse")      },
		{ 0x08, TEXT("Backspace")      }, { 0x09, TEXT("Tab")              },
		{ 0x0D, TEXT("Enter")          }, { 0x10, TEXT("Shift")            },
		{ 0x11, TEXT("Ctrl")           }, { 0x12, TEXT("Alt")              },
		{ 0x13, TEXT("Pause")          }, { 0x14, TEXT("CapsLock")         },
		{ 0x1B, TEXT("Escape")         }, { 0x20, TEXT("Space")            },
		{ 0x21, TEXT("PageUp")         }, { 0x22, TEXT("PageDown")         },
		{ 0x23, TEXT("End")            }, { 0x24, TEXT("Home")             },
		{ 0x25, TEXT("Left")           }, { 0x26, TEXT("Up")               },
		{ 0x27, TEXT("Right")          }, { 0x28, TEXT("Down")             },
		{ 0x29, TEXT("Select")         }, { 0x2A, TEXT("Print")            },
		{ 0x2B, TEXT("Execute")        }, { 0x2C, TEXT("PrintScrn")        },
		{ 0x2D, TEXT("Insert")         }, { 0x2E, TEXT("Delete")           },
		{ 0x2F, TEXT("Help")           },
		{ 0x6A, TEXT("GreyStar")       }, { 0x6B, TEXT("GreyPlus")         },
		{ 0x6C, TEXT("Separator")      }, { 0x6D, TEXT("GreyMinus")        },
		{ 0x6E, TEXT("NumPadPeriod")   }, { 0x6F, TEXT("GreySlash")        },
		{ 0x90, TEXT("NumLock")        }, { 0x91, TEXT("ScrollLock")       },
		{ 0xA0, TEXT("LShift")         }, { 0xA1, TEXT("RShift")           },
		{ 0xA2, TEXT("LControl")       }, { 0xA3, TEXT("RControl")         },
		{ 0xBA, TEXT("Semicolon")      }, { 0xBB, TEXT("Equals")           },
		{ 0xBC, TEXT("Comma")          }, { 0xBD, TEXT("Minus")            },
		{ 0xBE, TEXT("Period")         }, { 0xBF, TEXT("Slash")            },
		{ 0xC0, TEXT("Tilde")          }, { 0xDB, TEXT("LeftBracket")      },
		{ 0xDC, TEXT("Backslash")      }, { 0xDD, TEXT("RightBracket")     },
		{ 0xDE, TEXT("Quote")          },
		{ 0xE0, TEXT("JoyX")           }, { 0xE1, TEXT("JoyY")             },
		{ 0xE2, TEXT("JoyZ")           }, { 0xE3, TEXT("JoyR")             },
		{ 0xE4, TEXT("MouseX")         }, { 0xE5, TEXT("MouseY")           },
		{ 0xE6, TEXT("MouseZ")         }, { 0xE7, TEXT("MouseW")           },
		{ 0xE8, TEXT("JoyU")           }, { 0xE9, TEXT("JoyV")             },
		{ 0xEC, TEXT("MouseWheelUp")   }, { 0xED, TEXT("MouseWheelDown")   },
	};
	for (INT i = 0; i < ARRAY_COUNT(Table); i++)
		if (Table[i].Code == k) return Table[i].Name;

	appSprintf(GenBuf, TEXT("Unknown%02X"), k & 0xFF);
	return GenBuf;
}

// ?FindKeyName@UInput@@QBEHPBGAAHPAVEInputKey@@@Z (reverse lookup: name → EInputKey)
IMPL_TODO("iterates GetKeyName; retail uses FName IK_-prefix lookup (0x103b5df0)")
INT UInput::FindKeyName(const TCHAR* KeyName, EInputKey& Key) const
{
	for (INT i = 1; i < 256; i++)
	{
		if (!appStricmp(GetKeyName((EInputKey)i), KeyName))
		{
			Key = (EInputKey)i;
			return 1;
		}
	}
	return 0;
}
IMPL_MATCH("Engine.dll", 0x10311730)
void UInput::SetInputAction(EInputAction Action, FLOAT Delta)
{
	*(EInputAction*)((BYTE*)this + 0xEAC) = Action;
	*(FLOAT*)((BYTE*)this + 0xEB0) = Delta;
}
IMPL_MATCH("Engine.dll", 0x10311750)
EInputAction UInput::GetInputAction()
{
	return *(EInputAction*)((BYTE*)this + 0xEAC);
}
IMPL_MATCH("Engine.dll", 0x10311760)
FLOAT UInput::GetInputDelta()
{
	return *(FLOAT*)((BYTE*)this + 0xEB0);
}
IMPL_MATCH("Engine.dll", 0x103116d0)
const TCHAR* UInput::StaticConfigName() { return TEXT("User"); }
IMPL_EMPTY("UInput static input initialization no-op")
void UInput::StaticInitInput() {}
