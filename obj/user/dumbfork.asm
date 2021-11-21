
obj/user/dumbfork:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 b0 01 00 00       	call   8001e1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	56                   	push   %esi
  80003b:	53                   	push   %ebx
  80003c:	8b 75 08             	mov    0x8(%ebp),%esi
  80003f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	6a 07                	push   $0x7
  800047:	53                   	push   %ebx
  800048:	56                   	push   %esi
  800049:	e8 29 0d 00 00       	call   800d77 <sys_page_alloc>
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	85 c0                	test   %eax,%eax
  800053:	78 4a                	js     80009f <duppage+0x6c>
		panic("sys_page_alloc: %e", r);
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)	
  800055:	83 ec 0c             	sub    $0xc,%esp
  800058:	6a 07                	push   $0x7
  80005a:	68 00 00 40 00       	push   $0x400000
  80005f:	6a 00                	push   $0x0
  800061:	53                   	push   %ebx
  800062:	56                   	push   %esi
  800063:	e8 56 0d 00 00       	call   800dbe <sys_page_map>
  800068:	83 c4 20             	add    $0x20,%esp
  80006b:	85 c0                	test   %eax,%eax
  80006d:	78 42                	js     8000b1 <duppage+0x7e>
		panic("sys_page_map: %e", r);				
	memmove(UTEMP, addr, PGSIZE);					
  80006f:	83 ec 04             	sub    $0x4,%esp
  800072:	68 00 10 00 00       	push   $0x1000
  800077:	53                   	push   %ebx
  800078:	68 00 00 40 00       	push   $0x400000
  80007d:	e8 69 0a 00 00       	call   800aeb <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)		
  800082:	83 c4 08             	add    $0x8,%esp
  800085:	68 00 00 40 00       	push   $0x400000
  80008a:	6a 00                	push   $0x0
  80008c:	e8 73 0d 00 00       	call   800e04 <sys_page_unmap>
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	85 c0                	test   %eax,%eax
  800096:	78 2b                	js     8000c3 <duppage+0x90>
		panic("sys_page_unmap: %e", r);
}
  800098:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009b:	5b                   	pop    %ebx
  80009c:	5e                   	pop    %esi
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  80009f:	50                   	push   %eax
  8000a0:	68 c0 11 80 00       	push   $0x8011c0
  8000a5:	6a 20                	push   $0x20
  8000a7:	68 d3 11 80 00       	push   $0x8011d3
  8000ac:	e8 93 01 00 00       	call   800244 <_panic>
		panic("sys_page_map: %e", r);				
  8000b1:	50                   	push   %eax
  8000b2:	68 e3 11 80 00       	push   $0x8011e3
  8000b7:	6a 22                	push   $0x22
  8000b9:	68 d3 11 80 00       	push   $0x8011d3
  8000be:	e8 81 01 00 00       	call   800244 <_panic>
		panic("sys_page_unmap: %e", r);
  8000c3:	50                   	push   %eax
  8000c4:	68 f4 11 80 00       	push   $0x8011f4
  8000c9:	6a 25                	push   $0x25
  8000cb:	68 d3 11 80 00       	push   $0x8011d3
  8000d0:	e8 6f 01 00 00       	call   800244 <_panic>

008000d5 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d5:	f3 0f 1e fb          	endbr32 
  8000d9:	55                   	push   %ebp
  8000da:	89 e5                	mov    %esp,%ebp
  8000dc:	56                   	push   %esi
  8000dd:	53                   	push   %ebx
  8000de:	83 ec 10             	sub    $0x10,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8000e1:	b8 07 00 00 00       	mov    $0x7,%eax
  8000e6:	cd 30                	int    $0x30
  8000e8:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8000ea:	85 c0                	test   %eax,%eax
  8000ec:	78 0d                	js     8000fb <dumbfork+0x26>
  8000ee:	89 c6                	mov    %eax,%esi
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  8000f0:	74 1b                	je     80010d <dumbfork+0x38>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  8000f2:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  8000f9:	eb 42                	jmp    80013d <dumbfork+0x68>
		panic("sys_exofork: %e", envid);
  8000fb:	50                   	push   %eax
  8000fc:	68 07 12 80 00       	push   $0x801207
  800101:	6a 37                	push   $0x37
  800103:	68 d3 11 80 00       	push   $0x8011d3
  800108:	e8 37 01 00 00       	call   800244 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
  80010d:	e8 1f 0c 00 00       	call   800d31 <sys_getenvid>
  800112:	25 ff 03 00 00       	and    $0x3ff,%eax
  800117:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  80011d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800122:	a3 60 40 80 00       	mov    %eax,0x804060
		return 0;
  800127:	eb 43                	jmp    80016c <dumbfork+0x97>
		duppage(envid, addr);
  800129:	83 ec 08             	sub    $0x8,%esp
  80012c:	52                   	push   %edx
  80012d:	56                   	push   %esi
  80012e:	e8 00 ff ff ff       	call   800033 <duppage>
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800133:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  80013a:	83 c4 10             	add    $0x10,%esp
  80013d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800140:	81 fa 64 40 80 00    	cmp    $0x804064,%edx
  800146:	72 e1                	jb     800129 <dumbfork+0x54>

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800148:	83 ec 08             	sub    $0x8,%esp
  80014b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80014e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800153:	50                   	push   %eax
  800154:	53                   	push   %ebx
  800155:	e8 d9 fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80015a:	83 c4 08             	add    $0x8,%esp
  80015d:	6a 02                	push   $0x2
  80015f:	53                   	push   %ebx
  800160:	e8 e5 0c 00 00       	call   800e4a <sys_env_set_status>
  800165:	83 c4 10             	add    $0x10,%esp
  800168:	85 c0                	test   %eax,%eax
  80016a:	78 09                	js     800175 <dumbfork+0xa0>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  80016c:	89 d8                	mov    %ebx,%eax
  80016e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800171:	5b                   	pop    %ebx
  800172:	5e                   	pop    %esi
  800173:	5d                   	pop    %ebp
  800174:	c3                   	ret    
		panic("sys_env_set_status: %e", r);
  800175:	50                   	push   %eax
  800176:	68 17 12 80 00       	push   $0x801217
  80017b:	6a 4c                	push   $0x4c
  80017d:	68 d3 11 80 00       	push   $0x8011d3
  800182:	e8 bd 00 00 00       	call   800244 <_panic>

00800187 <umain>:
{
  800187:	f3 0f 1e fb          	endbr32 
  80018b:	55                   	push   %ebp
  80018c:	89 e5                	mov    %esp,%ebp
  80018e:	57                   	push   %edi
  80018f:	56                   	push   %esi
  800190:	53                   	push   %ebx
  800191:	83 ec 0c             	sub    $0xc,%esp
	who = dumbfork();
  800194:	e8 3c ff ff ff       	call   8000d5 <dumbfork>
  800199:	89 c6                	mov    %eax,%esi
  80019b:	85 c0                	test   %eax,%eax
  80019d:	bf 2e 12 80 00       	mov    $0x80122e,%edi
  8001a2:	b8 35 12 80 00       	mov    $0x801235,%eax
  8001a7:	0f 44 f8             	cmove  %eax,%edi
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001af:	eb 1f                	jmp    8001d0 <umain+0x49>
  8001b1:	83 fb 13             	cmp    $0x13,%ebx
  8001b4:	7f 23                	jg     8001d9 <umain+0x52>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001b6:	83 ec 04             	sub    $0x4,%esp
  8001b9:	57                   	push   %edi
  8001ba:	53                   	push   %ebx
  8001bb:	68 3b 12 80 00       	push   $0x80123b
  8001c0:	e8 66 01 00 00       	call   80032b <cprintf>
		sys_yield();
  8001c5:	e8 8a 0b 00 00       	call   800d54 <sys_yield>
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001ca:	83 c3 01             	add    $0x1,%ebx
  8001cd:	83 c4 10             	add    $0x10,%esp
  8001d0:	85 f6                	test   %esi,%esi
  8001d2:	74 dd                	je     8001b1 <umain+0x2a>
  8001d4:	83 fb 09             	cmp    $0x9,%ebx
  8001d7:	7e dd                	jle    8001b6 <umain+0x2f>
}
  8001d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001dc:	5b                   	pop    %ebx
  8001dd:	5e                   	pop    %esi
  8001de:	5f                   	pop    %edi
  8001df:	5d                   	pop    %ebp
  8001e0:	c3                   	ret    

008001e1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e1:	f3 0f 1e fb          	endbr32 
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
  8001ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001ed:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8001f0:	e8 3c 0b 00 00       	call   800d31 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  8001f5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001fa:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  800200:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800205:	a3 60 40 80 00       	mov    %eax,0x804060

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80020a:	85 db                	test   %ebx,%ebx
  80020c:	7e 07                	jle    800215 <libmain+0x34>
		binaryname = argv[0];
  80020e:	8b 06                	mov    (%esi),%eax
  800210:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800215:	83 ec 08             	sub    $0x8,%esp
  800218:	56                   	push   %esi
  800219:	53                   	push   %ebx
  80021a:	e8 68 ff ff ff       	call   800187 <umain>

	// exit gracefully
	exit();
  80021f:	e8 0a 00 00 00       	call   80022e <exit>
}
  800224:	83 c4 10             	add    $0x10,%esp
  800227:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80022a:	5b                   	pop    %ebx
  80022b:	5e                   	pop    %esi
  80022c:	5d                   	pop    %ebp
  80022d:	c3                   	ret    

