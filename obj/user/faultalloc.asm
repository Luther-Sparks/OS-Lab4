
obj/user/faultalloc:     file format elf32-i386


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
  80002c:	e8 a1 00 00 00       	call   8000d2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	53                   	push   %ebx
  80003b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003e:	8b 45 08             	mov    0x8(%ebp),%eax
  800041:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800043:	53                   	push   %ebx
  800044:	68 20 11 80 00       	push   $0x801120
  800049:	e8 ce 01 00 00       	call   80021c <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004e:	83 c4 0c             	add    $0xc,%esp
  800051:	6a 07                	push   $0x7
  800053:	89 d8                	mov    %ebx,%eax
  800055:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005a:	50                   	push   %eax
  80005b:	6a 00                	push   $0x0
  80005d:	e8 06 0c 00 00       	call   800c68 <sys_page_alloc>
  800062:	83 c4 10             	add    $0x10,%esp
  800065:	85 c0                	test   %eax,%eax
  800067:	78 16                	js     80007f <handler+0x4c>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800069:	53                   	push   %ebx
  80006a:	68 6c 11 80 00       	push   $0x80116c
  80006f:	6a 64                	push   $0x64
  800071:	53                   	push   %ebx
  800072:	e8 4e 07 00 00       	call   8007c5 <snprintf>
}																			
  800077:	83 c4 10             	add    $0x10,%esp
  80007a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007d:	c9                   	leave  
  80007e:	c3                   	ret    
		panic("allocating at %x in page fault handler: %e", addr, r);
  80007f:	83 ec 0c             	sub    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	53                   	push   %ebx
  800084:	68 40 11 80 00       	push   $0x801140
  800089:	6a 0e                	push   $0xe
  80008b:	68 2a 11 80 00       	push   $0x80112a
  800090:	e8 a0 00 00 00       	call   800135 <_panic>

00800095 <umain>:

void
umain(int argc, char **argv)
{
  800095:	f3 0f 1e fb          	endbr32 
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  80009f:	68 33 00 80 00       	push   $0x800033
  8000a4:	e8 8a 0d 00 00       	call   800e33 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a9:	83 c4 08             	add    $0x8,%esp
  8000ac:	68 ef be ad de       	push   $0xdeadbeef
  8000b1:	68 3c 11 80 00       	push   $0x80113c
  8000b6:	e8 61 01 00 00       	call   80021c <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000bb:	83 c4 08             	add    $0x8,%esp
  8000be:	68 fe bf fe ca       	push   $0xcafebffe
  8000c3:	68 3c 11 80 00       	push   $0x80113c
  8000c8:	e8 4f 01 00 00       	call   80021c <cprintf>
}
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	c9                   	leave  
  8000d1:	c3                   	ret    

008000d2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000d2:	f3 0f 1e fb          	endbr32 
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	56                   	push   %esi
  8000da:	53                   	push   %ebx
  8000db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000de:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8000e1:	e8 3c 0b 00 00       	call   800c22 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  8000e6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000eb:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  8000f1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f6:	a3 60 40 80 00       	mov    %eax,0x804060

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000fb:	85 db                	test   %ebx,%ebx
  8000fd:	7e 07                	jle    800106 <libmain+0x34>
		binaryname = argv[0];
  8000ff:	8b 06                	mov    (%esi),%eax
  800101:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800106:	83 ec 08             	sub    $0x8,%esp
  800109:	56                   	push   %esi
  80010a:	53                   	push   %ebx
  80010b:	e8 85 ff ff ff       	call   800095 <umain>

	// exit gracefully
	exit();
  800110:	e8 0a 00 00 00       	call   80011f <exit>
}
  800115:	83 c4 10             	add    $0x10,%esp
  800118:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80011b:	5b                   	pop    %ebx
  80011c:	5e                   	pop    %esi
  80011d:	5d                   	pop    %ebp
  80011e:	c3                   	ret    

0080011f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80011f:	f3 0f 1e fb          	endbr32 
  800123:	55                   	push   %ebp
  800124:	89 e5                	mov    %esp,%ebp
  800126:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800129:	6a 00                	push   $0x0
  80012b:	e8 ad 0a 00 00       	call   800bdd <sys_env_destroy>
}
  800130:	83 c4 10             	add    $0x10,%esp
  800133:	c9                   	leave  
  800134:	c3                   	ret    

00800135 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800135:	f3 0f 1e fb          	endbr32 
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	56                   	push   %esi
  80013d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80013e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800141:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800147:	e8 d6 0a 00 00       	call   800c22 <sys_getenvid>
  80014c:	83 ec 0c             	sub    $0xc,%esp
  80014f:	ff 75 0c             	pushl  0xc(%ebp)
  800152:	ff 75 08             	pushl  0x8(%ebp)
  800155:	56                   	push   %esi
  800156:	50                   	push   %eax
  800157:	68 98 11 80 00       	push   $0x801198
  80015c:	e8 bb 00 00 00       	call   80021c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800161:	83 c4 18             	add    $0x18,%esp
  800164:	53                   	push   %ebx
  800165:	ff 75 10             	pushl  0x10(%ebp)
  800168:	e8 5a 00 00 00       	call   8001c7 <vcprintf>
	cprintf("\n");
  80016d:	c7 04 24 3e 11 80 00 	movl   $0x80113e,(%esp)
  800174:	e8 a3 00 00 00       	call   80021c <cprintf>
  800179:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017c:	cc                   	int3   
  80017d:	eb fd                	jmp    80017c <_panic+0x47>

0080017f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80017f:	f3 0f 1e fb          	endbr32 
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	53                   	push   %ebx
  800187:	83 ec 04             	sub    $0x4,%esp
  80018a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018d:	8b 13                	mov    (%ebx),%edx
  80018f:	8d 42 01             	lea    0x1(%edx),%eax
  800192:	89 03                	mov    %eax,(%ebx)
  800194:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800197:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80019b:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a0:	74 09                	je     8001ab <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001a2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a9:	c9                   	leave  
  8001aa:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001ab:	83 ec 08             	sub    $0x8,%esp
  8001ae:	68 ff 00 00 00       	push   $0xff
  8001b3:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b6:	50                   	push   %eax
  8001b7:	e8 dc 09 00 00       	call   800b98 <sys_cputs>
		b->idx = 0;
  8001bc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c2:	83 c4 10             	add    $0x10,%esp
  8001c5:	eb db                	jmp    8001a2 <putch+0x23>

008001c7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c7:	f3 0f 1e fb          	endbr32 
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001db:	00 00 00 
	b.cnt = 0;
  8001de:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e8:	ff 75 0c             	pushl  0xc(%ebp)
  8001eb:	ff 75 08             	pushl  0x8(%ebp)
  8001ee:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f4:	50                   	push   %eax
  8001f5:	68 7f 01 80 00       	push   $0x80017f
  8001fa:	e8 20 01 00 00       	call   80031f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ff:	83 c4 08             	add    $0x8,%esp
  800202:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800208:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80020e:	50                   	push   %eax
  80020f:	e8 84 09 00 00       	call   800b98 <sys_cputs>

	return b.cnt;
}
  800214:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80021a:	c9                   	leave  
  80021b:	c3                   	ret    

0080021c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80021c:	f3 0f 1e fb          	endbr32 
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800226:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800229:	50                   	push   %eax
  80022a:	ff 75 08             	pushl  0x8(%ebp)
  80022d:	e8 95 ff ff ff       	call   8001c7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800232:	c9                   	leave  
  800233:	c3                   	ret    

00800234 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	57                   	push   %edi
  800238:	56                   	push   %esi
  800239:	53                   	push   %ebx
  80023a:	83 ec 1c             	sub    $0x1c,%esp
  80023d:	89 c7                	mov    %eax,%edi
  80023f:	89 d6                	mov    %edx,%esi
  800241:	8b 45 08             	mov    0x8(%ebp),%eax
  800244:	8b 55 0c             	mov    0xc(%ebp),%edx
  800247:	89 d1                	mov    %edx,%ecx
  800249:	89 c2                	mov    %eax,%edx
  80024b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80024e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800251:	8b 45 10             	mov    0x10(%ebp),%eax
  800254:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800257:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80025a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800261:	39 c2                	cmp    %eax,%edx
  800263:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800266:	72 3e                	jb     8002a6 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800268:	83 ec 0c             	sub    $0xc,%esp
  80026b:	ff 75 18             	pushl  0x18(%ebp)
  80026e:	83 eb 01             	sub    $0x1,%ebx
  800271:	53                   	push   %ebx
  800272:	50                   	push   %eax
  800273:	83 ec 08             	sub    $0x8,%esp
  800276:	ff 75 e4             	pushl  -0x1c(%ebp)
  800279:	ff 75 e0             	pushl  -0x20(%ebp)
  80027c:	ff 75 dc             	pushl  -0x24(%ebp)
  80027f:	ff 75 d8             	pushl  -0x28(%ebp)
  800282:	e8 39 0c 00 00       	call   800ec0 <__udivdi3>
  800287:	83 c4 18             	add    $0x18,%esp
  80028a:	52                   	push   %edx
  80028b:	50                   	push   %eax
  80028c:	89 f2                	mov    %esi,%edx
  80028e:	89 f8                	mov    %edi,%eax
  800290:	e8 9f ff ff ff       	call   800234 <printnum>
  800295:	83 c4 20             	add    $0x20,%esp
  800298:	eb 13                	jmp    8002ad <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029a:	83 ec 08             	sub    $0x8,%esp
  80029d:	56                   	push   %esi
  80029e:	ff 75 18             	pushl  0x18(%ebp)
  8002a1:	ff d7                	call   *%edi
  8002a3:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002a6:	83 eb 01             	sub    $0x1,%ebx
  8002a9:	85 db                	test   %ebx,%ebx
  8002ab:	7f ed                	jg     80029a <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ad:	83 ec 08             	sub    $0x8,%esp
  8002b0:	56                   	push   %esi
  8002b1:	83 ec 04             	sub    $0x4,%esp
  8002b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b7:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ba:	ff 75 dc             	pushl  -0x24(%ebp)
  8002bd:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c0:	e8 0b 0d 00 00       	call   800fd0 <__umoddi3>
  8002c5:	83 c4 14             	add    $0x14,%esp
  8002c8:	0f be 80 bb 11 80 00 	movsbl 0x8011bb(%eax),%eax
  8002cf:	50                   	push   %eax
  8002d0:	ff d7                	call   *%edi
}
  8002d2:	83 c4 10             	add    $0x10,%esp
  8002d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d8:	5b                   	pop    %ebx
  8002d9:	5e                   	pop    %esi
  8002da:	5f                   	pop    %edi
  8002db:	5d                   	pop    %ebp
  8002dc:	c3                   	ret    

