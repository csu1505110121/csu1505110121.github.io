---
layout: post
title:  "Installment of Homebrew on Mac M1 silicon"
date:   2020-12-24 15:20 +0800
categories: Mac
tags: Mac, homebrew, jekyll
---
<!--
 >Theory and Computational Biology: From Molecular to System
-->
<!-- > 当你打开我这个网页时，恭喜你，你离毕业不远了，撸起袖子加油干啊，奥利给！  
> <p align="right">-- Forty Braver </p>
-->
# Homebrew简介：

引用[官方](https://brew.sh)的一句话：Homebrew是Mac OS 不可或缺的套件管理器。
Homebrew是一款Mac OS平台下的软件包管理工具，拥有安装、卸载、更新、查看、搜索等很多实用的功能。简单的一条指令，就可以实现包管理，而不用你关心各种依赖和文件路径的情况，十分方便快捷。

个人觉得，使用Homebrew使得Mac上安装软件和在ubuntu上使用apt-get install 一样便捷！

本来是想新Mac到手，可以继续把我的[blog](https://csu1505110121.github.io)经营起来，按照[jekyll官网](https://jekyllrb.com)的介绍，使用Mac自带的ruby版本`2.6.0`无法正常执行jekyll，想着是不是要将ruby进行升级到`2.7.3`进行试一下。



但是截止到这篇blog，homebrew使用原始x86都无法正常安装，本文的安装主要参照一下两篇blog：

- [https://www.dbform.com/2020/11/30/how-to-install-native-homebrew-on-an-apple-silicon-m1-mac/](https://www.dbform.com/2020/11/30/how-to-install-native-homebrew-on-an-apple-silicon-m1-mac/)
- [https://blog.csdn.net/csdn2314/article/details/110952637](https://blog.csdn.net/csdn2314/article/details/110952637) 


# Homebrew在2020 Mac M1 silicon上的安装方法
要在Apple Silicon M1上安装homebrew有两种方法：

* **第一种：** 在Rosetta 2下安装x86架构的Homebrew *（本人没有亲自尝试）*，主要原理是使用Rosetta的转码功能，还是直接安装x86架构的Homebrew，后续通过这个brew安装所有的软件，毋庸置疑，也都是基于x86架构的，可以通过Rosetta 2在M1 silicon上常运行。

安装方法如下：
```bash
arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

* **第二种：** 通过自行安装，运行M1架构的原生Homebrew

安装方法如下：

```bash
##首先创建安装目录
sudo mkdir -p /opt/homebrew

##将目录属主修改为当前用户，方便以后用当前用户直接brew install软件
sudo chown -R $(whoami) /opt/homebrew

## 进入到/opt下
cd /opt

##直接下载homebrew tar包并解压
curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew

##将路径增加到PATH环境变量中
如果使用的是zsh则直接修改~/.zshrc，如果使用的是bash，则修改~/.bash_profile，我的例子中修改.zshrc
echo "export PATH=/opt/homebrew/bin:$PATH" >> ~/.zshrc

##新开一个Terminal窗口或者在当前窗口让环境变量生效
source ~/.zshrc

##现在可以安装软件了，注意要使用-s选项，表示编译源码安装
brew install -s wget
```
---

# [jekyll 安装测试](https://jekyllrb.com/docs/installation/macos/)

1. 安装CTL(command line tools)

```bash
xcode-select --install
```

2. 安装Ruby

```bash
# Install Ruby -s选项表示源码编译
brew install -s ruby
```

3. 将ruby加入到环境变量中

```bash
# If you're using Zsh
echo 'export PATH="/usr/local/opt/ruby/bin:$PATH"' >> ~/.zshrc

# If you're using Bash
echo 'export PATH="/usr/local/opt/ruby/bin:$PATH"' >> ~/.bash_profile

# Unsure which shell you are using? Type
echo $SHELL
```

4. 安装jekyll (local install)

```bash
gem install --user-install bundler jekyll
```









