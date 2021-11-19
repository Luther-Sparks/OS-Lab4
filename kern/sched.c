#include <inc/assert.h>
#include <inc/x86.h>
#include <kern/spinlock.h>
#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/monitor.h>
#include <kern/sched.h>

void sched_halt(void);

struct Node nodepool[NENV];
struct Queue FBQueue[4];
int timeslice_counter = 0;

// push a node to the back of the queue
struct Queue* push(struct Queue* queue, struct Node* node) {
	if (queue->rear == NULL) {
		queue->front = node;
		queue->rear = node;
	}
	else {
		node->next = NULL;
		queue->rear = node;
	}
	return queue;
}

// pop a node from the front of the queue
struct Queue* pop(struct Queue* queue) {
	if (queue->front == NULL) {
		return queue;
	}
	else {
		Node* temp = queue->front;
		queue->front = queue->front->next;
		temp->next = NULL;
	}
	return queue;
}

// remove a node which environment equals env from the queue
int remove_by_env(struct Queue* queue, struct Env* env) {
	Node* cur = queue->front;
	if (cur->env->env_id == env->env_id) {
		queue->front = queue->front->next;
		cur->next = NULL;
		return 1;
	}
	else {
		Node* prev = cur;
		cur = cur->next;
		while (cur != NULL) {
			if (cur->env->env_id == env->env_id) {
				prev->next = cur->next;
				cur->next = NULL;
				return 1;
			}
			prev = cur;
			cur = cur->next;
		}
		return 0;
	}
}

// check if the queue is empty
inline int emptyQueue(struct Queue* queue) {
	return queue->front == NULL;
}

// Choose a user environment to run and run it.
void sched_yield(void)
{
	// struct Env *idle;
	

	// Implement simple round-robin scheduling.
	//
	// Search through 'envs' for an ENV_RUNNABLE environment in
	// circular fashion starting just after the env this CPU was
	// last running.  Switch to the first such environment found.
	//
	// If no envs are runnable, but the environment previously
	// running on this CPU is still ENV_RUNNING, it's okay to
	// choose that environment.
	//
	// Never choose an environment that's currently running on
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	for (int i = 0; i < 4; i++) {
		if (!emptyQueue(&FBQueue[i])) {
			Node* cur = FBQueue[i].front;
			while (cur != NULL) {
				if (cur->env->env_status == ENV_RUNNABLE) {
					env_run(cur->env);
				}
				if (cur->env->env_id == curenv->env_id) {		
					// 由于设计会使当前运行的环境被放在队列的最后，这种情况表明该队列中已没有其他可以运行的环境
					if (curenv && curenv->env_status == ENV_RUNNING) {
						env_run(curenv);
					}
				}
				cur = cur->next;
			}
		}
	}
	sched_halt();

	// LAB 4: Your code here.
	
	// 首先考察最高优先级

/*
	int start = 0;
	int j;

	if (curenv)
	{
		start = ENVX(curenv->env_id) + 1; 
	}
	for (int i = 0; i < NENV ; i++)
	{
		j = (start + i) % NENV;
		if (envs[j].env_status == ENV_RUNNABLE )
		{
			env_run(&envs[j]);
		}
	}
	if (curenv && curenv->env_status == ENV_RUNNING)
	{
		env_run(curenv);
	}
	sched_halt();
*/
}

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void sched_halt(void)
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++)
	{
		if ((envs[i].env_status == ENV_RUNNABLE ||
			 envs[i].env_status == ENV_RUNNING ||
			 envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV)
	{
		cprintf("No runnable environments in the system!\n");
		while (1)
			monitor(NULL);
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
	lcr3(PADDR(kern_pgdir));

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile(
		"movl $0, %%ebp\n"
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
		:
		: "a"(thiscpu->cpu_ts.ts_esp0));
}
