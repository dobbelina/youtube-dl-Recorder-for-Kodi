;@Ahk2Exe-SetCopyright    Dobbelina
;@Ahk2Exe-SetDescription  youtube-dl Recorder for Kodi
;@Ahk2Exe-SetFileVersion   1.0.0.0
;@Ahk2Exe-SetProductName   YT-DL_Recorder.exe
;@Ahk2Exe-SetProductVersion   1.0.0.0

#NoEnv
#SingleInstance force
#Persistent
SetWorkingDir %A_ScriptDir%
#Include functions.ahk
IniName = youtube-dl.ini
FilePath = %A_ScriptDir%\config.txt
xval:=A_ScreenWidth * 0.75
yval:=A_ScreenHeight * 0.02
Body := "{""jsonrpc"": ""2.0"", ""method"": ""Player.GetItem"", ""params"": { ""properties"": [""file"", ""thumbnail""], ""playerid"": 1 }, ""id"": ""VideoGetItem""}"

FileRead, Console, %FilePath%
If InStr(Console, "--console-title")
Console := "Yes"

if !FileExist(IniName)
{
Gui, Font, s10
Gui, Add, Text, x6 y5 w360 h30 +Center, Please Input Details
Gui, Add, Checkbox, x106 y95 w210 h30  vYTD Checked, Download Latest youtube-dl.exe
Gui, Add, Text, x106 y130 w260 h30 , Kodi IP
Gui, Add, Edit, x175 y128 w140 h21 limit15 vIPAddress, 192.168.0.68
Gui, Add, Text, x106 y155 w260 h30 , Port
Gui, Add, Edit, x175 y153 w140 h21 limit5 vPort, 8080
Gui, Add, Text, x106 y180 w260 h30 , Username
Gui, Add, Edit, x175 y178 w140 h21 limit15 vUsername, kodi
Gui, Add, Text, x106 y205 w260 h30 , Password
Gui, Add, Edit, x175 y203 w140 h21 limit15 vPassw Password
Gui, Add, Text, x106 y232 w260 h30 , Download = Ctrl +
Gui, Add, Edit, x215 y229 w100 h21 limit15 vShortcut, p
Gui, Add, Text, x146 y285 w260 h30 , (F4 To Exit)
Gui, Add, Checkbox, x106 y255 w260 h30  vYesNoBox Checked, Download Thumbnails
Gui, Font,

Gui, Font, bold
Gui, Add, Button, x106 y25 w160 h30 gbutton1 ,Choose Download Location
Gui, Add, Button, x106 y60 w160 h30 gbutton2 ,youtube-dl.exe Location
Gui, Add, Button, x66 y307 w240 h45 ,Go
Gui, Show, x375 y245 h367 w377, Enter Details
Return

Button1:
FileSelectFolder, OutputVar, , 3, Choose Download Folder
if (OutputVar = "")
{
MsgBox, 48, Attention!, You didn't select a folder.
return
}
return

Button2:
FileSelectFile, SelectedFile, 3, , Select youtube-dl.exe, youtube-dl (*.exe)
if (SelectedFile = "")
{
MsgBox, 48, Attention!, The user didn't select anything.
return
}
SplitPath, SelectedFile, exename
if (exename != "youtube-dl.exe")
{
MsgBox, 48, Attention!, Wrong file!
return
}
IniWrite, %SelectedFile%, %IniName%, Init, youtube
return

ButtonGo:
Gui, Submit, NoHide
Gui, +OwnDialogs
If ( OutputVar ="")
{
	MsgBox, 48, Error, Download path Location  Empty!
	return
}
If (IPAddress = "")
{
	MsgBox, 48, Error, IPAddress Is Empty!
	return
}
If (Port = "")
{
	MsgBox, 48, Error, Port Is Empty!
	return
}
If (Username = "")
{
	MsgBox, 48, Error, Username Is Empty!
	return
}
If (Shortcut = "")
{
	MsgBox, 48, Error, Shortcut Is Empty!
	return
}
GuiControlGet, Checked,,YesNoBox
if (checked == 0)
IniWrite, No, %IniName%, Init, Miniature
else
IniWrite, Yes, %IniName%, Init, Miniature
IniWrite, %OutputVar%, %IniName%, Init, outputfolder
IniWrite, https://yt-dl.org/latest/youtube-dl.exe, %IniName%, UpdateUrl, YTupdate
IniWrite, %IPAddress%, %IniName%, Init, IPAddress
IniWrite, %Port%, %IniName%, Init, Port
IniWrite, %Shortcut%, %IniName%, Init, Shortcut
Key := b64Encode(Username . ":" . Passw)
IniWrite, %Key%, %IniName%, Init, Key
FileCreateShortcut, %A_ScriptDir%\YT-DL_Recorder.exe, %A_Desktop%\YT-DL_Recorder.lnk, "%A_ScriptDir%", "%A_ScriptFullPath%", YT-DL_Recorder, %A_ScriptDir%\YT-DL_Recorder.exe, , "1"
IniRead, youtube, youtube-dl.ini, Init, youtube
IniRead, YTupdate, youtube-dl.ini, UpdateUrl, YTupdate
GuiControlGet, Checked,,YTD
if (checked == 1)
{
	FileSelectFolder, YtDest, , 3, youtube-dl.exe Destination Folder
if (YtDest = "")
{
MsgBox, 48, Attention!, You didn't select a folder.
return
}
save = %YtDest%\youtube-dl.exe
SetTimer, uProgress2, 150
UrlDownloadToFile, %YTupdate%, %save%
SetTimer, uProgress2, off
Progress, Off
IniWrite, %save%, %IniName%, Init, youtube
IniRead, youtube, youtube-dl.ini, Init, youtube
Sleep, 200
}
SplitPath, youtube, exename
if (exename != "youtube-dl.exe")
{
MsgBox, 48, Attention!, youtube-dl.exe location Empty!
return
}
FileInstall, YT-Instructions.txt, YT-Instructions.txt
FileInstall, config.txt, %FilePath%
Run, YT-Instructions.txt
Reload
}
IniRead, Shortcut, youtube-dl.ini, Init, Shortcut
Progress,B2 fs18 c0 zh0  w320 h30 CW4e8af2 CTFFFFFF cbBlack,Starting youtube-dl Recorder,, YT-DL_Recorder-Notification
Fader()
Hotkey,^%Shortcut%,Dobbelina
Return

