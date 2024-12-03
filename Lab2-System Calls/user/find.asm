
user/_find:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <find>:
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

// 递归查找函数，查找路径为 path 的目录下是否有目标文件 target
void find(char* path, char* target) {
   0:	d8010113          	addi	sp,sp,-640
   4:	26113c23          	sd	ra,632(sp)
   8:	26813823          	sd	s0,624(sp)
   c:	26913423          	sd	s1,616(sp)
  10:	27213023          	sd	s2,608(sp)
  14:	25313c23          	sd	s3,600(sp)
  18:	25413823          	sd	s4,592(sp)
  1c:	25513423          	sd	s5,584(sp)
  20:	25613023          	sd	s6,576(sp)
  24:	23713c23          	sd	s7,568(sp)
  28:	0500                	addi	s0,sp,640
  2a:	892a                	mv	s2,a0
  2c:	89ae                	mv	s3,a1
	char buf[512], *p;
	int fd;
	struct dirent de;
	struct stat st;
    // 打开目录
	if((fd = open(path, 0)) < 0){
  2e:	4581                	li	a1,0
  30:	00000097          	auipc	ra,0x0
  34:	50a080e7          	jalr	1290(ra) # 53a <open>
  38:	08054963          	bltz	a0,ca <find+0xca>
  3c:	84aa                	mv	s1,a0
		fprintf(2, "find: cannot open %s\n", path);
		return;
	}
    // 获取目录的状态信息
	if(fstat(fd, &st) < 0){
  3e:	d8840593          	addi	a1,s0,-632
  42:	00000097          	auipc	ra,0x0
  46:	510080e7          	jalr	1296(ra) # 552 <fstat>
  4a:	08054b63          	bltz	a0,e0 <find+0xe0>
		fprintf(2, "find: cannot stat %s\n", path);
		close(fd);
		return;
	}
    // 文件、目录分别处理
    switch (st.type) {
  4e:	d9041783          	lh	a5,-624(s0)
  52:	0007869b          	sext.w	a3,a5
  56:	4705                	li	a4,1
  58:	0ae68e63          	beq	a3,a4,114 <find+0x114>
  5c:	4709                	li	a4,2
  5e:	02e69c63          	bne	a3,a4,96 <find+0x96>
    // 如果是文件，检查文件名是否与目标文件名匹配
    case T_FILE:
		if(strcmp(path+strlen(path)-strlen(target), target) == 0) {
  62:	854a                	mv	a0,s2
  64:	00000097          	auipc	ra,0x0
  68:	268080e7          	jalr	616(ra) # 2cc <strlen>
  6c:	00050a1b          	sext.w	s4,a0
  70:	854e                	mv	a0,s3
  72:	00000097          	auipc	ra,0x0
  76:	25a080e7          	jalr	602(ra) # 2cc <strlen>
  7a:	1a02                	slli	s4,s4,0x20
  7c:	020a5a13          	srli	s4,s4,0x20
  80:	1502                	slli	a0,a0,0x20
  82:	9101                	srli	a0,a0,0x20
  84:	40aa0533          	sub	a0,s4,a0
  88:	85ce                	mv	a1,s3
  8a:	954a                	add	a0,a0,s2
  8c:	00000097          	auipc	ra,0x0
  90:	214080e7          	jalr	532(ra) # 2a0 <strcmp>
  94:	c535                	beqz	a0,100 <find+0x100>
				find(buf, target);      // 递归查找子目录
			}
		}
		break;
	}
	close(fd);      // 关闭目录
  96:	8526                	mv	a0,s1
  98:	00000097          	auipc	ra,0x0
  9c:	48a080e7          	jalr	1162(ra) # 522 <close>
}
  a0:	27813083          	ld	ra,632(sp)
  a4:	27013403          	ld	s0,624(sp)
  a8:	26813483          	ld	s1,616(sp)
  ac:	26013903          	ld	s2,608(sp)
  b0:	25813983          	ld	s3,600(sp)
  b4:	25013a03          	ld	s4,592(sp)
  b8:	24813a83          	ld	s5,584(sp)
  bc:	24013b03          	ld	s6,576(sp)
  c0:	23813b83          	ld	s7,568(sp)
  c4:	28010113          	addi	sp,sp,640
  c8:	8082                	ret
		fprintf(2, "find: cannot open %s\n", path);
  ca:	864a                	mv	a2,s2
  cc:	00001597          	auipc	a1,0x1
  d0:	94c58593          	addi	a1,a1,-1716 # a18 <malloc+0xe8>
  d4:	4509                	li	a0,2
  d6:	00000097          	auipc	ra,0x0
  da:	76e080e7          	jalr	1902(ra) # 844 <fprintf>
		return;
  de:	b7c9                	j	a0 <find+0xa0>
		fprintf(2, "find: cannot stat %s\n", path);
  e0:	864a                	mv	a2,s2
  e2:	00001597          	auipc	a1,0x1
  e6:	94e58593          	addi	a1,a1,-1714 # a30 <malloc+0x100>
  ea:	4509                	li	a0,2
  ec:	00000097          	auipc	ra,0x0
  f0:	758080e7          	jalr	1880(ra) # 844 <fprintf>
		close(fd);
  f4:	8526                	mv	a0,s1
  f6:	00000097          	auipc	ra,0x0
  fa:	42c080e7          	jalr	1068(ra) # 522 <close>
		return;
  fe:	b74d                	j	a0 <find+0xa0>
			printf("%s\n", path);
 100:	85ca                	mv	a1,s2
 102:	00001517          	auipc	a0,0x1
 106:	94650513          	addi	a0,a0,-1722 # a48 <malloc+0x118>
 10a:	00000097          	auipc	ra,0x0
 10e:	768080e7          	jalr	1896(ra) # 872 <printf>
 112:	b751                	j	96 <find+0x96>
        if (strlen(path) + 1 + DIRSIZ + 1 > sizeof buf) {
 114:	854a                	mv	a0,s2
 116:	00000097          	auipc	ra,0x0
 11a:	1b6080e7          	jalr	438(ra) # 2cc <strlen>
 11e:	2541                	addiw	a0,a0,16
 120:	20000793          	li	a5,512
 124:	00a7fb63          	bgeu	a5,a0,13a <find+0x13a>
			printf("find: path too long\n");
 128:	00001517          	auipc	a0,0x1
 12c:	92850513          	addi	a0,a0,-1752 # a50 <malloc+0x120>
 130:	00000097          	auipc	ra,0x0
 134:	742080e7          	jalr	1858(ra) # 872 <printf>
			break;
 138:	bfb9                	j	96 <find+0x96>
		strcpy(buf, path);
 13a:	85ca                	mv	a1,s2
 13c:	db040513          	addi	a0,s0,-592
 140:	00000097          	auipc	ra,0x0
 144:	144080e7          	jalr	324(ra) # 284 <strcpy>
		p = buf+strlen(buf);
 148:	db040513          	addi	a0,s0,-592
 14c:	00000097          	auipc	ra,0x0
 150:	180080e7          	jalr	384(ra) # 2cc <strlen>
 154:	02051913          	slli	s2,a0,0x20
 158:	02095913          	srli	s2,s2,0x20
 15c:	db040793          	addi	a5,s0,-592
 160:	993e                	add	s2,s2,a5
        *p++ = '/';
 162:	00190a13          	addi	s4,s2,1
 166:	02f00793          	li	a5,47
 16a:	00f90023          	sb	a5,0(s2)
			if(strcmp(buf+strlen(buf)-2, "/.") != 0 && strcmp(buf+strlen(buf)-3, "/..") != 0) {
 16e:	00001a97          	auipc	s5,0x1
 172:	8faa8a93          	addi	s5,s5,-1798 # a68 <malloc+0x138>
 176:	00001b97          	auipc	s7,0x1
 17a:	8fab8b93          	addi	s7,s7,-1798 # a70 <malloc+0x140>
				printf("find: cannot stat %s\n", buf);
 17e:	00001b17          	auipc	s6,0x1
 182:	8b2b0b13          	addi	s6,s6,-1870 # a30 <malloc+0x100>
        while (read(fd, &de, sizeof(de)) == sizeof(de)) {
 186:	4641                	li	a2,16
 188:	da040593          	addi	a1,s0,-608
 18c:	8526                	mv	a0,s1
 18e:	00000097          	auipc	ra,0x0
 192:	384080e7          	jalr	900(ra) # 512 <read>
 196:	47c1                	li	a5,16
 198:	eef51fe3          	bne	a0,a5,96 <find+0x96>
			if(de.inum == 0)
 19c:	da045783          	lhu	a5,-608(s0)
 1a0:	d3fd                	beqz	a5,186 <find+0x186>
			memmove(p, de.name, DIRSIZ);
 1a2:	4639                	li	a2,14
 1a4:	da240593          	addi	a1,s0,-606
 1a8:	8552                	mv	a0,s4
 1aa:	00000097          	auipc	ra,0x0
 1ae:	29a080e7          	jalr	666(ra) # 444 <memmove>
            p[DIRSIZ] = 0;
 1b2:	000907a3          	sb	zero,15(s2)
            if (stat(buf, &st) < 0) {
 1b6:	d8840593          	addi	a1,s0,-632
 1ba:	db040513          	addi	a0,s0,-592
 1be:	00000097          	auipc	ra,0x0
 1c2:	1f6080e7          	jalr	502(ra) # 3b4 <stat>
 1c6:	04054e63          	bltz	a0,222 <find+0x222>
			if(strcmp(buf+strlen(buf)-2, "/.") != 0 && strcmp(buf+strlen(buf)-3, "/..") != 0) {
 1ca:	db040513          	addi	a0,s0,-592
 1ce:	00000097          	auipc	ra,0x0
 1d2:	0fe080e7          	jalr	254(ra) # 2cc <strlen>
 1d6:	1502                	slli	a0,a0,0x20
 1d8:	9101                	srli	a0,a0,0x20
 1da:	1579                	addi	a0,a0,-2
 1dc:	85d6                	mv	a1,s5
 1de:	db040793          	addi	a5,s0,-592
 1e2:	953e                	add	a0,a0,a5
 1e4:	00000097          	auipc	ra,0x0
 1e8:	0bc080e7          	jalr	188(ra) # 2a0 <strcmp>
 1ec:	dd49                	beqz	a0,186 <find+0x186>
 1ee:	db040513          	addi	a0,s0,-592
 1f2:	00000097          	auipc	ra,0x0
 1f6:	0da080e7          	jalr	218(ra) # 2cc <strlen>
 1fa:	1502                	slli	a0,a0,0x20
 1fc:	9101                	srli	a0,a0,0x20
 1fe:	1575                	addi	a0,a0,-3
 200:	85de                	mv	a1,s7
 202:	db040793          	addi	a5,s0,-592
 206:	953e                	add	a0,a0,a5
 208:	00000097          	auipc	ra,0x0
 20c:	098080e7          	jalr	152(ra) # 2a0 <strcmp>
 210:	d93d                	beqz	a0,186 <find+0x186>
				find(buf, target);      // 递归查找子目录
 212:	85ce                	mv	a1,s3
 214:	db040513          	addi	a0,s0,-592
 218:	00000097          	auipc	ra,0x0
 21c:	de8080e7          	jalr	-536(ra) # 0 <find>
 220:	b79d                	j	186 <find+0x186>
				printf("find: cannot stat %s\n", buf);
 222:	db040593          	addi	a1,s0,-592
 226:	855a                	mv	a0,s6
 228:	00000097          	auipc	ra,0x0
 22c:	64a080e7          	jalr	1610(ra) # 872 <printf>
				continue;
 230:	bf99                	j	186 <find+0x186>

0000000000000232 <main>:

int main(int argc, char *argv[])
{
 232:	de010113          	addi	sp,sp,-544
 236:	20113c23          	sd	ra,536(sp)
 23a:	20813823          	sd	s0,528(sp)
 23e:	20913423          	sd	s1,520(sp)
 242:	1400                	addi	s0,sp,544
	if(argc < 3){                   // 如果参数不足，退出程序
 244:	4789                	li	a5,2
 246:	00a7c763          	blt	a5,a0,254 <main+0x22>
		exit(0);
 24a:	4501                	li	a0,0
 24c:	00000097          	auipc	ra,0x0
 250:	2ae080e7          	jalr	686(ra) # 4fa <exit>
 254:	84ae                	mv	s1,a1
	}
	char target[512];
	target[0] = '/';                // 为查找的文件名添加 / 在开头
 256:	02f00793          	li	a5,47
 25a:	def40023          	sb	a5,-544(s0)
	strcpy(target+1, argv[2]);      // 将目标文件名存储在 target 中
 25e:	698c                	ld	a1,16(a1)
 260:	de140513          	addi	a0,s0,-543
 264:	00000097          	auipc	ra,0x0
 268:	020080e7          	jalr	32(ra) # 284 <strcpy>
	find(argv[1], target);          // 调用查找函数
 26c:	de040593          	addi	a1,s0,-544
 270:	6488                	ld	a0,8(s1)
 272:	00000097          	auipc	ra,0x0
 276:	d8e080e7          	jalr	-626(ra) # 0 <find>
	exit(0);
 27a:	4501                	li	a0,0
 27c:	00000097          	auipc	ra,0x0
 280:	27e080e7          	jalr	638(ra) # 4fa <exit>

0000000000000284 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 284:	1141                	addi	sp,sp,-16
 286:	e422                	sd	s0,8(sp)
 288:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 28a:	87aa                	mv	a5,a0
 28c:	0585                	addi	a1,a1,1
 28e:	0785                	addi	a5,a5,1
 290:	fff5c703          	lbu	a4,-1(a1)
 294:	fee78fa3          	sb	a4,-1(a5)
 298:	fb75                	bnez	a4,28c <strcpy+0x8>
    ;
  return os;
}
 29a:	6422                	ld	s0,8(sp)
 29c:	0141                	addi	sp,sp,16
 29e:	8082                	ret

00000000000002a0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2a0:	1141                	addi	sp,sp,-16
 2a2:	e422                	sd	s0,8(sp)
 2a4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2a6:	00054783          	lbu	a5,0(a0)
 2aa:	cb91                	beqz	a5,2be <strcmp+0x1e>
 2ac:	0005c703          	lbu	a4,0(a1)
 2b0:	00f71763          	bne	a4,a5,2be <strcmp+0x1e>
    p++, q++;
 2b4:	0505                	addi	a0,a0,1
 2b6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2b8:	00054783          	lbu	a5,0(a0)
 2bc:	fbe5                	bnez	a5,2ac <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2be:	0005c503          	lbu	a0,0(a1)
}
 2c2:	40a7853b          	subw	a0,a5,a0
 2c6:	6422                	ld	s0,8(sp)
 2c8:	0141                	addi	sp,sp,16
 2ca:	8082                	ret

00000000000002cc <strlen>:

uint
strlen(const char *s)
{
 2cc:	1141                	addi	sp,sp,-16
 2ce:	e422                	sd	s0,8(sp)
 2d0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2d2:	00054783          	lbu	a5,0(a0)
 2d6:	cf91                	beqz	a5,2f2 <strlen+0x26>
 2d8:	0505                	addi	a0,a0,1
 2da:	87aa                	mv	a5,a0
 2dc:	4685                	li	a3,1
 2de:	9e89                	subw	a3,a3,a0
 2e0:	00f6853b          	addw	a0,a3,a5
 2e4:	0785                	addi	a5,a5,1
 2e6:	fff7c703          	lbu	a4,-1(a5)
 2ea:	fb7d                	bnez	a4,2e0 <strlen+0x14>
    ;
  return n;
}
 2ec:	6422                	ld	s0,8(sp)
 2ee:	0141                	addi	sp,sp,16
 2f0:	8082                	ret
  for(n = 0; s[n]; n++)
 2f2:	4501                	li	a0,0
 2f4:	bfe5                	j	2ec <strlen+0x20>

00000000000002f6 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2f6:	1141                	addi	sp,sp,-16
 2f8:	e422                	sd	s0,8(sp)
 2fa:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2fc:	ce09                	beqz	a2,316 <memset+0x20>
 2fe:	87aa                	mv	a5,a0
 300:	fff6071b          	addiw	a4,a2,-1
 304:	1702                	slli	a4,a4,0x20
 306:	9301                	srli	a4,a4,0x20
 308:	0705                	addi	a4,a4,1
 30a:	972a                	add	a4,a4,a0
    cdst[i] = c;
 30c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 310:	0785                	addi	a5,a5,1
 312:	fee79de3          	bne	a5,a4,30c <memset+0x16>
  }
  return dst;
}
 316:	6422                	ld	s0,8(sp)
 318:	0141                	addi	sp,sp,16
 31a:	8082                	ret

000000000000031c <strchr>:

char*
strchr(const char *s, char c)
{
 31c:	1141                	addi	sp,sp,-16
 31e:	e422                	sd	s0,8(sp)
 320:	0800                	addi	s0,sp,16
  for(; *s; s++)
 322:	00054783          	lbu	a5,0(a0)
 326:	cb99                	beqz	a5,33c <strchr+0x20>
    if(*s == c)
 328:	00f58763          	beq	a1,a5,336 <strchr+0x1a>
  for(; *s; s++)
 32c:	0505                	addi	a0,a0,1
 32e:	00054783          	lbu	a5,0(a0)
 332:	fbfd                	bnez	a5,328 <strchr+0xc>
      return (char*)s;
  return 0;
 334:	4501                	li	a0,0
}
 336:	6422                	ld	s0,8(sp)
 338:	0141                	addi	sp,sp,16
 33a:	8082                	ret
  return 0;
 33c:	4501                	li	a0,0
 33e:	bfe5                	j	336 <strchr+0x1a>

0000000000000340 <gets>:

char*
gets(char *buf, int max)
{
 340:	711d                	addi	sp,sp,-96
 342:	ec86                	sd	ra,88(sp)
 344:	e8a2                	sd	s0,80(sp)
 346:	e4a6                	sd	s1,72(sp)
 348:	e0ca                	sd	s2,64(sp)
 34a:	fc4e                	sd	s3,56(sp)
 34c:	f852                	sd	s4,48(sp)
 34e:	f456                	sd	s5,40(sp)
 350:	f05a                	sd	s6,32(sp)
 352:	ec5e                	sd	s7,24(sp)
 354:	1080                	addi	s0,sp,96
 356:	8baa                	mv	s7,a0
 358:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 35a:	892a                	mv	s2,a0
 35c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 35e:	4aa9                	li	s5,10
 360:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 362:	89a6                	mv	s3,s1
 364:	2485                	addiw	s1,s1,1
 366:	0344d863          	bge	s1,s4,396 <gets+0x56>
    cc = read(0, &c, 1);
 36a:	4605                	li	a2,1
 36c:	faf40593          	addi	a1,s0,-81
 370:	4501                	li	a0,0
 372:	00000097          	auipc	ra,0x0
 376:	1a0080e7          	jalr	416(ra) # 512 <read>
    if(cc < 1)
 37a:	00a05e63          	blez	a0,396 <gets+0x56>
    buf[i++] = c;
 37e:	faf44783          	lbu	a5,-81(s0)
 382:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 386:	01578763          	beq	a5,s5,394 <gets+0x54>
 38a:	0905                	addi	s2,s2,1
 38c:	fd679be3          	bne	a5,s6,362 <gets+0x22>
  for(i=0; i+1 < max; ){
 390:	89a6                	mv	s3,s1
 392:	a011                	j	396 <gets+0x56>
 394:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 396:	99de                	add	s3,s3,s7
 398:	00098023          	sb	zero,0(s3)
  return buf;
}
 39c:	855e                	mv	a0,s7
 39e:	60e6                	ld	ra,88(sp)
 3a0:	6446                	ld	s0,80(sp)
 3a2:	64a6                	ld	s1,72(sp)
 3a4:	6906                	ld	s2,64(sp)
 3a6:	79e2                	ld	s3,56(sp)
 3a8:	7a42                	ld	s4,48(sp)
 3aa:	7aa2                	ld	s5,40(sp)
 3ac:	7b02                	ld	s6,32(sp)
 3ae:	6be2                	ld	s7,24(sp)
 3b0:	6125                	addi	sp,sp,96
 3b2:	8082                	ret

00000000000003b4 <stat>:

int
stat(const char *n, struct stat *st)
{
 3b4:	1101                	addi	sp,sp,-32
 3b6:	ec06                	sd	ra,24(sp)
 3b8:	e822                	sd	s0,16(sp)
 3ba:	e426                	sd	s1,8(sp)
 3bc:	e04a                	sd	s2,0(sp)
 3be:	1000                	addi	s0,sp,32
 3c0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3c2:	4581                	li	a1,0
 3c4:	00000097          	auipc	ra,0x0
 3c8:	176080e7          	jalr	374(ra) # 53a <open>
  if(fd < 0)
 3cc:	02054563          	bltz	a0,3f6 <stat+0x42>
 3d0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3d2:	85ca                	mv	a1,s2
 3d4:	00000097          	auipc	ra,0x0
 3d8:	17e080e7          	jalr	382(ra) # 552 <fstat>
 3dc:	892a                	mv	s2,a0
  close(fd);
 3de:	8526                	mv	a0,s1
 3e0:	00000097          	auipc	ra,0x0
 3e4:	142080e7          	jalr	322(ra) # 522 <close>
  return r;
}
 3e8:	854a                	mv	a0,s2
 3ea:	60e2                	ld	ra,24(sp)
 3ec:	6442                	ld	s0,16(sp)
 3ee:	64a2                	ld	s1,8(sp)
 3f0:	6902                	ld	s2,0(sp)
 3f2:	6105                	addi	sp,sp,32
 3f4:	8082                	ret
    return -1;
 3f6:	597d                	li	s2,-1
 3f8:	bfc5                	j	3e8 <stat+0x34>

00000000000003fa <atoi>:

int
atoi(const char *s)
{
 3fa:	1141                	addi	sp,sp,-16
 3fc:	e422                	sd	s0,8(sp)
 3fe:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 400:	00054603          	lbu	a2,0(a0)
 404:	fd06079b          	addiw	a5,a2,-48
 408:	0ff7f793          	andi	a5,a5,255
 40c:	4725                	li	a4,9
 40e:	02f76963          	bltu	a4,a5,440 <atoi+0x46>
 412:	86aa                	mv	a3,a0
  n = 0;
 414:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 416:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 418:	0685                	addi	a3,a3,1
 41a:	0025179b          	slliw	a5,a0,0x2
 41e:	9fa9                	addw	a5,a5,a0
 420:	0017979b          	slliw	a5,a5,0x1
 424:	9fb1                	addw	a5,a5,a2
 426:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 42a:	0006c603          	lbu	a2,0(a3)
 42e:	fd06071b          	addiw	a4,a2,-48
 432:	0ff77713          	andi	a4,a4,255
 436:	fee5f1e3          	bgeu	a1,a4,418 <atoi+0x1e>
  return n;
}
 43a:	6422                	ld	s0,8(sp)
 43c:	0141                	addi	sp,sp,16
 43e:	8082                	ret
  n = 0;
 440:	4501                	li	a0,0
 442:	bfe5                	j	43a <atoi+0x40>

0000000000000444 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 444:	1141                	addi	sp,sp,-16
 446:	e422                	sd	s0,8(sp)
 448:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 44a:	02b57663          	bgeu	a0,a1,476 <memmove+0x32>
    while(n-- > 0)
 44e:	02c05163          	blez	a2,470 <memmove+0x2c>
 452:	fff6079b          	addiw	a5,a2,-1
 456:	1782                	slli	a5,a5,0x20
 458:	9381                	srli	a5,a5,0x20
 45a:	0785                	addi	a5,a5,1
 45c:	97aa                	add	a5,a5,a0
  dst = vdst;
 45e:	872a                	mv	a4,a0
      *dst++ = *src++;
 460:	0585                	addi	a1,a1,1
 462:	0705                	addi	a4,a4,1
 464:	fff5c683          	lbu	a3,-1(a1)
 468:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 46c:	fee79ae3          	bne	a5,a4,460 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 470:	6422                	ld	s0,8(sp)
 472:	0141                	addi	sp,sp,16
 474:	8082                	ret
    dst += n;
 476:	00c50733          	add	a4,a0,a2
    src += n;
 47a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 47c:	fec05ae3          	blez	a2,470 <memmove+0x2c>
 480:	fff6079b          	addiw	a5,a2,-1
 484:	1782                	slli	a5,a5,0x20
 486:	9381                	srli	a5,a5,0x20
 488:	fff7c793          	not	a5,a5
 48c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 48e:	15fd                	addi	a1,a1,-1
 490:	177d                	addi	a4,a4,-1
 492:	0005c683          	lbu	a3,0(a1)
 496:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 49a:	fee79ae3          	bne	a5,a4,48e <memmove+0x4a>
 49e:	bfc9                	j	470 <memmove+0x2c>

00000000000004a0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4a0:	1141                	addi	sp,sp,-16
 4a2:	e422                	sd	s0,8(sp)
 4a4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4a6:	ca05                	beqz	a2,4d6 <memcmp+0x36>
 4a8:	fff6069b          	addiw	a3,a2,-1
 4ac:	1682                	slli	a3,a3,0x20
 4ae:	9281                	srli	a3,a3,0x20
 4b0:	0685                	addi	a3,a3,1
 4b2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 4b4:	00054783          	lbu	a5,0(a0)
 4b8:	0005c703          	lbu	a4,0(a1)
 4bc:	00e79863          	bne	a5,a4,4cc <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 4c0:	0505                	addi	a0,a0,1
    p2++;
 4c2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4c4:	fed518e3          	bne	a0,a3,4b4 <memcmp+0x14>
  }
  return 0;
 4c8:	4501                	li	a0,0
 4ca:	a019                	j	4d0 <memcmp+0x30>
      return *p1 - *p2;
 4cc:	40e7853b          	subw	a0,a5,a4
}
 4d0:	6422                	ld	s0,8(sp)
 4d2:	0141                	addi	sp,sp,16
 4d4:	8082                	ret
  return 0;
 4d6:	4501                	li	a0,0
 4d8:	bfe5                	j	4d0 <memcmp+0x30>

00000000000004da <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4da:	1141                	addi	sp,sp,-16
 4dc:	e406                	sd	ra,8(sp)
 4de:	e022                	sd	s0,0(sp)
 4e0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4e2:	00000097          	auipc	ra,0x0
 4e6:	f62080e7          	jalr	-158(ra) # 444 <memmove>
}
 4ea:	60a2                	ld	ra,8(sp)
 4ec:	6402                	ld	s0,0(sp)
 4ee:	0141                	addi	sp,sp,16
 4f0:	8082                	ret

