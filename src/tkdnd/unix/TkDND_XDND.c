// ======================================================================
// Copyright: (C) 2012 Gregor Cramer
// ======================================================================

/*
 * TkDND_XDND.h -- Tk XDND Drag'n'Drop Protocol Implementation
 *
 *    This file implements the unix portion of the drag&drop mechanism
 *    for the tk toolkit. The protocol in use under unix is the
 *    XDND protocol.
 *
 * This software is copyrighted by:
 * Georgios Petasis, Athens, Greece.
 * e-mail: petasisg@yahoo.gr, petasis@iit.demokritos.gr
 *
 * The following terms apply to all files associated
 * with the software unless explicitly disclaimed in individual files.
 *
 * The authors hereby grant permission to use, copy, modify, distribute,
 * and license this software and its documentation for any purpose, provided
 * that existing copyright notices are retained in all copies and that this
 * notice is included verbatim in any distributions. No written agreement,
 * license, or royalty fee is required for any of the authorized uses.
 * Modifications to this software may be copyrighted by their authors
 * and need not follow the licensing terms described here, provided that
 * the new terms are clearly indicated on the first page of each file where
 * they apply.
 *
 * IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY
 * FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
 * ARISING OUT OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY
 * DERIVATIVES THEREOF, EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 * THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.  THIS SOFTWARE
 * IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE
 * NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
 * MODIFICATIONS.
 */
#include "tcl.h"
#include "tk.h"
#include <X11/Xlib.h>
#include <X11/X.h>
#include <X11/Xatom.h>
#include <X11/keysym.h>
#include <string.h>

#ifdef HAVE_LIMITS_H
#include "limits.h"
#else
#define LONG_MAX 0x7FFFFFFFL
#endif

#define XDND_VERSION 5

#define GNOME_SUPPORT
//#define DEBUG_CLIENTMESSAGE_HANDLER

#ifndef PACKAGE_NAME
# define PACKAGE_NAME "tkDND"
#endif

#ifndef PACKAGE_VERSION
# define PACKAGE_VERSION "2.3"
#endif

#ifdef TKDND_ENABLE_MOTIF_DROPS
extern int MotifDND_HandleClientMessage(Tk_Window tkwin, XEvent* xevent);
extern void MotifDND_RegisterTypesObjCmd(Tk_Window tkwin);
#endif

#define TkDND_TkWin(x) \
  (Tk_NameToWindow(interp, Tcl_GetString(x), Tk_MainWindow(interp)))

int
TkDND_Eval(Tcl_Interp* interp, int objc, Tcl_Obj* const* objv)
{
  int i;
  int status;

  for (i = 0; i < objc; ++i)
    Tcl_IncrRefCount(objv[i]);
  status = Tcl_EvalObjv(interp, objc, objv, TCL_EVAL_GLOBAL);
  if (status != TCL_OK)
    Tk_BackgroundError(interp);
  for (i = 0; i < objc; ++i)
    Tcl_DecrRefCount(objv[i]);
  return status;
}

#ifdef GNOME_SUPPORT

# ifdef USE_TKINT_H
#  include "tkInt.h"
# endif

static Tk_Window
GetWmFrameChild(Tk_Window tkwin) {
  if (Tk_PathName(tkwin) == NULL) {
    Window    xroot;
    Window    xwmwin;
    Window*   childs;
    unsigned  nchilds;

    if (XQueryTree(Tk_Display(tkwin), Tk_WindowId(tkwin),
                   &xroot, &xwmwin, &childs, &nchilds) && childs) {
      /* This is GNOME. We have to use the child window. */
      if (nchilds == 1) {
        tkwin = Tk_IdToWindow(Tk_Display(tkwin), childs[0]);
      } else if (nchilds == 2) {
        /* In this case we have to disqualify the menu bar. */
        Tk_Window win1 = Tk_IdToWindow(Tk_Display(tkwin), childs[0]);
        Tk_Window win2 = Tk_IdToWindow(Tk_Display(tkwin), childs[1]);

        char const* p1 = Tk_PathName(win1);
        char const* p2 = Tk_PathName(win2);

        if (p1 && p2) {
          char const* s1 = strchr(p1, '#');
          char const* s2 = strchr(p2, '#');

          if ((s1 == NULL) != (s2 == NULL)) {
            tkwin = s1 ? win2 : win1;
          }
        }
      }
      XFree(childs);
    }
  }

  return tkwin;
}

