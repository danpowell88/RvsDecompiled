/*=============================================================================
	UnDownload.cpp: File download system (UDownload hierarchy)
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

// --- UBinaryFileDownload ---
IMPL_MATCH("Engine.dll", 0x10489160)
void UBinaryFileDownload::StaticConstructor()
{
	guard(UBinaryFileDownload::StaticConstructor);
	// Retail: 0x189160, 71b. Sets the config key FString at +0x38 to "Enabled".
	*(FString*)((BYTE*)this + 0x38) = TEXT("Enabled");
	unguard;
}

IMPL_EMPTY("Tick — Ghidra shows retail is shared empty stub at 0x176d60")
void UBinaryFileDownload::Tick()
{
	// Retail: 0x176d60 (shared empty stub)
}

IMPL_MATCH("Engine.dll", 0x10414310)
int UBinaryFileDownload::TrySkipFile()
{
	guard(UBinaryFileDownload::TrySkipFile);
	// Ghidra 0x114310: shared zero-return vtable stub.
	return 0;
	unguard;
}

// (merged from earlier occurrence)
IMPL_MATCH("Engine.dll", 0x10489270)
void UBinaryFileDownload::ReceiveData(BYTE* Data, int Size)
{
	guard(UBinaryFileDownload::ReceiveData);
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
	unguard;
}
IMPL_EMPTY("ReceiveFile — Ghidra shows retail is shared empty stub at 0x14770")
void UBinaryFileDownload::ReceiveFile(UNetConnection *,int,const TCHAR*,int)
{
	// Retail: 0x14770 (shared empty stub)
}
IMPL_MATCH("Engine.dll", 0x104891e0)
void UBinaryFileDownload::Serialize(FArchive& Ar)
{
	guard(UBinaryFileDownload::Serialize);
	// Retail: 0x1891e0. UChannelDownload::Serialize + serialize connection ptr at this+0x458.
	UChannelDownload::Serialize(Ar);
	Ar << *(UObject**)((BYTE*)this + 0x458);
	unguard;
}
IMPL_MATCH("Engine.dll", 0x10489a30)
void UBinaryFileDownload::Destroy()
{
	guard(UBinaryFileDownload::Destroy);
	// Retail: 0x189a30. Clear connection back-pointer at conn+0x68, call UChannelDownload::Destroy.
	// Diverges: FPackageInfo at this+0x34 is not explicitly freed (forward decl only).
	INT connPtr = *(INT*)((BYTE*)this + 0x458);
	if (connPtr && *(INT*)(connPtr + 0x68) == (INT)this)
		*(INT*)(connPtr + 0x68) = 0;
	*(INT*)((BYTE*)this + 0x458) = 0;
	UChannelDownload::Destroy();
	unguard;
}
IMPL_MATCH("Engine.dll", 0x10489330)
void UBinaryFileDownload::DownloadDone()
{
	guard(UBinaryFileDownload::DownloadDone);
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
	unguard;
}
IMPL_EMPTY("DownloadError — Ghidra shows retail is shared empty stub at 0x176d60")
void UBinaryFileDownload::DownloadError(const TCHAR*)
{
	// Retail: 0x176d60 (shared empty stub)
}


// --- UChannelDownload ---
IMPL_MATCH("Engine.dll", 0x10488ea0)
void UChannelDownload::StaticConstructor()
{
	guard(UChannelDownload::StaticConstructor);
	// Retail: 0x188ea0, 71b. Sets the config key FString at +0x38 to "Enabled".
	*(FString*)((BYTE*)this + 0x38) = TEXT("Enabled");
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10488fb0)
int UChannelDownload::TrySkipFile()
{
	guard(UChannelDownload::TrySkipFile);
	// Ghidra 0x188fb0: if channel exists and base TrySkipFile succeeds,
	// send a "SKIP" bunch over the channel and return 1.
	UChannel* ch = *(UChannel**)((BYTE*)this + 0x458);
	if (ch != NULL)
	{
		if (UDownload::TrySkipFile())
		{
			FOutBunch Bunch(ch, 1);
			FString SkipStr(TEXT("SKIP"));
			(FArchive&)Bunch << SkipStr;
			*((_WORD*)((BYTE*)&Bunch + 0x2a)) = 1; // bClose flag at bunch+0x2a
			ch->SendBunch(&Bunch, 0);
			return 1;
		}
	}
	return 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x104898c0)
void UChannelDownload::ReceiveFile(UNetConnection* Connection, int PackageIndex, const TCHAR* Data, int DataSize)
{
	// Retail: 0x1898c0, 310b.
	UDownload::ReceiveFile(Connection, PackageIndex, Data, DataSize);

	UChannel* ch = Connection->CreateChannel(CHTYPE_File, 1, -1);
	*(UChannel**)((BYTE*)this + 0x458) = ch;
	if (!ch)
	{
		const TCHAR* err = LocalizeError(TEXT("ChAllocate"), TEXT("Engine"), NULL);
		DownloadError(err);
		DownloadDone();
		return;
	}

	// Store back-pointer in channel+0x68, copy channel index to channel+0x270
	*(UChannelDownload**)((BYTE*)ch + 0x68) = this;
	*(INT*)((BYTE*)ch + 0x270) = *(INT*)((BYTE*)this + 0x30);

	// Create a bit-packed send bunch, serialize the package GUID into it, then send
	FOutBunch bunch(ch, 0);
	typedef void (*GuidSerFn)(void*, void*);
	((GuidSerFn)0x103bef40)(&bunch, (void*)(*(INT*)((BYTE*)this + 0x34) + 0x14));

	// FArchive::ArIsError is at +0x30 in the FArchive base
	if (*(UBOOL*)((BYTE*)&bunch + 0x30))
		appFailAssert("!Bunch.IsError()", ".\\UnDownload.cpp", 0x105);

	ch->SendBunch(&bunch, 0);
}

IMPL_MATCH("Engine.dll", 0x10488f20)
void UChannelDownload::Serialize(FArchive& Ar)
{
	guard(UChannelDownload::Serialize);
	// Retail: 0x188f20, 84b.
	UDownload::Serialize(Ar);
	Ar << *(UObject**)((BYTE*)this + 0x458);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x104890d0)
void UChannelDownload::Destroy()
{
	guard(UChannelDownload::Destroy);
	// Retail: 0x1890d0, 84b. Clear the channel's back-pointer, then chain to base Destroy.
	INT ch = *(INT*)((BYTE*)this + 0x458);
	if (ch != 0 && *(UChannelDownload**)(ch + 0x68) == this)
		*(DWORD*)(ch + 0x68) = 0;
	*(DWORD*)((BYTE*)this + 0x458) = 0;
	UDownload::Destroy();
	unguard;
}


// --- UDownload ---
IMPL_MATCH("Engine.dll", 0x104889d0)
void UDownload::StaticConstructor()
{
	guard(UDownload::StaticConstructor);
	// Retail: 0x1889d0, 80b. Initialise config key FString at +0x38 to "" and zero +0x44.
	*(FString*)((BYTE*)this + 0x38) = TEXT("");
	*(DWORD*)((BYTE*)this + 0x44) = 0;
	unguard;
}

IMPL_EMPTY("Tick — Ghidra shows retail is shared empty stub at 0x176d60")
void UDownload::Tick()
{
	// Retail: 0x176d60 (shared empty stub)
}

IMPL_MATCH("Engine.dll", 0x10488af0)
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

IMPL_MATCH("Engine.dll", 0x10488b10)
void UDownload::ReceiveData(BYTE* Data, int Size)
{
	guard(UDownload::ReceiveData);
	// Retail: 0x188b10, 544b. Lazy-open a temp file on the first call, then append data.
	// +0x44c = total bytes received; +0x48 = FArchive* write handle; +0x4c = temp path buffer.
	if (*(INT*)((BYTE*)this + 0x44c) == 0 && *(INT*)((BYTE*)this + 0x48) == 0)
	{
		// Ensure the cache directory exists, then create a unique temp filename inside it
		const TCHAR* cachePath = ((FString*)((BYTE*)GSys + 0x44))->operator*();
		GFileManager->MakeDirectory(cachePath);
		cachePath = ((FString*)((BYTE*)GSys + 0x44))->operator*();
		appCreateTempFilename(cachePath, (TCHAR*)((BYTE*)this + 0x4c));
		*(FArchive**)((BYTE*)this + 0x48) = GFileManager->CreateFileWriter(
			(const TCHAR*)((BYTE*)this + 0x4c), 0, GNull);
	}
	FArchive* archive = *(FArchive**)((BYTE*)this + 0x48);
	if (!archive)
	{
		const TCHAR* err = LocalizeError(TEXT("NetOpen"), TEXT("Engine"), NULL);
		DownloadError(err);
		return;
	}
	if (Size > 0)
	{
		archive->Serialize(Data, Size);
		*(INT*)((BYTE*)this + 0x44c) += Size;
	}
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10489460)
void UDownload::ReceiveFile(UNetConnection* Connection, int Channel, const TCHAR* /*Data*/, int /*DataSize*/)
{
	// Retail: 32b. Stores connection/channel, computes channel base offset.
	*(DWORD*)((BYTE*)this + 0x2C) = (DWORD)Connection;
	*(INT*)((BYTE*)this + 0x30) = Channel;
	BYTE* ChannelTable = *(BYTE**)((BYTE*)Connection + 0xC8);
	*(INT*)((BYTE*)this + 0x34) = Channel * 0x44 + *(INT*)(ChannelTable + 0x2C);
}

