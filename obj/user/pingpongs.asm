
obj/user/pingpongs:     file format elf32-i386


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
  80002c:	e8 d6 00 00 00       	call   800107 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	57                   	push   %edi
  80003b:	56                   	push   %esi
  80003c:	53                   	push   %ebx
  80003d:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  800040:	e8 5c 10 00 00       	call   8010a1 <sfork>
  800045:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800048:	85 c0                	test   %eax,%eax
  80004a:	75 74                	jne    8000c0 <umain+0x8d>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80004c:	83 ec 04             	sub    $0x4,%esp
  80004f:	6a 00                	push   $0x0
  800051:	6a 00                	push   $0x0
  800053:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800056:	50                   	push   %eax
  800057:	e8 63 10 00 00       	call   8010bf <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80005c:	8b 1d 60 40 80 00    	mov    0x804060,%ebx
  800062:	8b 7b 48             	mov    0x48(%ebx),%edi
  800065:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800068:	a1 50 20 80 00       	mov    0x802050,%eax
  80006d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800070:	e8 98 0b 00 00       	call   800c0d <sys_getenvid>
  800075:	83 c4 08             	add    $0x8,%esp
  800078:	57                   	push   %edi
  800079:	53                   	push   %ebx
  80007a:	56                   	push   %esi
  80007b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80007e:	50                   	push   %eax
  80007f:	68 30 15 80 00       	push   $0x801530
  800084:	e8 7e 01 00 00       	call   800207 <cprintf>
		if (val == 10)
  800089:	a1 50 20 80 00       	mov    0x802050,%eax
  80008e:	83 c4 20             	add    $0x20,%esp
  800091:	83 f8 0a             	cmp    $0xa,%eax
  800094:	74 22                	je     8000b8 <umain+0x85>
			return;
		++val;
  800096:	83 c0 01             	add    $0x1,%eax
  800099:	a3 50 20 80 00       	mov    %eax,0x802050
		ipc_send(who, 0, 0, 0);
  80009e:	6a 00                	push   $0x0
  8000a0:	6a 00                	push   $0x0
  8000a2:	6a 00                	push   $0x0
  8000a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a7:	e8 80 10 00 00       	call   80112c <ipc_send>
		if (val == 10)
  8000ac:	83 c4 10             	add    $0x10,%esp
  8000af:	83 3d 50 20 80 00 0a 	cmpl   $0xa,0x802050
  8000b6:	75 94                	jne    80004c <umain+0x19>
			return;
	}

}
  8000b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  8000c0:	8b 1d 60 40 80 00    	mov    0x804060,%ebx
  8000c6:	e8 42 0b 00 00       	call   800c0d <sys_getenvid>
  8000cb:	83 ec 04             	sub    $0x4,%esp
  8000ce:	53                   	push   %ebx
  8000cf:	50                   	push   %eax
  8000d0:	68 00 15 80 00       	push   $0x801500
  8000d5:	e8 2d 01 00 00       	call   800207 <cprintf>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  8000da:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8000dd:	e8 2b 0b 00 00       	call   800c0d <sys_getenvid>
  8000e2:	83 c4 0c             	add    $0xc,%esp
  8000e5:	53                   	push   %ebx
  8000e6:	50                   	push   %eax
  8000e7:	68 1a 15 80 00       	push   $0x80151a
  8000ec:	e8 16 01 00 00       	call   800207 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000f1:	6a 00                	push   $0x0
  8000f3:	6a 00                	push   $0x0
  8000f5:	6a 00                	push   $0x0
  8000f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000fa:	e8 2d 10 00 00       	call   80112c <ipc_send>
  8000ff:	83 c4 20             	add    $0x20,%esp
  800102:	e9 45 ff ff ff       	jmp    80004c <umain+0x19>

00800107 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800107:	f3 0f 1e fb          	endbr32 
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	56                   	push   %esi
  80010f:	53                   	push   %ebx
  800110:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800113:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800116:	e8 f2 0a 00 00       	call   800c0d <sys_getenvid>
	thisenv = envs + ENVX(envid);
  80011b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800120:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  800126:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80012b:	a3 60 40 80 00       	mov    %eax,0x804060

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800130:	85 db                	test   %ebx,%ebx
  800132:	7e 07                	jle    80013b <libmain+0x34>
		binaryname = argv[0];
  800134:	8b 06                	mov    (%esi),%eax
  800136:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80013b:	83 ec 08             	sub    $0x8,%esp
  80013e:	56                   	push   %esi
  80013f:	53                   	push   %ebx
  800140:	e8 ee fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800145:	e8 0a 00 00 00       	call   800154 <exit>
}
  80014a:	83 c4 10             	add    $0x10,%esp
  80014d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800150:	5b                   	pop    %ebx
  800151:	5e                   	pop    %esi
  800152:	5d                   	pop    %ebp
  800153:	c3                   	ret    

00800154 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800154:	f3 0f 1e fb          	endbr32 
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80015e:	6a 00                	push   $0x0
  800160:	e8 63 0a 00 00       	call   800bc8 <sys_env_destroy>
}
  800165:	83 c4 10             	add    $0x10,%esp
  800168:	c9                   	leave  
  800169:	c3                   	ret    

0080016a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80016a:	f3 0f 1e fb          	endbr32 
  80016e:	55                   	push   %ebp
  80016f:	89 e5                	mov    %esp,%ebp
  800171:	53                   	push   %ebx
  800172:	83 ec 04             	sub    $0x4,%esp
  800175:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800178:	8b 13                	mov    (%ebx),%edx
  80017a:	8d 42 01             	lea    0x1(%edx),%eax
  80017d:	89 03                	mov    %eax,(%ebx)
  80017f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800182:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800186:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018b:	74 09                	je     800196 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80018d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800191:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800194:	c9                   	leave  
  800195:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800196:	83 ec 08             	sub    $0x8,%esp
  800199:	68 ff 00 00 00       	push   $0xff
  80019e:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a1:	50                   	push   %eax
  8001a2:	e8 dc 09 00 00       	call   800b83 <sys_cputs>
		b->idx = 0;
  8001a7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001ad:	83 c4 10             	add    $0x10,%esp
  8001b0:	eb db                	jmp    80018d <putch+0x23>

008001b2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b2:	f3 0f 1e fb          	endbr32 
  8001b6:	55                   	push   %ebp
  8001b7:	89 e5                	mov    %esp,%ebp
  8001b9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001bf:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c6:	00 00 00 
	b.cnt = 0;
  8001c9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d3:	ff 75 0c             	pushl  0xc(%ebp)
  8001d6:	ff 75 08             	pushl  0x8(%ebp)
  8001d9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001df:	50                   	push   %eax
  8001e0:	68 6a 01 80 00       	push   $0x80016a
  8001e5:	e8 20 01 00 00       	call   80030a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ea:	83 c4 08             	add    $0x8,%esp
  8001ed:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001f3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f9:	50                   	push   %eax
  8001fa:	e8 84 09 00 00       	call   800b83 <sys_cputs>

	return b.cnt;
}
  8001ff:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800205:	c9                   	leave  
  800206:	c3                   	ret    

00800207 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800207:	f3 0f 1e fb          	endbr32 
  80020b:	55                   	push   %ebp
  80020c:	89 e5                	mov    %esp,%ebp
  80020e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800211:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800214:	50                   	push   %eax
  800215:	ff 75 08             	pushl  0x8(%ebp)
  800218:	e8 95 ff ff ff       	call   8001b2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80021d:	c9                   	leave  
  80021e:	c3                   	ret    

0080021f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80021f:	55                   	push   %ebp
  800220:	89 e5                	mov    %esp,%ebp
  800222:	57                   	push   %edi
  800223:	56                   	push   %esi
  800224:	53                   	push   %ebx
  800225:	83 ec 1c             	sub    $0x1c,%esp
  800228:	89 c7                	mov    %eax,%edi
  80022a:	89 d6                	mov    %edx,%esi
  80022c:	8b 45 08             	mov    0x8(%ebp),%eax
  80022f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800232:	89 d1                	mov    %edx,%ecx
  800234:	89 c2                	mov    %eax,%edx
  800236:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800239:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80023c:	8b 45 10             	mov    0x10(%ebp),%eax
  80023f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800242:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800245:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80024c:	39 c2                	cmp    %eax,%edx
  80024e:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800251:	72 3e                	jb     800291 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800253:	83 ec 0c             	sub    $0xc,%esp
  800256:	ff 75 18             	pushl  0x18(%ebp)
  800259:	83 eb 01             	sub    $0x1,%ebx
  80025c:	53                   	push   %ebx
  80025d:	50                   	push   %eax
  80025e:	83 ec 08             	sub    $0x8,%esp
  800261:	ff 75 e4             	pushl  -0x1c(%ebp)
  800264:	ff 75 e0             	pushl  -0x20(%ebp)
  800267:	ff 75 dc             	pushl  -0x24(%ebp)
  80026a:	ff 75 d8             	pushl  -0x28(%ebp)
  80026d:	e8 2e 10 00 00       	call   8012a0 <__udivdi3>
  800272:	83 c4 18             	add    $0x18,%esp
  800275:	52                   	push   %edx
  800276:	50                   	push   %eax
  800277:	89 f2                	mov    %esi,%edx
  800279:	89 f8                	mov    %edi,%eax
  80027b:	e8 9f ff ff ff       	call   80021f <printnum>
  800280:	83 c4 20             	add    $0x20,%esp
  800283:	eb 13                	jmp    800298 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	56                   	push   %esi
  800289:	ff 75 18             	pushl  0x18(%ebp)
  80028c:	ff d7                	call   *%edi
  80028e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800291:	83 eb 01             	sub    $0x1,%ebx
  800294:	85 db                	test   %ebx,%ebx
  800296:	7f ed                	jg     800285 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800298:	83 ec 08             	sub    $0x8,%esp
  80029b:	56                   	push   %esi
  80029c:	83 ec 04             	sub    $0x4,%esp
  80029f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a5:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a8:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ab:	e8 00 11 00 00       	call   8013b0 <__umoddi3>
  8002b0:	83 c4 14             	add    $0x14,%esp
  8002b3:	0f be 80 60 15 80 00 	movsbl 0x801560(%eax),%eax
  8002ba:	50                   	push   %eax
  8002bb:	ff d7                	call   *%edi
}
  8002bd:	83 c4 10             	add    $0x10,%esp
  8002c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c3:	5b                   	pop    %ebx
  8002c4:	5e                   	pop    %esi
  8002c5:	5f                   	pop    %edi
  8002c6:	5d                   	pop    %ebp
  8002c7:	c3                   	ret    

008002c8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c8:	f3 0f 1e fb          	endbr32 
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d6:	8b 10                	mov    (%eax),%edx
  8002d8:	3b 50 04             	cmp    0x4(%eax),%edx
  8002db:	73 0a                	jae    8002e7 <sprintputch+0x1f>
		*b->buf++ = ch;
  8002dd:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e0:	89 08                	mov    %ecx,(%eax)
  8002e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e5:	88 02                	mov    %al,(%edx)
}
  8002e7:	5d                   	pop    %ebp
  8002e8:	c3                   	ret    

008002e9 <printfmt>:
{
  8002e9:	f3 0f 1e fb          	endbr32 
  8002ed:	55                   	push   %ebp
  8002ee:	89 e5                	mov    %esp,%ebp
  8002f0:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002f3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f6:	50                   	push   %eax
  8002f7:	ff 75 10             	pushl  0x10(%ebp)
  8002fa:	ff 75 0c             	pushl  0xc(%ebp)
  8002fd:	ff 75 08             	pushl  0x8(%ebp)
  800300:	e8 05 00 00 00       	call   80030a <vprintfmt>
}
  800305:	83 c4 10             	add    $0x10,%esp
  800308:	c9                   	leave  
  800309:	c3                   	ret    

