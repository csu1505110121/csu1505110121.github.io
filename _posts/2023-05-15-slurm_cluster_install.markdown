---
layout: post
title:  "Centos 9 Stream上安装Slurm集群和测试"
date:   2023-05-15 14:13 +0800
categories: Linux
tags: slurm
---
<!--
 >Theory and Computational Biology: From Molecular to System
-->
<!-- > 当你打开我这个网页时，恭喜你，你离毕业不远了，撸起袖子加油干啊，奥利给！  
> <p align="right">-- Forty Braver </p>
-->



>	穷则变，变则通，通则久


**本教程是在`CentOS Stream release 9`下进行，对于CentOS 7或者其他发行版本的安装一些命令存在差异，本教程仅供参考**

## 先前准备工作

- 查看当前服务器的系统版本
```
>>> cat /etc/redhat-release 
CentOS Stream release 9
```

- 本教程中服务器的配置情况

| name of node | internal ip | external ip | 
| :-           |:-           |:-           |
| main node    |192.168.1.100|100.xxx.xxx.x|
| comput node01|192.168.1.1  |-            |
| comput node02|192.168.1.2  |-            |
| comput node03|192.168.1.3  |-            |

其中主节点`main node`存在着两个网卡，一个网卡(姑且叫做`eno01`)直接连接着外网进行互联网的访问，另一个网卡(`eno02`)进行内部网络的访问和转发。对于计算节点并没有多个网卡的需要，只需要有一个网卡就行。对于内部网络本教程中设定的是`192.168.1.x`的网段，这个大家可以随便设定，但是保证所有服务器都是在同一个网段下即可。譬如，该内网内部的计算节点的ip就设定为`192.168.1.1`~`192.168.1.3`。


## 集群的搭建

- 系统OS的安装

和安装普通机器一样，集群中的机器都需要事先安装好对应的系统，关于机器硬盘的分区，本教程采用如下的规划：

1. 主节点的分区配置 (总过14 Tb)

| partition name | size |
|:-              | :-   |
|swap            | 2048 Mib|
|/boot           | 1024 Mib|
|/boot/efi (取决于用什么方式安装)      | 1024 Mib|
|/var            | 2048 Mib|
|/               | 300 Gib |
|/home           | 13.78 Tib|

2. 计算节点的分区配置 (最多700 Gb)

| partition name | size |
|:-              | :-   |
|swap            | 2048 Mib|
|/boot           | 1024 Mib|
|/boot/efi (取决于用什么方式安装)      | 1024 Mib|
|/var            | 2048 Mib|
|/               | 30 Gib |
|/home           | 650 Gib|


- 网络的配置

配置动态ip和静态ip，因为`CentOS 9`和`CentOS 7`的网卡管理地址发生了变化，安装在`CentOS 7`的小伙伴这里需要额外注意下

1. 主节点的网络配置

```
vim /etc/NetworkManager/system-connections/eno02 (eno02就是用来管理内部ip的网口)

[ipv4]
method=manual      (改为手动，不让其自动获取ip)
address=192.168.1.100   （设置为指定的ip）
network=192.168.20.0     （保证该网段下的机器都能够互相通信）
netmask=255.255.255.0

```

2. 计算节点网络配置

```
vim /etc/NetworkManager/system-connections/eno01 (eno01用来获取ip的网口)

[ipv4]
method=manual      (改为手动，不让其自动获取ip)
address=192.168.1.1   （设置为指定的ip）
gateway=192.168.20.100  (保证后续该内部结点可以通过主节点来进行外网的访问）
netmask=255.255.255.0
```

网卡配置的更新和网口的启动 (CentOS 9和CentOS 7发行版本的另一个重要区别)

```
nmcli c reload (配置的重载)
nmcli c up etho_name (网口的启动，譬如主节点想要启动eno02，就直接nmcli c up eno02)
```

- 内网访问互联网 (主要是为了后续服务器库更新的方便)