008002dd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002dd:	f3 0f 1e fb          	endbr32 
  8002e1:	55                   	push   %ebp
  8002e2:	89 e5                	mov    %esp,%ebp
  8002e4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002eb:	8b 10                	mov    (%eax),%edx
  8002ed:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f0:	73 0a                	jae    8002fc <sprintputch+0x1f>
		*b->buf++ = ch;
  8002f2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002f5:	89 08                	mov    %ecx,(%eax)
  8002f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fa:	88 02                	mov    %al,(%edx)
}
  8002fc:	5d                   	pop    %ebp
  8002fd:	c3                   	ret    

008002fe <printfmt>:
{
  8002fe:	f3 0f 1e fb          	endbr32 
  800302:	55                   	push   %ebp
  800303:	89 e5                	mov    %esp,%ebp
  800305:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800308:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80030b:	50                   	push   %eax
  80030c:	ff 75 10             	pushl  0x10(%ebp)
  80030f:	ff 75 0c             	pushl  0xc(%ebp)
  800312:	ff 75 08             	pushl  0x8(%ebp)
  800315:	e8 05 00 00 00       	call   80031f <vprintfmt>
}
  80031a:	83 c4 10             	add    $0x10,%esp
  80031d:	c9                   	leave  
  80031e:	c3                   	ret    