00000000000004f2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4f2:	4885                	li	a7,1
 ecall
 4f4:	00000073          	ecall
 ret
 4f8:	8082                	ret

00000000000004fa <exit>:
.global exit
exit:
 li a7, SYS_exit
 4fa:	4889                	li	a7,2
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <wait>:
.global wait
wait:
 li a7, SYS_wait
 502:	488d                	li	a7,3
 ecall
 504:	00000073          	ecall
 ret
 508:	8082                	ret

000000000000050a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 50a:	4891                	li	a7,4
 ecall
 50c:	00000073          	ecall
 ret
 510:	8082                	ret

0000000000000512 <read>:
.global read
read:
 li a7, SYS_read
 512:	4895                	li	a7,5
 ecall
 514:	00000073          	ecall
 ret
 518:	8082                	ret

000000000000051a <write>:
.global write
write:
 li a7, SYS_write
 51a:	48c1                	li	a7,16
 ecall
 51c:	00000073          	ecall
 ret
 520:	8082                	ret

0000000000000522 <close>:
.global close
close:
 li a7, SYS_close
 522:	48d5                	li	a7,21
 ecall
 524:	00000073          	ecall
 ret
 528:	8082                	ret

000000000000052a <kill>:
.global kill
kill:
 li a7, SYS_kill
 52a:	4899                	li	a7,6
 ecall
 52c:	00000073          	ecall
 ret
 530:	8082                	ret

