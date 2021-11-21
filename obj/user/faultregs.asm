
obj/user/faultregs:     file format elf32-i386


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
  80002c:	e8 b8 05 00 00       	call   8005e9 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 71 16 80 00       	push   $0x801671
  800049:	68 40 16 80 00       	push   $0x801640
  80004e:	e8 e0 06 00 00       	call   800733 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 50 16 80 00       	push   $0x801650
  80005c:	68 54 16 80 00       	push   $0x801654
  800061:	e8 cd 06 00 00       	call   800733 <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	0f 84 2e 02 00 00    	je     8002a1 <check_regs+0x26e>
  800073:	83 ec 0c             	sub    $0xc,%esp
  800076:	68 68 16 80 00       	push   $0x801668
  80007b:	e8 b3 06 00 00       	call   800733 <cprintf>
  800080:	83 c4 10             	add    $0x10,%esp
  800083:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  800088:	ff 73 04             	pushl  0x4(%ebx)
  80008b:	ff 76 04             	pushl  0x4(%esi)
  80008e:	68 72 16 80 00       	push   $0x801672
  800093:	68 54 16 80 00       	push   $0x801654
  800098:	e8 96 06 00 00       	call   800733 <cprintf>
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	8b 43 04             	mov    0x4(%ebx),%eax
  8000a3:	39 46 04             	cmp    %eax,0x4(%esi)
  8000a6:	0f 84 0f 02 00 00    	je     8002bb <check_regs+0x288>
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 68 16 80 00       	push   $0x801668
  8000b4:	e8 7a 06 00 00       	call   800733 <cprintf>
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000c1:	ff 73 08             	pushl  0x8(%ebx)
  8000c4:	ff 76 08             	pushl  0x8(%esi)
  8000c7:	68 76 16 80 00       	push   $0x801676
  8000cc:	68 54 16 80 00       	push   $0x801654
  8000d1:	e8 5d 06 00 00       	call   800733 <cprintf>
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8b 43 08             	mov    0x8(%ebx),%eax
  8000dc:	39 46 08             	cmp    %eax,0x8(%esi)
  8000df:	0f 84 eb 01 00 00    	je     8002d0 <check_regs+0x29d>
  8000e5:	83 ec 0c             	sub    $0xc,%esp
  8000e8:	68 68 16 80 00       	push   $0x801668
  8000ed:	e8 41 06 00 00       	call   800733 <cprintf>
  8000f2:	83 c4 10             	add    $0x10,%esp
  8000f5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  8000fa:	ff 73 10             	pushl  0x10(%ebx)
  8000fd:	ff 76 10             	pushl  0x10(%esi)
  800100:	68 7a 16 80 00       	push   $0x80167a
  800105:	68 54 16 80 00       	push   $0x801654
  80010a:	e8 24 06 00 00       	call   800733 <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	8b 43 10             	mov    0x10(%ebx),%eax
  800115:	39 46 10             	cmp    %eax,0x10(%esi)
  800118:	0f 84 c7 01 00 00    	je     8002e5 <check_regs+0x2b2>
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	68 68 16 80 00       	push   $0x801668
  800126:	e8 08 06 00 00       	call   800733 <cprintf>
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800133:	ff 73 14             	pushl  0x14(%ebx)
  800136:	ff 76 14             	pushl  0x14(%esi)
  800139:	68 7e 16 80 00       	push   $0x80167e
  80013e:	68 54 16 80 00       	push   $0x801654
  800143:	e8 eb 05 00 00       	call   800733 <cprintf>
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	8b 43 14             	mov    0x14(%ebx),%eax
  80014e:	39 46 14             	cmp    %eax,0x14(%esi)
  800151:	0f 84 a3 01 00 00    	je     8002fa <check_regs+0x2c7>
  800157:	83 ec 0c             	sub    $0xc,%esp
  80015a:	68 68 16 80 00       	push   $0x801668
  80015f:	e8 cf 05 00 00       	call   800733 <cprintf>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  80016c:	ff 73 18             	pushl  0x18(%ebx)
  80016f:	ff 76 18             	pushl  0x18(%esi)
  800172:	68 82 16 80 00       	push   $0x801682
  800177:	68 54 16 80 00       	push   $0x801654
  80017c:	e8 b2 05 00 00       	call   800733 <cprintf>
  800181:	83 c4 10             	add    $0x10,%esp
  800184:	8b 43 18             	mov    0x18(%ebx),%eax
  800187:	39 46 18             	cmp    %eax,0x18(%esi)
  80018a:	0f 84 7f 01 00 00    	je     80030f <check_regs+0x2dc>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 68 16 80 00       	push   $0x801668
  800198:	e8 96 05 00 00       	call   800733 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001a5:	ff 73 1c             	pushl  0x1c(%ebx)
  8001a8:	ff 76 1c             	pushl  0x1c(%esi)
  8001ab:	68 86 16 80 00       	push   $0x801686
  8001b0:	68 54 16 80 00       	push   $0x801654
  8001b5:	e8 79 05 00 00       	call   800733 <cprintf>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	8b 43 1c             	mov    0x1c(%ebx),%eax
  8001c0:	39 46 1c             	cmp    %eax,0x1c(%esi)
  8001c3:	0f 84 5b 01 00 00    	je     800324 <check_regs+0x2f1>
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	68 68 16 80 00       	push   $0x801668
  8001d1:	e8 5d 05 00 00       	call   800733 <cprintf>
  8001d6:	83 c4 10             	add    $0x10,%esp
  8001d9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  8001de:	ff 73 20             	pushl  0x20(%ebx)
  8001e1:	ff 76 20             	pushl  0x20(%esi)
  8001e4:	68 8a 16 80 00       	push   $0x80168a
  8001e9:	68 54 16 80 00       	push   $0x801654
  8001ee:	e8 40 05 00 00       	call   800733 <cprintf>
  8001f3:	83 c4 10             	add    $0x10,%esp
  8001f6:	8b 43 20             	mov    0x20(%ebx),%eax
  8001f9:	39 46 20             	cmp    %eax,0x20(%esi)
  8001fc:	0f 84 37 01 00 00    	je     800339 <check_regs+0x306>
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	68 68 16 80 00       	push   $0x801668
  80020a:	e8 24 05 00 00       	call   800733 <cprintf>
  80020f:	83 c4 10             	add    $0x10,%esp
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  800217:	ff 73 24             	pushl  0x24(%ebx)
  80021a:	ff 76 24             	pushl  0x24(%esi)
  80021d:	68 8e 16 80 00       	push   $0x80168e
  800222:	68 54 16 80 00       	push   $0x801654
  800227:	e8 07 05 00 00       	call   800733 <cprintf>
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	8b 43 24             	mov    0x24(%ebx),%eax
  800232:	39 46 24             	cmp    %eax,0x24(%esi)
  800235:	0f 84 13 01 00 00    	je     80034e <check_regs+0x31b>
  80023b:	83 ec 0c             	sub    $0xc,%esp
  80023e:	68 68 16 80 00       	push   $0x801668
  800243:	e8 eb 04 00 00       	call   800733 <cprintf>
	CHECK(esp, esp);
  800248:	ff 73 28             	pushl  0x28(%ebx)
  80024b:	ff 76 28             	pushl  0x28(%esi)
  80024e:	68 95 16 80 00       	push   $0x801695
  800253:	68 54 16 80 00       	push   $0x801654
  800258:	e8 d6 04 00 00       	call   800733 <cprintf>
  80025d:	83 c4 20             	add    $0x20,%esp
  800260:	8b 43 28             	mov    0x28(%ebx),%eax
  800263:	39 46 28             	cmp    %eax,0x28(%esi)
  800266:	0f 84 53 01 00 00    	je     8003bf <check_regs+0x38c>
  80026c:	83 ec 0c             	sub    $0xc,%esp
  80026f:	68 68 16 80 00       	push   $0x801668
  800274:	e8 ba 04 00 00       	call   800733 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800279:	83 c4 08             	add    $0x8,%esp
  80027c:	ff 75 0c             	pushl  0xc(%ebp)
  80027f:	68 99 16 80 00       	push   $0x801699
  800284:	e8 aa 04 00 00       	call   800733 <cprintf>
  800289:	83 c4 10             	add    $0x10,%esp
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
  80028c:	83 ec 0c             	sub    $0xc,%esp
  80028f:	68 68 16 80 00       	push   $0x801668
  800294:	e8 9a 04 00 00       	call   800733 <cprintf>
  800299:	83 c4 10             	add    $0x10,%esp
}
  80029c:	e9 16 01 00 00       	jmp    8003b7 <check_regs+0x384>
	CHECK(edi, regs.reg_edi);
  8002a1:	83 ec 0c             	sub    $0xc,%esp
  8002a4:	68 64 16 80 00       	push   $0x801664
  8002a9:	e8 85 04 00 00       	call   800733 <cprintf>
  8002ae:	83 c4 10             	add    $0x10,%esp
	int mismatch = 0;
  8002b1:	bf 00 00 00 00       	mov    $0x0,%edi
  8002b6:	e9 cd fd ff ff       	jmp    800088 <check_regs+0x55>
	CHECK(esi, regs.reg_esi);
  8002bb:	83 ec 0c             	sub    $0xc,%esp
  8002be:	68 64 16 80 00       	push   $0x801664
  8002c3:	e8 6b 04 00 00       	call   800733 <cprintf>
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	e9 f1 fd ff ff       	jmp    8000c1 <check_regs+0x8e>
	CHECK(ebp, regs.reg_ebp);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	68 64 16 80 00       	push   $0x801664
  8002d8:	e8 56 04 00 00       	call   800733 <cprintf>
  8002dd:	83 c4 10             	add    $0x10,%esp
  8002e0:	e9 15 fe ff ff       	jmp    8000fa <check_regs+0xc7>
	CHECK(ebx, regs.reg_ebx);
  8002e5:	83 ec 0c             	sub    $0xc,%esp
  8002e8:	68 64 16 80 00       	push   $0x801664
  8002ed:	e8 41 04 00 00       	call   800733 <cprintf>
  8002f2:	83 c4 10             	add    $0x10,%esp
  8002f5:	e9 39 fe ff ff       	jmp    800133 <check_regs+0x100>
	CHECK(edx, regs.reg_edx);
  8002fa:	83 ec 0c             	sub    $0xc,%esp
  8002fd:	68 64 16 80 00       	push   $0x801664
  800302:	e8 2c 04 00 00       	call   800733 <cprintf>
  800307:	83 c4 10             	add    $0x10,%esp
  80030a:	e9 5d fe ff ff       	jmp    80016c <check_regs+0x139>
	CHECK(ecx, regs.reg_ecx);
  80030f:	83 ec 0c             	sub    $0xc,%esp
  800312:	68 64 16 80 00       	push   $0x801664
  800317:	e8 17 04 00 00       	call   800733 <cprintf>
  80031c:	83 c4 10             	add    $0x10,%esp
  80031f:	e9 81 fe ff ff       	jmp    8001a5 <check_regs+0x172>
	CHECK(eax, regs.reg_eax);
  800324:	83 ec 0c             	sub    $0xc,%esp
  800327:	68 64 16 80 00       	push   $0x801664
  80032c:	e8 02 04 00 00       	call   800733 <cprintf>
  800331:	83 c4 10             	add    $0x10,%esp
  800334:	e9 a5 fe ff ff       	jmp    8001de <check_regs+0x1ab>
	CHECK(eip, eip);
  800339:	83 ec 0c             	sub    $0xc,%esp
  80033c:	68 64 16 80 00       	push   $0x801664
  800341:	e8 ed 03 00 00       	call   800733 <cprintf>
  800346:	83 c4 10             	add    $0x10,%esp
  800349:	e9 c9 fe ff ff       	jmp    800217 <check_regs+0x1e4>
	CHECK(eflags, eflags);
  80034e:	83 ec 0c             	sub    $0xc,%esp
  800351:	68 64 16 80 00       	push   $0x801664
  800356:	e8 d8 03 00 00       	call   800733 <cprintf>
	CHECK(esp, esp);
  80035b:	ff 73 28             	pushl  0x28(%ebx)
  80035e:	ff 76 28             	pushl  0x28(%esi)
  800361:	68 95 16 80 00       	push   $0x801695
  800366:	68 54 16 80 00       	push   $0x801654
  80036b:	e8 c3 03 00 00       	call   800733 <cprintf>
  800370:	83 c4 20             	add    $0x20,%esp
  800373:	8b 43 28             	mov    0x28(%ebx),%eax
  800376:	39 46 28             	cmp    %eax,0x28(%esi)
  800379:	0f 85 ed fe ff ff    	jne    80026c <check_regs+0x239>
  80037f:	83 ec 0c             	sub    $0xc,%esp
  800382:	68 64 16 80 00       	push   $0x801664
  800387:	e8 a7 03 00 00       	call   800733 <cprintf>
	cprintf("Registers %s ", testname);
  80038c:	83 c4 08             	add    $0x8,%esp
  80038f:	ff 75 0c             	pushl  0xc(%ebp)
  800392:	68 99 16 80 00       	push   $0x801699
  800397:	e8 97 03 00 00       	call   800733 <cprintf>
	if (!mismatch)
  80039c:	83 c4 10             	add    $0x10,%esp
  80039f:	85 ff                	test   %edi,%edi
  8003a1:	0f 85 e5 fe ff ff    	jne    80028c <check_regs+0x259>
		cprintf("OK\n");
  8003a7:	83 ec 0c             	sub    $0xc,%esp
  8003aa:	68 64 16 80 00       	push   $0x801664
  8003af:	e8 7f 03 00 00       	call   800733 <cprintf>
  8003b4:	83 c4 10             	add    $0x10,%esp
}
  8003b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003ba:	5b                   	pop    %ebx
  8003bb:	5e                   	pop    %esi
  8003bc:	5f                   	pop    %edi
  8003bd:	5d                   	pop    %ebp
  8003be:	c3                   	ret    
	CHECK(esp, esp);
  8003bf:	83 ec 0c             	sub    $0xc,%esp
  8003c2:	68 64 16 80 00       	push   $0x801664
  8003c7:	e8 67 03 00 00       	call   800733 <cprintf>
	cprintf("Registers %s ", testname);
  8003cc:	83 c4 08             	add    $0x8,%esp
  8003cf:	ff 75 0c             	pushl  0xc(%ebp)
  8003d2:	68 99 16 80 00       	push   $0x801699
  8003d7:	e8 57 03 00 00       	call   800733 <cprintf>
  8003dc:	83 c4 10             	add    $0x10,%esp
  8003df:	e9 a8 fe ff ff       	jmp    80028c <check_regs+0x259>

