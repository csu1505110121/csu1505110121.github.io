---
layout: post
title:  "Configuration of a Computer Cluster"
date:   2019-07-27 22:02 +0800
categories: Linux
tags: Network Configuration
---

打开网络转发机制
{% highlight bash %}
echo "1" > /proc/sys/net/ipv4/ip_forward
{% endhighlight %}

按照常规的设置将集群设置成一个主节点和若干节点
{% highlight bash %}
主节点ip：xxx.xxx.xxx.xxx （动态）
节点ip：192.168.xxx.xxx (静态)
{% endhighlight %}

设置iptables转发机制
{% highlight bash %}
#main_node=xxx.xxx.xxx.xxx(主节点动态ip)
#PORT 目标节点的端口号，人为指定
#192.168.xxx.xxx 目标节点的静态ip
#-o eno1 目标机器的网卡名
#-i eno1 目标机器的网卡名
iptables -F
iptables -X

iptables -t nat -A PREROUTING -d ${main_node} -p tcp --dport ${PORT}(you specified) -j DNAT --to-dest 192.168.xxx.xxx:22 (the static ip of the node)
iptables -t nat -A POSTROUTING -d 192.168.xxx.xxx -p tcp --dport 22 -j SNAT --to 192.168.120.1(static ip of the main node)
iptables -A FORWARD -o eno1 -d 192.168.xxx.xxx -p tcp --dport 22 -j ACCEPT
iptables -A FORWARD -i eno1 -d 192.168.xxx.xxx -p tcp --dport 22 -j ACCEPT
{% endhighlight %}

至此，一个集群就已经搭建完毕，如果想登陆端口号为100的机器可以通过如下命令进行登陆
{% highlight bash %}
ssh -p 100 username@main_node(主节点ip)
{% endhighlight %}

***特别鸣谢 Dr. Xiaoyu Xie and Zhen Luo.***
