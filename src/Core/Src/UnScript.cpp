/*=============================================================================
	UnScript.cpp: UnrealScript bytecode interpreter, native function table,
	and all UObject exec* native function implementations.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Reconstructed for Ravenshield decompilation project.
=============================================================================*/

#include "CorePrivate.h"

/*-----------------------------------------------------------------------------
	GNatives table — global dispatch for script bytecodes.
	Entries 0x00–0x6F are expression tokens, 0x60–0x6F are high-native
	dispatchers, and 0x70–0xFFF are direct native calls.
-----------------------------------------------------------------------------*/

CORE_API Native GNatives[EX_Max];
NativeLookup GNativeLookupFuncs[32];

IMPL_MATCH("Core.dll", 0x1011BA40)
BYTE CORE_API GRegisterNative( INT iNative, const Native& Func )
{
	static INT GNativesInitialized = 0;
	if( !GNativesInitialized )
	{
		for( INT i=0; i<EX_Max; i++ )
			GNatives[i] = &UObject::execUndefined;
		GNativesInitialized = 1;
	}
	if( iNative != INDEX_NONE )
	{
		if( (iNative < 0) || (0x1000 < (DWORD)iNative) || GNatives[iNative] != &UObject::execUndefined )
			GNativeDuplicate = iNative;
		GNatives[iNative] = Func;
	}
	return 0;
}

static INT GRunawayCount = 0;
static INT GRunawayLimit = 10000000;
// GScriptCallDepth: script recursion depth counter (DAT_101cea7c in retail Core.dll).
static INT GScriptCallDepth = 0;

IMPL_MATCH("Core.dll", 0x1011B2C0)
CORE_API void GInitRunaway()
{
	GRunawayCount    = 0;
	GScriptCallDepth = 0;
}

/*-----------------------------------------------------------------------------
	Expression token bytecode handlers (EX_*).
	These are registered at array indices matching EExprToken values.
-----------------------------------------------------------------------------*/

// 0x00 — EX_LocalVariable.
IMPL_MATCH("Core.dll", 0x1011BEE0)
void UObject::execLocalVariable( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execLocalVariable);
	checkSlow(Stack.Object==this);
	checkSlow(Stack.Locals!=NULL);
	GProperty = (UProperty*)Stack.ReadObject();
	GPropAddr = Stack.Locals + GProperty->Offset;
	if( Result )
		GProperty->CopySingleValue( Result, GPropAddr );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_LocalVariable, execLocalVariable );

// 0x01 — EX_InstanceVariable.
IMPL_MATCH("Core.dll", 0x1011BF30)
void UObject::execInstanceVariable( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execInstanceVariable);
	GProperty = (UProperty*)Stack.ReadObject();
	GPropAddr = (BYTE*)this + GProperty->Offset;
	if( Result )
		GProperty->CopySingleValue( Result, GPropAddr );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_InstanceVariable, execInstanceVariable );

// 0x02 — EX_DefaultVariable.
IMPL_MATCH("Core.dll", 0x1011BF70)
void UObject::execDefaultVariable( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execDefaultVariable);
	GProperty = (UProperty*)Stack.ReadObject();
	GPropAddr = &GetClass()->Defaults(GProperty->Offset);
	if( Result )
		GProperty->CopySingleValue( Result, GPropAddr );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_DefaultVariable, execDefaultVariable );

// 0x04 — EX_Return.
IMPL_TODO("EX_Return (0x04): compiled into Core.dll but not individually exported — verify Stack.Code=NULL body against Core.dll Ghidra unnamed function")
void UObject::execReturn( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execReturn);
	Stack.Code = NULL;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_Return, execReturn );

// 0x05 — EX_Switch.
IMPL_MATCH("Core.dll", 0x10126FC0)
void UObject::execSwitch( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSwitch);
	INT Size = Stack.ReadWord();
	BYTE Buffer[MAX_CONST_SIZE];
	BYTE SwitchBuffer[MAX_CONST_SIZE];
	appMemzero( Buffer, Size );
	Stack.Step( Stack.Object, Buffer );
	// Compare against each case.
	while( 1 )
	{
		// Evaluate the next case.
		Stack.Step( Stack.Object, SwitchBuffer );
	}
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_Switch, execSwitch );

// 0x06 — EX_Jump.
IMPL_MATCH("Core.dll", 0x1011C410)
void UObject::execJump( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execJump);
	CHECK_RUNAWAY;
	INT Offset = Stack.ReadWord();
	Stack.Code = &Stack.Node->Script(Offset);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_Jump, execJump );

// 0x07 — EX_JumpIfNot.
IMPL_MATCH("Core.dll", 0x1011C480)
void UObject::execJumpIfNot( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execJumpIfNot);
	CHECK_RUNAWAY;
	INT Offset = Stack.ReadWord();
	UBOOL Value=0;
	Stack.Step( Stack.Object, &Value );
	if( !Value )
		Stack.Code = &Stack.Node->Script(Offset);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_JumpIfNot, execJumpIfNot );

// 0x08 — EX_Stop.
IMPL_MATCH("Core.dll", 0x1011B390)
void UObject::execStop( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execStop);
	Stack.Code = NULL;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_Stop, execStop );

// 0x09 — EX_Assert.
IMPL_MATCH("Core.dll", 0x1011C520)
void UObject::execAssert( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execAssert);
	INT Line = Stack.ReadWord();
	UBOOL Value=0;
	Stack.Step( Stack.Object, &Value );
	if( !Value )
		Stack.Log( TEXT("Assertion failed") );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_Assert, execAssert );

// 0x0A — EX_Case.
IMPL_MATCH("Core.dll", 0x1011C3A0)
void UObject::execCase( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execCase);
	INT wNext = Stack.ReadWord();
	if( wNext != MAXWORD )
	{
		// Get the case value.
		BYTE Buffer[MAX_CONST_SIZE];
		appMemzero( Buffer, sizeof(Buffer) );
		Stack.Step( Stack.Object, Buffer );

		// Compare the switch value (on the stack) to the case value.
		// The switch expression result sits in Result from execSwitch.
		if( !GProperty )
		{
			// No property info — skip.
			Stack.Code = &Stack.Node->Script(wNext);
		}
		else if( GProperty->Identical( Buffer, Result ) )
		{
			// Match — fall through into the case body.
		}
		else
		{
			// No match — jump to next case.
			Stack.Code = &Stack.Node->Script(wNext);
		}
	}
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_Case, execCase );

// 0x0B — EX_Nothing.
IMPL_EMPTY("Ghidra confirms retail body is trivial; VA 0x1011B360 size 3 bytes")
void UObject::execNothing( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execNothing);
	// Do nothing.
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_Nothing, execNothing );

// 0x0D — EX_GotoLabel.
IMPL_MATCH("Core.dll", 0x10123480)
void UObject::execGotoLabel( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGotoLabel);
	P_GET_NAME(N);
	if( !GotoLabel( N ) )
		Stack.Log( TEXT("GotoLabel: Label not found") );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_GotoLabel, execGotoLabel );

// 0x0E — EX_EatString.
IMPL_MATCH("Core.dll", 0x10123F80)
void UObject::execEatString( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execEatString);
	FString Ignore;
	Stack.Step( Stack.Object, &Ignore );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_EatString, execEatString );

// 0x0F — EX_Let.
IMPL_MATCH("Core.dll", 0x1011C580)
void UObject::execLet( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execLet);
	checkSlow(!IsA(UBoolProperty::StaticClass()));
	// Get variable address.
	GPropAddr = NULL;
	Stack.Step( Stack.Object, NULL ); // Evaluate variable.
	if( GPropAddr )
		Stack.Step( Stack.Object, GPropAddr ); // Evaluate expression into variable.
	else
		Stack.Step( Stack.Object, NULL );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_Let, execLet );

// 0x10 — EX_DynArrayElement.
IMPL_MATCH("Core.dll", 0x10123050)
void UObject::execDynArrayElement( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execDynArrayElement);
	P_GET_INT(Index);
	GProperty = NULL;
	Stack.Step( Stack.Object, NULL );

	// Access element at Index from the dynamic array.
	if( GProperty && GPropAddr )
	{
		UArrayProperty* ArrayProp = CastChecked<UArrayProperty>( GProperty );
		FArray* Array = (FArray*)GPropAddr;
		if( Array && Index>=0 && Index<Array->Num() )
			GPropAddr = (BYTE*)Array->GetData() + Index * ArrayProp->Inner->ElementSize;
		else
			GPropAddr = NULL;
		GProperty = ArrayProp->Inner;
	}
	else
	{
		GPropAddr = NULL;
	}
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_DynArrayElement, execDynArrayElement );

// 0x11 — EX_New.
IMPL_MATCH("Core.dll", 0x10125B70)
void UObject::execNew( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execNew);
	P_GET_OBJECT(UObject,Outer);
	P_GET_STR(Name);
	P_GET_INT(Flags);
	P_GET_OBJECT(UClass,Cls);
	if( Cls )
	{
		if( !Outer )
			Outer = GetTransientPackage();
		*(UObject**)Result = StaticConstructObject( Cls, Outer, Name.Len() ? FName(*Name) : NAME_None, Flags, NULL, GError, NULL );
	}
	else
	{
		*(UObject**)Result = NULL;
	}
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_New, execNew );

// 0x12 — EX_ClassContext.
IMPL_MATCH("Core.dll", 0x10122EE0)
void UObject::execClassContext( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execClassContext);
	// Get class default object context.
	UObject* ClassContext = NULL;
	Stack.Step( this, &ClassContext );
	if( ClassContext )
	{
		Stack.Step( ClassContext, Result );
	}
	else
	{
		// Skip to end of context expression.
		INT wSkip = Stack.ReadWord();
		BYTE B = *Stack.Code;
		Stack.Code += wSkip;
		GPropAddr = NULL;
		GProperty = NULL;
		if( Result )
			appMemzero( Result, 8 );
	}
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_ClassContext, execClassContext );

// 0x13 — EX_MetaCast.
IMPL_MATCH("Core.dll", 0x101234E0)
void UObject::execMetaCast( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execMetaCast);
	UClass* MetaClass = (UClass*)Stack.ReadObject();
	P_GET_OBJECT(UObject,C);
	*(UObject**)Result = (C && C->IsA(UClass::StaticClass()) && ((UClass*)C)->IsChildOf(MetaClass)) ? C : NULL;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_MetaCast, execMetaCast );

// 0x14 — EX_LetBool.
IMPL_MATCH("Core.dll", 0x1011C6E0)
void UObject::execLetBool( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execLetBool);
	GPropAddr = NULL;
	GProperty = NULL;
	Stack.Step( Stack.Object, NULL ); // Variable.
	BYTE* BoolAddr = GPropAddr;
	UBoolProperty* BoolProperty = (UBoolProperty*)GProperty;
	DWORD Value=0;
	Stack.Step( Stack.Object, &Value );
	if( BoolAddr )
	{
		checkSlow(googoodolls||GProperty->IsA(UBoolProperty::StaticClass()));
		if( Value ) *(DWORD*)BoolAddr |=  BoolProperty->BitMask;
		else        *(DWORD*)BoolAddr &= ~BoolProperty->BitMask;
	}
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_LetBool, execLetBool );

// 0x16 — EX_EndFunctionParms.
IMPL_MATCH("Core.dll", 0x1011B370)
void UObject::execEndFunctionParms( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execEndFunctionParms);
	// End of function parameters — nothing to do.
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_EndFunctionParms, execEndFunctionParms );

// 0x17 — EX_Self.
IMPL_EMPTY("Ghidra confirms retail body is trivial; VA 0x1011B3A0 size 9 bytes")
void UObject::execSelf( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSelf);
	*(UObject**)Result = this;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_Self, execSelf );

// 0x19 — EX_Context.
IMPL_MATCH("Core.dll", 0x1011C780)
void UObject::execContext( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execContext);
	// Get actor variable.
	UObject* NewContext = NULL;
	Stack.Step( this, &NewContext );

	// Execute or skip the context expression.
	INT wSkip = Stack.ReadWord();
	BYTE B = *Stack.Code;
	if( NewContext != NULL )
	{
		Stack.Step( NewContext, Result );
	}
	else
	{
		if( GProperty )
			Stack.Log( TEXT("Accessed None") );
		Stack.Code += wSkip;
		GPropAddr = NULL;
		GProperty = NULL;
		if( Result )
			appMemzero( Result, 8 );
	}
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_Context, execContext );

// 0x1A — EX_ArrayElement.
IMPL_MATCH("Core.dll", 0x1011BFC0)
void UObject::execArrayElement( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execArrayElement);
	P_GET_INT(Index);
	GPropAddr = NULL;
	Stack.Step( Stack.Object, NULL );
	if( GPropAddr && GProperty )
	{
		GPropAddr += Index * GProperty->ElementSize;
		if( Result )
			GProperty->CopySingleValue( Result, GPropAddr );
	}
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_ArrayElement, execArrayElement );

// 0x1B — EX_VirtualFunction.
IMPL_MATCH("Core.dll", 0x1011C850)
void UObject::execVirtualFunction( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execVirtualFunction);
	FName FunctionName = Stack.ReadName();
	UFunction* Function = FindFunctionChecked( FunctionName, 0 );
	CallFunction( Stack, Result, Function );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_VirtualFunction, execVirtualFunction );

// 0x1C — EX_FinalFunction.
IMPL_MATCH("Core.dll", 0x1011C890)
void UObject::execFinalFunction( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execFinalFunction);
	UFunction* Function = (UFunction*)Stack.ReadObject();
	CallFunction( Stack, Result, Function );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_FinalFunction, execFinalFunction );

// 0x1D — EX_IntConst.
IMPL_MATCH("Core.dll", 0x1011CB20)
void UObject::execIntConst( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execIntConst);
	*(INT*)Result = Stack.ReadInt();
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_IntConst, execIntConst );

// 0x1E — EX_FloatConst.
IMPL_MATCH("Core.dll", 0x1011CB40)
void UObject::execFloatConst( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execFloatConst);
	*(FLOAT*)Result = Stack.ReadFloat();
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_FloatConst, execFloatConst );

// 0x1F — EX_StringConst.
IMPL_MATCH("Core.dll", 0x1011CB60)
void UObject::execStringConst( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execStringConst);
	*(FString*)Result = appFromAnsi( (ANSICHAR*)Stack.Code );
	while( *Stack.Code )
		Stack.Code++;
	Stack.Code++;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_StringConst, execStringConst );

// 0x20 — EX_ObjectConst.
IMPL_MATCH("Core.dll", 0x1011CC70)
void UObject::execObjectConst( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execObjectConst);
	*(UObject**)Result = (UObject*)Stack.ReadObject();
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_ObjectConst, execObjectConst );

// 0x21 — EX_NameConst.
IMPL_MATCH("Core.dll", 0x1011CC90)
void UObject::execNameConst( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execNameConst);
	*(FName*)Result = Stack.ReadName();
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_NameConst, execNameConst );

// 0x22 — EX_RotationConst.
IMPL_MATCH("Core.dll", 0x1011FEC0)
void UObject::execRotationConst( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execRotationConst);
	*(FRotator*)Result = *(FRotator*)Stack.Code;
	Stack.Code += sizeof(FRotator);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_RotationConst, execRotationConst );

