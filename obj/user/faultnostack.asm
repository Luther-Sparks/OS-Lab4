
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 27 00 00 00       	call   800058 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003d:	68 56 03 80 00       	push   $0x800356
  800042:	6a 00                	push   $0x0
  800044:	e8 5b 02 00 00       	call   8002a4 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800049:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800050:	00 00 00 
}
  800053:	83 c4 10             	add    $0x10,%esp
  800056:	c9                   	leave  
  800057:	c3                   	ret    

00800058 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800058:	f3 0f 1e fb          	endbr32 
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	56                   	push   %esi
  800060:	53                   	push   %ebx
  800061:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800064:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800067:	e8 d9 00 00 00       	call   800145 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  80006c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800071:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  800077:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007c:	a3 60 40 80 00       	mov    %eax,0x804060

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800081:	85 db                	test   %ebx,%ebx
  800083:	7e 07                	jle    80008c <libmain+0x34>
		binaryname = argv[0];
  800085:	8b 06                	mov    (%esi),%eax
  800087:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008c:	83 ec 08             	sub    $0x8,%esp
  80008f:	56                   	push   %esi
  800090:	53                   	push   %ebx
  800091:	e8 9d ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800096:	e8 0a 00 00 00       	call   8000a5 <exit>
}
  80009b:	83 c4 10             	add    $0x10,%esp
  80009e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a1:	5b                   	pop    %ebx
  8000a2:	5e                   	pop    %esi
  8000a3:	5d                   	pop    %ebp
  8000a4:	c3                   	ret    

008000a5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a5:	f3 0f 1e fb          	endbr32 
  8000a9:	55                   	push   %ebp
  8000aa:	89 e5                	mov    %esp,%ebp
  8000ac:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000af:	6a 00                	push   $0x0
  8000b1:	e8 4a 00 00 00       	call   800100 <sys_env_destroy>
}
  8000b6:	83 c4 10             	add    $0x10,%esp
  8000b9:	c9                   	leave  
  8000ba:	c3                   	ret    

008000bb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bb:	f3 0f 1e fb          	endbr32 
  8000bf:	55                   	push   %ebp
  8000c0:	89 e5                	mov    %esp,%ebp
  8000c2:	57                   	push   %edi
  8000c3:	56                   	push   %esi
  8000c4:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8000c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d0:	89 c3                	mov    %eax,%ebx
  8000d2:	89 c7                	mov    %eax,%edi
  8000d4:	89 c6                	mov    %eax,%esi
  8000d6:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d8:	5b                   	pop    %ebx
  8000d9:	5e                   	pop    %esi
  8000da:	5f                   	pop    %edi
  8000db:	5d                   	pop    %ebp
  8000dc:	c3                   	ret    

008000dd <sys_cgetc>:

int
sys_cgetc(void)
{
  8000dd:	f3 0f 1e fb          	endbr32 
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	57                   	push   %edi
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8000e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ec:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f1:	89 d1                	mov    %edx,%ecx
  8000f3:	89 d3                	mov    %edx,%ebx
  8000f5:	89 d7                	mov    %edx,%edi
  8000f7:	89 d6                	mov    %edx,%esi
  8000f9:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fb:	5b                   	pop    %ebx
  8000fc:	5e                   	pop    %esi
  8000fd:	5f                   	pop    %edi
  8000fe:	5d                   	pop    %ebp
  8000ff:	c3                   	ret    

00800100 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800100:	f3 0f 1e fb          	endbr32 
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	57                   	push   %edi
  800108:	56                   	push   %esi
  800109:	53                   	push   %ebx
  80010a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  80010d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800112:	8b 55 08             	mov    0x8(%ebp),%edx
  800115:	b8 03 00 00 00       	mov    $0x3,%eax
  80011a:	89 cb                	mov    %ecx,%ebx
  80011c:	89 cf                	mov    %ecx,%edi
  80011e:	89 ce                	mov    %ecx,%esi
  800120:	cd 30                	int    $0x30
	if(check && ret > 0)
  800122:	85 c0                	test   %eax,%eax
  800124:	7f 08                	jg     80012e <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800126:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800129:	5b                   	pop    %ebx
  80012a:	5e                   	pop    %esi
  80012b:	5f                   	pop    %edi
  80012c:	5d                   	pop    %ebp
  80012d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80012e:	83 ec 0c             	sub    $0xc,%esp
  800131:	50                   	push   %eax
  800132:	6a 03                	push   $0x3
  800134:	68 aa 10 80 00       	push   $0x8010aa
  800139:	6a 23                	push   $0x23
  80013b:	68 c7 10 80 00       	push   $0x8010c7
  800140:	e8 35 02 00 00       	call   80037a <_panic>

00800145 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800145:	f3 0f 1e fb          	endbr32 
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	57                   	push   %edi
  80014d:	56                   	push   %esi
  80014e:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  80014f:	ba 00 00 00 00       	mov    $0x0,%edx
  800154:	b8 02 00 00 00       	mov    $0x2,%eax
  800159:	89 d1                	mov    %edx,%ecx
  80015b:	89 d3                	mov    %edx,%ebx
  80015d:	89 d7                	mov    %edx,%edi
  80015f:	89 d6                	mov    %edx,%esi
  800161:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800163:	5b                   	pop    %ebx
  800164:	5e                   	pop    %esi
  800165:	5f                   	pop    %edi
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <sys_yield>:

void
sys_yield(void)
{
  800168:	f3 0f 1e fb          	endbr32 
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	57                   	push   %edi
  800170:	56                   	push   %esi
  800171:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800172:	ba 00 00 00 00       	mov    $0x0,%edx
  800177:	b8 0a 00 00 00       	mov    $0xa,%eax
  80017c:	89 d1                	mov    %edx,%ecx
  80017e:	89 d3                	mov    %edx,%ebx
  800180:	89 d7                	mov    %edx,%edi
  800182:	89 d6                	mov    %edx,%esi
  800184:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800186:	5b                   	pop    %ebx
  800187:	5e                   	pop    %esi
  800188:	5f                   	pop    %edi
  800189:	5d                   	pop    %ebp
  80018a:	c3                   	ret    

0080018b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80018b:	f3 0f 1e fb          	endbr32 
  80018f:	55                   	push   %ebp
  800190:	89 e5                	mov    %esp,%ebp
  800192:	57                   	push   %edi
  800193:	56                   	push   %esi
  800194:	53                   	push   %ebx
  800195:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800198:	be 00 00 00 00       	mov    $0x0,%esi
  80019d:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a3:	b8 04 00 00 00       	mov    $0x4,%eax
  8001a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ab:	89 f7                	mov    %esi,%edi
  8001ad:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001af:	85 c0                	test   %eax,%eax
  8001b1:	7f 08                	jg     8001bb <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b6:	5b                   	pop    %ebx
  8001b7:	5e                   	pop    %esi
  8001b8:	5f                   	pop    %edi
  8001b9:	5d                   	pop    %ebp
  8001ba:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bb:	83 ec 0c             	sub    $0xc,%esp
  8001be:	50                   	push   %eax
  8001bf:	6a 04                	push   $0x4
  8001c1:	68 aa 10 80 00       	push   $0x8010aa
  8001c6:	6a 23                	push   $0x23
  8001c8:	68 c7 10 80 00       	push   $0x8010c7
  8001cd:	e8 a8 01 00 00       	call   80037a <_panic>

008001d2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d2:	f3 0f 1e fb          	endbr32 
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	57                   	push   %edi
  8001da:	56                   	push   %esi
  8001db:	53                   	push   %ebx
  8001dc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8001df:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e5:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ed:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001f0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001f3:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001f5:	85 c0                	test   %eax,%eax
  8001f7:	7f 08                	jg     800201 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001fc:	5b                   	pop    %ebx
  8001fd:	5e                   	pop    %esi
  8001fe:	5f                   	pop    %edi
  8001ff:	5d                   	pop    %ebp
  800200:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800201:	83 ec 0c             	sub    $0xc,%esp
  800204:	50                   	push   %eax
  800205:	6a 05                	push   $0x5
  800207:	68 aa 10 80 00       	push   $0x8010aa
  80020c:	6a 23                	push   $0x23
  80020e:	68 c7 10 80 00       	push   $0x8010c7
  800213:	e8 62 01 00 00       	call   80037a <_panic>

00800218 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800218:	f3 0f 1e fb          	endbr32 
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800225:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022a:	8b 55 08             	mov    0x8(%ebp),%edx
  80022d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800230:	b8 06 00 00 00       	mov    $0x6,%eax
  800235:	89 df                	mov    %ebx,%edi
  800237:	89 de                	mov    %ebx,%esi
  800239:	cd 30                	int    $0x30
	if(check && ret > 0)
  80023b:	85 c0                	test   %eax,%eax
  80023d:	7f 08                	jg     800247 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80023f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800242:	5b                   	pop    %ebx
  800243:	5e                   	pop    %esi
  800244:	5f                   	pop    %edi
  800245:	5d                   	pop    %ebp
  800246:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800247:	83 ec 0c             	sub    $0xc,%esp
  80024a:	50                   	push   %eax
  80024b:	6a 06                	push   $0x6
  80024d:	68 aa 10 80 00       	push   $0x8010aa
  800252:	6a 23                	push   $0x23
  800254:	68 c7 10 80 00       	push   $0x8010c7
  800259:	e8 1c 01 00 00       	call   80037a <_panic>

0080025e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80025e:	f3 0f 1e fb          	endbr32 
  800262:	55                   	push   %ebp
  800263:	89 e5                	mov    %esp,%ebp
  800265:	57                   	push   %edi
  800266:	56                   	push   %esi
  800267:	53                   	push   %ebx
  800268:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  80026b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800270:	8b 55 08             	mov    0x8(%ebp),%edx
  800273:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800276:	b8 08 00 00 00       	mov    $0x8,%eax
  80027b:	89 df                	mov    %ebx,%edi
  80027d:	89 de                	mov    %ebx,%esi
  80027f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800281:	85 c0                	test   %eax,%eax
  800283:	7f 08                	jg     80028d <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800285:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800288:	5b                   	pop    %ebx
  800289:	5e                   	pop    %esi
  80028a:	5f                   	pop    %edi
  80028b:	5d                   	pop    %ebp
  80028c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80028d:	83 ec 0c             	sub    $0xc,%esp
  800290:	50                   	push   %eax
  800291:	6a 08                	push   $0x8
  800293:	68 aa 10 80 00       	push   $0x8010aa
  800298:	6a 23                	push   $0x23
  80029a:	68 c7 10 80 00       	push   $0x8010c7
  80029f:	e8 d6 00 00 00       	call   80037a <_panic>

008002a4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a4:	f3 0f 1e fb          	endbr32 
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
  8002ab:	57                   	push   %edi
  8002ac:	56                   	push   %esi
  8002ad:	53                   	push   %ebx
  8002ae:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8002b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bc:	b8 09 00 00 00       	mov    $0x9,%eax
  8002c1:	89 df                	mov    %ebx,%edi
  8002c3:	89 de                	mov    %ebx,%esi
  8002c5:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002c7:	85 c0                	test   %eax,%eax
  8002c9:	7f 08                	jg     8002d3 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ce:	5b                   	pop    %ebx
  8002cf:	5e                   	pop    %esi
  8002d0:	5f                   	pop    %edi
  8002d1:	5d                   	pop    %ebp
  8002d2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d3:	83 ec 0c             	sub    $0xc,%esp
  8002d6:	50                   	push   %eax
  8002d7:	6a 09                	push   $0x9
  8002d9:	68 aa 10 80 00       	push   $0x8010aa
  8002de:	6a 23                	push   $0x23
  8002e0:	68 c7 10 80 00       	push   $0x8010c7
  8002e5:	e8 90 00 00 00       	call   80037a <_panic>

008002ea <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002ea:	f3 0f 1e fb          	endbr32 
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	57                   	push   %edi
  8002f2:	56                   	push   %esi
  8002f3:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8002f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fa:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002ff:	be 00 00 00 00       	mov    $0x0,%esi
  800304:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800307:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030a:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80030c:	5b                   	pop    %ebx
  80030d:	5e                   	pop    %esi
  80030e:	5f                   	pop    %edi
  80030f:	5d                   	pop    %ebp
  800310:	c3                   	ret    

00800311 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800311:	f3 0f 1e fb          	endbr32 
  800315:	55                   	push   %ebp
  800316:	89 e5                	mov    %esp,%ebp
  800318:	57                   	push   %edi
  800319:	56                   	push   %esi
  80031a:	53                   	push   %ebx
  80031b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  80031e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800323:	8b 55 08             	mov    0x8(%ebp),%edx
  800326:	b8 0c 00 00 00       	mov    $0xc,%eax
  80032b:	89 cb                	mov    %ecx,%ebx
  80032d:	89 cf                	mov    %ecx,%edi
  80032f:	89 ce                	mov    %ecx,%esi
  800331:	cd 30                	int    $0x30
	if(check && ret > 0)
  800333:	85 c0                	test   %eax,%eax
  800335:	7f 08                	jg     80033f <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800337:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80033a:	5b                   	pop    %ebx
  80033b:	5e                   	pop    %esi
  80033c:	5f                   	pop    %edi
  80033d:	5d                   	pop    %ebp
  80033e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80033f:	83 ec 0c             	sub    $0xc,%esp
  800342:	50                   	push   %eax
  800343:	6a 0c                	push   $0xc
  800345:	68 aa 10 80 00       	push   $0x8010aa
  80034a:	6a 23                	push   $0x23
  80034c:	68 c7 10 80 00       	push   $0x8010c7
  800351:	e8 24 00 00 00       	call   80037a <_panic>

00800356 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800356:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800357:	a1 64 40 80 00       	mov    0x804064,%eax
	call *%eax				
  80035c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80035e:	83 c4 04             	add    $0x4,%esp
	// LAB 4: Your code here.

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp			
  800361:	83 c4 08             	add    $0x8,%esp
	movl 40(%esp), %eax 	
  800364:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 32(%esp), %ecx 	
  800368:	8b 4c 24 20          	mov    0x20(%esp),%ecx
	movl %ecx, -4(%eax) 	
  80036c:	89 48 fc             	mov    %ecx,-0x4(%eax)
	popal
  80036f:	61                   	popa   
	addl $4, %esp		
  800370:	83 c4 04             	add    $0x4,%esp

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	popfl
  800373:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800374:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	lea -4(%esp), %esp	
  800375:	8d 64 24 fc          	lea    -0x4(%esp),%esp
	ret
  800379:	c3                   	ret    

0080037a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80037a:	f3 0f 1e fb          	endbr32 
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	56                   	push   %esi
  800382:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800383:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800386:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80038c:	e8 b4 fd ff ff       	call   800145 <sys_getenvid>
  800391:	83 ec 0c             	sub    $0xc,%esp
  800394:	ff 75 0c             	pushl  0xc(%ebp)
  800397:	ff 75 08             	pushl  0x8(%ebp)
  80039a:	56                   	push   %esi
  80039b:	50                   	push   %eax
  80039c:	68 d8 10 80 00       	push   $0x8010d8
  8003a1:	e8 bb 00 00 00       	call   800461 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003a6:	83 c4 18             	add    $0x18,%esp
  8003a9:	53                   	push   %ebx
  8003aa:	ff 75 10             	pushl  0x10(%ebp)
  8003ad:	e8 5a 00 00 00       	call   80040c <vcprintf>
	cprintf("\n");
  8003b2:	c7 04 24 fb 10 80 00 	movl   $0x8010fb,(%esp)
  8003b9:	e8 a3 00 00 00       	call   800461 <cprintf>
  8003be:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003c1:	cc                   	int3   
  8003c2:	eb fd                	jmp    8003c1 <_panic+0x47>

008003c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003c4:	f3 0f 1e fb          	endbr32 
  8003c8:	55                   	push   %ebp
  8003c9:	89 e5                	mov    %esp,%ebp
  8003cb:	53                   	push   %ebx
  8003cc:	83 ec 04             	sub    $0x4,%esp
  8003cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003d2:	8b 13                	mov    (%ebx),%edx
  8003d4:	8d 42 01             	lea    0x1(%edx),%eax
  8003d7:	89 03                	mov    %eax,(%ebx)
  8003d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003dc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003e0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003e5:	74 09                	je     8003f0 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003e7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003ee:	c9                   	leave  
  8003ef:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003f0:	83 ec 08             	sub    $0x8,%esp
  8003f3:	68 ff 00 00 00       	push   $0xff
  8003f8:	8d 43 08             	lea    0x8(%ebx),%eax
  8003fb:	50                   	push   %eax
  8003fc:	e8 ba fc ff ff       	call   8000bb <sys_cputs>
		b->idx = 0;
  800401:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800407:	83 c4 10             	add    $0x10,%esp
  80040a:	eb db                	jmp    8003e7 <putch+0x23>

0080040c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80040c:	f3 0f 1e fb          	endbr32 
  800410:	55                   	push   %ebp
  800411:	89 e5                	mov    %esp,%ebp
  800413:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800419:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800420:	00 00 00 
	b.cnt = 0;
  800423:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80042a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80042d:	ff 75 0c             	pushl  0xc(%ebp)
  800430:	ff 75 08             	pushl  0x8(%ebp)
  800433:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800439:	50                   	push   %eax
  80043a:	68 c4 03 80 00       	push   $0x8003c4
  80043f:	e8 20 01 00 00       	call   800564 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800444:	83 c4 08             	add    $0x8,%esp
  800447:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80044d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800453:	50                   	push   %eax
  800454:	e8 62 fc ff ff       	call   8000bb <sys_cputs>

	return b.cnt;
}
  800459:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80045f:	c9                   	leave  
  800460:	c3                   	ret    

00800461 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800461:	f3 0f 1e fb          	endbr32 
  800465:	55                   	push   %ebp
  800466:	89 e5                	mov    %esp,%ebp
  800468:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80046b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80046e:	50                   	push   %eax
  80046f:	ff 75 08             	pushl  0x8(%ebp)
  800472:	e8 95 ff ff ff       	call   80040c <vcprintf>
	va_end(ap);

	return cnt;
}
  800477:	c9                   	leave  
  800478:	c3                   	ret    