0080030a <vprintfmt>:
{
  80030a:	f3 0f 1e fb          	endbr32 
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
  800314:	83 ec 3c             	sub    $0x3c,%esp
  800317:	8b 75 08             	mov    0x8(%ebp),%esi
  80031a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80031d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800320:	e9 8e 03 00 00       	jmp    8006b3 <vprintfmt+0x3a9>
		padc = ' ';
  800325:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800329:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800330:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800337:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80033e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800343:	8d 47 01             	lea    0x1(%edi),%eax
  800346:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800349:	0f b6 17             	movzbl (%edi),%edx
  80034c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80034f:	3c 55                	cmp    $0x55,%al
  800351:	0f 87 df 03 00 00    	ja     800736 <vprintfmt+0x42c>
  800357:	0f b6 c0             	movzbl %al,%eax
  80035a:	3e ff 24 85 20 16 80 	notrack jmp *0x801620(,%eax,4)
  800361:	00 
  800362:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800365:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800369:	eb d8                	jmp    800343 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80036b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80036e:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800372:	eb cf                	jmp    800343 <vprintfmt+0x39>
  800374:	0f b6 d2             	movzbl %dl,%edx
  800377:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80037a:	b8 00 00 00 00       	mov    $0x0,%eax
  80037f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800382:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800385:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800389:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80038c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80038f:	83 f9 09             	cmp    $0x9,%ecx
  800392:	77 55                	ja     8003e9 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800394:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800397:	eb e9                	jmp    800382 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800399:	8b 45 14             	mov    0x14(%ebp),%eax
  80039c:	8b 00                	mov    (%eax),%eax
  80039e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a4:	8d 40 04             	lea    0x4(%eax),%eax
  8003a7:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003ad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b1:	79 90                	jns    800343 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003b3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003b6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b9:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003c0:	eb 81                	jmp    800343 <vprintfmt+0x39>
  8003c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c5:	85 c0                	test   %eax,%eax
  8003c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003cc:	0f 49 d0             	cmovns %eax,%edx
  8003cf:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003d5:	e9 69 ff ff ff       	jmp    800343 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003dd:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003e4:	e9 5a ff ff ff       	jmp    800343 <vprintfmt+0x39>
  8003e9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ef:	eb bc                	jmp    8003ad <vprintfmt+0xa3>
			lflag++;
  8003f1:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003f7:	e9 47 ff ff ff       	jmp    800343 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ff:	8d 78 04             	lea    0x4(%eax),%edi
  800402:	83 ec 08             	sub    $0x8,%esp
  800405:	53                   	push   %ebx
  800406:	ff 30                	pushl  (%eax)
  800408:	ff d6                	call   *%esi
			break;
  80040a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80040d:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800410:	e9 9b 02 00 00       	jmp    8006b0 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800415:	8b 45 14             	mov    0x14(%ebp),%eax
  800418:	8d 78 04             	lea    0x4(%eax),%edi
  80041b:	8b 00                	mov    (%eax),%eax
  80041d:	99                   	cltd   
  80041e:	31 d0                	xor    %edx,%eax
  800420:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800422:	83 f8 08             	cmp    $0x8,%eax
  800425:	7f 23                	jg     80044a <vprintfmt+0x140>
  800427:	8b 14 85 80 17 80 00 	mov    0x801780(,%eax,4),%edx
  80042e:	85 d2                	test   %edx,%edx
  800430:	74 18                	je     80044a <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  800432:	52                   	push   %edx
  800433:	68 81 15 80 00       	push   $0x801581
  800438:	53                   	push   %ebx
  800439:	56                   	push   %esi
  80043a:	e8 aa fe ff ff       	call   8002e9 <printfmt>
  80043f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800442:	89 7d 14             	mov    %edi,0x14(%ebp)
  800445:	e9 66 02 00 00       	jmp    8006b0 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  80044a:	50                   	push   %eax
  80044b:	68 78 15 80 00       	push   $0x801578
  800450:	53                   	push   %ebx
  800451:	56                   	push   %esi
  800452:	e8 92 fe ff ff       	call   8002e9 <printfmt>
  800457:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80045a:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80045d:	e9 4e 02 00 00       	jmp    8006b0 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800462:	8b 45 14             	mov    0x14(%ebp),%eax
  800465:	83 c0 04             	add    $0x4,%eax
  800468:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80046b:	8b 45 14             	mov    0x14(%ebp),%eax
  80046e:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800470:	85 d2                	test   %edx,%edx
  800472:	b8 71 15 80 00       	mov    $0x801571,%eax
  800477:	0f 45 c2             	cmovne %edx,%eax
  80047a:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80047d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800481:	7e 06                	jle    800489 <vprintfmt+0x17f>
  800483:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800487:	75 0d                	jne    800496 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800489:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80048c:	89 c7                	mov    %eax,%edi
  80048e:	03 45 e0             	add    -0x20(%ebp),%eax
  800491:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800494:	eb 55                	jmp    8004eb <vprintfmt+0x1e1>
  800496:	83 ec 08             	sub    $0x8,%esp
  800499:	ff 75 d8             	pushl  -0x28(%ebp)
  80049c:	ff 75 cc             	pushl  -0x34(%ebp)
  80049f:	e8 46 03 00 00       	call   8007ea <strnlen>
  8004a4:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004a7:	29 c2                	sub    %eax,%edx
  8004a9:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8004ac:	83 c4 10             	add    $0x10,%esp
  8004af:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8004b1:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b8:	85 ff                	test   %edi,%edi
  8004ba:	7e 11                	jle    8004cd <vprintfmt+0x1c3>
					putch(padc, putdat);
  8004bc:	83 ec 08             	sub    $0x8,%esp
  8004bf:	53                   	push   %ebx
  8004c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c3:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c5:	83 ef 01             	sub    $0x1,%edi
  8004c8:	83 c4 10             	add    $0x10,%esp
  8004cb:	eb eb                	jmp    8004b8 <vprintfmt+0x1ae>
  8004cd:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004d0:	85 d2                	test   %edx,%edx
  8004d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d7:	0f 49 c2             	cmovns %edx,%eax
  8004da:	29 c2                	sub    %eax,%edx
  8004dc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004df:	eb a8                	jmp    800489 <vprintfmt+0x17f>
					putch(ch, putdat);
  8004e1:	83 ec 08             	sub    $0x8,%esp
  8004e4:	53                   	push   %ebx
  8004e5:	52                   	push   %edx
  8004e6:	ff d6                	call   *%esi
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ee:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f0:	83 c7 01             	add    $0x1,%edi
  8004f3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f7:	0f be d0             	movsbl %al,%edx
  8004fa:	85 d2                	test   %edx,%edx
  8004fc:	74 4b                	je     800549 <vprintfmt+0x23f>
  8004fe:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800502:	78 06                	js     80050a <vprintfmt+0x200>
  800504:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800508:	78 1e                	js     800528 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  80050a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80050e:	74 d1                	je     8004e1 <vprintfmt+0x1d7>
  800510:	0f be c0             	movsbl %al,%eax
  800513:	83 e8 20             	sub    $0x20,%eax
  800516:	83 f8 5e             	cmp    $0x5e,%eax
  800519:	76 c6                	jbe    8004e1 <vprintfmt+0x1d7>
					putch('?', putdat);
  80051b:	83 ec 08             	sub    $0x8,%esp
  80051e:	53                   	push   %ebx
  80051f:	6a 3f                	push   $0x3f
  800521:	ff d6                	call   *%esi
  800523:	83 c4 10             	add    $0x10,%esp
  800526:	eb c3                	jmp    8004eb <vprintfmt+0x1e1>
  800528:	89 cf                	mov    %ecx,%edi
  80052a:	eb 0e                	jmp    80053a <vprintfmt+0x230>
				putch(' ', putdat);
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	53                   	push   %ebx
  800530:	6a 20                	push   $0x20
  800532:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800534:	83 ef 01             	sub    $0x1,%edi
  800537:	83 c4 10             	add    $0x10,%esp
  80053a:	85 ff                	test   %edi,%edi
  80053c:	7f ee                	jg     80052c <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80053e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800541:	89 45 14             	mov    %eax,0x14(%ebp)
  800544:	e9 67 01 00 00       	jmp    8006b0 <vprintfmt+0x3a6>
  800549:	89 cf                	mov    %ecx,%edi
  80054b:	eb ed                	jmp    80053a <vprintfmt+0x230>
	if (lflag >= 2)
  80054d:	83 f9 01             	cmp    $0x1,%ecx
  800550:	7f 1b                	jg     80056d <vprintfmt+0x263>
	else if (lflag)
  800552:	85 c9                	test   %ecx,%ecx
  800554:	74 63                	je     8005b9 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800556:	8b 45 14             	mov    0x14(%ebp),%eax
  800559:	8b 00                	mov    (%eax),%eax
  80055b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055e:	99                   	cltd   
  80055f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800562:	8b 45 14             	mov    0x14(%ebp),%eax
  800565:	8d 40 04             	lea    0x4(%eax),%eax
  800568:	89 45 14             	mov    %eax,0x14(%ebp)
  80056b:	eb 17                	jmp    800584 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8b 50 04             	mov    0x4(%eax),%edx
  800573:	8b 00                	mov    (%eax),%eax
  800575:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800578:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057b:	8b 45 14             	mov    0x14(%ebp),%eax
  80057e:	8d 40 08             	lea    0x8(%eax),%eax
  800581:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800584:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800587:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80058a:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80058f:	85 c9                	test   %ecx,%ecx
  800591:	0f 89 ff 00 00 00    	jns    800696 <vprintfmt+0x38c>
				putch('-', putdat);
  800597:	83 ec 08             	sub    $0x8,%esp
  80059a:	53                   	push   %ebx
  80059b:	6a 2d                	push   $0x2d
  80059d:	ff d6                	call   *%esi
				num = -(long long) num;
  80059f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005a5:	f7 da                	neg    %edx
  8005a7:	83 d1 00             	adc    $0x0,%ecx
  8005aa:	f7 d9                	neg    %ecx
  8005ac:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005af:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b4:	e9 dd 00 00 00       	jmp    800696 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8b 00                	mov    (%eax),%eax
  8005be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c1:	99                   	cltd   
  8005c2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c8:	8d 40 04             	lea    0x4(%eax),%eax
  8005cb:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ce:	eb b4                	jmp    800584 <vprintfmt+0x27a>
	if (lflag >= 2)
  8005d0:	83 f9 01             	cmp    $0x1,%ecx
  8005d3:	7f 1e                	jg     8005f3 <vprintfmt+0x2e9>
	else if (lflag)
  8005d5:	85 c9                	test   %ecx,%ecx
  8005d7:	74 32                	je     80060b <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8b 10                	mov    (%eax),%edx
  8005de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e3:	8d 40 04             	lea    0x4(%eax),%eax
  8005e6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e9:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  8005ee:	e9 a3 00 00 00       	jmp    800696 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8b 10                	mov    (%eax),%edx
  8005f8:	8b 48 04             	mov    0x4(%eax),%ecx
  8005fb:	8d 40 08             	lea    0x8(%eax),%eax
  8005fe:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800601:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800606:	e9 8b 00 00 00       	jmp    800696 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8b 10                	mov    (%eax),%edx
  800610:	b9 00 00 00 00       	mov    $0x0,%ecx
  800615:	8d 40 04             	lea    0x4(%eax),%eax
  800618:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80061b:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800620:	eb 74                	jmp    800696 <vprintfmt+0x38c>
	if (lflag >= 2)
  800622:	83 f9 01             	cmp    $0x1,%ecx
  800625:	7f 1b                	jg     800642 <vprintfmt+0x338>
	else if (lflag)
  800627:	85 c9                	test   %ecx,%ecx
  800629:	74 2c                	je     800657 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  80062b:	8b 45 14             	mov    0x14(%ebp),%eax
  80062e:	8b 10                	mov    (%eax),%edx
  800630:	b9 00 00 00 00       	mov    $0x0,%ecx
  800635:	8d 40 04             	lea    0x4(%eax),%eax
  800638:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80063b:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800640:	eb 54                	jmp    800696 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8b 10                	mov    (%eax),%edx
  800647:	8b 48 04             	mov    0x4(%eax),%ecx
  80064a:	8d 40 08             	lea    0x8(%eax),%eax
  80064d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800650:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800655:	eb 3f                	jmp    800696 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8b 10                	mov    (%eax),%edx
  80065c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800661:	8d 40 04             	lea    0x4(%eax),%eax
  800664:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800667:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  80066c:	eb 28                	jmp    800696 <vprintfmt+0x38c>
			putch('0', putdat);
  80066e:	83 ec 08             	sub    $0x8,%esp
  800671:	53                   	push   %ebx
  800672:	6a 30                	push   $0x30
  800674:	ff d6                	call   *%esi
			putch('x', putdat);
  800676:	83 c4 08             	add    $0x8,%esp
  800679:	53                   	push   %ebx
  80067a:	6a 78                	push   $0x78
  80067c:	ff d6                	call   *%esi
			num = (unsigned long long)
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8b 10                	mov    (%eax),%edx
  800683:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800688:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80068b:	8d 40 04             	lea    0x4(%eax),%eax
  80068e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800691:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800696:	83 ec 0c             	sub    $0xc,%esp
  800699:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80069d:	57                   	push   %edi
  80069e:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a1:	50                   	push   %eax
  8006a2:	51                   	push   %ecx
  8006a3:	52                   	push   %edx
  8006a4:	89 da                	mov    %ebx,%edx
  8006a6:	89 f0                	mov    %esi,%eax
  8006a8:	e8 72 fb ff ff       	call   80021f <printnum>
			break;
  8006ad:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8006b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {	
  8006b3:	83 c7 01             	add    $0x1,%edi
  8006b6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006ba:	83 f8 25             	cmp    $0x25,%eax
  8006bd:	0f 84 62 fc ff ff    	je     800325 <vprintfmt+0x1b>
			if (ch == '\0')										
  8006c3:	85 c0                	test   %eax,%eax
  8006c5:	0f 84 8b 00 00 00    	je     800756 <vprintfmt+0x44c>
			putch(ch, putdat);
  8006cb:	83 ec 08             	sub    $0x8,%esp
  8006ce:	53                   	push   %ebx
  8006cf:	50                   	push   %eax
  8006d0:	ff d6                	call   *%esi
  8006d2:	83 c4 10             	add    $0x10,%esp
  8006d5:	eb dc                	jmp    8006b3 <vprintfmt+0x3a9>
	if (lflag >= 2)
  8006d7:	83 f9 01             	cmp    $0x1,%ecx
  8006da:	7f 1b                	jg     8006f7 <vprintfmt+0x3ed>
	else if (lflag)
  8006dc:	85 c9                	test   %ecx,%ecx
  8006de:	74 2c                	je     80070c <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	8b 10                	mov    (%eax),%edx
  8006e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ea:	8d 40 04             	lea    0x4(%eax),%eax
  8006ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f0:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  8006f5:	eb 9f                	jmp    800696 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	8b 10                	mov    (%eax),%edx
  8006fc:	8b 48 04             	mov    0x4(%eax),%ecx
  8006ff:	8d 40 08             	lea    0x8(%eax),%eax
  800702:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800705:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  80070a:	eb 8a                	jmp    800696 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80070c:	8b 45 14             	mov    0x14(%ebp),%eax
  80070f:	8b 10                	mov    (%eax),%edx
  800711:	b9 00 00 00 00       	mov    $0x0,%ecx
  800716:	8d 40 04             	lea    0x4(%eax),%eax
  800719:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80071c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800721:	e9 70 ff ff ff       	jmp    800696 <vprintfmt+0x38c>
			putch(ch, putdat);
  800726:	83 ec 08             	sub    $0x8,%esp
  800729:	53                   	push   %ebx
  80072a:	6a 25                	push   $0x25
  80072c:	ff d6                	call   *%esi
			break;
  80072e:	83 c4 10             	add    $0x10,%esp
  800731:	e9 7a ff ff ff       	jmp    8006b0 <vprintfmt+0x3a6>
			putch('%', putdat);
  800736:	83 ec 08             	sub    $0x8,%esp
  800739:	53                   	push   %ebx
  80073a:	6a 25                	push   $0x25
  80073c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80073e:	83 c4 10             	add    $0x10,%esp
  800741:	89 f8                	mov    %edi,%eax
  800743:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800747:	74 05                	je     80074e <vprintfmt+0x444>
  800749:	83 e8 01             	sub    $0x1,%eax
  80074c:	eb f5                	jmp    800743 <vprintfmt+0x439>
  80074e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800751:	e9 5a ff ff ff       	jmp    8006b0 <vprintfmt+0x3a6>
}
  800756:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800759:	5b                   	pop    %ebx
  80075a:	5e                   	pop    %esi
  80075b:	5f                   	pop    %edi
  80075c:	5d                   	pop    %ebp
  80075d:	c3                   	ret    

0080075e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80075e:	f3 0f 1e fb          	endbr32 
  800762:	55                   	push   %ebp
  800763:	89 e5                	mov    %esp,%ebp
  800765:	83 ec 18             	sub    $0x18,%esp
  800768:	8b 45 08             	mov    0x8(%ebp),%eax
  80076b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80076e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800771:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800775:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800778:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80077f:	85 c0                	test   %eax,%eax
  800781:	74 26                	je     8007a9 <vsnprintf+0x4b>
  800783:	85 d2                	test   %edx,%edx
  800785:	7e 22                	jle    8007a9 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800787:	ff 75 14             	pushl  0x14(%ebp)
  80078a:	ff 75 10             	pushl  0x10(%ebp)
  80078d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800790:	50                   	push   %eax
  800791:	68 c8 02 80 00       	push   $0x8002c8
  800796:	e8 6f fb ff ff       	call   80030a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80079b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80079e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a4:	83 c4 10             	add    $0x10,%esp
}
  8007a7:	c9                   	leave  
  8007a8:	c3                   	ret    
		return -E_INVAL;
  8007a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ae:	eb f7                	jmp    8007a7 <vsnprintf+0x49>

