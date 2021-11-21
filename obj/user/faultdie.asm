
obj/user/faultdie:     file format elf32-i386


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
  80002c:	e8 57 00 00 00       	call   800088 <libmain>
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
  80003a:	83 ec 0c             	sub    $0xc,%esp
  80003d:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  800040:	8b 42 04             	mov    0x4(%edx),%eax
  800043:	83 e0 07             	and    $0x7,%eax
  800046:	50                   	push   %eax
  800047:	ff 32                	pushl  (%edx)
  800049:	68 e0 10 80 00       	push   $0x8010e0
  80004e:	e8 35 01 00 00       	call   800188 <cprintf>
	sys_env_destroy(sys_getenvid());
  800053:	e8 36 0b 00 00       	call   800b8e <sys_getenvid>
  800058:	89 04 24             	mov    %eax,(%esp)
  80005b:	e8 e9 0a 00 00       	call   800b49 <sys_env_destroy>
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <umain>:

void
umain(int argc, char **argv)
{
  800065:	f3 0f 1e fb          	endbr32 
  800069:	55                   	push   %ebp
  80006a:	89 e5                	mov    %esp,%ebp
  80006c:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  80006f:	68 33 00 80 00       	push   $0x800033
  800074:	e8 26 0d 00 00       	call   800d9f <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800079:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800080:	00 00 00 
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	c9                   	leave  
  800087:	c3                   	ret    

00800088 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800088:	f3 0f 1e fb          	endbr32 
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	56                   	push   %esi
  800090:	53                   	push   %ebx
  800091:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800094:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800097:	e8 f2 0a 00 00       	call   800b8e <sys_getenvid>
	thisenv = envs + ENVX(envid);
  80009c:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a1:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  8000a7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ac:	a3 60 40 80 00       	mov    %eax,0x804060

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000b1:	85 db                	test   %ebx,%ebx
  8000b3:	7e 07                	jle    8000bc <libmain+0x34>
		binaryname = argv[0];
  8000b5:	8b 06                	mov    (%esi),%eax
  8000b7:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000bc:	83 ec 08             	sub    $0x8,%esp
  8000bf:	56                   	push   %esi
  8000c0:	53                   	push   %ebx
  8000c1:	e8 9f ff ff ff       	call   800065 <umain>

	// exit gracefully
	exit();
  8000c6:	e8 0a 00 00 00       	call   8000d5 <exit>
}
  8000cb:	83 c4 10             	add    $0x10,%esp
  8000ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5d                   	pop    %ebp
  8000d4:	c3                   	ret    

008000d5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d5:	f3 0f 1e fb          	endbr32 
  8000d9:	55                   	push   %ebp
  8000da:	89 e5                	mov    %esp,%ebp
  8000dc:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000df:	6a 00                	push   $0x0
  8000e1:	e8 63 0a 00 00       	call   800b49 <sys_env_destroy>
}
  8000e6:	83 c4 10             	add    $0x10,%esp
  8000e9:	c9                   	leave  
  8000ea:	c3                   	ret    

008000eb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000eb:	f3 0f 1e fb          	endbr32 
  8000ef:	55                   	push   %ebp
  8000f0:	89 e5                	mov    %esp,%ebp
  8000f2:	53                   	push   %ebx
  8000f3:	83 ec 04             	sub    $0x4,%esp
  8000f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000f9:	8b 13                	mov    (%ebx),%edx
  8000fb:	8d 42 01             	lea    0x1(%edx),%eax
  8000fe:	89 03                	mov    %eax,(%ebx)
  800100:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800103:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800107:	3d ff 00 00 00       	cmp    $0xff,%eax
  80010c:	74 09                	je     800117 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80010e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800112:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800115:	c9                   	leave  
  800116:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800117:	83 ec 08             	sub    $0x8,%esp
  80011a:	68 ff 00 00 00       	push   $0xff
  80011f:	8d 43 08             	lea    0x8(%ebx),%eax
  800122:	50                   	push   %eax
  800123:	e8 dc 09 00 00       	call   800b04 <sys_cputs>
		b->idx = 0;
  800128:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80012e:	83 c4 10             	add    $0x10,%esp
  800131:	eb db                	jmp    80010e <putch+0x23>

00800133 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800133:	f3 0f 1e fb          	endbr32 
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800140:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800147:	00 00 00 
	b.cnt = 0;
  80014a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800151:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800154:	ff 75 0c             	pushl  0xc(%ebp)
  800157:	ff 75 08             	pushl  0x8(%ebp)
  80015a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800160:	50                   	push   %eax
  800161:	68 eb 00 80 00       	push   $0x8000eb
  800166:	e8 20 01 00 00       	call   80028b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80016b:	83 c4 08             	add    $0x8,%esp
  80016e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800174:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017a:	50                   	push   %eax
  80017b:	e8 84 09 00 00       	call   800b04 <sys_cputs>

	return b.cnt;
}
  800180:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800186:	c9                   	leave  
  800187:	c3                   	ret    

00800188 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800188:	f3 0f 1e fb          	endbr32 
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800192:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800195:	50                   	push   %eax
  800196:	ff 75 08             	pushl  0x8(%ebp)
  800199:	e8 95 ff ff ff       	call   800133 <vcprintf>
	va_end(ap);

	return cnt;
}
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	57                   	push   %edi
  8001a4:	56                   	push   %esi
  8001a5:	53                   	push   %ebx
  8001a6:	83 ec 1c             	sub    $0x1c,%esp
  8001a9:	89 c7                	mov    %eax,%edi
  8001ab:	89 d6                	mov    %edx,%esi
  8001ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b3:	89 d1                	mov    %edx,%ecx
  8001b5:	89 c2                	mov    %eax,%edx
  8001b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001c6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001cd:	39 c2                	cmp    %eax,%edx
  8001cf:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001d2:	72 3e                	jb     800212 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d4:	83 ec 0c             	sub    $0xc,%esp
  8001d7:	ff 75 18             	pushl  0x18(%ebp)
  8001da:	83 eb 01             	sub    $0x1,%ebx
  8001dd:	53                   	push   %ebx
  8001de:	50                   	push   %eax
  8001df:	83 ec 08             	sub    $0x8,%esp
  8001e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e5:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e8:	ff 75 dc             	pushl  -0x24(%ebp)
  8001eb:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ee:	e8 7d 0c 00 00       	call   800e70 <__udivdi3>
  8001f3:	83 c4 18             	add    $0x18,%esp
  8001f6:	52                   	push   %edx
  8001f7:	50                   	push   %eax
  8001f8:	89 f2                	mov    %esi,%edx
  8001fa:	89 f8                	mov    %edi,%eax
  8001fc:	e8 9f ff ff ff       	call   8001a0 <printnum>
  800201:	83 c4 20             	add    $0x20,%esp
  800204:	eb 13                	jmp    800219 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800206:	83 ec 08             	sub    $0x8,%esp
  800209:	56                   	push   %esi
  80020a:	ff 75 18             	pushl  0x18(%ebp)
  80020d:	ff d7                	call   *%edi
  80020f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800212:	83 eb 01             	sub    $0x1,%ebx
  800215:	85 db                	test   %ebx,%ebx
  800217:	7f ed                	jg     800206 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800219:	83 ec 08             	sub    $0x8,%esp
  80021c:	56                   	push   %esi
  80021d:	83 ec 04             	sub    $0x4,%esp
  800220:	ff 75 e4             	pushl  -0x1c(%ebp)
  800223:	ff 75 e0             	pushl  -0x20(%ebp)
  800226:	ff 75 dc             	pushl  -0x24(%ebp)
  800229:	ff 75 d8             	pushl  -0x28(%ebp)
  80022c:	e8 4f 0d 00 00       	call   800f80 <__umoddi3>
  800231:	83 c4 14             	add    $0x14,%esp
  800234:	0f be 80 06 11 80 00 	movsbl 0x801106(%eax),%eax
  80023b:	50                   	push   %eax
  80023c:	ff d7                	call   *%edi
}
  80023e:	83 c4 10             	add    $0x10,%esp
  800241:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800244:	5b                   	pop    %ebx
  800245:	5e                   	pop    %esi
  800246:	5f                   	pop    %edi
  800247:	5d                   	pop    %ebp
  800248:	c3                   	ret    

00800249 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800249:	f3 0f 1e fb          	endbr32 
  80024d:	55                   	push   %ebp
  80024e:	89 e5                	mov    %esp,%ebp
  800250:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800253:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800257:	8b 10                	mov    (%eax),%edx
  800259:	3b 50 04             	cmp    0x4(%eax),%edx
  80025c:	73 0a                	jae    800268 <sprintputch+0x1f>
		*b->buf++ = ch;
  80025e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800261:	89 08                	mov    %ecx,(%eax)
  800263:	8b 45 08             	mov    0x8(%ebp),%eax
  800266:	88 02                	mov    %al,(%edx)
}
  800268:	5d                   	pop    %ebp
  800269:	c3                   	ret    

