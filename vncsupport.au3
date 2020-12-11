; vncdesktop.au3 Created by andy03kr
;

#include "main.au3"

#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Compression=3
#AutoIt3Wrapper_Add_Constants=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

Opt ( "TrayIconHide", 1 )

#Region ### START Koda GUI section ### Form=
$_1 = GUICreate ( "VNC support", 500, 300, 190, 120 )
GUISetFont ( 16, 400, 0, "MS Sans Serif" )
$Group = GUICtrlCreateGroup ( "Quick Support", 15, 15, 470, 270 )

GUICtrlCreateLabel ( "Remote ID :", 40, 80, 240, 30 )
$idInputID = GUICtrlCreateInput ( $sGUI_ID, 288, 80, 145, 30, BitOR ( $GUI_SS_DEFAULT_INPUT,$ES_NUMBER ))

GUICtrlCreateLabel ( "Remote Password :", 40, 130, 240, 30 )
$idInputPASS = GUICtrlCreateInput ( $sGUI_PASS, 288, 130, 145, 30, $GUI_SS_DEFAULT_INPUT )

$idButtonVNC = GUICtrlCreateButton ( "Connect", 288, 180, 145, 35 )

GUICtrlCreateLabel ( "Status :", 40, 230, 70, 30 )
$idLabelSTAT = GUICtrlCreateLabel ( $sSRV_Stat, 120, 230, 280, 30 )

GUISetState ( @SW_SHOW )
#EndRegion ### END Koda GUI section ###

While 1
   Switch GUIGetMsg()
	  Case $idButtonVNC
		 $sGUI_ID = GUICtrlRead ( $idInputID )
		 $sGUI_PASS = GUICtrlRead ( $idInputPASS )
		 $retStat = ServerStat ( $sServer, $iSSH_port )
		 Switch $retStat
			Case -5
			   GUICtrlSetData ( $idLabelSTAT, "Fail TCP connection" )
			Case -2
			   GUICtrlSetData ( $idLabelSTAT, "Not connected" )
			Case 0
			   GUICtrlSetData ( $idLabelSTAT, "Socket error" )
			Case 1
			   GUICtrlSetData ( $idLabelSTAT, "IP-address is incorrect = " & $sIPAddress )
			Case 2
			   GUICtrlSetData ( $idLabelSTAT, "Port is incorrect" )
			Case 3
			   GUICtrlSetData ( $idLabelSTAT, "Password may not be empty" )
			Case 4
			   GUICtrlSetData ( $idLabelSTAT, "ID-number is incorrect" )
			Case 5
			   $iConn = ConnectSRV ( $sServer, $iSSH_port )
			   If $iConn == 1 Then
				  GUICtrlSetData ( $idLabelSTAT, "vncviewer.exe NOT started" )
			   ElseIf $iConn == 2 Then
				  GUICtrlSetData ( $idLabelSTAT, "plink.exe NOT started" )
			   ElseIf $iConn == 5 Then
				  GUICtrlSetData ( $idLabelSTAT, "Connected" )
			   Else
				  GUICtrlSetData ( $idLabelSTAT, "Unknown" )
			   EndIf
			Case Else
			   GUICtrlSetData ( $idLabelSTAT, "Sockets Error = " & $retStat )
		 EndSwitch
	  Case $GUI_EVENT_CLOSE
		 KillTools ()
		 Exit
   EndSwitch
WEnd
