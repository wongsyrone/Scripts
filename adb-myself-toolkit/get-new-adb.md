# 获得最新 ADB 工具(2014-12-28)

访问 `https://dl-ssl.google.com/android/repository/repository-10.xml` 链接，可以获得 XML 文件，如下所示

```xml
<!--  PLATFORM-TOOLS ........................  -->
<sdk:platform-tool>
	<!--
	 Generated at Thu Oct 16 18:23:45 2014 from git_lmp-release @ 1521886 
	-->
	<sdk:revision>
		<sdk:major>21</sdk:major>
		<sdk:minor>0</sdk:minor>
		<sdk:micro>0</sdk:micro>
	</sdk:revision>
	<sdk:archives>
		<sdk:archive>
			<sdk:size>1824862</sdk:size>
			<sdk:checksum type="sha1">04b26e60e47cda4867d321817270058c22572352</sdk:checksum>
			<sdk:url>platform-tools_r21-windows.zip</sdk:url>
			<sdk:host-os>windows</sdk:host-os>
		</sdk:archive>
		<sdk:archive>
			<sdk:size>1692013</sdk:size>
			<sdk:checksum type="sha1">2502ade68af9f6288c4dd7726796599e8d9a4337</sdk:checksum>
			<sdk:url>platform-tools_r21-linux.zip</sdk:url>
			<sdk:host-os>linux</sdk:host-os>
		</sdk:archive>
		<sdk:archive>
			<sdk:size>1680668</sdk:size>
			<sdk:checksum type="sha1">6675f9f583841972c5c5ef8d2c131e1209529fde</sdk:checksum>
			<sdk:url>platform-tools_r21-macosx.zip</sdk:url>
			<sdk:host-os>macosx</sdk:host-os>
		</sdk:archive>
	</sdk:archives>
	<sdk:uses-license ref="android-sdk-license"/>
</sdk:platform-tool>
```

其中 url 部分是 `<sdk:url>platform-tools_r21-windows.zip</sdk:url>` ，校验码是 

> SHA-1 04b26e60e47cda4867d321817270058c22572352

我们可以直接得到下载地址是 `https://dl-ssl.google.com/android/repository/platform-tools_r21-windows.zip`

Enjoy :)