
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 33 00 00 00       	call   800064 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  80003d:	c7 05 50 20 80 00 00 	movl   $0x0,0x802050
  800044:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800047:	b8 01 00 00 00       	mov    $0x1,%eax
  80004c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800051:	99                   	cltd   
  800052:	f7 f9                	idiv   %ecx
  800054:	50                   	push   %eax
  800055:	68 40 10 80 00       	push   $0x801040
  80005a:	e8 05 01 00 00       	call   800164 <cprintf>
}
  80005f:	83 c4 10             	add    $0x10,%esp
  800062:	c9                   	leave  
  800063:	c3                   	ret    

00800064 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800064:	f3 0f 1e fb          	endbr32 
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	56                   	push   %esi
  80006c:	53                   	push   %ebx
  80006d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800070:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800073:	e8 f2 0a 00 00       	call   800b6a <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800078:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007d:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  800083:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800088:	a3 60 40 80 00       	mov    %eax,0x804060

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008d:	85 db                	test   %ebx,%ebx
  80008f:	7e 07                	jle    800098 <libmain+0x34>
		binaryname = argv[0];
  800091:	8b 06                	mov    (%esi),%eax
  800093:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800098:	83 ec 08             	sub    $0x8,%esp
  80009b:	56                   	push   %esi
  80009c:	53                   	push   %ebx
  80009d:	e8 91 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a2:	e8 0a 00 00 00       	call   8000b1 <exit>
}
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ad:	5b                   	pop    %ebx
  8000ae:	5e                   	pop    %esi
  8000af:	5d                   	pop    %ebp
  8000b0:	c3                   	ret    

008000b1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b1:	f3 0f 1e fb          	endbr32 
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000bb:	6a 00                	push   $0x0
  8000bd:	e8 63 0a 00 00       	call   800b25 <sys_env_destroy>
}
  8000c2:	83 c4 10             	add    $0x10,%esp
  8000c5:	c9                   	leave  
  8000c6:	c3                   	ret    

008000c7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c7:	f3 0f 1e fb          	endbr32 
  8000cb:	55                   	push   %ebp
  8000cc:	89 e5                	mov    %esp,%ebp
  8000ce:	53                   	push   %ebx
  8000cf:	83 ec 04             	sub    $0x4,%esp
  8000d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d5:	8b 13                	mov    (%ebx),%edx
  8000d7:	8d 42 01             	lea    0x1(%edx),%eax
  8000da:	89 03                	mov    %eax,(%ebx)
  8000dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000df:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000e3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e8:	74 09                	je     8000f3 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000ea:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f1:	c9                   	leave  
  8000f2:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000f3:	83 ec 08             	sub    $0x8,%esp
  8000f6:	68 ff 00 00 00       	push   $0xff
  8000fb:	8d 43 08             	lea    0x8(%ebx),%eax
  8000fe:	50                   	push   %eax
  8000ff:	e8 dc 09 00 00       	call   800ae0 <sys_cputs>
		b->idx = 0;
  800104:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80010a:	83 c4 10             	add    $0x10,%esp
  80010d:	eb db                	jmp    8000ea <putch+0x23>

0080010f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010f:	f3 0f 1e fb          	endbr32 
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80011c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800123:	00 00 00 
	b.cnt = 0;
  800126:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80012d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800130:	ff 75 0c             	pushl  0xc(%ebp)
  800133:	ff 75 08             	pushl  0x8(%ebp)
  800136:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80013c:	50                   	push   %eax
  80013d:	68 c7 00 80 00       	push   $0x8000c7
  800142:	e8 20 01 00 00       	call   800267 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800147:	83 c4 08             	add    $0x8,%esp
  80014a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800150:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800156:	50                   	push   %eax
  800157:	e8 84 09 00 00       	call   800ae0 <sys_cputs>

	return b.cnt;
}
  80015c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800162:	c9                   	leave  
  800163:	c3                   	ret    

00800164 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800164:	f3 0f 1e fb          	endbr32 
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800171:	50                   	push   %eax
  800172:	ff 75 08             	pushl  0x8(%ebp)
  800175:	e8 95 ff ff ff       	call   80010f <vcprintf>
	va_end(ap);

	return cnt;
}
  80017a:	c9                   	leave  
  80017b:	c3                   	ret    

0080017c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	57                   	push   %edi
  800180:	56                   	push   %esi
  800181:	53                   	push   %ebx
  800182:	83 ec 1c             	sub    $0x1c,%esp
  800185:	89 c7                	mov    %eax,%edi
  800187:	89 d6                	mov    %edx,%esi
  800189:	8b 45 08             	mov    0x8(%ebp),%eax
  80018c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018f:	89 d1                	mov    %edx,%ecx
  800191:	89 c2                	mov    %eax,%edx
  800193:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800196:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800199:	8b 45 10             	mov    0x10(%ebp),%eax
  80019c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80019f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001a2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001a9:	39 c2                	cmp    %eax,%edx
  8001ab:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001ae:	72 3e                	jb     8001ee <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b0:	83 ec 0c             	sub    $0xc,%esp
  8001b3:	ff 75 18             	pushl  0x18(%ebp)
  8001b6:	83 eb 01             	sub    $0x1,%ebx
  8001b9:	53                   	push   %ebx
  8001ba:	50                   	push   %eax
  8001bb:	83 ec 08             	sub    $0x8,%esp
  8001be:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8001c4:	ff 75 dc             	pushl  -0x24(%ebp)
  8001c7:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ca:	e8 01 0c 00 00       	call   800dd0 <__udivdi3>
  8001cf:	83 c4 18             	add    $0x18,%esp
  8001d2:	52                   	push   %edx
  8001d3:	50                   	push   %eax
  8001d4:	89 f2                	mov    %esi,%edx
  8001d6:	89 f8                	mov    %edi,%eax
  8001d8:	e8 9f ff ff ff       	call   80017c <printnum>
  8001dd:	83 c4 20             	add    $0x20,%esp
  8001e0:	eb 13                	jmp    8001f5 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001e2:	83 ec 08             	sub    $0x8,%esp
  8001e5:	56                   	push   %esi
  8001e6:	ff 75 18             	pushl  0x18(%ebp)
  8001e9:	ff d7                	call   *%edi
  8001eb:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001ee:	83 eb 01             	sub    $0x1,%ebx
  8001f1:	85 db                	test   %ebx,%ebx
  8001f3:	7f ed                	jg     8001e2 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001f5:	83 ec 08             	sub    $0x8,%esp
  8001f8:	56                   	push   %esi
  8001f9:	83 ec 04             	sub    $0x4,%esp
  8001fc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ff:	ff 75 e0             	pushl  -0x20(%ebp)
  800202:	ff 75 dc             	pushl  -0x24(%ebp)
  800205:	ff 75 d8             	pushl  -0x28(%ebp)
  800208:	e8 d3 0c 00 00       	call   800ee0 <__umoddi3>
  80020d:	83 c4 14             	add    $0x14,%esp
  800210:	0f be 80 58 10 80 00 	movsbl 0x801058(%eax),%eax
  800217:	50                   	push   %eax
  800218:	ff d7                	call   *%edi
}
  80021a:	83 c4 10             	add    $0x10,%esp
  80021d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800220:	5b                   	pop    %ebx
  800221:	5e                   	pop    %esi
  800222:	5f                   	pop    %edi
  800223:	5d                   	pop    %ebp
  800224:	c3                   	ret    

00800225 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800225:	f3 0f 1e fb          	endbr32 
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80022f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800233:	8b 10                	mov    (%eax),%edx
  800235:	3b 50 04             	cmp    0x4(%eax),%edx
  800238:	73 0a                	jae    800244 <sprintputch+0x1f>
		*b->buf++ = ch;
  80023a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80023d:	89 08                	mov    %ecx,(%eax)
  80023f:	8b 45 08             	mov    0x8(%ebp),%eax
  800242:	88 02                	mov    %al,(%edx)
}
  800244:	5d                   	pop    %ebp
  800245:	c3                   	ret    

00800246 <printfmt>:
{
  800246:	f3 0f 1e fb          	endbr32 
  80024a:	55                   	push   %ebp
  80024b:	89 e5                	mov    %esp,%ebp
  80024d:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800250:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800253:	50                   	push   %eax
  800254:	ff 75 10             	pushl  0x10(%ebp)
  800257:	ff 75 0c             	pushl  0xc(%ebp)
  80025a:	ff 75 08             	pushl  0x8(%ebp)
  80025d:	e8 05 00 00 00       	call   800267 <vprintfmt>
}
  800262:	83 c4 10             	add    $0x10,%esp
  800265:	c9                   	leave  
  800266:	c3                   	ret    