00800479 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800479:	55                   	push   %ebp
  80047a:	89 e5                	mov    %esp,%ebp
  80047c:	57                   	push   %edi
  80047d:	56                   	push   %esi
  80047e:	53                   	push   %ebx
  80047f:	83 ec 1c             	sub    $0x1c,%esp
  800482:	89 c7                	mov    %eax,%edi
  800484:	89 d6                	mov    %edx,%esi
  800486:	8b 45 08             	mov    0x8(%ebp),%eax
  800489:	8b 55 0c             	mov    0xc(%ebp),%edx
  80048c:	89 d1                	mov    %edx,%ecx
  80048e:	89 c2                	mov    %eax,%edx
  800490:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800493:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800496:	8b 45 10             	mov    0x10(%ebp),%eax
  800499:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80049c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80049f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004a6:	39 c2                	cmp    %eax,%edx
  8004a8:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8004ab:	72 3e                	jb     8004eb <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004ad:	83 ec 0c             	sub    $0xc,%esp
  8004b0:	ff 75 18             	pushl  0x18(%ebp)
  8004b3:	83 eb 01             	sub    $0x1,%ebx
  8004b6:	53                   	push   %ebx
  8004b7:	50                   	push   %eax
  8004b8:	83 ec 08             	sub    $0x8,%esp
  8004bb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004be:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c1:	ff 75 dc             	pushl  -0x24(%ebp)
  8004c4:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c7:	e8 74 09 00 00       	call   800e40 <__udivdi3>
  8004cc:	83 c4 18             	add    $0x18,%esp
  8004cf:	52                   	push   %edx
  8004d0:	50                   	push   %eax
  8004d1:	89 f2                	mov    %esi,%edx
  8004d3:	89 f8                	mov    %edi,%eax
  8004d5:	e8 9f ff ff ff       	call   800479 <printnum>
  8004da:	83 c4 20             	add    $0x20,%esp
  8004dd:	eb 13                	jmp    8004f2 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004df:	83 ec 08             	sub    $0x8,%esp
  8004e2:	56                   	push   %esi
  8004e3:	ff 75 18             	pushl  0x18(%ebp)
  8004e6:	ff d7                	call   *%edi
  8004e8:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004eb:	83 eb 01             	sub    $0x1,%ebx
  8004ee:	85 db                	test   %ebx,%ebx
  8004f0:	7f ed                	jg     8004df <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004f2:	83 ec 08             	sub    $0x8,%esp
  8004f5:	56                   	push   %esi
  8004f6:	83 ec 04             	sub    $0x4,%esp
  8004f9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004fc:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ff:	ff 75 dc             	pushl  -0x24(%ebp)
  800502:	ff 75 d8             	pushl  -0x28(%ebp)
  800505:	e8 46 0a 00 00       	call   800f50 <__umoddi3>
  80050a:	83 c4 14             	add    $0x14,%esp
  80050d:	0f be 80 fd 10 80 00 	movsbl 0x8010fd(%eax),%eax
  800514:	50                   	push   %eax
  800515:	ff d7                	call   *%edi
}
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80051d:	5b                   	pop    %ebx
  80051e:	5e                   	pop    %esi
  80051f:	5f                   	pop    %edi
  800520:	5d                   	pop    %ebp
  800521:	c3                   	ret    

00800522 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800522:	f3 0f 1e fb          	endbr32 
  800526:	55                   	push   %ebp
  800527:	89 e5                	mov    %esp,%ebp
  800529:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80052c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800530:	8b 10                	mov    (%eax),%edx
  800532:	3b 50 04             	cmp    0x4(%eax),%edx
  800535:	73 0a                	jae    800541 <sprintputch+0x1f>
		*b->buf++ = ch;
  800537:	8d 4a 01             	lea    0x1(%edx),%ecx
  80053a:	89 08                	mov    %ecx,(%eax)
  80053c:	8b 45 08             	mov    0x8(%ebp),%eax
  80053f:	88 02                	mov    %al,(%edx)
}
  800541:	5d                   	pop    %ebp
  800542:	c3                   	ret    

00800543 <printfmt>:
{
  800543:	f3 0f 1e fb          	endbr32 
  800547:	55                   	push   %ebp
  800548:	89 e5                	mov    %esp,%ebp
  80054a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80054d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800550:	50                   	push   %eax
  800551:	ff 75 10             	pushl  0x10(%ebp)
  800554:	ff 75 0c             	pushl  0xc(%ebp)
  800557:	ff 75 08             	pushl  0x8(%ebp)
  80055a:	e8 05 00 00 00       	call   800564 <vprintfmt>
}
  80055f:	83 c4 10             	add    $0x10,%esp
  800562:	c9                   	leave  
  800563:	c3                   	ret    

