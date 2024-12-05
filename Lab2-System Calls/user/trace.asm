
user/_trace:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	712d                	addi	sp,sp,-288
   2:	ee06                	sd	ra,280(sp)
   4:	ea22                	sd	s0,272(sp)
   6:	e626                	sd	s1,264(sp)
   8:	e24a                	sd	s2,256(sp)
   a:	1200                	addi	s0,sp,288
   c:	892e                	mv	s2,a1
  int i;
  char *nargv[MAXARG];

  if(argc < 3 || (argv[1][0] < '0' || argv[1][0] > '9')){
   e:	4789                	li	a5,2
  10:	00a7dd63          	bge	a5,a0,2a <main+0x2a>
  14:	84aa                	mv	s1,a0
  16:	6588                	ld	a0,8(a1)
  18:	00054783          	lbu	a5,0(a0)
  1c:	fd07879b          	addiw	a5,a5,-48
  20:	0ff7f793          	andi	a5,a5,255
  24:	4725                	li	a4,9
  26:	02f77263          	bgeu	a4,a5,4a <main+0x4a>
    fprintf(2, "Usage: %s mask command\n", argv[0]);
  2a:	00093603          	ld	a2,0(s2)
  2e:	00001597          	auipc	a1,0x1
  32:	83258593          	addi	a1,a1,-1998 # 860 <malloc+0xe4>
  36:	4509                	li	a0,2
  38:	00000097          	auipc	ra,0x0
  3c:	658080e7          	jalr	1624(ra) # 690 <fprintf>
    exit(1);
  40:	4505                	li	a0,1
  42:	00000097          	auipc	ra,0x0
  46:	2f4080e7          	jalr	756(ra) # 336 <exit>
  }

  if (trace(atoi(argv[1])) < 0) {
  4a:	00000097          	auipc	ra,0x0
  4e:	1ec080e7          	jalr	492(ra) # 236 <atoi>
  52:	00000097          	auipc	ra,0x0
  56:	384080e7          	jalr	900(ra) # 3d6 <trace>
  5a:	04054363          	bltz	a0,a0 <main+0xa0>
  5e:	01090793          	addi	a5,s2,16
  62:	ee040713          	addi	a4,s0,-288
  66:	ffd4869b          	addiw	a3,s1,-3
  6a:	1682                	slli	a3,a3,0x20
  6c:	9281                	srli	a3,a3,0x20
  6e:	068e                	slli	a3,a3,0x3
  70:	96be                	add	a3,a3,a5
  72:	10090913          	addi	s2,s2,256
    fprintf(2, "%s: trace failed\n", argv[0]);
    exit(1);
  }
  
  for(i = 2; i < argc && i < MAXARG; i++){
    nargv[i-2] = argv[i];
  76:	6390                	ld	a2,0(a5)
  78:	e310                	sd	a2,0(a4)
  for(i = 2; i < argc && i < MAXARG; i++){
  7a:	00d78663          	beq	a5,a3,86 <main+0x86>
  7e:	07a1                	addi	a5,a5,8
  80:	0721                	addi	a4,a4,8
  82:	ff279ae3          	bne	a5,s2,76 <main+0x76>
  }
  exec(nargv[0], nargv);
  86:	ee040593          	addi	a1,s0,-288
  8a:	ee043503          	ld	a0,-288(s0)
  8e:	00000097          	auipc	ra,0x0
  92:	2e0080e7          	jalr	736(ra) # 36e <exec>
  exit(0);
  96:	4501                	li	a0,0
  98:	00000097          	auipc	ra,0x0
  9c:	29e080e7          	jalr	670(ra) # 336 <exit>
    fprintf(2, "%s: trace failed\n", argv[0]);
  a0:	00093603          	ld	a2,0(s2)
  a4:	00000597          	auipc	a1,0x0
  a8:	7d458593          	addi	a1,a1,2004 # 878 <malloc+0xfc>
  ac:	4509                	li	a0,2
  ae:	00000097          	auipc	ra,0x0
  b2:	5e2080e7          	jalr	1506(ra) # 690 <fprintf>
    exit(1);
  b6:	4505                	li	a0,1
  b8:	00000097          	auipc	ra,0x0
  bc:	27e080e7          	jalr	638(ra) # 336 <exit>

00000000000000c0 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  c0:	1141                	addi	sp,sp,-16
  c2:	e422                	sd	s0,8(sp)
  c4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  c6:	87aa                	mv	a5,a0
  c8:	0585                	addi	a1,a1,1
  ca:	0785                	addi	a5,a5,1
  cc:	fff5c703          	lbu	a4,-1(a1)
  d0:	fee78fa3          	sb	a4,-1(a5)
  d4:	fb75                	bnez	a4,c8 <strcpy+0x8>
    ;
  return os;
}
  d6:	6422                	ld	s0,8(sp)
  d8:	0141                	addi	sp,sp,16
  da:	8082                	ret

