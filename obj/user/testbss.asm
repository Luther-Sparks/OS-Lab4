
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 af 00 00 00       	call   8000e0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  80003d:	68 c0 10 80 00       	push   $0x8010c0
  800042:	e8 e3 01 00 00       	call   80022a <cprintf>
  800047:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  80004a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004f:	83 3c 85 60 20 80 00 	cmpl   $0x0,0x802060(,%eax,4)
  800056:	00 
  800057:	75 63                	jne    8000bc <umain+0x89>
	for (i = 0; i < ARRAYSIZE; i++)
  800059:	83 c0 01             	add    $0x1,%eax
  80005c:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800061:	75 ec                	jne    80004f <umain+0x1c>
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  800063:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
  800068:	89 04 85 60 20 80 00 	mov    %eax,0x802060(,%eax,4)
	for (i = 0; i < ARRAYSIZE; i++)
  80006f:	83 c0 01             	add    $0x1,%eax
  800072:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800077:	75 ef                	jne    800068 <umain+0x35>
	for (i = 0; i < ARRAYSIZE; i++)
  800079:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != i)
  80007e:	39 04 85 60 20 80 00 	cmp    %eax,0x802060(,%eax,4)
  800085:	75 47                	jne    8000ce <umain+0x9b>
	for (i = 0; i < ARRAYSIZE; i++)
  800087:	83 c0 01             	add    $0x1,%eax
  80008a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008f:	75 ed                	jne    80007e <umain+0x4b>
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  800091:	83 ec 0c             	sub    $0xc,%esp
  800094:	68 08 11 80 00       	push   $0x801108
  800099:	e8 8c 01 00 00       	call   80022a <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  80009e:	c7 05 60 30 c0 00 00 	movl   $0x0,0xc03060
  8000a5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000a8:	83 c4 0c             	add    $0xc,%esp
  8000ab:	68 67 11 80 00       	push   $0x801167
  8000b0:	6a 1a                	push   $0x1a
  8000b2:	68 58 11 80 00       	push   $0x801158
  8000b7:	e8 87 00 00 00       	call   800143 <_panic>
			panic("bigarray[%d] isn't cleared!\n", i);
  8000bc:	50                   	push   %eax
  8000bd:	68 3b 11 80 00       	push   $0x80113b
  8000c2:	6a 11                	push   $0x11
  8000c4:	68 58 11 80 00       	push   $0x801158
  8000c9:	e8 75 00 00 00       	call   800143 <_panic>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000ce:	50                   	push   %eax
  8000cf:	68 e0 10 80 00       	push   $0x8010e0
  8000d4:	6a 16                	push   $0x16
  8000d6:	68 58 11 80 00       	push   $0x801158
  8000db:	e8 63 00 00 00       	call   800143 <_panic>

008000e0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e0:	f3 0f 1e fb          	endbr32 
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8000ef:	e8 3c 0b 00 00       	call   800c30 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  8000f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f9:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  8000ff:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800104:	a3 60 40 c0 00       	mov    %eax,0xc04060

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800109:	85 db                	test   %ebx,%ebx
  80010b:	7e 07                	jle    800114 <libmain+0x34>
		binaryname = argv[0];
  80010d:	8b 06                	mov    (%esi),%eax
  80010f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800114:	83 ec 08             	sub    $0x8,%esp
  800117:	56                   	push   %esi
  800118:	53                   	push   %ebx
  800119:	e8 15 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80011e:	e8 0a 00 00 00       	call   80012d <exit>
}
  800123:	83 c4 10             	add    $0x10,%esp
  800126:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800129:	5b                   	pop    %ebx
  80012a:	5e                   	pop    %esi
  80012b:	5d                   	pop    %ebp
  80012c:	c3                   	ret    

0080012d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80012d:	f3 0f 1e fb          	endbr32 
  800131:	55                   	push   %ebp
  800132:	89 e5                	mov    %esp,%ebp
  800134:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800137:	6a 00                	push   $0x0
  800139:	e8 ad 0a 00 00       	call   800beb <sys_env_destroy>
}
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800143:	f3 0f 1e fb          	endbr32 
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	56                   	push   %esi
  80014b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80014c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800155:	e8 d6 0a 00 00       	call   800c30 <sys_getenvid>
  80015a:	83 ec 0c             	sub    $0xc,%esp
  80015d:	ff 75 0c             	pushl  0xc(%ebp)
  800160:	ff 75 08             	pushl  0x8(%ebp)
  800163:	56                   	push   %esi
  800164:	50                   	push   %eax
  800165:	68 88 11 80 00       	push   $0x801188
  80016a:	e8 bb 00 00 00       	call   80022a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80016f:	83 c4 18             	add    $0x18,%esp
  800172:	53                   	push   %ebx
  800173:	ff 75 10             	pushl  0x10(%ebp)
  800176:	e8 5a 00 00 00       	call   8001d5 <vcprintf>
	cprintf("\n");
  80017b:	c7 04 24 56 11 80 00 	movl   $0x801156,(%esp)
  800182:	e8 a3 00 00 00       	call   80022a <cprintf>
  800187:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80018a:	cc                   	int3   
  80018b:	eb fd                	jmp    80018a <_panic+0x47>

0080018d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80018d:	f3 0f 1e fb          	endbr32 
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	53                   	push   %ebx
  800195:	83 ec 04             	sub    $0x4,%esp
  800198:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019b:	8b 13                	mov    (%ebx),%edx
  80019d:	8d 42 01             	lea    0x1(%edx),%eax
  8001a0:	89 03                	mov    %eax,(%ebx)
  8001a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ae:	74 09                	je     8001b9 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001b0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b7:	c9                   	leave  
  8001b8:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001b9:	83 ec 08             	sub    $0x8,%esp
  8001bc:	68 ff 00 00 00       	push   $0xff
  8001c1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c4:	50                   	push   %eax
  8001c5:	e8 dc 09 00 00       	call   800ba6 <sys_cputs>
		b->idx = 0;
  8001ca:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d0:	83 c4 10             	add    $0x10,%esp
  8001d3:	eb db                	jmp    8001b0 <putch+0x23>

008001d5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d5:	f3 0f 1e fb          	endbr32 
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e9:	00 00 00 
	b.cnt = 0;
  8001ec:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f6:	ff 75 0c             	pushl  0xc(%ebp)
  8001f9:	ff 75 08             	pushl  0x8(%ebp)
  8001fc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800202:	50                   	push   %eax
  800203:	68 8d 01 80 00       	push   $0x80018d
  800208:	e8 20 01 00 00       	call   80032d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80020d:	83 c4 08             	add    $0x8,%esp
  800210:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800216:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80021c:	50                   	push   %eax
  80021d:	e8 84 09 00 00       	call   800ba6 <sys_cputs>

	return b.cnt;
}
  800222:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800228:	c9                   	leave  
  800229:	c3                   	ret    

0080022a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80022a:	f3 0f 1e fb          	endbr32 
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
  800231:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800234:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800237:	50                   	push   %eax
  800238:	ff 75 08             	pushl  0x8(%ebp)
  80023b:	e8 95 ff ff ff       	call   8001d5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800240:	c9                   	leave  
  800241:	c3                   	ret    