00800564 <vprintfmt>:
{
  800564:	f3 0f 1e fb          	endbr32 
  800568:	55                   	push   %ebp
  800569:	89 e5                	mov    %esp,%ebp
  80056b:	57                   	push   %edi
  80056c:	56                   	push   %esi
  80056d:	53                   	push   %ebx
  80056e:	83 ec 3c             	sub    $0x3c,%esp
  800571:	8b 75 08             	mov    0x8(%ebp),%esi
  800574:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800577:	8b 7d 10             	mov    0x10(%ebp),%edi
  80057a:	e9 8e 03 00 00       	jmp    80090d <vprintfmt+0x3a9>
		padc = ' ';
  80057f:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800583:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80058a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800591:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800598:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80059d:	8d 47 01             	lea    0x1(%edi),%eax
  8005a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005a3:	0f b6 17             	movzbl (%edi),%edx
  8005a6:	8d 42 dd             	lea    -0x23(%edx),%eax
  8005a9:	3c 55                	cmp    $0x55,%al
  8005ab:	0f 87 df 03 00 00    	ja     800990 <vprintfmt+0x42c>
  8005b1:	0f b6 c0             	movzbl %al,%eax
  8005b4:	3e ff 24 85 c0 11 80 	notrack jmp *0x8011c0(,%eax,4)
  8005bb:	00 
  8005bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8005bf:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8005c3:	eb d8                	jmp    80059d <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c8:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8005cc:	eb cf                	jmp    80059d <vprintfmt+0x39>
  8005ce:	0f b6 d2             	movzbl %dl,%edx
  8005d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8005d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005dc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005df:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005e3:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005e6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005e9:	83 f9 09             	cmp    $0x9,%ecx
  8005ec:	77 55                	ja     800643 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005ee:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005f1:	eb e9                	jmp    8005dc <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8b 00                	mov    (%eax),%eax
  8005f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8d 40 04             	lea    0x4(%eax),%eax
  800601:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800604:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800607:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80060b:	79 90                	jns    80059d <vprintfmt+0x39>
				width = precision, precision = -1;
  80060d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800610:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800613:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80061a:	eb 81                	jmp    80059d <vprintfmt+0x39>
  80061c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80061f:	85 c0                	test   %eax,%eax
  800621:	ba 00 00 00 00       	mov    $0x0,%edx
  800626:	0f 49 d0             	cmovns %eax,%edx
  800629:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80062c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80062f:	e9 69 ff ff ff       	jmp    80059d <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800634:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800637:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80063e:	e9 5a ff ff ff       	jmp    80059d <vprintfmt+0x39>
  800643:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800646:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800649:	eb bc                	jmp    800607 <vprintfmt+0xa3>
			lflag++;
  80064b:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80064e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800651:	e9 47 ff ff ff       	jmp    80059d <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8d 78 04             	lea    0x4(%eax),%edi
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	53                   	push   %ebx
  800660:	ff 30                	pushl  (%eax)
  800662:	ff d6                	call   *%esi
			break;
  800664:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800667:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80066a:	e9 9b 02 00 00       	jmp    80090a <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8d 78 04             	lea    0x4(%eax),%edi
  800675:	8b 00                	mov    (%eax),%eax
  800677:	99                   	cltd   
  800678:	31 d0                	xor    %edx,%eax
  80067a:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80067c:	83 f8 08             	cmp    $0x8,%eax
  80067f:	7f 23                	jg     8006a4 <vprintfmt+0x140>
  800681:	8b 14 85 20 13 80 00 	mov    0x801320(,%eax,4),%edx
  800688:	85 d2                	test   %edx,%edx
  80068a:	74 18                	je     8006a4 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80068c:	52                   	push   %edx
  80068d:	68 1e 11 80 00       	push   $0x80111e
  800692:	53                   	push   %ebx
  800693:	56                   	push   %esi
  800694:	e8 aa fe ff ff       	call   800543 <printfmt>
  800699:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80069c:	89 7d 14             	mov    %edi,0x14(%ebp)
  80069f:	e9 66 02 00 00       	jmp    80090a <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  8006a4:	50                   	push   %eax
  8006a5:	68 15 11 80 00       	push   $0x801115
  8006aa:	53                   	push   %ebx
  8006ab:	56                   	push   %esi
  8006ac:	e8 92 fe ff ff       	call   800543 <printfmt>
  8006b1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8006b4:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8006b7:	e9 4e 02 00 00       	jmp    80090a <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  8006bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bf:	83 c0 04             	add    $0x4,%eax
  8006c2:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8006c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c8:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8006ca:	85 d2                	test   %edx,%edx
  8006cc:	b8 0e 11 80 00       	mov    $0x80110e,%eax
  8006d1:	0f 45 c2             	cmovne %edx,%eax
  8006d4:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8006d7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006db:	7e 06                	jle    8006e3 <vprintfmt+0x17f>
  8006dd:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006e1:	75 0d                	jne    8006f0 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006e6:	89 c7                	mov    %eax,%edi
  8006e8:	03 45 e0             	add    -0x20(%ebp),%eax
  8006eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ee:	eb 55                	jmp    800745 <vprintfmt+0x1e1>
  8006f0:	83 ec 08             	sub    $0x8,%esp
  8006f3:	ff 75 d8             	pushl  -0x28(%ebp)
  8006f6:	ff 75 cc             	pushl  -0x34(%ebp)
  8006f9:	e8 46 03 00 00       	call   800a44 <strnlen>
  8006fe:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800701:	29 c2                	sub    %eax,%edx
  800703:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800706:	83 c4 10             	add    $0x10,%esp
  800709:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80070b:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80070f:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800712:	85 ff                	test   %edi,%edi
  800714:	7e 11                	jle    800727 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800716:	83 ec 08             	sub    $0x8,%esp
  800719:	53                   	push   %ebx
  80071a:	ff 75 e0             	pushl  -0x20(%ebp)
  80071d:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80071f:	83 ef 01             	sub    $0x1,%edi
  800722:	83 c4 10             	add    $0x10,%esp
  800725:	eb eb                	jmp    800712 <vprintfmt+0x1ae>
  800727:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80072a:	85 d2                	test   %edx,%edx
  80072c:	b8 00 00 00 00       	mov    $0x0,%eax
  800731:	0f 49 c2             	cmovns %edx,%eax
  800734:	29 c2                	sub    %eax,%edx
  800736:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800739:	eb a8                	jmp    8006e3 <vprintfmt+0x17f>
					putch(ch, putdat);
  80073b:	83 ec 08             	sub    $0x8,%esp
  80073e:	53                   	push   %ebx
  80073f:	52                   	push   %edx
  800740:	ff d6                	call   *%esi
  800742:	83 c4 10             	add    $0x10,%esp
  800745:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800748:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80074a:	83 c7 01             	add    $0x1,%edi
  80074d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800751:	0f be d0             	movsbl %al,%edx
  800754:	85 d2                	test   %edx,%edx
  800756:	74 4b                	je     8007a3 <vprintfmt+0x23f>
  800758:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80075c:	78 06                	js     800764 <vprintfmt+0x200>
  80075e:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800762:	78 1e                	js     800782 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800764:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800768:	74 d1                	je     80073b <vprintfmt+0x1d7>
  80076a:	0f be c0             	movsbl %al,%eax
  80076d:	83 e8 20             	sub    $0x20,%eax
  800770:	83 f8 5e             	cmp    $0x5e,%eax
  800773:	76 c6                	jbe    80073b <vprintfmt+0x1d7>
					putch('?', putdat);
  800775:	83 ec 08             	sub    $0x8,%esp
  800778:	53                   	push   %ebx
  800779:	6a 3f                	push   $0x3f
  80077b:	ff d6                	call   *%esi
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	eb c3                	jmp    800745 <vprintfmt+0x1e1>
  800782:	89 cf                	mov    %ecx,%edi
  800784:	eb 0e                	jmp    800794 <vprintfmt+0x230>
				putch(' ', putdat);
  800786:	83 ec 08             	sub    $0x8,%esp
  800789:	53                   	push   %ebx
  80078a:	6a 20                	push   $0x20
  80078c:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80078e:	83 ef 01             	sub    $0x1,%edi
  800791:	83 c4 10             	add    $0x10,%esp
  800794:	85 ff                	test   %edi,%edi
  800796:	7f ee                	jg     800786 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800798:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80079b:	89 45 14             	mov    %eax,0x14(%ebp)
  80079e:	e9 67 01 00 00       	jmp    80090a <vprintfmt+0x3a6>
  8007a3:	89 cf                	mov    %ecx,%edi
  8007a5:	eb ed                	jmp    800794 <vprintfmt+0x230>
	if (lflag >= 2)
  8007a7:	83 f9 01             	cmp    $0x1,%ecx
  8007aa:	7f 1b                	jg     8007c7 <vprintfmt+0x263>
	else if (lflag)
  8007ac:	85 c9                	test   %ecx,%ecx
  8007ae:	74 63                	je     800813 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8007b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b3:	8b 00                	mov    (%eax),%eax
  8007b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b8:	99                   	cltd   
  8007b9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bf:	8d 40 04             	lea    0x4(%eax),%eax
  8007c2:	89 45 14             	mov    %eax,0x14(%ebp)
  8007c5:	eb 17                	jmp    8007de <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8007c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ca:	8b 50 04             	mov    0x4(%eax),%edx
  8007cd:	8b 00                	mov    (%eax),%eax
  8007cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d8:	8d 40 08             	lea    0x8(%eax),%eax
  8007db:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007de:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007e1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007e4:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007e9:	85 c9                	test   %ecx,%ecx
  8007eb:	0f 89 ff 00 00 00    	jns    8008f0 <vprintfmt+0x38c>
				putch('-', putdat);
  8007f1:	83 ec 08             	sub    $0x8,%esp
  8007f4:	53                   	push   %ebx
  8007f5:	6a 2d                	push   $0x2d
  8007f7:	ff d6                	call   *%esi
				num = -(long long) num;
  8007f9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007fc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007ff:	f7 da                	neg    %edx
  800801:	83 d1 00             	adc    $0x0,%ecx
  800804:	f7 d9                	neg    %ecx
  800806:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800809:	b8 0a 00 00 00       	mov    $0xa,%eax
  80080e:	e9 dd 00 00 00       	jmp    8008f0 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  800813:	8b 45 14             	mov    0x14(%ebp),%eax
  800816:	8b 00                	mov    (%eax),%eax
  800818:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80081b:	99                   	cltd   
  80081c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80081f:	8b 45 14             	mov    0x14(%ebp),%eax
  800822:	8d 40 04             	lea    0x4(%eax),%eax
  800825:	89 45 14             	mov    %eax,0x14(%ebp)
  800828:	eb b4                	jmp    8007de <vprintfmt+0x27a>
	if (lflag >= 2)
  80082a:	83 f9 01             	cmp    $0x1,%ecx
  80082d:	7f 1e                	jg     80084d <vprintfmt+0x2e9>
	else if (lflag)
  80082f:	85 c9                	test   %ecx,%ecx
  800831:	74 32                	je     800865 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800833:	8b 45 14             	mov    0x14(%ebp),%eax
  800836:	8b 10                	mov    (%eax),%edx
  800838:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083d:	8d 40 04             	lea    0x4(%eax),%eax
  800840:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800843:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800848:	e9 a3 00 00 00       	jmp    8008f0 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80084d:	8b 45 14             	mov    0x14(%ebp),%eax
  800850:	8b 10                	mov    (%eax),%edx
  800852:	8b 48 04             	mov    0x4(%eax),%ecx
  800855:	8d 40 08             	lea    0x8(%eax),%eax
  800858:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80085b:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800860:	e9 8b 00 00 00       	jmp    8008f0 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800865:	8b 45 14             	mov    0x14(%ebp),%eax
  800868:	8b 10                	mov    (%eax),%edx
  80086a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80086f:	8d 40 04             	lea    0x4(%eax),%eax
  800872:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800875:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80087a:	eb 74                	jmp    8008f0 <vprintfmt+0x38c>
	if (lflag >= 2)
  80087c:	83 f9 01             	cmp    $0x1,%ecx
  80087f:	7f 1b                	jg     80089c <vprintfmt+0x338>
	else if (lflag)
  800881:	85 c9                	test   %ecx,%ecx
  800883:	74 2c                	je     8008b1 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800885:	8b 45 14             	mov    0x14(%ebp),%eax
  800888:	8b 10                	mov    (%eax),%edx
  80088a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80088f:	8d 40 04             	lea    0x4(%eax),%eax
  800892:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800895:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  80089a:	eb 54                	jmp    8008f0 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80089c:	8b 45 14             	mov    0x14(%ebp),%eax
  80089f:	8b 10                	mov    (%eax),%edx
  8008a1:	8b 48 04             	mov    0x4(%eax),%ecx
  8008a4:	8d 40 08             	lea    0x8(%eax),%eax
  8008a7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8008aa:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  8008af:	eb 3f                	jmp    8008f0 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8008b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b4:	8b 10                	mov    (%eax),%edx
  8008b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008bb:	8d 40 04             	lea    0x4(%eax),%eax
  8008be:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8008c1:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  8008c6:	eb 28                	jmp    8008f0 <vprintfmt+0x38c>
			putch('0', putdat);
  8008c8:	83 ec 08             	sub    $0x8,%esp
  8008cb:	53                   	push   %ebx
  8008cc:	6a 30                	push   $0x30
  8008ce:	ff d6                	call   *%esi
			putch('x', putdat);
  8008d0:	83 c4 08             	add    $0x8,%esp
  8008d3:	53                   	push   %ebx
  8008d4:	6a 78                	push   $0x78
  8008d6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008db:	8b 10                	mov    (%eax),%edx
  8008dd:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008e2:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008e5:	8d 40 04             	lea    0x4(%eax),%eax
  8008e8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008eb:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008f0:	83 ec 0c             	sub    $0xc,%esp
  8008f3:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8008f7:	57                   	push   %edi
  8008f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8008fb:	50                   	push   %eax
  8008fc:	51                   	push   %ecx
  8008fd:	52                   	push   %edx
  8008fe:	89 da                	mov    %ebx,%edx
  800900:	89 f0                	mov    %esi,%eax
  800902:	e8 72 fb ff ff       	call   800479 <printnum>
			break;
  800907:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80090a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {	
  80090d:	83 c7 01             	add    $0x1,%edi
  800910:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800914:	83 f8 25             	cmp    $0x25,%eax
  800917:	0f 84 62 fc ff ff    	je     80057f <vprintfmt+0x1b>
			if (ch == '\0')										
  80091d:	85 c0                	test   %eax,%eax
  80091f:	0f 84 8b 00 00 00    	je     8009b0 <vprintfmt+0x44c>
			putch(ch, putdat);
  800925:	83 ec 08             	sub    $0x8,%esp
  800928:	53                   	push   %ebx
  800929:	50                   	push   %eax
  80092a:	ff d6                	call   *%esi
  80092c:	83 c4 10             	add    $0x10,%esp
  80092f:	eb dc                	jmp    80090d <vprintfmt+0x3a9>
	if (lflag >= 2)
  800931:	83 f9 01             	cmp    $0x1,%ecx
  800934:	7f 1b                	jg     800951 <vprintfmt+0x3ed>
	else if (lflag)
  800936:	85 c9                	test   %ecx,%ecx
  800938:	74 2c                	je     800966 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  80093a:	8b 45 14             	mov    0x14(%ebp),%eax
  80093d:	8b 10                	mov    (%eax),%edx
  80093f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800944:	8d 40 04             	lea    0x4(%eax),%eax
  800947:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80094a:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80094f:	eb 9f                	jmp    8008f0 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800951:	8b 45 14             	mov    0x14(%ebp),%eax
  800954:	8b 10                	mov    (%eax),%edx
  800956:	8b 48 04             	mov    0x4(%eax),%ecx
  800959:	8d 40 08             	lea    0x8(%eax),%eax
  80095c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80095f:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800964:	eb 8a                	jmp    8008f0 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800966:	8b 45 14             	mov    0x14(%ebp),%eax
  800969:	8b 10                	mov    (%eax),%edx
  80096b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800970:	8d 40 04             	lea    0x4(%eax),%eax
  800973:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800976:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80097b:	e9 70 ff ff ff       	jmp    8008f0 <vprintfmt+0x38c>
			putch(ch, putdat);
  800980:	83 ec 08             	sub    $0x8,%esp
  800983:	53                   	push   %ebx
  800984:	6a 25                	push   $0x25
  800986:	ff d6                	call   *%esi
			break;
  800988:	83 c4 10             	add    $0x10,%esp
  80098b:	e9 7a ff ff ff       	jmp    80090a <vprintfmt+0x3a6>
			putch('%', putdat);
  800990:	83 ec 08             	sub    $0x8,%esp
  800993:	53                   	push   %ebx
  800994:	6a 25                	push   $0x25
  800996:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800998:	83 c4 10             	add    $0x10,%esp
  80099b:	89 f8                	mov    %edi,%eax
  80099d:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8009a1:	74 05                	je     8009a8 <vprintfmt+0x444>
  8009a3:	83 e8 01             	sub    $0x1,%eax
  8009a6:	eb f5                	jmp    80099d <vprintfmt+0x439>
  8009a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009ab:	e9 5a ff ff ff       	jmp    80090a <vprintfmt+0x3a6>
}
  8009b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009b3:	5b                   	pop    %ebx
  8009b4:	5e                   	pop    %esi
  8009b5:	5f                   	pop    %edi
  8009b6:	5d                   	pop    %ebp
  8009b7:	c3                   	ret    

008009b8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009b8:	f3 0f 1e fb          	endbr32 
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	83 ec 18             	sub    $0x18,%esp
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009cb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009cf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009d9:	85 c0                	test   %eax,%eax
  8009db:	74 26                	je     800a03 <vsnprintf+0x4b>
  8009dd:	85 d2                	test   %edx,%edx
  8009df:	7e 22                	jle    800a03 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009e1:	ff 75 14             	pushl  0x14(%ebp)
  8009e4:	ff 75 10             	pushl  0x10(%ebp)
  8009e7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009ea:	50                   	push   %eax
  8009eb:	68 22 05 80 00       	push   $0x800522
  8009f0:	e8 6f fb ff ff       	call   800564 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009f8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009fe:	83 c4 10             	add    $0x10,%esp
}
  800a01:	c9                   	leave  
  800a02:	c3                   	ret    
		return -E_INVAL;
  800a03:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a08:	eb f7                	jmp    800a01 <vsnprintf+0x49>

