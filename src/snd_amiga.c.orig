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
// snd_amiga.c

#include <exec/exec.h>
#include <dos/dos.h>
#include <graphics/gfxbase.h>
#include <devices/audio.h>
#include <devices/ahi.h>

#if defined(__VBCC__) || (defined(__STORM__) && defined(__PPC__))
#include <powerpc/powerpc.h>
#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/graphics_protos.h>
#include <clib/ahi_protos.h>
#include <clib/powerpc_protos.h>
extern struct GfxBase *GfxBase;
#else
#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/graphics.h>
#include <proto/ahi.h>
#endif
#if defined(__SASC) && defined(__PPC__)
#include <powerup/ppclib/memory.h>
#endif

#include "quakedef.h"

#if defined(__SASC) && defined(__PPC__)

#define	BeginIO(ioRequest)	_BeginIO(ioRequest)
static __inline void _BeginIO (struct IORequest *ioRequest)
{
  struct Caos MyCaos;
  MyCaos.M68kCacheMode	= IF_CACHEFLUSHALL;
  MyCaos.PPCCacheMode	= IF_CACHEFLUSHALL;
  MyCaos.a1		= (ULONG)ioRequest;
  MyCaos.caos_Un.Offset	= (-30);
  MyCaos.a6		= (ULONG)ioRequest->io_Device;
  PPCCallOS (&MyCaos);
}

#define	CheckIO(ioRequest) _MyCheckIO(EXEC_BASE_NAME, ioRequest)
static __inline struct IORequest *_MyCheckIO (void *SysBase, struct IORequest *ioRequest)
{
  struct Caos MyCaos;
  MyCaos.M68kCacheMode	= IF_CACHEFLUSHNO;
  MyCaos.PPCCacheMode	= IF_CACHEFLUSHNO;
  MyCaos.a1		= (ULONG)ioRequest;
  MyCaos.caos_Un.Offset	= (-468);
  MyCaos.a6		= (ULONG)SysBase;	
  return (struct IORequest *)PPCCallOS (&MyCaos);
}

#define	WaitIO(ioRequest) _MyWaitIO(EXEC_BASE_NAME, ioRequest)
static __inline struct IORequest *_MyWaitIO (void *SysBase, struct IORequest *ioRequest)
{
  struct Caos MyCaos;
  MyCaos.M68kCacheMode	= IF_CACHEFLUSHNO;
  MyCaos.PPCCacheMode	= IF_CACHEFLUSHNO;
  MyCaos.a1		= (ULONG)ioRequest;
  MyCaos.caos_Un.Offset	= (-474);
  MyCaos.a6		= (ULONG)SysBase;	
  return (struct IORequest *)PPCCallOS (&MyCaos);
}

#define	WaitPort(port) _MyWaitPort(EXEC_BASE_NAME, port)
static __inline struct Message *_MyWaitPort (void *SysBase, struct MsgPort *port)
{
  struct Caos	MyCaos;
  MyCaos.M68kCacheMode	= IF_CACHEFLUSHNO;
  MyCaos.PPCCacheMode	= IF_CACHEFLUSHNO;
  MyCaos.a0		= (ULONG) port;
  MyCaos.caos_Un.Offset	= (-384);
  MyCaos.a6		= (ULONG)SysBase;	
  return (struct Message *)PPCCallOS (&MyCaos);
}

#define	AbortIO(ioRequest) _MyAbortIO(EXEC_BASE_NAME, ioRequest)
static __inline void _MyAbortIO (void *SysBase, struct IORequest *ioRequest)
{
  struct Caos	MyCaos;
  MyCaos.M68kCacheMode	= IF_CACHEFLUSHNO;
  MyCaos.PPCCacheMode	= IF_CACHEFLUSHNO;
  MyCaos.a1		= (ULONG)ioRequest;
  MyCaos.caos_Un.Offset	= (-480);
  MyCaos.a6		= (ULONG)SysBase;	
  PPCCallOS (&MyCaos);
}

#endif