0080022e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80022e:	f3 0f 1e fb          	endbr32 
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800238:	6a 00                	push   $0x0
  80023a:	e8 ad 0a 00 00       	call   800cec <sys_env_destroy>
}
  80023f:	83 c4 10             	add    $0x10,%esp
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800244:	f3 0f 1e fb          	endbr32 
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	56                   	push   %esi
  80024c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80024d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800250:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800256:	e8 d6 0a 00 00       	call   800d31 <sys_getenvid>
  80025b:	83 ec 0c             	sub    $0xc,%esp
  80025e:	ff 75 0c             	pushl  0xc(%ebp)
  800261:	ff 75 08             	pushl  0x8(%ebp)
  800264:	56                   	push   %esi
  800265:	50                   	push   %eax
  800266:	68 58 12 80 00       	push   $0x801258
  80026b:	e8 bb 00 00 00       	call   80032b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800270:	83 c4 18             	add    $0x18,%esp
  800273:	53                   	push   %ebx
  800274:	ff 75 10             	pushl  0x10(%ebp)
  800277:	e8 5a 00 00 00       	call   8002d6 <vcprintf>
	cprintf("\n");
  80027c:	c7 04 24 4b 12 80 00 	movl   $0x80124b,(%esp)
  800283:	e8 a3 00 00 00       	call   80032b <cprintf>
  800288:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80028b:	cc                   	int3   
  80028c:	eb fd                	jmp    80028b <_panic+0x47>

0080028e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80028e:	f3 0f 1e fb          	endbr32 
  800292:	55                   	push   %ebp
  800293:	89 e5                	mov    %esp,%ebp
  800295:	53                   	push   %ebx
  800296:	83 ec 04             	sub    $0x4,%esp
  800299:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80029c:	8b 13                	mov    (%ebx),%edx
  80029e:	8d 42 01             	lea    0x1(%edx),%eax
  8002a1:	89 03                	mov    %eax,(%ebx)
  8002a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002aa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002af:	74 09                	je     8002ba <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8002b1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002b8:	c9                   	leave  
  8002b9:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8002ba:	83 ec 08             	sub    $0x8,%esp
  8002bd:	68 ff 00 00 00       	push   $0xff
  8002c2:	8d 43 08             	lea    0x8(%ebx),%eax
  8002c5:	50                   	push   %eax
  8002c6:	e8 dc 09 00 00       	call   800ca7 <sys_cputs>
		b->idx = 0;
  8002cb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002d1:	83 c4 10             	add    $0x10,%esp
  8002d4:	eb db                	jmp    8002b1 <putch+0x23>

008002d6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002d6:	f3 0f 1e fb          	endbr32 
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002e3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ea:	00 00 00 
	b.cnt = 0;
  8002ed:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002f4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002f7:	ff 75 0c             	pushl  0xc(%ebp)
  8002fa:	ff 75 08             	pushl  0x8(%ebp)
  8002fd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800303:	50                   	push   %eax
  800304:	68 8e 02 80 00       	push   $0x80028e
  800309:	e8 20 01 00 00       	call   80042e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80030e:	83 c4 08             	add    $0x8,%esp
  800311:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800317:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80031d:	50                   	push   %eax
  80031e:	e8 84 09 00 00       	call   800ca7 <sys_cputs>

	return b.cnt;
}
  800323:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800329:	c9                   	leave  
  80032a:	c3                   	ret    

0080032b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80032b:	f3 0f 1e fb          	endbr32 
  80032f:	55                   	push   %ebp
  800330:	89 e5                	mov    %esp,%ebp
  800332:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800335:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800338:	50                   	push   %eax
  800339:	ff 75 08             	pushl  0x8(%ebp)
  80033c:	e8 95 ff ff ff       	call   8002d6 <vcprintf>
	va_end(ap);

	return cnt;
}
  800341:	c9                   	leave  
  800342:	c3                   	ret    

00800343 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800343:	55                   	push   %ebp
  800344:	89 e5                	mov    %esp,%ebp
  800346:	57                   	push   %edi
  800347:	56                   	push   %esi
  800348:	53                   	push   %ebx
  800349:	83 ec 1c             	sub    $0x1c,%esp
  80034c:	89 c7                	mov    %eax,%edi
  80034e:	89 d6                	mov    %edx,%esi
  800350:	8b 45 08             	mov    0x8(%ebp),%eax
  800353:	8b 55 0c             	mov    0xc(%ebp),%edx
  800356:	89 d1                	mov    %edx,%ecx
  800358:	89 c2                	mov    %eax,%edx
  80035a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80035d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800360:	8b 45 10             	mov    0x10(%ebp),%eax
  800363:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800366:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800369:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800370:	39 c2                	cmp    %eax,%edx
  800372:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800375:	72 3e                	jb     8003b5 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800377:	83 ec 0c             	sub    $0xc,%esp
  80037a:	ff 75 18             	pushl  0x18(%ebp)
  80037d:	83 eb 01             	sub    $0x1,%ebx
  800380:	53                   	push   %ebx
  800381:	50                   	push   %eax
  800382:	83 ec 08             	sub    $0x8,%esp
  800385:	ff 75 e4             	pushl  -0x1c(%ebp)
  800388:	ff 75 e0             	pushl  -0x20(%ebp)
  80038b:	ff 75 dc             	pushl  -0x24(%ebp)
  80038e:	ff 75 d8             	pushl  -0x28(%ebp)
  800391:	e8 ba 0b 00 00       	call   800f50 <__udivdi3>
  800396:	83 c4 18             	add    $0x18,%esp
  800399:	52                   	push   %edx
  80039a:	50                   	push   %eax
  80039b:	89 f2                	mov    %esi,%edx
  80039d:	89 f8                	mov    %edi,%eax
  80039f:	e8 9f ff ff ff       	call   800343 <printnum>
  8003a4:	83 c4 20             	add    $0x20,%esp
  8003a7:	eb 13                	jmp    8003bc <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003a9:	83 ec 08             	sub    $0x8,%esp
  8003ac:	56                   	push   %esi
  8003ad:	ff 75 18             	pushl  0x18(%ebp)
  8003b0:	ff d7                	call   *%edi
  8003b2:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8003b5:	83 eb 01             	sub    $0x1,%ebx
  8003b8:	85 db                	test   %ebx,%ebx
  8003ba:	7f ed                	jg     8003a9 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003bc:	83 ec 08             	sub    $0x8,%esp
  8003bf:	56                   	push   %esi
  8003c0:	83 ec 04             	sub    $0x4,%esp
  8003c3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003c6:	ff 75 e0             	pushl  -0x20(%ebp)
  8003c9:	ff 75 dc             	pushl  -0x24(%ebp)
  8003cc:	ff 75 d8             	pushl  -0x28(%ebp)
  8003cf:	e8 8c 0c 00 00       	call   801060 <__umoddi3>
  8003d4:	83 c4 14             	add    $0x14,%esp
  8003d7:	0f be 80 7b 12 80 00 	movsbl 0x80127b(%eax),%eax
  8003de:	50                   	push   %eax
  8003df:	ff d7                	call   *%edi
}
  8003e1:	83 c4 10             	add    $0x10,%esp
  8003e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003e7:	5b                   	pop    %ebx
  8003e8:	5e                   	pop    %esi
  8003e9:	5f                   	pop    %edi
  8003ea:	5d                   	pop    %ebp
  8003eb:	c3                   	ret    

008003ec <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ec:	f3 0f 1e fb          	endbr32 
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003fa:	8b 10                	mov    (%eax),%edx
  8003fc:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ff:	73 0a                	jae    80040b <sprintputch+0x1f>
		*b->buf++ = ch;
  800401:	8d 4a 01             	lea    0x1(%edx),%ecx
  800404:	89 08                	mov    %ecx,(%eax)
  800406:	8b 45 08             	mov    0x8(%ebp),%eax
  800409:	88 02                	mov    %al,(%edx)
}
  80040b:	5d                   	pop    %ebp
  80040c:	c3                   	ret    

0080040d <printfmt>:
{
  80040d:	f3 0f 1e fb          	endbr32 
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800417:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80041a:	50                   	push   %eax
  80041b:	ff 75 10             	pushl  0x10(%ebp)
  80041e:	ff 75 0c             	pushl  0xc(%ebp)
  800421:	ff 75 08             	pushl  0x8(%ebp)
  800424:	e8 05 00 00 00       	call   80042e <vprintfmt>
}
  800429:	83 c4 10             	add    $0x10,%esp
  80042c:	c9                   	leave  
  80042d:	c3                   	ret    