0080026a <printfmt>:
{
  80026a:	f3 0f 1e fb          	endbr32 
  80026e:	55                   	push   %ebp
  80026f:	89 e5                	mov    %esp,%ebp
  800271:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800274:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800277:	50                   	push   %eax
  800278:	ff 75 10             	pushl  0x10(%ebp)
  80027b:	ff 75 0c             	pushl  0xc(%ebp)
  80027e:	ff 75 08             	pushl  0x8(%ebp)
  800281:	e8 05 00 00 00       	call   80028b <vprintfmt>
}
  800286:	83 c4 10             	add    $0x10,%esp
  800289:	c9                   	leave  
  80028a:	c3                   	ret    

0080028b <vprintfmt>:
{
  80028b:	f3 0f 1e fb          	endbr32 
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
  800292:	57                   	push   %edi
  800293:	56                   	push   %esi
  800294:	53                   	push   %ebx
  800295:	83 ec 3c             	sub    $0x3c,%esp
  800298:	8b 75 08             	mov    0x8(%ebp),%esi
  80029b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80029e:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002a1:	e9 8e 03 00 00       	jmp    800634 <vprintfmt+0x3a9>
		padc = ' ';
  8002a6:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002aa:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002b1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002b8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002bf:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002c4:	8d 47 01             	lea    0x1(%edi),%eax
  8002c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ca:	0f b6 17             	movzbl (%edi),%edx
  8002cd:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002d0:	3c 55                	cmp    $0x55,%al
  8002d2:	0f 87 df 03 00 00    	ja     8006b7 <vprintfmt+0x42c>
  8002d8:	0f b6 c0             	movzbl %al,%eax
  8002db:	3e ff 24 85 c0 11 80 	notrack jmp *0x8011c0(,%eax,4)
  8002e2:	00 
  8002e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002e6:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002ea:	eb d8                	jmp    8002c4 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8002ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002ef:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002f3:	eb cf                	jmp    8002c4 <vprintfmt+0x39>
  8002f5:	0f b6 d2             	movzbl %dl,%edx
  8002f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800300:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800303:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800306:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80030a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80030d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800310:	83 f9 09             	cmp    $0x9,%ecx
  800313:	77 55                	ja     80036a <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800315:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800318:	eb e9                	jmp    800303 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80031a:	8b 45 14             	mov    0x14(%ebp),%eax
  80031d:	8b 00                	mov    (%eax),%eax
  80031f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800322:	8b 45 14             	mov    0x14(%ebp),%eax
  800325:	8d 40 04             	lea    0x4(%eax),%eax
  800328:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80032b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80032e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800332:	79 90                	jns    8002c4 <vprintfmt+0x39>
				width = precision, precision = -1;
  800334:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800337:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80033a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800341:	eb 81                	jmp    8002c4 <vprintfmt+0x39>
  800343:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800346:	85 c0                	test   %eax,%eax
  800348:	ba 00 00 00 00       	mov    $0x0,%edx
  80034d:	0f 49 d0             	cmovns %eax,%edx
  800350:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800353:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800356:	e9 69 ff ff ff       	jmp    8002c4 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80035b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80035e:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800365:	e9 5a ff ff ff       	jmp    8002c4 <vprintfmt+0x39>
  80036a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80036d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800370:	eb bc                	jmp    80032e <vprintfmt+0xa3>
			lflag++;
  800372:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800378:	e9 47 ff ff ff       	jmp    8002c4 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80037d:	8b 45 14             	mov    0x14(%ebp),%eax
  800380:	8d 78 04             	lea    0x4(%eax),%edi
  800383:	83 ec 08             	sub    $0x8,%esp
  800386:	53                   	push   %ebx
  800387:	ff 30                	pushl  (%eax)
  800389:	ff d6                	call   *%esi
			break;
  80038b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80038e:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800391:	e9 9b 02 00 00       	jmp    800631 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800396:	8b 45 14             	mov    0x14(%ebp),%eax
  800399:	8d 78 04             	lea    0x4(%eax),%edi
  80039c:	8b 00                	mov    (%eax),%eax
  80039e:	99                   	cltd   
  80039f:	31 d0                	xor    %edx,%eax
  8003a1:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003a3:	83 f8 08             	cmp    $0x8,%eax
  8003a6:	7f 23                	jg     8003cb <vprintfmt+0x140>
  8003a8:	8b 14 85 20 13 80 00 	mov    0x801320(,%eax,4),%edx
  8003af:	85 d2                	test   %edx,%edx
  8003b1:	74 18                	je     8003cb <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003b3:	52                   	push   %edx
  8003b4:	68 27 11 80 00       	push   $0x801127
  8003b9:	53                   	push   %ebx
  8003ba:	56                   	push   %esi
  8003bb:	e8 aa fe ff ff       	call   80026a <printfmt>
  8003c0:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003c3:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003c6:	e9 66 02 00 00       	jmp    800631 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  8003cb:	50                   	push   %eax
  8003cc:	68 1e 11 80 00       	push   $0x80111e
  8003d1:	53                   	push   %ebx
  8003d2:	56                   	push   %esi
  8003d3:	e8 92 fe ff ff       	call   80026a <printfmt>
  8003d8:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003db:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003de:	e9 4e 02 00 00       	jmp    800631 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  8003e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e6:	83 c0 04             	add    $0x4,%eax
  8003e9:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ef:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003f1:	85 d2                	test   %edx,%edx
  8003f3:	b8 17 11 80 00       	mov    $0x801117,%eax
  8003f8:	0f 45 c2             	cmovne %edx,%eax
  8003fb:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003fe:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800402:	7e 06                	jle    80040a <vprintfmt+0x17f>
  800404:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800408:	75 0d                	jne    800417 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80040a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80040d:	89 c7                	mov    %eax,%edi
  80040f:	03 45 e0             	add    -0x20(%ebp),%eax
  800412:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800415:	eb 55                	jmp    80046c <vprintfmt+0x1e1>
  800417:	83 ec 08             	sub    $0x8,%esp
  80041a:	ff 75 d8             	pushl  -0x28(%ebp)
  80041d:	ff 75 cc             	pushl  -0x34(%ebp)
  800420:	e8 46 03 00 00       	call   80076b <strnlen>
  800425:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800428:	29 c2                	sub    %eax,%edx
  80042a:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80042d:	83 c4 10             	add    $0x10,%esp
  800430:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800432:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800436:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800439:	85 ff                	test   %edi,%edi
  80043b:	7e 11                	jle    80044e <vprintfmt+0x1c3>
					putch(padc, putdat);
  80043d:	83 ec 08             	sub    $0x8,%esp
  800440:	53                   	push   %ebx
  800441:	ff 75 e0             	pushl  -0x20(%ebp)
  800444:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800446:	83 ef 01             	sub    $0x1,%edi
  800449:	83 c4 10             	add    $0x10,%esp
  80044c:	eb eb                	jmp    800439 <vprintfmt+0x1ae>
  80044e:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800451:	85 d2                	test   %edx,%edx
  800453:	b8 00 00 00 00       	mov    $0x0,%eax
  800458:	0f 49 c2             	cmovns %edx,%eax
  80045b:	29 c2                	sub    %eax,%edx
  80045d:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800460:	eb a8                	jmp    80040a <vprintfmt+0x17f>
					putch(ch, putdat);
  800462:	83 ec 08             	sub    $0x8,%esp
  800465:	53                   	push   %ebx
  800466:	52                   	push   %edx
  800467:	ff d6                	call   *%esi
  800469:	83 c4 10             	add    $0x10,%esp
  80046c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80046f:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800471:	83 c7 01             	add    $0x1,%edi
  800474:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800478:	0f be d0             	movsbl %al,%edx
  80047b:	85 d2                	test   %edx,%edx
  80047d:	74 4b                	je     8004ca <vprintfmt+0x23f>
  80047f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800483:	78 06                	js     80048b <vprintfmt+0x200>
  800485:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800489:	78 1e                	js     8004a9 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80048b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80048f:	74 d1                	je     800462 <vprintfmt+0x1d7>
  800491:	0f be c0             	movsbl %al,%eax
  800494:	83 e8 20             	sub    $0x20,%eax
  800497:	83 f8 5e             	cmp    $0x5e,%eax
  80049a:	76 c6                	jbe    800462 <vprintfmt+0x1d7>
					putch('?', putdat);
  80049c:	83 ec 08             	sub    $0x8,%esp
  80049f:	53                   	push   %ebx
  8004a0:	6a 3f                	push   $0x3f
  8004a2:	ff d6                	call   *%esi
  8004a4:	83 c4 10             	add    $0x10,%esp
  8004a7:	eb c3                	jmp    80046c <vprintfmt+0x1e1>
  8004a9:	89 cf                	mov    %ecx,%edi
  8004ab:	eb 0e                	jmp    8004bb <vprintfmt+0x230>
				putch(' ', putdat);
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	53                   	push   %ebx
  8004b1:	6a 20                	push   $0x20
  8004b3:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004b5:	83 ef 01             	sub    $0x1,%edi
  8004b8:	83 c4 10             	add    $0x10,%esp
  8004bb:	85 ff                	test   %edi,%edi
  8004bd:	7f ee                	jg     8004ad <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004bf:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004c2:	89 45 14             	mov    %eax,0x14(%ebp)
  8004c5:	e9 67 01 00 00       	jmp    800631 <vprintfmt+0x3a6>
  8004ca:	89 cf                	mov    %ecx,%edi
  8004cc:	eb ed                	jmp    8004bb <vprintfmt+0x230>
	if (lflag >= 2)
  8004ce:	83 f9 01             	cmp    $0x1,%ecx
  8004d1:	7f 1b                	jg     8004ee <vprintfmt+0x263>
	else if (lflag)
  8004d3:	85 c9                	test   %ecx,%ecx
  8004d5:	74 63                	je     80053a <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8004d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004da:	8b 00                	mov    (%eax),%eax
  8004dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004df:	99                   	cltd   
  8004e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e6:	8d 40 04             	lea    0x4(%eax),%eax
  8004e9:	89 45 14             	mov    %eax,0x14(%ebp)
  8004ec:	eb 17                	jmp    800505 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8004ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f1:	8b 50 04             	mov    0x4(%eax),%edx
  8004f4:	8b 00                	mov    (%eax),%eax
  8004f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ff:	8d 40 08             	lea    0x8(%eax),%eax
  800502:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800505:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800508:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80050b:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800510:	85 c9                	test   %ecx,%ecx
  800512:	0f 89 ff 00 00 00    	jns    800617 <vprintfmt+0x38c>
				putch('-', putdat);
  800518:	83 ec 08             	sub    $0x8,%esp
  80051b:	53                   	push   %ebx
  80051c:	6a 2d                	push   $0x2d
  80051e:	ff d6                	call   *%esi
				num = -(long long) num;
  800520:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800523:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800526:	f7 da                	neg    %edx
  800528:	83 d1 00             	adc    $0x0,%ecx
  80052b:	f7 d9                	neg    %ecx
  80052d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800530:	b8 0a 00 00 00       	mov    $0xa,%eax
  800535:	e9 dd 00 00 00       	jmp    800617 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  80053a:	8b 45 14             	mov    0x14(%ebp),%eax
  80053d:	8b 00                	mov    (%eax),%eax
  80053f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800542:	99                   	cltd   
  800543:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800546:	8b 45 14             	mov    0x14(%ebp),%eax
  800549:	8d 40 04             	lea    0x4(%eax),%eax
  80054c:	89 45 14             	mov    %eax,0x14(%ebp)
  80054f:	eb b4                	jmp    800505 <vprintfmt+0x27a>
	if (lflag >= 2)
  800551:	83 f9 01             	cmp    $0x1,%ecx
  800554:	7f 1e                	jg     800574 <vprintfmt+0x2e9>
	else if (lflag)
  800556:	85 c9                	test   %ecx,%ecx
  800558:	74 32                	je     80058c <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8b 10                	mov    (%eax),%edx
  80055f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800564:	8d 40 04             	lea    0x4(%eax),%eax
  800567:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80056a:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80056f:	e9 a3 00 00 00       	jmp    800617 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8b 10                	mov    (%eax),%edx
  800579:	8b 48 04             	mov    0x4(%eax),%ecx
  80057c:	8d 40 08             	lea    0x8(%eax),%eax
  80057f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800582:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800587:	e9 8b 00 00 00       	jmp    800617 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	8b 10                	mov    (%eax),%edx
  800591:	b9 00 00 00 00       	mov    $0x0,%ecx
  800596:	8d 40 04             	lea    0x4(%eax),%eax
  800599:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80059c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005a1:	eb 74                	jmp    800617 <vprintfmt+0x38c>
	if (lflag >= 2)
  8005a3:	83 f9 01             	cmp    $0x1,%ecx
  8005a6:	7f 1b                	jg     8005c3 <vprintfmt+0x338>
	else if (lflag)
  8005a8:	85 c9                	test   %ecx,%ecx
  8005aa:	74 2c                	je     8005d8 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8b 10                	mov    (%eax),%edx
  8005b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b6:	8d 40 04             	lea    0x4(%eax),%eax
  8005b9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005bc:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  8005c1:	eb 54                	jmp    800617 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8b 10                	mov    (%eax),%edx
  8005c8:	8b 48 04             	mov    0x4(%eax),%ecx
  8005cb:	8d 40 08             	lea    0x8(%eax),%eax
  8005ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005d1:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  8005d6:	eb 3f                	jmp    800617 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8005d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005db:	8b 10                	mov    (%eax),%edx
  8005dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e2:	8d 40 04             	lea    0x4(%eax),%eax
  8005e5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005e8:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  8005ed:	eb 28                	jmp    800617 <vprintfmt+0x38c>
			putch('0', putdat);
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	53                   	push   %ebx
  8005f3:	6a 30                	push   $0x30
  8005f5:	ff d6                	call   *%esi
			putch('x', putdat);
  8005f7:	83 c4 08             	add    $0x8,%esp
  8005fa:	53                   	push   %ebx
  8005fb:	6a 78                	push   $0x78
  8005fd:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800602:	8b 10                	mov    (%eax),%edx
  800604:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800609:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80060c:	8d 40 04             	lea    0x4(%eax),%eax
  80060f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800612:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800617:	83 ec 0c             	sub    $0xc,%esp
  80061a:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80061e:	57                   	push   %edi
  80061f:	ff 75 e0             	pushl  -0x20(%ebp)
  800622:	50                   	push   %eax
  800623:	51                   	push   %ecx
  800624:	52                   	push   %edx
  800625:	89 da                	mov    %ebx,%edx
  800627:	89 f0                	mov    %esi,%eax
  800629:	e8 72 fb ff ff       	call   8001a0 <printnum>
			break;
  80062e:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800631:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {	
  800634:	83 c7 01             	add    $0x1,%edi
  800637:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80063b:	83 f8 25             	cmp    $0x25,%eax
  80063e:	0f 84 62 fc ff ff    	je     8002a6 <vprintfmt+0x1b>
			if (ch == '\0')										
  800644:	85 c0                	test   %eax,%eax
  800646:	0f 84 8b 00 00 00    	je     8006d7 <vprintfmt+0x44c>
			putch(ch, putdat);
  80064c:	83 ec 08             	sub    $0x8,%esp
  80064f:	53                   	push   %ebx
  800650:	50                   	push   %eax
  800651:	ff d6                	call   *%esi
  800653:	83 c4 10             	add    $0x10,%esp
  800656:	eb dc                	jmp    800634 <vprintfmt+0x3a9>
	if (lflag >= 2)
  800658:	83 f9 01             	cmp    $0x1,%ecx
  80065b:	7f 1b                	jg     800678 <vprintfmt+0x3ed>
	else if (lflag)
  80065d:	85 c9                	test   %ecx,%ecx
  80065f:	74 2c                	je     80068d <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800661:	8b 45 14             	mov    0x14(%ebp),%eax
  800664:	8b 10                	mov    (%eax),%edx
  800666:	b9 00 00 00 00       	mov    $0x0,%ecx
  80066b:	8d 40 04             	lea    0x4(%eax),%eax
  80066e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800671:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800676:	eb 9f                	jmp    800617 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8b 10                	mov    (%eax),%edx
  80067d:	8b 48 04             	mov    0x4(%eax),%ecx
  800680:	8d 40 08             	lea    0x8(%eax),%eax
  800683:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800686:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80068b:	eb 8a                	jmp    800617 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80068d:	8b 45 14             	mov    0x14(%ebp),%eax
  800690:	8b 10                	mov    (%eax),%edx
  800692:	b9 00 00 00 00       	mov    $0x0,%ecx
  800697:	8d 40 04             	lea    0x4(%eax),%eax
  80069a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80069d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006a2:	e9 70 ff ff ff       	jmp    800617 <vprintfmt+0x38c>
			putch(ch, putdat);
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	53                   	push   %ebx
  8006ab:	6a 25                	push   $0x25
  8006ad:	ff d6                	call   *%esi
			break;
  8006af:	83 c4 10             	add    $0x10,%esp
  8006b2:	e9 7a ff ff ff       	jmp    800631 <vprintfmt+0x3a6>
			putch('%', putdat);
  8006b7:	83 ec 08             	sub    $0x8,%esp
  8006ba:	53                   	push   %ebx
  8006bb:	6a 25                	push   $0x25
  8006bd:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006bf:	83 c4 10             	add    $0x10,%esp
  8006c2:	89 f8                	mov    %edi,%eax
  8006c4:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006c8:	74 05                	je     8006cf <vprintfmt+0x444>
  8006ca:	83 e8 01             	sub    $0x1,%eax
  8006cd:	eb f5                	jmp    8006c4 <vprintfmt+0x439>
  8006cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006d2:	e9 5a ff ff ff       	jmp    800631 <vprintfmt+0x3a6>
}
  8006d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006da:	5b                   	pop    %ebx
  8006db:	5e                   	pop    %esi
  8006dc:	5f                   	pop    %edi
  8006dd:	5d                   	pop    %ebp
  8006de:	c3                   	ret    

008006df <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006df:	f3 0f 1e fb          	endbr32 
  8006e3:	55                   	push   %ebp
  8006e4:	89 e5                	mov    %esp,%ebp
  8006e6:	83 ec 18             	sub    $0x18,%esp
  8006e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ec:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006f2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800700:	85 c0                	test   %eax,%eax
  800702:	74 26                	je     80072a <vsnprintf+0x4b>
  800704:	85 d2                	test   %edx,%edx
  800706:	7e 22                	jle    80072a <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800708:	ff 75 14             	pushl  0x14(%ebp)
  80070b:	ff 75 10             	pushl  0x10(%ebp)
  80070e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800711:	50                   	push   %eax
  800712:	68 49 02 80 00       	push   $0x800249
  800717:	e8 6f fb ff ff       	call   80028b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80071c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80071f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800722:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800725:	83 c4 10             	add    $0x10,%esp
}
  800728:	c9                   	leave  
  800729:	c3                   	ret    
		return -E_INVAL;
  80072a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80072f:	eb f7                	jmp    800728 <vsnprintf+0x49>