#if defined(__STORM__) && defined(__PPC__)
#define	BeginIO(ioRequest) _BeginIO(ioRequest)
__inline void _BeginIO(struct IORequest *ioRequest)
{
  struct PPCArgs args;
  memset (&args,0,sizeof(args));
  args.PP_Code		= (APTR)ioRequest->io_Device;
  args.PP_Offset	= (-30);
  args.PP_Flags		= 0;
  args.PP_Regs[PPREG_A1]= (ULONG)ioRequest;
  args.PP_Regs[PPREG_A6]= (ULONG)ioRequest->io_Device;
  Run68K (&args);
}
#endif

/**********************************************************************/

extern int desired_speed;
extern int desired_bits;
int using_ahi = FALSE;

/**********************************************************************/

/* AHI */

#define AHIBUFFERSIZE 262144

struct ahi_channel_info {
  struct AHIRequest *AHIio;
  double starttime;
  BOOL sound_in_progress;
};

struct Library *AHIBase = NULL;
static struct MsgPort *AHImp = NULL;
static struct ahi_channel_info ahi_channel_info[2] = {
  {NULL, 0.0, FALSE},
  {NULL, 0.0, FALSE}
};
static BYTE AHIDevice = -1;
static BOOL ahidevice_is_open = FALSE;
static double ahi_playtime;
static int which_buffer;


/* audio.device */

/* #define BUFFERSIZE 16384 */
#define BUFFERSIZE 4096

#define MAXNUMCHANNELS   4   /* max number of Amiga sound channels */

struct channel_info {
  struct MsgPort *audio_mp;
  struct IOAudio *audio_io;
  double starttime;
  BOOL sound_in_progress;
};

static struct channel_info channel_info[MAXNUMCHANNELS] = {
  {NULL, NULL, 0.0, FALSE},
  {NULL, NULL, 0.0, FALSE},
  {NULL, NULL, 0.0, FALSE},
  {NULL, NULL, 0.0, FALSE},
};

static int size;
static struct MsgPort *audio_mp = NULL;
static struct IOAudio *audio_io = NULL;
static BOOL audio_is_open = FALSE;
static ULONG clock_constant;   /* see Amiga Hardware Manual page 141 */
static UWORD period;
static double twice_real_speed;

/**********************************************************************/
static void stop_ahi_sound (struct ahi_channel_info *c)
{
  if (!ahidevice_is_open)
    return;
  if (c->sound_in_progress) {
    AbortIO ((struct IORequest *)c->AHIio);
    WaitPort (AHImp);
    GetMsg (AHImp);
    c->sound_in_progress = FALSE;
  }
}

/**********************************************************************/
// Starts an AHI sound in a particular sound channel.
// Use link for double-buffering.

static void start_ahi_sound (struct ahi_channel_info *c,
                             char *buffer, int length,
                             struct AHIRequest *link)
{
  if (!ahidevice_is_open)
    return;
  stop_ahi_sound (c);
  c->AHIio->ahir_Std.io_Command = CMD_WRITE;
  c->AHIio->ahir_Std.io_Flags = 0;
  c->AHIio->ahir_Std.io_Message.mn_Node.ln_Pri = -50;   /* sound effects */
  c->AHIio->ahir_Std.io_Data = buffer;
  c->AHIio->ahir_Std.io_Length = length;
  c->AHIio->ahir_Type = AHIST_S16S;
  c->AHIio->ahir_Frequency = shm->speed;
  c->AHIio->ahir_Volume = 0x10000;
  c->AHIio->ahir_Position = 0x8000;
  c->AHIio->ahir_Link = link;
  SendIO ((struct IORequest *)c->AHIio);
  c->sound_in_progress = TRUE;
}

/**********************************************************************/
// Stops an audio.device sound channel.

static void stopsound (int cnum)
{
  if (!audio_is_open)
    return;
  if (channel_info[cnum].sound_in_progress) {
    AbortIO ((struct IORequest *)channel_info[cnum].audio_io);
    WaitPort (channel_info[cnum].audio_mp);
    GetMsg (channel_info[cnum].audio_mp);
    channel_info[cnum].sound_in_progress = FALSE;
  }
}

/**********************************************************************/
// Starts an audio.device sound in a particular sound channel.