0080031f <vprintfmt>:
{
  80031f:	f3 0f 1e fb          	endbr32 
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	57                   	push   %edi
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
  800329:	83 ec 3c             	sub    $0x3c,%esp
  80032c:	8b 75 08             	mov    0x8(%ebp),%esi
  80032f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800332:	8b 7d 10             	mov    0x10(%ebp),%edi
  800335:	e9 8e 03 00 00       	jmp    8006c8 <vprintfmt+0x3a9>
		padc = ' ';
  80033a:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80033e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800345:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80034c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800353:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800358:	8d 47 01             	lea    0x1(%edi),%eax
  80035b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80035e:	0f b6 17             	movzbl (%edi),%edx
  800361:	8d 42 dd             	lea    -0x23(%edx),%eax
  800364:	3c 55                	cmp    $0x55,%al
  800366:	0f 87 df 03 00 00    	ja     80074b <vprintfmt+0x42c>
  80036c:	0f b6 c0             	movzbl %al,%eax
  80036f:	3e ff 24 85 80 12 80 	notrack jmp *0x801280(,%eax,4)
  800376:	00 
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80037a:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80037e:	eb d8                	jmp    800358 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800380:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800383:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800387:	eb cf                	jmp    800358 <vprintfmt+0x39>
  800389:	0f b6 d2             	movzbl %dl,%edx
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80038f:	b8 00 00 00 00       	mov    $0x0,%eax
  800394:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800397:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80039a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80039e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003a1:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003a4:	83 f9 09             	cmp    $0x9,%ecx
  8003a7:	77 55                	ja     8003fe <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003a9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003ac:	eb e9                	jmp    800397 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b1:	8b 00                	mov    (%eax),%eax
  8003b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b9:	8d 40 04             	lea    0x4(%eax),%eax
  8003bc:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003c2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c6:	79 90                	jns    800358 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003c8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ce:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003d5:	eb 81                	jmp    800358 <vprintfmt+0x39>
  8003d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003da:	85 c0                	test   %eax,%eax
  8003dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e1:	0f 49 d0             	cmovns %eax,%edx
  8003e4:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003ea:	e9 69 ff ff ff       	jmp    800358 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003f2:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003f9:	e9 5a ff ff ff       	jmp    800358 <vprintfmt+0x39>
  8003fe:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800401:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800404:	eb bc                	jmp    8003c2 <vprintfmt+0xa3>
			lflag++;
  800406:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80040c:	e9 47 ff ff ff       	jmp    800358 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800411:	8b 45 14             	mov    0x14(%ebp),%eax
  800414:	8d 78 04             	lea    0x4(%eax),%edi
  800417:	83 ec 08             	sub    $0x8,%esp
  80041a:	53                   	push   %ebx
  80041b:	ff 30                	pushl  (%eax)
  80041d:	ff d6                	call   *%esi
			break;
  80041f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800422:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800425:	e9 9b 02 00 00       	jmp    8006c5 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  80042a:	8b 45 14             	mov    0x14(%ebp),%eax
  80042d:	8d 78 04             	lea    0x4(%eax),%edi
  800430:	8b 00                	mov    (%eax),%eax
  800432:	99                   	cltd   
  800433:	31 d0                	xor    %edx,%eax
  800435:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800437:	83 f8 08             	cmp    $0x8,%eax
  80043a:	7f 23                	jg     80045f <vprintfmt+0x140>
  80043c:	8b 14 85 e0 13 80 00 	mov    0x8013e0(,%eax,4),%edx
  800443:	85 d2                	test   %edx,%edx
  800445:	74 18                	je     80045f <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800447:	52                   	push   %edx
  800448:	68 dc 11 80 00       	push   $0x8011dc
  80044d:	53                   	push   %ebx
  80044e:	56                   	push   %esi
  80044f:	e8 aa fe ff ff       	call   8002fe <printfmt>
  800454:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800457:	89 7d 14             	mov    %edi,0x14(%ebp)
  80045a:	e9 66 02 00 00       	jmp    8006c5 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  80045f:	50                   	push   %eax
  800460:	68 d3 11 80 00       	push   $0x8011d3
  800465:	53                   	push   %ebx
  800466:	56                   	push   %esi
  800467:	e8 92 fe ff ff       	call   8002fe <printfmt>
  80046c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80046f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800472:	e9 4e 02 00 00       	jmp    8006c5 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800477:	8b 45 14             	mov    0x14(%ebp),%eax
  80047a:	83 c0 04             	add    $0x4,%eax
  80047d:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800480:	8b 45 14             	mov    0x14(%ebp),%eax
  800483:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800485:	85 d2                	test   %edx,%edx
  800487:	b8 cc 11 80 00       	mov    $0x8011cc,%eax
  80048c:	0f 45 c2             	cmovne %edx,%eax
  80048f:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800492:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800496:	7e 06                	jle    80049e <vprintfmt+0x17f>
  800498:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80049c:	75 0d                	jne    8004ab <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80049e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004a1:	89 c7                	mov    %eax,%edi
  8004a3:	03 45 e0             	add    -0x20(%ebp),%eax
  8004a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a9:	eb 55                	jmp    800500 <vprintfmt+0x1e1>
  8004ab:	83 ec 08             	sub    $0x8,%esp
  8004ae:	ff 75 d8             	pushl  -0x28(%ebp)
  8004b1:	ff 75 cc             	pushl  -0x34(%ebp)
  8004b4:	e8 46 03 00 00       	call   8007ff <strnlen>
  8004b9:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004bc:	29 c2                	sub    %eax,%edx
  8004be:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004c1:	83 c4 10             	add    $0x10,%esp
  8004c4:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004c6:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cd:	85 ff                	test   %edi,%edi
  8004cf:	7e 11                	jle    8004e2 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004d1:	83 ec 08             	sub    $0x8,%esp
  8004d4:	53                   	push   %ebx
  8004d5:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d8:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004da:	83 ef 01             	sub    $0x1,%edi
  8004dd:	83 c4 10             	add    $0x10,%esp
  8004e0:	eb eb                	jmp    8004cd <vprintfmt+0x1ae>
  8004e2:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004e5:	85 d2                	test   %edx,%edx
  8004e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ec:	0f 49 c2             	cmovns %edx,%eax
  8004ef:	29 c2                	sub    %eax,%edx
  8004f1:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004f4:	eb a8                	jmp    80049e <vprintfmt+0x17f>
					putch(ch, putdat);
  8004f6:	83 ec 08             	sub    $0x8,%esp
  8004f9:	53                   	push   %ebx
  8004fa:	52                   	push   %edx
  8004fb:	ff d6                	call   *%esi
  8004fd:	83 c4 10             	add    $0x10,%esp
  800500:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800503:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800505:	83 c7 01             	add    $0x1,%edi
  800508:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80050c:	0f be d0             	movsbl %al,%edx
  80050f:	85 d2                	test   %edx,%edx
  800511:	74 4b                	je     80055e <vprintfmt+0x23f>
  800513:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800517:	78 06                	js     80051f <vprintfmt+0x200>
  800519:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80051d:	78 1e                	js     80053d <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80051f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800523:	74 d1                	je     8004f6 <vprintfmt+0x1d7>
  800525:	0f be c0             	movsbl %al,%eax
  800528:	83 e8 20             	sub    $0x20,%eax
  80052b:	83 f8 5e             	cmp    $0x5e,%eax
  80052e:	76 c6                	jbe    8004f6 <vprintfmt+0x1d7>
					putch('?', putdat);
  800530:	83 ec 08             	sub    $0x8,%esp
  800533:	53                   	push   %ebx
  800534:	6a 3f                	push   $0x3f
  800536:	ff d6                	call   *%esi
  800538:	83 c4 10             	add    $0x10,%esp
  80053b:	eb c3                	jmp    800500 <vprintfmt+0x1e1>
  80053d:	89 cf                	mov    %ecx,%edi
  80053f:	eb 0e                	jmp    80054f <vprintfmt+0x230>
				putch(' ', putdat);
  800541:	83 ec 08             	sub    $0x8,%esp
  800544:	53                   	push   %ebx
  800545:	6a 20                	push   $0x20
  800547:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800549:	83 ef 01             	sub    $0x1,%edi
  80054c:	83 c4 10             	add    $0x10,%esp
  80054f:	85 ff                	test   %edi,%edi
  800551:	7f ee                	jg     800541 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800553:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800556:	89 45 14             	mov    %eax,0x14(%ebp)
  800559:	e9 67 01 00 00       	jmp    8006c5 <vprintfmt+0x3a6>
  80055e:	89 cf                	mov    %ecx,%edi
  800560:	eb ed                	jmp    80054f <vprintfmt+0x230>
	if (lflag >= 2)
  800562:	83 f9 01             	cmp    $0x1,%ecx
  800565:	7f 1b                	jg     800582 <vprintfmt+0x263>
	else if (lflag)
  800567:	85 c9                	test   %ecx,%ecx
  800569:	74 63                	je     8005ce <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80056b:	8b 45 14             	mov    0x14(%ebp),%eax
  80056e:	8b 00                	mov    (%eax),%eax
  800570:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800573:	99                   	cltd   
  800574:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8d 40 04             	lea    0x4(%eax),%eax
  80057d:	89 45 14             	mov    %eax,0x14(%ebp)
  800580:	eb 17                	jmp    800599 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	8b 50 04             	mov    0x4(%eax),%edx
  800588:	8b 00                	mov    (%eax),%eax
  80058a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8d 40 08             	lea    0x8(%eax),%eax
  800596:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800599:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80059c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80059f:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005a4:	85 c9                	test   %ecx,%ecx
  8005a6:	0f 89 ff 00 00 00    	jns    8006ab <vprintfmt+0x38c>
				putch('-', putdat);
  8005ac:	83 ec 08             	sub    $0x8,%esp
  8005af:	53                   	push   %ebx
  8005b0:	6a 2d                	push   $0x2d
  8005b2:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005ba:	f7 da                	neg    %edx
  8005bc:	83 d1 00             	adc    $0x0,%ecx
  8005bf:	f7 d9                	neg    %ecx
  8005c1:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005c4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c9:	e9 dd 00 00 00       	jmp    8006ab <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8005ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d1:	8b 00                	mov    (%eax),%eax
  8005d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d6:	99                   	cltd   
  8005d7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005da:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dd:	8d 40 04             	lea    0x4(%eax),%eax
  8005e0:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e3:	eb b4                	jmp    800599 <vprintfmt+0x27a>
	if (lflag >= 2)
  8005e5:	83 f9 01             	cmp    $0x1,%ecx
  8005e8:	7f 1e                	jg     800608 <vprintfmt+0x2e9>
	else if (lflag)
  8005ea:	85 c9                	test   %ecx,%ecx
  8005ec:	74 32                	je     800620 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8b 10                	mov    (%eax),%edx
  8005f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f8:	8d 40 04             	lea    0x4(%eax),%eax
  8005fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005fe:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800603:	e9 a3 00 00 00       	jmp    8006ab <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8b 10                	mov    (%eax),%edx
  80060d:	8b 48 04             	mov    0x4(%eax),%ecx
  800610:	8d 40 08             	lea    0x8(%eax),%eax
  800613:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800616:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80061b:	e9 8b 00 00 00       	jmp    8006ab <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8b 10                	mov    (%eax),%edx
  800625:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062a:	8d 40 04             	lea    0x4(%eax),%eax
  80062d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800630:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800635:	eb 74                	jmp    8006ab <vprintfmt+0x38c>
	if (lflag >= 2)
  800637:	83 f9 01             	cmp    $0x1,%ecx
  80063a:	7f 1b                	jg     800657 <vprintfmt+0x338>
	else if (lflag)
  80063c:	85 c9                	test   %ecx,%ecx
  80063e:	74 2c                	je     80066c <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8b 10                	mov    (%eax),%edx
  800645:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064a:	8d 40 04             	lea    0x4(%eax),%eax
  80064d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800650:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800655:	eb 54                	jmp    8006ab <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8b 10                	mov    (%eax),%edx
  80065c:	8b 48 04             	mov    0x4(%eax),%ecx
  80065f:	8d 40 08             	lea    0x8(%eax),%eax
  800662:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800665:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  80066a:	eb 3f                	jmp    8006ab <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8b 10                	mov    (%eax),%edx
  800671:	b9 00 00 00 00       	mov    $0x0,%ecx
  800676:	8d 40 04             	lea    0x4(%eax),%eax
  800679:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80067c:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800681:	eb 28                	jmp    8006ab <vprintfmt+0x38c>
			putch('0', putdat);
  800683:	83 ec 08             	sub    $0x8,%esp
  800686:	53                   	push   %ebx
  800687:	6a 30                	push   $0x30
  800689:	ff d6                	call   *%esi
			putch('x', putdat);
  80068b:	83 c4 08             	add    $0x8,%esp
  80068e:	53                   	push   %ebx
  80068f:	6a 78                	push   $0x78
  800691:	ff d6                	call   *%esi
			num = (unsigned long long)
  800693:	8b 45 14             	mov    0x14(%ebp),%eax
  800696:	8b 10                	mov    (%eax),%edx
  800698:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80069d:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006a0:	8d 40 04             	lea    0x4(%eax),%eax
  8006a3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a6:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006ab:	83 ec 0c             	sub    $0xc,%esp
  8006ae:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8006b2:	57                   	push   %edi
  8006b3:	ff 75 e0             	pushl  -0x20(%ebp)
  8006b6:	50                   	push   %eax
  8006b7:	51                   	push   %ecx
  8006b8:	52                   	push   %edx
  8006b9:	89 da                	mov    %ebx,%edx
  8006bb:	89 f0                	mov    %esi,%eax
  8006bd:	e8 72 fb ff ff       	call   800234 <printnum>
			break;
  8006c2:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8006c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {	
  8006c8:	83 c7 01             	add    $0x1,%edi
  8006cb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006cf:	83 f8 25             	cmp    $0x25,%eax
  8006d2:	0f 84 62 fc ff ff    	je     80033a <vprintfmt+0x1b>
			if (ch == '\0')										
  8006d8:	85 c0                	test   %eax,%eax
  8006da:	0f 84 8b 00 00 00    	je     80076b <vprintfmt+0x44c>
			putch(ch, putdat);
  8006e0:	83 ec 08             	sub    $0x8,%esp
  8006e3:	53                   	push   %ebx
  8006e4:	50                   	push   %eax
  8006e5:	ff d6                	call   *%esi
  8006e7:	83 c4 10             	add    $0x10,%esp
  8006ea:	eb dc                	jmp    8006c8 <vprintfmt+0x3a9>
	if (lflag >= 2)
  8006ec:	83 f9 01             	cmp    $0x1,%ecx
  8006ef:	7f 1b                	jg     80070c <vprintfmt+0x3ed>
	else if (lflag)
  8006f1:	85 c9                	test   %ecx,%ecx
  8006f3:	74 2c                	je     800721 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  8006f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f8:	8b 10                	mov    (%eax),%edx
  8006fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ff:	8d 40 04             	lea    0x4(%eax),%eax
  800702:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800705:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80070a:	eb 9f                	jmp    8006ab <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80070c:	8b 45 14             	mov    0x14(%ebp),%eax
  80070f:	8b 10                	mov    (%eax),%edx
  800711:	8b 48 04             	mov    0x4(%eax),%ecx
  800714:	8d 40 08             	lea    0x8(%eax),%eax
  800717:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80071a:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80071f:	eb 8a                	jmp    8006ab <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800721:	8b 45 14             	mov    0x14(%ebp),%eax
  800724:	8b 10                	mov    (%eax),%edx
  800726:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072b:	8d 40 04             	lea    0x4(%eax),%eax
  80072e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800731:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800736:	e9 70 ff ff ff       	jmp    8006ab <vprintfmt+0x38c>
			putch(ch, putdat);
  80073b:	83 ec 08             	sub    $0x8,%esp
  80073e:	53                   	push   %ebx
  80073f:	6a 25                	push   $0x25
  800741:	ff d6                	call   *%esi
			break;
  800743:	83 c4 10             	add    $0x10,%esp
  800746:	e9 7a ff ff ff       	jmp    8006c5 <vprintfmt+0x3a6>
			putch('%', putdat);
  80074b:	83 ec 08             	sub    $0x8,%esp
  80074e:	53                   	push   %ebx
  80074f:	6a 25                	push   $0x25
  800751:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800753:	83 c4 10             	add    $0x10,%esp
  800756:	89 f8                	mov    %edi,%eax
  800758:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80075c:	74 05                	je     800763 <vprintfmt+0x444>
  80075e:	83 e8 01             	sub    $0x1,%eax
  800761:	eb f5                	jmp    800758 <vprintfmt+0x439>
  800763:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800766:	e9 5a ff ff ff       	jmp    8006c5 <vprintfmt+0x3a6>
}
  80076b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076e:	5b                   	pop    %ebx
  80076f:	5e                   	pop    %esi
  800770:	5f                   	pop    %edi
  800771:	5d                   	pop    %ebp
  800772:	c3                   	ret    

00800773 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800773:	f3 0f 1e fb          	endbr32 
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	83 ec 18             	sub    $0x18,%esp
  80077d:	8b 45 08             	mov    0x8(%ebp),%eax
  800780:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800783:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800786:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80078a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80078d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800794:	85 c0                	test   %eax,%eax
  800796:	74 26                	je     8007be <vsnprintf+0x4b>
  800798:	85 d2                	test   %edx,%edx
  80079a:	7e 22                	jle    8007be <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80079c:	ff 75 14             	pushl  0x14(%ebp)
  80079f:	ff 75 10             	pushl  0x10(%ebp)
  8007a2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a5:	50                   	push   %eax
  8007a6:	68 dd 02 80 00       	push   $0x8002dd
  8007ab:	e8 6f fb ff ff       	call   80031f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b9:	83 c4 10             	add    $0x10,%esp
}
  8007bc:	c9                   	leave  
  8007bd:	c3                   	ret    
		return -E_INVAL;
  8007be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007c3:	eb f7                	jmp    8007bc <vsnprintf+0x49>

