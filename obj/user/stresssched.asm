
obj/user/stresssched:     file format elf32-i386


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
  80002c:	e8 b9 00 00 00       	call   8000ea <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	56                   	push   %esi
  80003b:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  80003c:	e8 f9 0b 00 00       	call   800c3a <sys_getenvid>
  800041:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  800043:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800048:	e8 d2 0e 00 00       	call   800f1f <fork>
  80004d:	85 c0                	test   %eax,%eax
  80004f:	74 0f                	je     800060 <umain+0x2d>
	for (i = 0; i < 20; i++)
  800051:	83 c3 01             	add    $0x1,%ebx
  800054:	83 fb 14             	cmp    $0x14,%ebx
  800057:	75 ef                	jne    800048 <umain+0x15>
			break;
	if (i == 20) {
		sys_yield();
  800059:	e8 ff 0b 00 00       	call   800c5d <sys_yield>
		return;
  80005e:	eb 6c                	jmp    8000cc <umain+0x99>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800060:	89 f0                	mov    %esi,%eax
  800062:	25 ff 03 00 00       	and    $0x3ff,%eax
  800067:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  80006d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800072:	eb 02                	jmp    800076 <umain+0x43>
		asm volatile("pause");
  800074:	f3 90                	pause  
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800076:	8b 50 54             	mov    0x54(%eax),%edx
  800079:	85 d2                	test   %edx,%edx
  80007b:	75 f7                	jne    800074 <umain+0x41>
  80007d:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800082:	e8 d6 0b 00 00       	call   800c5d <sys_yield>
  800087:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008c:	a1 50 20 80 00       	mov    0x802050,%eax
  800091:	83 c0 01             	add    $0x1,%eax
  800094:	a3 50 20 80 00       	mov    %eax,0x802050
		for (j = 0; j < 10000; j++)
  800099:	83 ea 01             	sub    $0x1,%edx
  80009c:	75 ee                	jne    80008c <umain+0x59>
	for (i = 0; i < 10; i++) {
  80009e:	83 eb 01             	sub    $0x1,%ebx
  8000a1:	75 df                	jne    800082 <umain+0x4f>
	}

	if (counter != 10*10000)
  8000a3:	a1 50 20 80 00       	mov    0x802050,%eax
  8000a8:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000ad:	75 24                	jne    8000d3 <umain+0xa0>
		panic("ran on two CPUs at once (counter is %d)", counter);

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000af:	a1 60 40 80 00       	mov    0x804060,%eax
  8000b4:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000b7:	8b 40 48             	mov    0x48(%eax),%eax
  8000ba:	83 ec 04             	sub    $0x4,%esp
  8000bd:	52                   	push   %edx
  8000be:	50                   	push   %eax
  8000bf:	68 1b 14 80 00       	push   $0x80141b
  8000c4:	e8 6b 01 00 00       	call   800234 <cprintf>
  8000c9:	83 c4 10             	add    $0x10,%esp

}
  8000cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cf:	5b                   	pop    %ebx
  8000d0:	5e                   	pop    %esi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000d3:	a1 50 20 80 00       	mov    0x802050,%eax
  8000d8:	50                   	push   %eax
  8000d9:	68 e0 13 80 00       	push   $0x8013e0
  8000de:	6a 21                	push   $0x21
  8000e0:	68 08 14 80 00       	push   $0x801408
  8000e5:	e8 63 00 00 00       	call   80014d <_panic>

008000ea <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ea:	f3 0f 1e fb          	endbr32 
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	56                   	push   %esi
  8000f2:	53                   	push   %ebx
  8000f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8000f9:	e8 3c 0b 00 00       	call   800c3a <sys_getenvid>
	thisenv = envs + ENVX(envid);
  8000fe:	25 ff 03 00 00       	and    $0x3ff,%eax
  800103:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  800109:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010e:	a3 60 40 80 00       	mov    %eax,0x804060

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800113:	85 db                	test   %ebx,%ebx
  800115:	7e 07                	jle    80011e <libmain+0x34>
		binaryname = argv[0];
  800117:	8b 06                	mov    (%esi),%eax
  800119:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80011e:	83 ec 08             	sub    $0x8,%esp
  800121:	56                   	push   %esi
  800122:	53                   	push   %ebx
  800123:	e8 0b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800128:	e8 0a 00 00 00       	call   800137 <exit>
}
  80012d:	83 c4 10             	add    $0x10,%esp
  800130:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800133:	5b                   	pop    %ebx
  800134:	5e                   	pop    %esi
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    

00800137 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800137:	f3 0f 1e fb          	endbr32 
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800141:	6a 00                	push   $0x0
  800143:	e8 ad 0a 00 00       	call   800bf5 <sys_env_destroy>
}
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014d:	f3 0f 1e fb          	endbr32 
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	56                   	push   %esi
  800155:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800156:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800159:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80015f:	e8 d6 0a 00 00       	call   800c3a <sys_getenvid>
  800164:	83 ec 0c             	sub    $0xc,%esp
  800167:	ff 75 0c             	pushl  0xc(%ebp)
  80016a:	ff 75 08             	pushl  0x8(%ebp)
  80016d:	56                   	push   %esi
  80016e:	50                   	push   %eax
  80016f:	68 44 14 80 00       	push   $0x801444
  800174:	e8 bb 00 00 00       	call   800234 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800179:	83 c4 18             	add    $0x18,%esp
  80017c:	53                   	push   %ebx
  80017d:	ff 75 10             	pushl  0x10(%ebp)
  800180:	e8 5a 00 00 00       	call   8001df <vcprintf>
	cprintf("\n");
  800185:	c7 04 24 37 14 80 00 	movl   $0x801437,(%esp)
  80018c:	e8 a3 00 00 00       	call   800234 <cprintf>
  800191:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800194:	cc                   	int3   
  800195:	eb fd                	jmp    800194 <_panic+0x47>

00800197 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800197:	f3 0f 1e fb          	endbr32 
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	53                   	push   %ebx
  80019f:	83 ec 04             	sub    $0x4,%esp
  8001a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a5:	8b 13                	mov    (%ebx),%edx
  8001a7:	8d 42 01             	lea    0x1(%edx),%eax
  8001aa:	89 03                	mov    %eax,(%ebx)
  8001ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001af:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b8:	74 09                	je     8001c3 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001ba:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c1:	c9                   	leave  
  8001c2:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001c3:	83 ec 08             	sub    $0x8,%esp
  8001c6:	68 ff 00 00 00       	push   $0xff
  8001cb:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ce:	50                   	push   %eax
  8001cf:	e8 dc 09 00 00       	call   800bb0 <sys_cputs>
		b->idx = 0;
  8001d4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001da:	83 c4 10             	add    $0x10,%esp
  8001dd:	eb db                	jmp    8001ba <putch+0x23>

008001df <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001df:	f3 0f 1e fb          	endbr32 
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ec:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f3:	00 00 00 
	b.cnt = 0;
  8001f6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800200:	ff 75 0c             	pushl  0xc(%ebp)
  800203:	ff 75 08             	pushl  0x8(%ebp)
  800206:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020c:	50                   	push   %eax
  80020d:	68 97 01 80 00       	push   $0x800197
  800212:	e8 20 01 00 00       	call   800337 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800217:	83 c4 08             	add    $0x8,%esp
  80021a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800220:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800226:	50                   	push   %eax
  800227:	e8 84 09 00 00       	call   800bb0 <sys_cputs>

	return b.cnt;
}
  80022c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800232:	c9                   	leave  
  800233:	c3                   	ret    

00800234 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800234:	f3 0f 1e fb          	endbr32 
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80023e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800241:	50                   	push   %eax
  800242:	ff 75 08             	pushl  0x8(%ebp)
  800245:	e8 95 ff ff ff       	call   8001df <vcprintf>
	va_end(ap);

	return cnt;
}
  80024a:	c9                   	leave  
  80024b:	c3                   	ret    

0080024c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	57                   	push   %edi
  800250:	56                   	push   %esi
  800251:	53                   	push   %ebx
  800252:	83 ec 1c             	sub    $0x1c,%esp
  800255:	89 c7                	mov    %eax,%edi
  800257:	89 d6                	mov    %edx,%esi
  800259:	8b 45 08             	mov    0x8(%ebp),%eax
  80025c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80025f:	89 d1                	mov    %edx,%ecx
  800261:	89 c2                	mov    %eax,%edx
  800263:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800266:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800269:	8b 45 10             	mov    0x10(%ebp),%eax
  80026c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80026f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800272:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800279:	39 c2                	cmp    %eax,%edx
  80027b:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80027e:	72 3e                	jb     8002be <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800280:	83 ec 0c             	sub    $0xc,%esp
  800283:	ff 75 18             	pushl  0x18(%ebp)
  800286:	83 eb 01             	sub    $0x1,%ebx
  800289:	53                   	push   %ebx
  80028a:	50                   	push   %eax
  80028b:	83 ec 08             	sub    $0x8,%esp
  80028e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800291:	ff 75 e0             	pushl  -0x20(%ebp)
  800294:	ff 75 dc             	pushl  -0x24(%ebp)
  800297:	ff 75 d8             	pushl  -0x28(%ebp)
  80029a:	e8 d1 0e 00 00       	call   801170 <__udivdi3>
  80029f:	83 c4 18             	add    $0x18,%esp
  8002a2:	52                   	push   %edx
  8002a3:	50                   	push   %eax
  8002a4:	89 f2                	mov    %esi,%edx
  8002a6:	89 f8                	mov    %edi,%eax
  8002a8:	e8 9f ff ff ff       	call   80024c <printnum>
  8002ad:	83 c4 20             	add    $0x20,%esp
  8002b0:	eb 13                	jmp    8002c5 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002b2:	83 ec 08             	sub    $0x8,%esp
  8002b5:	56                   	push   %esi
  8002b6:	ff 75 18             	pushl  0x18(%ebp)
  8002b9:	ff d7                	call   *%edi
  8002bb:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002be:	83 eb 01             	sub    $0x1,%ebx
  8002c1:	85 db                	test   %ebx,%ebx
  8002c3:	7f ed                	jg     8002b2 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c5:	83 ec 08             	sub    $0x8,%esp
  8002c8:	56                   	push   %esi
  8002c9:	83 ec 04             	sub    $0x4,%esp
  8002cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d8:	e8 a3 0f 00 00       	call   801280 <__umoddi3>
  8002dd:	83 c4 14             	add    $0x14,%esp
  8002e0:	0f be 80 67 14 80 00 	movsbl 0x801467(%eax),%eax
  8002e7:	50                   	push   %eax
  8002e8:	ff d7                	call   *%edi
}
  8002ea:	83 c4 10             	add    $0x10,%esp
  8002ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f0:	5b                   	pop    %ebx
  8002f1:	5e                   	pop    %esi
  8002f2:	5f                   	pop    %edi
  8002f3:	5d                   	pop    %ebp
  8002f4:	c3                   	ret    

