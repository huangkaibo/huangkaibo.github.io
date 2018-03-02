echo commit内容: 
read content
git add . && git commit -m "$content" && git push