00800731 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800731:	f3 0f 1e fb          	endbr32 
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80073b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80073e:	50                   	push   %eax
  80073f:	ff 75 10             	pushl  0x10(%ebp)
  800742:	ff 75 0c             	pushl  0xc(%ebp)
  800745:	ff 75 08             	pushl  0x8(%ebp)
  800748:	e8 92 ff ff ff       	call   8006df <vsnprintf>
	va_end(ap);

	return rc;
}
  80074d:	c9                   	leave  
  80074e:	c3                   	ret    

0080074f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80074f:	f3 0f 1e fb          	endbr32 
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800759:	b8 00 00 00 00       	mov    $0x0,%eax
  80075e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800762:	74 05                	je     800769 <strlen+0x1a>
		n++;
  800764:	83 c0 01             	add    $0x1,%eax
  800767:	eb f5                	jmp    80075e <strlen+0xf>
	return n;
}
  800769:	5d                   	pop    %ebp
  80076a:	c3                   	ret    

0080076b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80076b:	f3 0f 1e fb          	endbr32 
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800775:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800778:	b8 00 00 00 00       	mov    $0x0,%eax
  80077d:	39 d0                	cmp    %edx,%eax
  80077f:	74 0d                	je     80078e <strnlen+0x23>
  800781:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800785:	74 05                	je     80078c <strnlen+0x21>
		n++;
  800787:	83 c0 01             	add    $0x1,%eax
  80078a:	eb f1                	jmp    80077d <strnlen+0x12>
  80078c:	89 c2                	mov    %eax,%edx
	return n;
}
  80078e:	89 d0                	mov    %edx,%eax
  800790:	5d                   	pop    %ebp
  800791:	c3                   	ret    

