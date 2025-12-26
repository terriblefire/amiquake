/*
Copyright (C) 2000 Peter McGavin.

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

/* the SAS/C __AMIGADATE__ macro appears to have broken from 1st Jan 2000 */
#ifdef __PPC__
#ifdef __STORM__
const char amigaversion[] = "$VER: awinquakewos 0.9 (12.3.100)\n";
#elif __VBCC__
const char amigaversion[] = "$VER: awinquakevbcc 0.9 (12.3.100)\n"; // __AMIGADATE__ ;
#else
const char amigaversion[] = "$VER: awinquakeppc 0.9 (12.3.100)\n"; // __AMIGADATE__ ;
#endif
#else
const char amigaversion[] = "$VER: awinquake 0.9 (12.3.100)\n"; // __AMIGADATE__ ;
#endif

#ifdef __SASC
//long __oslibversion = 38;	/* we require at least OS3.0 for LoadRGB32() */
//char __stdiowin[] = "CON:20/50/600/130/awinquake";
//char __stdiov37[] = "/AUTO/CLOSE/WAIT";
//long __stack = 500000;  /* increase stack size to at least 500000 bytes */
#endif

#include <stdio.h>
#include <stdlib.h>

#ifdef __SASC
#include <dos.h>
#endif

#ifndef __PPC__
#include <time.h>
#endif

#ifdef __PPC__
#include <exec/types.h>
#if defined(__STORM__) || defined(__VBCC__)
#include <powerpc/powerpc.h>
#include <clib/exec_protos.h>
#include <clib/powerpc_protos.h>
#endif
#ifdef __SASC
#include <PowerUP/ppclib/ppc.h>
#include <proto/exec.h>
#endif
#endif

#include "quakedef.h"
#include "errno.h"

#ifdef __PPC__
#include "amiga_timer.h"
#endif

qboolean isDedicated = FALSE;

#ifdef __PPC__
static int cpu_type;
static int bus_clock;
static int bus_MHz;
static double clocks2secs;
#endif

/*
===============================================================================

FILE IO

===============================================================================
*/

#define	MAX_HANDLES		10
FILE	*sys_handles[MAX_HANDLES];

int		findhandle (void)
{
	int		i;
	
	for (i=1 ; i<MAX_HANDLES ; i++)
		if (!sys_handles[i])
			return i;
	Sys_Error ("out of handles");
	return -1;
}

/*
================
filelength
================
*/
int filelength (FILE *f)
{
	int		pos;
	int		end;

	pos = ftell (f);
	fseek (f, 0, SEEK_END);
	end = ftell (f);
	fseek (f, pos, SEEK_SET);

	return end;
}

int Sys_FileOpenRead (char *path, int *hndl)
{
	FILE	*f;
	int		i;
	
	i = findhandle ();

	printf ("Opening '%s' for read\n", path);
	f = fopen(path, "rb");
	if (!f)
	{
		*hndl = -1;
		return -1;
	}
	sys_handles[i] = f;
	*hndl = i;
	
	return filelength(f);
}

int Sys_FileOpenWrite (char *path)
{
	FILE	*f;
	int		i;
	
	i = findhandle ();

	printf ("Opening '%s' for write\n", path);
	f = fopen(path, "wb");
	if (!f)
		Sys_Error ("Error opening %s: %s", path,strerror(errno));
	sys_handles[i] = f;
	
	return i;
}

void Sys_FileClose (int handle)
{
	fclose (sys_handles[handle]);
	sys_handles[handle] = NULL;
}

void Sys_FileSeek (int handle, int position)
{
	/* printf ("%d: Seeking to %d\n", handle, position); */
	if (fseek (sys_handles[handle], position, SEEK_SET) == -1)
		Sys_Error ("Error in fseek()");
}

int Sys_FileRead (int handle, void *dest, int count)
{
	/* printf ("%d: Reading %d to %08x\n", handle, count, dest); */
	return (int)fread (dest, 1, count, sys_handles[handle]);
}

