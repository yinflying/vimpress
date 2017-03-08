" Copyright (C) 2007 Adrien Friggeri.
"
" This program is free software; you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation; either version 2, or (at your option)
" any later version.
"
" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with this program; if not, write to the Free Software Foundation,
" Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
" 
" Maintainer:	Adrien Friggeri <adrien@friggeri.net>
" URL:		http://www.friggeri.net/projets/vimblog/
" Version:	0.9
" Last Change:  2007 July 13
"
" Commands :
" ":BListL"
"   Lists all articles in the blog
" ":BListR"
"   Lists all articles in the local
" ":BNew"
"   Opens page to write new article
" ":BOpen <id>"
"   Opens the article <id> for edition
" ":BSend"
"   Saves the article to the blog
" ":BSave"
"   Save the article in the local
"
" Configuration : 
"   Edit the "Settings" section (starts at line 51).
"
"   If you wish to use UTW tags, you should install the following plugin : 
"   http://blog.circlesixdesign.com/download/utw-rpc-autotag/
"   and set "enable_tags" to 1 on line 50
"
" Usage : 
"   Just fill in the blanks, do not modify the highlighted parts and everything
"   should be ok.
"
"修正：
"   增加本地功能

command! -nargs=0 BListR exec("py blog_list_posts()")
command! -nargs=0 BNew exec("py blog_new_post()")
command! -nargs=0 BSend exec("py blog_send_post()")
command! -nargs=0 BSave exec("py blog_save_posts()")
command! -nargs=0 BListL exec("py blog_list_local_posts()")
command! -nargs=1 BOpen exec('py blog_open_post(<f-args>)')
python <<EOF
# -*- coding: utf-8 -*-
import urllib , urllib2 , vim , xml.dom.minidom , xmlrpclib , sys , string , re
import os,shutil,time

#####################
#      Settings     #
#####################

#you could choose setting here
enable_tags = 1
blog_username = ''
blog_password = ''
blog_url = ''
blog_local = ''

#or use extra file to set 
user_home = os.path.expanduser('~')
linenum = 1;
for line in open(user_home + '/.vim/bundle/vimpress/vimpress_config'):
    if(linenum == 1):
        blog_username = line;
    if(linenum == 2):
        blog_password = line;
    if(linenum == 3):
        blog_url = line;
    if(linenum == 4):
        blog_local = line;
        break;
    linenum = linenum + 1

#####################
# Do not edit below #
#####################

handler = xmlrpclib.ServerProxy(blog_url).metaWeblog
edit = 1

def blog_edit_off():
  global edit
  if edit:
    edit = 0
    for i in ["i","a","s","o","I","A","S","O"]:
      vim.command('map '+i+' <nop>')

def blog_edit_on():
  global edit
  if not edit:
    edit = 1
    for i in ["i","a","s","o","I","A","S","O"]:
      vim.command('unmap '+i)

def blog_send_post():
  vim.command("BSave")
  def get_line(what):
    start = 0
    while not vim.current.buffer[start].startswith('"'+what):
      start +=1
    return start
  def get_meta(what): 
    start = get_line(what)
    end = start + 1
    while not vim.current.buffer[end][0] == '"':
      end +=1
    return " ".join(vim.current.buffer[start:end]).split(":")[1].strip()
      
  strid = get_meta("StrID")
  title = get_meta("Title")
  cats = [i.strip() for i in get_meta("Cats").split(",")]
  if enable_tags:
    tags = get_meta("Tags")
  
  text_start = 0
  while not vim.current.buffer[text_start] == "\"========== Content ==========":
    text_start +=1
  text_start +=1
  text = '\n'.join(vim.current.buffer[text_start:])

  content = text

  if enable_tags:
    post = {
      'title': title,
      'description': content,
      'categories': cats,
      'mt_keywords': tags
    }
  else:
    post = {
      'title': title,
      'description': content,
      'categories': cats,
    }

  if strid == '':
    strid = handler.newPost('', blog_username,
      blog_password, post, 1)

    vim.current.buffer[get_line("StrID")] = "\"StrID : "+strid
  else:
    handler.editPost(strid, blog_username,
      blog_password, post, 1)

  vim.command('set nomodified')