008007c5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c5:	f3 0f 1e fb          	endbr32 
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007cf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007d2:	50                   	push   %eax
  8007d3:	ff 75 10             	pushl  0x10(%ebp)
  8007d6:	ff 75 0c             	pushl  0xc(%ebp)
  8007d9:	ff 75 08             	pushl  0x8(%ebp)
  8007dc:	e8 92 ff ff ff       	call   800773 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007e1:	c9                   	leave  
  8007e2:	c3                   	ret    

008007e3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e3:	f3 0f 1e fb          	endbr32 
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f6:	74 05                	je     8007fd <strlen+0x1a>
		n++;
  8007f8:	83 c0 01             	add    $0x1,%eax
  8007fb:	eb f5                	jmp    8007f2 <strlen+0xf>
	return n;
}
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ff:	f3 0f 1e fb          	endbr32 
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800809:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080c:	b8 00 00 00 00       	mov    $0x0,%eax
  800811:	39 d0                	cmp    %edx,%eax
  800813:	74 0d                	je     800822 <strnlen+0x23>
  800815:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800819:	74 05                	je     800820 <strnlen+0x21>
		n++;
  80081b:	83 c0 01             	add    $0x1,%eax
  80081e:	eb f1                	jmp    800811 <strnlen+0x12>
  800820:	89 c2                	mov    %eax,%edx
	return n;
}
  800822:	89 d0                	mov    %edx,%eax
  800824:	5d                   	pop    %ebp
  800825:	c3                   	ret    

00800826 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800826:	f3 0f 1e fb          	endbr32 
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	53                   	push   %ebx
  80082e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800831:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800834:	b8 00 00 00 00       	mov    $0x0,%eax
  800839:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80083d:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800840:	83 c0 01             	add    $0x1,%eax
  800843:	84 d2                	test   %dl,%dl
  800845:	75 f2                	jne    800839 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800847:	89 c8                	mov    %ecx,%eax
  800849:	5b                   	pop    %ebx
  80084a:	5d                   	pop    %ebp
  80084b:	c3                   	ret    

0080084c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80084c:	f3 0f 1e fb          	endbr32 
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	53                   	push   %ebx
  800854:	83 ec 10             	sub    $0x10,%esp
  800857:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80085a:	53                   	push   %ebx
  80085b:	e8 83 ff ff ff       	call   8007e3 <strlen>
  800860:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800863:	ff 75 0c             	pushl  0xc(%ebp)
  800866:	01 d8                	add    %ebx,%eax
  800868:	50                   	push   %eax
  800869:	e8 b8 ff ff ff       	call   800826 <strcpy>
	return dst;
}
  80086e:	89 d8                	mov    %ebx,%eax
  800870:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800873:	c9                   	leave  
  800874:	c3                   	ret    

00800875 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800875:	f3 0f 1e fb          	endbr32 
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	56                   	push   %esi
  80087d:	53                   	push   %ebx
  80087e:	8b 75 08             	mov    0x8(%ebp),%esi
  800881:	8b 55 0c             	mov    0xc(%ebp),%edx
  800884:	89 f3                	mov    %esi,%ebx
  800886:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800889:	89 f0                	mov    %esi,%eax
  80088b:	39 d8                	cmp    %ebx,%eax
  80088d:	74 11                	je     8008a0 <strncpy+0x2b>
		*dst++ = *src;
  80088f:	83 c0 01             	add    $0x1,%eax
  800892:	0f b6 0a             	movzbl (%edx),%ecx
  800895:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800898:	80 f9 01             	cmp    $0x1,%cl
  80089b:	83 da ff             	sbb    $0xffffffff,%edx
  80089e:	eb eb                	jmp    80088b <strncpy+0x16>
	}
	return ret;
}
  8008a0:	89 f0                	mov    %esi,%eax
  8008a2:	5b                   	pop    %ebx
  8008a3:	5e                   	pop    %esi
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a6:	f3 0f 1e fb          	endbr32 
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	56                   	push   %esi
  8008ae:	53                   	push   %ebx
  8008af:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b5:	8b 55 10             	mov    0x10(%ebp),%edx
  8008b8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008ba:	85 d2                	test   %edx,%edx
  8008bc:	74 21                	je     8008df <strlcpy+0x39>
  8008be:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008c2:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008c4:	39 c2                	cmp    %eax,%edx
  8008c6:	74 14                	je     8008dc <strlcpy+0x36>
  8008c8:	0f b6 19             	movzbl (%ecx),%ebx
  8008cb:	84 db                	test   %bl,%bl
  8008cd:	74 0b                	je     8008da <strlcpy+0x34>
			*dst++ = *src++;
  8008cf:	83 c1 01             	add    $0x1,%ecx
  8008d2:	83 c2 01             	add    $0x1,%edx
  8008d5:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008d8:	eb ea                	jmp    8008c4 <strlcpy+0x1e>
  8008da:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008dc:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008df:	29 f0                	sub    %esi,%eax
}
  8008e1:	5b                   	pop    %ebx
  8008e2:	5e                   	pop    %esi
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    

008008e5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e5:	f3 0f 1e fb          	endbr32 
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ef:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008f2:	0f b6 01             	movzbl (%ecx),%eax
  8008f5:	84 c0                	test   %al,%al
  8008f7:	74 0c                	je     800905 <strcmp+0x20>
  8008f9:	3a 02                	cmp    (%edx),%al
  8008fb:	75 08                	jne    800905 <strcmp+0x20>
		p++, q++;
  8008fd:	83 c1 01             	add    $0x1,%ecx
  800900:	83 c2 01             	add    $0x1,%edx
  800903:	eb ed                	jmp    8008f2 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800905:	0f b6 c0             	movzbl %al,%eax
  800908:	0f b6 12             	movzbl (%edx),%edx
  80090b:	29 d0                	sub    %edx,%eax
}
  80090d:	5d                   	pop    %ebp
  80090e:	c3                   	ret    

0080090f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80090f:	f3 0f 1e fb          	endbr32 
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	53                   	push   %ebx
  800917:	8b 45 08             	mov    0x8(%ebp),%eax
  80091a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091d:	89 c3                	mov    %eax,%ebx
  80091f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800922:	eb 06                	jmp    80092a <strncmp+0x1b>
		n--, p++, q++;
  800924:	83 c0 01             	add    $0x1,%eax
  800927:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80092a:	39 d8                	cmp    %ebx,%eax
  80092c:	74 16                	je     800944 <strncmp+0x35>
  80092e:	0f b6 08             	movzbl (%eax),%ecx
  800931:	84 c9                	test   %cl,%cl
  800933:	74 04                	je     800939 <strncmp+0x2a>
  800935:	3a 0a                	cmp    (%edx),%cl
  800937:	74 eb                	je     800924 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800939:	0f b6 00             	movzbl (%eax),%eax
  80093c:	0f b6 12             	movzbl (%edx),%edx
  80093f:	29 d0                	sub    %edx,%eax
}
  800941:	5b                   	pop    %ebx
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    
		return 0;
  800944:	b8 00 00 00 00       	mov    $0x0,%eax
  800949:	eb f6                	jmp    800941 <strncmp+0x32>

