# Makefile for AmiQuake - GCC m68k-amigaos build
# Based on awinquake 0.9 source
# Target: 68060 with FPU

# Toolchain
CC = m68k-amigaos-gcc
AS = vasmm68k_mot
AR = m68k-amigaos-ar
RANLIB = m68k-amigaos-ranlib

# NDK includes (can be overridden)
NDK_INC ?= /opt/amiga/m68k-amigaos/ndk-include

# Compiler flags
ARCH_FLAGS = -m68040 -m68881
OPT_FLAGS = -O1 -fno-strict-aliasing
# NOTE: Using -O1 globally due to GCC optimizer bugs (culling, FP math)
# NOTE: cvar.c contains workaround for AmigaOS sprintf lacking %f support
WARN_FLAGS = -Wall -Wno-unused
DEFINES = -DAMIGA -DFALSE=0 -DTRUE=1
# Note: id68k=1 not defined - using C implementations instead of SAS/C assembly
# Note: Defining FALSE/TRUE as this GCC SDK doesn't provide them
INCLUDES = -I. -Isrc -ICDPlayerSDK

CFLAGS = $(ARCH_FLAGS) $(OPT_FLAGS) $(WARN_FLAGS) $(DEFINES) $(INCLUDES)

# Linker flags
LDFLAGS = $(ARCH_FLAGS) -s
LIBS = -lm -lamiga

# Source directory
SRCDIR = src

# Output
TARGET = build/AmiQuakeGCC
OBJDIR = obj

# Source files (from OBJSGCC in smakefile)
# Note: amiga_stubs.c provides stub implementations for assembly functions (timer, unlink)
# Note: C2P functions provided by c2p8_040_amlaukka.s
SRCS = \
	amiga_stubs.c \
	cd_amiga.c \
	chase.c \
	cl_demo.c \
	cl_input.c \
	cl_main.c \
	cl_parse.c \
	cl_tent.c \
	cmd.c \
	common.c \
	console.c \
	crc.c \
	cvar.c \
	d_edge.c \
	d_fill.c \
	d_init.c \
	d_modech.c \
	d_part.c \
	d_polyse.c \
	d_scan.c \
	d_sky.c \
	d_sprite.c \
	d_surf.c \
	d_vars.c \
	d_zpoint.c \
	draw.c \
	host.c \
	host_cmd.c \
	in_amiga.c \
	keys.c \
	mathlib.c \
	menu.c \
	model.c \
	net_dgrm.c \
	net_loop.c \
	net_main.c \
	net_bsd.c \
	net_amigaudp.c \
	net_vcr.c \
	nonintel.c \
	pr_cmds.c \
	pr_edict.c \
	pr_exec.c \
	r_aclip.c \
	r_alias.c \
	r_bsp.c \
	r_draw.c \
	r_edge.c \
	r_efrag.c \
	r_light.c \
	r_main.c \
	r_misc.c \
	r_part.c \
	r_sky.c \
	r_sprite.c \
	r_surf.c \
	r_vars.c \
	sbar.c \
	screen.c \
	snd_dma.c \
	snd_mem.c \
	snd_mix.c \
	snd_amiga.c \
	sv_main.c \
	sv_move.c \
	sv_phys.c \
	sv_user.c \
	sys_amiga.c \
	sys_file_amiga.c \
	vid_amiga.c \
	view.c \
	wad.c \
	world.c \
	zone.c

# Assembly source files
# Using NovaCoder's optimized C2P extracted from AmiQuake v1.36 binary
ASMSRCS = \
	c2p8.s

# Generate object file lists
OBJS = $(SRCS:%.c=$(OBJDIR)/%.o)
ASMOBJS = $(ASMSRCS:%.s=$(OBJDIR)/%.o)
ALLOBJS = $(OBJS) $(ASMOBJS)

# Default target - build both versions
.PHONY: all fpu nofpu
all: fpu nofpu

# FPU target (68040 with FPU)
fpu: ARCH_FLAGS = -m68040 -m68881
fpu: TARGET = build/AmiQuakeGCC
fpu: OBJDIR = obj
fpu: LDFLAGS = -m68040 -m68881 -s
fpu: $(TARGET)

# NOFPU target (soft-float for 68020+ without FPU)
nofpu:
	@$(MAKE) build/AmiQuakeGCC-NoFPU ARCH_FLAGS="-m68020 -msoft-float" TARGET="build/AmiQuakeGCC-NoFPU" OBJDIR="obj-nofpu" LDFLAGS="-m68020 -msoft-float -s"

# Create directories
$(OBJDIR):
	@mkdir -p $(OBJDIR)

# Link
$(TARGET): $(OBJDIR) $(ALLOBJS)
	@mkdir -p build
	$(CC) $(LDFLAGS) -o $(TARGET) $(ALLOBJS) $(LIBS)
	@echo "Build complete: $(TARGET)"

# Compile C files
$(OBJDIR)/%.o: $(SRCDIR)/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

# Assemble .s files (using 68040 for C2P compatibility)
$(OBJDIR)/%.o: $(SRCDIR)/%.s
	$(AS) -Fhunk -m68040 -quiet -I$(NDK_INC) -I$(NDK_INC)/lvo -o $@ $<

# Special rule for net_amigaudp.c (needs additional include path)
$(OBJDIR)/net_amigaudp.o: $(SRCDIR)/net_amigaudp.c
	$(CC) $(CFLAGS) -c -o $@ $<

# mathlib.c uses default -O1 flags (no special rule needed)

# Clean
clean:
	rm -rf obj obj-nofpu
	rm -f build/AmiQuakeGCC build/AmiQuakeGCC-NoFPU

# Rebuild
rebuild: clean all

# Show configuration
config:
	@echo "Compiler: $(CC)"
	@$(CC) --version
	@echo ""
	@echo "Flags: $(CFLAGS)"
	@echo "Source files: $(words $(SRCS))"
	@echo "Object files: $(words $(OBJS))"

.PHONY: all clean rebuild config