008007b0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b0:	f3 0f 1e fb          	endbr32 
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ba:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007bd:	50                   	push   %eax
  8007be:	ff 75 10             	pushl  0x10(%ebp)
  8007c1:	ff 75 0c             	pushl  0xc(%ebp)
  8007c4:	ff 75 08             	pushl  0x8(%ebp)
  8007c7:	e8 92 ff ff ff       	call   80075e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007cc:	c9                   	leave  
  8007cd:	c3                   	ret    

008007ce <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ce:	f3 0f 1e fb          	endbr32 
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007dd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e1:	74 05                	je     8007e8 <strlen+0x1a>
		n++;
  8007e3:	83 c0 01             	add    $0x1,%eax
  8007e6:	eb f5                	jmp    8007dd <strlen+0xf>
	return n;
}
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ea:	f3 0f 1e fb          	endbr32 
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fc:	39 d0                	cmp    %edx,%eax
  8007fe:	74 0d                	je     80080d <strnlen+0x23>
  800800:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800804:	74 05                	je     80080b <strnlen+0x21>
		n++;
  800806:	83 c0 01             	add    $0x1,%eax
  800809:	eb f1                	jmp    8007fc <strnlen+0x12>
  80080b:	89 c2                	mov    %eax,%edx
	return n;
}
  80080d:	89 d0                	mov    %edx,%eax
  80080f:	5d                   	pop    %ebp
  800810:	c3                   	ret    

00800811 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800811:	f3 0f 1e fb          	endbr32 
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	53                   	push   %ebx
  800819:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80081f:	b8 00 00 00 00       	mov    $0x0,%eax
  800824:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800828:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80082b:	83 c0 01             	add    $0x1,%eax
  80082e:	84 d2                	test   %dl,%dl
  800830:	75 f2                	jne    800824 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800832:	89 c8                	mov    %ecx,%eax
  800834:	5b                   	pop    %ebx
  800835:	5d                   	pop    %ebp
  800836:	c3                   	ret    

00800837 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800837:	f3 0f 1e fb          	endbr32 
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	53                   	push   %ebx
  80083f:	83 ec 10             	sub    $0x10,%esp
  800842:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800845:	53                   	push   %ebx
  800846:	e8 83 ff ff ff       	call   8007ce <strlen>
  80084b:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80084e:	ff 75 0c             	pushl  0xc(%ebp)
  800851:	01 d8                	add    %ebx,%eax
  800853:	50                   	push   %eax
  800854:	e8 b8 ff ff ff       	call   800811 <strcpy>
	return dst;
}
  800859:	89 d8                	mov    %ebx,%eax
  80085b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80085e:	c9                   	leave  
  80085f:	c3                   	ret    

00800860 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800860:	f3 0f 1e fb          	endbr32 
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	56                   	push   %esi
  800868:	53                   	push   %ebx
  800869:	8b 75 08             	mov    0x8(%ebp),%esi
  80086c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086f:	89 f3                	mov    %esi,%ebx
  800871:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800874:	89 f0                	mov    %esi,%eax
  800876:	39 d8                	cmp    %ebx,%eax
  800878:	74 11                	je     80088b <strncpy+0x2b>
		*dst++ = *src;
  80087a:	83 c0 01             	add    $0x1,%eax
  80087d:	0f b6 0a             	movzbl (%edx),%ecx
  800880:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800883:	80 f9 01             	cmp    $0x1,%cl
  800886:	83 da ff             	sbb    $0xffffffff,%edx
  800889:	eb eb                	jmp    800876 <strncpy+0x16>
	}
	return ret;
}
  80088b:	89 f0                	mov    %esi,%eax
  80088d:	5b                   	pop    %ebx
  80088e:	5e                   	pop    %esi
  80088f:	5d                   	pop    %ebp
  800890:	c3                   	ret    

00800891 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800891:	f3 0f 1e fb          	endbr32 
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	56                   	push   %esi
  800899:	53                   	push   %ebx
  80089a:	8b 75 08             	mov    0x8(%ebp),%esi
  80089d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a0:	8b 55 10             	mov    0x10(%ebp),%edx
  8008a3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a5:	85 d2                	test   %edx,%edx
  8008a7:	74 21                	je     8008ca <strlcpy+0x39>
  8008a9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008ad:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008af:	39 c2                	cmp    %eax,%edx
  8008b1:	74 14                	je     8008c7 <strlcpy+0x36>
  8008b3:	0f b6 19             	movzbl (%ecx),%ebx
  8008b6:	84 db                	test   %bl,%bl
  8008b8:	74 0b                	je     8008c5 <strlcpy+0x34>
			*dst++ = *src++;
  8008ba:	83 c1 01             	add    $0x1,%ecx
  8008bd:	83 c2 01             	add    $0x1,%edx
  8008c0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008c3:	eb ea                	jmp    8008af <strlcpy+0x1e>
  8008c5:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008c7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ca:	29 f0                	sub    %esi,%eax
}
  8008cc:	5b                   	pop    %ebx
  8008cd:	5e                   	pop    %esi
  8008ce:	5d                   	pop    %ebp
  8008cf:	c3                   	ret    

