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

IMPL_MATCH("Engine.dll", 0x103b44a0)
void UInputPlanning::StaticInitInput()
{
	guard(UInputPlanning::StaticInitInput);
	// Ghidra 0x103b44a0 (591b): builds Alias UStruct with FName+FString properties,
	// registers Aliases TArray<> on UInputPlanning, populates per-key UStrProperty
	// from EInputKey enum entries.
	FArchive DummyAr;

	// Build Alias struct: { FName Alias; FString Command; } = 0x10 bytes
	UStruct* AliasStruct = new(NULL, TEXT("Alias"), RF_Public) UStruct((UStruct*)NULL);
	AliasStruct->SetPropertiesSize(0x10);
	new(AliasStruct, TEXT("Alias"), RF_Public)
		UNameProperty(EC_CppProperty, 0, TEXT(""), CPF_Config);
	new(AliasStruct, TEXT("Command"), RF_Public)
		UStrProperty(EC_CppProperty, 4, TEXT(""), CPF_Config);
	AliasStruct->Link(DummyAr, 1);

	// Register Aliases array (40 entries at class offset 0x30, stride 0x10)
	UStructProperty* AliasProp = new(StaticClass(), TEXT("Aliases"), RF_Public)
		UStructProperty(EC_CppProperty, 0x30, TEXT("Aliases"), CPF_Config, AliasStruct);
	*(INT*)((BYTE*)AliasProp + 0x38) = 0x28; // ArrayDim = 40

	// Find EInputKey enum in UInteractions class
	UEnum* InputKeyEnum = (UEnum*)UObject::StaticFindObjectChecked(
		UEnum::StaticClass(),
		UInteractions::StaticClass(),
		TEXT("EInputKey"), 0);

	// For each valid key (0..254), register a UStrProperty named after the key
	// at offset key*0xC + 0x2B0 (per-key binding string)
	FName* EnumNames = *(FName**)((BYTE*)InputKeyEnum + 0x38);
	for (INT i = 0; i <= 0xFE; i++)
	{
		if (EnumNames[i] != NAME_None)
		{
			const TCHAR* KeyStr = *EnumNames[i];
			new(StaticClass(), KeyStr + 3, RF_Public) // skip "IK_" prefix
				UStrProperty(EC_CppProperty, i * 0xC + 0x2B0, TEXT("RawKeys"), CPF_Config);
		}
	}

	// Link and load config
	StaticClass()->Link(DummyAr, 1);
	UObject* DefaultObj = StaticClass()->GetDefaultObject();
	DefaultObj->LoadConfig(0, NULL, NULL);
	unguard;
}


// =============================================================================
// UInput (moved from EngineClassImpl.cpp)
// =============================================================================

namespace
{
	enum { INPUT_PROPERTY_CACHE_TAG = 0x1F };
	enum { CPF_InputFlag = 0x00000004 };
	enum { INPUT_ALIAS_COUNT = 40 };

	struct FInputPropertyCache
	{
		INT Count;
		UProperty* Properties[1];
	};

	struct FInputAlias
	{
		FName Alias;
		FString Command;
	};

	// Re-entrancy guard for alias dispatch (DAT_106717e8 in retail binary).
	// Prevents infinite loops when an alias command recursively triggers another alias.
	static UBOOL GInputAliasInExec = 0;

	static FInputPropertyCache* GetInputPropertyCache(UClass* Class, FMemCache::FCacheItem*& Item)
	{
		QWORD CacheId = INPUT_PROPERTY_CACHE_TAG;
		if (Class)
		{
			CacheId += (QWORD)Class->GetIndex() * 0x100;
		}

		FInputPropertyCache* Cache = (FInputPropertyCache*)GCache.Get(CacheId, Item, 8);
		if (!Cache)
		{
			INT Count = 0;
			if (Class)
			{
				for (TFieldIterator<UProperty> It(Class); It; ++It)
				{
					if (It->PropertyFlags & CPF_InputFlag)
					{
						++Count;
					}
				}
			}

			INT CacheSize = sizeof(FInputPropertyCache);
			if (Count > 1)
			{
				CacheSize += (Count - 1) * sizeof(UProperty*);
			}

			Cache = (FInputPropertyCache*)GCache.Create(CacheId, Item, CacheSize, 8);
			check(Cache);
			Cache->Count = Count;

			if (Class)
			{
				INT Index = 0;
				for (TFieldIterator<UProperty> It(Class); It; ++It)
				{
					if (It->PropertyFlags & CPF_InputFlag)
					{
						Cache->Properties[Index++] = *It;
					}
				}
			}
		}

		return Cache;
	}
}

