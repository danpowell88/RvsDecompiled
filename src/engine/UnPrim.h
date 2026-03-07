/*=============================================================================
	UnPrim.h: UPrimitive definition for Ravenshield Engine module.

	This local header replaces both the CSDK 432Core/Inc/UnPrim.h and the
	UT99 Engine/Inc/UnPrim.h.  It provides the RVS-compatible type layouts
	(Material field in FCheckResult, 7-arg LineCheck) together with the
	DECLARE_CLASS macro that IMPLEMENT_CLASS requires.

	Our local Core.h deliberately skips the CSDK UnPrim.h, so this file
	is the single definition site for these types.
=============================================================================*/

#ifndef _INC_UNPRIM
#define _INC_UNPRIM

/*-----------------------------------------------------------------------------
	ETraceActorFlags — RVS-specific trace options (from CSDK 432Core).
-----------------------------------------------------------------------------*/

enum ETraceActorFlags
{
	TRACE_Pawns              = 0x0001,
	TRACE_Movers             = 0x0002,
	TRACE_Level              = 0x0004,
	TRACE_Volumes            = 0x0008,
	TRACE_Others             = 0x0010,
	TRACE_OnlyProjActor      = 0x0020,
	TRACE_Blocking           = 0x0040,
	TRACE_LevelGeometry      = 0x0080,
	TRACE_ShadowCast         = 0x0100,
	TRACE_StopAtFirstHit     = 0x0200,
	TRACE_SingleResult       = 0x0400,
	TRACE_Debug              = 0x0800,
	TRACE_Material           = 0x1000,
	TRACE_VisibleNonColliding= 0x2000,
	TRACE_Usable             = 0x4000,

	TRACE_Actors             = TRACE_Others | TRACE_LevelGeometry | TRACE_Pawns | TRACE_Movers,
	TRACE_AllBlocking        = TRACE_Pawns | TRACE_Movers | TRACE_Level | TRACE_Volumes | TRACE_Others | TRACE_Blocking | TRACE_LevelGeometry,
	TRACE_AllColliding       = TRACE_Pawns | TRACE_Movers | TRACE_Level | TRACE_Volumes | TRACE_Others | TRACE_LevelGeometry,
	TRACE_Hash               = TRACE_Pawns | TRACE_Movers | TRACE_Volumes | TRACE_Others | TRACE_LevelGeometry,
	TRACE_ProjTargets        = TRACE_Pawns | TRACE_Movers | TRACE_Level | TRACE_Volumes | TRACE_Others | TRACE_OnlyProjActor | TRACE_LevelGeometry,
	TRACE_World              = TRACE_Movers | TRACE_Level | TRACE_LevelGeometry,
};

/*-----------------------------------------------------------------------------
	FCheckResult.
-----------------------------------------------------------------------------*/

struct FIteratorActorList : public FIteratorList
{
	AActor* Actor;
	FIteratorActorList() {}
	FIteratorActorList( FIteratorActorList* InNext, AActor* InActor )
	:	FIteratorList(InNext), Actor(InActor) {}
	FIteratorActorList* GetNext()
	{ return (FIteratorActorList*) Next; }
};

struct FCheckResult : public FIteratorActorList
{
	FVector		Location;
	FVector		Normal;
	class UPrimitive*	Primitive;
	FLOAT		Time;
	INT			Item;
	class UMaterial*	Material;   // RVS addition

	FCheckResult() {}
	FCheckResult( FLOAT InTime, FCheckResult* InNext=NULL )
	:	FIteratorActorList( InNext, NULL )
	,	Location(0,0,0), Normal(0,0,0), Primitive(NULL)
	,	Time(InTime), Item(INDEX_NONE), Material(NULL) {}
	FCheckResult*& GetNext()
		{ return *(FCheckResult**)&Next; }
	friend QSORT_RETURN CDECL CompareHits( const FCheckResult* A, const FCheckResult* B )
		{ return A->Time<B->Time ? -1 : A->Time>B->Time ? 1 : 0; }
};

/*-----------------------------------------------------------------------------
	UPrimitive.
-----------------------------------------------------------------------------*/

class ENGINE_API UPrimitive : public UObject
{
	DECLARE_CLASS(UPrimitive,UObject,0,Engine)

	FBox BoundingBox;
	FSphere BoundingSphere;

	UPrimitive()
	: BoundingBox(0), BoundingSphere(0) {}

	// UObject interface.
	void Serialize( FArchive& Ar );

	// UPrimitive collision interface — RVS signatures (7-arg LineCheck, 1-arg bounding).
	virtual INT PointCheck( FCheckResult& Result, AActor* Owner, FVector Location, FVector Extent, DWORD ExtraNodeFlags );
	virtual INT LineCheck( FCheckResult& Result, AActor* Owner, FVector End, FVector Start, FVector Extent, DWORD ExtraNodeFlags, DWORD ExtraFlags );
	virtual FBox GetRenderBoundingBox( const AActor* Owner );
	virtual FSphere GetRenderBoundingSphere( const AActor* Owner );
	virtual FBox GetCollisionBoundingBox( const AActor* Owner ) const;
	virtual INT UseCylinderCollision( const AActor* Owner );
	virtual void Illuminate( AActor* Owner, INT bDynamic );
	virtual FVector GetEncroachExtent( AActor* Owner );
	virtual FVector GetEncroachCenter( AActor* Owner );
};

#endif
