---
layout: post
title:  "NJU 博士毕业大礼包"
date:   2020-01-17 17:50 +0800
categories: PhD Degrees
tags: Phd
---
<!--
 >Theory and Computational Biology: From Molecular to System
-->
> 当你打开我这个网页时，恭喜你，你离毕业不远了，撸起袖子加油干啊，奥利给！  
> <p align="right">-- Forty Braver </p>

# 三个课程作业

我将我用到的模板都附在后面，大家想用的话可以直接下载下来使用！

- 文献翻译 (找一篇和自己课题相关的文献翻一下，文献长短个人选择，当然你可以和老师商量下)
[Download]({{site.url}}/assets/PhD_details/qiang_homework_1/homework_1_translate.tex) /
[Templet]({{site.url}}/assets/PhD_details/qiang_homework_1/homework_1_translate.pdf)
- 两个专业课 (这两个涉及到了具体的结果我就不上传了，有需要的可以问我要)
	- 现代量子化学研究进展 (可以把你平时的ppt整体下然后merge成一个整体，所以平时的ppt都要保存好哦！)
	- 研究报告 (可以把你毕业论文的绪论部分修改下直接搬过来（这个是最偷懒的办法），当然还需要改一改，不要自己都看不过去)

三个作业的封面列在下方：

[文献翻译]({{site.url}}/assets/PhD_details/covers/professional_english.doc)/[现代量子化学进展]({{site.url}}/assets/PhD_details/covers/progress.doc)/[研究报告]({{site.url}}/assets/PhD_details/covers/research_report.doc) 

2020 年的具体要求我列在这个文件里了，需要自取。
- [2020 南京大学博士毕业具体及学位申请流程]({{site.url}}/assets/PhD_details/requirments/2020_NJU_PhD_details.pdf)
- [2020 博士课程邮件模板]({{site.url}}/assets/PhD_details/requirments/2020_templet_emails.docx)
- [2020 毕业论文成绩模板]({{site.url}}/assets/PhD_details/requirments/2020_templet_grades.docx)

