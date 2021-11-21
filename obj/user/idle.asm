
obj/user/idle:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  80003d:	c7 05 00 20 80 00 20 	movl   $0x801020,0x802000
  800044:	10 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800047:	e8 12 01 00 00       	call   80015e <sys_yield>
  80004c:	eb f9                	jmp    800047 <umain+0x14>

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	f3 0f 1e fb          	endbr32 
  800052:	55                   	push   %ebp
  800053:	89 e5                	mov    %esp,%ebp
  800055:	56                   	push   %esi
  800056:	53                   	push   %ebx
  800057:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  80005d:	e8 d9 00 00 00       	call   80013b <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800062:	25 ff 03 00 00       	and    $0x3ff,%eax
  800067:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  80006d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800072:	a3 60 40 80 00       	mov    %eax,0x804060

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800077:	85 db                	test   %ebx,%ebx
  800079:	7e 07                	jle    800082 <libmain+0x34>
		binaryname = argv[0];
  80007b:	8b 06                	mov    (%esi),%eax
  80007d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800082:	83 ec 08             	sub    $0x8,%esp
  800085:	56                   	push   %esi
  800086:	53                   	push   %ebx
  800087:	e8 a7 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008c:	e8 0a 00 00 00       	call   80009b <exit>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800097:	5b                   	pop    %ebx
  800098:	5e                   	pop    %esi
  800099:	5d                   	pop    %ebp
  80009a:	c3                   	ret    

0080009b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009b:	f3 0f 1e fb          	endbr32 
  80009f:	55                   	push   %ebp
  8000a0:	89 e5                	mov    %esp,%ebp
  8000a2:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a5:	6a 00                	push   $0x0
  8000a7:	e8 4a 00 00 00       	call   8000f6 <sys_env_destroy>
}
  8000ac:	83 c4 10             	add    $0x10,%esp
  8000af:	c9                   	leave  
  8000b0:	c3                   	ret    

008000b1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b1:	f3 0f 1e fb          	endbr32 
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	57                   	push   %edi
  8000b9:	56                   	push   %esi
  8000ba:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8000bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c6:	89 c3                	mov    %eax,%ebx
  8000c8:	89 c7                	mov    %eax,%edi
  8000ca:	89 c6                	mov    %eax,%esi
  8000cc:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	5f                   	pop    %edi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d3:	f3 0f 1e fb          	endbr32 
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	57                   	push   %edi
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8000dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e7:	89 d1                	mov    %edx,%ecx
  8000e9:	89 d3                	mov    %edx,%ebx
  8000eb:	89 d7                	mov    %edx,%edi
  8000ed:	89 d6                	mov    %edx,%esi
  8000ef:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f1:	5b                   	pop    %ebx
  8000f2:	5e                   	pop    %esi
  8000f3:	5f                   	pop    %edi
  8000f4:	5d                   	pop    %ebp
  8000f5:	c3                   	ret    

008000f6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f6:	f3 0f 1e fb          	endbr32 
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	57                   	push   %edi
  8000fe:	56                   	push   %esi
  8000ff:	53                   	push   %ebx
  800100:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800103:	b9 00 00 00 00       	mov    $0x0,%ecx
  800108:	8b 55 08             	mov    0x8(%ebp),%edx
  80010b:	b8 03 00 00 00       	mov    $0x3,%eax
  800110:	89 cb                	mov    %ecx,%ebx
  800112:	89 cf                	mov    %ecx,%edi
  800114:	89 ce                	mov    %ecx,%esi
  800116:	cd 30                	int    $0x30
	if(check && ret > 0)
  800118:	85 c0                	test   %eax,%eax
  80011a:	7f 08                	jg     800124 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011f:	5b                   	pop    %ebx
  800120:	5e                   	pop    %esi
  800121:	5f                   	pop    %edi
  800122:	5d                   	pop    %ebp
  800123:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800124:	83 ec 0c             	sub    $0xc,%esp
  800127:	50                   	push   %eax
  800128:	6a 03                	push   $0x3
  80012a:	68 2f 10 80 00       	push   $0x80102f
  80012f:	6a 23                	push   $0x23
  800131:	68 4c 10 80 00       	push   $0x80104c
  800136:	e8 11 02 00 00       	call   80034c <_panic>

0080013b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013b:	f3 0f 1e fb          	endbr32 
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	57                   	push   %edi
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800145:	ba 00 00 00 00       	mov    $0x0,%edx
  80014a:	b8 02 00 00 00       	mov    $0x2,%eax
  80014f:	89 d1                	mov    %edx,%ecx
  800151:	89 d3                	mov    %edx,%ebx
  800153:	89 d7                	mov    %edx,%edi
  800155:	89 d6                	mov    %edx,%esi
  800157:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	5d                   	pop    %ebp
  80015d:	c3                   	ret    

0080015e <sys_yield>:

