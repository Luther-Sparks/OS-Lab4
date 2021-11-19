/* See COPYRIGHT for copyright information. */

#ifndef JOS_KERN_SCHED_H
#define JOS_KERN_SCHED_H
#ifndef JOS_KERNEL
# error "This is a JOS kernel header; user programs should not #include it"
#endif
#include <kern/env.h>

// This function does not return.
void sched_yield(void) __attribute__((noreturn));

// the node of the queue to implement MLFQ algorithm
typedef struct Node {
    struct Env* env;                // this environment
    struct Node* next;                     // next Node in the queue
} Node;

// feedback queue
// its node stores the information about the environment's priority information
typedef struct Queue {
    Node* front;                    // front Node
    Node* rear;                     // rear Node
    int length;                     // length of the queue
}Queue;

extern struct Node nodepool[NENV];
extern struct Queue FBQueue[4];


#define SLICE(priority) (0x1 << (priority)) 
int remove_by_env(struct Queue* queue, struct Env* env);
struct Queue* push(struct Queue* queue, struct Node* node);
struct Queue* pop(struct Queue* queue);

#endif	// !JOS_KERN_SCHED_H