008003e4 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003e4:	f3 0f 1e fb          	endbr32 
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	83 ec 08             	sub    $0x8,%esp
  8003ee:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003f1:	8b 10                	mov    (%eax),%edx
  8003f3:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003f9:	0f 85 a3 00 00 00    	jne    8004a2 <pgfault+0xbe>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003ff:	8b 50 08             	mov    0x8(%eax),%edx
  800402:	89 15 60 20 80 00    	mov    %edx,0x802060
  800408:	8b 50 0c             	mov    0xc(%eax),%edx
  80040b:	89 15 64 20 80 00    	mov    %edx,0x802064
  800411:	8b 50 10             	mov    0x10(%eax),%edx
  800414:	89 15 68 20 80 00    	mov    %edx,0x802068
  80041a:	8b 50 14             	mov    0x14(%eax),%edx
  80041d:	89 15 6c 20 80 00    	mov    %edx,0x80206c
  800423:	8b 50 18             	mov    0x18(%eax),%edx
  800426:	89 15 70 20 80 00    	mov    %edx,0x802070
  80042c:	8b 50 1c             	mov    0x1c(%eax),%edx
  80042f:	89 15 74 20 80 00    	mov    %edx,0x802074
  800435:	8b 50 20             	mov    0x20(%eax),%edx
  800438:	89 15 78 20 80 00    	mov    %edx,0x802078
  80043e:	8b 50 24             	mov    0x24(%eax),%edx
  800441:	89 15 7c 20 80 00    	mov    %edx,0x80207c
	during.eip = utf->utf_eip;
  800447:	8b 50 28             	mov    0x28(%eax),%edx
  80044a:	89 15 80 20 80 00    	mov    %edx,0x802080
	during.eflags = utf->utf_eflags & ~FL_RF;
  800450:	8b 50 2c             	mov    0x2c(%eax),%edx
  800453:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  800459:	89 15 84 20 80 00    	mov    %edx,0x802084
	during.esp = utf->utf_esp;
  80045f:	8b 40 30             	mov    0x30(%eax),%eax
  800462:	a3 88 20 80 00       	mov    %eax,0x802088
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800467:	83 ec 08             	sub    $0x8,%esp
  80046a:	68 bf 16 80 00       	push   $0x8016bf
  80046f:	68 cd 16 80 00       	push   $0x8016cd
  800474:	b9 60 20 80 00       	mov    $0x802060,%ecx
  800479:	ba b8 16 80 00       	mov    $0x8016b8,%edx
  80047e:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  800483:	e8 ab fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800488:	83 c4 0c             	add    $0xc,%esp
  80048b:	6a 07                	push   $0x7
  80048d:	68 00 00 40 00       	push   $0x400000
  800492:	6a 00                	push   $0x0
  800494:	e8 e6 0c 00 00       	call   80117f <sys_page_alloc>
  800499:	83 c4 10             	add    $0x10,%esp
  80049c:	85 c0                	test   %eax,%eax
  80049e:	78 1a                	js     8004ba <pgfault+0xd6>
		panic("sys_page_alloc: %e", r);
}
  8004a0:	c9                   	leave  
  8004a1:	c3                   	ret    
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8004a2:	83 ec 0c             	sub    $0xc,%esp
  8004a5:	ff 70 28             	pushl  0x28(%eax)
  8004a8:	52                   	push   %edx
  8004a9:	68 00 17 80 00       	push   $0x801700
  8004ae:	6a 50                	push   $0x50
  8004b0:	68 a7 16 80 00       	push   $0x8016a7
  8004b5:	e8 92 01 00 00       	call   80064c <_panic>
		panic("sys_page_alloc: %e", r);
  8004ba:	50                   	push   %eax
  8004bb:	68 d4 16 80 00       	push   $0x8016d4
  8004c0:	6a 5c                	push   $0x5c
  8004c2:	68 a7 16 80 00       	push   $0x8016a7
  8004c7:	e8 80 01 00 00       	call   80064c <_panic>

008004cc <umain>:

void
umain(int argc, char **argv)
{
  8004cc:	f3 0f 1e fb          	endbr32 
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  8004d6:	68 e4 03 80 00       	push   $0x8003e4
  8004db:	e8 6a 0e 00 00       	call   80134a <set_pgfault_handler>

	asm volatile(
  8004e0:	50                   	push   %eax
  8004e1:	9c                   	pushf  
  8004e2:	58                   	pop    %eax
  8004e3:	0d d5 08 00 00       	or     $0x8d5,%eax
  8004e8:	50                   	push   %eax
  8004e9:	9d                   	popf   
  8004ea:	a3 c4 20 80 00       	mov    %eax,0x8020c4
  8004ef:	8d 05 2a 05 80 00    	lea    0x80052a,%eax
  8004f5:	a3 c0 20 80 00       	mov    %eax,0x8020c0
  8004fa:	58                   	pop    %eax
  8004fb:	89 3d a0 20 80 00    	mov    %edi,0x8020a0
  800501:	89 35 a4 20 80 00    	mov    %esi,0x8020a4
  800507:	89 2d a8 20 80 00    	mov    %ebp,0x8020a8
  80050d:	89 1d b0 20 80 00    	mov    %ebx,0x8020b0
  800513:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  800519:	89 0d b8 20 80 00    	mov    %ecx,0x8020b8
  80051f:	a3 bc 20 80 00       	mov    %eax,0x8020bc
  800524:	89 25 c8 20 80 00    	mov    %esp,0x8020c8
  80052a:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  800531:	00 00 00 
  800534:	89 3d 20 20 80 00    	mov    %edi,0x802020
  80053a:	89 35 24 20 80 00    	mov    %esi,0x802024
  800540:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  800546:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  80054c:	89 15 34 20 80 00    	mov    %edx,0x802034
  800552:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  800558:	a3 3c 20 80 00       	mov    %eax,0x80203c
  80055d:	89 25 48 20 80 00    	mov    %esp,0x802048
  800563:	8b 3d a0 20 80 00    	mov    0x8020a0,%edi
  800569:	8b 35 a4 20 80 00    	mov    0x8020a4,%esi
  80056f:	8b 2d a8 20 80 00    	mov    0x8020a8,%ebp
  800575:	8b 1d b0 20 80 00    	mov    0x8020b0,%ebx
  80057b:	8b 15 b4 20 80 00    	mov    0x8020b4,%edx
  800581:	8b 0d b8 20 80 00    	mov    0x8020b8,%ecx
  800587:	a1 bc 20 80 00       	mov    0x8020bc,%eax
  80058c:	8b 25 c8 20 80 00    	mov    0x8020c8,%esp
  800592:	50                   	push   %eax
  800593:	9c                   	pushf  
  800594:	58                   	pop    %eax
  800595:	a3 44 20 80 00       	mov    %eax,0x802044
  80059a:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  80059b:	83 c4 10             	add    $0x10,%esp
  80059e:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  8005a5:	75 30                	jne    8005d7 <umain+0x10b>
		cprintf("EIP after page-fault MISMATCH\n");
	after.eip = before.eip;
  8005a7:	a1 c0 20 80 00       	mov    0x8020c0,%eax
  8005ac:	a3 40 20 80 00       	mov    %eax,0x802040

	check_regs(&before, "before", &after, "after", "after page-fault");
  8005b1:	83 ec 08             	sub    $0x8,%esp
  8005b4:	68 e7 16 80 00       	push   $0x8016e7
  8005b9:	68 f8 16 80 00       	push   $0x8016f8
  8005be:	b9 20 20 80 00       	mov    $0x802020,%ecx
  8005c3:	ba b8 16 80 00       	mov    $0x8016b8,%edx
  8005c8:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  8005cd:	e8 61 fa ff ff       	call   800033 <check_regs>
}
  8005d2:	83 c4 10             	add    $0x10,%esp
  8005d5:	c9                   	leave  
  8005d6:	c3                   	ret    
		cprintf("EIP after page-fault MISMATCH\n");
  8005d7:	83 ec 0c             	sub    $0xc,%esp
  8005da:	68 34 17 80 00       	push   $0x801734
  8005df:	e8 4f 01 00 00       	call   800733 <cprintf>
  8005e4:	83 c4 10             	add    $0x10,%esp
  8005e7:	eb be                	jmp    8005a7 <umain+0xdb>

008005e9 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8005e9:	f3 0f 1e fb          	endbr32 
  8005ed:	55                   	push   %ebp
  8005ee:	89 e5                	mov    %esp,%ebp
  8005f0:	56                   	push   %esi
  8005f1:	53                   	push   %ebx
  8005f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005f5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8005f8:	e8 3c 0b 00 00       	call   801139 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  8005fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800602:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  800608:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80060d:	a3 20 41 80 00       	mov    %eax,0x804120

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800612:	85 db                	test   %ebx,%ebx
  800614:	7e 07                	jle    80061d <libmain+0x34>
		binaryname = argv[0];
  800616:	8b 06                	mov    (%esi),%eax
  800618:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80061d:	83 ec 08             	sub    $0x8,%esp
  800620:	56                   	push   %esi
  800621:	53                   	push   %ebx
  800622:	e8 a5 fe ff ff       	call   8004cc <umain>

	// exit gracefully
	exit();
  800627:	e8 0a 00 00 00       	call   800636 <exit>
}
  80062c:	83 c4 10             	add    $0x10,%esp
  80062f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800632:	5b                   	pop    %ebx
  800633:	5e                   	pop    %esi
  800634:	5d                   	pop    %ebp
  800635:	c3                   	ret    

00800636 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800636:	f3 0f 1e fb          	endbr32 
  80063a:	55                   	push   %ebp
  80063b:	89 e5                	mov    %esp,%ebp
  80063d:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800640:	6a 00                	push   $0x0
  800642:	e8 ad 0a 00 00       	call   8010f4 <sys_env_destroy>
}
  800647:	83 c4 10             	add    $0x10,%esp
  80064a:	c9                   	leave  
  80064b:	c3                   	ret    

0080064c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80064c:	f3 0f 1e fb          	endbr32 
  800650:	55                   	push   %ebp
  800651:	89 e5                	mov    %esp,%ebp
  800653:	56                   	push   %esi
  800654:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800655:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800658:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80065e:	e8 d6 0a 00 00       	call   801139 <sys_getenvid>
  800663:	83 ec 0c             	sub    $0xc,%esp
  800666:	ff 75 0c             	pushl  0xc(%ebp)
  800669:	ff 75 08             	pushl  0x8(%ebp)
  80066c:	56                   	push   %esi
  80066d:	50                   	push   %eax
  80066e:	68 60 17 80 00       	push   $0x801760
  800673:	e8 bb 00 00 00       	call   800733 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800678:	83 c4 18             	add    $0x18,%esp
  80067b:	53                   	push   %ebx
  80067c:	ff 75 10             	pushl  0x10(%ebp)
  80067f:	e8 5a 00 00 00       	call   8006de <vcprintf>
	cprintf("\n");
  800684:	c7 04 24 70 16 80 00 	movl   $0x801670,(%esp)
  80068b:	e8 a3 00 00 00       	call   800733 <cprintf>
  800690:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800693:	cc                   	int3   
  800694:	eb fd                	jmp    800693 <_panic+0x47>

