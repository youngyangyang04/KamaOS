
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	9e813103          	ld	sp,-1560(sp) # 800089e8 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	070000ef          	jal	ra,80000086 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80000026:	0037969b          	slliw	a3,a5,0x3
    8000002a:	02004737          	lui	a4,0x2004
    8000002e:	96ba                	add	a3,a3,a4
    80000030:	0200c737          	lui	a4,0x200c
    80000034:	ff873603          	ld	a2,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80000038:	000f4737          	lui	a4,0xf4
    8000003c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000040:	963a                	add	a2,a2,a4
    80000042:	e290                	sd	a2,0(a3)

  // prepare information in scratch[] for timervec.
  // scratch[0..3] : space for timervec to save registers.
  // scratch[4] : address of CLINT MTIMECMP register.
  // scratch[5] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &mscratch0[32 * id];
    80000044:	0057979b          	slliw	a5,a5,0x5
    80000048:	078e                	slli	a5,a5,0x3
    8000004a:	00009617          	auipc	a2,0x9
    8000004e:	fe660613          	addi	a2,a2,-26 # 80009030 <mscratch0>
    80000052:	97b2                	add	a5,a5,a2
  scratch[4] = CLINT_MTIMECMP(id);
    80000054:	f394                	sd	a3,32(a5)
  scratch[5] = interval;
    80000056:	f798                	sd	a4,40(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000058:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000005c:	00006797          	auipc	a5,0x6
    80000060:	c9478793          	addi	a5,a5,-876 # 80005cf0 <timervec>
    80000064:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000006c:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000070:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000074:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000078:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    8000007c:	30479073          	csrw	mie,a5
}
    80000080:	6422                	ld	s0,8(sp)
    80000082:	0141                	addi	sp,sp,16
    80000084:	8082                	ret

0000000080000086 <start>:
{
    80000086:	1141                	addi	sp,sp,-16
    80000088:	e406                	sd	ra,8(sp)
    8000008a:	e022                	sd	s0,0(sp)
    8000008c:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000008e:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000092:	7779                	lui	a4,0xffffe
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	e6a78793          	addi	a5,a5,-406 # 80000f10 <main>
    800000ae:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b2:	4781                	li	a5,0
    800000b4:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000b8:	67c1                	lui	a5,0x10
    800000ba:	17fd                	addi	a5,a5,-1
    800000bc:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c0:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000c4:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000c8:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000cc:	10479073          	csrw	sie,a5
  timerinit();
    800000d0:	00000097          	auipc	ra,0x0
    800000d4:	f4c080e7          	jalr	-180(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000d8:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000dc:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000de:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e0:	30200073          	mret
}
    800000e4:	60a2                	ld	ra,8(sp)
    800000e6:	6402                	ld	s0,0(sp)
    800000e8:	0141                	addi	sp,sp,16
    800000ea:	8082                	ret

00000000800000ec <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000ec:	715d                	addi	sp,sp,-80
    800000ee:	e486                	sd	ra,72(sp)
    800000f0:	e0a2                	sd	s0,64(sp)
    800000f2:	fc26                	sd	s1,56(sp)
    800000f4:	f84a                	sd	s2,48(sp)
    800000f6:	f44e                	sd	s3,40(sp)
    800000f8:	f052                	sd	s4,32(sp)
    800000fa:	ec56                	sd	s5,24(sp)
    800000fc:	0880                	addi	s0,sp,80
    800000fe:	8a2a                	mv	s4,a0
    80000100:	84ae                	mv	s1,a1
    80000102:	89b2                	mv	s3,a2
  int i;

  acquire(&cons.lock);
    80000104:	00011517          	auipc	a0,0x11
    80000108:	72c50513          	addi	a0,a0,1836 # 80011830 <cons>
    8000010c:	00001097          	auipc	ra,0x1
    80000110:	b56080e7          	jalr	-1194(ra) # 80000c62 <acquire>
  for(i = 0; i < n; i++){
    80000114:	05305b63          	blez	s3,8000016a <consolewrite+0x7e>
    80000118:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011a:	5afd                	li	s5,-1
    8000011c:	4685                	li	a3,1
    8000011e:	8626                	mv	a2,s1
    80000120:	85d2                	mv	a1,s4
    80000122:	fbf40513          	addi	a0,s0,-65
    80000126:	00002097          	auipc	ra,0x2
    8000012a:	3da080e7          	jalr	986(ra) # 80002500 <either_copyin>
    8000012e:	01550c63          	beq	a0,s5,80000146 <consolewrite+0x5a>
      break;
    uartputc(c);
    80000132:	fbf44503          	lbu	a0,-65(s0)
    80000136:	00000097          	auipc	ra,0x0
    8000013a:	7aa080e7          	jalr	1962(ra) # 800008e0 <uartputc>
  for(i = 0; i < n; i++){
    8000013e:	2905                	addiw	s2,s2,1
    80000140:	0485                	addi	s1,s1,1
    80000142:	fd299de3          	bne	s3,s2,8000011c <consolewrite+0x30>
  }
  release(&cons.lock);
    80000146:	00011517          	auipc	a0,0x11
    8000014a:	6ea50513          	addi	a0,a0,1770 # 80011830 <cons>
    8000014e:	00001097          	auipc	ra,0x1
    80000152:	bc8080e7          	jalr	-1080(ra) # 80000d16 <release>

  return i;
}
    80000156:	854a                	mv	a0,s2
    80000158:	60a6                	ld	ra,72(sp)
    8000015a:	6406                	ld	s0,64(sp)
    8000015c:	74e2                	ld	s1,56(sp)
    8000015e:	7942                	ld	s2,48(sp)
    80000160:	79a2                	ld	s3,40(sp)
    80000162:	7a02                	ld	s4,32(sp)
    80000164:	6ae2                	ld	s5,24(sp)
    80000166:	6161                	addi	sp,sp,80
    80000168:	8082                	ret
  for(i = 0; i < n; i++){
    8000016a:	4901                	li	s2,0
    8000016c:	bfe9                	j	80000146 <consolewrite+0x5a>

000000008000016e <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	7119                	addi	sp,sp,-128
    80000170:	fc86                	sd	ra,120(sp)
    80000172:	f8a2                	sd	s0,112(sp)
    80000174:	f4a6                	sd	s1,104(sp)
    80000176:	f0ca                	sd	s2,96(sp)
    80000178:	ecce                	sd	s3,88(sp)
    8000017a:	e8d2                	sd	s4,80(sp)
    8000017c:	e4d6                	sd	s5,72(sp)
    8000017e:	e0da                	sd	s6,64(sp)
    80000180:	fc5e                	sd	s7,56(sp)
    80000182:	f862                	sd	s8,48(sp)
    80000184:	f466                	sd	s9,40(sp)
    80000186:	f06a                	sd	s10,32(sp)
    80000188:	ec6e                	sd	s11,24(sp)
    8000018a:	0100                	addi	s0,sp,128
    8000018c:	8b2a                	mv	s6,a0
    8000018e:	8aae                	mv	s5,a1
    80000190:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000192:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    80000196:	00011517          	auipc	a0,0x11
    8000019a:	69a50513          	addi	a0,a0,1690 # 80011830 <cons>
    8000019e:	00001097          	auipc	ra,0x1
    800001a2:	ac4080e7          	jalr	-1340(ra) # 80000c62 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001a6:	00011497          	auipc	s1,0x11
    800001aa:	68a48493          	addi	s1,s1,1674 # 80011830 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001ae:	89a6                	mv	s3,s1
    800001b0:	00011917          	auipc	s2,0x11
    800001b4:	71890913          	addi	s2,s2,1816 # 800118c8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001b8:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ba:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001bc:	4da9                	li	s11,10
  while(n > 0){
    800001be:	07405863          	blez	s4,8000022e <consoleread+0xc0>
    while(cons.r == cons.w){
    800001c2:	0984a783          	lw	a5,152(s1)
    800001c6:	09c4a703          	lw	a4,156(s1)
    800001ca:	02f71463          	bne	a4,a5,800001f2 <consoleread+0x84>
      if(myproc()->killed){
    800001ce:	00002097          	auipc	ra,0x2
    800001d2:	862080e7          	jalr	-1950(ra) # 80001a30 <myproc>
    800001d6:	591c                	lw	a5,48(a0)
    800001d8:	e7b5                	bnez	a5,80000244 <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001da:	85ce                	mv	a1,s3
    800001dc:	854a                	mv	a0,s2
    800001de:	00002097          	auipc	ra,0x2
    800001e2:	06a080e7          	jalr	106(ra) # 80002248 <sleep>
    while(cons.r == cons.w){
    800001e6:	0984a783          	lw	a5,152(s1)
    800001ea:	09c4a703          	lw	a4,156(s1)
    800001ee:	fef700e3          	beq	a4,a5,800001ce <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001f2:	0017871b          	addiw	a4,a5,1
    800001f6:	08e4ac23          	sw	a4,152(s1)
    800001fa:	07f7f713          	andi	a4,a5,127
    800001fe:	9726                	add	a4,a4,s1
    80000200:	01874703          	lbu	a4,24(a4)
    80000204:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    80000208:	079c0663          	beq	s8,s9,80000274 <consoleread+0x106>
    cbuf = c;
    8000020c:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000210:	4685                	li	a3,1
    80000212:	f8f40613          	addi	a2,s0,-113
    80000216:	85d6                	mv	a1,s5
    80000218:	855a                	mv	a0,s6
    8000021a:	00002097          	auipc	ra,0x2
    8000021e:	290080e7          	jalr	656(ra) # 800024aa <either_copyout>
    80000222:	01a50663          	beq	a0,s10,8000022e <consoleread+0xc0>
    dst++;
    80000226:	0a85                	addi	s5,s5,1
    --n;
    80000228:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    8000022a:	f9bc1ae3          	bne	s8,s11,800001be <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    8000022e:	00011517          	auipc	a0,0x11
    80000232:	60250513          	addi	a0,a0,1538 # 80011830 <cons>
    80000236:	00001097          	auipc	ra,0x1
    8000023a:	ae0080e7          	jalr	-1312(ra) # 80000d16 <release>

  return target - n;
    8000023e:	414b853b          	subw	a0,s7,s4
    80000242:	a811                	j	80000256 <consoleread+0xe8>
        release(&cons.lock);
    80000244:	00011517          	auipc	a0,0x11
    80000248:	5ec50513          	addi	a0,a0,1516 # 80011830 <cons>
    8000024c:	00001097          	auipc	ra,0x1
    80000250:	aca080e7          	jalr	-1334(ra) # 80000d16 <release>
        return -1;
    80000254:	557d                	li	a0,-1
}
    80000256:	70e6                	ld	ra,120(sp)
    80000258:	7446                	ld	s0,112(sp)
    8000025a:	74a6                	ld	s1,104(sp)
    8000025c:	7906                	ld	s2,96(sp)
    8000025e:	69e6                	ld	s3,88(sp)
    80000260:	6a46                	ld	s4,80(sp)
    80000262:	6aa6                	ld	s5,72(sp)
    80000264:	6b06                	ld	s6,64(sp)
    80000266:	7be2                	ld	s7,56(sp)
    80000268:	7c42                	ld	s8,48(sp)
    8000026a:	7ca2                	ld	s9,40(sp)
    8000026c:	7d02                	ld	s10,32(sp)
    8000026e:	6de2                	ld	s11,24(sp)
    80000270:	6109                	addi	sp,sp,128
    80000272:	8082                	ret
      if(n < target){
    80000274:	000a071b          	sext.w	a4,s4
    80000278:	fb777be3          	bgeu	a4,s7,8000022e <consoleread+0xc0>
        cons.r--;
    8000027c:	00011717          	auipc	a4,0x11
    80000280:	64f72623          	sw	a5,1612(a4) # 800118c8 <cons+0x98>
    80000284:	b76d                	j	8000022e <consoleread+0xc0>

0000000080000286 <consputc>:
{
    80000286:	1141                	addi	sp,sp,-16
    80000288:	e406                	sd	ra,8(sp)
    8000028a:	e022                	sd	s0,0(sp)
    8000028c:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000028e:	10000793          	li	a5,256
    80000292:	00f50a63          	beq	a0,a5,800002a6 <consputc+0x20>
    uartputc_sync(c);
    80000296:	00000097          	auipc	ra,0x0
    8000029a:	564080e7          	jalr	1380(ra) # 800007fa <uartputc_sync>
}
    8000029e:	60a2                	ld	ra,8(sp)
    800002a0:	6402                	ld	s0,0(sp)
    800002a2:	0141                	addi	sp,sp,16
    800002a4:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002a6:	4521                	li	a0,8
    800002a8:	00000097          	auipc	ra,0x0
    800002ac:	552080e7          	jalr	1362(ra) # 800007fa <uartputc_sync>
    800002b0:	02000513          	li	a0,32
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	546080e7          	jalr	1350(ra) # 800007fa <uartputc_sync>
    800002bc:	4521                	li	a0,8
    800002be:	00000097          	auipc	ra,0x0
    800002c2:	53c080e7          	jalr	1340(ra) # 800007fa <uartputc_sync>
    800002c6:	bfe1                	j	8000029e <consputc+0x18>

00000000800002c8 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002c8:	1101                	addi	sp,sp,-32
    800002ca:	ec06                	sd	ra,24(sp)
    800002cc:	e822                	sd	s0,16(sp)
    800002ce:	e426                	sd	s1,8(sp)
    800002d0:	e04a                	sd	s2,0(sp)
    800002d2:	1000                	addi	s0,sp,32
    800002d4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002d6:	00011517          	auipc	a0,0x11
    800002da:	55a50513          	addi	a0,a0,1370 # 80011830 <cons>
    800002de:	00001097          	auipc	ra,0x1
    800002e2:	984080e7          	jalr	-1660(ra) # 80000c62 <acquire>

  switch(c){
    800002e6:	47d5                	li	a5,21
    800002e8:	0af48663          	beq	s1,a5,80000394 <consoleintr+0xcc>
    800002ec:	0297ca63          	blt	a5,s1,80000320 <consoleintr+0x58>
    800002f0:	47a1                	li	a5,8
    800002f2:	0ef48763          	beq	s1,a5,800003e0 <consoleintr+0x118>
    800002f6:	47c1                	li	a5,16
    800002f8:	10f49a63          	bne	s1,a5,8000040c <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002fc:	00002097          	auipc	ra,0x2
    80000300:	25a080e7          	jalr	602(ra) # 80002556 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000304:	00011517          	auipc	a0,0x11
    80000308:	52c50513          	addi	a0,a0,1324 # 80011830 <cons>
    8000030c:	00001097          	auipc	ra,0x1
    80000310:	a0a080e7          	jalr	-1526(ra) # 80000d16 <release>
}
    80000314:	60e2                	ld	ra,24(sp)
    80000316:	6442                	ld	s0,16(sp)
    80000318:	64a2                	ld	s1,8(sp)
    8000031a:	6902                	ld	s2,0(sp)
    8000031c:	6105                	addi	sp,sp,32
    8000031e:	8082                	ret
  switch(c){
    80000320:	07f00793          	li	a5,127
    80000324:	0af48e63          	beq	s1,a5,800003e0 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000328:	00011717          	auipc	a4,0x11
    8000032c:	50870713          	addi	a4,a4,1288 # 80011830 <cons>
    80000330:	0a072783          	lw	a5,160(a4)
    80000334:	09872703          	lw	a4,152(a4)
    80000338:	9f99                	subw	a5,a5,a4
    8000033a:	07f00713          	li	a4,127
    8000033e:	fcf763e3          	bltu	a4,a5,80000304 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000342:	47b5                	li	a5,13
    80000344:	0cf48763          	beq	s1,a5,80000412 <consoleintr+0x14a>
      consputc(c);
    80000348:	8526                	mv	a0,s1
    8000034a:	00000097          	auipc	ra,0x0
    8000034e:	f3c080e7          	jalr	-196(ra) # 80000286 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000352:	00011797          	auipc	a5,0x11
    80000356:	4de78793          	addi	a5,a5,1246 # 80011830 <cons>
    8000035a:	0a07a703          	lw	a4,160(a5)
    8000035e:	0017069b          	addiw	a3,a4,1
    80000362:	0006861b          	sext.w	a2,a3
    80000366:	0ad7a023          	sw	a3,160(a5)
    8000036a:	07f77713          	andi	a4,a4,127
    8000036e:	97ba                	add	a5,a5,a4
    80000370:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000374:	47a9                	li	a5,10
    80000376:	0cf48563          	beq	s1,a5,80000440 <consoleintr+0x178>
    8000037a:	4791                	li	a5,4
    8000037c:	0cf48263          	beq	s1,a5,80000440 <consoleintr+0x178>
    80000380:	00011797          	auipc	a5,0x11
    80000384:	5487a783          	lw	a5,1352(a5) # 800118c8 <cons+0x98>
    80000388:	0807879b          	addiw	a5,a5,128
    8000038c:	f6f61ce3          	bne	a2,a5,80000304 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000390:	863e                	mv	a2,a5
    80000392:	a07d                	j	80000440 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000394:	00011717          	auipc	a4,0x11
    80000398:	49c70713          	addi	a4,a4,1180 # 80011830 <cons>
    8000039c:	0a072783          	lw	a5,160(a4)
    800003a0:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a4:	00011497          	auipc	s1,0x11
    800003a8:	48c48493          	addi	s1,s1,1164 # 80011830 <cons>
    while(cons.e != cons.w &&
    800003ac:	4929                	li	s2,10
    800003ae:	f4f70be3          	beq	a4,a5,80000304 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003b2:	37fd                	addiw	a5,a5,-1
    800003b4:	07f7f713          	andi	a4,a5,127
    800003b8:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003ba:	01874703          	lbu	a4,24(a4)
    800003be:	f52703e3          	beq	a4,s2,80000304 <consoleintr+0x3c>
      cons.e--;
    800003c2:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003c6:	10000513          	li	a0,256
    800003ca:	00000097          	auipc	ra,0x0
    800003ce:	ebc080e7          	jalr	-324(ra) # 80000286 <consputc>
    while(cons.e != cons.w &&
    800003d2:	0a04a783          	lw	a5,160(s1)
    800003d6:	09c4a703          	lw	a4,156(s1)
    800003da:	fcf71ce3          	bne	a4,a5,800003b2 <consoleintr+0xea>
    800003de:	b71d                	j	80000304 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003e0:	00011717          	auipc	a4,0x11
    800003e4:	45070713          	addi	a4,a4,1104 # 80011830 <cons>
    800003e8:	0a072783          	lw	a5,160(a4)
    800003ec:	09c72703          	lw	a4,156(a4)
    800003f0:	f0f70ae3          	beq	a4,a5,80000304 <consoleintr+0x3c>
      cons.e--;
    800003f4:	37fd                	addiw	a5,a5,-1
    800003f6:	00011717          	auipc	a4,0x11
    800003fa:	4cf72d23          	sw	a5,1242(a4) # 800118d0 <cons+0xa0>
      consputc(BACKSPACE);
    800003fe:	10000513          	li	a0,256
    80000402:	00000097          	auipc	ra,0x0
    80000406:	e84080e7          	jalr	-380(ra) # 80000286 <consputc>
    8000040a:	bded                	j	80000304 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000040c:	ee048ce3          	beqz	s1,80000304 <consoleintr+0x3c>
    80000410:	bf21                	j	80000328 <consoleintr+0x60>
      consputc(c);
    80000412:	4529                	li	a0,10
    80000414:	00000097          	auipc	ra,0x0
    80000418:	e72080e7          	jalr	-398(ra) # 80000286 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000041c:	00011797          	auipc	a5,0x11
    80000420:	41478793          	addi	a5,a5,1044 # 80011830 <cons>
    80000424:	0a07a703          	lw	a4,160(a5)
    80000428:	0017069b          	addiw	a3,a4,1
    8000042c:	0006861b          	sext.w	a2,a3
    80000430:	0ad7a023          	sw	a3,160(a5)
    80000434:	07f77713          	andi	a4,a4,127
    80000438:	97ba                	add	a5,a5,a4
    8000043a:	4729                	li	a4,10
    8000043c:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000440:	00011797          	auipc	a5,0x11
    80000444:	48c7a623          	sw	a2,1164(a5) # 800118cc <cons+0x9c>
        wakeup(&cons.r);
    80000448:	00011517          	auipc	a0,0x11
    8000044c:	48050513          	addi	a0,a0,1152 # 800118c8 <cons+0x98>
    80000450:	00002097          	auipc	ra,0x2
    80000454:	f7e080e7          	jalr	-130(ra) # 800023ce <wakeup>
    80000458:	b575                	j	80000304 <consoleintr+0x3c>

000000008000045a <consoleinit>:

void
consoleinit(void)
{
    8000045a:	1141                	addi	sp,sp,-16
    8000045c:	e406                	sd	ra,8(sp)
    8000045e:	e022                	sd	s0,0(sp)
    80000460:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000462:	00008597          	auipc	a1,0x8
    80000466:	bae58593          	addi	a1,a1,-1106 # 80008010 <etext+0x10>
    8000046a:	00011517          	auipc	a0,0x11
    8000046e:	3c650513          	addi	a0,a0,966 # 80011830 <cons>
    80000472:	00000097          	auipc	ra,0x0
    80000476:	760080e7          	jalr	1888(ra) # 80000bd2 <initlock>

  uartinit();
    8000047a:	00000097          	auipc	ra,0x0
    8000047e:	330080e7          	jalr	816(ra) # 800007aa <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000482:	00021797          	auipc	a5,0x21
    80000486:	72e78793          	addi	a5,a5,1838 # 80021bb0 <devsw>
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	ce470713          	addi	a4,a4,-796 # 8000016e <consoleread>
    80000492:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000494:	00000717          	auipc	a4,0x0
    80000498:	c5870713          	addi	a4,a4,-936 # 800000ec <consolewrite>
    8000049c:	ef98                	sd	a4,24(a5)
}
    8000049e:	60a2                	ld	ra,8(sp)
    800004a0:	6402                	ld	s0,0(sp)
    800004a2:	0141                	addi	sp,sp,16
    800004a4:	8082                	ret

00000000800004a6 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004a6:	7179                	addi	sp,sp,-48
    800004a8:	f406                	sd	ra,40(sp)
    800004aa:	f022                	sd	s0,32(sp)
    800004ac:	ec26                	sd	s1,24(sp)
    800004ae:	e84a                	sd	s2,16(sp)
    800004b0:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004b2:	c219                	beqz	a2,800004b8 <printint+0x12>
    800004b4:	08054663          	bltz	a0,80000540 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004b8:	2501                	sext.w	a0,a0
    800004ba:	4881                	li	a7,0
    800004bc:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004c0:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004c2:	2581                	sext.w	a1,a1
    800004c4:	00008617          	auipc	a2,0x8
    800004c8:	b7c60613          	addi	a2,a2,-1156 # 80008040 <digits>
    800004cc:	883a                	mv	a6,a4
    800004ce:	2705                	addiw	a4,a4,1
    800004d0:	02b577bb          	remuw	a5,a0,a1
    800004d4:	1782                	slli	a5,a5,0x20
    800004d6:	9381                	srli	a5,a5,0x20
    800004d8:	97b2                	add	a5,a5,a2
    800004da:	0007c783          	lbu	a5,0(a5)
    800004de:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004e2:	0005079b          	sext.w	a5,a0
    800004e6:	02b5553b          	divuw	a0,a0,a1
    800004ea:	0685                	addi	a3,a3,1
    800004ec:	feb7f0e3          	bgeu	a5,a1,800004cc <printint+0x26>

  if(sign)
    800004f0:	00088b63          	beqz	a7,80000506 <printint+0x60>
    buf[i++] = '-';
    800004f4:	fe040793          	addi	a5,s0,-32
    800004f8:	973e                	add	a4,a4,a5
    800004fa:	02d00793          	li	a5,45
    800004fe:	fef70823          	sb	a5,-16(a4)
    80000502:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000506:	02e05763          	blez	a4,80000534 <printint+0x8e>
    8000050a:	fd040793          	addi	a5,s0,-48
    8000050e:	00e784b3          	add	s1,a5,a4
    80000512:	fff78913          	addi	s2,a5,-1
    80000516:	993a                	add	s2,s2,a4
    80000518:	377d                	addiw	a4,a4,-1
    8000051a:	1702                	slli	a4,a4,0x20
    8000051c:	9301                	srli	a4,a4,0x20
    8000051e:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000522:	fff4c503          	lbu	a0,-1(s1)
    80000526:	00000097          	auipc	ra,0x0
    8000052a:	d60080e7          	jalr	-672(ra) # 80000286 <consputc>
  while(--i >= 0)
    8000052e:	14fd                	addi	s1,s1,-1
    80000530:	ff2499e3          	bne	s1,s2,80000522 <printint+0x7c>
}
    80000534:	70a2                	ld	ra,40(sp)
    80000536:	7402                	ld	s0,32(sp)
    80000538:	64e2                	ld	s1,24(sp)
    8000053a:	6942                	ld	s2,16(sp)
    8000053c:	6145                	addi	sp,sp,48
    8000053e:	8082                	ret
    x = -xx;
    80000540:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000544:	4885                	li	a7,1
    x = -xx;
    80000546:	bf9d                	j	800004bc <printint+0x16>

0000000080000548 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000548:	1101                	addi	sp,sp,-32
    8000054a:	ec06                	sd	ra,24(sp)
    8000054c:	e822                	sd	s0,16(sp)
    8000054e:	e426                	sd	s1,8(sp)
    80000550:	1000                	addi	s0,sp,32
    80000552:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000554:	00011797          	auipc	a5,0x11
    80000558:	3807ae23          	sw	zero,924(a5) # 800118f0 <pr+0x18>
  printf("panic: ");
    8000055c:	00008517          	auipc	a0,0x8
    80000560:	abc50513          	addi	a0,a0,-1348 # 80008018 <etext+0x18>
    80000564:	00000097          	auipc	ra,0x0
    80000568:	02e080e7          	jalr	46(ra) # 80000592 <printf>
  printf(s);
    8000056c:	8526                	mv	a0,s1
    8000056e:	00000097          	auipc	ra,0x0
    80000572:	024080e7          	jalr	36(ra) # 80000592 <printf>
  printf("\n");
    80000576:	00008517          	auipc	a0,0x8
    8000057a:	b5250513          	addi	a0,a0,-1198 # 800080c8 <digits+0x88>
    8000057e:	00000097          	auipc	ra,0x0
    80000582:	014080e7          	jalr	20(ra) # 80000592 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000586:	4785                	li	a5,1
    80000588:	00009717          	auipc	a4,0x9
    8000058c:	a6f72c23          	sw	a5,-1416(a4) # 80009000 <panicked>
  for(;;)
    80000590:	a001                	j	80000590 <panic+0x48>

0000000080000592 <printf>:
{
    80000592:	7131                	addi	sp,sp,-192
    80000594:	fc86                	sd	ra,120(sp)
    80000596:	f8a2                	sd	s0,112(sp)
    80000598:	f4a6                	sd	s1,104(sp)
    8000059a:	f0ca                	sd	s2,96(sp)
    8000059c:	ecce                	sd	s3,88(sp)
    8000059e:	e8d2                	sd	s4,80(sp)
    800005a0:	e4d6                	sd	s5,72(sp)
    800005a2:	e0da                	sd	s6,64(sp)
    800005a4:	fc5e                	sd	s7,56(sp)
    800005a6:	f862                	sd	s8,48(sp)
    800005a8:	f466                	sd	s9,40(sp)
    800005aa:	f06a                	sd	s10,32(sp)
    800005ac:	ec6e                	sd	s11,24(sp)
    800005ae:	0100                	addi	s0,sp,128
    800005b0:	8a2a                	mv	s4,a0
    800005b2:	e40c                	sd	a1,8(s0)
    800005b4:	e810                	sd	a2,16(s0)
    800005b6:	ec14                	sd	a3,24(s0)
    800005b8:	f018                	sd	a4,32(s0)
    800005ba:	f41c                	sd	a5,40(s0)
    800005bc:	03043823          	sd	a6,48(s0)
    800005c0:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005c4:	00011d97          	auipc	s11,0x11
    800005c8:	32cdad83          	lw	s11,812(s11) # 800118f0 <pr+0x18>
  if(locking)
    800005cc:	020d9b63          	bnez	s11,80000602 <printf+0x70>
  if (fmt == 0)
    800005d0:	040a0263          	beqz	s4,80000614 <printf+0x82>
  va_start(ap, fmt);
    800005d4:	00840793          	addi	a5,s0,8
    800005d8:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005dc:	000a4503          	lbu	a0,0(s4)
    800005e0:	16050263          	beqz	a0,80000744 <printf+0x1b2>
    800005e4:	4481                	li	s1,0
    if(c != '%'){
    800005e6:	02500a93          	li	s5,37
    switch(c){
    800005ea:	07000b13          	li	s6,112
  consputc('x');
    800005ee:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005f0:	00008b97          	auipc	s7,0x8
    800005f4:	a50b8b93          	addi	s7,s7,-1456 # 80008040 <digits>
    switch(c){
    800005f8:	07300c93          	li	s9,115
    800005fc:	06400c13          	li	s8,100
    80000600:	a82d                	j	8000063a <printf+0xa8>
    acquire(&pr.lock);
    80000602:	00011517          	auipc	a0,0x11
    80000606:	2d650513          	addi	a0,a0,726 # 800118d8 <pr>
    8000060a:	00000097          	auipc	ra,0x0
    8000060e:	658080e7          	jalr	1624(ra) # 80000c62 <acquire>
    80000612:	bf7d                	j	800005d0 <printf+0x3e>
    panic("null fmt");
    80000614:	00008517          	auipc	a0,0x8
    80000618:	a1450513          	addi	a0,a0,-1516 # 80008028 <etext+0x28>
    8000061c:	00000097          	auipc	ra,0x0
    80000620:	f2c080e7          	jalr	-212(ra) # 80000548 <panic>
      consputc(c);
    80000624:	00000097          	auipc	ra,0x0
    80000628:	c62080e7          	jalr	-926(ra) # 80000286 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000062c:	2485                	addiw	s1,s1,1
    8000062e:	009a07b3          	add	a5,s4,s1
    80000632:	0007c503          	lbu	a0,0(a5)
    80000636:	10050763          	beqz	a0,80000744 <printf+0x1b2>
    if(c != '%'){
    8000063a:	ff5515e3          	bne	a0,s5,80000624 <printf+0x92>
    c = fmt[++i] & 0xff;
    8000063e:	2485                	addiw	s1,s1,1
    80000640:	009a07b3          	add	a5,s4,s1
    80000644:	0007c783          	lbu	a5,0(a5)
    80000648:	0007891b          	sext.w	s2,a5
    if(c == 0)
    8000064c:	cfe5                	beqz	a5,80000744 <printf+0x1b2>
    switch(c){
    8000064e:	05678a63          	beq	a5,s6,800006a2 <printf+0x110>
    80000652:	02fb7663          	bgeu	s6,a5,8000067e <printf+0xec>
    80000656:	09978963          	beq	a5,s9,800006e8 <printf+0x156>
    8000065a:	07800713          	li	a4,120
    8000065e:	0ce79863          	bne	a5,a4,8000072e <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    80000662:	f8843783          	ld	a5,-120(s0)
    80000666:	00878713          	addi	a4,a5,8
    8000066a:	f8e43423          	sd	a4,-120(s0)
    8000066e:	4605                	li	a2,1
    80000670:	85ea                	mv	a1,s10
    80000672:	4388                	lw	a0,0(a5)
    80000674:	00000097          	auipc	ra,0x0
    80000678:	e32080e7          	jalr	-462(ra) # 800004a6 <printint>
      break;
    8000067c:	bf45                	j	8000062c <printf+0x9a>
    switch(c){
    8000067e:	0b578263          	beq	a5,s5,80000722 <printf+0x190>
    80000682:	0b879663          	bne	a5,s8,8000072e <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    80000686:	f8843783          	ld	a5,-120(s0)
    8000068a:	00878713          	addi	a4,a5,8
    8000068e:	f8e43423          	sd	a4,-120(s0)
    80000692:	4605                	li	a2,1
    80000694:	45a9                	li	a1,10
    80000696:	4388                	lw	a0,0(a5)
    80000698:	00000097          	auipc	ra,0x0
    8000069c:	e0e080e7          	jalr	-498(ra) # 800004a6 <printint>
      break;
    800006a0:	b771                	j	8000062c <printf+0x9a>
      printptr(va_arg(ap, uint64));
    800006a2:	f8843783          	ld	a5,-120(s0)
    800006a6:	00878713          	addi	a4,a5,8
    800006aa:	f8e43423          	sd	a4,-120(s0)
    800006ae:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006b2:	03000513          	li	a0,48
    800006b6:	00000097          	auipc	ra,0x0
    800006ba:	bd0080e7          	jalr	-1072(ra) # 80000286 <consputc>
  consputc('x');
    800006be:	07800513          	li	a0,120
    800006c2:	00000097          	auipc	ra,0x0
    800006c6:	bc4080e7          	jalr	-1084(ra) # 80000286 <consputc>
    800006ca:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006cc:	03c9d793          	srli	a5,s3,0x3c
    800006d0:	97de                	add	a5,a5,s7
    800006d2:	0007c503          	lbu	a0,0(a5)
    800006d6:	00000097          	auipc	ra,0x0
    800006da:	bb0080e7          	jalr	-1104(ra) # 80000286 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006de:	0992                	slli	s3,s3,0x4
    800006e0:	397d                	addiw	s2,s2,-1
    800006e2:	fe0915e3          	bnez	s2,800006cc <printf+0x13a>
    800006e6:	b799                	j	8000062c <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006e8:	f8843783          	ld	a5,-120(s0)
    800006ec:	00878713          	addi	a4,a5,8
    800006f0:	f8e43423          	sd	a4,-120(s0)
    800006f4:	0007b903          	ld	s2,0(a5)
    800006f8:	00090e63          	beqz	s2,80000714 <printf+0x182>
      for(; *s; s++)
    800006fc:	00094503          	lbu	a0,0(s2)
    80000700:	d515                	beqz	a0,8000062c <printf+0x9a>
        consputc(*s);
    80000702:	00000097          	auipc	ra,0x0
    80000706:	b84080e7          	jalr	-1148(ra) # 80000286 <consputc>
      for(; *s; s++)
    8000070a:	0905                	addi	s2,s2,1
    8000070c:	00094503          	lbu	a0,0(s2)
    80000710:	f96d                	bnez	a0,80000702 <printf+0x170>
    80000712:	bf29                	j	8000062c <printf+0x9a>
        s = "(null)";
    80000714:	00008917          	auipc	s2,0x8
    80000718:	90c90913          	addi	s2,s2,-1780 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000071c:	02800513          	li	a0,40
    80000720:	b7cd                	j	80000702 <printf+0x170>
      consputc('%');
    80000722:	8556                	mv	a0,s5
    80000724:	00000097          	auipc	ra,0x0
    80000728:	b62080e7          	jalr	-1182(ra) # 80000286 <consputc>
      break;
    8000072c:	b701                	j	8000062c <printf+0x9a>
      consputc('%');
    8000072e:	8556                	mv	a0,s5
    80000730:	00000097          	auipc	ra,0x0
    80000734:	b56080e7          	jalr	-1194(ra) # 80000286 <consputc>
      consputc(c);
    80000738:	854a                	mv	a0,s2
    8000073a:	00000097          	auipc	ra,0x0
    8000073e:	b4c080e7          	jalr	-1204(ra) # 80000286 <consputc>
      break;
    80000742:	b5ed                	j	8000062c <printf+0x9a>
  if(locking)
    80000744:	020d9163          	bnez	s11,80000766 <printf+0x1d4>
}
    80000748:	70e6                	ld	ra,120(sp)
    8000074a:	7446                	ld	s0,112(sp)
    8000074c:	74a6                	ld	s1,104(sp)
    8000074e:	7906                	ld	s2,96(sp)
    80000750:	69e6                	ld	s3,88(sp)
    80000752:	6a46                	ld	s4,80(sp)
    80000754:	6aa6                	ld	s5,72(sp)
    80000756:	6b06                	ld	s6,64(sp)
    80000758:	7be2                	ld	s7,56(sp)
    8000075a:	7c42                	ld	s8,48(sp)
    8000075c:	7ca2                	ld	s9,40(sp)
    8000075e:	7d02                	ld	s10,32(sp)
    80000760:	6de2                	ld	s11,24(sp)
    80000762:	6129                	addi	sp,sp,192
    80000764:	8082                	ret
    release(&pr.lock);
    80000766:	00011517          	auipc	a0,0x11
    8000076a:	17250513          	addi	a0,a0,370 # 800118d8 <pr>
    8000076e:	00000097          	auipc	ra,0x0
    80000772:	5a8080e7          	jalr	1448(ra) # 80000d16 <release>
}
    80000776:	bfc9                	j	80000748 <printf+0x1b6>

0000000080000778 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000778:	1101                	addi	sp,sp,-32
    8000077a:	ec06                	sd	ra,24(sp)
    8000077c:	e822                	sd	s0,16(sp)
    8000077e:	e426                	sd	s1,8(sp)
    80000780:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000782:	00011497          	auipc	s1,0x11
    80000786:	15648493          	addi	s1,s1,342 # 800118d8 <pr>
    8000078a:	00008597          	auipc	a1,0x8
    8000078e:	8ae58593          	addi	a1,a1,-1874 # 80008038 <etext+0x38>
    80000792:	8526                	mv	a0,s1
    80000794:	00000097          	auipc	ra,0x0
    80000798:	43e080e7          	jalr	1086(ra) # 80000bd2 <initlock>
  pr.locking = 1;
    8000079c:	4785                	li	a5,1
    8000079e:	cc9c                	sw	a5,24(s1)
}
    800007a0:	60e2                	ld	ra,24(sp)
    800007a2:	6442                	ld	s0,16(sp)
    800007a4:	64a2                	ld	s1,8(sp)
    800007a6:	6105                	addi	sp,sp,32
    800007a8:	8082                	ret

00000000800007aa <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007aa:	1141                	addi	sp,sp,-16
    800007ac:	e406                	sd	ra,8(sp)
    800007ae:	e022                	sd	s0,0(sp)
    800007b0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007b2:	100007b7          	lui	a5,0x10000
    800007b6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ba:	f8000713          	li	a4,-128
    800007be:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007c2:	470d                	li	a4,3
    800007c4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007c8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007cc:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007d0:	469d                	li	a3,7
    800007d2:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007d6:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007da:	00008597          	auipc	a1,0x8
    800007de:	87e58593          	addi	a1,a1,-1922 # 80008058 <digits+0x18>
    800007e2:	00011517          	auipc	a0,0x11
    800007e6:	11650513          	addi	a0,a0,278 # 800118f8 <uart_tx_lock>
    800007ea:	00000097          	auipc	ra,0x0
    800007ee:	3e8080e7          	jalr	1000(ra) # 80000bd2 <initlock>
}
    800007f2:	60a2                	ld	ra,8(sp)
    800007f4:	6402                	ld	s0,0(sp)
    800007f6:	0141                	addi	sp,sp,16
    800007f8:	8082                	ret

00000000800007fa <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007fa:	1101                	addi	sp,sp,-32
    800007fc:	ec06                	sd	ra,24(sp)
    800007fe:	e822                	sd	s0,16(sp)
    80000800:	e426                	sd	s1,8(sp)
    80000802:	1000                	addi	s0,sp,32
    80000804:	84aa                	mv	s1,a0
  push_off();
    80000806:	00000097          	auipc	ra,0x0
    8000080a:	410080e7          	jalr	1040(ra) # 80000c16 <push_off>

  if(panicked){
    8000080e:	00008797          	auipc	a5,0x8
    80000812:	7f27a783          	lw	a5,2034(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000816:	10000737          	lui	a4,0x10000
  if(panicked){
    8000081a:	c391                	beqz	a5,8000081e <uartputc_sync+0x24>
    for(;;)
    8000081c:	a001                	j	8000081c <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000081e:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000822:	0ff7f793          	andi	a5,a5,255
    80000826:	0207f793          	andi	a5,a5,32
    8000082a:	dbf5                	beqz	a5,8000081e <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000082c:	0ff4f793          	andi	a5,s1,255
    80000830:	10000737          	lui	a4,0x10000
    80000834:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    80000838:	00000097          	auipc	ra,0x0
    8000083c:	47e080e7          	jalr	1150(ra) # 80000cb6 <pop_off>
}
    80000840:	60e2                	ld	ra,24(sp)
    80000842:	6442                	ld	s0,16(sp)
    80000844:	64a2                	ld	s1,8(sp)
    80000846:	6105                	addi	sp,sp,32
    80000848:	8082                	ret

000000008000084a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000084a:	00008797          	auipc	a5,0x8
    8000084e:	7ba7a783          	lw	a5,1978(a5) # 80009004 <uart_tx_r>
    80000852:	00008717          	auipc	a4,0x8
    80000856:	7b672703          	lw	a4,1974(a4) # 80009008 <uart_tx_w>
    8000085a:	08f70263          	beq	a4,a5,800008de <uartstart+0x94>
{
    8000085e:	7139                	addi	sp,sp,-64
    80000860:	fc06                	sd	ra,56(sp)
    80000862:	f822                	sd	s0,48(sp)
    80000864:	f426                	sd	s1,40(sp)
    80000866:	f04a                	sd	s2,32(sp)
    80000868:	ec4e                	sd	s3,24(sp)
    8000086a:	e852                	sd	s4,16(sp)
    8000086c:	e456                	sd	s5,8(sp)
    8000086e:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000870:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r];
    80000874:	00011a17          	auipc	s4,0x11
    80000878:	084a0a13          	addi	s4,s4,132 # 800118f8 <uart_tx_lock>
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    8000087c:	00008497          	auipc	s1,0x8
    80000880:	78848493          	addi	s1,s1,1928 # 80009004 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000884:	00008997          	auipc	s3,0x8
    80000888:	78498993          	addi	s3,s3,1924 # 80009008 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000088c:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000890:	0ff77713          	andi	a4,a4,255
    80000894:	02077713          	andi	a4,a4,32
    80000898:	cb15                	beqz	a4,800008cc <uartstart+0x82>
    int c = uart_tx_buf[uart_tx_r];
    8000089a:	00fa0733          	add	a4,s4,a5
    8000089e:	01874a83          	lbu	s5,24(a4)
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    800008a2:	2785                	addiw	a5,a5,1
    800008a4:	41f7d71b          	sraiw	a4,a5,0x1f
    800008a8:	01b7571b          	srliw	a4,a4,0x1b
    800008ac:	9fb9                	addw	a5,a5,a4
    800008ae:	8bfd                	andi	a5,a5,31
    800008b0:	9f99                	subw	a5,a5,a4
    800008b2:	c09c                	sw	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008b4:	8526                	mv	a0,s1
    800008b6:	00002097          	auipc	ra,0x2
    800008ba:	b18080e7          	jalr	-1256(ra) # 800023ce <wakeup>
    
    WriteReg(THR, c);
    800008be:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008c2:	409c                	lw	a5,0(s1)
    800008c4:	0009a703          	lw	a4,0(s3)
    800008c8:	fcf712e3          	bne	a4,a5,8000088c <uartstart+0x42>
  }
}
    800008cc:	70e2                	ld	ra,56(sp)
    800008ce:	7442                	ld	s0,48(sp)
    800008d0:	74a2                	ld	s1,40(sp)
    800008d2:	7902                	ld	s2,32(sp)
    800008d4:	69e2                	ld	s3,24(sp)
    800008d6:	6a42                	ld	s4,16(sp)
    800008d8:	6aa2                	ld	s5,8(sp)
    800008da:	6121                	addi	sp,sp,64
    800008dc:	8082                	ret
    800008de:	8082                	ret

00000000800008e0 <uartputc>:
{
    800008e0:	7179                	addi	sp,sp,-48
    800008e2:	f406                	sd	ra,40(sp)
    800008e4:	f022                	sd	s0,32(sp)
    800008e6:	ec26                	sd	s1,24(sp)
    800008e8:	e84a                	sd	s2,16(sp)
    800008ea:	e44e                	sd	s3,8(sp)
    800008ec:	e052                	sd	s4,0(sp)
    800008ee:	1800                	addi	s0,sp,48
    800008f0:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    800008f2:	00011517          	auipc	a0,0x11
    800008f6:	00650513          	addi	a0,a0,6 # 800118f8 <uart_tx_lock>
    800008fa:	00000097          	auipc	ra,0x0
    800008fe:	368080e7          	jalr	872(ra) # 80000c62 <acquire>
  if(panicked){
    80000902:	00008797          	auipc	a5,0x8
    80000906:	6fe7a783          	lw	a5,1790(a5) # 80009000 <panicked>
    8000090a:	c391                	beqz	a5,8000090e <uartputc+0x2e>
    for(;;)
    8000090c:	a001                	j	8000090c <uartputc+0x2c>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    8000090e:	00008717          	auipc	a4,0x8
    80000912:	6fa72703          	lw	a4,1786(a4) # 80009008 <uart_tx_w>
    80000916:	0017079b          	addiw	a5,a4,1
    8000091a:	41f7d69b          	sraiw	a3,a5,0x1f
    8000091e:	01b6d69b          	srliw	a3,a3,0x1b
    80000922:	9fb5                	addw	a5,a5,a3
    80000924:	8bfd                	andi	a5,a5,31
    80000926:	9f95                	subw	a5,a5,a3
    80000928:	00008697          	auipc	a3,0x8
    8000092c:	6dc6a683          	lw	a3,1756(a3) # 80009004 <uart_tx_r>
    80000930:	04f69263          	bne	a3,a5,80000974 <uartputc+0x94>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000934:	00011a17          	auipc	s4,0x11
    80000938:	fc4a0a13          	addi	s4,s4,-60 # 800118f8 <uart_tx_lock>
    8000093c:	00008497          	auipc	s1,0x8
    80000940:	6c848493          	addi	s1,s1,1736 # 80009004 <uart_tx_r>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000944:	00008917          	auipc	s2,0x8
    80000948:	6c490913          	addi	s2,s2,1732 # 80009008 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000094c:	85d2                	mv	a1,s4
    8000094e:	8526                	mv	a0,s1
    80000950:	00002097          	auipc	ra,0x2
    80000954:	8f8080e7          	jalr	-1800(ra) # 80002248 <sleep>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000958:	00092703          	lw	a4,0(s2)
    8000095c:	0017079b          	addiw	a5,a4,1
    80000960:	41f7d69b          	sraiw	a3,a5,0x1f
    80000964:	01b6d69b          	srliw	a3,a3,0x1b
    80000968:	9fb5                	addw	a5,a5,a3
    8000096a:	8bfd                	andi	a5,a5,31
    8000096c:	9f95                	subw	a5,a5,a3
    8000096e:	4094                	lw	a3,0(s1)
    80000970:	fcf68ee3          	beq	a3,a5,8000094c <uartputc+0x6c>
      uart_tx_buf[uart_tx_w] = c;
    80000974:	00011497          	auipc	s1,0x11
    80000978:	f8448493          	addi	s1,s1,-124 # 800118f8 <uart_tx_lock>
    8000097c:	9726                	add	a4,a4,s1
    8000097e:	01370c23          	sb	s3,24(a4)
      uart_tx_w = (uart_tx_w + 1) % UART_TX_BUF_SIZE;
    80000982:	00008717          	auipc	a4,0x8
    80000986:	68f72323          	sw	a5,1670(a4) # 80009008 <uart_tx_w>
      uartstart();
    8000098a:	00000097          	auipc	ra,0x0
    8000098e:	ec0080e7          	jalr	-320(ra) # 8000084a <uartstart>
      release(&uart_tx_lock);
    80000992:	8526                	mv	a0,s1
    80000994:	00000097          	auipc	ra,0x0
    80000998:	382080e7          	jalr	898(ra) # 80000d16 <release>
}
    8000099c:	70a2                	ld	ra,40(sp)
    8000099e:	7402                	ld	s0,32(sp)
    800009a0:	64e2                	ld	s1,24(sp)
    800009a2:	6942                	ld	s2,16(sp)
    800009a4:	69a2                	ld	s3,8(sp)
    800009a6:	6a02                	ld	s4,0(sp)
    800009a8:	6145                	addi	sp,sp,48
    800009aa:	8082                	ret

00000000800009ac <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009ac:	1141                	addi	sp,sp,-16
    800009ae:	e422                	sd	s0,8(sp)
    800009b0:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009b2:	100007b7          	lui	a5,0x10000
    800009b6:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009ba:	8b85                	andi	a5,a5,1
    800009bc:	cb91                	beqz	a5,800009d0 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009be:	100007b7          	lui	a5,0x10000
    800009c2:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800009c6:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800009ca:	6422                	ld	s0,8(sp)
    800009cc:	0141                	addi	sp,sp,16
    800009ce:	8082                	ret
    return -1;
    800009d0:	557d                	li	a0,-1
    800009d2:	bfe5                	j	800009ca <uartgetc+0x1e>

00000000800009d4 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800009d4:	1101                	addi	sp,sp,-32
    800009d6:	ec06                	sd	ra,24(sp)
    800009d8:	e822                	sd	s0,16(sp)
    800009da:	e426                	sd	s1,8(sp)
    800009dc:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009de:	54fd                	li	s1,-1
    int c = uartgetc();
    800009e0:	00000097          	auipc	ra,0x0
    800009e4:	fcc080e7          	jalr	-52(ra) # 800009ac <uartgetc>
    if(c == -1)
    800009e8:	00950763          	beq	a0,s1,800009f6 <uartintr+0x22>
      break;
    consoleintr(c);
    800009ec:	00000097          	auipc	ra,0x0
    800009f0:	8dc080e7          	jalr	-1828(ra) # 800002c8 <consoleintr>
  while(1){
    800009f4:	b7f5                	j	800009e0 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009f6:	00011497          	auipc	s1,0x11
    800009fa:	f0248493          	addi	s1,s1,-254 # 800118f8 <uart_tx_lock>
    800009fe:	8526                	mv	a0,s1
    80000a00:	00000097          	auipc	ra,0x0
    80000a04:	262080e7          	jalr	610(ra) # 80000c62 <acquire>
  uartstart();
    80000a08:	00000097          	auipc	ra,0x0
    80000a0c:	e42080e7          	jalr	-446(ra) # 8000084a <uartstart>
  release(&uart_tx_lock);
    80000a10:	8526                	mv	a0,s1
    80000a12:	00000097          	auipc	ra,0x0
    80000a16:	304080e7          	jalr	772(ra) # 80000d16 <release>
}
    80000a1a:	60e2                	ld	ra,24(sp)
    80000a1c:	6442                	ld	s0,16(sp)
    80000a1e:	64a2                	ld	s1,8(sp)
    80000a20:	6105                	addi	sp,sp,32
    80000a22:	8082                	ret

0000000080000a24 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a24:	1101                	addi	sp,sp,-32
    80000a26:	ec06                	sd	ra,24(sp)
    80000a28:	e822                	sd	s0,16(sp)
    80000a2a:	e426                	sd	s1,8(sp)
    80000a2c:	e04a                	sd	s2,0(sp)
    80000a2e:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a30:	03451793          	slli	a5,a0,0x34
    80000a34:	ebb9                	bnez	a5,80000a8a <kfree+0x66>
    80000a36:	84aa                	mv	s1,a0
    80000a38:	00025797          	auipc	a5,0x25
    80000a3c:	5c878793          	addi	a5,a5,1480 # 80026000 <end>
    80000a40:	04f56563          	bltu	a0,a5,80000a8a <kfree+0x66>
    80000a44:	47c5                	li	a5,17
    80000a46:	07ee                	slli	a5,a5,0x1b
    80000a48:	04f57163          	bgeu	a0,a5,80000a8a <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a4c:	6605                	lui	a2,0x1
    80000a4e:	4585                	li	a1,1
    80000a50:	00000097          	auipc	ra,0x0
    80000a54:	30e080e7          	jalr	782(ra) # 80000d5e <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a58:	00011917          	auipc	s2,0x11
    80000a5c:	ed890913          	addi	s2,s2,-296 # 80011930 <kmem>
    80000a60:	854a                	mv	a0,s2
    80000a62:	00000097          	auipc	ra,0x0
    80000a66:	200080e7          	jalr	512(ra) # 80000c62 <acquire>
  r->next = kmem.freelist;
    80000a6a:	01893783          	ld	a5,24(s2)
    80000a6e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a70:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a74:	854a                	mv	a0,s2
    80000a76:	00000097          	auipc	ra,0x0
    80000a7a:	2a0080e7          	jalr	672(ra) # 80000d16 <release>
}
    80000a7e:	60e2                	ld	ra,24(sp)
    80000a80:	6442                	ld	s0,16(sp)
    80000a82:	64a2                	ld	s1,8(sp)
    80000a84:	6902                	ld	s2,0(sp)
    80000a86:	6105                	addi	sp,sp,32
    80000a88:	8082                	ret
    panic("kfree");
    80000a8a:	00007517          	auipc	a0,0x7
    80000a8e:	5d650513          	addi	a0,a0,1494 # 80008060 <digits+0x20>
    80000a92:	00000097          	auipc	ra,0x0
    80000a96:	ab6080e7          	jalr	-1354(ra) # 80000548 <panic>

0000000080000a9a <freerange>:
{
    80000a9a:	7179                	addi	sp,sp,-48
    80000a9c:	f406                	sd	ra,40(sp)
    80000a9e:	f022                	sd	s0,32(sp)
    80000aa0:	ec26                	sd	s1,24(sp)
    80000aa2:	e84a                	sd	s2,16(sp)
    80000aa4:	e44e                	sd	s3,8(sp)
    80000aa6:	e052                	sd	s4,0(sp)
    80000aa8:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000aaa:	6785                	lui	a5,0x1
    80000aac:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000ab0:	94aa                	add	s1,s1,a0
    80000ab2:	757d                	lui	a0,0xfffff
    80000ab4:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ab6:	94be                	add	s1,s1,a5
    80000ab8:	0095ee63          	bltu	a1,s1,80000ad4 <freerange+0x3a>
    80000abc:	892e                	mv	s2,a1
    kfree(p);
    80000abe:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ac0:	6985                	lui	s3,0x1
    kfree(p);
    80000ac2:	01448533          	add	a0,s1,s4
    80000ac6:	00000097          	auipc	ra,0x0
    80000aca:	f5e080e7          	jalr	-162(ra) # 80000a24 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ace:	94ce                	add	s1,s1,s3
    80000ad0:	fe9979e3          	bgeu	s2,s1,80000ac2 <freerange+0x28>
}
    80000ad4:	70a2                	ld	ra,40(sp)
    80000ad6:	7402                	ld	s0,32(sp)
    80000ad8:	64e2                	ld	s1,24(sp)
    80000ada:	6942                	ld	s2,16(sp)
    80000adc:	69a2                	ld	s3,8(sp)
    80000ade:	6a02                	ld	s4,0(sp)
    80000ae0:	6145                	addi	sp,sp,48
    80000ae2:	8082                	ret

0000000080000ae4 <kinit>:
{
    80000ae4:	1141                	addi	sp,sp,-16
    80000ae6:	e406                	sd	ra,8(sp)
    80000ae8:	e022                	sd	s0,0(sp)
    80000aea:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aec:	00007597          	auipc	a1,0x7
    80000af0:	57c58593          	addi	a1,a1,1404 # 80008068 <digits+0x28>
    80000af4:	00011517          	auipc	a0,0x11
    80000af8:	e3c50513          	addi	a0,a0,-452 # 80011930 <kmem>
    80000afc:	00000097          	auipc	ra,0x0
    80000b00:	0d6080e7          	jalr	214(ra) # 80000bd2 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b04:	45c5                	li	a1,17
    80000b06:	05ee                	slli	a1,a1,0x1b
    80000b08:	00025517          	auipc	a0,0x25
    80000b0c:	4f850513          	addi	a0,a0,1272 # 80026000 <end>
    80000b10:	00000097          	auipc	ra,0x0
    80000b14:	f8a080e7          	jalr	-118(ra) # 80000a9a <freerange>
}
    80000b18:	60a2                	ld	ra,8(sp)
    80000b1a:	6402                	ld	s0,0(sp)
    80000b1c:	0141                	addi	sp,sp,16
    80000b1e:	8082                	ret

0000000080000b20 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b20:	1101                	addi	sp,sp,-32
    80000b22:	ec06                	sd	ra,24(sp)
    80000b24:	e822                	sd	s0,16(sp)
    80000b26:	e426                	sd	s1,8(sp)
    80000b28:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b2a:	00011497          	auipc	s1,0x11
    80000b2e:	e0648493          	addi	s1,s1,-506 # 80011930 <kmem>
    80000b32:	8526                	mv	a0,s1
    80000b34:	00000097          	auipc	ra,0x0
    80000b38:	12e080e7          	jalr	302(ra) # 80000c62 <acquire>
  r = kmem.freelist;
    80000b3c:	6c84                	ld	s1,24(s1)
  if(r)
    80000b3e:	c885                	beqz	s1,80000b6e <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b40:	609c                	ld	a5,0(s1)
    80000b42:	00011517          	auipc	a0,0x11
    80000b46:	dee50513          	addi	a0,a0,-530 # 80011930 <kmem>
    80000b4a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b4c:	00000097          	auipc	ra,0x0
    80000b50:	1ca080e7          	jalr	458(ra) # 80000d16 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b54:	6605                	lui	a2,0x1
    80000b56:	4595                	li	a1,5
    80000b58:	8526                	mv	a0,s1
    80000b5a:	00000097          	auipc	ra,0x0
    80000b5e:	204080e7          	jalr	516(ra) # 80000d5e <memset>
  return (void*)r;
}
    80000b62:	8526                	mv	a0,s1
    80000b64:	60e2                	ld	ra,24(sp)
    80000b66:	6442                	ld	s0,16(sp)
    80000b68:	64a2                	ld	s1,8(sp)
    80000b6a:	6105                	addi	sp,sp,32
    80000b6c:	8082                	ret
  release(&kmem.lock);
    80000b6e:	00011517          	auipc	a0,0x11
    80000b72:	dc250513          	addi	a0,a0,-574 # 80011930 <kmem>
    80000b76:	00000097          	auipc	ra,0x0
    80000b7a:	1a0080e7          	jalr	416(ra) # 80000d16 <release>
  if(r)
    80000b7e:	b7d5                	j	80000b62 <kalloc+0x42>

0000000080000b80 <kama_freebytes>:

// 获取空闲内存
void kama_freebytes(uint64* dst) {
    80000b80:	1101                	addi	sp,sp,-32
    80000b82:	ec06                	sd	ra,24(sp)
    80000b84:	e822                	sd	s0,16(sp)
    80000b86:	e426                	sd	s1,8(sp)
    80000b88:	e04a                	sd	s2,0(sp)
    80000b8a:	1000                	addi	s0,sp,32
    80000b8c:	892a                	mv	s2,a0
    *dst = 0;
    80000b8e:	00053023          	sd	zero,0(a0)
    struct run* p = kmem.freelist;
    80000b92:	00011517          	auipc	a0,0x11
    80000b96:	d9e50513          	addi	a0,a0,-610 # 80011930 <kmem>
    80000b9a:	6d04                	ld	s1,24(a0)

    acquire(&kmem.lock);		// 加锁保证线程安全
    80000b9c:	00000097          	auipc	ra,0x0
    80000ba0:	0c6080e7          	jalr	198(ra) # 80000c62 <acquire>
    while (p) {
    80000ba4:	c889                	beqz	s1,80000bb6 <kama_freebytes+0x36>
        *dst += PGSIZE;			// 统计空闲字节数
    80000ba6:	6705                	lui	a4,0x1
    80000ba8:	00093783          	ld	a5,0(s2)
    80000bac:	97ba                	add	a5,a5,a4
    80000bae:	00f93023          	sd	a5,0(s2)
        p = p->next;
    80000bb2:	6084                	ld	s1,0(s1)
    while (p) {
    80000bb4:	f8f5                	bnez	s1,80000ba8 <kama_freebytes+0x28>
    }
    release(&kmem.lock);
    80000bb6:	00011517          	auipc	a0,0x11
    80000bba:	d7a50513          	addi	a0,a0,-646 # 80011930 <kmem>
    80000bbe:	00000097          	auipc	ra,0x0
    80000bc2:	158080e7          	jalr	344(ra) # 80000d16 <release>
    80000bc6:	60e2                	ld	ra,24(sp)
    80000bc8:	6442                	ld	s0,16(sp)
    80000bca:	64a2                	ld	s1,8(sp)
    80000bcc:	6902                	ld	s2,0(sp)
    80000bce:	6105                	addi	sp,sp,32
    80000bd0:	8082                	ret

0000000080000bd2 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000bd2:	1141                	addi	sp,sp,-16
    80000bd4:	e422                	sd	s0,8(sp)
    80000bd6:	0800                	addi	s0,sp,16
  lk->name = name;
    80000bd8:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bda:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bde:	00053823          	sd	zero,16(a0)
}
    80000be2:	6422                	ld	s0,8(sp)
    80000be4:	0141                	addi	sp,sp,16
    80000be6:	8082                	ret

0000000080000be8 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000be8:	411c                	lw	a5,0(a0)
    80000bea:	e399                	bnez	a5,80000bf0 <holding+0x8>
    80000bec:	4501                	li	a0,0
  return r;
}
    80000bee:	8082                	ret
{
    80000bf0:	1101                	addi	sp,sp,-32
    80000bf2:	ec06                	sd	ra,24(sp)
    80000bf4:	e822                	sd	s0,16(sp)
    80000bf6:	e426                	sd	s1,8(sp)
    80000bf8:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bfa:	6904                	ld	s1,16(a0)
    80000bfc:	00001097          	auipc	ra,0x1
    80000c00:	e18080e7          	jalr	-488(ra) # 80001a14 <mycpu>
    80000c04:	40a48533          	sub	a0,s1,a0
    80000c08:	00153513          	seqz	a0,a0
}
    80000c0c:	60e2                	ld	ra,24(sp)
    80000c0e:	6442                	ld	s0,16(sp)
    80000c10:	64a2                	ld	s1,8(sp)
    80000c12:	6105                	addi	sp,sp,32
    80000c14:	8082                	ret

0000000080000c16 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c16:	1101                	addi	sp,sp,-32
    80000c18:	ec06                	sd	ra,24(sp)
    80000c1a:	e822                	sd	s0,16(sp)
    80000c1c:	e426                	sd	s1,8(sp)
    80000c1e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c20:	100024f3          	csrr	s1,sstatus
    80000c24:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c28:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c2a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c2e:	00001097          	auipc	ra,0x1
    80000c32:	de6080e7          	jalr	-538(ra) # 80001a14 <mycpu>
    80000c36:	5d3c                	lw	a5,120(a0)
    80000c38:	cf89                	beqz	a5,80000c52 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c3a:	00001097          	auipc	ra,0x1
    80000c3e:	dda080e7          	jalr	-550(ra) # 80001a14 <mycpu>
    80000c42:	5d3c                	lw	a5,120(a0)
    80000c44:	2785                	addiw	a5,a5,1
    80000c46:	dd3c                	sw	a5,120(a0)
}
    80000c48:	60e2                	ld	ra,24(sp)
    80000c4a:	6442                	ld	s0,16(sp)
    80000c4c:	64a2                	ld	s1,8(sp)
    80000c4e:	6105                	addi	sp,sp,32
    80000c50:	8082                	ret
    mycpu()->intena = old;
    80000c52:	00001097          	auipc	ra,0x1
    80000c56:	dc2080e7          	jalr	-574(ra) # 80001a14 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c5a:	8085                	srli	s1,s1,0x1
    80000c5c:	8885                	andi	s1,s1,1
    80000c5e:	dd64                	sw	s1,124(a0)
    80000c60:	bfe9                	j	80000c3a <push_off+0x24>

0000000080000c62 <acquire>:
{
    80000c62:	1101                	addi	sp,sp,-32
    80000c64:	ec06                	sd	ra,24(sp)
    80000c66:	e822                	sd	s0,16(sp)
    80000c68:	e426                	sd	s1,8(sp)
    80000c6a:	1000                	addi	s0,sp,32
    80000c6c:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c6e:	00000097          	auipc	ra,0x0
    80000c72:	fa8080e7          	jalr	-88(ra) # 80000c16 <push_off>
  if(holding(lk))
    80000c76:	8526                	mv	a0,s1
    80000c78:	00000097          	auipc	ra,0x0
    80000c7c:	f70080e7          	jalr	-144(ra) # 80000be8 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c80:	4705                	li	a4,1
  if(holding(lk))
    80000c82:	e115                	bnez	a0,80000ca6 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c84:	87ba                	mv	a5,a4
    80000c86:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c8a:	2781                	sext.w	a5,a5
    80000c8c:	ffe5                	bnez	a5,80000c84 <acquire+0x22>
  __sync_synchronize();
    80000c8e:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c92:	00001097          	auipc	ra,0x1
    80000c96:	d82080e7          	jalr	-638(ra) # 80001a14 <mycpu>
    80000c9a:	e888                	sd	a0,16(s1)
}
    80000c9c:	60e2                	ld	ra,24(sp)
    80000c9e:	6442                	ld	s0,16(sp)
    80000ca0:	64a2                	ld	s1,8(sp)
    80000ca2:	6105                	addi	sp,sp,32
    80000ca4:	8082                	ret
    panic("acquire");
    80000ca6:	00007517          	auipc	a0,0x7
    80000caa:	3ca50513          	addi	a0,a0,970 # 80008070 <digits+0x30>
    80000cae:	00000097          	auipc	ra,0x0
    80000cb2:	89a080e7          	jalr	-1894(ra) # 80000548 <panic>

0000000080000cb6 <pop_off>:

void
pop_off(void)
{
    80000cb6:	1141                	addi	sp,sp,-16
    80000cb8:	e406                	sd	ra,8(sp)
    80000cba:	e022                	sd	s0,0(sp)
    80000cbc:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000cbe:	00001097          	auipc	ra,0x1
    80000cc2:	d56080e7          	jalr	-682(ra) # 80001a14 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cc6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000cca:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000ccc:	e78d                	bnez	a5,80000cf6 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000cce:	5d3c                	lw	a5,120(a0)
    80000cd0:	02f05b63          	blez	a5,80000d06 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000cd4:	37fd                	addiw	a5,a5,-1
    80000cd6:	0007871b          	sext.w	a4,a5
    80000cda:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000cdc:	eb09                	bnez	a4,80000cee <pop_off+0x38>
    80000cde:	5d7c                	lw	a5,124(a0)
    80000ce0:	c799                	beqz	a5,80000cee <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000ce2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000ce6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cea:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000cee:	60a2                	ld	ra,8(sp)
    80000cf0:	6402                	ld	s0,0(sp)
    80000cf2:	0141                	addi	sp,sp,16
    80000cf4:	8082                	ret
    panic("pop_off - interruptible");
    80000cf6:	00007517          	auipc	a0,0x7
    80000cfa:	38250513          	addi	a0,a0,898 # 80008078 <digits+0x38>
    80000cfe:	00000097          	auipc	ra,0x0
    80000d02:	84a080e7          	jalr	-1974(ra) # 80000548 <panic>
    panic("pop_off");
    80000d06:	00007517          	auipc	a0,0x7
    80000d0a:	38a50513          	addi	a0,a0,906 # 80008090 <digits+0x50>
    80000d0e:	00000097          	auipc	ra,0x0
    80000d12:	83a080e7          	jalr	-1990(ra) # 80000548 <panic>

0000000080000d16 <release>:
{
    80000d16:	1101                	addi	sp,sp,-32
    80000d18:	ec06                	sd	ra,24(sp)
    80000d1a:	e822                	sd	s0,16(sp)
    80000d1c:	e426                	sd	s1,8(sp)
    80000d1e:	1000                	addi	s0,sp,32
    80000d20:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d22:	00000097          	auipc	ra,0x0
    80000d26:	ec6080e7          	jalr	-314(ra) # 80000be8 <holding>
    80000d2a:	c115                	beqz	a0,80000d4e <release+0x38>
  lk->cpu = 0;
    80000d2c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d30:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d34:	0f50000f          	fence	iorw,ow
    80000d38:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d3c:	00000097          	auipc	ra,0x0
    80000d40:	f7a080e7          	jalr	-134(ra) # 80000cb6 <pop_off>
}
    80000d44:	60e2                	ld	ra,24(sp)
    80000d46:	6442                	ld	s0,16(sp)
    80000d48:	64a2                	ld	s1,8(sp)
    80000d4a:	6105                	addi	sp,sp,32
    80000d4c:	8082                	ret
    panic("release");
    80000d4e:	00007517          	auipc	a0,0x7
    80000d52:	34a50513          	addi	a0,a0,842 # 80008098 <digits+0x58>
    80000d56:	fffff097          	auipc	ra,0xfffff
    80000d5a:	7f2080e7          	jalr	2034(ra) # 80000548 <panic>

0000000080000d5e <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d5e:	1141                	addi	sp,sp,-16
    80000d60:	e422                	sd	s0,8(sp)
    80000d62:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d64:	ce09                	beqz	a2,80000d7e <memset+0x20>
    80000d66:	87aa                	mv	a5,a0
    80000d68:	fff6071b          	addiw	a4,a2,-1
    80000d6c:	1702                	slli	a4,a4,0x20
    80000d6e:	9301                	srli	a4,a4,0x20
    80000d70:	0705                	addi	a4,a4,1
    80000d72:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000d74:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d78:	0785                	addi	a5,a5,1
    80000d7a:	fee79de3          	bne	a5,a4,80000d74 <memset+0x16>
  }
  return dst;
}
    80000d7e:	6422                	ld	s0,8(sp)
    80000d80:	0141                	addi	sp,sp,16
    80000d82:	8082                	ret

0000000080000d84 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d84:	1141                	addi	sp,sp,-16
    80000d86:	e422                	sd	s0,8(sp)
    80000d88:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d8a:	ca05                	beqz	a2,80000dba <memcmp+0x36>
    80000d8c:	fff6069b          	addiw	a3,a2,-1
    80000d90:	1682                	slli	a3,a3,0x20
    80000d92:	9281                	srli	a3,a3,0x20
    80000d94:	0685                	addi	a3,a3,1
    80000d96:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d98:	00054783          	lbu	a5,0(a0)
    80000d9c:	0005c703          	lbu	a4,0(a1)
    80000da0:	00e79863          	bne	a5,a4,80000db0 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000da4:	0505                	addi	a0,a0,1
    80000da6:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000da8:	fed518e3          	bne	a0,a3,80000d98 <memcmp+0x14>
  }

  return 0;
    80000dac:	4501                	li	a0,0
    80000dae:	a019                	j	80000db4 <memcmp+0x30>
      return *s1 - *s2;
    80000db0:	40e7853b          	subw	a0,a5,a4
}
    80000db4:	6422                	ld	s0,8(sp)
    80000db6:	0141                	addi	sp,sp,16
    80000db8:	8082                	ret
  return 0;
    80000dba:	4501                	li	a0,0
    80000dbc:	bfe5                	j	80000db4 <memcmp+0x30>

0000000080000dbe <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000dbe:	1141                	addi	sp,sp,-16
    80000dc0:	e422                	sd	s0,8(sp)
    80000dc2:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000dc4:	00a5f963          	bgeu	a1,a0,80000dd6 <memmove+0x18>
    80000dc8:	02061713          	slli	a4,a2,0x20
    80000dcc:	9301                	srli	a4,a4,0x20
    80000dce:	00e587b3          	add	a5,a1,a4
    80000dd2:	02f56563          	bltu	a0,a5,80000dfc <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000dd6:	fff6069b          	addiw	a3,a2,-1
    80000dda:	ce11                	beqz	a2,80000df6 <memmove+0x38>
    80000ddc:	1682                	slli	a3,a3,0x20
    80000dde:	9281                	srli	a3,a3,0x20
    80000de0:	0685                	addi	a3,a3,1
    80000de2:	96ae                	add	a3,a3,a1
    80000de4:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000de6:	0585                	addi	a1,a1,1
    80000de8:	0785                	addi	a5,a5,1
    80000dea:	fff5c703          	lbu	a4,-1(a1)
    80000dee:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000df2:	fed59ae3          	bne	a1,a3,80000de6 <memmove+0x28>

  return dst;
}
    80000df6:	6422                	ld	s0,8(sp)
    80000df8:	0141                	addi	sp,sp,16
    80000dfa:	8082                	ret
    d += n;
    80000dfc:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000dfe:	fff6069b          	addiw	a3,a2,-1
    80000e02:	da75                	beqz	a2,80000df6 <memmove+0x38>
    80000e04:	02069613          	slli	a2,a3,0x20
    80000e08:	9201                	srli	a2,a2,0x20
    80000e0a:	fff64613          	not	a2,a2
    80000e0e:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000e10:	17fd                	addi	a5,a5,-1
    80000e12:	177d                	addi	a4,a4,-1
    80000e14:	0007c683          	lbu	a3,0(a5)
    80000e18:	00d70023          	sb	a3,0(a4) # 1000 <_entry-0x7ffff000>
    while(n-- > 0)
    80000e1c:	fec79ae3          	bne	a5,a2,80000e10 <memmove+0x52>
    80000e20:	bfd9                	j	80000df6 <memmove+0x38>

0000000080000e22 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e22:	1141                	addi	sp,sp,-16
    80000e24:	e406                	sd	ra,8(sp)
    80000e26:	e022                	sd	s0,0(sp)
    80000e28:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e2a:	00000097          	auipc	ra,0x0
    80000e2e:	f94080e7          	jalr	-108(ra) # 80000dbe <memmove>
}
    80000e32:	60a2                	ld	ra,8(sp)
    80000e34:	6402                	ld	s0,0(sp)
    80000e36:	0141                	addi	sp,sp,16
    80000e38:	8082                	ret

0000000080000e3a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e3a:	1141                	addi	sp,sp,-16
    80000e3c:	e422                	sd	s0,8(sp)
    80000e3e:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e40:	ce11                	beqz	a2,80000e5c <strncmp+0x22>
    80000e42:	00054783          	lbu	a5,0(a0)
    80000e46:	cf89                	beqz	a5,80000e60 <strncmp+0x26>
    80000e48:	0005c703          	lbu	a4,0(a1)
    80000e4c:	00f71a63          	bne	a4,a5,80000e60 <strncmp+0x26>
    n--, p++, q++;
    80000e50:	367d                	addiw	a2,a2,-1
    80000e52:	0505                	addi	a0,a0,1
    80000e54:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e56:	f675                	bnez	a2,80000e42 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e58:	4501                	li	a0,0
    80000e5a:	a809                	j	80000e6c <strncmp+0x32>
    80000e5c:	4501                	li	a0,0
    80000e5e:	a039                	j	80000e6c <strncmp+0x32>
  if(n == 0)
    80000e60:	ca09                	beqz	a2,80000e72 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e62:	00054503          	lbu	a0,0(a0)
    80000e66:	0005c783          	lbu	a5,0(a1)
    80000e6a:	9d1d                	subw	a0,a0,a5
}
    80000e6c:	6422                	ld	s0,8(sp)
    80000e6e:	0141                	addi	sp,sp,16
    80000e70:	8082                	ret
    return 0;
    80000e72:	4501                	li	a0,0
    80000e74:	bfe5                	j	80000e6c <strncmp+0x32>

0000000080000e76 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e76:	1141                	addi	sp,sp,-16
    80000e78:	e422                	sd	s0,8(sp)
    80000e7a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e7c:	872a                	mv	a4,a0
    80000e7e:	8832                	mv	a6,a2
    80000e80:	367d                	addiw	a2,a2,-1
    80000e82:	01005963          	blez	a6,80000e94 <strncpy+0x1e>
    80000e86:	0705                	addi	a4,a4,1
    80000e88:	0005c783          	lbu	a5,0(a1)
    80000e8c:	fef70fa3          	sb	a5,-1(a4)
    80000e90:	0585                	addi	a1,a1,1
    80000e92:	f7f5                	bnez	a5,80000e7e <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e94:	00c05d63          	blez	a2,80000eae <strncpy+0x38>
    80000e98:	86ba                	mv	a3,a4
    *s++ = 0;
    80000e9a:	0685                	addi	a3,a3,1
    80000e9c:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000ea0:	fff6c793          	not	a5,a3
    80000ea4:	9fb9                	addw	a5,a5,a4
    80000ea6:	010787bb          	addw	a5,a5,a6
    80000eaa:	fef048e3          	bgtz	a5,80000e9a <strncpy+0x24>
  return os;
}
    80000eae:	6422                	ld	s0,8(sp)
    80000eb0:	0141                	addi	sp,sp,16
    80000eb2:	8082                	ret

0000000080000eb4 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000eb4:	1141                	addi	sp,sp,-16
    80000eb6:	e422                	sd	s0,8(sp)
    80000eb8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000eba:	02c05363          	blez	a2,80000ee0 <safestrcpy+0x2c>
    80000ebe:	fff6069b          	addiw	a3,a2,-1
    80000ec2:	1682                	slli	a3,a3,0x20
    80000ec4:	9281                	srli	a3,a3,0x20
    80000ec6:	96ae                	add	a3,a3,a1
    80000ec8:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000eca:	00d58963          	beq	a1,a3,80000edc <safestrcpy+0x28>
    80000ece:	0585                	addi	a1,a1,1
    80000ed0:	0785                	addi	a5,a5,1
    80000ed2:	fff5c703          	lbu	a4,-1(a1)
    80000ed6:	fee78fa3          	sb	a4,-1(a5)
    80000eda:	fb65                	bnez	a4,80000eca <safestrcpy+0x16>
    ;
  *s = 0;
    80000edc:	00078023          	sb	zero,0(a5)
  return os;
}
    80000ee0:	6422                	ld	s0,8(sp)
    80000ee2:	0141                	addi	sp,sp,16
    80000ee4:	8082                	ret

0000000080000ee6 <strlen>:

int
strlen(const char *s)
{
    80000ee6:	1141                	addi	sp,sp,-16
    80000ee8:	e422                	sd	s0,8(sp)
    80000eea:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000eec:	00054783          	lbu	a5,0(a0)
    80000ef0:	cf91                	beqz	a5,80000f0c <strlen+0x26>
    80000ef2:	0505                	addi	a0,a0,1
    80000ef4:	87aa                	mv	a5,a0
    80000ef6:	4685                	li	a3,1
    80000ef8:	9e89                	subw	a3,a3,a0
    80000efa:	00f6853b          	addw	a0,a3,a5
    80000efe:	0785                	addi	a5,a5,1
    80000f00:	fff7c703          	lbu	a4,-1(a5)
    80000f04:	fb7d                	bnez	a4,80000efa <strlen+0x14>
    ;
  return n;
}
    80000f06:	6422                	ld	s0,8(sp)
    80000f08:	0141                	addi	sp,sp,16
    80000f0a:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f0c:	4501                	li	a0,0
    80000f0e:	bfe5                	j	80000f06 <strlen+0x20>

0000000080000f10 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f10:	1141                	addi	sp,sp,-16
    80000f12:	e406                	sd	ra,8(sp)
    80000f14:	e022                	sd	s0,0(sp)
    80000f16:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f18:	00001097          	auipc	ra,0x1
    80000f1c:	aec080e7          	jalr	-1300(ra) # 80001a04 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f20:	00008717          	auipc	a4,0x8
    80000f24:	0ec70713          	addi	a4,a4,236 # 8000900c <started>
  if(cpuid() == 0){
    80000f28:	c139                	beqz	a0,80000f6e <main+0x5e>
    while(started == 0)
    80000f2a:	431c                	lw	a5,0(a4)
    80000f2c:	2781                	sext.w	a5,a5
    80000f2e:	dff5                	beqz	a5,80000f2a <main+0x1a>
      ;
    __sync_synchronize();
    80000f30:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000f34:	00001097          	auipc	ra,0x1
    80000f38:	ad0080e7          	jalr	-1328(ra) # 80001a04 <cpuid>
    80000f3c:	85aa                	mv	a1,a0
    80000f3e:	00007517          	auipc	a0,0x7
    80000f42:	17a50513          	addi	a0,a0,378 # 800080b8 <digits+0x78>
    80000f46:	fffff097          	auipc	ra,0xfffff
    80000f4a:	64c080e7          	jalr	1612(ra) # 80000592 <printf>
    kvminithart();    // turn on paging
    80000f4e:	00000097          	auipc	ra,0x0
    80000f52:	0d8080e7          	jalr	216(ra) # 80001026 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f56:	00001097          	auipc	ra,0x1
    80000f5a:	776080e7          	jalr	1910(ra) # 800026cc <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f5e:	00005097          	auipc	ra,0x5
    80000f62:	dd2080e7          	jalr	-558(ra) # 80005d30 <plicinithart>
  }

  scheduler();        
    80000f66:	00001097          	auipc	ra,0x1
    80000f6a:	006080e7          	jalr	6(ra) # 80001f6c <scheduler>
    consoleinit();
    80000f6e:	fffff097          	auipc	ra,0xfffff
    80000f72:	4ec080e7          	jalr	1260(ra) # 8000045a <consoleinit>
    printfinit();
    80000f76:	00000097          	auipc	ra,0x0
    80000f7a:	802080e7          	jalr	-2046(ra) # 80000778 <printfinit>
    printf("\n");
    80000f7e:	00007517          	auipc	a0,0x7
    80000f82:	14a50513          	addi	a0,a0,330 # 800080c8 <digits+0x88>
    80000f86:	fffff097          	auipc	ra,0xfffff
    80000f8a:	60c080e7          	jalr	1548(ra) # 80000592 <printf>
    printf("xv6 kernel is booting\n");
    80000f8e:	00007517          	auipc	a0,0x7
    80000f92:	11250513          	addi	a0,a0,274 # 800080a0 <digits+0x60>
    80000f96:	fffff097          	auipc	ra,0xfffff
    80000f9a:	5fc080e7          	jalr	1532(ra) # 80000592 <printf>
    printf("\n");
    80000f9e:	00007517          	auipc	a0,0x7
    80000fa2:	12a50513          	addi	a0,a0,298 # 800080c8 <digits+0x88>
    80000fa6:	fffff097          	auipc	ra,0xfffff
    80000faa:	5ec080e7          	jalr	1516(ra) # 80000592 <printf>
    kinit();         // physical page allocator
    80000fae:	00000097          	auipc	ra,0x0
    80000fb2:	b36080e7          	jalr	-1226(ra) # 80000ae4 <kinit>
    kvminit();       // create kernel page table
    80000fb6:	00000097          	auipc	ra,0x0
    80000fba:	2a0080e7          	jalr	672(ra) # 80001256 <kvminit>
    kvminithart();   // turn on paging
    80000fbe:	00000097          	auipc	ra,0x0
    80000fc2:	068080e7          	jalr	104(ra) # 80001026 <kvminithart>
    procinit();      // process table
    80000fc6:	00001097          	auipc	ra,0x1
    80000fca:	96e080e7          	jalr	-1682(ra) # 80001934 <procinit>
    trapinit();      // trap vectors
    80000fce:	00001097          	auipc	ra,0x1
    80000fd2:	6d6080e7          	jalr	1750(ra) # 800026a4 <trapinit>
    trapinithart();  // install kernel trap vector
    80000fd6:	00001097          	auipc	ra,0x1
    80000fda:	6f6080e7          	jalr	1782(ra) # 800026cc <trapinithart>
    plicinit();      // set up interrupt controller
    80000fde:	00005097          	auipc	ra,0x5
    80000fe2:	d3c080e7          	jalr	-708(ra) # 80005d1a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fe6:	00005097          	auipc	ra,0x5
    80000fea:	d4a080e7          	jalr	-694(ra) # 80005d30 <plicinithart>
    binit();         // buffer cache
    80000fee:	00002097          	auipc	ra,0x2
    80000ff2:	ee8080e7          	jalr	-280(ra) # 80002ed6 <binit>
    iinit();         // inode cache
    80000ff6:	00002097          	auipc	ra,0x2
    80000ffa:	578080e7          	jalr	1400(ra) # 8000356e <iinit>
    fileinit();      // file table
    80000ffe:	00003097          	auipc	ra,0x3
    80001002:	512080e7          	jalr	1298(ra) # 80004510 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001006:	00005097          	auipc	ra,0x5
    8000100a:	e32080e7          	jalr	-462(ra) # 80005e38 <virtio_disk_init>
    userinit();      // first user process
    8000100e:	00001097          	auipc	ra,0x1
    80001012:	cf0080e7          	jalr	-784(ra) # 80001cfe <userinit>
    __sync_synchronize();
    80001016:	0ff0000f          	fence
    started = 1;
    8000101a:	4785                	li	a5,1
    8000101c:	00008717          	auipc	a4,0x8
    80001020:	fef72823          	sw	a5,-16(a4) # 8000900c <started>
    80001024:	b789                	j	80000f66 <main+0x56>

0000000080001026 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80001026:	1141                	addi	sp,sp,-16
    80001028:	e422                	sd	s0,8(sp)
    8000102a:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    8000102c:	00008797          	auipc	a5,0x8
    80001030:	fe47b783          	ld	a5,-28(a5) # 80009010 <kernel_pagetable>
    80001034:	83b1                	srli	a5,a5,0xc
    80001036:	577d                	li	a4,-1
    80001038:	177e                	slli	a4,a4,0x3f
    8000103a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000103c:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001040:	12000073          	sfence.vma
  sfence_vma();
}
    80001044:	6422                	ld	s0,8(sp)
    80001046:	0141                	addi	sp,sp,16
    80001048:	8082                	ret

000000008000104a <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000104a:	7139                	addi	sp,sp,-64
    8000104c:	fc06                	sd	ra,56(sp)
    8000104e:	f822                	sd	s0,48(sp)
    80001050:	f426                	sd	s1,40(sp)
    80001052:	f04a                	sd	s2,32(sp)
    80001054:	ec4e                	sd	s3,24(sp)
    80001056:	e852                	sd	s4,16(sp)
    80001058:	e456                	sd	s5,8(sp)
    8000105a:	e05a                	sd	s6,0(sp)
    8000105c:	0080                	addi	s0,sp,64
    8000105e:	84aa                	mv	s1,a0
    80001060:	89ae                	mv	s3,a1
    80001062:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001064:	57fd                	li	a5,-1
    80001066:	83e9                	srli	a5,a5,0x1a
    80001068:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000106a:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000106c:	04b7f263          	bgeu	a5,a1,800010b0 <walk+0x66>
    panic("walk");
    80001070:	00007517          	auipc	a0,0x7
    80001074:	06050513          	addi	a0,a0,96 # 800080d0 <digits+0x90>
    80001078:	fffff097          	auipc	ra,0xfffff
    8000107c:	4d0080e7          	jalr	1232(ra) # 80000548 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001080:	060a8663          	beqz	s5,800010ec <walk+0xa2>
    80001084:	00000097          	auipc	ra,0x0
    80001088:	a9c080e7          	jalr	-1380(ra) # 80000b20 <kalloc>
    8000108c:	84aa                	mv	s1,a0
    8000108e:	c529                	beqz	a0,800010d8 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001090:	6605                	lui	a2,0x1
    80001092:	4581                	li	a1,0
    80001094:	00000097          	auipc	ra,0x0
    80001098:	cca080e7          	jalr	-822(ra) # 80000d5e <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000109c:	00c4d793          	srli	a5,s1,0xc
    800010a0:	07aa                	slli	a5,a5,0xa
    800010a2:	0017e793          	ori	a5,a5,1
    800010a6:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800010aa:	3a5d                	addiw	s4,s4,-9
    800010ac:	036a0063          	beq	s4,s6,800010cc <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800010b0:	0149d933          	srl	s2,s3,s4
    800010b4:	1ff97913          	andi	s2,s2,511
    800010b8:	090e                	slli	s2,s2,0x3
    800010ba:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800010bc:	00093483          	ld	s1,0(s2)
    800010c0:	0014f793          	andi	a5,s1,1
    800010c4:	dfd5                	beqz	a5,80001080 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800010c6:	80a9                	srli	s1,s1,0xa
    800010c8:	04b2                	slli	s1,s1,0xc
    800010ca:	b7c5                	j	800010aa <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800010cc:	00c9d513          	srli	a0,s3,0xc
    800010d0:	1ff57513          	andi	a0,a0,511
    800010d4:	050e                	slli	a0,a0,0x3
    800010d6:	9526                	add	a0,a0,s1
}
    800010d8:	70e2                	ld	ra,56(sp)
    800010da:	7442                	ld	s0,48(sp)
    800010dc:	74a2                	ld	s1,40(sp)
    800010de:	7902                	ld	s2,32(sp)
    800010e0:	69e2                	ld	s3,24(sp)
    800010e2:	6a42                	ld	s4,16(sp)
    800010e4:	6aa2                	ld	s5,8(sp)
    800010e6:	6b02                	ld	s6,0(sp)
    800010e8:	6121                	addi	sp,sp,64
    800010ea:	8082                	ret
        return 0;
    800010ec:	4501                	li	a0,0
    800010ee:	b7ed                	j	800010d8 <walk+0x8e>

00000000800010f0 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010f0:	57fd                	li	a5,-1
    800010f2:	83e9                	srli	a5,a5,0x1a
    800010f4:	00b7f463          	bgeu	a5,a1,800010fc <walkaddr+0xc>
    return 0;
    800010f8:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010fa:	8082                	ret
{
    800010fc:	1141                	addi	sp,sp,-16
    800010fe:	e406                	sd	ra,8(sp)
    80001100:	e022                	sd	s0,0(sp)
    80001102:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001104:	4601                	li	a2,0
    80001106:	00000097          	auipc	ra,0x0
    8000110a:	f44080e7          	jalr	-188(ra) # 8000104a <walk>
  if(pte == 0)
    8000110e:	c105                	beqz	a0,8000112e <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001110:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001112:	0117f693          	andi	a3,a5,17
    80001116:	4745                	li	a4,17
    return 0;
    80001118:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000111a:	00e68663          	beq	a3,a4,80001126 <walkaddr+0x36>
}
    8000111e:	60a2                	ld	ra,8(sp)
    80001120:	6402                	ld	s0,0(sp)
    80001122:	0141                	addi	sp,sp,16
    80001124:	8082                	ret
  pa = PTE2PA(*pte);
    80001126:	00a7d513          	srli	a0,a5,0xa
    8000112a:	0532                	slli	a0,a0,0xc
  return pa;
    8000112c:	bfcd                	j	8000111e <walkaddr+0x2e>
    return 0;
    8000112e:	4501                	li	a0,0
    80001130:	b7fd                	j	8000111e <walkaddr+0x2e>

0000000080001132 <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    80001132:	1101                	addi	sp,sp,-32
    80001134:	ec06                	sd	ra,24(sp)
    80001136:	e822                	sd	s0,16(sp)
    80001138:	e426                	sd	s1,8(sp)
    8000113a:	1000                	addi	s0,sp,32
    8000113c:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    8000113e:	1552                	slli	a0,a0,0x34
    80001140:	03455493          	srli	s1,a0,0x34
  pte_t *pte;
  uint64 pa;
  
  pte = walk(kernel_pagetable, va, 0);
    80001144:	4601                	li	a2,0
    80001146:	00008517          	auipc	a0,0x8
    8000114a:	eca53503          	ld	a0,-310(a0) # 80009010 <kernel_pagetable>
    8000114e:	00000097          	auipc	ra,0x0
    80001152:	efc080e7          	jalr	-260(ra) # 8000104a <walk>
  if(pte == 0)
    80001156:	cd09                	beqz	a0,80001170 <kvmpa+0x3e>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    80001158:	6108                	ld	a0,0(a0)
    8000115a:	00157793          	andi	a5,a0,1
    8000115e:	c38d                	beqz	a5,80001180 <kvmpa+0x4e>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    80001160:	8129                	srli	a0,a0,0xa
    80001162:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    80001164:	9526                	add	a0,a0,s1
    80001166:	60e2                	ld	ra,24(sp)
    80001168:	6442                	ld	s0,16(sp)
    8000116a:	64a2                	ld	s1,8(sp)
    8000116c:	6105                	addi	sp,sp,32
    8000116e:	8082                	ret
    panic("kvmpa");
    80001170:	00007517          	auipc	a0,0x7
    80001174:	f6850513          	addi	a0,a0,-152 # 800080d8 <digits+0x98>
    80001178:	fffff097          	auipc	ra,0xfffff
    8000117c:	3d0080e7          	jalr	976(ra) # 80000548 <panic>
    panic("kvmpa");
    80001180:	00007517          	auipc	a0,0x7
    80001184:	f5850513          	addi	a0,a0,-168 # 800080d8 <digits+0x98>
    80001188:	fffff097          	auipc	ra,0xfffff
    8000118c:	3c0080e7          	jalr	960(ra) # 80000548 <panic>

0000000080001190 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001190:	715d                	addi	sp,sp,-80
    80001192:	e486                	sd	ra,72(sp)
    80001194:	e0a2                	sd	s0,64(sp)
    80001196:	fc26                	sd	s1,56(sp)
    80001198:	f84a                	sd	s2,48(sp)
    8000119a:	f44e                	sd	s3,40(sp)
    8000119c:	f052                	sd	s4,32(sp)
    8000119e:	ec56                	sd	s5,24(sp)
    800011a0:	e85a                	sd	s6,16(sp)
    800011a2:	e45e                	sd	s7,8(sp)
    800011a4:	0880                	addi	s0,sp,80
    800011a6:	8aaa                	mv	s5,a0
    800011a8:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800011aa:	777d                	lui	a4,0xfffff
    800011ac:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800011b0:	167d                	addi	a2,a2,-1
    800011b2:	00b609b3          	add	s3,a2,a1
    800011b6:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800011ba:	893e                	mv	s2,a5
    800011bc:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800011c0:	6b85                	lui	s7,0x1
    800011c2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800011c6:	4605                	li	a2,1
    800011c8:	85ca                	mv	a1,s2
    800011ca:	8556                	mv	a0,s5
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	e7e080e7          	jalr	-386(ra) # 8000104a <walk>
    800011d4:	c51d                	beqz	a0,80001202 <mappages+0x72>
    if(*pte & PTE_V)
    800011d6:	611c                	ld	a5,0(a0)
    800011d8:	8b85                	andi	a5,a5,1
    800011da:	ef81                	bnez	a5,800011f2 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800011dc:	80b1                	srli	s1,s1,0xc
    800011de:	04aa                	slli	s1,s1,0xa
    800011e0:	0164e4b3          	or	s1,s1,s6
    800011e4:	0014e493          	ori	s1,s1,1
    800011e8:	e104                	sd	s1,0(a0)
    if(a == last)
    800011ea:	03390863          	beq	s2,s3,8000121a <mappages+0x8a>
    a += PGSIZE;
    800011ee:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800011f0:	bfc9                	j	800011c2 <mappages+0x32>
      panic("remap");
    800011f2:	00007517          	auipc	a0,0x7
    800011f6:	eee50513          	addi	a0,a0,-274 # 800080e0 <digits+0xa0>
    800011fa:	fffff097          	auipc	ra,0xfffff
    800011fe:	34e080e7          	jalr	846(ra) # 80000548 <panic>
      return -1;
    80001202:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001204:	60a6                	ld	ra,72(sp)
    80001206:	6406                	ld	s0,64(sp)
    80001208:	74e2                	ld	s1,56(sp)
    8000120a:	7942                	ld	s2,48(sp)
    8000120c:	79a2                	ld	s3,40(sp)
    8000120e:	7a02                	ld	s4,32(sp)
    80001210:	6ae2                	ld	s5,24(sp)
    80001212:	6b42                	ld	s6,16(sp)
    80001214:	6ba2                	ld	s7,8(sp)
    80001216:	6161                	addi	sp,sp,80
    80001218:	8082                	ret
  return 0;
    8000121a:	4501                	li	a0,0
    8000121c:	b7e5                	j	80001204 <mappages+0x74>

000000008000121e <kvmmap>:
{
    8000121e:	1141                	addi	sp,sp,-16
    80001220:	e406                	sd	ra,8(sp)
    80001222:	e022                	sd	s0,0(sp)
    80001224:	0800                	addi	s0,sp,16
    80001226:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    80001228:	86ae                	mv	a3,a1
    8000122a:	85aa                	mv	a1,a0
    8000122c:	00008517          	auipc	a0,0x8
    80001230:	de453503          	ld	a0,-540(a0) # 80009010 <kernel_pagetable>
    80001234:	00000097          	auipc	ra,0x0
    80001238:	f5c080e7          	jalr	-164(ra) # 80001190 <mappages>
    8000123c:	e509                	bnez	a0,80001246 <kvmmap+0x28>
}
    8000123e:	60a2                	ld	ra,8(sp)
    80001240:	6402                	ld	s0,0(sp)
    80001242:	0141                	addi	sp,sp,16
    80001244:	8082                	ret
    panic("kvmmap");
    80001246:	00007517          	auipc	a0,0x7
    8000124a:	ea250513          	addi	a0,a0,-350 # 800080e8 <digits+0xa8>
    8000124e:	fffff097          	auipc	ra,0xfffff
    80001252:	2fa080e7          	jalr	762(ra) # 80000548 <panic>

0000000080001256 <kvminit>:
{
    80001256:	1101                	addi	sp,sp,-32
    80001258:	ec06                	sd	ra,24(sp)
    8000125a:	e822                	sd	s0,16(sp)
    8000125c:	e426                	sd	s1,8(sp)
    8000125e:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    80001260:	00000097          	auipc	ra,0x0
    80001264:	8c0080e7          	jalr	-1856(ra) # 80000b20 <kalloc>
    80001268:	00008797          	auipc	a5,0x8
    8000126c:	daa7b423          	sd	a0,-600(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    80001270:	6605                	lui	a2,0x1
    80001272:	4581                	li	a1,0
    80001274:	00000097          	auipc	ra,0x0
    80001278:	aea080e7          	jalr	-1302(ra) # 80000d5e <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000127c:	4699                	li	a3,6
    8000127e:	6605                	lui	a2,0x1
    80001280:	100005b7          	lui	a1,0x10000
    80001284:	10000537          	lui	a0,0x10000
    80001288:	00000097          	auipc	ra,0x0
    8000128c:	f96080e7          	jalr	-106(ra) # 8000121e <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001290:	4699                	li	a3,6
    80001292:	6605                	lui	a2,0x1
    80001294:	100015b7          	lui	a1,0x10001
    80001298:	10001537          	lui	a0,0x10001
    8000129c:	00000097          	auipc	ra,0x0
    800012a0:	f82080e7          	jalr	-126(ra) # 8000121e <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    800012a4:	4699                	li	a3,6
    800012a6:	6641                	lui	a2,0x10
    800012a8:	020005b7          	lui	a1,0x2000
    800012ac:	02000537          	lui	a0,0x2000
    800012b0:	00000097          	auipc	ra,0x0
    800012b4:	f6e080e7          	jalr	-146(ra) # 8000121e <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800012b8:	4699                	li	a3,6
    800012ba:	00400637          	lui	a2,0x400
    800012be:	0c0005b7          	lui	a1,0xc000
    800012c2:	0c000537          	lui	a0,0xc000
    800012c6:	00000097          	auipc	ra,0x0
    800012ca:	f58080e7          	jalr	-168(ra) # 8000121e <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800012ce:	00007497          	auipc	s1,0x7
    800012d2:	d3248493          	addi	s1,s1,-718 # 80008000 <etext>
    800012d6:	46a9                	li	a3,10
    800012d8:	80007617          	auipc	a2,0x80007
    800012dc:	d2860613          	addi	a2,a2,-728 # 8000 <_entry-0x7fff8000>
    800012e0:	4585                	li	a1,1
    800012e2:	05fe                	slli	a1,a1,0x1f
    800012e4:	852e                	mv	a0,a1
    800012e6:	00000097          	auipc	ra,0x0
    800012ea:	f38080e7          	jalr	-200(ra) # 8000121e <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800012ee:	4699                	li	a3,6
    800012f0:	4645                	li	a2,17
    800012f2:	066e                	slli	a2,a2,0x1b
    800012f4:	8e05                	sub	a2,a2,s1
    800012f6:	85a6                	mv	a1,s1
    800012f8:	8526                	mv	a0,s1
    800012fa:	00000097          	auipc	ra,0x0
    800012fe:	f24080e7          	jalr	-220(ra) # 8000121e <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001302:	46a9                	li	a3,10
    80001304:	6605                	lui	a2,0x1
    80001306:	00006597          	auipc	a1,0x6
    8000130a:	cfa58593          	addi	a1,a1,-774 # 80007000 <_trampoline>
    8000130e:	04000537          	lui	a0,0x4000
    80001312:	157d                	addi	a0,a0,-1
    80001314:	0532                	slli	a0,a0,0xc
    80001316:	00000097          	auipc	ra,0x0
    8000131a:	f08080e7          	jalr	-248(ra) # 8000121e <kvmmap>
}
    8000131e:	60e2                	ld	ra,24(sp)
    80001320:	6442                	ld	s0,16(sp)
    80001322:	64a2                	ld	s1,8(sp)
    80001324:	6105                	addi	sp,sp,32
    80001326:	8082                	ret

0000000080001328 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001328:	715d                	addi	sp,sp,-80
    8000132a:	e486                	sd	ra,72(sp)
    8000132c:	e0a2                	sd	s0,64(sp)
    8000132e:	fc26                	sd	s1,56(sp)
    80001330:	f84a                	sd	s2,48(sp)
    80001332:	f44e                	sd	s3,40(sp)
    80001334:	f052                	sd	s4,32(sp)
    80001336:	ec56                	sd	s5,24(sp)
    80001338:	e85a                	sd	s6,16(sp)
    8000133a:	e45e                	sd	s7,8(sp)
    8000133c:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000133e:	03459793          	slli	a5,a1,0x34
    80001342:	e795                	bnez	a5,8000136e <uvmunmap+0x46>
    80001344:	8a2a                	mv	s4,a0
    80001346:	892e                	mv	s2,a1
    80001348:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000134a:	0632                	slli	a2,a2,0xc
    8000134c:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001350:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001352:	6b05                	lui	s6,0x1
    80001354:	0735e863          	bltu	a1,s3,800013c4 <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001358:	60a6                	ld	ra,72(sp)
    8000135a:	6406                	ld	s0,64(sp)
    8000135c:	74e2                	ld	s1,56(sp)
    8000135e:	7942                	ld	s2,48(sp)
    80001360:	79a2                	ld	s3,40(sp)
    80001362:	7a02                	ld	s4,32(sp)
    80001364:	6ae2                	ld	s5,24(sp)
    80001366:	6b42                	ld	s6,16(sp)
    80001368:	6ba2                	ld	s7,8(sp)
    8000136a:	6161                	addi	sp,sp,80
    8000136c:	8082                	ret
    panic("uvmunmap: not aligned");
    8000136e:	00007517          	auipc	a0,0x7
    80001372:	d8250513          	addi	a0,a0,-638 # 800080f0 <digits+0xb0>
    80001376:	fffff097          	auipc	ra,0xfffff
    8000137a:	1d2080e7          	jalr	466(ra) # 80000548 <panic>
      panic("uvmunmap: walk");
    8000137e:	00007517          	auipc	a0,0x7
    80001382:	d8a50513          	addi	a0,a0,-630 # 80008108 <digits+0xc8>
    80001386:	fffff097          	auipc	ra,0xfffff
    8000138a:	1c2080e7          	jalr	450(ra) # 80000548 <panic>
      panic("uvmunmap: not mapped");
    8000138e:	00007517          	auipc	a0,0x7
    80001392:	d8a50513          	addi	a0,a0,-630 # 80008118 <digits+0xd8>
    80001396:	fffff097          	auipc	ra,0xfffff
    8000139a:	1b2080e7          	jalr	434(ra) # 80000548 <panic>
      panic("uvmunmap: not a leaf");
    8000139e:	00007517          	auipc	a0,0x7
    800013a2:	d9250513          	addi	a0,a0,-622 # 80008130 <digits+0xf0>
    800013a6:	fffff097          	auipc	ra,0xfffff
    800013aa:	1a2080e7          	jalr	418(ra) # 80000548 <panic>
      uint64 pa = PTE2PA(*pte);
    800013ae:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800013b0:	0532                	slli	a0,a0,0xc
    800013b2:	fffff097          	auipc	ra,0xfffff
    800013b6:	672080e7          	jalr	1650(ra) # 80000a24 <kfree>
    *pte = 0;
    800013ba:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013be:	995a                	add	s2,s2,s6
    800013c0:	f9397ce3          	bgeu	s2,s3,80001358 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800013c4:	4601                	li	a2,0
    800013c6:	85ca                	mv	a1,s2
    800013c8:	8552                	mv	a0,s4
    800013ca:	00000097          	auipc	ra,0x0
    800013ce:	c80080e7          	jalr	-896(ra) # 8000104a <walk>
    800013d2:	84aa                	mv	s1,a0
    800013d4:	d54d                	beqz	a0,8000137e <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800013d6:	6108                	ld	a0,0(a0)
    800013d8:	00157793          	andi	a5,a0,1
    800013dc:	dbcd                	beqz	a5,8000138e <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800013de:	3ff57793          	andi	a5,a0,1023
    800013e2:	fb778ee3          	beq	a5,s7,8000139e <uvmunmap+0x76>
    if(do_free){
    800013e6:	fc0a8ae3          	beqz	s5,800013ba <uvmunmap+0x92>
    800013ea:	b7d1                	j	800013ae <uvmunmap+0x86>

00000000800013ec <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800013ec:	1101                	addi	sp,sp,-32
    800013ee:	ec06                	sd	ra,24(sp)
    800013f0:	e822                	sd	s0,16(sp)
    800013f2:	e426                	sd	s1,8(sp)
    800013f4:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800013f6:	fffff097          	auipc	ra,0xfffff
    800013fa:	72a080e7          	jalr	1834(ra) # 80000b20 <kalloc>
    800013fe:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001400:	c519                	beqz	a0,8000140e <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001402:	6605                	lui	a2,0x1
    80001404:	4581                	li	a1,0
    80001406:	00000097          	auipc	ra,0x0
    8000140a:	958080e7          	jalr	-1704(ra) # 80000d5e <memset>
  return pagetable;
}
    8000140e:	8526                	mv	a0,s1
    80001410:	60e2                	ld	ra,24(sp)
    80001412:	6442                	ld	s0,16(sp)
    80001414:	64a2                	ld	s1,8(sp)
    80001416:	6105                	addi	sp,sp,32
    80001418:	8082                	ret

000000008000141a <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    8000141a:	7179                	addi	sp,sp,-48
    8000141c:	f406                	sd	ra,40(sp)
    8000141e:	f022                	sd	s0,32(sp)
    80001420:	ec26                	sd	s1,24(sp)
    80001422:	e84a                	sd	s2,16(sp)
    80001424:	e44e                	sd	s3,8(sp)
    80001426:	e052                	sd	s4,0(sp)
    80001428:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000142a:	6785                	lui	a5,0x1
    8000142c:	04f67863          	bgeu	a2,a5,8000147c <uvminit+0x62>
    80001430:	8a2a                	mv	s4,a0
    80001432:	89ae                	mv	s3,a1
    80001434:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001436:	fffff097          	auipc	ra,0xfffff
    8000143a:	6ea080e7          	jalr	1770(ra) # 80000b20 <kalloc>
    8000143e:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001440:	6605                	lui	a2,0x1
    80001442:	4581                	li	a1,0
    80001444:	00000097          	auipc	ra,0x0
    80001448:	91a080e7          	jalr	-1766(ra) # 80000d5e <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000144c:	4779                	li	a4,30
    8000144e:	86ca                	mv	a3,s2
    80001450:	6605                	lui	a2,0x1
    80001452:	4581                	li	a1,0
    80001454:	8552                	mv	a0,s4
    80001456:	00000097          	auipc	ra,0x0
    8000145a:	d3a080e7          	jalr	-710(ra) # 80001190 <mappages>
  memmove(mem, src, sz);
    8000145e:	8626                	mv	a2,s1
    80001460:	85ce                	mv	a1,s3
    80001462:	854a                	mv	a0,s2
    80001464:	00000097          	auipc	ra,0x0
    80001468:	95a080e7          	jalr	-1702(ra) # 80000dbe <memmove>
}
    8000146c:	70a2                	ld	ra,40(sp)
    8000146e:	7402                	ld	s0,32(sp)
    80001470:	64e2                	ld	s1,24(sp)
    80001472:	6942                	ld	s2,16(sp)
    80001474:	69a2                	ld	s3,8(sp)
    80001476:	6a02                	ld	s4,0(sp)
    80001478:	6145                	addi	sp,sp,48
    8000147a:	8082                	ret
    panic("inituvm: more than a page");
    8000147c:	00007517          	auipc	a0,0x7
    80001480:	ccc50513          	addi	a0,a0,-820 # 80008148 <digits+0x108>
    80001484:	fffff097          	auipc	ra,0xfffff
    80001488:	0c4080e7          	jalr	196(ra) # 80000548 <panic>

000000008000148c <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000148c:	1101                	addi	sp,sp,-32
    8000148e:	ec06                	sd	ra,24(sp)
    80001490:	e822                	sd	s0,16(sp)
    80001492:	e426                	sd	s1,8(sp)
    80001494:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001496:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001498:	00b67d63          	bgeu	a2,a1,800014b2 <uvmdealloc+0x26>
    8000149c:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000149e:	6785                	lui	a5,0x1
    800014a0:	17fd                	addi	a5,a5,-1
    800014a2:	00f60733          	add	a4,a2,a5
    800014a6:	767d                	lui	a2,0xfffff
    800014a8:	8f71                	and	a4,a4,a2
    800014aa:	97ae                	add	a5,a5,a1
    800014ac:	8ff1                	and	a5,a5,a2
    800014ae:	00f76863          	bltu	a4,a5,800014be <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800014b2:	8526                	mv	a0,s1
    800014b4:	60e2                	ld	ra,24(sp)
    800014b6:	6442                	ld	s0,16(sp)
    800014b8:	64a2                	ld	s1,8(sp)
    800014ba:	6105                	addi	sp,sp,32
    800014bc:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800014be:	8f99                	sub	a5,a5,a4
    800014c0:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800014c2:	4685                	li	a3,1
    800014c4:	0007861b          	sext.w	a2,a5
    800014c8:	85ba                	mv	a1,a4
    800014ca:	00000097          	auipc	ra,0x0
    800014ce:	e5e080e7          	jalr	-418(ra) # 80001328 <uvmunmap>
    800014d2:	b7c5                	j	800014b2 <uvmdealloc+0x26>

00000000800014d4 <uvmalloc>:
  if(newsz < oldsz)
    800014d4:	0ab66163          	bltu	a2,a1,80001576 <uvmalloc+0xa2>
{
    800014d8:	7139                	addi	sp,sp,-64
    800014da:	fc06                	sd	ra,56(sp)
    800014dc:	f822                	sd	s0,48(sp)
    800014de:	f426                	sd	s1,40(sp)
    800014e0:	f04a                	sd	s2,32(sp)
    800014e2:	ec4e                	sd	s3,24(sp)
    800014e4:	e852                	sd	s4,16(sp)
    800014e6:	e456                	sd	s5,8(sp)
    800014e8:	0080                	addi	s0,sp,64
    800014ea:	8aaa                	mv	s5,a0
    800014ec:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800014ee:	6985                	lui	s3,0x1
    800014f0:	19fd                	addi	s3,s3,-1
    800014f2:	95ce                	add	a1,a1,s3
    800014f4:	79fd                	lui	s3,0xfffff
    800014f6:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014fa:	08c9f063          	bgeu	s3,a2,8000157a <uvmalloc+0xa6>
    800014fe:	894e                	mv	s2,s3
    mem = kalloc();
    80001500:	fffff097          	auipc	ra,0xfffff
    80001504:	620080e7          	jalr	1568(ra) # 80000b20 <kalloc>
    80001508:	84aa                	mv	s1,a0
    if(mem == 0){
    8000150a:	c51d                	beqz	a0,80001538 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000150c:	6605                	lui	a2,0x1
    8000150e:	4581                	li	a1,0
    80001510:	00000097          	auipc	ra,0x0
    80001514:	84e080e7          	jalr	-1970(ra) # 80000d5e <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001518:	4779                	li	a4,30
    8000151a:	86a6                	mv	a3,s1
    8000151c:	6605                	lui	a2,0x1
    8000151e:	85ca                	mv	a1,s2
    80001520:	8556                	mv	a0,s5
    80001522:	00000097          	auipc	ra,0x0
    80001526:	c6e080e7          	jalr	-914(ra) # 80001190 <mappages>
    8000152a:	e905                	bnez	a0,8000155a <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000152c:	6785                	lui	a5,0x1
    8000152e:	993e                	add	s2,s2,a5
    80001530:	fd4968e3          	bltu	s2,s4,80001500 <uvmalloc+0x2c>
  return newsz;
    80001534:	8552                	mv	a0,s4
    80001536:	a809                	j	80001548 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001538:	864e                	mv	a2,s3
    8000153a:	85ca                	mv	a1,s2
    8000153c:	8556                	mv	a0,s5
    8000153e:	00000097          	auipc	ra,0x0
    80001542:	f4e080e7          	jalr	-178(ra) # 8000148c <uvmdealloc>
      return 0;
    80001546:	4501                	li	a0,0
}
    80001548:	70e2                	ld	ra,56(sp)
    8000154a:	7442                	ld	s0,48(sp)
    8000154c:	74a2                	ld	s1,40(sp)
    8000154e:	7902                	ld	s2,32(sp)
    80001550:	69e2                	ld	s3,24(sp)
    80001552:	6a42                	ld	s4,16(sp)
    80001554:	6aa2                	ld	s5,8(sp)
    80001556:	6121                	addi	sp,sp,64
    80001558:	8082                	ret
      kfree(mem);
    8000155a:	8526                	mv	a0,s1
    8000155c:	fffff097          	auipc	ra,0xfffff
    80001560:	4c8080e7          	jalr	1224(ra) # 80000a24 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001564:	864e                	mv	a2,s3
    80001566:	85ca                	mv	a1,s2
    80001568:	8556                	mv	a0,s5
    8000156a:	00000097          	auipc	ra,0x0
    8000156e:	f22080e7          	jalr	-222(ra) # 8000148c <uvmdealloc>
      return 0;
    80001572:	4501                	li	a0,0
    80001574:	bfd1                	j	80001548 <uvmalloc+0x74>
    return oldsz;
    80001576:	852e                	mv	a0,a1
}
    80001578:	8082                	ret
  return newsz;
    8000157a:	8532                	mv	a0,a2
    8000157c:	b7f1                	j	80001548 <uvmalloc+0x74>

000000008000157e <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000157e:	7179                	addi	sp,sp,-48
    80001580:	f406                	sd	ra,40(sp)
    80001582:	f022                	sd	s0,32(sp)
    80001584:	ec26                	sd	s1,24(sp)
    80001586:	e84a                	sd	s2,16(sp)
    80001588:	e44e                	sd	s3,8(sp)
    8000158a:	e052                	sd	s4,0(sp)
    8000158c:	1800                	addi	s0,sp,48
    8000158e:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001590:	84aa                	mv	s1,a0
    80001592:	6905                	lui	s2,0x1
    80001594:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001596:	4985                	li	s3,1
    80001598:	a821                	j	800015b0 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000159a:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    8000159c:	0532                	slli	a0,a0,0xc
    8000159e:	00000097          	auipc	ra,0x0
    800015a2:	fe0080e7          	jalr	-32(ra) # 8000157e <freewalk>
      pagetable[i] = 0;
    800015a6:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800015aa:	04a1                	addi	s1,s1,8
    800015ac:	03248163          	beq	s1,s2,800015ce <freewalk+0x50>
    pte_t pte = pagetable[i];
    800015b0:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015b2:	00f57793          	andi	a5,a0,15
    800015b6:	ff3782e3          	beq	a5,s3,8000159a <freewalk+0x1c>
    } else if(pte & PTE_V){
    800015ba:	8905                	andi	a0,a0,1
    800015bc:	d57d                	beqz	a0,800015aa <freewalk+0x2c>
      panic("freewalk: leaf");
    800015be:	00007517          	auipc	a0,0x7
    800015c2:	baa50513          	addi	a0,a0,-1110 # 80008168 <digits+0x128>
    800015c6:	fffff097          	auipc	ra,0xfffff
    800015ca:	f82080e7          	jalr	-126(ra) # 80000548 <panic>
    }
  }
  kfree((void*)pagetable);
    800015ce:	8552                	mv	a0,s4
    800015d0:	fffff097          	auipc	ra,0xfffff
    800015d4:	454080e7          	jalr	1108(ra) # 80000a24 <kfree>
}
    800015d8:	70a2                	ld	ra,40(sp)
    800015da:	7402                	ld	s0,32(sp)
    800015dc:	64e2                	ld	s1,24(sp)
    800015de:	6942                	ld	s2,16(sp)
    800015e0:	69a2                	ld	s3,8(sp)
    800015e2:	6a02                	ld	s4,0(sp)
    800015e4:	6145                	addi	sp,sp,48
    800015e6:	8082                	ret

00000000800015e8 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015e8:	1101                	addi	sp,sp,-32
    800015ea:	ec06                	sd	ra,24(sp)
    800015ec:	e822                	sd	s0,16(sp)
    800015ee:	e426                	sd	s1,8(sp)
    800015f0:	1000                	addi	s0,sp,32
    800015f2:	84aa                	mv	s1,a0
  if(sz > 0)
    800015f4:	e999                	bnez	a1,8000160a <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015f6:	8526                	mv	a0,s1
    800015f8:	00000097          	auipc	ra,0x0
    800015fc:	f86080e7          	jalr	-122(ra) # 8000157e <freewalk>
}
    80001600:	60e2                	ld	ra,24(sp)
    80001602:	6442                	ld	s0,16(sp)
    80001604:	64a2                	ld	s1,8(sp)
    80001606:	6105                	addi	sp,sp,32
    80001608:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000160a:	6605                	lui	a2,0x1
    8000160c:	167d                	addi	a2,a2,-1
    8000160e:	962e                	add	a2,a2,a1
    80001610:	4685                	li	a3,1
    80001612:	8231                	srli	a2,a2,0xc
    80001614:	4581                	li	a1,0
    80001616:	00000097          	auipc	ra,0x0
    8000161a:	d12080e7          	jalr	-750(ra) # 80001328 <uvmunmap>
    8000161e:	bfe1                	j	800015f6 <uvmfree+0xe>

0000000080001620 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001620:	c679                	beqz	a2,800016ee <uvmcopy+0xce>
{
    80001622:	715d                	addi	sp,sp,-80
    80001624:	e486                	sd	ra,72(sp)
    80001626:	e0a2                	sd	s0,64(sp)
    80001628:	fc26                	sd	s1,56(sp)
    8000162a:	f84a                	sd	s2,48(sp)
    8000162c:	f44e                	sd	s3,40(sp)
    8000162e:	f052                	sd	s4,32(sp)
    80001630:	ec56                	sd	s5,24(sp)
    80001632:	e85a                	sd	s6,16(sp)
    80001634:	e45e                	sd	s7,8(sp)
    80001636:	0880                	addi	s0,sp,80
    80001638:	8b2a                	mv	s6,a0
    8000163a:	8aae                	mv	s5,a1
    8000163c:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000163e:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001640:	4601                	li	a2,0
    80001642:	85ce                	mv	a1,s3
    80001644:	855a                	mv	a0,s6
    80001646:	00000097          	auipc	ra,0x0
    8000164a:	a04080e7          	jalr	-1532(ra) # 8000104a <walk>
    8000164e:	c531                	beqz	a0,8000169a <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001650:	6118                	ld	a4,0(a0)
    80001652:	00177793          	andi	a5,a4,1
    80001656:	cbb1                	beqz	a5,800016aa <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001658:	00a75593          	srli	a1,a4,0xa
    8000165c:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001660:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001664:	fffff097          	auipc	ra,0xfffff
    80001668:	4bc080e7          	jalr	1212(ra) # 80000b20 <kalloc>
    8000166c:	892a                	mv	s2,a0
    8000166e:	c939                	beqz	a0,800016c4 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001670:	6605                	lui	a2,0x1
    80001672:	85de                	mv	a1,s7
    80001674:	fffff097          	auipc	ra,0xfffff
    80001678:	74a080e7          	jalr	1866(ra) # 80000dbe <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000167c:	8726                	mv	a4,s1
    8000167e:	86ca                	mv	a3,s2
    80001680:	6605                	lui	a2,0x1
    80001682:	85ce                	mv	a1,s3
    80001684:	8556                	mv	a0,s5
    80001686:	00000097          	auipc	ra,0x0
    8000168a:	b0a080e7          	jalr	-1270(ra) # 80001190 <mappages>
    8000168e:	e515                	bnez	a0,800016ba <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001690:	6785                	lui	a5,0x1
    80001692:	99be                	add	s3,s3,a5
    80001694:	fb49e6e3          	bltu	s3,s4,80001640 <uvmcopy+0x20>
    80001698:	a081                	j	800016d8 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    8000169a:	00007517          	auipc	a0,0x7
    8000169e:	ade50513          	addi	a0,a0,-1314 # 80008178 <digits+0x138>
    800016a2:	fffff097          	auipc	ra,0xfffff
    800016a6:	ea6080e7          	jalr	-346(ra) # 80000548 <panic>
      panic("uvmcopy: page not present");
    800016aa:	00007517          	auipc	a0,0x7
    800016ae:	aee50513          	addi	a0,a0,-1298 # 80008198 <digits+0x158>
    800016b2:	fffff097          	auipc	ra,0xfffff
    800016b6:	e96080e7          	jalr	-362(ra) # 80000548 <panic>
      kfree(mem);
    800016ba:	854a                	mv	a0,s2
    800016bc:	fffff097          	auipc	ra,0xfffff
    800016c0:	368080e7          	jalr	872(ra) # 80000a24 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800016c4:	4685                	li	a3,1
    800016c6:	00c9d613          	srli	a2,s3,0xc
    800016ca:	4581                	li	a1,0
    800016cc:	8556                	mv	a0,s5
    800016ce:	00000097          	auipc	ra,0x0
    800016d2:	c5a080e7          	jalr	-934(ra) # 80001328 <uvmunmap>
  return -1;
    800016d6:	557d                	li	a0,-1
}
    800016d8:	60a6                	ld	ra,72(sp)
    800016da:	6406                	ld	s0,64(sp)
    800016dc:	74e2                	ld	s1,56(sp)
    800016de:	7942                	ld	s2,48(sp)
    800016e0:	79a2                	ld	s3,40(sp)
    800016e2:	7a02                	ld	s4,32(sp)
    800016e4:	6ae2                	ld	s5,24(sp)
    800016e6:	6b42                	ld	s6,16(sp)
    800016e8:	6ba2                	ld	s7,8(sp)
    800016ea:	6161                	addi	sp,sp,80
    800016ec:	8082                	ret
  return 0;
    800016ee:	4501                	li	a0,0
}
    800016f0:	8082                	ret

00000000800016f2 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800016f2:	1141                	addi	sp,sp,-16
    800016f4:	e406                	sd	ra,8(sp)
    800016f6:	e022                	sd	s0,0(sp)
    800016f8:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016fa:	4601                	li	a2,0
    800016fc:	00000097          	auipc	ra,0x0
    80001700:	94e080e7          	jalr	-1714(ra) # 8000104a <walk>
  if(pte == 0)
    80001704:	c901                	beqz	a0,80001714 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001706:	611c                	ld	a5,0(a0)
    80001708:	9bbd                	andi	a5,a5,-17
    8000170a:	e11c                	sd	a5,0(a0)
}
    8000170c:	60a2                	ld	ra,8(sp)
    8000170e:	6402                	ld	s0,0(sp)
    80001710:	0141                	addi	sp,sp,16
    80001712:	8082                	ret
    panic("uvmclear");
    80001714:	00007517          	auipc	a0,0x7
    80001718:	aa450513          	addi	a0,a0,-1372 # 800081b8 <digits+0x178>
    8000171c:	fffff097          	auipc	ra,0xfffff
    80001720:	e2c080e7          	jalr	-468(ra) # 80000548 <panic>

0000000080001724 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001724:	c6bd                	beqz	a3,80001792 <copyout+0x6e>
{
    80001726:	715d                	addi	sp,sp,-80
    80001728:	e486                	sd	ra,72(sp)
    8000172a:	e0a2                	sd	s0,64(sp)
    8000172c:	fc26                	sd	s1,56(sp)
    8000172e:	f84a                	sd	s2,48(sp)
    80001730:	f44e                	sd	s3,40(sp)
    80001732:	f052                	sd	s4,32(sp)
    80001734:	ec56                	sd	s5,24(sp)
    80001736:	e85a                	sd	s6,16(sp)
    80001738:	e45e                	sd	s7,8(sp)
    8000173a:	e062                	sd	s8,0(sp)
    8000173c:	0880                	addi	s0,sp,80
    8000173e:	8b2a                	mv	s6,a0
    80001740:	8c2e                	mv	s8,a1
    80001742:	8a32                	mv	s4,a2
    80001744:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001746:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001748:	6a85                	lui	s5,0x1
    8000174a:	a015                	j	8000176e <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000174c:	9562                	add	a0,a0,s8
    8000174e:	0004861b          	sext.w	a2,s1
    80001752:	85d2                	mv	a1,s4
    80001754:	41250533          	sub	a0,a0,s2
    80001758:	fffff097          	auipc	ra,0xfffff
    8000175c:	666080e7          	jalr	1638(ra) # 80000dbe <memmove>

    len -= n;
    80001760:	409989b3          	sub	s3,s3,s1
    src += n;
    80001764:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001766:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000176a:	02098263          	beqz	s3,8000178e <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000176e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001772:	85ca                	mv	a1,s2
    80001774:	855a                	mv	a0,s6
    80001776:	00000097          	auipc	ra,0x0
    8000177a:	97a080e7          	jalr	-1670(ra) # 800010f0 <walkaddr>
    if(pa0 == 0)
    8000177e:	cd01                	beqz	a0,80001796 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001780:	418904b3          	sub	s1,s2,s8
    80001784:	94d6                	add	s1,s1,s5
    if(n > len)
    80001786:	fc99f3e3          	bgeu	s3,s1,8000174c <copyout+0x28>
    8000178a:	84ce                	mv	s1,s3
    8000178c:	b7c1                	j	8000174c <copyout+0x28>
  }
  return 0;
    8000178e:	4501                	li	a0,0
    80001790:	a021                	j	80001798 <copyout+0x74>
    80001792:	4501                	li	a0,0
}
    80001794:	8082                	ret
      return -1;
    80001796:	557d                	li	a0,-1
}
    80001798:	60a6                	ld	ra,72(sp)
    8000179a:	6406                	ld	s0,64(sp)
    8000179c:	74e2                	ld	s1,56(sp)
    8000179e:	7942                	ld	s2,48(sp)
    800017a0:	79a2                	ld	s3,40(sp)
    800017a2:	7a02                	ld	s4,32(sp)
    800017a4:	6ae2                	ld	s5,24(sp)
    800017a6:	6b42                	ld	s6,16(sp)
    800017a8:	6ba2                	ld	s7,8(sp)
    800017aa:	6c02                	ld	s8,0(sp)
    800017ac:	6161                	addi	sp,sp,80
    800017ae:	8082                	ret

00000000800017b0 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800017b0:	c6bd                	beqz	a3,8000181e <copyin+0x6e>
{
    800017b2:	715d                	addi	sp,sp,-80
    800017b4:	e486                	sd	ra,72(sp)
    800017b6:	e0a2                	sd	s0,64(sp)
    800017b8:	fc26                	sd	s1,56(sp)
    800017ba:	f84a                	sd	s2,48(sp)
    800017bc:	f44e                	sd	s3,40(sp)
    800017be:	f052                	sd	s4,32(sp)
    800017c0:	ec56                	sd	s5,24(sp)
    800017c2:	e85a                	sd	s6,16(sp)
    800017c4:	e45e                	sd	s7,8(sp)
    800017c6:	e062                	sd	s8,0(sp)
    800017c8:	0880                	addi	s0,sp,80
    800017ca:	8b2a                	mv	s6,a0
    800017cc:	8a2e                	mv	s4,a1
    800017ce:	8c32                	mv	s8,a2
    800017d0:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800017d2:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017d4:	6a85                	lui	s5,0x1
    800017d6:	a015                	j	800017fa <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800017d8:	9562                	add	a0,a0,s8
    800017da:	0004861b          	sext.w	a2,s1
    800017de:	412505b3          	sub	a1,a0,s2
    800017e2:	8552                	mv	a0,s4
    800017e4:	fffff097          	auipc	ra,0xfffff
    800017e8:	5da080e7          	jalr	1498(ra) # 80000dbe <memmove>

    len -= n;
    800017ec:	409989b3          	sub	s3,s3,s1
    dst += n;
    800017f0:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800017f2:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017f6:	02098263          	beqz	s3,8000181a <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    800017fa:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017fe:	85ca                	mv	a1,s2
    80001800:	855a                	mv	a0,s6
    80001802:	00000097          	auipc	ra,0x0
    80001806:	8ee080e7          	jalr	-1810(ra) # 800010f0 <walkaddr>
    if(pa0 == 0)
    8000180a:	cd01                	beqz	a0,80001822 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    8000180c:	418904b3          	sub	s1,s2,s8
    80001810:	94d6                	add	s1,s1,s5
    if(n > len)
    80001812:	fc99f3e3          	bgeu	s3,s1,800017d8 <copyin+0x28>
    80001816:	84ce                	mv	s1,s3
    80001818:	b7c1                	j	800017d8 <copyin+0x28>
  }
  return 0;
    8000181a:	4501                	li	a0,0
    8000181c:	a021                	j	80001824 <copyin+0x74>
    8000181e:	4501                	li	a0,0
}
    80001820:	8082                	ret
      return -1;
    80001822:	557d                	li	a0,-1
}
    80001824:	60a6                	ld	ra,72(sp)
    80001826:	6406                	ld	s0,64(sp)
    80001828:	74e2                	ld	s1,56(sp)
    8000182a:	7942                	ld	s2,48(sp)
    8000182c:	79a2                	ld	s3,40(sp)
    8000182e:	7a02                	ld	s4,32(sp)
    80001830:	6ae2                	ld	s5,24(sp)
    80001832:	6b42                	ld	s6,16(sp)
    80001834:	6ba2                	ld	s7,8(sp)
    80001836:	6c02                	ld	s8,0(sp)
    80001838:	6161                	addi	sp,sp,80
    8000183a:	8082                	ret

000000008000183c <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000183c:	c6c5                	beqz	a3,800018e4 <copyinstr+0xa8>
{
    8000183e:	715d                	addi	sp,sp,-80
    80001840:	e486                	sd	ra,72(sp)
    80001842:	e0a2                	sd	s0,64(sp)
    80001844:	fc26                	sd	s1,56(sp)
    80001846:	f84a                	sd	s2,48(sp)
    80001848:	f44e                	sd	s3,40(sp)
    8000184a:	f052                	sd	s4,32(sp)
    8000184c:	ec56                	sd	s5,24(sp)
    8000184e:	e85a                	sd	s6,16(sp)
    80001850:	e45e                	sd	s7,8(sp)
    80001852:	0880                	addi	s0,sp,80
    80001854:	8a2a                	mv	s4,a0
    80001856:	8b2e                	mv	s6,a1
    80001858:	8bb2                	mv	s7,a2
    8000185a:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    8000185c:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000185e:	6985                	lui	s3,0x1
    80001860:	a035                	j	8000188c <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001862:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001866:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001868:	0017b793          	seqz	a5,a5
    8000186c:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001870:	60a6                	ld	ra,72(sp)
    80001872:	6406                	ld	s0,64(sp)
    80001874:	74e2                	ld	s1,56(sp)
    80001876:	7942                	ld	s2,48(sp)
    80001878:	79a2                	ld	s3,40(sp)
    8000187a:	7a02                	ld	s4,32(sp)
    8000187c:	6ae2                	ld	s5,24(sp)
    8000187e:	6b42                	ld	s6,16(sp)
    80001880:	6ba2                	ld	s7,8(sp)
    80001882:	6161                	addi	sp,sp,80
    80001884:	8082                	ret
    srcva = va0 + PGSIZE;
    80001886:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    8000188a:	c8a9                	beqz	s1,800018dc <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    8000188c:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001890:	85ca                	mv	a1,s2
    80001892:	8552                	mv	a0,s4
    80001894:	00000097          	auipc	ra,0x0
    80001898:	85c080e7          	jalr	-1956(ra) # 800010f0 <walkaddr>
    if(pa0 == 0)
    8000189c:	c131                	beqz	a0,800018e0 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    8000189e:	41790833          	sub	a6,s2,s7
    800018a2:	984e                	add	a6,a6,s3
    if(n > max)
    800018a4:	0104f363          	bgeu	s1,a6,800018aa <copyinstr+0x6e>
    800018a8:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800018aa:	955e                	add	a0,a0,s7
    800018ac:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800018b0:	fc080be3          	beqz	a6,80001886 <copyinstr+0x4a>
    800018b4:	985a                	add	a6,a6,s6
    800018b6:	87da                	mv	a5,s6
      if(*p == '\0'){
    800018b8:	41650633          	sub	a2,a0,s6
    800018bc:	14fd                	addi	s1,s1,-1
    800018be:	9b26                	add	s6,s6,s1
    800018c0:	00f60733          	add	a4,a2,a5
    800018c4:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9000>
    800018c8:	df49                	beqz	a4,80001862 <copyinstr+0x26>
        *dst = *p;
    800018ca:	00e78023          	sb	a4,0(a5)
      --max;
    800018ce:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800018d2:	0785                	addi	a5,a5,1
    while(n > 0){
    800018d4:	ff0796e3          	bne	a5,a6,800018c0 <copyinstr+0x84>
      dst++;
    800018d8:	8b42                	mv	s6,a6
    800018da:	b775                	j	80001886 <copyinstr+0x4a>
    800018dc:	4781                	li	a5,0
    800018de:	b769                	j	80001868 <copyinstr+0x2c>
      return -1;
    800018e0:	557d                	li	a0,-1
    800018e2:	b779                	j	80001870 <copyinstr+0x34>
  int got_null = 0;
    800018e4:	4781                	li	a5,0
  if(got_null){
    800018e6:	0017b793          	seqz	a5,a5
    800018ea:	40f00533          	neg	a0,a5
}
    800018ee:	8082                	ret

00000000800018f0 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    800018f0:	1101                	addi	sp,sp,-32
    800018f2:	ec06                	sd	ra,24(sp)
    800018f4:	e822                	sd	s0,16(sp)
    800018f6:	e426                	sd	s1,8(sp)
    800018f8:	1000                	addi	s0,sp,32
    800018fa:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800018fc:	fffff097          	auipc	ra,0xfffff
    80001900:	2ec080e7          	jalr	748(ra) # 80000be8 <holding>
    80001904:	c909                	beqz	a0,80001916 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001906:	749c                	ld	a5,40(s1)
    80001908:	00978f63          	beq	a5,s1,80001926 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    8000190c:	60e2                	ld	ra,24(sp)
    8000190e:	6442                	ld	s0,16(sp)
    80001910:	64a2                	ld	s1,8(sp)
    80001912:	6105                	addi	sp,sp,32
    80001914:	8082                	ret
    panic("wakeup1");
    80001916:	00007517          	auipc	a0,0x7
    8000191a:	8b250513          	addi	a0,a0,-1870 # 800081c8 <digits+0x188>
    8000191e:	fffff097          	auipc	ra,0xfffff
    80001922:	c2a080e7          	jalr	-982(ra) # 80000548 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001926:	4c98                	lw	a4,24(s1)
    80001928:	4785                	li	a5,1
    8000192a:	fef711e3          	bne	a4,a5,8000190c <wakeup1+0x1c>
    p->state = RUNNABLE;
    8000192e:	4789                	li	a5,2
    80001930:	cc9c                	sw	a5,24(s1)
}
    80001932:	bfe9                	j	8000190c <wakeup1+0x1c>

0000000080001934 <procinit>:
{
    80001934:	715d                	addi	sp,sp,-80
    80001936:	e486                	sd	ra,72(sp)
    80001938:	e0a2                	sd	s0,64(sp)
    8000193a:	fc26                	sd	s1,56(sp)
    8000193c:	f84a                	sd	s2,48(sp)
    8000193e:	f44e                	sd	s3,40(sp)
    80001940:	f052                	sd	s4,32(sp)
    80001942:	ec56                	sd	s5,24(sp)
    80001944:	e85a                	sd	s6,16(sp)
    80001946:	e45e                	sd	s7,8(sp)
    80001948:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    8000194a:	00007597          	auipc	a1,0x7
    8000194e:	88658593          	addi	a1,a1,-1914 # 800081d0 <digits+0x190>
    80001952:	00010517          	auipc	a0,0x10
    80001956:	ffe50513          	addi	a0,a0,-2 # 80011950 <pid_lock>
    8000195a:	fffff097          	auipc	ra,0xfffff
    8000195e:	278080e7          	jalr	632(ra) # 80000bd2 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001962:	00010917          	auipc	s2,0x10
    80001966:	40690913          	addi	s2,s2,1030 # 80011d68 <proc>
      initlock(&p->lock, "proc");
    8000196a:	00007b97          	auipc	s7,0x7
    8000196e:	86eb8b93          	addi	s7,s7,-1938 # 800081d8 <digits+0x198>
      uint64 va = KSTACK((int) (p - proc));
    80001972:	8b4a                	mv	s6,s2
    80001974:	00006a97          	auipc	s5,0x6
    80001978:	68ca8a93          	addi	s5,s5,1676 # 80008000 <etext>
    8000197c:	040009b7          	lui	s3,0x4000
    80001980:	19fd                	addi	s3,s3,-1
    80001982:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001984:	00016a17          	auipc	s4,0x16
    80001988:	fe4a0a13          	addi	s4,s4,-28 # 80017968 <tickslock>
      initlock(&p->lock, "proc");
    8000198c:	85de                	mv	a1,s7
    8000198e:	854a                	mv	a0,s2
    80001990:	fffff097          	auipc	ra,0xfffff
    80001994:	242080e7          	jalr	578(ra) # 80000bd2 <initlock>
      char *pa = kalloc();
    80001998:	fffff097          	auipc	ra,0xfffff
    8000199c:	188080e7          	jalr	392(ra) # 80000b20 <kalloc>
    800019a0:	85aa                	mv	a1,a0
      if(pa == 0)
    800019a2:	c929                	beqz	a0,800019f4 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    800019a4:	416904b3          	sub	s1,s2,s6
    800019a8:	8491                	srai	s1,s1,0x4
    800019aa:	000ab783          	ld	a5,0(s5)
    800019ae:	02f484b3          	mul	s1,s1,a5
    800019b2:	2485                	addiw	s1,s1,1
    800019b4:	00d4949b          	slliw	s1,s1,0xd
    800019b8:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019bc:	4699                	li	a3,6
    800019be:	6605                	lui	a2,0x1
    800019c0:	8526                	mv	a0,s1
    800019c2:	00000097          	auipc	ra,0x0
    800019c6:	85c080e7          	jalr	-1956(ra) # 8000121e <kvmmap>
      p->kstack = va;
    800019ca:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019ce:	17090913          	addi	s2,s2,368
    800019d2:	fb491de3          	bne	s2,s4,8000198c <procinit+0x58>
  kvminithart();
    800019d6:	fffff097          	auipc	ra,0xfffff
    800019da:	650080e7          	jalr	1616(ra) # 80001026 <kvminithart>
}
    800019de:	60a6                	ld	ra,72(sp)
    800019e0:	6406                	ld	s0,64(sp)
    800019e2:	74e2                	ld	s1,56(sp)
    800019e4:	7942                	ld	s2,48(sp)
    800019e6:	79a2                	ld	s3,40(sp)
    800019e8:	7a02                	ld	s4,32(sp)
    800019ea:	6ae2                	ld	s5,24(sp)
    800019ec:	6b42                	ld	s6,16(sp)
    800019ee:	6ba2                	ld	s7,8(sp)
    800019f0:	6161                	addi	sp,sp,80
    800019f2:	8082                	ret
        panic("kalloc");
    800019f4:	00006517          	auipc	a0,0x6
    800019f8:	7ec50513          	addi	a0,a0,2028 # 800081e0 <digits+0x1a0>
    800019fc:	fffff097          	auipc	ra,0xfffff
    80001a00:	b4c080e7          	jalr	-1204(ra) # 80000548 <panic>

0000000080001a04 <cpuid>:
{
    80001a04:	1141                	addi	sp,sp,-16
    80001a06:	e422                	sd	s0,8(sp)
    80001a08:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a0a:	8512                	mv	a0,tp
}
    80001a0c:	2501                	sext.w	a0,a0
    80001a0e:	6422                	ld	s0,8(sp)
    80001a10:	0141                	addi	sp,sp,16
    80001a12:	8082                	ret

0000000080001a14 <mycpu>:
mycpu(void) {
    80001a14:	1141                	addi	sp,sp,-16
    80001a16:	e422                	sd	s0,8(sp)
    80001a18:	0800                	addi	s0,sp,16
    80001a1a:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001a1c:	2781                	sext.w	a5,a5
    80001a1e:	079e                	slli	a5,a5,0x7
}
    80001a20:	00010517          	auipc	a0,0x10
    80001a24:	f4850513          	addi	a0,a0,-184 # 80011968 <cpus>
    80001a28:	953e                	add	a0,a0,a5
    80001a2a:	6422                	ld	s0,8(sp)
    80001a2c:	0141                	addi	sp,sp,16
    80001a2e:	8082                	ret

0000000080001a30 <myproc>:
myproc(void) {
    80001a30:	1101                	addi	sp,sp,-32
    80001a32:	ec06                	sd	ra,24(sp)
    80001a34:	e822                	sd	s0,16(sp)
    80001a36:	e426                	sd	s1,8(sp)
    80001a38:	1000                	addi	s0,sp,32
  push_off();
    80001a3a:	fffff097          	auipc	ra,0xfffff
    80001a3e:	1dc080e7          	jalr	476(ra) # 80000c16 <push_off>
    80001a42:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001a44:	2781                	sext.w	a5,a5
    80001a46:	079e                	slli	a5,a5,0x7
    80001a48:	00010717          	auipc	a4,0x10
    80001a4c:	f0870713          	addi	a4,a4,-248 # 80011950 <pid_lock>
    80001a50:	97ba                	add	a5,a5,a4
    80001a52:	6f84                	ld	s1,24(a5)
  pop_off();
    80001a54:	fffff097          	auipc	ra,0xfffff
    80001a58:	262080e7          	jalr	610(ra) # 80000cb6 <pop_off>
}
    80001a5c:	8526                	mv	a0,s1
    80001a5e:	60e2                	ld	ra,24(sp)
    80001a60:	6442                	ld	s0,16(sp)
    80001a62:	64a2                	ld	s1,8(sp)
    80001a64:	6105                	addi	sp,sp,32
    80001a66:	8082                	ret

0000000080001a68 <forkret>:
{
    80001a68:	1141                	addi	sp,sp,-16
    80001a6a:	e406                	sd	ra,8(sp)
    80001a6c:	e022                	sd	s0,0(sp)
    80001a6e:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001a70:	00000097          	auipc	ra,0x0
    80001a74:	fc0080e7          	jalr	-64(ra) # 80001a30 <myproc>
    80001a78:	fffff097          	auipc	ra,0xfffff
    80001a7c:	29e080e7          	jalr	670(ra) # 80000d16 <release>
  if (first) {
    80001a80:	00007797          	auipc	a5,0x7
    80001a84:	e607a783          	lw	a5,-416(a5) # 800088e0 <first.1667>
    80001a88:	eb89                	bnez	a5,80001a9a <forkret+0x32>
  usertrapret();
    80001a8a:	00001097          	auipc	ra,0x1
    80001a8e:	c5a080e7          	jalr	-934(ra) # 800026e4 <usertrapret>
}
    80001a92:	60a2                	ld	ra,8(sp)
    80001a94:	6402                	ld	s0,0(sp)
    80001a96:	0141                	addi	sp,sp,16
    80001a98:	8082                	ret
    first = 0;
    80001a9a:	00007797          	auipc	a5,0x7
    80001a9e:	e407a323          	sw	zero,-442(a5) # 800088e0 <first.1667>
    fsinit(ROOTDEV);
    80001aa2:	4505                	li	a0,1
    80001aa4:	00002097          	auipc	ra,0x2
    80001aa8:	a4a080e7          	jalr	-1462(ra) # 800034ee <fsinit>
    80001aac:	bff9                	j	80001a8a <forkret+0x22>

0000000080001aae <allocpid>:
allocpid() {
    80001aae:	1101                	addi	sp,sp,-32
    80001ab0:	ec06                	sd	ra,24(sp)
    80001ab2:	e822                	sd	s0,16(sp)
    80001ab4:	e426                	sd	s1,8(sp)
    80001ab6:	e04a                	sd	s2,0(sp)
    80001ab8:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001aba:	00010917          	auipc	s2,0x10
    80001abe:	e9690913          	addi	s2,s2,-362 # 80011950 <pid_lock>
    80001ac2:	854a                	mv	a0,s2
    80001ac4:	fffff097          	auipc	ra,0xfffff
    80001ac8:	19e080e7          	jalr	414(ra) # 80000c62 <acquire>
  pid = nextpid;
    80001acc:	00007797          	auipc	a5,0x7
    80001ad0:	e1878793          	addi	a5,a5,-488 # 800088e4 <nextpid>
    80001ad4:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001ad6:	0014871b          	addiw	a4,s1,1
    80001ada:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001adc:	854a                	mv	a0,s2
    80001ade:	fffff097          	auipc	ra,0xfffff
    80001ae2:	238080e7          	jalr	568(ra) # 80000d16 <release>
}
    80001ae6:	8526                	mv	a0,s1
    80001ae8:	60e2                	ld	ra,24(sp)
    80001aea:	6442                	ld	s0,16(sp)
    80001aec:	64a2                	ld	s1,8(sp)
    80001aee:	6902                	ld	s2,0(sp)
    80001af0:	6105                	addi	sp,sp,32
    80001af2:	8082                	ret

0000000080001af4 <proc_pagetable>:
{
    80001af4:	1101                	addi	sp,sp,-32
    80001af6:	ec06                	sd	ra,24(sp)
    80001af8:	e822                	sd	s0,16(sp)
    80001afa:	e426                	sd	s1,8(sp)
    80001afc:	e04a                	sd	s2,0(sp)
    80001afe:	1000                	addi	s0,sp,32
    80001b00:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b02:	00000097          	auipc	ra,0x0
    80001b06:	8ea080e7          	jalr	-1814(ra) # 800013ec <uvmcreate>
    80001b0a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b0c:	c121                	beqz	a0,80001b4c <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b0e:	4729                	li	a4,10
    80001b10:	00005697          	auipc	a3,0x5
    80001b14:	4f068693          	addi	a3,a3,1264 # 80007000 <_trampoline>
    80001b18:	6605                	lui	a2,0x1
    80001b1a:	040005b7          	lui	a1,0x4000
    80001b1e:	15fd                	addi	a1,a1,-1
    80001b20:	05b2                	slli	a1,a1,0xc
    80001b22:	fffff097          	auipc	ra,0xfffff
    80001b26:	66e080e7          	jalr	1646(ra) # 80001190 <mappages>
    80001b2a:	02054863          	bltz	a0,80001b5a <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b2e:	4719                	li	a4,6
    80001b30:	05893683          	ld	a3,88(s2)
    80001b34:	6605                	lui	a2,0x1
    80001b36:	020005b7          	lui	a1,0x2000
    80001b3a:	15fd                	addi	a1,a1,-1
    80001b3c:	05b6                	slli	a1,a1,0xd
    80001b3e:	8526                	mv	a0,s1
    80001b40:	fffff097          	auipc	ra,0xfffff
    80001b44:	650080e7          	jalr	1616(ra) # 80001190 <mappages>
    80001b48:	02054163          	bltz	a0,80001b6a <proc_pagetable+0x76>
}
    80001b4c:	8526                	mv	a0,s1
    80001b4e:	60e2                	ld	ra,24(sp)
    80001b50:	6442                	ld	s0,16(sp)
    80001b52:	64a2                	ld	s1,8(sp)
    80001b54:	6902                	ld	s2,0(sp)
    80001b56:	6105                	addi	sp,sp,32
    80001b58:	8082                	ret
    uvmfree(pagetable, 0);
    80001b5a:	4581                	li	a1,0
    80001b5c:	8526                	mv	a0,s1
    80001b5e:	00000097          	auipc	ra,0x0
    80001b62:	a8a080e7          	jalr	-1398(ra) # 800015e8 <uvmfree>
    return 0;
    80001b66:	4481                	li	s1,0
    80001b68:	b7d5                	j	80001b4c <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b6a:	4681                	li	a3,0
    80001b6c:	4605                	li	a2,1
    80001b6e:	040005b7          	lui	a1,0x4000
    80001b72:	15fd                	addi	a1,a1,-1
    80001b74:	05b2                	slli	a1,a1,0xc
    80001b76:	8526                	mv	a0,s1
    80001b78:	fffff097          	auipc	ra,0xfffff
    80001b7c:	7b0080e7          	jalr	1968(ra) # 80001328 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b80:	4581                	li	a1,0
    80001b82:	8526                	mv	a0,s1
    80001b84:	00000097          	auipc	ra,0x0
    80001b88:	a64080e7          	jalr	-1436(ra) # 800015e8 <uvmfree>
    return 0;
    80001b8c:	4481                	li	s1,0
    80001b8e:	bf7d                	j	80001b4c <proc_pagetable+0x58>

0000000080001b90 <proc_freepagetable>:
{
    80001b90:	1101                	addi	sp,sp,-32
    80001b92:	ec06                	sd	ra,24(sp)
    80001b94:	e822                	sd	s0,16(sp)
    80001b96:	e426                	sd	s1,8(sp)
    80001b98:	e04a                	sd	s2,0(sp)
    80001b9a:	1000                	addi	s0,sp,32
    80001b9c:	84aa                	mv	s1,a0
    80001b9e:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ba0:	4681                	li	a3,0
    80001ba2:	4605                	li	a2,1
    80001ba4:	040005b7          	lui	a1,0x4000
    80001ba8:	15fd                	addi	a1,a1,-1
    80001baa:	05b2                	slli	a1,a1,0xc
    80001bac:	fffff097          	auipc	ra,0xfffff
    80001bb0:	77c080e7          	jalr	1916(ra) # 80001328 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001bb4:	4681                	li	a3,0
    80001bb6:	4605                	li	a2,1
    80001bb8:	020005b7          	lui	a1,0x2000
    80001bbc:	15fd                	addi	a1,a1,-1
    80001bbe:	05b6                	slli	a1,a1,0xd
    80001bc0:	8526                	mv	a0,s1
    80001bc2:	fffff097          	auipc	ra,0xfffff
    80001bc6:	766080e7          	jalr	1894(ra) # 80001328 <uvmunmap>
  uvmfree(pagetable, sz);
    80001bca:	85ca                	mv	a1,s2
    80001bcc:	8526                	mv	a0,s1
    80001bce:	00000097          	auipc	ra,0x0
    80001bd2:	a1a080e7          	jalr	-1510(ra) # 800015e8 <uvmfree>
}
    80001bd6:	60e2                	ld	ra,24(sp)
    80001bd8:	6442                	ld	s0,16(sp)
    80001bda:	64a2                	ld	s1,8(sp)
    80001bdc:	6902                	ld	s2,0(sp)
    80001bde:	6105                	addi	sp,sp,32
    80001be0:	8082                	ret

0000000080001be2 <freeproc>:
{
    80001be2:	1101                	addi	sp,sp,-32
    80001be4:	ec06                	sd	ra,24(sp)
    80001be6:	e822                	sd	s0,16(sp)
    80001be8:	e426                	sd	s1,8(sp)
    80001bea:	1000                	addi	s0,sp,32
    80001bec:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001bee:	6d28                	ld	a0,88(a0)
    80001bf0:	c509                	beqz	a0,80001bfa <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001bf2:	fffff097          	auipc	ra,0xfffff
    80001bf6:	e32080e7          	jalr	-462(ra) # 80000a24 <kfree>
  p->trapframe = 0;
    80001bfa:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001bfe:	68a8                	ld	a0,80(s1)
    80001c00:	c511                	beqz	a0,80001c0c <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001c02:	64ac                	ld	a1,72(s1)
    80001c04:	00000097          	auipc	ra,0x0
    80001c08:	f8c080e7          	jalr	-116(ra) # 80001b90 <proc_freepagetable>
  p->pagetable = 0;
    80001c0c:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c10:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c14:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001c18:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001c1c:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c20:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001c24:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001c28:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001c2c:	0004ac23          	sw	zero,24(s1)
}
    80001c30:	60e2                	ld	ra,24(sp)
    80001c32:	6442                	ld	s0,16(sp)
    80001c34:	64a2                	ld	s1,8(sp)
    80001c36:	6105                	addi	sp,sp,32
    80001c38:	8082                	ret

0000000080001c3a <allocproc>:
{
    80001c3a:	1101                	addi	sp,sp,-32
    80001c3c:	ec06                	sd	ra,24(sp)
    80001c3e:	e822                	sd	s0,16(sp)
    80001c40:	e426                	sd	s1,8(sp)
    80001c42:	e04a                	sd	s2,0(sp)
    80001c44:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c46:	00010497          	auipc	s1,0x10
    80001c4a:	12248493          	addi	s1,s1,290 # 80011d68 <proc>
    80001c4e:	00016917          	auipc	s2,0x16
    80001c52:	d1a90913          	addi	s2,s2,-742 # 80017968 <tickslock>
    acquire(&p->lock);
    80001c56:	8526                	mv	a0,s1
    80001c58:	fffff097          	auipc	ra,0xfffff
    80001c5c:	00a080e7          	jalr	10(ra) # 80000c62 <acquire>
    if(p->state == UNUSED) {
    80001c60:	4c9c                	lw	a5,24(s1)
    80001c62:	cf81                	beqz	a5,80001c7a <allocproc+0x40>
      release(&p->lock);
    80001c64:	8526                	mv	a0,s1
    80001c66:	fffff097          	auipc	ra,0xfffff
    80001c6a:	0b0080e7          	jalr	176(ra) # 80000d16 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c6e:	17048493          	addi	s1,s1,368
    80001c72:	ff2492e3          	bne	s1,s2,80001c56 <allocproc+0x1c>
  return 0;
    80001c76:	4481                	li	s1,0
    80001c78:	a889                	j	80001cca <allocproc+0x90>
  p->pid = allocpid();
    80001c7a:	00000097          	auipc	ra,0x0
    80001c7e:	e34080e7          	jalr	-460(ra) # 80001aae <allocpid>
    80001c82:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c84:	fffff097          	auipc	ra,0xfffff
    80001c88:	e9c080e7          	jalr	-356(ra) # 80000b20 <kalloc>
    80001c8c:	892a                	mv	s2,a0
    80001c8e:	eca8                	sd	a0,88(s1)
    80001c90:	c521                	beqz	a0,80001cd8 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001c92:	8526                	mv	a0,s1
    80001c94:	00000097          	auipc	ra,0x0
    80001c98:	e60080e7          	jalr	-416(ra) # 80001af4 <proc_pagetable>
    80001c9c:	892a                	mv	s2,a0
    80001c9e:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001ca0:	c139                	beqz	a0,80001ce6 <allocproc+0xac>
  memset(&p->context, 0, sizeof(p->context));
    80001ca2:	07000613          	li	a2,112
    80001ca6:	4581                	li	a1,0
    80001ca8:	06048513          	addi	a0,s1,96
    80001cac:	fffff097          	auipc	ra,0xfffff
    80001cb0:	0b2080e7          	jalr	178(ra) # 80000d5e <memset>
  p->context.ra = (uint64)forkret;
    80001cb4:	00000797          	auipc	a5,0x0
    80001cb8:	db478793          	addi	a5,a5,-588 # 80001a68 <forkret>
    80001cbc:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001cbe:	60bc                	ld	a5,64(s1)
    80001cc0:	6705                	lui	a4,0x1
    80001cc2:	97ba                	add	a5,a5,a4
    80001cc4:	f4bc                	sd	a5,104(s1)
  p->kama_syscall_trace = 0;         //创建新进程的时候，kama_syscall_trace 设置为默认值0
    80001cc6:	1604b423          	sd	zero,360(s1)
}
    80001cca:	8526                	mv	a0,s1
    80001ccc:	60e2                	ld	ra,24(sp)
    80001cce:	6442                	ld	s0,16(sp)
    80001cd0:	64a2                	ld	s1,8(sp)
    80001cd2:	6902                	ld	s2,0(sp)
    80001cd4:	6105                	addi	sp,sp,32
    80001cd6:	8082                	ret
    release(&p->lock);
    80001cd8:	8526                	mv	a0,s1
    80001cda:	fffff097          	auipc	ra,0xfffff
    80001cde:	03c080e7          	jalr	60(ra) # 80000d16 <release>
    return 0;
    80001ce2:	84ca                	mv	s1,s2
    80001ce4:	b7dd                	j	80001cca <allocproc+0x90>
    freeproc(p);
    80001ce6:	8526                	mv	a0,s1
    80001ce8:	00000097          	auipc	ra,0x0
    80001cec:	efa080e7          	jalr	-262(ra) # 80001be2 <freeproc>
    release(&p->lock);
    80001cf0:	8526                	mv	a0,s1
    80001cf2:	fffff097          	auipc	ra,0xfffff
    80001cf6:	024080e7          	jalr	36(ra) # 80000d16 <release>
    return 0;
    80001cfa:	84ca                	mv	s1,s2
    80001cfc:	b7f9                	j	80001cca <allocproc+0x90>

0000000080001cfe <userinit>:
{
    80001cfe:	1101                	addi	sp,sp,-32
    80001d00:	ec06                	sd	ra,24(sp)
    80001d02:	e822                	sd	s0,16(sp)
    80001d04:	e426                	sd	s1,8(sp)
    80001d06:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d08:	00000097          	auipc	ra,0x0
    80001d0c:	f32080e7          	jalr	-206(ra) # 80001c3a <allocproc>
    80001d10:	84aa                	mv	s1,a0
  initproc = p;
    80001d12:	00007797          	auipc	a5,0x7
    80001d16:	30a7b323          	sd	a0,774(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d1a:	03400613          	li	a2,52
    80001d1e:	00007597          	auipc	a1,0x7
    80001d22:	bd258593          	addi	a1,a1,-1070 # 800088f0 <initcode>
    80001d26:	6928                	ld	a0,80(a0)
    80001d28:	fffff097          	auipc	ra,0xfffff
    80001d2c:	6f2080e7          	jalr	1778(ra) # 8000141a <uvminit>
  p->sz = PGSIZE;
    80001d30:	6785                	lui	a5,0x1
    80001d32:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d34:	6cb8                	ld	a4,88(s1)
    80001d36:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d3a:	6cb8                	ld	a4,88(s1)
    80001d3c:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d3e:	4641                	li	a2,16
    80001d40:	00006597          	auipc	a1,0x6
    80001d44:	4a858593          	addi	a1,a1,1192 # 800081e8 <digits+0x1a8>
    80001d48:	15848513          	addi	a0,s1,344
    80001d4c:	fffff097          	auipc	ra,0xfffff
    80001d50:	168080e7          	jalr	360(ra) # 80000eb4 <safestrcpy>
  p->cwd = namei("/");
    80001d54:	00006517          	auipc	a0,0x6
    80001d58:	4a450513          	addi	a0,a0,1188 # 800081f8 <digits+0x1b8>
    80001d5c:	00002097          	auipc	ra,0x2
    80001d60:	1ba080e7          	jalr	442(ra) # 80003f16 <namei>
    80001d64:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d68:	4789                	li	a5,2
    80001d6a:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d6c:	8526                	mv	a0,s1
    80001d6e:	fffff097          	auipc	ra,0xfffff
    80001d72:	fa8080e7          	jalr	-88(ra) # 80000d16 <release>
}
    80001d76:	60e2                	ld	ra,24(sp)
    80001d78:	6442                	ld	s0,16(sp)
    80001d7a:	64a2                	ld	s1,8(sp)
    80001d7c:	6105                	addi	sp,sp,32
    80001d7e:	8082                	ret

0000000080001d80 <growproc>:
{
    80001d80:	1101                	addi	sp,sp,-32
    80001d82:	ec06                	sd	ra,24(sp)
    80001d84:	e822                	sd	s0,16(sp)
    80001d86:	e426                	sd	s1,8(sp)
    80001d88:	e04a                	sd	s2,0(sp)
    80001d8a:	1000                	addi	s0,sp,32
    80001d8c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d8e:	00000097          	auipc	ra,0x0
    80001d92:	ca2080e7          	jalr	-862(ra) # 80001a30 <myproc>
    80001d96:	892a                	mv	s2,a0
  sz = p->sz;
    80001d98:	652c                	ld	a1,72(a0)
    80001d9a:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001d9e:	00904f63          	bgtz	s1,80001dbc <growproc+0x3c>
  } else if(n < 0){
    80001da2:	0204cc63          	bltz	s1,80001dda <growproc+0x5a>
  p->sz = sz;
    80001da6:	1602                	slli	a2,a2,0x20
    80001da8:	9201                	srli	a2,a2,0x20
    80001daa:	04c93423          	sd	a2,72(s2)
  return 0;
    80001dae:	4501                	li	a0,0
}
    80001db0:	60e2                	ld	ra,24(sp)
    80001db2:	6442                	ld	s0,16(sp)
    80001db4:	64a2                	ld	s1,8(sp)
    80001db6:	6902                	ld	s2,0(sp)
    80001db8:	6105                	addi	sp,sp,32
    80001dba:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001dbc:	9e25                	addw	a2,a2,s1
    80001dbe:	1602                	slli	a2,a2,0x20
    80001dc0:	9201                	srli	a2,a2,0x20
    80001dc2:	1582                	slli	a1,a1,0x20
    80001dc4:	9181                	srli	a1,a1,0x20
    80001dc6:	6928                	ld	a0,80(a0)
    80001dc8:	fffff097          	auipc	ra,0xfffff
    80001dcc:	70c080e7          	jalr	1804(ra) # 800014d4 <uvmalloc>
    80001dd0:	0005061b          	sext.w	a2,a0
    80001dd4:	fa69                	bnez	a2,80001da6 <growproc+0x26>
      return -1;
    80001dd6:	557d                	li	a0,-1
    80001dd8:	bfe1                	j	80001db0 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001dda:	9e25                	addw	a2,a2,s1
    80001ddc:	1602                	slli	a2,a2,0x20
    80001dde:	9201                	srli	a2,a2,0x20
    80001de0:	1582                	slli	a1,a1,0x20
    80001de2:	9181                	srli	a1,a1,0x20
    80001de4:	6928                	ld	a0,80(a0)
    80001de6:	fffff097          	auipc	ra,0xfffff
    80001dea:	6a6080e7          	jalr	1702(ra) # 8000148c <uvmdealloc>
    80001dee:	0005061b          	sext.w	a2,a0
    80001df2:	bf55                	j	80001da6 <growproc+0x26>

0000000080001df4 <fork>:
{
    80001df4:	7179                	addi	sp,sp,-48
    80001df6:	f406                	sd	ra,40(sp)
    80001df8:	f022                	sd	s0,32(sp)
    80001dfa:	ec26                	sd	s1,24(sp)
    80001dfc:	e84a                	sd	s2,16(sp)
    80001dfe:	e44e                	sd	s3,8(sp)
    80001e00:	e052                	sd	s4,0(sp)
    80001e02:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e04:	00000097          	auipc	ra,0x0
    80001e08:	c2c080e7          	jalr	-980(ra) # 80001a30 <myproc>
    80001e0c:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001e0e:	00000097          	auipc	ra,0x0
    80001e12:	e2c080e7          	jalr	-468(ra) # 80001c3a <allocproc>
    80001e16:	c575                	beqz	a0,80001f02 <fork+0x10e>
    80001e18:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e1a:	04893603          	ld	a2,72(s2)
    80001e1e:	692c                	ld	a1,80(a0)
    80001e20:	05093503          	ld	a0,80(s2)
    80001e24:	fffff097          	auipc	ra,0xfffff
    80001e28:	7fc080e7          	jalr	2044(ra) # 80001620 <uvmcopy>
    80001e2c:	04054863          	bltz	a0,80001e7c <fork+0x88>
  np->sz = p->sz;
    80001e30:	04893783          	ld	a5,72(s2)
    80001e34:	04f9b423          	sd	a5,72(s3) # 4000048 <_entry-0x7bffffb8>
  np->parent = p;
    80001e38:	0329b023          	sd	s2,32(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e3c:	05893683          	ld	a3,88(s2)
    80001e40:	87b6                	mv	a5,a3
    80001e42:	0589b703          	ld	a4,88(s3)
    80001e46:	12068693          	addi	a3,a3,288
    80001e4a:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e4e:	6788                	ld	a0,8(a5)
    80001e50:	6b8c                	ld	a1,16(a5)
    80001e52:	6f90                	ld	a2,24(a5)
    80001e54:	01073023          	sd	a6,0(a4)
    80001e58:	e708                	sd	a0,8(a4)
    80001e5a:	eb0c                	sd	a1,16(a4)
    80001e5c:	ef10                	sd	a2,24(a4)
    80001e5e:	02078793          	addi	a5,a5,32
    80001e62:	02070713          	addi	a4,a4,32
    80001e66:	fed792e3          	bne	a5,a3,80001e4a <fork+0x56>
  np->trapframe->a0 = 0;
    80001e6a:	0589b783          	ld	a5,88(s3)
    80001e6e:	0607b823          	sd	zero,112(a5)
    80001e72:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001e76:	15000a13          	li	s4,336
    80001e7a:	a03d                	j	80001ea8 <fork+0xb4>
    freeproc(np);
    80001e7c:	854e                	mv	a0,s3
    80001e7e:	00000097          	auipc	ra,0x0
    80001e82:	d64080e7          	jalr	-668(ra) # 80001be2 <freeproc>
    release(&np->lock);
    80001e86:	854e                	mv	a0,s3
    80001e88:	fffff097          	auipc	ra,0xfffff
    80001e8c:	e8e080e7          	jalr	-370(ra) # 80000d16 <release>
    return -1;
    80001e90:	54fd                	li	s1,-1
    80001e92:	a8b9                	j	80001ef0 <fork+0xfc>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e94:	00002097          	auipc	ra,0x2
    80001e98:	70e080e7          	jalr	1806(ra) # 800045a2 <filedup>
    80001e9c:	009987b3          	add	a5,s3,s1
    80001ea0:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001ea2:	04a1                	addi	s1,s1,8
    80001ea4:	01448763          	beq	s1,s4,80001eb2 <fork+0xbe>
    if(p->ofile[i])
    80001ea8:	009907b3          	add	a5,s2,s1
    80001eac:	6388                	ld	a0,0(a5)
    80001eae:	f17d                	bnez	a0,80001e94 <fork+0xa0>
    80001eb0:	bfcd                	j	80001ea2 <fork+0xae>
  np->cwd = idup(p->cwd);
    80001eb2:	15093503          	ld	a0,336(s2)
    80001eb6:	00002097          	auipc	ra,0x2
    80001eba:	872080e7          	jalr	-1934(ra) # 80003728 <idup>
    80001ebe:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ec2:	4641                	li	a2,16
    80001ec4:	15890593          	addi	a1,s2,344
    80001ec8:	15898513          	addi	a0,s3,344
    80001ecc:	fffff097          	auipc	ra,0xfffff
    80001ed0:	fe8080e7          	jalr	-24(ra) # 80000eb4 <safestrcpy>
  pid = np->pid;
    80001ed4:	0389a483          	lw	s1,56(s3)
  np->state = RUNNABLE;
    80001ed8:	4789                	li	a5,2
    80001eda:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001ede:	854e                	mv	a0,s3
    80001ee0:	fffff097          	auipc	ra,0xfffff
    80001ee4:	e36080e7          	jalr	-458(ra) # 80000d16 <release>
  np->kama_syscall_trace = p->kama_syscall_trace;      //子进程继承父进程的syscall_trace
    80001ee8:	16893783          	ld	a5,360(s2)
    80001eec:	16f9b423          	sd	a5,360(s3)
}
    80001ef0:	8526                	mv	a0,s1
    80001ef2:	70a2                	ld	ra,40(sp)
    80001ef4:	7402                	ld	s0,32(sp)
    80001ef6:	64e2                	ld	s1,24(sp)
    80001ef8:	6942                	ld	s2,16(sp)
    80001efa:	69a2                	ld	s3,8(sp)
    80001efc:	6a02                	ld	s4,0(sp)
    80001efe:	6145                	addi	sp,sp,48
    80001f00:	8082                	ret
    return -1;
    80001f02:	54fd                	li	s1,-1
    80001f04:	b7f5                	j	80001ef0 <fork+0xfc>

0000000080001f06 <reparent>:
{
    80001f06:	7179                	addi	sp,sp,-48
    80001f08:	f406                	sd	ra,40(sp)
    80001f0a:	f022                	sd	s0,32(sp)
    80001f0c:	ec26                	sd	s1,24(sp)
    80001f0e:	e84a                	sd	s2,16(sp)
    80001f10:	e44e                	sd	s3,8(sp)
    80001f12:	e052                	sd	s4,0(sp)
    80001f14:	1800                	addi	s0,sp,48
    80001f16:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f18:	00010497          	auipc	s1,0x10
    80001f1c:	e5048493          	addi	s1,s1,-432 # 80011d68 <proc>
      pp->parent = initproc;
    80001f20:	00007a17          	auipc	s4,0x7
    80001f24:	0f8a0a13          	addi	s4,s4,248 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f28:	00016997          	auipc	s3,0x16
    80001f2c:	a4098993          	addi	s3,s3,-1472 # 80017968 <tickslock>
    80001f30:	a029                	j	80001f3a <reparent+0x34>
    80001f32:	17048493          	addi	s1,s1,368
    80001f36:	03348363          	beq	s1,s3,80001f5c <reparent+0x56>
    if(pp->parent == p){
    80001f3a:	709c                	ld	a5,32(s1)
    80001f3c:	ff279be3          	bne	a5,s2,80001f32 <reparent+0x2c>
      acquire(&pp->lock);
    80001f40:	8526                	mv	a0,s1
    80001f42:	fffff097          	auipc	ra,0xfffff
    80001f46:	d20080e7          	jalr	-736(ra) # 80000c62 <acquire>
      pp->parent = initproc;
    80001f4a:	000a3783          	ld	a5,0(s4)
    80001f4e:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    80001f50:	8526                	mv	a0,s1
    80001f52:	fffff097          	auipc	ra,0xfffff
    80001f56:	dc4080e7          	jalr	-572(ra) # 80000d16 <release>
    80001f5a:	bfe1                	j	80001f32 <reparent+0x2c>
}
    80001f5c:	70a2                	ld	ra,40(sp)
    80001f5e:	7402                	ld	s0,32(sp)
    80001f60:	64e2                	ld	s1,24(sp)
    80001f62:	6942                	ld	s2,16(sp)
    80001f64:	69a2                	ld	s3,8(sp)
    80001f66:	6a02                	ld	s4,0(sp)
    80001f68:	6145                	addi	sp,sp,48
    80001f6a:	8082                	ret

0000000080001f6c <scheduler>:
{
    80001f6c:	715d                	addi	sp,sp,-80
    80001f6e:	e486                	sd	ra,72(sp)
    80001f70:	e0a2                	sd	s0,64(sp)
    80001f72:	fc26                	sd	s1,56(sp)
    80001f74:	f84a                	sd	s2,48(sp)
    80001f76:	f44e                	sd	s3,40(sp)
    80001f78:	f052                	sd	s4,32(sp)
    80001f7a:	ec56                	sd	s5,24(sp)
    80001f7c:	e85a                	sd	s6,16(sp)
    80001f7e:	e45e                	sd	s7,8(sp)
    80001f80:	e062                	sd	s8,0(sp)
    80001f82:	0880                	addi	s0,sp,80
    80001f84:	8792                	mv	a5,tp
  int id = r_tp();
    80001f86:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f88:	00779b13          	slli	s6,a5,0x7
    80001f8c:	00010717          	auipc	a4,0x10
    80001f90:	9c470713          	addi	a4,a4,-1596 # 80011950 <pid_lock>
    80001f94:	975a                	add	a4,a4,s6
    80001f96:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80001f9a:	00010717          	auipc	a4,0x10
    80001f9e:	9d670713          	addi	a4,a4,-1578 # 80011970 <cpus+0x8>
    80001fa2:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001fa4:	4c0d                	li	s8,3
        c->proc = p;
    80001fa6:	079e                	slli	a5,a5,0x7
    80001fa8:	00010a17          	auipc	s4,0x10
    80001fac:	9a8a0a13          	addi	s4,s4,-1624 # 80011950 <pid_lock>
    80001fb0:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fb2:	00016997          	auipc	s3,0x16
    80001fb6:	9b698993          	addi	s3,s3,-1610 # 80017968 <tickslock>
        found = 1;
    80001fba:	4b85                	li	s7,1
    80001fbc:	a899                	j	80002012 <scheduler+0xa6>
        p->state = RUNNING;
    80001fbe:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001fc2:	009a3c23          	sd	s1,24(s4)
        swtch(&c->context, &p->context);
    80001fc6:	06048593          	addi	a1,s1,96
    80001fca:	855a                	mv	a0,s6
    80001fcc:	00000097          	auipc	ra,0x0
    80001fd0:	66e080e7          	jalr	1646(ra) # 8000263a <swtch>
        c->proc = 0;
    80001fd4:	000a3c23          	sd	zero,24(s4)
        found = 1;
    80001fd8:	8ade                	mv	s5,s7
      release(&p->lock);
    80001fda:	8526                	mv	a0,s1
    80001fdc:	fffff097          	auipc	ra,0xfffff
    80001fe0:	d3a080e7          	jalr	-710(ra) # 80000d16 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fe4:	17048493          	addi	s1,s1,368
    80001fe8:	01348b63          	beq	s1,s3,80001ffe <scheduler+0x92>
      acquire(&p->lock);
    80001fec:	8526                	mv	a0,s1
    80001fee:	fffff097          	auipc	ra,0xfffff
    80001ff2:	c74080e7          	jalr	-908(ra) # 80000c62 <acquire>
      if(p->state == RUNNABLE) {
    80001ff6:	4c9c                	lw	a5,24(s1)
    80001ff8:	ff2791e3          	bne	a5,s2,80001fda <scheduler+0x6e>
    80001ffc:	b7c9                	j	80001fbe <scheduler+0x52>
    if(found == 0) {
    80001ffe:	000a9a63          	bnez	s5,80002012 <scheduler+0xa6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002002:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002006:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000200a:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    8000200e:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002012:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002016:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000201a:	10079073          	csrw	sstatus,a5
    int found = 0;
    8000201e:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80002020:	00010497          	auipc	s1,0x10
    80002024:	d4848493          	addi	s1,s1,-696 # 80011d68 <proc>
      if(p->state == RUNNABLE) {
    80002028:	4909                	li	s2,2
    8000202a:	b7c9                	j	80001fec <scheduler+0x80>

000000008000202c <sched>:
{
    8000202c:	7179                	addi	sp,sp,-48
    8000202e:	f406                	sd	ra,40(sp)
    80002030:	f022                	sd	s0,32(sp)
    80002032:	ec26                	sd	s1,24(sp)
    80002034:	e84a                	sd	s2,16(sp)
    80002036:	e44e                	sd	s3,8(sp)
    80002038:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000203a:	00000097          	auipc	ra,0x0
    8000203e:	9f6080e7          	jalr	-1546(ra) # 80001a30 <myproc>
    80002042:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002044:	fffff097          	auipc	ra,0xfffff
    80002048:	ba4080e7          	jalr	-1116(ra) # 80000be8 <holding>
    8000204c:	c93d                	beqz	a0,800020c2 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000204e:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002050:	2781                	sext.w	a5,a5
    80002052:	079e                	slli	a5,a5,0x7
    80002054:	00010717          	auipc	a4,0x10
    80002058:	8fc70713          	addi	a4,a4,-1796 # 80011950 <pid_lock>
    8000205c:	97ba                	add	a5,a5,a4
    8000205e:	0907a703          	lw	a4,144(a5)
    80002062:	4785                	li	a5,1
    80002064:	06f71763          	bne	a4,a5,800020d2 <sched+0xa6>
  if(p->state == RUNNING)
    80002068:	4c98                	lw	a4,24(s1)
    8000206a:	478d                	li	a5,3
    8000206c:	06f70b63          	beq	a4,a5,800020e2 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002070:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002074:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002076:	efb5                	bnez	a5,800020f2 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002078:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000207a:	00010917          	auipc	s2,0x10
    8000207e:	8d690913          	addi	s2,s2,-1834 # 80011950 <pid_lock>
    80002082:	2781                	sext.w	a5,a5
    80002084:	079e                	slli	a5,a5,0x7
    80002086:	97ca                	add	a5,a5,s2
    80002088:	0947a983          	lw	s3,148(a5)
    8000208c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000208e:	2781                	sext.w	a5,a5
    80002090:	079e                	slli	a5,a5,0x7
    80002092:	00010597          	auipc	a1,0x10
    80002096:	8de58593          	addi	a1,a1,-1826 # 80011970 <cpus+0x8>
    8000209a:	95be                	add	a1,a1,a5
    8000209c:	06048513          	addi	a0,s1,96
    800020a0:	00000097          	auipc	ra,0x0
    800020a4:	59a080e7          	jalr	1434(ra) # 8000263a <swtch>
    800020a8:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020aa:	2781                	sext.w	a5,a5
    800020ac:	079e                	slli	a5,a5,0x7
    800020ae:	97ca                	add	a5,a5,s2
    800020b0:	0937aa23          	sw	s3,148(a5)
}
    800020b4:	70a2                	ld	ra,40(sp)
    800020b6:	7402                	ld	s0,32(sp)
    800020b8:	64e2                	ld	s1,24(sp)
    800020ba:	6942                	ld	s2,16(sp)
    800020bc:	69a2                	ld	s3,8(sp)
    800020be:	6145                	addi	sp,sp,48
    800020c0:	8082                	ret
    panic("sched p->lock");
    800020c2:	00006517          	auipc	a0,0x6
    800020c6:	13e50513          	addi	a0,a0,318 # 80008200 <digits+0x1c0>
    800020ca:	ffffe097          	auipc	ra,0xffffe
    800020ce:	47e080e7          	jalr	1150(ra) # 80000548 <panic>
    panic("sched locks");
    800020d2:	00006517          	auipc	a0,0x6
    800020d6:	13e50513          	addi	a0,a0,318 # 80008210 <digits+0x1d0>
    800020da:	ffffe097          	auipc	ra,0xffffe
    800020de:	46e080e7          	jalr	1134(ra) # 80000548 <panic>
    panic("sched running");
    800020e2:	00006517          	auipc	a0,0x6
    800020e6:	13e50513          	addi	a0,a0,318 # 80008220 <digits+0x1e0>
    800020ea:	ffffe097          	auipc	ra,0xffffe
    800020ee:	45e080e7          	jalr	1118(ra) # 80000548 <panic>
    panic("sched interruptible");
    800020f2:	00006517          	auipc	a0,0x6
    800020f6:	13e50513          	addi	a0,a0,318 # 80008230 <digits+0x1f0>
    800020fa:	ffffe097          	auipc	ra,0xffffe
    800020fe:	44e080e7          	jalr	1102(ra) # 80000548 <panic>

0000000080002102 <exit>:
{
    80002102:	7179                	addi	sp,sp,-48
    80002104:	f406                	sd	ra,40(sp)
    80002106:	f022                	sd	s0,32(sp)
    80002108:	ec26                	sd	s1,24(sp)
    8000210a:	e84a                	sd	s2,16(sp)
    8000210c:	e44e                	sd	s3,8(sp)
    8000210e:	e052                	sd	s4,0(sp)
    80002110:	1800                	addi	s0,sp,48
    80002112:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002114:	00000097          	auipc	ra,0x0
    80002118:	91c080e7          	jalr	-1764(ra) # 80001a30 <myproc>
    8000211c:	89aa                	mv	s3,a0
  if(p == initproc)
    8000211e:	00007797          	auipc	a5,0x7
    80002122:	efa7b783          	ld	a5,-262(a5) # 80009018 <initproc>
    80002126:	0d050493          	addi	s1,a0,208
    8000212a:	15050913          	addi	s2,a0,336
    8000212e:	02a79363          	bne	a5,a0,80002154 <exit+0x52>
    panic("init exiting");
    80002132:	00006517          	auipc	a0,0x6
    80002136:	11650513          	addi	a0,a0,278 # 80008248 <digits+0x208>
    8000213a:	ffffe097          	auipc	ra,0xffffe
    8000213e:	40e080e7          	jalr	1038(ra) # 80000548 <panic>
      fileclose(f);
    80002142:	00002097          	auipc	ra,0x2
    80002146:	4b2080e7          	jalr	1202(ra) # 800045f4 <fileclose>
      p->ofile[fd] = 0;
    8000214a:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000214e:	04a1                	addi	s1,s1,8
    80002150:	01248563          	beq	s1,s2,8000215a <exit+0x58>
    if(p->ofile[fd]){
    80002154:	6088                	ld	a0,0(s1)
    80002156:	f575                	bnez	a0,80002142 <exit+0x40>
    80002158:	bfdd                	j	8000214e <exit+0x4c>
  begin_op();
    8000215a:	00002097          	auipc	ra,0x2
    8000215e:	fc8080e7          	jalr	-56(ra) # 80004122 <begin_op>
  iput(p->cwd);
    80002162:	1509b503          	ld	a0,336(s3)
    80002166:	00001097          	auipc	ra,0x1
    8000216a:	7ba080e7          	jalr	1978(ra) # 80003920 <iput>
  end_op();
    8000216e:	00002097          	auipc	ra,0x2
    80002172:	034080e7          	jalr	52(ra) # 800041a2 <end_op>
  p->cwd = 0;
    80002176:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    8000217a:	00007497          	auipc	s1,0x7
    8000217e:	e9e48493          	addi	s1,s1,-354 # 80009018 <initproc>
    80002182:	6088                	ld	a0,0(s1)
    80002184:	fffff097          	auipc	ra,0xfffff
    80002188:	ade080e7          	jalr	-1314(ra) # 80000c62 <acquire>
  wakeup1(initproc);
    8000218c:	6088                	ld	a0,0(s1)
    8000218e:	fffff097          	auipc	ra,0xfffff
    80002192:	762080e7          	jalr	1890(ra) # 800018f0 <wakeup1>
  release(&initproc->lock);
    80002196:	6088                	ld	a0,0(s1)
    80002198:	fffff097          	auipc	ra,0xfffff
    8000219c:	b7e080e7          	jalr	-1154(ra) # 80000d16 <release>
  acquire(&p->lock);
    800021a0:	854e                	mv	a0,s3
    800021a2:	fffff097          	auipc	ra,0xfffff
    800021a6:	ac0080e7          	jalr	-1344(ra) # 80000c62 <acquire>
  struct proc *original_parent = p->parent;
    800021aa:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    800021ae:	854e                	mv	a0,s3
    800021b0:	fffff097          	auipc	ra,0xfffff
    800021b4:	b66080e7          	jalr	-1178(ra) # 80000d16 <release>
  acquire(&original_parent->lock);
    800021b8:	8526                	mv	a0,s1
    800021ba:	fffff097          	auipc	ra,0xfffff
    800021be:	aa8080e7          	jalr	-1368(ra) # 80000c62 <acquire>
  acquire(&p->lock);
    800021c2:	854e                	mv	a0,s3
    800021c4:	fffff097          	auipc	ra,0xfffff
    800021c8:	a9e080e7          	jalr	-1378(ra) # 80000c62 <acquire>
  reparent(p);
    800021cc:	854e                	mv	a0,s3
    800021ce:	00000097          	auipc	ra,0x0
    800021d2:	d38080e7          	jalr	-712(ra) # 80001f06 <reparent>
  wakeup1(original_parent);
    800021d6:	8526                	mv	a0,s1
    800021d8:	fffff097          	auipc	ra,0xfffff
    800021dc:	718080e7          	jalr	1816(ra) # 800018f0 <wakeup1>
  p->xstate = status;
    800021e0:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    800021e4:	4791                	li	a5,4
    800021e6:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    800021ea:	8526                	mv	a0,s1
    800021ec:	fffff097          	auipc	ra,0xfffff
    800021f0:	b2a080e7          	jalr	-1238(ra) # 80000d16 <release>
  sched();
    800021f4:	00000097          	auipc	ra,0x0
    800021f8:	e38080e7          	jalr	-456(ra) # 8000202c <sched>
  panic("zombie exit");
    800021fc:	00006517          	auipc	a0,0x6
    80002200:	05c50513          	addi	a0,a0,92 # 80008258 <digits+0x218>
    80002204:	ffffe097          	auipc	ra,0xffffe
    80002208:	344080e7          	jalr	836(ra) # 80000548 <panic>

000000008000220c <yield>:
{
    8000220c:	1101                	addi	sp,sp,-32
    8000220e:	ec06                	sd	ra,24(sp)
    80002210:	e822                	sd	s0,16(sp)
    80002212:	e426                	sd	s1,8(sp)
    80002214:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002216:	00000097          	auipc	ra,0x0
    8000221a:	81a080e7          	jalr	-2022(ra) # 80001a30 <myproc>
    8000221e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002220:	fffff097          	auipc	ra,0xfffff
    80002224:	a42080e7          	jalr	-1470(ra) # 80000c62 <acquire>
  p->state = RUNNABLE;
    80002228:	4789                	li	a5,2
    8000222a:	cc9c                	sw	a5,24(s1)
  sched();
    8000222c:	00000097          	auipc	ra,0x0
    80002230:	e00080e7          	jalr	-512(ra) # 8000202c <sched>
  release(&p->lock);
    80002234:	8526                	mv	a0,s1
    80002236:	fffff097          	auipc	ra,0xfffff
    8000223a:	ae0080e7          	jalr	-1312(ra) # 80000d16 <release>
}
    8000223e:	60e2                	ld	ra,24(sp)
    80002240:	6442                	ld	s0,16(sp)
    80002242:	64a2                	ld	s1,8(sp)
    80002244:	6105                	addi	sp,sp,32
    80002246:	8082                	ret

0000000080002248 <sleep>:
{
    80002248:	7179                	addi	sp,sp,-48
    8000224a:	f406                	sd	ra,40(sp)
    8000224c:	f022                	sd	s0,32(sp)
    8000224e:	ec26                	sd	s1,24(sp)
    80002250:	e84a                	sd	s2,16(sp)
    80002252:	e44e                	sd	s3,8(sp)
    80002254:	1800                	addi	s0,sp,48
    80002256:	89aa                	mv	s3,a0
    80002258:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000225a:	fffff097          	auipc	ra,0xfffff
    8000225e:	7d6080e7          	jalr	2006(ra) # 80001a30 <myproc>
    80002262:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002264:	05250663          	beq	a0,s2,800022b0 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80002268:	fffff097          	auipc	ra,0xfffff
    8000226c:	9fa080e7          	jalr	-1542(ra) # 80000c62 <acquire>
    release(lk);
    80002270:	854a                	mv	a0,s2
    80002272:	fffff097          	auipc	ra,0xfffff
    80002276:	aa4080e7          	jalr	-1372(ra) # 80000d16 <release>
  p->chan = chan;
    8000227a:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    8000227e:	4785                	li	a5,1
    80002280:	cc9c                	sw	a5,24(s1)
  sched();
    80002282:	00000097          	auipc	ra,0x0
    80002286:	daa080e7          	jalr	-598(ra) # 8000202c <sched>
  p->chan = 0;
    8000228a:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    8000228e:	8526                	mv	a0,s1
    80002290:	fffff097          	auipc	ra,0xfffff
    80002294:	a86080e7          	jalr	-1402(ra) # 80000d16 <release>
    acquire(lk);
    80002298:	854a                	mv	a0,s2
    8000229a:	fffff097          	auipc	ra,0xfffff
    8000229e:	9c8080e7          	jalr	-1592(ra) # 80000c62 <acquire>
}
    800022a2:	70a2                	ld	ra,40(sp)
    800022a4:	7402                	ld	s0,32(sp)
    800022a6:	64e2                	ld	s1,24(sp)
    800022a8:	6942                	ld	s2,16(sp)
    800022aa:	69a2                	ld	s3,8(sp)
    800022ac:	6145                	addi	sp,sp,48
    800022ae:	8082                	ret
  p->chan = chan;
    800022b0:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    800022b4:	4785                	li	a5,1
    800022b6:	cd1c                	sw	a5,24(a0)
  sched();
    800022b8:	00000097          	auipc	ra,0x0
    800022bc:	d74080e7          	jalr	-652(ra) # 8000202c <sched>
  p->chan = 0;
    800022c0:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    800022c4:	bff9                	j	800022a2 <sleep+0x5a>

00000000800022c6 <wait>:
{
    800022c6:	715d                	addi	sp,sp,-80
    800022c8:	e486                	sd	ra,72(sp)
    800022ca:	e0a2                	sd	s0,64(sp)
    800022cc:	fc26                	sd	s1,56(sp)
    800022ce:	f84a                	sd	s2,48(sp)
    800022d0:	f44e                	sd	s3,40(sp)
    800022d2:	f052                	sd	s4,32(sp)
    800022d4:	ec56                	sd	s5,24(sp)
    800022d6:	e85a                	sd	s6,16(sp)
    800022d8:	e45e                	sd	s7,8(sp)
    800022da:	e062                	sd	s8,0(sp)
    800022dc:	0880                	addi	s0,sp,80
    800022de:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800022e0:	fffff097          	auipc	ra,0xfffff
    800022e4:	750080e7          	jalr	1872(ra) # 80001a30 <myproc>
    800022e8:	892a                	mv	s2,a0
  acquire(&p->lock);
    800022ea:	8c2a                	mv	s8,a0
    800022ec:	fffff097          	auipc	ra,0xfffff
    800022f0:	976080e7          	jalr	-1674(ra) # 80000c62 <acquire>
    havekids = 0;
    800022f4:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800022f6:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    800022f8:	00015997          	auipc	s3,0x15
    800022fc:	67098993          	addi	s3,s3,1648 # 80017968 <tickslock>
        havekids = 1;
    80002300:	4a85                	li	s5,1
    havekids = 0;
    80002302:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002304:	00010497          	auipc	s1,0x10
    80002308:	a6448493          	addi	s1,s1,-1436 # 80011d68 <proc>
    8000230c:	a08d                	j	8000236e <wait+0xa8>
          pid = np->pid;
    8000230e:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002312:	000b0e63          	beqz	s6,8000232e <wait+0x68>
    80002316:	4691                	li	a3,4
    80002318:	03448613          	addi	a2,s1,52
    8000231c:	85da                	mv	a1,s6
    8000231e:	05093503          	ld	a0,80(s2)
    80002322:	fffff097          	auipc	ra,0xfffff
    80002326:	402080e7          	jalr	1026(ra) # 80001724 <copyout>
    8000232a:	02054263          	bltz	a0,8000234e <wait+0x88>
          freeproc(np);
    8000232e:	8526                	mv	a0,s1
    80002330:	00000097          	auipc	ra,0x0
    80002334:	8b2080e7          	jalr	-1870(ra) # 80001be2 <freeproc>
          release(&np->lock);
    80002338:	8526                	mv	a0,s1
    8000233a:	fffff097          	auipc	ra,0xfffff
    8000233e:	9dc080e7          	jalr	-1572(ra) # 80000d16 <release>
          release(&p->lock);
    80002342:	854a                	mv	a0,s2
    80002344:	fffff097          	auipc	ra,0xfffff
    80002348:	9d2080e7          	jalr	-1582(ra) # 80000d16 <release>
          return pid;
    8000234c:	a8a9                	j	800023a6 <wait+0xe0>
            release(&np->lock);
    8000234e:	8526                	mv	a0,s1
    80002350:	fffff097          	auipc	ra,0xfffff
    80002354:	9c6080e7          	jalr	-1594(ra) # 80000d16 <release>
            release(&p->lock);
    80002358:	854a                	mv	a0,s2
    8000235a:	fffff097          	auipc	ra,0xfffff
    8000235e:	9bc080e7          	jalr	-1604(ra) # 80000d16 <release>
            return -1;
    80002362:	59fd                	li	s3,-1
    80002364:	a089                	j	800023a6 <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    80002366:	17048493          	addi	s1,s1,368
    8000236a:	03348463          	beq	s1,s3,80002392 <wait+0xcc>
      if(np->parent == p){
    8000236e:	709c                	ld	a5,32(s1)
    80002370:	ff279be3          	bne	a5,s2,80002366 <wait+0xa0>
        acquire(&np->lock);
    80002374:	8526                	mv	a0,s1
    80002376:	fffff097          	auipc	ra,0xfffff
    8000237a:	8ec080e7          	jalr	-1812(ra) # 80000c62 <acquire>
        if(np->state == ZOMBIE){
    8000237e:	4c9c                	lw	a5,24(s1)
    80002380:	f94787e3          	beq	a5,s4,8000230e <wait+0x48>
        release(&np->lock);
    80002384:	8526                	mv	a0,s1
    80002386:	fffff097          	auipc	ra,0xfffff
    8000238a:	990080e7          	jalr	-1648(ra) # 80000d16 <release>
        havekids = 1;
    8000238e:	8756                	mv	a4,s5
    80002390:	bfd9                	j	80002366 <wait+0xa0>
    if(!havekids || p->killed){
    80002392:	c701                	beqz	a4,8000239a <wait+0xd4>
    80002394:	03092783          	lw	a5,48(s2)
    80002398:	c785                	beqz	a5,800023c0 <wait+0xfa>
      release(&p->lock);
    8000239a:	854a                	mv	a0,s2
    8000239c:	fffff097          	auipc	ra,0xfffff
    800023a0:	97a080e7          	jalr	-1670(ra) # 80000d16 <release>
      return -1;
    800023a4:	59fd                	li	s3,-1
}
    800023a6:	854e                	mv	a0,s3
    800023a8:	60a6                	ld	ra,72(sp)
    800023aa:	6406                	ld	s0,64(sp)
    800023ac:	74e2                	ld	s1,56(sp)
    800023ae:	7942                	ld	s2,48(sp)
    800023b0:	79a2                	ld	s3,40(sp)
    800023b2:	7a02                	ld	s4,32(sp)
    800023b4:	6ae2                	ld	s5,24(sp)
    800023b6:	6b42                	ld	s6,16(sp)
    800023b8:	6ba2                	ld	s7,8(sp)
    800023ba:	6c02                	ld	s8,0(sp)
    800023bc:	6161                	addi	sp,sp,80
    800023be:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    800023c0:	85e2                	mv	a1,s8
    800023c2:	854a                	mv	a0,s2
    800023c4:	00000097          	auipc	ra,0x0
    800023c8:	e84080e7          	jalr	-380(ra) # 80002248 <sleep>
    havekids = 0;
    800023cc:	bf1d                	j	80002302 <wait+0x3c>

00000000800023ce <wakeup>:
{
    800023ce:	7139                	addi	sp,sp,-64
    800023d0:	fc06                	sd	ra,56(sp)
    800023d2:	f822                	sd	s0,48(sp)
    800023d4:	f426                	sd	s1,40(sp)
    800023d6:	f04a                	sd	s2,32(sp)
    800023d8:	ec4e                	sd	s3,24(sp)
    800023da:	e852                	sd	s4,16(sp)
    800023dc:	e456                	sd	s5,8(sp)
    800023de:	0080                	addi	s0,sp,64
    800023e0:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800023e2:	00010497          	auipc	s1,0x10
    800023e6:	98648493          	addi	s1,s1,-1658 # 80011d68 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800023ea:	4985                	li	s3,1
      p->state = RUNNABLE;
    800023ec:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800023ee:	00015917          	auipc	s2,0x15
    800023f2:	57a90913          	addi	s2,s2,1402 # 80017968 <tickslock>
    800023f6:	a821                	j	8000240e <wakeup+0x40>
      p->state = RUNNABLE;
    800023f8:	0154ac23          	sw	s5,24(s1)
    release(&p->lock);
    800023fc:	8526                	mv	a0,s1
    800023fe:	fffff097          	auipc	ra,0xfffff
    80002402:	918080e7          	jalr	-1768(ra) # 80000d16 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002406:	17048493          	addi	s1,s1,368
    8000240a:	01248e63          	beq	s1,s2,80002426 <wakeup+0x58>
    acquire(&p->lock);
    8000240e:	8526                	mv	a0,s1
    80002410:	fffff097          	auipc	ra,0xfffff
    80002414:	852080e7          	jalr	-1966(ra) # 80000c62 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    80002418:	4c9c                	lw	a5,24(s1)
    8000241a:	ff3791e3          	bne	a5,s3,800023fc <wakeup+0x2e>
    8000241e:	749c                	ld	a5,40(s1)
    80002420:	fd479ee3          	bne	a5,s4,800023fc <wakeup+0x2e>
    80002424:	bfd1                	j	800023f8 <wakeup+0x2a>
}
    80002426:	70e2                	ld	ra,56(sp)
    80002428:	7442                	ld	s0,48(sp)
    8000242a:	74a2                	ld	s1,40(sp)
    8000242c:	7902                	ld	s2,32(sp)
    8000242e:	69e2                	ld	s3,24(sp)
    80002430:	6a42                	ld	s4,16(sp)
    80002432:	6aa2                	ld	s5,8(sp)
    80002434:	6121                	addi	sp,sp,64
    80002436:	8082                	ret

0000000080002438 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002438:	7179                	addi	sp,sp,-48
    8000243a:	f406                	sd	ra,40(sp)
    8000243c:	f022                	sd	s0,32(sp)
    8000243e:	ec26                	sd	s1,24(sp)
    80002440:	e84a                	sd	s2,16(sp)
    80002442:	e44e                	sd	s3,8(sp)
    80002444:	1800                	addi	s0,sp,48
    80002446:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002448:	00010497          	auipc	s1,0x10
    8000244c:	92048493          	addi	s1,s1,-1760 # 80011d68 <proc>
    80002450:	00015997          	auipc	s3,0x15
    80002454:	51898993          	addi	s3,s3,1304 # 80017968 <tickslock>
    acquire(&p->lock);
    80002458:	8526                	mv	a0,s1
    8000245a:	fffff097          	auipc	ra,0xfffff
    8000245e:	808080e7          	jalr	-2040(ra) # 80000c62 <acquire>
    if(p->pid == pid){
    80002462:	5c9c                	lw	a5,56(s1)
    80002464:	01278d63          	beq	a5,s2,8000247e <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002468:	8526                	mv	a0,s1
    8000246a:	fffff097          	auipc	ra,0xfffff
    8000246e:	8ac080e7          	jalr	-1876(ra) # 80000d16 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002472:	17048493          	addi	s1,s1,368
    80002476:	ff3491e3          	bne	s1,s3,80002458 <kill+0x20>
  }
  return -1;
    8000247a:	557d                	li	a0,-1
    8000247c:	a829                	j	80002496 <kill+0x5e>
      p->killed = 1;
    8000247e:	4785                	li	a5,1
    80002480:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    80002482:	4c98                	lw	a4,24(s1)
    80002484:	4785                	li	a5,1
    80002486:	00f70f63          	beq	a4,a5,800024a4 <kill+0x6c>
      release(&p->lock);
    8000248a:	8526                	mv	a0,s1
    8000248c:	fffff097          	auipc	ra,0xfffff
    80002490:	88a080e7          	jalr	-1910(ra) # 80000d16 <release>
      return 0;
    80002494:	4501                	li	a0,0
}
    80002496:	70a2                	ld	ra,40(sp)
    80002498:	7402                	ld	s0,32(sp)
    8000249a:	64e2                	ld	s1,24(sp)
    8000249c:	6942                	ld	s2,16(sp)
    8000249e:	69a2                	ld	s3,8(sp)
    800024a0:	6145                	addi	sp,sp,48
    800024a2:	8082                	ret
        p->state = RUNNABLE;
    800024a4:	4789                	li	a5,2
    800024a6:	cc9c                	sw	a5,24(s1)
    800024a8:	b7cd                	j	8000248a <kill+0x52>

00000000800024aa <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024aa:	7179                	addi	sp,sp,-48
    800024ac:	f406                	sd	ra,40(sp)
    800024ae:	f022                	sd	s0,32(sp)
    800024b0:	ec26                	sd	s1,24(sp)
    800024b2:	e84a                	sd	s2,16(sp)
    800024b4:	e44e                	sd	s3,8(sp)
    800024b6:	e052                	sd	s4,0(sp)
    800024b8:	1800                	addi	s0,sp,48
    800024ba:	84aa                	mv	s1,a0
    800024bc:	892e                	mv	s2,a1
    800024be:	89b2                	mv	s3,a2
    800024c0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024c2:	fffff097          	auipc	ra,0xfffff
    800024c6:	56e080e7          	jalr	1390(ra) # 80001a30 <myproc>
  if(user_dst){
    800024ca:	c08d                	beqz	s1,800024ec <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800024cc:	86d2                	mv	a3,s4
    800024ce:	864e                	mv	a2,s3
    800024d0:	85ca                	mv	a1,s2
    800024d2:	6928                	ld	a0,80(a0)
    800024d4:	fffff097          	auipc	ra,0xfffff
    800024d8:	250080e7          	jalr	592(ra) # 80001724 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024dc:	70a2                	ld	ra,40(sp)
    800024de:	7402                	ld	s0,32(sp)
    800024e0:	64e2                	ld	s1,24(sp)
    800024e2:	6942                	ld	s2,16(sp)
    800024e4:	69a2                	ld	s3,8(sp)
    800024e6:	6a02                	ld	s4,0(sp)
    800024e8:	6145                	addi	sp,sp,48
    800024ea:	8082                	ret
    memmove((char *)dst, src, len);
    800024ec:	000a061b          	sext.w	a2,s4
    800024f0:	85ce                	mv	a1,s3
    800024f2:	854a                	mv	a0,s2
    800024f4:	fffff097          	auipc	ra,0xfffff
    800024f8:	8ca080e7          	jalr	-1846(ra) # 80000dbe <memmove>
    return 0;
    800024fc:	8526                	mv	a0,s1
    800024fe:	bff9                	j	800024dc <either_copyout+0x32>

0000000080002500 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002500:	7179                	addi	sp,sp,-48
    80002502:	f406                	sd	ra,40(sp)
    80002504:	f022                	sd	s0,32(sp)
    80002506:	ec26                	sd	s1,24(sp)
    80002508:	e84a                	sd	s2,16(sp)
    8000250a:	e44e                	sd	s3,8(sp)
    8000250c:	e052                	sd	s4,0(sp)
    8000250e:	1800                	addi	s0,sp,48
    80002510:	892a                	mv	s2,a0
    80002512:	84ae                	mv	s1,a1
    80002514:	89b2                	mv	s3,a2
    80002516:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002518:	fffff097          	auipc	ra,0xfffff
    8000251c:	518080e7          	jalr	1304(ra) # 80001a30 <myproc>
  if(user_src){
    80002520:	c08d                	beqz	s1,80002542 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002522:	86d2                	mv	a3,s4
    80002524:	864e                	mv	a2,s3
    80002526:	85ca                	mv	a1,s2
    80002528:	6928                	ld	a0,80(a0)
    8000252a:	fffff097          	auipc	ra,0xfffff
    8000252e:	286080e7          	jalr	646(ra) # 800017b0 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002532:	70a2                	ld	ra,40(sp)
    80002534:	7402                	ld	s0,32(sp)
    80002536:	64e2                	ld	s1,24(sp)
    80002538:	6942                	ld	s2,16(sp)
    8000253a:	69a2                	ld	s3,8(sp)
    8000253c:	6a02                	ld	s4,0(sp)
    8000253e:	6145                	addi	sp,sp,48
    80002540:	8082                	ret
    memmove(dst, (char*)src, len);
    80002542:	000a061b          	sext.w	a2,s4
    80002546:	85ce                	mv	a1,s3
    80002548:	854a                	mv	a0,s2
    8000254a:	fffff097          	auipc	ra,0xfffff
    8000254e:	874080e7          	jalr	-1932(ra) # 80000dbe <memmove>
    return 0;
    80002552:	8526                	mv	a0,s1
    80002554:	bff9                	j	80002532 <either_copyin+0x32>

0000000080002556 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002556:	715d                	addi	sp,sp,-80
    80002558:	e486                	sd	ra,72(sp)
    8000255a:	e0a2                	sd	s0,64(sp)
    8000255c:	fc26                	sd	s1,56(sp)
    8000255e:	f84a                	sd	s2,48(sp)
    80002560:	f44e                	sd	s3,40(sp)
    80002562:	f052                	sd	s4,32(sp)
    80002564:	ec56                	sd	s5,24(sp)
    80002566:	e85a                	sd	s6,16(sp)
    80002568:	e45e                	sd	s7,8(sp)
    8000256a:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000256c:	00006517          	auipc	a0,0x6
    80002570:	b5c50513          	addi	a0,a0,-1188 # 800080c8 <digits+0x88>
    80002574:	ffffe097          	auipc	ra,0xffffe
    80002578:	01e080e7          	jalr	30(ra) # 80000592 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000257c:	00010497          	auipc	s1,0x10
    80002580:	94448493          	addi	s1,s1,-1724 # 80011ec0 <proc+0x158>
    80002584:	00015917          	auipc	s2,0x15
    80002588:	53c90913          	addi	s2,s2,1340 # 80017ac0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000258c:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    8000258e:	00006997          	auipc	s3,0x6
    80002592:	cda98993          	addi	s3,s3,-806 # 80008268 <digits+0x228>
    printf("%d %s %s", p->pid, state, p->name);
    80002596:	00006a97          	auipc	s5,0x6
    8000259a:	cdaa8a93          	addi	s5,s5,-806 # 80008270 <digits+0x230>
    printf("\n");
    8000259e:	00006a17          	auipc	s4,0x6
    800025a2:	b2aa0a13          	addi	s4,s4,-1238 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025a6:	00006b97          	auipc	s7,0x6
    800025aa:	d02b8b93          	addi	s7,s7,-766 # 800082a8 <states.1707>
    800025ae:	a00d                	j	800025d0 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800025b0:	ee06a583          	lw	a1,-288(a3)
    800025b4:	8556                	mv	a0,s5
    800025b6:	ffffe097          	auipc	ra,0xffffe
    800025ba:	fdc080e7          	jalr	-36(ra) # 80000592 <printf>
    printf("\n");
    800025be:	8552                	mv	a0,s4
    800025c0:	ffffe097          	auipc	ra,0xffffe
    800025c4:	fd2080e7          	jalr	-46(ra) # 80000592 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025c8:	17048493          	addi	s1,s1,368
    800025cc:	03248163          	beq	s1,s2,800025ee <procdump+0x98>
    if(p->state == UNUSED)
    800025d0:	86a6                	mv	a3,s1
    800025d2:	ec04a783          	lw	a5,-320(s1)
    800025d6:	dbed                	beqz	a5,800025c8 <procdump+0x72>
      state = "???";
    800025d8:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025da:	fcfb6be3          	bltu	s6,a5,800025b0 <procdump+0x5a>
    800025de:	1782                	slli	a5,a5,0x20
    800025e0:	9381                	srli	a5,a5,0x20
    800025e2:	078e                	slli	a5,a5,0x3
    800025e4:	97de                	add	a5,a5,s7
    800025e6:	6390                	ld	a2,0(a5)
    800025e8:	f661                	bnez	a2,800025b0 <procdump+0x5a>
      state = "???";
    800025ea:	864e                	mv	a2,s3
    800025ec:	b7d1                	j	800025b0 <procdump+0x5a>
  }
}
    800025ee:	60a6                	ld	ra,72(sp)
    800025f0:	6406                	ld	s0,64(sp)
    800025f2:	74e2                	ld	s1,56(sp)
    800025f4:	7942                	ld	s2,48(sp)
    800025f6:	79a2                	ld	s3,40(sp)
    800025f8:	7a02                	ld	s4,32(sp)
    800025fa:	6ae2                	ld	s5,24(sp)
    800025fc:	6b42                	ld	s6,16(sp)
    800025fe:	6ba2                	ld	s7,8(sp)
    80002600:	6161                	addi	sp,sp,80
    80002602:	8082                	ret

0000000080002604 <kama_procnum>:

// 统计处于活动状态的进程
void
kama_procnum(uint64* dst) {
    80002604:	1141                	addi	sp,sp,-16
    80002606:	e422                	sd	s0,8(sp)
    80002608:	0800                	addi	s0,sp,16
    *dst = 0;
    8000260a:	00053023          	sd	zero,0(a0)
    struct proc* p;
    for (p = proc;p < &proc[NPROC];p++) {
    8000260e:	0000f797          	auipc	a5,0xf
    80002612:	75a78793          	addi	a5,a5,1882 # 80011d68 <proc>
    80002616:	00015697          	auipc	a3,0x15
    8000261a:	35268693          	addi	a3,a3,850 # 80017968 <tickslock>
    8000261e:	a029                	j	80002628 <kama_procnum+0x24>
    80002620:	17078793          	addi	a5,a5,368
    80002624:	00d78863          	beq	a5,a3,80002634 <kama_procnum+0x30>
        if (p->state != UNUSED)
    80002628:	4f98                	lw	a4,24(a5)
    8000262a:	db7d                	beqz	a4,80002620 <kama_procnum+0x1c>
            (*dst)++;
    8000262c:	6118                	ld	a4,0(a0)
    8000262e:	0705                	addi	a4,a4,1
    80002630:	e118                	sd	a4,0(a0)
    80002632:	b7fd                	j	80002620 <kama_procnum+0x1c>
    }
    80002634:	6422                	ld	s0,8(sp)
    80002636:	0141                	addi	sp,sp,16
    80002638:	8082                	ret

000000008000263a <swtch>:
    8000263a:	00153023          	sd	ra,0(a0)
    8000263e:	00253423          	sd	sp,8(a0)
    80002642:	e900                	sd	s0,16(a0)
    80002644:	ed04                	sd	s1,24(a0)
    80002646:	03253023          	sd	s2,32(a0)
    8000264a:	03353423          	sd	s3,40(a0)
    8000264e:	03453823          	sd	s4,48(a0)
    80002652:	03553c23          	sd	s5,56(a0)
    80002656:	05653023          	sd	s6,64(a0)
    8000265a:	05753423          	sd	s7,72(a0)
    8000265e:	05853823          	sd	s8,80(a0)
    80002662:	05953c23          	sd	s9,88(a0)
    80002666:	07a53023          	sd	s10,96(a0)
    8000266a:	07b53423          	sd	s11,104(a0)
    8000266e:	0005b083          	ld	ra,0(a1)
    80002672:	0085b103          	ld	sp,8(a1)
    80002676:	6980                	ld	s0,16(a1)
    80002678:	6d84                	ld	s1,24(a1)
    8000267a:	0205b903          	ld	s2,32(a1)
    8000267e:	0285b983          	ld	s3,40(a1)
    80002682:	0305ba03          	ld	s4,48(a1)
    80002686:	0385ba83          	ld	s5,56(a1)
    8000268a:	0405bb03          	ld	s6,64(a1)
    8000268e:	0485bb83          	ld	s7,72(a1)
    80002692:	0505bc03          	ld	s8,80(a1)
    80002696:	0585bc83          	ld	s9,88(a1)
    8000269a:	0605bd03          	ld	s10,96(a1)
    8000269e:	0685bd83          	ld	s11,104(a1)
    800026a2:	8082                	ret

00000000800026a4 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800026a4:	1141                	addi	sp,sp,-16
    800026a6:	e406                	sd	ra,8(sp)
    800026a8:	e022                	sd	s0,0(sp)
    800026aa:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800026ac:	00006597          	auipc	a1,0x6
    800026b0:	c2458593          	addi	a1,a1,-988 # 800082d0 <states.1707+0x28>
    800026b4:	00015517          	auipc	a0,0x15
    800026b8:	2b450513          	addi	a0,a0,692 # 80017968 <tickslock>
    800026bc:	ffffe097          	auipc	ra,0xffffe
    800026c0:	516080e7          	jalr	1302(ra) # 80000bd2 <initlock>
}
    800026c4:	60a2                	ld	ra,8(sp)
    800026c6:	6402                	ld	s0,0(sp)
    800026c8:	0141                	addi	sp,sp,16
    800026ca:	8082                	ret

00000000800026cc <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800026cc:	1141                	addi	sp,sp,-16
    800026ce:	e422                	sd	s0,8(sp)
    800026d0:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026d2:	00003797          	auipc	a5,0x3
    800026d6:	58e78793          	addi	a5,a5,1422 # 80005c60 <kernelvec>
    800026da:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800026de:	6422                	ld	s0,8(sp)
    800026e0:	0141                	addi	sp,sp,16
    800026e2:	8082                	ret

00000000800026e4 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800026e4:	1141                	addi	sp,sp,-16
    800026e6:	e406                	sd	ra,8(sp)
    800026e8:	e022                	sd	s0,0(sp)
    800026ea:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800026ec:	fffff097          	auipc	ra,0xfffff
    800026f0:	344080e7          	jalr	836(ra) # 80001a30 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026f4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800026f8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026fa:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800026fe:	00005617          	auipc	a2,0x5
    80002702:	90260613          	addi	a2,a2,-1790 # 80007000 <_trampoline>
    80002706:	00005697          	auipc	a3,0x5
    8000270a:	8fa68693          	addi	a3,a3,-1798 # 80007000 <_trampoline>
    8000270e:	8e91                	sub	a3,a3,a2
    80002710:	040007b7          	lui	a5,0x4000
    80002714:	17fd                	addi	a5,a5,-1
    80002716:	07b2                	slli	a5,a5,0xc
    80002718:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000271a:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000271e:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002720:	180026f3          	csrr	a3,satp
    80002724:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002726:	6d38                	ld	a4,88(a0)
    80002728:	6134                	ld	a3,64(a0)
    8000272a:	6585                	lui	a1,0x1
    8000272c:	96ae                	add	a3,a3,a1
    8000272e:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002730:	6d38                	ld	a4,88(a0)
    80002732:	00000697          	auipc	a3,0x0
    80002736:	13868693          	addi	a3,a3,312 # 8000286a <usertrap>
    8000273a:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000273c:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000273e:	8692                	mv	a3,tp
    80002740:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002742:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002746:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000274a:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000274e:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002752:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002754:	6f18                	ld	a4,24(a4)
    80002756:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000275a:	692c                	ld	a1,80(a0)
    8000275c:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    8000275e:	00005717          	auipc	a4,0x5
    80002762:	93270713          	addi	a4,a4,-1742 # 80007090 <userret>
    80002766:	8f11                	sub	a4,a4,a2
    80002768:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    8000276a:	577d                	li	a4,-1
    8000276c:	177e                	slli	a4,a4,0x3f
    8000276e:	8dd9                	or	a1,a1,a4
    80002770:	02000537          	lui	a0,0x2000
    80002774:	157d                	addi	a0,a0,-1
    80002776:	0536                	slli	a0,a0,0xd
    80002778:	9782                	jalr	a5
}
    8000277a:	60a2                	ld	ra,8(sp)
    8000277c:	6402                	ld	s0,0(sp)
    8000277e:	0141                	addi	sp,sp,16
    80002780:	8082                	ret

0000000080002782 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002782:	1101                	addi	sp,sp,-32
    80002784:	ec06                	sd	ra,24(sp)
    80002786:	e822                	sd	s0,16(sp)
    80002788:	e426                	sd	s1,8(sp)
    8000278a:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000278c:	00015497          	auipc	s1,0x15
    80002790:	1dc48493          	addi	s1,s1,476 # 80017968 <tickslock>
    80002794:	8526                	mv	a0,s1
    80002796:	ffffe097          	auipc	ra,0xffffe
    8000279a:	4cc080e7          	jalr	1228(ra) # 80000c62 <acquire>
  ticks++;
    8000279e:	00007517          	auipc	a0,0x7
    800027a2:	88250513          	addi	a0,a0,-1918 # 80009020 <ticks>
    800027a6:	411c                	lw	a5,0(a0)
    800027a8:	2785                	addiw	a5,a5,1
    800027aa:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800027ac:	00000097          	auipc	ra,0x0
    800027b0:	c22080e7          	jalr	-990(ra) # 800023ce <wakeup>
  release(&tickslock);
    800027b4:	8526                	mv	a0,s1
    800027b6:	ffffe097          	auipc	ra,0xffffe
    800027ba:	560080e7          	jalr	1376(ra) # 80000d16 <release>
}
    800027be:	60e2                	ld	ra,24(sp)
    800027c0:	6442                	ld	s0,16(sp)
    800027c2:	64a2                	ld	s1,8(sp)
    800027c4:	6105                	addi	sp,sp,32
    800027c6:	8082                	ret

00000000800027c8 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800027c8:	1101                	addi	sp,sp,-32
    800027ca:	ec06                	sd	ra,24(sp)
    800027cc:	e822                	sd	s0,16(sp)
    800027ce:	e426                	sd	s1,8(sp)
    800027d0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027d2:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800027d6:	00074d63          	bltz	a4,800027f0 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800027da:	57fd                	li	a5,-1
    800027dc:	17fe                	slli	a5,a5,0x3f
    800027de:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800027e0:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800027e2:	06f70363          	beq	a4,a5,80002848 <devintr+0x80>
  }
}
    800027e6:	60e2                	ld	ra,24(sp)
    800027e8:	6442                	ld	s0,16(sp)
    800027ea:	64a2                	ld	s1,8(sp)
    800027ec:	6105                	addi	sp,sp,32
    800027ee:	8082                	ret
     (scause & 0xff) == 9){
    800027f0:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800027f4:	46a5                	li	a3,9
    800027f6:	fed792e3          	bne	a5,a3,800027da <devintr+0x12>
    int irq = plic_claim();
    800027fa:	00003097          	auipc	ra,0x3
    800027fe:	56e080e7          	jalr	1390(ra) # 80005d68 <plic_claim>
    80002802:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002804:	47a9                	li	a5,10
    80002806:	02f50763          	beq	a0,a5,80002834 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    8000280a:	4785                	li	a5,1
    8000280c:	02f50963          	beq	a0,a5,8000283e <devintr+0x76>
    return 1;
    80002810:	4505                	li	a0,1
    } else if(irq){
    80002812:	d8f1                	beqz	s1,800027e6 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002814:	85a6                	mv	a1,s1
    80002816:	00006517          	auipc	a0,0x6
    8000281a:	ac250513          	addi	a0,a0,-1342 # 800082d8 <states.1707+0x30>
    8000281e:	ffffe097          	auipc	ra,0xffffe
    80002822:	d74080e7          	jalr	-652(ra) # 80000592 <printf>
      plic_complete(irq);
    80002826:	8526                	mv	a0,s1
    80002828:	00003097          	auipc	ra,0x3
    8000282c:	564080e7          	jalr	1380(ra) # 80005d8c <plic_complete>
    return 1;
    80002830:	4505                	li	a0,1
    80002832:	bf55                	j	800027e6 <devintr+0x1e>
      uartintr();
    80002834:	ffffe097          	auipc	ra,0xffffe
    80002838:	1a0080e7          	jalr	416(ra) # 800009d4 <uartintr>
    8000283c:	b7ed                	j	80002826 <devintr+0x5e>
      virtio_disk_intr();
    8000283e:	00004097          	auipc	ra,0x4
    80002842:	9e8080e7          	jalr	-1560(ra) # 80006226 <virtio_disk_intr>
    80002846:	b7c5                	j	80002826 <devintr+0x5e>
    if(cpuid() == 0){
    80002848:	fffff097          	auipc	ra,0xfffff
    8000284c:	1bc080e7          	jalr	444(ra) # 80001a04 <cpuid>
    80002850:	c901                	beqz	a0,80002860 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002852:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002856:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002858:	14479073          	csrw	sip,a5
    return 2;
    8000285c:	4509                	li	a0,2
    8000285e:	b761                	j	800027e6 <devintr+0x1e>
      clockintr();
    80002860:	00000097          	auipc	ra,0x0
    80002864:	f22080e7          	jalr	-222(ra) # 80002782 <clockintr>
    80002868:	b7ed                	j	80002852 <devintr+0x8a>

000000008000286a <usertrap>:
{
    8000286a:	1101                	addi	sp,sp,-32
    8000286c:	ec06                	sd	ra,24(sp)
    8000286e:	e822                	sd	s0,16(sp)
    80002870:	e426                	sd	s1,8(sp)
    80002872:	e04a                	sd	s2,0(sp)
    80002874:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002876:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000287a:	1007f793          	andi	a5,a5,256
    8000287e:	e3ad                	bnez	a5,800028e0 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002880:	00003797          	auipc	a5,0x3
    80002884:	3e078793          	addi	a5,a5,992 # 80005c60 <kernelvec>
    80002888:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000288c:	fffff097          	auipc	ra,0xfffff
    80002890:	1a4080e7          	jalr	420(ra) # 80001a30 <myproc>
    80002894:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002896:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002898:	14102773          	csrr	a4,sepc
    8000289c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000289e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800028a2:	47a1                	li	a5,8
    800028a4:	04f71c63          	bne	a4,a5,800028fc <usertrap+0x92>
    if(p->killed)
    800028a8:	591c                	lw	a5,48(a0)
    800028aa:	e3b9                	bnez	a5,800028f0 <usertrap+0x86>
    p->trapframe->epc += 4;
    800028ac:	6cb8                	ld	a4,88(s1)
    800028ae:	6f1c                	ld	a5,24(a4)
    800028b0:	0791                	addi	a5,a5,4
    800028b2:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028b4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800028b8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028bc:	10079073          	csrw	sstatus,a5
    syscall();
    800028c0:	00000097          	auipc	ra,0x0
    800028c4:	2e0080e7          	jalr	736(ra) # 80002ba0 <syscall>
  if(p->killed)
    800028c8:	589c                	lw	a5,48(s1)
    800028ca:	ebc1                	bnez	a5,8000295a <usertrap+0xf0>
  usertrapret();
    800028cc:	00000097          	auipc	ra,0x0
    800028d0:	e18080e7          	jalr	-488(ra) # 800026e4 <usertrapret>
}
    800028d4:	60e2                	ld	ra,24(sp)
    800028d6:	6442                	ld	s0,16(sp)
    800028d8:	64a2                	ld	s1,8(sp)
    800028da:	6902                	ld	s2,0(sp)
    800028dc:	6105                	addi	sp,sp,32
    800028de:	8082                	ret
    panic("usertrap: not from user mode");
    800028e0:	00006517          	auipc	a0,0x6
    800028e4:	a1850513          	addi	a0,a0,-1512 # 800082f8 <states.1707+0x50>
    800028e8:	ffffe097          	auipc	ra,0xffffe
    800028ec:	c60080e7          	jalr	-928(ra) # 80000548 <panic>
      exit(-1);
    800028f0:	557d                	li	a0,-1
    800028f2:	00000097          	auipc	ra,0x0
    800028f6:	810080e7          	jalr	-2032(ra) # 80002102 <exit>
    800028fa:	bf4d                	j	800028ac <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    800028fc:	00000097          	auipc	ra,0x0
    80002900:	ecc080e7          	jalr	-308(ra) # 800027c8 <devintr>
    80002904:	892a                	mv	s2,a0
    80002906:	c501                	beqz	a0,8000290e <usertrap+0xa4>
  if(p->killed)
    80002908:	589c                	lw	a5,48(s1)
    8000290a:	c3a1                	beqz	a5,8000294a <usertrap+0xe0>
    8000290c:	a815                	j	80002940 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000290e:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002912:	5c90                	lw	a2,56(s1)
    80002914:	00006517          	auipc	a0,0x6
    80002918:	a0450513          	addi	a0,a0,-1532 # 80008318 <states.1707+0x70>
    8000291c:	ffffe097          	auipc	ra,0xffffe
    80002920:	c76080e7          	jalr	-906(ra) # 80000592 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002924:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002928:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000292c:	00006517          	auipc	a0,0x6
    80002930:	a1c50513          	addi	a0,a0,-1508 # 80008348 <states.1707+0xa0>
    80002934:	ffffe097          	auipc	ra,0xffffe
    80002938:	c5e080e7          	jalr	-930(ra) # 80000592 <printf>
    p->killed = 1;
    8000293c:	4785                	li	a5,1
    8000293e:	d89c                	sw	a5,48(s1)
    exit(-1);
    80002940:	557d                	li	a0,-1
    80002942:	fffff097          	auipc	ra,0xfffff
    80002946:	7c0080e7          	jalr	1984(ra) # 80002102 <exit>
  if(which_dev == 2)
    8000294a:	4789                	li	a5,2
    8000294c:	f8f910e3          	bne	s2,a5,800028cc <usertrap+0x62>
    yield();
    80002950:	00000097          	auipc	ra,0x0
    80002954:	8bc080e7          	jalr	-1860(ra) # 8000220c <yield>
    80002958:	bf95                	j	800028cc <usertrap+0x62>
  int which_dev = 0;
    8000295a:	4901                	li	s2,0
    8000295c:	b7d5                	j	80002940 <usertrap+0xd6>

000000008000295e <kerneltrap>:
{
    8000295e:	7179                	addi	sp,sp,-48
    80002960:	f406                	sd	ra,40(sp)
    80002962:	f022                	sd	s0,32(sp)
    80002964:	ec26                	sd	s1,24(sp)
    80002966:	e84a                	sd	s2,16(sp)
    80002968:	e44e                	sd	s3,8(sp)
    8000296a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000296c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002970:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002974:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002978:	1004f793          	andi	a5,s1,256
    8000297c:	cb85                	beqz	a5,800029ac <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000297e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002982:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002984:	ef85                	bnez	a5,800029bc <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002986:	00000097          	auipc	ra,0x0
    8000298a:	e42080e7          	jalr	-446(ra) # 800027c8 <devintr>
    8000298e:	cd1d                	beqz	a0,800029cc <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002990:	4789                	li	a5,2
    80002992:	06f50a63          	beq	a0,a5,80002a06 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002996:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000299a:	10049073          	csrw	sstatus,s1
}
    8000299e:	70a2                	ld	ra,40(sp)
    800029a0:	7402                	ld	s0,32(sp)
    800029a2:	64e2                	ld	s1,24(sp)
    800029a4:	6942                	ld	s2,16(sp)
    800029a6:	69a2                	ld	s3,8(sp)
    800029a8:	6145                	addi	sp,sp,48
    800029aa:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800029ac:	00006517          	auipc	a0,0x6
    800029b0:	9bc50513          	addi	a0,a0,-1604 # 80008368 <states.1707+0xc0>
    800029b4:	ffffe097          	auipc	ra,0xffffe
    800029b8:	b94080e7          	jalr	-1132(ra) # 80000548 <panic>
    panic("kerneltrap: interrupts enabled");
    800029bc:	00006517          	auipc	a0,0x6
    800029c0:	9d450513          	addi	a0,a0,-1580 # 80008390 <states.1707+0xe8>
    800029c4:	ffffe097          	auipc	ra,0xffffe
    800029c8:	b84080e7          	jalr	-1148(ra) # 80000548 <panic>
    printf("scause %p\n", scause);
    800029cc:	85ce                	mv	a1,s3
    800029ce:	00006517          	auipc	a0,0x6
    800029d2:	9e250513          	addi	a0,a0,-1566 # 800083b0 <states.1707+0x108>
    800029d6:	ffffe097          	auipc	ra,0xffffe
    800029da:	bbc080e7          	jalr	-1092(ra) # 80000592 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029de:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029e2:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029e6:	00006517          	auipc	a0,0x6
    800029ea:	9da50513          	addi	a0,a0,-1574 # 800083c0 <states.1707+0x118>
    800029ee:	ffffe097          	auipc	ra,0xffffe
    800029f2:	ba4080e7          	jalr	-1116(ra) # 80000592 <printf>
    panic("kerneltrap");
    800029f6:	00006517          	auipc	a0,0x6
    800029fa:	9e250513          	addi	a0,a0,-1566 # 800083d8 <states.1707+0x130>
    800029fe:	ffffe097          	auipc	ra,0xffffe
    80002a02:	b4a080e7          	jalr	-1206(ra) # 80000548 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a06:	fffff097          	auipc	ra,0xfffff
    80002a0a:	02a080e7          	jalr	42(ra) # 80001a30 <myproc>
    80002a0e:	d541                	beqz	a0,80002996 <kerneltrap+0x38>
    80002a10:	fffff097          	auipc	ra,0xfffff
    80002a14:	020080e7          	jalr	32(ra) # 80001a30 <myproc>
    80002a18:	4d18                	lw	a4,24(a0)
    80002a1a:	478d                	li	a5,3
    80002a1c:	f6f71de3          	bne	a4,a5,80002996 <kerneltrap+0x38>
    yield();
    80002a20:	fffff097          	auipc	ra,0xfffff
    80002a24:	7ec080e7          	jalr	2028(ra) # 8000220c <yield>
    80002a28:	b7bd                	j	80002996 <kerneltrap+0x38>

0000000080002a2a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a2a:	1101                	addi	sp,sp,-32
    80002a2c:	ec06                	sd	ra,24(sp)
    80002a2e:	e822                	sd	s0,16(sp)
    80002a30:	e426                	sd	s1,8(sp)
    80002a32:	1000                	addi	s0,sp,32
    80002a34:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a36:	fffff097          	auipc	ra,0xfffff
    80002a3a:	ffa080e7          	jalr	-6(ra) # 80001a30 <myproc>
  switch (n) {
    80002a3e:	4795                	li	a5,5
    80002a40:	0497e163          	bltu	a5,s1,80002a82 <argraw+0x58>
    80002a44:	048a                	slli	s1,s1,0x2
    80002a46:	00006717          	auipc	a4,0x6
    80002a4a:	a8a70713          	addi	a4,a4,-1398 # 800084d0 <states.1707+0x228>
    80002a4e:	94ba                	add	s1,s1,a4
    80002a50:	409c                	lw	a5,0(s1)
    80002a52:	97ba                	add	a5,a5,a4
    80002a54:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a56:	6d3c                	ld	a5,88(a0)
    80002a58:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a5a:	60e2                	ld	ra,24(sp)
    80002a5c:	6442                	ld	s0,16(sp)
    80002a5e:	64a2                	ld	s1,8(sp)
    80002a60:	6105                	addi	sp,sp,32
    80002a62:	8082                	ret
    return p->trapframe->a1;
    80002a64:	6d3c                	ld	a5,88(a0)
    80002a66:	7fa8                	ld	a0,120(a5)
    80002a68:	bfcd                	j	80002a5a <argraw+0x30>
    return p->trapframe->a2;
    80002a6a:	6d3c                	ld	a5,88(a0)
    80002a6c:	63c8                	ld	a0,128(a5)
    80002a6e:	b7f5                	j	80002a5a <argraw+0x30>
    return p->trapframe->a3;
    80002a70:	6d3c                	ld	a5,88(a0)
    80002a72:	67c8                	ld	a0,136(a5)
    80002a74:	b7dd                	j	80002a5a <argraw+0x30>
    return p->trapframe->a4;
    80002a76:	6d3c                	ld	a5,88(a0)
    80002a78:	6bc8                	ld	a0,144(a5)
    80002a7a:	b7c5                	j	80002a5a <argraw+0x30>
    return p->trapframe->a5;
    80002a7c:	6d3c                	ld	a5,88(a0)
    80002a7e:	6fc8                	ld	a0,152(a5)
    80002a80:	bfe9                	j	80002a5a <argraw+0x30>
  panic("argraw");
    80002a82:	00006517          	auipc	a0,0x6
    80002a86:	96650513          	addi	a0,a0,-1690 # 800083e8 <states.1707+0x140>
    80002a8a:	ffffe097          	auipc	ra,0xffffe
    80002a8e:	abe080e7          	jalr	-1346(ra) # 80000548 <panic>

0000000080002a92 <fetchaddr>:
{
    80002a92:	1101                	addi	sp,sp,-32
    80002a94:	ec06                	sd	ra,24(sp)
    80002a96:	e822                	sd	s0,16(sp)
    80002a98:	e426                	sd	s1,8(sp)
    80002a9a:	e04a                	sd	s2,0(sp)
    80002a9c:	1000                	addi	s0,sp,32
    80002a9e:	84aa                	mv	s1,a0
    80002aa0:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002aa2:	fffff097          	auipc	ra,0xfffff
    80002aa6:	f8e080e7          	jalr	-114(ra) # 80001a30 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002aaa:	653c                	ld	a5,72(a0)
    80002aac:	02f4f863          	bgeu	s1,a5,80002adc <fetchaddr+0x4a>
    80002ab0:	00848713          	addi	a4,s1,8
    80002ab4:	02e7e663          	bltu	a5,a4,80002ae0 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002ab8:	46a1                	li	a3,8
    80002aba:	8626                	mv	a2,s1
    80002abc:	85ca                	mv	a1,s2
    80002abe:	6928                	ld	a0,80(a0)
    80002ac0:	fffff097          	auipc	ra,0xfffff
    80002ac4:	cf0080e7          	jalr	-784(ra) # 800017b0 <copyin>
    80002ac8:	00a03533          	snez	a0,a0
    80002acc:	40a00533          	neg	a0,a0
}
    80002ad0:	60e2                	ld	ra,24(sp)
    80002ad2:	6442                	ld	s0,16(sp)
    80002ad4:	64a2                	ld	s1,8(sp)
    80002ad6:	6902                	ld	s2,0(sp)
    80002ad8:	6105                	addi	sp,sp,32
    80002ada:	8082                	ret
    return -1;
    80002adc:	557d                	li	a0,-1
    80002ade:	bfcd                	j	80002ad0 <fetchaddr+0x3e>
    80002ae0:	557d                	li	a0,-1
    80002ae2:	b7fd                	j	80002ad0 <fetchaddr+0x3e>

0000000080002ae4 <fetchstr>:
{
    80002ae4:	7179                	addi	sp,sp,-48
    80002ae6:	f406                	sd	ra,40(sp)
    80002ae8:	f022                	sd	s0,32(sp)
    80002aea:	ec26                	sd	s1,24(sp)
    80002aec:	e84a                	sd	s2,16(sp)
    80002aee:	e44e                	sd	s3,8(sp)
    80002af0:	1800                	addi	s0,sp,48
    80002af2:	892a                	mv	s2,a0
    80002af4:	84ae                	mv	s1,a1
    80002af6:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002af8:	fffff097          	auipc	ra,0xfffff
    80002afc:	f38080e7          	jalr	-200(ra) # 80001a30 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002b00:	86ce                	mv	a3,s3
    80002b02:	864a                	mv	a2,s2
    80002b04:	85a6                	mv	a1,s1
    80002b06:	6928                	ld	a0,80(a0)
    80002b08:	fffff097          	auipc	ra,0xfffff
    80002b0c:	d34080e7          	jalr	-716(ra) # 8000183c <copyinstr>
  if(err < 0)
    80002b10:	00054763          	bltz	a0,80002b1e <fetchstr+0x3a>
  return strlen(buf);
    80002b14:	8526                	mv	a0,s1
    80002b16:	ffffe097          	auipc	ra,0xffffe
    80002b1a:	3d0080e7          	jalr	976(ra) # 80000ee6 <strlen>
}
    80002b1e:	70a2                	ld	ra,40(sp)
    80002b20:	7402                	ld	s0,32(sp)
    80002b22:	64e2                	ld	s1,24(sp)
    80002b24:	6942                	ld	s2,16(sp)
    80002b26:	69a2                	ld	s3,8(sp)
    80002b28:	6145                	addi	sp,sp,48
    80002b2a:	8082                	ret

0000000080002b2c <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002b2c:	1101                	addi	sp,sp,-32
    80002b2e:	ec06                	sd	ra,24(sp)
    80002b30:	e822                	sd	s0,16(sp)
    80002b32:	e426                	sd	s1,8(sp)
    80002b34:	1000                	addi	s0,sp,32
    80002b36:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b38:	00000097          	auipc	ra,0x0
    80002b3c:	ef2080e7          	jalr	-270(ra) # 80002a2a <argraw>
    80002b40:	c088                	sw	a0,0(s1)
  return 0;
}
    80002b42:	4501                	li	a0,0
    80002b44:	60e2                	ld	ra,24(sp)
    80002b46:	6442                	ld	s0,16(sp)
    80002b48:	64a2                	ld	s1,8(sp)
    80002b4a:	6105                	addi	sp,sp,32
    80002b4c:	8082                	ret

0000000080002b4e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002b4e:	1101                	addi	sp,sp,-32
    80002b50:	ec06                	sd	ra,24(sp)
    80002b52:	e822                	sd	s0,16(sp)
    80002b54:	e426                	sd	s1,8(sp)
    80002b56:	1000                	addi	s0,sp,32
    80002b58:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b5a:	00000097          	auipc	ra,0x0
    80002b5e:	ed0080e7          	jalr	-304(ra) # 80002a2a <argraw>
    80002b62:	e088                	sd	a0,0(s1)
  return 0;
}
    80002b64:	4501                	li	a0,0
    80002b66:	60e2                	ld	ra,24(sp)
    80002b68:	6442                	ld	s0,16(sp)
    80002b6a:	64a2                	ld	s1,8(sp)
    80002b6c:	6105                	addi	sp,sp,32
    80002b6e:	8082                	ret

0000000080002b70 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b70:	1101                	addi	sp,sp,-32
    80002b72:	ec06                	sd	ra,24(sp)
    80002b74:	e822                	sd	s0,16(sp)
    80002b76:	e426                	sd	s1,8(sp)
    80002b78:	e04a                	sd	s2,0(sp)
    80002b7a:	1000                	addi	s0,sp,32
    80002b7c:	84ae                	mv	s1,a1
    80002b7e:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002b80:	00000097          	auipc	ra,0x0
    80002b84:	eaa080e7          	jalr	-342(ra) # 80002a2a <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002b88:	864a                	mv	a2,s2
    80002b8a:	85a6                	mv	a1,s1
    80002b8c:	00000097          	auipc	ra,0x0
    80002b90:	f58080e7          	jalr	-168(ra) # 80002ae4 <fetchstr>
}
    80002b94:	60e2                	ld	ra,24(sp)
    80002b96:	6442                	ld	s0,16(sp)
    80002b98:	64a2                	ld	s1,8(sp)
    80002b9a:	6902                	ld	s2,0(sp)
    80002b9c:	6105                	addi	sp,sp,32
    80002b9e:	8082                	ret

0000000080002ba0 <syscall>:
[SYS_trace]   "trace",
};

void
syscall(void)
{
    80002ba0:	7179                	addi	sp,sp,-48
    80002ba2:	f406                	sd	ra,40(sp)
    80002ba4:	f022                	sd	s0,32(sp)
    80002ba6:	ec26                	sd	s1,24(sp)
    80002ba8:	e84a                	sd	s2,16(sp)
    80002baa:	e44e                	sd	s3,8(sp)
    80002bac:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002bae:	fffff097          	auipc	ra,0xfffff
    80002bb2:	e82080e7          	jalr	-382(ra) # 80001a30 <myproc>
    80002bb6:	84aa                	mv	s1,a0

  // 获取系统调用号
  num = p->trapframe->a7;
    80002bb8:	05853903          	ld	s2,88(a0)
    80002bbc:	0a893783          	ld	a5,168(s2)
    80002bc0:	0007899b          	sext.w	s3,a5
  // 如果系统调用编号有效（大于 0 且小于 syscalls 数组的长度，并且对应的处理函数存在）
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002bc4:	37fd                	addiw	a5,a5,-1
    80002bc6:	4759                	li	a4,22
    80002bc8:	04f76863          	bltu	a4,a5,80002c18 <syscall+0x78>
    80002bcc:	00399713          	slli	a4,s3,0x3
    80002bd0:	00006797          	auipc	a5,0x6
    80002bd4:	91878793          	addi	a5,a5,-1768 # 800084e8 <syscalls>
    80002bd8:	97ba                	add	a5,a5,a4
    80002bda:	639c                	ld	a5,0(a5)
    80002bdc:	cf95                	beqz	a5,80002c18 <syscall+0x78>
      // 调用对应的处理函数，并将返回值存储在 a0 寄存器中
      p->trapframe->a0 = syscalls[num]();                           
    80002bde:	9782                	jalr	a5
    80002be0:	06a93823          	sd	a0,112(s2)

      // 如果当前进程启用了trace跟踪，则按照题设要求打印信息
      if ((p->kama_syscall_trace >> num) & 1) {				
    80002be4:	1684b783          	ld	a5,360(s1)
    80002be8:	0137d7b3          	srl	a5,a5,s3
    80002bec:	8b85                	andi	a5,a5,1
    80002bee:	c7a1                	beqz	a5,80002c36 <syscall+0x96>
          printf("%d: syscall %s -> %d\n",p->pid, kama_syscall_names[num], p->trapframe->a0); 
    80002bf0:	6cb8                	ld	a4,88(s1)
    80002bf2:	098e                	slli	s3,s3,0x3
    80002bf4:	00006797          	auipc	a5,0x6
    80002bf8:	d3478793          	addi	a5,a5,-716 # 80008928 <kama_syscall_names>
    80002bfc:	99be                	add	s3,s3,a5
    80002bfe:	7b34                	ld	a3,112(a4)
    80002c00:	0009b603          	ld	a2,0(s3)
    80002c04:	5c8c                	lw	a1,56(s1)
    80002c06:	00005517          	auipc	a0,0x5
    80002c0a:	7ea50513          	addi	a0,a0,2026 # 800083f0 <states.1707+0x148>
    80002c0e:	ffffe097          	auipc	ra,0xffffe
    80002c12:	984080e7          	jalr	-1660(ra) # 80000592 <printf>
    80002c16:	a005                	j	80002c36 <syscall+0x96>
      }
  }
  else {
    printf("%d %s: unknown sys call %d\n",
    80002c18:	86ce                	mv	a3,s3
    80002c1a:	15848613          	addi	a2,s1,344
    80002c1e:	5c8c                	lw	a1,56(s1)
    80002c20:	00005517          	auipc	a0,0x5
    80002c24:	7e850513          	addi	a0,a0,2024 # 80008408 <states.1707+0x160>
    80002c28:	ffffe097          	auipc	ra,0xffffe
    80002c2c:	96a080e7          	jalr	-1686(ra) # 80000592 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002c30:	6cbc                	ld	a5,88(s1)
    80002c32:	577d                	li	a4,-1
    80002c34:	fbb8                	sd	a4,112(a5)
  }
}
    80002c36:	70a2                	ld	ra,40(sp)
    80002c38:	7402                	ld	s0,32(sp)
    80002c3a:	64e2                	ld	s1,24(sp)
    80002c3c:	6942                	ld	s2,16(sp)
    80002c3e:	69a2                	ld	s3,8(sp)
    80002c40:	6145                	addi	sp,sp,48
    80002c42:	8082                	ret

0000000080002c44 <sys_exit>:
#include "proc.h"
#include "sysinfo.h"

uint64
sys_exit(void)
{
    80002c44:	1101                	addi	sp,sp,-32
    80002c46:	ec06                	sd	ra,24(sp)
    80002c48:	e822                	sd	s0,16(sp)
    80002c4a:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002c4c:	fec40593          	addi	a1,s0,-20
    80002c50:	4501                	li	a0,0
    80002c52:	00000097          	auipc	ra,0x0
    80002c56:	eda080e7          	jalr	-294(ra) # 80002b2c <argint>
    return -1;
    80002c5a:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002c5c:	00054963          	bltz	a0,80002c6e <sys_exit+0x2a>
  exit(n);
    80002c60:	fec42503          	lw	a0,-20(s0)
    80002c64:	fffff097          	auipc	ra,0xfffff
    80002c68:	49e080e7          	jalr	1182(ra) # 80002102 <exit>
  return 0;  // not reached
    80002c6c:	4781                	li	a5,0
}
    80002c6e:	853e                	mv	a0,a5
    80002c70:	60e2                	ld	ra,24(sp)
    80002c72:	6442                	ld	s0,16(sp)
    80002c74:	6105                	addi	sp,sp,32
    80002c76:	8082                	ret

0000000080002c78 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c78:	1141                	addi	sp,sp,-16
    80002c7a:	e406                	sd	ra,8(sp)
    80002c7c:	e022                	sd	s0,0(sp)
    80002c7e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c80:	fffff097          	auipc	ra,0xfffff
    80002c84:	db0080e7          	jalr	-592(ra) # 80001a30 <myproc>
}
    80002c88:	5d08                	lw	a0,56(a0)
    80002c8a:	60a2                	ld	ra,8(sp)
    80002c8c:	6402                	ld	s0,0(sp)
    80002c8e:	0141                	addi	sp,sp,16
    80002c90:	8082                	ret

0000000080002c92 <sys_fork>:

uint64
sys_fork(void)
{
    80002c92:	1141                	addi	sp,sp,-16
    80002c94:	e406                	sd	ra,8(sp)
    80002c96:	e022                	sd	s0,0(sp)
    80002c98:	0800                	addi	s0,sp,16
  return fork();
    80002c9a:	fffff097          	auipc	ra,0xfffff
    80002c9e:	15a080e7          	jalr	346(ra) # 80001df4 <fork>
}
    80002ca2:	60a2                	ld	ra,8(sp)
    80002ca4:	6402                	ld	s0,0(sp)
    80002ca6:	0141                	addi	sp,sp,16
    80002ca8:	8082                	ret

0000000080002caa <sys_wait>:

uint64
sys_wait(void)
{
    80002caa:	1101                	addi	sp,sp,-32
    80002cac:	ec06                	sd	ra,24(sp)
    80002cae:	e822                	sd	s0,16(sp)
    80002cb0:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002cb2:	fe840593          	addi	a1,s0,-24
    80002cb6:	4501                	li	a0,0
    80002cb8:	00000097          	auipc	ra,0x0
    80002cbc:	e96080e7          	jalr	-362(ra) # 80002b4e <argaddr>
    80002cc0:	87aa                	mv	a5,a0
    return -1;
    80002cc2:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002cc4:	0007c863          	bltz	a5,80002cd4 <sys_wait+0x2a>
  return wait(p);
    80002cc8:	fe843503          	ld	a0,-24(s0)
    80002ccc:	fffff097          	auipc	ra,0xfffff
    80002cd0:	5fa080e7          	jalr	1530(ra) # 800022c6 <wait>
}
    80002cd4:	60e2                	ld	ra,24(sp)
    80002cd6:	6442                	ld	s0,16(sp)
    80002cd8:	6105                	addi	sp,sp,32
    80002cda:	8082                	ret

0000000080002cdc <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002cdc:	7179                	addi	sp,sp,-48
    80002cde:	f406                	sd	ra,40(sp)
    80002ce0:	f022                	sd	s0,32(sp)
    80002ce2:	ec26                	sd	s1,24(sp)
    80002ce4:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002ce6:	fdc40593          	addi	a1,s0,-36
    80002cea:	4501                	li	a0,0
    80002cec:	00000097          	auipc	ra,0x0
    80002cf0:	e40080e7          	jalr	-448(ra) # 80002b2c <argint>
    80002cf4:	87aa                	mv	a5,a0
    return -1;
    80002cf6:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002cf8:	0207c063          	bltz	a5,80002d18 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002cfc:	fffff097          	auipc	ra,0xfffff
    80002d00:	d34080e7          	jalr	-716(ra) # 80001a30 <myproc>
    80002d04:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002d06:	fdc42503          	lw	a0,-36(s0)
    80002d0a:	fffff097          	auipc	ra,0xfffff
    80002d0e:	076080e7          	jalr	118(ra) # 80001d80 <growproc>
    80002d12:	00054863          	bltz	a0,80002d22 <sys_sbrk+0x46>
    return -1;
  return addr;
    80002d16:	8526                	mv	a0,s1
}
    80002d18:	70a2                	ld	ra,40(sp)
    80002d1a:	7402                	ld	s0,32(sp)
    80002d1c:	64e2                	ld	s1,24(sp)
    80002d1e:	6145                	addi	sp,sp,48
    80002d20:	8082                	ret
    return -1;
    80002d22:	557d                	li	a0,-1
    80002d24:	bfd5                	j	80002d18 <sys_sbrk+0x3c>

0000000080002d26 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002d26:	7139                	addi	sp,sp,-64
    80002d28:	fc06                	sd	ra,56(sp)
    80002d2a:	f822                	sd	s0,48(sp)
    80002d2c:	f426                	sd	s1,40(sp)
    80002d2e:	f04a                	sd	s2,32(sp)
    80002d30:	ec4e                	sd	s3,24(sp)
    80002d32:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002d34:	fcc40593          	addi	a1,s0,-52
    80002d38:	4501                	li	a0,0
    80002d3a:	00000097          	auipc	ra,0x0
    80002d3e:	df2080e7          	jalr	-526(ra) # 80002b2c <argint>
    return -1;
    80002d42:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002d44:	06054563          	bltz	a0,80002dae <sys_sleep+0x88>
  acquire(&tickslock);
    80002d48:	00015517          	auipc	a0,0x15
    80002d4c:	c2050513          	addi	a0,a0,-992 # 80017968 <tickslock>
    80002d50:	ffffe097          	auipc	ra,0xffffe
    80002d54:	f12080e7          	jalr	-238(ra) # 80000c62 <acquire>
  ticks0 = ticks;
    80002d58:	00006917          	auipc	s2,0x6
    80002d5c:	2c892903          	lw	s2,712(s2) # 80009020 <ticks>
  while(ticks - ticks0 < n){
    80002d60:	fcc42783          	lw	a5,-52(s0)
    80002d64:	cf85                	beqz	a5,80002d9c <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d66:	00015997          	auipc	s3,0x15
    80002d6a:	c0298993          	addi	s3,s3,-1022 # 80017968 <tickslock>
    80002d6e:	00006497          	auipc	s1,0x6
    80002d72:	2b248493          	addi	s1,s1,690 # 80009020 <ticks>
    if(myproc()->killed){
    80002d76:	fffff097          	auipc	ra,0xfffff
    80002d7a:	cba080e7          	jalr	-838(ra) # 80001a30 <myproc>
    80002d7e:	591c                	lw	a5,48(a0)
    80002d80:	ef9d                	bnez	a5,80002dbe <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002d82:	85ce                	mv	a1,s3
    80002d84:	8526                	mv	a0,s1
    80002d86:	fffff097          	auipc	ra,0xfffff
    80002d8a:	4c2080e7          	jalr	1218(ra) # 80002248 <sleep>
  while(ticks - ticks0 < n){
    80002d8e:	409c                	lw	a5,0(s1)
    80002d90:	412787bb          	subw	a5,a5,s2
    80002d94:	fcc42703          	lw	a4,-52(s0)
    80002d98:	fce7efe3          	bltu	a5,a4,80002d76 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002d9c:	00015517          	auipc	a0,0x15
    80002da0:	bcc50513          	addi	a0,a0,-1076 # 80017968 <tickslock>
    80002da4:	ffffe097          	auipc	ra,0xffffe
    80002da8:	f72080e7          	jalr	-142(ra) # 80000d16 <release>
  return 0;
    80002dac:	4781                	li	a5,0
}
    80002dae:	853e                	mv	a0,a5
    80002db0:	70e2                	ld	ra,56(sp)
    80002db2:	7442                	ld	s0,48(sp)
    80002db4:	74a2                	ld	s1,40(sp)
    80002db6:	7902                	ld	s2,32(sp)
    80002db8:	69e2                	ld	s3,24(sp)
    80002dba:	6121                	addi	sp,sp,64
    80002dbc:	8082                	ret
      release(&tickslock);
    80002dbe:	00015517          	auipc	a0,0x15
    80002dc2:	baa50513          	addi	a0,a0,-1110 # 80017968 <tickslock>
    80002dc6:	ffffe097          	auipc	ra,0xffffe
    80002dca:	f50080e7          	jalr	-176(ra) # 80000d16 <release>
      return -1;
    80002dce:	57fd                	li	a5,-1
    80002dd0:	bff9                	j	80002dae <sys_sleep+0x88>

0000000080002dd2 <sys_kill>:

uint64
sys_kill(void)
{
    80002dd2:	1101                	addi	sp,sp,-32
    80002dd4:	ec06                	sd	ra,24(sp)
    80002dd6:	e822                	sd	s0,16(sp)
    80002dd8:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002dda:	fec40593          	addi	a1,s0,-20
    80002dde:	4501                	li	a0,0
    80002de0:	00000097          	auipc	ra,0x0
    80002de4:	d4c080e7          	jalr	-692(ra) # 80002b2c <argint>
    80002de8:	87aa                	mv	a5,a0
    return -1;
    80002dea:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002dec:	0007c863          	bltz	a5,80002dfc <sys_kill+0x2a>
  return kill(pid);
    80002df0:	fec42503          	lw	a0,-20(s0)
    80002df4:	fffff097          	auipc	ra,0xfffff
    80002df8:	644080e7          	jalr	1604(ra) # 80002438 <kill>
}
    80002dfc:	60e2                	ld	ra,24(sp)
    80002dfe:	6442                	ld	s0,16(sp)
    80002e00:	6105                	addi	sp,sp,32
    80002e02:	8082                	ret

0000000080002e04 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002e04:	1101                	addi	sp,sp,-32
    80002e06:	ec06                	sd	ra,24(sp)
    80002e08:	e822                	sd	s0,16(sp)
    80002e0a:	e426                	sd	s1,8(sp)
    80002e0c:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002e0e:	00015517          	auipc	a0,0x15
    80002e12:	b5a50513          	addi	a0,a0,-1190 # 80017968 <tickslock>
    80002e16:	ffffe097          	auipc	ra,0xffffe
    80002e1a:	e4c080e7          	jalr	-436(ra) # 80000c62 <acquire>
  xticks = ticks;
    80002e1e:	00006497          	auipc	s1,0x6
    80002e22:	2024a483          	lw	s1,514(s1) # 80009020 <ticks>
  release(&tickslock);
    80002e26:	00015517          	auipc	a0,0x15
    80002e2a:	b4250513          	addi	a0,a0,-1214 # 80017968 <tickslock>
    80002e2e:	ffffe097          	auipc	ra,0xffffe
    80002e32:	ee8080e7          	jalr	-280(ra) # 80000d16 <release>
  return xticks;
}
    80002e36:	02049513          	slli	a0,s1,0x20
    80002e3a:	9101                	srli	a0,a0,0x20
    80002e3c:	60e2                	ld	ra,24(sp)
    80002e3e:	6442                	ld	s0,16(sp)
    80002e40:	64a2                	ld	s1,8(sp)
    80002e42:	6105                	addi	sp,sp,32
    80002e44:	8082                	ret

0000000080002e46 <sys_trace>:

// 当前进程的系统调用跟踪掩码
uint64
sys_trace(void)
{
    80002e46:	7179                	addi	sp,sp,-48
    80002e48:	f406                	sd	ra,40(sp)
    80002e4a:	f022                	sd	s0,32(sp)
    80002e4c:	ec26                	sd	s1,24(sp)
    80002e4e:	1800                	addi	s0,sp,48
    int mask;

    if(argint(0, &mask) < 0)                // 获取用户程序传入的数据
    80002e50:	fdc40593          	addi	a1,s0,-36
    80002e54:	4501                	li	a0,0
    80002e56:	00000097          	auipc	ra,0x0
    80002e5a:	cd6080e7          	jalr	-810(ra) # 80002b2c <argint>
        return -1;
    80002e5e:	57fd                	li	a5,-1
    if(argint(0, &mask) < 0)                // 获取用户程序传入的数据
    80002e60:	00054b63          	bltz	a0,80002e76 <sys_trace+0x30>

    myproc()->kama_syscall_trace = mask;    // 设置调用进程的kama_syscall_trace掩码mask
    80002e64:	fdc42483          	lw	s1,-36(s0)
    80002e68:	fffff097          	auipc	ra,0xfffff
    80002e6c:	bc8080e7          	jalr	-1080(ra) # 80001a30 <myproc>
    80002e70:	16953423          	sd	s1,360(a0)
    return 0;
    80002e74:	4781                	li	a5,0
}
    80002e76:	853e                	mv	a0,a5
    80002e78:	70a2                	ld	ra,40(sp)
    80002e7a:	7402                	ld	s0,32(sp)
    80002e7c:	64e2                	ld	s1,24(sp)
    80002e7e:	6145                	addi	sp,sp,48
    80002e80:	8082                	ret

0000000080002e82 <sys_sysinfo>:

// 收集系统信息
uint64
sys_sysinfo(void) {
    80002e82:	7179                	addi	sp,sp,-48
    80002e84:	f406                	sd	ra,40(sp)
    80002e86:	f022                	sd	s0,32(sp)
    80002e88:	1800                	addi	s0,sp,48
    struct sysinfo info;
    kama_freebytes(&info.freemem);	// 获取空闲内存
    80002e8a:	fe040513          	addi	a0,s0,-32
    80002e8e:	ffffe097          	auipc	ra,0xffffe
    80002e92:	cf2080e7          	jalr	-782(ra) # 80000b80 <kama_freebytes>
    kama_procnum(&info.nproc);		// 获取进程数量
    80002e96:	fe840513          	addi	a0,s0,-24
    80002e9a:	fffff097          	auipc	ra,0xfffff
    80002e9e:	76a080e7          	jalr	1898(ra) # 80002604 <kama_procnum>

    //获取用户虚拟地址
    uint64 dstaddr;
    argaddr(0, &dstaddr);
    80002ea2:	fd840593          	addi	a1,s0,-40
    80002ea6:	4501                	li	a0,0
    80002ea8:	00000097          	auipc	ra,0x0
    80002eac:	ca6080e7          	jalr	-858(ra) # 80002b4e <argaddr>

    //从内核空间拷贝数据到用户空间
    if (copyout(myproc()->pagetable, dstaddr, (char*)&info, sizeof info) < 0)
    80002eb0:	fffff097          	auipc	ra,0xfffff
    80002eb4:	b80080e7          	jalr	-1152(ra) # 80001a30 <myproc>
    80002eb8:	46c1                	li	a3,16
    80002eba:	fe040613          	addi	a2,s0,-32
    80002ebe:	fd843583          	ld	a1,-40(s0)
    80002ec2:	6928                	ld	a0,80(a0)
    80002ec4:	fffff097          	auipc	ra,0xfffff
    80002ec8:	860080e7          	jalr	-1952(ra) # 80001724 <copyout>
        return -1;

    return 0;
    80002ecc:	957d                	srai	a0,a0,0x3f
    80002ece:	70a2                	ld	ra,40(sp)
    80002ed0:	7402                	ld	s0,32(sp)
    80002ed2:	6145                	addi	sp,sp,48
    80002ed4:	8082                	ret

0000000080002ed6 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002ed6:	7179                	addi	sp,sp,-48
    80002ed8:	f406                	sd	ra,40(sp)
    80002eda:	f022                	sd	s0,32(sp)
    80002edc:	ec26                	sd	s1,24(sp)
    80002ede:	e84a                	sd	s2,16(sp)
    80002ee0:	e44e                	sd	s3,8(sp)
    80002ee2:	e052                	sd	s4,0(sp)
    80002ee4:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002ee6:	00005597          	auipc	a1,0x5
    80002eea:	6c258593          	addi	a1,a1,1730 # 800085a8 <syscalls+0xc0>
    80002eee:	00015517          	auipc	a0,0x15
    80002ef2:	a9250513          	addi	a0,a0,-1390 # 80017980 <bcache>
    80002ef6:	ffffe097          	auipc	ra,0xffffe
    80002efa:	cdc080e7          	jalr	-804(ra) # 80000bd2 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002efe:	0001d797          	auipc	a5,0x1d
    80002f02:	a8278793          	addi	a5,a5,-1406 # 8001f980 <bcache+0x8000>
    80002f06:	0001d717          	auipc	a4,0x1d
    80002f0a:	ce270713          	addi	a4,a4,-798 # 8001fbe8 <bcache+0x8268>
    80002f0e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002f12:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f16:	00015497          	auipc	s1,0x15
    80002f1a:	a8248493          	addi	s1,s1,-1406 # 80017998 <bcache+0x18>
    b->next = bcache.head.next;
    80002f1e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002f20:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002f22:	00005a17          	auipc	s4,0x5
    80002f26:	68ea0a13          	addi	s4,s4,1678 # 800085b0 <syscalls+0xc8>
    b->next = bcache.head.next;
    80002f2a:	2b893783          	ld	a5,696(s2)
    80002f2e:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f30:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002f34:	85d2                	mv	a1,s4
    80002f36:	01048513          	addi	a0,s1,16
    80002f3a:	00001097          	auipc	ra,0x1
    80002f3e:	4ac080e7          	jalr	1196(ra) # 800043e6 <initsleeplock>
    bcache.head.next->prev = b;
    80002f42:	2b893783          	ld	a5,696(s2)
    80002f46:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002f48:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f4c:	45848493          	addi	s1,s1,1112
    80002f50:	fd349de3          	bne	s1,s3,80002f2a <binit+0x54>
  }
}
    80002f54:	70a2                	ld	ra,40(sp)
    80002f56:	7402                	ld	s0,32(sp)
    80002f58:	64e2                	ld	s1,24(sp)
    80002f5a:	6942                	ld	s2,16(sp)
    80002f5c:	69a2                	ld	s3,8(sp)
    80002f5e:	6a02                	ld	s4,0(sp)
    80002f60:	6145                	addi	sp,sp,48
    80002f62:	8082                	ret

0000000080002f64 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002f64:	7179                	addi	sp,sp,-48
    80002f66:	f406                	sd	ra,40(sp)
    80002f68:	f022                	sd	s0,32(sp)
    80002f6a:	ec26                	sd	s1,24(sp)
    80002f6c:	e84a                	sd	s2,16(sp)
    80002f6e:	e44e                	sd	s3,8(sp)
    80002f70:	1800                	addi	s0,sp,48
    80002f72:	89aa                	mv	s3,a0
    80002f74:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80002f76:	00015517          	auipc	a0,0x15
    80002f7a:	a0a50513          	addi	a0,a0,-1526 # 80017980 <bcache>
    80002f7e:	ffffe097          	auipc	ra,0xffffe
    80002f82:	ce4080e7          	jalr	-796(ra) # 80000c62 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002f86:	0001d497          	auipc	s1,0x1d
    80002f8a:	cb24b483          	ld	s1,-846(s1) # 8001fc38 <bcache+0x82b8>
    80002f8e:	0001d797          	auipc	a5,0x1d
    80002f92:	c5a78793          	addi	a5,a5,-934 # 8001fbe8 <bcache+0x8268>
    80002f96:	02f48f63          	beq	s1,a5,80002fd4 <bread+0x70>
    80002f9a:	873e                	mv	a4,a5
    80002f9c:	a021                	j	80002fa4 <bread+0x40>
    80002f9e:	68a4                	ld	s1,80(s1)
    80002fa0:	02e48a63          	beq	s1,a4,80002fd4 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002fa4:	449c                	lw	a5,8(s1)
    80002fa6:	ff379ce3          	bne	a5,s3,80002f9e <bread+0x3a>
    80002faa:	44dc                	lw	a5,12(s1)
    80002fac:	ff2799e3          	bne	a5,s2,80002f9e <bread+0x3a>
      b->refcnt++;
    80002fb0:	40bc                	lw	a5,64(s1)
    80002fb2:	2785                	addiw	a5,a5,1
    80002fb4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002fb6:	00015517          	auipc	a0,0x15
    80002fba:	9ca50513          	addi	a0,a0,-1590 # 80017980 <bcache>
    80002fbe:	ffffe097          	auipc	ra,0xffffe
    80002fc2:	d58080e7          	jalr	-680(ra) # 80000d16 <release>
      acquiresleep(&b->lock);
    80002fc6:	01048513          	addi	a0,s1,16
    80002fca:	00001097          	auipc	ra,0x1
    80002fce:	456080e7          	jalr	1110(ra) # 80004420 <acquiresleep>
      return b;
    80002fd2:	a8b9                	j	80003030 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fd4:	0001d497          	auipc	s1,0x1d
    80002fd8:	c5c4b483          	ld	s1,-932(s1) # 8001fc30 <bcache+0x82b0>
    80002fdc:	0001d797          	auipc	a5,0x1d
    80002fe0:	c0c78793          	addi	a5,a5,-1012 # 8001fbe8 <bcache+0x8268>
    80002fe4:	00f48863          	beq	s1,a5,80002ff4 <bread+0x90>
    80002fe8:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002fea:	40bc                	lw	a5,64(s1)
    80002fec:	cf81                	beqz	a5,80003004 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fee:	64a4                	ld	s1,72(s1)
    80002ff0:	fee49de3          	bne	s1,a4,80002fea <bread+0x86>
  panic("bget: no buffers");
    80002ff4:	00005517          	auipc	a0,0x5
    80002ff8:	5c450513          	addi	a0,a0,1476 # 800085b8 <syscalls+0xd0>
    80002ffc:	ffffd097          	auipc	ra,0xffffd
    80003000:	54c080e7          	jalr	1356(ra) # 80000548 <panic>
      b->dev = dev;
    80003004:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80003008:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    8000300c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003010:	4785                	li	a5,1
    80003012:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003014:	00015517          	auipc	a0,0x15
    80003018:	96c50513          	addi	a0,a0,-1684 # 80017980 <bcache>
    8000301c:	ffffe097          	auipc	ra,0xffffe
    80003020:	cfa080e7          	jalr	-774(ra) # 80000d16 <release>
      acquiresleep(&b->lock);
    80003024:	01048513          	addi	a0,s1,16
    80003028:	00001097          	auipc	ra,0x1
    8000302c:	3f8080e7          	jalr	1016(ra) # 80004420 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003030:	409c                	lw	a5,0(s1)
    80003032:	cb89                	beqz	a5,80003044 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003034:	8526                	mv	a0,s1
    80003036:	70a2                	ld	ra,40(sp)
    80003038:	7402                	ld	s0,32(sp)
    8000303a:	64e2                	ld	s1,24(sp)
    8000303c:	6942                	ld	s2,16(sp)
    8000303e:	69a2                	ld	s3,8(sp)
    80003040:	6145                	addi	sp,sp,48
    80003042:	8082                	ret
    virtio_disk_rw(b, 0);
    80003044:	4581                	li	a1,0
    80003046:	8526                	mv	a0,s1
    80003048:	00003097          	auipc	ra,0x3
    8000304c:	f34080e7          	jalr	-204(ra) # 80005f7c <virtio_disk_rw>
    b->valid = 1;
    80003050:	4785                	li	a5,1
    80003052:	c09c                	sw	a5,0(s1)
  return b;
    80003054:	b7c5                	j	80003034 <bread+0xd0>

0000000080003056 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003056:	1101                	addi	sp,sp,-32
    80003058:	ec06                	sd	ra,24(sp)
    8000305a:	e822                	sd	s0,16(sp)
    8000305c:	e426                	sd	s1,8(sp)
    8000305e:	1000                	addi	s0,sp,32
    80003060:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003062:	0541                	addi	a0,a0,16
    80003064:	00001097          	auipc	ra,0x1
    80003068:	456080e7          	jalr	1110(ra) # 800044ba <holdingsleep>
    8000306c:	cd01                	beqz	a0,80003084 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000306e:	4585                	li	a1,1
    80003070:	8526                	mv	a0,s1
    80003072:	00003097          	auipc	ra,0x3
    80003076:	f0a080e7          	jalr	-246(ra) # 80005f7c <virtio_disk_rw>
}
    8000307a:	60e2                	ld	ra,24(sp)
    8000307c:	6442                	ld	s0,16(sp)
    8000307e:	64a2                	ld	s1,8(sp)
    80003080:	6105                	addi	sp,sp,32
    80003082:	8082                	ret
    panic("bwrite");
    80003084:	00005517          	auipc	a0,0x5
    80003088:	54c50513          	addi	a0,a0,1356 # 800085d0 <syscalls+0xe8>
    8000308c:	ffffd097          	auipc	ra,0xffffd
    80003090:	4bc080e7          	jalr	1212(ra) # 80000548 <panic>

0000000080003094 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003094:	1101                	addi	sp,sp,-32
    80003096:	ec06                	sd	ra,24(sp)
    80003098:	e822                	sd	s0,16(sp)
    8000309a:	e426                	sd	s1,8(sp)
    8000309c:	e04a                	sd	s2,0(sp)
    8000309e:	1000                	addi	s0,sp,32
    800030a0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800030a2:	01050913          	addi	s2,a0,16
    800030a6:	854a                	mv	a0,s2
    800030a8:	00001097          	auipc	ra,0x1
    800030ac:	412080e7          	jalr	1042(ra) # 800044ba <holdingsleep>
    800030b0:	c92d                	beqz	a0,80003122 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800030b2:	854a                	mv	a0,s2
    800030b4:	00001097          	auipc	ra,0x1
    800030b8:	3c2080e7          	jalr	962(ra) # 80004476 <releasesleep>

  acquire(&bcache.lock);
    800030bc:	00015517          	auipc	a0,0x15
    800030c0:	8c450513          	addi	a0,a0,-1852 # 80017980 <bcache>
    800030c4:	ffffe097          	auipc	ra,0xffffe
    800030c8:	b9e080e7          	jalr	-1122(ra) # 80000c62 <acquire>
  b->refcnt--;
    800030cc:	40bc                	lw	a5,64(s1)
    800030ce:	37fd                	addiw	a5,a5,-1
    800030d0:	0007871b          	sext.w	a4,a5
    800030d4:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800030d6:	eb05                	bnez	a4,80003106 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800030d8:	68bc                	ld	a5,80(s1)
    800030da:	64b8                	ld	a4,72(s1)
    800030dc:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800030de:	64bc                	ld	a5,72(s1)
    800030e0:	68b8                	ld	a4,80(s1)
    800030e2:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800030e4:	0001d797          	auipc	a5,0x1d
    800030e8:	89c78793          	addi	a5,a5,-1892 # 8001f980 <bcache+0x8000>
    800030ec:	2b87b703          	ld	a4,696(a5)
    800030f0:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800030f2:	0001d717          	auipc	a4,0x1d
    800030f6:	af670713          	addi	a4,a4,-1290 # 8001fbe8 <bcache+0x8268>
    800030fa:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800030fc:	2b87b703          	ld	a4,696(a5)
    80003100:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003102:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003106:	00015517          	auipc	a0,0x15
    8000310a:	87a50513          	addi	a0,a0,-1926 # 80017980 <bcache>
    8000310e:	ffffe097          	auipc	ra,0xffffe
    80003112:	c08080e7          	jalr	-1016(ra) # 80000d16 <release>
}
    80003116:	60e2                	ld	ra,24(sp)
    80003118:	6442                	ld	s0,16(sp)
    8000311a:	64a2                	ld	s1,8(sp)
    8000311c:	6902                	ld	s2,0(sp)
    8000311e:	6105                	addi	sp,sp,32
    80003120:	8082                	ret
    panic("brelse");
    80003122:	00005517          	auipc	a0,0x5
    80003126:	4b650513          	addi	a0,a0,1206 # 800085d8 <syscalls+0xf0>
    8000312a:	ffffd097          	auipc	ra,0xffffd
    8000312e:	41e080e7          	jalr	1054(ra) # 80000548 <panic>

0000000080003132 <bpin>:

void
bpin(struct buf *b) {
    80003132:	1101                	addi	sp,sp,-32
    80003134:	ec06                	sd	ra,24(sp)
    80003136:	e822                	sd	s0,16(sp)
    80003138:	e426                	sd	s1,8(sp)
    8000313a:	1000                	addi	s0,sp,32
    8000313c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000313e:	00015517          	auipc	a0,0x15
    80003142:	84250513          	addi	a0,a0,-1982 # 80017980 <bcache>
    80003146:	ffffe097          	auipc	ra,0xffffe
    8000314a:	b1c080e7          	jalr	-1252(ra) # 80000c62 <acquire>
  b->refcnt++;
    8000314e:	40bc                	lw	a5,64(s1)
    80003150:	2785                	addiw	a5,a5,1
    80003152:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003154:	00015517          	auipc	a0,0x15
    80003158:	82c50513          	addi	a0,a0,-2004 # 80017980 <bcache>
    8000315c:	ffffe097          	auipc	ra,0xffffe
    80003160:	bba080e7          	jalr	-1094(ra) # 80000d16 <release>
}
    80003164:	60e2                	ld	ra,24(sp)
    80003166:	6442                	ld	s0,16(sp)
    80003168:	64a2                	ld	s1,8(sp)
    8000316a:	6105                	addi	sp,sp,32
    8000316c:	8082                	ret

000000008000316e <bunpin>:

void
bunpin(struct buf *b) {
    8000316e:	1101                	addi	sp,sp,-32
    80003170:	ec06                	sd	ra,24(sp)
    80003172:	e822                	sd	s0,16(sp)
    80003174:	e426                	sd	s1,8(sp)
    80003176:	1000                	addi	s0,sp,32
    80003178:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000317a:	00015517          	auipc	a0,0x15
    8000317e:	80650513          	addi	a0,a0,-2042 # 80017980 <bcache>
    80003182:	ffffe097          	auipc	ra,0xffffe
    80003186:	ae0080e7          	jalr	-1312(ra) # 80000c62 <acquire>
  b->refcnt--;
    8000318a:	40bc                	lw	a5,64(s1)
    8000318c:	37fd                	addiw	a5,a5,-1
    8000318e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003190:	00014517          	auipc	a0,0x14
    80003194:	7f050513          	addi	a0,a0,2032 # 80017980 <bcache>
    80003198:	ffffe097          	auipc	ra,0xffffe
    8000319c:	b7e080e7          	jalr	-1154(ra) # 80000d16 <release>
}
    800031a0:	60e2                	ld	ra,24(sp)
    800031a2:	6442                	ld	s0,16(sp)
    800031a4:	64a2                	ld	s1,8(sp)
    800031a6:	6105                	addi	sp,sp,32
    800031a8:	8082                	ret

00000000800031aa <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800031aa:	1101                	addi	sp,sp,-32
    800031ac:	ec06                	sd	ra,24(sp)
    800031ae:	e822                	sd	s0,16(sp)
    800031b0:	e426                	sd	s1,8(sp)
    800031b2:	e04a                	sd	s2,0(sp)
    800031b4:	1000                	addi	s0,sp,32
    800031b6:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800031b8:	00d5d59b          	srliw	a1,a1,0xd
    800031bc:	0001d797          	auipc	a5,0x1d
    800031c0:	ea07a783          	lw	a5,-352(a5) # 8002005c <sb+0x1c>
    800031c4:	9dbd                	addw	a1,a1,a5
    800031c6:	00000097          	auipc	ra,0x0
    800031ca:	d9e080e7          	jalr	-610(ra) # 80002f64 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800031ce:	0074f713          	andi	a4,s1,7
    800031d2:	4785                	li	a5,1
    800031d4:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800031d8:	14ce                	slli	s1,s1,0x33
    800031da:	90d9                	srli	s1,s1,0x36
    800031dc:	00950733          	add	a4,a0,s1
    800031e0:	05874703          	lbu	a4,88(a4)
    800031e4:	00e7f6b3          	and	a3,a5,a4
    800031e8:	c69d                	beqz	a3,80003216 <bfree+0x6c>
    800031ea:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800031ec:	94aa                	add	s1,s1,a0
    800031ee:	fff7c793          	not	a5,a5
    800031f2:	8ff9                	and	a5,a5,a4
    800031f4:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800031f8:	00001097          	auipc	ra,0x1
    800031fc:	100080e7          	jalr	256(ra) # 800042f8 <log_write>
  brelse(bp);
    80003200:	854a                	mv	a0,s2
    80003202:	00000097          	auipc	ra,0x0
    80003206:	e92080e7          	jalr	-366(ra) # 80003094 <brelse>
}
    8000320a:	60e2                	ld	ra,24(sp)
    8000320c:	6442                	ld	s0,16(sp)
    8000320e:	64a2                	ld	s1,8(sp)
    80003210:	6902                	ld	s2,0(sp)
    80003212:	6105                	addi	sp,sp,32
    80003214:	8082                	ret
    panic("freeing free block");
    80003216:	00005517          	auipc	a0,0x5
    8000321a:	3ca50513          	addi	a0,a0,970 # 800085e0 <syscalls+0xf8>
    8000321e:	ffffd097          	auipc	ra,0xffffd
    80003222:	32a080e7          	jalr	810(ra) # 80000548 <panic>

0000000080003226 <balloc>:
{
    80003226:	711d                	addi	sp,sp,-96
    80003228:	ec86                	sd	ra,88(sp)
    8000322a:	e8a2                	sd	s0,80(sp)
    8000322c:	e4a6                	sd	s1,72(sp)
    8000322e:	e0ca                	sd	s2,64(sp)
    80003230:	fc4e                	sd	s3,56(sp)
    80003232:	f852                	sd	s4,48(sp)
    80003234:	f456                	sd	s5,40(sp)
    80003236:	f05a                	sd	s6,32(sp)
    80003238:	ec5e                	sd	s7,24(sp)
    8000323a:	e862                	sd	s8,16(sp)
    8000323c:	e466                	sd	s9,8(sp)
    8000323e:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003240:	0001d797          	auipc	a5,0x1d
    80003244:	e047a783          	lw	a5,-508(a5) # 80020044 <sb+0x4>
    80003248:	cbd1                	beqz	a5,800032dc <balloc+0xb6>
    8000324a:	8baa                	mv	s7,a0
    8000324c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000324e:	0001db17          	auipc	s6,0x1d
    80003252:	df2b0b13          	addi	s6,s6,-526 # 80020040 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003256:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003258:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000325a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000325c:	6c89                	lui	s9,0x2
    8000325e:	a831                	j	8000327a <balloc+0x54>
    brelse(bp);
    80003260:	854a                	mv	a0,s2
    80003262:	00000097          	auipc	ra,0x0
    80003266:	e32080e7          	jalr	-462(ra) # 80003094 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000326a:	015c87bb          	addw	a5,s9,s5
    8000326e:	00078a9b          	sext.w	s5,a5
    80003272:	004b2703          	lw	a4,4(s6)
    80003276:	06eaf363          	bgeu	s5,a4,800032dc <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    8000327a:	41fad79b          	sraiw	a5,s5,0x1f
    8000327e:	0137d79b          	srliw	a5,a5,0x13
    80003282:	015787bb          	addw	a5,a5,s5
    80003286:	40d7d79b          	sraiw	a5,a5,0xd
    8000328a:	01cb2583          	lw	a1,28(s6)
    8000328e:	9dbd                	addw	a1,a1,a5
    80003290:	855e                	mv	a0,s7
    80003292:	00000097          	auipc	ra,0x0
    80003296:	cd2080e7          	jalr	-814(ra) # 80002f64 <bread>
    8000329a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000329c:	004b2503          	lw	a0,4(s6)
    800032a0:	000a849b          	sext.w	s1,s5
    800032a4:	8662                	mv	a2,s8
    800032a6:	faa4fde3          	bgeu	s1,a0,80003260 <balloc+0x3a>
      m = 1 << (bi % 8);
    800032aa:	41f6579b          	sraiw	a5,a2,0x1f
    800032ae:	01d7d69b          	srliw	a3,a5,0x1d
    800032b2:	00c6873b          	addw	a4,a3,a2
    800032b6:	00777793          	andi	a5,a4,7
    800032ba:	9f95                	subw	a5,a5,a3
    800032bc:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800032c0:	4037571b          	sraiw	a4,a4,0x3
    800032c4:	00e906b3          	add	a3,s2,a4
    800032c8:	0586c683          	lbu	a3,88(a3)
    800032cc:	00d7f5b3          	and	a1,a5,a3
    800032d0:	cd91                	beqz	a1,800032ec <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032d2:	2605                	addiw	a2,a2,1
    800032d4:	2485                	addiw	s1,s1,1
    800032d6:	fd4618e3          	bne	a2,s4,800032a6 <balloc+0x80>
    800032da:	b759                	j	80003260 <balloc+0x3a>
  panic("balloc: out of blocks");
    800032dc:	00005517          	auipc	a0,0x5
    800032e0:	31c50513          	addi	a0,a0,796 # 800085f8 <syscalls+0x110>
    800032e4:	ffffd097          	auipc	ra,0xffffd
    800032e8:	264080e7          	jalr	612(ra) # 80000548 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800032ec:	974a                	add	a4,a4,s2
    800032ee:	8fd5                	or	a5,a5,a3
    800032f0:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800032f4:	854a                	mv	a0,s2
    800032f6:	00001097          	auipc	ra,0x1
    800032fa:	002080e7          	jalr	2(ra) # 800042f8 <log_write>
        brelse(bp);
    800032fe:	854a                	mv	a0,s2
    80003300:	00000097          	auipc	ra,0x0
    80003304:	d94080e7          	jalr	-620(ra) # 80003094 <brelse>
  bp = bread(dev, bno);
    80003308:	85a6                	mv	a1,s1
    8000330a:	855e                	mv	a0,s7
    8000330c:	00000097          	auipc	ra,0x0
    80003310:	c58080e7          	jalr	-936(ra) # 80002f64 <bread>
    80003314:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003316:	40000613          	li	a2,1024
    8000331a:	4581                	li	a1,0
    8000331c:	05850513          	addi	a0,a0,88
    80003320:	ffffe097          	auipc	ra,0xffffe
    80003324:	a3e080e7          	jalr	-1474(ra) # 80000d5e <memset>
  log_write(bp);
    80003328:	854a                	mv	a0,s2
    8000332a:	00001097          	auipc	ra,0x1
    8000332e:	fce080e7          	jalr	-50(ra) # 800042f8 <log_write>
  brelse(bp);
    80003332:	854a                	mv	a0,s2
    80003334:	00000097          	auipc	ra,0x0
    80003338:	d60080e7          	jalr	-672(ra) # 80003094 <brelse>
}
    8000333c:	8526                	mv	a0,s1
    8000333e:	60e6                	ld	ra,88(sp)
    80003340:	6446                	ld	s0,80(sp)
    80003342:	64a6                	ld	s1,72(sp)
    80003344:	6906                	ld	s2,64(sp)
    80003346:	79e2                	ld	s3,56(sp)
    80003348:	7a42                	ld	s4,48(sp)
    8000334a:	7aa2                	ld	s5,40(sp)
    8000334c:	7b02                	ld	s6,32(sp)
    8000334e:	6be2                	ld	s7,24(sp)
    80003350:	6c42                	ld	s8,16(sp)
    80003352:	6ca2                	ld	s9,8(sp)
    80003354:	6125                	addi	sp,sp,96
    80003356:	8082                	ret

0000000080003358 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003358:	7179                	addi	sp,sp,-48
    8000335a:	f406                	sd	ra,40(sp)
    8000335c:	f022                	sd	s0,32(sp)
    8000335e:	ec26                	sd	s1,24(sp)
    80003360:	e84a                	sd	s2,16(sp)
    80003362:	e44e                	sd	s3,8(sp)
    80003364:	e052                	sd	s4,0(sp)
    80003366:	1800                	addi	s0,sp,48
    80003368:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000336a:	47ad                	li	a5,11
    8000336c:	04b7fe63          	bgeu	a5,a1,800033c8 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003370:	ff45849b          	addiw	s1,a1,-12
    80003374:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003378:	0ff00793          	li	a5,255
    8000337c:	0ae7e363          	bltu	a5,a4,80003422 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003380:	08052583          	lw	a1,128(a0)
    80003384:	c5ad                	beqz	a1,800033ee <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003386:	00092503          	lw	a0,0(s2)
    8000338a:	00000097          	auipc	ra,0x0
    8000338e:	bda080e7          	jalr	-1062(ra) # 80002f64 <bread>
    80003392:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003394:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003398:	02049593          	slli	a1,s1,0x20
    8000339c:	9181                	srli	a1,a1,0x20
    8000339e:	058a                	slli	a1,a1,0x2
    800033a0:	00b784b3          	add	s1,a5,a1
    800033a4:	0004a983          	lw	s3,0(s1)
    800033a8:	04098d63          	beqz	s3,80003402 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800033ac:	8552                	mv	a0,s4
    800033ae:	00000097          	auipc	ra,0x0
    800033b2:	ce6080e7          	jalr	-794(ra) # 80003094 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800033b6:	854e                	mv	a0,s3
    800033b8:	70a2                	ld	ra,40(sp)
    800033ba:	7402                	ld	s0,32(sp)
    800033bc:	64e2                	ld	s1,24(sp)
    800033be:	6942                	ld	s2,16(sp)
    800033c0:	69a2                	ld	s3,8(sp)
    800033c2:	6a02                	ld	s4,0(sp)
    800033c4:	6145                	addi	sp,sp,48
    800033c6:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800033c8:	02059493          	slli	s1,a1,0x20
    800033cc:	9081                	srli	s1,s1,0x20
    800033ce:	048a                	slli	s1,s1,0x2
    800033d0:	94aa                	add	s1,s1,a0
    800033d2:	0504a983          	lw	s3,80(s1)
    800033d6:	fe0990e3          	bnez	s3,800033b6 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800033da:	4108                	lw	a0,0(a0)
    800033dc:	00000097          	auipc	ra,0x0
    800033e0:	e4a080e7          	jalr	-438(ra) # 80003226 <balloc>
    800033e4:	0005099b          	sext.w	s3,a0
    800033e8:	0534a823          	sw	s3,80(s1)
    800033ec:	b7e9                	j	800033b6 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800033ee:	4108                	lw	a0,0(a0)
    800033f0:	00000097          	auipc	ra,0x0
    800033f4:	e36080e7          	jalr	-458(ra) # 80003226 <balloc>
    800033f8:	0005059b          	sext.w	a1,a0
    800033fc:	08b92023          	sw	a1,128(s2)
    80003400:	b759                	j	80003386 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003402:	00092503          	lw	a0,0(s2)
    80003406:	00000097          	auipc	ra,0x0
    8000340a:	e20080e7          	jalr	-480(ra) # 80003226 <balloc>
    8000340e:	0005099b          	sext.w	s3,a0
    80003412:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003416:	8552                	mv	a0,s4
    80003418:	00001097          	auipc	ra,0x1
    8000341c:	ee0080e7          	jalr	-288(ra) # 800042f8 <log_write>
    80003420:	b771                	j	800033ac <bmap+0x54>
  panic("bmap: out of range");
    80003422:	00005517          	auipc	a0,0x5
    80003426:	1ee50513          	addi	a0,a0,494 # 80008610 <syscalls+0x128>
    8000342a:	ffffd097          	auipc	ra,0xffffd
    8000342e:	11e080e7          	jalr	286(ra) # 80000548 <panic>

0000000080003432 <iget>:
{
    80003432:	7179                	addi	sp,sp,-48
    80003434:	f406                	sd	ra,40(sp)
    80003436:	f022                	sd	s0,32(sp)
    80003438:	ec26                	sd	s1,24(sp)
    8000343a:	e84a                	sd	s2,16(sp)
    8000343c:	e44e                	sd	s3,8(sp)
    8000343e:	e052                	sd	s4,0(sp)
    80003440:	1800                	addi	s0,sp,48
    80003442:	89aa                	mv	s3,a0
    80003444:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003446:	0001d517          	auipc	a0,0x1d
    8000344a:	c1a50513          	addi	a0,a0,-998 # 80020060 <icache>
    8000344e:	ffffe097          	auipc	ra,0xffffe
    80003452:	814080e7          	jalr	-2028(ra) # 80000c62 <acquire>
  empty = 0;
    80003456:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003458:	0001d497          	auipc	s1,0x1d
    8000345c:	c2048493          	addi	s1,s1,-992 # 80020078 <icache+0x18>
    80003460:	0001e697          	auipc	a3,0x1e
    80003464:	6a868693          	addi	a3,a3,1704 # 80021b08 <log>
    80003468:	a039                	j	80003476 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000346a:	02090b63          	beqz	s2,800034a0 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000346e:	08848493          	addi	s1,s1,136
    80003472:	02d48a63          	beq	s1,a3,800034a6 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003476:	449c                	lw	a5,8(s1)
    80003478:	fef059e3          	blez	a5,8000346a <iget+0x38>
    8000347c:	4098                	lw	a4,0(s1)
    8000347e:	ff3716e3          	bne	a4,s3,8000346a <iget+0x38>
    80003482:	40d8                	lw	a4,4(s1)
    80003484:	ff4713e3          	bne	a4,s4,8000346a <iget+0x38>
      ip->ref++;
    80003488:	2785                	addiw	a5,a5,1
    8000348a:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    8000348c:	0001d517          	auipc	a0,0x1d
    80003490:	bd450513          	addi	a0,a0,-1068 # 80020060 <icache>
    80003494:	ffffe097          	auipc	ra,0xffffe
    80003498:	882080e7          	jalr	-1918(ra) # 80000d16 <release>
      return ip;
    8000349c:	8926                	mv	s2,s1
    8000349e:	a03d                	j	800034cc <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034a0:	f7f9                	bnez	a5,8000346e <iget+0x3c>
    800034a2:	8926                	mv	s2,s1
    800034a4:	b7e9                	j	8000346e <iget+0x3c>
  if(empty == 0)
    800034a6:	02090c63          	beqz	s2,800034de <iget+0xac>
  ip->dev = dev;
    800034aa:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800034ae:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800034b2:	4785                	li	a5,1
    800034b4:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800034b8:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    800034bc:	0001d517          	auipc	a0,0x1d
    800034c0:	ba450513          	addi	a0,a0,-1116 # 80020060 <icache>
    800034c4:	ffffe097          	auipc	ra,0xffffe
    800034c8:	852080e7          	jalr	-1966(ra) # 80000d16 <release>
}
    800034cc:	854a                	mv	a0,s2
    800034ce:	70a2                	ld	ra,40(sp)
    800034d0:	7402                	ld	s0,32(sp)
    800034d2:	64e2                	ld	s1,24(sp)
    800034d4:	6942                	ld	s2,16(sp)
    800034d6:	69a2                	ld	s3,8(sp)
    800034d8:	6a02                	ld	s4,0(sp)
    800034da:	6145                	addi	sp,sp,48
    800034dc:	8082                	ret
    panic("iget: no inodes");
    800034de:	00005517          	auipc	a0,0x5
    800034e2:	14a50513          	addi	a0,a0,330 # 80008628 <syscalls+0x140>
    800034e6:	ffffd097          	auipc	ra,0xffffd
    800034ea:	062080e7          	jalr	98(ra) # 80000548 <panic>

00000000800034ee <fsinit>:
fsinit(int dev) {
    800034ee:	7179                	addi	sp,sp,-48
    800034f0:	f406                	sd	ra,40(sp)
    800034f2:	f022                	sd	s0,32(sp)
    800034f4:	ec26                	sd	s1,24(sp)
    800034f6:	e84a                	sd	s2,16(sp)
    800034f8:	e44e                	sd	s3,8(sp)
    800034fa:	1800                	addi	s0,sp,48
    800034fc:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800034fe:	4585                	li	a1,1
    80003500:	00000097          	auipc	ra,0x0
    80003504:	a64080e7          	jalr	-1436(ra) # 80002f64 <bread>
    80003508:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000350a:	0001d997          	auipc	s3,0x1d
    8000350e:	b3698993          	addi	s3,s3,-1226 # 80020040 <sb>
    80003512:	02000613          	li	a2,32
    80003516:	05850593          	addi	a1,a0,88
    8000351a:	854e                	mv	a0,s3
    8000351c:	ffffe097          	auipc	ra,0xffffe
    80003520:	8a2080e7          	jalr	-1886(ra) # 80000dbe <memmove>
  brelse(bp);
    80003524:	8526                	mv	a0,s1
    80003526:	00000097          	auipc	ra,0x0
    8000352a:	b6e080e7          	jalr	-1170(ra) # 80003094 <brelse>
  if(sb.magic != FSMAGIC)
    8000352e:	0009a703          	lw	a4,0(s3)
    80003532:	102037b7          	lui	a5,0x10203
    80003536:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000353a:	02f71263          	bne	a4,a5,8000355e <fsinit+0x70>
  initlog(dev, &sb);
    8000353e:	0001d597          	auipc	a1,0x1d
    80003542:	b0258593          	addi	a1,a1,-1278 # 80020040 <sb>
    80003546:	854a                	mv	a0,s2
    80003548:	00001097          	auipc	ra,0x1
    8000354c:	b38080e7          	jalr	-1224(ra) # 80004080 <initlog>
}
    80003550:	70a2                	ld	ra,40(sp)
    80003552:	7402                	ld	s0,32(sp)
    80003554:	64e2                	ld	s1,24(sp)
    80003556:	6942                	ld	s2,16(sp)
    80003558:	69a2                	ld	s3,8(sp)
    8000355a:	6145                	addi	sp,sp,48
    8000355c:	8082                	ret
    panic("invalid file system");
    8000355e:	00005517          	auipc	a0,0x5
    80003562:	0da50513          	addi	a0,a0,218 # 80008638 <syscalls+0x150>
    80003566:	ffffd097          	auipc	ra,0xffffd
    8000356a:	fe2080e7          	jalr	-30(ra) # 80000548 <panic>

000000008000356e <iinit>:
{
    8000356e:	7179                	addi	sp,sp,-48
    80003570:	f406                	sd	ra,40(sp)
    80003572:	f022                	sd	s0,32(sp)
    80003574:	ec26                	sd	s1,24(sp)
    80003576:	e84a                	sd	s2,16(sp)
    80003578:	e44e                	sd	s3,8(sp)
    8000357a:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    8000357c:	00005597          	auipc	a1,0x5
    80003580:	0d458593          	addi	a1,a1,212 # 80008650 <syscalls+0x168>
    80003584:	0001d517          	auipc	a0,0x1d
    80003588:	adc50513          	addi	a0,a0,-1316 # 80020060 <icache>
    8000358c:	ffffd097          	auipc	ra,0xffffd
    80003590:	646080e7          	jalr	1606(ra) # 80000bd2 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003594:	0001d497          	auipc	s1,0x1d
    80003598:	af448493          	addi	s1,s1,-1292 # 80020088 <icache+0x28>
    8000359c:	0001e997          	auipc	s3,0x1e
    800035a0:	57c98993          	addi	s3,s3,1404 # 80021b18 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    800035a4:	00005917          	auipc	s2,0x5
    800035a8:	0b490913          	addi	s2,s2,180 # 80008658 <syscalls+0x170>
    800035ac:	85ca                	mv	a1,s2
    800035ae:	8526                	mv	a0,s1
    800035b0:	00001097          	auipc	ra,0x1
    800035b4:	e36080e7          	jalr	-458(ra) # 800043e6 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800035b8:	08848493          	addi	s1,s1,136
    800035bc:	ff3498e3          	bne	s1,s3,800035ac <iinit+0x3e>
}
    800035c0:	70a2                	ld	ra,40(sp)
    800035c2:	7402                	ld	s0,32(sp)
    800035c4:	64e2                	ld	s1,24(sp)
    800035c6:	6942                	ld	s2,16(sp)
    800035c8:	69a2                	ld	s3,8(sp)
    800035ca:	6145                	addi	sp,sp,48
    800035cc:	8082                	ret

00000000800035ce <ialloc>:
{
    800035ce:	715d                	addi	sp,sp,-80
    800035d0:	e486                	sd	ra,72(sp)
    800035d2:	e0a2                	sd	s0,64(sp)
    800035d4:	fc26                	sd	s1,56(sp)
    800035d6:	f84a                	sd	s2,48(sp)
    800035d8:	f44e                	sd	s3,40(sp)
    800035da:	f052                	sd	s4,32(sp)
    800035dc:	ec56                	sd	s5,24(sp)
    800035de:	e85a                	sd	s6,16(sp)
    800035e0:	e45e                	sd	s7,8(sp)
    800035e2:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800035e4:	0001d717          	auipc	a4,0x1d
    800035e8:	a6872703          	lw	a4,-1432(a4) # 8002004c <sb+0xc>
    800035ec:	4785                	li	a5,1
    800035ee:	04e7fa63          	bgeu	a5,a4,80003642 <ialloc+0x74>
    800035f2:	8aaa                	mv	s5,a0
    800035f4:	8bae                	mv	s7,a1
    800035f6:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800035f8:	0001da17          	auipc	s4,0x1d
    800035fc:	a48a0a13          	addi	s4,s4,-1464 # 80020040 <sb>
    80003600:	00048b1b          	sext.w	s6,s1
    80003604:	0044d593          	srli	a1,s1,0x4
    80003608:	018a2783          	lw	a5,24(s4)
    8000360c:	9dbd                	addw	a1,a1,a5
    8000360e:	8556                	mv	a0,s5
    80003610:	00000097          	auipc	ra,0x0
    80003614:	954080e7          	jalr	-1708(ra) # 80002f64 <bread>
    80003618:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000361a:	05850993          	addi	s3,a0,88
    8000361e:	00f4f793          	andi	a5,s1,15
    80003622:	079a                	slli	a5,a5,0x6
    80003624:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003626:	00099783          	lh	a5,0(s3)
    8000362a:	c785                	beqz	a5,80003652 <ialloc+0x84>
    brelse(bp);
    8000362c:	00000097          	auipc	ra,0x0
    80003630:	a68080e7          	jalr	-1432(ra) # 80003094 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003634:	0485                	addi	s1,s1,1
    80003636:	00ca2703          	lw	a4,12(s4)
    8000363a:	0004879b          	sext.w	a5,s1
    8000363e:	fce7e1e3          	bltu	a5,a4,80003600 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003642:	00005517          	auipc	a0,0x5
    80003646:	01e50513          	addi	a0,a0,30 # 80008660 <syscalls+0x178>
    8000364a:	ffffd097          	auipc	ra,0xffffd
    8000364e:	efe080e7          	jalr	-258(ra) # 80000548 <panic>
      memset(dip, 0, sizeof(*dip));
    80003652:	04000613          	li	a2,64
    80003656:	4581                	li	a1,0
    80003658:	854e                	mv	a0,s3
    8000365a:	ffffd097          	auipc	ra,0xffffd
    8000365e:	704080e7          	jalr	1796(ra) # 80000d5e <memset>
      dip->type = type;
    80003662:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003666:	854a                	mv	a0,s2
    80003668:	00001097          	auipc	ra,0x1
    8000366c:	c90080e7          	jalr	-880(ra) # 800042f8 <log_write>
      brelse(bp);
    80003670:	854a                	mv	a0,s2
    80003672:	00000097          	auipc	ra,0x0
    80003676:	a22080e7          	jalr	-1502(ra) # 80003094 <brelse>
      return iget(dev, inum);
    8000367a:	85da                	mv	a1,s6
    8000367c:	8556                	mv	a0,s5
    8000367e:	00000097          	auipc	ra,0x0
    80003682:	db4080e7          	jalr	-588(ra) # 80003432 <iget>
}
    80003686:	60a6                	ld	ra,72(sp)
    80003688:	6406                	ld	s0,64(sp)
    8000368a:	74e2                	ld	s1,56(sp)
    8000368c:	7942                	ld	s2,48(sp)
    8000368e:	79a2                	ld	s3,40(sp)
    80003690:	7a02                	ld	s4,32(sp)
    80003692:	6ae2                	ld	s5,24(sp)
    80003694:	6b42                	ld	s6,16(sp)
    80003696:	6ba2                	ld	s7,8(sp)
    80003698:	6161                	addi	sp,sp,80
    8000369a:	8082                	ret

000000008000369c <iupdate>:
{
    8000369c:	1101                	addi	sp,sp,-32
    8000369e:	ec06                	sd	ra,24(sp)
    800036a0:	e822                	sd	s0,16(sp)
    800036a2:	e426                	sd	s1,8(sp)
    800036a4:	e04a                	sd	s2,0(sp)
    800036a6:	1000                	addi	s0,sp,32
    800036a8:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036aa:	415c                	lw	a5,4(a0)
    800036ac:	0047d79b          	srliw	a5,a5,0x4
    800036b0:	0001d597          	auipc	a1,0x1d
    800036b4:	9a85a583          	lw	a1,-1624(a1) # 80020058 <sb+0x18>
    800036b8:	9dbd                	addw	a1,a1,a5
    800036ba:	4108                	lw	a0,0(a0)
    800036bc:	00000097          	auipc	ra,0x0
    800036c0:	8a8080e7          	jalr	-1880(ra) # 80002f64 <bread>
    800036c4:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036c6:	05850793          	addi	a5,a0,88
    800036ca:	40c8                	lw	a0,4(s1)
    800036cc:	893d                	andi	a0,a0,15
    800036ce:	051a                	slli	a0,a0,0x6
    800036d0:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800036d2:	04449703          	lh	a4,68(s1)
    800036d6:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800036da:	04649703          	lh	a4,70(s1)
    800036de:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800036e2:	04849703          	lh	a4,72(s1)
    800036e6:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800036ea:	04a49703          	lh	a4,74(s1)
    800036ee:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800036f2:	44f8                	lw	a4,76(s1)
    800036f4:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800036f6:	03400613          	li	a2,52
    800036fa:	05048593          	addi	a1,s1,80
    800036fe:	0531                	addi	a0,a0,12
    80003700:	ffffd097          	auipc	ra,0xffffd
    80003704:	6be080e7          	jalr	1726(ra) # 80000dbe <memmove>
  log_write(bp);
    80003708:	854a                	mv	a0,s2
    8000370a:	00001097          	auipc	ra,0x1
    8000370e:	bee080e7          	jalr	-1042(ra) # 800042f8 <log_write>
  brelse(bp);
    80003712:	854a                	mv	a0,s2
    80003714:	00000097          	auipc	ra,0x0
    80003718:	980080e7          	jalr	-1664(ra) # 80003094 <brelse>
}
    8000371c:	60e2                	ld	ra,24(sp)
    8000371e:	6442                	ld	s0,16(sp)
    80003720:	64a2                	ld	s1,8(sp)
    80003722:	6902                	ld	s2,0(sp)
    80003724:	6105                	addi	sp,sp,32
    80003726:	8082                	ret

0000000080003728 <idup>:
{
    80003728:	1101                	addi	sp,sp,-32
    8000372a:	ec06                	sd	ra,24(sp)
    8000372c:	e822                	sd	s0,16(sp)
    8000372e:	e426                	sd	s1,8(sp)
    80003730:	1000                	addi	s0,sp,32
    80003732:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003734:	0001d517          	auipc	a0,0x1d
    80003738:	92c50513          	addi	a0,a0,-1748 # 80020060 <icache>
    8000373c:	ffffd097          	auipc	ra,0xffffd
    80003740:	526080e7          	jalr	1318(ra) # 80000c62 <acquire>
  ip->ref++;
    80003744:	449c                	lw	a5,8(s1)
    80003746:	2785                	addiw	a5,a5,1
    80003748:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    8000374a:	0001d517          	auipc	a0,0x1d
    8000374e:	91650513          	addi	a0,a0,-1770 # 80020060 <icache>
    80003752:	ffffd097          	auipc	ra,0xffffd
    80003756:	5c4080e7          	jalr	1476(ra) # 80000d16 <release>
}
    8000375a:	8526                	mv	a0,s1
    8000375c:	60e2                	ld	ra,24(sp)
    8000375e:	6442                	ld	s0,16(sp)
    80003760:	64a2                	ld	s1,8(sp)
    80003762:	6105                	addi	sp,sp,32
    80003764:	8082                	ret

0000000080003766 <ilock>:
{
    80003766:	1101                	addi	sp,sp,-32
    80003768:	ec06                	sd	ra,24(sp)
    8000376a:	e822                	sd	s0,16(sp)
    8000376c:	e426                	sd	s1,8(sp)
    8000376e:	e04a                	sd	s2,0(sp)
    80003770:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003772:	c115                	beqz	a0,80003796 <ilock+0x30>
    80003774:	84aa                	mv	s1,a0
    80003776:	451c                	lw	a5,8(a0)
    80003778:	00f05f63          	blez	a5,80003796 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000377c:	0541                	addi	a0,a0,16
    8000377e:	00001097          	auipc	ra,0x1
    80003782:	ca2080e7          	jalr	-862(ra) # 80004420 <acquiresleep>
  if(ip->valid == 0){
    80003786:	40bc                	lw	a5,64(s1)
    80003788:	cf99                	beqz	a5,800037a6 <ilock+0x40>
}
    8000378a:	60e2                	ld	ra,24(sp)
    8000378c:	6442                	ld	s0,16(sp)
    8000378e:	64a2                	ld	s1,8(sp)
    80003790:	6902                	ld	s2,0(sp)
    80003792:	6105                	addi	sp,sp,32
    80003794:	8082                	ret
    panic("ilock");
    80003796:	00005517          	auipc	a0,0x5
    8000379a:	ee250513          	addi	a0,a0,-286 # 80008678 <syscalls+0x190>
    8000379e:	ffffd097          	auipc	ra,0xffffd
    800037a2:	daa080e7          	jalr	-598(ra) # 80000548 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037a6:	40dc                	lw	a5,4(s1)
    800037a8:	0047d79b          	srliw	a5,a5,0x4
    800037ac:	0001d597          	auipc	a1,0x1d
    800037b0:	8ac5a583          	lw	a1,-1876(a1) # 80020058 <sb+0x18>
    800037b4:	9dbd                	addw	a1,a1,a5
    800037b6:	4088                	lw	a0,0(s1)
    800037b8:	fffff097          	auipc	ra,0xfffff
    800037bc:	7ac080e7          	jalr	1964(ra) # 80002f64 <bread>
    800037c0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037c2:	05850593          	addi	a1,a0,88
    800037c6:	40dc                	lw	a5,4(s1)
    800037c8:	8bbd                	andi	a5,a5,15
    800037ca:	079a                	slli	a5,a5,0x6
    800037cc:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800037ce:	00059783          	lh	a5,0(a1)
    800037d2:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800037d6:	00259783          	lh	a5,2(a1)
    800037da:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800037de:	00459783          	lh	a5,4(a1)
    800037e2:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800037e6:	00659783          	lh	a5,6(a1)
    800037ea:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800037ee:	459c                	lw	a5,8(a1)
    800037f0:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800037f2:	03400613          	li	a2,52
    800037f6:	05b1                	addi	a1,a1,12
    800037f8:	05048513          	addi	a0,s1,80
    800037fc:	ffffd097          	auipc	ra,0xffffd
    80003800:	5c2080e7          	jalr	1474(ra) # 80000dbe <memmove>
    brelse(bp);
    80003804:	854a                	mv	a0,s2
    80003806:	00000097          	auipc	ra,0x0
    8000380a:	88e080e7          	jalr	-1906(ra) # 80003094 <brelse>
    ip->valid = 1;
    8000380e:	4785                	li	a5,1
    80003810:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003812:	04449783          	lh	a5,68(s1)
    80003816:	fbb5                	bnez	a5,8000378a <ilock+0x24>
      panic("ilock: no type");
    80003818:	00005517          	auipc	a0,0x5
    8000381c:	e6850513          	addi	a0,a0,-408 # 80008680 <syscalls+0x198>
    80003820:	ffffd097          	auipc	ra,0xffffd
    80003824:	d28080e7          	jalr	-728(ra) # 80000548 <panic>

0000000080003828 <iunlock>:
{
    80003828:	1101                	addi	sp,sp,-32
    8000382a:	ec06                	sd	ra,24(sp)
    8000382c:	e822                	sd	s0,16(sp)
    8000382e:	e426                	sd	s1,8(sp)
    80003830:	e04a                	sd	s2,0(sp)
    80003832:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003834:	c905                	beqz	a0,80003864 <iunlock+0x3c>
    80003836:	84aa                	mv	s1,a0
    80003838:	01050913          	addi	s2,a0,16
    8000383c:	854a                	mv	a0,s2
    8000383e:	00001097          	auipc	ra,0x1
    80003842:	c7c080e7          	jalr	-900(ra) # 800044ba <holdingsleep>
    80003846:	cd19                	beqz	a0,80003864 <iunlock+0x3c>
    80003848:	449c                	lw	a5,8(s1)
    8000384a:	00f05d63          	blez	a5,80003864 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000384e:	854a                	mv	a0,s2
    80003850:	00001097          	auipc	ra,0x1
    80003854:	c26080e7          	jalr	-986(ra) # 80004476 <releasesleep>
}
    80003858:	60e2                	ld	ra,24(sp)
    8000385a:	6442                	ld	s0,16(sp)
    8000385c:	64a2                	ld	s1,8(sp)
    8000385e:	6902                	ld	s2,0(sp)
    80003860:	6105                	addi	sp,sp,32
    80003862:	8082                	ret
    panic("iunlock");
    80003864:	00005517          	auipc	a0,0x5
    80003868:	e2c50513          	addi	a0,a0,-468 # 80008690 <syscalls+0x1a8>
    8000386c:	ffffd097          	auipc	ra,0xffffd
    80003870:	cdc080e7          	jalr	-804(ra) # 80000548 <panic>

0000000080003874 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003874:	7179                	addi	sp,sp,-48
    80003876:	f406                	sd	ra,40(sp)
    80003878:	f022                	sd	s0,32(sp)
    8000387a:	ec26                	sd	s1,24(sp)
    8000387c:	e84a                	sd	s2,16(sp)
    8000387e:	e44e                	sd	s3,8(sp)
    80003880:	e052                	sd	s4,0(sp)
    80003882:	1800                	addi	s0,sp,48
    80003884:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003886:	05050493          	addi	s1,a0,80
    8000388a:	08050913          	addi	s2,a0,128
    8000388e:	a021                	j	80003896 <itrunc+0x22>
    80003890:	0491                	addi	s1,s1,4
    80003892:	01248d63          	beq	s1,s2,800038ac <itrunc+0x38>
    if(ip->addrs[i]){
    80003896:	408c                	lw	a1,0(s1)
    80003898:	dde5                	beqz	a1,80003890 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000389a:	0009a503          	lw	a0,0(s3)
    8000389e:	00000097          	auipc	ra,0x0
    800038a2:	90c080e7          	jalr	-1780(ra) # 800031aa <bfree>
      ip->addrs[i] = 0;
    800038a6:	0004a023          	sw	zero,0(s1)
    800038aa:	b7dd                	j	80003890 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800038ac:	0809a583          	lw	a1,128(s3)
    800038b0:	e185                	bnez	a1,800038d0 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800038b2:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800038b6:	854e                	mv	a0,s3
    800038b8:	00000097          	auipc	ra,0x0
    800038bc:	de4080e7          	jalr	-540(ra) # 8000369c <iupdate>
}
    800038c0:	70a2                	ld	ra,40(sp)
    800038c2:	7402                	ld	s0,32(sp)
    800038c4:	64e2                	ld	s1,24(sp)
    800038c6:	6942                	ld	s2,16(sp)
    800038c8:	69a2                	ld	s3,8(sp)
    800038ca:	6a02                	ld	s4,0(sp)
    800038cc:	6145                	addi	sp,sp,48
    800038ce:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800038d0:	0009a503          	lw	a0,0(s3)
    800038d4:	fffff097          	auipc	ra,0xfffff
    800038d8:	690080e7          	jalr	1680(ra) # 80002f64 <bread>
    800038dc:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800038de:	05850493          	addi	s1,a0,88
    800038e2:	45850913          	addi	s2,a0,1112
    800038e6:	a811                	j	800038fa <itrunc+0x86>
        bfree(ip->dev, a[j]);
    800038e8:	0009a503          	lw	a0,0(s3)
    800038ec:	00000097          	auipc	ra,0x0
    800038f0:	8be080e7          	jalr	-1858(ra) # 800031aa <bfree>
    for(j = 0; j < NINDIRECT; j++){
    800038f4:	0491                	addi	s1,s1,4
    800038f6:	01248563          	beq	s1,s2,80003900 <itrunc+0x8c>
      if(a[j])
    800038fa:	408c                	lw	a1,0(s1)
    800038fc:	dde5                	beqz	a1,800038f4 <itrunc+0x80>
    800038fe:	b7ed                	j	800038e8 <itrunc+0x74>
    brelse(bp);
    80003900:	8552                	mv	a0,s4
    80003902:	fffff097          	auipc	ra,0xfffff
    80003906:	792080e7          	jalr	1938(ra) # 80003094 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000390a:	0809a583          	lw	a1,128(s3)
    8000390e:	0009a503          	lw	a0,0(s3)
    80003912:	00000097          	auipc	ra,0x0
    80003916:	898080e7          	jalr	-1896(ra) # 800031aa <bfree>
    ip->addrs[NDIRECT] = 0;
    8000391a:	0809a023          	sw	zero,128(s3)
    8000391e:	bf51                	j	800038b2 <itrunc+0x3e>

0000000080003920 <iput>:
{
    80003920:	1101                	addi	sp,sp,-32
    80003922:	ec06                	sd	ra,24(sp)
    80003924:	e822                	sd	s0,16(sp)
    80003926:	e426                	sd	s1,8(sp)
    80003928:	e04a                	sd	s2,0(sp)
    8000392a:	1000                	addi	s0,sp,32
    8000392c:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    8000392e:	0001c517          	auipc	a0,0x1c
    80003932:	73250513          	addi	a0,a0,1842 # 80020060 <icache>
    80003936:	ffffd097          	auipc	ra,0xffffd
    8000393a:	32c080e7          	jalr	812(ra) # 80000c62 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000393e:	4498                	lw	a4,8(s1)
    80003940:	4785                	li	a5,1
    80003942:	02f70363          	beq	a4,a5,80003968 <iput+0x48>
  ip->ref--;
    80003946:	449c                	lw	a5,8(s1)
    80003948:	37fd                	addiw	a5,a5,-1
    8000394a:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    8000394c:	0001c517          	auipc	a0,0x1c
    80003950:	71450513          	addi	a0,a0,1812 # 80020060 <icache>
    80003954:	ffffd097          	auipc	ra,0xffffd
    80003958:	3c2080e7          	jalr	962(ra) # 80000d16 <release>
}
    8000395c:	60e2                	ld	ra,24(sp)
    8000395e:	6442                	ld	s0,16(sp)
    80003960:	64a2                	ld	s1,8(sp)
    80003962:	6902                	ld	s2,0(sp)
    80003964:	6105                	addi	sp,sp,32
    80003966:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003968:	40bc                	lw	a5,64(s1)
    8000396a:	dff1                	beqz	a5,80003946 <iput+0x26>
    8000396c:	04a49783          	lh	a5,74(s1)
    80003970:	fbf9                	bnez	a5,80003946 <iput+0x26>
    acquiresleep(&ip->lock);
    80003972:	01048913          	addi	s2,s1,16
    80003976:	854a                	mv	a0,s2
    80003978:	00001097          	auipc	ra,0x1
    8000397c:	aa8080e7          	jalr	-1368(ra) # 80004420 <acquiresleep>
    release(&icache.lock);
    80003980:	0001c517          	auipc	a0,0x1c
    80003984:	6e050513          	addi	a0,a0,1760 # 80020060 <icache>
    80003988:	ffffd097          	auipc	ra,0xffffd
    8000398c:	38e080e7          	jalr	910(ra) # 80000d16 <release>
    itrunc(ip);
    80003990:	8526                	mv	a0,s1
    80003992:	00000097          	auipc	ra,0x0
    80003996:	ee2080e7          	jalr	-286(ra) # 80003874 <itrunc>
    ip->type = 0;
    8000399a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000399e:	8526                	mv	a0,s1
    800039a0:	00000097          	auipc	ra,0x0
    800039a4:	cfc080e7          	jalr	-772(ra) # 8000369c <iupdate>
    ip->valid = 0;
    800039a8:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800039ac:	854a                	mv	a0,s2
    800039ae:	00001097          	auipc	ra,0x1
    800039b2:	ac8080e7          	jalr	-1336(ra) # 80004476 <releasesleep>
    acquire(&icache.lock);
    800039b6:	0001c517          	auipc	a0,0x1c
    800039ba:	6aa50513          	addi	a0,a0,1706 # 80020060 <icache>
    800039be:	ffffd097          	auipc	ra,0xffffd
    800039c2:	2a4080e7          	jalr	676(ra) # 80000c62 <acquire>
    800039c6:	b741                	j	80003946 <iput+0x26>

00000000800039c8 <iunlockput>:
{
    800039c8:	1101                	addi	sp,sp,-32
    800039ca:	ec06                	sd	ra,24(sp)
    800039cc:	e822                	sd	s0,16(sp)
    800039ce:	e426                	sd	s1,8(sp)
    800039d0:	1000                	addi	s0,sp,32
    800039d2:	84aa                	mv	s1,a0
  iunlock(ip);
    800039d4:	00000097          	auipc	ra,0x0
    800039d8:	e54080e7          	jalr	-428(ra) # 80003828 <iunlock>
  iput(ip);
    800039dc:	8526                	mv	a0,s1
    800039de:	00000097          	auipc	ra,0x0
    800039e2:	f42080e7          	jalr	-190(ra) # 80003920 <iput>
}
    800039e6:	60e2                	ld	ra,24(sp)
    800039e8:	6442                	ld	s0,16(sp)
    800039ea:	64a2                	ld	s1,8(sp)
    800039ec:	6105                	addi	sp,sp,32
    800039ee:	8082                	ret

00000000800039f0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800039f0:	1141                	addi	sp,sp,-16
    800039f2:	e422                	sd	s0,8(sp)
    800039f4:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800039f6:	411c                	lw	a5,0(a0)
    800039f8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800039fa:	415c                	lw	a5,4(a0)
    800039fc:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800039fe:	04451783          	lh	a5,68(a0)
    80003a02:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003a06:	04a51783          	lh	a5,74(a0)
    80003a0a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003a0e:	04c56783          	lwu	a5,76(a0)
    80003a12:	e99c                	sd	a5,16(a1)
}
    80003a14:	6422                	ld	s0,8(sp)
    80003a16:	0141                	addi	sp,sp,16
    80003a18:	8082                	ret

0000000080003a1a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a1a:	457c                	lw	a5,76(a0)
    80003a1c:	0ed7e863          	bltu	a5,a3,80003b0c <readi+0xf2>
{
    80003a20:	7159                	addi	sp,sp,-112
    80003a22:	f486                	sd	ra,104(sp)
    80003a24:	f0a2                	sd	s0,96(sp)
    80003a26:	eca6                	sd	s1,88(sp)
    80003a28:	e8ca                	sd	s2,80(sp)
    80003a2a:	e4ce                	sd	s3,72(sp)
    80003a2c:	e0d2                	sd	s4,64(sp)
    80003a2e:	fc56                	sd	s5,56(sp)
    80003a30:	f85a                	sd	s6,48(sp)
    80003a32:	f45e                	sd	s7,40(sp)
    80003a34:	f062                	sd	s8,32(sp)
    80003a36:	ec66                	sd	s9,24(sp)
    80003a38:	e86a                	sd	s10,16(sp)
    80003a3a:	e46e                	sd	s11,8(sp)
    80003a3c:	1880                	addi	s0,sp,112
    80003a3e:	8baa                	mv	s7,a0
    80003a40:	8c2e                	mv	s8,a1
    80003a42:	8ab2                	mv	s5,a2
    80003a44:	84b6                	mv	s1,a3
    80003a46:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a48:	9f35                	addw	a4,a4,a3
    return 0;
    80003a4a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003a4c:	08d76f63          	bltu	a4,a3,80003aea <readi+0xd0>
  if(off + n > ip->size)
    80003a50:	00e7f463          	bgeu	a5,a4,80003a58 <readi+0x3e>
    n = ip->size - off;
    80003a54:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a58:	0a0b0863          	beqz	s6,80003b08 <readi+0xee>
    80003a5c:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a5e:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003a62:	5cfd                	li	s9,-1
    80003a64:	a82d                	j	80003a9e <readi+0x84>
    80003a66:	020a1d93          	slli	s11,s4,0x20
    80003a6a:	020ddd93          	srli	s11,s11,0x20
    80003a6e:	05890613          	addi	a2,s2,88
    80003a72:	86ee                	mv	a3,s11
    80003a74:	963a                	add	a2,a2,a4
    80003a76:	85d6                	mv	a1,s5
    80003a78:	8562                	mv	a0,s8
    80003a7a:	fffff097          	auipc	ra,0xfffff
    80003a7e:	a30080e7          	jalr	-1488(ra) # 800024aa <either_copyout>
    80003a82:	05950d63          	beq	a0,s9,80003adc <readi+0xc2>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003a86:	854a                	mv	a0,s2
    80003a88:	fffff097          	auipc	ra,0xfffff
    80003a8c:	60c080e7          	jalr	1548(ra) # 80003094 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a90:	013a09bb          	addw	s3,s4,s3
    80003a94:	009a04bb          	addw	s1,s4,s1
    80003a98:	9aee                	add	s5,s5,s11
    80003a9a:	0569f663          	bgeu	s3,s6,80003ae6 <readi+0xcc>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003a9e:	000ba903          	lw	s2,0(s7)
    80003aa2:	00a4d59b          	srliw	a1,s1,0xa
    80003aa6:	855e                	mv	a0,s7
    80003aa8:	00000097          	auipc	ra,0x0
    80003aac:	8b0080e7          	jalr	-1872(ra) # 80003358 <bmap>
    80003ab0:	0005059b          	sext.w	a1,a0
    80003ab4:	854a                	mv	a0,s2
    80003ab6:	fffff097          	auipc	ra,0xfffff
    80003aba:	4ae080e7          	jalr	1198(ra) # 80002f64 <bread>
    80003abe:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ac0:	3ff4f713          	andi	a4,s1,1023
    80003ac4:	40ed07bb          	subw	a5,s10,a4
    80003ac8:	413b06bb          	subw	a3,s6,s3
    80003acc:	8a3e                	mv	s4,a5
    80003ace:	2781                	sext.w	a5,a5
    80003ad0:	0006861b          	sext.w	a2,a3
    80003ad4:	f8f679e3          	bgeu	a2,a5,80003a66 <readi+0x4c>
    80003ad8:	8a36                	mv	s4,a3
    80003ada:	b771                	j	80003a66 <readi+0x4c>
      brelse(bp);
    80003adc:	854a                	mv	a0,s2
    80003ade:	fffff097          	auipc	ra,0xfffff
    80003ae2:	5b6080e7          	jalr	1462(ra) # 80003094 <brelse>
  }
  return tot;
    80003ae6:	0009851b          	sext.w	a0,s3
}
    80003aea:	70a6                	ld	ra,104(sp)
    80003aec:	7406                	ld	s0,96(sp)
    80003aee:	64e6                	ld	s1,88(sp)
    80003af0:	6946                	ld	s2,80(sp)
    80003af2:	69a6                	ld	s3,72(sp)
    80003af4:	6a06                	ld	s4,64(sp)
    80003af6:	7ae2                	ld	s5,56(sp)
    80003af8:	7b42                	ld	s6,48(sp)
    80003afa:	7ba2                	ld	s7,40(sp)
    80003afc:	7c02                	ld	s8,32(sp)
    80003afe:	6ce2                	ld	s9,24(sp)
    80003b00:	6d42                	ld	s10,16(sp)
    80003b02:	6da2                	ld	s11,8(sp)
    80003b04:	6165                	addi	sp,sp,112
    80003b06:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b08:	89da                	mv	s3,s6
    80003b0a:	bff1                	j	80003ae6 <readi+0xcc>
    return 0;
    80003b0c:	4501                	li	a0,0
}
    80003b0e:	8082                	ret

0000000080003b10 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b10:	457c                	lw	a5,76(a0)
    80003b12:	10d7e663          	bltu	a5,a3,80003c1e <writei+0x10e>
{
    80003b16:	7159                	addi	sp,sp,-112
    80003b18:	f486                	sd	ra,104(sp)
    80003b1a:	f0a2                	sd	s0,96(sp)
    80003b1c:	eca6                	sd	s1,88(sp)
    80003b1e:	e8ca                	sd	s2,80(sp)
    80003b20:	e4ce                	sd	s3,72(sp)
    80003b22:	e0d2                	sd	s4,64(sp)
    80003b24:	fc56                	sd	s5,56(sp)
    80003b26:	f85a                	sd	s6,48(sp)
    80003b28:	f45e                	sd	s7,40(sp)
    80003b2a:	f062                	sd	s8,32(sp)
    80003b2c:	ec66                	sd	s9,24(sp)
    80003b2e:	e86a                	sd	s10,16(sp)
    80003b30:	e46e                	sd	s11,8(sp)
    80003b32:	1880                	addi	s0,sp,112
    80003b34:	8baa                	mv	s7,a0
    80003b36:	8c2e                	mv	s8,a1
    80003b38:	8ab2                	mv	s5,a2
    80003b3a:	8936                	mv	s2,a3
    80003b3c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b3e:	00e687bb          	addw	a5,a3,a4
    80003b42:	0ed7e063          	bltu	a5,a3,80003c22 <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003b46:	00043737          	lui	a4,0x43
    80003b4a:	0cf76e63          	bltu	a4,a5,80003c26 <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b4e:	0a0b0763          	beqz	s6,80003bfc <writei+0xec>
    80003b52:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b54:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003b58:	5cfd                	li	s9,-1
    80003b5a:	a091                	j	80003b9e <writei+0x8e>
    80003b5c:	02099d93          	slli	s11,s3,0x20
    80003b60:	020ddd93          	srli	s11,s11,0x20
    80003b64:	05848513          	addi	a0,s1,88
    80003b68:	86ee                	mv	a3,s11
    80003b6a:	8656                	mv	a2,s5
    80003b6c:	85e2                	mv	a1,s8
    80003b6e:	953a                	add	a0,a0,a4
    80003b70:	fffff097          	auipc	ra,0xfffff
    80003b74:	990080e7          	jalr	-1648(ra) # 80002500 <either_copyin>
    80003b78:	07950263          	beq	a0,s9,80003bdc <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003b7c:	8526                	mv	a0,s1
    80003b7e:	00000097          	auipc	ra,0x0
    80003b82:	77a080e7          	jalr	1914(ra) # 800042f8 <log_write>
    brelse(bp);
    80003b86:	8526                	mv	a0,s1
    80003b88:	fffff097          	auipc	ra,0xfffff
    80003b8c:	50c080e7          	jalr	1292(ra) # 80003094 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b90:	01498a3b          	addw	s4,s3,s4
    80003b94:	0129893b          	addw	s2,s3,s2
    80003b98:	9aee                	add	s5,s5,s11
    80003b9a:	056a7663          	bgeu	s4,s6,80003be6 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003b9e:	000ba483          	lw	s1,0(s7)
    80003ba2:	00a9559b          	srliw	a1,s2,0xa
    80003ba6:	855e                	mv	a0,s7
    80003ba8:	fffff097          	auipc	ra,0xfffff
    80003bac:	7b0080e7          	jalr	1968(ra) # 80003358 <bmap>
    80003bb0:	0005059b          	sext.w	a1,a0
    80003bb4:	8526                	mv	a0,s1
    80003bb6:	fffff097          	auipc	ra,0xfffff
    80003bba:	3ae080e7          	jalr	942(ra) # 80002f64 <bread>
    80003bbe:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bc0:	3ff97713          	andi	a4,s2,1023
    80003bc4:	40ed07bb          	subw	a5,s10,a4
    80003bc8:	414b06bb          	subw	a3,s6,s4
    80003bcc:	89be                	mv	s3,a5
    80003bce:	2781                	sext.w	a5,a5
    80003bd0:	0006861b          	sext.w	a2,a3
    80003bd4:	f8f674e3          	bgeu	a2,a5,80003b5c <writei+0x4c>
    80003bd8:	89b6                	mv	s3,a3
    80003bda:	b749                	j	80003b5c <writei+0x4c>
      brelse(bp);
    80003bdc:	8526                	mv	a0,s1
    80003bde:	fffff097          	auipc	ra,0xfffff
    80003be2:	4b6080e7          	jalr	1206(ra) # 80003094 <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003be6:	04cba783          	lw	a5,76(s7)
    80003bea:	0127f463          	bgeu	a5,s2,80003bf2 <writei+0xe2>
      ip->size = off;
    80003bee:	052ba623          	sw	s2,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003bf2:	855e                	mv	a0,s7
    80003bf4:	00000097          	auipc	ra,0x0
    80003bf8:	aa8080e7          	jalr	-1368(ra) # 8000369c <iupdate>
  }

  return n;
    80003bfc:	000b051b          	sext.w	a0,s6
}
    80003c00:	70a6                	ld	ra,104(sp)
    80003c02:	7406                	ld	s0,96(sp)
    80003c04:	64e6                	ld	s1,88(sp)
    80003c06:	6946                	ld	s2,80(sp)
    80003c08:	69a6                	ld	s3,72(sp)
    80003c0a:	6a06                	ld	s4,64(sp)
    80003c0c:	7ae2                	ld	s5,56(sp)
    80003c0e:	7b42                	ld	s6,48(sp)
    80003c10:	7ba2                	ld	s7,40(sp)
    80003c12:	7c02                	ld	s8,32(sp)
    80003c14:	6ce2                	ld	s9,24(sp)
    80003c16:	6d42                	ld	s10,16(sp)
    80003c18:	6da2                	ld	s11,8(sp)
    80003c1a:	6165                	addi	sp,sp,112
    80003c1c:	8082                	ret
    return -1;
    80003c1e:	557d                	li	a0,-1
}
    80003c20:	8082                	ret
    return -1;
    80003c22:	557d                	li	a0,-1
    80003c24:	bff1                	j	80003c00 <writei+0xf0>
    return -1;
    80003c26:	557d                	li	a0,-1
    80003c28:	bfe1                	j	80003c00 <writei+0xf0>

0000000080003c2a <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003c2a:	1141                	addi	sp,sp,-16
    80003c2c:	e406                	sd	ra,8(sp)
    80003c2e:	e022                	sd	s0,0(sp)
    80003c30:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003c32:	4639                	li	a2,14
    80003c34:	ffffd097          	auipc	ra,0xffffd
    80003c38:	206080e7          	jalr	518(ra) # 80000e3a <strncmp>
}
    80003c3c:	60a2                	ld	ra,8(sp)
    80003c3e:	6402                	ld	s0,0(sp)
    80003c40:	0141                	addi	sp,sp,16
    80003c42:	8082                	ret

0000000080003c44 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003c44:	7139                	addi	sp,sp,-64
    80003c46:	fc06                	sd	ra,56(sp)
    80003c48:	f822                	sd	s0,48(sp)
    80003c4a:	f426                	sd	s1,40(sp)
    80003c4c:	f04a                	sd	s2,32(sp)
    80003c4e:	ec4e                	sd	s3,24(sp)
    80003c50:	e852                	sd	s4,16(sp)
    80003c52:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003c54:	04451703          	lh	a4,68(a0)
    80003c58:	4785                	li	a5,1
    80003c5a:	00f71a63          	bne	a4,a5,80003c6e <dirlookup+0x2a>
    80003c5e:	892a                	mv	s2,a0
    80003c60:	89ae                	mv	s3,a1
    80003c62:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c64:	457c                	lw	a5,76(a0)
    80003c66:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003c68:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c6a:	e79d                	bnez	a5,80003c98 <dirlookup+0x54>
    80003c6c:	a8a5                	j	80003ce4 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003c6e:	00005517          	auipc	a0,0x5
    80003c72:	a2a50513          	addi	a0,a0,-1494 # 80008698 <syscalls+0x1b0>
    80003c76:	ffffd097          	auipc	ra,0xffffd
    80003c7a:	8d2080e7          	jalr	-1838(ra) # 80000548 <panic>
      panic("dirlookup read");
    80003c7e:	00005517          	auipc	a0,0x5
    80003c82:	a3250513          	addi	a0,a0,-1486 # 800086b0 <syscalls+0x1c8>
    80003c86:	ffffd097          	auipc	ra,0xffffd
    80003c8a:	8c2080e7          	jalr	-1854(ra) # 80000548 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c8e:	24c1                	addiw	s1,s1,16
    80003c90:	04c92783          	lw	a5,76(s2)
    80003c94:	04f4f763          	bgeu	s1,a5,80003ce2 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c98:	4741                	li	a4,16
    80003c9a:	86a6                	mv	a3,s1
    80003c9c:	fc040613          	addi	a2,s0,-64
    80003ca0:	4581                	li	a1,0
    80003ca2:	854a                	mv	a0,s2
    80003ca4:	00000097          	auipc	ra,0x0
    80003ca8:	d76080e7          	jalr	-650(ra) # 80003a1a <readi>
    80003cac:	47c1                	li	a5,16
    80003cae:	fcf518e3          	bne	a0,a5,80003c7e <dirlookup+0x3a>
    if(de.inum == 0)
    80003cb2:	fc045783          	lhu	a5,-64(s0)
    80003cb6:	dfe1                	beqz	a5,80003c8e <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003cb8:	fc240593          	addi	a1,s0,-62
    80003cbc:	854e                	mv	a0,s3
    80003cbe:	00000097          	auipc	ra,0x0
    80003cc2:	f6c080e7          	jalr	-148(ra) # 80003c2a <namecmp>
    80003cc6:	f561                	bnez	a0,80003c8e <dirlookup+0x4a>
      if(poff)
    80003cc8:	000a0463          	beqz	s4,80003cd0 <dirlookup+0x8c>
        *poff = off;
    80003ccc:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003cd0:	fc045583          	lhu	a1,-64(s0)
    80003cd4:	00092503          	lw	a0,0(s2)
    80003cd8:	fffff097          	auipc	ra,0xfffff
    80003cdc:	75a080e7          	jalr	1882(ra) # 80003432 <iget>
    80003ce0:	a011                	j	80003ce4 <dirlookup+0xa0>
  return 0;
    80003ce2:	4501                	li	a0,0
}
    80003ce4:	70e2                	ld	ra,56(sp)
    80003ce6:	7442                	ld	s0,48(sp)
    80003ce8:	74a2                	ld	s1,40(sp)
    80003cea:	7902                	ld	s2,32(sp)
    80003cec:	69e2                	ld	s3,24(sp)
    80003cee:	6a42                	ld	s4,16(sp)
    80003cf0:	6121                	addi	sp,sp,64
    80003cf2:	8082                	ret

0000000080003cf4 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003cf4:	711d                	addi	sp,sp,-96
    80003cf6:	ec86                	sd	ra,88(sp)
    80003cf8:	e8a2                	sd	s0,80(sp)
    80003cfa:	e4a6                	sd	s1,72(sp)
    80003cfc:	e0ca                	sd	s2,64(sp)
    80003cfe:	fc4e                	sd	s3,56(sp)
    80003d00:	f852                	sd	s4,48(sp)
    80003d02:	f456                	sd	s5,40(sp)
    80003d04:	f05a                	sd	s6,32(sp)
    80003d06:	ec5e                	sd	s7,24(sp)
    80003d08:	e862                	sd	s8,16(sp)
    80003d0a:	e466                	sd	s9,8(sp)
    80003d0c:	1080                	addi	s0,sp,96
    80003d0e:	84aa                	mv	s1,a0
    80003d10:	8b2e                	mv	s6,a1
    80003d12:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003d14:	00054703          	lbu	a4,0(a0)
    80003d18:	02f00793          	li	a5,47
    80003d1c:	02f70363          	beq	a4,a5,80003d42 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003d20:	ffffe097          	auipc	ra,0xffffe
    80003d24:	d10080e7          	jalr	-752(ra) # 80001a30 <myproc>
    80003d28:	15053503          	ld	a0,336(a0)
    80003d2c:	00000097          	auipc	ra,0x0
    80003d30:	9fc080e7          	jalr	-1540(ra) # 80003728 <idup>
    80003d34:	89aa                	mv	s3,a0
  while(*path == '/')
    80003d36:	02f00913          	li	s2,47
  len = path - s;
    80003d3a:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003d3c:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003d3e:	4c05                	li	s8,1
    80003d40:	a865                	j	80003df8 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003d42:	4585                	li	a1,1
    80003d44:	4505                	li	a0,1
    80003d46:	fffff097          	auipc	ra,0xfffff
    80003d4a:	6ec080e7          	jalr	1772(ra) # 80003432 <iget>
    80003d4e:	89aa                	mv	s3,a0
    80003d50:	b7dd                	j	80003d36 <namex+0x42>
      iunlockput(ip);
    80003d52:	854e                	mv	a0,s3
    80003d54:	00000097          	auipc	ra,0x0
    80003d58:	c74080e7          	jalr	-908(ra) # 800039c8 <iunlockput>
      return 0;
    80003d5c:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003d5e:	854e                	mv	a0,s3
    80003d60:	60e6                	ld	ra,88(sp)
    80003d62:	6446                	ld	s0,80(sp)
    80003d64:	64a6                	ld	s1,72(sp)
    80003d66:	6906                	ld	s2,64(sp)
    80003d68:	79e2                	ld	s3,56(sp)
    80003d6a:	7a42                	ld	s4,48(sp)
    80003d6c:	7aa2                	ld	s5,40(sp)
    80003d6e:	7b02                	ld	s6,32(sp)
    80003d70:	6be2                	ld	s7,24(sp)
    80003d72:	6c42                	ld	s8,16(sp)
    80003d74:	6ca2                	ld	s9,8(sp)
    80003d76:	6125                	addi	sp,sp,96
    80003d78:	8082                	ret
      iunlock(ip);
    80003d7a:	854e                	mv	a0,s3
    80003d7c:	00000097          	auipc	ra,0x0
    80003d80:	aac080e7          	jalr	-1364(ra) # 80003828 <iunlock>
      return ip;
    80003d84:	bfe9                	j	80003d5e <namex+0x6a>
      iunlockput(ip);
    80003d86:	854e                	mv	a0,s3
    80003d88:	00000097          	auipc	ra,0x0
    80003d8c:	c40080e7          	jalr	-960(ra) # 800039c8 <iunlockput>
      return 0;
    80003d90:	89d2                	mv	s3,s4
    80003d92:	b7f1                	j	80003d5e <namex+0x6a>
  len = path - s;
    80003d94:	40b48633          	sub	a2,s1,a1
    80003d98:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003d9c:	094cd463          	bge	s9,s4,80003e24 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003da0:	4639                	li	a2,14
    80003da2:	8556                	mv	a0,s5
    80003da4:	ffffd097          	auipc	ra,0xffffd
    80003da8:	01a080e7          	jalr	26(ra) # 80000dbe <memmove>
  while(*path == '/')
    80003dac:	0004c783          	lbu	a5,0(s1)
    80003db0:	01279763          	bne	a5,s2,80003dbe <namex+0xca>
    path++;
    80003db4:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003db6:	0004c783          	lbu	a5,0(s1)
    80003dba:	ff278de3          	beq	a5,s2,80003db4 <namex+0xc0>
    ilock(ip);
    80003dbe:	854e                	mv	a0,s3
    80003dc0:	00000097          	auipc	ra,0x0
    80003dc4:	9a6080e7          	jalr	-1626(ra) # 80003766 <ilock>
    if(ip->type != T_DIR){
    80003dc8:	04499783          	lh	a5,68(s3)
    80003dcc:	f98793e3          	bne	a5,s8,80003d52 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003dd0:	000b0563          	beqz	s6,80003dda <namex+0xe6>
    80003dd4:	0004c783          	lbu	a5,0(s1)
    80003dd8:	d3cd                	beqz	a5,80003d7a <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003dda:	865e                	mv	a2,s7
    80003ddc:	85d6                	mv	a1,s5
    80003dde:	854e                	mv	a0,s3
    80003de0:	00000097          	auipc	ra,0x0
    80003de4:	e64080e7          	jalr	-412(ra) # 80003c44 <dirlookup>
    80003de8:	8a2a                	mv	s4,a0
    80003dea:	dd51                	beqz	a0,80003d86 <namex+0x92>
    iunlockput(ip);
    80003dec:	854e                	mv	a0,s3
    80003dee:	00000097          	auipc	ra,0x0
    80003df2:	bda080e7          	jalr	-1062(ra) # 800039c8 <iunlockput>
    ip = next;
    80003df6:	89d2                	mv	s3,s4
  while(*path == '/')
    80003df8:	0004c783          	lbu	a5,0(s1)
    80003dfc:	05279763          	bne	a5,s2,80003e4a <namex+0x156>
    path++;
    80003e00:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e02:	0004c783          	lbu	a5,0(s1)
    80003e06:	ff278de3          	beq	a5,s2,80003e00 <namex+0x10c>
  if(*path == 0)
    80003e0a:	c79d                	beqz	a5,80003e38 <namex+0x144>
    path++;
    80003e0c:	85a6                	mv	a1,s1
  len = path - s;
    80003e0e:	8a5e                	mv	s4,s7
    80003e10:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003e12:	01278963          	beq	a5,s2,80003e24 <namex+0x130>
    80003e16:	dfbd                	beqz	a5,80003d94 <namex+0xa0>
    path++;
    80003e18:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003e1a:	0004c783          	lbu	a5,0(s1)
    80003e1e:	ff279ce3          	bne	a5,s2,80003e16 <namex+0x122>
    80003e22:	bf8d                	j	80003d94 <namex+0xa0>
    memmove(name, s, len);
    80003e24:	2601                	sext.w	a2,a2
    80003e26:	8556                	mv	a0,s5
    80003e28:	ffffd097          	auipc	ra,0xffffd
    80003e2c:	f96080e7          	jalr	-106(ra) # 80000dbe <memmove>
    name[len] = 0;
    80003e30:	9a56                	add	s4,s4,s5
    80003e32:	000a0023          	sb	zero,0(s4)
    80003e36:	bf9d                	j	80003dac <namex+0xb8>
  if(nameiparent){
    80003e38:	f20b03e3          	beqz	s6,80003d5e <namex+0x6a>
    iput(ip);
    80003e3c:	854e                	mv	a0,s3
    80003e3e:	00000097          	auipc	ra,0x0
    80003e42:	ae2080e7          	jalr	-1310(ra) # 80003920 <iput>
    return 0;
    80003e46:	4981                	li	s3,0
    80003e48:	bf19                	j	80003d5e <namex+0x6a>
  if(*path == 0)
    80003e4a:	d7fd                	beqz	a5,80003e38 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003e4c:	0004c783          	lbu	a5,0(s1)
    80003e50:	85a6                	mv	a1,s1
    80003e52:	b7d1                	j	80003e16 <namex+0x122>

0000000080003e54 <dirlink>:
{
    80003e54:	7139                	addi	sp,sp,-64
    80003e56:	fc06                	sd	ra,56(sp)
    80003e58:	f822                	sd	s0,48(sp)
    80003e5a:	f426                	sd	s1,40(sp)
    80003e5c:	f04a                	sd	s2,32(sp)
    80003e5e:	ec4e                	sd	s3,24(sp)
    80003e60:	e852                	sd	s4,16(sp)
    80003e62:	0080                	addi	s0,sp,64
    80003e64:	892a                	mv	s2,a0
    80003e66:	8a2e                	mv	s4,a1
    80003e68:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003e6a:	4601                	li	a2,0
    80003e6c:	00000097          	auipc	ra,0x0
    80003e70:	dd8080e7          	jalr	-552(ra) # 80003c44 <dirlookup>
    80003e74:	e93d                	bnez	a0,80003eea <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e76:	04c92483          	lw	s1,76(s2)
    80003e7a:	c49d                	beqz	s1,80003ea8 <dirlink+0x54>
    80003e7c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e7e:	4741                	li	a4,16
    80003e80:	86a6                	mv	a3,s1
    80003e82:	fc040613          	addi	a2,s0,-64
    80003e86:	4581                	li	a1,0
    80003e88:	854a                	mv	a0,s2
    80003e8a:	00000097          	auipc	ra,0x0
    80003e8e:	b90080e7          	jalr	-1136(ra) # 80003a1a <readi>
    80003e92:	47c1                	li	a5,16
    80003e94:	06f51163          	bne	a0,a5,80003ef6 <dirlink+0xa2>
    if(de.inum == 0)
    80003e98:	fc045783          	lhu	a5,-64(s0)
    80003e9c:	c791                	beqz	a5,80003ea8 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e9e:	24c1                	addiw	s1,s1,16
    80003ea0:	04c92783          	lw	a5,76(s2)
    80003ea4:	fcf4ede3          	bltu	s1,a5,80003e7e <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003ea8:	4639                	li	a2,14
    80003eaa:	85d2                	mv	a1,s4
    80003eac:	fc240513          	addi	a0,s0,-62
    80003eb0:	ffffd097          	auipc	ra,0xffffd
    80003eb4:	fc6080e7          	jalr	-58(ra) # 80000e76 <strncpy>
  de.inum = inum;
    80003eb8:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ebc:	4741                	li	a4,16
    80003ebe:	86a6                	mv	a3,s1
    80003ec0:	fc040613          	addi	a2,s0,-64
    80003ec4:	4581                	li	a1,0
    80003ec6:	854a                	mv	a0,s2
    80003ec8:	00000097          	auipc	ra,0x0
    80003ecc:	c48080e7          	jalr	-952(ra) # 80003b10 <writei>
    80003ed0:	872a                	mv	a4,a0
    80003ed2:	47c1                	li	a5,16
  return 0;
    80003ed4:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ed6:	02f71863          	bne	a4,a5,80003f06 <dirlink+0xb2>
}
    80003eda:	70e2                	ld	ra,56(sp)
    80003edc:	7442                	ld	s0,48(sp)
    80003ede:	74a2                	ld	s1,40(sp)
    80003ee0:	7902                	ld	s2,32(sp)
    80003ee2:	69e2                	ld	s3,24(sp)
    80003ee4:	6a42                	ld	s4,16(sp)
    80003ee6:	6121                	addi	sp,sp,64
    80003ee8:	8082                	ret
    iput(ip);
    80003eea:	00000097          	auipc	ra,0x0
    80003eee:	a36080e7          	jalr	-1482(ra) # 80003920 <iput>
    return -1;
    80003ef2:	557d                	li	a0,-1
    80003ef4:	b7dd                	j	80003eda <dirlink+0x86>
      panic("dirlink read");
    80003ef6:	00004517          	auipc	a0,0x4
    80003efa:	7ca50513          	addi	a0,a0,1994 # 800086c0 <syscalls+0x1d8>
    80003efe:	ffffc097          	auipc	ra,0xffffc
    80003f02:	64a080e7          	jalr	1610(ra) # 80000548 <panic>
    panic("dirlink");
    80003f06:	00005517          	auipc	a0,0x5
    80003f0a:	8d250513          	addi	a0,a0,-1838 # 800087d8 <syscalls+0x2f0>
    80003f0e:	ffffc097          	auipc	ra,0xffffc
    80003f12:	63a080e7          	jalr	1594(ra) # 80000548 <panic>

0000000080003f16 <namei>:

struct inode*
namei(char *path)
{
    80003f16:	1101                	addi	sp,sp,-32
    80003f18:	ec06                	sd	ra,24(sp)
    80003f1a:	e822                	sd	s0,16(sp)
    80003f1c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003f1e:	fe040613          	addi	a2,s0,-32
    80003f22:	4581                	li	a1,0
    80003f24:	00000097          	auipc	ra,0x0
    80003f28:	dd0080e7          	jalr	-560(ra) # 80003cf4 <namex>
}
    80003f2c:	60e2                	ld	ra,24(sp)
    80003f2e:	6442                	ld	s0,16(sp)
    80003f30:	6105                	addi	sp,sp,32
    80003f32:	8082                	ret

0000000080003f34 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003f34:	1141                	addi	sp,sp,-16
    80003f36:	e406                	sd	ra,8(sp)
    80003f38:	e022                	sd	s0,0(sp)
    80003f3a:	0800                	addi	s0,sp,16
    80003f3c:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003f3e:	4585                	li	a1,1
    80003f40:	00000097          	auipc	ra,0x0
    80003f44:	db4080e7          	jalr	-588(ra) # 80003cf4 <namex>
}
    80003f48:	60a2                	ld	ra,8(sp)
    80003f4a:	6402                	ld	s0,0(sp)
    80003f4c:	0141                	addi	sp,sp,16
    80003f4e:	8082                	ret

0000000080003f50 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003f50:	1101                	addi	sp,sp,-32
    80003f52:	ec06                	sd	ra,24(sp)
    80003f54:	e822                	sd	s0,16(sp)
    80003f56:	e426                	sd	s1,8(sp)
    80003f58:	e04a                	sd	s2,0(sp)
    80003f5a:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003f5c:	0001e917          	auipc	s2,0x1e
    80003f60:	bac90913          	addi	s2,s2,-1108 # 80021b08 <log>
    80003f64:	01892583          	lw	a1,24(s2)
    80003f68:	02892503          	lw	a0,40(s2)
    80003f6c:	fffff097          	auipc	ra,0xfffff
    80003f70:	ff8080e7          	jalr	-8(ra) # 80002f64 <bread>
    80003f74:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003f76:	02c92683          	lw	a3,44(s2)
    80003f7a:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003f7c:	02d05763          	blez	a3,80003faa <write_head+0x5a>
    80003f80:	0001e797          	auipc	a5,0x1e
    80003f84:	bb878793          	addi	a5,a5,-1096 # 80021b38 <log+0x30>
    80003f88:	05c50713          	addi	a4,a0,92
    80003f8c:	36fd                	addiw	a3,a3,-1
    80003f8e:	1682                	slli	a3,a3,0x20
    80003f90:	9281                	srli	a3,a3,0x20
    80003f92:	068a                	slli	a3,a3,0x2
    80003f94:	0001e617          	auipc	a2,0x1e
    80003f98:	ba860613          	addi	a2,a2,-1112 # 80021b3c <log+0x34>
    80003f9c:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003f9e:	4390                	lw	a2,0(a5)
    80003fa0:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003fa2:	0791                	addi	a5,a5,4
    80003fa4:	0711                	addi	a4,a4,4
    80003fa6:	fed79ce3          	bne	a5,a3,80003f9e <write_head+0x4e>
  }
  bwrite(buf);
    80003faa:	8526                	mv	a0,s1
    80003fac:	fffff097          	auipc	ra,0xfffff
    80003fb0:	0aa080e7          	jalr	170(ra) # 80003056 <bwrite>
  brelse(buf);
    80003fb4:	8526                	mv	a0,s1
    80003fb6:	fffff097          	auipc	ra,0xfffff
    80003fba:	0de080e7          	jalr	222(ra) # 80003094 <brelse>
}
    80003fbe:	60e2                	ld	ra,24(sp)
    80003fc0:	6442                	ld	s0,16(sp)
    80003fc2:	64a2                	ld	s1,8(sp)
    80003fc4:	6902                	ld	s2,0(sp)
    80003fc6:	6105                	addi	sp,sp,32
    80003fc8:	8082                	ret

0000000080003fca <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fca:	0001e797          	auipc	a5,0x1e
    80003fce:	b6a7a783          	lw	a5,-1174(a5) # 80021b34 <log+0x2c>
    80003fd2:	0af05663          	blez	a5,8000407e <install_trans+0xb4>
{
    80003fd6:	7139                	addi	sp,sp,-64
    80003fd8:	fc06                	sd	ra,56(sp)
    80003fda:	f822                	sd	s0,48(sp)
    80003fdc:	f426                	sd	s1,40(sp)
    80003fde:	f04a                	sd	s2,32(sp)
    80003fe0:	ec4e                	sd	s3,24(sp)
    80003fe2:	e852                	sd	s4,16(sp)
    80003fe4:	e456                	sd	s5,8(sp)
    80003fe6:	0080                	addi	s0,sp,64
    80003fe8:	0001ea97          	auipc	s5,0x1e
    80003fec:	b50a8a93          	addi	s5,s5,-1200 # 80021b38 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ff0:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003ff2:	0001e997          	auipc	s3,0x1e
    80003ff6:	b1698993          	addi	s3,s3,-1258 # 80021b08 <log>
    80003ffa:	0189a583          	lw	a1,24(s3)
    80003ffe:	014585bb          	addw	a1,a1,s4
    80004002:	2585                	addiw	a1,a1,1
    80004004:	0289a503          	lw	a0,40(s3)
    80004008:	fffff097          	auipc	ra,0xfffff
    8000400c:	f5c080e7          	jalr	-164(ra) # 80002f64 <bread>
    80004010:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004012:	000aa583          	lw	a1,0(s5)
    80004016:	0289a503          	lw	a0,40(s3)
    8000401a:	fffff097          	auipc	ra,0xfffff
    8000401e:	f4a080e7          	jalr	-182(ra) # 80002f64 <bread>
    80004022:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004024:	40000613          	li	a2,1024
    80004028:	05890593          	addi	a1,s2,88
    8000402c:	05850513          	addi	a0,a0,88
    80004030:	ffffd097          	auipc	ra,0xffffd
    80004034:	d8e080e7          	jalr	-626(ra) # 80000dbe <memmove>
    bwrite(dbuf);  // write dst to disk
    80004038:	8526                	mv	a0,s1
    8000403a:	fffff097          	auipc	ra,0xfffff
    8000403e:	01c080e7          	jalr	28(ra) # 80003056 <bwrite>
    bunpin(dbuf);
    80004042:	8526                	mv	a0,s1
    80004044:	fffff097          	auipc	ra,0xfffff
    80004048:	12a080e7          	jalr	298(ra) # 8000316e <bunpin>
    brelse(lbuf);
    8000404c:	854a                	mv	a0,s2
    8000404e:	fffff097          	auipc	ra,0xfffff
    80004052:	046080e7          	jalr	70(ra) # 80003094 <brelse>
    brelse(dbuf);
    80004056:	8526                	mv	a0,s1
    80004058:	fffff097          	auipc	ra,0xfffff
    8000405c:	03c080e7          	jalr	60(ra) # 80003094 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004060:	2a05                	addiw	s4,s4,1
    80004062:	0a91                	addi	s5,s5,4
    80004064:	02c9a783          	lw	a5,44(s3)
    80004068:	f8fa49e3          	blt	s4,a5,80003ffa <install_trans+0x30>
}
    8000406c:	70e2                	ld	ra,56(sp)
    8000406e:	7442                	ld	s0,48(sp)
    80004070:	74a2                	ld	s1,40(sp)
    80004072:	7902                	ld	s2,32(sp)
    80004074:	69e2                	ld	s3,24(sp)
    80004076:	6a42                	ld	s4,16(sp)
    80004078:	6aa2                	ld	s5,8(sp)
    8000407a:	6121                	addi	sp,sp,64
    8000407c:	8082                	ret
    8000407e:	8082                	ret

0000000080004080 <initlog>:
{
    80004080:	7179                	addi	sp,sp,-48
    80004082:	f406                	sd	ra,40(sp)
    80004084:	f022                	sd	s0,32(sp)
    80004086:	ec26                	sd	s1,24(sp)
    80004088:	e84a                	sd	s2,16(sp)
    8000408a:	e44e                	sd	s3,8(sp)
    8000408c:	1800                	addi	s0,sp,48
    8000408e:	892a                	mv	s2,a0
    80004090:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004092:	0001e497          	auipc	s1,0x1e
    80004096:	a7648493          	addi	s1,s1,-1418 # 80021b08 <log>
    8000409a:	00004597          	auipc	a1,0x4
    8000409e:	63658593          	addi	a1,a1,1590 # 800086d0 <syscalls+0x1e8>
    800040a2:	8526                	mv	a0,s1
    800040a4:	ffffd097          	auipc	ra,0xffffd
    800040a8:	b2e080e7          	jalr	-1234(ra) # 80000bd2 <initlock>
  log.start = sb->logstart;
    800040ac:	0149a583          	lw	a1,20(s3)
    800040b0:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800040b2:	0109a783          	lw	a5,16(s3)
    800040b6:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800040b8:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800040bc:	854a                	mv	a0,s2
    800040be:	fffff097          	auipc	ra,0xfffff
    800040c2:	ea6080e7          	jalr	-346(ra) # 80002f64 <bread>
  log.lh.n = lh->n;
    800040c6:	4d3c                	lw	a5,88(a0)
    800040c8:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800040ca:	02f05563          	blez	a5,800040f4 <initlog+0x74>
    800040ce:	05c50713          	addi	a4,a0,92
    800040d2:	0001e697          	auipc	a3,0x1e
    800040d6:	a6668693          	addi	a3,a3,-1434 # 80021b38 <log+0x30>
    800040da:	37fd                	addiw	a5,a5,-1
    800040dc:	1782                	slli	a5,a5,0x20
    800040de:	9381                	srli	a5,a5,0x20
    800040e0:	078a                	slli	a5,a5,0x2
    800040e2:	06050613          	addi	a2,a0,96
    800040e6:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    800040e8:	4310                	lw	a2,0(a4)
    800040ea:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    800040ec:	0711                	addi	a4,a4,4
    800040ee:	0691                	addi	a3,a3,4
    800040f0:	fef71ce3          	bne	a4,a5,800040e8 <initlog+0x68>
  brelse(buf);
    800040f4:	fffff097          	auipc	ra,0xfffff
    800040f8:	fa0080e7          	jalr	-96(ra) # 80003094 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    800040fc:	00000097          	auipc	ra,0x0
    80004100:	ece080e7          	jalr	-306(ra) # 80003fca <install_trans>
  log.lh.n = 0;
    80004104:	0001e797          	auipc	a5,0x1e
    80004108:	a207a823          	sw	zero,-1488(a5) # 80021b34 <log+0x2c>
  write_head(); // clear the log
    8000410c:	00000097          	auipc	ra,0x0
    80004110:	e44080e7          	jalr	-444(ra) # 80003f50 <write_head>
}
    80004114:	70a2                	ld	ra,40(sp)
    80004116:	7402                	ld	s0,32(sp)
    80004118:	64e2                	ld	s1,24(sp)
    8000411a:	6942                	ld	s2,16(sp)
    8000411c:	69a2                	ld	s3,8(sp)
    8000411e:	6145                	addi	sp,sp,48
    80004120:	8082                	ret

0000000080004122 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004122:	1101                	addi	sp,sp,-32
    80004124:	ec06                	sd	ra,24(sp)
    80004126:	e822                	sd	s0,16(sp)
    80004128:	e426                	sd	s1,8(sp)
    8000412a:	e04a                	sd	s2,0(sp)
    8000412c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000412e:	0001e517          	auipc	a0,0x1e
    80004132:	9da50513          	addi	a0,a0,-1574 # 80021b08 <log>
    80004136:	ffffd097          	auipc	ra,0xffffd
    8000413a:	b2c080e7          	jalr	-1236(ra) # 80000c62 <acquire>
  while(1){
    if(log.committing){
    8000413e:	0001e497          	auipc	s1,0x1e
    80004142:	9ca48493          	addi	s1,s1,-1590 # 80021b08 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004146:	4979                	li	s2,30
    80004148:	a039                	j	80004156 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000414a:	85a6                	mv	a1,s1
    8000414c:	8526                	mv	a0,s1
    8000414e:	ffffe097          	auipc	ra,0xffffe
    80004152:	0fa080e7          	jalr	250(ra) # 80002248 <sleep>
    if(log.committing){
    80004156:	50dc                	lw	a5,36(s1)
    80004158:	fbed                	bnez	a5,8000414a <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000415a:	509c                	lw	a5,32(s1)
    8000415c:	0017871b          	addiw	a4,a5,1
    80004160:	0007069b          	sext.w	a3,a4
    80004164:	0027179b          	slliw	a5,a4,0x2
    80004168:	9fb9                	addw	a5,a5,a4
    8000416a:	0017979b          	slliw	a5,a5,0x1
    8000416e:	54d8                	lw	a4,44(s1)
    80004170:	9fb9                	addw	a5,a5,a4
    80004172:	00f95963          	bge	s2,a5,80004184 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004176:	85a6                	mv	a1,s1
    80004178:	8526                	mv	a0,s1
    8000417a:	ffffe097          	auipc	ra,0xffffe
    8000417e:	0ce080e7          	jalr	206(ra) # 80002248 <sleep>
    80004182:	bfd1                	j	80004156 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004184:	0001e517          	auipc	a0,0x1e
    80004188:	98450513          	addi	a0,a0,-1660 # 80021b08 <log>
    8000418c:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000418e:	ffffd097          	auipc	ra,0xffffd
    80004192:	b88080e7          	jalr	-1144(ra) # 80000d16 <release>
      break;
    }
  }
}
    80004196:	60e2                	ld	ra,24(sp)
    80004198:	6442                	ld	s0,16(sp)
    8000419a:	64a2                	ld	s1,8(sp)
    8000419c:	6902                	ld	s2,0(sp)
    8000419e:	6105                	addi	sp,sp,32
    800041a0:	8082                	ret

00000000800041a2 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800041a2:	7139                	addi	sp,sp,-64
    800041a4:	fc06                	sd	ra,56(sp)
    800041a6:	f822                	sd	s0,48(sp)
    800041a8:	f426                	sd	s1,40(sp)
    800041aa:	f04a                	sd	s2,32(sp)
    800041ac:	ec4e                	sd	s3,24(sp)
    800041ae:	e852                	sd	s4,16(sp)
    800041b0:	e456                	sd	s5,8(sp)
    800041b2:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800041b4:	0001e497          	auipc	s1,0x1e
    800041b8:	95448493          	addi	s1,s1,-1708 # 80021b08 <log>
    800041bc:	8526                	mv	a0,s1
    800041be:	ffffd097          	auipc	ra,0xffffd
    800041c2:	aa4080e7          	jalr	-1372(ra) # 80000c62 <acquire>
  log.outstanding -= 1;
    800041c6:	509c                	lw	a5,32(s1)
    800041c8:	37fd                	addiw	a5,a5,-1
    800041ca:	0007891b          	sext.w	s2,a5
    800041ce:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800041d0:	50dc                	lw	a5,36(s1)
    800041d2:	efb9                	bnez	a5,80004230 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    800041d4:	06091663          	bnez	s2,80004240 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    800041d8:	0001e497          	auipc	s1,0x1e
    800041dc:	93048493          	addi	s1,s1,-1744 # 80021b08 <log>
    800041e0:	4785                	li	a5,1
    800041e2:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800041e4:	8526                	mv	a0,s1
    800041e6:	ffffd097          	auipc	ra,0xffffd
    800041ea:	b30080e7          	jalr	-1232(ra) # 80000d16 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800041ee:	54dc                	lw	a5,44(s1)
    800041f0:	06f04763          	bgtz	a5,8000425e <end_op+0xbc>
    acquire(&log.lock);
    800041f4:	0001e497          	auipc	s1,0x1e
    800041f8:	91448493          	addi	s1,s1,-1772 # 80021b08 <log>
    800041fc:	8526                	mv	a0,s1
    800041fe:	ffffd097          	auipc	ra,0xffffd
    80004202:	a64080e7          	jalr	-1436(ra) # 80000c62 <acquire>
    log.committing = 0;
    80004206:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000420a:	8526                	mv	a0,s1
    8000420c:	ffffe097          	auipc	ra,0xffffe
    80004210:	1c2080e7          	jalr	450(ra) # 800023ce <wakeup>
    release(&log.lock);
    80004214:	8526                	mv	a0,s1
    80004216:	ffffd097          	auipc	ra,0xffffd
    8000421a:	b00080e7          	jalr	-1280(ra) # 80000d16 <release>
}
    8000421e:	70e2                	ld	ra,56(sp)
    80004220:	7442                	ld	s0,48(sp)
    80004222:	74a2                	ld	s1,40(sp)
    80004224:	7902                	ld	s2,32(sp)
    80004226:	69e2                	ld	s3,24(sp)
    80004228:	6a42                	ld	s4,16(sp)
    8000422a:	6aa2                	ld	s5,8(sp)
    8000422c:	6121                	addi	sp,sp,64
    8000422e:	8082                	ret
    panic("log.committing");
    80004230:	00004517          	auipc	a0,0x4
    80004234:	4a850513          	addi	a0,a0,1192 # 800086d8 <syscalls+0x1f0>
    80004238:	ffffc097          	auipc	ra,0xffffc
    8000423c:	310080e7          	jalr	784(ra) # 80000548 <panic>
    wakeup(&log);
    80004240:	0001e497          	auipc	s1,0x1e
    80004244:	8c848493          	addi	s1,s1,-1848 # 80021b08 <log>
    80004248:	8526                	mv	a0,s1
    8000424a:	ffffe097          	auipc	ra,0xffffe
    8000424e:	184080e7          	jalr	388(ra) # 800023ce <wakeup>
  release(&log.lock);
    80004252:	8526                	mv	a0,s1
    80004254:	ffffd097          	auipc	ra,0xffffd
    80004258:	ac2080e7          	jalr	-1342(ra) # 80000d16 <release>
  if(do_commit){
    8000425c:	b7c9                	j	8000421e <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000425e:	0001ea97          	auipc	s5,0x1e
    80004262:	8daa8a93          	addi	s5,s5,-1830 # 80021b38 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004266:	0001ea17          	auipc	s4,0x1e
    8000426a:	8a2a0a13          	addi	s4,s4,-1886 # 80021b08 <log>
    8000426e:	018a2583          	lw	a1,24(s4)
    80004272:	012585bb          	addw	a1,a1,s2
    80004276:	2585                	addiw	a1,a1,1
    80004278:	028a2503          	lw	a0,40(s4)
    8000427c:	fffff097          	auipc	ra,0xfffff
    80004280:	ce8080e7          	jalr	-792(ra) # 80002f64 <bread>
    80004284:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004286:	000aa583          	lw	a1,0(s5)
    8000428a:	028a2503          	lw	a0,40(s4)
    8000428e:	fffff097          	auipc	ra,0xfffff
    80004292:	cd6080e7          	jalr	-810(ra) # 80002f64 <bread>
    80004296:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004298:	40000613          	li	a2,1024
    8000429c:	05850593          	addi	a1,a0,88
    800042a0:	05848513          	addi	a0,s1,88
    800042a4:	ffffd097          	auipc	ra,0xffffd
    800042a8:	b1a080e7          	jalr	-1254(ra) # 80000dbe <memmove>
    bwrite(to);  // write the log
    800042ac:	8526                	mv	a0,s1
    800042ae:	fffff097          	auipc	ra,0xfffff
    800042b2:	da8080e7          	jalr	-600(ra) # 80003056 <bwrite>
    brelse(from);
    800042b6:	854e                	mv	a0,s3
    800042b8:	fffff097          	auipc	ra,0xfffff
    800042bc:	ddc080e7          	jalr	-548(ra) # 80003094 <brelse>
    brelse(to);
    800042c0:	8526                	mv	a0,s1
    800042c2:	fffff097          	auipc	ra,0xfffff
    800042c6:	dd2080e7          	jalr	-558(ra) # 80003094 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042ca:	2905                	addiw	s2,s2,1
    800042cc:	0a91                	addi	s5,s5,4
    800042ce:	02ca2783          	lw	a5,44(s4)
    800042d2:	f8f94ee3          	blt	s2,a5,8000426e <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800042d6:	00000097          	auipc	ra,0x0
    800042da:	c7a080e7          	jalr	-902(ra) # 80003f50 <write_head>
    install_trans(); // Now install writes to home locations
    800042de:	00000097          	auipc	ra,0x0
    800042e2:	cec080e7          	jalr	-788(ra) # 80003fca <install_trans>
    log.lh.n = 0;
    800042e6:	0001e797          	auipc	a5,0x1e
    800042ea:	8407a723          	sw	zero,-1970(a5) # 80021b34 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800042ee:	00000097          	auipc	ra,0x0
    800042f2:	c62080e7          	jalr	-926(ra) # 80003f50 <write_head>
    800042f6:	bdfd                	j	800041f4 <end_op+0x52>

00000000800042f8 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800042f8:	1101                	addi	sp,sp,-32
    800042fa:	ec06                	sd	ra,24(sp)
    800042fc:	e822                	sd	s0,16(sp)
    800042fe:	e426                	sd	s1,8(sp)
    80004300:	e04a                	sd	s2,0(sp)
    80004302:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004304:	0001e717          	auipc	a4,0x1e
    80004308:	83072703          	lw	a4,-2000(a4) # 80021b34 <log+0x2c>
    8000430c:	47f5                	li	a5,29
    8000430e:	08e7c063          	blt	a5,a4,8000438e <log_write+0x96>
    80004312:	84aa                	mv	s1,a0
    80004314:	0001e797          	auipc	a5,0x1e
    80004318:	8107a783          	lw	a5,-2032(a5) # 80021b24 <log+0x1c>
    8000431c:	37fd                	addiw	a5,a5,-1
    8000431e:	06f75863          	bge	a4,a5,8000438e <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004322:	0001e797          	auipc	a5,0x1e
    80004326:	8067a783          	lw	a5,-2042(a5) # 80021b28 <log+0x20>
    8000432a:	06f05a63          	blez	a5,8000439e <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    8000432e:	0001d917          	auipc	s2,0x1d
    80004332:	7da90913          	addi	s2,s2,2010 # 80021b08 <log>
    80004336:	854a                	mv	a0,s2
    80004338:	ffffd097          	auipc	ra,0xffffd
    8000433c:	92a080e7          	jalr	-1750(ra) # 80000c62 <acquire>
  for (i = 0; i < log.lh.n; i++) {
    80004340:	02c92603          	lw	a2,44(s2)
    80004344:	06c05563          	blez	a2,800043ae <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004348:	44cc                	lw	a1,12(s1)
    8000434a:	0001d717          	auipc	a4,0x1d
    8000434e:	7ee70713          	addi	a4,a4,2030 # 80021b38 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004352:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004354:	4314                	lw	a3,0(a4)
    80004356:	04b68d63          	beq	a3,a1,800043b0 <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    8000435a:	2785                	addiw	a5,a5,1
    8000435c:	0711                	addi	a4,a4,4
    8000435e:	fec79be3          	bne	a5,a2,80004354 <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004362:	0621                	addi	a2,a2,8
    80004364:	060a                	slli	a2,a2,0x2
    80004366:	0001d797          	auipc	a5,0x1d
    8000436a:	7a278793          	addi	a5,a5,1954 # 80021b08 <log>
    8000436e:	963e                	add	a2,a2,a5
    80004370:	44dc                	lw	a5,12(s1)
    80004372:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004374:	8526                	mv	a0,s1
    80004376:	fffff097          	auipc	ra,0xfffff
    8000437a:	dbc080e7          	jalr	-580(ra) # 80003132 <bpin>
    log.lh.n++;
    8000437e:	0001d717          	auipc	a4,0x1d
    80004382:	78a70713          	addi	a4,a4,1930 # 80021b08 <log>
    80004386:	575c                	lw	a5,44(a4)
    80004388:	2785                	addiw	a5,a5,1
    8000438a:	d75c                	sw	a5,44(a4)
    8000438c:	a83d                	j	800043ca <log_write+0xd2>
    panic("too big a transaction");
    8000438e:	00004517          	auipc	a0,0x4
    80004392:	35a50513          	addi	a0,a0,858 # 800086e8 <syscalls+0x200>
    80004396:	ffffc097          	auipc	ra,0xffffc
    8000439a:	1b2080e7          	jalr	434(ra) # 80000548 <panic>
    panic("log_write outside of trans");
    8000439e:	00004517          	auipc	a0,0x4
    800043a2:	36250513          	addi	a0,a0,866 # 80008700 <syscalls+0x218>
    800043a6:	ffffc097          	auipc	ra,0xffffc
    800043aa:	1a2080e7          	jalr	418(ra) # 80000548 <panic>
  for (i = 0; i < log.lh.n; i++) {
    800043ae:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    800043b0:	00878713          	addi	a4,a5,8
    800043b4:	00271693          	slli	a3,a4,0x2
    800043b8:	0001d717          	auipc	a4,0x1d
    800043bc:	75070713          	addi	a4,a4,1872 # 80021b08 <log>
    800043c0:	9736                	add	a4,a4,a3
    800043c2:	44d4                	lw	a3,12(s1)
    800043c4:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800043c6:	faf607e3          	beq	a2,a5,80004374 <log_write+0x7c>
  }
  release(&log.lock);
    800043ca:	0001d517          	auipc	a0,0x1d
    800043ce:	73e50513          	addi	a0,a0,1854 # 80021b08 <log>
    800043d2:	ffffd097          	auipc	ra,0xffffd
    800043d6:	944080e7          	jalr	-1724(ra) # 80000d16 <release>
}
    800043da:	60e2                	ld	ra,24(sp)
    800043dc:	6442                	ld	s0,16(sp)
    800043de:	64a2                	ld	s1,8(sp)
    800043e0:	6902                	ld	s2,0(sp)
    800043e2:	6105                	addi	sp,sp,32
    800043e4:	8082                	ret

00000000800043e6 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800043e6:	1101                	addi	sp,sp,-32
    800043e8:	ec06                	sd	ra,24(sp)
    800043ea:	e822                	sd	s0,16(sp)
    800043ec:	e426                	sd	s1,8(sp)
    800043ee:	e04a                	sd	s2,0(sp)
    800043f0:	1000                	addi	s0,sp,32
    800043f2:	84aa                	mv	s1,a0
    800043f4:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800043f6:	00004597          	auipc	a1,0x4
    800043fa:	32a58593          	addi	a1,a1,810 # 80008720 <syscalls+0x238>
    800043fe:	0521                	addi	a0,a0,8
    80004400:	ffffc097          	auipc	ra,0xffffc
    80004404:	7d2080e7          	jalr	2002(ra) # 80000bd2 <initlock>
  lk->name = name;
    80004408:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000440c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004410:	0204a423          	sw	zero,40(s1)
}
    80004414:	60e2                	ld	ra,24(sp)
    80004416:	6442                	ld	s0,16(sp)
    80004418:	64a2                	ld	s1,8(sp)
    8000441a:	6902                	ld	s2,0(sp)
    8000441c:	6105                	addi	sp,sp,32
    8000441e:	8082                	ret

0000000080004420 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004420:	1101                	addi	sp,sp,-32
    80004422:	ec06                	sd	ra,24(sp)
    80004424:	e822                	sd	s0,16(sp)
    80004426:	e426                	sd	s1,8(sp)
    80004428:	e04a                	sd	s2,0(sp)
    8000442a:	1000                	addi	s0,sp,32
    8000442c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000442e:	00850913          	addi	s2,a0,8
    80004432:	854a                	mv	a0,s2
    80004434:	ffffd097          	auipc	ra,0xffffd
    80004438:	82e080e7          	jalr	-2002(ra) # 80000c62 <acquire>
  while (lk->locked) {
    8000443c:	409c                	lw	a5,0(s1)
    8000443e:	cb89                	beqz	a5,80004450 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004440:	85ca                	mv	a1,s2
    80004442:	8526                	mv	a0,s1
    80004444:	ffffe097          	auipc	ra,0xffffe
    80004448:	e04080e7          	jalr	-508(ra) # 80002248 <sleep>
  while (lk->locked) {
    8000444c:	409c                	lw	a5,0(s1)
    8000444e:	fbed                	bnez	a5,80004440 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004450:	4785                	li	a5,1
    80004452:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004454:	ffffd097          	auipc	ra,0xffffd
    80004458:	5dc080e7          	jalr	1500(ra) # 80001a30 <myproc>
    8000445c:	5d1c                	lw	a5,56(a0)
    8000445e:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004460:	854a                	mv	a0,s2
    80004462:	ffffd097          	auipc	ra,0xffffd
    80004466:	8b4080e7          	jalr	-1868(ra) # 80000d16 <release>
}
    8000446a:	60e2                	ld	ra,24(sp)
    8000446c:	6442                	ld	s0,16(sp)
    8000446e:	64a2                	ld	s1,8(sp)
    80004470:	6902                	ld	s2,0(sp)
    80004472:	6105                	addi	sp,sp,32
    80004474:	8082                	ret

0000000080004476 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004476:	1101                	addi	sp,sp,-32
    80004478:	ec06                	sd	ra,24(sp)
    8000447a:	e822                	sd	s0,16(sp)
    8000447c:	e426                	sd	s1,8(sp)
    8000447e:	e04a                	sd	s2,0(sp)
    80004480:	1000                	addi	s0,sp,32
    80004482:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004484:	00850913          	addi	s2,a0,8
    80004488:	854a                	mv	a0,s2
    8000448a:	ffffc097          	auipc	ra,0xffffc
    8000448e:	7d8080e7          	jalr	2008(ra) # 80000c62 <acquire>
  lk->locked = 0;
    80004492:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004496:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000449a:	8526                	mv	a0,s1
    8000449c:	ffffe097          	auipc	ra,0xffffe
    800044a0:	f32080e7          	jalr	-206(ra) # 800023ce <wakeup>
  release(&lk->lk);
    800044a4:	854a                	mv	a0,s2
    800044a6:	ffffd097          	auipc	ra,0xffffd
    800044aa:	870080e7          	jalr	-1936(ra) # 80000d16 <release>
}
    800044ae:	60e2                	ld	ra,24(sp)
    800044b0:	6442                	ld	s0,16(sp)
    800044b2:	64a2                	ld	s1,8(sp)
    800044b4:	6902                	ld	s2,0(sp)
    800044b6:	6105                	addi	sp,sp,32
    800044b8:	8082                	ret

00000000800044ba <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800044ba:	7179                	addi	sp,sp,-48
    800044bc:	f406                	sd	ra,40(sp)
    800044be:	f022                	sd	s0,32(sp)
    800044c0:	ec26                	sd	s1,24(sp)
    800044c2:	e84a                	sd	s2,16(sp)
    800044c4:	e44e                	sd	s3,8(sp)
    800044c6:	1800                	addi	s0,sp,48
    800044c8:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800044ca:	00850913          	addi	s2,a0,8
    800044ce:	854a                	mv	a0,s2
    800044d0:	ffffc097          	auipc	ra,0xffffc
    800044d4:	792080e7          	jalr	1938(ra) # 80000c62 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800044d8:	409c                	lw	a5,0(s1)
    800044da:	ef99                	bnez	a5,800044f8 <holdingsleep+0x3e>
    800044dc:	4481                	li	s1,0
  release(&lk->lk);
    800044de:	854a                	mv	a0,s2
    800044e0:	ffffd097          	auipc	ra,0xffffd
    800044e4:	836080e7          	jalr	-1994(ra) # 80000d16 <release>
  return r;
}
    800044e8:	8526                	mv	a0,s1
    800044ea:	70a2                	ld	ra,40(sp)
    800044ec:	7402                	ld	s0,32(sp)
    800044ee:	64e2                	ld	s1,24(sp)
    800044f0:	6942                	ld	s2,16(sp)
    800044f2:	69a2                	ld	s3,8(sp)
    800044f4:	6145                	addi	sp,sp,48
    800044f6:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800044f8:	0284a983          	lw	s3,40(s1)
    800044fc:	ffffd097          	auipc	ra,0xffffd
    80004500:	534080e7          	jalr	1332(ra) # 80001a30 <myproc>
    80004504:	5d04                	lw	s1,56(a0)
    80004506:	413484b3          	sub	s1,s1,s3
    8000450a:	0014b493          	seqz	s1,s1
    8000450e:	bfc1                	j	800044de <holdingsleep+0x24>

0000000080004510 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004510:	1141                	addi	sp,sp,-16
    80004512:	e406                	sd	ra,8(sp)
    80004514:	e022                	sd	s0,0(sp)
    80004516:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004518:	00004597          	auipc	a1,0x4
    8000451c:	21858593          	addi	a1,a1,536 # 80008730 <syscalls+0x248>
    80004520:	0001d517          	auipc	a0,0x1d
    80004524:	73050513          	addi	a0,a0,1840 # 80021c50 <ftable>
    80004528:	ffffc097          	auipc	ra,0xffffc
    8000452c:	6aa080e7          	jalr	1706(ra) # 80000bd2 <initlock>
}
    80004530:	60a2                	ld	ra,8(sp)
    80004532:	6402                	ld	s0,0(sp)
    80004534:	0141                	addi	sp,sp,16
    80004536:	8082                	ret

0000000080004538 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004538:	1101                	addi	sp,sp,-32
    8000453a:	ec06                	sd	ra,24(sp)
    8000453c:	e822                	sd	s0,16(sp)
    8000453e:	e426                	sd	s1,8(sp)
    80004540:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004542:	0001d517          	auipc	a0,0x1d
    80004546:	70e50513          	addi	a0,a0,1806 # 80021c50 <ftable>
    8000454a:	ffffc097          	auipc	ra,0xffffc
    8000454e:	718080e7          	jalr	1816(ra) # 80000c62 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004552:	0001d497          	auipc	s1,0x1d
    80004556:	71648493          	addi	s1,s1,1814 # 80021c68 <ftable+0x18>
    8000455a:	0001e717          	auipc	a4,0x1e
    8000455e:	6ae70713          	addi	a4,a4,1710 # 80022c08 <ftable+0xfb8>
    if(f->ref == 0){
    80004562:	40dc                	lw	a5,4(s1)
    80004564:	cf99                	beqz	a5,80004582 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004566:	02848493          	addi	s1,s1,40
    8000456a:	fee49ce3          	bne	s1,a4,80004562 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000456e:	0001d517          	auipc	a0,0x1d
    80004572:	6e250513          	addi	a0,a0,1762 # 80021c50 <ftable>
    80004576:	ffffc097          	auipc	ra,0xffffc
    8000457a:	7a0080e7          	jalr	1952(ra) # 80000d16 <release>
  return 0;
    8000457e:	4481                	li	s1,0
    80004580:	a819                	j	80004596 <filealloc+0x5e>
      f->ref = 1;
    80004582:	4785                	li	a5,1
    80004584:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004586:	0001d517          	auipc	a0,0x1d
    8000458a:	6ca50513          	addi	a0,a0,1738 # 80021c50 <ftable>
    8000458e:	ffffc097          	auipc	ra,0xffffc
    80004592:	788080e7          	jalr	1928(ra) # 80000d16 <release>
}
    80004596:	8526                	mv	a0,s1
    80004598:	60e2                	ld	ra,24(sp)
    8000459a:	6442                	ld	s0,16(sp)
    8000459c:	64a2                	ld	s1,8(sp)
    8000459e:	6105                	addi	sp,sp,32
    800045a0:	8082                	ret

00000000800045a2 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800045a2:	1101                	addi	sp,sp,-32
    800045a4:	ec06                	sd	ra,24(sp)
    800045a6:	e822                	sd	s0,16(sp)
    800045a8:	e426                	sd	s1,8(sp)
    800045aa:	1000                	addi	s0,sp,32
    800045ac:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800045ae:	0001d517          	auipc	a0,0x1d
    800045b2:	6a250513          	addi	a0,a0,1698 # 80021c50 <ftable>
    800045b6:	ffffc097          	auipc	ra,0xffffc
    800045ba:	6ac080e7          	jalr	1708(ra) # 80000c62 <acquire>
  if(f->ref < 1)
    800045be:	40dc                	lw	a5,4(s1)
    800045c0:	02f05263          	blez	a5,800045e4 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800045c4:	2785                	addiw	a5,a5,1
    800045c6:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800045c8:	0001d517          	auipc	a0,0x1d
    800045cc:	68850513          	addi	a0,a0,1672 # 80021c50 <ftable>
    800045d0:	ffffc097          	auipc	ra,0xffffc
    800045d4:	746080e7          	jalr	1862(ra) # 80000d16 <release>
  return f;
}
    800045d8:	8526                	mv	a0,s1
    800045da:	60e2                	ld	ra,24(sp)
    800045dc:	6442                	ld	s0,16(sp)
    800045de:	64a2                	ld	s1,8(sp)
    800045e0:	6105                	addi	sp,sp,32
    800045e2:	8082                	ret
    panic("filedup");
    800045e4:	00004517          	auipc	a0,0x4
    800045e8:	15450513          	addi	a0,a0,340 # 80008738 <syscalls+0x250>
    800045ec:	ffffc097          	auipc	ra,0xffffc
    800045f0:	f5c080e7          	jalr	-164(ra) # 80000548 <panic>

00000000800045f4 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800045f4:	7139                	addi	sp,sp,-64
    800045f6:	fc06                	sd	ra,56(sp)
    800045f8:	f822                	sd	s0,48(sp)
    800045fa:	f426                	sd	s1,40(sp)
    800045fc:	f04a                	sd	s2,32(sp)
    800045fe:	ec4e                	sd	s3,24(sp)
    80004600:	e852                	sd	s4,16(sp)
    80004602:	e456                	sd	s5,8(sp)
    80004604:	0080                	addi	s0,sp,64
    80004606:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004608:	0001d517          	auipc	a0,0x1d
    8000460c:	64850513          	addi	a0,a0,1608 # 80021c50 <ftable>
    80004610:	ffffc097          	auipc	ra,0xffffc
    80004614:	652080e7          	jalr	1618(ra) # 80000c62 <acquire>
  if(f->ref < 1)
    80004618:	40dc                	lw	a5,4(s1)
    8000461a:	06f05163          	blez	a5,8000467c <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    8000461e:	37fd                	addiw	a5,a5,-1
    80004620:	0007871b          	sext.w	a4,a5
    80004624:	c0dc                	sw	a5,4(s1)
    80004626:	06e04363          	bgtz	a4,8000468c <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000462a:	0004a903          	lw	s2,0(s1)
    8000462e:	0094ca83          	lbu	s5,9(s1)
    80004632:	0104ba03          	ld	s4,16(s1)
    80004636:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000463a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000463e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004642:	0001d517          	auipc	a0,0x1d
    80004646:	60e50513          	addi	a0,a0,1550 # 80021c50 <ftable>
    8000464a:	ffffc097          	auipc	ra,0xffffc
    8000464e:	6cc080e7          	jalr	1740(ra) # 80000d16 <release>

  if(ff.type == FD_PIPE){
    80004652:	4785                	li	a5,1
    80004654:	04f90d63          	beq	s2,a5,800046ae <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004658:	3979                	addiw	s2,s2,-2
    8000465a:	4785                	li	a5,1
    8000465c:	0527e063          	bltu	a5,s2,8000469c <fileclose+0xa8>
    begin_op();
    80004660:	00000097          	auipc	ra,0x0
    80004664:	ac2080e7          	jalr	-1342(ra) # 80004122 <begin_op>
    iput(ff.ip);
    80004668:	854e                	mv	a0,s3
    8000466a:	fffff097          	auipc	ra,0xfffff
    8000466e:	2b6080e7          	jalr	694(ra) # 80003920 <iput>
    end_op();
    80004672:	00000097          	auipc	ra,0x0
    80004676:	b30080e7          	jalr	-1232(ra) # 800041a2 <end_op>
    8000467a:	a00d                	j	8000469c <fileclose+0xa8>
    panic("fileclose");
    8000467c:	00004517          	auipc	a0,0x4
    80004680:	0c450513          	addi	a0,a0,196 # 80008740 <syscalls+0x258>
    80004684:	ffffc097          	auipc	ra,0xffffc
    80004688:	ec4080e7          	jalr	-316(ra) # 80000548 <panic>
    release(&ftable.lock);
    8000468c:	0001d517          	auipc	a0,0x1d
    80004690:	5c450513          	addi	a0,a0,1476 # 80021c50 <ftable>
    80004694:	ffffc097          	auipc	ra,0xffffc
    80004698:	682080e7          	jalr	1666(ra) # 80000d16 <release>
  }
}
    8000469c:	70e2                	ld	ra,56(sp)
    8000469e:	7442                	ld	s0,48(sp)
    800046a0:	74a2                	ld	s1,40(sp)
    800046a2:	7902                	ld	s2,32(sp)
    800046a4:	69e2                	ld	s3,24(sp)
    800046a6:	6a42                	ld	s4,16(sp)
    800046a8:	6aa2                	ld	s5,8(sp)
    800046aa:	6121                	addi	sp,sp,64
    800046ac:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800046ae:	85d6                	mv	a1,s5
    800046b0:	8552                	mv	a0,s4
    800046b2:	00000097          	auipc	ra,0x0
    800046b6:	372080e7          	jalr	882(ra) # 80004a24 <pipeclose>
    800046ba:	b7cd                	j	8000469c <fileclose+0xa8>

00000000800046bc <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800046bc:	715d                	addi	sp,sp,-80
    800046be:	e486                	sd	ra,72(sp)
    800046c0:	e0a2                	sd	s0,64(sp)
    800046c2:	fc26                	sd	s1,56(sp)
    800046c4:	f84a                	sd	s2,48(sp)
    800046c6:	f44e                	sd	s3,40(sp)
    800046c8:	0880                	addi	s0,sp,80
    800046ca:	84aa                	mv	s1,a0
    800046cc:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800046ce:	ffffd097          	auipc	ra,0xffffd
    800046d2:	362080e7          	jalr	866(ra) # 80001a30 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800046d6:	409c                	lw	a5,0(s1)
    800046d8:	37f9                	addiw	a5,a5,-2
    800046da:	4705                	li	a4,1
    800046dc:	04f76763          	bltu	a4,a5,8000472a <filestat+0x6e>
    800046e0:	892a                	mv	s2,a0
    ilock(f->ip);
    800046e2:	6c88                	ld	a0,24(s1)
    800046e4:	fffff097          	auipc	ra,0xfffff
    800046e8:	082080e7          	jalr	130(ra) # 80003766 <ilock>
    stati(f->ip, &st);
    800046ec:	fb840593          	addi	a1,s0,-72
    800046f0:	6c88                	ld	a0,24(s1)
    800046f2:	fffff097          	auipc	ra,0xfffff
    800046f6:	2fe080e7          	jalr	766(ra) # 800039f0 <stati>
    iunlock(f->ip);
    800046fa:	6c88                	ld	a0,24(s1)
    800046fc:	fffff097          	auipc	ra,0xfffff
    80004700:	12c080e7          	jalr	300(ra) # 80003828 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004704:	46e1                	li	a3,24
    80004706:	fb840613          	addi	a2,s0,-72
    8000470a:	85ce                	mv	a1,s3
    8000470c:	05093503          	ld	a0,80(s2)
    80004710:	ffffd097          	auipc	ra,0xffffd
    80004714:	014080e7          	jalr	20(ra) # 80001724 <copyout>
    80004718:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000471c:	60a6                	ld	ra,72(sp)
    8000471e:	6406                	ld	s0,64(sp)
    80004720:	74e2                	ld	s1,56(sp)
    80004722:	7942                	ld	s2,48(sp)
    80004724:	79a2                	ld	s3,40(sp)
    80004726:	6161                	addi	sp,sp,80
    80004728:	8082                	ret
  return -1;
    8000472a:	557d                	li	a0,-1
    8000472c:	bfc5                	j	8000471c <filestat+0x60>

000000008000472e <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000472e:	7179                	addi	sp,sp,-48
    80004730:	f406                	sd	ra,40(sp)
    80004732:	f022                	sd	s0,32(sp)
    80004734:	ec26                	sd	s1,24(sp)
    80004736:	e84a                	sd	s2,16(sp)
    80004738:	e44e                	sd	s3,8(sp)
    8000473a:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000473c:	00854783          	lbu	a5,8(a0)
    80004740:	c3d5                	beqz	a5,800047e4 <fileread+0xb6>
    80004742:	84aa                	mv	s1,a0
    80004744:	89ae                	mv	s3,a1
    80004746:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004748:	411c                	lw	a5,0(a0)
    8000474a:	4705                	li	a4,1
    8000474c:	04e78963          	beq	a5,a4,8000479e <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004750:	470d                	li	a4,3
    80004752:	04e78d63          	beq	a5,a4,800047ac <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004756:	4709                	li	a4,2
    80004758:	06e79e63          	bne	a5,a4,800047d4 <fileread+0xa6>
    ilock(f->ip);
    8000475c:	6d08                	ld	a0,24(a0)
    8000475e:	fffff097          	auipc	ra,0xfffff
    80004762:	008080e7          	jalr	8(ra) # 80003766 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004766:	874a                	mv	a4,s2
    80004768:	5094                	lw	a3,32(s1)
    8000476a:	864e                	mv	a2,s3
    8000476c:	4585                	li	a1,1
    8000476e:	6c88                	ld	a0,24(s1)
    80004770:	fffff097          	auipc	ra,0xfffff
    80004774:	2aa080e7          	jalr	682(ra) # 80003a1a <readi>
    80004778:	892a                	mv	s2,a0
    8000477a:	00a05563          	blez	a0,80004784 <fileread+0x56>
      f->off += r;
    8000477e:	509c                	lw	a5,32(s1)
    80004780:	9fa9                	addw	a5,a5,a0
    80004782:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004784:	6c88                	ld	a0,24(s1)
    80004786:	fffff097          	auipc	ra,0xfffff
    8000478a:	0a2080e7          	jalr	162(ra) # 80003828 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000478e:	854a                	mv	a0,s2
    80004790:	70a2                	ld	ra,40(sp)
    80004792:	7402                	ld	s0,32(sp)
    80004794:	64e2                	ld	s1,24(sp)
    80004796:	6942                	ld	s2,16(sp)
    80004798:	69a2                	ld	s3,8(sp)
    8000479a:	6145                	addi	sp,sp,48
    8000479c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000479e:	6908                	ld	a0,16(a0)
    800047a0:	00000097          	auipc	ra,0x0
    800047a4:	418080e7          	jalr	1048(ra) # 80004bb8 <piperead>
    800047a8:	892a                	mv	s2,a0
    800047aa:	b7d5                	j	8000478e <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800047ac:	02451783          	lh	a5,36(a0)
    800047b0:	03079693          	slli	a3,a5,0x30
    800047b4:	92c1                	srli	a3,a3,0x30
    800047b6:	4725                	li	a4,9
    800047b8:	02d76863          	bltu	a4,a3,800047e8 <fileread+0xba>
    800047bc:	0792                	slli	a5,a5,0x4
    800047be:	0001d717          	auipc	a4,0x1d
    800047c2:	3f270713          	addi	a4,a4,1010 # 80021bb0 <devsw>
    800047c6:	97ba                	add	a5,a5,a4
    800047c8:	639c                	ld	a5,0(a5)
    800047ca:	c38d                	beqz	a5,800047ec <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800047cc:	4505                	li	a0,1
    800047ce:	9782                	jalr	a5
    800047d0:	892a                	mv	s2,a0
    800047d2:	bf75                	j	8000478e <fileread+0x60>
    panic("fileread");
    800047d4:	00004517          	auipc	a0,0x4
    800047d8:	f7c50513          	addi	a0,a0,-132 # 80008750 <syscalls+0x268>
    800047dc:	ffffc097          	auipc	ra,0xffffc
    800047e0:	d6c080e7          	jalr	-660(ra) # 80000548 <panic>
    return -1;
    800047e4:	597d                	li	s2,-1
    800047e6:	b765                	j	8000478e <fileread+0x60>
      return -1;
    800047e8:	597d                	li	s2,-1
    800047ea:	b755                	j	8000478e <fileread+0x60>
    800047ec:	597d                	li	s2,-1
    800047ee:	b745                	j	8000478e <fileread+0x60>

00000000800047f0 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800047f0:	00954783          	lbu	a5,9(a0)
    800047f4:	14078563          	beqz	a5,8000493e <filewrite+0x14e>
{
    800047f8:	715d                	addi	sp,sp,-80
    800047fa:	e486                	sd	ra,72(sp)
    800047fc:	e0a2                	sd	s0,64(sp)
    800047fe:	fc26                	sd	s1,56(sp)
    80004800:	f84a                	sd	s2,48(sp)
    80004802:	f44e                	sd	s3,40(sp)
    80004804:	f052                	sd	s4,32(sp)
    80004806:	ec56                	sd	s5,24(sp)
    80004808:	e85a                	sd	s6,16(sp)
    8000480a:	e45e                	sd	s7,8(sp)
    8000480c:	e062                	sd	s8,0(sp)
    8000480e:	0880                	addi	s0,sp,80
    80004810:	892a                	mv	s2,a0
    80004812:	8aae                	mv	s5,a1
    80004814:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004816:	411c                	lw	a5,0(a0)
    80004818:	4705                	li	a4,1
    8000481a:	02e78263          	beq	a5,a4,8000483e <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000481e:	470d                	li	a4,3
    80004820:	02e78563          	beq	a5,a4,8000484a <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004824:	4709                	li	a4,2
    80004826:	10e79463          	bne	a5,a4,8000492e <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000482a:	0ec05e63          	blez	a2,80004926 <filewrite+0x136>
    int i = 0;
    8000482e:	4981                	li	s3,0
    80004830:	6b05                	lui	s6,0x1
    80004832:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004836:	6b85                	lui	s7,0x1
    80004838:	c00b8b9b          	addiw	s7,s7,-1024
    8000483c:	a851                	j	800048d0 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    8000483e:	6908                	ld	a0,16(a0)
    80004840:	00000097          	auipc	ra,0x0
    80004844:	254080e7          	jalr	596(ra) # 80004a94 <pipewrite>
    80004848:	a85d                	j	800048fe <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000484a:	02451783          	lh	a5,36(a0)
    8000484e:	03079693          	slli	a3,a5,0x30
    80004852:	92c1                	srli	a3,a3,0x30
    80004854:	4725                	li	a4,9
    80004856:	0ed76663          	bltu	a4,a3,80004942 <filewrite+0x152>
    8000485a:	0792                	slli	a5,a5,0x4
    8000485c:	0001d717          	auipc	a4,0x1d
    80004860:	35470713          	addi	a4,a4,852 # 80021bb0 <devsw>
    80004864:	97ba                	add	a5,a5,a4
    80004866:	679c                	ld	a5,8(a5)
    80004868:	cff9                	beqz	a5,80004946 <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    8000486a:	4505                	li	a0,1
    8000486c:	9782                	jalr	a5
    8000486e:	a841                	j	800048fe <filewrite+0x10e>
    80004870:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004874:	00000097          	auipc	ra,0x0
    80004878:	8ae080e7          	jalr	-1874(ra) # 80004122 <begin_op>
      ilock(f->ip);
    8000487c:	01893503          	ld	a0,24(s2)
    80004880:	fffff097          	auipc	ra,0xfffff
    80004884:	ee6080e7          	jalr	-282(ra) # 80003766 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004888:	8762                	mv	a4,s8
    8000488a:	02092683          	lw	a3,32(s2)
    8000488e:	01598633          	add	a2,s3,s5
    80004892:	4585                	li	a1,1
    80004894:	01893503          	ld	a0,24(s2)
    80004898:	fffff097          	auipc	ra,0xfffff
    8000489c:	278080e7          	jalr	632(ra) # 80003b10 <writei>
    800048a0:	84aa                	mv	s1,a0
    800048a2:	02a05f63          	blez	a0,800048e0 <filewrite+0xf0>
        f->off += r;
    800048a6:	02092783          	lw	a5,32(s2)
    800048aa:	9fa9                	addw	a5,a5,a0
    800048ac:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800048b0:	01893503          	ld	a0,24(s2)
    800048b4:	fffff097          	auipc	ra,0xfffff
    800048b8:	f74080e7          	jalr	-140(ra) # 80003828 <iunlock>
      end_op();
    800048bc:	00000097          	auipc	ra,0x0
    800048c0:	8e6080e7          	jalr	-1818(ra) # 800041a2 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    800048c4:	049c1963          	bne	s8,s1,80004916 <filewrite+0x126>
        panic("short filewrite");
      i += r;
    800048c8:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800048cc:	0349d663          	bge	s3,s4,800048f8 <filewrite+0x108>
      int n1 = n - i;
    800048d0:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800048d4:	84be                	mv	s1,a5
    800048d6:	2781                	sext.w	a5,a5
    800048d8:	f8fb5ce3          	bge	s6,a5,80004870 <filewrite+0x80>
    800048dc:	84de                	mv	s1,s7
    800048de:	bf49                	j	80004870 <filewrite+0x80>
      iunlock(f->ip);
    800048e0:	01893503          	ld	a0,24(s2)
    800048e4:	fffff097          	auipc	ra,0xfffff
    800048e8:	f44080e7          	jalr	-188(ra) # 80003828 <iunlock>
      end_op();
    800048ec:	00000097          	auipc	ra,0x0
    800048f0:	8b6080e7          	jalr	-1866(ra) # 800041a2 <end_op>
      if(r < 0)
    800048f4:	fc04d8e3          	bgez	s1,800048c4 <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    800048f8:	8552                	mv	a0,s4
    800048fa:	033a1863          	bne	s4,s3,8000492a <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800048fe:	60a6                	ld	ra,72(sp)
    80004900:	6406                	ld	s0,64(sp)
    80004902:	74e2                	ld	s1,56(sp)
    80004904:	7942                	ld	s2,48(sp)
    80004906:	79a2                	ld	s3,40(sp)
    80004908:	7a02                	ld	s4,32(sp)
    8000490a:	6ae2                	ld	s5,24(sp)
    8000490c:	6b42                	ld	s6,16(sp)
    8000490e:	6ba2                	ld	s7,8(sp)
    80004910:	6c02                	ld	s8,0(sp)
    80004912:	6161                	addi	sp,sp,80
    80004914:	8082                	ret
        panic("short filewrite");
    80004916:	00004517          	auipc	a0,0x4
    8000491a:	e4a50513          	addi	a0,a0,-438 # 80008760 <syscalls+0x278>
    8000491e:	ffffc097          	auipc	ra,0xffffc
    80004922:	c2a080e7          	jalr	-982(ra) # 80000548 <panic>
    int i = 0;
    80004926:	4981                	li	s3,0
    80004928:	bfc1                	j	800048f8 <filewrite+0x108>
    ret = (i == n ? n : -1);
    8000492a:	557d                	li	a0,-1
    8000492c:	bfc9                	j	800048fe <filewrite+0x10e>
    panic("filewrite");
    8000492e:	00004517          	auipc	a0,0x4
    80004932:	e4250513          	addi	a0,a0,-446 # 80008770 <syscalls+0x288>
    80004936:	ffffc097          	auipc	ra,0xffffc
    8000493a:	c12080e7          	jalr	-1006(ra) # 80000548 <panic>
    return -1;
    8000493e:	557d                	li	a0,-1
}
    80004940:	8082                	ret
      return -1;
    80004942:	557d                	li	a0,-1
    80004944:	bf6d                	j	800048fe <filewrite+0x10e>
    80004946:	557d                	li	a0,-1
    80004948:	bf5d                	j	800048fe <filewrite+0x10e>

000000008000494a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000494a:	7179                	addi	sp,sp,-48
    8000494c:	f406                	sd	ra,40(sp)
    8000494e:	f022                	sd	s0,32(sp)
    80004950:	ec26                	sd	s1,24(sp)
    80004952:	e84a                	sd	s2,16(sp)
    80004954:	e44e                	sd	s3,8(sp)
    80004956:	e052                	sd	s4,0(sp)
    80004958:	1800                	addi	s0,sp,48
    8000495a:	84aa                	mv	s1,a0
    8000495c:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000495e:	0005b023          	sd	zero,0(a1)
    80004962:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004966:	00000097          	auipc	ra,0x0
    8000496a:	bd2080e7          	jalr	-1070(ra) # 80004538 <filealloc>
    8000496e:	e088                	sd	a0,0(s1)
    80004970:	c551                	beqz	a0,800049fc <pipealloc+0xb2>
    80004972:	00000097          	auipc	ra,0x0
    80004976:	bc6080e7          	jalr	-1082(ra) # 80004538 <filealloc>
    8000497a:	00aa3023          	sd	a0,0(s4)
    8000497e:	c92d                	beqz	a0,800049f0 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004980:	ffffc097          	auipc	ra,0xffffc
    80004984:	1a0080e7          	jalr	416(ra) # 80000b20 <kalloc>
    80004988:	892a                	mv	s2,a0
    8000498a:	c125                	beqz	a0,800049ea <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    8000498c:	4985                	li	s3,1
    8000498e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004992:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004996:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000499a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000499e:	00004597          	auipc	a1,0x4
    800049a2:	aa258593          	addi	a1,a1,-1374 # 80008440 <states.1707+0x198>
    800049a6:	ffffc097          	auipc	ra,0xffffc
    800049aa:	22c080e7          	jalr	556(ra) # 80000bd2 <initlock>
  (*f0)->type = FD_PIPE;
    800049ae:	609c                	ld	a5,0(s1)
    800049b0:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800049b4:	609c                	ld	a5,0(s1)
    800049b6:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800049ba:	609c                	ld	a5,0(s1)
    800049bc:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800049c0:	609c                	ld	a5,0(s1)
    800049c2:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800049c6:	000a3783          	ld	a5,0(s4)
    800049ca:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800049ce:	000a3783          	ld	a5,0(s4)
    800049d2:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800049d6:	000a3783          	ld	a5,0(s4)
    800049da:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800049de:	000a3783          	ld	a5,0(s4)
    800049e2:	0127b823          	sd	s2,16(a5)
  return 0;
    800049e6:	4501                	li	a0,0
    800049e8:	a025                	j	80004a10 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800049ea:	6088                	ld	a0,0(s1)
    800049ec:	e501                	bnez	a0,800049f4 <pipealloc+0xaa>
    800049ee:	a039                	j	800049fc <pipealloc+0xb2>
    800049f0:	6088                	ld	a0,0(s1)
    800049f2:	c51d                	beqz	a0,80004a20 <pipealloc+0xd6>
    fileclose(*f0);
    800049f4:	00000097          	auipc	ra,0x0
    800049f8:	c00080e7          	jalr	-1024(ra) # 800045f4 <fileclose>
  if(*f1)
    800049fc:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004a00:	557d                	li	a0,-1
  if(*f1)
    80004a02:	c799                	beqz	a5,80004a10 <pipealloc+0xc6>
    fileclose(*f1);
    80004a04:	853e                	mv	a0,a5
    80004a06:	00000097          	auipc	ra,0x0
    80004a0a:	bee080e7          	jalr	-1042(ra) # 800045f4 <fileclose>
  return -1;
    80004a0e:	557d                	li	a0,-1
}
    80004a10:	70a2                	ld	ra,40(sp)
    80004a12:	7402                	ld	s0,32(sp)
    80004a14:	64e2                	ld	s1,24(sp)
    80004a16:	6942                	ld	s2,16(sp)
    80004a18:	69a2                	ld	s3,8(sp)
    80004a1a:	6a02                	ld	s4,0(sp)
    80004a1c:	6145                	addi	sp,sp,48
    80004a1e:	8082                	ret
  return -1;
    80004a20:	557d                	li	a0,-1
    80004a22:	b7fd                	j	80004a10 <pipealloc+0xc6>

0000000080004a24 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004a24:	1101                	addi	sp,sp,-32
    80004a26:	ec06                	sd	ra,24(sp)
    80004a28:	e822                	sd	s0,16(sp)
    80004a2a:	e426                	sd	s1,8(sp)
    80004a2c:	e04a                	sd	s2,0(sp)
    80004a2e:	1000                	addi	s0,sp,32
    80004a30:	84aa                	mv	s1,a0
    80004a32:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004a34:	ffffc097          	auipc	ra,0xffffc
    80004a38:	22e080e7          	jalr	558(ra) # 80000c62 <acquire>
  if(writable){
    80004a3c:	02090d63          	beqz	s2,80004a76 <pipeclose+0x52>
    pi->writeopen = 0;
    80004a40:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004a44:	21848513          	addi	a0,s1,536
    80004a48:	ffffe097          	auipc	ra,0xffffe
    80004a4c:	986080e7          	jalr	-1658(ra) # 800023ce <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004a50:	2204b783          	ld	a5,544(s1)
    80004a54:	eb95                	bnez	a5,80004a88 <pipeclose+0x64>
    release(&pi->lock);
    80004a56:	8526                	mv	a0,s1
    80004a58:	ffffc097          	auipc	ra,0xffffc
    80004a5c:	2be080e7          	jalr	702(ra) # 80000d16 <release>
    kfree((char*)pi);
    80004a60:	8526                	mv	a0,s1
    80004a62:	ffffc097          	auipc	ra,0xffffc
    80004a66:	fc2080e7          	jalr	-62(ra) # 80000a24 <kfree>
  } else
    release(&pi->lock);
}
    80004a6a:	60e2                	ld	ra,24(sp)
    80004a6c:	6442                	ld	s0,16(sp)
    80004a6e:	64a2                	ld	s1,8(sp)
    80004a70:	6902                	ld	s2,0(sp)
    80004a72:	6105                	addi	sp,sp,32
    80004a74:	8082                	ret
    pi->readopen = 0;
    80004a76:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004a7a:	21c48513          	addi	a0,s1,540
    80004a7e:	ffffe097          	auipc	ra,0xffffe
    80004a82:	950080e7          	jalr	-1712(ra) # 800023ce <wakeup>
    80004a86:	b7e9                	j	80004a50 <pipeclose+0x2c>
    release(&pi->lock);
    80004a88:	8526                	mv	a0,s1
    80004a8a:	ffffc097          	auipc	ra,0xffffc
    80004a8e:	28c080e7          	jalr	652(ra) # 80000d16 <release>
}
    80004a92:	bfe1                	j	80004a6a <pipeclose+0x46>

0000000080004a94 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004a94:	7119                	addi	sp,sp,-128
    80004a96:	fc86                	sd	ra,120(sp)
    80004a98:	f8a2                	sd	s0,112(sp)
    80004a9a:	f4a6                	sd	s1,104(sp)
    80004a9c:	f0ca                	sd	s2,96(sp)
    80004a9e:	ecce                	sd	s3,88(sp)
    80004aa0:	e8d2                	sd	s4,80(sp)
    80004aa2:	e4d6                	sd	s5,72(sp)
    80004aa4:	e0da                	sd	s6,64(sp)
    80004aa6:	fc5e                	sd	s7,56(sp)
    80004aa8:	f862                	sd	s8,48(sp)
    80004aaa:	f466                	sd	s9,40(sp)
    80004aac:	f06a                	sd	s10,32(sp)
    80004aae:	ec6e                	sd	s11,24(sp)
    80004ab0:	0100                	addi	s0,sp,128
    80004ab2:	84aa                	mv	s1,a0
    80004ab4:	8cae                	mv	s9,a1
    80004ab6:	8b32                	mv	s6,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004ab8:	ffffd097          	auipc	ra,0xffffd
    80004abc:	f78080e7          	jalr	-136(ra) # 80001a30 <myproc>
    80004ac0:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004ac2:	8526                	mv	a0,s1
    80004ac4:	ffffc097          	auipc	ra,0xffffc
    80004ac8:	19e080e7          	jalr	414(ra) # 80000c62 <acquire>
  for(i = 0; i < n; i++){
    80004acc:	0d605963          	blez	s6,80004b9e <pipewrite+0x10a>
    80004ad0:	89a6                	mv	s3,s1
    80004ad2:	3b7d                	addiw	s6,s6,-1
    80004ad4:	1b02                	slli	s6,s6,0x20
    80004ad6:	020b5b13          	srli	s6,s6,0x20
    80004ada:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004adc:	21848a93          	addi	s5,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004ae0:	21c48a13          	addi	s4,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ae4:	5dfd                	li	s11,-1
    80004ae6:	000b8d1b          	sext.w	s10,s7
    80004aea:	8c6a                	mv	s8,s10
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004aec:	2184a783          	lw	a5,536(s1)
    80004af0:	21c4a703          	lw	a4,540(s1)
    80004af4:	2007879b          	addiw	a5,a5,512
    80004af8:	02f71b63          	bne	a4,a5,80004b2e <pipewrite+0x9a>
      if(pi->readopen == 0 || pr->killed){
    80004afc:	2204a783          	lw	a5,544(s1)
    80004b00:	cbad                	beqz	a5,80004b72 <pipewrite+0xde>
    80004b02:	03092783          	lw	a5,48(s2)
    80004b06:	e7b5                	bnez	a5,80004b72 <pipewrite+0xde>
      wakeup(&pi->nread);
    80004b08:	8556                	mv	a0,s5
    80004b0a:	ffffe097          	auipc	ra,0xffffe
    80004b0e:	8c4080e7          	jalr	-1852(ra) # 800023ce <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004b12:	85ce                	mv	a1,s3
    80004b14:	8552                	mv	a0,s4
    80004b16:	ffffd097          	auipc	ra,0xffffd
    80004b1a:	732080e7          	jalr	1842(ra) # 80002248 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004b1e:	2184a783          	lw	a5,536(s1)
    80004b22:	21c4a703          	lw	a4,540(s1)
    80004b26:	2007879b          	addiw	a5,a5,512
    80004b2a:	fcf709e3          	beq	a4,a5,80004afc <pipewrite+0x68>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b2e:	4685                	li	a3,1
    80004b30:	019b8633          	add	a2,s7,s9
    80004b34:	f8f40593          	addi	a1,s0,-113
    80004b38:	05093503          	ld	a0,80(s2)
    80004b3c:	ffffd097          	auipc	ra,0xffffd
    80004b40:	c74080e7          	jalr	-908(ra) # 800017b0 <copyin>
    80004b44:	05b50e63          	beq	a0,s11,80004ba0 <pipewrite+0x10c>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004b48:	21c4a783          	lw	a5,540(s1)
    80004b4c:	0017871b          	addiw	a4,a5,1
    80004b50:	20e4ae23          	sw	a4,540(s1)
    80004b54:	1ff7f793          	andi	a5,a5,511
    80004b58:	97a6                	add	a5,a5,s1
    80004b5a:	f8f44703          	lbu	a4,-113(s0)
    80004b5e:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004b62:	001d0c1b          	addiw	s8,s10,1
    80004b66:	001b8793          	addi	a5,s7,1 # 1001 <_entry-0x7fffefff>
    80004b6a:	036b8b63          	beq	s7,s6,80004ba0 <pipewrite+0x10c>
    80004b6e:	8bbe                	mv	s7,a5
    80004b70:	bf9d                	j	80004ae6 <pipewrite+0x52>
        release(&pi->lock);
    80004b72:	8526                	mv	a0,s1
    80004b74:	ffffc097          	auipc	ra,0xffffc
    80004b78:	1a2080e7          	jalr	418(ra) # 80000d16 <release>
        return -1;
    80004b7c:	5c7d                	li	s8,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);
  return i;
}
    80004b7e:	8562                	mv	a0,s8
    80004b80:	70e6                	ld	ra,120(sp)
    80004b82:	7446                	ld	s0,112(sp)
    80004b84:	74a6                	ld	s1,104(sp)
    80004b86:	7906                	ld	s2,96(sp)
    80004b88:	69e6                	ld	s3,88(sp)
    80004b8a:	6a46                	ld	s4,80(sp)
    80004b8c:	6aa6                	ld	s5,72(sp)
    80004b8e:	6b06                	ld	s6,64(sp)
    80004b90:	7be2                	ld	s7,56(sp)
    80004b92:	7c42                	ld	s8,48(sp)
    80004b94:	7ca2                	ld	s9,40(sp)
    80004b96:	7d02                	ld	s10,32(sp)
    80004b98:	6de2                	ld	s11,24(sp)
    80004b9a:	6109                	addi	sp,sp,128
    80004b9c:	8082                	ret
  for(i = 0; i < n; i++){
    80004b9e:	4c01                	li	s8,0
  wakeup(&pi->nread);
    80004ba0:	21848513          	addi	a0,s1,536
    80004ba4:	ffffe097          	auipc	ra,0xffffe
    80004ba8:	82a080e7          	jalr	-2006(ra) # 800023ce <wakeup>
  release(&pi->lock);
    80004bac:	8526                	mv	a0,s1
    80004bae:	ffffc097          	auipc	ra,0xffffc
    80004bb2:	168080e7          	jalr	360(ra) # 80000d16 <release>
  return i;
    80004bb6:	b7e1                	j	80004b7e <pipewrite+0xea>

0000000080004bb8 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004bb8:	715d                	addi	sp,sp,-80
    80004bba:	e486                	sd	ra,72(sp)
    80004bbc:	e0a2                	sd	s0,64(sp)
    80004bbe:	fc26                	sd	s1,56(sp)
    80004bc0:	f84a                	sd	s2,48(sp)
    80004bc2:	f44e                	sd	s3,40(sp)
    80004bc4:	f052                	sd	s4,32(sp)
    80004bc6:	ec56                	sd	s5,24(sp)
    80004bc8:	e85a                	sd	s6,16(sp)
    80004bca:	0880                	addi	s0,sp,80
    80004bcc:	84aa                	mv	s1,a0
    80004bce:	892e                	mv	s2,a1
    80004bd0:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004bd2:	ffffd097          	auipc	ra,0xffffd
    80004bd6:	e5e080e7          	jalr	-418(ra) # 80001a30 <myproc>
    80004bda:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004bdc:	8b26                	mv	s6,s1
    80004bde:	8526                	mv	a0,s1
    80004be0:	ffffc097          	auipc	ra,0xffffc
    80004be4:	082080e7          	jalr	130(ra) # 80000c62 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004be8:	2184a703          	lw	a4,536(s1)
    80004bec:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004bf0:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004bf4:	02f71463          	bne	a4,a5,80004c1c <piperead+0x64>
    80004bf8:	2244a783          	lw	a5,548(s1)
    80004bfc:	c385                	beqz	a5,80004c1c <piperead+0x64>
    if(pr->killed){
    80004bfe:	030a2783          	lw	a5,48(s4)
    80004c02:	ebc1                	bnez	a5,80004c92 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004c04:	85da                	mv	a1,s6
    80004c06:	854e                	mv	a0,s3
    80004c08:	ffffd097          	auipc	ra,0xffffd
    80004c0c:	640080e7          	jalr	1600(ra) # 80002248 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c10:	2184a703          	lw	a4,536(s1)
    80004c14:	21c4a783          	lw	a5,540(s1)
    80004c18:	fef700e3          	beq	a4,a5,80004bf8 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c1c:	09505263          	blez	s5,80004ca0 <piperead+0xe8>
    80004c20:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004c22:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004c24:	2184a783          	lw	a5,536(s1)
    80004c28:	21c4a703          	lw	a4,540(s1)
    80004c2c:	02f70d63          	beq	a4,a5,80004c66 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004c30:	0017871b          	addiw	a4,a5,1
    80004c34:	20e4ac23          	sw	a4,536(s1)
    80004c38:	1ff7f793          	andi	a5,a5,511
    80004c3c:	97a6                	add	a5,a5,s1
    80004c3e:	0187c783          	lbu	a5,24(a5)
    80004c42:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004c46:	4685                	li	a3,1
    80004c48:	fbf40613          	addi	a2,s0,-65
    80004c4c:	85ca                	mv	a1,s2
    80004c4e:	050a3503          	ld	a0,80(s4)
    80004c52:	ffffd097          	auipc	ra,0xffffd
    80004c56:	ad2080e7          	jalr	-1326(ra) # 80001724 <copyout>
    80004c5a:	01650663          	beq	a0,s6,80004c66 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c5e:	2985                	addiw	s3,s3,1
    80004c60:	0905                	addi	s2,s2,1
    80004c62:	fd3a91e3          	bne	s5,s3,80004c24 <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004c66:	21c48513          	addi	a0,s1,540
    80004c6a:	ffffd097          	auipc	ra,0xffffd
    80004c6e:	764080e7          	jalr	1892(ra) # 800023ce <wakeup>
  release(&pi->lock);
    80004c72:	8526                	mv	a0,s1
    80004c74:	ffffc097          	auipc	ra,0xffffc
    80004c78:	0a2080e7          	jalr	162(ra) # 80000d16 <release>
  return i;
}
    80004c7c:	854e                	mv	a0,s3
    80004c7e:	60a6                	ld	ra,72(sp)
    80004c80:	6406                	ld	s0,64(sp)
    80004c82:	74e2                	ld	s1,56(sp)
    80004c84:	7942                	ld	s2,48(sp)
    80004c86:	79a2                	ld	s3,40(sp)
    80004c88:	7a02                	ld	s4,32(sp)
    80004c8a:	6ae2                	ld	s5,24(sp)
    80004c8c:	6b42                	ld	s6,16(sp)
    80004c8e:	6161                	addi	sp,sp,80
    80004c90:	8082                	ret
      release(&pi->lock);
    80004c92:	8526                	mv	a0,s1
    80004c94:	ffffc097          	auipc	ra,0xffffc
    80004c98:	082080e7          	jalr	130(ra) # 80000d16 <release>
      return -1;
    80004c9c:	59fd                	li	s3,-1
    80004c9e:	bff9                	j	80004c7c <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ca0:	4981                	li	s3,0
    80004ca2:	b7d1                	j	80004c66 <piperead+0xae>

0000000080004ca4 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004ca4:	df010113          	addi	sp,sp,-528
    80004ca8:	20113423          	sd	ra,520(sp)
    80004cac:	20813023          	sd	s0,512(sp)
    80004cb0:	ffa6                	sd	s1,504(sp)
    80004cb2:	fbca                	sd	s2,496(sp)
    80004cb4:	f7ce                	sd	s3,488(sp)
    80004cb6:	f3d2                	sd	s4,480(sp)
    80004cb8:	efd6                	sd	s5,472(sp)
    80004cba:	ebda                	sd	s6,464(sp)
    80004cbc:	e7de                	sd	s7,456(sp)
    80004cbe:	e3e2                	sd	s8,448(sp)
    80004cc0:	ff66                	sd	s9,440(sp)
    80004cc2:	fb6a                	sd	s10,432(sp)
    80004cc4:	f76e                	sd	s11,424(sp)
    80004cc6:	0c00                	addi	s0,sp,528
    80004cc8:	84aa                	mv	s1,a0
    80004cca:	dea43c23          	sd	a0,-520(s0)
    80004cce:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004cd2:	ffffd097          	auipc	ra,0xffffd
    80004cd6:	d5e080e7          	jalr	-674(ra) # 80001a30 <myproc>
    80004cda:	892a                	mv	s2,a0

  begin_op();
    80004cdc:	fffff097          	auipc	ra,0xfffff
    80004ce0:	446080e7          	jalr	1094(ra) # 80004122 <begin_op>

  if((ip = namei(path)) == 0){
    80004ce4:	8526                	mv	a0,s1
    80004ce6:	fffff097          	auipc	ra,0xfffff
    80004cea:	230080e7          	jalr	560(ra) # 80003f16 <namei>
    80004cee:	c92d                	beqz	a0,80004d60 <exec+0xbc>
    80004cf0:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004cf2:	fffff097          	auipc	ra,0xfffff
    80004cf6:	a74080e7          	jalr	-1420(ra) # 80003766 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004cfa:	04000713          	li	a4,64
    80004cfe:	4681                	li	a3,0
    80004d00:	e4840613          	addi	a2,s0,-440
    80004d04:	4581                	li	a1,0
    80004d06:	8526                	mv	a0,s1
    80004d08:	fffff097          	auipc	ra,0xfffff
    80004d0c:	d12080e7          	jalr	-750(ra) # 80003a1a <readi>
    80004d10:	04000793          	li	a5,64
    80004d14:	00f51a63          	bne	a0,a5,80004d28 <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004d18:	e4842703          	lw	a4,-440(s0)
    80004d1c:	464c47b7          	lui	a5,0x464c4
    80004d20:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004d24:	04f70463          	beq	a4,a5,80004d6c <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004d28:	8526                	mv	a0,s1
    80004d2a:	fffff097          	auipc	ra,0xfffff
    80004d2e:	c9e080e7          	jalr	-866(ra) # 800039c8 <iunlockput>
    end_op();
    80004d32:	fffff097          	auipc	ra,0xfffff
    80004d36:	470080e7          	jalr	1136(ra) # 800041a2 <end_op>
  }
  return -1;
    80004d3a:	557d                	li	a0,-1
}
    80004d3c:	20813083          	ld	ra,520(sp)
    80004d40:	20013403          	ld	s0,512(sp)
    80004d44:	74fe                	ld	s1,504(sp)
    80004d46:	795e                	ld	s2,496(sp)
    80004d48:	79be                	ld	s3,488(sp)
    80004d4a:	7a1e                	ld	s4,480(sp)
    80004d4c:	6afe                	ld	s5,472(sp)
    80004d4e:	6b5e                	ld	s6,464(sp)
    80004d50:	6bbe                	ld	s7,456(sp)
    80004d52:	6c1e                	ld	s8,448(sp)
    80004d54:	7cfa                	ld	s9,440(sp)
    80004d56:	7d5a                	ld	s10,432(sp)
    80004d58:	7dba                	ld	s11,424(sp)
    80004d5a:	21010113          	addi	sp,sp,528
    80004d5e:	8082                	ret
    end_op();
    80004d60:	fffff097          	auipc	ra,0xfffff
    80004d64:	442080e7          	jalr	1090(ra) # 800041a2 <end_op>
    return -1;
    80004d68:	557d                	li	a0,-1
    80004d6a:	bfc9                	j	80004d3c <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004d6c:	854a                	mv	a0,s2
    80004d6e:	ffffd097          	auipc	ra,0xffffd
    80004d72:	d86080e7          	jalr	-634(ra) # 80001af4 <proc_pagetable>
    80004d76:	8baa                	mv	s7,a0
    80004d78:	d945                	beqz	a0,80004d28 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d7a:	e6842983          	lw	s3,-408(s0)
    80004d7e:	e8045783          	lhu	a5,-384(s0)
    80004d82:	c7ad                	beqz	a5,80004dec <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004d84:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d86:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80004d88:	6c85                	lui	s9,0x1
    80004d8a:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004d8e:	def43823          	sd	a5,-528(s0)
    80004d92:	a42d                	j	80004fbc <exec+0x318>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004d94:	00004517          	auipc	a0,0x4
    80004d98:	9ec50513          	addi	a0,a0,-1556 # 80008780 <syscalls+0x298>
    80004d9c:	ffffb097          	auipc	ra,0xffffb
    80004da0:	7ac080e7          	jalr	1964(ra) # 80000548 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004da4:	8756                	mv	a4,s5
    80004da6:	012d86bb          	addw	a3,s11,s2
    80004daa:	4581                	li	a1,0
    80004dac:	8526                	mv	a0,s1
    80004dae:	fffff097          	auipc	ra,0xfffff
    80004db2:	c6c080e7          	jalr	-916(ra) # 80003a1a <readi>
    80004db6:	2501                	sext.w	a0,a0
    80004db8:	1aaa9963          	bne	s5,a0,80004f6a <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    80004dbc:	6785                	lui	a5,0x1
    80004dbe:	0127893b          	addw	s2,a5,s2
    80004dc2:	77fd                	lui	a5,0xfffff
    80004dc4:	01478a3b          	addw	s4,a5,s4
    80004dc8:	1f897163          	bgeu	s2,s8,80004faa <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    80004dcc:	02091593          	slli	a1,s2,0x20
    80004dd0:	9181                	srli	a1,a1,0x20
    80004dd2:	95ea                	add	a1,a1,s10
    80004dd4:	855e                	mv	a0,s7
    80004dd6:	ffffc097          	auipc	ra,0xffffc
    80004dda:	31a080e7          	jalr	794(ra) # 800010f0 <walkaddr>
    80004dde:	862a                	mv	a2,a0
    if(pa == 0)
    80004de0:	d955                	beqz	a0,80004d94 <exec+0xf0>
      n = PGSIZE;
    80004de2:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80004de4:	fd9a70e3          	bgeu	s4,s9,80004da4 <exec+0x100>
      n = sz - i;
    80004de8:	8ad2                	mv	s5,s4
    80004dea:	bf6d                	j	80004da4 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004dec:	4901                	li	s2,0
  iunlockput(ip);
    80004dee:	8526                	mv	a0,s1
    80004df0:	fffff097          	auipc	ra,0xfffff
    80004df4:	bd8080e7          	jalr	-1064(ra) # 800039c8 <iunlockput>
  end_op();
    80004df8:	fffff097          	auipc	ra,0xfffff
    80004dfc:	3aa080e7          	jalr	938(ra) # 800041a2 <end_op>
  p = myproc();
    80004e00:	ffffd097          	auipc	ra,0xffffd
    80004e04:	c30080e7          	jalr	-976(ra) # 80001a30 <myproc>
    80004e08:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004e0a:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004e0e:	6785                	lui	a5,0x1
    80004e10:	17fd                	addi	a5,a5,-1
    80004e12:	993e                	add	s2,s2,a5
    80004e14:	757d                	lui	a0,0xfffff
    80004e16:	00a977b3          	and	a5,s2,a0
    80004e1a:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004e1e:	6609                	lui	a2,0x2
    80004e20:	963e                	add	a2,a2,a5
    80004e22:	85be                	mv	a1,a5
    80004e24:	855e                	mv	a0,s7
    80004e26:	ffffc097          	auipc	ra,0xffffc
    80004e2a:	6ae080e7          	jalr	1710(ra) # 800014d4 <uvmalloc>
    80004e2e:	8b2a                	mv	s6,a0
  ip = 0;
    80004e30:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004e32:	12050c63          	beqz	a0,80004f6a <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004e36:	75f9                	lui	a1,0xffffe
    80004e38:	95aa                	add	a1,a1,a0
    80004e3a:	855e                	mv	a0,s7
    80004e3c:	ffffd097          	auipc	ra,0xffffd
    80004e40:	8b6080e7          	jalr	-1866(ra) # 800016f2 <uvmclear>
  stackbase = sp - PGSIZE;
    80004e44:	7c7d                	lui	s8,0xfffff
    80004e46:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    80004e48:	e0043783          	ld	a5,-512(s0)
    80004e4c:	6388                	ld	a0,0(a5)
    80004e4e:	c535                	beqz	a0,80004eba <exec+0x216>
    80004e50:	e8840993          	addi	s3,s0,-376
    80004e54:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80004e58:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    80004e5a:	ffffc097          	auipc	ra,0xffffc
    80004e5e:	08c080e7          	jalr	140(ra) # 80000ee6 <strlen>
    80004e62:	2505                	addiw	a0,a0,1
    80004e64:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004e68:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004e6c:	13896363          	bltu	s2,s8,80004f92 <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004e70:	e0043d83          	ld	s11,-512(s0)
    80004e74:	000dba03          	ld	s4,0(s11)
    80004e78:	8552                	mv	a0,s4
    80004e7a:	ffffc097          	auipc	ra,0xffffc
    80004e7e:	06c080e7          	jalr	108(ra) # 80000ee6 <strlen>
    80004e82:	0015069b          	addiw	a3,a0,1
    80004e86:	8652                	mv	a2,s4
    80004e88:	85ca                	mv	a1,s2
    80004e8a:	855e                	mv	a0,s7
    80004e8c:	ffffd097          	auipc	ra,0xffffd
    80004e90:	898080e7          	jalr	-1896(ra) # 80001724 <copyout>
    80004e94:	10054363          	bltz	a0,80004f9a <exec+0x2f6>
    ustack[argc] = sp;
    80004e98:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004e9c:	0485                	addi	s1,s1,1
    80004e9e:	008d8793          	addi	a5,s11,8
    80004ea2:	e0f43023          	sd	a5,-512(s0)
    80004ea6:	008db503          	ld	a0,8(s11)
    80004eaa:	c911                	beqz	a0,80004ebe <exec+0x21a>
    if(argc >= MAXARG)
    80004eac:	09a1                	addi	s3,s3,8
    80004eae:	fb3c96e3          	bne	s9,s3,80004e5a <exec+0x1b6>
  sz = sz1;
    80004eb2:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004eb6:	4481                	li	s1,0
    80004eb8:	a84d                	j	80004f6a <exec+0x2c6>
  sp = sz;
    80004eba:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004ebc:	4481                	li	s1,0
  ustack[argc] = 0;
    80004ebe:	00349793          	slli	a5,s1,0x3
    80004ec2:	f9040713          	addi	a4,s0,-112
    80004ec6:	97ba                	add	a5,a5,a4
    80004ec8:	ee07bc23          	sd	zero,-264(a5) # ef8 <_entry-0x7ffff108>
  sp -= (argc+1) * sizeof(uint64);
    80004ecc:	00148693          	addi	a3,s1,1
    80004ed0:	068e                	slli	a3,a3,0x3
    80004ed2:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004ed6:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004eda:	01897663          	bgeu	s2,s8,80004ee6 <exec+0x242>
  sz = sz1;
    80004ede:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004ee2:	4481                	li	s1,0
    80004ee4:	a059                	j	80004f6a <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004ee6:	e8840613          	addi	a2,s0,-376
    80004eea:	85ca                	mv	a1,s2
    80004eec:	855e                	mv	a0,s7
    80004eee:	ffffd097          	auipc	ra,0xffffd
    80004ef2:	836080e7          	jalr	-1994(ra) # 80001724 <copyout>
    80004ef6:	0a054663          	bltz	a0,80004fa2 <exec+0x2fe>
  p->trapframe->a1 = sp;
    80004efa:	058ab783          	ld	a5,88(s5)
    80004efe:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004f02:	df843783          	ld	a5,-520(s0)
    80004f06:	0007c703          	lbu	a4,0(a5)
    80004f0a:	cf11                	beqz	a4,80004f26 <exec+0x282>
    80004f0c:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004f0e:	02f00693          	li	a3,47
    80004f12:	a029                	j	80004f1c <exec+0x278>
  for(last=s=path; *s; s++)
    80004f14:	0785                	addi	a5,a5,1
    80004f16:	fff7c703          	lbu	a4,-1(a5)
    80004f1a:	c711                	beqz	a4,80004f26 <exec+0x282>
    if(*s == '/')
    80004f1c:	fed71ce3          	bne	a4,a3,80004f14 <exec+0x270>
      last = s+1;
    80004f20:	def43c23          	sd	a5,-520(s0)
    80004f24:	bfc5                	j	80004f14 <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    80004f26:	4641                	li	a2,16
    80004f28:	df843583          	ld	a1,-520(s0)
    80004f2c:	158a8513          	addi	a0,s5,344
    80004f30:	ffffc097          	auipc	ra,0xffffc
    80004f34:	f84080e7          	jalr	-124(ra) # 80000eb4 <safestrcpy>
  oldpagetable = p->pagetable;
    80004f38:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004f3c:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    80004f40:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004f44:	058ab783          	ld	a5,88(s5)
    80004f48:	e6043703          	ld	a4,-416(s0)
    80004f4c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004f4e:	058ab783          	ld	a5,88(s5)
    80004f52:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004f56:	85ea                	mv	a1,s10
    80004f58:	ffffd097          	auipc	ra,0xffffd
    80004f5c:	c38080e7          	jalr	-968(ra) # 80001b90 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004f60:	0004851b          	sext.w	a0,s1
    80004f64:	bbe1                	j	80004d3c <exec+0x98>
    80004f66:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80004f6a:	e0843583          	ld	a1,-504(s0)
    80004f6e:	855e                	mv	a0,s7
    80004f70:	ffffd097          	auipc	ra,0xffffd
    80004f74:	c20080e7          	jalr	-992(ra) # 80001b90 <proc_freepagetable>
  if(ip){
    80004f78:	da0498e3          	bnez	s1,80004d28 <exec+0x84>
  return -1;
    80004f7c:	557d                	li	a0,-1
    80004f7e:	bb7d                	j	80004d3c <exec+0x98>
    80004f80:	e1243423          	sd	s2,-504(s0)
    80004f84:	b7dd                	j	80004f6a <exec+0x2c6>
    80004f86:	e1243423          	sd	s2,-504(s0)
    80004f8a:	b7c5                	j	80004f6a <exec+0x2c6>
    80004f8c:	e1243423          	sd	s2,-504(s0)
    80004f90:	bfe9                	j	80004f6a <exec+0x2c6>
  sz = sz1;
    80004f92:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004f96:	4481                	li	s1,0
    80004f98:	bfc9                	j	80004f6a <exec+0x2c6>
  sz = sz1;
    80004f9a:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004f9e:	4481                	li	s1,0
    80004fa0:	b7e9                	j	80004f6a <exec+0x2c6>
  sz = sz1;
    80004fa2:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004fa6:	4481                	li	s1,0
    80004fa8:	b7c9                	j	80004f6a <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004faa:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fae:	2b05                	addiw	s6,s6,1
    80004fb0:	0389899b          	addiw	s3,s3,56
    80004fb4:	e8045783          	lhu	a5,-384(s0)
    80004fb8:	e2fb5be3          	bge	s6,a5,80004dee <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004fbc:	2981                	sext.w	s3,s3
    80004fbe:	03800713          	li	a4,56
    80004fc2:	86ce                	mv	a3,s3
    80004fc4:	e1040613          	addi	a2,s0,-496
    80004fc8:	4581                	li	a1,0
    80004fca:	8526                	mv	a0,s1
    80004fcc:	fffff097          	auipc	ra,0xfffff
    80004fd0:	a4e080e7          	jalr	-1458(ra) # 80003a1a <readi>
    80004fd4:	03800793          	li	a5,56
    80004fd8:	f8f517e3          	bne	a0,a5,80004f66 <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    80004fdc:	e1042783          	lw	a5,-496(s0)
    80004fe0:	4705                	li	a4,1
    80004fe2:	fce796e3          	bne	a5,a4,80004fae <exec+0x30a>
    if(ph.memsz < ph.filesz)
    80004fe6:	e3843603          	ld	a2,-456(s0)
    80004fea:	e3043783          	ld	a5,-464(s0)
    80004fee:	f8f669e3          	bltu	a2,a5,80004f80 <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004ff2:	e2043783          	ld	a5,-480(s0)
    80004ff6:	963e                	add	a2,a2,a5
    80004ff8:	f8f667e3          	bltu	a2,a5,80004f86 <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004ffc:	85ca                	mv	a1,s2
    80004ffe:	855e                	mv	a0,s7
    80005000:	ffffc097          	auipc	ra,0xffffc
    80005004:	4d4080e7          	jalr	1236(ra) # 800014d4 <uvmalloc>
    80005008:	e0a43423          	sd	a0,-504(s0)
    8000500c:	d141                	beqz	a0,80004f8c <exec+0x2e8>
    if(ph.vaddr % PGSIZE != 0)
    8000500e:	e2043d03          	ld	s10,-480(s0)
    80005012:	df043783          	ld	a5,-528(s0)
    80005016:	00fd77b3          	and	a5,s10,a5
    8000501a:	fba1                	bnez	a5,80004f6a <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000501c:	e1842d83          	lw	s11,-488(s0)
    80005020:	e3042c03          	lw	s8,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005024:	f80c03e3          	beqz	s8,80004faa <exec+0x306>
    80005028:	8a62                	mv	s4,s8
    8000502a:	4901                	li	s2,0
    8000502c:	b345                	j	80004dcc <exec+0x128>

000000008000502e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000502e:	7179                	addi	sp,sp,-48
    80005030:	f406                	sd	ra,40(sp)
    80005032:	f022                	sd	s0,32(sp)
    80005034:	ec26                	sd	s1,24(sp)
    80005036:	e84a                	sd	s2,16(sp)
    80005038:	1800                	addi	s0,sp,48
    8000503a:	892e                	mv	s2,a1
    8000503c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    8000503e:	fdc40593          	addi	a1,s0,-36
    80005042:	ffffe097          	auipc	ra,0xffffe
    80005046:	aea080e7          	jalr	-1302(ra) # 80002b2c <argint>
    8000504a:	04054063          	bltz	a0,8000508a <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000504e:	fdc42703          	lw	a4,-36(s0)
    80005052:	47bd                	li	a5,15
    80005054:	02e7ed63          	bltu	a5,a4,8000508e <argfd+0x60>
    80005058:	ffffd097          	auipc	ra,0xffffd
    8000505c:	9d8080e7          	jalr	-1576(ra) # 80001a30 <myproc>
    80005060:	fdc42703          	lw	a4,-36(s0)
    80005064:	01a70793          	addi	a5,a4,26
    80005068:	078e                	slli	a5,a5,0x3
    8000506a:	953e                	add	a0,a0,a5
    8000506c:	611c                	ld	a5,0(a0)
    8000506e:	c395                	beqz	a5,80005092 <argfd+0x64>
    return -1;
  if(pfd)
    80005070:	00090463          	beqz	s2,80005078 <argfd+0x4a>
    *pfd = fd;
    80005074:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005078:	4501                	li	a0,0
  if(pf)
    8000507a:	c091                	beqz	s1,8000507e <argfd+0x50>
    *pf = f;
    8000507c:	e09c                	sd	a5,0(s1)
}
    8000507e:	70a2                	ld	ra,40(sp)
    80005080:	7402                	ld	s0,32(sp)
    80005082:	64e2                	ld	s1,24(sp)
    80005084:	6942                	ld	s2,16(sp)
    80005086:	6145                	addi	sp,sp,48
    80005088:	8082                	ret
    return -1;
    8000508a:	557d                	li	a0,-1
    8000508c:	bfcd                	j	8000507e <argfd+0x50>
    return -1;
    8000508e:	557d                	li	a0,-1
    80005090:	b7fd                	j	8000507e <argfd+0x50>
    80005092:	557d                	li	a0,-1
    80005094:	b7ed                	j	8000507e <argfd+0x50>

0000000080005096 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005096:	1101                	addi	sp,sp,-32
    80005098:	ec06                	sd	ra,24(sp)
    8000509a:	e822                	sd	s0,16(sp)
    8000509c:	e426                	sd	s1,8(sp)
    8000509e:	1000                	addi	s0,sp,32
    800050a0:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800050a2:	ffffd097          	auipc	ra,0xffffd
    800050a6:	98e080e7          	jalr	-1650(ra) # 80001a30 <myproc>
    800050aa:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800050ac:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffd90d0>
    800050b0:	4501                	li	a0,0
    800050b2:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800050b4:	6398                	ld	a4,0(a5)
    800050b6:	cb19                	beqz	a4,800050cc <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800050b8:	2505                	addiw	a0,a0,1
    800050ba:	07a1                	addi	a5,a5,8
    800050bc:	fed51ce3          	bne	a0,a3,800050b4 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800050c0:	557d                	li	a0,-1
}
    800050c2:	60e2                	ld	ra,24(sp)
    800050c4:	6442                	ld	s0,16(sp)
    800050c6:	64a2                	ld	s1,8(sp)
    800050c8:	6105                	addi	sp,sp,32
    800050ca:	8082                	ret
      p->ofile[fd] = f;
    800050cc:	01a50793          	addi	a5,a0,26
    800050d0:	078e                	slli	a5,a5,0x3
    800050d2:	963e                	add	a2,a2,a5
    800050d4:	e204                	sd	s1,0(a2)
      return fd;
    800050d6:	b7f5                	j	800050c2 <fdalloc+0x2c>

00000000800050d8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800050d8:	715d                	addi	sp,sp,-80
    800050da:	e486                	sd	ra,72(sp)
    800050dc:	e0a2                	sd	s0,64(sp)
    800050de:	fc26                	sd	s1,56(sp)
    800050e0:	f84a                	sd	s2,48(sp)
    800050e2:	f44e                	sd	s3,40(sp)
    800050e4:	f052                	sd	s4,32(sp)
    800050e6:	ec56                	sd	s5,24(sp)
    800050e8:	0880                	addi	s0,sp,80
    800050ea:	89ae                	mv	s3,a1
    800050ec:	8ab2                	mv	s5,a2
    800050ee:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800050f0:	fb040593          	addi	a1,s0,-80
    800050f4:	fffff097          	auipc	ra,0xfffff
    800050f8:	e40080e7          	jalr	-448(ra) # 80003f34 <nameiparent>
    800050fc:	892a                	mv	s2,a0
    800050fe:	12050f63          	beqz	a0,8000523c <create+0x164>
    return 0;

  ilock(dp);
    80005102:	ffffe097          	auipc	ra,0xffffe
    80005106:	664080e7          	jalr	1636(ra) # 80003766 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000510a:	4601                	li	a2,0
    8000510c:	fb040593          	addi	a1,s0,-80
    80005110:	854a                	mv	a0,s2
    80005112:	fffff097          	auipc	ra,0xfffff
    80005116:	b32080e7          	jalr	-1230(ra) # 80003c44 <dirlookup>
    8000511a:	84aa                	mv	s1,a0
    8000511c:	c921                	beqz	a0,8000516c <create+0x94>
    iunlockput(dp);
    8000511e:	854a                	mv	a0,s2
    80005120:	fffff097          	auipc	ra,0xfffff
    80005124:	8a8080e7          	jalr	-1880(ra) # 800039c8 <iunlockput>
    ilock(ip);
    80005128:	8526                	mv	a0,s1
    8000512a:	ffffe097          	auipc	ra,0xffffe
    8000512e:	63c080e7          	jalr	1596(ra) # 80003766 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005132:	2981                	sext.w	s3,s3
    80005134:	4789                	li	a5,2
    80005136:	02f99463          	bne	s3,a5,8000515e <create+0x86>
    8000513a:	0444d783          	lhu	a5,68(s1)
    8000513e:	37f9                	addiw	a5,a5,-2
    80005140:	17c2                	slli	a5,a5,0x30
    80005142:	93c1                	srli	a5,a5,0x30
    80005144:	4705                	li	a4,1
    80005146:	00f76c63          	bltu	a4,a5,8000515e <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    8000514a:	8526                	mv	a0,s1
    8000514c:	60a6                	ld	ra,72(sp)
    8000514e:	6406                	ld	s0,64(sp)
    80005150:	74e2                	ld	s1,56(sp)
    80005152:	7942                	ld	s2,48(sp)
    80005154:	79a2                	ld	s3,40(sp)
    80005156:	7a02                	ld	s4,32(sp)
    80005158:	6ae2                	ld	s5,24(sp)
    8000515a:	6161                	addi	sp,sp,80
    8000515c:	8082                	ret
    iunlockput(ip);
    8000515e:	8526                	mv	a0,s1
    80005160:	fffff097          	auipc	ra,0xfffff
    80005164:	868080e7          	jalr	-1944(ra) # 800039c8 <iunlockput>
    return 0;
    80005168:	4481                	li	s1,0
    8000516a:	b7c5                	j	8000514a <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000516c:	85ce                	mv	a1,s3
    8000516e:	00092503          	lw	a0,0(s2)
    80005172:	ffffe097          	auipc	ra,0xffffe
    80005176:	45c080e7          	jalr	1116(ra) # 800035ce <ialloc>
    8000517a:	84aa                	mv	s1,a0
    8000517c:	c529                	beqz	a0,800051c6 <create+0xee>
  ilock(ip);
    8000517e:	ffffe097          	auipc	ra,0xffffe
    80005182:	5e8080e7          	jalr	1512(ra) # 80003766 <ilock>
  ip->major = major;
    80005186:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    8000518a:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    8000518e:	4785                	li	a5,1
    80005190:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005194:	8526                	mv	a0,s1
    80005196:	ffffe097          	auipc	ra,0xffffe
    8000519a:	506080e7          	jalr	1286(ra) # 8000369c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000519e:	2981                	sext.w	s3,s3
    800051a0:	4785                	li	a5,1
    800051a2:	02f98a63          	beq	s3,a5,800051d6 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800051a6:	40d0                	lw	a2,4(s1)
    800051a8:	fb040593          	addi	a1,s0,-80
    800051ac:	854a                	mv	a0,s2
    800051ae:	fffff097          	auipc	ra,0xfffff
    800051b2:	ca6080e7          	jalr	-858(ra) # 80003e54 <dirlink>
    800051b6:	06054b63          	bltz	a0,8000522c <create+0x154>
  iunlockput(dp);
    800051ba:	854a                	mv	a0,s2
    800051bc:	fffff097          	auipc	ra,0xfffff
    800051c0:	80c080e7          	jalr	-2036(ra) # 800039c8 <iunlockput>
  return ip;
    800051c4:	b759                	j	8000514a <create+0x72>
    panic("create: ialloc");
    800051c6:	00003517          	auipc	a0,0x3
    800051ca:	5da50513          	addi	a0,a0,1498 # 800087a0 <syscalls+0x2b8>
    800051ce:	ffffb097          	auipc	ra,0xffffb
    800051d2:	37a080e7          	jalr	890(ra) # 80000548 <panic>
    dp->nlink++;  // for ".."
    800051d6:	04a95783          	lhu	a5,74(s2)
    800051da:	2785                	addiw	a5,a5,1
    800051dc:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800051e0:	854a                	mv	a0,s2
    800051e2:	ffffe097          	auipc	ra,0xffffe
    800051e6:	4ba080e7          	jalr	1210(ra) # 8000369c <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800051ea:	40d0                	lw	a2,4(s1)
    800051ec:	00003597          	auipc	a1,0x3
    800051f0:	5c458593          	addi	a1,a1,1476 # 800087b0 <syscalls+0x2c8>
    800051f4:	8526                	mv	a0,s1
    800051f6:	fffff097          	auipc	ra,0xfffff
    800051fa:	c5e080e7          	jalr	-930(ra) # 80003e54 <dirlink>
    800051fe:	00054f63          	bltz	a0,8000521c <create+0x144>
    80005202:	00492603          	lw	a2,4(s2)
    80005206:	00003597          	auipc	a1,0x3
    8000520a:	5b258593          	addi	a1,a1,1458 # 800087b8 <syscalls+0x2d0>
    8000520e:	8526                	mv	a0,s1
    80005210:	fffff097          	auipc	ra,0xfffff
    80005214:	c44080e7          	jalr	-956(ra) # 80003e54 <dirlink>
    80005218:	f80557e3          	bgez	a0,800051a6 <create+0xce>
      panic("create dots");
    8000521c:	00003517          	auipc	a0,0x3
    80005220:	5a450513          	addi	a0,a0,1444 # 800087c0 <syscalls+0x2d8>
    80005224:	ffffb097          	auipc	ra,0xffffb
    80005228:	324080e7          	jalr	804(ra) # 80000548 <panic>
    panic("create: dirlink");
    8000522c:	00003517          	auipc	a0,0x3
    80005230:	5a450513          	addi	a0,a0,1444 # 800087d0 <syscalls+0x2e8>
    80005234:	ffffb097          	auipc	ra,0xffffb
    80005238:	314080e7          	jalr	788(ra) # 80000548 <panic>
    return 0;
    8000523c:	84aa                	mv	s1,a0
    8000523e:	b731                	j	8000514a <create+0x72>

0000000080005240 <sys_dup>:
{
    80005240:	7179                	addi	sp,sp,-48
    80005242:	f406                	sd	ra,40(sp)
    80005244:	f022                	sd	s0,32(sp)
    80005246:	ec26                	sd	s1,24(sp)
    80005248:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000524a:	fd840613          	addi	a2,s0,-40
    8000524e:	4581                	li	a1,0
    80005250:	4501                	li	a0,0
    80005252:	00000097          	auipc	ra,0x0
    80005256:	ddc080e7          	jalr	-548(ra) # 8000502e <argfd>
    return -1;
    8000525a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000525c:	02054363          	bltz	a0,80005282 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005260:	fd843503          	ld	a0,-40(s0)
    80005264:	00000097          	auipc	ra,0x0
    80005268:	e32080e7          	jalr	-462(ra) # 80005096 <fdalloc>
    8000526c:	84aa                	mv	s1,a0
    return -1;
    8000526e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005270:	00054963          	bltz	a0,80005282 <sys_dup+0x42>
  filedup(f);
    80005274:	fd843503          	ld	a0,-40(s0)
    80005278:	fffff097          	auipc	ra,0xfffff
    8000527c:	32a080e7          	jalr	810(ra) # 800045a2 <filedup>
  return fd;
    80005280:	87a6                	mv	a5,s1
}
    80005282:	853e                	mv	a0,a5
    80005284:	70a2                	ld	ra,40(sp)
    80005286:	7402                	ld	s0,32(sp)
    80005288:	64e2                	ld	s1,24(sp)
    8000528a:	6145                	addi	sp,sp,48
    8000528c:	8082                	ret

000000008000528e <sys_read>:
{
    8000528e:	7179                	addi	sp,sp,-48
    80005290:	f406                	sd	ra,40(sp)
    80005292:	f022                	sd	s0,32(sp)
    80005294:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005296:	fe840613          	addi	a2,s0,-24
    8000529a:	4581                	li	a1,0
    8000529c:	4501                	li	a0,0
    8000529e:	00000097          	auipc	ra,0x0
    800052a2:	d90080e7          	jalr	-624(ra) # 8000502e <argfd>
    return -1;
    800052a6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052a8:	04054163          	bltz	a0,800052ea <sys_read+0x5c>
    800052ac:	fe440593          	addi	a1,s0,-28
    800052b0:	4509                	li	a0,2
    800052b2:	ffffe097          	auipc	ra,0xffffe
    800052b6:	87a080e7          	jalr	-1926(ra) # 80002b2c <argint>
    return -1;
    800052ba:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052bc:	02054763          	bltz	a0,800052ea <sys_read+0x5c>
    800052c0:	fd840593          	addi	a1,s0,-40
    800052c4:	4505                	li	a0,1
    800052c6:	ffffe097          	auipc	ra,0xffffe
    800052ca:	888080e7          	jalr	-1912(ra) # 80002b4e <argaddr>
    return -1;
    800052ce:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052d0:	00054d63          	bltz	a0,800052ea <sys_read+0x5c>
  return fileread(f, p, n);
    800052d4:	fe442603          	lw	a2,-28(s0)
    800052d8:	fd843583          	ld	a1,-40(s0)
    800052dc:	fe843503          	ld	a0,-24(s0)
    800052e0:	fffff097          	auipc	ra,0xfffff
    800052e4:	44e080e7          	jalr	1102(ra) # 8000472e <fileread>
    800052e8:	87aa                	mv	a5,a0
}
    800052ea:	853e                	mv	a0,a5
    800052ec:	70a2                	ld	ra,40(sp)
    800052ee:	7402                	ld	s0,32(sp)
    800052f0:	6145                	addi	sp,sp,48
    800052f2:	8082                	ret

00000000800052f4 <sys_write>:
{
    800052f4:	7179                	addi	sp,sp,-48
    800052f6:	f406                	sd	ra,40(sp)
    800052f8:	f022                	sd	s0,32(sp)
    800052fa:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052fc:	fe840613          	addi	a2,s0,-24
    80005300:	4581                	li	a1,0
    80005302:	4501                	li	a0,0
    80005304:	00000097          	auipc	ra,0x0
    80005308:	d2a080e7          	jalr	-726(ra) # 8000502e <argfd>
    return -1;
    8000530c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000530e:	04054163          	bltz	a0,80005350 <sys_write+0x5c>
    80005312:	fe440593          	addi	a1,s0,-28
    80005316:	4509                	li	a0,2
    80005318:	ffffe097          	auipc	ra,0xffffe
    8000531c:	814080e7          	jalr	-2028(ra) # 80002b2c <argint>
    return -1;
    80005320:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005322:	02054763          	bltz	a0,80005350 <sys_write+0x5c>
    80005326:	fd840593          	addi	a1,s0,-40
    8000532a:	4505                	li	a0,1
    8000532c:	ffffe097          	auipc	ra,0xffffe
    80005330:	822080e7          	jalr	-2014(ra) # 80002b4e <argaddr>
    return -1;
    80005334:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005336:	00054d63          	bltz	a0,80005350 <sys_write+0x5c>
  return filewrite(f, p, n);
    8000533a:	fe442603          	lw	a2,-28(s0)
    8000533e:	fd843583          	ld	a1,-40(s0)
    80005342:	fe843503          	ld	a0,-24(s0)
    80005346:	fffff097          	auipc	ra,0xfffff
    8000534a:	4aa080e7          	jalr	1194(ra) # 800047f0 <filewrite>
    8000534e:	87aa                	mv	a5,a0
}
    80005350:	853e                	mv	a0,a5
    80005352:	70a2                	ld	ra,40(sp)
    80005354:	7402                	ld	s0,32(sp)
    80005356:	6145                	addi	sp,sp,48
    80005358:	8082                	ret

000000008000535a <sys_close>:
{
    8000535a:	1101                	addi	sp,sp,-32
    8000535c:	ec06                	sd	ra,24(sp)
    8000535e:	e822                	sd	s0,16(sp)
    80005360:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005362:	fe040613          	addi	a2,s0,-32
    80005366:	fec40593          	addi	a1,s0,-20
    8000536a:	4501                	li	a0,0
    8000536c:	00000097          	auipc	ra,0x0
    80005370:	cc2080e7          	jalr	-830(ra) # 8000502e <argfd>
    return -1;
    80005374:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005376:	02054463          	bltz	a0,8000539e <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000537a:	ffffc097          	auipc	ra,0xffffc
    8000537e:	6b6080e7          	jalr	1718(ra) # 80001a30 <myproc>
    80005382:	fec42783          	lw	a5,-20(s0)
    80005386:	07e9                	addi	a5,a5,26
    80005388:	078e                	slli	a5,a5,0x3
    8000538a:	97aa                	add	a5,a5,a0
    8000538c:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005390:	fe043503          	ld	a0,-32(s0)
    80005394:	fffff097          	auipc	ra,0xfffff
    80005398:	260080e7          	jalr	608(ra) # 800045f4 <fileclose>
  return 0;
    8000539c:	4781                	li	a5,0
}
    8000539e:	853e                	mv	a0,a5
    800053a0:	60e2                	ld	ra,24(sp)
    800053a2:	6442                	ld	s0,16(sp)
    800053a4:	6105                	addi	sp,sp,32
    800053a6:	8082                	ret

00000000800053a8 <sys_fstat>:
{
    800053a8:	1101                	addi	sp,sp,-32
    800053aa:	ec06                	sd	ra,24(sp)
    800053ac:	e822                	sd	s0,16(sp)
    800053ae:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800053b0:	fe840613          	addi	a2,s0,-24
    800053b4:	4581                	li	a1,0
    800053b6:	4501                	li	a0,0
    800053b8:	00000097          	auipc	ra,0x0
    800053bc:	c76080e7          	jalr	-906(ra) # 8000502e <argfd>
    return -1;
    800053c0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800053c2:	02054563          	bltz	a0,800053ec <sys_fstat+0x44>
    800053c6:	fe040593          	addi	a1,s0,-32
    800053ca:	4505                	li	a0,1
    800053cc:	ffffd097          	auipc	ra,0xffffd
    800053d0:	782080e7          	jalr	1922(ra) # 80002b4e <argaddr>
    return -1;
    800053d4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800053d6:	00054b63          	bltz	a0,800053ec <sys_fstat+0x44>
  return filestat(f, st);
    800053da:	fe043583          	ld	a1,-32(s0)
    800053de:	fe843503          	ld	a0,-24(s0)
    800053e2:	fffff097          	auipc	ra,0xfffff
    800053e6:	2da080e7          	jalr	730(ra) # 800046bc <filestat>
    800053ea:	87aa                	mv	a5,a0
}
    800053ec:	853e                	mv	a0,a5
    800053ee:	60e2                	ld	ra,24(sp)
    800053f0:	6442                	ld	s0,16(sp)
    800053f2:	6105                	addi	sp,sp,32
    800053f4:	8082                	ret

00000000800053f6 <sys_link>:
{
    800053f6:	7169                	addi	sp,sp,-304
    800053f8:	f606                	sd	ra,296(sp)
    800053fa:	f222                	sd	s0,288(sp)
    800053fc:	ee26                	sd	s1,280(sp)
    800053fe:	ea4a                	sd	s2,272(sp)
    80005400:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005402:	08000613          	li	a2,128
    80005406:	ed040593          	addi	a1,s0,-304
    8000540a:	4501                	li	a0,0
    8000540c:	ffffd097          	auipc	ra,0xffffd
    80005410:	764080e7          	jalr	1892(ra) # 80002b70 <argstr>
    return -1;
    80005414:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005416:	10054e63          	bltz	a0,80005532 <sys_link+0x13c>
    8000541a:	08000613          	li	a2,128
    8000541e:	f5040593          	addi	a1,s0,-176
    80005422:	4505                	li	a0,1
    80005424:	ffffd097          	auipc	ra,0xffffd
    80005428:	74c080e7          	jalr	1868(ra) # 80002b70 <argstr>
    return -1;
    8000542c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000542e:	10054263          	bltz	a0,80005532 <sys_link+0x13c>
  begin_op();
    80005432:	fffff097          	auipc	ra,0xfffff
    80005436:	cf0080e7          	jalr	-784(ra) # 80004122 <begin_op>
  if((ip = namei(old)) == 0){
    8000543a:	ed040513          	addi	a0,s0,-304
    8000543e:	fffff097          	auipc	ra,0xfffff
    80005442:	ad8080e7          	jalr	-1320(ra) # 80003f16 <namei>
    80005446:	84aa                	mv	s1,a0
    80005448:	c551                	beqz	a0,800054d4 <sys_link+0xde>
  ilock(ip);
    8000544a:	ffffe097          	auipc	ra,0xffffe
    8000544e:	31c080e7          	jalr	796(ra) # 80003766 <ilock>
  if(ip->type == T_DIR){
    80005452:	04449703          	lh	a4,68(s1)
    80005456:	4785                	li	a5,1
    80005458:	08f70463          	beq	a4,a5,800054e0 <sys_link+0xea>
  ip->nlink++;
    8000545c:	04a4d783          	lhu	a5,74(s1)
    80005460:	2785                	addiw	a5,a5,1
    80005462:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005466:	8526                	mv	a0,s1
    80005468:	ffffe097          	auipc	ra,0xffffe
    8000546c:	234080e7          	jalr	564(ra) # 8000369c <iupdate>
  iunlock(ip);
    80005470:	8526                	mv	a0,s1
    80005472:	ffffe097          	auipc	ra,0xffffe
    80005476:	3b6080e7          	jalr	950(ra) # 80003828 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000547a:	fd040593          	addi	a1,s0,-48
    8000547e:	f5040513          	addi	a0,s0,-176
    80005482:	fffff097          	auipc	ra,0xfffff
    80005486:	ab2080e7          	jalr	-1358(ra) # 80003f34 <nameiparent>
    8000548a:	892a                	mv	s2,a0
    8000548c:	c935                	beqz	a0,80005500 <sys_link+0x10a>
  ilock(dp);
    8000548e:	ffffe097          	auipc	ra,0xffffe
    80005492:	2d8080e7          	jalr	728(ra) # 80003766 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005496:	00092703          	lw	a4,0(s2)
    8000549a:	409c                	lw	a5,0(s1)
    8000549c:	04f71d63          	bne	a4,a5,800054f6 <sys_link+0x100>
    800054a0:	40d0                	lw	a2,4(s1)
    800054a2:	fd040593          	addi	a1,s0,-48
    800054a6:	854a                	mv	a0,s2
    800054a8:	fffff097          	auipc	ra,0xfffff
    800054ac:	9ac080e7          	jalr	-1620(ra) # 80003e54 <dirlink>
    800054b0:	04054363          	bltz	a0,800054f6 <sys_link+0x100>
  iunlockput(dp);
    800054b4:	854a                	mv	a0,s2
    800054b6:	ffffe097          	auipc	ra,0xffffe
    800054ba:	512080e7          	jalr	1298(ra) # 800039c8 <iunlockput>
  iput(ip);
    800054be:	8526                	mv	a0,s1
    800054c0:	ffffe097          	auipc	ra,0xffffe
    800054c4:	460080e7          	jalr	1120(ra) # 80003920 <iput>
  end_op();
    800054c8:	fffff097          	auipc	ra,0xfffff
    800054cc:	cda080e7          	jalr	-806(ra) # 800041a2 <end_op>
  return 0;
    800054d0:	4781                	li	a5,0
    800054d2:	a085                	j	80005532 <sys_link+0x13c>
    end_op();
    800054d4:	fffff097          	auipc	ra,0xfffff
    800054d8:	cce080e7          	jalr	-818(ra) # 800041a2 <end_op>
    return -1;
    800054dc:	57fd                	li	a5,-1
    800054de:	a891                	j	80005532 <sys_link+0x13c>
    iunlockput(ip);
    800054e0:	8526                	mv	a0,s1
    800054e2:	ffffe097          	auipc	ra,0xffffe
    800054e6:	4e6080e7          	jalr	1254(ra) # 800039c8 <iunlockput>
    end_op();
    800054ea:	fffff097          	auipc	ra,0xfffff
    800054ee:	cb8080e7          	jalr	-840(ra) # 800041a2 <end_op>
    return -1;
    800054f2:	57fd                	li	a5,-1
    800054f4:	a83d                	j	80005532 <sys_link+0x13c>
    iunlockput(dp);
    800054f6:	854a                	mv	a0,s2
    800054f8:	ffffe097          	auipc	ra,0xffffe
    800054fc:	4d0080e7          	jalr	1232(ra) # 800039c8 <iunlockput>
  ilock(ip);
    80005500:	8526                	mv	a0,s1
    80005502:	ffffe097          	auipc	ra,0xffffe
    80005506:	264080e7          	jalr	612(ra) # 80003766 <ilock>
  ip->nlink--;
    8000550a:	04a4d783          	lhu	a5,74(s1)
    8000550e:	37fd                	addiw	a5,a5,-1
    80005510:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005514:	8526                	mv	a0,s1
    80005516:	ffffe097          	auipc	ra,0xffffe
    8000551a:	186080e7          	jalr	390(ra) # 8000369c <iupdate>
  iunlockput(ip);
    8000551e:	8526                	mv	a0,s1
    80005520:	ffffe097          	auipc	ra,0xffffe
    80005524:	4a8080e7          	jalr	1192(ra) # 800039c8 <iunlockput>
  end_op();
    80005528:	fffff097          	auipc	ra,0xfffff
    8000552c:	c7a080e7          	jalr	-902(ra) # 800041a2 <end_op>
  return -1;
    80005530:	57fd                	li	a5,-1
}
    80005532:	853e                	mv	a0,a5
    80005534:	70b2                	ld	ra,296(sp)
    80005536:	7412                	ld	s0,288(sp)
    80005538:	64f2                	ld	s1,280(sp)
    8000553a:	6952                	ld	s2,272(sp)
    8000553c:	6155                	addi	sp,sp,304
    8000553e:	8082                	ret

0000000080005540 <sys_unlink>:
{
    80005540:	7151                	addi	sp,sp,-240
    80005542:	f586                	sd	ra,232(sp)
    80005544:	f1a2                	sd	s0,224(sp)
    80005546:	eda6                	sd	s1,216(sp)
    80005548:	e9ca                	sd	s2,208(sp)
    8000554a:	e5ce                	sd	s3,200(sp)
    8000554c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000554e:	08000613          	li	a2,128
    80005552:	f3040593          	addi	a1,s0,-208
    80005556:	4501                	li	a0,0
    80005558:	ffffd097          	auipc	ra,0xffffd
    8000555c:	618080e7          	jalr	1560(ra) # 80002b70 <argstr>
    80005560:	18054163          	bltz	a0,800056e2 <sys_unlink+0x1a2>
  begin_op();
    80005564:	fffff097          	auipc	ra,0xfffff
    80005568:	bbe080e7          	jalr	-1090(ra) # 80004122 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000556c:	fb040593          	addi	a1,s0,-80
    80005570:	f3040513          	addi	a0,s0,-208
    80005574:	fffff097          	auipc	ra,0xfffff
    80005578:	9c0080e7          	jalr	-1600(ra) # 80003f34 <nameiparent>
    8000557c:	84aa                	mv	s1,a0
    8000557e:	c979                	beqz	a0,80005654 <sys_unlink+0x114>
  ilock(dp);
    80005580:	ffffe097          	auipc	ra,0xffffe
    80005584:	1e6080e7          	jalr	486(ra) # 80003766 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005588:	00003597          	auipc	a1,0x3
    8000558c:	22858593          	addi	a1,a1,552 # 800087b0 <syscalls+0x2c8>
    80005590:	fb040513          	addi	a0,s0,-80
    80005594:	ffffe097          	auipc	ra,0xffffe
    80005598:	696080e7          	jalr	1686(ra) # 80003c2a <namecmp>
    8000559c:	14050a63          	beqz	a0,800056f0 <sys_unlink+0x1b0>
    800055a0:	00003597          	auipc	a1,0x3
    800055a4:	21858593          	addi	a1,a1,536 # 800087b8 <syscalls+0x2d0>
    800055a8:	fb040513          	addi	a0,s0,-80
    800055ac:	ffffe097          	auipc	ra,0xffffe
    800055b0:	67e080e7          	jalr	1662(ra) # 80003c2a <namecmp>
    800055b4:	12050e63          	beqz	a0,800056f0 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800055b8:	f2c40613          	addi	a2,s0,-212
    800055bc:	fb040593          	addi	a1,s0,-80
    800055c0:	8526                	mv	a0,s1
    800055c2:	ffffe097          	auipc	ra,0xffffe
    800055c6:	682080e7          	jalr	1666(ra) # 80003c44 <dirlookup>
    800055ca:	892a                	mv	s2,a0
    800055cc:	12050263          	beqz	a0,800056f0 <sys_unlink+0x1b0>
  ilock(ip);
    800055d0:	ffffe097          	auipc	ra,0xffffe
    800055d4:	196080e7          	jalr	406(ra) # 80003766 <ilock>
  if(ip->nlink < 1)
    800055d8:	04a91783          	lh	a5,74(s2)
    800055dc:	08f05263          	blez	a5,80005660 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800055e0:	04491703          	lh	a4,68(s2)
    800055e4:	4785                	li	a5,1
    800055e6:	08f70563          	beq	a4,a5,80005670 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800055ea:	4641                	li	a2,16
    800055ec:	4581                	li	a1,0
    800055ee:	fc040513          	addi	a0,s0,-64
    800055f2:	ffffb097          	auipc	ra,0xffffb
    800055f6:	76c080e7          	jalr	1900(ra) # 80000d5e <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800055fa:	4741                	li	a4,16
    800055fc:	f2c42683          	lw	a3,-212(s0)
    80005600:	fc040613          	addi	a2,s0,-64
    80005604:	4581                	li	a1,0
    80005606:	8526                	mv	a0,s1
    80005608:	ffffe097          	auipc	ra,0xffffe
    8000560c:	508080e7          	jalr	1288(ra) # 80003b10 <writei>
    80005610:	47c1                	li	a5,16
    80005612:	0af51563          	bne	a0,a5,800056bc <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005616:	04491703          	lh	a4,68(s2)
    8000561a:	4785                	li	a5,1
    8000561c:	0af70863          	beq	a4,a5,800056cc <sys_unlink+0x18c>
  iunlockput(dp);
    80005620:	8526                	mv	a0,s1
    80005622:	ffffe097          	auipc	ra,0xffffe
    80005626:	3a6080e7          	jalr	934(ra) # 800039c8 <iunlockput>
  ip->nlink--;
    8000562a:	04a95783          	lhu	a5,74(s2)
    8000562e:	37fd                	addiw	a5,a5,-1
    80005630:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005634:	854a                	mv	a0,s2
    80005636:	ffffe097          	auipc	ra,0xffffe
    8000563a:	066080e7          	jalr	102(ra) # 8000369c <iupdate>
  iunlockput(ip);
    8000563e:	854a                	mv	a0,s2
    80005640:	ffffe097          	auipc	ra,0xffffe
    80005644:	388080e7          	jalr	904(ra) # 800039c8 <iunlockput>
  end_op();
    80005648:	fffff097          	auipc	ra,0xfffff
    8000564c:	b5a080e7          	jalr	-1190(ra) # 800041a2 <end_op>
  return 0;
    80005650:	4501                	li	a0,0
    80005652:	a84d                	j	80005704 <sys_unlink+0x1c4>
    end_op();
    80005654:	fffff097          	auipc	ra,0xfffff
    80005658:	b4e080e7          	jalr	-1202(ra) # 800041a2 <end_op>
    return -1;
    8000565c:	557d                	li	a0,-1
    8000565e:	a05d                	j	80005704 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005660:	00003517          	auipc	a0,0x3
    80005664:	18050513          	addi	a0,a0,384 # 800087e0 <syscalls+0x2f8>
    80005668:	ffffb097          	auipc	ra,0xffffb
    8000566c:	ee0080e7          	jalr	-288(ra) # 80000548 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005670:	04c92703          	lw	a4,76(s2)
    80005674:	02000793          	li	a5,32
    80005678:	f6e7f9e3          	bgeu	a5,a4,800055ea <sys_unlink+0xaa>
    8000567c:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005680:	4741                	li	a4,16
    80005682:	86ce                	mv	a3,s3
    80005684:	f1840613          	addi	a2,s0,-232
    80005688:	4581                	li	a1,0
    8000568a:	854a                	mv	a0,s2
    8000568c:	ffffe097          	auipc	ra,0xffffe
    80005690:	38e080e7          	jalr	910(ra) # 80003a1a <readi>
    80005694:	47c1                	li	a5,16
    80005696:	00f51b63          	bne	a0,a5,800056ac <sys_unlink+0x16c>
    if(de.inum != 0)
    8000569a:	f1845783          	lhu	a5,-232(s0)
    8000569e:	e7a1                	bnez	a5,800056e6 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800056a0:	29c1                	addiw	s3,s3,16
    800056a2:	04c92783          	lw	a5,76(s2)
    800056a6:	fcf9ede3          	bltu	s3,a5,80005680 <sys_unlink+0x140>
    800056aa:	b781                	j	800055ea <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800056ac:	00003517          	auipc	a0,0x3
    800056b0:	14c50513          	addi	a0,a0,332 # 800087f8 <syscalls+0x310>
    800056b4:	ffffb097          	auipc	ra,0xffffb
    800056b8:	e94080e7          	jalr	-364(ra) # 80000548 <panic>
    panic("unlink: writei");
    800056bc:	00003517          	auipc	a0,0x3
    800056c0:	15450513          	addi	a0,a0,340 # 80008810 <syscalls+0x328>
    800056c4:	ffffb097          	auipc	ra,0xffffb
    800056c8:	e84080e7          	jalr	-380(ra) # 80000548 <panic>
    dp->nlink--;
    800056cc:	04a4d783          	lhu	a5,74(s1)
    800056d0:	37fd                	addiw	a5,a5,-1
    800056d2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800056d6:	8526                	mv	a0,s1
    800056d8:	ffffe097          	auipc	ra,0xffffe
    800056dc:	fc4080e7          	jalr	-60(ra) # 8000369c <iupdate>
    800056e0:	b781                	j	80005620 <sys_unlink+0xe0>
    return -1;
    800056e2:	557d                	li	a0,-1
    800056e4:	a005                	j	80005704 <sys_unlink+0x1c4>
    iunlockput(ip);
    800056e6:	854a                	mv	a0,s2
    800056e8:	ffffe097          	auipc	ra,0xffffe
    800056ec:	2e0080e7          	jalr	736(ra) # 800039c8 <iunlockput>
  iunlockput(dp);
    800056f0:	8526                	mv	a0,s1
    800056f2:	ffffe097          	auipc	ra,0xffffe
    800056f6:	2d6080e7          	jalr	726(ra) # 800039c8 <iunlockput>
  end_op();
    800056fa:	fffff097          	auipc	ra,0xfffff
    800056fe:	aa8080e7          	jalr	-1368(ra) # 800041a2 <end_op>
  return -1;
    80005702:	557d                	li	a0,-1
}
    80005704:	70ae                	ld	ra,232(sp)
    80005706:	740e                	ld	s0,224(sp)
    80005708:	64ee                	ld	s1,216(sp)
    8000570a:	694e                	ld	s2,208(sp)
    8000570c:	69ae                	ld	s3,200(sp)
    8000570e:	616d                	addi	sp,sp,240
    80005710:	8082                	ret

0000000080005712 <sys_open>:

uint64
sys_open(void)
{
    80005712:	7131                	addi	sp,sp,-192
    80005714:	fd06                	sd	ra,184(sp)
    80005716:	f922                	sd	s0,176(sp)
    80005718:	f526                	sd	s1,168(sp)
    8000571a:	f14a                	sd	s2,160(sp)
    8000571c:	ed4e                	sd	s3,152(sp)
    8000571e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005720:	08000613          	li	a2,128
    80005724:	f5040593          	addi	a1,s0,-176
    80005728:	4501                	li	a0,0
    8000572a:	ffffd097          	auipc	ra,0xffffd
    8000572e:	446080e7          	jalr	1094(ra) # 80002b70 <argstr>
    return -1;
    80005732:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005734:	0c054163          	bltz	a0,800057f6 <sys_open+0xe4>
    80005738:	f4c40593          	addi	a1,s0,-180
    8000573c:	4505                	li	a0,1
    8000573e:	ffffd097          	auipc	ra,0xffffd
    80005742:	3ee080e7          	jalr	1006(ra) # 80002b2c <argint>
    80005746:	0a054863          	bltz	a0,800057f6 <sys_open+0xe4>

  begin_op();
    8000574a:	fffff097          	auipc	ra,0xfffff
    8000574e:	9d8080e7          	jalr	-1576(ra) # 80004122 <begin_op>

  if(omode & O_CREATE){
    80005752:	f4c42783          	lw	a5,-180(s0)
    80005756:	2007f793          	andi	a5,a5,512
    8000575a:	cbdd                	beqz	a5,80005810 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000575c:	4681                	li	a3,0
    8000575e:	4601                	li	a2,0
    80005760:	4589                	li	a1,2
    80005762:	f5040513          	addi	a0,s0,-176
    80005766:	00000097          	auipc	ra,0x0
    8000576a:	972080e7          	jalr	-1678(ra) # 800050d8 <create>
    8000576e:	892a                	mv	s2,a0
    if(ip == 0){
    80005770:	c959                	beqz	a0,80005806 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005772:	04491703          	lh	a4,68(s2)
    80005776:	478d                	li	a5,3
    80005778:	00f71763          	bne	a4,a5,80005786 <sys_open+0x74>
    8000577c:	04695703          	lhu	a4,70(s2)
    80005780:	47a5                	li	a5,9
    80005782:	0ce7ec63          	bltu	a5,a4,8000585a <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005786:	fffff097          	auipc	ra,0xfffff
    8000578a:	db2080e7          	jalr	-590(ra) # 80004538 <filealloc>
    8000578e:	89aa                	mv	s3,a0
    80005790:	10050263          	beqz	a0,80005894 <sys_open+0x182>
    80005794:	00000097          	auipc	ra,0x0
    80005798:	902080e7          	jalr	-1790(ra) # 80005096 <fdalloc>
    8000579c:	84aa                	mv	s1,a0
    8000579e:	0e054663          	bltz	a0,8000588a <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800057a2:	04491703          	lh	a4,68(s2)
    800057a6:	478d                	li	a5,3
    800057a8:	0cf70463          	beq	a4,a5,80005870 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800057ac:	4789                	li	a5,2
    800057ae:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800057b2:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800057b6:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    800057ba:	f4c42783          	lw	a5,-180(s0)
    800057be:	0017c713          	xori	a4,a5,1
    800057c2:	8b05                	andi	a4,a4,1
    800057c4:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800057c8:	0037f713          	andi	a4,a5,3
    800057cc:	00e03733          	snez	a4,a4
    800057d0:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800057d4:	4007f793          	andi	a5,a5,1024
    800057d8:	c791                	beqz	a5,800057e4 <sys_open+0xd2>
    800057da:	04491703          	lh	a4,68(s2)
    800057de:	4789                	li	a5,2
    800057e0:	08f70f63          	beq	a4,a5,8000587e <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800057e4:	854a                	mv	a0,s2
    800057e6:	ffffe097          	auipc	ra,0xffffe
    800057ea:	042080e7          	jalr	66(ra) # 80003828 <iunlock>
  end_op();
    800057ee:	fffff097          	auipc	ra,0xfffff
    800057f2:	9b4080e7          	jalr	-1612(ra) # 800041a2 <end_op>

  return fd;
}
    800057f6:	8526                	mv	a0,s1
    800057f8:	70ea                	ld	ra,184(sp)
    800057fa:	744a                	ld	s0,176(sp)
    800057fc:	74aa                	ld	s1,168(sp)
    800057fe:	790a                	ld	s2,160(sp)
    80005800:	69ea                	ld	s3,152(sp)
    80005802:	6129                	addi	sp,sp,192
    80005804:	8082                	ret
      end_op();
    80005806:	fffff097          	auipc	ra,0xfffff
    8000580a:	99c080e7          	jalr	-1636(ra) # 800041a2 <end_op>
      return -1;
    8000580e:	b7e5                	j	800057f6 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005810:	f5040513          	addi	a0,s0,-176
    80005814:	ffffe097          	auipc	ra,0xffffe
    80005818:	702080e7          	jalr	1794(ra) # 80003f16 <namei>
    8000581c:	892a                	mv	s2,a0
    8000581e:	c905                	beqz	a0,8000584e <sys_open+0x13c>
    ilock(ip);
    80005820:	ffffe097          	auipc	ra,0xffffe
    80005824:	f46080e7          	jalr	-186(ra) # 80003766 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005828:	04491703          	lh	a4,68(s2)
    8000582c:	4785                	li	a5,1
    8000582e:	f4f712e3          	bne	a4,a5,80005772 <sys_open+0x60>
    80005832:	f4c42783          	lw	a5,-180(s0)
    80005836:	dba1                	beqz	a5,80005786 <sys_open+0x74>
      iunlockput(ip);
    80005838:	854a                	mv	a0,s2
    8000583a:	ffffe097          	auipc	ra,0xffffe
    8000583e:	18e080e7          	jalr	398(ra) # 800039c8 <iunlockput>
      end_op();
    80005842:	fffff097          	auipc	ra,0xfffff
    80005846:	960080e7          	jalr	-1696(ra) # 800041a2 <end_op>
      return -1;
    8000584a:	54fd                	li	s1,-1
    8000584c:	b76d                	j	800057f6 <sys_open+0xe4>
      end_op();
    8000584e:	fffff097          	auipc	ra,0xfffff
    80005852:	954080e7          	jalr	-1708(ra) # 800041a2 <end_op>
      return -1;
    80005856:	54fd                	li	s1,-1
    80005858:	bf79                	j	800057f6 <sys_open+0xe4>
    iunlockput(ip);
    8000585a:	854a                	mv	a0,s2
    8000585c:	ffffe097          	auipc	ra,0xffffe
    80005860:	16c080e7          	jalr	364(ra) # 800039c8 <iunlockput>
    end_op();
    80005864:	fffff097          	auipc	ra,0xfffff
    80005868:	93e080e7          	jalr	-1730(ra) # 800041a2 <end_op>
    return -1;
    8000586c:	54fd                	li	s1,-1
    8000586e:	b761                	j	800057f6 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005870:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005874:	04691783          	lh	a5,70(s2)
    80005878:	02f99223          	sh	a5,36(s3)
    8000587c:	bf2d                	j	800057b6 <sys_open+0xa4>
    itrunc(ip);
    8000587e:	854a                	mv	a0,s2
    80005880:	ffffe097          	auipc	ra,0xffffe
    80005884:	ff4080e7          	jalr	-12(ra) # 80003874 <itrunc>
    80005888:	bfb1                	j	800057e4 <sys_open+0xd2>
      fileclose(f);
    8000588a:	854e                	mv	a0,s3
    8000588c:	fffff097          	auipc	ra,0xfffff
    80005890:	d68080e7          	jalr	-664(ra) # 800045f4 <fileclose>
    iunlockput(ip);
    80005894:	854a                	mv	a0,s2
    80005896:	ffffe097          	auipc	ra,0xffffe
    8000589a:	132080e7          	jalr	306(ra) # 800039c8 <iunlockput>
    end_op();
    8000589e:	fffff097          	auipc	ra,0xfffff
    800058a2:	904080e7          	jalr	-1788(ra) # 800041a2 <end_op>
    return -1;
    800058a6:	54fd                	li	s1,-1
    800058a8:	b7b9                	j	800057f6 <sys_open+0xe4>

00000000800058aa <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800058aa:	7175                	addi	sp,sp,-144
    800058ac:	e506                	sd	ra,136(sp)
    800058ae:	e122                	sd	s0,128(sp)
    800058b0:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800058b2:	fffff097          	auipc	ra,0xfffff
    800058b6:	870080e7          	jalr	-1936(ra) # 80004122 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800058ba:	08000613          	li	a2,128
    800058be:	f7040593          	addi	a1,s0,-144
    800058c2:	4501                	li	a0,0
    800058c4:	ffffd097          	auipc	ra,0xffffd
    800058c8:	2ac080e7          	jalr	684(ra) # 80002b70 <argstr>
    800058cc:	02054963          	bltz	a0,800058fe <sys_mkdir+0x54>
    800058d0:	4681                	li	a3,0
    800058d2:	4601                	li	a2,0
    800058d4:	4585                	li	a1,1
    800058d6:	f7040513          	addi	a0,s0,-144
    800058da:	fffff097          	auipc	ra,0xfffff
    800058de:	7fe080e7          	jalr	2046(ra) # 800050d8 <create>
    800058e2:	cd11                	beqz	a0,800058fe <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800058e4:	ffffe097          	auipc	ra,0xffffe
    800058e8:	0e4080e7          	jalr	228(ra) # 800039c8 <iunlockput>
  end_op();
    800058ec:	fffff097          	auipc	ra,0xfffff
    800058f0:	8b6080e7          	jalr	-1866(ra) # 800041a2 <end_op>
  return 0;
    800058f4:	4501                	li	a0,0
}
    800058f6:	60aa                	ld	ra,136(sp)
    800058f8:	640a                	ld	s0,128(sp)
    800058fa:	6149                	addi	sp,sp,144
    800058fc:	8082                	ret
    end_op();
    800058fe:	fffff097          	auipc	ra,0xfffff
    80005902:	8a4080e7          	jalr	-1884(ra) # 800041a2 <end_op>
    return -1;
    80005906:	557d                	li	a0,-1
    80005908:	b7fd                	j	800058f6 <sys_mkdir+0x4c>

000000008000590a <sys_mknod>:

uint64
sys_mknod(void)
{
    8000590a:	7135                	addi	sp,sp,-160
    8000590c:	ed06                	sd	ra,152(sp)
    8000590e:	e922                	sd	s0,144(sp)
    80005910:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005912:	fffff097          	auipc	ra,0xfffff
    80005916:	810080e7          	jalr	-2032(ra) # 80004122 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000591a:	08000613          	li	a2,128
    8000591e:	f7040593          	addi	a1,s0,-144
    80005922:	4501                	li	a0,0
    80005924:	ffffd097          	auipc	ra,0xffffd
    80005928:	24c080e7          	jalr	588(ra) # 80002b70 <argstr>
    8000592c:	04054a63          	bltz	a0,80005980 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005930:	f6c40593          	addi	a1,s0,-148
    80005934:	4505                	li	a0,1
    80005936:	ffffd097          	auipc	ra,0xffffd
    8000593a:	1f6080e7          	jalr	502(ra) # 80002b2c <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000593e:	04054163          	bltz	a0,80005980 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005942:	f6840593          	addi	a1,s0,-152
    80005946:	4509                	li	a0,2
    80005948:	ffffd097          	auipc	ra,0xffffd
    8000594c:	1e4080e7          	jalr	484(ra) # 80002b2c <argint>
     argint(1, &major) < 0 ||
    80005950:	02054863          	bltz	a0,80005980 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005954:	f6841683          	lh	a3,-152(s0)
    80005958:	f6c41603          	lh	a2,-148(s0)
    8000595c:	458d                	li	a1,3
    8000595e:	f7040513          	addi	a0,s0,-144
    80005962:	fffff097          	auipc	ra,0xfffff
    80005966:	776080e7          	jalr	1910(ra) # 800050d8 <create>
     argint(2, &minor) < 0 ||
    8000596a:	c919                	beqz	a0,80005980 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000596c:	ffffe097          	auipc	ra,0xffffe
    80005970:	05c080e7          	jalr	92(ra) # 800039c8 <iunlockput>
  end_op();
    80005974:	fffff097          	auipc	ra,0xfffff
    80005978:	82e080e7          	jalr	-2002(ra) # 800041a2 <end_op>
  return 0;
    8000597c:	4501                	li	a0,0
    8000597e:	a031                	j	8000598a <sys_mknod+0x80>
    end_op();
    80005980:	fffff097          	auipc	ra,0xfffff
    80005984:	822080e7          	jalr	-2014(ra) # 800041a2 <end_op>
    return -1;
    80005988:	557d                	li	a0,-1
}
    8000598a:	60ea                	ld	ra,152(sp)
    8000598c:	644a                	ld	s0,144(sp)
    8000598e:	610d                	addi	sp,sp,160
    80005990:	8082                	ret

0000000080005992 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005992:	7135                	addi	sp,sp,-160
    80005994:	ed06                	sd	ra,152(sp)
    80005996:	e922                	sd	s0,144(sp)
    80005998:	e526                	sd	s1,136(sp)
    8000599a:	e14a                	sd	s2,128(sp)
    8000599c:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000599e:	ffffc097          	auipc	ra,0xffffc
    800059a2:	092080e7          	jalr	146(ra) # 80001a30 <myproc>
    800059a6:	892a                	mv	s2,a0
  
  begin_op();
    800059a8:	ffffe097          	auipc	ra,0xffffe
    800059ac:	77a080e7          	jalr	1914(ra) # 80004122 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800059b0:	08000613          	li	a2,128
    800059b4:	f6040593          	addi	a1,s0,-160
    800059b8:	4501                	li	a0,0
    800059ba:	ffffd097          	auipc	ra,0xffffd
    800059be:	1b6080e7          	jalr	438(ra) # 80002b70 <argstr>
    800059c2:	04054b63          	bltz	a0,80005a18 <sys_chdir+0x86>
    800059c6:	f6040513          	addi	a0,s0,-160
    800059ca:	ffffe097          	auipc	ra,0xffffe
    800059ce:	54c080e7          	jalr	1356(ra) # 80003f16 <namei>
    800059d2:	84aa                	mv	s1,a0
    800059d4:	c131                	beqz	a0,80005a18 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800059d6:	ffffe097          	auipc	ra,0xffffe
    800059da:	d90080e7          	jalr	-624(ra) # 80003766 <ilock>
  if(ip->type != T_DIR){
    800059de:	04449703          	lh	a4,68(s1)
    800059e2:	4785                	li	a5,1
    800059e4:	04f71063          	bne	a4,a5,80005a24 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800059e8:	8526                	mv	a0,s1
    800059ea:	ffffe097          	auipc	ra,0xffffe
    800059ee:	e3e080e7          	jalr	-450(ra) # 80003828 <iunlock>
  iput(p->cwd);
    800059f2:	15093503          	ld	a0,336(s2)
    800059f6:	ffffe097          	auipc	ra,0xffffe
    800059fa:	f2a080e7          	jalr	-214(ra) # 80003920 <iput>
  end_op();
    800059fe:	ffffe097          	auipc	ra,0xffffe
    80005a02:	7a4080e7          	jalr	1956(ra) # 800041a2 <end_op>
  p->cwd = ip;
    80005a06:	14993823          	sd	s1,336(s2)
  return 0;
    80005a0a:	4501                	li	a0,0
}
    80005a0c:	60ea                	ld	ra,152(sp)
    80005a0e:	644a                	ld	s0,144(sp)
    80005a10:	64aa                	ld	s1,136(sp)
    80005a12:	690a                	ld	s2,128(sp)
    80005a14:	610d                	addi	sp,sp,160
    80005a16:	8082                	ret
    end_op();
    80005a18:	ffffe097          	auipc	ra,0xffffe
    80005a1c:	78a080e7          	jalr	1930(ra) # 800041a2 <end_op>
    return -1;
    80005a20:	557d                	li	a0,-1
    80005a22:	b7ed                	j	80005a0c <sys_chdir+0x7a>
    iunlockput(ip);
    80005a24:	8526                	mv	a0,s1
    80005a26:	ffffe097          	auipc	ra,0xffffe
    80005a2a:	fa2080e7          	jalr	-94(ra) # 800039c8 <iunlockput>
    end_op();
    80005a2e:	ffffe097          	auipc	ra,0xffffe
    80005a32:	774080e7          	jalr	1908(ra) # 800041a2 <end_op>
    return -1;
    80005a36:	557d                	li	a0,-1
    80005a38:	bfd1                	j	80005a0c <sys_chdir+0x7a>

0000000080005a3a <sys_exec>:

uint64
sys_exec(void)
{
    80005a3a:	7145                	addi	sp,sp,-464
    80005a3c:	e786                	sd	ra,456(sp)
    80005a3e:	e3a2                	sd	s0,448(sp)
    80005a40:	ff26                	sd	s1,440(sp)
    80005a42:	fb4a                	sd	s2,432(sp)
    80005a44:	f74e                	sd	s3,424(sp)
    80005a46:	f352                	sd	s4,416(sp)
    80005a48:	ef56                	sd	s5,408(sp)
    80005a4a:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005a4c:	08000613          	li	a2,128
    80005a50:	f4040593          	addi	a1,s0,-192
    80005a54:	4501                	li	a0,0
    80005a56:	ffffd097          	auipc	ra,0xffffd
    80005a5a:	11a080e7          	jalr	282(ra) # 80002b70 <argstr>
    return -1;
    80005a5e:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005a60:	0c054a63          	bltz	a0,80005b34 <sys_exec+0xfa>
    80005a64:	e3840593          	addi	a1,s0,-456
    80005a68:	4505                	li	a0,1
    80005a6a:	ffffd097          	auipc	ra,0xffffd
    80005a6e:	0e4080e7          	jalr	228(ra) # 80002b4e <argaddr>
    80005a72:	0c054163          	bltz	a0,80005b34 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005a76:	10000613          	li	a2,256
    80005a7a:	4581                	li	a1,0
    80005a7c:	e4040513          	addi	a0,s0,-448
    80005a80:	ffffb097          	auipc	ra,0xffffb
    80005a84:	2de080e7          	jalr	734(ra) # 80000d5e <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005a88:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005a8c:	89a6                	mv	s3,s1
    80005a8e:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005a90:	02000a13          	li	s4,32
    80005a94:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005a98:	00391513          	slli	a0,s2,0x3
    80005a9c:	e3040593          	addi	a1,s0,-464
    80005aa0:	e3843783          	ld	a5,-456(s0)
    80005aa4:	953e                	add	a0,a0,a5
    80005aa6:	ffffd097          	auipc	ra,0xffffd
    80005aaa:	fec080e7          	jalr	-20(ra) # 80002a92 <fetchaddr>
    80005aae:	02054a63          	bltz	a0,80005ae2 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005ab2:	e3043783          	ld	a5,-464(s0)
    80005ab6:	c3b9                	beqz	a5,80005afc <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005ab8:	ffffb097          	auipc	ra,0xffffb
    80005abc:	068080e7          	jalr	104(ra) # 80000b20 <kalloc>
    80005ac0:	85aa                	mv	a1,a0
    80005ac2:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005ac6:	cd11                	beqz	a0,80005ae2 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005ac8:	6605                	lui	a2,0x1
    80005aca:	e3043503          	ld	a0,-464(s0)
    80005ace:	ffffd097          	auipc	ra,0xffffd
    80005ad2:	016080e7          	jalr	22(ra) # 80002ae4 <fetchstr>
    80005ad6:	00054663          	bltz	a0,80005ae2 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005ada:	0905                	addi	s2,s2,1
    80005adc:	09a1                	addi	s3,s3,8
    80005ade:	fb491be3          	bne	s2,s4,80005a94 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ae2:	10048913          	addi	s2,s1,256
    80005ae6:	6088                	ld	a0,0(s1)
    80005ae8:	c529                	beqz	a0,80005b32 <sys_exec+0xf8>
    kfree(argv[i]);
    80005aea:	ffffb097          	auipc	ra,0xffffb
    80005aee:	f3a080e7          	jalr	-198(ra) # 80000a24 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005af2:	04a1                	addi	s1,s1,8
    80005af4:	ff2499e3          	bne	s1,s2,80005ae6 <sys_exec+0xac>
  return -1;
    80005af8:	597d                	li	s2,-1
    80005afa:	a82d                	j	80005b34 <sys_exec+0xfa>
      argv[i] = 0;
    80005afc:	0a8e                	slli	s5,s5,0x3
    80005afe:	fc040793          	addi	a5,s0,-64
    80005b02:	9abe                	add	s5,s5,a5
    80005b04:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005b08:	e4040593          	addi	a1,s0,-448
    80005b0c:	f4040513          	addi	a0,s0,-192
    80005b10:	fffff097          	auipc	ra,0xfffff
    80005b14:	194080e7          	jalr	404(ra) # 80004ca4 <exec>
    80005b18:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b1a:	10048993          	addi	s3,s1,256
    80005b1e:	6088                	ld	a0,0(s1)
    80005b20:	c911                	beqz	a0,80005b34 <sys_exec+0xfa>
    kfree(argv[i]);
    80005b22:	ffffb097          	auipc	ra,0xffffb
    80005b26:	f02080e7          	jalr	-254(ra) # 80000a24 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b2a:	04a1                	addi	s1,s1,8
    80005b2c:	ff3499e3          	bne	s1,s3,80005b1e <sys_exec+0xe4>
    80005b30:	a011                	j	80005b34 <sys_exec+0xfa>
  return -1;
    80005b32:	597d                	li	s2,-1
}
    80005b34:	854a                	mv	a0,s2
    80005b36:	60be                	ld	ra,456(sp)
    80005b38:	641e                	ld	s0,448(sp)
    80005b3a:	74fa                	ld	s1,440(sp)
    80005b3c:	795a                	ld	s2,432(sp)
    80005b3e:	79ba                	ld	s3,424(sp)
    80005b40:	7a1a                	ld	s4,416(sp)
    80005b42:	6afa                	ld	s5,408(sp)
    80005b44:	6179                	addi	sp,sp,464
    80005b46:	8082                	ret

0000000080005b48 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005b48:	7139                	addi	sp,sp,-64
    80005b4a:	fc06                	sd	ra,56(sp)
    80005b4c:	f822                	sd	s0,48(sp)
    80005b4e:	f426                	sd	s1,40(sp)
    80005b50:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005b52:	ffffc097          	auipc	ra,0xffffc
    80005b56:	ede080e7          	jalr	-290(ra) # 80001a30 <myproc>
    80005b5a:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005b5c:	fd840593          	addi	a1,s0,-40
    80005b60:	4501                	li	a0,0
    80005b62:	ffffd097          	auipc	ra,0xffffd
    80005b66:	fec080e7          	jalr	-20(ra) # 80002b4e <argaddr>
    return -1;
    80005b6a:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005b6c:	0e054063          	bltz	a0,80005c4c <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005b70:	fc840593          	addi	a1,s0,-56
    80005b74:	fd040513          	addi	a0,s0,-48
    80005b78:	fffff097          	auipc	ra,0xfffff
    80005b7c:	dd2080e7          	jalr	-558(ra) # 8000494a <pipealloc>
    return -1;
    80005b80:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005b82:	0c054563          	bltz	a0,80005c4c <sys_pipe+0x104>
  fd0 = -1;
    80005b86:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005b8a:	fd043503          	ld	a0,-48(s0)
    80005b8e:	fffff097          	auipc	ra,0xfffff
    80005b92:	508080e7          	jalr	1288(ra) # 80005096 <fdalloc>
    80005b96:	fca42223          	sw	a0,-60(s0)
    80005b9a:	08054c63          	bltz	a0,80005c32 <sys_pipe+0xea>
    80005b9e:	fc843503          	ld	a0,-56(s0)
    80005ba2:	fffff097          	auipc	ra,0xfffff
    80005ba6:	4f4080e7          	jalr	1268(ra) # 80005096 <fdalloc>
    80005baa:	fca42023          	sw	a0,-64(s0)
    80005bae:	06054863          	bltz	a0,80005c1e <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005bb2:	4691                	li	a3,4
    80005bb4:	fc440613          	addi	a2,s0,-60
    80005bb8:	fd843583          	ld	a1,-40(s0)
    80005bbc:	68a8                	ld	a0,80(s1)
    80005bbe:	ffffc097          	auipc	ra,0xffffc
    80005bc2:	b66080e7          	jalr	-1178(ra) # 80001724 <copyout>
    80005bc6:	02054063          	bltz	a0,80005be6 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005bca:	4691                	li	a3,4
    80005bcc:	fc040613          	addi	a2,s0,-64
    80005bd0:	fd843583          	ld	a1,-40(s0)
    80005bd4:	0591                	addi	a1,a1,4
    80005bd6:	68a8                	ld	a0,80(s1)
    80005bd8:	ffffc097          	auipc	ra,0xffffc
    80005bdc:	b4c080e7          	jalr	-1204(ra) # 80001724 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005be0:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005be2:	06055563          	bgez	a0,80005c4c <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005be6:	fc442783          	lw	a5,-60(s0)
    80005bea:	07e9                	addi	a5,a5,26
    80005bec:	078e                	slli	a5,a5,0x3
    80005bee:	97a6                	add	a5,a5,s1
    80005bf0:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005bf4:	fc042503          	lw	a0,-64(s0)
    80005bf8:	0569                	addi	a0,a0,26
    80005bfa:	050e                	slli	a0,a0,0x3
    80005bfc:	9526                	add	a0,a0,s1
    80005bfe:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005c02:	fd043503          	ld	a0,-48(s0)
    80005c06:	fffff097          	auipc	ra,0xfffff
    80005c0a:	9ee080e7          	jalr	-1554(ra) # 800045f4 <fileclose>
    fileclose(wf);
    80005c0e:	fc843503          	ld	a0,-56(s0)
    80005c12:	fffff097          	auipc	ra,0xfffff
    80005c16:	9e2080e7          	jalr	-1566(ra) # 800045f4 <fileclose>
    return -1;
    80005c1a:	57fd                	li	a5,-1
    80005c1c:	a805                	j	80005c4c <sys_pipe+0x104>
    if(fd0 >= 0)
    80005c1e:	fc442783          	lw	a5,-60(s0)
    80005c22:	0007c863          	bltz	a5,80005c32 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005c26:	01a78513          	addi	a0,a5,26
    80005c2a:	050e                	slli	a0,a0,0x3
    80005c2c:	9526                	add	a0,a0,s1
    80005c2e:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005c32:	fd043503          	ld	a0,-48(s0)
    80005c36:	fffff097          	auipc	ra,0xfffff
    80005c3a:	9be080e7          	jalr	-1602(ra) # 800045f4 <fileclose>
    fileclose(wf);
    80005c3e:	fc843503          	ld	a0,-56(s0)
    80005c42:	fffff097          	auipc	ra,0xfffff
    80005c46:	9b2080e7          	jalr	-1614(ra) # 800045f4 <fileclose>
    return -1;
    80005c4a:	57fd                	li	a5,-1
}
    80005c4c:	853e                	mv	a0,a5
    80005c4e:	70e2                	ld	ra,56(sp)
    80005c50:	7442                	ld	s0,48(sp)
    80005c52:	74a2                	ld	s1,40(sp)
    80005c54:	6121                	addi	sp,sp,64
    80005c56:	8082                	ret
	...

0000000080005c60 <kernelvec>:
    80005c60:	7111                	addi	sp,sp,-256
    80005c62:	e006                	sd	ra,0(sp)
    80005c64:	e40a                	sd	sp,8(sp)
    80005c66:	e80e                	sd	gp,16(sp)
    80005c68:	ec12                	sd	tp,24(sp)
    80005c6a:	f016                	sd	t0,32(sp)
    80005c6c:	f41a                	sd	t1,40(sp)
    80005c6e:	f81e                	sd	t2,48(sp)
    80005c70:	fc22                	sd	s0,56(sp)
    80005c72:	e0a6                	sd	s1,64(sp)
    80005c74:	e4aa                	sd	a0,72(sp)
    80005c76:	e8ae                	sd	a1,80(sp)
    80005c78:	ecb2                	sd	a2,88(sp)
    80005c7a:	f0b6                	sd	a3,96(sp)
    80005c7c:	f4ba                	sd	a4,104(sp)
    80005c7e:	f8be                	sd	a5,112(sp)
    80005c80:	fcc2                	sd	a6,120(sp)
    80005c82:	e146                	sd	a7,128(sp)
    80005c84:	e54a                	sd	s2,136(sp)
    80005c86:	e94e                	sd	s3,144(sp)
    80005c88:	ed52                	sd	s4,152(sp)
    80005c8a:	f156                	sd	s5,160(sp)
    80005c8c:	f55a                	sd	s6,168(sp)
    80005c8e:	f95e                	sd	s7,176(sp)
    80005c90:	fd62                	sd	s8,184(sp)
    80005c92:	e1e6                	sd	s9,192(sp)
    80005c94:	e5ea                	sd	s10,200(sp)
    80005c96:	e9ee                	sd	s11,208(sp)
    80005c98:	edf2                	sd	t3,216(sp)
    80005c9a:	f1f6                	sd	t4,224(sp)
    80005c9c:	f5fa                	sd	t5,232(sp)
    80005c9e:	f9fe                	sd	t6,240(sp)
    80005ca0:	cbffc0ef          	jal	ra,8000295e <kerneltrap>
    80005ca4:	6082                	ld	ra,0(sp)
    80005ca6:	6122                	ld	sp,8(sp)
    80005ca8:	61c2                	ld	gp,16(sp)
    80005caa:	7282                	ld	t0,32(sp)
    80005cac:	7322                	ld	t1,40(sp)
    80005cae:	73c2                	ld	t2,48(sp)
    80005cb0:	7462                	ld	s0,56(sp)
    80005cb2:	6486                	ld	s1,64(sp)
    80005cb4:	6526                	ld	a0,72(sp)
    80005cb6:	65c6                	ld	a1,80(sp)
    80005cb8:	6666                	ld	a2,88(sp)
    80005cba:	7686                	ld	a3,96(sp)
    80005cbc:	7726                	ld	a4,104(sp)
    80005cbe:	77c6                	ld	a5,112(sp)
    80005cc0:	7866                	ld	a6,120(sp)
    80005cc2:	688a                	ld	a7,128(sp)
    80005cc4:	692a                	ld	s2,136(sp)
    80005cc6:	69ca                	ld	s3,144(sp)
    80005cc8:	6a6a                	ld	s4,152(sp)
    80005cca:	7a8a                	ld	s5,160(sp)
    80005ccc:	7b2a                	ld	s6,168(sp)
    80005cce:	7bca                	ld	s7,176(sp)
    80005cd0:	7c6a                	ld	s8,184(sp)
    80005cd2:	6c8e                	ld	s9,192(sp)
    80005cd4:	6d2e                	ld	s10,200(sp)
    80005cd6:	6dce                	ld	s11,208(sp)
    80005cd8:	6e6e                	ld	t3,216(sp)
    80005cda:	7e8e                	ld	t4,224(sp)
    80005cdc:	7f2e                	ld	t5,232(sp)
    80005cde:	7fce                	ld	t6,240(sp)
    80005ce0:	6111                	addi	sp,sp,256
    80005ce2:	10200073          	sret
    80005ce6:	00000013          	nop
    80005cea:	00000013          	nop
    80005cee:	0001                	nop

0000000080005cf0 <timervec>:
    80005cf0:	34051573          	csrrw	a0,mscratch,a0
    80005cf4:	e10c                	sd	a1,0(a0)
    80005cf6:	e510                	sd	a2,8(a0)
    80005cf8:	e914                	sd	a3,16(a0)
    80005cfa:	710c                	ld	a1,32(a0)
    80005cfc:	7510                	ld	a2,40(a0)
    80005cfe:	6194                	ld	a3,0(a1)
    80005d00:	96b2                	add	a3,a3,a2
    80005d02:	e194                	sd	a3,0(a1)
    80005d04:	4589                	li	a1,2
    80005d06:	14459073          	csrw	sip,a1
    80005d0a:	6914                	ld	a3,16(a0)
    80005d0c:	6510                	ld	a2,8(a0)
    80005d0e:	610c                	ld	a1,0(a0)
    80005d10:	34051573          	csrrw	a0,mscratch,a0
    80005d14:	30200073          	mret
	...

0000000080005d1a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005d1a:	1141                	addi	sp,sp,-16
    80005d1c:	e422                	sd	s0,8(sp)
    80005d1e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005d20:	0c0007b7          	lui	a5,0xc000
    80005d24:	4705                	li	a4,1
    80005d26:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005d28:	c3d8                	sw	a4,4(a5)
}
    80005d2a:	6422                	ld	s0,8(sp)
    80005d2c:	0141                	addi	sp,sp,16
    80005d2e:	8082                	ret

0000000080005d30 <plicinithart>:

void
plicinithart(void)
{
    80005d30:	1141                	addi	sp,sp,-16
    80005d32:	e406                	sd	ra,8(sp)
    80005d34:	e022                	sd	s0,0(sp)
    80005d36:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d38:	ffffc097          	auipc	ra,0xffffc
    80005d3c:	ccc080e7          	jalr	-820(ra) # 80001a04 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005d40:	0085171b          	slliw	a4,a0,0x8
    80005d44:	0c0027b7          	lui	a5,0xc002
    80005d48:	97ba                	add	a5,a5,a4
    80005d4a:	40200713          	li	a4,1026
    80005d4e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005d52:	00d5151b          	slliw	a0,a0,0xd
    80005d56:	0c2017b7          	lui	a5,0xc201
    80005d5a:	953e                	add	a0,a0,a5
    80005d5c:	00052023          	sw	zero,0(a0)
}
    80005d60:	60a2                	ld	ra,8(sp)
    80005d62:	6402                	ld	s0,0(sp)
    80005d64:	0141                	addi	sp,sp,16
    80005d66:	8082                	ret

0000000080005d68 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005d68:	1141                	addi	sp,sp,-16
    80005d6a:	e406                	sd	ra,8(sp)
    80005d6c:	e022                	sd	s0,0(sp)
    80005d6e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d70:	ffffc097          	auipc	ra,0xffffc
    80005d74:	c94080e7          	jalr	-876(ra) # 80001a04 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005d78:	00d5179b          	slliw	a5,a0,0xd
    80005d7c:	0c201537          	lui	a0,0xc201
    80005d80:	953e                	add	a0,a0,a5
  return irq;
}
    80005d82:	4148                	lw	a0,4(a0)
    80005d84:	60a2                	ld	ra,8(sp)
    80005d86:	6402                	ld	s0,0(sp)
    80005d88:	0141                	addi	sp,sp,16
    80005d8a:	8082                	ret

0000000080005d8c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005d8c:	1101                	addi	sp,sp,-32
    80005d8e:	ec06                	sd	ra,24(sp)
    80005d90:	e822                	sd	s0,16(sp)
    80005d92:	e426                	sd	s1,8(sp)
    80005d94:	1000                	addi	s0,sp,32
    80005d96:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005d98:	ffffc097          	auipc	ra,0xffffc
    80005d9c:	c6c080e7          	jalr	-916(ra) # 80001a04 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005da0:	00d5151b          	slliw	a0,a0,0xd
    80005da4:	0c2017b7          	lui	a5,0xc201
    80005da8:	97aa                	add	a5,a5,a0
    80005daa:	c3c4                	sw	s1,4(a5)
}
    80005dac:	60e2                	ld	ra,24(sp)
    80005dae:	6442                	ld	s0,16(sp)
    80005db0:	64a2                	ld	s1,8(sp)
    80005db2:	6105                	addi	sp,sp,32
    80005db4:	8082                	ret

0000000080005db6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005db6:	1141                	addi	sp,sp,-16
    80005db8:	e406                	sd	ra,8(sp)
    80005dba:	e022                	sd	s0,0(sp)
    80005dbc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005dbe:	479d                	li	a5,7
    80005dc0:	04a7cc63          	blt	a5,a0,80005e18 <free_desc+0x62>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005dc4:	0001d797          	auipc	a5,0x1d
    80005dc8:	23c78793          	addi	a5,a5,572 # 80023000 <disk>
    80005dcc:	00a78733          	add	a4,a5,a0
    80005dd0:	6789                	lui	a5,0x2
    80005dd2:	97ba                	add	a5,a5,a4
    80005dd4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005dd8:	eba1                	bnez	a5,80005e28 <free_desc+0x72>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005dda:	00451713          	slli	a4,a0,0x4
    80005dde:	0001f797          	auipc	a5,0x1f
    80005de2:	2227b783          	ld	a5,546(a5) # 80025000 <disk+0x2000>
    80005de6:	97ba                	add	a5,a5,a4
    80005de8:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80005dec:	0001d797          	auipc	a5,0x1d
    80005df0:	21478793          	addi	a5,a5,532 # 80023000 <disk>
    80005df4:	97aa                	add	a5,a5,a0
    80005df6:	6509                	lui	a0,0x2
    80005df8:	953e                	add	a0,a0,a5
    80005dfa:	4785                	li	a5,1
    80005dfc:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005e00:	0001f517          	auipc	a0,0x1f
    80005e04:	21850513          	addi	a0,a0,536 # 80025018 <disk+0x2018>
    80005e08:	ffffc097          	auipc	ra,0xffffc
    80005e0c:	5c6080e7          	jalr	1478(ra) # 800023ce <wakeup>
}
    80005e10:	60a2                	ld	ra,8(sp)
    80005e12:	6402                	ld	s0,0(sp)
    80005e14:	0141                	addi	sp,sp,16
    80005e16:	8082                	ret
    panic("virtio_disk_intr 1");
    80005e18:	00003517          	auipc	a0,0x3
    80005e1c:	a0850513          	addi	a0,a0,-1528 # 80008820 <syscalls+0x338>
    80005e20:	ffffa097          	auipc	ra,0xffffa
    80005e24:	728080e7          	jalr	1832(ra) # 80000548 <panic>
    panic("virtio_disk_intr 2");
    80005e28:	00003517          	auipc	a0,0x3
    80005e2c:	a1050513          	addi	a0,a0,-1520 # 80008838 <syscalls+0x350>
    80005e30:	ffffa097          	auipc	ra,0xffffa
    80005e34:	718080e7          	jalr	1816(ra) # 80000548 <panic>

0000000080005e38 <virtio_disk_init>:
{
    80005e38:	1101                	addi	sp,sp,-32
    80005e3a:	ec06                	sd	ra,24(sp)
    80005e3c:	e822                	sd	s0,16(sp)
    80005e3e:	e426                	sd	s1,8(sp)
    80005e40:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005e42:	00003597          	auipc	a1,0x3
    80005e46:	a0e58593          	addi	a1,a1,-1522 # 80008850 <syscalls+0x368>
    80005e4a:	0001f517          	auipc	a0,0x1f
    80005e4e:	25e50513          	addi	a0,a0,606 # 800250a8 <disk+0x20a8>
    80005e52:	ffffb097          	auipc	ra,0xffffb
    80005e56:	d80080e7          	jalr	-640(ra) # 80000bd2 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e5a:	100017b7          	lui	a5,0x10001
    80005e5e:	4398                	lw	a4,0(a5)
    80005e60:	2701                	sext.w	a4,a4
    80005e62:	747277b7          	lui	a5,0x74727
    80005e66:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005e6a:	0ef71163          	bne	a4,a5,80005f4c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005e6e:	100017b7          	lui	a5,0x10001
    80005e72:	43dc                	lw	a5,4(a5)
    80005e74:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e76:	4705                	li	a4,1
    80005e78:	0ce79a63          	bne	a5,a4,80005f4c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e7c:	100017b7          	lui	a5,0x10001
    80005e80:	479c                	lw	a5,8(a5)
    80005e82:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005e84:	4709                	li	a4,2
    80005e86:	0ce79363          	bne	a5,a4,80005f4c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005e8a:	100017b7          	lui	a5,0x10001
    80005e8e:	47d8                	lw	a4,12(a5)
    80005e90:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e92:	554d47b7          	lui	a5,0x554d4
    80005e96:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005e9a:	0af71963          	bne	a4,a5,80005f4c <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e9e:	100017b7          	lui	a5,0x10001
    80005ea2:	4705                	li	a4,1
    80005ea4:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ea6:	470d                	li	a4,3
    80005ea8:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005eaa:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005eac:	c7ffe737          	lui	a4,0xc7ffe
    80005eb0:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    80005eb4:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005eb6:	2701                	sext.w	a4,a4
    80005eb8:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005eba:	472d                	li	a4,11
    80005ebc:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ebe:	473d                	li	a4,15
    80005ec0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005ec2:	6705                	lui	a4,0x1
    80005ec4:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005ec6:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005eca:	5bdc                	lw	a5,52(a5)
    80005ecc:	2781                	sext.w	a5,a5
  if(max == 0)
    80005ece:	c7d9                	beqz	a5,80005f5c <virtio_disk_init+0x124>
  if(max < NUM)
    80005ed0:	471d                	li	a4,7
    80005ed2:	08f77d63          	bgeu	a4,a5,80005f6c <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005ed6:	100014b7          	lui	s1,0x10001
    80005eda:	47a1                	li	a5,8
    80005edc:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005ede:	6609                	lui	a2,0x2
    80005ee0:	4581                	li	a1,0
    80005ee2:	0001d517          	auipc	a0,0x1d
    80005ee6:	11e50513          	addi	a0,a0,286 # 80023000 <disk>
    80005eea:	ffffb097          	auipc	ra,0xffffb
    80005eee:	e74080e7          	jalr	-396(ra) # 80000d5e <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005ef2:	0001d717          	auipc	a4,0x1d
    80005ef6:	10e70713          	addi	a4,a4,270 # 80023000 <disk>
    80005efa:	00c75793          	srli	a5,a4,0xc
    80005efe:	2781                	sext.w	a5,a5
    80005f00:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    80005f02:	0001f797          	auipc	a5,0x1f
    80005f06:	0fe78793          	addi	a5,a5,254 # 80025000 <disk+0x2000>
    80005f0a:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    80005f0c:	0001d717          	auipc	a4,0x1d
    80005f10:	17470713          	addi	a4,a4,372 # 80023080 <disk+0x80>
    80005f14:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    80005f16:	0001e717          	auipc	a4,0x1e
    80005f1a:	0ea70713          	addi	a4,a4,234 # 80024000 <disk+0x1000>
    80005f1e:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80005f20:	4705                	li	a4,1
    80005f22:	00e78c23          	sb	a4,24(a5)
    80005f26:	00e78ca3          	sb	a4,25(a5)
    80005f2a:	00e78d23          	sb	a4,26(a5)
    80005f2e:	00e78da3          	sb	a4,27(a5)
    80005f32:	00e78e23          	sb	a4,28(a5)
    80005f36:	00e78ea3          	sb	a4,29(a5)
    80005f3a:	00e78f23          	sb	a4,30(a5)
    80005f3e:	00e78fa3          	sb	a4,31(a5)
}
    80005f42:	60e2                	ld	ra,24(sp)
    80005f44:	6442                	ld	s0,16(sp)
    80005f46:	64a2                	ld	s1,8(sp)
    80005f48:	6105                	addi	sp,sp,32
    80005f4a:	8082                	ret
    panic("could not find virtio disk");
    80005f4c:	00003517          	auipc	a0,0x3
    80005f50:	91450513          	addi	a0,a0,-1772 # 80008860 <syscalls+0x378>
    80005f54:	ffffa097          	auipc	ra,0xffffa
    80005f58:	5f4080e7          	jalr	1524(ra) # 80000548 <panic>
    panic("virtio disk has no queue 0");
    80005f5c:	00003517          	auipc	a0,0x3
    80005f60:	92450513          	addi	a0,a0,-1756 # 80008880 <syscalls+0x398>
    80005f64:	ffffa097          	auipc	ra,0xffffa
    80005f68:	5e4080e7          	jalr	1508(ra) # 80000548 <panic>
    panic("virtio disk max queue too short");
    80005f6c:	00003517          	auipc	a0,0x3
    80005f70:	93450513          	addi	a0,a0,-1740 # 800088a0 <syscalls+0x3b8>
    80005f74:	ffffa097          	auipc	ra,0xffffa
    80005f78:	5d4080e7          	jalr	1492(ra) # 80000548 <panic>

0000000080005f7c <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005f7c:	7119                	addi	sp,sp,-128
    80005f7e:	fc86                	sd	ra,120(sp)
    80005f80:	f8a2                	sd	s0,112(sp)
    80005f82:	f4a6                	sd	s1,104(sp)
    80005f84:	f0ca                	sd	s2,96(sp)
    80005f86:	ecce                	sd	s3,88(sp)
    80005f88:	e8d2                	sd	s4,80(sp)
    80005f8a:	e4d6                	sd	s5,72(sp)
    80005f8c:	e0da                	sd	s6,64(sp)
    80005f8e:	fc5e                	sd	s7,56(sp)
    80005f90:	f862                	sd	s8,48(sp)
    80005f92:	f466                	sd	s9,40(sp)
    80005f94:	f06a                	sd	s10,32(sp)
    80005f96:	0100                	addi	s0,sp,128
    80005f98:	892a                	mv	s2,a0
    80005f9a:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005f9c:	00c52c83          	lw	s9,12(a0)
    80005fa0:	001c9c9b          	slliw	s9,s9,0x1
    80005fa4:	1c82                	slli	s9,s9,0x20
    80005fa6:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005faa:	0001f517          	auipc	a0,0x1f
    80005fae:	0fe50513          	addi	a0,a0,254 # 800250a8 <disk+0x20a8>
    80005fb2:	ffffb097          	auipc	ra,0xffffb
    80005fb6:	cb0080e7          	jalr	-848(ra) # 80000c62 <acquire>
  for(int i = 0; i < 3; i++){
    80005fba:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005fbc:	4c21                	li	s8,8
      disk.free[i] = 0;
    80005fbe:	0001db97          	auipc	s7,0x1d
    80005fc2:	042b8b93          	addi	s7,s7,66 # 80023000 <disk>
    80005fc6:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    80005fc8:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80005fca:	8a4e                	mv	s4,s3
    80005fcc:	a051                	j	80006050 <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    80005fce:	00fb86b3          	add	a3,s7,a5
    80005fd2:	96da                	add	a3,a3,s6
    80005fd4:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80005fd8:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80005fda:	0207c563          	bltz	a5,80006004 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80005fde:	2485                	addiw	s1,s1,1
    80005fe0:	0711                	addi	a4,a4,4
    80005fe2:	23548d63          	beq	s1,s5,8000621c <virtio_disk_rw+0x2a0>
    idx[i] = alloc_desc();
    80005fe6:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80005fe8:	0001f697          	auipc	a3,0x1f
    80005fec:	03068693          	addi	a3,a3,48 # 80025018 <disk+0x2018>
    80005ff0:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80005ff2:	0006c583          	lbu	a1,0(a3)
    80005ff6:	fde1                	bnez	a1,80005fce <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80005ff8:	2785                	addiw	a5,a5,1
    80005ffa:	0685                	addi	a3,a3,1
    80005ffc:	ff879be3          	bne	a5,s8,80005ff2 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006000:	57fd                	li	a5,-1
    80006002:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80006004:	02905a63          	blez	s1,80006038 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80006008:	f9042503          	lw	a0,-112(s0)
    8000600c:	00000097          	auipc	ra,0x0
    80006010:	daa080e7          	jalr	-598(ra) # 80005db6 <free_desc>
      for(int j = 0; j < i; j++)
    80006014:	4785                	li	a5,1
    80006016:	0297d163          	bge	a5,s1,80006038 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    8000601a:	f9442503          	lw	a0,-108(s0)
    8000601e:	00000097          	auipc	ra,0x0
    80006022:	d98080e7          	jalr	-616(ra) # 80005db6 <free_desc>
      for(int j = 0; j < i; j++)
    80006026:	4789                	li	a5,2
    80006028:	0097d863          	bge	a5,s1,80006038 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    8000602c:	f9842503          	lw	a0,-104(s0)
    80006030:	00000097          	auipc	ra,0x0
    80006034:	d86080e7          	jalr	-634(ra) # 80005db6 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006038:	0001f597          	auipc	a1,0x1f
    8000603c:	07058593          	addi	a1,a1,112 # 800250a8 <disk+0x20a8>
    80006040:	0001f517          	auipc	a0,0x1f
    80006044:	fd850513          	addi	a0,a0,-40 # 80025018 <disk+0x2018>
    80006048:	ffffc097          	auipc	ra,0xffffc
    8000604c:	200080e7          	jalr	512(ra) # 80002248 <sleep>
  for(int i = 0; i < 3; i++){
    80006050:	f9040713          	addi	a4,s0,-112
    80006054:	84ce                	mv	s1,s3
    80006056:	bf41                	j	80005fe6 <virtio_disk_rw+0x6a>
    uint32 reserved;
    uint64 sector;
  } buf0;

  if(write)
    buf0.type = VIRTIO_BLK_T_OUT; // write the disk
    80006058:	4785                	li	a5,1
    8000605a:	f8f42023          	sw	a5,-128(s0)
  else
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
  buf0.reserved = 0;
    8000605e:	f8042223          	sw	zero,-124(s0)
  buf0.sector = sector;
    80006062:	f9943423          	sd	s9,-120(s0)

  // buf0 is on a kernel stack, which is not direct mapped,
  // thus the call to kvmpa().
  disk.desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    80006066:	f9042983          	lw	s3,-112(s0)
    8000606a:	00499493          	slli	s1,s3,0x4
    8000606e:	0001fa17          	auipc	s4,0x1f
    80006072:	f92a0a13          	addi	s4,s4,-110 # 80025000 <disk+0x2000>
    80006076:	000a3a83          	ld	s5,0(s4)
    8000607a:	9aa6                	add	s5,s5,s1
    8000607c:	f8040513          	addi	a0,s0,-128
    80006080:	ffffb097          	auipc	ra,0xffffb
    80006084:	0b2080e7          	jalr	178(ra) # 80001132 <kvmpa>
    80006088:	00aab023          	sd	a0,0(s5)
  disk.desc[idx[0]].len = sizeof(buf0);
    8000608c:	000a3783          	ld	a5,0(s4)
    80006090:	97a6                	add	a5,a5,s1
    80006092:	4741                	li	a4,16
    80006094:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006096:	000a3783          	ld	a5,0(s4)
    8000609a:	97a6                	add	a5,a5,s1
    8000609c:	4705                	li	a4,1
    8000609e:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    800060a2:	f9442703          	lw	a4,-108(s0)
    800060a6:	000a3783          	ld	a5,0(s4)
    800060aa:	97a6                	add	a5,a5,s1
    800060ac:	00e79723          	sh	a4,14(a5)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800060b0:	0712                	slli	a4,a4,0x4
    800060b2:	000a3783          	ld	a5,0(s4)
    800060b6:	97ba                	add	a5,a5,a4
    800060b8:	05890693          	addi	a3,s2,88
    800060bc:	e394                	sd	a3,0(a5)
  disk.desc[idx[1]].len = BSIZE;
    800060be:	000a3783          	ld	a5,0(s4)
    800060c2:	97ba                	add	a5,a5,a4
    800060c4:	40000693          	li	a3,1024
    800060c8:	c794                	sw	a3,8(a5)
  if(write)
    800060ca:	100d0a63          	beqz	s10,800061de <virtio_disk_rw+0x262>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800060ce:	0001f797          	auipc	a5,0x1f
    800060d2:	f327b783          	ld	a5,-206(a5) # 80025000 <disk+0x2000>
    800060d6:	97ba                	add	a5,a5,a4
    800060d8:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800060dc:	0001d517          	auipc	a0,0x1d
    800060e0:	f2450513          	addi	a0,a0,-220 # 80023000 <disk>
    800060e4:	0001f797          	auipc	a5,0x1f
    800060e8:	f1c78793          	addi	a5,a5,-228 # 80025000 <disk+0x2000>
    800060ec:	6394                	ld	a3,0(a5)
    800060ee:	96ba                	add	a3,a3,a4
    800060f0:	00c6d603          	lhu	a2,12(a3)
    800060f4:	00166613          	ori	a2,a2,1
    800060f8:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800060fc:	f9842683          	lw	a3,-104(s0)
    80006100:	6390                	ld	a2,0(a5)
    80006102:	9732                	add	a4,a4,a2
    80006104:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0;
    80006108:	20098613          	addi	a2,s3,512
    8000610c:	0612                	slli	a2,a2,0x4
    8000610e:	962a                	add	a2,a2,a0
    80006110:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006114:	00469713          	slli	a4,a3,0x4
    80006118:	6394                	ld	a3,0(a5)
    8000611a:	96ba                	add	a3,a3,a4
    8000611c:	6589                	lui	a1,0x2
    8000611e:	03058593          	addi	a1,a1,48 # 2030 <_entry-0x7fffdfd0>
    80006122:	94ae                	add	s1,s1,a1
    80006124:	94aa                	add	s1,s1,a0
    80006126:	e284                	sd	s1,0(a3)
  disk.desc[idx[2]].len = 1;
    80006128:	6394                	ld	a3,0(a5)
    8000612a:	96ba                	add	a3,a3,a4
    8000612c:	4585                	li	a1,1
    8000612e:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006130:	6394                	ld	a3,0(a5)
    80006132:	96ba                	add	a3,a3,a4
    80006134:	4509                	li	a0,2
    80006136:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    8000613a:	6394                	ld	a3,0(a5)
    8000613c:	9736                	add	a4,a4,a3
    8000613e:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006142:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    80006146:	03263423          	sd	s2,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    8000614a:	6794                	ld	a3,8(a5)
    8000614c:	0026d703          	lhu	a4,2(a3)
    80006150:	8b1d                	andi	a4,a4,7
    80006152:	2709                	addiw	a4,a4,2
    80006154:	0706                	slli	a4,a4,0x1
    80006156:	9736                	add	a4,a4,a3
    80006158:	01371023          	sh	s3,0(a4)
  __sync_synchronize();
    8000615c:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    80006160:	6798                	ld	a4,8(a5)
    80006162:	00275783          	lhu	a5,2(a4)
    80006166:	2785                	addiw	a5,a5,1
    80006168:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000616c:	100017b7          	lui	a5,0x10001
    80006170:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006174:	00492703          	lw	a4,4(s2)
    80006178:	4785                	li	a5,1
    8000617a:	02f71163          	bne	a4,a5,8000619c <virtio_disk_rw+0x220>
    sleep(b, &disk.vdisk_lock);
    8000617e:	0001f997          	auipc	s3,0x1f
    80006182:	f2a98993          	addi	s3,s3,-214 # 800250a8 <disk+0x20a8>
  while(b->disk == 1) {
    80006186:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006188:	85ce                	mv	a1,s3
    8000618a:	854a                	mv	a0,s2
    8000618c:	ffffc097          	auipc	ra,0xffffc
    80006190:	0bc080e7          	jalr	188(ra) # 80002248 <sleep>
  while(b->disk == 1) {
    80006194:	00492783          	lw	a5,4(s2)
    80006198:	fe9788e3          	beq	a5,s1,80006188 <virtio_disk_rw+0x20c>
  }

  disk.info[idx[0]].b = 0;
    8000619c:	f9042483          	lw	s1,-112(s0)
    800061a0:	20048793          	addi	a5,s1,512 # 10001200 <_entry-0x6fffee00>
    800061a4:	00479713          	slli	a4,a5,0x4
    800061a8:	0001d797          	auipc	a5,0x1d
    800061ac:	e5878793          	addi	a5,a5,-424 # 80023000 <disk>
    800061b0:	97ba                	add	a5,a5,a4
    800061b2:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    800061b6:	0001f917          	auipc	s2,0x1f
    800061ba:	e4a90913          	addi	s2,s2,-438 # 80025000 <disk+0x2000>
    free_desc(i);
    800061be:	8526                	mv	a0,s1
    800061c0:	00000097          	auipc	ra,0x0
    800061c4:	bf6080e7          	jalr	-1034(ra) # 80005db6 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    800061c8:	0492                	slli	s1,s1,0x4
    800061ca:	00093783          	ld	a5,0(s2)
    800061ce:	94be                	add	s1,s1,a5
    800061d0:	00c4d783          	lhu	a5,12(s1)
    800061d4:	8b85                	andi	a5,a5,1
    800061d6:	cf89                	beqz	a5,800061f0 <virtio_disk_rw+0x274>
      i = disk.desc[i].next;
    800061d8:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    800061dc:	b7cd                	j	800061be <virtio_disk_rw+0x242>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800061de:	0001f797          	auipc	a5,0x1f
    800061e2:	e227b783          	ld	a5,-478(a5) # 80025000 <disk+0x2000>
    800061e6:	97ba                	add	a5,a5,a4
    800061e8:	4689                	li	a3,2
    800061ea:	00d79623          	sh	a3,12(a5)
    800061ee:	b5fd                	j	800060dc <virtio_disk_rw+0x160>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800061f0:	0001f517          	auipc	a0,0x1f
    800061f4:	eb850513          	addi	a0,a0,-328 # 800250a8 <disk+0x20a8>
    800061f8:	ffffb097          	auipc	ra,0xffffb
    800061fc:	b1e080e7          	jalr	-1250(ra) # 80000d16 <release>
}
    80006200:	70e6                	ld	ra,120(sp)
    80006202:	7446                	ld	s0,112(sp)
    80006204:	74a6                	ld	s1,104(sp)
    80006206:	7906                	ld	s2,96(sp)
    80006208:	69e6                	ld	s3,88(sp)
    8000620a:	6a46                	ld	s4,80(sp)
    8000620c:	6aa6                	ld	s5,72(sp)
    8000620e:	6b06                	ld	s6,64(sp)
    80006210:	7be2                	ld	s7,56(sp)
    80006212:	7c42                	ld	s8,48(sp)
    80006214:	7ca2                	ld	s9,40(sp)
    80006216:	7d02                	ld	s10,32(sp)
    80006218:	6109                	addi	sp,sp,128
    8000621a:	8082                	ret
  if(write)
    8000621c:	e20d1ee3          	bnez	s10,80006058 <virtio_disk_rw+0xdc>
    buf0.type = VIRTIO_BLK_T_IN; // read the disk
    80006220:	f8042023          	sw	zero,-128(s0)
    80006224:	bd2d                	j	8000605e <virtio_disk_rw+0xe2>

0000000080006226 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006226:	1101                	addi	sp,sp,-32
    80006228:	ec06                	sd	ra,24(sp)
    8000622a:	e822                	sd	s0,16(sp)
    8000622c:	e426                	sd	s1,8(sp)
    8000622e:	e04a                	sd	s2,0(sp)
    80006230:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006232:	0001f517          	auipc	a0,0x1f
    80006236:	e7650513          	addi	a0,a0,-394 # 800250a8 <disk+0x20a8>
    8000623a:	ffffb097          	auipc	ra,0xffffb
    8000623e:	a28080e7          	jalr	-1496(ra) # 80000c62 <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006242:	0001f717          	auipc	a4,0x1f
    80006246:	dbe70713          	addi	a4,a4,-578 # 80025000 <disk+0x2000>
    8000624a:	02075783          	lhu	a5,32(a4)
    8000624e:	6b18                	ld	a4,16(a4)
    80006250:	00275683          	lhu	a3,2(a4)
    80006254:	8ebd                	xor	a3,a3,a5
    80006256:	8a9d                	andi	a3,a3,7
    80006258:	cab9                	beqz	a3,800062ae <virtio_disk_intr+0x88>
    int id = disk.used->elems[disk.used_idx].id;

    if(disk.info[id].status != 0)
    8000625a:	0001d917          	auipc	s2,0x1d
    8000625e:	da690913          	addi	s2,s2,-602 # 80023000 <disk>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006262:	0001f497          	auipc	s1,0x1f
    80006266:	d9e48493          	addi	s1,s1,-610 # 80025000 <disk+0x2000>
    int id = disk.used->elems[disk.used_idx].id;
    8000626a:	078e                	slli	a5,a5,0x3
    8000626c:	97ba                	add	a5,a5,a4
    8000626e:	43dc                	lw	a5,4(a5)
    if(disk.info[id].status != 0)
    80006270:	20078713          	addi	a4,a5,512
    80006274:	0712                	slli	a4,a4,0x4
    80006276:	974a                	add	a4,a4,s2
    80006278:	03074703          	lbu	a4,48(a4)
    8000627c:	ef21                	bnez	a4,800062d4 <virtio_disk_intr+0xae>
    disk.info[id].b->disk = 0;   // disk is done with buf
    8000627e:	20078793          	addi	a5,a5,512
    80006282:	0792                	slli	a5,a5,0x4
    80006284:	97ca                	add	a5,a5,s2
    80006286:	7798                	ld	a4,40(a5)
    80006288:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    8000628c:	7788                	ld	a0,40(a5)
    8000628e:	ffffc097          	auipc	ra,0xffffc
    80006292:	140080e7          	jalr	320(ra) # 800023ce <wakeup>
    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006296:	0204d783          	lhu	a5,32(s1)
    8000629a:	2785                	addiw	a5,a5,1
    8000629c:	8b9d                	andi	a5,a5,7
    8000629e:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    800062a2:	6898                	ld	a4,16(s1)
    800062a4:	00275683          	lhu	a3,2(a4)
    800062a8:	8a9d                	andi	a3,a3,7
    800062aa:	fcf690e3          	bne	a3,a5,8000626a <virtio_disk_intr+0x44>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800062ae:	10001737          	lui	a4,0x10001
    800062b2:	533c                	lw	a5,96(a4)
    800062b4:	8b8d                	andi	a5,a5,3
    800062b6:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    800062b8:	0001f517          	auipc	a0,0x1f
    800062bc:	df050513          	addi	a0,a0,-528 # 800250a8 <disk+0x20a8>
    800062c0:	ffffb097          	auipc	ra,0xffffb
    800062c4:	a56080e7          	jalr	-1450(ra) # 80000d16 <release>
}
    800062c8:	60e2                	ld	ra,24(sp)
    800062ca:	6442                	ld	s0,16(sp)
    800062cc:	64a2                	ld	s1,8(sp)
    800062ce:	6902                	ld	s2,0(sp)
    800062d0:	6105                	addi	sp,sp,32
    800062d2:	8082                	ret
      panic("virtio_disk_intr status");
    800062d4:	00002517          	auipc	a0,0x2
    800062d8:	5ec50513          	addi	a0,a0,1516 # 800088c0 <syscalls+0x3d8>
    800062dc:	ffffa097          	auipc	ra,0xffffa
    800062e0:	26c080e7          	jalr	620(ra) # 80000548 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