00000000000000dc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  dc:	1141                	addi	sp,sp,-16
  de:	e422                	sd	s0,8(sp)
  e0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  e2:	00054783          	lbu	a5,0(a0)
  e6:	cb91                	beqz	a5,fa <strcmp+0x1e>
  e8:	0005c703          	lbu	a4,0(a1)
  ec:	00f71763          	bne	a4,a5,fa <strcmp+0x1e>
    p++, q++;
  f0:	0505                	addi	a0,a0,1
  f2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  f4:	00054783          	lbu	a5,0(a0)
  f8:	fbe5                	bnez	a5,e8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  fa:	0005c503          	lbu	a0,0(a1)
}
  fe:	40a7853b          	subw	a0,a5,a0
 102:	6422                	ld	s0,8(sp)
 104:	0141                	addi	sp,sp,16
 106:	8082                	ret

0000000000000108 <strlen>:

uint
strlen(const char *s)
{
 108:	1141                	addi	sp,sp,-16
 10a:	e422                	sd	s0,8(sp)
 10c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 10e:	00054783          	lbu	a5,0(a0)
 112:	cf91                	beqz	a5,12e <strlen+0x26>
 114:	0505                	addi	a0,a0,1
 116:	87aa                	mv	a5,a0
 118:	4685                	li	a3,1
 11a:	9e89                	subw	a3,a3,a0
 11c:	00f6853b          	addw	a0,a3,a5
 120:	0785                	addi	a5,a5,1
 122:	fff7c703          	lbu	a4,-1(a5)
 126:	fb7d                	bnez	a4,11c <strlen+0x14>
    ;
  return n;
}
 128:	6422                	ld	s0,8(sp)
 12a:	0141                	addi	sp,sp,16
 12c:	8082                	ret
  for(n = 0; s[n]; n++)
 12e:	4501                	li	a0,0
 130:	bfe5                	j	128 <strlen+0x20>

0000000000000132 <memset>:

void*
memset(void *dst, int c, uint n)
{
 132:	1141                	addi	sp,sp,-16
 134:	e422                	sd	s0,8(sp)
 136:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 138:	ce09                	beqz	a2,152 <memset+0x20>
 13a:	87aa                	mv	a5,a0
 13c:	fff6071b          	addiw	a4,a2,-1
 140:	1702                	slli	a4,a4,0x20
 142:	9301                	srli	a4,a4,0x20
 144:	0705                	addi	a4,a4,1
 146:	972a                	add	a4,a4,a0
    cdst[i] = c;
 148:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 14c:	0785                	addi	a5,a5,1
 14e:	fee79de3          	bne	a5,a4,148 <memset+0x16>
  }
  return dst;
}
 152:	6422                	ld	s0,8(sp)
 154:	0141                	addi	sp,sp,16
 156:	8082                	ret

0000000000000158 <strchr>:

char*
strchr(const char *s, char c)
{
 158:	1141                	addi	sp,sp,-16
 15a:	e422                	sd	s0,8(sp)
 15c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 15e:	00054783          	lbu	a5,0(a0)
 162:	cb99                	beqz	a5,178 <strchr+0x20>
    if(*s == c)
 164:	00f58763          	beq	a1,a5,172 <strchr+0x1a>
  for(; *s; s++)
 168:	0505                	addi	a0,a0,1
 16a:	00054783          	lbu	a5,0(a0)
 16e:	fbfd                	bnez	a5,164 <strchr+0xc>
      return (char*)s;
  return 0;
 170:	4501                	li	a0,0
}
 172:	6422                	ld	s0,8(sp)
 174:	0141                	addi	sp,sp,16
 176:	8082                	ret
  return 0;
 178:	4501                	li	a0,0
 17a:	bfe5                	j	172 <strchr+0x1a>

000000000000017c <gets>:

char*
gets(char *buf, int max)
{
 17c:	711d                	addi	sp,sp,-96
 17e:	ec86                	sd	ra,88(sp)
 180:	e8a2                	sd	s0,80(sp)
 182:	e4a6                	sd	s1,72(sp)
 184:	e0ca                	sd	s2,64(sp)
 186:	fc4e                	sd	s3,56(sp)
 188:	f852                	sd	s4,48(sp)
 18a:	f456                	sd	s5,40(sp)
 18c:	f05a                	sd	s6,32(sp)
 18e:	ec5e                	sd	s7,24(sp)
 190:	1080                	addi	s0,sp,96
 192:	8baa                	mv	s7,a0
 194:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 196:	892a                	mv	s2,a0
 198:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 19a:	4aa9                	li	s5,10
 19c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 19e:	89a6                	mv	s3,s1
 1a0:	2485                	addiw	s1,s1,1
 1a2:	0344d863          	bge	s1,s4,1d2 <gets+0x56>
    cc = read(0, &c, 1);
 1a6:	4605                	li	a2,1
 1a8:	faf40593          	addi	a1,s0,-81
 1ac:	4501                	li	a0,0
 1ae:	00000097          	auipc	ra,0x0
 1b2:	1a0080e7          	jalr	416(ra) # 34e <read>
    if(cc < 1)
 1b6:	00a05e63          	blez	a0,1d2 <gets+0x56>
    buf[i++] = c;
 1ba:	faf44783          	lbu	a5,-81(s0)
 1be:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1c2:	01578763          	beq	a5,s5,1d0 <gets+0x54>
 1c6:	0905                	addi	s2,s2,1
 1c8:	fd679be3          	bne	a5,s6,19e <gets+0x22>
  for(i=0; i+1 < max; ){
 1cc:	89a6                	mv	s3,s1
 1ce:	a011                	j	1d2 <gets+0x56>
 1d0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1d2:	99de                	add	s3,s3,s7
 1d4:	00098023          	sb	zero,0(s3)
  return buf;
}
 1d8:	855e                	mv	a0,s7
 1da:	60e6                	ld	ra,88(sp)
 1dc:	6446                	ld	s0,80(sp)
 1de:	64a6                	ld	s1,72(sp)
 1e0:	6906                	ld	s2,64(sp)
 1e2:	79e2                	ld	s3,56(sp)
 1e4:	7a42                	ld	s4,48(sp)
 1e6:	7aa2                	ld	s5,40(sp)
 1e8:	7b02                	ld	s6,32(sp)
 1ea:	6be2                	ld	s7,24(sp)
 1ec:	6125                	addi	sp,sp,96
 1ee:	8082                	ret

00000000000001f0 <stat>:

int
stat(const char *n, struct stat *st)
{
 1f0:	1101                	addi	sp,sp,-32
 1f2:	ec06                	sd	ra,24(sp)
 1f4:	e822                	sd	s0,16(sp)
 1f6:	e426                	sd	s1,8(sp)
 1f8:	e04a                	sd	s2,0(sp)
 1fa:	1000                	addi	s0,sp,32
 1fc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1fe:	4581                	li	a1,0
 200:	00000097          	auipc	ra,0x0
 204:	176080e7          	jalr	374(ra) # 376 <open>
  if(fd < 0)
 208:	02054563          	bltz	a0,232 <stat+0x42>
 20c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 20e:	85ca                	mv	a1,s2
 210:	00000097          	auipc	ra,0x0
 214:	17e080e7          	jalr	382(ra) # 38e <fstat>
 218:	892a                	mv	s2,a0
  close(fd);
 21a:	8526                	mv	a0,s1
 21c:	00000097          	auipc	ra,0x0
 220:	142080e7          	jalr	322(ra) # 35e <close>
  return r;
}
 224:	854a                	mv	a0,s2
 226:	60e2                	ld	ra,24(sp)
 228:	6442                	ld	s0,16(sp)
 22a:	64a2                	ld	s1,8(sp)
 22c:	6902                	ld	s2,0(sp)
 22e:	6105                	addi	sp,sp,32
 230:	8082                	ret
    return -1;
 232:	597d                	li	s2,-1
 234:	bfc5                	j	224 <stat+0x34>

0000000000000236 <atoi>:

int
atoi(const char *s)
{
 236:	1141                	addi	sp,sp,-16
 238:	e422                	sd	s0,8(sp)
 23a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 23c:	00054603          	lbu	a2,0(a0)
 240:	fd06079b          	addiw	a5,a2,-48
 244:	0ff7f793          	andi	a5,a5,255
 248:	4725                	li	a4,9
 24a:	02f76963          	bltu	a4,a5,27c <atoi+0x46>
 24e:	86aa                	mv	a3,a0
  n = 0;
 250:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 252:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 254:	0685                	addi	a3,a3,1
 256:	0025179b          	slliw	a5,a0,0x2
 25a:	9fa9                	addw	a5,a5,a0
 25c:	0017979b          	slliw	a5,a5,0x1
 260:	9fb1                	addw	a5,a5,a2
 262:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 266:	0006c603          	lbu	a2,0(a3)
 26a:	fd06071b          	addiw	a4,a2,-48
 26e:	0ff77713          	andi	a4,a4,255
 272:	fee5f1e3          	bgeu	a1,a4,254 <atoi+0x1e>
  return n;
}
 276:	6422                	ld	s0,8(sp)
 278:	0141                	addi	sp,sp,16
 27a:	8082                	ret
  n = 0;
 27c:	4501                	li	a0,0
 27e:	bfe5                	j	276 <atoi+0x40>

0000000000000280 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 280:	1141                	addi	sp,sp,-16
 282:	e422                	sd	s0,8(sp)
 284:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 286:	02b57663          	bgeu	a0,a1,2b2 <memmove+0x32>
    while(n-- > 0)
 28a:	02c05163          	blez	a2,2ac <memmove+0x2c>
 28e:	fff6079b          	addiw	a5,a2,-1
 292:	1782                	slli	a5,a5,0x20
 294:	9381                	srli	a5,a5,0x20
 296:	0785                	addi	a5,a5,1
 298:	97aa                	add	a5,a5,a0
  dst = vdst;
 29a:	872a                	mv	a4,a0
      *dst++ = *src++;
 29c:	0585                	addi	a1,a1,1
 29e:	0705                	addi	a4,a4,1
 2a0:	fff5c683          	lbu	a3,-1(a1)
 2a4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2a8:	fee79ae3          	bne	a5,a4,29c <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2ac:	6422                	ld	s0,8(sp)
 2ae:	0141                	addi	sp,sp,16
 2b0:	8082                	ret
    dst += n;
 2b2:	00c50733          	add	a4,a0,a2
    src += n;
 2b6:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2b8:	fec05ae3          	blez	a2,2ac <memmove+0x2c>
 2bc:	fff6079b          	addiw	a5,a2,-1
 2c0:	1782                	slli	a5,a5,0x20
 2c2:	9381                	srli	a5,a5,0x20
 2c4:	fff7c793          	not	a5,a5
 2c8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2ca:	15fd                	addi	a1,a1,-1
 2cc:	177d                	addi	a4,a4,-1
 2ce:	0005c683          	lbu	a3,0(a1)
 2d2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2d6:	fee79ae3          	bne	a5,a4,2ca <memmove+0x4a>
 2da:	bfc9                	j	2ac <memmove+0x2c>

00000000000002dc <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2dc:	1141                	addi	sp,sp,-16
 2de:	e422                	sd	s0,8(sp)
 2e0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2e2:	ca05                	beqz	a2,312 <memcmp+0x36>
 2e4:	fff6069b          	addiw	a3,a2,-1
 2e8:	1682                	slli	a3,a3,0x20
 2ea:	9281                	srli	a3,a3,0x20
 2ec:	0685                	addi	a3,a3,1
 2ee:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2f0:	00054783          	lbu	a5,0(a0)
 2f4:	0005c703          	lbu	a4,0(a1)
 2f8:	00e79863          	bne	a5,a4,308 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2fc:	0505                	addi	a0,a0,1
    p2++;
 2fe:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 300:	fed518e3          	bne	a0,a3,2f0 <memcmp+0x14>
  }
  return 0;
 304:	4501                	li	a0,0
 306:	a019                	j	30c <memcmp+0x30>
      return *p1 - *p2;
 308:	40e7853b          	subw	a0,a5,a4
}
 30c:	6422                	ld	s0,8(sp)
 30e:	0141                	addi	sp,sp,16
 310:	8082                	ret
  return 0;
 312:	4501                	li	a0,0
 314:	bfe5                	j	30c <memcmp+0x30>