00800696 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800696:	f3 0f 1e fb          	endbr32 
  80069a:	55                   	push   %ebp
  80069b:	89 e5                	mov    %esp,%ebp
  80069d:	53                   	push   %ebx
  80069e:	83 ec 04             	sub    $0x4,%esp
  8006a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006a4:	8b 13                	mov    (%ebx),%edx
  8006a6:	8d 42 01             	lea    0x1(%edx),%eax
  8006a9:	89 03                	mov    %eax,(%ebx)
  8006ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006ae:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8006b2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006b7:	74 09                	je     8006c2 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8006b9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8006bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c0:	c9                   	leave  
  8006c1:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8006c2:	83 ec 08             	sub    $0x8,%esp
  8006c5:	68 ff 00 00 00       	push   $0xff
  8006ca:	8d 43 08             	lea    0x8(%ebx),%eax
  8006cd:	50                   	push   %eax
  8006ce:	e8 dc 09 00 00       	call   8010af <sys_cputs>
		b->idx = 0;
  8006d3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8006d9:	83 c4 10             	add    $0x10,%esp
  8006dc:	eb db                	jmp    8006b9 <putch+0x23>

008006de <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8006de:	f3 0f 1e fb          	endbr32 
  8006e2:	55                   	push   %ebp
  8006e3:	89 e5                	mov    %esp,%ebp
  8006e5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8006eb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006f2:	00 00 00 
	b.cnt = 0;
  8006f5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006fc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006ff:	ff 75 0c             	pushl  0xc(%ebp)
  800702:	ff 75 08             	pushl  0x8(%ebp)
  800705:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80070b:	50                   	push   %eax
  80070c:	68 96 06 80 00       	push   $0x800696
  800711:	e8 20 01 00 00       	call   800836 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800716:	83 c4 08             	add    $0x8,%esp
  800719:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80071f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800725:	50                   	push   %eax
  800726:	e8 84 09 00 00       	call   8010af <sys_cputs>

	return b.cnt;
}
  80072b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800731:	c9                   	leave  
  800732:	c3                   	ret    

00800733 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800733:	f3 0f 1e fb          	endbr32 
  800737:	55                   	push   %ebp
  800738:	89 e5                	mov    %esp,%ebp
  80073a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80073d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800740:	50                   	push   %eax
  800741:	ff 75 08             	pushl  0x8(%ebp)
  800744:	e8 95 ff ff ff       	call   8006de <vcprintf>
	va_end(ap);

	return cnt;
}
  800749:	c9                   	leave  
  80074a:	c3                   	ret    

0080074b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80074b:	55                   	push   %ebp
  80074c:	89 e5                	mov    %esp,%ebp
  80074e:	57                   	push   %edi
  80074f:	56                   	push   %esi
  800750:	53                   	push   %ebx
  800751:	83 ec 1c             	sub    $0x1c,%esp
  800754:	89 c7                	mov    %eax,%edi
  800756:	89 d6                	mov    %edx,%esi
  800758:	8b 45 08             	mov    0x8(%ebp),%eax
  80075b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80075e:	89 d1                	mov    %edx,%ecx
  800760:	89 c2                	mov    %eax,%edx
  800762:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800765:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800768:	8b 45 10             	mov    0x10(%ebp),%eax
  80076b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80076e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800771:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800778:	39 c2                	cmp    %eax,%edx
  80077a:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80077d:	72 3e                	jb     8007bd <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80077f:	83 ec 0c             	sub    $0xc,%esp
  800782:	ff 75 18             	pushl  0x18(%ebp)
  800785:	83 eb 01             	sub    $0x1,%ebx
  800788:	53                   	push   %ebx
  800789:	50                   	push   %eax
  80078a:	83 ec 08             	sub    $0x8,%esp
  80078d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800790:	ff 75 e0             	pushl  -0x20(%ebp)
  800793:	ff 75 dc             	pushl  -0x24(%ebp)
  800796:	ff 75 d8             	pushl  -0x28(%ebp)
  800799:	e8 32 0c 00 00       	call   8013d0 <__udivdi3>
  80079e:	83 c4 18             	add    $0x18,%esp
  8007a1:	52                   	push   %edx
  8007a2:	50                   	push   %eax
  8007a3:	89 f2                	mov    %esi,%edx
  8007a5:	89 f8                	mov    %edi,%eax
  8007a7:	e8 9f ff ff ff       	call   80074b <printnum>
  8007ac:	83 c4 20             	add    $0x20,%esp
  8007af:	eb 13                	jmp    8007c4 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007b1:	83 ec 08             	sub    $0x8,%esp
  8007b4:	56                   	push   %esi
  8007b5:	ff 75 18             	pushl  0x18(%ebp)
  8007b8:	ff d7                	call   *%edi
  8007ba:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8007bd:	83 eb 01             	sub    $0x1,%ebx
  8007c0:	85 db                	test   %ebx,%ebx
  8007c2:	7f ed                	jg     8007b1 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007c4:	83 ec 08             	sub    $0x8,%esp
  8007c7:	56                   	push   %esi
  8007c8:	83 ec 04             	sub    $0x4,%esp
  8007cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8007d1:	ff 75 dc             	pushl  -0x24(%ebp)
  8007d4:	ff 75 d8             	pushl  -0x28(%ebp)
  8007d7:	e8 04 0d 00 00       	call   8014e0 <__umoddi3>
  8007dc:	83 c4 14             	add    $0x14,%esp
  8007df:	0f be 80 83 17 80 00 	movsbl 0x801783(%eax),%eax
  8007e6:	50                   	push   %eax
  8007e7:	ff d7                	call   *%edi
}
  8007e9:	83 c4 10             	add    $0x10,%esp
  8007ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ef:	5b                   	pop    %ebx
  8007f0:	5e                   	pop    %esi
  8007f1:	5f                   	pop    %edi
  8007f2:	5d                   	pop    %ebp
  8007f3:	c3                   	ret    

008007f4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007f4:	f3 0f 1e fb          	endbr32 
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007fe:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800802:	8b 10                	mov    (%eax),%edx
  800804:	3b 50 04             	cmp    0x4(%eax),%edx
  800807:	73 0a                	jae    800813 <sprintputch+0x1f>
		*b->buf++ = ch;
  800809:	8d 4a 01             	lea    0x1(%edx),%ecx
  80080c:	89 08                	mov    %ecx,(%eax)
  80080e:	8b 45 08             	mov    0x8(%ebp),%eax
  800811:	88 02                	mov    %al,(%edx)
}
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <printfmt>:
{
  800815:	f3 0f 1e fb          	endbr32 
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80081f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800822:	50                   	push   %eax
  800823:	ff 75 10             	pushl  0x10(%ebp)
  800826:	ff 75 0c             	pushl  0xc(%ebp)
  800829:	ff 75 08             	pushl  0x8(%ebp)
  80082c:	e8 05 00 00 00       	call   800836 <vprintfmt>
}
  800831:	83 c4 10             	add    $0x10,%esp
  800834:	c9                   	leave  
  800835:	c3                   	ret    

