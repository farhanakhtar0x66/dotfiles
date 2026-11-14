/*
 * rawmax — one-key display brightness modes (bound to alt-shift-b in AeroSpace).
 *
 *   rawmax [toggle]   flip between the two modes (default)
 *   rawmax max        "Surface of the Sun": 100% brightness + linear gamma table
 *   rawmax indoor     "Indoor human": standard ICC/ColorSync profile + 55% brightness
 *   rawmax status     print current brightness and mode
 *
 * Rebuilt from the original binary's behaviour: toggle goes to max when current
 * brightness is below 98%, otherwise back to indoor.
 *
 * Build:  clang -O2 -o ~/.local/bin/rawmax rawmax.c -framework CoreGraphics
 * DisplayServices is a private framework, so it is loaded at runtime with dlopen:
 * if a future macOS removes it, rawmax says so instead of failing to launch.
 */
#include <CoreGraphics/CoreGraphics.h>
#include <dlfcn.h>
#include <stdio.h>
#include <string.h>

#define INDOOR_LEVEL 0.55f
#define MAX_THRESHOLD 0.98f

typedef int (*get_fn)(CGDirectDisplayID, float *);
typedef int (*set_fn)(CGDirectDisplayID, float);

static void mode_max(CGDirectDisplayID d, set_fn set) {
    set(d, 1.0f);
    CGSetDisplayTransferByFormula(d, 0, 1, 1, 0, 1, 1, 0, 1, 1); /* identity LUT */
    printf("☀️ Mode: SURFACE OF THE SUN (100%% / 525 Nits + Linear LUT)\n");
}

static void mode_indoor(CGDirectDisplayID d, set_fn set) {
    CGDisplayRestoreColorSyncSettings();
    set(d, INDOOR_LEVEL);
    printf("🌙 Mode: INDOOR HUMAN (55%% + Standard ICC Profile)\n");
}

int main(int argc, char **argv) {
    void *h = dlopen("/System/Library/PrivateFrameworks/DisplayServices.framework/DisplayServices", RTLD_LAZY);
    get_fn get = h ? (get_fn)dlsym(h, "DisplayServicesGetBrightness") : NULL;
    set_fn set = h ? (set_fn)dlsym(h, "DisplayServicesSetBrightness") : NULL;
    if (!get || !set) { fprintf(stderr, "rawmax: DisplayServices unavailable on this macOS\n"); return 1; }

    CGDirectDisplayID d = CGMainDisplayID();
    float level = INDOOR_LEVEL;
    get(d, &level);
    const char *cmd = argc > 1 ? argv[1] : "toggle";

    if (!strcmp(cmd, "max"))         mode_max(d, set);
    else if (!strcmp(cmd, "indoor")) mode_indoor(d, set);
    else if (!strcmp(cmd, "toggle")) { if (level < MAX_THRESHOLD) mode_max(d, set); else mode_indoor(d, set); }
    else if (!strcmp(cmd, "status")) printf("brightness: %.0f%% (%s)\n", level * 100, level >= MAX_THRESHOLD ? "max" : "indoor/other");
    else { fprintf(stderr, "usage: rawmax [toggle|max|indoor|status]\n"); return 2; }
    return 0;
}
