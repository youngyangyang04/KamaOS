
user/_sysinfotest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <sinfo>:
#include "kernel/sysinfo.h"
#include "user/user.h"


void
sinfo(struct sysinfo *info) {
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  if (sysinfo(info) < 0) {
   8:	00000097          	auipc	ra,0x0
   c:	656080e7          	jalr	1622(ra) # 65e <sysinfo>
  10:	00054663          	bltz	a0,1c <sinfo+0x1c>
    printf("FAIL: sysinfo failed");
    exit(1);
  }
}
  14:	60a2                	ld	ra,8(sp)
  16:	6402                	ld	s0,0(sp)
  18:	0141                	addi	sp,sp,16
  1a:	8082                	ret
    printf("FAIL: sysinfo failed");
  1c:	00001517          	auipc	a0,0x1
  20:	ac450513          	addi	a0,a0,-1340 # ae0 <malloc+0xe4>
  24:	00001097          	auipc	ra,0x1
  28:	91a080e7          	jalr	-1766(ra) # 93e <printf>
    exit(1);
  2c:	4505                	li	a0,1
  2e:	00000097          	auipc	ra,0x0
  32:	588080e7          	jalr	1416(ra) # 5b6 <exit>

0000000000000036 <countfree>:
//
// use sbrk() to count how many free physical memory pages there are.
//
int
countfree()
{
  36:	7139                	addi	sp,sp,-64
  38:	fc06                	sd	ra,56(sp)
  3a:	f822                	sd	s0,48(sp)
  3c:	f426                	sd	s1,40(sp)
  3e:	f04a                	sd	s2,32(sp)
  40:	ec4e                	sd	s3,24(sp)
  42:	e852                	sd	s4,16(sp)
  44:	0080                	addi	s0,sp,64
  uint64 sz0 = (uint64)sbrk(0);
  46:	4501                	li	a0,0
  48:	00000097          	auipc	ra,0x0
  4c:	5f6080e7          	jalr	1526(ra) # 63e <sbrk>
  50:	8a2a                	mv	s4,a0
  struct sysinfo info;
  int n = 0;
  52:	4481                	li	s1,0

  while(1){
    if((uint64)sbrk(PGSIZE) == 0xffffffffffffffff){
  54:	597d                	li	s2,-1
      break;
    }
    n += PGSIZE;
  56:	6985                	lui	s3,0x1
    if((uint64)sbrk(PGSIZE) == 0xffffffffffffffff){
  58:	6505                	lui	a0,0x1
  5a:	00000097          	auipc	ra,0x0
  5e:	5e4080e7          	jalr	1508(ra) # 63e <sbrk>
  62:	01250563          	beq	a0,s2,6c <countfree+0x36>
    n += PGSIZE;
  66:	009984bb          	addw	s1,s3,s1
    if((uint64)sbrk(PGSIZE) == 0xffffffffffffffff){
  6a:	b7fd                	j	58 <countfree+0x22>
  }
  sinfo(&info);
  6c:	fc040513          	addi	a0,s0,-64
  70:	00000097          	auipc	ra,0x0
  74:	f90080e7          	jalr	-112(ra) # 0 <sinfo>
  if (info.freemem != 0) {
  78:	fc043583          	ld	a1,-64(s0)
  7c:	e58d                	bnez	a1,a6 <countfree+0x70>
    printf("FAIL: there is no free mem, but sysinfo.freemem=%d\n",
      info.freemem);
    exit(1);
  }
  sbrk(-((uint64)sbrk(0) - sz0));
  7e:	4501                	li	a0,0
  80:	00000097          	auipc	ra,0x0
  84:	5be080e7          	jalr	1470(ra) # 63e <sbrk>
  88:	40aa053b          	subw	a0,s4,a0
  8c:	00000097          	auipc	ra,0x0
  90:	5b2080e7          	jalr	1458(ra) # 63e <sbrk>
  return n;
}
  94:	8526                	mv	a0,s1
  96:	70e2                	ld	ra,56(sp)
  98:	7442                	ld	s0,48(sp)
  9a:	74a2                	ld	s1,40(sp)
  9c:	7902                	ld	s2,32(sp)
  9e:	69e2                	ld	s3,24(sp)
  a0:	6a42                	ld	s4,16(sp)
  a2:	6121                	addi	sp,sp,64
  a4:	8082                	ret
    printf("FAIL: there is no free mem, but sysinfo.freemem=%d\n",
  a6:	00001517          	auipc	a0,0x1
  aa:	a5250513          	addi	a0,a0,-1454 # af8 <malloc+0xfc>
  ae:	00001097          	auipc	ra,0x1
  b2:	890080e7          	jalr	-1904(ra) # 93e <printf>
    exit(1);
  b6:	4505                	li	a0,1
  b8:	00000097          	auipc	ra,0x0
  bc:	4fe080e7          	jalr	1278(ra) # 5b6 <exit>

00000000000000c0 <testmem>:

void
testmem() {
  c0:	7179                	addi	sp,sp,-48
  c2:	f406                	sd	ra,40(sp)
  c4:	f022                	sd	s0,32(sp)
  c6:	ec26                	sd	s1,24(sp)
  c8:	e84a                	sd	s2,16(sp)
  ca:	1800                	addi	s0,sp,48
  struct sysinfo info;
  uint64 n = countfree();
  cc:	00000097          	auipc	ra,0x0
  d0:	f6a080e7          	jalr	-150(ra) # 36 <countfree>
  d4:	84aa                	mv	s1,a0
  
  sinfo(&info);
  d6:	fd040513          	addi	a0,s0,-48
  da:	00000097          	auipc	ra,0x0
  de:	f26080e7          	jalr	-218(ra) # 0 <sinfo>

  if (info.freemem!= n) {
  e2:	fd043583          	ld	a1,-48(s0)
  e6:	04959e63          	bne	a1,s1,142 <testmem+0x82>
    printf("FAIL: free mem %d (bytes) instead of %d\n", info.freemem, n);
    exit(1);
  }
  
  if((uint64)sbrk(PGSIZE) == 0xffffffffffffffff){
  ea:	6505                	lui	a0,0x1
  ec:	00000097          	auipc	ra,0x0
  f0:	552080e7          	jalr	1362(ra) # 63e <sbrk>
  f4:	57fd                	li	a5,-1
  f6:	06f50463          	beq	a0,a5,15e <testmem+0x9e>
    printf("sbrk failed");
    exit(1);
  }

  sinfo(&info);
  fa:	fd040513          	addi	a0,s0,-48
  fe:	00000097          	auipc	ra,0x0
 102:	f02080e7          	jalr	-254(ra) # 0 <sinfo>
    
  if (info.freemem != n-PGSIZE) {
 106:	fd043603          	ld	a2,-48(s0)
 10a:	75fd                	lui	a1,0xfffff
 10c:	95a6                	add	a1,a1,s1
 10e:	06b61563          	bne	a2,a1,178 <testmem+0xb8>
    printf("FAIL: free mem %d (bytes) instead of %d\n", n-PGSIZE, info.freemem);
    exit(1);
  }
  
  if((uint64)sbrk(-PGSIZE) == 0xffffffffffffffff){
 112:	757d                	lui	a0,0xfffff
 114:	00000097          	auipc	ra,0x0
 118:	52a080e7          	jalr	1322(ra) # 63e <sbrk>
 11c:	57fd                	li	a5,-1
 11e:	06f50a63          	beq	a0,a5,192 <testmem+0xd2>
    printf("sbrk failed");
    exit(1);
  }

  sinfo(&info);
 122:	fd040513          	addi	a0,s0,-48
 126:	00000097          	auipc	ra,0x0
 12a:	eda080e7          	jalr	-294(ra) # 0 <sinfo>
    
  if (info.freemem != n) {
 12e:	fd043603          	ld	a2,-48(s0)
 132:	06961d63          	bne	a2,s1,1ac <testmem+0xec>
    printf("FAIL: free mem %d (bytes) instead of %d\n", n, info.freemem);
    exit(1);
  }
}
 136:	70a2                	ld	ra,40(sp)
 138:	7402                	ld	s0,32(sp)
 13a:	64e2                	ld	s1,24(sp)
 13c:	6942                	ld	s2,16(sp)
 13e:	6145                	addi	sp,sp,48
 140:	8082                	ret
    printf("FAIL: free mem %d (bytes) instead of %d\n", info.freemem, n);
 142:	8626                	mv	a2,s1
 144:	00001517          	auipc	a0,0x1
 148:	9ec50513          	addi	a0,a0,-1556 # b30 <malloc+0x134>
 14c:	00000097          	auipc	ra,0x0
 150:	7f2080e7          	jalr	2034(ra) # 93e <printf>
    exit(1);
 154:	4505                	li	a0,1
 156:	00000097          	auipc	ra,0x0
 15a:	460080e7          	jalr	1120(ra) # 5b6 <exit>
    printf("sbrk failed");
 15e:	00001517          	auipc	a0,0x1
 162:	a0250513          	addi	a0,a0,-1534 # b60 <malloc+0x164>
 166:	00000097          	auipc	ra,0x0
 16a:	7d8080e7          	jalr	2008(ra) # 93e <printf>
    exit(1);
 16e:	4505                	li	a0,1
 170:	00000097          	auipc	ra,0x0
 174:	446080e7          	jalr	1094(ra) # 5b6 <exit>
    printf("FAIL: free mem %d (bytes) instead of %d\n", n-PGSIZE, info.freemem);
 178:	00001517          	auipc	a0,0x1
 17c:	9b850513          	addi	a0,a0,-1608 # b30 <malloc+0x134>
 180:	00000097          	auipc	ra,0x0
 184:	7be080e7          	jalr	1982(ra) # 93e <printf>
    exit(1);
 188:	4505                	li	a0,1
 18a:	00000097          	auipc	ra,0x0
 18e:	42c080e7          	jalr	1068(ra) # 5b6 <exit>
    printf("sbrk failed");
 192:	00001517          	auipc	a0,0x1
 196:	9ce50513          	addi	a0,a0,-1586 # b60 <malloc+0x164>
 19a:	00000097          	auipc	ra,0x0
 19e:	7a4080e7          	jalr	1956(ra) # 93e <printf>
    exit(1);
 1a2:	4505                	li	a0,1
 1a4:	00000097          	auipc	ra,0x0
 1a8:	412080e7          	jalr	1042(ra) # 5b6 <exit>
    printf("FAIL: free mem %d (bytes) instead of %d\n", n, info.freemem);
 1ac:	85a6                	mv	a1,s1
 1ae:	00001517          	auipc	a0,0x1
 1b2:	98250513          	addi	a0,a0,-1662 # b30 <malloc+0x134>
 1b6:	00000097          	auipc	ra,0x0
 1ba:	788080e7          	jalr	1928(ra) # 93e <printf>
    exit(1);
 1be:	4505                	li	a0,1
 1c0:	00000097          	auipc	ra,0x0
 1c4:	3f6080e7          	jalr	1014(ra) # 5b6 <exit>

00000000000001c8 <testcall>:

void
testcall() {
 1c8:	1101                	addi	sp,sp,-32
 1ca:	ec06                	sd	ra,24(sp)
 1cc:	e822                	sd	s0,16(sp)
 1ce:	1000                	addi	s0,sp,32
  struct sysinfo info;
  
  if (sysinfo(&info) < 0) {
 1d0:	fe040513          	addi	a0,s0,-32
 1d4:	00000097          	auipc	ra,0x0
 1d8:	48a080e7          	jalr	1162(ra) # 65e <sysinfo>
 1dc:	02054163          	bltz	a0,1fe <testcall+0x36>
    printf("FAIL: sysinfo failed\n");
    exit(1);
  }

  if (sysinfo((struct sysinfo *) 0xeaeb0b5b00002f5e) !=  0xffffffffffffffff) {
 1e0:	00001517          	auipc	a0,0x1
 1e4:	a7853503          	ld	a0,-1416(a0) # c58 <__SDATA_BEGIN__>
 1e8:	00000097          	auipc	ra,0x0
 1ec:	476080e7          	jalr	1142(ra) # 65e <sysinfo>
 1f0:	57fd                	li	a5,-1
 1f2:	02f51363          	bne	a0,a5,218 <testcall+0x50>
    printf("FAIL: sysinfo succeeded with bad argument\n");
    exit(1);
  }
}
 1f6:	60e2                	ld	ra,24(sp)
 1f8:	6442                	ld	s0,16(sp)
 1fa:	6105                	addi	sp,sp,32
 1fc:	8082                	ret
    printf("FAIL: sysinfo failed\n");
 1fe:	00001517          	auipc	a0,0x1
 202:	97250513          	addi	a0,a0,-1678 # b70 <malloc+0x174>
 206:	00000097          	auipc	ra,0x0
 20a:	738080e7          	jalr	1848(ra) # 93e <printf>
    exit(1);
 20e:	4505                	li	a0,1
 210:	00000097          	auipc	ra,0x0
 214:	3a6080e7          	jalr	934(ra) # 5b6 <exit>
    printf("FAIL: sysinfo succeeded with bad argument\n");
 218:	00001517          	auipc	a0,0x1
 21c:	97050513          	addi	a0,a0,-1680 # b88 <malloc+0x18c>
 220:	00000097          	auipc	ra,0x0
 224:	71e080e7          	jalr	1822(ra) # 93e <printf>
    exit(1);
 228:	4505                	li	a0,1
 22a:	00000097          	auipc	ra,0x0
 22e:	38c080e7          	jalr	908(ra) # 5b6 <exit>

0000000000000232 <testproc>:

void testproc() {
 232:	7139                	addi	sp,sp,-64
 234:	fc06                	sd	ra,56(sp)
 236:	f822                	sd	s0,48(sp)
 238:	f426                	sd	s1,40(sp)
 23a:	0080                	addi	s0,sp,64
  struct sysinfo info;
  uint64 nproc;
  int status;
  int pid;
  
  sinfo(&info);
 23c:	fd040513          	addi	a0,s0,-48
 240:	00000097          	auipc	ra,0x0
 244:	dc0080e7          	jalr	-576(ra) # 0 <sinfo>
  nproc = info.nproc;
 248:	fd843483          	ld	s1,-40(s0)

  pid = fork();
 24c:	00000097          	auipc	ra,0x0
 250:	362080e7          	jalr	866(ra) # 5ae <fork>
  if(pid < 0){
 254:	02054c63          	bltz	a0,28c <testproc+0x5a>
    printf("sysinfotest: fork failed\n");
    exit(1);
  }
  if(pid == 0){
 258:	ed21                	bnez	a0,2b0 <testproc+0x7e>
    sinfo(&info);
 25a:	fd040513          	addi	a0,s0,-48
 25e:	00000097          	auipc	ra,0x0
 262:	da2080e7          	jalr	-606(ra) # 0 <sinfo>
    if(info.nproc != nproc+1) {
 266:	fd843583          	ld	a1,-40(s0)
 26a:	00148613          	addi	a2,s1,1
 26e:	02c58c63          	beq	a1,a2,2a6 <testproc+0x74>
      printf("sysinfotest: FAIL nproc is %d instead of %d\n", info.nproc, nproc+1);
 272:	00001517          	auipc	a0,0x1
 276:	96650513          	addi	a0,a0,-1690 # bd8 <malloc+0x1dc>
 27a:	00000097          	auipc	ra,0x0
 27e:	6c4080e7          	jalr	1732(ra) # 93e <printf>
      exit(1);
 282:	4505                	li	a0,1
 284:	00000097          	auipc	ra,0x0
 288:	332080e7          	jalr	818(ra) # 5b6 <exit>
    printf("sysinfotest: fork failed\n");
 28c:	00001517          	auipc	a0,0x1
 290:	92c50513          	addi	a0,a0,-1748 # bb8 <malloc+0x1bc>
 294:	00000097          	auipc	ra,0x0
 298:	6aa080e7          	jalr	1706(ra) # 93e <printf>
    exit(1);
 29c:	4505                	li	a0,1
 29e:	00000097          	auipc	ra,0x0
 2a2:	318080e7          	jalr	792(ra) # 5b6 <exit>
    }
    exit(0);
 2a6:	4501                	li	a0,0
 2a8:	00000097          	auipc	ra,0x0
 2ac:	30e080e7          	jalr	782(ra) # 5b6 <exit>
  }
  wait(&status);
 2b0:	fcc40513          	addi	a0,s0,-52
 2b4:	00000097          	auipc	ra,0x0
 2b8:	30a080e7          	jalr	778(ra) # 5be <wait>
  sinfo(&info);
 2bc:	fd040513          	addi	a0,s0,-48
 2c0:	00000097          	auipc	ra,0x0
 2c4:	d40080e7          	jalr	-704(ra) # 0 <sinfo>
  if(info.nproc != nproc) {
 2c8:	fd843583          	ld	a1,-40(s0)
 2cc:	00959763          	bne	a1,s1,2da <testproc+0xa8>
      printf("sysinfotest: FAIL nproc is %d instead of %d\n", info.nproc, nproc);
      exit(1);
  }
}
 2d0:	70e2                	ld	ra,56(sp)
 2d2:	7442                	ld	s0,48(sp)
 2d4:	74a2                	ld	s1,40(sp)
 2d6:	6121                	addi	sp,sp,64
 2d8:	8082                	ret
      printf("sysinfotest: FAIL nproc is %d instead of %d\n", info.nproc, nproc);
 2da:	8626                	mv	a2,s1
 2dc:	00001517          	auipc	a0,0x1
 2e0:	8fc50513          	addi	a0,a0,-1796 # bd8 <malloc+0x1dc>
 2e4:	00000097          	auipc	ra,0x0
 2e8:	65a080e7          	jalr	1626(ra) # 93e <printf>
      exit(1);
 2ec:	4505                	li	a0,1
 2ee:	00000097          	auipc	ra,0x0
 2f2:	2c8080e7          	jalr	712(ra) # 5b6 <exit>

00000000000002f6 <main>:

int
main(int argc, char *argv[])
{
 2f6:	1141                	addi	sp,sp,-16
 2f8:	e406                	sd	ra,8(sp)
 2fa:	e022                	sd	s0,0(sp)
 2fc:	0800                	addi	s0,sp,16
  printf("sysinfotest: start\n");
 2fe:	00001517          	auipc	a0,0x1
 302:	90a50513          	addi	a0,a0,-1782 # c08 <malloc+0x20c>
 306:	00000097          	auipc	ra,0x0
 30a:	638080e7          	jalr	1592(ra) # 93e <printf>
  testcall();
 30e:	00000097          	auipc	ra,0x0
 312:	eba080e7          	jalr	-326(ra) # 1c8 <testcall>
  testmem();
 316:	00000097          	auipc	ra,0x0
 31a:	daa080e7          	jalr	-598(ra) # c0 <testmem>
  testproc();
 31e:	00000097          	auipc	ra,0x0
 322:	f14080e7          	jalr	-236(ra) # 232 <testproc>
  printf("sysinfotest: OK\n");
 326:	00001517          	auipc	a0,0x1
 32a:	8fa50513          	addi	a0,a0,-1798 # c20 <malloc+0x224>
 32e:	00000097          	auipc	ra,0x0
 332:	610080e7          	jalr	1552(ra) # 93e <printf>
  exit(0);
 336:	4501                	li	a0,0
 338:	00000097          	auipc	ra,0x0
 33c:	27e080e7          	jalr	638(ra) # 5b6 <exit>

0000000000000340 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 340:	1141                	addi	sp,sp,-16
 342:	e422                	sd	s0,8(sp)
 344:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 346:	87aa                	mv	a5,a0
 348:	0585                	addi	a1,a1,1
 34a:	0785                	addi	a5,a5,1
 34c:	fff5c703          	lbu	a4,-1(a1) # ffffffffffffefff <__global_pointer$+0xffffffffffffdbae>
 350:	fee78fa3          	sb	a4,-1(a5)
 354:	fb75                	bnez	a4,348 <strcpy+0x8>
    ;
  return os;
}
 356:	6422                	ld	s0,8(sp)
 358:	0141                	addi	sp,sp,16
 35a:	8082                	ret

000000000000035c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 35c:	1141                	addi	sp,sp,-16
 35e:	e422                	sd	s0,8(sp)
 360:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 362:	00054783          	lbu	a5,0(a0)
 366:	cb91                	beqz	a5,37a <strcmp+0x1e>
 368:	0005c703          	lbu	a4,0(a1)
 36c:	00f71763          	bne	a4,a5,37a <strcmp+0x1e>
    p++, q++;
 370:	0505                	addi	a0,a0,1
 372:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 374:	00054783          	lbu	a5,0(a0)
 378:	fbe5                	bnez	a5,368 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 37a:	0005c503          	lbu	a0,0(a1)
}
 37e:	40a7853b          	subw	a0,a5,a0
 382:	6422                	ld	s0,8(sp)
 384:	0141                	addi	sp,sp,16
 386:	8082                	ret

0000000000000388 <strlen>:

uint
strlen(const char *s)
{
 388:	1141                	addi	sp,sp,-16
 38a:	e422                	sd	s0,8(sp)
 38c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 38e:	00054783          	lbu	a5,0(a0)
 392:	cf91                	beqz	a5,3ae <strlen+0x26>
 394:	0505                	addi	a0,a0,1
 396:	87aa                	mv	a5,a0
 398:	4685                	li	a3,1
 39a:	9e89                	subw	a3,a3,a0
 39c:	00f6853b          	addw	a0,a3,a5
 3a0:	0785                	addi	a5,a5,1
 3a2:	fff7c703          	lbu	a4,-1(a5)
 3a6:	fb7d                	bnez	a4,39c <strlen+0x14>
    ;
  return n;
}
 3a8:	6422                	ld	s0,8(sp)
 3aa:	0141                	addi	sp,sp,16
 3ac:	8082                	ret
  for(n = 0; s[n]; n++)
 3ae:	4501                	li	a0,0
 3b0:	bfe5                	j	3a8 <strlen+0x20>

00000000000003b2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3b2:	1141                	addi	sp,sp,-16
 3b4:	e422                	sd	s0,8(sp)
 3b6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 3b8:	ce09                	beqz	a2,3d2 <memset+0x20>
 3ba:	87aa                	mv	a5,a0
 3bc:	fff6071b          	addiw	a4,a2,-1
 3c0:	1702                	slli	a4,a4,0x20
 3c2:	9301                	srli	a4,a4,0x20
 3c4:	0705                	addi	a4,a4,1
 3c6:	972a                	add	a4,a4,a0
    cdst[i] = c;
 3c8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 3cc:	0785                	addi	a5,a5,1
 3ce:	fee79de3          	bne	a5,a4,3c8 <memset+0x16>
  }
  return dst;
}
 3d2:	6422                	ld	s0,8(sp)
 3d4:	0141                	addi	sp,sp,16
 3d6:	8082                	ret