int Sys_FileWrite (int handle, void *data, int count)
{
	return (int)fwrite (data, 1, count, sys_handles[handle]);
}

int	Sys_FileTime (char *path)
{
	FILE	*f;
	
	f = fopen(path, "rb");
	if (f)
	{
		fclose(f);
		return 1;
	}
	
	return -1;
}

void Sys_mkdir (char *path)
{
}


/*
===============================================================================

SYSTEM IO

===============================================================================
*/

void Sys_MakeCodeWriteable (unsigned long startaddr, unsigned long length)
{
}


void Sys_DebugLog(char *file, char *fmt, ...)
{
}

void Sys_Error (char *error, ...)
{
	va_list		argptr;

	printf ("Sys_Error: ");	
	va_start (argptr,error);
	vprintf (error,argptr);
	va_end (argptr);
	printf ("\n");

	exit (20);
}

void Sys_Printf (char *fmt, ...)
{
	va_list		argptr;
	
	va_start (argptr,fmt);
	if (!con_initialized)
	  vprintf (fmt,argptr);
	va_end (argptr);
}

void Sys_Quit (void)
{
	exit (0);
}

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

/*
void Sys_SendKeyEvents (void)
{
}
*/

void Sys_HighFPPrecision (void)
{
}

void Sys_LowFPPrecision (void)
{
}

//=============================================================================

