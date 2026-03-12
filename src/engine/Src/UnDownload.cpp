/*=============================================================================
	UnDownload.cpp: File download system (UDownload hierarchy)
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

// --- UBinaryFileDownload ---
void UBinaryFileDownload::StaticConstructor()
{
}

void UBinaryFileDownload::Tick()
{
}

int UBinaryFileDownload::TrySkipFile()
{
	return 0;
}

// (merged from earlier occurrence)
void UBinaryFileDownload::ReceiveData(BYTE* Data, int Size)
{
	// Retail: 0x189270. Lazy-opens a write-file at path this+0x4C, then appends Data bytes.
	// this+0x44c = bytes received so far; this+0x48 = FArchive* file handle.
	if (*(INT*)((BYTE*)this + 0x44C) == 0 && *(INT*)((BYTE*)this + 0x48) == 0)
	{
		// Create file: GFileManager->OpenFileWrite(this+0x4C path, 0, GNull)
		typedef FArchive* (__thiscall *OpenFn)(void*, void*, INT, void*);
		void** fm = *(void***)GFileManager;
		*(FArchive**)((BYTE*)this + 0x48) = ((OpenFn)(fm[2]))((void*)GFileManager,
			(void*)((BYTE*)this + 0x4C), 0, (void*)GNull);
	}
	FArchive* file = *(FArchive**)((BYTE*)this + 0x48);
	if (Size > 0 && file)
	{
		file->Serialize(Data, Size);
		*(INT*)((BYTE*)this + 0x44C) += Size;
	}
}
void UBinaryFileDownload::ReceiveFile(UNetConnection *,int,const TCHAR*,int)
{
}
void UBinaryFileDownload::Serialize(FArchive& Ar)
{
	// Retail: 0x1891e0. UChannelDownload::Serialize + serialize connection ptr at this+0x458.
	UChannelDownload::Serialize(Ar);
	Ar << *(UObject**)((BYTE*)this + 0x458);
}
void UBinaryFileDownload::Destroy()
{
	// Retail: 0x189a30. Clear connection back-pointer at conn+0x68, call UChannelDownload::Destroy.
	// Diverges: FPackageInfo at this+0x34 is not explicitly freed (forward decl only).
	INT connPtr = *(INT*)((BYTE*)this + 0x458);
	if (connPtr && *(INT*)(connPtr + 0x68) == (INT)this)
		*(INT*)(connPtr + 0x68) = 0;
	*(INT*)((BYTE*)this + 0x458) = 0;
	UChannelDownload::Destroy();
}
void UBinaryFileDownload::DownloadDone()
{
	// Retail: 0x189330. Closes the file write handle and notifies connection.
	// this+0x48 = FArchive* file handle; calls vtable[0x13].Close() then deletes object.
	FArchive* file = *(FArchive**)((BYTE*)this + 0x48);
	if (file)
	{
		INT vtable = *(INT*)file;
		typedef void (__thiscall *CloseFn)(FArchive*);
		((CloseFn)(*(INT*)(vtable + 0x4C)))(file);
		typedef void (__thiscall *DeleteFn)(FArchive*, INT);
		((DeleteFn)(*(INT*)vtable))(file, 1);
		*(INT*)((BYTE*)this + 0x48)  = 0;
		*(INT*)((BYTE*)this + 0x44C) = 0;
	}
}
void UBinaryFileDownload::DownloadError(const TCHAR*)
{
}


// --- UChannelDownload ---
void UChannelDownload::StaticConstructor()
{
}

int UChannelDownload::TrySkipFile()
{
	return 0;
}

void UChannelDownload::ReceiveFile(UNetConnection *,int,const TCHAR*,int)
{
}

void UChannelDownload::Serialize(FArchive &)
{
}

void UChannelDownload::Destroy()
{
}


// --- UDownload ---
void UDownload::StaticConstructor()
{
}

void UDownload::Tick()
{
}

int UDownload::TrySkipFile()
{
	// Retail (28b, RVA 0x188AF0): need the connection object at +0x48 to exist,
	// and the flag at [[this+0x34]+0x40] bit 1 to be set. If so, set +0x450=1 and return 1.
	void* conn = *(void**)((BYTE*)this + 0x48);
	if (!conn) return 0;
	void* channel = *(void**)((BYTE*)this + 0x34);
	if (!(*(BYTE*)((BYTE*)channel + 0x40) & 0x02)) return 0;
	*(INT*)((BYTE*)this + 0x450) = 1;
	return 1;
}

void UDownload::ReceiveData(BYTE*,int)
{
}

void UDownload::ReceiveFile(UNetConnection* Connection, int Channel, const TCHAR* /*Data*/, int /*DataSize*/)
{
	// Retail: 32b. Stores connection/channel, computes channel base offset.
	*(DWORD*)((BYTE*)this + 0x2C) = (DWORD)Connection;
	*(INT*)((BYTE*)this + 0x30) = Channel;
	BYTE* ChannelTable = *(BYTE**)((BYTE*)Connection + 0xC8);
	*(INT*)((BYTE*)this + 0x34) = Channel * 0x44 + *(INT*)(ChannelTable + 0x2C);
}

void UDownload::Serialize(FArchive &)
{
}

void UDownload::Destroy()
{
}

void UDownload::DownloadDone()
{
}

void UDownload::DownloadError(const TCHAR*)
{
}

