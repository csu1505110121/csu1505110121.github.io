---
layout: post
title:  "通过SSH端口转发在服务器上搭建Jupyter notebook服务"
date:   2021-04-14 16:10 +0800
categories: Linux
tags: Python
---
<!--
 >Theory and Computational Biology: From Molecular to System
-->
<!-- > 当你打开我这个网页时，恭喜你，你离毕业不远了，撸起袖子加油干啊，奥利给！  
> <p align="right">-- Forty Braver </p>
-->



>	低回愧人子，不敢叹风尘	

在机器学习中无法绕开的编程语言就是Python，现有的大量的软件包都提供了Python语言的API。对于python的使用，环境搭建最为方便的软件我如果说是anaconda我想没有人会反对吧！Jupyter Notebook 是一款允许使用者创建和分享文档的开源web应用。文档中支持Markdown文本解析、LaTex公式和交互式编程等功能。在数据科学、数值计算和机器学习等领域有着广泛的应用。而且 Jupyter 也非常容易上手，安装使用等基本问题请参考官网。

本文将介绍的是如何在服务器上部署 Jupyter notebook 并通过更加安全的 SSH 通道访问。这样只要浏览器和网络就能***随时随地开始编程了***，简直是一大杀器！

# Jupyter配置
- 生成密钥

进入`ipython`交互界面，为Jupyter创建密钥：
```bash
zhuqiang@zhuqiangs-MacBook-Air Desktop % ipython
Python 3.9.1 | packaged by conda-forge | (default, Jan 26 2021, 01:30:54)
Type 'copyright', 'credits' or 'license' for more information
IPython 7.21.0 -- An enhanced Interactive Python. Type '?' for help.

In [1]: from notebook.auth import passwd

In [2]:passwd()
Enter password:
Verify password:
Out[2]: 'sha1:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
```

- 设置配置文件

网上有两种策略设置配置文件，一种是通过直接修改配置文件`~/.jupyter/jupyter_notebook_config.py`，但是对于笔者并不适用，因为笔者的桌面带有图形界面，一般在办公室的时候就直接利用本地，但是出差的时间希望通过远程来访问jupyter的notebook，两者之间进行切换实在是好不麻烦。

在这篇博文中，我推荐的做法是自行创建一个配置文件，然后在运行jupyter notebook的时候动态加载配置信息。创建配置文件，这里取名为jupyter_config.py.

配置内容如下：

```python
c.NotebookApp.ip = 'localhost' # 指定
c.NotebookApp.open_browser = False # 关闭自动打开浏览器
c.NotebookApp.port = 8888 # 端口随意指定
c.NotebookApp.password = u'sha1:d8334*******' # 复制前一步生成的密钥
```

- 启动Jupyter服务器

接下来运行Jupyter
```bash
jupyter notebook --config=jupyter_config.py
```

但是当前这样还存在一个问题，就是一旦关闭终端，Jupyter 程序也就终止了运行。这是因为该 Jupyter 程序作为当前终端的子进程，在用户终端关闭的时候将收到一个 hangup 信号，从而被关闭。
所以为了让程序能忽视 hangup 信号，可以使用 nohup 命令。同时还要配合 & 来将程序放入后台运行。
这里就会涉及到如何将nohup程序杀掉的问题，可以看本文的相关拓展。
```bash
nohup jupyter notebook --config=jupyter_config.py &
```

- SSH端口转发

SSH 提供的端口转发，能够将其他 TCP 端口的网络数据通过 SSH 链接来转发，并且自动提供了相应的加密及解密服务。这一过程有时也被叫做“隧道”（tunneling），这是因为 SSH 为其他 TCP 链接提供了一个安全的通道来进行传输而得名。

因此SSH端口转发能提供两大功能：
```bash
1. 加密SSH客户端到SSH服务端的通信；
2. 突破防火墙限制，建立一些之前受限的TCP连接
```

本地端口转发的命令格式是：
```bash
ssh -p port(默认是22如果该服务器没有做过端口转发的话) -L <local port>(本地想要映射的端口):<remote host>(jupyter_config.py中的ip):<remote port>(jupyter_config.py中设置的端口) username@<SSH hostname>
```

之后便能通过`localhost:<local port>`来访问Jupyter服务器了。

<div align="center">
<img src="{{site.url}}/assets/2021_jupyter_ssh/ssh_jupyter.png" width = "800" alt="ssh jupyter"/>
 </div>


---
# 拓展阅读：

- 在linux下如何杀掉`nohup`的进程：

方法1：

```bash
1. 如果没有退出客户端界面，可以先通过“jobs”命令查看程序是否还在运行，此时只有序号没有PID号；
2. 输入命令“jobs -l”会显示程序的PID号，然后通过“kill -9 PID”杀死程序；
3. 输入命令“jobs”查看程序是否被杀死
```

方法2：

```bash
1. 如果退出客户端界面，输入“jobs”命令查不到正在运行的程序；
2. 输入“ps -aux | grep xxxx” 来查看对应程序的进程号PID，然后通过“kill -9 PID”杀死程序；
3. 输入“ps -aux” 来查看程序是否被杀死
```

- 在linux下如何查看端口是否被占用并释放当前端口：

```bash
1. 输入netstat -tln，查看当前系统所有被占用的端口，主要是为了查看端口是否被真正的占用
2. 根据端口查询进程，输入lsof -i  :8888，切记不要忘了添加冒号，可以看到当前占用端口8888的程序进程号；
3. 知道了进程号，直接kill -9 进程号回车，就可以杀掉进程了
```







