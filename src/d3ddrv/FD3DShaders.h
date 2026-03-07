/*=============================================================================
	FD3DShaders.h: D3D8 shader object wrappers.
	Reconstructed for Ravenshield decompilation project — Phase 9A.

	FD3DPixelShader and FD3DVertexShader wrap D3D8 shader program handles.

	D3D8 uses DWORD handles for shaders (not COM objects like D3D9+):
	  - Pixel shaders: IDirect3DDevice8::CreatePixelShader returns a DWORD
	  - Vertex shaders: IDirect3DDevice8::CreateVertexShader returns a DWORD

	Ghidra analysis of GetPixelShader (0x10009720) and GetVertexShader
	(0x1000ab90) shows these are looked up by enum index and cached.
=============================================================================*/

#ifndef _INC_FD3DSHADERS
#define _INC_FD3DSHADERS

#pragma pack(push, 4)

/*-----------------------------------------------------------------------------
	FD3DPixelShader — cached pixel shader program.
-----------------------------------------------------------------------------*/
class FD3DPixelShader
{
public:
	DWORD   Handle;     // D3D8 pixel shader handle (0 = invalid/not created)
	INT     Type;       // EPixelShader enum value

	FD3DPixelShader()
		: Handle(0)
		, Type(PS_None)
	{}

	void Release( IDirect3DDevice8* Device )
	{
		if( Handle && Device )
		{
			Device->DeletePixelShader( Handle );
			Handle = 0;
		}
	}
};

/*-----------------------------------------------------------------------------
	FD3DVertexShader — cached vertex shader program.
-----------------------------------------------------------------------------*/
class FD3DVertexShader
{
public:
	DWORD               Handle;     // D3D8 vertex shader handle (0 = invalid)
	INT                 Type;       // EVertexShader enum value
	FShaderDeclaration  Decl;       // Vertex declaration this shader was created with

	FD3DVertexShader()
		: Handle(0)
		, Type(VS_None)
	{
		appMemzero( &Decl, sizeof(Decl) );
	}

	void Release( IDirect3DDevice8* Device )
	{
		if( Handle && Device )
		{
			Device->DeleteVertexShader( Handle );
			Handle = 0;
		}
	}
};

#pragma pack(pop)

#endif // _INC_FD3DSHADERS
