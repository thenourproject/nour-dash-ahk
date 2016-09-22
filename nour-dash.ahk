#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Off
PingResults:="PingResults.txt"
PingYas:="bytes=32"
debug = yes
EarlyExit = 0

WelcomeVar =
(
Daemon is now running in Standalone mode
View Readme.md to understand how to run from console

192.168.2.105
)

OnExit, ExitSub

Main:
{
FileDelete,%PingResults%
if debug = yes
	goto presetstart
If 0 > 0
	{
	Computername = %1%
	Comment = %3%
	ptorun = %2%
	Goto StartDaemon
	}
else
	{
	comp_ip = %A_IPAddress1%
	StringGetPos, comp_temp, comp_ip, . , R1
	stringlen, add_length, A_IPAddress1
	comp_temp := comp_temp + 1
	cut_char := add_length - comp_temp
	StringTrimRight, comp_ip, comp_ip, cut_char
InputBox, Computername , Button Daemon Standalone Mode,%WelcomeVar%,,,,,,,,%comp_ip%
	if ErrorLevel
		{
		EarlyExit = 1
		exitapp
		}
	FileSelectfile, ptorun
	InputBox, Comment , Enter Comment of Button, Comment for Button Goes here
	if ErrorLevel
		{
		EarlyExit = 1
		exitapp
		}
	Goto StartDaemon
	}
}
Return

presetstart:
	Computername = 192.168.2.105
	;ptorun = msgbox.ahk
	PingResults:="PingResults" . Computername . ".txt"
	Comment = "debug comment"

	WinHTTP := ComObjCreate("WinHTTP.WinHttpRequest.5.1")
	;~ WinHTTP.SetProxy(0)
	WinHTTP.Open("POST", "https://maker.ifttt.com/trigger/nour-button_pressed/with/key/cYwSzBWAgp-JGkrllx_RAn", 0)
	WinHTTP.SetRequestHeader("Content-Type", "application/json")
	Body := "{}"
	WinHTTP.Send(Body)
	Result := WinHTTP.ResponseText
	Status := WinHTTP.Status
	;msgbox % "status: " status "`n`nresult: " result


Goto StartDaemon

StartDaemon:
	PingResults:="PingResults" . Computername . ".txt"
	menu, tray, tip,%A_ScriptName% `nFor button at:           %Computername%`nRunning program:   %ptorun%`nComment:                %Comment%
Checkcomp:
	gosub CheckCompison
	;run %ptorun%

	WinHTTP := ComObjCreate("WinHTTP.WinHttpRequest.5.1")
	;~ WinHTTP.SetProxy(0)
	WinHTTP.Open("POST", "https://maker.ifttt.com/trigger/nour-button_pressed/with/key/cYwSzBWAgp-JGkrllx_RAn", 0)
	WinHTTP.SetRequestHeader("Content-Type", "application/json")
	Body := "{}"
	WinHTTP.Send(Body)
	Result := WinHTTP.ResponseText
	Status := WinHTTP.Status
	;msgbox % "status: " status "`n`nresult: " result



	ToolTip, Button at %Computername%`nhas been pushed.
	SetTimer, RemoveToolTip, 2000
	gosub CheckCompisbackoff
goto Checkcomp


CheckCompison:
Loop
{
;PingCmd:="tping -d 10 " . ComputerName . " >" . PingResults
PingCmd:="ping -w 1 -n 3 " . ComputerName . " >" . PingResults
;msgbox %PingCmd%
RunWait %comspec% /c """%PingCmd%""",,Hide
Loop
	{
	PingError:=false
	FileReadLine,PingLine,%PingResults%,%A_Index%
	If (ErrorLevel=1 )
	Break
	IfInString,PingLine,%PingYas%
		{
		PingError:=true
		break
		}
	}
;runwait %PingResults%
;FileDelete,%PingResults%
If PingError = 1
	{
	break
	}
}
return

CheckCompisbackoff:
	Loop
	{
	sleep 1000
	PingCmd:="ping " . ComputerName . " -n 1 >" . PingResults
	RunWait %comspec% /c """%PingCmd%""",,Hide
	Loop
		{
		PingError:=false
		FileReadLine,PingLine,%PingResults%,%A_Index%
		If (ErrorLevel=1 )
		Break
		IfInString,PingLine,%PingYas%
			{
			PingError:=true
			break
			}
		}
	;msgbox, broke out of loop
	;FileDelete,%PingResults%
	If PingError = 0
		{
		;msgbox, button disappeared!
		ToolTip, Button at %Computername%`nhas disappeared.
		SetTimer, RemoveToolTip, 2000
		break
		}
	}
Return

RemoveToolTip:
SetTimer, RemoveToolTip, Off
ToolTip
return

ExitSub:
if EarlyExit = 1
	{
	FileDelete, %PingResults%
	ExitApp
	}
if A_ExitReason not in Logoff,Shutdown  ; Avoid spaces around the comma in this line.
{
    MsgBox, 4, , Are you sure you want to close the daemon monitoring button at `n%ComputerName%?`n`nSet to run program at:`n%ptorun%`n`nComment: %Comment%
    IfMsgBox, No
        return
}
sleep 3000
FileDelete, %PingResults%
;if ErrorLevel   ; i.e. it's not blank or zero.
;    MsgBox, ummm... error says %ErrorLevel%
ExitApp