0000000000000532 <exec>:
.global exec
exec:
 li a7, SYS_exec
 532:	489d                	li	a7,7
 ecall
 534:	00000073          	ecall
 ret
 538:	8082                	ret

000000000000053a <open>:
.global open
open:
 li a7, SYS_open
 53a:	48bd                	li	a7,15
 ecall
 53c:	00000073          	ecall
 ret
 540:	8082                	ret

0000000000000542 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 542:	48c5                	li	a7,17
 ecall
 544:	00000073          	ecall
 ret
 548:	8082                	ret

000000000000054a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 54a:	48c9                	li	a7,18
 ecall
 54c:	00000073          	ecall
 ret
 550:	8082                	ret

0000000000000552 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 552:	48a1                	li	a7,8
 ecall
 554:	00000073          	ecall
 ret
 558:	8082                	ret

000000000000055a <link>:
.global link
link:
 li a7, SYS_link
 55a:	48cd                	li	a7,19
 ecall
 55c:	00000073          	ecall
 ret
 560:	8082                	ret

0000000000000562 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 562:	48d1                	li	a7,20
 ecall
 564:	00000073          	ecall
 ret
 568:	8082                	ret

000000000000056a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 56a:	48a5                	li	a7,9
 ecall
 56c:	00000073          	ecall
 ret
 570:	8082                	ret

