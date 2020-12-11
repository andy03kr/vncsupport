; main.au3 Created by andy03kr
; plink.exe -ssh -N -R 45554:127.0.0.1:5900 -hostkey 24:b1:c4:9e:c9:b5:d6:e6:03:12:df:1f:64:dd:81:1d -C -P 10022 -i c:\vncsupport\bin\vncproxy.ppk -l vncproxy -batch vncproxy.home.lan
; copy /b 7zSD.sfx + config.txt + vncsupport.7z vncsupport.exe

#include-once
#include <AutoItConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <MsgBoxConstants.au3>

Opt ( "TrayIconHide", 1 )

$sBin         = @ScriptDir & "\bin\"
$sINI_file    = $sBin & "vncsupport.ini"

; read vncsupport.ini
If FileExists ( $sINI_file ) Then
   $sServer = IniRead ( $sINI_file, "General", "server", "" )
   $iSSH_port  = IniRead ( $sINI_file, "General", "sshport", "22022" )
   $iVNC_port  = IniRead ( $sINI_file, "General", "vncport", "15900" )
   $sSSH_user  = IniRead ( $sINI_file, "General", "sshuser", "vncproxy" )
   $sSSH_crt   = IniRead ( $sINI_file, "General", "certificate", "" )
   $sHostKey   = IniRead ( $sINI_file, "General", "hostkey", "" )
Else
   MsgBox ( $MB_OK, "Error", "File vncsupport.ini not found" )
   Exit
EndIf

If $sServer == "" Then
   MsgBox ( $MB_OK, "Error", "Server not defined in vncsupport.ini" )
   Exit
EndIf

If $sSSH_crt == "" Then
   MsgBox ( $MB_OK, "Error", "Public key file not defined in vncsupport.ini" )
   Exit
EndIf

If FileExists ( $sBin & $sSSH_crt ) Then
   $sSSH_crt = $sBin & $sSSH_crt
Else
   MsgBox ( $MB_OK, "Error", "Key file not found in " & $Bin )
EndIf

If $sHostKey == "" Then
   MsgBox ( $MB_OK, "Error", "Proxy server fingerprint not defined in vncsupport.ini" )
   Exit
EndIf

$sMode        = "app mode"
$sSRV_Stat    = "Wait"
$sPLINK_cmd   = ""
$sVNC_cmd     = ""

$iPLINK_pid   = -1
$iVNC_pid     = -1

$sGUI_ID      = ""
$sGUI_PASS    = ""
$idLabelSTAT  = ""
$idInputID    = ""
$idInputPASS  = ""

; Func ServerStat return:
; -5 fail TCP connection
; -2 not connected
; 1 IPAddr is incorrect
; 2 port is incorrect
; 5 connection established
; 10060 Connection timed out
Func ServerStat ( $sServer, $iSSH_port )
   Local $idSock = 0
   Local $sIPAddress = ""

   If $sGUI_PASS == "" Then Return 3
   If $sGUI_ID == 0 Or $sGUI_ID < 40000 Or $sGUI_ID > 50000 Then Return 4
   If $iSSH_port == "" Or $iSSH_port <= 0 Or $iSSH_port >= 65536 Then Return 2
   If TCPStartup () == 0 Then Return -5
   ; Windows Sockets Error https://docs.microsoft.com/ru-ru/windows/desktop/WinSock/windows-sockets-error-codes-2
   $sIPAddress = TCPNameToIP ( $sServer )
   If $sIPAddress == "" Then Return @error
   $idSock = TCPConnect ( $sIPAddress, $iSSH_port )
   If $idSock <= 0 Then
	  ; @error:	-2 not connected.
	  ;			1 IPAddr is incorrect.
	  ;			2 port is incorrect.
	  ; 		10060 Connection timed out.
 	  Return @error
   EndIf
   TCPCloseSocket ( $idSock )
   Return 5
EndFunc

; Func ConnectSRV return:
; 1 error while run winvnc
; 2 error while run plink
; 5 connection established
Func ConnectSRV ( $sServer, $iSSH_port )
   $sPLINK_cmd = "-ssh -N -L " & $iVNC_port & ":127.0.0.1:" & $sGUI_ID & " -hostkey " & $sHostKey & " -C -P " & $iSSH_port & " -i " & $sSSH_crt & " -l " & $sSSH_user & " -batch " & $sServer
   $sVNC_cmd = "127.0.0.1:" & $iVNC_port & " -disablesponsor -nostatus -autoscaling -shared -password " & $sGUI_PASS & " -quickoption 1 -loglevel 10 -console"

   $iPLINK_pid = Run ( $sBin & "plink.exe " & $sPLINK_cmd, "", @SW_HIDE )
   If $iPLINK_pid <= 0 Then
	  Return 2
   Else
	  $iVNC_pid = Run ( $sBin & "vncviewer.exe " & $sVNC_cmd, "", @SW_HIDE )
	  If $iVNC_pid <= 0 Then
		 Return 1
	  EndIf
   EndIf
   Return 5
EndFunc

Func KillTools ()
   If $iVNC_pid > 0 Then
	  RunWait ( @ComSpec & " /C taskkill /F /T /PID " & $iVNC_pid, "", @SW_HIDE )
   EndIf
   If $iPLINK_pid > 0 Then
	  RunWait ( @ComSpec & " /C taskkill /F /T /PID " & $iPLINK_pid, "", @SW_HIDE )
   EndIf
EndFunc