008002f5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f5:	f3 0f 1e fb          	endbr32 
  8002f9:	55                   	push   %ebp
  8002fa:	89 e5                	mov    %esp,%ebp
  8002fc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ff:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800303:	8b 10                	mov    (%eax),%edx
  800305:	3b 50 04             	cmp    0x4(%eax),%edx
  800308:	73 0a                	jae    800314 <sprintputch+0x1f>
		*b->buf++ = ch;
  80030a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80030d:	89 08                	mov    %ecx,(%eax)
  80030f:	8b 45 08             	mov    0x8(%ebp),%eax
  800312:	88 02                	mov    %al,(%edx)
}
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <printfmt>:
{
  800316:	f3 0f 1e fb          	endbr32 
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800320:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800323:	50                   	push   %eax
  800324:	ff 75 10             	pushl  0x10(%ebp)
  800327:	ff 75 0c             	pushl  0xc(%ebp)
  80032a:	ff 75 08             	pushl  0x8(%ebp)
  80032d:	e8 05 00 00 00       	call   800337 <vprintfmt>
}
  800332:	83 c4 10             	add    $0x10,%esp
  800335:	c9                   	leave  
  800336:	c3                   	ret    

00800337 <vprintfmt>:
{
  800337:	f3 0f 1e fb          	endbr32 
  80033b:	55                   	push   %ebp
  80033c:	89 e5                	mov    %esp,%ebp
  80033e:	57                   	push   %edi
  80033f:	56                   	push   %esi
  800340:	53                   	push   %ebx
  800341:	83 ec 3c             	sub    $0x3c,%esp
  800344:	8b 75 08             	mov    0x8(%ebp),%esi
  800347:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80034a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80034d:	e9 8e 03 00 00       	jmp    8006e0 <vprintfmt+0x3a9>
		padc = ' ';
  800352:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800356:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80035d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800364:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80036b:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800370:	8d 47 01             	lea    0x1(%edi),%eax
  800373:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800376:	0f b6 17             	movzbl (%edi),%edx
  800379:	8d 42 dd             	lea    -0x23(%edx),%eax
  80037c:	3c 55                	cmp    $0x55,%al
  80037e:	0f 87 df 03 00 00    	ja     800763 <vprintfmt+0x42c>
  800384:	0f b6 c0             	movzbl %al,%eax
  800387:	3e ff 24 85 20 15 80 	notrack jmp *0x801520(,%eax,4)
  80038e:	00 
  80038f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800392:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800396:	eb d8                	jmp    800370 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80039b:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80039f:	eb cf                	jmp    800370 <vprintfmt+0x39>
  8003a1:	0f b6 d2             	movzbl %dl,%edx
  8003a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ac:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003af:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b2:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003b6:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003b9:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003bc:	83 f9 09             	cmp    $0x9,%ecx
  8003bf:	77 55                	ja     800416 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003c1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003c4:	eb e9                	jmp    8003af <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c9:	8b 00                	mov    (%eax),%eax
  8003cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d1:	8d 40 04             	lea    0x4(%eax),%eax
  8003d4:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003da:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003de:	79 90                	jns    800370 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003ed:	eb 81                	jmp    800370 <vprintfmt+0x39>
  8003ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003f2:	85 c0                	test   %eax,%eax
  8003f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f9:	0f 49 d0             	cmovns %eax,%edx
  8003fc:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800402:	e9 69 ff ff ff       	jmp    800370 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800407:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80040a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800411:	e9 5a ff ff ff       	jmp    800370 <vprintfmt+0x39>
  800416:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800419:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80041c:	eb bc                	jmp    8003da <vprintfmt+0xa3>
			lflag++;
  80041e:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800421:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800424:	e9 47 ff ff ff       	jmp    800370 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800429:	8b 45 14             	mov    0x14(%ebp),%eax
  80042c:	8d 78 04             	lea    0x4(%eax),%edi
  80042f:	83 ec 08             	sub    $0x8,%esp
  800432:	53                   	push   %ebx
  800433:	ff 30                	pushl  (%eax)
  800435:	ff d6                	call   *%esi
			break;
  800437:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80043a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80043d:	e9 9b 02 00 00       	jmp    8006dd <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800442:	8b 45 14             	mov    0x14(%ebp),%eax
  800445:	8d 78 04             	lea    0x4(%eax),%edi
  800448:	8b 00                	mov    (%eax),%eax
  80044a:	99                   	cltd   
  80044b:	31 d0                	xor    %edx,%eax
  80044d:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044f:	83 f8 08             	cmp    $0x8,%eax
  800452:	7f 23                	jg     800477 <vprintfmt+0x140>
  800454:	8b 14 85 80 16 80 00 	mov    0x801680(,%eax,4),%edx
  80045b:	85 d2                	test   %edx,%edx
  80045d:	74 18                	je     800477 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80045f:	52                   	push   %edx
  800460:	68 88 14 80 00       	push   $0x801488
  800465:	53                   	push   %ebx
  800466:	56                   	push   %esi
  800467:	e8 aa fe ff ff       	call   800316 <printfmt>
  80046c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80046f:	89 7d 14             	mov    %edi,0x14(%ebp)
  800472:	e9 66 02 00 00       	jmp    8006dd <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800477:	50                   	push   %eax
  800478:	68 7f 14 80 00       	push   $0x80147f
  80047d:	53                   	push   %ebx
  80047e:	56                   	push   %esi
  80047f:	e8 92 fe ff ff       	call   800316 <printfmt>
  800484:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800487:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80048a:	e9 4e 02 00 00       	jmp    8006dd <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  80048f:	8b 45 14             	mov    0x14(%ebp),%eax
  800492:	83 c0 04             	add    $0x4,%eax
  800495:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800498:	8b 45 14             	mov    0x14(%ebp),%eax
  80049b:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80049d:	85 d2                	test   %edx,%edx
  80049f:	b8 78 14 80 00       	mov    $0x801478,%eax
  8004a4:	0f 45 c2             	cmovne %edx,%eax
  8004a7:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004aa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ae:	7e 06                	jle    8004b6 <vprintfmt+0x17f>
  8004b0:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004b4:	75 0d                	jne    8004c3 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004b9:	89 c7                	mov    %eax,%edi
  8004bb:	03 45 e0             	add    -0x20(%ebp),%eax
  8004be:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c1:	eb 55                	jmp    800518 <vprintfmt+0x1e1>
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c9:	ff 75 cc             	pushl  -0x34(%ebp)
  8004cc:	e8 46 03 00 00       	call   800817 <strnlen>
  8004d1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004d4:	29 c2                	sub    %eax,%edx
  8004d6:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004d9:	83 c4 10             	add    $0x10,%esp
  8004dc:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004de:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e5:	85 ff                	test   %edi,%edi
  8004e7:	7e 11                	jle    8004fa <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004e9:	83 ec 08             	sub    $0x8,%esp
  8004ec:	53                   	push   %ebx
  8004ed:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f0:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f2:	83 ef 01             	sub    $0x1,%edi
  8004f5:	83 c4 10             	add    $0x10,%esp
  8004f8:	eb eb                	jmp    8004e5 <vprintfmt+0x1ae>
  8004fa:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004fd:	85 d2                	test   %edx,%edx
  8004ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800504:	0f 49 c2             	cmovns %edx,%eax
  800507:	29 c2                	sub    %eax,%edx
  800509:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80050c:	eb a8                	jmp    8004b6 <vprintfmt+0x17f>
					putch(ch, putdat);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	53                   	push   %ebx
  800512:	52                   	push   %edx
  800513:	ff d6                	call   *%esi
  800515:	83 c4 10             	add    $0x10,%esp
  800518:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80051b:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051d:	83 c7 01             	add    $0x1,%edi
  800520:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800524:	0f be d0             	movsbl %al,%edx
  800527:	85 d2                	test   %edx,%edx
  800529:	74 4b                	je     800576 <vprintfmt+0x23f>
  80052b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80052f:	78 06                	js     800537 <vprintfmt+0x200>
  800531:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800535:	78 1e                	js     800555 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800537:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80053b:	74 d1                	je     80050e <vprintfmt+0x1d7>
  80053d:	0f be c0             	movsbl %al,%eax
  800540:	83 e8 20             	sub    $0x20,%eax
  800543:	83 f8 5e             	cmp    $0x5e,%eax
  800546:	76 c6                	jbe    80050e <vprintfmt+0x1d7>
					putch('?', putdat);
  800548:	83 ec 08             	sub    $0x8,%esp
  80054b:	53                   	push   %ebx
  80054c:	6a 3f                	push   $0x3f
  80054e:	ff d6                	call   *%esi
  800550:	83 c4 10             	add    $0x10,%esp
  800553:	eb c3                	jmp    800518 <vprintfmt+0x1e1>
  800555:	89 cf                	mov    %ecx,%edi
  800557:	eb 0e                	jmp    800567 <vprintfmt+0x230>
				putch(' ', putdat);
  800559:	83 ec 08             	sub    $0x8,%esp
  80055c:	53                   	push   %ebx
  80055d:	6a 20                	push   $0x20
  80055f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800561:	83 ef 01             	sub    $0x1,%edi
  800564:	83 c4 10             	add    $0x10,%esp
  800567:	85 ff                	test   %edi,%edi
  800569:	7f ee                	jg     800559 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80056b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80056e:	89 45 14             	mov    %eax,0x14(%ebp)
  800571:	e9 67 01 00 00       	jmp    8006dd <vprintfmt+0x3a6>
  800576:	89 cf                	mov    %ecx,%edi
  800578:	eb ed                	jmp    800567 <vprintfmt+0x230>
	if (lflag >= 2)
  80057a:	83 f9 01             	cmp    $0x1,%ecx
  80057d:	7f 1b                	jg     80059a <vprintfmt+0x263>
	else if (lflag)
  80057f:	85 c9                	test   %ecx,%ecx
  800581:	74 63                	je     8005e6 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8b 00                	mov    (%eax),%eax
  800588:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058b:	99                   	cltd   
  80058c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058f:	8b 45 14             	mov    0x14(%ebp),%eax
  800592:	8d 40 04             	lea    0x4(%eax),%eax
  800595:	89 45 14             	mov    %eax,0x14(%ebp)
  800598:	eb 17                	jmp    8005b1 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8b 50 04             	mov    0x4(%eax),%edx
  8005a0:	8b 00                	mov    (%eax),%eax
  8005a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ab:	8d 40 08             	lea    0x8(%eax),%eax
  8005ae:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005b7:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005bc:	85 c9                	test   %ecx,%ecx
  8005be:	0f 89 ff 00 00 00    	jns    8006c3 <vprintfmt+0x38c>
				putch('-', putdat);
  8005c4:	83 ec 08             	sub    $0x8,%esp
  8005c7:	53                   	push   %ebx
  8005c8:	6a 2d                	push   $0x2d
  8005ca:	ff d6                	call   *%esi
				num = -(long long) num;
  8005cc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005cf:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005d2:	f7 da                	neg    %edx
  8005d4:	83 d1 00             	adc    $0x0,%ecx
  8005d7:	f7 d9                	neg    %ecx
  8005d9:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005dc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e1:	e9 dd 00 00 00       	jmp    8006c3 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8b 00                	mov    (%eax),%eax
  8005eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ee:	99                   	cltd   
  8005ef:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8d 40 04             	lea    0x4(%eax),%eax
  8005f8:	89 45 14             	mov    %eax,0x14(%ebp)
  8005fb:	eb b4                	jmp    8005b1 <vprintfmt+0x27a>
	if (lflag >= 2)
  8005fd:	83 f9 01             	cmp    $0x1,%ecx
  800600:	7f 1e                	jg     800620 <vprintfmt+0x2e9>
	else if (lflag)
  800602:	85 c9                	test   %ecx,%ecx
  800604:	74 32                	je     800638 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8b 10                	mov    (%eax),%edx
  80060b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800610:	8d 40 04             	lea    0x4(%eax),%eax
  800613:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800616:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80061b:	e9 a3 00 00 00       	jmp    8006c3 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8b 10                	mov    (%eax),%edx
  800625:	8b 48 04             	mov    0x4(%eax),%ecx
  800628:	8d 40 08             	lea    0x8(%eax),%eax
  80062b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80062e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800633:	e9 8b 00 00 00       	jmp    8006c3 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	8b 10                	mov    (%eax),%edx
  80063d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800642:	8d 40 04             	lea    0x4(%eax),%eax
  800645:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800648:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80064d:	eb 74                	jmp    8006c3 <vprintfmt+0x38c>
	if (lflag >= 2)
  80064f:	83 f9 01             	cmp    $0x1,%ecx
  800652:	7f 1b                	jg     80066f <vprintfmt+0x338>
	else if (lflag)
  800654:	85 c9                	test   %ecx,%ecx
  800656:	74 2c                	je     800684 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800658:	8b 45 14             	mov    0x14(%ebp),%eax
  80065b:	8b 10                	mov    (%eax),%edx
  80065d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800662:	8d 40 04             	lea    0x4(%eax),%eax
  800665:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800668:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  80066d:	eb 54                	jmp    8006c3 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8b 10                	mov    (%eax),%edx
  800674:	8b 48 04             	mov    0x4(%eax),%ecx
  800677:	8d 40 08             	lea    0x8(%eax),%eax
  80067a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80067d:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800682:	eb 3f                	jmp    8006c3 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8b 10                	mov    (%eax),%edx
  800689:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068e:	8d 40 04             	lea    0x4(%eax),%eax
  800691:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800694:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800699:	eb 28                	jmp    8006c3 <vprintfmt+0x38c>
			putch('0', putdat);
  80069b:	83 ec 08             	sub    $0x8,%esp
  80069e:	53                   	push   %ebx
  80069f:	6a 30                	push   $0x30
  8006a1:	ff d6                	call   *%esi
			putch('x', putdat);
  8006a3:	83 c4 08             	add    $0x8,%esp
  8006a6:	53                   	push   %ebx
  8006a7:	6a 78                	push   $0x78
  8006a9:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ae:	8b 10                	mov    (%eax),%edx
  8006b0:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006b5:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006b8:	8d 40 04             	lea    0x4(%eax),%eax
  8006bb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006be:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006c3:	83 ec 0c             	sub    $0xc,%esp
  8006c6:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8006ca:	57                   	push   %edi
  8006cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ce:	50                   	push   %eax
  8006cf:	51                   	push   %ecx
  8006d0:	52                   	push   %edx
  8006d1:	89 da                	mov    %ebx,%edx
  8006d3:	89 f0                	mov    %esi,%eax
  8006d5:	e8 72 fb ff ff       	call   80024c <printnum>
			break;
  8006da:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8006dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {	
  8006e0:	83 c7 01             	add    $0x1,%edi
  8006e3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006e7:	83 f8 25             	cmp    $0x25,%eax
  8006ea:	0f 84 62 fc ff ff    	je     800352 <vprintfmt+0x1b>
			if (ch == '\0')										
  8006f0:	85 c0                	test   %eax,%eax
  8006f2:	0f 84 8b 00 00 00    	je     800783 <vprintfmt+0x44c>
			putch(ch, putdat);
  8006f8:	83 ec 08             	sub    $0x8,%esp
  8006fb:	53                   	push   %ebx
  8006fc:	50                   	push   %eax
  8006fd:	ff d6                	call   *%esi
  8006ff:	83 c4 10             	add    $0x10,%esp
  800702:	eb dc                	jmp    8006e0 <vprintfmt+0x3a9>
	if (lflag >= 2)
  800704:	83 f9 01             	cmp    $0x1,%ecx
  800707:	7f 1b                	jg     800724 <vprintfmt+0x3ed>
	else if (lflag)
  800709:	85 c9                	test   %ecx,%ecx
  80070b:	74 2c                	je     800739 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  80070d:	8b 45 14             	mov    0x14(%ebp),%eax
  800710:	8b 10                	mov    (%eax),%edx
  800712:	b9 00 00 00 00       	mov    $0x0,%ecx
  800717:	8d 40 04             	lea    0x4(%eax),%eax
  80071a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80071d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800722:	eb 9f                	jmp    8006c3 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800724:	8b 45 14             	mov    0x14(%ebp),%eax
  800727:	8b 10                	mov    (%eax),%edx
  800729:	8b 48 04             	mov    0x4(%eax),%ecx
  80072c:	8d 40 08             	lea    0x8(%eax),%eax
  80072f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800732:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800737:	eb 8a                	jmp    8006c3 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800739:	8b 45 14             	mov    0x14(%ebp),%eax
  80073c:	8b 10                	mov    (%eax),%edx
  80073e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800743:	8d 40 04             	lea    0x4(%eax),%eax
  800746:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800749:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80074e:	e9 70 ff ff ff       	jmp    8006c3 <vprintfmt+0x38c>
			putch(ch, putdat);
  800753:	83 ec 08             	sub    $0x8,%esp
  800756:	53                   	push   %ebx
  800757:	6a 25                	push   $0x25
  800759:	ff d6                	call   *%esi
			break;
  80075b:	83 c4 10             	add    $0x10,%esp
  80075e:	e9 7a ff ff ff       	jmp    8006dd <vprintfmt+0x3a6>
			putch('%', putdat);
  800763:	83 ec 08             	sub    $0x8,%esp
  800766:	53                   	push   %ebx
  800767:	6a 25                	push   $0x25
  800769:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80076b:	83 c4 10             	add    $0x10,%esp
  80076e:	89 f8                	mov    %edi,%eax
  800770:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800774:	74 05                	je     80077b <vprintfmt+0x444>
  800776:	83 e8 01             	sub    $0x1,%eax
  800779:	eb f5                	jmp    800770 <vprintfmt+0x439>
  80077b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80077e:	e9 5a ff ff ff       	jmp    8006dd <vprintfmt+0x3a6>
}
  800783:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800786:	5b                   	pop    %ebx
  800787:	5e                   	pop    %esi
  800788:	5f                   	pop    %edi
  800789:	5d                   	pop    %ebp
  80078a:	c3                   	ret    

0080078b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80078b:	f3 0f 1e fb          	endbr32 
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	83 ec 18             	sub    $0x18,%esp
  800795:	8b 45 08             	mov    0x8(%ebp),%eax
  800798:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80079b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80079e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ac:	85 c0                	test   %eax,%eax
  8007ae:	74 26                	je     8007d6 <vsnprintf+0x4b>
  8007b0:	85 d2                	test   %edx,%edx
  8007b2:	7e 22                	jle    8007d6 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007b4:	ff 75 14             	pushl  0x14(%ebp)
  8007b7:	ff 75 10             	pushl  0x10(%ebp)
  8007ba:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007bd:	50                   	push   %eax
  8007be:	68 f5 02 80 00       	push   $0x8002f5
  8007c3:	e8 6f fb ff ff       	call   800337 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007cb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d1:	83 c4 10             	add    $0x10,%esp
}
  8007d4:	c9                   	leave  
  8007d5:	c3                   	ret    
		return -E_INVAL;
  8007d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007db:	eb f7                	jmp    8007d4 <vsnprintf+0x49>