00800792 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800792:	f3 0f 1e fb          	endbr32 
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	53                   	push   %ebx
  80079a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a5:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007a9:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007ac:	83 c0 01             	add    $0x1,%eax
  8007af:	84 d2                	test   %dl,%dl
  8007b1:	75 f2                	jne    8007a5 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007b3:	89 c8                	mov    %ecx,%eax
  8007b5:	5b                   	pop    %ebx
  8007b6:	5d                   	pop    %ebp
  8007b7:	c3                   	ret    

008007b8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b8:	f3 0f 1e fb          	endbr32 
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	53                   	push   %ebx
  8007c0:	83 ec 10             	sub    $0x10,%esp
  8007c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c6:	53                   	push   %ebx
  8007c7:	e8 83 ff ff ff       	call   80074f <strlen>
  8007cc:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007cf:	ff 75 0c             	pushl  0xc(%ebp)
  8007d2:	01 d8                	add    %ebx,%eax
  8007d4:	50                   	push   %eax
  8007d5:	e8 b8 ff ff ff       	call   800792 <strcpy>
	return dst;
}
  8007da:	89 d8                	mov    %ebx,%eax
  8007dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007df:	c9                   	leave  
  8007e0:	c3                   	ret    

008007e1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007e1:	f3 0f 1e fb          	endbr32 
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	56                   	push   %esi
  8007e9:	53                   	push   %ebx
  8007ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f0:	89 f3                	mov    %esi,%ebx
  8007f2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f5:	89 f0                	mov    %esi,%eax
  8007f7:	39 d8                	cmp    %ebx,%eax
  8007f9:	74 11                	je     80080c <strncpy+0x2b>
		*dst++ = *src;
  8007fb:	83 c0 01             	add    $0x1,%eax
  8007fe:	0f b6 0a             	movzbl (%edx),%ecx
  800801:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800804:	80 f9 01             	cmp    $0x1,%cl
  800807:	83 da ff             	sbb    $0xffffffff,%edx
  80080a:	eb eb                	jmp    8007f7 <strncpy+0x16>
	}
	return ret;
}
  80080c:	89 f0                	mov    %esi,%eax
  80080e:	5b                   	pop    %ebx
  80080f:	5e                   	pop    %esi
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800812:	f3 0f 1e fb          	endbr32 
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	56                   	push   %esi
  80081a:	53                   	push   %ebx
  80081b:	8b 75 08             	mov    0x8(%ebp),%esi
  80081e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800821:	8b 55 10             	mov    0x10(%ebp),%edx
  800824:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800826:	85 d2                	test   %edx,%edx
  800828:	74 21                	je     80084b <strlcpy+0x39>
  80082a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80082e:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800830:	39 c2                	cmp    %eax,%edx
  800832:	74 14                	je     800848 <strlcpy+0x36>
  800834:	0f b6 19             	movzbl (%ecx),%ebx
  800837:	84 db                	test   %bl,%bl
  800839:	74 0b                	je     800846 <strlcpy+0x34>
			*dst++ = *src++;
  80083b:	83 c1 01             	add    $0x1,%ecx
  80083e:	83 c2 01             	add    $0x1,%edx
  800841:	88 5a ff             	mov    %bl,-0x1(%edx)
  800844:	eb ea                	jmp    800830 <strlcpy+0x1e>
  800846:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800848:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80084b:	29 f0                	sub    %esi,%eax
}
  80084d:	5b                   	pop    %ebx
  80084e:	5e                   	pop    %esi
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800851:	f3 0f 1e fb          	endbr32 
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80085e:	0f b6 01             	movzbl (%ecx),%eax
  800861:	84 c0                	test   %al,%al
  800863:	74 0c                	je     800871 <strcmp+0x20>
  800865:	3a 02                	cmp    (%edx),%al
  800867:	75 08                	jne    800871 <strcmp+0x20>
		p++, q++;
  800869:	83 c1 01             	add    $0x1,%ecx
  80086c:	83 c2 01             	add    $0x1,%edx
  80086f:	eb ed                	jmp    80085e <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800871:	0f b6 c0             	movzbl %al,%eax
  800874:	0f b6 12             	movzbl (%edx),%edx
  800877:	29 d0                	sub    %edx,%eax
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80087b:	f3 0f 1e fb          	endbr32 
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	53                   	push   %ebx
  800883:	8b 45 08             	mov    0x8(%ebp),%eax
  800886:	8b 55 0c             	mov    0xc(%ebp),%edx
  800889:	89 c3                	mov    %eax,%ebx
  80088b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80088e:	eb 06                	jmp    800896 <strncmp+0x1b>
		n--, p++, q++;
  800890:	83 c0 01             	add    $0x1,%eax
  800893:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800896:	39 d8                	cmp    %ebx,%eax
  800898:	74 16                	je     8008b0 <strncmp+0x35>
  80089a:	0f b6 08             	movzbl (%eax),%ecx
  80089d:	84 c9                	test   %cl,%cl
  80089f:	74 04                	je     8008a5 <strncmp+0x2a>
  8008a1:	3a 0a                	cmp    (%edx),%cl
  8008a3:	74 eb                	je     800890 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a5:	0f b6 00             	movzbl (%eax),%eax
  8008a8:	0f b6 12             	movzbl (%edx),%edx
  8008ab:	29 d0                	sub    %edx,%eax
}
  8008ad:	5b                   	pop    %ebx
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    
		return 0;
  8008b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b5:	eb f6                	jmp    8008ad <strncmp+0x32>

008008b7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b7:	f3 0f 1e fb          	endbr32 
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c5:	0f b6 10             	movzbl (%eax),%edx
  8008c8:	84 d2                	test   %dl,%dl
  8008ca:	74 09                	je     8008d5 <strchr+0x1e>
		if (*s == c)
  8008cc:	38 ca                	cmp    %cl,%dl
  8008ce:	74 0a                	je     8008da <strchr+0x23>
	for (; *s; s++)
  8008d0:	83 c0 01             	add    $0x1,%eax
  8008d3:	eb f0                	jmp    8008c5 <strchr+0xe>
			return (char *) s;
	return 0;
  8008d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008da:	5d                   	pop    %ebp
  8008db:	c3                   	ret    

008008dc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008dc:	f3 0f 1e fb          	endbr32 
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ea:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008ed:	38 ca                	cmp    %cl,%dl
  8008ef:	74 09                	je     8008fa <strfind+0x1e>
  8008f1:	84 d2                	test   %dl,%dl
  8008f3:	74 05                	je     8008fa <strfind+0x1e>
	for (; *s; s++)
  8008f5:	83 c0 01             	add    $0x1,%eax
  8008f8:	eb f0                	jmp    8008ea <strfind+0xe>
			break;
	return (char *) s;
}
  8008fa:	5d                   	pop    %ebp
  8008fb:	c3                   	ret    

