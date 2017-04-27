这是vimpress一个修改版本，主要是针对vim + markdown + wordpress 的用户
保持了vimpress基本功能不变的基础上，增加的有：
```
1、markdown高亮
2、本地保存和备份
3、简化命令
4、独立配置文件
```
# 一、安装方法:
```
# 在vundle中添加
Plugin "yinflying/vimpress"
# 然后重启vim并执行
:PluginInstall
# 进入vimpress目录，配置
cd ~/.vim/vundle/vimpress
cp vimpress_config_example vimpress_config
# 按照提示进行配置
vim vimpress_config
```

# 二、使用方法
```
 :BListL
   列出所有本地的博客
 :BListR
   列出所有远程博客
 :BNewR
   创建一个新的博客
 :BNewL
   从本地模板创建一个新的博客(模板位置./backup/blog_template.md,如果不存在，就
   会直接从远程创建模板并保存到本地)
 :BSend
   将博客发送到wordpress上，并且保存到本地
 :BSave
   将博客保存到本地并将之前的备份
```