def blog_new_post():
  def blog_get_cats():
    l = handler.getCategories('', blog_username, blog_password)
    s = ""
    for i in l:
      s = s + (i["description"].encode("utf-8"))+", "
    if s != "": 
      return s[:-2]
    else:
      return s
  del vim.current.buffer[:]
  blog_edit_on()
  vim.command("set syntax=blogsyntax")
  vim.current.buffer[0] =   "\"=========== Meta ============\n"
  vim.current.buffer.append("\"StrID : ")
  vim.current.buffer.append("\"Title : ")
  vim.current.buffer.append("\"Cats  : "+blog_get_cats())
  if enable_tags:
    vim.current.buffer.append("\"Tags  : ")
  vim.current.buffer.append("\"========== Content ==========\n")
  vim.current.buffer.append("\n")
  vim.current.window.cursor = (len(vim.current.buffer), 0)
  vim.command('set nomodified')
  vim.command('set textwidth=0')

def blog_open_post(id):
  try:
    post = handler.getPost(id, blog_username, blog_password)
    blog_edit_on()
    vim.command("set syntax=blogsyntax")
    del vim.current.buffer[:]
    vim.current.buffer[0] =   "\"=========== Meta ============\n"
    vim.current.buffer.append("\"StrID : "+str(id))
    vim.current.buffer.append("\"Title : "+(post["title"]).encode("utf-8"))
    vim.current.buffer.append("\"Cats  : "+",".join(post["categories"]).encode("utf-8"))
    if enable_tags:
      vim.current.buffer.append("\"Tags  : "+(post["mt_keywords"]).encode("utf-8"))
    vim.current.buffer.append("\"========== Content ==========\n")
    content = (post["description"]).encode("utf-8")
    for line in content.split('\n'):
      vim.current.buffer.append(line)
    text_start = 0
    while not vim.current.buffer[text_start] == "\"========== Content ==========":
      text_start +=1
    text_start +=1
    vim.current.window.cursor = (text_start+1, 0)
    vim.command('set nomodified')
    vim.command('set textwidth=0')
  except:
    sys.stderr.write("An error has occured")

def blog_list_edit():
  try:
    row,col = vim.current.window.cursor
    id = vim.current.buffer[row-1].split()[0]
    blog_open_post(int(id))
  except:
    pass

def blog_list_posts():
  try:
    lessthan = handler.getRecentPosts('',blog_username, blog_password,1)[0]["postid"]
    size = len(lessthan)
    allposts = handler.getRecentPosts('',blog_username, blog_password,int(lessthan))
    del vim.current.buffer[:]
    vim.command("set syntax=blogsyntax")
    vim.current.buffer[0] = "\"====== List of Posts ========="
    for p in allposts:
      vim.current.buffer.append(("".zfill(size-len(p["postid"])).replace("0", " ")+p["postid"])+"\t"+(p["title"]).encode("utf-8"))
      vim.command('set nomodified')
    blog_edit_off()
    vim.current.window.cursor = (2, 0)
    vim.command('map <enter> :py blog_list_edit()<cr>')
  except:
    sys.stderr.write("An error has occured")

# add
def blog_save_posts():
    fileID = vim.current.buffer[1]
    filename = vim.current.buffer[2]
    fileID = fileID[8:]
    fileID = "".join(fileID.split())
    filename = filename[8:]
    if ( fileID == "" ):
        fileID = "LocalDraft"
    filename = fileID + "_" + filename + ".md"
    isBackupDir = os.path.exists(blog_local + "backup")
    filename = "".join(filename.split())
    ctime = time.strftime('%Y%m%d-%H%M%S',time.localtime(time.time()))
    if not isBackupDir:
        os.makedirs(blog_local + "backup")
    if (os.path.isfile(blog_local+filename)):
        shutil.move(blog_local+filename,blog_local+"backup/"+ctime+"_"+filename)
    vim.command("save " + blog_local + filename)
    vim.command("set syntax=blogsyntax")

def blog_list_local_posts():
    try:
        vim.command("Explore "+blog_local)
    except:
        sys.stderr.write("An error has occured")