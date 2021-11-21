
obj/user/forktree:     file format elf32-i386


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
  80002c:	e8 be 00 00 00       	call   8000ef <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	53                   	push   %ebx
  80003b:	83 ec 04             	sub    $0x4,%esp
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  800041:	e8 af 0b 00 00       	call   800bf5 <sys_getenvid>
  800046:	83 ec 04             	sub    $0x4,%esp
  800049:	53                   	push   %ebx
  80004a:	50                   	push   %eax
  80004b:	68 e0 13 80 00       	push   $0x8013e0
  800050:	e8 9a 01 00 00       	call   8001ef <cprintf>

	forkchild(cur, '0');
  800055:	83 c4 08             	add    $0x8,%esp
  800058:	6a 30                	push   $0x30
  80005a:	53                   	push   %ebx
  80005b:	e8 13 00 00 00       	call   800073 <forkchild>
	forkchild(cur, '1');
  800060:	83 c4 08             	add    $0x8,%esp
  800063:	6a 31                	push   $0x31
  800065:	53                   	push   %ebx
  800066:	e8 08 00 00 00       	call   800073 <forkchild>
}
  80006b:	83 c4 10             	add    $0x10,%esp
  80006e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800071:	c9                   	leave  
  800072:	c3                   	ret    

00800073 <forkchild>:
{
  800073:	f3 0f 1e fb          	endbr32 
  800077:	55                   	push   %ebp
  800078:	89 e5                	mov    %esp,%ebp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	83 ec 1c             	sub    $0x1c,%esp
  80007f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800082:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (strlen(cur) >= DEPTH)
  800085:	53                   	push   %ebx
  800086:	e8 2b 07 00 00       	call   8007b6 <strlen>
  80008b:	83 c4 10             	add    $0x10,%esp
  80008e:	83 f8 02             	cmp    $0x2,%eax
  800091:	7e 07                	jle    80009a <forkchild+0x27>
}
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    
	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	89 f0                	mov    %esi,%eax
  80009f:	0f be f0             	movsbl %al,%esi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
  8000a4:	68 f1 13 80 00       	push   $0x8013f1
  8000a9:	6a 04                	push   $0x4
  8000ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000ae:	50                   	push   %eax
  8000af:	e8 e4 06 00 00       	call   800798 <snprintf>
	if (fork() == 0) {
  8000b4:	83 c4 20             	add    $0x20,%esp
  8000b7:	e8 1e 0e 00 00       	call   800eda <fork>
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	75 d3                	jne    800093 <forkchild+0x20>
		forktree(nxt);
  8000c0:	83 ec 0c             	sub    $0xc,%esp
  8000c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000c6:	50                   	push   %eax
  8000c7:	e8 67 ff ff ff       	call   800033 <forktree>
		exit();
  8000cc:	e8 6b 00 00 00       	call   80013c <exit>
  8000d1:	83 c4 10             	add    $0x10,%esp
  8000d4:	eb bd                	jmp    800093 <forkchild+0x20>

008000d6 <umain>:

void
umain(int argc, char **argv)
{
  8000d6:	f3 0f 1e fb          	endbr32 
  8000da:	55                   	push   %ebp
  8000db:	89 e5                	mov    %esp,%ebp
  8000dd:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000e0:	68 f0 13 80 00       	push   $0x8013f0
  8000e5:	e8 49 ff ff ff       	call   800033 <forktree>
}
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	c9                   	leave  
  8000ee:	c3                   	ret    

008000ef <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ef:	f3 0f 1e fb          	endbr32 
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	56                   	push   %esi
  8000f7:	53                   	push   %ebx
  8000f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000fb:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8000fe:	e8 f2 0a 00 00       	call   800bf5 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
  800108:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  80010e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800113:	a3 60 40 80 00       	mov    %eax,0x804060

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800118:	85 db                	test   %ebx,%ebx
  80011a:	7e 07                	jle    800123 <libmain+0x34>
		binaryname = argv[0];
  80011c:	8b 06                	mov    (%esi),%eax
  80011e:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800123:	83 ec 08             	sub    $0x8,%esp
  800126:	56                   	push   %esi
  800127:	53                   	push   %ebx
  800128:	e8 a9 ff ff ff       	call   8000d6 <umain>

	// exit gracefully
	exit();
  80012d:	e8 0a 00 00 00       	call   80013c <exit>
}
  800132:	83 c4 10             	add    $0x10,%esp
  800135:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800138:	5b                   	pop    %ebx
  800139:	5e                   	pop    %esi
  80013a:	5d                   	pop    %ebp
  80013b:	c3                   	ret    

0080013c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013c:	f3 0f 1e fb          	endbr32 
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800146:	6a 00                	push   $0x0
  800148:	e8 63 0a 00 00       	call   800bb0 <sys_env_destroy>
}
  80014d:	83 c4 10             	add    $0x10,%esp
  800150:	c9                   	leave  
  800151:	c3                   	ret    

00800152 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800152:	f3 0f 1e fb          	endbr32 
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	53                   	push   %ebx
  80015a:	83 ec 04             	sub    $0x4,%esp
  80015d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800160:	8b 13                	mov    (%ebx),%edx
  800162:	8d 42 01             	lea    0x1(%edx),%eax
  800165:	89 03                	mov    %eax,(%ebx)
  800167:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80016e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800173:	74 09                	je     80017e <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800175:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800179:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80017c:	c9                   	leave  
  80017d:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80017e:	83 ec 08             	sub    $0x8,%esp
  800181:	68 ff 00 00 00       	push   $0xff
  800186:	8d 43 08             	lea    0x8(%ebx),%eax
  800189:	50                   	push   %eax
  80018a:	e8 dc 09 00 00       	call   800b6b <sys_cputs>
		b->idx = 0;
  80018f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800195:	83 c4 10             	add    $0x10,%esp
  800198:	eb db                	jmp    800175 <putch+0x23>

0080019a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019a:	f3 0f 1e fb          	endbr32 
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ae:	00 00 00 
	b.cnt = 0;
  8001b1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bb:	ff 75 0c             	pushl  0xc(%ebp)
  8001be:	ff 75 08             	pushl  0x8(%ebp)
  8001c1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c7:	50                   	push   %eax
  8001c8:	68 52 01 80 00       	push   $0x800152
  8001cd:	e8 20 01 00 00       	call   8002f2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d2:	83 c4 08             	add    $0x8,%esp
  8001d5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001db:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e1:	50                   	push   %eax
  8001e2:	e8 84 09 00 00       	call   800b6b <sys_cputs>

	return b.cnt;
}
  8001e7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ed:	c9                   	leave  
  8001ee:	c3                   	ret    

008001ef <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ef:	f3 0f 1e fb          	endbr32 
  8001f3:	55                   	push   %ebp
  8001f4:	89 e5                	mov    %esp,%ebp
  8001f6:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001fc:	50                   	push   %eax
  8001fd:	ff 75 08             	pushl  0x8(%ebp)
  800200:	e8 95 ff ff ff       	call   80019a <vcprintf>
	va_end(ap);

	return cnt;
}
  800205:	c9                   	leave  
  800206:	c3                   	ret    

00800207 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800207:	55                   	push   %ebp
  800208:	89 e5                	mov    %esp,%ebp
  80020a:	57                   	push   %edi
  80020b:	56                   	push   %esi
  80020c:	53                   	push   %ebx
  80020d:	83 ec 1c             	sub    $0x1c,%esp
  800210:	89 c7                	mov    %eax,%edi
  800212:	89 d6                	mov    %edx,%esi
  800214:	8b 45 08             	mov    0x8(%ebp),%eax
  800217:	8b 55 0c             	mov    0xc(%ebp),%edx
  80021a:	89 d1                	mov    %edx,%ecx
  80021c:	89 c2                	mov    %eax,%edx
  80021e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800221:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800224:	8b 45 10             	mov    0x10(%ebp),%eax
  800227:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80022a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80022d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800234:	39 c2                	cmp    %eax,%edx
  800236:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800239:	72 3e                	jb     800279 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80023b:	83 ec 0c             	sub    $0xc,%esp
  80023e:	ff 75 18             	pushl  0x18(%ebp)
  800241:	83 eb 01             	sub    $0x1,%ebx
  800244:	53                   	push   %ebx
  800245:	50                   	push   %eax
  800246:	83 ec 08             	sub    $0x8,%esp
  800249:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024c:	ff 75 e0             	pushl  -0x20(%ebp)
  80024f:	ff 75 dc             	pushl  -0x24(%ebp)
  800252:	ff 75 d8             	pushl  -0x28(%ebp)
  800255:	e8 26 0f 00 00       	call   801180 <__udivdi3>
  80025a:	83 c4 18             	add    $0x18,%esp
  80025d:	52                   	push   %edx
  80025e:	50                   	push   %eax
  80025f:	89 f2                	mov    %esi,%edx
  800261:	89 f8                	mov    %edi,%eax
  800263:	e8 9f ff ff ff       	call   800207 <printnum>
  800268:	83 c4 20             	add    $0x20,%esp
  80026b:	eb 13                	jmp    800280 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026d:	83 ec 08             	sub    $0x8,%esp
  800270:	56                   	push   %esi
  800271:	ff 75 18             	pushl  0x18(%ebp)
  800274:	ff d7                	call   *%edi
  800276:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800279:	83 eb 01             	sub    $0x1,%ebx
  80027c:	85 db                	test   %ebx,%ebx
  80027e:	7f ed                	jg     80026d <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800280:	83 ec 08             	sub    $0x8,%esp
  800283:	56                   	push   %esi
  800284:	83 ec 04             	sub    $0x4,%esp
  800287:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028a:	ff 75 e0             	pushl  -0x20(%ebp)
  80028d:	ff 75 dc             	pushl  -0x24(%ebp)
  800290:	ff 75 d8             	pushl  -0x28(%ebp)
  800293:	e8 f8 0f 00 00       	call   801290 <__umoddi3>
  800298:	83 c4 14             	add    $0x14,%esp
  80029b:	0f be 80 00 14 80 00 	movsbl 0x801400(%eax),%eax
  8002a2:	50                   	push   %eax
  8002a3:	ff d7                	call   *%edi
}
  8002a5:	83 c4 10             	add    $0x10,%esp
  8002a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ab:	5b                   	pop    %ebx
  8002ac:	5e                   	pop    %esi
  8002ad:	5f                   	pop    %edi
  8002ae:	5d                   	pop    %ebp
  8002af:	c3                   	ret    

008002b0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b0:	f3 0f 1e fb          	endbr32 
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ba:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002be:	8b 10                	mov    (%eax),%edx
  8002c0:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c3:	73 0a                	jae    8002cf <sprintputch+0x1f>
		*b->buf++ = ch;
  8002c5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c8:	89 08                	mov    %ecx,(%eax)
  8002ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cd:	88 02                	mov    %al,(%edx)
}
  8002cf:	5d                   	pop    %ebp
  8002d0:	c3                   	ret    

