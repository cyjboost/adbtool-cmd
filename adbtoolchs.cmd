@echo off
cls
title adbtool
::ɾ��ʣ����ʱ�ļ�
mode con: cols=70 lines=36
echo Made by Bailey Chase ^& Timmy Cheng.
echo �˽ű�������Windows Powershell
echo ����Powershell����ʹ��
echo fastbootģʽ��֧��һ̨�豸
echo Ӧ��Ҳ������ͬʱˢ��̨���ϵĻ��İɣ���С����
ping 127.0.0.1 -n 2 > nul
cls
echo ɾ����ʱ�ļ������б���������������
PowerShell -Command "rm 1.txt"
PowerShell -Command "rm 2.txt"
PowerShell -Command "rm seldev.txt"
cls
goto first

:first
cls
echo ��������adb�豸��������yes����Ҫ���ո񣩽���������
echo ��û��������skip����Ҫ���ո�
echo �������Fastbootģʽ������fastboot����֧�ֵ��豸��
set /p wadba=
if "%wadba%"=="skip" (goto select)
if "%wadba%"=="yes" (goto cmdconnectting)
if "%wadba%"=="fastboot" (goto fastbootmode)
goto first

:cmdconnectting
cls
echo �����Ӻú�����exit�ص��ű�
cd bin
cmd
cd ..
goto first


:select
cls
::����豸������ʱ�ļ�
.\bin\adb devices | findstr /E /P "device" > 1.txt

::�������
type 1.txt | find /n "device" > 2.txt

::�����滻device����Ϊ�ո�
setlocal EnableDelayedExpansion 
set "strOld=device"
set "strNew= "
for /f %%i in ('dir /b /s /a:-d *.txt') do (
  powershell -Command "(gc %%i) -replace '%strOld%', '%strNew%' | Out-File %%i"
)
cls


echo ѡ���豸
type 2.txt 
echo.
echo.
echo ������û�����⣬��ʱ�Ϸ�Ӧ���Ѿ������豸���ֻ��ַ
echo ��û�м�⵽�豸
echo �����²���usb�豸��ص����ӽ��棬������skip
echo ����������ص����ӽ����������ȷ��ip�Լ��˿ں�
echo ������adbĬ��5555��
echo.
echo ����0���»ص����ӽ���
set /p devnum= �������ѡ���豸��Enter��������
if %devnum%==0 (goto first)
type 2.txt | findstr /c:[%devnum%] > seldev.txt

::����豸����Ƿ����
if %errorlevel% == 1 (echo �������������ѡ�� && goto select)


::����Ϊ�滻 [����] Ϊ�ո�
set "strOld=\[%devnum%]"
set "strNew="
for /f %%i in ('dir /b /s /a:-d seldev.txt') do (
  powershell -Command "(gc %%i) -replace '%strOld%', '%strNew%' | Out-File %%i"
)

::��ȡ��ѡ���豸��
for /f %%i in ('type seldev.txt') do (
set devaddr=%%i
)
goto main


::main�����ܽ���
::�����������cmd������������һ��tab�������ţ��ı��༭�����ܿ���������
:main
	cls
	ping 127.1 -n 2 > nul
	echo ������������ִ�в�����
    echo 1.	����
    echo 2.	��Դѡ��
    echo 3.	��װӦ��
    echo 4.	ж��Ӧ��
    echo 5.	ж��ϵͳӦ��
    echo 6.	scrcpy�����ֻ�
    echo 7.	�����ļ���/sdcard
    echo 8.	��������
	echo 9.	����Ӧ�ð���
	echo 10.	�Ͽ��������Ӳ��رոýű�
	echo c.	����豸��Ϣ
	echo e.	���˳��ű�
	echo f.	�ű��л���Fastbootģʽ������������FB��
	echo r.	�ص����ӽ��棨Ĭ�ϻ�������������ӵ������豸��
    echo ����������������������������������������������������������������������������������������������������
    set /p num=���������:
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
echo �����˳�
ping 127.1 -n 2 > nul
taskkill -fi "windowtitle eq adbtool" -im cmd.exe



:fullexit
cls
echo �����˳�
ping 127.1 -n 2 > nul
adb disconnect
taskkill -fi "windowtitle eq adbtool" -im cmd.exe


:cmdline
cls
cd bin
echo �ڲ�����ɺ�����exit�ص��ű�
cmd
cd ..
goto main

:cmdline_fb
cls
cd bin
echo �ڲ�����ɺ�����exit�ص��ű�
cmd
cd ..
goto fastbootmode


:uninst_sys
cls
echo ����return����
set /p uapp=������Ҫж������İ���
if %uapp%==return goto main
@echo on
adb -s %devaddr% shell pm uninstall -k --user 0 %uapp%
@echo off
echo ���س��Զ�����
echo ��ϣ������ж��Ӧ��������redo
set /p choice=�����룺
if "%choice%"=="redo" (set jump=uninst_sys && goto jumper)
goto main


:uninst
cls
echo ����֪���������ȷ��ز�ѯ
echo ����return����
set /p uapp=������Ҫж������İ���
if %uapp%==return goto main
@echo on
adb -s %devaddr% uninstall %uapp%
@echo off
echo ���س��Զ�����
echo ��ϣ������ж��Ӧ��������redo
set /p choice=�����룺
if "%choice%"=="redo" (set jump=uninst && goto jumper)
goto main



:inst
cls
set /p app=�뽫apk�ϵ����ﲢ���»س�(��·�����ɺ�˫����)
@echo on
adb -s %devaddr% install "%app%">nul
@echo off
echo ���س��Զ�����
echo ��ϣ��������װӦ��������redo
set /p choice=�����룺
if "%choice%"=="redo" (set jump=inst && goto jumper)
goto main


