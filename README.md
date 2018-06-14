
# ZipperDown

**ZipperDown漏洞**是由盘古实验室发现的，该漏洞是盘古团队针对不同客户的iOS应用安全审计的过程中发现的，大约有10％的iOS应用会受到此漏洞的影响。类似**解压**等通用功能的漏洞，一个平台爆出了漏洞，其他平台往往也受到牵连，不久前Android平台上的unZip解压文件漏洞，和这个漏洞几乎是完全一样，只是平台和第三方解压库不同而已。

## 危害

利用此漏洞可以做很多事情，例如实现目录遍历攻击和App沙盒目录中任意文件**覆盖风险**，影响究竟有多大，取决于具体App。例如，如果集成了**热修复**，且未做相应的安全处理，通过覆盖热修复的JS代码，可以在**非越狱的手机上**达到修改执行源码的目的。

## 原理

**ZipperDown漏洞**并非**iOS平台自身**问题，而是与Zip文件解压有关。

* iOS平台没有提供**官方**解压类库，所以开发中往往引用**第三方**库来实现解压功能；
* 由于现有的iOS App基本上采用SSZipArchive或Ziparchive来实现解压，因此漏洞是来自使用第三方Zip库解压Zip文件的过程中没有对Zip内文件名做校验导致的；
* 例如 SSZipArchive解压时会吧文件名直接拼接到目标路径后面，如果文件名中含有“../”则可以实现目录的上一级跳转，从而实现应用内任意目录的跳转，进一步可以实现文件覆盖；
* 如果把App的热修复hotpatch文件覆盖替换了，可以达到执行黑客指定指令，从而按照黑客的意图实现任意应用内攻击。

## 攻击条件

1. 使用了SSZipArchive或Ziparchive第三方解压库;
2. Zip包在解压时没有做完整性校验;
3. 文件名中包含../等路径特殊符号，解压时没有对文件名过滤处理;
4. 使用了JSPatch或其他热修复库，且本地脚本没有加密等安全处理;
5. 连接不可靠的WIFI热点或者网络被人劫持。

> 注：若App没有使用热修复功能，并且在沙盒文件中没有保存重要的配置/信息，则可忽略此漏洞。

## 修复

iOS端修复很简单，下载文件成功后，解压文件时，不用**网络传输**过来的文件名称，或者将文件名中的./等特殊符号全部都**过滤替换掉**就可以了。

## Demo演示

1. 假设我们App使用了热修复，热修复文件放在沙盒的library/Caches/jspatch/hot.js(hot.js内容为 **jjjjjjjjjj**);
2. 我们需要从这个链接(https://raw.githubusercontent.com/muzipiao/CommonResource/master/zip/hot.zip)下载一个包含图片的ZIP文件，下载解压的目标路径为library/Caches/zip/default;
3. 黑客通过替换压缩包，将压缩包中内容替换为假的hot.js(hot.js内容为 **hack hack hack**)，并将压缩重命名为**../jspatch**；
4. 我们下载解压后发现，JS热修复文件(library/Caches/jspatch/hot.js)内容变成了**hack hack hack**；
5. 如果使用的是Http，可以通过**charles**代理抓包替换来达到模拟的目的，这里我们通过手动修改压缩包名称来模拟。

## 攻击示意图

![攻击示意图](https://raw.githubusercontent.com/muzipiao/GitHubImages/master/ZipperDown/ZipperDownImg1.png)

如果您觉得有所帮助，请在[ZipperDownDemo](https://github.com/muzipiao/ZipperDownDemo)上赏个Star ⭐️，您的鼓励是我前进的动力


参考：https://blog.csdn.net/yidunmarket/article/details/80359004