008002d1 <printfmt>:
{
  8002d1:	f3 0f 1e fb          	endbr32 
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002db:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002de:	50                   	push   %eax
  8002df:	ff 75 10             	pushl  0x10(%ebp)
  8002e2:	ff 75 0c             	pushl  0xc(%ebp)
  8002e5:	ff 75 08             	pushl  0x8(%ebp)
  8002e8:	e8 05 00 00 00       	call   8002f2 <vprintfmt>
}
  8002ed:	83 c4 10             	add    $0x10,%esp
  8002f0:	c9                   	leave  
  8002f1:	c3                   	ret    

008002f2 <vprintfmt>:
{
  8002f2:	f3 0f 1e fb          	endbr32 
  8002f6:	55                   	push   %ebp
  8002f7:	89 e5                	mov    %esp,%ebp
  8002f9:	57                   	push   %edi
  8002fa:	56                   	push   %esi
  8002fb:	53                   	push   %ebx
  8002fc:	83 ec 3c             	sub    $0x3c,%esp
  8002ff:	8b 75 08             	mov    0x8(%ebp),%esi
  800302:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800305:	8b 7d 10             	mov    0x10(%ebp),%edi
  800308:	e9 8e 03 00 00       	jmp    80069b <vprintfmt+0x3a9>
		padc = ' ';
  80030d:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800311:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800318:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80031f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800326:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80032b:	8d 47 01             	lea    0x1(%edi),%eax
  80032e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800331:	0f b6 17             	movzbl (%edi),%edx
  800334:	8d 42 dd             	lea    -0x23(%edx),%eax
  800337:	3c 55                	cmp    $0x55,%al
  800339:	0f 87 df 03 00 00    	ja     80071e <vprintfmt+0x42c>
  80033f:	0f b6 c0             	movzbl %al,%eax
  800342:	3e ff 24 85 c0 14 80 	notrack jmp *0x8014c0(,%eax,4)
  800349:	00 
  80034a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80034d:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800351:	eb d8                	jmp    80032b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800353:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800356:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80035a:	eb cf                	jmp    80032b <vprintfmt+0x39>
  80035c:	0f b6 d2             	movzbl %dl,%edx
  80035f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800362:	b8 00 00 00 00       	mov    $0x0,%eax
  800367:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80036a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80036d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800371:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800374:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800377:	83 f9 09             	cmp    $0x9,%ecx
  80037a:	77 55                	ja     8003d1 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80037c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80037f:	eb e9                	jmp    80036a <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800381:	8b 45 14             	mov    0x14(%ebp),%eax
  800384:	8b 00                	mov    (%eax),%eax
  800386:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800389:	8b 45 14             	mov    0x14(%ebp),%eax
  80038c:	8d 40 04             	lea    0x4(%eax),%eax
  80038f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800395:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800399:	79 90                	jns    80032b <vprintfmt+0x39>
				width = precision, precision = -1;
  80039b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80039e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003a8:	eb 81                	jmp    80032b <vprintfmt+0x39>
  8003aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ad:	85 c0                	test   %eax,%eax
  8003af:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b4:	0f 49 d0             	cmovns %eax,%edx
  8003b7:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003bd:	e9 69 ff ff ff       	jmp    80032b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003c5:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003cc:	e9 5a ff ff ff       	jmp    80032b <vprintfmt+0x39>
  8003d1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003d7:	eb bc                	jmp    800395 <vprintfmt+0xa3>
			lflag++;
  8003d9:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003df:	e9 47 ff ff ff       	jmp    80032b <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e7:	8d 78 04             	lea    0x4(%eax),%edi
  8003ea:	83 ec 08             	sub    $0x8,%esp
  8003ed:	53                   	push   %ebx
  8003ee:	ff 30                	pushl  (%eax)
  8003f0:	ff d6                	call   *%esi
			break;
  8003f2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003f5:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003f8:	e9 9b 02 00 00       	jmp    800698 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  8003fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800400:	8d 78 04             	lea    0x4(%eax),%edi
  800403:	8b 00                	mov    (%eax),%eax
  800405:	99                   	cltd   
  800406:	31 d0                	xor    %edx,%eax
  800408:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80040a:	83 f8 08             	cmp    $0x8,%eax
  80040d:	7f 23                	jg     800432 <vprintfmt+0x140>
  80040f:	8b 14 85 20 16 80 00 	mov    0x801620(,%eax,4),%edx
  800416:	85 d2                	test   %edx,%edx
  800418:	74 18                	je     800432 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80041a:	52                   	push   %edx
  80041b:	68 21 14 80 00       	push   $0x801421
  800420:	53                   	push   %ebx
  800421:	56                   	push   %esi
  800422:	e8 aa fe ff ff       	call   8002d1 <printfmt>
  800427:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80042a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80042d:	e9 66 02 00 00       	jmp    800698 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800432:	50                   	push   %eax
  800433:	68 18 14 80 00       	push   $0x801418
  800438:	53                   	push   %ebx
  800439:	56                   	push   %esi
  80043a:	e8 92 fe ff ff       	call   8002d1 <printfmt>
  80043f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800442:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800445:	e9 4e 02 00 00       	jmp    800698 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  80044a:	8b 45 14             	mov    0x14(%ebp),%eax
  80044d:	83 c0 04             	add    $0x4,%eax
  800450:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800453:	8b 45 14             	mov    0x14(%ebp),%eax
  800456:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800458:	85 d2                	test   %edx,%edx
  80045a:	b8 11 14 80 00       	mov    $0x801411,%eax
  80045f:	0f 45 c2             	cmovne %edx,%eax
  800462:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800465:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800469:	7e 06                	jle    800471 <vprintfmt+0x17f>
  80046b:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80046f:	75 0d                	jne    80047e <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800471:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800474:	89 c7                	mov    %eax,%edi
  800476:	03 45 e0             	add    -0x20(%ebp),%eax
  800479:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047c:	eb 55                	jmp    8004d3 <vprintfmt+0x1e1>
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	ff 75 d8             	pushl  -0x28(%ebp)
  800484:	ff 75 cc             	pushl  -0x34(%ebp)
  800487:	e8 46 03 00 00       	call   8007d2 <strnlen>
  80048c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80048f:	29 c2                	sub    %eax,%edx
  800491:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800494:	83 c4 10             	add    $0x10,%esp
  800497:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800499:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80049d:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a0:	85 ff                	test   %edi,%edi
  8004a2:	7e 11                	jle    8004b5 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004a4:	83 ec 08             	sub    $0x8,%esp
  8004a7:	53                   	push   %ebx
  8004a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ab:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ad:	83 ef 01             	sub    $0x1,%edi
  8004b0:	83 c4 10             	add    $0x10,%esp
  8004b3:	eb eb                	jmp    8004a0 <vprintfmt+0x1ae>
  8004b5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004b8:	85 d2                	test   %edx,%edx
  8004ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bf:	0f 49 c2             	cmovns %edx,%eax
  8004c2:	29 c2                	sub    %eax,%edx
  8004c4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004c7:	eb a8                	jmp    800471 <vprintfmt+0x17f>
					putch(ch, putdat);
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	53                   	push   %ebx
  8004cd:	52                   	push   %edx
  8004ce:	ff d6                	call   *%esi
  8004d0:	83 c4 10             	add    $0x10,%esp
  8004d3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d6:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d8:	83 c7 01             	add    $0x1,%edi
  8004db:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004df:	0f be d0             	movsbl %al,%edx
  8004e2:	85 d2                	test   %edx,%edx
  8004e4:	74 4b                	je     800531 <vprintfmt+0x23f>
  8004e6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ea:	78 06                	js     8004f2 <vprintfmt+0x200>
  8004ec:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004f0:	78 1e                	js     800510 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004f2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004f6:	74 d1                	je     8004c9 <vprintfmt+0x1d7>
  8004f8:	0f be c0             	movsbl %al,%eax
  8004fb:	83 e8 20             	sub    $0x20,%eax
  8004fe:	83 f8 5e             	cmp    $0x5e,%eax
  800501:	76 c6                	jbe    8004c9 <vprintfmt+0x1d7>
					putch('?', putdat);
  800503:	83 ec 08             	sub    $0x8,%esp
  800506:	53                   	push   %ebx
  800507:	6a 3f                	push   $0x3f
  800509:	ff d6                	call   *%esi
  80050b:	83 c4 10             	add    $0x10,%esp
  80050e:	eb c3                	jmp    8004d3 <vprintfmt+0x1e1>
  800510:	89 cf                	mov    %ecx,%edi
  800512:	eb 0e                	jmp    800522 <vprintfmt+0x230>
				putch(' ', putdat);
  800514:	83 ec 08             	sub    $0x8,%esp
  800517:	53                   	push   %ebx
  800518:	6a 20                	push   $0x20
  80051a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80051c:	83 ef 01             	sub    $0x1,%edi
  80051f:	83 c4 10             	add    $0x10,%esp
  800522:	85 ff                	test   %edi,%edi
  800524:	7f ee                	jg     800514 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800526:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800529:	89 45 14             	mov    %eax,0x14(%ebp)
  80052c:	e9 67 01 00 00       	jmp    800698 <vprintfmt+0x3a6>
  800531:	89 cf                	mov    %ecx,%edi
  800533:	eb ed                	jmp    800522 <vprintfmt+0x230>
	if (lflag >= 2)
  800535:	83 f9 01             	cmp    $0x1,%ecx
  800538:	7f 1b                	jg     800555 <vprintfmt+0x263>
	else if (lflag)
  80053a:	85 c9                	test   %ecx,%ecx
  80053c:	74 63                	je     8005a1 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80053e:	8b 45 14             	mov    0x14(%ebp),%eax
  800541:	8b 00                	mov    (%eax),%eax
  800543:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800546:	99                   	cltd   
  800547:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80054a:	8b 45 14             	mov    0x14(%ebp),%eax
  80054d:	8d 40 04             	lea    0x4(%eax),%eax
  800550:	89 45 14             	mov    %eax,0x14(%ebp)
  800553:	eb 17                	jmp    80056c <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800555:	8b 45 14             	mov    0x14(%ebp),%eax
  800558:	8b 50 04             	mov    0x4(%eax),%edx
  80055b:	8b 00                	mov    (%eax),%eax
  80055d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800560:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800563:	8b 45 14             	mov    0x14(%ebp),%eax
  800566:	8d 40 08             	lea    0x8(%eax),%eax
  800569:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80056c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80056f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800572:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800577:	85 c9                	test   %ecx,%ecx
  800579:	0f 89 ff 00 00 00    	jns    80067e <vprintfmt+0x38c>
				putch('-', putdat);
  80057f:	83 ec 08             	sub    $0x8,%esp
  800582:	53                   	push   %ebx
  800583:	6a 2d                	push   $0x2d
  800585:	ff d6                	call   *%esi
				num = -(long long) num;
  800587:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80058a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80058d:	f7 da                	neg    %edx
  80058f:	83 d1 00             	adc    $0x0,%ecx
  800592:	f7 d9                	neg    %ecx
  800594:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800597:	b8 0a 00 00 00       	mov    $0xa,%eax
  80059c:	e9 dd 00 00 00       	jmp    80067e <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8005a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a4:	8b 00                	mov    (%eax),%eax
  8005a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a9:	99                   	cltd   
  8005aa:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8d 40 04             	lea    0x4(%eax),%eax
  8005b3:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b6:	eb b4                	jmp    80056c <vprintfmt+0x27a>
	if (lflag >= 2)
  8005b8:	83 f9 01             	cmp    $0x1,%ecx
  8005bb:	7f 1e                	jg     8005db <vprintfmt+0x2e9>
	else if (lflag)
  8005bd:	85 c9                	test   %ecx,%ecx
  8005bf:	74 32                	je     8005f3 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8005c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c4:	8b 10                	mov    (%eax),%edx
  8005c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005cb:	8d 40 04             	lea    0x4(%eax),%eax
  8005ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d1:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005d6:	e9 a3 00 00 00       	jmp    80067e <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8b 10                	mov    (%eax),%edx
  8005e0:	8b 48 04             	mov    0x4(%eax),%ecx
  8005e3:	8d 40 08             	lea    0x8(%eax),%eax
  8005e6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e9:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005ee:	e9 8b 00 00 00       	jmp    80067e <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8b 10                	mov    (%eax),%edx
  8005f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fd:	8d 40 04             	lea    0x4(%eax),%eax
  800600:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800603:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800608:	eb 74                	jmp    80067e <vprintfmt+0x38c>
	if (lflag >= 2)
  80060a:	83 f9 01             	cmp    $0x1,%ecx
  80060d:	7f 1b                	jg     80062a <vprintfmt+0x338>
	else if (lflag)
  80060f:	85 c9                	test   %ecx,%ecx
  800611:	74 2c                	je     80063f <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800613:	8b 45 14             	mov    0x14(%ebp),%eax
  800616:	8b 10                	mov    (%eax),%edx
  800618:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061d:	8d 40 04             	lea    0x4(%eax),%eax
  800620:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800623:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800628:	eb 54                	jmp    80067e <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80062a:	8b 45 14             	mov    0x14(%ebp),%eax
  80062d:	8b 10                	mov    (%eax),%edx
  80062f:	8b 48 04             	mov    0x4(%eax),%ecx
  800632:	8d 40 08             	lea    0x8(%eax),%eax
  800635:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800638:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  80063d:	eb 3f                	jmp    80067e <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8b 10                	mov    (%eax),%edx
  800644:	b9 00 00 00 00       	mov    $0x0,%ecx
  800649:	8d 40 04             	lea    0x4(%eax),%eax
  80064c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80064f:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800654:	eb 28                	jmp    80067e <vprintfmt+0x38c>
			putch('0', putdat);
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	53                   	push   %ebx
  80065a:	6a 30                	push   $0x30
  80065c:	ff d6                	call   *%esi
			putch('x', putdat);
  80065e:	83 c4 08             	add    $0x8,%esp
  800661:	53                   	push   %ebx
  800662:	6a 78                	push   $0x78
  800664:	ff d6                	call   *%esi
			num = (unsigned long long)
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8b 10                	mov    (%eax),%edx
  80066b:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800670:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800673:	8d 40 04             	lea    0x4(%eax),%eax
  800676:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800679:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80067e:	83 ec 0c             	sub    $0xc,%esp
  800681:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800685:	57                   	push   %edi
  800686:	ff 75 e0             	pushl  -0x20(%ebp)
  800689:	50                   	push   %eax
  80068a:	51                   	push   %ecx
  80068b:	52                   	push   %edx
  80068c:	89 da                	mov    %ebx,%edx
  80068e:	89 f0                	mov    %esi,%eax
  800690:	e8 72 fb ff ff       	call   800207 <printnum>
			break;
  800695:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800698:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {	
  80069b:	83 c7 01             	add    $0x1,%edi
  80069e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006a2:	83 f8 25             	cmp    $0x25,%eax
  8006a5:	0f 84 62 fc ff ff    	je     80030d <vprintfmt+0x1b>
			if (ch == '\0')										
  8006ab:	85 c0                	test   %eax,%eax
  8006ad:	0f 84 8b 00 00 00    	je     80073e <vprintfmt+0x44c>
			putch(ch, putdat);
  8006b3:	83 ec 08             	sub    $0x8,%esp
  8006b6:	53                   	push   %ebx
  8006b7:	50                   	push   %eax
  8006b8:	ff d6                	call   *%esi
  8006ba:	83 c4 10             	add    $0x10,%esp
  8006bd:	eb dc                	jmp    80069b <vprintfmt+0x3a9>
	if (lflag >= 2)
  8006bf:	83 f9 01             	cmp    $0x1,%ecx
  8006c2:	7f 1b                	jg     8006df <vprintfmt+0x3ed>
	else if (lflag)
  8006c4:	85 c9                	test   %ecx,%ecx
  8006c6:	74 2c                	je     8006f4 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  8006c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cb:	8b 10                	mov    (%eax),%edx
  8006cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d2:	8d 40 04             	lea    0x4(%eax),%eax
  8006d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d8:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006dd:	eb 9f                	jmp    80067e <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8006df:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e2:	8b 10                	mov    (%eax),%edx
  8006e4:	8b 48 04             	mov    0x4(%eax),%ecx
  8006e7:	8d 40 08             	lea    0x8(%eax),%eax
  8006ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ed:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006f2:	eb 8a                	jmp    80067e <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8006f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f7:	8b 10                	mov    (%eax),%edx
  8006f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006fe:	8d 40 04             	lea    0x4(%eax),%eax
  800701:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800704:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800709:	e9 70 ff ff ff       	jmp    80067e <vprintfmt+0x38c>
			putch(ch, putdat);
  80070e:	83 ec 08             	sub    $0x8,%esp
  800711:	53                   	push   %ebx
  800712:	6a 25                	push   $0x25
  800714:	ff d6                	call   *%esi
			break;
  800716:	83 c4 10             	add    $0x10,%esp
  800719:	e9 7a ff ff ff       	jmp    800698 <vprintfmt+0x3a6>
			putch('%', putdat);
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	53                   	push   %ebx
  800722:	6a 25                	push   $0x25
  800724:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800726:	83 c4 10             	add    $0x10,%esp
  800729:	89 f8                	mov    %edi,%eax
  80072b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80072f:	74 05                	je     800736 <vprintfmt+0x444>
  800731:	83 e8 01             	sub    $0x1,%eax
  800734:	eb f5                	jmp    80072b <vprintfmt+0x439>
  800736:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800739:	e9 5a ff ff ff       	jmp    800698 <vprintfmt+0x3a6>
}
  80073e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800741:	5b                   	pop    %ebx
  800742:	5e                   	pop    %esi
  800743:	5f                   	pop    %edi
  800744:	5d                   	pop    %ebp
  800745:	c3                   	ret    

00800746 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800746:	f3 0f 1e fb          	endbr32 
  80074a:	55                   	push   %ebp
  80074b:	89 e5                	mov    %esp,%ebp
  80074d:	83 ec 18             	sub    $0x18,%esp
  800750:	8b 45 08             	mov    0x8(%ebp),%eax
  800753:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800756:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800759:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80075d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800760:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800767:	85 c0                	test   %eax,%eax
  800769:	74 26                	je     800791 <vsnprintf+0x4b>
  80076b:	85 d2                	test   %edx,%edx
  80076d:	7e 22                	jle    800791 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80076f:	ff 75 14             	pushl  0x14(%ebp)
  800772:	ff 75 10             	pushl  0x10(%ebp)
  800775:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800778:	50                   	push   %eax
  800779:	68 b0 02 80 00       	push   $0x8002b0
  80077e:	e8 6f fb ff ff       	call   8002f2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800783:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800786:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800789:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078c:	83 c4 10             	add    $0x10,%esp
}
  80078f:	c9                   	leave  
  800790:	c3                   	ret    
		return -E_INVAL;
  800791:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800796:	eb f7                	jmp    80078f <vsnprintf+0x49>

