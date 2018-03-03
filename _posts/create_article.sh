# 这个脚本是将我平常写的markdown笔记转化成博客要求的格式
# 也就是名字从free.md转化为2018-03-02-free.md
# 内容加上一个头部, 头部包括标题 日期 tags

# ex. free.md
file_name_before=$1
# ex. 2018-03-02
date_now=`date +%Y-%m-%d`
# ex. 2018-03-02-free.md
file_name_after=$date_now-$file_name_before
# ex. free
title=${file_name_before%.*}

echo 输入tags 以,分割
read tags
# ex. [Linux, 命令]
tags=[$tags]

mv $file_name_before $file_name_after

sed -i "1i\---\ntitle: $title\ndate: $date_now\ntags: $tags\n---\n" $file_name_after
echo success