0080042e <vprintfmt>:
{
  80042e:	f3 0f 1e fb          	endbr32 
  800432:	55                   	push   %ebp
  800433:	89 e5                	mov    %esp,%ebp
  800435:	57                   	push   %edi
  800436:	56                   	push   %esi
  800437:	53                   	push   %ebx
  800438:	83 ec 3c             	sub    $0x3c,%esp
  80043b:	8b 75 08             	mov    0x8(%ebp),%esi
  80043e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800441:	8b 7d 10             	mov    0x10(%ebp),%edi
  800444:	e9 8e 03 00 00       	jmp    8007d7 <vprintfmt+0x3a9>
		padc = ' ';
  800449:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80044d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800454:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80045b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800462:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800467:	8d 47 01             	lea    0x1(%edi),%eax
  80046a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80046d:	0f b6 17             	movzbl (%edi),%edx
  800470:	8d 42 dd             	lea    -0x23(%edx),%eax
  800473:	3c 55                	cmp    $0x55,%al
  800475:	0f 87 df 03 00 00    	ja     80085a <vprintfmt+0x42c>
  80047b:	0f b6 c0             	movzbl %al,%eax
  80047e:	3e ff 24 85 40 13 80 	notrack jmp *0x801340(,%eax,4)
  800485:	00 
  800486:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800489:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80048d:	eb d8                	jmp    800467 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800492:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800496:	eb cf                	jmp    800467 <vprintfmt+0x39>
  800498:	0f b6 d2             	movzbl %dl,%edx
  80049b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80049e:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8004a6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004a9:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004ad:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004b0:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004b3:	83 f9 09             	cmp    $0x9,%ecx
  8004b6:	77 55                	ja     80050d <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8004b8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004bb:	eb e9                	jmp    8004a6 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8004bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c0:	8b 00                	mov    (%eax),%eax
  8004c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c8:	8d 40 04             	lea    0x4(%eax),%eax
  8004cb:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004d1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d5:	79 90                	jns    800467 <vprintfmt+0x39>
				width = precision, precision = -1;
  8004d7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004da:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004dd:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8004e4:	eb 81                	jmp    800467 <vprintfmt+0x39>
  8004e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004e9:	85 c0                	test   %eax,%eax
  8004eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f0:	0f 49 d0             	cmovns %eax,%edx
  8004f3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004f9:	e9 69 ff ff ff       	jmp    800467 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8004fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800501:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800508:	e9 5a ff ff ff       	jmp    800467 <vprintfmt+0x39>
  80050d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800510:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800513:	eb bc                	jmp    8004d1 <vprintfmt+0xa3>
			lflag++;
  800515:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800518:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80051b:	e9 47 ff ff ff       	jmp    800467 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8d 78 04             	lea    0x4(%eax),%edi
  800526:	83 ec 08             	sub    $0x8,%esp
  800529:	53                   	push   %ebx
  80052a:	ff 30                	pushl  (%eax)
  80052c:	ff d6                	call   *%esi
			break;
  80052e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800531:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800534:	e9 9b 02 00 00       	jmp    8007d4 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800539:	8b 45 14             	mov    0x14(%ebp),%eax
  80053c:	8d 78 04             	lea    0x4(%eax),%edi
  80053f:	8b 00                	mov    (%eax),%eax
  800541:	99                   	cltd   
  800542:	31 d0                	xor    %edx,%eax
  800544:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800546:	83 f8 08             	cmp    $0x8,%eax
  800549:	7f 23                	jg     80056e <vprintfmt+0x140>
  80054b:	8b 14 85 a0 14 80 00 	mov    0x8014a0(,%eax,4),%edx
  800552:	85 d2                	test   %edx,%edx
  800554:	74 18                	je     80056e <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800556:	52                   	push   %edx
  800557:	68 9c 12 80 00       	push   $0x80129c
  80055c:	53                   	push   %ebx
  80055d:	56                   	push   %esi
  80055e:	e8 aa fe ff ff       	call   80040d <printfmt>
  800563:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800566:	89 7d 14             	mov    %edi,0x14(%ebp)
  800569:	e9 66 02 00 00       	jmp    8007d4 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  80056e:	50                   	push   %eax
  80056f:	68 93 12 80 00       	push   $0x801293
  800574:	53                   	push   %ebx
  800575:	56                   	push   %esi
  800576:	e8 92 fe ff ff       	call   80040d <printfmt>
  80057b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80057e:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800581:	e9 4e 02 00 00       	jmp    8007d4 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	83 c0 04             	add    $0x4,%eax
  80058c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80058f:	8b 45 14             	mov    0x14(%ebp),%eax
  800592:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800594:	85 d2                	test   %edx,%edx
  800596:	b8 8c 12 80 00       	mov    $0x80128c,%eax
  80059b:	0f 45 c2             	cmovne %edx,%eax
  80059e:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8005a1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005a5:	7e 06                	jle    8005ad <vprintfmt+0x17f>
  8005a7:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8005ab:	75 0d                	jne    8005ba <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ad:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005b0:	89 c7                	mov    %eax,%edi
  8005b2:	03 45 e0             	add    -0x20(%ebp),%eax
  8005b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b8:	eb 55                	jmp    80060f <vprintfmt+0x1e1>
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	ff 75 d8             	pushl  -0x28(%ebp)
  8005c0:	ff 75 cc             	pushl  -0x34(%ebp)
  8005c3:	e8 46 03 00 00       	call   80090e <strnlen>
  8005c8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005cb:	29 c2                	sub    %eax,%edx
  8005cd:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8005d0:	83 c4 10             	add    $0x10,%esp
  8005d3:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8005d5:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8005d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005dc:	85 ff                	test   %edi,%edi
  8005de:	7e 11                	jle    8005f1 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8005e0:	83 ec 08             	sub    $0x8,%esp
  8005e3:	53                   	push   %ebx
  8005e4:	ff 75 e0             	pushl  -0x20(%ebp)
  8005e7:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e9:	83 ef 01             	sub    $0x1,%edi
  8005ec:	83 c4 10             	add    $0x10,%esp
  8005ef:	eb eb                	jmp    8005dc <vprintfmt+0x1ae>
  8005f1:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005f4:	85 d2                	test   %edx,%edx
  8005f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8005fb:	0f 49 c2             	cmovns %edx,%eax
  8005fe:	29 c2                	sub    %eax,%edx
  800600:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800603:	eb a8                	jmp    8005ad <vprintfmt+0x17f>
					putch(ch, putdat);
  800605:	83 ec 08             	sub    $0x8,%esp
  800608:	53                   	push   %ebx
  800609:	52                   	push   %edx
  80060a:	ff d6                	call   *%esi
  80060c:	83 c4 10             	add    $0x10,%esp
  80060f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800612:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800614:	83 c7 01             	add    $0x1,%edi
  800617:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80061b:	0f be d0             	movsbl %al,%edx
  80061e:	85 d2                	test   %edx,%edx
  800620:	74 4b                	je     80066d <vprintfmt+0x23f>
  800622:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800626:	78 06                	js     80062e <vprintfmt+0x200>
  800628:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80062c:	78 1e                	js     80064c <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80062e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800632:	74 d1                	je     800605 <vprintfmt+0x1d7>
  800634:	0f be c0             	movsbl %al,%eax
  800637:	83 e8 20             	sub    $0x20,%eax
  80063a:	83 f8 5e             	cmp    $0x5e,%eax
  80063d:	76 c6                	jbe    800605 <vprintfmt+0x1d7>
					putch('?', putdat);
  80063f:	83 ec 08             	sub    $0x8,%esp
  800642:	53                   	push   %ebx
  800643:	6a 3f                	push   $0x3f
  800645:	ff d6                	call   *%esi
  800647:	83 c4 10             	add    $0x10,%esp
  80064a:	eb c3                	jmp    80060f <vprintfmt+0x1e1>
  80064c:	89 cf                	mov    %ecx,%edi
  80064e:	eb 0e                	jmp    80065e <vprintfmt+0x230>
				putch(' ', putdat);
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	53                   	push   %ebx
  800654:	6a 20                	push   $0x20
  800656:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800658:	83 ef 01             	sub    $0x1,%edi
  80065b:	83 c4 10             	add    $0x10,%esp
  80065e:	85 ff                	test   %edi,%edi
  800660:	7f ee                	jg     800650 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800662:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800665:	89 45 14             	mov    %eax,0x14(%ebp)
  800668:	e9 67 01 00 00       	jmp    8007d4 <vprintfmt+0x3a6>
  80066d:	89 cf                	mov    %ecx,%edi
  80066f:	eb ed                	jmp    80065e <vprintfmt+0x230>
	if (lflag >= 2)
  800671:	83 f9 01             	cmp    $0x1,%ecx
  800674:	7f 1b                	jg     800691 <vprintfmt+0x263>
	else if (lflag)
  800676:	85 c9                	test   %ecx,%ecx
  800678:	74 63                	je     8006dd <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8b 00                	mov    (%eax),%eax
  80067f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800682:	99                   	cltd   
  800683:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800686:	8b 45 14             	mov    0x14(%ebp),%eax
  800689:	8d 40 04             	lea    0x4(%eax),%eax
  80068c:	89 45 14             	mov    %eax,0x14(%ebp)
  80068f:	eb 17                	jmp    8006a8 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800691:	8b 45 14             	mov    0x14(%ebp),%eax
  800694:	8b 50 04             	mov    0x4(%eax),%edx
  800697:	8b 00                	mov    (%eax),%eax
  800699:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80069c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80069f:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a2:	8d 40 08             	lea    0x8(%eax),%eax
  8006a5:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8006a8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006ab:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8006ae:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8006b3:	85 c9                	test   %ecx,%ecx
  8006b5:	0f 89 ff 00 00 00    	jns    8007ba <vprintfmt+0x38c>
				putch('-', putdat);
  8006bb:	83 ec 08             	sub    $0x8,%esp
  8006be:	53                   	push   %ebx
  8006bf:	6a 2d                	push   $0x2d
  8006c1:	ff d6                	call   *%esi
				num = -(long long) num;
  8006c3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006c6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006c9:	f7 da                	neg    %edx
  8006cb:	83 d1 00             	adc    $0x0,%ecx
  8006ce:	f7 d9                	neg    %ecx
  8006d0:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006d3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d8:	e9 dd 00 00 00       	jmp    8007ba <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8b 00                	mov    (%eax),%eax
  8006e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e5:	99                   	cltd   
  8006e6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ec:	8d 40 04             	lea    0x4(%eax),%eax
  8006ef:	89 45 14             	mov    %eax,0x14(%ebp)
  8006f2:	eb b4                	jmp    8006a8 <vprintfmt+0x27a>
	if (lflag >= 2)
  8006f4:	83 f9 01             	cmp    $0x1,%ecx
  8006f7:	7f 1e                	jg     800717 <vprintfmt+0x2e9>
	else if (lflag)
  8006f9:	85 c9                	test   %ecx,%ecx
  8006fb:	74 32                	je     80072f <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8006fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800700:	8b 10                	mov    (%eax),%edx
  800702:	b9 00 00 00 00       	mov    $0x0,%ecx
  800707:	8d 40 04             	lea    0x4(%eax),%eax
  80070a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80070d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800712:	e9 a3 00 00 00       	jmp    8007ba <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800717:	8b 45 14             	mov    0x14(%ebp),%eax
  80071a:	8b 10                	mov    (%eax),%edx
  80071c:	8b 48 04             	mov    0x4(%eax),%ecx
  80071f:	8d 40 08             	lea    0x8(%eax),%eax
  800722:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800725:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80072a:	e9 8b 00 00 00       	jmp    8007ba <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80072f:	8b 45 14             	mov    0x14(%ebp),%eax
  800732:	8b 10                	mov    (%eax),%edx
  800734:	b9 00 00 00 00       	mov    $0x0,%ecx
  800739:	8d 40 04             	lea    0x4(%eax),%eax
  80073c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80073f:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800744:	eb 74                	jmp    8007ba <vprintfmt+0x38c>
	if (lflag >= 2)
  800746:	83 f9 01             	cmp    $0x1,%ecx
  800749:	7f 1b                	jg     800766 <vprintfmt+0x338>
	else if (lflag)
  80074b:	85 c9                	test   %ecx,%ecx
  80074d:	74 2c                	je     80077b <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  80074f:	8b 45 14             	mov    0x14(%ebp),%eax
  800752:	8b 10                	mov    (%eax),%edx
  800754:	b9 00 00 00 00       	mov    $0x0,%ecx
  800759:	8d 40 04             	lea    0x4(%eax),%eax
  80075c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80075f:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800764:	eb 54                	jmp    8007ba <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800766:	8b 45 14             	mov    0x14(%ebp),%eax
  800769:	8b 10                	mov    (%eax),%edx
  80076b:	8b 48 04             	mov    0x4(%eax),%ecx
  80076e:	8d 40 08             	lea    0x8(%eax),%eax
  800771:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800774:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800779:	eb 3f                	jmp    8007ba <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80077b:	8b 45 14             	mov    0x14(%ebp),%eax
  80077e:	8b 10                	mov    (%eax),%edx
  800780:	b9 00 00 00 00       	mov    $0x0,%ecx
  800785:	8d 40 04             	lea    0x4(%eax),%eax
  800788:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80078b:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800790:	eb 28                	jmp    8007ba <vprintfmt+0x38c>
			putch('0', putdat);
  800792:	83 ec 08             	sub    $0x8,%esp
  800795:	53                   	push   %ebx
  800796:	6a 30                	push   $0x30
  800798:	ff d6                	call   *%esi
			putch('x', putdat);
  80079a:	83 c4 08             	add    $0x8,%esp
  80079d:	53                   	push   %ebx
  80079e:	6a 78                	push   $0x78
  8007a0:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a5:	8b 10                	mov    (%eax),%edx
  8007a7:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007ac:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007af:	8d 40 04             	lea    0x4(%eax),%eax
  8007b2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007b5:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8007ba:	83 ec 0c             	sub    $0xc,%esp
  8007bd:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8007c1:	57                   	push   %edi
  8007c2:	ff 75 e0             	pushl  -0x20(%ebp)
  8007c5:	50                   	push   %eax
  8007c6:	51                   	push   %ecx
  8007c7:	52                   	push   %edx
  8007c8:	89 da                	mov    %ebx,%edx
  8007ca:	89 f0                	mov    %esi,%eax
  8007cc:	e8 72 fb ff ff       	call   800343 <printnum>
			break;
  8007d1:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8007d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {	
  8007d7:	83 c7 01             	add    $0x1,%edi
  8007da:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007de:	83 f8 25             	cmp    $0x25,%eax
  8007e1:	0f 84 62 fc ff ff    	je     800449 <vprintfmt+0x1b>
			if (ch == '\0')										
  8007e7:	85 c0                	test   %eax,%eax
  8007e9:	0f 84 8b 00 00 00    	je     80087a <vprintfmt+0x44c>
			putch(ch, putdat);
  8007ef:	83 ec 08             	sub    $0x8,%esp
  8007f2:	53                   	push   %ebx
  8007f3:	50                   	push   %eax
  8007f4:	ff d6                	call   *%esi
  8007f6:	83 c4 10             	add    $0x10,%esp
  8007f9:	eb dc                	jmp    8007d7 <vprintfmt+0x3a9>
	if (lflag >= 2)
  8007fb:	83 f9 01             	cmp    $0x1,%ecx
  8007fe:	7f 1b                	jg     80081b <vprintfmt+0x3ed>
	else if (lflag)
  800800:	85 c9                	test   %ecx,%ecx
  800802:	74 2c                	je     800830 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800804:	8b 45 14             	mov    0x14(%ebp),%eax
  800807:	8b 10                	mov    (%eax),%edx
  800809:	b9 00 00 00 00       	mov    $0x0,%ecx
  80080e:	8d 40 04             	lea    0x4(%eax),%eax
  800811:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800814:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800819:	eb 9f                	jmp    8007ba <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80081b:	8b 45 14             	mov    0x14(%ebp),%eax
  80081e:	8b 10                	mov    (%eax),%edx
  800820:	8b 48 04             	mov    0x4(%eax),%ecx
  800823:	8d 40 08             	lea    0x8(%eax),%eax
  800826:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800829:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80082e:	eb 8a                	jmp    8007ba <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800830:	8b 45 14             	mov    0x14(%ebp),%eax
  800833:	8b 10                	mov    (%eax),%edx
  800835:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083a:	8d 40 04             	lea    0x4(%eax),%eax
  80083d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800840:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800845:	e9 70 ff ff ff       	jmp    8007ba <vprintfmt+0x38c>
			putch(ch, putdat);
  80084a:	83 ec 08             	sub    $0x8,%esp
  80084d:	53                   	push   %ebx
  80084e:	6a 25                	push   $0x25
  800850:	ff d6                	call   *%esi
			break;
  800852:	83 c4 10             	add    $0x10,%esp
  800855:	e9 7a ff ff ff       	jmp    8007d4 <vprintfmt+0x3a6>
			putch('%', putdat);
  80085a:	83 ec 08             	sub    $0x8,%esp
  80085d:	53                   	push   %ebx
  80085e:	6a 25                	push   $0x25
  800860:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800862:	83 c4 10             	add    $0x10,%esp
  800865:	89 f8                	mov    %edi,%eax
  800867:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80086b:	74 05                	je     800872 <vprintfmt+0x444>
  80086d:	83 e8 01             	sub    $0x1,%eax
  800870:	eb f5                	jmp    800867 <vprintfmt+0x439>
  800872:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800875:	e9 5a ff ff ff       	jmp    8007d4 <vprintfmt+0x3a6>
}
  80087a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80087d:	5b                   	pop    %ebx
  80087e:	5e                   	pop    %esi
  80087f:	5f                   	pop    %edi
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800882:	f3 0f 1e fb          	endbr32 
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	83 ec 18             	sub    $0x18,%esp
  80088c:	8b 45 08             	mov    0x8(%ebp),%eax
  80088f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800892:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800895:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800899:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80089c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008a3:	85 c0                	test   %eax,%eax
  8008a5:	74 26                	je     8008cd <vsnprintf+0x4b>
  8008a7:	85 d2                	test   %edx,%edx
  8008a9:	7e 22                	jle    8008cd <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008ab:	ff 75 14             	pushl  0x14(%ebp)
  8008ae:	ff 75 10             	pushl  0x10(%ebp)
  8008b1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008b4:	50                   	push   %eax
  8008b5:	68 ec 03 80 00       	push   $0x8003ec
  8008ba:	e8 6f fb ff ff       	call   80042e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008c2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c8:	83 c4 10             	add    $0x10,%esp
}
  8008cb:	c9                   	leave  
  8008cc:	c3                   	ret    
		return -E_INVAL;
  8008cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008d2:	eb f7                	jmp    8008cb <vsnprintf+0x49>

