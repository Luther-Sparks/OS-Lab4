
obj/user/spin:     file format elf32-i386


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
  80002c:	e8 88 00 00 00       	call   8000b9 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	53                   	push   %ebx
  80003b:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003e:	68 a0 13 80 00       	push   $0x8013a0
  800043:	e8 71 01 00 00       	call   8001b9 <cprintf>
	if ((env = fork()) == 0) {
  800048:	e8 57 0e 00 00       	call   800ea4 <fork>
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	85 c0                	test   %eax,%eax
  800052:	75 12                	jne    800066 <umain+0x33>
		cprintf("I am the child.  Spinning...\n");
  800054:	83 ec 0c             	sub    $0xc,%esp
  800057:	68 18 14 80 00       	push   $0x801418
  80005c:	e8 58 01 00 00       	call   8001b9 <cprintf>
  800061:	83 c4 10             	add    $0x10,%esp
  800064:	eb fe                	jmp    800064 <umain+0x31>
  800066:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800068:	83 ec 0c             	sub    $0xc,%esp
  80006b:	68 c8 13 80 00       	push   $0x8013c8
  800070:	e8 44 01 00 00       	call   8001b9 <cprintf>
	sys_yield();
  800075:	e8 68 0b 00 00       	call   800be2 <sys_yield>
	sys_yield();
  80007a:	e8 63 0b 00 00       	call   800be2 <sys_yield>
	sys_yield();
  80007f:	e8 5e 0b 00 00       	call   800be2 <sys_yield>
	sys_yield();
  800084:	e8 59 0b 00 00       	call   800be2 <sys_yield>
	sys_yield();
  800089:	e8 54 0b 00 00       	call   800be2 <sys_yield>
	sys_yield();
  80008e:	e8 4f 0b 00 00       	call   800be2 <sys_yield>
	sys_yield();
  800093:	e8 4a 0b 00 00       	call   800be2 <sys_yield>
	sys_yield();
  800098:	e8 45 0b 00 00       	call   800be2 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  80009d:	c7 04 24 f0 13 80 00 	movl   $0x8013f0,(%esp)
  8000a4:	e8 10 01 00 00       	call   8001b9 <cprintf>
	sys_env_destroy(env);
  8000a9:	89 1c 24             	mov    %ebx,(%esp)
  8000ac:	e8 c9 0a 00 00       	call   800b7a <sys_env_destroy>
}
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b7:	c9                   	leave  
  8000b8:	c3                   	ret    

008000b9 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b9:	f3 0f 1e fb          	endbr32 
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
  8000c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8000c8:	e8 f2 0a 00 00       	call   800bbf <sys_getenvid>
	thisenv = envs + ENVX(envid);
  8000cd:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d2:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  8000d8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000dd:	a3 60 40 80 00       	mov    %eax,0x804060

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e2:	85 db                	test   %ebx,%ebx
  8000e4:	7e 07                	jle    8000ed <libmain+0x34>
		binaryname = argv[0];
  8000e6:	8b 06                	mov    (%esi),%eax
  8000e8:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ed:	83 ec 08             	sub    $0x8,%esp
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	e8 3c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f7:	e8 0a 00 00 00       	call   800106 <exit>
}
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800102:	5b                   	pop    %ebx
  800103:	5e                   	pop    %esi
  800104:	5d                   	pop    %ebp
  800105:	c3                   	ret    

00800106 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800106:	f3 0f 1e fb          	endbr32 
  80010a:	55                   	push   %ebp
  80010b:	89 e5                	mov    %esp,%ebp
  80010d:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800110:	6a 00                	push   $0x0
  800112:	e8 63 0a 00 00       	call   800b7a <sys_env_destroy>
}
  800117:	83 c4 10             	add    $0x10,%esp
  80011a:	c9                   	leave  
  80011b:	c3                   	ret    

0080011c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80011c:	f3 0f 1e fb          	endbr32 
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	53                   	push   %ebx
  800124:	83 ec 04             	sub    $0x4,%esp
  800127:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012a:	8b 13                	mov    (%ebx),%edx
  80012c:	8d 42 01             	lea    0x1(%edx),%eax
  80012f:	89 03                	mov    %eax,(%ebx)
  800131:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800134:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800138:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013d:	74 09                	je     800148 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80013f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800143:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800146:	c9                   	leave  
  800147:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800148:	83 ec 08             	sub    $0x8,%esp
  80014b:	68 ff 00 00 00       	push   $0xff
  800150:	8d 43 08             	lea    0x8(%ebx),%eax
  800153:	50                   	push   %eax
  800154:	e8 dc 09 00 00       	call   800b35 <sys_cputs>
		b->idx = 0;
  800159:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80015f:	83 c4 10             	add    $0x10,%esp
  800162:	eb db                	jmp    80013f <putch+0x23>

00800164 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800164:	f3 0f 1e fb          	endbr32 
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800171:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800178:	00 00 00 
	b.cnt = 0;
  80017b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800182:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800185:	ff 75 0c             	pushl  0xc(%ebp)
  800188:	ff 75 08             	pushl  0x8(%ebp)
  80018b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800191:	50                   	push   %eax
  800192:	68 1c 01 80 00       	push   $0x80011c
  800197:	e8 20 01 00 00       	call   8002bc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80019c:	83 c4 08             	add    $0x8,%esp
  80019f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ab:	50                   	push   %eax
  8001ac:	e8 84 09 00 00       	call   800b35 <sys_cputs>

	return b.cnt;
}
  8001b1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b7:	c9                   	leave  
  8001b8:	c3                   	ret    

008001b9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b9:	f3 0f 1e fb          	endbr32 
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001c3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001c6:	50                   	push   %eax
  8001c7:	ff 75 08             	pushl  0x8(%ebp)
  8001ca:	e8 95 ff ff ff       	call   800164 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001cf:	c9                   	leave  
  8001d0:	c3                   	ret    

008001d1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001d1:	55                   	push   %ebp
  8001d2:	89 e5                	mov    %esp,%ebp
  8001d4:	57                   	push   %edi
  8001d5:	56                   	push   %esi
  8001d6:	53                   	push   %ebx
  8001d7:	83 ec 1c             	sub    $0x1c,%esp
  8001da:	89 c7                	mov    %eax,%edi
  8001dc:	89 d6                	mov    %edx,%esi
  8001de:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e4:	89 d1                	mov    %edx,%ecx
  8001e6:	89 c2                	mov    %eax,%edx
  8001e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001eb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001f7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001fe:	39 c2                	cmp    %eax,%edx
  800200:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800203:	72 3e                	jb     800243 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800205:	83 ec 0c             	sub    $0xc,%esp
  800208:	ff 75 18             	pushl  0x18(%ebp)
  80020b:	83 eb 01             	sub    $0x1,%ebx
  80020e:	53                   	push   %ebx
  80020f:	50                   	push   %eax
  800210:	83 ec 08             	sub    $0x8,%esp
  800213:	ff 75 e4             	pushl  -0x1c(%ebp)
  800216:	ff 75 e0             	pushl  -0x20(%ebp)
  800219:	ff 75 dc             	pushl  -0x24(%ebp)
  80021c:	ff 75 d8             	pushl  -0x28(%ebp)
  80021f:	e8 1c 0f 00 00       	call   801140 <__udivdi3>
  800224:	83 c4 18             	add    $0x18,%esp
  800227:	52                   	push   %edx
  800228:	50                   	push   %eax
  800229:	89 f2                	mov    %esi,%edx
  80022b:	89 f8                	mov    %edi,%eax
  80022d:	e8 9f ff ff ff       	call   8001d1 <printnum>
  800232:	83 c4 20             	add    $0x20,%esp
  800235:	eb 13                	jmp    80024a <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800237:	83 ec 08             	sub    $0x8,%esp
  80023a:	56                   	push   %esi
  80023b:	ff 75 18             	pushl  0x18(%ebp)
  80023e:	ff d7                	call   *%edi
  800240:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800243:	83 eb 01             	sub    $0x1,%ebx
  800246:	85 db                	test   %ebx,%ebx
  800248:	7f ed                	jg     800237 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80024a:	83 ec 08             	sub    $0x8,%esp
  80024d:	56                   	push   %esi
  80024e:	83 ec 04             	sub    $0x4,%esp
  800251:	ff 75 e4             	pushl  -0x1c(%ebp)
  800254:	ff 75 e0             	pushl  -0x20(%ebp)
  800257:	ff 75 dc             	pushl  -0x24(%ebp)
  80025a:	ff 75 d8             	pushl  -0x28(%ebp)
  80025d:	e8 ee 0f 00 00       	call   801250 <__umoddi3>
  800262:	83 c4 14             	add    $0x14,%esp
  800265:	0f be 80 40 14 80 00 	movsbl 0x801440(%eax),%eax
  80026c:	50                   	push   %eax
  80026d:	ff d7                	call   *%edi
}
  80026f:	83 c4 10             	add    $0x10,%esp
  800272:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800275:	5b                   	pop    %ebx
  800276:	5e                   	pop    %esi
  800277:	5f                   	pop    %edi
  800278:	5d                   	pop    %ebp
  800279:	c3                   	ret    

0080027a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80027a:	f3 0f 1e fb          	endbr32 
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800284:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800288:	8b 10                	mov    (%eax),%edx
  80028a:	3b 50 04             	cmp    0x4(%eax),%edx
  80028d:	73 0a                	jae    800299 <sprintputch+0x1f>
		*b->buf++ = ch;
  80028f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800292:	89 08                	mov    %ecx,(%eax)
  800294:	8b 45 08             	mov    0x8(%ebp),%eax
  800297:	88 02                	mov    %al,(%edx)
}
  800299:	5d                   	pop    %ebp
  80029a:	c3                   	ret    

0080029b <printfmt>:
{
  80029b:	f3 0f 1e fb          	endbr32 
  80029f:	55                   	push   %ebp
  8002a0:	89 e5                	mov    %esp,%ebp
  8002a2:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002a5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002a8:	50                   	push   %eax
  8002a9:	ff 75 10             	pushl  0x10(%ebp)
  8002ac:	ff 75 0c             	pushl  0xc(%ebp)
  8002af:	ff 75 08             	pushl  0x8(%ebp)
  8002b2:	e8 05 00 00 00       	call   8002bc <vprintfmt>
}
  8002b7:	83 c4 10             	add    $0x10,%esp
  8002ba:	c9                   	leave  
  8002bb:	c3                   	ret    