0000000000000572 <dup>:
.global dup
dup:
 li a7, SYS_dup
 572:	48a9                	li	a7,10
 ecall
 574:	00000073          	ecall
 ret
 578:	8082                	ret

000000000000057a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 57a:	48ad                	li	a7,11
 ecall
 57c:	00000073          	ecall
 ret
 580:	8082                	ret

0000000000000582 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 582:	48b1                	li	a7,12
 ecall
 584:	00000073          	ecall
 ret
 588:	8082                	ret

000000000000058a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 58a:	48b5                	li	a7,13
 ecall
 58c:	00000073          	ecall
 ret
 590:	8082                	ret

0000000000000592 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 592:	48b9                	li	a7,14
 ecall
 594:	00000073          	ecall
 ret
 598:	8082                	ret

000000000000059a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 59a:	1101                	addi	sp,sp,-32
 59c:	ec06                	sd	ra,24(sp)
 59e:	e822                	sd	s0,16(sp)
 5a0:	1000                	addi	s0,sp,32
 5a2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5a6:	4605                	li	a2,1
 5a8:	fef40593          	addi	a1,s0,-17
 5ac:	00000097          	auipc	ra,0x0
 5b0:	f6e080e7          	jalr	-146(ra) # 51a <write>
}
 5b4:	60e2                	ld	ra,24(sp)
 5b6:	6442                	ld	s0,16(sp)
 5b8:	6105                	addi	sp,sp,32
 5ba:	8082                	ret

