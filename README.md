# 一些有用的脚本
## 目录
* install-wine-deps.sh  -->检测安装wine的安装依赖 已经支持 Ubuntu 14.04 LTS
* terminalcolors.py  -->使用方法 python terminalcolors.py 检测终端（XTerm）的颜色支持，用于校验是否能够使用256色配色方案，如果能够输出各种颜色，证明功能正常
* clean_compile_soft.py  --> 清理编译安装的软件，有些软件的 Makefile 中没有 uninstall 字段，只能先 make clean，然后 find 到所有相关文件之后再 rm，这个脚本很好用，通过虚拟安装到/tmp目录生成安装文件列表，然后清理，详细介绍在脚本中
* touchpad-control.sh   --> 控制笔记本ELAN触控板开关
* get-fonts.sh           --> 使用: chmod +x get-fonts.sh && sudo ./get-fonts.sh
* bandwagonhost-debian-ss-polarssl.sh     --> Debian编译安装polarssl版本shadowsocks脚本  使用：wget --no-check-certificate https://raw.githubusercontent.com/wongsyrone/Scripts/master/bandwagonhost-debian-ss-polarssl.sh && chmod +x bandwagonhost-debian-ss-polarssl.sh && bash bandwagonhost-debian-ss-polarssl.sh
* ip-dec2hex-netmask.sh   -->点分格式的ip地址列表转为HEX列表，可以生成 iptables 过滤规则，netmask版本
* ip-dec2hex.sh     --> WIP
* upper-hex-ip.sh      -->输入HEX的ip地址列表，输出转成大写的列表
* google_find_ip_ver1.3.tar.xz   --> Google 可用IP地址寻找工具，换用xz压缩，使用 -e 参数提高压缩比
* google_find_ip_ver1.3-256-Modified_by_wong.tar.xz    --> 自己修改，增加tcping探测过程，增加自己写的批量从文件添加地址池的脚本，增加Google IP地址池（包括Google原生和GoGo Tester的地址池）以及少量调整，换用xz压缩，使用 -e 参数提高压缩比
* autoproxy20131215.xpi  --> 好吧，不是脚本，是Firefox修复版本（普通Logo）的Autoproxy.
* fix-vac-tool/ 文件夹  --> 【CRLF】自己写的解决 Steam 平台提示计算机屏蔽 VAC 的解决工具
* adb-myself-toolkit/ 文件夹  --> 【CRLF】自用的 ADB 工具