008002bc <vprintfmt>:
{
  8002bc:	f3 0f 1e fb          	endbr32 
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	57                   	push   %edi
  8002c4:	56                   	push   %esi
  8002c5:	53                   	push   %ebx
  8002c6:	83 ec 3c             	sub    $0x3c,%esp
  8002c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8002cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002cf:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002d2:	e9 8e 03 00 00       	jmp    800665 <vprintfmt+0x3a9>
		padc = ' ';
  8002d7:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002db:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002e2:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002e9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002f0:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002f5:	8d 47 01             	lea    0x1(%edi),%eax
  8002f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002fb:	0f b6 17             	movzbl (%edi),%edx
  8002fe:	8d 42 dd             	lea    -0x23(%edx),%eax
  800301:	3c 55                	cmp    $0x55,%al
  800303:	0f 87 df 03 00 00    	ja     8006e8 <vprintfmt+0x42c>
  800309:	0f b6 c0             	movzbl %al,%eax
  80030c:	3e ff 24 85 00 15 80 	notrack jmp *0x801500(,%eax,4)
  800313:	00 
  800314:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800317:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80031b:	eb d8                	jmp    8002f5 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80031d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800320:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800324:	eb cf                	jmp    8002f5 <vprintfmt+0x39>
  800326:	0f b6 d2             	movzbl %dl,%edx
  800329:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80032c:	b8 00 00 00 00       	mov    $0x0,%eax
  800331:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800334:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800337:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80033b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80033e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800341:	83 f9 09             	cmp    $0x9,%ecx
  800344:	77 55                	ja     80039b <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800346:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800349:	eb e9                	jmp    800334 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80034b:	8b 45 14             	mov    0x14(%ebp),%eax
  80034e:	8b 00                	mov    (%eax),%eax
  800350:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800353:	8b 45 14             	mov    0x14(%ebp),%eax
  800356:	8d 40 04             	lea    0x4(%eax),%eax
  800359:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80035c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80035f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800363:	79 90                	jns    8002f5 <vprintfmt+0x39>
				width = precision, precision = -1;
  800365:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800368:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80036b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800372:	eb 81                	jmp    8002f5 <vprintfmt+0x39>
  800374:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800377:	85 c0                	test   %eax,%eax
  800379:	ba 00 00 00 00       	mov    $0x0,%edx
  80037e:	0f 49 d0             	cmovns %eax,%edx
  800381:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800384:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800387:	e9 69 ff ff ff       	jmp    8002f5 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80038f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800396:	e9 5a ff ff ff       	jmp    8002f5 <vprintfmt+0x39>
  80039b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80039e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a1:	eb bc                	jmp    80035f <vprintfmt+0xa3>
			lflag++;
  8003a3:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003a9:	e9 47 ff ff ff       	jmp    8002f5 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b1:	8d 78 04             	lea    0x4(%eax),%edi
  8003b4:	83 ec 08             	sub    $0x8,%esp
  8003b7:	53                   	push   %ebx
  8003b8:	ff 30                	pushl  (%eax)
  8003ba:	ff d6                	call   *%esi
			break;
  8003bc:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003bf:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003c2:	e9 9b 02 00 00       	jmp    800662 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  8003c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ca:	8d 78 04             	lea    0x4(%eax),%edi
  8003cd:	8b 00                	mov    (%eax),%eax
  8003cf:	99                   	cltd   
  8003d0:	31 d0                	xor    %edx,%eax
  8003d2:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003d4:	83 f8 08             	cmp    $0x8,%eax
  8003d7:	7f 23                	jg     8003fc <vprintfmt+0x140>
  8003d9:	8b 14 85 60 16 80 00 	mov    0x801660(,%eax,4),%edx
  8003e0:	85 d2                	test   %edx,%edx
  8003e2:	74 18                	je     8003fc <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003e4:	52                   	push   %edx
  8003e5:	68 61 14 80 00       	push   $0x801461
  8003ea:	53                   	push   %ebx
  8003eb:	56                   	push   %esi
  8003ec:	e8 aa fe ff ff       	call   80029b <printfmt>
  8003f1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003f4:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003f7:	e9 66 02 00 00       	jmp    800662 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  8003fc:	50                   	push   %eax
  8003fd:	68 58 14 80 00       	push   $0x801458
  800402:	53                   	push   %ebx
  800403:	56                   	push   %esi
  800404:	e8 92 fe ff ff       	call   80029b <printfmt>
  800409:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80040c:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80040f:	e9 4e 02 00 00       	jmp    800662 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	83 c0 04             	add    $0x4,%eax
  80041a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80041d:	8b 45 14             	mov    0x14(%ebp),%eax
  800420:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800422:	85 d2                	test   %edx,%edx
  800424:	b8 51 14 80 00       	mov    $0x801451,%eax
  800429:	0f 45 c2             	cmovne %edx,%eax
  80042c:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80042f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800433:	7e 06                	jle    80043b <vprintfmt+0x17f>
  800435:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800439:	75 0d                	jne    800448 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  80043b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80043e:	89 c7                	mov    %eax,%edi
  800440:	03 45 e0             	add    -0x20(%ebp),%eax
  800443:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800446:	eb 55                	jmp    80049d <vprintfmt+0x1e1>
  800448:	83 ec 08             	sub    $0x8,%esp
  80044b:	ff 75 d8             	pushl  -0x28(%ebp)
  80044e:	ff 75 cc             	pushl  -0x34(%ebp)
  800451:	e8 46 03 00 00       	call   80079c <strnlen>
  800456:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800459:	29 c2                	sub    %eax,%edx
  80045b:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80045e:	83 c4 10             	add    $0x10,%esp
  800461:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800463:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800467:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80046a:	85 ff                	test   %edi,%edi
  80046c:	7e 11                	jle    80047f <vprintfmt+0x1c3>
					putch(padc, putdat);
  80046e:	83 ec 08             	sub    $0x8,%esp
  800471:	53                   	push   %ebx
  800472:	ff 75 e0             	pushl  -0x20(%ebp)
  800475:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800477:	83 ef 01             	sub    $0x1,%edi
  80047a:	83 c4 10             	add    $0x10,%esp
  80047d:	eb eb                	jmp    80046a <vprintfmt+0x1ae>
  80047f:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800482:	85 d2                	test   %edx,%edx
  800484:	b8 00 00 00 00       	mov    $0x0,%eax
  800489:	0f 49 c2             	cmovns %edx,%eax
  80048c:	29 c2                	sub    %eax,%edx
  80048e:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800491:	eb a8                	jmp    80043b <vprintfmt+0x17f>
					putch(ch, putdat);
  800493:	83 ec 08             	sub    $0x8,%esp
  800496:	53                   	push   %ebx
  800497:	52                   	push   %edx
  800498:	ff d6                	call   *%esi
  80049a:	83 c4 10             	add    $0x10,%esp
  80049d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a0:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a2:	83 c7 01             	add    $0x1,%edi
  8004a5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004a9:	0f be d0             	movsbl %al,%edx
  8004ac:	85 d2                	test   %edx,%edx
  8004ae:	74 4b                	je     8004fb <vprintfmt+0x23f>
  8004b0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b4:	78 06                	js     8004bc <vprintfmt+0x200>
  8004b6:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004ba:	78 1e                	js     8004da <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004bc:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004c0:	74 d1                	je     800493 <vprintfmt+0x1d7>
  8004c2:	0f be c0             	movsbl %al,%eax
  8004c5:	83 e8 20             	sub    $0x20,%eax
  8004c8:	83 f8 5e             	cmp    $0x5e,%eax
  8004cb:	76 c6                	jbe    800493 <vprintfmt+0x1d7>
					putch('?', putdat);
  8004cd:	83 ec 08             	sub    $0x8,%esp
  8004d0:	53                   	push   %ebx
  8004d1:	6a 3f                	push   $0x3f
  8004d3:	ff d6                	call   *%esi
  8004d5:	83 c4 10             	add    $0x10,%esp
  8004d8:	eb c3                	jmp    80049d <vprintfmt+0x1e1>
  8004da:	89 cf                	mov    %ecx,%edi
  8004dc:	eb 0e                	jmp    8004ec <vprintfmt+0x230>
				putch(' ', putdat);
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	53                   	push   %ebx
  8004e2:	6a 20                	push   $0x20
  8004e4:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004e6:	83 ef 01             	sub    $0x1,%edi
  8004e9:	83 c4 10             	add    $0x10,%esp
  8004ec:	85 ff                	test   %edi,%edi
  8004ee:	7f ee                	jg     8004de <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004f0:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004f3:	89 45 14             	mov    %eax,0x14(%ebp)
  8004f6:	e9 67 01 00 00       	jmp    800662 <vprintfmt+0x3a6>
  8004fb:	89 cf                	mov    %ecx,%edi
  8004fd:	eb ed                	jmp    8004ec <vprintfmt+0x230>
	if (lflag >= 2)
  8004ff:	83 f9 01             	cmp    $0x1,%ecx
  800502:	7f 1b                	jg     80051f <vprintfmt+0x263>
	else if (lflag)
  800504:	85 c9                	test   %ecx,%ecx
  800506:	74 63                	je     80056b <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800508:	8b 45 14             	mov    0x14(%ebp),%eax
  80050b:	8b 00                	mov    (%eax),%eax
  80050d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800510:	99                   	cltd   
  800511:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800514:	8b 45 14             	mov    0x14(%ebp),%eax
  800517:	8d 40 04             	lea    0x4(%eax),%eax
  80051a:	89 45 14             	mov    %eax,0x14(%ebp)
  80051d:	eb 17                	jmp    800536 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80051f:	8b 45 14             	mov    0x14(%ebp),%eax
  800522:	8b 50 04             	mov    0x4(%eax),%edx
  800525:	8b 00                	mov    (%eax),%eax
  800527:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80052a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80052d:	8b 45 14             	mov    0x14(%ebp),%eax
  800530:	8d 40 08             	lea    0x8(%eax),%eax
  800533:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800536:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800539:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80053c:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800541:	85 c9                	test   %ecx,%ecx
  800543:	0f 89 ff 00 00 00    	jns    800648 <vprintfmt+0x38c>
				putch('-', putdat);
  800549:	83 ec 08             	sub    $0x8,%esp
  80054c:	53                   	push   %ebx
  80054d:	6a 2d                	push   $0x2d
  80054f:	ff d6                	call   *%esi
				num = -(long long) num;
  800551:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800554:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800557:	f7 da                	neg    %edx
  800559:	83 d1 00             	adc    $0x0,%ecx
  80055c:	f7 d9                	neg    %ecx
  80055e:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800561:	b8 0a 00 00 00       	mov    $0xa,%eax
  800566:	e9 dd 00 00 00       	jmp    800648 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  80056b:	8b 45 14             	mov    0x14(%ebp),%eax
  80056e:	8b 00                	mov    (%eax),%eax
  800570:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800573:	99                   	cltd   
  800574:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8d 40 04             	lea    0x4(%eax),%eax
  80057d:	89 45 14             	mov    %eax,0x14(%ebp)
  800580:	eb b4                	jmp    800536 <vprintfmt+0x27a>
	if (lflag >= 2)
  800582:	83 f9 01             	cmp    $0x1,%ecx
  800585:	7f 1e                	jg     8005a5 <vprintfmt+0x2e9>
	else if (lflag)
  800587:	85 c9                	test   %ecx,%ecx
  800589:	74 32                	je     8005bd <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  80058b:	8b 45 14             	mov    0x14(%ebp),%eax
  80058e:	8b 10                	mov    (%eax),%edx
  800590:	b9 00 00 00 00       	mov    $0x0,%ecx
  800595:	8d 40 04             	lea    0x4(%eax),%eax
  800598:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80059b:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005a0:	e9 a3 00 00 00       	jmp    800648 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8005a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a8:	8b 10                	mov    (%eax),%edx
  8005aa:	8b 48 04             	mov    0x4(%eax),%ecx
  8005ad:	8d 40 08             	lea    0x8(%eax),%eax
  8005b0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b3:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005b8:	e9 8b 00 00 00       	jmp    800648 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8b 10                	mov    (%eax),%edx
  8005c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c7:	8d 40 04             	lea    0x4(%eax),%eax
  8005ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005cd:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005d2:	eb 74                	jmp    800648 <vprintfmt+0x38c>
	if (lflag >= 2)
  8005d4:	83 f9 01             	cmp    $0x1,%ecx
  8005d7:	7f 1b                	jg     8005f4 <vprintfmt+0x338>
	else if (lflag)
  8005d9:	85 c9                	test   %ecx,%ecx
  8005db:	74 2c                	je     800609 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8b 10                	mov    (%eax),%edx
  8005e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e7:	8d 40 04             	lea    0x4(%eax),%eax
  8005ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005ed:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  8005f2:	eb 54                	jmp    800648 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8b 10                	mov    (%eax),%edx
  8005f9:	8b 48 04             	mov    0x4(%eax),%ecx
  8005fc:	8d 40 08             	lea    0x8(%eax),%eax
  8005ff:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800602:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800607:	eb 3f                	jmp    800648 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800609:	8b 45 14             	mov    0x14(%ebp),%eax
  80060c:	8b 10                	mov    (%eax),%edx
  80060e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800613:	8d 40 04             	lea    0x4(%eax),%eax
  800616:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800619:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  80061e:	eb 28                	jmp    800648 <vprintfmt+0x38c>
			putch('0', putdat);
  800620:	83 ec 08             	sub    $0x8,%esp
  800623:	53                   	push   %ebx
  800624:	6a 30                	push   $0x30
  800626:	ff d6                	call   *%esi
			putch('x', putdat);
  800628:	83 c4 08             	add    $0x8,%esp
  80062b:	53                   	push   %ebx
  80062c:	6a 78                	push   $0x78
  80062e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800630:	8b 45 14             	mov    0x14(%ebp),%eax
  800633:	8b 10                	mov    (%eax),%edx
  800635:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80063a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80063d:	8d 40 04             	lea    0x4(%eax),%eax
  800640:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800643:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800648:	83 ec 0c             	sub    $0xc,%esp
  80064b:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80064f:	57                   	push   %edi
  800650:	ff 75 e0             	pushl  -0x20(%ebp)
  800653:	50                   	push   %eax
  800654:	51                   	push   %ecx
  800655:	52                   	push   %edx
  800656:	89 da                	mov    %ebx,%edx
  800658:	89 f0                	mov    %esi,%eax
  80065a:	e8 72 fb ff ff       	call   8001d1 <printnum>
			break;
  80065f:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800662:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {	
  800665:	83 c7 01             	add    $0x1,%edi
  800668:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80066c:	83 f8 25             	cmp    $0x25,%eax
  80066f:	0f 84 62 fc ff ff    	je     8002d7 <vprintfmt+0x1b>
			if (ch == '\0')										
  800675:	85 c0                	test   %eax,%eax
  800677:	0f 84 8b 00 00 00    	je     800708 <vprintfmt+0x44c>
			putch(ch, putdat);
  80067d:	83 ec 08             	sub    $0x8,%esp
  800680:	53                   	push   %ebx
  800681:	50                   	push   %eax
  800682:	ff d6                	call   *%esi
  800684:	83 c4 10             	add    $0x10,%esp
  800687:	eb dc                	jmp    800665 <vprintfmt+0x3a9>
	if (lflag >= 2)
  800689:	83 f9 01             	cmp    $0x1,%ecx
  80068c:	7f 1b                	jg     8006a9 <vprintfmt+0x3ed>
	else if (lflag)
  80068e:	85 c9                	test   %ecx,%ecx
  800690:	74 2c                	je     8006be <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8b 10                	mov    (%eax),%edx
  800697:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069c:	8d 40 04             	lea    0x4(%eax),%eax
  80069f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a2:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006a7:	eb 9f                	jmp    800648 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8006a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ac:	8b 10                	mov    (%eax),%edx
  8006ae:	8b 48 04             	mov    0x4(%eax),%ecx
  8006b1:	8d 40 08             	lea    0x8(%eax),%eax
  8006b4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b7:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006bc:	eb 8a                	jmp    800648 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8006be:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c1:	8b 10                	mov    (%eax),%edx
  8006c3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006c8:	8d 40 04             	lea    0x4(%eax),%eax
  8006cb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ce:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006d3:	e9 70 ff ff ff       	jmp    800648 <vprintfmt+0x38c>
			putch(ch, putdat);
  8006d8:	83 ec 08             	sub    $0x8,%esp
  8006db:	53                   	push   %ebx
  8006dc:	6a 25                	push   $0x25
  8006de:	ff d6                	call   *%esi
			break;
  8006e0:	83 c4 10             	add    $0x10,%esp
  8006e3:	e9 7a ff ff ff       	jmp    800662 <vprintfmt+0x3a6>
			putch('%', putdat);
  8006e8:	83 ec 08             	sub    $0x8,%esp
  8006eb:	53                   	push   %ebx
  8006ec:	6a 25                	push   $0x25
  8006ee:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f0:	83 c4 10             	add    $0x10,%esp
  8006f3:	89 f8                	mov    %edi,%eax
  8006f5:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006f9:	74 05                	je     800700 <vprintfmt+0x444>
  8006fb:	83 e8 01             	sub    $0x1,%eax
  8006fe:	eb f5                	jmp    8006f5 <vprintfmt+0x439>
  800700:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800703:	e9 5a ff ff ff       	jmp    800662 <vprintfmt+0x3a6>
}
  800708:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070b:	5b                   	pop    %ebx
  80070c:	5e                   	pop    %esi
  80070d:	5f                   	pop    %edi
  80070e:	5d                   	pop    %ebp
  80070f:	c3                   	ret    

00800710 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800710:	f3 0f 1e fb          	endbr32 
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	83 ec 18             	sub    $0x18,%esp
  80071a:	8b 45 08             	mov    0x8(%ebp),%eax
  80071d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800720:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800723:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800727:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800731:	85 c0                	test   %eax,%eax
  800733:	74 26                	je     80075b <vsnprintf+0x4b>
  800735:	85 d2                	test   %edx,%edx
  800737:	7e 22                	jle    80075b <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800739:	ff 75 14             	pushl  0x14(%ebp)
  80073c:	ff 75 10             	pushl  0x10(%ebp)
  80073f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800742:	50                   	push   %eax
  800743:	68 7a 02 80 00       	push   $0x80027a
  800748:	e8 6f fb ff ff       	call   8002bc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800750:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800753:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800756:	83 c4 10             	add    $0x10,%esp
}
  800759:	c9                   	leave  
  80075a:	c3                   	ret    
		return -E_INVAL;
  80075b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800760:	eb f7                	jmp    800759 <vsnprintf+0x49>

