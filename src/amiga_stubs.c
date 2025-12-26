// Stub implementations for Amiga-specific assembly functions
// These would normally be implemented in assembly for performance

#include <exec/types.h>
#include <graphics/gfx.h>

// Timer stubs
void timer(ULONG *clock) {
    // Stub: Would normally read hardware timer
    static ULONG counter = 0;
    *clock = counter++;
}

// C2P (Chunky to Planar) conversion functions are now provided by c2p8_040_amlaukka.s
// (removed stubs - using real assembly implementation)

// unlink stub (should be in libc but might be missing)
int unlink(const char *path) {
    // Stub: Would normally delete a file
    return -1;  // Indicate failure
}

// strnicmp - case-insensitive string compare (DOS/Windows name)
// GCC libc has strncasecmp instead
#include <string.h>
#include <ctype.h>

int strnicmp(const char *s1, const char *s2, size_t n) {
    // Use strncasecmp if available, otherwise implement it
    #ifdef __GNUC__
    return strncasecmp(s1, s2, n);
    #else
    // Fallback implementation
    while (n > 0) {
        int c1 = tolower((unsigned char)*s1);
        int c2 = tolower((unsigned char)*s2);
        if (c1 != c2) return c1 - c2;
        if (c1 == 0) return 0;
        s1++; s2++; n--;
    }
    return 0;
    #endif
}
