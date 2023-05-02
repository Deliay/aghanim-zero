# 阿哈利姆2 Zero
基于原版阿哈利姆天地迷宫衍生的开源地图。

## 本地如何运行？
1. 环境准备
```powershell
pwd # 记住你的当前目录
git clone git@jihulab.com:aghanim-zero/aghanim-zero.git
cd # cd到你的dota2自定义游戏目录
# 创建符号链接
New-Item -Type SymbolicLink -Target 当前目录/aghanim-zero -Name aghanim_zero
```
2. 运行 Dota2 Tools

## 如何协作？
1. fork本仓库到你自己的账号下
1. 本地运行、调试
1. 本地调试通过之后，提交pr
1. 自动通过CI/CD发布（还没做，目前手动发布）

## 你想用这个图...
1. 衍生自己的版本：
> 完全没问题

2. 使用其中一些元素在自己的地图上：
> 完全没问题

3. 一起完善出更好的版本：
> 完全没问题

## 特别鸣谢
阿哈利姆2 EXT作者CyFio
