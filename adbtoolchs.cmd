@echo off
cls
title adbtool
::删除剩余临时文件
mode con: cols=70 lines=36
echo Made by Bailey Chase ^& Timmy Cheng.
echo 此脚本依赖于Windows Powershell
echo 若无Powershell请勿使用
echo fastboot模式仅支持一台设备
echo 应该也少有人同时刷两台以上的机的吧（超小声）
ping 127.0.0.1 -n 2 > nul
cls
echo 删除临时文件，若有报错属于正常现象
PowerShell -Command "rm 1.txt"
PowerShell -Command "rm 2.txt"
PowerShell -Command "rm seldev.txt"
cls
goto first

:first
cls
echo 若有无线adb设备请先输入yes（不要带空格）进入命令行
echo 若没有请输入skip（不要带空格）
echo 若想进入Fastboot模式请输入fastboot（仅支持单设备）
set /p wadba=
if "%wadba%"=="skip" (goto select)
if "%wadba%"=="yes" (goto cmdconnectting)
if "%wadba%"=="fastboot" (goto fastbootmode)
goto first

:cmdconnectting
cls
echo 在连接好后输入exit回到脚本
cd bin
cmd
cd ..
goto first


:select
cls
::输出设备名到临时文件
.\bin\adb devices | findstr /E /P "device" > 1.txt

::增加序号
type 1.txt | find /n "device" > 2.txt

::以下替换device字样为空格
setlocal EnableDelayedExpansion 
set "strOld=device"
set "strNew= "
for /f %%i in ('dir /b /s /a:-d *.txt') do (
  powershell -Command "(gc %%i) -replace '%strOld%', '%strNew%' | Out-File %%i"
)
cls


echo 选择设备
type 2.txt 
echo.
echo.
echo 若连接没有问题，此时上方应该已经出现设备名字或地址
echo 若没有检测到设备
echo 请重新插入usb设备后回到连接界面，并输入skip
echo 无线连接请回到连接界面后输入正确的ip以及端口号
echo （无线adb默认5555）
echo.
echo 输入0重新回到连接界面
set /p devnum= 输入序号选择设备后按Enter键继续：
if %devnum%==0 (goto first)
type 2.txt | findstr /c:[%devnum%] > seldev.txt

::检测设备序号是否存在
if %errorlevel% == 1 (echo 输入错误，请重新选择 && goto select)


::以下为替换 [数字] 为空格
set "strOld=\[%devnum%]"
set "strNew="
for /f %%i in ('dir /b /s /a:-d seldev.txt') do (
  powershell -Command "(gc %%i) -replace '%strOld%', '%strNew%' | Out-File %%i"
)

::读取已选择设备名
for /f %%i in ('type seldev.txt') do (
set devaddr=%%i
)
goto main


::main主功能界面
::这里的缩进在cmd里面是正常的一个tab缩进符号，文本编辑器可能看着有问题
:main
	cls
	ping 127.1 -n 2 > nul
	echo 输入以下数字执行操作：
    echo 1.	锁屏
    echo 2.	电源选项
    echo 3.	安装应用
    echo 4.	卸载应用
    echo 5.	卸载系统应用
    echo 6.	scrcpy控制手机
    echo 7.	传输文件到/sdcard
    echo 8.	输入命令
	echo 9.	搜索应用包名
	echo 10.	断开无线连接并关闭该脚本
	echo c.	输出设备信息
	echo e.	仅退出脚本
	echo f.	脚本切换到Fastboot模式（请先重启到FB）
	echo r.	回到连接界面（默认会断连所有已连接的无线设备）
    echo ——————————————————————————————————————————————————
    set /p num=请输入序号:
    if "%num%"=="1" (.\bin\adb -s %devaddr% shell input keyevent 26)
    if "%num%"=="2" (goto power)
    if "%num%"=="3" (goto inst)
    if "%num%"=="4" (goto uninst)
    if "%num%"=="5" (goto uninst_sys)
    if "%num%"=="6" (goto scrcpy)
    if "%num%"=="7" (goto send)
    if "%num%"=="8" (goto cmdline)
	if "%num%"=="9" (goto searchpack)
	if "%num%"=="10" (goto fullexit)
	if "%num%"=="e" (goto nonfullexit)
    if "%num%"=="c" (goto devinf)
	if "%num%"=="r" (goto first)
	if "%num%"=="f" (goto fastbootmode)
	goto main


:jumper
cls
goto %jump%


:nonfullexit
cls
echo 即将退出
ping 127.1 -n 2 > nul
taskkill -fi "windowtitle eq adbtool" -im cmd.exe