00800836 <vprintfmt>:
{
  800836:	f3 0f 1e fb          	endbr32 
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	57                   	push   %edi
  80083e:	56                   	push   %esi
  80083f:	53                   	push   %ebx
  800840:	83 ec 3c             	sub    $0x3c,%esp
  800843:	8b 75 08             	mov    0x8(%ebp),%esi
  800846:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800849:	8b 7d 10             	mov    0x10(%ebp),%edi
  80084c:	e9 8e 03 00 00       	jmp    800bdf <vprintfmt+0x3a9>
		padc = ' ';
  800851:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800855:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80085c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800863:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80086a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80086f:	8d 47 01             	lea    0x1(%edi),%eax
  800872:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800875:	0f b6 17             	movzbl (%edi),%edx
  800878:	8d 42 dd             	lea    -0x23(%edx),%eax
  80087b:	3c 55                	cmp    $0x55,%al
  80087d:	0f 87 df 03 00 00    	ja     800c62 <vprintfmt+0x42c>
  800883:	0f b6 c0             	movzbl %al,%eax
  800886:	3e ff 24 85 40 18 80 	notrack jmp *0x801840(,%eax,4)
  80088d:	00 
  80088e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800891:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800895:	eb d8                	jmp    80086f <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800897:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80089a:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80089e:	eb cf                	jmp    80086f <vprintfmt+0x39>
  8008a0:	0f b6 d2             	movzbl %dl,%edx
  8008a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8008a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ab:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8008ae:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8008b1:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8008b5:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8008b8:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8008bb:	83 f9 09             	cmp    $0x9,%ecx
  8008be:	77 55                	ja     800915 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8008c0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8008c3:	eb e9                	jmp    8008ae <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8008c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c8:	8b 00                	mov    (%eax),%eax
  8008ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d0:	8d 40 04             	lea    0x4(%eax),%eax
  8008d3:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8008d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8008d9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008dd:	79 90                	jns    80086f <vprintfmt+0x39>
				width = precision, precision = -1;
  8008df:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008e5:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8008ec:	eb 81                	jmp    80086f <vprintfmt+0x39>
  8008ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008f1:	85 c0                	test   %eax,%eax
  8008f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8008f8:	0f 49 d0             	cmovns %eax,%edx
  8008fb:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8008fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800901:	e9 69 ff ff ff       	jmp    80086f <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800906:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800909:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800910:	e9 5a ff ff ff       	jmp    80086f <vprintfmt+0x39>
  800915:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800918:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80091b:	eb bc                	jmp    8008d9 <vprintfmt+0xa3>
			lflag++;
  80091d:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800920:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800923:	e9 47 ff ff ff       	jmp    80086f <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800928:	8b 45 14             	mov    0x14(%ebp),%eax
  80092b:	8d 78 04             	lea    0x4(%eax),%edi
  80092e:	83 ec 08             	sub    $0x8,%esp
  800931:	53                   	push   %ebx
  800932:	ff 30                	pushl  (%eax)
  800934:	ff d6                	call   *%esi
			break;
  800936:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800939:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80093c:	e9 9b 02 00 00       	jmp    800bdc <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800941:	8b 45 14             	mov    0x14(%ebp),%eax
  800944:	8d 78 04             	lea    0x4(%eax),%edi
  800947:	8b 00                	mov    (%eax),%eax
  800949:	99                   	cltd   
  80094a:	31 d0                	xor    %edx,%eax
  80094c:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80094e:	83 f8 08             	cmp    $0x8,%eax
  800951:	7f 23                	jg     800976 <vprintfmt+0x140>
  800953:	8b 14 85 a0 19 80 00 	mov    0x8019a0(,%eax,4),%edx
  80095a:	85 d2                	test   %edx,%edx
  80095c:	74 18                	je     800976 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80095e:	52                   	push   %edx
  80095f:	68 a4 17 80 00       	push   $0x8017a4
  800964:	53                   	push   %ebx
  800965:	56                   	push   %esi
  800966:	e8 aa fe ff ff       	call   800815 <printfmt>
  80096b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80096e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800971:	e9 66 02 00 00       	jmp    800bdc <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800976:	50                   	push   %eax
  800977:	68 9b 17 80 00       	push   $0x80179b
  80097c:	53                   	push   %ebx
  80097d:	56                   	push   %esi
  80097e:	e8 92 fe ff ff       	call   800815 <printfmt>
  800983:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800986:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800989:	e9 4e 02 00 00       	jmp    800bdc <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  80098e:	8b 45 14             	mov    0x14(%ebp),%eax
  800991:	83 c0 04             	add    $0x4,%eax
  800994:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800997:	8b 45 14             	mov    0x14(%ebp),%eax
  80099a:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80099c:	85 d2                	test   %edx,%edx
  80099e:	b8 94 17 80 00       	mov    $0x801794,%eax
  8009a3:	0f 45 c2             	cmovne %edx,%eax
  8009a6:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8009a9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009ad:	7e 06                	jle    8009b5 <vprintfmt+0x17f>
  8009af:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8009b3:	75 0d                	jne    8009c2 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009b5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8009b8:	89 c7                	mov    %eax,%edi
  8009ba:	03 45 e0             	add    -0x20(%ebp),%eax
  8009bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009c0:	eb 55                	jmp    800a17 <vprintfmt+0x1e1>
  8009c2:	83 ec 08             	sub    $0x8,%esp
  8009c5:	ff 75 d8             	pushl  -0x28(%ebp)
  8009c8:	ff 75 cc             	pushl  -0x34(%ebp)
  8009cb:	e8 46 03 00 00       	call   800d16 <strnlen>
  8009d0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8009d3:	29 c2                	sub    %eax,%edx
  8009d5:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8009d8:	83 c4 10             	add    $0x10,%esp
  8009db:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8009dd:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8009e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8009e4:	85 ff                	test   %edi,%edi
  8009e6:	7e 11                	jle    8009f9 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8009e8:	83 ec 08             	sub    $0x8,%esp
  8009eb:	53                   	push   %ebx
  8009ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8009ef:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8009f1:	83 ef 01             	sub    $0x1,%edi
  8009f4:	83 c4 10             	add    $0x10,%esp
  8009f7:	eb eb                	jmp    8009e4 <vprintfmt+0x1ae>
  8009f9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8009fc:	85 d2                	test   %edx,%edx
  8009fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800a03:	0f 49 c2             	cmovns %edx,%eax
  800a06:	29 c2                	sub    %eax,%edx
  800a08:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800a0b:	eb a8                	jmp    8009b5 <vprintfmt+0x17f>
					putch(ch, putdat);
  800a0d:	83 ec 08             	sub    $0x8,%esp
  800a10:	53                   	push   %ebx
  800a11:	52                   	push   %edx
  800a12:	ff d6                	call   *%esi
  800a14:	83 c4 10             	add    $0x10,%esp
  800a17:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a1a:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a1c:	83 c7 01             	add    $0x1,%edi
  800a1f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a23:	0f be d0             	movsbl %al,%edx
  800a26:	85 d2                	test   %edx,%edx
  800a28:	74 4b                	je     800a75 <vprintfmt+0x23f>
  800a2a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a2e:	78 06                	js     800a36 <vprintfmt+0x200>
  800a30:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800a34:	78 1e                	js     800a54 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800a36:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800a3a:	74 d1                	je     800a0d <vprintfmt+0x1d7>
  800a3c:	0f be c0             	movsbl %al,%eax
  800a3f:	83 e8 20             	sub    $0x20,%eax
  800a42:	83 f8 5e             	cmp    $0x5e,%eax
  800a45:	76 c6                	jbe    800a0d <vprintfmt+0x1d7>
					putch('?', putdat);
  800a47:	83 ec 08             	sub    $0x8,%esp
  800a4a:	53                   	push   %ebx
  800a4b:	6a 3f                	push   $0x3f
  800a4d:	ff d6                	call   *%esi
  800a4f:	83 c4 10             	add    $0x10,%esp
  800a52:	eb c3                	jmp    800a17 <vprintfmt+0x1e1>
  800a54:	89 cf                	mov    %ecx,%edi
  800a56:	eb 0e                	jmp    800a66 <vprintfmt+0x230>
				putch(' ', putdat);
  800a58:	83 ec 08             	sub    $0x8,%esp
  800a5b:	53                   	push   %ebx
  800a5c:	6a 20                	push   $0x20
  800a5e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800a60:	83 ef 01             	sub    $0x1,%edi
  800a63:	83 c4 10             	add    $0x10,%esp
  800a66:	85 ff                	test   %edi,%edi
  800a68:	7f ee                	jg     800a58 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800a6a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800a6d:	89 45 14             	mov    %eax,0x14(%ebp)
  800a70:	e9 67 01 00 00       	jmp    800bdc <vprintfmt+0x3a6>
  800a75:	89 cf                	mov    %ecx,%edi
  800a77:	eb ed                	jmp    800a66 <vprintfmt+0x230>
	if (lflag >= 2)
  800a79:	83 f9 01             	cmp    $0x1,%ecx
  800a7c:	7f 1b                	jg     800a99 <vprintfmt+0x263>
	else if (lflag)
  800a7e:	85 c9                	test   %ecx,%ecx
  800a80:	74 63                	je     800ae5 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800a82:	8b 45 14             	mov    0x14(%ebp),%eax
  800a85:	8b 00                	mov    (%eax),%eax
  800a87:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a8a:	99                   	cltd   
  800a8b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a8e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a91:	8d 40 04             	lea    0x4(%eax),%eax
  800a94:	89 45 14             	mov    %eax,0x14(%ebp)
  800a97:	eb 17                	jmp    800ab0 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800a99:	8b 45 14             	mov    0x14(%ebp),%eax
  800a9c:	8b 50 04             	mov    0x4(%eax),%edx
  800a9f:	8b 00                	mov    (%eax),%eax
  800aa1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aa4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800aa7:	8b 45 14             	mov    0x14(%ebp),%eax
  800aaa:	8d 40 08             	lea    0x8(%eax),%eax
  800aad:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800ab0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ab3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800ab6:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800abb:	85 c9                	test   %ecx,%ecx
  800abd:	0f 89 ff 00 00 00    	jns    800bc2 <vprintfmt+0x38c>
				putch('-', putdat);
  800ac3:	83 ec 08             	sub    $0x8,%esp
  800ac6:	53                   	push   %ebx
  800ac7:	6a 2d                	push   $0x2d
  800ac9:	ff d6                	call   *%esi
				num = -(long long) num;
  800acb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ace:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800ad1:	f7 da                	neg    %edx
  800ad3:	83 d1 00             	adc    $0x0,%ecx
  800ad6:	f7 d9                	neg    %ecx
  800ad8:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800adb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ae0:	e9 dd 00 00 00       	jmp    800bc2 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  800ae5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ae8:	8b 00                	mov    (%eax),%eax
  800aea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aed:	99                   	cltd   
  800aee:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800af1:	8b 45 14             	mov    0x14(%ebp),%eax
  800af4:	8d 40 04             	lea    0x4(%eax),%eax
  800af7:	89 45 14             	mov    %eax,0x14(%ebp)
  800afa:	eb b4                	jmp    800ab0 <vprintfmt+0x27a>
	if (lflag >= 2)
  800afc:	83 f9 01             	cmp    $0x1,%ecx
  800aff:	7f 1e                	jg     800b1f <vprintfmt+0x2e9>
	else if (lflag)
  800b01:	85 c9                	test   %ecx,%ecx
  800b03:	74 32                	je     800b37 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800b05:	8b 45 14             	mov    0x14(%ebp),%eax
  800b08:	8b 10                	mov    (%eax),%edx
  800b0a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b0f:	8d 40 04             	lea    0x4(%eax),%eax
  800b12:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b15:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800b1a:	e9 a3 00 00 00       	jmp    800bc2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800b1f:	8b 45 14             	mov    0x14(%ebp),%eax
  800b22:	8b 10                	mov    (%eax),%edx
  800b24:	8b 48 04             	mov    0x4(%eax),%ecx
  800b27:	8d 40 08             	lea    0x8(%eax),%eax
  800b2a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b2d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800b32:	e9 8b 00 00 00       	jmp    800bc2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800b37:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3a:	8b 10                	mov    (%eax),%edx
  800b3c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b41:	8d 40 04             	lea    0x4(%eax),%eax
  800b44:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b47:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800b4c:	eb 74                	jmp    800bc2 <vprintfmt+0x38c>
	if (lflag >= 2)
  800b4e:	83 f9 01             	cmp    $0x1,%ecx
  800b51:	7f 1b                	jg     800b6e <vprintfmt+0x338>
	else if (lflag)
  800b53:	85 c9                	test   %ecx,%ecx
  800b55:	74 2c                	je     800b83 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800b57:	8b 45 14             	mov    0x14(%ebp),%eax
  800b5a:	8b 10                	mov    (%eax),%edx
  800b5c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b61:	8d 40 04             	lea    0x4(%eax),%eax
  800b64:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800b67:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800b6c:	eb 54                	jmp    800bc2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800b6e:	8b 45 14             	mov    0x14(%ebp),%eax
  800b71:	8b 10                	mov    (%eax),%edx
  800b73:	8b 48 04             	mov    0x4(%eax),%ecx
  800b76:	8d 40 08             	lea    0x8(%eax),%eax
  800b79:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800b7c:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800b81:	eb 3f                	jmp    800bc2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800b83:	8b 45 14             	mov    0x14(%ebp),%eax
  800b86:	8b 10                	mov    (%eax),%edx
  800b88:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8d:	8d 40 04             	lea    0x4(%eax),%eax
  800b90:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800b93:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800b98:	eb 28                	jmp    800bc2 <vprintfmt+0x38c>
			putch('0', putdat);
  800b9a:	83 ec 08             	sub    $0x8,%esp
  800b9d:	53                   	push   %ebx
  800b9e:	6a 30                	push   $0x30
  800ba0:	ff d6                	call   *%esi
			putch('x', putdat);
  800ba2:	83 c4 08             	add    $0x8,%esp
  800ba5:	53                   	push   %ebx
  800ba6:	6a 78                	push   $0x78
  800ba8:	ff d6                	call   *%esi
			num = (unsigned long long)
  800baa:	8b 45 14             	mov    0x14(%ebp),%eax
  800bad:	8b 10                	mov    (%eax),%edx
  800baf:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800bb4:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800bb7:	8d 40 04             	lea    0x4(%eax),%eax
  800bba:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800bbd:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800bc2:	83 ec 0c             	sub    $0xc,%esp
  800bc5:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800bc9:	57                   	push   %edi
  800bca:	ff 75 e0             	pushl  -0x20(%ebp)
  800bcd:	50                   	push   %eax
  800bce:	51                   	push   %ecx
  800bcf:	52                   	push   %edx
  800bd0:	89 da                	mov    %ebx,%edx
  800bd2:	89 f0                	mov    %esi,%eax
  800bd4:	e8 72 fb ff ff       	call   80074b <printnum>
			break;
  800bd9:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800bdc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {	
  800bdf:	83 c7 01             	add    $0x1,%edi
  800be2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800be6:	83 f8 25             	cmp    $0x25,%eax
  800be9:	0f 84 62 fc ff ff    	je     800851 <vprintfmt+0x1b>
			if (ch == '\0')										
  800bef:	85 c0                	test   %eax,%eax
  800bf1:	0f 84 8b 00 00 00    	je     800c82 <vprintfmt+0x44c>
			putch(ch, putdat);
  800bf7:	83 ec 08             	sub    $0x8,%esp
  800bfa:	53                   	push   %ebx
  800bfb:	50                   	push   %eax
  800bfc:	ff d6                	call   *%esi
  800bfe:	83 c4 10             	add    $0x10,%esp
  800c01:	eb dc                	jmp    800bdf <vprintfmt+0x3a9>
	if (lflag >= 2)
  800c03:	83 f9 01             	cmp    $0x1,%ecx
  800c06:	7f 1b                	jg     800c23 <vprintfmt+0x3ed>
	else if (lflag)
  800c08:	85 c9                	test   %ecx,%ecx
  800c0a:	74 2c                	je     800c38 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800c0c:	8b 45 14             	mov    0x14(%ebp),%eax
  800c0f:	8b 10                	mov    (%eax),%edx
  800c11:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c16:	8d 40 04             	lea    0x4(%eax),%eax
  800c19:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c1c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800c21:	eb 9f                	jmp    800bc2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800c23:	8b 45 14             	mov    0x14(%ebp),%eax
  800c26:	8b 10                	mov    (%eax),%edx
  800c28:	8b 48 04             	mov    0x4(%eax),%ecx
  800c2b:	8d 40 08             	lea    0x8(%eax),%eax
  800c2e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c31:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800c36:	eb 8a                	jmp    800bc2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800c38:	8b 45 14             	mov    0x14(%ebp),%eax
  800c3b:	8b 10                	mov    (%eax),%edx
  800c3d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c42:	8d 40 04             	lea    0x4(%eax),%eax
  800c45:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c48:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800c4d:	e9 70 ff ff ff       	jmp    800bc2 <vprintfmt+0x38c>
			putch(ch, putdat);
  800c52:	83 ec 08             	sub    $0x8,%esp
  800c55:	53                   	push   %ebx
  800c56:	6a 25                	push   $0x25
  800c58:	ff d6                	call   *%esi
			break;
  800c5a:	83 c4 10             	add    $0x10,%esp
  800c5d:	e9 7a ff ff ff       	jmp    800bdc <vprintfmt+0x3a6>
			putch('%', putdat);
  800c62:	83 ec 08             	sub    $0x8,%esp
  800c65:	53                   	push   %ebx
  800c66:	6a 25                	push   $0x25
  800c68:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c6a:	83 c4 10             	add    $0x10,%esp
  800c6d:	89 f8                	mov    %edi,%eax
  800c6f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800c73:	74 05                	je     800c7a <vprintfmt+0x444>
  800c75:	83 e8 01             	sub    $0x1,%eax
  800c78:	eb f5                	jmp    800c6f <vprintfmt+0x439>
  800c7a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c7d:	e9 5a ff ff ff       	jmp    800bdc <vprintfmt+0x3a6>
}
  800c82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c8a:	f3 0f 1e fb          	endbr32 
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	83 ec 18             	sub    $0x18,%esp
  800c94:	8b 45 08             	mov    0x8(%ebp),%eax
  800c97:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c9a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c9d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ca1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ca4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800cab:	85 c0                	test   %eax,%eax
  800cad:	74 26                	je     800cd5 <vsnprintf+0x4b>
  800caf:	85 d2                	test   %edx,%edx
  800cb1:	7e 22                	jle    800cd5 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cb3:	ff 75 14             	pushl  0x14(%ebp)
  800cb6:	ff 75 10             	pushl  0x10(%ebp)
  800cb9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cbc:	50                   	push   %eax
  800cbd:	68 f4 07 80 00       	push   $0x8007f4
  800cc2:	e8 6f fb ff ff       	call   800836 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800cc7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cca:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cd0:	83 c4 10             	add    $0x10,%esp
}
  800cd3:	c9                   	leave  
  800cd4:	c3                   	ret    
		return -E_INVAL;
  800cd5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800cda:	eb f7                	jmp    800cd3 <vsnprintf+0x49>