void
sys_yield(void)
{
  80015e:	f3 0f 1e fb          	endbr32 
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800168:	ba 00 00 00 00       	mov    $0x0,%edx
  80016d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800172:	89 d1                	mov    %edx,%ecx
  800174:	89 d3                	mov    %edx,%ebx
  800176:	89 d7                	mov    %edx,%edi
  800178:	89 d6                	mov    %edx,%esi
  80017a:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017c:	5b                   	pop    %ebx
  80017d:	5e                   	pop    %esi
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800181:	f3 0f 1e fb          	endbr32 
  800185:	55                   	push   %ebp
  800186:	89 e5                	mov    %esp,%ebp
  800188:	57                   	push   %edi
  800189:	56                   	push   %esi
  80018a:	53                   	push   %ebx
  80018b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  80018e:	be 00 00 00 00       	mov    $0x0,%esi
  800193:	8b 55 08             	mov    0x8(%ebp),%edx
  800196:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800199:	b8 04 00 00 00       	mov    $0x4,%eax
  80019e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a1:	89 f7                	mov    %esi,%edi
  8001a3:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001a5:	85 c0                	test   %eax,%eax
  8001a7:	7f 08                	jg     8001b1 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ac:	5b                   	pop    %ebx
  8001ad:	5e                   	pop    %esi
  8001ae:	5f                   	pop    %edi
  8001af:	5d                   	pop    %ebp
  8001b0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b1:	83 ec 0c             	sub    $0xc,%esp
  8001b4:	50                   	push   %eax
  8001b5:	6a 04                	push   $0x4
  8001b7:	68 2f 10 80 00       	push   $0x80102f
  8001bc:	6a 23                	push   $0x23
  8001be:	68 4c 10 80 00       	push   $0x80104c
  8001c3:	e8 84 01 00 00       	call   80034c <_panic>

008001c8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c8:	f3 0f 1e fb          	endbr32 
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	57                   	push   %edi
  8001d0:	56                   	push   %esi
  8001d1:	53                   	push   %ebx
  8001d2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8001d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001db:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e6:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e9:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001eb:	85 c0                	test   %eax,%eax
  8001ed:	7f 08                	jg     8001f7 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f2:	5b                   	pop    %ebx
  8001f3:	5e                   	pop    %esi
  8001f4:	5f                   	pop    %edi
  8001f5:	5d                   	pop    %ebp
  8001f6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f7:	83 ec 0c             	sub    $0xc,%esp
  8001fa:	50                   	push   %eax
  8001fb:	6a 05                	push   $0x5
  8001fd:	68 2f 10 80 00       	push   $0x80102f
  800202:	6a 23                	push   $0x23
  800204:	68 4c 10 80 00       	push   $0x80104c
  800209:	e8 3e 01 00 00       	call   80034c <_panic>

0080020e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80020e:	f3 0f 1e fb          	endbr32 
  800212:	55                   	push   %ebp
  800213:	89 e5                	mov    %esp,%ebp
  800215:	57                   	push   %edi
  800216:	56                   	push   %esi
  800217:	53                   	push   %ebx
  800218:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  80021b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800220:	8b 55 08             	mov    0x8(%ebp),%edx
  800223:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800226:	b8 06 00 00 00       	mov    $0x6,%eax
  80022b:	89 df                	mov    %ebx,%edi
  80022d:	89 de                	mov    %ebx,%esi
  80022f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800231:	85 c0                	test   %eax,%eax
  800233:	7f 08                	jg     80023d <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800235:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800238:	5b                   	pop    %ebx
  800239:	5e                   	pop    %esi
  80023a:	5f                   	pop    %edi
  80023b:	5d                   	pop    %ebp
  80023c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80023d:	83 ec 0c             	sub    $0xc,%esp
  800240:	50                   	push   %eax
  800241:	6a 06                	push   $0x6
  800243:	68 2f 10 80 00       	push   $0x80102f
  800248:	6a 23                	push   $0x23
  80024a:	68 4c 10 80 00       	push   $0x80104c
  80024f:	e8 f8 00 00 00       	call   80034c <_panic>

00800254 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800254:	f3 0f 1e fb          	endbr32 
  800258:	55                   	push   %ebp
  800259:	89 e5                	mov    %esp,%ebp
  80025b:	57                   	push   %edi
  80025c:	56                   	push   %esi
  80025d:	53                   	push   %ebx
  80025e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800261:	bb 00 00 00 00       	mov    $0x0,%ebx
  800266:	8b 55 08             	mov    0x8(%ebp),%edx
  800269:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026c:	b8 08 00 00 00       	mov    $0x8,%eax
  800271:	89 df                	mov    %ebx,%edi
  800273:	89 de                	mov    %ebx,%esi
  800275:	cd 30                	int    $0x30
	if(check && ret > 0)
  800277:	85 c0                	test   %eax,%eax
  800279:	7f 08                	jg     800283 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80027b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027e:	5b                   	pop    %ebx
  80027f:	5e                   	pop    %esi
  800280:	5f                   	pop    %edi
  800281:	5d                   	pop    %ebp
  800282:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800283:	83 ec 0c             	sub    $0xc,%esp
  800286:	50                   	push   %eax
  800287:	6a 08                	push   $0x8
  800289:	68 2f 10 80 00       	push   $0x80102f
  80028e:	6a 23                	push   $0x23
  800290:	68 4c 10 80 00       	push   $0x80104c
  800295:	e8 b2 00 00 00       	call   80034c <_panic>

0080029a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80029a:	f3 0f 1e fb          	endbr32 
  80029e:	55                   	push   %ebp
  80029f:	89 e5                	mov    %esp,%ebp
  8002a1:	57                   	push   %edi
  8002a2:	56                   	push   %esi
  8002a3:	53                   	push   %ebx
  8002a4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8002a7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8002af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b2:	b8 09 00 00 00       	mov    $0x9,%eax
  8002b7:	89 df                	mov    %ebx,%edi
  8002b9:	89 de                	mov    %ebx,%esi
  8002bb:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002bd:	85 c0                	test   %eax,%eax
  8002bf:	7f 08                	jg     8002c9 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c4:	5b                   	pop    %ebx
  8002c5:	5e                   	pop    %esi
  8002c6:	5f                   	pop    %edi
  8002c7:	5d                   	pop    %ebp
  8002c8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c9:	83 ec 0c             	sub    $0xc,%esp
  8002cc:	50                   	push   %eax
  8002cd:	6a 09                	push   $0x9
  8002cf:	68 2f 10 80 00       	push   $0x80102f
  8002d4:	6a 23                	push   $0x23
  8002d6:	68 4c 10 80 00       	push   $0x80104c
  8002db:	e8 6c 00 00 00       	call   80034c <_panic>

008002e0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e0:	f3 0f 1e fb          	endbr32 
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	57                   	push   %edi
  8002e8:	56                   	push   %esi
  8002e9:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  8002ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f0:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002f5:	be 00 00 00 00       	mov    $0x0,%esi
  8002fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800300:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800302:	5b                   	pop    %ebx
  800303:	5e                   	pop    %esi
  800304:	5f                   	pop    %edi
  800305:	5d                   	pop    %ebp
  800306:	c3                   	ret    

00800307 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800307:	f3 0f 1e fb          	endbr32 
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	57                   	push   %edi
  80030f:	56                   	push   %esi
  800310:	53                   	push   %ebx
  800311:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800314:	b9 00 00 00 00       	mov    $0x0,%ecx
  800319:	8b 55 08             	mov    0x8(%ebp),%edx
  80031c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800321:	89 cb                	mov    %ecx,%ebx
  800323:	89 cf                	mov    %ecx,%edi
  800325:	89 ce                	mov    %ecx,%esi
  800327:	cd 30                	int    $0x30
	if(check && ret > 0)
  800329:	85 c0                	test   %eax,%eax
  80032b:	7f 08                	jg     800335 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80032d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800330:	5b                   	pop    %ebx
  800331:	5e                   	pop    %esi
  800332:	5f                   	pop    %edi
  800333:	5d                   	pop    %ebp
  800334:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	50                   	push   %eax
  800339:	6a 0c                	push   $0xc
  80033b:	68 2f 10 80 00       	push   $0x80102f
  800340:	6a 23                	push   $0x23
  800342:	68 4c 10 80 00       	push   $0x80104c
  800347:	e8 00 00 00 00       	call   80034c <_panic>

0080034c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80034c:	f3 0f 1e fb          	endbr32 
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	56                   	push   %esi
  800354:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800355:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800358:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80035e:	e8 d8 fd ff ff       	call   80013b <sys_getenvid>
  800363:	83 ec 0c             	sub    $0xc,%esp
  800366:	ff 75 0c             	pushl  0xc(%ebp)
  800369:	ff 75 08             	pushl  0x8(%ebp)
  80036c:	56                   	push   %esi
  80036d:	50                   	push   %eax
  80036e:	68 5c 10 80 00       	push   $0x80105c
  800373:	e8 bb 00 00 00       	call   800433 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800378:	83 c4 18             	add    $0x18,%esp
  80037b:	53                   	push   %ebx
  80037c:	ff 75 10             	pushl  0x10(%ebp)
  80037f:	e8 5a 00 00 00       	call   8003de <vcprintf>
	cprintf("\n");
  800384:	c7 04 24 7f 10 80 00 	movl   $0x80107f,(%esp)
  80038b:	e8 a3 00 00 00       	call   800433 <cprintf>
  800390:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800393:	cc                   	int3   
  800394:	eb fd                	jmp    800393 <_panic+0x47>

00800396 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800396:	f3 0f 1e fb          	endbr32 
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	53                   	push   %ebx
  80039e:	83 ec 04             	sub    $0x4,%esp
  8003a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003a4:	8b 13                	mov    (%ebx),%edx
  8003a6:	8d 42 01             	lea    0x1(%edx),%eax
  8003a9:	89 03                	mov    %eax,(%ebx)
  8003ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003ae:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003b2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003b7:	74 09                	je     8003c2 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003b9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003c0:	c9                   	leave  
  8003c1:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003c2:	83 ec 08             	sub    $0x8,%esp
  8003c5:	68 ff 00 00 00       	push   $0xff
  8003ca:	8d 43 08             	lea    0x8(%ebx),%eax
  8003cd:	50                   	push   %eax
  8003ce:	e8 de fc ff ff       	call   8000b1 <sys_cputs>
		b->idx = 0;
  8003d3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003d9:	83 c4 10             	add    $0x10,%esp
  8003dc:	eb db                	jmp    8003b9 <putch+0x23>

008003de <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003de:	f3 0f 1e fb          	endbr32 
  8003e2:	55                   	push   %ebp
  8003e3:	89 e5                	mov    %esp,%ebp
  8003e5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003eb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003f2:	00 00 00 
	b.cnt = 0;
  8003f5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003fc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003ff:	ff 75 0c             	pushl  0xc(%ebp)
  800402:	ff 75 08             	pushl  0x8(%ebp)
  800405:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80040b:	50                   	push   %eax
  80040c:	68 96 03 80 00       	push   $0x800396
  800411:	e8 20 01 00 00       	call   800536 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800416:	83 c4 08             	add    $0x8,%esp
  800419:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80041f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800425:	50                   	push   %eax
  800426:	e8 86 fc ff ff       	call   8000b1 <sys_cputs>

	return b.cnt;
}
  80042b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800431:	c9                   	leave  
  800432:	c3                   	ret    

00800433 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800433:	f3 0f 1e fb          	endbr32 
  800437:	55                   	push   %ebp
  800438:	89 e5                	mov    %esp,%ebp
  80043a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80043d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800440:	50                   	push   %eax
  800441:	ff 75 08             	pushl  0x8(%ebp)
  800444:	e8 95 ff ff ff       	call   8003de <vcprintf>
	va_end(ap);

	return cnt;
}
  800449:	c9                   	leave  
  80044a:	c3                   	ret    

