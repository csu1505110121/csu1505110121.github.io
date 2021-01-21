---
layout: post
title:  "Installment of Gaussian and Gaussian View on Linux"
date:   2021-01-21 21:05 +0800
categories: Linux
tags: Linux, Software, Gaussian, Gaussian View, Quantum Chemistry
---
<!--
 >Theory and Computational Biology: From Molecular to System
-->
<!-- > 当你打开我这个网页时，恭喜你，你离毕业不远了，撸起袖子加油干啊，奥利给！  
> <p align="right">-- Forty Braver </p>
-->
最近组里面的师弟师妹们爱上了使用linux，那linux下的一些科研软件的安装并不像window上安装那么方便。例如一些常用的量化软件，Gaussian和gaussian view。在这篇blog中我就简单介绍下gaussian和gaussian view如何在linux下安装并使用，虽然本教程是在ubuntu 15.10下进行的，但是在centos版本的linux下也同样适用。


# Step 1. 安装包的解压缩

```bash
# 解压缩gaussian view的压缩包
tar -xvf GaussView\ 4.1.2_Linux_x86.tar.gz
# 得到的目录文件是gv

# 解压缩gaussian对应的压缩包
tar -xvf Gaussian.tbz
# 得到的目录文件是g09
```

# Step 2. Gaussian环境变量的设置
```bash
# 设置gaussian的环境变量
export g09root=/home/username  # username就是你机器的名字
export GAUSS_SCRDIR=/tmp       # /tmp是根目录下的一个文件夹，安装系统的时候都会有，一般用来做临时文件，也可以任意指定，但是注意要有读写的权限
source /home/username/g09/bsd/g09.profile
```

# Step 3. Gaussian View环境变量的设置

```bash
# 设置gaussian view的环境变量
export GV_DIR='/home/username/gv' # /home/usename/gv 是你step 1中Gaussian view压缩得到的文件的位置
alias gv=$GV_DIR'/gview'          # 设置gaussian view命令行唤醒的别名，可以是gv也可以是gview看你个人习惯
alias gview=$GV_DIR'/gview'        
export LD_LIBRARY_PATH=$GV_DIR/lib:$LD_LIBRARY_PATH
```

All Done !!!