008008d0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008d0:	f3 0f 1e fb          	endbr32 
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008da:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008dd:	0f b6 01             	movzbl (%ecx),%eax
  8008e0:	84 c0                	test   %al,%al
  8008e2:	74 0c                	je     8008f0 <strcmp+0x20>
  8008e4:	3a 02                	cmp    (%edx),%al
  8008e6:	75 08                	jne    8008f0 <strcmp+0x20>
		p++, q++;
  8008e8:	83 c1 01             	add    $0x1,%ecx
  8008eb:	83 c2 01             	add    $0x1,%edx
  8008ee:	eb ed                	jmp    8008dd <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f0:	0f b6 c0             	movzbl %al,%eax
  8008f3:	0f b6 12             	movzbl (%edx),%edx
  8008f6:	29 d0                	sub    %edx,%eax
}
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008fa:	f3 0f 1e fb          	endbr32 
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	53                   	push   %ebx
  800902:	8b 45 08             	mov    0x8(%ebp),%eax
  800905:	8b 55 0c             	mov    0xc(%ebp),%edx
  800908:	89 c3                	mov    %eax,%ebx
  80090a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80090d:	eb 06                	jmp    800915 <strncmp+0x1b>
		n--, p++, q++;
  80090f:	83 c0 01             	add    $0x1,%eax
  800912:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800915:	39 d8                	cmp    %ebx,%eax
  800917:	74 16                	je     80092f <strncmp+0x35>
  800919:	0f b6 08             	movzbl (%eax),%ecx
  80091c:	84 c9                	test   %cl,%cl
  80091e:	74 04                	je     800924 <strncmp+0x2a>
  800920:	3a 0a                	cmp    (%edx),%cl
  800922:	74 eb                	je     80090f <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800924:	0f b6 00             	movzbl (%eax),%eax
  800927:	0f b6 12             	movzbl (%edx),%edx
  80092a:	29 d0                	sub    %edx,%eax
}
  80092c:	5b                   	pop    %ebx
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    
		return 0;
  80092f:	b8 00 00 00 00       	mov    $0x0,%eax
  800934:	eb f6                	jmp    80092c <strncmp+0x32>

00800936 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800936:	f3 0f 1e fb          	endbr32 
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	8b 45 08             	mov    0x8(%ebp),%eax
  800940:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800944:	0f b6 10             	movzbl (%eax),%edx
  800947:	84 d2                	test   %dl,%dl
  800949:	74 09                	je     800954 <strchr+0x1e>
		if (*s == c)
  80094b:	38 ca                	cmp    %cl,%dl
  80094d:	74 0a                	je     800959 <strchr+0x23>
	for (; *s; s++)
  80094f:	83 c0 01             	add    $0x1,%eax
  800952:	eb f0                	jmp    800944 <strchr+0xe>
			return (char *) s;
	return 0;
  800954:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80095b:	f3 0f 1e fb          	endbr32 
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	8b 45 08             	mov    0x8(%ebp),%eax
  800965:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800969:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80096c:	38 ca                	cmp    %cl,%dl
  80096e:	74 09                	je     800979 <strfind+0x1e>
  800970:	84 d2                	test   %dl,%dl
  800972:	74 05                	je     800979 <strfind+0x1e>
	for (; *s; s++)
  800974:	83 c0 01             	add    $0x1,%eax
  800977:	eb f0                	jmp    800969 <strfind+0xe>
			break;
	return (char *) s;
}
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80097b:	f3 0f 1e fb          	endbr32 
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	57                   	push   %edi
  800983:	56                   	push   %esi
  800984:	53                   	push   %ebx
  800985:	8b 7d 08             	mov    0x8(%ebp),%edi
  800988:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80098b:	85 c9                	test   %ecx,%ecx
  80098d:	74 31                	je     8009c0 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80098f:	89 f8                	mov    %edi,%eax
  800991:	09 c8                	or     %ecx,%eax
  800993:	a8 03                	test   $0x3,%al
  800995:	75 23                	jne    8009ba <memset+0x3f>
		c &= 0xFF;
  800997:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80099b:	89 d3                	mov    %edx,%ebx
  80099d:	c1 e3 08             	shl    $0x8,%ebx
  8009a0:	89 d0                	mov    %edx,%eax
  8009a2:	c1 e0 18             	shl    $0x18,%eax
  8009a5:	89 d6                	mov    %edx,%esi
  8009a7:	c1 e6 10             	shl    $0x10,%esi
  8009aa:	09 f0                	or     %esi,%eax
  8009ac:	09 c2                	or     %eax,%edx
  8009ae:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009b0:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009b3:	89 d0                	mov    %edx,%eax
  8009b5:	fc                   	cld    
  8009b6:	f3 ab                	rep stos %eax,%es:(%edi)
  8009b8:	eb 06                	jmp    8009c0 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bd:	fc                   	cld    
  8009be:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009c0:	89 f8                	mov    %edi,%eax
  8009c2:	5b                   	pop    %ebx
  8009c3:	5e                   	pop    %esi
  8009c4:	5f                   	pop    %edi
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c7:	f3 0f 1e fb          	endbr32 
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	57                   	push   %edi
  8009cf:	56                   	push   %esi
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d9:	39 c6                	cmp    %eax,%esi
  8009db:	73 32                	jae    800a0f <memmove+0x48>
  8009dd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009e0:	39 c2                	cmp    %eax,%edx
  8009e2:	76 2b                	jbe    800a0f <memmove+0x48>
		s += n;
		d += n;
  8009e4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e7:	89 fe                	mov    %edi,%esi
  8009e9:	09 ce                	or     %ecx,%esi
  8009eb:	09 d6                	or     %edx,%esi
  8009ed:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009f3:	75 0e                	jne    800a03 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009f5:	83 ef 04             	sub    $0x4,%edi
  8009f8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009fb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009fe:	fd                   	std    
  8009ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a01:	eb 09                	jmp    800a0c <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a03:	83 ef 01             	sub    $0x1,%edi
  800a06:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a09:	fd                   	std    
  800a0a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a0c:	fc                   	cld    
  800a0d:	eb 1a                	jmp    800a29 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0f:	89 c2                	mov    %eax,%edx
  800a11:	09 ca                	or     %ecx,%edx
  800a13:	09 f2                	or     %esi,%edx
  800a15:	f6 c2 03             	test   $0x3,%dl
  800a18:	75 0a                	jne    800a24 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a1a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a1d:	89 c7                	mov    %eax,%edi
  800a1f:	fc                   	cld    
  800a20:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a22:	eb 05                	jmp    800a29 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a24:	89 c7                	mov    %eax,%edi
  800a26:	fc                   	cld    
  800a27:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a29:	5e                   	pop    %esi
  800a2a:	5f                   	pop    %edi
  800a2b:	5d                   	pop    %ebp
  800a2c:	c3                   	ret    

00800a2d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a2d:	f3 0f 1e fb          	endbr32 
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a37:	ff 75 10             	pushl  0x10(%ebp)
  800a3a:	ff 75 0c             	pushl  0xc(%ebp)
  800a3d:	ff 75 08             	pushl  0x8(%ebp)
  800a40:	e8 82 ff ff ff       	call   8009c7 <memmove>
}
  800a45:	c9                   	leave  
  800a46:	c3                   	ret    

00800a47 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a47:	f3 0f 1e fb          	endbr32 
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	56                   	push   %esi
  800a4f:	53                   	push   %ebx
  800a50:	8b 45 08             	mov    0x8(%ebp),%eax
  800a53:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a56:	89 c6                	mov    %eax,%esi
  800a58:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a5b:	39 f0                	cmp    %esi,%eax
  800a5d:	74 1c                	je     800a7b <memcmp+0x34>
		if (*s1 != *s2)
  800a5f:	0f b6 08             	movzbl (%eax),%ecx
  800a62:	0f b6 1a             	movzbl (%edx),%ebx
  800a65:	38 d9                	cmp    %bl,%cl
  800a67:	75 08                	jne    800a71 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a69:	83 c0 01             	add    $0x1,%eax
  800a6c:	83 c2 01             	add    $0x1,%edx
  800a6f:	eb ea                	jmp    800a5b <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a71:	0f b6 c1             	movzbl %cl,%eax
  800a74:	0f b6 db             	movzbl %bl,%ebx
  800a77:	29 d8                	sub    %ebx,%eax
  800a79:	eb 05                	jmp    800a80 <memcmp+0x39>
	}

	return 0;
  800a7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a80:	5b                   	pop    %ebx
  800a81:	5e                   	pop    %esi
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a84:	f3 0f 1e fb          	endbr32 
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a91:	89 c2                	mov    %eax,%edx
  800a93:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a96:	39 d0                	cmp    %edx,%eax
  800a98:	73 09                	jae    800aa3 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a9a:	38 08                	cmp    %cl,(%eax)
  800a9c:	74 05                	je     800aa3 <memfind+0x1f>
	for (; s < ends; s++)
  800a9e:	83 c0 01             	add    $0x1,%eax
  800aa1:	eb f3                	jmp    800a96 <memfind+0x12>
			break;
	return (void *) s;
}
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    

00800aa5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800aa5:	f3 0f 1e fb          	endbr32 
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	57                   	push   %edi
  800aad:	56                   	push   %esi
  800aae:	53                   	push   %ebx
  800aaf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ab5:	eb 03                	jmp    800aba <strtol+0x15>
		s++;
  800ab7:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800aba:	0f b6 01             	movzbl (%ecx),%eax
  800abd:	3c 20                	cmp    $0x20,%al
  800abf:	74 f6                	je     800ab7 <strtol+0x12>
  800ac1:	3c 09                	cmp    $0x9,%al
  800ac3:	74 f2                	je     800ab7 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800ac5:	3c 2b                	cmp    $0x2b,%al
  800ac7:	74 2a                	je     800af3 <strtol+0x4e>
	int neg = 0;
  800ac9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ace:	3c 2d                	cmp    $0x2d,%al
  800ad0:	74 2b                	je     800afd <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ad8:	75 0f                	jne    800ae9 <strtol+0x44>
  800ada:	80 39 30             	cmpb   $0x30,(%ecx)
  800add:	74 28                	je     800b07 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800adf:	85 db                	test   %ebx,%ebx
  800ae1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ae6:	0f 44 d8             	cmove  %eax,%ebx
  800ae9:	b8 00 00 00 00       	mov    $0x0,%eax
  800aee:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800af1:	eb 46                	jmp    800b39 <strtol+0x94>
		s++;
  800af3:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800af6:	bf 00 00 00 00       	mov    $0x0,%edi
  800afb:	eb d5                	jmp    800ad2 <strtol+0x2d>
		s++, neg = 1;
  800afd:	83 c1 01             	add    $0x1,%ecx
  800b00:	bf 01 00 00 00       	mov    $0x1,%edi
  800b05:	eb cb                	jmp    800ad2 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b07:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b0b:	74 0e                	je     800b1b <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b0d:	85 db                	test   %ebx,%ebx
  800b0f:	75 d8                	jne    800ae9 <strtol+0x44>
		s++, base = 8;
  800b11:	83 c1 01             	add    $0x1,%ecx
  800b14:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b19:	eb ce                	jmp    800ae9 <strtol+0x44>
		s += 2, base = 16;
  800b1b:	83 c1 02             	add    $0x2,%ecx
  800b1e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b23:	eb c4                	jmp    800ae9 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b25:	0f be d2             	movsbl %dl,%edx
  800b28:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b2b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b2e:	7d 3a                	jge    800b6a <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b30:	83 c1 01             	add    $0x1,%ecx
  800b33:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b37:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b39:	0f b6 11             	movzbl (%ecx),%edx
  800b3c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b3f:	89 f3                	mov    %esi,%ebx
  800b41:	80 fb 09             	cmp    $0x9,%bl
  800b44:	76 df                	jbe    800b25 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b46:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b49:	89 f3                	mov    %esi,%ebx
  800b4b:	80 fb 19             	cmp    $0x19,%bl
  800b4e:	77 08                	ja     800b58 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b50:	0f be d2             	movsbl %dl,%edx
  800b53:	83 ea 57             	sub    $0x57,%edx
  800b56:	eb d3                	jmp    800b2b <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b58:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b5b:	89 f3                	mov    %esi,%ebx
  800b5d:	80 fb 19             	cmp    $0x19,%bl
  800b60:	77 08                	ja     800b6a <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b62:	0f be d2             	movsbl %dl,%edx
  800b65:	83 ea 37             	sub    $0x37,%edx
  800b68:	eb c1                	jmp    800b2b <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b6a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b6e:	74 05                	je     800b75 <strtol+0xd0>
		*endptr = (char *) s;
  800b70:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b73:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b75:	89 c2                	mov    %eax,%edx
  800b77:	f7 da                	neg    %edx
  800b79:	85 ff                	test   %edi,%edi
  800b7b:	0f 45 c2             	cmovne %edx,%eax
}
  800b7e:	5b                   	pop    %ebx
  800b7f:	5e                   	pop    %esi
  800b80:	5f                   	pop    %edi
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    