static Tk_Window
CoordsToWindow(int rootX, int rootY, Tk_Window tkwin) {
  Tk_Window mouse_tkwin;
  int childX, childY;

  tkwin = GetWmFrameChild(tkwin);

  if (Tk_PathName(tkwin) == NULL)
    return NULL; /* something was going wrong */

  Tk_GetRootCoords(tkwin, &childX, &childY);
  rootX -= childX;
  rootY -= childY;
  mouse_tkwin = tkwin;

  while (tkwin != NULL) {
#ifdef USE_TKINT_H
    TkWindow* winPtr = ((TkWindow*)tkwin)->childList;
    tkwin = NULL;

    for ( ; winPtr != NULL; winPtr = winPtr->nextPtr) {
      if (!(winPtr->flags & TK_ANONYMOUS_WINDOW)) {
        Tk_Window child = (Tk_Window)winPtr;

        if (Tk_IsMapped(winPtr)) {
          int x = Tk_X(child);
          int y = Tk_Y(child);
          int width = Tk_Width(child);
          int height = Tk_Height(child);

          if (x <= rootX && y <= rootY && rootX < x + width && rootY < y + height) {
            tkwin = child;
            mouse_tkwin = child;
            rootX -= x;
            rootY -= y;
            break;
          }
        }
      }
    }
#else
    Tcl_Interp* interp = Tk_Interp(tkwin);
    Tcl_Obj* objv[3];
    Tcl_Obj* result;
    int length, i;

    objv[0] = Tcl_NewStringObj("winfo", -1);
    objv[1] = Tcl_NewStringObj("children", -1);
    objv[2] = Tcl_NewStringObj(Tk_PathName(tkwin), -1);

    if (TkDND_Eval(interp, 3, objv) != TCL_OK)
      return NULL;

    result = Tcl_GetObjResult(interp);
    Tcl_IncrRefCount(result);
    tkwin = NULL;

    if (Tcl_ListObjLength(interp, result, &length) == TCL_OK) {
      for (i = 0; i < length; ++i) {
        Tcl_Obj* path;
        Tk_Window child;
        int x, y, width, height;

        if (Tcl_ListObjIndex(interp, result, i, &path) == TCL_OK) {
          child = Tk_NameToWindow(interp, Tcl_GetString(path), mouse_tkwin);

          if (child != NULL && Tk_IsMapped(child)) {
            x = Tk_X(child);
            y = Tk_Y(child);
            width = Tk_Width(child);
            height = Tk_Height(child);

            if (x <= rootX && y <= rootY && rootX < x + width && rootY < y + height) {
              tkwin = child;
              mouse_tkwin = child;
              rootX -= x;
              rootY -= y;
              break;
            }
          }
        }
      }
    }

    Tcl_DecrRefCount(result);
#endif
  }

  return mouse_tkwin;
}

static void
SetWmFrameAware(Tk_Window path) {
  Tk_Window toplevel = path;
  Display*  display  = Tk_Display(path);
  Window    xroot;
  Window    xwmwin;
  Window*   childs;
  unsigned  nchilds;

  while (!Tk_IsTopLevel(toplevel)) {
    toplevel = Tk_Parent(toplevel);
    if (!toplevel)
      return;
  }

  if (!Tk_IsMapped(toplevel)) {
    /* What a pitty, no window manager frame exists. */
    return;
  }

  if (XQueryTree(display, Tk_WindowId(toplevel),
                 &xroot, &xwmwin, &childs, &nchilds)) {
    if (xwmwin != None &&
        xwmwin != RootWindow(display, Tk_ScreenNumber(path))) {
      Atom version = XDND_VERSION;
      /* Set XdndAware to window manager frame, otherwise GNOME will not work. */
      XChangeProperty(Tk_Display(toplevel), xwmwin,
                      Tk_InternAtom(path, "XdndAware"),
                      XA_ATOM, 32, PropModeReplace,
                      (unsigned char *) &version, 1);
    }
    if (childs)
      XFree(childs);
  }
}