00800798 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800798:	f3 0f 1e fb          	endbr32 
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a5:	50                   	push   %eax
  8007a6:	ff 75 10             	pushl  0x10(%ebp)
  8007a9:	ff 75 0c             	pushl  0xc(%ebp)
  8007ac:	ff 75 08             	pushl  0x8(%ebp)
  8007af:	e8 92 ff ff ff       	call   800746 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b4:	c9                   	leave  
  8007b5:	c3                   	ret    

008007b6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b6:	f3 0f 1e fb          	endbr32 
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c9:	74 05                	je     8007d0 <strlen+0x1a>
		n++;
  8007cb:	83 c0 01             	add    $0x1,%eax
  8007ce:	eb f5                	jmp    8007c5 <strlen+0xf>
	return n;
}
  8007d0:	5d                   	pop    %ebp
  8007d1:	c3                   	ret    

008007d2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d2:	f3 0f 1e fb          	endbr32 
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007dc:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007df:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e4:	39 d0                	cmp    %edx,%eax
  8007e6:	74 0d                	je     8007f5 <strnlen+0x23>
  8007e8:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007ec:	74 05                	je     8007f3 <strnlen+0x21>
		n++;
  8007ee:	83 c0 01             	add    $0x1,%eax
  8007f1:	eb f1                	jmp    8007e4 <strnlen+0x12>
  8007f3:	89 c2                	mov    %eax,%edx
	return n;
}
  8007f5:	89 d0                	mov    %edx,%eax
  8007f7:	5d                   	pop    %ebp
  8007f8:	c3                   	ret    

008007f9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f9:	f3 0f 1e fb          	endbr32 
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	53                   	push   %ebx
  800801:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800804:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800807:	b8 00 00 00 00       	mov    $0x0,%eax
  80080c:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800810:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800813:	83 c0 01             	add    $0x1,%eax
  800816:	84 d2                	test   %dl,%dl
  800818:	75 f2                	jne    80080c <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80081a:	89 c8                	mov    %ecx,%eax
  80081c:	5b                   	pop    %ebx
  80081d:	5d                   	pop    %ebp
  80081e:	c3                   	ret    

0080081f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80081f:	f3 0f 1e fb          	endbr32 
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	53                   	push   %ebx
  800827:	83 ec 10             	sub    $0x10,%esp
  80082a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80082d:	53                   	push   %ebx
  80082e:	e8 83 ff ff ff       	call   8007b6 <strlen>
  800833:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800836:	ff 75 0c             	pushl  0xc(%ebp)
  800839:	01 d8                	add    %ebx,%eax
  80083b:	50                   	push   %eax
  80083c:	e8 b8 ff ff ff       	call   8007f9 <strcpy>
	return dst;
}
  800841:	89 d8                	mov    %ebx,%eax
  800843:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800846:	c9                   	leave  
  800847:	c3                   	ret    

00800848 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800848:	f3 0f 1e fb          	endbr32 
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	56                   	push   %esi
  800850:	53                   	push   %ebx
  800851:	8b 75 08             	mov    0x8(%ebp),%esi
  800854:	8b 55 0c             	mov    0xc(%ebp),%edx
  800857:	89 f3                	mov    %esi,%ebx
  800859:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80085c:	89 f0                	mov    %esi,%eax
  80085e:	39 d8                	cmp    %ebx,%eax
  800860:	74 11                	je     800873 <strncpy+0x2b>
		*dst++ = *src;
  800862:	83 c0 01             	add    $0x1,%eax
  800865:	0f b6 0a             	movzbl (%edx),%ecx
  800868:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80086b:	80 f9 01             	cmp    $0x1,%cl
  80086e:	83 da ff             	sbb    $0xffffffff,%edx
  800871:	eb eb                	jmp    80085e <strncpy+0x16>
	}
	return ret;
}
  800873:	89 f0                	mov    %esi,%eax
  800875:	5b                   	pop    %ebx
  800876:	5e                   	pop    %esi
  800877:	5d                   	pop    %ebp
  800878:	c3                   	ret    

