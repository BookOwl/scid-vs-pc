// ======================================================================
// Copyright: (C) 2012 Gregor Cramer
// ======================================================================

// ======================================================================
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// ======================================================================

#include <tcl.h>
#include <tk.h>
#include <string.h>
#include <assert.h>

#include "dstring.h"

#define nullptr NULL
#define M_ASSERT(x) assert(x)


#if defined(WIN32) || (defined(__unix__) && !defined(__MacOSX__))

extern "C" { int TclRenameCommand(Tcl_Interp* ti, char const* oldName, char const* newName); }

static Tcl_Obj* m_renamedCmd = 0;

static int
invokeTkSelection(Tcl_Interp *ti, int objc, Tcl_Obj* const objv[])
{
	Tcl_Obj* objs[objc];
	memcpy(objs, objv, objc*sizeof(Tcl_Obj*));
	objs[0] = m_renamedCmd;
	return Tcl_EvalObjv(ti, objc, objs, 0);
}

# if defined(WIN32)

#  include <windows.h>

#  ifndef XA_STRING
#   define XA_STRING CF_TEXT
#  endif

static int
selectionGet(Tcl_Interp* ti, Tk_Window tkwin, Atom selection, Atom target, unsigned long)
{
	int	done = 0;
	bool	notAvailable = false;

	if (OpenClipboard(0))
	{
		if (target == Tk_InternAtom(tkwin, "CF_HDROP"))
		{
			if (IsClipboardFormatAvailable(CF_HDROP))
			{
				HGLOBAL handle = GetClipboardData(CF_HDROP);

				if (handle)
				{
					HDROP hdrop = static_cast<HDROP>(GlobalLock(handle));
					int count = DragQueryFileW(hdrop, static_cast<unsigned>(-1), 0, 0);
					DString result;

					for (int i = 0; i < count; ++i)
					{
						Tcl_UniChar buffer[1024];

                  if (int len = DragQueryFileW(hdrop, i, (WCHAR*) buffer, sizeof(buffer)/sizeof(buffer[0])))
						{
							Tcl_UniChar const* s = buffer;
							Tcl_UniChar const* e = s + len;

							for ( ; s < e; ++s)
							{
								char buf[6];
								result.Append(buf, buf + Tcl_UniCharToUtf(*s, buf));
							}

							result.AddChar('\n');
						}
					}

					Tcl_SetObjResult(ti, Tcl_NewStringObj(result.Data(), result.Length()));
					GlobalUnlock(handle);
					done = 1;
				}
				else
				{
					notAvailable = true;
				}
			}
		}
		else
		{
			notAvailable = true;
		}

		CloseClipboard();
	}

	if (!notAvailable)
	{
		Tcl_AppendResult(	ti,
								Tk_GetAtomName(tkwin, selection),
								" selection doesn't exist or form \"",
								Tk_GetAtomName(tkwin, target), "\" not defined",
								nullptr);
	}

	return done;
}

static int
selEventProc(Tk_Window, XEvent*)
{
	return 0; // no action required
}

# elif defined(__unix__)

#  include <X11/Xatom.h>
#  include <ctype.h>

static bool m_selectionRetrieved = false;
static bool m_timeOut = true;


inline unsigned
xdigitToVal(unsigned char c)
{
	return isdigit(c) ? c - '0' : toupper(c) - 'A' + 10;
}


static char*
unescapeChars(char* s, char const* e)
{
	char* p = s;

	while (s < e)
	{
		if (*s == '%')
		{
			if (s[1] == '%')
			{
				*p++ = '%';
				s += 2;
			}
			else if (isxdigit(s[1]) && isxdigit(s[2]))
			{
				*p++ = (xdigitToVal(s[1]) << 4) + xdigitToVal(s[2]);
				s += 3;
			}
			else
			{
				// Ooops, this shouldn't happen.
				*p++ = *s++;
			}
		}
		else
		{
			*p++ = *s++;
		}
	}

	return p;
}


static int
selEventProc(Tk_Window tkwin, XEvent* eventPtr)
{
	char*	propInfo	= 0;
	Atom	type;
	int	format;

	unsigned long numItems = 0;
	unsigned long bytesAfter;

	if (m_timeOut)
		return 1; // we don't expect a selection

	if (eventPtr->xselection.property == None)
		return 0; // this may happen sporadically

	int result = XGetWindowProperty(	eventPtr->xselection.display,
												eventPtr->xselection.requestor,
												eventPtr->xselection.property,
												0,
												100000,
												False,
												AnyPropertyType,
												&type,
												&format,
												&numItems,
												&bytesAfter,
												reinterpret_cast<unsigned char**>(&propInfo));

	int done = 0;

	if (result == Success && propInfo != 0 && type != None && bytesAfter == 0 && format == 8)
	{
		Atom xaPlainText		= 0;
		Atom xaPlainTextUtf8	= 0;
		Atom xaUriList			= 0;

		if (	type == (xaPlainText			= Tk_InternAtom(tkwin, "text/plain"))
			|| type == (xaPlainTextUtf8	= Tk_InternAtom(tkwin, "text/plain;charset=UTF-8"))
			|| type == (xaUriList			= Tk_InternAtom(tkwin, "text/uri-list")))
		{
			while (numItems > 0 && propInfo[numItems - 1] == '\0')
				--numItems;

			if (type == xaPlainTextUtf8)
			{
				Tcl_SetObjResult(Tk_Interp(tkwin), Tcl_NewStringObj(propInfo, numItems));
			}
			else
			{
				Tcl_DString ds;

				if (type == xaUriList)
					numItems = unescapeChars(propInfo, propInfo + numItems) - propInfo;

				Tcl_ExternalToUtfDString(0, propInfo, numItems, &ds);
				Tcl_DStringResult(Tk_Interp(tkwin), &ds);
				Tcl_DStringFree(&ds);
			}

			done = 1;
			m_selectionRetrieved = true;
			m_timeOut = true;
		}
	}

	if (propInfo)
		XFree(propInfo);

	return done;
}