0080044b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80044b:	55                   	push   %ebp
  80044c:	89 e5                	mov    %esp,%ebp
  80044e:	57                   	push   %edi
  80044f:	56                   	push   %esi
  800450:	53                   	push   %ebx
  800451:	83 ec 1c             	sub    $0x1c,%esp
  800454:	89 c7                	mov    %eax,%edi
  800456:	89 d6                	mov    %edx,%esi
  800458:	8b 45 08             	mov    0x8(%ebp),%eax
  80045b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80045e:	89 d1                	mov    %edx,%ecx
  800460:	89 c2                	mov    %eax,%edx
  800462:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800465:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800468:	8b 45 10             	mov    0x10(%ebp),%eax
  80046b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80046e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800471:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800478:	39 c2                	cmp    %eax,%edx
  80047a:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80047d:	72 3e                	jb     8004bd <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80047f:	83 ec 0c             	sub    $0xc,%esp
  800482:	ff 75 18             	pushl  0x18(%ebp)
  800485:	83 eb 01             	sub    $0x1,%ebx
  800488:	53                   	push   %ebx
  800489:	50                   	push   %eax
  80048a:	83 ec 08             	sub    $0x8,%esp
  80048d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800490:	ff 75 e0             	pushl  -0x20(%ebp)
  800493:	ff 75 dc             	pushl  -0x24(%ebp)
  800496:	ff 75 d8             	pushl  -0x28(%ebp)
  800499:	e8 12 09 00 00       	call   800db0 <__udivdi3>
  80049e:	83 c4 18             	add    $0x18,%esp
  8004a1:	52                   	push   %edx
  8004a2:	50                   	push   %eax
  8004a3:	89 f2                	mov    %esi,%edx
  8004a5:	89 f8                	mov    %edi,%eax
  8004a7:	e8 9f ff ff ff       	call   80044b <printnum>
  8004ac:	83 c4 20             	add    $0x20,%esp
  8004af:	eb 13                	jmp    8004c4 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	56                   	push   %esi
  8004b5:	ff 75 18             	pushl  0x18(%ebp)
  8004b8:	ff d7                	call   *%edi
  8004ba:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004bd:	83 eb 01             	sub    $0x1,%ebx
  8004c0:	85 db                	test   %ebx,%ebx
  8004c2:	7f ed                	jg     8004b1 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004c4:	83 ec 08             	sub    $0x8,%esp
  8004c7:	56                   	push   %esi
  8004c8:	83 ec 04             	sub    $0x4,%esp
  8004cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d1:	ff 75 dc             	pushl  -0x24(%ebp)
  8004d4:	ff 75 d8             	pushl  -0x28(%ebp)
  8004d7:	e8 e4 09 00 00       	call   800ec0 <__umoddi3>
  8004dc:	83 c4 14             	add    $0x14,%esp
  8004df:	0f be 80 81 10 80 00 	movsbl 0x801081(%eax),%eax
  8004e6:	50                   	push   %eax
  8004e7:	ff d7                	call   *%edi
}
  8004e9:	83 c4 10             	add    $0x10,%esp
  8004ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004ef:	5b                   	pop    %ebx
  8004f0:	5e                   	pop    %esi
  8004f1:	5f                   	pop    %edi
  8004f2:	5d                   	pop    %ebp
  8004f3:	c3                   	ret    

008004f4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004f4:	f3 0f 1e fb          	endbr32 
  8004f8:	55                   	push   %ebp
  8004f9:	89 e5                	mov    %esp,%ebp
  8004fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004fe:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800502:	8b 10                	mov    (%eax),%edx
  800504:	3b 50 04             	cmp    0x4(%eax),%edx
  800507:	73 0a                	jae    800513 <sprintputch+0x1f>
		*b->buf++ = ch;
  800509:	8d 4a 01             	lea    0x1(%edx),%ecx
  80050c:	89 08                	mov    %ecx,(%eax)
  80050e:	8b 45 08             	mov    0x8(%ebp),%eax
  800511:	88 02                	mov    %al,(%edx)
}
  800513:	5d                   	pop    %ebp
  800514:	c3                   	ret    

00800515 <printfmt>:
{
  800515:	f3 0f 1e fb          	endbr32 
  800519:	55                   	push   %ebp
  80051a:	89 e5                	mov    %esp,%ebp
  80051c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80051f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800522:	50                   	push   %eax
  800523:	ff 75 10             	pushl  0x10(%ebp)
  800526:	ff 75 0c             	pushl  0xc(%ebp)
  800529:	ff 75 08             	pushl  0x8(%ebp)
  80052c:	e8 05 00 00 00       	call   800536 <vprintfmt>
}
  800531:	83 c4 10             	add    $0x10,%esp
  800534:	c9                   	leave  
  800535:	c3                   	ret    

