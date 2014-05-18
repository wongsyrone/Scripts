#!/usr/bin/env python
# http://hi.baidu.com/hkuieagle/item/e96258e28aa0baa7ce2d4f4a
# 使用方法：将脚本拷贝到软件源码的根目录 (包含 Makefile的地方 根目录或者 src/ 的上层目录)，运行即可
# 首先安装小工具 tree
import sys, os
PACKAGE_NAME = os.path.abspath('.').split('/')[-1]
DESTDIR = "/tmp/" + PACKAGE_NAME
MAKE_INSTALL = "make > /dev/null ; make install DESTDIR=" + DESTDIR + "> /dev/null"
FILELIST = DESTDIR + '.' + 'uninstall'
TREE = "tree -if . > " + FILELIST

print 'package name:', PACKAGE_NAME
print 'destdir:', DESTDIR
print 'filelist:', FILELIST
print

class queue(object):
    def __init__(self, filelist):
        self.f = open(filelist, 'r')     
        self.lines = [line.strip()[1:] for line in self.f.readlines() if line != '\n']
        self.f.close()
        self.lines.pop()
        self.lines.append('DUMMY')

    def get(self):
        return self.lines.pop(0)

    def put(self, line):
        self.lines.append(line)

def uninstall(filelist):
    lines_queue = queue(filelist)
    reach_dummy = 0
    del_count = 0
    while True:
        l = lines_queue.get()
        if os.path.isfile(l):
            os.remove(l)
            print "Del: ", l
            del_count += 1
        elif os.path.isdir(l):
            try:
                os.rmdir(l)
                print "Del: ", l
                del_count += 1
            except OSError:
                lines_queue.put(l)
        elif l == 'DUMMY':
            reach_dummy = 1
            lines_queue.put(l)

        if reach_dummy == 1:
            if del_count == 0:
                break
            else:
                reach_dummy = 0
                del_count = 0

    print
    print "Uninstalled ", PACKAGE_NAME, " successfully!"
    return 0

os.system(MAKE_INSTALL)
os.chdir(DESTDIR)
os.system(TREE)
uninstall(FILELIST)
os.chdir('/tmp')
os.system('rm -r ' + DESTDIR)
os.system('rm ' + FILELIST)
 
#=============================== END ======================================#

# 脚本的原理很简单：就是利用make DESTDIR = /tmp/package_name install 的功能，将软件临时安装到/tmp/package_name目录下去，再利用工具tree 遍历/tmp/package_name，获得安装的文件和目录的列表，输出到 /tmp/package_name.uninstall文件，然后依照列表文件删除相应的文件和目录，最后删除临时目录/tmp/package_name和 /tmp/package_name.uninstall。（如果有不用执行实际安装就可以获得列表的方法，那就更好了）
# 不过在得到安装文件列表后，删除文件和目录还需要一点技巧，这就是脚本中的函数 uninstall(filelist) 做的事情，其中参数就是安装的列表文件 /tmp/package_name.uninstall。这是因为，一个软件的文件可能是安装在一个自己新建立的目录下，也可能是原来就存在的，而且目录中还有别的文件，所以不能见到目录和文件就直接删。比如下面是transimission的安装文件列表 /tmp/transmission-2.00.uninstall 的开头一部分：
# /usr
# /usr/local
# /usr/local/bin
# /usr/local/bin/transmission
# /usr/local/bin/transmissioncli
# /usr/local/bin/transmission-daemon
# /usr/local/bin/transmission-remote
# /usr/local/share
# /usr/local/share/applications
# /usr/local/share/applications/transmission.desktop
# /usr/local/share/icons
# .
# .
# .
# 可见，连 /usr 目录都在其中，当然不能直接取一行删一个目录了！
# uninstall() 函数中的算法是这样的：首先将列表文件中的所有文件或目录放入一个列队中。分析的时候，每次从列队中取出一个文件或目录，如果是文件则直接删除；如果是目录：1.为空则直接删除，2.不为空：put 回列队尾，然后继续取列队的下一个分析。这样经过列队的一次遍历后，开始put回队列的非空目录中的文件或子目录可能都已经被删除了，于是也可以删除，而后面的包含它的父目录又可以删掉了（观察文件列表可以发现，父目录总是在子目录前面，所以放回列队以后总是在子目录后面，因此，这种方法很高效，没有任何不必要的操作），如此，循环遍历队列…… 但是这样还不完全，因为有些目录是永远不会为空的，比如/usr目录，里面的东西，不会也不应该删空，那么这样，遍历队列就会进入死循环：不停的提取出目录，又放回去，不做任何有用的处理。所以一旦进入这种状态就应该退出，这时其实该删的都删光了，软件也已经清除干净了。 实现这一步的是开始时在队列的最后放了一个'DUMMY'，两次访问到'DUMMY'说明证号遍历了一次队列，这时检查del_count的计数，如果在一次队列遍历中没有任何删除动作（再遍历一次还是不会有任何处理，开始进入死循环），就说明，软件已经清除干净了，就可以退出了。
