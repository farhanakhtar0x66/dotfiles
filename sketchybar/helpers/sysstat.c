/*
 * sysstat — CPU % and used RAM in one ~1ms process (replaces `ps -A` + `vm_stat` + awk).
 * Prints:  <cpu percent> <used GB>      e.g.  "12 9.6"
 * CPU is the busy share since the previous call (ticks kept in $TMPDIR/sysstat.ticks);
 * the very first call samples twice, 100ms apart. RAM = active + wired + compressed,
 * the same figure the bar showed before.
 * Build: clang -O2 -o ~/.local/bin/sysstat sysstat.c
 */
#include <mach/mach.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

static void ticks(natural_t t[4]) {
    host_cpu_load_info_data_t c;
    mach_msg_type_number_t n = HOST_CPU_LOAD_INFO_COUNT;
    host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, (host_info_t)&c, &n);
    t[0] = c.cpu_ticks[CPU_STATE_USER];
    t[1] = c.cpu_ticks[CPU_STATE_SYSTEM];
    t[2] = c.cpu_ticks[CPU_STATE_IDLE];
    t[3] = c.cpu_ticks[CPU_STATE_NICE];
}

int main(void) {
    const char *tmp = getenv("TMPDIR");
    char path[1024];
    snprintf(path, sizeof path, "%s/sysstat.ticks", tmp ? tmp : "/tmp");

    natural_t prev[4] = {0}, cur[4];
    int have_prev = 0;
    FILE *f = fopen(path, "r");
    if (f) {
        have_prev = fscanf(f, "%u %u %u %u", &prev[0], &prev[1], &prev[2], &prev[3]) == 4;
        fclose(f);
    }
    if (!have_prev) { ticks(prev); usleep(100000); }
    ticks(cur);
    if ((f = fopen(path, "w"))) {
        fprintf(f, "%u %u %u %u\n", cur[0], cur[1], cur[2], cur[3]);
        fclose(f);
    }

    double busy = (double)(natural_t)(cur[0] - prev[0]) + (natural_t)(cur[1] - prev[1]) + (natural_t)(cur[3] - prev[3]);
    double idle = (double)(natural_t)(cur[2] - prev[2]);
    double pct = (busy + idle) > 0 ? busy * 100.0 / (busy + idle) : 0;

    vm_statistics64_data_t v;
    mach_msg_type_number_t c = HOST_VM_INFO64_COUNT;
    host_statistics64(mach_host_self(), HOST_VM_INFO64, (host_info64_t)&v, &c);
    vm_size_t ps = 0;
    host_page_size(mach_host_self(), &ps);
    double gb = ((double)v.active_count + v.wire_count + v.compressor_page_count) * ps / 1073741824.0;

    printf("%d %.1f\n", (int)(pct + 0.5), gb);
    return 0;
}
