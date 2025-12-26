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
// in_null.c -- for systems without a mouse

#include "quakedef.h"

#include <exec/exec.h>
#include <libraries/lowlevel.h>
#if defined(__STORM__) || defined(__VBCC__)
#include <clib/exec_protos.h>
#include <clib/lowlevel_protos.h>
#else
#include <proto/exec.h>
#include <proto/lowlevel.h>
#endif

struct Library *LowLevelBase = NULL;

cvar_t m_filter = {"m_filter", "1"};

qboolean using_mouse = false;
qboolean mouse_has_moved = false;
qboolean using_joypad = false;
short int last_mouse[2] = {0, 0};

/**********************************************************************/
static void Init_Joypad (void)
{
  LowLevelBase = OpenLibrary ("lowlevel.library", 0);
  if (LowLevelBase != NULL) {
    Con_Printf ("Joypad enabled\n");
    using_joypad = true;
  } else {
    Con_Printf ("Can't open lowlevel.libary\n");
    using_joypad = false;
  }
}

/**********************************************************************/
void IN_Init (void)
{
  using_mouse = COM_CheckParm("-mouse");
  if (using_mouse)
    Cvar_RegisterVariable (&m_filter);

  using_joypad = COM_CheckParm ("-joypad");
  if (using_joypad)
    Init_Joypad ();
}

/**********************************************************************/
void IN_Shutdown (void)
{
  if (LowLevelBase != NULL) {
    CloseLibrary (LowLevelBase);
    LowLevelBase = NULL;
  }
}

/**********************************************************************/
static void Read_Joypad (void)
{
  ULONG joypos;

  joypos = ReadJoyPort (1);

  if (joypos & JPF_JOY_LEFT)
    Key_Event (K_AUX1, true);
  else
    Key_Event (K_AUX1, false);

  if (joypos & JPF_JOY_RIGHT)
    Key_Event (K_AUX2, true);
  else
    Key_Event (K_AUX2, false);

  if (joypos & JPF_JOY_UP)
    Key_Event (K_AUX3, true);
  else
    Key_Event (K_AUX3, false);

  if (joypos & JPF_JOY_DOWN)
    Key_Event (K_AUX4, true);
  else
    Key_Event (K_AUX4, false);

  if (joypos & JPF_BUTTON_RED)
    Key_Event (K_AUX5, true);
  else
    Key_Event (K_AUX5, false);

  if (joypos & JPF_BUTTON_GREEN)
    Key_Event (K_AUX6, true);
  else
    Key_Event (K_AUX6, false);

  if (joypos & JPF_BUTTON_YELLOW)
    Key_Event (K_AUX7, true);
  else
    Key_Event (K_AUX7, false);

  if (joypos & JPF_BUTTON_BLUE)
    Key_Event (K_AUX8, true);
  else
    Key_Event (K_AUX8, false);

  if (joypos & JPF_BUTTON_PLAY)
    Key_Event (K_AUX9, true);
  else
    Key_Event (K_AUX9, false);

  if (joypos & JPF_BUTTON_FORWARD)
    Key_Event (K_AUX10, true);
  else
    Key_Event (K_AUX10, false);

  if (joypos & JPF_BUTTON_REVERSE)
    Key_Event (K_AUX11 ,true);
  else
    Key_Event (K_AUX11, false);
}

/**********************************************************************/
void IN_Commands (void)
{
  if (using_joypad)
    Read_Joypad ();
}

/**********************************************************************/
void IN_Move (usercmd_t *cmd)
{
  short int mx, my;
  double mouse_x, mouse_y;
  static int old_mouse_x = 0, old_mouse_y = 0;

  if (!mouse_has_moved)
    return;
  mouse_has_moved = false;

  mx = (last_mouse[0] >> 1) << 3;
  my = (last_mouse[1] >> 1) << 3;

  if (m_filter.value) {
    mouse_x = 0.5 * (mx + old_mouse_x);
    mouse_y = 0.5 * (my + old_mouse_y);
  } else {
    mouse_x = (double)mx;
    mouse_y = (double)my;
  }
  old_mouse_x = mx;
  old_mouse_y = my;

  mouse_x *= sensitivity.value;
  mouse_y *= sensitivity.value;

  /* add mouse X/Y movement to cmd */
  if ((in_strafe.state & 1) || (lookstrafe.value && (in_mlook.state & 1)))
    cmd->sidemove += m_side.value * mouse_x;
  else
    cl.viewangles[YAW] -= m_yaw.value * mouse_x;

  if (in_mlook.state & 1)
    V_StopPitchDrift ();

  if ((in_mlook.state & 1) && !(in_strafe.state & 1)) {
    cl.viewangles[PITCH] += m_pitch.value * mouse_y;
    if (cl.viewangles[PITCH] > 80)
      cl.viewangles[PITCH] = 80;
    if (cl.viewangles[PITCH] < -70)
      cl.viewangles[PITCH] = -70;
  } else {
    if ((in_strafe.state & 1) && noclip_anglehack)
      cmd->upmove -= m_forward.value * mouse_y;
    else
      cmd->forwardmove -= m_forward.value * mouse_y;
  }
}

/**********************************************************************/
#ifdef __SASC
void _STD_IN_Shutdown (void)
{
//  printf ("_STD_IN_Shutdown\n");
  IN_Shutdown ();
}
#endif

/**********************************************************************/
#ifdef __STORM__
void EXIT_9_IN_Shutdown (void)
{
//  printf ("EXIT_9_IN_Shutdown\n");
  IN_Shutdown ();
}
#endif

/**********************************************************************/
#ifdef __VBCC__
void _EXIT_9_IN_Shutdown (void)
{
//  printf ("_EXIT_9_IN_Shutdown\n");
  IN_Shutdown ();
}
#endif

/**********************************************************************/