static int startsound (int cnum, char *buffer, int length)
{
  struct channel_info *c;

  if (!audio_is_open)
    return 1;
  stopsound (cnum);
  c = &channel_info[cnum];
  c->audio_io->ioa_Request.io_Command = CMD_WRITE;
  c->audio_io->ioa_Request.io_Flags = ADIOF_PERVOL;
  c->audio_io->ioa_Data = buffer;
  c->audio_io->ioa_Length = length;
  c->audio_io->ioa_Period = period;
  c->audio_io->ioa_Volume = 64;
  c->audio_io->ioa_Cycles = 0;
  BeginIO ((struct IORequest *)c->audio_io);
  c->starttime = Sys_FloatTime ();
  c->sound_in_progress = TRUE;
  return cnum;
}

/**********************************************************************/

qboolean SNDDMA_Init (void)
{
  int i;
  struct channel_info *c;
  UBYTE chans[1];

//  printf ("SNDDMA_Init()\n");

  if ((shm = (dma_t *)malloc (sizeof(dma_t))) == NULL)
    Sys_Error ("malloc() failed");
  memset((void*)shm, 0, sizeof(dma_t));

  if (COM_CheckParm ("-ahi")) {

    Con_Printf("Using AHI unit 0.\n");
    using_ahi = TRUE;

//#if defined(__SASC) && defined(__PPC__)
//    if ((shm->buffer = PPCAllocMem (AHIBUFFERSIZE, MEMF_NOCACHESYNCPPC |
//                                MEMF_NOCACHESYNCM68K | MEMF_PUBLIC)) == NULL)
//#else
    if ((shm->buffer = malloc (AHIBUFFERSIZE)) == NULL)
//#endif
      Sys_Error ("malloc() failed");
    memset (shm->buffer, 0, AHIBUFFERSIZE);

    shm->channels = 2;
    shm->speed = desired_speed;
    shm->samplebits = 16;
    shm->samples = AHIBUFFERSIZE / (shm->samplebits / 8);
    shm->submission_chunk = 1;

    if ((AHImp = CreateMsgPort ()) == NULL)
      Sys_Error ("CreateMsgPort() failed");
    for (i = 0; i < 2; i++)
      if ((ahi_channel_info[i].AHIio = (struct AHIRequest *)CreateIORequest
                                   (AHImp, sizeof(struct AHIRequest))) == NULL)
        Sys_Error ("CreateIORequest() failed");
    ahi_channel_info[0].AHIio->ahir_Version = 4;
    if ((AHIDevice = OpenDevice (AHINAME, AHI_DEFAULT_UNIT,
                                 (struct IORequest *)ahi_channel_info[0].AHIio,
                                 0)) != 0)
      Sys_Error ("OpenDevice() failed");
    ahidevice_is_open = TRUE;
    AHIBase = (struct Library *)ahi_channel_info[0].AHIio->ahir_Std.io_Device;
    *ahi_channel_info[1].AHIio = *ahi_channel_info[0].AHIio;

    twice_real_speed = 2.0 * (double)shm->speed;
    ahi_playtime = ((double)(AHIBUFFERSIZE >> 2)) / (double)shm->speed;
    //printf ("ahi_playtime = %f\n", ahi_playtime);

    ahi_channel_info[0].starttime = Sys_FloatTime ();
    start_ahi_sound (&ahi_channel_info[0], shm->buffer, AHIBUFFERSIZE, NULL);
    //printf ("start[0] = %f  %f\n", ahi_channel_info[0].starttime,
    //                               ahi_channel_info[0].starttime + ahi_playtime);
    ahi_channel_info[1].starttime = ahi_channel_info[0].starttime + ahi_playtime;
    start_ahi_sound (&ahi_channel_info[1], shm->buffer, AHIBUFFERSIZE,
                     ahi_channel_info[0].AHIio);
    //printf ("start[1] = %f  %f\n", ahi_channel_info[1].starttime,
    //                               ahi_channel_info[1].starttime + ahi_playtime);
    which_buffer = 0;

  } else { /* audio.device */

    Con_Printf("Using audio.device.\n");
    using_ahi = FALSE;

    if ((shm->buffer = AllocMem (BUFFERSIZE, MEMF_CHIP | MEMF_CLEAR)) == NULL)
      Sys_Error ("Out of CHIP memory for sound");
//    memset(shm->buffer, 0x80, BUFFERSIZE);

//    printf ("Sound buffer at 0x%08x\n", shm->buffer);

    shm->channels = 2;
    shm->speed = desired_speed;
    shm->samplebits = 8;
    shm->samples = BUFFERSIZE / (shm->samplebits / 8);
    shm->submission_chunk = 1;

    if ((audio_mp = CreateMsgPort ()) == NULL ||
        (audio_io = (struct IOAudio *)AllocMem(sizeof(struct IOAudio),
                                             MEMF_PUBLIC | MEMF_CLEAR)) == NULL)
      Sys_Error ("CreateMsgPort() or AllocMem() failed");

    chans[0] = (1 << shm->channels) - 1; /* shm->channels Amiga audio channels */
    audio_io->ioa_Request.io_Message.mn_ReplyPort = audio_mp;
    audio_io->ioa_Request.io_Message.mn_Node.ln_Pri = 127;
    audio_io->ioa_AllocKey = 0;
    audio_io->ioa_Data = chans;
    audio_io->ioa_Length = sizeof(chans);

    if (OpenDevice (AUDIONAME, 0, (struct IORequest *)audio_io, 0) != 0)
      Sys_Error ("OpenDevice(\"audio.device\") failed");
    audio_is_open = TRUE;

    for (i = 0; i < shm->channels; i++) {
      c = &channel_info[i];
      if ((c->audio_mp = CreateMsgPort ()) == NULL ||
          (c->audio_io = (struct IOAudio *)AllocMem(sizeof(struct IOAudio),
                                             MEMF_PUBLIC | MEMF_CLEAR)) == NULL)
        Sys_Error ("CreateMsgPort() or AllocMem() failed");
      *c->audio_io = *audio_io;
      c->audio_io->ioa_Request.io_Message.mn_ReplyPort = c->audio_mp;
      c->audio_io->ioa_Request.io_Unit = (struct Unit *)(1 << i);
    }

    if ((GfxBase->DisplayFlags & REALLY_PAL) == 0)
      clock_constant = 3579545;   /* NTSC */
    else
      clock_constant = 3546895;   /* PAL */

    period = ((clock_constant << 1) + shm->speed) / ((shm->speed) << 1);

    twice_real_speed = 2.0 * ((double)clock_constant) / (double)period;

    startsound (0, shm->buffer, BUFFERSIZE >> 1);
    startsound (1, shm->buffer + (BUFFERSIZE >> 1), BUFFERSIZE >> 1);
  }

  return 1;
}