00800a0a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a0a:	f3 0f 1e fb          	endbr32 
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a14:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a17:	50                   	push   %eax
  800a18:	ff 75 10             	pushl  0x10(%ebp)
  800a1b:	ff 75 0c             	pushl  0xc(%ebp)
  800a1e:	ff 75 08             	pushl  0x8(%ebp)
  800a21:	e8 92 ff ff ff       	call   8009b8 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a26:	c9                   	leave  
  800a27:	c3                   	ret    

00800a28 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a28:	f3 0f 1e fb          	endbr32 
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a32:	b8 00 00 00 00       	mov    $0x0,%eax
  800a37:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a3b:	74 05                	je     800a42 <strlen+0x1a>
		n++;
  800a3d:	83 c0 01             	add    $0x1,%eax
  800a40:	eb f5                	jmp    800a37 <strlen+0xf>
	return n;
}
  800a42:	5d                   	pop    %ebp
  800a43:	c3                   	ret    

00800a44 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a44:	f3 0f 1e fb          	endbr32 
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a51:	b8 00 00 00 00       	mov    $0x0,%eax
  800a56:	39 d0                	cmp    %edx,%eax
  800a58:	74 0d                	je     800a67 <strnlen+0x23>
  800a5a:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a5e:	74 05                	je     800a65 <strnlen+0x21>
		n++;
  800a60:	83 c0 01             	add    $0x1,%eax
  800a63:	eb f1                	jmp    800a56 <strnlen+0x12>
  800a65:	89 c2                	mov    %eax,%edx
	return n;
}
  800a67:	89 d0                	mov    %edx,%eax
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    

00800a6b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a6b:	f3 0f 1e fb          	endbr32 
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	53                   	push   %ebx
  800a73:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a76:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a79:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7e:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a82:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a85:	83 c0 01             	add    $0x1,%eax
  800a88:	84 d2                	test   %dl,%dl
  800a8a:	75 f2                	jne    800a7e <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a8c:	89 c8                	mov    %ecx,%eax
  800a8e:	5b                   	pop    %ebx
  800a8f:	5d                   	pop    %ebp
  800a90:	c3                   	ret    

00800a91 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a91:	f3 0f 1e fb          	endbr32 
  800a95:	55                   	push   %ebp
  800a96:	89 e5                	mov    %esp,%ebp
  800a98:	53                   	push   %ebx
  800a99:	83 ec 10             	sub    $0x10,%esp
  800a9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a9f:	53                   	push   %ebx
  800aa0:	e8 83 ff ff ff       	call   800a28 <strlen>
  800aa5:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800aa8:	ff 75 0c             	pushl  0xc(%ebp)
  800aab:	01 d8                	add    %ebx,%eax
  800aad:	50                   	push   %eax
  800aae:	e8 b8 ff ff ff       	call   800a6b <strcpy>
	return dst;
}
  800ab3:	89 d8                	mov    %ebx,%eax
  800ab5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ab8:	c9                   	leave  
  800ab9:	c3                   	ret    

00800aba <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800aba:	f3 0f 1e fb          	endbr32 
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	56                   	push   %esi
  800ac2:	53                   	push   %ebx
  800ac3:	8b 75 08             	mov    0x8(%ebp),%esi
  800ac6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac9:	89 f3                	mov    %esi,%ebx
  800acb:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ace:	89 f0                	mov    %esi,%eax
  800ad0:	39 d8                	cmp    %ebx,%eax
  800ad2:	74 11                	je     800ae5 <strncpy+0x2b>
		*dst++ = *src;
  800ad4:	83 c0 01             	add    $0x1,%eax
  800ad7:	0f b6 0a             	movzbl (%edx),%ecx
  800ada:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800add:	80 f9 01             	cmp    $0x1,%cl
  800ae0:	83 da ff             	sbb    $0xffffffff,%edx
  800ae3:	eb eb                	jmp    800ad0 <strncpy+0x16>
	}
	return ret;
}
  800ae5:	89 f0                	mov    %esi,%eax
  800ae7:	5b                   	pop    %ebx
  800ae8:	5e                   	pop    %esi
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aeb:	f3 0f 1e fb          	endbr32 
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
  800af4:	8b 75 08             	mov    0x8(%ebp),%esi
  800af7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800afa:	8b 55 10             	mov    0x10(%ebp),%edx
  800afd:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aff:	85 d2                	test   %edx,%edx
  800b01:	74 21                	je     800b24 <strlcpy+0x39>
  800b03:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b07:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800b09:	39 c2                	cmp    %eax,%edx
  800b0b:	74 14                	je     800b21 <strlcpy+0x36>
  800b0d:	0f b6 19             	movzbl (%ecx),%ebx
  800b10:	84 db                	test   %bl,%bl
  800b12:	74 0b                	je     800b1f <strlcpy+0x34>
			*dst++ = *src++;
  800b14:	83 c1 01             	add    $0x1,%ecx
  800b17:	83 c2 01             	add    $0x1,%edx
  800b1a:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b1d:	eb ea                	jmp    800b09 <strlcpy+0x1e>
  800b1f:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b21:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b24:	29 f0                	sub    %esi,%eax
}
  800b26:	5b                   	pop    %ebx
  800b27:	5e                   	pop    %esi
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    

