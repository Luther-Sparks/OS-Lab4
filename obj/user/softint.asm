
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
	asm volatile("int $14");	// page fault
  800037:	cd 0e                	int    $0xe
}
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	f3 0f 1e fb          	endbr32 
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800049:	e8 d9 00 00 00       	call   800127 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  800059:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005e:	a3 60 40 80 00       	mov    %eax,0x804060

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800063:	85 db                	test   %ebx,%ebx
  800065:	7e 07                	jle    80006e <libmain+0x34>
		binaryname = argv[0];
  800067:	8b 06                	mov    (%esi),%eax
  800069:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006e:	83 ec 08             	sub    $0x8,%esp
  800071:	56                   	push   %esi
  800072:	53                   	push   %ebx
  800073:	e8 bb ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800078:	e8 0a 00 00 00       	call   800087 <exit>
}
  80007d:	83 c4 10             	add    $0x10,%esp
  800080:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800083:	5b                   	pop    %ebx
  800084:	5e                   	pop    %esi
  800085:	5d                   	pop    %ebp
  800086:	c3                   	ret    

00800087 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800087:	f3 0f 1e fb          	endbr32 
  80008b:	55                   	push   %ebp
  80008c:	89 e5                	mov    %esp,%ebp
  80008e:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800091:	6a 00                	push   $0x0
  800093:	e8 4a 00 00 00       	call   8000e2 <sys_env_destroy>
}
  800098:	83 c4 10             	add    $0x10,%esp
  80009b:	c9                   	leave  
  80009c:	c3                   	ret    

0080009d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009d:	f3 0f 1e fb          	endbr32 
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	57                   	push   %edi
  8000a5:	56                   	push   %esi
  8000a6:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8000a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8000af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b2:	89 c3                	mov    %eax,%ebx
  8000b4:	89 c7                	mov    %eax,%edi
  8000b6:	89 c6                	mov    %eax,%esi
  8000b8:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ba:	5b                   	pop    %ebx
  8000bb:	5e                   	pop    %esi
  8000bc:	5f                   	pop    %edi
  8000bd:	5d                   	pop    %ebp
  8000be:	c3                   	ret    

008000bf <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bf:	f3 0f 1e fb          	endbr32 
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	57                   	push   %edi
  8000c7:	56                   	push   %esi
  8000c8:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8000c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d3:	89 d1                	mov    %edx,%ecx
  8000d5:	89 d3                	mov    %edx,%ebx
  8000d7:	89 d7                	mov    %edx,%edi
  8000d9:	89 d6                	mov    %edx,%esi
  8000db:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000dd:	5b                   	pop    %ebx
  8000de:	5e                   	pop    %esi
  8000df:	5f                   	pop    %edi
  8000e0:	5d                   	pop    %ebp
  8000e1:	c3                   	ret    

008000e2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e2:	f3 0f 1e fb          	endbr32 
  8000e6:	55                   	push   %ebp
  8000e7:	89 e5                	mov    %esp,%ebp
  8000e9:	57                   	push   %edi
  8000ea:	56                   	push   %esi
  8000eb:	53                   	push   %ebx
  8000ec:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8000ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fc:	89 cb                	mov    %ecx,%ebx
  8000fe:	89 cf                	mov    %ecx,%edi
  800100:	89 ce                	mov    %ecx,%esi
  800102:	cd 30                	int    $0x30
	if(check && ret > 0)
  800104:	85 c0                	test   %eax,%eax
  800106:	7f 08                	jg     800110 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800108:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010b:	5b                   	pop    %ebx
  80010c:	5e                   	pop    %esi
  80010d:	5f                   	pop    %edi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800110:	83 ec 0c             	sub    $0xc,%esp
  800113:	50                   	push   %eax
  800114:	6a 03                	push   $0x3
  800116:	68 0a 10 80 00       	push   $0x80100a
  80011b:	6a 23                	push   $0x23
  80011d:	68 27 10 80 00       	push   $0x801027
  800122:	e8 11 02 00 00       	call   800338 <_panic>

00800127 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800127:	f3 0f 1e fb          	endbr32 
  80012b:	55                   	push   %ebp
  80012c:	89 e5                	mov    %esp,%ebp
  80012e:	57                   	push   %edi
  80012f:	56                   	push   %esi
  800130:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800131:	ba 00 00 00 00       	mov    $0x0,%edx
  800136:	b8 02 00 00 00       	mov    $0x2,%eax
  80013b:	89 d1                	mov    %edx,%ecx
  80013d:	89 d3                	mov    %edx,%ebx
  80013f:	89 d7                	mov    %edx,%edi
  800141:	89 d6                	mov    %edx,%esi
  800143:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800145:	5b                   	pop    %ebx
  800146:	5e                   	pop    %esi
  800147:	5f                   	pop    %edi
  800148:	5d                   	pop    %ebp
  800149:	c3                   	ret    

0080014a <sys_yield>:

void
sys_yield(void)
{
  80014a:	f3 0f 1e fb          	endbr32 
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	57                   	push   %edi
  800152:	56                   	push   %esi
  800153:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800154:	ba 00 00 00 00       	mov    $0x0,%edx
  800159:	b8 0a 00 00 00       	mov    $0xa,%eax
  80015e:	89 d1                	mov    %edx,%ecx
  800160:	89 d3                	mov    %edx,%ebx
  800162:	89 d7                	mov    %edx,%edi
  800164:	89 d6                	mov    %edx,%esi
  800166:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800168:	5b                   	pop    %ebx
  800169:	5e                   	pop    %esi
  80016a:	5f                   	pop    %edi
  80016b:	5d                   	pop    %ebp
  80016c:	c3                   	ret    

0080016d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016d:	f3 0f 1e fb          	endbr32 
  800171:	55                   	push   %ebp
  800172:	89 e5                	mov    %esp,%ebp
  800174:	57                   	push   %edi
  800175:	56                   	push   %esi
  800176:	53                   	push   %ebx
  800177:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  80017a:	be 00 00 00 00       	mov    $0x0,%esi
  80017f:	8b 55 08             	mov    0x8(%ebp),%edx
  800182:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800185:	b8 04 00 00 00       	mov    $0x4,%eax
  80018a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018d:	89 f7                	mov    %esi,%edi
  80018f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800191:	85 c0                	test   %eax,%eax
  800193:	7f 08                	jg     80019d <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800195:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800198:	5b                   	pop    %ebx
  800199:	5e                   	pop    %esi
  80019a:	5f                   	pop    %edi
  80019b:	5d                   	pop    %ebp
  80019c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80019d:	83 ec 0c             	sub    $0xc,%esp
  8001a0:	50                   	push   %eax
  8001a1:	6a 04                	push   $0x4
  8001a3:	68 0a 10 80 00       	push   $0x80100a
  8001a8:	6a 23                	push   $0x23
  8001aa:	68 27 10 80 00       	push   $0x801027
  8001af:	e8 84 01 00 00       	call   800338 <_panic>

008001b4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b4:	f3 0f 1e fb          	endbr32 
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	57                   	push   %edi
  8001bc:	56                   	push   %esi
  8001bd:	53                   	push   %ebx
  8001be:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8001c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c7:	b8 05 00 00 00       	mov    $0x5,%eax
  8001cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001cf:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d2:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d5:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001d7:	85 c0                	test   %eax,%eax
  8001d9:	7f 08                	jg     8001e3 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001de:	5b                   	pop    %ebx
  8001df:	5e                   	pop    %esi
  8001e0:	5f                   	pop    %edi
  8001e1:	5d                   	pop    %ebp
  8001e2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e3:	83 ec 0c             	sub    $0xc,%esp
  8001e6:	50                   	push   %eax
  8001e7:	6a 05                	push   $0x5
  8001e9:	68 0a 10 80 00       	push   $0x80100a
  8001ee:	6a 23                	push   $0x23
  8001f0:	68 27 10 80 00       	push   $0x801027
  8001f5:	e8 3e 01 00 00       	call   800338 <_panic>

008001fa <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001fa:	f3 0f 1e fb          	endbr32 
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	57                   	push   %edi
  800202:	56                   	push   %esi
  800203:	53                   	push   %ebx
  800204:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800207:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020c:	8b 55 08             	mov    0x8(%ebp),%edx
  80020f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800212:	b8 06 00 00 00       	mov    $0x6,%eax
  800217:	89 df                	mov    %ebx,%edi
  800219:	89 de                	mov    %ebx,%esi
  80021b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80021d:	85 c0                	test   %eax,%eax
  80021f:	7f 08                	jg     800229 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800221:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800224:	5b                   	pop    %ebx
  800225:	5e                   	pop    %esi
  800226:	5f                   	pop    %edi
  800227:	5d                   	pop    %ebp
  800228:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800229:	83 ec 0c             	sub    $0xc,%esp
  80022c:	50                   	push   %eax
  80022d:	6a 06                	push   $0x6
  80022f:	68 0a 10 80 00       	push   $0x80100a
  800234:	6a 23                	push   $0x23
  800236:	68 27 10 80 00       	push   $0x801027
  80023b:	e8 f8 00 00 00       	call   800338 <_panic>

00800240 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800240:	f3 0f 1e fb          	endbr32 
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	57                   	push   %edi
  800248:	56                   	push   %esi
  800249:	53                   	push   %ebx
  80024a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  80024d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800252:	8b 55 08             	mov    0x8(%ebp),%edx
  800255:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800258:	b8 08 00 00 00       	mov    $0x8,%eax
  80025d:	89 df                	mov    %ebx,%edi
  80025f:	89 de                	mov    %ebx,%esi
  800261:	cd 30                	int    $0x30
	if(check && ret > 0)
  800263:	85 c0                	test   %eax,%eax
  800265:	7f 08                	jg     80026f <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800267:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80026f:	83 ec 0c             	sub    $0xc,%esp
  800272:	50                   	push   %eax
  800273:	6a 08                	push   $0x8
  800275:	68 0a 10 80 00       	push   $0x80100a
  80027a:	6a 23                	push   $0x23
  80027c:	68 27 10 80 00       	push   $0x801027
  800281:	e8 b2 00 00 00       	call   800338 <_panic>

00800286 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800286:	f3 0f 1e fb          	endbr32 
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800293:	bb 00 00 00 00       	mov    $0x0,%ebx
  800298:	8b 55 08             	mov    0x8(%ebp),%edx
  80029b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80029e:	b8 09 00 00 00       	mov    $0x9,%eax
  8002a3:	89 df                	mov    %ebx,%edi
  8002a5:	89 de                	mov    %ebx,%esi
  8002a7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002a9:	85 c0                	test   %eax,%eax
  8002ab:	7f 08                	jg     8002b5 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b0:	5b                   	pop    %ebx
  8002b1:	5e                   	pop    %esi
  8002b2:	5f                   	pop    %edi
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b5:	83 ec 0c             	sub    $0xc,%esp
  8002b8:	50                   	push   %eax
  8002b9:	6a 09                	push   $0x9
  8002bb:	68 0a 10 80 00       	push   $0x80100a
  8002c0:	6a 23                	push   $0x23
  8002c2:	68 27 10 80 00       	push   $0x801027
  8002c7:	e8 6c 00 00 00       	call   800338 <_panic>

008002cc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002cc:	f3 0f 1e fb          	endbr32 
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	57                   	push   %edi
  8002d4:	56                   	push   %esi
  8002d5:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8002d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002dc:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002e1:	be 00 00 00 00       	mov    $0x0,%esi
  8002e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002e9:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002ec:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002ee:	5b                   	pop    %ebx
  8002ef:	5e                   	pop    %esi
  8002f0:	5f                   	pop    %edi
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    

008002f3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002f3:	f3 0f 1e fb          	endbr32 
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	57                   	push   %edi
  8002fb:	56                   	push   %esi
  8002fc:	53                   	push   %ebx
  8002fd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800300:	b9 00 00 00 00       	mov    $0x0,%ecx
  800305:	8b 55 08             	mov    0x8(%ebp),%edx
  800308:	b8 0c 00 00 00       	mov    $0xc,%eax
  80030d:	89 cb                	mov    %ecx,%ebx
  80030f:	89 cf                	mov    %ecx,%edi
  800311:	89 ce                	mov    %ecx,%esi
  800313:	cd 30                	int    $0x30
	if(check && ret > 0)
  800315:	85 c0                	test   %eax,%eax
  800317:	7f 08                	jg     800321 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800319:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80031c:	5b                   	pop    %ebx
  80031d:	5e                   	pop    %esi
  80031e:	5f                   	pop    %edi
  80031f:	5d                   	pop    %ebp
  800320:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800321:	83 ec 0c             	sub    $0xc,%esp
  800324:	50                   	push   %eax
  800325:	6a 0c                	push   $0xc
  800327:	68 0a 10 80 00       	push   $0x80100a
  80032c:	6a 23                	push   $0x23
  80032e:	68 27 10 80 00       	push   $0x801027
  800333:	e8 00 00 00 00       	call   800338 <_panic>

00800338 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800338:	f3 0f 1e fb          	endbr32 
  80033c:	55                   	push   %ebp
  80033d:	89 e5                	mov    %esp,%ebp
  80033f:	56                   	push   %esi
  800340:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800341:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800344:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80034a:	e8 d8 fd ff ff       	call   800127 <sys_getenvid>
  80034f:	83 ec 0c             	sub    $0xc,%esp
  800352:	ff 75 0c             	pushl  0xc(%ebp)
  800355:	ff 75 08             	pushl  0x8(%ebp)
  800358:	56                   	push   %esi
  800359:	50                   	push   %eax
  80035a:	68 38 10 80 00       	push   $0x801038
  80035f:	e8 bb 00 00 00       	call   80041f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800364:	83 c4 18             	add    $0x18,%esp
  800367:	53                   	push   %ebx
  800368:	ff 75 10             	pushl  0x10(%ebp)
  80036b:	e8 5a 00 00 00       	call   8003ca <vcprintf>
	cprintf("\n");
  800370:	c7 04 24 5b 10 80 00 	movl   $0x80105b,(%esp)
  800377:	e8 a3 00 00 00       	call   80041f <cprintf>
  80037c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80037f:	cc                   	int3   
  800380:	eb fd                	jmp    80037f <_panic+0x47>

00800382 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800382:	f3 0f 1e fb          	endbr32 
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
  800389:	53                   	push   %ebx
  80038a:	83 ec 04             	sub    $0x4,%esp
  80038d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800390:	8b 13                	mov    (%ebx),%edx
  800392:	8d 42 01             	lea    0x1(%edx),%eax
  800395:	89 03                	mov    %eax,(%ebx)
  800397:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80039e:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a3:	74 09                	je     8003ae <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003a5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003ac:	c9                   	leave  
  8003ad:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003ae:	83 ec 08             	sub    $0x8,%esp
  8003b1:	68 ff 00 00 00       	push   $0xff
  8003b6:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b9:	50                   	push   %eax
  8003ba:	e8 de fc ff ff       	call   80009d <sys_cputs>
		b->idx = 0;
  8003bf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003c5:	83 c4 10             	add    $0x10,%esp
  8003c8:	eb db                	jmp    8003a5 <putch+0x23>

008003ca <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003ca:	f3 0f 1e fb          	endbr32 
  8003ce:	55                   	push   %ebp
  8003cf:	89 e5                	mov    %esp,%ebp
  8003d1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003d7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003de:	00 00 00 
	b.cnt = 0;
  8003e1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003e8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003eb:	ff 75 0c             	pushl  0xc(%ebp)
  8003ee:	ff 75 08             	pushl  0x8(%ebp)
  8003f1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003f7:	50                   	push   %eax
  8003f8:	68 82 03 80 00       	push   $0x800382
  8003fd:	e8 20 01 00 00       	call   800522 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800402:	83 c4 08             	add    $0x8,%esp
  800405:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80040b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800411:	50                   	push   %eax
  800412:	e8 86 fc ff ff       	call   80009d <sys_cputs>

	return b.cnt;
}
  800417:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80041d:	c9                   	leave  
  80041e:	c3                   	ret    

0080041f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80041f:	f3 0f 1e fb          	endbr32 
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
  800426:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800429:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80042c:	50                   	push   %eax
  80042d:	ff 75 08             	pushl  0x8(%ebp)
  800430:	e8 95 ff ff ff       	call   8003ca <vcprintf>
	va_end(ap);

	return cnt;
}
  800435:	c9                   	leave  
  800436:	c3                   	ret    