0080094b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80094b:	f3 0f 1e fb          	endbr32 
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	8b 45 08             	mov    0x8(%ebp),%eax
  800955:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800959:	0f b6 10             	movzbl (%eax),%edx
  80095c:	84 d2                	test   %dl,%dl
  80095e:	74 09                	je     800969 <strchr+0x1e>
		if (*s == c)
  800960:	38 ca                	cmp    %cl,%dl
  800962:	74 0a                	je     80096e <strchr+0x23>
	for (; *s; s++)
  800964:	83 c0 01             	add    $0x1,%eax
  800967:	eb f0                	jmp    800959 <strchr+0xe>
			return (char *) s;
	return 0;
  800969:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800970:	f3 0f 1e fb          	endbr32 
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	8b 45 08             	mov    0x8(%ebp),%eax
  80097a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80097e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800981:	38 ca                	cmp    %cl,%dl
  800983:	74 09                	je     80098e <strfind+0x1e>
  800985:	84 d2                	test   %dl,%dl
  800987:	74 05                	je     80098e <strfind+0x1e>
	for (; *s; s++)
  800989:	83 c0 01             	add    $0x1,%eax
  80098c:	eb f0                	jmp    80097e <strfind+0xe>
			break;
	return (char *) s;
}
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800990:	f3 0f 1e fb          	endbr32 
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	57                   	push   %edi
  800998:	56                   	push   %esi
  800999:	53                   	push   %ebx
  80099a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80099d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009a0:	85 c9                	test   %ecx,%ecx
  8009a2:	74 31                	je     8009d5 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a4:	89 f8                	mov    %edi,%eax
  8009a6:	09 c8                	or     %ecx,%eax
  8009a8:	a8 03                	test   $0x3,%al
  8009aa:	75 23                	jne    8009cf <memset+0x3f>
		c &= 0xFF;
  8009ac:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009b0:	89 d3                	mov    %edx,%ebx
  8009b2:	c1 e3 08             	shl    $0x8,%ebx
  8009b5:	89 d0                	mov    %edx,%eax
  8009b7:	c1 e0 18             	shl    $0x18,%eax
  8009ba:	89 d6                	mov    %edx,%esi
  8009bc:	c1 e6 10             	shl    $0x10,%esi
  8009bf:	09 f0                	or     %esi,%eax
  8009c1:	09 c2                	or     %eax,%edx
  8009c3:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009c5:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009c8:	89 d0                	mov    %edx,%eax
  8009ca:	fc                   	cld    
  8009cb:	f3 ab                	rep stos %eax,%es:(%edi)
  8009cd:	eb 06                	jmp    8009d5 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d2:	fc                   	cld    
  8009d3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009d5:	89 f8                	mov    %edi,%eax
  8009d7:	5b                   	pop    %ebx
  8009d8:	5e                   	pop    %esi
  8009d9:	5f                   	pop    %edi
  8009da:	5d                   	pop    %ebp
  8009db:	c3                   	ret    

008009dc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009dc:	f3 0f 1e fb          	endbr32 
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	57                   	push   %edi
  8009e4:	56                   	push   %esi
  8009e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009eb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ee:	39 c6                	cmp    %eax,%esi
  8009f0:	73 32                	jae    800a24 <memmove+0x48>
  8009f2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009f5:	39 c2                	cmp    %eax,%edx
  8009f7:	76 2b                	jbe    800a24 <memmove+0x48>
		s += n;
		d += n;
  8009f9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fc:	89 fe                	mov    %edi,%esi
  8009fe:	09 ce                	or     %ecx,%esi
  800a00:	09 d6                	or     %edx,%esi
  800a02:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a08:	75 0e                	jne    800a18 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a0a:	83 ef 04             	sub    $0x4,%edi
  800a0d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a10:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a13:	fd                   	std    
  800a14:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a16:	eb 09                	jmp    800a21 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a18:	83 ef 01             	sub    $0x1,%edi
  800a1b:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a1e:	fd                   	std    
  800a1f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a21:	fc                   	cld    
  800a22:	eb 1a                	jmp    800a3e <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a24:	89 c2                	mov    %eax,%edx
  800a26:	09 ca                	or     %ecx,%edx
  800a28:	09 f2                	or     %esi,%edx
  800a2a:	f6 c2 03             	test   $0x3,%dl
  800a2d:	75 0a                	jne    800a39 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a2f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a32:	89 c7                	mov    %eax,%edi
  800a34:	fc                   	cld    
  800a35:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a37:	eb 05                	jmp    800a3e <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a39:	89 c7                	mov    %eax,%edi
  800a3b:	fc                   	cld    
  800a3c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a3e:	5e                   	pop    %esi
  800a3f:	5f                   	pop    %edi
  800a40:	5d                   	pop    %ebp
  800a41:	c3                   	ret    

00800a42 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a42:	f3 0f 1e fb          	endbr32 
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a4c:	ff 75 10             	pushl  0x10(%ebp)
  800a4f:	ff 75 0c             	pushl  0xc(%ebp)
  800a52:	ff 75 08             	pushl  0x8(%ebp)
  800a55:	e8 82 ff ff ff       	call   8009dc <memmove>
}
  800a5a:	c9                   	leave  
  800a5b:	c3                   	ret    

00800a5c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a5c:	f3 0f 1e fb          	endbr32 
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	56                   	push   %esi
  800a64:	53                   	push   %ebx
  800a65:	8b 45 08             	mov    0x8(%ebp),%eax
  800a68:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a6b:	89 c6                	mov    %eax,%esi
  800a6d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a70:	39 f0                	cmp    %esi,%eax
  800a72:	74 1c                	je     800a90 <memcmp+0x34>
		if (*s1 != *s2)
  800a74:	0f b6 08             	movzbl (%eax),%ecx
  800a77:	0f b6 1a             	movzbl (%edx),%ebx
  800a7a:	38 d9                	cmp    %bl,%cl
  800a7c:	75 08                	jne    800a86 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a7e:	83 c0 01             	add    $0x1,%eax
  800a81:	83 c2 01             	add    $0x1,%edx
  800a84:	eb ea                	jmp    800a70 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a86:	0f b6 c1             	movzbl %cl,%eax
  800a89:	0f b6 db             	movzbl %bl,%ebx
  800a8c:	29 d8                	sub    %ebx,%eax
  800a8e:	eb 05                	jmp    800a95 <memcmp+0x39>
	}

	return 0;
  800a90:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a95:	5b                   	pop    %ebx
  800a96:	5e                   	pop    %esi
  800a97:	5d                   	pop    %ebp
  800a98:	c3                   	ret    

00800a99 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a99:	f3 0f 1e fb          	endbr32 
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800aa6:	89 c2                	mov    %eax,%edx
  800aa8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aab:	39 d0                	cmp    %edx,%eax
  800aad:	73 09                	jae    800ab8 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aaf:	38 08                	cmp    %cl,(%eax)
  800ab1:	74 05                	je     800ab8 <memfind+0x1f>
	for (; s < ends; s++)
  800ab3:	83 c0 01             	add    $0x1,%eax
  800ab6:	eb f3                	jmp    800aab <memfind+0x12>
			break;
	return (void *) s;
}
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aba:	f3 0f 1e fb          	endbr32 
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	57                   	push   %edi
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
  800ac4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ac7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aca:	eb 03                	jmp    800acf <strtol+0x15>
		s++;
  800acc:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800acf:	0f b6 01             	movzbl (%ecx),%eax
  800ad2:	3c 20                	cmp    $0x20,%al
  800ad4:	74 f6                	je     800acc <strtol+0x12>
  800ad6:	3c 09                	cmp    $0x9,%al
  800ad8:	74 f2                	je     800acc <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800ada:	3c 2b                	cmp    $0x2b,%al
  800adc:	74 2a                	je     800b08 <strtol+0x4e>
	int neg = 0;
  800ade:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ae3:	3c 2d                	cmp    $0x2d,%al
  800ae5:	74 2b                	je     800b12 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ae7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aed:	75 0f                	jne    800afe <strtol+0x44>
  800aef:	80 39 30             	cmpb   $0x30,(%ecx)
  800af2:	74 28                	je     800b1c <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800af4:	85 db                	test   %ebx,%ebx
  800af6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800afb:	0f 44 d8             	cmove  %eax,%ebx
  800afe:	b8 00 00 00 00       	mov    $0x0,%eax
  800b03:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b06:	eb 46                	jmp    800b4e <strtol+0x94>
		s++;
  800b08:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b0b:	bf 00 00 00 00       	mov    $0x0,%edi
  800b10:	eb d5                	jmp    800ae7 <strtol+0x2d>
		s++, neg = 1;
  800b12:	83 c1 01             	add    $0x1,%ecx
  800b15:	bf 01 00 00 00       	mov    $0x1,%edi
  800b1a:	eb cb                	jmp    800ae7 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b1c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b20:	74 0e                	je     800b30 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b22:	85 db                	test   %ebx,%ebx
  800b24:	75 d8                	jne    800afe <strtol+0x44>
		s++, base = 8;
  800b26:	83 c1 01             	add    $0x1,%ecx
  800b29:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b2e:	eb ce                	jmp    800afe <strtol+0x44>
		s += 2, base = 16;
  800b30:	83 c1 02             	add    $0x2,%ecx
  800b33:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b38:	eb c4                	jmp    800afe <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b3a:	0f be d2             	movsbl %dl,%edx
  800b3d:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b40:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b43:	7d 3a                	jge    800b7f <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b45:	83 c1 01             	add    $0x1,%ecx
  800b48:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b4c:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b4e:	0f b6 11             	movzbl (%ecx),%edx
  800b51:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b54:	89 f3                	mov    %esi,%ebx
  800b56:	80 fb 09             	cmp    $0x9,%bl
  800b59:	76 df                	jbe    800b3a <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b5b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b5e:	89 f3                	mov    %esi,%ebx
  800b60:	80 fb 19             	cmp    $0x19,%bl
  800b63:	77 08                	ja     800b6d <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b65:	0f be d2             	movsbl %dl,%edx
  800b68:	83 ea 57             	sub    $0x57,%edx
  800b6b:	eb d3                	jmp    800b40 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b6d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b70:	89 f3                	mov    %esi,%ebx
  800b72:	80 fb 19             	cmp    $0x19,%bl
  800b75:	77 08                	ja     800b7f <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b77:	0f be d2             	movsbl %dl,%edx
  800b7a:	83 ea 37             	sub    $0x37,%edx
  800b7d:	eb c1                	jmp    800b40 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b7f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b83:	74 05                	je     800b8a <strtol+0xd0>
		*endptr = (char *) s;
  800b85:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b88:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b8a:	89 c2                	mov    %eax,%edx
  800b8c:	f7 da                	neg    %edx
  800b8e:	85 ff                	test   %edi,%edi
  800b90:	0f 45 c2             	cmovne %edx,%eax
}
  800b93:	5b                   	pop    %ebx
  800b94:	5e                   	pop    %esi
  800b95:	5f                   	pop    %edi
  800b96:	5d                   	pop    %ebp
  800b97:	c3                   	ret    