00000000000003d8 <strchr>:

char*
strchr(const char *s, char c)
{
 3d8:	1141                	addi	sp,sp,-16
 3da:	e422                	sd	s0,8(sp)
 3dc:	0800                	addi	s0,sp,16
  for(; *s; s++)
 3de:	00054783          	lbu	a5,0(a0)
 3e2:	cb99                	beqz	a5,3f8 <strchr+0x20>
    if(*s == c)
 3e4:	00f58763          	beq	a1,a5,3f2 <strchr+0x1a>
  for(; *s; s++)
 3e8:	0505                	addi	a0,a0,1
 3ea:	00054783          	lbu	a5,0(a0)
 3ee:	fbfd                	bnez	a5,3e4 <strchr+0xc>
      return (char*)s;
  return 0;
 3f0:	4501                	li	a0,0
}
 3f2:	6422                	ld	s0,8(sp)
 3f4:	0141                	addi	sp,sp,16
 3f6:	8082                	ret
  return 0;
 3f8:	4501                	li	a0,0
 3fa:	bfe5                	j	3f2 <strchr+0x1a>

00000000000003fc <gets>:

char*
gets(char *buf, int max)
{
 3fc:	711d                	addi	sp,sp,-96
 3fe:	ec86                	sd	ra,88(sp)
 400:	e8a2                	sd	s0,80(sp)
 402:	e4a6                	sd	s1,72(sp)
 404:	e0ca                	sd	s2,64(sp)
 406:	fc4e                	sd	s3,56(sp)
 408:	f852                	sd	s4,48(sp)
 40a:	f456                	sd	s5,40(sp)
 40c:	f05a                	sd	s6,32(sp)
 40e:	ec5e                	sd	s7,24(sp)
 410:	1080                	addi	s0,sp,96
 412:	8baa                	mv	s7,a0
 414:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 416:	892a                	mv	s2,a0
 418:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 41a:	4aa9                	li	s5,10
 41c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 41e:	89a6                	mv	s3,s1
 420:	2485                	addiw	s1,s1,1
 422:	0344d863          	bge	s1,s4,452 <gets+0x56>
    cc = read(0, &c, 1);
 426:	4605                	li	a2,1
 428:	faf40593          	addi	a1,s0,-81
 42c:	4501                	li	a0,0
 42e:	00000097          	auipc	ra,0x0
 432:	1a0080e7          	jalr	416(ra) # 5ce <read>
    if(cc < 1)
 436:	00a05e63          	blez	a0,452 <gets+0x56>
    buf[i++] = c;
 43a:	faf44783          	lbu	a5,-81(s0)
 43e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 442:	01578763          	beq	a5,s5,450 <gets+0x54>
 446:	0905                	addi	s2,s2,1
 448:	fd679be3          	bne	a5,s6,41e <gets+0x22>
  for(i=0; i+1 < max; ){
 44c:	89a6                	mv	s3,s1
 44e:	a011                	j	452 <gets+0x56>
 450:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 452:	99de                	add	s3,s3,s7
 454:	00098023          	sb	zero,0(s3) # 1000 <__BSS_END__+0x388>
  return buf;
}
 458:	855e                	mv	a0,s7
 45a:	60e6                	ld	ra,88(sp)
 45c:	6446                	ld	s0,80(sp)
 45e:	64a6                	ld	s1,72(sp)
 460:	6906                	ld	s2,64(sp)
 462:	79e2                	ld	s3,56(sp)
 464:	7a42                	ld	s4,48(sp)
 466:	7aa2                	ld	s5,40(sp)
 468:	7b02                	ld	s6,32(sp)
 46a:	6be2                	ld	s7,24(sp)
 46c:	6125                	addi	sp,sp,96
 46e:	8082                	ret

0000000000000470 <stat>:

int
stat(const char *n, struct stat *st)
{
 470:	1101                	addi	sp,sp,-32
 472:	ec06                	sd	ra,24(sp)
 474:	e822                	sd	s0,16(sp)
 476:	e426                	sd	s1,8(sp)
 478:	e04a                	sd	s2,0(sp)
 47a:	1000                	addi	s0,sp,32
 47c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 47e:	4581                	li	a1,0
 480:	00000097          	auipc	ra,0x0
 484:	176080e7          	jalr	374(ra) # 5f6 <open>
  if(fd < 0)
 488:	02054563          	bltz	a0,4b2 <stat+0x42>
 48c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 48e:	85ca                	mv	a1,s2
 490:	00000097          	auipc	ra,0x0
 494:	17e080e7          	jalr	382(ra) # 60e <fstat>
 498:	892a                	mv	s2,a0
  close(fd);
 49a:	8526                	mv	a0,s1
 49c:	00000097          	auipc	ra,0x0
 4a0:	142080e7          	jalr	322(ra) # 5de <close>
  return r;
}
 4a4:	854a                	mv	a0,s2
 4a6:	60e2                	ld	ra,24(sp)
 4a8:	6442                	ld	s0,16(sp)
 4aa:	64a2                	ld	s1,8(sp)
 4ac:	6902                	ld	s2,0(sp)
 4ae:	6105                	addi	sp,sp,32
 4b0:	8082                	ret
    return -1;
 4b2:	597d                	li	s2,-1
 4b4:	bfc5                	j	4a4 <stat+0x34>

00000000000004b6 <atoi>:

int
atoi(const char *s)
{
 4b6:	1141                	addi	sp,sp,-16
 4b8:	e422                	sd	s0,8(sp)
 4ba:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 4bc:	00054603          	lbu	a2,0(a0)
 4c0:	fd06079b          	addiw	a5,a2,-48
 4c4:	0ff7f793          	andi	a5,a5,255
 4c8:	4725                	li	a4,9
 4ca:	02f76963          	bltu	a4,a5,4fc <atoi+0x46>
 4ce:	86aa                	mv	a3,a0
  n = 0;
 4d0:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 4d2:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 4d4:	0685                	addi	a3,a3,1
 4d6:	0025179b          	slliw	a5,a0,0x2
 4da:	9fa9                	addw	a5,a5,a0
 4dc:	0017979b          	slliw	a5,a5,0x1
 4e0:	9fb1                	addw	a5,a5,a2
 4e2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 4e6:	0006c603          	lbu	a2,0(a3)
 4ea:	fd06071b          	addiw	a4,a2,-48
 4ee:	0ff77713          	andi	a4,a4,255
 4f2:	fee5f1e3          	bgeu	a1,a4,4d4 <atoi+0x1e>
  return n;
}
 4f6:	6422                	ld	s0,8(sp)
 4f8:	0141                	addi	sp,sp,16
 4fa:	8082                	ret
  n = 0;
 4fc:	4501                	li	a0,0
 4fe:	bfe5                	j	4f6 <atoi+0x40>

0000000000000500 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 500:	1141                	addi	sp,sp,-16
 502:	e422                	sd	s0,8(sp)
 504:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 506:	02b57663          	bgeu	a0,a1,532 <memmove+0x32>
    while(n-- > 0)
 50a:	02c05163          	blez	a2,52c <memmove+0x2c>
 50e:	fff6079b          	addiw	a5,a2,-1
 512:	1782                	slli	a5,a5,0x20
 514:	9381                	srli	a5,a5,0x20
 516:	0785                	addi	a5,a5,1
 518:	97aa                	add	a5,a5,a0
  dst = vdst;
 51a:	872a                	mv	a4,a0
      *dst++ = *src++;
 51c:	0585                	addi	a1,a1,1
 51e:	0705                	addi	a4,a4,1
 520:	fff5c683          	lbu	a3,-1(a1)
 524:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 528:	fee79ae3          	bne	a5,a4,51c <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 52c:	6422                	ld	s0,8(sp)
 52e:	0141                	addi	sp,sp,16
 530:	8082                	ret
    dst += n;
 532:	00c50733          	add	a4,a0,a2
    src += n;
 536:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 538:	fec05ae3          	blez	a2,52c <memmove+0x2c>
 53c:	fff6079b          	addiw	a5,a2,-1
 540:	1782                	slli	a5,a5,0x20
 542:	9381                	srli	a5,a5,0x20
 544:	fff7c793          	not	a5,a5
 548:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 54a:	15fd                	addi	a1,a1,-1
 54c:	177d                	addi	a4,a4,-1
 54e:	0005c683          	lbu	a3,0(a1)
 552:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 556:	fee79ae3          	bne	a5,a4,54a <memmove+0x4a>
 55a:	bfc9                	j	52c <memmove+0x2c>

000000000000055c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 55c:	1141                	addi	sp,sp,-16
 55e:	e422                	sd	s0,8(sp)
 560:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 562:	ca05                	beqz	a2,592 <memcmp+0x36>
 564:	fff6069b          	addiw	a3,a2,-1
 568:	1682                	slli	a3,a3,0x20
 56a:	9281                	srli	a3,a3,0x20
 56c:	0685                	addi	a3,a3,1
 56e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 570:	00054783          	lbu	a5,0(a0)
 574:	0005c703          	lbu	a4,0(a1)
 578:	00e79863          	bne	a5,a4,588 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 57c:	0505                	addi	a0,a0,1
    p2++;
 57e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 580:	fed518e3          	bne	a0,a3,570 <memcmp+0x14>
  }
  return 0;
 584:	4501                	li	a0,0
 586:	a019                	j	58c <memcmp+0x30>
      return *p1 - *p2;
 588:	40e7853b          	subw	a0,a5,a4
}
 58c:	6422                	ld	s0,8(sp)
 58e:	0141                	addi	sp,sp,16
 590:	8082                	ret
  return 0;
 592:	4501                	li	a0,0
 594:	bfe5                	j	58c <memcmp+0x30>