008007dd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007dd:	f3 0f 1e fb          	endbr32 
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007e7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ea:	50                   	push   %eax
  8007eb:	ff 75 10             	pushl  0x10(%ebp)
  8007ee:	ff 75 0c             	pushl  0xc(%ebp)
  8007f1:	ff 75 08             	pushl  0x8(%ebp)
  8007f4:	e8 92 ff ff ff       	call   80078b <vsnprintf>
	va_end(ap);

	return rc;
}
  8007f9:	c9                   	leave  
  8007fa:	c3                   	ret    

008007fb <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007fb:	f3 0f 1e fb          	endbr32 
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800805:	b8 00 00 00 00       	mov    $0x0,%eax
  80080a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80080e:	74 05                	je     800815 <strlen+0x1a>
		n++;
  800810:	83 c0 01             	add    $0x1,%eax
  800813:	eb f5                	jmp    80080a <strlen+0xf>
	return n;
}
  800815:	5d                   	pop    %ebp
  800816:	c3                   	ret    

00800817 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800817:	f3 0f 1e fb          	endbr32 
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800821:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800824:	b8 00 00 00 00       	mov    $0x0,%eax
  800829:	39 d0                	cmp    %edx,%eax
  80082b:	74 0d                	je     80083a <strnlen+0x23>
  80082d:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800831:	74 05                	je     800838 <strnlen+0x21>
		n++;
  800833:	83 c0 01             	add    $0x1,%eax
  800836:	eb f1                	jmp    800829 <strnlen+0x12>
  800838:	89 c2                	mov    %eax,%edx
	return n;
}
  80083a:	89 d0                	mov    %edx,%eax
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80083e:	f3 0f 1e fb          	endbr32 
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	53                   	push   %ebx
  800846:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800849:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80084c:	b8 00 00 00 00       	mov    $0x0,%eax
  800851:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800855:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800858:	83 c0 01             	add    $0x1,%eax
  80085b:	84 d2                	test   %dl,%dl
  80085d:	75 f2                	jne    800851 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80085f:	89 c8                	mov    %ecx,%eax
  800861:	5b                   	pop    %ebx
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800864:	f3 0f 1e fb          	endbr32 
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	53                   	push   %ebx
  80086c:	83 ec 10             	sub    $0x10,%esp
  80086f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800872:	53                   	push   %ebx
  800873:	e8 83 ff ff ff       	call   8007fb <strlen>
  800878:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80087b:	ff 75 0c             	pushl  0xc(%ebp)
  80087e:	01 d8                	add    %ebx,%eax
  800880:	50                   	push   %eax
  800881:	e8 b8 ff ff ff       	call   80083e <strcpy>
	return dst;
}
  800886:	89 d8                	mov    %ebx,%eax
  800888:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80088b:	c9                   	leave  
  80088c:	c3                   	ret    