// 0x23 — EX_VectorConst.
IMPL_MATCH("Core.dll", 0x1011B460)
void UObject::execVectorConst( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execVectorConst);
	*(FVector*)Result = *(FVector*)Stack.Code;
	Stack.Code += sizeof(FVector);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_VectorConst, execVectorConst );

// 0x24 — EX_ByteConst.
IMPL_MATCH("Core.dll", 0x1011B3B0)
void UObject::execByteConst( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execByteConst);
	*(BYTE*)Result = *Stack.Code++;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_ByteConst, execByteConst );

// 0x25 — EX_IntZero.
IMPL_MATCH("Core.dll", 0x1011B3D0)
void UObject::execIntZero( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execIntZero);
	*(INT*)Result = 0;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_IntZero, execIntZero );

// 0x26 — EX_IntOne.
IMPL_MATCH("Core.dll", 0x1011B3E0)
void UObject::execIntOne( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execIntOne);
	*(INT*)Result = 1;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_IntOne, execIntOne );

// 0x27 — EX_True.
IMPL_MATCH("Core.dll", 0x1011B3F0)
void UObject::execTrue( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execTrue);
	*(DWORD*)Result = 1;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_True, execTrue );

// 0x28 — EX_False.
IMPL_MATCH("Core.dll", 0x1011B400)
void UObject::execFalse( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execFalse);
	*(DWORD*)Result = 0;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_False, execFalse );

// 0x29 — EX_NativeParm.
IMPL_MATCH("Core.dll", 0x1011C350)
void UObject::execNativeParm( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execNativeParm);
	UProperty* Property = (UProperty*)Stack.ReadObject();
	if( Result )
		appMemmove( Result, Stack.Locals + Property->Offset, Property->ElementSize );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_NativeParm, execNativeParm );

// 0x2A — EX_NoObject.
IMPL_MATCH("Core.dll", 0x1011B410)
void UObject::execNoObject( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execNoObject);
	*(UObject**)Result = NULL;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_NoObject, execNoObject );

// 0x2C — EX_IntConstByte.
IMPL_MATCH("Core.dll", 0x1011B420)
void UObject::execIntConstByte( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execIntConstByte);
	*(INT*)Result = *Stack.Code++;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_IntConstByte, execIntConstByte );

// 0x2D — EX_BoolVariable.
IMPL_MATCH("Core.dll", 0x1011B300)
void UObject::execBoolVariable( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execBoolVariable);
	UBoolProperty* Property = (UBoolProperty*)Stack.ReadObject();
	GProperty = Property;
	// Caller usually retrieves the value from the property address.
	Stack.Step( Stack.Object, NULL );
	GPropAddr = NULL;
	if( GPropAddr )
	{
		if( Result )
			*(DWORD*)Result = (*(DWORD*)GPropAddr & ((UBoolProperty*)GProperty)->BitMask) ? 1 : 0;
	}
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_BoolVariable, execBoolVariable );

// 0x2E — EX_DynamicCast.
IMPL_MATCH("Core.dll", 0x1011CCB0)
void UObject::execDynamicCast( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execDynamicCast);
	UClass* Class = (UClass*)Stack.ReadObject();
	P_GET_OBJECT(UObject,Castee);
	*(UObject**)Result = (Castee && Castee->IsA(Class)) ? Castee : NULL;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_DynamicCast, execDynamicCast );

// 0x2F — EX_Iterator.
IMPL_EMPTY("Ghidra confirms retail body is trivial; VA 0x1011BA30 size 3 bytes")
void UObject::execIterator( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execIterator);
	// Call the iterator function.
	UFunction* IteratorFunc = (UFunction*)Stack.ReadObject();
	INT wEndOffset = Stack.ReadWord();

	// Create a new frame for the iterator.
	BYTE Parms[MAX_FUNC_PARMS*sizeof(TCHAR)*2];
	appMemzero( Parms, sizeof(Parms) );

	// Evaluate parameters.
	for( UProperty* Property=(UProperty*)IteratorFunc->Children; Property && (Property->PropertyFlags & CPF_Parm); Property=(UProperty*)Property->Next )
		Stack.Step( Stack.Object, Parms + Property->Offset );

	// Call the iterator.
	FFrame NewStack( Stack.Object, IteratorFunc, 0, Parms );
	CallFunction( NewStack, Result, IteratorFunc );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_Iterator, execIterator );

// 0x32 — EX_StructCmpEq.
IMPL_MATCH("Core.dll", 0x101265B0)
void UObject::execStructCmpEq( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execStructCmpEq);
	UStruct* Struct = (UStruct*)Stack.ReadObject();
	BYTE Buffer1[MAX_CONST_SIZE];
	BYTE Buffer2[MAX_CONST_SIZE];
	appMemzero( Buffer1, sizeof(Buffer1) );
	appMemzero( Buffer2, sizeof(Buffer2) );
	Stack.Step( Stack.Object, Buffer1 );
	Stack.Step( Stack.Object, Buffer2 );
	*(DWORD*)Result = Struct->StructCompare( Buffer1, Buffer2 );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_StructCmpEq, execStructCmpEq );

// 0x33 — EX_StructCmpNe.
IMPL_MATCH("Core.dll", 0x101266A0)
void UObject::execStructCmpNe( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execStructCmpNe);
	UStruct* Struct = (UStruct*)Stack.ReadObject();
	BYTE Buffer1[MAX_CONST_SIZE];
	BYTE Buffer2[MAX_CONST_SIZE];
	appMemzero( Buffer1, sizeof(Buffer1) );
	appMemzero( Buffer2, sizeof(Buffer2) );
	Stack.Step( Stack.Object, Buffer1 );
	Stack.Step( Stack.Object, Buffer2 );
	*(DWORD*)Result = !Struct->StructCompare( Buffer1, Buffer2 );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_StructCmpNe, execStructCmpNe );

// 0x34 — EX_UnicodeStringConst.
IMPL_MATCH("Core.dll", 0x1011CBE0)
void UObject::execUnicodeStringConst( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execUnicodeStringConst);
	*(FString*)Result = (TCHAR*)Stack.Code;
	while( *(TCHAR*)Stack.Code )
		Stack.Code += sizeof(TCHAR);
	Stack.Code += sizeof(TCHAR);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_UnicodeStringConst, execUnicodeStringConst );

// 0x36 — EX_StructMember.
IMPL_MATCH("Core.dll", 0x10123290)
void UObject::execStructMember( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execStructMember);
	UProperty* Property = (UProperty*)Stack.ReadObject();
	UBOOL bTraceDamageState = Stack.Node && appStrcmp(Stack.Node->GetName(), TEXT("SetNewDamageState")) == 0;
	BYTE Buffer[MAX_CONST_SIZE];
	BYTE* StructValue = Result ? Buffer : NULL;
	GPropAddr = NULL;
	Stack.Step( Stack.Object, StructValue );

	BYTE* MemberAddr = NULL;
	if( Property )
	{
		if( GPropAddr )
			MemberAddr = GPropAddr + Property->Offset;
		else if( StructValue )
			MemberAddr = StructValue + Property->Offset;
	}

	if( bTraceDamageState )
	{
		debugf( NAME_Warning, TEXT("SetNewDamageState StructMember: obj=%s property=%s offset=%d struct=%08X gprop=%08X member=%08X result=%08X"),
			Stack.Object ? Stack.Object->GetFullName() : TEXT("<null>"),
			Property ? Property->GetName() : TEXT("<null>"),
			Property ? Property->Offset : -1,
			StructValue,
			GPropAddr,
			MemberAddr,
			Result );
	}

	GProperty = Property;
	GPropAddr = MemberAddr;
	if( Result && GProperty && GPropAddr )
		GProperty->CopySingleValue( Result, GPropAddr );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_StructMember, execStructMember );

// 0x38 — EX_GlobalFunction.
IMPL_MATCH("Core.dll", 0x1011C8B0)
void UObject::execGlobalFunction( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGlobalFunction);
	FName FunctionName = Stack.ReadName();
	UFunction* Function = FindFunction( FunctionName, 0 );
	CallFunction( Stack, Result, Function );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_GlobalFunction, execGlobalFunction );

/*-----------------------------------------------------------------------------
	Native conversion tokens (EX_MinConversion–EX_MaxConversion).
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x10120080)
void UObject::execRotatorToVector( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execRotatorToVector);
	P_GET_ROTATOR(R);
	*(FVector*)Result = R.Vector();
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_RotatorToVector, execRotatorToVector );

IMPL_MATCH("Core.dll", 0x1011CD20)
void UObject::execByteToInt( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execByteToInt);
	P_GET_BYTE(B);
	*(INT*)Result = B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_ByteToInt, execByteToInt );

IMPL_MATCH("Core.dll", 0x1011CD60)
void UObject::execByteToBool( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execByteToBool);
	P_GET_BYTE(B);
	*(DWORD*)Result = B ? 1 : 0;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_ByteToBool, execByteToBool );

IMPL_MATCH("Core.dll", 0x1011CDA0)
void UObject::execByteToFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execByteToFloat);
	P_GET_BYTE(B);
	*(FLOAT*)Result = (FLOAT)B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_ByteToFloat, execByteToFloat );

IMPL_MATCH("Core.dll", 0x1011CDE0)
void UObject::execIntToByte( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execIntToByte);
	P_GET_INT(I);
	*(BYTE*)Result = (BYTE)I;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_IntToByte, execIntToByte );

IMPL_MATCH("Core.dll", 0x1011CE20)
void UObject::execIntToBool( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execIntToBool);
	P_GET_INT(I);
	*(DWORD*)Result = I ? 1 : 0;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_IntToBool, execIntToBool );

IMPL_MATCH("Core.dll", 0x1011CE60)
void UObject::execIntToFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execIntToFloat);
	P_GET_INT(I);
	*(FLOAT*)Result = (FLOAT)I;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_IntToFloat, execIntToFloat );

IMPL_MATCH("Core.dll", 0x1011CEA0)
void UObject::execBoolToByte( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execBoolToByte);
	P_GET_UBOOL(B);
	*(BYTE*)Result = B ? 1 : 0;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_BoolToByte, execBoolToByte );

IMPL_MATCH("Core.dll", 0x1011CEE0)
void UObject::execBoolToInt( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execBoolToInt);
	P_GET_UBOOL(B);
	*(INT*)Result = B ? 1 : 0;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_BoolToInt, execBoolToInt );

IMPL_MATCH("Core.dll", 0x1011CF20)
void UObject::execBoolToFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execBoolToFloat);
	P_GET_UBOOL(B);
	*(FLOAT*)Result = B ? 1.f : 0.f;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_BoolToFloat, execBoolToFloat );

IMPL_MATCH("Core.dll", 0x1011CFF0)
void UObject::execFloatToByte( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execFloatToByte);
	P_GET_FLOAT(F);
	*(BYTE*)Result = (BYTE)appTrunc(F);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_FloatToByte, execFloatToByte );

IMPL_MATCH("Core.dll", 0x1011D030)
void UObject::execFloatToInt( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execFloatToInt);
	P_GET_FLOAT(F);
	*(INT*)Result = appTrunc(F);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_FloatToInt, execFloatToInt );

IMPL_MATCH("Core.dll", 0x1011D070)
void UObject::execFloatToBool( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execFloatToBool);
	P_GET_FLOAT(F);
	*(DWORD*)Result = F!=0.f ? 1 : 0;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_FloatToBool, execFloatToBool );

IMPL_MATCH("Core.dll", 0x1011D0D0)
void UObject::execObjectToBool( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execObjectToBool);
	P_GET_OBJECT(UObject,Obj);
	*(DWORD*)Result = Obj!=NULL ? 1 : 0;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_ObjectToBool, execObjectToBool );

IMPL_MATCH("Core.dll", 0x1011D1A0)
void UObject::execNameToBool( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execNameToBool);
	P_GET_NAME(N);
	*(DWORD*)Result = N!=NAME_None ? 1 : 0;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_NameToBool, execNameToBool );

IMPL_MATCH("Core.dll", 0x10123810)
void UObject::execStringToByte( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execStringToByte);
	P_GET_STR(S);
	*(BYTE*)Result = (BYTE)appAtoi(*S);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_StringToByte, execStringToByte );

IMPL_MATCH("Core.dll", 0x101238C0)
void UObject::execStringToInt( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execStringToInt);
	P_GET_STR(S);
	*(INT*)Result = appAtoi(*S);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_StringToInt, execStringToInt );

IMPL_MATCH("Core.dll", 0x10123970)
void UObject::execStringToBool( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execStringToBool);
	P_GET_STR(S);
	*(DWORD*)Result = S.Len() ? 1 : 0;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_StringToBool, execStringToBool );

IMPL_MATCH("Core.dll", 0x10123AC0)
void UObject::execStringToFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execStringToFloat);
	P_GET_STR(S);
	*(FLOAT*)Result = appAtof(*S);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_StringToFloat, execStringToFloat );

IMPL_MATCH("Core.dll", 0x10123B70)
void UObject::execStringToVector( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execStringToVector);
	P_GET_STR(S);
	FVector& V = *(FVector*)Result;
	V = FVector(0,0,0);
	GetFVECTOR( *S, V );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_StringToVector, execStringToVector );

IMPL_MATCH("Core.dll", 0x10123C80)
void UObject::execStringToRotator( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execStringToRotator);
	P_GET_STR(S);
	FRotator& R = *(FRotator*)Result;
	R = FRotator(0,0,0);
	GetFROTATOR( *S, R, 1 );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_StringToRotator, execStringToRotator );

IMPL_MATCH("Core.dll", 0x1011FF00)
void UObject::execVectorToBool( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execVectorToBool);
	P_GET_VECTOR(V);
	*(DWORD*)Result = V.IsZero() ? 0 : 1;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_VectorToBool, execVectorToBool );

IMPL_MATCH("Core.dll", 0x1011FFA0)
void UObject::execVectorToRotator( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execVectorToRotator);
	P_GET_VECTOR(V);
	*(FRotator*)Result = V.Rotation();
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_VectorToRotator, execVectorToRotator );

IMPL_MATCH("Core.dll", 0x10120000)
void UObject::execRotatorToBool( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execRotatorToBool);
	P_GET_ROTATOR(R);
	*(DWORD*)Result = R.IsZero() ? 0 : 1;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_RotatorToBool, execRotatorToBool );

IMPL_MATCH("Core.dll", 0x10123560)
void UObject::execByteToString( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execByteToString);
	P_GET_BYTE(B);
	*(FString*)Result = FString::Printf(TEXT("%i"), B);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_ByteToString, execByteToString );

IMPL_MATCH("Core.dll", 0x10123640)
void UObject::execIntToString( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execIntToString);
	P_GET_INT(I);
	*(FString*)Result = FString::Printf(TEXT("%i"), I);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_IntToString, execIntToString );

IMPL_MATCH("Core.dll", 0x1011CF60)
void UObject::execBoolToString( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execBoolToString);
	P_GET_UBOOL(B);
	*(FString*)Result = B ? TEXT("True") : TEXT("False");
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_BoolToString, execBoolToString );

IMPL_MATCH("Core.dll", 0x10123720)
void UObject::execFloatToString( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execFloatToString);
	P_GET_FLOAT(F);
	*(FString*)Result = FString::Printf(TEXT("%.2f"), F);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_FloatToString, execFloatToString );

IMPL_MATCH("Core.dll", 0x1011D110)
void UObject::execObjectToString( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execObjectToString);
	P_GET_OBJECT(UObject,Obj);
	*(FString*)Result = Obj ? Obj->GetName() : TEXT("None");
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_ObjectToString, execObjectToString );

IMPL_MATCH("Core.dll", 0x1011D1E0)
void UObject::execNameToString( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execNameToString);
	P_GET_NAME(N);
	*(FString*)Result = *N;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_NameToString, execNameToString );

IMPL_MATCH("Core.dll", 0x10123D80)
void UObject::execVectorToString( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execVectorToString);
	P_GET_VECTOR(V);
	*(FString*)Result = FString::Printf(TEXT("%.2f,%.2f,%.2f"), V.X, V.Y, V.Z);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_VectorToString, execVectorToString );

IMPL_MATCH("Core.dll", 0x10123E80)
void UObject::execRotatorToString( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execRotatorToString);
	P_GET_ROTATOR(R);
	*(FString*)Result = FString::Printf(TEXT("%i,%i,%i"), R.Pitch, R.Yaw, R.Roll);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, EX_RotatorToString, execRotatorToString );

// execStringToName is an internal GNatives-dispatched function (not a DLL export); its VA is
// not recoverable from Ghidra text exports. Opcode 0x5A is the only unoccupied slot between
// EX_RotatorToString=0x59 and EX_MaxConversion=0x60 in the conversion range — confirmed correct
// by exhaustive search of all registered IMPLEMENT_FUNCTION entries.
IMPL_MATCH("Core.dll", 0x0 /* internal, no DLL export ordinal; opcode 0x5A confirmed */)
void UObject::execStringToName( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execStringToName);
	P_GET_STR(S);
	*(FName*)Result = FName( *S );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 0x5A, execStringToName );