00800cdc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800cdc:	f3 0f 1e fb          	endbr32 
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ce6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ce9:	50                   	push   %eax
  800cea:	ff 75 10             	pushl  0x10(%ebp)
  800ced:	ff 75 0c             	pushl  0xc(%ebp)
  800cf0:	ff 75 08             	pushl  0x8(%ebp)
  800cf3:	e8 92 ff ff ff       	call   800c8a <vsnprintf>
	va_end(ap);

	return rc;
}
  800cf8:	c9                   	leave  
  800cf9:	c3                   	ret    

00800cfa <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cfa:	f3 0f 1e fb          	endbr32 
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d04:	b8 00 00 00 00       	mov    $0x0,%eax
  800d09:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d0d:	74 05                	je     800d14 <strlen+0x1a>
		n++;
  800d0f:	83 c0 01             	add    $0x1,%eax
  800d12:	eb f5                	jmp    800d09 <strlen+0xf>
	return n;
}
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    

00800d16 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d16:	f3 0f 1e fb          	endbr32 
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d20:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d23:	b8 00 00 00 00       	mov    $0x0,%eax
  800d28:	39 d0                	cmp    %edx,%eax
  800d2a:	74 0d                	je     800d39 <strnlen+0x23>
  800d2c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800d30:	74 05                	je     800d37 <strnlen+0x21>
		n++;
  800d32:	83 c0 01             	add    $0x1,%eax
  800d35:	eb f1                	jmp    800d28 <strnlen+0x12>
  800d37:	89 c2                	mov    %eax,%edx
	return n;
}
  800d39:	89 d0                	mov    %edx,%eax
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d3d:	f3 0f 1e fb          	endbr32 
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	53                   	push   %ebx
  800d45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d48:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d50:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800d54:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800d57:	83 c0 01             	add    $0x1,%eax
  800d5a:	84 d2                	test   %dl,%dl
  800d5c:	75 f2                	jne    800d50 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800d5e:	89 c8                	mov    %ecx,%eax
  800d60:	5b                   	pop    %ebx
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    

00800d63 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d63:	f3 0f 1e fb          	endbr32 
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	53                   	push   %ebx
  800d6b:	83 ec 10             	sub    $0x10,%esp
  800d6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d71:	53                   	push   %ebx
  800d72:	e8 83 ff ff ff       	call   800cfa <strlen>
  800d77:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800d7a:	ff 75 0c             	pushl  0xc(%ebp)
  800d7d:	01 d8                	add    %ebx,%eax
  800d7f:	50                   	push   %eax
  800d80:	e8 b8 ff ff ff       	call   800d3d <strcpy>
	return dst;
}
  800d85:	89 d8                	mov    %ebx,%eax
  800d87:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d8a:	c9                   	leave  
  800d8b:	c3                   	ret    

00800d8c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d8c:	f3 0f 1e fb          	endbr32 
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	56                   	push   %esi
  800d94:	53                   	push   %ebx
  800d95:	8b 75 08             	mov    0x8(%ebp),%esi
  800d98:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d9b:	89 f3                	mov    %esi,%ebx
  800d9d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800da0:	89 f0                	mov    %esi,%eax
  800da2:	39 d8                	cmp    %ebx,%eax
  800da4:	74 11                	je     800db7 <strncpy+0x2b>
		*dst++ = *src;
  800da6:	83 c0 01             	add    $0x1,%eax
  800da9:	0f b6 0a             	movzbl (%edx),%ecx
  800dac:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800daf:	80 f9 01             	cmp    $0x1,%cl
  800db2:	83 da ff             	sbb    $0xffffffff,%edx
  800db5:	eb eb                	jmp    800da2 <strncpy+0x16>
	}
	return ret;
}
  800db7:	89 f0                	mov    %esi,%eax
  800db9:	5b                   	pop    %ebx
  800dba:	5e                   	pop    %esi
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    

00800dbd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800dbd:	f3 0f 1e fb          	endbr32 
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	56                   	push   %esi
  800dc5:	53                   	push   %ebx
  800dc6:	8b 75 08             	mov    0x8(%ebp),%esi
  800dc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcc:	8b 55 10             	mov    0x10(%ebp),%edx
  800dcf:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800dd1:	85 d2                	test   %edx,%edx
  800dd3:	74 21                	je     800df6 <strlcpy+0x39>
  800dd5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800dd9:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800ddb:	39 c2                	cmp    %eax,%edx
  800ddd:	74 14                	je     800df3 <strlcpy+0x36>
  800ddf:	0f b6 19             	movzbl (%ecx),%ebx
  800de2:	84 db                	test   %bl,%bl
  800de4:	74 0b                	je     800df1 <strlcpy+0x34>
			*dst++ = *src++;
  800de6:	83 c1 01             	add    $0x1,%ecx
  800de9:	83 c2 01             	add    $0x1,%edx
  800dec:	88 5a ff             	mov    %bl,-0x1(%edx)
  800def:	eb ea                	jmp    800ddb <strlcpy+0x1e>
  800df1:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800df3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800df6:	29 f0                	sub    %esi,%eax
}
  800df8:	5b                   	pop    %ebx
  800df9:	5e                   	pop    %esi
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    

00800dfc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800dfc:	f3 0f 1e fb          	endbr32 
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e06:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e09:	0f b6 01             	movzbl (%ecx),%eax
  800e0c:	84 c0                	test   %al,%al
  800e0e:	74 0c                	je     800e1c <strcmp+0x20>
  800e10:	3a 02                	cmp    (%edx),%al
  800e12:	75 08                	jne    800e1c <strcmp+0x20>
		p++, q++;
  800e14:	83 c1 01             	add    $0x1,%ecx
  800e17:	83 c2 01             	add    $0x1,%edx
  800e1a:	eb ed                	jmp    800e09 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e1c:	0f b6 c0             	movzbl %al,%eax
  800e1f:	0f b6 12             	movzbl (%edx),%edx
  800e22:	29 d0                	sub    %edx,%eax
}
  800e24:	5d                   	pop    %ebp
  800e25:	c3                   	ret    

00800e26 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e26:	f3 0f 1e fb          	endbr32 
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	53                   	push   %ebx
  800e2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e31:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e34:	89 c3                	mov    %eax,%ebx
  800e36:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e39:	eb 06                	jmp    800e41 <strncmp+0x1b>
		n--, p++, q++;
  800e3b:	83 c0 01             	add    $0x1,%eax
  800e3e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800e41:	39 d8                	cmp    %ebx,%eax
  800e43:	74 16                	je     800e5b <strncmp+0x35>
  800e45:	0f b6 08             	movzbl (%eax),%ecx
  800e48:	84 c9                	test   %cl,%cl
  800e4a:	74 04                	je     800e50 <strncmp+0x2a>
  800e4c:	3a 0a                	cmp    (%edx),%cl
  800e4e:	74 eb                	je     800e3b <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e50:	0f b6 00             	movzbl (%eax),%eax
  800e53:	0f b6 12             	movzbl (%edx),%edx
  800e56:	29 d0                	sub    %edx,%eax
}
  800e58:	5b                   	pop    %ebx
  800e59:	5d                   	pop    %ebp
  800e5a:	c3                   	ret    
		return 0;
  800e5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e60:	eb f6                	jmp    800e58 <strncmp+0x32>

00800e62 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e62:	f3 0f 1e fb          	endbr32 
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e70:	0f b6 10             	movzbl (%eax),%edx
  800e73:	84 d2                	test   %dl,%dl
  800e75:	74 09                	je     800e80 <strchr+0x1e>
		if (*s == c)
  800e77:	38 ca                	cmp    %cl,%dl
  800e79:	74 0a                	je     800e85 <strchr+0x23>
	for (; *s; s++)
  800e7b:	83 c0 01             	add    $0x1,%eax
  800e7e:	eb f0                	jmp    800e70 <strchr+0xe>
			return (char *) s;
	return 0;
  800e80:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e85:	5d                   	pop    %ebp
  800e86:	c3                   	ret    

00800e87 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e87:	f3 0f 1e fb          	endbr32 
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e91:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e95:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800e98:	38 ca                	cmp    %cl,%dl
  800e9a:	74 09                	je     800ea5 <strfind+0x1e>
  800e9c:	84 d2                	test   %dl,%dl
  800e9e:	74 05                	je     800ea5 <strfind+0x1e>
	for (; *s; s++)
  800ea0:	83 c0 01             	add    $0x1,%eax
  800ea3:	eb f0                	jmp    800e95 <strfind+0xe>
			break;
	return (char *) s;
}
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    

00800ea7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ea7:	f3 0f 1e fb          	endbr32 
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
  800eae:	57                   	push   %edi
  800eaf:	56                   	push   %esi
  800eb0:	53                   	push   %ebx
  800eb1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800eb4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800eb7:	85 c9                	test   %ecx,%ecx
  800eb9:	74 31                	je     800eec <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ebb:	89 f8                	mov    %edi,%eax
  800ebd:	09 c8                	or     %ecx,%eax
  800ebf:	a8 03                	test   $0x3,%al
  800ec1:	75 23                	jne    800ee6 <memset+0x3f>
		c &= 0xFF;
  800ec3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ec7:	89 d3                	mov    %edx,%ebx
  800ec9:	c1 e3 08             	shl    $0x8,%ebx
  800ecc:	89 d0                	mov    %edx,%eax
  800ece:	c1 e0 18             	shl    $0x18,%eax
  800ed1:	89 d6                	mov    %edx,%esi
  800ed3:	c1 e6 10             	shl    $0x10,%esi
  800ed6:	09 f0                	or     %esi,%eax
  800ed8:	09 c2                	or     %eax,%edx
  800eda:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800edc:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800edf:	89 d0                	mov    %edx,%eax
  800ee1:	fc                   	cld    
  800ee2:	f3 ab                	rep stos %eax,%es:(%edi)
  800ee4:	eb 06                	jmp    800eec <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ee6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee9:	fc                   	cld    
  800eea:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800eec:	89 f8                	mov    %edi,%eax
  800eee:	5b                   	pop    %ebx
  800eef:	5e                   	pop    %esi
  800ef0:	5f                   	pop    %edi
  800ef1:	5d                   	pop    %ebp
  800ef2:	c3                   	ret    