0000000000000596 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 596:	1141                	addi	sp,sp,-16
 598:	e406                	sd	ra,8(sp)
 59a:	e022                	sd	s0,0(sp)
 59c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 59e:	00000097          	auipc	ra,0x0
 5a2:	f62080e7          	jalr	-158(ra) # 500 <memmove>
}
 5a6:	60a2                	ld	ra,8(sp)
 5a8:	6402                	ld	s0,0(sp)
 5aa:	0141                	addi	sp,sp,16
 5ac:	8082                	ret

00000000000005ae <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 5ae:	4885                	li	a7,1
 ecall
 5b0:	00000073          	ecall
 ret
 5b4:	8082                	ret

00000000000005b6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 5b6:	4889                	li	a7,2
 ecall
 5b8:	00000073          	ecall
 ret
 5bc:	8082                	ret

00000000000005be <wait>:
.global wait
wait:
 li a7, SYS_wait
 5be:	488d                	li	a7,3
 ecall
 5c0:	00000073          	ecall
 ret
 5c4:	8082                	ret

00000000000005c6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 5c6:	4891                	li	a7,4
 ecall
 5c8:	00000073          	ecall
 ret
 5cc:	8082                	ret

00000000000005ce <read>:
.global read
read:
 li a7, SYS_read
 5ce:	4895                	li	a7,5
 ecall
 5d0:	00000073          	ecall
 ret
 5d4:	8082                	ret