0080088d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80088d:	f3 0f 1e fb          	endbr32 
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	56                   	push   %esi
  800895:	53                   	push   %ebx
  800896:	8b 75 08             	mov    0x8(%ebp),%esi
  800899:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089c:	89 f3                	mov    %esi,%ebx
  80089e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a1:	89 f0                	mov    %esi,%eax
  8008a3:	39 d8                	cmp    %ebx,%eax
  8008a5:	74 11                	je     8008b8 <strncpy+0x2b>
		*dst++ = *src;
  8008a7:	83 c0 01             	add    $0x1,%eax
  8008aa:	0f b6 0a             	movzbl (%edx),%ecx
  8008ad:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b0:	80 f9 01             	cmp    $0x1,%cl
  8008b3:	83 da ff             	sbb    $0xffffffff,%edx
  8008b6:	eb eb                	jmp    8008a3 <strncpy+0x16>
	}
	return ret;
}
  8008b8:	89 f0                	mov    %esi,%eax
  8008ba:	5b                   	pop    %ebx
  8008bb:	5e                   	pop    %esi
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008be:	f3 0f 1e fb          	endbr32 
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	56                   	push   %esi
  8008c6:	53                   	push   %ebx
  8008c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008cd:	8b 55 10             	mov    0x10(%ebp),%edx
  8008d0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d2:	85 d2                	test   %edx,%edx
  8008d4:	74 21                	je     8008f7 <strlcpy+0x39>
  8008d6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008da:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008dc:	39 c2                	cmp    %eax,%edx
  8008de:	74 14                	je     8008f4 <strlcpy+0x36>
  8008e0:	0f b6 19             	movzbl (%ecx),%ebx
  8008e3:	84 db                	test   %bl,%bl
  8008e5:	74 0b                	je     8008f2 <strlcpy+0x34>
			*dst++ = *src++;
  8008e7:	83 c1 01             	add    $0x1,%ecx
  8008ea:	83 c2 01             	add    $0x1,%edx
  8008ed:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008f0:	eb ea                	jmp    8008dc <strlcpy+0x1e>
  8008f2:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008f4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008f7:	29 f0                	sub    %esi,%eax
}
  8008f9:	5b                   	pop    %ebx
  8008fa:	5e                   	pop    %esi
  8008fb:	5d                   	pop    %ebp
  8008fc:	c3                   	ret    

008008fd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008fd:	f3 0f 1e fb          	endbr32 
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800907:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80090a:	0f b6 01             	movzbl (%ecx),%eax
  80090d:	84 c0                	test   %al,%al
  80090f:	74 0c                	je     80091d <strcmp+0x20>
  800911:	3a 02                	cmp    (%edx),%al
  800913:	75 08                	jne    80091d <strcmp+0x20>
		p++, q++;
  800915:	83 c1 01             	add    $0x1,%ecx
  800918:	83 c2 01             	add    $0x1,%edx
  80091b:	eb ed                	jmp    80090a <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80091d:	0f b6 c0             	movzbl %al,%eax
  800920:	0f b6 12             	movzbl (%edx),%edx
  800923:	29 d0                	sub    %edx,%eax
}
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800927:	f3 0f 1e fb          	endbr32 
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	53                   	push   %ebx
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
  800932:	8b 55 0c             	mov    0xc(%ebp),%edx
  800935:	89 c3                	mov    %eax,%ebx
  800937:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80093a:	eb 06                	jmp    800942 <strncmp+0x1b>
		n--, p++, q++;
  80093c:	83 c0 01             	add    $0x1,%eax
  80093f:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800942:	39 d8                	cmp    %ebx,%eax
  800944:	74 16                	je     80095c <strncmp+0x35>
  800946:	0f b6 08             	movzbl (%eax),%ecx
  800949:	84 c9                	test   %cl,%cl
  80094b:	74 04                	je     800951 <strncmp+0x2a>
  80094d:	3a 0a                	cmp    (%edx),%cl
  80094f:	74 eb                	je     80093c <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800951:	0f b6 00             	movzbl (%eax),%eax
  800954:	0f b6 12             	movzbl (%edx),%edx
  800957:	29 d0                	sub    %edx,%eax
}
  800959:	5b                   	pop    %ebx
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    
		return 0;
  80095c:	b8 00 00 00 00       	mov    $0x0,%eax
  800961:	eb f6                	jmp    800959 <strncmp+0x32>

00800963 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800963:	f3 0f 1e fb          	endbr32 
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800971:	0f b6 10             	movzbl (%eax),%edx
  800974:	84 d2                	test   %dl,%dl
  800976:	74 09                	je     800981 <strchr+0x1e>
		if (*s == c)
  800978:	38 ca                	cmp    %cl,%dl
  80097a:	74 0a                	je     800986 <strchr+0x23>
	for (; *s; s++)
  80097c:	83 c0 01             	add    $0x1,%eax
  80097f:	eb f0                	jmp    800971 <strchr+0xe>
			return (char *) s;
	return 0;
  800981:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800988:	f3 0f 1e fb          	endbr32 
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800996:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800999:	38 ca                	cmp    %cl,%dl
  80099b:	74 09                	je     8009a6 <strfind+0x1e>
  80099d:	84 d2                	test   %dl,%dl
  80099f:	74 05                	je     8009a6 <strfind+0x1e>
	for (; *s; s++)
  8009a1:	83 c0 01             	add    $0x1,%eax
  8009a4:	eb f0                	jmp    800996 <strfind+0xe>
			break;
	return (char *) s;
}
  8009a6:	5d                   	pop    %ebp
  8009a7:	c3                   	ret    

008009a8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009a8:	f3 0f 1e fb          	endbr32 
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	57                   	push   %edi
  8009b0:	56                   	push   %esi
  8009b1:	53                   	push   %ebx
  8009b2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009b5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009b8:	85 c9                	test   %ecx,%ecx
  8009ba:	74 31                	je     8009ed <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009bc:	89 f8                	mov    %edi,%eax
  8009be:	09 c8                	or     %ecx,%eax
  8009c0:	a8 03                	test   $0x3,%al
  8009c2:	75 23                	jne    8009e7 <memset+0x3f>
		c &= 0xFF;
  8009c4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c8:	89 d3                	mov    %edx,%ebx
  8009ca:	c1 e3 08             	shl    $0x8,%ebx
  8009cd:	89 d0                	mov    %edx,%eax
  8009cf:	c1 e0 18             	shl    $0x18,%eax
  8009d2:	89 d6                	mov    %edx,%esi
  8009d4:	c1 e6 10             	shl    $0x10,%esi
  8009d7:	09 f0                	or     %esi,%eax
  8009d9:	09 c2                	or     %eax,%edx
  8009db:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009dd:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009e0:	89 d0                	mov    %edx,%eax
  8009e2:	fc                   	cld    
  8009e3:	f3 ab                	rep stos %eax,%es:(%edi)
  8009e5:	eb 06                	jmp    8009ed <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ea:	fc                   	cld    
  8009eb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009ed:	89 f8                	mov    %edi,%eax
  8009ef:	5b                   	pop    %ebx
  8009f0:	5e                   	pop    %esi
  8009f1:	5f                   	pop    %edi
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009f4:	f3 0f 1e fb          	endbr32 
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	57                   	push   %edi
  8009fc:	56                   	push   %esi
  8009fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800a00:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a03:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a06:	39 c6                	cmp    %eax,%esi
  800a08:	73 32                	jae    800a3c <memmove+0x48>
  800a0a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a0d:	39 c2                	cmp    %eax,%edx
  800a0f:	76 2b                	jbe    800a3c <memmove+0x48>
		s += n;
		d += n;
  800a11:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a14:	89 fe                	mov    %edi,%esi
  800a16:	09 ce                	or     %ecx,%esi
  800a18:	09 d6                	or     %edx,%esi
  800a1a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a20:	75 0e                	jne    800a30 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a22:	83 ef 04             	sub    $0x4,%edi
  800a25:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a28:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a2b:	fd                   	std    
  800a2c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a2e:	eb 09                	jmp    800a39 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a30:	83 ef 01             	sub    $0x1,%edi
  800a33:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a36:	fd                   	std    
  800a37:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a39:	fc                   	cld    
  800a3a:	eb 1a                	jmp    800a56 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3c:	89 c2                	mov    %eax,%edx
  800a3e:	09 ca                	or     %ecx,%edx
  800a40:	09 f2                	or     %esi,%edx
  800a42:	f6 c2 03             	test   $0x3,%dl
  800a45:	75 0a                	jne    800a51 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a47:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a4a:	89 c7                	mov    %eax,%edi
  800a4c:	fc                   	cld    
  800a4d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a4f:	eb 05                	jmp    800a56 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a51:	89 c7                	mov    %eax,%edi
  800a53:	fc                   	cld    
  800a54:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a56:	5e                   	pop    %esi
  800a57:	5f                   	pop    %edi
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a5a:	f3 0f 1e fb          	endbr32 
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a64:	ff 75 10             	pushl  0x10(%ebp)
  800a67:	ff 75 0c             	pushl  0xc(%ebp)
  800a6a:	ff 75 08             	pushl  0x8(%ebp)
  800a6d:	e8 82 ff ff ff       	call   8009f4 <memmove>
}
  800a72:	c9                   	leave  
  800a73:	c3                   	ret    

00800a74 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a74:	f3 0f 1e fb          	endbr32 
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	56                   	push   %esi
  800a7c:	53                   	push   %ebx
  800a7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a80:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a83:	89 c6                	mov    %eax,%esi
  800a85:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a88:	39 f0                	cmp    %esi,%eax
  800a8a:	74 1c                	je     800aa8 <memcmp+0x34>
		if (*s1 != *s2)
  800a8c:	0f b6 08             	movzbl (%eax),%ecx
  800a8f:	0f b6 1a             	movzbl (%edx),%ebx
  800a92:	38 d9                	cmp    %bl,%cl
  800a94:	75 08                	jne    800a9e <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a96:	83 c0 01             	add    $0x1,%eax
  800a99:	83 c2 01             	add    $0x1,%edx
  800a9c:	eb ea                	jmp    800a88 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a9e:	0f b6 c1             	movzbl %cl,%eax
  800aa1:	0f b6 db             	movzbl %bl,%ebx
  800aa4:	29 d8                	sub    %ebx,%eax
  800aa6:	eb 05                	jmp    800aad <memcmp+0x39>
	}

	return 0;
  800aa8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aad:	5b                   	pop    %ebx
  800aae:	5e                   	pop    %esi
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ab1:	f3 0f 1e fb          	endbr32 
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  800abb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800abe:	89 c2                	mov    %eax,%edx
  800ac0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ac3:	39 d0                	cmp    %edx,%eax
  800ac5:	73 09                	jae    800ad0 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ac7:	38 08                	cmp    %cl,(%eax)
  800ac9:	74 05                	je     800ad0 <memfind+0x1f>
	for (; s < ends; s++)
  800acb:	83 c0 01             	add    $0x1,%eax
  800ace:	eb f3                	jmp    800ac3 <memfind+0x12>
			break;
	return (void *) s;
}
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    