// UInput
// =============================================================================

// Ghidra 0x103b4bd0 (1757 bytes).  Handles BUTTON, PULSE, TOGGLE, AXIS, COUNT,
// KEYNAME, KEYBINDING, and alias dispatch.
//
// Layout notes (confirmed from Ghidra with 0x2C `this` adjustment — Exec is
// called through a secondary vtable slot at UInput+0x2C):
//   Viewport  = *(UViewport**)((BYTE*)this + 0xEA4)
//   Actor     = *(AActor**)  ((BYTE*)Viewport + 0x34)
//   ParentAct = *(AActor**)  ((BYTE*)Actor    + 0x3D8)
//   Aliases   = (FInputAlias*)((BYTE*)this + 0x30)  [40 × 16-byte entries]
//   InputAction: GetInputAction() / GetInputDelta()
//   DAT_106717e8 = GInputAliasInExec (re-entrancy guard)
//   Viewport+0xB4 = unknown float guard that blocks AXIS when positive
IMPL_MATCH("Engine.dll", 0x103b4bd0)
INT UInput::Exec( const TCHAR* Cmd, FOutputDevice& Ar )
{
	guard(UInput::Exec);

	const TCHAR* Str = Cmd;
	TCHAR Token[256];

	UViewport* Viewport = *(UViewport**)((BYTE*)this + 0xEA4);
	AActor*    Actor    = (Viewport ? *(AActor**)((BYTE*)Viewport + 0x34) : NULL);

	if( ParseCommand(&Str, TEXT("BUTTON")) )
	{
		if( Actor && ParseToken(Str, Token, 256, 0) )
		{
			BYTE* Button = FindButtonName(Actor, Token);
			if( !Button )
			{
				AActor* Parent = *(AActor**)((BYTE*)Actor + 0x3D8);
				if( Parent ) Button = FindButtonName(Parent, Token);
			}
			if( Button )
			{
				if( GetInputAction() != IST_Press ) return 1;
				*Button = 1;
				return 1;
			}
		}
		Ar.Log(TEXT("Bad Button command"));
		return 1;
	}
	else if( ParseCommand(&Str, TEXT("PULSE")) )
	{
		if( Actor && ParseToken(Str, Token, 256, 0) )
		{
			BYTE* Button = FindButtonName(Actor, Token);
			if( !Button )
			{
				AActor* Parent = *(AActor**)((BYTE*)Actor + 0x3D8);
				if( Parent ) Button = FindButtonName(Parent, Token);
			}
			if( Button )
			{
				if( GetInputAction() != IST_Press ) return 1;
				*Button = 1;
				return 1;
			}
		}
		Ar.Log(TEXT("Bad Button command"));
		return 1;
	}
	else if( ParseCommand(&Str, TEXT("TOGGLE")) )
	{
		if( Actor && ParseToken(Str, Token, 256, 0) )
		{
			BYTE* Button = FindButtonName(Actor, Token);
			if( Button )
			{
				if( GetInputAction() != IST_Press ) return 1;
				*Button ^= 0x80;
				return 1;
			}
		}
		Ar.Log(TEXT("Bad Toggle command"));
		return 1;
	}
	else if( ParseCommand(&Str, TEXT("AXIS")) )
	{
		// Ghidra: skip AXIS processing when Viewport+0xB4 (unknown float) > 0.
		if( Viewport && *(FLOAT*)((BYTE*)Viewport + 0xB4) > 0.0f )
			return 1;

		if( Actor && ParseToken(Str, Token, 256, 0) )
		{
			FLOAT* Axis = FindAxisName(Actor, Token);
			if( !Axis )
			{
				Ar.Log(TEXT("Bad Axis command"));
				return 1;
			}

			FLOAT Speed     = 1.0f;
			FLOAT SpeedBase = 0.0f;
			FLOAT DeadZone  = 0.0f;
			INT   Invert    = 1;

			Parse(Str, TEXT("SPEED="),     Speed);
			Parse(Str, TEXT("SPEEDBASE="), SpeedBase);
			Parse(Str, TEXT("INVERT="),    Invert);
			Parse(Str, TEXT("DEADZONE="),  DeadZone);

			// Detect mouse axes: names starting with "AMOUSEY" or "AMOUSEX".
			// Ghidra: InStr at pos 0 distinguishes starts-with from substring.
			FString CapsToken = FString(Token).Caps();
			UBOOL bIsMouse = (CapsToken.InStr(TEXT("AMOUSEY"), 0) == 0) ||
			                 (CapsToken.InStr(TEXT("AMOUSEX"), 0) == 0);

			if( bIsMouse )
			{
				Invert = Abs(Invert);
				Speed  = 2.0f;
			}
			else if( SpeedBase > 0.0f )
			{
				// Deadzone normalisation.  Ghidra uses Speed as the raw input
				// magnitude here (compiler reuses the stack slot).
				if( Abs(Speed) <= DeadZone )
					return 1;
				FLOAT Norm = (Speed <= 0.0f)
					? -((-Speed - DeadZone) / (1.0f - DeadZone))
					:  ( (Speed - DeadZone) / (1.0f - DeadZone));
				*Axis += (FLOAT)Invert * GetInputDelta() * SpeedBase * Norm;
				return 1;
			}

			EInputAction Action = GetInputAction();
			if( Action == IST_Axis )
			{
				*Axis += (FLOAT)Invert * GetInputDelta() * Speed * 0.01f;
			}
			else if( Action == IST_Hold )
			{
				*Axis += (FLOAT)Invert * GetInputDelta() * Speed;
			}
		}
		return 1;
	}
	else if( ParseCommand(&Str, TEXT("COUNT")) )
	{
		if( Actor && ParseToken(Str, Token, 256, 0) )
		{
			BYTE* Button = FindButtonName(Actor, Token);
			if( Button )
			{
				(*Button)++;
				return 1;
			}
		}
		Ar.Log(TEXT("Bad Count command"));
		return 1;
	}
	else if( ParseCommand(&Str, TEXT("KEYNAME")) )
	{
		INT KeyCode = appAtoi(Str);
		Ar.Log(GetKeyName((EInputKey)KeyCode));
		return 1;
	}
	else if( ParseCommand(&Str, TEXT("KEYBINDING")) )
	{
		EInputKey Key = (EInputKey)0;
		if( FindKeyName(Str, Key) )
			Ar.Log(*GetActionKey(Key));
		return 1;
	}
	else
	{
		// Alias dispatch.  GInputAliasInExec prevents infinite recursion when
		// an alias command itself contains an alias (DAT_106717e8 in retail).
		if( !GInputAliasInExec && ParseToken(Str, Token, 256, 0) )
		{
			FName AliasName(Token, FNAME_Find);
			if( AliasName != NAME_None )
			{
				FInputAlias* Aliases = (FInputAlias*)((BYTE*)this + 0x30);
				for( INT i = 0; i < INPUT_ALIAS_COUNT; i++ )
				{
					if( Aliases[i].Alias == AliasName )
					{
						GInputAliasInExec = 1;
						Exec(*Aliases[i].Command, Ar);
						GInputAliasInExec = 0;
						return 1;
					}
				}
			}
		}
		return 0;
	}

	unguard;
}
IMPL_MATCH("Engine.dll", 0x103b4b40)
void UInput::Serialize( FArchive& Ar )
{
	Super::Serialize( Ar );
	// Serialize the UViewport* stored at offset 0xEA8
	Ar << *(UViewport**)((BYTE*)this + 0xEA8);
}
IMPL_MATCH("Engine.dll", 0x103b3f50)
void UInput::Init( UViewport* InViewport )
{
	guard(UInput::Init);
	*(UViewport**)((BYTE*)this + 0xEA4) = InViewport;
	ResetInput();
	GLog->Logf(NAME_Init, TEXT("Input system initialized for %s"), InViewport->GetName());

	// Retail stores 40 alias entries here as FName + FString pairs on a 0x10-byte stride.
	FInputAlias* Aliases = (FInputAlias*)((BYTE*)this + 0x30);
	for (INT Index = 0; Index < INPUT_ALIAS_COUNT; ++Index)
	{
		FString UpperCommand = Aliases[Index].Command.Caps();
		if (UpperCommand.InStr(TEXT("AXIS"), 0) != -1 && UpperCommand.InStr(TEXT("FIRE"), 0) != -1)
		{
			Aliases[Index].Command = TEXT("");
			Aliases[Index].Alias = FName(TEXT(")"), FNAME_Add);
		}
	}
	unguard;
}
IMPL_MATCH("Engine.dll", 0x103b5b30)
void UInput::ReadInput( FLOAT DeltaSeconds, FOutputDevice& Ar )
{
	guard(UInput::ReadInput);
	if (GIsRunning)
	{
		FMemCache::FCacheItem* Item = NULL;
		UViewport* Viewport = *(UViewport**)((BYTE*)this + 0xEA4);
		AActor* Actor = *(AActor**)((BYTE*)Viewport + 0x34);
		FInputPropertyCache* Cache = GetInputPropertyCache(Actor->GetClass(), Item);

		const UBOOL bProcessHeldKeys = !appIsNan(DeltaSeconds) && (DeltaSeconds != -1.0f);
		if (bProcessHeldKeys)
		{
			BYTE* KeyDownMap = (BYTE*)this + 0xEB4;
			for (INT Key = 0; Key < 0xFF; ++Key)
			{
				if (KeyDownMap[Key])
				{
					Process(*GLog, (EInputKey)Key, IST_Hold, DeltaSeconds);
				}
			}
		}

		const FLOAT Scale = bProcessHeldKeys ? (20.0f / DeltaSeconds) : 0.0f;
		for (INT Index = 0; Index < Cache->Count; ++Index)
		{
			UProperty* Property = Cache->Properties[Index];
			if (Property && Property->IsA(UFloatProperty::StaticClass()))
			{
				*(FLOAT*)((BYTE*)Actor + Property->Offset) *= Scale;
			}
		}

		Item->Unlock();
	}
	unguard;
}
IMPL_MATCH("Engine.dll", 0x103b5c90)
void UInput::ResetInput()
{
	guard(UInput::ResetInput);
	UViewport* Viewport = *(UViewport**)((BYTE*)this + 0xEA4);
	check(Viewport);

	BYTE* KeyDownMap = (BYTE*)this + 0xEB4;
	for (INT Key = 0; Key < 0xFF; ++Key)
	{
		KeyDownMap[Key] = 0;
	}

	AActor* Actor = *(AActor**)((BYTE*)Viewport + 0x34);
	for (TFieldIterator<UByteProperty> ItB(Actor->GetClass()); ItB; ++ItB)
	{
		if (ItB->PropertyFlags & CPF_InputFlag)
		{
			*(BYTE*)((BYTE*)Actor + ItB->Offset) = 0;
		}
	}

	for (TFieldIterator<UFloatProperty> ItF(Actor->GetClass()); ItF; ++ItF)
	{
		if (ItF->PropertyFlags & CPF_InputFlag)
		{
			*(FLOAT*)((BYTE*)Actor + ItF->Offset) = 0.0f;
		}
	}

	SetInputAction(IST_None, 0.0f);

	typedef void (__thiscall *FViewportUpdateInputFn)(UViewport*, INT, FLOAT);
	((FViewportUpdateInputFn)(*(DWORD*)Viewport + 0x90))(Viewport, 1, 0.0f);
	unguard;
}
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
IMPL_MATCH("Engine.dll", 0x103b41e0)
void UInput::SetKey( const TCHAR* KeyName )
{
	guard(UInput::SetKey);
	TCHAR Token[256];
	FString NewBinding;
	EInputKey Key = (EInputKey)0;

	if (ParseToken(KeyName, Token, 256, 0))
	{
		if (FindKeyName(Token, Key))
		{
			if (ParseToken(KeyName, Token, 256, 0))
			{
				NewBinding = Token;
			}
		}
	}

	if (NewBinding.Len() > 0)
	{
		for (BYTE i = 0; i != 0xFF; i++)
		{
			FStringNoInit& Binding = *(FStringNoInit*)((BYTE*)this + (DWORD)i * 0xC + 0x2B0);
			if (appStricmp(*NewBinding, *Binding) == 0)
			{
				Binding = TEXT("");
			}
		}
	}

	*(FStringNoInit*)((BYTE*)this + (INT)Key * 0xC + 0x2B0) = NewBinding;
	SaveConfig(CPF_Config, NULL);
	unguard;
}
IMPL_MATCH("Engine.dll", 0x103b4350)
FString UInput::GetActionKey( BYTE Key ) { return *(FString*)((BYTE*)this + Key * 0xC + 0x2B0); }
IMPL_MATCH("Engine.dll", 0x103b5870)
BYTE* UInput::FindButtonName( AActor* Actor, const TCHAR* ButtonName ) const
{
	guard(UInput::FindButtonName);
	check(*(UViewport**)((BYTE*)this + 0xEA4));
	check(Actor);

	FName Button(ButtonName, FNAME_Find);
	if (Button != NAME_None)
	{
		FMemCache::FCacheItem* Item = NULL;
		FInputPropertyCache* Cache = GetInputPropertyCache(Actor->GetClass(), Item);
		INT Index = 0;
		for (; Index < Cache->Count; ++Index)
		{
			UProperty* Property = Cache->Properties[Index];
			if (Property->GetFName() == Button && Property->IsA(UByteProperty::StaticClass()))
			{
				break;
			}
		}
		Item->Unlock();

		if (Index < Cache->Count)
		{
			return (BYTE*)Actor + Cache->Properties[Index]->Offset;
		}
	}

	return NULL;
	unguard;
}
IMPL_MATCH("Engine.dll", 0x103b59d0)
FLOAT* UInput::FindAxisName( AActor* Actor, const TCHAR* AxisName ) const
{
	guard(UInput::FindAxisName);
	check(*(UViewport**)((BYTE*)this + 0xEA4));
	check(Actor);

	FName Axis(AxisName, FNAME_Find);
	if (Axis != NAME_None)
	{
		FMemCache::FCacheItem* Item = NULL;
		FInputPropertyCache* Cache = GetInputPropertyCache(Actor->GetClass(), Item);
		INT Index = 0;
		for (; Index < Cache->Count; ++Index)
		{
			UProperty* Property = Cache->Properties[Index];
			if (Property->GetFName() == Axis && Property->IsA(UFloatProperty::StaticClass()))
			{
				break;
			}
		}
		Item->Unlock();

		if (Index < Cache->Count)
		{
			return (FLOAT*)((BYTE*)Actor + Cache->Properties[Index]->Offset);
		}
	}

	return NULL;
	unguard;
}
IMPL_MATCH("Engine.dll", 0x103b3e50)
void UInput::ExecInputCommands( const TCHAR* Cmd, FOutputDevice& Ar )
{
	guard(UInput::ExecInputCommands);
	TCHAR Line[256];
	UViewport* Viewport = *(UViewport**)((BYTE*)this + 0xEA4);
	const TCHAR* LineCmd;
	typedef INT (__thiscall* FExecDispatchFn)(void*, const TCHAR*, FOutputDevice&);

	do
	{
		while (1)
		{
			if (!ParseLine(&Cmd, Line, 256, 0))
				return;
			LineCmd = Line;
			if (*(EInputAction*)((BYTE*)this + 0xEAC) != IST_Press)
				break;
		DispatchViewport:
			((FExecDispatchFn)**(void***)((BYTE*)Viewport + 0x30))((BYTE*)Viewport + 0x30, LineCmd, Ar);
		}
		if (*(EInputAction*)((BYTE*)this + 0xEAC) == IST_Release)
		{
			if (ParseCommand(&LineCmd, TEXT("OnRelease")))
				goto DispatchViewport;
		}
		((FExecDispatchFn)**(void***)((BYTE*)this + 0x2C))((BYTE*)this + 0x2C, LineCmd, Ar);
	} while (1);
	unguard;
}
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
IMPL_MATCH("Engine.dll", 0x103b5400)
void UInput::DirectAxis(EInputKey Key, FLOAT Value, FLOAT Delta)
{
	guard(UInput::DirectAxis);
	FString Remaining = *(FString*)((BYTE*)this + (INT)Key * 0xC + 0x2B0);
	FString Left = Remaining;

	while (Remaining.Len())
	{
		Left = Remaining;
		TCHAR* Delim = appStrchr(*Left, TEXT('|'));
		if (!Delim)
		{
			Remaining = TEXT("");
		}
		else
		{
			*Delim = 0;
			Remaining = Delim + 1;
		}

		FString Command = FString::Printf(TEXT("%s Speed=%f"), *Left, (DOUBLE)Value);
		SetInputAction(IST_Hold, Delta);
		ExecInputCommands(*Command, *GLog);
		SetInputAction(IST_None, 0.0f);
	}
	unguard;
}