00800242 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800242:	55                   	push   %ebp
  800243:	89 e5                	mov    %esp,%ebp
  800245:	57                   	push   %edi
  800246:	56                   	push   %esi
  800247:	53                   	push   %ebx
  800248:	83 ec 1c             	sub    $0x1c,%esp
  80024b:	89 c7                	mov    %eax,%edi
  80024d:	89 d6                	mov    %edx,%esi
  80024f:	8b 45 08             	mov    0x8(%ebp),%eax
  800252:	8b 55 0c             	mov    0xc(%ebp),%edx
  800255:	89 d1                	mov    %edx,%ecx
  800257:	89 c2                	mov    %eax,%edx
  800259:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80025f:	8b 45 10             	mov    0x10(%ebp),%eax
  800262:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800265:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800268:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80026f:	39 c2                	cmp    %eax,%edx
  800271:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800274:	72 3e                	jb     8002b4 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800276:	83 ec 0c             	sub    $0xc,%esp
  800279:	ff 75 18             	pushl  0x18(%ebp)
  80027c:	83 eb 01             	sub    $0x1,%ebx
  80027f:	53                   	push   %ebx
  800280:	50                   	push   %eax
  800281:	83 ec 08             	sub    $0x8,%esp
  800284:	ff 75 e4             	pushl  -0x1c(%ebp)
  800287:	ff 75 e0             	pushl  -0x20(%ebp)
  80028a:	ff 75 dc             	pushl  -0x24(%ebp)
  80028d:	ff 75 d8             	pushl  -0x28(%ebp)
  800290:	e8 bb 0b 00 00       	call   800e50 <__udivdi3>
  800295:	83 c4 18             	add    $0x18,%esp
  800298:	52                   	push   %edx
  800299:	50                   	push   %eax
  80029a:	89 f2                	mov    %esi,%edx
  80029c:	89 f8                	mov    %edi,%eax
  80029e:	e8 9f ff ff ff       	call   800242 <printnum>
  8002a3:	83 c4 20             	add    $0x20,%esp
  8002a6:	eb 13                	jmp    8002bb <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	56                   	push   %esi
  8002ac:	ff 75 18             	pushl  0x18(%ebp)
  8002af:	ff d7                	call   *%edi
  8002b1:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002b4:	83 eb 01             	sub    $0x1,%ebx
  8002b7:	85 db                	test   %ebx,%ebx
  8002b9:	7f ed                	jg     8002a8 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002bb:	83 ec 08             	sub    $0x8,%esp
  8002be:	56                   	push   %esi
  8002bf:	83 ec 04             	sub    $0x4,%esp
  8002c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c8:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cb:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ce:	e8 8d 0c 00 00       	call   800f60 <__umoddi3>
  8002d3:	83 c4 14             	add    $0x14,%esp
  8002d6:	0f be 80 ab 11 80 00 	movsbl 0x8011ab(%eax),%eax
  8002dd:	50                   	push   %eax
  8002de:	ff d7                	call   *%edi
}
  8002e0:	83 c4 10             	add    $0x10,%esp
  8002e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e6:	5b                   	pop    %ebx
  8002e7:	5e                   	pop    %esi
  8002e8:	5f                   	pop    %edi
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002eb:	f3 0f 1e fb          	endbr32 
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f9:	8b 10                	mov    (%eax),%edx
  8002fb:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fe:	73 0a                	jae    80030a <sprintputch+0x1f>
		*b->buf++ = ch;
  800300:	8d 4a 01             	lea    0x1(%edx),%ecx
  800303:	89 08                	mov    %ecx,(%eax)
  800305:	8b 45 08             	mov    0x8(%ebp),%eax
  800308:	88 02                	mov    %al,(%edx)
}
  80030a:	5d                   	pop    %ebp
  80030b:	c3                   	ret    

0080030c <printfmt>:
{
  80030c:	f3 0f 1e fb          	endbr32 
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800316:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800319:	50                   	push   %eax
  80031a:	ff 75 10             	pushl  0x10(%ebp)
  80031d:	ff 75 0c             	pushl  0xc(%ebp)
  800320:	ff 75 08             	pushl  0x8(%ebp)
  800323:	e8 05 00 00 00       	call   80032d <vprintfmt>
}
  800328:	83 c4 10             	add    $0x10,%esp
  80032b:	c9                   	leave  
  80032c:	c3                   	ret    