0000000000000316 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 316:	1141                	addi	sp,sp,-16
 318:	e406                	sd	ra,8(sp)
 31a:	e022                	sd	s0,0(sp)
 31c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 31e:	00000097          	auipc	ra,0x0
 322:	f62080e7          	jalr	-158(ra) # 280 <memmove>
}
 326:	60a2                	ld	ra,8(sp)
 328:	6402                	ld	s0,0(sp)
 32a:	0141                	addi	sp,sp,16
 32c:	8082                	ret

000000000000032e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 32e:	4885                	li	a7,1
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <exit>:
.global exit
exit:
 li a7, SYS_exit
 336:	4889                	li	a7,2
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <wait>:
.global wait
wait:
 li a7, SYS_wait
 33e:	488d                	li	a7,3
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 346:	4891                	li	a7,4
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <read>:
.global read
read:
 li a7, SYS_read
 34e:	4895                	li	a7,5
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <write>:
.global write
write:
 li a7, SYS_write
 356:	48c1                	li	a7,16
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <close>:
.global close
close:
 li a7, SYS_close
 35e:	48d5                	li	a7,21
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <kill>:
.global kill
kill:
 li a7, SYS_kill
 366:	4899                	li	a7,6
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <exec>:
.global exec
exec:
 li a7, SYS_exec
 36e:	489d                	li	a7,7
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <open>:
.global open
open:
 li a7, SYS_open
 376:	48bd                	li	a7,15
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 37e:	48c5                	li	a7,17
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 386:	48c9                	li	a7,18
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 38e:	48a1                	li	a7,8
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <link>:
.global link
link:
 li a7, SYS_link
 396:	48cd                	li	a7,19
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 39e:	48d1                	li	a7,20
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3a6:	48a5                	li	a7,9
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <dup>:
.global dup
dup:
 li a7, SYS_dup
 3ae:	48a9                	li	a7,10
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3b6:	48ad                	li	a7,11
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3be:	48b1                	li	a7,12
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3c6:	48b5                	li	a7,13
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3ce:	48b9                	li	a7,14
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <trace>:
.global trace
trace:
 li a7, SYS_trace
 3d6:	48d9                	li	a7,22
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 3de:	48dd                	li	a7,23
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3e6:	1101                	addi	sp,sp,-32
 3e8:	ec06                	sd	ra,24(sp)
 3ea:	e822                	sd	s0,16(sp)
 3ec:	1000                	addi	s0,sp,32
 3ee:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3f2:	4605                	li	a2,1
 3f4:	fef40593          	addi	a1,s0,-17
 3f8:	00000097          	auipc	ra,0x0
 3fc:	f5e080e7          	jalr	-162(ra) # 356 <write>
}
 400:	60e2                	ld	ra,24(sp)
 402:	6442                	ld	s0,16(sp)
 404:	6105                	addi	sp,sp,32
 406:	8082                	ret