00800b98 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b98:	f3 0f 1e fb          	endbr32 
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	57                   	push   %edi
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800ba2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba7:	8b 55 08             	mov    0x8(%ebp),%edx
  800baa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bad:	89 c3                	mov    %eax,%ebx
  800baf:	89 c7                	mov    %eax,%edi
  800bb1:	89 c6                	mov    %eax,%esi
  800bb3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <sys_cgetc>:

int
sys_cgetc(void)
{
  800bba:	f3 0f 1e fb          	endbr32 
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800bc4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc9:	b8 01 00 00 00       	mov    $0x1,%eax
  800bce:	89 d1                	mov    %edx,%ecx
  800bd0:	89 d3                	mov    %edx,%ebx
  800bd2:	89 d7                	mov    %edx,%edi
  800bd4:	89 d6                	mov    %edx,%esi
  800bd6:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bd8:	5b                   	pop    %ebx
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    

00800bdd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bdd:	f3 0f 1e fb          	endbr32 
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	57                   	push   %edi
  800be5:	56                   	push   %esi
  800be6:	53                   	push   %ebx
  800be7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800bea:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bef:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf2:	b8 03 00 00 00       	mov    $0x3,%eax
  800bf7:	89 cb                	mov    %ecx,%ebx
  800bf9:	89 cf                	mov    %ecx,%edi
  800bfb:	89 ce                	mov    %ecx,%esi
  800bfd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bff:	85 c0                	test   %eax,%eax
  800c01:	7f 08                	jg     800c0b <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c06:	5b                   	pop    %ebx
  800c07:	5e                   	pop    %esi
  800c08:	5f                   	pop    %edi
  800c09:	5d                   	pop    %ebp
  800c0a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0b:	83 ec 0c             	sub    $0xc,%esp
  800c0e:	50                   	push   %eax
  800c0f:	6a 03                	push   $0x3
  800c11:	68 04 14 80 00       	push   $0x801404
  800c16:	6a 23                	push   $0x23
  800c18:	68 21 14 80 00       	push   $0x801421
  800c1d:	e8 13 f5 ff ff       	call   800135 <_panic>

00800c22 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c22:	f3 0f 1e fb          	endbr32 
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c31:	b8 02 00 00 00       	mov    $0x2,%eax
  800c36:	89 d1                	mov    %edx,%ecx
  800c38:	89 d3                	mov    %edx,%ebx
  800c3a:	89 d7                	mov    %edx,%edi
  800c3c:	89 d6                	mov    %edx,%esi
  800c3e:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <sys_yield>:

void
sys_yield(void)
{
  800c45:	f3 0f 1e fb          	endbr32 
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	57                   	push   %edi
  800c4d:	56                   	push   %esi
  800c4e:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c4f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c54:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c59:	89 d1                	mov    %edx,%ecx
  800c5b:	89 d3                	mov    %edx,%ebx
  800c5d:	89 d7                	mov    %edx,%edi
  800c5f:	89 d6                	mov    %edx,%esi
  800c61:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5f                   	pop    %edi
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c68:	f3 0f 1e fb          	endbr32 
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	57                   	push   %edi
  800c70:	56                   	push   %esi
  800c71:	53                   	push   %ebx
  800c72:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c75:	be 00 00 00 00       	mov    $0x0,%esi
  800c7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c80:	b8 04 00 00 00       	mov    $0x4,%eax
  800c85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c88:	89 f7                	mov    %esi,%edi
  800c8a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c8c:	85 c0                	test   %eax,%eax
  800c8e:	7f 08                	jg     800c98 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c93:	5b                   	pop    %ebx
  800c94:	5e                   	pop    %esi
  800c95:	5f                   	pop    %edi
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c98:	83 ec 0c             	sub    $0xc,%esp
  800c9b:	50                   	push   %eax
  800c9c:	6a 04                	push   $0x4
  800c9e:	68 04 14 80 00       	push   $0x801404
  800ca3:	6a 23                	push   $0x23
  800ca5:	68 21 14 80 00       	push   $0x801421
  800caa:	e8 86 f4 ff ff       	call   800135 <_panic>

00800caf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800caf:	f3 0f 1e fb          	endbr32 
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	57                   	push   %edi
  800cb7:	56                   	push   %esi
  800cb8:	53                   	push   %ebx
  800cb9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800cbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc2:	b8 05 00 00 00       	mov    $0x5,%eax
  800cc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cca:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ccd:	8b 75 18             	mov    0x18(%ebp),%esi
  800cd0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd2:	85 c0                	test   %eax,%eax
  800cd4:	7f 08                	jg     800cde <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd9:	5b                   	pop    %ebx
  800cda:	5e                   	pop    %esi
  800cdb:	5f                   	pop    %edi
  800cdc:	5d                   	pop    %ebp
  800cdd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cde:	83 ec 0c             	sub    $0xc,%esp
  800ce1:	50                   	push   %eax
  800ce2:	6a 05                	push   $0x5
  800ce4:	68 04 14 80 00       	push   $0x801404
  800ce9:	6a 23                	push   $0x23
  800ceb:	68 21 14 80 00       	push   $0x801421
  800cf0:	e8 40 f4 ff ff       	call   800135 <_panic>

00800cf5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cf5:	f3 0f 1e fb          	endbr32 
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
  800cff:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d02:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d07:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0d:	b8 06 00 00 00       	mov    $0x6,%eax
  800d12:	89 df                	mov    %ebx,%edi
  800d14:	89 de                	mov    %ebx,%esi
  800d16:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	7f 08                	jg     800d24 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d24:	83 ec 0c             	sub    $0xc,%esp
  800d27:	50                   	push   %eax
  800d28:	6a 06                	push   $0x6
  800d2a:	68 04 14 80 00       	push   $0x801404
  800d2f:	6a 23                	push   $0x23
  800d31:	68 21 14 80 00       	push   $0x801421
  800d36:	e8 fa f3 ff ff       	call   800135 <_panic>

00800d3b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d3b:	f3 0f 1e fb          	endbr32 
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	57                   	push   %edi
  800d43:	56                   	push   %esi
  800d44:	53                   	push   %ebx
  800d45:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d48:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d53:	b8 08 00 00 00       	mov    $0x8,%eax
  800d58:	89 df                	mov    %ebx,%edi
  800d5a:	89 de                	mov    %ebx,%esi
  800d5c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d5e:	85 c0                	test   %eax,%eax
  800d60:	7f 08                	jg     800d6a <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d65:	5b                   	pop    %ebx
  800d66:	5e                   	pop    %esi
  800d67:	5f                   	pop    %edi
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6a:	83 ec 0c             	sub    $0xc,%esp
  800d6d:	50                   	push   %eax
  800d6e:	6a 08                	push   $0x8
  800d70:	68 04 14 80 00       	push   $0x801404
  800d75:	6a 23                	push   $0x23
  800d77:	68 21 14 80 00       	push   $0x801421
  800d7c:	e8 b4 f3 ff ff       	call   800135 <_panic>

00800d81 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d81:	f3 0f 1e fb          	endbr32 
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	57                   	push   %edi
  800d89:	56                   	push   %esi
  800d8a:	53                   	push   %ebx
  800d8b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d93:	8b 55 08             	mov    0x8(%ebp),%edx
  800d96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d99:	b8 09 00 00 00       	mov    $0x9,%eax
  800d9e:	89 df                	mov    %ebx,%edi
  800da0:	89 de                	mov    %ebx,%esi
  800da2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800da4:	85 c0                	test   %eax,%eax
  800da6:	7f 08                	jg     800db0 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800da8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dab:	5b                   	pop    %ebx
  800dac:	5e                   	pop    %esi
  800dad:	5f                   	pop    %edi
  800dae:	5d                   	pop    %ebp
  800daf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800db0:	83 ec 0c             	sub    $0xc,%esp
  800db3:	50                   	push   %eax
  800db4:	6a 09                	push   $0x9
  800db6:	68 04 14 80 00       	push   $0x801404
  800dbb:	6a 23                	push   $0x23
  800dbd:	68 21 14 80 00       	push   $0x801421
  800dc2:	e8 6e f3 ff ff       	call   800135 <_panic>

00800dc7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dc7:	f3 0f 1e fb          	endbr32 
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	57                   	push   %edi
  800dcf:	56                   	push   %esi
  800dd0:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800dd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ddc:	be 00 00 00 00       	mov    $0x0,%esi
  800de1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de7:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800de9:	5b                   	pop    %ebx
  800dea:	5e                   	pop    %esi
  800deb:	5f                   	pop    %edi
  800dec:	5d                   	pop    %ebp
  800ded:	c3                   	ret    

00800dee <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dee:	f3 0f 1e fb          	endbr32 
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	57                   	push   %edi
  800df6:	56                   	push   %esi
  800df7:	53                   	push   %ebx
  800df8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800dfb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e00:	8b 55 08             	mov    0x8(%ebp),%edx
  800e03:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e08:	89 cb                	mov    %ecx,%ebx
  800e0a:	89 cf                	mov    %ecx,%edi
  800e0c:	89 ce                	mov    %ecx,%esi
  800e0e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e10:	85 c0                	test   %eax,%eax
  800e12:	7f 08                	jg     800e1c <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e17:	5b                   	pop    %ebx
  800e18:	5e                   	pop    %esi
  800e19:	5f                   	pop    %edi
  800e1a:	5d                   	pop    %ebp
  800e1b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1c:	83 ec 0c             	sub    $0xc,%esp
  800e1f:	50                   	push   %eax
  800e20:	6a 0c                	push   $0xc
  800e22:	68 04 14 80 00       	push   $0x801404
  800e27:	6a 23                	push   $0x23
  800e29:	68 21 14 80 00       	push   $0x801421
  800e2e:	e8 02 f3 ff ff       	call   800135 <_panic>

00800e33 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800e33:	f3 0f 1e fb          	endbr32 
  800e37:	55                   	push   %ebp
  800e38:	89 e5                	mov    %esp,%ebp
  800e3a:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e3d:	83 3d 64 40 80 00 00 	cmpl   $0x0,0x804064
  800e44:	74 0a                	je     800e50 <set_pgfault_handler+0x1d>
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);		//系统调用，设置进程的env_pgfault_upcall属性
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e46:	8b 45 08             	mov    0x8(%ebp),%eax
  800e49:	a3 64 40 80 00       	mov    %eax,0x804064
}
  800e4e:	c9                   	leave  
  800e4f:	c3                   	ret    
		int r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_W | PTE_U | PTE_P);	//为当前进程分配异常栈
  800e50:	83 ec 04             	sub    $0x4,%esp
  800e53:	6a 07                	push   $0x7
  800e55:	68 00 f0 bf ee       	push   $0xeebff000
  800e5a:	6a 00                	push   $0x0
  800e5c:	e8 07 fe ff ff       	call   800c68 <sys_page_alloc>
		if (r < 0) {
  800e61:	83 c4 10             	add    $0x10,%esp
  800e64:	85 c0                	test   %eax,%eax
  800e66:	78 14                	js     800e7c <set_pgfault_handler+0x49>
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);		//系统调用，设置进程的env_pgfault_upcall属性
  800e68:	83 ec 08             	sub    $0x8,%esp
  800e6b:	68 90 0e 80 00       	push   $0x800e90
  800e70:	6a 00                	push   $0x0
  800e72:	e8 0a ff ff ff       	call   800d81 <sys_env_set_pgfault_upcall>
  800e77:	83 c4 10             	add    $0x10,%esp
  800e7a:	eb ca                	jmp    800e46 <set_pgfault_handler+0x13>
			panic("set_pgfault_handler:sys_page_alloc failed");;
  800e7c:	83 ec 04             	sub    $0x4,%esp
  800e7f:	68 30 14 80 00       	push   $0x801430
  800e84:	6a 22                	push   $0x22
  800e86:	68 5a 14 80 00       	push   $0x80145a
  800e8b:	e8 a5 f2 ff ff       	call   800135 <_panic>

