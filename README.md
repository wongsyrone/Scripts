# 一些有用的脚本
## 目录
* install-wine-deps.sh  -->检测安装wine的安装依赖 已经支持 Ubuntu 14.04 LTS
* terminalcolors.py  -->使用方法 python terminalcolors.py 检测终端（XTerm）的颜色支持，用于校验是否能够使用256色配色方案，如果能够输出各种颜色，证明功能正常
* clean_compile_soft.py  --> 清理编译安装的软件，有些软件的 Makefile 中没有 uninstall 字段，只能先 make clean，然后 find 到所有相关文件之后再 rm，这个脚本很好用，通过虚拟安装到/tmp目录生成安装文件列表，然后清理，详细介绍在脚本中
* get-fonts.sh           --> 使用: chmod +x get-fonts.sh && sudo ./get-fonts.sh
* google_find_ip_ver1.3.tar.xz   --> Google 可用IP地址寻找工具，换用xz压缩，使用 -e 参数提高压缩比
* google_find_ip_ver1.3-256-Modified_by_wong.tar.xz    --> 自己修改，增加tcping探测过程，增加自己写的批量从文件添加地址池的脚本，增加Google IP地址池（包括Google原生和GoGo Tester的地址池）以及少量调整，换用xz压缩，使用 -e 参数提高压缩比
* 