00000000000005d6 <write>:
.global write
write:
 li a7, SYS_write
 5d6:	48c1                	li	a7,16
 ecall
 5d8:	00000073          	ecall
 ret
 5dc:	8082                	ret

00000000000005de <close>:
.global close
close:
 li a7, SYS_close
 5de:	48d5                	li	a7,21
 ecall
 5e0:	00000073          	ecall
 ret
 5e4:	8082                	ret

00000000000005e6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 5e6:	4899                	li	a7,6
 ecall
 5e8:	00000073          	ecall
 ret
 5ec:	8082                	ret

00000000000005ee <exec>:
.global exec
exec:
 li a7, SYS_exec
 5ee:	489d                	li	a7,7
 ecall
 5f0:	00000073          	ecall
 ret
 5f4:	8082                	ret

00000000000005f6 <open>:
.global open
open:
 li a7, SYS_open
 5f6:	48bd                	li	a7,15
 ecall
 5f8:	00000073          	ecall
 ret
 5fc:	8082                	ret

00000000000005fe <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5fe:	48c5                	li	a7,17
 ecall
 600:	00000073          	ecall
 ret
 604:	8082                	ret

0000000000000606 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 606:	48c9                	li	a7,18
 ecall
 608:	00000073          	ecall
 ret
 60c:	8082                	ret

