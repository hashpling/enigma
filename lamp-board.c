/* (c) 2015 Charles Bailey */

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/select.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>

int main(void) {
	int r, m = -1;
	unsigned u;
	int lamps[26];
	char fname[13];
	fd_set empty, reads;
	struct timeval tv;
	const struct timeval hour = {3600, 0};

	for (u = 0; u < sizeof lamps / sizeof *lamps; u++) {
		sprintf(fname, "lamp%c", 'A' + u);
		lamps[u] = open(fname, O_RDONLY);
		if (lamps[u] > m)
			m = lamps[u];
	}

	FD_ZERO(&empty);

	for (;;) {
		FD_ZERO(&reads);
		for (u = 0; u < sizeof lamps / sizeof *lamps; u++) {
			if (lamps[u] != -1) {
				FD_SET(lamps[u], &reads);
			}
		}
		tv = hour;
		r = select(m + 1, &reads, &empty, &empty, &tv);
		if (r > 0) {
			for (u = 0; u < sizeof lamps / sizeof *lamps; u++) {
				if (FD_ISSET(lamps[u], &reads)) {
					r = read(lamps[u], fname, sizeof(fname));
					if (r == 0) {
						close(lamps[u]);
						sprintf(fname, "lamp%c", 'A' + u);
						lamps[u] = open(fname, O_RDONLY);
					} else {
						putchar('A' + u);
					}
				}
			}
			fflush(stdout);
		}
	}
	/* wot, no close()? */
}
