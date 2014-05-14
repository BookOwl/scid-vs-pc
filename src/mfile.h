//////////////////////////////////////////////////////////////////////
//
//  FILE:       mfile.h
//              MFile class
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    2.0
//
//  Notice:     Copyright (c) 2000  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////


// An MFile is a file that can be a regular file, or memory-only with
// no actual file on any device.
// In addition, an MFile can decode its contents from a GZip (.gz) file
// and will hopefully in future also be able to extract the contents of
// all files in a Zip file, as if they were in one large plain file.

// -------------------------------------------------------------------
// Extension by Gregor Cramer, 25 March 2014:
// -------------------------------------------------------------------
// For reading a whole file and avoiding the time consuming locking we
// are using memory mapping (file mapping) under Windows.
//
// On Linux we have a simpler method, glibc is providing the function
// getc_unlocked() for this purpose.


#ifndef SCID_MFILE_H
#define SCID_MFILE_H

#include "common.h"
#include "dstring.h"
#include "error.h"

#ifdef WIN32
# include "win_mmap.h"
#endif

enum mfileT {
    MFILE_REGULAR = 0, MFILE_MEMORY, MFILE_GZIP, MFILE_ZIP,
#ifdef WIN32
    MFILE_MMAP,
#endif
};

class MFile
{
  private:
    FILE *      Handle;         // For regular files.
    gzFile      GzHandle;       // For Gzip files.
    fileModeT   FileMode;
    mfileT      Type;
    char *      FileName;

    // The next few fields are used to improve I/O speed on Gzip files, by
    // avoiding doing a gzgetc() every character, since the zlib file gzio.c
    // simply does a (relatively slow) gzread() for each gzgetc().
    byte *      GzBuffer;
    int         GzBuffer_Avail;
    byte *      GzBuffer_Current;

    // The next few fields are used for in-memory files.
    uint        Capacity;
    uint        Location;
    byte *      Data;
    byte *      CurrentPtr;

    char *      FileBuffer;  // Only for files with unusual buffer size.

#ifdef WIN32
    WinMMap *   MappedFile;  // File mapping for fast read access.
#endif

    void  Extend();
    int   FillGzBuffer();

  public:
    MFile() { Init(); }
    ~MFile() {
        if (Handle != NULL) { Close(); }
        if (Data != NULL) { delete[] Data; }
        if (FileBuffer != NULL) { delete[] FileBuffer; }
        if (FileName != NULL) { delete[] FileName; }
#ifdef WIN32
        delete MappedFile;
#endif
    }

    void Init();

    fileModeT Mode() { return FileMode; }

    errorT Create (const char * name, fileModeT fmode);
    errorT Open  (const char * name, fileModeT fmode);
#ifdef WIN32
    errorT OpenMappedFile (const char * name, fileModeT fmode);
#endif
    void   CreateMemory () { Close(); Init(); }
    errorT Close ();

    void   SetBufferSize (uint bufsize);

    uint   Size ();
    uint   Tell () { return Location; }
    errorT Seek (uint position);
    errorT Flush ();
    inline bool EndOfFile();

    errorT        WriteNBytes (const char * str, uint length);
    errorT        ReadNBytes (char * str, uint length);
    errorT        ReadLine (char * str, uint maxLength);
    errorT        ReadLine (DString * dstr);
    inline errorT WriteOneByte (byte value);
    errorT        WriteTwoBytes (uint value);
    errorT        WriteThreeBytes (uint value);
    errorT        WriteFourBytes (uint value);
    inline int    ReadOneByte ();
    uint          ReadTwoBytes ();
    uint          ReadThreeBytes ();
    uint          ReadFourBytes ();

    inline const char * GetFileName ();
};


inline const char *
MFile::GetFileName ()
{
    if (FileName == NULL) {
        return "";
    } else {
        return FileName;
    }
}

inline bool
MFile::EndOfFile ()
{
    switch (Type) {
    case MFILE_MEMORY:
        return (Location >= Capacity);
    case MFILE_REGULAR:
        return feof(Handle);
    case MFILE_GZIP:
        if (GzBuffer_Avail > 0) { return 0; }
        return gzeof(GzHandle);
#ifdef WIN32
    case MFILE_MMAP:
        return Location >= MappedFile->size();
#endif
    default:
        return false;
    }
}

inline errorT
MFile::WriteOneByte (byte value)
{
    ASSERT (FileMode != FMODE_ReadOnly);
    if (Type == MFILE_MEMORY) {
        if (Location >= Capacity) { Extend(); }
        *CurrentPtr++ = value;
        Location++;
        return OK;
    }
    Location++;
    if (Type == MFILE_GZIP) {
        return (gzputc(GzHandle, value) == EOF) ? ERROR_FileWrite : OK;
    }
    return (putc(value, Handle) == EOF) ? ERROR_FileWrite : OK;
}

inline int
MFile::ReadOneByte ()
{
    ASSERT (FileMode != FMODE_WriteOnly);
    if (Type == MFILE_MEMORY) {
        if (Location >= Capacity) { return EOF; }
        byte value = *CurrentPtr;
        Location++;
        CurrentPtr++;
        return (int) value;
    }
    if (Type == MFILE_GZIP) {
        Location++;
        if (GzBuffer_Avail <= 0) {
            return FillGzBuffer();
        }
        GzBuffer_Avail--;
        int retval = *GzBuffer_Current;
        GzBuffer_Current++;
        return retval;
    }
#ifdef WIN32
    if (Type == MFILE_MMAP) {
        if (Location >= MappedFile->size()) { return EOF; }
        return *(MappedFile->address() + Location++);
    } else {
        Location++;
        return getc(Handle);
    }
#else
    Location++;
# ifdef __GNUC__
    return getc_unlocked(Handle);
# else
    return getc(Handle);
# endif
#endif
}

#endif  // SCID_MFILE_H

