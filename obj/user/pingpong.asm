
obj/user/pingpong:     file format elf32-i386


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
  80002c:	e8 93 00 00 00       	call   8000c4 <libmain>
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
  80003a:	57                   	push   %edi
  80003b:	56                   	push   %esi
  80003c:	53                   	push   %ebx
  80003d:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  800040:	e8 6a 0e 00 00       	call   800eaf <fork>
  800045:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800048:	85 c0                	test   %eax,%eax
  80004a:	75 4f                	jne    80009b <umain+0x68>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80004c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	6a 00                	push   $0x0
  800054:	6a 00                	push   $0x0
  800056:	56                   	push   %esi
  800057:	e8 20 10 00 00       	call   80107c <ipc_recv>
  80005c:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  80005e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800061:	e8 64 0b 00 00       	call   800bca <sys_getenvid>
  800066:	57                   	push   %edi
  800067:	53                   	push   %ebx
  800068:	50                   	push   %eax
  800069:	68 d6 14 80 00       	push   $0x8014d6
  80006e:	e8 51 01 00 00       	call   8001c4 <cprintf>
		if (i == 10)
  800073:	83 c4 20             	add    $0x20,%esp
  800076:	83 fb 0a             	cmp    $0xa,%ebx
  800079:	74 18                	je     800093 <umain+0x60>
			return;
		i++;
  80007b:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  80007e:	6a 00                	push   $0x0
  800080:	6a 00                	push   $0x0
  800082:	53                   	push   %ebx
  800083:	ff 75 e4             	pushl  -0x1c(%ebp)
  800086:	e8 5e 10 00 00       	call   8010e9 <ipc_send>
		if (i == 10)
  80008b:	83 c4 10             	add    $0x10,%esp
  80008e:	83 fb 0a             	cmp    $0xa,%ebx
  800091:	75 bc                	jne    80004f <umain+0x1c>
			return;
	}

}
  800093:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5f                   	pop    %edi
  800099:	5d                   	pop    %ebp
  80009a:	c3                   	ret    
  80009b:	89 c3                	mov    %eax,%ebx
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80009d:	e8 28 0b 00 00       	call   800bca <sys_getenvid>
  8000a2:	83 ec 04             	sub    $0x4,%esp
  8000a5:	53                   	push   %ebx
  8000a6:	50                   	push   %eax
  8000a7:	68 c0 14 80 00       	push   $0x8014c0
  8000ac:	e8 13 01 00 00       	call   8001c4 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000b1:	6a 00                	push   $0x0
  8000b3:	6a 00                	push   $0x0
  8000b5:	6a 00                	push   $0x0
  8000b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000ba:	e8 2a 10 00 00       	call   8010e9 <ipc_send>
  8000bf:	83 c4 20             	add    $0x20,%esp
  8000c2:	eb 88                	jmp    80004c <umain+0x19>

008000c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c4:	f3 0f 1e fb          	endbr32 
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	56                   	push   %esi
  8000cc:	53                   	push   %ebx
  8000cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8000d3:	e8 f2 0a 00 00       	call   800bca <sys_getenvid>
	thisenv = envs + ENVX(envid);
  8000d8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000dd:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  8000e3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e8:	a3 60 40 80 00       	mov    %eax,0x804060

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ed:	85 db                	test   %ebx,%ebx
  8000ef:	7e 07                	jle    8000f8 <libmain+0x34>
		binaryname = argv[0];
  8000f1:	8b 06                	mov    (%esi),%eax
  8000f3:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f8:	83 ec 08             	sub    $0x8,%esp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	e8 31 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800102:	e8 0a 00 00 00       	call   800111 <exit>
}
  800107:	83 c4 10             	add    $0x10,%esp
  80010a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010d:	5b                   	pop    %ebx
  80010e:	5e                   	pop    %esi
  80010f:	5d                   	pop    %ebp
  800110:	c3                   	ret    

00800111 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800111:	f3 0f 1e fb          	endbr32 
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80011b:	6a 00                	push   $0x0
  80011d:	e8 63 0a 00 00       	call   800b85 <sys_env_destroy>
}
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	c9                   	leave  
  800126:	c3                   	ret    

00800127 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800127:	f3 0f 1e fb          	endbr32 
  80012b:	55                   	push   %ebp
  80012c:	89 e5                	mov    %esp,%ebp
  80012e:	53                   	push   %ebx
  80012f:	83 ec 04             	sub    $0x4,%esp
  800132:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800135:	8b 13                	mov    (%ebx),%edx
  800137:	8d 42 01             	lea    0x1(%edx),%eax
  80013a:	89 03                	mov    %eax,(%ebx)
  80013c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80013f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800143:	3d ff 00 00 00       	cmp    $0xff,%eax
  800148:	74 09                	je     800153 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80014a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80014e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800151:	c9                   	leave  
  800152:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800153:	83 ec 08             	sub    $0x8,%esp
  800156:	68 ff 00 00 00       	push   $0xff
  80015b:	8d 43 08             	lea    0x8(%ebx),%eax
  80015e:	50                   	push   %eax
  80015f:	e8 dc 09 00 00       	call   800b40 <sys_cputs>
		b->idx = 0;
  800164:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80016a:	83 c4 10             	add    $0x10,%esp
  80016d:	eb db                	jmp    80014a <putch+0x23>

0080016f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80016f:	f3 0f 1e fb          	endbr32 
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80017c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800183:	00 00 00 
	b.cnt = 0;
  800186:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80018d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800190:	ff 75 0c             	pushl  0xc(%ebp)
  800193:	ff 75 08             	pushl  0x8(%ebp)
  800196:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80019c:	50                   	push   %eax
  80019d:	68 27 01 80 00       	push   $0x800127
  8001a2:	e8 20 01 00 00       	call   8002c7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a7:	83 c4 08             	add    $0x8,%esp
  8001aa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001b0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b6:	50                   	push   %eax
  8001b7:	e8 84 09 00 00       	call   800b40 <sys_cputs>

	return b.cnt;
}
  8001bc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c2:	c9                   	leave  
  8001c3:	c3                   	ret    

008001c4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c4:	f3 0f 1e fb          	endbr32 
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ce:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d1:	50                   	push   %eax
  8001d2:	ff 75 08             	pushl  0x8(%ebp)
  8001d5:	e8 95 ff ff ff       	call   80016f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001da:	c9                   	leave  
  8001db:	c3                   	ret    

008001dc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	57                   	push   %edi
  8001e0:	56                   	push   %esi
  8001e1:	53                   	push   %ebx
  8001e2:	83 ec 1c             	sub    $0x1c,%esp
  8001e5:	89 c7                	mov    %eax,%edi
  8001e7:	89 d6                	mov    %edx,%esi
  8001e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ef:	89 d1                	mov    %edx,%ecx
  8001f1:	89 c2                	mov    %eax,%edx
  8001f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001f6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8001fc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001ff:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800202:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800209:	39 c2                	cmp    %eax,%edx
  80020b:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80020e:	72 3e                	jb     80024e <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800210:	83 ec 0c             	sub    $0xc,%esp
  800213:	ff 75 18             	pushl  0x18(%ebp)
  800216:	83 eb 01             	sub    $0x1,%ebx
  800219:	53                   	push   %ebx
  80021a:	50                   	push   %eax
  80021b:	83 ec 08             	sub    $0x8,%esp
  80021e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800221:	ff 75 e0             	pushl  -0x20(%ebp)
  800224:	ff 75 dc             	pushl  -0x24(%ebp)
  800227:	ff 75 d8             	pushl  -0x28(%ebp)
  80022a:	e8 21 10 00 00       	call   801250 <__udivdi3>
  80022f:	83 c4 18             	add    $0x18,%esp
  800232:	52                   	push   %edx
  800233:	50                   	push   %eax
  800234:	89 f2                	mov    %esi,%edx
  800236:	89 f8                	mov    %edi,%eax
  800238:	e8 9f ff ff ff       	call   8001dc <printnum>
  80023d:	83 c4 20             	add    $0x20,%esp
  800240:	eb 13                	jmp    800255 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800242:	83 ec 08             	sub    $0x8,%esp
  800245:	56                   	push   %esi
  800246:	ff 75 18             	pushl  0x18(%ebp)
  800249:	ff d7                	call   *%edi
  80024b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80024e:	83 eb 01             	sub    $0x1,%ebx
  800251:	85 db                	test   %ebx,%ebx
  800253:	7f ed                	jg     800242 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800255:	83 ec 08             	sub    $0x8,%esp
  800258:	56                   	push   %esi
  800259:	83 ec 04             	sub    $0x4,%esp
  80025c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025f:	ff 75 e0             	pushl  -0x20(%ebp)
  800262:	ff 75 dc             	pushl  -0x24(%ebp)
  800265:	ff 75 d8             	pushl  -0x28(%ebp)
  800268:	e8 f3 10 00 00       	call   801360 <__umoddi3>
  80026d:	83 c4 14             	add    $0x14,%esp
  800270:	0f be 80 f3 14 80 00 	movsbl 0x8014f3(%eax),%eax
  800277:	50                   	push   %eax
  800278:	ff d7                	call   *%edi
}
  80027a:	83 c4 10             	add    $0x10,%esp
  80027d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800280:	5b                   	pop    %ebx
  800281:	5e                   	pop    %esi
  800282:	5f                   	pop    %edi
  800283:	5d                   	pop    %ebp
  800284:	c3                   	ret    

00800285 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800285:	f3 0f 1e fb          	endbr32 
  800289:	55                   	push   %ebp
  80028a:	89 e5                	mov    %esp,%ebp
  80028c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80028f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800293:	8b 10                	mov    (%eax),%edx
  800295:	3b 50 04             	cmp    0x4(%eax),%edx
  800298:	73 0a                	jae    8002a4 <sprintputch+0x1f>
		*b->buf++ = ch;
  80029a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80029d:	89 08                	mov    %ecx,(%eax)
  80029f:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a2:	88 02                	mov    %al,(%edx)
}
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    

008002a6 <printfmt>:
{
  8002a6:	f3 0f 1e fb          	endbr32 
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002b0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b3:	50                   	push   %eax
  8002b4:	ff 75 10             	pushl  0x10(%ebp)
  8002b7:	ff 75 0c             	pushl  0xc(%ebp)
  8002ba:	ff 75 08             	pushl  0x8(%ebp)
  8002bd:	e8 05 00 00 00       	call   8002c7 <vprintfmt>
}
  8002c2:	83 c4 10             	add    $0x10,%esp
  8002c5:	c9                   	leave  
  8002c6:	c3                   	ret    