0000000000000408 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 408:	7139                	addi	sp,sp,-64
 40a:	fc06                	sd	ra,56(sp)
 40c:	f822                	sd	s0,48(sp)
 40e:	f426                	sd	s1,40(sp)
 410:	f04a                	sd	s2,32(sp)
 412:	ec4e                	sd	s3,24(sp)
 414:	0080                	addi	s0,sp,64
 416:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 418:	c299                	beqz	a3,41e <printint+0x16>
 41a:	0805c863          	bltz	a1,4aa <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 41e:	2581                	sext.w	a1,a1
  neg = 0;
 420:	4881                	li	a7,0
 422:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 426:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 428:	2601                	sext.w	a2,a2
 42a:	00000517          	auipc	a0,0x0
 42e:	46e50513          	addi	a0,a0,1134 # 898 <digits>
 432:	883a                	mv	a6,a4
 434:	2705                	addiw	a4,a4,1
 436:	02c5f7bb          	remuw	a5,a1,a2
 43a:	1782                	slli	a5,a5,0x20
 43c:	9381                	srli	a5,a5,0x20
 43e:	97aa                	add	a5,a5,a0
 440:	0007c783          	lbu	a5,0(a5)
 444:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 448:	0005879b          	sext.w	a5,a1
 44c:	02c5d5bb          	divuw	a1,a1,a2
 450:	0685                	addi	a3,a3,1
 452:	fec7f0e3          	bgeu	a5,a2,432 <printint+0x2a>
  if(neg)
 456:	00088b63          	beqz	a7,46c <printint+0x64>
    buf[i++] = '-';
 45a:	fd040793          	addi	a5,s0,-48
 45e:	973e                	add	a4,a4,a5
 460:	02d00793          	li	a5,45
 464:	fef70823          	sb	a5,-16(a4)
 468:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 46c:	02e05863          	blez	a4,49c <printint+0x94>
 470:	fc040793          	addi	a5,s0,-64
 474:	00e78933          	add	s2,a5,a4
 478:	fff78993          	addi	s3,a5,-1
 47c:	99ba                	add	s3,s3,a4
 47e:	377d                	addiw	a4,a4,-1
 480:	1702                	slli	a4,a4,0x20
 482:	9301                	srli	a4,a4,0x20
 484:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 488:	fff94583          	lbu	a1,-1(s2)
 48c:	8526                	mv	a0,s1
 48e:	00000097          	auipc	ra,0x0
 492:	f58080e7          	jalr	-168(ra) # 3e6 <putc>
  while(--i >= 0)
 496:	197d                	addi	s2,s2,-1
 498:	ff3918e3          	bne	s2,s3,488 <printint+0x80>
}
 49c:	70e2                	ld	ra,56(sp)
 49e:	7442                	ld	s0,48(sp)
 4a0:	74a2                	ld	s1,40(sp)
 4a2:	7902                	ld	s2,32(sp)
 4a4:	69e2                	ld	s3,24(sp)
 4a6:	6121                	addi	sp,sp,64
 4a8:	8082                	ret
    x = -xx;
 4aa:	40b005bb          	negw	a1,a1
    neg = 1;
 4ae:	4885                	li	a7,1
    x = -xx;
 4b0:	bf8d                	j	422 <printint+0x1a>