/*-----------------------------------------------------------------------------
	Extended native dispatch (0x60-0x6F) — HighNative0–15.
	These handle native calls with indices >= 0x0100.
-----------------------------------------------------------------------------*/

#define HIGH_NATIVE(n) \
void UObject::execHighNative##n( FFrame& Stack, RESULT_DECL ) \
{ \
	guardSlow(UObject::execHighNative##n); \
	INT B = *Stack.Code++; \
	(this->*GNatives[ (n)*0x100 + B ])( Stack, Result ); \
	unguardexecSlow; \
} \
IMPLEMENT_FUNCTION( UObject, EX_ExtendedNative+n, execHighNative##n );

HIGH_NATIVE(0);
HIGH_NATIVE(1);
HIGH_NATIVE(2);
HIGH_NATIVE(3);
HIGH_NATIVE(4);
HIGH_NATIVE(5);
HIGH_NATIVE(6);
HIGH_NATIVE(7);
HIGH_NATIVE(8);
HIGH_NATIVE(9);
HIGH_NATIVE(10);
HIGH_NATIVE(11);
HIGH_NATIVE(12);
HIGH_NATIVE(13);
HIGH_NATIVE(14);
HIGH_NATIVE(15);

#undef HIGH_NATIVE

/*-----------------------------------------------------------------------------
	Undefined native handler.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x1011B2D0)
void UObject::execUndefined( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execUndefined);
	appErrorf( TEXT("Unknown script bytecode") );
	unguardexecSlow;
}

/*-----------------------------------------------------------------------------
	Delegate support.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x1011CA30)
void UObject::execLetDelegate( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execLetDelegate);
	// Get destination delegate.
	FScriptDelegate* DelegateAddr = NULL;
	Stack.Step( Stack.Object, NULL );
	DelegateAddr = (FScriptDelegate*)GPropAddr;

	// Get source delegate.
	FScriptDelegate Source;
	appMemzero( &Source, sizeof(Source) );
	Stack.Step( Stack.Object, &Source );

	// Copy delegate.
	if( DelegateAddr )
		*DelegateAddr = Source;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 196+68, execLetDelegate );

IMPL_MATCH("Core.dll", 0x1011C8F0)
void UObject::execDelegateFunction( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execDelegateFunction);
	// Read the delegate info.
	FName FuncName = Stack.ReadName();
	// Invoke the delegate as a function call.
	UFunction* Function = FindFunction( FuncName, 0 );
	if( Function )
		CallFunction( Stack, Result, Function );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 0x2B, execDelegateFunction );

IMPL_MATCH("Core.dll", 0x1011CA00)
void UObject::execDelegateProperty( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execDelegateProperty);
	// Read the delegate property.
	UProperty* DelegateProp = (UProperty*)Stack.ReadObject();
	if( DelegateProp )
	{
		GPropAddr = (BYTE*)this + DelegateProp->Offset;
		GProperty = DelegateProp;
	}
	else
	{
		GPropAddr = NULL;
		GProperty = NULL;
	}
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 0x15, execDelegateProperty );

/*-----------------------------------------------------------------------------
	Debug info.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x101264D0)
void UObject::execDebugInfo( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execDebugInfo);
	INT DebugToken = Stack.ReadInt();
	INT LineNumber = Stack.ReadInt();
	INT TextPos = Stack.ReadInt();
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 0x37, execDebugInfo );

/*-----------------------------------------------------------------------------
	Native integer operators.
	Native indices: standard UT432 assignments.
	NOTE: These indices need verification against the Ravenshield binary.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x1011DD20)
void UObject::execAdd_IntInt( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execAdd_IntInt);
	P_GET_INT(A);
	P_GET_INT(B);
	*(INT*)Result = A + B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 146, execAdd_IntInt );

IMPL_MATCH("Core.dll", 0x1011DDA0)
void UObject::execSubtract_IntInt( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSubtract_IntInt);
	P_GET_INT(A);
	P_GET_INT(B);
	*(INT*)Result = A - B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 147, execSubtract_IntInt );

IMPL_MATCH("Core.dll", 0x1011DC10)
void UObject::execMultiply_IntInt( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execMultiply_IntInt);
	P_GET_INT(A);
	P_GET_INT(B);
	*(INT*)Result = A * B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 144, execMultiply_IntInt );

IMPL_MATCH("Core.dll", 0x1011DC90)
void UObject::execDivide_IntInt( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execDivide_IntInt);
	P_GET_INT(A);
	P_GET_INT(B);
	*(INT*)Result = B ? A/B : 0;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 145, execDivide_IntInt );

IMPL_MATCH("Core.dll", 0x1011DBB0)
void UObject::execSubtract_PreInt( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSubtract_PreInt);
	P_GET_INT(A);
	*(INT*)Result = -A;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 143, execSubtract_PreInt );

IMPL_MATCH("Core.dll", 0x1011DAD0)
void UObject::execComplement_PreInt( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execComplement_PreInt);
	P_GET_INT(A);
	*(INT*)Result = ~A;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 141, execComplement_PreInt );

IMPL_MATCH("Core.dll", 0x1011E280)
void UObject::execAnd_IntInt( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execAnd_IntInt);
	P_GET_INT(A);
	P_GET_INT(B);
	*(INT*)Result = A & B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 156, execAnd_IntInt );

IMPL_MATCH("Core.dll", 0x1011E380)
void UObject::execOr_IntInt( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execOr_IntInt);
	P_GET_INT(A);
	P_GET_INT(B);
	*(INT*)Result = A | B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 158, execOr_IntInt );

IMPL_MATCH("Core.dll", 0x1011E300)
void UObject::execXor_IntInt( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execXor_IntInt);
	P_GET_INT(A);
	P_GET_INT(B);
	*(INT*)Result = A ^ B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 157, execXor_IntInt );

IMPL_MATCH("Core.dll", 0x1011DE20)
void UObject::execLessLess_IntInt( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execLessLess_IntInt);
	P_GET_INT(A);
	P_GET_INT(B);
	*(INT*)Result = A << B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 148, execLessLess_IntInt );

IMPL_MATCH("Core.dll", 0x1011DEA0)
void UObject::execGreaterGreater_IntInt( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGreaterGreater_IntInt);
	P_GET_INT(A);
	P_GET_INT(B);
	*(INT*)Result = A >> B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 149, execGreaterGreater_IntInt );

IMPL_MATCH("Core.dll", 0x1011DB30)
void UObject::execGreaterGreaterGreater_IntInt( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGreaterGreaterGreater_IntInt);
	P_GET_INT(A);
	P_GET_INT(B);
	*(INT*)Result = ((DWORD)A) >> B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 196, execGreaterGreaterGreater_IntInt );

IMPL_MATCH("Core.dll", 0x1011DF20)
void UObject::execLess_IntInt( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execLess_IntInt);
	P_GET_INT(A);
	P_GET_INT(B);
	*(DWORD*)Result = A < B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 150, execLess_IntInt );

IMPL_MATCH("Core.dll", 0x1011DFB0)
void UObject::execGreater_IntInt( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGreater_IntInt);
	P_GET_INT(A);
	P_GET_INT(B);
	*(DWORD*)Result = A > B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 151, execGreater_IntInt );

IMPL_MATCH("Core.dll", 0x1011E040)
void UObject::execLessEqual_IntInt( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execLessEqual_IntInt);
	P_GET_INT(A);
	P_GET_INT(B);
	*(DWORD*)Result = A <= B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 152, execLessEqual_IntInt );

IMPL_MATCH("Core.dll", 0x1011E0D0)
void UObject::execGreaterEqual_IntInt( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGreaterEqual_IntInt);
	P_GET_INT(A);
	P_GET_INT(B);
	*(DWORD*)Result = A >= B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 153, execGreaterEqual_IntInt );

IMPL_MATCH("Core.dll", 0x1011E160)
void UObject::execEqualEqual_IntInt( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execEqualEqual_IntInt);
	P_GET_INT(A);
	P_GET_INT(B);
	*(DWORD*)Result = A == B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 154, execEqualEqual_IntInt );

IMPL_MATCH("Core.dll", 0x1011E1F0)
void UObject::execNotEqual_IntInt( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execNotEqual_IntInt);
	P_GET_INT(A);
	P_GET_INT(B);
	*(DWORD*)Result = A != B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 155, execNotEqual_IntInt );

IMPL_MATCH("Core.dll", 0x1011E590)
void UObject::execAddEqual_IntInt( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execAddEqual_IntInt);
	P_GET_INT_REF(A);
	P_GET_INT(B);
	*(INT*)Result = (*A += B);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 161, execAddEqual_IntInt );

IMPL_MATCH("Core.dll", 0x1011E640)
void UObject::execSubtractEqual_IntInt( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSubtractEqual_IntInt);
	P_GET_INT_REF(A);
	P_GET_INT(B);
	*(INT*)Result = (*A -= B);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 162, execSubtractEqual_IntInt );

IMPL_MATCH("Core.dll", 0x1011E400)
void UObject::execMultiplyEqual_IntFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execMultiplyEqual_IntFloat);
	P_GET_INT_REF(A);
	P_GET_FLOAT(B);
	*(INT*)Result = (*A = appTrunc(*A * B));
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 159, execMultiplyEqual_IntFloat );

IMPL_MATCH("Core.dll", 0x1011E4B0)
void UObject::execDivideEqual_IntFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execDivideEqual_IntFloat);
	P_GET_INT_REF(A);
	P_GET_FLOAT(B);
	*(INT*)Result = B!=0.f ? (*A = appTrunc(*A / B)) : 0;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 160, execDivideEqual_IntFloat );

IMPL_MATCH("Core.dll", 0x1011E6F0)
void UObject::execAddAdd_PreInt( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execAddAdd_PreInt);
	P_GET_INT_REF(A);
	*(INT*)Result = ++(*A);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 163, execAddAdd_PreInt );

IMPL_MATCH("Core.dll", 0x1011E780)
void UObject::execSubtractSubtract_PreInt( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSubtractSubtract_PreInt);
	P_GET_INT_REF(A);
	*(INT*)Result = --(*A);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 164, execSubtractSubtract_PreInt );

IMPL_MATCH("Core.dll", 0x1011E810)
void UObject::execAddAdd_Int( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execAddAdd_Int);
	P_GET_INT_REF(A);
	*(INT*)Result = (*A)++;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 165, execAddAdd_Int );

IMPL_MATCH("Core.dll", 0x1011E8A0)
void UObject::execSubtractSubtract_Int( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSubtractSubtract_Int);
	P_GET_INT_REF(A);
	*(INT*)Result = (*A)--;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 166, execSubtractSubtract_Int );

/*-----------------------------------------------------------------------------
	Native byte operators.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x1011D730)
void UObject::execAddEqual_ByteByte( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execAddEqual_ByteByte);
	P_GET_BYTE_REF(A);
	P_GET_BYTE(B);
	*(BYTE*)Result = (*A += B);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 135, execAddEqual_ByteByte );

IMPL_MATCH("Core.dll", 0x1011D7E0)
void UObject::execSubtractEqual_ByteByte( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSubtractEqual_ByteByte);
	P_GET_BYTE_REF(A);
	P_GET_BYTE(B);
	*(BYTE*)Result = (*A -= B);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 136, execSubtractEqual_ByteByte );

IMPL_MATCH("Core.dll", 0x1011D5C0)
void UObject::execMultiplyEqual_ByteByte( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execMultiplyEqual_ByteByte);
	P_GET_BYTE_REF(A);
	P_GET_BYTE(B);
	*(BYTE*)Result = (*A *= B);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 133, execMultiplyEqual_ByteByte );

IMPL_MATCH("Core.dll", 0x1011D670)
void UObject::execDivideEqual_ByteByte( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execDivideEqual_ByteByte);
	P_GET_BYTE_REF(A);
	P_GET_BYTE(B);
	*(BYTE*)Result = B ? (*A /= B) : 0;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 134, execDivideEqual_ByteByte );

IMPL_MATCH("Core.dll", 0x1011D890)
void UObject::execAddAdd_PreByte( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execAddAdd_PreByte);
	P_GET_BYTE_REF(A);
	*(BYTE*)Result = ++(*A);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 137, execAddAdd_PreByte );

IMPL_MATCH("Core.dll", 0x1011D920)
void UObject::execSubtractSubtract_PreByte( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSubtractSubtract_PreByte);
	P_GET_BYTE_REF(A);
	*(BYTE*)Result = --(*A);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 138, execSubtractSubtract_PreByte );

IMPL_MATCH("Core.dll", 0x1011D9B0)
void UObject::execAddAdd_Byte( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execAddAdd_Byte);
	P_GET_BYTE_REF(A);
	*(BYTE*)Result = (*A)++;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 139, execAddAdd_Byte );

IMPL_MATCH("Core.dll", 0x1011DA40)
void UObject::execSubtractSubtract_Byte( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSubtractSubtract_Byte);
	P_GET_BYTE_REF(A);
	*(BYTE*)Result = (*A)--;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 140, execSubtractSubtract_Byte );

/*-----------------------------------------------------------------------------
	Native float operators.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x1011EE00)
void UObject::execAdd_FloatFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execAdd_FloatFloat);
	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	*(FLOAT*)Result = A + B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 174, execAdd_FloatFloat );

IMPL_MATCH("Core.dll", 0x1011EE80)
void UObject::execSubtract_FloatFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSubtract_FloatFloat);
	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	*(FLOAT*)Result = A - B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 175, execSubtract_FloatFloat );

IMPL_MATCH("Core.dll", 0x1011EC70)
void UObject::execMultiply_FloatFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execMultiply_FloatFloat);
	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	*(FLOAT*)Result = A * B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 171, execMultiply_FloatFloat );

IMPL_MATCH("Core.dll", 0x1011ECF0)
void UObject::execDivide_FloatFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execDivide_FloatFloat);
	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	*(FLOAT*)Result = B!=0.f ? A/B : 0.f;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 172, execDivide_FloatFloat );

IMPL_MATCH("Core.dll", 0x1011ED70)
void UObject::execPercent_FloatFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execPercent_FloatFloat);
	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	*(FLOAT*)Result = B!=0.f ? appFmod(A,B) : 0.f;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 173, execPercent_FloatFloat );

IMPL_MATCH("Core.dll", 0x1011EBE0)
void UObject::execMultiplyMultiply_FloatFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execMultiplyMultiply_FloatFloat);
	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	*(FLOAT*)Result = appPow(A,B);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 170, execMultiplyMultiply_FloatFloat );

IMPL_MATCH("Core.dll", 0x1011EB80)
void UObject::execSubtract_PreFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSubtract_PreFloat);
	P_GET_FLOAT(A);
	*(FLOAT*)Result = -A;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 169, execSubtract_PreFloat );


IMPL_MATCH("Core.dll", 0x1011F370)
void UObject::execMultiplyEqual_FloatFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execMultiplyEqual_FloatFloat);
	P_GET_FLOAT_REF(A);
	P_GET_FLOAT(B);
	*(FLOAT*)Result = (*A *= B);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 182, execMultiplyEqual_FloatFloat );

IMPL_MATCH("Core.dll", 0x1011F420)
void UObject::execDivideEqual_FloatFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execDivideEqual_FloatFloat);
	P_GET_FLOAT_REF(A);
	P_GET_FLOAT(B);
	*(FLOAT*)Result = B!=0.f ? (*A /= B) : 0.f;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 183, execDivideEqual_FloatFloat );

IMPL_MATCH("Core.dll", 0x1011F4D0)
void UObject::execAddEqual_FloatFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execAddEqual_FloatFloat);
	P_GET_FLOAT_REF(A);
	P_GET_FLOAT(B);
	*(FLOAT*)Result = (*A += B);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 184, execAddEqual_FloatFloat );

IMPL_MATCH("Core.dll", 0x1011F580)
void UObject::execSubtractEqual_FloatFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSubtractEqual_FloatFloat);
	P_GET_FLOAT_REF(A);
	P_GET_FLOAT(B);
	*(FLOAT*)Result = (*A -= B);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 185, execSubtractEqual_FloatFloat );

IMPL_MATCH("Core.dll", 0x1011EF00)
void UObject::execLess_FloatFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execLess_FloatFloat);
	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	*(DWORD*)Result = A < B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 176, execLess_FloatFloat );

IMPL_MATCH("Core.dll", 0x1011EFA0)
void UObject::execGreater_FloatFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGreater_FloatFloat);
	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	*(DWORD*)Result = A > B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 177, execGreater_FloatFloat );

IMPL_MATCH("Core.dll", 0x1011F040)
void UObject::execLessEqual_FloatFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execLessEqual_FloatFloat);
	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	*(DWORD*)Result = A <= B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 178, execLessEqual_FloatFloat );

IMPL_MATCH("Core.dll", 0x1011F0E0)
void UObject::execGreaterEqual_FloatFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGreaterEqual_FloatFloat);
	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	*(DWORD*)Result = A >= B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 179, execGreaterEqual_FloatFloat );

IMPL_MATCH("Core.dll", 0x1011F180)
void UObject::execEqualEqual_FloatFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execEqualEqual_FloatFloat);
	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	*(DWORD*)Result = A == B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 180, execEqualEqual_FloatFloat );

IMPL_MATCH("Core.dll", 0x1011F220)
void UObject::execNotEqual_FloatFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execNotEqual_FloatFloat);
	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	*(DWORD*)Result = A != B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 181, execNotEqual_FloatFloat );

IMPL_MATCH("Core.dll", 0x1011F2C0)
void UObject::execComplementEqual_FloatFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execComplementEqual_FloatFloat);
	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	*(DWORD*)Result = Abs(A-B) < (1.e-4);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 210, execComplementEqual_FloatFloat );

/*-----------------------------------------------------------------------------
	Native bool operators.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x1011D270)
void UObject::execNot_PreBool( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execNot_PreBool);
	P_GET_UBOOL(A);
	*(DWORD*)Result = !A;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 129, execNot_PreBool );

IMPL_MATCH("Core.dll", 0x1011D2D0)
void UObject::execEqualEqual_BoolBool( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execEqualEqual_BoolBool);
	P_GET_UBOOL(A);
	P_GET_UBOOL(B);
	*(DWORD*)Result = (!A == !B);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 242, execEqualEqual_BoolBool );

IMPL_MATCH("Core.dll", 0x1011D360)
void UObject::execNotEqual_BoolBool( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execNotEqual_BoolBool);
	P_GET_UBOOL(A);
	P_GET_UBOOL(B);
	*(DWORD*)Result = (!A != !B);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 243, execNotEqual_BoolBool );

IMPL_MATCH("Core.dll", 0x1011D3F0)
void UObject::execAndAnd_BoolBool( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execAndAnd_BoolBool);
	P_GET_UBOOL(A);
	P_GET_SKIP_OFFSET(W);
	if( A )
	{
		P_GET_UBOOL(B);
		*(DWORD*)Result = A && B;
	}
	else
	{
		*(DWORD*)Result = 0;
		Stack.Code += W;
	}
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 130, execAndAnd_BoolBool );

IMPL_MATCH("Core.dll", 0x1011D520)
void UObject::execOrOr_BoolBool( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execOrOr_BoolBool);
	P_GET_UBOOL(A);
	P_GET_SKIP_OFFSET(W);
	if( !A )
	{
		P_GET_UBOOL(B);
		*(DWORD*)Result = A || B;
	}
	else
	{
		*(DWORD*)Result = 1;
		Stack.Code += W;
	}
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 132, execOrOr_BoolBool );

IMPL_MATCH("Core.dll", 0x1011D490)
void UObject::execXorXor_BoolBool( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execXorXor_BoolBool);
	P_GET_UBOOL(A);
	P_GET_UBOOL(B);
	*(DWORD*)Result = !A ^ !B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 131, execXorXor_BoolBool );

/*-----------------------------------------------------------------------------
	Native name operators.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x10122120)
void UObject::execEqualEqual_NameName( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execEqualEqual_NameName);
	P_GET_NAME(A);
	P_GET_NAME(B);
	*(DWORD*)Result = A == B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 254, execEqualEqual_NameName );

IMPL_MATCH("Core.dll", 0x101221B0)
void UObject::execNotEqual_NameName( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execNotEqual_NameName);
	P_GET_NAME(A);
	P_GET_NAME(B);
	*(DWORD*)Result = A != B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 255, execNotEqual_NameName );

/*-----------------------------------------------------------------------------
	Native object operators.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x10122240)
void UObject::execEqualEqual_ObjectObject( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execEqualEqual_ObjectObject);
	P_GET_OBJECT(UObject,A);
	P_GET_OBJECT(UObject,B);
	*(DWORD*)Result = A == B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 114, execEqualEqual_ObjectObject );

IMPL_MATCH("Core.dll", 0x101222D0)
void UObject::execNotEqual_ObjectObject( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execNotEqual_ObjectObject);
	P_GET_OBJECT(UObject,A);
	P_GET_OBJECT(UObject,B);
	*(DWORD*)Result = A != B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 119, execNotEqual_ObjectObject );

/*-----------------------------------------------------------------------------
	Native string operators.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x10124010)
void UObject::execConcat_StringString( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execConcat_StringString);
	P_GET_STR(A);
	P_GET_STR(B);
	*(FString*)Result = A + B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 112, execConcat_StringString );

IMPL_MATCH("Core.dll", 0x10124190)
void UObject::execAt_StringString( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execAt_StringString);
	P_GET_STR(A);
	P_GET_STR(B);
	*(FString*)Result = A + TEXT(" ") + B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 168, execAt_StringString );

IMPL_MATCH("Core.dll", 0x10124350)
void UObject::execLess_StringString( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execLess_StringString);
	P_GET_STR(A);
	P_GET_STR(B);
	*(DWORD*)Result = appStricmp(*A, *B) < 0;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 115, execLess_StringString );

IMPL_MATCH("Core.dll", 0x10124480)
void UObject::execGreater_StringString( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGreater_StringString);
	P_GET_STR(A);
	P_GET_STR(B);
	*(DWORD*)Result = appStricmp(*A, *B) > 0;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 116, execGreater_StringString );

IMPL_MATCH("Core.dll", 0x101245B0)
void UObject::execLessEqual_StringString( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execLessEqual_StringString);
	P_GET_STR(A);
	P_GET_STR(B);
	*(DWORD*)Result = appStricmp(*A, *B) <= 0;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 120, execLessEqual_StringString );

IMPL_MATCH("Core.dll", 0x101246E0)
void UObject::execGreaterEqual_StringString( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGreaterEqual_StringString);
	P_GET_STR(A);
	P_GET_STR(B);
	*(DWORD*)Result = appStricmp(*A, *B) >= 0;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 121, execGreaterEqual_StringString );

IMPL_MATCH("Core.dll", 0x10124810)
void UObject::execEqualEqual_StringString( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execEqualEqual_StringString);
	P_GET_STR(A);
	P_GET_STR(B);
	*(DWORD*)Result = appStricmp(*A, *B)==0;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 122, execEqualEqual_StringString );

IMPL_MATCH("Core.dll", 0x10124940)
void UObject::execNotEqual_StringString( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execNotEqual_StringString);
	P_GET_STR(A);
	P_GET_STR(B);
	*(DWORD*)Result = appStricmp(*A, *B)!=0;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 123, execNotEqual_StringString );

IMPL_MATCH("Core.dll", 0x10124A70)
void UObject::execComplementEqual_StringString( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execComplementEqual_StringString);
	P_GET_STR(A);
	P_GET_STR(B);
	*(DWORD*)Result = appStricmp(*A, *B)==0;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 124, execComplementEqual_StringString );

IMPL_MATCH("Core.dll", 0x10124BA0)
void UObject::execLen( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execLen);
	P_GET_STR(S);
	*(INT*)Result = S.Len();
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 125, execLen );

IMPL_MATCH("Core.dll", 0x10124C60)
void UObject::execInStr( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execInStr);
	P_GET_STR(S);
	P_GET_STR(T);
	*(INT*)Result = S.InStr(T);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 126, execInStr );

IMPL_MATCH("Core.dll", 0x10126890)
void UObject::execMid( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execMid);
	P_GET_STR(S);
	P_GET_INT(I);
	P_GET_INT_OPTX(C, 65535);
	*(FString*)Result = S.Mid(I,C);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 127, execMid );

IMPL_MATCH("Core.dll", 0x10126A00)
void UObject::execLeft( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execLeft);
	P_GET_STR(S);
	P_GET_INT(I);
	*(FString*)Result = S.Left(I);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 128, execLeft );

IMPL_MATCH("Core.dll", 0x10124D80)
void UObject::execRight( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execRight);
	P_GET_STR(S);
	P_GET_INT(I);
	*(FString*)Result = S.Right(I);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 234, execRight );

IMPL_MATCH("Core.dll", 0x10124ED0)
void UObject::execCaps( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execCaps);
	P_GET_STR(S);
	*(FString*)Result = S.Caps();
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 235, execCaps );

IMPL_MATCH("Core.dll", 0x10121FD0)
void UObject::execChr( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execChr);
	P_GET_INT(I);
	TCHAR Temp[2];
	Temp[0] = (TCHAR)I;
	Temp[1] = 0;
	*(FString*)Result = Temp;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 236, execChr );

IMPL_MATCH("Core.dll", 0x101252B0)
void UObject::execAsc( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execAsc);
	P_GET_STR(S);
	*(INT*)Result = S.Len() ? (**S) : 0;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 237, execAsc );

IMPL_TODO("execLocs: Ravenshield addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execLocs( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execLocs);
	P_GET_STR(S);
	*(FString*)Result = S.Locs();
	unguardexecSlow;
}

/*-----------------------------------------------------------------------------
	Native math functions.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x1011F630)
void UObject::execAbs( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execAbs);
	P_GET_FLOAT(A);
	*(FLOAT*)Result = Abs(A);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 186, execAbs );

IMPL_MATCH("Core.dll", 0x1011F6B0)
void UObject::execSin( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSin);
	P_GET_FLOAT(A);
	*(FLOAT*)Result = appSin(A);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 187, execSin );

IMPL_MATCH("Core.dll", 0x1011F790)
void UObject::execCos( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execCos);
	P_GET_FLOAT(A);
	*(FLOAT*)Result = appCos(A);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 188, execCos );

IMPL_MATCH("Core.dll", 0x1011F870)
void UObject::execTan( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execTan);
	P_GET_FLOAT(A);
	*(FLOAT*)Result = appTan(A);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 189, execTan );

IMPL_MATCH("Core.dll", 0x1011F8E0)
void UObject::execAtan( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execAtan);
	P_GET_FLOAT(A);
	*(FLOAT*)Result = appAtan(A);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 190, execAtan );

IMPL_MATCH("Core.dll", 0x1011F800)
void UObject::execAcos( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execAcos);
	P_GET_FLOAT(A);
	*(FLOAT*)Result = appAcos(A);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 0, execAcos );

IMPL_MATCH("Core.dll", 0x1011F720)
void UObject::execAsin( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execAsin);
	P_GET_FLOAT(A);
	*(FLOAT*)Result = appAsin(A);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 0, execAsin );

IMPL_MATCH("Core.dll", 0x1011F950)
void UObject::execExp( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execExp);
	P_GET_FLOAT(A);
	*(FLOAT*)Result = appExp(A);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 191, execExp );

IMPL_MATCH("Core.dll", 0x1011F9C0)
void UObject::execLoge( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execLoge);
	P_GET_FLOAT(A);
	*(FLOAT*)Result = appLoge(A);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 192, execLoge );

IMPL_MATCH("Core.dll", 0x1011FA30)
void UObject::execSqrt( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSqrt);
	P_GET_FLOAT(A);
	*(FLOAT*)Result = appSqrt( Abs(A) );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 193, execSqrt );

IMPL_MATCH("Core.dll", 0x1011FAA0)
void UObject::execSquare( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSquare);
	P_GET_FLOAT(A);
	*(FLOAT*)Result = Square(A);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 194, execSquare );

IMPL_MATCH("Core.dll", 0x1011FB00)
void UObject::execFRand( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execFRand);
	*(FLOAT*)Result = appFrand();
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 195, execFRand );

IMPL_MATCH("Core.dll", 0x1011E930)
void UObject::execRand( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execRand);
	P_GET_INT(N);
	*(INT*)Result = N>0 ? (appRand() % N) : 0;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 167, execRand );

IMPL_MATCH("Core.dll", 0x1011E9A0)
void UObject::execMin( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execMin);
	P_GET_INT(A);
	P_GET_INT(B);
	*(INT*)Result = Min(A,B);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 249, execMin );

IMPL_MATCH("Core.dll", 0x1011EA30)
void UObject::execMax( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execMax);
	P_GET_INT(A);
	P_GET_INT(B);
	*(INT*)Result = Max(A,B);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 250, execMax );

IMPL_MATCH("Core.dll", 0x1011EAC0)
void UObject::execClamp( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execClamp);
	P_GET_INT(V);
	P_GET_INT(A);
	P_GET_INT(B);
	*(INT*)Result = Clamp(V,A,B);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 251, execClamp );

IMPL_MATCH("Core.dll", 0x1011FC70)
void UObject::execFClamp( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execFClamp);
	P_GET_FLOAT(V);
	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	*(FLOAT*)Result = Clamp(V,A,B);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 246, execFClamp );

IMPL_MATCH("Core.dll", 0x1011FB30)
void UObject::execFMin( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execFMin);
	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	*(FLOAT*)Result = Min(A,B);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 244, execFMin );

IMPL_MATCH("Core.dll", 0x1011FBD0)
void UObject::execFMax( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execFMax);
	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	*(FLOAT*)Result = Max(A,B);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 245, execFMax );

IMPL_MATCH("Core.dll", 0x1011FD50)
void UObject::execLerp( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execLerp);
	P_GET_FLOAT(Alpha);
	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	*(FLOAT*)Result = A + Alpha*(B-A);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 247, execLerp );

IMPL_MATCH("Core.dll", 0x1011FE00)
void UObject::execSmerp( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSmerp);
	P_GET_FLOAT(Alpha);
	P_GET_FLOAT(A);
	P_GET_FLOAT(B);
	FLOAT S = 3.f*Alpha*Alpha - 2.f*Alpha*Alpha*Alpha;
	*(FLOAT*)Result = A + S*(B-A);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 248, execSmerp );

IMPL_TODO("execCeil: Ravenshield addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execCeil( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execCeil);
	P_GET_FLOAT(A);
	*(INT*)Result = appCeil(A);
	unguardexecSlow;
}

IMPL_TODO("execRound: Ravenshield addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execRound( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execRound);
	P_GET_FLOAT(A);
	*(INT*)Result = appRound(A);
	unguardexecSlow;
}

/*-----------------------------------------------------------------------------
	Native vector operators & functions.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x10120430)
void UObject::execAdd_VectorVector( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execAdd_VectorVector);
	P_GET_VECTOR(A);
	P_GET_VECTOR(B);
	*(FVector*)Result = A + B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 215, execAdd_VectorVector );

IMPL_MATCH("Core.dll", 0x101204D0)
void UObject::execSubtract_VectorVector( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSubtract_VectorVector);
	P_GET_VECTOR(A);
	P_GET_VECTOR(B);
	*(FVector*)Result = A - B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 216, execSubtract_VectorVector );

IMPL_MATCH("Core.dll", 0x10120100)
void UObject::execSubtract_PreVector( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSubtract_PreVector);
	P_GET_VECTOR(A);
	*(FVector*)Result = -A;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 211, execSubtract_PreVector );


IMPL_MATCH("Core.dll", 0x10120180)
void UObject::execMultiply_VectorFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execMultiply_VectorFloat);
	P_GET_VECTOR(A);
	P_GET_FLOAT(B);
	*(FVector*)Result = A * B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 212, execMultiply_VectorFloat );

IMPL_MATCH("Core.dll", 0x10120230)
void UObject::execMultiply_FloatVector( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execMultiply_FloatVector);
	P_GET_FLOAT(A);
	P_GET_VECTOR(B);
	*(FVector*)Result = B * A;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 213, execMultiply_FloatVector );

IMPL_MATCH("Core.dll", 0x101202E0)
void UObject::execMultiply_VectorVector( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execMultiply_VectorVector);
	P_GET_VECTOR(A);
	P_GET_VECTOR(B);
	*(FVector*)Result = FVector(A.X*B.X, A.Y*B.Y, A.Z*B.Z);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 296, execMultiply_VectorVector );

IMPL_MATCH("Core.dll", 0x10120380)
void UObject::execDivide_VectorFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execDivide_VectorFloat);
	P_GET_VECTOR(A);
	P_GET_FLOAT(B);
	*(FVector*)Result = B!=0.f ? A*(1.f/B) : FVector(0,0,0);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 214, execDivide_VectorFloat );

IMPL_MATCH("Core.dll", 0x10120870)
void UObject::execDot_VectorVector( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execDot_VectorVector);
	P_GET_VECTOR(A);
	P_GET_VECTOR(B);
	*(FLOAT*)Result = A | B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 219, execDot_VectorVector );

IMPL_MATCH("Core.dll", 0x10120900)
void UObject::execCross_VectorVector( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execCross_VectorVector);
	P_GET_VECTOR(A);
	P_GET_VECTOR(B);
	*(FVector*)Result = A ^ B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 220, execCross_VectorVector );

IMPL_MATCH("Core.dll", 0x10120710)
void UObject::execEqualEqual_VectorVector( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execEqualEqual_VectorVector);
	P_GET_VECTOR(A);
	P_GET_VECTOR(B);
	*(DWORD*)Result = A.X==B.X && A.Y==B.Y && A.Z==B.Z;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 217, execEqualEqual_VectorVector );

IMPL_MATCH("Core.dll", 0x101207C0)
void UObject::execNotEqual_VectorVector( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execNotEqual_VectorVector);
	P_GET_VECTOR(A);
	P_GET_VECTOR(B);
	*(DWORD*)Result = A.X!=B.X || A.Y!=B.Y || A.Z!=B.Z;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 218, execNotEqual_VectorVector );

IMPL_MATCH("Core.dll", 0x101209C0)
void UObject::execMultiplyEqual_VectorFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execMultiplyEqual_VectorFloat);
	P_GET_VECTOR_REF(A);
	P_GET_FLOAT(B);
	*(FVector*)Result = (*A *= B);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 221, execMultiplyEqual_VectorFloat );

IMPL_MATCH("Core.dll", 0x10120A90)
void UObject::execMultiplyEqual_VectorVector( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execMultiplyEqual_VectorVector);
	P_GET_VECTOR_REF(A);
	P_GET_VECTOR(B);
	A->X *= B.X; A->Y *= B.Y; A->Z *= B.Z;
	*(FVector*)Result = *A;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 297, execMultiplyEqual_VectorVector );

IMPL_MATCH("Core.dll", 0x10120B50)
void UObject::execDivideEqual_VectorFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execDivideEqual_VectorFloat);
	P_GET_VECTOR_REF(A);
	P_GET_FLOAT(B);
	if( B!=0.f ) *A *= (1.f/B);
	*(FVector*)Result = *A;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 222, execDivideEqual_VectorFloat );

IMPL_MATCH("Core.dll", 0x10120C20)
void UObject::execAddEqual_VectorVector( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execAddEqual_VectorVector);
	P_GET_VECTOR_REF(A);
	P_GET_VECTOR(B);
	*(FVector*)Result = (*A += B);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 223, execAddEqual_VectorVector );

IMPL_MATCH("Core.dll", 0x10120CE0)
void UObject::execSubtractEqual_VectorVector( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSubtractEqual_VectorVector);
	P_GET_VECTOR_REF(A);
	P_GET_VECTOR(B);
	*(FVector*)Result = (*A -= B);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 224, execSubtractEqual_VectorVector );

IMPL_MATCH("Core.dll", 0x10120DA0)
void UObject::execVSize( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execVSize);
	P_GET_VECTOR(A);
	*(FLOAT*)Result = A.Size();
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 225, execVSize );

IMPL_TODO("execVSizeSquared: Ravenshield addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execVSizeSquared( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execVSizeSquared);
	P_GET_VECTOR(A);
	*(FLOAT*)Result = A.SizeSquared();
	unguardexecSlow;
}

IMPL_MATCH("Core.dll", 0x10120E20)
void UObject::execNormal( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execNormal);
	P_GET_VECTOR(A);
	*(FVector*)Result = A.SafeNormal();
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 226, execNormal );

IMPL_MATCH("Core.dll", 0x10121E80)
void UObject::execNormalize( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execNormalize);
	P_GET_ROTATOR(R);
	*(FRotator*)Result = R.IsZero() ? FRotator(0,0,0) : R;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 0, execNormalize );
IMPLEMENT_FUNCTION( UObject, 252, execVRand );

IMPL_MATCH("Core.dll", 0x10121150)
void UObject::execMirrorVectorByNormal( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execMirrorVectorByNormal);
	P_GET_VECTOR(A);
	P_GET_VECTOR(B);
	B = B.SafeNormal();
	*(FVector*)Result = A - 2.f * B * (B | A);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 300, execMirrorVectorByNormal );

IMPL_MATCH("Core.dll", 0x10120E90)
void UObject::execInvert( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execInvert);
	P_GET_VECTOR_REF(X);
	P_GET_VECTOR_REF(Y);
	P_GET_VECTOR_REF(Z);
	// Invert a coordinate system (transpose the 3x3 axis matrix).
	FCoords Coords(FVector(0,0,0), *X, *Y, *Z);
	FCoords Inv = Coords.Transpose();
	*X = Inv.XAxis;
	*Y = Inv.YAxis;
	*Z = Inv.ZAxis;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 227, execInvert );


/*-----------------------------------------------------------------------------
	Rotator / axes functions.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x10121A30)
void UObject::execGetAxes( FFrame& Stack, RESULT_DECL )
{P_GET_VECTOR_REF(X);
	P_GET_VECTOR_REF(Y);
	P_GET_VECTOR_REF(Z);
	// Invert a coordinate system (transpose the 3x3 axis matrix).
	FCoords Coords(FVector(0,0,0), *X, *Y, *Z);
	FCoords Inv = Coords.Transpose();
	*X = Inv.XAxis;
	*Y = Inv.YAxis;
	*Z = Inv.ZAxis;
	guardSlow(UObject::execGetAxes);
	P_GET_ROTATOR(R);
	P_GET_VECTOR_REF(X);
	P_GET_VECTOR_REF(Y);
	P_GET_VECTOR_REF(Z);
	FCoords Coords = GMath.UnitCoords / R;
	*X = Coords.XAxis;
	*Y = Coords.YAxis;
	*Z = Coords.ZAxis;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 229, execGetAxes );

IMPL_MATCH("Core.dll", 0x10121BD0)
void UObject::execGetUnAxes( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGetUnAxes);
	P_GET_ROTATOR(R);
	P_GET_VECTOR_REF(X);
	P_GET_VECTOR_REF(Y);
	P_GET_VECTOR_REF(Z);
	FCoords Coords = GMath.UnitCoords / R;
	*X = FVector( Coords.XAxis.X, Coords.YAxis.X, Coords.ZAxis.X );
	*Y = FVector( Coords.XAxis.Y, Coords.YAxis.Y, Coords.ZAxis.Y );
	*Z = FVector( Coords.XAxis.Z, Coords.YAxis.Z, Coords.ZAxis.Z );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 230, execGetUnAxes );

IMPL_MATCH("Core.dll", 0x10121D70)
void UObject::execOrthoRotation( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execOrthoRotation);
	P_GET_VECTOR(X);
	P_GET_VECTOR(Y);
	P_GET_VECTOR(Z);
	FCoords Coords = FCoords( FVector(0,0,0), X, Y, Z );
	*(FRotator*)Result = Coords.OrthoRotation();
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 253, execOrthoRotation );

IMPL_MATCH("Core.dll", 0x10120570)
void UObject::execLessLess_VectorRotator( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execLessLess_VectorRotator);
	P_GET_VECTOR(V);
	P_GET_ROTATOR(R);
	*(FVector*)Result = FVector( V.TransformVectorBy( GMath.UnitCoords / R ) );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 275, execLessLess_VectorRotator );

IMPL_MATCH("Core.dll", 0x10120640)
void UObject::execGreaterGreater_VectorRotator( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGreaterGreater_VectorRotator);
	P_GET_VECTOR(V);
	P_GET_ROTATOR(R);
	*(FVector*)Result = FVector( V.TransformVectorBy( GMath.UnitCoords * R ) );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 276, execGreaterGreater_VectorRotator );

/*-----------------------------------------------------------------------------
	Rotator operators.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x10121770)
void UObject::execAdd_RotatorRotator( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execAdd_RotatorRotator);
	P_GET_ROTATOR(A);
	P_GET_ROTATOR(B);
	*(FRotator*)Result = A + B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 316, execAdd_RotatorRotator );

IMPL_MATCH("Core.dll", 0x10121800)
void UObject::execSubtract_RotatorRotator( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSubtract_RotatorRotator);
	P_GET_ROTATOR(A);
	P_GET_ROTATOR(B);
	*(FRotator*)Result = A - B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 317, execSubtract_RotatorRotator );

IMPL_MATCH("Core.dll", 0x101213A0)
void UObject::execMultiply_RotatorFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execMultiply_RotatorFloat);
	P_GET_ROTATOR(A);
	P_GET_FLOAT(B);
	*(FRotator*)Result = A * B;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 287, execMultiply_RotatorFloat );

IMPL_MATCH("Core.dll", 0x10121450)
void UObject::execMultiply_FloatRotator( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execMultiply_FloatRotator);
	P_GET_FLOAT(A);
	P_GET_ROTATOR(B);
	*(FRotator*)Result = B * A;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 288, execMultiply_FloatRotator );

IMPL_MATCH("Core.dll", 0x10121500)
void UObject::execDivide_RotatorFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execDivide_RotatorFloat);
	P_GET_ROTATOR(A);
	P_GET_FLOAT(B);
	*(FRotator*)Result = B!=0.f ? A*(1.f/B) : FRotator(0,0,0);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 289, execDivide_RotatorFloat );

IMPL_MATCH("Core.dll", 0x10121260)
void UObject::execEqualEqual_RotatorRotator( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execEqualEqual_RotatorRotator);
	P_GET_ROTATOR(A);
	P_GET_ROTATOR(B);
	*(DWORD*)Result = A.Pitch==B.Pitch && A.Yaw==B.Yaw && A.Roll==B.Roll;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 142, execEqualEqual_RotatorRotator );

IMPL_MATCH("Core.dll", 0x10121300)
void UObject::execNotEqual_RotatorRotator( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execNotEqual_RotatorRotator);
	P_GET_ROTATOR(A);
	P_GET_ROTATOR(B);
	*(DWORD*)Result = A.Pitch!=B.Pitch || A.Yaw!=B.Yaw || A.Roll!=B.Roll;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 203, execNotEqual_RotatorRotator );

IMPL_MATCH("Core.dll", 0x101215B0)
void UObject::execMultiplyEqual_RotatorFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execMultiplyEqual_RotatorFloat);
	P_GET_ROTATOR_REF(A);
	P_GET_FLOAT(B);
	*(FRotator*)Result = (*A *= B);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 290, execMultiplyEqual_RotatorFloat );

IMPL_MATCH("Core.dll", 0x10121690)
void UObject::execDivideEqual_RotatorFloat( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execDivideEqual_RotatorFloat);
	P_GET_ROTATOR_REF(A);
	P_GET_FLOAT(B);
	if(B!=0.f) *A *= (1.f/B);
	*(FRotator*)Result = *A;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 291, execDivideEqual_RotatorFloat );

IMPL_MATCH("Core.dll", 0x10121890)
void UObject::execAddEqual_RotatorRotator( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execAddEqual_RotatorRotator);
	P_GET_ROTATOR_REF(A);
	P_GET_ROTATOR(B);
	*(FRotator*)Result = (*A += B);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 318, execAddEqual_RotatorRotator );

IMPL_MATCH("Core.dll", 0x10121960)
void UObject::execSubtractEqual_RotatorRotator( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSubtractEqual_RotatorRotator);
	P_GET_ROTATOR_REF(A);
	P_GET_ROTATOR(B);
	*(FRotator*)Result = (*A -= B);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 319, execSubtractEqual_RotatorRotator );

IMPL_MATCH("Core.dll", 0x10121F20)
void UObject::execClockwiseFrom_IntInt( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execClockwiseFrom_IntInt);
	P_GET_INT(A);
	P_GET_INT(B);
	*(DWORD*)Result = ((A-B)&0xFFFF) <= 0x8000;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 246+100, execClockwiseFrom_IntInt );

IMPL_TODO("execInitRotRand: Ravenshield addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execInitRotRand( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execInitRotRand);
	P_GET_INT(Seed);
	P_GET_ROTATOR(RMax);
	// Initialize a random rotation within the given range.
	appRandInit( Seed );
	FRotator R;
	R.Pitch = (INT)(appFrand() * RMax.Pitch * 2) - RMax.Pitch;
	R.Yaw   = (INT)(appFrand() * RMax.Yaw * 2) - RMax.Yaw;
	R.Roll  = (INT)(appFrand() * RMax.Roll * 2) - RMax.Roll;
	*(FRotator*)Result = R;
	unguardexecSlow;
}

IMPL_MATCH("Core.dll", 0x101210A0)
void UObject::execRotRand( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execRotRand);
	P_GET_UBOOL_OPTX(bRoll,0);
	*(FRotator*)Result = RotRand(bRoll);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 320, execRotRand );


/*-----------------------------------------------------------------------------
	Quaternion functions.
-----------------------------------------------------------------------------*/

IMPL_TODO("execQuatProduct: Ravenshield addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execQuatProduct( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execQuatProduct);
	P_GET_STRUCT(FQuat,A);
	P_GET_STRUCT(FQuat,B);
	*(FQuat*)Result = A * B;
	unguardexecSlow;
}

IMPL_TODO("execQuatInvert: Ravenshield addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execQuatInvert( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execQuatInvert);
	P_GET_STRUCT(FQuat,A);
	*(FQuat*)Result = FQuat(-A.X,-A.Y,-A.Z,A.W);
	unguardexecSlow;
}

IMPL_TODO("execQuatRotateVector: Ravenshield addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execQuatRotateVector( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execQuatRotateVector);
	P_GET_STRUCT(FQuat,Q);
	P_GET_VECTOR(V);
	// Rotate vector V by quaternion Q: Q * V * Q^-1.
	FQuat VQ(V.X, V.Y, V.Z, 0.f);
	FQuat QInv(-Q.X, -Q.Y, -Q.Z, Q.W);
	FQuat R = Q * VQ * QInv;
	*(FVector*)Result = FVector(R.X, R.Y, R.Z);
	unguardexecSlow;
}

IMPL_TODO("execQuatFindBetween: Ravenshield addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execQuatFindBetween( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execQuatFindBetween);
	P_GET_VECTOR(A);
	P_GET_VECTOR(B);
	// Find quaternion that rotates unit vector A to unit vector B.
	A = A.SafeNormal();
	B = B.SafeNormal();
	FVector Cross = A ^ B;
	FLOAT Dot = A | B;
	FLOAT W = appSqrt((A | A) * (B | B)) + Dot;
	FQuat R(Cross.X, Cross.Y, Cross.Z, W);
	FLOAT Size = appSqrt(R.X*R.X + R.Y*R.Y + R.Z*R.Z + R.W*R.W);
	if( Size > SMALL_NUMBER )
	{
		FLOAT InvSize = 1.f / Size;
		R.X *= InvSize; R.Y *= InvSize; R.Z *= InvSize; R.W *= InvSize;
	}
	*(FQuat*)Result = R;
	unguardexecSlow;
}

IMPL_TODO("execQuatFromAxisAndAngle: Ravenshield addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execQuatFromAxisAndAngle( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execQuatFromAxisAndAngle);
	P_GET_VECTOR(Axis);
	P_GET_FLOAT(Angle);
	FQuat AngAxis(Axis.X, Axis.Y, Axis.Z, Angle);
	*(FQuat*)Result = AngAxis.AngAxisToFQuat();
	unguardexecSlow;
}

/*-----------------------------------------------------------------------------
	InterpCurve functions.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x10126790)
void UObject::execInterpCurveEval( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execInterpCurveEval);
	P_GET_STRUCT(FInterpCurve,Curve);
	P_GET_FLOAT(Input);
	*(FLOAT*)Result = Curve.Eval( Input );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 0, execInterpCurveEval );

IMPL_TODO("execInterpCurveGetInputDomain: Ravenshield addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execInterpCurveGetInputDomain( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execInterpCurveGetInputDomain);
	P_GET_STRUCT(FInterpCurve,Curve);
	P_GET_FLOAT_REF(Min);
	P_GET_FLOAT_REF(Max);
	if( Curve.Points.Num() > 0 )
	{
		*Min = Curve.Points(0).InVal;
		*Max = Curve.Points(Curve.Points.Num()-1).InVal;
	}
	else
	{
		*Min = 0.f;
		*Max = 0.f;
	}
	unguardexecSlow;
}

IMPL_TODO("execInterpCurveGetOutputRange: Ravenshield addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execInterpCurveGetOutputRange( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execInterpCurveGetOutputRange);
	P_GET_STRUCT(FInterpCurve,Curve);
	P_GET_FLOAT_REF(Min);
	P_GET_FLOAT_REF(Max);
	*Min = +BIG_NUMBER;
	*Max = -BIG_NUMBER;
	for( INT i=0; i<Curve.Points.Num(); i++ )
	{
		if( Curve.Points(i).OutVal < *Min ) *Min = Curve.Points(i).OutVal;
		if( Curve.Points(i).OutVal > *Max ) *Max = Curve.Points(i).OutVal;
	}
	if( Curve.Points.Num() == 0 )
	{
		*Min = 0.f;
		*Max = 0.f;
	}
	unguardexecSlow;
}

/*-----------------------------------------------------------------------------
	Dynamic array operations.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x1011C160)
void UObject::execDynArrayLength( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execDynArrayLength);
	GProperty = NULL;
	Stack.Step( Stack.Object, NULL );
	if( GPropAddr )
	{
		FArray* Array = (FArray*)GPropAddr;
		*(INT*)Result = Array->Num();
	}
	else
	{
		*(INT*)Result = 0;
	}
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 0x35, execDynArrayLength );

IMPL_MATCH("Core.dll", 0x10123170)
void UObject::execDynArrayInsert( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execDynArrayInsert);
	GProperty = NULL;
	Stack.Step( Stack.Object, NULL );
	P_GET_INT(Index);
	P_GET_INT(Count);
	if( GPropAddr && GProperty )
	{
		UArrayProperty* ArrayProp = CastChecked<UArrayProperty>( GProperty );
		FArray* Array = (FArray*)GPropAddr;
		Array->Insert( Index, Count, ArrayProp->Inner->ElementSize );
		appMemzero( (BYTE*)Array->GetData() + Index*ArrayProp->Inner->ElementSize, Count*ArrayProp->Inner->ElementSize );
	}
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 0, execDynArrayInsert );

IMPL_MATCH("Core.dll", 0x1011C1C0)
void UObject::execDynArrayRemove( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execDynArrayRemove);
	GProperty = NULL;
	Stack.Step( Stack.Object, NULL );
	P_GET_INT(Index);
	P_GET_INT(Count);
	if( GPropAddr && GProperty )
	{
		UArrayProperty* ArrayProp = CastChecked<UArrayProperty>( GProperty );
		FArray* Array = (FArray*)GPropAddr;
		for( INT i=Index; i<Index+Count && i<Array->Num(); i++ )
			ArrayProp->Inner->DestroyValue( (BYTE*)Array->GetData() + i*ArrayProp->Inner->ElementSize );
		Array->Remove( Index, Count, ArrayProp->Inner->ElementSize );
	}
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 0, execDynArrayRemove );

/*-----------------------------------------------------------------------------
	Object functions.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x1011B9B0)
void UObject::execIsA( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execIsA);
	P_GET_NAME(ClassName);
	UClass* TempClass;
	for( TempClass=GetClass(); TempClass; TempClass=(UClass*)TempClass->SuperField )
		if( TempClass->GetFName() == ClassName )
			break;
	*(DWORD*)Result = (TempClass!=NULL);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 197+106, execIsA );

IMPL_MATCH("Core.dll", 0x10122360)
void UObject::execClassIsChildOf( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execClassIsChildOf);
	P_GET_OBJECT(UClass,K);
	P_GET_OBJECT(UClass,C);
	*(DWORD*)Result = (K && C) ? K->IsChildOf(C) : 0;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 258, execClassIsChildOf );

IMPL_MATCH("Core.dll", 0x101262C0)
void UObject::execDynamicLoadObject( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execDynamicLoadObject);
	P_GET_STR(ObjectName);
	P_GET_OBJECT(UClass,ObjectClass);
	P_GET_UBOOL_OPTX(bMayFail,0);
	*(UObject**)Result = StaticLoadObject( ObjectClass, NULL, *ObjectName, NULL, LOAD_NoWarn|(bMayFail?LOAD_Quiet:0), NULL );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 0, execDynamicLoadObject );

IMPL_MATCH("Core.dll", 0x101263E0)
void UObject::execFindObject( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execFindObject);
	P_GET_STR(ObjectName);
	P_GET_OBJECT(UClass,ObjectClass);
	*(UObject**)Result = StaticFindObject( ObjectClass, NULL, *ObjectName, 0 );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 0, execFindObject );

IMPL_TODO("execCalcDirection: Ravenshield addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execCalcDirection( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execCalcDirection);
	P_GET_VECTOR(A);
	P_GET_VECTOR(B);
	FVector Dir = (B - A).SafeNormal();
	*(FLOAT*)Result = appAtan2(Dir.Y, Dir.X) * (32768.f / PI);
	unguardexecSlow;
}

IMPL_TODO("execCalcRotation: Ravenshield addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execCalcRotation( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execCalcRotation);
	P_GET_VECTOR(Dir);
	*(FRotator*)Result = Dir.Rotation();
	unguardexecSlow;
}

static const TCHAR* GCompressedStringPrefix = TEXT("R6C1:");

IMPL_TODO("unexported Core.dll internal helper; small and characterizable — verify against Core.dll Ghidra unnamed function matching the signature")
static void FStringToAnsiBytes( const FString& In, TArray<BYTE>& OutBytes )
{
	const TCHAR* Chars = *In;
	const INT Count = appStrlen( Chars );
	OutBytes.Empty( Count );
	OutBytes.Add( Count );
	for( INT i=0; i<Count; i++ )
		OutBytes(i) = ToAnsi( Chars[i] );
}

IMPL_TODO("unexported Core.dll internal helper; small and characterizable — verify against Core.dll Ghidra unnamed function matching the signature")
static FString AnsiBytesToFString( const TArray<BYTE>& InBytes )
{
	FString Out;
	Out.GetCharArray().Empty( InBytes.Num() + 1 );
	Out.GetCharArray().Add( InBytes.Num() + 1 );
	for( INT i=0; i<InBytes.Num(); i++ )
		Out.GetCharArray()(i) = FromAnsi( (ANSICHAR)InBytes(i) );
	Out.GetCharArray()(InBytes.Num()) = 0;
	return Out;
}

IMPL_TODO("unexported Core.dll internal helper; small and characterizable — verify against Core.dll Ghidra unnamed function matching the signature")
static void RunCodecStage( FCodec& Codec, const TArray<BYTE>& InBytes, TArray<BYTE>& OutBytes, UBOOL Encode )
{
	FBufferReader Reader( InBytes );
	FBufferWriter Writer( OutBytes );
	if( Encode )
		Codec.Encode( Reader, Writer );
	else
		Codec.Decode( Reader, Writer );
}

IMPL_TODO("unexported Core.dll internal helper; small and characterizable — verify against Core.dll Ghidra unnamed function matching the signature")
static void CompressStringBytes( const TArray<BYTE>& InBytes, TArray<BYTE>& OutBytes )
{
	FCodecRLE Stage1;
	FCodecBWT Stage2;
	FCodecMTF Stage3;
	FCodecRLE Stage4;
	FCodecHuffman Stage5;
	TArray<BYTE> Buffer1, Buffer2, Buffer3, Buffer4;
	RunCodecStage( Stage1, InBytes, Buffer1, 1 );
	RunCodecStage( Stage2, Buffer1, Buffer2, 1 );
	RunCodecStage( Stage3, Buffer2, Buffer3, 1 );
	RunCodecStage( Stage4, Buffer3, Buffer4, 1 );
	RunCodecStage( Stage5, Buffer4, OutBytes, 1 );
}

IMPL_TODO("unexported Core.dll internal helper; small and characterizable — verify against Core.dll Ghidra unnamed function matching the signature")
static void ExpandStringBytes( const TArray<BYTE>& InBytes, TArray<BYTE>& OutBytes )
{
	FCodecHuffman Stage1;
	FCodecRLE Stage2;
	FCodecMTF Stage3;
	FCodecBWT Stage4;
	FCodecRLE Stage5;
	TArray<BYTE> Buffer1, Buffer2, Buffer3, Buffer4;
	RunCodecStage( Stage1, InBytes, Buffer1, 0 );
	RunCodecStage( Stage2, Buffer1, Buffer2, 0 );
	RunCodecStage( Stage3, Buffer2, Buffer3, 0 );
	RunCodecStage( Stage4, Buffer3, Buffer4, 0 );
	RunCodecStage( Stage5, Buffer4, OutBytes, 0 );
}

IMPL_TODO("unexported Core.dll internal helper; small and characterizable — verify against Core.dll Ghidra unnamed function matching the signature")
static TCHAR EncodeHexNibble( BYTE Value )
{
	return Value < 10 ? TEXT('0') + Value : TEXT('A') + (Value - 10);
}

IMPL_TODO("unexported Core.dll internal helper; small and characterizable — verify against Core.dll Ghidra unnamed function matching the signature")
static INT DecodeHexNibble( TCHAR Ch )
{
	if( Ch >= TEXT('0') && Ch <= TEXT('9') )
		return Ch - TEXT('0');
	if( Ch >= TEXT('A') && Ch <= TEXT('F') )
		return Ch - TEXT('A') + 10;
	if( Ch >= TEXT('a') && Ch <= TEXT('f') )
		return Ch - TEXT('a') + 10;
	return INDEX_NONE;
}

IMPL_TODO("unexported Core.dll internal helper; small and characterizable — verify against Core.dll Ghidra unnamed function matching the signature")
static FString EncodeCompressedBytes( const TArray<BYTE>& InBytes )
{
	const INT PrefixLen = appStrlen( GCompressedStringPrefix );
	FString Out;
	Out.GetCharArray().Empty( PrefixLen + InBytes.Num() * 2 + 1 );
	Out.GetCharArray().Add( PrefixLen + InBytes.Num() * 2 + 1 );
	for( INT i=0; i<PrefixLen; i++ )
		Out.GetCharArray()(i) = GCompressedStringPrefix[i];
	for( INT i=0; i<InBytes.Num(); i++ )
	{
		Out.GetCharArray()(PrefixLen + i * 2 + 0) = EncodeHexNibble( InBytes(i) >> 4 );
		Out.GetCharArray()(PrefixLen + i * 2 + 1) = EncodeHexNibble( InBytes(i) & 0x0f );
	}
	Out.GetCharArray()(PrefixLen + InBytes.Num() * 2) = 0;
	return Out;
}

IMPL_TODO("unexported Core.dll internal helper; small and characterizable — verify against Core.dll Ghidra unnamed function matching the signature")
static UBOOL DecodeCompressedBytes( const FString& In, TArray<BYTE>& OutBytes )
{
	const TCHAR* Chars = *In;
	const INT PrefixLen = appStrlen( GCompressedStringPrefix );
	if( appStrnicmp( Chars, GCompressedStringPrefix, PrefixLen ) != 0 )
		return 0;

	const TCHAR* HexChars = Chars + PrefixLen;
	const INT HexLen = appStrlen( HexChars );
	if( (HexLen & 1) != 0 )
		return 0;

	OutBytes.Empty( HexLen / 2 );
	OutBytes.Add( HexLen / 2 );
	for( INT i=0; i<OutBytes.Num(); i++ )
	{
		const INT Hi = DecodeHexNibble( HexChars[i * 2 + 0] );
		const INT Lo = DecodeHexNibble( HexChars[i * 2 + 1] );
		if( Hi == INDEX_NONE || Lo == INDEX_NONE )
			return 0;
		OutBytes(i) = (BYTE)((Hi << 4) | Lo);
	}
	return 1;
}

IMPL_TODO("execCompress: Ravenshield addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execCompress( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execCompress);
	P_GET_STR(In);
	TArray<BYTE> SourceBytes, CompressedBytes;
	FStringToAnsiBytes( In, SourceBytes );
	CompressStringBytes( SourceBytes, CompressedBytes );
	// Retail uses the engine codec stack internally. The exact printable string
	// packing is still undocumented, so we wrap the byte stream in a stable ASCII
	// prefix + hex encoding rather than keeping this as a passthrough stub.
	*(FString*)Result = EncodeCompressedBytes( CompressedBytes );
	unguardexecSlow;
}

IMPL_TODO("execExpand: Ravenshield addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execExpand( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execExpand);
	P_GET_STR(In);
	TArray<BYTE> CompressedBytes, ExpandedBytes;
	if( !DecodeCompressedBytes( In, CompressedBytes ) )
		*(FString*)Result = In;
	else
	{
		ExpandStringBytes( CompressedBytes, ExpandedBytes );
		*(FString*)Result = AnsiBytesToFString( ExpandedBytes );
	}
	unguardexecSlow;
}


/*-----------------------------------------------------------------------------
	State/enable/disable functions.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x10122410)
void UObject::execGotoState( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGotoState);
	P_GET_NAME_OPTX(S,NAME_None);
	P_GET_NAME_OPTX(L,NAME_None);
	EGotoState Ret = GotoState( S );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 113, execGotoState );

IMPL_MATCH("Core.dll", 0x10122540)
void UObject::execEnable( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execEnable);
	P_GET_NAME(N);
	UFunction* Func = FindFunctionChecked(N, 0);
	check(Func->FunctionFlags & FUNC_Probe);
	if( StateFrame )
		StateFrame->ProbeMask |= (QWORD)1 << Func->iNative;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 117, execEnable );

IMPL_MATCH("Core.dll", 0x10122620)
void UObject::execDisable( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execDisable);
	P_GET_NAME(N);
	UFunction* Func = FindFunctionChecked(N, 0);
	check(Func->FunctionFlags & FUNC_Probe);
	if( StateFrame )
		StateFrame->ProbeMask &= ~((QWORD)1 << Func->iNative);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 118, execDisable );

IMPL_MATCH("Core.dll", 0x1011B8C0)
void UObject::execIsInState( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execIsInState);
	P_GET_NAME(StateName);
	*(DWORD*)Result = IsInState(StateName);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 281, execIsInState );

IMPL_MATCH("Core.dll", 0x1011B950)
void UObject::execGetStateName( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGetStateName);
	*(FName*)Result = (StateFrame && StateFrame->StateNode) ? StateFrame->StateNode->GetFName() : NAME_None;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 284, execGetStateName );

/*-----------------------------------------------------------------------------
	Logging functions.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x101258A0)
void UObject::execLog( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execLog);
	P_GET_STR(S);
	P_GET_NAME_OPTX(Tag,NAME_ScriptLog);
	if( GLog )
		GLog->Log( (EName)Tag.GetIndex(), *S );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 231, execLog );

IMPL_MATCH("Core.dll", 0x10125AA0)
void UObject::execWarn( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execWarn);
	P_GET_STR(S);
	if( GWarn )
		GWarn->Log( NAME_ScriptWarning, *S );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 232, execWarn );

IMPL_MATCH("Core.dll", 0x10127130)
void UObject::execLocalize( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execLocalize);
	P_GET_STR(SectionName);
	P_GET_STR(KeyName);
	P_GET_STR(PackageName);
	*(FString*)Result = Localize( *SectionName, *KeyName, *PackageName );
	unguardexecSlow;
}
// REMOVED: bare native (iNative=0 in Core.u)
IMPLEMENT_FUNCTION( UObject, 0, execLocalize );

/*-----------------------------------------------------------------------------
	Property get/set functions.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x10125D30)
void UObject::execGetPropertyText( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGetPropertyText);
	P_GET_STR(PropName);
	UProperty* Prop = FindField<UProperty>( GetClass(), *PropName );
	if( Prop )
	{
		TCHAR Temp[1024] = TEXT("");
		Prop->ExportText( 0, Temp, (BYTE*)this, (BYTE*)this, 0 );
		*(FString*)Result = Temp;
	}
	else
	{
		*(FString*)Result = TEXT("");
	}
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 462, execGetPropertyText );

IMPL_MATCH("Core.dll", 0x10125E90)
void UObject::execSetPropertyText( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSetPropertyText);
	P_GET_STR(PropName);
	P_GET_STR(PropValue);
	UProperty* Prop = FindField<UProperty>( GetClass(), *PropName );
	if( Prop )
	{
		Prop->ImportText( *PropValue, (BYTE*)this + Prop->Offset, 0 );
	}
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 0, execSetPropertyText );

/*-----------------------------------------------------------------------------
	Config functions.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x10125FE0)
void UObject::execSaveConfig( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSaveConfig);
	SaveConfig(CPF_Config, NULL);
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 536, execSaveConfig );

IMPL_MATCH("Core.dll", 0x101226D0)
void UObject::execStaticSaveConfig( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execStaticSaveConfig);
	P_FINISH;
	// Save config for the class default object so it persists for all instances.
	GetClass()->GetDefaultObject()->SaveConfig( CPF_Config, NULL );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 537, execStaticSaveConfig );

IMPL_MATCH("Core.dll", 0x101261D0)
void UObject::execResetConfig( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execResetConfig);
	ResetConfig( GetClass(), NULL, 0 );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 0, execResetConfig );

IMPL_MATCH("Core.dll", 0x101227A0)
void UObject::execGetEnum( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGetEnum);
	P_GET_OBJECT(UObject,EnumObj);
	P_GET_INT(Index);
	UEnum* Enum = Cast<UEnum>( EnumObj );
	if( Enum && Index >= 0 && Index < Enum->Names.Num() )
		*(FName*)Result = Enum->Names(Index);
	else
		*(FName*)Result = NAME_None;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 0, execGetEnum );

/*-----------------------------------------------------------------------------
	Ravenshield INI profile functions.
-----------------------------------------------------------------------------*/

IMPL_TODO("execGetPrivateProfileInt: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execGetPrivateProfileInt( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGetPrivateProfileInt);
	P_GET_STR(Section);
	P_GET_STR(Key);
	P_GET_STR(Filename);
	P_GET_INT(Default);
	*(INT*)Result = -1;
	unguardexecSlow;
}

IMPL_TODO("execGetPrivateProfileString: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execGetPrivateProfileString( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGetPrivateProfileString);
	P_GET_STR(Section);
	P_GET_STR(Key);
	P_GET_STR(Filename);
	P_GET_STR(Default);
	*(FString*)Result = Default;
	unguardexecSlow;
}

IMPL_TODO("execSetPrivateProfileInt: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execSetPrivateProfileInt( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSetPrivateProfileInt);
	P_GET_STR(Section);
	P_GET_STR(Key);
	P_GET_INT(Value);
	P_GET_STR(Filename);
	unguardexecSlow;
}

IMPL_TODO("execSetPrivateProfileString: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execSetPrivateProfileString( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSetPrivateProfileString);
	P_GET_STR(Section);
	P_GET_STR(Key);
	P_GET_STR(Value);
	P_GET_STR(Filename);
	unguardexecSlow;
}

IMPL_TODO("execSavePrivateProfile: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execSavePrivateProfile( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSavePrivateProfile);
	P_GET_STR(Filename);
	unguardexecSlow;
}

/*-----------------------------------------------------------------------------
	Ravenshield-specific version/platform/filter functions.
-----------------------------------------------------------------------------*/

IMPL_TODO("execGetPlatform: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execGetPlatform( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGetPlatform);
	*(FString*)Result = TEXT("PC");
	unguardexecSlow;
}

IMPL_TODO("execGetVersionWarfareEngine: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execGetVersionWarfareEngine( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGetVersionWarfareEngine);
	*(INT*)Result = ENGINE_VERSION;
	unguardexecSlow;
}

IMPL_TODO("execGetVersionAGPMajor: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execGetVersionAGPMajor( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGetVersionAGPMajor);
	*(INT*)Result = 1;
	unguardexecSlow;
}

IMPL_TODO("execGetVersionAGPMinor: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execGetVersionAGPMinor( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGetVersionAGPMinor);
	*(INT*)Result = 56;
	unguardexecSlow;
}

IMPL_TODO("execGetVersionAGPTiny: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execGetVersionAGPTiny( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGetVersionAGPTiny);
	*(INT*)Result = 0;
	unguardexecSlow;
}

IMPL_TODO("execIsDebugBuild: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execIsDebugBuild( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execIsDebugBuild);
#ifdef _DEBUG
	*(DWORD*)Result = 1;
#else
	*(DWORD*)Result = 0;
#endif
	unguardexecSlow;
}

IMPL_TODO("execGetMilesOnly: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execGetMilesOnly( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGetMilesOnly);
	*(DWORD*)Result = 0;
	unguardexecSlow;
}

IMPL_TODO("execSetMilesOnly: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execSetMilesOnly( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSetMilesOnly);
	P_GET_UBOOL(bMilesOnly);
	unguardexecSlow;
}

IMPL_TODO("execGetNoBlood: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execGetNoBlood( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGetNoBlood);
	*(DWORD*)Result = 0;
	unguardexecSlow;
}

IMPL_TODO("execSetNoBlood: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execSetNoBlood( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSetNoBlood);
	P_GET_UBOOL(bNoBlood);
	unguardexecSlow;
}

IMPL_TODO("execGetNoSniper: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execGetNoSniper( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGetNoSniper);
	*(DWORD*)Result = 0;
	unguardexecSlow;
}

IMPL_TODO("execSetNoSniper: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execSetNoSniper( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSetNoSniper);
	P_GET_UBOOL(bNoSniper);
	unguardexecSlow;
}

IMPL_TODO("execGetLanguageFilter: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execGetLanguageFilter( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGetLanguageFilter);
	*(FString*)Result = TEXT("");
	unguardexecSlow;
}

IMPL_TODO("execSetLanguageFilter: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execSetLanguageFilter( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSetLanguageFilter);
	P_GET_STR(Filter);
	unguardexecSlow;
}

IMPL_TODO("execGetInputKeyString: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execGetInputKeyString( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGetInputKeyString);
	P_GET_STR(KeyName);
	*(FString*)Result = KeyName;
	unguardexecSlow;
}

IMPL_TODO("execGetBaseDir: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execGetBaseDir( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGetBaseDir);
	*(FString*)Result = appBaseDir();
	unguardexecSlow;
}

/*-----------------------------------------------------------------------------
	Primitive cast handler.
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x1011B440)
void UObject::execPrimitiveCast( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execPrimitiveCast);
	INT B = *(Stack.Code-1);
	(this->*GNatives[B])( Stack, Result );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 0x46, execPrimitiveCast );

/*-----------------------------------------------------------------------------
	Private set handler.
-----------------------------------------------------------------------------*/

// execPrivateSet: body is correct (delegates to Stack.Step). Opcode is CURRENTLY unresolvable
// from text exports: function is not in Core.dll export table; SDK EExprToken enum has no
// EX_PrivateSet entry; Ghidra _global.cpp and _unnamed.cpp contain no reference to the symbol.
// Exhaustive opcode-gap analysis: 0x2B is EX_DelegateFunction, 0x15 is EX_DelegateProperty.
// Remaining unassigned gaps: 0x03, 0x0C (EX_LabelTable), 0x18 (EX_Skip), 0x35, 0x37.
// Until GNatives[] init code is disassembled from the raw binary, no IMPLEMENT_FUNCTION
// can be added safely.
// NOTE: This is IMPL_TODO (not IMPL_DIVERGE) because the opcode IS present in the retail
// binary's GNatives[] table — it is discoverable via binary disassembly of Core.dll's
// initialisation code. Blocked by missing binary analysis, not a permanent constraint.
IMPL_TODO("execPrivateSet: Stack.Step passthrough is correct; opcode requires binary GNatives[] disassembly to determine — gaps 0x03, 0x0C, 0x18, 0x35, 0x37; IMPL_TODO not IMPL_DIVERGE because opcode exists in retail binary")
void UObject::execPrivateSet( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execPrivateSet);
	// Private property access -- step through the property reference.
	Stack.Step( Stack.Object, Result );
	unguardexecSlow;
}

/*-----------------------------------------------------------------------------
	File I/O functions — Ravenshield additions.
	Uses a simple handle table mapping integer handles to FArchive pointers.
-----------------------------------------------------------------------------*/

enum { MAX_SCRIPT_FILE_HANDLES = 64 };
static FArchive* GScriptFileHandles[MAX_SCRIPT_FILE_HANDLES];
static UBOOL GScriptFileHandlesInit = 0;

IMPL_TODO("unexported Core.dll internal helper; small and characterizable — verify against Core.dll Ghidra unnamed function matching the signature")
static void InitFileHandles()
{
	if( !GScriptFileHandlesInit )
	{
		appMemzero( GScriptFileHandles, sizeof(GScriptFileHandles) );
		GScriptFileHandlesInit = 1;
	}
}

IMPL_TODO("unexported Core.dll internal helper; small and characterizable — verify against Core.dll Ghidra unnamed function matching the signature")
static INT AllocFileHandle( FArchive* Ar )
{
	InitFileHandles();
	for( INT i=0; i<MAX_SCRIPT_FILE_HANDLES; i++ )
	{
		if( !GScriptFileHandles[i] )
		{
			GScriptFileHandles[i] = Ar;
			return i;
		}
	}
	delete Ar;
	return -1;
}

IMPL_TODO("unexported Core.dll internal helper; small and characterizable — verify against Core.dll Ghidra unnamed function matching the signature")
static FArchive* GetFileHandle( INT Handle )
{
	InitFileHandles();
	if( Handle >= 0 && Handle < MAX_SCRIPT_FILE_HANDLES )
		return GScriptFileHandles[Handle];
	return NULL;
}

IMPL_TODO("unexported Core.dll internal helper; small and characterizable — verify against Core.dll Ghidra unnamed function matching the signature")
static void FreeFileHandle( INT Handle )
{
	InitFileHandles();
	if( Handle >= 0 && Handle < MAX_SCRIPT_FILE_HANDLES && GScriptFileHandles[Handle] )
	{
		delete GScriptFileHandles[Handle];
		GScriptFileHandles[Handle] = NULL;
	}
}

IMPL_TODO("execFOpen: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execFOpen( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execFOpen);
	P_GET_STR(Filename);
	P_GET_INT(Mode);
	FArchive* Ar = NULL;
	if( Mode == 0 )
		Ar = GFileManager->CreateFileReader( *Filename );
	else
		Ar = GFileManager->CreateFileWriter( *Filename, FILEWRITE_AllowRead );
	*(INT*)Result = Ar ? AllocFileHandle(Ar) : -1;
	unguardexecSlow;
}

IMPL_TODO("execFOpenWrite: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execFOpenWrite( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execFOpenWrite);
	P_GET_STR(Filename);
	FArchive* Ar = GFileManager->CreateFileWriter( *Filename, FILEWRITE_AllowRead );
	*(INT*)Result = Ar ? AllocFileHandle(Ar) : -1;
	unguardexecSlow;
}

IMPL_TODO("execFClose: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execFClose( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execFClose);
	P_GET_INT(Handle);
	FreeFileHandle( Handle );
	unguardexecSlow;
}

IMPL_TODO("execFReadLine: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execFReadLine( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execFReadLine);
	P_GET_INT(Handle);
	FArchive* Ar = GetFileHandle(Handle);
	FString Line;
	if( Ar && !Ar->AtEnd() )
	{
		ANSICHAR Ch;
		while( !Ar->AtEnd() )
		{
			Ar->Serialize( &Ch, 1 );
			if( Ch == '\n' )
				break;
			if( Ch != '\r' )
			{
				TCHAR Buf[2] = { (TCHAR)Ch, 0 };
				Line += Buf;
			}
		}
	}
	*(FString*)Result = Line;
	unguardexecSlow;
}

IMPL_TODO("execFWrite: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execFWrite( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execFWrite);
	P_GET_INT(Handle);
	P_GET_STR(Data);
	FArchive* Ar = GetFileHandle(Handle);
	if( Ar )
	{
		for( INT i=0; i<Data.Len(); i++ )
		{
			ANSICHAR Ch = (ANSICHAR)(*Data)[i];
			Ar->Serialize( &Ch, 1 );
		}
	}
	unguardexecSlow;
}

IMPL_TODO("execFWriteLine: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execFWriteLine( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execFWriteLine);
	P_GET_INT(Handle);
	P_GET_STR(Line);
	FArchive* Ar = GetFileHandle(Handle);
	if( Ar )
	{
		for( INT i=0; i<Line.Len(); i++ )
		{
			ANSICHAR Ch = (ANSICHAR)(*Line)[i];
			Ar->Serialize( &Ch, 1 );
		}
		ANSICHAR Newline[] = { '\r', '\n' };
		Ar->Serialize( Newline, 2 );
	}
	unguardexecSlow;
}

IMPL_TODO("execFLoad: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execFLoad( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execFLoad);
	P_GET_STR(Filename);
	FString Contents;
	FArchive* Ar = GFileManager->CreateFileReader( *Filename );
	if( Ar )
	{
		INT Size = Ar->TotalSize();
		TArray<ANSICHAR> Buffer( Size + 1 );
		Ar->Serialize( &Buffer(0), Size );
		Buffer(Size) = 0;
		delete Ar;
		Contents = ANSI_TO_TCHAR( &Buffer(0) );
	}
	*(FString*)Result = Contents;
	unguardexecSlow;
}

IMPL_TODO("execFUnload: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execFUnload( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execFUnload);
	P_GET_STR(Filename);
	// FUnload is a no-op — file contents are not cached.
	unguardexecSlow;
}

/*-----------------------------------------------------------------------------
	Log file functions — Ravenshield additions.
-----------------------------------------------------------------------------*/

IMPL_TODO("execLogFileOpen: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execLogFileOpen( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execLogFileOpen);
	P_GET_STR(Filename);
	FArchive* Ar = GFileManager->CreateFileWriter( *Filename, FILEWRITE_AllowRead | FILEWRITE_Append );
	*(INT*)Result = Ar ? AllocFileHandle(Ar) : -1;
	unguardexecSlow;
}

IMPL_TODO("execLogFileClose: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execLogFileClose( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execLogFileClose);
	P_GET_INT(Handle);
	FreeFileHandle( Handle );
	unguardexecSlow;
}

IMPL_TODO("execLogFileWrite: Ravenshield R6 addition compiled into Core.dll but not exported — verify implementation against Core.dll Ghidra unnamed function")
void UObject::execLogFileWrite( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execLogFileWrite);
	P_GET_INT(Handle);
	P_GET_STR(Line);
	FArchive* Ar = GetFileHandle(Handle);
	if( Ar )
	{
		for( INT i=0; i<Line.Len(); i++ )
		{
			ANSICHAR Ch = (ANSICHAR)(*Line)[i];
			Ar->Serialize( &Ch, 1 );
		}
		ANSICHAR Newline[] = { '\r', '\n' };
		Ar->Serialize( Newline, 2 );
	}
	unguardexecSlow;
}

