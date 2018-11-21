---
title: python requests模块
date: 2018-07-29
tags: [python]
---

内容: python request模块使用

<!-- more -->

# 引入包

```python
import requests
```

requests是第三方模块, 不是python原生的, 需要pip下载

python原生的是urllib和urllib2

# get请求

```python
response = requests.get("http://www.baidu.com")

# 带参数, 参数要是字典类型
params = {'k1':'v1', 'k2':['v2.1', 'v2.2']}
response = requests.get("http://www.baidu.com", params=params)
```

# post请求

```python
response = requests.post("http://www.baidu.com")

# 带参数: 字典类型
params = {'k1':'v1', 'k2':['v2.1', 'v2.2']}
response = requests.post("http://www.baidu.com", data=params)

# 带参数: json类型
params = {'k1':'v1', 'k2':'v2'}
response = requests.post("http://www.baidu.com", data=json.dumps(params)

# 发送文件
files = {'file1': open('test.txt1', 'rb'), 'file2': open('test2.txt', 'rb')}
response = requests.post("http://www.baidu.com", files=files)
```

# response结构

```
res.url
res.encoding
res.cookies

# 请求响应头: 返回字典类型
res.headers
res.headers["Server"]

# 返回状态码
res.status_code

# 返回内容: 就是html源码
# 字符串类型
res.text
# 二进制类型
res.content
# res.text是推测编码后decode的, 可能有错
# 如果有错就自己用content来decode

# 如果返回的是json
res.json()
```

![](http://media.huangkaibo.cn/18-7-5/25473573.jpg)

# 自定义headers

```python
headers = {'user-agent': 'myAgent'}
response = requests.get("http://www.baidu.com", headers=headers)
```

# 自定义cookies

```python
cookies = {'user-cookies': 'myCookies'}
response = requests.get("http://www.baidu.com", cookies=cookies)
```

# 自定义代理

```python
proxies = {
  "http": "http://10.10.1.10:3128",
  "https": "http://10.10.1.10:1080",
}

response = requests.get("http://www.baidu.com", proxies=proxies)
```

# session

```python
# 获取session
session = request.Session()
login_data = {'email': 'huangkaibochn@gmail.com', 'password': '123456'}
session.post("http://www.baidu.com/login", login_data)
response = session.get("http://www.baidu.com/result")
# @TODO
```