00800267 <vprintfmt>:
{
  800267:	f3 0f 1e fb          	endbr32 
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	57                   	push   %edi
  80026f:	56                   	push   %esi
  800270:	53                   	push   %ebx
  800271:	83 ec 3c             	sub    $0x3c,%esp
  800274:	8b 75 08             	mov    0x8(%ebp),%esi
  800277:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80027a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80027d:	e9 8e 03 00 00       	jmp    800610 <vprintfmt+0x3a9>
		padc = ' ';
  800282:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800286:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80028d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800294:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80029b:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002a0:	8d 47 01             	lea    0x1(%edi),%eax
  8002a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002a6:	0f b6 17             	movzbl (%edi),%edx
  8002a9:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002ac:	3c 55                	cmp    $0x55,%al
  8002ae:	0f 87 df 03 00 00    	ja     800693 <vprintfmt+0x42c>
  8002b4:	0f b6 c0             	movzbl %al,%eax
  8002b7:	3e ff 24 85 20 11 80 	notrack jmp *0x801120(,%eax,4)
  8002be:	00 
  8002bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002c2:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002c6:	eb d8                	jmp    8002a0 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8002c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002cb:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002cf:	eb cf                	jmp    8002a0 <vprintfmt+0x39>
  8002d1:	0f b6 d2             	movzbl %dl,%edx
  8002d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8002dc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002df:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002e2:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002e6:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002e9:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002ec:	83 f9 09             	cmp    $0x9,%ecx
  8002ef:	77 55                	ja     800346 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8002f1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002f4:	eb e9                	jmp    8002df <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8002f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f9:	8b 00                	mov    (%eax),%eax
  8002fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800301:	8d 40 04             	lea    0x4(%eax),%eax
  800304:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800307:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80030a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80030e:	79 90                	jns    8002a0 <vprintfmt+0x39>
				width = precision, precision = -1;
  800310:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800313:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800316:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80031d:	eb 81                	jmp    8002a0 <vprintfmt+0x39>
  80031f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800322:	85 c0                	test   %eax,%eax
  800324:	ba 00 00 00 00       	mov    $0x0,%edx
  800329:	0f 49 d0             	cmovns %eax,%edx
  80032c:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80032f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800332:	e9 69 ff ff ff       	jmp    8002a0 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800337:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80033a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800341:	e9 5a ff ff ff       	jmp    8002a0 <vprintfmt+0x39>
  800346:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800349:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80034c:	eb bc                	jmp    80030a <vprintfmt+0xa3>
			lflag++;
  80034e:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800351:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800354:	e9 47 ff ff ff       	jmp    8002a0 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800359:	8b 45 14             	mov    0x14(%ebp),%eax
  80035c:	8d 78 04             	lea    0x4(%eax),%edi
  80035f:	83 ec 08             	sub    $0x8,%esp
  800362:	53                   	push   %ebx
  800363:	ff 30                	pushl  (%eax)
  800365:	ff d6                	call   *%esi
			break;
  800367:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80036a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80036d:	e9 9b 02 00 00       	jmp    80060d <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800372:	8b 45 14             	mov    0x14(%ebp),%eax
  800375:	8d 78 04             	lea    0x4(%eax),%edi
  800378:	8b 00                	mov    (%eax),%eax
  80037a:	99                   	cltd   
  80037b:	31 d0                	xor    %edx,%eax
  80037d:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80037f:	83 f8 08             	cmp    $0x8,%eax
  800382:	7f 23                	jg     8003a7 <vprintfmt+0x140>
  800384:	8b 14 85 80 12 80 00 	mov    0x801280(,%eax,4),%edx
  80038b:	85 d2                	test   %edx,%edx
  80038d:	74 18                	je     8003a7 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80038f:	52                   	push   %edx
  800390:	68 79 10 80 00       	push   $0x801079
  800395:	53                   	push   %ebx
  800396:	56                   	push   %esi
  800397:	e8 aa fe ff ff       	call   800246 <printfmt>
  80039c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80039f:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003a2:	e9 66 02 00 00       	jmp    80060d <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  8003a7:	50                   	push   %eax
  8003a8:	68 70 10 80 00       	push   $0x801070
  8003ad:	53                   	push   %ebx
  8003ae:	56                   	push   %esi
  8003af:	e8 92 fe ff ff       	call   800246 <printfmt>
  8003b4:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003b7:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003ba:	e9 4e 02 00 00       	jmp    80060d <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  8003bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c2:	83 c0 04             	add    $0x4,%eax
  8003c5:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cb:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003cd:	85 d2                	test   %edx,%edx
  8003cf:	b8 69 10 80 00       	mov    $0x801069,%eax
  8003d4:	0f 45 c2             	cmovne %edx,%eax
  8003d7:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003da:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003de:	7e 06                	jle    8003e6 <vprintfmt+0x17f>
  8003e0:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003e4:	75 0d                	jne    8003f3 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003e6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003e9:	89 c7                	mov    %eax,%edi
  8003eb:	03 45 e0             	add    -0x20(%ebp),%eax
  8003ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f1:	eb 55                	jmp    800448 <vprintfmt+0x1e1>
  8003f3:	83 ec 08             	sub    $0x8,%esp
  8003f6:	ff 75 d8             	pushl  -0x28(%ebp)
  8003f9:	ff 75 cc             	pushl  -0x34(%ebp)
  8003fc:	e8 46 03 00 00       	call   800747 <strnlen>
  800401:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800404:	29 c2                	sub    %eax,%edx
  800406:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800409:	83 c4 10             	add    $0x10,%esp
  80040c:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80040e:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800412:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800415:	85 ff                	test   %edi,%edi
  800417:	7e 11                	jle    80042a <vprintfmt+0x1c3>
					putch(padc, putdat);
  800419:	83 ec 08             	sub    $0x8,%esp
  80041c:	53                   	push   %ebx
  80041d:	ff 75 e0             	pushl  -0x20(%ebp)
  800420:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800422:	83 ef 01             	sub    $0x1,%edi
  800425:	83 c4 10             	add    $0x10,%esp
  800428:	eb eb                	jmp    800415 <vprintfmt+0x1ae>
  80042a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80042d:	85 d2                	test   %edx,%edx
  80042f:	b8 00 00 00 00       	mov    $0x0,%eax
  800434:	0f 49 c2             	cmovns %edx,%eax
  800437:	29 c2                	sub    %eax,%edx
  800439:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80043c:	eb a8                	jmp    8003e6 <vprintfmt+0x17f>
					putch(ch, putdat);
  80043e:	83 ec 08             	sub    $0x8,%esp
  800441:	53                   	push   %ebx
  800442:	52                   	push   %edx
  800443:	ff d6                	call   *%esi
  800445:	83 c4 10             	add    $0x10,%esp
  800448:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80044b:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80044d:	83 c7 01             	add    $0x1,%edi
  800450:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800454:	0f be d0             	movsbl %al,%edx
  800457:	85 d2                	test   %edx,%edx
  800459:	74 4b                	je     8004a6 <vprintfmt+0x23f>
  80045b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80045f:	78 06                	js     800467 <vprintfmt+0x200>
  800461:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800465:	78 1e                	js     800485 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800467:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80046b:	74 d1                	je     80043e <vprintfmt+0x1d7>
  80046d:	0f be c0             	movsbl %al,%eax
  800470:	83 e8 20             	sub    $0x20,%eax
  800473:	83 f8 5e             	cmp    $0x5e,%eax
  800476:	76 c6                	jbe    80043e <vprintfmt+0x1d7>
					putch('?', putdat);
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	53                   	push   %ebx
  80047c:	6a 3f                	push   $0x3f
  80047e:	ff d6                	call   *%esi
  800480:	83 c4 10             	add    $0x10,%esp
  800483:	eb c3                	jmp    800448 <vprintfmt+0x1e1>
  800485:	89 cf                	mov    %ecx,%edi
  800487:	eb 0e                	jmp    800497 <vprintfmt+0x230>
				putch(' ', putdat);
  800489:	83 ec 08             	sub    $0x8,%esp
  80048c:	53                   	push   %ebx
  80048d:	6a 20                	push   $0x20
  80048f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800491:	83 ef 01             	sub    $0x1,%edi
  800494:	83 c4 10             	add    $0x10,%esp
  800497:	85 ff                	test   %edi,%edi
  800499:	7f ee                	jg     800489 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80049b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80049e:	89 45 14             	mov    %eax,0x14(%ebp)
  8004a1:	e9 67 01 00 00       	jmp    80060d <vprintfmt+0x3a6>
  8004a6:	89 cf                	mov    %ecx,%edi
  8004a8:	eb ed                	jmp    800497 <vprintfmt+0x230>
	if (lflag >= 2)
  8004aa:	83 f9 01             	cmp    $0x1,%ecx
  8004ad:	7f 1b                	jg     8004ca <vprintfmt+0x263>
	else if (lflag)
  8004af:	85 c9                	test   %ecx,%ecx
  8004b1:	74 63                	je     800516 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8004b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b6:	8b 00                	mov    (%eax),%eax
  8004b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004bb:	99                   	cltd   
  8004bc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c2:	8d 40 04             	lea    0x4(%eax),%eax
  8004c5:	89 45 14             	mov    %eax,0x14(%ebp)
  8004c8:	eb 17                	jmp    8004e1 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8004ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cd:	8b 50 04             	mov    0x4(%eax),%edx
  8004d0:	8b 00                	mov    (%eax),%eax
  8004d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004d5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004db:	8d 40 08             	lea    0x8(%eax),%eax
  8004de:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004e1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004e4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8004e7:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8004ec:	85 c9                	test   %ecx,%ecx
  8004ee:	0f 89 ff 00 00 00    	jns    8005f3 <vprintfmt+0x38c>
				putch('-', putdat);
  8004f4:	83 ec 08             	sub    $0x8,%esp
  8004f7:	53                   	push   %ebx
  8004f8:	6a 2d                	push   $0x2d
  8004fa:	ff d6                	call   *%esi
				num = -(long long) num;
  8004fc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004ff:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800502:	f7 da                	neg    %edx
  800504:	83 d1 00             	adc    $0x0,%ecx
  800507:	f7 d9                	neg    %ecx
  800509:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80050c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800511:	e9 dd 00 00 00       	jmp    8005f3 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  800516:	8b 45 14             	mov    0x14(%ebp),%eax
  800519:	8b 00                	mov    (%eax),%eax
  80051b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051e:	99                   	cltd   
  80051f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8d 40 04             	lea    0x4(%eax),%eax
  800528:	89 45 14             	mov    %eax,0x14(%ebp)
  80052b:	eb b4                	jmp    8004e1 <vprintfmt+0x27a>
	if (lflag >= 2)
  80052d:	83 f9 01             	cmp    $0x1,%ecx
  800530:	7f 1e                	jg     800550 <vprintfmt+0x2e9>
	else if (lflag)
  800532:	85 c9                	test   %ecx,%ecx
  800534:	74 32                	je     800568 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800536:	8b 45 14             	mov    0x14(%ebp),%eax
  800539:	8b 10                	mov    (%eax),%edx
  80053b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800540:	8d 40 04             	lea    0x4(%eax),%eax
  800543:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800546:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80054b:	e9 a3 00 00 00       	jmp    8005f3 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800550:	8b 45 14             	mov    0x14(%ebp),%eax
  800553:	8b 10                	mov    (%eax),%edx
  800555:	8b 48 04             	mov    0x4(%eax),%ecx
  800558:	8d 40 08             	lea    0x8(%eax),%eax
  80055b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80055e:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800563:	e9 8b 00 00 00       	jmp    8005f3 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8b 10                	mov    (%eax),%edx
  80056d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800572:	8d 40 04             	lea    0x4(%eax),%eax
  800575:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800578:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80057d:	eb 74                	jmp    8005f3 <vprintfmt+0x38c>
	if (lflag >= 2)
  80057f:	83 f9 01             	cmp    $0x1,%ecx
  800582:	7f 1b                	jg     80059f <vprintfmt+0x338>
	else if (lflag)
  800584:	85 c9                	test   %ecx,%ecx
  800586:	74 2c                	je     8005b4 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800588:	8b 45 14             	mov    0x14(%ebp),%eax
  80058b:	8b 10                	mov    (%eax),%edx
  80058d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800592:	8d 40 04             	lea    0x4(%eax),%eax
  800595:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800598:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  80059d:	eb 54                	jmp    8005f3 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80059f:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a2:	8b 10                	mov    (%eax),%edx
  8005a4:	8b 48 04             	mov    0x4(%eax),%ecx
  8005a7:	8d 40 08             	lea    0x8(%eax),%eax
  8005aa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005ad:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  8005b2:	eb 3f                	jmp    8005f3 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8b 10                	mov    (%eax),%edx
  8005b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005be:	8d 40 04             	lea    0x4(%eax),%eax
  8005c1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005c4:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  8005c9:	eb 28                	jmp    8005f3 <vprintfmt+0x38c>
			putch('0', putdat);
  8005cb:	83 ec 08             	sub    $0x8,%esp
  8005ce:	53                   	push   %ebx
  8005cf:	6a 30                	push   $0x30
  8005d1:	ff d6                	call   *%esi
			putch('x', putdat);
  8005d3:	83 c4 08             	add    $0x8,%esp
  8005d6:	53                   	push   %ebx
  8005d7:	6a 78                	push   $0x78
  8005d9:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8b 10                	mov    (%eax),%edx
  8005e0:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005e5:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8005e8:	8d 40 04             	lea    0x4(%eax),%eax
  8005eb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005ee:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005f3:	83 ec 0c             	sub    $0xc,%esp
  8005f6:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005fa:	57                   	push   %edi
  8005fb:	ff 75 e0             	pushl  -0x20(%ebp)
  8005fe:	50                   	push   %eax
  8005ff:	51                   	push   %ecx
  800600:	52                   	push   %edx
  800601:	89 da                	mov    %ebx,%edx
  800603:	89 f0                	mov    %esi,%eax
  800605:	e8 72 fb ff ff       	call   80017c <printnum>
			break;
  80060a:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80060d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {	
  800610:	83 c7 01             	add    $0x1,%edi
  800613:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800617:	83 f8 25             	cmp    $0x25,%eax
  80061a:	0f 84 62 fc ff ff    	je     800282 <vprintfmt+0x1b>
			if (ch == '\0')										
  800620:	85 c0                	test   %eax,%eax
  800622:	0f 84 8b 00 00 00    	je     8006b3 <vprintfmt+0x44c>
			putch(ch, putdat);
  800628:	83 ec 08             	sub    $0x8,%esp
  80062b:	53                   	push   %ebx
  80062c:	50                   	push   %eax
  80062d:	ff d6                	call   *%esi
  80062f:	83 c4 10             	add    $0x10,%esp
  800632:	eb dc                	jmp    800610 <vprintfmt+0x3a9>
	if (lflag >= 2)
  800634:	83 f9 01             	cmp    $0x1,%ecx
  800637:	7f 1b                	jg     800654 <vprintfmt+0x3ed>
	else if (lflag)
  800639:	85 c9                	test   %ecx,%ecx
  80063b:	74 2c                	je     800669 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8b 10                	mov    (%eax),%edx
  800642:	b9 00 00 00 00       	mov    $0x0,%ecx
  800647:	8d 40 04             	lea    0x4(%eax),%eax
  80064a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80064d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800652:	eb 9f                	jmp    8005f3 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800654:	8b 45 14             	mov    0x14(%ebp),%eax
  800657:	8b 10                	mov    (%eax),%edx
  800659:	8b 48 04             	mov    0x4(%eax),%ecx
  80065c:	8d 40 08             	lea    0x8(%eax),%eax
  80065f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800662:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800667:	eb 8a                	jmp    8005f3 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8b 10                	mov    (%eax),%edx
  80066e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800673:	8d 40 04             	lea    0x4(%eax),%eax
  800676:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800679:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80067e:	e9 70 ff ff ff       	jmp    8005f3 <vprintfmt+0x38c>
			putch(ch, putdat);
  800683:	83 ec 08             	sub    $0x8,%esp
  800686:	53                   	push   %ebx
  800687:	6a 25                	push   $0x25
  800689:	ff d6                	call   *%esi
			break;
  80068b:	83 c4 10             	add    $0x10,%esp
  80068e:	e9 7a ff ff ff       	jmp    80060d <vprintfmt+0x3a6>
			putch('%', putdat);
  800693:	83 ec 08             	sub    $0x8,%esp
  800696:	53                   	push   %ebx
  800697:	6a 25                	push   $0x25
  800699:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80069b:	83 c4 10             	add    $0x10,%esp
  80069e:	89 f8                	mov    %edi,%eax
  8006a0:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006a4:	74 05                	je     8006ab <vprintfmt+0x444>
  8006a6:	83 e8 01             	sub    $0x1,%eax
  8006a9:	eb f5                	jmp    8006a0 <vprintfmt+0x439>
  8006ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006ae:	e9 5a ff ff ff       	jmp    80060d <vprintfmt+0x3a6>
}
  8006b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b6:	5b                   	pop    %ebx
  8006b7:	5e                   	pop    %esi
  8006b8:	5f                   	pop    %edi
  8006b9:	5d                   	pop    %ebp
  8006ba:	c3                   	ret    

008006bb <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006bb:	f3 0f 1e fb          	endbr32 
  8006bf:	55                   	push   %ebp
  8006c0:	89 e5                	mov    %esp,%ebp
  8006c2:	83 ec 18             	sub    $0x18,%esp
  8006c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ce:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006dc:	85 c0                	test   %eax,%eax
  8006de:	74 26                	je     800706 <vsnprintf+0x4b>
  8006e0:	85 d2                	test   %edx,%edx
  8006e2:	7e 22                	jle    800706 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e4:	ff 75 14             	pushl  0x14(%ebp)
  8006e7:	ff 75 10             	pushl  0x10(%ebp)
  8006ea:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006ed:	50                   	push   %eax
  8006ee:	68 25 02 80 00       	push   $0x800225
  8006f3:	e8 6f fb ff ff       	call   800267 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006fb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800701:	83 c4 10             	add    $0x10,%esp
}
  800704:	c9                   	leave  
  800705:	c3                   	ret    
		return -E_INVAL;
  800706:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80070b:	eb f7                	jmp    800704 <vsnprintf+0x49>