#endif

int TkDND_RegisterTypesObjCmd(ClientData clientData, Tcl_Interp *interp,
                              int objc, Tcl_Obj *CONST objv[]) {

  Atom version       = XDND_VERSION;
  Tk_Window path     = TkDND_TkWin(objv[1]);

  if (objc != 4) {
    Tcl_WrongNumArgs(interp, 1, objv, "path toplevel types-list");
    return TCL_ERROR;
  }

  /*
   * We must make the toplevel that holds this widget XDND aware. This means
   * that we have to set the XdndAware property on our toplevel.
   */
  Tk_MakeWindowExist(path);
  XChangeProperty(Tk_Display(path), Tk_WindowId(path),
                  Tk_InternAtom(path, "XdndAware"),
                  XA_ATOM, 32, PropModeReplace,
                  (unsigned char *) &version, 1);

#ifdef GNOME_SUPPORT
  /* For GNOME support we have to set the awareness to the window manager
   * frame, this requires that the toplevel window is already mapped. We
   * will not do this mapping implicitly, the TCL side should care about this.
   * One problem remains: if the user is switching the window manager,
   * the awareness will get lost. Due to the fact that we cannot catch the
   * ReparentNotify event - this event is encapsulated inside the Tk library -
   * we have to live with this. Furthermore GNOME's decision is causing much
   * superfluous X traffic. GNOME's decision for the window manager frame,
   * which is not belonging to our own process, is nonsense.
  */
  SetWmFrameAware(path);
#endif

#ifdef TKDND_ENABLE_MOTIF_DROPS
  MotifDND_RegisterTypesObjCmd(path);
#endif
  return TCL_OK;
} /* TkDND_RegisterTypesObjCmd */

int TkDND_HandleXdndEnter(Tk_Window tkwin, XClientMessageEvent cm) {
  Tcl_Interp *interp = Tk_Interp(tkwin);
  Atom *typelist;
  const long *l = cm.data.l;
  int i, version = (int)(((unsigned long)(l[1])) >> 24);
  Window drag_source;
  Tcl_Obj* objv[4], *element;

  if (interp == NULL) return False;
  if (version > XDND_VERSION) return False;
  drag_source = l[0];
  if (l[1] & 0x1UL) {
    /* Get the types from XdndTypeList property. */
    Atom actualType = None;
    int actualFormat;
    unsigned long itemCount, remainingBytes;
    unsigned char *data;
    XGetWindowProperty(cm.display, drag_source,
                       Tk_InternAtom(tkwin, "XdndTypeList"), 0,
                       LONG_MAX, False, XA_ATOM, &actualType, &actualFormat,
                       &itemCount, &remainingBytes, &data);
    typelist = (Atom *) Tcl_Alloc(sizeof(Atom)*(itemCount+1));
    if (typelist == NULL) return False;
    for (i=0; i<itemCount; i++) { typelist[i] = ((Atom*)data)[i]; }
    typelist[itemCount] = None;
    if (data) XFree(data);
  } else {
    typelist = (Atom *) Tcl_Alloc(sizeof(Atom)*4);
    if (typelist == NULL) return False;
    typelist[0] = cm.data.l[2];
    typelist[1] = cm.data.l[3];
    typelist[2] = cm.data.l[4];
    typelist[3] = None;
  }
  /* We have all the information we need. Its time to pass it at the Tcl
   * level.*/
  objv[0] = Tcl_NewStringObj("tkdnd::xdnd::_HandleXdndEnter", -1);
  objv[1] = Tcl_NewStringObj(Tk_PathName(tkwin), -1);
  objv[2] = Tcl_NewLongObj(drag_source);
  objv[3] = Tcl_NewListObj(0, NULL);
  for (i=0; typelist[i] != None; ++i) {
    element = Tcl_NewStringObj(Tk_GetAtomName(tkwin, typelist[i]), -1);
    Tcl_ListObjAppendElement(NULL, objv[3], element);
  }
  TkDND_Eval(Tk_Interp(tkwin), 4, objv);
  Tcl_Free((char *) typelist);
  return True;
} /* TkDND_HandleXdndEnter */