00800879 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800879:	f3 0f 1e fb          	endbr32 
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	56                   	push   %esi
  800881:	53                   	push   %ebx
  800882:	8b 75 08             	mov    0x8(%ebp),%esi
  800885:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800888:	8b 55 10             	mov    0x10(%ebp),%edx
  80088b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80088d:	85 d2                	test   %edx,%edx
  80088f:	74 21                	je     8008b2 <strlcpy+0x39>
  800891:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800895:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800897:	39 c2                	cmp    %eax,%edx
  800899:	74 14                	je     8008af <strlcpy+0x36>
  80089b:	0f b6 19             	movzbl (%ecx),%ebx
  80089e:	84 db                	test   %bl,%bl
  8008a0:	74 0b                	je     8008ad <strlcpy+0x34>
			*dst++ = *src++;
  8008a2:	83 c1 01             	add    $0x1,%ecx
  8008a5:	83 c2 01             	add    $0x1,%edx
  8008a8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008ab:	eb ea                	jmp    800897 <strlcpy+0x1e>
  8008ad:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008af:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b2:	29 f0                	sub    %esi,%eax
}
  8008b4:	5b                   	pop    %ebx
  8008b5:	5e                   	pop    %esi
  8008b6:	5d                   	pop    %ebp
  8008b7:	c3                   	ret    

008008b8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b8:	f3 0f 1e fb          	endbr32 
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c5:	0f b6 01             	movzbl (%ecx),%eax
  8008c8:	84 c0                	test   %al,%al
  8008ca:	74 0c                	je     8008d8 <strcmp+0x20>
  8008cc:	3a 02                	cmp    (%edx),%al
  8008ce:	75 08                	jne    8008d8 <strcmp+0x20>
		p++, q++;
  8008d0:	83 c1 01             	add    $0x1,%ecx
  8008d3:	83 c2 01             	add    $0x1,%edx
  8008d6:	eb ed                	jmp    8008c5 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d8:	0f b6 c0             	movzbl %al,%eax
  8008db:	0f b6 12             	movzbl (%edx),%edx
  8008de:	29 d0                	sub    %edx,%eax
}
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e2:	f3 0f 1e fb          	endbr32 
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	53                   	push   %ebx
  8008ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f0:	89 c3                	mov    %eax,%ebx
  8008f2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008f5:	eb 06                	jmp    8008fd <strncmp+0x1b>
		n--, p++, q++;
  8008f7:	83 c0 01             	add    $0x1,%eax
  8008fa:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008fd:	39 d8                	cmp    %ebx,%eax
  8008ff:	74 16                	je     800917 <strncmp+0x35>
  800901:	0f b6 08             	movzbl (%eax),%ecx
  800904:	84 c9                	test   %cl,%cl
  800906:	74 04                	je     80090c <strncmp+0x2a>
  800908:	3a 0a                	cmp    (%edx),%cl
  80090a:	74 eb                	je     8008f7 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80090c:	0f b6 00             	movzbl (%eax),%eax
  80090f:	0f b6 12             	movzbl (%edx),%edx
  800912:	29 d0                	sub    %edx,%eax
}
  800914:	5b                   	pop    %ebx
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    
		return 0;
  800917:	b8 00 00 00 00       	mov    $0x0,%eax
  80091c:	eb f6                	jmp    800914 <strncmp+0x32>

0080091e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80091e:	f3 0f 1e fb          	endbr32 
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80092c:	0f b6 10             	movzbl (%eax),%edx
  80092f:	84 d2                	test   %dl,%dl
  800931:	74 09                	je     80093c <strchr+0x1e>
		if (*s == c)
  800933:	38 ca                	cmp    %cl,%dl
  800935:	74 0a                	je     800941 <strchr+0x23>
	for (; *s; s++)
  800937:	83 c0 01             	add    $0x1,%eax
  80093a:	eb f0                	jmp    80092c <strchr+0xe>
			return (char *) s;
	return 0;
  80093c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800941:	5d                   	pop    %ebp
  800942:	c3                   	ret    

00800943 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800943:	f3 0f 1e fb          	endbr32 
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
  80094d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800951:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800954:	38 ca                	cmp    %cl,%dl
  800956:	74 09                	je     800961 <strfind+0x1e>
  800958:	84 d2                	test   %dl,%dl
  80095a:	74 05                	je     800961 <strfind+0x1e>
	for (; *s; s++)
  80095c:	83 c0 01             	add    $0x1,%eax
  80095f:	eb f0                	jmp    800951 <strfind+0xe>
			break;
	return (char *) s;
}
  800961:	5d                   	pop    %ebp
  800962:	c3                   	ret    

00800963 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800963:	f3 0f 1e fb          	endbr32 
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	57                   	push   %edi
  80096b:	56                   	push   %esi
  80096c:	53                   	push   %ebx
  80096d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800970:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800973:	85 c9                	test   %ecx,%ecx
  800975:	74 31                	je     8009a8 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800977:	89 f8                	mov    %edi,%eax
  800979:	09 c8                	or     %ecx,%eax
  80097b:	a8 03                	test   $0x3,%al
  80097d:	75 23                	jne    8009a2 <memset+0x3f>
		c &= 0xFF;
  80097f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800983:	89 d3                	mov    %edx,%ebx
  800985:	c1 e3 08             	shl    $0x8,%ebx
  800988:	89 d0                	mov    %edx,%eax
  80098a:	c1 e0 18             	shl    $0x18,%eax
  80098d:	89 d6                	mov    %edx,%esi
  80098f:	c1 e6 10             	shl    $0x10,%esi
  800992:	09 f0                	or     %esi,%eax
  800994:	09 c2                	or     %eax,%edx
  800996:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800998:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80099b:	89 d0                	mov    %edx,%eax
  80099d:	fc                   	cld    
  80099e:	f3 ab                	rep stos %eax,%es:(%edi)
  8009a0:	eb 06                	jmp    8009a8 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a5:	fc                   	cld    
  8009a6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009a8:	89 f8                	mov    %edi,%eax
  8009aa:	5b                   	pop    %ebx
  8009ab:	5e                   	pop    %esi
  8009ac:	5f                   	pop    %edi
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009af:	f3 0f 1e fb          	endbr32 
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	57                   	push   %edi
  8009b7:	56                   	push   %esi
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009be:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009c1:	39 c6                	cmp    %eax,%esi
  8009c3:	73 32                	jae    8009f7 <memmove+0x48>
  8009c5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c8:	39 c2                	cmp    %eax,%edx
  8009ca:	76 2b                	jbe    8009f7 <memmove+0x48>
		s += n;
		d += n;
  8009cc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cf:	89 fe                	mov    %edi,%esi
  8009d1:	09 ce                	or     %ecx,%esi
  8009d3:	09 d6                	or     %edx,%esi
  8009d5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009db:	75 0e                	jne    8009eb <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009dd:	83 ef 04             	sub    $0x4,%edi
  8009e0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009e3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009e6:	fd                   	std    
  8009e7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e9:	eb 09                	jmp    8009f4 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009eb:	83 ef 01             	sub    $0x1,%edi
  8009ee:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009f1:	fd                   	std    
  8009f2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009f4:	fc                   	cld    
  8009f5:	eb 1a                	jmp    800a11 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f7:	89 c2                	mov    %eax,%edx
  8009f9:	09 ca                	or     %ecx,%edx
  8009fb:	09 f2                	or     %esi,%edx
  8009fd:	f6 c2 03             	test   $0x3,%dl
  800a00:	75 0a                	jne    800a0c <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a02:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a05:	89 c7                	mov    %eax,%edi
  800a07:	fc                   	cld    
  800a08:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0a:	eb 05                	jmp    800a11 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a0c:	89 c7                	mov    %eax,%edi
  800a0e:	fc                   	cld    
  800a0f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a11:	5e                   	pop    %esi
  800a12:	5f                   	pop    %edi
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a15:	f3 0f 1e fb          	endbr32 
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a1f:	ff 75 10             	pushl  0x10(%ebp)
  800a22:	ff 75 0c             	pushl  0xc(%ebp)
  800a25:	ff 75 08             	pushl  0x8(%ebp)
  800a28:	e8 82 ff ff ff       	call   8009af <memmove>
}
  800a2d:	c9                   	leave  
  800a2e:	c3                   	ret    

00800a2f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a2f:	f3 0f 1e fb          	endbr32 
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	56                   	push   %esi
  800a37:	53                   	push   %ebx
  800a38:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3e:	89 c6                	mov    %eax,%esi
  800a40:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a43:	39 f0                	cmp    %esi,%eax
  800a45:	74 1c                	je     800a63 <memcmp+0x34>
		if (*s1 != *s2)
  800a47:	0f b6 08             	movzbl (%eax),%ecx
  800a4a:	0f b6 1a             	movzbl (%edx),%ebx
  800a4d:	38 d9                	cmp    %bl,%cl
  800a4f:	75 08                	jne    800a59 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a51:	83 c0 01             	add    $0x1,%eax
  800a54:	83 c2 01             	add    $0x1,%edx
  800a57:	eb ea                	jmp    800a43 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a59:	0f b6 c1             	movzbl %cl,%eax
  800a5c:	0f b6 db             	movzbl %bl,%ebx
  800a5f:	29 d8                	sub    %ebx,%eax
  800a61:	eb 05                	jmp    800a68 <memcmp+0x39>
	}

	return 0;
  800a63:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a68:	5b                   	pop    %ebx
  800a69:	5e                   	pop    %esi
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a6c:	f3 0f 1e fb          	endbr32 
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	8b 45 08             	mov    0x8(%ebp),%eax
  800a76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a79:	89 c2                	mov    %eax,%edx
  800a7b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a7e:	39 d0                	cmp    %edx,%eax
  800a80:	73 09                	jae    800a8b <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a82:	38 08                	cmp    %cl,(%eax)
  800a84:	74 05                	je     800a8b <memfind+0x1f>
	for (; s < ends; s++)
  800a86:	83 c0 01             	add    $0x1,%eax
  800a89:	eb f3                	jmp    800a7e <memfind+0x12>
			break;
	return (void *) s;
}
  800a8b:	5d                   	pop    %ebp
  800a8c:	c3                   	ret    