008008fc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fc:	f3 0f 1e fb          	endbr32 
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	57                   	push   %edi
  800904:	56                   	push   %esi
  800905:	53                   	push   %ebx
  800906:	8b 7d 08             	mov    0x8(%ebp),%edi
  800909:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80090c:	85 c9                	test   %ecx,%ecx
  80090e:	74 31                	je     800941 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800910:	89 f8                	mov    %edi,%eax
  800912:	09 c8                	or     %ecx,%eax
  800914:	a8 03                	test   $0x3,%al
  800916:	75 23                	jne    80093b <memset+0x3f>
		c &= 0xFF;
  800918:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091c:	89 d3                	mov    %edx,%ebx
  80091e:	c1 e3 08             	shl    $0x8,%ebx
  800921:	89 d0                	mov    %edx,%eax
  800923:	c1 e0 18             	shl    $0x18,%eax
  800926:	89 d6                	mov    %edx,%esi
  800928:	c1 e6 10             	shl    $0x10,%esi
  80092b:	09 f0                	or     %esi,%eax
  80092d:	09 c2                	or     %eax,%edx
  80092f:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800931:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800934:	89 d0                	mov    %edx,%eax
  800936:	fc                   	cld    
  800937:	f3 ab                	rep stos %eax,%es:(%edi)
  800939:	eb 06                	jmp    800941 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093e:	fc                   	cld    
  80093f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800941:	89 f8                	mov    %edi,%eax
  800943:	5b                   	pop    %ebx
  800944:	5e                   	pop    %esi
  800945:	5f                   	pop    %edi
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800948:	f3 0f 1e fb          	endbr32 
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	57                   	push   %edi
  800950:	56                   	push   %esi
  800951:	8b 45 08             	mov    0x8(%ebp),%eax
  800954:	8b 75 0c             	mov    0xc(%ebp),%esi
  800957:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80095a:	39 c6                	cmp    %eax,%esi
  80095c:	73 32                	jae    800990 <memmove+0x48>
  80095e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800961:	39 c2                	cmp    %eax,%edx
  800963:	76 2b                	jbe    800990 <memmove+0x48>
		s += n;
		d += n;
  800965:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800968:	89 fe                	mov    %edi,%esi
  80096a:	09 ce                	or     %ecx,%esi
  80096c:	09 d6                	or     %edx,%esi
  80096e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800974:	75 0e                	jne    800984 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800976:	83 ef 04             	sub    $0x4,%edi
  800979:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80097f:	fd                   	std    
  800980:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800982:	eb 09                	jmp    80098d <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800984:	83 ef 01             	sub    $0x1,%edi
  800987:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80098a:	fd                   	std    
  80098b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098d:	fc                   	cld    
  80098e:	eb 1a                	jmp    8009aa <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800990:	89 c2                	mov    %eax,%edx
  800992:	09 ca                	or     %ecx,%edx
  800994:	09 f2                	or     %esi,%edx
  800996:	f6 c2 03             	test   $0x3,%dl
  800999:	75 0a                	jne    8009a5 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80099b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80099e:	89 c7                	mov    %eax,%edi
  8009a0:	fc                   	cld    
  8009a1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a3:	eb 05                	jmp    8009aa <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009a5:	89 c7                	mov    %eax,%edi
  8009a7:	fc                   	cld    
  8009a8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009aa:	5e                   	pop    %esi
  8009ab:	5f                   	pop    %edi
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ae:	f3 0f 1e fb          	endbr32 
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009b8:	ff 75 10             	pushl  0x10(%ebp)
  8009bb:	ff 75 0c             	pushl  0xc(%ebp)
  8009be:	ff 75 08             	pushl  0x8(%ebp)
  8009c1:	e8 82 ff ff ff       	call   800948 <memmove>
}
  8009c6:	c9                   	leave  
  8009c7:	c3                   	ret    

008009c8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c8:	f3 0f 1e fb          	endbr32 
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	56                   	push   %esi
  8009d0:	53                   	push   %ebx
  8009d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d7:	89 c6                	mov    %eax,%esi
  8009d9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009dc:	39 f0                	cmp    %esi,%eax
  8009de:	74 1c                	je     8009fc <memcmp+0x34>
		if (*s1 != *s2)
  8009e0:	0f b6 08             	movzbl (%eax),%ecx
  8009e3:	0f b6 1a             	movzbl (%edx),%ebx
  8009e6:	38 d9                	cmp    %bl,%cl
  8009e8:	75 08                	jne    8009f2 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009ea:	83 c0 01             	add    $0x1,%eax
  8009ed:	83 c2 01             	add    $0x1,%edx
  8009f0:	eb ea                	jmp    8009dc <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8009f2:	0f b6 c1             	movzbl %cl,%eax
  8009f5:	0f b6 db             	movzbl %bl,%ebx
  8009f8:	29 d8                	sub    %ebx,%eax
  8009fa:	eb 05                	jmp    800a01 <memcmp+0x39>
	}

	return 0;
  8009fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a01:	5b                   	pop    %ebx
  800a02:	5e                   	pop    %esi
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    

00800a05 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a05:	f3 0f 1e fb          	endbr32 
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
  800a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a12:	89 c2                	mov    %eax,%edx
  800a14:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a17:	39 d0                	cmp    %edx,%eax
  800a19:	73 09                	jae    800a24 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a1b:	38 08                	cmp    %cl,(%eax)
  800a1d:	74 05                	je     800a24 <memfind+0x1f>
	for (; s < ends; s++)
  800a1f:	83 c0 01             	add    $0x1,%eax
  800a22:	eb f3                	jmp    800a17 <memfind+0x12>
			break;
	return (void *) s;
}
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a26:	f3 0f 1e fb          	endbr32 
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	57                   	push   %edi
  800a2e:	56                   	push   %esi
  800a2f:	53                   	push   %ebx
  800a30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a33:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a36:	eb 03                	jmp    800a3b <strtol+0x15>
		s++;
  800a38:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a3b:	0f b6 01             	movzbl (%ecx),%eax
  800a3e:	3c 20                	cmp    $0x20,%al
  800a40:	74 f6                	je     800a38 <strtol+0x12>
  800a42:	3c 09                	cmp    $0x9,%al
  800a44:	74 f2                	je     800a38 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a46:	3c 2b                	cmp    $0x2b,%al
  800a48:	74 2a                	je     800a74 <strtol+0x4e>
	int neg = 0;
  800a4a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a4f:	3c 2d                	cmp    $0x2d,%al
  800a51:	74 2b                	je     800a7e <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a53:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a59:	75 0f                	jne    800a6a <strtol+0x44>
  800a5b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a5e:	74 28                	je     800a88 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a60:	85 db                	test   %ebx,%ebx
  800a62:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a67:	0f 44 d8             	cmove  %eax,%ebx
  800a6a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a72:	eb 46                	jmp    800aba <strtol+0x94>
		s++;
  800a74:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a77:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7c:	eb d5                	jmp    800a53 <strtol+0x2d>
		s++, neg = 1;
  800a7e:	83 c1 01             	add    $0x1,%ecx
  800a81:	bf 01 00 00 00       	mov    $0x1,%edi
  800a86:	eb cb                	jmp    800a53 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a88:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a8c:	74 0e                	je     800a9c <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a8e:	85 db                	test   %ebx,%ebx
  800a90:	75 d8                	jne    800a6a <strtol+0x44>
		s++, base = 8;
  800a92:	83 c1 01             	add    $0x1,%ecx
  800a95:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a9a:	eb ce                	jmp    800a6a <strtol+0x44>
		s += 2, base = 16;
  800a9c:	83 c1 02             	add    $0x2,%ecx
  800a9f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa4:	eb c4                	jmp    800a6a <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800aa6:	0f be d2             	movsbl %dl,%edx
  800aa9:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aac:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aaf:	7d 3a                	jge    800aeb <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ab1:	83 c1 01             	add    $0x1,%ecx
  800ab4:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab8:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800aba:	0f b6 11             	movzbl (%ecx),%edx
  800abd:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ac0:	89 f3                	mov    %esi,%ebx
  800ac2:	80 fb 09             	cmp    $0x9,%bl
  800ac5:	76 df                	jbe    800aa6 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800ac7:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aca:	89 f3                	mov    %esi,%ebx
  800acc:	80 fb 19             	cmp    $0x19,%bl
  800acf:	77 08                	ja     800ad9 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ad1:	0f be d2             	movsbl %dl,%edx
  800ad4:	83 ea 57             	sub    $0x57,%edx
  800ad7:	eb d3                	jmp    800aac <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800ad9:	8d 72 bf             	lea    -0x41(%edx),%esi
  800adc:	89 f3                	mov    %esi,%ebx
  800ade:	80 fb 19             	cmp    $0x19,%bl
  800ae1:	77 08                	ja     800aeb <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ae3:	0f be d2             	movsbl %dl,%edx
  800ae6:	83 ea 37             	sub    $0x37,%edx
  800ae9:	eb c1                	jmp    800aac <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800aeb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aef:	74 05                	je     800af6 <strtol+0xd0>
		*endptr = (char *) s;
  800af1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af4:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800af6:	89 c2                	mov    %eax,%edx
  800af8:	f7 da                	neg    %edx
  800afa:	85 ff                	test   %edi,%edi
  800afc:	0f 45 c2             	cmovne %edx,%eax
}
  800aff:	5b                   	pop    %ebx
  800b00:	5e                   	pop    %esi
  800b01:	5f                   	pop    %edi
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b04:	f3 0f 1e fb          	endbr32 
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	57                   	push   %edi
  800b0c:	56                   	push   %esi
  800b0d:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800b0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800b13:	8b 55 08             	mov    0x8(%ebp),%edx
  800b16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b19:	89 c3                	mov    %eax,%ebx
  800b1b:	89 c7                	mov    %eax,%edi
  800b1d:	89 c6                	mov    %eax,%esi
  800b1f:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b21:	5b                   	pop    %ebx
  800b22:	5e                   	pop    %esi
  800b23:	5f                   	pop    %edi
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b26:	f3 0f 1e fb          	endbr32 
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	57                   	push   %edi
  800b2e:	56                   	push   %esi
  800b2f:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800b30:	ba 00 00 00 00       	mov    $0x0,%edx
  800b35:	b8 01 00 00 00       	mov    $0x1,%eax
  800b3a:	89 d1                	mov    %edx,%ecx
  800b3c:	89 d3                	mov    %edx,%ebx
  800b3e:	89 d7                	mov    %edx,%edi
  800b40:	89 d6                	mov    %edx,%esi
  800b42:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b44:	5b                   	pop    %ebx
  800b45:	5e                   	pop    %esi
  800b46:	5f                   	pop    %edi
  800b47:	5d                   	pop    %ebp
  800b48:	c3                   	ret    