00800b83 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b83:	f3 0f 1e fb          	endbr32 
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	57                   	push   %edi
  800b8b:	56                   	push   %esi
  800b8c:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800b8d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b92:	8b 55 08             	mov    0x8(%ebp),%edx
  800b95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b98:	89 c3                	mov    %eax,%ebx
  800b9a:	89 c7                	mov    %eax,%edi
  800b9c:	89 c6                	mov    %eax,%esi
  800b9e:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba0:	5b                   	pop    %ebx
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ba5:	f3 0f 1e fb          	endbr32 
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	57                   	push   %edi
  800bad:	56                   	push   %esi
  800bae:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800baf:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb4:	b8 01 00 00 00       	mov    $0x1,%eax
  800bb9:	89 d1                	mov    %edx,%ecx
  800bbb:	89 d3                	mov    %edx,%ebx
  800bbd:	89 d7                	mov    %edx,%edi
  800bbf:	89 d6                	mov    %edx,%esi
  800bc1:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bc3:	5b                   	pop    %ebx
  800bc4:	5e                   	pop    %esi
  800bc5:	5f                   	pop    %edi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bc8:	f3 0f 1e fb          	endbr32 
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	57                   	push   %edi
  800bd0:	56                   	push   %esi
  800bd1:	53                   	push   %ebx
  800bd2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800bd5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bda:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdd:	b8 03 00 00 00       	mov    $0x3,%eax
  800be2:	89 cb                	mov    %ecx,%ebx
  800be4:	89 cf                	mov    %ecx,%edi
  800be6:	89 ce                	mov    %ecx,%esi
  800be8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bea:	85 c0                	test   %eax,%eax
  800bec:	7f 08                	jg     800bf6 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf6:	83 ec 0c             	sub    $0xc,%esp
  800bf9:	50                   	push   %eax
  800bfa:	6a 03                	push   $0x3
  800bfc:	68 a4 17 80 00       	push   $0x8017a4
  800c01:	6a 23                	push   $0x23
  800c03:	68 c1 17 80 00       	push   $0x8017c1
  800c08:	e8 ba 05 00 00       	call   8011c7 <_panic>

00800c0d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c0d:	f3 0f 1e fb          	endbr32 
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	57                   	push   %edi
  800c15:	56                   	push   %esi
  800c16:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c17:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1c:	b8 02 00 00 00       	mov    $0x2,%eax
  800c21:	89 d1                	mov    %edx,%ecx
  800c23:	89 d3                	mov    %edx,%ebx
  800c25:	89 d7                	mov    %edx,%edi
  800c27:	89 d6                	mov    %edx,%esi
  800c29:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c2b:	5b                   	pop    %ebx
  800c2c:	5e                   	pop    %esi
  800c2d:	5f                   	pop    %edi
  800c2e:	5d                   	pop    %ebp
  800c2f:	c3                   	ret    

00800c30 <sys_yield>:

void
sys_yield(void)
{
  800c30:	f3 0f 1e fb          	endbr32 
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	57                   	push   %edi
  800c38:	56                   	push   %esi
  800c39:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c44:	89 d1                	mov    %edx,%ecx
  800c46:	89 d3                	mov    %edx,%ebx
  800c48:	89 d7                	mov    %edx,%edi
  800c4a:	89 d6                	mov    %edx,%esi
  800c4c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c4e:	5b                   	pop    %ebx
  800c4f:	5e                   	pop    %esi
  800c50:	5f                   	pop    %edi
  800c51:	5d                   	pop    %ebp
  800c52:	c3                   	ret    

00800c53 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c53:	f3 0f 1e fb          	endbr32 
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c60:	be 00 00 00 00       	mov    $0x0,%esi
  800c65:	8b 55 08             	mov    0x8(%ebp),%edx
  800c68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c70:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c73:	89 f7                	mov    %esi,%edi
  800c75:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c77:	85 c0                	test   %eax,%eax
  800c79:	7f 08                	jg     800c83 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c83:	83 ec 0c             	sub    $0xc,%esp
  800c86:	50                   	push   %eax
  800c87:	6a 04                	push   $0x4
  800c89:	68 a4 17 80 00       	push   $0x8017a4
  800c8e:	6a 23                	push   $0x23
  800c90:	68 c1 17 80 00       	push   $0x8017c1
  800c95:	e8 2d 05 00 00       	call   8011c7 <_panic>

00800c9a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c9a:	f3 0f 1e fb          	endbr32 
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	53                   	push   %ebx
  800ca4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800ca7:	8b 55 08             	mov    0x8(%ebp),%edx
  800caa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cad:	b8 05 00 00 00       	mov    $0x5,%eax
  800cb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cb8:	8b 75 18             	mov    0x18(%ebp),%esi
  800cbb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cbd:	85 c0                	test   %eax,%eax
  800cbf:	7f 08                	jg     800cc9 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc9:	83 ec 0c             	sub    $0xc,%esp
  800ccc:	50                   	push   %eax
  800ccd:	6a 05                	push   $0x5
  800ccf:	68 a4 17 80 00       	push   $0x8017a4
  800cd4:	6a 23                	push   $0x23
  800cd6:	68 c1 17 80 00       	push   $0x8017c1
  800cdb:	e8 e7 04 00 00       	call   8011c7 <_panic>

00800ce0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ce0:	f3 0f 1e fb          	endbr32 
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
  800cea:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800ced:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf8:	b8 06 00 00 00       	mov    $0x6,%eax
  800cfd:	89 df                	mov    %ebx,%edi
  800cff:	89 de                	mov    %ebx,%esi
  800d01:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d03:	85 c0                	test   %eax,%eax
  800d05:	7f 08                	jg     800d0f <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0a:	5b                   	pop    %ebx
  800d0b:	5e                   	pop    %esi
  800d0c:	5f                   	pop    %edi
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0f:	83 ec 0c             	sub    $0xc,%esp
  800d12:	50                   	push   %eax
  800d13:	6a 06                	push   $0x6
  800d15:	68 a4 17 80 00       	push   $0x8017a4
  800d1a:	6a 23                	push   $0x23
  800d1c:	68 c1 17 80 00       	push   $0x8017c1
  800d21:	e8 a1 04 00 00       	call   8011c7 <_panic>

00800d26 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d26:	f3 0f 1e fb          	endbr32 
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
  800d30:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d38:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3e:	b8 08 00 00 00       	mov    $0x8,%eax
  800d43:	89 df                	mov    %ebx,%edi
  800d45:	89 de                	mov    %ebx,%esi
  800d47:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	7f 08                	jg     800d55 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d55:	83 ec 0c             	sub    $0xc,%esp
  800d58:	50                   	push   %eax
  800d59:	6a 08                	push   $0x8
  800d5b:	68 a4 17 80 00       	push   $0x8017a4
  800d60:	6a 23                	push   $0x23
  800d62:	68 c1 17 80 00       	push   $0x8017c1
  800d67:	e8 5b 04 00 00       	call   8011c7 <_panic>

00800d6c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d6c:	f3 0f 1e fb          	endbr32 
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	57                   	push   %edi
  800d74:	56                   	push   %esi
  800d75:	53                   	push   %ebx
  800d76:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d79:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d84:	b8 09 00 00 00       	mov    $0x9,%eax
  800d89:	89 df                	mov    %ebx,%edi
  800d8b:	89 de                	mov    %ebx,%esi
  800d8d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d8f:	85 c0                	test   %eax,%eax
  800d91:	7f 08                	jg     800d9b <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d96:	5b                   	pop    %ebx
  800d97:	5e                   	pop    %esi
  800d98:	5f                   	pop    %edi
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9b:	83 ec 0c             	sub    $0xc,%esp
  800d9e:	50                   	push   %eax
  800d9f:	6a 09                	push   $0x9
  800da1:	68 a4 17 80 00       	push   $0x8017a4
  800da6:	6a 23                	push   $0x23
  800da8:	68 c1 17 80 00       	push   $0x8017c1
  800dad:	e8 15 04 00 00       	call   8011c7 <_panic>

00800db2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800db2:	f3 0f 1e fb          	endbr32 
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	57                   	push   %edi
  800dba:	56                   	push   %esi
  800dbb:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800dbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc2:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dc7:	be 00 00 00 00       	mov    $0x0,%esi
  800dcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dcf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dd2:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dd4:	5b                   	pop    %ebx
  800dd5:	5e                   	pop    %esi
  800dd6:	5f                   	pop    %edi
  800dd7:	5d                   	pop    %ebp
  800dd8:	c3                   	ret    

00800dd9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dd9:	f3 0f 1e fb          	endbr32 
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	57                   	push   %edi
  800de1:	56                   	push   %esi
  800de2:	53                   	push   %ebx
  800de3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800de6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800deb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dee:	b8 0c 00 00 00       	mov    $0xc,%eax
  800df3:	89 cb                	mov    %ecx,%ebx
  800df5:	89 cf                	mov    %ecx,%edi
  800df7:	89 ce                	mov    %ecx,%esi
  800df9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dfb:	85 c0                	test   %eax,%eax
  800dfd:	7f 08                	jg     800e07 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e02:	5b                   	pop    %ebx
  800e03:	5e                   	pop    %esi
  800e04:	5f                   	pop    %edi
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e07:	83 ec 0c             	sub    $0xc,%esp
  800e0a:	50                   	push   %eax
  800e0b:	6a 0c                	push   $0xc
  800e0d:	68 a4 17 80 00       	push   $0x8017a4
  800e12:	6a 23                	push   $0x23
  800e14:	68 c1 17 80 00       	push   $0x8017c1
  800e19:	e8 a9 03 00 00       	call   8011c7 <_panic>

00800e1e <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e1e:	f3 0f 1e fb          	endbr32 
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	53                   	push   %ebx
  800e26:	83 ec 04             	sub    $0x4,%esp
  800e29:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e2c:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpt[PGNUM(addr)] & PTE_COW))) { 
  800e2e:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e32:	74 74                	je     800ea8 <pgfault+0x8a>
  800e34:	89 d8                	mov    %ebx,%eax
  800e36:	c1 e8 0c             	shr    $0xc,%eax
  800e39:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e40:	f6 c4 08             	test   $0x8,%ah
  800e43:	74 63                	je     800ea8 <pgfault+0x8a>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	addr = ROUNDDOWN(addr, PGSIZE);
  800e45:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_map(0, addr, 0, PFTEMP, PTE_U|PTE_P)) < 0)		
  800e4b:	83 ec 0c             	sub    $0xc,%esp
  800e4e:	6a 05                	push   $0x5
  800e50:	68 00 f0 7f 00       	push   $0x7ff000
  800e55:	6a 00                	push   $0x0
  800e57:	53                   	push   %ebx
  800e58:	6a 00                	push   $0x0
  800e5a:	e8 3b fe ff ff       	call   800c9a <sys_page_map>
  800e5f:	83 c4 20             	add    $0x20,%esp
  800e62:	85 c0                	test   %eax,%eax
  800e64:	78 56                	js     800ebc <pgfault+0x9e>
		panic("sys_page_map: %e", r);
	if ((r = sys_page_alloc(0, addr, PTE_P|PTE_U|PTE_W)) < 0)	
  800e66:	83 ec 04             	sub    $0x4,%esp
  800e69:	6a 07                	push   $0x7
  800e6b:	53                   	push   %ebx
  800e6c:	6a 00                	push   $0x0
  800e6e:	e8 e0 fd ff ff       	call   800c53 <sys_page_alloc>
  800e73:	83 c4 10             	add    $0x10,%esp
  800e76:	85 c0                	test   %eax,%eax
  800e78:	78 54                	js     800ece <pgfault+0xb0>
		panic("sys_page_alloc: %e", r);
	memmove(addr, PFTEMP, PGSIZE);							
  800e7a:	83 ec 04             	sub    $0x4,%esp
  800e7d:	68 00 10 00 00       	push   $0x1000
  800e82:	68 00 f0 7f 00       	push   $0x7ff000
  800e87:	53                   	push   %ebx
  800e88:	e8 3a fb ff ff       	call   8009c7 <memmove>
	if ((r = sys_page_unmap(0, PFTEMP)) < 0)				
  800e8d:	83 c4 08             	add    $0x8,%esp
  800e90:	68 00 f0 7f 00       	push   $0x7ff000
  800e95:	6a 00                	push   $0x0
  800e97:	e8 44 fe ff ff       	call   800ce0 <sys_page_unmap>
  800e9c:	83 c4 10             	add    $0x10,%esp
  800e9f:	85 c0                	test   %eax,%eax
  800ea1:	78 3d                	js     800ee0 <pgfault+0xc2>
		panic("sys_page_unmap: %e", r);
}
  800ea3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ea6:	c9                   	leave  
  800ea7:	c3                   	ret    
		panic("pgfault():not cow");
  800ea8:	83 ec 04             	sub    $0x4,%esp
  800eab:	68 cf 17 80 00       	push   $0x8017cf
  800eb0:	6a 1d                	push   $0x1d
  800eb2:	68 e1 17 80 00       	push   $0x8017e1
  800eb7:	e8 0b 03 00 00       	call   8011c7 <_panic>
		panic("sys_page_map: %e", r);
  800ebc:	50                   	push   %eax
  800ebd:	68 ec 17 80 00       	push   $0x8017ec
  800ec2:	6a 2a                	push   $0x2a
  800ec4:	68 e1 17 80 00       	push   $0x8017e1
  800ec9:	e8 f9 02 00 00       	call   8011c7 <_panic>
		panic("sys_page_alloc: %e", r);
  800ece:	50                   	push   %eax
  800ecf:	68 fd 17 80 00       	push   $0x8017fd
  800ed4:	6a 2c                	push   $0x2c
  800ed6:	68 e1 17 80 00       	push   $0x8017e1
  800edb:	e8 e7 02 00 00       	call   8011c7 <_panic>
		panic("sys_page_unmap: %e", r);
  800ee0:	50                   	push   %eax
  800ee1:	68 10 18 80 00       	push   $0x801810
  800ee6:	6a 2f                	push   $0x2f
  800ee8:	68 e1 17 80 00       	push   $0x8017e1
  800eed:	e8 d5 02 00 00       	call   8011c7 <_panic>

