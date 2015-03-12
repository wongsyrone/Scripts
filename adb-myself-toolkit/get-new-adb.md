# 获得最新 ADB 工具(2015-03-02)

访问 `https://dl-ssl.google.com/android/repository/repository-10.xml` 链接，可以获得 XML 文件，如下所示

```xml
<!--  PLATFORM-TOOLS ........................  -->
<sdk:platform-tool>
<!--
	Generated at Mon Mar  2 16:26:07 2015 from git_lmp-mr1-sdk-release @ 1737576 
-->
	<sdk:revision>
		<sdk:major>22</sdk:major>
		<sdk:minor>0</sdk:minor>
		<sdk:micro>0</sdk:micro>
	</sdk:revision>
	<sdk:archives>
		<sdk:archive>
			<sdk:size>1848028</sdk:size>
			<sdk:checksum type="sha1">720214bd29d08eb82673cd81a8159b083eef19d7</sdk:checksum>
			<sdk:url>platform-tools_r22-windows.zip</sdk:url>
			<sdk:host-os>windows</sdk:host-os>
		</sdk:archive>
		<sdk:archive>
			<sdk:size>1751911</sdk:size>
			<sdk:checksum type="sha1">b78be9cc31cf9f9fe0609e29a6a133beacf03b52</sdk:checksum>
			<sdk:url>platform-tools_r22-linux.zip</sdk:url>
			<sdk:host-os>linux</sdk:host-os>
		</sdk:archive>
		<sdk:archive>
			<sdk:size>1743025</sdk:size>
			<sdk:checksum type="sha1">ddc96385bccf8a15d4f8a11eb1cb9d2a08a531c8</sdk:checksum>
			<sdk:url>platform-tools_r22-macosx.zip</sdk:url>
			<sdk:host-os>macosx</sdk:host-os>
		</sdk:archive>
	</sdk:archives>
	<sdk:uses-license ref="android-sdk-license"/>
</sdk:platform-tool>
```

对 Windows 版本来说，其中 url 部分是 `<sdk:url>platform-tools_r22-windows.zip</sdk:url>` ，校验码是 

> SHA-1 720214bd29d08eb82673cd81a8159b083eef19d7

我们可以直接得到下载地址是 `https://dl-ssl.google.com/android/repository/platform-tools_r22-windows.zip`

Enjoy :)