00800437 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800437:	55                   	push   %ebp
  800438:	89 e5                	mov    %esp,%ebp
  80043a:	57                   	push   %edi
  80043b:	56                   	push   %esi
  80043c:	53                   	push   %ebx
  80043d:	83 ec 1c             	sub    $0x1c,%esp
  800440:	89 c7                	mov    %eax,%edi
  800442:	89 d6                	mov    %edx,%esi
  800444:	8b 45 08             	mov    0x8(%ebp),%eax
  800447:	8b 55 0c             	mov    0xc(%ebp),%edx
  80044a:	89 d1                	mov    %edx,%ecx
  80044c:	89 c2                	mov    %eax,%edx
  80044e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800451:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800454:	8b 45 10             	mov    0x10(%ebp),%eax
  800457:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80045a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800464:	39 c2                	cmp    %eax,%edx
  800466:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800469:	72 3e                	jb     8004a9 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80046b:	83 ec 0c             	sub    $0xc,%esp
  80046e:	ff 75 18             	pushl  0x18(%ebp)
  800471:	83 eb 01             	sub    $0x1,%ebx
  800474:	53                   	push   %ebx
  800475:	50                   	push   %eax
  800476:	83 ec 08             	sub    $0x8,%esp
  800479:	ff 75 e4             	pushl  -0x1c(%ebp)
  80047c:	ff 75 e0             	pushl  -0x20(%ebp)
  80047f:	ff 75 dc             	pushl  -0x24(%ebp)
  800482:	ff 75 d8             	pushl  -0x28(%ebp)
  800485:	e8 16 09 00 00       	call   800da0 <__udivdi3>
  80048a:	83 c4 18             	add    $0x18,%esp
  80048d:	52                   	push   %edx
  80048e:	50                   	push   %eax
  80048f:	89 f2                	mov    %esi,%edx
  800491:	89 f8                	mov    %edi,%eax
  800493:	e8 9f ff ff ff       	call   800437 <printnum>
  800498:	83 c4 20             	add    $0x20,%esp
  80049b:	eb 13                	jmp    8004b0 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80049d:	83 ec 08             	sub    $0x8,%esp
  8004a0:	56                   	push   %esi
  8004a1:	ff 75 18             	pushl  0x18(%ebp)
  8004a4:	ff d7                	call   *%edi
  8004a6:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004a9:	83 eb 01             	sub    $0x1,%ebx
  8004ac:	85 db                	test   %ebx,%ebx
  8004ae:	7f ed                	jg     80049d <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004b0:	83 ec 08             	sub    $0x8,%esp
  8004b3:	56                   	push   %esi
  8004b4:	83 ec 04             	sub    $0x4,%esp
  8004b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8004bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8004c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c3:	e8 e8 09 00 00       	call   800eb0 <__umoddi3>
  8004c8:	83 c4 14             	add    $0x14,%esp
  8004cb:	0f be 80 5d 10 80 00 	movsbl 0x80105d(%eax),%eax
  8004d2:	50                   	push   %eax
  8004d3:	ff d7                	call   *%edi
}
  8004d5:	83 c4 10             	add    $0x10,%esp
  8004d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004db:	5b                   	pop    %ebx
  8004dc:	5e                   	pop    %esi
  8004dd:	5f                   	pop    %edi
  8004de:	5d                   	pop    %ebp
  8004df:	c3                   	ret    

008004e0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e0:	f3 0f 1e fb          	endbr32 
  8004e4:	55                   	push   %ebp
  8004e5:	89 e5                	mov    %esp,%ebp
  8004e7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ea:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ee:	8b 10                	mov    (%eax),%edx
  8004f0:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f3:	73 0a                	jae    8004ff <sprintputch+0x1f>
		*b->buf++ = ch;
  8004f5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004f8:	89 08                	mov    %ecx,(%eax)
  8004fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fd:	88 02                	mov    %al,(%edx)
}
  8004ff:	5d                   	pop    %ebp
  800500:	c3                   	ret    

00800501 <printfmt>:
{
  800501:	f3 0f 1e fb          	endbr32 
  800505:	55                   	push   %ebp
  800506:	89 e5                	mov    %esp,%ebp
  800508:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80050b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80050e:	50                   	push   %eax
  80050f:	ff 75 10             	pushl  0x10(%ebp)
  800512:	ff 75 0c             	pushl  0xc(%ebp)
  800515:	ff 75 08             	pushl  0x8(%ebp)
  800518:	e8 05 00 00 00       	call   800522 <vprintfmt>
}
  80051d:	83 c4 10             	add    $0x10,%esp
  800520:	c9                   	leave  
  800521:	c3                   	ret    

