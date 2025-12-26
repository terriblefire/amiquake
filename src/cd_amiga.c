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
#include <exec/types.h>
#include <exec/memory.h>
#include <dos/dos.h>
#include <dos/dosextens.h>
#include <dos/filehandler.h>
#include <dos/rdargs.h>
#include <libraries/cdplayer.h>

#if defined(__VBCC__) || (defined(__STORM__) && defined(__PPC__))
#include <clib/cdplayer_protos.h>
#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#else
#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/cdplayer.h>
#ifdef __PPC__
#include <ppcpragmas/cdplayer_pragmas.h>
#endif
#endif

#include "quakedef.h"

struct Library	*CDPlayerBase = NULL;

static struct IOStdReq *CD_Request = NULL;
static struct MsgPort *CD_Port = NULL;
static struct CD_TOC table;
static BOOL cd_is_open = FALSE;
static BOOL cd_is_playing = FALSE;
static qboolean cd_is_looping = FALSE;
static byte cd_track;
static char scsi_device_name[36] = "";
static ULONG scsi_unit;
static float cdvolume;

/**********************************************************************/
static BOOL get_cd_dev_and_unit (char *volumename,
                                 char **devicename,
                                 ULONG *unit)
/* given a CD volume name, search the DosList for the associated device
   handler, then extract and return the low level scsi device driver name
   and unit */
{
  struct DosList *dl, *dl2;
  int len;
  struct InfoData *id;
  struct FileSysStartupMsg *fssm;
  static char device_name[60];

  if ((id = (struct InfoData *)AllocVec (sizeof(struct InfoData), MEMF_PUBLIC | MEMF_CLEAR)) == NULL) {
    Sys_Error ("AllocMem() failed\n");
    return FALSE;
  }
  if ((dl = LockDosList (LDF_DEVICES | LDF_READ)) == NULL) {
    FreeVec (id);
    Sys_Error ("LockDosList() failed\n");
    return FALSE;
  }
  while ((dl = NextDosEntry (dl, LDF_DEVICES)) != NULL) {
    if (dl->dol_Type == DLT_DEVICE &&
        dl->dol_Task != NULL &&
        DoPkt (dl->dol_Task, ACTION_DISK_INFO, MKBADDR(id), 0, 0, 0, 0) &&
        (dl2 = (struct DosList *)BADDR(id->id_VolumeNode)) != NULL &&
        dl2->dol_Type == DLT_VOLUME &&
        (len = ((char *)BADDR(dl2->dol_Name))[0]) == strlen(volumename) &&
        strnicmp (volumename, &((char *)BADDR(dl2->dol_Name))[1], len) == 0 &&
        (fssm = (struct FileSysStartupMsg *)
                         BADDR(dl->dol_misc.dol_handler.dol_Startup)) != NULL) {
      len = ((char *)BADDR(fssm->fssm_Device))[0];
      memcpy (device_name, &((char *)BADDR(fssm->fssm_Device))[1], len);
      device_name[len] = '\0';
      *devicename = device_name;
      *unit = fssm->fssm_Unit;
      UnLockDosList (LDF_DEVICES | LDF_READ);
      FreeVec (id);
      return TRUE;
    }
  }
  UnLockDosList (LDF_DEVICES | LDF_READ);
  FreeVec (id);
  return FALSE;
}

/**********************************************************************/
static int open_cdplayer (void)
{
  int result;

  if (CD_Request == NULL)
    return 1;
  if ((CDPlayerBase = OpenLibrary ("libs/" CDPLAYERNAME, CDPLAYERVERSION)) == NULL &&
      (CDPlayerBase = OpenLibrary (CDPLAYERNAME, CDPLAYERVERSION)) == NULL) {
    Con_Printf ("Can't open cdplayer.library, CD audio not available\n");
    return 1;
  }
  if ((result = OpenDevice (scsi_device_name, scsi_unit,
                            (struct IORequest *)CD_Request, 0)) == 0) {
    cd_is_open = TRUE;
  }
  return result;
}

/**********************************************************************/
static void close_cdplayer (void)
{
  if (cd_is_open) {
    CloseDevice ((struct IORequest *) CD_Request);
    cd_is_open = FALSE;
  }
  if (CDPlayerBase != NULL) {
    CloseLibrary (CDPlayerBase);
    CDPlayerBase = NULL;
  }
}

/**********************************************************************/
void CDAudio_Play (byte track, qboolean looping)
{
//  printf ("CDAudio_Play(%d,%d)\n", track, looping);
  CDAudio_Stop ();
  if (open_cdplayer () == 0) {
    cd_is_playing = (CDPlay (track, track, CD_Request) == 0);
    cd_track = track;
    cd_is_looping = looping;
    close_cdplayer ();
  }
}


/**********************************************************************/
void CDAudio_Stop (void)
{
//  printf ("CDAudio_Stop()\n");
  if (open_cdplayer () == 0) {
    CDStop (CD_Request);
    cd_is_playing = FALSE;
    cd_is_looping = FALSE;
    close_cdplayer ();
  }
}


/**********************************************************************/
void CDAudio_Pause (void)
{
//  printf ("CDAudio_Pause()\n");
  if (open_cdplayer () == 0) {
    CDResume (TRUE, CD_Request);
    close_cdplayer ();
  }
}