00800ad2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ad2:	f3 0f 1e fb          	endbr32 
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	57                   	push   %edi
  800ada:	56                   	push   %esi
  800adb:	53                   	push   %ebx
  800adc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800adf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ae2:	eb 03                	jmp    800ae7 <strtol+0x15>
		s++;
  800ae4:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ae7:	0f b6 01             	movzbl (%ecx),%eax
  800aea:	3c 20                	cmp    $0x20,%al
  800aec:	74 f6                	je     800ae4 <strtol+0x12>
  800aee:	3c 09                	cmp    $0x9,%al
  800af0:	74 f2                	je     800ae4 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800af2:	3c 2b                	cmp    $0x2b,%al
  800af4:	74 2a                	je     800b20 <strtol+0x4e>
	int neg = 0;
  800af6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800afb:	3c 2d                	cmp    $0x2d,%al
  800afd:	74 2b                	je     800b2a <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aff:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b05:	75 0f                	jne    800b16 <strtol+0x44>
  800b07:	80 39 30             	cmpb   $0x30,(%ecx)
  800b0a:	74 28                	je     800b34 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b0c:	85 db                	test   %ebx,%ebx
  800b0e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b13:	0f 44 d8             	cmove  %eax,%ebx
  800b16:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b1e:	eb 46                	jmp    800b66 <strtol+0x94>
		s++;
  800b20:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b23:	bf 00 00 00 00       	mov    $0x0,%edi
  800b28:	eb d5                	jmp    800aff <strtol+0x2d>
		s++, neg = 1;
  800b2a:	83 c1 01             	add    $0x1,%ecx
  800b2d:	bf 01 00 00 00       	mov    $0x1,%edi
  800b32:	eb cb                	jmp    800aff <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b34:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b38:	74 0e                	je     800b48 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b3a:	85 db                	test   %ebx,%ebx
  800b3c:	75 d8                	jne    800b16 <strtol+0x44>
		s++, base = 8;
  800b3e:	83 c1 01             	add    $0x1,%ecx
  800b41:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b46:	eb ce                	jmp    800b16 <strtol+0x44>
		s += 2, base = 16;
  800b48:	83 c1 02             	add    $0x2,%ecx
  800b4b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b50:	eb c4                	jmp    800b16 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b52:	0f be d2             	movsbl %dl,%edx
  800b55:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b58:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b5b:	7d 3a                	jge    800b97 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b5d:	83 c1 01             	add    $0x1,%ecx
  800b60:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b64:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b66:	0f b6 11             	movzbl (%ecx),%edx
  800b69:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b6c:	89 f3                	mov    %esi,%ebx
  800b6e:	80 fb 09             	cmp    $0x9,%bl
  800b71:	76 df                	jbe    800b52 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b73:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b76:	89 f3                	mov    %esi,%ebx
  800b78:	80 fb 19             	cmp    $0x19,%bl
  800b7b:	77 08                	ja     800b85 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b7d:	0f be d2             	movsbl %dl,%edx
  800b80:	83 ea 57             	sub    $0x57,%edx
  800b83:	eb d3                	jmp    800b58 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b85:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b88:	89 f3                	mov    %esi,%ebx
  800b8a:	80 fb 19             	cmp    $0x19,%bl
  800b8d:	77 08                	ja     800b97 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b8f:	0f be d2             	movsbl %dl,%edx
  800b92:	83 ea 37             	sub    $0x37,%edx
  800b95:	eb c1                	jmp    800b58 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b97:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b9b:	74 05                	je     800ba2 <strtol+0xd0>
		*endptr = (char *) s;
  800b9d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba0:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ba2:	89 c2                	mov    %eax,%edx
  800ba4:	f7 da                	neg    %edx
  800ba6:	85 ff                	test   %edi,%edi
  800ba8:	0f 45 c2             	cmovne %edx,%eax
}
  800bab:	5b                   	pop    %ebx
  800bac:	5e                   	pop    %esi
  800bad:	5f                   	pop    %edi
  800bae:	5d                   	pop    %ebp
  800baf:	c3                   	ret    

00800bb0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bb0:	f3 0f 1e fb          	endbr32 
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800bba:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc5:	89 c3                	mov    %eax,%ebx
  800bc7:	89 c7                	mov    %eax,%edi
  800bc9:	89 c6                	mov    %eax,%esi
  800bcb:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5f                   	pop    %edi
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bd2:	f3 0f 1e fb          	endbr32 
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800bdc:	ba 00 00 00 00       	mov    $0x0,%edx
  800be1:	b8 01 00 00 00       	mov    $0x1,%eax
  800be6:	89 d1                	mov    %edx,%ecx
  800be8:	89 d3                	mov    %edx,%ebx
  800bea:	89 d7                	mov    %edx,%edi
  800bec:	89 d6                	mov    %edx,%esi
  800bee:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bf5:	f3 0f 1e fb          	endbr32 
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
  800bff:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c02:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c07:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0a:	b8 03 00 00 00       	mov    $0x3,%eax
  800c0f:	89 cb                	mov    %ecx,%ebx
  800c11:	89 cf                	mov    %ecx,%edi
  800c13:	89 ce                	mov    %ecx,%esi
  800c15:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c17:	85 c0                	test   %eax,%eax
  800c19:	7f 08                	jg     800c23 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1e:	5b                   	pop    %ebx
  800c1f:	5e                   	pop    %esi
  800c20:	5f                   	pop    %edi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c23:	83 ec 0c             	sub    $0xc,%esp
  800c26:	50                   	push   %eax
  800c27:	6a 03                	push   $0x3
  800c29:	68 a4 16 80 00       	push   $0x8016a4
  800c2e:	6a 23                	push   $0x23
  800c30:	68 c1 16 80 00       	push   $0x8016c1
  800c35:	e8 13 f5 ff ff       	call   80014d <_panic>

00800c3a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c3a:	f3 0f 1e fb          	endbr32 
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c44:	ba 00 00 00 00       	mov    $0x0,%edx
  800c49:	b8 02 00 00 00       	mov    $0x2,%eax
  800c4e:	89 d1                	mov    %edx,%ecx
  800c50:	89 d3                	mov    %edx,%ebx
  800c52:	89 d7                	mov    %edx,%edi
  800c54:	89 d6                	mov    %edx,%esi
  800c56:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c58:	5b                   	pop    %ebx
  800c59:	5e                   	pop    %esi
  800c5a:	5f                   	pop    %edi
  800c5b:	5d                   	pop    %ebp
  800c5c:	c3                   	ret    

00800c5d <sys_yield>:

void
sys_yield(void)
{
  800c5d:	f3 0f 1e fb          	endbr32 
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c67:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c71:	89 d1                	mov    %edx,%ecx
  800c73:	89 d3                	mov    %edx,%ebx
  800c75:	89 d7                	mov    %edx,%edi
  800c77:	89 d6                	mov    %edx,%esi
  800c79:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c7b:	5b                   	pop    %ebx
  800c7c:	5e                   	pop    %esi
  800c7d:	5f                   	pop    %edi
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c80:	f3 0f 1e fb          	endbr32 
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	57                   	push   %edi
  800c88:	56                   	push   %esi
  800c89:	53                   	push   %ebx
  800c8a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c8d:	be 00 00 00 00       	mov    $0x0,%esi
  800c92:	8b 55 08             	mov    0x8(%ebp),%edx
  800c95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c98:	b8 04 00 00 00       	mov    $0x4,%eax
  800c9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca0:	89 f7                	mov    %esi,%edi
  800ca2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca4:	85 c0                	test   %eax,%eax
  800ca6:	7f 08                	jg     800cb0 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ca8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cab:	5b                   	pop    %ebx
  800cac:	5e                   	pop    %esi
  800cad:	5f                   	pop    %edi
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb0:	83 ec 0c             	sub    $0xc,%esp
  800cb3:	50                   	push   %eax
  800cb4:	6a 04                	push   $0x4
  800cb6:	68 a4 16 80 00       	push   $0x8016a4
  800cbb:	6a 23                	push   $0x23
  800cbd:	68 c1 16 80 00       	push   $0x8016c1
  800cc2:	e8 86 f4 ff ff       	call   80014d <_panic>

00800cc7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cc7:	f3 0f 1e fb          	endbr32 
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	57                   	push   %edi
  800ccf:	56                   	push   %esi
  800cd0:	53                   	push   %ebx
  800cd1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800cd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cda:	b8 05 00 00 00       	mov    $0x5,%eax
  800cdf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ce5:	8b 75 18             	mov    0x18(%ebp),%esi
  800ce8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cea:	85 c0                	test   %eax,%eax
  800cec:	7f 08                	jg     800cf6 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf6:	83 ec 0c             	sub    $0xc,%esp
  800cf9:	50                   	push   %eax
  800cfa:	6a 05                	push   $0x5
  800cfc:	68 a4 16 80 00       	push   $0x8016a4
  800d01:	6a 23                	push   $0x23
  800d03:	68 c1 16 80 00       	push   $0x8016c1
  800d08:	e8 40 f4 ff ff       	call   80014d <_panic>

00800d0d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d0d:	f3 0f 1e fb          	endbr32 
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	57                   	push   %edi
  800d15:	56                   	push   %esi
  800d16:	53                   	push   %ebx
  800d17:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d1a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d25:	b8 06 00 00 00       	mov    $0x6,%eax
  800d2a:	89 df                	mov    %ebx,%edi
  800d2c:	89 de                	mov    %ebx,%esi
  800d2e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d30:	85 c0                	test   %eax,%eax
  800d32:	7f 08                	jg     800d3c <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3c:	83 ec 0c             	sub    $0xc,%esp
  800d3f:	50                   	push   %eax
  800d40:	6a 06                	push   $0x6
  800d42:	68 a4 16 80 00       	push   $0x8016a4
  800d47:	6a 23                	push   $0x23
  800d49:	68 c1 16 80 00       	push   $0x8016c1
  800d4e:	e8 fa f3 ff ff       	call   80014d <_panic>

00800d53 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d53:	f3 0f 1e fb          	endbr32 
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	57                   	push   %edi
  800d5b:	56                   	push   %esi
  800d5c:	53                   	push   %ebx
  800d5d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d60:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d65:	8b 55 08             	mov    0x8(%ebp),%edx
  800d68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6b:	b8 08 00 00 00       	mov    $0x8,%eax
  800d70:	89 df                	mov    %ebx,%edi
  800d72:	89 de                	mov    %ebx,%esi
  800d74:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d76:	85 c0                	test   %eax,%eax
  800d78:	7f 08                	jg     800d82 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d82:	83 ec 0c             	sub    $0xc,%esp
  800d85:	50                   	push   %eax
  800d86:	6a 08                	push   $0x8
  800d88:	68 a4 16 80 00       	push   $0x8016a4
  800d8d:	6a 23                	push   $0x23
  800d8f:	68 c1 16 80 00       	push   $0x8016c1
  800d94:	e8 b4 f3 ff ff       	call   80014d <_panic>

00800d99 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d99:	f3 0f 1e fb          	endbr32 
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	57                   	push   %edi
  800da1:	56                   	push   %esi
  800da2:	53                   	push   %ebx
  800da3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800da6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dab:	8b 55 08             	mov    0x8(%ebp),%edx
  800dae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db1:	b8 09 00 00 00       	mov    $0x9,%eax
  800db6:	89 df                	mov    %ebx,%edi
  800db8:	89 de                	mov    %ebx,%esi
  800dba:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dbc:	85 c0                	test   %eax,%eax
  800dbe:	7f 08                	jg     800dc8 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc8:	83 ec 0c             	sub    $0xc,%esp
  800dcb:	50                   	push   %eax
  800dcc:	6a 09                	push   $0x9
  800dce:	68 a4 16 80 00       	push   $0x8016a4
  800dd3:	6a 23                	push   $0x23
  800dd5:	68 c1 16 80 00       	push   $0x8016c1
  800dda:	e8 6e f3 ff ff       	call   80014d <_panic>

00800ddf <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ddf:	f3 0f 1e fb          	endbr32 
  800de3:	55                   	push   %ebp
  800de4:	89 e5                	mov    %esp,%ebp
  800de6:	57                   	push   %edi
  800de7:	56                   	push   %esi
  800de8:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800de9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800def:	b8 0b 00 00 00       	mov    $0xb,%eax
  800df4:	be 00 00 00 00       	mov    $0x0,%esi
  800df9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dfc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dff:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e01:	5b                   	pop    %ebx
  800e02:	5e                   	pop    %esi
  800e03:	5f                   	pop    %edi
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    

00800e06 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e06:	f3 0f 1e fb          	endbr32 
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
  800e10:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800e13:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e18:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e20:	89 cb                	mov    %ecx,%ebx
  800e22:	89 cf                	mov    %ecx,%edi
  800e24:	89 ce                	mov    %ecx,%esi
  800e26:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e28:	85 c0                	test   %eax,%eax
  800e2a:	7f 08                	jg     800e34 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e2f:	5b                   	pop    %ebx
  800e30:	5e                   	pop    %esi
  800e31:	5f                   	pop    %edi
  800e32:	5d                   	pop    %ebp
  800e33:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e34:	83 ec 0c             	sub    $0xc,%esp
  800e37:	50                   	push   %eax
  800e38:	6a 0c                	push   $0xc
  800e3a:	68 a4 16 80 00       	push   $0x8016a4
  800e3f:	6a 23                	push   $0x23
  800e41:	68 c1 16 80 00       	push   $0x8016c1
  800e46:	e8 02 f3 ff ff       	call   80014d <_panic>

00800e4b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e4b:	f3 0f 1e fb          	endbr32 
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	53                   	push   %ebx
  800e53:	83 ec 04             	sub    $0x4,%esp
  800e56:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e59:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpt[PGNUM(addr)] & PTE_COW))) { 
  800e5b:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e5f:	74 74                	je     800ed5 <pgfault+0x8a>
  800e61:	89 d8                	mov    %ebx,%eax
  800e63:	c1 e8 0c             	shr    $0xc,%eax
  800e66:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e6d:	f6 c4 08             	test   $0x8,%ah
  800e70:	74 63                	je     800ed5 <pgfault+0x8a>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  800e72:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_map(0, addr, 0, PFTEMP, PTE_U|PTE_P)) < 0)		
  800e78:	83 ec 0c             	sub    $0xc,%esp
  800e7b:	6a 05                	push   $0x5
  800e7d:	68 00 f0 7f 00       	push   $0x7ff000
  800e82:	6a 00                	push   $0x0
  800e84:	53                   	push   %ebx
  800e85:	6a 00                	push   $0x0
  800e87:	e8 3b fe ff ff       	call   800cc7 <sys_page_map>
  800e8c:	83 c4 20             	add    $0x20,%esp
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	78 56                	js     800ee9 <pgfault+0x9e>
		panic("sys_page_map: %e", r);
	if ((r = sys_page_alloc(0, addr, PTE_P|PTE_U|PTE_W)) < 0)	
  800e93:	83 ec 04             	sub    $0x4,%esp
  800e96:	6a 07                	push   $0x7
  800e98:	53                   	push   %ebx
  800e99:	6a 00                	push   $0x0
  800e9b:	e8 e0 fd ff ff       	call   800c80 <sys_page_alloc>
  800ea0:	83 c4 10             	add    $0x10,%esp
  800ea3:	85 c0                	test   %eax,%eax
  800ea5:	78 54                	js     800efb <pgfault+0xb0>
		panic("sys_page_alloc: %e", r);
	memmove(addr, PFTEMP, PGSIZE);							
  800ea7:	83 ec 04             	sub    $0x4,%esp
  800eaa:	68 00 10 00 00       	push   $0x1000
  800eaf:	68 00 f0 7f 00       	push   $0x7ff000
  800eb4:	53                   	push   %ebx
  800eb5:	e8 3a fb ff ff       	call   8009f4 <memmove>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)				
  800eba:	83 c4 08             	add    $0x8,%esp
  800ebd:	68 00 f0 7f 00       	push   $0x7ff000
  800ec2:	6a 00                	push   $0x0
  800ec4:	e8 44 fe ff ff       	call   800d0d <sys_page_unmap>
  800ec9:	83 c4 10             	add    $0x10,%esp
  800ecc:	85 c0                	test   %eax,%eax
  800ece:	78 3d                	js     800f0d <pgfault+0xc2>
		panic("sys_page_unmap: %e", r);
}
  800ed0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ed3:	c9                   	leave  
  800ed4:	c3                   	ret    
		panic("pgfault():not cow");
  800ed5:	83 ec 04             	sub    $0x4,%esp
  800ed8:	68 cf 16 80 00       	push   $0x8016cf
  800edd:	6a 1d                	push   $0x1d
  800edf:	68 e1 16 80 00       	push   $0x8016e1
  800ee4:	e8 64 f2 ff ff       	call   80014d <_panic>
		panic("sys_page_map: %e", r);
  800ee9:	50                   	push   %eax
  800eea:	68 ec 16 80 00       	push   $0x8016ec
  800eef:	6a 2a                	push   $0x2a
  800ef1:	68 e1 16 80 00       	push   $0x8016e1
  800ef6:	e8 52 f2 ff ff       	call   80014d <_panic>
		panic("sys_page_alloc: %e", r);
  800efb:	50                   	push   %eax
  800efc:	68 fd 16 80 00       	push   $0x8016fd
  800f01:	6a 2c                	push   $0x2c
  800f03:	68 e1 16 80 00       	push   $0x8016e1
  800f08:	e8 40 f2 ff ff       	call   80014d <_panic>
		panic("sys_page_unmap: %e", r);
  800f0d:	50                   	push   %eax
  800f0e:	68 10 17 80 00       	push   $0x801710
  800f13:	6a 2f                	push   $0x2f
  800f15:	68 e1 16 80 00       	push   $0x8016e1
  800f1a:	e8 2e f2 ff ff       	call   80014d <_panic>

