// Pull M29 (M42, exploratory, after the frozen run): print every cyclic component of the white-interval graph G_n.
// Reuses the frozen claudeM5_gap_audit.c unchanged (included, its main renamed). One line per component:
// "gap n comp size k: row row ...", rows in wheel order (A first), a trailing * marking a reset-free row.
// Usage: claudeM5_gap_dump NMIN NMAX
#define main audit_main
#include "claudeM5_gap_audit.c"
#undef main

int main(int argc, char **argv) {
    if (argc < 3) return 1;
    for (n = atoi(argv[1]); n <= atoi(argv[2]); n++) {
        N = 1u << (n - 3);
        rowmask = (1ULL << (n + 1)) - 1;
        u32 ncomp;
        uint8_t *self;
        int32_t *comp = tarjan(N, base_succ, NULL, &ncomp, &self);
        u32 *csize = calloc(ncomp, sizeof(u32));
        uint8_t *cself = calloc(ncomp, 1);
        for (u32 v = 0; v < N; v++) { csize[comp[v]]++; if (self[v]) cself[comp[v]] = 1; }
        for (u32 c = 0; c < ncomp; c++) {
            if (!(csize[c] > 1 || cself[c])) continue;
            printf("gap %d comp size %u:", n, csize[c]);
            for (u32 v = 0; v < N; v++) if (comp[v] == (int32_t)c) {
                U w = decode(v);
                putchar(' ');
                for (int i = 0; i <= n; i++) putchar(((w >> i) & 1) ? '1' : '0');
                if (reset_free(w)) putchar('*');
            }
            putchar('\n');
        }
        free(comp); free(self); free(csize); free(cself);
    }
    return 0;
}