Dobbelina:
IniRead, outputfolder, youtube-dl.ini, Init, outputfolder
IniRead, youtube, youtube-dl.ini, Init, youtube
IniRead, IPAddress, youtube-dl.ini, Init, IPAddress
IniRead, Port, youtube-dl.ini, Init, Port
IniRead, Key, youtube-dl.ini, Init, Key
IniRead, Miniature, youtube-dl.ini, Init, Miniature

OnError("LogError")

LogError(exception) {
return true
}

WinHttp := ComObjCreate("WinHttp.WinHttpRequest.5.1")
WinHttp.Open("POST", "http://" . IPAddress . ":" . Port . "/jsonrpc", False)
WinHttp.SetRequestHeader("Content-Type", "application/json")
WinHttp.SetRequestHeader("Authorization", "Basic " Key)
try {WinHttp.Send(Body)
}
catch e
{
Progress,B2 fs18 c0 zh0  w290 h30 CWcf9797 cbBlack,No Connection To Server,, YT-DL_Recorder-Notification
Fader()
}
arr := WinHttp.responseBody
pData := NumGet(ComObjValue(arr) + 8 + A_PtrSize)
length := arr.MaxIndex() + 1
text := StrGet(pData, length, "utf-8")
Incoming := UrlDecode(text)

; File Name
Tags := RegExReplace(Incoming, "(?i)\[COL.*\OR]"  , Replacement := "")
RegExMatch(Tags, "(?<=label"":"")(.+?)(?="",""|$)", FileName0)
FileName := RegExReplace(FileName0, "[\\\/:*?""<>|]+"  , Replacement := " ")

;Thumbnail
RegExMatch(Incoming, "(?<=image:\/\/)(.*?)(?=\/"",""|[|]|$)", Thumbnail)
FindDot := SubStr(Thumbnail, -3,1)
if (Thumbnail != "" and Thumbnail != "N/A" and FindDot != ".")
Thumbnail := Thumbnail . ".jpg"
SplitPath, Thumbnail, , , ext
Sleep, 200