00800522 <vprintfmt>:
{
  800522:	f3 0f 1e fb          	endbr32 
  800526:	55                   	push   %ebp
  800527:	89 e5                	mov    %esp,%ebp
  800529:	57                   	push   %edi
  80052a:	56                   	push   %esi
  80052b:	53                   	push   %ebx
  80052c:	83 ec 3c             	sub    $0x3c,%esp
  80052f:	8b 75 08             	mov    0x8(%ebp),%esi
  800532:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800535:	8b 7d 10             	mov    0x10(%ebp),%edi
  800538:	e9 8e 03 00 00       	jmp    8008cb <vprintfmt+0x3a9>
		padc = ' ';
  80053d:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800541:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800548:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80054f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800556:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80055b:	8d 47 01             	lea    0x1(%edi),%eax
  80055e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800561:	0f b6 17             	movzbl (%edi),%edx
  800564:	8d 42 dd             	lea    -0x23(%edx),%eax
  800567:	3c 55                	cmp    $0x55,%al
  800569:	0f 87 df 03 00 00    	ja     80094e <vprintfmt+0x42c>
  80056f:	0f b6 c0             	movzbl %al,%eax
  800572:	3e ff 24 85 20 11 80 	notrack jmp *0x801120(,%eax,4)
  800579:	00 
  80057a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80057d:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800581:	eb d8                	jmp    80055b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800583:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800586:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80058a:	eb cf                	jmp    80055b <vprintfmt+0x39>
  80058c:	0f b6 d2             	movzbl %dl,%edx
  80058f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800592:	b8 00 00 00 00       	mov    $0x0,%eax
  800597:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80059a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80059d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005a1:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005a4:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005a7:	83 f9 09             	cmp    $0x9,%ecx
  8005aa:	77 55                	ja     800601 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005ac:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005af:	eb e9                	jmp    80059a <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8b 00                	mov    (%eax),%eax
  8005b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8d 40 04             	lea    0x4(%eax),%eax
  8005bf:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005c9:	79 90                	jns    80055b <vprintfmt+0x39>
				width = precision, precision = -1;
  8005cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005d8:	eb 81                	jmp    80055b <vprintfmt+0x39>
  8005da:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005dd:	85 c0                	test   %eax,%eax
  8005df:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e4:	0f 49 d0             	cmovns %eax,%edx
  8005e7:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005ed:	e9 69 ff ff ff       	jmp    80055b <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005f5:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8005fc:	e9 5a ff ff ff       	jmp    80055b <vprintfmt+0x39>
  800601:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800604:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800607:	eb bc                	jmp    8005c5 <vprintfmt+0xa3>
			lflag++;
  800609:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80060c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80060f:	e9 47 ff ff ff       	jmp    80055b <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8d 78 04             	lea    0x4(%eax),%edi
  80061a:	83 ec 08             	sub    $0x8,%esp
  80061d:	53                   	push   %ebx
  80061e:	ff 30                	pushl  (%eax)
  800620:	ff d6                	call   *%esi
			break;
  800622:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800625:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800628:	e9 9b 02 00 00       	jmp    8008c8 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  80062d:	8b 45 14             	mov    0x14(%ebp),%eax
  800630:	8d 78 04             	lea    0x4(%eax),%edi
  800633:	8b 00                	mov    (%eax),%eax
  800635:	99                   	cltd   
  800636:	31 d0                	xor    %edx,%eax
  800638:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80063a:	83 f8 08             	cmp    $0x8,%eax
  80063d:	7f 23                	jg     800662 <vprintfmt+0x140>
  80063f:	8b 14 85 80 12 80 00 	mov    0x801280(,%eax,4),%edx
  800646:	85 d2                	test   %edx,%edx
  800648:	74 18                	je     800662 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80064a:	52                   	push   %edx
  80064b:	68 7e 10 80 00       	push   $0x80107e
  800650:	53                   	push   %ebx
  800651:	56                   	push   %esi
  800652:	e8 aa fe ff ff       	call   800501 <printfmt>
  800657:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80065a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80065d:	e9 66 02 00 00       	jmp    8008c8 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800662:	50                   	push   %eax
  800663:	68 75 10 80 00       	push   $0x801075
  800668:	53                   	push   %ebx
  800669:	56                   	push   %esi
  80066a:	e8 92 fe ff ff       	call   800501 <printfmt>
  80066f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800672:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800675:	e9 4e 02 00 00       	jmp    8008c8 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	83 c0 04             	add    $0x4,%eax
  800680:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800688:	85 d2                	test   %edx,%edx
  80068a:	b8 6e 10 80 00       	mov    $0x80106e,%eax
  80068f:	0f 45 c2             	cmovne %edx,%eax
  800692:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800695:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800699:	7e 06                	jle    8006a1 <vprintfmt+0x17f>
  80069b:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80069f:	75 0d                	jne    8006ae <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a1:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006a4:	89 c7                	mov    %eax,%edi
  8006a6:	03 45 e0             	add    -0x20(%ebp),%eax
  8006a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ac:	eb 55                	jmp    800703 <vprintfmt+0x1e1>
  8006ae:	83 ec 08             	sub    $0x8,%esp
  8006b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8006b4:	ff 75 cc             	pushl  -0x34(%ebp)
  8006b7:	e8 46 03 00 00       	call   800a02 <strnlen>
  8006bc:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006bf:	29 c2                	sub    %eax,%edx
  8006c1:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8006c4:	83 c4 10             	add    $0x10,%esp
  8006c7:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8006c9:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d0:	85 ff                	test   %edi,%edi
  8006d2:	7e 11                	jle    8006e5 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8006d4:	83 ec 08             	sub    $0x8,%esp
  8006d7:	53                   	push   %ebx
  8006d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006db:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006dd:	83 ef 01             	sub    $0x1,%edi
  8006e0:	83 c4 10             	add    $0x10,%esp
  8006e3:	eb eb                	jmp    8006d0 <vprintfmt+0x1ae>
  8006e5:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006e8:	85 d2                	test   %edx,%edx
  8006ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ef:	0f 49 c2             	cmovns %edx,%eax
  8006f2:	29 c2                	sub    %eax,%edx
  8006f4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006f7:	eb a8                	jmp    8006a1 <vprintfmt+0x17f>
					putch(ch, putdat);
  8006f9:	83 ec 08             	sub    $0x8,%esp
  8006fc:	53                   	push   %ebx
  8006fd:	52                   	push   %edx
  8006fe:	ff d6                	call   *%esi
  800700:	83 c4 10             	add    $0x10,%esp
  800703:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800706:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800708:	83 c7 01             	add    $0x1,%edi
  80070b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80070f:	0f be d0             	movsbl %al,%edx
  800712:	85 d2                	test   %edx,%edx
  800714:	74 4b                	je     800761 <vprintfmt+0x23f>
  800716:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80071a:	78 06                	js     800722 <vprintfmt+0x200>
  80071c:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800720:	78 1e                	js     800740 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800722:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800726:	74 d1                	je     8006f9 <vprintfmt+0x1d7>
  800728:	0f be c0             	movsbl %al,%eax
  80072b:	83 e8 20             	sub    $0x20,%eax
  80072e:	83 f8 5e             	cmp    $0x5e,%eax
  800731:	76 c6                	jbe    8006f9 <vprintfmt+0x1d7>
					putch('?', putdat);
  800733:	83 ec 08             	sub    $0x8,%esp
  800736:	53                   	push   %ebx
  800737:	6a 3f                	push   $0x3f
  800739:	ff d6                	call   *%esi
  80073b:	83 c4 10             	add    $0x10,%esp
  80073e:	eb c3                	jmp    800703 <vprintfmt+0x1e1>
  800740:	89 cf                	mov    %ecx,%edi
  800742:	eb 0e                	jmp    800752 <vprintfmt+0x230>
				putch(' ', putdat);
  800744:	83 ec 08             	sub    $0x8,%esp
  800747:	53                   	push   %ebx
  800748:	6a 20                	push   $0x20
  80074a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80074c:	83 ef 01             	sub    $0x1,%edi
  80074f:	83 c4 10             	add    $0x10,%esp
  800752:	85 ff                	test   %edi,%edi
  800754:	7f ee                	jg     800744 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800756:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800759:	89 45 14             	mov    %eax,0x14(%ebp)
  80075c:	e9 67 01 00 00       	jmp    8008c8 <vprintfmt+0x3a6>
  800761:	89 cf                	mov    %ecx,%edi
  800763:	eb ed                	jmp    800752 <vprintfmt+0x230>
	if (lflag >= 2)
  800765:	83 f9 01             	cmp    $0x1,%ecx
  800768:	7f 1b                	jg     800785 <vprintfmt+0x263>
	else if (lflag)
  80076a:	85 c9                	test   %ecx,%ecx
  80076c:	74 63                	je     8007d1 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  80076e:	8b 45 14             	mov    0x14(%ebp),%eax
  800771:	8b 00                	mov    (%eax),%eax
  800773:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800776:	99                   	cltd   
  800777:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80077a:	8b 45 14             	mov    0x14(%ebp),%eax
  80077d:	8d 40 04             	lea    0x4(%eax),%eax
  800780:	89 45 14             	mov    %eax,0x14(%ebp)
  800783:	eb 17                	jmp    80079c <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800785:	8b 45 14             	mov    0x14(%ebp),%eax
  800788:	8b 50 04             	mov    0x4(%eax),%edx
  80078b:	8b 00                	mov    (%eax),%eax
  80078d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800790:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800793:	8b 45 14             	mov    0x14(%ebp),%eax
  800796:	8d 40 08             	lea    0x8(%eax),%eax
  800799:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80079c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80079f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007a2:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007a7:	85 c9                	test   %ecx,%ecx
  8007a9:	0f 89 ff 00 00 00    	jns    8008ae <vprintfmt+0x38c>
				putch('-', putdat);
  8007af:	83 ec 08             	sub    $0x8,%esp
  8007b2:	53                   	push   %ebx
  8007b3:	6a 2d                	push   $0x2d
  8007b5:	ff d6                	call   *%esi
				num = -(long long) num;
  8007b7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007ba:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007bd:	f7 da                	neg    %edx
  8007bf:	83 d1 00             	adc    $0x0,%ecx
  8007c2:	f7 d9                	neg    %ecx
  8007c4:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007c7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007cc:	e9 dd 00 00 00       	jmp    8008ae <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8007d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d4:	8b 00                	mov    (%eax),%eax
  8007d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d9:	99                   	cltd   
  8007da:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e0:	8d 40 04             	lea    0x4(%eax),%eax
  8007e3:	89 45 14             	mov    %eax,0x14(%ebp)
  8007e6:	eb b4                	jmp    80079c <vprintfmt+0x27a>
	if (lflag >= 2)
  8007e8:	83 f9 01             	cmp    $0x1,%ecx
  8007eb:	7f 1e                	jg     80080b <vprintfmt+0x2e9>
	else if (lflag)
  8007ed:	85 c9                	test   %ecx,%ecx
  8007ef:	74 32                	je     800823 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8007f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f4:	8b 10                	mov    (%eax),%edx
  8007f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007fb:	8d 40 04             	lea    0x4(%eax),%eax
  8007fe:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800801:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800806:	e9 a3 00 00 00       	jmp    8008ae <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80080b:	8b 45 14             	mov    0x14(%ebp),%eax
  80080e:	8b 10                	mov    (%eax),%edx
  800810:	8b 48 04             	mov    0x4(%eax),%ecx
  800813:	8d 40 08             	lea    0x8(%eax),%eax
  800816:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800819:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80081e:	e9 8b 00 00 00       	jmp    8008ae <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800823:	8b 45 14             	mov    0x14(%ebp),%eax
  800826:	8b 10                	mov    (%eax),%edx
  800828:	b9 00 00 00 00       	mov    $0x0,%ecx
  80082d:	8d 40 04             	lea    0x4(%eax),%eax
  800830:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800833:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  800838:	eb 74                	jmp    8008ae <vprintfmt+0x38c>
	if (lflag >= 2)
  80083a:	83 f9 01             	cmp    $0x1,%ecx
  80083d:	7f 1b                	jg     80085a <vprintfmt+0x338>
	else if (lflag)
  80083f:	85 c9                	test   %ecx,%ecx
  800841:	74 2c                	je     80086f <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800843:	8b 45 14             	mov    0x14(%ebp),%eax
  800846:	8b 10                	mov    (%eax),%edx
  800848:	b9 00 00 00 00       	mov    $0x0,%ecx
  80084d:	8d 40 04             	lea    0x4(%eax),%eax
  800850:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800853:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  800858:	eb 54                	jmp    8008ae <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80085a:	8b 45 14             	mov    0x14(%ebp),%eax
  80085d:	8b 10                	mov    (%eax),%edx
  80085f:	8b 48 04             	mov    0x4(%eax),%ecx
  800862:	8d 40 08             	lea    0x8(%eax),%eax
  800865:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800868:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  80086d:	eb 3f                	jmp    8008ae <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  80086f:	8b 45 14             	mov    0x14(%ebp),%eax
  800872:	8b 10                	mov    (%eax),%edx
  800874:	b9 00 00 00 00       	mov    $0x0,%ecx
  800879:	8d 40 04             	lea    0x4(%eax),%eax
  80087c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80087f:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800884:	eb 28                	jmp    8008ae <vprintfmt+0x38c>
			putch('0', putdat);
  800886:	83 ec 08             	sub    $0x8,%esp
  800889:	53                   	push   %ebx
  80088a:	6a 30                	push   $0x30
  80088c:	ff d6                	call   *%esi
			putch('x', putdat);
  80088e:	83 c4 08             	add    $0x8,%esp
  800891:	53                   	push   %ebx
  800892:	6a 78                	push   $0x78
  800894:	ff d6                	call   *%esi
			num = (unsigned long long)
  800896:	8b 45 14             	mov    0x14(%ebp),%eax
  800899:	8b 10                	mov    (%eax),%edx
  80089b:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008a0:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008a3:	8d 40 04             	lea    0x4(%eax),%eax
  8008a6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008a9:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008ae:	83 ec 0c             	sub    $0xc,%esp
  8008b1:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8008b5:	57                   	push   %edi
  8008b6:	ff 75 e0             	pushl  -0x20(%ebp)
  8008b9:	50                   	push   %eax
  8008ba:	51                   	push   %ecx
  8008bb:	52                   	push   %edx
  8008bc:	89 da                	mov    %ebx,%edx
  8008be:	89 f0                	mov    %esi,%eax
  8008c0:	e8 72 fb ff ff       	call   800437 <printnum>
			break;
  8008c5:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8008c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {	
  8008cb:	83 c7 01             	add    $0x1,%edi
  8008ce:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008d2:	83 f8 25             	cmp    $0x25,%eax
  8008d5:	0f 84 62 fc ff ff    	je     80053d <vprintfmt+0x1b>
			if (ch == '\0')										
  8008db:	85 c0                	test   %eax,%eax
  8008dd:	0f 84 8b 00 00 00    	je     80096e <vprintfmt+0x44c>
			putch(ch, putdat);
  8008e3:	83 ec 08             	sub    $0x8,%esp
  8008e6:	53                   	push   %ebx
  8008e7:	50                   	push   %eax
  8008e8:	ff d6                	call   *%esi
  8008ea:	83 c4 10             	add    $0x10,%esp
  8008ed:	eb dc                	jmp    8008cb <vprintfmt+0x3a9>
	if (lflag >= 2)
  8008ef:	83 f9 01             	cmp    $0x1,%ecx
  8008f2:	7f 1b                	jg     80090f <vprintfmt+0x3ed>
	else if (lflag)
  8008f4:	85 c9                	test   %ecx,%ecx
  8008f6:	74 2c                	je     800924 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  8008f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fb:	8b 10                	mov    (%eax),%edx
  8008fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800902:	8d 40 04             	lea    0x4(%eax),%eax
  800905:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800908:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80090d:	eb 9f                	jmp    8008ae <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80090f:	8b 45 14             	mov    0x14(%ebp),%eax
  800912:	8b 10                	mov    (%eax),%edx
  800914:	8b 48 04             	mov    0x4(%eax),%ecx
  800917:	8d 40 08             	lea    0x8(%eax),%eax
  80091a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80091d:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800922:	eb 8a                	jmp    8008ae <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800924:	8b 45 14             	mov    0x14(%ebp),%eax
  800927:	8b 10                	mov    (%eax),%edx
  800929:	b9 00 00 00 00       	mov    $0x0,%ecx
  80092e:	8d 40 04             	lea    0x4(%eax),%eax
  800931:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800934:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  800939:	e9 70 ff ff ff       	jmp    8008ae <vprintfmt+0x38c>
			putch(ch, putdat);
  80093e:	83 ec 08             	sub    $0x8,%esp
  800941:	53                   	push   %ebx
  800942:	6a 25                	push   $0x25
  800944:	ff d6                	call   *%esi
			break;
  800946:	83 c4 10             	add    $0x10,%esp
  800949:	e9 7a ff ff ff       	jmp    8008c8 <vprintfmt+0x3a6>
			putch('%', putdat);
  80094e:	83 ec 08             	sub    $0x8,%esp
  800951:	53                   	push   %ebx
  800952:	6a 25                	push   $0x25
  800954:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800956:	83 c4 10             	add    $0x10,%esp
  800959:	89 f8                	mov    %edi,%eax
  80095b:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80095f:	74 05                	je     800966 <vprintfmt+0x444>
  800961:	83 e8 01             	sub    $0x1,%eax
  800964:	eb f5                	jmp    80095b <vprintfmt+0x439>
  800966:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800969:	e9 5a ff ff ff       	jmp    8008c8 <vprintfmt+0x3a6>
}
  80096e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800971:	5b                   	pop    %ebx
  800972:	5e                   	pop    %esi
  800973:	5f                   	pop    %edi
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800976:	f3 0f 1e fb          	endbr32 
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	83 ec 18             	sub    $0x18,%esp
  800980:	8b 45 08             	mov    0x8(%ebp),%eax
  800983:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800986:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800989:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80098d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800990:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800997:	85 c0                	test   %eax,%eax
  800999:	74 26                	je     8009c1 <vsnprintf+0x4b>
  80099b:	85 d2                	test   %edx,%edx
  80099d:	7e 22                	jle    8009c1 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80099f:	ff 75 14             	pushl  0x14(%ebp)
  8009a2:	ff 75 10             	pushl  0x10(%ebp)
  8009a5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009a8:	50                   	push   %eax
  8009a9:	68 e0 04 80 00       	push   $0x8004e0
  8009ae:	e8 6f fb ff ff       	call   800522 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009b6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009bc:	83 c4 10             	add    $0x10,%esp
}
  8009bf:	c9                   	leave  
  8009c0:	c3                   	ret    
		return -E_INVAL;
  8009c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009c6:	eb f7                	jmp    8009bf <vsnprintf+0x49>