00800536 <vprintfmt>:
{
  800536:	f3 0f 1e fb          	endbr32 
  80053a:	55                   	push   %ebp
  80053b:	89 e5                	mov    %esp,%ebp
  80053d:	57                   	push   %edi
  80053e:	56                   	push   %esi
  80053f:	53                   	push   %ebx
  800540:	83 ec 3c             	sub    $0x3c,%esp
  800543:	8b 75 08             	mov    0x8(%ebp),%esi
  800546:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800549:	8b 7d 10             	mov    0x10(%ebp),%edi
  80054c:	e9 8e 03 00 00       	jmp    8008df <vprintfmt+0x3a9>
		padc = ' ';
  800551:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800555:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80055c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800563:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80056a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80056f:	8d 47 01             	lea    0x1(%edi),%eax
  800572:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800575:	0f b6 17             	movzbl (%edi),%edx
  800578:	8d 42 dd             	lea    -0x23(%edx),%eax
  80057b:	3c 55                	cmp    $0x55,%al
  80057d:	0f 87 df 03 00 00    	ja     800962 <vprintfmt+0x42c>
  800583:	0f b6 c0             	movzbl %al,%eax
  800586:	3e ff 24 85 40 11 80 	notrack jmp *0x801140(,%eax,4)
  80058d:	00 
  80058e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800591:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800595:	eb d8                	jmp    80056f <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800597:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80059a:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80059e:	eb cf                	jmp    80056f <vprintfmt+0x39>
  8005a0:	0f b6 d2             	movzbl %dl,%edx
  8005a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8005a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ab:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005ae:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005b1:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005b5:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005b8:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005bb:	83 f9 09             	cmp    $0x9,%ecx
  8005be:	77 55                	ja     800615 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005c0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005c3:	eb e9                	jmp    8005ae <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c8:	8b 00                	mov    (%eax),%eax
  8005ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d0:	8d 40 04             	lea    0x4(%eax),%eax
  8005d3:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005d9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005dd:	79 90                	jns    80056f <vprintfmt+0x39>
				width = precision, precision = -1;
  8005df:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e5:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005ec:	eb 81                	jmp    80056f <vprintfmt+0x39>
  8005ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005f1:	85 c0                	test   %eax,%eax
  8005f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8005f8:	0f 49 d0             	cmovns %eax,%edx
  8005fb:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800601:	e9 69 ff ff ff       	jmp    80056f <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800606:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800609:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800610:	e9 5a ff ff ff       	jmp    80056f <vprintfmt+0x39>
  800615:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800618:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061b:	eb bc                	jmp    8005d9 <vprintfmt+0xa3>
			lflag++;
  80061d:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800620:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800623:	e9 47 ff ff ff       	jmp    80056f <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8d 78 04             	lea    0x4(%eax),%edi
  80062e:	83 ec 08             	sub    $0x8,%esp
  800631:	53                   	push   %ebx
  800632:	ff 30                	pushl  (%eax)
  800634:	ff d6                	call   *%esi
			break;
  800636:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800639:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80063c:	e9 9b 02 00 00       	jmp    8008dc <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8d 78 04             	lea    0x4(%eax),%edi
  800647:	8b 00                	mov    (%eax),%eax
  800649:	99                   	cltd   
  80064a:	31 d0                	xor    %edx,%eax
  80064c:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80064e:	83 f8 08             	cmp    $0x8,%eax
  800651:	7f 23                	jg     800676 <vprintfmt+0x140>
  800653:	8b 14 85 a0 12 80 00 	mov    0x8012a0(,%eax,4),%edx
  80065a:	85 d2                	test   %edx,%edx
  80065c:	74 18                	je     800676 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80065e:	52                   	push   %edx
  80065f:	68 a2 10 80 00       	push   $0x8010a2
  800664:	53                   	push   %ebx
  800665:	56                   	push   %esi
  800666:	e8 aa fe ff ff       	call   800515 <printfmt>
  80066b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80066e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800671:	e9 66 02 00 00       	jmp    8008dc <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800676:	50                   	push   %eax
  800677:	68 99 10 80 00       	push   $0x801099
  80067c:	53                   	push   %ebx
  80067d:	56                   	push   %esi
  80067e:	e8 92 fe ff ff       	call   800515 <printfmt>
  800683:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800686:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800689:	e9 4e 02 00 00       	jmp    8008dc <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  80068e:	8b 45 14             	mov    0x14(%ebp),%eax
  800691:	83 c0 04             	add    $0x4,%eax
  800694:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80069c:	85 d2                	test   %edx,%edx
  80069e:	b8 92 10 80 00       	mov    $0x801092,%eax
  8006a3:	0f 45 c2             	cmovne %edx,%eax
  8006a6:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8006a9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006ad:	7e 06                	jle    8006b5 <vprintfmt+0x17f>
  8006af:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006b3:	75 0d                	jne    8006c2 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006b8:	89 c7                	mov    %eax,%edi
  8006ba:	03 45 e0             	add    -0x20(%ebp),%eax
  8006bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006c0:	eb 55                	jmp    800717 <vprintfmt+0x1e1>
  8006c2:	83 ec 08             	sub    $0x8,%esp
  8006c5:	ff 75 d8             	pushl  -0x28(%ebp)
  8006c8:	ff 75 cc             	pushl  -0x34(%ebp)
  8006cb:	e8 46 03 00 00       	call   800a16 <strnlen>
  8006d0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006d3:	29 c2                	sub    %eax,%edx
  8006d5:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8006d8:	83 c4 10             	add    $0x10,%esp
  8006db:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8006dd:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e4:	85 ff                	test   %edi,%edi
  8006e6:	7e 11                	jle    8006f9 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8006e8:	83 ec 08             	sub    $0x8,%esp
  8006eb:	53                   	push   %ebx
  8006ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ef:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f1:	83 ef 01             	sub    $0x1,%edi
  8006f4:	83 c4 10             	add    $0x10,%esp
  8006f7:	eb eb                	jmp    8006e4 <vprintfmt+0x1ae>
  8006f9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006fc:	85 d2                	test   %edx,%edx
  8006fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800703:	0f 49 c2             	cmovns %edx,%eax
  800706:	29 c2                	sub    %eax,%edx
  800708:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80070b:	eb a8                	jmp    8006b5 <vprintfmt+0x17f>
					putch(ch, putdat);
  80070d:	83 ec 08             	sub    $0x8,%esp
  800710:	53                   	push   %ebx
  800711:	52                   	push   %edx
  800712:	ff d6                	call   *%esi
  800714:	83 c4 10             	add    $0x10,%esp
  800717:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80071a:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80071c:	83 c7 01             	add    $0x1,%edi
  80071f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800723:	0f be d0             	movsbl %al,%edx
  800726:	85 d2                	test   %edx,%edx
  800728:	74 4b                	je     800775 <vprintfmt+0x23f>
  80072a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80072e:	78 06                	js     800736 <vprintfmt+0x200>
  800730:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800734:	78 1e                	js     800754 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800736:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80073a:	74 d1                	je     80070d <vprintfmt+0x1d7>
  80073c:	0f be c0             	movsbl %al,%eax
  80073f:	83 e8 20             	sub    $0x20,%eax
  800742:	83 f8 5e             	cmp    $0x5e,%eax
  800745:	76 c6                	jbe    80070d <vprintfmt+0x1d7>
					putch('?', putdat);
  800747:	83 ec 08             	sub    $0x8,%esp
  80074a:	53                   	push   %ebx
  80074b:	6a 3f                	push   $0x3f
  80074d:	ff d6                	call   *%esi
  80074f:	83 c4 10             	add    $0x10,%esp
  800752:	eb c3                	jmp    800717 <vprintfmt+0x1e1>
  800754:	89 cf                	mov    %ecx,%edi
  800756:	eb 0e                	jmp    800766 <vprintfmt+0x230>
				putch(' ', putdat);
  800758:	83 ec 08             	sub    $0x8,%esp
  80075b:	53                   	push   %ebx
  80075c:	6a 20                	push   $0x20
  80075e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800760:	83 ef 01             	sub    $0x1,%edi
  800763:	83 c4 10             	add    $0x10,%esp
  800766:	85 ff                	test   %edi,%edi
  800768:	7f ee                	jg     800758 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80076a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80076d:	89 45 14             	mov    %eax,0x14(%ebp)
  800770:	e9 67 01 00 00       	jmp    8008dc <vprintfmt+0x3a6>
  800775:	89 cf                	mov    %ecx,%edi
  800777:	eb ed                	jmp    800766 <vprintfmt+0x230>
	if (lflag >= 2)
  800779:	83 f9 01             	cmp    $0x1,%ecx
  80077c:	7f 1b                	jg     800799 <vprintfmt+0x263>
	else if (lflag)
  80077e:	85 c9                	test   %ecx,%ecx
  800780:	74 63                	je     8007e5 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800782:	8b 45 14             	mov    0x14(%ebp),%eax
  800785:	8b 00                	mov    (%eax),%eax
  800787:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078a:	99                   	cltd   
  80078b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80078e:	8b 45 14             	mov    0x14(%ebp),%eax
  800791:	8d 40 04             	lea    0x4(%eax),%eax
  800794:	89 45 14             	mov    %eax,0x14(%ebp)
  800797:	eb 17                	jmp    8007b0 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800799:	8b 45 14             	mov    0x14(%ebp),%eax
  80079c:	8b 50 04             	mov    0x4(%eax),%edx
  80079f:	8b 00                	mov    (%eax),%eax
  8007a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007aa:	8d 40 08             	lea    0x8(%eax),%eax
  8007ad:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007b0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007b3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007b6:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007bb:	85 c9                	test   %ecx,%ecx
  8007bd:	0f 89 ff 00 00 00    	jns    8008c2 <vprintfmt+0x38c>
				putch('-', putdat);
  8007c3:	83 ec 08             	sub    $0x8,%esp
  8007c6:	53                   	push   %ebx
  8007c7:	6a 2d                	push   $0x2d
  8007c9:	ff d6                	call   *%esi
				num = -(long long) num;
  8007cb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007ce:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007d1:	f7 da                	neg    %edx
  8007d3:	83 d1 00             	adc    $0x0,%ecx
  8007d6:	f7 d9                	neg    %ecx
  8007d8:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007db:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007e0:	e9 dd 00 00 00       	jmp    8008c2 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8007e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e8:	8b 00                	mov    (%eax),%eax
  8007ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ed:	99                   	cltd   
  8007ee:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f4:	8d 40 04             	lea    0x4(%eax),%eax
  8007f7:	89 45 14             	mov    %eax,0x14(%ebp)
  8007fa:	eb b4                	jmp    8007b0 <vprintfmt+0x27a>
	if (lflag >= 2)
  8007fc:	83 f9 01             	cmp    $0x1,%ecx
  8007ff:	7f 1e                	jg     80081f <vprintfmt+0x2e9>
	else if (lflag)
  800801:	85 c9                	test   %ecx,%ecx
  800803:	74 32                	je     800837 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800805:	8b 45 14             	mov    0x14(%ebp),%eax
  800808:	8b 10                	mov    (%eax),%edx
  80080a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80080f:	8d 40 04             	lea    0x4(%eax),%eax
  800812:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800815:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80081a:	e9 a3 00 00 00       	jmp    8008c2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80081f:	8b 45 14             	mov    0x14(%ebp),%eax
  800822:	8b 10                	mov    (%eax),%edx
  800824:	8b 48 04             	mov    0x4(%eax),%ecx
  800827:	8d 40 08             	lea    0x8(%eax),%eax
  80082a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80082d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800832:	e9 8b 00 00 00       	jmp    8008c2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800837:	8b 45 14             	mov    0x14(%ebp),%eax
  80083a:	8b 10                	mov    (%eax),%edx
  80083c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800841:	8d 40 04             	lea    0x4(%eax),%eax
  800844:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800847:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80084c:	eb 74                	jmp    8008c2 <vprintfmt+0x38c>
	if (lflag >= 2)
  80084e:	83 f9 01             	cmp    $0x1,%ecx
  800851:	7f 1b                	jg     80086e <vprintfmt+0x338>
	else if (lflag)
  800853:	85 c9                	test   %ecx,%ecx
  800855:	74 2c                	je     800883 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800857:	8b 45 14             	mov    0x14(%ebp),%eax
  80085a:	8b 10                	mov    (%eax),%edx
  80085c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800861:	8d 40 04             	lea    0x4(%eax),%eax
  800864:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800867:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  80086c:	eb 54                	jmp    8008c2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80086e:	8b 45 14             	mov    0x14(%ebp),%eax
  800871:	8b 10                	mov    (%eax),%edx
  800873:	8b 48 04             	mov    0x4(%eax),%ecx
  800876:	8d 40 08             	lea    0x8(%eax),%eax
  800879:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80087c:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800881:	eb 3f                	jmp    8008c2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800883:	8b 45 14             	mov    0x14(%ebp),%eax
  800886:	8b 10                	mov    (%eax),%edx
  800888:	b9 00 00 00 00       	mov    $0x0,%ecx
  80088d:	8d 40 04             	lea    0x4(%eax),%eax
  800890:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800893:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800898:	eb 28                	jmp    8008c2 <vprintfmt+0x38c>
			putch('0', putdat);
  80089a:	83 ec 08             	sub    $0x8,%esp
  80089d:	53                   	push   %ebx
  80089e:	6a 30                	push   $0x30
  8008a0:	ff d6                	call   *%esi
			putch('x', putdat);
  8008a2:	83 c4 08             	add    $0x8,%esp
  8008a5:	53                   	push   %ebx
  8008a6:	6a 78                	push   $0x78
  8008a8:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ad:	8b 10                	mov    (%eax),%edx
  8008af:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008b4:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008b7:	8d 40 04             	lea    0x4(%eax),%eax
  8008ba:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008bd:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008c2:	83 ec 0c             	sub    $0xc,%esp
  8008c5:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8008c9:	57                   	push   %edi
  8008ca:	ff 75 e0             	pushl  -0x20(%ebp)
  8008cd:	50                   	push   %eax
  8008ce:	51                   	push   %ecx
  8008cf:	52                   	push   %edx
  8008d0:	89 da                	mov    %ebx,%edx
  8008d2:	89 f0                	mov    %esi,%eax
  8008d4:	e8 72 fb ff ff       	call   80044b <printnum>
			break;
  8008d9:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8008dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {	
  8008df:	83 c7 01             	add    $0x1,%edi
  8008e2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008e6:	83 f8 25             	cmp    $0x25,%eax
  8008e9:	0f 84 62 fc ff ff    	je     800551 <vprintfmt+0x1b>
			if (ch == '\0')										
  8008ef:	85 c0                	test   %eax,%eax
  8008f1:	0f 84 8b 00 00 00    	je     800982 <vprintfmt+0x44c>
			putch(ch, putdat);
  8008f7:	83 ec 08             	sub    $0x8,%esp
  8008fa:	53                   	push   %ebx
  8008fb:	50                   	push   %eax
  8008fc:	ff d6                	call   *%esi
  8008fe:	83 c4 10             	add    $0x10,%esp
  800901:	eb dc                	jmp    8008df <vprintfmt+0x3a9>
	if (lflag >= 2)
  800903:	83 f9 01             	cmp    $0x1,%ecx
  800906:	7f 1b                	jg     800923 <vprintfmt+0x3ed>
	else if (lflag)
  800908:	85 c9                	test   %ecx,%ecx
  80090a:	74 2c                	je     800938 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  80090c:	8b 45 14             	mov    0x14(%ebp),%eax
  80090f:	8b 10                	mov    (%eax),%edx
  800911:	b9 00 00 00 00       	mov    $0x0,%ecx
  800916:	8d 40 04             	lea    0x4(%eax),%eax
  800919:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80091c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800921:	eb 9f                	jmp    8008c2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800923:	8b 45 14             	mov    0x14(%ebp),%eax
  800926:	8b 10                	mov    (%eax),%edx
  800928:	8b 48 04             	mov    0x4(%eax),%ecx
  80092b:	8d 40 08             	lea    0x8(%eax),%eax
  80092e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800931:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800936:	eb 8a                	jmp    8008c2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800938:	8b 45 14             	mov    0x14(%ebp),%eax
  80093b:	8b 10                	mov    (%eax),%edx
  80093d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800942:	8d 40 04             	lea    0x4(%eax),%eax
  800945:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800948:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80094d:	e9 70 ff ff ff       	jmp    8008c2 <vprintfmt+0x38c>
			putch(ch, putdat);
  800952:	83 ec 08             	sub    $0x8,%esp
  800955:	53                   	push   %ebx
  800956:	6a 25                	push   $0x25
  800958:	ff d6                	call   *%esi
			break;
  80095a:	83 c4 10             	add    $0x10,%esp
  80095d:	e9 7a ff ff ff       	jmp    8008dc <vprintfmt+0x3a6>
			putch('%', putdat);
  800962:	83 ec 08             	sub    $0x8,%esp
  800965:	53                   	push   %ebx
  800966:	6a 25                	push   $0x25
  800968:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80096a:	83 c4 10             	add    $0x10,%esp
  80096d:	89 f8                	mov    %edi,%eax
  80096f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800973:	74 05                	je     80097a <vprintfmt+0x444>
  800975:	83 e8 01             	sub    $0x1,%eax
  800978:	eb f5                	jmp    80096f <vprintfmt+0x439>
  80097a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80097d:	e9 5a ff ff ff       	jmp    8008dc <vprintfmt+0x3a6>
}
  800982:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800985:	5b                   	pop    %ebx
  800986:	5e                   	pop    %esi
  800987:	5f                   	pop    %edi
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80098a:	f3 0f 1e fb          	endbr32 
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	83 ec 18             	sub    $0x18,%esp
  800994:	8b 45 08             	mov    0x8(%ebp),%eax
  800997:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80099a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80099d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009a1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009ab:	85 c0                	test   %eax,%eax
  8009ad:	74 26                	je     8009d5 <vsnprintf+0x4b>
  8009af:	85 d2                	test   %edx,%edx
  8009b1:	7e 22                	jle    8009d5 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009b3:	ff 75 14             	pushl  0x14(%ebp)
  8009b6:	ff 75 10             	pushl  0x10(%ebp)
  8009b9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009bc:	50                   	push   %eax
  8009bd:	68 f4 04 80 00       	push   $0x8004f4
  8009c2:	e8 6f fb ff ff       	call   800536 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009ca:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009d0:	83 c4 10             	add    $0x10,%esp
}
  8009d3:	c9                   	leave  
  8009d4:	c3                   	ret    
		return -E_INVAL;
  8009d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009da:	eb f7                	jmp    8009d3 <vsnprintf+0x49>