00800f1f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f1f:	f3 0f 1e fb          	endbr32 
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	57                   	push   %edi
  800f27:	56                   	push   %esi
  800f28:	53                   	push   %ebx
  800f29:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	extern void _pgfault_upcall(void);
	set_pgfault_handler(pgfault);	
  800f2c:	68 4b 0e 80 00       	push   $0x800e4b
  800f31:	e8 b6 01 00 00       	call   8010ec <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f36:	b8 07 00 00 00       	mov    $0x7,%eax
  800f3b:	cd 30                	int    $0x30
  800f3d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();	
	if (envid == 0) {				
  800f40:	83 c4 10             	add    $0x10,%esp
  800f43:	85 c0                	test   %eax,%eax
  800f45:	74 12                	je     800f59 <fork+0x3a>
  800f47:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	if (envid < 0) {
  800f49:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f4d:	78 29                	js     800f78 <fork+0x59>
		panic("sys_exofork: %e", envid);
	}

	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  800f4f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f54:	e9 80 00 00 00       	jmp    800fd9 <fork+0xba>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f59:	e8 dc fc ff ff       	call   800c3a <sys_getenvid>
  800f5e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f63:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  800f69:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f6e:	a3 60 40 80 00       	mov    %eax,0x804060
		return 0;
  800f73:	e9 27 01 00 00       	jmp    80109f <fork+0x180>
		panic("sys_exofork: %e", envid);
  800f78:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f7b:	68 23 17 80 00       	push   $0x801723
  800f80:	6a 6b                	push   $0x6b
  800f82:	68 e1 16 80 00       	push   $0x8016e1
  800f87:	e8 c1 f1 ff ff       	call   80014d <_panic>
		if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800f8c:	83 ec 0c             	sub    $0xc,%esp
  800f8f:	68 05 08 00 00       	push   $0x805
  800f94:	56                   	push   %esi
  800f95:	57                   	push   %edi
  800f96:	56                   	push   %esi
  800f97:	6a 00                	push   $0x0
  800f99:	e8 29 fd ff ff       	call   800cc7 <sys_page_map>
  800f9e:	83 c4 20             	add    $0x20,%esp
  800fa1:	85 c0                	test   %eax,%eax
  800fa3:	0f 88 96 00 00 00    	js     80103f <fork+0x120>
		if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800fa9:	83 ec 0c             	sub    $0xc,%esp
  800fac:	68 05 08 00 00       	push   $0x805
  800fb1:	56                   	push   %esi
  800fb2:	6a 00                	push   $0x0
  800fb4:	56                   	push   %esi
  800fb5:	6a 00                	push   $0x0
  800fb7:	e8 0b fd ff ff       	call   800cc7 <sys_page_map>
  800fbc:	83 c4 20             	add    $0x20,%esp
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	0f 88 8a 00 00 00    	js     801051 <fork+0x132>
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  800fc7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fcd:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fd3:	0f 84 8a 00 00 00    	je     801063 <fork+0x144>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) 
  800fd9:	89 d8                	mov    %ebx,%eax
  800fdb:	c1 e8 16             	shr    $0x16,%eax
  800fde:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fe5:	a8 01                	test   $0x1,%al
  800fe7:	74 de                	je     800fc7 <fork+0xa8>
  800fe9:	89 d8                	mov    %ebx,%eax
  800feb:	c1 e8 0c             	shr    $0xc,%eax
  800fee:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ff5:	f6 c2 01             	test   $0x1,%dl
  800ff8:	74 cd                	je     800fc7 <fork+0xa8>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  800ffa:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801001:	f6 c2 04             	test   $0x4,%dl
  801004:	74 c1                	je     800fc7 <fork+0xa8>
	void *addr = (void*) (pn * PGSIZE);
  801006:	89 c6                	mov    %eax,%esi
  801008:	c1 e6 0c             	shl    $0xc,%esi
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) { 
  80100b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801012:	f6 c2 02             	test   $0x2,%dl
  801015:	0f 85 71 ff ff ff    	jne    800f8c <fork+0x6d>
  80101b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801022:	f6 c4 08             	test   $0x8,%ah
  801025:	0f 85 61 ff ff ff    	jne    800f8c <fork+0x6d>
		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);	
  80102b:	83 ec 0c             	sub    $0xc,%esp
  80102e:	6a 05                	push   $0x5
  801030:	56                   	push   %esi
  801031:	57                   	push   %edi
  801032:	56                   	push   %esi
  801033:	6a 00                	push   $0x0
  801035:	e8 8d fc ff ff       	call   800cc7 <sys_page_map>
  80103a:	83 c4 20             	add    $0x20,%esp
  80103d:	eb 88                	jmp    800fc7 <fork+0xa8>
			panic("sys_page_map：%e", r);
  80103f:	50                   	push   %eax
  801040:	68 33 17 80 00       	push   $0x801733
  801045:	6a 46                	push   $0x46
  801047:	68 e1 16 80 00       	push   $0x8016e1
  80104c:	e8 fc f0 ff ff       	call   80014d <_panic>
			panic("sys_page_map：%e", r);
  801051:	50                   	push   %eax
  801052:	68 33 17 80 00       	push   $0x801733
  801057:	6a 48                	push   $0x48
  801059:	68 e1 16 80 00       	push   $0x8016e1
  80105e:	e8 ea f0 ff ff       	call   80014d <_panic>
			duppage(envid, PGNUM(addr));	
		}
	}
	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)	
  801063:	83 ec 04             	sub    $0x4,%esp
  801066:	6a 07                	push   $0x7
  801068:	68 00 f0 bf ee       	push   $0xeebff000
  80106d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801070:	e8 0b fc ff ff       	call   800c80 <sys_page_alloc>
  801075:	83 c4 10             	add    $0x10,%esp
  801078:	85 c0                	test   %eax,%eax
  80107a:	78 2e                	js     8010aa <fork+0x18b>
		panic("sys_page_alloc: %e", r);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);		
  80107c:	83 ec 08             	sub    $0x8,%esp
  80107f:	68 49 11 80 00       	push   $0x801149
  801084:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801087:	57                   	push   %edi
  801088:	e8 0c fd ff ff       	call   800d99 <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)	
  80108d:	83 c4 08             	add    $0x8,%esp
  801090:	6a 02                	push   $0x2
  801092:	57                   	push   %edi
  801093:	e8 bb fc ff ff       	call   800d53 <sys_env_set_status>
  801098:	83 c4 10             	add    $0x10,%esp
  80109b:	85 c0                	test   %eax,%eax
  80109d:	78 1d                	js     8010bc <fork+0x19d>
		panic("sys_env_set_status: %e", r);
	return envid;
}
  80109f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a5:	5b                   	pop    %ebx
  8010a6:	5e                   	pop    %esi
  8010a7:	5f                   	pop    %edi
  8010a8:	5d                   	pop    %ebp
  8010a9:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  8010aa:	50                   	push   %eax
  8010ab:	68 fd 16 80 00       	push   $0x8016fd
  8010b0:	6a 77                	push   $0x77
  8010b2:	68 e1 16 80 00       	push   $0x8016e1
  8010b7:	e8 91 f0 ff ff       	call   80014d <_panic>
		panic("sys_env_set_status: %e", r);
  8010bc:	50                   	push   %eax
  8010bd:	68 45 17 80 00       	push   $0x801745
  8010c2:	6a 7b                	push   $0x7b
  8010c4:	68 e1 16 80 00       	push   $0x8016e1
  8010c9:	e8 7f f0 ff ff       	call   80014d <_panic>

008010ce <sfork>:

// Challenge!
int
sfork(void)
{
  8010ce:	f3 0f 1e fb          	endbr32 
  8010d2:	55                   	push   %ebp
  8010d3:	89 e5                	mov    %esp,%ebp
  8010d5:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010d8:	68 5c 17 80 00       	push   $0x80175c
  8010dd:	68 83 00 00 00       	push   $0x83
  8010e2:	68 e1 16 80 00       	push   $0x8016e1
  8010e7:	e8 61 f0 ff ff       	call   80014d <_panic>

008010ec <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8010ec:	f3 0f 1e fb          	endbr32 
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8010f6:	83 3d 64 40 80 00 00 	cmpl   $0x0,0x804064
  8010fd:	74 0a                	je     801109 <set_pgfault_handler+0x1d>
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);		//系统调用，设置进程的env_pgfault_upcall属性
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8010ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801102:	a3 64 40 80 00       	mov    %eax,0x804064
}
  801107:	c9                   	leave  
  801108:	c3                   	ret    
		int r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_W | PTE_U | PTE_P);	//为当前进程分配异常栈
  801109:	83 ec 04             	sub    $0x4,%esp
  80110c:	6a 07                	push   $0x7
  80110e:	68 00 f0 bf ee       	push   $0xeebff000
  801113:	6a 00                	push   $0x0
  801115:	e8 66 fb ff ff       	call   800c80 <sys_page_alloc>
		if (r < 0) {
  80111a:	83 c4 10             	add    $0x10,%esp
  80111d:	85 c0                	test   %eax,%eax
  80111f:	78 14                	js     801135 <set_pgfault_handler+0x49>
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);		//系统调用，设置进程的env_pgfault_upcall属性
  801121:	83 ec 08             	sub    $0x8,%esp
  801124:	68 49 11 80 00       	push   $0x801149
  801129:	6a 00                	push   $0x0
  80112b:	e8 69 fc ff ff       	call   800d99 <sys_env_set_pgfault_upcall>
  801130:	83 c4 10             	add    $0x10,%esp
  801133:	eb ca                	jmp    8010ff <set_pgfault_handler+0x13>
			panic("set_pgfault_handler:sys_page_alloc failed");;
  801135:	83 ec 04             	sub    $0x4,%esp
  801138:	68 74 17 80 00       	push   $0x801774
  80113d:	6a 22                	push   $0x22
  80113f:	68 9e 17 80 00       	push   $0x80179e
  801144:	e8 04 f0 ff ff       	call   80014d <_panic>

00801149 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801149:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80114a:	a1 64 40 80 00       	mov    0x804064,%eax
	call *%eax				
  80114f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801151:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp			
  801154:	83 c4 08             	add    $0x8,%esp
	movl 40(%esp), %eax 	
  801157:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 32(%esp), %ecx 	
  80115b:	8b 4c 24 20          	mov    0x20(%esp),%ecx
	movl %ecx, -4(%eax) 	
  80115f:	89 48 fc             	mov    %ecx,-0x4(%eax)
	popal
  801162:	61                   	popa   
	addl $4, %esp		
  801163:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popfl
  801166:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801167:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	lea -4(%esp), %esp	
  801168:	8d 64 24 fc          	lea    -0x4(%esp),%esp
	ret
  80116c:	c3                   	ret    
  80116d:	66 90                	xchg   %ax,%ax
  80116f:	90                   	nop