008002c7 <vprintfmt>:
{
  8002c7:	f3 0f 1e fb          	endbr32 
  8002cb:	55                   	push   %ebp
  8002cc:	89 e5                	mov    %esp,%ebp
  8002ce:	57                   	push   %edi
  8002cf:	56                   	push   %esi
  8002d0:	53                   	push   %ebx
  8002d1:	83 ec 3c             	sub    $0x3c,%esp
  8002d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002da:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002dd:	e9 8e 03 00 00       	jmp    800670 <vprintfmt+0x3a9>
		padc = ' ';
  8002e2:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002e6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002ed:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002f4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002fb:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800300:	8d 47 01             	lea    0x1(%edi),%eax
  800303:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800306:	0f b6 17             	movzbl (%edi),%edx
  800309:	8d 42 dd             	lea    -0x23(%edx),%eax
  80030c:	3c 55                	cmp    $0x55,%al
  80030e:	0f 87 df 03 00 00    	ja     8006f3 <vprintfmt+0x42c>
  800314:	0f b6 c0             	movzbl %al,%eax
  800317:	3e ff 24 85 c0 15 80 	notrack jmp *0x8015c0(,%eax,4)
  80031e:	00 
  80031f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800322:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800326:	eb d8                	jmp    800300 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80032b:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80032f:	eb cf                	jmp    800300 <vprintfmt+0x39>
  800331:	0f b6 d2             	movzbl %dl,%edx
  800334:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800337:	b8 00 00 00 00       	mov    $0x0,%eax
  80033c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80033f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800342:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800346:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800349:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80034c:	83 f9 09             	cmp    $0x9,%ecx
  80034f:	77 55                	ja     8003a6 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800351:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800354:	eb e9                	jmp    80033f <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800356:	8b 45 14             	mov    0x14(%ebp),%eax
  800359:	8b 00                	mov    (%eax),%eax
  80035b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80035e:	8b 45 14             	mov    0x14(%ebp),%eax
  800361:	8d 40 04             	lea    0x4(%eax),%eax
  800364:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800367:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80036a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80036e:	79 90                	jns    800300 <vprintfmt+0x39>
				width = precision, precision = -1;
  800370:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800373:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800376:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80037d:	eb 81                	jmp    800300 <vprintfmt+0x39>
  80037f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800382:	85 c0                	test   %eax,%eax
  800384:	ba 00 00 00 00       	mov    $0x0,%edx
  800389:	0f 49 d0             	cmovns %eax,%edx
  80038c:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80038f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800392:	e9 69 ff ff ff       	jmp    800300 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800397:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80039a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003a1:	e9 5a ff ff ff       	jmp    800300 <vprintfmt+0x39>
  8003a6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ac:	eb bc                	jmp    80036a <vprintfmt+0xa3>
			lflag++;
  8003ae:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003b4:	e9 47 ff ff ff       	jmp    800300 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bc:	8d 78 04             	lea    0x4(%eax),%edi
  8003bf:	83 ec 08             	sub    $0x8,%esp
  8003c2:	53                   	push   %ebx
  8003c3:	ff 30                	pushl  (%eax)
  8003c5:	ff d6                	call   *%esi
			break;
  8003c7:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003ca:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003cd:	e9 9b 02 00 00       	jmp    80066d <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  8003d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d5:	8d 78 04             	lea    0x4(%eax),%edi
  8003d8:	8b 00                	mov    (%eax),%eax
  8003da:	99                   	cltd   
  8003db:	31 d0                	xor    %edx,%eax
  8003dd:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003df:	83 f8 08             	cmp    $0x8,%eax
  8003e2:	7f 23                	jg     800407 <vprintfmt+0x140>
  8003e4:	8b 14 85 20 17 80 00 	mov    0x801720(,%eax,4),%edx
  8003eb:	85 d2                	test   %edx,%edx
  8003ed:	74 18                	je     800407 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003ef:	52                   	push   %edx
  8003f0:	68 14 15 80 00       	push   $0x801514
  8003f5:	53                   	push   %ebx
  8003f6:	56                   	push   %esi
  8003f7:	e8 aa fe ff ff       	call   8002a6 <printfmt>
  8003fc:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003ff:	89 7d 14             	mov    %edi,0x14(%ebp)
  800402:	e9 66 02 00 00       	jmp    80066d <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800407:	50                   	push   %eax
  800408:	68 0b 15 80 00       	push   $0x80150b
  80040d:	53                   	push   %ebx
  80040e:	56                   	push   %esi
  80040f:	e8 92 fe ff ff       	call   8002a6 <printfmt>
  800414:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800417:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80041a:	e9 4e 02 00 00       	jmp    80066d <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  80041f:	8b 45 14             	mov    0x14(%ebp),%eax
  800422:	83 c0 04             	add    $0x4,%eax
  800425:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800428:	8b 45 14             	mov    0x14(%ebp),%eax
  80042b:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80042d:	85 d2                	test   %edx,%edx
  80042f:	b8 04 15 80 00       	mov    $0x801504,%eax
  800434:	0f 45 c2             	cmovne %edx,%eax
  800437:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80043a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80043e:	7e 06                	jle    800446 <vprintfmt+0x17f>
  800440:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800444:	75 0d                	jne    800453 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800446:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800449:	89 c7                	mov    %eax,%edi
  80044b:	03 45 e0             	add    -0x20(%ebp),%eax
  80044e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800451:	eb 55                	jmp    8004a8 <vprintfmt+0x1e1>
  800453:	83 ec 08             	sub    $0x8,%esp
  800456:	ff 75 d8             	pushl  -0x28(%ebp)
  800459:	ff 75 cc             	pushl  -0x34(%ebp)
  80045c:	e8 46 03 00 00       	call   8007a7 <strnlen>
  800461:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800464:	29 c2                	sub    %eax,%edx
  800466:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800469:	83 c4 10             	add    $0x10,%esp
  80046c:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80046e:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800472:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800475:	85 ff                	test   %edi,%edi
  800477:	7e 11                	jle    80048a <vprintfmt+0x1c3>
					putch(padc, putdat);
  800479:	83 ec 08             	sub    $0x8,%esp
  80047c:	53                   	push   %ebx
  80047d:	ff 75 e0             	pushl  -0x20(%ebp)
  800480:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800482:	83 ef 01             	sub    $0x1,%edi
  800485:	83 c4 10             	add    $0x10,%esp
  800488:	eb eb                	jmp    800475 <vprintfmt+0x1ae>
  80048a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80048d:	85 d2                	test   %edx,%edx
  80048f:	b8 00 00 00 00       	mov    $0x0,%eax
  800494:	0f 49 c2             	cmovns %edx,%eax
  800497:	29 c2                	sub    %eax,%edx
  800499:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80049c:	eb a8                	jmp    800446 <vprintfmt+0x17f>
					putch(ch, putdat);
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	53                   	push   %ebx
  8004a2:	52                   	push   %edx
  8004a3:	ff d6                	call   *%esi
  8004a5:	83 c4 10             	add    $0x10,%esp
  8004a8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ab:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ad:	83 c7 01             	add    $0x1,%edi
  8004b0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004b4:	0f be d0             	movsbl %al,%edx
  8004b7:	85 d2                	test   %edx,%edx
  8004b9:	74 4b                	je     800506 <vprintfmt+0x23f>
  8004bb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004bf:	78 06                	js     8004c7 <vprintfmt+0x200>
  8004c1:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004c5:	78 1e                	js     8004e5 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004c7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004cb:	74 d1                	je     80049e <vprintfmt+0x1d7>
  8004cd:	0f be c0             	movsbl %al,%eax
  8004d0:	83 e8 20             	sub    $0x20,%eax
  8004d3:	83 f8 5e             	cmp    $0x5e,%eax
  8004d6:	76 c6                	jbe    80049e <vprintfmt+0x1d7>
					putch('?', putdat);
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	53                   	push   %ebx
  8004dc:	6a 3f                	push   $0x3f
  8004de:	ff d6                	call   *%esi
  8004e0:	83 c4 10             	add    $0x10,%esp
  8004e3:	eb c3                	jmp    8004a8 <vprintfmt+0x1e1>
  8004e5:	89 cf                	mov    %ecx,%edi
  8004e7:	eb 0e                	jmp    8004f7 <vprintfmt+0x230>
				putch(' ', putdat);
  8004e9:	83 ec 08             	sub    $0x8,%esp
  8004ec:	53                   	push   %ebx
  8004ed:	6a 20                	push   $0x20
  8004ef:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004f1:	83 ef 01             	sub    $0x1,%edi
  8004f4:	83 c4 10             	add    $0x10,%esp
  8004f7:	85 ff                	test   %edi,%edi
  8004f9:	7f ee                	jg     8004e9 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004fb:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004fe:	89 45 14             	mov    %eax,0x14(%ebp)
  800501:	e9 67 01 00 00       	jmp    80066d <vprintfmt+0x3a6>
  800506:	89 cf                	mov    %ecx,%edi
  800508:	eb ed                	jmp    8004f7 <vprintfmt+0x230>
	if (lflag >= 2)
  80050a:	83 f9 01             	cmp    $0x1,%ecx
  80050d:	7f 1b                	jg     80052a <vprintfmt+0x263>
	else if (lflag)
  80050f:	85 c9                	test   %ecx,%ecx
  800511:	74 63                	je     800576 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800513:	8b 45 14             	mov    0x14(%ebp),%eax
  800516:	8b 00                	mov    (%eax),%eax
  800518:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051b:	99                   	cltd   
  80051c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80051f:	8b 45 14             	mov    0x14(%ebp),%eax
  800522:	8d 40 04             	lea    0x4(%eax),%eax
  800525:	89 45 14             	mov    %eax,0x14(%ebp)
  800528:	eb 17                	jmp    800541 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80052a:	8b 45 14             	mov    0x14(%ebp),%eax
  80052d:	8b 50 04             	mov    0x4(%eax),%edx
  800530:	8b 00                	mov    (%eax),%eax
  800532:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800535:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800538:	8b 45 14             	mov    0x14(%ebp),%eax
  80053b:	8d 40 08             	lea    0x8(%eax),%eax
  80053e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800541:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800544:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800547:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80054c:	85 c9                	test   %ecx,%ecx
  80054e:	0f 89 ff 00 00 00    	jns    800653 <vprintfmt+0x38c>
				putch('-', putdat);
  800554:	83 ec 08             	sub    $0x8,%esp
  800557:	53                   	push   %ebx
  800558:	6a 2d                	push   $0x2d
  80055a:	ff d6                	call   *%esi
				num = -(long long) num;
  80055c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80055f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800562:	f7 da                	neg    %edx
  800564:	83 d1 00             	adc    $0x0,%ecx
  800567:	f7 d9                	neg    %ecx
  800569:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80056c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800571:	e9 dd 00 00 00       	jmp    800653 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8b 00                	mov    (%eax),%eax
  80057b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057e:	99                   	cltd   
  80057f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	8d 40 04             	lea    0x4(%eax),%eax
  800588:	89 45 14             	mov    %eax,0x14(%ebp)
  80058b:	eb b4                	jmp    800541 <vprintfmt+0x27a>
	if (lflag >= 2)
  80058d:	83 f9 01             	cmp    $0x1,%ecx
  800590:	7f 1e                	jg     8005b0 <vprintfmt+0x2e9>
	else if (lflag)
  800592:	85 c9                	test   %ecx,%ecx
  800594:	74 32                	je     8005c8 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800596:	8b 45 14             	mov    0x14(%ebp),%eax
  800599:	8b 10                	mov    (%eax),%edx
  80059b:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a0:	8d 40 04             	lea    0x4(%eax),%eax
  8005a3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005a6:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005ab:	e9 a3 00 00 00       	jmp    800653 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8b 10                	mov    (%eax),%edx
  8005b5:	8b 48 04             	mov    0x4(%eax),%ecx
  8005b8:	8d 40 08             	lea    0x8(%eax),%eax
  8005bb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005be:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005c3:	e9 8b 00 00 00       	jmp    800653 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8b 10                	mov    (%eax),%edx
  8005cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d2:	8d 40 04             	lea    0x4(%eax),%eax
  8005d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d8:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005dd:	eb 74                	jmp    800653 <vprintfmt+0x38c>
	if (lflag >= 2)
  8005df:	83 f9 01             	cmp    $0x1,%ecx
  8005e2:	7f 1b                	jg     8005ff <vprintfmt+0x338>
	else if (lflag)
  8005e4:	85 c9                	test   %ecx,%ecx
  8005e6:	74 2c                	je     800614 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8b 10                	mov    (%eax),%edx
  8005ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f2:	8d 40 04             	lea    0x4(%eax),%eax
  8005f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005f8:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  8005fd:	eb 54                	jmp    800653 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800602:	8b 10                	mov    (%eax),%edx
  800604:	8b 48 04             	mov    0x4(%eax),%ecx
  800607:	8d 40 08             	lea    0x8(%eax),%eax
  80060a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80060d:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800612:	eb 3f                	jmp    800653 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8b 10                	mov    (%eax),%edx
  800619:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061e:	8d 40 04             	lea    0x4(%eax),%eax
  800621:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800624:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800629:	eb 28                	jmp    800653 <vprintfmt+0x38c>
			putch('0', putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	53                   	push   %ebx
  80062f:	6a 30                	push   $0x30
  800631:	ff d6                	call   *%esi
			putch('x', putdat);
  800633:	83 c4 08             	add    $0x8,%esp
  800636:	53                   	push   %ebx
  800637:	6a 78                	push   $0x78
  800639:	ff d6                	call   *%esi
			num = (unsigned long long)
  80063b:	8b 45 14             	mov    0x14(%ebp),%eax
  80063e:	8b 10                	mov    (%eax),%edx
  800640:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800645:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800648:	8d 40 04             	lea    0x4(%eax),%eax
  80064b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80064e:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800653:	83 ec 0c             	sub    $0xc,%esp
  800656:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80065a:	57                   	push   %edi
  80065b:	ff 75 e0             	pushl  -0x20(%ebp)
  80065e:	50                   	push   %eax
  80065f:	51                   	push   %ecx
  800660:	52                   	push   %edx
  800661:	89 da                	mov    %ebx,%edx
  800663:	89 f0                	mov    %esi,%eax
  800665:	e8 72 fb ff ff       	call   8001dc <printnum>
			break;
  80066a:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80066d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {	
  800670:	83 c7 01             	add    $0x1,%edi
  800673:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800677:	83 f8 25             	cmp    $0x25,%eax
  80067a:	0f 84 62 fc ff ff    	je     8002e2 <vprintfmt+0x1b>
			if (ch == '\0')										
  800680:	85 c0                	test   %eax,%eax
  800682:	0f 84 8b 00 00 00    	je     800713 <vprintfmt+0x44c>
			putch(ch, putdat);
  800688:	83 ec 08             	sub    $0x8,%esp
  80068b:	53                   	push   %ebx
  80068c:	50                   	push   %eax
  80068d:	ff d6                	call   *%esi
  80068f:	83 c4 10             	add    $0x10,%esp
  800692:	eb dc                	jmp    800670 <vprintfmt+0x3a9>
	if (lflag >= 2)
  800694:	83 f9 01             	cmp    $0x1,%ecx
  800697:	7f 1b                	jg     8006b4 <vprintfmt+0x3ed>
	else if (lflag)
  800699:	85 c9                	test   %ecx,%ecx
  80069b:	74 2c                	je     8006c9 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  80069d:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a0:	8b 10                	mov    (%eax),%edx
  8006a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a7:	8d 40 04             	lea    0x4(%eax),%eax
  8006aa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ad:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006b2:	eb 9f                	jmp    800653 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8b 10                	mov    (%eax),%edx
  8006b9:	8b 48 04             	mov    0x4(%eax),%ecx
  8006bc:	8d 40 08             	lea    0x8(%eax),%eax
  8006bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c2:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006c7:	eb 8a                	jmp    800653 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8006c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cc:	8b 10                	mov    (%eax),%edx
  8006ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d3:	8d 40 04             	lea    0x4(%eax),%eax
  8006d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d9:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006de:	e9 70 ff ff ff       	jmp    800653 <vprintfmt+0x38c>
			putch(ch, putdat);
  8006e3:	83 ec 08             	sub    $0x8,%esp
  8006e6:	53                   	push   %ebx
  8006e7:	6a 25                	push   $0x25
  8006e9:	ff d6                	call   *%esi
			break;
  8006eb:	83 c4 10             	add    $0x10,%esp
  8006ee:	e9 7a ff ff ff       	jmp    80066d <vprintfmt+0x3a6>
			putch('%', putdat);
  8006f3:	83 ec 08             	sub    $0x8,%esp
  8006f6:	53                   	push   %ebx
  8006f7:	6a 25                	push   $0x25
  8006f9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fb:	83 c4 10             	add    $0x10,%esp
  8006fe:	89 f8                	mov    %edi,%eax
  800700:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800704:	74 05                	je     80070b <vprintfmt+0x444>
  800706:	83 e8 01             	sub    $0x1,%eax
  800709:	eb f5                	jmp    800700 <vprintfmt+0x439>
  80070b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80070e:	e9 5a ff ff ff       	jmp    80066d <vprintfmt+0x3a6>
}
  800713:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800716:	5b                   	pop    %ebx
  800717:	5e                   	pop    %esi
  800718:	5f                   	pop    %edi
  800719:	5d                   	pop    %ebp
  80071a:	c3                   	ret    

0080071b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80071b:	f3 0f 1e fb          	endbr32 
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	83 ec 18             	sub    $0x18,%esp
  800725:	8b 45 08             	mov    0x8(%ebp),%eax
  800728:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80072b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80072e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800732:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800735:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80073c:	85 c0                	test   %eax,%eax
  80073e:	74 26                	je     800766 <vsnprintf+0x4b>
  800740:	85 d2                	test   %edx,%edx
  800742:	7e 22                	jle    800766 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800744:	ff 75 14             	pushl  0x14(%ebp)
  800747:	ff 75 10             	pushl  0x10(%ebp)
  80074a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80074d:	50                   	push   %eax
  80074e:	68 85 02 80 00       	push   $0x800285
  800753:	e8 6f fb ff ff       	call   8002c7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800758:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80075b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80075e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800761:	83 c4 10             	add    $0x10,%esp
}
  800764:	c9                   	leave  
  800765:	c3                   	ret    
		return -E_INVAL;
  800766:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80076b:	eb f7                	jmp    800764 <vsnprintf+0x49>

0080076d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80076d:	f3 0f 1e fb          	endbr32 
  800771:	55                   	push   %ebp
  800772:	89 e5                	mov    %esp,%ebp
  800774:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800777:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80077a:	50                   	push   %eax
  80077b:	ff 75 10             	pushl  0x10(%ebp)
  80077e:	ff 75 0c             	pushl  0xc(%ebp)
  800781:	ff 75 08             	pushl  0x8(%ebp)
  800784:	e8 92 ff ff ff       	call   80071b <vsnprintf>
	va_end(ap);

	return rc;
}
  800789:	c9                   	leave  
  80078a:	c3                   	ret    

