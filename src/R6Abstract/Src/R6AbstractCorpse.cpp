/*=============================================================================
	R6AbstractCorpse.cpp
=============================================================================*/

#include "R6AbstractPrivate.h"

IMPLEMENT_CLASS(AR6AbstractCorpse)

IMPLEMENT_FUNCTION(AR6AbstractCorpse, -1, execAddImpulseToBone)
IMPLEMENT_FUNCTION(AR6AbstractCorpse, -1, execFirstInit)
IMPLEMENT_FUNCTION(AR6AbstractCorpse, -1, execRenderBones)

// --- AR6AbstractCorpse ---

IMPL_EMPTY("Abstract base; overridden in concrete subclass")
void AR6AbstractCorpse::FirstInit(AR6AbstractPawn*) {}
IMPL_EMPTY("Abstract base; overridden in concrete subclass")
void AR6AbstractCorpse::RenderBones(UCanvas*) {}
IMPL_EMPTY("Abstract base; overridden in concrete subclass")
void AR6AbstractCorpse::AddImpulseToBone(INT, FVector) {}

IMPL_MATCH("R6Abstract.dll", 0x10001000)
void AR6AbstractCorpse::execAddImpulseToBone(FFrame& Stack, RESULT_DECL)
{
	P_GET_INT(iTracedBone);
	P_GET_STRUCT(FVector, vMomentum);
	P_FINISH;
	AddImpulseToBone(iTracedBone, vMomentum);
}

IMPL_MATCH("R6Abstract.dll", 0x100011d0)
void AR6AbstractCorpse::execFirstInit(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(AR6AbstractPawn, pawnOwner);
	P_FINISH;
	FirstInit(pawnOwner);
}

IMPL_MATCH("R6Abstract.dll", 0x10001100)
void AR6AbstractCorpse::execRenderBones(FFrame& Stack, RESULT_DECL)
{
	P_GET_OBJECT(UCanvas, C);
	P_FINISH;
	RenderBones(C);
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
