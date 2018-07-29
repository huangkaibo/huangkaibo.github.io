---
title: python 序列化 json和pickle
date: 2018-04-07
updated: 2018-07-29
tags: [python]
---

内容: python 序列化

<!-- more -->

# 概述

python序列化有两个模块: json和pickle, 都是自带的

## json序列化

json被用于在不同语言之间传输数据, 转化为json就能传给其他语言使用, 这个就叫序列化

python的dict类型接近json, 所以python的json模块就是将python的dict转化为json, 传给其他语言使用

## pickle序列化

pickle能将python的任何类型序列化, 但是序列化后的类型不是json这种各个语言通用的, 序列化后的类型只能被python识别, 可以用于python语言间传数据

# json

## json.dumps()

将dict类型转化为json, 就是个str类型

```
import json

name_emb = {'a':'1111','b':'2222','c':'3333','d':'4444'}   
  
jsObj = json.dumps(name_emb)

print(name_emb)  
print(jsObj)  
  
print(type(name_emb))  
print(type(jsObj))
```

```
{'a': '1111', 'c': '3333', 'b': '2222', 'd': '4444'}  
{"a": "1111", "c": "3333", "b": "2222", "d": "4444"}  
<type 'dict'>  
<type 'str'>
```

## json.loads()

json字符串转化为dict类型

## json.dump()

比起`json.dumps()`多了一个参数, 可以顺便将str写入文件

```
json.dump(name_emb, open(emb_filename, "w"))
```

## json.load()

从文件读取json字符串, 然后转dict

```
jsObj = json.load(open(emb_filename))
```

## 参考资料

[【Python】Json模块dumps、loads、dump、load函数介绍](https://m.baidu.com/from=1019023i/bd_page_type=1/ssid=0/uid=0/pu=usm%401%2Csz%40320_1001%2Cta%40iphone_2_6.0_3_537/baiduid=DDB45A06B637A7A0B61C1DB36850EC31/w=0_10_/t=iphone/l=1/tc?ref=www_iphone&lid=14843342029913449216&order=1&fm=alop&h5ad=2&tj=site_together_1_0_10_title&vit=osres&cltj=normal_title&asres=1&dict=-1&wd=&eqid=cdfe24eecc9de000100000005ac21cde&w_qd=IlPT2AEptyoA_yivD5yjZSUhwhLI&tcplug=1&sec=28764&di=102d9b737841eb5d&bdenc=1&tch=124.486.303.247.1.72&nsrc=IlPT2AEptyoA_yixCFOxXnANedT62v3IGtiTKS2TLDmhmU4thPXrZQRAXyHENW7XHUL6wWz0sqdUgjDyPDpzzBAxePckgjJzmGjb9ffvex_HJBIK&clk_info=%7B%22srcid%22%3A205%2C%22tplname%22%3A%22site_together%22%2C%22t%22%3A1522670825122%2C%22xpath%22%3A%22div-a-h3%22%7D)

# pickle

## 概述

序列化有很多叫法: serializing/pickling/serialization/marshalling/flattening

python里使用pickling/unpickling来称呼

## pickle.dumps()

将python数据转化为bytes类型

```python
import pickle

dic = {'k1':'v1', 'k2':'v2'}
res = pickle.dumps(dic)
# b'\x80\x03}q\x00(X\x02\x00\x00\x00k1q\x01X\x02\x00\x00\x00v1q\x02X\x02\x00\x00\x00k2q\x03X\x02\x00\x00\x00v2q\x04u.'
# 是一个bytes类型

# bytes类型要存入文件, 模式需要设为b
with open('./tmp.txt', 'wb') as f:
    f.write(res)
```

## pickle.loads()

将`pickle.dumps()`得到的bytes类型数据转化为python内置类型

## pickle.dump()

将python数据序列化为bytes类型, 同时写入文件, 就是上面的简化版

```python
dic = {'k1':'v1', 'k2':'v2'}
with open('./tmp.txt', 'wb') as f:
    pickle.dump(dic, f)
```

## pickle.load()

从文件加载

# 参考资料

[简单谈谈Python中的json与pickle](https://www.jb51.net/article/119010.htm)