00800b2a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b2a:	f3 0f 1e fb          	endbr32 
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b34:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b37:	0f b6 01             	movzbl (%ecx),%eax
  800b3a:	84 c0                	test   %al,%al
  800b3c:	74 0c                	je     800b4a <strcmp+0x20>
  800b3e:	3a 02                	cmp    (%edx),%al
  800b40:	75 08                	jne    800b4a <strcmp+0x20>
		p++, q++;
  800b42:	83 c1 01             	add    $0x1,%ecx
  800b45:	83 c2 01             	add    $0x1,%edx
  800b48:	eb ed                	jmp    800b37 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b4a:	0f b6 c0             	movzbl %al,%eax
  800b4d:	0f b6 12             	movzbl (%edx),%edx
  800b50:	29 d0                	sub    %edx,%eax
}
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b54:	f3 0f 1e fb          	endbr32 
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	53                   	push   %ebx
  800b5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b62:	89 c3                	mov    %eax,%ebx
  800b64:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b67:	eb 06                	jmp    800b6f <strncmp+0x1b>
		n--, p++, q++;
  800b69:	83 c0 01             	add    $0x1,%eax
  800b6c:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b6f:	39 d8                	cmp    %ebx,%eax
  800b71:	74 16                	je     800b89 <strncmp+0x35>
  800b73:	0f b6 08             	movzbl (%eax),%ecx
  800b76:	84 c9                	test   %cl,%cl
  800b78:	74 04                	je     800b7e <strncmp+0x2a>
  800b7a:	3a 0a                	cmp    (%edx),%cl
  800b7c:	74 eb                	je     800b69 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b7e:	0f b6 00             	movzbl (%eax),%eax
  800b81:	0f b6 12             	movzbl (%edx),%edx
  800b84:	29 d0                	sub    %edx,%eax
}
  800b86:	5b                   	pop    %ebx
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    
		return 0;
  800b89:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8e:	eb f6                	jmp    800b86 <strncmp+0x32>

00800b90 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b90:	f3 0f 1e fb          	endbr32 
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b9e:	0f b6 10             	movzbl (%eax),%edx
  800ba1:	84 d2                	test   %dl,%dl
  800ba3:	74 09                	je     800bae <strchr+0x1e>
		if (*s == c)
  800ba5:	38 ca                	cmp    %cl,%dl
  800ba7:	74 0a                	je     800bb3 <strchr+0x23>
	for (; *s; s++)
  800ba9:	83 c0 01             	add    $0x1,%eax
  800bac:	eb f0                	jmp    800b9e <strchr+0xe>
			return (char *) s;
	return 0;
  800bae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bb5:	f3 0f 1e fb          	endbr32 
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bc3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bc6:	38 ca                	cmp    %cl,%dl
  800bc8:	74 09                	je     800bd3 <strfind+0x1e>
  800bca:	84 d2                	test   %dl,%dl
  800bcc:	74 05                	je     800bd3 <strfind+0x1e>
	for (; *s; s++)
  800bce:	83 c0 01             	add    $0x1,%eax
  800bd1:	eb f0                	jmp    800bc3 <strfind+0xe>
			break;
	return (char *) s;
}
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    

00800bd5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bd5:	f3 0f 1e fb          	endbr32 
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	57                   	push   %edi
  800bdd:	56                   	push   %esi
  800bde:	53                   	push   %ebx
  800bdf:	8b 7d 08             	mov    0x8(%ebp),%edi
  800be2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800be5:	85 c9                	test   %ecx,%ecx
  800be7:	74 31                	je     800c1a <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800be9:	89 f8                	mov    %edi,%eax
  800beb:	09 c8                	or     %ecx,%eax
  800bed:	a8 03                	test   $0x3,%al
  800bef:	75 23                	jne    800c14 <memset+0x3f>
		c &= 0xFF;
  800bf1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bf5:	89 d3                	mov    %edx,%ebx
  800bf7:	c1 e3 08             	shl    $0x8,%ebx
  800bfa:	89 d0                	mov    %edx,%eax
  800bfc:	c1 e0 18             	shl    $0x18,%eax
  800bff:	89 d6                	mov    %edx,%esi
  800c01:	c1 e6 10             	shl    $0x10,%esi
  800c04:	09 f0                	or     %esi,%eax
  800c06:	09 c2                	or     %eax,%edx
  800c08:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c0a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c0d:	89 d0                	mov    %edx,%eax
  800c0f:	fc                   	cld    
  800c10:	f3 ab                	rep stos %eax,%es:(%edi)
  800c12:	eb 06                	jmp    800c1a <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c14:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c17:	fc                   	cld    
  800c18:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c1a:	89 f8                	mov    %edi,%eax
  800c1c:	5b                   	pop    %ebx
  800c1d:	5e                   	pop    %esi
  800c1e:	5f                   	pop    %edi
  800c1f:	5d                   	pop    %ebp
  800c20:	c3                   	ret    

00800c21 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c21:	f3 0f 1e fb          	endbr32 
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c30:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c33:	39 c6                	cmp    %eax,%esi
  800c35:	73 32                	jae    800c69 <memmove+0x48>
  800c37:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c3a:	39 c2                	cmp    %eax,%edx
  800c3c:	76 2b                	jbe    800c69 <memmove+0x48>
		s += n;
		d += n;
  800c3e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c41:	89 fe                	mov    %edi,%esi
  800c43:	09 ce                	or     %ecx,%esi
  800c45:	09 d6                	or     %edx,%esi
  800c47:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c4d:	75 0e                	jne    800c5d <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c4f:	83 ef 04             	sub    $0x4,%edi
  800c52:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c55:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c58:	fd                   	std    
  800c59:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c5b:	eb 09                	jmp    800c66 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c5d:	83 ef 01             	sub    $0x1,%edi
  800c60:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c63:	fd                   	std    
  800c64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c66:	fc                   	cld    
  800c67:	eb 1a                	jmp    800c83 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c69:	89 c2                	mov    %eax,%edx
  800c6b:	09 ca                	or     %ecx,%edx
  800c6d:	09 f2                	or     %esi,%edx
  800c6f:	f6 c2 03             	test   $0x3,%dl
  800c72:	75 0a                	jne    800c7e <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c74:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c77:	89 c7                	mov    %eax,%edi
  800c79:	fc                   	cld    
  800c7a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c7c:	eb 05                	jmp    800c83 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c7e:	89 c7                	mov    %eax,%edi
  800c80:	fc                   	cld    
  800c81:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    

00800c87 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c87:	f3 0f 1e fb          	endbr32 
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c91:	ff 75 10             	pushl  0x10(%ebp)
  800c94:	ff 75 0c             	pushl  0xc(%ebp)
  800c97:	ff 75 08             	pushl  0x8(%ebp)
  800c9a:	e8 82 ff ff ff       	call   800c21 <memmove>
}
  800c9f:	c9                   	leave  
  800ca0:	c3                   	ret    

00800ca1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ca1:	f3 0f 1e fb          	endbr32 
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
  800caa:	8b 45 08             	mov    0x8(%ebp),%eax
  800cad:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cb0:	89 c6                	mov    %eax,%esi
  800cb2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cb5:	39 f0                	cmp    %esi,%eax
  800cb7:	74 1c                	je     800cd5 <memcmp+0x34>
		if (*s1 != *s2)
  800cb9:	0f b6 08             	movzbl (%eax),%ecx
  800cbc:	0f b6 1a             	movzbl (%edx),%ebx
  800cbf:	38 d9                	cmp    %bl,%cl
  800cc1:	75 08                	jne    800ccb <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800cc3:	83 c0 01             	add    $0x1,%eax
  800cc6:	83 c2 01             	add    $0x1,%edx
  800cc9:	eb ea                	jmp    800cb5 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800ccb:	0f b6 c1             	movzbl %cl,%eax
  800cce:	0f b6 db             	movzbl %bl,%ebx
  800cd1:	29 d8                	sub    %ebx,%eax
  800cd3:	eb 05                	jmp    800cda <memcmp+0x39>
	}

	return 0;
  800cd5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5d                   	pop    %ebp
  800cdd:	c3                   	ret    

00800cde <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cde:	f3 0f 1e fb          	endbr32 
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ceb:	89 c2                	mov    %eax,%edx
  800ced:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cf0:	39 d0                	cmp    %edx,%eax
  800cf2:	73 09                	jae    800cfd <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cf4:	38 08                	cmp    %cl,(%eax)
  800cf6:	74 05                	je     800cfd <memfind+0x1f>
	for (; s < ends; s++)
  800cf8:	83 c0 01             	add    $0x1,%eax
  800cfb:	eb f3                	jmp    800cf0 <memfind+0x12>
			break;
	return (void *) s;
}
  800cfd:	5d                   	pop    %ebp
  800cfe:	c3                   	ret    