# 博士毕业论文
这里给师弟/妹们安利下使用[LaTeX](https://www.latex-project.org)来书写你的毕业论文，如果还是喜欢用*Word*或者*WPS*的话下面的内容看官可以忽略了，下面主要是给使用**LaTeX**的同志们准备的。  

**使用LaTeX来书写NJU博士论文的好处**
- 开源啊，不要钱啊！！！（主要是我Mac版的*WORD*像个智障，还有Latex在*ubuntu*上也可以使用）
- 格式什么不需要care（包括字体还有文献的格式统统都是模板，只要填内容就好）；
- 不用担心电脑内存导致的辛辛苦苦码半天，最后因为格式的问题保存不了的尴尬处境；
- 写过论文的都知道，毕业论文的文献较多，如果用Endnote导入的话，不可避免的会造成电脑卡死的情况哦（主要还是我的电脑辣鸡）！！！  

**但是使用LaTeX的缺点(只谈优点不谈缺点的都是耍流氓)**
- 上手比较费时，但是好在有Google和Baidu啊

下面进入正题，首先把LaTeX安装好，然后去[Haixing Hu](https://github.com/Haixing-Hu/nju-thesis)的github主页上把NJU博士论文的模板下载下来，里面哪个地方填什么*Hu*都用中文注释的比较清楚，大家跟着他的来就可以。


对于一些个性化的设置，这里感谢下*Dr. Xiaoyu Xie*，下面是他就*Hu*的版本进行的修改方面的建议。

---

**资源获取（南京大学胡海星博士提供）**

``` bash
git clone https://github.com/Haixing-Hu/nju-thesis.git
```

**字体问题**

作者提供了四种体字系统: windows, linux, mac 及 adobe。调用时在`\documentclass`处指定（以Windows为例）：
``` latex
\documentclass[winfonts]{njuthesis}
```
各个体统的默认的格式为：

|       | adobefonts         | winfonts        | linuxfonts             | macfonts   |
|-------|--------------------|-----------------|------------------------|------------|
| 宋体   | Adobe Song Std     | SimSun          | AR PL SungtiL GB       | STSong     |
| 黑体   | Adobe Heiti Std    | SimHei          | WenQuanYi Zen Hei Mono | STHeiti    |
| 楷体   | Adobe Kaiti Std    | KaiTi           | AR PL KaitiM GB        | STKaiti    |
| 仿宋体 | Adobe Fangsong Std | FangSong        | STFangsong             | STFangsong |
| Serif | Times              | Times New Roman | Times                  | Times      |
| Sans  | Helvetica          | Arial           | Helvetica              | Helvetica  |
| Mono  | Courier            | Courier New     | Courier                | Courier    |

可根据要求安装相应的字体，也可在`njuthesis.dtx`文件中修改字体为自己机器中以有的字体。

``` latex
%    \begin{macrocode}
\newcommand*{\njut@zhfn@songti@win}{NSimSun}
\newcommand*{\njut@zhfn@heiti@win}{SimHei}
\newcommand*{\njut@zhfn@kaishu@win}{KaiTi}
\newcommand*{\njut@zhfn@fangsong@win}{FangSong}
%    \end{macrocode}
%
%    \begin{macrocode}
\newcommand*{\njut@enfn@main@win}{Times New Roman}
\newcommand*{\njut@enfn@sans@win}{Arial}
\newcommand*{\njut@enfn@mono@win}{Courier New}
%    \end{macrocode}
%
%    \begin{macrocode}
\newcommand*{\njut@zhfn@songti@linux}{AR PL SungtiL GB}
\newcommand*{\njut@zhfn@heiti@linux}{WenQuanYi Zen Hei Mono}
\newcommand*{\njut@zhfn@kaishu@linux}{AR PL KaitiM GB}
\newcommand*{\njut@zhfn@fangsong@linux}{STFangSong}
%    \end{macrocode}
%
%    \begin{macrocode}
\newcommand*{\njut@enfn@main@linux}{Times}
\newcommand*{\njut@enfn@sans@linux}{Helvetica}
\newcommand*{\njut@enfn@mono@linux}{Courier}
%    \end{macrocode}
%
%    \begin{macrocode}
\newcommand*{\njut@zhfn@songti@mac}{STSong}
\newcommand*{\njut@zhfn@heiti@mac}{STHeiti}
\newcommand*{\njut@zhfn@kaishu@mac}{STKaiti}
\newcommand*{\njut@zhfn@fangsong@mac}{STFangsong}
%    \end{macrocode}
%
%    \begin{macrocode}
\newcommand*{\njut@enfn@main@mac}{Times}
\newcommand*{\njut@enfn@sans@mac}{Helvetica}
\newcommand*{\njut@enfn@mono@mac}{Courier}
%    \end{macrocode}
%
%    \begin{macrocode}
\newcommand*{\njut@zhfn@songti@adobe}{Source Han Serif CN}
\newcommand*{\njut@zhfn@heiti@adobe}{Source Han Sans CN}
\newcommand*{\njut@zhfn@kaishu@adobe}{KaiTi}
\newcommand*{\njut@zhfn@fangsong@adobe}{FangSong}
%    \end{macrocode}
%
%    \begin{macrocode}
\newcommand*{\njut@enfn@main@adobe}{Source Serif Pro}
\newcommand*{\njut@enfn@sans@adobe}{Source Sans Pro}
\newcommand*{\njut@enfn@mono@adobe}{Courier}
%</cfg>
%    \end{macrocode}
%
```

**自定义环境问题**
在`njuthesis.dtx`文件中有许多自定义的环境，如`resume`（简历和科研成果）及其下的`education`、`publication`和`projects`等。本质上这些都是黑体标题或含标题的列表。以`publication`为例，其定义主要是如下两部分

```latex
\newcommand*{njut@capresume@publications}{
  攻读{\nju@value@degree}学位完成的学术成果
}
```

```latex
% \begin{environment}{publications}
% 定义作者攻读学位期间发表论文列表环境。此环境必须被放在|resume|环境中。
%    \begin{macrocode}
\newenvironment{publications}{
  \paragraph*{\njut@cap@resume@publications}
  \begin{enumerate}[label=\arabic*., labelindent=0em, leftmargin=*]
}{
  \end{enumerate}
}
%    \end{macrocode}
% \end{environment}
```

如需自定义环境，可以依葫芦画瓢。如修改并扩充上述环境为“已发表文章”及“待发表文章”环境可添加
``` latex
\newcommand*{\njut@cap@resume@publications}{
攻读{\njut@value@degree}学位期间已发表的学术成果
}

\newcommand*{\njut@cap@resume@unpublish}{
攻读{\njut@value@degree}学位期间待发表的学术成果
}


% \begin{environment}{publications}
% 定义作者攻读学位期间发表论文列表环境。此环境必须被放在|resume|环境中。
%    \begin{macrocode}
\newenvironment{publications}{
  \paragraph*{\njut@cap@resume@publications}
  \begin{enumerate}[label=\arabic*., labelindent=0em, leftmargin=*]
}{
  \end{enumerate}
}
%    \end{macrocode}
% \end{environment}

% \begin{environment}{unpublish}
% 定义作者攻读学位期间发表论文列表环境。此环境必须被放在|resume|环境中。
%    \begin{macrocode}
\newenvironment{unpublish}{
  \paragraph*{\njut@cap@resume@unpublish}
  \begin{enumerate}[label=\arabic*., labelindent=0em, leftmargin=*]
}{
  \end{enumerate}
}
%    \end{macrocode}
% \end{environment}
```

另，安装后`\newcommand`和`\newenvironment`分别存于`njuthesis.cfg`文件和`njuthesis.cls`文件中,也可以直接修改这两个文件。


写在最后：
**祝各位毕业顺利！！！**





