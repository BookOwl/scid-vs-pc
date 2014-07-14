//////////////////////////////////////////////////////////////////////
//
//  FILE:       win_mmap.h
//              Fast file read access for Windows.
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    2.0
//
//  Notice:     Copyright (c) 2014  Gregor Cramer.
//
//  Author:     Gregor Cramer
//
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
//
// Only useful for fast sequential read of a whole file.
//
// This class is for Windows only.
//
//////////////////////////////////////////////////////////////////////

#ifndef SCID_WIN_MMAP_H
#define SCID_WIN_MMAP_H

#include <windows.h>

class WinMMap
{
public:

    WinMMap(char const* filename);
    ~WinMMap();

    bool isOpen() const;

    unsigned size() const;

    unsigned char const* address() const;

private:

    void*     m_address;
    unsigned  m_size;
    HANDLE    m_file;
    HANDLE    m_mapping;
};


WinMMap::WinMMap(char const* filename)
    :m_address(0)
    ,m_size(0)
    ,m_file(INVALID_HANDLE_VALUE)
    ,m_mapping(INVALID_HANDLE_VALUE)
{
    ASSERT (filename != NULL);

    m_file = CreateFileA(
					filename,
					GENERIC_READ,
					0,
					0,
					OPEN_EXISTING,
					FILE_FLAG_SEQUENTIAL_SCAN | FILE_ATTRIBUTE_READONLY | FILE_ATTRIBUTE_TEMPORARY,
					0);

    if (m_file == INVALID_HANDLE_VALUE)
        return;

    m_mapping = CreateFileMappingA(
						 m_file,
						 0,
						 PAGE_READONLY,
						 0,
						 0,
						 filename);

    if (m_mapping == INVALID_HANDLE_VALUE)
    {
        CloseHandle(m_file);
        return;
    }

    m_address = MapViewOfFile(m_mapping, FILE_MAP_READ, 0, 0, 0);
    m_size = GetFileSize(m_file, 0);
}


WinMMap::~WinMMap()
{
    if (m_address)
        UnmapViewOfFile(m_address);

    if (m_mapping != INVALID_HANDLE_VALUE)
        CloseHandle(m_mapping);

    if (m_file != INVALID_HANDLE_VALUE)
        CloseHandle(m_file);
}

#endif  // SCID_WIN_MMAP_H

//////////////////////////////////////////////////////////////////////
//  End of file: win_mmap.h
//////////////////////////////////////////////////////////////////////