/*-----------------------------------------------------------------------------
	Ravenshield R6CODE native functions.
	Ordinals from Object.uc native declarations.
-----------------------------------------------------------------------------*/

// native(1227)
IMPL_MATCH("Core.dll", 0x10125370)
void UObject::execItoa( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execItoa);
	P_GET_INT(i);
	P_FINISH;
	*(FString*)Result = FString::Printf( TEXT("%i"), i );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 1227, execItoa );

// native(1228)
IMPL_MATCH("Core.dll", 0x10125470)
void UObject::execAtoi( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execAtoi);
	P_GET_STR(S);
	P_FINISH;
	*(INT*)Result = appAtoi( *S );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 1228, execAtoi );

// native(1306)
IMPL_MATCH("Core.dll", 0x10125160)
void UObject::execStrnicmp( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execStrnicmp);
	P_GET_STR(A);
	P_GET_STR(B);
	P_GET_INT(iCount);
	P_FINISH;
	*(INT*)Result = appStrnicmp( *A, *B, iCount );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 1306, execStrnicmp );

// native(238) R6CODE — RemoveInvalidChars replaces Localize at this index.
IMPL_MATCH("Core.dll", 0x10125000)
void UObject::execRemoveInvalidChars( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execRemoveInvalidChars);
	P_GET_STR(S);
	P_FINISH;
	// Strip characters that are invalid for filenames/names.
	FString Clean;
	const TCHAR* Str = *S;
	for( INT i=0; i<S.Len(); i++ )
	{
		TCHAR C = Str[i];
		if( C != '/' && C != '\\' && C != ':' && C != '*' && C != '?' && C != '"' && C != '<' && C != '>' && C != '|' )
			Clean += FString::Printf( TEXT("%c"), C );
	}
	*(FString*)Result = Clean;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 238, execRemoveInvalidChars );