00800cff <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cff:	f3 0f 1e fb          	endbr32 
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	57                   	push   %edi
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
  800d09:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d0f:	eb 03                	jmp    800d14 <strtol+0x15>
		s++;
  800d11:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d14:	0f b6 01             	movzbl (%ecx),%eax
  800d17:	3c 20                	cmp    $0x20,%al
  800d19:	74 f6                	je     800d11 <strtol+0x12>
  800d1b:	3c 09                	cmp    $0x9,%al
  800d1d:	74 f2                	je     800d11 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d1f:	3c 2b                	cmp    $0x2b,%al
  800d21:	74 2a                	je     800d4d <strtol+0x4e>
	int neg = 0;
  800d23:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d28:	3c 2d                	cmp    $0x2d,%al
  800d2a:	74 2b                	je     800d57 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d2c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d32:	75 0f                	jne    800d43 <strtol+0x44>
  800d34:	80 39 30             	cmpb   $0x30,(%ecx)
  800d37:	74 28                	je     800d61 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d39:	85 db                	test   %ebx,%ebx
  800d3b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d40:	0f 44 d8             	cmove  %eax,%ebx
  800d43:	b8 00 00 00 00       	mov    $0x0,%eax
  800d48:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d4b:	eb 46                	jmp    800d93 <strtol+0x94>
		s++;
  800d4d:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d50:	bf 00 00 00 00       	mov    $0x0,%edi
  800d55:	eb d5                	jmp    800d2c <strtol+0x2d>
		s++, neg = 1;
  800d57:	83 c1 01             	add    $0x1,%ecx
  800d5a:	bf 01 00 00 00       	mov    $0x1,%edi
  800d5f:	eb cb                	jmp    800d2c <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d61:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d65:	74 0e                	je     800d75 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d67:	85 db                	test   %ebx,%ebx
  800d69:	75 d8                	jne    800d43 <strtol+0x44>
		s++, base = 8;
  800d6b:	83 c1 01             	add    $0x1,%ecx
  800d6e:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d73:	eb ce                	jmp    800d43 <strtol+0x44>
		s += 2, base = 16;
  800d75:	83 c1 02             	add    $0x2,%ecx
  800d78:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d7d:	eb c4                	jmp    800d43 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d7f:	0f be d2             	movsbl %dl,%edx
  800d82:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d85:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d88:	7d 3a                	jge    800dc4 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d8a:	83 c1 01             	add    $0x1,%ecx
  800d8d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d91:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d93:	0f b6 11             	movzbl (%ecx),%edx
  800d96:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d99:	89 f3                	mov    %esi,%ebx
  800d9b:	80 fb 09             	cmp    $0x9,%bl
  800d9e:	76 df                	jbe    800d7f <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800da0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800da3:	89 f3                	mov    %esi,%ebx
  800da5:	80 fb 19             	cmp    $0x19,%bl
  800da8:	77 08                	ja     800db2 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800daa:	0f be d2             	movsbl %dl,%edx
  800dad:	83 ea 57             	sub    $0x57,%edx
  800db0:	eb d3                	jmp    800d85 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800db2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800db5:	89 f3                	mov    %esi,%ebx
  800db7:	80 fb 19             	cmp    $0x19,%bl
  800dba:	77 08                	ja     800dc4 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800dbc:	0f be d2             	movsbl %dl,%edx
  800dbf:	83 ea 37             	sub    $0x37,%edx
  800dc2:	eb c1                	jmp    800d85 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800dc4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dc8:	74 05                	je     800dcf <strtol+0xd0>
		*endptr = (char *) s;
  800dca:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dcd:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800dcf:	89 c2                	mov    %eax,%edx
  800dd1:	f7 da                	neg    %edx
  800dd3:	85 ff                	test   %edi,%edi
  800dd5:	0f 45 c2             	cmovne %edx,%eax
}
  800dd8:	5b                   	pop    %ebx
  800dd9:	5e                   	pop    %esi
  800dda:	5f                   	pop    %edi
  800ddb:	5d                   	pop    %ebp
  800ddc:	c3                   	ret    

00800ddd <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800ddd:	f3 0f 1e fb          	endbr32 
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800de7:	83 3d 64 40 80 00 00 	cmpl   $0x0,0x804064
  800dee:	74 0a                	je     800dfa <set_pgfault_handler+0x1d>
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);		//系统调用，设置进程的env_pgfault_upcall属性
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800df0:	8b 45 08             	mov    0x8(%ebp),%eax
  800df3:	a3 64 40 80 00       	mov    %eax,0x804064
}
  800df8:	c9                   	leave  
  800df9:	c3                   	ret    
		int r = sys_page_alloc(0, (void *)(UXSTACKTOP-PGSIZE), PTE_W | PTE_U | PTE_P);	//为当前进程分配异常栈
  800dfa:	83 ec 04             	sub    $0x4,%esp
  800dfd:	6a 07                	push   $0x7
  800dff:	68 00 f0 bf ee       	push   $0xeebff000
  800e04:	6a 00                	push   $0x0
  800e06:	e8 80 f3 ff ff       	call   80018b <sys_page_alloc>
		if (r < 0) {
  800e0b:	83 c4 10             	add    $0x10,%esp
  800e0e:	85 c0                	test   %eax,%eax
  800e10:	78 14                	js     800e26 <set_pgfault_handler+0x49>
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);		//系统调用，设置进程的env_pgfault_upcall属性
  800e12:	83 ec 08             	sub    $0x8,%esp
  800e15:	68 56 03 80 00       	push   $0x800356
  800e1a:	6a 00                	push   $0x0
  800e1c:	e8 83 f4 ff ff       	call   8002a4 <sys_env_set_pgfault_upcall>
  800e21:	83 c4 10             	add    $0x10,%esp
  800e24:	eb ca                	jmp    800df0 <set_pgfault_handler+0x13>
			panic("set_pgfault_handler:sys_page_alloc failed");;
  800e26:	83 ec 04             	sub    $0x4,%esp
  800e29:	68 44 13 80 00       	push   $0x801344
  800e2e:	6a 22                	push   $0x22
  800e30:	68 6e 13 80 00       	push   $0x80136e
  800e35:	e8 40 f5 ff ff       	call   80037a <_panic>
  800e3a:	66 90                	xchg   %ax,%ax
  800e3c:	66 90                	xchg   %ax,%ax
  800e3e:	66 90                	xchg   %ax,%ax

00800e40 <__udivdi3>:
  800e40:	f3 0f 1e fb          	endbr32 
  800e44:	55                   	push   %ebp
  800e45:	57                   	push   %edi
  800e46:	56                   	push   %esi
  800e47:	53                   	push   %ebx
  800e48:	83 ec 1c             	sub    $0x1c,%esp
  800e4b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e4f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e53:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e57:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e5b:	85 d2                	test   %edx,%edx
  800e5d:	75 19                	jne    800e78 <__udivdi3+0x38>
  800e5f:	39 f3                	cmp    %esi,%ebx
  800e61:	76 4d                	jbe    800eb0 <__udivdi3+0x70>
  800e63:	31 ff                	xor    %edi,%edi
  800e65:	89 e8                	mov    %ebp,%eax
  800e67:	89 f2                	mov    %esi,%edx
  800e69:	f7 f3                	div    %ebx
  800e6b:	89 fa                	mov    %edi,%edx
  800e6d:	83 c4 1c             	add    $0x1c,%esp
  800e70:	5b                   	pop    %ebx
  800e71:	5e                   	pop    %esi
  800e72:	5f                   	pop    %edi
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    
  800e75:	8d 76 00             	lea    0x0(%esi),%esi
  800e78:	39 f2                	cmp    %esi,%edx
  800e7a:	76 14                	jbe    800e90 <__udivdi3+0x50>
  800e7c:	31 ff                	xor    %edi,%edi
  800e7e:	31 c0                	xor    %eax,%eax
  800e80:	89 fa                	mov    %edi,%edx
  800e82:	83 c4 1c             	add    $0x1c,%esp
  800e85:	5b                   	pop    %ebx
  800e86:	5e                   	pop    %esi
  800e87:	5f                   	pop    %edi
  800e88:	5d                   	pop    %ebp
  800e89:	c3                   	ret    
  800e8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e90:	0f bd fa             	bsr    %edx,%edi
  800e93:	83 f7 1f             	xor    $0x1f,%edi
  800e96:	75 48                	jne    800ee0 <__udivdi3+0xa0>
  800e98:	39 f2                	cmp    %esi,%edx
  800e9a:	72 06                	jb     800ea2 <__udivdi3+0x62>
  800e9c:	31 c0                	xor    %eax,%eax
  800e9e:	39 eb                	cmp    %ebp,%ebx
  800ea0:	77 de                	ja     800e80 <__udivdi3+0x40>
  800ea2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea7:	eb d7                	jmp    800e80 <__udivdi3+0x40>
  800ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800eb0:	89 d9                	mov    %ebx,%ecx
  800eb2:	85 db                	test   %ebx,%ebx
  800eb4:	75 0b                	jne    800ec1 <__udivdi3+0x81>
  800eb6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ebb:	31 d2                	xor    %edx,%edx
  800ebd:	f7 f3                	div    %ebx
  800ebf:	89 c1                	mov    %eax,%ecx
  800ec1:	31 d2                	xor    %edx,%edx
  800ec3:	89 f0                	mov    %esi,%eax
  800ec5:	f7 f1                	div    %ecx
  800ec7:	89 c6                	mov    %eax,%esi
  800ec9:	89 e8                	mov    %ebp,%eax
  800ecb:	89 f7                	mov    %esi,%edi
  800ecd:	f7 f1                	div    %ecx
  800ecf:	89 fa                	mov    %edi,%edx
  800ed1:	83 c4 1c             	add    $0x1c,%esp
  800ed4:	5b                   	pop    %ebx
  800ed5:	5e                   	pop    %esi
  800ed6:	5f                   	pop    %edi
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    
  800ed9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ee0:	89 f9                	mov    %edi,%ecx
  800ee2:	b8 20 00 00 00       	mov    $0x20,%eax
  800ee7:	29 f8                	sub    %edi,%eax
  800ee9:	d3 e2                	shl    %cl,%edx
  800eeb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800eef:	89 c1                	mov    %eax,%ecx
  800ef1:	89 da                	mov    %ebx,%edx
  800ef3:	d3 ea                	shr    %cl,%edx
  800ef5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ef9:	09 d1                	or     %edx,%ecx
  800efb:	89 f2                	mov    %esi,%edx
  800efd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f01:	89 f9                	mov    %edi,%ecx
  800f03:	d3 e3                	shl    %cl,%ebx
  800f05:	89 c1                	mov    %eax,%ecx
  800f07:	d3 ea                	shr    %cl,%edx
  800f09:	89 f9                	mov    %edi,%ecx
  800f0b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f0f:	89 eb                	mov    %ebp,%ebx
  800f11:	d3 e6                	shl    %cl,%esi
  800f13:	89 c1                	mov    %eax,%ecx
  800f15:	d3 eb                	shr    %cl,%ebx
  800f17:	09 de                	or     %ebx,%esi
  800f19:	89 f0                	mov    %esi,%eax
  800f1b:	f7 74 24 08          	divl   0x8(%esp)
  800f1f:	89 d6                	mov    %edx,%esi
  800f21:	89 c3                	mov    %eax,%ebx
  800f23:	f7 64 24 0c          	mull   0xc(%esp)
  800f27:	39 d6                	cmp    %edx,%esi
  800f29:	72 15                	jb     800f40 <__udivdi3+0x100>
  800f2b:	89 f9                	mov    %edi,%ecx
  800f2d:	d3 e5                	shl    %cl,%ebp
  800f2f:	39 c5                	cmp    %eax,%ebp
  800f31:	73 04                	jae    800f37 <__udivdi3+0xf7>
  800f33:	39 d6                	cmp    %edx,%esi
  800f35:	74 09                	je     800f40 <__udivdi3+0x100>
  800f37:	89 d8                	mov    %ebx,%eax
  800f39:	31 ff                	xor    %edi,%edi
  800f3b:	e9 40 ff ff ff       	jmp    800e80 <__udivdi3+0x40>
  800f40:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f43:	31 ff                	xor    %edi,%edi
  800f45:	e9 36 ff ff ff       	jmp    800e80 <__udivdi3+0x40>
  800f4a:	66 90                	xchg   %ax,%ax
  800f4c:	66 90                	xchg   %ax,%ax
  800f4e:	66 90                	xchg   %ax,%ax

