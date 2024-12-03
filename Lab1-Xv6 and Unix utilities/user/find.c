// user/find.c
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

// 递归查找函数，查找路径为 path 的目录下是否有目标文件 target
void find(char* path, char* target) {
	char buf[512], *p;
	int fd;
	struct dirent de;
	struct stat st;
    // 打开目录
	if((fd = open(path, 0)) < 0){
		fprintf(2, "find: cannot open %s\n", path);
		return;
	}
    // 获取目录的状态信息
	if(fstat(fd, &st) < 0){
		fprintf(2, "find: cannot stat %s\n", path);
		close(fd);
		return;
	}
    // 文件、目录分别处理
    switch (st.type) {
    // 如果是文件，检查文件名是否与目标文件名匹配
    case T_FILE:
		if(strcmp(path+strlen(path)-strlen(target), target) == 0) {
			printf("%s\n", path);
		}
        break;
    // 如果是目录
    case T_DIR:
        // 检查路径长度是否超出缓冲区大小
        if (strlen(path) + 1 + DIRSIZ + 1 > sizeof buf) {
			printf("find: path too long\n");
			break;
		}
		strcpy(buf, path);
		p = buf+strlen(buf);
        *p++ = '/';
        // 读取目录项
        while (read(fd, &de, sizeof(de)) == sizeof(de)) {
			if(de.inum == 0)
				continue;
			memmove(p, de.name, DIRSIZ);
            p[DIRSIZ] = 0;
            // 获取目录项的状态信息
            if (stat(buf, &st) < 0) {
				printf("find: cannot stat %s\n", buf);
				continue;
			}
            // 排除 "." 和 ".." 目录
			if(strcmp(buf+strlen(buf)-2, "/.") != 0 && strcmp(buf+strlen(buf)-3, "/..") != 0) {
				find(buf, target);      // 递归查找子目录
			}
		}
		break;
	}
	close(fd);      // 关闭目录
}

int main(int argc, char *argv[])
{
	if(argc < 3){                   // 如果参数不足，退出程序
		exit(0);
	}
	char target[512];
	target[0] = '/';                // 为查找的文件名添加 / 在开头
	strcpy(target+1, argv[2]);      // 将目标文件名存储在 target 中
	find(argv[1], target);          // 调用查找函数
	exit(0);
}