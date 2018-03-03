# 这个脚本就是简单整合了发布过程
echo commit内容: 
read content
git add -A && git commit -m "$content" && git push