0080070d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80070d:	f3 0f 1e fb          	endbr32 
  800711:	55                   	push   %ebp
  800712:	89 e5                	mov    %esp,%ebp
  800714:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800717:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80071a:	50                   	push   %eax
  80071b:	ff 75 10             	pushl  0x10(%ebp)
  80071e:	ff 75 0c             	pushl  0xc(%ebp)
  800721:	ff 75 08             	pushl  0x8(%ebp)
  800724:	e8 92 ff ff ff       	call   8006bb <vsnprintf>
	va_end(ap);

	return rc;
}
  800729:	c9                   	leave  
  80072a:	c3                   	ret    

0080072b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80072b:	f3 0f 1e fb          	endbr32 
  80072f:	55                   	push   %ebp
  800730:	89 e5                	mov    %esp,%ebp
  800732:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800735:	b8 00 00 00 00       	mov    $0x0,%eax
  80073a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80073e:	74 05                	je     800745 <strlen+0x1a>
		n++;
  800740:	83 c0 01             	add    $0x1,%eax
  800743:	eb f5                	jmp    80073a <strlen+0xf>
	return n;
}
  800745:	5d                   	pop    %ebp
  800746:	c3                   	ret    

00800747 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800747:	f3 0f 1e fb          	endbr32 
  80074b:	55                   	push   %ebp
  80074c:	89 e5                	mov    %esp,%ebp
  80074e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800751:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800754:	b8 00 00 00 00       	mov    $0x0,%eax
  800759:	39 d0                	cmp    %edx,%eax
  80075b:	74 0d                	je     80076a <strnlen+0x23>
  80075d:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800761:	74 05                	je     800768 <strnlen+0x21>
		n++;
  800763:	83 c0 01             	add    $0x1,%eax
  800766:	eb f1                	jmp    800759 <strnlen+0x12>
  800768:	89 c2                	mov    %eax,%edx
	return n;
}
  80076a:	89 d0                	mov    %edx,%eax
  80076c:	5d                   	pop    %ebp
  80076d:	c3                   	ret    