0080032d <vprintfmt>:
{
  80032d:	f3 0f 1e fb          	endbr32 
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 3c             	sub    $0x3c,%esp
  80033a:	8b 75 08             	mov    0x8(%ebp),%esi
  80033d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800340:	8b 7d 10             	mov    0x10(%ebp),%edi
  800343:	e9 8e 03 00 00       	jmp    8006d6 <vprintfmt+0x3a9>
		padc = ' ';
  800348:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80034c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800353:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80035a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800361:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800366:	8d 47 01             	lea    0x1(%edi),%eax
  800369:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036c:	0f b6 17             	movzbl (%edi),%edx
  80036f:	8d 42 dd             	lea    -0x23(%edx),%eax
  800372:	3c 55                	cmp    $0x55,%al
  800374:	0f 87 df 03 00 00    	ja     800759 <vprintfmt+0x42c>
  80037a:	0f b6 c0             	movzbl %al,%eax
  80037d:	3e ff 24 85 80 12 80 	notrack jmp *0x801280(,%eax,4)
  800384:	00 
  800385:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800388:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80038c:	eb d8                	jmp    800366 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800391:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800395:	eb cf                	jmp    800366 <vprintfmt+0x39>
  800397:	0f b6 d2             	movzbl %dl,%edx
  80039a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80039d:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003a5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003a8:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003ac:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003af:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003b2:	83 f9 09             	cmp    $0x9,%ecx
  8003b5:	77 55                	ja     80040c <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8003b7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003ba:	eb e9                	jmp    8003a5 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bf:	8b 00                	mov    (%eax),%eax
  8003c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c7:	8d 40 04             	lea    0x4(%eax),%eax
  8003ca:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003d0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d4:	79 90                	jns    800366 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003d6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003dc:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003e3:	eb 81                	jmp    800366 <vprintfmt+0x39>
  8003e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e8:	85 c0                	test   %eax,%eax
  8003ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ef:	0f 49 d0             	cmovns %eax,%edx
  8003f2:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003f8:	e9 69 ff ff ff       	jmp    800366 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800400:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800407:	e9 5a ff ff ff       	jmp    800366 <vprintfmt+0x39>
  80040c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80040f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800412:	eb bc                	jmp    8003d0 <vprintfmt+0xa3>
			lflag++;
  800414:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800417:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80041a:	e9 47 ff ff ff       	jmp    800366 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80041f:	8b 45 14             	mov    0x14(%ebp),%eax
  800422:	8d 78 04             	lea    0x4(%eax),%edi
  800425:	83 ec 08             	sub    $0x8,%esp
  800428:	53                   	push   %ebx
  800429:	ff 30                	pushl  (%eax)
  80042b:	ff d6                	call   *%esi
			break;
  80042d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800430:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800433:	e9 9b 02 00 00       	jmp    8006d3 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800438:	8b 45 14             	mov    0x14(%ebp),%eax
  80043b:	8d 78 04             	lea    0x4(%eax),%edi
  80043e:	8b 00                	mov    (%eax),%eax
  800440:	99                   	cltd   
  800441:	31 d0                	xor    %edx,%eax
  800443:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800445:	83 f8 08             	cmp    $0x8,%eax
  800448:	7f 23                	jg     80046d <vprintfmt+0x140>
  80044a:	8b 14 85 e0 13 80 00 	mov    0x8013e0(,%eax,4),%edx
  800451:	85 d2                	test   %edx,%edx
  800453:	74 18                	je     80046d <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800455:	52                   	push   %edx
  800456:	68 cc 11 80 00       	push   $0x8011cc
  80045b:	53                   	push   %ebx
  80045c:	56                   	push   %esi
  80045d:	e8 aa fe ff ff       	call   80030c <printfmt>
  800462:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800465:	89 7d 14             	mov    %edi,0x14(%ebp)
  800468:	e9 66 02 00 00       	jmp    8006d3 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  80046d:	50                   	push   %eax
  80046e:	68 c3 11 80 00       	push   $0x8011c3
  800473:	53                   	push   %ebx
  800474:	56                   	push   %esi
  800475:	e8 92 fe ff ff       	call   80030c <printfmt>
  80047a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80047d:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800480:	e9 4e 02 00 00       	jmp    8006d3 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800485:	8b 45 14             	mov    0x14(%ebp),%eax
  800488:	83 c0 04             	add    $0x4,%eax
  80048b:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80048e:	8b 45 14             	mov    0x14(%ebp),%eax
  800491:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800493:	85 d2                	test   %edx,%edx
  800495:	b8 bc 11 80 00       	mov    $0x8011bc,%eax
  80049a:	0f 45 c2             	cmovne %edx,%eax
  80049d:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004a0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004a4:	7e 06                	jle    8004ac <vprintfmt+0x17f>
  8004a6:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004aa:	75 0d                	jne    8004b9 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ac:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004af:	89 c7                	mov    %eax,%edi
  8004b1:	03 45 e0             	add    -0x20(%ebp),%eax
  8004b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b7:	eb 55                	jmp    80050e <vprintfmt+0x1e1>
  8004b9:	83 ec 08             	sub    $0x8,%esp
  8004bc:	ff 75 d8             	pushl  -0x28(%ebp)
  8004bf:	ff 75 cc             	pushl  -0x34(%ebp)
  8004c2:	e8 46 03 00 00       	call   80080d <strnlen>
  8004c7:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004ca:	29 c2                	sub    %eax,%edx
  8004cc:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004cf:	83 c4 10             	add    $0x10,%esp
  8004d2:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004d4:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004db:	85 ff                	test   %edi,%edi
  8004dd:	7e 11                	jle    8004f0 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004df:	83 ec 08             	sub    $0x8,%esp
  8004e2:	53                   	push   %ebx
  8004e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8004e6:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e8:	83 ef 01             	sub    $0x1,%edi
  8004eb:	83 c4 10             	add    $0x10,%esp
  8004ee:	eb eb                	jmp    8004db <vprintfmt+0x1ae>
  8004f0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004f3:	85 d2                	test   %edx,%edx
  8004f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fa:	0f 49 c2             	cmovns %edx,%eax
  8004fd:	29 c2                	sub    %eax,%edx
  8004ff:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800502:	eb a8                	jmp    8004ac <vprintfmt+0x17f>
					putch(ch, putdat);
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	53                   	push   %ebx
  800508:	52                   	push   %edx
  800509:	ff d6                	call   *%esi
  80050b:	83 c4 10             	add    $0x10,%esp
  80050e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800511:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800513:	83 c7 01             	add    $0x1,%edi
  800516:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80051a:	0f be d0             	movsbl %al,%edx
  80051d:	85 d2                	test   %edx,%edx
  80051f:	74 4b                	je     80056c <vprintfmt+0x23f>
  800521:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800525:	78 06                	js     80052d <vprintfmt+0x200>
  800527:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80052b:	78 1e                	js     80054b <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80052d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800531:	74 d1                	je     800504 <vprintfmt+0x1d7>
  800533:	0f be c0             	movsbl %al,%eax
  800536:	83 e8 20             	sub    $0x20,%eax
  800539:	83 f8 5e             	cmp    $0x5e,%eax
  80053c:	76 c6                	jbe    800504 <vprintfmt+0x1d7>
					putch('?', putdat);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	53                   	push   %ebx
  800542:	6a 3f                	push   $0x3f
  800544:	ff d6                	call   *%esi
  800546:	83 c4 10             	add    $0x10,%esp
  800549:	eb c3                	jmp    80050e <vprintfmt+0x1e1>
  80054b:	89 cf                	mov    %ecx,%edi
  80054d:	eb 0e                	jmp    80055d <vprintfmt+0x230>
				putch(' ', putdat);
  80054f:	83 ec 08             	sub    $0x8,%esp
  800552:	53                   	push   %ebx
  800553:	6a 20                	push   $0x20
  800555:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800557:	83 ef 01             	sub    $0x1,%edi
  80055a:	83 c4 10             	add    $0x10,%esp
  80055d:	85 ff                	test   %edi,%edi
  80055f:	7f ee                	jg     80054f <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800561:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800564:	89 45 14             	mov    %eax,0x14(%ebp)
  800567:	e9 67 01 00 00       	jmp    8006d3 <vprintfmt+0x3a6>
  80056c:	89 cf                	mov    %ecx,%edi
  80056e:	eb ed                	jmp    80055d <vprintfmt+0x230>
	if (lflag >= 2)
  800570:	83 f9 01             	cmp    $0x1,%ecx
  800573:	7f 1b                	jg     800590 <vprintfmt+0x263>
	else if (lflag)
  800575:	85 c9                	test   %ecx,%ecx
  800577:	74 63                	je     8005dc <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800579:	8b 45 14             	mov    0x14(%ebp),%eax
  80057c:	8b 00                	mov    (%eax),%eax
  80057e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800581:	99                   	cltd   
  800582:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800585:	8b 45 14             	mov    0x14(%ebp),%eax
  800588:	8d 40 04             	lea    0x4(%eax),%eax
  80058b:	89 45 14             	mov    %eax,0x14(%ebp)
  80058e:	eb 17                	jmp    8005a7 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8b 50 04             	mov    0x4(%eax),%edx
  800596:	8b 00                	mov    (%eax),%eax
  800598:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8d 40 08             	lea    0x8(%eax),%eax
  8005a4:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8005a7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005aa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005ad:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005b2:	85 c9                	test   %ecx,%ecx
  8005b4:	0f 89 ff 00 00 00    	jns    8006b9 <vprintfmt+0x38c>
				putch('-', putdat);
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	53                   	push   %ebx
  8005be:	6a 2d                	push   $0x2d
  8005c0:	ff d6                	call   *%esi
				num = -(long long) num;
  8005c2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005c8:	f7 da                	neg    %edx
  8005ca:	83 d1 00             	adc    $0x0,%ecx
  8005cd:	f7 d9                	neg    %ecx
  8005cf:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005d2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d7:	e9 dd 00 00 00       	jmp    8006b9 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8b 00                	mov    (%eax),%eax
  8005e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e4:	99                   	cltd   
  8005e5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8d 40 04             	lea    0x4(%eax),%eax
  8005ee:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f1:	eb b4                	jmp    8005a7 <vprintfmt+0x27a>
	if (lflag >= 2)
  8005f3:	83 f9 01             	cmp    $0x1,%ecx
  8005f6:	7f 1e                	jg     800616 <vprintfmt+0x2e9>
	else if (lflag)
  8005f8:	85 c9                	test   %ecx,%ecx
  8005fa:	74 32                	je     80062e <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8b 10                	mov    (%eax),%edx
  800601:	b9 00 00 00 00       	mov    $0x0,%ecx
  800606:	8d 40 04             	lea    0x4(%eax),%eax
  800609:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80060c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800611:	e9 a3 00 00 00       	jmp    8006b9 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800616:	8b 45 14             	mov    0x14(%ebp),%eax
  800619:	8b 10                	mov    (%eax),%edx
  80061b:	8b 48 04             	mov    0x4(%eax),%ecx
  80061e:	8d 40 08             	lea    0x8(%eax),%eax
  800621:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800624:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800629:	e9 8b 00 00 00       	jmp    8006b9 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8b 10                	mov    (%eax),%edx
  800633:	b9 00 00 00 00       	mov    $0x0,%ecx
  800638:	8d 40 04             	lea    0x4(%eax),%eax
  80063b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80063e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800643:	eb 74                	jmp    8006b9 <vprintfmt+0x38c>
	if (lflag >= 2)
  800645:	83 f9 01             	cmp    $0x1,%ecx
  800648:	7f 1b                	jg     800665 <vprintfmt+0x338>
	else if (lflag)
  80064a:	85 c9                	test   %ecx,%ecx
  80064c:	74 2c                	je     80067a <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  80064e:	8b 45 14             	mov    0x14(%ebp),%eax
  800651:	8b 10                	mov    (%eax),%edx
  800653:	b9 00 00 00 00       	mov    $0x0,%ecx
  800658:	8d 40 04             	lea    0x4(%eax),%eax
  80065b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80065e:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800663:	eb 54                	jmp    8006b9 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8b 10                	mov    (%eax),%edx
  80066a:	8b 48 04             	mov    0x4(%eax),%ecx
  80066d:	8d 40 08             	lea    0x8(%eax),%eax
  800670:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800673:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800678:	eb 3f                	jmp    8006b9 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8b 10                	mov    (%eax),%edx
  80067f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800684:	8d 40 04             	lea    0x4(%eax),%eax
  800687:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80068a:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  80068f:	eb 28                	jmp    8006b9 <vprintfmt+0x38c>
			putch('0', putdat);
  800691:	83 ec 08             	sub    $0x8,%esp
  800694:	53                   	push   %ebx
  800695:	6a 30                	push   $0x30
  800697:	ff d6                	call   *%esi
			putch('x', putdat);
  800699:	83 c4 08             	add    $0x8,%esp
  80069c:	53                   	push   %ebx
  80069d:	6a 78                	push   $0x78
  80069f:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a4:	8b 10                	mov    (%eax),%edx
  8006a6:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006ab:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006ae:	8d 40 04             	lea    0x4(%eax),%eax
  8006b1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b4:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006b9:	83 ec 0c             	sub    $0xc,%esp
  8006bc:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8006c0:	57                   	push   %edi
  8006c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c4:	50                   	push   %eax
  8006c5:	51                   	push   %ecx
  8006c6:	52                   	push   %edx
  8006c7:	89 da                	mov    %ebx,%edx
  8006c9:	89 f0                	mov    %esi,%eax
  8006cb:	e8 72 fb ff ff       	call   800242 <printnum>
			break;
  8006d0:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8006d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {	
  8006d6:	83 c7 01             	add    $0x1,%edi
  8006d9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006dd:	83 f8 25             	cmp    $0x25,%eax
  8006e0:	0f 84 62 fc ff ff    	je     800348 <vprintfmt+0x1b>
			if (ch == '\0')										
  8006e6:	85 c0                	test   %eax,%eax
  8006e8:	0f 84 8b 00 00 00    	je     800779 <vprintfmt+0x44c>
			putch(ch, putdat);
  8006ee:	83 ec 08             	sub    $0x8,%esp
  8006f1:	53                   	push   %ebx
  8006f2:	50                   	push   %eax
  8006f3:	ff d6                	call   *%esi
  8006f5:	83 c4 10             	add    $0x10,%esp
  8006f8:	eb dc                	jmp    8006d6 <vprintfmt+0x3a9>
	if (lflag >= 2)
  8006fa:	83 f9 01             	cmp    $0x1,%ecx
  8006fd:	7f 1b                	jg     80071a <vprintfmt+0x3ed>
	else if (lflag)
  8006ff:	85 c9                	test   %ecx,%ecx
  800701:	74 2c                	je     80072f <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800703:	8b 45 14             	mov    0x14(%ebp),%eax
  800706:	8b 10                	mov    (%eax),%edx
  800708:	b9 00 00 00 00       	mov    $0x0,%ecx
  80070d:	8d 40 04             	lea    0x4(%eax),%eax
  800710:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800713:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800718:	eb 9f                	jmp    8006b9 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8b 10                	mov    (%eax),%edx
  80071f:	8b 48 04             	mov    0x4(%eax),%ecx
  800722:	8d 40 08             	lea    0x8(%eax),%eax
  800725:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800728:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80072d:	eb 8a                	jmp    8006b9 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80072f:	8b 45 14             	mov    0x14(%ebp),%eax
  800732:	8b 10                	mov    (%eax),%edx
  800734:	b9 00 00 00 00       	mov    $0x0,%ecx
  800739:	8d 40 04             	lea    0x4(%eax),%eax
  80073c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80073f:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800744:	e9 70 ff ff ff       	jmp    8006b9 <vprintfmt+0x38c>
			putch(ch, putdat);
  800749:	83 ec 08             	sub    $0x8,%esp
  80074c:	53                   	push   %ebx
  80074d:	6a 25                	push   $0x25
  80074f:	ff d6                	call   *%esi
			break;
  800751:	83 c4 10             	add    $0x10,%esp
  800754:	e9 7a ff ff ff       	jmp    8006d3 <vprintfmt+0x3a6>
			putch('%', putdat);
  800759:	83 ec 08             	sub    $0x8,%esp
  80075c:	53                   	push   %ebx
  80075d:	6a 25                	push   $0x25
  80075f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800761:	83 c4 10             	add    $0x10,%esp
  800764:	89 f8                	mov    %edi,%eax
  800766:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80076a:	74 05                	je     800771 <vprintfmt+0x444>
  80076c:	83 e8 01             	sub    $0x1,%eax
  80076f:	eb f5                	jmp    800766 <vprintfmt+0x439>
  800771:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800774:	e9 5a ff ff ff       	jmp    8006d3 <vprintfmt+0x3a6>
}
  800779:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80077c:	5b                   	pop    %ebx
  80077d:	5e                   	pop    %esi
  80077e:	5f                   	pop    %edi
  80077f:	5d                   	pop    %ebp
  800780:	c3                   	ret    

00800781 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800781:	f3 0f 1e fb          	endbr32 
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	83 ec 18             	sub    $0x18,%esp
  80078b:	8b 45 08             	mov    0x8(%ebp),%eax
  80078e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800791:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800794:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800798:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80079b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007a2:	85 c0                	test   %eax,%eax
  8007a4:	74 26                	je     8007cc <vsnprintf+0x4b>
  8007a6:	85 d2                	test   %edx,%edx
  8007a8:	7e 22                	jle    8007cc <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007aa:	ff 75 14             	pushl  0x14(%ebp)
  8007ad:	ff 75 10             	pushl  0x10(%ebp)
  8007b0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007b3:	50                   	push   %eax
  8007b4:	68 eb 02 80 00       	push   $0x8002eb
  8007b9:	e8 6f fb ff ff       	call   80032d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007be:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007c7:	83 c4 10             	add    $0x10,%esp
}
  8007ca:	c9                   	leave  
  8007cb:	c3                   	ret    
		return -E_INVAL;
  8007cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007d1:	eb f7                	jmp    8007ca <vsnprintf+0x49>