00800a8d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a8d:	f3 0f 1e fb          	endbr32 
  800a91:	55                   	push   %ebp
  800a92:	89 e5                	mov    %esp,%ebp
  800a94:	57                   	push   %edi
  800a95:	56                   	push   %esi
  800a96:	53                   	push   %ebx
  800a97:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a9d:	eb 03                	jmp    800aa2 <strtol+0x15>
		s++;
  800a9f:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800aa2:	0f b6 01             	movzbl (%ecx),%eax
  800aa5:	3c 20                	cmp    $0x20,%al
  800aa7:	74 f6                	je     800a9f <strtol+0x12>
  800aa9:	3c 09                	cmp    $0x9,%al
  800aab:	74 f2                	je     800a9f <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800aad:	3c 2b                	cmp    $0x2b,%al
  800aaf:	74 2a                	je     800adb <strtol+0x4e>
	int neg = 0;
  800ab1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ab6:	3c 2d                	cmp    $0x2d,%al
  800ab8:	74 2b                	je     800ae5 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aba:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ac0:	75 0f                	jne    800ad1 <strtol+0x44>
  800ac2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac5:	74 28                	je     800aef <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ac7:	85 db                	test   %ebx,%ebx
  800ac9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ace:	0f 44 d8             	cmove  %eax,%ebx
  800ad1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad6:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ad9:	eb 46                	jmp    800b21 <strtol+0x94>
		s++;
  800adb:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ade:	bf 00 00 00 00       	mov    $0x0,%edi
  800ae3:	eb d5                	jmp    800aba <strtol+0x2d>
		s++, neg = 1;
  800ae5:	83 c1 01             	add    $0x1,%ecx
  800ae8:	bf 01 00 00 00       	mov    $0x1,%edi
  800aed:	eb cb                	jmp    800aba <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aef:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800af3:	74 0e                	je     800b03 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800af5:	85 db                	test   %ebx,%ebx
  800af7:	75 d8                	jne    800ad1 <strtol+0x44>
		s++, base = 8;
  800af9:	83 c1 01             	add    $0x1,%ecx
  800afc:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b01:	eb ce                	jmp    800ad1 <strtol+0x44>
		s += 2, base = 16;
  800b03:	83 c1 02             	add    $0x2,%ecx
  800b06:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b0b:	eb c4                	jmp    800ad1 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b0d:	0f be d2             	movsbl %dl,%edx
  800b10:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b13:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b16:	7d 3a                	jge    800b52 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b18:	83 c1 01             	add    $0x1,%ecx
  800b1b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b1f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b21:	0f b6 11             	movzbl (%ecx),%edx
  800b24:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b27:	89 f3                	mov    %esi,%ebx
  800b29:	80 fb 09             	cmp    $0x9,%bl
  800b2c:	76 df                	jbe    800b0d <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b2e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b31:	89 f3                	mov    %esi,%ebx
  800b33:	80 fb 19             	cmp    $0x19,%bl
  800b36:	77 08                	ja     800b40 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b38:	0f be d2             	movsbl %dl,%edx
  800b3b:	83 ea 57             	sub    $0x57,%edx
  800b3e:	eb d3                	jmp    800b13 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b40:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b43:	89 f3                	mov    %esi,%ebx
  800b45:	80 fb 19             	cmp    $0x19,%bl
  800b48:	77 08                	ja     800b52 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b4a:	0f be d2             	movsbl %dl,%edx
  800b4d:	83 ea 37             	sub    $0x37,%edx
  800b50:	eb c1                	jmp    800b13 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b52:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b56:	74 05                	je     800b5d <strtol+0xd0>
		*endptr = (char *) s;
  800b58:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b5b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b5d:	89 c2                	mov    %eax,%edx
  800b5f:	f7 da                	neg    %edx
  800b61:	85 ff                	test   %edi,%edi
  800b63:	0f 45 c2             	cmovne %edx,%eax
}
  800b66:	5b                   	pop    %ebx
  800b67:	5e                   	pop    %esi
  800b68:	5f                   	pop    %edi
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b6b:	f3 0f 1e fb          	endbr32 
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	57                   	push   %edi
  800b73:	56                   	push   %esi
  800b74:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800b75:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b80:	89 c3                	mov    %eax,%ebx
  800b82:	89 c7                	mov    %eax,%edi
  800b84:	89 c6                	mov    %eax,%esi
  800b86:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b88:	5b                   	pop    %ebx
  800b89:	5e                   	pop    %esi
  800b8a:	5f                   	pop    %edi
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <sys_cgetc>:

int
sys_cgetc(void)
{
  800b8d:	f3 0f 1e fb          	endbr32 
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	57                   	push   %edi
  800b95:	56                   	push   %esi
  800b96:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800b97:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9c:	b8 01 00 00 00       	mov    $0x1,%eax
  800ba1:	89 d1                	mov    %edx,%ecx
  800ba3:	89 d3                	mov    %edx,%ebx
  800ba5:	89 d7                	mov    %edx,%edi
  800ba7:	89 d6                	mov    %edx,%esi
  800ba9:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bab:	5b                   	pop    %ebx
  800bac:	5e                   	pop    %esi
  800bad:	5f                   	pop    %edi
  800bae:	5d                   	pop    %ebp
  800baf:	c3                   	ret    

00800bb0 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bb0:	f3 0f 1e fb          	endbr32 
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	53                   	push   %ebx
  800bba:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800bbd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc5:	b8 03 00 00 00       	mov    $0x3,%eax
  800bca:	89 cb                	mov    %ecx,%ebx
  800bcc:	89 cf                	mov    %ecx,%edi
  800bce:	89 ce                	mov    %ecx,%esi
  800bd0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bd2:	85 c0                	test   %eax,%eax
  800bd4:	7f 08                	jg     800bde <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bde:	83 ec 0c             	sub    $0xc,%esp
  800be1:	50                   	push   %eax
  800be2:	6a 03                	push   $0x3
  800be4:	68 44 16 80 00       	push   $0x801644
  800be9:	6a 23                	push   $0x23
  800beb:	68 61 16 80 00       	push   $0x801661
  800bf0:	e8 b2 04 00 00       	call   8010a7 <_panic>

00800bf5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bf5:	f3 0f 1e fb          	endbr32 
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800bff:	ba 00 00 00 00       	mov    $0x0,%edx
  800c04:	b8 02 00 00 00       	mov    $0x2,%eax
  800c09:	89 d1                	mov    %edx,%ecx
  800c0b:	89 d3                	mov    %edx,%ebx
  800c0d:	89 d7                	mov    %edx,%edi
  800c0f:	89 d6                	mov    %edx,%esi
  800c11:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5f                   	pop    %edi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <sys_yield>:

void
sys_yield(void)
{
  800c18:	f3 0f 1e fb          	endbr32 
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
  800c1f:	57                   	push   %edi
  800c20:	56                   	push   %esi
  800c21:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c22:	ba 00 00 00 00       	mov    $0x0,%edx
  800c27:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c2c:	89 d1                	mov    %edx,%ecx
  800c2e:	89 d3                	mov    %edx,%ebx
  800c30:	89 d7                	mov    %edx,%edi
  800c32:	89 d6                	mov    %edx,%esi
  800c34:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c3b:	f3 0f 1e fb          	endbr32 
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	57                   	push   %edi
  800c43:	56                   	push   %esi
  800c44:	53                   	push   %ebx
  800c45:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c48:	be 00 00 00 00       	mov    $0x0,%esi
  800c4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c53:	b8 04 00 00 00       	mov    $0x4,%eax
  800c58:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c5b:	89 f7                	mov    %esi,%edi
  800c5d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	7f 08                	jg     800c6b <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c66:	5b                   	pop    %ebx
  800c67:	5e                   	pop    %esi
  800c68:	5f                   	pop    %edi
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6b:	83 ec 0c             	sub    $0xc,%esp
  800c6e:	50                   	push   %eax
  800c6f:	6a 04                	push   $0x4
  800c71:	68 44 16 80 00       	push   $0x801644
  800c76:	6a 23                	push   $0x23
  800c78:	68 61 16 80 00       	push   $0x801661
  800c7d:	e8 25 04 00 00       	call   8010a7 <_panic>

00800c82 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c82:	f3 0f 1e fb          	endbr32 
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
  800c8c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c95:	b8 05 00 00 00       	mov    $0x5,%eax
  800c9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c9d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca0:	8b 75 18             	mov    0x18(%ebp),%esi
  800ca3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca5:	85 c0                	test   %eax,%eax
  800ca7:	7f 08                	jg     800cb1 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ca9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cac:	5b                   	pop    %ebx
  800cad:	5e                   	pop    %esi
  800cae:	5f                   	pop    %edi
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb1:	83 ec 0c             	sub    $0xc,%esp
  800cb4:	50                   	push   %eax
  800cb5:	6a 05                	push   $0x5
  800cb7:	68 44 16 80 00       	push   $0x801644
  800cbc:	6a 23                	push   $0x23
  800cbe:	68 61 16 80 00       	push   $0x801661
  800cc3:	e8 df 03 00 00       	call   8010a7 <_panic>

00800cc8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cc8:	f3 0f 1e fb          	endbr32 
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
  800cd2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800cd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cda:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce0:	b8 06 00 00 00       	mov    $0x6,%eax
  800ce5:	89 df                	mov    %ebx,%edi
  800ce7:	89 de                	mov    %ebx,%esi
  800ce9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ceb:	85 c0                	test   %eax,%eax
  800ced:	7f 08                	jg     800cf7 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf2:	5b                   	pop    %ebx
  800cf3:	5e                   	pop    %esi
  800cf4:	5f                   	pop    %edi
  800cf5:	5d                   	pop    %ebp
  800cf6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf7:	83 ec 0c             	sub    $0xc,%esp
  800cfa:	50                   	push   %eax
  800cfb:	6a 06                	push   $0x6
  800cfd:	68 44 16 80 00       	push   $0x801644
  800d02:	6a 23                	push   $0x23
  800d04:	68 61 16 80 00       	push   $0x801661
  800d09:	e8 99 03 00 00       	call   8010a7 <_panic>

00800d0e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d0e:	f3 0f 1e fb          	endbr32 
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	57                   	push   %edi
  800d16:	56                   	push   %esi
  800d17:	53                   	push   %ebx
  800d18:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d20:	8b 55 08             	mov    0x8(%ebp),%edx
  800d23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d26:	b8 08 00 00 00       	mov    $0x8,%eax
  800d2b:	89 df                	mov    %ebx,%edi
  800d2d:	89 de                	mov    %ebx,%esi
  800d2f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d31:	85 c0                	test   %eax,%eax
  800d33:	7f 08                	jg     800d3d <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d38:	5b                   	pop    %ebx
  800d39:	5e                   	pop    %esi
  800d3a:	5f                   	pop    %edi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3d:	83 ec 0c             	sub    $0xc,%esp
  800d40:	50                   	push   %eax
  800d41:	6a 08                	push   $0x8
  800d43:	68 44 16 80 00       	push   $0x801644
  800d48:	6a 23                	push   $0x23
  800d4a:	68 61 16 80 00       	push   $0x801661
  800d4f:	e8 53 03 00 00       	call   8010a7 <_panic>

00800d54 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d54:	f3 0f 1e fb          	endbr32 
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
  800d5b:	57                   	push   %edi
  800d5c:	56                   	push   %esi
  800d5d:	53                   	push   %ebx
  800d5e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d61:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d66:	8b 55 08             	mov    0x8(%ebp),%edx
  800d69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6c:	b8 09 00 00 00       	mov    $0x9,%eax
  800d71:	89 df                	mov    %ebx,%edi
  800d73:	89 de                	mov    %ebx,%esi
  800d75:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d77:	85 c0                	test   %eax,%eax
  800d79:	7f 08                	jg     800d83 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7e:	5b                   	pop    %ebx
  800d7f:	5e                   	pop    %esi
  800d80:	5f                   	pop    %edi
  800d81:	5d                   	pop    %ebp
  800d82:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d83:	83 ec 0c             	sub    $0xc,%esp
  800d86:	50                   	push   %eax
  800d87:	6a 09                	push   $0x9
  800d89:	68 44 16 80 00       	push   $0x801644
  800d8e:	6a 23                	push   $0x23
  800d90:	68 61 16 80 00       	push   $0x801661
  800d95:	e8 0d 03 00 00       	call   8010a7 <_panic>

00800d9a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d9a:	f3 0f 1e fb          	endbr32 
  800d9e:	55                   	push   %ebp
  800d9f:	89 e5                	mov    %esp,%ebp
  800da1:	57                   	push   %edi
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800da4:	8b 55 08             	mov    0x8(%ebp),%edx
  800da7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800daa:	b8 0b 00 00 00       	mov    $0xb,%eax
  800daf:	be 00 00 00 00       	mov    $0x0,%esi
  800db4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dba:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dbc:	5b                   	pop    %ebx
  800dbd:	5e                   	pop    %esi
  800dbe:	5f                   	pop    %edi
  800dbf:	5d                   	pop    %ebp
  800dc0:	c3                   	ret    

00800dc1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc1:	f3 0f 1e fb          	endbr32 
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	57                   	push   %edi
  800dc9:	56                   	push   %esi
  800dca:	53                   	push   %ebx
  800dcb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800dce:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ddb:	89 cb                	mov    %ecx,%ebx
  800ddd:	89 cf                	mov    %ecx,%edi
  800ddf:	89 ce                	mov    %ecx,%esi
  800de1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800de3:	85 c0                	test   %eax,%eax
  800de5:	7f 08                	jg     800def <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800de7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dea:	5b                   	pop    %ebx
  800deb:	5e                   	pop    %esi
  800dec:	5f                   	pop    %edi
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800def:	83 ec 0c             	sub    $0xc,%esp
  800df2:	50                   	push   %eax
  800df3:	6a 0c                	push   $0xc
  800df5:	68 44 16 80 00       	push   $0x801644
  800dfa:	6a 23                	push   $0x23
  800dfc:	68 61 16 80 00       	push   $0x801661
  800e01:	e8 a1 02 00 00       	call   8010a7 <_panic>

00800e06 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e06:	f3 0f 1e fb          	endbr32 
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	53                   	push   %ebx
  800e0e:	83 ec 04             	sub    $0x4,%esp
  800e11:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e14:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpt[PGNUM(addr)] & PTE_COW))) { 
  800e16:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e1a:	74 74                	je     800e90 <pgfault+0x8a>
  800e1c:	89 d8                	mov    %ebx,%eax
  800e1e:	c1 e8 0c             	shr    $0xc,%eax
  800e21:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e28:	f6 c4 08             	test   $0x8,%ah
  800e2b:	74 63                	je     800e90 <pgfault+0x8a>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  800e2d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_map(0, addr, 0, PFTEMP, PTE_U|PTE_P)) < 0)		
  800e33:	83 ec 0c             	sub    $0xc,%esp
  800e36:	6a 05                	push   $0x5
  800e38:	68 00 f0 7f 00       	push   $0x7ff000
  800e3d:	6a 00                	push   $0x0
  800e3f:	53                   	push   %ebx
  800e40:	6a 00                	push   $0x0
  800e42:	e8 3b fe ff ff       	call   800c82 <sys_page_map>
  800e47:	83 c4 20             	add    $0x20,%esp
  800e4a:	85 c0                	test   %eax,%eax
  800e4c:	78 56                	js     800ea4 <pgfault+0x9e>
		panic("sys_page_map: %e", r);
	if ((r = sys_page_alloc(0, addr, PTE_P|PTE_U|PTE_W)) < 0)	
  800e4e:	83 ec 04             	sub    $0x4,%esp
  800e51:	6a 07                	push   $0x7
  800e53:	53                   	push   %ebx
  800e54:	6a 00                	push   $0x0
  800e56:	e8 e0 fd ff ff       	call   800c3b <sys_page_alloc>
  800e5b:	83 c4 10             	add    $0x10,%esp
  800e5e:	85 c0                	test   %eax,%eax
  800e60:	78 54                	js     800eb6 <pgfault+0xb0>
		panic("sys_page_alloc: %e", r);
	memmove(addr, PFTEMP, PGSIZE);							
  800e62:	83 ec 04             	sub    $0x4,%esp
  800e65:	68 00 10 00 00       	push   $0x1000
  800e6a:	68 00 f0 7f 00       	push   $0x7ff000
  800e6f:	53                   	push   %ebx
  800e70:	e8 3a fb ff ff       	call   8009af <memmove>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)				
  800e75:	83 c4 08             	add    $0x8,%esp
  800e78:	68 00 f0 7f 00       	push   $0x7ff000
  800e7d:	6a 00                	push   $0x0
  800e7f:	e8 44 fe ff ff       	call   800cc8 <sys_page_unmap>
  800e84:	83 c4 10             	add    $0x10,%esp
  800e87:	85 c0                	test   %eax,%eax
  800e89:	78 3d                	js     800ec8 <pgfault+0xc2>
		panic("sys_page_unmap: %e", r);
}
  800e8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e8e:	c9                   	leave  
  800e8f:	c3                   	ret    
		panic("pgfault():not cow");
  800e90:	83 ec 04             	sub    $0x4,%esp
  800e93:	68 6f 16 80 00       	push   $0x80166f
  800e98:	6a 1d                	push   $0x1d
  800e9a:	68 81 16 80 00       	push   $0x801681
  800e9f:	e8 03 02 00 00       	call   8010a7 <_panic>
		panic("sys_page_map: %e", r);
  800ea4:	50                   	push   %eax
  800ea5:	68 8c 16 80 00       	push   $0x80168c
  800eaa:	6a 2a                	push   $0x2a
  800eac:	68 81 16 80 00       	push   $0x801681
  800eb1:	e8 f1 01 00 00       	call   8010a7 <_panic>
		panic("sys_page_alloc: %e", r);
  800eb6:	50                   	push   %eax
  800eb7:	68 9d 16 80 00       	push   $0x80169d
  800ebc:	6a 2c                	push   $0x2c
  800ebe:	68 81 16 80 00       	push   $0x801681
  800ec3:	e8 df 01 00 00       	call   8010a7 <_panic>
		panic("sys_page_unmap: %e", r);
  800ec8:	50                   	push   %eax
  800ec9:	68 b0 16 80 00       	push   $0x8016b0
  800ece:	6a 2f                	push   $0x2f
  800ed0:	68 81 16 80 00       	push   $0x801681
  800ed5:	e8 cd 01 00 00       	call   8010a7 <_panic>