int TkDND_HandleXdndPosition(Tk_Window tkwin, XClientMessageEvent cm) {
  Tcl_Interp *interp = Tk_Interp(tkwin);
  Tk_Window mouse_tkwin;
  Tcl_Obj* result;
  Tcl_Obj* objv[4];
  const unsigned long *l = (const unsigned long *) cm.data.l;
  int rootX, rootY, index, status;
  XClientMessageEvent response;
  int width = 1, height = 1;
  static char *DropActions[] = {
    "copy", "move", "link", "ask",  "private", "refuse_drop", "default",
    (char *) NULL
  };
  enum dropactions {
    ActionCopy, ActionMove, ActionLink, ActionAsk, ActionPrivate,
    refuse_drop, ActionDefault
  };

  if (interp == NULL) return False;

  rootX = (l[2] & 0xffff0000) >> 16;
  rootY =  l[2] & 0x0000ffff;
  mouse_tkwin = Tk_CoordsToWindow(rootX, rootY, tkwin);
#ifdef GNOME_SUPPORT
  if (mouse_tkwin == NULL) {
    /* The GNOME shape is confusing Tk_CoordsToWindow(), because this shape has
     * the root window as parent. What the hell is GNOME doing? */
    mouse_tkwin = CoordsToWindow(rootX, rootY, tkwin);
  }
#endif
  if (mouse_tkwin == NULL) {
    /* We received the client message, but we cannot find a window? Strange...*/
    /* A last attemp: execute wm containing x, y */
    objv[0] = Tcl_NewStringObj("update", -1);
    objv[1] = Tcl_NewStringObj("idletasks", -1);
    TkDND_Eval(Tk_Interp(tkwin), 2, objv);
    objv[0] = Tcl_NewStringObj("winfo", -1);
    objv[1] = Tcl_NewStringObj("containing", -1);
    objv[2] = Tcl_NewIntObj(rootX);
    objv[3] = Tcl_NewIntObj(rootY);
    if (TkDND_Eval(Tk_Interp(tkwin), 4, objv) == TCL_OK) {
      result = Tcl_GetObjResult(interp); Tcl_IncrRefCount(result);
      mouse_tkwin = Tk_NameToWindow(interp, Tcl_GetString(result),
                                    Tk_MainWindow(interp));
      Tcl_DecrRefCount(result);
    }
  }
  /* Get the drag source. */
  objv[0] = Tcl_NewStringObj("tkdnd::xdnd::_GetDragSource", -1);
  if (TkDND_Eval(Tk_Interp(tkwin), 1, objv) != TCL_OK) return False;
  if (Tcl_GetLongFromObj(interp, Tcl_GetObjResult(interp),
                         (long *)&response.window) != TCL_OK) return False;
  /* Now that we have found the containing widget, ask it whether it will accept
   * the drop... */
  index = refuse_drop;
  if (mouse_tkwin != NULL) {
    objv[0] = Tcl_NewStringObj("tkdnd::xdnd::_HandleXdndPosition", -1);
    objv[1] = Tcl_NewStringObj(Tk_PathName(mouse_tkwin), -1);
    objv[2] = Tcl_NewIntObj(rootX);
    objv[3] = Tcl_NewIntObj(rootY);
    if (TkDND_Eval(Tk_Interp(tkwin), 4, objv) == TCL_OK) {
      /* Get the returned action... */
      result = Tcl_GetObjResult(interp); Tcl_IncrRefCount(result);
      status = Tcl_GetIndexFromObj(interp, result, (const char **) DropActions,
                              "dropactions", 0, &index);
      Tcl_DecrRefCount(result);
      if (status != TCL_OK) index = refuse_drop;
    }
  }
  /* Sent */
  response.type         = ClientMessage;
  response.format       = 32;
  response.message_type = Tk_InternAtom(tkwin, "XdndStatus");
  response.data.l[0]    = (mouse_tkwin!=NULL) ? Tk_WindowId(mouse_tkwin) : 0;
  response.data.l[1]    = 1; /* yes */
  response.data.l[2]    = ((rootX) << 16) | ((rootY)  & 0xFFFFUL); /* x, y */
  response.data.l[3]    = ((width) << 16) | ((height) & 0xFFFFUL); /* w, h */
  response.data.l[4]    = 0; /* action */
  switch ((enum dropactions) index) {
    case ActionDefault:
    case ActionCopy:
      response.data.l[4] = Tk_InternAtom(tkwin, "XdndActionCopy");    break;
    case ActionMove:
      response.data.l[4] = Tk_InternAtom(tkwin, "XdndActionMove");    break;
    case ActionLink:
      response.data.l[4] = Tk_InternAtom(tkwin, "XdndActionLink");    break;
    case ActionAsk:
      response.data.l[4] = Tk_InternAtom(tkwin, "XdndActionAsk");     break;
    case ActionPrivate:
      response.data.l[4] = Tk_InternAtom(tkwin, "XdndActionPrivate"); break;
    case refuse_drop: {
      response.data.l[1] = 0; /* Refuse drop. */
    }
  }
#ifdef GNOME_SUPPORT
  if (Tk_PathName(tkwin) == NULL) {
    /* GNOME is expecting the window manager frame. */
    response.data.l[0] = Tk_WindowId(tkwin);
  }
#endif
  XSendEvent(cm.display, response.window, False, NoEventMask,
             (XEvent*)&response);
  return True;
} /* TkDND_HandleXdndPosition */

int TkDND_HandleXdndLeave(Tk_Window tkwin, XClientMessageEvent cm) {
  Tcl_Interp *interp = Tk_Interp(tkwin);
  Tcl_Obj* objv[1];
  if (interp == NULL) return False;
  objv[0] = Tcl_NewStringObj("tkdnd::xdnd::_HandleXdndLeave", -1);
  TkDND_Eval(Tk_Interp(tkwin), 1, objv);
  return True;
} /* TkDND_HandleXdndLeave */

int TkDND_HandleXdndDrop(Tk_Window tkwin, XClientMessageEvent cm) {
  XClientMessageEvent finished;
  Tcl_Interp *interp = Tk_Interp(tkwin);
  Tcl_Obj* objv[2], *result;
  int status, index;
  Time time = cm.data.l[2];
  static char *DropActions[] = {
    "copy", "move", "link", "ask",  "private", "refuse_drop", "default",
    (char *) NULL
  };
  enum dropactions {
    ActionCopy, ActionMove, ActionLink, ActionAsk, ActionPrivate,
    refuse_drop, ActionDefault
  };

  if (interp == NULL) return False;

  /* Get the drag source. */
  objv[0] = Tcl_NewStringObj("tkdnd::xdnd::_GetDragSource", -1);
  if (TkDND_Eval(Tk_Interp(tkwin), 1, objv) != TCL_OK) return False;
  if (Tcl_GetLongFromObj(interp, Tcl_GetObjResult(interp),
                         (long *) &finished.window) != TCL_OK) return False;

  /* Get the drop target. */
#ifdef GNOME_SUPPORT
  /* It seems that GNOME is expecting thw window manager frame. */
  if (Tk_PathName(tkwin) == NULL) {
    finished.data.l[0] = Tk_WindowId(tkwin);
  } else {
#endif
    objv[0] = Tcl_NewStringObj("tkdnd::xdnd::_GetDropTarget", -1);
    TkDND_Eval(Tk_Interp(tkwin), 1, objv);
    if (Tcl_GetLongFromObj(interp,
           Tcl_GetObjResult(interp), &finished.data.l[0]) != TCL_OK) {
      finished.data.l[0] = None;
    }
#ifdef GNOME_SUPPORT
  }
#endif

  /* Call out Tcl callback. */
  objv[0] = Tcl_NewStringObj("tkdnd::xdnd::_HandleXdndDrop", -1);
  objv[1] = Tcl_NewLongObj(time);
  if (TkDND_Eval(Tk_Interp(tkwin), 2, objv) == TCL_OK) {
    finished.data.l[1] = 1; /* Accept drop. */
    /* Get the returned action... */
    result = Tcl_GetObjResult(interp); Tcl_IncrRefCount(result);
    status = Tcl_GetIndexFromObj(interp, result, (const char **) DropActions,
                            "dropactions", 0, &index);
    Tcl_DecrRefCount(result);
    if (status != TCL_OK) index = refuse_drop;
    switch ((enum dropactions) index) {
      case ActionDefault:
      case ActionCopy:
        finished.data.l[2] = Tk_InternAtom(tkwin, "XdndActionCopy");    break;
      case ActionMove:
        finished.data.l[2] = Tk_InternAtom(tkwin, "XdndActionMove");    break;
      case ActionLink:
        finished.data.l[2] = Tk_InternAtom(tkwin, "XdndActionLink");    break;
      case ActionAsk:
        finished.data.l[2] = Tk_InternAtom(tkwin, "XdndActionAsk");     break;
      case ActionPrivate:
        finished.data.l[2] = Tk_InternAtom(tkwin, "XdndActionPrivate"); break;
      case refuse_drop: {
        finished.data.l[1] = 0; /* Drop canceled. */
      }
    }
  } else {
    finished.data.l[1] = 0;
  }
  /* Send XdndFinished. */
  finished.type         = ClientMessage;
  finished.format       = 32;
  finished.message_type = Tk_InternAtom(tkwin, "XdndFinished");
  XSendEvent(cm.display, finished.window, False, NoEventMask,
             (XEvent*)&finished);
  return True;
} /* TkDND_HandleXdndDrop */

int TkDND_HandleXdndStatus(Tk_Window tkwin, XClientMessageEvent cm) {
  return False;
} /* TkDND_HandleXdndStatus */

int TkDND_HandleXdndFinished(Tk_Window tkwin, XClientMessageEvent cm) {
  return False;
} /* TkDND_HandleXdndFinished */

static int TkDND_XDNDHandler(Tk_Window tkwin, XEvent *xevent) {
  XClientMessageEvent clientMessage;
  if (xevent->type != ClientMessage) return False;
  clientMessage = xevent->xclient;

  if (clientMessage.message_type == Tk_InternAtom(tkwin, "XdndPosition")) {
#ifdef DEBUG_CLIENTMESSAGE_HANDLER
    printf("XDND_HandleClientMessage: Received XdndPosition\n");
#endif /* DEBUG_CLIENTMESSAGE_HANDLER */
    return TkDND_HandleXdndPosition(tkwin, clientMessage);
  } else if (clientMessage.message_type == Tk_InternAtom(tkwin, "XdndEnter")) {
#ifdef DEBUG_CLIENTMESSAGE_HANDLER
    printf("XDND_HandleClientMessage: Received XdndEnter\n");
#endif /* DEBUG_CLIENTMESSAGE_HANDLER */
    return TkDND_HandleXdndEnter(tkwin, clientMessage);
  } else if (clientMessage.message_type == Tk_InternAtom(tkwin, "XdndStatus")) {
#ifdef DEBUG_CLIENTMESSAGE_HANDLER
    printf("XDND_HandleClientMessage: Received XdndStatus\n");
#endif /* DEBUG_CLIENTMESSAGE_HANDLER */
    return TkDND_HandleXdndStatus(tkwin, clientMessage);
  } else if (clientMessage.message_type == Tk_InternAtom(tkwin, "XdndLeave")) {
#ifdef DEBUG_CLIENTMESSAGE_HANDLER
    printf("XDND_HandleClientMessage: Received XdndLeave\n");
#endif /* DEBUG_CLIENTMESSAGE_HANDLER */
    return TkDND_HandleXdndLeave(tkwin, clientMessage);
  } else if (clientMessage.message_type == Tk_InternAtom(tkwin, "XdndDrop")) {
#ifdef DEBUG_CLIENTMESSAGE_HANDLER
    printf("XDND_HandleClientMessage: Received XdndDrop\n");
#endif /* DEBUG_CLIENTMESSAGE_HANDLER */
    return TkDND_HandleXdndDrop(tkwin, clientMessage);
  } else if (clientMessage.message_type ==
                                         Tk_InternAtom(tkwin, "XdndFinished")) {
#ifdef DEBUG_CLIENTMESSAGE_HANDLER
    printf("XDND_HandleClientMessage: Received XdndFinished\n");
#endif /* DEBUG_CLIENTMESSAGE_HANDLER */
    return TkDND_HandleXdndFinished(tkwin, clientMessage);
  } else {
#ifdef TKDND_ENABLE_MOTIF_DROPS
    if (MotifDND_HandleClientMessage(tkwin, xevent)) return True;
#endif /* TKDND_ENABLE_MOTIF_DROPS */
  }
  return False;
} /* TkDND_XDNDHandler */

int TkDND_GetSelectionObjCmd(ClientData clientData, Tcl_Interp *interp,
                             int objc, Tcl_Obj *CONST objv[]) {
  Time time;
  Tk_Window path;
  Atom selection;

  if (objc != 4) {
    Tcl_WrongNumArgs(interp, 1, objv, "path time type");
    return TCL_ERROR;
  }

  if (Tcl_GetLongFromObj(interp, objv[2], (long *) &time) != TCL_OK) {
    return TCL_ERROR;
  }

  path      = TkDND_TkWin(objv[1]);
  selection = Tk_InternAtom(path, "XdndSelection");

  XConvertSelection(Tk_Display(path), selection,
                    Tk_InternAtom(path, Tcl_GetString(objv[3])),
                    selection, Tk_WindowId(path), time);
  return TCL_OK;
} /* TkDND_GetSelectionObjCmd */

/*
 * For C++ compilers, use extern "C"
 */
#ifdef __cplusplus
extern "C" {
#endif
DLLEXPORT int Tkdnd_Init(Tcl_Interp *interp);
DLLEXPORT int Tkdnd_SafeInit(Tcl_Interp *interp);
#ifdef __cplusplus
}
#endif

int DLLEXPORT Tkdnd_Init(Tcl_Interp *interp) {
  int major, minor, patchlevel;

  if (
#ifdef USE_TCL_STUBS
      Tcl_InitStubs(interp, "8.3", 0)
#else
      Tcl_PkgRequire(interp, "Tcl", "8.3", 0)
#endif /* USE_TCL_STUBS */
            == NULL) {
            return TCL_ERROR;
  }
  if (
#ifdef USE_TK_STUBS
       Tk_InitStubs(interp, "8.3", 0)
#else
       Tcl_PkgRequire(interp, "Tk", "8.3", 0)
#endif /* USE_TK_STUBS */
            == NULL) {
            return TCL_ERROR;
  }

  /*
   * Get the version, because we really need 8.3.3+.
   */
  Tcl_GetVersion(&major, &minor, &patchlevel, NULL);
  if ((major == 8) && (minor == 3) && (patchlevel < 3)) {
    Tcl_SetResult(interp, "tkdnd requires Tk 8.3.3 or greater", TCL_STATIC);
    return TCL_ERROR;
  }


  /* Register the various commands */
  if (Tcl_CreateObjCommand(interp, "_register_types",
           (Tcl_ObjCmdProc*) TkDND_RegisterTypesObjCmd,
           (ClientData) NULL, (Tcl_CmdDeleteProc *) NULL) == NULL) {
    return TCL_ERROR;
  }

  if (Tcl_CreateObjCommand(interp, "_get_selection",
           (Tcl_ObjCmdProc*) TkDND_GetSelectionObjCmd,
           (ClientData) NULL, (Tcl_CmdDeleteProc *) NULL) == NULL) {
    return TCL_ERROR;
  }

  /* Finally, register the XDND Handler... */
  Tk_CreateClientMessageHandler(&TkDND_XDNDHandler);

  Tcl_PkgProvide(interp, PACKAGE_NAME, PACKAGE_VERSION);
  return TCL_OK;
} /* Tkdnd_Init */

int DLLEXPORT Tkdnd_SafeInit(Tcl_Interp *interp) {
  return Tkdnd_Init(interp);
} /* Tkdnd_SafeInit */

/* vi:set ts=2 sw=2 et: */