0080076e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80076e:	f3 0f 1e fb          	endbr32 
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	53                   	push   %ebx
  800776:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800779:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80077c:	b8 00 00 00 00       	mov    $0x0,%eax
  800781:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800785:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800788:	83 c0 01             	add    $0x1,%eax
  80078b:	84 d2                	test   %dl,%dl
  80078d:	75 f2                	jne    800781 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80078f:	89 c8                	mov    %ecx,%eax
  800791:	5b                   	pop    %ebx
  800792:	5d                   	pop    %ebp
  800793:	c3                   	ret    

00800794 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800794:	f3 0f 1e fb          	endbr32 
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	53                   	push   %ebx
  80079c:	83 ec 10             	sub    $0x10,%esp
  80079f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a2:	53                   	push   %ebx
  8007a3:	e8 83 ff ff ff       	call   80072b <strlen>
  8007a8:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007ab:	ff 75 0c             	pushl  0xc(%ebp)
  8007ae:	01 d8                	add    %ebx,%eax
  8007b0:	50                   	push   %eax
  8007b1:	e8 b8 ff ff ff       	call   80076e <strcpy>
	return dst;
}
  8007b6:	89 d8                	mov    %ebx,%eax
  8007b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007bb:	c9                   	leave  
  8007bc:	c3                   	ret    

008007bd <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007bd:	f3 0f 1e fb          	endbr32 
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	56                   	push   %esi
  8007c5:	53                   	push   %ebx
  8007c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007cc:	89 f3                	mov    %esi,%ebx
  8007ce:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d1:	89 f0                	mov    %esi,%eax
  8007d3:	39 d8                	cmp    %ebx,%eax
  8007d5:	74 11                	je     8007e8 <strncpy+0x2b>
		*dst++ = *src;
  8007d7:	83 c0 01             	add    $0x1,%eax
  8007da:	0f b6 0a             	movzbl (%edx),%ecx
  8007dd:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007e0:	80 f9 01             	cmp    $0x1,%cl
  8007e3:	83 da ff             	sbb    $0xffffffff,%edx
  8007e6:	eb eb                	jmp    8007d3 <strncpy+0x16>
	}
	return ret;
}
  8007e8:	89 f0                	mov    %esi,%eax
  8007ea:	5b                   	pop    %ebx
  8007eb:	5e                   	pop    %esi
  8007ec:	5d                   	pop    %ebp
  8007ed:	c3                   	ret    

008007ee <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ee:	f3 0f 1e fb          	endbr32 
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	56                   	push   %esi
  8007f6:	53                   	push   %ebx
  8007f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007fd:	8b 55 10             	mov    0x10(%ebp),%edx
  800800:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800802:	85 d2                	test   %edx,%edx
  800804:	74 21                	je     800827 <strlcpy+0x39>
  800806:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80080a:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80080c:	39 c2                	cmp    %eax,%edx
  80080e:	74 14                	je     800824 <strlcpy+0x36>
  800810:	0f b6 19             	movzbl (%ecx),%ebx
  800813:	84 db                	test   %bl,%bl
  800815:	74 0b                	je     800822 <strlcpy+0x34>
			*dst++ = *src++;
  800817:	83 c1 01             	add    $0x1,%ecx
  80081a:	83 c2 01             	add    $0x1,%edx
  80081d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800820:	eb ea                	jmp    80080c <strlcpy+0x1e>
  800822:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800824:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800827:	29 f0                	sub    %esi,%eax
}
  800829:	5b                   	pop    %ebx
  80082a:	5e                   	pop    %esi
  80082b:	5d                   	pop    %ebp
  80082c:	c3                   	ret    

0080082d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80082d:	f3 0f 1e fb          	endbr32 
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800837:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80083a:	0f b6 01             	movzbl (%ecx),%eax
  80083d:	84 c0                	test   %al,%al
  80083f:	74 0c                	je     80084d <strcmp+0x20>
  800841:	3a 02                	cmp    (%edx),%al
  800843:	75 08                	jne    80084d <strcmp+0x20>
		p++, q++;
  800845:	83 c1 01             	add    $0x1,%ecx
  800848:	83 c2 01             	add    $0x1,%edx
  80084b:	eb ed                	jmp    80083a <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80084d:	0f b6 c0             	movzbl %al,%eax
  800850:	0f b6 12             	movzbl (%edx),%edx
  800853:	29 d0                	sub    %edx,%eax
}
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    

00800857 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800857:	f3 0f 1e fb          	endbr32 
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	53                   	push   %ebx
  80085f:	8b 45 08             	mov    0x8(%ebp),%eax
  800862:	8b 55 0c             	mov    0xc(%ebp),%edx
  800865:	89 c3                	mov    %eax,%ebx
  800867:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80086a:	eb 06                	jmp    800872 <strncmp+0x1b>
		n--, p++, q++;
  80086c:	83 c0 01             	add    $0x1,%eax
  80086f:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800872:	39 d8                	cmp    %ebx,%eax
  800874:	74 16                	je     80088c <strncmp+0x35>
  800876:	0f b6 08             	movzbl (%eax),%ecx
  800879:	84 c9                	test   %cl,%cl
  80087b:	74 04                	je     800881 <strncmp+0x2a>
  80087d:	3a 0a                	cmp    (%edx),%cl
  80087f:	74 eb                	je     80086c <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800881:	0f b6 00             	movzbl (%eax),%eax
  800884:	0f b6 12             	movzbl (%edx),%edx
  800887:	29 d0                	sub    %edx,%eax
}
  800889:	5b                   	pop    %ebx
  80088a:	5d                   	pop    %ebp
  80088b:	c3                   	ret    
		return 0;
  80088c:	b8 00 00 00 00       	mov    $0x0,%eax
  800891:	eb f6                	jmp    800889 <strncmp+0x32>

00800893 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800893:	f3 0f 1e fb          	endbr32 
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	8b 45 08             	mov    0x8(%ebp),%eax
  80089d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a1:	0f b6 10             	movzbl (%eax),%edx
  8008a4:	84 d2                	test   %dl,%dl
  8008a6:	74 09                	je     8008b1 <strchr+0x1e>
		if (*s == c)
  8008a8:	38 ca                	cmp    %cl,%dl
  8008aa:	74 0a                	je     8008b6 <strchr+0x23>
	for (; *s; s++)
  8008ac:	83 c0 01             	add    $0x1,%eax
  8008af:	eb f0                	jmp    8008a1 <strchr+0xe>
			return (char *) s;
	return 0;
  8008b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b6:	5d                   	pop    %ebp
  8008b7:	c3                   	ret    