0080078b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80078b:	f3 0f 1e fb          	endbr32 
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800795:	b8 00 00 00 00       	mov    $0x0,%eax
  80079a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80079e:	74 05                	je     8007a5 <strlen+0x1a>
		n++;
  8007a0:	83 c0 01             	add    $0x1,%eax
  8007a3:	eb f5                	jmp    80079a <strlen+0xf>
	return n;
}
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007a7:	f3 0f 1e fb          	endbr32 
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b1:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b9:	39 d0                	cmp    %edx,%eax
  8007bb:	74 0d                	je     8007ca <strnlen+0x23>
  8007bd:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007c1:	74 05                	je     8007c8 <strnlen+0x21>
		n++;
  8007c3:	83 c0 01             	add    $0x1,%eax
  8007c6:	eb f1                	jmp    8007b9 <strnlen+0x12>
  8007c8:	89 c2                	mov    %eax,%edx
	return n;
}
  8007ca:	89 d0                	mov    %edx,%eax
  8007cc:	5d                   	pop    %ebp
  8007cd:	c3                   	ret    

008007ce <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ce:	f3 0f 1e fb          	endbr32 
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	53                   	push   %ebx
  8007d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e1:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007e5:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007e8:	83 c0 01             	add    $0x1,%eax
  8007eb:	84 d2                	test   %dl,%dl
  8007ed:	75 f2                	jne    8007e1 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007ef:	89 c8                	mov    %ecx,%eax
  8007f1:	5b                   	pop    %ebx
  8007f2:	5d                   	pop    %ebp
  8007f3:	c3                   	ret    

008007f4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f4:	f3 0f 1e fb          	endbr32 
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	53                   	push   %ebx
  8007fc:	83 ec 10             	sub    $0x10,%esp
  8007ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800802:	53                   	push   %ebx
  800803:	e8 83 ff ff ff       	call   80078b <strlen>
  800808:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80080b:	ff 75 0c             	pushl  0xc(%ebp)
  80080e:	01 d8                	add    %ebx,%eax
  800810:	50                   	push   %eax
  800811:	e8 b8 ff ff ff       	call   8007ce <strcpy>
	return dst;
}
  800816:	89 d8                	mov    %ebx,%eax
  800818:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80081b:	c9                   	leave  
  80081c:	c3                   	ret    

0080081d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80081d:	f3 0f 1e fb          	endbr32 
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	56                   	push   %esi
  800825:	53                   	push   %ebx
  800826:	8b 75 08             	mov    0x8(%ebp),%esi
  800829:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082c:	89 f3                	mov    %esi,%ebx
  80082e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800831:	89 f0                	mov    %esi,%eax
  800833:	39 d8                	cmp    %ebx,%eax
  800835:	74 11                	je     800848 <strncpy+0x2b>
		*dst++ = *src;
  800837:	83 c0 01             	add    $0x1,%eax
  80083a:	0f b6 0a             	movzbl (%edx),%ecx
  80083d:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800840:	80 f9 01             	cmp    $0x1,%cl
  800843:	83 da ff             	sbb    $0xffffffff,%edx
  800846:	eb eb                	jmp    800833 <strncpy+0x16>
	}
	return ret;
}
  800848:	89 f0                	mov    %esi,%eax
  80084a:	5b                   	pop    %ebx
  80084b:	5e                   	pop    %esi
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    

0080084e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80084e:	f3 0f 1e fb          	endbr32 
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	56                   	push   %esi
  800856:	53                   	push   %ebx
  800857:	8b 75 08             	mov    0x8(%ebp),%esi
  80085a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085d:	8b 55 10             	mov    0x10(%ebp),%edx
  800860:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800862:	85 d2                	test   %edx,%edx
  800864:	74 21                	je     800887 <strlcpy+0x39>
  800866:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80086a:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80086c:	39 c2                	cmp    %eax,%edx
  80086e:	74 14                	je     800884 <strlcpy+0x36>
  800870:	0f b6 19             	movzbl (%ecx),%ebx
  800873:	84 db                	test   %bl,%bl
  800875:	74 0b                	je     800882 <strlcpy+0x34>
			*dst++ = *src++;
  800877:	83 c1 01             	add    $0x1,%ecx
  80087a:	83 c2 01             	add    $0x1,%edx
  80087d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800880:	eb ea                	jmp    80086c <strlcpy+0x1e>
  800882:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800884:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800887:	29 f0                	sub    %esi,%eax
}
  800889:	5b                   	pop    %ebx
  80088a:	5e                   	pop    %esi
  80088b:	5d                   	pop    %ebp
  80088c:	c3                   	ret    