008009c8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009c8:	f3 0f 1e fb          	endbr32 
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009d2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009d5:	50                   	push   %eax
  8009d6:	ff 75 10             	pushl  0x10(%ebp)
  8009d9:	ff 75 0c             	pushl  0xc(%ebp)
  8009dc:	ff 75 08             	pushl  0x8(%ebp)
  8009df:	e8 92 ff ff ff       	call   800976 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009e4:	c9                   	leave  
  8009e5:	c3                   	ret    

008009e6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009e6:	f3 0f 1e fb          	endbr32 
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009f9:	74 05                	je     800a00 <strlen+0x1a>
		n++;
  8009fb:	83 c0 01             	add    $0x1,%eax
  8009fe:	eb f5                	jmp    8009f5 <strlen+0xf>
	return n;
}
  800a00:	5d                   	pop    %ebp
  800a01:	c3                   	ret    

00800a02 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a02:	f3 0f 1e fb          	endbr32 
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a14:	39 d0                	cmp    %edx,%eax
  800a16:	74 0d                	je     800a25 <strnlen+0x23>
  800a18:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a1c:	74 05                	je     800a23 <strnlen+0x21>
		n++;
  800a1e:	83 c0 01             	add    $0x1,%eax
  800a21:	eb f1                	jmp    800a14 <strnlen+0x12>
  800a23:	89 c2                	mov    %eax,%edx
	return n;
}
  800a25:	89 d0                	mov    %edx,%eax
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a29:	f3 0f 1e fb          	endbr32 
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	53                   	push   %ebx
  800a31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a34:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a37:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3c:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a40:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a43:	83 c0 01             	add    $0x1,%eax
  800a46:	84 d2                	test   %dl,%dl
  800a48:	75 f2                	jne    800a3c <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a4a:	89 c8                	mov    %ecx,%eax
  800a4c:	5b                   	pop    %ebx
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    

00800a4f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a4f:	f3 0f 1e fb          	endbr32 
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	53                   	push   %ebx
  800a57:	83 ec 10             	sub    $0x10,%esp
  800a5a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a5d:	53                   	push   %ebx
  800a5e:	e8 83 ff ff ff       	call   8009e6 <strlen>
  800a63:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800a66:	ff 75 0c             	pushl  0xc(%ebp)
  800a69:	01 d8                	add    %ebx,%eax
  800a6b:	50                   	push   %eax
  800a6c:	e8 b8 ff ff ff       	call   800a29 <strcpy>
	return dst;
}
  800a71:	89 d8                	mov    %ebx,%eax
  800a73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a76:	c9                   	leave  
  800a77:	c3                   	ret    

00800a78 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a78:	f3 0f 1e fb          	endbr32 
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	56                   	push   %esi
  800a80:	53                   	push   %ebx
  800a81:	8b 75 08             	mov    0x8(%ebp),%esi
  800a84:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a87:	89 f3                	mov    %esi,%ebx
  800a89:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a8c:	89 f0                	mov    %esi,%eax
  800a8e:	39 d8                	cmp    %ebx,%eax
  800a90:	74 11                	je     800aa3 <strncpy+0x2b>
		*dst++ = *src;
  800a92:	83 c0 01             	add    $0x1,%eax
  800a95:	0f b6 0a             	movzbl (%edx),%ecx
  800a98:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a9b:	80 f9 01             	cmp    $0x1,%cl
  800a9e:	83 da ff             	sbb    $0xffffffff,%edx
  800aa1:	eb eb                	jmp    800a8e <strncpy+0x16>
	}
	return ret;
}
  800aa3:	89 f0                	mov    %esi,%eax
  800aa5:	5b                   	pop    %ebx
  800aa6:	5e                   	pop    %esi
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    

00800aa9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aa9:	f3 0f 1e fb          	endbr32 
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	56                   	push   %esi
  800ab1:	53                   	push   %ebx
  800ab2:	8b 75 08             	mov    0x8(%ebp),%esi
  800ab5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab8:	8b 55 10             	mov    0x10(%ebp),%edx
  800abb:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800abd:	85 d2                	test   %edx,%edx
  800abf:	74 21                	je     800ae2 <strlcpy+0x39>
  800ac1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800ac5:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800ac7:	39 c2                	cmp    %eax,%edx
  800ac9:	74 14                	je     800adf <strlcpy+0x36>
  800acb:	0f b6 19             	movzbl (%ecx),%ebx
  800ace:	84 db                	test   %bl,%bl
  800ad0:	74 0b                	je     800add <strlcpy+0x34>
			*dst++ = *src++;
  800ad2:	83 c1 01             	add    $0x1,%ecx
  800ad5:	83 c2 01             	add    $0x1,%edx
  800ad8:	88 5a ff             	mov    %bl,-0x1(%edx)
  800adb:	eb ea                	jmp    800ac7 <strlcpy+0x1e>
  800add:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800adf:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ae2:	29 f0                	sub    %esi,%eax
}
  800ae4:	5b                   	pop    %ebx
  800ae5:	5e                   	pop    %esi
  800ae6:	5d                   	pop    %ebp
  800ae7:	c3                   	ret    

