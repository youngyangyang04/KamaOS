
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <copyinstr1>:
}

// what if you pass ridiculous string pointers to system calls?
void
copyinstr1(char *s)
{
       0:	1141                	addi	sp,sp,-16
       2:	e406                	sd	ra,8(sp)
       4:	e022                	sd	s0,0(sp)
       6:	0800                	addi	s0,sp,16
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };

  for(int ai = 0; ai < 2; ai++){
    uint64 addr = addrs[ai];

    int fd = open((char *)addr, O_CREATE|O_WRONLY);
       8:	20100593          	li	a1,513
       c:	4505                	li	a0,1
       e:	057e                	slli	a0,a0,0x1f
      10:	00005097          	auipc	ra,0x5
      14:	3a8080e7          	jalr	936(ra) # 53b8 <open>
    if(fd >= 0){
      18:	02055063          	bgez	a0,38 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
      1c:	20100593          	li	a1,513
      20:	557d                	li	a0,-1
      22:	00005097          	auipc	ra,0x5
      26:	396080e7          	jalr	918(ra) # 53b8 <open>
    uint64 addr = addrs[ai];
      2a:	55fd                	li	a1,-1
    if(fd >= 0){
      2c:	00055863          	bgez	a0,3c <copyinstr1+0x3c>
      printf("open(%p) returned %d, not -1\n", addr, fd);
      exit(1);
    }
  }
}
      30:	60a2                	ld	ra,8(sp)
      32:	6402                	ld	s0,0(sp)
      34:	0141                	addi	sp,sp,16
      36:	8082                	ret
    uint64 addr = addrs[ai];
      38:	4585                	li	a1,1
      3a:	05fe                	slli	a1,a1,0x1f
      printf("open(%p) returned %d, not -1\n", addr, fd);
      3c:	862a                	mv	a2,a0
      3e:	00006517          	auipc	a0,0x6
      42:	b5a50513          	addi	a0,a0,-1190 # 5b98 <malloc+0x3ea>
      46:	00005097          	auipc	ra,0x5
      4a:	6aa080e7          	jalr	1706(ra) # 56f0 <printf>
      exit(1);
      4e:	4505                	li	a0,1
      50:	00005097          	auipc	ra,0x5
      54:	328080e7          	jalr	808(ra) # 5378 <exit>

0000000000000058 <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
      58:	00009797          	auipc	a5,0x9
      5c:	fd078793          	addi	a5,a5,-48 # 9028 <uninit>
      60:	0000b697          	auipc	a3,0xb
      64:	6d868693          	addi	a3,a3,1752 # b738 <buf>
    if(uninit[i] != '\0'){
      68:	0007c703          	lbu	a4,0(a5)
      6c:	e709                	bnez	a4,76 <bsstest+0x1e>
  for(i = 0; i < sizeof(uninit); i++){
      6e:	0785                	addi	a5,a5,1
      70:	fed79ce3          	bne	a5,a3,68 <bsstest+0x10>
      74:	8082                	ret
{
      76:	1141                	addi	sp,sp,-16
      78:	e406                	sd	ra,8(sp)
      7a:	e022                	sd	s0,0(sp)
      7c:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
      7e:	85aa                	mv	a1,a0
      80:	00006517          	auipc	a0,0x6
      84:	b3850513          	addi	a0,a0,-1224 # 5bb8 <malloc+0x40a>
      88:	00005097          	auipc	ra,0x5
      8c:	668080e7          	jalr	1640(ra) # 56f0 <printf>
      exit(1);
      90:	4505                	li	a0,1
      92:	00005097          	auipc	ra,0x5
      96:	2e6080e7          	jalr	742(ra) # 5378 <exit>

000000000000009a <opentest>:
{
      9a:	1101                	addi	sp,sp,-32
      9c:	ec06                	sd	ra,24(sp)
      9e:	e822                	sd	s0,16(sp)
      a0:	e426                	sd	s1,8(sp)
      a2:	1000                	addi	s0,sp,32
      a4:	84aa                	mv	s1,a0
  fd = open("echo", 0);
      a6:	4581                	li	a1,0
      a8:	00006517          	auipc	a0,0x6
      ac:	b2850513          	addi	a0,a0,-1240 # 5bd0 <malloc+0x422>
      b0:	00005097          	auipc	ra,0x5
      b4:	308080e7          	jalr	776(ra) # 53b8 <open>
  if(fd < 0){
      b8:	02054663          	bltz	a0,e4 <opentest+0x4a>
  close(fd);
      bc:	00005097          	auipc	ra,0x5
      c0:	2e4080e7          	jalr	740(ra) # 53a0 <close>
  fd = open("doesnotexist", 0);
      c4:	4581                	li	a1,0
      c6:	00006517          	auipc	a0,0x6
      ca:	b2a50513          	addi	a0,a0,-1238 # 5bf0 <malloc+0x442>
      ce:	00005097          	auipc	ra,0x5
      d2:	2ea080e7          	jalr	746(ra) # 53b8 <open>
  if(fd >= 0){
      d6:	02055563          	bgez	a0,100 <opentest+0x66>
}
      da:	60e2                	ld	ra,24(sp)
      dc:	6442                	ld	s0,16(sp)
      de:	64a2                	ld	s1,8(sp)
      e0:	6105                	addi	sp,sp,32
      e2:	8082                	ret
    printf("%s: open echo failed!\n", s);
      e4:	85a6                	mv	a1,s1
      e6:	00006517          	auipc	a0,0x6
      ea:	af250513          	addi	a0,a0,-1294 # 5bd8 <malloc+0x42a>
      ee:	00005097          	auipc	ra,0x5
      f2:	602080e7          	jalr	1538(ra) # 56f0 <printf>
    exit(1);
      f6:	4505                	li	a0,1
      f8:	00005097          	auipc	ra,0x5
      fc:	280080e7          	jalr	640(ra) # 5378 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     100:	85a6                	mv	a1,s1
     102:	00006517          	auipc	a0,0x6
     106:	afe50513          	addi	a0,a0,-1282 # 5c00 <malloc+0x452>
     10a:	00005097          	auipc	ra,0x5
     10e:	5e6080e7          	jalr	1510(ra) # 56f0 <printf>
    exit(1);
     112:	4505                	li	a0,1
     114:	00005097          	auipc	ra,0x5
     118:	264080e7          	jalr	612(ra) # 5378 <exit>

000000000000011c <truncate2>:
{
     11c:	7179                	addi	sp,sp,-48
     11e:	f406                	sd	ra,40(sp)
     120:	f022                	sd	s0,32(sp)
     122:	ec26                	sd	s1,24(sp)
     124:	e84a                	sd	s2,16(sp)
     126:	e44e                	sd	s3,8(sp)
     128:	1800                	addi	s0,sp,48
     12a:	89aa                	mv	s3,a0
  unlink("truncfile");
     12c:	00006517          	auipc	a0,0x6
     130:	afc50513          	addi	a0,a0,-1284 # 5c28 <malloc+0x47a>
     134:	00005097          	auipc	ra,0x5
     138:	294080e7          	jalr	660(ra) # 53c8 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     13c:	60100593          	li	a1,1537
     140:	00006517          	auipc	a0,0x6
     144:	ae850513          	addi	a0,a0,-1304 # 5c28 <malloc+0x47a>
     148:	00005097          	auipc	ra,0x5
     14c:	270080e7          	jalr	624(ra) # 53b8 <open>
     150:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     152:	4611                	li	a2,4
     154:	00006597          	auipc	a1,0x6
     158:	ae458593          	addi	a1,a1,-1308 # 5c38 <malloc+0x48a>
     15c:	00005097          	auipc	ra,0x5
     160:	23c080e7          	jalr	572(ra) # 5398 <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     164:	40100593          	li	a1,1025
     168:	00006517          	auipc	a0,0x6
     16c:	ac050513          	addi	a0,a0,-1344 # 5c28 <malloc+0x47a>
     170:	00005097          	auipc	ra,0x5
     174:	248080e7          	jalr	584(ra) # 53b8 <open>
     178:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     17a:	4605                	li	a2,1
     17c:	00006597          	auipc	a1,0x6
     180:	ac458593          	addi	a1,a1,-1340 # 5c40 <malloc+0x492>
     184:	8526                	mv	a0,s1
     186:	00005097          	auipc	ra,0x5
     18a:	212080e7          	jalr	530(ra) # 5398 <write>
  if(n != -1){
     18e:	57fd                	li	a5,-1
     190:	02f51b63          	bne	a0,a5,1c6 <truncate2+0xaa>
  unlink("truncfile");
     194:	00006517          	auipc	a0,0x6
     198:	a9450513          	addi	a0,a0,-1388 # 5c28 <malloc+0x47a>
     19c:	00005097          	auipc	ra,0x5
     1a0:	22c080e7          	jalr	556(ra) # 53c8 <unlink>
  close(fd1);
     1a4:	8526                	mv	a0,s1
     1a6:	00005097          	auipc	ra,0x5
     1aa:	1fa080e7          	jalr	506(ra) # 53a0 <close>
  close(fd2);
     1ae:	854a                	mv	a0,s2
     1b0:	00005097          	auipc	ra,0x5
     1b4:	1f0080e7          	jalr	496(ra) # 53a0 <close>
}
     1b8:	70a2                	ld	ra,40(sp)
     1ba:	7402                	ld	s0,32(sp)
     1bc:	64e2                	ld	s1,24(sp)
     1be:	6942                	ld	s2,16(sp)
     1c0:	69a2                	ld	s3,8(sp)
     1c2:	6145                	addi	sp,sp,48
     1c4:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     1c6:	862a                	mv	a2,a0
     1c8:	85ce                	mv	a1,s3
     1ca:	00006517          	auipc	a0,0x6
     1ce:	a7e50513          	addi	a0,a0,-1410 # 5c48 <malloc+0x49a>
     1d2:	00005097          	auipc	ra,0x5
     1d6:	51e080e7          	jalr	1310(ra) # 56f0 <printf>
    exit(1);
     1da:	4505                	li	a0,1
     1dc:	00005097          	auipc	ra,0x5
     1e0:	19c080e7          	jalr	412(ra) # 5378 <exit>

00000000000001e4 <createtest>:
{
     1e4:	7179                	addi	sp,sp,-48
     1e6:	f406                	sd	ra,40(sp)
     1e8:	f022                	sd	s0,32(sp)
     1ea:	ec26                	sd	s1,24(sp)
     1ec:	e84a                	sd	s2,16(sp)
     1ee:	e44e                	sd	s3,8(sp)
     1f0:	1800                	addi	s0,sp,48
  name[0] = 'a';
     1f2:	00008797          	auipc	a5,0x8
     1f6:	d1e78793          	addi	a5,a5,-738 # 7f10 <name>
     1fa:	06100713          	li	a4,97
     1fe:	00e78023          	sb	a4,0(a5)
  name[2] = '\0';
     202:	00078123          	sb	zero,2(a5)
     206:	03000493          	li	s1,48
    name[1] = '0' + i;
     20a:	893e                	mv	s2,a5
  for(i = 0; i < N; i++){
     20c:	06400993          	li	s3,100
    name[1] = '0' + i;
     210:	009900a3          	sb	s1,1(s2)
    fd = open(name, O_CREATE|O_RDWR);
     214:	20200593          	li	a1,514
     218:	854a                	mv	a0,s2
     21a:	00005097          	auipc	ra,0x5
     21e:	19e080e7          	jalr	414(ra) # 53b8 <open>
    close(fd);
     222:	00005097          	auipc	ra,0x5
     226:	17e080e7          	jalr	382(ra) # 53a0 <close>
  for(i = 0; i < N; i++){
     22a:	2485                	addiw	s1,s1,1
     22c:	0ff4f493          	andi	s1,s1,255
     230:	ff3490e3          	bne	s1,s3,210 <createtest+0x2c>
  name[0] = 'a';
     234:	00008797          	auipc	a5,0x8
     238:	cdc78793          	addi	a5,a5,-804 # 7f10 <name>
     23c:	06100713          	li	a4,97
     240:	00e78023          	sb	a4,0(a5)
  name[2] = '\0';
     244:	00078123          	sb	zero,2(a5)
     248:	03000493          	li	s1,48
    name[1] = '0' + i;
     24c:	893e                	mv	s2,a5
  for(i = 0; i < N; i++){
     24e:	06400993          	li	s3,100
    name[1] = '0' + i;
     252:	009900a3          	sb	s1,1(s2)
    unlink(name);
     256:	854a                	mv	a0,s2
     258:	00005097          	auipc	ra,0x5
     25c:	170080e7          	jalr	368(ra) # 53c8 <unlink>
  for(i = 0; i < N; i++){
     260:	2485                	addiw	s1,s1,1
     262:	0ff4f493          	andi	s1,s1,255
     266:	ff3496e3          	bne	s1,s3,252 <createtest+0x6e>
}
     26a:	70a2                	ld	ra,40(sp)
     26c:	7402                	ld	s0,32(sp)
     26e:	64e2                	ld	s1,24(sp)
     270:	6942                	ld	s2,16(sp)
     272:	69a2                	ld	s3,8(sp)
     274:	6145                	addi	sp,sp,48
     276:	8082                	ret

0000000000000278 <bigwrite>:
{
     278:	715d                	addi	sp,sp,-80
     27a:	e486                	sd	ra,72(sp)
     27c:	e0a2                	sd	s0,64(sp)
     27e:	fc26                	sd	s1,56(sp)
     280:	f84a                	sd	s2,48(sp)
     282:	f44e                	sd	s3,40(sp)
     284:	f052                	sd	s4,32(sp)
     286:	ec56                	sd	s5,24(sp)
     288:	e85a                	sd	s6,16(sp)
     28a:	e45e                	sd	s7,8(sp)
     28c:	0880                	addi	s0,sp,80
     28e:	8baa                	mv	s7,a0
  unlink("bigwrite");
     290:	00005517          	auipc	a0,0x5
     294:	7b850513          	addi	a0,a0,1976 # 5a48 <malloc+0x29a>
     298:	00005097          	auipc	ra,0x5
     29c:	130080e7          	jalr	304(ra) # 53c8 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2a0:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2a4:	00005a97          	auipc	s5,0x5
     2a8:	7a4a8a93          	addi	s5,s5,1956 # 5a48 <malloc+0x29a>
      int cc = write(fd, buf, sz);
     2ac:	0000ba17          	auipc	s4,0xb
     2b0:	48ca0a13          	addi	s4,s4,1164 # b738 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2b4:	6b0d                	lui	s6,0x3
     2b6:	1c9b0b13          	addi	s6,s6,457 # 31c9 <subdir+0x4ed>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2ba:	20200593          	li	a1,514
     2be:	8556                	mv	a0,s5
     2c0:	00005097          	auipc	ra,0x5
     2c4:	0f8080e7          	jalr	248(ra) # 53b8 <open>
     2c8:	892a                	mv	s2,a0
    if(fd < 0){
     2ca:	04054d63          	bltz	a0,324 <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     2ce:	8626                	mv	a2,s1
     2d0:	85d2                	mv	a1,s4
     2d2:	00005097          	auipc	ra,0x5
     2d6:	0c6080e7          	jalr	198(ra) # 5398 <write>
     2da:	89aa                	mv	s3,a0
      if(cc != sz){
     2dc:	06a49463          	bne	s1,a0,344 <bigwrite+0xcc>
      int cc = write(fd, buf, sz);
     2e0:	8626                	mv	a2,s1
     2e2:	85d2                	mv	a1,s4
     2e4:	854a                	mv	a0,s2
     2e6:	00005097          	auipc	ra,0x5
     2ea:	0b2080e7          	jalr	178(ra) # 5398 <write>
      if(cc != sz){
     2ee:	04951963          	bne	a0,s1,340 <bigwrite+0xc8>
    close(fd);
     2f2:	854a                	mv	a0,s2
     2f4:	00005097          	auipc	ra,0x5
     2f8:	0ac080e7          	jalr	172(ra) # 53a0 <close>
    unlink("bigwrite");
     2fc:	8556                	mv	a0,s5
     2fe:	00005097          	auipc	ra,0x5
     302:	0ca080e7          	jalr	202(ra) # 53c8 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     306:	1d74849b          	addiw	s1,s1,471
     30a:	fb6498e3          	bne	s1,s6,2ba <bigwrite+0x42>
}
     30e:	60a6                	ld	ra,72(sp)
     310:	6406                	ld	s0,64(sp)
     312:	74e2                	ld	s1,56(sp)
     314:	7942                	ld	s2,48(sp)
     316:	79a2                	ld	s3,40(sp)
     318:	7a02                	ld	s4,32(sp)
     31a:	6ae2                	ld	s5,24(sp)
     31c:	6b42                	ld	s6,16(sp)
     31e:	6ba2                	ld	s7,8(sp)
     320:	6161                	addi	sp,sp,80
     322:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     324:	85de                	mv	a1,s7
     326:	00006517          	auipc	a0,0x6
     32a:	94a50513          	addi	a0,a0,-1718 # 5c70 <malloc+0x4c2>
     32e:	00005097          	auipc	ra,0x5
     332:	3c2080e7          	jalr	962(ra) # 56f0 <printf>
      exit(1);
     336:	4505                	li	a0,1
     338:	00005097          	auipc	ra,0x5
     33c:	040080e7          	jalr	64(ra) # 5378 <exit>
     340:	84ce                	mv	s1,s3
      int cc = write(fd, buf, sz);
     342:	89aa                	mv	s3,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     344:	86ce                	mv	a3,s3
     346:	8626                	mv	a2,s1
     348:	85de                	mv	a1,s7
     34a:	00006517          	auipc	a0,0x6
     34e:	94650513          	addi	a0,a0,-1722 # 5c90 <malloc+0x4e2>
     352:	00005097          	auipc	ra,0x5
     356:	39e080e7          	jalr	926(ra) # 56f0 <printf>
        exit(1);
     35a:	4505                	li	a0,1
     35c:	00005097          	auipc	ra,0x5
     360:	01c080e7          	jalr	28(ra) # 5378 <exit>

0000000000000364 <copyin>:
{
     364:	715d                	addi	sp,sp,-80
     366:	e486                	sd	ra,72(sp)
     368:	e0a2                	sd	s0,64(sp)
     36a:	fc26                	sd	s1,56(sp)
     36c:	f84a                	sd	s2,48(sp)
     36e:	f44e                	sd	s3,40(sp)
     370:	f052                	sd	s4,32(sp)
     372:	0880                	addi	s0,sp,80
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     374:	4785                	li	a5,1
     376:	07fe                	slli	a5,a5,0x1f
     378:	fcf43023          	sd	a5,-64(s0)
     37c:	57fd                	li	a5,-1
     37e:	fcf43423          	sd	a5,-56(s0)
  for(int ai = 0; ai < 2; ai++){
     382:	fc040913          	addi	s2,s0,-64
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     386:	00006a17          	auipc	s4,0x6
     38a:	922a0a13          	addi	s4,s4,-1758 # 5ca8 <malloc+0x4fa>
    uint64 addr = addrs[ai];
     38e:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     392:	20100593          	li	a1,513
     396:	8552                	mv	a0,s4
     398:	00005097          	auipc	ra,0x5
     39c:	020080e7          	jalr	32(ra) # 53b8 <open>
     3a0:	84aa                	mv	s1,a0
    if(fd < 0){
     3a2:	08054863          	bltz	a0,432 <copyin+0xce>
    int n = write(fd, (void*)addr, 8192);
     3a6:	6609                	lui	a2,0x2
     3a8:	85ce                	mv	a1,s3
     3aa:	00005097          	auipc	ra,0x5
     3ae:	fee080e7          	jalr	-18(ra) # 5398 <write>
    if(n >= 0){
     3b2:	08055d63          	bgez	a0,44c <copyin+0xe8>
    close(fd);
     3b6:	8526                	mv	a0,s1
     3b8:	00005097          	auipc	ra,0x5
     3bc:	fe8080e7          	jalr	-24(ra) # 53a0 <close>
    unlink("copyin1");
     3c0:	8552                	mv	a0,s4
     3c2:	00005097          	auipc	ra,0x5
     3c6:	006080e7          	jalr	6(ra) # 53c8 <unlink>
    n = write(1, (char*)addr, 8192);
     3ca:	6609                	lui	a2,0x2
     3cc:	85ce                	mv	a1,s3
     3ce:	4505                	li	a0,1
     3d0:	00005097          	auipc	ra,0x5
     3d4:	fc8080e7          	jalr	-56(ra) # 5398 <write>
    if(n > 0){
     3d8:	08a04963          	bgtz	a0,46a <copyin+0x106>
    if(pipe(fds) < 0){
     3dc:	fb840513          	addi	a0,s0,-72
     3e0:	00005097          	auipc	ra,0x5
     3e4:	fa8080e7          	jalr	-88(ra) # 5388 <pipe>
     3e8:	0a054063          	bltz	a0,488 <copyin+0x124>
    n = write(fds[1], (char*)addr, 8192);
     3ec:	6609                	lui	a2,0x2
     3ee:	85ce                	mv	a1,s3
     3f0:	fbc42503          	lw	a0,-68(s0)
     3f4:	00005097          	auipc	ra,0x5
     3f8:	fa4080e7          	jalr	-92(ra) # 5398 <write>
    if(n > 0){
     3fc:	0aa04363          	bgtz	a0,4a2 <copyin+0x13e>
    close(fds[0]);
     400:	fb842503          	lw	a0,-72(s0)
     404:	00005097          	auipc	ra,0x5
     408:	f9c080e7          	jalr	-100(ra) # 53a0 <close>
    close(fds[1]);
     40c:	fbc42503          	lw	a0,-68(s0)
     410:	00005097          	auipc	ra,0x5
     414:	f90080e7          	jalr	-112(ra) # 53a0 <close>
  for(int ai = 0; ai < 2; ai++){
     418:	0921                	addi	s2,s2,8
     41a:	fd040793          	addi	a5,s0,-48
     41e:	f6f918e3          	bne	s2,a5,38e <copyin+0x2a>
}
     422:	60a6                	ld	ra,72(sp)
     424:	6406                	ld	s0,64(sp)
     426:	74e2                	ld	s1,56(sp)
     428:	7942                	ld	s2,48(sp)
     42a:	79a2                	ld	s3,40(sp)
     42c:	7a02                	ld	s4,32(sp)
     42e:	6161                	addi	sp,sp,80
     430:	8082                	ret
      printf("open(copyin1) failed\n");
     432:	00006517          	auipc	a0,0x6
     436:	87e50513          	addi	a0,a0,-1922 # 5cb0 <malloc+0x502>
     43a:	00005097          	auipc	ra,0x5
     43e:	2b6080e7          	jalr	694(ra) # 56f0 <printf>
      exit(1);
     442:	4505                	li	a0,1
     444:	00005097          	auipc	ra,0x5
     448:	f34080e7          	jalr	-204(ra) # 5378 <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
     44c:	862a                	mv	a2,a0
     44e:	85ce                	mv	a1,s3
     450:	00006517          	auipc	a0,0x6
     454:	87850513          	addi	a0,a0,-1928 # 5cc8 <malloc+0x51a>
     458:	00005097          	auipc	ra,0x5
     45c:	298080e7          	jalr	664(ra) # 56f0 <printf>
      exit(1);
     460:	4505                	li	a0,1
     462:	00005097          	auipc	ra,0x5
     466:	f16080e7          	jalr	-234(ra) # 5378 <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     46a:	862a                	mv	a2,a0
     46c:	85ce                	mv	a1,s3
     46e:	00006517          	auipc	a0,0x6
     472:	88a50513          	addi	a0,a0,-1910 # 5cf8 <malloc+0x54a>
     476:	00005097          	auipc	ra,0x5
     47a:	27a080e7          	jalr	634(ra) # 56f0 <printf>
      exit(1);
     47e:	4505                	li	a0,1
     480:	00005097          	auipc	ra,0x5
     484:	ef8080e7          	jalr	-264(ra) # 5378 <exit>
      printf("pipe() failed\n");
     488:	00006517          	auipc	a0,0x6
     48c:	8a050513          	addi	a0,a0,-1888 # 5d28 <malloc+0x57a>
     490:	00005097          	auipc	ra,0x5
     494:	260080e7          	jalr	608(ra) # 56f0 <printf>
      exit(1);
     498:	4505                	li	a0,1
     49a:	00005097          	auipc	ra,0x5
     49e:	ede080e7          	jalr	-290(ra) # 5378 <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     4a2:	862a                	mv	a2,a0
     4a4:	85ce                	mv	a1,s3
     4a6:	00006517          	auipc	a0,0x6
     4aa:	89250513          	addi	a0,a0,-1902 # 5d38 <malloc+0x58a>
     4ae:	00005097          	auipc	ra,0x5
     4b2:	242080e7          	jalr	578(ra) # 56f0 <printf>
      exit(1);
     4b6:	4505                	li	a0,1
     4b8:	00005097          	auipc	ra,0x5
     4bc:	ec0080e7          	jalr	-320(ra) # 5378 <exit>

00000000000004c0 <copyout>:
{
     4c0:	711d                	addi	sp,sp,-96
     4c2:	ec86                	sd	ra,88(sp)
     4c4:	e8a2                	sd	s0,80(sp)
     4c6:	e4a6                	sd	s1,72(sp)
     4c8:	e0ca                	sd	s2,64(sp)
     4ca:	fc4e                	sd	s3,56(sp)
     4cc:	f852                	sd	s4,48(sp)
     4ce:	f456                	sd	s5,40(sp)
     4d0:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     4d2:	4785                	li	a5,1
     4d4:	07fe                	slli	a5,a5,0x1f
     4d6:	faf43823          	sd	a5,-80(s0)
     4da:	57fd                	li	a5,-1
     4dc:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < 2; ai++){
     4e0:	fb040913          	addi	s2,s0,-80
    int fd = open("README", 0);
     4e4:	00006a17          	auipc	s4,0x6
     4e8:	884a0a13          	addi	s4,s4,-1916 # 5d68 <malloc+0x5ba>
    n = write(fds[1], "x", 1);
     4ec:	00005a97          	auipc	s5,0x5
     4f0:	754a8a93          	addi	s5,s5,1876 # 5c40 <malloc+0x492>
    uint64 addr = addrs[ai];
     4f4:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     4f8:	4581                	li	a1,0
     4fa:	8552                	mv	a0,s4
     4fc:	00005097          	auipc	ra,0x5
     500:	ebc080e7          	jalr	-324(ra) # 53b8 <open>
     504:	84aa                	mv	s1,a0
    if(fd < 0){
     506:	08054663          	bltz	a0,592 <copyout+0xd2>
    int n = read(fd, (void*)addr, 8192);
     50a:	6609                	lui	a2,0x2
     50c:	85ce                	mv	a1,s3
     50e:	00005097          	auipc	ra,0x5
     512:	e82080e7          	jalr	-382(ra) # 5390 <read>
    if(n > 0){
     516:	08a04b63          	bgtz	a0,5ac <copyout+0xec>
    close(fd);
     51a:	8526                	mv	a0,s1
     51c:	00005097          	auipc	ra,0x5
     520:	e84080e7          	jalr	-380(ra) # 53a0 <close>
    if(pipe(fds) < 0){
     524:	fa840513          	addi	a0,s0,-88
     528:	00005097          	auipc	ra,0x5
     52c:	e60080e7          	jalr	-416(ra) # 5388 <pipe>
     530:	08054d63          	bltz	a0,5ca <copyout+0x10a>
    n = write(fds[1], "x", 1);
     534:	4605                	li	a2,1
     536:	85d6                	mv	a1,s5
     538:	fac42503          	lw	a0,-84(s0)
     53c:	00005097          	auipc	ra,0x5
     540:	e5c080e7          	jalr	-420(ra) # 5398 <write>
    if(n != 1){
     544:	4785                	li	a5,1
     546:	08f51f63          	bne	a0,a5,5e4 <copyout+0x124>
    n = read(fds[0], (void*)addr, 8192);
     54a:	6609                	lui	a2,0x2
     54c:	85ce                	mv	a1,s3
     54e:	fa842503          	lw	a0,-88(s0)
     552:	00005097          	auipc	ra,0x5
     556:	e3e080e7          	jalr	-450(ra) # 5390 <read>
    if(n > 0){
     55a:	0aa04263          	bgtz	a0,5fe <copyout+0x13e>
    close(fds[0]);
     55e:	fa842503          	lw	a0,-88(s0)
     562:	00005097          	auipc	ra,0x5
     566:	e3e080e7          	jalr	-450(ra) # 53a0 <close>
    close(fds[1]);
     56a:	fac42503          	lw	a0,-84(s0)
     56e:	00005097          	auipc	ra,0x5
     572:	e32080e7          	jalr	-462(ra) # 53a0 <close>
  for(int ai = 0; ai < 2; ai++){
     576:	0921                	addi	s2,s2,8
     578:	fc040793          	addi	a5,s0,-64
     57c:	f6f91ce3          	bne	s2,a5,4f4 <copyout+0x34>
}
     580:	60e6                	ld	ra,88(sp)
     582:	6446                	ld	s0,80(sp)
     584:	64a6                	ld	s1,72(sp)
     586:	6906                	ld	s2,64(sp)
     588:	79e2                	ld	s3,56(sp)
     58a:	7a42                	ld	s4,48(sp)
     58c:	7aa2                	ld	s5,40(sp)
     58e:	6125                	addi	sp,sp,96
     590:	8082                	ret
      printf("open(README) failed\n");
     592:	00005517          	auipc	a0,0x5
     596:	7de50513          	addi	a0,a0,2014 # 5d70 <malloc+0x5c2>
     59a:	00005097          	auipc	ra,0x5
     59e:	156080e7          	jalr	342(ra) # 56f0 <printf>
      exit(1);
     5a2:	4505                	li	a0,1
     5a4:	00005097          	auipc	ra,0x5
     5a8:	dd4080e7          	jalr	-556(ra) # 5378 <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     5ac:	862a                	mv	a2,a0
     5ae:	85ce                	mv	a1,s3
     5b0:	00005517          	auipc	a0,0x5
     5b4:	7d850513          	addi	a0,a0,2008 # 5d88 <malloc+0x5da>
     5b8:	00005097          	auipc	ra,0x5
     5bc:	138080e7          	jalr	312(ra) # 56f0 <printf>
      exit(1);
     5c0:	4505                	li	a0,1
     5c2:	00005097          	auipc	ra,0x5
     5c6:	db6080e7          	jalr	-586(ra) # 5378 <exit>
      printf("pipe() failed\n");
     5ca:	00005517          	auipc	a0,0x5
     5ce:	75e50513          	addi	a0,a0,1886 # 5d28 <malloc+0x57a>
     5d2:	00005097          	auipc	ra,0x5
     5d6:	11e080e7          	jalr	286(ra) # 56f0 <printf>
      exit(1);
     5da:	4505                	li	a0,1
     5dc:	00005097          	auipc	ra,0x5
     5e0:	d9c080e7          	jalr	-612(ra) # 5378 <exit>
      printf("pipe write failed\n");
     5e4:	00005517          	auipc	a0,0x5
     5e8:	7d450513          	addi	a0,a0,2004 # 5db8 <malloc+0x60a>
     5ec:	00005097          	auipc	ra,0x5
     5f0:	104080e7          	jalr	260(ra) # 56f0 <printf>
      exit(1);
     5f4:	4505                	li	a0,1
     5f6:	00005097          	auipc	ra,0x5
     5fa:	d82080e7          	jalr	-638(ra) # 5378 <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     5fe:	862a                	mv	a2,a0
     600:	85ce                	mv	a1,s3
     602:	00005517          	auipc	a0,0x5
     606:	7ce50513          	addi	a0,a0,1998 # 5dd0 <malloc+0x622>
     60a:	00005097          	auipc	ra,0x5
     60e:	0e6080e7          	jalr	230(ra) # 56f0 <printf>
      exit(1);
     612:	4505                	li	a0,1
     614:	00005097          	auipc	ra,0x5
     618:	d64080e7          	jalr	-668(ra) # 5378 <exit>

000000000000061c <truncate1>:
{
     61c:	711d                	addi	sp,sp,-96
     61e:	ec86                	sd	ra,88(sp)
     620:	e8a2                	sd	s0,80(sp)
     622:	e4a6                	sd	s1,72(sp)
     624:	e0ca                	sd	s2,64(sp)
     626:	fc4e                	sd	s3,56(sp)
     628:	f852                	sd	s4,48(sp)
     62a:	f456                	sd	s5,40(sp)
     62c:	1080                	addi	s0,sp,96
     62e:	8aaa                	mv	s5,a0
  unlink("truncfile");
     630:	00005517          	auipc	a0,0x5
     634:	5f850513          	addi	a0,a0,1528 # 5c28 <malloc+0x47a>
     638:	00005097          	auipc	ra,0x5
     63c:	d90080e7          	jalr	-624(ra) # 53c8 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     640:	60100593          	li	a1,1537
     644:	00005517          	auipc	a0,0x5
     648:	5e450513          	addi	a0,a0,1508 # 5c28 <malloc+0x47a>
     64c:	00005097          	auipc	ra,0x5
     650:	d6c080e7          	jalr	-660(ra) # 53b8 <open>
     654:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     656:	4611                	li	a2,4
     658:	00005597          	auipc	a1,0x5
     65c:	5e058593          	addi	a1,a1,1504 # 5c38 <malloc+0x48a>
     660:	00005097          	auipc	ra,0x5
     664:	d38080e7          	jalr	-712(ra) # 5398 <write>
  close(fd1);
     668:	8526                	mv	a0,s1
     66a:	00005097          	auipc	ra,0x5
     66e:	d36080e7          	jalr	-714(ra) # 53a0 <close>
  int fd2 = open("truncfile", O_RDONLY);
     672:	4581                	li	a1,0
     674:	00005517          	auipc	a0,0x5
     678:	5b450513          	addi	a0,a0,1460 # 5c28 <malloc+0x47a>
     67c:	00005097          	auipc	ra,0x5
     680:	d3c080e7          	jalr	-708(ra) # 53b8 <open>
     684:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     686:	02000613          	li	a2,32
     68a:	fa040593          	addi	a1,s0,-96
     68e:	00005097          	auipc	ra,0x5
     692:	d02080e7          	jalr	-766(ra) # 5390 <read>
  if(n != 4){
     696:	4791                	li	a5,4
     698:	0cf51e63          	bne	a0,a5,774 <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     69c:	40100593          	li	a1,1025
     6a0:	00005517          	auipc	a0,0x5
     6a4:	58850513          	addi	a0,a0,1416 # 5c28 <malloc+0x47a>
     6a8:	00005097          	auipc	ra,0x5
     6ac:	d10080e7          	jalr	-752(ra) # 53b8 <open>
     6b0:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     6b2:	4581                	li	a1,0
     6b4:	00005517          	auipc	a0,0x5
     6b8:	57450513          	addi	a0,a0,1396 # 5c28 <malloc+0x47a>
     6bc:	00005097          	auipc	ra,0x5
     6c0:	cfc080e7          	jalr	-772(ra) # 53b8 <open>
     6c4:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     6c6:	02000613          	li	a2,32
     6ca:	fa040593          	addi	a1,s0,-96
     6ce:	00005097          	auipc	ra,0x5
     6d2:	cc2080e7          	jalr	-830(ra) # 5390 <read>
     6d6:	8a2a                	mv	s4,a0
  if(n != 0){
     6d8:	ed4d                	bnez	a0,792 <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     6da:	02000613          	li	a2,32
     6de:	fa040593          	addi	a1,s0,-96
     6e2:	8526                	mv	a0,s1
     6e4:	00005097          	auipc	ra,0x5
     6e8:	cac080e7          	jalr	-852(ra) # 5390 <read>
     6ec:	8a2a                	mv	s4,a0
  if(n != 0){
     6ee:	e971                	bnez	a0,7c2 <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     6f0:	4619                	li	a2,6
     6f2:	00005597          	auipc	a1,0x5
     6f6:	76e58593          	addi	a1,a1,1902 # 5e60 <malloc+0x6b2>
     6fa:	854e                	mv	a0,s3
     6fc:	00005097          	auipc	ra,0x5
     700:	c9c080e7          	jalr	-868(ra) # 5398 <write>
  n = read(fd3, buf, sizeof(buf));
     704:	02000613          	li	a2,32
     708:	fa040593          	addi	a1,s0,-96
     70c:	854a                	mv	a0,s2
     70e:	00005097          	auipc	ra,0x5
     712:	c82080e7          	jalr	-894(ra) # 5390 <read>
  if(n != 6){
     716:	4799                	li	a5,6
     718:	0cf51d63          	bne	a0,a5,7f2 <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     71c:	02000613          	li	a2,32
     720:	fa040593          	addi	a1,s0,-96
     724:	8526                	mv	a0,s1
     726:	00005097          	auipc	ra,0x5
     72a:	c6a080e7          	jalr	-918(ra) # 5390 <read>
  if(n != 2){
     72e:	4789                	li	a5,2
     730:	0ef51063          	bne	a0,a5,810 <truncate1+0x1f4>
  unlink("truncfile");
     734:	00005517          	auipc	a0,0x5
     738:	4f450513          	addi	a0,a0,1268 # 5c28 <malloc+0x47a>
     73c:	00005097          	auipc	ra,0x5
     740:	c8c080e7          	jalr	-884(ra) # 53c8 <unlink>
  close(fd1);
     744:	854e                	mv	a0,s3
     746:	00005097          	auipc	ra,0x5
     74a:	c5a080e7          	jalr	-934(ra) # 53a0 <close>
  close(fd2);
     74e:	8526                	mv	a0,s1
     750:	00005097          	auipc	ra,0x5
     754:	c50080e7          	jalr	-944(ra) # 53a0 <close>
  close(fd3);
     758:	854a                	mv	a0,s2
     75a:	00005097          	auipc	ra,0x5
     75e:	c46080e7          	jalr	-954(ra) # 53a0 <close>
}
     762:	60e6                	ld	ra,88(sp)
     764:	6446                	ld	s0,80(sp)
     766:	64a6                	ld	s1,72(sp)
     768:	6906                	ld	s2,64(sp)
     76a:	79e2                	ld	s3,56(sp)
     76c:	7a42                	ld	s4,48(sp)
     76e:	7aa2                	ld	s5,40(sp)
     770:	6125                	addi	sp,sp,96
     772:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     774:	862a                	mv	a2,a0
     776:	85d6                	mv	a1,s5
     778:	00005517          	auipc	a0,0x5
     77c:	68850513          	addi	a0,a0,1672 # 5e00 <malloc+0x652>
     780:	00005097          	auipc	ra,0x5
     784:	f70080e7          	jalr	-144(ra) # 56f0 <printf>
    exit(1);
     788:	4505                	li	a0,1
     78a:	00005097          	auipc	ra,0x5
     78e:	bee080e7          	jalr	-1042(ra) # 5378 <exit>
    printf("aaa fd3=%d\n", fd3);
     792:	85ca                	mv	a1,s2
     794:	00005517          	auipc	a0,0x5
     798:	68c50513          	addi	a0,a0,1676 # 5e20 <malloc+0x672>
     79c:	00005097          	auipc	ra,0x5
     7a0:	f54080e7          	jalr	-172(ra) # 56f0 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     7a4:	8652                	mv	a2,s4
     7a6:	85d6                	mv	a1,s5
     7a8:	00005517          	auipc	a0,0x5
     7ac:	68850513          	addi	a0,a0,1672 # 5e30 <malloc+0x682>
     7b0:	00005097          	auipc	ra,0x5
     7b4:	f40080e7          	jalr	-192(ra) # 56f0 <printf>
    exit(1);
     7b8:	4505                	li	a0,1
     7ba:	00005097          	auipc	ra,0x5
     7be:	bbe080e7          	jalr	-1090(ra) # 5378 <exit>
    printf("bbb fd2=%d\n", fd2);
     7c2:	85a6                	mv	a1,s1
     7c4:	00005517          	auipc	a0,0x5
     7c8:	68c50513          	addi	a0,a0,1676 # 5e50 <malloc+0x6a2>
     7cc:	00005097          	auipc	ra,0x5
     7d0:	f24080e7          	jalr	-220(ra) # 56f0 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     7d4:	8652                	mv	a2,s4
     7d6:	85d6                	mv	a1,s5
     7d8:	00005517          	auipc	a0,0x5
     7dc:	65850513          	addi	a0,a0,1624 # 5e30 <malloc+0x682>
     7e0:	00005097          	auipc	ra,0x5
     7e4:	f10080e7          	jalr	-240(ra) # 56f0 <printf>
    exit(1);
     7e8:	4505                	li	a0,1
     7ea:	00005097          	auipc	ra,0x5
     7ee:	b8e080e7          	jalr	-1138(ra) # 5378 <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     7f2:	862a                	mv	a2,a0
     7f4:	85d6                	mv	a1,s5
     7f6:	00005517          	auipc	a0,0x5
     7fa:	67250513          	addi	a0,a0,1650 # 5e68 <malloc+0x6ba>
     7fe:	00005097          	auipc	ra,0x5
     802:	ef2080e7          	jalr	-270(ra) # 56f0 <printf>
    exit(1);
     806:	4505                	li	a0,1
     808:	00005097          	auipc	ra,0x5
     80c:	b70080e7          	jalr	-1168(ra) # 5378 <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     810:	862a                	mv	a2,a0
     812:	85d6                	mv	a1,s5
     814:	00005517          	auipc	a0,0x5
     818:	67450513          	addi	a0,a0,1652 # 5e88 <malloc+0x6da>
     81c:	00005097          	auipc	ra,0x5
     820:	ed4080e7          	jalr	-300(ra) # 56f0 <printf>
    exit(1);
     824:	4505                	li	a0,1
     826:	00005097          	auipc	ra,0x5
     82a:	b52080e7          	jalr	-1198(ra) # 5378 <exit>

000000000000082e <writetest>:
{
     82e:	7139                	addi	sp,sp,-64
     830:	fc06                	sd	ra,56(sp)
     832:	f822                	sd	s0,48(sp)
     834:	f426                	sd	s1,40(sp)
     836:	f04a                	sd	s2,32(sp)
     838:	ec4e                	sd	s3,24(sp)
     83a:	e852                	sd	s4,16(sp)
     83c:	e456                	sd	s5,8(sp)
     83e:	e05a                	sd	s6,0(sp)
     840:	0080                	addi	s0,sp,64
     842:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
     844:	20200593          	li	a1,514
     848:	00005517          	auipc	a0,0x5
     84c:	66050513          	addi	a0,a0,1632 # 5ea8 <malloc+0x6fa>
     850:	00005097          	auipc	ra,0x5
     854:	b68080e7          	jalr	-1176(ra) # 53b8 <open>
  if(fd < 0){
     858:	0a054d63          	bltz	a0,912 <writetest+0xe4>
     85c:	892a                	mv	s2,a0
     85e:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     860:	00005997          	auipc	s3,0x5
     864:	67098993          	addi	s3,s3,1648 # 5ed0 <malloc+0x722>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     868:	00005a97          	auipc	s5,0x5
     86c:	6a0a8a93          	addi	s5,s5,1696 # 5f08 <malloc+0x75a>
  for(i = 0; i < N; i++){
     870:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     874:	4629                	li	a2,10
     876:	85ce                	mv	a1,s3
     878:	854a                	mv	a0,s2
     87a:	00005097          	auipc	ra,0x5
     87e:	b1e080e7          	jalr	-1250(ra) # 5398 <write>
     882:	47a9                	li	a5,10
     884:	0af51563          	bne	a0,a5,92e <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     888:	4629                	li	a2,10
     88a:	85d6                	mv	a1,s5
     88c:	854a                	mv	a0,s2
     88e:	00005097          	auipc	ra,0x5
     892:	b0a080e7          	jalr	-1270(ra) # 5398 <write>
     896:	47a9                	li	a5,10
     898:	0af51963          	bne	a0,a5,94a <writetest+0x11c>
  for(i = 0; i < N; i++){
     89c:	2485                	addiw	s1,s1,1
     89e:	fd449be3          	bne	s1,s4,874 <writetest+0x46>
  close(fd);
     8a2:	854a                	mv	a0,s2
     8a4:	00005097          	auipc	ra,0x5
     8a8:	afc080e7          	jalr	-1284(ra) # 53a0 <close>
  fd = open("small", O_RDONLY);
     8ac:	4581                	li	a1,0
     8ae:	00005517          	auipc	a0,0x5
     8b2:	5fa50513          	addi	a0,a0,1530 # 5ea8 <malloc+0x6fa>
     8b6:	00005097          	auipc	ra,0x5
     8ba:	b02080e7          	jalr	-1278(ra) # 53b8 <open>
     8be:	84aa                	mv	s1,a0
  if(fd < 0){
     8c0:	0a054363          	bltz	a0,966 <writetest+0x138>
  i = read(fd, buf, N*SZ*2);
     8c4:	7d000613          	li	a2,2000
     8c8:	0000b597          	auipc	a1,0xb
     8cc:	e7058593          	addi	a1,a1,-400 # b738 <buf>
     8d0:	00005097          	auipc	ra,0x5
     8d4:	ac0080e7          	jalr	-1344(ra) # 5390 <read>
  if(i != N*SZ*2){
     8d8:	7d000793          	li	a5,2000
     8dc:	0af51363          	bne	a0,a5,982 <writetest+0x154>
  close(fd);
     8e0:	8526                	mv	a0,s1
     8e2:	00005097          	auipc	ra,0x5
     8e6:	abe080e7          	jalr	-1346(ra) # 53a0 <close>
  if(unlink("small") < 0){
     8ea:	00005517          	auipc	a0,0x5
     8ee:	5be50513          	addi	a0,a0,1470 # 5ea8 <malloc+0x6fa>
     8f2:	00005097          	auipc	ra,0x5
     8f6:	ad6080e7          	jalr	-1322(ra) # 53c8 <unlink>
     8fa:	0a054263          	bltz	a0,99e <writetest+0x170>
}
     8fe:	70e2                	ld	ra,56(sp)
     900:	7442                	ld	s0,48(sp)
     902:	74a2                	ld	s1,40(sp)
     904:	7902                	ld	s2,32(sp)
     906:	69e2                	ld	s3,24(sp)
     908:	6a42                	ld	s4,16(sp)
     90a:	6aa2                	ld	s5,8(sp)
     90c:	6b02                	ld	s6,0(sp)
     90e:	6121                	addi	sp,sp,64
     910:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     912:	85da                	mv	a1,s6
     914:	00005517          	auipc	a0,0x5
     918:	59c50513          	addi	a0,a0,1436 # 5eb0 <malloc+0x702>
     91c:	00005097          	auipc	ra,0x5
     920:	dd4080e7          	jalr	-556(ra) # 56f0 <printf>
    exit(1);
     924:	4505                	li	a0,1
     926:	00005097          	auipc	ra,0x5
     92a:	a52080e7          	jalr	-1454(ra) # 5378 <exit>
      printf("%s: error: write aa %d new file failed\n", i);
     92e:	85a6                	mv	a1,s1
     930:	00005517          	auipc	a0,0x5
     934:	5b050513          	addi	a0,a0,1456 # 5ee0 <malloc+0x732>
     938:	00005097          	auipc	ra,0x5
     93c:	db8080e7          	jalr	-584(ra) # 56f0 <printf>
      exit(1);
     940:	4505                	li	a0,1
     942:	00005097          	auipc	ra,0x5
     946:	a36080e7          	jalr	-1482(ra) # 5378 <exit>
      printf("%s: error: write bb %d new file failed\n", i);
     94a:	85a6                	mv	a1,s1
     94c:	00005517          	auipc	a0,0x5
     950:	5cc50513          	addi	a0,a0,1484 # 5f18 <malloc+0x76a>
     954:	00005097          	auipc	ra,0x5
     958:	d9c080e7          	jalr	-612(ra) # 56f0 <printf>
      exit(1);
     95c:	4505                	li	a0,1
     95e:	00005097          	auipc	ra,0x5
     962:	a1a080e7          	jalr	-1510(ra) # 5378 <exit>
    printf("%s: error: open small failed!\n", s);
     966:	85da                	mv	a1,s6
     968:	00005517          	auipc	a0,0x5
     96c:	5d850513          	addi	a0,a0,1496 # 5f40 <malloc+0x792>
     970:	00005097          	auipc	ra,0x5
     974:	d80080e7          	jalr	-640(ra) # 56f0 <printf>
    exit(1);
     978:	4505                	li	a0,1
     97a:	00005097          	auipc	ra,0x5
     97e:	9fe080e7          	jalr	-1538(ra) # 5378 <exit>
    printf("%s: read failed\n", s);
     982:	85da                	mv	a1,s6
     984:	00005517          	auipc	a0,0x5
     988:	5dc50513          	addi	a0,a0,1500 # 5f60 <malloc+0x7b2>
     98c:	00005097          	auipc	ra,0x5
     990:	d64080e7          	jalr	-668(ra) # 56f0 <printf>
    exit(1);
     994:	4505                	li	a0,1
     996:	00005097          	auipc	ra,0x5
     99a:	9e2080e7          	jalr	-1566(ra) # 5378 <exit>
    printf("%s: unlink small failed\n", s);
     99e:	85da                	mv	a1,s6
     9a0:	00005517          	auipc	a0,0x5
     9a4:	5d850513          	addi	a0,a0,1496 # 5f78 <malloc+0x7ca>
     9a8:	00005097          	auipc	ra,0x5
     9ac:	d48080e7          	jalr	-696(ra) # 56f0 <printf>
    exit(1);
     9b0:	4505                	li	a0,1
     9b2:	00005097          	auipc	ra,0x5
     9b6:	9c6080e7          	jalr	-1594(ra) # 5378 <exit>

00000000000009ba <writebig>:
{
     9ba:	7139                	addi	sp,sp,-64
     9bc:	fc06                	sd	ra,56(sp)
     9be:	f822                	sd	s0,48(sp)
     9c0:	f426                	sd	s1,40(sp)
     9c2:	f04a                	sd	s2,32(sp)
     9c4:	ec4e                	sd	s3,24(sp)
     9c6:	e852                	sd	s4,16(sp)
     9c8:	e456                	sd	s5,8(sp)
     9ca:	0080                	addi	s0,sp,64
     9cc:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
     9ce:	20200593          	li	a1,514
     9d2:	00005517          	auipc	a0,0x5
     9d6:	5c650513          	addi	a0,a0,1478 # 5f98 <malloc+0x7ea>
     9da:	00005097          	auipc	ra,0x5
     9de:	9de080e7          	jalr	-1570(ra) # 53b8 <open>
     9e2:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
     9e4:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     9e6:	0000b917          	auipc	s2,0xb
     9ea:	d5290913          	addi	s2,s2,-686 # b738 <buf>
  for(i = 0; i < MAXFILE; i++){
     9ee:	10c00a13          	li	s4,268
  if(fd < 0){
     9f2:	06054c63          	bltz	a0,a6a <writebig+0xb0>
    ((int*)buf)[0] = i;
     9f6:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     9fa:	40000613          	li	a2,1024
     9fe:	85ca                	mv	a1,s2
     a00:	854e                	mv	a0,s3
     a02:	00005097          	auipc	ra,0x5
     a06:	996080e7          	jalr	-1642(ra) # 5398 <write>
     a0a:	40000793          	li	a5,1024
     a0e:	06f51c63          	bne	a0,a5,a86 <writebig+0xcc>
  for(i = 0; i < MAXFILE; i++){
     a12:	2485                	addiw	s1,s1,1
     a14:	ff4491e3          	bne	s1,s4,9f6 <writebig+0x3c>
  close(fd);
     a18:	854e                	mv	a0,s3
     a1a:	00005097          	auipc	ra,0x5
     a1e:	986080e7          	jalr	-1658(ra) # 53a0 <close>
  fd = open("big", O_RDONLY);
     a22:	4581                	li	a1,0
     a24:	00005517          	auipc	a0,0x5
     a28:	57450513          	addi	a0,a0,1396 # 5f98 <malloc+0x7ea>
     a2c:	00005097          	auipc	ra,0x5
     a30:	98c080e7          	jalr	-1652(ra) # 53b8 <open>
     a34:	89aa                	mv	s3,a0
  n = 0;
     a36:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     a38:	0000b917          	auipc	s2,0xb
     a3c:	d0090913          	addi	s2,s2,-768 # b738 <buf>
  if(fd < 0){
     a40:	06054163          	bltz	a0,aa2 <writebig+0xe8>
    i = read(fd, buf, BSIZE);
     a44:	40000613          	li	a2,1024
     a48:	85ca                	mv	a1,s2
     a4a:	854e                	mv	a0,s3
     a4c:	00005097          	auipc	ra,0x5
     a50:	944080e7          	jalr	-1724(ra) # 5390 <read>
    if(i == 0){
     a54:	c52d                	beqz	a0,abe <writebig+0x104>
    } else if(i != BSIZE){
     a56:	40000793          	li	a5,1024
     a5a:	0af51d63          	bne	a0,a5,b14 <writebig+0x15a>
    if(((int*)buf)[0] != n){
     a5e:	00092603          	lw	a2,0(s2)
     a62:	0c961763          	bne	a2,s1,b30 <writebig+0x176>
    n++;
     a66:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     a68:	bff1                	j	a44 <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
     a6a:	85d6                	mv	a1,s5
     a6c:	00005517          	auipc	a0,0x5
     a70:	53450513          	addi	a0,a0,1332 # 5fa0 <malloc+0x7f2>
     a74:	00005097          	auipc	ra,0x5
     a78:	c7c080e7          	jalr	-900(ra) # 56f0 <printf>
    exit(1);
     a7c:	4505                	li	a0,1
     a7e:	00005097          	auipc	ra,0x5
     a82:	8fa080e7          	jalr	-1798(ra) # 5378 <exit>
      printf("%s: error: write big file failed\n", i);
     a86:	85a6                	mv	a1,s1
     a88:	00005517          	auipc	a0,0x5
     a8c:	53850513          	addi	a0,a0,1336 # 5fc0 <malloc+0x812>
     a90:	00005097          	auipc	ra,0x5
     a94:	c60080e7          	jalr	-928(ra) # 56f0 <printf>
      exit(1);
     a98:	4505                	li	a0,1
     a9a:	00005097          	auipc	ra,0x5
     a9e:	8de080e7          	jalr	-1826(ra) # 5378 <exit>
    printf("%s: error: open big failed!\n", s);
     aa2:	85d6                	mv	a1,s5
     aa4:	00005517          	auipc	a0,0x5
     aa8:	54450513          	addi	a0,a0,1348 # 5fe8 <malloc+0x83a>
     aac:	00005097          	auipc	ra,0x5
     ab0:	c44080e7          	jalr	-956(ra) # 56f0 <printf>
    exit(1);
     ab4:	4505                	li	a0,1
     ab6:	00005097          	auipc	ra,0x5
     aba:	8c2080e7          	jalr	-1854(ra) # 5378 <exit>
      if(n == MAXFILE - 1){
     abe:	10b00793          	li	a5,267
     ac2:	02f48a63          	beq	s1,a5,af6 <writebig+0x13c>
  close(fd);
     ac6:	854e                	mv	a0,s3
     ac8:	00005097          	auipc	ra,0x5
     acc:	8d8080e7          	jalr	-1832(ra) # 53a0 <close>
  if(unlink("big") < 0){
     ad0:	00005517          	auipc	a0,0x5
     ad4:	4c850513          	addi	a0,a0,1224 # 5f98 <malloc+0x7ea>
     ad8:	00005097          	auipc	ra,0x5
     adc:	8f0080e7          	jalr	-1808(ra) # 53c8 <unlink>
     ae0:	06054663          	bltz	a0,b4c <writebig+0x192>
}
     ae4:	70e2                	ld	ra,56(sp)
     ae6:	7442                	ld	s0,48(sp)
     ae8:	74a2                	ld	s1,40(sp)
     aea:	7902                	ld	s2,32(sp)
     aec:	69e2                	ld	s3,24(sp)
     aee:	6a42                	ld	s4,16(sp)
     af0:	6aa2                	ld	s5,8(sp)
     af2:	6121                	addi	sp,sp,64
     af4:	8082                	ret
        printf("%s: read only %d blocks from big", n);
     af6:	10b00593          	li	a1,267
     afa:	00005517          	auipc	a0,0x5
     afe:	50e50513          	addi	a0,a0,1294 # 6008 <malloc+0x85a>
     b02:	00005097          	auipc	ra,0x5
     b06:	bee080e7          	jalr	-1042(ra) # 56f0 <printf>
        exit(1);
     b0a:	4505                	li	a0,1
     b0c:	00005097          	auipc	ra,0x5
     b10:	86c080e7          	jalr	-1940(ra) # 5378 <exit>
      printf("%s: read failed %d\n", i);
     b14:	85aa                	mv	a1,a0
     b16:	00005517          	auipc	a0,0x5
     b1a:	51a50513          	addi	a0,a0,1306 # 6030 <malloc+0x882>
     b1e:	00005097          	auipc	ra,0x5
     b22:	bd2080e7          	jalr	-1070(ra) # 56f0 <printf>
      exit(1);
     b26:	4505                	li	a0,1
     b28:	00005097          	auipc	ra,0x5
     b2c:	850080e7          	jalr	-1968(ra) # 5378 <exit>
      printf("%s: read content of block %d is %d\n",
     b30:	85a6                	mv	a1,s1
     b32:	00005517          	auipc	a0,0x5
     b36:	51650513          	addi	a0,a0,1302 # 6048 <malloc+0x89a>
     b3a:	00005097          	auipc	ra,0x5
     b3e:	bb6080e7          	jalr	-1098(ra) # 56f0 <printf>
      exit(1);
     b42:	4505                	li	a0,1
     b44:	00005097          	auipc	ra,0x5
     b48:	834080e7          	jalr	-1996(ra) # 5378 <exit>
    printf("%s: unlink big failed\n", s);
     b4c:	85d6                	mv	a1,s5
     b4e:	00005517          	auipc	a0,0x5
     b52:	52250513          	addi	a0,a0,1314 # 6070 <malloc+0x8c2>
     b56:	00005097          	auipc	ra,0x5
     b5a:	b9a080e7          	jalr	-1126(ra) # 56f0 <printf>
    exit(1);
     b5e:	4505                	li	a0,1
     b60:	00005097          	auipc	ra,0x5
     b64:	818080e7          	jalr	-2024(ra) # 5378 <exit>

0000000000000b68 <unlinkread>:
{
     b68:	7179                	addi	sp,sp,-48
     b6a:	f406                	sd	ra,40(sp)
     b6c:	f022                	sd	s0,32(sp)
     b6e:	ec26                	sd	s1,24(sp)
     b70:	e84a                	sd	s2,16(sp)
     b72:	e44e                	sd	s3,8(sp)
     b74:	1800                	addi	s0,sp,48
     b76:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     b78:	20200593          	li	a1,514
     b7c:	00005517          	auipc	a0,0x5
     b80:	e6450513          	addi	a0,a0,-412 # 59e0 <malloc+0x232>
     b84:	00005097          	auipc	ra,0x5
     b88:	834080e7          	jalr	-1996(ra) # 53b8 <open>
  if(fd < 0){
     b8c:	0e054563          	bltz	a0,c76 <unlinkread+0x10e>
     b90:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     b92:	4615                	li	a2,5
     b94:	00005597          	auipc	a1,0x5
     b98:	51458593          	addi	a1,a1,1300 # 60a8 <malloc+0x8fa>
     b9c:	00004097          	auipc	ra,0x4
     ba0:	7fc080e7          	jalr	2044(ra) # 5398 <write>
  close(fd);
     ba4:	8526                	mv	a0,s1
     ba6:	00004097          	auipc	ra,0x4
     baa:	7fa080e7          	jalr	2042(ra) # 53a0 <close>
  fd = open("unlinkread", O_RDWR);
     bae:	4589                	li	a1,2
     bb0:	00005517          	auipc	a0,0x5
     bb4:	e3050513          	addi	a0,a0,-464 # 59e0 <malloc+0x232>
     bb8:	00005097          	auipc	ra,0x5
     bbc:	800080e7          	jalr	-2048(ra) # 53b8 <open>
     bc0:	84aa                	mv	s1,a0
  if(fd < 0){
     bc2:	0c054863          	bltz	a0,c92 <unlinkread+0x12a>
  if(unlink("unlinkread") != 0){
     bc6:	00005517          	auipc	a0,0x5
     bca:	e1a50513          	addi	a0,a0,-486 # 59e0 <malloc+0x232>
     bce:	00004097          	auipc	ra,0x4
     bd2:	7fa080e7          	jalr	2042(ra) # 53c8 <unlink>
     bd6:	ed61                	bnez	a0,cae <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     bd8:	20200593          	li	a1,514
     bdc:	00005517          	auipc	a0,0x5
     be0:	e0450513          	addi	a0,a0,-508 # 59e0 <malloc+0x232>
     be4:	00004097          	auipc	ra,0x4
     be8:	7d4080e7          	jalr	2004(ra) # 53b8 <open>
     bec:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     bee:	460d                	li	a2,3
     bf0:	00005597          	auipc	a1,0x5
     bf4:	50058593          	addi	a1,a1,1280 # 60f0 <malloc+0x942>
     bf8:	00004097          	auipc	ra,0x4
     bfc:	7a0080e7          	jalr	1952(ra) # 5398 <write>
  close(fd1);
     c00:	854a                	mv	a0,s2
     c02:	00004097          	auipc	ra,0x4
     c06:	79e080e7          	jalr	1950(ra) # 53a0 <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
     c0a:	660d                	lui	a2,0x3
     c0c:	0000b597          	auipc	a1,0xb
     c10:	b2c58593          	addi	a1,a1,-1236 # b738 <buf>
     c14:	8526                	mv	a0,s1
     c16:	00004097          	auipc	ra,0x4
     c1a:	77a080e7          	jalr	1914(ra) # 5390 <read>
     c1e:	4795                	li	a5,5
     c20:	0af51563          	bne	a0,a5,cca <unlinkread+0x162>
  if(buf[0] != 'h'){
     c24:	0000b717          	auipc	a4,0xb
     c28:	b1474703          	lbu	a4,-1260(a4) # b738 <buf>
     c2c:	06800793          	li	a5,104
     c30:	0af71b63          	bne	a4,a5,ce6 <unlinkread+0x17e>
  if(write(fd, buf, 10) != 10){
     c34:	4629                	li	a2,10
     c36:	0000b597          	auipc	a1,0xb
     c3a:	b0258593          	addi	a1,a1,-1278 # b738 <buf>
     c3e:	8526                	mv	a0,s1
     c40:	00004097          	auipc	ra,0x4
     c44:	758080e7          	jalr	1880(ra) # 5398 <write>
     c48:	47a9                	li	a5,10
     c4a:	0af51c63          	bne	a0,a5,d02 <unlinkread+0x19a>
  close(fd);
     c4e:	8526                	mv	a0,s1
     c50:	00004097          	auipc	ra,0x4
     c54:	750080e7          	jalr	1872(ra) # 53a0 <close>
  unlink("unlinkread");
     c58:	00005517          	auipc	a0,0x5
     c5c:	d8850513          	addi	a0,a0,-632 # 59e0 <malloc+0x232>
     c60:	00004097          	auipc	ra,0x4
     c64:	768080e7          	jalr	1896(ra) # 53c8 <unlink>
}
     c68:	70a2                	ld	ra,40(sp)
     c6a:	7402                	ld	s0,32(sp)
     c6c:	64e2                	ld	s1,24(sp)
     c6e:	6942                	ld	s2,16(sp)
     c70:	69a2                	ld	s3,8(sp)
     c72:	6145                	addi	sp,sp,48
     c74:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     c76:	85ce                	mv	a1,s3
     c78:	00005517          	auipc	a0,0x5
     c7c:	41050513          	addi	a0,a0,1040 # 6088 <malloc+0x8da>
     c80:	00005097          	auipc	ra,0x5
     c84:	a70080e7          	jalr	-1424(ra) # 56f0 <printf>
    exit(1);
     c88:	4505                	li	a0,1
     c8a:	00004097          	auipc	ra,0x4
     c8e:	6ee080e7          	jalr	1774(ra) # 5378 <exit>
    printf("%s: open unlinkread failed\n", s);
     c92:	85ce                	mv	a1,s3
     c94:	00005517          	auipc	a0,0x5
     c98:	41c50513          	addi	a0,a0,1052 # 60b0 <malloc+0x902>
     c9c:	00005097          	auipc	ra,0x5
     ca0:	a54080e7          	jalr	-1452(ra) # 56f0 <printf>
    exit(1);
     ca4:	4505                	li	a0,1
     ca6:	00004097          	auipc	ra,0x4
     caa:	6d2080e7          	jalr	1746(ra) # 5378 <exit>
    printf("%s: unlink unlinkread failed\n", s);
     cae:	85ce                	mv	a1,s3
     cb0:	00005517          	auipc	a0,0x5
     cb4:	42050513          	addi	a0,a0,1056 # 60d0 <malloc+0x922>
     cb8:	00005097          	auipc	ra,0x5
     cbc:	a38080e7          	jalr	-1480(ra) # 56f0 <printf>
    exit(1);
     cc0:	4505                	li	a0,1
     cc2:	00004097          	auipc	ra,0x4
     cc6:	6b6080e7          	jalr	1718(ra) # 5378 <exit>
    printf("%s: unlinkread read failed", s);
     cca:	85ce                	mv	a1,s3
     ccc:	00005517          	auipc	a0,0x5
     cd0:	42c50513          	addi	a0,a0,1068 # 60f8 <malloc+0x94a>
     cd4:	00005097          	auipc	ra,0x5
     cd8:	a1c080e7          	jalr	-1508(ra) # 56f0 <printf>
    exit(1);
     cdc:	4505                	li	a0,1
     cde:	00004097          	auipc	ra,0x4
     ce2:	69a080e7          	jalr	1690(ra) # 5378 <exit>
    printf("%s: unlinkread wrong data\n", s);
     ce6:	85ce                	mv	a1,s3
     ce8:	00005517          	auipc	a0,0x5
     cec:	43050513          	addi	a0,a0,1072 # 6118 <malloc+0x96a>
     cf0:	00005097          	auipc	ra,0x5
     cf4:	a00080e7          	jalr	-1536(ra) # 56f0 <printf>
    exit(1);
     cf8:	4505                	li	a0,1
     cfa:	00004097          	auipc	ra,0x4
     cfe:	67e080e7          	jalr	1662(ra) # 5378 <exit>
    printf("%s: unlinkread write failed\n", s);
     d02:	85ce                	mv	a1,s3
     d04:	00005517          	auipc	a0,0x5
     d08:	43450513          	addi	a0,a0,1076 # 6138 <malloc+0x98a>
     d0c:	00005097          	auipc	ra,0x5
     d10:	9e4080e7          	jalr	-1564(ra) # 56f0 <printf>
    exit(1);
     d14:	4505                	li	a0,1
     d16:	00004097          	auipc	ra,0x4
     d1a:	662080e7          	jalr	1634(ra) # 5378 <exit>

0000000000000d1e <linktest>:
{
     d1e:	1101                	addi	sp,sp,-32
     d20:	ec06                	sd	ra,24(sp)
     d22:	e822                	sd	s0,16(sp)
     d24:	e426                	sd	s1,8(sp)
     d26:	e04a                	sd	s2,0(sp)
     d28:	1000                	addi	s0,sp,32
     d2a:	892a                	mv	s2,a0
  unlink("lf1");
     d2c:	00005517          	auipc	a0,0x5
     d30:	42c50513          	addi	a0,a0,1068 # 6158 <malloc+0x9aa>
     d34:	00004097          	auipc	ra,0x4
     d38:	694080e7          	jalr	1684(ra) # 53c8 <unlink>
  unlink("lf2");
     d3c:	00005517          	auipc	a0,0x5
     d40:	42450513          	addi	a0,a0,1060 # 6160 <malloc+0x9b2>
     d44:	00004097          	auipc	ra,0x4
     d48:	684080e7          	jalr	1668(ra) # 53c8 <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
     d4c:	20200593          	li	a1,514
     d50:	00005517          	auipc	a0,0x5
     d54:	40850513          	addi	a0,a0,1032 # 6158 <malloc+0x9aa>
     d58:	00004097          	auipc	ra,0x4
     d5c:	660080e7          	jalr	1632(ra) # 53b8 <open>
  if(fd < 0){
     d60:	10054763          	bltz	a0,e6e <linktest+0x150>
     d64:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
     d66:	4615                	li	a2,5
     d68:	00005597          	auipc	a1,0x5
     d6c:	34058593          	addi	a1,a1,832 # 60a8 <malloc+0x8fa>
     d70:	00004097          	auipc	ra,0x4
     d74:	628080e7          	jalr	1576(ra) # 5398 <write>
     d78:	4795                	li	a5,5
     d7a:	10f51863          	bne	a0,a5,e8a <linktest+0x16c>
  close(fd);
     d7e:	8526                	mv	a0,s1
     d80:	00004097          	auipc	ra,0x4
     d84:	620080e7          	jalr	1568(ra) # 53a0 <close>
  if(link("lf1", "lf2") < 0){
     d88:	00005597          	auipc	a1,0x5
     d8c:	3d858593          	addi	a1,a1,984 # 6160 <malloc+0x9b2>
     d90:	00005517          	auipc	a0,0x5
     d94:	3c850513          	addi	a0,a0,968 # 6158 <malloc+0x9aa>
     d98:	00004097          	auipc	ra,0x4
     d9c:	640080e7          	jalr	1600(ra) # 53d8 <link>
     da0:	10054363          	bltz	a0,ea6 <linktest+0x188>
  unlink("lf1");
     da4:	00005517          	auipc	a0,0x5
     da8:	3b450513          	addi	a0,a0,948 # 6158 <malloc+0x9aa>
     dac:	00004097          	auipc	ra,0x4
     db0:	61c080e7          	jalr	1564(ra) # 53c8 <unlink>
  if(open("lf1", 0) >= 0){
     db4:	4581                	li	a1,0
     db6:	00005517          	auipc	a0,0x5
     dba:	3a250513          	addi	a0,a0,930 # 6158 <malloc+0x9aa>
     dbe:	00004097          	auipc	ra,0x4
     dc2:	5fa080e7          	jalr	1530(ra) # 53b8 <open>
     dc6:	0e055e63          	bgez	a0,ec2 <linktest+0x1a4>
  fd = open("lf2", 0);
     dca:	4581                	li	a1,0
     dcc:	00005517          	auipc	a0,0x5
     dd0:	39450513          	addi	a0,a0,916 # 6160 <malloc+0x9b2>
     dd4:	00004097          	auipc	ra,0x4
     dd8:	5e4080e7          	jalr	1508(ra) # 53b8 <open>
     ddc:	84aa                	mv	s1,a0
  if(fd < 0){
     dde:	10054063          	bltz	a0,ede <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
     de2:	660d                	lui	a2,0x3
     de4:	0000b597          	auipc	a1,0xb
     de8:	95458593          	addi	a1,a1,-1708 # b738 <buf>
     dec:	00004097          	auipc	ra,0x4
     df0:	5a4080e7          	jalr	1444(ra) # 5390 <read>
     df4:	4795                	li	a5,5
     df6:	10f51263          	bne	a0,a5,efa <linktest+0x1dc>
  close(fd);
     dfa:	8526                	mv	a0,s1
     dfc:	00004097          	auipc	ra,0x4
     e00:	5a4080e7          	jalr	1444(ra) # 53a0 <close>
  if(link("lf2", "lf2") >= 0){
     e04:	00005597          	auipc	a1,0x5
     e08:	35c58593          	addi	a1,a1,860 # 6160 <malloc+0x9b2>
     e0c:	852e                	mv	a0,a1
     e0e:	00004097          	auipc	ra,0x4
     e12:	5ca080e7          	jalr	1482(ra) # 53d8 <link>
     e16:	10055063          	bgez	a0,f16 <linktest+0x1f8>
  unlink("lf2");
     e1a:	00005517          	auipc	a0,0x5
     e1e:	34650513          	addi	a0,a0,838 # 6160 <malloc+0x9b2>
     e22:	00004097          	auipc	ra,0x4
     e26:	5a6080e7          	jalr	1446(ra) # 53c8 <unlink>
  if(link("lf2", "lf1") >= 0){
     e2a:	00005597          	auipc	a1,0x5
     e2e:	32e58593          	addi	a1,a1,814 # 6158 <malloc+0x9aa>
     e32:	00005517          	auipc	a0,0x5
     e36:	32e50513          	addi	a0,a0,814 # 6160 <malloc+0x9b2>
     e3a:	00004097          	auipc	ra,0x4
     e3e:	59e080e7          	jalr	1438(ra) # 53d8 <link>
     e42:	0e055863          	bgez	a0,f32 <linktest+0x214>
  if(link(".", "lf1") >= 0){
     e46:	00005597          	auipc	a1,0x5
     e4a:	31258593          	addi	a1,a1,786 # 6158 <malloc+0x9aa>
     e4e:	00005517          	auipc	a0,0x5
     e52:	41a50513          	addi	a0,a0,1050 # 6268 <malloc+0xaba>
     e56:	00004097          	auipc	ra,0x4
     e5a:	582080e7          	jalr	1410(ra) # 53d8 <link>
     e5e:	0e055863          	bgez	a0,f4e <linktest+0x230>
}
     e62:	60e2                	ld	ra,24(sp)
     e64:	6442                	ld	s0,16(sp)
     e66:	64a2                	ld	s1,8(sp)
     e68:	6902                	ld	s2,0(sp)
     e6a:	6105                	addi	sp,sp,32
     e6c:	8082                	ret
    printf("%s: create lf1 failed\n", s);
     e6e:	85ca                	mv	a1,s2
     e70:	00005517          	auipc	a0,0x5
     e74:	2f850513          	addi	a0,a0,760 # 6168 <malloc+0x9ba>
     e78:	00005097          	auipc	ra,0x5
     e7c:	878080e7          	jalr	-1928(ra) # 56f0 <printf>
    exit(1);
     e80:	4505                	li	a0,1
     e82:	00004097          	auipc	ra,0x4
     e86:	4f6080e7          	jalr	1270(ra) # 5378 <exit>
    printf("%s: write lf1 failed\n", s);
     e8a:	85ca                	mv	a1,s2
     e8c:	00005517          	auipc	a0,0x5
     e90:	2f450513          	addi	a0,a0,756 # 6180 <malloc+0x9d2>
     e94:	00005097          	auipc	ra,0x5
     e98:	85c080e7          	jalr	-1956(ra) # 56f0 <printf>
    exit(1);
     e9c:	4505                	li	a0,1
     e9e:	00004097          	auipc	ra,0x4
     ea2:	4da080e7          	jalr	1242(ra) # 5378 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
     ea6:	85ca                	mv	a1,s2
     ea8:	00005517          	auipc	a0,0x5
     eac:	2f050513          	addi	a0,a0,752 # 6198 <malloc+0x9ea>
     eb0:	00005097          	auipc	ra,0x5
     eb4:	840080e7          	jalr	-1984(ra) # 56f0 <printf>
    exit(1);
     eb8:	4505                	li	a0,1
     eba:	00004097          	auipc	ra,0x4
     ebe:	4be080e7          	jalr	1214(ra) # 5378 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
     ec2:	85ca                	mv	a1,s2
     ec4:	00005517          	auipc	a0,0x5
     ec8:	2f450513          	addi	a0,a0,756 # 61b8 <malloc+0xa0a>
     ecc:	00005097          	auipc	ra,0x5
     ed0:	824080e7          	jalr	-2012(ra) # 56f0 <printf>
    exit(1);
     ed4:	4505                	li	a0,1
     ed6:	00004097          	auipc	ra,0x4
     eda:	4a2080e7          	jalr	1186(ra) # 5378 <exit>
    printf("%s: open lf2 failed\n", s);
     ede:	85ca                	mv	a1,s2
     ee0:	00005517          	auipc	a0,0x5
     ee4:	30850513          	addi	a0,a0,776 # 61e8 <malloc+0xa3a>
     ee8:	00005097          	auipc	ra,0x5
     eec:	808080e7          	jalr	-2040(ra) # 56f0 <printf>
    exit(1);
     ef0:	4505                	li	a0,1
     ef2:	00004097          	auipc	ra,0x4
     ef6:	486080e7          	jalr	1158(ra) # 5378 <exit>
    printf("%s: read lf2 failed\n", s);
     efa:	85ca                	mv	a1,s2
     efc:	00005517          	auipc	a0,0x5
     f00:	30450513          	addi	a0,a0,772 # 6200 <malloc+0xa52>
     f04:	00004097          	auipc	ra,0x4
     f08:	7ec080e7          	jalr	2028(ra) # 56f0 <printf>
    exit(1);
     f0c:	4505                	li	a0,1
     f0e:	00004097          	auipc	ra,0x4
     f12:	46a080e7          	jalr	1130(ra) # 5378 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
     f16:	85ca                	mv	a1,s2
     f18:	00005517          	auipc	a0,0x5
     f1c:	30050513          	addi	a0,a0,768 # 6218 <malloc+0xa6a>
     f20:	00004097          	auipc	ra,0x4
     f24:	7d0080e7          	jalr	2000(ra) # 56f0 <printf>
    exit(1);
     f28:	4505                	li	a0,1
     f2a:	00004097          	auipc	ra,0x4
     f2e:	44e080e7          	jalr	1102(ra) # 5378 <exit>
    printf("%s: link non-existant succeeded! oops\n", s);
     f32:	85ca                	mv	a1,s2
     f34:	00005517          	auipc	a0,0x5
     f38:	30c50513          	addi	a0,a0,780 # 6240 <malloc+0xa92>
     f3c:	00004097          	auipc	ra,0x4
     f40:	7b4080e7          	jalr	1972(ra) # 56f0 <printf>
    exit(1);
     f44:	4505                	li	a0,1
     f46:	00004097          	auipc	ra,0x4
     f4a:	432080e7          	jalr	1074(ra) # 5378 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
     f4e:	85ca                	mv	a1,s2
     f50:	00005517          	auipc	a0,0x5
     f54:	32050513          	addi	a0,a0,800 # 6270 <malloc+0xac2>
     f58:	00004097          	auipc	ra,0x4
     f5c:	798080e7          	jalr	1944(ra) # 56f0 <printf>
    exit(1);
     f60:	4505                	li	a0,1
     f62:	00004097          	auipc	ra,0x4
     f66:	416080e7          	jalr	1046(ra) # 5378 <exit>

0000000000000f6a <bigdir>:
{
     f6a:	715d                	addi	sp,sp,-80
     f6c:	e486                	sd	ra,72(sp)
     f6e:	e0a2                	sd	s0,64(sp)
     f70:	fc26                	sd	s1,56(sp)
     f72:	f84a                	sd	s2,48(sp)
     f74:	f44e                	sd	s3,40(sp)
     f76:	f052                	sd	s4,32(sp)
     f78:	ec56                	sd	s5,24(sp)
     f7a:	e85a                	sd	s6,16(sp)
     f7c:	0880                	addi	s0,sp,80
     f7e:	89aa                	mv	s3,a0
  unlink("bd");
     f80:	00005517          	auipc	a0,0x5
     f84:	31050513          	addi	a0,a0,784 # 6290 <malloc+0xae2>
     f88:	00004097          	auipc	ra,0x4
     f8c:	440080e7          	jalr	1088(ra) # 53c8 <unlink>
  fd = open("bd", O_CREATE);
     f90:	20000593          	li	a1,512
     f94:	00005517          	auipc	a0,0x5
     f98:	2fc50513          	addi	a0,a0,764 # 6290 <malloc+0xae2>
     f9c:	00004097          	auipc	ra,0x4
     fa0:	41c080e7          	jalr	1052(ra) # 53b8 <open>
  if(fd < 0){
     fa4:	0c054963          	bltz	a0,1076 <bigdir+0x10c>
  close(fd);
     fa8:	00004097          	auipc	ra,0x4
     fac:	3f8080e7          	jalr	1016(ra) # 53a0 <close>
  for(i = 0; i < N; i++){
     fb0:	4901                	li	s2,0
    name[0] = 'x';
     fb2:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
     fb6:	00005a17          	auipc	s4,0x5
     fba:	2daa0a13          	addi	s4,s4,730 # 6290 <malloc+0xae2>
  for(i = 0; i < N; i++){
     fbe:	1f400b13          	li	s6,500
    name[0] = 'x';
     fc2:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
     fc6:	41f9579b          	sraiw	a5,s2,0x1f
     fca:	01a7d71b          	srliw	a4,a5,0x1a
     fce:	012707bb          	addw	a5,a4,s2
     fd2:	4067d69b          	sraiw	a3,a5,0x6
     fd6:	0306869b          	addiw	a3,a3,48
     fda:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
     fde:	03f7f793          	andi	a5,a5,63
     fe2:	9f99                	subw	a5,a5,a4
     fe4:	0307879b          	addiw	a5,a5,48
     fe8:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
     fec:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
     ff0:	fb040593          	addi	a1,s0,-80
     ff4:	8552                	mv	a0,s4
     ff6:	00004097          	auipc	ra,0x4
     ffa:	3e2080e7          	jalr	994(ra) # 53d8 <link>
     ffe:	84aa                	mv	s1,a0
    1000:	e949                	bnez	a0,1092 <bigdir+0x128>
  for(i = 0; i < N; i++){
    1002:	2905                	addiw	s2,s2,1
    1004:	fb691fe3          	bne	s2,s6,fc2 <bigdir+0x58>
  unlink("bd");
    1008:	00005517          	auipc	a0,0x5
    100c:	28850513          	addi	a0,a0,648 # 6290 <malloc+0xae2>
    1010:	00004097          	auipc	ra,0x4
    1014:	3b8080e7          	jalr	952(ra) # 53c8 <unlink>
    name[0] = 'x';
    1018:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
    101c:	1f400a13          	li	s4,500
    name[0] = 'x';
    1020:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    1024:	41f4d79b          	sraiw	a5,s1,0x1f
    1028:	01a7d71b          	srliw	a4,a5,0x1a
    102c:	009707bb          	addw	a5,a4,s1
    1030:	4067d69b          	sraiw	a3,a5,0x6
    1034:	0306869b          	addiw	a3,a3,48
    1038:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    103c:	03f7f793          	andi	a5,a5,63
    1040:	9f99                	subw	a5,a5,a4
    1042:	0307879b          	addiw	a5,a5,48
    1046:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    104a:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
    104e:	fb040513          	addi	a0,s0,-80
    1052:	00004097          	auipc	ra,0x4
    1056:	376080e7          	jalr	886(ra) # 53c8 <unlink>
    105a:	ed21                	bnez	a0,10b2 <bigdir+0x148>
  for(i = 0; i < N; i++){
    105c:	2485                	addiw	s1,s1,1
    105e:	fd4491e3          	bne	s1,s4,1020 <bigdir+0xb6>
}
    1062:	60a6                	ld	ra,72(sp)
    1064:	6406                	ld	s0,64(sp)
    1066:	74e2                	ld	s1,56(sp)
    1068:	7942                	ld	s2,48(sp)
    106a:	79a2                	ld	s3,40(sp)
    106c:	7a02                	ld	s4,32(sp)
    106e:	6ae2                	ld	s5,24(sp)
    1070:	6b42                	ld	s6,16(sp)
    1072:	6161                	addi	sp,sp,80
    1074:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    1076:	85ce                	mv	a1,s3
    1078:	00005517          	auipc	a0,0x5
    107c:	22050513          	addi	a0,a0,544 # 6298 <malloc+0xaea>
    1080:	00004097          	auipc	ra,0x4
    1084:	670080e7          	jalr	1648(ra) # 56f0 <printf>
    exit(1);
    1088:	4505                	li	a0,1
    108a:	00004097          	auipc	ra,0x4
    108e:	2ee080e7          	jalr	750(ra) # 5378 <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    1092:	fb040613          	addi	a2,s0,-80
    1096:	85ce                	mv	a1,s3
    1098:	00005517          	auipc	a0,0x5
    109c:	22050513          	addi	a0,a0,544 # 62b8 <malloc+0xb0a>
    10a0:	00004097          	auipc	ra,0x4
    10a4:	650080e7          	jalr	1616(ra) # 56f0 <printf>
      exit(1);
    10a8:	4505                	li	a0,1
    10aa:	00004097          	auipc	ra,0x4
    10ae:	2ce080e7          	jalr	718(ra) # 5378 <exit>
      printf("%s: bigdir unlink failed", s);
    10b2:	85ce                	mv	a1,s3
    10b4:	00005517          	auipc	a0,0x5
    10b8:	22450513          	addi	a0,a0,548 # 62d8 <malloc+0xb2a>
    10bc:	00004097          	auipc	ra,0x4
    10c0:	634080e7          	jalr	1588(ra) # 56f0 <printf>
      exit(1);
    10c4:	4505                	li	a0,1
    10c6:	00004097          	auipc	ra,0x4
    10ca:	2b2080e7          	jalr	690(ra) # 5378 <exit>

00000000000010ce <validatetest>:
{
    10ce:	7139                	addi	sp,sp,-64
    10d0:	fc06                	sd	ra,56(sp)
    10d2:	f822                	sd	s0,48(sp)
    10d4:	f426                	sd	s1,40(sp)
    10d6:	f04a                	sd	s2,32(sp)
    10d8:	ec4e                	sd	s3,24(sp)
    10da:	e852                	sd	s4,16(sp)
    10dc:	e456                	sd	s5,8(sp)
    10de:	e05a                	sd	s6,0(sp)
    10e0:	0080                	addi	s0,sp,64
    10e2:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    10e4:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
    10e6:	00005997          	auipc	s3,0x5
    10ea:	21298993          	addi	s3,s3,530 # 62f8 <malloc+0xb4a>
    10ee:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    10f0:	6a85                	lui	s5,0x1
    10f2:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    10f6:	85a6                	mv	a1,s1
    10f8:	854e                	mv	a0,s3
    10fa:	00004097          	auipc	ra,0x4
    10fe:	2de080e7          	jalr	734(ra) # 53d8 <link>
    1102:	01251f63          	bne	a0,s2,1120 <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1106:	94d6                	add	s1,s1,s5
    1108:	ff4497e3          	bne	s1,s4,10f6 <validatetest+0x28>
}
    110c:	70e2                	ld	ra,56(sp)
    110e:	7442                	ld	s0,48(sp)
    1110:	74a2                	ld	s1,40(sp)
    1112:	7902                	ld	s2,32(sp)
    1114:	69e2                	ld	s3,24(sp)
    1116:	6a42                	ld	s4,16(sp)
    1118:	6aa2                	ld	s5,8(sp)
    111a:	6b02                	ld	s6,0(sp)
    111c:	6121                	addi	sp,sp,64
    111e:	8082                	ret
      printf("%s: link should not succeed\n", s);
    1120:	85da                	mv	a1,s6
    1122:	00005517          	auipc	a0,0x5
    1126:	1e650513          	addi	a0,a0,486 # 6308 <malloc+0xb5a>
    112a:	00004097          	auipc	ra,0x4
    112e:	5c6080e7          	jalr	1478(ra) # 56f0 <printf>
      exit(1);
    1132:	4505                	li	a0,1
    1134:	00004097          	auipc	ra,0x4
    1138:	244080e7          	jalr	580(ra) # 5378 <exit>

000000000000113c <pgbug>:
// regression test. copyin(), copyout(), and copyinstr() used to cast
// the virtual page address to uint, which (with certain wild system
// call arguments) resulted in a kernel page faults.
void
pgbug(char *s)
{
    113c:	7179                	addi	sp,sp,-48
    113e:	f406                	sd	ra,40(sp)
    1140:	f022                	sd	s0,32(sp)
    1142:	ec26                	sd	s1,24(sp)
    1144:	1800                	addi	s0,sp,48
  char *argv[1];
  argv[0] = 0;
    1146:	fc043c23          	sd	zero,-40(s0)
  exec((char*)0xeaeb0b5b00002f5e, argv);
    114a:	00007497          	auipc	s1,0x7
    114e:	db64b483          	ld	s1,-586(s1) # 7f00 <__SDATA_BEGIN__>
    1152:	fd840593          	addi	a1,s0,-40
    1156:	8526                	mv	a0,s1
    1158:	00004097          	auipc	ra,0x4
    115c:	258080e7          	jalr	600(ra) # 53b0 <exec>

  pipe((int*)0xeaeb0b5b00002f5e);
    1160:	8526                	mv	a0,s1
    1162:	00004097          	auipc	ra,0x4
    1166:	226080e7          	jalr	550(ra) # 5388 <pipe>

  exit(0);
    116a:	4501                	li	a0,0
    116c:	00004097          	auipc	ra,0x4
    1170:	20c080e7          	jalr	524(ra) # 5378 <exit>

0000000000001174 <badarg>:

// regression test. test whether exec() leaks memory if one of the
// arguments is invalid. the test passes if the kernel doesn't panic.
void
badarg(char *s)
{
    1174:	7139                	addi	sp,sp,-64
    1176:	fc06                	sd	ra,56(sp)
    1178:	f822                	sd	s0,48(sp)
    117a:	f426                	sd	s1,40(sp)
    117c:	f04a                	sd	s2,32(sp)
    117e:	ec4e                	sd	s3,24(sp)
    1180:	0080                	addi	s0,sp,64
    1182:	64b1                	lui	s1,0xc
    1184:	35048493          	addi	s1,s1,848 # c350 <buf+0xc18>
  for(int i = 0; i < 50000; i++){
    char *argv[2];
    argv[0] = (char*)0xffffffff;
    1188:	597d                	li	s2,-1
    118a:	02095913          	srli	s2,s2,0x20
    argv[1] = 0;
    exec("echo", argv);
    118e:	00005997          	auipc	s3,0x5
    1192:	a4298993          	addi	s3,s3,-1470 # 5bd0 <malloc+0x422>
    argv[0] = (char*)0xffffffff;
    1196:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    119a:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    119e:	fc040593          	addi	a1,s0,-64
    11a2:	854e                	mv	a0,s3
    11a4:	00004097          	auipc	ra,0x4
    11a8:	20c080e7          	jalr	524(ra) # 53b0 <exec>
  for(int i = 0; i < 50000; i++){
    11ac:	34fd                	addiw	s1,s1,-1
    11ae:	f4e5                	bnez	s1,1196 <badarg+0x22>
  }
  
  exit(0);
    11b0:	4501                	li	a0,0
    11b2:	00004097          	auipc	ra,0x4
    11b6:	1c6080e7          	jalr	454(ra) # 5378 <exit>

00000000000011ba <copyinstr2>:
{
    11ba:	7155                	addi	sp,sp,-208
    11bc:	e586                	sd	ra,200(sp)
    11be:	e1a2                	sd	s0,192(sp)
    11c0:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    11c2:	f6840793          	addi	a5,s0,-152
    11c6:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    11ca:	07800713          	li	a4,120
    11ce:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    11d2:	0785                	addi	a5,a5,1
    11d4:	fed79de3          	bne	a5,a3,11ce <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    11d8:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    11dc:	f6840513          	addi	a0,s0,-152
    11e0:	00004097          	auipc	ra,0x4
    11e4:	1e8080e7          	jalr	488(ra) # 53c8 <unlink>
  if(ret != -1){
    11e8:	57fd                	li	a5,-1
    11ea:	0ef51063          	bne	a0,a5,12ca <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
    11ee:	20100593          	li	a1,513
    11f2:	f6840513          	addi	a0,s0,-152
    11f6:	00004097          	auipc	ra,0x4
    11fa:	1c2080e7          	jalr	450(ra) # 53b8 <open>
  if(fd != -1){
    11fe:	57fd                	li	a5,-1
    1200:	0ef51563          	bne	a0,a5,12ea <copyinstr2+0x130>
  ret = link(b, b);
    1204:	f6840593          	addi	a1,s0,-152
    1208:	852e                	mv	a0,a1
    120a:	00004097          	auipc	ra,0x4
    120e:	1ce080e7          	jalr	462(ra) # 53d8 <link>
  if(ret != -1){
    1212:	57fd                	li	a5,-1
    1214:	0ef51b63          	bne	a0,a5,130a <copyinstr2+0x150>
  char *args[] = { "xx", 0 };
    1218:	00006797          	auipc	a5,0x6
    121c:	1b078793          	addi	a5,a5,432 # 73c8 <malloc+0x1c1a>
    1220:	f4f43c23          	sd	a5,-168(s0)
    1224:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    1228:	f5840593          	addi	a1,s0,-168
    122c:	f6840513          	addi	a0,s0,-152
    1230:	00004097          	auipc	ra,0x4
    1234:	180080e7          	jalr	384(ra) # 53b0 <exec>
  if(ret != -1){
    1238:	57fd                	li	a5,-1
    123a:	0ef51963          	bne	a0,a5,132c <copyinstr2+0x172>
  int pid = fork();
    123e:	00004097          	auipc	ra,0x4
    1242:	132080e7          	jalr	306(ra) # 5370 <fork>
  if(pid < 0){
    1246:	10054363          	bltz	a0,134c <copyinstr2+0x192>
  if(pid == 0){
    124a:	12051463          	bnez	a0,1372 <copyinstr2+0x1b8>
    124e:	00007797          	auipc	a5,0x7
    1252:	dd278793          	addi	a5,a5,-558 # 8020 <big.1265>
    1256:	00008697          	auipc	a3,0x8
    125a:	dca68693          	addi	a3,a3,-566 # 9020 <__global_pointer$+0x920>
      big[i] = 'x';
    125e:	07800713          	li	a4,120
    1262:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    1266:	0785                	addi	a5,a5,1
    1268:	fed79de3          	bne	a5,a3,1262 <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    126c:	00008797          	auipc	a5,0x8
    1270:	da078a23          	sb	zero,-588(a5) # 9020 <__global_pointer$+0x920>
    char *args2[] = { big, big, big, 0 };
    1274:	00007797          	auipc	a5,0x7
    1278:	8cc78793          	addi	a5,a5,-1844 # 7b40 <malloc+0x2392>
    127c:	6390                	ld	a2,0(a5)
    127e:	6794                	ld	a3,8(a5)
    1280:	6b98                	ld	a4,16(a5)
    1282:	6f9c                	ld	a5,24(a5)
    1284:	f2c43823          	sd	a2,-208(s0)
    1288:	f2d43c23          	sd	a3,-200(s0)
    128c:	f4e43023          	sd	a4,-192(s0)
    1290:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    1294:	f3040593          	addi	a1,s0,-208
    1298:	00005517          	auipc	a0,0x5
    129c:	93850513          	addi	a0,a0,-1736 # 5bd0 <malloc+0x422>
    12a0:	00004097          	auipc	ra,0x4
    12a4:	110080e7          	jalr	272(ra) # 53b0 <exec>
    if(ret != -1){
    12a8:	57fd                	li	a5,-1
    12aa:	0af50e63          	beq	a0,a5,1366 <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    12ae:	55fd                	li	a1,-1
    12b0:	00005517          	auipc	a0,0x5
    12b4:	10050513          	addi	a0,a0,256 # 63b0 <malloc+0xc02>
    12b8:	00004097          	auipc	ra,0x4
    12bc:	438080e7          	jalr	1080(ra) # 56f0 <printf>
      exit(1);
    12c0:	4505                	li	a0,1
    12c2:	00004097          	auipc	ra,0x4
    12c6:	0b6080e7          	jalr	182(ra) # 5378 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    12ca:	862a                	mv	a2,a0
    12cc:	f6840593          	addi	a1,s0,-152
    12d0:	00005517          	auipc	a0,0x5
    12d4:	05850513          	addi	a0,a0,88 # 6328 <malloc+0xb7a>
    12d8:	00004097          	auipc	ra,0x4
    12dc:	418080e7          	jalr	1048(ra) # 56f0 <printf>
    exit(1);
    12e0:	4505                	li	a0,1
    12e2:	00004097          	auipc	ra,0x4
    12e6:	096080e7          	jalr	150(ra) # 5378 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    12ea:	862a                	mv	a2,a0
    12ec:	f6840593          	addi	a1,s0,-152
    12f0:	00005517          	auipc	a0,0x5
    12f4:	05850513          	addi	a0,a0,88 # 6348 <malloc+0xb9a>
    12f8:	00004097          	auipc	ra,0x4
    12fc:	3f8080e7          	jalr	1016(ra) # 56f0 <printf>
    exit(1);
    1300:	4505                	li	a0,1
    1302:	00004097          	auipc	ra,0x4
    1306:	076080e7          	jalr	118(ra) # 5378 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    130a:	86aa                	mv	a3,a0
    130c:	f6840613          	addi	a2,s0,-152
    1310:	85b2                	mv	a1,a2
    1312:	00005517          	auipc	a0,0x5
    1316:	05650513          	addi	a0,a0,86 # 6368 <malloc+0xbba>
    131a:	00004097          	auipc	ra,0x4
    131e:	3d6080e7          	jalr	982(ra) # 56f0 <printf>
    exit(1);
    1322:	4505                	li	a0,1
    1324:	00004097          	auipc	ra,0x4
    1328:	054080e7          	jalr	84(ra) # 5378 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    132c:	567d                	li	a2,-1
    132e:	f6840593          	addi	a1,s0,-152
    1332:	00005517          	auipc	a0,0x5
    1336:	05e50513          	addi	a0,a0,94 # 6390 <malloc+0xbe2>
    133a:	00004097          	auipc	ra,0x4
    133e:	3b6080e7          	jalr	950(ra) # 56f0 <printf>
    exit(1);
    1342:	4505                	li	a0,1
    1344:	00004097          	auipc	ra,0x4
    1348:	034080e7          	jalr	52(ra) # 5378 <exit>
    printf("fork failed\n");
    134c:	00005517          	auipc	a0,0x5
    1350:	4ac50513          	addi	a0,a0,1196 # 67f8 <malloc+0x104a>
    1354:	00004097          	auipc	ra,0x4
    1358:	39c080e7          	jalr	924(ra) # 56f0 <printf>
    exit(1);
    135c:	4505                	li	a0,1
    135e:	00004097          	auipc	ra,0x4
    1362:	01a080e7          	jalr	26(ra) # 5378 <exit>
    exit(747); // OK
    1366:	2eb00513          	li	a0,747
    136a:	00004097          	auipc	ra,0x4
    136e:	00e080e7          	jalr	14(ra) # 5378 <exit>
  int st = 0;
    1372:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    1376:	f5440513          	addi	a0,s0,-172
    137a:	00004097          	auipc	ra,0x4
    137e:	006080e7          	jalr	6(ra) # 5380 <wait>
  if(st != 747){
    1382:	f5442703          	lw	a4,-172(s0)
    1386:	2eb00793          	li	a5,747
    138a:	00f71663          	bne	a4,a5,1396 <copyinstr2+0x1dc>
}
    138e:	60ae                	ld	ra,200(sp)
    1390:	640e                	ld	s0,192(sp)
    1392:	6169                	addi	sp,sp,208
    1394:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    1396:	00005517          	auipc	a0,0x5
    139a:	04250513          	addi	a0,a0,66 # 63d8 <malloc+0xc2a>
    139e:	00004097          	auipc	ra,0x4
    13a2:	352080e7          	jalr	850(ra) # 56f0 <printf>
    exit(1);
    13a6:	4505                	li	a0,1
    13a8:	00004097          	auipc	ra,0x4
    13ac:	fd0080e7          	jalr	-48(ra) # 5378 <exit>

00000000000013b0 <truncate3>:
{
    13b0:	7159                	addi	sp,sp,-112
    13b2:	f486                	sd	ra,104(sp)
    13b4:	f0a2                	sd	s0,96(sp)
    13b6:	eca6                	sd	s1,88(sp)
    13b8:	e8ca                	sd	s2,80(sp)
    13ba:	e4ce                	sd	s3,72(sp)
    13bc:	e0d2                	sd	s4,64(sp)
    13be:	fc56                	sd	s5,56(sp)
    13c0:	1880                	addi	s0,sp,112
    13c2:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    13c4:	60100593          	li	a1,1537
    13c8:	00005517          	auipc	a0,0x5
    13cc:	86050513          	addi	a0,a0,-1952 # 5c28 <malloc+0x47a>
    13d0:	00004097          	auipc	ra,0x4
    13d4:	fe8080e7          	jalr	-24(ra) # 53b8 <open>
    13d8:	00004097          	auipc	ra,0x4
    13dc:	fc8080e7          	jalr	-56(ra) # 53a0 <close>
  pid = fork();
    13e0:	00004097          	auipc	ra,0x4
    13e4:	f90080e7          	jalr	-112(ra) # 5370 <fork>
  if(pid < 0){
    13e8:	08054063          	bltz	a0,1468 <truncate3+0xb8>
  if(pid == 0){
    13ec:	e969                	bnez	a0,14be <truncate3+0x10e>
    13ee:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    13f2:	00005a17          	auipc	s4,0x5
    13f6:	836a0a13          	addi	s4,s4,-1994 # 5c28 <malloc+0x47a>
      int n = write(fd, "1234567890", 10);
    13fa:	00005a97          	auipc	s5,0x5
    13fe:	03ea8a93          	addi	s5,s5,62 # 6438 <malloc+0xc8a>
      int fd = open("truncfile", O_WRONLY);
    1402:	4585                	li	a1,1
    1404:	8552                	mv	a0,s4
    1406:	00004097          	auipc	ra,0x4
    140a:	fb2080e7          	jalr	-78(ra) # 53b8 <open>
    140e:	84aa                	mv	s1,a0
      if(fd < 0){
    1410:	06054a63          	bltz	a0,1484 <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
    1414:	4629                	li	a2,10
    1416:	85d6                	mv	a1,s5
    1418:	00004097          	auipc	ra,0x4
    141c:	f80080e7          	jalr	-128(ra) # 5398 <write>
      if(n != 10){
    1420:	47a9                	li	a5,10
    1422:	06f51f63          	bne	a0,a5,14a0 <truncate3+0xf0>
      close(fd);
    1426:	8526                	mv	a0,s1
    1428:	00004097          	auipc	ra,0x4
    142c:	f78080e7          	jalr	-136(ra) # 53a0 <close>
      fd = open("truncfile", O_RDONLY);
    1430:	4581                	li	a1,0
    1432:	8552                	mv	a0,s4
    1434:	00004097          	auipc	ra,0x4
    1438:	f84080e7          	jalr	-124(ra) # 53b8 <open>
    143c:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    143e:	02000613          	li	a2,32
    1442:	f9840593          	addi	a1,s0,-104
    1446:	00004097          	auipc	ra,0x4
    144a:	f4a080e7          	jalr	-182(ra) # 5390 <read>
      close(fd);
    144e:	8526                	mv	a0,s1
    1450:	00004097          	auipc	ra,0x4
    1454:	f50080e7          	jalr	-176(ra) # 53a0 <close>
    for(int i = 0; i < 100; i++){
    1458:	39fd                	addiw	s3,s3,-1
    145a:	fa0994e3          	bnez	s3,1402 <truncate3+0x52>
    exit(0);
    145e:	4501                	li	a0,0
    1460:	00004097          	auipc	ra,0x4
    1464:	f18080e7          	jalr	-232(ra) # 5378 <exit>
    printf("%s: fork failed\n", s);
    1468:	85ca                	mv	a1,s2
    146a:	00005517          	auipc	a0,0x5
    146e:	f9e50513          	addi	a0,a0,-98 # 6408 <malloc+0xc5a>
    1472:	00004097          	auipc	ra,0x4
    1476:	27e080e7          	jalr	638(ra) # 56f0 <printf>
    exit(1);
    147a:	4505                	li	a0,1
    147c:	00004097          	auipc	ra,0x4
    1480:	efc080e7          	jalr	-260(ra) # 5378 <exit>
        printf("%s: open failed\n", s);
    1484:	85ca                	mv	a1,s2
    1486:	00005517          	auipc	a0,0x5
    148a:	f9a50513          	addi	a0,a0,-102 # 6420 <malloc+0xc72>
    148e:	00004097          	auipc	ra,0x4
    1492:	262080e7          	jalr	610(ra) # 56f0 <printf>
        exit(1);
    1496:	4505                	li	a0,1
    1498:	00004097          	auipc	ra,0x4
    149c:	ee0080e7          	jalr	-288(ra) # 5378 <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    14a0:	862a                	mv	a2,a0
    14a2:	85ca                	mv	a1,s2
    14a4:	00005517          	auipc	a0,0x5
    14a8:	fa450513          	addi	a0,a0,-92 # 6448 <malloc+0xc9a>
    14ac:	00004097          	auipc	ra,0x4
    14b0:	244080e7          	jalr	580(ra) # 56f0 <printf>
        exit(1);
    14b4:	4505                	li	a0,1
    14b6:	00004097          	auipc	ra,0x4
    14ba:	ec2080e7          	jalr	-318(ra) # 5378 <exit>
    14be:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    14c2:	00004a17          	auipc	s4,0x4
    14c6:	766a0a13          	addi	s4,s4,1894 # 5c28 <malloc+0x47a>
    int n = write(fd, "xxx", 3);
    14ca:	00005a97          	auipc	s5,0x5
    14ce:	f9ea8a93          	addi	s5,s5,-98 # 6468 <malloc+0xcba>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    14d2:	60100593          	li	a1,1537
    14d6:	8552                	mv	a0,s4
    14d8:	00004097          	auipc	ra,0x4
    14dc:	ee0080e7          	jalr	-288(ra) # 53b8 <open>
    14e0:	84aa                	mv	s1,a0
    if(fd < 0){
    14e2:	04054763          	bltz	a0,1530 <truncate3+0x180>
    int n = write(fd, "xxx", 3);
    14e6:	460d                	li	a2,3
    14e8:	85d6                	mv	a1,s5
    14ea:	00004097          	auipc	ra,0x4
    14ee:	eae080e7          	jalr	-338(ra) # 5398 <write>
    if(n != 3){
    14f2:	478d                	li	a5,3
    14f4:	04f51c63          	bne	a0,a5,154c <truncate3+0x19c>
    close(fd);
    14f8:	8526                	mv	a0,s1
    14fa:	00004097          	auipc	ra,0x4
    14fe:	ea6080e7          	jalr	-346(ra) # 53a0 <close>
  for(int i = 0; i < 150; i++){
    1502:	39fd                	addiw	s3,s3,-1
    1504:	fc0997e3          	bnez	s3,14d2 <truncate3+0x122>
  wait(&xstatus);
    1508:	fbc40513          	addi	a0,s0,-68
    150c:	00004097          	auipc	ra,0x4
    1510:	e74080e7          	jalr	-396(ra) # 5380 <wait>
  unlink("truncfile");
    1514:	00004517          	auipc	a0,0x4
    1518:	71450513          	addi	a0,a0,1812 # 5c28 <malloc+0x47a>
    151c:	00004097          	auipc	ra,0x4
    1520:	eac080e7          	jalr	-340(ra) # 53c8 <unlink>
  exit(xstatus);
    1524:	fbc42503          	lw	a0,-68(s0)
    1528:	00004097          	auipc	ra,0x4
    152c:	e50080e7          	jalr	-432(ra) # 5378 <exit>
      printf("%s: open failed\n", s);
    1530:	85ca                	mv	a1,s2
    1532:	00005517          	auipc	a0,0x5
    1536:	eee50513          	addi	a0,a0,-274 # 6420 <malloc+0xc72>
    153a:	00004097          	auipc	ra,0x4
    153e:	1b6080e7          	jalr	438(ra) # 56f0 <printf>
      exit(1);
    1542:	4505                	li	a0,1
    1544:	00004097          	auipc	ra,0x4
    1548:	e34080e7          	jalr	-460(ra) # 5378 <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    154c:	862a                	mv	a2,a0
    154e:	85ca                	mv	a1,s2
    1550:	00005517          	auipc	a0,0x5
    1554:	f2050513          	addi	a0,a0,-224 # 6470 <malloc+0xcc2>
    1558:	00004097          	auipc	ra,0x4
    155c:	198080e7          	jalr	408(ra) # 56f0 <printf>
      exit(1);
    1560:	4505                	li	a0,1
    1562:	00004097          	auipc	ra,0x4
    1566:	e16080e7          	jalr	-490(ra) # 5378 <exit>

000000000000156a <exectest>:
{
    156a:	715d                	addi	sp,sp,-80
    156c:	e486                	sd	ra,72(sp)
    156e:	e0a2                	sd	s0,64(sp)
    1570:	fc26                	sd	s1,56(sp)
    1572:	f84a                	sd	s2,48(sp)
    1574:	0880                	addi	s0,sp,80
    1576:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    1578:	00004797          	auipc	a5,0x4
    157c:	65878793          	addi	a5,a5,1624 # 5bd0 <malloc+0x422>
    1580:	fcf43023          	sd	a5,-64(s0)
    1584:	00005797          	auipc	a5,0x5
    1588:	f0c78793          	addi	a5,a5,-244 # 6490 <malloc+0xce2>
    158c:	fcf43423          	sd	a5,-56(s0)
    1590:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    1594:	00005517          	auipc	a0,0x5
    1598:	f0450513          	addi	a0,a0,-252 # 6498 <malloc+0xcea>
    159c:	00004097          	auipc	ra,0x4
    15a0:	e2c080e7          	jalr	-468(ra) # 53c8 <unlink>
  pid = fork();
    15a4:	00004097          	auipc	ra,0x4
    15a8:	dcc080e7          	jalr	-564(ra) # 5370 <fork>
  if(pid < 0) {
    15ac:	04054663          	bltz	a0,15f8 <exectest+0x8e>
    15b0:	84aa                	mv	s1,a0
  if(pid == 0) {
    15b2:	e959                	bnez	a0,1648 <exectest+0xde>
    close(1);
    15b4:	4505                	li	a0,1
    15b6:	00004097          	auipc	ra,0x4
    15ba:	dea080e7          	jalr	-534(ra) # 53a0 <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    15be:	20100593          	li	a1,513
    15c2:	00005517          	auipc	a0,0x5
    15c6:	ed650513          	addi	a0,a0,-298 # 6498 <malloc+0xcea>
    15ca:	00004097          	auipc	ra,0x4
    15ce:	dee080e7          	jalr	-530(ra) # 53b8 <open>
    if(fd < 0) {
    15d2:	04054163          	bltz	a0,1614 <exectest+0xaa>
    if(fd != 1) {
    15d6:	4785                	li	a5,1
    15d8:	04f50c63          	beq	a0,a5,1630 <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    15dc:	85ca                	mv	a1,s2
    15de:	00005517          	auipc	a0,0x5
    15e2:	eda50513          	addi	a0,a0,-294 # 64b8 <malloc+0xd0a>
    15e6:	00004097          	auipc	ra,0x4
    15ea:	10a080e7          	jalr	266(ra) # 56f0 <printf>
      exit(1);
    15ee:	4505                	li	a0,1
    15f0:	00004097          	auipc	ra,0x4
    15f4:	d88080e7          	jalr	-632(ra) # 5378 <exit>
     printf("%s: fork failed\n", s);
    15f8:	85ca                	mv	a1,s2
    15fa:	00005517          	auipc	a0,0x5
    15fe:	e0e50513          	addi	a0,a0,-498 # 6408 <malloc+0xc5a>
    1602:	00004097          	auipc	ra,0x4
    1606:	0ee080e7          	jalr	238(ra) # 56f0 <printf>
     exit(1);
    160a:	4505                	li	a0,1
    160c:	00004097          	auipc	ra,0x4
    1610:	d6c080e7          	jalr	-660(ra) # 5378 <exit>
      printf("%s: create failed\n", s);
    1614:	85ca                	mv	a1,s2
    1616:	00005517          	auipc	a0,0x5
    161a:	e8a50513          	addi	a0,a0,-374 # 64a0 <malloc+0xcf2>
    161e:	00004097          	auipc	ra,0x4
    1622:	0d2080e7          	jalr	210(ra) # 56f0 <printf>
      exit(1);
    1626:	4505                	li	a0,1
    1628:	00004097          	auipc	ra,0x4
    162c:	d50080e7          	jalr	-688(ra) # 5378 <exit>
    if(exec("echo", echoargv) < 0){
    1630:	fc040593          	addi	a1,s0,-64
    1634:	00004517          	auipc	a0,0x4
    1638:	59c50513          	addi	a0,a0,1436 # 5bd0 <malloc+0x422>
    163c:	00004097          	auipc	ra,0x4
    1640:	d74080e7          	jalr	-652(ra) # 53b0 <exec>
    1644:	02054163          	bltz	a0,1666 <exectest+0xfc>
  if (wait(&xstatus) != pid) {
    1648:	fdc40513          	addi	a0,s0,-36
    164c:	00004097          	auipc	ra,0x4
    1650:	d34080e7          	jalr	-716(ra) # 5380 <wait>
    1654:	02951763          	bne	a0,s1,1682 <exectest+0x118>
  if(xstatus != 0)
    1658:	fdc42503          	lw	a0,-36(s0)
    165c:	cd0d                	beqz	a0,1696 <exectest+0x12c>
    exit(xstatus);
    165e:	00004097          	auipc	ra,0x4
    1662:	d1a080e7          	jalr	-742(ra) # 5378 <exit>
      printf("%s: exec echo failed\n", s);
    1666:	85ca                	mv	a1,s2
    1668:	00005517          	auipc	a0,0x5
    166c:	e6050513          	addi	a0,a0,-416 # 64c8 <malloc+0xd1a>
    1670:	00004097          	auipc	ra,0x4
    1674:	080080e7          	jalr	128(ra) # 56f0 <printf>
      exit(1);
    1678:	4505                	li	a0,1
    167a:	00004097          	auipc	ra,0x4
    167e:	cfe080e7          	jalr	-770(ra) # 5378 <exit>
    printf("%s: wait failed!\n", s);
    1682:	85ca                	mv	a1,s2
    1684:	00005517          	auipc	a0,0x5
    1688:	e5c50513          	addi	a0,a0,-420 # 64e0 <malloc+0xd32>
    168c:	00004097          	auipc	ra,0x4
    1690:	064080e7          	jalr	100(ra) # 56f0 <printf>
    1694:	b7d1                	j	1658 <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    1696:	4581                	li	a1,0
    1698:	00005517          	auipc	a0,0x5
    169c:	e0050513          	addi	a0,a0,-512 # 6498 <malloc+0xcea>
    16a0:	00004097          	auipc	ra,0x4
    16a4:	d18080e7          	jalr	-744(ra) # 53b8 <open>
  if(fd < 0) {
    16a8:	02054a63          	bltz	a0,16dc <exectest+0x172>
  if (read(fd, buf, 2) != 2) {
    16ac:	4609                	li	a2,2
    16ae:	fb840593          	addi	a1,s0,-72
    16b2:	00004097          	auipc	ra,0x4
    16b6:	cde080e7          	jalr	-802(ra) # 5390 <read>
    16ba:	4789                	li	a5,2
    16bc:	02f50e63          	beq	a0,a5,16f8 <exectest+0x18e>
    printf("%s: read failed\n", s);
    16c0:	85ca                	mv	a1,s2
    16c2:	00005517          	auipc	a0,0x5
    16c6:	89e50513          	addi	a0,a0,-1890 # 5f60 <malloc+0x7b2>
    16ca:	00004097          	auipc	ra,0x4
    16ce:	026080e7          	jalr	38(ra) # 56f0 <printf>
    exit(1);
    16d2:	4505                	li	a0,1
    16d4:	00004097          	auipc	ra,0x4
    16d8:	ca4080e7          	jalr	-860(ra) # 5378 <exit>
    printf("%s: open failed\n", s);
    16dc:	85ca                	mv	a1,s2
    16de:	00005517          	auipc	a0,0x5
    16e2:	d4250513          	addi	a0,a0,-702 # 6420 <malloc+0xc72>
    16e6:	00004097          	auipc	ra,0x4
    16ea:	00a080e7          	jalr	10(ra) # 56f0 <printf>
    exit(1);
    16ee:	4505                	li	a0,1
    16f0:	00004097          	auipc	ra,0x4
    16f4:	c88080e7          	jalr	-888(ra) # 5378 <exit>
  unlink("echo-ok");
    16f8:	00005517          	auipc	a0,0x5
    16fc:	da050513          	addi	a0,a0,-608 # 6498 <malloc+0xcea>
    1700:	00004097          	auipc	ra,0x4
    1704:	cc8080e7          	jalr	-824(ra) # 53c8 <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    1708:	fb844703          	lbu	a4,-72(s0)
    170c:	04f00793          	li	a5,79
    1710:	00f71863          	bne	a4,a5,1720 <exectest+0x1b6>
    1714:	fb944703          	lbu	a4,-71(s0)
    1718:	04b00793          	li	a5,75
    171c:	02f70063          	beq	a4,a5,173c <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    1720:	85ca                	mv	a1,s2
    1722:	00005517          	auipc	a0,0x5
    1726:	dd650513          	addi	a0,a0,-554 # 64f8 <malloc+0xd4a>
    172a:	00004097          	auipc	ra,0x4
    172e:	fc6080e7          	jalr	-58(ra) # 56f0 <printf>
    exit(1);
    1732:	4505                	li	a0,1
    1734:	00004097          	auipc	ra,0x4
    1738:	c44080e7          	jalr	-956(ra) # 5378 <exit>
    exit(0);
    173c:	4501                	li	a0,0
    173e:	00004097          	auipc	ra,0x4
    1742:	c3a080e7          	jalr	-966(ra) # 5378 <exit>

0000000000001746 <pipe1>:
{
    1746:	711d                	addi	sp,sp,-96
    1748:	ec86                	sd	ra,88(sp)
    174a:	e8a2                	sd	s0,80(sp)
    174c:	e4a6                	sd	s1,72(sp)
    174e:	e0ca                	sd	s2,64(sp)
    1750:	fc4e                	sd	s3,56(sp)
    1752:	f852                	sd	s4,48(sp)
    1754:	f456                	sd	s5,40(sp)
    1756:	f05a                	sd	s6,32(sp)
    1758:	ec5e                	sd	s7,24(sp)
    175a:	1080                	addi	s0,sp,96
    175c:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    175e:	fa840513          	addi	a0,s0,-88
    1762:	00004097          	auipc	ra,0x4
    1766:	c26080e7          	jalr	-986(ra) # 5388 <pipe>
    176a:	ed25                	bnez	a0,17e2 <pipe1+0x9c>
    176c:	84aa                	mv	s1,a0
  pid = fork();
    176e:	00004097          	auipc	ra,0x4
    1772:	c02080e7          	jalr	-1022(ra) # 5370 <fork>
    1776:	8a2a                	mv	s4,a0
  if(pid == 0){
    1778:	c159                	beqz	a0,17fe <pipe1+0xb8>
  } else if(pid > 0){
    177a:	16a05e63          	blez	a0,18f6 <pipe1+0x1b0>
    close(fds[1]);
    177e:	fac42503          	lw	a0,-84(s0)
    1782:	00004097          	auipc	ra,0x4
    1786:	c1e080e7          	jalr	-994(ra) # 53a0 <close>
    total = 0;
    178a:	8a26                	mv	s4,s1
    cc = 1;
    178c:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
    178e:	0000aa97          	auipc	s5,0xa
    1792:	faaa8a93          	addi	s5,s5,-86 # b738 <buf>
      if(cc > sizeof(buf))
    1796:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
    1798:	864e                	mv	a2,s3
    179a:	85d6                	mv	a1,s5
    179c:	fa842503          	lw	a0,-88(s0)
    17a0:	00004097          	auipc	ra,0x4
    17a4:	bf0080e7          	jalr	-1040(ra) # 5390 <read>
    17a8:	10a05263          	blez	a0,18ac <pipe1+0x166>
      for(i = 0; i < n; i++){
    17ac:	0000a717          	auipc	a4,0xa
    17b0:	f8c70713          	addi	a4,a4,-116 # b738 <buf>
    17b4:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17b8:	00074683          	lbu	a3,0(a4)
    17bc:	0ff4f793          	andi	a5,s1,255
    17c0:	2485                	addiw	s1,s1,1
    17c2:	0cf69163          	bne	a3,a5,1884 <pipe1+0x13e>
      for(i = 0; i < n; i++){
    17c6:	0705                	addi	a4,a4,1
    17c8:	fec498e3          	bne	s1,a2,17b8 <pipe1+0x72>
      total += n;
    17cc:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    17d0:	0019979b          	slliw	a5,s3,0x1
    17d4:	0007899b          	sext.w	s3,a5
      if(cc > sizeof(buf))
    17d8:	013b7363          	bgeu	s6,s3,17de <pipe1+0x98>
        cc = sizeof(buf);
    17dc:	89da                	mv	s3,s6
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17de:	84b2                	mv	s1,a2
    17e0:	bf65                	j	1798 <pipe1+0x52>
    printf("%s: pipe() failed\n", s);
    17e2:	85ca                	mv	a1,s2
    17e4:	00005517          	auipc	a0,0x5
    17e8:	d2c50513          	addi	a0,a0,-724 # 6510 <malloc+0xd62>
    17ec:	00004097          	auipc	ra,0x4
    17f0:	f04080e7          	jalr	-252(ra) # 56f0 <printf>
    exit(1);
    17f4:	4505                	li	a0,1
    17f6:	00004097          	auipc	ra,0x4
    17fa:	b82080e7          	jalr	-1150(ra) # 5378 <exit>
    close(fds[0]);
    17fe:	fa842503          	lw	a0,-88(s0)
    1802:	00004097          	auipc	ra,0x4
    1806:	b9e080e7          	jalr	-1122(ra) # 53a0 <close>
    for(n = 0; n < N; n++){
    180a:	0000ab17          	auipc	s6,0xa
    180e:	f2eb0b13          	addi	s6,s6,-210 # b738 <buf>
    1812:	416004bb          	negw	s1,s6
    1816:	0ff4f493          	andi	s1,s1,255
    181a:	409b0993          	addi	s3,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
    181e:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
    1820:	6a85                	lui	s5,0x1
    1822:	42da8a93          	addi	s5,s5,1069 # 142d <truncate3+0x7d>
{
    1826:	87da                	mv	a5,s6
        buf[i] = seq++;
    1828:	0097873b          	addw	a4,a5,s1
    182c:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    1830:	0785                	addi	a5,a5,1
    1832:	fef99be3          	bne	s3,a5,1828 <pipe1+0xe2>
    1836:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    183a:	40900613          	li	a2,1033
    183e:	85de                	mv	a1,s7
    1840:	fac42503          	lw	a0,-84(s0)
    1844:	00004097          	auipc	ra,0x4
    1848:	b54080e7          	jalr	-1196(ra) # 5398 <write>
    184c:	40900793          	li	a5,1033
    1850:	00f51c63          	bne	a0,a5,1868 <pipe1+0x122>
    for(n = 0; n < N; n++){
    1854:	24a5                	addiw	s1,s1,9
    1856:	0ff4f493          	andi	s1,s1,255
    185a:	fd5a16e3          	bne	s4,s5,1826 <pipe1+0xe0>
    exit(0);
    185e:	4501                	li	a0,0
    1860:	00004097          	auipc	ra,0x4
    1864:	b18080e7          	jalr	-1256(ra) # 5378 <exit>
        printf("%s: pipe1 oops 1\n", s);
    1868:	85ca                	mv	a1,s2
    186a:	00005517          	auipc	a0,0x5
    186e:	cbe50513          	addi	a0,a0,-834 # 6528 <malloc+0xd7a>
    1872:	00004097          	auipc	ra,0x4
    1876:	e7e080e7          	jalr	-386(ra) # 56f0 <printf>
        exit(1);
    187a:	4505                	li	a0,1
    187c:	00004097          	auipc	ra,0x4
    1880:	afc080e7          	jalr	-1284(ra) # 5378 <exit>
          printf("%s: pipe1 oops 2\n", s);
    1884:	85ca                	mv	a1,s2
    1886:	00005517          	auipc	a0,0x5
    188a:	cba50513          	addi	a0,a0,-838 # 6540 <malloc+0xd92>
    188e:	00004097          	auipc	ra,0x4
    1892:	e62080e7          	jalr	-414(ra) # 56f0 <printf>
}
    1896:	60e6                	ld	ra,88(sp)
    1898:	6446                	ld	s0,80(sp)
    189a:	64a6                	ld	s1,72(sp)
    189c:	6906                	ld	s2,64(sp)
    189e:	79e2                	ld	s3,56(sp)
    18a0:	7a42                	ld	s4,48(sp)
    18a2:	7aa2                	ld	s5,40(sp)
    18a4:	7b02                	ld	s6,32(sp)
    18a6:	6be2                	ld	s7,24(sp)
    18a8:	6125                	addi	sp,sp,96
    18aa:	8082                	ret
    if(total != N * SZ){
    18ac:	6785                	lui	a5,0x1
    18ae:	42d78793          	addi	a5,a5,1069 # 142d <truncate3+0x7d>
    18b2:	02fa0063          	beq	s4,a5,18d2 <pipe1+0x18c>
      printf("%s: pipe1 oops 3 total %d\n", total);
    18b6:	85d2                	mv	a1,s4
    18b8:	00005517          	auipc	a0,0x5
    18bc:	ca050513          	addi	a0,a0,-864 # 6558 <malloc+0xdaa>
    18c0:	00004097          	auipc	ra,0x4
    18c4:	e30080e7          	jalr	-464(ra) # 56f0 <printf>
      exit(1);
    18c8:	4505                	li	a0,1
    18ca:	00004097          	auipc	ra,0x4
    18ce:	aae080e7          	jalr	-1362(ra) # 5378 <exit>
    close(fds[0]);
    18d2:	fa842503          	lw	a0,-88(s0)
    18d6:	00004097          	auipc	ra,0x4
    18da:	aca080e7          	jalr	-1334(ra) # 53a0 <close>
    wait(&xstatus);
    18de:	fa440513          	addi	a0,s0,-92
    18e2:	00004097          	auipc	ra,0x4
    18e6:	a9e080e7          	jalr	-1378(ra) # 5380 <wait>
    exit(xstatus);
    18ea:	fa442503          	lw	a0,-92(s0)
    18ee:	00004097          	auipc	ra,0x4
    18f2:	a8a080e7          	jalr	-1398(ra) # 5378 <exit>
    printf("%s: fork() failed\n", s);
    18f6:	85ca                	mv	a1,s2
    18f8:	00005517          	auipc	a0,0x5
    18fc:	c8050513          	addi	a0,a0,-896 # 6578 <malloc+0xdca>
    1900:	00004097          	auipc	ra,0x4
    1904:	df0080e7          	jalr	-528(ra) # 56f0 <printf>
    exit(1);
    1908:	4505                	li	a0,1
    190a:	00004097          	auipc	ra,0x4
    190e:	a6e080e7          	jalr	-1426(ra) # 5378 <exit>

0000000000001912 <exitwait>:
{
    1912:	7139                	addi	sp,sp,-64
    1914:	fc06                	sd	ra,56(sp)
    1916:	f822                	sd	s0,48(sp)
    1918:	f426                	sd	s1,40(sp)
    191a:	f04a                	sd	s2,32(sp)
    191c:	ec4e                	sd	s3,24(sp)
    191e:	e852                	sd	s4,16(sp)
    1920:	0080                	addi	s0,sp,64
    1922:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
    1924:	4901                	li	s2,0
    1926:	06400993          	li	s3,100
    pid = fork();
    192a:	00004097          	auipc	ra,0x4
    192e:	a46080e7          	jalr	-1466(ra) # 5370 <fork>
    1932:	84aa                	mv	s1,a0
    if(pid < 0){
    1934:	02054a63          	bltz	a0,1968 <exitwait+0x56>
    if(pid){
    1938:	c151                	beqz	a0,19bc <exitwait+0xaa>
      if(wait(&xstate) != pid){
    193a:	fcc40513          	addi	a0,s0,-52
    193e:	00004097          	auipc	ra,0x4
    1942:	a42080e7          	jalr	-1470(ra) # 5380 <wait>
    1946:	02951f63          	bne	a0,s1,1984 <exitwait+0x72>
      if(i != xstate) {
    194a:	fcc42783          	lw	a5,-52(s0)
    194e:	05279963          	bne	a5,s2,19a0 <exitwait+0x8e>
  for(i = 0; i < 100; i++){
    1952:	2905                	addiw	s2,s2,1
    1954:	fd391be3          	bne	s2,s3,192a <exitwait+0x18>
}
    1958:	70e2                	ld	ra,56(sp)
    195a:	7442                	ld	s0,48(sp)
    195c:	74a2                	ld	s1,40(sp)
    195e:	7902                	ld	s2,32(sp)
    1960:	69e2                	ld	s3,24(sp)
    1962:	6a42                	ld	s4,16(sp)
    1964:	6121                	addi	sp,sp,64
    1966:	8082                	ret
      printf("%s: fork failed\n", s);
    1968:	85d2                	mv	a1,s4
    196a:	00005517          	auipc	a0,0x5
    196e:	a9e50513          	addi	a0,a0,-1378 # 6408 <malloc+0xc5a>
    1972:	00004097          	auipc	ra,0x4
    1976:	d7e080e7          	jalr	-642(ra) # 56f0 <printf>
      exit(1);
    197a:	4505                	li	a0,1
    197c:	00004097          	auipc	ra,0x4
    1980:	9fc080e7          	jalr	-1540(ra) # 5378 <exit>
        printf("%s: wait wrong pid\n", s);
    1984:	85d2                	mv	a1,s4
    1986:	00005517          	auipc	a0,0x5
    198a:	c0a50513          	addi	a0,a0,-1014 # 6590 <malloc+0xde2>
    198e:	00004097          	auipc	ra,0x4
    1992:	d62080e7          	jalr	-670(ra) # 56f0 <printf>
        exit(1);
    1996:	4505                	li	a0,1
    1998:	00004097          	auipc	ra,0x4
    199c:	9e0080e7          	jalr	-1568(ra) # 5378 <exit>
        printf("%s: wait wrong exit status\n", s);
    19a0:	85d2                	mv	a1,s4
    19a2:	00005517          	auipc	a0,0x5
    19a6:	c0650513          	addi	a0,a0,-1018 # 65a8 <malloc+0xdfa>
    19aa:	00004097          	auipc	ra,0x4
    19ae:	d46080e7          	jalr	-698(ra) # 56f0 <printf>
        exit(1);
    19b2:	4505                	li	a0,1
    19b4:	00004097          	auipc	ra,0x4
    19b8:	9c4080e7          	jalr	-1596(ra) # 5378 <exit>
      exit(i);
    19bc:	854a                	mv	a0,s2
    19be:	00004097          	auipc	ra,0x4
    19c2:	9ba080e7          	jalr	-1606(ra) # 5378 <exit>

00000000000019c6 <twochildren>:
{
    19c6:	1101                	addi	sp,sp,-32
    19c8:	ec06                	sd	ra,24(sp)
    19ca:	e822                	sd	s0,16(sp)
    19cc:	e426                	sd	s1,8(sp)
    19ce:	e04a                	sd	s2,0(sp)
    19d0:	1000                	addi	s0,sp,32
    19d2:	892a                	mv	s2,a0
    19d4:	3e800493          	li	s1,1000
    int pid1 = fork();
    19d8:	00004097          	auipc	ra,0x4
    19dc:	998080e7          	jalr	-1640(ra) # 5370 <fork>
    if(pid1 < 0){
    19e0:	02054c63          	bltz	a0,1a18 <twochildren+0x52>
    if(pid1 == 0){
    19e4:	c921                	beqz	a0,1a34 <twochildren+0x6e>
      int pid2 = fork();
    19e6:	00004097          	auipc	ra,0x4
    19ea:	98a080e7          	jalr	-1654(ra) # 5370 <fork>
      if(pid2 < 0){
    19ee:	04054763          	bltz	a0,1a3c <twochildren+0x76>
      if(pid2 == 0){
    19f2:	c13d                	beqz	a0,1a58 <twochildren+0x92>
        wait(0);
    19f4:	4501                	li	a0,0
    19f6:	00004097          	auipc	ra,0x4
    19fa:	98a080e7          	jalr	-1654(ra) # 5380 <wait>
        wait(0);
    19fe:	4501                	li	a0,0
    1a00:	00004097          	auipc	ra,0x4
    1a04:	980080e7          	jalr	-1664(ra) # 5380 <wait>
  for(int i = 0; i < 1000; i++){
    1a08:	34fd                	addiw	s1,s1,-1
    1a0a:	f4f9                	bnez	s1,19d8 <twochildren+0x12>
}
    1a0c:	60e2                	ld	ra,24(sp)
    1a0e:	6442                	ld	s0,16(sp)
    1a10:	64a2                	ld	s1,8(sp)
    1a12:	6902                	ld	s2,0(sp)
    1a14:	6105                	addi	sp,sp,32
    1a16:	8082                	ret
      printf("%s: fork failed\n", s);
    1a18:	85ca                	mv	a1,s2
    1a1a:	00005517          	auipc	a0,0x5
    1a1e:	9ee50513          	addi	a0,a0,-1554 # 6408 <malloc+0xc5a>
    1a22:	00004097          	auipc	ra,0x4
    1a26:	cce080e7          	jalr	-818(ra) # 56f0 <printf>
      exit(1);
    1a2a:	4505                	li	a0,1
    1a2c:	00004097          	auipc	ra,0x4
    1a30:	94c080e7          	jalr	-1716(ra) # 5378 <exit>
      exit(0);
    1a34:	00004097          	auipc	ra,0x4
    1a38:	944080e7          	jalr	-1724(ra) # 5378 <exit>
        printf("%s: fork failed\n", s);
    1a3c:	85ca                	mv	a1,s2
    1a3e:	00005517          	auipc	a0,0x5
    1a42:	9ca50513          	addi	a0,a0,-1590 # 6408 <malloc+0xc5a>
    1a46:	00004097          	auipc	ra,0x4
    1a4a:	caa080e7          	jalr	-854(ra) # 56f0 <printf>
        exit(1);
    1a4e:	4505                	li	a0,1
    1a50:	00004097          	auipc	ra,0x4
    1a54:	928080e7          	jalr	-1752(ra) # 5378 <exit>
        exit(0);
    1a58:	00004097          	auipc	ra,0x4
    1a5c:	920080e7          	jalr	-1760(ra) # 5378 <exit>

0000000000001a60 <forkfork>:
{
    1a60:	7179                	addi	sp,sp,-48
    1a62:	f406                	sd	ra,40(sp)
    1a64:	f022                	sd	s0,32(sp)
    1a66:	ec26                	sd	s1,24(sp)
    1a68:	1800                	addi	s0,sp,48
    1a6a:	84aa                	mv	s1,a0
    int pid = fork();
    1a6c:	00004097          	auipc	ra,0x4
    1a70:	904080e7          	jalr	-1788(ra) # 5370 <fork>
    if(pid < 0){
    1a74:	04054163          	bltz	a0,1ab6 <forkfork+0x56>
    if(pid == 0){
    1a78:	cd29                	beqz	a0,1ad2 <forkfork+0x72>
    int pid = fork();
    1a7a:	00004097          	auipc	ra,0x4
    1a7e:	8f6080e7          	jalr	-1802(ra) # 5370 <fork>
    if(pid < 0){
    1a82:	02054a63          	bltz	a0,1ab6 <forkfork+0x56>
    if(pid == 0){
    1a86:	c531                	beqz	a0,1ad2 <forkfork+0x72>
    wait(&xstatus);
    1a88:	fdc40513          	addi	a0,s0,-36
    1a8c:	00004097          	auipc	ra,0x4
    1a90:	8f4080e7          	jalr	-1804(ra) # 5380 <wait>
    if(xstatus != 0) {
    1a94:	fdc42783          	lw	a5,-36(s0)
    1a98:	ebbd                	bnez	a5,1b0e <forkfork+0xae>
    wait(&xstatus);
    1a9a:	fdc40513          	addi	a0,s0,-36
    1a9e:	00004097          	auipc	ra,0x4
    1aa2:	8e2080e7          	jalr	-1822(ra) # 5380 <wait>
    if(xstatus != 0) {
    1aa6:	fdc42783          	lw	a5,-36(s0)
    1aaa:	e3b5                	bnez	a5,1b0e <forkfork+0xae>
}
    1aac:	70a2                	ld	ra,40(sp)
    1aae:	7402                	ld	s0,32(sp)
    1ab0:	64e2                	ld	s1,24(sp)
    1ab2:	6145                	addi	sp,sp,48
    1ab4:	8082                	ret
      printf("%s: fork failed", s);
    1ab6:	85a6                	mv	a1,s1
    1ab8:	00005517          	auipc	a0,0x5
    1abc:	b1050513          	addi	a0,a0,-1264 # 65c8 <malloc+0xe1a>
    1ac0:	00004097          	auipc	ra,0x4
    1ac4:	c30080e7          	jalr	-976(ra) # 56f0 <printf>
      exit(1);
    1ac8:	4505                	li	a0,1
    1aca:	00004097          	auipc	ra,0x4
    1ace:	8ae080e7          	jalr	-1874(ra) # 5378 <exit>
{
    1ad2:	0c800493          	li	s1,200
        int pid1 = fork();
    1ad6:	00004097          	auipc	ra,0x4
    1ada:	89a080e7          	jalr	-1894(ra) # 5370 <fork>
        if(pid1 < 0){
    1ade:	00054f63          	bltz	a0,1afc <forkfork+0x9c>
        if(pid1 == 0){
    1ae2:	c115                	beqz	a0,1b06 <forkfork+0xa6>
        wait(0);
    1ae4:	4501                	li	a0,0
    1ae6:	00004097          	auipc	ra,0x4
    1aea:	89a080e7          	jalr	-1894(ra) # 5380 <wait>
      for(int j = 0; j < 200; j++){
    1aee:	34fd                	addiw	s1,s1,-1
    1af0:	f0fd                	bnez	s1,1ad6 <forkfork+0x76>
      exit(0);
    1af2:	4501                	li	a0,0
    1af4:	00004097          	auipc	ra,0x4
    1af8:	884080e7          	jalr	-1916(ra) # 5378 <exit>
          exit(1);
    1afc:	4505                	li	a0,1
    1afe:	00004097          	auipc	ra,0x4
    1b02:	87a080e7          	jalr	-1926(ra) # 5378 <exit>
          exit(0);
    1b06:	00004097          	auipc	ra,0x4
    1b0a:	872080e7          	jalr	-1934(ra) # 5378 <exit>
      printf("%s: fork in child failed", s);
    1b0e:	85a6                	mv	a1,s1
    1b10:	00005517          	auipc	a0,0x5
    1b14:	ac850513          	addi	a0,a0,-1336 # 65d8 <malloc+0xe2a>
    1b18:	00004097          	auipc	ra,0x4
    1b1c:	bd8080e7          	jalr	-1064(ra) # 56f0 <printf>
      exit(1);
    1b20:	4505                	li	a0,1
    1b22:	00004097          	auipc	ra,0x4
    1b26:	856080e7          	jalr	-1962(ra) # 5378 <exit>

0000000000001b2a <reparent2>:
{
    1b2a:	1101                	addi	sp,sp,-32
    1b2c:	ec06                	sd	ra,24(sp)
    1b2e:	e822                	sd	s0,16(sp)
    1b30:	e426                	sd	s1,8(sp)
    1b32:	1000                	addi	s0,sp,32
    1b34:	32000493          	li	s1,800
    int pid1 = fork();
    1b38:	00004097          	auipc	ra,0x4
    1b3c:	838080e7          	jalr	-1992(ra) # 5370 <fork>
    if(pid1 < 0){
    1b40:	00054f63          	bltz	a0,1b5e <reparent2+0x34>
    if(pid1 == 0){
    1b44:	c915                	beqz	a0,1b78 <reparent2+0x4e>
    wait(0);
    1b46:	4501                	li	a0,0
    1b48:	00004097          	auipc	ra,0x4
    1b4c:	838080e7          	jalr	-1992(ra) # 5380 <wait>
  for(int i = 0; i < 800; i++){
    1b50:	34fd                	addiw	s1,s1,-1
    1b52:	f0fd                	bnez	s1,1b38 <reparent2+0xe>
  exit(0);
    1b54:	4501                	li	a0,0
    1b56:	00004097          	auipc	ra,0x4
    1b5a:	822080e7          	jalr	-2014(ra) # 5378 <exit>
      printf("fork failed\n");
    1b5e:	00005517          	auipc	a0,0x5
    1b62:	c9a50513          	addi	a0,a0,-870 # 67f8 <malloc+0x104a>
    1b66:	00004097          	auipc	ra,0x4
    1b6a:	b8a080e7          	jalr	-1142(ra) # 56f0 <printf>
      exit(1);
    1b6e:	4505                	li	a0,1
    1b70:	00004097          	auipc	ra,0x4
    1b74:	808080e7          	jalr	-2040(ra) # 5378 <exit>
      fork();
    1b78:	00003097          	auipc	ra,0x3
    1b7c:	7f8080e7          	jalr	2040(ra) # 5370 <fork>
      fork();
    1b80:	00003097          	auipc	ra,0x3
    1b84:	7f0080e7          	jalr	2032(ra) # 5370 <fork>
      exit(0);
    1b88:	4501                	li	a0,0
    1b8a:	00003097          	auipc	ra,0x3
    1b8e:	7ee080e7          	jalr	2030(ra) # 5378 <exit>

0000000000001b92 <createdelete>:
{
    1b92:	7175                	addi	sp,sp,-144
    1b94:	e506                	sd	ra,136(sp)
    1b96:	e122                	sd	s0,128(sp)
    1b98:	fca6                	sd	s1,120(sp)
    1b9a:	f8ca                	sd	s2,112(sp)
    1b9c:	f4ce                	sd	s3,104(sp)
    1b9e:	f0d2                	sd	s4,96(sp)
    1ba0:	ecd6                	sd	s5,88(sp)
    1ba2:	e8da                	sd	s6,80(sp)
    1ba4:	e4de                	sd	s7,72(sp)
    1ba6:	e0e2                	sd	s8,64(sp)
    1ba8:	fc66                	sd	s9,56(sp)
    1baa:	0900                	addi	s0,sp,144
    1bac:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    1bae:	4901                	li	s2,0
    1bb0:	4991                	li	s3,4
    pid = fork();
    1bb2:	00003097          	auipc	ra,0x3
    1bb6:	7be080e7          	jalr	1982(ra) # 5370 <fork>
    1bba:	84aa                	mv	s1,a0
    if(pid < 0){
    1bbc:	02054f63          	bltz	a0,1bfa <createdelete+0x68>
    if(pid == 0){
    1bc0:	c939                	beqz	a0,1c16 <createdelete+0x84>
  for(pi = 0; pi < NCHILD; pi++){
    1bc2:	2905                	addiw	s2,s2,1
    1bc4:	ff3917e3          	bne	s2,s3,1bb2 <createdelete+0x20>
    1bc8:	4491                	li	s1,4
    wait(&xstatus);
    1bca:	f7c40513          	addi	a0,s0,-132
    1bce:	00003097          	auipc	ra,0x3
    1bd2:	7b2080e7          	jalr	1970(ra) # 5380 <wait>
    if(xstatus != 0)
    1bd6:	f7c42903          	lw	s2,-132(s0)
    1bda:	0e091263          	bnez	s2,1cbe <createdelete+0x12c>
  for(pi = 0; pi < NCHILD; pi++){
    1bde:	34fd                	addiw	s1,s1,-1
    1be0:	f4ed                	bnez	s1,1bca <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
    1be2:	f8040123          	sb	zero,-126(s0)
    1be6:	03000993          	li	s3,48
    1bea:	5a7d                	li	s4,-1
    1bec:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1bf0:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
    1bf2:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
    1bf4:	07400a93          	li	s5,116
    1bf8:	a29d                	j	1d5e <createdelete+0x1cc>
      printf("fork failed\n", s);
    1bfa:	85e6                	mv	a1,s9
    1bfc:	00005517          	auipc	a0,0x5
    1c00:	bfc50513          	addi	a0,a0,-1028 # 67f8 <malloc+0x104a>
    1c04:	00004097          	auipc	ra,0x4
    1c08:	aec080e7          	jalr	-1300(ra) # 56f0 <printf>
      exit(1);
    1c0c:	4505                	li	a0,1
    1c0e:	00003097          	auipc	ra,0x3
    1c12:	76a080e7          	jalr	1898(ra) # 5378 <exit>
      name[0] = 'p' + pi;
    1c16:	0709091b          	addiw	s2,s2,112
    1c1a:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    1c1e:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    1c22:	4951                	li	s2,20
    1c24:	a015                	j	1c48 <createdelete+0xb6>
          printf("%s: create failed\n", s);
    1c26:	85e6                	mv	a1,s9
    1c28:	00005517          	auipc	a0,0x5
    1c2c:	87850513          	addi	a0,a0,-1928 # 64a0 <malloc+0xcf2>
    1c30:	00004097          	auipc	ra,0x4
    1c34:	ac0080e7          	jalr	-1344(ra) # 56f0 <printf>
          exit(1);
    1c38:	4505                	li	a0,1
    1c3a:	00003097          	auipc	ra,0x3
    1c3e:	73e080e7          	jalr	1854(ra) # 5378 <exit>
      for(i = 0; i < N; i++){
    1c42:	2485                	addiw	s1,s1,1
    1c44:	07248863          	beq	s1,s2,1cb4 <createdelete+0x122>
        name[1] = '0' + i;
    1c48:	0304879b          	addiw	a5,s1,48
    1c4c:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    1c50:	20200593          	li	a1,514
    1c54:	f8040513          	addi	a0,s0,-128
    1c58:	00003097          	auipc	ra,0x3
    1c5c:	760080e7          	jalr	1888(ra) # 53b8 <open>
        if(fd < 0){
    1c60:	fc0543e3          	bltz	a0,1c26 <createdelete+0x94>
        close(fd);
    1c64:	00003097          	auipc	ra,0x3
    1c68:	73c080e7          	jalr	1852(ra) # 53a0 <close>
        if(i > 0 && (i % 2 ) == 0){
    1c6c:	fc905be3          	blez	s1,1c42 <createdelete+0xb0>
    1c70:	0014f793          	andi	a5,s1,1
    1c74:	f7f9                	bnez	a5,1c42 <createdelete+0xb0>
          name[1] = '0' + (i / 2);
    1c76:	01f4d79b          	srliw	a5,s1,0x1f
    1c7a:	9fa5                	addw	a5,a5,s1
    1c7c:	4017d79b          	sraiw	a5,a5,0x1
    1c80:	0307879b          	addiw	a5,a5,48
    1c84:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    1c88:	f8040513          	addi	a0,s0,-128
    1c8c:	00003097          	auipc	ra,0x3
    1c90:	73c080e7          	jalr	1852(ra) # 53c8 <unlink>
    1c94:	fa0557e3          	bgez	a0,1c42 <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
    1c98:	85e6                	mv	a1,s9
    1c9a:	00005517          	auipc	a0,0x5
    1c9e:	95e50513          	addi	a0,a0,-1698 # 65f8 <malloc+0xe4a>
    1ca2:	00004097          	auipc	ra,0x4
    1ca6:	a4e080e7          	jalr	-1458(ra) # 56f0 <printf>
            exit(1);
    1caa:	4505                	li	a0,1
    1cac:	00003097          	auipc	ra,0x3
    1cb0:	6cc080e7          	jalr	1740(ra) # 5378 <exit>
      exit(0);
    1cb4:	4501                	li	a0,0
    1cb6:	00003097          	auipc	ra,0x3
    1cba:	6c2080e7          	jalr	1730(ra) # 5378 <exit>
      exit(1);
    1cbe:	4505                	li	a0,1
    1cc0:	00003097          	auipc	ra,0x3
    1cc4:	6b8080e7          	jalr	1720(ra) # 5378 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    1cc8:	f8040613          	addi	a2,s0,-128
    1ccc:	85e6                	mv	a1,s9
    1cce:	00005517          	auipc	a0,0x5
    1cd2:	94250513          	addi	a0,a0,-1726 # 6610 <malloc+0xe62>
    1cd6:	00004097          	auipc	ra,0x4
    1cda:	a1a080e7          	jalr	-1510(ra) # 56f0 <printf>
        exit(1);
    1cde:	4505                	li	a0,1
    1ce0:	00003097          	auipc	ra,0x3
    1ce4:	698080e7          	jalr	1688(ra) # 5378 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1ce8:	054b7163          	bgeu	s6,s4,1d2a <createdelete+0x198>
      if(fd >= 0)
    1cec:	02055a63          	bgez	a0,1d20 <createdelete+0x18e>
    for(pi = 0; pi < NCHILD; pi++){
    1cf0:	2485                	addiw	s1,s1,1
    1cf2:	0ff4f493          	andi	s1,s1,255
    1cf6:	05548c63          	beq	s1,s5,1d4e <createdelete+0x1bc>
      name[0] = 'p' + pi;
    1cfa:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1cfe:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    1d02:	4581                	li	a1,0
    1d04:	f8040513          	addi	a0,s0,-128
    1d08:	00003097          	auipc	ra,0x3
    1d0c:	6b0080e7          	jalr	1712(ra) # 53b8 <open>
      if((i == 0 || i >= N/2) && fd < 0){
    1d10:	00090463          	beqz	s2,1d18 <createdelete+0x186>
    1d14:	fd2bdae3          	bge	s7,s2,1ce8 <createdelete+0x156>
    1d18:	fa0548e3          	bltz	a0,1cc8 <createdelete+0x136>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d1c:	014b7963          	bgeu	s6,s4,1d2e <createdelete+0x19c>
        close(fd);
    1d20:	00003097          	auipc	ra,0x3
    1d24:	680080e7          	jalr	1664(ra) # 53a0 <close>
    1d28:	b7e1                	j	1cf0 <createdelete+0x15e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d2a:	fc0543e3          	bltz	a0,1cf0 <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
    1d2e:	f8040613          	addi	a2,s0,-128
    1d32:	85e6                	mv	a1,s9
    1d34:	00005517          	auipc	a0,0x5
    1d38:	90450513          	addi	a0,a0,-1788 # 6638 <malloc+0xe8a>
    1d3c:	00004097          	auipc	ra,0x4
    1d40:	9b4080e7          	jalr	-1612(ra) # 56f0 <printf>
        exit(1);
    1d44:	4505                	li	a0,1
    1d46:	00003097          	auipc	ra,0x3
    1d4a:	632080e7          	jalr	1586(ra) # 5378 <exit>
  for(i = 0; i < N; i++){
    1d4e:	2905                	addiw	s2,s2,1
    1d50:	2a05                	addiw	s4,s4,1
    1d52:	2985                	addiw	s3,s3,1
    1d54:	0ff9f993          	andi	s3,s3,255
    1d58:	47d1                	li	a5,20
    1d5a:	02f90a63          	beq	s2,a5,1d8e <createdelete+0x1fc>
    for(pi = 0; pi < NCHILD; pi++){
    1d5e:	84e2                	mv	s1,s8
    1d60:	bf69                	j	1cfa <createdelete+0x168>
  for(i = 0; i < N; i++){
    1d62:	2905                	addiw	s2,s2,1
    1d64:	0ff97913          	andi	s2,s2,255
    1d68:	2985                	addiw	s3,s3,1
    1d6a:	0ff9f993          	andi	s3,s3,255
    1d6e:	03490863          	beq	s2,s4,1d9e <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
    1d72:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    1d74:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    1d78:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    1d7c:	f8040513          	addi	a0,s0,-128
    1d80:	00003097          	auipc	ra,0x3
    1d84:	648080e7          	jalr	1608(ra) # 53c8 <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    1d88:	34fd                	addiw	s1,s1,-1
    1d8a:	f4ed                	bnez	s1,1d74 <createdelete+0x1e2>
    1d8c:	bfd9                	j	1d62 <createdelete+0x1d0>
    1d8e:	03000993          	li	s3,48
    1d92:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    1d96:	4a91                	li	s5,4
  for(i = 0; i < N; i++){
    1d98:	08400a13          	li	s4,132
    1d9c:	bfd9                	j	1d72 <createdelete+0x1e0>
}
    1d9e:	60aa                	ld	ra,136(sp)
    1da0:	640a                	ld	s0,128(sp)
    1da2:	74e6                	ld	s1,120(sp)
    1da4:	7946                	ld	s2,112(sp)
    1da6:	79a6                	ld	s3,104(sp)
    1da8:	7a06                	ld	s4,96(sp)
    1daa:	6ae6                	ld	s5,88(sp)
    1dac:	6b46                	ld	s6,80(sp)
    1dae:	6ba6                	ld	s7,72(sp)
    1db0:	6c06                	ld	s8,64(sp)
    1db2:	7ce2                	ld	s9,56(sp)
    1db4:	6149                	addi	sp,sp,144
    1db6:	8082                	ret

0000000000001db8 <linkunlink>:
{
    1db8:	711d                	addi	sp,sp,-96
    1dba:	ec86                	sd	ra,88(sp)
    1dbc:	e8a2                	sd	s0,80(sp)
    1dbe:	e4a6                	sd	s1,72(sp)
    1dc0:	e0ca                	sd	s2,64(sp)
    1dc2:	fc4e                	sd	s3,56(sp)
    1dc4:	f852                	sd	s4,48(sp)
    1dc6:	f456                	sd	s5,40(sp)
    1dc8:	f05a                	sd	s6,32(sp)
    1dca:	ec5e                	sd	s7,24(sp)
    1dcc:	e862                	sd	s8,16(sp)
    1dce:	e466                	sd	s9,8(sp)
    1dd0:	1080                	addi	s0,sp,96
    1dd2:	84aa                	mv	s1,a0
  unlink("x");
    1dd4:	00004517          	auipc	a0,0x4
    1dd8:	e6c50513          	addi	a0,a0,-404 # 5c40 <malloc+0x492>
    1ddc:	00003097          	auipc	ra,0x3
    1de0:	5ec080e7          	jalr	1516(ra) # 53c8 <unlink>
  pid = fork();
    1de4:	00003097          	auipc	ra,0x3
    1de8:	58c080e7          	jalr	1420(ra) # 5370 <fork>
  if(pid < 0){
    1dec:	02054b63          	bltz	a0,1e22 <linkunlink+0x6a>
    1df0:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    1df2:	4c85                	li	s9,1
    1df4:	e119                	bnez	a0,1dfa <linkunlink+0x42>
    1df6:	06100c93          	li	s9,97
    1dfa:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    1dfe:	41c659b7          	lui	s3,0x41c65
    1e02:	e6d9899b          	addiw	s3,s3,-403
    1e06:	690d                	lui	s2,0x3
    1e08:	0399091b          	addiw	s2,s2,57
    if((x % 3) == 0){
    1e0c:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    1e0e:	4b05                	li	s6,1
      unlink("x");
    1e10:	00004a97          	auipc	s5,0x4
    1e14:	e30a8a93          	addi	s5,s5,-464 # 5c40 <malloc+0x492>
      link("cat", "x");
    1e18:	00005b97          	auipc	s7,0x5
    1e1c:	848b8b93          	addi	s7,s7,-1976 # 6660 <malloc+0xeb2>
    1e20:	a091                	j	1e64 <linkunlink+0xac>
    printf("%s: fork failed\n", s);
    1e22:	85a6                	mv	a1,s1
    1e24:	00004517          	auipc	a0,0x4
    1e28:	5e450513          	addi	a0,a0,1508 # 6408 <malloc+0xc5a>
    1e2c:	00004097          	auipc	ra,0x4
    1e30:	8c4080e7          	jalr	-1852(ra) # 56f0 <printf>
    exit(1);
    1e34:	4505                	li	a0,1
    1e36:	00003097          	auipc	ra,0x3
    1e3a:	542080e7          	jalr	1346(ra) # 5378 <exit>
      close(open("x", O_RDWR | O_CREATE));
    1e3e:	20200593          	li	a1,514
    1e42:	8556                	mv	a0,s5
    1e44:	00003097          	auipc	ra,0x3
    1e48:	574080e7          	jalr	1396(ra) # 53b8 <open>
    1e4c:	00003097          	auipc	ra,0x3
    1e50:	554080e7          	jalr	1364(ra) # 53a0 <close>
    1e54:	a031                	j	1e60 <linkunlink+0xa8>
      unlink("x");
    1e56:	8556                	mv	a0,s5
    1e58:	00003097          	auipc	ra,0x3
    1e5c:	570080e7          	jalr	1392(ra) # 53c8 <unlink>
  for(i = 0; i < 100; i++){
    1e60:	34fd                	addiw	s1,s1,-1
    1e62:	c09d                	beqz	s1,1e88 <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    1e64:	033c87bb          	mulw	a5,s9,s3
    1e68:	012787bb          	addw	a5,a5,s2
    1e6c:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    1e70:	0347f7bb          	remuw	a5,a5,s4
    1e74:	d7e9                	beqz	a5,1e3e <linkunlink+0x86>
    } else if((x % 3) == 1){
    1e76:	ff6790e3          	bne	a5,s6,1e56 <linkunlink+0x9e>
      link("cat", "x");
    1e7a:	85d6                	mv	a1,s5
    1e7c:	855e                	mv	a0,s7
    1e7e:	00003097          	auipc	ra,0x3
    1e82:	55a080e7          	jalr	1370(ra) # 53d8 <link>
    1e86:	bfe9                	j	1e60 <linkunlink+0xa8>
  if(pid)
    1e88:	020c0463          	beqz	s8,1eb0 <linkunlink+0xf8>
    wait(0);
    1e8c:	4501                	li	a0,0
    1e8e:	00003097          	auipc	ra,0x3
    1e92:	4f2080e7          	jalr	1266(ra) # 5380 <wait>
}
    1e96:	60e6                	ld	ra,88(sp)
    1e98:	6446                	ld	s0,80(sp)
    1e9a:	64a6                	ld	s1,72(sp)
    1e9c:	6906                	ld	s2,64(sp)
    1e9e:	79e2                	ld	s3,56(sp)
    1ea0:	7a42                	ld	s4,48(sp)
    1ea2:	7aa2                	ld	s5,40(sp)
    1ea4:	7b02                	ld	s6,32(sp)
    1ea6:	6be2                	ld	s7,24(sp)
    1ea8:	6c42                	ld	s8,16(sp)
    1eaa:	6ca2                	ld	s9,8(sp)
    1eac:	6125                	addi	sp,sp,96
    1eae:	8082                	ret
    exit(0);
    1eb0:	4501                	li	a0,0
    1eb2:	00003097          	auipc	ra,0x3
    1eb6:	4c6080e7          	jalr	1222(ra) # 5378 <exit>

0000000000001eba <forktest>:
{
    1eba:	7179                	addi	sp,sp,-48
    1ebc:	f406                	sd	ra,40(sp)
    1ebe:	f022                	sd	s0,32(sp)
    1ec0:	ec26                	sd	s1,24(sp)
    1ec2:	e84a                	sd	s2,16(sp)
    1ec4:	e44e                	sd	s3,8(sp)
    1ec6:	1800                	addi	s0,sp,48
    1ec8:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    1eca:	4481                	li	s1,0
    1ecc:	3e800913          	li	s2,1000
    pid = fork();
    1ed0:	00003097          	auipc	ra,0x3
    1ed4:	4a0080e7          	jalr	1184(ra) # 5370 <fork>
    if(pid < 0)
    1ed8:	02054863          	bltz	a0,1f08 <forktest+0x4e>
    if(pid == 0)
    1edc:	c115                	beqz	a0,1f00 <forktest+0x46>
  for(n=0; n<N; n++){
    1ede:	2485                	addiw	s1,s1,1
    1ee0:	ff2498e3          	bne	s1,s2,1ed0 <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    1ee4:	85ce                	mv	a1,s3
    1ee6:	00004517          	auipc	a0,0x4
    1eea:	79a50513          	addi	a0,a0,1946 # 6680 <malloc+0xed2>
    1eee:	00004097          	auipc	ra,0x4
    1ef2:	802080e7          	jalr	-2046(ra) # 56f0 <printf>
    exit(1);
    1ef6:	4505                	li	a0,1
    1ef8:	00003097          	auipc	ra,0x3
    1efc:	480080e7          	jalr	1152(ra) # 5378 <exit>
      exit(0);
    1f00:	00003097          	auipc	ra,0x3
    1f04:	478080e7          	jalr	1144(ra) # 5378 <exit>
  if (n == 0) {
    1f08:	cc9d                	beqz	s1,1f46 <forktest+0x8c>
  if(n == N){
    1f0a:	3e800793          	li	a5,1000
    1f0e:	fcf48be3          	beq	s1,a5,1ee4 <forktest+0x2a>
  for(; n > 0; n--){
    1f12:	00905b63          	blez	s1,1f28 <forktest+0x6e>
    if(wait(0) < 0){
    1f16:	4501                	li	a0,0
    1f18:	00003097          	auipc	ra,0x3
    1f1c:	468080e7          	jalr	1128(ra) # 5380 <wait>
    1f20:	04054163          	bltz	a0,1f62 <forktest+0xa8>
  for(; n > 0; n--){
    1f24:	34fd                	addiw	s1,s1,-1
    1f26:	f8e5                	bnez	s1,1f16 <forktest+0x5c>
  if(wait(0) != -1){
    1f28:	4501                	li	a0,0
    1f2a:	00003097          	auipc	ra,0x3
    1f2e:	456080e7          	jalr	1110(ra) # 5380 <wait>
    1f32:	57fd                	li	a5,-1
    1f34:	04f51563          	bne	a0,a5,1f7e <forktest+0xc4>
}
    1f38:	70a2                	ld	ra,40(sp)
    1f3a:	7402                	ld	s0,32(sp)
    1f3c:	64e2                	ld	s1,24(sp)
    1f3e:	6942                	ld	s2,16(sp)
    1f40:	69a2                	ld	s3,8(sp)
    1f42:	6145                	addi	sp,sp,48
    1f44:	8082                	ret
    printf("%s: no fork at all!\n", s);
    1f46:	85ce                	mv	a1,s3
    1f48:	00004517          	auipc	a0,0x4
    1f4c:	72050513          	addi	a0,a0,1824 # 6668 <malloc+0xeba>
    1f50:	00003097          	auipc	ra,0x3
    1f54:	7a0080e7          	jalr	1952(ra) # 56f0 <printf>
    exit(1);
    1f58:	4505                	li	a0,1
    1f5a:	00003097          	auipc	ra,0x3
    1f5e:	41e080e7          	jalr	1054(ra) # 5378 <exit>
      printf("%s: wait stopped early\n", s);
    1f62:	85ce                	mv	a1,s3
    1f64:	00004517          	auipc	a0,0x4
    1f68:	74450513          	addi	a0,a0,1860 # 66a8 <malloc+0xefa>
    1f6c:	00003097          	auipc	ra,0x3
    1f70:	784080e7          	jalr	1924(ra) # 56f0 <printf>
      exit(1);
    1f74:	4505                	li	a0,1
    1f76:	00003097          	auipc	ra,0x3
    1f7a:	402080e7          	jalr	1026(ra) # 5378 <exit>
    printf("%s: wait got too many\n", s);
    1f7e:	85ce                	mv	a1,s3
    1f80:	00004517          	auipc	a0,0x4
    1f84:	74050513          	addi	a0,a0,1856 # 66c0 <malloc+0xf12>
    1f88:	00003097          	auipc	ra,0x3
    1f8c:	768080e7          	jalr	1896(ra) # 56f0 <printf>
    exit(1);
    1f90:	4505                	li	a0,1
    1f92:	00003097          	auipc	ra,0x3
    1f96:	3e6080e7          	jalr	998(ra) # 5378 <exit>

0000000000001f9a <kernmem>:
{
    1f9a:	715d                	addi	sp,sp,-80
    1f9c:	e486                	sd	ra,72(sp)
    1f9e:	e0a2                	sd	s0,64(sp)
    1fa0:	fc26                	sd	s1,56(sp)
    1fa2:	f84a                	sd	s2,48(sp)
    1fa4:	f44e                	sd	s3,40(sp)
    1fa6:	f052                	sd	s4,32(sp)
    1fa8:	ec56                	sd	s5,24(sp)
    1faa:	0880                	addi	s0,sp,80
    1fac:	8a2a                	mv	s4,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1fae:	4485                	li	s1,1
    1fb0:	04fe                	slli	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
    1fb2:	5afd                	li	s5,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1fb4:	69b1                	lui	s3,0xc
    1fb6:	35098993          	addi	s3,s3,848 # c350 <buf+0xc18>
    1fba:	1003d937          	lui	s2,0x1003d
    1fbe:	090e                	slli	s2,s2,0x3
    1fc0:	48090913          	addi	s2,s2,1152 # 1003d480 <__BSS_END__+0x1002ed38>
    pid = fork();
    1fc4:	00003097          	auipc	ra,0x3
    1fc8:	3ac080e7          	jalr	940(ra) # 5370 <fork>
    if(pid < 0){
    1fcc:	02054963          	bltz	a0,1ffe <kernmem+0x64>
    if(pid == 0){
    1fd0:	c529                	beqz	a0,201a <kernmem+0x80>
    wait(&xstatus);
    1fd2:	fbc40513          	addi	a0,s0,-68
    1fd6:	00003097          	auipc	ra,0x3
    1fda:	3aa080e7          	jalr	938(ra) # 5380 <wait>
    if(xstatus != -1)  // did kernel kill child?
    1fde:	fbc42783          	lw	a5,-68(s0)
    1fe2:	05579c63          	bne	a5,s5,203a <kernmem+0xa0>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1fe6:	94ce                	add	s1,s1,s3
    1fe8:	fd249ee3          	bne	s1,s2,1fc4 <kernmem+0x2a>
}
    1fec:	60a6                	ld	ra,72(sp)
    1fee:	6406                	ld	s0,64(sp)
    1ff0:	74e2                	ld	s1,56(sp)
    1ff2:	7942                	ld	s2,48(sp)
    1ff4:	79a2                	ld	s3,40(sp)
    1ff6:	7a02                	ld	s4,32(sp)
    1ff8:	6ae2                	ld	s5,24(sp)
    1ffa:	6161                	addi	sp,sp,80
    1ffc:	8082                	ret
      printf("%s: fork failed\n", s);
    1ffe:	85d2                	mv	a1,s4
    2000:	00004517          	auipc	a0,0x4
    2004:	40850513          	addi	a0,a0,1032 # 6408 <malloc+0xc5a>
    2008:	00003097          	auipc	ra,0x3
    200c:	6e8080e7          	jalr	1768(ra) # 56f0 <printf>
      exit(1);
    2010:	4505                	li	a0,1
    2012:	00003097          	auipc	ra,0x3
    2016:	366080e7          	jalr	870(ra) # 5378 <exit>
      printf("%s: oops could read %x = %x\n", a, *a);
    201a:	0004c603          	lbu	a2,0(s1)
    201e:	85a6                	mv	a1,s1
    2020:	00004517          	auipc	a0,0x4
    2024:	6b850513          	addi	a0,a0,1720 # 66d8 <malloc+0xf2a>
    2028:	00003097          	auipc	ra,0x3
    202c:	6c8080e7          	jalr	1736(ra) # 56f0 <printf>
      exit(1);
    2030:	4505                	li	a0,1
    2032:	00003097          	auipc	ra,0x3
    2036:	346080e7          	jalr	838(ra) # 5378 <exit>
      exit(1);
    203a:	4505                	li	a0,1
    203c:	00003097          	auipc	ra,0x3
    2040:	33c080e7          	jalr	828(ra) # 5378 <exit>

0000000000002044 <bigargtest>:
{
    2044:	7179                	addi	sp,sp,-48
    2046:	f406                	sd	ra,40(sp)
    2048:	f022                	sd	s0,32(sp)
    204a:	ec26                	sd	s1,24(sp)
    204c:	1800                	addi	s0,sp,48
    204e:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    2050:	00004517          	auipc	a0,0x4
    2054:	6a850513          	addi	a0,a0,1704 # 66f8 <malloc+0xf4a>
    2058:	00003097          	auipc	ra,0x3
    205c:	370080e7          	jalr	880(ra) # 53c8 <unlink>
  pid = fork();
    2060:	00003097          	auipc	ra,0x3
    2064:	310080e7          	jalr	784(ra) # 5370 <fork>
  if(pid == 0){
    2068:	c121                	beqz	a0,20a8 <bigargtest+0x64>
  } else if(pid < 0){
    206a:	0a054063          	bltz	a0,210a <bigargtest+0xc6>
  wait(&xstatus);
    206e:	fdc40513          	addi	a0,s0,-36
    2072:	00003097          	auipc	ra,0x3
    2076:	30e080e7          	jalr	782(ra) # 5380 <wait>
  if(xstatus != 0)
    207a:	fdc42503          	lw	a0,-36(s0)
    207e:	e545                	bnez	a0,2126 <bigargtest+0xe2>
  fd = open("bigarg-ok", 0);
    2080:	4581                	li	a1,0
    2082:	00004517          	auipc	a0,0x4
    2086:	67650513          	addi	a0,a0,1654 # 66f8 <malloc+0xf4a>
    208a:	00003097          	auipc	ra,0x3
    208e:	32e080e7          	jalr	814(ra) # 53b8 <open>
  if(fd < 0){
    2092:	08054e63          	bltz	a0,212e <bigargtest+0xea>
  close(fd);
    2096:	00003097          	auipc	ra,0x3
    209a:	30a080e7          	jalr	778(ra) # 53a0 <close>
}
    209e:	70a2                	ld	ra,40(sp)
    20a0:	7402                	ld	s0,32(sp)
    20a2:	64e2                	ld	s1,24(sp)
    20a4:	6145                	addi	sp,sp,48
    20a6:	8082                	ret
    20a8:	00006797          	auipc	a5,0x6
    20ac:	e7878793          	addi	a5,a5,-392 # 7f20 <args.1802>
    20b0:	00006697          	auipc	a3,0x6
    20b4:	f6868693          	addi	a3,a3,-152 # 8018 <args.1802+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    20b8:	00004717          	auipc	a4,0x4
    20bc:	65070713          	addi	a4,a4,1616 # 6708 <malloc+0xf5a>
    20c0:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    20c2:	07a1                	addi	a5,a5,8
    20c4:	fed79ee3          	bne	a5,a3,20c0 <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    20c8:	00006597          	auipc	a1,0x6
    20cc:	e5858593          	addi	a1,a1,-424 # 7f20 <args.1802>
    20d0:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    20d4:	00004517          	auipc	a0,0x4
    20d8:	afc50513          	addi	a0,a0,-1284 # 5bd0 <malloc+0x422>
    20dc:	00003097          	auipc	ra,0x3
    20e0:	2d4080e7          	jalr	724(ra) # 53b0 <exec>
    fd = open("bigarg-ok", O_CREATE);
    20e4:	20000593          	li	a1,512
    20e8:	00004517          	auipc	a0,0x4
    20ec:	61050513          	addi	a0,a0,1552 # 66f8 <malloc+0xf4a>
    20f0:	00003097          	auipc	ra,0x3
    20f4:	2c8080e7          	jalr	712(ra) # 53b8 <open>
    close(fd);
    20f8:	00003097          	auipc	ra,0x3
    20fc:	2a8080e7          	jalr	680(ra) # 53a0 <close>
    exit(0);
    2100:	4501                	li	a0,0
    2102:	00003097          	auipc	ra,0x3
    2106:	276080e7          	jalr	630(ra) # 5378 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    210a:	85a6                	mv	a1,s1
    210c:	00004517          	auipc	a0,0x4
    2110:	6dc50513          	addi	a0,a0,1756 # 67e8 <malloc+0x103a>
    2114:	00003097          	auipc	ra,0x3
    2118:	5dc080e7          	jalr	1500(ra) # 56f0 <printf>
    exit(1);
    211c:	4505                	li	a0,1
    211e:	00003097          	auipc	ra,0x3
    2122:	25a080e7          	jalr	602(ra) # 5378 <exit>
    exit(xstatus);
    2126:	00003097          	auipc	ra,0x3
    212a:	252080e7          	jalr	594(ra) # 5378 <exit>
    printf("%s: bigarg test failed!\n", s);
    212e:	85a6                	mv	a1,s1
    2130:	00004517          	auipc	a0,0x4
    2134:	6d850513          	addi	a0,a0,1752 # 6808 <malloc+0x105a>
    2138:	00003097          	auipc	ra,0x3
    213c:	5b8080e7          	jalr	1464(ra) # 56f0 <printf>
    exit(1);
    2140:	4505                	li	a0,1
    2142:	00003097          	auipc	ra,0x3
    2146:	236080e7          	jalr	566(ra) # 5378 <exit>

000000000000214a <stacktest>:
{
    214a:	7179                	addi	sp,sp,-48
    214c:	f406                	sd	ra,40(sp)
    214e:	f022                	sd	s0,32(sp)
    2150:	ec26                	sd	s1,24(sp)
    2152:	1800                	addi	s0,sp,48
    2154:	84aa                	mv	s1,a0
  pid = fork();
    2156:	00003097          	auipc	ra,0x3
    215a:	21a080e7          	jalr	538(ra) # 5370 <fork>
  if(pid == 0) {
    215e:	c115                	beqz	a0,2182 <stacktest+0x38>
  } else if(pid < 0){
    2160:	04054363          	bltz	a0,21a6 <stacktest+0x5c>
  wait(&xstatus);
    2164:	fdc40513          	addi	a0,s0,-36
    2168:	00003097          	auipc	ra,0x3
    216c:	218080e7          	jalr	536(ra) # 5380 <wait>
  if(xstatus == -1)  // kernel killed child?
    2170:	fdc42503          	lw	a0,-36(s0)
    2174:	57fd                	li	a5,-1
    2176:	04f50663          	beq	a0,a5,21c2 <stacktest+0x78>
    exit(xstatus);
    217a:	00003097          	auipc	ra,0x3
    217e:	1fe080e7          	jalr	510(ra) # 5378 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    2182:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", *sp);
    2184:	77fd                	lui	a5,0xfffff
    2186:	97ba                	add	a5,a5,a4
    2188:	0007c583          	lbu	a1,0(a5) # fffffffffffff000 <__BSS_END__+0xffffffffffff08b8>
    218c:	00004517          	auipc	a0,0x4
    2190:	69c50513          	addi	a0,a0,1692 # 6828 <malloc+0x107a>
    2194:	00003097          	auipc	ra,0x3
    2198:	55c080e7          	jalr	1372(ra) # 56f0 <printf>
    exit(1);
    219c:	4505                	li	a0,1
    219e:	00003097          	auipc	ra,0x3
    21a2:	1da080e7          	jalr	474(ra) # 5378 <exit>
    printf("%s: fork failed\n", s);
    21a6:	85a6                	mv	a1,s1
    21a8:	00004517          	auipc	a0,0x4
    21ac:	26050513          	addi	a0,a0,608 # 6408 <malloc+0xc5a>
    21b0:	00003097          	auipc	ra,0x3
    21b4:	540080e7          	jalr	1344(ra) # 56f0 <printf>
    exit(1);
    21b8:	4505                	li	a0,1
    21ba:	00003097          	auipc	ra,0x3
    21be:	1be080e7          	jalr	446(ra) # 5378 <exit>
    exit(0);
    21c2:	4501                	li	a0,0
    21c4:	00003097          	auipc	ra,0x3
    21c8:	1b4080e7          	jalr	436(ra) # 5378 <exit>

00000000000021cc <copyinstr3>:
{
    21cc:	7179                	addi	sp,sp,-48
    21ce:	f406                	sd	ra,40(sp)
    21d0:	f022                	sd	s0,32(sp)
    21d2:	ec26                	sd	s1,24(sp)
    21d4:	1800                	addi	s0,sp,48
  sbrk(8192);
    21d6:	6509                	lui	a0,0x2
    21d8:	00003097          	auipc	ra,0x3
    21dc:	228080e7          	jalr	552(ra) # 5400 <sbrk>
  uint64 top = (uint64) sbrk(0);
    21e0:	4501                	li	a0,0
    21e2:	00003097          	auipc	ra,0x3
    21e6:	21e080e7          	jalr	542(ra) # 5400 <sbrk>
  if((top % PGSIZE) != 0){
    21ea:	03451793          	slli	a5,a0,0x34
    21ee:	e3c9                	bnez	a5,2270 <copyinstr3+0xa4>
  top = (uint64) sbrk(0);
    21f0:	4501                	li	a0,0
    21f2:	00003097          	auipc	ra,0x3
    21f6:	20e080e7          	jalr	526(ra) # 5400 <sbrk>
  if(top % PGSIZE){
    21fa:	03451793          	slli	a5,a0,0x34
    21fe:	e3d9                	bnez	a5,2284 <copyinstr3+0xb8>
  char *b = (char *) (top - 1);
    2200:	fff50493          	addi	s1,a0,-1 # 1fff <kernmem+0x65>
  *b = 'x';
    2204:	07800793          	li	a5,120
    2208:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    220c:	8526                	mv	a0,s1
    220e:	00003097          	auipc	ra,0x3
    2212:	1ba080e7          	jalr	442(ra) # 53c8 <unlink>
  if(ret != -1){
    2216:	57fd                	li	a5,-1
    2218:	08f51363          	bne	a0,a5,229e <copyinstr3+0xd2>
  int fd = open(b, O_CREATE | O_WRONLY);
    221c:	20100593          	li	a1,513
    2220:	8526                	mv	a0,s1
    2222:	00003097          	auipc	ra,0x3
    2226:	196080e7          	jalr	406(ra) # 53b8 <open>
  if(fd != -1){
    222a:	57fd                	li	a5,-1
    222c:	08f51863          	bne	a0,a5,22bc <copyinstr3+0xf0>
  ret = link(b, b);
    2230:	85a6                	mv	a1,s1
    2232:	8526                	mv	a0,s1
    2234:	00003097          	auipc	ra,0x3
    2238:	1a4080e7          	jalr	420(ra) # 53d8 <link>
  if(ret != -1){
    223c:	57fd                	li	a5,-1
    223e:	08f51e63          	bne	a0,a5,22da <copyinstr3+0x10e>
  char *args[] = { "xx", 0 };
    2242:	00005797          	auipc	a5,0x5
    2246:	18678793          	addi	a5,a5,390 # 73c8 <malloc+0x1c1a>
    224a:	fcf43823          	sd	a5,-48(s0)
    224e:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    2252:	fd040593          	addi	a1,s0,-48
    2256:	8526                	mv	a0,s1
    2258:	00003097          	auipc	ra,0x3
    225c:	158080e7          	jalr	344(ra) # 53b0 <exec>
  if(ret != -1){
    2260:	57fd                	li	a5,-1
    2262:	08f51c63          	bne	a0,a5,22fa <copyinstr3+0x12e>
}
    2266:	70a2                	ld	ra,40(sp)
    2268:	7402                	ld	s0,32(sp)
    226a:	64e2                	ld	s1,24(sp)
    226c:	6145                	addi	sp,sp,48
    226e:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    2270:	0347d513          	srli	a0,a5,0x34
    2274:	6785                	lui	a5,0x1
    2276:	40a7853b          	subw	a0,a5,a0
    227a:	00003097          	auipc	ra,0x3
    227e:	186080e7          	jalr	390(ra) # 5400 <sbrk>
    2282:	b7bd                	j	21f0 <copyinstr3+0x24>
    printf("oops\n");
    2284:	00004517          	auipc	a0,0x4
    2288:	5cc50513          	addi	a0,a0,1484 # 6850 <malloc+0x10a2>
    228c:	00003097          	auipc	ra,0x3
    2290:	464080e7          	jalr	1124(ra) # 56f0 <printf>
    exit(1);
    2294:	4505                	li	a0,1
    2296:	00003097          	auipc	ra,0x3
    229a:	0e2080e7          	jalr	226(ra) # 5378 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    229e:	862a                	mv	a2,a0
    22a0:	85a6                	mv	a1,s1
    22a2:	00004517          	auipc	a0,0x4
    22a6:	08650513          	addi	a0,a0,134 # 6328 <malloc+0xb7a>
    22aa:	00003097          	auipc	ra,0x3
    22ae:	446080e7          	jalr	1094(ra) # 56f0 <printf>
    exit(1);
    22b2:	4505                	li	a0,1
    22b4:	00003097          	auipc	ra,0x3
    22b8:	0c4080e7          	jalr	196(ra) # 5378 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    22bc:	862a                	mv	a2,a0
    22be:	85a6                	mv	a1,s1
    22c0:	00004517          	auipc	a0,0x4
    22c4:	08850513          	addi	a0,a0,136 # 6348 <malloc+0xb9a>
    22c8:	00003097          	auipc	ra,0x3
    22cc:	428080e7          	jalr	1064(ra) # 56f0 <printf>
    exit(1);
    22d0:	4505                	li	a0,1
    22d2:	00003097          	auipc	ra,0x3
    22d6:	0a6080e7          	jalr	166(ra) # 5378 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    22da:	86aa                	mv	a3,a0
    22dc:	8626                	mv	a2,s1
    22de:	85a6                	mv	a1,s1
    22e0:	00004517          	auipc	a0,0x4
    22e4:	08850513          	addi	a0,a0,136 # 6368 <malloc+0xbba>
    22e8:	00003097          	auipc	ra,0x3
    22ec:	408080e7          	jalr	1032(ra) # 56f0 <printf>
    exit(1);
    22f0:	4505                	li	a0,1
    22f2:	00003097          	auipc	ra,0x3
    22f6:	086080e7          	jalr	134(ra) # 5378 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    22fa:	567d                	li	a2,-1
    22fc:	85a6                	mv	a1,s1
    22fe:	00004517          	auipc	a0,0x4
    2302:	09250513          	addi	a0,a0,146 # 6390 <malloc+0xbe2>
    2306:	00003097          	auipc	ra,0x3
    230a:	3ea080e7          	jalr	1002(ra) # 56f0 <printf>
    exit(1);
    230e:	4505                	li	a0,1
    2310:	00003097          	auipc	ra,0x3
    2314:	068080e7          	jalr	104(ra) # 5378 <exit>

0000000000002318 <sbrkbasic>:
{
    2318:	715d                	addi	sp,sp,-80
    231a:	e486                	sd	ra,72(sp)
    231c:	e0a2                	sd	s0,64(sp)
    231e:	fc26                	sd	s1,56(sp)
    2320:	f84a                	sd	s2,48(sp)
    2322:	f44e                	sd	s3,40(sp)
    2324:	f052                	sd	s4,32(sp)
    2326:	ec56                	sd	s5,24(sp)
    2328:	0880                	addi	s0,sp,80
    232a:	8a2a                	mv	s4,a0
  pid = fork();
    232c:	00003097          	auipc	ra,0x3
    2330:	044080e7          	jalr	68(ra) # 5370 <fork>
  if(pid < 0){
    2334:	02054c63          	bltz	a0,236c <sbrkbasic+0x54>
  if(pid == 0){
    2338:	ed21                	bnez	a0,2390 <sbrkbasic+0x78>
    a = sbrk(TOOMUCH);
    233a:	40000537          	lui	a0,0x40000
    233e:	00003097          	auipc	ra,0x3
    2342:	0c2080e7          	jalr	194(ra) # 5400 <sbrk>
    if(a == (char*)0xffffffffffffffffL){
    2346:	57fd                	li	a5,-1
    2348:	02f50f63          	beq	a0,a5,2386 <sbrkbasic+0x6e>
    for(b = a; b < a+TOOMUCH; b += 4096){
    234c:	400007b7          	lui	a5,0x40000
    2350:	97aa                	add	a5,a5,a0
      *b = 99;
    2352:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += 4096){
    2356:	6705                	lui	a4,0x1
      *b = 99;
    2358:	00d50023          	sb	a3,0(a0) # 40000000 <__BSS_END__+0x3fff18b8>
    for(b = a; b < a+TOOMUCH; b += 4096){
    235c:	953a                	add	a0,a0,a4
    235e:	fef51de3          	bne	a0,a5,2358 <sbrkbasic+0x40>
    exit(1);
    2362:	4505                	li	a0,1
    2364:	00003097          	auipc	ra,0x3
    2368:	014080e7          	jalr	20(ra) # 5378 <exit>
    printf("fork failed in sbrkbasic\n");
    236c:	00004517          	auipc	a0,0x4
    2370:	4ec50513          	addi	a0,a0,1260 # 6858 <malloc+0x10aa>
    2374:	00003097          	auipc	ra,0x3
    2378:	37c080e7          	jalr	892(ra) # 56f0 <printf>
    exit(1);
    237c:	4505                	li	a0,1
    237e:	00003097          	auipc	ra,0x3
    2382:	ffa080e7          	jalr	-6(ra) # 5378 <exit>
      exit(0);
    2386:	4501                	li	a0,0
    2388:	00003097          	auipc	ra,0x3
    238c:	ff0080e7          	jalr	-16(ra) # 5378 <exit>
  wait(&xstatus);
    2390:	fbc40513          	addi	a0,s0,-68
    2394:	00003097          	auipc	ra,0x3
    2398:	fec080e7          	jalr	-20(ra) # 5380 <wait>
  if(xstatus == 1){
    239c:	fbc42703          	lw	a4,-68(s0)
    23a0:	4785                	li	a5,1
    23a2:	00f70e63          	beq	a4,a5,23be <sbrkbasic+0xa6>
  a = sbrk(0);
    23a6:	4501                	li	a0,0
    23a8:	00003097          	auipc	ra,0x3
    23ac:	058080e7          	jalr	88(ra) # 5400 <sbrk>
    23b0:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    23b2:	4901                	li	s2,0
    *b = 1;
    23b4:	4a85                	li	s5,1
  for(i = 0; i < 5000; i++){
    23b6:	6985                	lui	s3,0x1
    23b8:	38898993          	addi	s3,s3,904 # 1388 <copyinstr2+0x1ce>
    23bc:	a005                	j	23dc <sbrkbasic+0xc4>
    printf("%s: too much memory allocated!\n", s);
    23be:	85d2                	mv	a1,s4
    23c0:	00004517          	auipc	a0,0x4
    23c4:	4b850513          	addi	a0,a0,1208 # 6878 <malloc+0x10ca>
    23c8:	00003097          	auipc	ra,0x3
    23cc:	328080e7          	jalr	808(ra) # 56f0 <printf>
    exit(1);
    23d0:	4505                	li	a0,1
    23d2:	00003097          	auipc	ra,0x3
    23d6:	fa6080e7          	jalr	-90(ra) # 5378 <exit>
    a = b + 1;
    23da:	84be                	mv	s1,a5
    b = sbrk(1);
    23dc:	4505                	li	a0,1
    23de:	00003097          	auipc	ra,0x3
    23e2:	022080e7          	jalr	34(ra) # 5400 <sbrk>
    if(b != a){
    23e6:	04951b63          	bne	a0,s1,243c <sbrkbasic+0x124>
    *b = 1;
    23ea:	01548023          	sb	s5,0(s1)
    a = b + 1;
    23ee:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    23f2:	2905                	addiw	s2,s2,1
    23f4:	ff3913e3          	bne	s2,s3,23da <sbrkbasic+0xc2>
  pid = fork();
    23f8:	00003097          	auipc	ra,0x3
    23fc:	f78080e7          	jalr	-136(ra) # 5370 <fork>
    2400:	892a                	mv	s2,a0
  if(pid < 0){
    2402:	04054d63          	bltz	a0,245c <sbrkbasic+0x144>
  c = sbrk(1);
    2406:	4505                	li	a0,1
    2408:	00003097          	auipc	ra,0x3
    240c:	ff8080e7          	jalr	-8(ra) # 5400 <sbrk>
  c = sbrk(1);
    2410:	4505                	li	a0,1
    2412:	00003097          	auipc	ra,0x3
    2416:	fee080e7          	jalr	-18(ra) # 5400 <sbrk>
  if(c != a + 1){
    241a:	0489                	addi	s1,s1,2
    241c:	04a48e63          	beq	s1,a0,2478 <sbrkbasic+0x160>
    printf("%s: sbrk test failed post-fork\n", s);
    2420:	85d2                	mv	a1,s4
    2422:	00004517          	auipc	a0,0x4
    2426:	4b650513          	addi	a0,a0,1206 # 68d8 <malloc+0x112a>
    242a:	00003097          	auipc	ra,0x3
    242e:	2c6080e7          	jalr	710(ra) # 56f0 <printf>
    exit(1);
    2432:	4505                	li	a0,1
    2434:	00003097          	auipc	ra,0x3
    2438:	f44080e7          	jalr	-188(ra) # 5378 <exit>
      printf("%s: sbrk test failed %d %x %x\n", i, a, b);
    243c:	86aa                	mv	a3,a0
    243e:	8626                	mv	a2,s1
    2440:	85ca                	mv	a1,s2
    2442:	00004517          	auipc	a0,0x4
    2446:	45650513          	addi	a0,a0,1110 # 6898 <malloc+0x10ea>
    244a:	00003097          	auipc	ra,0x3
    244e:	2a6080e7          	jalr	678(ra) # 56f0 <printf>
      exit(1);
    2452:	4505                	li	a0,1
    2454:	00003097          	auipc	ra,0x3
    2458:	f24080e7          	jalr	-220(ra) # 5378 <exit>
    printf("%s: sbrk test fork failed\n", s);
    245c:	85d2                	mv	a1,s4
    245e:	00004517          	auipc	a0,0x4
    2462:	45a50513          	addi	a0,a0,1114 # 68b8 <malloc+0x110a>
    2466:	00003097          	auipc	ra,0x3
    246a:	28a080e7          	jalr	650(ra) # 56f0 <printf>
    exit(1);
    246e:	4505                	li	a0,1
    2470:	00003097          	auipc	ra,0x3
    2474:	f08080e7          	jalr	-248(ra) # 5378 <exit>
  if(pid == 0)
    2478:	00091763          	bnez	s2,2486 <sbrkbasic+0x16e>
    exit(0);
    247c:	4501                	li	a0,0
    247e:	00003097          	auipc	ra,0x3
    2482:	efa080e7          	jalr	-262(ra) # 5378 <exit>
  wait(&xstatus);
    2486:	fbc40513          	addi	a0,s0,-68
    248a:	00003097          	auipc	ra,0x3
    248e:	ef6080e7          	jalr	-266(ra) # 5380 <wait>
  exit(xstatus);
    2492:	fbc42503          	lw	a0,-68(s0)
    2496:	00003097          	auipc	ra,0x3
    249a:	ee2080e7          	jalr	-286(ra) # 5378 <exit>

000000000000249e <sbrkmuch>:
{
    249e:	7179                	addi	sp,sp,-48
    24a0:	f406                	sd	ra,40(sp)
    24a2:	f022                	sd	s0,32(sp)
    24a4:	ec26                	sd	s1,24(sp)
    24a6:	e84a                	sd	s2,16(sp)
    24a8:	e44e                	sd	s3,8(sp)
    24aa:	e052                	sd	s4,0(sp)
    24ac:	1800                	addi	s0,sp,48
    24ae:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    24b0:	4501                	li	a0,0
    24b2:	00003097          	auipc	ra,0x3
    24b6:	f4e080e7          	jalr	-178(ra) # 5400 <sbrk>
    24ba:	892a                	mv	s2,a0
  a = sbrk(0);
    24bc:	4501                	li	a0,0
    24be:	00003097          	auipc	ra,0x3
    24c2:	f42080e7          	jalr	-190(ra) # 5400 <sbrk>
    24c6:	84aa                	mv	s1,a0
  p = sbrk(amt);
    24c8:	06400537          	lui	a0,0x6400
    24cc:	9d05                	subw	a0,a0,s1
    24ce:	00003097          	auipc	ra,0x3
    24d2:	f32080e7          	jalr	-206(ra) # 5400 <sbrk>
  if (p != a) {
    24d6:	0ca49863          	bne	s1,a0,25a6 <sbrkmuch+0x108>
  char *eee = sbrk(0);
    24da:	4501                	li	a0,0
    24dc:	00003097          	auipc	ra,0x3
    24e0:	f24080e7          	jalr	-220(ra) # 5400 <sbrk>
    24e4:	87aa                	mv	a5,a0
  for(char *pp = a; pp < eee; pp += 4096)
    24e6:	00a4f963          	bgeu	s1,a0,24f8 <sbrkmuch+0x5a>
    *pp = 1;
    24ea:	4685                	li	a3,1
  for(char *pp = a; pp < eee; pp += 4096)
    24ec:	6705                	lui	a4,0x1
    *pp = 1;
    24ee:	00d48023          	sb	a3,0(s1)
  for(char *pp = a; pp < eee; pp += 4096)
    24f2:	94ba                	add	s1,s1,a4
    24f4:	fef4ede3          	bltu	s1,a5,24ee <sbrkmuch+0x50>
  *lastaddr = 99;
    24f8:	064007b7          	lui	a5,0x6400
    24fc:	06300713          	li	a4,99
    2500:	fee78fa3          	sb	a4,-1(a5) # 63fffff <__BSS_END__+0x63f18b7>
  a = sbrk(0);
    2504:	4501                	li	a0,0
    2506:	00003097          	auipc	ra,0x3
    250a:	efa080e7          	jalr	-262(ra) # 5400 <sbrk>
    250e:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    2510:	757d                	lui	a0,0xfffff
    2512:	00003097          	auipc	ra,0x3
    2516:	eee080e7          	jalr	-274(ra) # 5400 <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    251a:	57fd                	li	a5,-1
    251c:	0af50363          	beq	a0,a5,25c2 <sbrkmuch+0x124>
  c = sbrk(0);
    2520:	4501                	li	a0,0
    2522:	00003097          	auipc	ra,0x3
    2526:	ede080e7          	jalr	-290(ra) # 5400 <sbrk>
  if(c != a - PGSIZE){
    252a:	77fd                	lui	a5,0xfffff
    252c:	97a6                	add	a5,a5,s1
    252e:	0af51863          	bne	a0,a5,25de <sbrkmuch+0x140>
  a = sbrk(0);
    2532:	4501                	li	a0,0
    2534:	00003097          	auipc	ra,0x3
    2538:	ecc080e7          	jalr	-308(ra) # 5400 <sbrk>
    253c:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    253e:	6505                	lui	a0,0x1
    2540:	00003097          	auipc	ra,0x3
    2544:	ec0080e7          	jalr	-320(ra) # 5400 <sbrk>
    2548:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    254a:	0aa49963          	bne	s1,a0,25fc <sbrkmuch+0x15e>
    254e:	4501                	li	a0,0
    2550:	00003097          	auipc	ra,0x3
    2554:	eb0080e7          	jalr	-336(ra) # 5400 <sbrk>
    2558:	6785                	lui	a5,0x1
    255a:	97a6                	add	a5,a5,s1
    255c:	0af51063          	bne	a0,a5,25fc <sbrkmuch+0x15e>
  if(*lastaddr == 99){
    2560:	064007b7          	lui	a5,0x6400
    2564:	fff7c703          	lbu	a4,-1(a5) # 63fffff <__BSS_END__+0x63f18b7>
    2568:	06300793          	li	a5,99
    256c:	0af70763          	beq	a4,a5,261a <sbrkmuch+0x17c>
  a = sbrk(0);
    2570:	4501                	li	a0,0
    2572:	00003097          	auipc	ra,0x3
    2576:	e8e080e7          	jalr	-370(ra) # 5400 <sbrk>
    257a:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    257c:	4501                	li	a0,0
    257e:	00003097          	auipc	ra,0x3
    2582:	e82080e7          	jalr	-382(ra) # 5400 <sbrk>
    2586:	40a9053b          	subw	a0,s2,a0
    258a:	00003097          	auipc	ra,0x3
    258e:	e76080e7          	jalr	-394(ra) # 5400 <sbrk>
  if(c != a){
    2592:	0aa49263          	bne	s1,a0,2636 <sbrkmuch+0x198>
}
    2596:	70a2                	ld	ra,40(sp)
    2598:	7402                	ld	s0,32(sp)
    259a:	64e2                	ld	s1,24(sp)
    259c:	6942                	ld	s2,16(sp)
    259e:	69a2                	ld	s3,8(sp)
    25a0:	6a02                	ld	s4,0(sp)
    25a2:	6145                	addi	sp,sp,48
    25a4:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    25a6:	85ce                	mv	a1,s3
    25a8:	00004517          	auipc	a0,0x4
    25ac:	35050513          	addi	a0,a0,848 # 68f8 <malloc+0x114a>
    25b0:	00003097          	auipc	ra,0x3
    25b4:	140080e7          	jalr	320(ra) # 56f0 <printf>
    exit(1);
    25b8:	4505                	li	a0,1
    25ba:	00003097          	auipc	ra,0x3
    25be:	dbe080e7          	jalr	-578(ra) # 5378 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    25c2:	85ce                	mv	a1,s3
    25c4:	00004517          	auipc	a0,0x4
    25c8:	37c50513          	addi	a0,a0,892 # 6940 <malloc+0x1192>
    25cc:	00003097          	auipc	ra,0x3
    25d0:	124080e7          	jalr	292(ra) # 56f0 <printf>
    exit(1);
    25d4:	4505                	li	a0,1
    25d6:	00003097          	auipc	ra,0x3
    25da:	da2080e7          	jalr	-606(ra) # 5378 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", a, c);
    25de:	862a                	mv	a2,a0
    25e0:	85a6                	mv	a1,s1
    25e2:	00004517          	auipc	a0,0x4
    25e6:	37e50513          	addi	a0,a0,894 # 6960 <malloc+0x11b2>
    25ea:	00003097          	auipc	ra,0x3
    25ee:	106080e7          	jalr	262(ra) # 56f0 <printf>
    exit(1);
    25f2:	4505                	li	a0,1
    25f4:	00003097          	auipc	ra,0x3
    25f8:	d84080e7          	jalr	-636(ra) # 5378 <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", a, c);
    25fc:	8652                	mv	a2,s4
    25fe:	85a6                	mv	a1,s1
    2600:	00004517          	auipc	a0,0x4
    2604:	3a050513          	addi	a0,a0,928 # 69a0 <malloc+0x11f2>
    2608:	00003097          	auipc	ra,0x3
    260c:	0e8080e7          	jalr	232(ra) # 56f0 <printf>
    exit(1);
    2610:	4505                	li	a0,1
    2612:	00003097          	auipc	ra,0x3
    2616:	d66080e7          	jalr	-666(ra) # 5378 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    261a:	85ce                	mv	a1,s3
    261c:	00004517          	auipc	a0,0x4
    2620:	3b450513          	addi	a0,a0,948 # 69d0 <malloc+0x1222>
    2624:	00003097          	auipc	ra,0x3
    2628:	0cc080e7          	jalr	204(ra) # 56f0 <printf>
    exit(1);
    262c:	4505                	li	a0,1
    262e:	00003097          	auipc	ra,0x3
    2632:	d4a080e7          	jalr	-694(ra) # 5378 <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", a, c);
    2636:	862a                	mv	a2,a0
    2638:	85a6                	mv	a1,s1
    263a:	00004517          	auipc	a0,0x4
    263e:	3ce50513          	addi	a0,a0,974 # 6a08 <malloc+0x125a>
    2642:	00003097          	auipc	ra,0x3
    2646:	0ae080e7          	jalr	174(ra) # 56f0 <printf>
    exit(1);
    264a:	4505                	li	a0,1
    264c:	00003097          	auipc	ra,0x3
    2650:	d2c080e7          	jalr	-724(ra) # 5378 <exit>

0000000000002654 <sbrkarg>:
{
    2654:	7179                	addi	sp,sp,-48
    2656:	f406                	sd	ra,40(sp)
    2658:	f022                	sd	s0,32(sp)
    265a:	ec26                	sd	s1,24(sp)
    265c:	e84a                	sd	s2,16(sp)
    265e:	e44e                	sd	s3,8(sp)
    2660:	1800                	addi	s0,sp,48
    2662:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    2664:	6505                	lui	a0,0x1
    2666:	00003097          	auipc	ra,0x3
    266a:	d9a080e7          	jalr	-614(ra) # 5400 <sbrk>
    266e:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    2670:	20100593          	li	a1,513
    2674:	00004517          	auipc	a0,0x4
    2678:	3bc50513          	addi	a0,a0,956 # 6a30 <malloc+0x1282>
    267c:	00003097          	auipc	ra,0x3
    2680:	d3c080e7          	jalr	-708(ra) # 53b8 <open>
    2684:	84aa                	mv	s1,a0
  unlink("sbrk");
    2686:	00004517          	auipc	a0,0x4
    268a:	3aa50513          	addi	a0,a0,938 # 6a30 <malloc+0x1282>
    268e:	00003097          	auipc	ra,0x3
    2692:	d3a080e7          	jalr	-710(ra) # 53c8 <unlink>
  if(fd < 0)  {
    2696:	0404c163          	bltz	s1,26d8 <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    269a:	6605                	lui	a2,0x1
    269c:	85ca                	mv	a1,s2
    269e:	8526                	mv	a0,s1
    26a0:	00003097          	auipc	ra,0x3
    26a4:	cf8080e7          	jalr	-776(ra) # 5398 <write>
    26a8:	04054663          	bltz	a0,26f4 <sbrkarg+0xa0>
  close(fd);
    26ac:	8526                	mv	a0,s1
    26ae:	00003097          	auipc	ra,0x3
    26b2:	cf2080e7          	jalr	-782(ra) # 53a0 <close>
  a = sbrk(PGSIZE);
    26b6:	6505                	lui	a0,0x1
    26b8:	00003097          	auipc	ra,0x3
    26bc:	d48080e7          	jalr	-696(ra) # 5400 <sbrk>
  if(pipe((int *) a) != 0){
    26c0:	00003097          	auipc	ra,0x3
    26c4:	cc8080e7          	jalr	-824(ra) # 5388 <pipe>
    26c8:	e521                	bnez	a0,2710 <sbrkarg+0xbc>
}
    26ca:	70a2                	ld	ra,40(sp)
    26cc:	7402                	ld	s0,32(sp)
    26ce:	64e2                	ld	s1,24(sp)
    26d0:	6942                	ld	s2,16(sp)
    26d2:	69a2                	ld	s3,8(sp)
    26d4:	6145                	addi	sp,sp,48
    26d6:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    26d8:	85ce                	mv	a1,s3
    26da:	00004517          	auipc	a0,0x4
    26de:	35e50513          	addi	a0,a0,862 # 6a38 <malloc+0x128a>
    26e2:	00003097          	auipc	ra,0x3
    26e6:	00e080e7          	jalr	14(ra) # 56f0 <printf>
    exit(1);
    26ea:	4505                	li	a0,1
    26ec:	00003097          	auipc	ra,0x3
    26f0:	c8c080e7          	jalr	-884(ra) # 5378 <exit>
    printf("%s: write sbrk failed\n", s);
    26f4:	85ce                	mv	a1,s3
    26f6:	00004517          	auipc	a0,0x4
    26fa:	35a50513          	addi	a0,a0,858 # 6a50 <malloc+0x12a2>
    26fe:	00003097          	auipc	ra,0x3
    2702:	ff2080e7          	jalr	-14(ra) # 56f0 <printf>
    exit(1);
    2706:	4505                	li	a0,1
    2708:	00003097          	auipc	ra,0x3
    270c:	c70080e7          	jalr	-912(ra) # 5378 <exit>
    printf("%s: pipe() failed\n", s);
    2710:	85ce                	mv	a1,s3
    2712:	00004517          	auipc	a0,0x4
    2716:	dfe50513          	addi	a0,a0,-514 # 6510 <malloc+0xd62>
    271a:	00003097          	auipc	ra,0x3
    271e:	fd6080e7          	jalr	-42(ra) # 56f0 <printf>
    exit(1);
    2722:	4505                	li	a0,1
    2724:	00003097          	auipc	ra,0x3
    2728:	c54080e7          	jalr	-940(ra) # 5378 <exit>

000000000000272c <argptest>:
{
    272c:	1101                	addi	sp,sp,-32
    272e:	ec06                	sd	ra,24(sp)
    2730:	e822                	sd	s0,16(sp)
    2732:	e426                	sd	s1,8(sp)
    2734:	e04a                	sd	s2,0(sp)
    2736:	1000                	addi	s0,sp,32
    2738:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    273a:	4581                	li	a1,0
    273c:	00004517          	auipc	a0,0x4
    2740:	32c50513          	addi	a0,a0,812 # 6a68 <malloc+0x12ba>
    2744:	00003097          	auipc	ra,0x3
    2748:	c74080e7          	jalr	-908(ra) # 53b8 <open>
  if (fd < 0) {
    274c:	02054b63          	bltz	a0,2782 <argptest+0x56>
    2750:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    2752:	4501                	li	a0,0
    2754:	00003097          	auipc	ra,0x3
    2758:	cac080e7          	jalr	-852(ra) # 5400 <sbrk>
    275c:	567d                	li	a2,-1
    275e:	fff50593          	addi	a1,a0,-1
    2762:	8526                	mv	a0,s1
    2764:	00003097          	auipc	ra,0x3
    2768:	c2c080e7          	jalr	-980(ra) # 5390 <read>
  close(fd);
    276c:	8526                	mv	a0,s1
    276e:	00003097          	auipc	ra,0x3
    2772:	c32080e7          	jalr	-974(ra) # 53a0 <close>
}
    2776:	60e2                	ld	ra,24(sp)
    2778:	6442                	ld	s0,16(sp)
    277a:	64a2                	ld	s1,8(sp)
    277c:	6902                	ld	s2,0(sp)
    277e:	6105                	addi	sp,sp,32
    2780:	8082                	ret
    printf("%s: open failed\n", s);
    2782:	85ca                	mv	a1,s2
    2784:	00004517          	auipc	a0,0x4
    2788:	c9c50513          	addi	a0,a0,-868 # 6420 <malloc+0xc72>
    278c:	00003097          	auipc	ra,0x3
    2790:	f64080e7          	jalr	-156(ra) # 56f0 <printf>
    exit(1);
    2794:	4505                	li	a0,1
    2796:	00003097          	auipc	ra,0x3
    279a:	be2080e7          	jalr	-1054(ra) # 5378 <exit>

000000000000279e <sbrkbugs>:
{
    279e:	1141                	addi	sp,sp,-16
    27a0:	e406                	sd	ra,8(sp)
    27a2:	e022                	sd	s0,0(sp)
    27a4:	0800                	addi	s0,sp,16
  int pid = fork();
    27a6:	00003097          	auipc	ra,0x3
    27aa:	bca080e7          	jalr	-1078(ra) # 5370 <fork>
  if(pid < 0){
    27ae:	02054263          	bltz	a0,27d2 <sbrkbugs+0x34>
  if(pid == 0){
    27b2:	ed0d                	bnez	a0,27ec <sbrkbugs+0x4e>
    int sz = (uint64) sbrk(0);
    27b4:	00003097          	auipc	ra,0x3
    27b8:	c4c080e7          	jalr	-948(ra) # 5400 <sbrk>
    sbrk(-sz);
    27bc:	40a0053b          	negw	a0,a0
    27c0:	00003097          	auipc	ra,0x3
    27c4:	c40080e7          	jalr	-960(ra) # 5400 <sbrk>
    exit(0);
    27c8:	4501                	li	a0,0
    27ca:	00003097          	auipc	ra,0x3
    27ce:	bae080e7          	jalr	-1106(ra) # 5378 <exit>
    printf("fork failed\n");
    27d2:	00004517          	auipc	a0,0x4
    27d6:	02650513          	addi	a0,a0,38 # 67f8 <malloc+0x104a>
    27da:	00003097          	auipc	ra,0x3
    27de:	f16080e7          	jalr	-234(ra) # 56f0 <printf>
    exit(1);
    27e2:	4505                	li	a0,1
    27e4:	00003097          	auipc	ra,0x3
    27e8:	b94080e7          	jalr	-1132(ra) # 5378 <exit>
  wait(0);
    27ec:	4501                	li	a0,0
    27ee:	00003097          	auipc	ra,0x3
    27f2:	b92080e7          	jalr	-1134(ra) # 5380 <wait>
  pid = fork();
    27f6:	00003097          	auipc	ra,0x3
    27fa:	b7a080e7          	jalr	-1158(ra) # 5370 <fork>
  if(pid < 0){
    27fe:	02054563          	bltz	a0,2828 <sbrkbugs+0x8a>
  if(pid == 0){
    2802:	e121                	bnez	a0,2842 <sbrkbugs+0xa4>
    int sz = (uint64) sbrk(0);
    2804:	00003097          	auipc	ra,0x3
    2808:	bfc080e7          	jalr	-1028(ra) # 5400 <sbrk>
    sbrk(-(sz - 3500));
    280c:	6785                	lui	a5,0x1
    280e:	dac7879b          	addiw	a5,a5,-596
    2812:	40a7853b          	subw	a0,a5,a0
    2816:	00003097          	auipc	ra,0x3
    281a:	bea080e7          	jalr	-1046(ra) # 5400 <sbrk>
    exit(0);
    281e:	4501                	li	a0,0
    2820:	00003097          	auipc	ra,0x3
    2824:	b58080e7          	jalr	-1192(ra) # 5378 <exit>
    printf("fork failed\n");
    2828:	00004517          	auipc	a0,0x4
    282c:	fd050513          	addi	a0,a0,-48 # 67f8 <malloc+0x104a>
    2830:	00003097          	auipc	ra,0x3
    2834:	ec0080e7          	jalr	-320(ra) # 56f0 <printf>
    exit(1);
    2838:	4505                	li	a0,1
    283a:	00003097          	auipc	ra,0x3
    283e:	b3e080e7          	jalr	-1218(ra) # 5378 <exit>
  wait(0);
    2842:	4501                	li	a0,0
    2844:	00003097          	auipc	ra,0x3
    2848:	b3c080e7          	jalr	-1220(ra) # 5380 <wait>
  pid = fork();
    284c:	00003097          	auipc	ra,0x3
    2850:	b24080e7          	jalr	-1244(ra) # 5370 <fork>
  if(pid < 0){
    2854:	02054a63          	bltz	a0,2888 <sbrkbugs+0xea>
  if(pid == 0){
    2858:	e529                	bnez	a0,28a2 <sbrkbugs+0x104>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    285a:	00003097          	auipc	ra,0x3
    285e:	ba6080e7          	jalr	-1114(ra) # 5400 <sbrk>
    2862:	67ad                	lui	a5,0xb
    2864:	8007879b          	addiw	a5,a5,-2048
    2868:	40a7853b          	subw	a0,a5,a0
    286c:	00003097          	auipc	ra,0x3
    2870:	b94080e7          	jalr	-1132(ra) # 5400 <sbrk>
    sbrk(-10);
    2874:	5559                	li	a0,-10
    2876:	00003097          	auipc	ra,0x3
    287a:	b8a080e7          	jalr	-1142(ra) # 5400 <sbrk>
    exit(0);
    287e:	4501                	li	a0,0
    2880:	00003097          	auipc	ra,0x3
    2884:	af8080e7          	jalr	-1288(ra) # 5378 <exit>
    printf("fork failed\n");
    2888:	00004517          	auipc	a0,0x4
    288c:	f7050513          	addi	a0,a0,-144 # 67f8 <malloc+0x104a>
    2890:	00003097          	auipc	ra,0x3
    2894:	e60080e7          	jalr	-416(ra) # 56f0 <printf>
    exit(1);
    2898:	4505                	li	a0,1
    289a:	00003097          	auipc	ra,0x3
    289e:	ade080e7          	jalr	-1314(ra) # 5378 <exit>
  wait(0);
    28a2:	4501                	li	a0,0
    28a4:	00003097          	auipc	ra,0x3
    28a8:	adc080e7          	jalr	-1316(ra) # 5380 <wait>
  exit(0);
    28ac:	4501                	li	a0,0
    28ae:	00003097          	auipc	ra,0x3
    28b2:	aca080e7          	jalr	-1334(ra) # 5378 <exit>

00000000000028b6 <execout>:
// test the exec() code that cleans up if it runs out
// of memory. it's really a test that such a condition
// doesn't cause a panic.
void
execout(char *s)
{
    28b6:	715d                	addi	sp,sp,-80
    28b8:	e486                	sd	ra,72(sp)
    28ba:	e0a2                	sd	s0,64(sp)
    28bc:	fc26                	sd	s1,56(sp)
    28be:	f84a                	sd	s2,48(sp)
    28c0:	f44e                	sd	s3,40(sp)
    28c2:	f052                	sd	s4,32(sp)
    28c4:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    28c6:	4901                	li	s2,0
    28c8:	49bd                	li	s3,15
    int pid = fork();
    28ca:	00003097          	auipc	ra,0x3
    28ce:	aa6080e7          	jalr	-1370(ra) # 5370 <fork>
    28d2:	84aa                	mv	s1,a0
    if(pid < 0){
    28d4:	02054063          	bltz	a0,28f4 <execout+0x3e>
      printf("fork failed\n");
      exit(1);
    } else if(pid == 0){
    28d8:	c91d                	beqz	a0,290e <execout+0x58>
      close(1);
      char *args[] = { "echo", "x", 0 };
      exec("echo", args);
      exit(0);
    } else {
      wait((int*)0);
    28da:	4501                	li	a0,0
    28dc:	00003097          	auipc	ra,0x3
    28e0:	aa4080e7          	jalr	-1372(ra) # 5380 <wait>
  for(int avail = 0; avail < 15; avail++){
    28e4:	2905                	addiw	s2,s2,1
    28e6:	ff3912e3          	bne	s2,s3,28ca <execout+0x14>
    }
  }

  exit(0);
    28ea:	4501                	li	a0,0
    28ec:	00003097          	auipc	ra,0x3
    28f0:	a8c080e7          	jalr	-1396(ra) # 5378 <exit>
      printf("fork failed\n");
    28f4:	00004517          	auipc	a0,0x4
    28f8:	f0450513          	addi	a0,a0,-252 # 67f8 <malloc+0x104a>
    28fc:	00003097          	auipc	ra,0x3
    2900:	df4080e7          	jalr	-524(ra) # 56f0 <printf>
      exit(1);
    2904:	4505                	li	a0,1
    2906:	00003097          	auipc	ra,0x3
    290a:	a72080e7          	jalr	-1422(ra) # 5378 <exit>
        if(a == 0xffffffffffffffffLL)
    290e:	59fd                	li	s3,-1
        *(char*)(a + 4096 - 1) = 1;
    2910:	4a05                	li	s4,1
        uint64 a = (uint64) sbrk(4096);
    2912:	6505                	lui	a0,0x1
    2914:	00003097          	auipc	ra,0x3
    2918:	aec080e7          	jalr	-1300(ra) # 5400 <sbrk>
        if(a == 0xffffffffffffffffLL)
    291c:	01350763          	beq	a0,s3,292a <execout+0x74>
        *(char*)(a + 4096 - 1) = 1;
    2920:	6785                	lui	a5,0x1
    2922:	953e                	add	a0,a0,a5
    2924:	ff450fa3          	sb	s4,-1(a0) # fff <bigdir+0x95>
      while(1){
    2928:	b7ed                	j	2912 <execout+0x5c>
      for(int i = 0; i < avail; i++)
    292a:	01205a63          	blez	s2,293e <execout+0x88>
        sbrk(-4096);
    292e:	757d                	lui	a0,0xfffff
    2930:	00003097          	auipc	ra,0x3
    2934:	ad0080e7          	jalr	-1328(ra) # 5400 <sbrk>
      for(int i = 0; i < avail; i++)
    2938:	2485                	addiw	s1,s1,1
    293a:	ff249ae3          	bne	s1,s2,292e <execout+0x78>
      close(1);
    293e:	4505                	li	a0,1
    2940:	00003097          	auipc	ra,0x3
    2944:	a60080e7          	jalr	-1440(ra) # 53a0 <close>
      char *args[] = { "echo", "x", 0 };
    2948:	00003517          	auipc	a0,0x3
    294c:	28850513          	addi	a0,a0,648 # 5bd0 <malloc+0x422>
    2950:	faa43c23          	sd	a0,-72(s0)
    2954:	00003797          	auipc	a5,0x3
    2958:	2ec78793          	addi	a5,a5,748 # 5c40 <malloc+0x492>
    295c:	fcf43023          	sd	a5,-64(s0)
    2960:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    2964:	fb840593          	addi	a1,s0,-72
    2968:	00003097          	auipc	ra,0x3
    296c:	a48080e7          	jalr	-1464(ra) # 53b0 <exec>
      exit(0);
    2970:	4501                	li	a0,0
    2972:	00003097          	auipc	ra,0x3
    2976:	a06080e7          	jalr	-1530(ra) # 5378 <exit>

000000000000297a <fourteen>:
{
    297a:	1101                	addi	sp,sp,-32
    297c:	ec06                	sd	ra,24(sp)
    297e:	e822                	sd	s0,16(sp)
    2980:	e426                	sd	s1,8(sp)
    2982:	1000                	addi	s0,sp,32
    2984:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    2986:	00004517          	auipc	a0,0x4
    298a:	2ba50513          	addi	a0,a0,698 # 6c40 <malloc+0x1492>
    298e:	00003097          	auipc	ra,0x3
    2992:	a52080e7          	jalr	-1454(ra) # 53e0 <mkdir>
    2996:	e165                	bnez	a0,2a76 <fourteen+0xfc>
  if(mkdir("12345678901234/123456789012345") != 0){
    2998:	00004517          	auipc	a0,0x4
    299c:	10050513          	addi	a0,a0,256 # 6a98 <malloc+0x12ea>
    29a0:	00003097          	auipc	ra,0x3
    29a4:	a40080e7          	jalr	-1472(ra) # 53e0 <mkdir>
    29a8:	e56d                	bnez	a0,2a92 <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    29aa:	20000593          	li	a1,512
    29ae:	00004517          	auipc	a0,0x4
    29b2:	14250513          	addi	a0,a0,322 # 6af0 <malloc+0x1342>
    29b6:	00003097          	auipc	ra,0x3
    29ba:	a02080e7          	jalr	-1534(ra) # 53b8 <open>
  if(fd < 0){
    29be:	0e054863          	bltz	a0,2aae <fourteen+0x134>
  close(fd);
    29c2:	00003097          	auipc	ra,0x3
    29c6:	9de080e7          	jalr	-1570(ra) # 53a0 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    29ca:	4581                	li	a1,0
    29cc:	00004517          	auipc	a0,0x4
    29d0:	19c50513          	addi	a0,a0,412 # 6b68 <malloc+0x13ba>
    29d4:	00003097          	auipc	ra,0x3
    29d8:	9e4080e7          	jalr	-1564(ra) # 53b8 <open>
  if(fd < 0){
    29dc:	0e054763          	bltz	a0,2aca <fourteen+0x150>
  close(fd);
    29e0:	00003097          	auipc	ra,0x3
    29e4:	9c0080e7          	jalr	-1600(ra) # 53a0 <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    29e8:	00004517          	auipc	a0,0x4
    29ec:	1f050513          	addi	a0,a0,496 # 6bd8 <malloc+0x142a>
    29f0:	00003097          	auipc	ra,0x3
    29f4:	9f0080e7          	jalr	-1552(ra) # 53e0 <mkdir>
    29f8:	c57d                	beqz	a0,2ae6 <fourteen+0x16c>
  if(mkdir("123456789012345/12345678901234") == 0){
    29fa:	00004517          	auipc	a0,0x4
    29fe:	23650513          	addi	a0,a0,566 # 6c30 <malloc+0x1482>
    2a02:	00003097          	auipc	ra,0x3
    2a06:	9de080e7          	jalr	-1570(ra) # 53e0 <mkdir>
    2a0a:	cd65                	beqz	a0,2b02 <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    2a0c:	00004517          	auipc	a0,0x4
    2a10:	22450513          	addi	a0,a0,548 # 6c30 <malloc+0x1482>
    2a14:	00003097          	auipc	ra,0x3
    2a18:	9b4080e7          	jalr	-1612(ra) # 53c8 <unlink>
  unlink("12345678901234/12345678901234");
    2a1c:	00004517          	auipc	a0,0x4
    2a20:	1bc50513          	addi	a0,a0,444 # 6bd8 <malloc+0x142a>
    2a24:	00003097          	auipc	ra,0x3
    2a28:	9a4080e7          	jalr	-1628(ra) # 53c8 <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    2a2c:	00004517          	auipc	a0,0x4
    2a30:	13c50513          	addi	a0,a0,316 # 6b68 <malloc+0x13ba>
    2a34:	00003097          	auipc	ra,0x3
    2a38:	994080e7          	jalr	-1644(ra) # 53c8 <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    2a3c:	00004517          	auipc	a0,0x4
    2a40:	0b450513          	addi	a0,a0,180 # 6af0 <malloc+0x1342>
    2a44:	00003097          	auipc	ra,0x3
    2a48:	984080e7          	jalr	-1660(ra) # 53c8 <unlink>
  unlink("12345678901234/123456789012345");
    2a4c:	00004517          	auipc	a0,0x4
    2a50:	04c50513          	addi	a0,a0,76 # 6a98 <malloc+0x12ea>
    2a54:	00003097          	auipc	ra,0x3
    2a58:	974080e7          	jalr	-1676(ra) # 53c8 <unlink>
  unlink("12345678901234");
    2a5c:	00004517          	auipc	a0,0x4
    2a60:	1e450513          	addi	a0,a0,484 # 6c40 <malloc+0x1492>
    2a64:	00003097          	auipc	ra,0x3
    2a68:	964080e7          	jalr	-1692(ra) # 53c8 <unlink>
}
    2a6c:	60e2                	ld	ra,24(sp)
    2a6e:	6442                	ld	s0,16(sp)
    2a70:	64a2                	ld	s1,8(sp)
    2a72:	6105                	addi	sp,sp,32
    2a74:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    2a76:	85a6                	mv	a1,s1
    2a78:	00004517          	auipc	a0,0x4
    2a7c:	ff850513          	addi	a0,a0,-8 # 6a70 <malloc+0x12c2>
    2a80:	00003097          	auipc	ra,0x3
    2a84:	c70080e7          	jalr	-912(ra) # 56f0 <printf>
    exit(1);
    2a88:	4505                	li	a0,1
    2a8a:	00003097          	auipc	ra,0x3
    2a8e:	8ee080e7          	jalr	-1810(ra) # 5378 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    2a92:	85a6                	mv	a1,s1
    2a94:	00004517          	auipc	a0,0x4
    2a98:	02450513          	addi	a0,a0,36 # 6ab8 <malloc+0x130a>
    2a9c:	00003097          	auipc	ra,0x3
    2aa0:	c54080e7          	jalr	-940(ra) # 56f0 <printf>
    exit(1);
    2aa4:	4505                	li	a0,1
    2aa6:	00003097          	auipc	ra,0x3
    2aaa:	8d2080e7          	jalr	-1838(ra) # 5378 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    2aae:	85a6                	mv	a1,s1
    2ab0:	00004517          	auipc	a0,0x4
    2ab4:	07050513          	addi	a0,a0,112 # 6b20 <malloc+0x1372>
    2ab8:	00003097          	auipc	ra,0x3
    2abc:	c38080e7          	jalr	-968(ra) # 56f0 <printf>
    exit(1);
    2ac0:	4505                	li	a0,1
    2ac2:	00003097          	auipc	ra,0x3
    2ac6:	8b6080e7          	jalr	-1866(ra) # 5378 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    2aca:	85a6                	mv	a1,s1
    2acc:	00004517          	auipc	a0,0x4
    2ad0:	0cc50513          	addi	a0,a0,204 # 6b98 <malloc+0x13ea>
    2ad4:	00003097          	auipc	ra,0x3
    2ad8:	c1c080e7          	jalr	-996(ra) # 56f0 <printf>
    exit(1);
    2adc:	4505                	li	a0,1
    2ade:	00003097          	auipc	ra,0x3
    2ae2:	89a080e7          	jalr	-1894(ra) # 5378 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    2ae6:	85a6                	mv	a1,s1
    2ae8:	00004517          	auipc	a0,0x4
    2aec:	11050513          	addi	a0,a0,272 # 6bf8 <malloc+0x144a>
    2af0:	00003097          	auipc	ra,0x3
    2af4:	c00080e7          	jalr	-1024(ra) # 56f0 <printf>
    exit(1);
    2af8:	4505                	li	a0,1
    2afa:	00003097          	auipc	ra,0x3
    2afe:	87e080e7          	jalr	-1922(ra) # 5378 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    2b02:	85a6                	mv	a1,s1
    2b04:	00004517          	auipc	a0,0x4
    2b08:	14c50513          	addi	a0,a0,332 # 6c50 <malloc+0x14a2>
    2b0c:	00003097          	auipc	ra,0x3
    2b10:	be4080e7          	jalr	-1052(ra) # 56f0 <printf>
    exit(1);
    2b14:	4505                	li	a0,1
    2b16:	00003097          	auipc	ra,0x3
    2b1a:	862080e7          	jalr	-1950(ra) # 5378 <exit>

0000000000002b1e <iputtest>:
{
    2b1e:	1101                	addi	sp,sp,-32
    2b20:	ec06                	sd	ra,24(sp)
    2b22:	e822                	sd	s0,16(sp)
    2b24:	e426                	sd	s1,8(sp)
    2b26:	1000                	addi	s0,sp,32
    2b28:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    2b2a:	00004517          	auipc	a0,0x4
    2b2e:	15e50513          	addi	a0,a0,350 # 6c88 <malloc+0x14da>
    2b32:	00003097          	auipc	ra,0x3
    2b36:	8ae080e7          	jalr	-1874(ra) # 53e0 <mkdir>
    2b3a:	04054563          	bltz	a0,2b84 <iputtest+0x66>
  if(chdir("iputdir") < 0){
    2b3e:	00004517          	auipc	a0,0x4
    2b42:	14a50513          	addi	a0,a0,330 # 6c88 <malloc+0x14da>
    2b46:	00003097          	auipc	ra,0x3
    2b4a:	8a2080e7          	jalr	-1886(ra) # 53e8 <chdir>
    2b4e:	04054963          	bltz	a0,2ba0 <iputtest+0x82>
  if(unlink("../iputdir") < 0){
    2b52:	00004517          	auipc	a0,0x4
    2b56:	17650513          	addi	a0,a0,374 # 6cc8 <malloc+0x151a>
    2b5a:	00003097          	auipc	ra,0x3
    2b5e:	86e080e7          	jalr	-1938(ra) # 53c8 <unlink>
    2b62:	04054d63          	bltz	a0,2bbc <iputtest+0x9e>
  if(chdir("/") < 0){
    2b66:	00004517          	auipc	a0,0x4
    2b6a:	19250513          	addi	a0,a0,402 # 6cf8 <malloc+0x154a>
    2b6e:	00003097          	auipc	ra,0x3
    2b72:	87a080e7          	jalr	-1926(ra) # 53e8 <chdir>
    2b76:	06054163          	bltz	a0,2bd8 <iputtest+0xba>
}
    2b7a:	60e2                	ld	ra,24(sp)
    2b7c:	6442                	ld	s0,16(sp)
    2b7e:	64a2                	ld	s1,8(sp)
    2b80:	6105                	addi	sp,sp,32
    2b82:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2b84:	85a6                	mv	a1,s1
    2b86:	00004517          	auipc	a0,0x4
    2b8a:	10a50513          	addi	a0,a0,266 # 6c90 <malloc+0x14e2>
    2b8e:	00003097          	auipc	ra,0x3
    2b92:	b62080e7          	jalr	-1182(ra) # 56f0 <printf>
    exit(1);
    2b96:	4505                	li	a0,1
    2b98:	00002097          	auipc	ra,0x2
    2b9c:	7e0080e7          	jalr	2016(ra) # 5378 <exit>
    printf("%s: chdir iputdir failed\n", s);
    2ba0:	85a6                	mv	a1,s1
    2ba2:	00004517          	auipc	a0,0x4
    2ba6:	10650513          	addi	a0,a0,262 # 6ca8 <malloc+0x14fa>
    2baa:	00003097          	auipc	ra,0x3
    2bae:	b46080e7          	jalr	-1210(ra) # 56f0 <printf>
    exit(1);
    2bb2:	4505                	li	a0,1
    2bb4:	00002097          	auipc	ra,0x2
    2bb8:	7c4080e7          	jalr	1988(ra) # 5378 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    2bbc:	85a6                	mv	a1,s1
    2bbe:	00004517          	auipc	a0,0x4
    2bc2:	11a50513          	addi	a0,a0,282 # 6cd8 <malloc+0x152a>
    2bc6:	00003097          	auipc	ra,0x3
    2bca:	b2a080e7          	jalr	-1238(ra) # 56f0 <printf>
    exit(1);
    2bce:	4505                	li	a0,1
    2bd0:	00002097          	auipc	ra,0x2
    2bd4:	7a8080e7          	jalr	1960(ra) # 5378 <exit>
    printf("%s: chdir / failed\n", s);
    2bd8:	85a6                	mv	a1,s1
    2bda:	00004517          	auipc	a0,0x4
    2bde:	12650513          	addi	a0,a0,294 # 6d00 <malloc+0x1552>
    2be2:	00003097          	auipc	ra,0x3
    2be6:	b0e080e7          	jalr	-1266(ra) # 56f0 <printf>
    exit(1);
    2bea:	4505                	li	a0,1
    2bec:	00002097          	auipc	ra,0x2
    2bf0:	78c080e7          	jalr	1932(ra) # 5378 <exit>

0000000000002bf4 <exitiputtest>:
{
    2bf4:	7179                	addi	sp,sp,-48
    2bf6:	f406                	sd	ra,40(sp)
    2bf8:	f022                	sd	s0,32(sp)
    2bfa:	ec26                	sd	s1,24(sp)
    2bfc:	1800                	addi	s0,sp,48
    2bfe:	84aa                	mv	s1,a0
  pid = fork();
    2c00:	00002097          	auipc	ra,0x2
    2c04:	770080e7          	jalr	1904(ra) # 5370 <fork>
  if(pid < 0){
    2c08:	04054663          	bltz	a0,2c54 <exitiputtest+0x60>
  if(pid == 0){
    2c0c:	ed45                	bnez	a0,2cc4 <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
    2c0e:	00004517          	auipc	a0,0x4
    2c12:	07a50513          	addi	a0,a0,122 # 6c88 <malloc+0x14da>
    2c16:	00002097          	auipc	ra,0x2
    2c1a:	7ca080e7          	jalr	1994(ra) # 53e0 <mkdir>
    2c1e:	04054963          	bltz	a0,2c70 <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
    2c22:	00004517          	auipc	a0,0x4
    2c26:	06650513          	addi	a0,a0,102 # 6c88 <malloc+0x14da>
    2c2a:	00002097          	auipc	ra,0x2
    2c2e:	7be080e7          	jalr	1982(ra) # 53e8 <chdir>
    2c32:	04054d63          	bltz	a0,2c8c <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
    2c36:	00004517          	auipc	a0,0x4
    2c3a:	09250513          	addi	a0,a0,146 # 6cc8 <malloc+0x151a>
    2c3e:	00002097          	auipc	ra,0x2
    2c42:	78a080e7          	jalr	1930(ra) # 53c8 <unlink>
    2c46:	06054163          	bltz	a0,2ca8 <exitiputtest+0xb4>
    exit(0);
    2c4a:	4501                	li	a0,0
    2c4c:	00002097          	auipc	ra,0x2
    2c50:	72c080e7          	jalr	1836(ra) # 5378 <exit>
    printf("%s: fork failed\n", s);
    2c54:	85a6                	mv	a1,s1
    2c56:	00003517          	auipc	a0,0x3
    2c5a:	7b250513          	addi	a0,a0,1970 # 6408 <malloc+0xc5a>
    2c5e:	00003097          	auipc	ra,0x3
    2c62:	a92080e7          	jalr	-1390(ra) # 56f0 <printf>
    exit(1);
    2c66:	4505                	li	a0,1
    2c68:	00002097          	auipc	ra,0x2
    2c6c:	710080e7          	jalr	1808(ra) # 5378 <exit>
      printf("%s: mkdir failed\n", s);
    2c70:	85a6                	mv	a1,s1
    2c72:	00004517          	auipc	a0,0x4
    2c76:	01e50513          	addi	a0,a0,30 # 6c90 <malloc+0x14e2>
    2c7a:	00003097          	auipc	ra,0x3
    2c7e:	a76080e7          	jalr	-1418(ra) # 56f0 <printf>
      exit(1);
    2c82:	4505                	li	a0,1
    2c84:	00002097          	auipc	ra,0x2
    2c88:	6f4080e7          	jalr	1780(ra) # 5378 <exit>
      printf("%s: child chdir failed\n", s);
    2c8c:	85a6                	mv	a1,s1
    2c8e:	00004517          	auipc	a0,0x4
    2c92:	08a50513          	addi	a0,a0,138 # 6d18 <malloc+0x156a>
    2c96:	00003097          	auipc	ra,0x3
    2c9a:	a5a080e7          	jalr	-1446(ra) # 56f0 <printf>
      exit(1);
    2c9e:	4505                	li	a0,1
    2ca0:	00002097          	auipc	ra,0x2
    2ca4:	6d8080e7          	jalr	1752(ra) # 5378 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    2ca8:	85a6                	mv	a1,s1
    2caa:	00004517          	auipc	a0,0x4
    2cae:	02e50513          	addi	a0,a0,46 # 6cd8 <malloc+0x152a>
    2cb2:	00003097          	auipc	ra,0x3
    2cb6:	a3e080e7          	jalr	-1474(ra) # 56f0 <printf>
      exit(1);
    2cba:	4505                	li	a0,1
    2cbc:	00002097          	auipc	ra,0x2
    2cc0:	6bc080e7          	jalr	1724(ra) # 5378 <exit>
  wait(&xstatus);
    2cc4:	fdc40513          	addi	a0,s0,-36
    2cc8:	00002097          	auipc	ra,0x2
    2ccc:	6b8080e7          	jalr	1720(ra) # 5380 <wait>
  exit(xstatus);
    2cd0:	fdc42503          	lw	a0,-36(s0)
    2cd4:	00002097          	auipc	ra,0x2
    2cd8:	6a4080e7          	jalr	1700(ra) # 5378 <exit>

0000000000002cdc <subdir>:
{
    2cdc:	1101                	addi	sp,sp,-32
    2cde:	ec06                	sd	ra,24(sp)
    2ce0:	e822                	sd	s0,16(sp)
    2ce2:	e426                	sd	s1,8(sp)
    2ce4:	e04a                	sd	s2,0(sp)
    2ce6:	1000                	addi	s0,sp,32
    2ce8:	892a                	mv	s2,a0
  unlink("ff");
    2cea:	00004517          	auipc	a0,0x4
    2cee:	17650513          	addi	a0,a0,374 # 6e60 <malloc+0x16b2>
    2cf2:	00002097          	auipc	ra,0x2
    2cf6:	6d6080e7          	jalr	1750(ra) # 53c8 <unlink>
  if(mkdir("dd") != 0){
    2cfa:	00004517          	auipc	a0,0x4
    2cfe:	03650513          	addi	a0,a0,54 # 6d30 <malloc+0x1582>
    2d02:	00002097          	auipc	ra,0x2
    2d06:	6de080e7          	jalr	1758(ra) # 53e0 <mkdir>
    2d0a:	38051663          	bnez	a0,3096 <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    2d0e:	20200593          	li	a1,514
    2d12:	00004517          	auipc	a0,0x4
    2d16:	03e50513          	addi	a0,a0,62 # 6d50 <malloc+0x15a2>
    2d1a:	00002097          	auipc	ra,0x2
    2d1e:	69e080e7          	jalr	1694(ra) # 53b8 <open>
    2d22:	84aa                	mv	s1,a0
  if(fd < 0){
    2d24:	38054763          	bltz	a0,30b2 <subdir+0x3d6>
  write(fd, "ff", 2);
    2d28:	4609                	li	a2,2
    2d2a:	00004597          	auipc	a1,0x4
    2d2e:	13658593          	addi	a1,a1,310 # 6e60 <malloc+0x16b2>
    2d32:	00002097          	auipc	ra,0x2
    2d36:	666080e7          	jalr	1638(ra) # 5398 <write>
  close(fd);
    2d3a:	8526                	mv	a0,s1
    2d3c:	00002097          	auipc	ra,0x2
    2d40:	664080e7          	jalr	1636(ra) # 53a0 <close>
  if(unlink("dd") >= 0){
    2d44:	00004517          	auipc	a0,0x4
    2d48:	fec50513          	addi	a0,a0,-20 # 6d30 <malloc+0x1582>
    2d4c:	00002097          	auipc	ra,0x2
    2d50:	67c080e7          	jalr	1660(ra) # 53c8 <unlink>
    2d54:	36055d63          	bgez	a0,30ce <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    2d58:	00004517          	auipc	a0,0x4
    2d5c:	05050513          	addi	a0,a0,80 # 6da8 <malloc+0x15fa>
    2d60:	00002097          	auipc	ra,0x2
    2d64:	680080e7          	jalr	1664(ra) # 53e0 <mkdir>
    2d68:	38051163          	bnez	a0,30ea <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    2d6c:	20200593          	li	a1,514
    2d70:	00004517          	auipc	a0,0x4
    2d74:	06050513          	addi	a0,a0,96 # 6dd0 <malloc+0x1622>
    2d78:	00002097          	auipc	ra,0x2
    2d7c:	640080e7          	jalr	1600(ra) # 53b8 <open>
    2d80:	84aa                	mv	s1,a0
  if(fd < 0){
    2d82:	38054263          	bltz	a0,3106 <subdir+0x42a>
  write(fd, "FF", 2);
    2d86:	4609                	li	a2,2
    2d88:	00004597          	auipc	a1,0x4
    2d8c:	07858593          	addi	a1,a1,120 # 6e00 <malloc+0x1652>
    2d90:	00002097          	auipc	ra,0x2
    2d94:	608080e7          	jalr	1544(ra) # 5398 <write>
  close(fd);
    2d98:	8526                	mv	a0,s1
    2d9a:	00002097          	auipc	ra,0x2
    2d9e:	606080e7          	jalr	1542(ra) # 53a0 <close>
  fd = open("dd/dd/../ff", 0);
    2da2:	4581                	li	a1,0
    2da4:	00004517          	auipc	a0,0x4
    2da8:	06450513          	addi	a0,a0,100 # 6e08 <malloc+0x165a>
    2dac:	00002097          	auipc	ra,0x2
    2db0:	60c080e7          	jalr	1548(ra) # 53b8 <open>
    2db4:	84aa                	mv	s1,a0
  if(fd < 0){
    2db6:	36054663          	bltz	a0,3122 <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    2dba:	660d                	lui	a2,0x3
    2dbc:	00009597          	auipc	a1,0x9
    2dc0:	97c58593          	addi	a1,a1,-1668 # b738 <buf>
    2dc4:	00002097          	auipc	ra,0x2
    2dc8:	5cc080e7          	jalr	1484(ra) # 5390 <read>
  if(cc != 2 || buf[0] != 'f'){
    2dcc:	4789                	li	a5,2
    2dce:	36f51863          	bne	a0,a5,313e <subdir+0x462>
    2dd2:	00009717          	auipc	a4,0x9
    2dd6:	96674703          	lbu	a4,-1690(a4) # b738 <buf>
    2dda:	06600793          	li	a5,102
    2dde:	36f71063          	bne	a4,a5,313e <subdir+0x462>
  close(fd);
    2de2:	8526                	mv	a0,s1
    2de4:	00002097          	auipc	ra,0x2
    2de8:	5bc080e7          	jalr	1468(ra) # 53a0 <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    2dec:	00004597          	auipc	a1,0x4
    2df0:	06c58593          	addi	a1,a1,108 # 6e58 <malloc+0x16aa>
    2df4:	00004517          	auipc	a0,0x4
    2df8:	fdc50513          	addi	a0,a0,-36 # 6dd0 <malloc+0x1622>
    2dfc:	00002097          	auipc	ra,0x2
    2e00:	5dc080e7          	jalr	1500(ra) # 53d8 <link>
    2e04:	34051b63          	bnez	a0,315a <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    2e08:	00004517          	auipc	a0,0x4
    2e0c:	fc850513          	addi	a0,a0,-56 # 6dd0 <malloc+0x1622>
    2e10:	00002097          	auipc	ra,0x2
    2e14:	5b8080e7          	jalr	1464(ra) # 53c8 <unlink>
    2e18:	34051f63          	bnez	a0,3176 <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2e1c:	4581                	li	a1,0
    2e1e:	00004517          	auipc	a0,0x4
    2e22:	fb250513          	addi	a0,a0,-78 # 6dd0 <malloc+0x1622>
    2e26:	00002097          	auipc	ra,0x2
    2e2a:	592080e7          	jalr	1426(ra) # 53b8 <open>
    2e2e:	36055263          	bgez	a0,3192 <subdir+0x4b6>
  if(chdir("dd") != 0){
    2e32:	00004517          	auipc	a0,0x4
    2e36:	efe50513          	addi	a0,a0,-258 # 6d30 <malloc+0x1582>
    2e3a:	00002097          	auipc	ra,0x2
    2e3e:	5ae080e7          	jalr	1454(ra) # 53e8 <chdir>
    2e42:	36051663          	bnez	a0,31ae <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    2e46:	00004517          	auipc	a0,0x4
    2e4a:	0aa50513          	addi	a0,a0,170 # 6ef0 <malloc+0x1742>
    2e4e:	00002097          	auipc	ra,0x2
    2e52:	59a080e7          	jalr	1434(ra) # 53e8 <chdir>
    2e56:	36051a63          	bnez	a0,31ca <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    2e5a:	00004517          	auipc	a0,0x4
    2e5e:	0c650513          	addi	a0,a0,198 # 6f20 <malloc+0x1772>
    2e62:	00002097          	auipc	ra,0x2
    2e66:	586080e7          	jalr	1414(ra) # 53e8 <chdir>
    2e6a:	36051e63          	bnez	a0,31e6 <subdir+0x50a>
  if(chdir("./..") != 0){
    2e6e:	00004517          	auipc	a0,0x4
    2e72:	0e250513          	addi	a0,a0,226 # 6f50 <malloc+0x17a2>
    2e76:	00002097          	auipc	ra,0x2
    2e7a:	572080e7          	jalr	1394(ra) # 53e8 <chdir>
    2e7e:	38051263          	bnez	a0,3202 <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    2e82:	4581                	li	a1,0
    2e84:	00004517          	auipc	a0,0x4
    2e88:	fd450513          	addi	a0,a0,-44 # 6e58 <malloc+0x16aa>
    2e8c:	00002097          	auipc	ra,0x2
    2e90:	52c080e7          	jalr	1324(ra) # 53b8 <open>
    2e94:	84aa                	mv	s1,a0
  if(fd < 0){
    2e96:	38054463          	bltz	a0,321e <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    2e9a:	660d                	lui	a2,0x3
    2e9c:	00009597          	auipc	a1,0x9
    2ea0:	89c58593          	addi	a1,a1,-1892 # b738 <buf>
    2ea4:	00002097          	auipc	ra,0x2
    2ea8:	4ec080e7          	jalr	1260(ra) # 5390 <read>
    2eac:	4789                	li	a5,2
    2eae:	38f51663          	bne	a0,a5,323a <subdir+0x55e>
  close(fd);
    2eb2:	8526                	mv	a0,s1
    2eb4:	00002097          	auipc	ra,0x2
    2eb8:	4ec080e7          	jalr	1260(ra) # 53a0 <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2ebc:	4581                	li	a1,0
    2ebe:	00004517          	auipc	a0,0x4
    2ec2:	f1250513          	addi	a0,a0,-238 # 6dd0 <malloc+0x1622>
    2ec6:	00002097          	auipc	ra,0x2
    2eca:	4f2080e7          	jalr	1266(ra) # 53b8 <open>
    2ece:	38055463          	bgez	a0,3256 <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    2ed2:	20200593          	li	a1,514
    2ed6:	00004517          	auipc	a0,0x4
    2eda:	10a50513          	addi	a0,a0,266 # 6fe0 <malloc+0x1832>
    2ede:	00002097          	auipc	ra,0x2
    2ee2:	4da080e7          	jalr	1242(ra) # 53b8 <open>
    2ee6:	38055663          	bgez	a0,3272 <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    2eea:	20200593          	li	a1,514
    2eee:	00004517          	auipc	a0,0x4
    2ef2:	12250513          	addi	a0,a0,290 # 7010 <malloc+0x1862>
    2ef6:	00002097          	auipc	ra,0x2
    2efa:	4c2080e7          	jalr	1218(ra) # 53b8 <open>
    2efe:	38055863          	bgez	a0,328e <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    2f02:	20000593          	li	a1,512
    2f06:	00004517          	auipc	a0,0x4
    2f0a:	e2a50513          	addi	a0,a0,-470 # 6d30 <malloc+0x1582>
    2f0e:	00002097          	auipc	ra,0x2
    2f12:	4aa080e7          	jalr	1194(ra) # 53b8 <open>
    2f16:	38055a63          	bgez	a0,32aa <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    2f1a:	4589                	li	a1,2
    2f1c:	00004517          	auipc	a0,0x4
    2f20:	e1450513          	addi	a0,a0,-492 # 6d30 <malloc+0x1582>
    2f24:	00002097          	auipc	ra,0x2
    2f28:	494080e7          	jalr	1172(ra) # 53b8 <open>
    2f2c:	38055d63          	bgez	a0,32c6 <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    2f30:	4585                	li	a1,1
    2f32:	00004517          	auipc	a0,0x4
    2f36:	dfe50513          	addi	a0,a0,-514 # 6d30 <malloc+0x1582>
    2f3a:	00002097          	auipc	ra,0x2
    2f3e:	47e080e7          	jalr	1150(ra) # 53b8 <open>
    2f42:	3a055063          	bgez	a0,32e2 <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    2f46:	00004597          	auipc	a1,0x4
    2f4a:	15a58593          	addi	a1,a1,346 # 70a0 <malloc+0x18f2>
    2f4e:	00004517          	auipc	a0,0x4
    2f52:	09250513          	addi	a0,a0,146 # 6fe0 <malloc+0x1832>
    2f56:	00002097          	auipc	ra,0x2
    2f5a:	482080e7          	jalr	1154(ra) # 53d8 <link>
    2f5e:	3a050063          	beqz	a0,32fe <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    2f62:	00004597          	auipc	a1,0x4
    2f66:	13e58593          	addi	a1,a1,318 # 70a0 <malloc+0x18f2>
    2f6a:	00004517          	auipc	a0,0x4
    2f6e:	0a650513          	addi	a0,a0,166 # 7010 <malloc+0x1862>
    2f72:	00002097          	auipc	ra,0x2
    2f76:	466080e7          	jalr	1126(ra) # 53d8 <link>
    2f7a:	3a050063          	beqz	a0,331a <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    2f7e:	00004597          	auipc	a1,0x4
    2f82:	eda58593          	addi	a1,a1,-294 # 6e58 <malloc+0x16aa>
    2f86:	00004517          	auipc	a0,0x4
    2f8a:	dca50513          	addi	a0,a0,-566 # 6d50 <malloc+0x15a2>
    2f8e:	00002097          	auipc	ra,0x2
    2f92:	44a080e7          	jalr	1098(ra) # 53d8 <link>
    2f96:	3a050063          	beqz	a0,3336 <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    2f9a:	00004517          	auipc	a0,0x4
    2f9e:	04650513          	addi	a0,a0,70 # 6fe0 <malloc+0x1832>
    2fa2:	00002097          	auipc	ra,0x2
    2fa6:	43e080e7          	jalr	1086(ra) # 53e0 <mkdir>
    2faa:	3a050463          	beqz	a0,3352 <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    2fae:	00004517          	auipc	a0,0x4
    2fb2:	06250513          	addi	a0,a0,98 # 7010 <malloc+0x1862>
    2fb6:	00002097          	auipc	ra,0x2
    2fba:	42a080e7          	jalr	1066(ra) # 53e0 <mkdir>
    2fbe:	3a050863          	beqz	a0,336e <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    2fc2:	00004517          	auipc	a0,0x4
    2fc6:	e9650513          	addi	a0,a0,-362 # 6e58 <malloc+0x16aa>
    2fca:	00002097          	auipc	ra,0x2
    2fce:	416080e7          	jalr	1046(ra) # 53e0 <mkdir>
    2fd2:	3a050c63          	beqz	a0,338a <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    2fd6:	00004517          	auipc	a0,0x4
    2fda:	03a50513          	addi	a0,a0,58 # 7010 <malloc+0x1862>
    2fde:	00002097          	auipc	ra,0x2
    2fe2:	3ea080e7          	jalr	1002(ra) # 53c8 <unlink>
    2fe6:	3c050063          	beqz	a0,33a6 <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    2fea:	00004517          	auipc	a0,0x4
    2fee:	ff650513          	addi	a0,a0,-10 # 6fe0 <malloc+0x1832>
    2ff2:	00002097          	auipc	ra,0x2
    2ff6:	3d6080e7          	jalr	982(ra) # 53c8 <unlink>
    2ffa:	3c050463          	beqz	a0,33c2 <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    2ffe:	00004517          	auipc	a0,0x4
    3002:	d5250513          	addi	a0,a0,-686 # 6d50 <malloc+0x15a2>
    3006:	00002097          	auipc	ra,0x2
    300a:	3e2080e7          	jalr	994(ra) # 53e8 <chdir>
    300e:	3c050863          	beqz	a0,33de <subdir+0x702>
  if(chdir("dd/xx") == 0){
    3012:	00004517          	auipc	a0,0x4
    3016:	1de50513          	addi	a0,a0,478 # 71f0 <malloc+0x1a42>
    301a:	00002097          	auipc	ra,0x2
    301e:	3ce080e7          	jalr	974(ra) # 53e8 <chdir>
    3022:	3c050c63          	beqz	a0,33fa <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    3026:	00004517          	auipc	a0,0x4
    302a:	e3250513          	addi	a0,a0,-462 # 6e58 <malloc+0x16aa>
    302e:	00002097          	auipc	ra,0x2
    3032:	39a080e7          	jalr	922(ra) # 53c8 <unlink>
    3036:	3e051063          	bnez	a0,3416 <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    303a:	00004517          	auipc	a0,0x4
    303e:	d1650513          	addi	a0,a0,-746 # 6d50 <malloc+0x15a2>
    3042:	00002097          	auipc	ra,0x2
    3046:	386080e7          	jalr	902(ra) # 53c8 <unlink>
    304a:	3e051463          	bnez	a0,3432 <subdir+0x756>
  if(unlink("dd") == 0){
    304e:	00004517          	auipc	a0,0x4
    3052:	ce250513          	addi	a0,a0,-798 # 6d30 <malloc+0x1582>
    3056:	00002097          	auipc	ra,0x2
    305a:	372080e7          	jalr	882(ra) # 53c8 <unlink>
    305e:	3e050863          	beqz	a0,344e <subdir+0x772>
  if(unlink("dd/dd") < 0){
    3062:	00004517          	auipc	a0,0x4
    3066:	1fe50513          	addi	a0,a0,510 # 7260 <malloc+0x1ab2>
    306a:	00002097          	auipc	ra,0x2
    306e:	35e080e7          	jalr	862(ra) # 53c8 <unlink>
    3072:	3e054c63          	bltz	a0,346a <subdir+0x78e>
  if(unlink("dd") < 0){
    3076:	00004517          	auipc	a0,0x4
    307a:	cba50513          	addi	a0,a0,-838 # 6d30 <malloc+0x1582>
    307e:	00002097          	auipc	ra,0x2
    3082:	34a080e7          	jalr	842(ra) # 53c8 <unlink>
    3086:	40054063          	bltz	a0,3486 <subdir+0x7aa>
}
    308a:	60e2                	ld	ra,24(sp)
    308c:	6442                	ld	s0,16(sp)
    308e:	64a2                	ld	s1,8(sp)
    3090:	6902                	ld	s2,0(sp)
    3092:	6105                	addi	sp,sp,32
    3094:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    3096:	85ca                	mv	a1,s2
    3098:	00004517          	auipc	a0,0x4
    309c:	ca050513          	addi	a0,a0,-864 # 6d38 <malloc+0x158a>
    30a0:	00002097          	auipc	ra,0x2
    30a4:	650080e7          	jalr	1616(ra) # 56f0 <printf>
    exit(1);
    30a8:	4505                	li	a0,1
    30aa:	00002097          	auipc	ra,0x2
    30ae:	2ce080e7          	jalr	718(ra) # 5378 <exit>
    printf("%s: create dd/ff failed\n", s);
    30b2:	85ca                	mv	a1,s2
    30b4:	00004517          	auipc	a0,0x4
    30b8:	ca450513          	addi	a0,a0,-860 # 6d58 <malloc+0x15aa>
    30bc:	00002097          	auipc	ra,0x2
    30c0:	634080e7          	jalr	1588(ra) # 56f0 <printf>
    exit(1);
    30c4:	4505                	li	a0,1
    30c6:	00002097          	auipc	ra,0x2
    30ca:	2b2080e7          	jalr	690(ra) # 5378 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    30ce:	85ca                	mv	a1,s2
    30d0:	00004517          	auipc	a0,0x4
    30d4:	ca850513          	addi	a0,a0,-856 # 6d78 <malloc+0x15ca>
    30d8:	00002097          	auipc	ra,0x2
    30dc:	618080e7          	jalr	1560(ra) # 56f0 <printf>
    exit(1);
    30e0:	4505                	li	a0,1
    30e2:	00002097          	auipc	ra,0x2
    30e6:	296080e7          	jalr	662(ra) # 5378 <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    30ea:	85ca                	mv	a1,s2
    30ec:	00004517          	auipc	a0,0x4
    30f0:	cc450513          	addi	a0,a0,-828 # 6db0 <malloc+0x1602>
    30f4:	00002097          	auipc	ra,0x2
    30f8:	5fc080e7          	jalr	1532(ra) # 56f0 <printf>
    exit(1);
    30fc:	4505                	li	a0,1
    30fe:	00002097          	auipc	ra,0x2
    3102:	27a080e7          	jalr	634(ra) # 5378 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    3106:	85ca                	mv	a1,s2
    3108:	00004517          	auipc	a0,0x4
    310c:	cd850513          	addi	a0,a0,-808 # 6de0 <malloc+0x1632>
    3110:	00002097          	auipc	ra,0x2
    3114:	5e0080e7          	jalr	1504(ra) # 56f0 <printf>
    exit(1);
    3118:	4505                	li	a0,1
    311a:	00002097          	auipc	ra,0x2
    311e:	25e080e7          	jalr	606(ra) # 5378 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    3122:	85ca                	mv	a1,s2
    3124:	00004517          	auipc	a0,0x4
    3128:	cf450513          	addi	a0,a0,-780 # 6e18 <malloc+0x166a>
    312c:	00002097          	auipc	ra,0x2
    3130:	5c4080e7          	jalr	1476(ra) # 56f0 <printf>
    exit(1);
    3134:	4505                	li	a0,1
    3136:	00002097          	auipc	ra,0x2
    313a:	242080e7          	jalr	578(ra) # 5378 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    313e:	85ca                	mv	a1,s2
    3140:	00004517          	auipc	a0,0x4
    3144:	cf850513          	addi	a0,a0,-776 # 6e38 <malloc+0x168a>
    3148:	00002097          	auipc	ra,0x2
    314c:	5a8080e7          	jalr	1448(ra) # 56f0 <printf>
    exit(1);
    3150:	4505                	li	a0,1
    3152:	00002097          	auipc	ra,0x2
    3156:	226080e7          	jalr	550(ra) # 5378 <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    315a:	85ca                	mv	a1,s2
    315c:	00004517          	auipc	a0,0x4
    3160:	d0c50513          	addi	a0,a0,-756 # 6e68 <malloc+0x16ba>
    3164:	00002097          	auipc	ra,0x2
    3168:	58c080e7          	jalr	1420(ra) # 56f0 <printf>
    exit(1);
    316c:	4505                	li	a0,1
    316e:	00002097          	auipc	ra,0x2
    3172:	20a080e7          	jalr	522(ra) # 5378 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3176:	85ca                	mv	a1,s2
    3178:	00004517          	auipc	a0,0x4
    317c:	d1850513          	addi	a0,a0,-744 # 6e90 <malloc+0x16e2>
    3180:	00002097          	auipc	ra,0x2
    3184:	570080e7          	jalr	1392(ra) # 56f0 <printf>
    exit(1);
    3188:	4505                	li	a0,1
    318a:	00002097          	auipc	ra,0x2
    318e:	1ee080e7          	jalr	494(ra) # 5378 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    3192:	85ca                	mv	a1,s2
    3194:	00004517          	auipc	a0,0x4
    3198:	d1c50513          	addi	a0,a0,-740 # 6eb0 <malloc+0x1702>
    319c:	00002097          	auipc	ra,0x2
    31a0:	554080e7          	jalr	1364(ra) # 56f0 <printf>
    exit(1);
    31a4:	4505                	li	a0,1
    31a6:	00002097          	auipc	ra,0x2
    31aa:	1d2080e7          	jalr	466(ra) # 5378 <exit>
    printf("%s: chdir dd failed\n", s);
    31ae:	85ca                	mv	a1,s2
    31b0:	00004517          	auipc	a0,0x4
    31b4:	d2850513          	addi	a0,a0,-728 # 6ed8 <malloc+0x172a>
    31b8:	00002097          	auipc	ra,0x2
    31bc:	538080e7          	jalr	1336(ra) # 56f0 <printf>
    exit(1);
    31c0:	4505                	li	a0,1
    31c2:	00002097          	auipc	ra,0x2
    31c6:	1b6080e7          	jalr	438(ra) # 5378 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    31ca:	85ca                	mv	a1,s2
    31cc:	00004517          	auipc	a0,0x4
    31d0:	d3450513          	addi	a0,a0,-716 # 6f00 <malloc+0x1752>
    31d4:	00002097          	auipc	ra,0x2
    31d8:	51c080e7          	jalr	1308(ra) # 56f0 <printf>
    exit(1);
    31dc:	4505                	li	a0,1
    31de:	00002097          	auipc	ra,0x2
    31e2:	19a080e7          	jalr	410(ra) # 5378 <exit>
    printf("chdir dd/../../dd failed\n", s);
    31e6:	85ca                	mv	a1,s2
    31e8:	00004517          	auipc	a0,0x4
    31ec:	d4850513          	addi	a0,a0,-696 # 6f30 <malloc+0x1782>
    31f0:	00002097          	auipc	ra,0x2
    31f4:	500080e7          	jalr	1280(ra) # 56f0 <printf>
    exit(1);
    31f8:	4505                	li	a0,1
    31fa:	00002097          	auipc	ra,0x2
    31fe:	17e080e7          	jalr	382(ra) # 5378 <exit>
    printf("%s: chdir ./.. failed\n", s);
    3202:	85ca                	mv	a1,s2
    3204:	00004517          	auipc	a0,0x4
    3208:	d5450513          	addi	a0,a0,-684 # 6f58 <malloc+0x17aa>
    320c:	00002097          	auipc	ra,0x2
    3210:	4e4080e7          	jalr	1252(ra) # 56f0 <printf>
    exit(1);
    3214:	4505                	li	a0,1
    3216:	00002097          	auipc	ra,0x2
    321a:	162080e7          	jalr	354(ra) # 5378 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    321e:	85ca                	mv	a1,s2
    3220:	00004517          	auipc	a0,0x4
    3224:	d5050513          	addi	a0,a0,-688 # 6f70 <malloc+0x17c2>
    3228:	00002097          	auipc	ra,0x2
    322c:	4c8080e7          	jalr	1224(ra) # 56f0 <printf>
    exit(1);
    3230:	4505                	li	a0,1
    3232:	00002097          	auipc	ra,0x2
    3236:	146080e7          	jalr	326(ra) # 5378 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    323a:	85ca                	mv	a1,s2
    323c:	00004517          	auipc	a0,0x4
    3240:	d5450513          	addi	a0,a0,-684 # 6f90 <malloc+0x17e2>
    3244:	00002097          	auipc	ra,0x2
    3248:	4ac080e7          	jalr	1196(ra) # 56f0 <printf>
    exit(1);
    324c:	4505                	li	a0,1
    324e:	00002097          	auipc	ra,0x2
    3252:	12a080e7          	jalr	298(ra) # 5378 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    3256:	85ca                	mv	a1,s2
    3258:	00004517          	auipc	a0,0x4
    325c:	d5850513          	addi	a0,a0,-680 # 6fb0 <malloc+0x1802>
    3260:	00002097          	auipc	ra,0x2
    3264:	490080e7          	jalr	1168(ra) # 56f0 <printf>
    exit(1);
    3268:	4505                	li	a0,1
    326a:	00002097          	auipc	ra,0x2
    326e:	10e080e7          	jalr	270(ra) # 5378 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    3272:	85ca                	mv	a1,s2
    3274:	00004517          	auipc	a0,0x4
    3278:	d7c50513          	addi	a0,a0,-644 # 6ff0 <malloc+0x1842>
    327c:	00002097          	auipc	ra,0x2
    3280:	474080e7          	jalr	1140(ra) # 56f0 <printf>
    exit(1);
    3284:	4505                	li	a0,1
    3286:	00002097          	auipc	ra,0x2
    328a:	0f2080e7          	jalr	242(ra) # 5378 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    328e:	85ca                	mv	a1,s2
    3290:	00004517          	auipc	a0,0x4
    3294:	d9050513          	addi	a0,a0,-624 # 7020 <malloc+0x1872>
    3298:	00002097          	auipc	ra,0x2
    329c:	458080e7          	jalr	1112(ra) # 56f0 <printf>
    exit(1);
    32a0:	4505                	li	a0,1
    32a2:	00002097          	auipc	ra,0x2
    32a6:	0d6080e7          	jalr	214(ra) # 5378 <exit>
    printf("%s: create dd succeeded!\n", s);
    32aa:	85ca                	mv	a1,s2
    32ac:	00004517          	auipc	a0,0x4
    32b0:	d9450513          	addi	a0,a0,-620 # 7040 <malloc+0x1892>
    32b4:	00002097          	auipc	ra,0x2
    32b8:	43c080e7          	jalr	1084(ra) # 56f0 <printf>
    exit(1);
    32bc:	4505                	li	a0,1
    32be:	00002097          	auipc	ra,0x2
    32c2:	0ba080e7          	jalr	186(ra) # 5378 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    32c6:	85ca                	mv	a1,s2
    32c8:	00004517          	auipc	a0,0x4
    32cc:	d9850513          	addi	a0,a0,-616 # 7060 <malloc+0x18b2>
    32d0:	00002097          	auipc	ra,0x2
    32d4:	420080e7          	jalr	1056(ra) # 56f0 <printf>
    exit(1);
    32d8:	4505                	li	a0,1
    32da:	00002097          	auipc	ra,0x2
    32de:	09e080e7          	jalr	158(ra) # 5378 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    32e2:	85ca                	mv	a1,s2
    32e4:	00004517          	auipc	a0,0x4
    32e8:	d9c50513          	addi	a0,a0,-612 # 7080 <malloc+0x18d2>
    32ec:	00002097          	auipc	ra,0x2
    32f0:	404080e7          	jalr	1028(ra) # 56f0 <printf>
    exit(1);
    32f4:	4505                	li	a0,1
    32f6:	00002097          	auipc	ra,0x2
    32fa:	082080e7          	jalr	130(ra) # 5378 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    32fe:	85ca                	mv	a1,s2
    3300:	00004517          	auipc	a0,0x4
    3304:	db050513          	addi	a0,a0,-592 # 70b0 <malloc+0x1902>
    3308:	00002097          	auipc	ra,0x2
    330c:	3e8080e7          	jalr	1000(ra) # 56f0 <printf>
    exit(1);
    3310:	4505                	li	a0,1
    3312:	00002097          	auipc	ra,0x2
    3316:	066080e7          	jalr	102(ra) # 5378 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    331a:	85ca                	mv	a1,s2
    331c:	00004517          	auipc	a0,0x4
    3320:	dbc50513          	addi	a0,a0,-580 # 70d8 <malloc+0x192a>
    3324:	00002097          	auipc	ra,0x2
    3328:	3cc080e7          	jalr	972(ra) # 56f0 <printf>
    exit(1);
    332c:	4505                	li	a0,1
    332e:	00002097          	auipc	ra,0x2
    3332:	04a080e7          	jalr	74(ra) # 5378 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    3336:	85ca                	mv	a1,s2
    3338:	00004517          	auipc	a0,0x4
    333c:	dc850513          	addi	a0,a0,-568 # 7100 <malloc+0x1952>
    3340:	00002097          	auipc	ra,0x2
    3344:	3b0080e7          	jalr	944(ra) # 56f0 <printf>
    exit(1);
    3348:	4505                	li	a0,1
    334a:	00002097          	auipc	ra,0x2
    334e:	02e080e7          	jalr	46(ra) # 5378 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    3352:	85ca                	mv	a1,s2
    3354:	00004517          	auipc	a0,0x4
    3358:	dd450513          	addi	a0,a0,-556 # 7128 <malloc+0x197a>
    335c:	00002097          	auipc	ra,0x2
    3360:	394080e7          	jalr	916(ra) # 56f0 <printf>
    exit(1);
    3364:	4505                	li	a0,1
    3366:	00002097          	auipc	ra,0x2
    336a:	012080e7          	jalr	18(ra) # 5378 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    336e:	85ca                	mv	a1,s2
    3370:	00004517          	auipc	a0,0x4
    3374:	dd850513          	addi	a0,a0,-552 # 7148 <malloc+0x199a>
    3378:	00002097          	auipc	ra,0x2
    337c:	378080e7          	jalr	888(ra) # 56f0 <printf>
    exit(1);
    3380:	4505                	li	a0,1
    3382:	00002097          	auipc	ra,0x2
    3386:	ff6080e7          	jalr	-10(ra) # 5378 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    338a:	85ca                	mv	a1,s2
    338c:	00004517          	auipc	a0,0x4
    3390:	ddc50513          	addi	a0,a0,-548 # 7168 <malloc+0x19ba>
    3394:	00002097          	auipc	ra,0x2
    3398:	35c080e7          	jalr	860(ra) # 56f0 <printf>
    exit(1);
    339c:	4505                	li	a0,1
    339e:	00002097          	auipc	ra,0x2
    33a2:	fda080e7          	jalr	-38(ra) # 5378 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    33a6:	85ca                	mv	a1,s2
    33a8:	00004517          	auipc	a0,0x4
    33ac:	de850513          	addi	a0,a0,-536 # 7190 <malloc+0x19e2>
    33b0:	00002097          	auipc	ra,0x2
    33b4:	340080e7          	jalr	832(ra) # 56f0 <printf>
    exit(1);
    33b8:	4505                	li	a0,1
    33ba:	00002097          	auipc	ra,0x2
    33be:	fbe080e7          	jalr	-66(ra) # 5378 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    33c2:	85ca                	mv	a1,s2
    33c4:	00004517          	auipc	a0,0x4
    33c8:	dec50513          	addi	a0,a0,-532 # 71b0 <malloc+0x1a02>
    33cc:	00002097          	auipc	ra,0x2
    33d0:	324080e7          	jalr	804(ra) # 56f0 <printf>
    exit(1);
    33d4:	4505                	li	a0,1
    33d6:	00002097          	auipc	ra,0x2
    33da:	fa2080e7          	jalr	-94(ra) # 5378 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    33de:	85ca                	mv	a1,s2
    33e0:	00004517          	auipc	a0,0x4
    33e4:	df050513          	addi	a0,a0,-528 # 71d0 <malloc+0x1a22>
    33e8:	00002097          	auipc	ra,0x2
    33ec:	308080e7          	jalr	776(ra) # 56f0 <printf>
    exit(1);
    33f0:	4505                	li	a0,1
    33f2:	00002097          	auipc	ra,0x2
    33f6:	f86080e7          	jalr	-122(ra) # 5378 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    33fa:	85ca                	mv	a1,s2
    33fc:	00004517          	auipc	a0,0x4
    3400:	dfc50513          	addi	a0,a0,-516 # 71f8 <malloc+0x1a4a>
    3404:	00002097          	auipc	ra,0x2
    3408:	2ec080e7          	jalr	748(ra) # 56f0 <printf>
    exit(1);
    340c:	4505                	li	a0,1
    340e:	00002097          	auipc	ra,0x2
    3412:	f6a080e7          	jalr	-150(ra) # 5378 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3416:	85ca                	mv	a1,s2
    3418:	00004517          	auipc	a0,0x4
    341c:	a7850513          	addi	a0,a0,-1416 # 6e90 <malloc+0x16e2>
    3420:	00002097          	auipc	ra,0x2
    3424:	2d0080e7          	jalr	720(ra) # 56f0 <printf>
    exit(1);
    3428:	4505                	li	a0,1
    342a:	00002097          	auipc	ra,0x2
    342e:	f4e080e7          	jalr	-178(ra) # 5378 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    3432:	85ca                	mv	a1,s2
    3434:	00004517          	auipc	a0,0x4
    3438:	de450513          	addi	a0,a0,-540 # 7218 <malloc+0x1a6a>
    343c:	00002097          	auipc	ra,0x2
    3440:	2b4080e7          	jalr	692(ra) # 56f0 <printf>
    exit(1);
    3444:	4505                	li	a0,1
    3446:	00002097          	auipc	ra,0x2
    344a:	f32080e7          	jalr	-206(ra) # 5378 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    344e:	85ca                	mv	a1,s2
    3450:	00004517          	auipc	a0,0x4
    3454:	de850513          	addi	a0,a0,-536 # 7238 <malloc+0x1a8a>
    3458:	00002097          	auipc	ra,0x2
    345c:	298080e7          	jalr	664(ra) # 56f0 <printf>
    exit(1);
    3460:	4505                	li	a0,1
    3462:	00002097          	auipc	ra,0x2
    3466:	f16080e7          	jalr	-234(ra) # 5378 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    346a:	85ca                	mv	a1,s2
    346c:	00004517          	auipc	a0,0x4
    3470:	dfc50513          	addi	a0,a0,-516 # 7268 <malloc+0x1aba>
    3474:	00002097          	auipc	ra,0x2
    3478:	27c080e7          	jalr	636(ra) # 56f0 <printf>
    exit(1);
    347c:	4505                	li	a0,1
    347e:	00002097          	auipc	ra,0x2
    3482:	efa080e7          	jalr	-262(ra) # 5378 <exit>
    printf("%s: unlink dd failed\n", s);
    3486:	85ca                	mv	a1,s2
    3488:	00004517          	auipc	a0,0x4
    348c:	e0050513          	addi	a0,a0,-512 # 7288 <malloc+0x1ada>
    3490:	00002097          	auipc	ra,0x2
    3494:	260080e7          	jalr	608(ra) # 56f0 <printf>
    exit(1);
    3498:	4505                	li	a0,1
    349a:	00002097          	auipc	ra,0x2
    349e:	ede080e7          	jalr	-290(ra) # 5378 <exit>

00000000000034a2 <rmdot>:
{
    34a2:	1101                	addi	sp,sp,-32
    34a4:	ec06                	sd	ra,24(sp)
    34a6:	e822                	sd	s0,16(sp)
    34a8:	e426                	sd	s1,8(sp)
    34aa:	1000                	addi	s0,sp,32
    34ac:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    34ae:	00004517          	auipc	a0,0x4
    34b2:	df250513          	addi	a0,a0,-526 # 72a0 <malloc+0x1af2>
    34b6:	00002097          	auipc	ra,0x2
    34ba:	f2a080e7          	jalr	-214(ra) # 53e0 <mkdir>
    34be:	e549                	bnez	a0,3548 <rmdot+0xa6>
  if(chdir("dots") != 0){
    34c0:	00004517          	auipc	a0,0x4
    34c4:	de050513          	addi	a0,a0,-544 # 72a0 <malloc+0x1af2>
    34c8:	00002097          	auipc	ra,0x2
    34cc:	f20080e7          	jalr	-224(ra) # 53e8 <chdir>
    34d0:	e951                	bnez	a0,3564 <rmdot+0xc2>
  if(unlink(".") == 0){
    34d2:	00003517          	auipc	a0,0x3
    34d6:	d9650513          	addi	a0,a0,-618 # 6268 <malloc+0xaba>
    34da:	00002097          	auipc	ra,0x2
    34de:	eee080e7          	jalr	-274(ra) # 53c8 <unlink>
    34e2:	cd59                	beqz	a0,3580 <rmdot+0xde>
  if(unlink("..") == 0){
    34e4:	00004517          	auipc	a0,0x4
    34e8:	e0c50513          	addi	a0,a0,-500 # 72f0 <malloc+0x1b42>
    34ec:	00002097          	auipc	ra,0x2
    34f0:	edc080e7          	jalr	-292(ra) # 53c8 <unlink>
    34f4:	c545                	beqz	a0,359c <rmdot+0xfa>
  if(chdir("/") != 0){
    34f6:	00004517          	auipc	a0,0x4
    34fa:	80250513          	addi	a0,a0,-2046 # 6cf8 <malloc+0x154a>
    34fe:	00002097          	auipc	ra,0x2
    3502:	eea080e7          	jalr	-278(ra) # 53e8 <chdir>
    3506:	e94d                	bnez	a0,35b8 <rmdot+0x116>
  if(unlink("dots/.") == 0){
    3508:	00004517          	auipc	a0,0x4
    350c:	e0850513          	addi	a0,a0,-504 # 7310 <malloc+0x1b62>
    3510:	00002097          	auipc	ra,0x2
    3514:	eb8080e7          	jalr	-328(ra) # 53c8 <unlink>
    3518:	cd55                	beqz	a0,35d4 <rmdot+0x132>
  if(unlink("dots/..") == 0){
    351a:	00004517          	auipc	a0,0x4
    351e:	e1e50513          	addi	a0,a0,-482 # 7338 <malloc+0x1b8a>
    3522:	00002097          	auipc	ra,0x2
    3526:	ea6080e7          	jalr	-346(ra) # 53c8 <unlink>
    352a:	c179                	beqz	a0,35f0 <rmdot+0x14e>
  if(unlink("dots") != 0){
    352c:	00004517          	auipc	a0,0x4
    3530:	d7450513          	addi	a0,a0,-652 # 72a0 <malloc+0x1af2>
    3534:	00002097          	auipc	ra,0x2
    3538:	e94080e7          	jalr	-364(ra) # 53c8 <unlink>
    353c:	e961                	bnez	a0,360c <rmdot+0x16a>
}
    353e:	60e2                	ld	ra,24(sp)
    3540:	6442                	ld	s0,16(sp)
    3542:	64a2                	ld	s1,8(sp)
    3544:	6105                	addi	sp,sp,32
    3546:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    3548:	85a6                	mv	a1,s1
    354a:	00004517          	auipc	a0,0x4
    354e:	d5e50513          	addi	a0,a0,-674 # 72a8 <malloc+0x1afa>
    3552:	00002097          	auipc	ra,0x2
    3556:	19e080e7          	jalr	414(ra) # 56f0 <printf>
    exit(1);
    355a:	4505                	li	a0,1
    355c:	00002097          	auipc	ra,0x2
    3560:	e1c080e7          	jalr	-484(ra) # 5378 <exit>
    printf("%s: chdir dots failed\n", s);
    3564:	85a6                	mv	a1,s1
    3566:	00004517          	auipc	a0,0x4
    356a:	d5a50513          	addi	a0,a0,-678 # 72c0 <malloc+0x1b12>
    356e:	00002097          	auipc	ra,0x2
    3572:	182080e7          	jalr	386(ra) # 56f0 <printf>
    exit(1);
    3576:	4505                	li	a0,1
    3578:	00002097          	auipc	ra,0x2
    357c:	e00080e7          	jalr	-512(ra) # 5378 <exit>
    printf("%s: rm . worked!\n", s);
    3580:	85a6                	mv	a1,s1
    3582:	00004517          	auipc	a0,0x4
    3586:	d5650513          	addi	a0,a0,-682 # 72d8 <malloc+0x1b2a>
    358a:	00002097          	auipc	ra,0x2
    358e:	166080e7          	jalr	358(ra) # 56f0 <printf>
    exit(1);
    3592:	4505                	li	a0,1
    3594:	00002097          	auipc	ra,0x2
    3598:	de4080e7          	jalr	-540(ra) # 5378 <exit>
    printf("%s: rm .. worked!\n", s);
    359c:	85a6                	mv	a1,s1
    359e:	00004517          	auipc	a0,0x4
    35a2:	d5a50513          	addi	a0,a0,-678 # 72f8 <malloc+0x1b4a>
    35a6:	00002097          	auipc	ra,0x2
    35aa:	14a080e7          	jalr	330(ra) # 56f0 <printf>
    exit(1);
    35ae:	4505                	li	a0,1
    35b0:	00002097          	auipc	ra,0x2
    35b4:	dc8080e7          	jalr	-568(ra) # 5378 <exit>
    printf("%s: chdir / failed\n", s);
    35b8:	85a6                	mv	a1,s1
    35ba:	00003517          	auipc	a0,0x3
    35be:	74650513          	addi	a0,a0,1862 # 6d00 <malloc+0x1552>
    35c2:	00002097          	auipc	ra,0x2
    35c6:	12e080e7          	jalr	302(ra) # 56f0 <printf>
    exit(1);
    35ca:	4505                	li	a0,1
    35cc:	00002097          	auipc	ra,0x2
    35d0:	dac080e7          	jalr	-596(ra) # 5378 <exit>
    printf("%s: unlink dots/. worked!\n", s);
    35d4:	85a6                	mv	a1,s1
    35d6:	00004517          	auipc	a0,0x4
    35da:	d4250513          	addi	a0,a0,-702 # 7318 <malloc+0x1b6a>
    35de:	00002097          	auipc	ra,0x2
    35e2:	112080e7          	jalr	274(ra) # 56f0 <printf>
    exit(1);
    35e6:	4505                	li	a0,1
    35e8:	00002097          	auipc	ra,0x2
    35ec:	d90080e7          	jalr	-624(ra) # 5378 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    35f0:	85a6                	mv	a1,s1
    35f2:	00004517          	auipc	a0,0x4
    35f6:	d4e50513          	addi	a0,a0,-690 # 7340 <malloc+0x1b92>
    35fa:	00002097          	auipc	ra,0x2
    35fe:	0f6080e7          	jalr	246(ra) # 56f0 <printf>
    exit(1);
    3602:	4505                	li	a0,1
    3604:	00002097          	auipc	ra,0x2
    3608:	d74080e7          	jalr	-652(ra) # 5378 <exit>
    printf("%s: unlink dots failed!\n", s);
    360c:	85a6                	mv	a1,s1
    360e:	00004517          	auipc	a0,0x4
    3612:	d5250513          	addi	a0,a0,-686 # 7360 <malloc+0x1bb2>
    3616:	00002097          	auipc	ra,0x2
    361a:	0da080e7          	jalr	218(ra) # 56f0 <printf>
    exit(1);
    361e:	4505                	li	a0,1
    3620:	00002097          	auipc	ra,0x2
    3624:	d58080e7          	jalr	-680(ra) # 5378 <exit>

0000000000003628 <dirfile>:
{
    3628:	1101                	addi	sp,sp,-32
    362a:	ec06                	sd	ra,24(sp)
    362c:	e822                	sd	s0,16(sp)
    362e:	e426                	sd	s1,8(sp)
    3630:	e04a                	sd	s2,0(sp)
    3632:	1000                	addi	s0,sp,32
    3634:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    3636:	20000593          	li	a1,512
    363a:	00002517          	auipc	a0,0x2
    363e:	53650513          	addi	a0,a0,1334 # 5b70 <malloc+0x3c2>
    3642:	00002097          	auipc	ra,0x2
    3646:	d76080e7          	jalr	-650(ra) # 53b8 <open>
  if(fd < 0){
    364a:	0e054d63          	bltz	a0,3744 <dirfile+0x11c>
  close(fd);
    364e:	00002097          	auipc	ra,0x2
    3652:	d52080e7          	jalr	-686(ra) # 53a0 <close>
  if(chdir("dirfile") == 0){
    3656:	00002517          	auipc	a0,0x2
    365a:	51a50513          	addi	a0,a0,1306 # 5b70 <malloc+0x3c2>
    365e:	00002097          	auipc	ra,0x2
    3662:	d8a080e7          	jalr	-630(ra) # 53e8 <chdir>
    3666:	cd6d                	beqz	a0,3760 <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    3668:	4581                	li	a1,0
    366a:	00004517          	auipc	a0,0x4
    366e:	d5650513          	addi	a0,a0,-682 # 73c0 <malloc+0x1c12>
    3672:	00002097          	auipc	ra,0x2
    3676:	d46080e7          	jalr	-698(ra) # 53b8 <open>
  if(fd >= 0){
    367a:	10055163          	bgez	a0,377c <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    367e:	20000593          	li	a1,512
    3682:	00004517          	auipc	a0,0x4
    3686:	d3e50513          	addi	a0,a0,-706 # 73c0 <malloc+0x1c12>
    368a:	00002097          	auipc	ra,0x2
    368e:	d2e080e7          	jalr	-722(ra) # 53b8 <open>
  if(fd >= 0){
    3692:	10055363          	bgez	a0,3798 <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
    3696:	00004517          	auipc	a0,0x4
    369a:	d2a50513          	addi	a0,a0,-726 # 73c0 <malloc+0x1c12>
    369e:	00002097          	auipc	ra,0x2
    36a2:	d42080e7          	jalr	-702(ra) # 53e0 <mkdir>
    36a6:	10050763          	beqz	a0,37b4 <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    36aa:	00004517          	auipc	a0,0x4
    36ae:	d1650513          	addi	a0,a0,-746 # 73c0 <malloc+0x1c12>
    36b2:	00002097          	auipc	ra,0x2
    36b6:	d16080e7          	jalr	-746(ra) # 53c8 <unlink>
    36ba:	10050b63          	beqz	a0,37d0 <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    36be:	00004597          	auipc	a1,0x4
    36c2:	d0258593          	addi	a1,a1,-766 # 73c0 <malloc+0x1c12>
    36c6:	00002517          	auipc	a0,0x2
    36ca:	6a250513          	addi	a0,a0,1698 # 5d68 <malloc+0x5ba>
    36ce:	00002097          	auipc	ra,0x2
    36d2:	d0a080e7          	jalr	-758(ra) # 53d8 <link>
    36d6:	10050b63          	beqz	a0,37ec <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    36da:	00002517          	auipc	a0,0x2
    36de:	49650513          	addi	a0,a0,1174 # 5b70 <malloc+0x3c2>
    36e2:	00002097          	auipc	ra,0x2
    36e6:	ce6080e7          	jalr	-794(ra) # 53c8 <unlink>
    36ea:	10051f63          	bnez	a0,3808 <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    36ee:	4589                	li	a1,2
    36f0:	00003517          	auipc	a0,0x3
    36f4:	b7850513          	addi	a0,a0,-1160 # 6268 <malloc+0xaba>
    36f8:	00002097          	auipc	ra,0x2
    36fc:	cc0080e7          	jalr	-832(ra) # 53b8 <open>
  if(fd >= 0){
    3700:	12055263          	bgez	a0,3824 <dirfile+0x1fc>
  fd = open(".", 0);
    3704:	4581                	li	a1,0
    3706:	00003517          	auipc	a0,0x3
    370a:	b6250513          	addi	a0,a0,-1182 # 6268 <malloc+0xaba>
    370e:	00002097          	auipc	ra,0x2
    3712:	caa080e7          	jalr	-854(ra) # 53b8 <open>
    3716:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    3718:	4605                	li	a2,1
    371a:	00002597          	auipc	a1,0x2
    371e:	52658593          	addi	a1,a1,1318 # 5c40 <malloc+0x492>
    3722:	00002097          	auipc	ra,0x2
    3726:	c76080e7          	jalr	-906(ra) # 5398 <write>
    372a:	10a04b63          	bgtz	a0,3840 <dirfile+0x218>
  close(fd);
    372e:	8526                	mv	a0,s1
    3730:	00002097          	auipc	ra,0x2
    3734:	c70080e7          	jalr	-912(ra) # 53a0 <close>
}
    3738:	60e2                	ld	ra,24(sp)
    373a:	6442                	ld	s0,16(sp)
    373c:	64a2                	ld	s1,8(sp)
    373e:	6902                	ld	s2,0(sp)
    3740:	6105                	addi	sp,sp,32
    3742:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    3744:	85ca                	mv	a1,s2
    3746:	00004517          	auipc	a0,0x4
    374a:	c3a50513          	addi	a0,a0,-966 # 7380 <malloc+0x1bd2>
    374e:	00002097          	auipc	ra,0x2
    3752:	fa2080e7          	jalr	-94(ra) # 56f0 <printf>
    exit(1);
    3756:	4505                	li	a0,1
    3758:	00002097          	auipc	ra,0x2
    375c:	c20080e7          	jalr	-992(ra) # 5378 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    3760:	85ca                	mv	a1,s2
    3762:	00004517          	auipc	a0,0x4
    3766:	c3e50513          	addi	a0,a0,-962 # 73a0 <malloc+0x1bf2>
    376a:	00002097          	auipc	ra,0x2
    376e:	f86080e7          	jalr	-122(ra) # 56f0 <printf>
    exit(1);
    3772:	4505                	li	a0,1
    3774:	00002097          	auipc	ra,0x2
    3778:	c04080e7          	jalr	-1020(ra) # 5378 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    377c:	85ca                	mv	a1,s2
    377e:	00004517          	auipc	a0,0x4
    3782:	c5250513          	addi	a0,a0,-942 # 73d0 <malloc+0x1c22>
    3786:	00002097          	auipc	ra,0x2
    378a:	f6a080e7          	jalr	-150(ra) # 56f0 <printf>
    exit(1);
    378e:	4505                	li	a0,1
    3790:	00002097          	auipc	ra,0x2
    3794:	be8080e7          	jalr	-1048(ra) # 5378 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3798:	85ca                	mv	a1,s2
    379a:	00004517          	auipc	a0,0x4
    379e:	c3650513          	addi	a0,a0,-970 # 73d0 <malloc+0x1c22>
    37a2:	00002097          	auipc	ra,0x2
    37a6:	f4e080e7          	jalr	-178(ra) # 56f0 <printf>
    exit(1);
    37aa:	4505                	li	a0,1
    37ac:	00002097          	auipc	ra,0x2
    37b0:	bcc080e7          	jalr	-1076(ra) # 5378 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    37b4:	85ca                	mv	a1,s2
    37b6:	00004517          	auipc	a0,0x4
    37ba:	c4250513          	addi	a0,a0,-958 # 73f8 <malloc+0x1c4a>
    37be:	00002097          	auipc	ra,0x2
    37c2:	f32080e7          	jalr	-206(ra) # 56f0 <printf>
    exit(1);
    37c6:	4505                	li	a0,1
    37c8:	00002097          	auipc	ra,0x2
    37cc:	bb0080e7          	jalr	-1104(ra) # 5378 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    37d0:	85ca                	mv	a1,s2
    37d2:	00004517          	auipc	a0,0x4
    37d6:	c4e50513          	addi	a0,a0,-946 # 7420 <malloc+0x1c72>
    37da:	00002097          	auipc	ra,0x2
    37de:	f16080e7          	jalr	-234(ra) # 56f0 <printf>
    exit(1);
    37e2:	4505                	li	a0,1
    37e4:	00002097          	auipc	ra,0x2
    37e8:	b94080e7          	jalr	-1132(ra) # 5378 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    37ec:	85ca                	mv	a1,s2
    37ee:	00004517          	auipc	a0,0x4
    37f2:	c5a50513          	addi	a0,a0,-934 # 7448 <malloc+0x1c9a>
    37f6:	00002097          	auipc	ra,0x2
    37fa:	efa080e7          	jalr	-262(ra) # 56f0 <printf>
    exit(1);
    37fe:	4505                	li	a0,1
    3800:	00002097          	auipc	ra,0x2
    3804:	b78080e7          	jalr	-1160(ra) # 5378 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    3808:	85ca                	mv	a1,s2
    380a:	00004517          	auipc	a0,0x4
    380e:	c6650513          	addi	a0,a0,-922 # 7470 <malloc+0x1cc2>
    3812:	00002097          	auipc	ra,0x2
    3816:	ede080e7          	jalr	-290(ra) # 56f0 <printf>
    exit(1);
    381a:	4505                	li	a0,1
    381c:	00002097          	auipc	ra,0x2
    3820:	b5c080e7          	jalr	-1188(ra) # 5378 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    3824:	85ca                	mv	a1,s2
    3826:	00004517          	auipc	a0,0x4
    382a:	c6a50513          	addi	a0,a0,-918 # 7490 <malloc+0x1ce2>
    382e:	00002097          	auipc	ra,0x2
    3832:	ec2080e7          	jalr	-318(ra) # 56f0 <printf>
    exit(1);
    3836:	4505                	li	a0,1
    3838:	00002097          	auipc	ra,0x2
    383c:	b40080e7          	jalr	-1216(ra) # 5378 <exit>
    printf("%s: write . succeeded!\n", s);
    3840:	85ca                	mv	a1,s2
    3842:	00004517          	auipc	a0,0x4
    3846:	c7650513          	addi	a0,a0,-906 # 74b8 <malloc+0x1d0a>
    384a:	00002097          	auipc	ra,0x2
    384e:	ea6080e7          	jalr	-346(ra) # 56f0 <printf>
    exit(1);
    3852:	4505                	li	a0,1
    3854:	00002097          	auipc	ra,0x2
    3858:	b24080e7          	jalr	-1244(ra) # 5378 <exit>

000000000000385c <iref>:
{
    385c:	7139                	addi	sp,sp,-64
    385e:	fc06                	sd	ra,56(sp)
    3860:	f822                	sd	s0,48(sp)
    3862:	f426                	sd	s1,40(sp)
    3864:	f04a                	sd	s2,32(sp)
    3866:	ec4e                	sd	s3,24(sp)
    3868:	e852                	sd	s4,16(sp)
    386a:	e456                	sd	s5,8(sp)
    386c:	e05a                	sd	s6,0(sp)
    386e:	0080                	addi	s0,sp,64
    3870:	8b2a                	mv	s6,a0
    3872:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    3876:	00004a17          	auipc	s4,0x4
    387a:	c5aa0a13          	addi	s4,s4,-934 # 74d0 <malloc+0x1d22>
    mkdir("");
    387e:	00003497          	auipc	s1,0x3
    3882:	75a48493          	addi	s1,s1,1882 # 6fd8 <malloc+0x182a>
    link("README", "");
    3886:	00002a97          	auipc	s5,0x2
    388a:	4e2a8a93          	addi	s5,s5,1250 # 5d68 <malloc+0x5ba>
    fd = open("xx", O_CREATE);
    388e:	00004997          	auipc	s3,0x4
    3892:	b3a98993          	addi	s3,s3,-1222 # 73c8 <malloc+0x1c1a>
    3896:	a891                	j	38ea <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    3898:	85da                	mv	a1,s6
    389a:	00004517          	auipc	a0,0x4
    389e:	c3e50513          	addi	a0,a0,-962 # 74d8 <malloc+0x1d2a>
    38a2:	00002097          	auipc	ra,0x2
    38a6:	e4e080e7          	jalr	-434(ra) # 56f0 <printf>
      exit(1);
    38aa:	4505                	li	a0,1
    38ac:	00002097          	auipc	ra,0x2
    38b0:	acc080e7          	jalr	-1332(ra) # 5378 <exit>
      printf("%s: chdir irefd failed\n", s);
    38b4:	85da                	mv	a1,s6
    38b6:	00004517          	auipc	a0,0x4
    38ba:	c3a50513          	addi	a0,a0,-966 # 74f0 <malloc+0x1d42>
    38be:	00002097          	auipc	ra,0x2
    38c2:	e32080e7          	jalr	-462(ra) # 56f0 <printf>
      exit(1);
    38c6:	4505                	li	a0,1
    38c8:	00002097          	auipc	ra,0x2
    38cc:	ab0080e7          	jalr	-1360(ra) # 5378 <exit>
      close(fd);
    38d0:	00002097          	auipc	ra,0x2
    38d4:	ad0080e7          	jalr	-1328(ra) # 53a0 <close>
    38d8:	a889                	j	392a <iref+0xce>
    unlink("xx");
    38da:	854e                	mv	a0,s3
    38dc:	00002097          	auipc	ra,0x2
    38e0:	aec080e7          	jalr	-1300(ra) # 53c8 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    38e4:	397d                	addiw	s2,s2,-1
    38e6:	06090063          	beqz	s2,3946 <iref+0xea>
    if(mkdir("irefd") != 0){
    38ea:	8552                	mv	a0,s4
    38ec:	00002097          	auipc	ra,0x2
    38f0:	af4080e7          	jalr	-1292(ra) # 53e0 <mkdir>
    38f4:	f155                	bnez	a0,3898 <iref+0x3c>
    if(chdir("irefd") != 0){
    38f6:	8552                	mv	a0,s4
    38f8:	00002097          	auipc	ra,0x2
    38fc:	af0080e7          	jalr	-1296(ra) # 53e8 <chdir>
    3900:	f955                	bnez	a0,38b4 <iref+0x58>
    mkdir("");
    3902:	8526                	mv	a0,s1
    3904:	00002097          	auipc	ra,0x2
    3908:	adc080e7          	jalr	-1316(ra) # 53e0 <mkdir>
    link("README", "");
    390c:	85a6                	mv	a1,s1
    390e:	8556                	mv	a0,s5
    3910:	00002097          	auipc	ra,0x2
    3914:	ac8080e7          	jalr	-1336(ra) # 53d8 <link>
    fd = open("", O_CREATE);
    3918:	20000593          	li	a1,512
    391c:	8526                	mv	a0,s1
    391e:	00002097          	auipc	ra,0x2
    3922:	a9a080e7          	jalr	-1382(ra) # 53b8 <open>
    if(fd >= 0)
    3926:	fa0555e3          	bgez	a0,38d0 <iref+0x74>
    fd = open("xx", O_CREATE);
    392a:	20000593          	li	a1,512
    392e:	854e                	mv	a0,s3
    3930:	00002097          	auipc	ra,0x2
    3934:	a88080e7          	jalr	-1400(ra) # 53b8 <open>
    if(fd >= 0)
    3938:	fa0541e3          	bltz	a0,38da <iref+0x7e>
      close(fd);
    393c:	00002097          	auipc	ra,0x2
    3940:	a64080e7          	jalr	-1436(ra) # 53a0 <close>
    3944:	bf59                	j	38da <iref+0x7e>
    3946:	03300493          	li	s1,51
    chdir("..");
    394a:	00004997          	auipc	s3,0x4
    394e:	9a698993          	addi	s3,s3,-1626 # 72f0 <malloc+0x1b42>
    unlink("irefd");
    3952:	00004917          	auipc	s2,0x4
    3956:	b7e90913          	addi	s2,s2,-1154 # 74d0 <malloc+0x1d22>
    chdir("..");
    395a:	854e                	mv	a0,s3
    395c:	00002097          	auipc	ra,0x2
    3960:	a8c080e7          	jalr	-1396(ra) # 53e8 <chdir>
    unlink("irefd");
    3964:	854a                	mv	a0,s2
    3966:	00002097          	auipc	ra,0x2
    396a:	a62080e7          	jalr	-1438(ra) # 53c8 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    396e:	34fd                	addiw	s1,s1,-1
    3970:	f4ed                	bnez	s1,395a <iref+0xfe>
  chdir("/");
    3972:	00003517          	auipc	a0,0x3
    3976:	38650513          	addi	a0,a0,902 # 6cf8 <malloc+0x154a>
    397a:	00002097          	auipc	ra,0x2
    397e:	a6e080e7          	jalr	-1426(ra) # 53e8 <chdir>
}
    3982:	70e2                	ld	ra,56(sp)
    3984:	7442                	ld	s0,48(sp)
    3986:	74a2                	ld	s1,40(sp)
    3988:	7902                	ld	s2,32(sp)
    398a:	69e2                	ld	s3,24(sp)
    398c:	6a42                	ld	s4,16(sp)
    398e:	6aa2                	ld	s5,8(sp)
    3990:	6b02                	ld	s6,0(sp)
    3992:	6121                	addi	sp,sp,64
    3994:	8082                	ret

0000000000003996 <openiputtest>:
{
    3996:	7179                	addi	sp,sp,-48
    3998:	f406                	sd	ra,40(sp)
    399a:	f022                	sd	s0,32(sp)
    399c:	ec26                	sd	s1,24(sp)
    399e:	1800                	addi	s0,sp,48
    39a0:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    39a2:	00004517          	auipc	a0,0x4
    39a6:	b6650513          	addi	a0,a0,-1178 # 7508 <malloc+0x1d5a>
    39aa:	00002097          	auipc	ra,0x2
    39ae:	a36080e7          	jalr	-1482(ra) # 53e0 <mkdir>
    39b2:	04054263          	bltz	a0,39f6 <openiputtest+0x60>
  pid = fork();
    39b6:	00002097          	auipc	ra,0x2
    39ba:	9ba080e7          	jalr	-1606(ra) # 5370 <fork>
  if(pid < 0){
    39be:	04054a63          	bltz	a0,3a12 <openiputtest+0x7c>
  if(pid == 0){
    39c2:	e93d                	bnez	a0,3a38 <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    39c4:	4589                	li	a1,2
    39c6:	00004517          	auipc	a0,0x4
    39ca:	b4250513          	addi	a0,a0,-1214 # 7508 <malloc+0x1d5a>
    39ce:	00002097          	auipc	ra,0x2
    39d2:	9ea080e7          	jalr	-1558(ra) # 53b8 <open>
    if(fd >= 0){
    39d6:	04054c63          	bltz	a0,3a2e <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    39da:	85a6                	mv	a1,s1
    39dc:	00004517          	auipc	a0,0x4
    39e0:	b4c50513          	addi	a0,a0,-1204 # 7528 <malloc+0x1d7a>
    39e4:	00002097          	auipc	ra,0x2
    39e8:	d0c080e7          	jalr	-756(ra) # 56f0 <printf>
      exit(1);
    39ec:	4505                	li	a0,1
    39ee:	00002097          	auipc	ra,0x2
    39f2:	98a080e7          	jalr	-1654(ra) # 5378 <exit>
    printf("%s: mkdir oidir failed\n", s);
    39f6:	85a6                	mv	a1,s1
    39f8:	00004517          	auipc	a0,0x4
    39fc:	b1850513          	addi	a0,a0,-1256 # 7510 <malloc+0x1d62>
    3a00:	00002097          	auipc	ra,0x2
    3a04:	cf0080e7          	jalr	-784(ra) # 56f0 <printf>
    exit(1);
    3a08:	4505                	li	a0,1
    3a0a:	00002097          	auipc	ra,0x2
    3a0e:	96e080e7          	jalr	-1682(ra) # 5378 <exit>
    printf("%s: fork failed\n", s);
    3a12:	85a6                	mv	a1,s1
    3a14:	00003517          	auipc	a0,0x3
    3a18:	9f450513          	addi	a0,a0,-1548 # 6408 <malloc+0xc5a>
    3a1c:	00002097          	auipc	ra,0x2
    3a20:	cd4080e7          	jalr	-812(ra) # 56f0 <printf>
    exit(1);
    3a24:	4505                	li	a0,1
    3a26:	00002097          	auipc	ra,0x2
    3a2a:	952080e7          	jalr	-1710(ra) # 5378 <exit>
    exit(0);
    3a2e:	4501                	li	a0,0
    3a30:	00002097          	auipc	ra,0x2
    3a34:	948080e7          	jalr	-1720(ra) # 5378 <exit>
  sleep(1);
    3a38:	4505                	li	a0,1
    3a3a:	00002097          	auipc	ra,0x2
    3a3e:	9ce080e7          	jalr	-1586(ra) # 5408 <sleep>
  if(unlink("oidir") != 0){
    3a42:	00004517          	auipc	a0,0x4
    3a46:	ac650513          	addi	a0,a0,-1338 # 7508 <malloc+0x1d5a>
    3a4a:	00002097          	auipc	ra,0x2
    3a4e:	97e080e7          	jalr	-1666(ra) # 53c8 <unlink>
    3a52:	cd19                	beqz	a0,3a70 <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    3a54:	85a6                	mv	a1,s1
    3a56:	00003517          	auipc	a0,0x3
    3a5a:	ba250513          	addi	a0,a0,-1118 # 65f8 <malloc+0xe4a>
    3a5e:	00002097          	auipc	ra,0x2
    3a62:	c92080e7          	jalr	-878(ra) # 56f0 <printf>
    exit(1);
    3a66:	4505                	li	a0,1
    3a68:	00002097          	auipc	ra,0x2
    3a6c:	910080e7          	jalr	-1776(ra) # 5378 <exit>
  wait(&xstatus);
    3a70:	fdc40513          	addi	a0,s0,-36
    3a74:	00002097          	auipc	ra,0x2
    3a78:	90c080e7          	jalr	-1780(ra) # 5380 <wait>
  exit(xstatus);
    3a7c:	fdc42503          	lw	a0,-36(s0)
    3a80:	00002097          	auipc	ra,0x2
    3a84:	8f8080e7          	jalr	-1800(ra) # 5378 <exit>

0000000000003a88 <forkforkfork>:
{
    3a88:	1101                	addi	sp,sp,-32
    3a8a:	ec06                	sd	ra,24(sp)
    3a8c:	e822                	sd	s0,16(sp)
    3a8e:	e426                	sd	s1,8(sp)
    3a90:	1000                	addi	s0,sp,32
    3a92:	84aa                	mv	s1,a0
  unlink("stopforking");
    3a94:	00004517          	auipc	a0,0x4
    3a98:	abc50513          	addi	a0,a0,-1348 # 7550 <malloc+0x1da2>
    3a9c:	00002097          	auipc	ra,0x2
    3aa0:	92c080e7          	jalr	-1748(ra) # 53c8 <unlink>
  int pid = fork();
    3aa4:	00002097          	auipc	ra,0x2
    3aa8:	8cc080e7          	jalr	-1844(ra) # 5370 <fork>
  if(pid < 0){
    3aac:	04054563          	bltz	a0,3af6 <forkforkfork+0x6e>
  if(pid == 0){
    3ab0:	c12d                	beqz	a0,3b12 <forkforkfork+0x8a>
  sleep(20); // two seconds
    3ab2:	4551                	li	a0,20
    3ab4:	00002097          	auipc	ra,0x2
    3ab8:	954080e7          	jalr	-1708(ra) # 5408 <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
    3abc:	20200593          	li	a1,514
    3ac0:	00004517          	auipc	a0,0x4
    3ac4:	a9050513          	addi	a0,a0,-1392 # 7550 <malloc+0x1da2>
    3ac8:	00002097          	auipc	ra,0x2
    3acc:	8f0080e7          	jalr	-1808(ra) # 53b8 <open>
    3ad0:	00002097          	auipc	ra,0x2
    3ad4:	8d0080e7          	jalr	-1840(ra) # 53a0 <close>
  wait(0);
    3ad8:	4501                	li	a0,0
    3ada:	00002097          	auipc	ra,0x2
    3ade:	8a6080e7          	jalr	-1882(ra) # 5380 <wait>
  sleep(10); // one second
    3ae2:	4529                	li	a0,10
    3ae4:	00002097          	auipc	ra,0x2
    3ae8:	924080e7          	jalr	-1756(ra) # 5408 <sleep>
}
    3aec:	60e2                	ld	ra,24(sp)
    3aee:	6442                	ld	s0,16(sp)
    3af0:	64a2                	ld	s1,8(sp)
    3af2:	6105                	addi	sp,sp,32
    3af4:	8082                	ret
    printf("%s: fork failed", s);
    3af6:	85a6                	mv	a1,s1
    3af8:	00003517          	auipc	a0,0x3
    3afc:	ad050513          	addi	a0,a0,-1328 # 65c8 <malloc+0xe1a>
    3b00:	00002097          	auipc	ra,0x2
    3b04:	bf0080e7          	jalr	-1040(ra) # 56f0 <printf>
    exit(1);
    3b08:	4505                	li	a0,1
    3b0a:	00002097          	auipc	ra,0x2
    3b0e:	86e080e7          	jalr	-1938(ra) # 5378 <exit>
      int fd = open("stopforking", 0);
    3b12:	00004497          	auipc	s1,0x4
    3b16:	a3e48493          	addi	s1,s1,-1474 # 7550 <malloc+0x1da2>
    3b1a:	4581                	li	a1,0
    3b1c:	8526                	mv	a0,s1
    3b1e:	00002097          	auipc	ra,0x2
    3b22:	89a080e7          	jalr	-1894(ra) # 53b8 <open>
      if(fd >= 0){
    3b26:	02055463          	bgez	a0,3b4e <forkforkfork+0xc6>
      if(fork() < 0){
    3b2a:	00002097          	auipc	ra,0x2
    3b2e:	846080e7          	jalr	-1978(ra) # 5370 <fork>
    3b32:	fe0554e3          	bgez	a0,3b1a <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
    3b36:	20200593          	li	a1,514
    3b3a:	8526                	mv	a0,s1
    3b3c:	00002097          	auipc	ra,0x2
    3b40:	87c080e7          	jalr	-1924(ra) # 53b8 <open>
    3b44:	00002097          	auipc	ra,0x2
    3b48:	85c080e7          	jalr	-1956(ra) # 53a0 <close>
    3b4c:	b7f9                	j	3b1a <forkforkfork+0x92>
        exit(0);
    3b4e:	4501                	li	a0,0
    3b50:	00002097          	auipc	ra,0x2
    3b54:	828080e7          	jalr	-2008(ra) # 5378 <exit>

0000000000003b58 <preempt>:
{
    3b58:	7139                	addi	sp,sp,-64
    3b5a:	fc06                	sd	ra,56(sp)
    3b5c:	f822                	sd	s0,48(sp)
    3b5e:	f426                	sd	s1,40(sp)
    3b60:	f04a                	sd	s2,32(sp)
    3b62:	ec4e                	sd	s3,24(sp)
    3b64:	e852                	sd	s4,16(sp)
    3b66:	0080                	addi	s0,sp,64
    3b68:	8a2a                	mv	s4,a0
  pid1 = fork();
    3b6a:	00002097          	auipc	ra,0x2
    3b6e:	806080e7          	jalr	-2042(ra) # 5370 <fork>
  if(pid1 < 0) {
    3b72:	00054563          	bltz	a0,3b7c <preempt+0x24>
    3b76:	89aa                	mv	s3,a0
  if(pid1 == 0)
    3b78:	ed19                	bnez	a0,3b96 <preempt+0x3e>
    for(;;)
    3b7a:	a001                	j	3b7a <preempt+0x22>
    printf("%s: fork failed");
    3b7c:	00003517          	auipc	a0,0x3
    3b80:	a4c50513          	addi	a0,a0,-1460 # 65c8 <malloc+0xe1a>
    3b84:	00002097          	auipc	ra,0x2
    3b88:	b6c080e7          	jalr	-1172(ra) # 56f0 <printf>
    exit(1);
    3b8c:	4505                	li	a0,1
    3b8e:	00001097          	auipc	ra,0x1
    3b92:	7ea080e7          	jalr	2026(ra) # 5378 <exit>
  pid2 = fork();
    3b96:	00001097          	auipc	ra,0x1
    3b9a:	7da080e7          	jalr	2010(ra) # 5370 <fork>
    3b9e:	892a                	mv	s2,a0
  if(pid2 < 0) {
    3ba0:	00054463          	bltz	a0,3ba8 <preempt+0x50>
  if(pid2 == 0)
    3ba4:	e105                	bnez	a0,3bc4 <preempt+0x6c>
    for(;;)
    3ba6:	a001                	j	3ba6 <preempt+0x4e>
    printf("%s: fork failed\n", s);
    3ba8:	85d2                	mv	a1,s4
    3baa:	00003517          	auipc	a0,0x3
    3bae:	85e50513          	addi	a0,a0,-1954 # 6408 <malloc+0xc5a>
    3bb2:	00002097          	auipc	ra,0x2
    3bb6:	b3e080e7          	jalr	-1218(ra) # 56f0 <printf>
    exit(1);
    3bba:	4505                	li	a0,1
    3bbc:	00001097          	auipc	ra,0x1
    3bc0:	7bc080e7          	jalr	1980(ra) # 5378 <exit>
  pipe(pfds);
    3bc4:	fc840513          	addi	a0,s0,-56
    3bc8:	00001097          	auipc	ra,0x1
    3bcc:	7c0080e7          	jalr	1984(ra) # 5388 <pipe>
  pid3 = fork();
    3bd0:	00001097          	auipc	ra,0x1
    3bd4:	7a0080e7          	jalr	1952(ra) # 5370 <fork>
    3bd8:	84aa                	mv	s1,a0
  if(pid3 < 0) {
    3bda:	02054e63          	bltz	a0,3c16 <preempt+0xbe>
  if(pid3 == 0){
    3bde:	e13d                	bnez	a0,3c44 <preempt+0xec>
    close(pfds[0]);
    3be0:	fc842503          	lw	a0,-56(s0)
    3be4:	00001097          	auipc	ra,0x1
    3be8:	7bc080e7          	jalr	1980(ra) # 53a0 <close>
    if(write(pfds[1], "x", 1) != 1)
    3bec:	4605                	li	a2,1
    3bee:	00002597          	auipc	a1,0x2
    3bf2:	05258593          	addi	a1,a1,82 # 5c40 <malloc+0x492>
    3bf6:	fcc42503          	lw	a0,-52(s0)
    3bfa:	00001097          	auipc	ra,0x1
    3bfe:	79e080e7          	jalr	1950(ra) # 5398 <write>
    3c02:	4785                	li	a5,1
    3c04:	02f51763          	bne	a0,a5,3c32 <preempt+0xda>
    close(pfds[1]);
    3c08:	fcc42503          	lw	a0,-52(s0)
    3c0c:	00001097          	auipc	ra,0x1
    3c10:	794080e7          	jalr	1940(ra) # 53a0 <close>
    for(;;)
    3c14:	a001                	j	3c14 <preempt+0xbc>
     printf("%s: fork failed\n", s);
    3c16:	85d2                	mv	a1,s4
    3c18:	00002517          	auipc	a0,0x2
    3c1c:	7f050513          	addi	a0,a0,2032 # 6408 <malloc+0xc5a>
    3c20:	00002097          	auipc	ra,0x2
    3c24:	ad0080e7          	jalr	-1328(ra) # 56f0 <printf>
     exit(1);
    3c28:	4505                	li	a0,1
    3c2a:	00001097          	auipc	ra,0x1
    3c2e:	74e080e7          	jalr	1870(ra) # 5378 <exit>
      printf("%s: preempt write error");
    3c32:	00004517          	auipc	a0,0x4
    3c36:	92e50513          	addi	a0,a0,-1746 # 7560 <malloc+0x1db2>
    3c3a:	00002097          	auipc	ra,0x2
    3c3e:	ab6080e7          	jalr	-1354(ra) # 56f0 <printf>
    3c42:	b7d9                	j	3c08 <preempt+0xb0>
  close(pfds[1]);
    3c44:	fcc42503          	lw	a0,-52(s0)
    3c48:	00001097          	auipc	ra,0x1
    3c4c:	758080e7          	jalr	1880(ra) # 53a0 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    3c50:	660d                	lui	a2,0x3
    3c52:	00008597          	auipc	a1,0x8
    3c56:	ae658593          	addi	a1,a1,-1306 # b738 <buf>
    3c5a:	fc842503          	lw	a0,-56(s0)
    3c5e:	00001097          	auipc	ra,0x1
    3c62:	732080e7          	jalr	1842(ra) # 5390 <read>
    3c66:	4785                	li	a5,1
    3c68:	02f50263          	beq	a0,a5,3c8c <preempt+0x134>
    printf("%s: preempt read error");
    3c6c:	00004517          	auipc	a0,0x4
    3c70:	90c50513          	addi	a0,a0,-1780 # 7578 <malloc+0x1dca>
    3c74:	00002097          	auipc	ra,0x2
    3c78:	a7c080e7          	jalr	-1412(ra) # 56f0 <printf>
}
    3c7c:	70e2                	ld	ra,56(sp)
    3c7e:	7442                	ld	s0,48(sp)
    3c80:	74a2                	ld	s1,40(sp)
    3c82:	7902                	ld	s2,32(sp)
    3c84:	69e2                	ld	s3,24(sp)
    3c86:	6a42                	ld	s4,16(sp)
    3c88:	6121                	addi	sp,sp,64
    3c8a:	8082                	ret
  close(pfds[0]);
    3c8c:	fc842503          	lw	a0,-56(s0)
    3c90:	00001097          	auipc	ra,0x1
    3c94:	710080e7          	jalr	1808(ra) # 53a0 <close>
  printf("kill... ");
    3c98:	00004517          	auipc	a0,0x4
    3c9c:	8f850513          	addi	a0,a0,-1800 # 7590 <malloc+0x1de2>
    3ca0:	00002097          	auipc	ra,0x2
    3ca4:	a50080e7          	jalr	-1456(ra) # 56f0 <printf>
  kill(pid1);
    3ca8:	854e                	mv	a0,s3
    3caa:	00001097          	auipc	ra,0x1
    3cae:	6fe080e7          	jalr	1790(ra) # 53a8 <kill>
  kill(pid2);
    3cb2:	854a                	mv	a0,s2
    3cb4:	00001097          	auipc	ra,0x1
    3cb8:	6f4080e7          	jalr	1780(ra) # 53a8 <kill>
  kill(pid3);
    3cbc:	8526                	mv	a0,s1
    3cbe:	00001097          	auipc	ra,0x1
    3cc2:	6ea080e7          	jalr	1770(ra) # 53a8 <kill>
  printf("wait... ");
    3cc6:	00004517          	auipc	a0,0x4
    3cca:	8da50513          	addi	a0,a0,-1830 # 75a0 <malloc+0x1df2>
    3cce:	00002097          	auipc	ra,0x2
    3cd2:	a22080e7          	jalr	-1502(ra) # 56f0 <printf>
  wait(0);
    3cd6:	4501                	li	a0,0
    3cd8:	00001097          	auipc	ra,0x1
    3cdc:	6a8080e7          	jalr	1704(ra) # 5380 <wait>
  wait(0);
    3ce0:	4501                	li	a0,0
    3ce2:	00001097          	auipc	ra,0x1
    3ce6:	69e080e7          	jalr	1694(ra) # 5380 <wait>
  wait(0);
    3cea:	4501                	li	a0,0
    3cec:	00001097          	auipc	ra,0x1
    3cf0:	694080e7          	jalr	1684(ra) # 5380 <wait>
    3cf4:	b761                	j	3c7c <preempt+0x124>

0000000000003cf6 <sbrkfail>:
{
    3cf6:	7119                	addi	sp,sp,-128
    3cf8:	fc86                	sd	ra,120(sp)
    3cfa:	f8a2                	sd	s0,112(sp)
    3cfc:	f4a6                	sd	s1,104(sp)
    3cfe:	f0ca                	sd	s2,96(sp)
    3d00:	ecce                	sd	s3,88(sp)
    3d02:	e8d2                	sd	s4,80(sp)
    3d04:	e4d6                	sd	s5,72(sp)
    3d06:	0100                	addi	s0,sp,128
    3d08:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    3d0a:	fb040513          	addi	a0,s0,-80
    3d0e:	00001097          	auipc	ra,0x1
    3d12:	67a080e7          	jalr	1658(ra) # 5388 <pipe>
    3d16:	e901                	bnez	a0,3d26 <sbrkfail+0x30>
    3d18:	f8040493          	addi	s1,s0,-128
    3d1c:	fa840a13          	addi	s4,s0,-88
    3d20:	89a6                	mv	s3,s1
    if(pids[i] != -1)
    3d22:	5afd                	li	s5,-1
    3d24:	a08d                	j	3d86 <sbrkfail+0x90>
    printf("%s: pipe() failed\n", s);
    3d26:	85ca                	mv	a1,s2
    3d28:	00002517          	auipc	a0,0x2
    3d2c:	7e850513          	addi	a0,a0,2024 # 6510 <malloc+0xd62>
    3d30:	00002097          	auipc	ra,0x2
    3d34:	9c0080e7          	jalr	-1600(ra) # 56f0 <printf>
    exit(1);
    3d38:	4505                	li	a0,1
    3d3a:	00001097          	auipc	ra,0x1
    3d3e:	63e080e7          	jalr	1598(ra) # 5378 <exit>
      sbrk(BIG - (uint64)sbrk(0));
    3d42:	4501                	li	a0,0
    3d44:	00001097          	auipc	ra,0x1
    3d48:	6bc080e7          	jalr	1724(ra) # 5400 <sbrk>
    3d4c:	064007b7          	lui	a5,0x6400
    3d50:	40a7853b          	subw	a0,a5,a0
    3d54:	00001097          	auipc	ra,0x1
    3d58:	6ac080e7          	jalr	1708(ra) # 5400 <sbrk>
      write(fds[1], "x", 1);
    3d5c:	4605                	li	a2,1
    3d5e:	00002597          	auipc	a1,0x2
    3d62:	ee258593          	addi	a1,a1,-286 # 5c40 <malloc+0x492>
    3d66:	fb442503          	lw	a0,-76(s0)
    3d6a:	00001097          	auipc	ra,0x1
    3d6e:	62e080e7          	jalr	1582(ra) # 5398 <write>
      for(;;) sleep(1000);
    3d72:	3e800513          	li	a0,1000
    3d76:	00001097          	auipc	ra,0x1
    3d7a:	692080e7          	jalr	1682(ra) # 5408 <sleep>
    3d7e:	bfd5                	j	3d72 <sbrkfail+0x7c>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3d80:	0991                	addi	s3,s3,4
    3d82:	03498563          	beq	s3,s4,3dac <sbrkfail+0xb6>
    if((pids[i] = fork()) == 0){
    3d86:	00001097          	auipc	ra,0x1
    3d8a:	5ea080e7          	jalr	1514(ra) # 5370 <fork>
    3d8e:	00a9a023          	sw	a0,0(s3)
    3d92:	d945                	beqz	a0,3d42 <sbrkfail+0x4c>
    if(pids[i] != -1)
    3d94:	ff5506e3          	beq	a0,s5,3d80 <sbrkfail+0x8a>
      read(fds[0], &scratch, 1);
    3d98:	4605                	li	a2,1
    3d9a:	faf40593          	addi	a1,s0,-81
    3d9e:	fb042503          	lw	a0,-80(s0)
    3da2:	00001097          	auipc	ra,0x1
    3da6:	5ee080e7          	jalr	1518(ra) # 5390 <read>
    3daa:	bfd9                	j	3d80 <sbrkfail+0x8a>
  c = sbrk(PGSIZE);
    3dac:	6505                	lui	a0,0x1
    3dae:	00001097          	auipc	ra,0x1
    3db2:	652080e7          	jalr	1618(ra) # 5400 <sbrk>
    3db6:	89aa                	mv	s3,a0
    if(pids[i] == -1)
    3db8:	5afd                	li	s5,-1
    3dba:	a021                	j	3dc2 <sbrkfail+0xcc>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3dbc:	0491                	addi	s1,s1,4
    3dbe:	01448f63          	beq	s1,s4,3ddc <sbrkfail+0xe6>
    if(pids[i] == -1)
    3dc2:	4088                	lw	a0,0(s1)
    3dc4:	ff550ce3          	beq	a0,s5,3dbc <sbrkfail+0xc6>
    kill(pids[i]);
    3dc8:	00001097          	auipc	ra,0x1
    3dcc:	5e0080e7          	jalr	1504(ra) # 53a8 <kill>
    wait(0);
    3dd0:	4501                	li	a0,0
    3dd2:	00001097          	auipc	ra,0x1
    3dd6:	5ae080e7          	jalr	1454(ra) # 5380 <wait>
    3dda:	b7cd                	j	3dbc <sbrkfail+0xc6>
  if(c == (char*)0xffffffffffffffffL){
    3ddc:	57fd                	li	a5,-1
    3dde:	04f98163          	beq	s3,a5,3e20 <sbrkfail+0x12a>
  pid = fork();
    3de2:	00001097          	auipc	ra,0x1
    3de6:	58e080e7          	jalr	1422(ra) # 5370 <fork>
    3dea:	84aa                	mv	s1,a0
  if(pid < 0){
    3dec:	04054863          	bltz	a0,3e3c <sbrkfail+0x146>
  if(pid == 0){
    3df0:	c525                	beqz	a0,3e58 <sbrkfail+0x162>
  wait(&xstatus);
    3df2:	fbc40513          	addi	a0,s0,-68
    3df6:	00001097          	auipc	ra,0x1
    3dfa:	58a080e7          	jalr	1418(ra) # 5380 <wait>
  if(xstatus != -1 && xstatus != 2)
    3dfe:	fbc42783          	lw	a5,-68(s0)
    3e02:	577d                	li	a4,-1
    3e04:	00e78563          	beq	a5,a4,3e0e <sbrkfail+0x118>
    3e08:	4709                	li	a4,2
    3e0a:	08e79c63          	bne	a5,a4,3ea2 <sbrkfail+0x1ac>
}
    3e0e:	70e6                	ld	ra,120(sp)
    3e10:	7446                	ld	s0,112(sp)
    3e12:	74a6                	ld	s1,104(sp)
    3e14:	7906                	ld	s2,96(sp)
    3e16:	69e6                	ld	s3,88(sp)
    3e18:	6a46                	ld	s4,80(sp)
    3e1a:	6aa6                	ld	s5,72(sp)
    3e1c:	6109                	addi	sp,sp,128
    3e1e:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    3e20:	85ca                	mv	a1,s2
    3e22:	00003517          	auipc	a0,0x3
    3e26:	78e50513          	addi	a0,a0,1934 # 75b0 <malloc+0x1e02>
    3e2a:	00002097          	auipc	ra,0x2
    3e2e:	8c6080e7          	jalr	-1850(ra) # 56f0 <printf>
    exit(1);
    3e32:	4505                	li	a0,1
    3e34:	00001097          	auipc	ra,0x1
    3e38:	544080e7          	jalr	1348(ra) # 5378 <exit>
    printf("%s: fork failed\n", s);
    3e3c:	85ca                	mv	a1,s2
    3e3e:	00002517          	auipc	a0,0x2
    3e42:	5ca50513          	addi	a0,a0,1482 # 6408 <malloc+0xc5a>
    3e46:	00002097          	auipc	ra,0x2
    3e4a:	8aa080e7          	jalr	-1878(ra) # 56f0 <printf>
    exit(1);
    3e4e:	4505                	li	a0,1
    3e50:	00001097          	auipc	ra,0x1
    3e54:	528080e7          	jalr	1320(ra) # 5378 <exit>
    a = sbrk(0);
    3e58:	4501                	li	a0,0
    3e5a:	00001097          	auipc	ra,0x1
    3e5e:	5a6080e7          	jalr	1446(ra) # 5400 <sbrk>
    3e62:	892a                	mv	s2,a0
    sbrk(10*BIG);
    3e64:	3e800537          	lui	a0,0x3e800
    3e68:	00001097          	auipc	ra,0x1
    3e6c:	598080e7          	jalr	1432(ra) # 5400 <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    3e70:	874a                	mv	a4,s2
    3e72:	3e8007b7          	lui	a5,0x3e800
    3e76:	97ca                	add	a5,a5,s2
    3e78:	6685                	lui	a3,0x1
      n += *(a+i);
    3e7a:	00074603          	lbu	a2,0(a4)
    3e7e:	9cb1                	addw	s1,s1,a2
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    3e80:	9736                	add	a4,a4,a3
    3e82:	fef71ce3          	bne	a4,a5,3e7a <sbrkfail+0x184>
    printf("%s: allocate a lot of memory succeeded %d\n", n);
    3e86:	85a6                	mv	a1,s1
    3e88:	00003517          	auipc	a0,0x3
    3e8c:	74850513          	addi	a0,a0,1864 # 75d0 <malloc+0x1e22>
    3e90:	00002097          	auipc	ra,0x2
    3e94:	860080e7          	jalr	-1952(ra) # 56f0 <printf>
    exit(1);
    3e98:	4505                	li	a0,1
    3e9a:	00001097          	auipc	ra,0x1
    3e9e:	4de080e7          	jalr	1246(ra) # 5378 <exit>
    exit(1);
    3ea2:	4505                	li	a0,1
    3ea4:	00001097          	auipc	ra,0x1
    3ea8:	4d4080e7          	jalr	1236(ra) # 5378 <exit>

0000000000003eac <reparent>:
{
    3eac:	7179                	addi	sp,sp,-48
    3eae:	f406                	sd	ra,40(sp)
    3eb0:	f022                	sd	s0,32(sp)
    3eb2:	ec26                	sd	s1,24(sp)
    3eb4:	e84a                	sd	s2,16(sp)
    3eb6:	e44e                	sd	s3,8(sp)
    3eb8:	e052                	sd	s4,0(sp)
    3eba:	1800                	addi	s0,sp,48
    3ebc:	89aa                	mv	s3,a0
  int master_pid = getpid();
    3ebe:	00001097          	auipc	ra,0x1
    3ec2:	53a080e7          	jalr	1338(ra) # 53f8 <getpid>
    3ec6:	8a2a                	mv	s4,a0
    3ec8:	0c800913          	li	s2,200
    int pid = fork();
    3ecc:	00001097          	auipc	ra,0x1
    3ed0:	4a4080e7          	jalr	1188(ra) # 5370 <fork>
    3ed4:	84aa                	mv	s1,a0
    if(pid < 0){
    3ed6:	02054263          	bltz	a0,3efa <reparent+0x4e>
    if(pid){
    3eda:	cd21                	beqz	a0,3f32 <reparent+0x86>
      if(wait(0) != pid){
    3edc:	4501                	li	a0,0
    3ede:	00001097          	auipc	ra,0x1
    3ee2:	4a2080e7          	jalr	1186(ra) # 5380 <wait>
    3ee6:	02951863          	bne	a0,s1,3f16 <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    3eea:	397d                	addiw	s2,s2,-1
    3eec:	fe0910e3          	bnez	s2,3ecc <reparent+0x20>
  exit(0);
    3ef0:	4501                	li	a0,0
    3ef2:	00001097          	auipc	ra,0x1
    3ef6:	486080e7          	jalr	1158(ra) # 5378 <exit>
      printf("%s: fork failed\n", s);
    3efa:	85ce                	mv	a1,s3
    3efc:	00002517          	auipc	a0,0x2
    3f00:	50c50513          	addi	a0,a0,1292 # 6408 <malloc+0xc5a>
    3f04:	00001097          	auipc	ra,0x1
    3f08:	7ec080e7          	jalr	2028(ra) # 56f0 <printf>
      exit(1);
    3f0c:	4505                	li	a0,1
    3f0e:	00001097          	auipc	ra,0x1
    3f12:	46a080e7          	jalr	1130(ra) # 5378 <exit>
        printf("%s: wait wrong pid\n", s);
    3f16:	85ce                	mv	a1,s3
    3f18:	00002517          	auipc	a0,0x2
    3f1c:	67850513          	addi	a0,a0,1656 # 6590 <malloc+0xde2>
    3f20:	00001097          	auipc	ra,0x1
    3f24:	7d0080e7          	jalr	2000(ra) # 56f0 <printf>
        exit(1);
    3f28:	4505                	li	a0,1
    3f2a:	00001097          	auipc	ra,0x1
    3f2e:	44e080e7          	jalr	1102(ra) # 5378 <exit>
      int pid2 = fork();
    3f32:	00001097          	auipc	ra,0x1
    3f36:	43e080e7          	jalr	1086(ra) # 5370 <fork>
      if(pid2 < 0){
    3f3a:	00054763          	bltz	a0,3f48 <reparent+0x9c>
      exit(0);
    3f3e:	4501                	li	a0,0
    3f40:	00001097          	auipc	ra,0x1
    3f44:	438080e7          	jalr	1080(ra) # 5378 <exit>
        kill(master_pid);
    3f48:	8552                	mv	a0,s4
    3f4a:	00001097          	auipc	ra,0x1
    3f4e:	45e080e7          	jalr	1118(ra) # 53a8 <kill>
        exit(1);
    3f52:	4505                	li	a0,1
    3f54:	00001097          	auipc	ra,0x1
    3f58:	424080e7          	jalr	1060(ra) # 5378 <exit>

0000000000003f5c <mem>:
{
    3f5c:	7139                	addi	sp,sp,-64
    3f5e:	fc06                	sd	ra,56(sp)
    3f60:	f822                	sd	s0,48(sp)
    3f62:	f426                	sd	s1,40(sp)
    3f64:	f04a                	sd	s2,32(sp)
    3f66:	ec4e                	sd	s3,24(sp)
    3f68:	0080                	addi	s0,sp,64
    3f6a:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    3f6c:	00001097          	auipc	ra,0x1
    3f70:	404080e7          	jalr	1028(ra) # 5370 <fork>
    m1 = 0;
    3f74:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    3f76:	6909                	lui	s2,0x2
    3f78:	71190913          	addi	s2,s2,1809 # 2711 <sbrkarg+0xbd>
  if((pid = fork()) == 0){
    3f7c:	ed39                	bnez	a0,3fda <mem+0x7e>
    while((m2 = malloc(10001)) != 0){
    3f7e:	854a                	mv	a0,s2
    3f80:	00002097          	auipc	ra,0x2
    3f84:	82e080e7          	jalr	-2002(ra) # 57ae <malloc>
    3f88:	c501                	beqz	a0,3f90 <mem+0x34>
      *(char**)m2 = m1;
    3f8a:	e104                	sd	s1,0(a0)
      m1 = m2;
    3f8c:	84aa                	mv	s1,a0
    3f8e:	bfc5                	j	3f7e <mem+0x22>
    while(m1){
    3f90:	c881                	beqz	s1,3fa0 <mem+0x44>
      m2 = *(char**)m1;
    3f92:	8526                	mv	a0,s1
    3f94:	6084                	ld	s1,0(s1)
      free(m1);
    3f96:	00001097          	auipc	ra,0x1
    3f9a:	790080e7          	jalr	1936(ra) # 5726 <free>
    while(m1){
    3f9e:	f8f5                	bnez	s1,3f92 <mem+0x36>
    m1 = malloc(1024*20);
    3fa0:	6515                	lui	a0,0x5
    3fa2:	00002097          	auipc	ra,0x2
    3fa6:	80c080e7          	jalr	-2036(ra) # 57ae <malloc>
    if(m1 == 0){
    3faa:	c911                	beqz	a0,3fbe <mem+0x62>
    free(m1);
    3fac:	00001097          	auipc	ra,0x1
    3fb0:	77a080e7          	jalr	1914(ra) # 5726 <free>
    exit(0);
    3fb4:	4501                	li	a0,0
    3fb6:	00001097          	auipc	ra,0x1
    3fba:	3c2080e7          	jalr	962(ra) # 5378 <exit>
      printf("couldn't allocate mem?!!\n", s);
    3fbe:	85ce                	mv	a1,s3
    3fc0:	00003517          	auipc	a0,0x3
    3fc4:	64050513          	addi	a0,a0,1600 # 7600 <malloc+0x1e52>
    3fc8:	00001097          	auipc	ra,0x1
    3fcc:	728080e7          	jalr	1832(ra) # 56f0 <printf>
      exit(1);
    3fd0:	4505                	li	a0,1
    3fd2:	00001097          	auipc	ra,0x1
    3fd6:	3a6080e7          	jalr	934(ra) # 5378 <exit>
    wait(&xstatus);
    3fda:	fcc40513          	addi	a0,s0,-52
    3fde:	00001097          	auipc	ra,0x1
    3fe2:	3a2080e7          	jalr	930(ra) # 5380 <wait>
    if(xstatus == -1){
    3fe6:	fcc42503          	lw	a0,-52(s0)
    3fea:	57fd                	li	a5,-1
    3fec:	00f50663          	beq	a0,a5,3ff8 <mem+0x9c>
    exit(xstatus);
    3ff0:	00001097          	auipc	ra,0x1
    3ff4:	388080e7          	jalr	904(ra) # 5378 <exit>
      exit(0);
    3ff8:	4501                	li	a0,0
    3ffa:	00001097          	auipc	ra,0x1
    3ffe:	37e080e7          	jalr	894(ra) # 5378 <exit>

0000000000004002 <sharedfd>:
{
    4002:	7159                	addi	sp,sp,-112
    4004:	f486                	sd	ra,104(sp)
    4006:	f0a2                	sd	s0,96(sp)
    4008:	eca6                	sd	s1,88(sp)
    400a:	e8ca                	sd	s2,80(sp)
    400c:	e4ce                	sd	s3,72(sp)
    400e:	e0d2                	sd	s4,64(sp)
    4010:	fc56                	sd	s5,56(sp)
    4012:	f85a                	sd	s6,48(sp)
    4014:	f45e                	sd	s7,40(sp)
    4016:	1880                	addi	s0,sp,112
    4018:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    401a:	00002517          	auipc	a0,0x2
    401e:	9fe50513          	addi	a0,a0,-1538 # 5a18 <malloc+0x26a>
    4022:	00001097          	auipc	ra,0x1
    4026:	3a6080e7          	jalr	934(ra) # 53c8 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    402a:	20200593          	li	a1,514
    402e:	00002517          	auipc	a0,0x2
    4032:	9ea50513          	addi	a0,a0,-1558 # 5a18 <malloc+0x26a>
    4036:	00001097          	auipc	ra,0x1
    403a:	382080e7          	jalr	898(ra) # 53b8 <open>
  if(fd < 0){
    403e:	04054a63          	bltz	a0,4092 <sharedfd+0x90>
    4042:	892a                	mv	s2,a0
  pid = fork();
    4044:	00001097          	auipc	ra,0x1
    4048:	32c080e7          	jalr	812(ra) # 5370 <fork>
    404c:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    404e:	06300593          	li	a1,99
    4052:	c119                	beqz	a0,4058 <sharedfd+0x56>
    4054:	07000593          	li	a1,112
    4058:	4629                	li	a2,10
    405a:	fa040513          	addi	a0,s0,-96
    405e:	00001097          	auipc	ra,0x1
    4062:	116080e7          	jalr	278(ra) # 5174 <memset>
    4066:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    406a:	4629                	li	a2,10
    406c:	fa040593          	addi	a1,s0,-96
    4070:	854a                	mv	a0,s2
    4072:	00001097          	auipc	ra,0x1
    4076:	326080e7          	jalr	806(ra) # 5398 <write>
    407a:	47a9                	li	a5,10
    407c:	02f51963          	bne	a0,a5,40ae <sharedfd+0xac>
  for(i = 0; i < N; i++){
    4080:	34fd                	addiw	s1,s1,-1
    4082:	f4e5                	bnez	s1,406a <sharedfd+0x68>
  if(pid == 0) {
    4084:	04099363          	bnez	s3,40ca <sharedfd+0xc8>
    exit(0);
    4088:	4501                	li	a0,0
    408a:	00001097          	auipc	ra,0x1
    408e:	2ee080e7          	jalr	750(ra) # 5378 <exit>
    printf("%s: cannot open sharedfd for writing", s);
    4092:	85d2                	mv	a1,s4
    4094:	00003517          	auipc	a0,0x3
    4098:	58c50513          	addi	a0,a0,1420 # 7620 <malloc+0x1e72>
    409c:	00001097          	auipc	ra,0x1
    40a0:	654080e7          	jalr	1620(ra) # 56f0 <printf>
    exit(1);
    40a4:	4505                	li	a0,1
    40a6:	00001097          	auipc	ra,0x1
    40aa:	2d2080e7          	jalr	722(ra) # 5378 <exit>
      printf("%s: write sharedfd failed\n", s);
    40ae:	85d2                	mv	a1,s4
    40b0:	00003517          	auipc	a0,0x3
    40b4:	59850513          	addi	a0,a0,1432 # 7648 <malloc+0x1e9a>
    40b8:	00001097          	auipc	ra,0x1
    40bc:	638080e7          	jalr	1592(ra) # 56f0 <printf>
      exit(1);
    40c0:	4505                	li	a0,1
    40c2:	00001097          	auipc	ra,0x1
    40c6:	2b6080e7          	jalr	694(ra) # 5378 <exit>
    wait(&xstatus);
    40ca:	f9c40513          	addi	a0,s0,-100
    40ce:	00001097          	auipc	ra,0x1
    40d2:	2b2080e7          	jalr	690(ra) # 5380 <wait>
    if(xstatus != 0)
    40d6:	f9c42983          	lw	s3,-100(s0)
    40da:	00098763          	beqz	s3,40e8 <sharedfd+0xe6>
      exit(xstatus);
    40de:	854e                	mv	a0,s3
    40e0:	00001097          	auipc	ra,0x1
    40e4:	298080e7          	jalr	664(ra) # 5378 <exit>
  close(fd);
    40e8:	854a                	mv	a0,s2
    40ea:	00001097          	auipc	ra,0x1
    40ee:	2b6080e7          	jalr	694(ra) # 53a0 <close>
  fd = open("sharedfd", 0);
    40f2:	4581                	li	a1,0
    40f4:	00002517          	auipc	a0,0x2
    40f8:	92450513          	addi	a0,a0,-1756 # 5a18 <malloc+0x26a>
    40fc:	00001097          	auipc	ra,0x1
    4100:	2bc080e7          	jalr	700(ra) # 53b8 <open>
    4104:	8baa                	mv	s7,a0
  nc = np = 0;
    4106:	8ace                	mv	s5,s3
  if(fd < 0){
    4108:	02054563          	bltz	a0,4132 <sharedfd+0x130>
    410c:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    4110:	06300493          	li	s1,99
      if(buf[i] == 'p')
    4114:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    4118:	4629                	li	a2,10
    411a:	fa040593          	addi	a1,s0,-96
    411e:	855e                	mv	a0,s7
    4120:	00001097          	auipc	ra,0x1
    4124:	270080e7          	jalr	624(ra) # 5390 <read>
    4128:	02a05f63          	blez	a0,4166 <sharedfd+0x164>
    412c:	fa040793          	addi	a5,s0,-96
    4130:	a01d                	j	4156 <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    4132:	85d2                	mv	a1,s4
    4134:	00003517          	auipc	a0,0x3
    4138:	53450513          	addi	a0,a0,1332 # 7668 <malloc+0x1eba>
    413c:	00001097          	auipc	ra,0x1
    4140:	5b4080e7          	jalr	1460(ra) # 56f0 <printf>
    exit(1);
    4144:	4505                	li	a0,1
    4146:	00001097          	auipc	ra,0x1
    414a:	232080e7          	jalr	562(ra) # 5378 <exit>
        nc++;
    414e:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    4150:	0785                	addi	a5,a5,1
    4152:	fd2783e3          	beq	a5,s2,4118 <sharedfd+0x116>
      if(buf[i] == 'c')
    4156:	0007c703          	lbu	a4,0(a5) # 3e800000 <__BSS_END__+0x3e7f18b8>
    415a:	fe970ae3          	beq	a4,s1,414e <sharedfd+0x14c>
      if(buf[i] == 'p')
    415e:	ff6719e3          	bne	a4,s6,4150 <sharedfd+0x14e>
        np++;
    4162:	2a85                	addiw	s5,s5,1
    4164:	b7f5                	j	4150 <sharedfd+0x14e>
  close(fd);
    4166:	855e                	mv	a0,s7
    4168:	00001097          	auipc	ra,0x1
    416c:	238080e7          	jalr	568(ra) # 53a0 <close>
  unlink("sharedfd");
    4170:	00002517          	auipc	a0,0x2
    4174:	8a850513          	addi	a0,a0,-1880 # 5a18 <malloc+0x26a>
    4178:	00001097          	auipc	ra,0x1
    417c:	250080e7          	jalr	592(ra) # 53c8 <unlink>
  if(nc == N*SZ && np == N*SZ){
    4180:	6789                	lui	a5,0x2
    4182:	71078793          	addi	a5,a5,1808 # 2710 <sbrkarg+0xbc>
    4186:	00f99763          	bne	s3,a5,4194 <sharedfd+0x192>
    418a:	6789                	lui	a5,0x2
    418c:	71078793          	addi	a5,a5,1808 # 2710 <sbrkarg+0xbc>
    4190:	02fa8063          	beq	s5,a5,41b0 <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    4194:	85d2                	mv	a1,s4
    4196:	00003517          	auipc	a0,0x3
    419a:	4fa50513          	addi	a0,a0,1274 # 7690 <malloc+0x1ee2>
    419e:	00001097          	auipc	ra,0x1
    41a2:	552080e7          	jalr	1362(ra) # 56f0 <printf>
    exit(1);
    41a6:	4505                	li	a0,1
    41a8:	00001097          	auipc	ra,0x1
    41ac:	1d0080e7          	jalr	464(ra) # 5378 <exit>
    exit(0);
    41b0:	4501                	li	a0,0
    41b2:	00001097          	auipc	ra,0x1
    41b6:	1c6080e7          	jalr	454(ra) # 5378 <exit>

00000000000041ba <fourfiles>:
{
    41ba:	7171                	addi	sp,sp,-176
    41bc:	f506                	sd	ra,168(sp)
    41be:	f122                	sd	s0,160(sp)
    41c0:	ed26                	sd	s1,152(sp)
    41c2:	e94a                	sd	s2,144(sp)
    41c4:	e54e                	sd	s3,136(sp)
    41c6:	e152                	sd	s4,128(sp)
    41c8:	fcd6                	sd	s5,120(sp)
    41ca:	f8da                	sd	s6,112(sp)
    41cc:	f4de                	sd	s7,104(sp)
    41ce:	f0e2                	sd	s8,96(sp)
    41d0:	ece6                	sd	s9,88(sp)
    41d2:	e8ea                	sd	s10,80(sp)
    41d4:	e4ee                	sd	s11,72(sp)
    41d6:	1900                	addi	s0,sp,176
    41d8:	8caa                	mv	s9,a0
  char *names[] = { "f0", "f1", "f2", "f3" };
    41da:	00001797          	auipc	a5,0x1
    41de:	6be78793          	addi	a5,a5,1726 # 5898 <malloc+0xea>
    41e2:	f6f43823          	sd	a5,-144(s0)
    41e6:	00001797          	auipc	a5,0x1
    41ea:	6ba78793          	addi	a5,a5,1722 # 58a0 <malloc+0xf2>
    41ee:	f6f43c23          	sd	a5,-136(s0)
    41f2:	00001797          	auipc	a5,0x1
    41f6:	6b678793          	addi	a5,a5,1718 # 58a8 <malloc+0xfa>
    41fa:	f8f43023          	sd	a5,-128(s0)
    41fe:	00001797          	auipc	a5,0x1
    4202:	6b278793          	addi	a5,a5,1714 # 58b0 <malloc+0x102>
    4206:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    420a:	f7040b93          	addi	s7,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    420e:	895e                	mv	s2,s7
  for(pi = 0; pi < NCHILD; pi++){
    4210:	4481                	li	s1,0
    4212:	4a11                	li	s4,4
    fname = names[pi];
    4214:	00093983          	ld	s3,0(s2)
    unlink(fname);
    4218:	854e                	mv	a0,s3
    421a:	00001097          	auipc	ra,0x1
    421e:	1ae080e7          	jalr	430(ra) # 53c8 <unlink>
    pid = fork();
    4222:	00001097          	auipc	ra,0x1
    4226:	14e080e7          	jalr	334(ra) # 5370 <fork>
    if(pid < 0){
    422a:	04054563          	bltz	a0,4274 <fourfiles+0xba>
    if(pid == 0){
    422e:	c12d                	beqz	a0,4290 <fourfiles+0xd6>
  for(pi = 0; pi < NCHILD; pi++){
    4230:	2485                	addiw	s1,s1,1
    4232:	0921                	addi	s2,s2,8
    4234:	ff4490e3          	bne	s1,s4,4214 <fourfiles+0x5a>
    4238:	4491                	li	s1,4
    wait(&xstatus);
    423a:	f6c40513          	addi	a0,s0,-148
    423e:	00001097          	auipc	ra,0x1
    4242:	142080e7          	jalr	322(ra) # 5380 <wait>
    if(xstatus != 0)
    4246:	f6c42503          	lw	a0,-148(s0)
    424a:	ed69                	bnez	a0,4324 <fourfiles+0x16a>
  for(pi = 0; pi < NCHILD; pi++){
    424c:	34fd                	addiw	s1,s1,-1
    424e:	f4f5                	bnez	s1,423a <fourfiles+0x80>
    4250:	03000b13          	li	s6,48
    total = 0;
    4254:	f4a43c23          	sd	a0,-168(s0)
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4258:	00007a17          	auipc	s4,0x7
    425c:	4e0a0a13          	addi	s4,s4,1248 # b738 <buf>
    4260:	00007a97          	auipc	s5,0x7
    4264:	4d9a8a93          	addi	s5,s5,1241 # b739 <buf+0x1>
    if(total != N*SZ){
    4268:	6d05                	lui	s10,0x1
    426a:	770d0d13          	addi	s10,s10,1904 # 1770 <pipe1+0x2a>
  for(i = 0; i < NCHILD; i++){
    426e:	03400d93          	li	s11,52
    4272:	a23d                	j	43a0 <fourfiles+0x1e6>
      printf("fork failed\n", s);
    4274:	85e6                	mv	a1,s9
    4276:	00002517          	auipc	a0,0x2
    427a:	58250513          	addi	a0,a0,1410 # 67f8 <malloc+0x104a>
    427e:	00001097          	auipc	ra,0x1
    4282:	472080e7          	jalr	1138(ra) # 56f0 <printf>
      exit(1);
    4286:	4505                	li	a0,1
    4288:	00001097          	auipc	ra,0x1
    428c:	0f0080e7          	jalr	240(ra) # 5378 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    4290:	20200593          	li	a1,514
    4294:	854e                	mv	a0,s3
    4296:	00001097          	auipc	ra,0x1
    429a:	122080e7          	jalr	290(ra) # 53b8 <open>
    429e:	892a                	mv	s2,a0
      if(fd < 0){
    42a0:	04054763          	bltz	a0,42ee <fourfiles+0x134>
      memset(buf, '0'+pi, SZ);
    42a4:	1f400613          	li	a2,500
    42a8:	0304859b          	addiw	a1,s1,48
    42ac:	00007517          	auipc	a0,0x7
    42b0:	48c50513          	addi	a0,a0,1164 # b738 <buf>
    42b4:	00001097          	auipc	ra,0x1
    42b8:	ec0080e7          	jalr	-320(ra) # 5174 <memset>
    42bc:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    42be:	00007997          	auipc	s3,0x7
    42c2:	47a98993          	addi	s3,s3,1146 # b738 <buf>
    42c6:	1f400613          	li	a2,500
    42ca:	85ce                	mv	a1,s3
    42cc:	854a                	mv	a0,s2
    42ce:	00001097          	auipc	ra,0x1
    42d2:	0ca080e7          	jalr	202(ra) # 5398 <write>
    42d6:	85aa                	mv	a1,a0
    42d8:	1f400793          	li	a5,500
    42dc:	02f51763          	bne	a0,a5,430a <fourfiles+0x150>
      for(i = 0; i < N; i++){
    42e0:	34fd                	addiw	s1,s1,-1
    42e2:	f0f5                	bnez	s1,42c6 <fourfiles+0x10c>
      exit(0);
    42e4:	4501                	li	a0,0
    42e6:	00001097          	auipc	ra,0x1
    42ea:	092080e7          	jalr	146(ra) # 5378 <exit>
        printf("create failed\n", s);
    42ee:	85e6                	mv	a1,s9
    42f0:	00003517          	auipc	a0,0x3
    42f4:	3b850513          	addi	a0,a0,952 # 76a8 <malloc+0x1efa>
    42f8:	00001097          	auipc	ra,0x1
    42fc:	3f8080e7          	jalr	1016(ra) # 56f0 <printf>
        exit(1);
    4300:	4505                	li	a0,1
    4302:	00001097          	auipc	ra,0x1
    4306:	076080e7          	jalr	118(ra) # 5378 <exit>
          printf("write failed %d\n", n);
    430a:	00003517          	auipc	a0,0x3
    430e:	3ae50513          	addi	a0,a0,942 # 76b8 <malloc+0x1f0a>
    4312:	00001097          	auipc	ra,0x1
    4316:	3de080e7          	jalr	990(ra) # 56f0 <printf>
          exit(1);
    431a:	4505                	li	a0,1
    431c:	00001097          	auipc	ra,0x1
    4320:	05c080e7          	jalr	92(ra) # 5378 <exit>
      exit(xstatus);
    4324:	00001097          	auipc	ra,0x1
    4328:	054080e7          	jalr	84(ra) # 5378 <exit>
          printf("wrong char\n", s);
    432c:	85e6                	mv	a1,s9
    432e:	00003517          	auipc	a0,0x3
    4332:	3a250513          	addi	a0,a0,930 # 76d0 <malloc+0x1f22>
    4336:	00001097          	auipc	ra,0x1
    433a:	3ba080e7          	jalr	954(ra) # 56f0 <printf>
          exit(1);
    433e:	4505                	li	a0,1
    4340:	00001097          	auipc	ra,0x1
    4344:	038080e7          	jalr	56(ra) # 5378 <exit>
      total += n;
    4348:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    434c:	660d                	lui	a2,0x3
    434e:	85d2                	mv	a1,s4
    4350:	854e                	mv	a0,s3
    4352:	00001097          	auipc	ra,0x1
    4356:	03e080e7          	jalr	62(ra) # 5390 <read>
    435a:	02a05363          	blez	a0,4380 <fourfiles+0x1c6>
    435e:	00007797          	auipc	a5,0x7
    4362:	3da78793          	addi	a5,a5,986 # b738 <buf>
    4366:	fff5069b          	addiw	a3,a0,-1
    436a:	1682                	slli	a3,a3,0x20
    436c:	9281                	srli	a3,a3,0x20
    436e:	96d6                	add	a3,a3,s5
        if(buf[j] != '0'+i){
    4370:	0007c703          	lbu	a4,0(a5)
    4374:	fa971ce3          	bne	a4,s1,432c <fourfiles+0x172>
      for(j = 0; j < n; j++){
    4378:	0785                	addi	a5,a5,1
    437a:	fed79be3          	bne	a5,a3,4370 <fourfiles+0x1b6>
    437e:	b7e9                	j	4348 <fourfiles+0x18e>
    close(fd);
    4380:	854e                	mv	a0,s3
    4382:	00001097          	auipc	ra,0x1
    4386:	01e080e7          	jalr	30(ra) # 53a0 <close>
    if(total != N*SZ){
    438a:	03a91963          	bne	s2,s10,43bc <fourfiles+0x202>
    unlink(fname);
    438e:	8562                	mv	a0,s8
    4390:	00001097          	auipc	ra,0x1
    4394:	038080e7          	jalr	56(ra) # 53c8 <unlink>
  for(i = 0; i < NCHILD; i++){
    4398:	0ba1                	addi	s7,s7,8
    439a:	2b05                	addiw	s6,s6,1
    439c:	03bb0e63          	beq	s6,s11,43d8 <fourfiles+0x21e>
    fname = names[i];
    43a0:	000bbc03          	ld	s8,0(s7)
    fd = open(fname, 0);
    43a4:	4581                	li	a1,0
    43a6:	8562                	mv	a0,s8
    43a8:	00001097          	auipc	ra,0x1
    43ac:	010080e7          	jalr	16(ra) # 53b8 <open>
    43b0:	89aa                	mv	s3,a0
    total = 0;
    43b2:	f5843903          	ld	s2,-168(s0)
        if(buf[j] != '0'+i){
    43b6:	000b049b          	sext.w	s1,s6
    while((n = read(fd, buf, sizeof(buf))) > 0){
    43ba:	bf49                	j	434c <fourfiles+0x192>
      printf("wrong length %d\n", total);
    43bc:	85ca                	mv	a1,s2
    43be:	00003517          	auipc	a0,0x3
    43c2:	32250513          	addi	a0,a0,802 # 76e0 <malloc+0x1f32>
    43c6:	00001097          	auipc	ra,0x1
    43ca:	32a080e7          	jalr	810(ra) # 56f0 <printf>
      exit(1);
    43ce:	4505                	li	a0,1
    43d0:	00001097          	auipc	ra,0x1
    43d4:	fa8080e7          	jalr	-88(ra) # 5378 <exit>
}
    43d8:	70aa                	ld	ra,168(sp)
    43da:	740a                	ld	s0,160(sp)
    43dc:	64ea                	ld	s1,152(sp)
    43de:	694a                	ld	s2,144(sp)
    43e0:	69aa                	ld	s3,136(sp)
    43e2:	6a0a                	ld	s4,128(sp)
    43e4:	7ae6                	ld	s5,120(sp)
    43e6:	7b46                	ld	s6,112(sp)
    43e8:	7ba6                	ld	s7,104(sp)
    43ea:	7c06                	ld	s8,96(sp)
    43ec:	6ce6                	ld	s9,88(sp)
    43ee:	6d46                	ld	s10,80(sp)
    43f0:	6da6                	ld	s11,72(sp)
    43f2:	614d                	addi	sp,sp,176
    43f4:	8082                	ret

00000000000043f6 <concreate>:
{
    43f6:	7135                	addi	sp,sp,-160
    43f8:	ed06                	sd	ra,152(sp)
    43fa:	e922                	sd	s0,144(sp)
    43fc:	e526                	sd	s1,136(sp)
    43fe:	e14a                	sd	s2,128(sp)
    4400:	fcce                	sd	s3,120(sp)
    4402:	f8d2                	sd	s4,112(sp)
    4404:	f4d6                	sd	s5,104(sp)
    4406:	f0da                	sd	s6,96(sp)
    4408:	ecde                	sd	s7,88(sp)
    440a:	1100                	addi	s0,sp,160
    440c:	89aa                	mv	s3,a0
  file[0] = 'C';
    440e:	04300793          	li	a5,67
    4412:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    4416:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    441a:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    441c:	4b0d                	li	s6,3
    441e:	4a85                	li	s5,1
      link("C0", file);
    4420:	00003b97          	auipc	s7,0x3
    4424:	2d8b8b93          	addi	s7,s7,728 # 76f8 <malloc+0x1f4a>
  for(i = 0; i < N; i++){
    4428:	02800a13          	li	s4,40
    442c:	acc1                	j	46fc <concreate+0x306>
      link("C0", file);
    442e:	fa840593          	addi	a1,s0,-88
    4432:	855e                	mv	a0,s7
    4434:	00001097          	auipc	ra,0x1
    4438:	fa4080e7          	jalr	-92(ra) # 53d8 <link>
    if(pid == 0) {
    443c:	a45d                	j	46e2 <concreate+0x2ec>
    } else if(pid == 0 && (i % 5) == 1){
    443e:	4795                	li	a5,5
    4440:	02f9693b          	remw	s2,s2,a5
    4444:	4785                	li	a5,1
    4446:	02f90b63          	beq	s2,a5,447c <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    444a:	20200593          	li	a1,514
    444e:	fa840513          	addi	a0,s0,-88
    4452:	00001097          	auipc	ra,0x1
    4456:	f66080e7          	jalr	-154(ra) # 53b8 <open>
      if(fd < 0){
    445a:	26055b63          	bgez	a0,46d0 <concreate+0x2da>
        printf("concreate create %s failed\n", file);
    445e:	fa840593          	addi	a1,s0,-88
    4462:	00003517          	auipc	a0,0x3
    4466:	29e50513          	addi	a0,a0,670 # 7700 <malloc+0x1f52>
    446a:	00001097          	auipc	ra,0x1
    446e:	286080e7          	jalr	646(ra) # 56f0 <printf>
        exit(1);
    4472:	4505                	li	a0,1
    4474:	00001097          	auipc	ra,0x1
    4478:	f04080e7          	jalr	-252(ra) # 5378 <exit>
      link("C0", file);
    447c:	fa840593          	addi	a1,s0,-88
    4480:	00003517          	auipc	a0,0x3
    4484:	27850513          	addi	a0,a0,632 # 76f8 <malloc+0x1f4a>
    4488:	00001097          	auipc	ra,0x1
    448c:	f50080e7          	jalr	-176(ra) # 53d8 <link>
      exit(0);
    4490:	4501                	li	a0,0
    4492:	00001097          	auipc	ra,0x1
    4496:	ee6080e7          	jalr	-282(ra) # 5378 <exit>
        exit(1);
    449a:	4505                	li	a0,1
    449c:	00001097          	auipc	ra,0x1
    44a0:	edc080e7          	jalr	-292(ra) # 5378 <exit>
  memset(fa, 0, sizeof(fa));
    44a4:	02800613          	li	a2,40
    44a8:	4581                	li	a1,0
    44aa:	f8040513          	addi	a0,s0,-128
    44ae:	00001097          	auipc	ra,0x1
    44b2:	cc6080e7          	jalr	-826(ra) # 5174 <memset>
  fd = open(".", 0);
    44b6:	4581                	li	a1,0
    44b8:	00002517          	auipc	a0,0x2
    44bc:	db050513          	addi	a0,a0,-592 # 6268 <malloc+0xaba>
    44c0:	00001097          	auipc	ra,0x1
    44c4:	ef8080e7          	jalr	-264(ra) # 53b8 <open>
    44c8:	892a                	mv	s2,a0
  n = 0;
    44ca:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    44cc:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    44d0:	02700b13          	li	s6,39
      fa[i] = 1;
    44d4:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    44d6:	a03d                	j	4504 <concreate+0x10e>
        printf("%s: concreate weird file %s\n", s, de.name);
    44d8:	f7240613          	addi	a2,s0,-142
    44dc:	85ce                	mv	a1,s3
    44de:	00003517          	auipc	a0,0x3
    44e2:	24250513          	addi	a0,a0,578 # 7720 <malloc+0x1f72>
    44e6:	00001097          	auipc	ra,0x1
    44ea:	20a080e7          	jalr	522(ra) # 56f0 <printf>
        exit(1);
    44ee:	4505                	li	a0,1
    44f0:	00001097          	auipc	ra,0x1
    44f4:	e88080e7          	jalr	-376(ra) # 5378 <exit>
      fa[i] = 1;
    44f8:	fb040793          	addi	a5,s0,-80
    44fc:	973e                	add	a4,a4,a5
    44fe:	fd770823          	sb	s7,-48(a4)
      n++;
    4502:	2a85                	addiw	s5,s5,1
  while(read(fd, &de, sizeof(de)) > 0){
    4504:	4641                	li	a2,16
    4506:	f7040593          	addi	a1,s0,-144
    450a:	854a                	mv	a0,s2
    450c:	00001097          	auipc	ra,0x1
    4510:	e84080e7          	jalr	-380(ra) # 5390 <read>
    4514:	04a05a63          	blez	a0,4568 <concreate+0x172>
    if(de.inum == 0)
    4518:	f7045783          	lhu	a5,-144(s0)
    451c:	d7e5                	beqz	a5,4504 <concreate+0x10e>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    451e:	f7244783          	lbu	a5,-142(s0)
    4522:	ff4791e3          	bne	a5,s4,4504 <concreate+0x10e>
    4526:	f7444783          	lbu	a5,-140(s0)
    452a:	ffe9                	bnez	a5,4504 <concreate+0x10e>
      i = de.name[1] - '0';
    452c:	f7344783          	lbu	a5,-141(s0)
    4530:	fd07879b          	addiw	a5,a5,-48
    4534:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    4538:	faeb60e3          	bltu	s6,a4,44d8 <concreate+0xe2>
      if(fa[i]){
    453c:	fb040793          	addi	a5,s0,-80
    4540:	97ba                	add	a5,a5,a4
    4542:	fd07c783          	lbu	a5,-48(a5)
    4546:	dbcd                	beqz	a5,44f8 <concreate+0x102>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    4548:	f7240613          	addi	a2,s0,-142
    454c:	85ce                	mv	a1,s3
    454e:	00003517          	auipc	a0,0x3
    4552:	1f250513          	addi	a0,a0,498 # 7740 <malloc+0x1f92>
    4556:	00001097          	auipc	ra,0x1
    455a:	19a080e7          	jalr	410(ra) # 56f0 <printf>
        exit(1);
    455e:	4505                	li	a0,1
    4560:	00001097          	auipc	ra,0x1
    4564:	e18080e7          	jalr	-488(ra) # 5378 <exit>
  close(fd);
    4568:	854a                	mv	a0,s2
    456a:	00001097          	auipc	ra,0x1
    456e:	e36080e7          	jalr	-458(ra) # 53a0 <close>
  if(n != N){
    4572:	02800793          	li	a5,40
    4576:	00fa9763          	bne	s5,a5,4584 <concreate+0x18e>
    if(((i % 3) == 0 && pid == 0) ||
    457a:	4a8d                	li	s5,3
    457c:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    457e:	02800a13          	li	s4,40
    4582:	a8c9                	j	4654 <concreate+0x25e>
    printf("%s: concreate not enough files in directory listing\n", s);
    4584:	85ce                	mv	a1,s3
    4586:	00003517          	auipc	a0,0x3
    458a:	1e250513          	addi	a0,a0,482 # 7768 <malloc+0x1fba>
    458e:	00001097          	auipc	ra,0x1
    4592:	162080e7          	jalr	354(ra) # 56f0 <printf>
    exit(1);
    4596:	4505                	li	a0,1
    4598:	00001097          	auipc	ra,0x1
    459c:	de0080e7          	jalr	-544(ra) # 5378 <exit>
      printf("%s: fork failed\n", s);
    45a0:	85ce                	mv	a1,s3
    45a2:	00002517          	auipc	a0,0x2
    45a6:	e6650513          	addi	a0,a0,-410 # 6408 <malloc+0xc5a>
    45aa:	00001097          	auipc	ra,0x1
    45ae:	146080e7          	jalr	326(ra) # 56f0 <printf>
      exit(1);
    45b2:	4505                	li	a0,1
    45b4:	00001097          	auipc	ra,0x1
    45b8:	dc4080e7          	jalr	-572(ra) # 5378 <exit>
      close(open(file, 0));
    45bc:	4581                	li	a1,0
    45be:	fa840513          	addi	a0,s0,-88
    45c2:	00001097          	auipc	ra,0x1
    45c6:	df6080e7          	jalr	-522(ra) # 53b8 <open>
    45ca:	00001097          	auipc	ra,0x1
    45ce:	dd6080e7          	jalr	-554(ra) # 53a0 <close>
      close(open(file, 0));
    45d2:	4581                	li	a1,0
    45d4:	fa840513          	addi	a0,s0,-88
    45d8:	00001097          	auipc	ra,0x1
    45dc:	de0080e7          	jalr	-544(ra) # 53b8 <open>
    45e0:	00001097          	auipc	ra,0x1
    45e4:	dc0080e7          	jalr	-576(ra) # 53a0 <close>
      close(open(file, 0));
    45e8:	4581                	li	a1,0
    45ea:	fa840513          	addi	a0,s0,-88
    45ee:	00001097          	auipc	ra,0x1
    45f2:	dca080e7          	jalr	-566(ra) # 53b8 <open>
    45f6:	00001097          	auipc	ra,0x1
    45fa:	daa080e7          	jalr	-598(ra) # 53a0 <close>
      close(open(file, 0));
    45fe:	4581                	li	a1,0
    4600:	fa840513          	addi	a0,s0,-88
    4604:	00001097          	auipc	ra,0x1
    4608:	db4080e7          	jalr	-588(ra) # 53b8 <open>
    460c:	00001097          	auipc	ra,0x1
    4610:	d94080e7          	jalr	-620(ra) # 53a0 <close>
      close(open(file, 0));
    4614:	4581                	li	a1,0
    4616:	fa840513          	addi	a0,s0,-88
    461a:	00001097          	auipc	ra,0x1
    461e:	d9e080e7          	jalr	-610(ra) # 53b8 <open>
    4622:	00001097          	auipc	ra,0x1
    4626:	d7e080e7          	jalr	-642(ra) # 53a0 <close>
      close(open(file, 0));
    462a:	4581                	li	a1,0
    462c:	fa840513          	addi	a0,s0,-88
    4630:	00001097          	auipc	ra,0x1
    4634:	d88080e7          	jalr	-632(ra) # 53b8 <open>
    4638:	00001097          	auipc	ra,0x1
    463c:	d68080e7          	jalr	-664(ra) # 53a0 <close>
    if(pid == 0)
    4640:	08090363          	beqz	s2,46c6 <concreate+0x2d0>
      wait(0);
    4644:	4501                	li	a0,0
    4646:	00001097          	auipc	ra,0x1
    464a:	d3a080e7          	jalr	-710(ra) # 5380 <wait>
  for(i = 0; i < N; i++){
    464e:	2485                	addiw	s1,s1,1
    4650:	0f448563          	beq	s1,s4,473a <concreate+0x344>
    file[1] = '0' + i;
    4654:	0304879b          	addiw	a5,s1,48
    4658:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    465c:	00001097          	auipc	ra,0x1
    4660:	d14080e7          	jalr	-748(ra) # 5370 <fork>
    4664:	892a                	mv	s2,a0
    if(pid < 0){
    4666:	f2054de3          	bltz	a0,45a0 <concreate+0x1aa>
    if(((i % 3) == 0 && pid == 0) ||
    466a:	0354e73b          	remw	a4,s1,s5
    466e:	00a767b3          	or	a5,a4,a0
    4672:	2781                	sext.w	a5,a5
    4674:	d7a1                	beqz	a5,45bc <concreate+0x1c6>
    4676:	01671363          	bne	a4,s6,467c <concreate+0x286>
       ((i % 3) == 1 && pid != 0)){
    467a:	f129                	bnez	a0,45bc <concreate+0x1c6>
      unlink(file);
    467c:	fa840513          	addi	a0,s0,-88
    4680:	00001097          	auipc	ra,0x1
    4684:	d48080e7          	jalr	-696(ra) # 53c8 <unlink>
      unlink(file);
    4688:	fa840513          	addi	a0,s0,-88
    468c:	00001097          	auipc	ra,0x1
    4690:	d3c080e7          	jalr	-708(ra) # 53c8 <unlink>
      unlink(file);
    4694:	fa840513          	addi	a0,s0,-88
    4698:	00001097          	auipc	ra,0x1
    469c:	d30080e7          	jalr	-720(ra) # 53c8 <unlink>
      unlink(file);
    46a0:	fa840513          	addi	a0,s0,-88
    46a4:	00001097          	auipc	ra,0x1
    46a8:	d24080e7          	jalr	-732(ra) # 53c8 <unlink>
      unlink(file);
    46ac:	fa840513          	addi	a0,s0,-88
    46b0:	00001097          	auipc	ra,0x1
    46b4:	d18080e7          	jalr	-744(ra) # 53c8 <unlink>
      unlink(file);
    46b8:	fa840513          	addi	a0,s0,-88
    46bc:	00001097          	auipc	ra,0x1
    46c0:	d0c080e7          	jalr	-756(ra) # 53c8 <unlink>
    46c4:	bfb5                	j	4640 <concreate+0x24a>
      exit(0);
    46c6:	4501                	li	a0,0
    46c8:	00001097          	auipc	ra,0x1
    46cc:	cb0080e7          	jalr	-848(ra) # 5378 <exit>
      close(fd);
    46d0:	00001097          	auipc	ra,0x1
    46d4:	cd0080e7          	jalr	-816(ra) # 53a0 <close>
    if(pid == 0) {
    46d8:	bb65                	j	4490 <concreate+0x9a>
      close(fd);
    46da:	00001097          	auipc	ra,0x1
    46de:	cc6080e7          	jalr	-826(ra) # 53a0 <close>
      wait(&xstatus);
    46e2:	f6c40513          	addi	a0,s0,-148
    46e6:	00001097          	auipc	ra,0x1
    46ea:	c9a080e7          	jalr	-870(ra) # 5380 <wait>
      if(xstatus != 0)
    46ee:	f6c42483          	lw	s1,-148(s0)
    46f2:	da0494e3          	bnez	s1,449a <concreate+0xa4>
  for(i = 0; i < N; i++){
    46f6:	2905                	addiw	s2,s2,1
    46f8:	db4906e3          	beq	s2,s4,44a4 <concreate+0xae>
    file[1] = '0' + i;
    46fc:	0309079b          	addiw	a5,s2,48
    4700:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    4704:	fa840513          	addi	a0,s0,-88
    4708:	00001097          	auipc	ra,0x1
    470c:	cc0080e7          	jalr	-832(ra) # 53c8 <unlink>
    pid = fork();
    4710:	00001097          	auipc	ra,0x1
    4714:	c60080e7          	jalr	-928(ra) # 5370 <fork>
    if(pid && (i % 3) == 1){
    4718:	d20503e3          	beqz	a0,443e <concreate+0x48>
    471c:	036967bb          	remw	a5,s2,s6
    4720:	d15787e3          	beq	a5,s5,442e <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    4724:	20200593          	li	a1,514
    4728:	fa840513          	addi	a0,s0,-88
    472c:	00001097          	auipc	ra,0x1
    4730:	c8c080e7          	jalr	-884(ra) # 53b8 <open>
      if(fd < 0){
    4734:	fa0553e3          	bgez	a0,46da <concreate+0x2e4>
    4738:	b31d                	j	445e <concreate+0x68>
}
    473a:	60ea                	ld	ra,152(sp)
    473c:	644a                	ld	s0,144(sp)
    473e:	64aa                	ld	s1,136(sp)
    4740:	690a                	ld	s2,128(sp)
    4742:	79e6                	ld	s3,120(sp)
    4744:	7a46                	ld	s4,112(sp)
    4746:	7aa6                	ld	s5,104(sp)
    4748:	7b06                	ld	s6,96(sp)
    474a:	6be6                	ld	s7,88(sp)
    474c:	610d                	addi	sp,sp,160
    474e:	8082                	ret

0000000000004750 <bigfile>:
{
    4750:	7139                	addi	sp,sp,-64
    4752:	fc06                	sd	ra,56(sp)
    4754:	f822                	sd	s0,48(sp)
    4756:	f426                	sd	s1,40(sp)
    4758:	f04a                	sd	s2,32(sp)
    475a:	ec4e                	sd	s3,24(sp)
    475c:	e852                	sd	s4,16(sp)
    475e:	e456                	sd	s5,8(sp)
    4760:	0080                	addi	s0,sp,64
    4762:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    4764:	00003517          	auipc	a0,0x3
    4768:	03c50513          	addi	a0,a0,60 # 77a0 <malloc+0x1ff2>
    476c:	00001097          	auipc	ra,0x1
    4770:	c5c080e7          	jalr	-932(ra) # 53c8 <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    4774:	20200593          	li	a1,514
    4778:	00003517          	auipc	a0,0x3
    477c:	02850513          	addi	a0,a0,40 # 77a0 <malloc+0x1ff2>
    4780:	00001097          	auipc	ra,0x1
    4784:	c38080e7          	jalr	-968(ra) # 53b8 <open>
    4788:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    478a:	4481                	li	s1,0
    memset(buf, i, SZ);
    478c:	00007917          	auipc	s2,0x7
    4790:	fac90913          	addi	s2,s2,-84 # b738 <buf>
  for(i = 0; i < N; i++){
    4794:	4a51                	li	s4,20
  if(fd < 0){
    4796:	0a054063          	bltz	a0,4836 <bigfile+0xe6>
    memset(buf, i, SZ);
    479a:	25800613          	li	a2,600
    479e:	85a6                	mv	a1,s1
    47a0:	854a                	mv	a0,s2
    47a2:	00001097          	auipc	ra,0x1
    47a6:	9d2080e7          	jalr	-1582(ra) # 5174 <memset>
    if(write(fd, buf, SZ) != SZ){
    47aa:	25800613          	li	a2,600
    47ae:	85ca                	mv	a1,s2
    47b0:	854e                	mv	a0,s3
    47b2:	00001097          	auipc	ra,0x1
    47b6:	be6080e7          	jalr	-1050(ra) # 5398 <write>
    47ba:	25800793          	li	a5,600
    47be:	08f51a63          	bne	a0,a5,4852 <bigfile+0x102>
  for(i = 0; i < N; i++){
    47c2:	2485                	addiw	s1,s1,1
    47c4:	fd449be3          	bne	s1,s4,479a <bigfile+0x4a>
  close(fd);
    47c8:	854e                	mv	a0,s3
    47ca:	00001097          	auipc	ra,0x1
    47ce:	bd6080e7          	jalr	-1066(ra) # 53a0 <close>
  fd = open("bigfile.dat", 0);
    47d2:	4581                	li	a1,0
    47d4:	00003517          	auipc	a0,0x3
    47d8:	fcc50513          	addi	a0,a0,-52 # 77a0 <malloc+0x1ff2>
    47dc:	00001097          	auipc	ra,0x1
    47e0:	bdc080e7          	jalr	-1060(ra) # 53b8 <open>
    47e4:	8a2a                	mv	s4,a0
  total = 0;
    47e6:	4981                	li	s3,0
  for(i = 0; ; i++){
    47e8:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    47ea:	00007917          	auipc	s2,0x7
    47ee:	f4e90913          	addi	s2,s2,-178 # b738 <buf>
  if(fd < 0){
    47f2:	06054e63          	bltz	a0,486e <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    47f6:	12c00613          	li	a2,300
    47fa:	85ca                	mv	a1,s2
    47fc:	8552                	mv	a0,s4
    47fe:	00001097          	auipc	ra,0x1
    4802:	b92080e7          	jalr	-1134(ra) # 5390 <read>
    if(cc < 0){
    4806:	08054263          	bltz	a0,488a <bigfile+0x13a>
    if(cc == 0)
    480a:	c971                	beqz	a0,48de <bigfile+0x18e>
    if(cc != SZ/2){
    480c:	12c00793          	li	a5,300
    4810:	08f51b63          	bne	a0,a5,48a6 <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    4814:	01f4d79b          	srliw	a5,s1,0x1f
    4818:	9fa5                	addw	a5,a5,s1
    481a:	4017d79b          	sraiw	a5,a5,0x1
    481e:	00094703          	lbu	a4,0(s2)
    4822:	0af71063          	bne	a4,a5,48c2 <bigfile+0x172>
    4826:	12b94703          	lbu	a4,299(s2)
    482a:	08f71c63          	bne	a4,a5,48c2 <bigfile+0x172>
    total += cc;
    482e:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    4832:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    4834:	b7c9                	j	47f6 <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    4836:	85d6                	mv	a1,s5
    4838:	00003517          	auipc	a0,0x3
    483c:	f7850513          	addi	a0,a0,-136 # 77b0 <malloc+0x2002>
    4840:	00001097          	auipc	ra,0x1
    4844:	eb0080e7          	jalr	-336(ra) # 56f0 <printf>
    exit(1);
    4848:	4505                	li	a0,1
    484a:	00001097          	auipc	ra,0x1
    484e:	b2e080e7          	jalr	-1234(ra) # 5378 <exit>
      printf("%s: write bigfile failed\n", s);
    4852:	85d6                	mv	a1,s5
    4854:	00003517          	auipc	a0,0x3
    4858:	f7c50513          	addi	a0,a0,-132 # 77d0 <malloc+0x2022>
    485c:	00001097          	auipc	ra,0x1
    4860:	e94080e7          	jalr	-364(ra) # 56f0 <printf>
      exit(1);
    4864:	4505                	li	a0,1
    4866:	00001097          	auipc	ra,0x1
    486a:	b12080e7          	jalr	-1262(ra) # 5378 <exit>
    printf("%s: cannot open bigfile\n", s);
    486e:	85d6                	mv	a1,s5
    4870:	00003517          	auipc	a0,0x3
    4874:	f8050513          	addi	a0,a0,-128 # 77f0 <malloc+0x2042>
    4878:	00001097          	auipc	ra,0x1
    487c:	e78080e7          	jalr	-392(ra) # 56f0 <printf>
    exit(1);
    4880:	4505                	li	a0,1
    4882:	00001097          	auipc	ra,0x1
    4886:	af6080e7          	jalr	-1290(ra) # 5378 <exit>
      printf("%s: read bigfile failed\n", s);
    488a:	85d6                	mv	a1,s5
    488c:	00003517          	auipc	a0,0x3
    4890:	f8450513          	addi	a0,a0,-124 # 7810 <malloc+0x2062>
    4894:	00001097          	auipc	ra,0x1
    4898:	e5c080e7          	jalr	-420(ra) # 56f0 <printf>
      exit(1);
    489c:	4505                	li	a0,1
    489e:	00001097          	auipc	ra,0x1
    48a2:	ada080e7          	jalr	-1318(ra) # 5378 <exit>
      printf("%s: short read bigfile\n", s);
    48a6:	85d6                	mv	a1,s5
    48a8:	00003517          	auipc	a0,0x3
    48ac:	f8850513          	addi	a0,a0,-120 # 7830 <malloc+0x2082>
    48b0:	00001097          	auipc	ra,0x1
    48b4:	e40080e7          	jalr	-448(ra) # 56f0 <printf>
      exit(1);
    48b8:	4505                	li	a0,1
    48ba:	00001097          	auipc	ra,0x1
    48be:	abe080e7          	jalr	-1346(ra) # 5378 <exit>
      printf("%s: read bigfile wrong data\n", s);
    48c2:	85d6                	mv	a1,s5
    48c4:	00003517          	auipc	a0,0x3
    48c8:	f8450513          	addi	a0,a0,-124 # 7848 <malloc+0x209a>
    48cc:	00001097          	auipc	ra,0x1
    48d0:	e24080e7          	jalr	-476(ra) # 56f0 <printf>
      exit(1);
    48d4:	4505                	li	a0,1
    48d6:	00001097          	auipc	ra,0x1
    48da:	aa2080e7          	jalr	-1374(ra) # 5378 <exit>
  close(fd);
    48de:	8552                	mv	a0,s4
    48e0:	00001097          	auipc	ra,0x1
    48e4:	ac0080e7          	jalr	-1344(ra) # 53a0 <close>
  if(total != N*SZ){
    48e8:	678d                	lui	a5,0x3
    48ea:	ee078793          	addi	a5,a5,-288 # 2ee0 <subdir+0x204>
    48ee:	02f99363          	bne	s3,a5,4914 <bigfile+0x1c4>
  unlink("bigfile.dat");
    48f2:	00003517          	auipc	a0,0x3
    48f6:	eae50513          	addi	a0,a0,-338 # 77a0 <malloc+0x1ff2>
    48fa:	00001097          	auipc	ra,0x1
    48fe:	ace080e7          	jalr	-1330(ra) # 53c8 <unlink>
}
    4902:	70e2                	ld	ra,56(sp)
    4904:	7442                	ld	s0,48(sp)
    4906:	74a2                	ld	s1,40(sp)
    4908:	7902                	ld	s2,32(sp)
    490a:	69e2                	ld	s3,24(sp)
    490c:	6a42                	ld	s4,16(sp)
    490e:	6aa2                	ld	s5,8(sp)
    4910:	6121                	addi	sp,sp,64
    4912:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    4914:	85d6                	mv	a1,s5
    4916:	00003517          	auipc	a0,0x3
    491a:	f5250513          	addi	a0,a0,-174 # 7868 <malloc+0x20ba>
    491e:	00001097          	auipc	ra,0x1
    4922:	dd2080e7          	jalr	-558(ra) # 56f0 <printf>
    exit(1);
    4926:	4505                	li	a0,1
    4928:	00001097          	auipc	ra,0x1
    492c:	a50080e7          	jalr	-1456(ra) # 5378 <exit>

0000000000004930 <dirtest>:
{
    4930:	1101                	addi	sp,sp,-32
    4932:	ec06                	sd	ra,24(sp)
    4934:	e822                	sd	s0,16(sp)
    4936:	e426                	sd	s1,8(sp)
    4938:	1000                	addi	s0,sp,32
    493a:	84aa                	mv	s1,a0
  printf("mkdir test\n");
    493c:	00003517          	auipc	a0,0x3
    4940:	f4c50513          	addi	a0,a0,-180 # 7888 <malloc+0x20da>
    4944:	00001097          	auipc	ra,0x1
    4948:	dac080e7          	jalr	-596(ra) # 56f0 <printf>
  if(mkdir("dir0") < 0){
    494c:	00003517          	auipc	a0,0x3
    4950:	f4c50513          	addi	a0,a0,-180 # 7898 <malloc+0x20ea>
    4954:	00001097          	auipc	ra,0x1
    4958:	a8c080e7          	jalr	-1396(ra) # 53e0 <mkdir>
    495c:	04054d63          	bltz	a0,49b6 <dirtest+0x86>
  if(chdir("dir0") < 0){
    4960:	00003517          	auipc	a0,0x3
    4964:	f3850513          	addi	a0,a0,-200 # 7898 <malloc+0x20ea>
    4968:	00001097          	auipc	ra,0x1
    496c:	a80080e7          	jalr	-1408(ra) # 53e8 <chdir>
    4970:	06054163          	bltz	a0,49d2 <dirtest+0xa2>
  if(chdir("..") < 0){
    4974:	00003517          	auipc	a0,0x3
    4978:	97c50513          	addi	a0,a0,-1668 # 72f0 <malloc+0x1b42>
    497c:	00001097          	auipc	ra,0x1
    4980:	a6c080e7          	jalr	-1428(ra) # 53e8 <chdir>
    4984:	06054563          	bltz	a0,49ee <dirtest+0xbe>
  if(unlink("dir0") < 0){
    4988:	00003517          	auipc	a0,0x3
    498c:	f1050513          	addi	a0,a0,-240 # 7898 <malloc+0x20ea>
    4990:	00001097          	auipc	ra,0x1
    4994:	a38080e7          	jalr	-1480(ra) # 53c8 <unlink>
    4998:	06054963          	bltz	a0,4a0a <dirtest+0xda>
  printf("%s: mkdir test ok\n");
    499c:	00003517          	auipc	a0,0x3
    49a0:	f4c50513          	addi	a0,a0,-180 # 78e8 <malloc+0x213a>
    49a4:	00001097          	auipc	ra,0x1
    49a8:	d4c080e7          	jalr	-692(ra) # 56f0 <printf>
}
    49ac:	60e2                	ld	ra,24(sp)
    49ae:	6442                	ld	s0,16(sp)
    49b0:	64a2                	ld	s1,8(sp)
    49b2:	6105                	addi	sp,sp,32
    49b4:	8082                	ret
    printf("%s: mkdir failed\n", s);
    49b6:	85a6                	mv	a1,s1
    49b8:	00002517          	auipc	a0,0x2
    49bc:	2d850513          	addi	a0,a0,728 # 6c90 <malloc+0x14e2>
    49c0:	00001097          	auipc	ra,0x1
    49c4:	d30080e7          	jalr	-720(ra) # 56f0 <printf>
    exit(1);
    49c8:	4505                	li	a0,1
    49ca:	00001097          	auipc	ra,0x1
    49ce:	9ae080e7          	jalr	-1618(ra) # 5378 <exit>
    printf("%s: chdir dir0 failed\n", s);
    49d2:	85a6                	mv	a1,s1
    49d4:	00003517          	auipc	a0,0x3
    49d8:	ecc50513          	addi	a0,a0,-308 # 78a0 <malloc+0x20f2>
    49dc:	00001097          	auipc	ra,0x1
    49e0:	d14080e7          	jalr	-748(ra) # 56f0 <printf>
    exit(1);
    49e4:	4505                	li	a0,1
    49e6:	00001097          	auipc	ra,0x1
    49ea:	992080e7          	jalr	-1646(ra) # 5378 <exit>
    printf("%s: chdir .. failed\n", s);
    49ee:	85a6                	mv	a1,s1
    49f0:	00003517          	auipc	a0,0x3
    49f4:	ec850513          	addi	a0,a0,-312 # 78b8 <malloc+0x210a>
    49f8:	00001097          	auipc	ra,0x1
    49fc:	cf8080e7          	jalr	-776(ra) # 56f0 <printf>
    exit(1);
    4a00:	4505                	li	a0,1
    4a02:	00001097          	auipc	ra,0x1
    4a06:	976080e7          	jalr	-1674(ra) # 5378 <exit>
    printf("%s: unlink dir0 failed\n", s);
    4a0a:	85a6                	mv	a1,s1
    4a0c:	00003517          	auipc	a0,0x3
    4a10:	ec450513          	addi	a0,a0,-316 # 78d0 <malloc+0x2122>
    4a14:	00001097          	auipc	ra,0x1
    4a18:	cdc080e7          	jalr	-804(ra) # 56f0 <printf>
    exit(1);
    4a1c:	4505                	li	a0,1
    4a1e:	00001097          	auipc	ra,0x1
    4a22:	95a080e7          	jalr	-1702(ra) # 5378 <exit>

0000000000004a26 <fsfull>:
{
    4a26:	7171                	addi	sp,sp,-176
    4a28:	f506                	sd	ra,168(sp)
    4a2a:	f122                	sd	s0,160(sp)
    4a2c:	ed26                	sd	s1,152(sp)
    4a2e:	e94a                	sd	s2,144(sp)
    4a30:	e54e                	sd	s3,136(sp)
    4a32:	e152                	sd	s4,128(sp)
    4a34:	fcd6                	sd	s5,120(sp)
    4a36:	f8da                	sd	s6,112(sp)
    4a38:	f4de                	sd	s7,104(sp)
    4a3a:	f0e2                	sd	s8,96(sp)
    4a3c:	ece6                	sd	s9,88(sp)
    4a3e:	e8ea                	sd	s10,80(sp)
    4a40:	e4ee                	sd	s11,72(sp)
    4a42:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    4a44:	00003517          	auipc	a0,0x3
    4a48:	ebc50513          	addi	a0,a0,-324 # 7900 <malloc+0x2152>
    4a4c:	00001097          	auipc	ra,0x1
    4a50:	ca4080e7          	jalr	-860(ra) # 56f0 <printf>
  for(nfiles = 0; ; nfiles++){
    4a54:	4481                	li	s1,0
    name[0] = 'f';
    4a56:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    4a5a:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4a5e:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    4a62:	4b29                	li	s6,10
    printf("%s: writing %s\n", name);
    4a64:	00003c97          	auipc	s9,0x3
    4a68:	eacc8c93          	addi	s9,s9,-340 # 7910 <malloc+0x2162>
    int total = 0;
    4a6c:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    4a6e:	00007a17          	auipc	s4,0x7
    4a72:	ccaa0a13          	addi	s4,s4,-822 # b738 <buf>
    name[0] = 'f';
    4a76:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4a7a:	0384c7bb          	divw	a5,s1,s8
    4a7e:	0307879b          	addiw	a5,a5,48
    4a82:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4a86:	0384e7bb          	remw	a5,s1,s8
    4a8a:	0377c7bb          	divw	a5,a5,s7
    4a8e:	0307879b          	addiw	a5,a5,48
    4a92:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4a96:	0374e7bb          	remw	a5,s1,s7
    4a9a:	0367c7bb          	divw	a5,a5,s6
    4a9e:	0307879b          	addiw	a5,a5,48
    4aa2:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4aa6:	0364e7bb          	remw	a5,s1,s6
    4aaa:	0307879b          	addiw	a5,a5,48
    4aae:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4ab2:	f4040aa3          	sb	zero,-171(s0)
    printf("%s: writing %s\n", name);
    4ab6:	f5040593          	addi	a1,s0,-176
    4aba:	8566                	mv	a0,s9
    4abc:	00001097          	auipc	ra,0x1
    4ac0:	c34080e7          	jalr	-972(ra) # 56f0 <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    4ac4:	20200593          	li	a1,514
    4ac8:	f5040513          	addi	a0,s0,-176
    4acc:	00001097          	auipc	ra,0x1
    4ad0:	8ec080e7          	jalr	-1812(ra) # 53b8 <open>
    4ad4:	892a                	mv	s2,a0
    if(fd < 0){
    4ad6:	0a055663          	bgez	a0,4b82 <fsfull+0x15c>
      printf("%s: open %s failed\n", name);
    4ada:	f5040593          	addi	a1,s0,-176
    4ade:	00003517          	auipc	a0,0x3
    4ae2:	e4250513          	addi	a0,a0,-446 # 7920 <malloc+0x2172>
    4ae6:	00001097          	auipc	ra,0x1
    4aea:	c0a080e7          	jalr	-1014(ra) # 56f0 <printf>
  while(nfiles >= 0){
    4aee:	0604c363          	bltz	s1,4b54 <fsfull+0x12e>
    name[0] = 'f';
    4af2:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    4af6:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4afa:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    4afe:	4929                	li	s2,10
  while(nfiles >= 0){
    4b00:	5afd                	li	s5,-1
    name[0] = 'f';
    4b02:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4b06:	0344c7bb          	divw	a5,s1,s4
    4b0a:	0307879b          	addiw	a5,a5,48
    4b0e:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4b12:	0344e7bb          	remw	a5,s1,s4
    4b16:	0337c7bb          	divw	a5,a5,s3
    4b1a:	0307879b          	addiw	a5,a5,48
    4b1e:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4b22:	0334e7bb          	remw	a5,s1,s3
    4b26:	0327c7bb          	divw	a5,a5,s2
    4b2a:	0307879b          	addiw	a5,a5,48
    4b2e:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4b32:	0324e7bb          	remw	a5,s1,s2
    4b36:	0307879b          	addiw	a5,a5,48
    4b3a:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4b3e:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    4b42:	f5040513          	addi	a0,s0,-176
    4b46:	00001097          	auipc	ra,0x1
    4b4a:	882080e7          	jalr	-1918(ra) # 53c8 <unlink>
    nfiles--;
    4b4e:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    4b50:	fb5499e3          	bne	s1,s5,4b02 <fsfull+0xdc>
  printf("fsfull test finished\n");
    4b54:	00003517          	auipc	a0,0x3
    4b58:	dfc50513          	addi	a0,a0,-516 # 7950 <malloc+0x21a2>
    4b5c:	00001097          	auipc	ra,0x1
    4b60:	b94080e7          	jalr	-1132(ra) # 56f0 <printf>
}
    4b64:	70aa                	ld	ra,168(sp)
    4b66:	740a                	ld	s0,160(sp)
    4b68:	64ea                	ld	s1,152(sp)
    4b6a:	694a                	ld	s2,144(sp)
    4b6c:	69aa                	ld	s3,136(sp)
    4b6e:	6a0a                	ld	s4,128(sp)
    4b70:	7ae6                	ld	s5,120(sp)
    4b72:	7b46                	ld	s6,112(sp)
    4b74:	7ba6                	ld	s7,104(sp)
    4b76:	7c06                	ld	s8,96(sp)
    4b78:	6ce6                	ld	s9,88(sp)
    4b7a:	6d46                	ld	s10,80(sp)
    4b7c:	6da6                	ld	s11,72(sp)
    4b7e:	614d                	addi	sp,sp,176
    4b80:	8082                	ret
    int total = 0;
    4b82:	89ee                	mv	s3,s11
      if(cc < BSIZE)
    4b84:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    4b88:	40000613          	li	a2,1024
    4b8c:	85d2                	mv	a1,s4
    4b8e:	854a                	mv	a0,s2
    4b90:	00001097          	auipc	ra,0x1
    4b94:	808080e7          	jalr	-2040(ra) # 5398 <write>
      if(cc < BSIZE)
    4b98:	00aad563          	bge	s5,a0,4ba2 <fsfull+0x17c>
      total += cc;
    4b9c:	00a989bb          	addw	s3,s3,a0
    while(1){
    4ba0:	b7e5                	j	4b88 <fsfull+0x162>
    printf("%s: wrote %d bytes\n", total);
    4ba2:	85ce                	mv	a1,s3
    4ba4:	00003517          	auipc	a0,0x3
    4ba8:	d9450513          	addi	a0,a0,-620 # 7938 <malloc+0x218a>
    4bac:	00001097          	auipc	ra,0x1
    4bb0:	b44080e7          	jalr	-1212(ra) # 56f0 <printf>
    close(fd);
    4bb4:	854a                	mv	a0,s2
    4bb6:	00000097          	auipc	ra,0x0
    4bba:	7ea080e7          	jalr	2026(ra) # 53a0 <close>
    if(total == 0)
    4bbe:	f20988e3          	beqz	s3,4aee <fsfull+0xc8>
  for(nfiles = 0; ; nfiles++){
    4bc2:	2485                	addiw	s1,s1,1
    4bc4:	bd4d                	j	4a76 <fsfull+0x50>

0000000000004bc6 <rand>:
{
    4bc6:	1141                	addi	sp,sp,-16
    4bc8:	e422                	sd	s0,8(sp)
    4bca:	0800                	addi	s0,sp,16
  randstate = randstate * 1664525 + 1013904223;
    4bcc:	00003717          	auipc	a4,0x3
    4bd0:	33c70713          	addi	a4,a4,828 # 7f08 <randstate>
    4bd4:	6308                	ld	a0,0(a4)
    4bd6:	001967b7          	lui	a5,0x196
    4bda:	60d78793          	addi	a5,a5,1549 # 19660d <__BSS_END__+0x187ec5>
    4bde:	02f50533          	mul	a0,a0,a5
    4be2:	3c6ef7b7          	lui	a5,0x3c6ef
    4be6:	35f78793          	addi	a5,a5,863 # 3c6ef35f <__BSS_END__+0x3c6e0c17>
    4bea:	953e                	add	a0,a0,a5
    4bec:	e308                	sd	a0,0(a4)
}
    4bee:	2501                	sext.w	a0,a0
    4bf0:	6422                	ld	s0,8(sp)
    4bf2:	0141                	addi	sp,sp,16
    4bf4:	8082                	ret

0000000000004bf6 <badwrite>:
{
    4bf6:	7179                	addi	sp,sp,-48
    4bf8:	f406                	sd	ra,40(sp)
    4bfa:	f022                	sd	s0,32(sp)
    4bfc:	ec26                	sd	s1,24(sp)
    4bfe:	e84a                	sd	s2,16(sp)
    4c00:	e44e                	sd	s3,8(sp)
    4c02:	e052                	sd	s4,0(sp)
    4c04:	1800                	addi	s0,sp,48
  unlink("junk");
    4c06:	00003517          	auipc	a0,0x3
    4c0a:	d6250513          	addi	a0,a0,-670 # 7968 <malloc+0x21ba>
    4c0e:	00000097          	auipc	ra,0x0
    4c12:	7ba080e7          	jalr	1978(ra) # 53c8 <unlink>
    4c16:	25800913          	li	s2,600
    int fd = open("junk", O_CREATE|O_WRONLY);
    4c1a:	00003997          	auipc	s3,0x3
    4c1e:	d4e98993          	addi	s3,s3,-690 # 7968 <malloc+0x21ba>
    write(fd, (char*)0xffffffffffL, 1);
    4c22:	5a7d                	li	s4,-1
    4c24:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
    4c28:	20100593          	li	a1,513
    4c2c:	854e                	mv	a0,s3
    4c2e:	00000097          	auipc	ra,0x0
    4c32:	78a080e7          	jalr	1930(ra) # 53b8 <open>
    4c36:	84aa                	mv	s1,a0
    if(fd < 0){
    4c38:	06054b63          	bltz	a0,4cae <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
    4c3c:	4605                	li	a2,1
    4c3e:	85d2                	mv	a1,s4
    4c40:	00000097          	auipc	ra,0x0
    4c44:	758080e7          	jalr	1880(ra) # 5398 <write>
    close(fd);
    4c48:	8526                	mv	a0,s1
    4c4a:	00000097          	auipc	ra,0x0
    4c4e:	756080e7          	jalr	1878(ra) # 53a0 <close>
    unlink("junk");
    4c52:	854e                	mv	a0,s3
    4c54:	00000097          	auipc	ra,0x0
    4c58:	774080e7          	jalr	1908(ra) # 53c8 <unlink>
  for(int i = 0; i < assumed_free; i++){
    4c5c:	397d                	addiw	s2,s2,-1
    4c5e:	fc0915e3          	bnez	s2,4c28 <badwrite+0x32>
  int fd = open("junk", O_CREATE|O_WRONLY);
    4c62:	20100593          	li	a1,513
    4c66:	00003517          	auipc	a0,0x3
    4c6a:	d0250513          	addi	a0,a0,-766 # 7968 <malloc+0x21ba>
    4c6e:	00000097          	auipc	ra,0x0
    4c72:	74a080e7          	jalr	1866(ra) # 53b8 <open>
    4c76:	84aa                	mv	s1,a0
  if(fd < 0){
    4c78:	04054863          	bltz	a0,4cc8 <badwrite+0xd2>
  if(write(fd, "x", 1) != 1){
    4c7c:	4605                	li	a2,1
    4c7e:	00001597          	auipc	a1,0x1
    4c82:	fc258593          	addi	a1,a1,-62 # 5c40 <malloc+0x492>
    4c86:	00000097          	auipc	ra,0x0
    4c8a:	712080e7          	jalr	1810(ra) # 5398 <write>
    4c8e:	4785                	li	a5,1
    4c90:	04f50963          	beq	a0,a5,4ce2 <badwrite+0xec>
    printf("write failed\n");
    4c94:	00003517          	auipc	a0,0x3
    4c98:	cf450513          	addi	a0,a0,-780 # 7988 <malloc+0x21da>
    4c9c:	00001097          	auipc	ra,0x1
    4ca0:	a54080e7          	jalr	-1452(ra) # 56f0 <printf>
    exit(1);
    4ca4:	4505                	li	a0,1
    4ca6:	00000097          	auipc	ra,0x0
    4caa:	6d2080e7          	jalr	1746(ra) # 5378 <exit>
      printf("open junk failed\n");
    4cae:	00003517          	auipc	a0,0x3
    4cb2:	cc250513          	addi	a0,a0,-830 # 7970 <malloc+0x21c2>
    4cb6:	00001097          	auipc	ra,0x1
    4cba:	a3a080e7          	jalr	-1478(ra) # 56f0 <printf>
      exit(1);
    4cbe:	4505                	li	a0,1
    4cc0:	00000097          	auipc	ra,0x0
    4cc4:	6b8080e7          	jalr	1720(ra) # 5378 <exit>
    printf("open junk failed\n");
    4cc8:	00003517          	auipc	a0,0x3
    4ccc:	ca850513          	addi	a0,a0,-856 # 7970 <malloc+0x21c2>
    4cd0:	00001097          	auipc	ra,0x1
    4cd4:	a20080e7          	jalr	-1504(ra) # 56f0 <printf>
    exit(1);
    4cd8:	4505                	li	a0,1
    4cda:	00000097          	auipc	ra,0x0
    4cde:	69e080e7          	jalr	1694(ra) # 5378 <exit>
  close(fd);
    4ce2:	8526                	mv	a0,s1
    4ce4:	00000097          	auipc	ra,0x0
    4ce8:	6bc080e7          	jalr	1724(ra) # 53a0 <close>
  unlink("junk");
    4cec:	00003517          	auipc	a0,0x3
    4cf0:	c7c50513          	addi	a0,a0,-900 # 7968 <malloc+0x21ba>
    4cf4:	00000097          	auipc	ra,0x0
    4cf8:	6d4080e7          	jalr	1748(ra) # 53c8 <unlink>
  exit(0);
    4cfc:	4501                	li	a0,0
    4cfe:	00000097          	auipc	ra,0x0
    4d02:	67a080e7          	jalr	1658(ra) # 5378 <exit>

0000000000004d06 <countfree>:
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int
countfree()
{
    4d06:	7139                	addi	sp,sp,-64
    4d08:	fc06                	sd	ra,56(sp)
    4d0a:	f822                	sd	s0,48(sp)
    4d0c:	f426                	sd	s1,40(sp)
    4d0e:	f04a                	sd	s2,32(sp)
    4d10:	ec4e                	sd	s3,24(sp)
    4d12:	0080                	addi	s0,sp,64
  int fds[2];

  if(pipe(fds) < 0){
    4d14:	fc840513          	addi	a0,s0,-56
    4d18:	00000097          	auipc	ra,0x0
    4d1c:	670080e7          	jalr	1648(ra) # 5388 <pipe>
    4d20:	06054863          	bltz	a0,4d90 <countfree+0x8a>
    printf("pipe() failed in countfree()\n");
    exit(1);
  }
  
  int pid = fork();
    4d24:	00000097          	auipc	ra,0x0
    4d28:	64c080e7          	jalr	1612(ra) # 5370 <fork>

  if(pid < 0){
    4d2c:	06054f63          	bltz	a0,4daa <countfree+0xa4>
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if(pid == 0){
    4d30:	ed59                	bnez	a0,4dce <countfree+0xc8>
    close(fds[0]);
    4d32:	fc842503          	lw	a0,-56(s0)
    4d36:	00000097          	auipc	ra,0x0
    4d3a:	66a080e7          	jalr	1642(ra) # 53a0 <close>
    
    while(1){
      uint64 a = (uint64) sbrk(4096);
      if(a == 0xffffffffffffffff){
    4d3e:	54fd                	li	s1,-1
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    4d40:	4985                	li	s3,1

      // report back one more page.
      if(write(fds[1], "x", 1) != 1){
    4d42:	00001917          	auipc	s2,0x1
    4d46:	efe90913          	addi	s2,s2,-258 # 5c40 <malloc+0x492>
      uint64 a = (uint64) sbrk(4096);
    4d4a:	6505                	lui	a0,0x1
    4d4c:	00000097          	auipc	ra,0x0
    4d50:	6b4080e7          	jalr	1716(ra) # 5400 <sbrk>
      if(a == 0xffffffffffffffff){
    4d54:	06950863          	beq	a0,s1,4dc4 <countfree+0xbe>
      *(char *)(a + 4096 - 1) = 1;
    4d58:	6785                	lui	a5,0x1
    4d5a:	953e                	add	a0,a0,a5
    4d5c:	ff350fa3          	sb	s3,-1(a0) # fff <bigdir+0x95>
      if(write(fds[1], "x", 1) != 1){
    4d60:	4605                	li	a2,1
    4d62:	85ca                	mv	a1,s2
    4d64:	fcc42503          	lw	a0,-52(s0)
    4d68:	00000097          	auipc	ra,0x0
    4d6c:	630080e7          	jalr	1584(ra) # 5398 <write>
    4d70:	4785                	li	a5,1
    4d72:	fcf50ce3          	beq	a0,a5,4d4a <countfree+0x44>
        printf("write() failed in countfree()\n");
    4d76:	00003517          	auipc	a0,0x3
    4d7a:	c6250513          	addi	a0,a0,-926 # 79d8 <malloc+0x222a>
    4d7e:	00001097          	auipc	ra,0x1
    4d82:	972080e7          	jalr	-1678(ra) # 56f0 <printf>
        exit(1);
    4d86:	4505                	li	a0,1
    4d88:	00000097          	auipc	ra,0x0
    4d8c:	5f0080e7          	jalr	1520(ra) # 5378 <exit>
    printf("pipe() failed in countfree()\n");
    4d90:	00003517          	auipc	a0,0x3
    4d94:	c0850513          	addi	a0,a0,-1016 # 7998 <malloc+0x21ea>
    4d98:	00001097          	auipc	ra,0x1
    4d9c:	958080e7          	jalr	-1704(ra) # 56f0 <printf>
    exit(1);
    4da0:	4505                	li	a0,1
    4da2:	00000097          	auipc	ra,0x0
    4da6:	5d6080e7          	jalr	1494(ra) # 5378 <exit>
    printf("fork failed in countfree()\n");
    4daa:	00003517          	auipc	a0,0x3
    4dae:	c0e50513          	addi	a0,a0,-1010 # 79b8 <malloc+0x220a>
    4db2:	00001097          	auipc	ra,0x1
    4db6:	93e080e7          	jalr	-1730(ra) # 56f0 <printf>
    exit(1);
    4dba:	4505                	li	a0,1
    4dbc:	00000097          	auipc	ra,0x0
    4dc0:	5bc080e7          	jalr	1468(ra) # 5378 <exit>
      }
    }

    exit(0);
    4dc4:	4501                	li	a0,0
    4dc6:	00000097          	auipc	ra,0x0
    4dca:	5b2080e7          	jalr	1458(ra) # 5378 <exit>
  }

  close(fds[1]);
    4dce:	fcc42503          	lw	a0,-52(s0)
    4dd2:	00000097          	auipc	ra,0x0
    4dd6:	5ce080e7          	jalr	1486(ra) # 53a0 <close>

  int n = 0;
    4dda:	4481                	li	s1,0
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    4ddc:	4605                	li	a2,1
    4dde:	fc740593          	addi	a1,s0,-57
    4de2:	fc842503          	lw	a0,-56(s0)
    4de6:	00000097          	auipc	ra,0x0
    4dea:	5aa080e7          	jalr	1450(ra) # 5390 <read>
    if(cc < 0){
    4dee:	00054563          	bltz	a0,4df8 <countfree+0xf2>
      printf("read() failed in countfree()\n");
      exit(1);
    }
    if(cc == 0)
    4df2:	c105                	beqz	a0,4e12 <countfree+0x10c>
      break;
    n += 1;
    4df4:	2485                	addiw	s1,s1,1
  while(1){
    4df6:	b7dd                	j	4ddc <countfree+0xd6>
      printf("read() failed in countfree()\n");
    4df8:	00003517          	auipc	a0,0x3
    4dfc:	c0050513          	addi	a0,a0,-1024 # 79f8 <malloc+0x224a>
    4e00:	00001097          	auipc	ra,0x1
    4e04:	8f0080e7          	jalr	-1808(ra) # 56f0 <printf>
      exit(1);
    4e08:	4505                	li	a0,1
    4e0a:	00000097          	auipc	ra,0x0
    4e0e:	56e080e7          	jalr	1390(ra) # 5378 <exit>
  }

  close(fds[0]);
    4e12:	fc842503          	lw	a0,-56(s0)
    4e16:	00000097          	auipc	ra,0x0
    4e1a:	58a080e7          	jalr	1418(ra) # 53a0 <close>
  wait((int*)0);
    4e1e:	4501                	li	a0,0
    4e20:	00000097          	auipc	ra,0x0
    4e24:	560080e7          	jalr	1376(ra) # 5380 <wait>
  
  return n;
}
    4e28:	8526                	mv	a0,s1
    4e2a:	70e2                	ld	ra,56(sp)
    4e2c:	7442                	ld	s0,48(sp)
    4e2e:	74a2                	ld	s1,40(sp)
    4e30:	7902                	ld	s2,32(sp)
    4e32:	69e2                	ld	s3,24(sp)
    4e34:	6121                	addi	sp,sp,64
    4e36:	8082                	ret

0000000000004e38 <run>:

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    4e38:	7179                	addi	sp,sp,-48
    4e3a:	f406                	sd	ra,40(sp)
    4e3c:	f022                	sd	s0,32(sp)
    4e3e:	ec26                	sd	s1,24(sp)
    4e40:	e84a                	sd	s2,16(sp)
    4e42:	1800                	addi	s0,sp,48
    4e44:	84aa                	mv	s1,a0
    4e46:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    4e48:	00003517          	auipc	a0,0x3
    4e4c:	bd050513          	addi	a0,a0,-1072 # 7a18 <malloc+0x226a>
    4e50:	00001097          	auipc	ra,0x1
    4e54:	8a0080e7          	jalr	-1888(ra) # 56f0 <printf>
  if((pid = fork()) < 0) {
    4e58:	00000097          	auipc	ra,0x0
    4e5c:	518080e7          	jalr	1304(ra) # 5370 <fork>
    4e60:	02054e63          	bltz	a0,4e9c <run+0x64>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    4e64:	c929                	beqz	a0,4eb6 <run+0x7e>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    4e66:	fdc40513          	addi	a0,s0,-36
    4e6a:	00000097          	auipc	ra,0x0
    4e6e:	516080e7          	jalr	1302(ra) # 5380 <wait>
    if(xstatus != 0) 
    4e72:	fdc42783          	lw	a5,-36(s0)
    4e76:	c7b9                	beqz	a5,4ec4 <run+0x8c>
      printf("FAILED\n");
    4e78:	00003517          	auipc	a0,0x3
    4e7c:	bc850513          	addi	a0,a0,-1080 # 7a40 <malloc+0x2292>
    4e80:	00001097          	auipc	ra,0x1
    4e84:	870080e7          	jalr	-1936(ra) # 56f0 <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    4e88:	fdc42503          	lw	a0,-36(s0)
  }
}
    4e8c:	00153513          	seqz	a0,a0
    4e90:	70a2                	ld	ra,40(sp)
    4e92:	7402                	ld	s0,32(sp)
    4e94:	64e2                	ld	s1,24(sp)
    4e96:	6942                	ld	s2,16(sp)
    4e98:	6145                	addi	sp,sp,48
    4e9a:	8082                	ret
    printf("runtest: fork error\n");
    4e9c:	00003517          	auipc	a0,0x3
    4ea0:	b8c50513          	addi	a0,a0,-1140 # 7a28 <malloc+0x227a>
    4ea4:	00001097          	auipc	ra,0x1
    4ea8:	84c080e7          	jalr	-1972(ra) # 56f0 <printf>
    exit(1);
    4eac:	4505                	li	a0,1
    4eae:	00000097          	auipc	ra,0x0
    4eb2:	4ca080e7          	jalr	1226(ra) # 5378 <exit>
    f(s);
    4eb6:	854a                	mv	a0,s2
    4eb8:	9482                	jalr	s1
    exit(0);
    4eba:	4501                	li	a0,0
    4ebc:	00000097          	auipc	ra,0x0
    4ec0:	4bc080e7          	jalr	1212(ra) # 5378 <exit>
      printf("OK\n");
    4ec4:	00003517          	auipc	a0,0x3
    4ec8:	b8450513          	addi	a0,a0,-1148 # 7a48 <malloc+0x229a>
    4ecc:	00001097          	auipc	ra,0x1
    4ed0:	824080e7          	jalr	-2012(ra) # 56f0 <printf>
    4ed4:	bf55                	j	4e88 <run+0x50>

0000000000004ed6 <main>:

int
main(int argc, char *argv[])
{
    4ed6:	c4010113          	addi	sp,sp,-960
    4eda:	3a113c23          	sd	ra,952(sp)
    4ede:	3a813823          	sd	s0,944(sp)
    4ee2:	3a913423          	sd	s1,936(sp)
    4ee6:	3b213023          	sd	s2,928(sp)
    4eea:	39313c23          	sd	s3,920(sp)
    4eee:	39413823          	sd	s4,912(sp)
    4ef2:	39513423          	sd	s5,904(sp)
    4ef6:	39613023          	sd	s6,896(sp)
    4efa:	0780                	addi	s0,sp,960
    4efc:	89aa                	mv	s3,a0
  int continuous = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    4efe:	4789                	li	a5,2
    4f00:	08f50763          	beq	a0,a5,4f8e <main+0xb8>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    4f04:	4785                	li	a5,1
  char *justone = 0;
    4f06:	4901                	li	s2,0
  } else if(argc > 1){
    4f08:	0ca7c163          	blt	a5,a0,4fca <main+0xf4>
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
    4f0c:	00003797          	auipc	a5,0x3
    4f10:	c5478793          	addi	a5,a5,-940 # 7b60 <malloc+0x23b2>
    4f14:	c4040713          	addi	a4,s0,-960
    4f18:	00003817          	auipc	a6,0x3
    4f1c:	fc880813          	addi	a6,a6,-56 # 7ee0 <malloc+0x2732>
    4f20:	6388                	ld	a0,0(a5)
    4f22:	678c                	ld	a1,8(a5)
    4f24:	6b90                	ld	a2,16(a5)
    4f26:	6f94                	ld	a3,24(a5)
    4f28:	e308                	sd	a0,0(a4)
    4f2a:	e70c                	sd	a1,8(a4)
    4f2c:	eb10                	sd	a2,16(a4)
    4f2e:	ef14                	sd	a3,24(a4)
    4f30:	02078793          	addi	a5,a5,32
    4f34:	02070713          	addi	a4,a4,32
    4f38:	ff0794e3          	bne	a5,a6,4f20 <main+0x4a>
          exit(1);
      }
    }
  }

  printf("usertests starting\n");
    4f3c:	00003517          	auipc	a0,0x3
    4f40:	bc450513          	addi	a0,a0,-1084 # 7b00 <malloc+0x2352>
    4f44:	00000097          	auipc	ra,0x0
    4f48:	7ac080e7          	jalr	1964(ra) # 56f0 <printf>
  int free0 = countfree();
    4f4c:	00000097          	auipc	ra,0x0
    4f50:	dba080e7          	jalr	-582(ra) # 4d06 <countfree>
    4f54:	8a2a                	mv	s4,a0
  int free1 = 0;
  int fail = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    4f56:	c4843503          	ld	a0,-952(s0)
    4f5a:	c4040493          	addi	s1,s0,-960
  int fail = 0;
    4f5e:	4981                	li	s3,0
    if((justone == 0) || strcmp(t->s, justone) == 0) {
      if(!run(t->f, t->s))
        fail = 1;
    4f60:	4a85                	li	s5,1
  for (struct test *t = tests; t->s != 0; t++) {
    4f62:	e55d                	bnez	a0,5010 <main+0x13a>
  }

  if(fail){
    printf("SOME TESTS FAILED\n");
    exit(1);
  } else if((free1 = countfree()) < free0){
    4f64:	00000097          	auipc	ra,0x0
    4f68:	da2080e7          	jalr	-606(ra) # 4d06 <countfree>
    4f6c:	85aa                	mv	a1,a0
    4f6e:	0f455163          	bge	a0,s4,5050 <main+0x17a>
    printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    4f72:	8652                	mv	a2,s4
    4f74:	00003517          	auipc	a0,0x3
    4f78:	b4450513          	addi	a0,a0,-1212 # 7ab8 <malloc+0x230a>
    4f7c:	00000097          	auipc	ra,0x0
    4f80:	774080e7          	jalr	1908(ra) # 56f0 <printf>
    exit(1);
    4f84:	4505                	li	a0,1
    4f86:	00000097          	auipc	ra,0x0
    4f8a:	3f2080e7          	jalr	1010(ra) # 5378 <exit>
    4f8e:	84ae                	mv	s1,a1
  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    4f90:	00003597          	auipc	a1,0x3
    4f94:	ac058593          	addi	a1,a1,-1344 # 7a50 <malloc+0x22a2>
    4f98:	6488                	ld	a0,8(s1)
    4f9a:	00000097          	auipc	ra,0x0
    4f9e:	184080e7          	jalr	388(ra) # 511e <strcmp>
    4fa2:	10050563          	beqz	a0,50ac <main+0x1d6>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    4fa6:	00003597          	auipc	a1,0x3
    4faa:	b9258593          	addi	a1,a1,-1134 # 7b38 <malloc+0x238a>
    4fae:	6488                	ld	a0,8(s1)
    4fb0:	00000097          	auipc	ra,0x0
    4fb4:	16e080e7          	jalr	366(ra) # 511e <strcmp>
    4fb8:	c97d                	beqz	a0,50ae <main+0x1d8>
  } else if(argc == 2 && argv[1][0] != '-'){
    4fba:	0084b903          	ld	s2,8(s1)
    4fbe:	00094703          	lbu	a4,0(s2)
    4fc2:	02d00793          	li	a5,45
    4fc6:	f4f713e3          	bne	a4,a5,4f0c <main+0x36>
    printf("Usage: usertests [-c] [testname]\n");
    4fca:	00003517          	auipc	a0,0x3
    4fce:	a8e50513          	addi	a0,a0,-1394 # 7a58 <malloc+0x22aa>
    4fd2:	00000097          	auipc	ra,0x0
    4fd6:	71e080e7          	jalr	1822(ra) # 56f0 <printf>
    exit(1);
    4fda:	4505                	li	a0,1
    4fdc:	00000097          	auipc	ra,0x0
    4fe0:	39c080e7          	jalr	924(ra) # 5378 <exit>
          exit(1);
    4fe4:	4505                	li	a0,1
    4fe6:	00000097          	auipc	ra,0x0
    4fea:	392080e7          	jalr	914(ra) # 5378 <exit>
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    4fee:	40a905bb          	subw	a1,s2,a0
    4ff2:	855a                	mv	a0,s6
    4ff4:	00000097          	auipc	ra,0x0
    4ff8:	6fc080e7          	jalr	1788(ra) # 56f0 <printf>
        if(continuous != 2)
    4ffc:	09498463          	beq	s3,s4,5084 <main+0x1ae>
          exit(1);
    5000:	4505                	li	a0,1
    5002:	00000097          	auipc	ra,0x0
    5006:	376080e7          	jalr	886(ra) # 5378 <exit>
  for (struct test *t = tests; t->s != 0; t++) {
    500a:	04c1                	addi	s1,s1,16
    500c:	6488                	ld	a0,8(s1)
    500e:	c115                	beqz	a0,5032 <main+0x15c>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    5010:	00090863          	beqz	s2,5020 <main+0x14a>
    5014:	85ca                	mv	a1,s2
    5016:	00000097          	auipc	ra,0x0
    501a:	108080e7          	jalr	264(ra) # 511e <strcmp>
    501e:	f575                	bnez	a0,500a <main+0x134>
      if(!run(t->f, t->s))
    5020:	648c                	ld	a1,8(s1)
    5022:	6088                	ld	a0,0(s1)
    5024:	00000097          	auipc	ra,0x0
    5028:	e14080e7          	jalr	-492(ra) # 4e38 <run>
    502c:	fd79                	bnez	a0,500a <main+0x134>
        fail = 1;
    502e:	89d6                	mv	s3,s5
    5030:	bfe9                	j	500a <main+0x134>
  if(fail){
    5032:	f20989e3          	beqz	s3,4f64 <main+0x8e>
    printf("SOME TESTS FAILED\n");
    5036:	00003517          	auipc	a0,0x3
    503a:	a6a50513          	addi	a0,a0,-1430 # 7aa0 <malloc+0x22f2>
    503e:	00000097          	auipc	ra,0x0
    5042:	6b2080e7          	jalr	1714(ra) # 56f0 <printf>
    exit(1);
    5046:	4505                	li	a0,1
    5048:	00000097          	auipc	ra,0x0
    504c:	330080e7          	jalr	816(ra) # 5378 <exit>
  } else {
    printf("ALL TESTS PASSED\n");
    5050:	00003517          	auipc	a0,0x3
    5054:	a9850513          	addi	a0,a0,-1384 # 7ae8 <malloc+0x233a>
    5058:	00000097          	auipc	ra,0x0
    505c:	698080e7          	jalr	1688(ra) # 56f0 <printf>
    exit(0);
    5060:	4501                	li	a0,0
    5062:	00000097          	auipc	ra,0x0
    5066:	316080e7          	jalr	790(ra) # 5378 <exit>
        printf("SOME TESTS FAILED\n");
    506a:	8556                	mv	a0,s5
    506c:	00000097          	auipc	ra,0x0
    5070:	684080e7          	jalr	1668(ra) # 56f0 <printf>
        if(continuous != 2)
    5074:	f74998e3          	bne	s3,s4,4fe4 <main+0x10e>
      int free1 = countfree();
    5078:	00000097          	auipc	ra,0x0
    507c:	c8e080e7          	jalr	-882(ra) # 4d06 <countfree>
      if(free1 < free0){
    5080:	f72547e3          	blt	a0,s2,4fee <main+0x118>
      int free0 = countfree();
    5084:	00000097          	auipc	ra,0x0
    5088:	c82080e7          	jalr	-894(ra) # 4d06 <countfree>
    508c:	892a                	mv	s2,a0
      for (struct test *t = tests; t->s != 0; t++) {
    508e:	c4843583          	ld	a1,-952(s0)
    5092:	d1fd                	beqz	a1,5078 <main+0x1a2>
    5094:	c4040493          	addi	s1,s0,-960
        if(!run(t->f, t->s)){
    5098:	6088                	ld	a0,0(s1)
    509a:	00000097          	auipc	ra,0x0
    509e:	d9e080e7          	jalr	-610(ra) # 4e38 <run>
    50a2:	d561                	beqz	a0,506a <main+0x194>
      for (struct test *t = tests; t->s != 0; t++) {
    50a4:	04c1                	addi	s1,s1,16
    50a6:	648c                	ld	a1,8(s1)
    50a8:	f9e5                	bnez	a1,5098 <main+0x1c2>
    50aa:	b7f9                	j	5078 <main+0x1a2>
    continuous = 1;
    50ac:	4985                	li	s3,1
  } tests[] = {
    50ae:	00003797          	auipc	a5,0x3
    50b2:	ab278793          	addi	a5,a5,-1358 # 7b60 <malloc+0x23b2>
    50b6:	c4040713          	addi	a4,s0,-960
    50ba:	00003817          	auipc	a6,0x3
    50be:	e2680813          	addi	a6,a6,-474 # 7ee0 <malloc+0x2732>
    50c2:	6388                	ld	a0,0(a5)
    50c4:	678c                	ld	a1,8(a5)
    50c6:	6b90                	ld	a2,16(a5)
    50c8:	6f94                	ld	a3,24(a5)
    50ca:	e308                	sd	a0,0(a4)
    50cc:	e70c                	sd	a1,8(a4)
    50ce:	eb10                	sd	a2,16(a4)
    50d0:	ef14                	sd	a3,24(a4)
    50d2:	02078793          	addi	a5,a5,32
    50d6:	02070713          	addi	a4,a4,32
    50da:	ff0794e3          	bne	a5,a6,50c2 <main+0x1ec>
    printf("continuous usertests starting\n");
    50de:	00003517          	auipc	a0,0x3
    50e2:	a3a50513          	addi	a0,a0,-1478 # 7b18 <malloc+0x236a>
    50e6:	00000097          	auipc	ra,0x0
    50ea:	60a080e7          	jalr	1546(ra) # 56f0 <printf>
        printf("SOME TESTS FAILED\n");
    50ee:	00003a97          	auipc	s5,0x3
    50f2:	9b2a8a93          	addi	s5,s5,-1614 # 7aa0 <malloc+0x22f2>
        if(continuous != 2)
    50f6:	4a09                	li	s4,2
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    50f8:	00003b17          	auipc	s6,0x3
    50fc:	988b0b13          	addi	s6,s6,-1656 # 7a80 <malloc+0x22d2>
    5100:	b751                	j	5084 <main+0x1ae>

0000000000005102 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
    5102:	1141                	addi	sp,sp,-16
    5104:	e422                	sd	s0,8(sp)
    5106:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    5108:	87aa                	mv	a5,a0
    510a:	0585                	addi	a1,a1,1
    510c:	0785                	addi	a5,a5,1
    510e:	fff5c703          	lbu	a4,-1(a1)
    5112:	fee78fa3          	sb	a4,-1(a5)
    5116:	fb75                	bnez	a4,510a <strcpy+0x8>
    ;
  return os;
}
    5118:	6422                	ld	s0,8(sp)
    511a:	0141                	addi	sp,sp,16
    511c:	8082                	ret

000000000000511e <strcmp>:

int
strcmp(const char *p, const char *q)
{
    511e:	1141                	addi	sp,sp,-16
    5120:	e422                	sd	s0,8(sp)
    5122:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    5124:	00054783          	lbu	a5,0(a0)
    5128:	cb91                	beqz	a5,513c <strcmp+0x1e>
    512a:	0005c703          	lbu	a4,0(a1)
    512e:	00f71763          	bne	a4,a5,513c <strcmp+0x1e>
    p++, q++;
    5132:	0505                	addi	a0,a0,1
    5134:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    5136:	00054783          	lbu	a5,0(a0)
    513a:	fbe5                	bnez	a5,512a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    513c:	0005c503          	lbu	a0,0(a1)
}
    5140:	40a7853b          	subw	a0,a5,a0
    5144:	6422                	ld	s0,8(sp)
    5146:	0141                	addi	sp,sp,16
    5148:	8082                	ret

000000000000514a <strlen>:

uint
strlen(const char *s)
{
    514a:	1141                	addi	sp,sp,-16
    514c:	e422                	sd	s0,8(sp)
    514e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    5150:	00054783          	lbu	a5,0(a0)
    5154:	cf91                	beqz	a5,5170 <strlen+0x26>
    5156:	0505                	addi	a0,a0,1
    5158:	87aa                	mv	a5,a0
    515a:	4685                	li	a3,1
    515c:	9e89                	subw	a3,a3,a0
    515e:	00f6853b          	addw	a0,a3,a5
    5162:	0785                	addi	a5,a5,1
    5164:	fff7c703          	lbu	a4,-1(a5)
    5168:	fb7d                	bnez	a4,515e <strlen+0x14>
    ;
  return n;
}
    516a:	6422                	ld	s0,8(sp)
    516c:	0141                	addi	sp,sp,16
    516e:	8082                	ret
  for(n = 0; s[n]; n++)
    5170:	4501                	li	a0,0
    5172:	bfe5                	j	516a <strlen+0x20>

0000000000005174 <memset>:

void*
memset(void *dst, int c, uint n)
{
    5174:	1141                	addi	sp,sp,-16
    5176:	e422                	sd	s0,8(sp)
    5178:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    517a:	ce09                	beqz	a2,5194 <memset+0x20>
    517c:	87aa                	mv	a5,a0
    517e:	fff6071b          	addiw	a4,a2,-1
    5182:	1702                	slli	a4,a4,0x20
    5184:	9301                	srli	a4,a4,0x20
    5186:	0705                	addi	a4,a4,1
    5188:	972a                	add	a4,a4,a0
    cdst[i] = c;
    518a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    518e:	0785                	addi	a5,a5,1
    5190:	fee79de3          	bne	a5,a4,518a <memset+0x16>
  }
  return dst;
}
    5194:	6422                	ld	s0,8(sp)
    5196:	0141                	addi	sp,sp,16
    5198:	8082                	ret

000000000000519a <strchr>:

char*
strchr(const char *s, char c)
{
    519a:	1141                	addi	sp,sp,-16
    519c:	e422                	sd	s0,8(sp)
    519e:	0800                	addi	s0,sp,16
  for(; *s; s++)
    51a0:	00054783          	lbu	a5,0(a0)
    51a4:	cb99                	beqz	a5,51ba <strchr+0x20>
    if(*s == c)
    51a6:	00f58763          	beq	a1,a5,51b4 <strchr+0x1a>
  for(; *s; s++)
    51aa:	0505                	addi	a0,a0,1
    51ac:	00054783          	lbu	a5,0(a0)
    51b0:	fbfd                	bnez	a5,51a6 <strchr+0xc>
      return (char*)s;
  return 0;
    51b2:	4501                	li	a0,0
}
    51b4:	6422                	ld	s0,8(sp)
    51b6:	0141                	addi	sp,sp,16
    51b8:	8082                	ret
  return 0;
    51ba:	4501                	li	a0,0
    51bc:	bfe5                	j	51b4 <strchr+0x1a>

00000000000051be <gets>:

char*
gets(char *buf, int max)
{
    51be:	711d                	addi	sp,sp,-96
    51c0:	ec86                	sd	ra,88(sp)
    51c2:	e8a2                	sd	s0,80(sp)
    51c4:	e4a6                	sd	s1,72(sp)
    51c6:	e0ca                	sd	s2,64(sp)
    51c8:	fc4e                	sd	s3,56(sp)
    51ca:	f852                	sd	s4,48(sp)
    51cc:	f456                	sd	s5,40(sp)
    51ce:	f05a                	sd	s6,32(sp)
    51d0:	ec5e                	sd	s7,24(sp)
    51d2:	1080                	addi	s0,sp,96
    51d4:	8baa                	mv	s7,a0
    51d6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    51d8:	892a                	mv	s2,a0
    51da:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    51dc:	4aa9                	li	s5,10
    51de:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    51e0:	89a6                	mv	s3,s1
    51e2:	2485                	addiw	s1,s1,1
    51e4:	0344d863          	bge	s1,s4,5214 <gets+0x56>
    cc = read(0, &c, 1);
    51e8:	4605                	li	a2,1
    51ea:	faf40593          	addi	a1,s0,-81
    51ee:	4501                	li	a0,0
    51f0:	00000097          	auipc	ra,0x0
    51f4:	1a0080e7          	jalr	416(ra) # 5390 <read>
    if(cc < 1)
    51f8:	00a05e63          	blez	a0,5214 <gets+0x56>
    buf[i++] = c;
    51fc:	faf44783          	lbu	a5,-81(s0)
    5200:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    5204:	01578763          	beq	a5,s5,5212 <gets+0x54>
    5208:	0905                	addi	s2,s2,1
    520a:	fd679be3          	bne	a5,s6,51e0 <gets+0x22>
  for(i=0; i+1 < max; ){
    520e:	89a6                	mv	s3,s1
    5210:	a011                	j	5214 <gets+0x56>
    5212:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    5214:	99de                	add	s3,s3,s7
    5216:	00098023          	sb	zero,0(s3)
  return buf;
}
    521a:	855e                	mv	a0,s7
    521c:	60e6                	ld	ra,88(sp)
    521e:	6446                	ld	s0,80(sp)
    5220:	64a6                	ld	s1,72(sp)
    5222:	6906                	ld	s2,64(sp)
    5224:	79e2                	ld	s3,56(sp)
    5226:	7a42                	ld	s4,48(sp)
    5228:	7aa2                	ld	s5,40(sp)
    522a:	7b02                	ld	s6,32(sp)
    522c:	6be2                	ld	s7,24(sp)
    522e:	6125                	addi	sp,sp,96
    5230:	8082                	ret

0000000000005232 <stat>:

int
stat(const char *n, struct stat *st)
{
    5232:	1101                	addi	sp,sp,-32
    5234:	ec06                	sd	ra,24(sp)
    5236:	e822                	sd	s0,16(sp)
    5238:	e426                	sd	s1,8(sp)
    523a:	e04a                	sd	s2,0(sp)
    523c:	1000                	addi	s0,sp,32
    523e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    5240:	4581                	li	a1,0
    5242:	00000097          	auipc	ra,0x0
    5246:	176080e7          	jalr	374(ra) # 53b8 <open>
  if(fd < 0)
    524a:	02054563          	bltz	a0,5274 <stat+0x42>
    524e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    5250:	85ca                	mv	a1,s2
    5252:	00000097          	auipc	ra,0x0
    5256:	17e080e7          	jalr	382(ra) # 53d0 <fstat>
    525a:	892a                	mv	s2,a0
  close(fd);
    525c:	8526                	mv	a0,s1
    525e:	00000097          	auipc	ra,0x0
    5262:	142080e7          	jalr	322(ra) # 53a0 <close>
  return r;
}
    5266:	854a                	mv	a0,s2
    5268:	60e2                	ld	ra,24(sp)
    526a:	6442                	ld	s0,16(sp)
    526c:	64a2                	ld	s1,8(sp)
    526e:	6902                	ld	s2,0(sp)
    5270:	6105                	addi	sp,sp,32
    5272:	8082                	ret
    return -1;
    5274:	597d                	li	s2,-1
    5276:	bfc5                	j	5266 <stat+0x34>

0000000000005278 <atoi>:

int
atoi(const char *s)
{
    5278:	1141                	addi	sp,sp,-16
    527a:	e422                	sd	s0,8(sp)
    527c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    527e:	00054603          	lbu	a2,0(a0)
    5282:	fd06079b          	addiw	a5,a2,-48
    5286:	0ff7f793          	andi	a5,a5,255
    528a:	4725                	li	a4,9
    528c:	02f76963          	bltu	a4,a5,52be <atoi+0x46>
    5290:	86aa                	mv	a3,a0
  n = 0;
    5292:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    5294:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    5296:	0685                	addi	a3,a3,1
    5298:	0025179b          	slliw	a5,a0,0x2
    529c:	9fa9                	addw	a5,a5,a0
    529e:	0017979b          	slliw	a5,a5,0x1
    52a2:	9fb1                	addw	a5,a5,a2
    52a4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    52a8:	0006c603          	lbu	a2,0(a3) # 1000 <bigdir+0x96>
    52ac:	fd06071b          	addiw	a4,a2,-48
    52b0:	0ff77713          	andi	a4,a4,255
    52b4:	fee5f1e3          	bgeu	a1,a4,5296 <atoi+0x1e>
  return n;
}
    52b8:	6422                	ld	s0,8(sp)
    52ba:	0141                	addi	sp,sp,16
    52bc:	8082                	ret
  n = 0;
    52be:	4501                	li	a0,0
    52c0:	bfe5                	j	52b8 <atoi+0x40>

00000000000052c2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    52c2:	1141                	addi	sp,sp,-16
    52c4:	e422                	sd	s0,8(sp)
    52c6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    52c8:	02b57663          	bgeu	a0,a1,52f4 <memmove+0x32>
    while(n-- > 0)
    52cc:	02c05163          	blez	a2,52ee <memmove+0x2c>
    52d0:	fff6079b          	addiw	a5,a2,-1
    52d4:	1782                	slli	a5,a5,0x20
    52d6:	9381                	srli	a5,a5,0x20
    52d8:	0785                	addi	a5,a5,1
    52da:	97aa                	add	a5,a5,a0
  dst = vdst;
    52dc:	872a                	mv	a4,a0
      *dst++ = *src++;
    52de:	0585                	addi	a1,a1,1
    52e0:	0705                	addi	a4,a4,1
    52e2:	fff5c683          	lbu	a3,-1(a1)
    52e6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    52ea:	fee79ae3          	bne	a5,a4,52de <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    52ee:	6422                	ld	s0,8(sp)
    52f0:	0141                	addi	sp,sp,16
    52f2:	8082                	ret
    dst += n;
    52f4:	00c50733          	add	a4,a0,a2
    src += n;
    52f8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    52fa:	fec05ae3          	blez	a2,52ee <memmove+0x2c>
    52fe:	fff6079b          	addiw	a5,a2,-1
    5302:	1782                	slli	a5,a5,0x20
    5304:	9381                	srli	a5,a5,0x20
    5306:	fff7c793          	not	a5,a5
    530a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    530c:	15fd                	addi	a1,a1,-1
    530e:	177d                	addi	a4,a4,-1
    5310:	0005c683          	lbu	a3,0(a1)
    5314:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    5318:	fee79ae3          	bne	a5,a4,530c <memmove+0x4a>
    531c:	bfc9                	j	52ee <memmove+0x2c>

000000000000531e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    531e:	1141                	addi	sp,sp,-16
    5320:	e422                	sd	s0,8(sp)
    5322:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    5324:	ca05                	beqz	a2,5354 <memcmp+0x36>
    5326:	fff6069b          	addiw	a3,a2,-1
    532a:	1682                	slli	a3,a3,0x20
    532c:	9281                	srli	a3,a3,0x20
    532e:	0685                	addi	a3,a3,1
    5330:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    5332:	00054783          	lbu	a5,0(a0)
    5336:	0005c703          	lbu	a4,0(a1)
    533a:	00e79863          	bne	a5,a4,534a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    533e:	0505                	addi	a0,a0,1
    p2++;
    5340:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    5342:	fed518e3          	bne	a0,a3,5332 <memcmp+0x14>
  }
  return 0;
    5346:	4501                	li	a0,0
    5348:	a019                	j	534e <memcmp+0x30>
      return *p1 - *p2;
    534a:	40e7853b          	subw	a0,a5,a4
}
    534e:	6422                	ld	s0,8(sp)
    5350:	0141                	addi	sp,sp,16
    5352:	8082                	ret
  return 0;
    5354:	4501                	li	a0,0
    5356:	bfe5                	j	534e <memcmp+0x30>

0000000000005358 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    5358:	1141                	addi	sp,sp,-16
    535a:	e406                	sd	ra,8(sp)
    535c:	e022                	sd	s0,0(sp)
    535e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    5360:	00000097          	auipc	ra,0x0
    5364:	f62080e7          	jalr	-158(ra) # 52c2 <memmove>
}
    5368:	60a2                	ld	ra,8(sp)
    536a:	6402                	ld	s0,0(sp)
    536c:	0141                	addi	sp,sp,16
    536e:	8082                	ret

0000000000005370 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    5370:	4885                	li	a7,1
 ecall
    5372:	00000073          	ecall
 ret
    5376:	8082                	ret

0000000000005378 <exit>:
.global exit
exit:
 li a7, SYS_exit
    5378:	4889                	li	a7,2
 ecall
    537a:	00000073          	ecall
 ret
    537e:	8082                	ret

0000000000005380 <wait>:
.global wait
wait:
 li a7, SYS_wait
    5380:	488d                	li	a7,3
 ecall
    5382:	00000073          	ecall
 ret
    5386:	8082                	ret

0000000000005388 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    5388:	4891                	li	a7,4
 ecall
    538a:	00000073          	ecall
 ret
    538e:	8082                	ret

0000000000005390 <read>:
.global read
read:
 li a7, SYS_read
    5390:	4895                	li	a7,5
 ecall
    5392:	00000073          	ecall
 ret
    5396:	8082                	ret

0000000000005398 <write>:
.global write
write:
 li a7, SYS_write
    5398:	48c1                	li	a7,16
 ecall
    539a:	00000073          	ecall
 ret
    539e:	8082                	ret

00000000000053a0 <close>:
.global close
close:
 li a7, SYS_close
    53a0:	48d5                	li	a7,21
 ecall
    53a2:	00000073          	ecall
 ret
    53a6:	8082                	ret

00000000000053a8 <kill>:
.global kill
kill:
 li a7, SYS_kill
    53a8:	4899                	li	a7,6
 ecall
    53aa:	00000073          	ecall
 ret
    53ae:	8082                	ret

00000000000053b0 <exec>:
.global exec
exec:
 li a7, SYS_exec
    53b0:	489d                	li	a7,7
 ecall
    53b2:	00000073          	ecall
 ret
    53b6:	8082                	ret

00000000000053b8 <open>:
.global open
open:
 li a7, SYS_open
    53b8:	48bd                	li	a7,15
 ecall
    53ba:	00000073          	ecall
 ret
    53be:	8082                	ret

00000000000053c0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    53c0:	48c5                	li	a7,17
 ecall
    53c2:	00000073          	ecall
 ret
    53c6:	8082                	ret

00000000000053c8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    53c8:	48c9                	li	a7,18
 ecall
    53ca:	00000073          	ecall
 ret
    53ce:	8082                	ret

00000000000053d0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    53d0:	48a1                	li	a7,8
 ecall
    53d2:	00000073          	ecall
 ret
    53d6:	8082                	ret

00000000000053d8 <link>:
.global link
link:
 li a7, SYS_link
    53d8:	48cd                	li	a7,19
 ecall
    53da:	00000073          	ecall
 ret
    53de:	8082                	ret

00000000000053e0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    53e0:	48d1                	li	a7,20
 ecall
    53e2:	00000073          	ecall
 ret
    53e6:	8082                	ret

00000000000053e8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    53e8:	48a5                	li	a7,9
 ecall
    53ea:	00000073          	ecall
 ret
    53ee:	8082                	ret

00000000000053f0 <dup>:
.global dup
dup:
 li a7, SYS_dup
    53f0:	48a9                	li	a7,10
 ecall
    53f2:	00000073          	ecall
 ret
    53f6:	8082                	ret

00000000000053f8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    53f8:	48ad                	li	a7,11
 ecall
    53fa:	00000073          	ecall
 ret
    53fe:	8082                	ret

0000000000005400 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    5400:	48b1                	li	a7,12
 ecall
    5402:	00000073          	ecall
 ret
    5406:	8082                	ret

0000000000005408 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    5408:	48b5                	li	a7,13
 ecall
    540a:	00000073          	ecall
 ret
    540e:	8082                	ret

0000000000005410 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    5410:	48b9                	li	a7,14
 ecall
    5412:	00000073          	ecall
 ret
    5416:	8082                	ret

0000000000005418 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    5418:	1101                	addi	sp,sp,-32
    541a:	ec06                	sd	ra,24(sp)
    541c:	e822                	sd	s0,16(sp)
    541e:	1000                	addi	s0,sp,32
    5420:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    5424:	4605                	li	a2,1
    5426:	fef40593          	addi	a1,s0,-17
    542a:	00000097          	auipc	ra,0x0
    542e:	f6e080e7          	jalr	-146(ra) # 5398 <write>
}
    5432:	60e2                	ld	ra,24(sp)
    5434:	6442                	ld	s0,16(sp)
    5436:	6105                	addi	sp,sp,32
    5438:	8082                	ret

000000000000543a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    543a:	7139                	addi	sp,sp,-64
    543c:	fc06                	sd	ra,56(sp)
    543e:	f822                	sd	s0,48(sp)
    5440:	f426                	sd	s1,40(sp)
    5442:	f04a                	sd	s2,32(sp)
    5444:	ec4e                	sd	s3,24(sp)
    5446:	0080                	addi	s0,sp,64
    5448:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    544a:	c299                	beqz	a3,5450 <printint+0x16>
    544c:	0805c863          	bltz	a1,54dc <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    5450:	2581                	sext.w	a1,a1
  neg = 0;
    5452:	4881                	li	a7,0
    5454:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    5458:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    545a:	2601                	sext.w	a2,a2
    545c:	00003517          	auipc	a0,0x3
    5460:	a8c50513          	addi	a0,a0,-1396 # 7ee8 <digits>
    5464:	883a                	mv	a6,a4
    5466:	2705                	addiw	a4,a4,1
    5468:	02c5f7bb          	remuw	a5,a1,a2
    546c:	1782                	slli	a5,a5,0x20
    546e:	9381                	srli	a5,a5,0x20
    5470:	97aa                	add	a5,a5,a0
    5472:	0007c783          	lbu	a5,0(a5)
    5476:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    547a:	0005879b          	sext.w	a5,a1
    547e:	02c5d5bb          	divuw	a1,a1,a2
    5482:	0685                	addi	a3,a3,1
    5484:	fec7f0e3          	bgeu	a5,a2,5464 <printint+0x2a>
  if(neg)
    5488:	00088b63          	beqz	a7,549e <printint+0x64>
    buf[i++] = '-';
    548c:	fd040793          	addi	a5,s0,-48
    5490:	973e                	add	a4,a4,a5
    5492:	02d00793          	li	a5,45
    5496:	fef70823          	sb	a5,-16(a4)
    549a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    549e:	02e05863          	blez	a4,54ce <printint+0x94>
    54a2:	fc040793          	addi	a5,s0,-64
    54a6:	00e78933          	add	s2,a5,a4
    54aa:	fff78993          	addi	s3,a5,-1
    54ae:	99ba                	add	s3,s3,a4
    54b0:	377d                	addiw	a4,a4,-1
    54b2:	1702                	slli	a4,a4,0x20
    54b4:	9301                	srli	a4,a4,0x20
    54b6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    54ba:	fff94583          	lbu	a1,-1(s2)
    54be:	8526                	mv	a0,s1
    54c0:	00000097          	auipc	ra,0x0
    54c4:	f58080e7          	jalr	-168(ra) # 5418 <putc>
  while(--i >= 0)
    54c8:	197d                	addi	s2,s2,-1
    54ca:	ff3918e3          	bne	s2,s3,54ba <printint+0x80>
}
    54ce:	70e2                	ld	ra,56(sp)
    54d0:	7442                	ld	s0,48(sp)
    54d2:	74a2                	ld	s1,40(sp)
    54d4:	7902                	ld	s2,32(sp)
    54d6:	69e2                	ld	s3,24(sp)
    54d8:	6121                	addi	sp,sp,64
    54da:	8082                	ret
    x = -xx;
    54dc:	40b005bb          	negw	a1,a1
    neg = 1;
    54e0:	4885                	li	a7,1
    x = -xx;
    54e2:	bf8d                	j	5454 <printint+0x1a>

00000000000054e4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    54e4:	7119                	addi	sp,sp,-128
    54e6:	fc86                	sd	ra,120(sp)
    54e8:	f8a2                	sd	s0,112(sp)
    54ea:	f4a6                	sd	s1,104(sp)
    54ec:	f0ca                	sd	s2,96(sp)
    54ee:	ecce                	sd	s3,88(sp)
    54f0:	e8d2                	sd	s4,80(sp)
    54f2:	e4d6                	sd	s5,72(sp)
    54f4:	e0da                	sd	s6,64(sp)
    54f6:	fc5e                	sd	s7,56(sp)
    54f8:	f862                	sd	s8,48(sp)
    54fa:	f466                	sd	s9,40(sp)
    54fc:	f06a                	sd	s10,32(sp)
    54fe:	ec6e                	sd	s11,24(sp)
    5500:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    5502:	0005c903          	lbu	s2,0(a1)
    5506:	18090f63          	beqz	s2,56a4 <vprintf+0x1c0>
    550a:	8aaa                	mv	s5,a0
    550c:	8b32                	mv	s6,a2
    550e:	00158493          	addi	s1,a1,1
  state = 0;
    5512:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    5514:	02500a13          	li	s4,37
      if(c == 'd'){
    5518:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    551c:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    5520:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    5524:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5528:	00003b97          	auipc	s7,0x3
    552c:	9c0b8b93          	addi	s7,s7,-1600 # 7ee8 <digits>
    5530:	a839                	j	554e <vprintf+0x6a>
        putc(fd, c);
    5532:	85ca                	mv	a1,s2
    5534:	8556                	mv	a0,s5
    5536:	00000097          	auipc	ra,0x0
    553a:	ee2080e7          	jalr	-286(ra) # 5418 <putc>
    553e:	a019                	j	5544 <vprintf+0x60>
    } else if(state == '%'){
    5540:	01498f63          	beq	s3,s4,555e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    5544:	0485                	addi	s1,s1,1
    5546:	fff4c903          	lbu	s2,-1(s1)
    554a:	14090d63          	beqz	s2,56a4 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    554e:	0009079b          	sext.w	a5,s2
    if(state == 0){
    5552:	fe0997e3          	bnez	s3,5540 <vprintf+0x5c>
      if(c == '%'){
    5556:	fd479ee3          	bne	a5,s4,5532 <vprintf+0x4e>
        state = '%';
    555a:	89be                	mv	s3,a5
    555c:	b7e5                	j	5544 <vprintf+0x60>
      if(c == 'd'){
    555e:	05878063          	beq	a5,s8,559e <vprintf+0xba>
      } else if(c == 'l') {
    5562:	05978c63          	beq	a5,s9,55ba <vprintf+0xd6>
      } else if(c == 'x') {
    5566:	07a78863          	beq	a5,s10,55d6 <vprintf+0xf2>
      } else if(c == 'p') {
    556a:	09b78463          	beq	a5,s11,55f2 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    556e:	07300713          	li	a4,115
    5572:	0ce78663          	beq	a5,a4,563e <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    5576:	06300713          	li	a4,99
    557a:	0ee78e63          	beq	a5,a4,5676 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    557e:	11478863          	beq	a5,s4,568e <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    5582:	85d2                	mv	a1,s4
    5584:	8556                	mv	a0,s5
    5586:	00000097          	auipc	ra,0x0
    558a:	e92080e7          	jalr	-366(ra) # 5418 <putc>
        putc(fd, c);
    558e:	85ca                	mv	a1,s2
    5590:	8556                	mv	a0,s5
    5592:	00000097          	auipc	ra,0x0
    5596:	e86080e7          	jalr	-378(ra) # 5418 <putc>
      }
      state = 0;
    559a:	4981                	li	s3,0
    559c:	b765                	j	5544 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    559e:	008b0913          	addi	s2,s6,8
    55a2:	4685                	li	a3,1
    55a4:	4629                	li	a2,10
    55a6:	000b2583          	lw	a1,0(s6)
    55aa:	8556                	mv	a0,s5
    55ac:	00000097          	auipc	ra,0x0
    55b0:	e8e080e7          	jalr	-370(ra) # 543a <printint>
    55b4:	8b4a                	mv	s6,s2
      state = 0;
    55b6:	4981                	li	s3,0
    55b8:	b771                	j	5544 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    55ba:	008b0913          	addi	s2,s6,8
    55be:	4681                	li	a3,0
    55c0:	4629                	li	a2,10
    55c2:	000b2583          	lw	a1,0(s6)
    55c6:	8556                	mv	a0,s5
    55c8:	00000097          	auipc	ra,0x0
    55cc:	e72080e7          	jalr	-398(ra) # 543a <printint>
    55d0:	8b4a                	mv	s6,s2
      state = 0;
    55d2:	4981                	li	s3,0
    55d4:	bf85                	j	5544 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    55d6:	008b0913          	addi	s2,s6,8
    55da:	4681                	li	a3,0
    55dc:	4641                	li	a2,16
    55de:	000b2583          	lw	a1,0(s6)
    55e2:	8556                	mv	a0,s5
    55e4:	00000097          	auipc	ra,0x0
    55e8:	e56080e7          	jalr	-426(ra) # 543a <printint>
    55ec:	8b4a                	mv	s6,s2
      state = 0;
    55ee:	4981                	li	s3,0
    55f0:	bf91                	j	5544 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    55f2:	008b0793          	addi	a5,s6,8
    55f6:	f8f43423          	sd	a5,-120(s0)
    55fa:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    55fe:	03000593          	li	a1,48
    5602:	8556                	mv	a0,s5
    5604:	00000097          	auipc	ra,0x0
    5608:	e14080e7          	jalr	-492(ra) # 5418 <putc>
  putc(fd, 'x');
    560c:	85ea                	mv	a1,s10
    560e:	8556                	mv	a0,s5
    5610:	00000097          	auipc	ra,0x0
    5614:	e08080e7          	jalr	-504(ra) # 5418 <putc>
    5618:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    561a:	03c9d793          	srli	a5,s3,0x3c
    561e:	97de                	add	a5,a5,s7
    5620:	0007c583          	lbu	a1,0(a5)
    5624:	8556                	mv	a0,s5
    5626:	00000097          	auipc	ra,0x0
    562a:	df2080e7          	jalr	-526(ra) # 5418 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    562e:	0992                	slli	s3,s3,0x4
    5630:	397d                	addiw	s2,s2,-1
    5632:	fe0914e3          	bnez	s2,561a <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    5636:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    563a:	4981                	li	s3,0
    563c:	b721                	j	5544 <vprintf+0x60>
        s = va_arg(ap, char*);
    563e:	008b0993          	addi	s3,s6,8
    5642:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    5646:	02090163          	beqz	s2,5668 <vprintf+0x184>
        while(*s != 0){
    564a:	00094583          	lbu	a1,0(s2)
    564e:	c9a1                	beqz	a1,569e <vprintf+0x1ba>
          putc(fd, *s);
    5650:	8556                	mv	a0,s5
    5652:	00000097          	auipc	ra,0x0
    5656:	dc6080e7          	jalr	-570(ra) # 5418 <putc>
          s++;
    565a:	0905                	addi	s2,s2,1
        while(*s != 0){
    565c:	00094583          	lbu	a1,0(s2)
    5660:	f9e5                	bnez	a1,5650 <vprintf+0x16c>
        s = va_arg(ap, char*);
    5662:	8b4e                	mv	s6,s3
      state = 0;
    5664:	4981                	li	s3,0
    5666:	bdf9                	j	5544 <vprintf+0x60>
          s = "(null)";
    5668:	00003917          	auipc	s2,0x3
    566c:	87890913          	addi	s2,s2,-1928 # 7ee0 <malloc+0x2732>
        while(*s != 0){
    5670:	02800593          	li	a1,40
    5674:	bff1                	j	5650 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    5676:	008b0913          	addi	s2,s6,8
    567a:	000b4583          	lbu	a1,0(s6)
    567e:	8556                	mv	a0,s5
    5680:	00000097          	auipc	ra,0x0
    5684:	d98080e7          	jalr	-616(ra) # 5418 <putc>
    5688:	8b4a                	mv	s6,s2
      state = 0;
    568a:	4981                	li	s3,0
    568c:	bd65                	j	5544 <vprintf+0x60>
        putc(fd, c);
    568e:	85d2                	mv	a1,s4
    5690:	8556                	mv	a0,s5
    5692:	00000097          	auipc	ra,0x0
    5696:	d86080e7          	jalr	-634(ra) # 5418 <putc>
      state = 0;
    569a:	4981                	li	s3,0
    569c:	b565                	j	5544 <vprintf+0x60>
        s = va_arg(ap, char*);
    569e:	8b4e                	mv	s6,s3
      state = 0;
    56a0:	4981                	li	s3,0
    56a2:	b54d                	j	5544 <vprintf+0x60>
    }
  }
}
    56a4:	70e6                	ld	ra,120(sp)
    56a6:	7446                	ld	s0,112(sp)
    56a8:	74a6                	ld	s1,104(sp)
    56aa:	7906                	ld	s2,96(sp)
    56ac:	69e6                	ld	s3,88(sp)
    56ae:	6a46                	ld	s4,80(sp)
    56b0:	6aa6                	ld	s5,72(sp)
    56b2:	6b06                	ld	s6,64(sp)
    56b4:	7be2                	ld	s7,56(sp)
    56b6:	7c42                	ld	s8,48(sp)
    56b8:	7ca2                	ld	s9,40(sp)
    56ba:	7d02                	ld	s10,32(sp)
    56bc:	6de2                	ld	s11,24(sp)
    56be:	6109                	addi	sp,sp,128
    56c0:	8082                	ret

00000000000056c2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    56c2:	715d                	addi	sp,sp,-80
    56c4:	ec06                	sd	ra,24(sp)
    56c6:	e822                	sd	s0,16(sp)
    56c8:	1000                	addi	s0,sp,32
    56ca:	e010                	sd	a2,0(s0)
    56cc:	e414                	sd	a3,8(s0)
    56ce:	e818                	sd	a4,16(s0)
    56d0:	ec1c                	sd	a5,24(s0)
    56d2:	03043023          	sd	a6,32(s0)
    56d6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    56da:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    56de:	8622                	mv	a2,s0
    56e0:	00000097          	auipc	ra,0x0
    56e4:	e04080e7          	jalr	-508(ra) # 54e4 <vprintf>
}
    56e8:	60e2                	ld	ra,24(sp)
    56ea:	6442                	ld	s0,16(sp)
    56ec:	6161                	addi	sp,sp,80
    56ee:	8082                	ret

00000000000056f0 <printf>:

void
printf(const char *fmt, ...)
{
    56f0:	711d                	addi	sp,sp,-96
    56f2:	ec06                	sd	ra,24(sp)
    56f4:	e822                	sd	s0,16(sp)
    56f6:	1000                	addi	s0,sp,32
    56f8:	e40c                	sd	a1,8(s0)
    56fa:	e810                	sd	a2,16(s0)
    56fc:	ec14                	sd	a3,24(s0)
    56fe:	f018                	sd	a4,32(s0)
    5700:	f41c                	sd	a5,40(s0)
    5702:	03043823          	sd	a6,48(s0)
    5706:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    570a:	00840613          	addi	a2,s0,8
    570e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    5712:	85aa                	mv	a1,a0
    5714:	4505                	li	a0,1
    5716:	00000097          	auipc	ra,0x0
    571a:	dce080e7          	jalr	-562(ra) # 54e4 <vprintf>
}
    571e:	60e2                	ld	ra,24(sp)
    5720:	6442                	ld	s0,16(sp)
    5722:	6125                	addi	sp,sp,96
    5724:	8082                	ret

0000000000005726 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    5726:	1141                	addi	sp,sp,-16
    5728:	e422                	sd	s0,8(sp)
    572a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    572c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5730:	00002797          	auipc	a5,0x2
    5734:	7e87b783          	ld	a5,2024(a5) # 7f18 <freep>
    5738:	a805                	j	5768 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    573a:	4618                	lw	a4,8(a2)
    573c:	9db9                	addw	a1,a1,a4
    573e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    5742:	6398                	ld	a4,0(a5)
    5744:	6318                	ld	a4,0(a4)
    5746:	fee53823          	sd	a4,-16(a0)
    574a:	a091                	j	578e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    574c:	ff852703          	lw	a4,-8(a0)
    5750:	9e39                	addw	a2,a2,a4
    5752:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    5754:	ff053703          	ld	a4,-16(a0)
    5758:	e398                	sd	a4,0(a5)
    575a:	a099                	j	57a0 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    575c:	6398                	ld	a4,0(a5)
    575e:	00e7e463          	bltu	a5,a4,5766 <free+0x40>
    5762:	00e6ea63          	bltu	a3,a4,5776 <free+0x50>
{
    5766:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5768:	fed7fae3          	bgeu	a5,a3,575c <free+0x36>
    576c:	6398                	ld	a4,0(a5)
    576e:	00e6e463          	bltu	a3,a4,5776 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5772:	fee7eae3          	bltu	a5,a4,5766 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    5776:	ff852583          	lw	a1,-8(a0)
    577a:	6390                	ld	a2,0(a5)
    577c:	02059713          	slli	a4,a1,0x20
    5780:	9301                	srli	a4,a4,0x20
    5782:	0712                	slli	a4,a4,0x4
    5784:	9736                	add	a4,a4,a3
    5786:	fae60ae3          	beq	a2,a4,573a <free+0x14>
    bp->s.ptr = p->s.ptr;
    578a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    578e:	4790                	lw	a2,8(a5)
    5790:	02061713          	slli	a4,a2,0x20
    5794:	9301                	srli	a4,a4,0x20
    5796:	0712                	slli	a4,a4,0x4
    5798:	973e                	add	a4,a4,a5
    579a:	fae689e3          	beq	a3,a4,574c <free+0x26>
  } else
    p->s.ptr = bp;
    579e:	e394                	sd	a3,0(a5)
  freep = p;
    57a0:	00002717          	auipc	a4,0x2
    57a4:	76f73c23          	sd	a5,1912(a4) # 7f18 <freep>
}
    57a8:	6422                	ld	s0,8(sp)
    57aa:	0141                	addi	sp,sp,16
    57ac:	8082                	ret

00000000000057ae <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    57ae:	7139                	addi	sp,sp,-64
    57b0:	fc06                	sd	ra,56(sp)
    57b2:	f822                	sd	s0,48(sp)
    57b4:	f426                	sd	s1,40(sp)
    57b6:	f04a                	sd	s2,32(sp)
    57b8:	ec4e                	sd	s3,24(sp)
    57ba:	e852                	sd	s4,16(sp)
    57bc:	e456                	sd	s5,8(sp)
    57be:	e05a                	sd	s6,0(sp)
    57c0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    57c2:	02051493          	slli	s1,a0,0x20
    57c6:	9081                	srli	s1,s1,0x20
    57c8:	04bd                	addi	s1,s1,15
    57ca:	8091                	srli	s1,s1,0x4
    57cc:	0014899b          	addiw	s3,s1,1
    57d0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    57d2:	00002517          	auipc	a0,0x2
    57d6:	74653503          	ld	a0,1862(a0) # 7f18 <freep>
    57da:	c515                	beqz	a0,5806 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    57dc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    57de:	4798                	lw	a4,8(a5)
    57e0:	02977f63          	bgeu	a4,s1,581e <malloc+0x70>
    57e4:	8a4e                	mv	s4,s3
    57e6:	0009871b          	sext.w	a4,s3
    57ea:	6685                	lui	a3,0x1
    57ec:	00d77363          	bgeu	a4,a3,57f2 <malloc+0x44>
    57f0:	6a05                	lui	s4,0x1
    57f2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    57f6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    57fa:	00002917          	auipc	s2,0x2
    57fe:	71e90913          	addi	s2,s2,1822 # 7f18 <freep>
  if(p == (char*)-1)
    5802:	5afd                	li	s5,-1
    5804:	a88d                	j	5876 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    5806:	00009797          	auipc	a5,0x9
    580a:	f3278793          	addi	a5,a5,-206 # e738 <base>
    580e:	00002717          	auipc	a4,0x2
    5812:	70f73523          	sd	a5,1802(a4) # 7f18 <freep>
    5816:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    5818:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    581c:	b7e1                	j	57e4 <malloc+0x36>
      if(p->s.size == nunits)
    581e:	02e48b63          	beq	s1,a4,5854 <malloc+0xa6>
        p->s.size -= nunits;
    5822:	4137073b          	subw	a4,a4,s3
    5826:	c798                	sw	a4,8(a5)
        p += p->s.size;
    5828:	1702                	slli	a4,a4,0x20
    582a:	9301                	srli	a4,a4,0x20
    582c:	0712                	slli	a4,a4,0x4
    582e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    5830:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    5834:	00002717          	auipc	a4,0x2
    5838:	6ea73223          	sd	a0,1764(a4) # 7f18 <freep>
      return (void*)(p + 1);
    583c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    5840:	70e2                	ld	ra,56(sp)
    5842:	7442                	ld	s0,48(sp)
    5844:	74a2                	ld	s1,40(sp)
    5846:	7902                	ld	s2,32(sp)
    5848:	69e2                	ld	s3,24(sp)
    584a:	6a42                	ld	s4,16(sp)
    584c:	6aa2                	ld	s5,8(sp)
    584e:	6b02                	ld	s6,0(sp)
    5850:	6121                	addi	sp,sp,64
    5852:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    5854:	6398                	ld	a4,0(a5)
    5856:	e118                	sd	a4,0(a0)
    5858:	bff1                	j	5834 <malloc+0x86>
  hp->s.size = nu;
    585a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    585e:	0541                	addi	a0,a0,16
    5860:	00000097          	auipc	ra,0x0
    5864:	ec6080e7          	jalr	-314(ra) # 5726 <free>
  return freep;
    5868:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    586c:	d971                	beqz	a0,5840 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    586e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5870:	4798                	lw	a4,8(a5)
    5872:	fa9776e3          	bgeu	a4,s1,581e <malloc+0x70>
    if(p == freep)
    5876:	00093703          	ld	a4,0(s2)
    587a:	853e                	mv	a0,a5
    587c:	fef719e3          	bne	a4,a5,586e <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    5880:	8552                	mv	a0,s4
    5882:	00000097          	auipc	ra,0x0
    5886:	b7e080e7          	jalr	-1154(ra) # 5400 <sbrk>
  if(p == (char*)-1)
    588a:	fd5518e3          	bne	a0,s5,585a <malloc+0xac>
        return 0;
    588e:	4501                	li	a0,0
    5890:	bf45                	j	5840 <malloc+0x92>