// native(2718)
IMPL_MATCH("Core.dll", 0x101259A0)
void UObject::execLogSnd( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execLogSnd);
	P_GET_STR(S);
	P_GET_NAME_OPTX(Tag,NAME_None);
	P_FINISH;
	if( Tag != NAME_None )
		debugf( NAME_Log, TEXT("%s: %s"), *Tag, *S );
	else
		debugf( NAME_Log, TEXT("LogSnd: %s"), *S );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 2718, execLogSnd );

// native(1010)
IMPL_MATCH("Core.dll", 0x101260E0)
void UObject::execLoadConfig( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execLoadConfig);
	P_GET_STR_OPTX(FileName,TEXT(""));
	P_FINISH;
	LoadConfig( 0, NULL, FileName.Len() ? *FileName : NULL );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 1010, execLoadConfig );

// Static state for package-class iteration (mirrors DAT_101cea80/84/DAT_101ca668 in retail)
static UObject*         GPkgIterPackage  = NULL;
static UClass*          GPkgIterClass    = NULL;
static TArray<UClass*>* GPkgIterArray    = NULL;
static INT              GPkgIterIndex    = 0;

// native(1005)
IMPL_MATCH("Core.dll", 0x10126B50)
void UObject::execGetFirstPackageClass( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGetFirstPackageClass);
	P_GET_STR(Package);
	P_GET_OBJECT(UClass,ObjectClass);
	P_FINISH;

	// Free any previous iteration state.
	if( GPkgIterArray )
	{
		delete GPkgIterArray;
		GPkgIterArray = NULL;
	}
	GPkgIterPackage = NULL;
	GPkgIterClass   = ObjectClass;
	GPkgIterIndex   = 0;

	// Load the requested package.
	const TCHAR* PkgName = Package.Len() ? *Package : TEXT("Core");
	GPkgIterPackage = LoadPackage( NULL, PkgName, LOAD_NoWarn );

	// Build an array of classes inside this package that match ObjectClass.
	if( GPkgIterPackage )
	{
		GPkgIterArray = new TArray<UClass*>();
		for( INT i=0; i<GObjObjects.Num(); i++ )
		{
			UObject* Obj = GObjObjects(i);
			if( Obj && Obj->IsA(UClass::StaticClass()) && Obj->IsIn(GPkgIterPackage) )
			{
				if( !GPkgIterClass || ((UClass*)Obj)->IsChildOf(GPkgIterClass) )
					GPkgIterArray->AddItem( (UClass*)Obj );
			}
		}
	}

	*(UClass**)Result = ( GPkgIterArray && GPkgIterArray->Num() > 0 )
		? (*GPkgIterArray)(0) : NULL;
	GPkgIterIndex = 1;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 1005, execGetFirstPackageClass );

