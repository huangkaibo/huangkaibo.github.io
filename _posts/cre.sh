# 这个脚本是将我平常写的markdown笔记转化成博客要求的格式
# 也就是文章名字从netstat.md转化为2018-03-02-netstat.md
# 内容加上一个头部, 如下
# ---
# title: free
# date: 2018-03-02
# tags: [Linux, 命令]
# ---

# 内容: 介绍了free命令

# 精华: 主要分辨了buffer和cache

# <!-- more -->

# ex. netstat.md
file_name_before=$1
# ex. 2018-03-02
date_now=`date +%Y-%m-%d`
# ex. 2018-03-02-netstat.md
file_name_after=$date_now-"$file_name_before"
# ex. netstat
title=${file_name_before%.*}

echo 输入内容
read content
echo '输入精华(没有输入null)'
read essence
echo 输入tags 以,分割
read tags
# ex. [Linux, 命令]
tags=[$tags]

mv "$file_name_before" "$file_name_after"

if [[ $essence == null ]]
then
    sed -i "1i\---\ntitle: $title\ndate: $date_now\ntags: $tags\n---\n\n内容: $content\n\n<!-- more -->\n" "$file_name_after"
else
    sed -i "1i\---\ntitle: $title\ndate: $date_now\ntags: $tags\n---\n\n内容: $content\n\n精华: $essence\n\n<!-- more -->\n" "$file_name_after"
fi

# 文章是从我自己win的有道云笔记转过来的, 所以有win和linux的换行符不同的问题, 这里解决
sed -i "s///g" "$file_name_after"

echo success
