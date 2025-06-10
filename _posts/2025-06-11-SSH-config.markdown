---
layout: post
title:  "SSH无需指定用户名进行登录"
date:   2025-06-11 09:09 +1000
categories: Linux
tags: Linux
---
<!--
 >Theory and Computational Biology: From Molecular to System
-->
<!-- > 当你打开我这个网页时，恭喜你，你离毕业不远了，撸起袖子加油干啊，奥利给！  
> <p align="right">-- Forty Braver </p>
-->



>	岭外音书断，经冬复历春。
>
>   近乡情更怯，不敢问来人。


在之前的一篇博客中[Linux下无密码传输文件（通过ssh-keygen实现）](https://csu1505110121.github.io/linux/2020/10/28/SSH-KEYGEN.html)，我介绍了Linux上如何不需要输入密码利用密钥进行登录。但是每次登录还是需要输入`用户名`和`ip地址`，在涉及到繁琐的上传下载的操作中还是多少有些不方便。尤其是在利用脚本进行批量的上传下载处理时，脚本看去来就非常的丑陋了。但其实可以通过配置文件`~/.ssh/config`让机器记住一个ip alias对应的用户名和ip，这样每次登录或者传输文件就只需要`ssh ip_alias`或者`rsync -arzu ip_alias:/path/to/file /path/to/destination`就可以了。


具体的配置文件如下`~/.ssh/config`：

```
  1 Host [ip_alias]
  2     HostName [xxx.xxx.xxx.xxx]
  3     User [your username]
  4     Port [port, default is 22]
```