00800762 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800762:	f3 0f 1e fb          	endbr32 
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076f:	50                   	push   %eax
  800770:	ff 75 10             	pushl  0x10(%ebp)
  800773:	ff 75 0c             	pushl  0xc(%ebp)
  800776:	ff 75 08             	pushl  0x8(%ebp)
  800779:	e8 92 ff ff ff       	call   800710 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077e:	c9                   	leave  
  80077f:	c3                   	ret    

00800780 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800780:	f3 0f 1e fb          	endbr32 
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80078a:	b8 00 00 00 00       	mov    $0x0,%eax
  80078f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800793:	74 05                	je     80079a <strlen+0x1a>
		n++;
  800795:	83 c0 01             	add    $0x1,%eax
  800798:	eb f5                	jmp    80078f <strlen+0xf>
	return n;
}
  80079a:	5d                   	pop    %ebp
  80079b:	c3                   	ret    

0080079c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80079c:	f3 0f 1e fb          	endbr32 
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007a6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ae:	39 d0                	cmp    %edx,%eax
  8007b0:	74 0d                	je     8007bf <strnlen+0x23>
  8007b2:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007b6:	74 05                	je     8007bd <strnlen+0x21>
		n++;
  8007b8:	83 c0 01             	add    $0x1,%eax
  8007bb:	eb f1                	jmp    8007ae <strnlen+0x12>
  8007bd:	89 c2                	mov    %eax,%edx
	return n;
}
  8007bf:	89 d0                	mov    %edx,%eax
  8007c1:	5d                   	pop    %ebp
  8007c2:	c3                   	ret    

008007c3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007c3:	f3 0f 1e fb          	endbr32 
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	53                   	push   %ebx
  8007cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d6:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007da:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007dd:	83 c0 01             	add    $0x1,%eax
  8007e0:	84 d2                	test   %dl,%dl
  8007e2:	75 f2                	jne    8007d6 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007e4:	89 c8                	mov    %ecx,%eax
  8007e6:	5b                   	pop    %ebx
  8007e7:	5d                   	pop    %ebp
  8007e8:	c3                   	ret    

008007e9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007e9:	f3 0f 1e fb          	endbr32 
  8007ed:	55                   	push   %ebp
  8007ee:	89 e5                	mov    %esp,%ebp
  8007f0:	53                   	push   %ebx
  8007f1:	83 ec 10             	sub    $0x10,%esp
  8007f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007f7:	53                   	push   %ebx
  8007f8:	e8 83 ff ff ff       	call   800780 <strlen>
  8007fd:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800800:	ff 75 0c             	pushl  0xc(%ebp)
  800803:	01 d8                	add    %ebx,%eax
  800805:	50                   	push   %eax
  800806:	e8 b8 ff ff ff       	call   8007c3 <strcpy>
	return dst;
}
  80080b:	89 d8                	mov    %ebx,%eax
  80080d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800810:	c9                   	leave  
  800811:	c3                   	ret    