00000000000005bc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5bc:	7139                	addi	sp,sp,-64
 5be:	fc06                	sd	ra,56(sp)
 5c0:	f822                	sd	s0,48(sp)
 5c2:	f426                	sd	s1,40(sp)
 5c4:	f04a                	sd	s2,32(sp)
 5c6:	ec4e                	sd	s3,24(sp)
 5c8:	0080                	addi	s0,sp,64
 5ca:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5cc:	c299                	beqz	a3,5d2 <printint+0x16>
 5ce:	0805c863          	bltz	a1,65e <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5d2:	2581                	sext.w	a1,a1
  neg = 0;
 5d4:	4881                	li	a7,0
 5d6:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5da:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5dc:	2601                	sext.w	a2,a2
 5de:	00000517          	auipc	a0,0x0
 5e2:	4a250513          	addi	a0,a0,1186 # a80 <digits>
 5e6:	883a                	mv	a6,a4
 5e8:	2705                	addiw	a4,a4,1
 5ea:	02c5f7bb          	remuw	a5,a1,a2
 5ee:	1782                	slli	a5,a5,0x20
 5f0:	9381                	srli	a5,a5,0x20
 5f2:	97aa                	add	a5,a5,a0
 5f4:	0007c783          	lbu	a5,0(a5)
 5f8:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5fc:	0005879b          	sext.w	a5,a1
 600:	02c5d5bb          	divuw	a1,a1,a2
 604:	0685                	addi	a3,a3,1
 606:	fec7f0e3          	bgeu	a5,a2,5e6 <printint+0x2a>
  if(neg)
 60a:	00088b63          	beqz	a7,620 <printint+0x64>
    buf[i++] = '-';
 60e:	fd040793          	addi	a5,s0,-48
 612:	973e                	add	a4,a4,a5
 614:	02d00793          	li	a5,45
 618:	fef70823          	sb	a5,-16(a4)
 61c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 620:	02e05863          	blez	a4,650 <printint+0x94>
 624:	fc040793          	addi	a5,s0,-64
 628:	00e78933          	add	s2,a5,a4
 62c:	fff78993          	addi	s3,a5,-1
 630:	99ba                	add	s3,s3,a4
 632:	377d                	addiw	a4,a4,-1
 634:	1702                	slli	a4,a4,0x20
 636:	9301                	srli	a4,a4,0x20
 638:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 63c:	fff94583          	lbu	a1,-1(s2)
 640:	8526                	mv	a0,s1
 642:	00000097          	auipc	ra,0x0
 646:	f58080e7          	jalr	-168(ra) # 59a <putc>
  while(--i >= 0)
 64a:	197d                	addi	s2,s2,-1
 64c:	ff3918e3          	bne	s2,s3,63c <printint+0x80>
}
 650:	70e2                	ld	ra,56(sp)
 652:	7442                	ld	s0,48(sp)
 654:	74a2                	ld	s1,40(sp)
 656:	7902                	ld	s2,32(sp)
 658:	69e2                	ld	s3,24(sp)
 65a:	6121                	addi	sp,sp,64
 65c:	8082                	ret
    x = -xx;
 65e:	40b005bb          	negw	a1,a1
    neg = 1;
 662:	4885                	li	a7,1
    x = -xx;
 664:	bf8d                	j	5d6 <printint+0x1a>

