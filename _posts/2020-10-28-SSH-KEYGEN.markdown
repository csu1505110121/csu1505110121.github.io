---
layout: post
title:  "Linux下无密码传输文件（通过ssh-keygen实现）"
date:   2020-10-28 08:12 +0800
categories: linux
tags: Linux
---
<!--
 >Theory and Computational Biology: From Molecular to System
-->
<!-- > 当你打开我这个网页时，恭喜你，你离毕业不远了，撸起袖子加油干啊，奥利给！  
> <p align="right">-- Forty Braver </p>
-->
# SSH公钥认证的基本原理：

SSH是一个专为远程登录会话和其他网络服务提供安全性的协议。默认状态下SSH链接是需要密码认证的，可以通过添加系统认证（即公钥-私钥）的修改，修改后系统间切换可以避免密码输入和SSH认证。
对信息的加密和解密采用不同的key，这对key分别称作private key和public key，其中，public key存放在欲登录的服务器上，而private key为特定的客户机所持有。
当客户机向服务器发出建立安全连接的请求时，首先发送自己的public key，如果这个public key是被服务器所允许的，服务器就发送一个经过public key加密的随机数据给客户机，这个数据只能通过private key解密，客户机将解密后的信息发还给服务器，服务器验证正确后即确认客户机是可信任的，从而建立起一条安全的信息通道。
通过这种方式，客户机不需要向外发送自己的身份标志“private key”即可达到校验的目的，并且private key是不能通过public key反向推断出来的。这避免了网络窃听可能造成的密码泄露。客户机需要小心的保存自己的private key，以免被其他人窃取，一旦这样的事情发生，就需要各服务器更换受信的public key列表。

# 操作流程：
## 前提假设
```
假设有两台机器需要建立上述无密码传输关系
A: 114.212.1.A
B: 114.212.1.B (也可以是通过端口转发的内网地址ip：192.168.1.X)
```
## 1. 在服务器A上利用```ssh-keygen```命令生成公钥和私钥（文件后缀为pub）对：
随便在某个目录下执行```ssh-keygen -t rsa```命令，连续按```3```次回车即可
```bash
[username@A ~]$ ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
df:71:f6:3e:bb:bb:6c:38:91:f4:bc:70:a1:dd:86:a9 root@flower1
The key's randomart image is:
+--[ RSA 2048]----+
|                 |
|                 |
|                 |
|             . . |
|        S   o Ooo|
|         . . Oo*o|
|          . ..=.o|
|            Eo.= |
|              o*B|
+-----------------+
```
进入到```~/.ssh```目录下查看生成的文件：其中```id_rsa```为私钥，```id_rsa.pub```为公钥
## 2. 使用```ssh-copy-id```将A的公钥拷贝到B相关目录下：
```bash
[username@A ~]$ssh-copy-id -i ~/.ssh/id_rsa.pub username@B
```

也有相关教程使用如下方式，但是两者最终的结果是一致的，```ssh-copy-id```这个方法更加的方便快捷，其他方法的教程如下：
### 2.1 将A上的公钥拷贝到B相关目录下
```bash
[username@A .ssh]# scp id_rsa.pub username@B:~/.ssh
```
### 2.2 登陆B服务器：
```bash
[username@B]touch ~/.ssh/authorized_keys (如果已经存在这个文件, 跳过这条)
[username@B]chmod 600 ~/.ssh/authorized_keys  (# 注意： 必须将~/.ssh/authorized_keys的权限改为600, 该文件用于保存ssh客户端生成的公钥，可以修改服务器的ssh服务端配置文件/etc/ssh/sshd_config来指定其他文件名）
[username@B]cat ~/.ssh/id_rsa.pub  >> /root/.ssh/authorized_keys (将id_rsa.pub的内容追加到 authorized_keys 中, 注意不要用 > ，否则会清空原有的内容，使其他人无法使用原有的密钥登录)
```

## 3.进行验证：
```bash
[username@A]ssh username@B (即可无密码登陆)
```