0080088d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80088d:	f3 0f 1e fb          	endbr32 
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800897:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80089a:	0f b6 01             	movzbl (%ecx),%eax
  80089d:	84 c0                	test   %al,%al
  80089f:	74 0c                	je     8008ad <strcmp+0x20>
  8008a1:	3a 02                	cmp    (%edx),%al
  8008a3:	75 08                	jne    8008ad <strcmp+0x20>
		p++, q++;
  8008a5:	83 c1 01             	add    $0x1,%ecx
  8008a8:	83 c2 01             	add    $0x1,%edx
  8008ab:	eb ed                	jmp    80089a <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ad:	0f b6 c0             	movzbl %al,%eax
  8008b0:	0f b6 12             	movzbl (%edx),%edx
  8008b3:	29 d0                	sub    %edx,%eax
}
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b7:	f3 0f 1e fb          	endbr32 
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	53                   	push   %ebx
  8008bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c5:	89 c3                	mov    %eax,%ebx
  8008c7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ca:	eb 06                	jmp    8008d2 <strncmp+0x1b>
		n--, p++, q++;
  8008cc:	83 c0 01             	add    $0x1,%eax
  8008cf:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008d2:	39 d8                	cmp    %ebx,%eax
  8008d4:	74 16                	je     8008ec <strncmp+0x35>
  8008d6:	0f b6 08             	movzbl (%eax),%ecx
  8008d9:	84 c9                	test   %cl,%cl
  8008db:	74 04                	je     8008e1 <strncmp+0x2a>
  8008dd:	3a 0a                	cmp    (%edx),%cl
  8008df:	74 eb                	je     8008cc <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e1:	0f b6 00             	movzbl (%eax),%eax
  8008e4:	0f b6 12             	movzbl (%edx),%edx
  8008e7:	29 d0                	sub    %edx,%eax
}
  8008e9:	5b                   	pop    %ebx
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    
		return 0;
  8008ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f1:	eb f6                	jmp    8008e9 <strncmp+0x32>

008008f3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f3:	f3 0f 1e fb          	endbr32 
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800901:	0f b6 10             	movzbl (%eax),%edx
  800904:	84 d2                	test   %dl,%dl
  800906:	74 09                	je     800911 <strchr+0x1e>
		if (*s == c)
  800908:	38 ca                	cmp    %cl,%dl
  80090a:	74 0a                	je     800916 <strchr+0x23>
	for (; *s; s++)
  80090c:	83 c0 01             	add    $0x1,%eax
  80090f:	eb f0                	jmp    800901 <strchr+0xe>
			return (char *) s;
	return 0;
  800911:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800918:	f3 0f 1e fb          	endbr32 
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	8b 45 08             	mov    0x8(%ebp),%eax
  800922:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800926:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800929:	38 ca                	cmp    %cl,%dl
  80092b:	74 09                	je     800936 <strfind+0x1e>
  80092d:	84 d2                	test   %dl,%dl
  80092f:	74 05                	je     800936 <strfind+0x1e>
	for (; *s; s++)
  800931:	83 c0 01             	add    $0x1,%eax
  800934:	eb f0                	jmp    800926 <strfind+0xe>
			break;
	return (char *) s;
}
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800938:	f3 0f 1e fb          	endbr32 
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	57                   	push   %edi
  800940:	56                   	push   %esi
  800941:	53                   	push   %ebx
  800942:	8b 7d 08             	mov    0x8(%ebp),%edi
  800945:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800948:	85 c9                	test   %ecx,%ecx
  80094a:	74 31                	je     80097d <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80094c:	89 f8                	mov    %edi,%eax
  80094e:	09 c8                	or     %ecx,%eax
  800950:	a8 03                	test   $0x3,%al
  800952:	75 23                	jne    800977 <memset+0x3f>
		c &= 0xFF;
  800954:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800958:	89 d3                	mov    %edx,%ebx
  80095a:	c1 e3 08             	shl    $0x8,%ebx
  80095d:	89 d0                	mov    %edx,%eax
  80095f:	c1 e0 18             	shl    $0x18,%eax
  800962:	89 d6                	mov    %edx,%esi
  800964:	c1 e6 10             	shl    $0x10,%esi
  800967:	09 f0                	or     %esi,%eax
  800969:	09 c2                	or     %eax,%edx
  80096b:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80096d:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800970:	89 d0                	mov    %edx,%eax
  800972:	fc                   	cld    
  800973:	f3 ab                	rep stos %eax,%es:(%edi)
  800975:	eb 06                	jmp    80097d <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800977:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097a:	fc                   	cld    
  80097b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097d:	89 f8                	mov    %edi,%eax
  80097f:	5b                   	pop    %ebx
  800980:	5e                   	pop    %esi
  800981:	5f                   	pop    %edi
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800984:	f3 0f 1e fb          	endbr32 
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	57                   	push   %edi
  80098c:	56                   	push   %esi
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	8b 75 0c             	mov    0xc(%ebp),%esi
  800993:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800996:	39 c6                	cmp    %eax,%esi
  800998:	73 32                	jae    8009cc <memmove+0x48>
  80099a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099d:	39 c2                	cmp    %eax,%edx
  80099f:	76 2b                	jbe    8009cc <memmove+0x48>
		s += n;
		d += n;
  8009a1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a4:	89 fe                	mov    %edi,%esi
  8009a6:	09 ce                	or     %ecx,%esi
  8009a8:	09 d6                	or     %edx,%esi
  8009aa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b0:	75 0e                	jne    8009c0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009b2:	83 ef 04             	sub    $0x4,%edi
  8009b5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009bb:	fd                   	std    
  8009bc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009be:	eb 09                	jmp    8009c9 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009c0:	83 ef 01             	sub    $0x1,%edi
  8009c3:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009c6:	fd                   	std    
  8009c7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c9:	fc                   	cld    
  8009ca:	eb 1a                	jmp    8009e6 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cc:	89 c2                	mov    %eax,%edx
  8009ce:	09 ca                	or     %ecx,%edx
  8009d0:	09 f2                	or     %esi,%edx
  8009d2:	f6 c2 03             	test   $0x3,%dl
  8009d5:	75 0a                	jne    8009e1 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009d7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009da:	89 c7                	mov    %eax,%edi
  8009dc:	fc                   	cld    
  8009dd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009df:	eb 05                	jmp    8009e6 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009e1:	89 c7                	mov    %eax,%edi
  8009e3:	fc                   	cld    
  8009e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e6:	5e                   	pop    %esi
  8009e7:	5f                   	pop    %edi
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ea:	f3 0f 1e fb          	endbr32 
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009f4:	ff 75 10             	pushl  0x10(%ebp)
  8009f7:	ff 75 0c             	pushl  0xc(%ebp)
  8009fa:	ff 75 08             	pushl  0x8(%ebp)
  8009fd:	e8 82 ff ff ff       	call   800984 <memmove>
}
  800a02:	c9                   	leave  
  800a03:	c3                   	ret    

00800a04 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a04:	f3 0f 1e fb          	endbr32 
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	56                   	push   %esi
  800a0c:	53                   	push   %ebx
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a10:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a13:	89 c6                	mov    %eax,%esi
  800a15:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a18:	39 f0                	cmp    %esi,%eax
  800a1a:	74 1c                	je     800a38 <memcmp+0x34>
		if (*s1 != *s2)
  800a1c:	0f b6 08             	movzbl (%eax),%ecx
  800a1f:	0f b6 1a             	movzbl (%edx),%ebx
  800a22:	38 d9                	cmp    %bl,%cl
  800a24:	75 08                	jne    800a2e <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a26:	83 c0 01             	add    $0x1,%eax
  800a29:	83 c2 01             	add    $0x1,%edx
  800a2c:	eb ea                	jmp    800a18 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a2e:	0f b6 c1             	movzbl %cl,%eax
  800a31:	0f b6 db             	movzbl %bl,%ebx
  800a34:	29 d8                	sub    %ebx,%eax
  800a36:	eb 05                	jmp    800a3d <memcmp+0x39>
	}

	return 0;
  800a38:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3d:	5b                   	pop    %ebx
  800a3e:	5e                   	pop    %esi
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a41:	f3 0f 1e fb          	endbr32 
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a4e:	89 c2                	mov    %eax,%edx
  800a50:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a53:	39 d0                	cmp    %edx,%eax
  800a55:	73 09                	jae    800a60 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a57:	38 08                	cmp    %cl,(%eax)
  800a59:	74 05                	je     800a60 <memfind+0x1f>
	for (; s < ends; s++)
  800a5b:	83 c0 01             	add    $0x1,%eax
  800a5e:	eb f3                	jmp    800a53 <memfind+0x12>
			break;
	return (void *) s;
}
  800a60:	5d                   	pop    %ebp
  800a61:	c3                   	ret    

00800a62 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a62:	f3 0f 1e fb          	endbr32 
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	57                   	push   %edi
  800a6a:	56                   	push   %esi
  800a6b:	53                   	push   %ebx
  800a6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a72:	eb 03                	jmp    800a77 <strtol+0x15>
		s++;
  800a74:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a77:	0f b6 01             	movzbl (%ecx),%eax
  800a7a:	3c 20                	cmp    $0x20,%al
  800a7c:	74 f6                	je     800a74 <strtol+0x12>
  800a7e:	3c 09                	cmp    $0x9,%al
  800a80:	74 f2                	je     800a74 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a82:	3c 2b                	cmp    $0x2b,%al
  800a84:	74 2a                	je     800ab0 <strtol+0x4e>
	int neg = 0;
  800a86:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a8b:	3c 2d                	cmp    $0x2d,%al
  800a8d:	74 2b                	je     800aba <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a95:	75 0f                	jne    800aa6 <strtol+0x44>
  800a97:	80 39 30             	cmpb   $0x30,(%ecx)
  800a9a:	74 28                	je     800ac4 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a9c:	85 db                	test   %ebx,%ebx
  800a9e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aa3:	0f 44 d8             	cmove  %eax,%ebx
  800aa6:	b8 00 00 00 00       	mov    $0x0,%eax
  800aab:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800aae:	eb 46                	jmp    800af6 <strtol+0x94>
		s++;
  800ab0:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ab3:	bf 00 00 00 00       	mov    $0x0,%edi
  800ab8:	eb d5                	jmp    800a8f <strtol+0x2d>
		s++, neg = 1;
  800aba:	83 c1 01             	add    $0x1,%ecx
  800abd:	bf 01 00 00 00       	mov    $0x1,%edi
  800ac2:	eb cb                	jmp    800a8f <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ac8:	74 0e                	je     800ad8 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800aca:	85 db                	test   %ebx,%ebx
  800acc:	75 d8                	jne    800aa6 <strtol+0x44>
		s++, base = 8;
  800ace:	83 c1 01             	add    $0x1,%ecx
  800ad1:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ad6:	eb ce                	jmp    800aa6 <strtol+0x44>
		s += 2, base = 16;
  800ad8:	83 c1 02             	add    $0x2,%ecx
  800adb:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ae0:	eb c4                	jmp    800aa6 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ae2:	0f be d2             	movsbl %dl,%edx
  800ae5:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ae8:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aeb:	7d 3a                	jge    800b27 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800aed:	83 c1 01             	add    $0x1,%ecx
  800af0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800af4:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800af6:	0f b6 11             	movzbl (%ecx),%edx
  800af9:	8d 72 d0             	lea    -0x30(%edx),%esi
  800afc:	89 f3                	mov    %esi,%ebx
  800afe:	80 fb 09             	cmp    $0x9,%bl
  800b01:	76 df                	jbe    800ae2 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b03:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b06:	89 f3                	mov    %esi,%ebx
  800b08:	80 fb 19             	cmp    $0x19,%bl
  800b0b:	77 08                	ja     800b15 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b0d:	0f be d2             	movsbl %dl,%edx
  800b10:	83 ea 57             	sub    $0x57,%edx
  800b13:	eb d3                	jmp    800ae8 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b15:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b18:	89 f3                	mov    %esi,%ebx
  800b1a:	80 fb 19             	cmp    $0x19,%bl
  800b1d:	77 08                	ja     800b27 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b1f:	0f be d2             	movsbl %dl,%edx
  800b22:	83 ea 37             	sub    $0x37,%edx
  800b25:	eb c1                	jmp    800ae8 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b27:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b2b:	74 05                	je     800b32 <strtol+0xd0>
		*endptr = (char *) s;
  800b2d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b30:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b32:	89 c2                	mov    %eax,%edx
  800b34:	f7 da                	neg    %edx
  800b36:	85 ff                	test   %edi,%edi
  800b38:	0f 45 c2             	cmovne %edx,%eax
}
  800b3b:	5b                   	pop    %ebx
  800b3c:	5e                   	pop    %esi
  800b3d:	5f                   	pop    %edi
  800b3e:	5d                   	pop    %ebp
  800b3f:	c3                   	ret    

