这是vimpress一个修改版本，主要是针对`vim + markdown + wordpress+linux`的用户
保持了vimpress基本功能不变的基础上，增加的有：
```
1、markdown高亮
2、本地保存和备份
3、自动上传本地文件并转换为相应的URL
4、简化命令
5、独立配置文件
```
更详细的说明参见: [http://yinflying.top](http://yinflying.top/604-vimpress%e4%b8%aa%e4%ba%ba%e4%bf%ae%e8%ae%a2%e7%89%88%e8%af%b4%e6%98%8e/)

# 一、安装方法:
## 1.1 使用vundle进行安装(推荐)
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
## 1.2  常规安装方法
自然是vim插件的常规的安装方式，此处不再多述

## 1.3 推荐配置
由于本vimpress打开本地文件的方式是使用`netrw`文件管理器，所以其常用的排序方式并不好用，故最好在`~/.vimrc`中添加下面的配置(时间倒序排列的方式)：
```
"vimpress 基本配置
let g:netrw_sort_direction = "reverse"  "倒序排列
let g:netrw_sort_by        = "time"     "使用时间排序
```
# 二、使用方法
在打开vim中即可以使用如下命令：
```
 :BListL
   列出所有本地的博客
 :BListR
   列出所有远程博客
 :BNewR
   创建一个新的博客
 :BNewL
   从本地模板创建一个新的博客(模板位置./backup/blog_template.md,如果不存在，就会直接从远程创建模板并保存到本地)
 :BSend
   将博客发送到wordpress上，并且保存到本地
 :BSave
   将博客保存到本地并将之前的备份(保存到./backup下)
 :BChangeL
   将博客内部形如(file:///home/xxxx/xxxx.png)上传并转换为URL
```