00800eda <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800eda:	f3 0f 1e fb          	endbr32 
  800ede:	55                   	push   %ebp
  800edf:	89 e5                	mov    %esp,%ebp
  800ee1:	57                   	push   %edi
  800ee2:	56                   	push   %esi
  800ee3:	53                   	push   %ebx
  800ee4:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	extern void _pgfault_upcall(void);
	set_pgfault_handler(pgfault);	
  800ee7:	68 06 0e 80 00       	push   $0x800e06
  800eec:	e8 00 02 00 00       	call   8010f1 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ef1:	b8 07 00 00 00       	mov    $0x7,%eax
  800ef6:	cd 30                	int    $0x30
  800ef8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();	
	if (envid == 0) {				
  800efb:	83 c4 10             	add    $0x10,%esp
  800efe:	85 c0                	test   %eax,%eax
  800f00:	74 12                	je     800f14 <fork+0x3a>
  800f02:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	if (envid < 0) {
  800f04:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f08:	78 29                	js     800f33 <fork+0x59>
		panic("sys_exofork: %e", envid);
	}

	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  800f0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f0f:	e9 80 00 00 00       	jmp    800f94 <fork+0xba>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f14:	e8 dc fc ff ff       	call   800bf5 <sys_getenvid>
  800f19:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f1e:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  800f24:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f29:	a3 60 40 80 00       	mov    %eax,0x804060
		return 0;
  800f2e:	e9 27 01 00 00       	jmp    80105a <fork+0x180>
		panic("sys_exofork: %e", envid);
  800f33:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f36:	68 c3 16 80 00       	push   $0x8016c3
  800f3b:	6a 6b                	push   $0x6b
  800f3d:	68 81 16 80 00       	push   $0x801681
  800f42:	e8 60 01 00 00       	call   8010a7 <_panic>
		if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800f47:	83 ec 0c             	sub    $0xc,%esp
  800f4a:	68 05 08 00 00       	push   $0x805
  800f4f:	56                   	push   %esi
  800f50:	57                   	push   %edi
  800f51:	56                   	push   %esi
  800f52:	6a 00                	push   $0x0
  800f54:	e8 29 fd ff ff       	call   800c82 <sys_page_map>
  800f59:	83 c4 20             	add    $0x20,%esp
  800f5c:	85 c0                	test   %eax,%eax
  800f5e:	0f 88 96 00 00 00    	js     800ffa <fork+0x120>
		if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800f64:	83 ec 0c             	sub    $0xc,%esp
  800f67:	68 05 08 00 00       	push   $0x805
  800f6c:	56                   	push   %esi
  800f6d:	6a 00                	push   $0x0
  800f6f:	56                   	push   %esi
  800f70:	6a 00                	push   $0x0
  800f72:	e8 0b fd ff ff       	call   800c82 <sys_page_map>
  800f77:	83 c4 20             	add    $0x20,%esp
  800f7a:	85 c0                	test   %eax,%eax
  800f7c:	0f 88 8a 00 00 00    	js     80100c <fork+0x132>
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  800f82:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f88:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f8e:	0f 84 8a 00 00 00    	je     80101e <fork+0x144>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) 
  800f94:	89 d8                	mov    %ebx,%eax
  800f96:	c1 e8 16             	shr    $0x16,%eax
  800f99:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fa0:	a8 01                	test   $0x1,%al
  800fa2:	74 de                	je     800f82 <fork+0xa8>
  800fa4:	89 d8                	mov    %ebx,%eax
  800fa6:	c1 e8 0c             	shr    $0xc,%eax
  800fa9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fb0:	f6 c2 01             	test   $0x1,%dl
  800fb3:	74 cd                	je     800f82 <fork+0xa8>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  800fb5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fbc:	f6 c2 04             	test   $0x4,%dl
  800fbf:	74 c1                	je     800f82 <fork+0xa8>
	void *addr = (void*) (pn * PGSIZE);
  800fc1:	89 c6                	mov    %eax,%esi
  800fc3:	c1 e6 0c             	shl    $0xc,%esi
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) { 
  800fc6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fcd:	f6 c2 02             	test   $0x2,%dl
  800fd0:	0f 85 71 ff ff ff    	jne    800f47 <fork+0x6d>
  800fd6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fdd:	f6 c4 08             	test   $0x8,%ah
  800fe0:	0f 85 61 ff ff ff    	jne    800f47 <fork+0x6d>
		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);	
  800fe6:	83 ec 0c             	sub    $0xc,%esp
  800fe9:	6a 05                	push   $0x5
  800feb:	56                   	push   %esi
  800fec:	57                   	push   %edi
  800fed:	56                   	push   %esi
  800fee:	6a 00                	push   $0x0
  800ff0:	e8 8d fc ff ff       	call   800c82 <sys_page_map>
  800ff5:	83 c4 20             	add    $0x20,%esp
  800ff8:	eb 88                	jmp    800f82 <fork+0xa8>
			panic("sys_page_map：%e", r);
  800ffa:	50                   	push   %eax
  800ffb:	68 d3 16 80 00       	push   $0x8016d3
  801000:	6a 46                	push   $0x46
  801002:	68 81 16 80 00       	push   $0x801681
  801007:	e8 9b 00 00 00       	call   8010a7 <_panic>
			panic("sys_page_map：%e", r);
  80100c:	50                   	push   %eax
  80100d:	68 d3 16 80 00       	push   $0x8016d3
  801012:	6a 48                	push   $0x48
  801014:	68 81 16 80 00       	push   $0x801681
  801019:	e8 89 00 00 00       	call   8010a7 <_panic>
			duppage(envid, PGNUM(addr));	
		}
	}
	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)	
  80101e:	83 ec 04             	sub    $0x4,%esp
  801021:	6a 07                	push   $0x7
  801023:	68 00 f0 bf ee       	push   $0xeebff000
  801028:	ff 75 e4             	pushl  -0x1c(%ebp)
  80102b:	e8 0b fc ff ff       	call   800c3b <sys_page_alloc>
  801030:	83 c4 10             	add    $0x10,%esp
  801033:	85 c0                	test   %eax,%eax
  801035:	78 2e                	js     801065 <fork+0x18b>
		panic("sys_page_alloc: %e", r);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);		
  801037:	83 ec 08             	sub    $0x8,%esp
  80103a:	68 4e 11 80 00       	push   $0x80114e
  80103f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801042:	57                   	push   %edi
  801043:	e8 0c fd ff ff       	call   800d54 <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)	
  801048:	83 c4 08             	add    $0x8,%esp
  80104b:	6a 02                	push   $0x2
  80104d:	57                   	push   %edi
  80104e:	e8 bb fc ff ff       	call   800d0e <sys_env_set_status>
  801053:	83 c4 10             	add    $0x10,%esp
  801056:	85 c0                	test   %eax,%eax
  801058:	78 1d                	js     801077 <fork+0x19d>
		panic("sys_env_set_status: %e", r);
	return envid;
}
  80105a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80105d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801060:	5b                   	pop    %ebx
  801061:	5e                   	pop    %esi
  801062:	5f                   	pop    %edi
  801063:	5d                   	pop    %ebp
  801064:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  801065:	50                   	push   %eax
  801066:	68 9d 16 80 00       	push   $0x80169d
  80106b:	6a 77                	push   $0x77
  80106d:	68 81 16 80 00       	push   $0x801681
  801072:	e8 30 00 00 00       	call   8010a7 <_panic>
		panic("sys_env_set_status: %e", r);
  801077:	50                   	push   %eax
  801078:	68 e5 16 80 00       	push   $0x8016e5
  80107d:	6a 7b                	push   $0x7b
  80107f:	68 81 16 80 00       	push   $0x801681
  801084:	e8 1e 00 00 00       	call   8010a7 <_panic>