// native(1006)
IMPL_MATCH("Core.dll", 0x10126D60)
void UObject::execGetNextClass( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGetNextClass);
	P_FINISH;
	if( GPkgIterArray && GPkgIterIndex < GPkgIterArray->Num() )
		*(UClass**)Result = (*GPkgIterArray)(GPkgIterIndex++);
	else
		*(UClass**)Result = NULL;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 1006, execGetNextClass );

// native(1301)
IMPL_MATCH("Core.dll", 0x10126E50)
void UObject::execRewindToFirstClass( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execRewindToFirstClass);
	P_FINISH;
	GPkgIterIndex = 0;
	*(UClass**)Result = ( GPkgIterArray && GPkgIterArray->Num() > 0 )
		? (*GPkgIterArray)(GPkgIterIndex++) : NULL;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 1301, execRewindToFirstClass );

// native(1007)
IMPL_MATCH("Core.dll", 0x1011B860)
void UObject::execFreePackageObjects( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execFreePackageObjects);
	P_FINISH;
	// Reset iteration state (mirrors DAT_101cea80=0, DAT_101cea84=0, free DAT_101ca668).
	GPkgIterPackage = NULL;
	GPkgIterClass   = NULL;
	GPkgIterIndex   = 0;
	if( GPkgIterArray )
	{
		delete GPkgIterArray;
		GPkgIterArray = NULL;
	}
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 1007, execFreePackageObjects );