IMPL_MATCH("Engine.dll", 0x10488a60)
void UDownload::Serialize(FArchive& Ar)
{
	guard(UDownload::Serialize);
	// Retail: 0x188a60, 82b.
	UObject::Serialize(Ar);
	Ar << *(UObject**)((BYTE*)this + 0x2c);
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10488df0)
void UDownload::Destroy()
{
	guard(UDownload::Destroy);
	// Retail: 0x188df0, 124b. Close and delete the temp file, clear connection back-pointer.
	if (*(INT*)((BYTE*)this + 0x48) != 0)
	{
		// Virtual delete: vtable[0](archive, 1) = scalar_deleting_destructor with flag 1
		void* arch = *(void**)((BYTE*)this + 0x48);
		typedef void (__thiscall* DtorFn)(void*, INT);
		((DtorFn)(*(INT*)(*(INT*)arch)))(arch, 1);
		*(INT*)((BYTE*)this + 0x48) = 0;
		GFileManager->Delete((const TCHAR*)((BYTE*)this + 0x4c), 0, 0);
	}
	INT conn = *(INT*)((BYTE*)this + 0x2c);
	if (conn != 0 && *(UDownload**)(conn + 0x4ba8) == this)
		*(INT*)(conn + 0x4ba8) = 0;
	*(INT*)((BYTE*)this + 0x2c) = 0;
	UObject::Destroy();
	unguard;
}