00800b49 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b49:	f3 0f 1e fb          	endbr32 
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	57                   	push   %edi
  800b51:	56                   	push   %esi
  800b52:	53                   	push   %ebx
  800b53:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800b56:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5e:	b8 03 00 00 00       	mov    $0x3,%eax
  800b63:	89 cb                	mov    %ecx,%ebx
  800b65:	89 cf                	mov    %ecx,%edi
  800b67:	89 ce                	mov    %ecx,%esi
  800b69:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b6b:	85 c0                	test   %eax,%eax
  800b6d:	7f 08                	jg     800b77 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b72:	5b                   	pop    %ebx
  800b73:	5e                   	pop    %esi
  800b74:	5f                   	pop    %edi
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b77:	83 ec 0c             	sub    $0xc,%esp
  800b7a:	50                   	push   %eax
  800b7b:	6a 03                	push   $0x3
  800b7d:	68 44 13 80 00       	push   $0x801344
  800b82:	6a 23                	push   $0x23
  800b84:	68 61 13 80 00       	push   $0x801361
  800b89:	e8 92 02 00 00       	call   800e20 <_panic>

00800b8e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b8e:	f3 0f 1e fb          	endbr32 
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	57                   	push   %edi
  800b96:	56                   	push   %esi
  800b97:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800b98:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9d:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba2:	89 d1                	mov    %edx,%ecx
  800ba4:	89 d3                	mov    %edx,%ebx
  800ba6:	89 d7                	mov    %edx,%edi
  800ba8:	89 d6                	mov    %edx,%esi
  800baa:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <sys_yield>:

void
sys_yield(void)
{
  800bb1:	f3 0f 1e fb          	endbr32 
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	57                   	push   %edi
  800bb9:	56                   	push   %esi
  800bba:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800bbb:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bc5:	89 d1                	mov    %edx,%ecx
  800bc7:	89 d3                	mov    %edx,%ebx
  800bc9:	89 d7                	mov    %edx,%edi
  800bcb:	89 d6                	mov    %edx,%esi
  800bcd:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bd4:	f3 0f 1e fb          	endbr32 
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	57                   	push   %edi
  800bdc:	56                   	push   %esi
  800bdd:	53                   	push   %ebx
  800bde:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800be1:	be 00 00 00 00       	mov    $0x0,%esi
  800be6:	8b 55 08             	mov    0x8(%ebp),%edx
  800be9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bec:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf4:	89 f7                	mov    %esi,%edi
  800bf6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bf8:	85 c0                	test   %eax,%eax
  800bfa:	7f 08                	jg     800c04 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bff:	5b                   	pop    %ebx
  800c00:	5e                   	pop    %esi
  800c01:	5f                   	pop    %edi
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c04:	83 ec 0c             	sub    $0xc,%esp
  800c07:	50                   	push   %eax
  800c08:	6a 04                	push   $0x4
  800c0a:	68 44 13 80 00       	push   $0x801344
  800c0f:	6a 23                	push   $0x23
  800c11:	68 61 13 80 00       	push   $0x801361
  800c16:	e8 05 02 00 00       	call   800e20 <_panic>

00800c1b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c1b:	f3 0f 1e fb          	endbr32 
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	57                   	push   %edi
  800c23:	56                   	push   %esi
  800c24:	53                   	push   %ebx
  800c25:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c28:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c33:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c36:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c39:	8b 75 18             	mov    0x18(%ebp),%esi
  800c3c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c3e:	85 c0                	test   %eax,%eax
  800c40:	7f 08                	jg     800c4a <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4a:	83 ec 0c             	sub    $0xc,%esp
  800c4d:	50                   	push   %eax
  800c4e:	6a 05                	push   $0x5
  800c50:	68 44 13 80 00       	push   $0x801344
  800c55:	6a 23                	push   $0x23
  800c57:	68 61 13 80 00       	push   $0x801361
  800c5c:	e8 bf 01 00 00       	call   800e20 <_panic>

00800c61 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c61:	f3 0f 1e fb          	endbr32 
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	57                   	push   %edi
  800c69:	56                   	push   %esi
  800c6a:	53                   	push   %ebx
  800c6b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c73:	8b 55 08             	mov    0x8(%ebp),%edx
  800c76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c79:	b8 06 00 00 00       	mov    $0x6,%eax
  800c7e:	89 df                	mov    %ebx,%edi
  800c80:	89 de                	mov    %ebx,%esi
  800c82:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c84:	85 c0                	test   %eax,%eax
  800c86:	7f 08                	jg     800c90 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c88:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8b:	5b                   	pop    %ebx
  800c8c:	5e                   	pop    %esi
  800c8d:	5f                   	pop    %edi
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c90:	83 ec 0c             	sub    $0xc,%esp
  800c93:	50                   	push   %eax
  800c94:	6a 06                	push   $0x6
  800c96:	68 44 13 80 00       	push   $0x801344
  800c9b:	6a 23                	push   $0x23
  800c9d:	68 61 13 80 00       	push   $0x801361
  800ca2:	e8 79 01 00 00       	call   800e20 <_panic>

00800ca7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ca7:	f3 0f 1e fb          	endbr32 
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	57                   	push   %edi
  800caf:	56                   	push   %esi
  800cb0:	53                   	push   %ebx
  800cb1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800cb4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbf:	b8 08 00 00 00       	mov    $0x8,%eax
  800cc4:	89 df                	mov    %ebx,%edi
  800cc6:	89 de                	mov    %ebx,%esi
  800cc8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cca:	85 c0                	test   %eax,%eax
  800ccc:	7f 08                	jg     800cd6 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd1:	5b                   	pop    %ebx
  800cd2:	5e                   	pop    %esi
  800cd3:	5f                   	pop    %edi
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd6:	83 ec 0c             	sub    $0xc,%esp
  800cd9:	50                   	push   %eax
  800cda:	6a 08                	push   $0x8
  800cdc:	68 44 13 80 00       	push   $0x801344
  800ce1:	6a 23                	push   $0x23
  800ce3:	68 61 13 80 00       	push   $0x801361
  800ce8:	e8 33 01 00 00       	call   800e20 <_panic>

00800ced <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ced:	f3 0f 1e fb          	endbr32 
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	57                   	push   %edi
  800cf5:	56                   	push   %esi
  800cf6:	53                   	push   %ebx
  800cf7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800cfa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cff:	8b 55 08             	mov    0x8(%ebp),%edx
  800d02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d05:	b8 09 00 00 00       	mov    $0x9,%eax
  800d0a:	89 df                	mov    %ebx,%edi
  800d0c:	89 de                	mov    %ebx,%esi
  800d0e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d10:	85 c0                	test   %eax,%eax
  800d12:	7f 08                	jg     800d1c <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d17:	5b                   	pop    %ebx
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1c:	83 ec 0c             	sub    $0xc,%esp
  800d1f:	50                   	push   %eax
  800d20:	6a 09                	push   $0x9
  800d22:	68 44 13 80 00       	push   $0x801344
  800d27:	6a 23                	push   $0x23
  800d29:	68 61 13 80 00       	push   $0x801361
  800d2e:	e8 ed 00 00 00       	call   800e20 <_panic>

00800d33 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d33:	f3 0f 1e fb          	endbr32 
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	57                   	push   %edi
  800d3b:	56                   	push   %esi
  800d3c:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d43:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d48:	be 00 00 00 00       	mov    $0x0,%esi
  800d4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d50:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d53:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d55:	5b                   	pop    %ebx
  800d56:	5e                   	pop    %esi
  800d57:	5f                   	pop    %edi
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    

00800d5a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d5a:	f3 0f 1e fb          	endbr32 
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d67:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d74:	89 cb                	mov    %ecx,%ebx
  800d76:	89 cf                	mov    %ecx,%edi
  800d78:	89 ce                	mov    %ecx,%esi
  800d7a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	7f 08                	jg     800d88 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d88:	83 ec 0c             	sub    $0xc,%esp
  800d8b:	50                   	push   %eax
  800d8c:	6a 0c                	push   $0xc
  800d8e:	68 44 13 80 00       	push   $0x801344
  800d93:	6a 23                	push   $0x23
  800d95:	68 61 13 80 00       	push   $0x801361
  800d9a:	e8 81 00 00 00       	call   800e20 <_panic>

00800d9f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d9f:	f3 0f 1e fb          	endbr32 
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800da9:	83 3d 64 40 80 00 00 	cmpl   $0x0,0x804064
  800db0:	74 0a                	je     800dbc <set_pgfault_handler+0x1d>
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);		//系统调用，设置进程的env_pgfault_upcall属性
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800db2:	8b 45 08             	mov    0x8(%ebp),%eax
  800db5:	a3 64 40 80 00       	mov    %eax,0x804064
}
  800dba:	c9                   	leave  
  800dbb:	c3                   	ret    
		int r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_W | PTE_U | PTE_P);	//为当前进程分配异常栈
  800dbc:	83 ec 04             	sub    $0x4,%esp
  800dbf:	6a 07                	push   $0x7
  800dc1:	68 00 f0 bf ee       	push   $0xeebff000
  800dc6:	6a 00                	push   $0x0
  800dc8:	e8 07 fe ff ff       	call   800bd4 <sys_page_alloc>
		if (r < 0) {
  800dcd:	83 c4 10             	add    $0x10,%esp
  800dd0:	85 c0                	test   %eax,%eax
  800dd2:	78 14                	js     800de8 <set_pgfault_handler+0x49>
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);		//系统调用，设置进程的env_pgfault_upcall属性
  800dd4:	83 ec 08             	sub    $0x8,%esp
  800dd7:	68 fc 0d 80 00       	push   $0x800dfc
  800ddc:	6a 00                	push   $0x0
  800dde:	e8 0a ff ff ff       	call   800ced <sys_env_set_pgfault_upcall>
  800de3:	83 c4 10             	add    $0x10,%esp
  800de6:	eb ca                	jmp    800db2 <set_pgfault_handler+0x13>
			panic("set_pgfault_handler:sys_page_alloc failed");;
  800de8:	83 ec 04             	sub    $0x4,%esp
  800deb:	68 70 13 80 00       	push   $0x801370
  800df0:	6a 22                	push   $0x22
  800df2:	68 9a 13 80 00       	push   $0x80139a
  800df7:	e8 24 00 00 00       	call   800e20 <_panic>