00800812 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800812:	f3 0f 1e fb          	endbr32 
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	56                   	push   %esi
  80081a:	53                   	push   %ebx
  80081b:	8b 75 08             	mov    0x8(%ebp),%esi
  80081e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800821:	89 f3                	mov    %esi,%ebx
  800823:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800826:	89 f0                	mov    %esi,%eax
  800828:	39 d8                	cmp    %ebx,%eax
  80082a:	74 11                	je     80083d <strncpy+0x2b>
		*dst++ = *src;
  80082c:	83 c0 01             	add    $0x1,%eax
  80082f:	0f b6 0a             	movzbl (%edx),%ecx
  800832:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800835:	80 f9 01             	cmp    $0x1,%cl
  800838:	83 da ff             	sbb    $0xffffffff,%edx
  80083b:	eb eb                	jmp    800828 <strncpy+0x16>
	}
	return ret;
}
  80083d:	89 f0                	mov    %esi,%eax
  80083f:	5b                   	pop    %ebx
  800840:	5e                   	pop    %esi
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800843:	f3 0f 1e fb          	endbr32 
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	56                   	push   %esi
  80084b:	53                   	push   %ebx
  80084c:	8b 75 08             	mov    0x8(%ebp),%esi
  80084f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800852:	8b 55 10             	mov    0x10(%ebp),%edx
  800855:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800857:	85 d2                	test   %edx,%edx
  800859:	74 21                	je     80087c <strlcpy+0x39>
  80085b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80085f:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800861:	39 c2                	cmp    %eax,%edx
  800863:	74 14                	je     800879 <strlcpy+0x36>
  800865:	0f b6 19             	movzbl (%ecx),%ebx
  800868:	84 db                	test   %bl,%bl
  80086a:	74 0b                	je     800877 <strlcpy+0x34>
			*dst++ = *src++;
  80086c:	83 c1 01             	add    $0x1,%ecx
  80086f:	83 c2 01             	add    $0x1,%edx
  800872:	88 5a ff             	mov    %bl,-0x1(%edx)
  800875:	eb ea                	jmp    800861 <strlcpy+0x1e>
  800877:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800879:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80087c:	29 f0                	sub    %esi,%eax
}
  80087e:	5b                   	pop    %ebx
  80087f:	5e                   	pop    %esi
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800882:	f3 0f 1e fb          	endbr32 
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80088f:	0f b6 01             	movzbl (%ecx),%eax
  800892:	84 c0                	test   %al,%al
  800894:	74 0c                	je     8008a2 <strcmp+0x20>
  800896:	3a 02                	cmp    (%edx),%al
  800898:	75 08                	jne    8008a2 <strcmp+0x20>
		p++, q++;
  80089a:	83 c1 01             	add    $0x1,%ecx
  80089d:	83 c2 01             	add    $0x1,%edx
  8008a0:	eb ed                	jmp    80088f <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a2:	0f b6 c0             	movzbl %al,%eax
  8008a5:	0f b6 12             	movzbl (%edx),%edx
  8008a8:	29 d0                	sub    %edx,%eax
}
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ac:	f3 0f 1e fb          	endbr32 
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	53                   	push   %ebx
  8008b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ba:	89 c3                	mov    %eax,%ebx
  8008bc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008bf:	eb 06                	jmp    8008c7 <strncmp+0x1b>
		n--, p++, q++;
  8008c1:	83 c0 01             	add    $0x1,%eax
  8008c4:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008c7:	39 d8                	cmp    %ebx,%eax
  8008c9:	74 16                	je     8008e1 <strncmp+0x35>
  8008cb:	0f b6 08             	movzbl (%eax),%ecx
  8008ce:	84 c9                	test   %cl,%cl
  8008d0:	74 04                	je     8008d6 <strncmp+0x2a>
  8008d2:	3a 0a                	cmp    (%edx),%cl
  8008d4:	74 eb                	je     8008c1 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d6:	0f b6 00             	movzbl (%eax),%eax
  8008d9:	0f b6 12             	movzbl (%edx),%edx
  8008dc:	29 d0                	sub    %edx,%eax
}
  8008de:	5b                   	pop    %ebx
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    
		return 0;
  8008e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e6:	eb f6                	jmp    8008de <strncmp+0x32>

008008e8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e8:	f3 0f 1e fb          	endbr32 
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f6:	0f b6 10             	movzbl (%eax),%edx
  8008f9:	84 d2                	test   %dl,%dl
  8008fb:	74 09                	je     800906 <strchr+0x1e>
		if (*s == c)
  8008fd:	38 ca                	cmp    %cl,%dl
  8008ff:	74 0a                	je     80090b <strchr+0x23>
	for (; *s; s++)
  800901:	83 c0 01             	add    $0x1,%eax
  800904:	eb f0                	jmp    8008f6 <strchr+0xe>
			return (char *) s;
	return 0;
  800906:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    

0080090d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80090d:	f3 0f 1e fb          	endbr32 
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	8b 45 08             	mov    0x8(%ebp),%eax
  800917:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80091b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80091e:	38 ca                	cmp    %cl,%dl
  800920:	74 09                	je     80092b <strfind+0x1e>
  800922:	84 d2                	test   %dl,%dl
  800924:	74 05                	je     80092b <strfind+0x1e>
	for (; *s; s++)
  800926:	83 c0 01             	add    $0x1,%eax
  800929:	eb f0                	jmp    80091b <strfind+0xe>
			break;
	return (char *) s;
}
  80092b:	5d                   	pop    %ebp
  80092c:	c3                   	ret    

0080092d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80092d:	f3 0f 1e fb          	endbr32 
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	57                   	push   %edi
  800935:	56                   	push   %esi
  800936:	53                   	push   %ebx
  800937:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80093d:	85 c9                	test   %ecx,%ecx
  80093f:	74 31                	je     800972 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800941:	89 f8                	mov    %edi,%eax
  800943:	09 c8                	or     %ecx,%eax
  800945:	a8 03                	test   $0x3,%al
  800947:	75 23                	jne    80096c <memset+0x3f>
		c &= 0xFF;
  800949:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80094d:	89 d3                	mov    %edx,%ebx
  80094f:	c1 e3 08             	shl    $0x8,%ebx
  800952:	89 d0                	mov    %edx,%eax
  800954:	c1 e0 18             	shl    $0x18,%eax
  800957:	89 d6                	mov    %edx,%esi
  800959:	c1 e6 10             	shl    $0x10,%esi
  80095c:	09 f0                	or     %esi,%eax
  80095e:	09 c2                	or     %eax,%edx
  800960:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800962:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800965:	89 d0                	mov    %edx,%eax
  800967:	fc                   	cld    
  800968:	f3 ab                	rep stos %eax,%es:(%edi)
  80096a:	eb 06                	jmp    800972 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096f:	fc                   	cld    
  800970:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800972:	89 f8                	mov    %edi,%eax
  800974:	5b                   	pop    %ebx
  800975:	5e                   	pop    %esi
  800976:	5f                   	pop    %edi
  800977:	5d                   	pop    %ebp
  800978:	c3                   	ret    

00800979 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800979:	f3 0f 1e fb          	endbr32 
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	57                   	push   %edi
  800981:	56                   	push   %esi
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	8b 75 0c             	mov    0xc(%ebp),%esi
  800988:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80098b:	39 c6                	cmp    %eax,%esi
  80098d:	73 32                	jae    8009c1 <memmove+0x48>
  80098f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800992:	39 c2                	cmp    %eax,%edx
  800994:	76 2b                	jbe    8009c1 <memmove+0x48>
		s += n;
		d += n;
  800996:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800999:	89 fe                	mov    %edi,%esi
  80099b:	09 ce                	or     %ecx,%esi
  80099d:	09 d6                	or     %edx,%esi
  80099f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a5:	75 0e                	jne    8009b5 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009a7:	83 ef 04             	sub    $0x4,%edi
  8009aa:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009ad:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009b0:	fd                   	std    
  8009b1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b3:	eb 09                	jmp    8009be <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009b5:	83 ef 01             	sub    $0x1,%edi
  8009b8:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009bb:	fd                   	std    
  8009bc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009be:	fc                   	cld    
  8009bf:	eb 1a                	jmp    8009db <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c1:	89 c2                	mov    %eax,%edx
  8009c3:	09 ca                	or     %ecx,%edx
  8009c5:	09 f2                	or     %esi,%edx
  8009c7:	f6 c2 03             	test   $0x3,%dl
  8009ca:	75 0a                	jne    8009d6 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009cc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009cf:	89 c7                	mov    %eax,%edi
  8009d1:	fc                   	cld    
  8009d2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d4:	eb 05                	jmp    8009db <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009d6:	89 c7                	mov    %eax,%edi
  8009d8:	fc                   	cld    
  8009d9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009db:	5e                   	pop    %esi
  8009dc:	5f                   	pop    %edi
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009df:	f3 0f 1e fb          	endbr32 
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009e9:	ff 75 10             	pushl  0x10(%ebp)
  8009ec:	ff 75 0c             	pushl  0xc(%ebp)
  8009ef:	ff 75 08             	pushl  0x8(%ebp)
  8009f2:	e8 82 ff ff ff       	call   800979 <memmove>
}
  8009f7:	c9                   	leave  
  8009f8:	c3                   	ret    

008009f9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f9:	f3 0f 1e fb          	endbr32 
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	56                   	push   %esi
  800a01:	53                   	push   %ebx
  800a02:	8b 45 08             	mov    0x8(%ebp),%eax
  800a05:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a08:	89 c6                	mov    %eax,%esi
  800a0a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0d:	39 f0                	cmp    %esi,%eax
  800a0f:	74 1c                	je     800a2d <memcmp+0x34>
		if (*s1 != *s2)
  800a11:	0f b6 08             	movzbl (%eax),%ecx
  800a14:	0f b6 1a             	movzbl (%edx),%ebx
  800a17:	38 d9                	cmp    %bl,%cl
  800a19:	75 08                	jne    800a23 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a1b:	83 c0 01             	add    $0x1,%eax
  800a1e:	83 c2 01             	add    $0x1,%edx
  800a21:	eb ea                	jmp    800a0d <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a23:	0f b6 c1             	movzbl %cl,%eax
  800a26:	0f b6 db             	movzbl %bl,%ebx
  800a29:	29 d8                	sub    %ebx,%eax
  800a2b:	eb 05                	jmp    800a32 <memcmp+0x39>
	}

	return 0;
  800a2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a32:	5b                   	pop    %ebx
  800a33:	5e                   	pop    %esi
  800a34:	5d                   	pop    %ebp
  800a35:	c3                   	ret    

00800a36 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a36:	f3 0f 1e fb          	endbr32 
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a43:	89 c2                	mov    %eax,%edx
  800a45:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a48:	39 d0                	cmp    %edx,%eax
  800a4a:	73 09                	jae    800a55 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4c:	38 08                	cmp    %cl,(%eax)
  800a4e:	74 05                	je     800a55 <memfind+0x1f>
	for (; s < ends; s++)
  800a50:	83 c0 01             	add    $0x1,%eax
  800a53:	eb f3                	jmp    800a48 <memfind+0x12>
			break;
	return (void *) s;
}
  800a55:	5d                   	pop    %ebp
  800a56:	c3                   	ret    

