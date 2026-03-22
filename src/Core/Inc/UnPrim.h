// ETraceActorFlags normally in UnLevel.h

//
// Trace actor options.
//
enum ETraceActorFlags
{
	// Bitflags.
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

	// Combinations.
	TRACE_Actors             = TRACE_Others | TRACE_LevelGeometry | TRACE_Pawns | TRACE_Movers,
	TRACE_AllBlocking        = TRACE_Pawns | TRACE_Movers | TRACE_Level | TRACE_Volumes | TRACE_Others | TRACE_Blocking | TRACE_LevelGeometry,
	TRACE_AllColliding       = TRACE_Pawns | TRACE_Movers | TRACE_Level | TRACE_Volumes | TRACE_Others | TRACE_LevelGeometry,
	TRACE_Hash               = TRACE_Pawns | TRACE_Movers | TRACE_Volumes | TRACE_Others | TRACE_LevelGeometry,
	TRACE_ProjTargets        = TRACE_Pawns | TRACE_Movers | TRACE_Level | TRACE_Volumes | TRACE_Others | TRACE_OnlyProjActor | TRACE_LevelGeometry,
  	TRACE_World              = TRACE_Movers | TRACE_Level | TRACE_LevelGeometry,
};


/*=============================================================================
	UnPrim.h: Unreal UPrimitive definition.
	Copyright 1997-1999 Epic Games, Inc. All Rights Reserved.

	Revision history:
		* Created by Tim Sweeney
=============================================================================*/

/*-----------------------------------------------------------------------------
	FCheckResult.
-----------------------------------------------------------------------------*/

//
// Results of an actor check.
//
struct FIteratorActorList : public FIteratorList
{
	// Variables.
	AActor* Actor;

	// Functions.
	FIteratorActorList()
	{}
	FIteratorActorList( FIteratorActorList* InNext, AActor* InActor )
	:	FIteratorList	(InNext)
	,	Actor			(InActor)
	{}
	FIteratorActorList* GetNext()
	{ return (FIteratorActorList*) Next; }
};

//
// Results from a collision check.
//
/*
struct CheckResult //extends IteratorActorList
{
    var() Object    Next;       //IteratorList*
    var() Actor     Actor;
    var() vector    Location;   // Location of the hit in coordinate system of the returner.
    var() vector    Normal;     // Normal vector in coordinate system of the returner. Zero=none.
    var() Primitive Primitive;  // Actor primitive which was hit, or NULL=none.
    var() float     Time;       // Time until hit, if line check.
    var() int       Item;       // Primitive data item which was hit, INDEX_NONE=none.
    var() Material  Material;   // Material cached by LineCheck()
}; // CheckResult is duplicated in Material.uc to prevent a circular dependency, please be sure to update both copies.
//OLD
*/
struct FCheckResult : public FIteratorActorList
{
	// Variables.
	FVector		Location;   // Location of the hit in coordinate system of the returner.
	FVector		Normal;     // Normal vector in coordinate system of the returner. Zero=none.
	class UPrimitive*	Primitive;  // Actor primitive which was hit, or NULL=none.
	FLOAT       Time;       // Time until hit, if line check.
	INT			Item;       // Primitive data item which was hit, INDEX_NONE=none.
	class UMaterial*	Material;  // Material cached by LineCheck()
	//INT	Unknown[10];

	// Functions.
	FCheckResult()
	{}
	FCheckResult( FLOAT InTime, FCheckResult* InNext=NULL )
	:	FIteratorActorList( InNext, NULL )
	,	Location	(0,0,0)
	,	Normal		(0,0,0)
	,	Primitive	(NULL)
	,	Time		(InTime)
	,	Item		(INDEX_NONE)
	,	Material	(NULL)
	{}
	FCheckResult*& GetNext()
		{ return *(FCheckResult**)&Next; }
	friend QSORT_RETURN CDECL CompareHits( const FCheckResult* A, const FCheckResult* B )
		{ return A->Time<B->Time ? -1 : A->Time>B->Time ? 1 : 0; }
};

/*-----------------------------------------------------------------------------
	UPrimitive.
-----------------------------------------------------------------------------*/

//
// UPrimitive, the base class of geometric entities capable of being
// rendered and collided with.
//

class ENGINE_API UPrimitive : public UObject
{
	FBox BoundingBox;
	FSphere BoundingSphere;

	virtual ~UPrimitive();
	virtual void Serialize(class FArchive &);
	virtual INT PointCheck(struct FCheckResult &, class AActor *, class FVector, class FVector, DWORD);
	virtual INT LineCheck(struct FCheckResult &, class AActor *, class FVector, class FVector, class FVector, DWORD, DWORD);
	virtual class FBox GetRenderBoundingBox(class AActor const *);
	virtual class FSphere GetRenderBoundingSphere(class AActor const *);
	virtual class FBox GetCollisionBoundingBox(class AActor const *) const;
	virtual INT UseCylinderCollision(class AActor const *);
	virtual void Illuminate(class AActor *, INT);
	virtual class FVector GetEncroachExtent(class AActor *);
	virtual class FVector GetEncroachCenter(class AActor *);
	static void CDECL InternalConstructor(void *);
	static class UClass * CDECL StaticClass();
	UPrimitive(class UPrimitive const &);
	UPrimitive();
	static void * CDECL operator new(unsigned int, class UObject *, class FName, DWORD);
	static void * CDECL operator new(unsigned int, enum EInternal *);
	class UPrimitive & operator=(class UPrimitive const &);
private:
	static class UClass PrivateStaticClass();
};

/*
	virtual UBOOL PointCheck
	(
		FCheckResult	&Result,
		AActor			*Owner,
		FVector			Location,
		FVector			Extent,
		DWORD           ExtraNodeFlags
	);
	virtual UBOOL LineCheck
	(
		FCheckResult	&Result,
		AActor			*Owner,
		FVector			End,
		FVector			Start,
		FVector			Extent,
		DWORD           ExtraNodeFlags
	);
	virtual FBox GetRenderBoundingBox( const AActor* Owner, UBOOL Exact );
	virtual FSphere GetRenderBoundingSphere( const AActor* Owner, UBOOL Exact );
	virtual FBox GetCollisionBoundingBox( const AActor* Owner ) const;
*/