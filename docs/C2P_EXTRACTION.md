# NovaCoder C2P Extraction from AmiQuake v1.36 Binary

## Overview

This document describes the extraction of NovaCoder's optimized Chunky-to-Planar (C2P) conversion routine from the AmiQuake v1.36 binary. The C2P routine is critical for performance on Amiga AGA systems, converting linear chunky pixel data to Amiga's planar bitplane format.

## Extraction Process

### Discovery

The C2P code was embedded as data within the AmiQuake binary at file offset **0x069ae4**, not recognized as executable code by Ghidra.

**Method:**
1. Located stub functions that referenced the C2P code:
   - `c2p8_reloc_stub` at virtual address 0x0037520c
   - `c2p8_deinit_stub` at virtual address 0x003752ec
   - `c2p8_stub` wrapper at virtual address 0x00375300

2. Found that c2p8_reloc_stub allocates memory and copies C2P code
3. Searched binary for C2P signature patterns:
   - Heavy register usage: `movem.l d2-d7/a2-a6,-(sp)` (11 registers)
   - Distinctive constant masks for bit manipulation:
     - `$33333333` (858993459 decimal) - 8 occurrences
     - `$55555555` (1431655765 decimal) - 8 occurrences
     - `$0f0f0f0f` (252645135 decimal) - 8 occurrences
     - `$00ff00ff` (16711935 decimal) - 6 occurrences

4. Located code by searching for movem.l pattern at file offset 0x069ae4

### Extraction Details

**File Location:** `build/AmiQuake` offset 0x069ae4
**Size:** 852 bytes (0x354 hex)
**Output:** `src/c2p_novacoder.s`

## Code Structure

### Entry Point: _c2p8 / @c2p8

```
Entry: a0 = c2p structure pointer
       a1 = BitMap pointer
       a2 = chunky buffer pointer
       d0 = size (width * height)
```

The routine consists of:

1. **Wrapper (offsets 0x00-0x24):**
   - Parameter validation
   - Register preservation
   - Indirect call via function pointer in a0
   - Exit and cleanup

2. **Conversion Algorithm (offsets 0x26-0x356):**
   - Main C2P bit-shuffling loop
   - Processes 8 pixels (32 bytes) per iteration
   - Uses XOR-shift sequences for planar transformation
   - Self-modifying code with BPLSIZE offset placeholders

### Self-Modifying Code

The routine contains placeholder offsets marked as `PATCH:` comments:

```assembly
; PATCH: move.l d0,(BPLSIZE_OFFSET,a2)
```

These are patched at runtime by `c2p8_reloc` to use proper bitplane stride values.

## Algorithm Characteristics

### Optimization Techniques

1. **Register-intensive:** Uses all available data/address registers (d0-d7, a0-a6)
2. **Unrolled loops:** Main conversion unrolled for 8 pixels
3. **Bit manipulation:** XOR-based swapping avoids temporary storage
4. **Cache-friendly:** Processes data in aligned chunks

### Bit-Shuffling Pattern

The algorithm uses standard C2P bit-reorganization:
- 16-bit word swaps with XOR exchange
- 2-bit shuffling: `lsr.l #2` / `and.l #$33333333`
- 8-bit byte swaps: `lsr.l #8` / `and.l #$00ff00ff`
- 1-bit interleaving: `lsr.l #1` / `and.l #$55555555`
- 4-bit nibble swaps: `lsr.l #4` / `and.l #$0f0f0f0f`

## Integration

### Header File

The existing `src/amiga_c2p_aga.h` provides GCC inline assembly stubs:

**c2p8_stub()** - Main conversion call
**c2p8_reloc_stub()** - Relocate to fast RAM
**c2p8_deinit_stub()** - Cleanup

### Build Integration

**Makefile:** Assembles with vasm for m68040 target

```make
ASMSRCS = c2p_novacoder.s
```

**Assembly:** `vasmm68k_mot -Fhunk -m68040`

## Stub Functions

The extracted assembly includes placeholder stubs:

```assembly
_c2p8_reloc:
@c2p8_reloc:
    rts  ; TODO: Implement relocation logic

_c2p8_deinit:
@c2p8_deinit:
    rts  ; TODO: Implement cleanup logic
```

These need implementation based on the original stub code at:
- c2p8_reloc_stub: 0x0037520c
- c2p8_deinit_stub: 0x003752ec

## Build Verification

**Status:** ✅ Successfully builds and links
**Binary:** `build/AmiQuake_gcc` (3.7MB)
**Toolchain:** GCC 6.5.0b m68k-amigaos cross-compiler

## Performance Notes

This C2P implementation is optimized for:
- **Target CPU:** 68040/060
- **Graphics:** AGA 8-bit chunky mode
- **Optimization:** Speed over size (852 bytes)

## Files

- **Source:** `src/c2p_novacoder.s`
- **Header:** `src/amiga_c2p_aga.h` (existing, compatible)
- **Binary extraction:** `/tmp/c2p_extracted_full.bin` (852 bytes)
- **Disassembly:** `/tmp/c2p_disasm_complete.txt`

## References

- Original binary: `build/AmiQuake` (AmiQuake v1.36)
- Reference C2P: `~/git/amiga-c2p-template/src/c2p1x1_8_c5_gen.s`
- Ghidra analysis: Binary loaded and analyzed for function identification
