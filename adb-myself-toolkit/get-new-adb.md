# 获得最新 ADB 工具(2015-10-06)

访问 `https://dl-ssl.google.com/android/repository/repository-10.xml` 链接，可以获得 XML 文件，如下所示

```xml
<!-- PLATFORM-TOOLS ........................ -->

<sdk:platform-tool>
	<!-- Generated at Wed Sep  9 14:16:45 2015 from git_mnc-sdk-release @ 2240729 -->
	<sdk:revision>
		<sdk:major>23</sdk:major>
		<sdk:minor>0</sdk:minor>
		<sdk:micro>1</sdk:micro>
	</sdk:revision>
	<sdk:archives>
		<sdk:archive>
			<sdk:size>2402978</sdk:size>
			<sdk:checksum type="sha1">8f32d5f724618ad58e71909cc963ae006d0867b0</sdk:checksum>
			<sdk:url>platform-tools_r23.0.1-windows.zip</sdk:url>
			<sdk:host-os>windows</sdk:host-os>
		</sdk:archive>
		<sdk:archive>
			<sdk:size>2520021</sdk:size>
			<sdk:checksum type="sha1">94dcc5072b3d0d74cc69e4101958b6c2e227e738</sdk:checksum>
			<sdk:url>platform-tools_r23.0.1-linux.zip</sdk:url>
			<sdk:host-os>linux</sdk:host-os>
		</sdk:archive>
		<sdk:archive>
			<sdk:size>2489850</sdk:size>
			<sdk:checksum type="sha1">c461d66f3ca9fbae8ea0fa1a49c203b3b6fd653f</sdk:checksum>
			<sdk:url>platform-tools_r23.0.1-macosx.zip</sdk:url>
			<sdk:host-os>macosx</sdk:host-os>
		</sdk:archive>
	</sdk:archives>
	<sdk:uses-license ref="android-sdk-license"/>
</sdk:platform-tool>
```

对 Windows 版本来说，其中 url 部分是 `<sdk:url>platform-tools_r23.0.1-windows.zip</sdk:url>` ，校验码是 

> SHA-1 8f32d5f724618ad58e71909cc963ae006d0867b0

我们可以直接得到下载地址是 `https://dl-ssl.google.com/android/repository/platform-tools_r23.0.1-windows.zip`

Enjoy :)