00800dfc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800dfc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800dfd:	a1 64 40 80 00       	mov    0x804064,%eax
	call *%eax				
  800e02:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e04:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp			
  800e07:	83 c4 08             	add    $0x8,%esp
	movl 40(%esp), %eax 	
  800e0a:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 32(%esp), %ecx 	
  800e0e:	8b 4c 24 20          	mov    0x20(%esp),%ecx
	movl %ecx, -4(%eax) 	
  800e12:	89 48 fc             	mov    %ecx,-0x4(%eax)
	popal
  800e15:	61                   	popa   
	addl $4, %esp		
  800e16:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popfl
  800e19:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800e1a:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	lea -4(%esp), %esp	
  800e1b:	8d 64 24 fc          	lea    -0x4(%esp),%esp
	ret
  800e1f:	c3                   	ret    

00800e20 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800e20:	f3 0f 1e fb          	endbr32 
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	56                   	push   %esi
  800e28:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800e29:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e2c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800e32:	e8 57 fd ff ff       	call   800b8e <sys_getenvid>
  800e37:	83 ec 0c             	sub    $0xc,%esp
  800e3a:	ff 75 0c             	pushl  0xc(%ebp)
  800e3d:	ff 75 08             	pushl  0x8(%ebp)
  800e40:	56                   	push   %esi
  800e41:	50                   	push   %eax
  800e42:	68 a8 13 80 00       	push   $0x8013a8
  800e47:	e8 3c f3 ff ff       	call   800188 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e4c:	83 c4 18             	add    $0x18,%esp
  800e4f:	53                   	push   %ebx
  800e50:	ff 75 10             	pushl  0x10(%ebp)
  800e53:	e8 db f2 ff ff       	call   800133 <vcprintf>
	cprintf("\n");
  800e58:	c7 04 24 fa 10 80 00 	movl   $0x8010fa,(%esp)
  800e5f:	e8 24 f3 ff ff       	call   800188 <cprintf>
  800e64:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e67:	cc                   	int3   
  800e68:	eb fd                	jmp    800e67 <_panic+0x47>
  800e6a:	66 90                	xchg   %ax,%ax
  800e6c:	66 90                	xchg   %ax,%ax
  800e6e:	66 90                	xchg   %ax,%ax

00800e70 <__udivdi3>:
  800e70:	f3 0f 1e fb          	endbr32 
  800e74:	55                   	push   %ebp
  800e75:	57                   	push   %edi
  800e76:	56                   	push   %esi
  800e77:	53                   	push   %ebx
  800e78:	83 ec 1c             	sub    $0x1c,%esp
  800e7b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e7f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e83:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e87:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e8b:	85 d2                	test   %edx,%edx
  800e8d:	75 19                	jne    800ea8 <__udivdi3+0x38>
  800e8f:	39 f3                	cmp    %esi,%ebx
  800e91:	76 4d                	jbe    800ee0 <__udivdi3+0x70>
  800e93:	31 ff                	xor    %edi,%edi
  800e95:	89 e8                	mov    %ebp,%eax
  800e97:	89 f2                	mov    %esi,%edx
  800e99:	f7 f3                	div    %ebx
  800e9b:	89 fa                	mov    %edi,%edx
  800e9d:	83 c4 1c             	add    $0x1c,%esp
  800ea0:	5b                   	pop    %ebx
  800ea1:	5e                   	pop    %esi
  800ea2:	5f                   	pop    %edi
  800ea3:	5d                   	pop    %ebp
  800ea4:	c3                   	ret    
  800ea5:	8d 76 00             	lea    0x0(%esi),%esi
  800ea8:	39 f2                	cmp    %esi,%edx
  800eaa:	76 14                	jbe    800ec0 <__udivdi3+0x50>
  800eac:	31 ff                	xor    %edi,%edi
  800eae:	31 c0                	xor    %eax,%eax
  800eb0:	89 fa                	mov    %edi,%edx
  800eb2:	83 c4 1c             	add    $0x1c,%esp
  800eb5:	5b                   	pop    %ebx
  800eb6:	5e                   	pop    %esi
  800eb7:	5f                   	pop    %edi
  800eb8:	5d                   	pop    %ebp
  800eb9:	c3                   	ret    
  800eba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ec0:	0f bd fa             	bsr    %edx,%edi
  800ec3:	83 f7 1f             	xor    $0x1f,%edi
  800ec6:	75 48                	jne    800f10 <__udivdi3+0xa0>
  800ec8:	39 f2                	cmp    %esi,%edx
  800eca:	72 06                	jb     800ed2 <__udivdi3+0x62>
  800ecc:	31 c0                	xor    %eax,%eax
  800ece:	39 eb                	cmp    %ebp,%ebx
  800ed0:	77 de                	ja     800eb0 <__udivdi3+0x40>
  800ed2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ed7:	eb d7                	jmp    800eb0 <__udivdi3+0x40>
  800ed9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ee0:	89 d9                	mov    %ebx,%ecx
  800ee2:	85 db                	test   %ebx,%ebx
  800ee4:	75 0b                	jne    800ef1 <__udivdi3+0x81>
  800ee6:	b8 01 00 00 00       	mov    $0x1,%eax
  800eeb:	31 d2                	xor    %edx,%edx
  800eed:	f7 f3                	div    %ebx
  800eef:	89 c1                	mov    %eax,%ecx
  800ef1:	31 d2                	xor    %edx,%edx
  800ef3:	89 f0                	mov    %esi,%eax
  800ef5:	f7 f1                	div    %ecx
  800ef7:	89 c6                	mov    %eax,%esi
  800ef9:	89 e8                	mov    %ebp,%eax
  800efb:	89 f7                	mov    %esi,%edi
  800efd:	f7 f1                	div    %ecx
  800eff:	89 fa                	mov    %edi,%edx
  800f01:	83 c4 1c             	add    $0x1c,%esp
  800f04:	5b                   	pop    %ebx
  800f05:	5e                   	pop    %esi
  800f06:	5f                   	pop    %edi
  800f07:	5d                   	pop    %ebp
  800f08:	c3                   	ret    
  800f09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f10:	89 f9                	mov    %edi,%ecx
  800f12:	b8 20 00 00 00       	mov    $0x20,%eax
  800f17:	29 f8                	sub    %edi,%eax
  800f19:	d3 e2                	shl    %cl,%edx
  800f1b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f1f:	89 c1                	mov    %eax,%ecx
  800f21:	89 da                	mov    %ebx,%edx
  800f23:	d3 ea                	shr    %cl,%edx
  800f25:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f29:	09 d1                	or     %edx,%ecx
  800f2b:	89 f2                	mov    %esi,%edx
  800f2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f31:	89 f9                	mov    %edi,%ecx
  800f33:	d3 e3                	shl    %cl,%ebx
  800f35:	89 c1                	mov    %eax,%ecx
  800f37:	d3 ea                	shr    %cl,%edx
  800f39:	89 f9                	mov    %edi,%ecx
  800f3b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f3f:	89 eb                	mov    %ebp,%ebx
  800f41:	d3 e6                	shl    %cl,%esi
  800f43:	89 c1                	mov    %eax,%ecx
  800f45:	d3 eb                	shr    %cl,%ebx
  800f47:	09 de                	or     %ebx,%esi
  800f49:	89 f0                	mov    %esi,%eax
  800f4b:	f7 74 24 08          	divl   0x8(%esp)
  800f4f:	89 d6                	mov    %edx,%esi
  800f51:	89 c3                	mov    %eax,%ebx
  800f53:	f7 64 24 0c          	mull   0xc(%esp)
  800f57:	39 d6                	cmp    %edx,%esi
  800f59:	72 15                	jb     800f70 <__udivdi3+0x100>
  800f5b:	89 f9                	mov    %edi,%ecx
  800f5d:	d3 e5                	shl    %cl,%ebp
  800f5f:	39 c5                	cmp    %eax,%ebp
  800f61:	73 04                	jae    800f67 <__udivdi3+0xf7>
  800f63:	39 d6                	cmp    %edx,%esi
  800f65:	74 09                	je     800f70 <__udivdi3+0x100>
  800f67:	89 d8                	mov    %ebx,%eax
  800f69:	31 ff                	xor    %edi,%edi
  800f6b:	e9 40 ff ff ff       	jmp    800eb0 <__udivdi3+0x40>
  800f70:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f73:	31 ff                	xor    %edi,%edi
  800f75:	e9 36 ff ff ff       	jmp    800eb0 <__udivdi3+0x40>
  800f7a:	66 90                	xchg   %ax,%ax
  800f7c:	66 90                	xchg   %ax,%ax
  800f7e:	66 90                	xchg   %ax,%ax