00800ae8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ae8:	f3 0f 1e fb          	endbr32 
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800af5:	0f b6 01             	movzbl (%ecx),%eax
  800af8:	84 c0                	test   %al,%al
  800afa:	74 0c                	je     800b08 <strcmp+0x20>
  800afc:	3a 02                	cmp    (%edx),%al
  800afe:	75 08                	jne    800b08 <strcmp+0x20>
		p++, q++;
  800b00:	83 c1 01             	add    $0x1,%ecx
  800b03:	83 c2 01             	add    $0x1,%edx
  800b06:	eb ed                	jmp    800af5 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b08:	0f b6 c0             	movzbl %al,%eax
  800b0b:	0f b6 12             	movzbl (%edx),%edx
  800b0e:	29 d0                	sub    %edx,%eax
}
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b12:	f3 0f 1e fb          	endbr32 
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	53                   	push   %ebx
  800b1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b20:	89 c3                	mov    %eax,%ebx
  800b22:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b25:	eb 06                	jmp    800b2d <strncmp+0x1b>
		n--, p++, q++;
  800b27:	83 c0 01             	add    $0x1,%eax
  800b2a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b2d:	39 d8                	cmp    %ebx,%eax
  800b2f:	74 16                	je     800b47 <strncmp+0x35>
  800b31:	0f b6 08             	movzbl (%eax),%ecx
  800b34:	84 c9                	test   %cl,%cl
  800b36:	74 04                	je     800b3c <strncmp+0x2a>
  800b38:	3a 0a                	cmp    (%edx),%cl
  800b3a:	74 eb                	je     800b27 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b3c:	0f b6 00             	movzbl (%eax),%eax
  800b3f:	0f b6 12             	movzbl (%edx),%edx
  800b42:	29 d0                	sub    %edx,%eax
}
  800b44:	5b                   	pop    %ebx
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    
		return 0;
  800b47:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4c:	eb f6                	jmp    800b44 <strncmp+0x32>

00800b4e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b4e:	f3 0f 1e fb          	endbr32 
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	8b 45 08             	mov    0x8(%ebp),%eax
  800b58:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b5c:	0f b6 10             	movzbl (%eax),%edx
  800b5f:	84 d2                	test   %dl,%dl
  800b61:	74 09                	je     800b6c <strchr+0x1e>
		if (*s == c)
  800b63:	38 ca                	cmp    %cl,%dl
  800b65:	74 0a                	je     800b71 <strchr+0x23>
	for (; *s; s++)
  800b67:	83 c0 01             	add    $0x1,%eax
  800b6a:	eb f0                	jmp    800b5c <strchr+0xe>
			return (char *) s;
	return 0;
  800b6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b73:	f3 0f 1e fb          	endbr32 
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b81:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b84:	38 ca                	cmp    %cl,%dl
  800b86:	74 09                	je     800b91 <strfind+0x1e>
  800b88:	84 d2                	test   %dl,%dl
  800b8a:	74 05                	je     800b91 <strfind+0x1e>
	for (; *s; s++)
  800b8c:	83 c0 01             	add    $0x1,%eax
  800b8f:	eb f0                	jmp    800b81 <strfind+0xe>
			break;
	return (char *) s;
}
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    

00800b93 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b93:	f3 0f 1e fb          	endbr32 
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	57                   	push   %edi
  800b9b:	56                   	push   %esi
  800b9c:	53                   	push   %ebx
  800b9d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ba0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ba3:	85 c9                	test   %ecx,%ecx
  800ba5:	74 31                	je     800bd8 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ba7:	89 f8                	mov    %edi,%eax
  800ba9:	09 c8                	or     %ecx,%eax
  800bab:	a8 03                	test   $0x3,%al
  800bad:	75 23                	jne    800bd2 <memset+0x3f>
		c &= 0xFF;
  800baf:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bb3:	89 d3                	mov    %edx,%ebx
  800bb5:	c1 e3 08             	shl    $0x8,%ebx
  800bb8:	89 d0                	mov    %edx,%eax
  800bba:	c1 e0 18             	shl    $0x18,%eax
  800bbd:	89 d6                	mov    %edx,%esi
  800bbf:	c1 e6 10             	shl    $0x10,%esi
  800bc2:	09 f0                	or     %esi,%eax
  800bc4:	09 c2                	or     %eax,%edx
  800bc6:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bc8:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800bcb:	89 d0                	mov    %edx,%eax
  800bcd:	fc                   	cld    
  800bce:	f3 ab                	rep stos %eax,%es:(%edi)
  800bd0:	eb 06                	jmp    800bd8 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bd2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd5:	fc                   	cld    
  800bd6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bd8:	89 f8                	mov    %edi,%eax
  800bda:	5b                   	pop    %ebx
  800bdb:	5e                   	pop    %esi
  800bdc:	5f                   	pop    %edi
  800bdd:	5d                   	pop    %ebp
  800bde:	c3                   	ret    

00800bdf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bdf:	f3 0f 1e fb          	endbr32 
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	8b 45 08             	mov    0x8(%ebp),%eax
  800beb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bf1:	39 c6                	cmp    %eax,%esi
  800bf3:	73 32                	jae    800c27 <memmove+0x48>
  800bf5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bf8:	39 c2                	cmp    %eax,%edx
  800bfa:	76 2b                	jbe    800c27 <memmove+0x48>
		s += n;
		d += n;
  800bfc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bff:	89 fe                	mov    %edi,%esi
  800c01:	09 ce                	or     %ecx,%esi
  800c03:	09 d6                	or     %edx,%esi
  800c05:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c0b:	75 0e                	jne    800c1b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c0d:	83 ef 04             	sub    $0x4,%edi
  800c10:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c13:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c16:	fd                   	std    
  800c17:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c19:	eb 09                	jmp    800c24 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c1b:	83 ef 01             	sub    $0x1,%edi
  800c1e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c21:	fd                   	std    
  800c22:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c24:	fc                   	cld    
  800c25:	eb 1a                	jmp    800c41 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c27:	89 c2                	mov    %eax,%edx
  800c29:	09 ca                	or     %ecx,%edx
  800c2b:	09 f2                	or     %esi,%edx
  800c2d:	f6 c2 03             	test   $0x3,%dl
  800c30:	75 0a                	jne    800c3c <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c32:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c35:	89 c7                	mov    %eax,%edi
  800c37:	fc                   	cld    
  800c38:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c3a:	eb 05                	jmp    800c41 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c3c:	89 c7                	mov    %eax,%edi
  800c3e:	fc                   	cld    
  800c3f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c45:	f3 0f 1e fb          	endbr32 
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c4f:	ff 75 10             	pushl  0x10(%ebp)
  800c52:	ff 75 0c             	pushl  0xc(%ebp)
  800c55:	ff 75 08             	pushl  0x8(%ebp)
  800c58:	e8 82 ff ff ff       	call   800bdf <memmove>
}
  800c5d:	c9                   	leave  
  800c5e:	c3                   	ret    

00800c5f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c5f:	f3 0f 1e fb          	endbr32 
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	56                   	push   %esi
  800c67:	53                   	push   %ebx
  800c68:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c6e:	89 c6                	mov    %eax,%esi
  800c70:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c73:	39 f0                	cmp    %esi,%eax
  800c75:	74 1c                	je     800c93 <memcmp+0x34>
		if (*s1 != *s2)
  800c77:	0f b6 08             	movzbl (%eax),%ecx
  800c7a:	0f b6 1a             	movzbl (%edx),%ebx
  800c7d:	38 d9                	cmp    %bl,%cl
  800c7f:	75 08                	jne    800c89 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c81:	83 c0 01             	add    $0x1,%eax
  800c84:	83 c2 01             	add    $0x1,%edx
  800c87:	eb ea                	jmp    800c73 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800c89:	0f b6 c1             	movzbl %cl,%eax
  800c8c:	0f b6 db             	movzbl %bl,%ebx
  800c8f:	29 d8                	sub    %ebx,%eax
  800c91:	eb 05                	jmp    800c98 <memcmp+0x39>
	}

	return 0;
  800c93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c98:	5b                   	pop    %ebx
  800c99:	5e                   	pop    %esi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c9c:	f3 0f 1e fb          	endbr32 
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ca9:	89 c2                	mov    %eax,%edx
  800cab:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cae:	39 d0                	cmp    %edx,%eax
  800cb0:	73 09                	jae    800cbb <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cb2:	38 08                	cmp    %cl,(%eax)
  800cb4:	74 05                	je     800cbb <memfind+0x1f>
	for (; s < ends; s++)
  800cb6:	83 c0 01             	add    $0x1,%eax
  800cb9:	eb f3                	jmp    800cae <memfind+0x12>
			break;
	return (void *) s;
}
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    