// Retail reads the EInputKey FName table populated by StaticInitInput and strips the "IK_"
// prefix. We mirror those exact display strings directly, including odd spellings like
// "Unknown10E"/"Unknown10F" from the script enum, so the observable result matches retail.
IMPL_MATCH("Engine.dll", 0x103b55d0)
const TCHAR* UInput::GetKeyName(EInputKey Key) const
{
	static TCHAR GenBuf[16]; // used for dynamically generated names
	DWORD k = (DWORD)Key;

	if (k >= 0xFF)
		return TEXT("");

	if (k == 0)
		return TEXT("None");

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
		{ 0xDE, TEXT("SingleQuote")    },
		{ 0xE0, TEXT("JoyX")           }, { 0xE1, TEXT("JoyY")             },
		{ 0xE2, TEXT("JoyZ")           }, { 0xE3, TEXT("JoyR")             },
		{ 0xE4, TEXT("MouseX")         }, { 0xE5, TEXT("MouseY")           },
		{ 0xE6, TEXT("MouseZ")         }, { 0xE7, TEXT("MouseW")           },
		{ 0xE8, TEXT("JoyU")           }, { 0xE9, TEXT("JoyV")             },
		{ 0xEC, TEXT("MouseWheelUp")   }, { 0xED, TEXT("MouseWheelDown")   },
		{ 0xEE, TEXT("Unknown10E")     }, { 0xEF, TEXT("Unknown10F")       },
		{ 0xF6, TEXT("Attn")           }, { 0xF7, TEXT("CrSel")            },
		{ 0xF8, TEXT("ExSel")          }, { 0xF9, TEXT("ErEof")            },
		{ 0xFA, TEXT("Play")           }, { 0xFB, TEXT("Zoom")             },
		{ 0xFC, TEXT("NoName")         }, { 0xFD, TEXT("PA1")              },
		{ 0xFE, TEXT("OEMClear")       },
	};
	for (INT i = 0; i < ARRAY_COUNT(Table); i++)
		if (Table[i].Code == k) return Table[i].Name;

	appSprintf(GenBuf, TEXT("Unknown%02X"), k & 0xFF);
	return GenBuf;
}