00800b40 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b40:	f3 0f 1e fb          	endbr32 
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800b4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b55:	89 c3                	mov    %eax,%ebx
  800b57:	89 c7                	mov    %eax,%edi
  800b59:	89 c6                	mov    %eax,%esi
  800b5b:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b5d:	5b                   	pop    %ebx
  800b5e:	5e                   	pop    %esi
  800b5f:	5f                   	pop    %edi
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b62:	f3 0f 1e fb          	endbr32 
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800b6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b71:	b8 01 00 00 00       	mov    $0x1,%eax
  800b76:	89 d1                	mov    %edx,%ecx
  800b78:	89 d3                	mov    %edx,%ebx
  800b7a:	89 d7                	mov    %edx,%edi
  800b7c:	89 d6                	mov    %edx,%esi
  800b7e:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b85:	f3 0f 1e fb          	endbr32 
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	57                   	push   %edi
  800b8d:	56                   	push   %esi
  800b8e:	53                   	push   %ebx
  800b8f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800b92:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b97:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b9f:	89 cb                	mov    %ecx,%ebx
  800ba1:	89 cf                	mov    %ecx,%edi
  800ba3:	89 ce                	mov    %ecx,%esi
  800ba5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ba7:	85 c0                	test   %eax,%eax
  800ba9:	7f 08                	jg     800bb3 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb3:	83 ec 0c             	sub    $0xc,%esp
  800bb6:	50                   	push   %eax
  800bb7:	6a 03                	push   $0x3
  800bb9:	68 44 17 80 00       	push   $0x801744
  800bbe:	6a 23                	push   $0x23
  800bc0:	68 61 17 80 00       	push   $0x801761
  800bc5:	e8 ba 05 00 00       	call   801184 <_panic>

00800bca <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bca:	f3 0f 1e fb          	endbr32 
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800bd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd9:	b8 02 00 00 00       	mov    $0x2,%eax
  800bde:	89 d1                	mov    %edx,%ecx
  800be0:	89 d3                	mov    %edx,%ebx
  800be2:	89 d7                	mov    %edx,%edi
  800be4:	89 d6                	mov    %edx,%esi
  800be6:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be8:	5b                   	pop    %ebx
  800be9:	5e                   	pop    %esi
  800bea:	5f                   	pop    %edi
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    

00800bed <sys_yield>:

void
sys_yield(void)
{
  800bed:	f3 0f 1e fb          	endbr32 
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800bf7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c01:	89 d1                	mov    %edx,%ecx
  800c03:	89 d3                	mov    %edx,%ebx
  800c05:	89 d7                	mov    %edx,%edi
  800c07:	89 d6                	mov    %edx,%esi
  800c09:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c0b:	5b                   	pop    %ebx
  800c0c:	5e                   	pop    %esi
  800c0d:	5f                   	pop    %edi
  800c0e:	5d                   	pop    %ebp
  800c0f:	c3                   	ret    

00800c10 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c10:	f3 0f 1e fb          	endbr32 
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
  800c1a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c1d:	be 00 00 00 00       	mov    $0x0,%esi
  800c22:	8b 55 08             	mov    0x8(%ebp),%edx
  800c25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c28:	b8 04 00 00 00       	mov    $0x4,%eax
  800c2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c30:	89 f7                	mov    %esi,%edi
  800c32:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c34:	85 c0                	test   %eax,%eax
  800c36:	7f 08                	jg     800c40 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3b:	5b                   	pop    %ebx
  800c3c:	5e                   	pop    %esi
  800c3d:	5f                   	pop    %edi
  800c3e:	5d                   	pop    %ebp
  800c3f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c40:	83 ec 0c             	sub    $0xc,%esp
  800c43:	50                   	push   %eax
  800c44:	6a 04                	push   $0x4
  800c46:	68 44 17 80 00       	push   $0x801744
  800c4b:	6a 23                	push   $0x23
  800c4d:	68 61 17 80 00       	push   $0x801761
  800c52:	e8 2d 05 00 00       	call   801184 <_panic>

00800c57 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c57:	f3 0f 1e fb          	endbr32 
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	57                   	push   %edi
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
  800c61:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c64:	8b 55 08             	mov    0x8(%ebp),%edx
  800c67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6a:	b8 05 00 00 00       	mov    $0x5,%eax
  800c6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c72:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c75:	8b 75 18             	mov    0x18(%ebp),%esi
  800c78:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c7a:	85 c0                	test   %eax,%eax
  800c7c:	7f 08                	jg     800c86 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c86:	83 ec 0c             	sub    $0xc,%esp
  800c89:	50                   	push   %eax
  800c8a:	6a 05                	push   $0x5
  800c8c:	68 44 17 80 00       	push   $0x801744
  800c91:	6a 23                	push   $0x23
  800c93:	68 61 17 80 00       	push   $0x801761
  800c98:	e8 e7 04 00 00       	call   801184 <_panic>

00800c9d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c9d:	f3 0f 1e fb          	endbr32 
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	57                   	push   %edi
  800ca5:	56                   	push   %esi
  800ca6:	53                   	push   %ebx
  800ca7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800caa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800caf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb5:	b8 06 00 00 00       	mov    $0x6,%eax
  800cba:	89 df                	mov    %ebx,%edi
  800cbc:	89 de                	mov    %ebx,%esi
  800cbe:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc0:	85 c0                	test   %eax,%eax
  800cc2:	7f 08                	jg     800ccc <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccc:	83 ec 0c             	sub    $0xc,%esp
  800ccf:	50                   	push   %eax
  800cd0:	6a 06                	push   $0x6
  800cd2:	68 44 17 80 00       	push   $0x801744
  800cd7:	6a 23                	push   $0x23
  800cd9:	68 61 17 80 00       	push   $0x801761
  800cde:	e8 a1 04 00 00       	call   801184 <_panic>

00800ce3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ce3:	f3 0f 1e fb          	endbr32 
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
  800ced:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800cf0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfb:	b8 08 00 00 00       	mov    $0x8,%eax
  800d00:	89 df                	mov    %ebx,%edi
  800d02:	89 de                	mov    %ebx,%esi
  800d04:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d06:	85 c0                	test   %eax,%eax
  800d08:	7f 08                	jg     800d12 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0d:	5b                   	pop    %ebx
  800d0e:	5e                   	pop    %esi
  800d0f:	5f                   	pop    %edi
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d12:	83 ec 0c             	sub    $0xc,%esp
  800d15:	50                   	push   %eax
  800d16:	6a 08                	push   $0x8
  800d18:	68 44 17 80 00       	push   $0x801744
  800d1d:	6a 23                	push   $0x23
  800d1f:	68 61 17 80 00       	push   $0x801761
  800d24:	e8 5b 04 00 00       	call   801184 <_panic>

00800d29 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d29:	f3 0f 1e fb          	endbr32 
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	57                   	push   %edi
  800d31:	56                   	push   %esi
  800d32:	53                   	push   %ebx
  800d33:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d36:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d41:	b8 09 00 00 00       	mov    $0x9,%eax
  800d46:	89 df                	mov    %ebx,%edi
  800d48:	89 de                	mov    %ebx,%esi
  800d4a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d4c:	85 c0                	test   %eax,%eax
  800d4e:	7f 08                	jg     800d58 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d53:	5b                   	pop    %ebx
  800d54:	5e                   	pop    %esi
  800d55:	5f                   	pop    %edi
  800d56:	5d                   	pop    %ebp
  800d57:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d58:	83 ec 0c             	sub    $0xc,%esp
  800d5b:	50                   	push   %eax
  800d5c:	6a 09                	push   $0x9
  800d5e:	68 44 17 80 00       	push   $0x801744
  800d63:	6a 23                	push   $0x23
  800d65:	68 61 17 80 00       	push   $0x801761
  800d6a:	e8 15 04 00 00       	call   801184 <_panic>

00800d6f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d6f:	f3 0f 1e fb          	endbr32 
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	57                   	push   %edi
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d84:	be 00 00 00 00       	mov    $0x0,%esi
  800d89:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d8c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d8f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d91:	5b                   	pop    %ebx
  800d92:	5e                   	pop    %esi
  800d93:	5f                   	pop    %edi
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d96:	f3 0f 1e fb          	endbr32 
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	57                   	push   %edi
  800d9e:	56                   	push   %esi
  800d9f:	53                   	push   %ebx
  800da0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800da3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dab:	b8 0c 00 00 00       	mov    $0xc,%eax
  800db0:	89 cb                	mov    %ecx,%ebx
  800db2:	89 cf                	mov    %ecx,%edi
  800db4:	89 ce                	mov    %ecx,%esi
  800db6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800db8:	85 c0                	test   %eax,%eax
  800dba:	7f 08                	jg     800dc4 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc4:	83 ec 0c             	sub    $0xc,%esp
  800dc7:	50                   	push   %eax
  800dc8:	6a 0c                	push   $0xc
  800dca:	68 44 17 80 00       	push   $0x801744
  800dcf:	6a 23                	push   $0x23
  800dd1:	68 61 17 80 00       	push   $0x801761
  800dd6:	e8 a9 03 00 00       	call   801184 <_panic>

00800ddb <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ddb:	f3 0f 1e fb          	endbr32 
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	53                   	push   %ebx
  800de3:	83 ec 04             	sub    $0x4,%esp
  800de6:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800de9:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpt[PGNUM(addr)] & PTE_COW))) { 
  800deb:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800def:	74 74                	je     800e65 <pgfault+0x8a>
  800df1:	89 d8                	mov    %ebx,%eax
  800df3:	c1 e8 0c             	shr    $0xc,%eax
  800df6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dfd:	f6 c4 08             	test   $0x8,%ah
  800e00:	74 63                	je     800e65 <pgfault+0x8a>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  800e02:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_map(0, addr, 0, PFTEMP, PTE_U|PTE_P)) < 0)		
  800e08:	83 ec 0c             	sub    $0xc,%esp
  800e0b:	6a 05                	push   $0x5
  800e0d:	68 00 f0 7f 00       	push   $0x7ff000
  800e12:	6a 00                	push   $0x0
  800e14:	53                   	push   %ebx
  800e15:	6a 00                	push   $0x0
  800e17:	e8 3b fe ff ff       	call   800c57 <sys_page_map>
  800e1c:	83 c4 20             	add    $0x20,%esp
  800e1f:	85 c0                	test   %eax,%eax
  800e21:	78 56                	js     800e79 <pgfault+0x9e>
		panic("sys_page_map: %e", r);
	if ((r = sys_page_alloc(0, addr, PTE_P|PTE_U|PTE_W)) < 0)	
  800e23:	83 ec 04             	sub    $0x4,%esp
  800e26:	6a 07                	push   $0x7
  800e28:	53                   	push   %ebx
  800e29:	6a 00                	push   $0x0
  800e2b:	e8 e0 fd ff ff       	call   800c10 <sys_page_alloc>
  800e30:	83 c4 10             	add    $0x10,%esp
  800e33:	85 c0                	test   %eax,%eax
  800e35:	78 54                	js     800e8b <pgfault+0xb0>
		panic("sys_page_alloc: %e", r);
	memmove(addr, PFTEMP, PGSIZE);							
  800e37:	83 ec 04             	sub    $0x4,%esp
  800e3a:	68 00 10 00 00       	push   $0x1000
  800e3f:	68 00 f0 7f 00       	push   $0x7ff000
  800e44:	53                   	push   %ebx
  800e45:	e8 3a fb ff ff       	call   800984 <memmove>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)				
  800e4a:	83 c4 08             	add    $0x8,%esp
  800e4d:	68 00 f0 7f 00       	push   $0x7ff000
  800e52:	6a 00                	push   $0x0
  800e54:	e8 44 fe ff ff       	call   800c9d <sys_page_unmap>
  800e59:	83 c4 10             	add    $0x10,%esp
  800e5c:	85 c0                	test   %eax,%eax
  800e5e:	78 3d                	js     800e9d <pgfault+0xc2>
		panic("sys_page_unmap: %e", r);
}
  800e60:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e63:	c9                   	leave  
  800e64:	c3                   	ret    
		panic("pgfault():not cow");
  800e65:	83 ec 04             	sub    $0x4,%esp
  800e68:	68 6f 17 80 00       	push   $0x80176f
  800e6d:	6a 1d                	push   $0x1d
  800e6f:	68 81 17 80 00       	push   $0x801781
  800e74:	e8 0b 03 00 00       	call   801184 <_panic>
		panic("sys_page_map: %e", r);
  800e79:	50                   	push   %eax
  800e7a:	68 8c 17 80 00       	push   $0x80178c
  800e7f:	6a 2a                	push   $0x2a
  800e81:	68 81 17 80 00       	push   $0x801781
  800e86:	e8 f9 02 00 00       	call   801184 <_panic>
		panic("sys_page_alloc: %e", r);
  800e8b:	50                   	push   %eax
  800e8c:	68 9d 17 80 00       	push   $0x80179d
  800e91:	6a 2c                	push   $0x2c
  800e93:	68 81 17 80 00       	push   $0x801781
  800e98:	e8 e7 02 00 00       	call   801184 <_panic>
		panic("sys_page_unmap: %e", r);
  800e9d:	50                   	push   %eax
  800e9e:	68 b0 17 80 00       	push   $0x8017b0
  800ea3:	6a 2f                	push   $0x2f
  800ea5:	68 81 17 80 00       	push   $0x801781
  800eaa:	e8 d5 02 00 00       	call   801184 <_panic>