00800cbd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cbd:	f3 0f 1e fb          	endbr32 
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ccd:	eb 03                	jmp    800cd2 <strtol+0x15>
		s++;
  800ccf:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800cd2:	0f b6 01             	movzbl (%ecx),%eax
  800cd5:	3c 20                	cmp    $0x20,%al
  800cd7:	74 f6                	je     800ccf <strtol+0x12>
  800cd9:	3c 09                	cmp    $0x9,%al
  800cdb:	74 f2                	je     800ccf <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800cdd:	3c 2b                	cmp    $0x2b,%al
  800cdf:	74 2a                	je     800d0b <strtol+0x4e>
	int neg = 0;
  800ce1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ce6:	3c 2d                	cmp    $0x2d,%al
  800ce8:	74 2b                	je     800d15 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cea:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cf0:	75 0f                	jne    800d01 <strtol+0x44>
  800cf2:	80 39 30             	cmpb   $0x30,(%ecx)
  800cf5:	74 28                	je     800d1f <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cf7:	85 db                	test   %ebx,%ebx
  800cf9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cfe:	0f 44 d8             	cmove  %eax,%ebx
  800d01:	b8 00 00 00 00       	mov    $0x0,%eax
  800d06:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d09:	eb 46                	jmp    800d51 <strtol+0x94>
		s++;
  800d0b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d0e:	bf 00 00 00 00       	mov    $0x0,%edi
  800d13:	eb d5                	jmp    800cea <strtol+0x2d>
		s++, neg = 1;
  800d15:	83 c1 01             	add    $0x1,%ecx
  800d18:	bf 01 00 00 00       	mov    $0x1,%edi
  800d1d:	eb cb                	jmp    800cea <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d1f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d23:	74 0e                	je     800d33 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d25:	85 db                	test   %ebx,%ebx
  800d27:	75 d8                	jne    800d01 <strtol+0x44>
		s++, base = 8;
  800d29:	83 c1 01             	add    $0x1,%ecx
  800d2c:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d31:	eb ce                	jmp    800d01 <strtol+0x44>
		s += 2, base = 16;
  800d33:	83 c1 02             	add    $0x2,%ecx
  800d36:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d3b:	eb c4                	jmp    800d01 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d3d:	0f be d2             	movsbl %dl,%edx
  800d40:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d43:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d46:	7d 3a                	jge    800d82 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d48:	83 c1 01             	add    $0x1,%ecx
  800d4b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d4f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d51:	0f b6 11             	movzbl (%ecx),%edx
  800d54:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d57:	89 f3                	mov    %esi,%ebx
  800d59:	80 fb 09             	cmp    $0x9,%bl
  800d5c:	76 df                	jbe    800d3d <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800d5e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d61:	89 f3                	mov    %esi,%ebx
  800d63:	80 fb 19             	cmp    $0x19,%bl
  800d66:	77 08                	ja     800d70 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800d68:	0f be d2             	movsbl %dl,%edx
  800d6b:	83 ea 57             	sub    $0x57,%edx
  800d6e:	eb d3                	jmp    800d43 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800d70:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d73:	89 f3                	mov    %esi,%ebx
  800d75:	80 fb 19             	cmp    $0x19,%bl
  800d78:	77 08                	ja     800d82 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d7a:	0f be d2             	movsbl %dl,%edx
  800d7d:	83 ea 37             	sub    $0x37,%edx
  800d80:	eb c1                	jmp    800d43 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d82:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d86:	74 05                	je     800d8d <strtol+0xd0>
		*endptr = (char *) s;
  800d88:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d8b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d8d:	89 c2                	mov    %eax,%edx
  800d8f:	f7 da                	neg    %edx
  800d91:	85 ff                	test   %edi,%edi
  800d93:	0f 45 c2             	cmovne %edx,%eax
}
  800d96:	5b                   	pop    %ebx
  800d97:	5e                   	pop    %esi
  800d98:	5f                   	pop    %edi
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    
  800d9b:	66 90                	xchg   %ax,%ax
  800d9d:	66 90                	xchg   %ax,%ax
  800d9f:	90                   	nop

00800da0 <__udivdi3>:
  800da0:	f3 0f 1e fb          	endbr32 
  800da4:	55                   	push   %ebp
  800da5:	57                   	push   %edi
  800da6:	56                   	push   %esi
  800da7:	53                   	push   %ebx
  800da8:	83 ec 1c             	sub    $0x1c,%esp
  800dab:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800daf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800db3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800db7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800dbb:	85 d2                	test   %edx,%edx
  800dbd:	75 19                	jne    800dd8 <__udivdi3+0x38>
  800dbf:	39 f3                	cmp    %esi,%ebx
  800dc1:	76 4d                	jbe    800e10 <__udivdi3+0x70>
  800dc3:	31 ff                	xor    %edi,%edi
  800dc5:	89 e8                	mov    %ebp,%eax
  800dc7:	89 f2                	mov    %esi,%edx
  800dc9:	f7 f3                	div    %ebx
  800dcb:	89 fa                	mov    %edi,%edx
  800dcd:	83 c4 1c             	add    $0x1c,%esp
  800dd0:	5b                   	pop    %ebx
  800dd1:	5e                   	pop    %esi
  800dd2:	5f                   	pop    %edi
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    
  800dd5:	8d 76 00             	lea    0x0(%esi),%esi
  800dd8:	39 f2                	cmp    %esi,%edx
  800dda:	76 14                	jbe    800df0 <__udivdi3+0x50>
  800ddc:	31 ff                	xor    %edi,%edi
  800dde:	31 c0                	xor    %eax,%eax
  800de0:	89 fa                	mov    %edi,%edx
  800de2:	83 c4 1c             	add    $0x1c,%esp
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    
  800dea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800df0:	0f bd fa             	bsr    %edx,%edi
  800df3:	83 f7 1f             	xor    $0x1f,%edi
  800df6:	75 48                	jne    800e40 <__udivdi3+0xa0>
  800df8:	39 f2                	cmp    %esi,%edx
  800dfa:	72 06                	jb     800e02 <__udivdi3+0x62>
  800dfc:	31 c0                	xor    %eax,%eax
  800dfe:	39 eb                	cmp    %ebp,%ebx
  800e00:	77 de                	ja     800de0 <__udivdi3+0x40>
  800e02:	b8 01 00 00 00       	mov    $0x1,%eax
  800e07:	eb d7                	jmp    800de0 <__udivdi3+0x40>
  800e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e10:	89 d9                	mov    %ebx,%ecx
  800e12:	85 db                	test   %ebx,%ebx
  800e14:	75 0b                	jne    800e21 <__udivdi3+0x81>
  800e16:	b8 01 00 00 00       	mov    $0x1,%eax
  800e1b:	31 d2                	xor    %edx,%edx
  800e1d:	f7 f3                	div    %ebx
  800e1f:	89 c1                	mov    %eax,%ecx
  800e21:	31 d2                	xor    %edx,%edx
  800e23:	89 f0                	mov    %esi,%eax
  800e25:	f7 f1                	div    %ecx
  800e27:	89 c6                	mov    %eax,%esi
  800e29:	89 e8                	mov    %ebp,%eax
  800e2b:	89 f7                	mov    %esi,%edi
  800e2d:	f7 f1                	div    %ecx
  800e2f:	89 fa                	mov    %edi,%edx
  800e31:	83 c4 1c             	add    $0x1c,%esp
  800e34:	5b                   	pop    %ebx
  800e35:	5e                   	pop    %esi
  800e36:	5f                   	pop    %edi
  800e37:	5d                   	pop    %ebp
  800e38:	c3                   	ret    
  800e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e40:	89 f9                	mov    %edi,%ecx
  800e42:	b8 20 00 00 00       	mov    $0x20,%eax
  800e47:	29 f8                	sub    %edi,%eax
  800e49:	d3 e2                	shl    %cl,%edx
  800e4b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e4f:	89 c1                	mov    %eax,%ecx
  800e51:	89 da                	mov    %ebx,%edx
  800e53:	d3 ea                	shr    %cl,%edx
  800e55:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e59:	09 d1                	or     %edx,%ecx
  800e5b:	89 f2                	mov    %esi,%edx
  800e5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e61:	89 f9                	mov    %edi,%ecx
  800e63:	d3 e3                	shl    %cl,%ebx
  800e65:	89 c1                	mov    %eax,%ecx
  800e67:	d3 ea                	shr    %cl,%edx
  800e69:	89 f9                	mov    %edi,%ecx
  800e6b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e6f:	89 eb                	mov    %ebp,%ebx
  800e71:	d3 e6                	shl    %cl,%esi
  800e73:	89 c1                	mov    %eax,%ecx
  800e75:	d3 eb                	shr    %cl,%ebx
  800e77:	09 de                	or     %ebx,%esi
  800e79:	89 f0                	mov    %esi,%eax
  800e7b:	f7 74 24 08          	divl   0x8(%esp)
  800e7f:	89 d6                	mov    %edx,%esi
  800e81:	89 c3                	mov    %eax,%ebx
  800e83:	f7 64 24 0c          	mull   0xc(%esp)
  800e87:	39 d6                	cmp    %edx,%esi
  800e89:	72 15                	jb     800ea0 <__udivdi3+0x100>
  800e8b:	89 f9                	mov    %edi,%ecx
  800e8d:	d3 e5                	shl    %cl,%ebp
  800e8f:	39 c5                	cmp    %eax,%ebp
  800e91:	73 04                	jae    800e97 <__udivdi3+0xf7>
  800e93:	39 d6                	cmp    %edx,%esi
  800e95:	74 09                	je     800ea0 <__udivdi3+0x100>
  800e97:	89 d8                	mov    %ebx,%eax
  800e99:	31 ff                	xor    %edi,%edi
  800e9b:	e9 40 ff ff ff       	jmp    800de0 <__udivdi3+0x40>
  800ea0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ea3:	31 ff                	xor    %edi,%edi
  800ea5:	e9 36 ff ff ff       	jmp    800de0 <__udivdi3+0x40>
  800eaa:	66 90                	xchg   %ax,%ax
  800eac:	66 90                	xchg   %ax,%ax
  800eae:	66 90                	xchg   %ax,%ax