:fullexit
cls
echo 即将退出
ping 127.1 -n 2 > nul
adb disconnect
taskkill -fi "windowtitle eq adbtool" -im cmd.exe


:cmdline
cls
cd bin
echo 在操作完成后输入exit回到脚本
cmd
cd ..
goto main

:cmdline_fb
cls
cd bin
echo 在操作完成后输入exit回到脚本
cmd
cd ..
goto fastbootmode


:uninst_sys
cls
echo 输入return返回
set /p uapp=请输入要卸载软件的包名
if %uapp%==return goto main
@echo on
adb -s %devaddr% shell pm uninstall -k --user 0 %uapp%
@echo off
echo 按回车自动返回
echo 若希望继续卸载应用请输入redo
set /p choice=请输入：
if "%choice%"=="redo" (set jump=uninst_sys && goto jumper)
goto main


:uninst
cls
echo 若不知道包名请先返回查询
echo 输入return返回
set /p uapp=请输入要卸载软件的包名
if %uapp%==return goto main
@echo on
adb -s %devaddr% uninstall %uapp%
@echo off
echo 按回车自动返回
echo 若希望继续卸载应用请输入redo
set /p choice=请输入：
if "%choice%"=="redo" (set jump=uninst && goto jumper)
goto main



:inst
cls
set /p app=请将apk拖到这里并按下回车(此路径不可含双引号)
@echo on
adb -s %devaddr% install "%app%">nul
@echo off
echo 按回车自动返回
echo 若希望继续安装应用请输入redo
set /p choice=请输入：
if "%choice%"=="redo" (set jump=inst && goto jumper)
goto main


:send
cls
echo 请将文件拖到这里并按下回车(此路径不可含双引号):
set /p filepath=
@echo on
.\bin\adb -s %devaddr% push "%filepath%" /sdcard
@echo off
echo.
echo.
echo 按回车自动返回
echo 若希望继续发送请输入redo
set /p choice=请输入：
if "%choice%"=="redo" (set jump=send && goto jumper)
goto main


:devinf
cls
for /f "delims=" %%i in ('adb shell "ip addr | grep inet | grep "/24" | awk '{print $2}' | cut -d "/" -f1"') do set ipv4_addr=%%i
for /f "delims=" %%i in ('adb shell "ip a | grep -B 1 wlan0|awk '$2 ~ /:/ {print $2}' | grep -v "wlan0:""') do set mac_addr=%%i
adb devices -l | findstr model > 5.txt
for /f "usebackq tokens=3,4,5 delims= " %%i in (5.txt) do (echo %%i && echo %%j && echo %%k)
echo ipv4_addr:%ipv4_addr%
echo mac_addr:%mac_addr%
for /f "delims=" %%i in ('adb shell getprop ro.build.version.release') do set version=%%i
for /f "delims=" %%i in ('adb shell wm size') do set screen=%%i
echo Android_version：%version%
echo Resolution：%screen:~15%
powershell -command "rm 5.txt"
echo.
echo.
echo 按任意键返回
pause>nul
goto main


:searchpack
cls
set /p ages=请输入关键词：
.\bin\adb -s %devaddr% shell cmd package list packages|findstr %ages%
echo.
echo.
echo 在复制好以后按回车自动返回
echo 若希望继续搜索请输入redo
set /p choice=请输入：
if "%choice%"=="redo" (goto searchpack)
goto main


:scrcpy
cls
echo. 默认码率为3M
.\bin\scrcpy -s %devaddr% -b 3M
goto main


:power
cls
echo 高级重启选项：
echo 1.关机
echo 2.重启
echo 3.重启到fastboot
echo 4.重启到recovery
echo 5.重启到edl模式
echo 回车即返回
echo ——————————————————————————————————————————————————
set /p nu=输入以执行操作：
if "%nu%"=="1" (adb -s %devaddr% shell reboot -p>ul)
if "%nu%"=="2" (adb -s %devaddr% shell reboot>nul)
if "%nu%"=="3" (adb -s %devaddr% reboot fastboot>nul)
if "%nu%"=="4" (adb -s %devaddr% reboot recovery>nul)
if "%nu%"=="5" (adb -s %devaddr% reboot edl>nul)
goto main