00801089 <sfork>:

// Challenge!
int
sfork(void)
{
  801089:	f3 0f 1e fb          	endbr32 
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
  801090:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801093:	68 fc 16 80 00       	push   $0x8016fc
  801098:	68 83 00 00 00       	push   $0x83
  80109d:	68 81 16 80 00       	push   $0x801681
  8010a2:	e8 00 00 00 00       	call   8010a7 <_panic>

008010a7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010a7:	f3 0f 1e fb          	endbr32 
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
  8010ae:	56                   	push   %esi
  8010af:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010b0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010b3:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8010b9:	e8 37 fb ff ff       	call   800bf5 <sys_getenvid>
  8010be:	83 ec 0c             	sub    $0xc,%esp
  8010c1:	ff 75 0c             	pushl  0xc(%ebp)
  8010c4:	ff 75 08             	pushl  0x8(%ebp)
  8010c7:	56                   	push   %esi
  8010c8:	50                   	push   %eax
  8010c9:	68 14 17 80 00       	push   $0x801714
  8010ce:	e8 1c f1 ff ff       	call   8001ef <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010d3:	83 c4 18             	add    $0x18,%esp
  8010d6:	53                   	push   %ebx
  8010d7:	ff 75 10             	pushl  0x10(%ebp)
  8010da:	e8 bb f0 ff ff       	call   80019a <vcprintf>
	cprintf("\n");
  8010df:	c7 04 24 ef 13 80 00 	movl   $0x8013ef,(%esp)
  8010e6:	e8 04 f1 ff ff       	call   8001ef <cprintf>
  8010eb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010ee:	cc                   	int3   
  8010ef:	eb fd                	jmp    8010ee <_panic+0x47>

008010f1 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8010f1:	f3 0f 1e fb          	endbr32 
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8010fb:	83 3d 64 40 80 00 00 	cmpl   $0x0,0x804064
  801102:	74 0a                	je     80110e <set_pgfault_handler+0x1d>
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);		//系统调用，设置进程的env_pgfault_upcall属性
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801104:	8b 45 08             	mov    0x8(%ebp),%eax
  801107:	a3 64 40 80 00       	mov    %eax,0x804064
}
  80110c:	c9                   	leave  
  80110d:	c3                   	ret    
		int r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_W | PTE_U | PTE_P);	//为当前进程分配异常栈
  80110e:	83 ec 04             	sub    $0x4,%esp
  801111:	6a 07                	push   $0x7
  801113:	68 00 f0 bf ee       	push   $0xeebff000
  801118:	6a 00                	push   $0x0
  80111a:	e8 1c fb ff ff       	call   800c3b <sys_page_alloc>
		if (r < 0) {
  80111f:	83 c4 10             	add    $0x10,%esp
  801122:	85 c0                	test   %eax,%eax
  801124:	78 14                	js     80113a <set_pgfault_handler+0x49>
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);		//系统调用，设置进程的env_pgfault_upcall属性
  801126:	83 ec 08             	sub    $0x8,%esp
  801129:	68 4e 11 80 00       	push   $0x80114e
  80112e:	6a 00                	push   $0x0
  801130:	e8 1f fc ff ff       	call   800d54 <sys_env_set_pgfault_upcall>
  801135:	83 c4 10             	add    $0x10,%esp
  801138:	eb ca                	jmp    801104 <set_pgfault_handler+0x13>
			panic("set_pgfault_handler:sys_page_alloc failed");;
  80113a:	83 ec 04             	sub    $0x4,%esp
  80113d:	68 38 17 80 00       	push   $0x801738
  801142:	6a 22                	push   $0x22
  801144:	68 62 17 80 00       	push   $0x801762
  801149:	e8 59 ff ff ff       	call   8010a7 <_panic>

0080114e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80114e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80114f:	a1 64 40 80 00       	mov    0x804064,%eax
	call *%eax				
  801154:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801156:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp			
  801159:	83 c4 08             	add    $0x8,%esp
	movl 40(%esp), %eax 	
  80115c:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 32(%esp), %ecx 	
  801160:	8b 4c 24 20          	mov    0x20(%esp),%ecx
	movl %ecx, -4(%eax) 	
  801164:	89 48 fc             	mov    %ecx,-0x4(%eax)
	popal
  801167:	61                   	popa   
	addl $4, %esp		
  801168:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popfl
  80116b:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80116c:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	lea -4(%esp), %esp	
  80116d:	8d 64 24 fc          	lea    -0x4(%esp),%esp
	ret
  801171:	c3                   	ret    
  801172:	66 90                	xchg   %ax,%ax
  801174:	66 90                	xchg   %ax,%ax
  801176:	66 90                	xchg   %ax,%ax
  801178:	66 90                	xchg   %ax,%ax
  80117a:	66 90                	xchg   %ax,%ax
  80117c:	66 90                	xchg   %ax,%ax
  80117e:	66 90                	xchg   %ax,%ax