00800eb0 <__umoddi3>:
  800eb0:	f3 0f 1e fb          	endbr32 
  800eb4:	55                   	push   %ebp
  800eb5:	57                   	push   %edi
  800eb6:	56                   	push   %esi
  800eb7:	53                   	push   %ebx
  800eb8:	83 ec 1c             	sub    $0x1c,%esp
  800ebb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800ebf:	8b 74 24 30          	mov    0x30(%esp),%esi
  800ec3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800ec7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ecb:	85 c0                	test   %eax,%eax
  800ecd:	75 19                	jne    800ee8 <__umoddi3+0x38>
  800ecf:	39 df                	cmp    %ebx,%edi
  800ed1:	76 5d                	jbe    800f30 <__umoddi3+0x80>
  800ed3:	89 f0                	mov    %esi,%eax
  800ed5:	89 da                	mov    %ebx,%edx
  800ed7:	f7 f7                	div    %edi
  800ed9:	89 d0                	mov    %edx,%eax
  800edb:	31 d2                	xor    %edx,%edx
  800edd:	83 c4 1c             	add    $0x1c,%esp
  800ee0:	5b                   	pop    %ebx
  800ee1:	5e                   	pop    %esi
  800ee2:	5f                   	pop    %edi
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    
  800ee5:	8d 76 00             	lea    0x0(%esi),%esi
  800ee8:	89 f2                	mov    %esi,%edx
  800eea:	39 d8                	cmp    %ebx,%eax
  800eec:	76 12                	jbe    800f00 <__umoddi3+0x50>
  800eee:	89 f0                	mov    %esi,%eax
  800ef0:	89 da                	mov    %ebx,%edx
  800ef2:	83 c4 1c             	add    $0x1c,%esp
  800ef5:	5b                   	pop    %ebx
  800ef6:	5e                   	pop    %esi
  800ef7:	5f                   	pop    %edi
  800ef8:	5d                   	pop    %ebp
  800ef9:	c3                   	ret    
  800efa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f00:	0f bd e8             	bsr    %eax,%ebp
  800f03:	83 f5 1f             	xor    $0x1f,%ebp
  800f06:	75 50                	jne    800f58 <__umoddi3+0xa8>
  800f08:	39 d8                	cmp    %ebx,%eax
  800f0a:	0f 82 e0 00 00 00    	jb     800ff0 <__umoddi3+0x140>
  800f10:	89 d9                	mov    %ebx,%ecx
  800f12:	39 f7                	cmp    %esi,%edi
  800f14:	0f 86 d6 00 00 00    	jbe    800ff0 <__umoddi3+0x140>
  800f1a:	89 d0                	mov    %edx,%eax
  800f1c:	89 ca                	mov    %ecx,%edx
  800f1e:	83 c4 1c             	add    $0x1c,%esp
  800f21:	5b                   	pop    %ebx
  800f22:	5e                   	pop    %esi
  800f23:	5f                   	pop    %edi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    
  800f26:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f2d:	8d 76 00             	lea    0x0(%esi),%esi
  800f30:	89 fd                	mov    %edi,%ebp
  800f32:	85 ff                	test   %edi,%edi
  800f34:	75 0b                	jne    800f41 <__umoddi3+0x91>
  800f36:	b8 01 00 00 00       	mov    $0x1,%eax
  800f3b:	31 d2                	xor    %edx,%edx
  800f3d:	f7 f7                	div    %edi
  800f3f:	89 c5                	mov    %eax,%ebp
  800f41:	89 d8                	mov    %ebx,%eax
  800f43:	31 d2                	xor    %edx,%edx
  800f45:	f7 f5                	div    %ebp
  800f47:	89 f0                	mov    %esi,%eax
  800f49:	f7 f5                	div    %ebp
  800f4b:	89 d0                	mov    %edx,%eax
  800f4d:	31 d2                	xor    %edx,%edx
  800f4f:	eb 8c                	jmp    800edd <__umoddi3+0x2d>
  800f51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f58:	89 e9                	mov    %ebp,%ecx
  800f5a:	ba 20 00 00 00       	mov    $0x20,%edx
  800f5f:	29 ea                	sub    %ebp,%edx
  800f61:	d3 e0                	shl    %cl,%eax
  800f63:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f67:	89 d1                	mov    %edx,%ecx
  800f69:	89 f8                	mov    %edi,%eax
  800f6b:	d3 e8                	shr    %cl,%eax
  800f6d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f71:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f75:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f79:	09 c1                	or     %eax,%ecx
  800f7b:	89 d8                	mov    %ebx,%eax
  800f7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f81:	89 e9                	mov    %ebp,%ecx
  800f83:	d3 e7                	shl    %cl,%edi
  800f85:	89 d1                	mov    %edx,%ecx
  800f87:	d3 e8                	shr    %cl,%eax
  800f89:	89 e9                	mov    %ebp,%ecx
  800f8b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800f8f:	d3 e3                	shl    %cl,%ebx
  800f91:	89 c7                	mov    %eax,%edi
  800f93:	89 d1                	mov    %edx,%ecx
  800f95:	89 f0                	mov    %esi,%eax
  800f97:	d3 e8                	shr    %cl,%eax
  800f99:	89 e9                	mov    %ebp,%ecx
  800f9b:	89 fa                	mov    %edi,%edx
  800f9d:	d3 e6                	shl    %cl,%esi
  800f9f:	09 d8                	or     %ebx,%eax
  800fa1:	f7 74 24 08          	divl   0x8(%esp)
  800fa5:	89 d1                	mov    %edx,%ecx
  800fa7:	89 f3                	mov    %esi,%ebx
  800fa9:	f7 64 24 0c          	mull   0xc(%esp)
  800fad:	89 c6                	mov    %eax,%esi
  800faf:	89 d7                	mov    %edx,%edi
  800fb1:	39 d1                	cmp    %edx,%ecx
  800fb3:	72 06                	jb     800fbb <__umoddi3+0x10b>
  800fb5:	75 10                	jne    800fc7 <__umoddi3+0x117>
  800fb7:	39 c3                	cmp    %eax,%ebx
  800fb9:	73 0c                	jae    800fc7 <__umoddi3+0x117>
  800fbb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800fbf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800fc3:	89 d7                	mov    %edx,%edi
  800fc5:	89 c6                	mov    %eax,%esi
  800fc7:	89 ca                	mov    %ecx,%edx
  800fc9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fce:	29 f3                	sub    %esi,%ebx
  800fd0:	19 fa                	sbb    %edi,%edx
  800fd2:	89 d0                	mov    %edx,%eax
  800fd4:	d3 e0                	shl    %cl,%eax
  800fd6:	89 e9                	mov    %ebp,%ecx
  800fd8:	d3 eb                	shr    %cl,%ebx
  800fda:	d3 ea                	shr    %cl,%edx
  800fdc:	09 d8                	or     %ebx,%eax
  800fde:	83 c4 1c             	add    $0x1c,%esp
  800fe1:	5b                   	pop    %ebx
  800fe2:	5e                   	pop    %esi
  800fe3:	5f                   	pop    %edi
  800fe4:	5d                   	pop    %ebp
  800fe5:	c3                   	ret    
  800fe6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fed:	8d 76 00             	lea    0x0(%esi),%esi
  800ff0:	29 fe                	sub    %edi,%esi
  800ff2:	19 c3                	sbb    %eax,%ebx
  800ff4:	89 f2                	mov    %esi,%edx
  800ff6:	89 d9                	mov    %ebx,%ecx
  800ff8:	e9 1d ff ff ff       	jmp    800f1a <__umoddi3+0x6a>