00800ef2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ef2:	f3 0f 1e fb          	endbr32 
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
  800ef9:	57                   	push   %edi
  800efa:	56                   	push   %esi
  800efb:	53                   	push   %ebx
  800efc:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	extern void _pgfault_upcall(void);
	set_pgfault_handler(pgfault);	
  800eff:	68 1e 0e 80 00       	push   $0x800e1e
  800f04:	e8 08 03 00 00       	call   801211 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f09:	b8 07 00 00 00       	mov    $0x7,%eax
  800f0e:	cd 30                	int    $0x30
  800f10:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	envid_t envid = sys_exofork();	
	if (envid == 0) {				
  800f13:	83 c4 10             	add    $0x10,%esp
  800f16:	85 c0                	test   %eax,%eax
  800f18:	74 12                	je     800f2c <fork+0x3a>
  800f1a:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	if (envid < 0) {
  800f1c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f20:	78 29                	js     800f4b <fork+0x59>
		panic("sys_exofork: %e", envid);
	}

	uint32_t addr;
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  800f22:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f27:	e9 80 00 00 00       	jmp    800fac <fork+0xba>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f2c:	e8 dc fc ff ff       	call   800c0d <sys_getenvid>
  800f31:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f36:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  800f3c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f41:	a3 60 40 80 00       	mov    %eax,0x804060
		return 0;
  800f46:	e9 27 01 00 00       	jmp    801072 <fork+0x180>
		panic("sys_exofork: %e", envid);
  800f4b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f4e:	68 23 18 80 00       	push   $0x801823
  800f53:	6a 6b                	push   $0x6b
  800f55:	68 e1 17 80 00       	push   $0x8017e1
  800f5a:	e8 68 02 00 00       	call   8011c7 <_panic>
		if ((r = sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800f5f:	83 ec 0c             	sub    $0xc,%esp
  800f62:	68 05 08 00 00       	push   $0x805
  800f67:	56                   	push   %esi
  800f68:	57                   	push   %edi
  800f69:	56                   	push   %esi
  800f6a:	6a 00                	push   $0x0
  800f6c:	e8 29 fd ff ff       	call   800c9a <sys_page_map>
  800f71:	83 c4 20             	add    $0x20,%esp
  800f74:	85 c0                	test   %eax,%eax
  800f76:	0f 88 96 00 00 00    	js     801012 <fork+0x120>
		if ((r = sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P)) < 0)
  800f7c:	83 ec 0c             	sub    $0xc,%esp
  800f7f:	68 05 08 00 00       	push   $0x805
  800f84:	56                   	push   %esi
  800f85:	6a 00                	push   $0x0
  800f87:	56                   	push   %esi
  800f88:	6a 00                	push   $0x0
  800f8a:	e8 0b fd ff ff       	call   800c9a <sys_page_map>
  800f8f:	83 c4 20             	add    $0x20,%esp
  800f92:	85 c0                	test   %eax,%eax
  800f94:	0f 88 8a 00 00 00    	js     801024 <fork+0x132>
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE) {
  800f9a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fa0:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fa6:	0f 84 8a 00 00 00    	je     801036 <fork+0x144>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) 
  800fac:	89 d8                	mov    %ebx,%eax
  800fae:	c1 e8 16             	shr    $0x16,%eax
  800fb1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fb8:	a8 01                	test   $0x1,%al
  800fba:	74 de                	je     800f9a <fork+0xa8>
  800fbc:	89 d8                	mov    %ebx,%eax
  800fbe:	c1 e8 0c             	shr    $0xc,%eax
  800fc1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fc8:	f6 c2 01             	test   $0x1,%dl
  800fcb:	74 cd                	je     800f9a <fork+0xa8>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  800fcd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fd4:	f6 c2 04             	test   $0x4,%dl
  800fd7:	74 c1                	je     800f9a <fork+0xa8>
	void *addr = (void*) (pn * PGSIZE);
  800fd9:	89 c6                	mov    %eax,%esi
  800fdb:	c1 e6 0c             	shl    $0xc,%esi
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) { 
  800fde:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fe5:	f6 c2 02             	test   $0x2,%dl
  800fe8:	0f 85 71 ff ff ff    	jne    800f5f <fork+0x6d>
  800fee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ff5:	f6 c4 08             	test   $0x8,%ah
  800ff8:	0f 85 61 ff ff ff    	jne    800f5f <fork+0x6d>
		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);	
  800ffe:	83 ec 0c             	sub    $0xc,%esp
  801001:	6a 05                	push   $0x5
  801003:	56                   	push   %esi
  801004:	57                   	push   %edi
  801005:	56                   	push   %esi
  801006:	6a 00                	push   $0x0
  801008:	e8 8d fc ff ff       	call   800c9a <sys_page_map>
  80100d:	83 c4 20             	add    $0x20,%esp
  801010:	eb 88                	jmp    800f9a <fork+0xa8>
			panic("sys_page_map：%e", r);
  801012:	50                   	push   %eax
  801013:	68 33 18 80 00       	push   $0x801833
  801018:	6a 46                	push   $0x46
  80101a:	68 e1 17 80 00       	push   $0x8017e1
  80101f:	e8 a3 01 00 00       	call   8011c7 <_panic>
			panic("sys_page_map：%e", r);
  801024:	50                   	push   %eax
  801025:	68 33 18 80 00       	push   $0x801833
  80102a:	6a 48                	push   $0x48
  80102c:	68 e1 17 80 00       	push   $0x8017e1
  801031:	e8 91 01 00 00       	call   8011c7 <_panic>
			duppage(envid, PGNUM(addr));	
		}
	}
	int r;
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)	
  801036:	83 ec 04             	sub    $0x4,%esp
  801039:	6a 07                	push   $0x7
  80103b:	68 00 f0 bf ee       	push   $0xeebff000
  801040:	ff 75 e4             	pushl  -0x1c(%ebp)
  801043:	e8 0b fc ff ff       	call   800c53 <sys_page_alloc>
  801048:	83 c4 10             	add    $0x10,%esp
  80104b:	85 c0                	test   %eax,%eax
  80104d:	78 2e                	js     80107d <fork+0x18b>
		panic("sys_page_alloc: %e", r);
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);		
  80104f:	83 ec 08             	sub    $0x8,%esp
  801052:	68 6e 12 80 00       	push   $0x80126e
  801057:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80105a:	57                   	push   %edi
  80105b:	e8 0c fd ff ff       	call   800d6c <sys_env_set_pgfault_upcall>

	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)	
  801060:	83 c4 08             	add    $0x8,%esp
  801063:	6a 02                	push   $0x2
  801065:	57                   	push   %edi
  801066:	e8 bb fc ff ff       	call   800d26 <sys_env_set_status>
  80106b:	83 c4 10             	add    $0x10,%esp
  80106e:	85 c0                	test   %eax,%eax
  801070:	78 1d                	js     80108f <fork+0x19d>
		panic("sys_env_set_status: %e", r);
	return envid;
}
  801072:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801075:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801078:	5b                   	pop    %ebx
  801079:	5e                   	pop    %esi
  80107a:	5f                   	pop    %edi
  80107b:	5d                   	pop    %ebp
  80107c:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  80107d:	50                   	push   %eax
  80107e:	68 fd 17 80 00       	push   $0x8017fd
  801083:	6a 77                	push   $0x77
  801085:	68 e1 17 80 00       	push   $0x8017e1
  80108a:	e8 38 01 00 00       	call   8011c7 <_panic>
		panic("sys_env_set_status: %e", r);
  80108f:	50                   	push   %eax
  801090:	68 45 18 80 00       	push   $0x801845
  801095:	6a 7b                	push   $0x7b
  801097:	68 e1 17 80 00       	push   $0x8017e1
  80109c:	e8 26 01 00 00       	call   8011c7 <_panic>

008010a1 <sfork>:

// Challenge!
int
sfork(void)
{
  8010a1:	f3 0f 1e fb          	endbr32 
  8010a5:	55                   	push   %ebp
  8010a6:	89 e5                	mov    %esp,%ebp
  8010a8:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010ab:	68 5c 18 80 00       	push   $0x80185c
  8010b0:	68 83 00 00 00       	push   $0x83
  8010b5:	68 e1 17 80 00       	push   $0x8017e1
  8010ba:	e8 08 01 00 00       	call   8011c7 <_panic>

008010bf <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010bf:	f3 0f 1e fb          	endbr32 
  8010c3:	55                   	push   %ebp
  8010c4:	89 e5                	mov    %esp,%ebp
  8010c6:	56                   	push   %esi
  8010c7:	53                   	push   %ebx
  8010c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8010cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010ce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *)-1;
  8010d1:	85 c0                	test   %eax,%eax
  8010d3:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8010d8:	0f 44 c2             	cmove  %edx,%eax
	}
	int r = sys_ipc_recv(pg);
  8010db:	83 ec 0c             	sub    $0xc,%esp
  8010de:	50                   	push   %eax
  8010df:	e8 f5 fc ff ff       	call   800dd9 <sys_ipc_recv>
	if (r < 0) {				
  8010e4:	83 c4 10             	add    $0x10,%esp
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	78 2b                	js     801116 <ipc_recv+0x57>
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return r;
	}
	if (from_env_store)
  8010eb:	85 f6                	test   %esi,%esi
  8010ed:	74 0a                	je     8010f9 <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  8010ef:	a1 60 40 80 00       	mov    0x804060,%eax
  8010f4:	8b 40 74             	mov    0x74(%eax),%eax
  8010f7:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  8010f9:	85 db                	test   %ebx,%ebx
  8010fb:	74 0a                	je     801107 <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  8010fd:	a1 60 40 80 00       	mov    0x804060,%eax
  801102:	8b 40 78             	mov    0x78(%eax),%eax
  801105:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801107:	a1 60 40 80 00       	mov    0x804060,%eax
  80110c:	8b 40 70             	mov    0x70(%eax),%eax
}
  80110f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801112:	5b                   	pop    %ebx
  801113:	5e                   	pop    %esi
  801114:	5d                   	pop    %ebp
  801115:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  801116:	85 f6                	test   %esi,%esi
  801118:	74 06                	je     801120 <ipc_recv+0x61>
  80111a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  801120:	85 db                	test   %ebx,%ebx
  801122:	74 eb                	je     80110f <ipc_recv+0x50>
  801124:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80112a:	eb e3                	jmp    80110f <ipc_recv+0x50>

0080112c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80112c:	f3 0f 1e fb          	endbr32 
  801130:	55                   	push   %ebp
  801131:	89 e5                	mov    %esp,%ebp
  801133:	57                   	push   %edi
  801134:	56                   	push   %esi
  801135:	53                   	push   %ebx
  801136:	83 ec 0c             	sub    $0xc,%esp
  801139:	8b 7d 08             	mov    0x8(%ebp),%edi
  80113c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80113f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *)-1;
  801142:	85 db                	test   %ebx,%ebx
  801144:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801149:	0f 44 d8             	cmove  %eax,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80114c:	ff 75 14             	pushl  0x14(%ebp)
  80114f:	53                   	push   %ebx
  801150:	56                   	push   %esi
  801151:	57                   	push   %edi
  801152:	e8 5b fc ff ff       	call   800db2 <sys_ipc_try_send>
		if (r == 0) {		
  801157:	83 c4 10             	add    $0x10,%esp
  80115a:	85 c0                	test   %eax,%eax
  80115c:	74 1e                	je     80117c <ipc_send+0x50>
			return;
		} else if (r == -E_IPC_NOT_RECV) {
  80115e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801161:	75 07                	jne    80116a <ipc_send+0x3e>
			sys_yield();
  801163:	e8 c8 fa ff ff       	call   800c30 <sys_yield>
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801168:	eb e2                	jmp    80114c <ipc_send+0x20>
		} else {			
			panic("ipc_send():%e", r);
  80116a:	50                   	push   %eax
  80116b:	68 72 18 80 00       	push   $0x801872
  801170:	6a 41                	push   $0x41
  801172:	68 80 18 80 00       	push   $0x801880
  801177:	e8 4b 00 00 00       	call   8011c7 <_panic>
		}
	}
}
  80117c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117f:	5b                   	pop    %ebx
  801180:	5e                   	pop    %esi
  801181:	5f                   	pop    %edi
  801182:	5d                   	pop    %ebp
  801183:	c3                   	ret    

00801184 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801184:	f3 0f 1e fb          	endbr32 
  801188:	55                   	push   %ebp
  801189:	89 e5                	mov    %esp,%ebp
  80118b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80118e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801193:	69 d0 84 00 00 00    	imul   $0x84,%eax,%edx
  801199:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80119f:	8b 52 50             	mov    0x50(%edx),%edx
  8011a2:	39 ca                	cmp    %ecx,%edx
  8011a4:	74 11                	je     8011b7 <ipc_find_env+0x33>
	for (i = 0; i < NENV; i++)
  8011a6:	83 c0 01             	add    $0x1,%eax
  8011a9:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011ae:	75 e3                	jne    801193 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8011b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b5:	eb 0e                	jmp    8011c5 <ipc_find_env+0x41>
			return envs[i].env_id;
  8011b7:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  8011bd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011c2:	8b 40 48             	mov    0x48(%eax),%eax
}
  8011c5:	5d                   	pop    %ebp
  8011c6:	c3                   	ret    

008011c7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8011c7:	f3 0f 1e fb          	endbr32 
  8011cb:	55                   	push   %ebp
  8011cc:	89 e5                	mov    %esp,%ebp
  8011ce:	56                   	push   %esi
  8011cf:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8011d0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8011d3:	8b 35 00 20 80 00    	mov    0x802000,%esi
  8011d9:	e8 2f fa ff ff       	call   800c0d <sys_getenvid>
  8011de:	83 ec 0c             	sub    $0xc,%esp
  8011e1:	ff 75 0c             	pushl  0xc(%ebp)
  8011e4:	ff 75 08             	pushl  0x8(%ebp)
  8011e7:	56                   	push   %esi
  8011e8:	50                   	push   %eax
  8011e9:	68 8c 18 80 00       	push   $0x80188c
  8011ee:	e8 14 f0 ff ff       	call   800207 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8011f3:	83 c4 18             	add    $0x18,%esp
  8011f6:	53                   	push   %ebx
  8011f7:	ff 75 10             	pushl  0x10(%ebp)
  8011fa:	e8 b3 ef ff ff       	call   8001b2 <vcprintf>
	cprintf("\n");
  8011ff:	c7 04 24 18 15 80 00 	movl   $0x801518,(%esp)
  801206:	e8 fc ef ff ff       	call   800207 <cprintf>
  80120b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80120e:	cc                   	int3   
  80120f:	eb fd                	jmp    80120e <_panic+0x47>

00801211 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801211:	f3 0f 1e fb          	endbr32 
  801215:	55                   	push   %ebp
  801216:	89 e5                	mov    %esp,%ebp
  801218:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80121b:	83 3d 64 40 80 00 00 	cmpl   $0x0,0x804064
  801222:	74 0a                	je     80122e <set_pgfault_handler+0x1d>
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);		//系统调用，设置进程的env_pgfault_upcall属性
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801224:	8b 45 08             	mov    0x8(%ebp),%eax
  801227:	a3 64 40 80 00       	mov    %eax,0x804064
}
  80122c:	c9                   	leave  
  80122d:	c3                   	ret    
		int r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_W | PTE_U | PTE_P);	//为当前进程分配异常栈
  80122e:	83 ec 04             	sub    $0x4,%esp
  801231:	6a 07                	push   $0x7
  801233:	68 00 f0 bf ee       	push   $0xeebff000
  801238:	6a 00                	push   $0x0
  80123a:	e8 14 fa ff ff       	call   800c53 <sys_page_alloc>
		if (r < 0) {
  80123f:	83 c4 10             	add    $0x10,%esp
  801242:	85 c0                	test   %eax,%eax
  801244:	78 14                	js     80125a <set_pgfault_handler+0x49>
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);		//系统调用，设置进程的env_pgfault_upcall属性
  801246:	83 ec 08             	sub    $0x8,%esp
  801249:	68 6e 12 80 00       	push   $0x80126e
  80124e:	6a 00                	push   $0x0
  801250:	e8 17 fb ff ff       	call   800d6c <sys_env_set_pgfault_upcall>
  801255:	83 c4 10             	add    $0x10,%esp
  801258:	eb ca                	jmp    801224 <set_pgfault_handler+0x13>
			panic("set_pgfault_handler:sys_page_alloc failed");;
  80125a:	83 ec 04             	sub    $0x4,%esp
  80125d:	68 b0 18 80 00       	push   $0x8018b0
  801262:	6a 22                	push   $0x22
  801264:	68 da 18 80 00       	push   $0x8018da
  801269:	e8 59 ff ff ff       	call   8011c7 <_panic>

0080126e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80126e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80126f:	a1 64 40 80 00       	mov    0x804064,%eax
	call *%eax				
  801274:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801276:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp			
  801279:	83 c4 08             	add    $0x8,%esp
	movl 40(%esp), %eax 	
  80127c:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 32(%esp), %ecx 	
  801280:	8b 4c 24 20          	mov    0x20(%esp),%ecx
	movl %ecx, -4(%eax) 	
  801284:	89 48 fc             	mov    %ecx,-0x4(%eax)
	popal
  801287:	61                   	popa   
	addl $4, %esp		
  801288:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popfl
  80128b:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80128c:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	lea -4(%esp), %esp	
  80128d:	8d 64 24 fc          	lea    -0x4(%esp),%esp
	ret
  801291:	c3                   	ret    
  801292:	66 90                	xchg   %ax,%ax
  801294:	66 90                	xchg   %ax,%ax
  801296:	66 90                	xchg   %ax,%ax
  801298:	66 90                	xchg   %ax,%ax
  80129a:	66 90                	xchg   %ax,%ax
  80129c:	66 90                	xchg   %ax,%ax
  80129e:	66 90                	xchg   %ax,%ax