008008d4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d4:	f3 0f 1e fb          	endbr32 
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008de:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008e1:	50                   	push   %eax
  8008e2:	ff 75 10             	pushl  0x10(%ebp)
  8008e5:	ff 75 0c             	pushl  0xc(%ebp)
  8008e8:	ff 75 08             	pushl  0x8(%ebp)
  8008eb:	e8 92 ff ff ff       	call   800882 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008f0:	c9                   	leave  
  8008f1:	c3                   	ret    

008008f2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008f2:	f3 0f 1e fb          	endbr32 
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800901:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800905:	74 05                	je     80090c <strlen+0x1a>
		n++;
  800907:	83 c0 01             	add    $0x1,%eax
  80090a:	eb f5                	jmp    800901 <strlen+0xf>
	return n;
}
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80090e:	f3 0f 1e fb          	endbr32 
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800918:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80091b:	b8 00 00 00 00       	mov    $0x0,%eax
  800920:	39 d0                	cmp    %edx,%eax
  800922:	74 0d                	je     800931 <strnlen+0x23>
  800924:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800928:	74 05                	je     80092f <strnlen+0x21>
		n++;
  80092a:	83 c0 01             	add    $0x1,%eax
  80092d:	eb f1                	jmp    800920 <strnlen+0x12>
  80092f:	89 c2                	mov    %eax,%edx
	return n;
}
  800931:	89 d0                	mov    %edx,%eax
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800935:	f3 0f 1e fb          	endbr32 
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	53                   	push   %ebx
  80093d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800940:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800943:	b8 00 00 00 00       	mov    $0x0,%eax
  800948:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80094c:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80094f:	83 c0 01             	add    $0x1,%eax
  800952:	84 d2                	test   %dl,%dl
  800954:	75 f2                	jne    800948 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800956:	89 c8                	mov    %ecx,%eax
  800958:	5b                   	pop    %ebx
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80095b:	f3 0f 1e fb          	endbr32 
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	53                   	push   %ebx
  800963:	83 ec 10             	sub    $0x10,%esp
  800966:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800969:	53                   	push   %ebx
  80096a:	e8 83 ff ff ff       	call   8008f2 <strlen>
  80096f:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800972:	ff 75 0c             	pushl  0xc(%ebp)
  800975:	01 d8                	add    %ebx,%eax
  800977:	50                   	push   %eax
  800978:	e8 b8 ff ff ff       	call   800935 <strcpy>
	return dst;
}
  80097d:	89 d8                	mov    %ebx,%eax
  80097f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800982:	c9                   	leave  
  800983:	c3                   	ret    