008008b8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008b8:	f3 0f 1e fb          	endbr32 
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008c9:	38 ca                	cmp    %cl,%dl
  8008cb:	74 09                	je     8008d6 <strfind+0x1e>
  8008cd:	84 d2                	test   %dl,%dl
  8008cf:	74 05                	je     8008d6 <strfind+0x1e>
	for (; *s; s++)
  8008d1:	83 c0 01             	add    $0x1,%eax
  8008d4:	eb f0                	jmp    8008c6 <strfind+0xe>
			break;
	return (char *) s;
}
  8008d6:	5d                   	pop    %ebp
  8008d7:	c3                   	ret    

008008d8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d8:	f3 0f 1e fb          	endbr32 
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	57                   	push   %edi
  8008e0:	56                   	push   %esi
  8008e1:	53                   	push   %ebx
  8008e2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e8:	85 c9                	test   %ecx,%ecx
  8008ea:	74 31                	je     80091d <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ec:	89 f8                	mov    %edi,%eax
  8008ee:	09 c8                	or     %ecx,%eax
  8008f0:	a8 03                	test   $0x3,%al
  8008f2:	75 23                	jne    800917 <memset+0x3f>
		c &= 0xFF;
  8008f4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f8:	89 d3                	mov    %edx,%ebx
  8008fa:	c1 e3 08             	shl    $0x8,%ebx
  8008fd:	89 d0                	mov    %edx,%eax
  8008ff:	c1 e0 18             	shl    $0x18,%eax
  800902:	89 d6                	mov    %edx,%esi
  800904:	c1 e6 10             	shl    $0x10,%esi
  800907:	09 f0                	or     %esi,%eax
  800909:	09 c2                	or     %eax,%edx
  80090b:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80090d:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800910:	89 d0                	mov    %edx,%eax
  800912:	fc                   	cld    
  800913:	f3 ab                	rep stos %eax,%es:(%edi)
  800915:	eb 06                	jmp    80091d <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800917:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091a:	fc                   	cld    
  80091b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80091d:	89 f8                	mov    %edi,%eax
  80091f:	5b                   	pop    %ebx
  800920:	5e                   	pop    %esi
  800921:	5f                   	pop    %edi
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800924:	f3 0f 1e fb          	endbr32 
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	57                   	push   %edi
  80092c:	56                   	push   %esi
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	8b 75 0c             	mov    0xc(%ebp),%esi
  800933:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800936:	39 c6                	cmp    %eax,%esi
  800938:	73 32                	jae    80096c <memmove+0x48>
  80093a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093d:	39 c2                	cmp    %eax,%edx
  80093f:	76 2b                	jbe    80096c <memmove+0x48>
		s += n;
		d += n;
  800941:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800944:	89 fe                	mov    %edi,%esi
  800946:	09 ce                	or     %ecx,%esi
  800948:	09 d6                	or     %edx,%esi
  80094a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800950:	75 0e                	jne    800960 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800952:	83 ef 04             	sub    $0x4,%edi
  800955:	8d 72 fc             	lea    -0x4(%edx),%esi
  800958:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80095b:	fd                   	std    
  80095c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095e:	eb 09                	jmp    800969 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800960:	83 ef 01             	sub    $0x1,%edi
  800963:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800966:	fd                   	std    
  800967:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800969:	fc                   	cld    
  80096a:	eb 1a                	jmp    800986 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096c:	89 c2                	mov    %eax,%edx
  80096e:	09 ca                	or     %ecx,%edx
  800970:	09 f2                	or     %esi,%edx
  800972:	f6 c2 03             	test   $0x3,%dl
  800975:	75 0a                	jne    800981 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800977:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80097a:	89 c7                	mov    %eax,%edi
  80097c:	fc                   	cld    
  80097d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097f:	eb 05                	jmp    800986 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800981:	89 c7                	mov    %eax,%edi
  800983:	fc                   	cld    
  800984:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800986:	5e                   	pop    %esi
  800987:	5f                   	pop    %edi
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80098a:	f3 0f 1e fb          	endbr32 
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800994:	ff 75 10             	pushl  0x10(%ebp)
  800997:	ff 75 0c             	pushl  0xc(%ebp)
  80099a:	ff 75 08             	pushl  0x8(%ebp)
  80099d:	e8 82 ff ff ff       	call   800924 <memmove>
}
  8009a2:	c9                   	leave  
  8009a3:	c3                   	ret    

008009a4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a4:	f3 0f 1e fb          	endbr32 
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	56                   	push   %esi
  8009ac:	53                   	push   %ebx
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b3:	89 c6                	mov    %eax,%esi
  8009b5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b8:	39 f0                	cmp    %esi,%eax
  8009ba:	74 1c                	je     8009d8 <memcmp+0x34>
		if (*s1 != *s2)
  8009bc:	0f b6 08             	movzbl (%eax),%ecx
  8009bf:	0f b6 1a             	movzbl (%edx),%ebx
  8009c2:	38 d9                	cmp    %bl,%cl
  8009c4:	75 08                	jne    8009ce <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009c6:	83 c0 01             	add    $0x1,%eax
  8009c9:	83 c2 01             	add    $0x1,%edx
  8009cc:	eb ea                	jmp    8009b8 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8009ce:	0f b6 c1             	movzbl %cl,%eax
  8009d1:	0f b6 db             	movzbl %bl,%ebx
  8009d4:	29 d8                	sub    %ebx,%eax
  8009d6:	eb 05                	jmp    8009dd <memcmp+0x39>
	}

	return 0;
  8009d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009dd:	5b                   	pop    %ebx
  8009de:	5e                   	pop    %esi
  8009df:	5d                   	pop    %ebp
  8009e0:	c3                   	ret    

008009e1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e1:	f3 0f 1e fb          	endbr32 
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009ee:	89 c2                	mov    %eax,%edx
  8009f0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009f3:	39 d0                	cmp    %edx,%eax
  8009f5:	73 09                	jae    800a00 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f7:	38 08                	cmp    %cl,(%eax)
  8009f9:	74 05                	je     800a00 <memfind+0x1f>
	for (; s < ends; s++)
  8009fb:	83 c0 01             	add    $0x1,%eax
  8009fe:	eb f3                	jmp    8009f3 <memfind+0x12>
			break;
	return (void *) s;
}
  800a00:	5d                   	pop    %ebp
  800a01:	c3                   	ret    

00800a02 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a02:	f3 0f 1e fb          	endbr32 
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	57                   	push   %edi
  800a0a:	56                   	push   %esi
  800a0b:	53                   	push   %ebx
  800a0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a12:	eb 03                	jmp    800a17 <strtol+0x15>
		s++;
  800a14:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a17:	0f b6 01             	movzbl (%ecx),%eax
  800a1a:	3c 20                	cmp    $0x20,%al
  800a1c:	74 f6                	je     800a14 <strtol+0x12>
  800a1e:	3c 09                	cmp    $0x9,%al
  800a20:	74 f2                	je     800a14 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a22:	3c 2b                	cmp    $0x2b,%al
  800a24:	74 2a                	je     800a50 <strtol+0x4e>
	int neg = 0;
  800a26:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a2b:	3c 2d                	cmp    $0x2d,%al
  800a2d:	74 2b                	je     800a5a <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a2f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a35:	75 0f                	jne    800a46 <strtol+0x44>
  800a37:	80 39 30             	cmpb   $0x30,(%ecx)
  800a3a:	74 28                	je     800a64 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a3c:	85 db                	test   %ebx,%ebx
  800a3e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a43:	0f 44 d8             	cmove  %eax,%ebx
  800a46:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a4e:	eb 46                	jmp    800a96 <strtol+0x94>
		s++;
  800a50:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a53:	bf 00 00 00 00       	mov    $0x0,%edi
  800a58:	eb d5                	jmp    800a2f <strtol+0x2d>
		s++, neg = 1;
  800a5a:	83 c1 01             	add    $0x1,%ecx
  800a5d:	bf 01 00 00 00       	mov    $0x1,%edi
  800a62:	eb cb                	jmp    800a2f <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a64:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a68:	74 0e                	je     800a78 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a6a:	85 db                	test   %ebx,%ebx
  800a6c:	75 d8                	jne    800a46 <strtol+0x44>
		s++, base = 8;
  800a6e:	83 c1 01             	add    $0x1,%ecx
  800a71:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a76:	eb ce                	jmp    800a46 <strtol+0x44>
		s += 2, base = 16;
  800a78:	83 c1 02             	add    $0x2,%ecx
  800a7b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a80:	eb c4                	jmp    800a46 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a82:	0f be d2             	movsbl %dl,%edx
  800a85:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a88:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a8b:	7d 3a                	jge    800ac7 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a8d:	83 c1 01             	add    $0x1,%ecx
  800a90:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a94:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a96:	0f b6 11             	movzbl (%ecx),%edx
  800a99:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a9c:	89 f3                	mov    %esi,%ebx
  800a9e:	80 fb 09             	cmp    $0x9,%bl
  800aa1:	76 df                	jbe    800a82 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800aa3:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aa6:	89 f3                	mov    %esi,%ebx
  800aa8:	80 fb 19             	cmp    $0x19,%bl
  800aab:	77 08                	ja     800ab5 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800aad:	0f be d2             	movsbl %dl,%edx
  800ab0:	83 ea 57             	sub    $0x57,%edx
  800ab3:	eb d3                	jmp    800a88 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800ab5:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ab8:	89 f3                	mov    %esi,%ebx
  800aba:	80 fb 19             	cmp    $0x19,%bl
  800abd:	77 08                	ja     800ac7 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800abf:	0f be d2             	movsbl %dl,%edx
  800ac2:	83 ea 37             	sub    $0x37,%edx
  800ac5:	eb c1                	jmp    800a88 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ac7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800acb:	74 05                	je     800ad2 <strtol+0xd0>
		*endptr = (char *) s;
  800acd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad0:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ad2:	89 c2                	mov    %eax,%edx
  800ad4:	f7 da                	neg    %edx
  800ad6:	85 ff                	test   %edi,%edi
  800ad8:	0f 45 c2             	cmovne %edx,%eax
}
  800adb:	5b                   	pop    %ebx
  800adc:	5e                   	pop    %esi
  800add:	5f                   	pop    %edi
  800ade:	5d                   	pop    %ebp
  800adf:	c3                   	ret    