00800eaf <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800eaf:	f3 0f 1e fb          	endbr32 
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	57                   	push   %edi
  800eb7:	56                   	push   %esi
  800eb8:	53                   	push   %ebx
  800eb9:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	extern void _pgfault_upcall(void);
	set_pgfault_handler(pgfault);	
  800ebc:	68 db 0d 80 00       	push   $0x800ddb
  800ec1:	e8 08 03 00 00       	call   8011ce <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ec6:	b8 07 00 00 00       	mov    $0x7,%eax
  800ecb:	cd 30                	int    $0x30
  800ecd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();	
	if (envid == 0) {				
  800ed0:	83 c4 10             	add    $0x10,%esp
  800ed3:	85 c0                	test   %eax,%eax
  800ed5:	74 12                	je     800ee9 <fork+0x3a>
  800ed7:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	if (envid < 0) {
  800ed9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800edd:	78 29                	js     800f08 <fork+0x59>
		panic("sys_exofork: %e", envid);
	}

	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  800edf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee4:	e9 80 00 00 00       	jmp    800f69 <fork+0xba>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ee9:	e8 dc fc ff ff       	call   800bca <sys_getenvid>
  800eee:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ef3:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  800ef9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800efe:	a3 60 40 80 00       	mov    %eax,0x804060
		return 0;
  800f03:	e9 27 01 00 00       	jmp    80102f <fork+0x180>
		panic("sys_exofork: %e", envid);
  800f08:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f0b:	68 c3 17 80 00       	push   $0x8017c3
  800f10:	6a 6b                	push   $0x6b
  800f12:	68 81 17 80 00       	push   $0x801781
  800f17:	e8 68 02 00 00       	call   801184 <_panic>
		if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800f1c:	83 ec 0c             	sub    $0xc,%esp
  800f1f:	68 05 08 00 00       	push   $0x805
  800f24:	56                   	push   %esi
  800f25:	57                   	push   %edi
  800f26:	56                   	push   %esi
  800f27:	6a 00                	push   $0x0
  800f29:	e8 29 fd ff ff       	call   800c57 <sys_page_map>
  800f2e:	83 c4 20             	add    $0x20,%esp
  800f31:	85 c0                	test   %eax,%eax
  800f33:	0f 88 96 00 00 00    	js     800fcf <fork+0x120>
		if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800f39:	83 ec 0c             	sub    $0xc,%esp
  800f3c:	68 05 08 00 00       	push   $0x805
  800f41:	56                   	push   %esi
  800f42:	6a 00                	push   $0x0
  800f44:	56                   	push   %esi
  800f45:	6a 00                	push   $0x0
  800f47:	e8 0b fd ff ff       	call   800c57 <sys_page_map>
  800f4c:	83 c4 20             	add    $0x20,%esp
  800f4f:	85 c0                	test   %eax,%eax
  800f51:	0f 88 8a 00 00 00    	js     800fe1 <fork+0x132>
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  800f57:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f5d:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f63:	0f 84 8a 00 00 00    	je     800ff3 <fork+0x144>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) 
  800f69:	89 d8                	mov    %ebx,%eax
  800f6b:	c1 e8 16             	shr    $0x16,%eax
  800f6e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f75:	a8 01                	test   $0x1,%al
  800f77:	74 de                	je     800f57 <fork+0xa8>
  800f79:	89 d8                	mov    %ebx,%eax
  800f7b:	c1 e8 0c             	shr    $0xc,%eax
  800f7e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f85:	f6 c2 01             	test   $0x1,%dl
  800f88:	74 cd                	je     800f57 <fork+0xa8>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  800f8a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f91:	f6 c2 04             	test   $0x4,%dl
  800f94:	74 c1                	je     800f57 <fork+0xa8>
	void *addr = (void*) (pn * PGSIZE);
  800f96:	89 c6                	mov    %eax,%esi
  800f98:	c1 e6 0c             	shl    $0xc,%esi
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) { 
  800f9b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fa2:	f6 c2 02             	test   $0x2,%dl
  800fa5:	0f 85 71 ff ff ff    	jne    800f1c <fork+0x6d>
  800fab:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fb2:	f6 c4 08             	test   $0x8,%ah
  800fb5:	0f 85 61 ff ff ff    	jne    800f1c <fork+0x6d>
		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);	
  800fbb:	83 ec 0c             	sub    $0xc,%esp
  800fbe:	6a 05                	push   $0x5
  800fc0:	56                   	push   %esi
  800fc1:	57                   	push   %edi
  800fc2:	56                   	push   %esi
  800fc3:	6a 00                	push   $0x0
  800fc5:	e8 8d fc ff ff       	call   800c57 <sys_page_map>
  800fca:	83 c4 20             	add    $0x20,%esp
  800fcd:	eb 88                	jmp    800f57 <fork+0xa8>
			panic("sys_page_map：%e", r);
  800fcf:	50                   	push   %eax
  800fd0:	68 d3 17 80 00       	push   $0x8017d3
  800fd5:	6a 46                	push   $0x46
  800fd7:	68 81 17 80 00       	push   $0x801781
  800fdc:	e8 a3 01 00 00       	call   801184 <_panic>
			panic("sys_page_map：%e", r);
  800fe1:	50                   	push   %eax
  800fe2:	68 d3 17 80 00       	push   $0x8017d3
  800fe7:	6a 48                	push   $0x48
  800fe9:	68 81 17 80 00       	push   $0x801781
  800fee:	e8 91 01 00 00       	call   801184 <_panic>
			duppage(envid, PGNUM(addr));	
		}
	}
	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)	
  800ff3:	83 ec 04             	sub    $0x4,%esp
  800ff6:	6a 07                	push   $0x7
  800ff8:	68 00 f0 bf ee       	push   $0xeebff000
  800ffd:	ff 75 e4             	pushl  -0x1c(%ebp)
  801000:	e8 0b fc ff ff       	call   800c10 <sys_page_alloc>
  801005:	83 c4 10             	add    $0x10,%esp
  801008:	85 c0                	test   %eax,%eax
  80100a:	78 2e                	js     80103a <fork+0x18b>
		panic("sys_page_alloc: %e", r);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);		
  80100c:	83 ec 08             	sub    $0x8,%esp
  80100f:	68 2b 12 80 00       	push   $0x80122b
  801014:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801017:	57                   	push   %edi
  801018:	e8 0c fd ff ff       	call   800d29 <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)	
  80101d:	83 c4 08             	add    $0x8,%esp
  801020:	6a 02                	push   $0x2
  801022:	57                   	push   %edi
  801023:	e8 bb fc ff ff       	call   800ce3 <sys_env_set_status>
  801028:	83 c4 10             	add    $0x10,%esp
  80102b:	85 c0                	test   %eax,%eax
  80102d:	78 1d                	js     80104c <fork+0x19d>
		panic("sys_env_set_status: %e", r);
	return envid;
}
  80102f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801032:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801035:	5b                   	pop    %ebx
  801036:	5e                   	pop    %esi
  801037:	5f                   	pop    %edi
  801038:	5d                   	pop    %ebp
  801039:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  80103a:	50                   	push   %eax
  80103b:	68 9d 17 80 00       	push   $0x80179d
  801040:	6a 77                	push   $0x77
  801042:	68 81 17 80 00       	push   $0x801781
  801047:	e8 38 01 00 00       	call   801184 <_panic>
		panic("sys_env_set_status: %e", r);
  80104c:	50                   	push   %eax
  80104d:	68 e5 17 80 00       	push   $0x8017e5
  801052:	6a 7b                	push   $0x7b
  801054:	68 81 17 80 00       	push   $0x801781
  801059:	e8 26 01 00 00       	call   801184 <_panic>

0080105e <sfork>:

// Challenge!
int
sfork(void)
{
  80105e:	f3 0f 1e fb          	endbr32 
  801062:	55                   	push   %ebp
  801063:	89 e5                	mov    %esp,%ebp
  801065:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801068:	68 fc 17 80 00       	push   $0x8017fc
  80106d:	68 83 00 00 00       	push   $0x83
  801072:	68 81 17 80 00       	push   $0x801781
  801077:	e8 08 01 00 00       	call   801184 <_panic>

0080107c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80107c:	f3 0f 1e fb          	endbr32 
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	56                   	push   %esi
  801084:	53                   	push   %ebx
  801085:	8b 75 08             	mov    0x8(%ebp),%esi
  801088:	8b 45 0c             	mov    0xc(%ebp),%eax
  80108b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *)-1;
  80108e:	85 c0                	test   %eax,%eax
  801090:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801095:	0f 44 c2             	cmove  %edx,%eax
	}
	int r = sys_ipc_recv(pg);
  801098:	83 ec 0c             	sub    $0xc,%esp
  80109b:	50                   	push   %eax
  80109c:	e8 f5 fc ff ff       	call   800d96 <sys_ipc_recv>
	if (r < 0) {				
  8010a1:	83 c4 10             	add    $0x10,%esp
  8010a4:	85 c0                	test   %eax,%eax
  8010a6:	78 2b                	js     8010d3 <ipc_recv+0x57>
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return r;
	}
	if (from_env_store)
  8010a8:	85 f6                	test   %esi,%esi
  8010aa:	74 0a                	je     8010b6 <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  8010ac:	a1 60 40 80 00       	mov    0x804060,%eax
  8010b1:	8b 40 74             	mov    0x74(%eax),%eax
  8010b4:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  8010b6:	85 db                	test   %ebx,%ebx
  8010b8:	74 0a                	je     8010c4 <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  8010ba:	a1 60 40 80 00       	mov    0x804060,%eax
  8010bf:	8b 40 78             	mov    0x78(%eax),%eax
  8010c2:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  8010c4:	a1 60 40 80 00       	mov    0x804060,%eax
  8010c9:	8b 40 70             	mov    0x70(%eax),%eax
}
  8010cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010cf:	5b                   	pop    %ebx
  8010d0:	5e                   	pop    %esi
  8010d1:	5d                   	pop    %ebp
  8010d2:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  8010d3:	85 f6                	test   %esi,%esi
  8010d5:	74 06                	je     8010dd <ipc_recv+0x61>
  8010d7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  8010dd:	85 db                	test   %ebx,%ebx
  8010df:	74 eb                	je     8010cc <ipc_recv+0x50>
  8010e1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010e7:	eb e3                	jmp    8010cc <ipc_recv+0x50>

008010e9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010e9:	f3 0f 1e fb          	endbr32 
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	57                   	push   %edi
  8010f1:	56                   	push   %esi
  8010f2:	53                   	push   %ebx
  8010f3:	83 ec 0c             	sub    $0xc,%esp
  8010f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010f9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *)-1;
  8010ff:	85 db                	test   %ebx,%ebx
  801101:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801106:	0f 44 d8             	cmove  %eax,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801109:	ff 75 14             	pushl  0x14(%ebp)
  80110c:	53                   	push   %ebx
  80110d:	56                   	push   %esi
  80110e:	57                   	push   %edi
  80110f:	e8 5b fc ff ff       	call   800d6f <sys_ipc_try_send>
		if (r == 0) {		
  801114:	83 c4 10             	add    $0x10,%esp
  801117:	85 c0                	test   %eax,%eax
  801119:	74 1e                	je     801139 <ipc_send+0x50>
			return;
		} else if (r == -E_IPC_NOT_RECV) {
  80111b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80111e:	75 07                	jne    801127 <ipc_send+0x3e>
			sys_yield();
  801120:	e8 c8 fa ff ff       	call   800bed <sys_yield>
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801125:	eb e2                	jmp    801109 <ipc_send+0x20>
		} else {			
			panic("ipc_send():%e", r);
  801127:	50                   	push   %eax
  801128:	68 12 18 80 00       	push   $0x801812
  80112d:	6a 41                	push   $0x41
  80112f:	68 20 18 80 00       	push   $0x801820
  801134:	e8 4b 00 00 00       	call   801184 <_panic>
		}
	}
}
  801139:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113c:	5b                   	pop    %ebx
  80113d:	5e                   	pop    %esi
  80113e:	5f                   	pop    %edi
  80113f:	5d                   	pop    %ebp
  801140:	c3                   	ret    

00801141 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801141:	f3 0f 1e fb          	endbr32 
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80114b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801150:	69 d0 84 00 00 00    	imul   $0x84,%eax,%edx
  801156:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80115c:	8b 52 50             	mov    0x50(%edx),%edx
  80115f:	39 ca                	cmp    %ecx,%edx
  801161:	74 11                	je     801174 <ipc_find_env+0x33>
	for (i = 0; i < NENV; i++)
  801163:	83 c0 01             	add    $0x1,%eax
  801166:	3d 00 04 00 00       	cmp    $0x400,%eax
  80116b:	75 e3                	jne    801150 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  80116d:	b8 00 00 00 00       	mov    $0x0,%eax
  801172:	eb 0e                	jmp    801182 <ipc_find_env+0x41>
			return envs[i].env_id;
  801174:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  80117a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80117f:	8b 40 48             	mov    0x48(%eax),%eax
}
  801182:	5d                   	pop    %ebp
  801183:	c3                   	ret    

00801184 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801184:	f3 0f 1e fb          	endbr32 
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
  80118b:	56                   	push   %esi
  80118c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80118d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801190:	8b 35 00 20 80 00    	mov    0x802000,%esi
  801196:	e8 2f fa ff ff       	call   800bca <sys_getenvid>
  80119b:	83 ec 0c             	sub    $0xc,%esp
  80119e:	ff 75 0c             	pushl  0xc(%ebp)
  8011a1:	ff 75 08             	pushl  0x8(%ebp)
  8011a4:	56                   	push   %esi
  8011a5:	50                   	push   %eax
  8011a6:	68 2c 18 80 00       	push   $0x80182c
  8011ab:	e8 14 f0 ff ff       	call   8001c4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8011b0:	83 c4 18             	add    $0x18,%esp
  8011b3:	53                   	push   %ebx
  8011b4:	ff 75 10             	pushl  0x10(%ebp)
  8011b7:	e8 b3 ef ff ff       	call   80016f <vcprintf>
	cprintf("\n");
  8011bc:	c7 04 24 e7 14 80 00 	movl   $0x8014e7,(%esp)
  8011c3:	e8 fc ef ff ff       	call   8001c4 <cprintf>
  8011c8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8011cb:	cc                   	int3   
  8011cc:	eb fd                	jmp    8011cb <_panic+0x47>

008011ce <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8011ce:	f3 0f 1e fb          	endbr32 
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8011d8:	83 3d 64 40 80 00 00 	cmpl   $0x0,0x804064
  8011df:	74 0a                	je     8011eb <set_pgfault_handler+0x1d>
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);		//系统调用，设置进程的env_pgfault_upcall属性
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8011e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e4:	a3 64 40 80 00       	mov    %eax,0x804064
}
  8011e9:	c9                   	leave  
  8011ea:	c3                   	ret    
		int r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_W | PTE_U | PTE_P);	//为当前进程分配异常栈
  8011eb:	83 ec 04             	sub    $0x4,%esp
  8011ee:	6a 07                	push   $0x7
  8011f0:	68 00 f0 bf ee       	push   $0xeebff000
  8011f5:	6a 00                	push   $0x0
  8011f7:	e8 14 fa ff ff       	call   800c10 <sys_page_alloc>
		if (r < 0) {
  8011fc:	83 c4 10             	add    $0x10,%esp
  8011ff:	85 c0                	test   %eax,%eax
  801201:	78 14                	js     801217 <set_pgfault_handler+0x49>
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);		//系统调用，设置进程的env_pgfault_upcall属性
  801203:	83 ec 08             	sub    $0x8,%esp
  801206:	68 2b 12 80 00       	push   $0x80122b
  80120b:	6a 00                	push   $0x0
  80120d:	e8 17 fb ff ff       	call   800d29 <sys_env_set_pgfault_upcall>
  801212:	83 c4 10             	add    $0x10,%esp
  801215:	eb ca                	jmp    8011e1 <set_pgfault_handler+0x13>
			panic("set_pgfault_handler:sys_page_alloc failed");;
  801217:	83 ec 04             	sub    $0x4,%esp
  80121a:	68 50 18 80 00       	push   $0x801850
  80121f:	6a 22                	push   $0x22
  801221:	68 7a 18 80 00       	push   $0x80187a
  801226:	e8 59 ff ff ff       	call   801184 <_panic>

0080122b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80122b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80122c:	a1 64 40 80 00       	mov    0x804064,%eax
	call *%eax				
  801231:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801233:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp			
  801236:	83 c4 08             	add    $0x8,%esp
	movl 40(%esp), %eax 	
  801239:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 32(%esp), %ecx 	
  80123d:	8b 4c 24 20          	mov    0x20(%esp),%ecx
	movl %ecx, -4(%eax) 	
  801241:	89 48 fc             	mov    %ecx,-0x4(%eax)
	popal
  801244:	61                   	popa   
	addl $4, %esp		
  801245:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popfl
  801248:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801249:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	lea -4(%esp), %esp	
  80124a:	8d 64 24 fc          	lea    -0x4(%esp),%esp
	ret
  80124e:	c3                   	ret    
  80124f:	90                   	nop