00800f50 <__umoddi3>:
  800f50:	f3 0f 1e fb          	endbr32 
  800f54:	55                   	push   %ebp
  800f55:	57                   	push   %edi
  800f56:	56                   	push   %esi
  800f57:	53                   	push   %ebx
  800f58:	83 ec 1c             	sub    $0x1c,%esp
  800f5b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800f5f:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f63:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f67:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f6b:	85 c0                	test   %eax,%eax
  800f6d:	75 19                	jne    800f88 <__umoddi3+0x38>
  800f6f:	39 df                	cmp    %ebx,%edi
  800f71:	76 5d                	jbe    800fd0 <__umoddi3+0x80>
  800f73:	89 f0                	mov    %esi,%eax
  800f75:	89 da                	mov    %ebx,%edx
  800f77:	f7 f7                	div    %edi
  800f79:	89 d0                	mov    %edx,%eax
  800f7b:	31 d2                	xor    %edx,%edx
  800f7d:	83 c4 1c             	add    $0x1c,%esp
  800f80:	5b                   	pop    %ebx
  800f81:	5e                   	pop    %esi
  800f82:	5f                   	pop    %edi
  800f83:	5d                   	pop    %ebp
  800f84:	c3                   	ret    
  800f85:	8d 76 00             	lea    0x0(%esi),%esi
  800f88:	89 f2                	mov    %esi,%edx
  800f8a:	39 d8                	cmp    %ebx,%eax
  800f8c:	76 12                	jbe    800fa0 <__umoddi3+0x50>
  800f8e:	89 f0                	mov    %esi,%eax
  800f90:	89 da                	mov    %ebx,%edx
  800f92:	83 c4 1c             	add    $0x1c,%esp
  800f95:	5b                   	pop    %ebx
  800f96:	5e                   	pop    %esi
  800f97:	5f                   	pop    %edi
  800f98:	5d                   	pop    %ebp
  800f99:	c3                   	ret    
  800f9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fa0:	0f bd e8             	bsr    %eax,%ebp
  800fa3:	83 f5 1f             	xor    $0x1f,%ebp
  800fa6:	75 50                	jne    800ff8 <__umoddi3+0xa8>
  800fa8:	39 d8                	cmp    %ebx,%eax
  800faa:	0f 82 e0 00 00 00    	jb     801090 <__umoddi3+0x140>
  800fb0:	89 d9                	mov    %ebx,%ecx
  800fb2:	39 f7                	cmp    %esi,%edi
  800fb4:	0f 86 d6 00 00 00    	jbe    801090 <__umoddi3+0x140>
  800fba:	89 d0                	mov    %edx,%eax
  800fbc:	89 ca                	mov    %ecx,%edx
  800fbe:	83 c4 1c             	add    $0x1c,%esp
  800fc1:	5b                   	pop    %ebx
  800fc2:	5e                   	pop    %esi
  800fc3:	5f                   	pop    %edi
  800fc4:	5d                   	pop    %ebp
  800fc5:	c3                   	ret    
  800fc6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fcd:	8d 76 00             	lea    0x0(%esi),%esi
  800fd0:	89 fd                	mov    %edi,%ebp
  800fd2:	85 ff                	test   %edi,%edi
  800fd4:	75 0b                	jne    800fe1 <__umoddi3+0x91>
  800fd6:	b8 01 00 00 00       	mov    $0x1,%eax
  800fdb:	31 d2                	xor    %edx,%edx
  800fdd:	f7 f7                	div    %edi
  800fdf:	89 c5                	mov    %eax,%ebp
  800fe1:	89 d8                	mov    %ebx,%eax
  800fe3:	31 d2                	xor    %edx,%edx
  800fe5:	f7 f5                	div    %ebp
  800fe7:	89 f0                	mov    %esi,%eax
  800fe9:	f7 f5                	div    %ebp
  800feb:	89 d0                	mov    %edx,%eax
  800fed:	31 d2                	xor    %edx,%edx
  800fef:	eb 8c                	jmp    800f7d <__umoddi3+0x2d>
  800ff1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ff8:	89 e9                	mov    %ebp,%ecx
  800ffa:	ba 20 00 00 00       	mov    $0x20,%edx
  800fff:	29 ea                	sub    %ebp,%edx
  801001:	d3 e0                	shl    %cl,%eax
  801003:	89 44 24 08          	mov    %eax,0x8(%esp)
  801007:	89 d1                	mov    %edx,%ecx
  801009:	89 f8                	mov    %edi,%eax
  80100b:	d3 e8                	shr    %cl,%eax
  80100d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801011:	89 54 24 04          	mov    %edx,0x4(%esp)
  801015:	8b 54 24 04          	mov    0x4(%esp),%edx
  801019:	09 c1                	or     %eax,%ecx
  80101b:	89 d8                	mov    %ebx,%eax
  80101d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801021:	89 e9                	mov    %ebp,%ecx
  801023:	d3 e7                	shl    %cl,%edi
  801025:	89 d1                	mov    %edx,%ecx
  801027:	d3 e8                	shr    %cl,%eax
  801029:	89 e9                	mov    %ebp,%ecx
  80102b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80102f:	d3 e3                	shl    %cl,%ebx
  801031:	89 c7                	mov    %eax,%edi
  801033:	89 d1                	mov    %edx,%ecx
  801035:	89 f0                	mov    %esi,%eax
  801037:	d3 e8                	shr    %cl,%eax
  801039:	89 e9                	mov    %ebp,%ecx
  80103b:	89 fa                	mov    %edi,%edx
  80103d:	d3 e6                	shl    %cl,%esi
  80103f:	09 d8                	or     %ebx,%eax
  801041:	f7 74 24 08          	divl   0x8(%esp)
  801045:	89 d1                	mov    %edx,%ecx
  801047:	89 f3                	mov    %esi,%ebx
  801049:	f7 64 24 0c          	mull   0xc(%esp)
  80104d:	89 c6                	mov    %eax,%esi
  80104f:	89 d7                	mov    %edx,%edi
  801051:	39 d1                	cmp    %edx,%ecx
  801053:	72 06                	jb     80105b <__umoddi3+0x10b>
  801055:	75 10                	jne    801067 <__umoddi3+0x117>
  801057:	39 c3                	cmp    %eax,%ebx
  801059:	73 0c                	jae    801067 <__umoddi3+0x117>
  80105b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80105f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801063:	89 d7                	mov    %edx,%edi
  801065:	89 c6                	mov    %eax,%esi
  801067:	89 ca                	mov    %ecx,%edx
  801069:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80106e:	29 f3                	sub    %esi,%ebx
  801070:	19 fa                	sbb    %edi,%edx
  801072:	89 d0                	mov    %edx,%eax
  801074:	d3 e0                	shl    %cl,%eax
  801076:	89 e9                	mov    %ebp,%ecx
  801078:	d3 eb                	shr    %cl,%ebx
  80107a:	d3 ea                	shr    %cl,%edx
  80107c:	09 d8                	or     %ebx,%eax
  80107e:	83 c4 1c             	add    $0x1c,%esp
  801081:	5b                   	pop    %ebx
  801082:	5e                   	pop    %esi
  801083:	5f                   	pop    %edi
  801084:	5d                   	pop    %ebp
  801085:	c3                   	ret    
  801086:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80108d:	8d 76 00             	lea    0x0(%esi),%esi
  801090:	29 fe                	sub    %edi,%esi
  801092:	19 c3                	sbb    %eax,%ebx
  801094:	89 f2                	mov    %esi,%edx
  801096:	89 d9                	mov    %ebx,%ecx
  801098:	e9 1d ff ff ff       	jmp    800fba <__umoddi3+0x6a>