利用`iptables`进行转发，使得计算节点可以直接访问外部的互联网，相关的内容可以看我前篇[博客](https://csu1505110121.github.io/linux/2019/07/27/Network-Configuration.html) 

***只需要在主节点上进行相关配置***

```
# 主节点配置(可以访问internet的节点配置)
1. 配置内核参数
## /etc/sysctl.conf ##
net.ipv4.ip_forward = 1

2. 配置SNAT防火墙映射
vim /opt/iptable.sh

# 添加如下路由规则

iptables -F
iptables -X

# share the internet
iptables -t nat -A POSTROUTING -s 192.168.20.0/24 (内网网段) -j SNAT --to-source 主节点上动态的ip网址(可以从外网访问的网址)
```

***只需要在计算节点上执行***

```
# 内部结点配置
1. 配置默认网关到主节点，dns设置为8.8.8.8 让其可以解析域名
ip route add default via 192.168.xxx.xxx (主节点的对内网ip)
echo "nameserver 8.8.8.8" > /etc/resolv.conf
```

- 节点间进行无密传输(主要是为了后续传输文件方便) 可以看我另一篇[博客](https://csu1505110121.github.io/linux/2020/10/28/SSH-KEYGEN.html)

```
# 生成密钥
ssh-keygen 

# 将公钥传输到各个计算节点上
ssh-copy-id node1
## 会要求输入node1上对应的密码，后续再登录node1就不再需要密码了
```


## Slurm服务相关软件的安装


### 安装用到的软件和对应的版本号

| software | version |
| :-       | :-      |
| munge    | 0.5.15  |
| slurm    | 23.02.2 |
| hwloc    | 2.8.0   |
| libevent | 2.1.12-stable  |
| pmix     | 4.2.3   |
| ucx      | 1.14.0  |
| openmpi  | 4.1.5   |

- 一些依赖库的安装

***主节点和计算节点都进行安装以下的库文件***

```
yum install openssl openssl-devel g++ gcc python3-pip openssh-server cmake 
```

***主节点需多安装mariadb数据库包***

这里不使用mysql库，是因为centos上更加兼容mariadb数据包

```
yum install mariadb mariadb-server
```

- 主节点数据库的启用

```
mariadb数据库的激活和启用

systemctl start mariadb
systemctl enable mariadb

## 数据库的安装
mysql_secure_installation （按照提示一步步走完就行）
```

修改数据库的配置文件
```
创建/etc/my.cnf.d/innodb.cnf并添加以下内容

[mysqld]
 innodb_buffer_pool_size=1024M
 innodb_log_file_size=64M
 innodb_lock_wait_timeout=900
```

重新启用数据库服务
```
systemctl stop mariadb
systemctl start mariadb
```

创建并配置`slurm_acc_db`数据库

```
$ mysql -u root -p
 mysql> grant all on slurm_acct_db.* TO 'slurm'@'localhost' identified by 'some_pass' with grant option;  (some_pass自行进行修改)
 mysql> create database slurm_acct_db;
```


### munge的编译

```
# 解压munge软件安装包
tar xf munge-0.5.15.tar.xz

cd munge-0.5.15

# 安装目录 /usr/local/munge-0.5.15
# 后续的软件都安装到/usr/local中并用软连接进行链接

./configure --prefix=/usr/local/munge-0.5.15

make -j 4 && make -j 4 install (4是cpu核心数)

cd /usr/local && ln -s munge-0.5.15 munge
```

添加环境变量

```
vim /etc/profile.d/munge.sh

export MUNGE_HOME=/usr/local/munge
export PATH=$MUNGE_HOME/bin:$PATH
export PATH=$MUNGE_HOME/sbin:$PATH
```

```
# 立即生效
source /etc/profile.d/munge.sh
```

### 编译pmix

在编译`pmix`前需要事先编译`hwloc`和`libevent`，编译步骤如下

* 编译`hwloc`

```
# 解压hwloc
tar xvf hwloc-2.8.0.tar.bz2

cd hwloc-2.8.0

# 安装目录 /usr/local/hwloc-2.8.0
./configure --prefix=/usr/local/hwloc-2.8.0

make -j 4 && make -j 4 install (4是cpu核心数)

cd /usr/local && ln -s hwloc-2.8.0 hwloc
```

* 编译`libevent`

```
# 解压libevent
tar xf libevent-2.1.12-stable.tar.gz

cd libevent-2.1.12-stable

# 安装目录 /usr/local/libevent-2.1.12
./configure --prefix=/usr/local/libevent-2.1.12

make -j 4 && make -j 4 install (4是cpu核心数)

cd /usr/local && ln -s libevent-2.1.12 libevent
```

* 最后编译`pmix`

```
# 解压pmix
tar xf pmix-4.2.3.tar.bz2

cd pmix-4.2.3

# 必须置顶刚才的两个依赖路径，因为我把他们单独放在一个文件夹了，方便以后更新、删除
./configure --prefix=/usr/local/pmix-4.2.3  --with-libevent=/usr/local/libevent --with-hwloc=/usr/local/hwloc

make -j 4 && make -j 4 install (4是cpu核心数)

cd /usr/local && ln -s pmix-4.2.3 pmix
```


### 编译openmpi

* 先安装`ucx`包

```
# 解压ucx安装包
tar xf ucx-1.14.0.tar.gz

cd ucx-1.14.0

./configure --prefix=/usr/local/ucx-1.14.0

make -j 4 && make -j 4 install 

cd /usr/local && ln -s ucx-1.14.0 ucx
```

* openmpi编译安装

```
# 解压openmpi安装包
tar xf openmpi-4.1.5.tar.bz2

cd openmpi-4.1.5

# 必须设定上述编译的库依赖路径，因为我把他们单独放在一个文件夹了，方便以后更新、删除
./configure --prefix=/usr/local/openmpi-4.1.5 --with-pmix=/usr/local/pmix --with-ucx=/usr/local/ucx --with-hwloc=/usr/local/hwloc --with-libevent=/usr/local/libevent

make -j 4 && make -j 4 install

cd /usr/local && ln -s openmpi-4.1.5 openmpi
```

添加环境变量

```
vim /etc/profile.d/openmpi.sh

export OPENMPI_HOME=/usr/local/openmpi
export PATH=$OPENMPI_HOME/bin:$PATH
export LD_LIBRARY_PATH=$OPENMPI_HOME/lib:$LD_LIBRARY_PATH
```

```
# 立即生效
source /etc/profile.d/openmpi.sh
```

### 编译slurm

```
# 解压slurm安装包
tar xf slurm-23.02.2.tar.bz2

cd slurm-23.03.2

# 设置上述安装的库的软件包，因为我把他们单独放在一个文件夹了，方便以后更新、删除
./configure --prefix=/usr/local/slurm-23.02.2 --with-pmix=/usr/local/pmix --with-munge=/usr/local/munge --with-hwloc=/usr/local/hwloc --with-ucx=/usr/local/ucx

make -j 4 && make -j 4 install

cd /usr/local && ln -s slurm-23.02.2 slurm
```

添加环境变量

```
vim /etc/profile.d/slurm.sh

export SLURM_HOME=/usr/local/slurm
export PATH=$SLURM_HOME/bin:$PATH
export PATH=$SLURM_HOME/sbin:$PATH
export LD_LIBRARY_PATH=$SLURM_HOME/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$SLURM_HOME/lib/slurm:$LD_LIBRARY_PATH
```

```
# 立即生效
source /etc/profile.d/slurm.sh
```

## 打开munge服务和slurm服务，连通主节点和计算节点

- munge key的产生

```
# 主节点munge key的产生
mungekey # 相应的munge.key文件会产生在 /usr/local/munge/etc/munge文件夹下

# munge key的分发
# 将主节点上的key分发到内部的计算节点上

scp /usr/local/munge/etc/munge/munge.key root@comput-node:/usr/local/munge/etc/munge
```

- 查看munge是否正常运行 (***主节点和计算节点都需要开启***)

```
munged

(应该会报 failed to check socket dir)
解决方案：
手动创建 /usr/local/munge/var/run/munge

# 查看是否有报错，没有error就行
cat /usr/local/munge/var/log/munge/munged.log


# 查看是否是munge相关的进程
ps aux | grep munge
```

- 开启slurmdbd (***只需要主节点上运行***)

```
slurmdbd

# 查看是否有报错，你启动以后的时间里没有error就行，之前的error没事
cat /var/log/slurmdbd.log

# 查看是否有相关进程
ps aux | grep slurmdbd

```

- 开启slurmctld (***只需要主节点上运行***)

```
slurmctld

# 查看是否有报错，你启动以后的时间里没有error就行，之前的error没事
cat /var/log/slurmctld.log

# 过几秒再看看，是否有问题
ps aux | grep slurmctld
```

- 创建`slurmdbd.conf`数据库相关的文件 (***只需要主节点设置***)

文件放置在`/usr/local/slurm/etc/slurmdbd.conf`，需要手动创建

```
ArchiveEvents=yes
ArchiveJobs=yes
ArchiveResvs=yes
ArchiveSteps=no
ArchiveSuspend=no
ArchiveTXN=no
ArchiveUsage=no
AuthInfo=/usr/local/munge/var/run/munge/munge.socket.2
AuthType=auth/munge   (着重注意)
DbdHost=localhost     (主节点)
DebugLevel=info
PurgeEventAfter=1month
PurgeJobAfter=12month
PurgeResvAfter=1month
PurgeStepAfter=1month
PurgeSuspendAfter=1month
PurgeTXNAfter=12month
PurgeUsageAfter=24month
LogFile=/var/log/slurmdbd.log
PidFile=/var/run/slurmdbd.pid
SlurmUser=root        (follow 别人的就没有设定slurm用户了)
StoragePass=12345678
StorageType=accounting_storage/mysql  (如果这个报错，我看了下是没有对应的so文件，我就直接使用的是accounting_storage/none)
StorageUser=slurm
StorageHost=localhost (主节点)
StoragePort=3306
```

- 创建并配置`slurm.conf`文件 (**主节点和计算节点上都需要配置，且文件需要一致**)

文件放置在`/usr/local/slurm/etc/slurm.conf`，需要手动创建

```
; 单机就是 localhost即可
SlurmctldHost=localhost

; 这个是mpi的默认值，用户输入 --mpi=mpix_v3 这时候会覆盖这个
MpiDefault=pmix

; 这个优先用cgroup，如果报错，换这个
ProctrackType=proctrack/linuxproc

; 下面这些都是数据库相关的，配置一下就行
AccountingStorageHost=localhost
; 合格是munge的位置
AccountingStoragePass=/usr/local/munge/var/run/munge/munge.socket.2
AccountingStorageType=accounting_storage/slurmdbd
AccountingStorageUser=slurm
JobCompHost=localhost
JobCompLoc=slurm_job_db
JobCompPass=12345678
JobCompType=jobcomp/mysql
JobCompUser=slurm

; 这个是各个计算节点，单机的话直接 localhost就行，至于CPUs就是你的cpu核心数，错了也没事，一会开启时会有提示应该是多少，Sockets，cpu插槽数；CoresPerSocket每个插槽多少核心，ThreadsPerCore每个核心多少线程， RealMemory内存（不设置的话，用户申请--mem会报错）
NodeName=localhost CPUs=6 Sockets=1 CoresPerSocket=6 ThreadsPerCore=1 RealMemory=32041 State=UNKNOWN
PartitionName=ptt1 Nodes=ALL Default=YES MaxTime=INFINITE State=UP

(最后的NodeName和PartitionName根据自己cluster的结构进行设置)
```


## 手动添加服务

- munge (***主节点和计算节点都需要***)

```
#vim /etc/systemd/system/munge.service

# /etc/systemd/system/munge.service
[Unit]
Description=MUNGE authentication service
Documentation=man:munged(8)
After=network.target
After=time-sync.target

[Service]
Type=forking
EnvironmentFile=-/usr/local/mung/etc/default/munge
ExecStart=/usr/local/munge/sbin/munged $OPTIONS
PIDFile=/usr/local/munge/var/run/munge/munged.pid
RuntimeDirectory=munge
RuntimeDirectoryMode=0755
Restart=on-abort

[Install]
WantedBy=multi-user.target
```

- slurmdbd (**只有主节点需要**)

```
# vim /etc/systemd/system/slurmdbd.service

# /lib/systemd/system/slurmdbd.service
[Unit]
Description=Slurm DBD accounting daemon
After=network.target munge.service network-online.target mysql.service
Wants=munge.service network-online.target mysql.service
ConditionPathExists=/usr/local/slurm/etc/slurmdbd.conf
Documentation=man:slurmdbd(8)

[Service]
Type=simple
EnvironmentFile=-/etc/default/slurmdbd
ExecStart=/usr/local/slurm/sbin/slurmdbd -D $SLURMDBD_OPTIONS
ExecReload=/bin/kill -HUP $MAINPID
PIDFile=/var/run/slurmdbd.pid
LimitNOFILE=65536
TasksMax=infinity

[Install]
WantedBy=multi-user.target
```

- slurmctld (**只有主节点需要**)

```
# vim /etc/systemd/system/slurmctld.service

# /lib/systemd/system/slurmctld.service
[Unit]
Description=Slurm controller daemon
After=slurmdbd.service
Wants=slurmdbd.service
ConditionPathExists=/usr/local/slurm/etc/slurm.conf
Documentation=man:slurmctld(8)

[Service]
Type=simple
EnvironmentFile=-/etc/default/slurmctld
ExecStart=/usr/local/slurm/sbin/slurmctld -D $SLURMCTLD_OPTIONS
ExecReload=/bin/kill -HUP $MAINPID
PIDFile=/var/run/slurmctld.pid
LimitNOFILE=65536
TasksMax=infinity

[Install]
WantedBy=multi-user.target
```

- slurmd (***主节点和计算节点都需要***)

```
# /lib/systemd/system/slurmd.service
[Unit]
Description=Slurm node daemon
After=remote-fs.target slurmctld.service
Wants=slurmctld.service
ConditionPathExists=/usr/local/slurm/etc/slurm.conf
Documentation=man:slurmd(8)

[Service]
Type=simple
EnvironmentFile=-/etc/default/slurmd
ExecStart=/usr/local/slurm/sbin/slurmd -D $SLURMD_OPTIONS
ExecReload=/bin/kill -HUP $MAINPID
PIDFile=/var/run/slurmd.pid
KillMode=process
LimitNOFILE=131072
LimitMEMLOCK=infinity
LimitSTACK=infinity
Delegate=yes
TasksMax=infinity

[Install]
WantedBy=multi-user.target
```

## 设置开机启动

```
# 主节点
systemctl enable --now mysql
systemctl enable --now munge
systemctl enable --now slurmdbd
systemctl enable --now slurmctld
systemctl enable --now slurmd

# 计算节点
systemctl enable --now munge
systemctl enable --now slurmd
```

## 查看集群

```
sinfo

# 一般应该是下面的
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
ptt1*        up   infinite      1   idle localhost
```

## 可能存在的问题


1. 计算节点无法连接主节点contorller

```
尝试将firewalld服务关掉然后再重新冲洗slurmd、slurmctld相关服务，将计算节点重新启动下试试
```

2. 计算节点的时间戳和主节点的时间戳不一致

***在计算节点上进行设置***

```
# 利用chrony创建 ntp服务器来进行时间同步

# 编辑 /etc/chrony.conf

# Use public servers from the pool.ntp.org project.
# Please consider joining the pool (https://www.pool.ntp.org/join.html).
#pool 2.centos.pool.ntp.org iburst
server 192.168.xx.xxx iburst （修改ip为主节点的ip）


# 打开
# Allow NTP client access from local network.
allow 192.168.0.0/16
```

```
# 添加对应的规则

$ firewall-cmd --add-service=ntp --permanent
$ firewall-cmd --reload
```

```
# 设置对应的时区

timedatectl list-timezones | grep -E 'America/Los*'

timedatectl set-timezon America/Los_Angeles

# 设置完时区后，强制同步下系统时间

chronyc -a makestep

# 启用NTP时间同步
timedatectl set-ntp yes

# 校准时间服务器
chronyc tracking (查看Leap status是否是Normal)
```




## 本博客参考的网址

- [Slurm installation](https://southgreenplatform.github.io/trainings/hpc/slurminstallation/)

- [slurm集群安装与踩坑详解](https://yuhldr.github.io/posts/bfa79f01.html)

- [Linux Chrony设置服务器集群同步时间](https://www.linuxprobe.com/centos7-chrony-time.html)