000000000000060e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 60e:	48a1                	li	a7,8
 ecall
 610:	00000073          	ecall
 ret
 614:	8082                	ret

0000000000000616 <link>:
.global link
link:
 li a7, SYS_link
 616:	48cd                	li	a7,19
 ecall
 618:	00000073          	ecall
 ret
 61c:	8082                	ret

000000000000061e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 61e:	48d1                	li	a7,20
 ecall
 620:	00000073          	ecall
 ret
 624:	8082                	ret

0000000000000626 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 626:	48a5                	li	a7,9
 ecall
 628:	00000073          	ecall
 ret
 62c:	8082                	ret

000000000000062e <dup>:
.global dup
dup:
 li a7, SYS_dup
 62e:	48a9                	li	a7,10
 ecall
 630:	00000073          	ecall
 ret
 634:	8082                	ret

0000000000000636 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 636:	48ad                	li	a7,11
 ecall
 638:	00000073          	ecall
 ret
 63c:	8082                	ret

000000000000063e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 63e:	48b1                	li	a7,12
 ecall
 640:	00000073          	ecall
 ret
 644:	8082                	ret

0000000000000646 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 646:	48b5                	li	a7,13
 ecall
 648:	00000073          	ecall
 ret
 64c:	8082                	ret

000000000000064e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 64e:	48b9                	li	a7,14
 ecall
 650:	00000073          	ecall
 ret
 654:	8082                	ret

0000000000000656 <trace>:
.global trace
trace:
 li a7, SYS_trace
 656:	48d9                	li	a7,22
 ecall
 658:	00000073          	ecall
 ret
 65c:	8082                	ret

000000000000065e <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 65e:	48dd                	li	a7,23
 ecall
 660:	00000073          	ecall
 ret
 664:	8082                	ret