static void
selTimeoutProc(ClientData clientData)
{
	m_timeOut = true;
	Tcl_SetResult(	static_cast<Tcl_Interp*>(clientData),
						const_cast<char*>("selection owner didn't respond"),
						TCL_STATIC);
}


static int
selectionGet(Tcl_Interp* ti, Tk_Window tkwin, Atom selection, Atom target, unsigned long timestamp)
{
	XConvertSelection(Tk_Display(tkwin), selection, target, selection, Tk_WindowId(tkwin), timestamp);

	Tcl_TimerToken timeout = Tcl_CreateTimerHandler(500, selTimeoutProc, ti);
	m_selectionRetrieved = m_timeOut = false;
	while (!m_timeOut)
		Tcl_DoOneEvent(0);
	Tcl_DeleteTimerHandler(timeout);
	m_timeOut = true;

	return m_selectionRetrieved ? TCL_OK : TCL_ERROR;
}

# endif // __unix__

static int
selGet(Tcl_Interp* ti, int objc, Tcl_Obj* const objv[])
{
	Tcl_Obj* const* objs = objv + 2;
	int count = objc - 2;

	char const* path			= 0;
	char const* selName		= 0;
	char const* targetName	= 0;
	long			timestamp	= CurrentTime;

	for ( ; count > 0; count -= 2, objs += 2)
	{
		static char const* OptionStrings[] = { "-displayof", "-selection", "-type", "-time", 0 };
		enum { GET_DISPLAYOF, GET_SELECTION, GET_TYPE, GET_TIME };

		char const* string = Tcl_GetString(objs[0]);

		if (string[0] != '-')
			break;

		if (count < 2)
		{
			Tcl_AppendResult(ti, "value for \"", string, "\" missing", nullptr);
			return TCL_ERROR;
		}

		int index;

		if (Tcl_GetIndexFromObj(ti, objs[0], OptionStrings, "option", 0, &index) != TCL_OK)
			return TCL_ERROR;

		switch (index)
		{
			case GET_DISPLAYOF:
				path = Tcl_GetString(objs[1]);
				break;

			case GET_SELECTION:
				selName = Tcl_GetString(objs[1]);
				break;

			case GET_TYPE:
				targetName = Tcl_GetString(objs[1]);
				break;

			case GET_TIME:
				// implementing TIP 370 <www.tcl.tk/cgi-bin/tct/tip/370.html>
				if (Tcl_GetLongFromObj(ti, objs[1], &timestamp) != TCL_OK)
				{
					Tcl_AppendResult(ti, "wrong time value \"", Tcl_GetString(objs[1]), nullptr);
					return TCL_ERROR;
				}
				break;
		}
	}

	if (count > 1)
	{
		Tcl_WrongNumArgs(ti, 2, objv, "?options?");
		return TCL_ERROR;
	}

	if (selName == 0 || strcmp(selName, "XdndSelection"))
		return invokeTkSelection(ti, objc, objv);

	Tk_Window tkwin = Tk_MainWindow(ti);

	if (path && tkwin)
		tkwin = Tk_NameToWindow(ti, path, tkwin);

	if (!tkwin)
		return TCL_ERROR;

	M_ASSERT(selName);

	Atom target = XA_STRING;

	if (count == 1)
		target = Tk_InternAtom(tkwin, Tcl_GetString(objs[0]));
	else if (targetName)
		target = Tk_InternAtom(tkwin, targetName);

	return selectionGet(ti, tkwin, Tk_InternAtom(tkwin, selName), target, timestamp);
}


static int
selCmd(ClientData, Tcl_Interp *ti, int objc, Tcl_Obj* const objv[])
{
	if (objc >= 2 && strcmp(Tcl_GetString(objv[1]), "get") == 0)
		return selGet(ti, objc, objv);

	return invokeTkSelection(ti, objc, objv);
}


static int
handleSelection(ClientData clientData, XEvent* eventPtr)
{
	if (eventPtr->type == SelectionNotify)
		return selEventProc(Tk_IdToWindow(eventPtr->xany.display, eventPtr->xany.window), eventPtr);

	return 0;
}


void
Tk_Selection_Init(Tcl_Interp* ti)
{
	// Poor Tk library cannot handle the most common types "text/plain", and "text/uri-list".
	// This means we have to do our own selection handling.
	Tcl_IncrRefCount(m_renamedCmd = Tcl_NewStringObj("__selection__x11_", -1));
	TclRenameCommand(ti, "selection", Tcl_GetString(m_renamedCmd));
	Tcl_CreateObjCommand(ti, "selection", selCmd, 0, 0);
	Tk_CreateGenericHandler(handleSelection, 0);
}

#else

void Tk_Selection_Init(Tcl_Interp* ti) {}

#endif

// vi:set ts=3 sw=3:
