/*
Copyright (C) 1996-1997 Id Software, Inc.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/

char *ID = "$VER: AmiQuake 1.22\r\n";  

#include "quakedef.h"



// Amiga includes.
#include <proto/exec.h>
#include <proto/dos.h>

#include <clib/icon_protos.h>
#include <workbench/startup.h>


// External video window from vid_amiga.c
extern struct Window *video_window;

// Dedicated server flag (not used on Amiga but needed for host.c)
qboolean isDedicated = FALSE;

// Mouse stuff.
int mouseX = 0;
int mouseY = 0;
qboolean mouse_has_moved = false;

#define RAWKEY_NM_WHEEL_UP      0x7A
#define RAWKEY_NM_WHEEL_DOWN    0x7B


static quakeparms_t quakeparms; 
 


static int myArgc = 0;
static char	*myArgv[MAX_NUM_ARGVS];

static int wbClosed = 0;



#ifndef NDEBUG
static int debugFileHandle = 0;

void Sys_Printf (char *message, ...)
{
	va_list		argptr;
	char		text[1024];

    va_start (argptr, message);
    vsprintf (text, message, argptr);
    va_end (argptr);

    if (!debugFileHandle) {
        debugFileHandle = Sys_FileOpenWrite("DEBUG.TXT");
    }

    if (debugFileHandle) {
    	Sys_FileWrite(debugFileHandle, text, strlen(text));
    }
}
#endif


void IN_MLookDown (void);

// Timer functions from original awinquake
double Sys_FloatTime (void)
{
#ifndef __PPC__
  static unsigned int basetime=0;
  unsigned int clock[2];

  timer (clock);
  if (!basetime)
    basetime = clock[0];
  return (clock[0]-basetime) + clock[1] / 1000000.0;
#else
  unsigned int clock[2];

  ppctimer (clock);
#ifdef __VBCC__  /* work around bug in VBCC */
  return (((double)clock[0]) * (2147483648.0 + 2147483648.0) +
          (double)clock[1]) * clocks2secs;
#else
  return (((double)clock[0]) * 4294967296.0 + (double)clock[1]) *
         clocks2secs;
#endif
#endif
}

char *Sys_ConsoleInput (void)
{
	return NULL;
}

void Sys_Sleep (void)
{
}

void Sys_HighFPPrecision (void)
{
}

void Sys_LowFPPrecision (void)
{
}

static void Sys_Init(void) {

    // Allocate memory.
    quakeparms.memsize = 16*1024*1024;
    
    // alloc 16-byte aligned quake memory
    quakeparms.memsize = (quakeparms.memsize+15)&~15;
	quakeparms.membase = malloc(quakeparms.memsize);
	if (!quakeparms.membase) {
		Sys_Error ("Not enough memory free\n");
    }
    
    // Mouse look by default.
    IN_MLookDown();
}

void Sys_Quit(void) {
    
	Host_Shutdown();
        	
	if (quakeparms.membase) {
        free(quakeparms.membase);
        quakeparms.membase = NULL;
    }
    
#ifndef NDEBUG
    if (debugFileHandle) {
    	Sys_FileClose(debugFileHandle);
    }
#endif    

	if (wbClosed) {
        OpenWorkBench();
    }
    
	exit(EXIT_SUCCESS);	
}
 

void Sys_Error (char *error, ...)
{
	va_list		argptr;
	char		text[1024];
	int errorFileHandle;

    
    va_start (argptr, error);
    vsprintf (text, error, argptr);
    va_end (argptr);

    errorFileHandle = Sys_FileOpenWrite("ERROR.TXT");
    if (errorFileHandle) {
    	Sys_FileWrite(errorFileHandle, text, strlen(text));
    	Sys_FileClose(errorFileHandle);
    }

	Host_Shutdown();
	
	if (quakeparms.membase) {
        free(quakeparms.membase);
        quakeparms.membase = NULL;
    }	

	if (wbClosed) {
        OpenWorkBench();
    }
    
	exit(EXIT_FAILURE);
}



static int xlate[0x68] = {
    '`', '1', '2', '3', '4', '5', '6', '7',
    '8', '9', '0', '-', '=', '\\', 0, '0',
    'q', 'w', 'e', 'r', 't', 'y', 'u', 'i',
    'o', 'p', K_F11, K_F12, 0, '0', '2', '3',
    'a', 's', 'd', 'f', 'g', 'h', 'j', 'k',
    'l', ';', '\'', K_ENTER, 0, '4', '5', '6',
    K_SHIFT, 'z', 'x', 'c', 'v', 'b', 'n', 'm',
    ',', '.', '/', 0, '.', '7', '8', '9',
    K_SPACE, K_BACKSPACE, K_TAB, K_ENTER, K_ENTER, K_ESCAPE, K_F11,
    0, 0, 0, '-', 0, K_UPARROW, K_DOWNARROW, K_RIGHTARROW, K_LEFTARROW,
    K_F1, K_F2, K_F3, K_F4, K_F5, K_F6, K_F7, K_F8,
    K_F9, K_F10, '(', ')', '/', '*', '=', K_PAUSE,
    K_SHIFT, K_SHIFT, 0, K_CTRL, K_ALT, K_ALT, 0, K_CTRL
};
    