0000000000000666 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 666:	1101                	addi	sp,sp,-32
 668:	ec06                	sd	ra,24(sp)
 66a:	e822                	sd	s0,16(sp)
 66c:	1000                	addi	s0,sp,32
 66e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 672:	4605                	li	a2,1
 674:	fef40593          	addi	a1,s0,-17
 678:	00000097          	auipc	ra,0x0
 67c:	f5e080e7          	jalr	-162(ra) # 5d6 <write>
}
 680:	60e2                	ld	ra,24(sp)
 682:	6442                	ld	s0,16(sp)
 684:	6105                	addi	sp,sp,32
 686:	8082                	ret

0000000000000688 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 688:	7139                	addi	sp,sp,-64
 68a:	fc06                	sd	ra,56(sp)
 68c:	f822                	sd	s0,48(sp)
 68e:	f426                	sd	s1,40(sp)
 690:	f04a                	sd	s2,32(sp)
 692:	ec4e                	sd	s3,24(sp)
 694:	0080                	addi	s0,sp,64
 696:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 698:	c299                	beqz	a3,69e <printint+0x16>
 69a:	0805c863          	bltz	a1,72a <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 69e:	2581                	sext.w	a1,a1
  neg = 0;
 6a0:	4881                	li	a7,0
 6a2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 6a6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 6a8:	2601                	sext.w	a2,a2
 6aa:	00000517          	auipc	a0,0x0
 6ae:	59650513          	addi	a0,a0,1430 # c40 <digits>
 6b2:	883a                	mv	a6,a4
 6b4:	2705                	addiw	a4,a4,1
 6b6:	02c5f7bb          	remuw	a5,a1,a2
 6ba:	1782                	slli	a5,a5,0x20
 6bc:	9381                	srli	a5,a5,0x20
 6be:	97aa                	add	a5,a5,a0
 6c0:	0007c783          	lbu	a5,0(a5)
 6c4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 6c8:	0005879b          	sext.w	a5,a1
 6cc:	02c5d5bb          	divuw	a1,a1,a2
 6d0:	0685                	addi	a3,a3,1
 6d2:	fec7f0e3          	bgeu	a5,a2,6b2 <printint+0x2a>
  if(neg)
 6d6:	00088b63          	beqz	a7,6ec <printint+0x64>
    buf[i++] = '-';
 6da:	fd040793          	addi	a5,s0,-48
 6de:	973e                	add	a4,a4,a5
 6e0:	02d00793          	li	a5,45
 6e4:	fef70823          	sb	a5,-16(a4)
 6e8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 6ec:	02e05863          	blez	a4,71c <printint+0x94>
 6f0:	fc040793          	addi	a5,s0,-64
 6f4:	00e78933          	add	s2,a5,a4
 6f8:	fff78993          	addi	s3,a5,-1
 6fc:	99ba                	add	s3,s3,a4
 6fe:	377d                	addiw	a4,a4,-1
 700:	1702                	slli	a4,a4,0x20
 702:	9301                	srli	a4,a4,0x20
 704:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 708:	fff94583          	lbu	a1,-1(s2)
 70c:	8526                	mv	a0,s1
 70e:	00000097          	auipc	ra,0x0
 712:	f58080e7          	jalr	-168(ra) # 666 <putc>
  while(--i >= 0)
 716:	197d                	addi	s2,s2,-1
 718:	ff3918e3          	bne	s2,s3,708 <printint+0x80>
}
 71c:	70e2                	ld	ra,56(sp)
 71e:	7442                	ld	s0,48(sp)
 720:	74a2                	ld	s1,40(sp)
 722:	7902                	ld	s2,32(sp)
 724:	69e2                	ld	s3,24(sp)
 726:	6121                	addi	sp,sp,64
 728:	8082                	ret
    x = -xx;
 72a:	40b005bb          	negw	a1,a1
    neg = 1;
 72e:	4885                	li	a7,1
    x = -xx;
 730:	bf8d                	j	6a2 <printint+0x1a>

