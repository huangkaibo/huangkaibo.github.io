---
title: MapReduce
date: 2018-06-17
tags: [大数据,Hadoop]
---

内容: 详细的介绍了MapReduce的流程和架构以及调度

精华: 全部是自己写的,针对自己不明白的都有查询解答,图片也都是自己绘制的

<!-- more -->

# 概述

分布式计算

# 流程图

![](http://p1rbtn7qp.bkt.clouddn.com/18-5-29/9935512.jpg?imageView2/0/q/75\|watermark/2/text/aHVhbmdrYWliby5naXRodWIuaW8=/font/5b6u6L2v6ZuF6buR/fontsize/320/fill/IzAwMDAwMA==/dissolve/100/gravity/SouthEast/dx/10/dy/10)

# split

![](http://p1rbtn7qp.bkt.clouddn.com/18-5-27/99217893.jpg?imageView2/0/q/75\|watermark/2/text/aHVhbmdrYWliby5naXRodWIuaW8=/font/5b6u6L2v6ZuF6buR/fontsize/320/fill/IzAwMDAwMA==/dissolve/100/gravity/SouthEast/dx/10/dy/10)

1. 从HDFS的DataNode节点获取待处理文件的各个block
2. 组合block为File
3. 将File切割为多个split(并不是真实切割, 而是记录每个切割点的位置)(split数量不一定等于block数量)

以词频统计为例, 文件100行, 每10行一个split

split要注意切分为几块, 一般切为一个block大小

一个split会被发给一个mapper

# mapper

## 正式mapper

一个mapper负责一个split

MapReduce原理就是分治, mapper负责分, reduce负责治

以词频统计为例, 分就是将每个单词分开, 比如

```
hello world hello huangkaibo

转化为

(hello, 1)(world, 1)(hello, 1)(huangkaibo, 1)
```

将任务分为原子单位, 再交给reducer进行处理统计, 这就是mapper做的

mapper生成的原子单位(也就是键值对)要写入mapper所在节点的本地磁盘而非HDFS, 因为这只是中间临时文件, 没必要写入HDFS, 写入的话还得占用带宽, 所以如果本地数据突然损坏了, 重新执行这个mapper就好

## shuffle前半段

### partition

mapper产生了很多键值对, 这些键值对会分给不同的reducer处理

哪个键值对分给哪个reducer, 做决定的就是partition这步了

默认是将key hash之后对reducer数量取模, 然后后面几步处理后被分配到对应reducer

### spill/溢写

#### 作用

![](http://p1rbtn7qp.bkt.clouddn.com/18-5-28/39978720.jpg?imageView2/0/q/75\|watermark/2/text/aHVhbmdrYWliby5naXRodWIuaW8=/font/5b6u6L2v6ZuF6buR/fontsize/320/fill/IzAwMDAwMA==/dissolve/100/gravity/SouthEast/dx/10/dy/10)

partition将键值对分为了三份: 分区1/分区2/分区3

但是只是打了分区标签, 键值对顺序没变, 也没有实际分成三堆, 都堆在一起呢, 且都还在内存, 还没写入文件

spill就是将这些键值对写入磁盘, 生成一个文件(**所有的键值对只生成了一个文件**)

#### 步骤

设置一个100MB的环形缓冲区, partition处理结果写入该环形缓冲区

当缓冲区占用80%时, 锁定80%, 触发写入

开个新线程将缓冲区这80%写入磁盘, 生成一个spill文件

partition此时仍在继续处理, 处理结果写在缓冲区的剩下20%里

#### sort

从缓冲区写入磁盘前有一步sort

将键值对按照分区排序, 相同分区按照键值排序, 结果为

![](http://p1rbtn7qp.bkt.clouddn.com/18-5-28/73643116.jpg?imageView2/0/q/75\|watermark/2/text/aHVhbmdrYWliby5naXRodWIuaW8=/font/5b6u6L2v6ZuF6buR/fontsize/320/fill/IzAwMDAwMA==/dissolve/100/gravity/SouthEast/dx/10/dy/10)

也就是三个partition会被搞成一个文件, 但是文件内的三个partition互相分开

#### combine

mapper和reducer都有spill步骤, spill步骤后面都可以接一个combine(可选)

combine就是进行和reducer完全相同的操作

但是不同的是, combine只针对当前spill文件

如果该mapper总共生成了3个spill文件, 每个spill都被combine了, 但是整体并没有

也就是spill1里有个(hello, 3), spill2里有个(hello, 4), 但是并没有被整体整合为(hello, 7)

#### spill结果

生成了很多spill文件

每个spill文件内部按照分区/键值排序了, 如果有combine, 那么相同键的元素值也被累加了

### merge

#### 作用

mapper最终只生成一个文件, 所以要将多个spill文件合并

#### 步骤

partition/spill过程都没有修改数据内容, 还是那些键值对

merge会改变数据内容

比如(hello, 1)(world, 1)(hello, 1)(huangkaibo, 1)

会被merge变为(hello, [1,1])(world, 1)(huangkaibo, 1)

即把相同键的合在一起, 但是不做累加

#### merge结果

![](http://p1rbtn7qp.bkt.clouddn.com/18-5-29/37241400.jpg?imageView2/0/q/75\|watermark/2/text/aHVhbmdrYWliby5naXRodWIuaW8=/font/5b6u6L2v6ZuF6buR/fontsize/320/fill/IzAwMDAwMA==/dissolve/100/gravity/SouthEast/dx/10/dy/10)

# reducer

## shuffle后半段

### copy

就是reducer从mapper那里拷贝待处理文件

reducer需要从多个mapper那里获取文件

reducer不断询问JobTracker哪些map task已结束, 结束了就通过http向该TaskTracker获取文件

注意:

* copy后是放在内存
* 一个reduce是copy对应partition的, 而非mapper上的整个文件

#### 结果

![](http://p1rbtn7qp.bkt.clouddn.com/18-5-28/96140336.jpg?imageView2/0/q/75\|watermark/2/text/aHVhbmdrYWliby5naXRodWIuaW8=/font/5b6u6L2v6ZuF6buR/fontsize/320/fill/IzAwMDAwMA==/dissolve/100/gravity/SouthEast/dx/10/dy/10)

### merge

#### 作用

reducer从多个mapper那里获取了文件, 要合并为一个文件

#### 步骤

merge有三个步骤

1. 内存到内存: 默认不开启, 不知道啥意思
2. 内存到磁盘: copy获取到了内存, 使用与spill相同的形式, 建立环形缓冲区, 缓冲区满了就输入到磁盘(也有sort/combine)
3. 磁盘到磁盘: 内存到磁盘步骤全部进行完毕, 从磁盘读出spill文件, 合并后放回磁盘

感觉就是普通的spill/sort/combine/merge, 但是偏偏就搞出了这么多名词

#### 结果

从多个mapper获取的文件被合并为一个文件

## 正式reducer

### 作用

读入键值对文件, 做处理, 分治的治

### 步骤

比如(hello, [1,1])(world, 1)(huangkaibo, 1)

累加为(hello, 2)(world, 1)(huangkaibo, 1), 并生成结果文件

生成的文件会存到HDFS而非reducer本地磁盘, 以为是最终结果了, 所以要注重安全

# 代码

## Mapper

```java
public class WCMapper extends Mapper<LongWritable, Text, Text, LongWritable> {

    @Override
    protected void map(LongWritable key, Text value,Mapper<LongWritable, Text, Text, LongWritable>.Context context) throws IOException, InterruptedException {
        //接收数据V1
        String line=value.toString();
        //切分数据
        String[] words=line.split(" ");
        //循环
        for (String w:words) {
            //出现一次，记作一个，输出
            context.write(new Text(w), new LongWritable(1));
        }
    }
}
```

## Reducer

```java
public class WCReducer extends Reducer<Text, LongWritable,Text, LongWritable>{

    @Override
    protected void reduce(Text key, Iterable<LongWritable> v2s,Reducer<Text, LongWritable, Text, LongWritable>.Context context) throws IOException,                                                      InterruptedException {
        //接收数据
        //定义一个计算器
        long counter=0;
        //循环v2s
        for (LongWritable i:v2s) {
            counter+=i.get();
        }
        //输出
        context.write(key,new LongWritable(counter));
    }
}
```

## main

```java
public class WordCount {

    public static  void main(String[] args) throws IOException, ClassNotFoundException, InterruptedException{

        //构建job对象
        Job job=Job.getInstance(new Configuration());

        //main方法所在的类
        job.setJarByClass(WordCount.class);

        //设置Mapper相关属性
        job.setMapperClass(WCMapper.class);
        job.setMapOutputKeyClass(Text.class);
        job.setMapOutputValueClass(LongWritable.class);
        FileInputFormat.setInputPaths(job, new Path("/words.txt"));

        //设置Reducer相关属性
        job.setReducerClass(WCReducer.class);
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(LongWritable.class);
        FileOutputFormat.setOutputPath(job, new Path("/wcount.txt"));

        //提交任务
        job.waitForCompletion(true);
    }
}
```

# MapReduce调度结构

## JobTracker

JobTracker位于NameNode, 负责调度/管理

### 调度流程

1. Client向JobTracker发送job请求, 附加jar大小等信息
2. JobTracker返回一个HDFS的地址和jobID
3. Client将jar文件发送到指定的HDFS地址
4. Client向JobTracker提交job信息(jobID, jar存放位置, 配置信息等)
5. JobTracker将任务放入调度器
6. TaskTracker通过心跳机制领取任务(领取的是job信息)
7. TaskTracker下载jar文件和配置文件
8. TaskTracker启动子进程执行任务
9. TaskTracker将结果写入到HDFS中

### 监控流程

1. TaskTracker定时向JobTracker发送心跳信息(自身健康情况和任务执行情况)
2. JobTracker由此来监控/管理/失败重启TaskTracker

### 参考资料

[从零开始学Hadoop——浅析MapReduce（一）](https://blog.csdn.net/u010168160/article/details/51438897)

## TaskTracker

TaskTracker实际执行mapper/reducer任务

一个TaskTracker上可以同时执行多个mapper和多个reducer, 依据自身mapper slot和reducer slot个数, mapper slot个数满了就不能再生成mapper, reducer slot个数满了就不能再生成reducer, 简单说就是限制了一个节点能有几个mapper和reducer

TaskTracker定时发心跳给JobTracker汇报自身健康情况和任务执行情况, 供其监控管理

# 参考资料

[简单的代码了解](https://blog.csdn.net/u010168160/article/details/51439402)

[极其详细的介绍了shuffle](https://www.cnblogs.com/ljy2013/articles/4435657.html)

[代码解释sort步骤详情](https://www.cnblogs.com/yurunmiao/p/4178389.html)

[shuffle过程中sort总结](https://blog.csdn.net/u013080251/article/details/60146294)

[JobTracker调度](https://blog.csdn.net/u010176083/article/details/53269317)

[各步骤很详细](https://blog.csdn.net/aijiudu/article/details/72353510)