00800a57 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a57:	f3 0f 1e fb          	endbr32 
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	57                   	push   %edi
  800a5f:	56                   	push   %esi
  800a60:	53                   	push   %ebx
  800a61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a64:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a67:	eb 03                	jmp    800a6c <strtol+0x15>
		s++;
  800a69:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a6c:	0f b6 01             	movzbl (%ecx),%eax
  800a6f:	3c 20                	cmp    $0x20,%al
  800a71:	74 f6                	je     800a69 <strtol+0x12>
  800a73:	3c 09                	cmp    $0x9,%al
  800a75:	74 f2                	je     800a69 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a77:	3c 2b                	cmp    $0x2b,%al
  800a79:	74 2a                	je     800aa5 <strtol+0x4e>
	int neg = 0;
  800a7b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a80:	3c 2d                	cmp    $0x2d,%al
  800a82:	74 2b                	je     800aaf <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a84:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a8a:	75 0f                	jne    800a9b <strtol+0x44>
  800a8c:	80 39 30             	cmpb   $0x30,(%ecx)
  800a8f:	74 28                	je     800ab9 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a91:	85 db                	test   %ebx,%ebx
  800a93:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a98:	0f 44 d8             	cmove  %eax,%ebx
  800a9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa0:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aa3:	eb 46                	jmp    800aeb <strtol+0x94>
		s++;
  800aa5:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800aa8:	bf 00 00 00 00       	mov    $0x0,%edi
  800aad:	eb d5                	jmp    800a84 <strtol+0x2d>
		s++, neg = 1;
  800aaf:	83 c1 01             	add    $0x1,%ecx
  800ab2:	bf 01 00 00 00       	mov    $0x1,%edi
  800ab7:	eb cb                	jmp    800a84 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800abd:	74 0e                	je     800acd <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800abf:	85 db                	test   %ebx,%ebx
  800ac1:	75 d8                	jne    800a9b <strtol+0x44>
		s++, base = 8;
  800ac3:	83 c1 01             	add    $0x1,%ecx
  800ac6:	bb 08 00 00 00       	mov    $0x8,%ebx
  800acb:	eb ce                	jmp    800a9b <strtol+0x44>
		s += 2, base = 16;
  800acd:	83 c1 02             	add    $0x2,%ecx
  800ad0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ad5:	eb c4                	jmp    800a9b <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ad7:	0f be d2             	movsbl %dl,%edx
  800ada:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800add:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ae0:	7d 3a                	jge    800b1c <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ae2:	83 c1 01             	add    $0x1,%ecx
  800ae5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ae9:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800aeb:	0f b6 11             	movzbl (%ecx),%edx
  800aee:	8d 72 d0             	lea    -0x30(%edx),%esi
  800af1:	89 f3                	mov    %esi,%ebx
  800af3:	80 fb 09             	cmp    $0x9,%bl
  800af6:	76 df                	jbe    800ad7 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800af8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800afb:	89 f3                	mov    %esi,%ebx
  800afd:	80 fb 19             	cmp    $0x19,%bl
  800b00:	77 08                	ja     800b0a <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b02:	0f be d2             	movsbl %dl,%edx
  800b05:	83 ea 57             	sub    $0x57,%edx
  800b08:	eb d3                	jmp    800add <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b0a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b0d:	89 f3                	mov    %esi,%ebx
  800b0f:	80 fb 19             	cmp    $0x19,%bl
  800b12:	77 08                	ja     800b1c <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b14:	0f be d2             	movsbl %dl,%edx
  800b17:	83 ea 37             	sub    $0x37,%edx
  800b1a:	eb c1                	jmp    800add <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b1c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b20:	74 05                	je     800b27 <strtol+0xd0>
		*endptr = (char *) s;
  800b22:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b25:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b27:	89 c2                	mov    %eax,%edx
  800b29:	f7 da                	neg    %edx
  800b2b:	85 ff                	test   %edi,%edi
  800b2d:	0f 45 c2             	cmovne %edx,%eax
}
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5f                   	pop    %edi
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b35:	f3 0f 1e fb          	endbr32 
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800b3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b44:	8b 55 08             	mov    0x8(%ebp),%edx
  800b47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4a:	89 c3                	mov    %eax,%ebx
  800b4c:	89 c7                	mov    %eax,%edi
  800b4e:	89 c6                	mov    %eax,%esi
  800b50:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b57:	f3 0f 1e fb          	endbr32 
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	57                   	push   %edi
  800b5f:	56                   	push   %esi
  800b60:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800b61:	ba 00 00 00 00       	mov    $0x0,%edx
  800b66:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6b:	89 d1                	mov    %edx,%ecx
  800b6d:	89 d3                	mov    %edx,%ebx
  800b6f:	89 d7                	mov    %edx,%edi
  800b71:	89 d6                	mov    %edx,%esi
  800b73:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b75:	5b                   	pop    %ebx
  800b76:	5e                   	pop    %esi
  800b77:	5f                   	pop    %edi
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b7a:	f3 0f 1e fb          	endbr32 
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	57                   	push   %edi
  800b82:	56                   	push   %esi
  800b83:	53                   	push   %ebx
  800b84:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800b87:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8f:	b8 03 00 00 00       	mov    $0x3,%eax
  800b94:	89 cb                	mov    %ecx,%ebx
  800b96:	89 cf                	mov    %ecx,%edi
  800b98:	89 ce                	mov    %ecx,%esi
  800b9a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b9c:	85 c0                	test   %eax,%eax
  800b9e:	7f 08                	jg     800ba8 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ba0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba3:	5b                   	pop    %ebx
  800ba4:	5e                   	pop    %esi
  800ba5:	5f                   	pop    %edi
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ba8:	83 ec 0c             	sub    $0xc,%esp
  800bab:	50                   	push   %eax
  800bac:	6a 03                	push   $0x3
  800bae:	68 84 16 80 00       	push   $0x801684
  800bb3:	6a 23                	push   $0x23
  800bb5:	68 a1 16 80 00       	push   $0x8016a1
  800bba:	e8 b2 04 00 00       	call   801071 <_panic>

00800bbf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bbf:	f3 0f 1e fb          	endbr32 
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	57                   	push   %edi
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800bc9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bce:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd3:	89 d1                	mov    %edx,%ecx
  800bd5:	89 d3                	mov    %edx,%ebx
  800bd7:	89 d7                	mov    %edx,%edi
  800bd9:	89 d6                	mov    %edx,%esi
  800bdb:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bdd:	5b                   	pop    %ebx
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <sys_yield>:

void
sys_yield(void)
{
  800be2:	f3 0f 1e fb          	endbr32 
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	57                   	push   %edi
  800bea:	56                   	push   %esi
  800beb:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800bec:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bf6:	89 d1                	mov    %edx,%ecx
  800bf8:	89 d3                	mov    %edx,%ebx
  800bfa:	89 d7                	mov    %edx,%edi
  800bfc:	89 d6                	mov    %edx,%esi
  800bfe:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c05:	f3 0f 1e fb          	endbr32 
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	57                   	push   %edi
  800c0d:	56                   	push   %esi
  800c0e:	53                   	push   %ebx
  800c0f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c12:	be 00 00 00 00       	mov    $0x0,%esi
  800c17:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1d:	b8 04 00 00 00       	mov    $0x4,%eax
  800c22:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c25:	89 f7                	mov    %esi,%edi
  800c27:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c29:	85 c0                	test   %eax,%eax
  800c2b:	7f 08                	jg     800c35 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c35:	83 ec 0c             	sub    $0xc,%esp
  800c38:	50                   	push   %eax
  800c39:	6a 04                	push   $0x4
  800c3b:	68 84 16 80 00       	push   $0x801684
  800c40:	6a 23                	push   $0x23
  800c42:	68 a1 16 80 00       	push   $0x8016a1
  800c47:	e8 25 04 00 00       	call   801071 <_panic>

00800c4c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c4c:	f3 0f 1e fb          	endbr32 
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	57                   	push   %edi
  800c54:	56                   	push   %esi
  800c55:	53                   	push   %ebx
  800c56:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c59:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5f:	b8 05 00 00 00       	mov    $0x5,%eax
  800c64:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c67:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c6a:	8b 75 18             	mov    0x18(%ebp),%esi
  800c6d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c6f:	85 c0                	test   %eax,%eax
  800c71:	7f 08                	jg     800c7b <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c76:	5b                   	pop    %ebx
  800c77:	5e                   	pop    %esi
  800c78:	5f                   	pop    %edi
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7b:	83 ec 0c             	sub    $0xc,%esp
  800c7e:	50                   	push   %eax
  800c7f:	6a 05                	push   $0x5
  800c81:	68 84 16 80 00       	push   $0x801684
  800c86:	6a 23                	push   $0x23
  800c88:	68 a1 16 80 00       	push   $0x8016a1
  800c8d:	e8 df 03 00 00       	call   801071 <_panic>

00800c92 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c92:	f3 0f 1e fb          	endbr32 
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	57                   	push   %edi
  800c9a:	56                   	push   %esi
  800c9b:	53                   	push   %ebx
  800c9c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caa:	b8 06 00 00 00       	mov    $0x6,%eax
  800caf:	89 df                	mov    %ebx,%edi
  800cb1:	89 de                	mov    %ebx,%esi
  800cb3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb5:	85 c0                	test   %eax,%eax
  800cb7:	7f 08                	jg     800cc1 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc1:	83 ec 0c             	sub    $0xc,%esp
  800cc4:	50                   	push   %eax
  800cc5:	6a 06                	push   $0x6
  800cc7:	68 84 16 80 00       	push   $0x801684
  800ccc:	6a 23                	push   $0x23
  800cce:	68 a1 16 80 00       	push   $0x8016a1
  800cd3:	e8 99 03 00 00       	call   801071 <_panic>

00800cd8 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cd8:	f3 0f 1e fb          	endbr32 
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	57                   	push   %edi
  800ce0:	56                   	push   %esi
  800ce1:	53                   	push   %ebx
  800ce2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800ce5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf0:	b8 08 00 00 00       	mov    $0x8,%eax
  800cf5:	89 df                	mov    %ebx,%edi
  800cf7:	89 de                	mov    %ebx,%esi
  800cf9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cfb:	85 c0                	test   %eax,%eax
  800cfd:	7f 08                	jg     800d07 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d07:	83 ec 0c             	sub    $0xc,%esp
  800d0a:	50                   	push   %eax
  800d0b:	6a 08                	push   $0x8
  800d0d:	68 84 16 80 00       	push   $0x801684
  800d12:	6a 23                	push   $0x23
  800d14:	68 a1 16 80 00       	push   $0x8016a1
  800d19:	e8 53 03 00 00       	call   801071 <_panic>

00800d1e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d1e:	f3 0f 1e fb          	endbr32 
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	57                   	push   %edi
  800d26:	56                   	push   %esi
  800d27:	53                   	push   %ebx
  800d28:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d2b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d30:	8b 55 08             	mov    0x8(%ebp),%edx
  800d33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d36:	b8 09 00 00 00       	mov    $0x9,%eax
  800d3b:	89 df                	mov    %ebx,%edi
  800d3d:	89 de                	mov    %ebx,%esi
  800d3f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d41:	85 c0                	test   %eax,%eax
  800d43:	7f 08                	jg     800d4d <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4d:	83 ec 0c             	sub    $0xc,%esp
  800d50:	50                   	push   %eax
  800d51:	6a 09                	push   $0x9
  800d53:	68 84 16 80 00       	push   $0x801684
  800d58:	6a 23                	push   $0x23
  800d5a:	68 a1 16 80 00       	push   $0x8016a1
  800d5f:	e8 0d 03 00 00       	call   801071 <_panic>

00800d64 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d64:	f3 0f 1e fb          	endbr32 
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	57                   	push   %edi
  800d6c:	56                   	push   %esi
  800d6d:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d74:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d79:	be 00 00 00 00       	mov    $0x0,%esi
  800d7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d81:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d84:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d86:	5b                   	pop    %ebx
  800d87:	5e                   	pop    %esi
  800d88:	5f                   	pop    %edi
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    

00800d8b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d8b:	f3 0f 1e fb          	endbr32 
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	57                   	push   %edi
  800d93:	56                   	push   %esi
  800d94:	53                   	push   %ebx
  800d95:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d98:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800da0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da5:	89 cb                	mov    %ecx,%ebx
  800da7:	89 cf                	mov    %ecx,%edi
  800da9:	89 ce                	mov    %ecx,%esi
  800dab:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dad:	85 c0                	test   %eax,%eax
  800daf:	7f 08                	jg     800db9 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800db1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db4:	5b                   	pop    %ebx
  800db5:	5e                   	pop    %esi
  800db6:	5f                   	pop    %edi
  800db7:	5d                   	pop    %ebp
  800db8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800db9:	83 ec 0c             	sub    $0xc,%esp
  800dbc:	50                   	push   %eax
  800dbd:	6a 0c                	push   $0xc
  800dbf:	68 84 16 80 00       	push   $0x801684
  800dc4:	6a 23                	push   $0x23
  800dc6:	68 a1 16 80 00       	push   $0x8016a1
  800dcb:	e8 a1 02 00 00       	call   801071 <_panic>

00800dd0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dd0:	f3 0f 1e fb          	endbr32 
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	53                   	push   %ebx
  800dd8:	83 ec 04             	sub    $0x4,%esp
  800ddb:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dde:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpt[PGNUM(addr)] & PTE_COW))) { 
  800de0:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800de4:	74 74                	je     800e5a <pgfault+0x8a>
  800de6:	89 d8                	mov    %ebx,%eax
  800de8:	c1 e8 0c             	shr    $0xc,%eax
  800deb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800df2:	f6 c4 08             	test   $0x8,%ah
  800df5:	74 63                	je     800e5a <pgfault+0x8a>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  800df7:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_map(0, addr, 0, PFTEMP, PTE_U|PTE_P)) < 0)		
  800dfd:	83 ec 0c             	sub    $0xc,%esp
  800e00:	6a 05                	push   $0x5
  800e02:	68 00 f0 7f 00       	push   $0x7ff000
  800e07:	6a 00                	push   $0x0
  800e09:	53                   	push   %ebx
  800e0a:	6a 00                	push   $0x0
  800e0c:	e8 3b fe ff ff       	call   800c4c <sys_page_map>
  800e11:	83 c4 20             	add    $0x20,%esp
  800e14:	85 c0                	test   %eax,%eax
  800e16:	78 56                	js     800e6e <pgfault+0x9e>
		panic("sys_page_map: %e", r);
	if ((r = sys_page_alloc(0, addr, PTE_P|PTE_U|PTE_W)) < 0)	
  800e18:	83 ec 04             	sub    $0x4,%esp
  800e1b:	6a 07                	push   $0x7
  800e1d:	53                   	push   %ebx
  800e1e:	6a 00                	push   $0x0
  800e20:	e8 e0 fd ff ff       	call   800c05 <sys_page_alloc>
  800e25:	83 c4 10             	add    $0x10,%esp
  800e28:	85 c0                	test   %eax,%eax
  800e2a:	78 54                	js     800e80 <pgfault+0xb0>
		panic("sys_page_alloc: %e", r);
	memmove(addr, PFTEMP, PGSIZE);							
  800e2c:	83 ec 04             	sub    $0x4,%esp
  800e2f:	68 00 10 00 00       	push   $0x1000
  800e34:	68 00 f0 7f 00       	push   $0x7ff000
  800e39:	53                   	push   %ebx
  800e3a:	e8 3a fb ff ff       	call   800979 <memmove>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)				
  800e3f:	83 c4 08             	add    $0x8,%esp
  800e42:	68 00 f0 7f 00       	push   $0x7ff000
  800e47:	6a 00                	push   $0x0
  800e49:	e8 44 fe ff ff       	call   800c92 <sys_page_unmap>
  800e4e:	83 c4 10             	add    $0x10,%esp
  800e51:	85 c0                	test   %eax,%eax
  800e53:	78 3d                	js     800e92 <pgfault+0xc2>
		panic("sys_page_unmap: %e", r);
}
  800e55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e58:	c9                   	leave  
  800e59:	c3                   	ret    
		panic("pgfault():not cow");
  800e5a:	83 ec 04             	sub    $0x4,%esp
  800e5d:	68 af 16 80 00       	push   $0x8016af
  800e62:	6a 1d                	push   $0x1d
  800e64:	68 c1 16 80 00       	push   $0x8016c1
  800e69:	e8 03 02 00 00       	call   801071 <_panic>
		panic("sys_page_map: %e", r);
  800e6e:	50                   	push   %eax
  800e6f:	68 cc 16 80 00       	push   $0x8016cc
  800e74:	6a 2a                	push   $0x2a
  800e76:	68 c1 16 80 00       	push   $0x8016c1
  800e7b:	e8 f1 01 00 00       	call   801071 <_panic>
		panic("sys_page_alloc: %e", r);
  800e80:	50                   	push   %eax
  800e81:	68 dd 16 80 00       	push   $0x8016dd
  800e86:	6a 2c                	push   $0x2c
  800e88:	68 c1 16 80 00       	push   $0x8016c1
  800e8d:	e8 df 01 00 00       	call   801071 <_panic>
		panic("sys_page_unmap: %e", r);
  800e92:	50                   	push   %eax
  800e93:	68 f0 16 80 00       	push   $0x8016f0
  800e98:	6a 2f                	push   $0x2f
  800e9a:	68 c1 16 80 00       	push   $0x8016c1
  800e9f:	e8 cd 01 00 00       	call   801071 <_panic>

00800ea4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ea4:	f3 0f 1e fb          	endbr32 
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	57                   	push   %edi
  800eac:	56                   	push   %esi
  800ead:	53                   	push   %ebx
  800eae:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	extern void _pgfault_upcall(void);
	set_pgfault_handler(pgfault);	
  800eb1:	68 d0 0d 80 00       	push   $0x800dd0
  800eb6:	e8 00 02 00 00       	call   8010bb <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ebb:	b8 07 00 00 00       	mov    $0x7,%eax
  800ec0:	cd 30                	int    $0x30
  800ec2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();	
	if (envid == 0) {				
  800ec5:	83 c4 10             	add    $0x10,%esp
  800ec8:	85 c0                	test   %eax,%eax
  800eca:	74 12                	je     800ede <fork+0x3a>
  800ecc:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	if (envid < 0) {
  800ece:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ed2:	78 29                	js     800efd <fork+0x59>
		panic("sys_exofork: %e", envid);
	}

	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  800ed4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed9:	e9 80 00 00 00       	jmp    800f5e <fork+0xba>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ede:	e8 dc fc ff ff       	call   800bbf <sys_getenvid>
  800ee3:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ee8:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  800eee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ef3:	a3 60 40 80 00       	mov    %eax,0x804060
		return 0;
  800ef8:	e9 27 01 00 00       	jmp    801024 <fork+0x180>
		panic("sys_exofork: %e", envid);
  800efd:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f00:	68 03 17 80 00       	push   $0x801703
  800f05:	6a 6b                	push   $0x6b
  800f07:	68 c1 16 80 00       	push   $0x8016c1
  800f0c:	e8 60 01 00 00       	call   801071 <_panic>
		if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800f11:	83 ec 0c             	sub    $0xc,%esp
  800f14:	68 05 08 00 00       	push   $0x805
  800f19:	56                   	push   %esi
  800f1a:	57                   	push   %edi
  800f1b:	56                   	push   %esi
  800f1c:	6a 00                	push   $0x0
  800f1e:	e8 29 fd ff ff       	call   800c4c <sys_page_map>
  800f23:	83 c4 20             	add    $0x20,%esp
  800f26:	85 c0                	test   %eax,%eax
  800f28:	0f 88 96 00 00 00    	js     800fc4 <fork+0x120>
		if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800f2e:	83 ec 0c             	sub    $0xc,%esp
  800f31:	68 05 08 00 00       	push   $0x805
  800f36:	56                   	push   %esi
  800f37:	6a 00                	push   $0x0
  800f39:	56                   	push   %esi
  800f3a:	6a 00                	push   $0x0
  800f3c:	e8 0b fd ff ff       	call   800c4c <sys_page_map>
  800f41:	83 c4 20             	add    $0x20,%esp
  800f44:	85 c0                	test   %eax,%eax
  800f46:	0f 88 8a 00 00 00    	js     800fd6 <fork+0x132>
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  800f4c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f52:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f58:	0f 84 8a 00 00 00    	je     800fe8 <fork+0x144>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) 
  800f5e:	89 d8                	mov    %ebx,%eax
  800f60:	c1 e8 16             	shr    $0x16,%eax
  800f63:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f6a:	a8 01                	test   $0x1,%al
  800f6c:	74 de                	je     800f4c <fork+0xa8>
  800f6e:	89 d8                	mov    %ebx,%eax
  800f70:	c1 e8 0c             	shr    $0xc,%eax
  800f73:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f7a:	f6 c2 01             	test   $0x1,%dl
  800f7d:	74 cd                	je     800f4c <fork+0xa8>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  800f7f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f86:	f6 c2 04             	test   $0x4,%dl
  800f89:	74 c1                	je     800f4c <fork+0xa8>
	void *addr = (void*) (pn * PGSIZE);
  800f8b:	89 c6                	mov    %eax,%esi
  800f8d:	c1 e6 0c             	shl    $0xc,%esi
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) { 
  800f90:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f97:	f6 c2 02             	test   $0x2,%dl
  800f9a:	0f 85 71 ff ff ff    	jne    800f11 <fork+0x6d>
  800fa0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fa7:	f6 c4 08             	test   $0x8,%ah
  800faa:	0f 85 61 ff ff ff    	jne    800f11 <fork+0x6d>
		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);	
  800fb0:	83 ec 0c             	sub    $0xc,%esp
  800fb3:	6a 05                	push   $0x5
  800fb5:	56                   	push   %esi
  800fb6:	57                   	push   %edi
  800fb7:	56                   	push   %esi
  800fb8:	6a 00                	push   $0x0
  800fba:	e8 8d fc ff ff       	call   800c4c <sys_page_map>
  800fbf:	83 c4 20             	add    $0x20,%esp
  800fc2:	eb 88                	jmp    800f4c <fork+0xa8>
			panic("sys_page_map：%e", r);
  800fc4:	50                   	push   %eax
  800fc5:	68 13 17 80 00       	push   $0x801713
  800fca:	6a 46                	push   $0x46
  800fcc:	68 c1 16 80 00       	push   $0x8016c1
  800fd1:	e8 9b 00 00 00       	call   801071 <_panic>
			panic("sys_page_map：%e", r);
  800fd6:	50                   	push   %eax
  800fd7:	68 13 17 80 00       	push   $0x801713
  800fdc:	6a 48                	push   $0x48
  800fde:	68 c1 16 80 00       	push   $0x8016c1
  800fe3:	e8 89 00 00 00       	call   801071 <_panic>
			duppage(envid, PGNUM(addr));	
		}
	}
	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)	
  800fe8:	83 ec 04             	sub    $0x4,%esp
  800feb:	6a 07                	push   $0x7
  800fed:	68 00 f0 bf ee       	push   $0xeebff000
  800ff2:	ff 75 e4             	pushl  -0x1c(%ebp)
  800ff5:	e8 0b fc ff ff       	call   800c05 <sys_page_alloc>
  800ffa:	83 c4 10             	add    $0x10,%esp
  800ffd:	85 c0                	test   %eax,%eax
  800fff:	78 2e                	js     80102f <fork+0x18b>
		panic("sys_page_alloc: %e", r);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);		
  801001:	83 ec 08             	sub    $0x8,%esp
  801004:	68 18 11 80 00       	push   $0x801118
  801009:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80100c:	57                   	push   %edi
  80100d:	e8 0c fd ff ff       	call   800d1e <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)	
  801012:	83 c4 08             	add    $0x8,%esp
  801015:	6a 02                	push   $0x2
  801017:	57                   	push   %edi
  801018:	e8 bb fc ff ff       	call   800cd8 <sys_env_set_status>
  80101d:	83 c4 10             	add    $0x10,%esp
  801020:	85 c0                	test   %eax,%eax
  801022:	78 1d                	js     801041 <fork+0x19d>
		panic("sys_env_set_status: %e", r);
	return envid;
}
  801024:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801027:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80102a:	5b                   	pop    %ebx
  80102b:	5e                   	pop    %esi
  80102c:	5f                   	pop    %edi
  80102d:	5d                   	pop    %ebp
  80102e:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  80102f:	50                   	push   %eax
  801030:	68 dd 16 80 00       	push   $0x8016dd
  801035:	6a 77                	push   $0x77
  801037:	68 c1 16 80 00       	push   $0x8016c1
  80103c:	e8 30 00 00 00       	call   801071 <_panic>
		panic("sys_env_set_status: %e", r);
  801041:	50                   	push   %eax
  801042:	68 25 17 80 00       	push   $0x801725
  801047:	6a 7b                	push   $0x7b
  801049:	68 c1 16 80 00       	push   $0x8016c1
  80104e:	e8 1e 00 00 00       	call   801071 <_panic>