/**********************************************************************/

int SNDDMA_GetDMAPos (void)
{
  if (shm == NULL || shm->buffer == NULL)
    return 0;

  if (using_ahi) {

    if (!ahi_channel_info[0].sound_in_progress)
      shm->samplepos = 0;
    else {
      struct ahi_channel_info *c, *c2;
      double now;

      now = Sys_FloatTime ();
      c = &ahi_channel_info[which_buffer];
      if (now >= c->starttime + ahi_playtime - 0.1 &&
          CheckIO ((struct IORequest *)c->AHIio)) {
        //printf ("finished[%d] = %f  %f\n", which_buffer, now,
        //                                   now - (c->starttime + ahi_playtime));
        c2 = &ahi_channel_info[1 - which_buffer];
        if (c2->starttime > now) {
          c2->starttime = now;
          //printf ("changed[%d] = %f  %f\n", 1 - which_buffer, c2->starttime,
          //                                  c2->starttime + ahi_playtime);
        }
        WaitPort (AHImp);
        GetMsg (AHImp);
        c->sound_in_progress = FALSE;
        if ((now = Sys_FloatTime ()) > (c->starttime =
                                        c2->starttime + ahi_playtime))
          c->starttime = now;
        start_ahi_sound (c, shm->buffer, AHIBUFFERSIZE,
                         ahi_channel_info[1 - which_buffer].AHIio);
        //printf ("start[%d] = %f  %f\n", which_buffer, c->starttime,
        //                                c->starttime + ahi_playtime);
        which_buffer = 1 - which_buffer;
        c = &ahi_channel_info[which_buffer];
      }
      shm->samplepos = ((int)((now + ahi_playtime - c->starttime) *
                              twice_real_speed + 0.5)) & (AHIBUFFERSIZE - 1);
    }

  } else {  /* audio.device */

    if (!channel_info[0].sound_in_progress)
      shm->samplepos = 0;
    else
      shm->samplepos = ((int)((Sys_FloatTime() - channel_info[0].starttime)
                              * twice_real_speed + 0.5))
                       & (BUFFERSIZE - 1);

  }

  return shm->samplepos;
}