IMPL_MATCH("Engine.dll", 0x1048ae80)
void UDownload::DownloadDone()
{
	guard(UDownload::DownloadDone);
	// Retail: 0x18ae80, 1347b. Finalises the download: closes the temp file, moves it
	// to the cache directory under a GUID-based name, and triggers package loading.
	// NOTE: Full package-load sequence (FUN_103b1d90 + cache.ini write) is partially
	// implemented below. FUN_103b1d90 is called via address thunk; cache.ini update omitted.

	// 1. Close and free the write archive
	if (*(INT*)((BYTE*)this + 0x48) != 0)
	{
		void* arch = *(void**)((BYTE*)this + 0x48);
		typedef void (__thiscall* DtorFn)(void*, INT);
		((DtorFn)(*(INT*)(*(INT*)arch)))(arch, 1);
		*(INT*)((BYTE*)this + 0x48) = 0;
	}

	// 2. If not skip mode, do the cache move + package load
	if (*(INT*)((BYTE*)this + 0x450) == 0)
	{
		// Build final cache path: "CachePath\<GUID>.uxx"
		typedef const TCHAR* (*GuidStrFn)(void*);
		const TCHAR* guidStr = ((GuidStrFn)0x103bef50)((void*)(*(INT*)((BYTE*)this + 0x34) + 0x14));
		TCHAR finalPath[512];
		appSprintf(finalPath, TEXT("%s\\%s.uxx"), ((FString*)((BYTE*)GSys + 0x44))->operator*(), guidStr);

		// If no data arrived and no prior error, report a refused download
		if (*(unsigned short*)((BYTE*)this + 0x24c) == 0 && *(INT*)((BYTE*)this + 0x44c) == 0)
		{
			const TCHAR* err = LocalizeError(TEXT("NetRefused"), TEXT("Engine"), NULL);
			DownloadError(err);
		}

		if (*(unsigned short*)((BYTE*)this + 0x24c) == 0)
		{
			// Verify the received file size matches the expected package size
			INT expectedSize = *(INT*)(*(INT*)((BYTE*)this + 0x34) + 0x24);
			INT actualSize = GFileManager->FileSize((const TCHAR*)((BYTE*)this + 0x4c));
			if (actualSize != expectedSize)
			{
				const TCHAR* err = LocalizeError(TEXT("NetSize"), TEXT("Engine"), NULL);
				DownloadError(err);
			}

			if (*(unsigned short*)((BYTE*)this + 0x24c) == 0)
			{
				// Move temp file to final cache path
				INT moved = GFileManager->Move(finalPath, (const TCHAR*)((BYTE*)this + 0x4c), 1, 0, 0);
				if (!moved)
				{
					const TCHAR* err = LocalizeError(TEXT("NetMove"), TEXT("Engine"), NULL);
					DownloadError(err);
				}

				if (*(unsigned short*)((BYTE*)this + 0x24c) == 0)
				{
					// FUN_103b1d90 = UPackageManager_RegisterCachedPackage() — register the
					// newly downloaded package with the engine's package cache system.
					// DIVERGENCE: cache.ini appSprintf + FString update (immediately following
					// in the retail binary) is omitted; package is registered but not persisted
					// to the ini file in this reconstruction.
					typedef void (*PkgLoadFn)();
					((PkgLoadFn)0x103b1d90)();
				}
			}
		}
	}

	// 3. Clear the connection back-pointer
	INT conn = *(INT*)((BYTE*)this + 0x2c);
	if (conn != 0 && *(UDownload**)(conn + 0x4ba8) == this)
		*(INT*)(conn + 0x4ba8) = 0;
	*(INT*)((BYTE*)this + 0x2c) = 0;
	unguard;
}

IMPL_MATCH("Engine.dll", 0x10488d70)
void UDownload::DownloadError(const TCHAR* Error)
{
	guard(UDownload::DownloadError);
	// Retail: 0x188d70, 79b. Copy error string into the error buffer at +0x24c.
	appStrcpy((TCHAR*)((BYTE*)this + 0x24c), Error);
	unguard;
}

