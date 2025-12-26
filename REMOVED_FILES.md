# Removed Source Files

This document lists all source files removed from the `src/` directory during the GCC m68k port cleanup. These files were removed because they are not used in the current Amiga m68k-amigaos build.

**Total files removed:** 101
**Date:** 2025-12-26

## Categories

### Old C2P Implementations (3 files)

Replaced by NovaCoder's optimized C2P extracted from AmiQuake v1.36 binary:

- `c2p8_040_amlaukka.s` - amlaukka's C2P implementation (replaced by c2p_novacoder.s)
- `c2p1x1_8_c5_gen.s` - Reference C2P implementation from amiga-c2p-template
- `c2p_wrapper.c` - C wrapper for old C2P

### PowerPC Assembly Files (3 files)

Not used in 68k build:

- `amiga_ppc_c2p.s`
- `amiga_ppc_d_scan.s`
- `amiga_ppc_mathlib.s`

### Other Amiga Assembly Files (15 files)

Not used in current GCC build:

- `amiga_cgxtagfns.s`
- `amiga_d_68k.s`
- `amiga_d_polyse68k.s`
- `amiga_r_68k.s`
- `amiga_socket_lib.s`
- `amiga_timer.s`
- `d_copy.s`
- `d_draw.s`
- `d_draw16.s`
- `d_parta.s`
- `d_polysa.s`
- `d_scana.s`
- `d_spr8.s`
- `d_varsa.s`
- `math.s`
- `r_aclipa.s`
- `r_aliasa.s`
- `r_drawa.s`
- `r_edgea.s`
- `r_varsa.s`
- `snd_mixa.s`
- `surf16.s`
- `surf8.s`
- `worlda.s`

### DOS Platform Files (4 files)

- `dos_v2.c`
- `dosasm.s`
- `in_dos.c`
- `snd_dos.c`
- `sys_dos.c`
- `sys_dosa.s`
- `vid_dos.c`

### Windows Platform Files (9 files)

- `cd_win.c`
- `in_win.c`
- `net_win.c`
- `net_wins.c`
- `net_wipx.c`
- `net_wso.c`
- `snd_win.c`
- `sys_win.c`
- `sys_wina.s`
- `sys_wind.c`
- `vid_win.c`

### Linux Platform Files (5 files)

- `cd_linux.c`
- `gl_vidlinux.c`
- `gl_vidlinuxglx.c`
- `snd_linux.c`
- `sys_linux.c`
- `vid_svgalib.c`

### Sun/Unix Platform Files (5 files)

- `in_sun.c`
- `snd_sun.c`
- `sys_sun.c`
- `vid_sunx.c`
- `vid_sunxil.c`

### OpenGL Files (14 files)

Not used in software-rendered Amiga version:

- `gl_draw.c`
- `gl_mesh.c`
- `gl_model.c`
- `gl_refrag.c`
- `gl_rlight.c`
- `gl_rmain.c`
- `gl_rmisc.c`
- `gl_rsurf.c`
- `gl_screen.c`
- `gl_test.c`
- `gl_vidlinux.c`
- `gl_vidlinuxglx.c`
- `gl_vidnt.c`
- `gl_warp.c`

### Null/Stub Implementations (8 files)

- `cd_audio.c`
- `cd_null.c`
- `cd_stub.c`
- `cdplayer_protos_stub.c`
- `cybergraphics_protos_stub.c`
- `in_null.c`
- `lowlevel_protos_stub.c`
- `snd_null.c`
- `sys_null.c`
- `vid_null.c`
- `writechunkypixels_stub.c`

### Other Network Drivers (10 files)

Not used (Amiga uses `net_amigaudp.c` and `net_bsd.c`):

- `net_bw.c`
- `net_comx.c`
- `net_dos.c`
- `net_ipx.c`
- `net_mp.c`
- `net_none.c`
- `net_ser.c`
- `net_udp.c`
- `net_win.c`
- `net_wins.c`
- `net_wipx.c`
- `net_wso.c`

### Other Platform-Specific Files (6 files)

- `conproc.c` - Windows console
- `mplib.c` - Multiplayer library
- `mplpc.c` - Multiplayer LPC
- `r_misc1.c` - Alternate renderer implementation
- `r_misc2.c` - Alternate renderer implementation
- `snd_gus.c` - Gravis Ultrasound driver
- `snd_next.c` - NeXT sound driver
- `vid_ext.c` - Extended video driver
- `vid_vga.c` - VGA video driver
- `vid_x.c` - X11 video driver
- `vregset.c` - VGA register setting

## Files Retained (75 files)

### C Source Files (74 files)

All 74 C files listed in the Makefile `SRCS` variable are retained, including:
- Amiga-specific: `amiga_stubs.c`, `cd_amiga.c`, `in_amiga.c`, `net_amigaudp.c`, `snd_amiga.c`, `sys_amiga.c`, `sys_file_amiga.c`, `vid_amiga.c`
- Core engine files: `chase.c`, `cl_*.c`, `cmd.c`, `common.c`, `console.c`, etc.
- Rendering: `d_*.c`, `r_*.c`, `draw.c`, `view.c`, `screen.c`
- Game logic: `pr_*.c`, `sv_*.c`, `host*.c`, `world.c`, `zone.c`
- Network: `net_bsd.c`, `net_dgrm.c`, `net_loop.c`, `net_main.c`, `net_vcr.c`
- Sound: `snd_dma.c`, `snd_mem.c`, `snd_mix.c`
- Math: `mathlib.c`, `nonintel.c`
- Misc: `keys.c`, `menu.c`, `model.c`, `sbar.c`, `wad.c`

### Assembly Source Files (1 file)

- `c2p_novacoder.s` - NovaCoder's optimized C2P routine extracted from AmiQuake v1.36 binary (842 bytes of disassembled code + relocation wrapper)

## Build Status

After removal, the build remains functional:
- **Binary size:** 534KB (stripped)
- **Build status:** ✅ Successful
- **Target platform:** Amiga 68040/68060 with FPU
- **Toolchain:** GCC m68k-amigaos

## Notes

- All removed files are platform-specific code for DOS, Windows, Linux, Sun, and other non-Amiga platforms
- The PowerPC assembly files were for AmigaOS 4/PowerPC builds
- The old C2P implementations were replaced by NovaCoder's optimized version
- OpenGL files removed as AmiQuake uses software rendering
- Stub files and null implementations not needed for Amiga build