008007d3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d3:	f3 0f 1e fb          	endbr32 
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007dd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007e0:	50                   	push   %eax
  8007e1:	ff 75 10             	pushl  0x10(%ebp)
  8007e4:	ff 75 0c             	pushl  0xc(%ebp)
  8007e7:	ff 75 08             	pushl  0x8(%ebp)
  8007ea:	e8 92 ff ff ff       	call   800781 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ef:	c9                   	leave  
  8007f0:	c3                   	ret    

008007f1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f1:	f3 0f 1e fb          	endbr32 
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800800:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800804:	74 05                	je     80080b <strlen+0x1a>
		n++;
  800806:	83 c0 01             	add    $0x1,%eax
  800809:	eb f5                	jmp    800800 <strlen+0xf>
	return n;
}
  80080b:	5d                   	pop    %ebp
  80080c:	c3                   	ret    

0080080d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80080d:	f3 0f 1e fb          	endbr32 
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800817:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081a:	b8 00 00 00 00       	mov    $0x0,%eax
  80081f:	39 d0                	cmp    %edx,%eax
  800821:	74 0d                	je     800830 <strnlen+0x23>
  800823:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800827:	74 05                	je     80082e <strnlen+0x21>
		n++;
  800829:	83 c0 01             	add    $0x1,%eax
  80082c:	eb f1                	jmp    80081f <strnlen+0x12>
  80082e:	89 c2                	mov    %eax,%edx
	return n;
}
  800830:	89 d0                	mov    %edx,%eax
  800832:	5d                   	pop    %ebp
  800833:	c3                   	ret    

00800834 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800834:	f3 0f 1e fb          	endbr32 
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	53                   	push   %ebx
  80083c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800842:	b8 00 00 00 00       	mov    $0x0,%eax
  800847:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80084b:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80084e:	83 c0 01             	add    $0x1,%eax
  800851:	84 d2                	test   %dl,%dl
  800853:	75 f2                	jne    800847 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800855:	89 c8                	mov    %ecx,%eax
  800857:	5b                   	pop    %ebx
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80085a:	f3 0f 1e fb          	endbr32 
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	53                   	push   %ebx
  800862:	83 ec 10             	sub    $0x10,%esp
  800865:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800868:	53                   	push   %ebx
  800869:	e8 83 ff ff ff       	call   8007f1 <strlen>
  80086e:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800871:	ff 75 0c             	pushl  0xc(%ebp)
  800874:	01 d8                	add    %ebx,%eax
  800876:	50                   	push   %eax
  800877:	e8 b8 ff ff ff       	call   800834 <strcpy>
	return dst;
}
  80087c:	89 d8                	mov    %ebx,%eax
  80087e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800881:	c9                   	leave  
  800882:	c3                   	ret    

00800883 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800883:	f3 0f 1e fb          	endbr32 
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	56                   	push   %esi
  80088b:	53                   	push   %ebx
  80088c:	8b 75 08             	mov    0x8(%ebp),%esi
  80088f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800892:	89 f3                	mov    %esi,%ebx
  800894:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800897:	89 f0                	mov    %esi,%eax
  800899:	39 d8                	cmp    %ebx,%eax
  80089b:	74 11                	je     8008ae <strncpy+0x2b>
		*dst++ = *src;
  80089d:	83 c0 01             	add    $0x1,%eax
  8008a0:	0f b6 0a             	movzbl (%edx),%ecx
  8008a3:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008a6:	80 f9 01             	cmp    $0x1,%cl
  8008a9:	83 da ff             	sbb    $0xffffffff,%edx
  8008ac:	eb eb                	jmp    800899 <strncpy+0x16>
	}
	return ret;
}
  8008ae:	89 f0                	mov    %esi,%eax
  8008b0:	5b                   	pop    %ebx
  8008b1:	5e                   	pop    %esi
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008b4:	f3 0f 1e fb          	endbr32 
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	56                   	push   %esi
  8008bc:	53                   	push   %ebx
  8008bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8008c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c3:	8b 55 10             	mov    0x10(%ebp),%edx
  8008c6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008c8:	85 d2                	test   %edx,%edx
  8008ca:	74 21                	je     8008ed <strlcpy+0x39>
  8008cc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008d0:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008d2:	39 c2                	cmp    %eax,%edx
  8008d4:	74 14                	je     8008ea <strlcpy+0x36>
  8008d6:	0f b6 19             	movzbl (%ecx),%ebx
  8008d9:	84 db                	test   %bl,%bl
  8008db:	74 0b                	je     8008e8 <strlcpy+0x34>
			*dst++ = *src++;
  8008dd:	83 c1 01             	add    $0x1,%ecx
  8008e0:	83 c2 01             	add    $0x1,%edx
  8008e3:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008e6:	eb ea                	jmp    8008d2 <strlcpy+0x1e>
  8008e8:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008ea:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ed:	29 f0                	sub    %esi,%eax
}
  8008ef:	5b                   	pop    %ebx
  8008f0:	5e                   	pop    %esi
  8008f1:	5d                   	pop    %ebp
  8008f2:	c3                   	ret    