0000000000000732 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 732:	7119                	addi	sp,sp,-128
 734:	fc86                	sd	ra,120(sp)
 736:	f8a2                	sd	s0,112(sp)
 738:	f4a6                	sd	s1,104(sp)
 73a:	f0ca                	sd	s2,96(sp)
 73c:	ecce                	sd	s3,88(sp)
 73e:	e8d2                	sd	s4,80(sp)
 740:	e4d6                	sd	s5,72(sp)
 742:	e0da                	sd	s6,64(sp)
 744:	fc5e                	sd	s7,56(sp)
 746:	f862                	sd	s8,48(sp)
 748:	f466                	sd	s9,40(sp)
 74a:	f06a                	sd	s10,32(sp)
 74c:	ec6e                	sd	s11,24(sp)
 74e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 750:	0005c903          	lbu	s2,0(a1)
 754:	18090f63          	beqz	s2,8f2 <vprintf+0x1c0>
 758:	8aaa                	mv	s5,a0
 75a:	8b32                	mv	s6,a2
 75c:	00158493          	addi	s1,a1,1
  state = 0;
 760:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 762:	02500a13          	li	s4,37
      if(c == 'd'){
 766:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 76a:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 76e:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 772:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 776:	00000b97          	auipc	s7,0x0
 77a:	4cab8b93          	addi	s7,s7,1226 # c40 <digits>
 77e:	a839                	j	79c <vprintf+0x6a>
        putc(fd, c);
 780:	85ca                	mv	a1,s2
 782:	8556                	mv	a0,s5
 784:	00000097          	auipc	ra,0x0
 788:	ee2080e7          	jalr	-286(ra) # 666 <putc>
 78c:	a019                	j	792 <vprintf+0x60>
    } else if(state == '%'){
 78e:	01498f63          	beq	s3,s4,7ac <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 792:	0485                	addi	s1,s1,1
 794:	fff4c903          	lbu	s2,-1(s1)
 798:	14090d63          	beqz	s2,8f2 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 79c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 7a0:	fe0997e3          	bnez	s3,78e <vprintf+0x5c>
      if(c == '%'){
 7a4:	fd479ee3          	bne	a5,s4,780 <vprintf+0x4e>
        state = '%';
 7a8:	89be                	mv	s3,a5
 7aa:	b7e5                	j	792 <vprintf+0x60>
      if(c == 'd'){
 7ac:	05878063          	beq	a5,s8,7ec <vprintf+0xba>
      } else if(c == 'l') {
 7b0:	05978c63          	beq	a5,s9,808 <vprintf+0xd6>
      } else if(c == 'x') {
 7b4:	07a78863          	beq	a5,s10,824 <vprintf+0xf2>
      } else if(c == 'p') {
 7b8:	09b78463          	beq	a5,s11,840 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 7bc:	07300713          	li	a4,115
 7c0:	0ce78663          	beq	a5,a4,88c <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7c4:	06300713          	li	a4,99
 7c8:	0ee78e63          	beq	a5,a4,8c4 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 7cc:	11478863          	beq	a5,s4,8dc <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7d0:	85d2                	mv	a1,s4
 7d2:	8556                	mv	a0,s5
 7d4:	00000097          	auipc	ra,0x0
 7d8:	e92080e7          	jalr	-366(ra) # 666 <putc>
        putc(fd, c);
 7dc:	85ca                	mv	a1,s2
 7de:	8556                	mv	a0,s5
 7e0:	00000097          	auipc	ra,0x0
 7e4:	e86080e7          	jalr	-378(ra) # 666 <putc>
      }
      state = 0;
 7e8:	4981                	li	s3,0
 7ea:	b765                	j	792 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 7ec:	008b0913          	addi	s2,s6,8
 7f0:	4685                	li	a3,1
 7f2:	4629                	li	a2,10
 7f4:	000b2583          	lw	a1,0(s6)
 7f8:	8556                	mv	a0,s5
 7fa:	00000097          	auipc	ra,0x0
 7fe:	e8e080e7          	jalr	-370(ra) # 688 <printint>
 802:	8b4a                	mv	s6,s2
      state = 0;
 804:	4981                	li	s3,0
 806:	b771                	j	792 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 808:	008b0913          	addi	s2,s6,8
 80c:	4681                	li	a3,0
 80e:	4629                	li	a2,10
 810:	000b2583          	lw	a1,0(s6)
 814:	8556                	mv	a0,s5
 816:	00000097          	auipc	ra,0x0
 81a:	e72080e7          	jalr	-398(ra) # 688 <printint>
 81e:	8b4a                	mv	s6,s2
      state = 0;
 820:	4981                	li	s3,0
 822:	bf85                	j	792 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 824:	008b0913          	addi	s2,s6,8
 828:	4681                	li	a3,0
 82a:	4641                	li	a2,16
 82c:	000b2583          	lw	a1,0(s6)
 830:	8556                	mv	a0,s5
 832:	00000097          	auipc	ra,0x0
 836:	e56080e7          	jalr	-426(ra) # 688 <printint>
 83a:	8b4a                	mv	s6,s2
      state = 0;
 83c:	4981                	li	s3,0
 83e:	bf91                	j	792 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 840:	008b0793          	addi	a5,s6,8
 844:	f8f43423          	sd	a5,-120(s0)
 848:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 84c:	03000593          	li	a1,48
 850:	8556                	mv	a0,s5
 852:	00000097          	auipc	ra,0x0
 856:	e14080e7          	jalr	-492(ra) # 666 <putc>
  putc(fd, 'x');
 85a:	85ea                	mv	a1,s10
 85c:	8556                	mv	a0,s5
 85e:	00000097          	auipc	ra,0x0
 862:	e08080e7          	jalr	-504(ra) # 666 <putc>
 866:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 868:	03c9d793          	srli	a5,s3,0x3c
 86c:	97de                	add	a5,a5,s7
 86e:	0007c583          	lbu	a1,0(a5)
 872:	8556                	mv	a0,s5
 874:	00000097          	auipc	ra,0x0
 878:	df2080e7          	jalr	-526(ra) # 666 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 87c:	0992                	slli	s3,s3,0x4
 87e:	397d                	addiw	s2,s2,-1
 880:	fe0914e3          	bnez	s2,868 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 884:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 888:	4981                	li	s3,0
 88a:	b721                	j	792 <vprintf+0x60>
        s = va_arg(ap, char*);
 88c:	008b0993          	addi	s3,s6,8
 890:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 894:	02090163          	beqz	s2,8b6 <vprintf+0x184>
        while(*s != 0){
 898:	00094583          	lbu	a1,0(s2)
 89c:	c9a1                	beqz	a1,8ec <vprintf+0x1ba>
          putc(fd, *s);
 89e:	8556                	mv	a0,s5
 8a0:	00000097          	auipc	ra,0x0
 8a4:	dc6080e7          	jalr	-570(ra) # 666 <putc>
          s++;
 8a8:	0905                	addi	s2,s2,1
        while(*s != 0){
 8aa:	00094583          	lbu	a1,0(s2)
 8ae:	f9e5                	bnez	a1,89e <vprintf+0x16c>
        s = va_arg(ap, char*);
 8b0:	8b4e                	mv	s6,s3
      state = 0;
 8b2:	4981                	li	s3,0
 8b4:	bdf9                	j	792 <vprintf+0x60>
          s = "(null)";
 8b6:	00000917          	auipc	s2,0x0
 8ba:	38290913          	addi	s2,s2,898 # c38 <malloc+0x23c>
        while(*s != 0){
 8be:	02800593          	li	a1,40
 8c2:	bff1                	j	89e <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 8c4:	008b0913          	addi	s2,s6,8
 8c8:	000b4583          	lbu	a1,0(s6)
 8cc:	8556                	mv	a0,s5
 8ce:	00000097          	auipc	ra,0x0
 8d2:	d98080e7          	jalr	-616(ra) # 666 <putc>
 8d6:	8b4a                	mv	s6,s2
      state = 0;
 8d8:	4981                	li	s3,0
 8da:	bd65                	j	792 <vprintf+0x60>
        putc(fd, c);
 8dc:	85d2                	mv	a1,s4
 8de:	8556                	mv	a0,s5
 8e0:	00000097          	auipc	ra,0x0
 8e4:	d86080e7          	jalr	-634(ra) # 666 <putc>
      state = 0;
 8e8:	4981                	li	s3,0
 8ea:	b565                	j	792 <vprintf+0x60>
        s = va_arg(ap, char*);
 8ec:	8b4e                	mv	s6,s3
      state = 0;
 8ee:	4981                	li	s3,0
 8f0:	b54d                	j	792 <vprintf+0x60>
    }
  }
}
 8f2:	70e6                	ld	ra,120(sp)
 8f4:	7446                	ld	s0,112(sp)
 8f6:	74a6                	ld	s1,104(sp)
 8f8:	7906                	ld	s2,96(sp)
 8fa:	69e6                	ld	s3,88(sp)
 8fc:	6a46                	ld	s4,80(sp)
 8fe:	6aa6                	ld	s5,72(sp)
 900:	6b06                	ld	s6,64(sp)
 902:	7be2                	ld	s7,56(sp)
 904:	7c42                	ld	s8,48(sp)
 906:	7ca2                	ld	s9,40(sp)
 908:	7d02                	ld	s10,32(sp)
 90a:	6de2                	ld	s11,24(sp)
 90c:	6109                	addi	sp,sp,128
 90e:	8082                	ret

0000000000000910 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 910:	715d                	addi	sp,sp,-80
 912:	ec06                	sd	ra,24(sp)
 914:	e822                	sd	s0,16(sp)
 916:	1000                	addi	s0,sp,32
 918:	e010                	sd	a2,0(s0)
 91a:	e414                	sd	a3,8(s0)
 91c:	e818                	sd	a4,16(s0)
 91e:	ec1c                	sd	a5,24(s0)
 920:	03043023          	sd	a6,32(s0)
 924:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 928:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 92c:	8622                	mv	a2,s0
 92e:	00000097          	auipc	ra,0x0
 932:	e04080e7          	jalr	-508(ra) # 732 <vprintf>
}
 936:	60e2                	ld	ra,24(sp)
 938:	6442                	ld	s0,16(sp)
 93a:	6161                	addi	sp,sp,80
 93c:	8082                	ret

000000000000093e <printf>:

void
printf(const char *fmt, ...)
{
 93e:	711d                	addi	sp,sp,-96
 940:	ec06                	sd	ra,24(sp)
 942:	e822                	sd	s0,16(sp)
 944:	1000                	addi	s0,sp,32
 946:	e40c                	sd	a1,8(s0)
 948:	e810                	sd	a2,16(s0)
 94a:	ec14                	sd	a3,24(s0)
 94c:	f018                	sd	a4,32(s0)
 94e:	f41c                	sd	a5,40(s0)
 950:	03043823          	sd	a6,48(s0)
 954:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 958:	00840613          	addi	a2,s0,8
 95c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 960:	85aa                	mv	a1,a0
 962:	4505                	li	a0,1
 964:	00000097          	auipc	ra,0x0
 968:	dce080e7          	jalr	-562(ra) # 732 <vprintf>
}
 96c:	60e2                	ld	ra,24(sp)
 96e:	6442                	ld	s0,16(sp)
 970:	6125                	addi	sp,sp,96
 972:	8082                	ret

0000000000000974 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 974:	1141                	addi	sp,sp,-16
 976:	e422                	sd	s0,8(sp)
 978:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 97a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 97e:	00000797          	auipc	a5,0x0
 982:	2e27b783          	ld	a5,738(a5) # c60 <freep>
 986:	a805                	j	9b6 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 988:	4618                	lw	a4,8(a2)
 98a:	9db9                	addw	a1,a1,a4
 98c:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 990:	6398                	ld	a4,0(a5)
 992:	6318                	ld	a4,0(a4)
 994:	fee53823          	sd	a4,-16(a0)
 998:	a091                	j	9dc <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 99a:	ff852703          	lw	a4,-8(a0)
 99e:	9e39                	addw	a2,a2,a4
 9a0:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 9a2:	ff053703          	ld	a4,-16(a0)
 9a6:	e398                	sd	a4,0(a5)
 9a8:	a099                	j	9ee <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9aa:	6398                	ld	a4,0(a5)
 9ac:	00e7e463          	bltu	a5,a4,9b4 <free+0x40>
 9b0:	00e6ea63          	bltu	a3,a4,9c4 <free+0x50>
{
 9b4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9b6:	fed7fae3          	bgeu	a5,a3,9aa <free+0x36>
 9ba:	6398                	ld	a4,0(a5)
 9bc:	00e6e463          	bltu	a3,a4,9c4 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9c0:	fee7eae3          	bltu	a5,a4,9b4 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 9c4:	ff852583          	lw	a1,-8(a0)
 9c8:	6390                	ld	a2,0(a5)
 9ca:	02059713          	slli	a4,a1,0x20
 9ce:	9301                	srli	a4,a4,0x20
 9d0:	0712                	slli	a4,a4,0x4
 9d2:	9736                	add	a4,a4,a3
 9d4:	fae60ae3          	beq	a2,a4,988 <free+0x14>
    bp->s.ptr = p->s.ptr;
 9d8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9dc:	4790                	lw	a2,8(a5)
 9de:	02061713          	slli	a4,a2,0x20
 9e2:	9301                	srli	a4,a4,0x20
 9e4:	0712                	slli	a4,a4,0x4
 9e6:	973e                	add	a4,a4,a5
 9e8:	fae689e3          	beq	a3,a4,99a <free+0x26>
  } else
    p->s.ptr = bp;
 9ec:	e394                	sd	a3,0(a5)
  freep = p;
 9ee:	00000717          	auipc	a4,0x0
 9f2:	26f73923          	sd	a5,626(a4) # c60 <freep>
}
 9f6:	6422                	ld	s0,8(sp)
 9f8:	0141                	addi	sp,sp,16
 9fa:	8082                	ret