00800ef3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ef3:	f3 0f 1e fb          	endbr32 
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	57                   	push   %edi
  800efb:	56                   	push   %esi
  800efc:	8b 45 08             	mov    0x8(%ebp),%eax
  800eff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f02:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f05:	39 c6                	cmp    %eax,%esi
  800f07:	73 32                	jae    800f3b <memmove+0x48>
  800f09:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f0c:	39 c2                	cmp    %eax,%edx
  800f0e:	76 2b                	jbe    800f3b <memmove+0x48>
		s += n;
		d += n;
  800f10:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f13:	89 fe                	mov    %edi,%esi
  800f15:	09 ce                	or     %ecx,%esi
  800f17:	09 d6                	or     %edx,%esi
  800f19:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f1f:	75 0e                	jne    800f2f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f21:	83 ef 04             	sub    $0x4,%edi
  800f24:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f27:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800f2a:	fd                   	std    
  800f2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f2d:	eb 09                	jmp    800f38 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f2f:	83 ef 01             	sub    $0x1,%edi
  800f32:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800f35:	fd                   	std    
  800f36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f38:	fc                   	cld    
  800f39:	eb 1a                	jmp    800f55 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f3b:	89 c2                	mov    %eax,%edx
  800f3d:	09 ca                	or     %ecx,%edx
  800f3f:	09 f2                	or     %esi,%edx
  800f41:	f6 c2 03             	test   $0x3,%dl
  800f44:	75 0a                	jne    800f50 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f46:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800f49:	89 c7                	mov    %eax,%edi
  800f4b:	fc                   	cld    
  800f4c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f4e:	eb 05                	jmp    800f55 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800f50:	89 c7                	mov    %eax,%edi
  800f52:	fc                   	cld    
  800f53:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f55:	5e                   	pop    %esi
  800f56:	5f                   	pop    %edi
  800f57:	5d                   	pop    %ebp
  800f58:	c3                   	ret    

00800f59 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f59:	f3 0f 1e fb          	endbr32 
  800f5d:	55                   	push   %ebp
  800f5e:	89 e5                	mov    %esp,%ebp
  800f60:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f63:	ff 75 10             	pushl  0x10(%ebp)
  800f66:	ff 75 0c             	pushl  0xc(%ebp)
  800f69:	ff 75 08             	pushl  0x8(%ebp)
  800f6c:	e8 82 ff ff ff       	call   800ef3 <memmove>
}
  800f71:	c9                   	leave  
  800f72:	c3                   	ret    

00800f73 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f73:	f3 0f 1e fb          	endbr32 
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	56                   	push   %esi
  800f7b:	53                   	push   %ebx
  800f7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f82:	89 c6                	mov    %eax,%esi
  800f84:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f87:	39 f0                	cmp    %esi,%eax
  800f89:	74 1c                	je     800fa7 <memcmp+0x34>
		if (*s1 != *s2)
  800f8b:	0f b6 08             	movzbl (%eax),%ecx
  800f8e:	0f b6 1a             	movzbl (%edx),%ebx
  800f91:	38 d9                	cmp    %bl,%cl
  800f93:	75 08                	jne    800f9d <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800f95:	83 c0 01             	add    $0x1,%eax
  800f98:	83 c2 01             	add    $0x1,%edx
  800f9b:	eb ea                	jmp    800f87 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800f9d:	0f b6 c1             	movzbl %cl,%eax
  800fa0:	0f b6 db             	movzbl %bl,%ebx
  800fa3:	29 d8                	sub    %ebx,%eax
  800fa5:	eb 05                	jmp    800fac <memcmp+0x39>
	}

	return 0;
  800fa7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fac:	5b                   	pop    %ebx
  800fad:	5e                   	pop    %esi
  800fae:	5d                   	pop    %ebp
  800faf:	c3                   	ret    

00800fb0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fb0:	f3 0f 1e fb          	endbr32 
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800fba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800fbd:	89 c2                	mov    %eax,%edx
  800fbf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800fc2:	39 d0                	cmp    %edx,%eax
  800fc4:	73 09                	jae    800fcf <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fc6:	38 08                	cmp    %cl,(%eax)
  800fc8:	74 05                	je     800fcf <memfind+0x1f>
	for (; s < ends; s++)
  800fca:	83 c0 01             	add    $0x1,%eax
  800fcd:	eb f3                	jmp    800fc2 <memfind+0x12>
			break;
	return (void *) s;
}
  800fcf:	5d                   	pop    %ebp
  800fd0:	c3                   	ret    

00800fd1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800fd1:	f3 0f 1e fb          	endbr32 
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
  800fd8:	57                   	push   %edi
  800fd9:	56                   	push   %esi
  800fda:	53                   	push   %ebx
  800fdb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fde:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fe1:	eb 03                	jmp    800fe6 <strtol+0x15>
		s++;
  800fe3:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800fe6:	0f b6 01             	movzbl (%ecx),%eax
  800fe9:	3c 20                	cmp    $0x20,%al
  800feb:	74 f6                	je     800fe3 <strtol+0x12>
  800fed:	3c 09                	cmp    $0x9,%al
  800fef:	74 f2                	je     800fe3 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800ff1:	3c 2b                	cmp    $0x2b,%al
  800ff3:	74 2a                	je     80101f <strtol+0x4e>
	int neg = 0;
  800ff5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ffa:	3c 2d                	cmp    $0x2d,%al
  800ffc:	74 2b                	je     801029 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ffe:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801004:	75 0f                	jne    801015 <strtol+0x44>
  801006:	80 39 30             	cmpb   $0x30,(%ecx)
  801009:	74 28                	je     801033 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80100b:	85 db                	test   %ebx,%ebx
  80100d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801012:	0f 44 d8             	cmove  %eax,%ebx
  801015:	b8 00 00 00 00       	mov    $0x0,%eax
  80101a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80101d:	eb 46                	jmp    801065 <strtol+0x94>
		s++;
  80101f:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801022:	bf 00 00 00 00       	mov    $0x0,%edi
  801027:	eb d5                	jmp    800ffe <strtol+0x2d>
		s++, neg = 1;
  801029:	83 c1 01             	add    $0x1,%ecx
  80102c:	bf 01 00 00 00       	mov    $0x1,%edi
  801031:	eb cb                	jmp    800ffe <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801033:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801037:	74 0e                	je     801047 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801039:	85 db                	test   %ebx,%ebx
  80103b:	75 d8                	jne    801015 <strtol+0x44>
		s++, base = 8;
  80103d:	83 c1 01             	add    $0x1,%ecx
  801040:	bb 08 00 00 00       	mov    $0x8,%ebx
  801045:	eb ce                	jmp    801015 <strtol+0x44>
		s += 2, base = 16;
  801047:	83 c1 02             	add    $0x2,%ecx
  80104a:	bb 10 00 00 00       	mov    $0x10,%ebx
  80104f:	eb c4                	jmp    801015 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801051:	0f be d2             	movsbl %dl,%edx
  801054:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801057:	3b 55 10             	cmp    0x10(%ebp),%edx
  80105a:	7d 3a                	jge    801096 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  80105c:	83 c1 01             	add    $0x1,%ecx
  80105f:	0f af 45 10          	imul   0x10(%ebp),%eax
  801063:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801065:	0f b6 11             	movzbl (%ecx),%edx
  801068:	8d 72 d0             	lea    -0x30(%edx),%esi
  80106b:	89 f3                	mov    %esi,%ebx
  80106d:	80 fb 09             	cmp    $0x9,%bl
  801070:	76 df                	jbe    801051 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  801072:	8d 72 9f             	lea    -0x61(%edx),%esi
  801075:	89 f3                	mov    %esi,%ebx
  801077:	80 fb 19             	cmp    $0x19,%bl
  80107a:	77 08                	ja     801084 <strtol+0xb3>
			dig = *s - 'a' + 10;
  80107c:	0f be d2             	movsbl %dl,%edx
  80107f:	83 ea 57             	sub    $0x57,%edx
  801082:	eb d3                	jmp    801057 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801084:	8d 72 bf             	lea    -0x41(%edx),%esi
  801087:	89 f3                	mov    %esi,%ebx
  801089:	80 fb 19             	cmp    $0x19,%bl
  80108c:	77 08                	ja     801096 <strtol+0xc5>
			dig = *s - 'A' + 10;
  80108e:	0f be d2             	movsbl %dl,%edx
  801091:	83 ea 37             	sub    $0x37,%edx
  801094:	eb c1                	jmp    801057 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801096:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80109a:	74 05                	je     8010a1 <strtol+0xd0>
		*endptr = (char *) s;
  80109c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80109f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8010a1:	89 c2                	mov    %eax,%edx
  8010a3:	f7 da                	neg    %edx
  8010a5:	85 ff                	test   %edi,%edi
  8010a7:	0f 45 c2             	cmovne %edx,%eax
}
  8010aa:	5b                   	pop    %ebx
  8010ab:	5e                   	pop    %esi
  8010ac:	5f                   	pop    %edi
  8010ad:	5d                   	pop    %ebp
  8010ae:	c3                   	ret    

008010af <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010af:	f3 0f 1e fb          	endbr32 
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
  8010b6:	57                   	push   %edi
  8010b7:	56                   	push   %esi
  8010b8:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8010b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8010be:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c4:	89 c3                	mov    %eax,%ebx
  8010c6:	89 c7                	mov    %eax,%edi
  8010c8:	89 c6                	mov    %eax,%esi
  8010ca:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8010cc:	5b                   	pop    %ebx
  8010cd:	5e                   	pop    %esi
  8010ce:	5f                   	pop    %edi
  8010cf:	5d                   	pop    %ebp
  8010d0:	c3                   	ret    

008010d1 <sys_cgetc>:

int
sys_cgetc(void)
{
  8010d1:	f3 0f 1e fb          	endbr32 
  8010d5:	55                   	push   %ebp
  8010d6:	89 e5                	mov    %esp,%ebp
  8010d8:	57                   	push   %edi
  8010d9:	56                   	push   %esi
  8010da:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8010db:	ba 00 00 00 00       	mov    $0x0,%edx
  8010e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8010e5:	89 d1                	mov    %edx,%ecx
  8010e7:	89 d3                	mov    %edx,%ebx
  8010e9:	89 d7                	mov    %edx,%edi
  8010eb:	89 d6                	mov    %edx,%esi
  8010ed:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8010ef:	5b                   	pop    %ebx
  8010f0:	5e                   	pop    %esi
  8010f1:	5f                   	pop    %edi
  8010f2:	5d                   	pop    %ebp
  8010f3:	c3                   	ret    

008010f4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8010f4:	f3 0f 1e fb          	endbr32 
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
  8010fb:	57                   	push   %edi
  8010fc:	56                   	push   %esi
  8010fd:	53                   	push   %ebx
  8010fe:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  801101:	b9 00 00 00 00       	mov    $0x0,%ecx
  801106:	8b 55 08             	mov    0x8(%ebp),%edx
  801109:	b8 03 00 00 00       	mov    $0x3,%eax
  80110e:	89 cb                	mov    %ecx,%ebx
  801110:	89 cf                	mov    %ecx,%edi
  801112:	89 ce                	mov    %ecx,%esi
  801114:	cd 30                	int    $0x30
	if(check && ret > 0)
  801116:	85 c0                	test   %eax,%eax
  801118:	7f 08                	jg     801122 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80111a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111d:	5b                   	pop    %ebx
  80111e:	5e                   	pop    %esi
  80111f:	5f                   	pop    %edi
  801120:	5d                   	pop    %ebp
  801121:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801122:	83 ec 0c             	sub    $0xc,%esp
  801125:	50                   	push   %eax
  801126:	6a 03                	push   $0x3
  801128:	68 c4 19 80 00       	push   $0x8019c4
  80112d:	6a 23                	push   $0x23
  80112f:	68 e1 19 80 00       	push   $0x8019e1
  801134:	e8 13 f5 ff ff       	call   80064c <_panic>

00801139 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801139:	f3 0f 1e fb          	endbr32 
  80113d:	55                   	push   %ebp
  80113e:	89 e5                	mov    %esp,%ebp
  801140:	57                   	push   %edi
  801141:	56                   	push   %esi
  801142:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  801143:	ba 00 00 00 00       	mov    $0x0,%edx
  801148:	b8 02 00 00 00       	mov    $0x2,%eax
  80114d:	89 d1                	mov    %edx,%ecx
  80114f:	89 d3                	mov    %edx,%ebx
  801151:	89 d7                	mov    %edx,%edi
  801153:	89 d6                	mov    %edx,%esi
  801155:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801157:	5b                   	pop    %ebx
  801158:	5e                   	pop    %esi
  801159:	5f                   	pop    %edi
  80115a:	5d                   	pop    %ebp
  80115b:	c3                   	ret    

0080115c <sys_yield>:

void
sys_yield(void)
{
  80115c:	f3 0f 1e fb          	endbr32 
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
  801163:	57                   	push   %edi
  801164:	56                   	push   %esi
  801165:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  801166:	ba 00 00 00 00       	mov    $0x0,%edx
  80116b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801170:	89 d1                	mov    %edx,%ecx
  801172:	89 d3                	mov    %edx,%ebx
  801174:	89 d7                	mov    %edx,%edi
  801176:	89 d6                	mov    %edx,%esi
  801178:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80117a:	5b                   	pop    %ebx
  80117b:	5e                   	pop    %esi
  80117c:	5f                   	pop    %edi
  80117d:	5d                   	pop    %ebp
  80117e:	c3                   	ret    

0080117f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80117f:	f3 0f 1e fb          	endbr32 
  801183:	55                   	push   %ebp
  801184:	89 e5                	mov    %esp,%ebp
  801186:	57                   	push   %edi
  801187:	56                   	push   %esi
  801188:	53                   	push   %ebx
  801189:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  80118c:	be 00 00 00 00       	mov    $0x0,%esi
  801191:	8b 55 08             	mov    0x8(%ebp),%edx
  801194:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801197:	b8 04 00 00 00       	mov    $0x4,%eax
  80119c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80119f:	89 f7                	mov    %esi,%edi
  8011a1:	cd 30                	int    $0x30
	if(check && ret > 0)
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	7f 08                	jg     8011af <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8011a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011aa:	5b                   	pop    %ebx
  8011ab:	5e                   	pop    %esi
  8011ac:	5f                   	pop    %edi
  8011ad:	5d                   	pop    %ebp
  8011ae:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8011af:	83 ec 0c             	sub    $0xc,%esp
  8011b2:	50                   	push   %eax
  8011b3:	6a 04                	push   $0x4
  8011b5:	68 c4 19 80 00       	push   $0x8019c4
  8011ba:	6a 23                	push   $0x23
  8011bc:	68 e1 19 80 00       	push   $0x8019e1
  8011c1:	e8 86 f4 ff ff       	call   80064c <_panic>

008011c6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8011c6:	f3 0f 1e fb          	endbr32 
  8011ca:	55                   	push   %ebp
  8011cb:	89 e5                	mov    %esp,%ebp
  8011cd:	57                   	push   %edi
  8011ce:	56                   	push   %esi
  8011cf:	53                   	push   %ebx
  8011d0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8011d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d9:	b8 05 00 00 00       	mov    $0x5,%eax
  8011de:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011e1:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011e4:	8b 75 18             	mov    0x18(%ebp),%esi
  8011e7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8011e9:	85 c0                	test   %eax,%eax
  8011eb:	7f 08                	jg     8011f5 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8011ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f0:	5b                   	pop    %ebx
  8011f1:	5e                   	pop    %esi
  8011f2:	5f                   	pop    %edi
  8011f3:	5d                   	pop    %ebp
  8011f4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8011f5:	83 ec 0c             	sub    $0xc,%esp
  8011f8:	50                   	push   %eax
  8011f9:	6a 05                	push   $0x5
  8011fb:	68 c4 19 80 00       	push   $0x8019c4
  801200:	6a 23                	push   $0x23
  801202:	68 e1 19 80 00       	push   $0x8019e1
  801207:	e8 40 f4 ff ff       	call   80064c <_panic>

0080120c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80120c:	f3 0f 1e fb          	endbr32 
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	57                   	push   %edi
  801214:	56                   	push   %esi
  801215:	53                   	push   %ebx
  801216:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  801219:	bb 00 00 00 00       	mov    $0x0,%ebx
  80121e:	8b 55 08             	mov    0x8(%ebp),%edx
  801221:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801224:	b8 06 00 00 00       	mov    $0x6,%eax
  801229:	89 df                	mov    %ebx,%edi
  80122b:	89 de                	mov    %ebx,%esi
  80122d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80122f:	85 c0                	test   %eax,%eax
  801231:	7f 08                	jg     80123b <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801233:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801236:	5b                   	pop    %ebx
  801237:	5e                   	pop    %esi
  801238:	5f                   	pop    %edi
  801239:	5d                   	pop    %ebp
  80123a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80123b:	83 ec 0c             	sub    $0xc,%esp
  80123e:	50                   	push   %eax
  80123f:	6a 06                	push   $0x6
  801241:	68 c4 19 80 00       	push   $0x8019c4
  801246:	6a 23                	push   $0x23
  801248:	68 e1 19 80 00       	push   $0x8019e1
  80124d:	e8 fa f3 ff ff       	call   80064c <_panic>

00801252 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801252:	f3 0f 1e fb          	endbr32 
  801256:	55                   	push   %ebp
  801257:	89 e5                	mov    %esp,%ebp
  801259:	57                   	push   %edi
  80125a:	56                   	push   %esi
  80125b:	53                   	push   %ebx
  80125c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  80125f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801264:	8b 55 08             	mov    0x8(%ebp),%edx
  801267:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80126a:	b8 08 00 00 00       	mov    $0x8,%eax
  80126f:	89 df                	mov    %ebx,%edi
  801271:	89 de                	mov    %ebx,%esi
  801273:	cd 30                	int    $0x30
	if(check && ret > 0)
  801275:	85 c0                	test   %eax,%eax
  801277:	7f 08                	jg     801281 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801279:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80127c:	5b                   	pop    %ebx
  80127d:	5e                   	pop    %esi
  80127e:	5f                   	pop    %edi
  80127f:	5d                   	pop    %ebp
  801280:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801281:	83 ec 0c             	sub    $0xc,%esp
  801284:	50                   	push   %eax
  801285:	6a 08                	push   $0x8
  801287:	68 c4 19 80 00       	push   $0x8019c4
  80128c:	6a 23                	push   $0x23
  80128e:	68 e1 19 80 00       	push   $0x8019e1
  801293:	e8 b4 f3 ff ff       	call   80064c <_panic>

00801298 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801298:	f3 0f 1e fb          	endbr32 
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	57                   	push   %edi
  8012a0:	56                   	push   %esi
  8012a1:	53                   	push   %ebx
  8012a2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8012a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012b0:	b8 09 00 00 00       	mov    $0x9,%eax
  8012b5:	89 df                	mov    %ebx,%edi
  8012b7:	89 de                	mov    %ebx,%esi
  8012b9:	cd 30                	int    $0x30
	if(check && ret > 0)
  8012bb:	85 c0                	test   %eax,%eax
  8012bd:	7f 08                	jg     8012c7 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8012bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c2:	5b                   	pop    %ebx
  8012c3:	5e                   	pop    %esi
  8012c4:	5f                   	pop    %edi
  8012c5:	5d                   	pop    %ebp
  8012c6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8012c7:	83 ec 0c             	sub    $0xc,%esp
  8012ca:	50                   	push   %eax
  8012cb:	6a 09                	push   $0x9
  8012cd:	68 c4 19 80 00       	push   $0x8019c4
  8012d2:	6a 23                	push   $0x23
  8012d4:	68 e1 19 80 00       	push   $0x8019e1
  8012d9:	e8 6e f3 ff ff       	call   80064c <_panic>

008012de <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8012de:	f3 0f 1e fb          	endbr32 
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	57                   	push   %edi
  8012e6:	56                   	push   %esi
  8012e7:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8012e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8012eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ee:	b8 0b 00 00 00       	mov    $0xb,%eax
  8012f3:	be 00 00 00 00       	mov    $0x0,%esi
  8012f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012fb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012fe:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801300:	5b                   	pop    %ebx
  801301:	5e                   	pop    %esi
  801302:	5f                   	pop    %edi
  801303:	5d                   	pop    %ebp
  801304:	c3                   	ret    

00801305 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801305:	f3 0f 1e fb          	endbr32 
  801309:	55                   	push   %ebp
  80130a:	89 e5                	mov    %esp,%ebp
  80130c:	57                   	push   %edi
  80130d:	56                   	push   %esi
  80130e:	53                   	push   %ebx
  80130f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  801312:	b9 00 00 00 00       	mov    $0x0,%ecx
  801317:	8b 55 08             	mov    0x8(%ebp),%edx
  80131a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80131f:	89 cb                	mov    %ecx,%ebx
  801321:	89 cf                	mov    %ecx,%edi
  801323:	89 ce                	mov    %ecx,%esi
  801325:	cd 30                	int    $0x30
	if(check && ret > 0)
  801327:	85 c0                	test   %eax,%eax
  801329:	7f 08                	jg     801333 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80132b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80132e:	5b                   	pop    %ebx
  80132f:	5e                   	pop    %esi
  801330:	5f                   	pop    %edi
  801331:	5d                   	pop    %ebp
  801332:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801333:	83 ec 0c             	sub    $0xc,%esp
  801336:	50                   	push   %eax
  801337:	6a 0c                	push   $0xc
  801339:	68 c4 19 80 00       	push   $0x8019c4
  80133e:	6a 23                	push   $0x23
  801340:	68 e1 19 80 00       	push   $0x8019e1
  801345:	e8 02 f3 ff ff       	call   80064c <_panic>

0080134a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80134a:	f3 0f 1e fb          	endbr32 
  80134e:	55                   	push   %ebp
  80134f:	89 e5                	mov    %esp,%ebp
  801351:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801354:	83 3d 24 41 80 00 00 	cmpl   $0x0,0x804124
  80135b:	74 0a                	je     801367 <set_pgfault_handler+0x1d>
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);		//系统调用，设置进程的env_pgfault_upcall属性
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80135d:	8b 45 08             	mov    0x8(%ebp),%eax
  801360:	a3 24 41 80 00       	mov    %eax,0x804124
}
  801365:	c9                   	leave  
  801366:	c3                   	ret    
		int r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_W | PTE_U | PTE_P);	//为当前进程分配异常栈
  801367:	83 ec 04             	sub    $0x4,%esp
  80136a:	6a 07                	push   $0x7
  80136c:	68 00 f0 bf ee       	push   $0xeebff000
  801371:	6a 00                	push   $0x0
  801373:	e8 07 fe ff ff       	call   80117f <sys_page_alloc>
		if (r < 0) {
  801378:	83 c4 10             	add    $0x10,%esp
  80137b:	85 c0                	test   %eax,%eax
  80137d:	78 14                	js     801393 <set_pgfault_handler+0x49>
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);		//系统调用，设置进程的env_pgfault_upcall属性
  80137f:	83 ec 08             	sub    $0x8,%esp
  801382:	68 a7 13 80 00       	push   $0x8013a7
  801387:	6a 00                	push   $0x0
  801389:	e8 0a ff ff ff       	call   801298 <sys_env_set_pgfault_upcall>
  80138e:	83 c4 10             	add    $0x10,%esp
  801391:	eb ca                	jmp    80135d <set_pgfault_handler+0x13>
			panic("set_pgfault_handler:sys_page_alloc failed");;
  801393:	83 ec 04             	sub    $0x4,%esp
  801396:	68 f0 19 80 00       	push   $0x8019f0
  80139b:	6a 22                	push   $0x22
  80139d:	68 1a 1a 80 00       	push   $0x801a1a
  8013a2:	e8 a5 f2 ff ff       	call   80064c <_panic>

008013a7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8013a7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8013a8:	a1 24 41 80 00       	mov    0x804124,%eax
	call *%eax				
  8013ad:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8013af:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp			
  8013b2:	83 c4 08             	add    $0x8,%esp
	movl 40(%esp), %eax 	
  8013b5:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 32(%esp), %ecx 	
  8013b9:	8b 4c 24 20          	mov    0x20(%esp),%ecx
	movl %ecx, -4(%eax) 	
  8013bd:	89 48 fc             	mov    %ecx,-0x4(%eax)
	popal
  8013c0:	61                   	popa   
	addl $4, %esp		
  8013c1:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popfl
  8013c4:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8013c5:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	lea -4(%esp), %esp	
  8013c6:	8d 64 24 fc          	lea    -0x4(%esp),%esp
	ret
  8013ca:	c3                   	ret    
  8013cb:	66 90                	xchg   %ax,%ax
  8013cd:	66 90                	xchg   %ax,%ax
  8013cf:	90                   	nop