00801053 <sfork>:

// Challenge!
int
sfork(void)
{
  801053:	f3 0f 1e fb          	endbr32 
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80105d:	68 3c 17 80 00       	push   $0x80173c
  801062:	68 83 00 00 00       	push   $0x83
  801067:	68 c1 16 80 00       	push   $0x8016c1
  80106c:	e8 00 00 00 00       	call   801071 <_panic>

00801071 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801071:	f3 0f 1e fb          	endbr32 
  801075:	55                   	push   %ebp
  801076:	89 e5                	mov    %esp,%ebp
  801078:	56                   	push   %esi
  801079:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80107a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80107d:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801083:	e8 37 fb ff ff       	call   800bbf <sys_getenvid>
  801088:	83 ec 0c             	sub    $0xc,%esp
  80108b:	ff 75 0c             	pushl  0xc(%ebp)
  80108e:	ff 75 08             	pushl  0x8(%ebp)
  801091:	56                   	push   %esi
  801092:	50                   	push   %eax
  801093:	68 54 17 80 00       	push   $0x801754
  801098:	e8 1c f1 ff ff       	call   8001b9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80109d:	83 c4 18             	add    $0x18,%esp
  8010a0:	53                   	push   %ebx
  8010a1:	ff 75 10             	pushl  0x10(%ebp)
  8010a4:	e8 bb f0 ff ff       	call   800164 <vcprintf>
	cprintf("\n");
  8010a9:	c7 04 24 34 14 80 00 	movl   $0x801434,(%esp)
  8010b0:	e8 04 f1 ff ff       	call   8001b9 <cprintf>
  8010b5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010b8:	cc                   	int3   
  8010b9:	eb fd                	jmp    8010b8 <_panic+0x47>

008010bb <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8010bb:	f3 0f 1e fb          	endbr32 
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8010c5:	83 3d 64 40 80 00 00 	cmpl   $0x0,0x804064
  8010cc:	74 0a                	je     8010d8 <set_pgfault_handler+0x1d>
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);		//系统调用，设置进程的env_pgfault_upcall属性
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8010ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d1:	a3 64 40 80 00       	mov    %eax,0x804064
}
  8010d6:	c9                   	leave  
  8010d7:	c3                   	ret    
		int r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_W | PTE_U | PTE_P);	//为当前进程分配异常栈
  8010d8:	83 ec 04             	sub    $0x4,%esp
  8010db:	6a 07                	push   $0x7
  8010dd:	68 00 f0 bf ee       	push   $0xeebff000
  8010e2:	6a 00                	push   $0x0
  8010e4:	e8 1c fb ff ff       	call   800c05 <sys_page_alloc>
		if (r < 0) {
  8010e9:	83 c4 10             	add    $0x10,%esp
  8010ec:	85 c0                	test   %eax,%eax
  8010ee:	78 14                	js     801104 <set_pgfault_handler+0x49>
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);		//系统调用，设置进程的env_pgfault_upcall属性
  8010f0:	83 ec 08             	sub    $0x8,%esp
  8010f3:	68 18 11 80 00       	push   $0x801118
  8010f8:	6a 00                	push   $0x0
  8010fa:	e8 1f fc ff ff       	call   800d1e <sys_env_set_pgfault_upcall>
  8010ff:	83 c4 10             	add    $0x10,%esp
  801102:	eb ca                	jmp    8010ce <set_pgfault_handler+0x13>
			panic("set_pgfault_handler:sys_page_alloc failed");;
  801104:	83 ec 04             	sub    $0x4,%esp
  801107:	68 78 17 80 00       	push   $0x801778
  80110c:	6a 22                	push   $0x22
  80110e:	68 a2 17 80 00       	push   $0x8017a2
  801113:	e8 59 ff ff ff       	call   801071 <_panic>

00801118 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801118:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801119:	a1 64 40 80 00       	mov    0x804064,%eax
	call *%eax				
  80111e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801120:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp			
  801123:	83 c4 08             	add    $0x8,%esp
	movl 40(%esp), %eax 	
  801126:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 32(%esp), %ecx 	
  80112a:	8b 4c 24 20          	mov    0x20(%esp),%ecx
	movl %ecx, -4(%eax) 	
  80112e:	89 48 fc             	mov    %ecx,-0x4(%eax)
	popal
  801131:	61                   	popa   
	addl $4, %esp		
  801132:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popfl
  801135:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801136:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	lea -4(%esp), %esp	
  801137:	8d 64 24 fc          	lea    -0x4(%esp),%esp
	ret
  80113b:	c3                   	ret    
  80113c:	66 90                	xchg   %ax,%ax
  80113e:	66 90                	xchg   %ax,%ax

