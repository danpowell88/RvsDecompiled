//=============================================================================
//  R6Tracer.uc : Laser tracer
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/07/13 * Created by Sebastien Lussier
//=============================================================================
class R6Tracer extends Effects;

/*#exec OBJ LOAD FILE=..\Textures\R6Reticules.utx PACKAGE=R6Reticules

var BOOL    m_bValidEnd;

var vector  m_vTracerStart;
var vector  m_vTracerEndPoint;
var vector  m_vTracerEndPointNormal;

var Decal   m_decalEndPoint;
var FLOAT   m_fTracerRange;

function PostBeginPlay()
{
    m_decalEndPoint = Spawn( class'Decal', Self );
    
    m_decalEndPoint.DrawType=DT_None;
    m_decalEndPoint.Texture = Texture'R6Reticules.Tracer';
}

simulated function PostRender( Canvas C )
{
    FindTracerEnd();
    UpdateDecalPosition();

    if( m_bValidEnd )
    {
        C.DrawColor.r = 1;
        C.DrawColor.g = 0;
        C.DrawColor.b = 0;
        
        SetLocation( m_vTracerEndPoint );
        C.Draw3DLine( m_vTracerStart, Location );       
    }
}

function UpdateDecalPosition()
{
    if( m_bValidEnd )
    {
        m_decalEndPoint.SetLocation( m_vTracerEndPoint );
        m_decalEndPoint.SetRotation( rotator(m_vTracerEndPointNormal) );
    
        m_decalEndPoint.DetachDecal();
        m_decalEndPoint.AttachDecal( 100, vector(Pawn(Owner.Owner).GetViewRotation()) );
    }
    else
    {
        m_decalEndPoint.DetachDecal();
    }
}

function FindTracerEnd()
{
    local vector	vTraceEnd;
        
    m_vTracerStart = Pawn(Owner.Owner).Location + Pawn(Owner.Owner).EyePosition();
    vTraceEnd = m_vTracerStart + m_fTracerRange * vector( Pawn(Owner.Owner).GetViewRotation() );
    
    if( Trace( m_vTracerEndPoint, m_vTracerEndPointNormal, vTraceEnd, m_vTracerStart, true ) != None )
    {
        m_bValidEnd = true;
    }
    else
    {
        m_bValidEnd = false;
    }
}*/

/*  DrawType=DT_None
    Physics=PHYS_None
    bUnlit=True
    bNetTemporary=true
    bGameRelevant=true
    CollisionRadius=+0.00000
    CollisionHeight=+0.00000
    RemoteRole=ROLE_SimulatedProxy

    LightType=LT_TexturePaletteOnce
    LightEffect=LE_NonIncidence
    LightHue=50
    LightSaturation=255
    LightBrightness=200
    LightRadius=1

    m_bValidEnd=false
    m_fTracerRange=1500.0f;*/

defaultproperties
{
}