00800984 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800984:	f3 0f 1e fb          	endbr32 
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	56                   	push   %esi
  80098c:	53                   	push   %ebx
  80098d:	8b 75 08             	mov    0x8(%ebp),%esi
  800990:	8b 55 0c             	mov    0xc(%ebp),%edx
  800993:	89 f3                	mov    %esi,%ebx
  800995:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800998:	89 f0                	mov    %esi,%eax
  80099a:	39 d8                	cmp    %ebx,%eax
  80099c:	74 11                	je     8009af <strncpy+0x2b>
		*dst++ = *src;
  80099e:	83 c0 01             	add    $0x1,%eax
  8009a1:	0f b6 0a             	movzbl (%edx),%ecx
  8009a4:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009a7:	80 f9 01             	cmp    $0x1,%cl
  8009aa:	83 da ff             	sbb    $0xffffffff,%edx
  8009ad:	eb eb                	jmp    80099a <strncpy+0x16>
	}
	return ret;
}
  8009af:	89 f0                	mov    %esi,%eax
  8009b1:	5b                   	pop    %ebx
  8009b2:	5e                   	pop    %esi
  8009b3:	5d                   	pop    %ebp
  8009b4:	c3                   	ret    

008009b5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009b5:	f3 0f 1e fb          	endbr32 
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	56                   	push   %esi
  8009bd:	53                   	push   %ebx
  8009be:	8b 75 08             	mov    0x8(%ebp),%esi
  8009c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009c4:	8b 55 10             	mov    0x10(%ebp),%edx
  8009c7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c9:	85 d2                	test   %edx,%edx
  8009cb:	74 21                	je     8009ee <strlcpy+0x39>
  8009cd:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009d1:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8009d3:	39 c2                	cmp    %eax,%edx
  8009d5:	74 14                	je     8009eb <strlcpy+0x36>
  8009d7:	0f b6 19             	movzbl (%ecx),%ebx
  8009da:	84 db                	test   %bl,%bl
  8009dc:	74 0b                	je     8009e9 <strlcpy+0x34>
			*dst++ = *src++;
  8009de:	83 c1 01             	add    $0x1,%ecx
  8009e1:	83 c2 01             	add    $0x1,%edx
  8009e4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009e7:	eb ea                	jmp    8009d3 <strlcpy+0x1e>
  8009e9:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8009eb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009ee:	29 f0                	sub    %esi,%eax
}
  8009f0:	5b                   	pop    %ebx
  8009f1:	5e                   	pop    %esi
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009f4:	f3 0f 1e fb          	endbr32 
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a01:	0f b6 01             	movzbl (%ecx),%eax
  800a04:	84 c0                	test   %al,%al
  800a06:	74 0c                	je     800a14 <strcmp+0x20>
  800a08:	3a 02                	cmp    (%edx),%al
  800a0a:	75 08                	jne    800a14 <strcmp+0x20>
		p++, q++;
  800a0c:	83 c1 01             	add    $0x1,%ecx
  800a0f:	83 c2 01             	add    $0x1,%edx
  800a12:	eb ed                	jmp    800a01 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a14:	0f b6 c0             	movzbl %al,%eax
  800a17:	0f b6 12             	movzbl (%edx),%edx
  800a1a:	29 d0                	sub    %edx,%eax
}
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a1e:	f3 0f 1e fb          	endbr32 
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	53                   	push   %ebx
  800a26:	8b 45 08             	mov    0x8(%ebp),%eax
  800a29:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2c:	89 c3                	mov    %eax,%ebx
  800a2e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a31:	eb 06                	jmp    800a39 <strncmp+0x1b>
		n--, p++, q++;
  800a33:	83 c0 01             	add    $0x1,%eax
  800a36:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a39:	39 d8                	cmp    %ebx,%eax
  800a3b:	74 16                	je     800a53 <strncmp+0x35>
  800a3d:	0f b6 08             	movzbl (%eax),%ecx
  800a40:	84 c9                	test   %cl,%cl
  800a42:	74 04                	je     800a48 <strncmp+0x2a>
  800a44:	3a 0a                	cmp    (%edx),%cl
  800a46:	74 eb                	je     800a33 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a48:	0f b6 00             	movzbl (%eax),%eax
  800a4b:	0f b6 12             	movzbl (%edx),%edx
  800a4e:	29 d0                	sub    %edx,%eax
}
  800a50:	5b                   	pop    %ebx
  800a51:	5d                   	pop    %ebp
  800a52:	c3                   	ret    
		return 0;
  800a53:	b8 00 00 00 00       	mov    $0x0,%eax
  800a58:	eb f6                	jmp    800a50 <strncmp+0x32>

00800a5a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a5a:	f3 0f 1e fb          	endbr32 
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	8b 45 08             	mov    0x8(%ebp),%eax
  800a64:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a68:	0f b6 10             	movzbl (%eax),%edx
  800a6b:	84 d2                	test   %dl,%dl
  800a6d:	74 09                	je     800a78 <strchr+0x1e>
		if (*s == c)
  800a6f:	38 ca                	cmp    %cl,%dl
  800a71:	74 0a                	je     800a7d <strchr+0x23>
	for (; *s; s++)
  800a73:	83 c0 01             	add    $0x1,%eax
  800a76:	eb f0                	jmp    800a68 <strchr+0xe>
			return (char *) s;
	return 0;
  800a78:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a7d:	5d                   	pop    %ebp
  800a7e:	c3                   	ret    

00800a7f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a7f:	f3 0f 1e fb          	endbr32 
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	8b 45 08             	mov    0x8(%ebp),%eax
  800a89:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a8d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a90:	38 ca                	cmp    %cl,%dl
  800a92:	74 09                	je     800a9d <strfind+0x1e>
  800a94:	84 d2                	test   %dl,%dl
  800a96:	74 05                	je     800a9d <strfind+0x1e>
	for (; *s; s++)
  800a98:	83 c0 01             	add    $0x1,%eax
  800a9b:	eb f0                	jmp    800a8d <strfind+0xe>
			break;
	return (char *) s;
}
  800a9d:	5d                   	pop    %ebp
  800a9e:	c3                   	ret    

00800a9f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a9f:	f3 0f 1e fb          	endbr32 
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	57                   	push   %edi
  800aa7:	56                   	push   %esi
  800aa8:	53                   	push   %ebx
  800aa9:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aac:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aaf:	85 c9                	test   %ecx,%ecx
  800ab1:	74 31                	je     800ae4 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ab3:	89 f8                	mov    %edi,%eax
  800ab5:	09 c8                	or     %ecx,%eax
  800ab7:	a8 03                	test   $0x3,%al
  800ab9:	75 23                	jne    800ade <memset+0x3f>
		c &= 0xFF;
  800abb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800abf:	89 d3                	mov    %edx,%ebx
  800ac1:	c1 e3 08             	shl    $0x8,%ebx
  800ac4:	89 d0                	mov    %edx,%eax
  800ac6:	c1 e0 18             	shl    $0x18,%eax
  800ac9:	89 d6                	mov    %edx,%esi
  800acb:	c1 e6 10             	shl    $0x10,%esi
  800ace:	09 f0                	or     %esi,%eax
  800ad0:	09 c2                	or     %eax,%edx
  800ad2:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ad4:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ad7:	89 d0                	mov    %edx,%eax
  800ad9:	fc                   	cld    
  800ada:	f3 ab                	rep stos %eax,%es:(%edi)
  800adc:	eb 06                	jmp    800ae4 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ade:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae1:	fc                   	cld    
  800ae2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ae4:	89 f8                	mov    %edi,%eax
  800ae6:	5b                   	pop    %ebx
  800ae7:	5e                   	pop    %esi
  800ae8:	5f                   	pop    %edi
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aeb:	f3 0f 1e fb          	endbr32 
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	57                   	push   %edi
  800af3:	56                   	push   %esi
  800af4:	8b 45 08             	mov    0x8(%ebp),%eax
  800af7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800afa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800afd:	39 c6                	cmp    %eax,%esi
  800aff:	73 32                	jae    800b33 <memmove+0x48>
  800b01:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b04:	39 c2                	cmp    %eax,%edx
  800b06:	76 2b                	jbe    800b33 <memmove+0x48>
		s += n;
		d += n;
  800b08:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b0b:	89 fe                	mov    %edi,%esi
  800b0d:	09 ce                	or     %ecx,%esi
  800b0f:	09 d6                	or     %edx,%esi
  800b11:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b17:	75 0e                	jne    800b27 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b19:	83 ef 04             	sub    $0x4,%edi
  800b1c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b1f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b22:	fd                   	std    
  800b23:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b25:	eb 09                	jmp    800b30 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b27:	83 ef 01             	sub    $0x1,%edi
  800b2a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b2d:	fd                   	std    
  800b2e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b30:	fc                   	cld    
  800b31:	eb 1a                	jmp    800b4d <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b33:	89 c2                	mov    %eax,%edx
  800b35:	09 ca                	or     %ecx,%edx
  800b37:	09 f2                	or     %esi,%edx
  800b39:	f6 c2 03             	test   $0x3,%dl
  800b3c:	75 0a                	jne    800b48 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b3e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b41:	89 c7                	mov    %eax,%edi
  800b43:	fc                   	cld    
  800b44:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b46:	eb 05                	jmp    800b4d <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800b48:	89 c7                	mov    %eax,%edi
  800b4a:	fc                   	cld    
  800b4b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b4d:	5e                   	pop    %esi
  800b4e:	5f                   	pop    %edi
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b51:	f3 0f 1e fb          	endbr32 
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b5b:	ff 75 10             	pushl  0x10(%ebp)
  800b5e:	ff 75 0c             	pushl  0xc(%ebp)
  800b61:	ff 75 08             	pushl  0x8(%ebp)
  800b64:	e8 82 ff ff ff       	call   800aeb <memmove>
}
  800b69:	c9                   	leave  
  800b6a:	c3                   	ret    