// native(1850)
IMPL_MATCH("Core.dll", 0x1011B790)
void UObject::execClearOuter( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execClearOuter);
	P_FINISH;
	Outer = NULL;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 1850, execClearOuter );

// native(1852)
IMPL_MATCH("Core.dll", 0x1011B7C0)
void UObject::execClock( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execClock);
	P_GET_INT(iCounter);
	P_FINISH;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 1852, execClock );

// native(1853)
IMPL_MATCH("Core.dll", 0x1011B810)
void UObject::execUnclock( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execUnclock);
	P_GET_INT(iCounter);
	P_FINISH;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 1853, execUnclock );

// native(1851)
IMPL_MATCH("Core.dll", 0x10122080)
void UObject::execShortestAngle2D( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execShortestAngle2D);
	P_GET_INT(iAngle1);
	P_GET_INT(iAngle2);
	P_FINISH;
	INT Delta = (iAngle2 - iAngle1) & 0xFFFF;
	if( Delta > 0x7FFF )
		Delta -= 0x10000;
	*(INT*)Result = Delta;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 1851, execShortestAngle2D );

// native(1854)
IMPL_MATCH("Core.dll", 0x10125540)
void UObject::execGetRegistryKey( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execGetRegistryKey);
	P_GET_STR(Dir);
	P_GET_STR(Key);
	P_GET_STR_REF(Value);
	P_FINISH;
	FString OutVal;
	INT bSuccess = RegGet( Dir, Key, OutVal );
	if( bSuccess )
		*Value = OutVal;
	*(INT*)Result = bSuccess;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 1854, execGetRegistryKey );

// native(1855)
IMPL_MATCH("Core.dll", 0x10125700)
void UObject::execSetRegistryKey( FFrame& Stack, RESULT_DECL )
{
	guardSlow(UObject::execSetRegistryKey);
	P_GET_STR(Dir);
	P_GET_STR(Key);
	P_GET_STR(Value);
	P_FINISH;
	*(INT*)Result = RegSet( Dir, Key, Value );
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( UObject, 1855, execSetRegistryKey );

/*-----------------------------------------------------------------------------
	UObject::execVRand — script exec stub for VRand().
-----------------------------------------------------------------------------*/

IMPL_MATCH("Core.dll", 0x10121050)
void UObject::execVRand( FFrame& Stack, void* const Result )
{
	P_FINISH;
	*(FVector*)Result = VRand();
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