0000000000000666 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 666:	7119                	addi	sp,sp,-128
 668:	fc86                	sd	ra,120(sp)
 66a:	f8a2                	sd	s0,112(sp)
 66c:	f4a6                	sd	s1,104(sp)
 66e:	f0ca                	sd	s2,96(sp)
 670:	ecce                	sd	s3,88(sp)
 672:	e8d2                	sd	s4,80(sp)
 674:	e4d6                	sd	s5,72(sp)
 676:	e0da                	sd	s6,64(sp)
 678:	fc5e                	sd	s7,56(sp)
 67a:	f862                	sd	s8,48(sp)
 67c:	f466                	sd	s9,40(sp)
 67e:	f06a                	sd	s10,32(sp)
 680:	ec6e                	sd	s11,24(sp)
 682:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 684:	0005c903          	lbu	s2,0(a1)
 688:	18090f63          	beqz	s2,826 <vprintf+0x1c0>
 68c:	8aaa                	mv	s5,a0
 68e:	8b32                	mv	s6,a2
 690:	00158493          	addi	s1,a1,1
  state = 0;
 694:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 696:	02500a13          	li	s4,37
      if(c == 'd'){
 69a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 69e:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 6a2:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 6a6:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6aa:	00000b97          	auipc	s7,0x0
 6ae:	3d6b8b93          	addi	s7,s7,982 # a80 <digits>
 6b2:	a839                	j	6d0 <vprintf+0x6a>
        putc(fd, c);
 6b4:	85ca                	mv	a1,s2
 6b6:	8556                	mv	a0,s5
 6b8:	00000097          	auipc	ra,0x0
 6bc:	ee2080e7          	jalr	-286(ra) # 59a <putc>
 6c0:	a019                	j	6c6 <vprintf+0x60>
    } else if(state == '%'){
 6c2:	01498f63          	beq	s3,s4,6e0 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 6c6:	0485                	addi	s1,s1,1
 6c8:	fff4c903          	lbu	s2,-1(s1)
 6cc:	14090d63          	beqz	s2,826 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 6d0:	0009079b          	sext.w	a5,s2
    if(state == 0){
 6d4:	fe0997e3          	bnez	s3,6c2 <vprintf+0x5c>
      if(c == '%'){
 6d8:	fd479ee3          	bne	a5,s4,6b4 <vprintf+0x4e>
        state = '%';
 6dc:	89be                	mv	s3,a5
 6de:	b7e5                	j	6c6 <vprintf+0x60>
      if(c == 'd'){
 6e0:	05878063          	beq	a5,s8,720 <vprintf+0xba>
      } else if(c == 'l') {
 6e4:	05978c63          	beq	a5,s9,73c <vprintf+0xd6>
      } else if(c == 'x') {
 6e8:	07a78863          	beq	a5,s10,758 <vprintf+0xf2>
      } else if(c == 'p') {
 6ec:	09b78463          	beq	a5,s11,774 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 6f0:	07300713          	li	a4,115
 6f4:	0ce78663          	beq	a5,a4,7c0 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6f8:	06300713          	li	a4,99
 6fc:	0ee78e63          	beq	a5,a4,7f8 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 700:	11478863          	beq	a5,s4,810 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 704:	85d2                	mv	a1,s4
 706:	8556                	mv	a0,s5
 708:	00000097          	auipc	ra,0x0
 70c:	e92080e7          	jalr	-366(ra) # 59a <putc>
        putc(fd, c);
 710:	85ca                	mv	a1,s2
 712:	8556                	mv	a0,s5
 714:	00000097          	auipc	ra,0x0
 718:	e86080e7          	jalr	-378(ra) # 59a <putc>
      }
      state = 0;
 71c:	4981                	li	s3,0
 71e:	b765                	j	6c6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 720:	008b0913          	addi	s2,s6,8
 724:	4685                	li	a3,1
 726:	4629                	li	a2,10
 728:	000b2583          	lw	a1,0(s6)
 72c:	8556                	mv	a0,s5
 72e:	00000097          	auipc	ra,0x0
 732:	e8e080e7          	jalr	-370(ra) # 5bc <printint>
 736:	8b4a                	mv	s6,s2
      state = 0;
 738:	4981                	li	s3,0
 73a:	b771                	j	6c6 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 73c:	008b0913          	addi	s2,s6,8
 740:	4681                	li	a3,0
 742:	4629                	li	a2,10
 744:	000b2583          	lw	a1,0(s6)
 748:	8556                	mv	a0,s5
 74a:	00000097          	auipc	ra,0x0
 74e:	e72080e7          	jalr	-398(ra) # 5bc <printint>
 752:	8b4a                	mv	s6,s2
      state = 0;
 754:	4981                	li	s3,0
 756:	bf85                	j	6c6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 758:	008b0913          	addi	s2,s6,8
 75c:	4681                	li	a3,0
 75e:	4641                	li	a2,16
 760:	000b2583          	lw	a1,0(s6)
 764:	8556                	mv	a0,s5
 766:	00000097          	auipc	ra,0x0
 76a:	e56080e7          	jalr	-426(ra) # 5bc <printint>
 76e:	8b4a                	mv	s6,s2
      state = 0;
 770:	4981                	li	s3,0
 772:	bf91                	j	6c6 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 774:	008b0793          	addi	a5,s6,8
 778:	f8f43423          	sd	a5,-120(s0)
 77c:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 780:	03000593          	li	a1,48
 784:	8556                	mv	a0,s5
 786:	00000097          	auipc	ra,0x0
 78a:	e14080e7          	jalr	-492(ra) # 59a <putc>
  putc(fd, 'x');
 78e:	85ea                	mv	a1,s10
 790:	8556                	mv	a0,s5
 792:	00000097          	auipc	ra,0x0
 796:	e08080e7          	jalr	-504(ra) # 59a <putc>
 79a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 79c:	03c9d793          	srli	a5,s3,0x3c
 7a0:	97de                	add	a5,a5,s7
 7a2:	0007c583          	lbu	a1,0(a5)
 7a6:	8556                	mv	a0,s5
 7a8:	00000097          	auipc	ra,0x0
 7ac:	df2080e7          	jalr	-526(ra) # 59a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7b0:	0992                	slli	s3,s3,0x4
 7b2:	397d                	addiw	s2,s2,-1
 7b4:	fe0914e3          	bnez	s2,79c <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 7b8:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 7bc:	4981                	li	s3,0
 7be:	b721                	j	6c6 <vprintf+0x60>
        s = va_arg(ap, char*);
 7c0:	008b0993          	addi	s3,s6,8
 7c4:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 7c8:	02090163          	beqz	s2,7ea <vprintf+0x184>
        while(*s != 0){
 7cc:	00094583          	lbu	a1,0(s2)
 7d0:	c9a1                	beqz	a1,820 <vprintf+0x1ba>
          putc(fd, *s);
 7d2:	8556                	mv	a0,s5
 7d4:	00000097          	auipc	ra,0x0
 7d8:	dc6080e7          	jalr	-570(ra) # 59a <putc>
          s++;
 7dc:	0905                	addi	s2,s2,1
        while(*s != 0){
 7de:	00094583          	lbu	a1,0(s2)
 7e2:	f9e5                	bnez	a1,7d2 <vprintf+0x16c>
        s = va_arg(ap, char*);
 7e4:	8b4e                	mv	s6,s3
      state = 0;
 7e6:	4981                	li	s3,0
 7e8:	bdf9                	j	6c6 <vprintf+0x60>
          s = "(null)";
 7ea:	00000917          	auipc	s2,0x0
 7ee:	28e90913          	addi	s2,s2,654 # a78 <malloc+0x148>
        while(*s != 0){
 7f2:	02800593          	li	a1,40
 7f6:	bff1                	j	7d2 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 7f8:	008b0913          	addi	s2,s6,8
 7fc:	000b4583          	lbu	a1,0(s6)
 800:	8556                	mv	a0,s5
 802:	00000097          	auipc	ra,0x0
 806:	d98080e7          	jalr	-616(ra) # 59a <putc>
 80a:	8b4a                	mv	s6,s2
      state = 0;
 80c:	4981                	li	s3,0
 80e:	bd65                	j	6c6 <vprintf+0x60>
        putc(fd, c);
 810:	85d2                	mv	a1,s4
 812:	8556                	mv	a0,s5
 814:	00000097          	auipc	ra,0x0
 818:	d86080e7          	jalr	-634(ra) # 59a <putc>
      state = 0;
 81c:	4981                	li	s3,0
 81e:	b565                	j	6c6 <vprintf+0x60>
        s = va_arg(ap, char*);
 820:	8b4e                	mv	s6,s3
      state = 0;
 822:	4981                	li	s3,0
 824:	b54d                	j	6c6 <vprintf+0x60>
    }
  }
}
 826:	70e6                	ld	ra,120(sp)
 828:	7446                	ld	s0,112(sp)
 82a:	74a6                	ld	s1,104(sp)
 82c:	7906                	ld	s2,96(sp)
 82e:	69e6                	ld	s3,88(sp)
 830:	6a46                	ld	s4,80(sp)
 832:	6aa6                	ld	s5,72(sp)
 834:	6b06                	ld	s6,64(sp)
 836:	7be2                	ld	s7,56(sp)
 838:	7c42                	ld	s8,48(sp)
 83a:	7ca2                	ld	s9,40(sp)
 83c:	7d02                	ld	s10,32(sp)
 83e:	6de2                	ld	s11,24(sp)
 840:	6109                	addi	sp,sp,128
 842:	8082                	ret

0000000000000844 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 844:	715d                	addi	sp,sp,-80
 846:	ec06                	sd	ra,24(sp)
 848:	e822                	sd	s0,16(sp)
 84a:	1000                	addi	s0,sp,32
 84c:	e010                	sd	a2,0(s0)
 84e:	e414                	sd	a3,8(s0)
 850:	e818                	sd	a4,16(s0)
 852:	ec1c                	sd	a5,24(s0)
 854:	03043023          	sd	a6,32(s0)
 858:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 85c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 860:	8622                	mv	a2,s0
 862:	00000097          	auipc	ra,0x0
 866:	e04080e7          	jalr	-508(ra) # 666 <vprintf>
}
 86a:	60e2                	ld	ra,24(sp)
 86c:	6442                	ld	s0,16(sp)
 86e:	6161                	addi	sp,sp,80
 870:	8082                	ret

0000000000000872 <printf>:

void
printf(const char *fmt, ...)
{
 872:	711d                	addi	sp,sp,-96
 874:	ec06                	sd	ra,24(sp)
 876:	e822                	sd	s0,16(sp)
 878:	1000                	addi	s0,sp,32
 87a:	e40c                	sd	a1,8(s0)
 87c:	e810                	sd	a2,16(s0)
 87e:	ec14                	sd	a3,24(s0)
 880:	f018                	sd	a4,32(s0)
 882:	f41c                	sd	a5,40(s0)
 884:	03043823          	sd	a6,48(s0)
 888:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 88c:	00840613          	addi	a2,s0,8
 890:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 894:	85aa                	mv	a1,a0
 896:	4505                	li	a0,1
 898:	00000097          	auipc	ra,0x0
 89c:	dce080e7          	jalr	-562(ra) # 666 <vprintf>
}
 8a0:	60e2                	ld	ra,24(sp)
 8a2:	6442                	ld	s0,16(sp)
 8a4:	6125                	addi	sp,sp,96
 8a6:	8082                	ret

00000000000008a8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8a8:	1141                	addi	sp,sp,-16
 8aa:	e422                	sd	s0,8(sp)
 8ac:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8ae:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8b2:	00000797          	auipc	a5,0x0
 8b6:	1e67b783          	ld	a5,486(a5) # a98 <freep>
 8ba:	a805                	j	8ea <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8bc:	4618                	lw	a4,8(a2)
 8be:	9db9                	addw	a1,a1,a4
 8c0:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8c4:	6398                	ld	a4,0(a5)
 8c6:	6318                	ld	a4,0(a4)
 8c8:	fee53823          	sd	a4,-16(a0)
 8cc:	a091                	j	910 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8ce:	ff852703          	lw	a4,-8(a0)
 8d2:	9e39                	addw	a2,a2,a4
 8d4:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 8d6:	ff053703          	ld	a4,-16(a0)
 8da:	e398                	sd	a4,0(a5)
 8dc:	a099                	j	922 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8de:	6398                	ld	a4,0(a5)
 8e0:	00e7e463          	bltu	a5,a4,8e8 <free+0x40>
 8e4:	00e6ea63          	bltu	a3,a4,8f8 <free+0x50>
{
 8e8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ea:	fed7fae3          	bgeu	a5,a3,8de <free+0x36>
 8ee:	6398                	ld	a4,0(a5)
 8f0:	00e6e463          	bltu	a3,a4,8f8 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8f4:	fee7eae3          	bltu	a5,a4,8e8 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 8f8:	ff852583          	lw	a1,-8(a0)
 8fc:	6390                	ld	a2,0(a5)
 8fe:	02059713          	slli	a4,a1,0x20
 902:	9301                	srli	a4,a4,0x20
 904:	0712                	slli	a4,a4,0x4
 906:	9736                	add	a4,a4,a3
 908:	fae60ae3          	beq	a2,a4,8bc <free+0x14>
    bp->s.ptr = p->s.ptr;
 90c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 910:	4790                	lw	a2,8(a5)
 912:	02061713          	slli	a4,a2,0x20
 916:	9301                	srli	a4,a4,0x20
 918:	0712                	slli	a4,a4,0x4
 91a:	973e                	add	a4,a4,a5
 91c:	fae689e3          	beq	a3,a4,8ce <free+0x26>
  } else
    p->s.ptr = bp;
 920:	e394                	sd	a3,0(a5)
  freep = p;
 922:	00000717          	auipc	a4,0x0
 926:	16f73b23          	sd	a5,374(a4) # a98 <freep>
}
 92a:	6422                	ld	s0,8(sp)
 92c:	0141                	addi	sp,sp,16
 92e:	8082                	ret

0000000000000930 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 930:	7139                	addi	sp,sp,-64
 932:	fc06                	sd	ra,56(sp)
 934:	f822                	sd	s0,48(sp)
 936:	f426                	sd	s1,40(sp)
 938:	f04a                	sd	s2,32(sp)
 93a:	ec4e                	sd	s3,24(sp)
 93c:	e852                	sd	s4,16(sp)
 93e:	e456                	sd	s5,8(sp)
 940:	e05a                	sd	s6,0(sp)
 942:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 944:	02051493          	slli	s1,a0,0x20
 948:	9081                	srli	s1,s1,0x20
 94a:	04bd                	addi	s1,s1,15
 94c:	8091                	srli	s1,s1,0x4
 94e:	0014899b          	addiw	s3,s1,1
 952:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 954:	00000517          	auipc	a0,0x0
 958:	14453503          	ld	a0,324(a0) # a98 <freep>
 95c:	c515                	beqz	a0,988 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 95e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 960:	4798                	lw	a4,8(a5)
 962:	02977f63          	bgeu	a4,s1,9a0 <malloc+0x70>
 966:	8a4e                	mv	s4,s3
 968:	0009871b          	sext.w	a4,s3
 96c:	6685                	lui	a3,0x1
 96e:	00d77363          	bgeu	a4,a3,974 <malloc+0x44>
 972:	6a05                	lui	s4,0x1
 974:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 978:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 97c:	00000917          	auipc	s2,0x0
 980:	11c90913          	addi	s2,s2,284 # a98 <freep>
  if(p == (char*)-1)
 984:	5afd                	li	s5,-1
 986:	a88d                	j	9f8 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 988:	00000797          	auipc	a5,0x0
 98c:	11878793          	addi	a5,a5,280 # aa0 <base>
 990:	00000717          	auipc	a4,0x0
 994:	10f73423          	sd	a5,264(a4) # a98 <freep>
 998:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 99a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 99e:	b7e1                	j	966 <malloc+0x36>
      if(p->s.size == nunits)
 9a0:	02e48b63          	beq	s1,a4,9d6 <malloc+0xa6>
        p->s.size -= nunits;
 9a4:	4137073b          	subw	a4,a4,s3
 9a8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9aa:	1702                	slli	a4,a4,0x20
 9ac:	9301                	srli	a4,a4,0x20
 9ae:	0712                	slli	a4,a4,0x4
 9b0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9b2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9b6:	00000717          	auipc	a4,0x0
 9ba:	0ea73123          	sd	a0,226(a4) # a98 <freep>
      return (void*)(p + 1);
 9be:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 9c2:	70e2                	ld	ra,56(sp)
 9c4:	7442                	ld	s0,48(sp)
 9c6:	74a2                	ld	s1,40(sp)
 9c8:	7902                	ld	s2,32(sp)
 9ca:	69e2                	ld	s3,24(sp)
 9cc:	6a42                	ld	s4,16(sp)
 9ce:	6aa2                	ld	s5,8(sp)
 9d0:	6b02                	ld	s6,0(sp)
 9d2:	6121                	addi	sp,sp,64
 9d4:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9d6:	6398                	ld	a4,0(a5)
 9d8:	e118                	sd	a4,0(a0)
 9da:	bff1                	j	9b6 <malloc+0x86>
  hp->s.size = nu;
 9dc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9e0:	0541                	addi	a0,a0,16
 9e2:	00000097          	auipc	ra,0x0
 9e6:	ec6080e7          	jalr	-314(ra) # 8a8 <free>
  return freep;
 9ea:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9ee:	d971                	beqz	a0,9c2 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9f0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9f2:	4798                	lw	a4,8(a5)
 9f4:	fa9776e3          	bgeu	a4,s1,9a0 <malloc+0x70>
    if(p == freep)
 9f8:	00093703          	ld	a4,0(s2)
 9fc:	853e                	mv	a0,a5
 9fe:	fef719e3          	bne	a4,a5,9f0 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 a02:	8552                	mv	a0,s4
 a04:	00000097          	auipc	ra,0x0
 a08:	b7e080e7          	jalr	-1154(ra) # 582 <sbrk>
  if(p == (char*)-1)
 a0c:	fd5518e3          	bne	a0,s5,9dc <malloc+0xac>
        return 0;
 a10:	4501                	li	a0,0
 a12:	bf45                	j	9c2 <malloc+0x92>