:send
cls
echo �뽫�ļ��ϵ����ﲢ���»س�(��·�����ɺ�˫����):
set /p filepath=
@echo on
.\bin\adb -s %devaddr% push "%filepath%" /sdcard
@echo off
echo.
echo.
echo ���س��Զ�����
echo ��ϣ����������������redo
set /p choice=�����룺
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
echo Android_version��%version%
echo Resolution��%screen:~15%
powershell -command "rm 5.txt"
echo.
echo.
echo �����������
pause>nul
goto main


:searchpack
cls
set /p ages=������ؼ��ʣ�
.\bin\adb -s %devaddr% shell cmd package list packages|findstr %ages%
echo.
echo.
echo �ڸ��ƺ��Ժ󰴻س��Զ�����
echo ��ϣ����������������redo
set /p choice=�����룺
if "%choice%"=="redo" (goto searchpack)
goto main


:scrcpy
cls
echo. Ĭ������Ϊ3M
.\bin\scrcpy -s %devaddr% -b 3M
goto main


:power
cls
echo �߼�����ѡ�
echo 1.�ػ�
echo 2.����
echo 3.������fastboot
echo 4.������recovery
echo 5.������edlģʽ
echo �س�������
echo ����������������������������������������������������������������������������������������������������
set /p nu=������ִ�в�����
if "%nu%"=="1" (adb -s %devaddr% shell reboot -p>ul)
if "%nu%"=="2" (adb -s %devaddr% shell reboot>nul)
if "%nu%"=="3" (adb -s %devaddr% reboot fastboot>nul)
if "%nu%"=="4" (adb -s %devaddr% reboot recovery>nul)
if "%nu%"=="5" (adb -s %devaddr% reboot edl>nul)
goto main


:fastbootmode
    cls
    ping 127.1 -n 2 > nul
    echo Fastbootģʽ
    echo ������������ִ�в�����
	echo 0.��������
    echo 1.�豸��Ϣ
    echo 2.��Դѡ��
    echo 3.ˢдģʽ
    echo 4.���ģʽ
	echo 5.�ָ���������
	echo 6.�����ȸ���֤
	echo r.����ADBģʽ
    echo ����������������������������������������������������������������������������������������������������
    set /p num=����������:
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
    echo δ��⵽�豸
    echo �����ص����˵�
    ping 127.1 -n 4 > nul
	goto fastbootmode
)
.\bin\fastboot getvar all
echo.
pause
goto fastbootmode


:flashsel
cls
echo ˢдģʽ��
echo 0.����
echo 1.д��recovery����
echo 2.д��system����
echo 3.д��boot����
echo ����������������������������������������������������������������������������������������������������
set /p nu=������������ִ�в�����
if %nu%==0 (echo �Ѿ�ȡ��ִ��д��ģʽ)
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
    echo δ��⵽�豸
    echo �����ص����˵�
    ping 127.1 -n 4 > nul
	goto fastbootmode
)
echo �뽫.img�ϵ����ﲢ���»س�:
set /p filename=
echo ��ȷ��Ҫ��%filename%д�뵽%partition%������[yes/no]
set ck=
set /p ck=
if %ck%==yes (.\bin\fastboot flash %partition% %filename%) else (echo �Ѿ�ȡ��ִ��)
echo.
echo.
goto fastbootmode
pause

:wipesel
cls
echo ���ģʽ��
echo 0.����
echo 1.���recovery����
echo 2.���system����
echo 3.���boot����
echo 4.���userdata����
echo 5.���cache����
echo ����������������������������������������������������������������������������������������������������
set /p nu=������������ִ�в�����
if %nu%==0 (echo �Ѿ�ȡ��ִ�����ģʽ)
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
echo �޷�ʶ��Ĳ���
echo �����ص����˵�
ping 127.1 -n 4 > nul
goto fastbootmode


:wipe
cls
ping 127.1 -n 2 > nul
set device=0
for /f "delims=" %%i in ('.\bin\fastboot devices') do set device=1
if %device%==0 (
    echo δ��⵽�豸
    echo �����ص����˵�
    ping 127.1 -n 4 > nul
	goto fastbootmode
)
echo ��Ҫ���%partition%������[yes/no]
set ck=
set /p ck=
if %ck%==yes (.\bin\fastboot erase %partition%) else (echo �Ѿ�ȡ��ִ��)
ping 127.1 -n 2 > nul
echo �����ص����˵�
ping 127.1 -n 2 > nul
goto fastbootmode


:power_fb
cls
ping 127.1 -n 2 > nul
set device=0
for /f "delims=" %%i in ('.\bin\fastboot devices') do set device=1
if %device%==0 (
	ping 127.1 -n 2 > nul
    echo δ��⵽�豸
    echo �����ص����˵�
    ping 127.1 -n 4 > nul
	goto fastbootmode
)
echo ��Դѡ�
echo 0.����
echo 1.�ػ�
echo 2.������ϵͳ
echo 3.������fastboot
echo 4.������recovery
echo 5.������edlģʽ
echo ����������������������������������������������������������������������������������������������������
set /p nu=������������ִ�в�����
if %nu%==0 (echo �Ѿ�ȡ��ִ�е�Դѡ��)
if %nu%==1 (.\bin\fastboot oem poweroff)
if %nu%==2 (.\bin\fastboot reboot)
if %nu%==3 (.\bin\fastboot reboot-bootloader)
if %nu%==4 (.\bin\fastboot oem reboot-recovery)
if %nu%==5 (.\bin\fastboot oem edl)
ping 127.1 -n 2 > nul
echo �����ص����˵�
ping 127.1 -n 4 > nul
goto fastbootmode