// Retail prepends "IK_", creates an FName, and scans the same key-name array through
// FUN_103b56b0. A linear search over GetKeyName() is equivalent once the display names match.
IMPL_MATCH("Engine.dll", 0x103b5df0)
INT UInput::FindKeyName(const TCHAR* KeyName, EInputKey& Key) const
{
	for (INT i = 0; i < 0xFF; i++)
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
IMPL_MATCH("Engine.dll", 0x103b47c0)
void UInput::StaticInitInput()
{
	guard(UInput::StaticInitInput);
	// Ghidra 0x103b47c0 (591b): identical to UInputPlanning::StaticInitInput.
	FArchive DummyAr;

	UStruct* AliasStruct = new(NULL, TEXT("Alias"), RF_Public) UStruct((UStruct*)NULL);
	AliasStruct->SetPropertiesSize(0x10);
	new(AliasStruct, TEXT("Alias"), RF_Public)
		UNameProperty(EC_CppProperty, 0, TEXT(""), CPF_Config);
	new(AliasStruct, TEXT("Command"), RF_Public)
		UStrProperty(EC_CppProperty, 4, TEXT(""), CPF_Config);
	AliasStruct->Link(DummyAr, 1);

	UStructProperty* AliasProp = new(StaticClass(), TEXT("Aliases"), RF_Public)
		UStructProperty(EC_CppProperty, 0x30, TEXT("Aliases"), CPF_Config, AliasStruct);
	*(INT*)((BYTE*)AliasProp + 0x38) = 0x28;

	UEnum* InputKeyEnum = (UEnum*)UObject::StaticFindObjectChecked(
		UEnum::StaticClass(),
		UInteractions::StaticClass(),
		TEXT("EInputKey"), 0);

	FName* EnumNames = *(FName**)((BYTE*)InputKeyEnum + 0x38);
	for (INT i = 0; i <= 0xFE; i++)
	{
		if (EnumNames[i] != NAME_None)
		{
			const TCHAR* KeyStr = *EnumNames[i];
			new(StaticClass(), KeyStr + 3, RF_Public)
				UStrProperty(EC_CppProperty, i * 0xC + 0x2B0, TEXT("RawKeys"), CPF_Config);
		}
	}

	StaticClass()->Link(DummyAr, 1);
	UObject* DefaultObj = StaticClass()->GetDefaultObject();
	DefaultObj->LoadConfig(0, NULL, NULL);
	unguard;
}