00801180 <__udivdi3>:
  801180:	f3 0f 1e fb          	endbr32 
  801184:	55                   	push   %ebp
  801185:	57                   	push   %edi
  801186:	56                   	push   %esi
  801187:	53                   	push   %ebx
  801188:	83 ec 1c             	sub    $0x1c,%esp
  80118b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80118f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801193:	8b 74 24 34          	mov    0x34(%esp),%esi
  801197:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80119b:	85 d2                	test   %edx,%edx
  80119d:	75 19                	jne    8011b8 <__udivdi3+0x38>
  80119f:	39 f3                	cmp    %esi,%ebx
  8011a1:	76 4d                	jbe    8011f0 <__udivdi3+0x70>
  8011a3:	31 ff                	xor    %edi,%edi
  8011a5:	89 e8                	mov    %ebp,%eax
  8011a7:	89 f2                	mov    %esi,%edx
  8011a9:	f7 f3                	div    %ebx
  8011ab:	89 fa                	mov    %edi,%edx
  8011ad:	83 c4 1c             	add    $0x1c,%esp
  8011b0:	5b                   	pop    %ebx
  8011b1:	5e                   	pop    %esi
  8011b2:	5f                   	pop    %edi
  8011b3:	5d                   	pop    %ebp
  8011b4:	c3                   	ret    
  8011b5:	8d 76 00             	lea    0x0(%esi),%esi
  8011b8:	39 f2                	cmp    %esi,%edx
  8011ba:	76 14                	jbe    8011d0 <__udivdi3+0x50>
  8011bc:	31 ff                	xor    %edi,%edi
  8011be:	31 c0                	xor    %eax,%eax
  8011c0:	89 fa                	mov    %edi,%edx
  8011c2:	83 c4 1c             	add    $0x1c,%esp
  8011c5:	5b                   	pop    %ebx
  8011c6:	5e                   	pop    %esi
  8011c7:	5f                   	pop    %edi
  8011c8:	5d                   	pop    %ebp
  8011c9:	c3                   	ret    
  8011ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011d0:	0f bd fa             	bsr    %edx,%edi
  8011d3:	83 f7 1f             	xor    $0x1f,%edi
  8011d6:	75 48                	jne    801220 <__udivdi3+0xa0>
  8011d8:	39 f2                	cmp    %esi,%edx
  8011da:	72 06                	jb     8011e2 <__udivdi3+0x62>
  8011dc:	31 c0                	xor    %eax,%eax
  8011de:	39 eb                	cmp    %ebp,%ebx
  8011e0:	77 de                	ja     8011c0 <__udivdi3+0x40>
  8011e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8011e7:	eb d7                	jmp    8011c0 <__udivdi3+0x40>
  8011e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011f0:	89 d9                	mov    %ebx,%ecx
  8011f2:	85 db                	test   %ebx,%ebx
  8011f4:	75 0b                	jne    801201 <__udivdi3+0x81>
  8011f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8011fb:	31 d2                	xor    %edx,%edx
  8011fd:	f7 f3                	div    %ebx
  8011ff:	89 c1                	mov    %eax,%ecx
  801201:	31 d2                	xor    %edx,%edx
  801203:	89 f0                	mov    %esi,%eax
  801205:	f7 f1                	div    %ecx
  801207:	89 c6                	mov    %eax,%esi
  801209:	89 e8                	mov    %ebp,%eax
  80120b:	89 f7                	mov    %esi,%edi
  80120d:	f7 f1                	div    %ecx
  80120f:	89 fa                	mov    %edi,%edx
  801211:	83 c4 1c             	add    $0x1c,%esp
  801214:	5b                   	pop    %ebx
  801215:	5e                   	pop    %esi
  801216:	5f                   	pop    %edi
  801217:	5d                   	pop    %ebp
  801218:	c3                   	ret    
  801219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801220:	89 f9                	mov    %edi,%ecx
  801222:	b8 20 00 00 00       	mov    $0x20,%eax
  801227:	29 f8                	sub    %edi,%eax
  801229:	d3 e2                	shl    %cl,%edx
  80122b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80122f:	89 c1                	mov    %eax,%ecx
  801231:	89 da                	mov    %ebx,%edx
  801233:	d3 ea                	shr    %cl,%edx
  801235:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801239:	09 d1                	or     %edx,%ecx
  80123b:	89 f2                	mov    %esi,%edx
  80123d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801241:	89 f9                	mov    %edi,%ecx
  801243:	d3 e3                	shl    %cl,%ebx
  801245:	89 c1                	mov    %eax,%ecx
  801247:	d3 ea                	shr    %cl,%edx
  801249:	89 f9                	mov    %edi,%ecx
  80124b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80124f:	89 eb                	mov    %ebp,%ebx
  801251:	d3 e6                	shl    %cl,%esi
  801253:	89 c1                	mov    %eax,%ecx
  801255:	d3 eb                	shr    %cl,%ebx
  801257:	09 de                	or     %ebx,%esi
  801259:	89 f0                	mov    %esi,%eax
  80125b:	f7 74 24 08          	divl   0x8(%esp)
  80125f:	89 d6                	mov    %edx,%esi
  801261:	89 c3                	mov    %eax,%ebx
  801263:	f7 64 24 0c          	mull   0xc(%esp)
  801267:	39 d6                	cmp    %edx,%esi
  801269:	72 15                	jb     801280 <__udivdi3+0x100>
  80126b:	89 f9                	mov    %edi,%ecx
  80126d:	d3 e5                	shl    %cl,%ebp
  80126f:	39 c5                	cmp    %eax,%ebp
  801271:	73 04                	jae    801277 <__udivdi3+0xf7>
  801273:	39 d6                	cmp    %edx,%esi
  801275:	74 09                	je     801280 <__udivdi3+0x100>
  801277:	89 d8                	mov    %ebx,%eax
  801279:	31 ff                	xor    %edi,%edi
  80127b:	e9 40 ff ff ff       	jmp    8011c0 <__udivdi3+0x40>
  801280:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801283:	31 ff                	xor    %edi,%edi
  801285:	e9 36 ff ff ff       	jmp    8011c0 <__udivdi3+0x40>
  80128a:	66 90                	xchg   %ax,%ax
  80128c:	66 90                	xchg   %ax,%ax
  80128e:	66 90                	xchg   %ax,%ax

00801290 <__umoddi3>:
  801290:	f3 0f 1e fb          	endbr32 
  801294:	55                   	push   %ebp
  801295:	57                   	push   %edi
  801296:	56                   	push   %esi
  801297:	53                   	push   %ebx
  801298:	83 ec 1c             	sub    $0x1c,%esp
  80129b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80129f:	8b 74 24 30          	mov    0x30(%esp),%esi
  8012a3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8012a7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8012ab:	85 c0                	test   %eax,%eax
  8012ad:	75 19                	jne    8012c8 <__umoddi3+0x38>
  8012af:	39 df                	cmp    %ebx,%edi
  8012b1:	76 5d                	jbe    801310 <__umoddi3+0x80>
  8012b3:	89 f0                	mov    %esi,%eax
  8012b5:	89 da                	mov    %ebx,%edx
  8012b7:	f7 f7                	div    %edi
  8012b9:	89 d0                	mov    %edx,%eax
  8012bb:	31 d2                	xor    %edx,%edx
  8012bd:	83 c4 1c             	add    $0x1c,%esp
  8012c0:	5b                   	pop    %ebx
  8012c1:	5e                   	pop    %esi
  8012c2:	5f                   	pop    %edi
  8012c3:	5d                   	pop    %ebp
  8012c4:	c3                   	ret    
  8012c5:	8d 76 00             	lea    0x0(%esi),%esi
  8012c8:	89 f2                	mov    %esi,%edx
  8012ca:	39 d8                	cmp    %ebx,%eax
  8012cc:	76 12                	jbe    8012e0 <__umoddi3+0x50>
  8012ce:	89 f0                	mov    %esi,%eax
  8012d0:	89 da                	mov    %ebx,%edx
  8012d2:	83 c4 1c             	add    $0x1c,%esp
  8012d5:	5b                   	pop    %ebx
  8012d6:	5e                   	pop    %esi
  8012d7:	5f                   	pop    %edi
  8012d8:	5d                   	pop    %ebp
  8012d9:	c3                   	ret    
  8012da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012e0:	0f bd e8             	bsr    %eax,%ebp
  8012e3:	83 f5 1f             	xor    $0x1f,%ebp
  8012e6:	75 50                	jne    801338 <__umoddi3+0xa8>
  8012e8:	39 d8                	cmp    %ebx,%eax
  8012ea:	0f 82 e0 00 00 00    	jb     8013d0 <__umoddi3+0x140>
  8012f0:	89 d9                	mov    %ebx,%ecx
  8012f2:	39 f7                	cmp    %esi,%edi
  8012f4:	0f 86 d6 00 00 00    	jbe    8013d0 <__umoddi3+0x140>
  8012fa:	89 d0                	mov    %edx,%eax
  8012fc:	89 ca                	mov    %ecx,%edx
  8012fe:	83 c4 1c             	add    $0x1c,%esp
  801301:	5b                   	pop    %ebx
  801302:	5e                   	pop    %esi
  801303:	5f                   	pop    %edi
  801304:	5d                   	pop    %ebp
  801305:	c3                   	ret    
  801306:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80130d:	8d 76 00             	lea    0x0(%esi),%esi
  801310:	89 fd                	mov    %edi,%ebp
  801312:	85 ff                	test   %edi,%edi
  801314:	75 0b                	jne    801321 <__umoddi3+0x91>
  801316:	b8 01 00 00 00       	mov    $0x1,%eax
  80131b:	31 d2                	xor    %edx,%edx
  80131d:	f7 f7                	div    %edi
  80131f:	89 c5                	mov    %eax,%ebp
  801321:	89 d8                	mov    %ebx,%eax
  801323:	31 d2                	xor    %edx,%edx
  801325:	f7 f5                	div    %ebp
  801327:	89 f0                	mov    %esi,%eax
  801329:	f7 f5                	div    %ebp
  80132b:	89 d0                	mov    %edx,%eax
  80132d:	31 d2                	xor    %edx,%edx
  80132f:	eb 8c                	jmp    8012bd <__umoddi3+0x2d>
  801331:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801338:	89 e9                	mov    %ebp,%ecx
  80133a:	ba 20 00 00 00       	mov    $0x20,%edx
  80133f:	29 ea                	sub    %ebp,%edx
  801341:	d3 e0                	shl    %cl,%eax
  801343:	89 44 24 08          	mov    %eax,0x8(%esp)
  801347:	89 d1                	mov    %edx,%ecx
  801349:	89 f8                	mov    %edi,%eax
  80134b:	d3 e8                	shr    %cl,%eax
  80134d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801351:	89 54 24 04          	mov    %edx,0x4(%esp)
  801355:	8b 54 24 04          	mov    0x4(%esp),%edx
  801359:	09 c1                	or     %eax,%ecx
  80135b:	89 d8                	mov    %ebx,%eax
  80135d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801361:	89 e9                	mov    %ebp,%ecx
  801363:	d3 e7                	shl    %cl,%edi
  801365:	89 d1                	mov    %edx,%ecx
  801367:	d3 e8                	shr    %cl,%eax
  801369:	89 e9                	mov    %ebp,%ecx
  80136b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80136f:	d3 e3                	shl    %cl,%ebx
  801371:	89 c7                	mov    %eax,%edi
  801373:	89 d1                	mov    %edx,%ecx
  801375:	89 f0                	mov    %esi,%eax
  801377:	d3 e8                	shr    %cl,%eax
  801379:	89 e9                	mov    %ebp,%ecx
  80137b:	89 fa                	mov    %edi,%edx
  80137d:	d3 e6                	shl    %cl,%esi
  80137f:	09 d8                	or     %ebx,%eax
  801381:	f7 74 24 08          	divl   0x8(%esp)
  801385:	89 d1                	mov    %edx,%ecx
  801387:	89 f3                	mov    %esi,%ebx
  801389:	f7 64 24 0c          	mull   0xc(%esp)
  80138d:	89 c6                	mov    %eax,%esi
  80138f:	89 d7                	mov    %edx,%edi
  801391:	39 d1                	cmp    %edx,%ecx
  801393:	72 06                	jb     80139b <__umoddi3+0x10b>
  801395:	75 10                	jne    8013a7 <__umoddi3+0x117>
  801397:	39 c3                	cmp    %eax,%ebx
  801399:	73 0c                	jae    8013a7 <__umoddi3+0x117>
  80139b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80139f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8013a3:	89 d7                	mov    %edx,%edi
  8013a5:	89 c6                	mov    %eax,%esi
  8013a7:	89 ca                	mov    %ecx,%edx
  8013a9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8013ae:	29 f3                	sub    %esi,%ebx
  8013b0:	19 fa                	sbb    %edi,%edx
  8013b2:	89 d0                	mov    %edx,%eax
  8013b4:	d3 e0                	shl    %cl,%eax
  8013b6:	89 e9                	mov    %ebp,%ecx
  8013b8:	d3 eb                	shr    %cl,%ebx
  8013ba:	d3 ea                	shr    %cl,%edx
  8013bc:	09 d8                	or     %ebx,%eax
  8013be:	83 c4 1c             	add    $0x1c,%esp
  8013c1:	5b                   	pop    %ebx
  8013c2:	5e                   	pop    %esi
  8013c3:	5f                   	pop    %edi
  8013c4:	5d                   	pop    %ebp
  8013c5:	c3                   	ret    
  8013c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013cd:	8d 76 00             	lea    0x0(%esi),%esi
  8013d0:	29 fe                	sub    %edi,%esi
  8013d2:	19 c3                	sbb    %eax,%ebx
  8013d4:	89 f2                	mov    %esi,%edx
  8013d6:	89 d9                	mov    %ebx,%ecx
  8013d8:	e9 1d ff ff ff       	jmp    8012fa <__umoddi3+0x6a>
