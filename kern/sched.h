/* See COPYRIGHT for copyright information. */
/** 
 * 
 * @author 黄绵秋 19307130142
 * @date 2021/11/21
 * @brief 本次实验任务六部分实现代码解析
 * 核心是维护每个进程运行的时间片和优先级，因而在 struct Env 中添加属性 当前优先级已用 timeslice 和 优先级 priority
 * 同时为了实现每20个时间片，而维护了一个全局变量totalslice
 * 同时设计了一个以链表为基础的数据结构，鉴于没有 malloc 函数，创建了一个结点池 nodepool[NENV] 作为结点的存储空间，每个环境在结点池中分配一个结点，下标为其在envs中的对应下标 
 * 由此创建了四个链表队列，命名为 MFQueue [数组类型] 分别对应4种不同的优先级
 * MFQueue数据结构在 env_init() 函数中初始化
 * 每收到一个 IRQ_TIMER(时间片中断) 则更新 totalslice，如果totalslice == 20，则从高优先级到低优先级遍历所有 env ，
 *    将他们的 priority 置0并将其 timeslice 置0，并添加到第0级队列MFQueue[0](最高优先级)，同时将totalslice置0
 * 每次调用 env_run 表明有一个进程运行，则更新当前进程的 timeslice，如果 timeslice == 其所在队列的最大时间片，则将其从队列中移除，并将其优先级降低一级
 * 每个进程的创建 env_alloc() 过程和销毁 env_free() 过程也会对其进行处理
 * 创建时会将其优先级置为0(最高优先级)，并将其 timeslice 置0，并添加到第0级队列MFQueue[0]
 * 销毁时会从该进程所在的队列中删除该结点
 * 具体的改动可以查看diff.diff文件（依据git diff命令生成的）
 * 
 **/

#ifndef JOS_KERN_SCHED_H
#define JOS_KERN_SCHED_H
#ifndef JOS_KERNEL
# error "This is a JOS kernel header; user programs should not #include it"
#endif

// This function does not return.
void sched_yield(void) __attribute__((noreturn));

#endif	// !JOS_KERN_SCHED_H