/**********************************************************************/

void SNDDMA_Shutdown (void)
{
  int i;

//  printf ("SNDDMA_Shutdown()\n");

  for (i = 0; i < 2; i++)
    stop_ahi_sound (&ahi_channel_info[i]);
  if (ahidevice_is_open) {
    CloseDevice ((struct IORequest *)ahi_channel_info[0].AHIio);
    ahidevice_is_open = FALSE;
  }
  for (i = 0; i < 2; i++) {
    if (ahi_channel_info[i].AHIio != NULL) {
      DeleteIORequest ((struct IORequest *)ahi_channel_info[i].AHIio);
      ahi_channel_info[i].AHIio = NULL;
    }
  }
  if (AHImp != NULL) {
    DeleteMsgPort (AHImp);
    AHImp = NULL;
  }
  if (audio_is_open) {
    if (shm != NULL) {
      for (i = 0; i < shm->channels; i++)
        stopsound (i);
      audio_io->ioa_Request.io_Unit = (struct Unit *)
                       ((1 << shm->channels) - 1);  /* free shm->channels channels */
    }
    CloseDevice ((struct IORequest *)audio_io);
    audio_is_open = FALSE;
  }
  for (i = 0; i < MAXNUMCHANNELS; i++) {
    if (channel_info[i].audio_io != NULL) {
      FreeMem (channel_info[i].audio_io, sizeof(struct IOAudio));
      channel_info[i].audio_io = NULL;
    }
    if (channel_info[i].audio_mp != NULL) {
      DeleteMsgPort (channel_info[i].audio_mp);
      channel_info[i].audio_mp = NULL;
    }
  }
  if (audio_io != NULL) {
    FreeMem (audio_io, sizeof(struct IOAudio));
    audio_io = NULL;
  }
  if (audio_mp != NULL) {
    DeleteMsgPort (audio_mp);
    audio_mp = NULL;
  }
  if (shm != NULL) {
    if (shm->buffer != NULL) {
      if (using_ahi)
//#if defined(__SASC) && defined(__PPC__)
//        PPCFreeMem (shm->buffer, AHIBUFFERSIZE);
//#else
        free (shm->buffer);
//#endif
      else
        FreeMem (shm->buffer, BUFFERSIZE);
      shm->buffer = NULL;
    }
    free ((char *)shm);
    shm = NULL;
  }
}

/**********************************************************************/
void SNDDMA_Submit (void)
{
//  printf ("SNDDMA_Submit()\n");
}

/**********************************************************************/

#ifdef __SASC
void _STD_SNDDMA_Shutdown (void)
{
//  printf ("_STD_SNDDMA_Shutdown()\n");

  SNDDMA_Shutdown ();
}
#endif

/**********************************************************************/
#ifdef __STORM__
void EXIT_9_SNDDMA_Shutdown (void)
{
//  printf ("EXIT_9_SNDDMA_Shutdown()\n");

  SNDDMA_Shutdown ();
}
#endif

/**********************************************************************/
#ifdef __VBCC__
void _EXIT_9_SNDDMA_Shutdown (void)
{
//  printf ("_EXIT_9_SNDDMA_Shutdown()\n");

  SNDDMA_Shutdown ();
}
#endif

/**********************************************************************/