008009dc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009dc:	f3 0f 1e fb          	endbr32 
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009e6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009e9:	50                   	push   %eax
  8009ea:	ff 75 10             	pushl  0x10(%ebp)
  8009ed:	ff 75 0c             	pushl  0xc(%ebp)
  8009f0:	ff 75 08             	pushl  0x8(%ebp)
  8009f3:	e8 92 ff ff ff       	call   80098a <vsnprintf>
	va_end(ap);

	return rc;
}
  8009f8:	c9                   	leave  
  8009f9:	c3                   	ret    

008009fa <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009fa:	f3 0f 1e fb          	endbr32 
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a04:	b8 00 00 00 00       	mov    $0x0,%eax
  800a09:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a0d:	74 05                	je     800a14 <strlen+0x1a>
		n++;
  800a0f:	83 c0 01             	add    $0x1,%eax
  800a12:	eb f5                	jmp    800a09 <strlen+0xf>
	return n;
}
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a16:	f3 0f 1e fb          	endbr32 
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a20:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a23:	b8 00 00 00 00       	mov    $0x0,%eax
  800a28:	39 d0                	cmp    %edx,%eax
  800a2a:	74 0d                	je     800a39 <strnlen+0x23>
  800a2c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a30:	74 05                	je     800a37 <strnlen+0x21>
		n++;
  800a32:	83 c0 01             	add    $0x1,%eax
  800a35:	eb f1                	jmp    800a28 <strnlen+0x12>
  800a37:	89 c2                	mov    %eax,%edx
	return n;
}
  800a39:	89 d0                	mov    %edx,%eax
  800a3b:	5d                   	pop    %ebp
  800a3c:	c3                   	ret    

00800a3d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a3d:	f3 0f 1e fb          	endbr32 
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	53                   	push   %ebx
  800a45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a48:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a50:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a54:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a57:	83 c0 01             	add    $0x1,%eax
  800a5a:	84 d2                	test   %dl,%dl
  800a5c:	75 f2                	jne    800a50 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a5e:	89 c8                	mov    %ecx,%eax
  800a60:	5b                   	pop    %ebx
  800a61:	5d                   	pop    %ebp
  800a62:	c3                   	ret    

00800a63 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a63:	f3 0f 1e fb          	endbr32 
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	53                   	push   %ebx
  800a6b:	83 ec 10             	sub    $0x10,%esp
  800a6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a71:	53                   	push   %ebx
  800a72:	e8 83 ff ff ff       	call   8009fa <strlen>
  800a77:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800a7a:	ff 75 0c             	pushl  0xc(%ebp)
  800a7d:	01 d8                	add    %ebx,%eax
  800a7f:	50                   	push   %eax
  800a80:	e8 b8 ff ff ff       	call   800a3d <strcpy>
	return dst;
}
  800a85:	89 d8                	mov    %ebx,%eax
  800a87:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a8a:	c9                   	leave  
  800a8b:	c3                   	ret    

