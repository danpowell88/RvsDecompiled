/*=============================================================================
	R6GameServiceHelpers.cpp
	Higher-level helpers that call the GMalloc wrappers defined in
	R6GameService.cpp.  They live in a separate translation unit so the
	compiler emits a real CALL to FUN_10006390 instead of inlining it.
=============================================================================*/

#include "R6GameServicePrivate.h"

#pragma comment(linker, "/include:?FUN_10041530@@YIXPAX@Z")
#pragma comment(linker, "/include:?FUN_10059140@@YIXPAX@Z")

// Forward-declare the Free wrapper (defined in R6GameService.cpp).
// __stdcall because retail's tail-call JMP to __thiscall Free() makes callee clean the arg.
extern void __stdcall FUN_10006390(void* Ptr);

/*-----------------------------------------------------------------------------
	FUN_10041530 — free-member thiscall (9 bytes, blocks 109)
	Frees the first member pointer of a GameSpy internal object.
	__thiscall: ECX = this pointer.
-----------------------------------------------------------------------------*/
IMPL_MATCH("R6GameService.dll", 0x10041530)
void __fastcall FUN_10041530(void* Self)
{
	FUN_10006390(*(void**)Self);
}

/*-----------------------------------------------------------------------------
	FUN_10059140 — linked-list cleanup thiscall (46 bytes, blocks 162)
	Walks a circular doubly-linked list, frees each node, then resets the
	head to self-pointing and frees it too.
	__thiscall: ECX = this (ListOwner*).
	Retail keeps `this` in EDI and reloads `Self->head` from [EDI] each
	time, so the source must use a struct pointer, NOT cache head in a local.
-----------------------------------------------------------------------------*/
struct GSListNode  { GSListNode* next; GSListNode* prev; };
struct GSListOwner { GSListNode* head; };

IMPL_MATCH("R6GameService.dll", 0x10059140)
void __fastcall FUN_10059140(void* Self)
{
	GSListOwner* owner = (GSListOwner*)Self;
	GSListNode* cur = owner->head->next;
	while (cur != owner->head)
	{
		GSListNode* node = cur;
		cur = cur->next;
		FUN_10006390(node);
	}
	owner->head->next = owner->head;
	owner->head->prev = owner->head;
	FUN_10006390(owner->head);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