00000000000004b2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4b2:	7119                	addi	sp,sp,-128
 4b4:	fc86                	sd	ra,120(sp)
 4b6:	f8a2                	sd	s0,112(sp)
 4b8:	f4a6                	sd	s1,104(sp)
 4ba:	f0ca                	sd	s2,96(sp)
 4bc:	ecce                	sd	s3,88(sp)
 4be:	e8d2                	sd	s4,80(sp)
 4c0:	e4d6                	sd	s5,72(sp)
 4c2:	e0da                	sd	s6,64(sp)
 4c4:	fc5e                	sd	s7,56(sp)
 4c6:	f862                	sd	s8,48(sp)
 4c8:	f466                	sd	s9,40(sp)
 4ca:	f06a                	sd	s10,32(sp)
 4cc:	ec6e                	sd	s11,24(sp)
 4ce:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4d0:	0005c903          	lbu	s2,0(a1)
 4d4:	18090f63          	beqz	s2,672 <vprintf+0x1c0>
 4d8:	8aaa                	mv	s5,a0
 4da:	8b32                	mv	s6,a2
 4dc:	00158493          	addi	s1,a1,1
  state = 0;
 4e0:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4e2:	02500a13          	li	s4,37
      if(c == 'd'){
 4e6:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 4ea:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 4ee:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 4f2:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4f6:	00000b97          	auipc	s7,0x0
 4fa:	3a2b8b93          	addi	s7,s7,930 # 898 <digits>
 4fe:	a839                	j	51c <vprintf+0x6a>
        putc(fd, c);
 500:	85ca                	mv	a1,s2
 502:	8556                	mv	a0,s5
 504:	00000097          	auipc	ra,0x0
 508:	ee2080e7          	jalr	-286(ra) # 3e6 <putc>
 50c:	a019                	j	512 <vprintf+0x60>
    } else if(state == '%'){
 50e:	01498f63          	beq	s3,s4,52c <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 512:	0485                	addi	s1,s1,1
 514:	fff4c903          	lbu	s2,-1(s1)
 518:	14090d63          	beqz	s2,672 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 51c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 520:	fe0997e3          	bnez	s3,50e <vprintf+0x5c>
      if(c == '%'){
 524:	fd479ee3          	bne	a5,s4,500 <vprintf+0x4e>
        state = '%';
 528:	89be                	mv	s3,a5
 52a:	b7e5                	j	512 <vprintf+0x60>
      if(c == 'd'){
 52c:	05878063          	beq	a5,s8,56c <vprintf+0xba>
      } else if(c == 'l') {
 530:	05978c63          	beq	a5,s9,588 <vprintf+0xd6>
      } else if(c == 'x') {
 534:	07a78863          	beq	a5,s10,5a4 <vprintf+0xf2>
      } else if(c == 'p') {
 538:	09b78463          	beq	a5,s11,5c0 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 53c:	07300713          	li	a4,115
 540:	0ce78663          	beq	a5,a4,60c <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 544:	06300713          	li	a4,99
 548:	0ee78e63          	beq	a5,a4,644 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 54c:	11478863          	beq	a5,s4,65c <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 550:	85d2                	mv	a1,s4
 552:	8556                	mv	a0,s5
 554:	00000097          	auipc	ra,0x0
 558:	e92080e7          	jalr	-366(ra) # 3e6 <putc>
        putc(fd, c);
 55c:	85ca                	mv	a1,s2
 55e:	8556                	mv	a0,s5
 560:	00000097          	auipc	ra,0x0
 564:	e86080e7          	jalr	-378(ra) # 3e6 <putc>
      }
      state = 0;
 568:	4981                	li	s3,0
 56a:	b765                	j	512 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 56c:	008b0913          	addi	s2,s6,8
 570:	4685                	li	a3,1
 572:	4629                	li	a2,10
 574:	000b2583          	lw	a1,0(s6)
 578:	8556                	mv	a0,s5
 57a:	00000097          	auipc	ra,0x0
 57e:	e8e080e7          	jalr	-370(ra) # 408 <printint>
 582:	8b4a                	mv	s6,s2
      state = 0;
 584:	4981                	li	s3,0
 586:	b771                	j	512 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 588:	008b0913          	addi	s2,s6,8
 58c:	4681                	li	a3,0
 58e:	4629                	li	a2,10
 590:	000b2583          	lw	a1,0(s6)
 594:	8556                	mv	a0,s5
 596:	00000097          	auipc	ra,0x0
 59a:	e72080e7          	jalr	-398(ra) # 408 <printint>
 59e:	8b4a                	mv	s6,s2
      state = 0;
 5a0:	4981                	li	s3,0
 5a2:	bf85                	j	512 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5a4:	008b0913          	addi	s2,s6,8
 5a8:	4681                	li	a3,0
 5aa:	4641                	li	a2,16
 5ac:	000b2583          	lw	a1,0(s6)
 5b0:	8556                	mv	a0,s5
 5b2:	00000097          	auipc	ra,0x0
 5b6:	e56080e7          	jalr	-426(ra) # 408 <printint>
 5ba:	8b4a                	mv	s6,s2
      state = 0;
 5bc:	4981                	li	s3,0
 5be:	bf91                	j	512 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5c0:	008b0793          	addi	a5,s6,8
 5c4:	f8f43423          	sd	a5,-120(s0)
 5c8:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5cc:	03000593          	li	a1,48
 5d0:	8556                	mv	a0,s5
 5d2:	00000097          	auipc	ra,0x0
 5d6:	e14080e7          	jalr	-492(ra) # 3e6 <putc>
  putc(fd, 'x');
 5da:	85ea                	mv	a1,s10
 5dc:	8556                	mv	a0,s5
 5de:	00000097          	auipc	ra,0x0
 5e2:	e08080e7          	jalr	-504(ra) # 3e6 <putc>
 5e6:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5e8:	03c9d793          	srli	a5,s3,0x3c
 5ec:	97de                	add	a5,a5,s7
 5ee:	0007c583          	lbu	a1,0(a5)
 5f2:	8556                	mv	a0,s5
 5f4:	00000097          	auipc	ra,0x0
 5f8:	df2080e7          	jalr	-526(ra) # 3e6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5fc:	0992                	slli	s3,s3,0x4
 5fe:	397d                	addiw	s2,s2,-1
 600:	fe0914e3          	bnez	s2,5e8 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 604:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 608:	4981                	li	s3,0
 60a:	b721                	j	512 <vprintf+0x60>
        s = va_arg(ap, char*);
 60c:	008b0993          	addi	s3,s6,8
 610:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 614:	02090163          	beqz	s2,636 <vprintf+0x184>
        while(*s != 0){
 618:	00094583          	lbu	a1,0(s2)
 61c:	c9a1                	beqz	a1,66c <vprintf+0x1ba>
          putc(fd, *s);
 61e:	8556                	mv	a0,s5
 620:	00000097          	auipc	ra,0x0
 624:	dc6080e7          	jalr	-570(ra) # 3e6 <putc>
          s++;
 628:	0905                	addi	s2,s2,1
        while(*s != 0){
 62a:	00094583          	lbu	a1,0(s2)
 62e:	f9e5                	bnez	a1,61e <vprintf+0x16c>
        s = va_arg(ap, char*);
 630:	8b4e                	mv	s6,s3
      state = 0;
 632:	4981                	li	s3,0
 634:	bdf9                	j	512 <vprintf+0x60>
          s = "(null)";
 636:	00000917          	auipc	s2,0x0
 63a:	25a90913          	addi	s2,s2,602 # 890 <malloc+0x114>
        while(*s != 0){
 63e:	02800593          	li	a1,40
 642:	bff1                	j	61e <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 644:	008b0913          	addi	s2,s6,8
 648:	000b4583          	lbu	a1,0(s6)
 64c:	8556                	mv	a0,s5
 64e:	00000097          	auipc	ra,0x0
 652:	d98080e7          	jalr	-616(ra) # 3e6 <putc>
 656:	8b4a                	mv	s6,s2
      state = 0;
 658:	4981                	li	s3,0
 65a:	bd65                	j	512 <vprintf+0x60>
        putc(fd, c);
 65c:	85d2                	mv	a1,s4
 65e:	8556                	mv	a0,s5
 660:	00000097          	auipc	ra,0x0
 664:	d86080e7          	jalr	-634(ra) # 3e6 <putc>
      state = 0;
 668:	4981                	li	s3,0
 66a:	b565                	j	512 <vprintf+0x60>
        s = va_arg(ap, char*);
 66c:	8b4e                	mv	s6,s3
      state = 0;
 66e:	4981                	li	s3,0
 670:	b54d                	j	512 <vprintf+0x60>
    }
  }
}
 672:	70e6                	ld	ra,120(sp)
 674:	7446                	ld	s0,112(sp)
 676:	74a6                	ld	s1,104(sp)
 678:	7906                	ld	s2,96(sp)
 67a:	69e6                	ld	s3,88(sp)
 67c:	6a46                	ld	s4,80(sp)
 67e:	6aa6                	ld	s5,72(sp)
 680:	6b06                	ld	s6,64(sp)
 682:	7be2                	ld	s7,56(sp)
 684:	7c42                	ld	s8,48(sp)
 686:	7ca2                	ld	s9,40(sp)
 688:	7d02                	ld	s10,32(sp)
 68a:	6de2                	ld	s11,24(sp)
 68c:	6109                	addi	sp,sp,128
 68e:	8082                	ret

0000000000000690 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 690:	715d                	addi	sp,sp,-80
 692:	ec06                	sd	ra,24(sp)
 694:	e822                	sd	s0,16(sp)
 696:	1000                	addi	s0,sp,32
 698:	e010                	sd	a2,0(s0)
 69a:	e414                	sd	a3,8(s0)
 69c:	e818                	sd	a4,16(s0)
 69e:	ec1c                	sd	a5,24(s0)
 6a0:	03043023          	sd	a6,32(s0)
 6a4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6a8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6ac:	8622                	mv	a2,s0
 6ae:	00000097          	auipc	ra,0x0
 6b2:	e04080e7          	jalr	-508(ra) # 4b2 <vprintf>
}
 6b6:	60e2                	ld	ra,24(sp)
 6b8:	6442                	ld	s0,16(sp)
 6ba:	6161                	addi	sp,sp,80
 6bc:	8082                	ret

00000000000006be <printf>:

void
printf(const char *fmt, ...)
{
 6be:	711d                	addi	sp,sp,-96
 6c0:	ec06                	sd	ra,24(sp)
 6c2:	e822                	sd	s0,16(sp)
 6c4:	1000                	addi	s0,sp,32
 6c6:	e40c                	sd	a1,8(s0)
 6c8:	e810                	sd	a2,16(s0)
 6ca:	ec14                	sd	a3,24(s0)
 6cc:	f018                	sd	a4,32(s0)
 6ce:	f41c                	sd	a5,40(s0)
 6d0:	03043823          	sd	a6,48(s0)
 6d4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6d8:	00840613          	addi	a2,s0,8
 6dc:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6e0:	85aa                	mv	a1,a0
 6e2:	4505                	li	a0,1
 6e4:	00000097          	auipc	ra,0x0
 6e8:	dce080e7          	jalr	-562(ra) # 4b2 <vprintf>
}
 6ec:	60e2                	ld	ra,24(sp)
 6ee:	6442                	ld	s0,16(sp)
 6f0:	6125                	addi	sp,sp,96
 6f2:	8082                	ret

00000000000006f4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6f4:	1141                	addi	sp,sp,-16
 6f6:	e422                	sd	s0,8(sp)
 6f8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6fa:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6fe:	00000797          	auipc	a5,0x0
 702:	1b27b783          	ld	a5,434(a5) # 8b0 <freep>
 706:	a805                	j	736 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 708:	4618                	lw	a4,8(a2)
 70a:	9db9                	addw	a1,a1,a4
 70c:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 710:	6398                	ld	a4,0(a5)
 712:	6318                	ld	a4,0(a4)
 714:	fee53823          	sd	a4,-16(a0)
 718:	a091                	j	75c <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 71a:	ff852703          	lw	a4,-8(a0)
 71e:	9e39                	addw	a2,a2,a4
 720:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 722:	ff053703          	ld	a4,-16(a0)
 726:	e398                	sd	a4,0(a5)
 728:	a099                	j	76e <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 72a:	6398                	ld	a4,0(a5)
 72c:	00e7e463          	bltu	a5,a4,734 <free+0x40>
 730:	00e6ea63          	bltu	a3,a4,744 <free+0x50>
{
 734:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 736:	fed7fae3          	bgeu	a5,a3,72a <free+0x36>
 73a:	6398                	ld	a4,0(a5)
 73c:	00e6e463          	bltu	a3,a4,744 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 740:	fee7eae3          	bltu	a5,a4,734 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 744:	ff852583          	lw	a1,-8(a0)
 748:	6390                	ld	a2,0(a5)
 74a:	02059713          	slli	a4,a1,0x20
 74e:	9301                	srli	a4,a4,0x20
 750:	0712                	slli	a4,a4,0x4
 752:	9736                	add	a4,a4,a3
 754:	fae60ae3          	beq	a2,a4,708 <free+0x14>
    bp->s.ptr = p->s.ptr;
 758:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 75c:	4790                	lw	a2,8(a5)
 75e:	02061713          	slli	a4,a2,0x20
 762:	9301                	srli	a4,a4,0x20
 764:	0712                	slli	a4,a4,0x4
 766:	973e                	add	a4,a4,a5
 768:	fae689e3          	beq	a3,a4,71a <free+0x26>
  } else
    p->s.ptr = bp;
 76c:	e394                	sd	a3,0(a5)
  freep = p;
 76e:	00000717          	auipc	a4,0x0
 772:	14f73123          	sd	a5,322(a4) # 8b0 <freep>
}
 776:	6422                	ld	s0,8(sp)
 778:	0141                	addi	sp,sp,16
 77a:	8082                	ret