00800e90 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e90:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e91:	a1 64 40 80 00       	mov    0x804064,%eax
	call *%eax				
  800e96:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e98:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp			
  800e9b:	83 c4 08             	add    $0x8,%esp
	movl 40(%esp), %eax 	
  800e9e:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 32(%esp), %ecx 	
  800ea2:	8b 4c 24 20          	mov    0x20(%esp),%ecx
	movl %ecx, -4(%eax) 	
  800ea6:	89 48 fc             	mov    %ecx,-0x4(%eax)
	popal
  800ea9:	61                   	popa   
	addl $4, %esp		
  800eaa:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popfl
  800ead:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800eae:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	lea -4(%esp), %esp	
  800eaf:	8d 64 24 fc          	lea    -0x4(%esp),%esp
	ret
  800eb3:	c3                   	ret    
  800eb4:	66 90                	xchg   %ax,%ax
  800eb6:	66 90                	xchg   %ax,%ax
  800eb8:	66 90                	xchg   %ax,%ax
  800eba:	66 90                	xchg   %ax,%ax
  800ebc:	66 90                	xchg   %ax,%ax
  800ebe:	66 90                	xchg   %ax,%ax

00800ec0 <__udivdi3>:
  800ec0:	f3 0f 1e fb          	endbr32 
  800ec4:	55                   	push   %ebp
  800ec5:	57                   	push   %edi
  800ec6:	56                   	push   %esi
  800ec7:	53                   	push   %ebx
  800ec8:	83 ec 1c             	sub    $0x1c,%esp
  800ecb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800ecf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800ed3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ed7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800edb:	85 d2                	test   %edx,%edx
  800edd:	75 19                	jne    800ef8 <__udivdi3+0x38>
  800edf:	39 f3                	cmp    %esi,%ebx
  800ee1:	76 4d                	jbe    800f30 <__udivdi3+0x70>
  800ee3:	31 ff                	xor    %edi,%edi
  800ee5:	89 e8                	mov    %ebp,%eax
  800ee7:	89 f2                	mov    %esi,%edx
  800ee9:	f7 f3                	div    %ebx
  800eeb:	89 fa                	mov    %edi,%edx
  800eed:	83 c4 1c             	add    $0x1c,%esp
  800ef0:	5b                   	pop    %ebx
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    
  800ef5:	8d 76 00             	lea    0x0(%esi),%esi
  800ef8:	39 f2                	cmp    %esi,%edx
  800efa:	76 14                	jbe    800f10 <__udivdi3+0x50>
  800efc:	31 ff                	xor    %edi,%edi
  800efe:	31 c0                	xor    %eax,%eax
  800f00:	89 fa                	mov    %edi,%edx
  800f02:	83 c4 1c             	add    $0x1c,%esp
  800f05:	5b                   	pop    %ebx
  800f06:	5e                   	pop    %esi
  800f07:	5f                   	pop    %edi
  800f08:	5d                   	pop    %ebp
  800f09:	c3                   	ret    
  800f0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f10:	0f bd fa             	bsr    %edx,%edi
  800f13:	83 f7 1f             	xor    $0x1f,%edi
  800f16:	75 48                	jne    800f60 <__udivdi3+0xa0>
  800f18:	39 f2                	cmp    %esi,%edx
  800f1a:	72 06                	jb     800f22 <__udivdi3+0x62>
  800f1c:	31 c0                	xor    %eax,%eax
  800f1e:	39 eb                	cmp    %ebp,%ebx
  800f20:	77 de                	ja     800f00 <__udivdi3+0x40>
  800f22:	b8 01 00 00 00       	mov    $0x1,%eax
  800f27:	eb d7                	jmp    800f00 <__udivdi3+0x40>
  800f29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f30:	89 d9                	mov    %ebx,%ecx
  800f32:	85 db                	test   %ebx,%ebx
  800f34:	75 0b                	jne    800f41 <__udivdi3+0x81>
  800f36:	b8 01 00 00 00       	mov    $0x1,%eax
  800f3b:	31 d2                	xor    %edx,%edx
  800f3d:	f7 f3                	div    %ebx
  800f3f:	89 c1                	mov    %eax,%ecx
  800f41:	31 d2                	xor    %edx,%edx
  800f43:	89 f0                	mov    %esi,%eax
  800f45:	f7 f1                	div    %ecx
  800f47:	89 c6                	mov    %eax,%esi
  800f49:	89 e8                	mov    %ebp,%eax
  800f4b:	89 f7                	mov    %esi,%edi
  800f4d:	f7 f1                	div    %ecx
  800f4f:	89 fa                	mov    %edi,%edx
  800f51:	83 c4 1c             	add    $0x1c,%esp
  800f54:	5b                   	pop    %ebx
  800f55:	5e                   	pop    %esi
  800f56:	5f                   	pop    %edi
  800f57:	5d                   	pop    %ebp
  800f58:	c3                   	ret    
  800f59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f60:	89 f9                	mov    %edi,%ecx
  800f62:	b8 20 00 00 00       	mov    $0x20,%eax
  800f67:	29 f8                	sub    %edi,%eax
  800f69:	d3 e2                	shl    %cl,%edx
  800f6b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f6f:	89 c1                	mov    %eax,%ecx
  800f71:	89 da                	mov    %ebx,%edx
  800f73:	d3 ea                	shr    %cl,%edx
  800f75:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f79:	09 d1                	or     %edx,%ecx
  800f7b:	89 f2                	mov    %esi,%edx
  800f7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f81:	89 f9                	mov    %edi,%ecx
  800f83:	d3 e3                	shl    %cl,%ebx
  800f85:	89 c1                	mov    %eax,%ecx
  800f87:	d3 ea                	shr    %cl,%edx
  800f89:	89 f9                	mov    %edi,%ecx
  800f8b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f8f:	89 eb                	mov    %ebp,%ebx
  800f91:	d3 e6                	shl    %cl,%esi
  800f93:	89 c1                	mov    %eax,%ecx
  800f95:	d3 eb                	shr    %cl,%ebx
  800f97:	09 de                	or     %ebx,%esi
  800f99:	89 f0                	mov    %esi,%eax
  800f9b:	f7 74 24 08          	divl   0x8(%esp)
  800f9f:	89 d6                	mov    %edx,%esi
  800fa1:	89 c3                	mov    %eax,%ebx
  800fa3:	f7 64 24 0c          	mull   0xc(%esp)
  800fa7:	39 d6                	cmp    %edx,%esi
  800fa9:	72 15                	jb     800fc0 <__udivdi3+0x100>
  800fab:	89 f9                	mov    %edi,%ecx
  800fad:	d3 e5                	shl    %cl,%ebp
  800faf:	39 c5                	cmp    %eax,%ebp
  800fb1:	73 04                	jae    800fb7 <__udivdi3+0xf7>
  800fb3:	39 d6                	cmp    %edx,%esi
  800fb5:	74 09                	je     800fc0 <__udivdi3+0x100>
  800fb7:	89 d8                	mov    %ebx,%eax
  800fb9:	31 ff                	xor    %edi,%edi
  800fbb:	e9 40 ff ff ff       	jmp    800f00 <__udivdi3+0x40>
  800fc0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800fc3:	31 ff                	xor    %edi,%edi
  800fc5:	e9 36 ff ff ff       	jmp    800f00 <__udivdi3+0x40>
  800fca:	66 90                	xchg   %ax,%ax
  800fcc:	66 90                	xchg   %ax,%ax
  800fce:	66 90                	xchg   %ax,%ax