00800f80 <__umoddi3>:
  800f80:	f3 0f 1e fb          	endbr32 
  800f84:	55                   	push   %ebp
  800f85:	57                   	push   %edi
  800f86:	56                   	push   %esi
  800f87:	53                   	push   %ebx
  800f88:	83 ec 1c             	sub    $0x1c,%esp
  800f8b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800f8f:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f93:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f97:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	75 19                	jne    800fb8 <__umoddi3+0x38>
  800f9f:	39 df                	cmp    %ebx,%edi
  800fa1:	76 5d                	jbe    801000 <__umoddi3+0x80>
  800fa3:	89 f0                	mov    %esi,%eax
  800fa5:	89 da                	mov    %ebx,%edx
  800fa7:	f7 f7                	div    %edi
  800fa9:	89 d0                	mov    %edx,%eax
  800fab:	31 d2                	xor    %edx,%edx
  800fad:	83 c4 1c             	add    $0x1c,%esp
  800fb0:	5b                   	pop    %ebx
  800fb1:	5e                   	pop    %esi
  800fb2:	5f                   	pop    %edi
  800fb3:	5d                   	pop    %ebp
  800fb4:	c3                   	ret    
  800fb5:	8d 76 00             	lea    0x0(%esi),%esi
  800fb8:	89 f2                	mov    %esi,%edx
  800fba:	39 d8                	cmp    %ebx,%eax
  800fbc:	76 12                	jbe    800fd0 <__umoddi3+0x50>
  800fbe:	89 f0                	mov    %esi,%eax
  800fc0:	89 da                	mov    %ebx,%edx
  800fc2:	83 c4 1c             	add    $0x1c,%esp
  800fc5:	5b                   	pop    %ebx
  800fc6:	5e                   	pop    %esi
  800fc7:	5f                   	pop    %edi
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    
  800fca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fd0:	0f bd e8             	bsr    %eax,%ebp
  800fd3:	83 f5 1f             	xor    $0x1f,%ebp
  800fd6:	75 50                	jne    801028 <__umoddi3+0xa8>
  800fd8:	39 d8                	cmp    %ebx,%eax
  800fda:	0f 82 e0 00 00 00    	jb     8010c0 <__umoddi3+0x140>
  800fe0:	89 d9                	mov    %ebx,%ecx
  800fe2:	39 f7                	cmp    %esi,%edi
  800fe4:	0f 86 d6 00 00 00    	jbe    8010c0 <__umoddi3+0x140>
  800fea:	89 d0                	mov    %edx,%eax
  800fec:	89 ca                	mov    %ecx,%edx
  800fee:	83 c4 1c             	add    $0x1c,%esp
  800ff1:	5b                   	pop    %ebx
  800ff2:	5e                   	pop    %esi
  800ff3:	5f                   	pop    %edi
  800ff4:	5d                   	pop    %ebp
  800ff5:	c3                   	ret    
  800ff6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ffd:	8d 76 00             	lea    0x0(%esi),%esi
  801000:	89 fd                	mov    %edi,%ebp
  801002:	85 ff                	test   %edi,%edi
  801004:	75 0b                	jne    801011 <__umoddi3+0x91>
  801006:	b8 01 00 00 00       	mov    $0x1,%eax
  80100b:	31 d2                	xor    %edx,%edx
  80100d:	f7 f7                	div    %edi
  80100f:	89 c5                	mov    %eax,%ebp
  801011:	89 d8                	mov    %ebx,%eax
  801013:	31 d2                	xor    %edx,%edx
  801015:	f7 f5                	div    %ebp
  801017:	89 f0                	mov    %esi,%eax
  801019:	f7 f5                	div    %ebp
  80101b:	89 d0                	mov    %edx,%eax
  80101d:	31 d2                	xor    %edx,%edx
  80101f:	eb 8c                	jmp    800fad <__umoddi3+0x2d>
  801021:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801028:	89 e9                	mov    %ebp,%ecx
  80102a:	ba 20 00 00 00       	mov    $0x20,%edx
  80102f:	29 ea                	sub    %ebp,%edx
  801031:	d3 e0                	shl    %cl,%eax
  801033:	89 44 24 08          	mov    %eax,0x8(%esp)
  801037:	89 d1                	mov    %edx,%ecx
  801039:	89 f8                	mov    %edi,%eax
  80103b:	d3 e8                	shr    %cl,%eax
  80103d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801041:	89 54 24 04          	mov    %edx,0x4(%esp)
  801045:	8b 54 24 04          	mov    0x4(%esp),%edx
  801049:	09 c1                	or     %eax,%ecx
  80104b:	89 d8                	mov    %ebx,%eax
  80104d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801051:	89 e9                	mov    %ebp,%ecx
  801053:	d3 e7                	shl    %cl,%edi
  801055:	89 d1                	mov    %edx,%ecx
  801057:	d3 e8                	shr    %cl,%eax
  801059:	89 e9                	mov    %ebp,%ecx
  80105b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80105f:	d3 e3                	shl    %cl,%ebx
  801061:	89 c7                	mov    %eax,%edi
  801063:	89 d1                	mov    %edx,%ecx
  801065:	89 f0                	mov    %esi,%eax
  801067:	d3 e8                	shr    %cl,%eax
  801069:	89 e9                	mov    %ebp,%ecx
  80106b:	89 fa                	mov    %edi,%edx
  80106d:	d3 e6                	shl    %cl,%esi
  80106f:	09 d8                	or     %ebx,%eax
  801071:	f7 74 24 08          	divl   0x8(%esp)
  801075:	89 d1                	mov    %edx,%ecx
  801077:	89 f3                	mov    %esi,%ebx
  801079:	f7 64 24 0c          	mull   0xc(%esp)
  80107d:	89 c6                	mov    %eax,%esi
  80107f:	89 d7                	mov    %edx,%edi
  801081:	39 d1                	cmp    %edx,%ecx
  801083:	72 06                	jb     80108b <__umoddi3+0x10b>
  801085:	75 10                	jne    801097 <__umoddi3+0x117>
  801087:	39 c3                	cmp    %eax,%ebx
  801089:	73 0c                	jae    801097 <__umoddi3+0x117>
  80108b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80108f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801093:	89 d7                	mov    %edx,%edi
  801095:	89 c6                	mov    %eax,%esi
  801097:	89 ca                	mov    %ecx,%edx
  801099:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80109e:	29 f3                	sub    %esi,%ebx
  8010a0:	19 fa                	sbb    %edi,%edx
  8010a2:	89 d0                	mov    %edx,%eax
  8010a4:	d3 e0                	shl    %cl,%eax
  8010a6:	89 e9                	mov    %ebp,%ecx
  8010a8:	d3 eb                	shr    %cl,%ebx
  8010aa:	d3 ea                	shr    %cl,%edx
  8010ac:	09 d8                	or     %ebx,%eax
  8010ae:	83 c4 1c             	add    $0x1c,%esp
  8010b1:	5b                   	pop    %ebx
  8010b2:	5e                   	pop    %esi
  8010b3:	5f                   	pop    %edi
  8010b4:	5d                   	pop    %ebp
  8010b5:	c3                   	ret    
  8010b6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010bd:	8d 76 00             	lea    0x0(%esi),%esi
  8010c0:	29 fe                	sub    %edi,%esi
  8010c2:	19 c3                	sbb    %eax,%ebx
  8010c4:	89 f2                	mov    %esi,%edx
  8010c6:	89 d9                	mov    %ebx,%ecx
  8010c8:	e9 1d ff ff ff       	jmp    800fea <__umoddi3+0x6a>
