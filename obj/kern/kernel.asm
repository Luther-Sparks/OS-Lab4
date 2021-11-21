
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 20 12 00       	mov    $0x122000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 20 12 f0       	mov    $0xf0122000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 62 00 00 00       	call   f01000a0 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	f3 0f 1e fb          	endbr32 
f0100044:	55                   	push   %ebp
f0100045:	89 e5                	mov    %esp,%ebp
f0100047:	56                   	push   %esi
f0100048:	53                   	push   %ebx
f0100049:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010004c:	83 3d b4 fe 23 f0 00 	cmpl   $0x0,0xf023feb4
f0100053:	74 0f                	je     f0100064 <_panic+0x24>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100055:	83 ec 0c             	sub    $0xc,%esp
f0100058:	6a 00                	push   $0x0
f010005a:	e8 b7 08 00 00       	call   f0100916 <monitor>
f010005f:	83 c4 10             	add    $0x10,%esp
f0100062:	eb f1                	jmp    f0100055 <_panic+0x15>
	panicstr = fmt;
f0100064:	89 35 b4 fe 23 f0    	mov    %esi,0xf023feb4
	asm volatile("cli; cld");
f010006a:	fa                   	cli    
f010006b:	fc                   	cld    
	va_start(ap, fmt);
f010006c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010006f:	e8 0e 61 00 00       	call   f0106182 <cpunum>
f0100074:	ff 75 0c             	pushl  0xc(%ebp)
f0100077:	ff 75 08             	pushl  0x8(%ebp)
f010007a:	50                   	push   %eax
f010007b:	68 00 68 10 f0       	push   $0xf0106800
f0100080:	e8 44 3a 00 00       	call   f0103ac9 <cprintf>
	vcprintf(fmt, ap);
f0100085:	83 c4 08             	add    $0x8,%esp
f0100088:	53                   	push   %ebx
f0100089:	56                   	push   %esi
f010008a:	e8 10 3a 00 00       	call   f0103a9f <vcprintf>
	cprintf("\n");
f010008f:	c7 04 24 00 7a 10 f0 	movl   $0xf0107a00,(%esp)
f0100096:	e8 2e 3a 00 00       	call   f0103ac9 <cprintf>
f010009b:	83 c4 10             	add    $0x10,%esp
f010009e:	eb b5                	jmp    f0100055 <_panic+0x15>

f01000a0 <i386_init>:
{
f01000a0:	f3 0f 1e fb          	endbr32 
f01000a4:	55                   	push   %ebp
f01000a5:	89 e5                	mov    %esp,%ebp
f01000a7:	53                   	push   %ebx
f01000a8:	83 ec 04             	sub    $0x4,%esp
	cons_init();
f01000ab:	e8 95 05 00 00       	call   f0100645 <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b0:	83 ec 08             	sub    $0x8,%esp
f01000b3:	68 ac 1a 00 00       	push   $0x1aac
f01000b8:	68 6c 68 10 f0       	push   $0xf010686c
f01000bd:	e8 07 3a 00 00       	call   f0103ac9 <cprintf>
	mem_init();
f01000c2:	e8 00 12 00 00       	call   f01012c7 <mem_init>
	env_init();
f01000c7:	e8 fa 2f 00 00       	call   f01030c6 <env_init>
	trap_init();
f01000cc:	e8 d3 3a 00 00       	call   f0103ba4 <trap_init>
	mp_init();	
f01000d1:	e8 ad 5d 00 00       	call   f0105e83 <mp_init>
	lapic_init();	
f01000d6:	e8 c1 60 00 00       	call   f010619c <lapic_init>
	pic_init();
f01000db:	e8 fe 38 00 00       	call   f01039de <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000e0:	c7 04 24 c0 43 12 f0 	movl   $0xf01243c0,(%esp)
f01000e7:	e8 1e 63 00 00       	call   f010640a <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000ec:	83 c4 10             	add    $0x10,%esp
f01000ef:	83 3d c0 1e 24 f0 07 	cmpl   $0x7,0xf0241ec0
f01000f6:	76 27                	jbe    f010011f <i386_init+0x7f>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01000f8:	83 ec 04             	sub    $0x4,%esp
f01000fb:	b8 e6 5d 10 f0       	mov    $0xf0105de6,%eax
f0100100:	2d 6c 5d 10 f0       	sub    $0xf0105d6c,%eax
f0100105:	50                   	push   %eax
f0100106:	68 6c 5d 10 f0       	push   $0xf0105d6c
f010010b:	68 00 70 00 f0       	push   $0xf0007000
f0100110:	e8 9a 5a 00 00       	call   f0105baf <memmove>
	for (c = cpus; c < cpus + ncpu; c++) {
f0100115:	83 c4 10             	add    $0x10,%esp
f0100118:	bb 20 20 24 f0       	mov    $0xf0242020,%ebx
f010011d:	eb 53                	jmp    f0100172 <i386_init+0xd2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010011f:	68 00 70 00 00       	push   $0x7000
f0100124:	68 24 68 10 f0       	push   $0xf0106824
f0100129:	6a 4c                	push   $0x4c
f010012b:	68 87 68 10 f0       	push   $0xf0106887
f0100130:	e8 0b ff ff ff       	call   f0100040 <_panic>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100135:	89 d8                	mov    %ebx,%eax
f0100137:	2d 20 20 24 f0       	sub    $0xf0242020,%eax
f010013c:	c1 f8 02             	sar    $0x2,%eax
f010013f:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100145:	c1 e0 0f             	shl    $0xf,%eax
f0100148:	8d 80 00 b0 24 f0    	lea    -0xfdb5000(%eax),%eax
f010014e:	a3 b8 fe 23 f0       	mov    %eax,0xf023feb8
		lapic_startap(c->cpu_id, PADDR(code));
f0100153:	83 ec 08             	sub    $0x8,%esp
f0100156:	68 00 70 00 00       	push   $0x7000
f010015b:	0f b6 03             	movzbl (%ebx),%eax
f010015e:	50                   	push   %eax
f010015f:	e8 92 61 00 00       	call   f01062f6 <lapic_startap>
		while(c->cpu_status != CPU_STARTED)
f0100164:	83 c4 10             	add    $0x10,%esp
f0100167:	8b 43 04             	mov    0x4(%ebx),%eax
f010016a:	83 f8 01             	cmp    $0x1,%eax
f010016d:	75 f8                	jne    f0100167 <i386_init+0xc7>
	for (c = cpus; c < cpus + ncpu; c++) {
f010016f:	83 c3 74             	add    $0x74,%ebx
f0100172:	6b 05 c4 23 24 f0 74 	imul   $0x74,0xf02423c4,%eax
f0100179:	05 20 20 24 f0       	add    $0xf0242020,%eax
f010017e:	39 c3                	cmp    %eax,%ebx
f0100180:	73 13                	jae    f0100195 <i386_init+0xf5>
		if (c == cpus + cpunum())  // We've started already.
f0100182:	e8 fb 5f 00 00       	call   f0106182 <cpunum>
f0100187:	6b c0 74             	imul   $0x74,%eax,%eax
f010018a:	05 20 20 24 f0       	add    $0xf0242020,%eax
f010018f:	39 c3                	cmp    %eax,%ebx
f0100191:	74 dc                	je     f010016f <i386_init+0xcf>
f0100193:	eb a0                	jmp    f0100135 <i386_init+0x95>
	ENV_CREATE(user_dumbfork, ENV_TYPE_USER);
f0100195:	83 ec 08             	sub    $0x8,%esp
f0100198:	6a 00                	push   $0x0
f010019a:	68 80 4e 1a f0       	push   $0xf01a4e80
f010019f:	e8 8f 32 00 00       	call   f0103433 <env_create>
	sched_yield();
f01001a4:	e8 92 47 00 00       	call   f010493b <sched_yield>

f01001a9 <mp_main>:
{
f01001a9:	f3 0f 1e fb          	endbr32 
f01001ad:	55                   	push   %ebp
f01001ae:	89 e5                	mov    %esp,%ebp
f01001b0:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f01001b3:	a1 c4 1e 24 f0       	mov    0xf0241ec4,%eax
	if ((uint32_t)kva < KERNBASE)
f01001b8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001bd:	76 52                	jbe    f0100211 <mp_main+0x68>
	return (physaddr_t)kva - KERNBASE;
f01001bf:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001c4:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001c7:	e8 b6 5f 00 00       	call   f0106182 <cpunum>
f01001cc:	83 ec 08             	sub    $0x8,%esp
f01001cf:	50                   	push   %eax
f01001d0:	68 93 68 10 f0       	push   $0xf0106893
f01001d5:	e8 ef 38 00 00       	call   f0103ac9 <cprintf>
	lapic_init();
f01001da:	e8 bd 5f 00 00       	call   f010619c <lapic_init>
	env_init_percpu();
f01001df:	e8 b2 2e 00 00       	call   f0103096 <env_init_percpu>
	trap_init_percpu();
f01001e4:	e8 f8 38 00 00       	call   f0103ae1 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01001e9:	e8 94 5f 00 00       	call   f0106182 <cpunum>
f01001ee:	6b d0 74             	imul   $0x74,%eax,%edx
f01001f1:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01001f4:	b8 01 00 00 00       	mov    $0x1,%eax
f01001f9:	f0 87 82 20 20 24 f0 	lock xchg %eax,-0xfdbdfe0(%edx)
f0100200:	c7 04 24 c0 43 12 f0 	movl   $0xf01243c0,(%esp)
f0100207:	e8 fe 61 00 00       	call   f010640a <spin_lock>
	sched_yield();
f010020c:	e8 2a 47 00 00       	call   f010493b <sched_yield>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100211:	50                   	push   %eax
f0100212:	68 48 68 10 f0       	push   $0xf0106848
f0100217:	6a 63                	push   $0x63
f0100219:	68 87 68 10 f0       	push   $0xf0106887
f010021e:	e8 1d fe ff ff       	call   f0100040 <_panic>

f0100223 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100223:	f3 0f 1e fb          	endbr32 
f0100227:	55                   	push   %ebp
f0100228:	89 e5                	mov    %esp,%ebp
f010022a:	53                   	push   %ebx
f010022b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010022e:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100231:	ff 75 0c             	pushl  0xc(%ebp)
f0100234:	ff 75 08             	pushl  0x8(%ebp)
f0100237:	68 a9 68 10 f0       	push   $0xf01068a9
f010023c:	e8 88 38 00 00       	call   f0103ac9 <cprintf>
	vcprintf(fmt, ap);
f0100241:	83 c4 08             	add    $0x8,%esp
f0100244:	53                   	push   %ebx
f0100245:	ff 75 10             	pushl  0x10(%ebp)
f0100248:	e8 52 38 00 00       	call   f0103a9f <vcprintf>
	cprintf("\n");
f010024d:	c7 04 24 00 7a 10 f0 	movl   $0xf0107a00,(%esp)
f0100254:	e8 70 38 00 00       	call   f0103ac9 <cprintf>
	va_end(ap);
}
f0100259:	83 c4 10             	add    $0x10,%esp
f010025c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010025f:	c9                   	leave  
f0100260:	c3                   	ret    

f0100261 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100261:	f3 0f 1e fb          	endbr32 
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100265:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010026a:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010026b:	a8 01                	test   $0x1,%al
f010026d:	74 0a                	je     f0100279 <serial_proc_data+0x18>
f010026f:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100274:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100275:	0f b6 c0             	movzbl %al,%eax
f0100278:	c3                   	ret    
		return -1;
f0100279:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f010027e:	c3                   	ret    

f010027f <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010027f:	55                   	push   %ebp
f0100280:	89 e5                	mov    %esp,%ebp
f0100282:	53                   	push   %ebx
f0100283:	83 ec 04             	sub    $0x4,%esp
f0100286:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100288:	ff d3                	call   *%ebx
f010028a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010028d:	74 29                	je     f01002b8 <cons_intr+0x39>
		if (c == 0)
f010028f:	85 c0                	test   %eax,%eax
f0100291:	74 f5                	je     f0100288 <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f0100293:	8b 0d 24 f2 23 f0    	mov    0xf023f224,%ecx
f0100299:	8d 51 01             	lea    0x1(%ecx),%edx
f010029c:	88 81 20 f0 23 f0    	mov    %al,-0xfdc0fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002a2:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f01002a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01002ad:	0f 44 d0             	cmove  %eax,%edx
f01002b0:	89 15 24 f2 23 f0    	mov    %edx,0xf023f224
f01002b6:	eb d0                	jmp    f0100288 <cons_intr+0x9>
	}
}
f01002b8:	83 c4 04             	add    $0x4,%esp
f01002bb:	5b                   	pop    %ebx
f01002bc:	5d                   	pop    %ebp
f01002bd:	c3                   	ret    

f01002be <kbd_proc_data>:
{
f01002be:	f3 0f 1e fb          	endbr32 
f01002c2:	55                   	push   %ebp
f01002c3:	89 e5                	mov    %esp,%ebp
f01002c5:	53                   	push   %ebx
f01002c6:	83 ec 04             	sub    $0x4,%esp
f01002c9:	ba 64 00 00 00       	mov    $0x64,%edx
f01002ce:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01002cf:	a8 01                	test   $0x1,%al
f01002d1:	0f 84 f2 00 00 00    	je     f01003c9 <kbd_proc_data+0x10b>
	if (stat & KBS_TERR)
f01002d7:	a8 20                	test   $0x20,%al
f01002d9:	0f 85 f1 00 00 00    	jne    f01003d0 <kbd_proc_data+0x112>
f01002df:	ba 60 00 00 00       	mov    $0x60,%edx
f01002e4:	ec                   	in     (%dx),%al
f01002e5:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f01002e7:	3c e0                	cmp    $0xe0,%al
f01002e9:	74 61                	je     f010034c <kbd_proc_data+0x8e>
	} else if (data & 0x80) {
f01002eb:	84 c0                	test   %al,%al
f01002ed:	78 70                	js     f010035f <kbd_proc_data+0xa1>
	} else if (shift & E0ESC) {
f01002ef:	8b 0d 00 f0 23 f0    	mov    0xf023f000,%ecx
f01002f5:	f6 c1 40             	test   $0x40,%cl
f01002f8:	74 0e                	je     f0100308 <kbd_proc_data+0x4a>
		data |= 0x80;
f01002fa:	83 c8 80             	or     $0xffffff80,%eax
f01002fd:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01002ff:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100302:	89 0d 00 f0 23 f0    	mov    %ecx,0xf023f000
	shift |= shiftcode[data];
f0100308:	0f b6 d2             	movzbl %dl,%edx
f010030b:	0f b6 82 20 6a 10 f0 	movzbl -0xfef95e0(%edx),%eax
f0100312:	0b 05 00 f0 23 f0    	or     0xf023f000,%eax
	shift ^= togglecode[data];
f0100318:	0f b6 8a 20 69 10 f0 	movzbl -0xfef96e0(%edx),%ecx
f010031f:	31 c8                	xor    %ecx,%eax
f0100321:	a3 00 f0 23 f0       	mov    %eax,0xf023f000
	c = charcode[shift & (CTL | SHIFT)][data];
f0100326:	89 c1                	mov    %eax,%ecx
f0100328:	83 e1 03             	and    $0x3,%ecx
f010032b:	8b 0c 8d 00 69 10 f0 	mov    -0xfef9700(,%ecx,4),%ecx
f0100332:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100336:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100339:	a8 08                	test   $0x8,%al
f010033b:	74 61                	je     f010039e <kbd_proc_data+0xe0>
		if ('a' <= c && c <= 'z')
f010033d:	89 da                	mov    %ebx,%edx
f010033f:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100342:	83 f9 19             	cmp    $0x19,%ecx
f0100345:	77 4b                	ja     f0100392 <kbd_proc_data+0xd4>
			c += 'A' - 'a';
f0100347:	83 eb 20             	sub    $0x20,%ebx
f010034a:	eb 0c                	jmp    f0100358 <kbd_proc_data+0x9a>
		shift |= E0ESC;
f010034c:	83 0d 00 f0 23 f0 40 	orl    $0x40,0xf023f000
		return 0;
f0100353:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100358:	89 d8                	mov    %ebx,%eax
f010035a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010035d:	c9                   	leave  
f010035e:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f010035f:	8b 0d 00 f0 23 f0    	mov    0xf023f000,%ecx
f0100365:	89 cb                	mov    %ecx,%ebx
f0100367:	83 e3 40             	and    $0x40,%ebx
f010036a:	83 e0 7f             	and    $0x7f,%eax
f010036d:	85 db                	test   %ebx,%ebx
f010036f:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100372:	0f b6 d2             	movzbl %dl,%edx
f0100375:	0f b6 82 20 6a 10 f0 	movzbl -0xfef95e0(%edx),%eax
f010037c:	83 c8 40             	or     $0x40,%eax
f010037f:	0f b6 c0             	movzbl %al,%eax
f0100382:	f7 d0                	not    %eax
f0100384:	21 c8                	and    %ecx,%eax
f0100386:	a3 00 f0 23 f0       	mov    %eax,0xf023f000
		return 0;
f010038b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100390:	eb c6                	jmp    f0100358 <kbd_proc_data+0x9a>
		else if ('A' <= c && c <= 'Z')
f0100392:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100395:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100398:	83 fa 1a             	cmp    $0x1a,%edx
f010039b:	0f 42 d9             	cmovb  %ecx,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010039e:	f7 d0                	not    %eax
f01003a0:	a8 06                	test   $0x6,%al
f01003a2:	75 b4                	jne    f0100358 <kbd_proc_data+0x9a>
f01003a4:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003aa:	75 ac                	jne    f0100358 <kbd_proc_data+0x9a>
		cprintf("Rebooting!\n");
f01003ac:	83 ec 0c             	sub    $0xc,%esp
f01003af:	68 c3 68 10 f0       	push   $0xf01068c3
f01003b4:	e8 10 37 00 00       	call   f0103ac9 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003b9:	b8 03 00 00 00       	mov    $0x3,%eax
f01003be:	ba 92 00 00 00       	mov    $0x92,%edx
f01003c3:	ee                   	out    %al,(%dx)
}
f01003c4:	83 c4 10             	add    $0x10,%esp
f01003c7:	eb 8f                	jmp    f0100358 <kbd_proc_data+0x9a>
		return -1;
f01003c9:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003ce:	eb 88                	jmp    f0100358 <kbd_proc_data+0x9a>
		return -1;
f01003d0:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003d5:	eb 81                	jmp    f0100358 <kbd_proc_data+0x9a>

f01003d7 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003d7:	55                   	push   %ebp
f01003d8:	89 e5                	mov    %esp,%ebp
f01003da:	57                   	push   %edi
f01003db:	56                   	push   %esi
f01003dc:	53                   	push   %ebx
f01003dd:	83 ec 1c             	sub    $0x1c,%esp
f01003e0:	89 c1                	mov    %eax,%ecx
	for (i = 0;
f01003e2:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003e7:	bf fd 03 00 00       	mov    $0x3fd,%edi
f01003ec:	bb 84 00 00 00       	mov    $0x84,%ebx
f01003f1:	89 fa                	mov    %edi,%edx
f01003f3:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003f4:	a8 20                	test   $0x20,%al
f01003f6:	75 13                	jne    f010040b <cons_putc+0x34>
f01003f8:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003fe:	7f 0b                	jg     f010040b <cons_putc+0x34>
f0100400:	89 da                	mov    %ebx,%edx
f0100402:	ec                   	in     (%dx),%al
f0100403:	ec                   	in     (%dx),%al
f0100404:	ec                   	in     (%dx),%al
f0100405:	ec                   	in     (%dx),%al
	     i++)
f0100406:	83 c6 01             	add    $0x1,%esi
f0100409:	eb e6                	jmp    f01003f1 <cons_putc+0x1a>
	outb(COM1 + COM_TX, c);
f010040b:	88 4d e7             	mov    %cl,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010040e:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100413:	89 c8                	mov    %ecx,%eax
f0100415:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100416:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010041b:	bf 79 03 00 00       	mov    $0x379,%edi
f0100420:	bb 84 00 00 00       	mov    $0x84,%ebx
f0100425:	89 fa                	mov    %edi,%edx
f0100427:	ec                   	in     (%dx),%al
f0100428:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010042e:	7f 0f                	jg     f010043f <cons_putc+0x68>
f0100430:	84 c0                	test   %al,%al
f0100432:	78 0b                	js     f010043f <cons_putc+0x68>
f0100434:	89 da                	mov    %ebx,%edx
f0100436:	ec                   	in     (%dx),%al
f0100437:	ec                   	in     (%dx),%al
f0100438:	ec                   	in     (%dx),%al
f0100439:	ec                   	in     (%dx),%al
f010043a:	83 c6 01             	add    $0x1,%esi
f010043d:	eb e6                	jmp    f0100425 <cons_putc+0x4e>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010043f:	ba 78 03 00 00       	mov    $0x378,%edx
f0100444:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100448:	ee                   	out    %al,(%dx)
f0100449:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010044e:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100453:	ee                   	out    %al,(%dx)
f0100454:	b8 08 00 00 00       	mov    $0x8,%eax
f0100459:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f010045a:	89 c8                	mov    %ecx,%eax
f010045c:	80 cc 07             	or     $0x7,%ah
f010045f:	f7 c1 00 ff ff ff    	test   $0xffffff00,%ecx
f0100465:	0f 44 c8             	cmove  %eax,%ecx
	switch (c & 0xff) {
f0100468:	0f b6 c1             	movzbl %cl,%eax
f010046b:	80 f9 0a             	cmp    $0xa,%cl
f010046e:	0f 84 dd 00 00 00    	je     f0100551 <cons_putc+0x17a>
f0100474:	83 f8 0a             	cmp    $0xa,%eax
f0100477:	7f 46                	jg     f01004bf <cons_putc+0xe8>
f0100479:	83 f8 08             	cmp    $0x8,%eax
f010047c:	0f 84 a7 00 00 00    	je     f0100529 <cons_putc+0x152>
f0100482:	83 f8 09             	cmp    $0x9,%eax
f0100485:	0f 85 d3 00 00 00    	jne    f010055e <cons_putc+0x187>
		cons_putc(' ');
f010048b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100490:	e8 42 ff ff ff       	call   f01003d7 <cons_putc>
		cons_putc(' ');
f0100495:	b8 20 00 00 00       	mov    $0x20,%eax
f010049a:	e8 38 ff ff ff       	call   f01003d7 <cons_putc>
		cons_putc(' ');
f010049f:	b8 20 00 00 00       	mov    $0x20,%eax
f01004a4:	e8 2e ff ff ff       	call   f01003d7 <cons_putc>
		cons_putc(' ');
f01004a9:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ae:	e8 24 ff ff ff       	call   f01003d7 <cons_putc>
		cons_putc(' ');
f01004b3:	b8 20 00 00 00       	mov    $0x20,%eax
f01004b8:	e8 1a ff ff ff       	call   f01003d7 <cons_putc>
		break;
f01004bd:	eb 25                	jmp    f01004e4 <cons_putc+0x10d>
	switch (c & 0xff) {
f01004bf:	83 f8 0d             	cmp    $0xd,%eax
f01004c2:	0f 85 96 00 00 00    	jne    f010055e <cons_putc+0x187>
		crt_pos -= (crt_pos % CRT_COLS);
f01004c8:	0f b7 05 28 f2 23 f0 	movzwl 0xf023f228,%eax
f01004cf:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004d5:	c1 e8 16             	shr    $0x16,%eax
f01004d8:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004db:	c1 e0 04             	shl    $0x4,%eax
f01004de:	66 a3 28 f2 23 f0    	mov    %ax,0xf023f228
	if (crt_pos >= CRT_SIZE) {
f01004e4:	66 81 3d 28 f2 23 f0 	cmpw   $0x7cf,0xf023f228
f01004eb:	cf 07 
f01004ed:	0f 87 8e 00 00 00    	ja     f0100581 <cons_putc+0x1aa>
	outb(addr_6845, 14);
f01004f3:	8b 0d 30 f2 23 f0    	mov    0xf023f230,%ecx
f01004f9:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004fe:	89 ca                	mov    %ecx,%edx
f0100500:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100501:	0f b7 1d 28 f2 23 f0 	movzwl 0xf023f228,%ebx
f0100508:	8d 71 01             	lea    0x1(%ecx),%esi
f010050b:	89 d8                	mov    %ebx,%eax
f010050d:	66 c1 e8 08          	shr    $0x8,%ax
f0100511:	89 f2                	mov    %esi,%edx
f0100513:	ee                   	out    %al,(%dx)
f0100514:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100519:	89 ca                	mov    %ecx,%edx
f010051b:	ee                   	out    %al,(%dx)
f010051c:	89 d8                	mov    %ebx,%eax
f010051e:	89 f2                	mov    %esi,%edx
f0100520:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100521:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100524:	5b                   	pop    %ebx
f0100525:	5e                   	pop    %esi
f0100526:	5f                   	pop    %edi
f0100527:	5d                   	pop    %ebp
f0100528:	c3                   	ret    
		if (crt_pos > 0) {
f0100529:	0f b7 05 28 f2 23 f0 	movzwl 0xf023f228,%eax
f0100530:	66 85 c0             	test   %ax,%ax
f0100533:	74 be                	je     f01004f3 <cons_putc+0x11c>
			crt_pos--;
f0100535:	83 e8 01             	sub    $0x1,%eax
f0100538:	66 a3 28 f2 23 f0    	mov    %ax,0xf023f228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010053e:	0f b7 d0             	movzwl %ax,%edx
f0100541:	b1 00                	mov    $0x0,%cl
f0100543:	83 c9 20             	or     $0x20,%ecx
f0100546:	a1 2c f2 23 f0       	mov    0xf023f22c,%eax
f010054b:	66 89 0c 50          	mov    %cx,(%eax,%edx,2)
f010054f:	eb 93                	jmp    f01004e4 <cons_putc+0x10d>
		crt_pos += CRT_COLS;
f0100551:	66 83 05 28 f2 23 f0 	addw   $0x50,0xf023f228
f0100558:	50 
f0100559:	e9 6a ff ff ff       	jmp    f01004c8 <cons_putc+0xf1>
		crt_buf[crt_pos++] = c;		/* write the character */
f010055e:	0f b7 05 28 f2 23 f0 	movzwl 0xf023f228,%eax
f0100565:	8d 50 01             	lea    0x1(%eax),%edx
f0100568:	66 89 15 28 f2 23 f0 	mov    %dx,0xf023f228
f010056f:	0f b7 c0             	movzwl %ax,%eax
f0100572:	8b 15 2c f2 23 f0    	mov    0xf023f22c,%edx
f0100578:	66 89 0c 42          	mov    %cx,(%edx,%eax,2)
		break;
f010057c:	e9 63 ff ff ff       	jmp    f01004e4 <cons_putc+0x10d>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100581:	a1 2c f2 23 f0       	mov    0xf023f22c,%eax
f0100586:	83 ec 04             	sub    $0x4,%esp
f0100589:	68 00 0f 00 00       	push   $0xf00
f010058e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100594:	52                   	push   %edx
f0100595:	50                   	push   %eax
f0100596:	e8 14 56 00 00       	call   f0105baf <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010059b:	8b 15 2c f2 23 f0    	mov    0xf023f22c,%edx
f01005a1:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01005a7:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01005ad:	83 c4 10             	add    $0x10,%esp
f01005b0:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01005b5:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005b8:	39 d0                	cmp    %edx,%eax
f01005ba:	75 f4                	jne    f01005b0 <cons_putc+0x1d9>
		crt_pos -= CRT_COLS;
f01005bc:	66 83 2d 28 f2 23 f0 	subw   $0x50,0xf023f228
f01005c3:	50 
f01005c4:	e9 2a ff ff ff       	jmp    f01004f3 <cons_putc+0x11c>

f01005c9 <serial_intr>:
{
f01005c9:	f3 0f 1e fb          	endbr32 
	if (serial_exists)
f01005cd:	80 3d 34 f2 23 f0 00 	cmpb   $0x0,0xf023f234
f01005d4:	75 01                	jne    f01005d7 <serial_intr+0xe>
f01005d6:	c3                   	ret    
{
f01005d7:	55                   	push   %ebp
f01005d8:	89 e5                	mov    %esp,%ebp
f01005da:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01005dd:	b8 61 02 10 f0       	mov    $0xf0100261,%eax
f01005e2:	e8 98 fc ff ff       	call   f010027f <cons_intr>
}
f01005e7:	c9                   	leave  
f01005e8:	c3                   	ret    

f01005e9 <kbd_intr>:
{
f01005e9:	f3 0f 1e fb          	endbr32 
f01005ed:	55                   	push   %ebp
f01005ee:	89 e5                	mov    %esp,%ebp
f01005f0:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005f3:	b8 be 02 10 f0       	mov    $0xf01002be,%eax
f01005f8:	e8 82 fc ff ff       	call   f010027f <cons_intr>
}
f01005fd:	c9                   	leave  
f01005fe:	c3                   	ret    

f01005ff <cons_getc>:
{
f01005ff:	f3 0f 1e fb          	endbr32 
f0100603:	55                   	push   %ebp
f0100604:	89 e5                	mov    %esp,%ebp
f0100606:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f0100609:	e8 bb ff ff ff       	call   f01005c9 <serial_intr>
	kbd_intr();
f010060e:	e8 d6 ff ff ff       	call   f01005e9 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100613:	a1 20 f2 23 f0       	mov    0xf023f220,%eax
	return 0;
f0100618:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f010061d:	3b 05 24 f2 23 f0    	cmp    0xf023f224,%eax
f0100623:	74 1c                	je     f0100641 <cons_getc+0x42>
		c = cons.buf[cons.rpos++];
f0100625:	8d 48 01             	lea    0x1(%eax),%ecx
f0100628:	0f b6 90 20 f0 23 f0 	movzbl -0xfdc0fe0(%eax),%edx
			cons.rpos = 0;
f010062f:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f0100634:	b8 00 00 00 00       	mov    $0x0,%eax
f0100639:	0f 45 c1             	cmovne %ecx,%eax
f010063c:	a3 20 f2 23 f0       	mov    %eax,0xf023f220
}
f0100641:	89 d0                	mov    %edx,%eax
f0100643:	c9                   	leave  
f0100644:	c3                   	ret    

f0100645 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100645:	f3 0f 1e fb          	endbr32 
f0100649:	55                   	push   %ebp
f010064a:	89 e5                	mov    %esp,%ebp
f010064c:	57                   	push   %edi
f010064d:	56                   	push   %esi
f010064e:	53                   	push   %ebx
f010064f:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f0100652:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100659:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100660:	5a a5 
	if (*cp != 0xA55A) {
f0100662:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100669:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010066d:	0f 84 d4 00 00 00    	je     f0100747 <cons_init+0x102>
		addr_6845 = MONO_BASE;
f0100673:	c7 05 30 f2 23 f0 b4 	movl   $0x3b4,0xf023f230
f010067a:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010067d:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f0100682:	8b 3d 30 f2 23 f0    	mov    0xf023f230,%edi
f0100688:	b8 0e 00 00 00       	mov    $0xe,%eax
f010068d:	89 fa                	mov    %edi,%edx
f010068f:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100690:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100693:	89 ca                	mov    %ecx,%edx
f0100695:	ec                   	in     (%dx),%al
f0100696:	0f b6 c0             	movzbl %al,%eax
f0100699:	c1 e0 08             	shl    $0x8,%eax
f010069c:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010069e:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006a3:	89 fa                	mov    %edi,%edx
f01006a5:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006a6:	89 ca                	mov    %ecx,%edx
f01006a8:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f01006a9:	89 35 2c f2 23 f0    	mov    %esi,0xf023f22c
	pos |= inb(addr_6845 + 1);
f01006af:	0f b6 c0             	movzbl %al,%eax
f01006b2:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f01006b4:	66 a3 28 f2 23 f0    	mov    %ax,0xf023f228
	kbd_intr();
f01006ba:	e8 2a ff ff ff       	call   f01005e9 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006bf:	83 ec 0c             	sub    $0xc,%esp
f01006c2:	0f b7 05 a8 43 12 f0 	movzwl 0xf01243a8,%eax
f01006c9:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006ce:	50                   	push   %eax
f01006cf:	e8 88 32 00 00       	call   f010395c <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006d4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01006d9:	b9 fa 03 00 00       	mov    $0x3fa,%ecx
f01006de:	89 d8                	mov    %ebx,%eax
f01006e0:	89 ca                	mov    %ecx,%edx
f01006e2:	ee                   	out    %al,(%dx)
f01006e3:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006e8:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006ed:	89 fa                	mov    %edi,%edx
f01006ef:	ee                   	out    %al,(%dx)
f01006f0:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006f5:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006fa:	ee                   	out    %al,(%dx)
f01006fb:	be f9 03 00 00       	mov    $0x3f9,%esi
f0100700:	89 d8                	mov    %ebx,%eax
f0100702:	89 f2                	mov    %esi,%edx
f0100704:	ee                   	out    %al,(%dx)
f0100705:	b8 03 00 00 00       	mov    $0x3,%eax
f010070a:	89 fa                	mov    %edi,%edx
f010070c:	ee                   	out    %al,(%dx)
f010070d:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100712:	89 d8                	mov    %ebx,%eax
f0100714:	ee                   	out    %al,(%dx)
f0100715:	b8 01 00 00 00       	mov    $0x1,%eax
f010071a:	89 f2                	mov    %esi,%edx
f010071c:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010071d:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100722:	ec                   	in     (%dx),%al
f0100723:	89 c3                	mov    %eax,%ebx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100725:	83 c4 10             	add    $0x10,%esp
f0100728:	3c ff                	cmp    $0xff,%al
f010072a:	0f 95 05 34 f2 23 f0 	setne  0xf023f234
f0100731:	89 ca                	mov    %ecx,%edx
f0100733:	ec                   	in     (%dx),%al
f0100734:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100739:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010073a:	80 fb ff             	cmp    $0xff,%bl
f010073d:	74 23                	je     f0100762 <cons_init+0x11d>
		cprintf("Serial port does not exist!\n");
}
f010073f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100742:	5b                   	pop    %ebx
f0100743:	5e                   	pop    %esi
f0100744:	5f                   	pop    %edi
f0100745:	5d                   	pop    %ebp
f0100746:	c3                   	ret    
		*cp = was;
f0100747:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010074e:	c7 05 30 f2 23 f0 d4 	movl   $0x3d4,0xf023f230
f0100755:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100758:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f010075d:	e9 20 ff ff ff       	jmp    f0100682 <cons_init+0x3d>
		cprintf("Serial port does not exist!\n");
f0100762:	83 ec 0c             	sub    $0xc,%esp
f0100765:	68 cf 68 10 f0       	push   $0xf01068cf
f010076a:	e8 5a 33 00 00       	call   f0103ac9 <cprintf>
f010076f:	83 c4 10             	add    $0x10,%esp
}
f0100772:	eb cb                	jmp    f010073f <cons_init+0xfa>

f0100774 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100774:	f3 0f 1e fb          	endbr32 
f0100778:	55                   	push   %ebp
f0100779:	89 e5                	mov    %esp,%ebp
f010077b:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010077e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100781:	e8 51 fc ff ff       	call   f01003d7 <cons_putc>
}
f0100786:	c9                   	leave  
f0100787:	c3                   	ret    

f0100788 <getchar>:

int
getchar(void)
{
f0100788:	f3 0f 1e fb          	endbr32 
f010078c:	55                   	push   %ebp
f010078d:	89 e5                	mov    %esp,%ebp
f010078f:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100792:	e8 68 fe ff ff       	call   f01005ff <cons_getc>
f0100797:	85 c0                	test   %eax,%eax
f0100799:	74 f7                	je     f0100792 <getchar+0xa>
		/* do nothing */;
	return c;
}
f010079b:	c9                   	leave  
f010079c:	c3                   	ret    

f010079d <iscons>:

int
iscons(int fdnum)
{
f010079d:	f3 0f 1e fb          	endbr32 
	// used by readline
	return 1;
}
f01007a1:	b8 01 00 00 00       	mov    $0x1,%eax
f01007a6:	c3                   	ret    

f01007a7 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007a7:	f3 0f 1e fb          	endbr32 
f01007ab:	55                   	push   %ebp
f01007ac:	89 e5                	mov    %esp,%ebp
f01007ae:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007b1:	68 20 6b 10 f0       	push   $0xf0106b20
f01007b6:	68 3e 6b 10 f0       	push   $0xf0106b3e
f01007bb:	68 43 6b 10 f0       	push   $0xf0106b43
f01007c0:	e8 04 33 00 00       	call   f0103ac9 <cprintf>
f01007c5:	83 c4 0c             	add    $0xc,%esp
f01007c8:	68 cc 6b 10 f0       	push   $0xf0106bcc
f01007cd:	68 4c 6b 10 f0       	push   $0xf0106b4c
f01007d2:	68 43 6b 10 f0       	push   $0xf0106b43
f01007d7:	e8 ed 32 00 00       	call   f0103ac9 <cprintf>
f01007dc:	83 c4 0c             	add    $0xc,%esp
f01007df:	68 55 6b 10 f0       	push   $0xf0106b55
f01007e4:	68 5b 6b 10 f0       	push   $0xf0106b5b
f01007e9:	68 43 6b 10 f0       	push   $0xf0106b43
f01007ee:	e8 d6 32 00 00       	call   f0103ac9 <cprintf>
	return 0;
}
f01007f3:	b8 00 00 00 00       	mov    $0x0,%eax
f01007f8:	c9                   	leave  
f01007f9:	c3                   	ret    

f01007fa <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007fa:	f3 0f 1e fb          	endbr32 
f01007fe:	55                   	push   %ebp
f01007ff:	89 e5                	mov    %esp,%ebp
f0100801:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100804:	68 65 6b 10 f0       	push   $0xf0106b65
f0100809:	e8 bb 32 00 00       	call   f0103ac9 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010080e:	83 c4 08             	add    $0x8,%esp
f0100811:	68 0c 00 10 00       	push   $0x10000c
f0100816:	68 f4 6b 10 f0       	push   $0xf0106bf4
f010081b:	e8 a9 32 00 00       	call   f0103ac9 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100820:	83 c4 0c             	add    $0xc,%esp
f0100823:	68 0c 00 10 00       	push   $0x10000c
f0100828:	68 0c 00 10 f0       	push   $0xf010000c
f010082d:	68 1c 6c 10 f0       	push   $0xf0106c1c
f0100832:	e8 92 32 00 00       	call   f0103ac9 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100837:	83 c4 0c             	add    $0xc,%esp
f010083a:	68 fd 67 10 00       	push   $0x1067fd
f010083f:	68 fd 67 10 f0       	push   $0xf01067fd
f0100844:	68 40 6c 10 f0       	push   $0xf0106c40
f0100849:	e8 7b 32 00 00       	call   f0103ac9 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010084e:	83 c4 0c             	add    $0xc,%esp
f0100851:	68 00 f0 23 00       	push   $0x23f000
f0100856:	68 00 f0 23 f0       	push   $0xf023f000
f010085b:	68 64 6c 10 f0       	push   $0xf0106c64
f0100860:	e8 64 32 00 00       	call   f0103ac9 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100865:	83 c4 0c             	add    $0xc,%esp
f0100868:	68 08 30 28 00       	push   $0x283008
f010086d:	68 08 30 28 f0       	push   $0xf0283008
f0100872:	68 88 6c 10 f0       	push   $0xf0106c88
f0100877:	e8 4d 32 00 00       	call   f0103ac9 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010087c:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010087f:	b8 08 30 28 f0       	mov    $0xf0283008,%eax
f0100884:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100889:	c1 f8 0a             	sar    $0xa,%eax
f010088c:	50                   	push   %eax
f010088d:	68 ac 6c 10 f0       	push   $0xf0106cac
f0100892:	e8 32 32 00 00       	call   f0103ac9 <cprintf>
	return 0;
}
f0100897:	b8 00 00 00 00       	mov    $0x0,%eax
f010089c:	c9                   	leave  
f010089d:	c3                   	ret    

f010089e <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010089e:	f3 0f 1e fb          	endbr32 
f01008a2:	55                   	push   %ebp
f01008a3:	89 e5                	mov    %esp,%ebp
f01008a5:	57                   	push   %edi
f01008a6:	56                   	push   %esi
f01008a7:	53                   	push   %ebx
f01008a8:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008ab:	89 eb                	mov    %ebp,%ebx
	uint32_t *ebp = (uint32_t *)read_ebp();
	struct Eipdebuginfo eipdebuginfo;
	while (ebp != 0) {
		uint32_t eip = *(ebp + 1);
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp + 2), *(ebp + 3), *(ebp + 4), *(ebp + 5), *(ebp + 6));
		debuginfo_eip((uintptr_t)eip, &eipdebuginfo);
f01008ad:	8d 7d d0             	lea    -0x30(%ebp),%edi
	while (ebp != 0) {
f01008b0:	85 db                	test   %ebx,%ebx
f01008b2:	74 55                	je     f0100909 <mon_backtrace+0x6b>
		uint32_t eip = *(ebp + 1);
f01008b4:	8b 73 04             	mov    0x4(%ebx),%esi
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp + 2), *(ebp + 3), *(ebp + 4), *(ebp + 5), *(ebp + 6));
f01008b7:	ff 73 18             	pushl  0x18(%ebx)
f01008ba:	ff 73 14             	pushl  0x14(%ebx)
f01008bd:	ff 73 10             	pushl  0x10(%ebx)
f01008c0:	ff 73 0c             	pushl  0xc(%ebx)
f01008c3:	ff 73 08             	pushl  0x8(%ebx)
f01008c6:	56                   	push   %esi
f01008c7:	53                   	push   %ebx
f01008c8:	68 d8 6c 10 f0       	push   $0xf0106cd8
f01008cd:	e8 f7 31 00 00       	call   f0103ac9 <cprintf>
		debuginfo_eip((uintptr_t)eip, &eipdebuginfo);
f01008d2:	83 c4 18             	add    $0x18,%esp
f01008d5:	57                   	push   %edi
f01008d6:	56                   	push   %esi
f01008d7:	e8 f1 47 00 00       	call   f01050cd <debuginfo_eip>
		cprintf("%s:%d", eipdebuginfo.eip_file, eipdebuginfo.eip_line);
f01008dc:	83 c4 0c             	add    $0xc,%esp
f01008df:	ff 75 d4             	pushl  -0x2c(%ebp)
f01008e2:	ff 75 d0             	pushl  -0x30(%ebp)
f01008e5:	68 7e 6b 10 f0       	push   $0xf0106b7e
f01008ea:	e8 da 31 00 00       	call   f0103ac9 <cprintf>
		cprintf(": %.*s+%d\n", eipdebuginfo.eip_fn_namelen, eipdebuginfo.eip_fn_name, eipdebuginfo.eip_fn_addr);
f01008ef:	ff 75 e0             	pushl  -0x20(%ebp)
f01008f2:	ff 75 d8             	pushl  -0x28(%ebp)
f01008f5:	ff 75 dc             	pushl  -0x24(%ebp)
f01008f8:	68 84 6b 10 f0       	push   $0xf0106b84
f01008fd:	e8 c7 31 00 00       	call   f0103ac9 <cprintf>
		ebp = (uint32_t *)(*ebp);
f0100902:	8b 1b                	mov    (%ebx),%ebx
f0100904:	83 c4 20             	add    $0x20,%esp
f0100907:	eb a7                	jmp    f01008b0 <mon_backtrace+0x12>
	}
	return 0;
}
f0100909:	b8 00 00 00 00       	mov    $0x0,%eax
f010090e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100911:	5b                   	pop    %ebx
f0100912:	5e                   	pop    %esi
f0100913:	5f                   	pop    %edi
f0100914:	5d                   	pop    %ebp
f0100915:	c3                   	ret    

f0100916 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100916:	f3 0f 1e fb          	endbr32 
f010091a:	55                   	push   %ebp
f010091b:	89 e5                	mov    %esp,%ebp
f010091d:	57                   	push   %edi
f010091e:	56                   	push   %esi
f010091f:	53                   	push   %ebx
f0100920:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100923:	68 0c 6d 10 f0       	push   $0xf0106d0c
f0100928:	e8 9c 31 00 00       	call   f0103ac9 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010092d:	c7 04 24 30 6d 10 f0 	movl   $0xf0106d30,(%esp)
f0100934:	e8 90 31 00 00       	call   f0103ac9 <cprintf>

	if (tf != NULL)
f0100939:	83 c4 10             	add    $0x10,%esp
f010093c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100940:	0f 84 d9 00 00 00    	je     f0100a1f <monitor+0x109>
		print_trapframe(tf);
f0100946:	83 ec 0c             	sub    $0xc,%esp
f0100949:	ff 75 08             	pushl  0x8(%ebp)
f010094c:	e8 81 38 00 00       	call   f01041d2 <print_trapframe>
f0100951:	83 c4 10             	add    $0x10,%esp
f0100954:	e9 c6 00 00 00       	jmp    f0100a1f <monitor+0x109>
		while (*buf && strchr(WHITESPACE, *buf))
f0100959:	83 ec 08             	sub    $0x8,%esp
f010095c:	0f be c0             	movsbl %al,%eax
f010095f:	50                   	push   %eax
f0100960:	68 93 6b 10 f0       	push   $0xf0106b93
f0100965:	e8 b4 51 00 00       	call   f0105b1e <strchr>
f010096a:	83 c4 10             	add    $0x10,%esp
f010096d:	85 c0                	test   %eax,%eax
f010096f:	74 63                	je     f01009d4 <monitor+0xbe>
			*buf++ = 0;
f0100971:	c6 03 00             	movb   $0x0,(%ebx)
f0100974:	89 f7                	mov    %esi,%edi
f0100976:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100979:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f010097b:	0f b6 03             	movzbl (%ebx),%eax
f010097e:	84 c0                	test   %al,%al
f0100980:	75 d7                	jne    f0100959 <monitor+0x43>
	argv[argc] = 0;
f0100982:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100989:	00 
	if (argc == 0)
f010098a:	85 f6                	test   %esi,%esi
f010098c:	0f 84 8d 00 00 00    	je     f0100a1f <monitor+0x109>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100992:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f0100997:	83 ec 08             	sub    $0x8,%esp
f010099a:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f010099d:	ff 34 85 60 6d 10 f0 	pushl  -0xfef92a0(,%eax,4)
f01009a4:	ff 75 a8             	pushl  -0x58(%ebp)
f01009a7:	e8 0c 51 00 00       	call   f0105ab8 <strcmp>
f01009ac:	83 c4 10             	add    $0x10,%esp
f01009af:	85 c0                	test   %eax,%eax
f01009b1:	0f 84 8f 00 00 00    	je     f0100a46 <monitor+0x130>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009b7:	83 c3 01             	add    $0x1,%ebx
f01009ba:	83 fb 03             	cmp    $0x3,%ebx
f01009bd:	75 d8                	jne    f0100997 <monitor+0x81>
	cprintf("Unknown command '%s'\n", argv[0]);
f01009bf:	83 ec 08             	sub    $0x8,%esp
f01009c2:	ff 75 a8             	pushl  -0x58(%ebp)
f01009c5:	68 b5 6b 10 f0       	push   $0xf0106bb5
f01009ca:	e8 fa 30 00 00       	call   f0103ac9 <cprintf>
	return 0;
f01009cf:	83 c4 10             	add    $0x10,%esp
f01009d2:	eb 4b                	jmp    f0100a1f <monitor+0x109>
		if (*buf == 0)
f01009d4:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009d7:	74 a9                	je     f0100982 <monitor+0x6c>
		if (argc == MAXARGS-1) {
f01009d9:	83 fe 0f             	cmp    $0xf,%esi
f01009dc:	74 2f                	je     f0100a0d <monitor+0xf7>
		argv[argc++] = buf;
f01009de:	8d 7e 01             	lea    0x1(%esi),%edi
f01009e1:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f01009e5:	0f b6 03             	movzbl (%ebx),%eax
f01009e8:	84 c0                	test   %al,%al
f01009ea:	74 8d                	je     f0100979 <monitor+0x63>
f01009ec:	83 ec 08             	sub    $0x8,%esp
f01009ef:	0f be c0             	movsbl %al,%eax
f01009f2:	50                   	push   %eax
f01009f3:	68 93 6b 10 f0       	push   $0xf0106b93
f01009f8:	e8 21 51 00 00       	call   f0105b1e <strchr>
f01009fd:	83 c4 10             	add    $0x10,%esp
f0100a00:	85 c0                	test   %eax,%eax
f0100a02:	0f 85 71 ff ff ff    	jne    f0100979 <monitor+0x63>
			buf++;
f0100a08:	83 c3 01             	add    $0x1,%ebx
f0100a0b:	eb d8                	jmp    f01009e5 <monitor+0xcf>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a0d:	83 ec 08             	sub    $0x8,%esp
f0100a10:	6a 10                	push   $0x10
f0100a12:	68 98 6b 10 f0       	push   $0xf0106b98
f0100a17:	e8 ad 30 00 00       	call   f0103ac9 <cprintf>
			return 0;
f0100a1c:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100a1f:	83 ec 0c             	sub    $0xc,%esp
f0100a22:	68 8f 6b 10 f0       	push   $0xf0106b8f
f0100a27:	e8 a4 4e 00 00       	call   f01058d0 <readline>
f0100a2c:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100a2e:	83 c4 10             	add    $0x10,%esp
f0100a31:	85 c0                	test   %eax,%eax
f0100a33:	74 ea                	je     f0100a1f <monitor+0x109>
	argv[argc] = 0;
f0100a35:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a3c:	be 00 00 00 00       	mov    $0x0,%esi
f0100a41:	e9 35 ff ff ff       	jmp    f010097b <monitor+0x65>
			return commands[i].func(argc, argv, tf);
f0100a46:	83 ec 04             	sub    $0x4,%esp
f0100a49:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a4c:	ff 75 08             	pushl  0x8(%ebp)
f0100a4f:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a52:	52                   	push   %edx
f0100a53:	56                   	push   %esi
f0100a54:	ff 14 85 68 6d 10 f0 	call   *-0xfef9298(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a5b:	83 c4 10             	add    $0x10,%esp
f0100a5e:	85 c0                	test   %eax,%eax
f0100a60:	79 bd                	jns    f0100a1f <monitor+0x109>
				break;
	}
}
f0100a62:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a65:	5b                   	pop    %ebx
f0100a66:	5e                   	pop    %esi
f0100a67:	5f                   	pop    %edi
f0100a68:	5d                   	pop    %ebp
f0100a69:	c3                   	ret    

f0100a6a <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree)
f0100a6a:	83 3d 38 f2 23 f0 00 	cmpl   $0x0,0xf023f238
f0100a71:	74 1a                	je     f0100a8d <boot_alloc+0x23>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f0100a73:	8b 15 38 f2 23 f0    	mov    0xf023f238,%edx
	nextfree = ROUNDUP((char *)result + n, PGSIZE);
f0100a79:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100a80:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a85:	a3 38 f2 23 f0       	mov    %eax,0xf023f238
	return result;
}
f0100a8a:	89 d0                	mov    %edx,%eax
f0100a8c:	c3                   	ret    
		nextfree = ROUNDUP((char *)end, PGSIZE);
f0100a8d:	ba 07 40 28 f0       	mov    $0xf0284007,%edx
f0100a92:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a98:	89 15 38 f2 23 f0    	mov    %edx,0xf023f238
f0100a9e:	eb d3                	jmp    f0100a73 <boot_alloc+0x9>

f0100aa0 <nvram_read>:
{
f0100aa0:	55                   	push   %ebp
f0100aa1:	89 e5                	mov    %esp,%ebp
f0100aa3:	56                   	push   %esi
f0100aa4:	53                   	push   %ebx
f0100aa5:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100aa7:	83 ec 0c             	sub    $0xc,%esp
f0100aaa:	50                   	push   %eax
f0100aab:	e8 76 2e 00 00       	call   f0103926 <mc146818_read>
f0100ab0:	89 c6                	mov    %eax,%esi
f0100ab2:	83 c3 01             	add    $0x1,%ebx
f0100ab5:	89 1c 24             	mov    %ebx,(%esp)
f0100ab8:	e8 69 2e 00 00       	call   f0103926 <mc146818_read>
f0100abd:	c1 e0 08             	shl    $0x8,%eax
f0100ac0:	09 f0                	or     %esi,%eax
}
f0100ac2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ac5:	5b                   	pop    %ebx
f0100ac6:	5e                   	pop    %esi
f0100ac7:	5d                   	pop    %ebp
f0100ac8:	c3                   	ret    

f0100ac9 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100ac9:	89 d1                	mov    %edx,%ecx
f0100acb:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100ace:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100ad1:	a8 01                	test   $0x1,%al
f0100ad3:	74 51                	je     f0100b26 <check_va2pa+0x5d>
		return ~0;
	p = (pte_t *)KADDR(PTE_ADDR(*pgdir));
f0100ad5:	89 c1                	mov    %eax,%ecx
f0100ad7:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	if (PGNUM(pa) >= npages)
f0100add:	c1 e8 0c             	shr    $0xc,%eax
f0100ae0:	3b 05 c0 1e 24 f0    	cmp    0xf0241ec0,%eax
f0100ae6:	73 23                	jae    f0100b0b <check_va2pa+0x42>
	if (!(p[PTX(va)] & PTE_P))
f0100ae8:	c1 ea 0c             	shr    $0xc,%edx
f0100aeb:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100af1:	8b 94 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100af8:	89 d0                	mov    %edx,%eax
f0100afa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100aff:	f6 c2 01             	test   $0x1,%dl
f0100b02:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b07:	0f 44 c2             	cmove  %edx,%eax
f0100b0a:	c3                   	ret    
{
f0100b0b:	55                   	push   %ebp
f0100b0c:	89 e5                	mov    %esp,%ebp
f0100b0e:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b11:	51                   	push   %ecx
f0100b12:	68 24 68 10 f0       	push   $0xf0106824
f0100b17:	68 a1 03 00 00       	push   $0x3a1
f0100b1c:	68 65 77 10 f0       	push   $0xf0107765
f0100b21:	e8 1a f5 ff ff       	call   f0100040 <_panic>
		return ~0;
f0100b26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100b2b:	c3                   	ret    

f0100b2c <check_page_free_list>:
{
f0100b2c:	55                   	push   %ebp
f0100b2d:	89 e5                	mov    %esp,%ebp
f0100b2f:	57                   	push   %edi
f0100b30:	56                   	push   %esi
f0100b31:	53                   	push   %ebx
f0100b32:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b35:	84 c0                	test   %al,%al
f0100b37:	0f 85 77 02 00 00    	jne    f0100db4 <check_page_free_list+0x288>
	if (!page_free_list)
f0100b3d:	83 3d 40 f2 23 f0 00 	cmpl   $0x0,0xf023f240
f0100b44:	74 0a                	je     f0100b50 <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b46:	be 00 04 00 00       	mov    $0x400,%esi
f0100b4b:	e9 bf 02 00 00       	jmp    f0100e0f <check_page_free_list+0x2e3>
		panic("'page_free_list' is a null pointer!");
f0100b50:	83 ec 04             	sub    $0x4,%esp
f0100b53:	68 84 6d 10 f0       	push   $0xf0106d84
f0100b58:	68 cd 02 00 00       	push   $0x2cd
f0100b5d:	68 65 77 10 f0       	push   $0xf0107765
f0100b62:	e8 d9 f4 ff ff       	call   f0100040 <_panic>
f0100b67:	50                   	push   %eax
f0100b68:	68 24 68 10 f0       	push   $0xf0106824
f0100b6d:	6a 58                	push   $0x58
f0100b6f:	68 71 77 10 f0       	push   $0xf0107771
f0100b74:	e8 c7 f4 ff ff       	call   f0100040 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b79:	8b 1b                	mov    (%ebx),%ebx
f0100b7b:	85 db                	test   %ebx,%ebx
f0100b7d:	74 41                	je     f0100bc0 <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b7f:	89 d8                	mov    %ebx,%eax
f0100b81:	2b 05 c8 1e 24 f0    	sub    0xf0241ec8,%eax
f0100b87:	c1 f8 03             	sar    $0x3,%eax
f0100b8a:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100b8d:	89 c2                	mov    %eax,%edx
f0100b8f:	c1 ea 16             	shr    $0x16,%edx
f0100b92:	39 f2                	cmp    %esi,%edx
f0100b94:	73 e3                	jae    f0100b79 <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100b96:	89 c2                	mov    %eax,%edx
f0100b98:	c1 ea 0c             	shr    $0xc,%edx
f0100b9b:	3b 15 c0 1e 24 f0    	cmp    0xf0241ec0,%edx
f0100ba1:	73 c4                	jae    f0100b67 <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100ba3:	83 ec 04             	sub    $0x4,%esp
f0100ba6:	68 80 00 00 00       	push   $0x80
f0100bab:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100bb0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100bb5:	50                   	push   %eax
f0100bb6:	e8 a8 4f 00 00       	call   f0105b63 <memset>
f0100bbb:	83 c4 10             	add    $0x10,%esp
f0100bbe:	eb b9                	jmp    f0100b79 <check_page_free_list+0x4d>
	first_free_page = (char *)boot_alloc(0);
f0100bc0:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bc5:	e8 a0 fe ff ff       	call   f0100a6a <boot_alloc>
f0100bca:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bcd:	8b 15 40 f2 23 f0    	mov    0xf023f240,%edx
		assert(pp >= pages);
f0100bd3:	8b 0d c8 1e 24 f0    	mov    0xf0241ec8,%ecx
		assert(pp < pages + npages);
f0100bd9:	a1 c0 1e 24 f0       	mov    0xf0241ec0,%eax
f0100bde:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100be1:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100be4:	bf 00 00 00 00       	mov    $0x0,%edi
f0100be9:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bec:	e9 f9 00 00 00       	jmp    f0100cea <check_page_free_list+0x1be>
		assert(pp >= pages);
f0100bf1:	68 7f 77 10 f0       	push   $0xf010777f
f0100bf6:	68 8b 77 10 f0       	push   $0xf010778b
f0100bfb:	68 ea 02 00 00       	push   $0x2ea
f0100c00:	68 65 77 10 f0       	push   $0xf0107765
f0100c05:	e8 36 f4 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c0a:	68 a0 77 10 f0       	push   $0xf01077a0
f0100c0f:	68 8b 77 10 f0       	push   $0xf010778b
f0100c14:	68 eb 02 00 00       	push   $0x2eb
f0100c19:	68 65 77 10 f0       	push   $0xf0107765
f0100c1e:	e8 1d f4 ff ff       	call   f0100040 <_panic>
		assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
f0100c23:	68 a8 6d 10 f0       	push   $0xf0106da8
f0100c28:	68 8b 77 10 f0       	push   $0xf010778b
f0100c2d:	68 ec 02 00 00       	push   $0x2ec
f0100c32:	68 65 77 10 f0       	push   $0xf0107765
f0100c37:	e8 04 f4 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != 0);
f0100c3c:	68 b4 77 10 f0       	push   $0xf01077b4
f0100c41:	68 8b 77 10 f0       	push   $0xf010778b
f0100c46:	68 ef 02 00 00       	push   $0x2ef
f0100c4b:	68 65 77 10 f0       	push   $0xf0107765
f0100c50:	e8 eb f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c55:	68 c5 77 10 f0       	push   $0xf01077c5
f0100c5a:	68 8b 77 10 f0       	push   $0xf010778b
f0100c5f:	68 f0 02 00 00       	push   $0x2f0
f0100c64:	68 65 77 10 f0       	push   $0xf0107765
f0100c69:	e8 d2 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c6e:	68 d8 6d 10 f0       	push   $0xf0106dd8
f0100c73:	68 8b 77 10 f0       	push   $0xf010778b
f0100c78:	68 f1 02 00 00       	push   $0x2f1
f0100c7d:	68 65 77 10 f0       	push   $0xf0107765
f0100c82:	e8 b9 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c87:	68 de 77 10 f0       	push   $0xf01077de
f0100c8c:	68 8b 77 10 f0       	push   $0xf010778b
f0100c91:	68 f2 02 00 00       	push   $0x2f2
f0100c96:	68 65 77 10 f0       	push   $0xf0107765
f0100c9b:	e8 a0 f3 ff ff       	call   f0100040 <_panic>
	if (PGNUM(pa) >= npages)
f0100ca0:	89 c3                	mov    %eax,%ebx
f0100ca2:	c1 eb 0c             	shr    $0xc,%ebx
f0100ca5:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0100ca8:	76 0f                	jbe    f0100cb9 <check_page_free_list+0x18d>
	return (void *)(pa + KERNBASE);
f0100caa:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *)page2kva(pp) >= first_free_page);
f0100caf:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100cb2:	77 17                	ja     f0100ccb <check_page_free_list+0x19f>
			++nfree_extmem;
f0100cb4:	83 c7 01             	add    $0x1,%edi
f0100cb7:	eb 2f                	jmp    f0100ce8 <check_page_free_list+0x1bc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cb9:	50                   	push   %eax
f0100cba:	68 24 68 10 f0       	push   $0xf0106824
f0100cbf:	6a 58                	push   $0x58
f0100cc1:	68 71 77 10 f0       	push   $0xf0107771
f0100cc6:	e8 75 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *)page2kva(pp) >= first_free_page);
f0100ccb:	68 fc 6d 10 f0       	push   $0xf0106dfc
f0100cd0:	68 8b 77 10 f0       	push   $0xf010778b
f0100cd5:	68 f3 02 00 00       	push   $0x2f3
f0100cda:	68 65 77 10 f0       	push   $0xf0107765
f0100cdf:	e8 5c f3 ff ff       	call   f0100040 <_panic>
			++nfree_basemem;
f0100ce4:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ce8:	8b 12                	mov    (%edx),%edx
f0100cea:	85 d2                	test   %edx,%edx
f0100cec:	74 74                	je     f0100d62 <check_page_free_list+0x236>
		assert(pp >= pages);
f0100cee:	39 d1                	cmp    %edx,%ecx
f0100cf0:	0f 87 fb fe ff ff    	ja     f0100bf1 <check_page_free_list+0xc5>
		assert(pp < pages + npages);
f0100cf6:	39 d6                	cmp    %edx,%esi
f0100cf8:	0f 86 0c ff ff ff    	jbe    f0100c0a <check_page_free_list+0xde>
		assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
f0100cfe:	89 d0                	mov    %edx,%eax
f0100d00:	29 c8                	sub    %ecx,%eax
f0100d02:	a8 07                	test   $0x7,%al
f0100d04:	0f 85 19 ff ff ff    	jne    f0100c23 <check_page_free_list+0xf7>
	return (pp - pages) << PGSHIFT;
f0100d0a:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100d0d:	c1 e0 0c             	shl    $0xc,%eax
f0100d10:	0f 84 26 ff ff ff    	je     f0100c3c <check_page_free_list+0x110>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d16:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d1b:	0f 84 34 ff ff ff    	je     f0100c55 <check_page_free_list+0x129>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d21:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d26:	0f 84 42 ff ff ff    	je     f0100c6e <check_page_free_list+0x142>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d2c:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d31:	0f 84 50 ff ff ff    	je     f0100c87 <check_page_free_list+0x15b>
		assert(page2pa(pp) < EXTPHYSMEM || (char *)page2kva(pp) >= first_free_page);
f0100d37:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d3c:	0f 87 5e ff ff ff    	ja     f0100ca0 <check_page_free_list+0x174>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100d42:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100d47:	75 9b                	jne    f0100ce4 <check_page_free_list+0x1b8>
f0100d49:	68 f8 77 10 f0       	push   $0xf01077f8
f0100d4e:	68 8b 77 10 f0       	push   $0xf010778b
f0100d53:	68 f5 02 00 00       	push   $0x2f5
f0100d58:	68 65 77 10 f0       	push   $0xf0107765
f0100d5d:	e8 de f2 ff ff       	call   f0100040 <_panic>
f0100d62:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
	assert(nfree_basemem > 0);
f0100d65:	85 db                	test   %ebx,%ebx
f0100d67:	7e 19                	jle    f0100d82 <check_page_free_list+0x256>
	assert(nfree_extmem > 0);
f0100d69:	85 ff                	test   %edi,%edi
f0100d6b:	7e 2e                	jle    f0100d9b <check_page_free_list+0x26f>
	cprintf("check_page_free_list() succeeded!\n");
f0100d6d:	83 ec 0c             	sub    $0xc,%esp
f0100d70:	68 40 6e 10 f0       	push   $0xf0106e40
f0100d75:	e8 4f 2d 00 00       	call   f0103ac9 <cprintf>
}
f0100d7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d7d:	5b                   	pop    %ebx
f0100d7e:	5e                   	pop    %esi
f0100d7f:	5f                   	pop    %edi
f0100d80:	5d                   	pop    %ebp
f0100d81:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100d82:	68 15 78 10 f0       	push   $0xf0107815
f0100d87:	68 8b 77 10 f0       	push   $0xf010778b
f0100d8c:	68 fd 02 00 00       	push   $0x2fd
f0100d91:	68 65 77 10 f0       	push   $0xf0107765
f0100d96:	e8 a5 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100d9b:	68 27 78 10 f0       	push   $0xf0107827
f0100da0:	68 8b 77 10 f0       	push   $0xf010778b
f0100da5:	68 fe 02 00 00       	push   $0x2fe
f0100daa:	68 65 77 10 f0       	push   $0xf0107765
f0100daf:	e8 8c f2 ff ff       	call   f0100040 <_panic>
	if (!page_free_list)
f0100db4:	a1 40 f2 23 f0       	mov    0xf023f240,%eax
f0100db9:	85 c0                	test   %eax,%eax
f0100dbb:	0f 84 8f fd ff ff    	je     f0100b50 <check_page_free_list+0x24>
		struct PageInfo **tp[2] = {&pp1, &pp2};
f0100dc1:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100dc4:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100dc7:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100dca:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100dcd:	89 c2                	mov    %eax,%edx
f0100dcf:	2b 15 c8 1e 24 f0    	sub    0xf0241ec8,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100dd5:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100ddb:	0f 95 c2             	setne  %dl
f0100dde:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100de1:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100de5:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100de7:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link)
f0100deb:	8b 00                	mov    (%eax),%eax
f0100ded:	85 c0                	test   %eax,%eax
f0100def:	75 dc                	jne    f0100dcd <check_page_free_list+0x2a1>
		*tp[1] = 0;
f0100df1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100df4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100dfa:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100dfd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e00:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100e02:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e05:	a3 40 f2 23 f0       	mov    %eax,0xf023f240
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e0a:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100e0f:	8b 1d 40 f2 23 f0    	mov    0xf023f240,%ebx
f0100e15:	e9 61 fd ff ff       	jmp    f0100b7b <check_page_free_list+0x4f>

f0100e1a <page_init>:
{
f0100e1a:	f3 0f 1e fb          	endbr32 
f0100e1e:	55                   	push   %ebp
f0100e1f:	89 e5                	mov    %esp,%ebp
f0100e21:	57                   	push   %edi
f0100e22:	56                   	push   %esi
f0100e23:	53                   	push   %ebx
f0100e24:	83 ec 0c             	sub    $0xc,%esp
	size_t kernel_end_page = PADDR(boot_alloc(0)) / PGSIZE;
f0100e27:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e2c:	e8 39 fc ff ff       	call   f0100a6a <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0100e31:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100e36:	76 20                	jbe    f0100e58 <page_init+0x3e>
	return (physaddr_t)kva - KERNBASE;
f0100e38:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f0100e3e:	c1 e9 0c             	shr    $0xc,%ecx
f0100e41:	8b 1d 40 f2 23 f0    	mov    0xf023f240,%ebx
	for (i = 0; i < npages; i++)
f0100e47:	be 00 00 00 00       	mov    $0x0,%esi
f0100e4c:	b8 00 00 00 00       	mov    $0x0,%eax
			page_free_list = &pages[i];
f0100e51:	bf 01 00 00 00       	mov    $0x1,%edi
	for (i = 0; i < npages; i++)
f0100e56:	eb 38                	jmp    f0100e90 <page_init+0x76>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e58:	50                   	push   %eax
f0100e59:	68 48 68 10 f0       	push   $0xf0106848
f0100e5e:	68 3e 01 00 00       	push   $0x13e
f0100e63:	68 65 77 10 f0       	push   $0xf0107765
f0100e68:	e8 d3 f1 ff ff       	call   f0100040 <_panic>
		else if (i >= io_hole_start_page && i < kernel_end_page)
f0100e6d:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f0100e72:	76 3c                	jbe    f0100eb0 <page_init+0x96>
f0100e74:	39 c8                	cmp    %ecx,%eax
f0100e76:	73 38                	jae    f0100eb0 <page_init+0x96>
			pages[i].pp_ref = 1;
f0100e78:	8b 15 c8 1e 24 f0    	mov    0xf0241ec8,%edx
f0100e7e:	8d 14 c2             	lea    (%edx,%eax,8),%edx
f0100e81:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
			pages[i].pp_link = NULL;
f0100e87:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	for (i = 0; i < npages; i++)
f0100e8d:	83 c0 01             	add    $0x1,%eax
f0100e90:	39 05 c0 1e 24 f0    	cmp    %eax,0xf0241ec0
f0100e96:	76 55                	jbe    f0100eed <page_init+0xd3>
		if (i == 0)
f0100e98:	85 c0                	test   %eax,%eax
f0100e9a:	75 d1                	jne    f0100e6d <page_init+0x53>
			pages[i].pp_ref = 1;
f0100e9c:	8b 15 c8 1e 24 f0    	mov    0xf0241ec8,%edx
f0100ea2:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
			pages[i].pp_link = NULL;
f0100ea8:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
f0100eae:	eb dd                	jmp    f0100e8d <page_init+0x73>
		else if (i == MPENTRY_PADDR / PGSIZE)
f0100eb0:	83 f8 07             	cmp    $0x7,%eax
f0100eb3:	74 23                	je     f0100ed8 <page_init+0xbe>
f0100eb5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
			pages[i].pp_ref = 0;
f0100ebc:	89 d6                	mov    %edx,%esi
f0100ebe:	03 35 c8 1e 24 f0    	add    0xf0241ec8,%esi
f0100ec4:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
			pages[i].pp_link = page_free_list;
f0100eca:	89 1e                	mov    %ebx,(%esi)
			page_free_list = &pages[i];
f0100ecc:	89 d3                	mov    %edx,%ebx
f0100ece:	03 1d c8 1e 24 f0    	add    0xf0241ec8,%ebx
f0100ed4:	89 fe                	mov    %edi,%esi
f0100ed6:	eb b5                	jmp    f0100e8d <page_init+0x73>
			pages[i].pp_ref = 1;
f0100ed8:	8b 15 c8 1e 24 f0    	mov    0xf0241ec8,%edx
f0100ede:	66 c7 42 3c 01 00    	movw   $0x1,0x3c(%edx)
			pages[i].pp_link = NULL;
f0100ee4:	c7 42 38 00 00 00 00 	movl   $0x0,0x38(%edx)
f0100eeb:	eb a0                	jmp    f0100e8d <page_init+0x73>
f0100eed:	89 f0                	mov    %esi,%eax
f0100eef:	84 c0                	test   %al,%al
f0100ef1:	74 06                	je     f0100ef9 <page_init+0xdf>
f0100ef3:	89 1d 40 f2 23 f0    	mov    %ebx,0xf023f240
}
f0100ef9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100efc:	5b                   	pop    %ebx
f0100efd:	5e                   	pop    %esi
f0100efe:	5f                   	pop    %edi
f0100eff:	5d                   	pop    %ebp
f0100f00:	c3                   	ret    

f0100f01 <page_alloc>:
{
f0100f01:	f3 0f 1e fb          	endbr32 
f0100f05:	55                   	push   %ebp
f0100f06:	89 e5                	mov    %esp,%ebp
f0100f08:	53                   	push   %ebx
f0100f09:	83 ec 04             	sub    $0x4,%esp
	struct PageInfo *ret = page_free_list;
f0100f0c:	8b 1d 40 f2 23 f0    	mov    0xf023f240,%ebx
	if (ret == NULL)
f0100f12:	85 db                	test   %ebx,%ebx
f0100f14:	74 13                	je     f0100f29 <page_alloc+0x28>
	page_free_list = ret->pp_link;
f0100f16:	8b 03                	mov    (%ebx),%eax
f0100f18:	a3 40 f2 23 f0       	mov    %eax,0xf023f240
	ret->pp_link = NULL;
f0100f1d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO)
f0100f23:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f27:	75 07                	jne    f0100f30 <page_alloc+0x2f>
}
f0100f29:	89 d8                	mov    %ebx,%eax
f0100f2b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f2e:	c9                   	leave  
f0100f2f:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0100f30:	89 d8                	mov    %ebx,%eax
f0100f32:	2b 05 c8 1e 24 f0    	sub    0xf0241ec8,%eax
f0100f38:	c1 f8 03             	sar    $0x3,%eax
f0100f3b:	89 c2                	mov    %eax,%edx
f0100f3d:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0100f40:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0100f45:	3b 05 c0 1e 24 f0    	cmp    0xf0241ec0,%eax
f0100f4b:	73 1b                	jae    f0100f68 <page_alloc+0x67>
		memset(page2kva(ret), 0, PGSIZE);
f0100f4d:	83 ec 04             	sub    $0x4,%esp
f0100f50:	68 00 10 00 00       	push   $0x1000
f0100f55:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100f57:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0100f5d:	52                   	push   %edx
f0100f5e:	e8 00 4c 00 00       	call   f0105b63 <memset>
f0100f63:	83 c4 10             	add    $0x10,%esp
f0100f66:	eb c1                	jmp    f0100f29 <page_alloc+0x28>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f68:	52                   	push   %edx
f0100f69:	68 24 68 10 f0       	push   $0xf0106824
f0100f6e:	6a 58                	push   $0x58
f0100f70:	68 71 77 10 f0       	push   $0xf0107771
f0100f75:	e8 c6 f0 ff ff       	call   f0100040 <_panic>

f0100f7a <page_free>:
{
f0100f7a:	f3 0f 1e fb          	endbr32 
f0100f7e:	55                   	push   %ebp
f0100f7f:	89 e5                	mov    %esp,%ebp
f0100f81:	83 ec 08             	sub    $0x8,%esp
f0100f84:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref != 0 || pp->pp_link != NULL)
f0100f87:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f8c:	75 14                	jne    f0100fa2 <page_free+0x28>
f0100f8e:	83 38 00             	cmpl   $0x0,(%eax)
f0100f91:	75 0f                	jne    f0100fa2 <page_free+0x28>
	pp->pp_link = page_free_list;
f0100f93:	8b 15 40 f2 23 f0    	mov    0xf023f240,%edx
f0100f99:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100f9b:	a3 40 f2 23 f0       	mov    %eax,0xf023f240
}
f0100fa0:	c9                   	leave  
f0100fa1:	c3                   	ret    
		panic("page_free: pp->pp_ref is nonzero or pp->pp_link is not NULL\n");
f0100fa2:	83 ec 04             	sub    $0x4,%esp
f0100fa5:	68 64 6e 10 f0       	push   $0xf0106e64
f0100faa:	68 81 01 00 00       	push   $0x181
f0100faf:	68 65 77 10 f0       	push   $0xf0107765
f0100fb4:	e8 87 f0 ff ff       	call   f0100040 <_panic>

f0100fb9 <page_decref>:
{
f0100fb9:	f3 0f 1e fb          	endbr32 
f0100fbd:	55                   	push   %ebp
f0100fbe:	89 e5                	mov    %esp,%ebp
f0100fc0:	83 ec 08             	sub    $0x8,%esp
f0100fc3:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100fc6:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100fca:	83 e8 01             	sub    $0x1,%eax
f0100fcd:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100fd1:	66 85 c0             	test   %ax,%ax
f0100fd4:	74 02                	je     f0100fd8 <page_decref+0x1f>
}
f0100fd6:	c9                   	leave  
f0100fd7:	c3                   	ret    
		page_free(pp);
f0100fd8:	83 ec 0c             	sub    $0xc,%esp
f0100fdb:	52                   	push   %edx
f0100fdc:	e8 99 ff ff ff       	call   f0100f7a <page_free>
f0100fe1:	83 c4 10             	add    $0x10,%esp
}
f0100fe4:	eb f0                	jmp    f0100fd6 <page_decref+0x1d>

f0100fe6 <pgdir_walk>:
{
f0100fe6:	f3 0f 1e fb          	endbr32 
f0100fea:	55                   	push   %ebp
f0100feb:	89 e5                	mov    %esp,%ebp
f0100fed:	56                   	push   %esi
f0100fee:	53                   	push   %ebx
f0100fef:	8b 75 0c             	mov    0xc(%ebp),%esi
	pde_t *pde = &pgdir[PDX(va)];
f0100ff2:	89 f3                	mov    %esi,%ebx
f0100ff4:	c1 eb 16             	shr    $0x16,%ebx
f0100ff7:	c1 e3 02             	shl    $0x2,%ebx
f0100ffa:	03 5d 08             	add    0x8(%ebp),%ebx
	if (!(*pde & PTE_P))
f0100ffd:	f6 03 01             	testb  $0x1,(%ebx)
f0101000:	75 2d                	jne    f010102f <pgdir_walk+0x49>
		if (!create)
f0101002:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101006:	74 68                	je     f0101070 <pgdir_walk+0x8a>
		if ((pp = page_alloc(ALLOC_ZERO)) == NULL)
f0101008:	83 ec 0c             	sub    $0xc,%esp
f010100b:	6a 01                	push   $0x1
f010100d:	e8 ef fe ff ff       	call   f0100f01 <page_alloc>
f0101012:	83 c4 10             	add    $0x10,%esp
f0101015:	85 c0                	test   %eax,%eax
f0101017:	74 3b                	je     f0101054 <pgdir_walk+0x6e>
		pp->pp_ref++;
f0101019:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f010101e:	2b 05 c8 1e 24 f0    	sub    0xf0241ec8,%eax
f0101024:	c1 f8 03             	sar    $0x3,%eax
f0101027:	c1 e0 0c             	shl    $0xc,%eax
		*pde = page2pa(pp) | PTE_P | PTE_W | PTE_U;
f010102a:	83 c8 07             	or     $0x7,%eax
f010102d:	89 03                	mov    %eax,(%ebx)
	pt_addr = KADDR(PTE_ADDR(*pde));
f010102f:	8b 03                	mov    (%ebx),%eax
f0101031:	89 c2                	mov    %eax,%edx
f0101033:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101039:	c1 e8 0c             	shr    $0xc,%eax
f010103c:	3b 05 c0 1e 24 f0    	cmp    0xf0241ec0,%eax
f0101042:	73 17                	jae    f010105b <pgdir_walk+0x75>
	return (pte_t *)(pt_addr + PTX(va));
f0101044:	c1 ee 0a             	shr    $0xa,%esi
f0101047:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f010104d:	8d 84 32 00 00 00 f0 	lea    -0x10000000(%edx,%esi,1),%eax
}
f0101054:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101057:	5b                   	pop    %ebx
f0101058:	5e                   	pop    %esi
f0101059:	5d                   	pop    %ebp
f010105a:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010105b:	52                   	push   %edx
f010105c:	68 24 68 10 f0       	push   $0xf0106824
f0101061:	68 be 01 00 00       	push   $0x1be
f0101066:	68 65 77 10 f0       	push   $0xf0107765
f010106b:	e8 d0 ef ff ff       	call   f0100040 <_panic>
			return NULL;
f0101070:	b8 00 00 00 00       	mov    $0x0,%eax
f0101075:	eb dd                	jmp    f0101054 <pgdir_walk+0x6e>

f0101077 <boot_map_region>:
{
f0101077:	55                   	push   %ebp
f0101078:	89 e5                	mov    %esp,%ebp
f010107a:	57                   	push   %edi
f010107b:	56                   	push   %esi
f010107c:	53                   	push   %ebx
f010107d:	83 ec 1c             	sub    $0x1c,%esp
f0101080:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101083:	8b 45 08             	mov    0x8(%ebp),%eax
	size_t pgs = size / PGSIZE;
f0101086:	89 cb                	mov    %ecx,%ebx
f0101088:	c1 eb 0c             	shr    $0xc,%ebx
	if (size % PGSIZE != 0)
f010108b:	81 e1 ff 0f 00 00    	and    $0xfff,%ecx
		pgs++;
f0101091:	83 f9 01             	cmp    $0x1,%ecx
f0101094:	83 db ff             	sbb    $0xffffffff,%ebx
f0101097:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	for (int i = 0; i < pgs; i++)
f010109a:	89 c3                	mov    %eax,%ebx
f010109c:	be 00 00 00 00       	mov    $0x0,%esi
		pte_t *pte = pgdir_walk(pgdir, (void *)va, 1);
f01010a1:	89 d7                	mov    %edx,%edi
f01010a3:	29 c7                	sub    %eax,%edi
	for (int i = 0; i < pgs; i++)
f01010a5:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f01010a8:	74 44                	je     f01010ee <boot_map_region+0x77>
		pte_t *pte = pgdir_walk(pgdir, (void *)va, 1);
f01010aa:	83 ec 04             	sub    $0x4,%esp
f01010ad:	6a 01                	push   $0x1
f01010af:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f01010b2:	50                   	push   %eax
f01010b3:	ff 75 e0             	pushl  -0x20(%ebp)
f01010b6:	e8 2b ff ff ff       	call   f0100fe6 <pgdir_walk>
		if (pte == NULL)
f01010bb:	83 c4 10             	add    $0x10,%esp
f01010be:	85 c0                	test   %eax,%eax
f01010c0:	74 15                	je     f01010d7 <boot_map_region+0x60>
		*pte = pa | PTE_P | perm;
f01010c2:	89 da                	mov    %ebx,%edx
f01010c4:	0b 55 0c             	or     0xc(%ebp),%edx
f01010c7:	83 ca 01             	or     $0x1,%edx
f01010ca:	89 10                	mov    %edx,(%eax)
		pa += PGSIZE;
f01010cc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (int i = 0; i < pgs; i++)
f01010d2:	83 c6 01             	add    $0x1,%esi
f01010d5:	eb ce                	jmp    f01010a5 <boot_map_region+0x2e>
			panic("boot_map_region(): out of memory\n");
f01010d7:	83 ec 04             	sub    $0x4,%esp
f01010da:	68 a4 6e 10 f0       	push   $0xf0106ea4
f01010df:	68 db 01 00 00       	push   $0x1db
f01010e4:	68 65 77 10 f0       	push   $0xf0107765
f01010e9:	e8 52 ef ff ff       	call   f0100040 <_panic>
}
f01010ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010f1:	5b                   	pop    %ebx
f01010f2:	5e                   	pop    %esi
f01010f3:	5f                   	pop    %edi
f01010f4:	5d                   	pop    %ebp
f01010f5:	c3                   	ret    

f01010f6 <page_lookup>:
{
f01010f6:	f3 0f 1e fb          	endbr32 
f01010fa:	55                   	push   %ebp
f01010fb:	89 e5                	mov    %esp,%ebp
f01010fd:	53                   	push   %ebx
f01010fe:	83 ec 08             	sub    $0x8,%esp
f0101101:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f0101104:	6a 00                	push   $0x0
f0101106:	ff 75 0c             	pushl  0xc(%ebp)
f0101109:	ff 75 08             	pushl  0x8(%ebp)
f010110c:	e8 d5 fe ff ff       	call   f0100fe6 <pgdir_walk>
	if (pte == NULL)
f0101111:	83 c4 10             	add    $0x10,%esp
f0101114:	85 c0                	test   %eax,%eax
f0101116:	74 3b                	je     f0101153 <page_lookup+0x5d>
	if (!(*pte) & PTE_P)
f0101118:	8b 10                	mov    (%eax),%edx
f010111a:	85 d2                	test   %edx,%edx
f010111c:	74 39                	je     f0101157 <page_lookup+0x61>
f010111e:	c1 ea 0c             	shr    $0xc,%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101121:	39 15 c0 1e 24 f0    	cmp    %edx,0xf0241ec0
f0101127:	76 16                	jbe    f010113f <page_lookup+0x49>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f0101129:	8b 0d c8 1e 24 f0    	mov    0xf0241ec8,%ecx
f010112f:	8d 14 d1             	lea    (%ecx,%edx,8),%edx
	if (pte_store != NULL)
f0101132:	85 db                	test   %ebx,%ebx
f0101134:	74 02                	je     f0101138 <page_lookup+0x42>
		*pte_store = pte;
f0101136:	89 03                	mov    %eax,(%ebx)
}
f0101138:	89 d0                	mov    %edx,%eax
f010113a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010113d:	c9                   	leave  
f010113e:	c3                   	ret    
		panic("pa2page called with invalid pa");
f010113f:	83 ec 04             	sub    $0x4,%esp
f0101142:	68 c8 6e 10 f0       	push   $0xf0106ec8
f0101147:	6a 51                	push   $0x51
f0101149:	68 71 77 10 f0       	push   $0xf0107771
f010114e:	e8 ed ee ff ff       	call   f0100040 <_panic>
		return NULL;
f0101153:	89 c2                	mov    %eax,%edx
f0101155:	eb e1                	jmp    f0101138 <page_lookup+0x42>
		return NULL;
f0101157:	ba 00 00 00 00       	mov    $0x0,%edx
f010115c:	eb da                	jmp    f0101138 <page_lookup+0x42>

f010115e <tlb_invalidate>:
{
f010115e:	f3 0f 1e fb          	endbr32 
f0101162:	55                   	push   %ebp
f0101163:	89 e5                	mov    %esp,%ebp
f0101165:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f0101168:	e8 15 50 00 00       	call   f0106182 <cpunum>
f010116d:	6b c0 74             	imul   $0x74,%eax,%eax
f0101170:	83 b8 28 20 24 f0 00 	cmpl   $0x0,-0xfdbdfd8(%eax)
f0101177:	74 16                	je     f010118f <tlb_invalidate+0x31>
f0101179:	e8 04 50 00 00       	call   f0106182 <cpunum>
f010117e:	6b c0 74             	imul   $0x74,%eax,%eax
f0101181:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0101187:	8b 55 08             	mov    0x8(%ebp),%edx
f010118a:	39 50 60             	cmp    %edx,0x60(%eax)
f010118d:	75 06                	jne    f0101195 <tlb_invalidate+0x37>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010118f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101192:	0f 01 38             	invlpg (%eax)
}
f0101195:	c9                   	leave  
f0101196:	c3                   	ret    

f0101197 <page_remove>:
{
f0101197:	f3 0f 1e fb          	endbr32 
f010119b:	55                   	push   %ebp
f010119c:	89 e5                	mov    %esp,%ebp
f010119e:	56                   	push   %esi
f010119f:	53                   	push   %ebx
f01011a0:	83 ec 14             	sub    $0x14,%esp
f01011a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01011a6:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct PageInfo *pp = page_lookup(pgdir, va, &pte_store);
f01011a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01011ac:	50                   	push   %eax
f01011ad:	56                   	push   %esi
f01011ae:	53                   	push   %ebx
f01011af:	e8 42 ff ff ff       	call   f01010f6 <page_lookup>
	if (pp == NULL)
f01011b4:	83 c4 10             	add    $0x10,%esp
f01011b7:	85 c0                	test   %eax,%eax
f01011b9:	74 1f                	je     f01011da <page_remove+0x43>
	page_decref(pp);
f01011bb:	83 ec 0c             	sub    $0xc,%esp
f01011be:	50                   	push   %eax
f01011bf:	e8 f5 fd ff ff       	call   f0100fb9 <page_decref>
	*pte_store = 0;
f01011c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01011c7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f01011cd:	83 c4 08             	add    $0x8,%esp
f01011d0:	56                   	push   %esi
f01011d1:	53                   	push   %ebx
f01011d2:	e8 87 ff ff ff       	call   f010115e <tlb_invalidate>
f01011d7:	83 c4 10             	add    $0x10,%esp
}
f01011da:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01011dd:	5b                   	pop    %ebx
f01011de:	5e                   	pop    %esi
f01011df:	5d                   	pop    %ebp
f01011e0:	c3                   	ret    

f01011e1 <page_insert>:
{
f01011e1:	f3 0f 1e fb          	endbr32 
f01011e5:	55                   	push   %ebp
f01011e6:	89 e5                	mov    %esp,%ebp
f01011e8:	57                   	push   %edi
f01011e9:	56                   	push   %esi
f01011ea:	53                   	push   %ebx
f01011eb:	83 ec 10             	sub    $0x10,%esp
f01011ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01011f1:	8b 7d 10             	mov    0x10(%ebp),%edi
	if ((pte = pgdir_walk(pgdir, va, 1)) == NULL)
f01011f4:	6a 01                	push   $0x1
f01011f6:	57                   	push   %edi
f01011f7:	ff 75 08             	pushl  0x8(%ebp)
f01011fa:	e8 e7 fd ff ff       	call   f0100fe6 <pgdir_walk>
f01011ff:	83 c4 10             	add    $0x10,%esp
f0101202:	85 c0                	test   %eax,%eax
f0101204:	74 3e                	je     f0101244 <page_insert+0x63>
f0101206:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f0101208:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if (*pte & PTE_P)
f010120d:	f6 00 01             	testb  $0x1,(%eax)
f0101210:	75 21                	jne    f0101233 <page_insert+0x52>
	return (pp - pages) << PGSHIFT;
f0101212:	2b 1d c8 1e 24 f0    	sub    0xf0241ec8,%ebx
f0101218:	c1 fb 03             	sar    $0x3,%ebx
f010121b:	c1 e3 0c             	shl    $0xc,%ebx
	*pte = page2pa(pp) | perm | PTE_P;
f010121e:	0b 5d 14             	or     0x14(%ebp),%ebx
f0101221:	83 cb 01             	or     $0x1,%ebx
f0101224:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0101226:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010122b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010122e:	5b                   	pop    %ebx
f010122f:	5e                   	pop    %esi
f0101230:	5f                   	pop    %edi
f0101231:	5d                   	pop    %ebp
f0101232:	c3                   	ret    
		page_remove(pgdir, va);
f0101233:	83 ec 08             	sub    $0x8,%esp
f0101236:	57                   	push   %edi
f0101237:	ff 75 08             	pushl  0x8(%ebp)
f010123a:	e8 58 ff ff ff       	call   f0101197 <page_remove>
f010123f:	83 c4 10             	add    $0x10,%esp
f0101242:	eb ce                	jmp    f0101212 <page_insert+0x31>
		return -E_NO_MEM;
f0101244:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101249:	eb e0                	jmp    f010122b <page_insert+0x4a>

f010124b <mmio_map_region>:
{
f010124b:	f3 0f 1e fb          	endbr32 
f010124f:	55                   	push   %ebp
f0101250:	89 e5                	mov    %esp,%ebp
f0101252:	57                   	push   %edi
f0101253:	56                   	push   %esi
f0101254:	53                   	push   %ebx
f0101255:	83 ec 0c             	sub    $0xc,%esp
f0101258:	8b 5d 08             	mov    0x8(%ebp),%ebx
	size = ROUNDUP(pa + size, PGSIZE);
f010125b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010125e:	8d bc 03 ff 0f 00 00 	lea    0xfff(%ebx,%eax,1),%edi
f0101265:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	pa = ROUNDDOWN(pa, PGSIZE);
f010126b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	size -= pa;
f0101271:	89 fe                	mov    %edi,%esi
f0101273:	29 de                	sub    %ebx,%esi
	if (base + size >= MMIOLIM)
f0101275:	8b 15 00 43 12 f0    	mov    0xf0124300,%edx
f010127b:	8d 04 32             	lea    (%edx,%esi,1),%eax
f010127e:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101283:	77 2b                	ja     f01012b0 <mmio_map_region+0x65>
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD | PTE_PWT | PTE_W);
f0101285:	83 ec 08             	sub    $0x8,%esp
f0101288:	6a 1a                	push   $0x1a
f010128a:	53                   	push   %ebx
f010128b:	89 f1                	mov    %esi,%ecx
f010128d:	a1 c4 1e 24 f0       	mov    0xf0241ec4,%eax
f0101292:	e8 e0 fd ff ff       	call   f0101077 <boot_map_region>
	base += size;
f0101297:	89 f0                	mov    %esi,%eax
f0101299:	03 05 00 43 12 f0    	add    0xf0124300,%eax
f010129f:	a3 00 43 12 f0       	mov    %eax,0xf0124300
	return (void *)(base - size);
f01012a4:	29 fb                	sub    %edi,%ebx
f01012a6:	01 d8                	add    %ebx,%eax
}
f01012a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012ab:	5b                   	pop    %ebx
f01012ac:	5e                   	pop    %esi
f01012ad:	5f                   	pop    %edi
f01012ae:	5d                   	pop    %ebp
f01012af:	c3                   	ret    
		panic("not enough memory");
f01012b0:	83 ec 04             	sub    $0x4,%esp
f01012b3:	68 38 78 10 f0       	push   $0xf0107838
f01012b8:	68 7d 02 00 00       	push   $0x27d
f01012bd:	68 65 77 10 f0       	push   $0xf0107765
f01012c2:	e8 79 ed ff ff       	call   f0100040 <_panic>

f01012c7 <mem_init>:
{
f01012c7:	f3 0f 1e fb          	endbr32 
f01012cb:	55                   	push   %ebp
f01012cc:	89 e5                	mov    %esp,%ebp
f01012ce:	57                   	push   %edi
f01012cf:	56                   	push   %esi
f01012d0:	53                   	push   %ebx
f01012d1:	83 ec 3c             	sub    $0x3c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f01012d4:	b8 15 00 00 00       	mov    $0x15,%eax
f01012d9:	e8 c2 f7 ff ff       	call   f0100aa0 <nvram_read>
f01012de:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f01012e0:	b8 17 00 00 00       	mov    $0x17,%eax
f01012e5:	e8 b6 f7 ff ff       	call   f0100aa0 <nvram_read>
f01012ea:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01012ec:	b8 34 00 00 00       	mov    $0x34,%eax
f01012f1:	e8 aa f7 ff ff       	call   f0100aa0 <nvram_read>
	if (ext16mem)
f01012f6:	c1 e0 06             	shl    $0x6,%eax
f01012f9:	0f 84 df 00 00 00    	je     f01013de <mem_init+0x117>
		totalmem = 16 * 1024 + ext16mem;
f01012ff:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101304:	89 c2                	mov    %eax,%edx
f0101306:	c1 ea 02             	shr    $0x2,%edx
f0101309:	89 15 c0 1e 24 f0    	mov    %edx,0xf0241ec0
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010130f:	89 c2                	mov    %eax,%edx
f0101311:	29 da                	sub    %ebx,%edx
f0101313:	52                   	push   %edx
f0101314:	53                   	push   %ebx
f0101315:	50                   	push   %eax
f0101316:	68 e8 6e 10 f0       	push   $0xf0106ee8
f010131b:	e8 a9 27 00 00       	call   f0103ac9 <cprintf>
	kern_pgdir = (pde_t *)boot_alloc(PGSIZE);
f0101320:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101325:	e8 40 f7 ff ff       	call   f0100a6a <boot_alloc>
f010132a:	a3 c4 1e 24 f0       	mov    %eax,0xf0241ec4
	memset(kern_pgdir, 0, PGSIZE);
f010132f:	83 c4 0c             	add    $0xc,%esp
f0101332:	68 00 10 00 00       	push   $0x1000
f0101337:	6a 00                	push   $0x0
f0101339:	50                   	push   %eax
f010133a:	e8 24 48 00 00       	call   f0105b63 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010133f:	a1 c4 1e 24 f0       	mov    0xf0241ec4,%eax
	if ((uint32_t)kva < KERNBASE)
f0101344:	83 c4 10             	add    $0x10,%esp
f0101347:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010134c:	0f 86 9c 00 00 00    	jbe    f01013ee <mem_init+0x127>
	return (physaddr_t)kva - KERNBASE;
f0101352:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101358:	83 ca 05             	or     $0x5,%edx
f010135b:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *)boot_alloc(sizeof(struct PageInfo) * npages);
f0101361:	a1 c0 1e 24 f0       	mov    0xf0241ec0,%eax
f0101366:	c1 e0 03             	shl    $0x3,%eax
f0101369:	e8 fc f6 ff ff       	call   f0100a6a <boot_alloc>
f010136e:	a3 c8 1e 24 f0       	mov    %eax,0xf0241ec8
	memset(pages, 0, sizeof(struct PageInfo) * npages);
f0101373:	83 ec 04             	sub    $0x4,%esp
f0101376:	8b 0d c0 1e 24 f0    	mov    0xf0241ec0,%ecx
f010137c:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101383:	52                   	push   %edx
f0101384:	6a 00                	push   $0x0
f0101386:	50                   	push   %eax
f0101387:	e8 d7 47 00 00       	call   f0105b63 <memset>
	envs = (struct Env *)boot_alloc(sizeof(struct Env) * NENV);
f010138c:	b8 00 10 02 00       	mov    $0x21000,%eax
f0101391:	e8 d4 f6 ff ff       	call   f0100a6a <boot_alloc>
f0101396:	a3 44 f2 23 f0       	mov    %eax,0xf023f244
	memset(envs, 0, sizeof(struct Env) * NENV);
f010139b:	83 c4 0c             	add    $0xc,%esp
f010139e:	68 00 10 02 00       	push   $0x21000
f01013a3:	6a 00                	push   $0x0
f01013a5:	50                   	push   %eax
f01013a6:	e8 b8 47 00 00       	call   f0105b63 <memset>
	page_init();
f01013ab:	e8 6a fa ff ff       	call   f0100e1a <page_init>
	check_page_free_list(1);
f01013b0:	b8 01 00 00 00       	mov    $0x1,%eax
f01013b5:	e8 72 f7 ff ff       	call   f0100b2c <check_page_free_list>
	if (!pages)
f01013ba:	83 c4 10             	add    $0x10,%esp
f01013bd:	83 3d c8 1e 24 f0 00 	cmpl   $0x0,0xf0241ec8
f01013c4:	74 3d                	je     f0101403 <mem_init+0x13c>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01013c6:	a1 40 f2 23 f0       	mov    0xf023f240,%eax
f01013cb:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f01013d2:	85 c0                	test   %eax,%eax
f01013d4:	74 44                	je     f010141a <mem_init+0x153>
		++nfree;
f01013d6:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01013da:	8b 00                	mov    (%eax),%eax
f01013dc:	eb f4                	jmp    f01013d2 <mem_init+0x10b>
		totalmem = 1 * 1024 + extmem;
f01013de:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01013e4:	85 f6                	test   %esi,%esi
f01013e6:	0f 44 c3             	cmove  %ebx,%eax
f01013e9:	e9 16 ff ff ff       	jmp    f0101304 <mem_init+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01013ee:	50                   	push   %eax
f01013ef:	68 48 68 10 f0       	push   $0xf0106848
f01013f4:	68 90 00 00 00       	push   $0x90
f01013f9:	68 65 77 10 f0       	push   $0xf0107765
f01013fe:	e8 3d ec ff ff       	call   f0100040 <_panic>
		panic("'pages' is a null pointer!");
f0101403:	83 ec 04             	sub    $0x4,%esp
f0101406:	68 4a 78 10 f0       	push   $0xf010784a
f010140b:	68 11 03 00 00       	push   $0x311
f0101410:	68 65 77 10 f0       	push   $0xf0107765
f0101415:	e8 26 ec ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f010141a:	83 ec 0c             	sub    $0xc,%esp
f010141d:	6a 00                	push   $0x0
f010141f:	e8 dd fa ff ff       	call   f0100f01 <page_alloc>
f0101424:	89 c3                	mov    %eax,%ebx
f0101426:	83 c4 10             	add    $0x10,%esp
f0101429:	85 c0                	test   %eax,%eax
f010142b:	0f 84 11 02 00 00    	je     f0101642 <mem_init+0x37b>
	assert((pp1 = page_alloc(0)));
f0101431:	83 ec 0c             	sub    $0xc,%esp
f0101434:	6a 00                	push   $0x0
f0101436:	e8 c6 fa ff ff       	call   f0100f01 <page_alloc>
f010143b:	89 c6                	mov    %eax,%esi
f010143d:	83 c4 10             	add    $0x10,%esp
f0101440:	85 c0                	test   %eax,%eax
f0101442:	0f 84 13 02 00 00    	je     f010165b <mem_init+0x394>
	assert((pp2 = page_alloc(0)));
f0101448:	83 ec 0c             	sub    $0xc,%esp
f010144b:	6a 00                	push   $0x0
f010144d:	e8 af fa ff ff       	call   f0100f01 <page_alloc>
f0101452:	89 c7                	mov    %eax,%edi
f0101454:	83 c4 10             	add    $0x10,%esp
f0101457:	85 c0                	test   %eax,%eax
f0101459:	0f 84 15 02 00 00    	je     f0101674 <mem_init+0x3ad>
	assert(pp1 && pp1 != pp0);
f010145f:	39 f3                	cmp    %esi,%ebx
f0101461:	0f 84 26 02 00 00    	je     f010168d <mem_init+0x3c6>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101467:	39 c3                	cmp    %eax,%ebx
f0101469:	0f 84 37 02 00 00    	je     f01016a6 <mem_init+0x3df>
f010146f:	39 c6                	cmp    %eax,%esi
f0101471:	0f 84 2f 02 00 00    	je     f01016a6 <mem_init+0x3df>
	return (pp - pages) << PGSHIFT;
f0101477:	8b 0d c8 1e 24 f0    	mov    0xf0241ec8,%ecx
	assert(page2pa(pp0) < npages * PGSIZE);
f010147d:	8b 15 c0 1e 24 f0    	mov    0xf0241ec0,%edx
f0101483:	c1 e2 0c             	shl    $0xc,%edx
f0101486:	89 d8                	mov    %ebx,%eax
f0101488:	29 c8                	sub    %ecx,%eax
f010148a:	c1 f8 03             	sar    $0x3,%eax
f010148d:	c1 e0 0c             	shl    $0xc,%eax
f0101490:	39 d0                	cmp    %edx,%eax
f0101492:	0f 83 27 02 00 00    	jae    f01016bf <mem_init+0x3f8>
f0101498:	89 f0                	mov    %esi,%eax
f010149a:	29 c8                	sub    %ecx,%eax
f010149c:	c1 f8 03             	sar    $0x3,%eax
f010149f:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages * PGSIZE);
f01014a2:	39 c2                	cmp    %eax,%edx
f01014a4:	0f 86 2e 02 00 00    	jbe    f01016d8 <mem_init+0x411>
f01014aa:	89 f8                	mov    %edi,%eax
f01014ac:	29 c8                	sub    %ecx,%eax
f01014ae:	c1 f8 03             	sar    $0x3,%eax
f01014b1:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages * PGSIZE);
f01014b4:	39 c2                	cmp    %eax,%edx
f01014b6:	0f 86 35 02 00 00    	jbe    f01016f1 <mem_init+0x42a>
	fl = page_free_list;
f01014bc:	a1 40 f2 23 f0       	mov    0xf023f240,%eax
f01014c1:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01014c4:	c7 05 40 f2 23 f0 00 	movl   $0x0,0xf023f240
f01014cb:	00 00 00 
	assert(!page_alloc(0));
f01014ce:	83 ec 0c             	sub    $0xc,%esp
f01014d1:	6a 00                	push   $0x0
f01014d3:	e8 29 fa ff ff       	call   f0100f01 <page_alloc>
f01014d8:	83 c4 10             	add    $0x10,%esp
f01014db:	85 c0                	test   %eax,%eax
f01014dd:	0f 85 27 02 00 00    	jne    f010170a <mem_init+0x443>
	page_free(pp0);
f01014e3:	83 ec 0c             	sub    $0xc,%esp
f01014e6:	53                   	push   %ebx
f01014e7:	e8 8e fa ff ff       	call   f0100f7a <page_free>
	page_free(pp1);
f01014ec:	89 34 24             	mov    %esi,(%esp)
f01014ef:	e8 86 fa ff ff       	call   f0100f7a <page_free>
	page_free(pp2);
f01014f4:	89 3c 24             	mov    %edi,(%esp)
f01014f7:	e8 7e fa ff ff       	call   f0100f7a <page_free>
	assert((pp0 = page_alloc(0)));
f01014fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101503:	e8 f9 f9 ff ff       	call   f0100f01 <page_alloc>
f0101508:	89 c3                	mov    %eax,%ebx
f010150a:	83 c4 10             	add    $0x10,%esp
f010150d:	85 c0                	test   %eax,%eax
f010150f:	0f 84 0e 02 00 00    	je     f0101723 <mem_init+0x45c>
	assert((pp1 = page_alloc(0)));
f0101515:	83 ec 0c             	sub    $0xc,%esp
f0101518:	6a 00                	push   $0x0
f010151a:	e8 e2 f9 ff ff       	call   f0100f01 <page_alloc>
f010151f:	89 c6                	mov    %eax,%esi
f0101521:	83 c4 10             	add    $0x10,%esp
f0101524:	85 c0                	test   %eax,%eax
f0101526:	0f 84 10 02 00 00    	je     f010173c <mem_init+0x475>
	assert((pp2 = page_alloc(0)));
f010152c:	83 ec 0c             	sub    $0xc,%esp
f010152f:	6a 00                	push   $0x0
f0101531:	e8 cb f9 ff ff       	call   f0100f01 <page_alloc>
f0101536:	89 c7                	mov    %eax,%edi
f0101538:	83 c4 10             	add    $0x10,%esp
f010153b:	85 c0                	test   %eax,%eax
f010153d:	0f 84 12 02 00 00    	je     f0101755 <mem_init+0x48e>
	assert(pp1 && pp1 != pp0);
f0101543:	39 f3                	cmp    %esi,%ebx
f0101545:	0f 84 23 02 00 00    	je     f010176e <mem_init+0x4a7>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010154b:	39 c6                	cmp    %eax,%esi
f010154d:	0f 84 34 02 00 00    	je     f0101787 <mem_init+0x4c0>
f0101553:	39 c3                	cmp    %eax,%ebx
f0101555:	0f 84 2c 02 00 00    	je     f0101787 <mem_init+0x4c0>
	assert(!page_alloc(0));
f010155b:	83 ec 0c             	sub    $0xc,%esp
f010155e:	6a 00                	push   $0x0
f0101560:	e8 9c f9 ff ff       	call   f0100f01 <page_alloc>
f0101565:	83 c4 10             	add    $0x10,%esp
f0101568:	85 c0                	test   %eax,%eax
f010156a:	0f 85 30 02 00 00    	jne    f01017a0 <mem_init+0x4d9>
f0101570:	89 d8                	mov    %ebx,%eax
f0101572:	2b 05 c8 1e 24 f0    	sub    0xf0241ec8,%eax
f0101578:	c1 f8 03             	sar    $0x3,%eax
f010157b:	89 c2                	mov    %eax,%edx
f010157d:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101580:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101585:	3b 05 c0 1e 24 f0    	cmp    0xf0241ec0,%eax
f010158b:	0f 83 28 02 00 00    	jae    f01017b9 <mem_init+0x4f2>
	memset(page2kva(pp0), 1, PGSIZE);
f0101591:	83 ec 04             	sub    $0x4,%esp
f0101594:	68 00 10 00 00       	push   $0x1000
f0101599:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f010159b:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01015a1:	52                   	push   %edx
f01015a2:	e8 bc 45 00 00       	call   f0105b63 <memset>
	page_free(pp0);
f01015a7:	89 1c 24             	mov    %ebx,(%esp)
f01015aa:	e8 cb f9 ff ff       	call   f0100f7a <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01015af:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01015b6:	e8 46 f9 ff ff       	call   f0100f01 <page_alloc>
f01015bb:	83 c4 10             	add    $0x10,%esp
f01015be:	85 c0                	test   %eax,%eax
f01015c0:	0f 84 05 02 00 00    	je     f01017cb <mem_init+0x504>
	assert(pp && pp0 == pp);
f01015c6:	39 c3                	cmp    %eax,%ebx
f01015c8:	0f 85 16 02 00 00    	jne    f01017e4 <mem_init+0x51d>
	return (pp - pages) << PGSHIFT;
f01015ce:	2b 05 c8 1e 24 f0    	sub    0xf0241ec8,%eax
f01015d4:	c1 f8 03             	sar    $0x3,%eax
f01015d7:	89 c2                	mov    %eax,%edx
f01015d9:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01015dc:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01015e1:	3b 05 c0 1e 24 f0    	cmp    0xf0241ec0,%eax
f01015e7:	0f 83 10 02 00 00    	jae    f01017fd <mem_init+0x536>
	return (void *)(pa + KERNBASE);
f01015ed:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f01015f3:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f01015f9:	80 38 00             	cmpb   $0x0,(%eax)
f01015fc:	0f 85 0d 02 00 00    	jne    f010180f <mem_init+0x548>
f0101602:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f0101605:	39 d0                	cmp    %edx,%eax
f0101607:	75 f0                	jne    f01015f9 <mem_init+0x332>
	page_free_list = fl;
f0101609:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010160c:	a3 40 f2 23 f0       	mov    %eax,0xf023f240
	page_free(pp0);
f0101611:	83 ec 0c             	sub    $0xc,%esp
f0101614:	53                   	push   %ebx
f0101615:	e8 60 f9 ff ff       	call   f0100f7a <page_free>
	page_free(pp1);
f010161a:	89 34 24             	mov    %esi,(%esp)
f010161d:	e8 58 f9 ff ff       	call   f0100f7a <page_free>
	page_free(pp2);
f0101622:	89 3c 24             	mov    %edi,(%esp)
f0101625:	e8 50 f9 ff ff       	call   f0100f7a <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010162a:	a1 40 f2 23 f0       	mov    0xf023f240,%eax
f010162f:	83 c4 10             	add    $0x10,%esp
f0101632:	85 c0                	test   %eax,%eax
f0101634:	0f 84 ee 01 00 00    	je     f0101828 <mem_init+0x561>
		--nfree;
f010163a:	83 6d d4 01          	subl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010163e:	8b 00                	mov    (%eax),%eax
f0101640:	eb f0                	jmp    f0101632 <mem_init+0x36b>
	assert((pp0 = page_alloc(0)));
f0101642:	68 65 78 10 f0       	push   $0xf0107865
f0101647:	68 8b 77 10 f0       	push   $0xf010778b
f010164c:	68 19 03 00 00       	push   $0x319
f0101651:	68 65 77 10 f0       	push   $0xf0107765
f0101656:	e8 e5 e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010165b:	68 7b 78 10 f0       	push   $0xf010787b
f0101660:	68 8b 77 10 f0       	push   $0xf010778b
f0101665:	68 1a 03 00 00       	push   $0x31a
f010166a:	68 65 77 10 f0       	push   $0xf0107765
f010166f:	e8 cc e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101674:	68 91 78 10 f0       	push   $0xf0107891
f0101679:	68 8b 77 10 f0       	push   $0xf010778b
f010167e:	68 1b 03 00 00       	push   $0x31b
f0101683:	68 65 77 10 f0       	push   $0xf0107765
f0101688:	e8 b3 e9 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f010168d:	68 a7 78 10 f0       	push   $0xf01078a7
f0101692:	68 8b 77 10 f0       	push   $0xf010778b
f0101697:	68 1e 03 00 00       	push   $0x31e
f010169c:	68 65 77 10 f0       	push   $0xf0107765
f01016a1:	e8 9a e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016a6:	68 24 6f 10 f0       	push   $0xf0106f24
f01016ab:	68 8b 77 10 f0       	push   $0xf010778b
f01016b0:	68 1f 03 00 00       	push   $0x31f
f01016b5:	68 65 77 10 f0       	push   $0xf0107765
f01016ba:	e8 81 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp0) < npages * PGSIZE);
f01016bf:	68 44 6f 10 f0       	push   $0xf0106f44
f01016c4:	68 8b 77 10 f0       	push   $0xf010778b
f01016c9:	68 20 03 00 00       	push   $0x320
f01016ce:	68 65 77 10 f0       	push   $0xf0107765
f01016d3:	e8 68 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages * PGSIZE);
f01016d8:	68 64 6f 10 f0       	push   $0xf0106f64
f01016dd:	68 8b 77 10 f0       	push   $0xf010778b
f01016e2:	68 21 03 00 00       	push   $0x321
f01016e7:	68 65 77 10 f0       	push   $0xf0107765
f01016ec:	e8 4f e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages * PGSIZE);
f01016f1:	68 84 6f 10 f0       	push   $0xf0106f84
f01016f6:	68 8b 77 10 f0       	push   $0xf010778b
f01016fb:	68 22 03 00 00       	push   $0x322
f0101700:	68 65 77 10 f0       	push   $0xf0107765
f0101705:	e8 36 e9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010170a:	68 b9 78 10 f0       	push   $0xf01078b9
f010170f:	68 8b 77 10 f0       	push   $0xf010778b
f0101714:	68 29 03 00 00       	push   $0x329
f0101719:	68 65 77 10 f0       	push   $0xf0107765
f010171e:	e8 1d e9 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0101723:	68 65 78 10 f0       	push   $0xf0107865
f0101728:	68 8b 77 10 f0       	push   $0xf010778b
f010172d:	68 30 03 00 00       	push   $0x330
f0101732:	68 65 77 10 f0       	push   $0xf0107765
f0101737:	e8 04 e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010173c:	68 7b 78 10 f0       	push   $0xf010787b
f0101741:	68 8b 77 10 f0       	push   $0xf010778b
f0101746:	68 31 03 00 00       	push   $0x331
f010174b:	68 65 77 10 f0       	push   $0xf0107765
f0101750:	e8 eb e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101755:	68 91 78 10 f0       	push   $0xf0107891
f010175a:	68 8b 77 10 f0       	push   $0xf010778b
f010175f:	68 32 03 00 00       	push   $0x332
f0101764:	68 65 77 10 f0       	push   $0xf0107765
f0101769:	e8 d2 e8 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f010176e:	68 a7 78 10 f0       	push   $0xf01078a7
f0101773:	68 8b 77 10 f0       	push   $0xf010778b
f0101778:	68 34 03 00 00       	push   $0x334
f010177d:	68 65 77 10 f0       	push   $0xf0107765
f0101782:	e8 b9 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101787:	68 24 6f 10 f0       	push   $0xf0106f24
f010178c:	68 8b 77 10 f0       	push   $0xf010778b
f0101791:	68 35 03 00 00       	push   $0x335
f0101796:	68 65 77 10 f0       	push   $0xf0107765
f010179b:	e8 a0 e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01017a0:	68 b9 78 10 f0       	push   $0xf01078b9
f01017a5:	68 8b 77 10 f0       	push   $0xf010778b
f01017aa:	68 36 03 00 00       	push   $0x336
f01017af:	68 65 77 10 f0       	push   $0xf0107765
f01017b4:	e8 87 e8 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017b9:	52                   	push   %edx
f01017ba:	68 24 68 10 f0       	push   $0xf0106824
f01017bf:	6a 58                	push   $0x58
f01017c1:	68 71 77 10 f0       	push   $0xf0107771
f01017c6:	e8 75 e8 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01017cb:	68 c8 78 10 f0       	push   $0xf01078c8
f01017d0:	68 8b 77 10 f0       	push   $0xf010778b
f01017d5:	68 3b 03 00 00       	push   $0x33b
f01017da:	68 65 77 10 f0       	push   $0xf0107765
f01017df:	e8 5c e8 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01017e4:	68 e6 78 10 f0       	push   $0xf01078e6
f01017e9:	68 8b 77 10 f0       	push   $0xf010778b
f01017ee:	68 3c 03 00 00       	push   $0x33c
f01017f3:	68 65 77 10 f0       	push   $0xf0107765
f01017f8:	e8 43 e8 ff ff       	call   f0100040 <_panic>
f01017fd:	52                   	push   %edx
f01017fe:	68 24 68 10 f0       	push   $0xf0106824
f0101803:	6a 58                	push   $0x58
f0101805:	68 71 77 10 f0       	push   $0xf0107771
f010180a:	e8 31 e8 ff ff       	call   f0100040 <_panic>
		assert(c[i] == 0);
f010180f:	68 f6 78 10 f0       	push   $0xf01078f6
f0101814:	68 8b 77 10 f0       	push   $0xf010778b
f0101819:	68 3f 03 00 00       	push   $0x33f
f010181e:	68 65 77 10 f0       	push   $0xf0107765
f0101823:	e8 18 e8 ff ff       	call   f0100040 <_panic>
	assert(nfree == 0);
f0101828:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010182c:	0f 85 43 09 00 00    	jne    f0102175 <mem_init+0xeae>
	cprintf("check_page_alloc() succeeded!\n");
f0101832:	83 ec 0c             	sub    $0xc,%esp
f0101835:	68 a4 6f 10 f0       	push   $0xf0106fa4
f010183a:	e8 8a 22 00 00       	call   f0103ac9 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010183f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101846:	e8 b6 f6 ff ff       	call   f0100f01 <page_alloc>
f010184b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010184e:	83 c4 10             	add    $0x10,%esp
f0101851:	85 c0                	test   %eax,%eax
f0101853:	0f 84 35 09 00 00    	je     f010218e <mem_init+0xec7>
	assert((pp1 = page_alloc(0)));
f0101859:	83 ec 0c             	sub    $0xc,%esp
f010185c:	6a 00                	push   $0x0
f010185e:	e8 9e f6 ff ff       	call   f0100f01 <page_alloc>
f0101863:	89 c7                	mov    %eax,%edi
f0101865:	83 c4 10             	add    $0x10,%esp
f0101868:	85 c0                	test   %eax,%eax
f010186a:	0f 84 37 09 00 00    	je     f01021a7 <mem_init+0xee0>
	assert((pp2 = page_alloc(0)));
f0101870:	83 ec 0c             	sub    $0xc,%esp
f0101873:	6a 00                	push   $0x0
f0101875:	e8 87 f6 ff ff       	call   f0100f01 <page_alloc>
f010187a:	89 c3                	mov    %eax,%ebx
f010187c:	83 c4 10             	add    $0x10,%esp
f010187f:	85 c0                	test   %eax,%eax
f0101881:	0f 84 39 09 00 00    	je     f01021c0 <mem_init+0xef9>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101887:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f010188a:	0f 84 49 09 00 00    	je     f01021d9 <mem_init+0xf12>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101890:	39 c7                	cmp    %eax,%edi
f0101892:	0f 84 5a 09 00 00    	je     f01021f2 <mem_init+0xf2b>
f0101898:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010189b:	0f 84 51 09 00 00    	je     f01021f2 <mem_init+0xf2b>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01018a1:	a1 40 f2 23 f0       	mov    0xf023f240,%eax
f01018a6:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f01018a9:	c7 05 40 f2 23 f0 00 	movl   $0x0,0xf023f240
f01018b0:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01018b3:	83 ec 0c             	sub    $0xc,%esp
f01018b6:	6a 00                	push   $0x0
f01018b8:	e8 44 f6 ff ff       	call   f0100f01 <page_alloc>
f01018bd:	83 c4 10             	add    $0x10,%esp
f01018c0:	85 c0                	test   %eax,%eax
f01018c2:	0f 85 43 09 00 00    	jne    f010220b <mem_init+0xf44>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *)0x0, &ptep) == NULL);
f01018c8:	83 ec 04             	sub    $0x4,%esp
f01018cb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01018ce:	50                   	push   %eax
f01018cf:	6a 00                	push   $0x0
f01018d1:	ff 35 c4 1e 24 f0    	pushl  0xf0241ec4
f01018d7:	e8 1a f8 ff ff       	call   f01010f6 <page_lookup>
f01018dc:	83 c4 10             	add    $0x10,%esp
f01018df:	85 c0                	test   %eax,%eax
f01018e1:	0f 85 3d 09 00 00    	jne    f0102224 <mem_init+0xf5d>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01018e7:	6a 02                	push   $0x2
f01018e9:	6a 00                	push   $0x0
f01018eb:	57                   	push   %edi
f01018ec:	ff 35 c4 1e 24 f0    	pushl  0xf0241ec4
f01018f2:	e8 ea f8 ff ff       	call   f01011e1 <page_insert>
f01018f7:	83 c4 10             	add    $0x10,%esp
f01018fa:	85 c0                	test   %eax,%eax
f01018fc:	0f 89 3b 09 00 00    	jns    f010223d <mem_init+0xf76>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101902:	83 ec 0c             	sub    $0xc,%esp
f0101905:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101908:	e8 6d f6 ff ff       	call   f0100f7a <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010190d:	6a 02                	push   $0x2
f010190f:	6a 00                	push   $0x0
f0101911:	57                   	push   %edi
f0101912:	ff 35 c4 1e 24 f0    	pushl  0xf0241ec4
f0101918:	e8 c4 f8 ff ff       	call   f01011e1 <page_insert>
f010191d:	83 c4 20             	add    $0x20,%esp
f0101920:	85 c0                	test   %eax,%eax
f0101922:	0f 85 2e 09 00 00    	jne    f0102256 <mem_init+0xf8f>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101928:	8b 35 c4 1e 24 f0    	mov    0xf0241ec4,%esi
	return (pp - pages) << PGSHIFT;
f010192e:	8b 0d c8 1e 24 f0    	mov    0xf0241ec8,%ecx
f0101934:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0101937:	8b 16                	mov    (%esi),%edx
f0101939:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010193f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101942:	29 c8                	sub    %ecx,%eax
f0101944:	c1 f8 03             	sar    $0x3,%eax
f0101947:	c1 e0 0c             	shl    $0xc,%eax
f010194a:	39 c2                	cmp    %eax,%edx
f010194c:	0f 85 1d 09 00 00    	jne    f010226f <mem_init+0xfa8>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101952:	ba 00 00 00 00       	mov    $0x0,%edx
f0101957:	89 f0                	mov    %esi,%eax
f0101959:	e8 6b f1 ff ff       	call   f0100ac9 <check_va2pa>
f010195e:	89 c2                	mov    %eax,%edx
f0101960:	89 f8                	mov    %edi,%eax
f0101962:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101965:	c1 f8 03             	sar    $0x3,%eax
f0101968:	c1 e0 0c             	shl    $0xc,%eax
f010196b:	39 c2                	cmp    %eax,%edx
f010196d:	0f 85 15 09 00 00    	jne    f0102288 <mem_init+0xfc1>
	assert(pp1->pp_ref == 1);
f0101973:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101978:	0f 85 23 09 00 00    	jne    f01022a1 <mem_init+0xfda>
	assert(pp0->pp_ref == 1);
f010197e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101981:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101986:	0f 85 2e 09 00 00    	jne    f01022ba <mem_init+0xff3>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f010198c:	6a 02                	push   $0x2
f010198e:	68 00 10 00 00       	push   $0x1000
f0101993:	53                   	push   %ebx
f0101994:	56                   	push   %esi
f0101995:	e8 47 f8 ff ff       	call   f01011e1 <page_insert>
f010199a:	83 c4 10             	add    $0x10,%esp
f010199d:	85 c0                	test   %eax,%eax
f010199f:	0f 85 2e 09 00 00    	jne    f01022d3 <mem_init+0x100c>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019a5:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019aa:	a1 c4 1e 24 f0       	mov    0xf0241ec4,%eax
f01019af:	e8 15 f1 ff ff       	call   f0100ac9 <check_va2pa>
f01019b4:	89 c2                	mov    %eax,%edx
f01019b6:	89 d8                	mov    %ebx,%eax
f01019b8:	2b 05 c8 1e 24 f0    	sub    0xf0241ec8,%eax
f01019be:	c1 f8 03             	sar    $0x3,%eax
f01019c1:	c1 e0 0c             	shl    $0xc,%eax
f01019c4:	39 c2                	cmp    %eax,%edx
f01019c6:	0f 85 20 09 00 00    	jne    f01022ec <mem_init+0x1025>
	assert(pp2->pp_ref == 1);
f01019cc:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01019d1:	0f 85 2e 09 00 00    	jne    f0102305 <mem_init+0x103e>

	// should be no free memory
	assert(!page_alloc(0));
f01019d7:	83 ec 0c             	sub    $0xc,%esp
f01019da:	6a 00                	push   $0x0
f01019dc:	e8 20 f5 ff ff       	call   f0100f01 <page_alloc>
f01019e1:	83 c4 10             	add    $0x10,%esp
f01019e4:	85 c0                	test   %eax,%eax
f01019e6:	0f 85 32 09 00 00    	jne    f010231e <mem_init+0x1057>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f01019ec:	6a 02                	push   $0x2
f01019ee:	68 00 10 00 00       	push   $0x1000
f01019f3:	53                   	push   %ebx
f01019f4:	ff 35 c4 1e 24 f0    	pushl  0xf0241ec4
f01019fa:	e8 e2 f7 ff ff       	call   f01011e1 <page_insert>
f01019ff:	83 c4 10             	add    $0x10,%esp
f0101a02:	85 c0                	test   %eax,%eax
f0101a04:	0f 85 2d 09 00 00    	jne    f0102337 <mem_init+0x1070>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a0a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a0f:	a1 c4 1e 24 f0       	mov    0xf0241ec4,%eax
f0101a14:	e8 b0 f0 ff ff       	call   f0100ac9 <check_va2pa>
f0101a19:	89 c2                	mov    %eax,%edx
f0101a1b:	89 d8                	mov    %ebx,%eax
f0101a1d:	2b 05 c8 1e 24 f0    	sub    0xf0241ec8,%eax
f0101a23:	c1 f8 03             	sar    $0x3,%eax
f0101a26:	c1 e0 0c             	shl    $0xc,%eax
f0101a29:	39 c2                	cmp    %eax,%edx
f0101a2b:	0f 85 1f 09 00 00    	jne    f0102350 <mem_init+0x1089>
	assert(pp2->pp_ref == 1);
f0101a31:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a36:	0f 85 2d 09 00 00    	jne    f0102369 <mem_init+0x10a2>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101a3c:	83 ec 0c             	sub    $0xc,%esp
f0101a3f:	6a 00                	push   $0x0
f0101a41:	e8 bb f4 ff ff       	call   f0100f01 <page_alloc>
f0101a46:	83 c4 10             	add    $0x10,%esp
f0101a49:	85 c0                	test   %eax,%eax
f0101a4b:	0f 85 31 09 00 00    	jne    f0102382 <mem_init+0x10bb>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *)KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101a51:	8b 0d c4 1e 24 f0    	mov    0xf0241ec4,%ecx
f0101a57:	8b 01                	mov    (%ecx),%eax
f0101a59:	89 c2                	mov    %eax,%edx
f0101a5b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101a61:	c1 e8 0c             	shr    $0xc,%eax
f0101a64:	3b 05 c0 1e 24 f0    	cmp    0xf0241ec0,%eax
f0101a6a:	0f 83 2b 09 00 00    	jae    f010239b <mem_init+0x10d4>
	return (void *)(pa + KERNBASE);
f0101a70:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101a76:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) == ptep + PTX(PGSIZE));
f0101a79:	83 ec 04             	sub    $0x4,%esp
f0101a7c:	6a 00                	push   $0x0
f0101a7e:	68 00 10 00 00       	push   $0x1000
f0101a83:	51                   	push   %ecx
f0101a84:	e8 5d f5 ff ff       	call   f0100fe6 <pgdir_walk>
f0101a89:	89 c2                	mov    %eax,%edx
f0101a8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101a8e:	83 c0 04             	add    $0x4,%eax
f0101a91:	83 c4 10             	add    $0x10,%esp
f0101a94:	39 d0                	cmp    %edx,%eax
f0101a96:	0f 85 14 09 00 00    	jne    f01023b0 <mem_init+0x10e9>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W | PTE_U) == 0);
f0101a9c:	6a 06                	push   $0x6
f0101a9e:	68 00 10 00 00       	push   $0x1000
f0101aa3:	53                   	push   %ebx
f0101aa4:	ff 35 c4 1e 24 f0    	pushl  0xf0241ec4
f0101aaa:	e8 32 f7 ff ff       	call   f01011e1 <page_insert>
f0101aaf:	83 c4 10             	add    $0x10,%esp
f0101ab2:	85 c0                	test   %eax,%eax
f0101ab4:	0f 85 0f 09 00 00    	jne    f01023c9 <mem_init+0x1102>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101aba:	8b 35 c4 1e 24 f0    	mov    0xf0241ec4,%esi
f0101ac0:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ac5:	89 f0                	mov    %esi,%eax
f0101ac7:	e8 fd ef ff ff       	call   f0100ac9 <check_va2pa>
f0101acc:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;
f0101ace:	89 d8                	mov    %ebx,%eax
f0101ad0:	2b 05 c8 1e 24 f0    	sub    0xf0241ec8,%eax
f0101ad6:	c1 f8 03             	sar    $0x3,%eax
f0101ad9:	c1 e0 0c             	shl    $0xc,%eax
f0101adc:	39 c2                	cmp    %eax,%edx
f0101ade:	0f 85 fe 08 00 00    	jne    f01023e2 <mem_init+0x111b>
	assert(pp2->pp_ref == 1);
f0101ae4:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ae9:	0f 85 0c 09 00 00    	jne    f01023fb <mem_init+0x1134>
	assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U);
f0101aef:	83 ec 04             	sub    $0x4,%esp
f0101af2:	6a 00                	push   $0x0
f0101af4:	68 00 10 00 00       	push   $0x1000
f0101af9:	56                   	push   %esi
f0101afa:	e8 e7 f4 ff ff       	call   f0100fe6 <pgdir_walk>
f0101aff:	83 c4 10             	add    $0x10,%esp
f0101b02:	f6 00 04             	testb  $0x4,(%eax)
f0101b05:	0f 84 09 09 00 00    	je     f0102414 <mem_init+0x114d>
	assert(kern_pgdir[0] & PTE_U);
f0101b0b:	a1 c4 1e 24 f0       	mov    0xf0241ec4,%eax
f0101b10:	f6 00 04             	testb  $0x4,(%eax)
f0101b13:	0f 84 14 09 00 00    	je     f010242d <mem_init+0x1166>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f0101b19:	6a 02                	push   $0x2
f0101b1b:	68 00 10 00 00       	push   $0x1000
f0101b20:	53                   	push   %ebx
f0101b21:	50                   	push   %eax
f0101b22:	e8 ba f6 ff ff       	call   f01011e1 <page_insert>
f0101b27:	83 c4 10             	add    $0x10,%esp
f0101b2a:	85 c0                	test   %eax,%eax
f0101b2c:	0f 85 14 09 00 00    	jne    f0102446 <mem_init+0x117f>
	assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_W);
f0101b32:	83 ec 04             	sub    $0x4,%esp
f0101b35:	6a 00                	push   $0x0
f0101b37:	68 00 10 00 00       	push   $0x1000
f0101b3c:	ff 35 c4 1e 24 f0    	pushl  0xf0241ec4
f0101b42:	e8 9f f4 ff ff       	call   f0100fe6 <pgdir_walk>
f0101b47:	83 c4 10             	add    $0x10,%esp
f0101b4a:	f6 00 02             	testb  $0x2,(%eax)
f0101b4d:	0f 84 0c 09 00 00    	je     f010245f <mem_init+0x1198>
	assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f0101b53:	83 ec 04             	sub    $0x4,%esp
f0101b56:	6a 00                	push   $0x0
f0101b58:	68 00 10 00 00       	push   $0x1000
f0101b5d:	ff 35 c4 1e 24 f0    	pushl  0xf0241ec4
f0101b63:	e8 7e f4 ff ff       	call   f0100fe6 <pgdir_walk>
f0101b68:	83 c4 10             	add    $0x10,%esp
f0101b6b:	f6 00 04             	testb  $0x4,(%eax)
f0101b6e:	0f 85 04 09 00 00    	jne    f0102478 <mem_init+0x11b1>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void *)PTSIZE, PTE_W) < 0);
f0101b74:	6a 02                	push   $0x2
f0101b76:	68 00 00 40 00       	push   $0x400000
f0101b7b:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b7e:	ff 35 c4 1e 24 f0    	pushl  0xf0241ec4
f0101b84:	e8 58 f6 ff ff       	call   f01011e1 <page_insert>
f0101b89:	83 c4 10             	add    $0x10,%esp
f0101b8c:	85 c0                	test   %eax,%eax
f0101b8e:	0f 89 fd 08 00 00    	jns    f0102491 <mem_init+0x11ca>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void *)PGSIZE, PTE_W) == 0);
f0101b94:	6a 02                	push   $0x2
f0101b96:	68 00 10 00 00       	push   $0x1000
f0101b9b:	57                   	push   %edi
f0101b9c:	ff 35 c4 1e 24 f0    	pushl  0xf0241ec4
f0101ba2:	e8 3a f6 ff ff       	call   f01011e1 <page_insert>
f0101ba7:	83 c4 10             	add    $0x10,%esp
f0101baa:	85 c0                	test   %eax,%eax
f0101bac:	0f 85 f8 08 00 00    	jne    f01024aa <mem_init+0x11e3>
	assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f0101bb2:	83 ec 04             	sub    $0x4,%esp
f0101bb5:	6a 00                	push   $0x0
f0101bb7:	68 00 10 00 00       	push   $0x1000
f0101bbc:	ff 35 c4 1e 24 f0    	pushl  0xf0241ec4
f0101bc2:	e8 1f f4 ff ff       	call   f0100fe6 <pgdir_walk>
f0101bc7:	83 c4 10             	add    $0x10,%esp
f0101bca:	f6 00 04             	testb  $0x4,(%eax)
f0101bcd:	0f 85 f0 08 00 00    	jne    f01024c3 <mem_init+0x11fc>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101bd3:	a1 c4 1e 24 f0       	mov    0xf0241ec4,%eax
f0101bd8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101bdb:	ba 00 00 00 00       	mov    $0x0,%edx
f0101be0:	e8 e4 ee ff ff       	call   f0100ac9 <check_va2pa>
f0101be5:	89 fe                	mov    %edi,%esi
f0101be7:	2b 35 c8 1e 24 f0    	sub    0xf0241ec8,%esi
f0101bed:	c1 fe 03             	sar    $0x3,%esi
f0101bf0:	c1 e6 0c             	shl    $0xc,%esi
f0101bf3:	39 f0                	cmp    %esi,%eax
f0101bf5:	0f 85 e1 08 00 00    	jne    f01024dc <mem_init+0x1215>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101bfb:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c00:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c03:	e8 c1 ee ff ff       	call   f0100ac9 <check_va2pa>
f0101c08:	39 c6                	cmp    %eax,%esi
f0101c0a:	0f 85 e5 08 00 00    	jne    f01024f5 <mem_init+0x122e>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101c10:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101c15:	0f 85 f3 08 00 00    	jne    f010250e <mem_init+0x1247>
	assert(pp2->pp_ref == 0);
f0101c1b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101c20:	0f 85 01 09 00 00    	jne    f0102527 <mem_init+0x1260>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101c26:	83 ec 0c             	sub    $0xc,%esp
f0101c29:	6a 00                	push   $0x0
f0101c2b:	e8 d1 f2 ff ff       	call   f0100f01 <page_alloc>
f0101c30:	83 c4 10             	add    $0x10,%esp
f0101c33:	39 c3                	cmp    %eax,%ebx
f0101c35:	0f 85 05 09 00 00    	jne    f0102540 <mem_init+0x1279>
f0101c3b:	85 c0                	test   %eax,%eax
f0101c3d:	0f 84 fd 08 00 00    	je     f0102540 <mem_init+0x1279>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101c43:	83 ec 08             	sub    $0x8,%esp
f0101c46:	6a 00                	push   $0x0
f0101c48:	ff 35 c4 1e 24 f0    	pushl  0xf0241ec4
f0101c4e:	e8 44 f5 ff ff       	call   f0101197 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101c53:	8b 35 c4 1e 24 f0    	mov    0xf0241ec4,%esi
f0101c59:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c5e:	89 f0                	mov    %esi,%eax
f0101c60:	e8 64 ee ff ff       	call   f0100ac9 <check_va2pa>
f0101c65:	83 c4 10             	add    $0x10,%esp
f0101c68:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101c6b:	0f 85 e8 08 00 00    	jne    f0102559 <mem_init+0x1292>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c71:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c76:	89 f0                	mov    %esi,%eax
f0101c78:	e8 4c ee ff ff       	call   f0100ac9 <check_va2pa>
f0101c7d:	89 c2                	mov    %eax,%edx
f0101c7f:	89 f8                	mov    %edi,%eax
f0101c81:	2b 05 c8 1e 24 f0    	sub    0xf0241ec8,%eax
f0101c87:	c1 f8 03             	sar    $0x3,%eax
f0101c8a:	c1 e0 0c             	shl    $0xc,%eax
f0101c8d:	39 c2                	cmp    %eax,%edx
f0101c8f:	0f 85 dd 08 00 00    	jne    f0102572 <mem_init+0x12ab>
	assert(pp1->pp_ref == 1);
f0101c95:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101c9a:	0f 85 eb 08 00 00    	jne    f010258b <mem_init+0x12c4>
	assert(pp2->pp_ref == 0);
f0101ca0:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101ca5:	0f 85 f9 08 00 00    	jne    f01025a4 <mem_init+0x12dd>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void *)PGSIZE, 0) == 0);
f0101cab:	6a 00                	push   $0x0
f0101cad:	68 00 10 00 00       	push   $0x1000
f0101cb2:	57                   	push   %edi
f0101cb3:	56                   	push   %esi
f0101cb4:	e8 28 f5 ff ff       	call   f01011e1 <page_insert>
f0101cb9:	83 c4 10             	add    $0x10,%esp
f0101cbc:	85 c0                	test   %eax,%eax
f0101cbe:	0f 85 f9 08 00 00    	jne    f01025bd <mem_init+0x12f6>
	assert(pp1->pp_ref);
f0101cc4:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101cc9:	0f 84 07 09 00 00    	je     f01025d6 <mem_init+0x130f>
	assert(pp1->pp_link == NULL);
f0101ccf:	83 3f 00             	cmpl   $0x0,(%edi)
f0101cd2:	0f 85 17 09 00 00    	jne    f01025ef <mem_init+0x1328>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void *)PGSIZE);
f0101cd8:	83 ec 08             	sub    $0x8,%esp
f0101cdb:	68 00 10 00 00       	push   $0x1000
f0101ce0:	ff 35 c4 1e 24 f0    	pushl  0xf0241ec4
f0101ce6:	e8 ac f4 ff ff       	call   f0101197 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101ceb:	8b 35 c4 1e 24 f0    	mov    0xf0241ec4,%esi
f0101cf1:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cf6:	89 f0                	mov    %esi,%eax
f0101cf8:	e8 cc ed ff ff       	call   f0100ac9 <check_va2pa>
f0101cfd:	83 c4 10             	add    $0x10,%esp
f0101d00:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d03:	0f 85 ff 08 00 00    	jne    f0102608 <mem_init+0x1341>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101d09:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d0e:	89 f0                	mov    %esi,%eax
f0101d10:	e8 b4 ed ff ff       	call   f0100ac9 <check_va2pa>
f0101d15:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d18:	0f 85 03 09 00 00    	jne    f0102621 <mem_init+0x135a>
	assert(pp1->pp_ref == 0);
f0101d1e:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101d23:	0f 85 11 09 00 00    	jne    f010263a <mem_init+0x1373>
	assert(pp2->pp_ref == 0);
f0101d29:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d2e:	0f 85 1f 09 00 00    	jne    f0102653 <mem_init+0x138c>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101d34:	83 ec 0c             	sub    $0xc,%esp
f0101d37:	6a 00                	push   $0x0
f0101d39:	e8 c3 f1 ff ff       	call   f0100f01 <page_alloc>
f0101d3e:	83 c4 10             	add    $0x10,%esp
f0101d41:	85 c0                	test   %eax,%eax
f0101d43:	0f 84 23 09 00 00    	je     f010266c <mem_init+0x13a5>
f0101d49:	39 c7                	cmp    %eax,%edi
f0101d4b:	0f 85 1b 09 00 00    	jne    f010266c <mem_init+0x13a5>

	// should be no free memory
	assert(!page_alloc(0));
f0101d51:	83 ec 0c             	sub    $0xc,%esp
f0101d54:	6a 00                	push   $0x0
f0101d56:	e8 a6 f1 ff ff       	call   f0100f01 <page_alloc>
f0101d5b:	83 c4 10             	add    $0x10,%esp
f0101d5e:	85 c0                	test   %eax,%eax
f0101d60:	0f 85 1f 09 00 00    	jne    f0102685 <mem_init+0x13be>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d66:	8b 0d c4 1e 24 f0    	mov    0xf0241ec4,%ecx
f0101d6c:	8b 11                	mov    (%ecx),%edx
f0101d6e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101d74:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d77:	2b 05 c8 1e 24 f0    	sub    0xf0241ec8,%eax
f0101d7d:	c1 f8 03             	sar    $0x3,%eax
f0101d80:	c1 e0 0c             	shl    $0xc,%eax
f0101d83:	39 c2                	cmp    %eax,%edx
f0101d85:	0f 85 13 09 00 00    	jne    f010269e <mem_init+0x13d7>
	kern_pgdir[0] = 0;
f0101d8b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101d91:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d94:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101d99:	0f 85 18 09 00 00    	jne    f01026b7 <mem_init+0x13f0>
	pp0->pp_ref = 0;
f0101d9f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101da2:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101da8:	83 ec 0c             	sub    $0xc,%esp
f0101dab:	50                   	push   %eax
f0101dac:	e8 c9 f1 ff ff       	call   f0100f7a <page_free>
	va = (void *)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101db1:	83 c4 0c             	add    $0xc,%esp
f0101db4:	6a 01                	push   $0x1
f0101db6:	68 00 10 40 00       	push   $0x401000
f0101dbb:	ff 35 c4 1e 24 f0    	pushl  0xf0241ec4
f0101dc1:	e8 20 f2 ff ff       	call   f0100fe6 <pgdir_walk>
f0101dc6:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101dc9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *)KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101dcc:	8b 0d c4 1e 24 f0    	mov    0xf0241ec4,%ecx
f0101dd2:	8b 41 04             	mov    0x4(%ecx),%eax
f0101dd5:	89 c6                	mov    %eax,%esi
f0101dd7:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f0101ddd:	8b 15 c0 1e 24 f0    	mov    0xf0241ec0,%edx
f0101de3:	c1 e8 0c             	shr    $0xc,%eax
f0101de6:	83 c4 10             	add    $0x10,%esp
f0101de9:	39 d0                	cmp    %edx,%eax
f0101deb:	0f 83 df 08 00 00    	jae    f01026d0 <mem_init+0x1409>
	assert(ptep == ptep1 + PTX(va));
f0101df1:	81 ee fc ff ff 0f    	sub    $0xffffffc,%esi
f0101df7:	39 75 d0             	cmp    %esi,-0x30(%ebp)
f0101dfa:	0f 85 e5 08 00 00    	jne    f01026e5 <mem_init+0x141e>
	kern_pgdir[PDX(va)] = 0;
f0101e00:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0101e07:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e0a:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101e10:	2b 05 c8 1e 24 f0    	sub    0xf0241ec8,%eax
f0101e16:	c1 f8 03             	sar    $0x3,%eax
f0101e19:	89 c1                	mov    %eax,%ecx
f0101e1b:	c1 e1 0c             	shl    $0xc,%ecx
	if (PGNUM(pa) >= npages)
f0101e1e:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101e23:	39 c2                	cmp    %eax,%edx
f0101e25:	0f 86 d3 08 00 00    	jbe    f01026fe <mem_init+0x1437>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101e2b:	83 ec 04             	sub    $0x4,%esp
f0101e2e:	68 00 10 00 00       	push   $0x1000
f0101e33:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101e38:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0101e3e:	51                   	push   %ecx
f0101e3f:	e8 1f 3d 00 00       	call   f0105b63 <memset>
	page_free(pp0);
f0101e44:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101e47:	89 34 24             	mov    %esi,(%esp)
f0101e4a:	e8 2b f1 ff ff       	call   f0100f7a <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101e4f:	83 c4 0c             	add    $0xc,%esp
f0101e52:	6a 01                	push   $0x1
f0101e54:	6a 00                	push   $0x0
f0101e56:	ff 35 c4 1e 24 f0    	pushl  0xf0241ec4
f0101e5c:	e8 85 f1 ff ff       	call   f0100fe6 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101e61:	89 f0                	mov    %esi,%eax
f0101e63:	2b 05 c8 1e 24 f0    	sub    0xf0241ec8,%eax
f0101e69:	c1 f8 03             	sar    $0x3,%eax
f0101e6c:	89 c2                	mov    %eax,%edx
f0101e6e:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101e71:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101e76:	83 c4 10             	add    $0x10,%esp
f0101e79:	3b 05 c0 1e 24 f0    	cmp    0xf0241ec0,%eax
f0101e7f:	0f 83 8b 08 00 00    	jae    f0102710 <mem_init+0x1449>
	return (void *)(pa + KERNBASE);
f0101e85:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *)page2kva(pp0);
f0101e8b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101e8e:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for (i = 0; i < NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101e94:	f6 00 01             	testb  $0x1,(%eax)
f0101e97:	0f 85 85 08 00 00    	jne    f0102722 <mem_init+0x145b>
f0101e9d:	83 c0 04             	add    $0x4,%eax
	for (i = 0; i < NPTENTRIES; i++)
f0101ea0:	39 d0                	cmp    %edx,%eax
f0101ea2:	75 f0                	jne    f0101e94 <mem_init+0xbcd>
	kern_pgdir[0] = 0;
f0101ea4:	a1 c4 1e 24 f0       	mov    0xf0241ec4,%eax
f0101ea9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101eaf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101eb2:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101eb8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101ebb:	89 0d 40 f2 23 f0    	mov    %ecx,0xf023f240

	// free the pages we took
	page_free(pp0);
f0101ec1:	83 ec 0c             	sub    $0xc,%esp
f0101ec4:	50                   	push   %eax
f0101ec5:	e8 b0 f0 ff ff       	call   f0100f7a <page_free>
	page_free(pp1);
f0101eca:	89 3c 24             	mov    %edi,(%esp)
f0101ecd:	e8 a8 f0 ff ff       	call   f0100f7a <page_free>
	page_free(pp2);
f0101ed2:	89 1c 24             	mov    %ebx,(%esp)
f0101ed5:	e8 a0 f0 ff ff       	call   f0100f7a <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t)mmio_map_region(0, 4097);
f0101eda:	83 c4 08             	add    $0x8,%esp
f0101edd:	68 01 10 00 00       	push   $0x1001
f0101ee2:	6a 00                	push   $0x0
f0101ee4:	e8 62 f3 ff ff       	call   f010124b <mmio_map_region>
f0101ee9:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t)mmio_map_region(0, 4096);
f0101eeb:	83 c4 08             	add    $0x8,%esp
f0101eee:	68 00 10 00 00       	push   $0x1000
f0101ef3:	6a 00                	push   $0x0
f0101ef5:	e8 51 f3 ff ff       	call   f010124b <mmio_map_region>
f0101efa:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0101efc:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0101f02:	83 c4 10             	add    $0x10,%esp
f0101f05:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0101f0b:	0f 86 2a 08 00 00    	jbe    f010273b <mem_init+0x1474>
f0101f11:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101f16:	0f 87 1f 08 00 00    	ja     f010273b <mem_init+0x1474>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0101f1c:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0101f22:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0101f28:	0f 87 26 08 00 00    	ja     f0102754 <mem_init+0x148d>
f0101f2e:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0101f34:	0f 86 1a 08 00 00    	jbe    f0102754 <mem_init+0x148d>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0101f3a:	89 da                	mov    %ebx,%edx
f0101f3c:	09 f2                	or     %esi,%edx
f0101f3e:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0101f44:	0f 85 23 08 00 00    	jne    f010276d <mem_init+0x14a6>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f0101f4a:	39 c6                	cmp    %eax,%esi
f0101f4c:	0f 82 34 08 00 00    	jb     f0102786 <mem_init+0x14bf>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0101f52:	8b 3d c4 1e 24 f0    	mov    0xf0241ec4,%edi
f0101f58:	89 da                	mov    %ebx,%edx
f0101f5a:	89 f8                	mov    %edi,%eax
f0101f5c:	e8 68 eb ff ff       	call   f0100ac9 <check_va2pa>
f0101f61:	85 c0                	test   %eax,%eax
f0101f63:	0f 85 36 08 00 00    	jne    f010279f <mem_init+0x14d8>
	assert(check_va2pa(kern_pgdir, mm1 + PGSIZE) == PGSIZE);
f0101f69:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0101f6f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f72:	89 c2                	mov    %eax,%edx
f0101f74:	89 f8                	mov    %edi,%eax
f0101f76:	e8 4e eb ff ff       	call   f0100ac9 <check_va2pa>
f0101f7b:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0101f80:	0f 85 32 08 00 00    	jne    f01027b8 <mem_init+0x14f1>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0101f86:	89 f2                	mov    %esi,%edx
f0101f88:	89 f8                	mov    %edi,%eax
f0101f8a:	e8 3a eb ff ff       	call   f0100ac9 <check_va2pa>
f0101f8f:	85 c0                	test   %eax,%eax
f0101f91:	0f 85 3a 08 00 00    	jne    f01027d1 <mem_init+0x150a>
	assert(check_va2pa(kern_pgdir, mm2 + PGSIZE) == ~0);
f0101f97:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0101f9d:	89 f8                	mov    %edi,%eax
f0101f9f:	e8 25 eb ff ff       	call   f0100ac9 <check_va2pa>
f0101fa4:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fa7:	0f 85 3d 08 00 00    	jne    f01027ea <mem_init+0x1523>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void *)mm1, 0) & (PTE_W | PTE_PWT | PTE_PCD));
f0101fad:	83 ec 04             	sub    $0x4,%esp
f0101fb0:	6a 00                	push   $0x0
f0101fb2:	53                   	push   %ebx
f0101fb3:	57                   	push   %edi
f0101fb4:	e8 2d f0 ff ff       	call   f0100fe6 <pgdir_walk>
f0101fb9:	83 c4 10             	add    $0x10,%esp
f0101fbc:	f6 00 1a             	testb  $0x1a,(%eax)
f0101fbf:	0f 84 3e 08 00 00    	je     f0102803 <mem_init+0x153c>
	assert(!(*pgdir_walk(kern_pgdir, (void *)mm1, 0) & PTE_U));
f0101fc5:	83 ec 04             	sub    $0x4,%esp
f0101fc8:	6a 00                	push   $0x0
f0101fca:	53                   	push   %ebx
f0101fcb:	ff 35 c4 1e 24 f0    	pushl  0xf0241ec4
f0101fd1:	e8 10 f0 ff ff       	call   f0100fe6 <pgdir_walk>
f0101fd6:	8b 00                	mov    (%eax),%eax
f0101fd8:	83 c4 10             	add    $0x10,%esp
f0101fdb:	83 e0 04             	and    $0x4,%eax
f0101fde:	89 c7                	mov    %eax,%edi
f0101fe0:	0f 85 36 08 00 00    	jne    f010281c <mem_init+0x1555>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void *)mm1, 0) = 0;
f0101fe6:	83 ec 04             	sub    $0x4,%esp
f0101fe9:	6a 00                	push   $0x0
f0101feb:	53                   	push   %ebx
f0101fec:	ff 35 c4 1e 24 f0    	pushl  0xf0241ec4
f0101ff2:	e8 ef ef ff ff       	call   f0100fe6 <pgdir_walk>
f0101ff7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void *)mm1 + PGSIZE, 0) = 0;
f0101ffd:	83 c4 0c             	add    $0xc,%esp
f0102000:	6a 00                	push   $0x0
f0102002:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102005:	ff 35 c4 1e 24 f0    	pushl  0xf0241ec4
f010200b:	e8 d6 ef ff ff       	call   f0100fe6 <pgdir_walk>
f0102010:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void *)mm2, 0) = 0;
f0102016:	83 c4 0c             	add    $0xc,%esp
f0102019:	6a 00                	push   $0x0
f010201b:	56                   	push   %esi
f010201c:	ff 35 c4 1e 24 f0    	pushl  0xf0241ec4
f0102022:	e8 bf ef ff ff       	call   f0100fe6 <pgdir_walk>
f0102027:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f010202d:	c7 04 24 e9 79 10 f0 	movl   $0xf01079e9,(%esp)
f0102034:	e8 90 1a 00 00       	call   f0103ac9 <cprintf>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f0102039:	a1 c8 1e 24 f0       	mov    0xf0241ec8,%eax
	if ((uint32_t)kva < KERNBASE)
f010203e:	83 c4 10             	add    $0x10,%esp
f0102041:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102046:	0f 86 e9 07 00 00    	jbe    f0102835 <mem_init+0x156e>
f010204c:	83 ec 08             	sub    $0x8,%esp
f010204f:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102051:	05 00 00 00 10       	add    $0x10000000,%eax
f0102056:	50                   	push   %eax
f0102057:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010205c:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102061:	a1 c4 1e 24 f0       	mov    0xf0241ec4,%eax
f0102066:	e8 0c f0 ff ff       	call   f0101077 <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f010206b:	a1 44 f2 23 f0       	mov    0xf023f244,%eax
	if ((uint32_t)kva < KERNBASE)
f0102070:	83 c4 10             	add    $0x10,%esp
f0102073:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102078:	0f 86 cc 07 00 00    	jbe    f010284a <mem_init+0x1583>
f010207e:	83 ec 08             	sub    $0x8,%esp
f0102081:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102083:	05 00 00 00 10       	add    $0x10000000,%eax
f0102088:	50                   	push   %eax
f0102089:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010208e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102093:	a1 c4 1e 24 f0       	mov    0xf0241ec4,%eax
f0102098:	e8 da ef ff ff       	call   f0101077 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f010209d:	83 c4 10             	add    $0x10,%esp
f01020a0:	b8 00 a0 11 f0       	mov    $0xf011a000,%eax
f01020a5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020aa:	0f 86 af 07 00 00    	jbe    f010285f <mem_init+0x1598>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01020b0:	83 ec 08             	sub    $0x8,%esp
f01020b3:	6a 02                	push   $0x2
f01020b5:	68 00 a0 11 00       	push   $0x11a000
f01020ba:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01020bf:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01020c4:	a1 c4 1e 24 f0       	mov    0xf0241ec4,%eax
f01020c9:	e8 a9 ef ff ff       	call   f0101077 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_W);
f01020ce:	83 c4 08             	add    $0x8,%esp
f01020d1:	6a 02                	push   $0x2
f01020d3:	6a 00                	push   $0x0
f01020d5:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f01020da:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01020df:	a1 c4 1e 24 f0       	mov    0xf0241ec4,%eax
f01020e4:	e8 8e ef ff ff       	call   f0101077 <boot_map_region>
f01020e9:	c7 45 d0 00 30 24 f0 	movl   $0xf0243000,-0x30(%ebp)
f01020f0:	83 c4 10             	add    $0x10,%esp
f01020f3:	bb 00 30 24 f0       	mov    $0xf0243000,%ebx
f01020f8:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f01020fd:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102103:	0f 86 6b 07 00 00    	jbe    f0102874 <mem_init+0x15ad>
		boot_map_region(kern_pgdir,
f0102109:	83 ec 08             	sub    $0x8,%esp
f010210c:	6a 02                	push   $0x2
f010210e:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102114:	50                   	push   %eax
f0102115:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010211a:	89 f2                	mov    %esi,%edx
f010211c:	a1 c4 1e 24 f0       	mov    0xf0241ec4,%eax
f0102121:	e8 51 ef ff ff       	call   f0101077 <boot_map_region>
f0102126:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f010212c:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	for (int i = 0; i < NCPU; i++)
f0102132:	83 c4 10             	add    $0x10,%esp
f0102135:	81 fb 00 30 28 f0    	cmp    $0xf0283000,%ebx
f010213b:	75 c0                	jne    f01020fd <mem_init+0xe36>
	pgdir = kern_pgdir;
f010213d:	a1 c4 1e 24 f0       	mov    0xf0241ec4,%eax
f0102142:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	n = ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE);
f0102145:	a1 c0 1e 24 f0       	mov    0xf0241ec0,%eax
f010214a:	89 45 c0             	mov    %eax,-0x40(%ebp)
f010214d:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102154:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102159:	89 45 cc             	mov    %eax,-0x34(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010215c:	8b 35 c8 1e 24 f0    	mov    0xf0241ec8,%esi
f0102162:	89 75 c8             	mov    %esi,-0x38(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0102165:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f010216b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f010216e:	89 fb                	mov    %edi,%ebx
f0102170:	e9 2f 07 00 00       	jmp    f01028a4 <mem_init+0x15dd>
	assert(nfree == 0);
f0102175:	68 00 79 10 f0       	push   $0xf0107900
f010217a:	68 8b 77 10 f0       	push   $0xf010778b
f010217f:	68 4c 03 00 00       	push   $0x34c
f0102184:	68 65 77 10 f0       	push   $0xf0107765
f0102189:	e8 b2 de ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f010218e:	68 65 78 10 f0       	push   $0xf0107865
f0102193:	68 8b 77 10 f0       	push   $0xf010778b
f0102198:	68 b5 03 00 00       	push   $0x3b5
f010219d:	68 65 77 10 f0       	push   $0xf0107765
f01021a2:	e8 99 de ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01021a7:	68 7b 78 10 f0       	push   $0xf010787b
f01021ac:	68 8b 77 10 f0       	push   $0xf010778b
f01021b1:	68 b6 03 00 00       	push   $0x3b6
f01021b6:	68 65 77 10 f0       	push   $0xf0107765
f01021bb:	e8 80 de ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01021c0:	68 91 78 10 f0       	push   $0xf0107891
f01021c5:	68 8b 77 10 f0       	push   $0xf010778b
f01021ca:	68 b7 03 00 00       	push   $0x3b7
f01021cf:	68 65 77 10 f0       	push   $0xf0107765
f01021d4:	e8 67 de ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f01021d9:	68 a7 78 10 f0       	push   $0xf01078a7
f01021de:	68 8b 77 10 f0       	push   $0xf010778b
f01021e3:	68 ba 03 00 00       	push   $0x3ba
f01021e8:	68 65 77 10 f0       	push   $0xf0107765
f01021ed:	e8 4e de ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01021f2:	68 24 6f 10 f0       	push   $0xf0106f24
f01021f7:	68 8b 77 10 f0       	push   $0xf010778b
f01021fc:	68 bb 03 00 00       	push   $0x3bb
f0102201:	68 65 77 10 f0       	push   $0xf0107765
f0102206:	e8 35 de ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010220b:	68 b9 78 10 f0       	push   $0xf01078b9
f0102210:	68 8b 77 10 f0       	push   $0xf010778b
f0102215:	68 c2 03 00 00       	push   $0x3c2
f010221a:	68 65 77 10 f0       	push   $0xf0107765
f010221f:	e8 1c de ff ff       	call   f0100040 <_panic>
	assert(page_lookup(kern_pgdir, (void *)0x0, &ptep) == NULL);
f0102224:	68 c4 6f 10 f0       	push   $0xf0106fc4
f0102229:	68 8b 77 10 f0       	push   $0xf010778b
f010222e:	68 c5 03 00 00       	push   $0x3c5
f0102233:	68 65 77 10 f0       	push   $0xf0107765
f0102238:	e8 03 de ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010223d:	68 f8 6f 10 f0       	push   $0xf0106ff8
f0102242:	68 8b 77 10 f0       	push   $0xf010778b
f0102247:	68 c8 03 00 00       	push   $0x3c8
f010224c:	68 65 77 10 f0       	push   $0xf0107765
f0102251:	e8 ea dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102256:	68 28 70 10 f0       	push   $0xf0107028
f010225b:	68 8b 77 10 f0       	push   $0xf010778b
f0102260:	68 cc 03 00 00       	push   $0x3cc
f0102265:	68 65 77 10 f0       	push   $0xf0107765
f010226a:	e8 d1 dd ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010226f:	68 58 70 10 f0       	push   $0xf0107058
f0102274:	68 8b 77 10 f0       	push   $0xf010778b
f0102279:	68 cd 03 00 00       	push   $0x3cd
f010227e:	68 65 77 10 f0       	push   $0xf0107765
f0102283:	e8 b8 dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102288:	68 80 70 10 f0       	push   $0xf0107080
f010228d:	68 8b 77 10 f0       	push   $0xf010778b
f0102292:	68 ce 03 00 00       	push   $0x3ce
f0102297:	68 65 77 10 f0       	push   $0xf0107765
f010229c:	e8 9f dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01022a1:	68 0b 79 10 f0       	push   $0xf010790b
f01022a6:	68 8b 77 10 f0       	push   $0xf010778b
f01022ab:	68 cf 03 00 00       	push   $0x3cf
f01022b0:	68 65 77 10 f0       	push   $0xf0107765
f01022b5:	e8 86 dd ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01022ba:	68 1c 79 10 f0       	push   $0xf010791c
f01022bf:	68 8b 77 10 f0       	push   $0xf010778b
f01022c4:	68 d0 03 00 00       	push   $0x3d0
f01022c9:	68 65 77 10 f0       	push   $0xf0107765
f01022ce:	e8 6d dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f01022d3:	68 b0 70 10 f0       	push   $0xf01070b0
f01022d8:	68 8b 77 10 f0       	push   $0xf010778b
f01022dd:	68 d3 03 00 00       	push   $0x3d3
f01022e2:	68 65 77 10 f0       	push   $0xf0107765
f01022e7:	e8 54 dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01022ec:	68 ec 70 10 f0       	push   $0xf01070ec
f01022f1:	68 8b 77 10 f0       	push   $0xf010778b
f01022f6:	68 d4 03 00 00       	push   $0x3d4
f01022fb:	68 65 77 10 f0       	push   $0xf0107765
f0102300:	e8 3b dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102305:	68 2d 79 10 f0       	push   $0xf010792d
f010230a:	68 8b 77 10 f0       	push   $0xf010778b
f010230f:	68 d5 03 00 00       	push   $0x3d5
f0102314:	68 65 77 10 f0       	push   $0xf0107765
f0102319:	e8 22 dd ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010231e:	68 b9 78 10 f0       	push   $0xf01078b9
f0102323:	68 8b 77 10 f0       	push   $0xf010778b
f0102328:	68 d8 03 00 00       	push   $0x3d8
f010232d:	68 65 77 10 f0       	push   $0xf0107765
f0102332:	e8 09 dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f0102337:	68 b0 70 10 f0       	push   $0xf01070b0
f010233c:	68 8b 77 10 f0       	push   $0xf010778b
f0102341:	68 db 03 00 00       	push   $0x3db
f0102346:	68 65 77 10 f0       	push   $0xf0107765
f010234b:	e8 f0 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102350:	68 ec 70 10 f0       	push   $0xf01070ec
f0102355:	68 8b 77 10 f0       	push   $0xf010778b
f010235a:	68 dc 03 00 00       	push   $0x3dc
f010235f:	68 65 77 10 f0       	push   $0xf0107765
f0102364:	e8 d7 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102369:	68 2d 79 10 f0       	push   $0xf010792d
f010236e:	68 8b 77 10 f0       	push   $0xf010778b
f0102373:	68 dd 03 00 00       	push   $0x3dd
f0102378:	68 65 77 10 f0       	push   $0xf0107765
f010237d:	e8 be dc ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102382:	68 b9 78 10 f0       	push   $0xf01078b9
f0102387:	68 8b 77 10 f0       	push   $0xf010778b
f010238c:	68 e1 03 00 00       	push   $0x3e1
f0102391:	68 65 77 10 f0       	push   $0xf0107765
f0102396:	e8 a5 dc ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010239b:	52                   	push   %edx
f010239c:	68 24 68 10 f0       	push   $0xf0106824
f01023a1:	68 e4 03 00 00       	push   $0x3e4
f01023a6:	68 65 77 10 f0       	push   $0xf0107765
f01023ab:	e8 90 dc ff ff       	call   f0100040 <_panic>
	assert(pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) == ptep + PTX(PGSIZE));
f01023b0:	68 1c 71 10 f0       	push   $0xf010711c
f01023b5:	68 8b 77 10 f0       	push   $0xf010778b
f01023ba:	68 e5 03 00 00       	push   $0x3e5
f01023bf:	68 65 77 10 f0       	push   $0xf0107765
f01023c4:	e8 77 dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W | PTE_U) == 0);
f01023c9:	68 5c 71 10 f0       	push   $0xf010715c
f01023ce:	68 8b 77 10 f0       	push   $0xf010778b
f01023d3:	68 e8 03 00 00       	push   $0x3e8
f01023d8:	68 65 77 10 f0       	push   $0xf0107765
f01023dd:	e8 5e dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023e2:	68 ec 70 10 f0       	push   $0xf01070ec
f01023e7:	68 8b 77 10 f0       	push   $0xf010778b
f01023ec:	68 e9 03 00 00       	push   $0x3e9
f01023f1:	68 65 77 10 f0       	push   $0xf0107765
f01023f6:	e8 45 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01023fb:	68 2d 79 10 f0       	push   $0xf010792d
f0102400:	68 8b 77 10 f0       	push   $0xf010778b
f0102405:	68 ea 03 00 00       	push   $0x3ea
f010240a:	68 65 77 10 f0       	push   $0xf0107765
f010240f:	e8 2c dc ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U);
f0102414:	68 a0 71 10 f0       	push   $0xf01071a0
f0102419:	68 8b 77 10 f0       	push   $0xf010778b
f010241e:	68 eb 03 00 00       	push   $0x3eb
f0102423:	68 65 77 10 f0       	push   $0xf0107765
f0102428:	e8 13 dc ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010242d:	68 3e 79 10 f0       	push   $0xf010793e
f0102432:	68 8b 77 10 f0       	push   $0xf010778b
f0102437:	68 ec 03 00 00       	push   $0x3ec
f010243c:	68 65 77 10 f0       	push   $0xf0107765
f0102441:	e8 fa db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f0102446:	68 b0 70 10 f0       	push   $0xf01070b0
f010244b:	68 8b 77 10 f0       	push   $0xf010778b
f0102450:	68 ef 03 00 00       	push   $0x3ef
f0102455:	68 65 77 10 f0       	push   $0xf0107765
f010245a:	e8 e1 db ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_W);
f010245f:	68 d4 71 10 f0       	push   $0xf01071d4
f0102464:	68 8b 77 10 f0       	push   $0xf010778b
f0102469:	68 f0 03 00 00       	push   $0x3f0
f010246e:	68 65 77 10 f0       	push   $0xf0107765
f0102473:	e8 c8 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f0102478:	68 08 72 10 f0       	push   $0xf0107208
f010247d:	68 8b 77 10 f0       	push   $0xf010778b
f0102482:	68 f1 03 00 00       	push   $0x3f1
f0102487:	68 65 77 10 f0       	push   $0xf0107765
f010248c:	e8 af db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void *)PTSIZE, PTE_W) < 0);
f0102491:	68 40 72 10 f0       	push   $0xf0107240
f0102496:	68 8b 77 10 f0       	push   $0xf010778b
f010249b:	68 f4 03 00 00       	push   $0x3f4
f01024a0:	68 65 77 10 f0       	push   $0xf0107765
f01024a5:	e8 96 db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void *)PGSIZE, PTE_W) == 0);
f01024aa:	68 78 72 10 f0       	push   $0xf0107278
f01024af:	68 8b 77 10 f0       	push   $0xf010778b
f01024b4:	68 f7 03 00 00       	push   $0x3f7
f01024b9:	68 65 77 10 f0       	push   $0xf0107765
f01024be:	e8 7d db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f01024c3:	68 08 72 10 f0       	push   $0xf0107208
f01024c8:	68 8b 77 10 f0       	push   $0xf010778b
f01024cd:	68 f8 03 00 00       	push   $0x3f8
f01024d2:	68 65 77 10 f0       	push   $0xf0107765
f01024d7:	e8 64 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01024dc:	68 b4 72 10 f0       	push   $0xf01072b4
f01024e1:	68 8b 77 10 f0       	push   $0xf010778b
f01024e6:	68 fb 03 00 00       	push   $0x3fb
f01024eb:	68 65 77 10 f0       	push   $0xf0107765
f01024f0:	e8 4b db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01024f5:	68 e0 72 10 f0       	push   $0xf01072e0
f01024fa:	68 8b 77 10 f0       	push   $0xf010778b
f01024ff:	68 fc 03 00 00       	push   $0x3fc
f0102504:	68 65 77 10 f0       	push   $0xf0107765
f0102509:	e8 32 db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 2);
f010250e:	68 54 79 10 f0       	push   $0xf0107954
f0102513:	68 8b 77 10 f0       	push   $0xf010778b
f0102518:	68 fe 03 00 00       	push   $0x3fe
f010251d:	68 65 77 10 f0       	push   $0xf0107765
f0102522:	e8 19 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102527:	68 65 79 10 f0       	push   $0xf0107965
f010252c:	68 8b 77 10 f0       	push   $0xf010778b
f0102531:	68 ff 03 00 00       	push   $0x3ff
f0102536:	68 65 77 10 f0       	push   $0xf0107765
f010253b:	e8 00 db ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102540:	68 10 73 10 f0       	push   $0xf0107310
f0102545:	68 8b 77 10 f0       	push   $0xf010778b
f010254a:	68 02 04 00 00       	push   $0x402
f010254f:	68 65 77 10 f0       	push   $0xf0107765
f0102554:	e8 e7 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102559:	68 34 73 10 f0       	push   $0xf0107334
f010255e:	68 8b 77 10 f0       	push   $0xf010778b
f0102563:	68 06 04 00 00       	push   $0x406
f0102568:	68 65 77 10 f0       	push   $0xf0107765
f010256d:	e8 ce da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102572:	68 e0 72 10 f0       	push   $0xf01072e0
f0102577:	68 8b 77 10 f0       	push   $0xf010778b
f010257c:	68 07 04 00 00       	push   $0x407
f0102581:	68 65 77 10 f0       	push   $0xf0107765
f0102586:	e8 b5 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010258b:	68 0b 79 10 f0       	push   $0xf010790b
f0102590:	68 8b 77 10 f0       	push   $0xf010778b
f0102595:	68 08 04 00 00       	push   $0x408
f010259a:	68 65 77 10 f0       	push   $0xf0107765
f010259f:	e8 9c da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01025a4:	68 65 79 10 f0       	push   $0xf0107965
f01025a9:	68 8b 77 10 f0       	push   $0xf010778b
f01025ae:	68 09 04 00 00       	push   $0x409
f01025b3:	68 65 77 10 f0       	push   $0xf0107765
f01025b8:	e8 83 da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void *)PGSIZE, 0) == 0);
f01025bd:	68 58 73 10 f0       	push   $0xf0107358
f01025c2:	68 8b 77 10 f0       	push   $0xf010778b
f01025c7:	68 0c 04 00 00       	push   $0x40c
f01025cc:	68 65 77 10 f0       	push   $0xf0107765
f01025d1:	e8 6a da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01025d6:	68 76 79 10 f0       	push   $0xf0107976
f01025db:	68 8b 77 10 f0       	push   $0xf010778b
f01025e0:	68 0d 04 00 00       	push   $0x40d
f01025e5:	68 65 77 10 f0       	push   $0xf0107765
f01025ea:	e8 51 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f01025ef:	68 82 79 10 f0       	push   $0xf0107982
f01025f4:	68 8b 77 10 f0       	push   $0xf010778b
f01025f9:	68 0e 04 00 00       	push   $0x40e
f01025fe:	68 65 77 10 f0       	push   $0xf0107765
f0102603:	e8 38 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102608:	68 34 73 10 f0       	push   $0xf0107334
f010260d:	68 8b 77 10 f0       	push   $0xf010778b
f0102612:	68 12 04 00 00       	push   $0x412
f0102617:	68 65 77 10 f0       	push   $0xf0107765
f010261c:	e8 1f da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102621:	68 90 73 10 f0       	push   $0xf0107390
f0102626:	68 8b 77 10 f0       	push   $0xf010778b
f010262b:	68 13 04 00 00       	push   $0x413
f0102630:	68 65 77 10 f0       	push   $0xf0107765
f0102635:	e8 06 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010263a:	68 97 79 10 f0       	push   $0xf0107997
f010263f:	68 8b 77 10 f0       	push   $0xf010778b
f0102644:	68 14 04 00 00       	push   $0x414
f0102649:	68 65 77 10 f0       	push   $0xf0107765
f010264e:	e8 ed d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102653:	68 65 79 10 f0       	push   $0xf0107965
f0102658:	68 8b 77 10 f0       	push   $0xf010778b
f010265d:	68 15 04 00 00       	push   $0x415
f0102662:	68 65 77 10 f0       	push   $0xf0107765
f0102667:	e8 d4 d9 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f010266c:	68 b8 73 10 f0       	push   $0xf01073b8
f0102671:	68 8b 77 10 f0       	push   $0xf010778b
f0102676:	68 18 04 00 00       	push   $0x418
f010267b:	68 65 77 10 f0       	push   $0xf0107765
f0102680:	e8 bb d9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102685:	68 b9 78 10 f0       	push   $0xf01078b9
f010268a:	68 8b 77 10 f0       	push   $0xf010778b
f010268f:	68 1b 04 00 00       	push   $0x41b
f0102694:	68 65 77 10 f0       	push   $0xf0107765
f0102699:	e8 a2 d9 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010269e:	68 58 70 10 f0       	push   $0xf0107058
f01026a3:	68 8b 77 10 f0       	push   $0xf010778b
f01026a8:	68 1e 04 00 00       	push   $0x41e
f01026ad:	68 65 77 10 f0       	push   $0xf0107765
f01026b2:	e8 89 d9 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01026b7:	68 1c 79 10 f0       	push   $0xf010791c
f01026bc:	68 8b 77 10 f0       	push   $0xf010778b
f01026c1:	68 20 04 00 00       	push   $0x420
f01026c6:	68 65 77 10 f0       	push   $0xf0107765
f01026cb:	e8 70 d9 ff ff       	call   f0100040 <_panic>
f01026d0:	56                   	push   %esi
f01026d1:	68 24 68 10 f0       	push   $0xf0106824
f01026d6:	68 27 04 00 00       	push   $0x427
f01026db:	68 65 77 10 f0       	push   $0xf0107765
f01026e0:	e8 5b d9 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01026e5:	68 a8 79 10 f0       	push   $0xf01079a8
f01026ea:	68 8b 77 10 f0       	push   $0xf010778b
f01026ef:	68 28 04 00 00       	push   $0x428
f01026f4:	68 65 77 10 f0       	push   $0xf0107765
f01026f9:	e8 42 d9 ff ff       	call   f0100040 <_panic>
f01026fe:	51                   	push   %ecx
f01026ff:	68 24 68 10 f0       	push   $0xf0106824
f0102704:	6a 58                	push   $0x58
f0102706:	68 71 77 10 f0       	push   $0xf0107771
f010270b:	e8 30 d9 ff ff       	call   f0100040 <_panic>
f0102710:	52                   	push   %edx
f0102711:	68 24 68 10 f0       	push   $0xf0106824
f0102716:	6a 58                	push   $0x58
f0102718:	68 71 77 10 f0       	push   $0xf0107771
f010271d:	e8 1e d9 ff ff       	call   f0100040 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102722:	68 c0 79 10 f0       	push   $0xf01079c0
f0102727:	68 8b 77 10 f0       	push   $0xf010778b
f010272c:	68 32 04 00 00       	push   $0x432
f0102731:	68 65 77 10 f0       	push   $0xf0107765
f0102736:	e8 05 d9 ff ff       	call   f0100040 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f010273b:	68 dc 73 10 f0       	push   $0xf01073dc
f0102740:	68 8b 77 10 f0       	push   $0xf010778b
f0102745:	68 42 04 00 00       	push   $0x442
f010274a:	68 65 77 10 f0       	push   $0xf0107765
f010274f:	e8 ec d8 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0102754:	68 04 74 10 f0       	push   $0xf0107404
f0102759:	68 8b 77 10 f0       	push   $0xf010778b
f010275e:	68 43 04 00 00       	push   $0x443
f0102763:	68 65 77 10 f0       	push   $0xf0107765
f0102768:	e8 d3 d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f010276d:	68 2c 74 10 f0       	push   $0xf010742c
f0102772:	68 8b 77 10 f0       	push   $0xf010778b
f0102777:	68 45 04 00 00       	push   $0x445
f010277c:	68 65 77 10 f0       	push   $0xf0107765
f0102781:	e8 ba d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 + 8192 <= mm2);
f0102786:	68 d7 79 10 f0       	push   $0xf01079d7
f010278b:	68 8b 77 10 f0       	push   $0xf010778b
f0102790:	68 47 04 00 00       	push   $0x447
f0102795:	68 65 77 10 f0       	push   $0xf0107765
f010279a:	e8 a1 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f010279f:	68 54 74 10 f0       	push   $0xf0107454
f01027a4:	68 8b 77 10 f0       	push   $0xf010778b
f01027a9:	68 49 04 00 00       	push   $0x449
f01027ae:	68 65 77 10 f0       	push   $0xf0107765
f01027b3:	e8 88 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1 + PGSIZE) == PGSIZE);
f01027b8:	68 78 74 10 f0       	push   $0xf0107478
f01027bd:	68 8b 77 10 f0       	push   $0xf010778b
f01027c2:	68 4a 04 00 00       	push   $0x44a
f01027c7:	68 65 77 10 f0       	push   $0xf0107765
f01027cc:	e8 6f d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01027d1:	68 a8 74 10 f0       	push   $0xf01074a8
f01027d6:	68 8b 77 10 f0       	push   $0xf010778b
f01027db:	68 4b 04 00 00       	push   $0x44b
f01027e0:	68 65 77 10 f0       	push   $0xf0107765
f01027e5:	e8 56 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2 + PGSIZE) == ~0);
f01027ea:	68 cc 74 10 f0       	push   $0xf01074cc
f01027ef:	68 8b 77 10 f0       	push   $0xf010778b
f01027f4:	68 4c 04 00 00       	push   $0x44c
f01027f9:	68 65 77 10 f0       	push   $0xf0107765
f01027fe:	e8 3d d8 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void *)mm1, 0) & (PTE_W | PTE_PWT | PTE_PCD));
f0102803:	68 f8 74 10 f0       	push   $0xf01074f8
f0102808:	68 8b 77 10 f0       	push   $0xf010778b
f010280d:	68 4e 04 00 00       	push   $0x44e
f0102812:	68 65 77 10 f0       	push   $0xf0107765
f0102817:	e8 24 d8 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *)mm1, 0) & PTE_U));
f010281c:	68 40 75 10 f0       	push   $0xf0107540
f0102821:	68 8b 77 10 f0       	push   $0xf010778b
f0102826:	68 4f 04 00 00       	push   $0x44f
f010282b:	68 65 77 10 f0       	push   $0xf0107765
f0102830:	e8 0b d8 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102835:	50                   	push   %eax
f0102836:	68 48 68 10 f0       	push   $0xf0106848
f010283b:	68 b9 00 00 00       	push   $0xb9
f0102840:	68 65 77 10 f0       	push   $0xf0107765
f0102845:	e8 f6 d7 ff ff       	call   f0100040 <_panic>
f010284a:	50                   	push   %eax
f010284b:	68 48 68 10 f0       	push   $0xf0106848
f0102850:	68 c2 00 00 00       	push   $0xc2
f0102855:	68 65 77 10 f0       	push   $0xf0107765
f010285a:	e8 e1 d7 ff ff       	call   f0100040 <_panic>
f010285f:	50                   	push   %eax
f0102860:	68 48 68 10 f0       	push   $0xf0106848
f0102865:	68 d0 00 00 00       	push   $0xd0
f010286a:	68 65 77 10 f0       	push   $0xf0107765
f010286f:	e8 cc d7 ff ff       	call   f0100040 <_panic>
f0102874:	53                   	push   %ebx
f0102875:	68 48 68 10 f0       	push   $0xf0106848
f010287a:	68 13 01 00 00       	push   $0x113
f010287f:	68 65 77 10 f0       	push   $0xf0107765
f0102884:	e8 b7 d7 ff ff       	call   f0100040 <_panic>
f0102889:	56                   	push   %esi
f010288a:	68 48 68 10 f0       	push   $0xf0106848
f010288f:	68 64 03 00 00       	push   $0x364
f0102894:	68 65 77 10 f0       	push   $0xf0107765
f0102899:	e8 a2 d7 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
f010289e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01028a4:	39 5d cc             	cmp    %ebx,-0x34(%ebp)
f01028a7:	76 3a                	jbe    f01028e3 <mem_init+0x161c>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01028a9:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01028af:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01028b2:	e8 12 e2 ff ff       	call   f0100ac9 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01028b7:	81 7d c8 ff ff ff ef 	cmpl   $0xefffffff,-0x38(%ebp)
f01028be:	76 c9                	jbe    f0102889 <mem_init+0x15c2>
f01028c0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01028c3:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f01028c6:	39 d0                	cmp    %edx,%eax
f01028c8:	74 d4                	je     f010289e <mem_init+0x15d7>
f01028ca:	68 74 75 10 f0       	push   $0xf0107574
f01028cf:	68 8b 77 10 f0       	push   $0xf010778b
f01028d4:	68 64 03 00 00       	push   $0x364
f01028d9:	68 65 77 10 f0       	push   $0xf0107765
f01028de:	e8 5d d7 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01028e3:	a1 44 f2 23 f0       	mov    0xf023f244,%eax
f01028e8:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01028eb:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01028ee:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01028f3:	8d b0 00 00 40 21    	lea    0x21400000(%eax),%esi
f01028f9:	89 da                	mov    %ebx,%edx
f01028fb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01028fe:	e8 c6 e1 ff ff       	call   f0100ac9 <check_va2pa>
f0102903:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f010290a:	76 3b                	jbe    f0102947 <mem_init+0x1680>
f010290c:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f010290f:	39 d0                	cmp    %edx,%eax
f0102911:	75 4b                	jne    f010295e <mem_init+0x1697>
f0102913:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
f0102919:	81 fb 00 10 c2 ee    	cmp    $0xeec21000,%ebx
f010291f:	75 d8                	jne    f01028f9 <mem_init+0x1632>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102921:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0102924:	c1 e6 0c             	shl    $0xc,%esi
f0102927:	89 fb                	mov    %edi,%ebx
f0102929:	39 f3                	cmp    %esi,%ebx
f010292b:	73 63                	jae    f0102990 <mem_init+0x16c9>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010292d:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102933:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102936:	e8 8e e1 ff ff       	call   f0100ac9 <check_va2pa>
f010293b:	39 c3                	cmp    %eax,%ebx
f010293d:	75 38                	jne    f0102977 <mem_init+0x16b0>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010293f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102945:	eb e2                	jmp    f0102929 <mem_init+0x1662>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102947:	ff 75 c8             	pushl  -0x38(%ebp)
f010294a:	68 48 68 10 f0       	push   $0xf0106848
f010294f:	68 69 03 00 00       	push   $0x369
f0102954:	68 65 77 10 f0       	push   $0xf0107765
f0102959:	e8 e2 d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010295e:	68 a8 75 10 f0       	push   $0xf01075a8
f0102963:	68 8b 77 10 f0       	push   $0xf010778b
f0102968:	68 69 03 00 00       	push   $0x369
f010296d:	68 65 77 10 f0       	push   $0xf0107765
f0102972:	e8 c9 d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102977:	68 dc 75 10 f0       	push   $0xf01075dc
f010297c:	68 8b 77 10 f0       	push   $0xf010778b
f0102981:	68 6d 03 00 00       	push   $0x36d
f0102986:	68 65 77 10 f0       	push   $0xf0107765
f010298b:	e8 b0 d6 ff ff       	call   f0100040 <_panic>
f0102990:	c7 45 cc 00 30 25 00 	movl   $0x253000,-0x34(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102997:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
f010299c:	89 7d c0             	mov    %edi,-0x40(%ebp)
f010299f:	8d bb 00 80 ff ff    	lea    -0x8000(%ebx),%edi
			assert(check_va2pa(pgdir, base + KSTKGAP + i) == PADDR(percpu_kstacks[n]) + i);
f01029a5:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01029a8:	89 45 bc             	mov    %eax,-0x44(%ebp)
f01029ab:	89 de                	mov    %ebx,%esi
f01029ad:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01029b0:	05 00 80 ff 0f       	add    $0xfff8000,%eax
f01029b5:	89 45 c8             	mov    %eax,-0x38(%ebp)
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01029b8:	8d 83 00 80 00 00    	lea    0x8000(%ebx),%eax
f01029be:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			assert(check_va2pa(pgdir, base + KSTKGAP + i) == PADDR(percpu_kstacks[n]) + i);
f01029c1:	89 f2                	mov    %esi,%edx
f01029c3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01029c6:	e8 fe e0 ff ff       	call   f0100ac9 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01029cb:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01029d2:	76 58                	jbe    f0102a2c <mem_init+0x1765>
f01029d4:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01029d7:	8d 14 31             	lea    (%ecx,%esi,1),%edx
f01029da:	39 d0                	cmp    %edx,%eax
f01029dc:	75 65                	jne    f0102a43 <mem_init+0x177c>
f01029de:	81 c6 00 10 00 00    	add    $0x1000,%esi
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01029e4:	3b 75 c4             	cmp    -0x3c(%ebp),%esi
f01029e7:	75 d8                	jne    f01029c1 <mem_init+0x16fa>
			assert(check_va2pa(pgdir, base + i) == ~0);
f01029e9:	89 fa                	mov    %edi,%edx
f01029eb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01029ee:	e8 d6 e0 ff ff       	call   f0100ac9 <check_va2pa>
f01029f3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029f6:	75 64                	jne    f0102a5c <mem_init+0x1795>
f01029f8:	81 c7 00 10 00 00    	add    $0x1000,%edi
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f01029fe:	39 df                	cmp    %ebx,%edi
f0102a00:	75 e7                	jne    f01029e9 <mem_init+0x1722>
f0102a02:	81 eb 00 00 01 00    	sub    $0x10000,%ebx
f0102a08:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
f0102a0f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102a12:	81 45 cc 00 80 01 00 	addl   $0x18000,-0x34(%ebp)
	for (n = 0; n < NCPU; n++)
f0102a19:	3d 00 30 28 f0       	cmp    $0xf0283000,%eax
f0102a1e:	0f 85 7b ff ff ff    	jne    f010299f <mem_init+0x16d8>
f0102a24:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0102a27:	e9 84 00 00 00       	jmp    f0102ab0 <mem_init+0x17e9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a2c:	ff 75 bc             	pushl  -0x44(%ebp)
f0102a2f:	68 48 68 10 f0       	push   $0xf0106848
f0102a34:	68 75 03 00 00       	push   $0x375
f0102a39:	68 65 77 10 f0       	push   $0xf0107765
f0102a3e:	e8 fd d5 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i) == PADDR(percpu_kstacks[n]) + i);
f0102a43:	68 04 76 10 f0       	push   $0xf0107604
f0102a48:	68 8b 77 10 f0       	push   $0xf010778b
f0102a4d:	68 75 03 00 00       	push   $0x375
f0102a52:	68 65 77 10 f0       	push   $0xf0107765
f0102a57:	e8 e4 d5 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102a5c:	68 4c 76 10 f0       	push   $0xf010764c
f0102a61:	68 8b 77 10 f0       	push   $0xf010778b
f0102a66:	68 77 03 00 00       	push   $0x377
f0102a6b:	68 65 77 10 f0       	push   $0xf0107765
f0102a70:	e8 cb d5 ff ff       	call   f0100040 <_panic>
			assert(pgdir[i] & PTE_P);
f0102a75:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a78:	f6 04 b8 01          	testb  $0x1,(%eax,%edi,4)
f0102a7c:	75 4e                	jne    f0102acc <mem_init+0x1805>
f0102a7e:	68 02 7a 10 f0       	push   $0xf0107a02
f0102a83:	68 8b 77 10 f0       	push   $0xf010778b
f0102a88:	68 84 03 00 00       	push   $0x384
f0102a8d:	68 65 77 10 f0       	push   $0xf0107765
f0102a92:	e8 a9 d5 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_P);
f0102a97:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a9a:	8b 04 b8             	mov    (%eax,%edi,4),%eax
f0102a9d:	a8 01                	test   $0x1,%al
f0102a9f:	74 30                	je     f0102ad1 <mem_init+0x180a>
				assert(pgdir[i] & PTE_W);
f0102aa1:	a8 02                	test   $0x2,%al
f0102aa3:	74 45                	je     f0102aea <mem_init+0x1823>
	for (i = 0; i < NPDENTRIES; i++)
f0102aa5:	83 c7 01             	add    $0x1,%edi
f0102aa8:	81 ff 00 04 00 00    	cmp    $0x400,%edi
f0102aae:	74 6c                	je     f0102b1c <mem_init+0x1855>
		switch (i)
f0102ab0:	8d 87 45 fc ff ff    	lea    -0x3bb(%edi),%eax
f0102ab6:	83 f8 04             	cmp    $0x4,%eax
f0102ab9:	76 ba                	jbe    f0102a75 <mem_init+0x17ae>
			if (i >= PDX(KERNBASE))
f0102abb:	81 ff bf 03 00 00    	cmp    $0x3bf,%edi
f0102ac1:	77 d4                	ja     f0102a97 <mem_init+0x17d0>
				assert(pgdir[i] == 0);
f0102ac3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102ac6:	83 3c b8 00          	cmpl   $0x0,(%eax,%edi,4)
f0102aca:	75 37                	jne    f0102b03 <mem_init+0x183c>
	for (i = 0; i < NPDENTRIES; i++)
f0102acc:	83 c7 01             	add    $0x1,%edi
f0102acf:	eb df                	jmp    f0102ab0 <mem_init+0x17e9>
				assert(pgdir[i] & PTE_P);
f0102ad1:	68 02 7a 10 f0       	push   $0xf0107a02
f0102ad6:	68 8b 77 10 f0       	push   $0xf010778b
f0102adb:	68 89 03 00 00       	push   $0x389
f0102ae0:	68 65 77 10 f0       	push   $0xf0107765
f0102ae5:	e8 56 d5 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102aea:	68 13 7a 10 f0       	push   $0xf0107a13
f0102aef:	68 8b 77 10 f0       	push   $0xf010778b
f0102af4:	68 8a 03 00 00       	push   $0x38a
f0102af9:	68 65 77 10 f0       	push   $0xf0107765
f0102afe:	e8 3d d5 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] == 0);
f0102b03:	68 24 7a 10 f0       	push   $0xf0107a24
f0102b08:	68 8b 77 10 f0       	push   $0xf010778b
f0102b0d:	68 8d 03 00 00       	push   $0x38d
f0102b12:	68 65 77 10 f0       	push   $0xf0107765
f0102b17:	e8 24 d5 ff ff       	call   f0100040 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102b1c:	83 ec 0c             	sub    $0xc,%esp
f0102b1f:	68 70 76 10 f0       	push   $0xf0107670
f0102b24:	e8 a0 0f 00 00       	call   f0103ac9 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102b29:	a1 c4 1e 24 f0       	mov    0xf0241ec4,%eax
	if ((uint32_t)kva < KERNBASE)
f0102b2e:	83 c4 10             	add    $0x10,%esp
f0102b31:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b36:	0f 86 03 02 00 00    	jbe    f0102d3f <mem_init+0x1a78>
	return (physaddr_t)kva - KERNBASE;
f0102b3c:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102b41:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102b44:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b49:	e8 de df ff ff       	call   f0100b2c <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102b4e:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS | CR0_EM);
f0102b51:	83 e0 f3             	and    $0xfffffff3,%eax
f0102b54:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102b59:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102b5c:	83 ec 0c             	sub    $0xc,%esp
f0102b5f:	6a 00                	push   $0x0
f0102b61:	e8 9b e3 ff ff       	call   f0100f01 <page_alloc>
f0102b66:	89 c6                	mov    %eax,%esi
f0102b68:	83 c4 10             	add    $0x10,%esp
f0102b6b:	85 c0                	test   %eax,%eax
f0102b6d:	0f 84 e1 01 00 00    	je     f0102d54 <mem_init+0x1a8d>
	assert((pp1 = page_alloc(0)));
f0102b73:	83 ec 0c             	sub    $0xc,%esp
f0102b76:	6a 00                	push   $0x0
f0102b78:	e8 84 e3 ff ff       	call   f0100f01 <page_alloc>
f0102b7d:	89 c7                	mov    %eax,%edi
f0102b7f:	83 c4 10             	add    $0x10,%esp
f0102b82:	85 c0                	test   %eax,%eax
f0102b84:	0f 84 e3 01 00 00    	je     f0102d6d <mem_init+0x1aa6>
	assert((pp2 = page_alloc(0)));
f0102b8a:	83 ec 0c             	sub    $0xc,%esp
f0102b8d:	6a 00                	push   $0x0
f0102b8f:	e8 6d e3 ff ff       	call   f0100f01 <page_alloc>
f0102b94:	89 c3                	mov    %eax,%ebx
f0102b96:	83 c4 10             	add    $0x10,%esp
f0102b99:	85 c0                	test   %eax,%eax
f0102b9b:	0f 84 e5 01 00 00    	je     f0102d86 <mem_init+0x1abf>
	page_free(pp0);
f0102ba1:	83 ec 0c             	sub    $0xc,%esp
f0102ba4:	56                   	push   %esi
f0102ba5:	e8 d0 e3 ff ff       	call   f0100f7a <page_free>
	return (pp - pages) << PGSHIFT;
f0102baa:	89 f8                	mov    %edi,%eax
f0102bac:	2b 05 c8 1e 24 f0    	sub    0xf0241ec8,%eax
f0102bb2:	c1 f8 03             	sar    $0x3,%eax
f0102bb5:	89 c2                	mov    %eax,%edx
f0102bb7:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102bba:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102bbf:	83 c4 10             	add    $0x10,%esp
f0102bc2:	3b 05 c0 1e 24 f0    	cmp    0xf0241ec0,%eax
f0102bc8:	0f 83 d1 01 00 00    	jae    f0102d9f <mem_init+0x1ad8>
	memset(page2kva(pp1), 1, PGSIZE);
f0102bce:	83 ec 04             	sub    $0x4,%esp
f0102bd1:	68 00 10 00 00       	push   $0x1000
f0102bd6:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102bd8:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102bde:	52                   	push   %edx
f0102bdf:	e8 7f 2f 00 00       	call   f0105b63 <memset>
	return (pp - pages) << PGSHIFT;
f0102be4:	89 d8                	mov    %ebx,%eax
f0102be6:	2b 05 c8 1e 24 f0    	sub    0xf0241ec8,%eax
f0102bec:	c1 f8 03             	sar    $0x3,%eax
f0102bef:	89 c2                	mov    %eax,%edx
f0102bf1:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102bf4:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102bf9:	83 c4 10             	add    $0x10,%esp
f0102bfc:	3b 05 c0 1e 24 f0    	cmp    0xf0241ec0,%eax
f0102c02:	0f 83 a9 01 00 00    	jae    f0102db1 <mem_init+0x1aea>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c08:	83 ec 04             	sub    $0x4,%esp
f0102c0b:	68 00 10 00 00       	push   $0x1000
f0102c10:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102c12:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102c18:	52                   	push   %edx
f0102c19:	e8 45 2f 00 00       	call   f0105b63 <memset>
	page_insert(kern_pgdir, pp1, (void *)PGSIZE, PTE_W);
f0102c1e:	6a 02                	push   $0x2
f0102c20:	68 00 10 00 00       	push   $0x1000
f0102c25:	57                   	push   %edi
f0102c26:	ff 35 c4 1e 24 f0    	pushl  0xf0241ec4
f0102c2c:	e8 b0 e5 ff ff       	call   f01011e1 <page_insert>
	assert(pp1->pp_ref == 1);
f0102c31:	83 c4 20             	add    $0x20,%esp
f0102c34:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102c39:	0f 85 84 01 00 00    	jne    f0102dc3 <mem_init+0x1afc>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102c3f:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102c46:	01 01 01 
f0102c49:	0f 85 8d 01 00 00    	jne    f0102ddc <mem_init+0x1b15>
	page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W);
f0102c4f:	6a 02                	push   $0x2
f0102c51:	68 00 10 00 00       	push   $0x1000
f0102c56:	53                   	push   %ebx
f0102c57:	ff 35 c4 1e 24 f0    	pushl  0xf0241ec4
f0102c5d:	e8 7f e5 ff ff       	call   f01011e1 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102c62:	83 c4 10             	add    $0x10,%esp
f0102c65:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102c6c:	02 02 02 
f0102c6f:	0f 85 80 01 00 00    	jne    f0102df5 <mem_init+0x1b2e>
	assert(pp2->pp_ref == 1);
f0102c75:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102c7a:	0f 85 8e 01 00 00    	jne    f0102e0e <mem_init+0x1b47>
	assert(pp1->pp_ref == 0);
f0102c80:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102c85:	0f 85 9c 01 00 00    	jne    f0102e27 <mem_init+0x1b60>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102c8b:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102c92:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102c95:	89 d8                	mov    %ebx,%eax
f0102c97:	2b 05 c8 1e 24 f0    	sub    0xf0241ec8,%eax
f0102c9d:	c1 f8 03             	sar    $0x3,%eax
f0102ca0:	89 c2                	mov    %eax,%edx
f0102ca2:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102ca5:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102caa:	3b 05 c0 1e 24 f0    	cmp    0xf0241ec0,%eax
f0102cb0:	0f 83 8a 01 00 00    	jae    f0102e40 <mem_init+0x1b79>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102cb6:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0102cbd:	03 03 03 
f0102cc0:	0f 85 8c 01 00 00    	jne    f0102e52 <mem_init+0x1b8b>
	page_remove(kern_pgdir, (void *)PGSIZE);
f0102cc6:	83 ec 08             	sub    $0x8,%esp
f0102cc9:	68 00 10 00 00       	push   $0x1000
f0102cce:	ff 35 c4 1e 24 f0    	pushl  0xf0241ec4
f0102cd4:	e8 be e4 ff ff       	call   f0101197 <page_remove>
	assert(pp2->pp_ref == 0);
f0102cd9:	83 c4 10             	add    $0x10,%esp
f0102cdc:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102ce1:	0f 85 84 01 00 00    	jne    f0102e6b <mem_init+0x1ba4>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ce7:	8b 0d c4 1e 24 f0    	mov    0xf0241ec4,%ecx
f0102ced:	8b 11                	mov    (%ecx),%edx
f0102cef:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102cf5:	89 f0                	mov    %esi,%eax
f0102cf7:	2b 05 c8 1e 24 f0    	sub    0xf0241ec8,%eax
f0102cfd:	c1 f8 03             	sar    $0x3,%eax
f0102d00:	c1 e0 0c             	shl    $0xc,%eax
f0102d03:	39 c2                	cmp    %eax,%edx
f0102d05:	0f 85 79 01 00 00    	jne    f0102e84 <mem_init+0x1bbd>
	kern_pgdir[0] = 0;
f0102d0b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102d11:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d16:	0f 85 81 01 00 00    	jne    f0102e9d <mem_init+0x1bd6>
	pp0->pp_ref = 0;
f0102d1c:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102d22:	83 ec 0c             	sub    $0xc,%esp
f0102d25:	56                   	push   %esi
f0102d26:	e8 4f e2 ff ff       	call   f0100f7a <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d2b:	c7 04 24 04 77 10 f0 	movl   $0xf0107704,(%esp)
f0102d32:	e8 92 0d 00 00       	call   f0103ac9 <cprintf>
}
f0102d37:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d3a:	5b                   	pop    %ebx
f0102d3b:	5e                   	pop    %esi
f0102d3c:	5f                   	pop    %edi
f0102d3d:	5d                   	pop    %ebp
f0102d3e:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d3f:	50                   	push   %eax
f0102d40:	68 48 68 10 f0       	push   $0xf0106848
f0102d45:	68 e9 00 00 00       	push   $0xe9
f0102d4a:	68 65 77 10 f0       	push   $0xf0107765
f0102d4f:	e8 ec d2 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0102d54:	68 65 78 10 f0       	push   $0xf0107865
f0102d59:	68 8b 77 10 f0       	push   $0xf010778b
f0102d5e:	68 64 04 00 00       	push   $0x464
f0102d63:	68 65 77 10 f0       	push   $0xf0107765
f0102d68:	e8 d3 d2 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102d6d:	68 7b 78 10 f0       	push   $0xf010787b
f0102d72:	68 8b 77 10 f0       	push   $0xf010778b
f0102d77:	68 65 04 00 00       	push   $0x465
f0102d7c:	68 65 77 10 f0       	push   $0xf0107765
f0102d81:	e8 ba d2 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102d86:	68 91 78 10 f0       	push   $0xf0107891
f0102d8b:	68 8b 77 10 f0       	push   $0xf010778b
f0102d90:	68 66 04 00 00       	push   $0x466
f0102d95:	68 65 77 10 f0       	push   $0xf0107765
f0102d9a:	e8 a1 d2 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d9f:	52                   	push   %edx
f0102da0:	68 24 68 10 f0       	push   $0xf0106824
f0102da5:	6a 58                	push   $0x58
f0102da7:	68 71 77 10 f0       	push   $0xf0107771
f0102dac:	e8 8f d2 ff ff       	call   f0100040 <_panic>
f0102db1:	52                   	push   %edx
f0102db2:	68 24 68 10 f0       	push   $0xf0106824
f0102db7:	6a 58                	push   $0x58
f0102db9:	68 71 77 10 f0       	push   $0xf0107771
f0102dbe:	e8 7d d2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102dc3:	68 0b 79 10 f0       	push   $0xf010790b
f0102dc8:	68 8b 77 10 f0       	push   $0xf010778b
f0102dcd:	68 6b 04 00 00       	push   $0x46b
f0102dd2:	68 65 77 10 f0       	push   $0xf0107765
f0102dd7:	e8 64 d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102ddc:	68 90 76 10 f0       	push   $0xf0107690
f0102de1:	68 8b 77 10 f0       	push   $0xf010778b
f0102de6:	68 6c 04 00 00       	push   $0x46c
f0102deb:	68 65 77 10 f0       	push   $0xf0107765
f0102df0:	e8 4b d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102df5:	68 b4 76 10 f0       	push   $0xf01076b4
f0102dfa:	68 8b 77 10 f0       	push   $0xf010778b
f0102dff:	68 6e 04 00 00       	push   $0x46e
f0102e04:	68 65 77 10 f0       	push   $0xf0107765
f0102e09:	e8 32 d2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102e0e:	68 2d 79 10 f0       	push   $0xf010792d
f0102e13:	68 8b 77 10 f0       	push   $0xf010778b
f0102e18:	68 6f 04 00 00       	push   $0x46f
f0102e1d:	68 65 77 10 f0       	push   $0xf0107765
f0102e22:	e8 19 d2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102e27:	68 97 79 10 f0       	push   $0xf0107997
f0102e2c:	68 8b 77 10 f0       	push   $0xf010778b
f0102e31:	68 70 04 00 00       	push   $0x470
f0102e36:	68 65 77 10 f0       	push   $0xf0107765
f0102e3b:	e8 00 d2 ff ff       	call   f0100040 <_panic>
f0102e40:	52                   	push   %edx
f0102e41:	68 24 68 10 f0       	push   $0xf0106824
f0102e46:	6a 58                	push   $0x58
f0102e48:	68 71 77 10 f0       	push   $0xf0107771
f0102e4d:	e8 ee d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e52:	68 d8 76 10 f0       	push   $0xf01076d8
f0102e57:	68 8b 77 10 f0       	push   $0xf010778b
f0102e5c:	68 72 04 00 00       	push   $0x472
f0102e61:	68 65 77 10 f0       	push   $0xf0107765
f0102e66:	e8 d5 d1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102e6b:	68 65 79 10 f0       	push   $0xf0107965
f0102e70:	68 8b 77 10 f0       	push   $0xf010778b
f0102e75:	68 74 04 00 00       	push   $0x474
f0102e7a:	68 65 77 10 f0       	push   $0xf0107765
f0102e7f:	e8 bc d1 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102e84:	68 58 70 10 f0       	push   $0xf0107058
f0102e89:	68 8b 77 10 f0       	push   $0xf010778b
f0102e8e:	68 77 04 00 00       	push   $0x477
f0102e93:	68 65 77 10 f0       	push   $0xf0107765
f0102e98:	e8 a3 d1 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102e9d:	68 1c 79 10 f0       	push   $0xf010791c
f0102ea2:	68 8b 77 10 f0       	push   $0xf010778b
f0102ea7:	68 79 04 00 00       	push   $0x479
f0102eac:	68 65 77 10 f0       	push   $0xf0107765
f0102eb1:	e8 8a d1 ff ff       	call   f0100040 <_panic>

f0102eb6 <user_mem_check>:
{
f0102eb6:	f3 0f 1e fb          	endbr32 
f0102eba:	55                   	push   %ebp
f0102ebb:	89 e5                	mov    %esp,%ebp
f0102ebd:	57                   	push   %edi
f0102ebe:	56                   	push   %esi
f0102ebf:	53                   	push   %ebx
f0102ec0:	83 ec 0c             	sub    $0xc,%esp
f0102ec3:	8b 75 14             	mov    0x14(%ebp),%esi
	uint32_t begin = (uint32_t)ROUNDDOWN(va, PGSIZE);
f0102ec6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102ec9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t end = (uint32_t)ROUNDUP(va + len, PGSIZE);
f0102ecf:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0102ed2:	03 7d 10             	add    0x10(%ebp),%edi
f0102ed5:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
f0102edb:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (i = (uint32_t)begin; i < end; i += PGSIZE)
f0102ee1:	eb 06                	jmp    f0102ee9 <user_mem_check+0x33>
f0102ee3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102ee9:	39 fb                	cmp    %edi,%ebx
f0102eeb:	73 46                	jae    f0102f33 <user_mem_check+0x7d>
		pte_t *pte = pgdir_walk(env->env_pgdir, (void *)i, 0);
f0102eed:	83 ec 04             	sub    $0x4,%esp
f0102ef0:	6a 00                	push   $0x0
f0102ef2:	53                   	push   %ebx
f0102ef3:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ef6:	ff 70 60             	pushl  0x60(%eax)
f0102ef9:	e8 e8 e0 ff ff       	call   f0100fe6 <pgdir_walk>
		if ((i >= ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm))
f0102efe:	83 c4 10             	add    $0x10,%esp
f0102f01:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102f07:	77 10                	ja     f0102f19 <user_mem_check+0x63>
f0102f09:	85 c0                	test   %eax,%eax
f0102f0b:	74 0c                	je     f0102f19 <user_mem_check+0x63>
f0102f0d:	8b 00                	mov    (%eax),%eax
f0102f0f:	a8 01                	test   $0x1,%al
f0102f11:	74 06                	je     f0102f19 <user_mem_check+0x63>
f0102f13:	21 f0                	and    %esi,%eax
f0102f15:	39 c6                	cmp    %eax,%esi
f0102f17:	74 ca                	je     f0102ee3 <user_mem_check+0x2d>
			user_mem_check_addr = (i < (uint32_t)va ? (uint32_t)va : i);
f0102f19:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102f1c:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f0102f20:	89 1d 3c f2 23 f0    	mov    %ebx,0xf023f23c
			return -E_FAULT;
f0102f26:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f0102f2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f2e:	5b                   	pop    %ebx
f0102f2f:	5e                   	pop    %esi
f0102f30:	5f                   	pop    %edi
f0102f31:	5d                   	pop    %ebp
f0102f32:	c3                   	ret    
	return 0;
f0102f33:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f38:	eb f1                	jmp    f0102f2b <user_mem_check+0x75>

f0102f3a <user_mem_assert>:
{
f0102f3a:	f3 0f 1e fb          	endbr32 
f0102f3e:	55                   	push   %ebp
f0102f3f:	89 e5                	mov    %esp,%ebp
f0102f41:	53                   	push   %ebx
f0102f42:	83 ec 04             	sub    $0x4,%esp
f0102f45:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0)
f0102f48:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f4b:	83 c8 04             	or     $0x4,%eax
f0102f4e:	50                   	push   %eax
f0102f4f:	ff 75 10             	pushl  0x10(%ebp)
f0102f52:	ff 75 0c             	pushl  0xc(%ebp)
f0102f55:	53                   	push   %ebx
f0102f56:	e8 5b ff ff ff       	call   f0102eb6 <user_mem_check>
f0102f5b:	83 c4 10             	add    $0x10,%esp
f0102f5e:	85 c0                	test   %eax,%eax
f0102f60:	78 05                	js     f0102f67 <user_mem_assert+0x2d>
}
f0102f62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102f65:	c9                   	leave  
f0102f66:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f0102f67:	83 ec 04             	sub    $0x4,%esp
f0102f6a:	ff 35 3c f2 23 f0    	pushl  0xf023f23c
f0102f70:	ff 73 48             	pushl  0x48(%ebx)
f0102f73:	68 30 77 10 f0       	push   $0xf0107730
f0102f78:	e8 4c 0b 00 00       	call   f0103ac9 <cprintf>
		env_destroy(env); // may not return
f0102f7d:	89 1c 24             	mov    %ebx,(%esp)
f0102f80:	e8 37 08 00 00       	call   f01037bc <env_destroy>
f0102f85:	83 c4 10             	add    $0x10,%esp
}
f0102f88:	eb d8                	jmp    f0102f62 <user_mem_assert+0x28>

f0102f8a <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102f8a:	55                   	push   %ebp
f0102f8b:	89 e5                	mov    %esp,%ebp
f0102f8d:	57                   	push   %edi
f0102f8e:	56                   	push   %esi
f0102f8f:	53                   	push   %ebx
f0102f90:	83 ec 0c             	sub    $0xc,%esp
f0102f93:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *begin = ROUNDDOWN(va, PGSIZE), *end = ROUNDUP(va+len, PGSIZE);
f0102f95:	89 d3                	mov    %edx,%ebx
f0102f97:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102f9d:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102fa4:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	while (begin < end) {
f0102faa:	39 f3                	cmp    %esi,%ebx
f0102fac:	73 3f                	jae    f0102fed <region_alloc+0x63>
		struct PageInfo *pg = page_alloc(0);
f0102fae:	83 ec 0c             	sub    $0xc,%esp
f0102fb1:	6a 00                	push   $0x0
f0102fb3:	e8 49 df ff ff       	call   f0100f01 <page_alloc>
		if (!pg) {
f0102fb8:	83 c4 10             	add    $0x10,%esp
f0102fbb:	85 c0                	test   %eax,%eax
f0102fbd:	74 17                	je     f0102fd6 <region_alloc+0x4c>
			panic("region_alloc failed\n");
		}
		page_insert(e->env_pgdir, pg, begin, PTE_W | PTE_U);
f0102fbf:	6a 06                	push   $0x6
f0102fc1:	53                   	push   %ebx
f0102fc2:	50                   	push   %eax
f0102fc3:	ff 77 60             	pushl  0x60(%edi)
f0102fc6:	e8 16 e2 ff ff       	call   f01011e1 <page_insert>
		begin += PGSIZE;
f0102fcb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102fd1:	83 c4 10             	add    $0x10,%esp
f0102fd4:	eb d4                	jmp    f0102faa <region_alloc+0x20>
			panic("region_alloc failed\n");
f0102fd6:	83 ec 04             	sub    $0x4,%esp
f0102fd9:	68 32 7a 10 f0       	push   $0xf0107a32
f0102fde:	68 3b 01 00 00       	push   $0x13b
f0102fe3:	68 47 7a 10 f0       	push   $0xf0107a47
f0102fe8:	e8 53 d0 ff ff       	call   f0100040 <_panic>
	}
}
f0102fed:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ff0:	5b                   	pop    %ebx
f0102ff1:	5e                   	pop    %esi
f0102ff2:	5f                   	pop    %edi
f0102ff3:	5d                   	pop    %ebp
f0102ff4:	c3                   	ret    

f0102ff5 <envid2env>:
{
f0102ff5:	f3 0f 1e fb          	endbr32 
f0102ff9:	55                   	push   %ebp
f0102ffa:	89 e5                	mov    %esp,%ebp
f0102ffc:	56                   	push   %esi
f0102ffd:	53                   	push   %ebx
f0102ffe:	8b 75 08             	mov    0x8(%ebp),%esi
f0103001:	8b 45 10             	mov    0x10(%ebp),%eax
	if (envid == 0) {
f0103004:	85 f6                	test   %esi,%esi
f0103006:	74 31                	je     f0103039 <envid2env+0x44>
	e = &envs[ENVX(envid)];
f0103008:	89 f3                	mov    %esi,%ebx
f010300a:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103010:	69 db 84 00 00 00    	imul   $0x84,%ebx,%ebx
f0103016:	03 1d 44 f2 23 f0    	add    0xf023f244,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010301c:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103020:	74 2e                	je     f0103050 <envid2env+0x5b>
f0103022:	39 73 48             	cmp    %esi,0x48(%ebx)
f0103025:	75 29                	jne    f0103050 <envid2env+0x5b>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103027:	84 c0                	test   %al,%al
f0103029:	75 35                	jne    f0103060 <envid2env+0x6b>
	*env_store = e;
f010302b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010302e:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103030:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103035:	5b                   	pop    %ebx
f0103036:	5e                   	pop    %esi
f0103037:	5d                   	pop    %ebp
f0103038:	c3                   	ret    
		*env_store = curenv;
f0103039:	e8 44 31 00 00       	call   f0106182 <cpunum>
f010303e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103041:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0103047:	8b 55 0c             	mov    0xc(%ebp),%edx
f010304a:	89 02                	mov    %eax,(%edx)
		return 0;
f010304c:	89 f0                	mov    %esi,%eax
f010304e:	eb e5                	jmp    f0103035 <envid2env+0x40>
		*env_store = 0;
f0103050:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103053:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103059:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010305e:	eb d5                	jmp    f0103035 <envid2env+0x40>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103060:	e8 1d 31 00 00       	call   f0106182 <cpunum>
f0103065:	6b c0 74             	imul   $0x74,%eax,%eax
f0103068:	39 98 28 20 24 f0    	cmp    %ebx,-0xfdbdfd8(%eax)
f010306e:	74 bb                	je     f010302b <envid2env+0x36>
f0103070:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103073:	e8 0a 31 00 00       	call   f0106182 <cpunum>
f0103078:	6b c0 74             	imul   $0x74,%eax,%eax
f010307b:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0103081:	3b 70 48             	cmp    0x48(%eax),%esi
f0103084:	74 a5                	je     f010302b <envid2env+0x36>
		*env_store = 0;
f0103086:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103089:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010308f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103094:	eb 9f                	jmp    f0103035 <envid2env+0x40>

f0103096 <env_init_percpu>:
{
f0103096:	f3 0f 1e fb          	endbr32 
	asm volatile("lgdt (%0)" : : "r" (p));
f010309a:	b8 20 43 12 f0       	mov    $0xf0124320,%eax
f010309f:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f01030a2:	b8 23 00 00 00       	mov    $0x23,%eax
f01030a7:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f01030a9:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f01030ab:	b8 10 00 00 00       	mov    $0x10,%eax
f01030b0:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f01030b2:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f01030b4:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f01030b6:	ea bd 30 10 f0 08 00 	ljmp   $0x8,$0xf01030bd
	asm volatile("lldt %0" : : "r" (sel));
f01030bd:	b8 00 00 00 00       	mov    $0x0,%eax
f01030c2:	0f 00 d0             	lldt   %ax
}
f01030c5:	c3                   	ret    

f01030c6 <env_init>:
{
f01030c6:	f3 0f 1e fb          	endbr32 
f01030ca:	55                   	push   %ebp
f01030cb:	89 e5                	mov    %esp,%ebp
f01030cd:	56                   	push   %esi
f01030ce:	53                   	push   %ebx
		envs[i].env_id = 0;
f01030cf:	8b 35 44 f2 23 f0    	mov    0xf023f244,%esi
f01030d5:	8d 86 7c 0f 02 00    	lea    0x20f7c(%esi),%eax
f01030db:	89 f3                	mov    %esi,%ebx
f01030dd:	ba 00 00 00 00       	mov    $0x0,%edx
f01030e2:	89 d1                	mov    %edx,%ecx
f01030e4:	89 c2                	mov    %eax,%edx
f01030e6:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f01030ed:	89 48 44             	mov    %ecx,0x44(%eax)
f01030f0:	2d 84 00 00 00       	sub    $0x84,%eax
	for (int i = NENV - 1; i >= 0; i--) {		
f01030f5:	39 da                	cmp    %ebx,%edx
f01030f7:	75 e9                	jne    f01030e2 <env_init+0x1c>
f01030f9:	89 35 48 f2 23 f0    	mov    %esi,0xf023f248
	totalslice = 0;
f01030ff:	c7 05 b0 fe 23 f0 00 	movl   $0x0,0xf023feb0
f0103106:	00 00 00 
		MFQueue[i].front = NULL;
f0103109:	c7 05 84 fe 23 f0 00 	movl   $0x0,0xf023fe84
f0103110:	00 00 00 
		MFQueue[i].rear = NULL;
f0103113:	c7 05 88 fe 23 f0 00 	movl   $0x0,0xf023fe88
f010311a:	00 00 00 
		MFQueue[i].front = NULL;
f010311d:	c7 05 90 fe 23 f0 00 	movl   $0x0,0xf023fe90
f0103124:	00 00 00 
		MFQueue[i].rear = NULL;
f0103127:	c7 05 94 fe 23 f0 00 	movl   $0x0,0xf023fe94
f010312e:	00 00 00 
		MFQueue[i].front = NULL;
f0103131:	c7 05 9c fe 23 f0 00 	movl   $0x0,0xf023fe9c
f0103138:	00 00 00 
		MFQueue[i].rear = NULL;
f010313b:	c7 05 a0 fe 23 f0 00 	movl   $0x0,0xf023fea0
f0103142:	00 00 00 
		MFQueue[i].front = NULL;
f0103145:	c7 05 a8 fe 23 f0 00 	movl   $0x0,0xf023fea8
f010314c:	00 00 00 
		MFQueue[i].rear = NULL;
f010314f:	c7 05 ac fe 23 f0 00 	movl   $0x0,0xf023feac
f0103156:	00 00 00 
	MFQueue[0].timelimit = 1;
f0103159:	c7 05 80 fe 23 f0 01 	movl   $0x1,0xf023fe80
f0103160:	00 00 00 
	MFQueue[1].timelimit = 2;
f0103163:	c7 05 8c fe 23 f0 02 	movl   $0x2,0xf023fe8c
f010316a:	00 00 00 
	MFQueue[2].timelimit = 4;
f010316d:	c7 05 98 fe 23 f0 04 	movl   $0x4,0xf023fe98
f0103174:	00 00 00 
	MFQueue[3].timelimit = INFINIE_TIMES;
f0103177:	c7 05 a4 fe 23 f0 ff 	movl   $0x7fffffff,0xf023fea4
f010317e:	ff ff 7f 
	env_init_percpu();
f0103181:	e8 10 ff ff ff       	call   f0103096 <env_init_percpu>
}
f0103186:	5b                   	pop    %ebx
f0103187:	5e                   	pop    %esi
f0103188:	5d                   	pop    %ebp
f0103189:	c3                   	ret    

f010318a <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f010318a:	f3 0f 1e fb          	endbr32 
f010318e:	55                   	push   %ebp
f010318f:	89 e5                	mov    %esp,%ebp
f0103191:	53                   	push   %ebx
f0103192:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103195:	e8 e8 2f 00 00       	call   f0106182 <cpunum>
f010319a:	6b c0 74             	imul   $0x74,%eax,%eax
f010319d:	8b 98 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%ebx
f01031a3:	e8 da 2f 00 00       	call   f0106182 <cpunum>
f01031a8:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f01031ab:	8b 65 08             	mov    0x8(%ebp),%esp
f01031ae:	61                   	popa   
f01031af:	07                   	pop    %es
f01031b0:	1f                   	pop    %ds
f01031b1:	83 c4 08             	add    $0x8,%esp
f01031b4:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01031b5:	83 ec 04             	sub    $0x4,%esp
f01031b8:	68 52 7a 10 f0       	push   $0xf0107a52
f01031bd:	68 0f 02 00 00       	push   $0x20f
f01031c2:	68 47 7a 10 f0       	push   $0xf0107a47
f01031c7:	e8 74 ce ff ff       	call   f0100040 <_panic>

f01031cc <e_insert>:
 * 
 * @param priority the priority of MFQueue to be inserted
 * @param e 		the environment to insert
 */
void
e_insert(int priority, struct Env* e) {
f01031cc:	f3 0f 1e fb          	endbr32 
f01031d0:	55                   	push   %ebp
f01031d1:	89 e5                	mov    %esp,%ebp
f01031d3:	56                   	push   %esi
f01031d4:	53                   	push   %ebx
f01031d5:	8b 45 08             	mov    0x8(%ebp),%eax
f01031d8:	8b 55 0c             	mov    0xc(%ebp),%edx
	nodepool[ENVX(e->env_id)].env = e;
f01031db:	8b 4a 48             	mov    0x48(%edx),%ecx
f01031de:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
f01031e4:	89 14 cd c4 fe 23 f0 	mov    %edx,-0xfdc013c(,%ecx,8)
	nodepool[ENVX(e->env_id)].next = NULL;
f01031eb:	8b 4a 48             	mov    0x48(%edx),%ecx
f01031ee:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
f01031f4:	c7 04 cd c0 fe 23 f0 	movl   $0x0,-0xfdc0140(,%ecx,8)
f01031fb:	00 00 00 00 
	if (MFQueue[priority].front == NULL) {
f01031ff:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0103202:	83 3c 8d 84 fe 23 f0 	cmpl   $0x0,-0xfdc017c(,%ecx,4)
f0103209:	00 
f010320a:	74 47                	je     f0103253 <e_insert+0x87>
		MFQueue[priority].front = &nodepool[ENVX(e->env_id)];
		MFQueue[priority].rear = &nodepool[ENVX(e->env_id)];
		return;
	}
	MFQueue[priority].rear->next = &nodepool[ENVX(e->env_id)];
f010320c:	8d 0c 00             	lea    (%eax,%eax,1),%ecx
f010320f:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
f0103212:	8b 34 9d 88 fe 23 f0 	mov    -0xfdc0178(,%ebx,4),%esi
f0103219:	8b 5a 48             	mov    0x48(%edx),%ebx
f010321c:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103222:	8d 1c dd c0 fe 23 f0 	lea    -0xfdc0140(,%ebx,8),%ebx
f0103229:	89 1e                	mov    %ebx,(%esi)
	MFQueue[priority].rear = &nodepool[ENVX(e->env_id)];
f010322b:	8b 52 48             	mov    0x48(%edx),%edx
f010322e:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0103234:	01 c8                	add    %ecx,%eax
f0103236:	8d 0c d5 c0 fe 23 f0 	lea    -0xfdc0140(,%edx,8),%ecx
f010323d:	89 0c 85 88 fe 23 f0 	mov    %ecx,-0xfdc0178(,%eax,4)
	MFQueue[priority].rear->next = NULL;
f0103244:	c7 04 d5 c0 fe 23 f0 	movl   $0x0,-0xfdc0140(,%edx,8)
f010324b:	00 00 00 00 
}
f010324f:	5b                   	pop    %ebx
f0103250:	5e                   	pop    %esi
f0103251:	5d                   	pop    %ebp
f0103252:	c3                   	ret    
		MFQueue[priority].front = &nodepool[ENVX(e->env_id)];
f0103253:	8b 52 48             	mov    0x48(%edx),%edx
f0103256:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010325c:	8d 0c d5 c0 fe 23 f0 	lea    -0xfdc0140(,%edx,8),%ecx
f0103263:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0103266:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
f0103269:	89 0c 9d 84 fe 23 f0 	mov    %ecx,-0xfdc017c(,%ebx,4)
		MFQueue[priority].rear = &nodepool[ENVX(e->env_id)];
f0103270:	89 0c 9d 88 fe 23 f0 	mov    %ecx,-0xfdc0178(,%ebx,4)
		return;
f0103277:	eb d6                	jmp    f010324f <e_insert+0x83>

f0103279 <env_alloc>:
{
f0103279:	f3 0f 1e fb          	endbr32 
f010327d:	55                   	push   %ebp
f010327e:	89 e5                	mov    %esp,%ebp
f0103280:	53                   	push   %ebx
f0103281:	83 ec 04             	sub    $0x4,%esp
	if (!(e = env_free_list))
f0103284:	8b 1d 48 f2 23 f0    	mov    0xf023f248,%ebx
f010328a:	85 db                	test   %ebx,%ebx
f010328c:	0f 84 93 01 00 00    	je     f0103425 <env_alloc+0x1ac>
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103292:	83 ec 0c             	sub    $0xc,%esp
f0103295:	6a 01                	push   $0x1
f0103297:	e8 65 dc ff ff       	call   f0100f01 <page_alloc>
f010329c:	83 c4 10             	add    $0x10,%esp
f010329f:	85 c0                	test   %eax,%eax
f01032a1:	0f 84 85 01 00 00    	je     f010342c <env_alloc+0x1b3>
	p->pp_ref++;
f01032a7:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f01032ac:	2b 05 c8 1e 24 f0    	sub    0xf0241ec8,%eax
f01032b2:	c1 f8 03             	sar    $0x3,%eax
f01032b5:	89 c2                	mov    %eax,%edx
f01032b7:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01032ba:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01032bf:	3b 05 c0 1e 24 f0    	cmp    0xf0241ec0,%eax
f01032c5:	0f 83 33 01 00 00    	jae    f01033fe <env_alloc+0x185>
	return (void *)(pa + KERNBASE);
f01032cb:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	e->env_pgdir = (pde_t *) page2kva(p);
f01032d1:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f01032d4:	83 ec 04             	sub    $0x4,%esp
f01032d7:	68 00 10 00 00       	push   $0x1000
f01032dc:	ff 35 c4 1e 24 f0    	pushl  0xf0241ec4
f01032e2:	50                   	push   %eax
f01032e3:	e8 2d 29 00 00       	call   f0105c15 <memcpy>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01032e8:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01032eb:	83 c4 10             	add    $0x10,%esp
f01032ee:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01032f3:	0f 86 17 01 00 00    	jbe    f0103410 <env_alloc+0x197>
	return (physaddr_t)kva - KERNBASE;
f01032f9:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01032ff:	83 ca 05             	or     $0x5,%edx
f0103302:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103308:	8b 43 48             	mov    0x48(%ebx),%eax
f010330b:	05 00 10 00 00       	add    $0x1000,%eax
		generation = 1 << ENVGENSHIFT;
f0103310:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0103315:	ba 00 10 00 00       	mov    $0x1000,%edx
f010331a:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010331d:	89 da                	mov    %ebx,%edx
f010331f:	2b 15 44 f2 23 f0    	sub    0xf023f244,%edx
f0103325:	c1 fa 02             	sar    $0x2,%edx
f0103328:	69 d2 e1 83 0f 3e    	imul   $0x3e0f83e1,%edx,%edx
f010332e:	09 d0                	or     %edx,%eax
f0103330:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f0103333:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103336:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103339:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103340:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103347:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	e->priority = 0;
f010334e:	c7 43 7c 00 00 00 00 	movl   $0x0,0x7c(%ebx)
	e->timeslice = 0;
f0103355:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
f010335c:	00 00 00 
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010335f:	83 ec 04             	sub    $0x4,%esp
f0103362:	6a 44                	push   $0x44
f0103364:	6a 00                	push   $0x0
f0103366:	53                   	push   %ebx
f0103367:	e8 f7 27 00 00       	call   f0105b63 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f010336c:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103372:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103378:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010337e:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103385:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	e->env_tf.tf_eflags |= FL_IF;
f010338b:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	e->env_pgfault_upcall = 0;
f0103392:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f0103399:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f010339d:	8b 43 44             	mov    0x44(%ebx),%eax
f01033a0:	a3 48 f2 23 f0       	mov    %eax,0xf023f248
	*newenv_store = e;
f01033a5:	8b 45 08             	mov    0x8(%ebp),%eax
f01033a8:	89 18                	mov    %ebx,(%eax)
	e_insert(0, e);
f01033aa:	83 c4 08             	add    $0x8,%esp
f01033ad:	53                   	push   %ebx
f01033ae:	6a 00                	push   $0x0
f01033b0:	e8 17 fe ff ff       	call   f01031cc <e_insert>
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01033b5:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01033b8:	e8 c5 2d 00 00       	call   f0106182 <cpunum>
f01033bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01033c0:	83 c4 10             	add    $0x10,%esp
f01033c3:	ba 00 00 00 00       	mov    $0x0,%edx
f01033c8:	83 b8 28 20 24 f0 00 	cmpl   $0x0,-0xfdbdfd8(%eax)
f01033cf:	74 11                	je     f01033e2 <env_alloc+0x169>
f01033d1:	e8 ac 2d 00 00       	call   f0106182 <cpunum>
f01033d6:	6b c0 74             	imul   $0x74,%eax,%eax
f01033d9:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f01033df:	8b 50 48             	mov    0x48(%eax),%edx
f01033e2:	83 ec 04             	sub    $0x4,%esp
f01033e5:	53                   	push   %ebx
f01033e6:	52                   	push   %edx
f01033e7:	68 5e 7a 10 f0       	push   $0xf0107a5e
f01033ec:	e8 d8 06 00 00       	call   f0103ac9 <cprintf>
	return 0;
f01033f1:	83 c4 10             	add    $0x10,%esp
f01033f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01033f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01033fc:	c9                   	leave  
f01033fd:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01033fe:	52                   	push   %edx
f01033ff:	68 24 68 10 f0       	push   $0xf0106824
f0103404:	6a 58                	push   $0x58
f0103406:	68 71 77 10 f0       	push   $0xf0107771
f010340b:	e8 30 cc ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103410:	50                   	push   %eax
f0103411:	68 48 68 10 f0       	push   $0xf0106848
f0103416:	68 d1 00 00 00       	push   $0xd1
f010341b:	68 47 7a 10 f0       	push   $0xf0107a47
f0103420:	e8 1b cc ff ff       	call   f0100040 <_panic>
		return -E_NO_FREE_ENV;
f0103425:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010342a:	eb cd                	jmp    f01033f9 <env_alloc+0x180>
		return -E_NO_MEM;
f010342c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103431:	eb c6                	jmp    f01033f9 <env_alloc+0x180>

f0103433 <env_create>:
{
f0103433:	f3 0f 1e fb          	endbr32 
f0103437:	55                   	push   %ebp
f0103438:	89 e5                	mov    %esp,%ebp
f010343a:	57                   	push   %edi
f010343b:	56                   	push   %esi
f010343c:	53                   	push   %ebx
f010343d:	83 ec 34             	sub    $0x34,%esp
f0103440:	8b 75 08             	mov    0x8(%ebp),%esi
	if ((r = env_alloc(&e, 0) != 0)) {
f0103443:	6a 00                	push   $0x0
f0103445:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103448:	50                   	push   %eax
f0103449:	e8 2b fe ff ff       	call   f0103279 <env_alloc>
f010344e:	83 c4 10             	add    $0x10,%esp
f0103451:	85 c0                	test   %eax,%eax
f0103453:	75 35                	jne    f010348a <env_create+0x57>
	load_icode(e, binary);
f0103455:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	if (ELFHDR->e_magic != ELF_MAGIC) {
f0103458:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f010345e:	75 41                	jne    f01034a1 <env_create+0x6e>
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
f0103460:	8b 5e 1c             	mov    0x1c(%esi),%ebx
	ph_num = ELFHDR->e_phnum;
f0103463:	0f b7 46 2c          	movzwl 0x2c(%esi),%eax
	lcr3(PADDR(e->env_pgdir));			
f0103467:	8b 57 60             	mov    0x60(%edi),%edx
	if ((uint32_t)kva < KERNBASE)
f010346a:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103470:	76 46                	jbe    f01034b8 <env_create+0x85>
	return (physaddr_t)kva - KERNBASE;
f0103472:	81 c2 00 00 00 10    	add    $0x10000000,%edx
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103478:	0f 22 da             	mov    %edx,%cr3
f010347b:	01 f3                	add    %esi,%ebx
f010347d:	0f b7 c0             	movzwl %ax,%eax
f0103480:	c1 e0 05             	shl    $0x5,%eax
f0103483:	01 d8                	add    %ebx,%eax
f0103485:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (int i = 0; i < ph_num; i++) {
f0103488:	eb 7a                	jmp    f0103504 <env_create+0xd1>
		panic("create env failed\n");
f010348a:	83 ec 04             	sub    $0x4,%esp
f010348d:	68 73 7a 10 f0       	push   $0xf0107a73
f0103492:	68 a2 01 00 00       	push   $0x1a2
f0103497:	68 47 7a 10 f0       	push   $0xf0107a47
f010349c:	e8 9f cb ff ff       	call   f0100040 <_panic>
		panic("binary is not ELF format\n");
f01034a1:	83 ec 04             	sub    $0x4,%esp
f01034a4:	68 86 7a 10 f0       	push   $0xf0107a86
f01034a9:	68 7c 01 00 00       	push   $0x17c
f01034ae:	68 47 7a 10 f0       	push   $0xf0107a47
f01034b3:	e8 88 cb ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034b8:	52                   	push   %edx
f01034b9:	68 48 68 10 f0       	push   $0xf0106848
f01034be:	68 81 01 00 00       	push   $0x181
f01034c3:	68 47 7a 10 f0       	push   $0xf0107a47
f01034c8:	e8 73 cb ff ff       	call   f0100040 <_panic>
			region_alloc(e, (void *)ph[i].p_va, ph[i].p_memsz);
f01034cd:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01034d0:	8b 53 08             	mov    0x8(%ebx),%edx
f01034d3:	89 f8                	mov    %edi,%eax
f01034d5:	e8 b0 fa ff ff       	call   f0102f8a <region_alloc>
			memset((void *)ph[i].p_va, 0, ph[i].p_memsz);		
f01034da:	83 ec 04             	sub    $0x4,%esp
f01034dd:	ff 73 14             	pushl  0x14(%ebx)
f01034e0:	6a 00                	push   $0x0
f01034e2:	ff 73 08             	pushl  0x8(%ebx)
f01034e5:	e8 79 26 00 00       	call   f0105b63 <memset>
			memcpy((void *)ph[i].p_va, binary + ph[i].p_offset, ph[i].p_filesz); 
f01034ea:	83 c4 0c             	add    $0xc,%esp
f01034ed:	ff 73 10             	pushl  0x10(%ebx)
f01034f0:	89 f0                	mov    %esi,%eax
f01034f2:	03 43 04             	add    0x4(%ebx),%eax
f01034f5:	50                   	push   %eax
f01034f6:	ff 73 08             	pushl  0x8(%ebx)
f01034f9:	e8 17 27 00 00       	call   f0105c15 <memcpy>
f01034fe:	83 c4 10             	add    $0x10,%esp
f0103501:	83 c3 20             	add    $0x20,%ebx
	for (int i = 0; i < ph_num; i++) {
f0103504:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f0103507:	74 07                	je     f0103510 <env_create+0xdd>
		if (ph[i].p_type == ELF_PROG_LOAD) {	
f0103509:	83 3b 01             	cmpl   $0x1,(%ebx)
f010350c:	75 f3                	jne    f0103501 <env_create+0xce>
f010350e:	eb bd                	jmp    f01034cd <env_create+0x9a>
	lcr3(PADDR(kern_pgdir));
f0103510:	a1 c4 1e 24 f0       	mov    0xf0241ec4,%eax
	if ((uint32_t)kva < KERNBASE)
f0103515:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010351a:	76 30                	jbe    f010354c <env_create+0x119>
	return (physaddr_t)kva - KERNBASE;
f010351c:	05 00 00 00 10       	add    $0x10000000,%eax
f0103521:	0f 22 d8             	mov    %eax,%cr3
	e->env_tf.tf_eip = ELFHDR->e_entry;
f0103524:	8b 46 18             	mov    0x18(%esi),%eax
f0103527:	89 47 30             	mov    %eax,0x30(%edi)
	region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);
f010352a:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010352f:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103534:	89 f8                	mov    %edi,%eax
f0103536:	e8 4f fa ff ff       	call   f0102f8a <region_alloc>
	e->env_type = type;
f010353b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010353e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103541:	89 50 50             	mov    %edx,0x50(%eax)
}
f0103544:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103547:	5b                   	pop    %ebx
f0103548:	5e                   	pop    %esi
f0103549:	5f                   	pop    %edi
f010354a:	5d                   	pop    %ebp
f010354b:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010354c:	50                   	push   %eax
f010354d:	68 48 68 10 f0       	push   $0xf0106848
f0103552:	68 8a 01 00 00       	push   $0x18a
f0103557:	68 47 7a 10 f0       	push   $0xf0107a47
f010355c:	e8 df ca ff ff       	call   f0100040 <_panic>

f0103561 <e_remove>:
 * @brief 			remove env e from MFQueue according to its priority
 * 
 * @param e 		the environment to remove
 */
void
e_remove(struct Env* e){
f0103561:	f3 0f 1e fb          	endbr32 
f0103565:	55                   	push   %ebp
f0103566:	89 e5                	mov    %esp,%ebp
f0103568:	53                   	push   %ebx
f0103569:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (MFQueue[e->priority].front == NULL) {
f010356c:	8b 43 7c             	mov    0x7c(%ebx),%eax
f010356f:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103572:	8b 14 95 84 fe 23 f0 	mov    -0xfdc017c(,%edx,4),%edx
f0103579:	85 d2                	test   %edx,%edx
f010357b:	74 44                	je     f01035c1 <e_remove+0x60>
		return;
	}
	if(MFQueue[e->priority].front->env == e){
f010357d:	39 5a 04             	cmp    %ebx,0x4(%edx)
f0103580:	74 22                	je     f01035a4 <e_remove+0x43>
		MFQueue[e->priority].front = MFQueue[e->priority].front->next;
		return;
	}
	Node* prev = MFQueue[e->priority].front;
	Node* cur = prev->next;
f0103582:	8b 02                	mov    (%edx),%eax
	while(cur->env != &envs[ENVX(e->env_id)] && cur != NULL){
f0103584:	8b 4b 48             	mov    0x48(%ebx),%ecx
f0103587:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
f010358d:	69 c9 84 00 00 00    	imul   $0x84,%ecx,%ecx
f0103593:	03 0d 44 f2 23 f0    	add    0xf023f244,%ecx
f0103599:	39 48 04             	cmp    %ecx,0x4(%eax)
f010359c:	74 14                	je     f01035b2 <e_remove+0x51>
		cur = cur->next;
f010359e:	8b 00                	mov    (%eax),%eax
		prev = prev->next;
f01035a0:	8b 12                	mov    (%edx),%edx
f01035a2:	eb f5                	jmp    f0103599 <e_remove+0x38>
		MFQueue[e->priority].front = MFQueue[e->priority].front->next;
f01035a4:	8b 12                	mov    (%edx),%edx
f01035a6:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01035a9:	89 14 85 84 fe 23 f0 	mov    %edx,-0xfdc017c(,%eax,4)
		return;
f01035b0:	eb 0f                	jmp    f01035c1 <e_remove+0x60>
	}
	if(cur == NULL){
		panic("e_remove error! Failed to remove env [%d] from MFQueue[%d]", e->env_id, e->priority);
	}
	prev->next = cur->next;
f01035b2:	8b 08                	mov    (%eax),%ecx
f01035b4:	89 0a                	mov    %ecx,(%edx)
	if (cur->next == NULL) {
f01035b6:	83 38 00             	cmpl   $0x0,(%eax)
f01035b9:	74 09                	je     f01035c4 <e_remove+0x63>
		MFQueue[e->priority].rear = prev;
	}
	cur->next = NULL;
f01035bb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	
f01035c1:	5b                   	pop    %ebx
f01035c2:	5d                   	pop    %ebp
f01035c3:	c3                   	ret    
		MFQueue[e->priority].rear = prev;
f01035c4:	8b 4b 7c             	mov    0x7c(%ebx),%ecx
f01035c7:	8d 0c 49             	lea    (%ecx,%ecx,2),%ecx
f01035ca:	89 14 8d 88 fe 23 f0 	mov    %edx,-0xfdc0178(,%ecx,4)
f01035d1:	eb e8                	jmp    f01035bb <e_remove+0x5a>

f01035d3 <env_free>:
{
f01035d3:	f3 0f 1e fb          	endbr32 
f01035d7:	55                   	push   %ebp
f01035d8:	89 e5                	mov    %esp,%ebp
f01035da:	57                   	push   %edi
f01035db:	56                   	push   %esi
f01035dc:	53                   	push   %ebx
f01035dd:	83 ec 1c             	sub    $0x1c,%esp
f01035e0:	8b 7d 08             	mov    0x8(%ebp),%edi
	if (e == curenv)
f01035e3:	e8 9a 2b 00 00       	call   f0106182 <cpunum>
f01035e8:	6b c0 74             	imul   $0x74,%eax,%eax
f01035eb:	39 b8 28 20 24 f0    	cmp    %edi,-0xfdbdfd8(%eax)
f01035f1:	74 48                	je     f010363b <env_free+0x68>
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01035f3:	8b 5f 48             	mov    0x48(%edi),%ebx
f01035f6:	e8 87 2b 00 00       	call   f0106182 <cpunum>
f01035fb:	6b c0 74             	imul   $0x74,%eax,%eax
f01035fe:	ba 00 00 00 00       	mov    $0x0,%edx
f0103603:	83 b8 28 20 24 f0 00 	cmpl   $0x0,-0xfdbdfd8(%eax)
f010360a:	74 11                	je     f010361d <env_free+0x4a>
f010360c:	e8 71 2b 00 00       	call   f0106182 <cpunum>
f0103611:	6b c0 74             	imul   $0x74,%eax,%eax
f0103614:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f010361a:	8b 50 48             	mov    0x48(%eax),%edx
f010361d:	83 ec 04             	sub    $0x4,%esp
f0103620:	53                   	push   %ebx
f0103621:	52                   	push   %edx
f0103622:	68 a0 7a 10 f0       	push   $0xf0107aa0
f0103627:	e8 9d 04 00 00       	call   f0103ac9 <cprintf>
f010362c:	83 c4 10             	add    $0x10,%esp
f010362f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103636:	e9 a9 00 00 00       	jmp    f01036e4 <env_free+0x111>
		lcr3(PADDR(kern_pgdir));
f010363b:	a1 c4 1e 24 f0       	mov    0xf0241ec4,%eax
	if ((uint32_t)kva < KERNBASE)
f0103640:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103645:	76 0a                	jbe    f0103651 <env_free+0x7e>
	return (physaddr_t)kva - KERNBASE;
f0103647:	05 00 00 00 10       	add    $0x10000000,%eax
f010364c:	0f 22 d8             	mov    %eax,%cr3
}
f010364f:	eb a2                	jmp    f01035f3 <env_free+0x20>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103651:	50                   	push   %eax
f0103652:	68 48 68 10 f0       	push   $0xf0106848
f0103657:	68 b7 01 00 00       	push   $0x1b7
f010365c:	68 47 7a 10 f0       	push   $0xf0107a47
f0103661:	e8 da c9 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103666:	56                   	push   %esi
f0103667:	68 24 68 10 f0       	push   $0xf0106824
f010366c:	68 c6 01 00 00       	push   $0x1c6
f0103671:	68 47 7a 10 f0       	push   $0xf0107a47
f0103676:	e8 c5 c9 ff ff       	call   f0100040 <_panic>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010367b:	83 ec 08             	sub    $0x8,%esp
f010367e:	89 d8                	mov    %ebx,%eax
f0103680:	c1 e0 0c             	shl    $0xc,%eax
f0103683:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103686:	50                   	push   %eax
f0103687:	ff 77 60             	pushl  0x60(%edi)
f010368a:	e8 08 db ff ff       	call   f0101197 <page_remove>
f010368f:	83 c4 10             	add    $0x10,%esp
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103692:	83 c3 01             	add    $0x1,%ebx
f0103695:	83 c6 04             	add    $0x4,%esi
f0103698:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010369e:	74 07                	je     f01036a7 <env_free+0xd4>
			if (pt[pteno] & PTE_P)
f01036a0:	f6 06 01             	testb  $0x1,(%esi)
f01036a3:	74 ed                	je     f0103692 <env_free+0xbf>
f01036a5:	eb d4                	jmp    f010367b <env_free+0xa8>
		e->env_pgdir[pdeno] = 0;
f01036a7:	8b 47 60             	mov    0x60(%edi),%eax
f01036aa:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01036ad:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f01036b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01036b7:	3b 05 c0 1e 24 f0    	cmp    0xf0241ec0,%eax
f01036bd:	73 65                	jae    f0103724 <env_free+0x151>
		page_decref(pa2page(pa));
f01036bf:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01036c2:	a1 c8 1e 24 f0       	mov    0xf0241ec8,%eax
f01036c7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01036ca:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01036cd:	50                   	push   %eax
f01036ce:	e8 e6 d8 ff ff       	call   f0100fb9 <page_decref>
f01036d3:	83 c4 10             	add    $0x10,%esp
f01036d6:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f01036da:	8b 45 e0             	mov    -0x20(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01036dd:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01036e2:	74 54                	je     f0103738 <env_free+0x165>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01036e4:	8b 47 60             	mov    0x60(%edi),%eax
f01036e7:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01036ea:	8b 04 10             	mov    (%eax,%edx,1),%eax
f01036ed:	a8 01                	test   $0x1,%al
f01036ef:	74 e5                	je     f01036d6 <env_free+0x103>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01036f1:	89 c6                	mov    %eax,%esi
f01036f3:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f01036f9:	c1 e8 0c             	shr    $0xc,%eax
f01036fc:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01036ff:	39 05 c0 1e 24 f0    	cmp    %eax,0xf0241ec0
f0103705:	0f 86 5b ff ff ff    	jbe    f0103666 <env_free+0x93>
	return (void *)(pa + KERNBASE);
f010370b:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f0103711:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103714:	c1 e0 14             	shl    $0x14,%eax
f0103717:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010371a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010371f:	e9 7c ff ff ff       	jmp    f01036a0 <env_free+0xcd>
		panic("pa2page called with invalid pa");
f0103724:	83 ec 04             	sub    $0x4,%esp
f0103727:	68 c8 6e 10 f0       	push   $0xf0106ec8
f010372c:	6a 51                	push   $0x51
f010372e:	68 71 77 10 f0       	push   $0xf0107771
f0103733:	e8 08 c9 ff ff       	call   f0100040 <_panic>
	pa = PADDR(e->env_pgdir);
f0103738:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f010373b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103740:	76 51                	jbe    f0103793 <env_free+0x1c0>
	e->env_pgdir = 0;
f0103742:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103749:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f010374e:	c1 e8 0c             	shr    $0xc,%eax
f0103751:	3b 05 c0 1e 24 f0    	cmp    0xf0241ec0,%eax
f0103757:	73 4f                	jae    f01037a8 <env_free+0x1d5>
	page_decref(pa2page(pa));
f0103759:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f010375c:	8b 15 c8 1e 24 f0    	mov    0xf0241ec8,%edx
f0103762:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103765:	50                   	push   %eax
f0103766:	e8 4e d8 ff ff       	call   f0100fb9 <page_decref>
	e->env_status = ENV_FREE;
f010376b:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103772:	a1 48 f2 23 f0       	mov    0xf023f248,%eax
f0103777:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010377a:	89 3d 48 f2 23 f0    	mov    %edi,0xf023f248
	e_remove(e);
f0103780:	89 3c 24             	mov    %edi,(%esp)
f0103783:	e8 d9 fd ff ff       	call   f0103561 <e_remove>
}
f0103788:	83 c4 10             	add    $0x10,%esp
f010378b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010378e:	5b                   	pop    %ebx
f010378f:	5e                   	pop    %esi
f0103790:	5f                   	pop    %edi
f0103791:	5d                   	pop    %ebp
f0103792:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103793:	50                   	push   %eax
f0103794:	68 48 68 10 f0       	push   $0xf0106848
f0103799:	68 d4 01 00 00       	push   $0x1d4
f010379e:	68 47 7a 10 f0       	push   $0xf0107a47
f01037a3:	e8 98 c8 ff ff       	call   f0100040 <_panic>
		panic("pa2page called with invalid pa");
f01037a8:	83 ec 04             	sub    $0x4,%esp
f01037ab:	68 c8 6e 10 f0       	push   $0xf0106ec8
f01037b0:	6a 51                	push   $0x51
f01037b2:	68 71 77 10 f0       	push   $0xf0107771
f01037b7:	e8 84 c8 ff ff       	call   f0100040 <_panic>

f01037bc <env_destroy>:
{
f01037bc:	f3 0f 1e fb          	endbr32 
f01037c0:	55                   	push   %ebp
f01037c1:	89 e5                	mov    %esp,%ebp
f01037c3:	53                   	push   %ebx
f01037c4:	83 ec 04             	sub    $0x4,%esp
f01037c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01037ca:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01037ce:	74 21                	je     f01037f1 <env_destroy+0x35>
	env_free(e);
f01037d0:	83 ec 0c             	sub    $0xc,%esp
f01037d3:	53                   	push   %ebx
f01037d4:	e8 fa fd ff ff       	call   f01035d3 <env_free>
	if (curenv == e) {
f01037d9:	e8 a4 29 00 00       	call   f0106182 <cpunum>
f01037de:	6b c0 74             	imul   $0x74,%eax,%eax
f01037e1:	83 c4 10             	add    $0x10,%esp
f01037e4:	39 98 28 20 24 f0    	cmp    %ebx,-0xfdbdfd8(%eax)
f01037ea:	74 1e                	je     f010380a <env_destroy+0x4e>
}
f01037ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01037ef:	c9                   	leave  
f01037f0:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01037f1:	e8 8c 29 00 00       	call   f0106182 <cpunum>
f01037f6:	6b c0 74             	imul   $0x74,%eax,%eax
f01037f9:	39 98 28 20 24 f0    	cmp    %ebx,-0xfdbdfd8(%eax)
f01037ff:	74 cf                	je     f01037d0 <env_destroy+0x14>
		e->env_status = ENV_DYING;
f0103801:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103808:	eb e2                	jmp    f01037ec <env_destroy+0x30>
		curenv = NULL;
f010380a:	e8 73 29 00 00       	call   f0106182 <cpunum>
f010380f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103812:	c7 80 28 20 24 f0 00 	movl   $0x0,-0xfdbdfd8(%eax)
f0103819:	00 00 00 
		sched_yield();
f010381c:	e8 1a 11 00 00       	call   f010493b <sched_yield>

f0103821 <env_run>:
{
f0103821:	f3 0f 1e fb          	endbr32 
f0103825:	55                   	push   %ebp
f0103826:	89 e5                	mov    %esp,%ebp
f0103828:	53                   	push   %ebx
f0103829:	83 ec 04             	sub    $0x4,%esp
f010382c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (curenv != NULL && curenv->env_status == ENV_RUNNING) {	
f010382f:	e8 4e 29 00 00       	call   f0106182 <cpunum>
f0103834:	6b c0 74             	imul   $0x74,%eax,%eax
f0103837:	83 b8 28 20 24 f0 00 	cmpl   $0x0,-0xfdbdfd8(%eax)
f010383e:	74 14                	je     f0103854 <env_run+0x33>
f0103840:	e8 3d 29 00 00       	call   f0106182 <cpunum>
f0103845:	6b c0 74             	imul   $0x74,%eax,%eax
f0103848:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f010384e:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103852:	74 78                	je     f01038cc <env_run+0xab>
	curenv = e;
f0103854:	e8 29 29 00 00       	call   f0106182 <cpunum>
f0103859:	6b c0 74             	imul   $0x74,%eax,%eax
f010385c:	89 98 28 20 24 f0    	mov    %ebx,-0xfdbdfd8(%eax)
	e->env_status = ENV_RUNNING;
f0103862:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
	e->env_runs++;
f0103869:	83 43 58 01          	addl   $0x1,0x58(%ebx)
	e->timeslice++;
f010386d:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
f0103873:	83 c0 01             	add    $0x1,%eax
f0103876:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	if (e->timeslice == MFQueue[e->priority].timelimit) {
f010387c:	8b 53 7c             	mov    0x7c(%ebx),%edx
f010387f:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103882:	3b 04 95 80 fe 23 f0 	cmp    -0xfdc0180(,%edx,4),%eax
f0103889:	74 5b                	je     f01038e6 <env_run+0xc5>
		e_remove(e);
f010388b:	83 ec 0c             	sub    $0xc,%esp
f010388e:	53                   	push   %ebx
f010388f:	e8 cd fc ff ff       	call   f0103561 <e_remove>
		e_insert(e->priority, e);
f0103894:	83 c4 08             	add    $0x8,%esp
f0103897:	53                   	push   %ebx
f0103898:	ff 73 7c             	pushl  0x7c(%ebx)
f010389b:	e8 2c f9 ff ff       	call   f01031cc <e_insert>
f01038a0:	83 c4 10             	add    $0x10,%esp
	lcr3(PADDR(e->env_pgdir));
f01038a3:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01038a6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01038ab:	76 64                	jbe    f0103911 <env_run+0xf0>
	return (physaddr_t)kva - KERNBASE;
f01038ad:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01038b2:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01038b5:	83 ec 0c             	sub    $0xc,%esp
f01038b8:	68 c0 43 12 f0       	push   $0xf01243c0
f01038bd:	e8 e6 2b 00 00       	call   f01064a8 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01038c2:	f3 90                	pause  
	env_pop_tf(&e->env_tf);
f01038c4:	89 1c 24             	mov    %ebx,(%esp)
f01038c7:	e8 be f8 ff ff       	call   f010318a <env_pop_tf>
		curenv->env_status = ENV_RUNNABLE;
f01038cc:	e8 b1 28 00 00       	call   f0106182 <cpunum>
f01038d1:	6b c0 74             	imul   $0x74,%eax,%eax
f01038d4:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f01038da:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f01038e1:	e9 6e ff ff ff       	jmp    f0103854 <env_run+0x33>
		e_remove(e);
f01038e6:	83 ec 0c             	sub    $0xc,%esp
f01038e9:	53                   	push   %ebx
f01038ea:	e8 72 fc ff ff       	call   f0103561 <e_remove>
		e->priority++;
f01038ef:	8b 43 7c             	mov    0x7c(%ebx),%eax
f01038f2:	83 c0 01             	add    $0x1,%eax
f01038f5:	89 43 7c             	mov    %eax,0x7c(%ebx)
		e->timeslice = 0;
f01038f8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
f01038ff:	00 00 00 
		e_insert(e->priority, e);
f0103902:	83 c4 08             	add    $0x8,%esp
f0103905:	53                   	push   %ebx
f0103906:	50                   	push   %eax
f0103907:	e8 c0 f8 ff ff       	call   f01031cc <e_insert>
f010390c:	83 c4 10             	add    $0x10,%esp
f010390f:	eb 92                	jmp    f01038a3 <env_run+0x82>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103911:	50                   	push   %eax
f0103912:	68 48 68 10 f0       	push   $0xf0106848
f0103917:	68 42 02 00 00       	push   $0x242
f010391c:	68 47 7a 10 f0       	push   $0xf0107a47
f0103921:	e8 1a c7 ff ff       	call   f0100040 <_panic>

f0103926 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103926:	f3 0f 1e fb          	endbr32 
f010392a:	55                   	push   %ebp
f010392b:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010392d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103930:	ba 70 00 00 00       	mov    $0x70,%edx
f0103935:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103936:	ba 71 00 00 00       	mov    $0x71,%edx
f010393b:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f010393c:	0f b6 c0             	movzbl %al,%eax
}
f010393f:	5d                   	pop    %ebp
f0103940:	c3                   	ret    

f0103941 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103941:	f3 0f 1e fb          	endbr32 
f0103945:	55                   	push   %ebp
f0103946:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103948:	8b 45 08             	mov    0x8(%ebp),%eax
f010394b:	ba 70 00 00 00       	mov    $0x70,%edx
f0103950:	ee                   	out    %al,(%dx)
f0103951:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103954:	ba 71 00 00 00       	mov    $0x71,%edx
f0103959:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010395a:	5d                   	pop    %ebp
f010395b:	c3                   	ret    

f010395c <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f010395c:	f3 0f 1e fb          	endbr32 
f0103960:	55                   	push   %ebp
f0103961:	89 e5                	mov    %esp,%ebp
f0103963:	56                   	push   %esi
f0103964:	53                   	push   %ebx
f0103965:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103968:	66 a3 a8 43 12 f0    	mov    %ax,0xf01243a8
	if (!didinit)
f010396e:	80 3d 4c f2 23 f0 00 	cmpb   $0x0,0xf023f24c
f0103975:	75 07                	jne    f010397e <irq_setmask_8259A+0x22>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f0103977:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010397a:	5b                   	pop    %ebx
f010397b:	5e                   	pop    %esi
f010397c:	5d                   	pop    %ebp
f010397d:	c3                   	ret    
f010397e:	89 c6                	mov    %eax,%esi
f0103980:	ba 21 00 00 00       	mov    $0x21,%edx
f0103985:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103986:	66 c1 e8 08          	shr    $0x8,%ax
f010398a:	ba a1 00 00 00       	mov    $0xa1,%edx
f010398f:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103990:	83 ec 0c             	sub    $0xc,%esp
f0103993:	68 b6 7a 10 f0       	push   $0xf0107ab6
f0103998:	e8 2c 01 00 00       	call   f0103ac9 <cprintf>
f010399d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01039a0:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01039a5:	0f b7 f6             	movzwl %si,%esi
f01039a8:	f7 d6                	not    %esi
f01039aa:	eb 19                	jmp    f01039c5 <irq_setmask_8259A+0x69>
			cprintf(" %d", i);
f01039ac:	83 ec 08             	sub    $0x8,%esp
f01039af:	53                   	push   %ebx
f01039b0:	68 9b 7f 10 f0       	push   $0xf0107f9b
f01039b5:	e8 0f 01 00 00       	call   f0103ac9 <cprintf>
f01039ba:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01039bd:	83 c3 01             	add    $0x1,%ebx
f01039c0:	83 fb 10             	cmp    $0x10,%ebx
f01039c3:	74 07                	je     f01039cc <irq_setmask_8259A+0x70>
		if (~mask & (1<<i))
f01039c5:	0f a3 de             	bt     %ebx,%esi
f01039c8:	73 f3                	jae    f01039bd <irq_setmask_8259A+0x61>
f01039ca:	eb e0                	jmp    f01039ac <irq_setmask_8259A+0x50>
	cprintf("\n");
f01039cc:	83 ec 0c             	sub    $0xc,%esp
f01039cf:	68 00 7a 10 f0       	push   $0xf0107a00
f01039d4:	e8 f0 00 00 00       	call   f0103ac9 <cprintf>
f01039d9:	83 c4 10             	add    $0x10,%esp
f01039dc:	eb 99                	jmp    f0103977 <irq_setmask_8259A+0x1b>

f01039de <pic_init>:
{
f01039de:	f3 0f 1e fb          	endbr32 
f01039e2:	55                   	push   %ebp
f01039e3:	89 e5                	mov    %esp,%ebp
f01039e5:	57                   	push   %edi
f01039e6:	56                   	push   %esi
f01039e7:	53                   	push   %ebx
f01039e8:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f01039eb:	c6 05 4c f2 23 f0 01 	movb   $0x1,0xf023f24c
f01039f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01039f7:	bb 21 00 00 00       	mov    $0x21,%ebx
f01039fc:	89 da                	mov    %ebx,%edx
f01039fe:	ee                   	out    %al,(%dx)
f01039ff:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f0103a04:	89 ca                	mov    %ecx,%edx
f0103a06:	ee                   	out    %al,(%dx)
f0103a07:	bf 11 00 00 00       	mov    $0x11,%edi
f0103a0c:	be 20 00 00 00       	mov    $0x20,%esi
f0103a11:	89 f8                	mov    %edi,%eax
f0103a13:	89 f2                	mov    %esi,%edx
f0103a15:	ee                   	out    %al,(%dx)
f0103a16:	b8 20 00 00 00       	mov    $0x20,%eax
f0103a1b:	89 da                	mov    %ebx,%edx
f0103a1d:	ee                   	out    %al,(%dx)
f0103a1e:	b8 04 00 00 00       	mov    $0x4,%eax
f0103a23:	ee                   	out    %al,(%dx)
f0103a24:	b8 03 00 00 00       	mov    $0x3,%eax
f0103a29:	ee                   	out    %al,(%dx)
f0103a2a:	bb a0 00 00 00       	mov    $0xa0,%ebx
f0103a2f:	89 f8                	mov    %edi,%eax
f0103a31:	89 da                	mov    %ebx,%edx
f0103a33:	ee                   	out    %al,(%dx)
f0103a34:	b8 28 00 00 00       	mov    $0x28,%eax
f0103a39:	89 ca                	mov    %ecx,%edx
f0103a3b:	ee                   	out    %al,(%dx)
f0103a3c:	b8 02 00 00 00       	mov    $0x2,%eax
f0103a41:	ee                   	out    %al,(%dx)
f0103a42:	b8 01 00 00 00       	mov    $0x1,%eax
f0103a47:	ee                   	out    %al,(%dx)
f0103a48:	bf 68 00 00 00       	mov    $0x68,%edi
f0103a4d:	89 f8                	mov    %edi,%eax
f0103a4f:	89 f2                	mov    %esi,%edx
f0103a51:	ee                   	out    %al,(%dx)
f0103a52:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0103a57:	89 c8                	mov    %ecx,%eax
f0103a59:	ee                   	out    %al,(%dx)
f0103a5a:	89 f8                	mov    %edi,%eax
f0103a5c:	89 da                	mov    %ebx,%edx
f0103a5e:	ee                   	out    %al,(%dx)
f0103a5f:	89 c8                	mov    %ecx,%eax
f0103a61:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f0103a62:	0f b7 05 a8 43 12 f0 	movzwl 0xf01243a8,%eax
f0103a69:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103a6d:	75 08                	jne    f0103a77 <pic_init+0x99>
}
f0103a6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103a72:	5b                   	pop    %ebx
f0103a73:	5e                   	pop    %esi
f0103a74:	5f                   	pop    %edi
f0103a75:	5d                   	pop    %ebp
f0103a76:	c3                   	ret    
		irq_setmask_8259A(irq_mask_8259A);
f0103a77:	83 ec 0c             	sub    $0xc,%esp
f0103a7a:	0f b7 c0             	movzwl %ax,%eax
f0103a7d:	50                   	push   %eax
f0103a7e:	e8 d9 fe ff ff       	call   f010395c <irq_setmask_8259A>
f0103a83:	83 c4 10             	add    $0x10,%esp
}
f0103a86:	eb e7                	jmp    f0103a6f <pic_init+0x91>

f0103a88 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103a88:	f3 0f 1e fb          	endbr32 
f0103a8c:	55                   	push   %ebp
f0103a8d:	89 e5                	mov    %esp,%ebp
f0103a8f:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103a92:	ff 75 08             	pushl  0x8(%ebp)
f0103a95:	e8 da cc ff ff       	call   f0100774 <cputchar>
	*cnt++;
}
f0103a9a:	83 c4 10             	add    $0x10,%esp
f0103a9d:	c9                   	leave  
f0103a9e:	c3                   	ret    

f0103a9f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103a9f:	f3 0f 1e fb          	endbr32 
f0103aa3:	55                   	push   %ebp
f0103aa4:	89 e5                	mov    %esp,%ebp
f0103aa6:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103aa9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103ab0:	ff 75 0c             	pushl  0xc(%ebp)
f0103ab3:	ff 75 08             	pushl  0x8(%ebp)
f0103ab6:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103ab9:	50                   	push   %eax
f0103aba:	68 88 3a 10 f0       	push   $0xf0103a88
f0103abf:	e8 48 19 00 00       	call   f010540c <vprintfmt>
	return cnt;
}
f0103ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103ac7:	c9                   	leave  
f0103ac8:	c3                   	ret    

f0103ac9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103ac9:	f3 0f 1e fb          	endbr32 
f0103acd:	55                   	push   %ebp
f0103ace:	89 e5                	mov    %esp,%ebp
f0103ad0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103ad3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103ad6:	50                   	push   %eax
f0103ad7:	ff 75 08             	pushl  0x8(%ebp)
f0103ada:	e8 c0 ff ff ff       	call   f0103a9f <vcprintf>
	va_end(ap);

	return cnt;
}
f0103adf:	c9                   	leave  
f0103ae0:	c3                   	ret    

f0103ae1 <trap_init_percpu>:
	trap_init_percpu();
}

// Initialize and load the per-CPU TSS and IDT
void trap_init_percpu(void)
{
f0103ae1:	f3 0f 1e fb          	endbr32 
f0103ae5:	55                   	push   %ebp
f0103ae6:	89 e5                	mov    %esp,%ebp
f0103ae8:	57                   	push   %edi
f0103ae9:	56                   	push   %esi
f0103aea:	53                   	push   %ebx
f0103aeb:	83 ec 0c             	sub    $0xc,%esp
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	int cid = thiscpu->cpu_id;
f0103aee:	e8 8f 26 00 00       	call   f0106182 <cpunum>
f0103af3:	6b c0 74             	imul   $0x74,%eax,%eax
f0103af6:	0f b6 98 20 20 24 f0 	movzbl -0xfdbdfe0(%eax),%ebx
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cid * (KSTKSIZE + KSTKGAP);
f0103afd:	e8 80 26 00 00       	call   f0106182 <cpunum>
f0103b02:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b05:	89 d9                	mov    %ebx,%ecx
f0103b07:	c1 e1 10             	shl    $0x10,%ecx
f0103b0a:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0103b0f:	29 ca                	sub    %ecx,%edx
f0103b11:	89 90 30 20 24 f0    	mov    %edx,-0xfdbdfd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103b17:	e8 66 26 00 00       	call   f0106182 <cpunum>
f0103b1c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b1f:	66 c7 80 34 20 24 f0 	movw   $0x10,-0xfdbdfcc(%eax)
f0103b26:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cid] = SEG16(STS_T32A, (uint32_t)(&(thiscpu->cpu_ts)),
f0103b28:	83 c3 05             	add    $0x5,%ebx
f0103b2b:	e8 52 26 00 00       	call   f0106182 <cpunum>
f0103b30:	89 c7                	mov    %eax,%edi
f0103b32:	e8 4b 26 00 00       	call   f0106182 <cpunum>
f0103b37:	89 c6                	mov    %eax,%esi
f0103b39:	e8 44 26 00 00       	call   f0106182 <cpunum>
f0103b3e:	66 c7 04 dd 40 43 12 	movw   $0x68,-0xfedbcc0(,%ebx,8)
f0103b45:	f0 68 00 
f0103b48:	6b ff 74             	imul   $0x74,%edi,%edi
f0103b4b:	81 c7 2c 20 24 f0    	add    $0xf024202c,%edi
f0103b51:	66 89 3c dd 42 43 12 	mov    %di,-0xfedbcbe(,%ebx,8)
f0103b58:	f0 
f0103b59:	6b d6 74             	imul   $0x74,%esi,%edx
f0103b5c:	81 c2 2c 20 24 f0    	add    $0xf024202c,%edx
f0103b62:	c1 ea 10             	shr    $0x10,%edx
f0103b65:	88 14 dd 44 43 12 f0 	mov    %dl,-0xfedbcbc(,%ebx,8)
f0103b6c:	c6 04 dd 46 43 12 f0 	movb   $0x40,-0xfedbcba(,%ebx,8)
f0103b73:	40 
f0103b74:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b77:	05 2c 20 24 f0       	add    $0xf024202c,%eax
f0103b7c:	c1 e8 18             	shr    $0x18,%eax
f0103b7f:	88 04 dd 47 43 12 f0 	mov    %al,-0xfedbcb9(,%ebx,8)
									  sizeof(struct Taskstate), 0);
	gdt[(GD_TSS0 >> 3) + cid].sd_s = 0;
f0103b86:	c6 04 dd 45 43 12 f0 	movb   $0x89,-0xfedbcbb(,%ebx,8)
f0103b8d:	89 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + 8 * cid);
f0103b8e:	c1 e3 03             	shl    $0x3,%ebx
	asm volatile("ltr %0" : : "r" (sel));
f0103b91:	0f 00 db             	ltr    %bx
	asm volatile("lidt (%0)" : : "r" (p));
f0103b94:	b8 ac 43 12 f0       	mov    $0xf01243ac,%eax
f0103b99:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0103b9c:	83 c4 0c             	add    $0xc,%esp
f0103b9f:	5b                   	pop    %ebx
f0103ba0:	5e                   	pop    %esi
f0103ba1:	5f                   	pop    %edi
f0103ba2:	5d                   	pop    %ebp
f0103ba3:	c3                   	ret    

f0103ba4 <trap_init>:
{
f0103ba4:	f3 0f 1e fb          	endbr32 
f0103ba8:	55                   	push   %ebp
f0103ba9:	89 e5                	mov    %esp,%ebp
f0103bab:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[T_DIVIDE], 0, GD_KT, &th_divide, 0);
f0103bae:	b8 74 47 10 f0       	mov    $0xf0104774,%eax
f0103bb3:	66 a3 60 f2 23 f0    	mov    %ax,0xf023f260
f0103bb9:	66 c7 05 62 f2 23 f0 	movw   $0x8,0xf023f262
f0103bc0:	08 00 
f0103bc2:	c6 05 64 f2 23 f0 00 	movb   $0x0,0xf023f264
f0103bc9:	c6 05 65 f2 23 f0 8e 	movb   $0x8e,0xf023f265
f0103bd0:	c1 e8 10             	shr    $0x10,%eax
f0103bd3:	66 a3 66 f2 23 f0    	mov    %ax,0xf023f266
	SETGATE(idt[T_DEBUG], 0, GD_KT, &th_debug, 0);
f0103bd9:	b8 7e 47 10 f0       	mov    $0xf010477e,%eax
f0103bde:	66 a3 68 f2 23 f0    	mov    %ax,0xf023f268
f0103be4:	66 c7 05 6a f2 23 f0 	movw   $0x8,0xf023f26a
f0103beb:	08 00 
f0103bed:	c6 05 6c f2 23 f0 00 	movb   $0x0,0xf023f26c
f0103bf4:	c6 05 6d f2 23 f0 8e 	movb   $0x8e,0xf023f26d
f0103bfb:	c1 e8 10             	shr    $0x10,%eax
f0103bfe:	66 a3 6e f2 23 f0    	mov    %ax,0xf023f26e
	SETGATE(idt[T_NMI], 0, GD_KT, &th_nmi, 0);
f0103c04:	b8 88 47 10 f0       	mov    $0xf0104788,%eax
f0103c09:	66 a3 70 f2 23 f0    	mov    %ax,0xf023f270
f0103c0f:	66 c7 05 72 f2 23 f0 	movw   $0x8,0xf023f272
f0103c16:	08 00 
f0103c18:	c6 05 74 f2 23 f0 00 	movb   $0x0,0xf023f274
f0103c1f:	c6 05 75 f2 23 f0 8e 	movb   $0x8e,0xf023f275
f0103c26:	c1 e8 10             	shr    $0x10,%eax
f0103c29:	66 a3 76 f2 23 f0    	mov    %ax,0xf023f276
	SETGATE(idt[T_BRKPT], 0, GD_KT, &th_brkpt, 0);
f0103c2f:	b8 92 47 10 f0       	mov    $0xf0104792,%eax
f0103c34:	66 a3 78 f2 23 f0    	mov    %ax,0xf023f278
f0103c3a:	66 c7 05 7a f2 23 f0 	movw   $0x8,0xf023f27a
f0103c41:	08 00 
f0103c43:	c6 05 7c f2 23 f0 00 	movb   $0x0,0xf023f27c
f0103c4a:	c6 05 7d f2 23 f0 8e 	movb   $0x8e,0xf023f27d
f0103c51:	c1 e8 10             	shr    $0x10,%eax
f0103c54:	66 a3 7e f2 23 f0    	mov    %ax,0xf023f27e
	SETGATE(idt[T_OFLOW], 0, GD_KT, &th_oflow, 0);
f0103c5a:	b8 9c 47 10 f0       	mov    $0xf010479c,%eax
f0103c5f:	66 a3 80 f2 23 f0    	mov    %ax,0xf023f280
f0103c65:	66 c7 05 82 f2 23 f0 	movw   $0x8,0xf023f282
f0103c6c:	08 00 
f0103c6e:	c6 05 84 f2 23 f0 00 	movb   $0x0,0xf023f284
f0103c75:	c6 05 85 f2 23 f0 8e 	movb   $0x8e,0xf023f285
f0103c7c:	c1 e8 10             	shr    $0x10,%eax
f0103c7f:	66 a3 86 f2 23 f0    	mov    %ax,0xf023f286
	SETGATE(idt[T_BOUND], 0, GD_KT, &th_bound, 0);
f0103c85:	b8 a6 47 10 f0       	mov    $0xf01047a6,%eax
f0103c8a:	66 a3 88 f2 23 f0    	mov    %ax,0xf023f288
f0103c90:	66 c7 05 8a f2 23 f0 	movw   $0x8,0xf023f28a
f0103c97:	08 00 
f0103c99:	c6 05 8c f2 23 f0 00 	movb   $0x0,0xf023f28c
f0103ca0:	c6 05 8d f2 23 f0 8e 	movb   $0x8e,0xf023f28d
f0103ca7:	c1 e8 10             	shr    $0x10,%eax
f0103caa:	66 a3 8e f2 23 f0    	mov    %ax,0xf023f28e
	SETGATE(idt[T_ILLOP], 0, GD_KT, &th_illop, 0);
f0103cb0:	b8 b0 47 10 f0       	mov    $0xf01047b0,%eax
f0103cb5:	66 a3 90 f2 23 f0    	mov    %ax,0xf023f290
f0103cbb:	66 c7 05 92 f2 23 f0 	movw   $0x8,0xf023f292
f0103cc2:	08 00 
f0103cc4:	c6 05 94 f2 23 f0 00 	movb   $0x0,0xf023f294
f0103ccb:	c6 05 95 f2 23 f0 8e 	movb   $0x8e,0xf023f295
f0103cd2:	c1 e8 10             	shr    $0x10,%eax
f0103cd5:	66 a3 96 f2 23 f0    	mov    %ax,0xf023f296
	SETGATE(idt[T_DEVICE], 0, GD_KT, &th_device, 0);
f0103cdb:	b8 ba 47 10 f0       	mov    $0xf01047ba,%eax
f0103ce0:	66 a3 98 f2 23 f0    	mov    %ax,0xf023f298
f0103ce6:	66 c7 05 9a f2 23 f0 	movw   $0x8,0xf023f29a
f0103ced:	08 00 
f0103cef:	c6 05 9c f2 23 f0 00 	movb   $0x0,0xf023f29c
f0103cf6:	c6 05 9d f2 23 f0 8e 	movb   $0x8e,0xf023f29d
f0103cfd:	c1 e8 10             	shr    $0x10,%eax
f0103d00:	66 a3 9e f2 23 f0    	mov    %ax,0xf023f29e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, &th_dblflt, 0);
f0103d06:	b8 c4 47 10 f0       	mov    $0xf01047c4,%eax
f0103d0b:	66 a3 a0 f2 23 f0    	mov    %ax,0xf023f2a0
f0103d11:	66 c7 05 a2 f2 23 f0 	movw   $0x8,0xf023f2a2
f0103d18:	08 00 
f0103d1a:	c6 05 a4 f2 23 f0 00 	movb   $0x0,0xf023f2a4
f0103d21:	c6 05 a5 f2 23 f0 8e 	movb   $0x8e,0xf023f2a5
f0103d28:	c1 e8 10             	shr    $0x10,%eax
f0103d2b:	66 a3 a6 f2 23 f0    	mov    %ax,0xf023f2a6
	SETGATE(idt[T_TSS], 0, GD_KT, &th_tss, 0);
f0103d31:	b8 d6 47 10 f0       	mov    $0xf01047d6,%eax
f0103d36:	66 a3 b0 f2 23 f0    	mov    %ax,0xf023f2b0
f0103d3c:	66 c7 05 b2 f2 23 f0 	movw   $0x8,0xf023f2b2
f0103d43:	08 00 
f0103d45:	c6 05 b4 f2 23 f0 00 	movb   $0x0,0xf023f2b4
f0103d4c:	c6 05 b5 f2 23 f0 8e 	movb   $0x8e,0xf023f2b5
f0103d53:	c1 e8 10             	shr    $0x10,%eax
f0103d56:	66 a3 b6 f2 23 f0    	mov    %ax,0xf023f2b6
	SETGATE(idt[9], 0, GD_KT, &th9, 0);
f0103d5c:	b8 cc 47 10 f0       	mov    $0xf01047cc,%eax
f0103d61:	66 a3 a8 f2 23 f0    	mov    %ax,0xf023f2a8
f0103d67:	66 c7 05 aa f2 23 f0 	movw   $0x8,0xf023f2aa
f0103d6e:	08 00 
f0103d70:	c6 05 ac f2 23 f0 00 	movb   $0x0,0xf023f2ac
f0103d77:	c6 05 ad f2 23 f0 8e 	movb   $0x8e,0xf023f2ad
f0103d7e:	c1 e8 10             	shr    $0x10,%eax
f0103d81:	66 a3 ae f2 23 f0    	mov    %ax,0xf023f2ae
	SETGATE(idt[T_SEGNP], 0, GD_KT, &th_segnp, 0);
f0103d87:	b8 da 47 10 f0       	mov    $0xf01047da,%eax
f0103d8c:	66 a3 b8 f2 23 f0    	mov    %ax,0xf023f2b8
f0103d92:	66 c7 05 ba f2 23 f0 	movw   $0x8,0xf023f2ba
f0103d99:	08 00 
f0103d9b:	c6 05 bc f2 23 f0 00 	movb   $0x0,0xf023f2bc
f0103da2:	c6 05 bd f2 23 f0 8e 	movb   $0x8e,0xf023f2bd
f0103da9:	c1 e8 10             	shr    $0x10,%eax
f0103dac:	66 a3 be f2 23 f0    	mov    %ax,0xf023f2be
	SETGATE(idt[T_STACK], 0, GD_KT, &th_stack, 0);
f0103db2:	b8 de 47 10 f0       	mov    $0xf01047de,%eax
f0103db7:	66 a3 c0 f2 23 f0    	mov    %ax,0xf023f2c0
f0103dbd:	66 c7 05 c2 f2 23 f0 	movw   $0x8,0xf023f2c2
f0103dc4:	08 00 
f0103dc6:	c6 05 c4 f2 23 f0 00 	movb   $0x0,0xf023f2c4
f0103dcd:	c6 05 c5 f2 23 f0 8e 	movb   $0x8e,0xf023f2c5
f0103dd4:	c1 e8 10             	shr    $0x10,%eax
f0103dd7:	66 a3 c6 f2 23 f0    	mov    %ax,0xf023f2c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, &th_gpflt, 0);
f0103ddd:	b8 e2 47 10 f0       	mov    $0xf01047e2,%eax
f0103de2:	66 a3 c8 f2 23 f0    	mov    %ax,0xf023f2c8
f0103de8:	66 c7 05 ca f2 23 f0 	movw   $0x8,0xf023f2ca
f0103def:	08 00 
f0103df1:	c6 05 cc f2 23 f0 00 	movb   $0x0,0xf023f2cc
f0103df8:	c6 05 cd f2 23 f0 8e 	movb   $0x8e,0xf023f2cd
f0103dff:	c1 e8 10             	shr    $0x10,%eax
f0103e02:	66 a3 ce f2 23 f0    	mov    %ax,0xf023f2ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, &th_pgflt, 0);
f0103e08:	b8 e6 47 10 f0       	mov    $0xf01047e6,%eax
f0103e0d:	66 a3 d0 f2 23 f0    	mov    %ax,0xf023f2d0
f0103e13:	66 c7 05 d2 f2 23 f0 	movw   $0x8,0xf023f2d2
f0103e1a:	08 00 
f0103e1c:	c6 05 d4 f2 23 f0 00 	movb   $0x0,0xf023f2d4
f0103e23:	c6 05 d5 f2 23 f0 8e 	movb   $0x8e,0xf023f2d5
f0103e2a:	c1 e8 10             	shr    $0x10,%eax
f0103e2d:	66 a3 d6 f2 23 f0    	mov    %ax,0xf023f2d6
	SETGATE(idt[T_FPERR], 0, GD_KT, &th_fperr, 0);
f0103e33:	b8 ea 47 10 f0       	mov    $0xf01047ea,%eax
f0103e38:	66 a3 e0 f2 23 f0    	mov    %ax,0xf023f2e0
f0103e3e:	66 c7 05 e2 f2 23 f0 	movw   $0x8,0xf023f2e2
f0103e45:	08 00 
f0103e47:	c6 05 e4 f2 23 f0 00 	movb   $0x0,0xf023f2e4
f0103e4e:	c6 05 e5 f2 23 f0 8e 	movb   $0x8e,0xf023f2e5
f0103e55:	c1 e8 10             	shr    $0x10,%eax
f0103e58:	66 a3 e6 f2 23 f0    	mov    %ax,0xf023f2e6
	SETGATE(idt[IRQ_OFFSET], 0, GD_KT, th32, 0);
f0103e5e:	b8 f0 47 10 f0       	mov    $0xf01047f0,%eax
f0103e63:	66 a3 60 f3 23 f0    	mov    %ax,0xf023f360
f0103e69:	66 c7 05 62 f3 23 f0 	movw   $0x8,0xf023f362
f0103e70:	08 00 
f0103e72:	c6 05 64 f3 23 f0 00 	movb   $0x0,0xf023f364
f0103e79:	c6 05 65 f3 23 f0 8e 	movb   $0x8e,0xf023f365
f0103e80:	c1 e8 10             	shr    $0x10,%eax
f0103e83:	66 a3 66 f3 23 f0    	mov    %ax,0xf023f366
	SETGATE(idt[IRQ_OFFSET + 1], 0, GD_KT, th33, 0);
f0103e89:	b8 f6 47 10 f0       	mov    $0xf01047f6,%eax
f0103e8e:	66 a3 68 f3 23 f0    	mov    %ax,0xf023f368
f0103e94:	66 c7 05 6a f3 23 f0 	movw   $0x8,0xf023f36a
f0103e9b:	08 00 
f0103e9d:	c6 05 6c f3 23 f0 00 	movb   $0x0,0xf023f36c
f0103ea4:	c6 05 6d f3 23 f0 8e 	movb   $0x8e,0xf023f36d
f0103eab:	c1 e8 10             	shr    $0x10,%eax
f0103eae:	66 a3 6e f3 23 f0    	mov    %ax,0xf023f36e
	SETGATE(idt[IRQ_OFFSET + 2], 0, GD_KT, th34, 0);
f0103eb4:	b8 fc 47 10 f0       	mov    $0xf01047fc,%eax
f0103eb9:	66 a3 70 f3 23 f0    	mov    %ax,0xf023f370
f0103ebf:	66 c7 05 72 f3 23 f0 	movw   $0x8,0xf023f372
f0103ec6:	08 00 
f0103ec8:	c6 05 74 f3 23 f0 00 	movb   $0x0,0xf023f374
f0103ecf:	c6 05 75 f3 23 f0 8e 	movb   $0x8e,0xf023f375
f0103ed6:	c1 e8 10             	shr    $0x10,%eax
f0103ed9:	66 a3 76 f3 23 f0    	mov    %ax,0xf023f376
	SETGATE(idt[IRQ_OFFSET + 3], 0, GD_KT, th35, 0);
f0103edf:	b8 02 48 10 f0       	mov    $0xf0104802,%eax
f0103ee4:	66 a3 78 f3 23 f0    	mov    %ax,0xf023f378
f0103eea:	66 c7 05 7a f3 23 f0 	movw   $0x8,0xf023f37a
f0103ef1:	08 00 
f0103ef3:	c6 05 7c f3 23 f0 00 	movb   $0x0,0xf023f37c
f0103efa:	c6 05 7d f3 23 f0 8e 	movb   $0x8e,0xf023f37d
f0103f01:	c1 e8 10             	shr    $0x10,%eax
f0103f04:	66 a3 7e f3 23 f0    	mov    %ax,0xf023f37e
	SETGATE(idt[IRQ_OFFSET + 4], 0, GD_KT, th36, 0);
f0103f0a:	b8 08 48 10 f0       	mov    $0xf0104808,%eax
f0103f0f:	66 a3 80 f3 23 f0    	mov    %ax,0xf023f380
f0103f15:	66 c7 05 82 f3 23 f0 	movw   $0x8,0xf023f382
f0103f1c:	08 00 
f0103f1e:	c6 05 84 f3 23 f0 00 	movb   $0x0,0xf023f384
f0103f25:	c6 05 85 f3 23 f0 8e 	movb   $0x8e,0xf023f385
f0103f2c:	c1 e8 10             	shr    $0x10,%eax
f0103f2f:	66 a3 86 f3 23 f0    	mov    %ax,0xf023f386
	SETGATE(idt[IRQ_OFFSET + 5], 0, GD_KT, th37, 0);
f0103f35:	b8 0e 48 10 f0       	mov    $0xf010480e,%eax
f0103f3a:	66 a3 88 f3 23 f0    	mov    %ax,0xf023f388
f0103f40:	66 c7 05 8a f3 23 f0 	movw   $0x8,0xf023f38a
f0103f47:	08 00 
f0103f49:	c6 05 8c f3 23 f0 00 	movb   $0x0,0xf023f38c
f0103f50:	c6 05 8d f3 23 f0 8e 	movb   $0x8e,0xf023f38d
f0103f57:	c1 e8 10             	shr    $0x10,%eax
f0103f5a:	66 a3 8e f3 23 f0    	mov    %ax,0xf023f38e
	SETGATE(idt[IRQ_OFFSET + 6], 0, GD_KT, th38, 0);
f0103f60:	b8 14 48 10 f0       	mov    $0xf0104814,%eax
f0103f65:	66 a3 90 f3 23 f0    	mov    %ax,0xf023f390
f0103f6b:	66 c7 05 92 f3 23 f0 	movw   $0x8,0xf023f392
f0103f72:	08 00 
f0103f74:	c6 05 94 f3 23 f0 00 	movb   $0x0,0xf023f394
f0103f7b:	c6 05 95 f3 23 f0 8e 	movb   $0x8e,0xf023f395
f0103f82:	c1 e8 10             	shr    $0x10,%eax
f0103f85:	66 a3 96 f3 23 f0    	mov    %ax,0xf023f396
	SETGATE(idt[IRQ_OFFSET + 7], 0, GD_KT, th39, 0);
f0103f8b:	b8 1a 48 10 f0       	mov    $0xf010481a,%eax
f0103f90:	66 a3 98 f3 23 f0    	mov    %ax,0xf023f398
f0103f96:	66 c7 05 9a f3 23 f0 	movw   $0x8,0xf023f39a
f0103f9d:	08 00 
f0103f9f:	c6 05 9c f3 23 f0 00 	movb   $0x0,0xf023f39c
f0103fa6:	c6 05 9d f3 23 f0 8e 	movb   $0x8e,0xf023f39d
f0103fad:	c1 e8 10             	shr    $0x10,%eax
f0103fb0:	66 a3 9e f3 23 f0    	mov    %ax,0xf023f39e
	SETGATE(idt[IRQ_OFFSET + 8], 0, GD_KT, th40, 0);
f0103fb6:	b8 20 48 10 f0       	mov    $0xf0104820,%eax
f0103fbb:	66 a3 a0 f3 23 f0    	mov    %ax,0xf023f3a0
f0103fc1:	66 c7 05 a2 f3 23 f0 	movw   $0x8,0xf023f3a2
f0103fc8:	08 00 
f0103fca:	c6 05 a4 f3 23 f0 00 	movb   $0x0,0xf023f3a4
f0103fd1:	c6 05 a5 f3 23 f0 8e 	movb   $0x8e,0xf023f3a5
f0103fd8:	c1 e8 10             	shr    $0x10,%eax
f0103fdb:	66 a3 a6 f3 23 f0    	mov    %ax,0xf023f3a6
	SETGATE(idt[IRQ_OFFSET + 9], 0, GD_KT, th41, 0);
f0103fe1:	b8 26 48 10 f0       	mov    $0xf0104826,%eax
f0103fe6:	66 a3 a8 f3 23 f0    	mov    %ax,0xf023f3a8
f0103fec:	66 c7 05 aa f3 23 f0 	movw   $0x8,0xf023f3aa
f0103ff3:	08 00 
f0103ff5:	c6 05 ac f3 23 f0 00 	movb   $0x0,0xf023f3ac
f0103ffc:	c6 05 ad f3 23 f0 8e 	movb   $0x8e,0xf023f3ad
f0104003:	c1 e8 10             	shr    $0x10,%eax
f0104006:	66 a3 ae f3 23 f0    	mov    %ax,0xf023f3ae
	SETGATE(idt[IRQ_OFFSET + 10], 0, GD_KT, th42, 0);
f010400c:	b8 2c 48 10 f0       	mov    $0xf010482c,%eax
f0104011:	66 a3 b0 f3 23 f0    	mov    %ax,0xf023f3b0
f0104017:	66 c7 05 b2 f3 23 f0 	movw   $0x8,0xf023f3b2
f010401e:	08 00 
f0104020:	c6 05 b4 f3 23 f0 00 	movb   $0x0,0xf023f3b4
f0104027:	c6 05 b5 f3 23 f0 8e 	movb   $0x8e,0xf023f3b5
f010402e:	c1 e8 10             	shr    $0x10,%eax
f0104031:	66 a3 b6 f3 23 f0    	mov    %ax,0xf023f3b6
	SETGATE(idt[IRQ_OFFSET + 11], 0, GD_KT, th43, 0);
f0104037:	b8 32 48 10 f0       	mov    $0xf0104832,%eax
f010403c:	66 a3 b8 f3 23 f0    	mov    %ax,0xf023f3b8
f0104042:	66 c7 05 ba f3 23 f0 	movw   $0x8,0xf023f3ba
f0104049:	08 00 
f010404b:	c6 05 bc f3 23 f0 00 	movb   $0x0,0xf023f3bc
f0104052:	c6 05 bd f3 23 f0 8e 	movb   $0x8e,0xf023f3bd
f0104059:	c1 e8 10             	shr    $0x10,%eax
f010405c:	66 a3 be f3 23 f0    	mov    %ax,0xf023f3be
	SETGATE(idt[IRQ_OFFSET + 12], 0, GD_KT, th44, 0);
f0104062:	b8 38 48 10 f0       	mov    $0xf0104838,%eax
f0104067:	66 a3 c0 f3 23 f0    	mov    %ax,0xf023f3c0
f010406d:	66 c7 05 c2 f3 23 f0 	movw   $0x8,0xf023f3c2
f0104074:	08 00 
f0104076:	c6 05 c4 f3 23 f0 00 	movb   $0x0,0xf023f3c4
f010407d:	c6 05 c5 f3 23 f0 8e 	movb   $0x8e,0xf023f3c5
f0104084:	c1 e8 10             	shr    $0x10,%eax
f0104087:	66 a3 c6 f3 23 f0    	mov    %ax,0xf023f3c6
	SETGATE(idt[IRQ_OFFSET + 13], 0, GD_KT, th45, 0);
f010408d:	b8 3e 48 10 f0       	mov    $0xf010483e,%eax
f0104092:	66 a3 c8 f3 23 f0    	mov    %ax,0xf023f3c8
f0104098:	66 c7 05 ca f3 23 f0 	movw   $0x8,0xf023f3ca
f010409f:	08 00 
f01040a1:	c6 05 cc f3 23 f0 00 	movb   $0x0,0xf023f3cc
f01040a8:	c6 05 cd f3 23 f0 8e 	movb   $0x8e,0xf023f3cd
f01040af:	c1 e8 10             	shr    $0x10,%eax
f01040b2:	66 a3 ce f3 23 f0    	mov    %ax,0xf023f3ce
	SETGATE(idt[IRQ_OFFSET + 14], 0, GD_KT, th46, 0);
f01040b8:	b8 44 48 10 f0       	mov    $0xf0104844,%eax
f01040bd:	66 a3 d0 f3 23 f0    	mov    %ax,0xf023f3d0
f01040c3:	66 c7 05 d2 f3 23 f0 	movw   $0x8,0xf023f3d2
f01040ca:	08 00 
f01040cc:	c6 05 d4 f3 23 f0 00 	movb   $0x0,0xf023f3d4
f01040d3:	c6 05 d5 f3 23 f0 8e 	movb   $0x8e,0xf023f3d5
f01040da:	c1 e8 10             	shr    $0x10,%eax
f01040dd:	66 a3 d6 f3 23 f0    	mov    %ax,0xf023f3d6
	SETGATE(idt[IRQ_OFFSET + 15], 0, GD_KT, th47, 0);
f01040e3:	b8 4a 48 10 f0       	mov    $0xf010484a,%eax
f01040e8:	66 a3 d8 f3 23 f0    	mov    %ax,0xf023f3d8
f01040ee:	66 c7 05 da f3 23 f0 	movw   $0x8,0xf023f3da
f01040f5:	08 00 
f01040f7:	c6 05 dc f3 23 f0 00 	movb   $0x0,0xf023f3dc
f01040fe:	c6 05 dd f3 23 f0 8e 	movb   $0x8e,0xf023f3dd
f0104105:	c1 e8 10             	shr    $0x10,%eax
f0104108:	66 a3 de f3 23 f0    	mov    %ax,0xf023f3de
	SETGATE(idt[T_SYSCALL], 0, GD_KT, th_syscall, 3);
f010410e:	b8 50 48 10 f0       	mov    $0xf0104850,%eax
f0104113:	66 a3 e0 f3 23 f0    	mov    %ax,0xf023f3e0
f0104119:	66 c7 05 e2 f3 23 f0 	movw   $0x8,0xf023f3e2
f0104120:	08 00 
f0104122:	c6 05 e4 f3 23 f0 00 	movb   $0x0,0xf023f3e4
f0104129:	c6 05 e5 f3 23 f0 ee 	movb   $0xee,0xf023f3e5
f0104130:	c1 e8 10             	shr    $0x10,%eax
f0104133:	66 a3 e6 f3 23 f0    	mov    %ax,0xf023f3e6
	trap_init_percpu();
f0104139:	e8 a3 f9 ff ff       	call   f0103ae1 <trap_init_percpu>
}
f010413e:	c9                   	leave  
f010413f:	c3                   	ret    

f0104140 <print_regs>:
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
	}
}

void print_regs(struct PushRegs *regs)
{
f0104140:	f3 0f 1e fb          	endbr32 
f0104144:	55                   	push   %ebp
f0104145:	89 e5                	mov    %esp,%ebp
f0104147:	53                   	push   %ebx
f0104148:	83 ec 0c             	sub    $0xc,%esp
f010414b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010414e:	ff 33                	pushl  (%ebx)
f0104150:	68 ca 7a 10 f0       	push   $0xf0107aca
f0104155:	e8 6f f9 ff ff       	call   f0103ac9 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010415a:	83 c4 08             	add    $0x8,%esp
f010415d:	ff 73 04             	pushl  0x4(%ebx)
f0104160:	68 d9 7a 10 f0       	push   $0xf0107ad9
f0104165:	e8 5f f9 ff ff       	call   f0103ac9 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010416a:	83 c4 08             	add    $0x8,%esp
f010416d:	ff 73 08             	pushl  0x8(%ebx)
f0104170:	68 e8 7a 10 f0       	push   $0xf0107ae8
f0104175:	e8 4f f9 ff ff       	call   f0103ac9 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f010417a:	83 c4 08             	add    $0x8,%esp
f010417d:	ff 73 0c             	pushl  0xc(%ebx)
f0104180:	68 f7 7a 10 f0       	push   $0xf0107af7
f0104185:	e8 3f f9 ff ff       	call   f0103ac9 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010418a:	83 c4 08             	add    $0x8,%esp
f010418d:	ff 73 10             	pushl  0x10(%ebx)
f0104190:	68 06 7b 10 f0       	push   $0xf0107b06
f0104195:	e8 2f f9 ff ff       	call   f0103ac9 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010419a:	83 c4 08             	add    $0x8,%esp
f010419d:	ff 73 14             	pushl  0x14(%ebx)
f01041a0:	68 15 7b 10 f0       	push   $0xf0107b15
f01041a5:	e8 1f f9 ff ff       	call   f0103ac9 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01041aa:	83 c4 08             	add    $0x8,%esp
f01041ad:	ff 73 18             	pushl  0x18(%ebx)
f01041b0:	68 24 7b 10 f0       	push   $0xf0107b24
f01041b5:	e8 0f f9 ff ff       	call   f0103ac9 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01041ba:	83 c4 08             	add    $0x8,%esp
f01041bd:	ff 73 1c             	pushl  0x1c(%ebx)
f01041c0:	68 33 7b 10 f0       	push   $0xf0107b33
f01041c5:	e8 ff f8 ff ff       	call   f0103ac9 <cprintf>
}
f01041ca:	83 c4 10             	add    $0x10,%esp
f01041cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01041d0:	c9                   	leave  
f01041d1:	c3                   	ret    

f01041d2 <print_trapframe>:
{
f01041d2:	f3 0f 1e fb          	endbr32 
f01041d6:	55                   	push   %ebp
f01041d7:	89 e5                	mov    %esp,%ebp
f01041d9:	56                   	push   %esi
f01041da:	53                   	push   %ebx
f01041db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01041de:	e8 9f 1f 00 00       	call   f0106182 <cpunum>
f01041e3:	83 ec 04             	sub    $0x4,%esp
f01041e6:	50                   	push   %eax
f01041e7:	53                   	push   %ebx
f01041e8:	68 97 7b 10 f0       	push   $0xf0107b97
f01041ed:	e8 d7 f8 ff ff       	call   f0103ac9 <cprintf>
	print_regs(&tf->tf_regs);
f01041f2:	89 1c 24             	mov    %ebx,(%esp)
f01041f5:	e8 46 ff ff ff       	call   f0104140 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01041fa:	83 c4 08             	add    $0x8,%esp
f01041fd:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0104201:	50                   	push   %eax
f0104202:	68 b5 7b 10 f0       	push   $0xf0107bb5
f0104207:	e8 bd f8 ff ff       	call   f0103ac9 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010420c:	83 c4 08             	add    $0x8,%esp
f010420f:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0104213:	50                   	push   %eax
f0104214:	68 c8 7b 10 f0       	push   $0xf0107bc8
f0104219:	e8 ab f8 ff ff       	call   f0103ac9 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010421e:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f0104221:	83 c4 10             	add    $0x10,%esp
f0104224:	83 f8 13             	cmp    $0x13,%eax
f0104227:	0f 86 da 00 00 00    	jbe    f0104307 <print_trapframe+0x135>
		return "System call";
f010422d:	ba 42 7b 10 f0       	mov    $0xf0107b42,%edx
	if (trapno == T_SYSCALL)
f0104232:	83 f8 30             	cmp    $0x30,%eax
f0104235:	74 13                	je     f010424a <print_trapframe+0x78>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0104237:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f010423a:	83 fa 0f             	cmp    $0xf,%edx
f010423d:	ba 4e 7b 10 f0       	mov    $0xf0107b4e,%edx
f0104242:	b9 5d 7b 10 f0       	mov    $0xf0107b5d,%ecx
f0104247:	0f 46 d1             	cmovbe %ecx,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010424a:	83 ec 04             	sub    $0x4,%esp
f010424d:	52                   	push   %edx
f010424e:	50                   	push   %eax
f010424f:	68 db 7b 10 f0       	push   $0xf0107bdb
f0104254:	e8 70 f8 ff ff       	call   f0103ac9 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104259:	83 c4 10             	add    $0x10,%esp
f010425c:	39 1d 60 fa 23 f0    	cmp    %ebx,0xf023fa60
f0104262:	0f 84 ab 00 00 00    	je     f0104313 <print_trapframe+0x141>
	cprintf("  err  0x%08x", tf->tf_err);
f0104268:	83 ec 08             	sub    $0x8,%esp
f010426b:	ff 73 2c             	pushl  0x2c(%ebx)
f010426e:	68 fc 7b 10 f0       	push   $0xf0107bfc
f0104273:	e8 51 f8 ff ff       	call   f0103ac9 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0104278:	83 c4 10             	add    $0x10,%esp
f010427b:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010427f:	0f 85 b1 00 00 00    	jne    f0104336 <print_trapframe+0x164>
				tf->tf_err & 1 ? "protection" : "not-present");
f0104285:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0104288:	a8 01                	test   $0x1,%al
f010428a:	b9 70 7b 10 f0       	mov    $0xf0107b70,%ecx
f010428f:	ba 7b 7b 10 f0       	mov    $0xf0107b7b,%edx
f0104294:	0f 44 ca             	cmove  %edx,%ecx
f0104297:	a8 02                	test   $0x2,%al
f0104299:	be 87 7b 10 f0       	mov    $0xf0107b87,%esi
f010429e:	ba 8d 7b 10 f0       	mov    $0xf0107b8d,%edx
f01042a3:	0f 45 d6             	cmovne %esi,%edx
f01042a6:	a8 04                	test   $0x4,%al
f01042a8:	b8 92 7b 10 f0       	mov    $0xf0107b92,%eax
f01042ad:	be c7 7c 10 f0       	mov    $0xf0107cc7,%esi
f01042b2:	0f 44 c6             	cmove  %esi,%eax
f01042b5:	51                   	push   %ecx
f01042b6:	52                   	push   %edx
f01042b7:	50                   	push   %eax
f01042b8:	68 0a 7c 10 f0       	push   $0xf0107c0a
f01042bd:	e8 07 f8 ff ff       	call   f0103ac9 <cprintf>
f01042c2:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01042c5:	83 ec 08             	sub    $0x8,%esp
f01042c8:	ff 73 30             	pushl  0x30(%ebx)
f01042cb:	68 19 7c 10 f0       	push   $0xf0107c19
f01042d0:	e8 f4 f7 ff ff       	call   f0103ac9 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01042d5:	83 c4 08             	add    $0x8,%esp
f01042d8:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01042dc:	50                   	push   %eax
f01042dd:	68 28 7c 10 f0       	push   $0xf0107c28
f01042e2:	e8 e2 f7 ff ff       	call   f0103ac9 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01042e7:	83 c4 08             	add    $0x8,%esp
f01042ea:	ff 73 38             	pushl  0x38(%ebx)
f01042ed:	68 3b 7c 10 f0       	push   $0xf0107c3b
f01042f2:	e8 d2 f7 ff ff       	call   f0103ac9 <cprintf>
	if ((tf->tf_cs & 3) != 0)
f01042f7:	83 c4 10             	add    $0x10,%esp
f01042fa:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01042fe:	75 4b                	jne    f010434b <print_trapframe+0x179>
}
f0104300:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104303:	5b                   	pop    %ebx
f0104304:	5e                   	pop    %esi
f0104305:	5d                   	pop    %ebp
f0104306:	c3                   	ret    
		return excnames[trapno];
f0104307:	8b 14 85 80 7e 10 f0 	mov    -0xfef8180(,%eax,4),%edx
f010430e:	e9 37 ff ff ff       	jmp    f010424a <print_trapframe+0x78>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104313:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104317:	0f 85 4b ff ff ff    	jne    f0104268 <print_trapframe+0x96>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010431d:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104320:	83 ec 08             	sub    $0x8,%esp
f0104323:	50                   	push   %eax
f0104324:	68 ed 7b 10 f0       	push   $0xf0107bed
f0104329:	e8 9b f7 ff ff       	call   f0103ac9 <cprintf>
f010432e:	83 c4 10             	add    $0x10,%esp
f0104331:	e9 32 ff ff ff       	jmp    f0104268 <print_trapframe+0x96>
		cprintf("\n");
f0104336:	83 ec 0c             	sub    $0xc,%esp
f0104339:	68 00 7a 10 f0       	push   $0xf0107a00
f010433e:	e8 86 f7 ff ff       	call   f0103ac9 <cprintf>
f0104343:	83 c4 10             	add    $0x10,%esp
f0104346:	e9 7a ff ff ff       	jmp    f01042c5 <print_trapframe+0xf3>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010434b:	83 ec 08             	sub    $0x8,%esp
f010434e:	ff 73 3c             	pushl  0x3c(%ebx)
f0104351:	68 4a 7c 10 f0       	push   $0xf0107c4a
f0104356:	e8 6e f7 ff ff       	call   f0103ac9 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010435b:	83 c4 08             	add    $0x8,%esp
f010435e:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104362:	50                   	push   %eax
f0104363:	68 59 7c 10 f0       	push   $0xf0107c59
f0104368:	e8 5c f7 ff ff       	call   f0103ac9 <cprintf>
f010436d:	83 c4 10             	add    $0x10,%esp
}
f0104370:	eb 8e                	jmp    f0104300 <print_trapframe+0x12e>

f0104372 <page_fault_handler>:
	else
		sched_yield();
}

void page_fault_handler(struct Trapframe *tf)
{
f0104372:	f3 0f 1e fb          	endbr32 
f0104376:	55                   	push   %ebp
f0104377:	89 e5                	mov    %esp,%ebp
f0104379:	57                   	push   %edi
f010437a:	56                   	push   %esi
f010437b:	53                   	push   %ebx
f010437c:	83 ec 1c             	sub    $0x1c,%esp
f010437f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104382:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0)
f0104385:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104389:	74 5d                	je     f01043e8 <page_fault_handler+0x76>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall)
f010438b:	e8 f2 1d 00 00       	call   f0106182 <cpunum>
f0104390:	6b c0 74             	imul   $0x74,%eax,%eax
f0104393:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104399:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f010439d:	75 60                	jne    f01043ff <page_fault_handler+0x8d>
		curenv->env_tf.tf_esp = (uintptr_t)utr;
		env_run(curenv); //重新进入用户态
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010439f:	8b 7b 30             	mov    0x30(%ebx),%edi
			curenv->env_id, fault_va, tf->tf_eip);
f01043a2:	e8 db 1d 00 00       	call   f0106182 <cpunum>
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01043a7:	57                   	push   %edi
f01043a8:	56                   	push   %esi
			curenv->env_id, fault_va, tf->tf_eip);
f01043a9:	6b c0 74             	imul   $0x74,%eax,%eax
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01043ac:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f01043b2:	ff 70 48             	pushl  0x48(%eax)
f01043b5:	68 48 7e 10 f0       	push   $0xf0107e48
f01043ba:	e8 0a f7 ff ff       	call   f0103ac9 <cprintf>
	print_trapframe(tf);
f01043bf:	89 1c 24             	mov    %ebx,(%esp)
f01043c2:	e8 0b fe ff ff       	call   f01041d2 <print_trapframe>
	env_destroy(curenv);
f01043c7:	e8 b6 1d 00 00       	call   f0106182 <cpunum>
f01043cc:	83 c4 04             	add    $0x4,%esp
f01043cf:	6b c0 74             	imul   $0x74,%eax,%eax
f01043d2:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f01043d8:	e8 df f3 ff ff       	call   f01037bc <env_destroy>
}
f01043dd:	83 c4 10             	add    $0x10,%esp
f01043e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01043e3:	5b                   	pop    %ebx
f01043e4:	5e                   	pop    %esi
f01043e5:	5f                   	pop    %edi
f01043e6:	5d                   	pop    %ebp
f01043e7:	c3                   	ret    
		panic("page_fault_handler():page fault in kernel mode!\n");
f01043e8:	83 ec 04             	sub    $0x4,%esp
f01043eb:	68 14 7e 10 f0       	push   $0xf0107e14
f01043f0:	68 80 01 00 00       	push   $0x180
f01043f5:	68 6c 7c 10 f0       	push   $0xf0107c6c
f01043fa:	e8 41 bc ff ff       	call   f0100040 <_panic>
		if (UXSTACKTOP - PGSIZE < tf->tf_esp && tf->tf_esp < UXSTACKTOP)
f01043ff:	8b 7b 3c             	mov    0x3c(%ebx),%edi
f0104402:	8d 87 ff 0f 40 11    	lea    0x11400fff(%edi),%eax
		uintptr_t stacktop = UXSTACKTOP;
f0104408:	3d ff 0f 00 00       	cmp    $0xfff,%eax
f010440d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
f0104412:	0f 43 f8             	cmovae %eax,%edi
		user_mem_assert(curenv, (void *)stacktop - size, size, PTE_U | PTE_W);
f0104415:	8d 57 c8             	lea    -0x38(%edi),%edx
f0104418:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010441b:	e8 62 1d 00 00       	call   f0106182 <cpunum>
f0104420:	6a 06                	push   $0x6
f0104422:	6a 38                	push   $0x38
f0104424:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104427:	6b c0 74             	imul   $0x74,%eax,%eax
f010442a:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f0104430:	e8 05 eb ff ff       	call   f0102f3a <user_mem_assert>
		utr->utf_fault_va = fault_va;
f0104435:	89 77 c8             	mov    %esi,-0x38(%edi)
		utr->utf_err = tf->tf_err;
f0104438:	8b 43 2c             	mov    0x2c(%ebx),%eax
f010443b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010443e:	89 42 04             	mov    %eax,0x4(%edx)
		utr->utf_regs = tf->tf_regs;
f0104441:	83 ef 30             	sub    $0x30,%edi
f0104444:	b9 08 00 00 00       	mov    $0x8,%ecx
f0104449:	89 de                	mov    %ebx,%esi
f010444b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utr->utf_eip = tf->tf_eip;
f010444d:	8b 43 30             	mov    0x30(%ebx),%eax
f0104450:	89 42 28             	mov    %eax,0x28(%edx)
		utr->utf_eflags = tf->tf_eflags;
f0104453:	8b 43 38             	mov    0x38(%ebx),%eax
f0104456:	89 d6                	mov    %edx,%esi
f0104458:	89 42 2c             	mov    %eax,0x2c(%edx)
		utr->utf_esp = tf->tf_esp; //UXSTACKTOP栈上需要保存发生缺页异常时的%esp和%eip
f010445b:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010445e:	89 42 30             	mov    %eax,0x30(%edx)
		curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f0104461:	e8 1c 1d 00 00       	call   f0106182 <cpunum>
f0104466:	6b c0 74             	imul   $0x74,%eax,%eax
f0104469:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f010446f:	8b 58 64             	mov    0x64(%eax),%ebx
f0104472:	e8 0b 1d 00 00       	call   f0106182 <cpunum>
f0104477:	6b c0 74             	imul   $0x74,%eax,%eax
f010447a:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104480:	89 58 30             	mov    %ebx,0x30(%eax)
		curenv->env_tf.tf_esp = (uintptr_t)utr;
f0104483:	e8 fa 1c 00 00       	call   f0106182 <cpunum>
f0104488:	6b c0 74             	imul   $0x74,%eax,%eax
f010448b:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104491:	89 70 3c             	mov    %esi,0x3c(%eax)
		env_run(curenv); //重新进入用户态
f0104494:	e8 e9 1c 00 00       	call   f0106182 <cpunum>
f0104499:	83 c4 04             	add    $0x4,%esp
f010449c:	6b c0 74             	imul   $0x74,%eax,%eax
f010449f:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f01044a5:	e8 77 f3 ff ff       	call   f0103821 <env_run>

f01044aa <trap>:
{
f01044aa:	f3 0f 1e fb          	endbr32 
f01044ae:	55                   	push   %ebp
f01044af:	89 e5                	mov    %esp,%ebp
f01044b1:	57                   	push   %edi
f01044b2:	56                   	push   %esi
f01044b3:	53                   	push   %ebx
f01044b4:	83 ec 0c             	sub    $0xc,%esp
f01044b7:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::
f01044ba:	fc                   	cld    
	if (panicstr)
f01044bb:	83 3d b4 fe 23 f0 00 	cmpl   $0x0,0xf023feb4
f01044c2:	74 01                	je     f01044c5 <trap+0x1b>
		asm volatile("hlt");
f01044c4:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01044c5:	e8 b8 1c 00 00       	call   f0106182 <cpunum>
f01044ca:	6b d0 74             	imul   $0x74,%eax,%edx
f01044cd:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f01044d0:	b8 01 00 00 00       	mov    $0x1,%eax
f01044d5:	f0 87 82 20 20 24 f0 	lock xchg %eax,-0xfdbdfe0(%edx)
f01044dc:	83 f8 02             	cmp    $0x2,%eax
f01044df:	0f 84 b3 00 00 00    	je     f0104598 <trap+0xee>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f01044e5:	9c                   	pushf  
f01044e6:	5b                   	pop    %ebx
	assert(!(read_eflags() & FL_IF));
f01044e7:	81 e3 00 02 00 00    	and    $0x200,%ebx
f01044ed:	0f 85 ba 00 00 00    	jne    f01045ad <trap+0x103>
	if ((tf->tf_cs & 3) == 3)
f01044f3:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01044f7:	83 e0 03             	and    $0x3,%eax
f01044fa:	66 83 f8 03          	cmp    $0x3,%ax
f01044fe:	0f 84 c2 00 00 00    	je     f01045c6 <trap+0x11c>
	last_tf = tf;
f0104504:	89 35 60 fa 23 f0    	mov    %esi,0xf023fa60
	if (tf->tf_trapno == T_PGFLT)
f010450a:	8b 46 28             	mov    0x28(%esi),%eax
f010450d:	83 f8 0e             	cmp    $0xe,%eax
f0104510:	0f 84 55 01 00 00    	je     f010466b <trap+0x1c1>
	if (tf->tf_trapno == T_BRKPT)
f0104516:	83 f8 03             	cmp    $0x3,%eax
f0104519:	0f 84 5d 01 00 00    	je     f010467c <trap+0x1d2>
	if (tf->tf_trapno == T_SYSCALL)
f010451f:	83 f8 30             	cmp    $0x30,%eax
f0104522:	0f 84 65 01 00 00    	je     f010468d <trap+0x1e3>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS)
f0104528:	83 f8 27             	cmp    $0x27,%eax
f010452b:	0f 84 80 01 00 00    	je     f01046b1 <trap+0x207>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER)
f0104531:	83 f8 20             	cmp    $0x20,%eax
f0104534:	0f 84 94 01 00 00    	je     f01046ce <trap+0x224>
	print_trapframe(tf);
f010453a:	83 ec 0c             	sub    $0xc,%esp
f010453d:	56                   	push   %esi
f010453e:	e8 8f fc ff ff       	call   f01041d2 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104543:	83 c4 10             	add    $0x10,%esp
f0104546:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010454b:	0f 84 f5 01 00 00    	je     f0104746 <trap+0x29c>
		env_destroy(curenv);
f0104551:	e8 2c 1c 00 00       	call   f0106182 <cpunum>
f0104556:	83 ec 0c             	sub    $0xc,%esp
f0104559:	6b c0 74             	imul   $0x74,%eax,%eax
f010455c:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f0104562:	e8 55 f2 ff ff       	call   f01037bc <env_destroy>
		return;
f0104567:	83 c4 10             	add    $0x10,%esp
	if (curenv && curenv->env_status == ENV_RUNNING)
f010456a:	e8 13 1c 00 00       	call   f0106182 <cpunum>
f010456f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104572:	83 b8 28 20 24 f0 00 	cmpl   $0x0,-0xfdbdfd8(%eax)
f0104579:	74 18                	je     f0104593 <trap+0xe9>
f010457b:	e8 02 1c 00 00       	call   f0106182 <cpunum>
f0104580:	6b c0 74             	imul   $0x74,%eax,%eax
f0104583:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104589:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010458d:	0f 84 ca 01 00 00    	je     f010475d <trap+0x2b3>
		sched_yield();
f0104593:	e8 a3 03 00 00       	call   f010493b <sched_yield>
	spin_lock(&kernel_lock);
f0104598:	83 ec 0c             	sub    $0xc,%esp
f010459b:	68 c0 43 12 f0       	push   $0xf01243c0
f01045a0:	e8 65 1e 00 00       	call   f010640a <spin_lock>
}
f01045a5:	83 c4 10             	add    $0x10,%esp
f01045a8:	e9 38 ff ff ff       	jmp    f01044e5 <trap+0x3b>
	assert(!(read_eflags() & FL_IF));
f01045ad:	68 78 7c 10 f0       	push   $0xf0107c78
f01045b2:	68 8b 77 10 f0       	push   $0xf010778b
f01045b7:	68 4a 01 00 00       	push   $0x14a
f01045bc:	68 6c 7c 10 f0       	push   $0xf0107c6c
f01045c1:	e8 7a ba ff ff       	call   f0100040 <_panic>
		assert(curenv);
f01045c6:	e8 b7 1b 00 00       	call   f0106182 <cpunum>
f01045cb:	6b c0 74             	imul   $0x74,%eax,%eax
f01045ce:	83 b8 28 20 24 f0 00 	cmpl   $0x0,-0xfdbdfd8(%eax)
f01045d5:	74 4e                	je     f0104625 <trap+0x17b>
	spin_lock(&kernel_lock);
f01045d7:	83 ec 0c             	sub    $0xc,%esp
f01045da:	68 c0 43 12 f0       	push   $0xf01243c0
f01045df:	e8 26 1e 00 00       	call   f010640a <spin_lock>
		if (curenv->env_status == ENV_DYING)
f01045e4:	e8 99 1b 00 00       	call   f0106182 <cpunum>
f01045e9:	6b c0 74             	imul   $0x74,%eax,%eax
f01045ec:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f01045f2:	83 c4 10             	add    $0x10,%esp
f01045f5:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01045f9:	74 43                	je     f010463e <trap+0x194>
		curenv->env_tf = *tf; 
f01045fb:	e8 82 1b 00 00       	call   f0106182 <cpunum>
f0104600:	6b c0 74             	imul   $0x74,%eax,%eax
f0104603:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104609:	b9 11 00 00 00       	mov    $0x11,%ecx
f010460e:	89 c7                	mov    %eax,%edi
f0104610:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0104612:	e8 6b 1b 00 00       	call   f0106182 <cpunum>
f0104617:	6b c0 74             	imul   $0x74,%eax,%eax
f010461a:	8b b0 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%esi
f0104620:	e9 df fe ff ff       	jmp    f0104504 <trap+0x5a>
		assert(curenv);
f0104625:	68 91 7c 10 f0       	push   $0xf0107c91
f010462a:	68 8b 77 10 f0       	push   $0xf010778b
f010462f:	68 52 01 00 00       	push   $0x152
f0104634:	68 6c 7c 10 f0       	push   $0xf0107c6c
f0104639:	e8 02 ba ff ff       	call   f0100040 <_panic>
			env_free(curenv);
f010463e:	e8 3f 1b 00 00       	call   f0106182 <cpunum>
f0104643:	83 ec 0c             	sub    $0xc,%esp
f0104646:	6b c0 74             	imul   $0x74,%eax,%eax
f0104649:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f010464f:	e8 7f ef ff ff       	call   f01035d3 <env_free>
			curenv = NULL;
f0104654:	e8 29 1b 00 00       	call   f0106182 <cpunum>
f0104659:	6b c0 74             	imul   $0x74,%eax,%eax
f010465c:	c7 80 28 20 24 f0 00 	movl   $0x0,-0xfdbdfd8(%eax)
f0104663:	00 00 00 
			sched_yield();
f0104666:	e8 d0 02 00 00       	call   f010493b <sched_yield>
		page_fault_handler(tf);
f010466b:	83 ec 0c             	sub    $0xc,%esp
f010466e:	56                   	push   %esi
f010466f:	e8 fe fc ff ff       	call   f0104372 <page_fault_handler>
		return;
f0104674:	83 c4 10             	add    $0x10,%esp
f0104677:	e9 ee fe ff ff       	jmp    f010456a <trap+0xc0>
		monitor(tf);
f010467c:	83 ec 0c             	sub    $0xc,%esp
f010467f:	56                   	push   %esi
f0104680:	e8 91 c2 ff ff       	call   f0100916 <monitor>
		return;
f0104685:	83 c4 10             	add    $0x10,%esp
f0104688:	e9 dd fe ff ff       	jmp    f010456a <trap+0xc0>
		tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f010468d:	83 ec 08             	sub    $0x8,%esp
f0104690:	ff 76 04             	pushl  0x4(%esi)
f0104693:	ff 36                	pushl  (%esi)
f0104695:	ff 76 10             	pushl  0x10(%esi)
f0104698:	ff 76 18             	pushl  0x18(%esi)
f010469b:	ff 76 14             	pushl  0x14(%esi)
f010469e:	ff 76 1c             	pushl  0x1c(%esi)
f01046a1:	e8 e1 03 00 00       	call   f0104a87 <syscall>
f01046a6:	89 46 1c             	mov    %eax,0x1c(%esi)
		return;
f01046a9:	83 c4 20             	add    $0x20,%esp
f01046ac:	e9 b9 fe ff ff       	jmp    f010456a <trap+0xc0>
		cprintf("Spurious interrupt on irq 7\n");
f01046b1:	83 ec 0c             	sub    $0xc,%esp
f01046b4:	68 98 7c 10 f0       	push   $0xf0107c98
f01046b9:	e8 0b f4 ff ff       	call   f0103ac9 <cprintf>
		print_trapframe(tf);
f01046be:	89 34 24             	mov    %esi,(%esp)
f01046c1:	e8 0c fb ff ff       	call   f01041d2 <print_trapframe>
		return;
f01046c6:	83 c4 10             	add    $0x10,%esp
f01046c9:	e9 9c fe ff ff       	jmp    f010456a <trap+0xc0>
		lapic_eoi();
f01046ce:	e8 fe 1b 00 00       	call   f01062d1 <lapic_eoi>
		totalslice++;
f01046d3:	a1 b0 fe 23 f0       	mov    0xf023feb0,%eax
f01046d8:	83 c0 01             	add    $0x1,%eax
f01046db:	a3 b0 fe 23 f0       	mov    %eax,0xf023feb0
		if (totalslice == 20) {
f01046e0:	83 f8 14             	cmp    $0x14,%eax
f01046e3:	74 0d                	je     f01046f2 <trap+0x248>
		sched_yield();
f01046e5:	e8 51 02 00 00       	call   f010493b <sched_yield>
f01046ea:	83 c3 0c             	add    $0xc,%ebx
			for (int i = 1; i < 4; i++) {
f01046ed:	83 fb 24             	cmp    $0x24,%ebx
f01046f0:	74 48                	je     f010473a <trap+0x290>
				Node* node = MFQueue[i].front;
f01046f2:	8b b3 90 fe 23 f0    	mov    -0xfdc0170(%ebx),%esi
				if (node == NULL) {
f01046f8:	85 f6                	test   %esi,%esi
f01046fa:	74 ee                	je     f01046ea <trap+0x240>
					e_remove(node->env);
f01046fc:	83 ec 0c             	sub    $0xc,%esp
f01046ff:	ff 76 04             	pushl  0x4(%esi)
f0104702:	e8 5a ee ff ff       	call   f0103561 <e_remove>
					node->env->priority = 0;
f0104707:	8b 46 04             	mov    0x4(%esi),%eax
f010470a:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
					node->env->timeslice = 0;
f0104711:	8b 46 04             	mov    0x4(%esi),%eax
f0104714:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
f010471b:	00 00 00 
					e_insert(0, node->env);
f010471e:	83 c4 08             	add    $0x8,%esp
f0104721:	ff 76 04             	pushl  0x4(%esi)
f0104724:	6a 00                	push   $0x0
f0104726:	e8 a1 ea ff ff       	call   f01031cc <e_insert>
					node = MFQueue[i].front;
f010472b:	8b b3 90 fe 23 f0    	mov    -0xfdc0170(%ebx),%esi
				while(node != NULL) {
f0104731:	83 c4 10             	add    $0x10,%esp
f0104734:	85 f6                	test   %esi,%esi
f0104736:	75 c4                	jne    f01046fc <trap+0x252>
f0104738:	eb b0                	jmp    f01046ea <trap+0x240>
			totalslice = 0;
f010473a:	c7 05 b0 fe 23 f0 00 	movl   $0x0,0xf023feb0
f0104741:	00 00 00 
f0104744:	eb 9f                	jmp    f01046e5 <trap+0x23b>
		panic("unhandled trap in kernel");
f0104746:	83 ec 04             	sub    $0x4,%esp
f0104749:	68 b5 7c 10 f0       	push   $0xf0107cb5
f010474e:	68 2f 01 00 00       	push   $0x12f
f0104753:	68 6c 7c 10 f0       	push   $0xf0107c6c
f0104758:	e8 e3 b8 ff ff       	call   f0100040 <_panic>
		env_run(curenv);
f010475d:	e8 20 1a 00 00       	call   f0106182 <cpunum>
f0104762:	83 ec 0c             	sub    $0xc,%esp
f0104765:	6b c0 74             	imul   $0x74,%eax,%eax
f0104768:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f010476e:	e8 ae f0 ff ff       	call   f0103821 <env_run>
f0104773:	90                   	nop

f0104774 <th_divide>:
/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */


	TRAPHANDLER_NOEC(th_divide, T_DIVIDE)
f0104774:	6a 00                	push   $0x0
f0104776:	6a 00                	push   $0x0
f0104778:	e9 d9 00 00 00       	jmp    f0104856 <_alltraps>
f010477d:	90                   	nop

f010477e <th_debug>:
	TRAPHANDLER_NOEC(th_debug, T_DEBUG)
f010477e:	6a 00                	push   $0x0
f0104780:	6a 01                	push   $0x1
f0104782:	e9 cf 00 00 00       	jmp    f0104856 <_alltraps>
f0104787:	90                   	nop

f0104788 <th_nmi>:
	TRAPHANDLER_NOEC(th_nmi, T_NMI)
f0104788:	6a 00                	push   $0x0
f010478a:	6a 02                	push   $0x2
f010478c:	e9 c5 00 00 00       	jmp    f0104856 <_alltraps>
f0104791:	90                   	nop

f0104792 <th_brkpt>:
	TRAPHANDLER_NOEC(th_brkpt, T_BRKPT)
f0104792:	6a 00                	push   $0x0
f0104794:	6a 03                	push   $0x3
f0104796:	e9 bb 00 00 00       	jmp    f0104856 <_alltraps>
f010479b:	90                   	nop

f010479c <th_oflow>:
	TRAPHANDLER_NOEC(th_oflow, T_OFLOW)
f010479c:	6a 00                	push   $0x0
f010479e:	6a 04                	push   $0x4
f01047a0:	e9 b1 00 00 00       	jmp    f0104856 <_alltraps>
f01047a5:	90                   	nop

f01047a6 <th_bound>:
	TRAPHANDLER_NOEC(th_bound, T_BOUND)
f01047a6:	6a 00                	push   $0x0
f01047a8:	6a 05                	push   $0x5
f01047aa:	e9 a7 00 00 00       	jmp    f0104856 <_alltraps>
f01047af:	90                   	nop

f01047b0 <th_illop>:
	TRAPHANDLER_NOEC(th_illop, T_ILLOP)
f01047b0:	6a 00                	push   $0x0
f01047b2:	6a 06                	push   $0x6
f01047b4:	e9 9d 00 00 00       	jmp    f0104856 <_alltraps>
f01047b9:	90                   	nop

f01047ba <th_device>:
	TRAPHANDLER_NOEC(th_device, T_DEVICE)
f01047ba:	6a 00                	push   $0x0
f01047bc:	6a 07                	push   $0x7
f01047be:	e9 93 00 00 00       	jmp    f0104856 <_alltraps>
f01047c3:	90                   	nop

f01047c4 <th_dblflt>:
	TRAPHANDLER(th_dblflt, T_DBLFLT)
f01047c4:	6a 08                	push   $0x8
f01047c6:	e9 8b 00 00 00       	jmp    f0104856 <_alltraps>
f01047cb:	90                   	nop

f01047cc <th9>:
	TRAPHANDLER_NOEC(th9, 9)
f01047cc:	6a 00                	push   $0x0
f01047ce:	6a 09                	push   $0x9
f01047d0:	e9 81 00 00 00       	jmp    f0104856 <_alltraps>
f01047d5:	90                   	nop

f01047d6 <th_tss>:
	TRAPHANDLER(th_tss, T_TSS)
f01047d6:	6a 0a                	push   $0xa
f01047d8:	eb 7c                	jmp    f0104856 <_alltraps>

f01047da <th_segnp>:
	TRAPHANDLER(th_segnp, T_SEGNP)
f01047da:	6a 0b                	push   $0xb
f01047dc:	eb 78                	jmp    f0104856 <_alltraps>

f01047de <th_stack>:
	TRAPHANDLER(th_stack, T_STACK)
f01047de:	6a 0c                	push   $0xc
f01047e0:	eb 74                	jmp    f0104856 <_alltraps>

f01047e2 <th_gpflt>:
	TRAPHANDLER(th_gpflt, T_GPFLT)
f01047e2:	6a 0d                	push   $0xd
f01047e4:	eb 70                	jmp    f0104856 <_alltraps>

f01047e6 <th_pgflt>:
	TRAPHANDLER(th_pgflt, T_PGFLT)
f01047e6:	6a 0e                	push   $0xe
f01047e8:	eb 6c                	jmp    f0104856 <_alltraps>

f01047ea <th_fperr>:
	TRAPHANDLER_NOEC(th_fperr, T_FPERR)
f01047ea:	6a 00                	push   $0x0
f01047ec:	6a 10                	push   $0x10
f01047ee:	eb 66                	jmp    f0104856 <_alltraps>

f01047f0 <th32>:

	TRAPHANDLER_NOEC(th32, IRQ_OFFSET)
f01047f0:	6a 00                	push   $0x0
f01047f2:	6a 20                	push   $0x20
f01047f4:	eb 60                	jmp    f0104856 <_alltraps>

f01047f6 <th33>:
	TRAPHANDLER_NOEC(th33, IRQ_OFFSET + 1)
f01047f6:	6a 00                	push   $0x0
f01047f8:	6a 21                	push   $0x21
f01047fa:	eb 5a                	jmp    f0104856 <_alltraps>

f01047fc <th34>:
	TRAPHANDLER_NOEC(th34, IRQ_OFFSET + 2)
f01047fc:	6a 00                	push   $0x0
f01047fe:	6a 22                	push   $0x22
f0104800:	eb 54                	jmp    f0104856 <_alltraps>

f0104802 <th35>:
	TRAPHANDLER_NOEC(th35, IRQ_OFFSET + 3)
f0104802:	6a 00                	push   $0x0
f0104804:	6a 23                	push   $0x23
f0104806:	eb 4e                	jmp    f0104856 <_alltraps>

f0104808 <th36>:
	TRAPHANDLER_NOEC(th36, IRQ_OFFSET + 4)
f0104808:	6a 00                	push   $0x0
f010480a:	6a 24                	push   $0x24
f010480c:	eb 48                	jmp    f0104856 <_alltraps>

f010480e <th37>:
	TRAPHANDLER_NOEC(th37, IRQ_OFFSET + 5)
f010480e:	6a 00                	push   $0x0
f0104810:	6a 25                	push   $0x25
f0104812:	eb 42                	jmp    f0104856 <_alltraps>

f0104814 <th38>:
	TRAPHANDLER_NOEC(th38, IRQ_OFFSET + 6)
f0104814:	6a 00                	push   $0x0
f0104816:	6a 26                	push   $0x26
f0104818:	eb 3c                	jmp    f0104856 <_alltraps>

f010481a <th39>:
	TRAPHANDLER_NOEC(th39, IRQ_OFFSET + 7)
f010481a:	6a 00                	push   $0x0
f010481c:	6a 27                	push   $0x27
f010481e:	eb 36                	jmp    f0104856 <_alltraps>

f0104820 <th40>:
	TRAPHANDLER_NOEC(th40, IRQ_OFFSET + 8)
f0104820:	6a 00                	push   $0x0
f0104822:	6a 28                	push   $0x28
f0104824:	eb 30                	jmp    f0104856 <_alltraps>

f0104826 <th41>:
	TRAPHANDLER_NOEC(th41, IRQ_OFFSET + 9)
f0104826:	6a 00                	push   $0x0
f0104828:	6a 29                	push   $0x29
f010482a:	eb 2a                	jmp    f0104856 <_alltraps>

f010482c <th42>:
	TRAPHANDLER_NOEC(th42, IRQ_OFFSET + 10)
f010482c:	6a 00                	push   $0x0
f010482e:	6a 2a                	push   $0x2a
f0104830:	eb 24                	jmp    f0104856 <_alltraps>

f0104832 <th43>:
	TRAPHANDLER_NOEC(th43, IRQ_OFFSET + 11)
f0104832:	6a 00                	push   $0x0
f0104834:	6a 2b                	push   $0x2b
f0104836:	eb 1e                	jmp    f0104856 <_alltraps>

f0104838 <th44>:
	TRAPHANDLER_NOEC(th44, IRQ_OFFSET + 12)
f0104838:	6a 00                	push   $0x0
f010483a:	6a 2c                	push   $0x2c
f010483c:	eb 18                	jmp    f0104856 <_alltraps>

f010483e <th45>:
	TRAPHANDLER_NOEC(th45, IRQ_OFFSET + 13)
f010483e:	6a 00                	push   $0x0
f0104840:	6a 2d                	push   $0x2d
f0104842:	eb 12                	jmp    f0104856 <_alltraps>

f0104844 <th46>:
	TRAPHANDLER_NOEC(th46, IRQ_OFFSET + 14)
f0104844:	6a 00                	push   $0x0
f0104846:	6a 2e                	push   $0x2e
f0104848:	eb 0c                	jmp    f0104856 <_alltraps>

f010484a <th47>:
	TRAPHANDLER_NOEC(th47, IRQ_OFFSET + 15)
f010484a:	6a 00                	push   $0x0
f010484c:	6a 2f                	push   $0x2f
f010484e:	eb 06                	jmp    f0104856 <_alltraps>

f0104850 <th_syscall>:

	TRAPHANDLER_NOEC(th_syscall, T_SYSCALL)
f0104850:	6a 00                	push   $0x0
f0104852:	6a 30                	push   $0x30
f0104854:	eb 00                	jmp    f0104856 <_alltraps>

f0104856 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
    pushl %ds
f0104856:	1e                   	push   %ds
    pushl %es
f0104857:	06                   	push   %es
    pushal
f0104858:	60                   	pusha  
    movw $GD_KD, %ax
f0104859:	66 b8 10 00          	mov    $0x10,%ax
    movw %ax, %ds
f010485d:	8e d8                	mov    %eax,%ds
    movw %ax, %es
f010485f:	8e c0                	mov    %eax,%es
    pushl %esp
f0104861:	54                   	push   %esp
    call trap
f0104862:	e8 43 fc ff ff       	call   f01044aa <trap>

f0104867 <sched_halt>:

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void sched_halt(void)
{
f0104867:	f3 0f 1e fb          	endbr32 
f010486b:	55                   	push   %ebp
f010486c:	89 e5                	mov    %esp,%ebp
f010486e:	83 ec 08             	sub    $0x8,%esp
f0104871:	a1 44 f2 23 f0       	mov    0xf023f244,%eax
f0104876:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++)
f0104879:	b9 00 00 00 00       	mov    $0x0,%ecx
	{
		if ((envs[i].env_status == ENV_RUNNABLE ||
			 envs[i].env_status == ENV_RUNNING ||
f010487e:	8b 02                	mov    (%edx),%eax
f0104880:	83 e8 01             	sub    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104883:	83 f8 02             	cmp    $0x2,%eax
f0104886:	76 30                	jbe    f01048b8 <sched_halt+0x51>
	for (i = 0; i < NENV; i++)
f0104888:	83 c1 01             	add    $0x1,%ecx
f010488b:	81 c2 84 00 00 00    	add    $0x84,%edx
f0104891:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104897:	75 e5                	jne    f010487e <sched_halt+0x17>
			 envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV)
	{
		cprintf("No runnable environments in the system!\n");
f0104899:	83 ec 0c             	sub    $0xc,%esp
f010489c:	68 d0 7e 10 f0       	push   $0xf0107ed0
f01048a1:	e8 23 f2 ff ff       	call   f0103ac9 <cprintf>
f01048a6:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01048a9:	83 ec 0c             	sub    $0xc,%esp
f01048ac:	6a 00                	push   $0x0
f01048ae:	e8 63 c0 ff ff       	call   f0100916 <monitor>
f01048b3:	83 c4 10             	add    $0x10,%esp
f01048b6:	eb f1                	jmp    f01048a9 <sched_halt+0x42>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01048b8:	e8 c5 18 00 00       	call   f0106182 <cpunum>
f01048bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01048c0:	c7 80 28 20 24 f0 00 	movl   $0x0,-0xfdbdfd8(%eax)
f01048c7:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f01048ca:	a1 c4 1e 24 f0       	mov    0xf0241ec4,%eax
	if ((uint32_t)kva < KERNBASE)
f01048cf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01048d4:	76 50                	jbe    f0104926 <sched_halt+0xbf>
	return (physaddr_t)kva - KERNBASE;
f01048d6:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01048db:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01048de:	e8 9f 18 00 00       	call   f0106182 <cpunum>
f01048e3:	6b d0 74             	imul   $0x74,%eax,%edx
f01048e6:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f01048e9:	b8 02 00 00 00       	mov    $0x2,%eax
f01048ee:	f0 87 82 20 20 24 f0 	lock xchg %eax,-0xfdbdfe0(%edx)
	spin_unlock(&kernel_lock);
f01048f5:	83 ec 0c             	sub    $0xc,%esp
f01048f8:	68 c0 43 12 f0       	push   $0xf01243c0
f01048fd:	e8 a6 1b 00 00       	call   f01064a8 <spin_unlock>
	asm volatile("pause");
f0104902:	f3 90                	pause  
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
		:
		: "a"(thiscpu->cpu_ts.ts_esp0));
f0104904:	e8 79 18 00 00       	call   f0106182 <cpunum>
f0104909:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile(
f010490c:	8b 80 30 20 24 f0    	mov    -0xfdbdfd0(%eax),%eax
f0104912:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104917:	89 c4                	mov    %eax,%esp
f0104919:	6a 00                	push   $0x0
f010491b:	6a 00                	push   $0x0
f010491d:	fb                   	sti    
f010491e:	f4                   	hlt    
f010491f:	eb fd                	jmp    f010491e <sched_halt+0xb7>
}
f0104921:	83 c4 10             	add    $0x10,%esp
f0104924:	c9                   	leave  
f0104925:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104926:	50                   	push   %eax
f0104927:	68 48 68 10 f0       	push   $0xf0106848
f010492c:	68 84 00 00 00       	push   $0x84
f0104931:	68 f9 7e 10 f0       	push   $0xf0107ef9
f0104936:	e8 05 b7 ff ff       	call   f0100040 <_panic>

f010493b <sched_yield>:
{
f010493b:	f3 0f 1e fb          	endbr32 
f010493f:	55                   	push   %ebp
f0104940:	89 e5                	mov    %esp,%ebp
f0104942:	57                   	push   %edi
f0104943:	56                   	push   %esi
f0104944:	53                   	push   %ebx
f0104945:	83 ec 1c             	sub    $0x1c,%esp
	if (curenv) {
f0104948:	e8 35 18 00 00       	call   f0106182 <cpunum>
f010494d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104950:	83 b8 28 20 24 f0 00 	cmpl   $0x0,-0xfdbdfd8(%eax)
f0104957:	0f 84 ed 00 00 00    	je     f0104a4a <sched_yield+0x10f>
f010495d:	c7 45 e4 80 fe 23 f0 	movl   $0xf023fe80,-0x1c(%ebp)
		for (int i = 0; i < 4; i++) {
f0104964:	bf 00 00 00 00       	mov    $0x0,%edi
f0104969:	e9 94 00 00 00       	jmp    f0104a02 <sched_yield+0xc7>
						env_run(cur->env);
f010496e:	83 ec 0c             	sub    $0xc,%esp
f0104971:	52                   	push   %edx
f0104972:	e8 aa ee ff ff       	call   f0103821 <env_run>
f0104977:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010497a:	89 45 e0             	mov    %eax,-0x20(%ebp)
				cur = MFQueue[i].front;
f010497d:	8b 58 04             	mov    0x4(%eax),%ebx
				while (cur->env != curenv) {
f0104980:	eb 02                	jmp    f0104984 <sched_yield+0x49>
					cur = cur->next;
f0104982:	8b 1b                	mov    (%ebx),%ebx
				while (cur->env != curenv) {
f0104984:	8b 73 04             	mov    0x4(%ebx),%esi
f0104987:	e8 f6 17 00 00       	call   f0106182 <cpunum>
f010498c:	6b c0 74             	imul   $0x74,%eax,%eax
f010498f:	3b b0 28 20 24 f0    	cmp    -0xfdbdfd8(%eax),%esi
f0104995:	75 eb                	jne    f0104982 <sched_yield+0x47>
				cur = cur->next;
f0104997:	8b 03                	mov    (%ebx),%eax
				while (cur != NULL) {
f0104999:	85 c0                	test   %eax,%eax
f010499b:	74 16                	je     f01049b3 <sched_yield+0x78>
					if (cur->env->env_status == ENV_RUNNABLE) {
f010499d:	8b 50 04             	mov    0x4(%eax),%edx
f01049a0:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f01049a4:	74 04                	je     f01049aa <sched_yield+0x6f>
					cur = cur->next;
f01049a6:	8b 00                	mov    (%eax),%eax
f01049a8:	eb ef                	jmp    f0104999 <sched_yield+0x5e>
						env_run(cur->env);
f01049aa:	83 ec 0c             	sub    $0xc,%esp
f01049ad:	52                   	push   %edx
f01049ae:	e8 6e ee ff ff       	call   f0103821 <env_run>
				cur = MFQueue[i].front;
f01049b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01049b6:	8b 58 04             	mov    0x4(%eax),%ebx
				while (cur->env != curenv) {
f01049b9:	8b 73 04             	mov    0x4(%ebx),%esi
f01049bc:	e8 c1 17 00 00       	call   f0106182 <cpunum>
f01049c1:	6b c0 74             	imul   $0x74,%eax,%eax
f01049c4:	3b b0 28 20 24 f0    	cmp    -0xfdbdfd8(%eax),%esi
f01049ca:	74 16                	je     f01049e2 <sched_yield+0xa7>
					if (cur->env->env_status == ENV_RUNNABLE) {
f01049cc:	8b 43 04             	mov    0x4(%ebx),%eax
f01049cf:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f01049d3:	74 04                	je     f01049d9 <sched_yield+0x9e>
					cur = cur->next;
f01049d5:	8b 1b                	mov    (%ebx),%ebx
f01049d7:	eb e0                	jmp    f01049b9 <sched_yield+0x7e>
						env_run(cur->env);
f01049d9:	83 ec 0c             	sub    $0xc,%esp
f01049dc:	50                   	push   %eax
f01049dd:	e8 3f ee ff ff       	call   f0103821 <env_run>
				if (curenv->env_status == ENV_RUNNABLE) {
f01049e2:	e8 9b 17 00 00       	call   f0106182 <cpunum>
f01049e7:	6b c0 74             	imul   $0x74,%eax,%eax
f01049ea:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f01049f0:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f01049f4:	74 3e                	je     f0104a34 <sched_yield+0xf9>
		for (int i = 0; i < 4; i++) {
f01049f6:	83 c7 01             	add    $0x1,%edi
f01049f9:	83 45 e4 0c          	addl   $0xc,-0x1c(%ebp)
f01049fd:	83 ff 04             	cmp    $0x4,%edi
f0104a00:	74 78                	je     f0104a7a <sched_yield+0x13f>
			if (i != curenv->priority) {
f0104a02:	e8 7b 17 00 00       	call   f0106182 <cpunum>
f0104a07:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a0a:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104a10:	39 78 7c             	cmp    %edi,0x7c(%eax)
f0104a13:	0f 84 5e ff ff ff    	je     f0104977 <sched_yield+0x3c>
				cur = MFQueue[i].front;
f0104a19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a1c:	8b 40 04             	mov    0x4(%eax),%eax
				while (cur != NULL) {
f0104a1f:	85 c0                	test   %eax,%eax
f0104a21:	74 d3                	je     f01049f6 <sched_yield+0xbb>
					if (cur->env->env_status == ENV_RUNNABLE) {
f0104a23:	8b 50 04             	mov    0x4(%eax),%edx
f0104a26:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f0104a2a:	0f 84 3e ff ff ff    	je     f010496e <sched_yield+0x33>
					cur = cur->next;
f0104a30:	8b 00                	mov    (%eax),%eax
f0104a32:	eb eb                	jmp    f0104a1f <sched_yield+0xe4>
					env_run(curenv);
f0104a34:	e8 49 17 00 00       	call   f0106182 <cpunum>
f0104a39:	83 ec 0c             	sub    $0xc,%esp
f0104a3c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a3f:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f0104a45:	e8 d7 ed ff ff       	call   f0103821 <env_run>
f0104a4a:	b9 80 fe 23 f0       	mov    $0xf023fe80,%ecx
f0104a4f:	bb b0 fe 23 f0       	mov    $0xf023feb0,%ebx
f0104a54:	eb 10                	jmp    f0104a66 <sched_yield+0x12b>
					env_run(cur->env);
f0104a56:	83 ec 0c             	sub    $0xc,%esp
f0104a59:	52                   	push   %edx
f0104a5a:	e8 c2 ed ff ff       	call   f0103821 <env_run>
f0104a5f:	83 c1 0c             	add    $0xc,%ecx
		for (int i = 0; i < 4; i++) {
f0104a62:	39 d9                	cmp    %ebx,%ecx
f0104a64:	74 14                	je     f0104a7a <sched_yield+0x13f>
			Node* cur = MFQueue[i].front;
f0104a66:	8b 41 04             	mov    0x4(%ecx),%eax
			while (cur != NULL) {
f0104a69:	85 c0                	test   %eax,%eax
f0104a6b:	74 f2                	je     f0104a5f <sched_yield+0x124>
				if (cur->env->env_status == ENV_RUNNABLE) {
f0104a6d:	8b 50 04             	mov    0x4(%eax),%edx
f0104a70:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f0104a74:	74 e0                	je     f0104a56 <sched_yield+0x11b>
				cur = cur->next;
f0104a76:	8b 00                	mov    (%eax),%eax
f0104a78:	eb ef                	jmp    f0104a69 <sched_yield+0x12e>
	sched_halt();
f0104a7a:	e8 e8 fd ff ff       	call   f0104867 <sched_halt>
}
f0104a7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104a82:	5b                   	pop    %ebx
f0104a83:	5e                   	pop    %esi
f0104a84:	5f                   	pop    %edi
f0104a85:	5d                   	pop    %ebp
f0104a86:	c3                   	ret    

f0104a87 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104a87:	f3 0f 1e fb          	endbr32 
f0104a8b:	55                   	push   %ebp
f0104a8c:	89 e5                	mov    %esp,%ebp
f0104a8e:	57                   	push   %edi
f0104a8f:	56                   	push   %esi
f0104a90:	53                   	push   %ebx
f0104a91:	83 ec 1c             	sub    $0x1c,%esp
f0104a94:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a97:	83 f8 0c             	cmp    $0xc,%eax
f0104a9a:	0f 87 2e 05 00 00    	ja     f0104fce <syscall+0x547>
f0104aa0:	3e ff 24 85 40 7f 10 	notrack jmp *-0xfef80c0(,%eax,4)
f0104aa7:	f0 
	user_mem_assert(curenv, s, len, 0);
f0104aa8:	e8 d5 16 00 00       	call   f0106182 <cpunum>
f0104aad:	6a 00                	push   $0x0
f0104aaf:	ff 75 10             	pushl  0x10(%ebp)
f0104ab2:	ff 75 0c             	pushl  0xc(%ebp)
f0104ab5:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ab8:	ff b0 28 20 24 f0    	pushl  -0xfdbdfd8(%eax)
f0104abe:	e8 77 e4 ff ff       	call   f0102f3a <user_mem_assert>
	cprintf("%.*s", len, s);
f0104ac3:	83 c4 0c             	add    $0xc,%esp
f0104ac6:	ff 75 0c             	pushl  0xc(%ebp)
f0104ac9:	ff 75 10             	pushl  0x10(%ebp)
f0104acc:	68 06 7f 10 f0       	push   $0xf0107f06
f0104ad1:	e8 f3 ef ff ff       	call   f0103ac9 <cprintf>
}
f0104ad6:	83 c4 10             	add    $0x10,%esp
	// LAB 3: Your code here.
	int32_t ret;
	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char *)a1, (size_t)a2);
			ret = 0;
f0104ad9:	bb 00 00 00 00       	mov    $0x0,%ebx
		default:
			return -E_INVAL;
	}

	return ret;
}
f0104ade:	89 d8                	mov    %ebx,%eax
f0104ae0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104ae3:	5b                   	pop    %ebx
f0104ae4:	5e                   	pop    %esi
f0104ae5:	5f                   	pop    %edi
f0104ae6:	5d                   	pop    %ebp
f0104ae7:	c3                   	ret    
	return cons_getc();
f0104ae8:	e8 12 bb ff ff       	call   f01005ff <cons_getc>
f0104aed:	89 c3                	mov    %eax,%ebx
			break;
f0104aef:	eb ed                	jmp    f0104ade <syscall+0x57>
	return curenv->env_id;
f0104af1:	e8 8c 16 00 00       	call   f0106182 <cpunum>
f0104af6:	6b c0 74             	imul   $0x74,%eax,%eax
f0104af9:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104aff:	8b 58 48             	mov    0x48(%eax),%ebx
			break;
f0104b02:	eb da                	jmp    f0104ade <syscall+0x57>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104b04:	83 ec 04             	sub    $0x4,%esp
f0104b07:	6a 01                	push   $0x1
f0104b09:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104b0c:	50                   	push   %eax
f0104b0d:	ff 75 0c             	pushl  0xc(%ebp)
f0104b10:	e8 e0 e4 ff ff       	call   f0102ff5 <envid2env>
f0104b15:	89 c3                	mov    %eax,%ebx
f0104b17:	83 c4 10             	add    $0x10,%esp
f0104b1a:	85 c0                	test   %eax,%eax
f0104b1c:	78 c0                	js     f0104ade <syscall+0x57>
	if (e == curenv)
f0104b1e:	e8 5f 16 00 00       	call   f0106182 <cpunum>
f0104b23:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104b26:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b29:	39 90 28 20 24 f0    	cmp    %edx,-0xfdbdfd8(%eax)
f0104b2f:	74 3d                	je     f0104b6e <syscall+0xe7>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104b31:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104b34:	e8 49 16 00 00       	call   f0106182 <cpunum>
f0104b39:	83 ec 04             	sub    $0x4,%esp
f0104b3c:	53                   	push   %ebx
f0104b3d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b40:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104b46:	ff 70 48             	pushl  0x48(%eax)
f0104b49:	68 26 7f 10 f0       	push   $0xf0107f26
f0104b4e:	e8 76 ef ff ff       	call   f0103ac9 <cprintf>
f0104b53:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104b56:	83 ec 0c             	sub    $0xc,%esp
f0104b59:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104b5c:	e8 5b ec ff ff       	call   f01037bc <env_destroy>
	return 0;
f0104b61:	83 c4 10             	add    $0x10,%esp
f0104b64:	bb 00 00 00 00       	mov    $0x0,%ebx
			break;
f0104b69:	e9 70 ff ff ff       	jmp    f0104ade <syscall+0x57>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104b6e:	e8 0f 16 00 00       	call   f0106182 <cpunum>
f0104b73:	83 ec 08             	sub    $0x8,%esp
f0104b76:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b79:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104b7f:	ff 70 48             	pushl  0x48(%eax)
f0104b82:	68 0b 7f 10 f0       	push   $0xf0107f0b
f0104b87:	e8 3d ef ff ff       	call   f0103ac9 <cprintf>
f0104b8c:	83 c4 10             	add    $0x10,%esp
f0104b8f:	eb c5                	jmp    f0104b56 <syscall+0xcf>
	sched_yield();
f0104b91:	e8 a5 fd ff ff       	call   f010493b <sched_yield>
	int ret = env_alloc(&e, curenv->env_id);
f0104b96:	e8 e7 15 00 00       	call   f0106182 <cpunum>
f0104b9b:	83 ec 08             	sub    $0x8,%esp
f0104b9e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ba1:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104ba7:	ff 70 48             	pushl  0x48(%eax)
f0104baa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104bad:	50                   	push   %eax
f0104bae:	e8 c6 e6 ff ff       	call   f0103279 <env_alloc>
f0104bb3:	89 c3                	mov    %eax,%ebx
	if (ret < 0) {
f0104bb5:	83 c4 10             	add    $0x10,%esp
f0104bb8:	85 c0                	test   %eax,%eax
f0104bba:	0f 88 1e ff ff ff    	js     f0104ade <syscall+0x57>
	e->env_tf = curenv->env_tf;			
f0104bc0:	e8 bd 15 00 00       	call   f0106182 <cpunum>
f0104bc5:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bc8:	8b b0 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%esi
f0104bce:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104bd3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104bd6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_status = ENV_NOT_RUNNABLE;
f0104bd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104bdb:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	e->env_tf.tf_regs.reg_eax = 0;		
f0104be2:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return e->env_id;
f0104be9:	8b 58 48             	mov    0x48(%eax),%ebx
			break;
f0104bec:	e9 ed fe ff ff       	jmp    f0104ade <syscall+0x57>
	if (status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE) return -E_INVAL;
f0104bf1:	8b 45 10             	mov    0x10(%ebp),%eax
f0104bf4:	83 e8 02             	sub    $0x2,%eax
f0104bf7:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104bfc:	75 31                	jne    f0104c2f <syscall+0x1a8>
	int ret = envid2env(envid, &e, 1);
f0104bfe:	83 ec 04             	sub    $0x4,%esp
f0104c01:	6a 01                	push   $0x1
f0104c03:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104c06:	50                   	push   %eax
f0104c07:	ff 75 0c             	pushl  0xc(%ebp)
f0104c0a:	e8 e6 e3 ff ff       	call   f0102ff5 <envid2env>
f0104c0f:	89 c3                	mov    %eax,%ebx
	if (ret < 0) {
f0104c11:	83 c4 10             	add    $0x10,%esp
f0104c14:	85 c0                	test   %eax,%eax
f0104c16:	0f 88 c2 fe ff ff    	js     f0104ade <syscall+0x57>
	e->env_status = status;
f0104c1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104c22:	89 48 54             	mov    %ecx,0x54(%eax)
	return 0;
f0104c25:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104c2a:	e9 af fe ff ff       	jmp    f0104ade <syscall+0x57>
	if (status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE) return -E_INVAL;
f0104c2f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			break;
f0104c34:	e9 a5 fe ff ff       	jmp    f0104ade <syscall+0x57>
	int ret = envid2env(envid, &e, 1);
f0104c39:	83 ec 04             	sub    $0x4,%esp
f0104c3c:	6a 01                	push   $0x1
f0104c3e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104c41:	50                   	push   %eax
f0104c42:	ff 75 0c             	pushl  0xc(%ebp)
f0104c45:	e8 ab e3 ff ff       	call   f0102ff5 <envid2env>
f0104c4a:	89 c3                	mov    %eax,%ebx
	if (ret) return ret;	
f0104c4c:	83 c4 10             	add    $0x10,%esp
f0104c4f:	85 c0                	test   %eax,%eax
f0104c51:	0f 85 87 fe ff ff    	jne    f0104ade <syscall+0x57>
	if ((va >= (void*)UTOP) || (ROUNDDOWN(va, PGSIZE) != va)) return -E_INVAL;	
f0104c57:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104c5e:	77 5c                	ja     f0104cbc <syscall+0x235>
f0104c60:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104c67:	75 5d                	jne    f0104cc6 <syscall+0x23f>
	if ((perm & flag) != flag) return -E_INVAL;
f0104c69:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c6c:	83 e0 05             	and    $0x5,%eax
f0104c6f:	83 f8 05             	cmp    $0x5,%eax
f0104c72:	75 5c                	jne    f0104cd0 <syscall+0x249>
	struct PageInfo *pg = page_alloc(1);			
f0104c74:	83 ec 0c             	sub    $0xc,%esp
f0104c77:	6a 01                	push   $0x1
f0104c79:	e8 83 c2 ff ff       	call   f0100f01 <page_alloc>
f0104c7e:	89 c6                	mov    %eax,%esi
	if (!pg) return -E_NO_MEM;
f0104c80:	83 c4 10             	add    $0x10,%esp
f0104c83:	85 c0                	test   %eax,%eax
f0104c85:	74 53                	je     f0104cda <syscall+0x253>
	pg->pp_ref++;
f0104c87:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	ret = page_insert(e->env_pgdir, pg, va, perm);	
f0104c8c:	ff 75 14             	pushl  0x14(%ebp)
f0104c8f:	ff 75 10             	pushl  0x10(%ebp)
f0104c92:	50                   	push   %eax
f0104c93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c96:	ff 70 60             	pushl  0x60(%eax)
f0104c99:	e8 43 c5 ff ff       	call   f01011e1 <page_insert>
f0104c9e:	89 c3                	mov    %eax,%ebx
	if (ret) {
f0104ca0:	83 c4 10             	add    $0x10,%esp
f0104ca3:	85 c0                	test   %eax,%eax
f0104ca5:	0f 84 33 fe ff ff    	je     f0104ade <syscall+0x57>
		page_free(pg);
f0104cab:	83 ec 0c             	sub    $0xc,%esp
f0104cae:	56                   	push   %esi
f0104caf:	e8 c6 c2 ff ff       	call   f0100f7a <page_free>
		return ret;
f0104cb4:	83 c4 10             	add    $0x10,%esp
f0104cb7:	e9 22 fe ff ff       	jmp    f0104ade <syscall+0x57>
	if ((va >= (void*)UTOP) || (ROUNDDOWN(va, PGSIZE) != va)) return -E_INVAL;	
f0104cbc:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104cc1:	e9 18 fe ff ff       	jmp    f0104ade <syscall+0x57>
f0104cc6:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104ccb:	e9 0e fe ff ff       	jmp    f0104ade <syscall+0x57>
	if ((perm & flag) != flag) return -E_INVAL;
f0104cd0:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104cd5:	e9 04 fe ff ff       	jmp    f0104ade <syscall+0x57>
	if (!pg) return -E_NO_MEM;
f0104cda:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
			break;
f0104cdf:	e9 fa fd ff ff       	jmp    f0104ade <syscall+0x57>
	int ret = envid2env(srcenvid, &se, 1);
f0104ce4:	83 ec 04             	sub    $0x4,%esp
f0104ce7:	6a 01                	push   $0x1
f0104ce9:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104cec:	50                   	push   %eax
f0104ced:	ff 75 0c             	pushl  0xc(%ebp)
f0104cf0:	e8 00 e3 ff ff       	call   f0102ff5 <envid2env>
f0104cf5:	89 c3                	mov    %eax,%ebx
	if (ret) return ret;	//bad_env
f0104cf7:	83 c4 10             	add    $0x10,%esp
f0104cfa:	85 c0                	test   %eax,%eax
f0104cfc:	0f 85 dc fd ff ff    	jne    f0104ade <syscall+0x57>
	ret = envid2env(dstenvid, &de, 1);
f0104d02:	83 ec 04             	sub    $0x4,%esp
f0104d05:	6a 01                	push   $0x1
f0104d07:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104d0a:	50                   	push   %eax
f0104d0b:	ff 75 14             	pushl  0x14(%ebp)
f0104d0e:	e8 e2 e2 ff ff       	call   f0102ff5 <envid2env>
f0104d13:	89 c3                	mov    %eax,%ebx
	if (ret) return ret;	//bad_env
f0104d15:	83 c4 10             	add    $0x10,%esp
f0104d18:	85 c0                	test   %eax,%eax
f0104d1a:	0f 85 be fd ff ff    	jne    f0104ade <syscall+0x57>
	if (srcva >= (void*)UTOP || dstva >= (void*)UTOP || 
f0104d20:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104d27:	77 6c                	ja     f0104d95 <syscall+0x30e>
f0104d29:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104d30:	77 63                	ja     f0104d95 <syscall+0x30e>
f0104d32:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104d39:	75 64                	jne    f0104d9f <syscall+0x318>
		ROUNDDOWN(srcva,PGSIZE) != srcva || ROUNDDOWN(dstva,PGSIZE) != dstva) 
f0104d3b:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0104d42:	75 65                	jne    f0104da9 <syscall+0x322>
	struct PageInfo *pg = page_lookup(se->env_pgdir, srcva, &pte);
f0104d44:	83 ec 04             	sub    $0x4,%esp
f0104d47:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104d4a:	50                   	push   %eax
f0104d4b:	ff 75 10             	pushl  0x10(%ebp)
f0104d4e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104d51:	ff 70 60             	pushl  0x60(%eax)
f0104d54:	e8 9d c3 ff ff       	call   f01010f6 <page_lookup>
	if (!pg) return -E_INVAL;
f0104d59:	83 c4 10             	add    $0x10,%esp
f0104d5c:	85 c0                	test   %eax,%eax
f0104d5e:	74 53                	je     f0104db3 <syscall+0x32c>
	if ((perm & flag) != flag) return -E_INVAL;
f0104d60:	8b 55 1c             	mov    0x1c(%ebp),%edx
f0104d63:	83 e2 05             	and    $0x5,%edx
f0104d66:	83 fa 05             	cmp    $0x5,%edx
f0104d69:	75 52                	jne    f0104dbd <syscall+0x336>
	if (((*pte&PTE_W) == 0) && (perm&PTE_W)) return -E_INVAL;
f0104d6b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104d6e:	f6 02 02             	testb  $0x2,(%edx)
f0104d71:	75 06                	jne    f0104d79 <syscall+0x2f2>
f0104d73:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104d77:	75 4e                	jne    f0104dc7 <syscall+0x340>
	ret = page_insert(de->env_pgdir, pg, dstva, perm);
f0104d79:	ff 75 1c             	pushl  0x1c(%ebp)
f0104d7c:	ff 75 18             	pushl  0x18(%ebp)
f0104d7f:	50                   	push   %eax
f0104d80:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d83:	ff 70 60             	pushl  0x60(%eax)
f0104d86:	e8 56 c4 ff ff       	call   f01011e1 <page_insert>
f0104d8b:	89 c3                	mov    %eax,%ebx
	return ret;
f0104d8d:	83 c4 10             	add    $0x10,%esp
f0104d90:	e9 49 fd ff ff       	jmp    f0104ade <syscall+0x57>
		return -E_INVAL;
f0104d95:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d9a:	e9 3f fd ff ff       	jmp    f0104ade <syscall+0x57>
f0104d9f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104da4:	e9 35 fd ff ff       	jmp    f0104ade <syscall+0x57>
f0104da9:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104dae:	e9 2b fd ff ff       	jmp    f0104ade <syscall+0x57>
	if (!pg) return -E_INVAL;
f0104db3:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104db8:	e9 21 fd ff ff       	jmp    f0104ade <syscall+0x57>
	if ((perm & flag) != flag) return -E_INVAL;
f0104dbd:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104dc2:	e9 17 fd ff ff       	jmp    f0104ade <syscall+0x57>
	if (((*pte&PTE_W) == 0) && (perm&PTE_W)) return -E_INVAL;
f0104dc7:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			break;
f0104dcc:	e9 0d fd ff ff       	jmp    f0104ade <syscall+0x57>
	int ret = envid2env(envid, &env, 1);
f0104dd1:	83 ec 04             	sub    $0x4,%esp
f0104dd4:	6a 01                	push   $0x1
f0104dd6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104dd9:	50                   	push   %eax
f0104dda:	ff 75 0c             	pushl  0xc(%ebp)
f0104ddd:	e8 13 e2 ff ff       	call   f0102ff5 <envid2env>
f0104de2:	89 c3                	mov    %eax,%ebx
	if (ret) return ret;
f0104de4:	83 c4 10             	add    $0x10,%esp
f0104de7:	85 c0                	test   %eax,%eax
f0104de9:	0f 85 ef fc ff ff    	jne    f0104ade <syscall+0x57>
	if ((va >= (void*)UTOP) || (ROUNDDOWN(va, PGSIZE) != va)) return -E_INVAL;
f0104def:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104df6:	77 22                	ja     f0104e1a <syscall+0x393>
f0104df8:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104dff:	75 23                	jne    f0104e24 <syscall+0x39d>
	page_remove(env->env_pgdir, va);
f0104e01:	83 ec 08             	sub    $0x8,%esp
f0104e04:	ff 75 10             	pushl  0x10(%ebp)
f0104e07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e0a:	ff 70 60             	pushl  0x60(%eax)
f0104e0d:	e8 85 c3 ff ff       	call   f0101197 <page_remove>
	return 0;
f0104e12:	83 c4 10             	add    $0x10,%esp
f0104e15:	e9 c4 fc ff ff       	jmp    f0104ade <syscall+0x57>
	if ((va >= (void*)UTOP) || (ROUNDDOWN(va, PGSIZE) != va)) return -E_INVAL;
f0104e1a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104e1f:	e9 ba fc ff ff       	jmp    f0104ade <syscall+0x57>
f0104e24:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			break;
f0104e29:	e9 b0 fc ff ff       	jmp    f0104ade <syscall+0x57>
	if ((ret = envid2env(envid, &env, 1)) < 0) {
f0104e2e:	83 ec 04             	sub    $0x4,%esp
f0104e31:	6a 01                	push   $0x1
f0104e33:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104e36:	50                   	push   %eax
f0104e37:	ff 75 0c             	pushl  0xc(%ebp)
f0104e3a:	e8 b6 e1 ff ff       	call   f0102ff5 <envid2env>
f0104e3f:	89 c3                	mov    %eax,%ebx
f0104e41:	83 c4 10             	add    $0x10,%esp
f0104e44:	85 c0                	test   %eax,%eax
f0104e46:	0f 88 92 fc ff ff    	js     f0104ade <syscall+0x57>
	env->env_pgfault_upcall = func;
f0104e4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e4f:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104e52:	89 78 64             	mov    %edi,0x64(%eax)
	return 0;
f0104e55:	bb 00 00 00 00       	mov    $0x0,%ebx
			break;
f0104e5a:	e9 7f fc ff ff       	jmp    f0104ade <syscall+0x57>
	int ret = envid2env(envid, &rcvenv, 0);
f0104e5f:	83 ec 04             	sub    $0x4,%esp
f0104e62:	6a 00                	push   $0x0
f0104e64:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104e67:	50                   	push   %eax
f0104e68:	ff 75 0c             	pushl  0xc(%ebp)
f0104e6b:	e8 85 e1 ff ff       	call   f0102ff5 <envid2env>
f0104e70:	89 c3                	mov    %eax,%ebx
	if (ret) return ret;
f0104e72:	83 c4 10             	add    $0x10,%esp
f0104e75:	85 c0                	test   %eax,%eax
f0104e77:	0f 85 61 fc ff ff    	jne    f0104ade <syscall+0x57>
	if (!rcvenv->env_ipc_recving) return -E_IPC_NOT_RECV;
f0104e7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e80:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104e84:	0f 84 de 00 00 00    	je     f0104f68 <syscall+0x4e1>
	if (srcva < (void*)UTOP) {
f0104e8a:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104e91:	77 62                	ja     f0104ef5 <syscall+0x46e>
		struct PageInfo *pg = page_lookup(curenv->env_pgdir, srcva, &pte);
f0104e93:	e8 ea 12 00 00       	call   f0106182 <cpunum>
f0104e98:	83 ec 04             	sub    $0x4,%esp
f0104e9b:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104e9e:	52                   	push   %edx
f0104e9f:	ff 75 14             	pushl  0x14(%ebp)
f0104ea2:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ea5:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104eab:	ff 70 60             	pushl  0x60(%eax)
f0104eae:	e8 43 c2 ff ff       	call   f01010f6 <page_lookup>
		if (srcva != ROUNDDOWN(srcva, PGSIZE)) return -E_INVAL;		
f0104eb3:	83 c4 10             	add    $0x10,%esp
f0104eb6:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104ebd:	74 0a                	je     f0104ec9 <syscall+0x442>
f0104ebf:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104ec4:	e9 15 fc ff ff       	jmp    f0104ade <syscall+0x57>
		if ((*pte & perm) != perm) return -E_INVAL;					
f0104ec9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104ecc:	8b 12                	mov    (%edx),%edx
f0104ece:	89 d1                	mov    %edx,%ecx
f0104ed0:	23 4d 18             	and    0x18(%ebp),%ecx
		if (!pg) return -E_INVAL;									
f0104ed3:	3b 4d 18             	cmp    0x18(%ebp),%ecx
f0104ed6:	75 75                	jne    f0104f4d <syscall+0x4c6>
f0104ed8:	85 c0                	test   %eax,%eax
f0104eda:	74 71                	je     f0104f4d <syscall+0x4c6>
		if ((perm & PTE_W) && !(*pte & PTE_W)) return -E_INVAL;		
f0104edc:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104ee0:	74 05                	je     f0104ee7 <syscall+0x460>
f0104ee2:	f6 c2 02             	test   $0x2,%dl
f0104ee5:	74 70                	je     f0104f57 <syscall+0x4d0>
		if (rcvenv->env_ipc_dstva < (void*)UTOP) {
f0104ee7:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104eea:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0104eed:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f0104ef3:	76 39                	jbe    f0104f2e <syscall+0x4a7>
	rcvenv->env_ipc_recving = 0;					
f0104ef5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ef8:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	rcvenv->env_ipc_from = curenv->env_id;
f0104efc:	e8 81 12 00 00       	call   f0106182 <cpunum>
f0104f01:	89 c2                	mov    %eax,%edx
f0104f03:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104f06:	6b d2 74             	imul   $0x74,%edx,%edx
f0104f09:	8b 92 28 20 24 f0    	mov    -0xfdbdfd8(%edx),%edx
f0104f0f:	8b 52 48             	mov    0x48(%edx),%edx
f0104f12:	89 50 74             	mov    %edx,0x74(%eax)
	rcvenv->env_ipc_value = value; 
f0104f15:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104f18:	89 78 70             	mov    %edi,0x70(%eax)
	rcvenv->env_status = ENV_RUNNABLE;
f0104f1b:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	rcvenv->env_tf.tf_regs.reg_eax = 0;
f0104f22:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return 0;
f0104f29:	e9 b0 fb ff ff       	jmp    f0104ade <syscall+0x57>
			ret = page_insert(rcvenv->env_pgdir, pg, rcvenv->env_ipc_dstva, perm); 
f0104f2e:	ff 75 18             	pushl  0x18(%ebp)
f0104f31:	51                   	push   %ecx
f0104f32:	50                   	push   %eax
f0104f33:	ff 72 60             	pushl  0x60(%edx)
f0104f36:	e8 a6 c2 ff ff       	call   f01011e1 <page_insert>
			if (ret) return ret;
f0104f3b:	83 c4 10             	add    $0x10,%esp
f0104f3e:	85 c0                	test   %eax,%eax
f0104f40:	75 1f                	jne    f0104f61 <syscall+0x4da>
			rcvenv->env_ipc_perm = perm;
f0104f42:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104f45:	8b 7d 18             	mov    0x18(%ebp),%edi
f0104f48:	89 78 78             	mov    %edi,0x78(%eax)
f0104f4b:	eb a8                	jmp    f0104ef5 <syscall+0x46e>
		if (!pg) return -E_INVAL;									
f0104f4d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104f52:	e9 87 fb ff ff       	jmp    f0104ade <syscall+0x57>
		if ((perm & PTE_W) && !(*pte & PTE_W)) return -E_INVAL;		
f0104f57:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104f5c:	e9 7d fb ff ff       	jmp    f0104ade <syscall+0x57>
			if (ret) return ret;
f0104f61:	89 c3                	mov    %eax,%ebx
f0104f63:	e9 76 fb ff ff       	jmp    f0104ade <syscall+0x57>
	if (!rcvenv->env_ipc_recving) return -E_IPC_NOT_RECV;
f0104f68:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
			break;
f0104f6d:	e9 6c fb ff ff       	jmp    f0104ade <syscall+0x57>
	if (dstva < (void *)UTOP && dstva != ROUNDDOWN(dstva, PGSIZE)) {
f0104f72:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104f79:	77 13                	ja     f0104f8e <syscall+0x507>
f0104f7b:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104f82:	74 0a                	je     f0104f8e <syscall+0x507>
			ret = sys_ipc_recv((void *)a1);
f0104f84:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104f89:	e9 50 fb ff ff       	jmp    f0104ade <syscall+0x57>
	curenv->env_ipc_recving = 1;
f0104f8e:	e8 ef 11 00 00       	call   f0106182 <cpunum>
f0104f93:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f96:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104f9c:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104fa0:	e8 dd 11 00 00       	call   f0106182 <cpunum>
f0104fa5:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fa8:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104fae:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_ipc_dstva = dstva;
f0104fb5:	e8 c8 11 00 00       	call   f0106182 <cpunum>
f0104fba:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fbd:	8b 80 28 20 24 f0    	mov    -0xfdbdfd8(%eax),%eax
f0104fc3:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104fc6:	89 78 6c             	mov    %edi,0x6c(%eax)
	sched_yield();
f0104fc9:	e8 6d f9 ff ff       	call   f010493b <sched_yield>
			ret = 0;
f0104fce:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104fd3:	e9 06 fb ff ff       	jmp    f0104ade <syscall+0x57>

f0104fd8 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104fd8:	55                   	push   %ebp
f0104fd9:	89 e5                	mov    %esp,%ebp
f0104fdb:	57                   	push   %edi
f0104fdc:	56                   	push   %esi
f0104fdd:	53                   	push   %ebx
f0104fde:	83 ec 14             	sub    $0x14,%esp
f0104fe1:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104fe4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104fe7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104fea:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104fed:	8b 1a                	mov    (%edx),%ebx
f0104fef:	8b 01                	mov    (%ecx),%eax
f0104ff1:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104ff4:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104ffb:	eb 23                	jmp    f0105020 <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104ffd:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0105000:	eb 1e                	jmp    f0105020 <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105002:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105005:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0105008:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010500c:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010500f:	73 46                	jae    f0105057 <stab_binsearch+0x7f>
			*region_left = m;
f0105011:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105014:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0105016:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0105019:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0105020:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0105023:	7f 5f                	jg     f0105084 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0105025:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105028:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f010502b:	89 d0                	mov    %edx,%eax
f010502d:	c1 e8 1f             	shr    $0x1f,%eax
f0105030:	01 d0                	add    %edx,%eax
f0105032:	89 c7                	mov    %eax,%edi
f0105034:	d1 ff                	sar    %edi
f0105036:	83 e0 fe             	and    $0xfffffffe,%eax
f0105039:	01 f8                	add    %edi,%eax
f010503b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010503e:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0105042:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0105044:	39 c3                	cmp    %eax,%ebx
f0105046:	7f b5                	jg     f0104ffd <stab_binsearch+0x25>
f0105048:	0f b6 0a             	movzbl (%edx),%ecx
f010504b:	83 ea 0c             	sub    $0xc,%edx
f010504e:	39 f1                	cmp    %esi,%ecx
f0105050:	74 b0                	je     f0105002 <stab_binsearch+0x2a>
			m--;
f0105052:	83 e8 01             	sub    $0x1,%eax
f0105055:	eb ed                	jmp    f0105044 <stab_binsearch+0x6c>
		} else if (stabs[m].n_value > addr) {
f0105057:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010505a:	76 14                	jbe    f0105070 <stab_binsearch+0x98>
			*region_right = m - 1;
f010505c:	83 e8 01             	sub    $0x1,%eax
f010505f:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105062:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105065:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0105067:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010506e:	eb b0                	jmp    f0105020 <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105070:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105073:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0105075:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0105079:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f010507b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0105082:	eb 9c                	jmp    f0105020 <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f0105084:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0105088:	75 15                	jne    f010509f <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f010508a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010508d:	8b 00                	mov    (%eax),%eax
f010508f:	83 e8 01             	sub    $0x1,%eax
f0105092:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105095:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0105097:	83 c4 14             	add    $0x14,%esp
f010509a:	5b                   	pop    %ebx
f010509b:	5e                   	pop    %esi
f010509c:	5f                   	pop    %edi
f010509d:	5d                   	pop    %ebp
f010509e:	c3                   	ret    
		for (l = *region_right;
f010509f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01050a2:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01050a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01050a7:	8b 0f                	mov    (%edi),%ecx
f01050a9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01050ac:	8b 7d ec             	mov    -0x14(%ebp),%edi
f01050af:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f01050b3:	eb 03                	jmp    f01050b8 <stab_binsearch+0xe0>
		     l--)
f01050b5:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f01050b8:	39 c1                	cmp    %eax,%ecx
f01050ba:	7d 0a                	jge    f01050c6 <stab_binsearch+0xee>
		     l > *region_left && stabs[l].n_type != type;
f01050bc:	0f b6 1a             	movzbl (%edx),%ebx
f01050bf:	83 ea 0c             	sub    $0xc,%edx
f01050c2:	39 f3                	cmp    %esi,%ebx
f01050c4:	75 ef                	jne    f01050b5 <stab_binsearch+0xdd>
		*region_left = l;
f01050c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01050c9:	89 07                	mov    %eax,(%edi)
}
f01050cb:	eb ca                	jmp    f0105097 <stab_binsearch+0xbf>

f01050cd <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01050cd:	f3 0f 1e fb          	endbr32 
f01050d1:	55                   	push   %ebp
f01050d2:	89 e5                	mov    %esp,%ebp
f01050d4:	57                   	push   %edi
f01050d5:	56                   	push   %esi
f01050d6:	53                   	push   %ebx
f01050d7:	83 ec 4c             	sub    $0x4c,%esp
f01050da:	8b 75 08             	mov    0x8(%ebp),%esi
f01050dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01050e0:	c7 03 74 7f 10 f0    	movl   $0xf0107f74,(%ebx)
	info->eip_line = 0;
f01050e6:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01050ed:	c7 43 08 74 7f 10 f0 	movl   $0xf0107f74,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01050f4:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01050fb:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01050fe:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0105105:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010510b:	0f 87 23 01 00 00    	ja     f0105234 <debuginfo_eip+0x167>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0105111:	a1 00 00 20 00       	mov    0x200000,%eax
f0105116:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stab_end = usd->stab_end;
f0105119:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f010511e:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f0105124:	89 7d b4             	mov    %edi,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f0105127:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f010512d:	89 7d b8             	mov    %edi,-0x48(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0105130:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0105133:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f0105136:	0f 83 c1 01 00 00    	jae    f01052fd <debuginfo_eip+0x230>
f010513c:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0105140:	0f 85 be 01 00 00    	jne    f0105304 <debuginfo_eip+0x237>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105146:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010514d:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0105150:	29 f8                	sub    %edi,%eax
f0105152:	c1 f8 02             	sar    $0x2,%eax
f0105155:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010515b:	83 e8 01             	sub    $0x1,%eax
f010515e:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105161:	56                   	push   %esi
f0105162:	6a 64                	push   $0x64
f0105164:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0105167:	89 c1                	mov    %eax,%ecx
f0105169:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010516c:	89 f8                	mov    %edi,%eax
f010516e:	e8 65 fe ff ff       	call   f0104fd8 <stab_binsearch>
	if (lfile == 0)
f0105173:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105176:	83 c4 08             	add    $0x8,%esp
f0105179:	85 c0                	test   %eax,%eax
f010517b:	0f 84 8a 01 00 00    	je     f010530b <debuginfo_eip+0x23e>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105181:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0105184:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105187:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010518a:	56                   	push   %esi
f010518b:	6a 24                	push   $0x24
f010518d:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0105190:	89 c1                	mov    %eax,%ecx
f0105192:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105195:	89 f8                	mov    %edi,%eax
f0105197:	e8 3c fe ff ff       	call   f0104fd8 <stab_binsearch>

	if (lfun <= rfun) {
f010519c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010519f:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01051a2:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f01051a5:	83 c4 08             	add    $0x8,%esp
f01051a8:	39 c8                	cmp    %ecx,%eax
f01051aa:	0f 8f a3 00 00 00    	jg     f0105253 <debuginfo_eip+0x186>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01051b0:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01051b3:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f01051b6:	8b 11                	mov    (%ecx),%edx
f01051b8:	8b 7d b8             	mov    -0x48(%ebp),%edi
f01051bb:	2b 7d b4             	sub    -0x4c(%ebp),%edi
f01051be:	39 fa                	cmp    %edi,%edx
f01051c0:	73 06                	jae    f01051c8 <debuginfo_eip+0xfb>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01051c2:	03 55 b4             	add    -0x4c(%ebp),%edx
f01051c5:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01051c8:	8b 51 08             	mov    0x8(%ecx),%edx
f01051cb:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01051ce:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01051d0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01051d3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01051d6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01051d9:	83 ec 08             	sub    $0x8,%esp
f01051dc:	6a 3a                	push   $0x3a
f01051de:	ff 73 08             	pushl  0x8(%ebx)
f01051e1:	e8 5d 09 00 00       	call   f0105b43 <strfind>
f01051e6:	2b 43 08             	sub    0x8(%ebx),%eax
f01051e9:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01051ec:	83 c4 08             	add    $0x8,%esp
f01051ef:	56                   	push   %esi
f01051f0:	6a 44                	push   $0x44
f01051f2:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01051f5:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01051f8:	8b 75 bc             	mov    -0x44(%ebp),%esi
f01051fb:	89 f0                	mov    %esi,%eax
f01051fd:	e8 d6 fd ff ff       	call   f0104fd8 <stab_binsearch>
    if(lline <= rline){
f0105202:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105205:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105208:	83 c4 10             	add    $0x10,%esp
        info->eip_line = stabs[rline].n_desc;
    }
    else {
        info->eip_line = -1;
f010520b:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
    if(lline <= rline){
f0105210:	39 c2                	cmp    %eax,%edx
f0105212:	7f 08                	jg     f010521c <debuginfo_eip+0x14f>
        info->eip_line = stabs[rline].n_desc;
f0105214:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105217:	0f b7 4c 86 06       	movzwl 0x6(%esi,%eax,4),%ecx
f010521c:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010521f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105222:	89 d0                	mov    %edx,%eax
f0105224:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0105227:	8b 75 bc             	mov    -0x44(%ebp),%esi
f010522a:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
f010522e:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0105232:	eb 3d                	jmp    f0105271 <debuginfo_eip+0x1a4>
		stabstr_end = __STABSTR_END__;
f0105234:	c7 45 b8 92 91 11 f0 	movl   $0xf0119192,-0x48(%ebp)
		stabstr = __STABSTR_BEGIN__;
f010523b:	c7 45 b4 71 55 11 f0 	movl   $0xf0115571,-0x4c(%ebp)
		stab_end = __STAB_END__;
f0105242:	b8 70 55 11 f0       	mov    $0xf0115570,%eax
		stabs = __STAB_BEGIN__;
f0105247:	c7 45 bc 54 84 10 f0 	movl   $0xf0108454,-0x44(%ebp)
f010524e:	e9 dd fe ff ff       	jmp    f0105130 <debuginfo_eip+0x63>
		info->eip_fn_addr = addr;
f0105253:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0105256:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105259:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f010525c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010525f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105262:	e9 72 ff ff ff       	jmp    f01051d9 <debuginfo_eip+0x10c>
f0105267:	83 e8 01             	sub    $0x1,%eax
f010526a:	83 ea 0c             	sub    $0xc,%edx
	while (lline >= lfile
f010526d:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0105271:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0105274:	39 c7                	cmp    %eax,%edi
f0105276:	7f 45                	jg     f01052bd <debuginfo_eip+0x1f0>
	       && stabs[lline].n_type != N_SOL
f0105278:	0f b6 0a             	movzbl (%edx),%ecx
f010527b:	80 f9 84             	cmp    $0x84,%cl
f010527e:	74 19                	je     f0105299 <debuginfo_eip+0x1cc>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105280:	80 f9 64             	cmp    $0x64,%cl
f0105283:	75 e2                	jne    f0105267 <debuginfo_eip+0x19a>
f0105285:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0105289:	74 dc                	je     f0105267 <debuginfo_eip+0x19a>
f010528b:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f010528f:	74 11                	je     f01052a2 <debuginfo_eip+0x1d5>
f0105291:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0105294:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0105297:	eb 09                	jmp    f01052a2 <debuginfo_eip+0x1d5>
f0105299:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f010529d:	74 03                	je     f01052a2 <debuginfo_eip+0x1d5>
f010529f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01052a2:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01052a5:	8b 75 bc             	mov    -0x44(%ebp),%esi
f01052a8:	8b 14 86             	mov    (%esi,%eax,4),%edx
f01052ab:	8b 45 b8             	mov    -0x48(%ebp),%eax
f01052ae:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f01052b1:	29 f8                	sub    %edi,%eax
f01052b3:	39 c2                	cmp    %eax,%edx
f01052b5:	73 06                	jae    f01052bd <debuginfo_eip+0x1f0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01052b7:	89 f8                	mov    %edi,%eax
f01052b9:	01 d0                	add    %edx,%eax
f01052bb:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01052bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01052c0:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01052c3:	ba 00 00 00 00       	mov    $0x0,%edx
	if (lfun < rfun)
f01052c8:	39 f0                	cmp    %esi,%eax
f01052ca:	7d 4b                	jge    f0105317 <debuginfo_eip+0x24a>
		for (lline = lfun + 1;
f01052cc:	8d 50 01             	lea    0x1(%eax),%edx
f01052cf:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01052d2:	89 d0                	mov    %edx,%eax
f01052d4:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01052d7:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01052da:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f01052de:	eb 04                	jmp    f01052e4 <debuginfo_eip+0x217>
			info->eip_fn_narg++;
f01052e0:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		for (lline = lfun + 1;
f01052e4:	39 c6                	cmp    %eax,%esi
f01052e6:	7e 2a                	jle    f0105312 <debuginfo_eip+0x245>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01052e8:	0f b6 0a             	movzbl (%edx),%ecx
f01052eb:	83 c0 01             	add    $0x1,%eax
f01052ee:	83 c2 0c             	add    $0xc,%edx
f01052f1:	80 f9 a0             	cmp    $0xa0,%cl
f01052f4:	74 ea                	je     f01052e0 <debuginfo_eip+0x213>
	return 0;
f01052f6:	ba 00 00 00 00       	mov    $0x0,%edx
f01052fb:	eb 1a                	jmp    f0105317 <debuginfo_eip+0x24a>
		return -1;
f01052fd:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0105302:	eb 13                	jmp    f0105317 <debuginfo_eip+0x24a>
f0105304:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0105309:	eb 0c                	jmp    f0105317 <debuginfo_eip+0x24a>
		return -1;
f010530b:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0105310:	eb 05                	jmp    f0105317 <debuginfo_eip+0x24a>
	return 0;
f0105312:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105317:	89 d0                	mov    %edx,%eax
f0105319:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010531c:	5b                   	pop    %ebx
f010531d:	5e                   	pop    %esi
f010531e:	5f                   	pop    %edi
f010531f:	5d                   	pop    %ebp
f0105320:	c3                   	ret    

f0105321 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105321:	55                   	push   %ebp
f0105322:	89 e5                	mov    %esp,%ebp
f0105324:	57                   	push   %edi
f0105325:	56                   	push   %esi
f0105326:	53                   	push   %ebx
f0105327:	83 ec 1c             	sub    $0x1c,%esp
f010532a:	89 c7                	mov    %eax,%edi
f010532c:	89 d6                	mov    %edx,%esi
f010532e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105331:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105334:	89 d1                	mov    %edx,%ecx
f0105336:	89 c2                	mov    %eax,%edx
f0105338:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010533b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010533e:	8b 45 10             	mov    0x10(%ebp),%eax
f0105341:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105344:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105347:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f010534e:	39 c2                	cmp    %eax,%edx
f0105350:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0105353:	72 3e                	jb     f0105393 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105355:	83 ec 0c             	sub    $0xc,%esp
f0105358:	ff 75 18             	pushl  0x18(%ebp)
f010535b:	83 eb 01             	sub    $0x1,%ebx
f010535e:	53                   	push   %ebx
f010535f:	50                   	push   %eax
f0105360:	83 ec 08             	sub    $0x8,%esp
f0105363:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105366:	ff 75 e0             	pushl  -0x20(%ebp)
f0105369:	ff 75 dc             	pushl  -0x24(%ebp)
f010536c:	ff 75 d8             	pushl  -0x28(%ebp)
f010536f:	e8 2c 12 00 00       	call   f01065a0 <__udivdi3>
f0105374:	83 c4 18             	add    $0x18,%esp
f0105377:	52                   	push   %edx
f0105378:	50                   	push   %eax
f0105379:	89 f2                	mov    %esi,%edx
f010537b:	89 f8                	mov    %edi,%eax
f010537d:	e8 9f ff ff ff       	call   f0105321 <printnum>
f0105382:	83 c4 20             	add    $0x20,%esp
f0105385:	eb 13                	jmp    f010539a <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105387:	83 ec 08             	sub    $0x8,%esp
f010538a:	56                   	push   %esi
f010538b:	ff 75 18             	pushl  0x18(%ebp)
f010538e:	ff d7                	call   *%edi
f0105390:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0105393:	83 eb 01             	sub    $0x1,%ebx
f0105396:	85 db                	test   %ebx,%ebx
f0105398:	7f ed                	jg     f0105387 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010539a:	83 ec 08             	sub    $0x8,%esp
f010539d:	56                   	push   %esi
f010539e:	83 ec 04             	sub    $0x4,%esp
f01053a1:	ff 75 e4             	pushl  -0x1c(%ebp)
f01053a4:	ff 75 e0             	pushl  -0x20(%ebp)
f01053a7:	ff 75 dc             	pushl  -0x24(%ebp)
f01053aa:	ff 75 d8             	pushl  -0x28(%ebp)
f01053ad:	e8 fe 12 00 00       	call   f01066b0 <__umoddi3>
f01053b2:	83 c4 14             	add    $0x14,%esp
f01053b5:	0f be 80 7e 7f 10 f0 	movsbl -0xfef8082(%eax),%eax
f01053bc:	50                   	push   %eax
f01053bd:	ff d7                	call   *%edi
}
f01053bf:	83 c4 10             	add    $0x10,%esp
f01053c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01053c5:	5b                   	pop    %ebx
f01053c6:	5e                   	pop    %esi
f01053c7:	5f                   	pop    %edi
f01053c8:	5d                   	pop    %ebp
f01053c9:	c3                   	ret    

f01053ca <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01053ca:	f3 0f 1e fb          	endbr32 
f01053ce:	55                   	push   %ebp
f01053cf:	89 e5                	mov    %esp,%ebp
f01053d1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01053d4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01053d8:	8b 10                	mov    (%eax),%edx
f01053da:	3b 50 04             	cmp    0x4(%eax),%edx
f01053dd:	73 0a                	jae    f01053e9 <sprintputch+0x1f>
		*b->buf++ = ch;
f01053df:	8d 4a 01             	lea    0x1(%edx),%ecx
f01053e2:	89 08                	mov    %ecx,(%eax)
f01053e4:	8b 45 08             	mov    0x8(%ebp),%eax
f01053e7:	88 02                	mov    %al,(%edx)
}
f01053e9:	5d                   	pop    %ebp
f01053ea:	c3                   	ret    

f01053eb <printfmt>:
{
f01053eb:	f3 0f 1e fb          	endbr32 
f01053ef:	55                   	push   %ebp
f01053f0:	89 e5                	mov    %esp,%ebp
f01053f2:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01053f5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01053f8:	50                   	push   %eax
f01053f9:	ff 75 10             	pushl  0x10(%ebp)
f01053fc:	ff 75 0c             	pushl  0xc(%ebp)
f01053ff:	ff 75 08             	pushl  0x8(%ebp)
f0105402:	e8 05 00 00 00       	call   f010540c <vprintfmt>
}
f0105407:	83 c4 10             	add    $0x10,%esp
f010540a:	c9                   	leave  
f010540b:	c3                   	ret    

f010540c <vprintfmt>:
{
f010540c:	f3 0f 1e fb          	endbr32 
f0105410:	55                   	push   %ebp
f0105411:	89 e5                	mov    %esp,%ebp
f0105413:	57                   	push   %edi
f0105414:	56                   	push   %esi
f0105415:	53                   	push   %ebx
f0105416:	83 ec 3c             	sub    $0x3c,%esp
f0105419:	8b 75 08             	mov    0x8(%ebp),%esi
f010541c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010541f:	8b 7d 10             	mov    0x10(%ebp),%edi
f0105422:	e9 8e 03 00 00       	jmp    f01057b5 <vprintfmt+0x3a9>
		padc = ' ';
f0105427:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f010542b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f0105432:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0105439:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0105440:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0105445:	8d 47 01             	lea    0x1(%edi),%eax
f0105448:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010544b:	0f b6 17             	movzbl (%edi),%edx
f010544e:	8d 42 dd             	lea    -0x23(%edx),%eax
f0105451:	3c 55                	cmp    $0x55,%al
f0105453:	0f 87 df 03 00 00    	ja     f0105838 <vprintfmt+0x42c>
f0105459:	0f b6 c0             	movzbl %al,%eax
f010545c:	3e ff 24 85 40 80 10 	notrack jmp *-0xfef7fc0(,%eax,4)
f0105463:	f0 
f0105464:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0105467:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f010546b:	eb d8                	jmp    f0105445 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
f010546d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105470:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f0105474:	eb cf                	jmp    f0105445 <vprintfmt+0x39>
f0105476:	0f b6 d2             	movzbl %dl,%edx
f0105479:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f010547c:	b8 00 00 00 00       	mov    $0x0,%eax
f0105481:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0105484:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0105487:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f010548b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f010548e:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0105491:	83 f9 09             	cmp    $0x9,%ecx
f0105494:	77 55                	ja     f01054eb <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
f0105496:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0105499:	eb e9                	jmp    f0105484 <vprintfmt+0x78>
			precision = va_arg(ap, int);
f010549b:	8b 45 14             	mov    0x14(%ebp),%eax
f010549e:	8b 00                	mov    (%eax),%eax
f01054a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01054a3:	8b 45 14             	mov    0x14(%ebp),%eax
f01054a6:	8d 40 04             	lea    0x4(%eax),%eax
f01054a9:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01054ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f01054af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01054b3:	79 90                	jns    f0105445 <vprintfmt+0x39>
				width = precision, precision = -1;
f01054b5:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01054b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01054bb:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f01054c2:	eb 81                	jmp    f0105445 <vprintfmt+0x39>
f01054c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01054c7:	85 c0                	test   %eax,%eax
f01054c9:	ba 00 00 00 00       	mov    $0x0,%edx
f01054ce:	0f 49 d0             	cmovns %eax,%edx
f01054d1:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01054d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01054d7:	e9 69 ff ff ff       	jmp    f0105445 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
f01054dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f01054df:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f01054e6:	e9 5a ff ff ff       	jmp    f0105445 <vprintfmt+0x39>
f01054eb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01054ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01054f1:	eb bc                	jmp    f01054af <vprintfmt+0xa3>
			lflag++;
f01054f3:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f01054f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01054f9:	e9 47 ff ff ff       	jmp    f0105445 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
f01054fe:	8b 45 14             	mov    0x14(%ebp),%eax
f0105501:	8d 78 04             	lea    0x4(%eax),%edi
f0105504:	83 ec 08             	sub    $0x8,%esp
f0105507:	53                   	push   %ebx
f0105508:	ff 30                	pushl  (%eax)
f010550a:	ff d6                	call   *%esi
			break;
f010550c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f010550f:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0105512:	e9 9b 02 00 00       	jmp    f01057b2 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
f0105517:	8b 45 14             	mov    0x14(%ebp),%eax
f010551a:	8d 78 04             	lea    0x4(%eax),%edi
f010551d:	8b 00                	mov    (%eax),%eax
f010551f:	99                   	cltd   
f0105520:	31 d0                	xor    %edx,%eax
f0105522:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105524:	83 f8 08             	cmp    $0x8,%eax
f0105527:	7f 23                	jg     f010554c <vprintfmt+0x140>
f0105529:	8b 14 85 a0 81 10 f0 	mov    -0xfef7e60(,%eax,4),%edx
f0105530:	85 d2                	test   %edx,%edx
f0105532:	74 18                	je     f010554c <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
f0105534:	52                   	push   %edx
f0105535:	68 9d 77 10 f0       	push   $0xf010779d
f010553a:	53                   	push   %ebx
f010553b:	56                   	push   %esi
f010553c:	e8 aa fe ff ff       	call   f01053eb <printfmt>
f0105541:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0105544:	89 7d 14             	mov    %edi,0x14(%ebp)
f0105547:	e9 66 02 00 00       	jmp    f01057b2 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
f010554c:	50                   	push   %eax
f010554d:	68 96 7f 10 f0       	push   $0xf0107f96
f0105552:	53                   	push   %ebx
f0105553:	56                   	push   %esi
f0105554:	e8 92 fe ff ff       	call   f01053eb <printfmt>
f0105559:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010555c:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f010555f:	e9 4e 02 00 00       	jmp    f01057b2 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
f0105564:	8b 45 14             	mov    0x14(%ebp),%eax
f0105567:	83 c0 04             	add    $0x4,%eax
f010556a:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010556d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105570:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f0105572:	85 d2                	test   %edx,%edx
f0105574:	b8 8f 7f 10 f0       	mov    $0xf0107f8f,%eax
f0105579:	0f 45 c2             	cmovne %edx,%eax
f010557c:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
f010557f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105583:	7e 06                	jle    f010558b <vprintfmt+0x17f>
f0105585:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f0105589:	75 0d                	jne    f0105598 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
f010558b:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010558e:	89 c7                	mov    %eax,%edi
f0105590:	03 45 e0             	add    -0x20(%ebp),%eax
f0105593:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105596:	eb 55                	jmp    f01055ed <vprintfmt+0x1e1>
f0105598:	83 ec 08             	sub    $0x8,%esp
f010559b:	ff 75 d8             	pushl  -0x28(%ebp)
f010559e:	ff 75 cc             	pushl  -0x34(%ebp)
f01055a1:	e8 2c 04 00 00       	call   f01059d2 <strnlen>
f01055a6:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01055a9:	29 c2                	sub    %eax,%edx
f01055ab:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f01055ae:	83 c4 10             	add    $0x10,%esp
f01055b1:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
f01055b3:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f01055b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f01055ba:	85 ff                	test   %edi,%edi
f01055bc:	7e 11                	jle    f01055cf <vprintfmt+0x1c3>
					putch(padc, putdat);
f01055be:	83 ec 08             	sub    $0x8,%esp
f01055c1:	53                   	push   %ebx
f01055c2:	ff 75 e0             	pushl  -0x20(%ebp)
f01055c5:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f01055c7:	83 ef 01             	sub    $0x1,%edi
f01055ca:	83 c4 10             	add    $0x10,%esp
f01055cd:	eb eb                	jmp    f01055ba <vprintfmt+0x1ae>
f01055cf:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01055d2:	85 d2                	test   %edx,%edx
f01055d4:	b8 00 00 00 00       	mov    $0x0,%eax
f01055d9:	0f 49 c2             	cmovns %edx,%eax
f01055dc:	29 c2                	sub    %eax,%edx
f01055de:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01055e1:	eb a8                	jmp    f010558b <vprintfmt+0x17f>
					putch(ch, putdat);
f01055e3:	83 ec 08             	sub    $0x8,%esp
f01055e6:	53                   	push   %ebx
f01055e7:	52                   	push   %edx
f01055e8:	ff d6                	call   *%esi
f01055ea:	83 c4 10             	add    $0x10,%esp
f01055ed:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01055f0:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01055f2:	83 c7 01             	add    $0x1,%edi
f01055f5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01055f9:	0f be d0             	movsbl %al,%edx
f01055fc:	85 d2                	test   %edx,%edx
f01055fe:	74 4b                	je     f010564b <vprintfmt+0x23f>
f0105600:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0105604:	78 06                	js     f010560c <vprintfmt+0x200>
f0105606:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f010560a:	78 1e                	js     f010562a <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
f010560c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0105610:	74 d1                	je     f01055e3 <vprintfmt+0x1d7>
f0105612:	0f be c0             	movsbl %al,%eax
f0105615:	83 e8 20             	sub    $0x20,%eax
f0105618:	83 f8 5e             	cmp    $0x5e,%eax
f010561b:	76 c6                	jbe    f01055e3 <vprintfmt+0x1d7>
					putch('?', putdat);
f010561d:	83 ec 08             	sub    $0x8,%esp
f0105620:	53                   	push   %ebx
f0105621:	6a 3f                	push   $0x3f
f0105623:	ff d6                	call   *%esi
f0105625:	83 c4 10             	add    $0x10,%esp
f0105628:	eb c3                	jmp    f01055ed <vprintfmt+0x1e1>
f010562a:	89 cf                	mov    %ecx,%edi
f010562c:	eb 0e                	jmp    f010563c <vprintfmt+0x230>
				putch(' ', putdat);
f010562e:	83 ec 08             	sub    $0x8,%esp
f0105631:	53                   	push   %ebx
f0105632:	6a 20                	push   $0x20
f0105634:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0105636:	83 ef 01             	sub    $0x1,%edi
f0105639:	83 c4 10             	add    $0x10,%esp
f010563c:	85 ff                	test   %edi,%edi
f010563e:	7f ee                	jg     f010562e <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
f0105640:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0105643:	89 45 14             	mov    %eax,0x14(%ebp)
f0105646:	e9 67 01 00 00       	jmp    f01057b2 <vprintfmt+0x3a6>
f010564b:	89 cf                	mov    %ecx,%edi
f010564d:	eb ed                	jmp    f010563c <vprintfmt+0x230>
	if (lflag >= 2)
f010564f:	83 f9 01             	cmp    $0x1,%ecx
f0105652:	7f 1b                	jg     f010566f <vprintfmt+0x263>
	else if (lflag)
f0105654:	85 c9                	test   %ecx,%ecx
f0105656:	74 63                	je     f01056bb <vprintfmt+0x2af>
		return va_arg(*ap, long);
f0105658:	8b 45 14             	mov    0x14(%ebp),%eax
f010565b:	8b 00                	mov    (%eax),%eax
f010565d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105660:	99                   	cltd   
f0105661:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105664:	8b 45 14             	mov    0x14(%ebp),%eax
f0105667:	8d 40 04             	lea    0x4(%eax),%eax
f010566a:	89 45 14             	mov    %eax,0x14(%ebp)
f010566d:	eb 17                	jmp    f0105686 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
f010566f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105672:	8b 50 04             	mov    0x4(%eax),%edx
f0105675:	8b 00                	mov    (%eax),%eax
f0105677:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010567a:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010567d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105680:	8d 40 08             	lea    0x8(%eax),%eax
f0105683:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0105686:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105689:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f010568c:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f0105691:	85 c9                	test   %ecx,%ecx
f0105693:	0f 89 ff 00 00 00    	jns    f0105798 <vprintfmt+0x38c>
				putch('-', putdat);
f0105699:	83 ec 08             	sub    $0x8,%esp
f010569c:	53                   	push   %ebx
f010569d:	6a 2d                	push   $0x2d
f010569f:	ff d6                	call   *%esi
				num = -(long long) num;
f01056a1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01056a4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01056a7:	f7 da                	neg    %edx
f01056a9:	83 d1 00             	adc    $0x0,%ecx
f01056ac:	f7 d9                	neg    %ecx
f01056ae:	83 c4 10             	add    $0x10,%esp
			base = 10;
f01056b1:	b8 0a 00 00 00       	mov    $0xa,%eax
f01056b6:	e9 dd 00 00 00       	jmp    f0105798 <vprintfmt+0x38c>
		return va_arg(*ap, int);
f01056bb:	8b 45 14             	mov    0x14(%ebp),%eax
f01056be:	8b 00                	mov    (%eax),%eax
f01056c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01056c3:	99                   	cltd   
f01056c4:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01056c7:	8b 45 14             	mov    0x14(%ebp),%eax
f01056ca:	8d 40 04             	lea    0x4(%eax),%eax
f01056cd:	89 45 14             	mov    %eax,0x14(%ebp)
f01056d0:	eb b4                	jmp    f0105686 <vprintfmt+0x27a>
	if (lflag >= 2)
f01056d2:	83 f9 01             	cmp    $0x1,%ecx
f01056d5:	7f 1e                	jg     f01056f5 <vprintfmt+0x2e9>
	else if (lflag)
f01056d7:	85 c9                	test   %ecx,%ecx
f01056d9:	74 32                	je     f010570d <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
f01056db:	8b 45 14             	mov    0x14(%ebp),%eax
f01056de:	8b 10                	mov    (%eax),%edx
f01056e0:	b9 00 00 00 00       	mov    $0x0,%ecx
f01056e5:	8d 40 04             	lea    0x4(%eax),%eax
f01056e8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01056eb:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
f01056f0:	e9 a3 00 00 00       	jmp    f0105798 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
f01056f5:	8b 45 14             	mov    0x14(%ebp),%eax
f01056f8:	8b 10                	mov    (%eax),%edx
f01056fa:	8b 48 04             	mov    0x4(%eax),%ecx
f01056fd:	8d 40 08             	lea    0x8(%eax),%eax
f0105700:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105703:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
f0105708:	e9 8b 00 00 00       	jmp    f0105798 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
f010570d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105710:	8b 10                	mov    (%eax),%edx
f0105712:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105717:	8d 40 04             	lea    0x4(%eax),%eax
f010571a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010571d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
f0105722:	eb 74                	jmp    f0105798 <vprintfmt+0x38c>
	if (lflag >= 2)
f0105724:	83 f9 01             	cmp    $0x1,%ecx
f0105727:	7f 1b                	jg     f0105744 <vprintfmt+0x338>
	else if (lflag)
f0105729:	85 c9                	test   %ecx,%ecx
f010572b:	74 2c                	je     f0105759 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
f010572d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105730:	8b 10                	mov    (%eax),%edx
f0105732:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105737:	8d 40 04             	lea    0x4(%eax),%eax
f010573a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010573d:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
f0105742:	eb 54                	jmp    f0105798 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
f0105744:	8b 45 14             	mov    0x14(%ebp),%eax
f0105747:	8b 10                	mov    (%eax),%edx
f0105749:	8b 48 04             	mov    0x4(%eax),%ecx
f010574c:	8d 40 08             	lea    0x8(%eax),%eax
f010574f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0105752:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
f0105757:	eb 3f                	jmp    f0105798 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
f0105759:	8b 45 14             	mov    0x14(%ebp),%eax
f010575c:	8b 10                	mov    (%eax),%edx
f010575e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105763:	8d 40 04             	lea    0x4(%eax),%eax
f0105766:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0105769:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
f010576e:	eb 28                	jmp    f0105798 <vprintfmt+0x38c>
			putch('0', putdat);
f0105770:	83 ec 08             	sub    $0x8,%esp
f0105773:	53                   	push   %ebx
f0105774:	6a 30                	push   $0x30
f0105776:	ff d6                	call   *%esi
			putch('x', putdat);
f0105778:	83 c4 08             	add    $0x8,%esp
f010577b:	53                   	push   %ebx
f010577c:	6a 78                	push   $0x78
f010577e:	ff d6                	call   *%esi
			num = (unsigned long long)
f0105780:	8b 45 14             	mov    0x14(%ebp),%eax
f0105783:	8b 10                	mov    (%eax),%edx
f0105785:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f010578a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f010578d:	8d 40 04             	lea    0x4(%eax),%eax
f0105790:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105793:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0105798:	83 ec 0c             	sub    $0xc,%esp
f010579b:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
f010579f:	57                   	push   %edi
f01057a0:	ff 75 e0             	pushl  -0x20(%ebp)
f01057a3:	50                   	push   %eax
f01057a4:	51                   	push   %ecx
f01057a5:	52                   	push   %edx
f01057a6:	89 da                	mov    %ebx,%edx
f01057a8:	89 f0                	mov    %esi,%eax
f01057aa:	e8 72 fb ff ff       	call   f0105321 <printnum>
			break;
f01057af:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f01057b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {	
f01057b5:	83 c7 01             	add    $0x1,%edi
f01057b8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01057bc:	83 f8 25             	cmp    $0x25,%eax
f01057bf:	0f 84 62 fc ff ff    	je     f0105427 <vprintfmt+0x1b>
			if (ch == '\0')										
f01057c5:	85 c0                	test   %eax,%eax
f01057c7:	0f 84 8b 00 00 00    	je     f0105858 <vprintfmt+0x44c>
			putch(ch, putdat);
f01057cd:	83 ec 08             	sub    $0x8,%esp
f01057d0:	53                   	push   %ebx
f01057d1:	50                   	push   %eax
f01057d2:	ff d6                	call   *%esi
f01057d4:	83 c4 10             	add    $0x10,%esp
f01057d7:	eb dc                	jmp    f01057b5 <vprintfmt+0x3a9>
	if (lflag >= 2)
f01057d9:	83 f9 01             	cmp    $0x1,%ecx
f01057dc:	7f 1b                	jg     f01057f9 <vprintfmt+0x3ed>
	else if (lflag)
f01057de:	85 c9                	test   %ecx,%ecx
f01057e0:	74 2c                	je     f010580e <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
f01057e2:	8b 45 14             	mov    0x14(%ebp),%eax
f01057e5:	8b 10                	mov    (%eax),%edx
f01057e7:	b9 00 00 00 00       	mov    $0x0,%ecx
f01057ec:	8d 40 04             	lea    0x4(%eax),%eax
f01057ef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01057f2:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
f01057f7:	eb 9f                	jmp    f0105798 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
f01057f9:	8b 45 14             	mov    0x14(%ebp),%eax
f01057fc:	8b 10                	mov    (%eax),%edx
f01057fe:	8b 48 04             	mov    0x4(%eax),%ecx
f0105801:	8d 40 08             	lea    0x8(%eax),%eax
f0105804:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105807:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
f010580c:	eb 8a                	jmp    f0105798 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
f010580e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105811:	8b 10                	mov    (%eax),%edx
f0105813:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105818:	8d 40 04             	lea    0x4(%eax),%eax
f010581b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010581e:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
f0105823:	e9 70 ff ff ff       	jmp    f0105798 <vprintfmt+0x38c>
			putch(ch, putdat);
f0105828:	83 ec 08             	sub    $0x8,%esp
f010582b:	53                   	push   %ebx
f010582c:	6a 25                	push   $0x25
f010582e:	ff d6                	call   *%esi
			break;
f0105830:	83 c4 10             	add    $0x10,%esp
f0105833:	e9 7a ff ff ff       	jmp    f01057b2 <vprintfmt+0x3a6>
			putch('%', putdat);
f0105838:	83 ec 08             	sub    $0x8,%esp
f010583b:	53                   	push   %ebx
f010583c:	6a 25                	push   $0x25
f010583e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105840:	83 c4 10             	add    $0x10,%esp
f0105843:	89 f8                	mov    %edi,%eax
f0105845:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0105849:	74 05                	je     f0105850 <vprintfmt+0x444>
f010584b:	83 e8 01             	sub    $0x1,%eax
f010584e:	eb f5                	jmp    f0105845 <vprintfmt+0x439>
f0105850:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105853:	e9 5a ff ff ff       	jmp    f01057b2 <vprintfmt+0x3a6>
}
f0105858:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010585b:	5b                   	pop    %ebx
f010585c:	5e                   	pop    %esi
f010585d:	5f                   	pop    %edi
f010585e:	5d                   	pop    %ebp
f010585f:	c3                   	ret    

f0105860 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105860:	f3 0f 1e fb          	endbr32 
f0105864:	55                   	push   %ebp
f0105865:	89 e5                	mov    %esp,%ebp
f0105867:	83 ec 18             	sub    $0x18,%esp
f010586a:	8b 45 08             	mov    0x8(%ebp),%eax
f010586d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105870:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105873:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105877:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010587a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105881:	85 c0                	test   %eax,%eax
f0105883:	74 26                	je     f01058ab <vsnprintf+0x4b>
f0105885:	85 d2                	test   %edx,%edx
f0105887:	7e 22                	jle    f01058ab <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105889:	ff 75 14             	pushl  0x14(%ebp)
f010588c:	ff 75 10             	pushl  0x10(%ebp)
f010588f:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105892:	50                   	push   %eax
f0105893:	68 ca 53 10 f0       	push   $0xf01053ca
f0105898:	e8 6f fb ff ff       	call   f010540c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010589d:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01058a0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01058a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01058a6:	83 c4 10             	add    $0x10,%esp
}
f01058a9:	c9                   	leave  
f01058aa:	c3                   	ret    
		return -E_INVAL;
f01058ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01058b0:	eb f7                	jmp    f01058a9 <vsnprintf+0x49>

f01058b2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01058b2:	f3 0f 1e fb          	endbr32 
f01058b6:	55                   	push   %ebp
f01058b7:	89 e5                	mov    %esp,%ebp
f01058b9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01058bc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01058bf:	50                   	push   %eax
f01058c0:	ff 75 10             	pushl  0x10(%ebp)
f01058c3:	ff 75 0c             	pushl  0xc(%ebp)
f01058c6:	ff 75 08             	pushl  0x8(%ebp)
f01058c9:	e8 92 ff ff ff       	call   f0105860 <vsnprintf>
	va_end(ap);

	return rc;
}
f01058ce:	c9                   	leave  
f01058cf:	c3                   	ret    

f01058d0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01058d0:	f3 0f 1e fb          	endbr32 
f01058d4:	55                   	push   %ebp
f01058d5:	89 e5                	mov    %esp,%ebp
f01058d7:	57                   	push   %edi
f01058d8:	56                   	push   %esi
f01058d9:	53                   	push   %ebx
f01058da:	83 ec 0c             	sub    $0xc,%esp
f01058dd:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01058e0:	85 c0                	test   %eax,%eax
f01058e2:	74 11                	je     f01058f5 <readline+0x25>
		cprintf("%s", prompt);
f01058e4:	83 ec 08             	sub    $0x8,%esp
f01058e7:	50                   	push   %eax
f01058e8:	68 9d 77 10 f0       	push   $0xf010779d
f01058ed:	e8 d7 e1 ff ff       	call   f0103ac9 <cprintf>
f01058f2:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01058f5:	83 ec 0c             	sub    $0xc,%esp
f01058f8:	6a 00                	push   $0x0
f01058fa:	e8 9e ae ff ff       	call   f010079d <iscons>
f01058ff:	89 c7                	mov    %eax,%edi
f0105901:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0105904:	be 00 00 00 00       	mov    $0x0,%esi
f0105909:	eb 4b                	jmp    f0105956 <readline+0x86>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f010590b:	83 ec 08             	sub    $0x8,%esp
f010590e:	50                   	push   %eax
f010590f:	68 c4 81 10 f0       	push   $0xf01081c4
f0105914:	e8 b0 e1 ff ff       	call   f0103ac9 <cprintf>
			return NULL;
f0105919:	83 c4 10             	add    $0x10,%esp
f010591c:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0105921:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105924:	5b                   	pop    %ebx
f0105925:	5e                   	pop    %esi
f0105926:	5f                   	pop    %edi
f0105927:	5d                   	pop    %ebp
f0105928:	c3                   	ret    
			if (echoing)
f0105929:	85 ff                	test   %edi,%edi
f010592b:	75 05                	jne    f0105932 <readline+0x62>
			i--;
f010592d:	83 ee 01             	sub    $0x1,%esi
f0105930:	eb 24                	jmp    f0105956 <readline+0x86>
				cputchar('\b');
f0105932:	83 ec 0c             	sub    $0xc,%esp
f0105935:	6a 08                	push   $0x8
f0105937:	e8 38 ae ff ff       	call   f0100774 <cputchar>
f010593c:	83 c4 10             	add    $0x10,%esp
f010593f:	eb ec                	jmp    f010592d <readline+0x5d>
				cputchar(c);
f0105941:	83 ec 0c             	sub    $0xc,%esp
f0105944:	53                   	push   %ebx
f0105945:	e8 2a ae ff ff       	call   f0100774 <cputchar>
f010594a:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010594d:	88 9e 80 fa 23 f0    	mov    %bl,-0xfdc0580(%esi)
f0105953:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f0105956:	e8 2d ae ff ff       	call   f0100788 <getchar>
f010595b:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010595d:	85 c0                	test   %eax,%eax
f010595f:	78 aa                	js     f010590b <readline+0x3b>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105961:	83 f8 08             	cmp    $0x8,%eax
f0105964:	0f 94 c2             	sete   %dl
f0105967:	83 f8 7f             	cmp    $0x7f,%eax
f010596a:	0f 94 c0             	sete   %al
f010596d:	08 c2                	or     %al,%dl
f010596f:	74 04                	je     f0105975 <readline+0xa5>
f0105971:	85 f6                	test   %esi,%esi
f0105973:	7f b4                	jg     f0105929 <readline+0x59>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105975:	83 fb 1f             	cmp    $0x1f,%ebx
f0105978:	7e 0e                	jle    f0105988 <readline+0xb8>
f010597a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105980:	7f 06                	jg     f0105988 <readline+0xb8>
			if (echoing)
f0105982:	85 ff                	test   %edi,%edi
f0105984:	74 c7                	je     f010594d <readline+0x7d>
f0105986:	eb b9                	jmp    f0105941 <readline+0x71>
		} else if (c == '\n' || c == '\r') {
f0105988:	83 fb 0a             	cmp    $0xa,%ebx
f010598b:	74 05                	je     f0105992 <readline+0xc2>
f010598d:	83 fb 0d             	cmp    $0xd,%ebx
f0105990:	75 c4                	jne    f0105956 <readline+0x86>
			if (echoing)
f0105992:	85 ff                	test   %edi,%edi
f0105994:	75 11                	jne    f01059a7 <readline+0xd7>
			buf[i] = 0;
f0105996:	c6 86 80 fa 23 f0 00 	movb   $0x0,-0xfdc0580(%esi)
			return buf;
f010599d:	b8 80 fa 23 f0       	mov    $0xf023fa80,%eax
f01059a2:	e9 7a ff ff ff       	jmp    f0105921 <readline+0x51>
				cputchar('\n');
f01059a7:	83 ec 0c             	sub    $0xc,%esp
f01059aa:	6a 0a                	push   $0xa
f01059ac:	e8 c3 ad ff ff       	call   f0100774 <cputchar>
f01059b1:	83 c4 10             	add    $0x10,%esp
f01059b4:	eb e0                	jmp    f0105996 <readline+0xc6>

f01059b6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01059b6:	f3 0f 1e fb          	endbr32 
f01059ba:	55                   	push   %ebp
f01059bb:	89 e5                	mov    %esp,%ebp
f01059bd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01059c0:	b8 00 00 00 00       	mov    $0x0,%eax
f01059c5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01059c9:	74 05                	je     f01059d0 <strlen+0x1a>
		n++;
f01059cb:	83 c0 01             	add    $0x1,%eax
f01059ce:	eb f5                	jmp    f01059c5 <strlen+0xf>
	return n;
}
f01059d0:	5d                   	pop    %ebp
f01059d1:	c3                   	ret    

f01059d2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01059d2:	f3 0f 1e fb          	endbr32 
f01059d6:	55                   	push   %ebp
f01059d7:	89 e5                	mov    %esp,%ebp
f01059d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01059dc:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01059df:	b8 00 00 00 00       	mov    $0x0,%eax
f01059e4:	39 d0                	cmp    %edx,%eax
f01059e6:	74 0d                	je     f01059f5 <strnlen+0x23>
f01059e8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01059ec:	74 05                	je     f01059f3 <strnlen+0x21>
		n++;
f01059ee:	83 c0 01             	add    $0x1,%eax
f01059f1:	eb f1                	jmp    f01059e4 <strnlen+0x12>
f01059f3:	89 c2                	mov    %eax,%edx
	return n;
}
f01059f5:	89 d0                	mov    %edx,%eax
f01059f7:	5d                   	pop    %ebp
f01059f8:	c3                   	ret    

f01059f9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01059f9:	f3 0f 1e fb          	endbr32 
f01059fd:	55                   	push   %ebp
f01059fe:	89 e5                	mov    %esp,%ebp
f0105a00:	53                   	push   %ebx
f0105a01:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105a04:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105a07:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a0c:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0105a10:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0105a13:	83 c0 01             	add    $0x1,%eax
f0105a16:	84 d2                	test   %dl,%dl
f0105a18:	75 f2                	jne    f0105a0c <strcpy+0x13>
		/* do nothing */;
	return ret;
}
f0105a1a:	89 c8                	mov    %ecx,%eax
f0105a1c:	5b                   	pop    %ebx
f0105a1d:	5d                   	pop    %ebp
f0105a1e:	c3                   	ret    

f0105a1f <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105a1f:	f3 0f 1e fb          	endbr32 
f0105a23:	55                   	push   %ebp
f0105a24:	89 e5                	mov    %esp,%ebp
f0105a26:	53                   	push   %ebx
f0105a27:	83 ec 10             	sub    $0x10,%esp
f0105a2a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105a2d:	53                   	push   %ebx
f0105a2e:	e8 83 ff ff ff       	call   f01059b6 <strlen>
f0105a33:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0105a36:	ff 75 0c             	pushl  0xc(%ebp)
f0105a39:	01 d8                	add    %ebx,%eax
f0105a3b:	50                   	push   %eax
f0105a3c:	e8 b8 ff ff ff       	call   f01059f9 <strcpy>
	return dst;
}
f0105a41:	89 d8                	mov    %ebx,%eax
f0105a43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105a46:	c9                   	leave  
f0105a47:	c3                   	ret    

f0105a48 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105a48:	f3 0f 1e fb          	endbr32 
f0105a4c:	55                   	push   %ebp
f0105a4d:	89 e5                	mov    %esp,%ebp
f0105a4f:	56                   	push   %esi
f0105a50:	53                   	push   %ebx
f0105a51:	8b 75 08             	mov    0x8(%ebp),%esi
f0105a54:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105a57:	89 f3                	mov    %esi,%ebx
f0105a59:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105a5c:	89 f0                	mov    %esi,%eax
f0105a5e:	39 d8                	cmp    %ebx,%eax
f0105a60:	74 11                	je     f0105a73 <strncpy+0x2b>
		*dst++ = *src;
f0105a62:	83 c0 01             	add    $0x1,%eax
f0105a65:	0f b6 0a             	movzbl (%edx),%ecx
f0105a68:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105a6b:	80 f9 01             	cmp    $0x1,%cl
f0105a6e:	83 da ff             	sbb    $0xffffffff,%edx
f0105a71:	eb eb                	jmp    f0105a5e <strncpy+0x16>
	}
	return ret;
}
f0105a73:	89 f0                	mov    %esi,%eax
f0105a75:	5b                   	pop    %ebx
f0105a76:	5e                   	pop    %esi
f0105a77:	5d                   	pop    %ebp
f0105a78:	c3                   	ret    

f0105a79 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105a79:	f3 0f 1e fb          	endbr32 
f0105a7d:	55                   	push   %ebp
f0105a7e:	89 e5                	mov    %esp,%ebp
f0105a80:	56                   	push   %esi
f0105a81:	53                   	push   %ebx
f0105a82:	8b 75 08             	mov    0x8(%ebp),%esi
f0105a85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105a88:	8b 55 10             	mov    0x10(%ebp),%edx
f0105a8b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105a8d:	85 d2                	test   %edx,%edx
f0105a8f:	74 21                	je     f0105ab2 <strlcpy+0x39>
f0105a91:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105a95:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f0105a97:	39 c2                	cmp    %eax,%edx
f0105a99:	74 14                	je     f0105aaf <strlcpy+0x36>
f0105a9b:	0f b6 19             	movzbl (%ecx),%ebx
f0105a9e:	84 db                	test   %bl,%bl
f0105aa0:	74 0b                	je     f0105aad <strlcpy+0x34>
			*dst++ = *src++;
f0105aa2:	83 c1 01             	add    $0x1,%ecx
f0105aa5:	83 c2 01             	add    $0x1,%edx
f0105aa8:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105aab:	eb ea                	jmp    f0105a97 <strlcpy+0x1e>
f0105aad:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0105aaf:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105ab2:	29 f0                	sub    %esi,%eax
}
f0105ab4:	5b                   	pop    %ebx
f0105ab5:	5e                   	pop    %esi
f0105ab6:	5d                   	pop    %ebp
f0105ab7:	c3                   	ret    

f0105ab8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105ab8:	f3 0f 1e fb          	endbr32 
f0105abc:	55                   	push   %ebp
f0105abd:	89 e5                	mov    %esp,%ebp
f0105abf:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105ac2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105ac5:	0f b6 01             	movzbl (%ecx),%eax
f0105ac8:	84 c0                	test   %al,%al
f0105aca:	74 0c                	je     f0105ad8 <strcmp+0x20>
f0105acc:	3a 02                	cmp    (%edx),%al
f0105ace:	75 08                	jne    f0105ad8 <strcmp+0x20>
		p++, q++;
f0105ad0:	83 c1 01             	add    $0x1,%ecx
f0105ad3:	83 c2 01             	add    $0x1,%edx
f0105ad6:	eb ed                	jmp    f0105ac5 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105ad8:	0f b6 c0             	movzbl %al,%eax
f0105adb:	0f b6 12             	movzbl (%edx),%edx
f0105ade:	29 d0                	sub    %edx,%eax
}
f0105ae0:	5d                   	pop    %ebp
f0105ae1:	c3                   	ret    

f0105ae2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105ae2:	f3 0f 1e fb          	endbr32 
f0105ae6:	55                   	push   %ebp
f0105ae7:	89 e5                	mov    %esp,%ebp
f0105ae9:	53                   	push   %ebx
f0105aea:	8b 45 08             	mov    0x8(%ebp),%eax
f0105aed:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105af0:	89 c3                	mov    %eax,%ebx
f0105af2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105af5:	eb 06                	jmp    f0105afd <strncmp+0x1b>
		n--, p++, q++;
f0105af7:	83 c0 01             	add    $0x1,%eax
f0105afa:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0105afd:	39 d8                	cmp    %ebx,%eax
f0105aff:	74 16                	je     f0105b17 <strncmp+0x35>
f0105b01:	0f b6 08             	movzbl (%eax),%ecx
f0105b04:	84 c9                	test   %cl,%cl
f0105b06:	74 04                	je     f0105b0c <strncmp+0x2a>
f0105b08:	3a 0a                	cmp    (%edx),%cl
f0105b0a:	74 eb                	je     f0105af7 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105b0c:	0f b6 00             	movzbl (%eax),%eax
f0105b0f:	0f b6 12             	movzbl (%edx),%edx
f0105b12:	29 d0                	sub    %edx,%eax
}
f0105b14:	5b                   	pop    %ebx
f0105b15:	5d                   	pop    %ebp
f0105b16:	c3                   	ret    
		return 0;
f0105b17:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b1c:	eb f6                	jmp    f0105b14 <strncmp+0x32>

f0105b1e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105b1e:	f3 0f 1e fb          	endbr32 
f0105b22:	55                   	push   %ebp
f0105b23:	89 e5                	mov    %esp,%ebp
f0105b25:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b28:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105b2c:	0f b6 10             	movzbl (%eax),%edx
f0105b2f:	84 d2                	test   %dl,%dl
f0105b31:	74 09                	je     f0105b3c <strchr+0x1e>
		if (*s == c)
f0105b33:	38 ca                	cmp    %cl,%dl
f0105b35:	74 0a                	je     f0105b41 <strchr+0x23>
	for (; *s; s++)
f0105b37:	83 c0 01             	add    $0x1,%eax
f0105b3a:	eb f0                	jmp    f0105b2c <strchr+0xe>
			return (char *) s;
	return 0;
f0105b3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105b41:	5d                   	pop    %ebp
f0105b42:	c3                   	ret    

f0105b43 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105b43:	f3 0f 1e fb          	endbr32 
f0105b47:	55                   	push   %ebp
f0105b48:	89 e5                	mov    %esp,%ebp
f0105b4a:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b4d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105b51:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105b54:	38 ca                	cmp    %cl,%dl
f0105b56:	74 09                	je     f0105b61 <strfind+0x1e>
f0105b58:	84 d2                	test   %dl,%dl
f0105b5a:	74 05                	je     f0105b61 <strfind+0x1e>
	for (; *s; s++)
f0105b5c:	83 c0 01             	add    $0x1,%eax
f0105b5f:	eb f0                	jmp    f0105b51 <strfind+0xe>
			break;
	return (char *) s;
}
f0105b61:	5d                   	pop    %ebp
f0105b62:	c3                   	ret    

f0105b63 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105b63:	f3 0f 1e fb          	endbr32 
f0105b67:	55                   	push   %ebp
f0105b68:	89 e5                	mov    %esp,%ebp
f0105b6a:	57                   	push   %edi
f0105b6b:	56                   	push   %esi
f0105b6c:	53                   	push   %ebx
f0105b6d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105b70:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105b73:	85 c9                	test   %ecx,%ecx
f0105b75:	74 31                	je     f0105ba8 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105b77:	89 f8                	mov    %edi,%eax
f0105b79:	09 c8                	or     %ecx,%eax
f0105b7b:	a8 03                	test   $0x3,%al
f0105b7d:	75 23                	jne    f0105ba2 <memset+0x3f>
		c &= 0xFF;
f0105b7f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105b83:	89 d3                	mov    %edx,%ebx
f0105b85:	c1 e3 08             	shl    $0x8,%ebx
f0105b88:	89 d0                	mov    %edx,%eax
f0105b8a:	c1 e0 18             	shl    $0x18,%eax
f0105b8d:	89 d6                	mov    %edx,%esi
f0105b8f:	c1 e6 10             	shl    $0x10,%esi
f0105b92:	09 f0                	or     %esi,%eax
f0105b94:	09 c2                	or     %eax,%edx
f0105b96:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105b98:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0105b9b:	89 d0                	mov    %edx,%eax
f0105b9d:	fc                   	cld    
f0105b9e:	f3 ab                	rep stos %eax,%es:(%edi)
f0105ba0:	eb 06                	jmp    f0105ba8 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105ba2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105ba5:	fc                   	cld    
f0105ba6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105ba8:	89 f8                	mov    %edi,%eax
f0105baa:	5b                   	pop    %ebx
f0105bab:	5e                   	pop    %esi
f0105bac:	5f                   	pop    %edi
f0105bad:	5d                   	pop    %ebp
f0105bae:	c3                   	ret    

f0105baf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105baf:	f3 0f 1e fb          	endbr32 
f0105bb3:	55                   	push   %ebp
f0105bb4:	89 e5                	mov    %esp,%ebp
f0105bb6:	57                   	push   %edi
f0105bb7:	56                   	push   %esi
f0105bb8:	8b 45 08             	mov    0x8(%ebp),%eax
f0105bbb:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105bbe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105bc1:	39 c6                	cmp    %eax,%esi
f0105bc3:	73 32                	jae    f0105bf7 <memmove+0x48>
f0105bc5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105bc8:	39 c2                	cmp    %eax,%edx
f0105bca:	76 2b                	jbe    f0105bf7 <memmove+0x48>
		s += n;
		d += n;
f0105bcc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105bcf:	89 fe                	mov    %edi,%esi
f0105bd1:	09 ce                	or     %ecx,%esi
f0105bd3:	09 d6                	or     %edx,%esi
f0105bd5:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105bdb:	75 0e                	jne    f0105beb <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105bdd:	83 ef 04             	sub    $0x4,%edi
f0105be0:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105be3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0105be6:	fd                   	std    
f0105be7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105be9:	eb 09                	jmp    f0105bf4 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105beb:	83 ef 01             	sub    $0x1,%edi
f0105bee:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0105bf1:	fd                   	std    
f0105bf2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105bf4:	fc                   	cld    
f0105bf5:	eb 1a                	jmp    f0105c11 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105bf7:	89 c2                	mov    %eax,%edx
f0105bf9:	09 ca                	or     %ecx,%edx
f0105bfb:	09 f2                	or     %esi,%edx
f0105bfd:	f6 c2 03             	test   $0x3,%dl
f0105c00:	75 0a                	jne    f0105c0c <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105c02:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0105c05:	89 c7                	mov    %eax,%edi
f0105c07:	fc                   	cld    
f0105c08:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105c0a:	eb 05                	jmp    f0105c11 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
f0105c0c:	89 c7                	mov    %eax,%edi
f0105c0e:	fc                   	cld    
f0105c0f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105c11:	5e                   	pop    %esi
f0105c12:	5f                   	pop    %edi
f0105c13:	5d                   	pop    %ebp
f0105c14:	c3                   	ret    

f0105c15 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105c15:	f3 0f 1e fb          	endbr32 
f0105c19:	55                   	push   %ebp
f0105c1a:	89 e5                	mov    %esp,%ebp
f0105c1c:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105c1f:	ff 75 10             	pushl  0x10(%ebp)
f0105c22:	ff 75 0c             	pushl  0xc(%ebp)
f0105c25:	ff 75 08             	pushl  0x8(%ebp)
f0105c28:	e8 82 ff ff ff       	call   f0105baf <memmove>
}
f0105c2d:	c9                   	leave  
f0105c2e:	c3                   	ret    

f0105c2f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105c2f:	f3 0f 1e fb          	endbr32 
f0105c33:	55                   	push   %ebp
f0105c34:	89 e5                	mov    %esp,%ebp
f0105c36:	56                   	push   %esi
f0105c37:	53                   	push   %ebx
f0105c38:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c3b:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105c3e:	89 c6                	mov    %eax,%esi
f0105c40:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105c43:	39 f0                	cmp    %esi,%eax
f0105c45:	74 1c                	je     f0105c63 <memcmp+0x34>
		if (*s1 != *s2)
f0105c47:	0f b6 08             	movzbl (%eax),%ecx
f0105c4a:	0f b6 1a             	movzbl (%edx),%ebx
f0105c4d:	38 d9                	cmp    %bl,%cl
f0105c4f:	75 08                	jne    f0105c59 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0105c51:	83 c0 01             	add    $0x1,%eax
f0105c54:	83 c2 01             	add    $0x1,%edx
f0105c57:	eb ea                	jmp    f0105c43 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
f0105c59:	0f b6 c1             	movzbl %cl,%eax
f0105c5c:	0f b6 db             	movzbl %bl,%ebx
f0105c5f:	29 d8                	sub    %ebx,%eax
f0105c61:	eb 05                	jmp    f0105c68 <memcmp+0x39>
	}

	return 0;
f0105c63:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105c68:	5b                   	pop    %ebx
f0105c69:	5e                   	pop    %esi
f0105c6a:	5d                   	pop    %ebp
f0105c6b:	c3                   	ret    

f0105c6c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105c6c:	f3 0f 1e fb          	endbr32 
f0105c70:	55                   	push   %ebp
f0105c71:	89 e5                	mov    %esp,%ebp
f0105c73:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105c79:	89 c2                	mov    %eax,%edx
f0105c7b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105c7e:	39 d0                	cmp    %edx,%eax
f0105c80:	73 09                	jae    f0105c8b <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105c82:	38 08                	cmp    %cl,(%eax)
f0105c84:	74 05                	je     f0105c8b <memfind+0x1f>
	for (; s < ends; s++)
f0105c86:	83 c0 01             	add    $0x1,%eax
f0105c89:	eb f3                	jmp    f0105c7e <memfind+0x12>
			break;
	return (void *) s;
}
f0105c8b:	5d                   	pop    %ebp
f0105c8c:	c3                   	ret    

f0105c8d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105c8d:	f3 0f 1e fb          	endbr32 
f0105c91:	55                   	push   %ebp
f0105c92:	89 e5                	mov    %esp,%ebp
f0105c94:	57                   	push   %edi
f0105c95:	56                   	push   %esi
f0105c96:	53                   	push   %ebx
f0105c97:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105c9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105c9d:	eb 03                	jmp    f0105ca2 <strtol+0x15>
		s++;
f0105c9f:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0105ca2:	0f b6 01             	movzbl (%ecx),%eax
f0105ca5:	3c 20                	cmp    $0x20,%al
f0105ca7:	74 f6                	je     f0105c9f <strtol+0x12>
f0105ca9:	3c 09                	cmp    $0x9,%al
f0105cab:	74 f2                	je     f0105c9f <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
f0105cad:	3c 2b                	cmp    $0x2b,%al
f0105caf:	74 2a                	je     f0105cdb <strtol+0x4e>
	int neg = 0;
f0105cb1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0105cb6:	3c 2d                	cmp    $0x2d,%al
f0105cb8:	74 2b                	je     f0105ce5 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105cba:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105cc0:	75 0f                	jne    f0105cd1 <strtol+0x44>
f0105cc2:	80 39 30             	cmpb   $0x30,(%ecx)
f0105cc5:	74 28                	je     f0105cef <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105cc7:	85 db                	test   %ebx,%ebx
f0105cc9:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105cce:	0f 44 d8             	cmove  %eax,%ebx
f0105cd1:	b8 00 00 00 00       	mov    $0x0,%eax
f0105cd6:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105cd9:	eb 46                	jmp    f0105d21 <strtol+0x94>
		s++;
f0105cdb:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0105cde:	bf 00 00 00 00       	mov    $0x0,%edi
f0105ce3:	eb d5                	jmp    f0105cba <strtol+0x2d>
		s++, neg = 1;
f0105ce5:	83 c1 01             	add    $0x1,%ecx
f0105ce8:	bf 01 00 00 00       	mov    $0x1,%edi
f0105ced:	eb cb                	jmp    f0105cba <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105cef:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105cf3:	74 0e                	je     f0105d03 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0105cf5:	85 db                	test   %ebx,%ebx
f0105cf7:	75 d8                	jne    f0105cd1 <strtol+0x44>
		s++, base = 8;
f0105cf9:	83 c1 01             	add    $0x1,%ecx
f0105cfc:	bb 08 00 00 00       	mov    $0x8,%ebx
f0105d01:	eb ce                	jmp    f0105cd1 <strtol+0x44>
		s += 2, base = 16;
f0105d03:	83 c1 02             	add    $0x2,%ecx
f0105d06:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105d0b:	eb c4                	jmp    f0105cd1 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0105d0d:	0f be d2             	movsbl %dl,%edx
f0105d10:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105d13:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105d16:	7d 3a                	jge    f0105d52 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0105d18:	83 c1 01             	add    $0x1,%ecx
f0105d1b:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105d1f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0105d21:	0f b6 11             	movzbl (%ecx),%edx
f0105d24:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105d27:	89 f3                	mov    %esi,%ebx
f0105d29:	80 fb 09             	cmp    $0x9,%bl
f0105d2c:	76 df                	jbe    f0105d0d <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
f0105d2e:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105d31:	89 f3                	mov    %esi,%ebx
f0105d33:	80 fb 19             	cmp    $0x19,%bl
f0105d36:	77 08                	ja     f0105d40 <strtol+0xb3>
			dig = *s - 'a' + 10;
f0105d38:	0f be d2             	movsbl %dl,%edx
f0105d3b:	83 ea 57             	sub    $0x57,%edx
f0105d3e:	eb d3                	jmp    f0105d13 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
f0105d40:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105d43:	89 f3                	mov    %esi,%ebx
f0105d45:	80 fb 19             	cmp    $0x19,%bl
f0105d48:	77 08                	ja     f0105d52 <strtol+0xc5>
			dig = *s - 'A' + 10;
f0105d4a:	0f be d2             	movsbl %dl,%edx
f0105d4d:	83 ea 37             	sub    $0x37,%edx
f0105d50:	eb c1                	jmp    f0105d13 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105d52:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105d56:	74 05                	je     f0105d5d <strtol+0xd0>
		*endptr = (char *) s;
f0105d58:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105d5b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0105d5d:	89 c2                	mov    %eax,%edx
f0105d5f:	f7 da                	neg    %edx
f0105d61:	85 ff                	test   %edi,%edi
f0105d63:	0f 45 c2             	cmovne %edx,%eax
}
f0105d66:	5b                   	pop    %ebx
f0105d67:	5e                   	pop    %esi
f0105d68:	5f                   	pop    %edi
f0105d69:	5d                   	pop    %ebp
f0105d6a:	c3                   	ret    
f0105d6b:	90                   	nop

f0105d6c <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105d6c:	fa                   	cli    

	xorw    %ax, %ax
f0105d6d:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105d6f:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105d71:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105d73:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105d75:	0f 01 16             	lgdtl  (%esi)
f0105d78:	74 70                	je     f0105dea <mpsearch1+0x3>
	movl    %cr0, %eax
f0105d7a:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105d7d:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105d81:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105d84:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105d8a:	08 00                	or     %al,(%eax)

f0105d8c <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105d8c:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105d90:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105d92:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105d94:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105d96:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105d9a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105d9c:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105d9e:	b8 00 20 12 00       	mov    $0x122000,%eax
	movl    %eax, %cr3
f0105da3:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105da6:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105da9:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105dae:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105db1:	8b 25 b8 fe 23 f0    	mov    0xf023feb8,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105db7:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105dbc:	b8 a9 01 10 f0       	mov    $0xf01001a9,%eax
	call    *%eax
f0105dc1:	ff d0                	call   *%eax

f0105dc3 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105dc3:	eb fe                	jmp    f0105dc3 <spin>
f0105dc5:	8d 76 00             	lea    0x0(%esi),%esi

f0105dc8 <gdt>:
	...
f0105dd0:	ff                   	(bad)  
f0105dd1:	ff 00                	incl   (%eax)
f0105dd3:	00 00                	add    %al,(%eax)
f0105dd5:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105ddc:	00                   	.byte 0x0
f0105ddd:	92                   	xchg   %eax,%edx
f0105dde:	cf                   	iret   
	...

f0105de0 <gdtdesc>:
f0105de0:	17                   	pop    %ss
f0105de1:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105de6 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105de6:	90                   	nop

f0105de7 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105de7:	55                   	push   %ebp
f0105de8:	89 e5                	mov    %esp,%ebp
f0105dea:	57                   	push   %edi
f0105deb:	56                   	push   %esi
f0105dec:	53                   	push   %ebx
f0105ded:	83 ec 0c             	sub    $0xc,%esp
f0105df0:	89 c7                	mov    %eax,%edi
	if (PGNUM(pa) >= npages)
f0105df2:	a1 c0 1e 24 f0       	mov    0xf0241ec0,%eax
f0105df7:	89 f9                	mov    %edi,%ecx
f0105df9:	c1 e9 0c             	shr    $0xc,%ecx
f0105dfc:	39 c1                	cmp    %eax,%ecx
f0105dfe:	73 19                	jae    f0105e19 <mpsearch1+0x32>
	return (void *)(pa + KERNBASE);
f0105e00:	8d 9f 00 00 00 f0    	lea    -0x10000000(%edi),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105e06:	01 d7                	add    %edx,%edi
	if (PGNUM(pa) >= npages)
f0105e08:	89 fa                	mov    %edi,%edx
f0105e0a:	c1 ea 0c             	shr    $0xc,%edx
f0105e0d:	39 c2                	cmp    %eax,%edx
f0105e0f:	73 1a                	jae    f0105e2b <mpsearch1+0x44>
	return (void *)(pa + KERNBASE);
f0105e11:	81 ef 00 00 00 10    	sub    $0x10000000,%edi

	for (; mp < end; mp++)
f0105e17:	eb 27                	jmp    f0105e40 <mpsearch1+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105e19:	57                   	push   %edi
f0105e1a:	68 24 68 10 f0       	push   $0xf0106824
f0105e1f:	6a 57                	push   $0x57
f0105e21:	68 61 83 10 f0       	push   $0xf0108361
f0105e26:	e8 15 a2 ff ff       	call   f0100040 <_panic>
f0105e2b:	57                   	push   %edi
f0105e2c:	68 24 68 10 f0       	push   $0xf0106824
f0105e31:	6a 57                	push   $0x57
f0105e33:	68 61 83 10 f0       	push   $0xf0108361
f0105e38:	e8 03 a2 ff ff       	call   f0100040 <_panic>
f0105e3d:	83 c3 10             	add    $0x10,%ebx
f0105e40:	39 fb                	cmp    %edi,%ebx
f0105e42:	73 30                	jae    f0105e74 <mpsearch1+0x8d>
f0105e44:	89 de                	mov    %ebx,%esi
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105e46:	83 ec 04             	sub    $0x4,%esp
f0105e49:	6a 04                	push   $0x4
f0105e4b:	68 71 83 10 f0       	push   $0xf0108371
f0105e50:	53                   	push   %ebx
f0105e51:	e8 d9 fd ff ff       	call   f0105c2f <memcmp>
f0105e56:	83 c4 10             	add    $0x10,%esp
f0105e59:	85 c0                	test   %eax,%eax
f0105e5b:	75 e0                	jne    f0105e3d <mpsearch1+0x56>
f0105e5d:	89 da                	mov    %ebx,%edx
	for (i = 0; i < len; i++)
f0105e5f:	83 c6 10             	add    $0x10,%esi
		sum += ((uint8_t *)addr)[i];
f0105e62:	0f b6 0a             	movzbl (%edx),%ecx
f0105e65:	01 c8                	add    %ecx,%eax
f0105e67:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < len; i++)
f0105e6a:	39 f2                	cmp    %esi,%edx
f0105e6c:	75 f4                	jne    f0105e62 <mpsearch1+0x7b>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105e6e:	84 c0                	test   %al,%al
f0105e70:	75 cb                	jne    f0105e3d <mpsearch1+0x56>
f0105e72:	eb 05                	jmp    f0105e79 <mpsearch1+0x92>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105e74:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0105e79:	89 d8                	mov    %ebx,%eax
f0105e7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105e7e:	5b                   	pop    %ebx
f0105e7f:	5e                   	pop    %esi
f0105e80:	5f                   	pop    %edi
f0105e81:	5d                   	pop    %ebp
f0105e82:	c3                   	ret    

f0105e83 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105e83:	f3 0f 1e fb          	endbr32 
f0105e87:	55                   	push   %ebp
f0105e88:	89 e5                	mov    %esp,%ebp
f0105e8a:	57                   	push   %edi
f0105e8b:	56                   	push   %esi
f0105e8c:	53                   	push   %ebx
f0105e8d:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105e90:	c7 05 c0 23 24 f0 20 	movl   $0xf0242020,0xf02423c0
f0105e97:	20 24 f0 
	if (PGNUM(pa) >= npages)
f0105e9a:	83 3d c0 1e 24 f0 00 	cmpl   $0x0,0xf0241ec0
f0105ea1:	0f 84 a3 00 00 00    	je     f0105f4a <mp_init+0xc7>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105ea7:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105eae:	85 c0                	test   %eax,%eax
f0105eb0:	0f 84 aa 00 00 00    	je     f0105f60 <mp_init+0xdd>
		p <<= 4;	// Translate from segment to PA
f0105eb6:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105eb9:	ba 00 04 00 00       	mov    $0x400,%edx
f0105ebe:	e8 24 ff ff ff       	call   f0105de7 <mpsearch1>
f0105ec3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105ec6:	85 c0                	test   %eax,%eax
f0105ec8:	75 1a                	jne    f0105ee4 <mp_init+0x61>
	return mpsearch1(0xF0000, 0x10000);
f0105eca:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105ecf:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105ed4:	e8 0e ff ff ff       	call   f0105de7 <mpsearch1>
f0105ed9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((mp = mpsearch()) == 0)
f0105edc:	85 c0                	test   %eax,%eax
f0105ede:	0f 84 35 02 00 00    	je     f0106119 <mp_init+0x296>
	if (mp->physaddr == 0 || mp->type != 0) {
f0105ee4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105ee7:	8b 58 04             	mov    0x4(%eax),%ebx
f0105eea:	85 db                	test   %ebx,%ebx
f0105eec:	0f 84 97 00 00 00    	je     f0105f89 <mp_init+0x106>
f0105ef2:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105ef6:	0f 85 8d 00 00 00    	jne    f0105f89 <mp_init+0x106>
f0105efc:	89 d8                	mov    %ebx,%eax
f0105efe:	c1 e8 0c             	shr    $0xc,%eax
f0105f01:	3b 05 c0 1e 24 f0    	cmp    0xf0241ec0,%eax
f0105f07:	0f 83 91 00 00 00    	jae    f0105f9e <mp_init+0x11b>
	return (void *)(pa + KERNBASE);
f0105f0d:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
f0105f13:	89 de                	mov    %ebx,%esi
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105f15:	83 ec 04             	sub    $0x4,%esp
f0105f18:	6a 04                	push   $0x4
f0105f1a:	68 76 83 10 f0       	push   $0xf0108376
f0105f1f:	53                   	push   %ebx
f0105f20:	e8 0a fd ff ff       	call   f0105c2f <memcmp>
f0105f25:	83 c4 10             	add    $0x10,%esp
f0105f28:	85 c0                	test   %eax,%eax
f0105f2a:	0f 85 83 00 00 00    	jne    f0105fb3 <mp_init+0x130>
f0105f30:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f0105f34:	01 df                	add    %ebx,%edi
	sum = 0;
f0105f36:	89 c2                	mov    %eax,%edx
	for (i = 0; i < len; i++)
f0105f38:	39 fb                	cmp    %edi,%ebx
f0105f3a:	0f 84 88 00 00 00    	je     f0105fc8 <mp_init+0x145>
		sum += ((uint8_t *)addr)[i];
f0105f40:	0f b6 0b             	movzbl (%ebx),%ecx
f0105f43:	01 ca                	add    %ecx,%edx
f0105f45:	83 c3 01             	add    $0x1,%ebx
f0105f48:	eb ee                	jmp    f0105f38 <mp_init+0xb5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105f4a:	68 00 04 00 00       	push   $0x400
f0105f4f:	68 24 68 10 f0       	push   $0xf0106824
f0105f54:	6a 6f                	push   $0x6f
f0105f56:	68 61 83 10 f0       	push   $0xf0108361
f0105f5b:	e8 e0 a0 ff ff       	call   f0100040 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105f60:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105f67:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105f6a:	2d 00 04 00 00       	sub    $0x400,%eax
f0105f6f:	ba 00 04 00 00       	mov    $0x400,%edx
f0105f74:	e8 6e fe ff ff       	call   f0105de7 <mpsearch1>
f0105f79:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105f7c:	85 c0                	test   %eax,%eax
f0105f7e:	0f 85 60 ff ff ff    	jne    f0105ee4 <mp_init+0x61>
f0105f84:	e9 41 ff ff ff       	jmp    f0105eca <mp_init+0x47>
		cprintf("SMP: Default configurations not implemented\n");
f0105f89:	83 ec 0c             	sub    $0xc,%esp
f0105f8c:	68 d4 81 10 f0       	push   $0xf01081d4
f0105f91:	e8 33 db ff ff       	call   f0103ac9 <cprintf>
		return NULL;
f0105f96:	83 c4 10             	add    $0x10,%esp
f0105f99:	e9 7b 01 00 00       	jmp    f0106119 <mp_init+0x296>
f0105f9e:	53                   	push   %ebx
f0105f9f:	68 24 68 10 f0       	push   $0xf0106824
f0105fa4:	68 90 00 00 00       	push   $0x90
f0105fa9:	68 61 83 10 f0       	push   $0xf0108361
f0105fae:	e8 8d a0 ff ff       	call   f0100040 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105fb3:	83 ec 0c             	sub    $0xc,%esp
f0105fb6:	68 04 82 10 f0       	push   $0xf0108204
f0105fbb:	e8 09 db ff ff       	call   f0103ac9 <cprintf>
		return NULL;
f0105fc0:	83 c4 10             	add    $0x10,%esp
f0105fc3:	e9 51 01 00 00       	jmp    f0106119 <mp_init+0x296>
	if (sum(conf, conf->length) != 0) {
f0105fc8:	84 d2                	test   %dl,%dl
f0105fca:	75 22                	jne    f0105fee <mp_init+0x16b>
	if (conf->version != 1 && conf->version != 4) {
f0105fcc:	0f b6 56 06          	movzbl 0x6(%esi),%edx
f0105fd0:	80 fa 01             	cmp    $0x1,%dl
f0105fd3:	74 05                	je     f0105fda <mp_init+0x157>
f0105fd5:	80 fa 04             	cmp    $0x4,%dl
f0105fd8:	75 29                	jne    f0106003 <mp_init+0x180>
f0105fda:	0f b7 4e 28          	movzwl 0x28(%esi),%ecx
f0105fde:	01 d9                	add    %ebx,%ecx
	for (i = 0; i < len; i++)
f0105fe0:	39 d9                	cmp    %ebx,%ecx
f0105fe2:	74 38                	je     f010601c <mp_init+0x199>
		sum += ((uint8_t *)addr)[i];
f0105fe4:	0f b6 13             	movzbl (%ebx),%edx
f0105fe7:	01 d0                	add    %edx,%eax
f0105fe9:	83 c3 01             	add    $0x1,%ebx
f0105fec:	eb f2                	jmp    f0105fe0 <mp_init+0x15d>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105fee:	83 ec 0c             	sub    $0xc,%esp
f0105ff1:	68 38 82 10 f0       	push   $0xf0108238
f0105ff6:	e8 ce da ff ff       	call   f0103ac9 <cprintf>
		return NULL;
f0105ffb:	83 c4 10             	add    $0x10,%esp
f0105ffe:	e9 16 01 00 00       	jmp    f0106119 <mp_init+0x296>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0106003:	83 ec 08             	sub    $0x8,%esp
f0106006:	0f b6 d2             	movzbl %dl,%edx
f0106009:	52                   	push   %edx
f010600a:	68 5c 82 10 f0       	push   $0xf010825c
f010600f:	e8 b5 da ff ff       	call   f0103ac9 <cprintf>
		return NULL;
f0106014:	83 c4 10             	add    $0x10,%esp
f0106017:	e9 fd 00 00 00       	jmp    f0106119 <mp_init+0x296>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010601c:	02 46 2a             	add    0x2a(%esi),%al
f010601f:	75 1c                	jne    f010603d <mp_init+0x1ba>
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
f0106021:	c7 05 00 20 24 f0 01 	movl   $0x1,0xf0242000
f0106028:	00 00 00 
	lapicaddr = conf->lapicaddr;
f010602b:	8b 46 24             	mov    0x24(%esi),%eax
f010602e:	a3 00 30 28 f0       	mov    %eax,0xf0283000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106033:	8d 7e 2c             	lea    0x2c(%esi),%edi
f0106036:	bb 00 00 00 00       	mov    $0x0,%ebx
f010603b:	eb 4d                	jmp    f010608a <mp_init+0x207>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f010603d:	83 ec 0c             	sub    $0xc,%esp
f0106040:	68 7c 82 10 f0       	push   $0xf010827c
f0106045:	e8 7f da ff ff       	call   f0103ac9 <cprintf>
		return NULL;
f010604a:	83 c4 10             	add    $0x10,%esp
f010604d:	e9 c7 00 00 00       	jmp    f0106119 <mp_init+0x296>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)			
f0106052:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0106056:	74 11                	je     f0106069 <mp_init+0x1e6>
				bootcpu = &cpus[ncpu];
f0106058:	6b 05 c4 23 24 f0 74 	imul   $0x74,0xf02423c4,%eax
f010605f:	05 20 20 24 f0       	add    $0xf0242020,%eax
f0106064:	a3 c0 23 24 f0       	mov    %eax,0xf02423c0
			if (ncpu < NCPU) {
f0106069:	a1 c4 23 24 f0       	mov    0xf02423c4,%eax
f010606e:	83 f8 07             	cmp    $0x7,%eax
f0106071:	7f 33                	jg     f01060a6 <mp_init+0x223>
				cpus[ncpu].cpu_id = ncpu;			
f0106073:	6b d0 74             	imul   $0x74,%eax,%edx
f0106076:	88 82 20 20 24 f0    	mov    %al,-0xfdbdfe0(%edx)
				ncpu++;
f010607c:	83 c0 01             	add    $0x1,%eax
f010607f:	a3 c4 23 24 f0       	mov    %eax,0xf02423c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106084:	83 c7 14             	add    $0x14,%edi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106087:	83 c3 01             	add    $0x1,%ebx
f010608a:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f010608e:	39 d8                	cmp    %ebx,%eax
f0106090:	76 4f                	jbe    f01060e1 <mp_init+0x25e>
		switch (*p) {
f0106092:	0f b6 07             	movzbl (%edi),%eax
f0106095:	84 c0                	test   %al,%al
f0106097:	74 b9                	je     f0106052 <mp_init+0x1cf>
f0106099:	8d 50 ff             	lea    -0x1(%eax),%edx
f010609c:	80 fa 03             	cmp    $0x3,%dl
f010609f:	77 1c                	ja     f01060bd <mp_init+0x23a>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01060a1:	83 c7 08             	add    $0x8,%edi
			continue;
f01060a4:	eb e1                	jmp    f0106087 <mp_init+0x204>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f01060a6:	83 ec 08             	sub    $0x8,%esp
f01060a9:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f01060ad:	50                   	push   %eax
f01060ae:	68 ac 82 10 f0       	push   $0xf01082ac
f01060b3:	e8 11 da ff ff       	call   f0103ac9 <cprintf>
f01060b8:	83 c4 10             	add    $0x10,%esp
f01060bb:	eb c7                	jmp    f0106084 <mp_init+0x201>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01060bd:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f01060c0:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f01060c3:	50                   	push   %eax
f01060c4:	68 d4 82 10 f0       	push   $0xf01082d4
f01060c9:	e8 fb d9 ff ff       	call   f0103ac9 <cprintf>
			ismp = 0;
f01060ce:	c7 05 00 20 24 f0 00 	movl   $0x0,0xf0242000
f01060d5:	00 00 00 
			i = conf->entry;
f01060d8:	0f b7 5e 22          	movzwl 0x22(%esi),%ebx
f01060dc:	83 c4 10             	add    $0x10,%esp
f01060df:	eb a6                	jmp    f0106087 <mp_init+0x204>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01060e1:	a1 c0 23 24 f0       	mov    0xf02423c0,%eax
f01060e6:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01060ed:	83 3d 00 20 24 f0 00 	cmpl   $0x0,0xf0242000
f01060f4:	74 2b                	je     f0106121 <mp_init+0x29e>
		ncpu = 1;
		lapicaddr = 0;
		cprintf("SMP: configuration not found, SMP disabled\n");
		return;
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01060f6:	83 ec 04             	sub    $0x4,%esp
f01060f9:	ff 35 c4 23 24 f0    	pushl  0xf02423c4
f01060ff:	0f b6 00             	movzbl (%eax),%eax
f0106102:	50                   	push   %eax
f0106103:	68 7b 83 10 f0       	push   $0xf010837b
f0106108:	e8 bc d9 ff ff       	call   f0103ac9 <cprintf>

	if (mp->imcrp) {
f010610d:	83 c4 10             	add    $0x10,%esp
f0106110:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106113:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106117:	75 2e                	jne    f0106147 <mp_init+0x2c4>
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0106119:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010611c:	5b                   	pop    %ebx
f010611d:	5e                   	pop    %esi
f010611e:	5f                   	pop    %edi
f010611f:	5d                   	pop    %ebp
f0106120:	c3                   	ret    
		ncpu = 1;
f0106121:	c7 05 c4 23 24 f0 01 	movl   $0x1,0xf02423c4
f0106128:	00 00 00 
		lapicaddr = 0;
f010612b:	c7 05 00 30 28 f0 00 	movl   $0x0,0xf0283000
f0106132:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106135:	83 ec 0c             	sub    $0xc,%esp
f0106138:	68 f4 82 10 f0       	push   $0xf01082f4
f010613d:	e8 87 d9 ff ff       	call   f0103ac9 <cprintf>
		return;
f0106142:	83 c4 10             	add    $0x10,%esp
f0106145:	eb d2                	jmp    f0106119 <mp_init+0x296>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106147:	83 ec 0c             	sub    $0xc,%esp
f010614a:	68 20 83 10 f0       	push   $0xf0108320
f010614f:	e8 75 d9 ff ff       	call   f0103ac9 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106154:	b8 70 00 00 00       	mov    $0x70,%eax
f0106159:	ba 22 00 00 00       	mov    $0x22,%edx
f010615e:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010615f:	ba 23 00 00 00       	mov    $0x23,%edx
f0106164:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0106165:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106168:	ee                   	out    %al,(%dx)
}
f0106169:	83 c4 10             	add    $0x10,%esp
f010616c:	eb ab                	jmp    f0106119 <mp_init+0x296>

f010616e <lapicw>:
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
	lapic[index] = value;
f010616e:	8b 0d 04 30 28 f0    	mov    0xf0283004,%ecx
f0106174:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0106177:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106179:	a1 04 30 28 f0       	mov    0xf0283004,%eax
f010617e:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106181:	c3                   	ret    

f0106182 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106182:	f3 0f 1e fb          	endbr32 
	if (lapic)
f0106186:	8b 15 04 30 28 f0    	mov    0xf0283004,%edx
		return lapic[ID] >> 24;
	return 0;
f010618c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f0106191:	85 d2                	test   %edx,%edx
f0106193:	74 06                	je     f010619b <cpunum+0x19>
		return lapic[ID] >> 24;
f0106195:	8b 42 20             	mov    0x20(%edx),%eax
f0106198:	c1 e8 18             	shr    $0x18,%eax
}
f010619b:	c3                   	ret    

f010619c <lapic_init>:
{
f010619c:	f3 0f 1e fb          	endbr32 
	if (!lapicaddr)
f01061a0:	a1 00 30 28 f0       	mov    0xf0283000,%eax
f01061a5:	85 c0                	test   %eax,%eax
f01061a7:	75 01                	jne    f01061aa <lapic_init+0xe>
f01061a9:	c3                   	ret    
{
f01061aa:	55                   	push   %ebp
f01061ab:	89 e5                	mov    %esp,%ebp
f01061ad:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f01061b0:	68 00 10 00 00       	push   $0x1000
f01061b5:	50                   	push   %eax
f01061b6:	e8 90 b0 ff ff       	call   f010124b <mmio_map_region>
f01061bb:	a3 04 30 28 f0       	mov    %eax,0xf0283004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01061c0:	ba 27 01 00 00       	mov    $0x127,%edx
f01061c5:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01061ca:	e8 9f ff ff ff       	call   f010616e <lapicw>
	lapicw(TDCR, X1);
f01061cf:	ba 0b 00 00 00       	mov    $0xb,%edx
f01061d4:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01061d9:	e8 90 ff ff ff       	call   f010616e <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01061de:	ba 20 00 02 00       	mov    $0x20020,%edx
f01061e3:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01061e8:	e8 81 ff ff ff       	call   f010616e <lapicw>
	lapicw(TICR, 10000000); 
f01061ed:	ba 80 96 98 00       	mov    $0x989680,%edx
f01061f2:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01061f7:	e8 72 ff ff ff       	call   f010616e <lapicw>
	if (thiscpu != bootcpu)
f01061fc:	e8 81 ff ff ff       	call   f0106182 <cpunum>
f0106201:	6b c0 74             	imul   $0x74,%eax,%eax
f0106204:	05 20 20 24 f0       	add    $0xf0242020,%eax
f0106209:	83 c4 10             	add    $0x10,%esp
f010620c:	39 05 c0 23 24 f0    	cmp    %eax,0xf02423c0
f0106212:	74 0f                	je     f0106223 <lapic_init+0x87>
		lapicw(LINT0, MASKED);
f0106214:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106219:	b8 d4 00 00 00       	mov    $0xd4,%eax
f010621e:	e8 4b ff ff ff       	call   f010616e <lapicw>
	lapicw(LINT1, MASKED);
f0106223:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106228:	b8 d8 00 00 00       	mov    $0xd8,%eax
f010622d:	e8 3c ff ff ff       	call   f010616e <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0106232:	a1 04 30 28 f0       	mov    0xf0283004,%eax
f0106237:	8b 40 30             	mov    0x30(%eax),%eax
f010623a:	c1 e8 10             	shr    $0x10,%eax
f010623d:	a8 fc                	test   $0xfc,%al
f010623f:	75 7c                	jne    f01062bd <lapic_init+0x121>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106241:	ba 33 00 00 00       	mov    $0x33,%edx
f0106246:	b8 dc 00 00 00       	mov    $0xdc,%eax
f010624b:	e8 1e ff ff ff       	call   f010616e <lapicw>
	lapicw(ESR, 0);
f0106250:	ba 00 00 00 00       	mov    $0x0,%edx
f0106255:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010625a:	e8 0f ff ff ff       	call   f010616e <lapicw>
	lapicw(ESR, 0);
f010625f:	ba 00 00 00 00       	mov    $0x0,%edx
f0106264:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106269:	e8 00 ff ff ff       	call   f010616e <lapicw>
	lapicw(EOI, 0);
f010626e:	ba 00 00 00 00       	mov    $0x0,%edx
f0106273:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106278:	e8 f1 fe ff ff       	call   f010616e <lapicw>
	lapicw(ICRHI, 0);
f010627d:	ba 00 00 00 00       	mov    $0x0,%edx
f0106282:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106287:	e8 e2 fe ff ff       	call   f010616e <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010628c:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106291:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106296:	e8 d3 fe ff ff       	call   f010616e <lapicw>
	while(lapic[ICRLO] & DELIVS)
f010629b:	8b 15 04 30 28 f0    	mov    0xf0283004,%edx
f01062a1:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01062a7:	f6 c4 10             	test   $0x10,%ah
f01062aa:	75 f5                	jne    f01062a1 <lapic_init+0x105>
	lapicw(TPR, 0);
f01062ac:	ba 00 00 00 00       	mov    $0x0,%edx
f01062b1:	b8 20 00 00 00       	mov    $0x20,%eax
f01062b6:	e8 b3 fe ff ff       	call   f010616e <lapicw>
}
f01062bb:	c9                   	leave  
f01062bc:	c3                   	ret    
		lapicw(PCINT, MASKED);
f01062bd:	ba 00 00 01 00       	mov    $0x10000,%edx
f01062c2:	b8 d0 00 00 00       	mov    $0xd0,%eax
f01062c7:	e8 a2 fe ff ff       	call   f010616e <lapicw>
f01062cc:	e9 70 ff ff ff       	jmp    f0106241 <lapic_init+0xa5>

f01062d1 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01062d1:	f3 0f 1e fb          	endbr32 
	if (lapic)
f01062d5:	83 3d 04 30 28 f0 00 	cmpl   $0x0,0xf0283004
f01062dc:	74 17                	je     f01062f5 <lapic_eoi+0x24>
{
f01062de:	55                   	push   %ebp
f01062df:	89 e5                	mov    %esp,%ebp
f01062e1:	83 ec 08             	sub    $0x8,%esp
		lapicw(EOI, 0);
f01062e4:	ba 00 00 00 00       	mov    $0x0,%edx
f01062e9:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01062ee:	e8 7b fe ff ff       	call   f010616e <lapicw>
}
f01062f3:	c9                   	leave  
f01062f4:	c3                   	ret    
f01062f5:	c3                   	ret    

f01062f6 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01062f6:	f3 0f 1e fb          	endbr32 
f01062fa:	55                   	push   %ebp
f01062fb:	89 e5                	mov    %esp,%ebp
f01062fd:	56                   	push   %esi
f01062fe:	53                   	push   %ebx
f01062ff:	8b 75 08             	mov    0x8(%ebp),%esi
f0106302:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106305:	b8 0f 00 00 00       	mov    $0xf,%eax
f010630a:	ba 70 00 00 00       	mov    $0x70,%edx
f010630f:	ee                   	out    %al,(%dx)
f0106310:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106315:	ba 71 00 00 00       	mov    $0x71,%edx
f010631a:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f010631b:	83 3d c0 1e 24 f0 00 	cmpl   $0x0,0xf0241ec0
f0106322:	74 7e                	je     f01063a2 <lapic_startap+0xac>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106324:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f010632b:	00 00 
	wrv[1] = addr >> 4;
f010632d:	89 d8                	mov    %ebx,%eax
f010632f:	c1 e8 04             	shr    $0x4,%eax
f0106332:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106338:	c1 e6 18             	shl    $0x18,%esi
f010633b:	89 f2                	mov    %esi,%edx
f010633d:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106342:	e8 27 fe ff ff       	call   f010616e <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106347:	ba 00 c5 00 00       	mov    $0xc500,%edx
f010634c:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106351:	e8 18 fe ff ff       	call   f010616e <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106356:	ba 00 85 00 00       	mov    $0x8500,%edx
f010635b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106360:	e8 09 fe ff ff       	call   f010616e <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106365:	c1 eb 0c             	shr    $0xc,%ebx
f0106368:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f010636b:	89 f2                	mov    %esi,%edx
f010636d:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106372:	e8 f7 fd ff ff       	call   f010616e <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106377:	89 da                	mov    %ebx,%edx
f0106379:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010637e:	e8 eb fd ff ff       	call   f010616e <lapicw>
		lapicw(ICRHI, apicid << 24);
f0106383:	89 f2                	mov    %esi,%edx
f0106385:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010638a:	e8 df fd ff ff       	call   f010616e <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010638f:	89 da                	mov    %ebx,%edx
f0106391:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106396:	e8 d3 fd ff ff       	call   f010616e <lapicw>
		microdelay(200);
	}
}
f010639b:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010639e:	5b                   	pop    %ebx
f010639f:	5e                   	pop    %esi
f01063a0:	5d                   	pop    %ebp
f01063a1:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01063a2:	68 67 04 00 00       	push   $0x467
f01063a7:	68 24 68 10 f0       	push   $0xf0106824
f01063ac:	68 98 00 00 00       	push   $0x98
f01063b1:	68 98 83 10 f0       	push   $0xf0108398
f01063b6:	e8 85 9c ff ff       	call   f0100040 <_panic>

f01063bb <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01063bb:	f3 0f 1e fb          	endbr32 
f01063bf:	55                   	push   %ebp
f01063c0:	89 e5                	mov    %esp,%ebp
f01063c2:	83 ec 08             	sub    $0x8,%esp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01063c5:	8b 55 08             	mov    0x8(%ebp),%edx
f01063c8:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01063ce:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01063d3:	e8 96 fd ff ff       	call   f010616e <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01063d8:	8b 15 04 30 28 f0    	mov    0xf0283004,%edx
f01063de:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01063e4:	f6 c4 10             	test   $0x10,%ah
f01063e7:	75 f5                	jne    f01063de <lapic_ipi+0x23>
		;
}
f01063e9:	c9                   	leave  
f01063ea:	c3                   	ret    

f01063eb <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01063eb:	f3 0f 1e fb          	endbr32 
f01063ef:	55                   	push   %ebp
f01063f0:	89 e5                	mov    %esp,%ebp
f01063f2:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01063f5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01063fb:	8b 55 0c             	mov    0xc(%ebp),%edx
f01063fe:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106401:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0106408:	5d                   	pop    %ebp
f0106409:	c3                   	ret    

f010640a <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f010640a:	f3 0f 1e fb          	endbr32 
f010640e:	55                   	push   %ebp
f010640f:	89 e5                	mov    %esp,%ebp
f0106411:	56                   	push   %esi
f0106412:	53                   	push   %ebx
f0106413:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f0106416:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106419:	75 07                	jne    f0106422 <spin_lock+0x18>
	asm volatile("lock; xchgl %0, %1"
f010641b:	ba 01 00 00 00       	mov    $0x1,%edx
f0106420:	eb 34                	jmp    f0106456 <spin_lock+0x4c>
f0106422:	8b 73 08             	mov    0x8(%ebx),%esi
f0106425:	e8 58 fd ff ff       	call   f0106182 <cpunum>
f010642a:	6b c0 74             	imul   $0x74,%eax,%eax
f010642d:	05 20 20 24 f0       	add    $0xf0242020,%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106432:	39 c6                	cmp    %eax,%esi
f0106434:	75 e5                	jne    f010641b <spin_lock+0x11>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106436:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106439:	e8 44 fd ff ff       	call   f0106182 <cpunum>
f010643e:	83 ec 0c             	sub    $0xc,%esp
f0106441:	53                   	push   %ebx
f0106442:	50                   	push   %eax
f0106443:	68 a8 83 10 f0       	push   $0xf01083a8
f0106448:	6a 41                	push   $0x41
f010644a:	68 0a 84 10 f0       	push   $0xf010840a
f010644f:	e8 ec 9b ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)			//原理见：https://pdos.csail.mit.edu/6.828/2018/xv6/book-rev11.pdf  chapter 4
		asm volatile ("pause");	
f0106454:	f3 90                	pause  
f0106456:	89 d0                	mov    %edx,%eax
f0106458:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)			//原理见：https://pdos.csail.mit.edu/6.828/2018/xv6/book-rev11.pdf  chapter 4
f010645b:	85 c0                	test   %eax,%eax
f010645d:	75 f5                	jne    f0106454 <spin_lock+0x4a>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f010645f:	e8 1e fd ff ff       	call   f0106182 <cpunum>
f0106464:	6b c0 74             	imul   $0x74,%eax,%eax
f0106467:	05 20 20 24 f0       	add    $0xf0242020,%eax
f010646c:	89 43 08             	mov    %eax,0x8(%ebx)
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010646f:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0106471:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106476:	83 f8 09             	cmp    $0x9,%eax
f0106479:	7f 21                	jg     f010649c <spin_lock+0x92>
f010647b:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106481:	76 19                	jbe    f010649c <spin_lock+0x92>
		pcs[i] = ebp[1];          // saved %eip
f0106483:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106486:	89 4c 83 0c          	mov    %ecx,0xc(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f010648a:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f010648c:	83 c0 01             	add    $0x1,%eax
f010648f:	eb e5                	jmp    f0106476 <spin_lock+0x6c>
		pcs[i] = 0;
f0106491:	c7 44 83 0c 00 00 00 	movl   $0x0,0xc(%ebx,%eax,4)
f0106498:	00 
	for (; i < 10; i++)
f0106499:	83 c0 01             	add    $0x1,%eax
f010649c:	83 f8 09             	cmp    $0x9,%eax
f010649f:	7e f0                	jle    f0106491 <spin_lock+0x87>
	get_caller_pcs(lk->pcs);
#endif
}
f01064a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01064a4:	5b                   	pop    %ebx
f01064a5:	5e                   	pop    %esi
f01064a6:	5d                   	pop    %ebp
f01064a7:	c3                   	ret    

f01064a8 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01064a8:	f3 0f 1e fb          	endbr32 
f01064ac:	55                   	push   %ebp
f01064ad:	89 e5                	mov    %esp,%ebp
f01064af:	57                   	push   %edi
f01064b0:	56                   	push   %esi
f01064b1:	53                   	push   %ebx
f01064b2:	83 ec 4c             	sub    $0x4c,%esp
f01064b5:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f01064b8:	83 3e 00             	cmpl   $0x0,(%esi)
f01064bb:	75 35                	jne    f01064f2 <spin_unlock+0x4a>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01064bd:	83 ec 04             	sub    $0x4,%esp
f01064c0:	6a 28                	push   $0x28
f01064c2:	8d 46 0c             	lea    0xc(%esi),%eax
f01064c5:	50                   	push   %eax
f01064c6:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f01064c9:	53                   	push   %ebx
f01064ca:	e8 e0 f6 ff ff       	call   f0105baf <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01064cf:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01064d2:	0f b6 38             	movzbl (%eax),%edi
f01064d5:	8b 76 04             	mov    0x4(%esi),%esi
f01064d8:	e8 a5 fc ff ff       	call   f0106182 <cpunum>
f01064dd:	57                   	push   %edi
f01064de:	56                   	push   %esi
f01064df:	50                   	push   %eax
f01064e0:	68 d4 83 10 f0       	push   $0xf01083d4
f01064e5:	e8 df d5 ff ff       	call   f0103ac9 <cprintf>
f01064ea:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01064ed:	8d 7d a8             	lea    -0x58(%ebp),%edi
f01064f0:	eb 4e                	jmp    f0106540 <spin_unlock+0x98>
	return lock->locked && lock->cpu == thiscpu;
f01064f2:	8b 5e 08             	mov    0x8(%esi),%ebx
f01064f5:	e8 88 fc ff ff       	call   f0106182 <cpunum>
f01064fa:	6b c0 74             	imul   $0x74,%eax,%eax
f01064fd:	05 20 20 24 f0       	add    $0xf0242020,%eax
	if (!holding(lk)) {
f0106502:	39 c3                	cmp    %eax,%ebx
f0106504:	75 b7                	jne    f01064bd <spin_unlock+0x15>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f0106506:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f010650d:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f0106514:	b8 00 00 00 00       	mov    $0x0,%eax
f0106519:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f010651c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010651f:	5b                   	pop    %ebx
f0106520:	5e                   	pop    %esi
f0106521:	5f                   	pop    %edi
f0106522:	5d                   	pop    %ebp
f0106523:	c3                   	ret    
				cprintf("  %08x\n", pcs[i]);
f0106524:	83 ec 08             	sub    $0x8,%esp
f0106527:	ff 36                	pushl  (%esi)
f0106529:	68 31 84 10 f0       	push   $0xf0108431
f010652e:	e8 96 d5 ff ff       	call   f0103ac9 <cprintf>
f0106533:	83 c4 10             	add    $0x10,%esp
f0106536:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106539:	8d 45 e8             	lea    -0x18(%ebp),%eax
f010653c:	39 c3                	cmp    %eax,%ebx
f010653e:	74 40                	je     f0106580 <spin_unlock+0xd8>
f0106540:	89 de                	mov    %ebx,%esi
f0106542:	8b 03                	mov    (%ebx),%eax
f0106544:	85 c0                	test   %eax,%eax
f0106546:	74 38                	je     f0106580 <spin_unlock+0xd8>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106548:	83 ec 08             	sub    $0x8,%esp
f010654b:	57                   	push   %edi
f010654c:	50                   	push   %eax
f010654d:	e8 7b eb ff ff       	call   f01050cd <debuginfo_eip>
f0106552:	83 c4 10             	add    $0x10,%esp
f0106555:	85 c0                	test   %eax,%eax
f0106557:	78 cb                	js     f0106524 <spin_unlock+0x7c>
					pcs[i] - info.eip_fn_addr);
f0106559:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f010655b:	83 ec 04             	sub    $0x4,%esp
f010655e:	89 c2                	mov    %eax,%edx
f0106560:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0106563:	52                   	push   %edx
f0106564:	ff 75 b0             	pushl  -0x50(%ebp)
f0106567:	ff 75 b4             	pushl  -0x4c(%ebp)
f010656a:	ff 75 ac             	pushl  -0x54(%ebp)
f010656d:	ff 75 a8             	pushl  -0x58(%ebp)
f0106570:	50                   	push   %eax
f0106571:	68 1a 84 10 f0       	push   $0xf010841a
f0106576:	e8 4e d5 ff ff       	call   f0103ac9 <cprintf>
f010657b:	83 c4 20             	add    $0x20,%esp
f010657e:	eb b6                	jmp    f0106536 <spin_unlock+0x8e>
		panic("spin_unlock");
f0106580:	83 ec 04             	sub    $0x4,%esp
f0106583:	68 39 84 10 f0       	push   $0xf0108439
f0106588:	6a 67                	push   $0x67
f010658a:	68 0a 84 10 f0       	push   $0xf010840a
f010658f:	e8 ac 9a ff ff       	call   f0100040 <_panic>
f0106594:	66 90                	xchg   %ax,%ax
f0106596:	66 90                	xchg   %ax,%ax
f0106598:	66 90                	xchg   %ax,%ax
f010659a:	66 90                	xchg   %ax,%ax
f010659c:	66 90                	xchg   %ax,%ax
f010659e:	66 90                	xchg   %ax,%ax

f01065a0 <__udivdi3>:
f01065a0:	f3 0f 1e fb          	endbr32 
f01065a4:	55                   	push   %ebp
f01065a5:	57                   	push   %edi
f01065a6:	56                   	push   %esi
f01065a7:	53                   	push   %ebx
f01065a8:	83 ec 1c             	sub    $0x1c,%esp
f01065ab:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01065af:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01065b3:	8b 74 24 34          	mov    0x34(%esp),%esi
f01065b7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f01065bb:	85 d2                	test   %edx,%edx
f01065bd:	75 19                	jne    f01065d8 <__udivdi3+0x38>
f01065bf:	39 f3                	cmp    %esi,%ebx
f01065c1:	76 4d                	jbe    f0106610 <__udivdi3+0x70>
f01065c3:	31 ff                	xor    %edi,%edi
f01065c5:	89 e8                	mov    %ebp,%eax
f01065c7:	89 f2                	mov    %esi,%edx
f01065c9:	f7 f3                	div    %ebx
f01065cb:	89 fa                	mov    %edi,%edx
f01065cd:	83 c4 1c             	add    $0x1c,%esp
f01065d0:	5b                   	pop    %ebx
f01065d1:	5e                   	pop    %esi
f01065d2:	5f                   	pop    %edi
f01065d3:	5d                   	pop    %ebp
f01065d4:	c3                   	ret    
f01065d5:	8d 76 00             	lea    0x0(%esi),%esi
f01065d8:	39 f2                	cmp    %esi,%edx
f01065da:	76 14                	jbe    f01065f0 <__udivdi3+0x50>
f01065dc:	31 ff                	xor    %edi,%edi
f01065de:	31 c0                	xor    %eax,%eax
f01065e0:	89 fa                	mov    %edi,%edx
f01065e2:	83 c4 1c             	add    $0x1c,%esp
f01065e5:	5b                   	pop    %ebx
f01065e6:	5e                   	pop    %esi
f01065e7:	5f                   	pop    %edi
f01065e8:	5d                   	pop    %ebp
f01065e9:	c3                   	ret    
f01065ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01065f0:	0f bd fa             	bsr    %edx,%edi
f01065f3:	83 f7 1f             	xor    $0x1f,%edi
f01065f6:	75 48                	jne    f0106640 <__udivdi3+0xa0>
f01065f8:	39 f2                	cmp    %esi,%edx
f01065fa:	72 06                	jb     f0106602 <__udivdi3+0x62>
f01065fc:	31 c0                	xor    %eax,%eax
f01065fe:	39 eb                	cmp    %ebp,%ebx
f0106600:	77 de                	ja     f01065e0 <__udivdi3+0x40>
f0106602:	b8 01 00 00 00       	mov    $0x1,%eax
f0106607:	eb d7                	jmp    f01065e0 <__udivdi3+0x40>
f0106609:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106610:	89 d9                	mov    %ebx,%ecx
f0106612:	85 db                	test   %ebx,%ebx
f0106614:	75 0b                	jne    f0106621 <__udivdi3+0x81>
f0106616:	b8 01 00 00 00       	mov    $0x1,%eax
f010661b:	31 d2                	xor    %edx,%edx
f010661d:	f7 f3                	div    %ebx
f010661f:	89 c1                	mov    %eax,%ecx
f0106621:	31 d2                	xor    %edx,%edx
f0106623:	89 f0                	mov    %esi,%eax
f0106625:	f7 f1                	div    %ecx
f0106627:	89 c6                	mov    %eax,%esi
f0106629:	89 e8                	mov    %ebp,%eax
f010662b:	89 f7                	mov    %esi,%edi
f010662d:	f7 f1                	div    %ecx
f010662f:	89 fa                	mov    %edi,%edx
f0106631:	83 c4 1c             	add    $0x1c,%esp
f0106634:	5b                   	pop    %ebx
f0106635:	5e                   	pop    %esi
f0106636:	5f                   	pop    %edi
f0106637:	5d                   	pop    %ebp
f0106638:	c3                   	ret    
f0106639:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106640:	89 f9                	mov    %edi,%ecx
f0106642:	b8 20 00 00 00       	mov    $0x20,%eax
f0106647:	29 f8                	sub    %edi,%eax
f0106649:	d3 e2                	shl    %cl,%edx
f010664b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010664f:	89 c1                	mov    %eax,%ecx
f0106651:	89 da                	mov    %ebx,%edx
f0106653:	d3 ea                	shr    %cl,%edx
f0106655:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0106659:	09 d1                	or     %edx,%ecx
f010665b:	89 f2                	mov    %esi,%edx
f010665d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106661:	89 f9                	mov    %edi,%ecx
f0106663:	d3 e3                	shl    %cl,%ebx
f0106665:	89 c1                	mov    %eax,%ecx
f0106667:	d3 ea                	shr    %cl,%edx
f0106669:	89 f9                	mov    %edi,%ecx
f010666b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010666f:	89 eb                	mov    %ebp,%ebx
f0106671:	d3 e6                	shl    %cl,%esi
f0106673:	89 c1                	mov    %eax,%ecx
f0106675:	d3 eb                	shr    %cl,%ebx
f0106677:	09 de                	or     %ebx,%esi
f0106679:	89 f0                	mov    %esi,%eax
f010667b:	f7 74 24 08          	divl   0x8(%esp)
f010667f:	89 d6                	mov    %edx,%esi
f0106681:	89 c3                	mov    %eax,%ebx
f0106683:	f7 64 24 0c          	mull   0xc(%esp)
f0106687:	39 d6                	cmp    %edx,%esi
f0106689:	72 15                	jb     f01066a0 <__udivdi3+0x100>
f010668b:	89 f9                	mov    %edi,%ecx
f010668d:	d3 e5                	shl    %cl,%ebp
f010668f:	39 c5                	cmp    %eax,%ebp
f0106691:	73 04                	jae    f0106697 <__udivdi3+0xf7>
f0106693:	39 d6                	cmp    %edx,%esi
f0106695:	74 09                	je     f01066a0 <__udivdi3+0x100>
f0106697:	89 d8                	mov    %ebx,%eax
f0106699:	31 ff                	xor    %edi,%edi
f010669b:	e9 40 ff ff ff       	jmp    f01065e0 <__udivdi3+0x40>
f01066a0:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01066a3:	31 ff                	xor    %edi,%edi
f01066a5:	e9 36 ff ff ff       	jmp    f01065e0 <__udivdi3+0x40>
f01066aa:	66 90                	xchg   %ax,%ax
f01066ac:	66 90                	xchg   %ax,%ax
f01066ae:	66 90                	xchg   %ax,%ax

f01066b0 <__umoddi3>:
f01066b0:	f3 0f 1e fb          	endbr32 
f01066b4:	55                   	push   %ebp
f01066b5:	57                   	push   %edi
f01066b6:	56                   	push   %esi
f01066b7:	53                   	push   %ebx
f01066b8:	83 ec 1c             	sub    $0x1c,%esp
f01066bb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f01066bf:	8b 74 24 30          	mov    0x30(%esp),%esi
f01066c3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01066c7:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01066cb:	85 c0                	test   %eax,%eax
f01066cd:	75 19                	jne    f01066e8 <__umoddi3+0x38>
f01066cf:	39 df                	cmp    %ebx,%edi
f01066d1:	76 5d                	jbe    f0106730 <__umoddi3+0x80>
f01066d3:	89 f0                	mov    %esi,%eax
f01066d5:	89 da                	mov    %ebx,%edx
f01066d7:	f7 f7                	div    %edi
f01066d9:	89 d0                	mov    %edx,%eax
f01066db:	31 d2                	xor    %edx,%edx
f01066dd:	83 c4 1c             	add    $0x1c,%esp
f01066e0:	5b                   	pop    %ebx
f01066e1:	5e                   	pop    %esi
f01066e2:	5f                   	pop    %edi
f01066e3:	5d                   	pop    %ebp
f01066e4:	c3                   	ret    
f01066e5:	8d 76 00             	lea    0x0(%esi),%esi
f01066e8:	89 f2                	mov    %esi,%edx
f01066ea:	39 d8                	cmp    %ebx,%eax
f01066ec:	76 12                	jbe    f0106700 <__umoddi3+0x50>
f01066ee:	89 f0                	mov    %esi,%eax
f01066f0:	89 da                	mov    %ebx,%edx
f01066f2:	83 c4 1c             	add    $0x1c,%esp
f01066f5:	5b                   	pop    %ebx
f01066f6:	5e                   	pop    %esi
f01066f7:	5f                   	pop    %edi
f01066f8:	5d                   	pop    %ebp
f01066f9:	c3                   	ret    
f01066fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106700:	0f bd e8             	bsr    %eax,%ebp
f0106703:	83 f5 1f             	xor    $0x1f,%ebp
f0106706:	75 50                	jne    f0106758 <__umoddi3+0xa8>
f0106708:	39 d8                	cmp    %ebx,%eax
f010670a:	0f 82 e0 00 00 00    	jb     f01067f0 <__umoddi3+0x140>
f0106710:	89 d9                	mov    %ebx,%ecx
f0106712:	39 f7                	cmp    %esi,%edi
f0106714:	0f 86 d6 00 00 00    	jbe    f01067f0 <__umoddi3+0x140>
f010671a:	89 d0                	mov    %edx,%eax
f010671c:	89 ca                	mov    %ecx,%edx
f010671e:	83 c4 1c             	add    $0x1c,%esp
f0106721:	5b                   	pop    %ebx
f0106722:	5e                   	pop    %esi
f0106723:	5f                   	pop    %edi
f0106724:	5d                   	pop    %ebp
f0106725:	c3                   	ret    
f0106726:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010672d:	8d 76 00             	lea    0x0(%esi),%esi
f0106730:	89 fd                	mov    %edi,%ebp
f0106732:	85 ff                	test   %edi,%edi
f0106734:	75 0b                	jne    f0106741 <__umoddi3+0x91>
f0106736:	b8 01 00 00 00       	mov    $0x1,%eax
f010673b:	31 d2                	xor    %edx,%edx
f010673d:	f7 f7                	div    %edi
f010673f:	89 c5                	mov    %eax,%ebp
f0106741:	89 d8                	mov    %ebx,%eax
f0106743:	31 d2                	xor    %edx,%edx
f0106745:	f7 f5                	div    %ebp
f0106747:	89 f0                	mov    %esi,%eax
f0106749:	f7 f5                	div    %ebp
f010674b:	89 d0                	mov    %edx,%eax
f010674d:	31 d2                	xor    %edx,%edx
f010674f:	eb 8c                	jmp    f01066dd <__umoddi3+0x2d>
f0106751:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106758:	89 e9                	mov    %ebp,%ecx
f010675a:	ba 20 00 00 00       	mov    $0x20,%edx
f010675f:	29 ea                	sub    %ebp,%edx
f0106761:	d3 e0                	shl    %cl,%eax
f0106763:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106767:	89 d1                	mov    %edx,%ecx
f0106769:	89 f8                	mov    %edi,%eax
f010676b:	d3 e8                	shr    %cl,%eax
f010676d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0106771:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106775:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106779:	09 c1                	or     %eax,%ecx
f010677b:	89 d8                	mov    %ebx,%eax
f010677d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106781:	89 e9                	mov    %ebp,%ecx
f0106783:	d3 e7                	shl    %cl,%edi
f0106785:	89 d1                	mov    %edx,%ecx
f0106787:	d3 e8                	shr    %cl,%eax
f0106789:	89 e9                	mov    %ebp,%ecx
f010678b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010678f:	d3 e3                	shl    %cl,%ebx
f0106791:	89 c7                	mov    %eax,%edi
f0106793:	89 d1                	mov    %edx,%ecx
f0106795:	89 f0                	mov    %esi,%eax
f0106797:	d3 e8                	shr    %cl,%eax
f0106799:	89 e9                	mov    %ebp,%ecx
f010679b:	89 fa                	mov    %edi,%edx
f010679d:	d3 e6                	shl    %cl,%esi
f010679f:	09 d8                	or     %ebx,%eax
f01067a1:	f7 74 24 08          	divl   0x8(%esp)
f01067a5:	89 d1                	mov    %edx,%ecx
f01067a7:	89 f3                	mov    %esi,%ebx
f01067a9:	f7 64 24 0c          	mull   0xc(%esp)
f01067ad:	89 c6                	mov    %eax,%esi
f01067af:	89 d7                	mov    %edx,%edi
f01067b1:	39 d1                	cmp    %edx,%ecx
f01067b3:	72 06                	jb     f01067bb <__umoddi3+0x10b>
f01067b5:	75 10                	jne    f01067c7 <__umoddi3+0x117>
f01067b7:	39 c3                	cmp    %eax,%ebx
f01067b9:	73 0c                	jae    f01067c7 <__umoddi3+0x117>
f01067bb:	2b 44 24 0c          	sub    0xc(%esp),%eax
f01067bf:	1b 54 24 08          	sbb    0x8(%esp),%edx
f01067c3:	89 d7                	mov    %edx,%edi
f01067c5:	89 c6                	mov    %eax,%esi
f01067c7:	89 ca                	mov    %ecx,%edx
f01067c9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01067ce:	29 f3                	sub    %esi,%ebx
f01067d0:	19 fa                	sbb    %edi,%edx
f01067d2:	89 d0                	mov    %edx,%eax
f01067d4:	d3 e0                	shl    %cl,%eax
f01067d6:	89 e9                	mov    %ebp,%ecx
f01067d8:	d3 eb                	shr    %cl,%ebx
f01067da:	d3 ea                	shr    %cl,%edx
f01067dc:	09 d8                	or     %ebx,%eax
f01067de:	83 c4 1c             	add    $0x1c,%esp
f01067e1:	5b                   	pop    %ebx
f01067e2:	5e                   	pop    %esi
f01067e3:	5f                   	pop    %edi
f01067e4:	5d                   	pop    %ebp
f01067e5:	c3                   	ret    
f01067e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01067ed:	8d 76 00             	lea    0x0(%esi),%esi
f01067f0:	29 fe                	sub    %edi,%esi
f01067f2:	19 c3                	sbb    %eax,%ebx
f01067f4:	89 f2                	mov    %esi,%edx
f01067f6:	89 d9                	mov    %ebx,%ecx
f01067f8:	e9 1d ff ff ff       	jmp    f010671a <__umoddi3+0x6a>