008008f3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008f3:	f3 0f 1e fb          	endbr32 
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008fd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800900:	0f b6 01             	movzbl (%ecx),%eax
  800903:	84 c0                	test   %al,%al
  800905:	74 0c                	je     800913 <strcmp+0x20>
  800907:	3a 02                	cmp    (%edx),%al
  800909:	75 08                	jne    800913 <strcmp+0x20>
		p++, q++;
  80090b:	83 c1 01             	add    $0x1,%ecx
  80090e:	83 c2 01             	add    $0x1,%edx
  800911:	eb ed                	jmp    800900 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800913:	0f b6 c0             	movzbl %al,%eax
  800916:	0f b6 12             	movzbl (%edx),%edx
  800919:	29 d0                	sub    %edx,%eax
}
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80091d:	f3 0f 1e fb          	endbr32 
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	53                   	push   %ebx
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092b:	89 c3                	mov    %eax,%ebx
  80092d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800930:	eb 06                	jmp    800938 <strncmp+0x1b>
		n--, p++, q++;
  800932:	83 c0 01             	add    $0x1,%eax
  800935:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800938:	39 d8                	cmp    %ebx,%eax
  80093a:	74 16                	je     800952 <strncmp+0x35>
  80093c:	0f b6 08             	movzbl (%eax),%ecx
  80093f:	84 c9                	test   %cl,%cl
  800941:	74 04                	je     800947 <strncmp+0x2a>
  800943:	3a 0a                	cmp    (%edx),%cl
  800945:	74 eb                	je     800932 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800947:	0f b6 00             	movzbl (%eax),%eax
  80094a:	0f b6 12             	movzbl (%edx),%edx
  80094d:	29 d0                	sub    %edx,%eax
}
  80094f:	5b                   	pop    %ebx
  800950:	5d                   	pop    %ebp
  800951:	c3                   	ret    
		return 0;
  800952:	b8 00 00 00 00       	mov    $0x0,%eax
  800957:	eb f6                	jmp    80094f <strncmp+0x32>

00800959 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800959:	f3 0f 1e fb          	endbr32 
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800967:	0f b6 10             	movzbl (%eax),%edx
  80096a:	84 d2                	test   %dl,%dl
  80096c:	74 09                	je     800977 <strchr+0x1e>
		if (*s == c)
  80096e:	38 ca                	cmp    %cl,%dl
  800970:	74 0a                	je     80097c <strchr+0x23>
	for (; *s; s++)
  800972:	83 c0 01             	add    $0x1,%eax
  800975:	eb f0                	jmp    800967 <strchr+0xe>
			return (char *) s;
	return 0;
  800977:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80097e:	f3 0f 1e fb          	endbr32 
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80098c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80098f:	38 ca                	cmp    %cl,%dl
  800991:	74 09                	je     80099c <strfind+0x1e>
  800993:	84 d2                	test   %dl,%dl
  800995:	74 05                	je     80099c <strfind+0x1e>
	for (; *s; s++)
  800997:	83 c0 01             	add    $0x1,%eax
  80099a:	eb f0                	jmp    80098c <strfind+0xe>
			break;
	return (char *) s;
}
  80099c:	5d                   	pop    %ebp
  80099d:	c3                   	ret    

0080099e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80099e:	f3 0f 1e fb          	endbr32 
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	57                   	push   %edi
  8009a6:	56                   	push   %esi
  8009a7:	53                   	push   %ebx
  8009a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ab:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009ae:	85 c9                	test   %ecx,%ecx
  8009b0:	74 31                	je     8009e3 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009b2:	89 f8                	mov    %edi,%eax
  8009b4:	09 c8                	or     %ecx,%eax
  8009b6:	a8 03                	test   $0x3,%al
  8009b8:	75 23                	jne    8009dd <memset+0x3f>
		c &= 0xFF;
  8009ba:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009be:	89 d3                	mov    %edx,%ebx
  8009c0:	c1 e3 08             	shl    $0x8,%ebx
  8009c3:	89 d0                	mov    %edx,%eax
  8009c5:	c1 e0 18             	shl    $0x18,%eax
  8009c8:	89 d6                	mov    %edx,%esi
  8009ca:	c1 e6 10             	shl    $0x10,%esi
  8009cd:	09 f0                	or     %esi,%eax
  8009cf:	09 c2                	or     %eax,%edx
  8009d1:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009d3:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009d6:	89 d0                	mov    %edx,%eax
  8009d8:	fc                   	cld    
  8009d9:	f3 ab                	rep stos %eax,%es:(%edi)
  8009db:	eb 06                	jmp    8009e3 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e0:	fc                   	cld    
  8009e1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009e3:	89 f8                	mov    %edi,%eax
  8009e5:	5b                   	pop    %ebx
  8009e6:	5e                   	pop    %esi
  8009e7:	5f                   	pop    %edi
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ea:	f3 0f 1e fb          	endbr32 
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	57                   	push   %edi
  8009f2:	56                   	push   %esi
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009fc:	39 c6                	cmp    %eax,%esi
  8009fe:	73 32                	jae    800a32 <memmove+0x48>
  800a00:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a03:	39 c2                	cmp    %eax,%edx
  800a05:	76 2b                	jbe    800a32 <memmove+0x48>
		s += n;
		d += n;
  800a07:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0a:	89 fe                	mov    %edi,%esi
  800a0c:	09 ce                	or     %ecx,%esi
  800a0e:	09 d6                	or     %edx,%esi
  800a10:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a16:	75 0e                	jne    800a26 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a18:	83 ef 04             	sub    $0x4,%edi
  800a1b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a1e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a21:	fd                   	std    
  800a22:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a24:	eb 09                	jmp    800a2f <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a26:	83 ef 01             	sub    $0x1,%edi
  800a29:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a2c:	fd                   	std    
  800a2d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a2f:	fc                   	cld    
  800a30:	eb 1a                	jmp    800a4c <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a32:	89 c2                	mov    %eax,%edx
  800a34:	09 ca                	or     %ecx,%edx
  800a36:	09 f2                	or     %esi,%edx
  800a38:	f6 c2 03             	test   $0x3,%dl
  800a3b:	75 0a                	jne    800a47 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a3d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a40:	89 c7                	mov    %eax,%edi
  800a42:	fc                   	cld    
  800a43:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a45:	eb 05                	jmp    800a4c <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a47:	89 c7                	mov    %eax,%edi
  800a49:	fc                   	cld    
  800a4a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a4c:	5e                   	pop    %esi
  800a4d:	5f                   	pop    %edi
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a50:	f3 0f 1e fb          	endbr32 
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a5a:	ff 75 10             	pushl  0x10(%ebp)
  800a5d:	ff 75 0c             	pushl  0xc(%ebp)
  800a60:	ff 75 08             	pushl  0x8(%ebp)
  800a63:	e8 82 ff ff ff       	call   8009ea <memmove>
}
  800a68:	c9                   	leave  
  800a69:	c3                   	ret    

00800a6a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a6a:	f3 0f 1e fb          	endbr32 
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	56                   	push   %esi
  800a72:	53                   	push   %ebx
  800a73:	8b 45 08             	mov    0x8(%ebp),%eax
  800a76:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a79:	89 c6                	mov    %eax,%esi
  800a7b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a7e:	39 f0                	cmp    %esi,%eax
  800a80:	74 1c                	je     800a9e <memcmp+0x34>
		if (*s1 != *s2)
  800a82:	0f b6 08             	movzbl (%eax),%ecx
  800a85:	0f b6 1a             	movzbl (%edx),%ebx
  800a88:	38 d9                	cmp    %bl,%cl
  800a8a:	75 08                	jne    800a94 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a8c:	83 c0 01             	add    $0x1,%eax
  800a8f:	83 c2 01             	add    $0x1,%edx
  800a92:	eb ea                	jmp    800a7e <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a94:	0f b6 c1             	movzbl %cl,%eax
  800a97:	0f b6 db             	movzbl %bl,%ebx
  800a9a:	29 d8                	sub    %ebx,%eax
  800a9c:	eb 05                	jmp    800aa3 <memcmp+0x39>
	}

	return 0;
  800a9e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa3:	5b                   	pop    %ebx
  800aa4:	5e                   	pop    %esi
  800aa5:	5d                   	pop    %ebp
  800aa6:	c3                   	ret    

00800aa7 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800aa7:	f3 0f 1e fb          	endbr32 
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ab4:	89 c2                	mov    %eax,%edx
  800ab6:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ab9:	39 d0                	cmp    %edx,%eax
  800abb:	73 09                	jae    800ac6 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800abd:	38 08                	cmp    %cl,(%eax)
  800abf:	74 05                	je     800ac6 <memfind+0x1f>
	for (; s < ends; s++)
  800ac1:	83 c0 01             	add    $0x1,%eax
  800ac4:	eb f3                	jmp    800ab9 <memfind+0x12>
			break;
	return (void *) s;
}
  800ac6:	5d                   	pop    %ebp
  800ac7:	c3                   	ret    