int main (int argc, char **argv)
{
  int j;
  double time, oldtime, newtime;
  quakeparms_t parms;

//  printf ("Stack size is %d\n", stacksize());

  memset (&parms, 0, sizeof(parms));

  COM_InitArgv (argc, argv);

  parms.memsize = 8*1024*1024;
  j = COM_CheckParm("-mem");
  if (j)
    parms.memsize = (int) (Q_atof(com_argv[j+1]) * 1024 * 1024);

  if ((parms.membase = malloc (parms.memsize)) == NULL)
    Sys_Error ("Can't allocate %d bytes", parms.memsize);
//  parms.basedir = "QUAKE:";
//  parms.basedir = "";
  parms.basedir = "PROGDIR:";
  parms.cachedir = "";

  parms.argc = com_argc;
  parms.argv = com_argv;

#ifdef __PPC__

#ifdef __SASC
  {
  int i;
  ULONG ipll, ipll2;
  double pll;

  cpu_type = PPCGetAttr (PPCINFOTAG_CPU);
  switch (cpu_type) {
    case 3:
      printf ("\nCPU is PPC603 ");
      break;
    case 4:
      printf ("\nCPU is PPC604 ");
      break;
    case 5:
      printf ("\nCPU is PPC602 ");
      break;
    case 6:
      printf ("\nCPU is PPC603e ");
      break;
    case 7:
      printf ("\nCPU is PPC603e+ ");
      break;
    case 9:
      printf ("\nCPU is PPC604e ");
      break;
    default:
      printf ("\nCPU is PPC ");
      break;
  }

  bus_clock = PPCGetAttr (PPCINFOTAG_CPUCLOCK);
  printf ("running at %d MHz ", bus_clock);
  if (!bus_clock)
    bus_clock = 233333333;
  else
    bus_clock = bus_clock * 1000000;
  ipll = PPCGetAttr (PPCINFOTAG_CPUPLL);
  if ((ipll & 0xf0000000) && !(ipll & 0x0ffffff0))
    ipll2 = ipll >> 28;     /* work around bug in ppc.library */
  else
    ipll2 = ipll & 0x0000000f;
  switch (ipll2) {    /* see http://mx1.xoom.com/silicon/docs/ppc_pll.html */
    case 0:
    case 1:
    case 2:
    case 3:
      pll = 1.0;			// PLL is 1:1 (or bypassed)
      break;
    case 4:
    case 5:
      pll = 2.0;			// PLL is 2:1
      break;
    case 6:
      pll = 2.5;
      break;
    case 7:
      pll = 4.5;
      break;
    case 8:
    case 9:
      pll = 3.0;			// PLL is 3:1
      break;
    case 10:
      pll = 4.0;
      break;
    case 11:
      pll = 5.0;
      break;
    case 12:
      if ((cpu_type == 4) || (cpu_type == 8))
        pll = 1.5;			// PLL is 1.5:1
      else
        pll = 4.0;			// PLL is 4:1
      break;
    case 13:
      pll = 6.0;			// PLL is 6:1
      break;
    case 14:
      pll = 3.5;			// PLL is 3.5:1
      break;
    default:
      pll = 3.0;
      break;
  }
  printf ("using a PLL divisor of %3.1f.  (%08x)\n", pll, ipll);

  i = COM_CheckParm ("-bus");
  if (i && i < com_argc-1) {
    bus_clock = atoi(com_argv[i+1]);
  } else {
    bus_clock = (int)((double)bus_clock / pll);
  }

  bus_MHz = bus_clock / 1000000;
  printf("Bus clock is %d MHz.\n\n", bus_MHz);

  clocks2secs = 4.0 / bus_clock;
  }
#endif /* __SASC */

#if defined(__STORM__) || defined(__VBCC__)
  {
    struct TagItem ti_cputype[] = {{GETINFO_CPU, 0}, {TAG_END, 0}};
    struct TagItem ti_cpuclock[] = {{GETINFO_CPUCLOCK, 0}, {TAG_END, 0}};
    struct TagItem ti_busclock[] = {{GETINFO_BUSCLOCK, 0}, {TAG_END, 0}};

    GetInfo (ti_cputype);
    cpu_type = ti_cputype[0].ti_Data;
    switch (cpu_type) {
      case CPUF_603:
        printf ("\nCPU is PPC603 ");
        break;
      case CPUF_604:
        printf ("\nCPU is PPC604 ");
        break;
      case CPUF_603E:
        printf ("\nCPU is PPC603e ");
        break;
      case CPUF_604E:
        printf ("\nCPU is PPC604e ");
        break;
      case CPUF_620:
        printf ("\nCPU is PPC620 ");
        break;
      default:
        printf ("\nCPU is PPC ");
        break;
    }

    GetInfo (ti_cpuclock);
    bus_clock = ti_cpuclock[0].ti_Data;
    printf ("running at %d MHz\n", bus_clock / 1000000);

    GetInfo (ti_busclock);
    bus_clock = ti_busclock[0].ti_Data;
    bus_MHz = bus_clock / 1000000;
    printf("Bus clock is %d MHz.\n\n", bus_MHz);

    clocks2secs = 4.0 / bus_clock;

  }

#endif /* __STORM__ */

#endif /* __PPC__ */

//	printf ("Host_Init\n");
	Host_Init (&parms);

//	while (1)
//	{
//		Host_Frame ((float)0.1);
//	}

	oldtime = Sys_FloatTime ();
	while (1)
	{
#ifdef __SASC
		chkabort ();
#endif
		newtime = Sys_FloatTime ();
		time = newtime - oldtime;

		if (time < 0.0)
			printf ("Negative time = %f!!\n", time);

		if (cls.state == ca_dedicated && (time<sys_ticrate.value))
			continue;

		Host_Frame ((float)time);

		oldtime = newtime;
	}
	return 0;
}

/**********************************************************************/
#ifdef __SASC
void _STD_Host_Shutdown (void)
{
//  printf ("_STD_Host_Shutdown\n");
  S_Shutdown();
  Host_Shutdown ();
}
#endif

/**********************************************************************/
#ifdef __STORM__
void EXIT_9_Host_Shutdown (void)
{
//  printf ("EXIT_9_Host_Shutdown\n");
  S_Shutdown();
  Host_Shutdown ();
}
#endif

/**********************************************************************/
#ifdef __VBCC__
void _EXIT_9_Host_Shutdown (void)
{
//  printf ("_EXIT_9_Host_Shutdown\n");
  S_Shutdown();
  Host_Shutdown ();
}
#endif

/**********************************************************************/
