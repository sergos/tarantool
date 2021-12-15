#include "fiber.h"

void
box_timeout_cb(int signum)
{
	(void)signum;
	fiber()->deadline_timeout = 0;
}

void
box_timeout_init(void)
{
	struct sigaction sa;
	memset(&sa, 0, sizeof(sa));
	sa.sa_handler = box_timeout_cb;
	/** Use SIGVTALRM for proof of concept. */
	sigaction(SIGVTALRM, &sa, NULL);
}
