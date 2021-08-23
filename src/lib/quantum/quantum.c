#include <stdint.h>
#include "quantum.h"
#include "trivia/util.h"
#include <stdio.h>

uint64_t quantum_max = 1000000000;
uint64_t current_quantum_num = 0;

void
quantum_add(uint64_t n)
{
	current_quantum_num += n;
	if (unlikely(quantum_max <= current_quantum_num)) {
		printf("QUANTUM LIMIT REACHED\n");
		abort();
	}
}

void
quantum_print()
{
	printf("quantum: %llu\n", current_quantum_num);
}