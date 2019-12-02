---
layout: post
title:  "Ubuntu无法使用ssh连接"
date:   2019-12-02 20:05 +0800
categories: Linux
tags: Linux
---
<!--
 >Theory and Computational Biology: From Molecular to System
-->

如果Ubuntu中输入```ifconfig```能够看到ip，但是从另一台机器却无法使用ssh进行登陆时，往往可能是以下的问题：
* ip查看错误，检查是否是局域网络ip，还是动态的ip
```
可以在terminal中通过ping ip看看是否能够ping通
```
如果可以ping通一般会显示如下：
```
usename@local-host:~$ ping www.baidu.com
PING www.a.shifen.com (14.215.177.39) 56(84) bytes of data.
64 bytes from 14.215.177.39: icmp_seq=1 ttl=52 time=24.9 ms
64 bytes from 14.215.177.39: icmp_seq=2 ttl=52 time=24.5 ms
64 bytes from 14.215.177.39: icmp_seq=3 ttl=52 time=24.7 ms
64 bytes from 14.215.177.39: icmp_seq=4 ttl=52 time=24.6 ms
64 bytes from 14.215.177.39: icmp_seq=5 ttl=52 time=24.7 ms
^C
--- www.a.shifen.com ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4006ms
rtt min/avg/max/mdev = 24.594/24.735/24.937/0.183 ms
```
* Ubuntu没有安装ssh服务
Ubuntu中是默认不会安装```ssh-server```服务的，可以使用如下命令进行安装
```
#首先更新下apt-get的库文件
sudo apt-get update
#安装ssh服务
sudo apt-get install openssh-server
在安装过程中，如果提示是否安装，一路输Y就可以了
service ssh start 
这一步我一般都没有输入，大家也可以忽略
```
* 防火墙或者ssh默认的端口```22```被占用导致无法连接
如果是防火墙导致的无法连接，使用如下命令：
```
sudo ufw disable
```
如果是端口22被占用，可以使用如下命令来释放```22```端口：
```
sudo ufw allow 22
```