00801170 <__udivdi3>:
  801170:	f3 0f 1e fb          	endbr32 
  801174:	55                   	push   %ebp
  801175:	57                   	push   %edi
  801176:	56                   	push   %esi
  801177:	53                   	push   %ebx
  801178:	83 ec 1c             	sub    $0x1c,%esp
  80117b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80117f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801183:	8b 74 24 34          	mov    0x34(%esp),%esi
  801187:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80118b:	85 d2                	test   %edx,%edx
  80118d:	75 19                	jne    8011a8 <__udivdi3+0x38>
  80118f:	39 f3                	cmp    %esi,%ebx
  801191:	76 4d                	jbe    8011e0 <__udivdi3+0x70>
  801193:	31 ff                	xor    %edi,%edi
  801195:	89 e8                	mov    %ebp,%eax
  801197:	89 f2                	mov    %esi,%edx
  801199:	f7 f3                	div    %ebx
  80119b:	89 fa                	mov    %edi,%edx
  80119d:	83 c4 1c             	add    $0x1c,%esp
  8011a0:	5b                   	pop    %ebx
  8011a1:	5e                   	pop    %esi
  8011a2:	5f                   	pop    %edi
  8011a3:	5d                   	pop    %ebp
  8011a4:	c3                   	ret    
  8011a5:	8d 76 00             	lea    0x0(%esi),%esi
  8011a8:	39 f2                	cmp    %esi,%edx
  8011aa:	76 14                	jbe    8011c0 <__udivdi3+0x50>
  8011ac:	31 ff                	xor    %edi,%edi
  8011ae:	31 c0                	xor    %eax,%eax
  8011b0:	89 fa                	mov    %edi,%edx
  8011b2:	83 c4 1c             	add    $0x1c,%esp
  8011b5:	5b                   	pop    %ebx
  8011b6:	5e                   	pop    %esi
  8011b7:	5f                   	pop    %edi
  8011b8:	5d                   	pop    %ebp
  8011b9:	c3                   	ret    
  8011ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011c0:	0f bd fa             	bsr    %edx,%edi
  8011c3:	83 f7 1f             	xor    $0x1f,%edi
  8011c6:	75 48                	jne    801210 <__udivdi3+0xa0>
  8011c8:	39 f2                	cmp    %esi,%edx
  8011ca:	72 06                	jb     8011d2 <__udivdi3+0x62>
  8011cc:	31 c0                	xor    %eax,%eax
  8011ce:	39 eb                	cmp    %ebp,%ebx
  8011d0:	77 de                	ja     8011b0 <__udivdi3+0x40>
  8011d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8011d7:	eb d7                	jmp    8011b0 <__udivdi3+0x40>
  8011d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011e0:	89 d9                	mov    %ebx,%ecx
  8011e2:	85 db                	test   %ebx,%ebx
  8011e4:	75 0b                	jne    8011f1 <__udivdi3+0x81>
  8011e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8011eb:	31 d2                	xor    %edx,%edx
  8011ed:	f7 f3                	div    %ebx
  8011ef:	89 c1                	mov    %eax,%ecx
  8011f1:	31 d2                	xor    %edx,%edx
  8011f3:	89 f0                	mov    %esi,%eax
  8011f5:	f7 f1                	div    %ecx
  8011f7:	89 c6                	mov    %eax,%esi
  8011f9:	89 e8                	mov    %ebp,%eax
  8011fb:	89 f7                	mov    %esi,%edi
  8011fd:	f7 f1                	div    %ecx
  8011ff:	89 fa                	mov    %edi,%edx
  801201:	83 c4 1c             	add    $0x1c,%esp
  801204:	5b                   	pop    %ebx
  801205:	5e                   	pop    %esi
  801206:	5f                   	pop    %edi
  801207:	5d                   	pop    %ebp
  801208:	c3                   	ret    
  801209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801210:	89 f9                	mov    %edi,%ecx
  801212:	b8 20 00 00 00       	mov    $0x20,%eax
  801217:	29 f8                	sub    %edi,%eax
  801219:	d3 e2                	shl    %cl,%edx
  80121b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80121f:	89 c1                	mov    %eax,%ecx
  801221:	89 da                	mov    %ebx,%edx
  801223:	d3 ea                	shr    %cl,%edx
  801225:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801229:	09 d1                	or     %edx,%ecx
  80122b:	89 f2                	mov    %esi,%edx
  80122d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801231:	89 f9                	mov    %edi,%ecx
  801233:	d3 e3                	shl    %cl,%ebx
  801235:	89 c1                	mov    %eax,%ecx
  801237:	d3 ea                	shr    %cl,%edx
  801239:	89 f9                	mov    %edi,%ecx
  80123b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80123f:	89 eb                	mov    %ebp,%ebx
  801241:	d3 e6                	shl    %cl,%esi
  801243:	89 c1                	mov    %eax,%ecx
  801245:	d3 eb                	shr    %cl,%ebx
  801247:	09 de                	or     %ebx,%esi
  801249:	89 f0                	mov    %esi,%eax
  80124b:	f7 74 24 08          	divl   0x8(%esp)
  80124f:	89 d6                	mov    %edx,%esi
  801251:	89 c3                	mov    %eax,%ebx
  801253:	f7 64 24 0c          	mull   0xc(%esp)
  801257:	39 d6                	cmp    %edx,%esi
  801259:	72 15                	jb     801270 <__udivdi3+0x100>
  80125b:	89 f9                	mov    %edi,%ecx
  80125d:	d3 e5                	shl    %cl,%ebp
  80125f:	39 c5                	cmp    %eax,%ebp
  801261:	73 04                	jae    801267 <__udivdi3+0xf7>
  801263:	39 d6                	cmp    %edx,%esi
  801265:	74 09                	je     801270 <__udivdi3+0x100>
  801267:	89 d8                	mov    %ebx,%eax
  801269:	31 ff                	xor    %edi,%edi
  80126b:	e9 40 ff ff ff       	jmp    8011b0 <__udivdi3+0x40>
  801270:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801273:	31 ff                	xor    %edi,%edi
  801275:	e9 36 ff ff ff       	jmp    8011b0 <__udivdi3+0x40>
  80127a:	66 90                	xchg   %ax,%ax
  80127c:	66 90                	xchg   %ax,%ax
  80127e:	66 90                	xchg   %ax,%ax

00801280 <__umoddi3>:
  801280:	f3 0f 1e fb          	endbr32 
  801284:	55                   	push   %ebp
  801285:	57                   	push   %edi
  801286:	56                   	push   %esi
  801287:	53                   	push   %ebx
  801288:	83 ec 1c             	sub    $0x1c,%esp
  80128b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80128f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801293:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801297:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80129b:	85 c0                	test   %eax,%eax
  80129d:	75 19                	jne    8012b8 <__umoddi3+0x38>
  80129f:	39 df                	cmp    %ebx,%edi
  8012a1:	76 5d                	jbe    801300 <__umoddi3+0x80>
  8012a3:	89 f0                	mov    %esi,%eax
  8012a5:	89 da                	mov    %ebx,%edx
  8012a7:	f7 f7                	div    %edi
  8012a9:	89 d0                	mov    %edx,%eax
  8012ab:	31 d2                	xor    %edx,%edx
  8012ad:	83 c4 1c             	add    $0x1c,%esp
  8012b0:	5b                   	pop    %ebx
  8012b1:	5e                   	pop    %esi
  8012b2:	5f                   	pop    %edi
  8012b3:	5d                   	pop    %ebp
  8012b4:	c3                   	ret    
  8012b5:	8d 76 00             	lea    0x0(%esi),%esi
  8012b8:	89 f2                	mov    %esi,%edx
  8012ba:	39 d8                	cmp    %ebx,%eax
  8012bc:	76 12                	jbe    8012d0 <__umoddi3+0x50>
  8012be:	89 f0                	mov    %esi,%eax
  8012c0:	89 da                	mov    %ebx,%edx
  8012c2:	83 c4 1c             	add    $0x1c,%esp
  8012c5:	5b                   	pop    %ebx
  8012c6:	5e                   	pop    %esi
  8012c7:	5f                   	pop    %edi
  8012c8:	5d                   	pop    %ebp
  8012c9:	c3                   	ret    
  8012ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012d0:	0f bd e8             	bsr    %eax,%ebp
  8012d3:	83 f5 1f             	xor    $0x1f,%ebp
  8012d6:	75 50                	jne    801328 <__umoddi3+0xa8>
  8012d8:	39 d8                	cmp    %ebx,%eax
  8012da:	0f 82 e0 00 00 00    	jb     8013c0 <__umoddi3+0x140>
  8012e0:	89 d9                	mov    %ebx,%ecx
  8012e2:	39 f7                	cmp    %esi,%edi
  8012e4:	0f 86 d6 00 00 00    	jbe    8013c0 <__umoddi3+0x140>
  8012ea:	89 d0                	mov    %edx,%eax
  8012ec:	89 ca                	mov    %ecx,%edx
  8012ee:	83 c4 1c             	add    $0x1c,%esp
  8012f1:	5b                   	pop    %ebx
  8012f2:	5e                   	pop    %esi
  8012f3:	5f                   	pop    %edi
  8012f4:	5d                   	pop    %ebp
  8012f5:	c3                   	ret    
  8012f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012fd:	8d 76 00             	lea    0x0(%esi),%esi
  801300:	89 fd                	mov    %edi,%ebp
  801302:	85 ff                	test   %edi,%edi
  801304:	75 0b                	jne    801311 <__umoddi3+0x91>
  801306:	b8 01 00 00 00       	mov    $0x1,%eax
  80130b:	31 d2                	xor    %edx,%edx
  80130d:	f7 f7                	div    %edi
  80130f:	89 c5                	mov    %eax,%ebp
  801311:	89 d8                	mov    %ebx,%eax
  801313:	31 d2                	xor    %edx,%edx
  801315:	f7 f5                	div    %ebp
  801317:	89 f0                	mov    %esi,%eax
  801319:	f7 f5                	div    %ebp
  80131b:	89 d0                	mov    %edx,%eax
  80131d:	31 d2                	xor    %edx,%edx
  80131f:	eb 8c                	jmp    8012ad <__umoddi3+0x2d>
  801321:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801328:	89 e9                	mov    %ebp,%ecx
  80132a:	ba 20 00 00 00       	mov    $0x20,%edx
  80132f:	29 ea                	sub    %ebp,%edx
  801331:	d3 e0                	shl    %cl,%eax
  801333:	89 44 24 08          	mov    %eax,0x8(%esp)
  801337:	89 d1                	mov    %edx,%ecx
  801339:	89 f8                	mov    %edi,%eax
  80133b:	d3 e8                	shr    %cl,%eax
  80133d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801341:	89 54 24 04          	mov    %edx,0x4(%esp)
  801345:	8b 54 24 04          	mov    0x4(%esp),%edx
  801349:	09 c1                	or     %eax,%ecx
  80134b:	89 d8                	mov    %ebx,%eax
  80134d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801351:	89 e9                	mov    %ebp,%ecx
  801353:	d3 e7                	shl    %cl,%edi
  801355:	89 d1                	mov    %edx,%ecx
  801357:	d3 e8                	shr    %cl,%eax
  801359:	89 e9                	mov    %ebp,%ecx
  80135b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80135f:	d3 e3                	shl    %cl,%ebx
  801361:	89 c7                	mov    %eax,%edi
  801363:	89 d1                	mov    %edx,%ecx
  801365:	89 f0                	mov    %esi,%eax
  801367:	d3 e8                	shr    %cl,%eax
  801369:	89 e9                	mov    %ebp,%ecx
  80136b:	89 fa                	mov    %edi,%edx
  80136d:	d3 e6                	shl    %cl,%esi
  80136f:	09 d8                	or     %ebx,%eax
  801371:	f7 74 24 08          	divl   0x8(%esp)
  801375:	89 d1                	mov    %edx,%ecx
  801377:	89 f3                	mov    %esi,%ebx
  801379:	f7 64 24 0c          	mull   0xc(%esp)
  80137d:	89 c6                	mov    %eax,%esi
  80137f:	89 d7                	mov    %edx,%edi
  801381:	39 d1                	cmp    %edx,%ecx
  801383:	72 06                	jb     80138b <__umoddi3+0x10b>
  801385:	75 10                	jne    801397 <__umoddi3+0x117>
  801387:	39 c3                	cmp    %eax,%ebx
  801389:	73 0c                	jae    801397 <__umoddi3+0x117>
  80138b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80138f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801393:	89 d7                	mov    %edx,%edi
  801395:	89 c6                	mov    %eax,%esi
  801397:	89 ca                	mov    %ecx,%edx
  801399:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80139e:	29 f3                	sub    %esi,%ebx
  8013a0:	19 fa                	sbb    %edi,%edx
  8013a2:	89 d0                	mov    %edx,%eax
  8013a4:	d3 e0                	shl    %cl,%eax
  8013a6:	89 e9                	mov    %ebp,%ecx
  8013a8:	d3 eb                	shr    %cl,%ebx
  8013aa:	d3 ea                	shr    %cl,%edx
  8013ac:	09 d8                	or     %ebx,%eax
  8013ae:	83 c4 1c             	add    $0x1c,%esp
  8013b1:	5b                   	pop    %ebx
  8013b2:	5e                   	pop    %esi
  8013b3:	5f                   	pop    %edi
  8013b4:	5d                   	pop    %ebp
  8013b5:	c3                   	ret    
  8013b6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013bd:	8d 76 00             	lea    0x0(%esi),%esi
  8013c0:	29 fe                	sub    %edi,%esi
  8013c2:	19 c3                	sbb    %eax,%ebx
  8013c4:	89 f2                	mov    %esi,%edx
  8013c6:	89 d9                	mov    %ebx,%ecx
  8013c8:	e9 1d ff ff ff       	jmp    8012ea <__umoddi3+0x6a>
