---
title: python json
date: 2018-04-07
tags: [python]
---

内容: python json转换

<!-- more -->

# 概述

```
import json
```

# json.dumps()

将dict类型转化为str类型

因为dict类型无法直接写入文件, 而str可以

```
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

# json.loads()

str转化为dict类型

# json.dump()

比起`json.dumps()`多了一个参数， 可以顺便将str写入文件

```
json.dump(name_emb, open(emb_filename, "w"))
```

# json.load()

从文件读取str， 然后转dict

```
jsObj = json.load(open(emb_filename))
```

# 参考资料

[【Python】Json模块dumps、loads、dump、load函数介绍](https://m.baidu.com/from=1019023i/bd_page_type=1/ssid=0/uid=0/pu=usm%401%2Csz%40320_1001%2Cta%40iphone_2_6.0_3_537/baiduid=DDB45A06B637A7A0B61C1DB36850EC31/w=0_10_/t=iphone/l=1/tc?ref=www_iphone&lid=14843342029913449216&order=1&fm=alop&h5ad=2&tj=site_together_1_0_10_title&vit=osres&cltj=normal_title&asres=1&dict=-1&wd=&eqid=cdfe24eecc9de000100000005ac21cde&w_qd=IlPT2AEptyoA_yivD5yjZSUhwhLI&tcplug=1&sec=28764&di=102d9b737841eb5d&bdenc=1&tch=124.486.303.247.1.72&nsrc=IlPT2AEptyoA_yixCFOxXnANedT62v3IGtiTKS2TLDmhmU4thPXrZQRAXyHENW7XHUL6wWz0sqdUgjDyPDpzzBAxePckgjJzmGjb9ffvex_HJBIK&clk_info=%7B%22srcid%22%3A205%2C%22tplname%22%3A%22site_together%22%2C%22t%22%3A1522670825122%2C%22xpath%22%3A%22div-a-h3%22%7D)
