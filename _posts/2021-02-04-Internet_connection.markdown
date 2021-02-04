---
layout: post
title:  "Windows下使用脚本自动连接Internet进行远程操作"
date:   2021-02-04 16:05 +0800
categories: Windows
tags: Linux, bras
---
<!--
 >Theory and Computational Biology: From Molecular to System
-->
<!-- > 当你打开我这个网页时，恭喜你，你离毕业不远了，撸起袖子加油干啊，奥利给！  
> <p align="right">-- Forty Braver </p>
-->
寒假来临，在家的同志对远程办公可谓是重度依赖了。对于远程办公，实验室的同僚往往使用的是Teamviewer，但是如果实验室没有网络，Teamviewer掉线，那么在家的同志也就无法进行相应的远程操作了。今天我就分享下如何在Windows 10操作系统下（在Linux下更加是丝般顺滑），每隔一段时间自动进行网络接入的方法，目前该方法只在南京大学网络下测试过，但是对于其他需要通过页面认证进行拨入的也一样适用。


# 准备条件

- 安装Ubuntu桌面子系统（Linux用户可以直接跳过这一步）
具体的安装过程不是这篇博文的重点，大家可以参照这篇[简书](https://www.jianshu.com/p/2bcf5eca5fbc)进行安装，如果只需要简单的功能仅仅进行到第四步就可以了。

- bras脚本的编写

```bash
#!/bin/bash

# username 是你登录网页所需要的账号
# password 是账号对应的密码
# http://p.nju.edu.cn/portal_io/login 是对应登录界面所对应的网址
curl -d "username=xxxxx&password=xxxxx" http://p.nju.edu.cn/portal_io/login </dev/null 2>/dev/null
```

有兴趣的朋友可以看下```curl```的参数详解

- 将bash脚本复制到Ubuntu系统中去，命名为```bras.sh```（名字可以任意，只是为了或许方便）

# 执行操作

```bash
#在Ubuntu子系统的命令行中输入如下命令：
watch -n xx bash bras.sh
#其中xx是对应的时间，在本例子中我输入的60表示每隔60s的时间就会执行一次bash bras.sh这个命令，更加具体的参数大家可以参考下watch这一命令
```
登录成功的话会出现如下界面
<div align="center">
<img src="{{site.url}}/assets/2021_bras/bras_connection.png" width = "" height = "" alt="bras connection"/>
 </div>

最后，祝大家新年快乐！