00000000000009fc <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9fc:	7139                	addi	sp,sp,-64
 9fe:	fc06                	sd	ra,56(sp)
 a00:	f822                	sd	s0,48(sp)
 a02:	f426                	sd	s1,40(sp)
 a04:	f04a                	sd	s2,32(sp)
 a06:	ec4e                	sd	s3,24(sp)
 a08:	e852                	sd	s4,16(sp)
 a0a:	e456                	sd	s5,8(sp)
 a0c:	e05a                	sd	s6,0(sp)
 a0e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a10:	02051493          	slli	s1,a0,0x20
 a14:	9081                	srli	s1,s1,0x20
 a16:	04bd                	addi	s1,s1,15
 a18:	8091                	srli	s1,s1,0x4
 a1a:	0014899b          	addiw	s3,s1,1
 a1e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a20:	00000517          	auipc	a0,0x0
 a24:	24053503          	ld	a0,576(a0) # c60 <freep>
 a28:	c515                	beqz	a0,a54 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a2a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a2c:	4798                	lw	a4,8(a5)
 a2e:	02977f63          	bgeu	a4,s1,a6c <malloc+0x70>
 a32:	8a4e                	mv	s4,s3
 a34:	0009871b          	sext.w	a4,s3
 a38:	6685                	lui	a3,0x1
 a3a:	00d77363          	bgeu	a4,a3,a40 <malloc+0x44>
 a3e:	6a05                	lui	s4,0x1
 a40:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a44:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a48:	00000917          	auipc	s2,0x0
 a4c:	21890913          	addi	s2,s2,536 # c60 <freep>
  if(p == (char*)-1)
 a50:	5afd                	li	s5,-1
 a52:	a88d                	j	ac4 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 a54:	00000797          	auipc	a5,0x0
 a58:	21478793          	addi	a5,a5,532 # c68 <base>
 a5c:	00000717          	auipc	a4,0x0
 a60:	20f73223          	sd	a5,516(a4) # c60 <freep>
 a64:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a66:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a6a:	b7e1                	j	a32 <malloc+0x36>
      if(p->s.size == nunits)
 a6c:	02e48b63          	beq	s1,a4,aa2 <malloc+0xa6>
        p->s.size -= nunits;
 a70:	4137073b          	subw	a4,a4,s3
 a74:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a76:	1702                	slli	a4,a4,0x20
 a78:	9301                	srli	a4,a4,0x20
 a7a:	0712                	slli	a4,a4,0x4
 a7c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a7e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a82:	00000717          	auipc	a4,0x0
 a86:	1ca73f23          	sd	a0,478(a4) # c60 <freep>
      return (void*)(p + 1);
 a8a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a8e:	70e2                	ld	ra,56(sp)
 a90:	7442                	ld	s0,48(sp)
 a92:	74a2                	ld	s1,40(sp)
 a94:	7902                	ld	s2,32(sp)
 a96:	69e2                	ld	s3,24(sp)
 a98:	6a42                	ld	s4,16(sp)
 a9a:	6aa2                	ld	s5,8(sp)
 a9c:	6b02                	ld	s6,0(sp)
 a9e:	6121                	addi	sp,sp,64
 aa0:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 aa2:	6398                	ld	a4,0(a5)
 aa4:	e118                	sd	a4,0(a0)
 aa6:	bff1                	j	a82 <malloc+0x86>
  hp->s.size = nu;
 aa8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 aac:	0541                	addi	a0,a0,16
 aae:	00000097          	auipc	ra,0x0
 ab2:	ec6080e7          	jalr	-314(ra) # 974 <free>
  return freep;
 ab6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 aba:	d971                	beqz	a0,a8e <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 abc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 abe:	4798                	lw	a4,8(a5)
 ac0:	fa9776e3          	bgeu	a4,s1,a6c <malloc+0x70>
    if(p == freep)
 ac4:	00093703          	ld	a4,0(s2)
 ac8:	853e                	mv	a0,a5
 aca:	fef719e3          	bne	a4,a5,abc <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 ace:	8552                	mv	a0,s4
 ad0:	00000097          	auipc	ra,0x0
 ad4:	b6e080e7          	jalr	-1170(ra) # 63e <sbrk>
  if(p == (char*)-1)
 ad8:	fd5518e3          	bne	a0,s5,aa8 <malloc+0xac>
        return 0;
 adc:	4501                	li	a0,0
 ade:	bf45                	j	a8e <malloc+0x92>