00800a8c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a8c:	f3 0f 1e fb          	endbr32 
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	56                   	push   %esi
  800a94:	53                   	push   %ebx
  800a95:	8b 75 08             	mov    0x8(%ebp),%esi
  800a98:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9b:	89 f3                	mov    %esi,%ebx
  800a9d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aa0:	89 f0                	mov    %esi,%eax
  800aa2:	39 d8                	cmp    %ebx,%eax
  800aa4:	74 11                	je     800ab7 <strncpy+0x2b>
		*dst++ = *src;
  800aa6:	83 c0 01             	add    $0x1,%eax
  800aa9:	0f b6 0a             	movzbl (%edx),%ecx
  800aac:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800aaf:	80 f9 01             	cmp    $0x1,%cl
  800ab2:	83 da ff             	sbb    $0xffffffff,%edx
  800ab5:	eb eb                	jmp    800aa2 <strncpy+0x16>
	}
	return ret;
}
  800ab7:	89 f0                	mov    %esi,%eax
  800ab9:	5b                   	pop    %ebx
  800aba:	5e                   	pop    %esi
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800abd:	f3 0f 1e fb          	endbr32 
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	56                   	push   %esi
  800ac5:	53                   	push   %ebx
  800ac6:	8b 75 08             	mov    0x8(%ebp),%esi
  800ac9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800acc:	8b 55 10             	mov    0x10(%ebp),%edx
  800acf:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ad1:	85 d2                	test   %edx,%edx
  800ad3:	74 21                	je     800af6 <strlcpy+0x39>
  800ad5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800ad9:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800adb:	39 c2                	cmp    %eax,%edx
  800add:	74 14                	je     800af3 <strlcpy+0x36>
  800adf:	0f b6 19             	movzbl (%ecx),%ebx
  800ae2:	84 db                	test   %bl,%bl
  800ae4:	74 0b                	je     800af1 <strlcpy+0x34>
			*dst++ = *src++;
  800ae6:	83 c1 01             	add    $0x1,%ecx
  800ae9:	83 c2 01             	add    $0x1,%edx
  800aec:	88 5a ff             	mov    %bl,-0x1(%edx)
  800aef:	eb ea                	jmp    800adb <strlcpy+0x1e>
  800af1:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800af3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800af6:	29 f0                	sub    %esi,%eax
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800afc:	f3 0f 1e fb          	endbr32 
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b06:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b09:	0f b6 01             	movzbl (%ecx),%eax
  800b0c:	84 c0                	test   %al,%al
  800b0e:	74 0c                	je     800b1c <strcmp+0x20>
  800b10:	3a 02                	cmp    (%edx),%al
  800b12:	75 08                	jne    800b1c <strcmp+0x20>
		p++, q++;
  800b14:	83 c1 01             	add    $0x1,%ecx
  800b17:	83 c2 01             	add    $0x1,%edx
  800b1a:	eb ed                	jmp    800b09 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b1c:	0f b6 c0             	movzbl %al,%eax
  800b1f:	0f b6 12             	movzbl (%edx),%edx
  800b22:	29 d0                	sub    %edx,%eax
}
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b26:	f3 0f 1e fb          	endbr32 
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	53                   	push   %ebx
  800b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b31:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b34:	89 c3                	mov    %eax,%ebx
  800b36:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b39:	eb 06                	jmp    800b41 <strncmp+0x1b>
		n--, p++, q++;
  800b3b:	83 c0 01             	add    $0x1,%eax
  800b3e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b41:	39 d8                	cmp    %ebx,%eax
  800b43:	74 16                	je     800b5b <strncmp+0x35>
  800b45:	0f b6 08             	movzbl (%eax),%ecx
  800b48:	84 c9                	test   %cl,%cl
  800b4a:	74 04                	je     800b50 <strncmp+0x2a>
  800b4c:	3a 0a                	cmp    (%edx),%cl
  800b4e:	74 eb                	je     800b3b <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b50:	0f b6 00             	movzbl (%eax),%eax
  800b53:	0f b6 12             	movzbl (%edx),%edx
  800b56:	29 d0                	sub    %edx,%eax
}
  800b58:	5b                   	pop    %ebx
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    
		return 0;
  800b5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b60:	eb f6                	jmp    800b58 <strncmp+0x32>

00800b62 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b62:	f3 0f 1e fb          	endbr32 
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b70:	0f b6 10             	movzbl (%eax),%edx
  800b73:	84 d2                	test   %dl,%dl
  800b75:	74 09                	je     800b80 <strchr+0x1e>
		if (*s == c)
  800b77:	38 ca                	cmp    %cl,%dl
  800b79:	74 0a                	je     800b85 <strchr+0x23>
	for (; *s; s++)
  800b7b:	83 c0 01             	add    $0x1,%eax
  800b7e:	eb f0                	jmp    800b70 <strchr+0xe>
			return (char *) s;
	return 0;
  800b80:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b85:	5d                   	pop    %ebp
  800b86:	c3                   	ret    

00800b87 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b87:	f3 0f 1e fb          	endbr32 
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b91:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b95:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b98:	38 ca                	cmp    %cl,%dl
  800b9a:	74 09                	je     800ba5 <strfind+0x1e>
  800b9c:	84 d2                	test   %dl,%dl
  800b9e:	74 05                	je     800ba5 <strfind+0x1e>
	for (; *s; s++)
  800ba0:	83 c0 01             	add    $0x1,%eax
  800ba3:	eb f0                	jmp    800b95 <strfind+0xe>
			break;
	return (char *) s;
}
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    

00800ba7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ba7:	f3 0f 1e fb          	endbr32 
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	57                   	push   %edi
  800baf:	56                   	push   %esi
  800bb0:	53                   	push   %ebx
  800bb1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bb4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bb7:	85 c9                	test   %ecx,%ecx
  800bb9:	74 31                	je     800bec <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bbb:	89 f8                	mov    %edi,%eax
  800bbd:	09 c8                	or     %ecx,%eax
  800bbf:	a8 03                	test   $0x3,%al
  800bc1:	75 23                	jne    800be6 <memset+0x3f>
		c &= 0xFF;
  800bc3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bc7:	89 d3                	mov    %edx,%ebx
  800bc9:	c1 e3 08             	shl    $0x8,%ebx
  800bcc:	89 d0                	mov    %edx,%eax
  800bce:	c1 e0 18             	shl    $0x18,%eax
  800bd1:	89 d6                	mov    %edx,%esi
  800bd3:	c1 e6 10             	shl    $0x10,%esi
  800bd6:	09 f0                	or     %esi,%eax
  800bd8:	09 c2                	or     %eax,%edx
  800bda:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bdc:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800bdf:	89 d0                	mov    %edx,%eax
  800be1:	fc                   	cld    
  800be2:	f3 ab                	rep stos %eax,%es:(%edi)
  800be4:	eb 06                	jmp    800bec <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800be6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be9:	fc                   	cld    
  800bea:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bec:	89 f8                	mov    %edi,%eax
  800bee:	5b                   	pop    %ebx
  800bef:	5e                   	pop    %esi
  800bf0:	5f                   	pop    %edi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    

00800bf3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bf3:	f3 0f 1e fb          	endbr32 
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	57                   	push   %edi
  800bfb:	56                   	push   %esi
  800bfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c02:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c05:	39 c6                	cmp    %eax,%esi
  800c07:	73 32                	jae    800c3b <memmove+0x48>
  800c09:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c0c:	39 c2                	cmp    %eax,%edx
  800c0e:	76 2b                	jbe    800c3b <memmove+0x48>
		s += n;
		d += n;
  800c10:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c13:	89 fe                	mov    %edi,%esi
  800c15:	09 ce                	or     %ecx,%esi
  800c17:	09 d6                	or     %edx,%esi
  800c19:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c1f:	75 0e                	jne    800c2f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c21:	83 ef 04             	sub    $0x4,%edi
  800c24:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c27:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c2a:	fd                   	std    
  800c2b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c2d:	eb 09                	jmp    800c38 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c2f:	83 ef 01             	sub    $0x1,%edi
  800c32:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c35:	fd                   	std    
  800c36:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c38:	fc                   	cld    
  800c39:	eb 1a                	jmp    800c55 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c3b:	89 c2                	mov    %eax,%edx
  800c3d:	09 ca                	or     %ecx,%edx
  800c3f:	09 f2                	or     %esi,%edx
  800c41:	f6 c2 03             	test   $0x3,%dl
  800c44:	75 0a                	jne    800c50 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c46:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c49:	89 c7                	mov    %eax,%edi
  800c4b:	fc                   	cld    
  800c4c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c4e:	eb 05                	jmp    800c55 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c50:	89 c7                	mov    %eax,%edi
  800c52:	fc                   	cld    
  800c53:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c55:	5e                   	pop    %esi
  800c56:	5f                   	pop    %edi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c59:	f3 0f 1e fb          	endbr32 
  800c5d:	55                   	push   %ebp
  800c5e:	89 e5                	mov    %esp,%ebp
  800c60:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c63:	ff 75 10             	pushl  0x10(%ebp)
  800c66:	ff 75 0c             	pushl  0xc(%ebp)
  800c69:	ff 75 08             	pushl  0x8(%ebp)
  800c6c:	e8 82 ff ff ff       	call   800bf3 <memmove>
}
  800c71:	c9                   	leave  
  800c72:	c3                   	ret    

00800c73 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c73:	f3 0f 1e fb          	endbr32 
  800c77:	55                   	push   %ebp
  800c78:	89 e5                	mov    %esp,%ebp
  800c7a:	56                   	push   %esi
  800c7b:	53                   	push   %ebx
  800c7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c82:	89 c6                	mov    %eax,%esi
  800c84:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c87:	39 f0                	cmp    %esi,%eax
  800c89:	74 1c                	je     800ca7 <memcmp+0x34>
		if (*s1 != *s2)
  800c8b:	0f b6 08             	movzbl (%eax),%ecx
  800c8e:	0f b6 1a             	movzbl (%edx),%ebx
  800c91:	38 d9                	cmp    %bl,%cl
  800c93:	75 08                	jne    800c9d <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c95:	83 c0 01             	add    $0x1,%eax
  800c98:	83 c2 01             	add    $0x1,%edx
  800c9b:	eb ea                	jmp    800c87 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800c9d:	0f b6 c1             	movzbl %cl,%eax
  800ca0:	0f b6 db             	movzbl %bl,%ebx
  800ca3:	29 d8                	sub    %ebx,%eax
  800ca5:	eb 05                	jmp    800cac <memcmp+0x39>
	}

	return 0;
  800ca7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cac:	5b                   	pop    %ebx
  800cad:	5e                   	pop    %esi
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    