000000000000077c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 77c:	7139                	addi	sp,sp,-64
 77e:	fc06                	sd	ra,56(sp)
 780:	f822                	sd	s0,48(sp)
 782:	f426                	sd	s1,40(sp)
 784:	f04a                	sd	s2,32(sp)
 786:	ec4e                	sd	s3,24(sp)
 788:	e852                	sd	s4,16(sp)
 78a:	e456                	sd	s5,8(sp)
 78c:	e05a                	sd	s6,0(sp)
 78e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 790:	02051493          	slli	s1,a0,0x20
 794:	9081                	srli	s1,s1,0x20
 796:	04bd                	addi	s1,s1,15
 798:	8091                	srli	s1,s1,0x4
 79a:	0014899b          	addiw	s3,s1,1
 79e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7a0:	00000517          	auipc	a0,0x0
 7a4:	11053503          	ld	a0,272(a0) # 8b0 <freep>
 7a8:	c515                	beqz	a0,7d4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7aa:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7ac:	4798                	lw	a4,8(a5)
 7ae:	02977f63          	bgeu	a4,s1,7ec <malloc+0x70>
 7b2:	8a4e                	mv	s4,s3
 7b4:	0009871b          	sext.w	a4,s3
 7b8:	6685                	lui	a3,0x1
 7ba:	00d77363          	bgeu	a4,a3,7c0 <malloc+0x44>
 7be:	6a05                	lui	s4,0x1
 7c0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7c4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7c8:	00000917          	auipc	s2,0x0
 7cc:	0e890913          	addi	s2,s2,232 # 8b0 <freep>
  if(p == (char*)-1)
 7d0:	5afd                	li	s5,-1
 7d2:	a88d                	j	844 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 7d4:	00000797          	auipc	a5,0x0
 7d8:	0e478793          	addi	a5,a5,228 # 8b8 <base>
 7dc:	00000717          	auipc	a4,0x0
 7e0:	0cf73a23          	sd	a5,212(a4) # 8b0 <freep>
 7e4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7e6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7ea:	b7e1                	j	7b2 <malloc+0x36>
      if(p->s.size == nunits)
 7ec:	02e48b63          	beq	s1,a4,822 <malloc+0xa6>
        p->s.size -= nunits;
 7f0:	4137073b          	subw	a4,a4,s3
 7f4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7f6:	1702                	slli	a4,a4,0x20
 7f8:	9301                	srli	a4,a4,0x20
 7fa:	0712                	slli	a4,a4,0x4
 7fc:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7fe:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 802:	00000717          	auipc	a4,0x0
 806:	0aa73723          	sd	a0,174(a4) # 8b0 <freep>
      return (void*)(p + 1);
 80a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 80e:	70e2                	ld	ra,56(sp)
 810:	7442                	ld	s0,48(sp)
 812:	74a2                	ld	s1,40(sp)
 814:	7902                	ld	s2,32(sp)
 816:	69e2                	ld	s3,24(sp)
 818:	6a42                	ld	s4,16(sp)
 81a:	6aa2                	ld	s5,8(sp)
 81c:	6b02                	ld	s6,0(sp)
 81e:	6121                	addi	sp,sp,64
 820:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 822:	6398                	ld	a4,0(a5)
 824:	e118                	sd	a4,0(a0)
 826:	bff1                	j	802 <malloc+0x86>
  hp->s.size = nu;
 828:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 82c:	0541                	addi	a0,a0,16
 82e:	00000097          	auipc	ra,0x0
 832:	ec6080e7          	jalr	-314(ra) # 6f4 <free>
  return freep;
 836:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 83a:	d971                	beqz	a0,80e <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 83c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 83e:	4798                	lw	a4,8(a5)
 840:	fa9776e3          	bgeu	a4,s1,7ec <malloc+0x70>
    if(p == freep)
 844:	00093703          	ld	a4,0(s2)
 848:	853e                	mv	a0,a5
 84a:	fef719e3          	bne	a4,a5,83c <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 84e:	8552                	mv	a0,s4
 850:	00000097          	auipc	ra,0x0
 854:	b6e080e7          	jalr	-1170(ra) # 3be <sbrk>
  if(p == (char*)-1)
 858:	fd5518e3          	bne	a0,s5,828 <malloc+0xac>
        return 0;
 85c:	4501                	li	a0,0
 85e:	bf45                	j	80e <malloc+0x92>
