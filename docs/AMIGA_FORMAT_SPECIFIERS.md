# AmigaOS RawDoFmt Format Specifiers

Based on exec.library/RawDoFmt documentation for AmigaOS

## Key Difference from Standard C

**CRITICAL**: On AmigaOS, format specifiers default to 16-bit (WORD) values, NOT 32-bit!

## Format Specifier Rules

### Integer Types
- `%d` - 16-bit signed decimal (WORD/short) - **DO NOT use for C int!**
- `%ld` - 32-bit signed decimal (LONG/int) - **USE THIS for C int variables**
- `%u` - 16-bit unsigned decimal (WORD)
- `%lu` - 32-bit unsigned decimal (LONG)
- `%x` - 16-bit hexadecimal (WORD)
- `%lx` - 32-bit hexadecimal (LONG)

### Other Types
- `%c` - 16-bit character (WORD)
- `%lc` - 32-bit character (LONG)
- `%s` - String pointer (32-bit)
- `%b` - BSTR (32-bit BPTR to byte count + string)

### Flags and Width
- `-` - Left justify
- `0` - Zero padding
- `width` - Minimum field width
- `.limit` - Maximum characters (strings only)

## Usage for C Programming

Since C compilers default to 32-bit `int` for varargs functions:

```c
int count = 5;
char name[256];

// WRONG - treats int as 16-bit, reads garbage
sprintf(name, "pak%d.pak", count);

// CORRECT - treats int as 32-bit
sprintf(name, "pak%ld.pak", count);
```

## Quick Reference

| C Type | Format | Notes |
|--------|--------|-------|
| `short` | `%d` | 16-bit signed |
| `int` | `%ld` | 32-bit signed |
| `long` | `%ld` | 32-bit signed |
| `unsigned short` | `%u` | 16-bit unsigned |
| `unsigned int` | `%lu` | 32-bit unsigned |
| `unsigned long` | `%lu` | 32-bit unsigned |
| `char` | `%c` | Use for single chars |
| `char *` | `%s` | Null-terminated string |
| `void *` | `%lx` | Display as hex address |

## Common Mistakes to Fix

1. `sprintf(buf, "%d", intVar)` → `sprintf(buf, "%ld", intVar)`
2. `sprintf(buf, "%x", intVar)` → `sprintf(buf, "%lx", intVar)`
3. `sprintf(buf, "entity %d", num)` → `sprintf(buf, "entity %ld", num)`

## Reference
- http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node036C.html
- https://d0.se/autodocs/exec.library/RawDoFmt