:fastbootmode
    cls
    ping 127.1 -n 2 > nul
    echo Fastboot模式
    echo 输入以下数字执行操作：
	echo 0.输入命令
    echo 1.设备信息
    echo 2.电源选项
    echo 3.刷写模式
    echo 4.清除模式
	echo 5.恢复出厂设置
	echo 6.跳过谷歌验证
	echo r.返回ADB模式
    echo ——————————————————————————————————————————————————
    set /p num=请输入数字:
	if "%num%"=="0" (goto cmdline_fb)
	if "%num%"=="1" (goto devinf_fb)
	if "%num%"=="2" (goto power_fb)
	if "%num%"=="3" (goto flashsel)
	if "%num%"=="4" (goto wipesel)
	if "%num%"=="5" (.\bin\fastboot -w reboot)
	if "%num%"=="6" (.\bin\fastboot erase frp)
	if "%num%"=="r" (goto first)
	goto fastbootmode
	
	
:devinf_fb
cls
ping 127.1 -n 2 > nul
set device=0
for /f "delims=" %%i in ('.\bin\fastboot devices') do set device=1
if %device%==0 (
    echo 未检测到设备
    echo 即将回到主菜单
    ping 127.1 -n 4 > nul
	goto fastbootmode
)
.\bin\fastboot getvar all
echo.
pause
goto fastbootmode


:flashsel
cls
echo 刷写模式：
echo 0.返回
echo 1.写入recovery分区
echo 2.写入system分区
echo 3.写入boot分区
echo ——————————————————————————————————————————————————
set /p nu=输入以下数字执行操作：
if %nu%==0 (echo 已经取消执行写入模式)
if %nu%==1 (
    set partition=recovery
    goto flash
)
if %nu%==2 (
    set partition=system
    goto flash
)
if %nu%==3 (
	set partition=boot
    goto flash
)


:flash
cls
ping 127.1 -n 2 > nul
set device=0
for /f "delims=" %%i in ('.\bin\fastboot devices') do set device=1
if %device%==0 (
    echo 未检测到设备
    echo 即将回到主菜单
    ping 127.1 -n 4 > nul
	goto fastbootmode
)
echo 请将.img拖到这里并按下回车:
set /p filename=
echo 你确定要把%filename%写入到%partition%分区吗？[yes/no]
set ck=
set /p ck=
if %ck%==yes (.\bin\fastboot flash %partition% %filename%) else (echo 已经取消执行)
echo.
echo.
goto fastbootmode
pause

:wipesel
cls
echo 清除模式：
echo 0.返回
echo 1.清除recovery分区
echo 2.清除system分区
echo 3.清除boot分区
echo 4.清除userdata分区
echo 5.清除cache分区
echo ——————————————————————————————————————————————————
set /p nu=输入以下数字执行操作：
if %nu%==0 (echo 已经取消执行清除模式)
if %nu%==1 (
    set partition=recovery
    goto wipe
)
if %nu%==2 (
    set partition=system
    goto wipe
)
if %nu%==3 (
    set partition=boot
    goto wipe
)
if %nu%==4 (
    set partition=userdata
    goto wipe
)
if %nu%==5 (
    set partition=cache
    goto wipe
)
echo 无法识别的操作
echo 即将回到主菜单
ping 127.1 -n 4 > nul
goto fastbootmode


:wipe
cls
ping 127.1 -n 2 > nul
set device=0
for /f "delims=" %%i in ('.\bin\fastboot devices') do set device=1
if %device%==0 (
    echo 未检测到设备
    echo 即将回到主菜单
    ping 127.1 -n 4 > nul
	goto fastbootmode
)
echo 你要清除%partition%分区吗？[yes/no]
set ck=
set /p ck=
if %ck%==yes (.\bin\fastboot erase %partition%) else (echo 已经取消执行)
ping 127.1 -n 2 > nul
echo 即将回到主菜单
ping 127.1 -n 2 > nul
goto fastbootmode


:power_fb
cls
ping 127.1 -n 2 > nul
set device=0
for /f "delims=" %%i in ('.\bin\fastboot devices') do set device=1
if %device%==0 (
	ping 127.1 -n 2 > nul
    echo 未检测到设备
    echo 即将回到主菜单
    ping 127.1 -n 4 > nul
	goto fastbootmode
)
echo 电源选项：
echo 0.返回
echo 1.关机
echo 2.重启到系统
echo 3.重启到fastboot
echo 4.重启到recovery
echo 5.重启到edl模式
echo ——————————————————————————————————————————————————
set /p nu=输入以下数字执行操作：
if %nu%==0 (echo 已经取消执行电源选项)
if %nu%==1 (.\bin\fastboot oem poweroff)
if %nu%==2 (.\bin\fastboot reboot)
if %nu%==3 (.\bin\fastboot reboot-bootloader)
if %nu%==4 (.\bin\fastboot oem reboot-recovery)
if %nu%==5 (.\bin\fastboot oem edl)
ping 127.1 -n 2 > nul
echo 即将回到主菜单
ping 127.1 -n 4 > nul
goto fastbootmode
