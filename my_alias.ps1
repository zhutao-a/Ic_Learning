# 目录跳转
function .. { cd .. }
function ... { cd ..\.. }

# Git 快捷命令
function gs { git status }
function gl { git pull }
function gh { git push }

# 清屏并列出文件
# if (Test-Path Alias:ls) { Remove-Item Alias:ls }
# 样式一：竖排显示（纯名字，一行一个）
# function ls { Get-ChildItem -Name }
# 样式二：多列排版显示（类似 Linux 的 ls，比较省屏幕空间）
# function ls { Get-ChildItem | Format-Wide }

function cl { clear; ls }