/**********************************************************************/
void CDAudio_Resume (void)
{
//  printf ("CDAudio_Resume()\n");
  if (open_cdplayer () == 0) {
    CDResume (FALSE, CD_Request);
    close_cdplayer ();
  }
}


/**********************************************************************/
/* This routine called once for every frame */
void CDAudio_Update (void)
{
  struct CD_Volume vol;
  struct CD_Time cd_time;
  static UWORD count = 64;

//  printf ("CDAudio_Update()\n");
  if (bgmvolume.value != cdvolume) {
//    printf ("bgmvolume.value = %6.2f\n", (double)bgmvolume.value);
    if (bgmvolume.value == 0.0 && cdvolume != 0.0)
      CDAudio_Pause ();
    else if (bgmvolume.value != 0.0 && cdvolume == 0.0)
      CDAudio_Resume ();
    cdvolume = bgmvolume.value;
    if (open_cdplayer () == 0) {
      vol.cdv_Chan0 = vol.cdv_Chan1 = (UBYTE)(cdvolume * 255.0);
      vol.cdv_Chan2 = vol.cdv_Chan3 = 0;
      CDSetVolume (&vol, CD_Request);
      close_cdplayer ();
    }
  }
  /* replay cd_track if cd_is_looping and we reach the end */
  if (--count == 0 && cd_is_playing && cd_is_looping) {
    if (open_cdplayer () == 0) {
      CDTitleTime (&cd_time, CD_Request);
//      printf ("%d %d %d %d %d %d\n", cd_time.cdt_TrackCurBase,
//              cd_time.cdt_TrackRemainBase, cd_time.cdt_TrackCompleteBase,
//              cd_time.cdt_AllCurBase, cd_time.cdt_AllRemainBase,
//              cd_time.cdt_AllCompleteBase);
      close_cdplayer ();
      if (cd_time.cdt_TrackRemainBase < 300)
        CDAudio_Play (cd_track, cd_is_looping);
    }
    count = 64;
  }
}


/**********************************************************************/
int CDAudio_Init (void)
{
  char *scsi_device_name2, *scsi_unit_name;

//  printf ("CDAudio_Init()\n");
  if (cls.state == ca_dedicated)
    return -1;

  if (COM_CheckParm("-nocdaudio"))
    return -1;

  if ((CD_Port = CreateMsgPort ()) == NULL) {
    Sys_Error ("CreateMsgPort() failed");
    return -1;
  }
  if ((CD_Request = (struct IOStdReq *)CreateIORequest (CD_Port,
                                           sizeof (struct IOStdReq))) == NULL) {
    Sys_Error ("CreateIORequest() failed");
    return -1;
  }
  if ((scsi_unit_name = getenv("quake/scsi_unit")) != NULL)
    scsi_unit = atoi(scsi_unit_name);
  if (scsi_unit_name == NULL ||
      (scsi_device_name2 = getenv("quake/scsi_device")) == NULL) {
    if (!get_cd_dev_and_unit ("QUAKE", &scsi_device_name2, &scsi_unit)) {
      Con_Printf ("Unable to determine SCSI device & Unit for CD audio\n");
      return -1;
    }
  }
  strncpy (scsi_device_name, scsi_device_name2, sizeof(scsi_device_name));
  if (open_cdplayer () != 0) {
    Con_Printf ("CdInit: Failed to open scsi device\n");
    return 1;
  }
  if (CDReadTOC (&table, CD_Request) != 0) {
    Sys_Error ("CdInit: CDReadTOC() failed");
    return -1;
  }
  close_cdplayer ();
  cdvolume = 1.0;
  CDAudio_Update ();
  return 0;
}


/**********************************************************************/
void CDAudio_Shutdown (void)
{
//  printf ("CDAudio_Shutdown()\n");
  CDAudio_Stop ();
  if (cd_is_open) {
    CloseDevice ((struct IORequest *) CD_Request);
    cd_is_open = FALSE;
  }
  if (CD_Request != NULL) {
    DeleteIORequest (CD_Request);
    CD_Request = NULL;
  }
  if (CD_Port != NULL) {
    DeleteMsgPort (CD_Port);
    CD_Port = NULL;
  }
  if (CDPlayerBase != NULL) {
    CloseLibrary (CDPlayerBase);
    CDPlayerBase = NULL;
  }
}

/**********************************************************************/

#ifdef __SASC
void _STD_CDAudio_Shutdown (void)
{
//  printf ("_STD_CDAudio_Shutdown()\n");

  CDAudio_Shutdown ();
}
#endif

/**********************************************************************/
#ifdef __STORM__
void EXIT_9_CDAudio_Shutdown (void)
{
//  printf ("EXIT_9_CDAudio_Shutdown()\n");

  CDAudio_Shutdown ();
}
#endif

/**********************************************************************/
#ifdef __VBCC__
void _EXIT_9_CDAudio_Shutdown (void)
{
//  printf ("_EXIT_9_CDAudio_Shutdown()\n");

  CDAudio_Shutdown ();
}
#endif

/**********************************************************************/