00800cb0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cb0:	f3 0f 1e fb          	endbr32 
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cbd:	89 c2                	mov    %eax,%edx
  800cbf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cc2:	39 d0                	cmp    %edx,%eax
  800cc4:	73 09                	jae    800ccf <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cc6:	38 08                	cmp    %cl,(%eax)
  800cc8:	74 05                	je     800ccf <memfind+0x1f>
	for (; s < ends; s++)
  800cca:	83 c0 01             	add    $0x1,%eax
  800ccd:	eb f3                	jmp    800cc2 <memfind+0x12>
			break;
	return (void *) s;
}
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cd1:	f3 0f 1e fb          	endbr32 
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	57                   	push   %edi
  800cd9:	56                   	push   %esi
  800cda:	53                   	push   %ebx
  800cdb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cde:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ce1:	eb 03                	jmp    800ce6 <strtol+0x15>
		s++;
  800ce3:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ce6:	0f b6 01             	movzbl (%ecx),%eax
  800ce9:	3c 20                	cmp    $0x20,%al
  800ceb:	74 f6                	je     800ce3 <strtol+0x12>
  800ced:	3c 09                	cmp    $0x9,%al
  800cef:	74 f2                	je     800ce3 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800cf1:	3c 2b                	cmp    $0x2b,%al
  800cf3:	74 2a                	je     800d1f <strtol+0x4e>
	int neg = 0;
  800cf5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800cfa:	3c 2d                	cmp    $0x2d,%al
  800cfc:	74 2b                	je     800d29 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cfe:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d04:	75 0f                	jne    800d15 <strtol+0x44>
  800d06:	80 39 30             	cmpb   $0x30,(%ecx)
  800d09:	74 28                	je     800d33 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d0b:	85 db                	test   %ebx,%ebx
  800d0d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d12:	0f 44 d8             	cmove  %eax,%ebx
  800d15:	b8 00 00 00 00       	mov    $0x0,%eax
  800d1a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d1d:	eb 46                	jmp    800d65 <strtol+0x94>
		s++;
  800d1f:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d22:	bf 00 00 00 00       	mov    $0x0,%edi
  800d27:	eb d5                	jmp    800cfe <strtol+0x2d>
		s++, neg = 1;
  800d29:	83 c1 01             	add    $0x1,%ecx
  800d2c:	bf 01 00 00 00       	mov    $0x1,%edi
  800d31:	eb cb                	jmp    800cfe <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d33:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d37:	74 0e                	je     800d47 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d39:	85 db                	test   %ebx,%ebx
  800d3b:	75 d8                	jne    800d15 <strtol+0x44>
		s++, base = 8;
  800d3d:	83 c1 01             	add    $0x1,%ecx
  800d40:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d45:	eb ce                	jmp    800d15 <strtol+0x44>
		s += 2, base = 16;
  800d47:	83 c1 02             	add    $0x2,%ecx
  800d4a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d4f:	eb c4                	jmp    800d15 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d51:	0f be d2             	movsbl %dl,%edx
  800d54:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d57:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d5a:	7d 3a                	jge    800d96 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d5c:	83 c1 01             	add    $0x1,%ecx
  800d5f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d63:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d65:	0f b6 11             	movzbl (%ecx),%edx
  800d68:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d6b:	89 f3                	mov    %esi,%ebx
  800d6d:	80 fb 09             	cmp    $0x9,%bl
  800d70:	76 df                	jbe    800d51 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800d72:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d75:	89 f3                	mov    %esi,%ebx
  800d77:	80 fb 19             	cmp    $0x19,%bl
  800d7a:	77 08                	ja     800d84 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800d7c:	0f be d2             	movsbl %dl,%edx
  800d7f:	83 ea 57             	sub    $0x57,%edx
  800d82:	eb d3                	jmp    800d57 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800d84:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d87:	89 f3                	mov    %esi,%ebx
  800d89:	80 fb 19             	cmp    $0x19,%bl
  800d8c:	77 08                	ja     800d96 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d8e:	0f be d2             	movsbl %dl,%edx
  800d91:	83 ea 37             	sub    $0x37,%edx
  800d94:	eb c1                	jmp    800d57 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d96:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d9a:	74 05                	je     800da1 <strtol+0xd0>
		*endptr = (char *) s;
  800d9c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d9f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800da1:	89 c2                	mov    %eax,%edx
  800da3:	f7 da                	neg    %edx
  800da5:	85 ff                	test   %edi,%edi
  800da7:	0f 45 c2             	cmovne %edx,%eax
}
  800daa:	5b                   	pop    %ebx
  800dab:	5e                   	pop    %esi
  800dac:	5f                   	pop    %edi
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    
  800daf:	90                   	nop

00800db0 <__udivdi3>:
  800db0:	f3 0f 1e fb          	endbr32 
  800db4:	55                   	push   %ebp
  800db5:	57                   	push   %edi
  800db6:	56                   	push   %esi
  800db7:	53                   	push   %ebx
  800db8:	83 ec 1c             	sub    $0x1c,%esp
  800dbb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800dbf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800dc3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800dc7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800dcb:	85 d2                	test   %edx,%edx
  800dcd:	75 19                	jne    800de8 <__udivdi3+0x38>
  800dcf:	39 f3                	cmp    %esi,%ebx
  800dd1:	76 4d                	jbe    800e20 <__udivdi3+0x70>
  800dd3:	31 ff                	xor    %edi,%edi
  800dd5:	89 e8                	mov    %ebp,%eax
  800dd7:	89 f2                	mov    %esi,%edx
  800dd9:	f7 f3                	div    %ebx
  800ddb:	89 fa                	mov    %edi,%edx
  800ddd:	83 c4 1c             	add    $0x1c,%esp
  800de0:	5b                   	pop    %ebx
  800de1:	5e                   	pop    %esi
  800de2:	5f                   	pop    %edi
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    
  800de5:	8d 76 00             	lea    0x0(%esi),%esi
  800de8:	39 f2                	cmp    %esi,%edx
  800dea:	76 14                	jbe    800e00 <__udivdi3+0x50>
  800dec:	31 ff                	xor    %edi,%edi
  800dee:	31 c0                	xor    %eax,%eax
  800df0:	89 fa                	mov    %edi,%edx
  800df2:	83 c4 1c             	add    $0x1c,%esp
  800df5:	5b                   	pop    %ebx
  800df6:	5e                   	pop    %esi
  800df7:	5f                   	pop    %edi
  800df8:	5d                   	pop    %ebp
  800df9:	c3                   	ret    
  800dfa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e00:	0f bd fa             	bsr    %edx,%edi
  800e03:	83 f7 1f             	xor    $0x1f,%edi
  800e06:	75 48                	jne    800e50 <__udivdi3+0xa0>
  800e08:	39 f2                	cmp    %esi,%edx
  800e0a:	72 06                	jb     800e12 <__udivdi3+0x62>
  800e0c:	31 c0                	xor    %eax,%eax
  800e0e:	39 eb                	cmp    %ebp,%ebx
  800e10:	77 de                	ja     800df0 <__udivdi3+0x40>
  800e12:	b8 01 00 00 00       	mov    $0x1,%eax
  800e17:	eb d7                	jmp    800df0 <__udivdi3+0x40>
  800e19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e20:	89 d9                	mov    %ebx,%ecx
  800e22:	85 db                	test   %ebx,%ebx
  800e24:	75 0b                	jne    800e31 <__udivdi3+0x81>
  800e26:	b8 01 00 00 00       	mov    $0x1,%eax
  800e2b:	31 d2                	xor    %edx,%edx
  800e2d:	f7 f3                	div    %ebx
  800e2f:	89 c1                	mov    %eax,%ecx
  800e31:	31 d2                	xor    %edx,%edx
  800e33:	89 f0                	mov    %esi,%eax
  800e35:	f7 f1                	div    %ecx
  800e37:	89 c6                	mov    %eax,%esi
  800e39:	89 e8                	mov    %ebp,%eax
  800e3b:	89 f7                	mov    %esi,%edi
  800e3d:	f7 f1                	div    %ecx
  800e3f:	89 fa                	mov    %edi,%edx
  800e41:	83 c4 1c             	add    $0x1c,%esp
  800e44:	5b                   	pop    %ebx
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    
  800e49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e50:	89 f9                	mov    %edi,%ecx
  800e52:	b8 20 00 00 00       	mov    $0x20,%eax
  800e57:	29 f8                	sub    %edi,%eax
  800e59:	d3 e2                	shl    %cl,%edx
  800e5b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e5f:	89 c1                	mov    %eax,%ecx
  800e61:	89 da                	mov    %ebx,%edx
  800e63:	d3 ea                	shr    %cl,%edx
  800e65:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e69:	09 d1                	or     %edx,%ecx
  800e6b:	89 f2                	mov    %esi,%edx
  800e6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e71:	89 f9                	mov    %edi,%ecx
  800e73:	d3 e3                	shl    %cl,%ebx
  800e75:	89 c1                	mov    %eax,%ecx
  800e77:	d3 ea                	shr    %cl,%edx
  800e79:	89 f9                	mov    %edi,%ecx
  800e7b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e7f:	89 eb                	mov    %ebp,%ebx
  800e81:	d3 e6                	shl    %cl,%esi
  800e83:	89 c1                	mov    %eax,%ecx
  800e85:	d3 eb                	shr    %cl,%ebx
  800e87:	09 de                	or     %ebx,%esi
  800e89:	89 f0                	mov    %esi,%eax
  800e8b:	f7 74 24 08          	divl   0x8(%esp)
  800e8f:	89 d6                	mov    %edx,%esi
  800e91:	89 c3                	mov    %eax,%ebx
  800e93:	f7 64 24 0c          	mull   0xc(%esp)
  800e97:	39 d6                	cmp    %edx,%esi
  800e99:	72 15                	jb     800eb0 <__udivdi3+0x100>
  800e9b:	89 f9                	mov    %edi,%ecx
  800e9d:	d3 e5                	shl    %cl,%ebp
  800e9f:	39 c5                	cmp    %eax,%ebp
  800ea1:	73 04                	jae    800ea7 <__udivdi3+0xf7>
  800ea3:	39 d6                	cmp    %edx,%esi
  800ea5:	74 09                	je     800eb0 <__udivdi3+0x100>
  800ea7:	89 d8                	mov    %ebx,%eax
  800ea9:	31 ff                	xor    %edi,%edi
  800eab:	e9 40 ff ff ff       	jmp    800df0 <__udivdi3+0x40>
  800eb0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800eb3:	31 ff                	xor    %edi,%edi
  800eb5:	e9 36 ff ff ff       	jmp    800df0 <__udivdi3+0x40>
  800eba:	66 90                	xchg   %ax,%ax
  800ebc:	66 90                	xchg   %ax,%ax
  800ebe:	66 90                	xchg   %ax,%ax