if (Miniature = "Yes")
{
if (ext = "tbn")
{
FileCopy, %Thumbnail%, %outputfolder%\%FileName%.jpg , 1
Goto, MoveOn
}
try {download_to_file(Thumbnail, outputfolder . "\" . FileName . "." . ext )
}
catch e
{
Progress,B2 fs18 c0 zh0  w270 h30 CWcf9797 cbBlack,No Thumbnail Avaliable,, YT-DL_Recorder-Notification
Fader()
Goto, MoveOn
}
If !FileExist(outputfolder . "\" . FileName . "." . ext)
{
Progress,B2 fs18 c0 zh0  w270 h30 CWcf9797 cbBlack,No Thumbnail Avaliable,, YT-DL_Recorder-Notification
Fader()
}
}
;Link
MoveOn:
Link0 := RegExReplace(Incoming, "&mode|Referer=htt|ge://ht|ge=ht"  , Replacement := " ")
RegExMatch(Link0, "(http.|rtmp)(.+?)(?=""|[|]|\s|$)", Link)
RegExMatch(Incoming, "(?<=youtube\/play\/\?video_id=)(.+?)(?="",""|$)", Link2)
if (Link2)
Link := Link2

if (Link = "")
{
Progress,B2 fs18 c0 zh0  w200 h30 CWcf9797 cbBlack,No Link Avaliable,, YT-DL_Recorder-Notification
Fader()
return
}
Link:= Chr(34) . Link . Chr(34)
RegExMatch(Incoming, "(?i)(?<=user-agent=)(.*?)(?=&|""|$)", Uagent0)
if (Uagent0)
Uagent:= "--user-agent " . Chr(34) . Uagent0 . Chr(34)

RegExMatch(Incoming, "(?i)(?<=Referer=)(.*?)(?=&|""|$)", Referer0)
if (Referer0)
Referer:= "--referer " . Chr(34) . Referer0 . Chr(34)

RegExMatch(Incoming, "(?i)(?<=Cookie=)(.*?)(?=&|""|$)", Cookie0)
if (Cookie0)
Cookie:= "--add-header " . Chr(34) . "Cookie:" . Cookie0 . Chr(34)

PathFile := Chr(34) . outputfolder . "\" . FileName . ".mp4" . Chr(34)
Recorder := Chr(34) . youtube . Chr(34)
Clipboard := Link

if (Console != "Yes")
Run, %Recorder% %Link% --config-location %FilePath% -o %PathFile% %Uagent% %Referer% %Cookie%
else
{
SetTimer, uProgress3, 150
Progress,  M c0 zh0 x%xval% y%yval% , Text text, Downloading..., youtube-dl
RunWait, %Recorder% %Link% --config-location %FilePath% -o %PathFile% %Uagent% %Referer% %Cookie%, , Min
SetTimer, uProgress3, off
Progress, off
}
return

GuiClose:
FileDelete, %IniName%
ExitApp

^F1::
WebObj := ComObjCreate("WinHttp.WinHttpRequest.5.1")
WebObj.Open("GET", "https://github.com/ytdl-org/youtube-dl/releases")
try {WebObj.Send()
}
catch e
{
}
HtmlText := WebObj.ResponseText
RegExMatch(HtmlText, "(?i)(?<=youtube-dl\/tree\/)\d{4}.\d{2}.\d{2}", LateVer)
LateVer := StrReplace(LateVer, ".0" , ".")
IniRead, YTupdate, youtube-dl.ini, UpdateUrl, YTupdate
IniRead, youtube, youtube-dl.ini, Init, youtube
FileGetVersion, Version, %youtube%
Length := StrLen(Version) -2
Version2 := SubStr(Version, 1, Length)
if (LateVer = Version2)
{
Progress,B2 fs18 c0 zh0  w440 h30 CW90cf8c cbBlack,You Have Latest Version: %Version%
Sleep, 3000
Progress, off
return
}
Progress,B2 fs18 c0 zh0  w310 h30 CW90cf8c cbBlack,Old Version: %Version%
Sleep, 3000
Progress, off
SetTimer, uProgress, 150
UrlDownloadToFile, %YTupdate%, %youtube%
SetTimer, uProgress, off
Progress, Off
FileGetVersion, Version, %youtube%
Progress,B2 fs18 c0 zh0  w310 h30 CW90cf8c cbBlack,New Version: %Version%
Sleep, 3000
Progress, off
return

uProgress:
Counter(youtube)
return

uProgress2:
Counter(save)
return

uProgress3:
WinGetTitle, OutputVar , ahk_exe youtube-dl.exe
Hi := SubStr(OutputVar, 13)
Progress , ,   %Hi%
return

F4::
SetTimer, uProgress3, off
Progress, Off
Progress,B2 fs18 c0 zh0  w320 h30 CWcf9797 cbBlack,Closing youtube-dl Recorder,, YT-DL_Recorder-Notification
Fader()
ExitApp