00800ac8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ac8:	f3 0f 1e fb          	endbr32 
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	57                   	push   %edi
  800ad0:	56                   	push   %esi
  800ad1:	53                   	push   %ebx
  800ad2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad8:	eb 03                	jmp    800add <strtol+0x15>
		s++;
  800ada:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800add:	0f b6 01             	movzbl (%ecx),%eax
  800ae0:	3c 20                	cmp    $0x20,%al
  800ae2:	74 f6                	je     800ada <strtol+0x12>
  800ae4:	3c 09                	cmp    $0x9,%al
  800ae6:	74 f2                	je     800ada <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800ae8:	3c 2b                	cmp    $0x2b,%al
  800aea:	74 2a                	je     800b16 <strtol+0x4e>
	int neg = 0;
  800aec:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800af1:	3c 2d                	cmp    $0x2d,%al
  800af3:	74 2b                	je     800b20 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800af5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800afb:	75 0f                	jne    800b0c <strtol+0x44>
  800afd:	80 39 30             	cmpb   $0x30,(%ecx)
  800b00:	74 28                	je     800b2a <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b02:	85 db                	test   %ebx,%ebx
  800b04:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b09:	0f 44 d8             	cmove  %eax,%ebx
  800b0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b11:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b14:	eb 46                	jmp    800b5c <strtol+0x94>
		s++;
  800b16:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b19:	bf 00 00 00 00       	mov    $0x0,%edi
  800b1e:	eb d5                	jmp    800af5 <strtol+0x2d>
		s++, neg = 1;
  800b20:	83 c1 01             	add    $0x1,%ecx
  800b23:	bf 01 00 00 00       	mov    $0x1,%edi
  800b28:	eb cb                	jmp    800af5 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b2a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b2e:	74 0e                	je     800b3e <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b30:	85 db                	test   %ebx,%ebx
  800b32:	75 d8                	jne    800b0c <strtol+0x44>
		s++, base = 8;
  800b34:	83 c1 01             	add    $0x1,%ecx
  800b37:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b3c:	eb ce                	jmp    800b0c <strtol+0x44>
		s += 2, base = 16;
  800b3e:	83 c1 02             	add    $0x2,%ecx
  800b41:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b46:	eb c4                	jmp    800b0c <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b48:	0f be d2             	movsbl %dl,%edx
  800b4b:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b4e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b51:	7d 3a                	jge    800b8d <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b53:	83 c1 01             	add    $0x1,%ecx
  800b56:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b5a:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b5c:	0f b6 11             	movzbl (%ecx),%edx
  800b5f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b62:	89 f3                	mov    %esi,%ebx
  800b64:	80 fb 09             	cmp    $0x9,%bl
  800b67:	76 df                	jbe    800b48 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b69:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b6c:	89 f3                	mov    %esi,%ebx
  800b6e:	80 fb 19             	cmp    $0x19,%bl
  800b71:	77 08                	ja     800b7b <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b73:	0f be d2             	movsbl %dl,%edx
  800b76:	83 ea 57             	sub    $0x57,%edx
  800b79:	eb d3                	jmp    800b4e <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b7b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b7e:	89 f3                	mov    %esi,%ebx
  800b80:	80 fb 19             	cmp    $0x19,%bl
  800b83:	77 08                	ja     800b8d <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b85:	0f be d2             	movsbl %dl,%edx
  800b88:	83 ea 37             	sub    $0x37,%edx
  800b8b:	eb c1                	jmp    800b4e <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b8d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b91:	74 05                	je     800b98 <strtol+0xd0>
		*endptr = (char *) s;
  800b93:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b96:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b98:	89 c2                	mov    %eax,%edx
  800b9a:	f7 da                	neg    %edx
  800b9c:	85 ff                	test   %edi,%edi
  800b9e:	0f 45 c2             	cmovne %edx,%eax
}
  800ba1:	5b                   	pop    %ebx
  800ba2:	5e                   	pop    %esi
  800ba3:	5f                   	pop    %edi
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ba6:	f3 0f 1e fb          	endbr32 
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	57                   	push   %edi
  800bae:	56                   	push   %esi
  800baf:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800bb0:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbb:	89 c3                	mov    %eax,%ebx
  800bbd:	89 c7                	mov    %eax,%edi
  800bbf:	89 c6                	mov    %eax,%esi
  800bc1:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bc3:	5b                   	pop    %ebx
  800bc4:	5e                   	pop    %esi
  800bc5:	5f                   	pop    %edi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bc8:	f3 0f 1e fb          	endbr32 
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	57                   	push   %edi
  800bd0:	56                   	push   %esi
  800bd1:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800bd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd7:	b8 01 00 00 00       	mov    $0x1,%eax
  800bdc:	89 d1                	mov    %edx,%ecx
  800bde:	89 d3                	mov    %edx,%ebx
  800be0:	89 d7                	mov    %edx,%edi
  800be2:	89 d6                	mov    %edx,%esi
  800be4:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800be6:	5b                   	pop    %ebx
  800be7:	5e                   	pop    %esi
  800be8:	5f                   	pop    %edi
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800beb:	f3 0f 1e fb          	endbr32 
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	57                   	push   %edi
  800bf3:	56                   	push   %esi
  800bf4:	53                   	push   %ebx
  800bf5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800bf8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800c00:	b8 03 00 00 00       	mov    $0x3,%eax
  800c05:	89 cb                	mov    %ecx,%ebx
  800c07:	89 cf                	mov    %ecx,%edi
  800c09:	89 ce                	mov    %ecx,%esi
  800c0b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c0d:	85 c0                	test   %eax,%eax
  800c0f:	7f 08                	jg     800c19 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c19:	83 ec 0c             	sub    $0xc,%esp
  800c1c:	50                   	push   %eax
  800c1d:	6a 03                	push   $0x3
  800c1f:	68 04 14 80 00       	push   $0x801404
  800c24:	6a 23                	push   $0x23
  800c26:	68 21 14 80 00       	push   $0x801421
  800c2b:	e8 13 f5 ff ff       	call   800143 <_panic>

00800c30 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c30:	f3 0f 1e fb          	endbr32 
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	57                   	push   %edi
  800c38:	56                   	push   %esi
  800c39:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3f:	b8 02 00 00 00       	mov    $0x2,%eax
  800c44:	89 d1                	mov    %edx,%ecx
  800c46:	89 d3                	mov    %edx,%ebx
  800c48:	89 d7                	mov    %edx,%edi
  800c4a:	89 d6                	mov    %edx,%esi
  800c4c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c4e:	5b                   	pop    %ebx
  800c4f:	5e                   	pop    %esi
  800c50:	5f                   	pop    %edi
  800c51:	5d                   	pop    %ebp
  800c52:	c3                   	ret    

00800c53 <sys_yield>:

void
sys_yield(void)
{
  800c53:	f3 0f 1e fb          	endbr32 
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c62:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c67:	89 d1                	mov    %edx,%ecx
  800c69:	89 d3                	mov    %edx,%ebx
  800c6b:	89 d7                	mov    %edx,%edi
  800c6d:	89 d6                	mov    %edx,%esi
  800c6f:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5f                   	pop    %edi
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    

00800c76 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c76:	f3 0f 1e fb          	endbr32 
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	57                   	push   %edi
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
  800c80:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c83:	be 00 00 00 00       	mov    $0x0,%esi
  800c88:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8e:	b8 04 00 00 00       	mov    $0x4,%eax
  800c93:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c96:	89 f7                	mov    %esi,%edi
  800c98:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c9a:	85 c0                	test   %eax,%eax
  800c9c:	7f 08                	jg     800ca6 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca6:	83 ec 0c             	sub    $0xc,%esp
  800ca9:	50                   	push   %eax
  800caa:	6a 04                	push   $0x4
  800cac:	68 04 14 80 00       	push   $0x801404
  800cb1:	6a 23                	push   $0x23
  800cb3:	68 21 14 80 00       	push   $0x801421
  800cb8:	e8 86 f4 ff ff       	call   800143 <_panic>

00800cbd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cbd:	f3 0f 1e fb          	endbr32 
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800cca:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd0:	b8 05 00 00 00       	mov    $0x5,%eax
  800cd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd8:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cdb:	8b 75 18             	mov    0x18(%ebp),%esi
  800cde:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	7f 08                	jg     800cec <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ce4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cec:	83 ec 0c             	sub    $0xc,%esp
  800cef:	50                   	push   %eax
  800cf0:	6a 05                	push   $0x5
  800cf2:	68 04 14 80 00       	push   $0x801404
  800cf7:	6a 23                	push   $0x23
  800cf9:	68 21 14 80 00       	push   $0x801421
  800cfe:	e8 40 f4 ff ff       	call   800143 <_panic>

00800d03 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d03:	f3 0f 1e fb          	endbr32 
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
  800d0d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d15:	8b 55 08             	mov    0x8(%ebp),%edx
  800d18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1b:	b8 06 00 00 00       	mov    $0x6,%eax
  800d20:	89 df                	mov    %ebx,%edi
  800d22:	89 de                	mov    %ebx,%esi
  800d24:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d26:	85 c0                	test   %eax,%eax
  800d28:	7f 08                	jg     800d32 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5f                   	pop    %edi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d32:	83 ec 0c             	sub    $0xc,%esp
  800d35:	50                   	push   %eax
  800d36:	6a 06                	push   $0x6
  800d38:	68 04 14 80 00       	push   $0x801404
  800d3d:	6a 23                	push   $0x23
  800d3f:	68 21 14 80 00       	push   $0x801421
  800d44:	e8 fa f3 ff ff       	call   800143 <_panic>

00800d49 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d49:	f3 0f 1e fb          	endbr32 
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	57                   	push   %edi
  800d51:	56                   	push   %esi
  800d52:	53                   	push   %ebx
  800d53:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d56:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d61:	b8 08 00 00 00       	mov    $0x8,%eax
  800d66:	89 df                	mov    %ebx,%edi
  800d68:	89 de                	mov    %ebx,%esi
  800d6a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d6c:	85 c0                	test   %eax,%eax
  800d6e:	7f 08                	jg     800d78 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d78:	83 ec 0c             	sub    $0xc,%esp
  800d7b:	50                   	push   %eax
  800d7c:	6a 08                	push   $0x8
  800d7e:	68 04 14 80 00       	push   $0x801404
  800d83:	6a 23                	push   $0x23
  800d85:	68 21 14 80 00       	push   $0x801421
  800d8a:	e8 b4 f3 ff ff       	call   800143 <_panic>

00800d8f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d8f:	f3 0f 1e fb          	endbr32 
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	57                   	push   %edi
  800d97:	56                   	push   %esi
  800d98:	53                   	push   %ebx
  800d99:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da1:	8b 55 08             	mov    0x8(%ebp),%edx
  800da4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da7:	b8 09 00 00 00       	mov    $0x9,%eax
  800dac:	89 df                	mov    %ebx,%edi
  800dae:	89 de                	mov    %ebx,%esi
  800db0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800db2:	85 c0                	test   %eax,%eax
  800db4:	7f 08                	jg     800dbe <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800db6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db9:	5b                   	pop    %ebx
  800dba:	5e                   	pop    %esi
  800dbb:	5f                   	pop    %edi
  800dbc:	5d                   	pop    %ebp
  800dbd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbe:	83 ec 0c             	sub    $0xc,%esp
  800dc1:	50                   	push   %eax
  800dc2:	6a 09                	push   $0x9
  800dc4:	68 04 14 80 00       	push   $0x801404
  800dc9:	6a 23                	push   $0x23
  800dcb:	68 21 14 80 00       	push   $0x801421
  800dd0:	e8 6e f3 ff ff       	call   800143 <_panic>

00800dd5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dd5:	f3 0f 1e fb          	endbr32 
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	57                   	push   %edi
  800ddd:	56                   	push   %esi
  800dde:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800ddf:	8b 55 08             	mov    0x8(%ebp),%edx
  800de2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dea:	be 00 00 00 00       	mov    $0x0,%esi
  800def:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df5:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800df7:	5b                   	pop    %ebx
  800df8:	5e                   	pop    %esi
  800df9:	5f                   	pop    %edi
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    

00800dfc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dfc:	f3 0f 1e fb          	endbr32 
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	57                   	push   %edi
  800e04:	56                   	push   %esi
  800e05:	53                   	push   %ebx
  800e06:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800e09:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e11:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e16:	89 cb                	mov    %ecx,%ebx
  800e18:	89 cf                	mov    %ecx,%edi
  800e1a:	89 ce                	mov    %ecx,%esi
  800e1c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e1e:	85 c0                	test   %eax,%eax
  800e20:	7f 08                	jg     800e2a <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e25:	5b                   	pop    %ebx
  800e26:	5e                   	pop    %esi
  800e27:	5f                   	pop    %edi
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2a:	83 ec 0c             	sub    $0xc,%esp
  800e2d:	50                   	push   %eax
  800e2e:	6a 0c                	push   $0xc
  800e30:	68 04 14 80 00       	push   $0x801404
  800e35:	6a 23                	push   $0x23
  800e37:	68 21 14 80 00       	push   $0x801421
  800e3c:	e8 02 f3 ff ff       	call   800143 <_panic>
  800e41:	66 90                	xchg   %ax,%ax
  800e43:	66 90                	xchg   %ax,%ax
  800e45:	66 90                	xchg   %ax,%ax
  800e47:	66 90                	xchg   %ax,%ax
  800e49:	66 90                	xchg   %ax,%ax
  800e4b:	66 90                	xchg   %ax,%ax
  800e4d:	66 90                	xchg   %ax,%ax
  800e4f:	90                   	nop

00800e50 <__udivdi3>:
  800e50:	f3 0f 1e fb          	endbr32 
  800e54:	55                   	push   %ebp
  800e55:	57                   	push   %edi
  800e56:	56                   	push   %esi
  800e57:	53                   	push   %ebx
  800e58:	83 ec 1c             	sub    $0x1c,%esp
  800e5b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e5f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e63:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e67:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e6b:	85 d2                	test   %edx,%edx
  800e6d:	75 19                	jne    800e88 <__udivdi3+0x38>
  800e6f:	39 f3                	cmp    %esi,%ebx
  800e71:	76 4d                	jbe    800ec0 <__udivdi3+0x70>
  800e73:	31 ff                	xor    %edi,%edi
  800e75:	89 e8                	mov    %ebp,%eax
  800e77:	89 f2                	mov    %esi,%edx
  800e79:	f7 f3                	div    %ebx
  800e7b:	89 fa                	mov    %edi,%edx
  800e7d:	83 c4 1c             	add    $0x1c,%esp
  800e80:	5b                   	pop    %ebx
  800e81:	5e                   	pop    %esi
  800e82:	5f                   	pop    %edi
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    
  800e85:	8d 76 00             	lea    0x0(%esi),%esi
  800e88:	39 f2                	cmp    %esi,%edx
  800e8a:	76 14                	jbe    800ea0 <__udivdi3+0x50>
  800e8c:	31 ff                	xor    %edi,%edi
  800e8e:	31 c0                	xor    %eax,%eax
  800e90:	89 fa                	mov    %edi,%edx
  800e92:	83 c4 1c             	add    $0x1c,%esp
  800e95:	5b                   	pop    %ebx
  800e96:	5e                   	pop    %esi
  800e97:	5f                   	pop    %edi
  800e98:	5d                   	pop    %ebp
  800e99:	c3                   	ret    
  800e9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ea0:	0f bd fa             	bsr    %edx,%edi
  800ea3:	83 f7 1f             	xor    $0x1f,%edi
  800ea6:	75 48                	jne    800ef0 <__udivdi3+0xa0>
  800ea8:	39 f2                	cmp    %esi,%edx
  800eaa:	72 06                	jb     800eb2 <__udivdi3+0x62>
  800eac:	31 c0                	xor    %eax,%eax
  800eae:	39 eb                	cmp    %ebp,%ebx
  800eb0:	77 de                	ja     800e90 <__udivdi3+0x40>
  800eb2:	b8 01 00 00 00       	mov    $0x1,%eax
  800eb7:	eb d7                	jmp    800e90 <__udivdi3+0x40>
  800eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ec0:	89 d9                	mov    %ebx,%ecx
  800ec2:	85 db                	test   %ebx,%ebx
  800ec4:	75 0b                	jne    800ed1 <__udivdi3+0x81>
  800ec6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ecb:	31 d2                	xor    %edx,%edx
  800ecd:	f7 f3                	div    %ebx
  800ecf:	89 c1                	mov    %eax,%ecx
  800ed1:	31 d2                	xor    %edx,%edx
  800ed3:	89 f0                	mov    %esi,%eax
  800ed5:	f7 f1                	div    %ecx
  800ed7:	89 c6                	mov    %eax,%esi
  800ed9:	89 e8                	mov    %ebp,%eax
  800edb:	89 f7                	mov    %esi,%edi
  800edd:	f7 f1                	div    %ecx
  800edf:	89 fa                	mov    %edi,%edx
  800ee1:	83 c4 1c             	add    $0x1c,%esp
  800ee4:	5b                   	pop    %ebx
  800ee5:	5e                   	pop    %esi
  800ee6:	5f                   	pop    %edi
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    
  800ee9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ef0:	89 f9                	mov    %edi,%ecx
  800ef2:	b8 20 00 00 00       	mov    $0x20,%eax
  800ef7:	29 f8                	sub    %edi,%eax
  800ef9:	d3 e2                	shl    %cl,%edx
  800efb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800eff:	89 c1                	mov    %eax,%ecx
  800f01:	89 da                	mov    %ebx,%edx
  800f03:	d3 ea                	shr    %cl,%edx
  800f05:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f09:	09 d1                	or     %edx,%ecx
  800f0b:	89 f2                	mov    %esi,%edx
  800f0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f11:	89 f9                	mov    %edi,%ecx
  800f13:	d3 e3                	shl    %cl,%ebx
  800f15:	89 c1                	mov    %eax,%ecx
  800f17:	d3 ea                	shr    %cl,%edx
  800f19:	89 f9                	mov    %edi,%ecx
  800f1b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f1f:	89 eb                	mov    %ebp,%ebx
  800f21:	d3 e6                	shl    %cl,%esi
  800f23:	89 c1                	mov    %eax,%ecx
  800f25:	d3 eb                	shr    %cl,%ebx
  800f27:	09 de                	or     %ebx,%esi
  800f29:	89 f0                	mov    %esi,%eax
  800f2b:	f7 74 24 08          	divl   0x8(%esp)
  800f2f:	89 d6                	mov    %edx,%esi
  800f31:	89 c3                	mov    %eax,%ebx
  800f33:	f7 64 24 0c          	mull   0xc(%esp)
  800f37:	39 d6                	cmp    %edx,%esi
  800f39:	72 15                	jb     800f50 <__udivdi3+0x100>
  800f3b:	89 f9                	mov    %edi,%ecx
  800f3d:	d3 e5                	shl    %cl,%ebp
  800f3f:	39 c5                	cmp    %eax,%ebp
  800f41:	73 04                	jae    800f47 <__udivdi3+0xf7>
  800f43:	39 d6                	cmp    %edx,%esi
  800f45:	74 09                	je     800f50 <__udivdi3+0x100>
  800f47:	89 d8                	mov    %ebx,%eax
  800f49:	31 ff                	xor    %edi,%edi
  800f4b:	e9 40 ff ff ff       	jmp    800e90 <__udivdi3+0x40>
  800f50:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f53:	31 ff                	xor    %edi,%edi
  800f55:	e9 36 ff ff ff       	jmp    800e90 <__udivdi3+0x40>
  800f5a:	66 90                	xchg   %ax,%ax
  800f5c:	66 90                	xchg   %ax,%ax
  800f5e:	66 90                	xchg   %ax,%ax

00800f60 <__umoddi3>:
  800f60:	f3 0f 1e fb          	endbr32 
  800f64:	55                   	push   %ebp
  800f65:	57                   	push   %edi
  800f66:	56                   	push   %esi
  800f67:	53                   	push   %ebx
  800f68:	83 ec 1c             	sub    $0x1c,%esp
  800f6b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800f6f:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f73:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f77:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	75 19                	jne    800f98 <__umoddi3+0x38>
  800f7f:	39 df                	cmp    %ebx,%edi
  800f81:	76 5d                	jbe    800fe0 <__umoddi3+0x80>
  800f83:	89 f0                	mov    %esi,%eax
  800f85:	89 da                	mov    %ebx,%edx
  800f87:	f7 f7                	div    %edi
  800f89:	89 d0                	mov    %edx,%eax
  800f8b:	31 d2                	xor    %edx,%edx
  800f8d:	83 c4 1c             	add    $0x1c,%esp
  800f90:	5b                   	pop    %ebx
  800f91:	5e                   	pop    %esi
  800f92:	5f                   	pop    %edi
  800f93:	5d                   	pop    %ebp
  800f94:	c3                   	ret    
  800f95:	8d 76 00             	lea    0x0(%esi),%esi
  800f98:	89 f2                	mov    %esi,%edx
  800f9a:	39 d8                	cmp    %ebx,%eax
  800f9c:	76 12                	jbe    800fb0 <__umoddi3+0x50>
  800f9e:	89 f0                	mov    %esi,%eax
  800fa0:	89 da                	mov    %ebx,%edx
  800fa2:	83 c4 1c             	add    $0x1c,%esp
  800fa5:	5b                   	pop    %ebx
  800fa6:	5e                   	pop    %esi
  800fa7:	5f                   	pop    %edi
  800fa8:	5d                   	pop    %ebp
  800fa9:	c3                   	ret    
  800faa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fb0:	0f bd e8             	bsr    %eax,%ebp
  800fb3:	83 f5 1f             	xor    $0x1f,%ebp
  800fb6:	75 50                	jne    801008 <__umoddi3+0xa8>
  800fb8:	39 d8                	cmp    %ebx,%eax
  800fba:	0f 82 e0 00 00 00    	jb     8010a0 <__umoddi3+0x140>
  800fc0:	89 d9                	mov    %ebx,%ecx
  800fc2:	39 f7                	cmp    %esi,%edi
  800fc4:	0f 86 d6 00 00 00    	jbe    8010a0 <__umoddi3+0x140>
  800fca:	89 d0                	mov    %edx,%eax
  800fcc:	89 ca                	mov    %ecx,%edx
  800fce:	83 c4 1c             	add    $0x1c,%esp
  800fd1:	5b                   	pop    %ebx
  800fd2:	5e                   	pop    %esi
  800fd3:	5f                   	pop    %edi
  800fd4:	5d                   	pop    %ebp
  800fd5:	c3                   	ret    
  800fd6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fdd:	8d 76 00             	lea    0x0(%esi),%esi
  800fe0:	89 fd                	mov    %edi,%ebp
  800fe2:	85 ff                	test   %edi,%edi
  800fe4:	75 0b                	jne    800ff1 <__umoddi3+0x91>
  800fe6:	b8 01 00 00 00       	mov    $0x1,%eax
  800feb:	31 d2                	xor    %edx,%edx
  800fed:	f7 f7                	div    %edi
  800fef:	89 c5                	mov    %eax,%ebp
  800ff1:	89 d8                	mov    %ebx,%eax
  800ff3:	31 d2                	xor    %edx,%edx
  800ff5:	f7 f5                	div    %ebp
  800ff7:	89 f0                	mov    %esi,%eax
  800ff9:	f7 f5                	div    %ebp
  800ffb:	89 d0                	mov    %edx,%eax
  800ffd:	31 d2                	xor    %edx,%edx
  800fff:	eb 8c                	jmp    800f8d <__umoddi3+0x2d>
  801001:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801008:	89 e9                	mov    %ebp,%ecx
  80100a:	ba 20 00 00 00       	mov    $0x20,%edx
  80100f:	29 ea                	sub    %ebp,%edx
  801011:	d3 e0                	shl    %cl,%eax
  801013:	89 44 24 08          	mov    %eax,0x8(%esp)
  801017:	89 d1                	mov    %edx,%ecx
  801019:	89 f8                	mov    %edi,%eax
  80101b:	d3 e8                	shr    %cl,%eax
  80101d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801021:	89 54 24 04          	mov    %edx,0x4(%esp)
  801025:	8b 54 24 04          	mov    0x4(%esp),%edx
  801029:	09 c1                	or     %eax,%ecx
  80102b:	89 d8                	mov    %ebx,%eax
  80102d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801031:	89 e9                	mov    %ebp,%ecx
  801033:	d3 e7                	shl    %cl,%edi
  801035:	89 d1                	mov    %edx,%ecx
  801037:	d3 e8                	shr    %cl,%eax
  801039:	89 e9                	mov    %ebp,%ecx
  80103b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80103f:	d3 e3                	shl    %cl,%ebx
  801041:	89 c7                	mov    %eax,%edi
  801043:	89 d1                	mov    %edx,%ecx
  801045:	89 f0                	mov    %esi,%eax
  801047:	d3 e8                	shr    %cl,%eax
  801049:	89 e9                	mov    %ebp,%ecx
  80104b:	89 fa                	mov    %edi,%edx
  80104d:	d3 e6                	shl    %cl,%esi
  80104f:	09 d8                	or     %ebx,%eax
  801051:	f7 74 24 08          	divl   0x8(%esp)
  801055:	89 d1                	mov    %edx,%ecx
  801057:	89 f3                	mov    %esi,%ebx
  801059:	f7 64 24 0c          	mull   0xc(%esp)
  80105d:	89 c6                	mov    %eax,%esi
  80105f:	89 d7                	mov    %edx,%edi
  801061:	39 d1                	cmp    %edx,%ecx
  801063:	72 06                	jb     80106b <__umoddi3+0x10b>
  801065:	75 10                	jne    801077 <__umoddi3+0x117>
  801067:	39 c3                	cmp    %eax,%ebx
  801069:	73 0c                	jae    801077 <__umoddi3+0x117>
  80106b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80106f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801073:	89 d7                	mov    %edx,%edi
  801075:	89 c6                	mov    %eax,%esi
  801077:	89 ca                	mov    %ecx,%edx
  801079:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80107e:	29 f3                	sub    %esi,%ebx
  801080:	19 fa                	sbb    %edi,%edx
  801082:	89 d0                	mov    %edx,%eax
  801084:	d3 e0                	shl    %cl,%eax
  801086:	89 e9                	mov    %ebp,%ecx
  801088:	d3 eb                	shr    %cl,%ebx
  80108a:	d3 ea                	shr    %cl,%edx
  80108c:	09 d8                	or     %ebx,%eax
  80108e:	83 c4 1c             	add    $0x1c,%esp
  801091:	5b                   	pop    %ebx
  801092:	5e                   	pop    %esi
  801093:	5f                   	pop    %edi
  801094:	5d                   	pop    %ebp
  801095:	c3                   	ret    
  801096:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80109d:	8d 76 00             	lea    0x0(%esi),%esi
  8010a0:	29 fe                	sub    %edi,%esi
  8010a2:	19 c3                	sbb    %eax,%ebx
  8010a4:	89 f2                	mov    %esi,%edx
  8010a6:	89 d9                	mov    %ebx,%ecx
  8010a8:	e9 1d ff ff ff       	jmp    800fca <__umoddi3+0x6a>