00800b6b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b6b:	f3 0f 1e fb          	endbr32 
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
  800b74:	8b 45 08             	mov    0x8(%ebp),%eax
  800b77:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b7a:	89 c6                	mov    %eax,%esi
  800b7c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b7f:	39 f0                	cmp    %esi,%eax
  800b81:	74 1c                	je     800b9f <memcmp+0x34>
		if (*s1 != *s2)
  800b83:	0f b6 08             	movzbl (%eax),%ecx
  800b86:	0f b6 1a             	movzbl (%edx),%ebx
  800b89:	38 d9                	cmp    %bl,%cl
  800b8b:	75 08                	jne    800b95 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b8d:	83 c0 01             	add    $0x1,%eax
  800b90:	83 c2 01             	add    $0x1,%edx
  800b93:	eb ea                	jmp    800b7f <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800b95:	0f b6 c1             	movzbl %cl,%eax
  800b98:	0f b6 db             	movzbl %bl,%ebx
  800b9b:	29 d8                	sub    %ebx,%eax
  800b9d:	eb 05                	jmp    800ba4 <memcmp+0x39>
	}

	return 0;
  800b9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ba4:	5b                   	pop    %ebx
  800ba5:	5e                   	pop    %esi
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    

00800ba8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ba8:	f3 0f 1e fb          	endbr32 
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bb5:	89 c2                	mov    %eax,%edx
  800bb7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bba:	39 d0                	cmp    %edx,%eax
  800bbc:	73 09                	jae    800bc7 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bbe:	38 08                	cmp    %cl,(%eax)
  800bc0:	74 05                	je     800bc7 <memfind+0x1f>
	for (; s < ends; s++)
  800bc2:	83 c0 01             	add    $0x1,%eax
  800bc5:	eb f3                	jmp    800bba <memfind+0x12>
			break;
	return (void *) s;
}
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bc9:	f3 0f 1e fb          	endbr32 
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
  800bd3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bd9:	eb 03                	jmp    800bde <strtol+0x15>
		s++;
  800bdb:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800bde:	0f b6 01             	movzbl (%ecx),%eax
  800be1:	3c 20                	cmp    $0x20,%al
  800be3:	74 f6                	je     800bdb <strtol+0x12>
  800be5:	3c 09                	cmp    $0x9,%al
  800be7:	74 f2                	je     800bdb <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800be9:	3c 2b                	cmp    $0x2b,%al
  800beb:	74 2a                	je     800c17 <strtol+0x4e>
	int neg = 0;
  800bed:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bf2:	3c 2d                	cmp    $0x2d,%al
  800bf4:	74 2b                	je     800c21 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bf6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bfc:	75 0f                	jne    800c0d <strtol+0x44>
  800bfe:	80 39 30             	cmpb   $0x30,(%ecx)
  800c01:	74 28                	je     800c2b <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c03:	85 db                	test   %ebx,%ebx
  800c05:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c0a:	0f 44 d8             	cmove  %eax,%ebx
  800c0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c12:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c15:	eb 46                	jmp    800c5d <strtol+0x94>
		s++;
  800c17:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800c1a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c1f:	eb d5                	jmp    800bf6 <strtol+0x2d>
		s++, neg = 1;
  800c21:	83 c1 01             	add    $0x1,%ecx
  800c24:	bf 01 00 00 00       	mov    $0x1,%edi
  800c29:	eb cb                	jmp    800bf6 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c2b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c2f:	74 0e                	je     800c3f <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c31:	85 db                	test   %ebx,%ebx
  800c33:	75 d8                	jne    800c0d <strtol+0x44>
		s++, base = 8;
  800c35:	83 c1 01             	add    $0x1,%ecx
  800c38:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c3d:	eb ce                	jmp    800c0d <strtol+0x44>
		s += 2, base = 16;
  800c3f:	83 c1 02             	add    $0x2,%ecx
  800c42:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c47:	eb c4                	jmp    800c0d <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800c49:	0f be d2             	movsbl %dl,%edx
  800c4c:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c4f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c52:	7d 3a                	jge    800c8e <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c54:	83 c1 01             	add    $0x1,%ecx
  800c57:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c5b:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c5d:	0f b6 11             	movzbl (%ecx),%edx
  800c60:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c63:	89 f3                	mov    %esi,%ebx
  800c65:	80 fb 09             	cmp    $0x9,%bl
  800c68:	76 df                	jbe    800c49 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800c6a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c6d:	89 f3                	mov    %esi,%ebx
  800c6f:	80 fb 19             	cmp    $0x19,%bl
  800c72:	77 08                	ja     800c7c <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c74:	0f be d2             	movsbl %dl,%edx
  800c77:	83 ea 57             	sub    $0x57,%edx
  800c7a:	eb d3                	jmp    800c4f <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800c7c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c7f:	89 f3                	mov    %esi,%ebx
  800c81:	80 fb 19             	cmp    $0x19,%bl
  800c84:	77 08                	ja     800c8e <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c86:	0f be d2             	movsbl %dl,%edx
  800c89:	83 ea 37             	sub    $0x37,%edx
  800c8c:	eb c1                	jmp    800c4f <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c8e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c92:	74 05                	je     800c99 <strtol+0xd0>
		*endptr = (char *) s;
  800c94:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c97:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c99:	89 c2                	mov    %eax,%edx
  800c9b:	f7 da                	neg    %edx
  800c9d:	85 ff                	test   %edi,%edi
  800c9f:	0f 45 c2             	cmovne %edx,%eax
}
  800ca2:	5b                   	pop    %ebx
  800ca3:	5e                   	pop    %esi
  800ca4:	5f                   	pop    %edi
  800ca5:	5d                   	pop    %ebp
  800ca6:	c3                   	ret    

00800ca7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ca7:	f3 0f 1e fb          	endbr32 
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	57                   	push   %edi
  800caf:	56                   	push   %esi
  800cb0:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800cb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbc:	89 c3                	mov    %eax,%ebx
  800cbe:	89 c7                	mov    %eax,%edi
  800cc0:	89 c6                	mov    %eax,%esi
  800cc2:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <sys_cgetc>:

int
sys_cgetc(void)
{
  800cc9:	f3 0f 1e fb          	endbr32 
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	57                   	push   %edi
  800cd1:	56                   	push   %esi
  800cd2:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800cd3:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd8:	b8 01 00 00 00       	mov    $0x1,%eax
  800cdd:	89 d1                	mov    %edx,%ecx
  800cdf:	89 d3                	mov    %edx,%ebx
  800ce1:	89 d7                	mov    %edx,%edi
  800ce3:	89 d6                	mov    %edx,%esi
  800ce5:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cec:	f3 0f 1e fb          	endbr32 
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	57                   	push   %edi
  800cf4:	56                   	push   %esi
  800cf5:	53                   	push   %ebx
  800cf6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800cf9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cfe:	8b 55 08             	mov    0x8(%ebp),%edx
  800d01:	b8 03 00 00 00       	mov    $0x3,%eax
  800d06:	89 cb                	mov    %ecx,%ebx
  800d08:	89 cf                	mov    %ecx,%edi
  800d0a:	89 ce                	mov    %ecx,%esi
  800d0c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d0e:	85 c0                	test   %eax,%eax
  800d10:	7f 08                	jg     800d1a <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d15:	5b                   	pop    %ebx
  800d16:	5e                   	pop    %esi
  800d17:	5f                   	pop    %edi
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1a:	83 ec 0c             	sub    $0xc,%esp
  800d1d:	50                   	push   %eax
  800d1e:	6a 03                	push   $0x3
  800d20:	68 c4 14 80 00       	push   $0x8014c4
  800d25:	6a 23                	push   $0x23
  800d27:	68 e1 14 80 00       	push   $0x8014e1
  800d2c:	e8 13 f5 ff ff       	call   800244 <_panic>

00800d31 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d31:	f3 0f 1e fb          	endbr32 
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	57                   	push   %edi
  800d39:	56                   	push   %esi
  800d3a:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d40:	b8 02 00 00 00       	mov    $0x2,%eax
  800d45:	89 d1                	mov    %edx,%ecx
  800d47:	89 d3                	mov    %edx,%ebx
  800d49:	89 d7                	mov    %edx,%edi
  800d4b:	89 d6                	mov    %edx,%esi
  800d4d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d4f:	5b                   	pop    %ebx
  800d50:	5e                   	pop    %esi
  800d51:	5f                   	pop    %edi
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <sys_yield>:

void
sys_yield(void)
{
  800d54:	f3 0f 1e fb          	endbr32 
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
  800d5b:	57                   	push   %edi
  800d5c:	56                   	push   %esi
  800d5d:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d5e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d63:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d68:	89 d1                	mov    %edx,%ecx
  800d6a:	89 d3                	mov    %edx,%ebx
  800d6c:	89 d7                	mov    %edx,%edi
  800d6e:	89 d6                	mov    %edx,%esi
  800d70:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d72:	5b                   	pop    %ebx
  800d73:	5e                   	pop    %esi
  800d74:	5f                   	pop    %edi
  800d75:	5d                   	pop    %ebp
  800d76:	c3                   	ret    

00800d77 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d77:	f3 0f 1e fb          	endbr32 
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	57                   	push   %edi
  800d7f:	56                   	push   %esi
  800d80:	53                   	push   %ebx
  800d81:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d84:	be 00 00 00 00       	mov    $0x0,%esi
  800d89:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8f:	b8 04 00 00 00       	mov    $0x4,%eax
  800d94:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d97:	89 f7                	mov    %esi,%edi
  800d99:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	7f 08                	jg     800da7 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da2:	5b                   	pop    %ebx
  800da3:	5e                   	pop    %esi
  800da4:	5f                   	pop    %edi
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800da7:	83 ec 0c             	sub    $0xc,%esp
  800daa:	50                   	push   %eax
  800dab:	6a 04                	push   $0x4
  800dad:	68 c4 14 80 00       	push   $0x8014c4
  800db2:	6a 23                	push   $0x23
  800db4:	68 e1 14 80 00       	push   $0x8014e1
  800db9:	e8 86 f4 ff ff       	call   800244 <_panic>

00800dbe <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dbe:	f3 0f 1e fb          	endbr32 
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	57                   	push   %edi
  800dc6:	56                   	push   %esi
  800dc7:	53                   	push   %ebx
  800dc8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800dcb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd1:	b8 05 00 00 00       	mov    $0x5,%eax
  800dd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ddc:	8b 75 18             	mov    0x18(%ebp),%esi
  800ddf:	cd 30                	int    $0x30
	if(check && ret > 0)
  800de1:	85 c0                	test   %eax,%eax
  800de3:	7f 08                	jg     800ded <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800de5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de8:	5b                   	pop    %ebx
  800de9:	5e                   	pop    %esi
  800dea:	5f                   	pop    %edi
  800deb:	5d                   	pop    %ebp
  800dec:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ded:	83 ec 0c             	sub    $0xc,%esp
  800df0:	50                   	push   %eax
  800df1:	6a 05                	push   $0x5
  800df3:	68 c4 14 80 00       	push   $0x8014c4
  800df8:	6a 23                	push   $0x23
  800dfa:	68 e1 14 80 00       	push   $0x8014e1
  800dff:	e8 40 f4 ff ff       	call   800244 <_panic>

00800e04 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e04:	f3 0f 1e fb          	endbr32 
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
  800e0b:	57                   	push   %edi
  800e0c:	56                   	push   %esi
  800e0d:	53                   	push   %ebx
  800e0e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800e11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e16:	8b 55 08             	mov    0x8(%ebp),%edx
  800e19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1c:	b8 06 00 00 00       	mov    $0x6,%eax
  800e21:	89 df                	mov    %ebx,%edi
  800e23:	89 de                	mov    %ebx,%esi
  800e25:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e27:	85 c0                	test   %eax,%eax
  800e29:	7f 08                	jg     800e33 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e2e:	5b                   	pop    %ebx
  800e2f:	5e                   	pop    %esi
  800e30:	5f                   	pop    %edi
  800e31:	5d                   	pop    %ebp
  800e32:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e33:	83 ec 0c             	sub    $0xc,%esp
  800e36:	50                   	push   %eax
  800e37:	6a 06                	push   $0x6
  800e39:	68 c4 14 80 00       	push   $0x8014c4
  800e3e:	6a 23                	push   $0x23
  800e40:	68 e1 14 80 00       	push   $0x8014e1
  800e45:	e8 fa f3 ff ff       	call   800244 <_panic>

00800e4a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e4a:	f3 0f 1e fb          	endbr32 
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
  800e54:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800e57:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e62:	b8 08 00 00 00       	mov    $0x8,%eax
  800e67:	89 df                	mov    %ebx,%edi
  800e69:	89 de                	mov    %ebx,%esi
  800e6b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e6d:	85 c0                	test   %eax,%eax
  800e6f:	7f 08                	jg     800e79 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e74:	5b                   	pop    %ebx
  800e75:	5e                   	pop    %esi
  800e76:	5f                   	pop    %edi
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e79:	83 ec 0c             	sub    $0xc,%esp
  800e7c:	50                   	push   %eax
  800e7d:	6a 08                	push   $0x8
  800e7f:	68 c4 14 80 00       	push   $0x8014c4
  800e84:	6a 23                	push   $0x23
  800e86:	68 e1 14 80 00       	push   $0x8014e1
  800e8b:	e8 b4 f3 ff ff       	call   800244 <_panic>

00800e90 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e90:	f3 0f 1e fb          	endbr32 
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	57                   	push   %edi
  800e98:	56                   	push   %esi
  800e99:	53                   	push   %ebx
  800e9a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800e9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea8:	b8 09 00 00 00       	mov    $0x9,%eax
  800ead:	89 df                	mov    %ebx,%edi
  800eaf:	89 de                	mov    %ebx,%esi
  800eb1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eb3:	85 c0                	test   %eax,%eax
  800eb5:	7f 08                	jg     800ebf <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eba:	5b                   	pop    %ebx
  800ebb:	5e                   	pop    %esi
  800ebc:	5f                   	pop    %edi
  800ebd:	5d                   	pop    %ebp
  800ebe:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebf:	83 ec 0c             	sub    $0xc,%esp
  800ec2:	50                   	push   %eax
  800ec3:	6a 09                	push   $0x9
  800ec5:	68 c4 14 80 00       	push   $0x8014c4
  800eca:	6a 23                	push   $0x23
  800ecc:	68 e1 14 80 00       	push   $0x8014e1
  800ed1:	e8 6e f3 ff ff       	call   800244 <_panic>

00800ed6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ed6:	f3 0f 1e fb          	endbr32 
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
  800edd:	57                   	push   %edi
  800ede:	56                   	push   %esi
  800edf:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800ee0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800eeb:	be 00 00 00 00       	mov    $0x0,%esi
  800ef0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ef6:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ef8:	5b                   	pop    %ebx
  800ef9:	5e                   	pop    %esi
  800efa:	5f                   	pop    %edi
  800efb:	5d                   	pop    %ebp
  800efc:	c3                   	ret    

00800efd <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800efd:	f3 0f 1e fb          	endbr32 
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	57                   	push   %edi
  800f05:	56                   	push   %esi
  800f06:	53                   	push   %ebx
  800f07:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800f0a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f12:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f17:	89 cb                	mov    %ecx,%ebx
  800f19:	89 cf                	mov    %ecx,%edi
  800f1b:	89 ce                	mov    %ecx,%esi
  800f1d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f1f:	85 c0                	test   %eax,%eax
  800f21:	7f 08                	jg     800f2b <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f26:	5b                   	pop    %ebx
  800f27:	5e                   	pop    %esi
  800f28:	5f                   	pop    %edi
  800f29:	5d                   	pop    %ebp
  800f2a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2b:	83 ec 0c             	sub    $0xc,%esp
  800f2e:	50                   	push   %eax
  800f2f:	6a 0c                	push   $0xc
  800f31:	68 c4 14 80 00       	push   $0x8014c4
  800f36:	6a 23                	push   $0x23
  800f38:	68 e1 14 80 00       	push   $0x8014e1
  800f3d:	e8 02 f3 ff ff       	call   800244 <_panic>
  800f42:	66 90                	xchg   %ax,%ax
  800f44:	66 90                	xchg   %ax,%ax
  800f46:	66 90                	xchg   %ax,%ax
  800f48:	66 90                	xchg   %ax,%ax
  800f4a:	66 90                	xchg   %ax,%ax
  800f4c:	66 90                	xchg   %ax,%ax
  800f4e:	66 90                	xchg   %ax,%ax

00800f50 <__udivdi3>:
  800f50:	f3 0f 1e fb          	endbr32 
  800f54:	55                   	push   %ebp
  800f55:	57                   	push   %edi
  800f56:	56                   	push   %esi
  800f57:	53                   	push   %ebx
  800f58:	83 ec 1c             	sub    $0x1c,%esp
  800f5b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f5f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800f63:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f67:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800f6b:	85 d2                	test   %edx,%edx
  800f6d:	75 19                	jne    800f88 <__udivdi3+0x38>
  800f6f:	39 f3                	cmp    %esi,%ebx
  800f71:	76 4d                	jbe    800fc0 <__udivdi3+0x70>
  800f73:	31 ff                	xor    %edi,%edi
  800f75:	89 e8                	mov    %ebp,%eax
  800f77:	89 f2                	mov    %esi,%edx
  800f79:	f7 f3                	div    %ebx
  800f7b:	89 fa                	mov    %edi,%edx
  800f7d:	83 c4 1c             	add    $0x1c,%esp
  800f80:	5b                   	pop    %ebx
  800f81:	5e                   	pop    %esi
  800f82:	5f                   	pop    %edi
  800f83:	5d                   	pop    %ebp
  800f84:	c3                   	ret    
  800f85:	8d 76 00             	lea    0x0(%esi),%esi
  800f88:	39 f2                	cmp    %esi,%edx
  800f8a:	76 14                	jbe    800fa0 <__udivdi3+0x50>
  800f8c:	31 ff                	xor    %edi,%edi
  800f8e:	31 c0                	xor    %eax,%eax
  800f90:	89 fa                	mov    %edi,%edx
  800f92:	83 c4 1c             	add    $0x1c,%esp
  800f95:	5b                   	pop    %ebx
  800f96:	5e                   	pop    %esi
  800f97:	5f                   	pop    %edi
  800f98:	5d                   	pop    %ebp
  800f99:	c3                   	ret    
  800f9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fa0:	0f bd fa             	bsr    %edx,%edi
  800fa3:	83 f7 1f             	xor    $0x1f,%edi
  800fa6:	75 48                	jne    800ff0 <__udivdi3+0xa0>
  800fa8:	39 f2                	cmp    %esi,%edx
  800faa:	72 06                	jb     800fb2 <__udivdi3+0x62>
  800fac:	31 c0                	xor    %eax,%eax
  800fae:	39 eb                	cmp    %ebp,%ebx
  800fb0:	77 de                	ja     800f90 <__udivdi3+0x40>
  800fb2:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb7:	eb d7                	jmp    800f90 <__udivdi3+0x40>
  800fb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fc0:	89 d9                	mov    %ebx,%ecx
  800fc2:	85 db                	test   %ebx,%ebx
  800fc4:	75 0b                	jne    800fd1 <__udivdi3+0x81>
  800fc6:	b8 01 00 00 00       	mov    $0x1,%eax
  800fcb:	31 d2                	xor    %edx,%edx
  800fcd:	f7 f3                	div    %ebx
  800fcf:	89 c1                	mov    %eax,%ecx
  800fd1:	31 d2                	xor    %edx,%edx
  800fd3:	89 f0                	mov    %esi,%eax
  800fd5:	f7 f1                	div    %ecx
  800fd7:	89 c6                	mov    %eax,%esi
  800fd9:	89 e8                	mov    %ebp,%eax
  800fdb:	89 f7                	mov    %esi,%edi
  800fdd:	f7 f1                	div    %ecx
  800fdf:	89 fa                	mov    %edi,%edx
  800fe1:	83 c4 1c             	add    $0x1c,%esp
  800fe4:	5b                   	pop    %ebx
  800fe5:	5e                   	pop    %esi
  800fe6:	5f                   	pop    %edi
  800fe7:	5d                   	pop    %ebp
  800fe8:	c3                   	ret    
  800fe9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ff0:	89 f9                	mov    %edi,%ecx
  800ff2:	b8 20 00 00 00       	mov    $0x20,%eax
  800ff7:	29 f8                	sub    %edi,%eax
  800ff9:	d3 e2                	shl    %cl,%edx
  800ffb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800fff:	89 c1                	mov    %eax,%ecx
  801001:	89 da                	mov    %ebx,%edx
  801003:	d3 ea                	shr    %cl,%edx
  801005:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801009:	09 d1                	or     %edx,%ecx
  80100b:	89 f2                	mov    %esi,%edx
  80100d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801011:	89 f9                	mov    %edi,%ecx
  801013:	d3 e3                	shl    %cl,%ebx
  801015:	89 c1                	mov    %eax,%ecx
  801017:	d3 ea                	shr    %cl,%edx
  801019:	89 f9                	mov    %edi,%ecx
  80101b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80101f:	89 eb                	mov    %ebp,%ebx
  801021:	d3 e6                	shl    %cl,%esi
  801023:	89 c1                	mov    %eax,%ecx
  801025:	d3 eb                	shr    %cl,%ebx
  801027:	09 de                	or     %ebx,%esi
  801029:	89 f0                	mov    %esi,%eax
  80102b:	f7 74 24 08          	divl   0x8(%esp)
  80102f:	89 d6                	mov    %edx,%esi
  801031:	89 c3                	mov    %eax,%ebx
  801033:	f7 64 24 0c          	mull   0xc(%esp)
  801037:	39 d6                	cmp    %edx,%esi
  801039:	72 15                	jb     801050 <__udivdi3+0x100>
  80103b:	89 f9                	mov    %edi,%ecx
  80103d:	d3 e5                	shl    %cl,%ebp
  80103f:	39 c5                	cmp    %eax,%ebp
  801041:	73 04                	jae    801047 <__udivdi3+0xf7>
  801043:	39 d6                	cmp    %edx,%esi
  801045:	74 09                	je     801050 <__udivdi3+0x100>
  801047:	89 d8                	mov    %ebx,%eax
  801049:	31 ff                	xor    %edi,%edi
  80104b:	e9 40 ff ff ff       	jmp    800f90 <__udivdi3+0x40>
  801050:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801053:	31 ff                	xor    %edi,%edi
  801055:	e9 36 ff ff ff       	jmp    800f90 <__udivdi3+0x40>
  80105a:	66 90                	xchg   %ax,%ax
  80105c:	66 90                	xchg   %ax,%ax
  80105e:	66 90                	xchg   %ax,%ax

00801060 <__umoddi3>:
  801060:	f3 0f 1e fb          	endbr32 
  801064:	55                   	push   %ebp
  801065:	57                   	push   %edi
  801066:	56                   	push   %esi
  801067:	53                   	push   %ebx
  801068:	83 ec 1c             	sub    $0x1c,%esp
  80106b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80106f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801073:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801077:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80107b:	85 c0                	test   %eax,%eax
  80107d:	75 19                	jne    801098 <__umoddi3+0x38>
  80107f:	39 df                	cmp    %ebx,%edi
  801081:	76 5d                	jbe    8010e0 <__umoddi3+0x80>
  801083:	89 f0                	mov    %esi,%eax
  801085:	89 da                	mov    %ebx,%edx
  801087:	f7 f7                	div    %edi
  801089:	89 d0                	mov    %edx,%eax
  80108b:	31 d2                	xor    %edx,%edx
  80108d:	83 c4 1c             	add    $0x1c,%esp
  801090:	5b                   	pop    %ebx
  801091:	5e                   	pop    %esi
  801092:	5f                   	pop    %edi
  801093:	5d                   	pop    %ebp
  801094:	c3                   	ret    
  801095:	8d 76 00             	lea    0x0(%esi),%esi
  801098:	89 f2                	mov    %esi,%edx
  80109a:	39 d8                	cmp    %ebx,%eax
  80109c:	76 12                	jbe    8010b0 <__umoddi3+0x50>
  80109e:	89 f0                	mov    %esi,%eax
  8010a0:	89 da                	mov    %ebx,%edx
  8010a2:	83 c4 1c             	add    $0x1c,%esp
  8010a5:	5b                   	pop    %ebx
  8010a6:	5e                   	pop    %esi
  8010a7:	5f                   	pop    %edi
  8010a8:	5d                   	pop    %ebp
  8010a9:	c3                   	ret    
  8010aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010b0:	0f bd e8             	bsr    %eax,%ebp
  8010b3:	83 f5 1f             	xor    $0x1f,%ebp
  8010b6:	75 50                	jne    801108 <__umoddi3+0xa8>
  8010b8:	39 d8                	cmp    %ebx,%eax
  8010ba:	0f 82 e0 00 00 00    	jb     8011a0 <__umoddi3+0x140>
  8010c0:	89 d9                	mov    %ebx,%ecx
  8010c2:	39 f7                	cmp    %esi,%edi
  8010c4:	0f 86 d6 00 00 00    	jbe    8011a0 <__umoddi3+0x140>
  8010ca:	89 d0                	mov    %edx,%eax
  8010cc:	89 ca                	mov    %ecx,%edx
  8010ce:	83 c4 1c             	add    $0x1c,%esp
  8010d1:	5b                   	pop    %ebx
  8010d2:	5e                   	pop    %esi
  8010d3:	5f                   	pop    %edi
  8010d4:	5d                   	pop    %ebp
  8010d5:	c3                   	ret    
  8010d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010dd:	8d 76 00             	lea    0x0(%esi),%esi
  8010e0:	89 fd                	mov    %edi,%ebp
  8010e2:	85 ff                	test   %edi,%edi
  8010e4:	75 0b                	jne    8010f1 <__umoddi3+0x91>
  8010e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8010eb:	31 d2                	xor    %edx,%edx
  8010ed:	f7 f7                	div    %edi
  8010ef:	89 c5                	mov    %eax,%ebp
  8010f1:	89 d8                	mov    %ebx,%eax
  8010f3:	31 d2                	xor    %edx,%edx
  8010f5:	f7 f5                	div    %ebp
  8010f7:	89 f0                	mov    %esi,%eax
  8010f9:	f7 f5                	div    %ebp
  8010fb:	89 d0                	mov    %edx,%eax
  8010fd:	31 d2                	xor    %edx,%edx
  8010ff:	eb 8c                	jmp    80108d <__umoddi3+0x2d>
  801101:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801108:	89 e9                	mov    %ebp,%ecx
  80110a:	ba 20 00 00 00       	mov    $0x20,%edx
  80110f:	29 ea                	sub    %ebp,%edx
  801111:	d3 e0                	shl    %cl,%eax
  801113:	89 44 24 08          	mov    %eax,0x8(%esp)
  801117:	89 d1                	mov    %edx,%ecx
  801119:	89 f8                	mov    %edi,%eax
  80111b:	d3 e8                	shr    %cl,%eax
  80111d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801121:	89 54 24 04          	mov    %edx,0x4(%esp)
  801125:	8b 54 24 04          	mov    0x4(%esp),%edx
  801129:	09 c1                	or     %eax,%ecx
  80112b:	89 d8                	mov    %ebx,%eax
  80112d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801131:	89 e9                	mov    %ebp,%ecx
  801133:	d3 e7                	shl    %cl,%edi
  801135:	89 d1                	mov    %edx,%ecx
  801137:	d3 e8                	shr    %cl,%eax
  801139:	89 e9                	mov    %ebp,%ecx
  80113b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80113f:	d3 e3                	shl    %cl,%ebx
  801141:	89 c7                	mov    %eax,%edi
  801143:	89 d1                	mov    %edx,%ecx
  801145:	89 f0                	mov    %esi,%eax
  801147:	d3 e8                	shr    %cl,%eax
  801149:	89 e9                	mov    %ebp,%ecx
  80114b:	89 fa                	mov    %edi,%edx
  80114d:	d3 e6                	shl    %cl,%esi
  80114f:	09 d8                	or     %ebx,%eax
  801151:	f7 74 24 08          	divl   0x8(%esp)
  801155:	89 d1                	mov    %edx,%ecx
  801157:	89 f3                	mov    %esi,%ebx
  801159:	f7 64 24 0c          	mull   0xc(%esp)
  80115d:	89 c6                	mov    %eax,%esi
  80115f:	89 d7                	mov    %edx,%edi
  801161:	39 d1                	cmp    %edx,%ecx
  801163:	72 06                	jb     80116b <__umoddi3+0x10b>
  801165:	75 10                	jne    801177 <__umoddi3+0x117>
  801167:	39 c3                	cmp    %eax,%ebx
  801169:	73 0c                	jae    801177 <__umoddi3+0x117>
  80116b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80116f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801173:	89 d7                	mov    %edx,%edi
  801175:	89 c6                	mov    %eax,%esi
  801177:	89 ca                	mov    %ecx,%edx
  801179:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80117e:	29 f3                	sub    %esi,%ebx
  801180:	19 fa                	sbb    %edi,%edx
  801182:	89 d0                	mov    %edx,%eax
  801184:	d3 e0                	shl    %cl,%eax
  801186:	89 e9                	mov    %ebp,%ecx
  801188:	d3 eb                	shr    %cl,%ebx
  80118a:	d3 ea                	shr    %cl,%edx
  80118c:	09 d8                	or     %ebx,%eax
  80118e:	83 c4 1c             	add    $0x1c,%esp
  801191:	5b                   	pop    %ebx
  801192:	5e                   	pop    %esi
  801193:	5f                   	pop    %edi
  801194:	5d                   	pop    %ebp
  801195:	c3                   	ret    
  801196:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80119d:	8d 76 00             	lea    0x0(%esi),%esi
  8011a0:	29 fe                	sub    %edi,%esi
  8011a2:	19 c3                	sbb    %eax,%ebx
  8011a4:	89 f2                	mov    %esi,%edx
  8011a6:	89 d9                	mov    %ebx,%ecx
  8011a8:	e9 1d ff ff ff       	jmp    8010ca <__umoddi3+0x6a>