void Sys_SendKeyEvents(void) {
    
  ULONG class;
  UWORD code;
  WORD mousex, mousey;
  struct IntuiMessage *msg;


  if (video_window != NULL) {
    while ((msg = (struct IntuiMessage *)GetMsg (video_window->UserPort)) != NULL) {
        ReplyMsg ((struct Message *)msg);
            
        class = msg->Class;
        code = msg->Code;

        switch (class) {
        case IDCMP_RAWKEY:
            switch (code) {
                case RAWKEY_NM_WHEEL_UP:
                	Key_Event(K_MWHEELUP, true);
                	Key_Event(K_MWHEELUP, false);
                	break;
                
                case RAWKEY_NM_WHEEL_DOWN:
                	Key_Event(K_MWHEELDOWN, true);
                	Key_Event(K_MWHEELDOWN, false);
                	break;
                
                default:
                    if (code & IECODE_UP_PREFIX) {
                		Key_Event(xlate[code & ~IECODE_UP_PREFIX], false);
                	} else {
                		Key_Event(xlate[code], true);
                	}
                    break;
            }         
            break;
          
        case IDCMP_MOUSEBUTTONS:
          switch (code) {
            case IECODE_LBUTTON:
              Key_Event (K_MOUSE1, true);
              break;
            case IECODE_LBUTTON + IECODE_UP_PREFIX:
              Key_Event (K_MOUSE1, false);
              break;
            case IECODE_MBUTTON:
              Key_Event (K_MOUSE2, true);
              break;
            case IECODE_MBUTTON + IECODE_UP_PREFIX:
              Key_Event (K_MOUSE2, false);
              break;
            case IECODE_RBUTTON:
              Key_Event (K_MOUSE3, true);
              break;
            case IECODE_RBUTTON + IECODE_UP_PREFIX:
              Key_Event (K_MOUSE3, false);
              break;
            default:
              break;
          }
          break;
          
        case IDCMP_MOUSEMOVE:
          mouseX = msg->MouseX;
          mouseY = msg->MouseY;
          mouse_has_moved = true;
          break;
          
        default:
          break;
        }
    }
  }
}

 
//=============================================================================



/* these command line arguments are flags */
static char *flags[] = {
    "-nosound",
    "-condebug",
    "-rogue",
    "-hipnotic"               
};


/* these command line arguments each take a value */
static char *settings[] = {
    "-game"
};

static void RunGameLoop(void)
{
    float newtime;
    float oldtime;
        
    // Never exits
    oldtime = Sys_FloatTime();
    while (true) {
        newtime = Sys_FloatTime();

        Host_Frame(newtime - oldtime);

        oldtime = newtime;
	}
}


int main(int argcWb, char *argvWb[]) {
	char path[MAX_OSPATH];
    struct DiskObject *diskObject;
    char *toolType;
    int i;
    struct WBStartup* wbStartup;
    int closeWb = 0;


    // Setup the system (allocate memory, enable mouselook).
    Sys_Init();


    // Check if started from shell or Workbench
    if (argcWb != 0) {
        // Started from the shell - use standard argc/argv
        COM_InitArgv(argcWb, argvWb);
        quakeparms.basedir = "";
        quakeparms.cachedir = NULL;
        quakeparms.argc = com_argc;
        quakeparms.argv = com_argv;
    } else {
        // Started from Workbench - process tooltypes
        wbStartup = (struct WBStartup*)argvWb;

        // Set the current directory.
        NameFromLock(wbStartup->sm_ArgList[0].wa_Lock, path, MAX_OSPATH);
        CurrentDir(wbStartup->sm_ArgList[0].wa_Lock);
        quakeparms.basedir = path;
        quakeparms.cachedir = NULL;

        // Setup command line.
        myArgv[myArgc++] = "AmiQuake";

        // Process Tooltypes.
        diskObject = GetDiskObject((char*)wbStartup->sm_ArgList[0].wa_Name);

        if (diskObject != NULL) {
            toolType = (char*)FindToolType(diskObject->do_ToolTypes, "CLOSE_WB");
            if (toolType != NULL) {
                closeWb = 1;
            }

            // Process DOS command line flags.
            for (i = 0; i < sizeof(flags)/sizeof(flags[0]); i++) {
                if (FindToolType(diskObject->do_ToolTypes, &flags[i][1]) != NULL) {
                    myArgv[myArgc++] = flags[i];
                }
            }

            // Process DOS command line settings.
            for (i = 0; i < sizeof(settings)/sizeof(settings[0]); i++) {
                if ((toolType = FindToolType (diskObject->do_ToolTypes, &settings[i][1])) != NULL) {
                    myArgv[myArgc++] = settings[i];
                    myArgv[myArgc] = malloc(strlen(toolType)+1);
                    strcpy(myArgv[myArgc++], toolType);
                }
            }
        }

        // Close WB if requested.
        if (closeWb) {
            wbClosed = CloseWorkBench();
        }

        COM_InitArgv(myArgc, myArgv);

        quakeparms.argc = myArgc;
        quakeparms.argv = myArgv;
    }
    
    // Setup the host.
	Host_Init(&quakeparms);


    // Never returns.
    RunGameLoop();

    
    // Keep compiler happy!    
    return EXIT_SUCCESS;
}