008013d0 <__udivdi3>:
  8013d0:	f3 0f 1e fb          	endbr32 
  8013d4:	55                   	push   %ebp
  8013d5:	57                   	push   %edi
  8013d6:	56                   	push   %esi
  8013d7:	53                   	push   %ebx
  8013d8:	83 ec 1c             	sub    $0x1c,%esp
  8013db:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8013df:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8013e3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8013e7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8013eb:	85 d2                	test   %edx,%edx
  8013ed:	75 19                	jne    801408 <__udivdi3+0x38>
  8013ef:	39 f3                	cmp    %esi,%ebx
  8013f1:	76 4d                	jbe    801440 <__udivdi3+0x70>
  8013f3:	31 ff                	xor    %edi,%edi
  8013f5:	89 e8                	mov    %ebp,%eax
  8013f7:	89 f2                	mov    %esi,%edx
  8013f9:	f7 f3                	div    %ebx
  8013fb:	89 fa                	mov    %edi,%edx
  8013fd:	83 c4 1c             	add    $0x1c,%esp
  801400:	5b                   	pop    %ebx
  801401:	5e                   	pop    %esi
  801402:	5f                   	pop    %edi
  801403:	5d                   	pop    %ebp
  801404:	c3                   	ret    
  801405:	8d 76 00             	lea    0x0(%esi),%esi
  801408:	39 f2                	cmp    %esi,%edx
  80140a:	76 14                	jbe    801420 <__udivdi3+0x50>
  80140c:	31 ff                	xor    %edi,%edi
  80140e:	31 c0                	xor    %eax,%eax
  801410:	89 fa                	mov    %edi,%edx
  801412:	83 c4 1c             	add    $0x1c,%esp
  801415:	5b                   	pop    %ebx
  801416:	5e                   	pop    %esi
  801417:	5f                   	pop    %edi
  801418:	5d                   	pop    %ebp
  801419:	c3                   	ret    
  80141a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801420:	0f bd fa             	bsr    %edx,%edi
  801423:	83 f7 1f             	xor    $0x1f,%edi
  801426:	75 48                	jne    801470 <__udivdi3+0xa0>
  801428:	39 f2                	cmp    %esi,%edx
  80142a:	72 06                	jb     801432 <__udivdi3+0x62>
  80142c:	31 c0                	xor    %eax,%eax
  80142e:	39 eb                	cmp    %ebp,%ebx
  801430:	77 de                	ja     801410 <__udivdi3+0x40>
  801432:	b8 01 00 00 00       	mov    $0x1,%eax
  801437:	eb d7                	jmp    801410 <__udivdi3+0x40>
  801439:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801440:	89 d9                	mov    %ebx,%ecx
  801442:	85 db                	test   %ebx,%ebx
  801444:	75 0b                	jne    801451 <__udivdi3+0x81>
  801446:	b8 01 00 00 00       	mov    $0x1,%eax
  80144b:	31 d2                	xor    %edx,%edx
  80144d:	f7 f3                	div    %ebx
  80144f:	89 c1                	mov    %eax,%ecx
  801451:	31 d2                	xor    %edx,%edx
  801453:	89 f0                	mov    %esi,%eax
  801455:	f7 f1                	div    %ecx
  801457:	89 c6                	mov    %eax,%esi
  801459:	89 e8                	mov    %ebp,%eax
  80145b:	89 f7                	mov    %esi,%edi
  80145d:	f7 f1                	div    %ecx
  80145f:	89 fa                	mov    %edi,%edx
  801461:	83 c4 1c             	add    $0x1c,%esp
  801464:	5b                   	pop    %ebx
  801465:	5e                   	pop    %esi
  801466:	5f                   	pop    %edi
  801467:	5d                   	pop    %ebp
  801468:	c3                   	ret    
  801469:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801470:	89 f9                	mov    %edi,%ecx
  801472:	b8 20 00 00 00       	mov    $0x20,%eax
  801477:	29 f8                	sub    %edi,%eax
  801479:	d3 e2                	shl    %cl,%edx
  80147b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80147f:	89 c1                	mov    %eax,%ecx
  801481:	89 da                	mov    %ebx,%edx
  801483:	d3 ea                	shr    %cl,%edx
  801485:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801489:	09 d1                	or     %edx,%ecx
  80148b:	89 f2                	mov    %esi,%edx
  80148d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801491:	89 f9                	mov    %edi,%ecx
  801493:	d3 e3                	shl    %cl,%ebx
  801495:	89 c1                	mov    %eax,%ecx
  801497:	d3 ea                	shr    %cl,%edx
  801499:	89 f9                	mov    %edi,%ecx
  80149b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80149f:	89 eb                	mov    %ebp,%ebx
  8014a1:	d3 e6                	shl    %cl,%esi
  8014a3:	89 c1                	mov    %eax,%ecx
  8014a5:	d3 eb                	shr    %cl,%ebx
  8014a7:	09 de                	or     %ebx,%esi
  8014a9:	89 f0                	mov    %esi,%eax
  8014ab:	f7 74 24 08          	divl   0x8(%esp)
  8014af:	89 d6                	mov    %edx,%esi
  8014b1:	89 c3                	mov    %eax,%ebx
  8014b3:	f7 64 24 0c          	mull   0xc(%esp)
  8014b7:	39 d6                	cmp    %edx,%esi
  8014b9:	72 15                	jb     8014d0 <__udivdi3+0x100>
  8014bb:	89 f9                	mov    %edi,%ecx
  8014bd:	d3 e5                	shl    %cl,%ebp
  8014bf:	39 c5                	cmp    %eax,%ebp
  8014c1:	73 04                	jae    8014c7 <__udivdi3+0xf7>
  8014c3:	39 d6                	cmp    %edx,%esi
  8014c5:	74 09                	je     8014d0 <__udivdi3+0x100>
  8014c7:	89 d8                	mov    %ebx,%eax
  8014c9:	31 ff                	xor    %edi,%edi
  8014cb:	e9 40 ff ff ff       	jmp    801410 <__udivdi3+0x40>
  8014d0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8014d3:	31 ff                	xor    %edi,%edi
  8014d5:	e9 36 ff ff ff       	jmp    801410 <__udivdi3+0x40>
  8014da:	66 90                	xchg   %ax,%ax
  8014dc:	66 90                	xchg   %ax,%ax
  8014de:	66 90                	xchg   %ax,%ax

008014e0 <__umoddi3>:
  8014e0:	f3 0f 1e fb          	endbr32 
  8014e4:	55                   	push   %ebp
  8014e5:	57                   	push   %edi
  8014e6:	56                   	push   %esi
  8014e7:	53                   	push   %ebx
  8014e8:	83 ec 1c             	sub    $0x1c,%esp
  8014eb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8014ef:	8b 74 24 30          	mov    0x30(%esp),%esi
  8014f3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8014f7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	75 19                	jne    801518 <__umoddi3+0x38>
  8014ff:	39 df                	cmp    %ebx,%edi
  801501:	76 5d                	jbe    801560 <__umoddi3+0x80>
  801503:	89 f0                	mov    %esi,%eax
  801505:	89 da                	mov    %ebx,%edx
  801507:	f7 f7                	div    %edi
  801509:	89 d0                	mov    %edx,%eax
  80150b:	31 d2                	xor    %edx,%edx
  80150d:	83 c4 1c             	add    $0x1c,%esp
  801510:	5b                   	pop    %ebx
  801511:	5e                   	pop    %esi
  801512:	5f                   	pop    %edi
  801513:	5d                   	pop    %ebp
  801514:	c3                   	ret    
  801515:	8d 76 00             	lea    0x0(%esi),%esi
  801518:	89 f2                	mov    %esi,%edx
  80151a:	39 d8                	cmp    %ebx,%eax
  80151c:	76 12                	jbe    801530 <__umoddi3+0x50>
  80151e:	89 f0                	mov    %esi,%eax
  801520:	89 da                	mov    %ebx,%edx
  801522:	83 c4 1c             	add    $0x1c,%esp
  801525:	5b                   	pop    %ebx
  801526:	5e                   	pop    %esi
  801527:	5f                   	pop    %edi
  801528:	5d                   	pop    %ebp
  801529:	c3                   	ret    
  80152a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801530:	0f bd e8             	bsr    %eax,%ebp
  801533:	83 f5 1f             	xor    $0x1f,%ebp
  801536:	75 50                	jne    801588 <__umoddi3+0xa8>
  801538:	39 d8                	cmp    %ebx,%eax
  80153a:	0f 82 e0 00 00 00    	jb     801620 <__umoddi3+0x140>
  801540:	89 d9                	mov    %ebx,%ecx
  801542:	39 f7                	cmp    %esi,%edi
  801544:	0f 86 d6 00 00 00    	jbe    801620 <__umoddi3+0x140>
  80154a:	89 d0                	mov    %edx,%eax
  80154c:	89 ca                	mov    %ecx,%edx
  80154e:	83 c4 1c             	add    $0x1c,%esp
  801551:	5b                   	pop    %ebx
  801552:	5e                   	pop    %esi
  801553:	5f                   	pop    %edi
  801554:	5d                   	pop    %ebp
  801555:	c3                   	ret    
  801556:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80155d:	8d 76 00             	lea    0x0(%esi),%esi
  801560:	89 fd                	mov    %edi,%ebp
  801562:	85 ff                	test   %edi,%edi
  801564:	75 0b                	jne    801571 <__umoddi3+0x91>
  801566:	b8 01 00 00 00       	mov    $0x1,%eax
  80156b:	31 d2                	xor    %edx,%edx
  80156d:	f7 f7                	div    %edi
  80156f:	89 c5                	mov    %eax,%ebp
  801571:	89 d8                	mov    %ebx,%eax
  801573:	31 d2                	xor    %edx,%edx
  801575:	f7 f5                	div    %ebp
  801577:	89 f0                	mov    %esi,%eax
  801579:	f7 f5                	div    %ebp
  80157b:	89 d0                	mov    %edx,%eax
  80157d:	31 d2                	xor    %edx,%edx
  80157f:	eb 8c                	jmp    80150d <__umoddi3+0x2d>
  801581:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801588:	89 e9                	mov    %ebp,%ecx
  80158a:	ba 20 00 00 00       	mov    $0x20,%edx
  80158f:	29 ea                	sub    %ebp,%edx
  801591:	d3 e0                	shl    %cl,%eax
  801593:	89 44 24 08          	mov    %eax,0x8(%esp)
  801597:	89 d1                	mov    %edx,%ecx
  801599:	89 f8                	mov    %edi,%eax
  80159b:	d3 e8                	shr    %cl,%eax
  80159d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8015a1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015a5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8015a9:	09 c1                	or     %eax,%ecx
  8015ab:	89 d8                	mov    %ebx,%eax
  8015ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015b1:	89 e9                	mov    %ebp,%ecx
  8015b3:	d3 e7                	shl    %cl,%edi
  8015b5:	89 d1                	mov    %edx,%ecx
  8015b7:	d3 e8                	shr    %cl,%eax
  8015b9:	89 e9                	mov    %ebp,%ecx
  8015bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8015bf:	d3 e3                	shl    %cl,%ebx
  8015c1:	89 c7                	mov    %eax,%edi
  8015c3:	89 d1                	mov    %edx,%ecx
  8015c5:	89 f0                	mov    %esi,%eax
  8015c7:	d3 e8                	shr    %cl,%eax
  8015c9:	89 e9                	mov    %ebp,%ecx
  8015cb:	89 fa                	mov    %edi,%edx
  8015cd:	d3 e6                	shl    %cl,%esi
  8015cf:	09 d8                	or     %ebx,%eax
  8015d1:	f7 74 24 08          	divl   0x8(%esp)
  8015d5:	89 d1                	mov    %edx,%ecx
  8015d7:	89 f3                	mov    %esi,%ebx
  8015d9:	f7 64 24 0c          	mull   0xc(%esp)
  8015dd:	89 c6                	mov    %eax,%esi
  8015df:	89 d7                	mov    %edx,%edi
  8015e1:	39 d1                	cmp    %edx,%ecx
  8015e3:	72 06                	jb     8015eb <__umoddi3+0x10b>
  8015e5:	75 10                	jne    8015f7 <__umoddi3+0x117>
  8015e7:	39 c3                	cmp    %eax,%ebx
  8015e9:	73 0c                	jae    8015f7 <__umoddi3+0x117>
  8015eb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8015ef:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8015f3:	89 d7                	mov    %edx,%edi
  8015f5:	89 c6                	mov    %eax,%esi
  8015f7:	89 ca                	mov    %ecx,%edx
  8015f9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8015fe:	29 f3                	sub    %esi,%ebx
  801600:	19 fa                	sbb    %edi,%edx
  801602:	89 d0                	mov    %edx,%eax
  801604:	d3 e0                	shl    %cl,%eax
  801606:	89 e9                	mov    %ebp,%ecx
  801608:	d3 eb                	shr    %cl,%ebx
  80160a:	d3 ea                	shr    %cl,%edx
  80160c:	09 d8                	or     %ebx,%eax
  80160e:	83 c4 1c             	add    $0x1c,%esp
  801611:	5b                   	pop    %ebx
  801612:	5e                   	pop    %esi
  801613:	5f                   	pop    %edi
  801614:	5d                   	pop    %ebp
  801615:	c3                   	ret    
  801616:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80161d:	8d 76 00             	lea    0x0(%esi),%esi
  801620:	29 fe                	sub    %edi,%esi
  801622:	19 c3                	sbb    %eax,%ebx
  801624:	89 f2                	mov    %esi,%edx
  801626:	89 d9                	mov    %ebx,%ecx
  801628:	e9 1d ff ff ff       	jmp    80154a <__umoddi3+0x6a>