00800fd0 <__umoddi3>:
  800fd0:	f3 0f 1e fb          	endbr32 
  800fd4:	55                   	push   %ebp
  800fd5:	57                   	push   %edi
  800fd6:	56                   	push   %esi
  800fd7:	53                   	push   %ebx
  800fd8:	83 ec 1c             	sub    $0x1c,%esp
  800fdb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800fdf:	8b 74 24 30          	mov    0x30(%esp),%esi
  800fe3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800fe7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800feb:	85 c0                	test   %eax,%eax
  800fed:	75 19                	jne    801008 <__umoddi3+0x38>
  800fef:	39 df                	cmp    %ebx,%edi
  800ff1:	76 5d                	jbe    801050 <__umoddi3+0x80>
  800ff3:	89 f0                	mov    %esi,%eax
  800ff5:	89 da                	mov    %ebx,%edx
  800ff7:	f7 f7                	div    %edi
  800ff9:	89 d0                	mov    %edx,%eax
  800ffb:	31 d2                	xor    %edx,%edx
  800ffd:	83 c4 1c             	add    $0x1c,%esp
  801000:	5b                   	pop    %ebx
  801001:	5e                   	pop    %esi
  801002:	5f                   	pop    %edi
  801003:	5d                   	pop    %ebp
  801004:	c3                   	ret    
  801005:	8d 76 00             	lea    0x0(%esi),%esi
  801008:	89 f2                	mov    %esi,%edx
  80100a:	39 d8                	cmp    %ebx,%eax
  80100c:	76 12                	jbe    801020 <__umoddi3+0x50>
  80100e:	89 f0                	mov    %esi,%eax
  801010:	89 da                	mov    %ebx,%edx
  801012:	83 c4 1c             	add    $0x1c,%esp
  801015:	5b                   	pop    %ebx
  801016:	5e                   	pop    %esi
  801017:	5f                   	pop    %edi
  801018:	5d                   	pop    %ebp
  801019:	c3                   	ret    
  80101a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801020:	0f bd e8             	bsr    %eax,%ebp
  801023:	83 f5 1f             	xor    $0x1f,%ebp
  801026:	75 50                	jne    801078 <__umoddi3+0xa8>
  801028:	39 d8                	cmp    %ebx,%eax
  80102a:	0f 82 e0 00 00 00    	jb     801110 <__umoddi3+0x140>
  801030:	89 d9                	mov    %ebx,%ecx
  801032:	39 f7                	cmp    %esi,%edi
  801034:	0f 86 d6 00 00 00    	jbe    801110 <__umoddi3+0x140>
  80103a:	89 d0                	mov    %edx,%eax
  80103c:	89 ca                	mov    %ecx,%edx
  80103e:	83 c4 1c             	add    $0x1c,%esp
  801041:	5b                   	pop    %ebx
  801042:	5e                   	pop    %esi
  801043:	5f                   	pop    %edi
  801044:	5d                   	pop    %ebp
  801045:	c3                   	ret    
  801046:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80104d:	8d 76 00             	lea    0x0(%esi),%esi
  801050:	89 fd                	mov    %edi,%ebp
  801052:	85 ff                	test   %edi,%edi
  801054:	75 0b                	jne    801061 <__umoddi3+0x91>
  801056:	b8 01 00 00 00       	mov    $0x1,%eax
  80105b:	31 d2                	xor    %edx,%edx
  80105d:	f7 f7                	div    %edi
  80105f:	89 c5                	mov    %eax,%ebp
  801061:	89 d8                	mov    %ebx,%eax
  801063:	31 d2                	xor    %edx,%edx
  801065:	f7 f5                	div    %ebp
  801067:	89 f0                	mov    %esi,%eax
  801069:	f7 f5                	div    %ebp
  80106b:	89 d0                	mov    %edx,%eax
  80106d:	31 d2                	xor    %edx,%edx
  80106f:	eb 8c                	jmp    800ffd <__umoddi3+0x2d>
  801071:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801078:	89 e9                	mov    %ebp,%ecx
  80107a:	ba 20 00 00 00       	mov    $0x20,%edx
  80107f:	29 ea                	sub    %ebp,%edx
  801081:	d3 e0                	shl    %cl,%eax
  801083:	89 44 24 08          	mov    %eax,0x8(%esp)
  801087:	89 d1                	mov    %edx,%ecx
  801089:	89 f8                	mov    %edi,%eax
  80108b:	d3 e8                	shr    %cl,%eax
  80108d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801091:	89 54 24 04          	mov    %edx,0x4(%esp)
  801095:	8b 54 24 04          	mov    0x4(%esp),%edx
  801099:	09 c1                	or     %eax,%ecx
  80109b:	89 d8                	mov    %ebx,%eax
  80109d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010a1:	89 e9                	mov    %ebp,%ecx
  8010a3:	d3 e7                	shl    %cl,%edi
  8010a5:	89 d1                	mov    %edx,%ecx
  8010a7:	d3 e8                	shr    %cl,%eax
  8010a9:	89 e9                	mov    %ebp,%ecx
  8010ab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010af:	d3 e3                	shl    %cl,%ebx
  8010b1:	89 c7                	mov    %eax,%edi
  8010b3:	89 d1                	mov    %edx,%ecx
  8010b5:	89 f0                	mov    %esi,%eax
  8010b7:	d3 e8                	shr    %cl,%eax
  8010b9:	89 e9                	mov    %ebp,%ecx
  8010bb:	89 fa                	mov    %edi,%edx
  8010bd:	d3 e6                	shl    %cl,%esi
  8010bf:	09 d8                	or     %ebx,%eax
  8010c1:	f7 74 24 08          	divl   0x8(%esp)
  8010c5:	89 d1                	mov    %edx,%ecx
  8010c7:	89 f3                	mov    %esi,%ebx
  8010c9:	f7 64 24 0c          	mull   0xc(%esp)
  8010cd:	89 c6                	mov    %eax,%esi
  8010cf:	89 d7                	mov    %edx,%edi
  8010d1:	39 d1                	cmp    %edx,%ecx
  8010d3:	72 06                	jb     8010db <__umoddi3+0x10b>
  8010d5:	75 10                	jne    8010e7 <__umoddi3+0x117>
  8010d7:	39 c3                	cmp    %eax,%ebx
  8010d9:	73 0c                	jae    8010e7 <__umoddi3+0x117>
  8010db:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8010df:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8010e3:	89 d7                	mov    %edx,%edi
  8010e5:	89 c6                	mov    %eax,%esi
  8010e7:	89 ca                	mov    %ecx,%edx
  8010e9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010ee:	29 f3                	sub    %esi,%ebx
  8010f0:	19 fa                	sbb    %edi,%edx
  8010f2:	89 d0                	mov    %edx,%eax
  8010f4:	d3 e0                	shl    %cl,%eax
  8010f6:	89 e9                	mov    %ebp,%ecx
  8010f8:	d3 eb                	shr    %cl,%ebx
  8010fa:	d3 ea                	shr    %cl,%edx
  8010fc:	09 d8                	or     %ebx,%eax
  8010fe:	83 c4 1c             	add    $0x1c,%esp
  801101:	5b                   	pop    %ebx
  801102:	5e                   	pop    %esi
  801103:	5f                   	pop    %edi
  801104:	5d                   	pop    %ebp
  801105:	c3                   	ret    
  801106:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80110d:	8d 76 00             	lea    0x0(%esi),%esi
  801110:	29 fe                	sub    %edi,%esi
  801112:	19 c3                	sbb    %eax,%ebx
  801114:	89 f2                	mov    %esi,%edx
  801116:	89 d9                	mov    %ebx,%ecx
  801118:	e9 1d ff ff ff       	jmp    80103a <__umoddi3+0x6a>