00800ec0 <__umoddi3>:
  800ec0:	f3 0f 1e fb          	endbr32 
  800ec4:	55                   	push   %ebp
  800ec5:	57                   	push   %edi
  800ec6:	56                   	push   %esi
  800ec7:	53                   	push   %ebx
  800ec8:	83 ec 1c             	sub    $0x1c,%esp
  800ecb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800ecf:	8b 74 24 30          	mov    0x30(%esp),%esi
  800ed3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800ed7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800edb:	85 c0                	test   %eax,%eax
  800edd:	75 19                	jne    800ef8 <__umoddi3+0x38>
  800edf:	39 df                	cmp    %ebx,%edi
  800ee1:	76 5d                	jbe    800f40 <__umoddi3+0x80>
  800ee3:	89 f0                	mov    %esi,%eax
  800ee5:	89 da                	mov    %ebx,%edx
  800ee7:	f7 f7                	div    %edi
  800ee9:	89 d0                	mov    %edx,%eax
  800eeb:	31 d2                	xor    %edx,%edx
  800eed:	83 c4 1c             	add    $0x1c,%esp
  800ef0:	5b                   	pop    %ebx
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    
  800ef5:	8d 76 00             	lea    0x0(%esi),%esi
  800ef8:	89 f2                	mov    %esi,%edx
  800efa:	39 d8                	cmp    %ebx,%eax
  800efc:	76 12                	jbe    800f10 <__umoddi3+0x50>
  800efe:	89 f0                	mov    %esi,%eax
  800f00:	89 da                	mov    %ebx,%edx
  800f02:	83 c4 1c             	add    $0x1c,%esp
  800f05:	5b                   	pop    %ebx
  800f06:	5e                   	pop    %esi
  800f07:	5f                   	pop    %edi
  800f08:	5d                   	pop    %ebp
  800f09:	c3                   	ret    
  800f0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f10:	0f bd e8             	bsr    %eax,%ebp
  800f13:	83 f5 1f             	xor    $0x1f,%ebp
  800f16:	75 50                	jne    800f68 <__umoddi3+0xa8>
  800f18:	39 d8                	cmp    %ebx,%eax
  800f1a:	0f 82 e0 00 00 00    	jb     801000 <__umoddi3+0x140>
  800f20:	89 d9                	mov    %ebx,%ecx
  800f22:	39 f7                	cmp    %esi,%edi
  800f24:	0f 86 d6 00 00 00    	jbe    801000 <__umoddi3+0x140>
  800f2a:	89 d0                	mov    %edx,%eax
  800f2c:	89 ca                	mov    %ecx,%edx
  800f2e:	83 c4 1c             	add    $0x1c,%esp
  800f31:	5b                   	pop    %ebx
  800f32:	5e                   	pop    %esi
  800f33:	5f                   	pop    %edi
  800f34:	5d                   	pop    %ebp
  800f35:	c3                   	ret    
  800f36:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f3d:	8d 76 00             	lea    0x0(%esi),%esi
  800f40:	89 fd                	mov    %edi,%ebp
  800f42:	85 ff                	test   %edi,%edi
  800f44:	75 0b                	jne    800f51 <__umoddi3+0x91>
  800f46:	b8 01 00 00 00       	mov    $0x1,%eax
  800f4b:	31 d2                	xor    %edx,%edx
  800f4d:	f7 f7                	div    %edi
  800f4f:	89 c5                	mov    %eax,%ebp
  800f51:	89 d8                	mov    %ebx,%eax
  800f53:	31 d2                	xor    %edx,%edx
  800f55:	f7 f5                	div    %ebp
  800f57:	89 f0                	mov    %esi,%eax
  800f59:	f7 f5                	div    %ebp
  800f5b:	89 d0                	mov    %edx,%eax
  800f5d:	31 d2                	xor    %edx,%edx
  800f5f:	eb 8c                	jmp    800eed <__umoddi3+0x2d>
  800f61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f68:	89 e9                	mov    %ebp,%ecx
  800f6a:	ba 20 00 00 00       	mov    $0x20,%edx
  800f6f:	29 ea                	sub    %ebp,%edx
  800f71:	d3 e0                	shl    %cl,%eax
  800f73:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f77:	89 d1                	mov    %edx,%ecx
  800f79:	89 f8                	mov    %edi,%eax
  800f7b:	d3 e8                	shr    %cl,%eax
  800f7d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f81:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f85:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f89:	09 c1                	or     %eax,%ecx
  800f8b:	89 d8                	mov    %ebx,%eax
  800f8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f91:	89 e9                	mov    %ebp,%ecx
  800f93:	d3 e7                	shl    %cl,%edi
  800f95:	89 d1                	mov    %edx,%ecx
  800f97:	d3 e8                	shr    %cl,%eax
  800f99:	89 e9                	mov    %ebp,%ecx
  800f9b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800f9f:	d3 e3                	shl    %cl,%ebx
  800fa1:	89 c7                	mov    %eax,%edi
  800fa3:	89 d1                	mov    %edx,%ecx
  800fa5:	89 f0                	mov    %esi,%eax
  800fa7:	d3 e8                	shr    %cl,%eax
  800fa9:	89 e9                	mov    %ebp,%ecx
  800fab:	89 fa                	mov    %edi,%edx
  800fad:	d3 e6                	shl    %cl,%esi
  800faf:	09 d8                	or     %ebx,%eax
  800fb1:	f7 74 24 08          	divl   0x8(%esp)
  800fb5:	89 d1                	mov    %edx,%ecx
  800fb7:	89 f3                	mov    %esi,%ebx
  800fb9:	f7 64 24 0c          	mull   0xc(%esp)
  800fbd:	89 c6                	mov    %eax,%esi
  800fbf:	89 d7                	mov    %edx,%edi
  800fc1:	39 d1                	cmp    %edx,%ecx
  800fc3:	72 06                	jb     800fcb <__umoddi3+0x10b>
  800fc5:	75 10                	jne    800fd7 <__umoddi3+0x117>
  800fc7:	39 c3                	cmp    %eax,%ebx
  800fc9:	73 0c                	jae    800fd7 <__umoddi3+0x117>
  800fcb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800fcf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800fd3:	89 d7                	mov    %edx,%edi
  800fd5:	89 c6                	mov    %eax,%esi
  800fd7:	89 ca                	mov    %ecx,%edx
  800fd9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fde:	29 f3                	sub    %esi,%ebx
  800fe0:	19 fa                	sbb    %edi,%edx
  800fe2:	89 d0                	mov    %edx,%eax
  800fe4:	d3 e0                	shl    %cl,%eax
  800fe6:	89 e9                	mov    %ebp,%ecx
  800fe8:	d3 eb                	shr    %cl,%ebx
  800fea:	d3 ea                	shr    %cl,%edx
  800fec:	09 d8                	or     %ebx,%eax
  800fee:	83 c4 1c             	add    $0x1c,%esp
  800ff1:	5b                   	pop    %ebx
  800ff2:	5e                   	pop    %esi
  800ff3:	5f                   	pop    %edi
  800ff4:	5d                   	pop    %ebp
  800ff5:	c3                   	ret    
  800ff6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ffd:	8d 76 00             	lea    0x0(%esi),%esi
  801000:	29 fe                	sub    %edi,%esi
  801002:	19 c3                	sbb    %eax,%ebx
  801004:	89 f2                	mov    %esi,%edx
  801006:	89 d9                	mov    %ebx,%ecx
  801008:	e9 1d ff ff ff       	jmp    800f2a <__umoddi3+0x6a>