00800ae0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ae0:	f3 0f 1e fb          	endbr32 
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	57                   	push   %edi
  800ae8:	56                   	push   %esi
  800ae9:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800aea:	b8 00 00 00 00       	mov    $0x0,%eax
  800aef:	8b 55 08             	mov    0x8(%ebp),%edx
  800af2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af5:	89 c3                	mov    %eax,%ebx
  800af7:	89 c7                	mov    %eax,%edi
  800af9:	89 c6                	mov    %eax,%esi
  800afb:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5f                   	pop    %edi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b02:	f3 0f 1e fb          	endbr32 
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	57                   	push   %edi
  800b0a:	56                   	push   %esi
  800b0b:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800b0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b11:	b8 01 00 00 00       	mov    $0x1,%eax
  800b16:	89 d1                	mov    %edx,%ecx
  800b18:	89 d3                	mov    %edx,%ebx
  800b1a:	89 d7                	mov    %edx,%edi
  800b1c:	89 d6                	mov    %edx,%esi
  800b1e:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5f                   	pop    %edi
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b25:	f3 0f 1e fb          	endbr32 
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	57                   	push   %edi
  800b2d:	56                   	push   %esi
  800b2e:	53                   	push   %ebx
  800b2f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800b32:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b37:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b3f:	89 cb                	mov    %ecx,%ebx
  800b41:	89 cf                	mov    %ecx,%edi
  800b43:	89 ce                	mov    %ecx,%esi
  800b45:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b47:	85 c0                	test   %eax,%eax
  800b49:	7f 08                	jg     800b53 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b4e:	5b                   	pop    %ebx
  800b4f:	5e                   	pop    %esi
  800b50:	5f                   	pop    %edi
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b53:	83 ec 0c             	sub    $0xc,%esp
  800b56:	50                   	push   %eax
  800b57:	6a 03                	push   $0x3
  800b59:	68 a4 12 80 00       	push   $0x8012a4
  800b5e:	6a 23                	push   $0x23
  800b60:	68 c1 12 80 00       	push   $0x8012c1
  800b65:	e8 11 02 00 00       	call   800d7b <_panic>

00800b6a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b6a:	f3 0f 1e fb          	endbr32 
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	57                   	push   %edi
  800b72:	56                   	push   %esi
  800b73:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800b74:	ba 00 00 00 00       	mov    $0x0,%edx
  800b79:	b8 02 00 00 00       	mov    $0x2,%eax
  800b7e:	89 d1                	mov    %edx,%ecx
  800b80:	89 d3                	mov    %edx,%ebx
  800b82:	89 d7                	mov    %edx,%edi
  800b84:	89 d6                	mov    %edx,%esi
  800b86:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b88:	5b                   	pop    %ebx
  800b89:	5e                   	pop    %esi
  800b8a:	5f                   	pop    %edi
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <sys_yield>:

void
sys_yield(void)
{
  800b8d:	f3 0f 1e fb          	endbr32 
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	57                   	push   %edi
  800b95:	56                   	push   %esi
  800b96:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800b97:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ba1:	89 d1                	mov    %edx,%ecx
  800ba3:	89 d3                	mov    %edx,%ebx
  800ba5:	89 d7                	mov    %edx,%edi
  800ba7:	89 d6                	mov    %edx,%esi
  800ba9:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bab:	5b                   	pop    %ebx
  800bac:	5e                   	pop    %esi
  800bad:	5f                   	pop    %edi
  800bae:	5d                   	pop    %ebp
  800baf:	c3                   	ret    

00800bb0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb0:	f3 0f 1e fb          	endbr32 
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	53                   	push   %ebx
  800bba:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800bbd:	be 00 00 00 00       	mov    $0x0,%esi
  800bc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc8:	b8 04 00 00 00       	mov    $0x4,%eax
  800bcd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd0:	89 f7                	mov    %esi,%edi
  800bd2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bd4:	85 c0                	test   %eax,%eax
  800bd6:	7f 08                	jg     800be0 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bdb:	5b                   	pop    %ebx
  800bdc:	5e                   	pop    %esi
  800bdd:	5f                   	pop    %edi
  800bde:	5d                   	pop    %ebp
  800bdf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800be0:	83 ec 0c             	sub    $0xc,%esp
  800be3:	50                   	push   %eax
  800be4:	6a 04                	push   $0x4
  800be6:	68 a4 12 80 00       	push   $0x8012a4
  800beb:	6a 23                	push   $0x23
  800bed:	68 c1 12 80 00       	push   $0x8012c1
  800bf2:	e8 84 01 00 00       	call   800d7b <_panic>

00800bf7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf7:	f3 0f 1e fb          	endbr32 
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
  800c01:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c04:	8b 55 08             	mov    0x8(%ebp),%edx
  800c07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c12:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c15:	8b 75 18             	mov    0x18(%ebp),%esi
  800c18:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c1a:	85 c0                	test   %eax,%eax
  800c1c:	7f 08                	jg     800c26 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c26:	83 ec 0c             	sub    $0xc,%esp
  800c29:	50                   	push   %eax
  800c2a:	6a 05                	push   $0x5
  800c2c:	68 a4 12 80 00       	push   $0x8012a4
  800c31:	6a 23                	push   $0x23
  800c33:	68 c1 12 80 00       	push   $0x8012c1
  800c38:	e8 3e 01 00 00       	call   800d7b <_panic>

00800c3d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c3d:	f3 0f 1e fb          	endbr32 
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	57                   	push   %edi
  800c45:	56                   	push   %esi
  800c46:	53                   	push   %ebx
  800c47:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c4a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c55:	b8 06 00 00 00       	mov    $0x6,%eax
  800c5a:	89 df                	mov    %ebx,%edi
  800c5c:	89 de                	mov    %ebx,%esi
  800c5e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c60:	85 c0                	test   %eax,%eax
  800c62:	7f 08                	jg     800c6c <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c67:	5b                   	pop    %ebx
  800c68:	5e                   	pop    %esi
  800c69:	5f                   	pop    %edi
  800c6a:	5d                   	pop    %ebp
  800c6b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6c:	83 ec 0c             	sub    $0xc,%esp
  800c6f:	50                   	push   %eax
  800c70:	6a 06                	push   $0x6
  800c72:	68 a4 12 80 00       	push   $0x8012a4
  800c77:	6a 23                	push   $0x23
  800c79:	68 c1 12 80 00       	push   $0x8012c1
  800c7e:	e8 f8 00 00 00       	call   800d7b <_panic>

00800c83 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c83:	f3 0f 1e fb          	endbr32 
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	57                   	push   %edi
  800c8b:	56                   	push   %esi
  800c8c:	53                   	push   %ebx
  800c8d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c90:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c95:	8b 55 08             	mov    0x8(%ebp),%edx
  800c98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9b:	b8 08 00 00 00       	mov    $0x8,%eax
  800ca0:	89 df                	mov    %ebx,%edi
  800ca2:	89 de                	mov    %ebx,%esi
  800ca4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca6:	85 c0                	test   %eax,%eax
  800ca8:	7f 08                	jg     800cb2 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800caa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cad:	5b                   	pop    %ebx
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	5d                   	pop    %ebp
  800cb1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb2:	83 ec 0c             	sub    $0xc,%esp
  800cb5:	50                   	push   %eax
  800cb6:	6a 08                	push   $0x8
  800cb8:	68 a4 12 80 00       	push   $0x8012a4
  800cbd:	6a 23                	push   $0x23
  800cbf:	68 c1 12 80 00       	push   $0x8012c1
  800cc4:	e8 b2 00 00 00       	call   800d7b <_panic>

00800cc9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc9:	f3 0f 1e fb          	endbr32 
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	57                   	push   %edi
  800cd1:	56                   	push   %esi
  800cd2:	53                   	push   %ebx
  800cd3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800cd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce1:	b8 09 00 00 00       	mov    $0x9,%eax
  800ce6:	89 df                	mov    %ebx,%edi
  800ce8:	89 de                	mov    %ebx,%esi
  800cea:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cec:	85 c0                	test   %eax,%eax
  800cee:	7f 08                	jg     800cf8 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cf0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf3:	5b                   	pop    %ebx
  800cf4:	5e                   	pop    %esi
  800cf5:	5f                   	pop    %edi
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf8:	83 ec 0c             	sub    $0xc,%esp
  800cfb:	50                   	push   %eax
  800cfc:	6a 09                	push   $0x9
  800cfe:	68 a4 12 80 00       	push   $0x8012a4
  800d03:	6a 23                	push   $0x23
  800d05:	68 c1 12 80 00       	push   $0x8012c1
  800d0a:	e8 6c 00 00 00       	call   800d7b <_panic>

00800d0f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d0f:	f3 0f 1e fb          	endbr32 
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	57                   	push   %edi
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d24:	be 00 00 00 00       	mov    $0x0,%esi
  800d29:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d31:	5b                   	pop    %ebx
  800d32:	5e                   	pop    %esi
  800d33:	5f                   	pop    %edi
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d36:	f3 0f 1e fb          	endbr32 
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	57                   	push   %edi
  800d3e:	56                   	push   %esi
  800d3f:	53                   	push   %ebx
  800d40:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d43:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d48:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d50:	89 cb                	mov    %ecx,%ebx
  800d52:	89 cf                	mov    %ecx,%edi
  800d54:	89 ce                	mov    %ecx,%esi
  800d56:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d58:	85 c0                	test   %eax,%eax
  800d5a:	7f 08                	jg     800d64 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5f:	5b                   	pop    %ebx
  800d60:	5e                   	pop    %esi
  800d61:	5f                   	pop    %edi
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d64:	83 ec 0c             	sub    $0xc,%esp
  800d67:	50                   	push   %eax
  800d68:	6a 0c                	push   $0xc
  800d6a:	68 a4 12 80 00       	push   $0x8012a4
  800d6f:	6a 23                	push   $0x23
  800d71:	68 c1 12 80 00       	push   $0x8012c1
  800d76:	e8 00 00 00 00       	call   800d7b <_panic>

00800d7b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d7b:	f3 0f 1e fb          	endbr32 
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	56                   	push   %esi
  800d83:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d84:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d87:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d8d:	e8 d8 fd ff ff       	call   800b6a <sys_getenvid>
  800d92:	83 ec 0c             	sub    $0xc,%esp
  800d95:	ff 75 0c             	pushl  0xc(%ebp)
  800d98:	ff 75 08             	pushl  0x8(%ebp)
  800d9b:	56                   	push   %esi
  800d9c:	50                   	push   %eax
  800d9d:	68 d0 12 80 00       	push   $0x8012d0
  800da2:	e8 bd f3 ff ff       	call   800164 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800da7:	83 c4 18             	add    $0x18,%esp
  800daa:	53                   	push   %ebx
  800dab:	ff 75 10             	pushl  0x10(%ebp)
  800dae:	e8 5c f3 ff ff       	call   80010f <vcprintf>
	cprintf("\n");
  800db3:	c7 04 24 4c 10 80 00 	movl   $0x80104c,(%esp)
  800dba:	e8 a5 f3 ff ff       	call   800164 <cprintf>
  800dbf:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800dc2:	cc                   	int3   
  800dc3:	eb fd                	jmp    800dc2 <_panic+0x47>
  800dc5:	66 90                	xchg   %ax,%ax
  800dc7:	66 90                	xchg   %ax,%ax
  800dc9:	66 90                	xchg   %ax,%ax
  800dcb:	66 90                	xchg   %ax,%ax
  800dcd:	66 90                	xchg   %ax,%ax
  800dcf:	90                   	nop

00800dd0 <__udivdi3>:
  800dd0:	f3 0f 1e fb          	endbr32 
  800dd4:	55                   	push   %ebp
  800dd5:	57                   	push   %edi
  800dd6:	56                   	push   %esi
  800dd7:	53                   	push   %ebx
  800dd8:	83 ec 1c             	sub    $0x1c,%esp
  800ddb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800ddf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800de3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800de7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800deb:	85 d2                	test   %edx,%edx
  800ded:	75 19                	jne    800e08 <__udivdi3+0x38>
  800def:	39 f3                	cmp    %esi,%ebx
  800df1:	76 4d                	jbe    800e40 <__udivdi3+0x70>
  800df3:	31 ff                	xor    %edi,%edi
  800df5:	89 e8                	mov    %ebp,%eax
  800df7:	89 f2                	mov    %esi,%edx
  800df9:	f7 f3                	div    %ebx
  800dfb:	89 fa                	mov    %edi,%edx
  800dfd:	83 c4 1c             	add    $0x1c,%esp
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    
  800e05:	8d 76 00             	lea    0x0(%esi),%esi
  800e08:	39 f2                	cmp    %esi,%edx
  800e0a:	76 14                	jbe    800e20 <__udivdi3+0x50>
  800e0c:	31 ff                	xor    %edi,%edi
  800e0e:	31 c0                	xor    %eax,%eax
  800e10:	89 fa                	mov    %edi,%edx
  800e12:	83 c4 1c             	add    $0x1c,%esp
  800e15:	5b                   	pop    %ebx
  800e16:	5e                   	pop    %esi
  800e17:	5f                   	pop    %edi
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    
  800e1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e20:	0f bd fa             	bsr    %edx,%edi
  800e23:	83 f7 1f             	xor    $0x1f,%edi
  800e26:	75 48                	jne    800e70 <__udivdi3+0xa0>
  800e28:	39 f2                	cmp    %esi,%edx
  800e2a:	72 06                	jb     800e32 <__udivdi3+0x62>
  800e2c:	31 c0                	xor    %eax,%eax
  800e2e:	39 eb                	cmp    %ebp,%ebx
  800e30:	77 de                	ja     800e10 <__udivdi3+0x40>
  800e32:	b8 01 00 00 00       	mov    $0x1,%eax
  800e37:	eb d7                	jmp    800e10 <__udivdi3+0x40>
  800e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e40:	89 d9                	mov    %ebx,%ecx
  800e42:	85 db                	test   %ebx,%ebx
  800e44:	75 0b                	jne    800e51 <__udivdi3+0x81>
  800e46:	b8 01 00 00 00       	mov    $0x1,%eax
  800e4b:	31 d2                	xor    %edx,%edx
  800e4d:	f7 f3                	div    %ebx
  800e4f:	89 c1                	mov    %eax,%ecx
  800e51:	31 d2                	xor    %edx,%edx
  800e53:	89 f0                	mov    %esi,%eax
  800e55:	f7 f1                	div    %ecx
  800e57:	89 c6                	mov    %eax,%esi
  800e59:	89 e8                	mov    %ebp,%eax
  800e5b:	89 f7                	mov    %esi,%edi
  800e5d:	f7 f1                	div    %ecx
  800e5f:	89 fa                	mov    %edi,%edx
  800e61:	83 c4 1c             	add    $0x1c,%esp
  800e64:	5b                   	pop    %ebx
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    
  800e69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e70:	89 f9                	mov    %edi,%ecx
  800e72:	b8 20 00 00 00       	mov    $0x20,%eax
  800e77:	29 f8                	sub    %edi,%eax
  800e79:	d3 e2                	shl    %cl,%edx
  800e7b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e7f:	89 c1                	mov    %eax,%ecx
  800e81:	89 da                	mov    %ebx,%edx
  800e83:	d3 ea                	shr    %cl,%edx
  800e85:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e89:	09 d1                	or     %edx,%ecx
  800e8b:	89 f2                	mov    %esi,%edx
  800e8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e91:	89 f9                	mov    %edi,%ecx
  800e93:	d3 e3                	shl    %cl,%ebx
  800e95:	89 c1                	mov    %eax,%ecx
  800e97:	d3 ea                	shr    %cl,%edx
  800e99:	89 f9                	mov    %edi,%ecx
  800e9b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e9f:	89 eb                	mov    %ebp,%ebx
  800ea1:	d3 e6                	shl    %cl,%esi
  800ea3:	89 c1                	mov    %eax,%ecx
  800ea5:	d3 eb                	shr    %cl,%ebx
  800ea7:	09 de                	or     %ebx,%esi
  800ea9:	89 f0                	mov    %esi,%eax
  800eab:	f7 74 24 08          	divl   0x8(%esp)
  800eaf:	89 d6                	mov    %edx,%esi
  800eb1:	89 c3                	mov    %eax,%ebx
  800eb3:	f7 64 24 0c          	mull   0xc(%esp)
  800eb7:	39 d6                	cmp    %edx,%esi
  800eb9:	72 15                	jb     800ed0 <__udivdi3+0x100>
  800ebb:	89 f9                	mov    %edi,%ecx
  800ebd:	d3 e5                	shl    %cl,%ebp
  800ebf:	39 c5                	cmp    %eax,%ebp
  800ec1:	73 04                	jae    800ec7 <__udivdi3+0xf7>
  800ec3:	39 d6                	cmp    %edx,%esi
  800ec5:	74 09                	je     800ed0 <__udivdi3+0x100>
  800ec7:	89 d8                	mov    %ebx,%eax
  800ec9:	31 ff                	xor    %edi,%edi
  800ecb:	e9 40 ff ff ff       	jmp    800e10 <__udivdi3+0x40>
  800ed0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ed3:	31 ff                	xor    %edi,%edi
  800ed5:	e9 36 ff ff ff       	jmp    800e10 <__udivdi3+0x40>
  800eda:	66 90                	xchg   %ax,%ax
  800edc:	66 90                	xchg   %ax,%ax
  800ede:	66 90                	xchg   %ax,%ax

00800ee0 <__umoddi3>:
  800ee0:	f3 0f 1e fb          	endbr32 
  800ee4:	55                   	push   %ebp
  800ee5:	57                   	push   %edi
  800ee6:	56                   	push   %esi
  800ee7:	53                   	push   %ebx
  800ee8:	83 ec 1c             	sub    $0x1c,%esp
  800eeb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800eef:	8b 74 24 30          	mov    0x30(%esp),%esi
  800ef3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800ef7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800efb:	85 c0                	test   %eax,%eax
  800efd:	75 19                	jne    800f18 <__umoddi3+0x38>
  800eff:	39 df                	cmp    %ebx,%edi
  800f01:	76 5d                	jbe    800f60 <__umoddi3+0x80>
  800f03:	89 f0                	mov    %esi,%eax
  800f05:	89 da                	mov    %ebx,%edx
  800f07:	f7 f7                	div    %edi
  800f09:	89 d0                	mov    %edx,%eax
  800f0b:	31 d2                	xor    %edx,%edx
  800f0d:	83 c4 1c             	add    $0x1c,%esp
  800f10:	5b                   	pop    %ebx
  800f11:	5e                   	pop    %esi
  800f12:	5f                   	pop    %edi
  800f13:	5d                   	pop    %ebp
  800f14:	c3                   	ret    
  800f15:	8d 76 00             	lea    0x0(%esi),%esi
  800f18:	89 f2                	mov    %esi,%edx
  800f1a:	39 d8                	cmp    %ebx,%eax
  800f1c:	76 12                	jbe    800f30 <__umoddi3+0x50>
  800f1e:	89 f0                	mov    %esi,%eax
  800f20:	89 da                	mov    %ebx,%edx
  800f22:	83 c4 1c             	add    $0x1c,%esp
  800f25:	5b                   	pop    %ebx
  800f26:	5e                   	pop    %esi
  800f27:	5f                   	pop    %edi
  800f28:	5d                   	pop    %ebp
  800f29:	c3                   	ret    
  800f2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f30:	0f bd e8             	bsr    %eax,%ebp
  800f33:	83 f5 1f             	xor    $0x1f,%ebp
  800f36:	75 50                	jne    800f88 <__umoddi3+0xa8>
  800f38:	39 d8                	cmp    %ebx,%eax
  800f3a:	0f 82 e0 00 00 00    	jb     801020 <__umoddi3+0x140>
  800f40:	89 d9                	mov    %ebx,%ecx
  800f42:	39 f7                	cmp    %esi,%edi
  800f44:	0f 86 d6 00 00 00    	jbe    801020 <__umoddi3+0x140>
  800f4a:	89 d0                	mov    %edx,%eax
  800f4c:	89 ca                	mov    %ecx,%edx
  800f4e:	83 c4 1c             	add    $0x1c,%esp
  800f51:	5b                   	pop    %ebx
  800f52:	5e                   	pop    %esi
  800f53:	5f                   	pop    %edi
  800f54:	5d                   	pop    %ebp
  800f55:	c3                   	ret    
  800f56:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f5d:	8d 76 00             	lea    0x0(%esi),%esi
  800f60:	89 fd                	mov    %edi,%ebp
  800f62:	85 ff                	test   %edi,%edi
  800f64:	75 0b                	jne    800f71 <__umoddi3+0x91>
  800f66:	b8 01 00 00 00       	mov    $0x1,%eax
  800f6b:	31 d2                	xor    %edx,%edx
  800f6d:	f7 f7                	div    %edi
  800f6f:	89 c5                	mov    %eax,%ebp
  800f71:	89 d8                	mov    %ebx,%eax
  800f73:	31 d2                	xor    %edx,%edx
  800f75:	f7 f5                	div    %ebp
  800f77:	89 f0                	mov    %esi,%eax
  800f79:	f7 f5                	div    %ebp
  800f7b:	89 d0                	mov    %edx,%eax
  800f7d:	31 d2                	xor    %edx,%edx
  800f7f:	eb 8c                	jmp    800f0d <__umoddi3+0x2d>
  800f81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f88:	89 e9                	mov    %ebp,%ecx
  800f8a:	ba 20 00 00 00       	mov    $0x20,%edx
  800f8f:	29 ea                	sub    %ebp,%edx
  800f91:	d3 e0                	shl    %cl,%eax
  800f93:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f97:	89 d1                	mov    %edx,%ecx
  800f99:	89 f8                	mov    %edi,%eax
  800f9b:	d3 e8                	shr    %cl,%eax
  800f9d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800fa1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fa5:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fa9:	09 c1                	or     %eax,%ecx
  800fab:	89 d8                	mov    %ebx,%eax
  800fad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fb1:	89 e9                	mov    %ebp,%ecx
  800fb3:	d3 e7                	shl    %cl,%edi
  800fb5:	89 d1                	mov    %edx,%ecx
  800fb7:	d3 e8                	shr    %cl,%eax
  800fb9:	89 e9                	mov    %ebp,%ecx
  800fbb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fbf:	d3 e3                	shl    %cl,%ebx
  800fc1:	89 c7                	mov    %eax,%edi
  800fc3:	89 d1                	mov    %edx,%ecx
  800fc5:	89 f0                	mov    %esi,%eax
  800fc7:	d3 e8                	shr    %cl,%eax
  800fc9:	89 e9                	mov    %ebp,%ecx
  800fcb:	89 fa                	mov    %edi,%edx
  800fcd:	d3 e6                	shl    %cl,%esi
  800fcf:	09 d8                	or     %ebx,%eax
  800fd1:	f7 74 24 08          	divl   0x8(%esp)
  800fd5:	89 d1                	mov    %edx,%ecx
  800fd7:	89 f3                	mov    %esi,%ebx
  800fd9:	f7 64 24 0c          	mull   0xc(%esp)
  800fdd:	89 c6                	mov    %eax,%esi
  800fdf:	89 d7                	mov    %edx,%edi
  800fe1:	39 d1                	cmp    %edx,%ecx
  800fe3:	72 06                	jb     800feb <__umoddi3+0x10b>
  800fe5:	75 10                	jne    800ff7 <__umoddi3+0x117>
  800fe7:	39 c3                	cmp    %eax,%ebx
  800fe9:	73 0c                	jae    800ff7 <__umoddi3+0x117>
  800feb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800fef:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800ff3:	89 d7                	mov    %edx,%edi
  800ff5:	89 c6                	mov    %eax,%esi
  800ff7:	89 ca                	mov    %ecx,%edx
  800ff9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ffe:	29 f3                	sub    %esi,%ebx
  801000:	19 fa                	sbb    %edi,%edx
  801002:	89 d0                	mov    %edx,%eax
  801004:	d3 e0                	shl    %cl,%eax
  801006:	89 e9                	mov    %ebp,%ecx
  801008:	d3 eb                	shr    %cl,%ebx
  80100a:	d3 ea                	shr    %cl,%edx
  80100c:	09 d8                	or     %ebx,%eax
  80100e:	83 c4 1c             	add    $0x1c,%esp
  801011:	5b                   	pop    %ebx
  801012:	5e                   	pop    %esi
  801013:	5f                   	pop    %edi
  801014:	5d                   	pop    %ebp
  801015:	c3                   	ret    
  801016:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80101d:	8d 76 00             	lea    0x0(%esi),%esi
  801020:	29 fe                	sub    %edi,%esi
  801022:	19 c3                	sbb    %eax,%ebx
  801024:	89 f2                	mov    %esi,%edx
  801026:	89 d9                	mov    %ebx,%ecx
  801028:	e9 1d ff ff ff       	jmp    800f4a <__umoddi3+0x6a>