00801140 <__udivdi3>:
  801140:	f3 0f 1e fb          	endbr32 
  801144:	55                   	push   %ebp
  801145:	57                   	push   %edi
  801146:	56                   	push   %esi
  801147:	53                   	push   %ebx
  801148:	83 ec 1c             	sub    $0x1c,%esp
  80114b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80114f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801153:	8b 74 24 34          	mov    0x34(%esp),%esi
  801157:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80115b:	85 d2                	test   %edx,%edx
  80115d:	75 19                	jne    801178 <__udivdi3+0x38>
  80115f:	39 f3                	cmp    %esi,%ebx
  801161:	76 4d                	jbe    8011b0 <__udivdi3+0x70>
  801163:	31 ff                	xor    %edi,%edi
  801165:	89 e8                	mov    %ebp,%eax
  801167:	89 f2                	mov    %esi,%edx
  801169:	f7 f3                	div    %ebx
  80116b:	89 fa                	mov    %edi,%edx
  80116d:	83 c4 1c             	add    $0x1c,%esp
  801170:	5b                   	pop    %ebx
  801171:	5e                   	pop    %esi
  801172:	5f                   	pop    %edi
  801173:	5d                   	pop    %ebp
  801174:	c3                   	ret    
  801175:	8d 76 00             	lea    0x0(%esi),%esi
  801178:	39 f2                	cmp    %esi,%edx
  80117a:	76 14                	jbe    801190 <__udivdi3+0x50>
  80117c:	31 ff                	xor    %edi,%edi
  80117e:	31 c0                	xor    %eax,%eax
  801180:	89 fa                	mov    %edi,%edx
  801182:	83 c4 1c             	add    $0x1c,%esp
  801185:	5b                   	pop    %ebx
  801186:	5e                   	pop    %esi
  801187:	5f                   	pop    %edi
  801188:	5d                   	pop    %ebp
  801189:	c3                   	ret    
  80118a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801190:	0f bd fa             	bsr    %edx,%edi
  801193:	83 f7 1f             	xor    $0x1f,%edi
  801196:	75 48                	jne    8011e0 <__udivdi3+0xa0>
  801198:	39 f2                	cmp    %esi,%edx
  80119a:	72 06                	jb     8011a2 <__udivdi3+0x62>
  80119c:	31 c0                	xor    %eax,%eax
  80119e:	39 eb                	cmp    %ebp,%ebx
  8011a0:	77 de                	ja     801180 <__udivdi3+0x40>
  8011a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8011a7:	eb d7                	jmp    801180 <__udivdi3+0x40>
  8011a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011b0:	89 d9                	mov    %ebx,%ecx
  8011b2:	85 db                	test   %ebx,%ebx
  8011b4:	75 0b                	jne    8011c1 <__udivdi3+0x81>
  8011b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8011bb:	31 d2                	xor    %edx,%edx
  8011bd:	f7 f3                	div    %ebx
  8011bf:	89 c1                	mov    %eax,%ecx
  8011c1:	31 d2                	xor    %edx,%edx
  8011c3:	89 f0                	mov    %esi,%eax
  8011c5:	f7 f1                	div    %ecx
  8011c7:	89 c6                	mov    %eax,%esi
  8011c9:	89 e8                	mov    %ebp,%eax
  8011cb:	89 f7                	mov    %esi,%edi
  8011cd:	f7 f1                	div    %ecx
  8011cf:	89 fa                	mov    %edi,%edx
  8011d1:	83 c4 1c             	add    $0x1c,%esp
  8011d4:	5b                   	pop    %ebx
  8011d5:	5e                   	pop    %esi
  8011d6:	5f                   	pop    %edi
  8011d7:	5d                   	pop    %ebp
  8011d8:	c3                   	ret    
  8011d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011e0:	89 f9                	mov    %edi,%ecx
  8011e2:	b8 20 00 00 00       	mov    $0x20,%eax
  8011e7:	29 f8                	sub    %edi,%eax
  8011e9:	d3 e2                	shl    %cl,%edx
  8011eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8011ef:	89 c1                	mov    %eax,%ecx
  8011f1:	89 da                	mov    %ebx,%edx
  8011f3:	d3 ea                	shr    %cl,%edx
  8011f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8011f9:	09 d1                	or     %edx,%ecx
  8011fb:	89 f2                	mov    %esi,%edx
  8011fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801201:	89 f9                	mov    %edi,%ecx
  801203:	d3 e3                	shl    %cl,%ebx
  801205:	89 c1                	mov    %eax,%ecx
  801207:	d3 ea                	shr    %cl,%edx
  801209:	89 f9                	mov    %edi,%ecx
  80120b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80120f:	89 eb                	mov    %ebp,%ebx
  801211:	d3 e6                	shl    %cl,%esi
  801213:	89 c1                	mov    %eax,%ecx
  801215:	d3 eb                	shr    %cl,%ebx
  801217:	09 de                	or     %ebx,%esi
  801219:	89 f0                	mov    %esi,%eax
  80121b:	f7 74 24 08          	divl   0x8(%esp)
  80121f:	89 d6                	mov    %edx,%esi
  801221:	89 c3                	mov    %eax,%ebx
  801223:	f7 64 24 0c          	mull   0xc(%esp)
  801227:	39 d6                	cmp    %edx,%esi
  801229:	72 15                	jb     801240 <__udivdi3+0x100>
  80122b:	89 f9                	mov    %edi,%ecx
  80122d:	d3 e5                	shl    %cl,%ebp
  80122f:	39 c5                	cmp    %eax,%ebp
  801231:	73 04                	jae    801237 <__udivdi3+0xf7>
  801233:	39 d6                	cmp    %edx,%esi
  801235:	74 09                	je     801240 <__udivdi3+0x100>
  801237:	89 d8                	mov    %ebx,%eax
  801239:	31 ff                	xor    %edi,%edi
  80123b:	e9 40 ff ff ff       	jmp    801180 <__udivdi3+0x40>
  801240:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801243:	31 ff                	xor    %edi,%edi
  801245:	e9 36 ff ff ff       	jmp    801180 <__udivdi3+0x40>
  80124a:	66 90                	xchg   %ax,%ax
  80124c:	66 90                	xchg   %ax,%ax
  80124e:	66 90                	xchg   %ax,%ax

00801250 <__umoddi3>:
  801250:	f3 0f 1e fb          	endbr32 
  801254:	55                   	push   %ebp
  801255:	57                   	push   %edi
  801256:	56                   	push   %esi
  801257:	53                   	push   %ebx
  801258:	83 ec 1c             	sub    $0x1c,%esp
  80125b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80125f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801263:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801267:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80126b:	85 c0                	test   %eax,%eax
  80126d:	75 19                	jne    801288 <__umoddi3+0x38>
  80126f:	39 df                	cmp    %ebx,%edi
  801271:	76 5d                	jbe    8012d0 <__umoddi3+0x80>
  801273:	89 f0                	mov    %esi,%eax
  801275:	89 da                	mov    %ebx,%edx
  801277:	f7 f7                	div    %edi
  801279:	89 d0                	mov    %edx,%eax
  80127b:	31 d2                	xor    %edx,%edx
  80127d:	83 c4 1c             	add    $0x1c,%esp
  801280:	5b                   	pop    %ebx
  801281:	5e                   	pop    %esi
  801282:	5f                   	pop    %edi
  801283:	5d                   	pop    %ebp
  801284:	c3                   	ret    
  801285:	8d 76 00             	lea    0x0(%esi),%esi
  801288:	89 f2                	mov    %esi,%edx
  80128a:	39 d8                	cmp    %ebx,%eax
  80128c:	76 12                	jbe    8012a0 <__umoddi3+0x50>
  80128e:	89 f0                	mov    %esi,%eax
  801290:	89 da                	mov    %ebx,%edx
  801292:	83 c4 1c             	add    $0x1c,%esp
  801295:	5b                   	pop    %ebx
  801296:	5e                   	pop    %esi
  801297:	5f                   	pop    %edi
  801298:	5d                   	pop    %ebp
  801299:	c3                   	ret    
  80129a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012a0:	0f bd e8             	bsr    %eax,%ebp
  8012a3:	83 f5 1f             	xor    $0x1f,%ebp
  8012a6:	75 50                	jne    8012f8 <__umoddi3+0xa8>
  8012a8:	39 d8                	cmp    %ebx,%eax
  8012aa:	0f 82 e0 00 00 00    	jb     801390 <__umoddi3+0x140>
  8012b0:	89 d9                	mov    %ebx,%ecx
  8012b2:	39 f7                	cmp    %esi,%edi
  8012b4:	0f 86 d6 00 00 00    	jbe    801390 <__umoddi3+0x140>
  8012ba:	89 d0                	mov    %edx,%eax
  8012bc:	89 ca                	mov    %ecx,%edx
  8012be:	83 c4 1c             	add    $0x1c,%esp
  8012c1:	5b                   	pop    %ebx
  8012c2:	5e                   	pop    %esi
  8012c3:	5f                   	pop    %edi
  8012c4:	5d                   	pop    %ebp
  8012c5:	c3                   	ret    
  8012c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012cd:	8d 76 00             	lea    0x0(%esi),%esi
  8012d0:	89 fd                	mov    %edi,%ebp
  8012d2:	85 ff                	test   %edi,%edi
  8012d4:	75 0b                	jne    8012e1 <__umoddi3+0x91>
  8012d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8012db:	31 d2                	xor    %edx,%edx
  8012dd:	f7 f7                	div    %edi
  8012df:	89 c5                	mov    %eax,%ebp
  8012e1:	89 d8                	mov    %ebx,%eax
  8012e3:	31 d2                	xor    %edx,%edx
  8012e5:	f7 f5                	div    %ebp
  8012e7:	89 f0                	mov    %esi,%eax
  8012e9:	f7 f5                	div    %ebp
  8012eb:	89 d0                	mov    %edx,%eax
  8012ed:	31 d2                	xor    %edx,%edx
  8012ef:	eb 8c                	jmp    80127d <__umoddi3+0x2d>
  8012f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012f8:	89 e9                	mov    %ebp,%ecx
  8012fa:	ba 20 00 00 00       	mov    $0x20,%edx
  8012ff:	29 ea                	sub    %ebp,%edx
  801301:	d3 e0                	shl    %cl,%eax
  801303:	89 44 24 08          	mov    %eax,0x8(%esp)
  801307:	89 d1                	mov    %edx,%ecx
  801309:	89 f8                	mov    %edi,%eax
  80130b:	d3 e8                	shr    %cl,%eax
  80130d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801311:	89 54 24 04          	mov    %edx,0x4(%esp)
  801315:	8b 54 24 04          	mov    0x4(%esp),%edx
  801319:	09 c1                	or     %eax,%ecx
  80131b:	89 d8                	mov    %ebx,%eax
  80131d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801321:	89 e9                	mov    %ebp,%ecx
  801323:	d3 e7                	shl    %cl,%edi
  801325:	89 d1                	mov    %edx,%ecx
  801327:	d3 e8                	shr    %cl,%eax
  801329:	89 e9                	mov    %ebp,%ecx
  80132b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80132f:	d3 e3                	shl    %cl,%ebx
  801331:	89 c7                	mov    %eax,%edi
  801333:	89 d1                	mov    %edx,%ecx
  801335:	89 f0                	mov    %esi,%eax
  801337:	d3 e8                	shr    %cl,%eax
  801339:	89 e9                	mov    %ebp,%ecx
  80133b:	89 fa                	mov    %edi,%edx
  80133d:	d3 e6                	shl    %cl,%esi
  80133f:	09 d8                	or     %ebx,%eax
  801341:	f7 74 24 08          	divl   0x8(%esp)
  801345:	89 d1                	mov    %edx,%ecx
  801347:	89 f3                	mov    %esi,%ebx
  801349:	f7 64 24 0c          	mull   0xc(%esp)
  80134d:	89 c6                	mov    %eax,%esi
  80134f:	89 d7                	mov    %edx,%edi
  801351:	39 d1                	cmp    %edx,%ecx
  801353:	72 06                	jb     80135b <__umoddi3+0x10b>
  801355:	75 10                	jne    801367 <__umoddi3+0x117>
  801357:	39 c3                	cmp    %eax,%ebx
  801359:	73 0c                	jae    801367 <__umoddi3+0x117>
  80135b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80135f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801363:	89 d7                	mov    %edx,%edi
  801365:	89 c6                	mov    %eax,%esi
  801367:	89 ca                	mov    %ecx,%edx
  801369:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80136e:	29 f3                	sub    %esi,%ebx
  801370:	19 fa                	sbb    %edi,%edx
  801372:	89 d0                	mov    %edx,%eax
  801374:	d3 e0                	shl    %cl,%eax
  801376:	89 e9                	mov    %ebp,%ecx
  801378:	d3 eb                	shr    %cl,%ebx
  80137a:	d3 ea                	shr    %cl,%edx
  80137c:	09 d8                	or     %ebx,%eax
  80137e:	83 c4 1c             	add    $0x1c,%esp
  801381:	5b                   	pop    %ebx
  801382:	5e                   	pop    %esi
  801383:	5f                   	pop    %edi
  801384:	5d                   	pop    %ebp
  801385:	c3                   	ret    
  801386:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80138d:	8d 76 00             	lea    0x0(%esi),%esi
  801390:	29 fe                	sub    %edi,%esi
  801392:	19 c3                	sbb    %eax,%ebx
  801394:	89 f2                	mov    %esi,%edx
  801396:	89 d9                	mov    %ebx,%ecx
  801398:	e9 1d ff ff ff       	jmp    8012ba <__umoddi3+0x6a>