00801250 <__udivdi3>:
  801250:	f3 0f 1e fb          	endbr32 
  801254:	55                   	push   %ebp
  801255:	57                   	push   %edi
  801256:	56                   	push   %esi
  801257:	53                   	push   %ebx
  801258:	83 ec 1c             	sub    $0x1c,%esp
  80125b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80125f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801263:	8b 74 24 34          	mov    0x34(%esp),%esi
  801267:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80126b:	85 d2                	test   %edx,%edx
  80126d:	75 19                	jne    801288 <__udivdi3+0x38>
  80126f:	39 f3                	cmp    %esi,%ebx
  801271:	76 4d                	jbe    8012c0 <__udivdi3+0x70>
  801273:	31 ff                	xor    %edi,%edi
  801275:	89 e8                	mov    %ebp,%eax
  801277:	89 f2                	mov    %esi,%edx
  801279:	f7 f3                	div    %ebx
  80127b:	89 fa                	mov    %edi,%edx
  80127d:	83 c4 1c             	add    $0x1c,%esp
  801280:	5b                   	pop    %ebx
  801281:	5e                   	pop    %esi
  801282:	5f                   	pop    %edi
  801283:	5d                   	pop    %ebp
  801284:	c3                   	ret    
  801285:	8d 76 00             	lea    0x0(%esi),%esi
  801288:	39 f2                	cmp    %esi,%edx
  80128a:	76 14                	jbe    8012a0 <__udivdi3+0x50>
  80128c:	31 ff                	xor    %edi,%edi
  80128e:	31 c0                	xor    %eax,%eax
  801290:	89 fa                	mov    %edi,%edx
  801292:	83 c4 1c             	add    $0x1c,%esp
  801295:	5b                   	pop    %ebx
  801296:	5e                   	pop    %esi
  801297:	5f                   	pop    %edi
  801298:	5d                   	pop    %ebp
  801299:	c3                   	ret    
  80129a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012a0:	0f bd fa             	bsr    %edx,%edi
  8012a3:	83 f7 1f             	xor    $0x1f,%edi
  8012a6:	75 48                	jne    8012f0 <__udivdi3+0xa0>
  8012a8:	39 f2                	cmp    %esi,%edx
  8012aa:	72 06                	jb     8012b2 <__udivdi3+0x62>
  8012ac:	31 c0                	xor    %eax,%eax
  8012ae:	39 eb                	cmp    %ebp,%ebx
  8012b0:	77 de                	ja     801290 <__udivdi3+0x40>
  8012b2:	b8 01 00 00 00       	mov    $0x1,%eax
  8012b7:	eb d7                	jmp    801290 <__udivdi3+0x40>
  8012b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012c0:	89 d9                	mov    %ebx,%ecx
  8012c2:	85 db                	test   %ebx,%ebx
  8012c4:	75 0b                	jne    8012d1 <__udivdi3+0x81>
  8012c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8012cb:	31 d2                	xor    %edx,%edx
  8012cd:	f7 f3                	div    %ebx
  8012cf:	89 c1                	mov    %eax,%ecx
  8012d1:	31 d2                	xor    %edx,%edx
  8012d3:	89 f0                	mov    %esi,%eax
  8012d5:	f7 f1                	div    %ecx
  8012d7:	89 c6                	mov    %eax,%esi
  8012d9:	89 e8                	mov    %ebp,%eax
  8012db:	89 f7                	mov    %esi,%edi
  8012dd:	f7 f1                	div    %ecx
  8012df:	89 fa                	mov    %edi,%edx
  8012e1:	83 c4 1c             	add    $0x1c,%esp
  8012e4:	5b                   	pop    %ebx
  8012e5:	5e                   	pop    %esi
  8012e6:	5f                   	pop    %edi
  8012e7:	5d                   	pop    %ebp
  8012e8:	c3                   	ret    
  8012e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012f0:	89 f9                	mov    %edi,%ecx
  8012f2:	b8 20 00 00 00       	mov    $0x20,%eax
  8012f7:	29 f8                	sub    %edi,%eax
  8012f9:	d3 e2                	shl    %cl,%edx
  8012fb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8012ff:	89 c1                	mov    %eax,%ecx
  801301:	89 da                	mov    %ebx,%edx
  801303:	d3 ea                	shr    %cl,%edx
  801305:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801309:	09 d1                	or     %edx,%ecx
  80130b:	89 f2                	mov    %esi,%edx
  80130d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801311:	89 f9                	mov    %edi,%ecx
  801313:	d3 e3                	shl    %cl,%ebx
  801315:	89 c1                	mov    %eax,%ecx
  801317:	d3 ea                	shr    %cl,%edx
  801319:	89 f9                	mov    %edi,%ecx
  80131b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80131f:	89 eb                	mov    %ebp,%ebx
  801321:	d3 e6                	shl    %cl,%esi
  801323:	89 c1                	mov    %eax,%ecx
  801325:	d3 eb                	shr    %cl,%ebx
  801327:	09 de                	or     %ebx,%esi
  801329:	89 f0                	mov    %esi,%eax
  80132b:	f7 74 24 08          	divl   0x8(%esp)
  80132f:	89 d6                	mov    %edx,%esi
  801331:	89 c3                	mov    %eax,%ebx
  801333:	f7 64 24 0c          	mull   0xc(%esp)
  801337:	39 d6                	cmp    %edx,%esi
  801339:	72 15                	jb     801350 <__udivdi3+0x100>
  80133b:	89 f9                	mov    %edi,%ecx
  80133d:	d3 e5                	shl    %cl,%ebp
  80133f:	39 c5                	cmp    %eax,%ebp
  801341:	73 04                	jae    801347 <__udivdi3+0xf7>
  801343:	39 d6                	cmp    %edx,%esi
  801345:	74 09                	je     801350 <__udivdi3+0x100>
  801347:	89 d8                	mov    %ebx,%eax
  801349:	31 ff                	xor    %edi,%edi
  80134b:	e9 40 ff ff ff       	jmp    801290 <__udivdi3+0x40>
  801350:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801353:	31 ff                	xor    %edi,%edi
  801355:	e9 36 ff ff ff       	jmp    801290 <__udivdi3+0x40>
  80135a:	66 90                	xchg   %ax,%ax
  80135c:	66 90                	xchg   %ax,%ax
  80135e:	66 90                	xchg   %ax,%ax

00801360 <__umoddi3>:
  801360:	f3 0f 1e fb          	endbr32 
  801364:	55                   	push   %ebp
  801365:	57                   	push   %edi
  801366:	56                   	push   %esi
  801367:	53                   	push   %ebx
  801368:	83 ec 1c             	sub    $0x1c,%esp
  80136b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80136f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801373:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801377:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80137b:	85 c0                	test   %eax,%eax
  80137d:	75 19                	jne    801398 <__umoddi3+0x38>
  80137f:	39 df                	cmp    %ebx,%edi
  801381:	76 5d                	jbe    8013e0 <__umoddi3+0x80>
  801383:	89 f0                	mov    %esi,%eax
  801385:	89 da                	mov    %ebx,%edx
  801387:	f7 f7                	div    %edi
  801389:	89 d0                	mov    %edx,%eax
  80138b:	31 d2                	xor    %edx,%edx
  80138d:	83 c4 1c             	add    $0x1c,%esp
  801390:	5b                   	pop    %ebx
  801391:	5e                   	pop    %esi
  801392:	5f                   	pop    %edi
  801393:	5d                   	pop    %ebp
  801394:	c3                   	ret    
  801395:	8d 76 00             	lea    0x0(%esi),%esi
  801398:	89 f2                	mov    %esi,%edx
  80139a:	39 d8                	cmp    %ebx,%eax
  80139c:	76 12                	jbe    8013b0 <__umoddi3+0x50>
  80139e:	89 f0                	mov    %esi,%eax
  8013a0:	89 da                	mov    %ebx,%edx
  8013a2:	83 c4 1c             	add    $0x1c,%esp
  8013a5:	5b                   	pop    %ebx
  8013a6:	5e                   	pop    %esi
  8013a7:	5f                   	pop    %edi
  8013a8:	5d                   	pop    %ebp
  8013a9:	c3                   	ret    
  8013aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8013b0:	0f bd e8             	bsr    %eax,%ebp
  8013b3:	83 f5 1f             	xor    $0x1f,%ebp
  8013b6:	75 50                	jne    801408 <__umoddi3+0xa8>
  8013b8:	39 d8                	cmp    %ebx,%eax
  8013ba:	0f 82 e0 00 00 00    	jb     8014a0 <__umoddi3+0x140>
  8013c0:	89 d9                	mov    %ebx,%ecx
  8013c2:	39 f7                	cmp    %esi,%edi
  8013c4:	0f 86 d6 00 00 00    	jbe    8014a0 <__umoddi3+0x140>
  8013ca:	89 d0                	mov    %edx,%eax
  8013cc:	89 ca                	mov    %ecx,%edx
  8013ce:	83 c4 1c             	add    $0x1c,%esp
  8013d1:	5b                   	pop    %ebx
  8013d2:	5e                   	pop    %esi
  8013d3:	5f                   	pop    %edi
  8013d4:	5d                   	pop    %ebp
  8013d5:	c3                   	ret    
  8013d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8013dd:	8d 76 00             	lea    0x0(%esi),%esi
  8013e0:	89 fd                	mov    %edi,%ebp
  8013e2:	85 ff                	test   %edi,%edi
  8013e4:	75 0b                	jne    8013f1 <__umoddi3+0x91>
  8013e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013eb:	31 d2                	xor    %edx,%edx
  8013ed:	f7 f7                	div    %edi
  8013ef:	89 c5                	mov    %eax,%ebp
  8013f1:	89 d8                	mov    %ebx,%eax
  8013f3:	31 d2                	xor    %edx,%edx
  8013f5:	f7 f5                	div    %ebp
  8013f7:	89 f0                	mov    %esi,%eax
  8013f9:	f7 f5                	div    %ebp
  8013fb:	89 d0                	mov    %edx,%eax
  8013fd:	31 d2                	xor    %edx,%edx
  8013ff:	eb 8c                	jmp    80138d <__umoddi3+0x2d>
  801401:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801408:	89 e9                	mov    %ebp,%ecx
  80140a:	ba 20 00 00 00       	mov    $0x20,%edx
  80140f:	29 ea                	sub    %ebp,%edx
  801411:	d3 e0                	shl    %cl,%eax
  801413:	89 44 24 08          	mov    %eax,0x8(%esp)
  801417:	89 d1                	mov    %edx,%ecx
  801419:	89 f8                	mov    %edi,%eax
  80141b:	d3 e8                	shr    %cl,%eax
  80141d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801421:	89 54 24 04          	mov    %edx,0x4(%esp)
  801425:	8b 54 24 04          	mov    0x4(%esp),%edx
  801429:	09 c1                	or     %eax,%ecx
  80142b:	89 d8                	mov    %ebx,%eax
  80142d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801431:	89 e9                	mov    %ebp,%ecx
  801433:	d3 e7                	shl    %cl,%edi
  801435:	89 d1                	mov    %edx,%ecx
  801437:	d3 e8                	shr    %cl,%eax
  801439:	89 e9                	mov    %ebp,%ecx
  80143b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80143f:	d3 e3                	shl    %cl,%ebx
  801441:	89 c7                	mov    %eax,%edi
  801443:	89 d1                	mov    %edx,%ecx
  801445:	89 f0                	mov    %esi,%eax
  801447:	d3 e8                	shr    %cl,%eax
  801449:	89 e9                	mov    %ebp,%ecx
  80144b:	89 fa                	mov    %edi,%edx
  80144d:	d3 e6                	shl    %cl,%esi
  80144f:	09 d8                	or     %ebx,%eax
  801451:	f7 74 24 08          	divl   0x8(%esp)
  801455:	89 d1                	mov    %edx,%ecx
  801457:	89 f3                	mov    %esi,%ebx
  801459:	f7 64 24 0c          	mull   0xc(%esp)
  80145d:	89 c6                	mov    %eax,%esi
  80145f:	89 d7                	mov    %edx,%edi
  801461:	39 d1                	cmp    %edx,%ecx
  801463:	72 06                	jb     80146b <__umoddi3+0x10b>
  801465:	75 10                	jne    801477 <__umoddi3+0x117>
  801467:	39 c3                	cmp    %eax,%ebx
  801469:	73 0c                	jae    801477 <__umoddi3+0x117>
  80146b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80146f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801473:	89 d7                	mov    %edx,%edi
  801475:	89 c6                	mov    %eax,%esi
  801477:	89 ca                	mov    %ecx,%edx
  801479:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80147e:	29 f3                	sub    %esi,%ebx
  801480:	19 fa                	sbb    %edi,%edx
  801482:	89 d0                	mov    %edx,%eax
  801484:	d3 e0                	shl    %cl,%eax
  801486:	89 e9                	mov    %ebp,%ecx
  801488:	d3 eb                	shr    %cl,%ebx
  80148a:	d3 ea                	shr    %cl,%edx
  80148c:	09 d8                	or     %ebx,%eax
  80148e:	83 c4 1c             	add    $0x1c,%esp
  801491:	5b                   	pop    %ebx
  801492:	5e                   	pop    %esi
  801493:	5f                   	pop    %edi
  801494:	5d                   	pop    %ebp
  801495:	c3                   	ret    
  801496:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80149d:	8d 76 00             	lea    0x0(%esi),%esi
  8014a0:	29 fe                	sub    %edi,%esi
  8014a2:	19 c3                	sbb    %eax,%ebx
  8014a4:	89 f2                	mov    %esi,%edx
  8014a6:	89 d9                	mov    %ebx,%ecx
  8014a8:	e9 1d ff ff ff       	jmp    8013ca <__umoddi3+0x6a>
