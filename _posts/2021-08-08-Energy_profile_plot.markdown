---
layout: post
title:  "Mac上利用Python的matplotlib库绘制一维能量曲线"
date:   2021-08-08 16:48 +0800
categories: Python
tags: scientific plot
---
<!--
 >Theory and Computational Biology: From Molecular to System
-->
<!-- > 当你打开我这个网页时，恭喜你，你离毕业不远了，撸起袖子加油干啊，奥利给！  
> <p align="right">-- Forty Braver </p>
-->



>	功利的世界里，一切都是如此现实。
>   不信你看宴中酒，杯杯先敬富贵人。

这段时间在进行NO3还原的课题，总算把各个态的能量优化计算出来了，但是绘制能量曲线的时候犯了难，之前课题组都是用orgin来进行科研绘图，不可否认origin是强大，但是毕竟是收费软件，同时对Mac支持的也就那样，有没有在Mac上也可以很好绘制能量曲线的工具呢？搜索了一下，确实有不少人在这方面做了不少“工作”，一些还有较为完善的图形界面！我把自己找到的一些方法一起放在这里，供各位看官参考。

- [mechaSVG](https://github.com/ricalmang/mechaSVG)
- [Jonyafei's blog](https://jonyafei.github.io/2019/08/09/matplotlib绘制势能面剖面图/#more)

但是或多或少这些网上的方法对于我的需求有的方面无法满足，例如字体的修改啦，反应坐标的名称啦，所以索性自己撸一个工具好了，这样后面的师弟师妹们或许也能用到，同时这个项目也是自己的第一个开源项目(energy_profile)，也正好Mark一下。

energy_profile的项目地址如下：[https://github.com/csu1505110121/energy_profile](https://github.com/csu1505110121/energy_profile)

本项目是在python框架下书写的，所以用到以下几个package，也都是一些经常使用到的包，为了大家使用方便，我把我的环境文件`environment.yml`也一起上传到了仓库中，有需要的可以直接下载下来。

## Requirement
- Python `3.8`
- numpy `1.21.1`
- pandas `1.3.1`
- matplotlib `3.4.2`

## Data Preparation

### input data (xlsx format)

目前的程序中对于各个稳态的能垒是存储在excel文件中的，并且按照一个反应路径一个表单（sheet）的格式进行存储，第一列对应的是每个稳态的名字，第二列对应的是每个态对应的能量值。程序示例中的数据格式如图所示：

<center class="half">
  <img style="margin:1px;" src="{{site.url}}/assets/2021_energy_profile/001.png" width="150"/><img style="margin:1px;" src="{{site.url}}/assets/2021_energy_profile/110.png" width="150"/><img stype="margin:1px;" src="{{site.url}}/assets/2021_energy_profile/111.png" width="150"/>
</center>


### configure file (plain text)

按照如下格式创建程序的配置文件，类似于gaussian的输入文件。

其中注释行都是以"#"开头，配置文件中的参数分为两个部分，一个是必选参数，这部分参数都放在了`**NECESSARY ARGS**`里面，另一部分是可选项，放在了`**OPTIONAL ARGS**`中，所谓可选项顾名思义，就是不需要指定程序也可以正常运行，但是最后的出图可能不够美观。

每个参数的详细作用介绍如下：
---
- `FILENAME`: 这部分参数主要是指定在input data中创建的xlsx的文件名和目录;
- `LEGEND_NAMES`: 对应的如果是多个反应路径的自由能变化，我们往往需要在图上标出对应的符号；
- `SHEET_NAMES`: 每个反应路径数据对应的表单，和input data中的顺序对应；
- `COLORS`: 指定每个反应路径对应的颜色；

---
- `TEXTLABEL`: 是否将能量的数值显示在每个水平线上；
- `LIMIT`: 是否需要人为指定图的Y值的分布范围，如果这里指定为`True`,一定要定义对应的两个参数`YMIN`和`YMAX` 
- `YMIN`: 指定Y值的最小值；
- `YMAX`: 指定Y值的最大值；
- `FONTSIZE`: 图中出现的字体大小，默认为`18` 
- `FIGSIZE`: 画布的大小，指定和python中有一定出入`14,6` 不需要指定括号"()"
- `XLABEL`: 图中X轴的标题；
- `YLABEL`: 图中Y轴的标题；
- `OUTPUT`: 最后出图的文件名和地址，默认值是在当前目录下的`example.png` 

---

`input.txt`文件示例：
```
# filename: input.txt
# An example of the input file
# Comment is started with symbol '#'
#                           Created by Qiang @ Zhengjiang

*NECESSARY ARGS*
FILENAME: /Users/zhuqiang/Documents/My_Jobs@Nanjing/WorkHotel/NO3RR/Energy_Profile/example/example.xlsx            # here is the input data and should be the absolute path
LEGEND_NAMES: 001, 110, 111    # name of legend
SHEET_NAMES:  001,110,111     # sheet of input data
COLORS: black, blue, grey      # color of each pathway


*OPTIONAL ARGS*
TEXTLABEL: False               # Show the value of energies
LIMIT:    True                 # optioinal: specify the YMIN and YMAX manually
YMIN:     -2                         # optional: you can specify and will overwrite the one self-generated
YMAX:      5                        # same as YMIN
FONTSIZE: 18                     # fontsize of the number and legends
FIGSIZE: 14,6                  # size of the canvas
XLABEL:  Reaction Pathway        # xlabel for the figure
YLABEL:  Free Eenergy $\Delta G$ (eV)       # ylabel for the figure
OUTPUT: ./example.png             # output name for the figure
```

## Usage
准备上述的两个文件xlsx格式原始数据和可读的文本格式的输入文件，将代码下载到本地。

编写一个python脚本或者直接在terminal中输入如下命令：

第一步是导入我们编写的程序`DeltaG_plot.main`中的相关程序，第二部是绘制图片`plot`或者直接将图片保存`saveplot` 

```bash
%python
Python 3.8.10 | packaged by conda-forge | (default, May 11 2021, 06:27:18)
[Clang 11.1.0 ] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> from DeltaG_plot.main import plot
>>> plot('example/input.txt')

-or-
%python
Python 3.8.10 | packaged by conda-forge | (default, May 11 2021, 06:27:18)
[Clang 11.1.0 ] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> from DeltaG_plot.main import saveplot
>>> saveplot('example/input.txt')

```



## Output
<div align="center">
<img src="{{site.url}}/assets/2021_energy_profile/example.png" width = "500" height = "" alt="output"/>
 </div>