008012a0 <__udivdi3>:
  8012a0:	f3 0f 1e fb          	endbr32 
  8012a4:	55                   	push   %ebp
  8012a5:	57                   	push   %edi
  8012a6:	56                   	push   %esi
  8012a7:	53                   	push   %ebx
  8012a8:	83 ec 1c             	sub    $0x1c,%esp
  8012ab:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8012af:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8012b3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8012b7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8012bb:	85 d2                	test   %edx,%edx
  8012bd:	75 19                	jne    8012d8 <__udivdi3+0x38>
  8012bf:	39 f3                	cmp    %esi,%ebx
  8012c1:	76 4d                	jbe    801310 <__udivdi3+0x70>
  8012c3:	31 ff                	xor    %edi,%edi
  8012c5:	89 e8                	mov    %ebp,%eax
  8012c7:	89 f2                	mov    %esi,%edx
  8012c9:	f7 f3                	div    %ebx
  8012cb:	89 fa                	mov    %edi,%edx
  8012cd:	83 c4 1c             	add    $0x1c,%esp
  8012d0:	5b                   	pop    %ebx
  8012d1:	5e                   	pop    %esi
  8012d2:	5f                   	pop    %edi
  8012d3:	5d                   	pop    %ebp
  8012d4:	c3                   	ret    
  8012d5:	8d 76 00             	lea    0x0(%esi),%esi
  8012d8:	39 f2                	cmp    %esi,%edx
  8012da:	76 14                	jbe    8012f0 <__udivdi3+0x50>
  8012dc:	31 ff                	xor    %edi,%edi
  8012de:	31 c0                	xor    %eax,%eax
  8012e0:	89 fa                	mov    %edi,%edx
  8012e2:	83 c4 1c             	add    $0x1c,%esp
  8012e5:	5b                   	pop    %ebx
  8012e6:	5e                   	pop    %esi
  8012e7:	5f                   	pop    %edi
  8012e8:	5d                   	pop    %ebp
  8012e9:	c3                   	ret    
  8012ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012f0:	0f bd fa             	bsr    %edx,%edi
  8012f3:	83 f7 1f             	xor    $0x1f,%edi
  8012f6:	75 48                	jne    801340 <__udivdi3+0xa0>
  8012f8:	39 f2                	cmp    %esi,%edx
  8012fa:	72 06                	jb     801302 <__udivdi3+0x62>
  8012fc:	31 c0                	xor    %eax,%eax
  8012fe:	39 eb                	cmp    %ebp,%ebx
  801300:	77 de                	ja     8012e0 <__udivdi3+0x40>
  801302:	b8 01 00 00 00       	mov    $0x1,%eax
  801307:	eb d7                	jmp    8012e0 <__udivdi3+0x40>
  801309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801310:	89 d9                	mov    %ebx,%ecx
  801312:	85 db                	test   %ebx,%ebx
  801314:	75 0b                	jne    801321 <__udivdi3+0x81>
  801316:	b8 01 00 00 00       	mov    $0x1,%eax
  80131b:	31 d2                	xor    %edx,%edx
  80131d:	f7 f3                	div    %ebx
  80131f:	89 c1                	mov    %eax,%ecx
  801321:	31 d2                	xor    %edx,%edx
  801323:	89 f0                	mov    %esi,%eax
  801325:	f7 f1                	div    %ecx
  801327:	89 c6                	mov    %eax,%esi
  801329:	89 e8                	mov    %ebp,%eax
  80132b:	89 f7                	mov    %esi,%edi
  80132d:	f7 f1                	div    %ecx
  80132f:	89 fa                	mov    %edi,%edx
  801331:	83 c4 1c             	add    $0x1c,%esp
  801334:	5b                   	pop    %ebx
  801335:	5e                   	pop    %esi
  801336:	5f                   	pop    %edi
  801337:	5d                   	pop    %ebp
  801338:	c3                   	ret    
  801339:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801340:	89 f9                	mov    %edi,%ecx
  801342:	b8 20 00 00 00       	mov    $0x20,%eax
  801347:	29 f8                	sub    %edi,%eax
  801349:	d3 e2                	shl    %cl,%edx
  80134b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80134f:	89 c1                	mov    %eax,%ecx
  801351:	89 da                	mov    %ebx,%edx
  801353:	d3 ea                	shr    %cl,%edx
  801355:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801359:	09 d1                	or     %edx,%ecx
  80135b:	89 f2                	mov    %esi,%edx
  80135d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801361:	89 f9                	mov    %edi,%ecx
  801363:	d3 e3                	shl    %cl,%ebx
  801365:	89 c1                	mov    %eax,%ecx
  801367:	d3 ea                	shr    %cl,%edx
  801369:	89 f9                	mov    %edi,%ecx
  80136b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80136f:	89 eb                	mov    %ebp,%ebx
  801371:	d3 e6                	shl    %cl,%esi
  801373:	89 c1                	mov    %eax,%ecx
  801375:	d3 eb                	shr    %cl,%ebx
  801377:	09 de                	or     %ebx,%esi
  801379:	89 f0                	mov    %esi,%eax
  80137b:	f7 74 24 08          	divl   0x8(%esp)
  80137f:	89 d6                	mov    %edx,%esi
  801381:	89 c3                	mov    %eax,%ebx
  801383:	f7 64 24 0c          	mull   0xc(%esp)
  801387:	39 d6                	cmp    %edx,%esi
  801389:	72 15                	jb     8013a0 <__udivdi3+0x100>
  80138b:	89 f9                	mov    %edi,%ecx
  80138d:	d3 e5                	shl    %cl,%ebp
  80138f:	39 c5                	cmp    %eax,%ebp
  801391:	73 04                	jae    801397 <__udivdi3+0xf7>
  801393:	39 d6                	cmp    %edx,%esi
  801395:	74 09                	je     8013a0 <__udivdi3+0x100>
  801397:	89 d8                	mov    %ebx,%eax
  801399:	31 ff                	xor    %edi,%edi
  80139b:	e9 40 ff ff ff       	jmp    8012e0 <__udivdi3+0x40>
  8013a0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8013a3:	31 ff                	xor    %edi,%edi
  8013a5:	e9 36 ff ff ff       	jmp    8012e0 <__udivdi3+0x40>
  8013aa:	66 90                	xchg   %ax,%ax
  8013ac:	66 90                	xchg   %ax,%ax
  8013ae:	66 90                	xchg   %ax,%ax

008013b0 <__umoddi3>:
  8013b0:	f3 0f 1e fb          	endbr32 
  8013b4:	55                   	push   %ebp
  8013b5:	57                   	push   %edi
  8013b6:	56                   	push   %esi
  8013b7:	53                   	push   %ebx
  8013b8:	83 ec 1c             	sub    $0x1c,%esp
  8013bb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8013bf:	8b 74 24 30          	mov    0x30(%esp),%esi
  8013c3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8013c7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8013cb:	85 c0                	test   %eax,%eax
  8013cd:	75 19                	jne    8013e8 <__umoddi3+0x38>
  8013cf:	39 df                	cmp    %ebx,%edi
  8013d1:	76 5d                	jbe    801430 <__umoddi3+0x80>
  8013d3:	89 f0                	mov    %esi,%eax
  8013d5:	89 da                	mov    %ebx,%edx
  8013d7:	f7 f7                	div    %edi
  8013d9:	89 d0                	mov    %edx,%eax
  8013db:	31 d2                	xor    %edx,%edx
  8013dd:	83 c4 1c             	add    $0x1c,%esp
  8013e0:	5b                   	pop    %ebx
  8013e1:	5e                   	pop    %esi
  8013e2:	5f                   	pop    %edi
  8013e3:	5d                   	pop    %ebp
  8013e4:	c3                   	ret    
  8013e5:	8d 76 00             	lea    0x0(%esi),%esi
  8013e8:	89 f2                	mov    %esi,%edx
  8013ea:	39 d8                	cmp    %ebx,%eax
  8013ec:	76 12                	jbe    801400 <__umoddi3+0x50>
  8013ee:	89 f0                	mov    %esi,%eax
  8013f0:	89 da                	mov    %ebx,%edx
  8013f2:	83 c4 1c             	add    $0x1c,%esp
  8013f5:	5b                   	pop    %ebx
  8013f6:	5e                   	pop    %esi
  8013f7:	5f                   	pop    %edi
  8013f8:	5d                   	pop    %ebp
  8013f9:	c3                   	ret    
  8013fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801400:	0f bd e8             	bsr    %eax,%ebp
  801403:	83 f5 1f             	xor    $0x1f,%ebp
  801406:	75 50                	jne    801458 <__umoddi3+0xa8>
  801408:	39 d8                	cmp    %ebx,%eax
  80140a:	0f 82 e0 00 00 00    	jb     8014f0 <__umoddi3+0x140>
  801410:	89 d9                	mov    %ebx,%ecx
  801412:	39 f7                	cmp    %esi,%edi
  801414:	0f 86 d6 00 00 00    	jbe    8014f0 <__umoddi3+0x140>
  80141a:	89 d0                	mov    %edx,%eax
  80141c:	89 ca                	mov    %ecx,%edx
  80141e:	83 c4 1c             	add    $0x1c,%esp
  801421:	5b                   	pop    %ebx
  801422:	5e                   	pop    %esi
  801423:	5f                   	pop    %edi
  801424:	5d                   	pop    %ebp
  801425:	c3                   	ret    
  801426:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80142d:	8d 76 00             	lea    0x0(%esi),%esi
  801430:	89 fd                	mov    %edi,%ebp
  801432:	85 ff                	test   %edi,%edi
  801434:	75 0b                	jne    801441 <__umoddi3+0x91>
  801436:	b8 01 00 00 00       	mov    $0x1,%eax
  80143b:	31 d2                	xor    %edx,%edx
  80143d:	f7 f7                	div    %edi
  80143f:	89 c5                	mov    %eax,%ebp
  801441:	89 d8                	mov    %ebx,%eax
  801443:	31 d2                	xor    %edx,%edx
  801445:	f7 f5                	div    %ebp
  801447:	89 f0                	mov    %esi,%eax
  801449:	f7 f5                	div    %ebp
  80144b:	89 d0                	mov    %edx,%eax
  80144d:	31 d2                	xor    %edx,%edx
  80144f:	eb 8c                	jmp    8013dd <__umoddi3+0x2d>
  801451:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801458:	89 e9                	mov    %ebp,%ecx
  80145a:	ba 20 00 00 00       	mov    $0x20,%edx
  80145f:	29 ea                	sub    %ebp,%edx
  801461:	d3 e0                	shl    %cl,%eax
  801463:	89 44 24 08          	mov    %eax,0x8(%esp)
  801467:	89 d1                	mov    %edx,%ecx
  801469:	89 f8                	mov    %edi,%eax
  80146b:	d3 e8                	shr    %cl,%eax
  80146d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801471:	89 54 24 04          	mov    %edx,0x4(%esp)
  801475:	8b 54 24 04          	mov    0x4(%esp),%edx
  801479:	09 c1                	or     %eax,%ecx
  80147b:	89 d8                	mov    %ebx,%eax
  80147d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801481:	89 e9                	mov    %ebp,%ecx
  801483:	d3 e7                	shl    %cl,%edi
  801485:	89 d1                	mov    %edx,%ecx
  801487:	d3 e8                	shr    %cl,%eax
  801489:	89 e9                	mov    %ebp,%ecx
  80148b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80148f:	d3 e3                	shl    %cl,%ebx
  801491:	89 c7                	mov    %eax,%edi
  801493:	89 d1                	mov    %edx,%ecx
  801495:	89 f0                	mov    %esi,%eax
  801497:	d3 e8                	shr    %cl,%eax
  801499:	89 e9                	mov    %ebp,%ecx
  80149b:	89 fa                	mov    %edi,%edx
  80149d:	d3 e6                	shl    %cl,%esi
  80149f:	09 d8                	or     %ebx,%eax
  8014a1:	f7 74 24 08          	divl   0x8(%esp)
  8014a5:	89 d1                	mov    %edx,%ecx
  8014a7:	89 f3                	mov    %esi,%ebx
  8014a9:	f7 64 24 0c          	mull   0xc(%esp)
  8014ad:	89 c6                	mov    %eax,%esi
  8014af:	89 d7                	mov    %edx,%edi
  8014b1:	39 d1                	cmp    %edx,%ecx
  8014b3:	72 06                	jb     8014bb <__umoddi3+0x10b>
  8014b5:	75 10                	jne    8014c7 <__umoddi3+0x117>
  8014b7:	39 c3                	cmp    %eax,%ebx
  8014b9:	73 0c                	jae    8014c7 <__umoddi3+0x117>
  8014bb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8014bf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8014c3:	89 d7                	mov    %edx,%edi
  8014c5:	89 c6                	mov    %eax,%esi
  8014c7:	89 ca                	mov    %ecx,%edx
  8014c9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8014ce:	29 f3                	sub    %esi,%ebx
  8014d0:	19 fa                	sbb    %edi,%edx
  8014d2:	89 d0                	mov    %edx,%eax
  8014d4:	d3 e0                	shl    %cl,%eax
  8014d6:	89 e9                	mov    %ebp,%ecx
  8014d8:	d3 eb                	shr    %cl,%ebx
  8014da:	d3 ea                	shr    %cl,%edx
  8014dc:	09 d8                	or     %ebx,%eax
  8014de:	83 c4 1c             	add    $0x1c,%esp
  8014e1:	5b                   	pop    %ebx
  8014e2:	5e                   	pop    %esi
  8014e3:	5f                   	pop    %edi
  8014e4:	5d                   	pop    %ebp
  8014e5:	c3                   	ret    
  8014e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8014ed:	8d 76 00             	lea    0x0(%esi),%esi
  8014f0:	29 fe                	sub    %edi,%esi
  8014f2:	19 c3                	sbb    %eax,%ebx
  8014f4:	89 f2                	mov    %esi,%edx
  8014f6:	89 d9                	mov    %ebx,%ecx
  8014f8:	e9 1d ff ff ff       	jmp    80141a <__umoddi3+0x6a>
