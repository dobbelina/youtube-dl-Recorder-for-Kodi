;@Ahk2Exe-SetCopyright    Dobbelina
;@Ahk2Exe-SetDescription  youtube-dl Recorder for Kodi
;@Ahk2Exe-SetFileVersion   1.0.0.0
;@Ahk2Exe-SetProductName   YT-DL_Recorder.exe
;@Ahk2Exe-SetProductVersion   1.0.0.0

#NoEnv
#SingleInstance force
SetWorkingDir %A_ScriptDir%
#Include functions.ahk
IniName = youtube-dl.ini

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
totalFileSize := HttpQueryInfo(url, 5)
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
FileCreateDir, %A_AppData%\youtube-dl
FileInstall, config.txt, %A_AppData%\youtube-dl\config.txt
Reload
}
IniRead, Shortcut, youtube-dl.ini, Init, Shortcut
Progress,B2 fs18 c0 zh0  w320 h30 CW4e8af2 CTFFFFFF cbBlack,Starting youtube-dl Recorder
Sleep, 1500
Progress, off
Hotkey,^%Shortcut%,Dobbelina
Return

Dobbelina:
IniRead, outputfolder, youtube-dl.ini, Init, outputfolder
IniRead, youtube, youtube-dl.ini, Init, youtube
IniRead, IPAddress, youtube-dl.ini, Init, IPAddress
IniRead, Port, youtube-dl.ini, Init, Port
IniRead, Key, youtube-dl.ini, Init, Key
IniRead, Miniature, youtube-dl.ini, Init, Miniature

json_send := "{""jsonrpc"": ""2.0"", ""method"": ""Player.GetItem"", ""params"": { ""properties"": [""file"", ""thumbnail""], ""playerid"": 1 }, ""id"": ""VideoGetItem""}"

OnError("LogError")
cause := error

LogError(exception) {
return true
}

WinHttp := ComObjCreate("WinHttp.WinHttpRequest.5.1")
WinHttp.Open("POST", "http://" . IPAddress . ":" . Port . "/jsonrpc", False)
WinHttp.SetRequestHeader("Content-Type", "application/json")
WinHttp.SetRequestHeader("Authorization", "Basic " Key)
Body := json_send
try {WinHttp.Send(Body)
}
catch e
{
Progress,B2 fs18 c0 zh0  w290 h30 CWcf9797 cbBlack,No Connection To Server
Sleep, 1500
Progress, off
}
arr := WinHttp.responseBody
pData := NumGet(ComObjValue(arr) + 8 + A_PtrSize)
length := arr.MaxIndex() + 1
text := StrGet(pData, length, "utf-8")
Incoming := UrlDecode(text)

; File Name
Tags := RegExReplace(Incoming, "(?i)\[COL.*\OR]"  , Replacement := "")
RegExMatch(Tags, "(?<=label"":"")(.+?)(?=""| ""|$)", FileName0)
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
if (ext = "")
{
Progress,B2 fs18 c0 zh0  w270 h30 CWcf9797 cbBlack,No Thumbnail Avaliable
Sleep, 1500
Progress, off
}
if (ext = "tbn")
{
FileCopy, %Thumbnail%, %outputfolder%\%FileName%.jpg , 1
ext =
}
else if (ext != "")
download_to_file(Thumbnail, outputfolder . "\" . FileName . "." . ext )
}
;Link

Link0 := RegExReplace(Incoming, "&mode|Referer=htt|ge://ht|ge=ht"  , Replacement := " ")
RegExMatch(Link0, "(http.|rtmp)(.+?)(?=""|[|]|\s|$)", Link)
RegExMatch(Incoming, "(?<=youtube\/play\/\?video_id=)(.+?)(?="",""|$)", Link2)
if (Link2)
Link := Link2

if (Link = "")
{
FileDelete, %outputfolder%\%FileName%.%ext%
Progress,B2 fs18 c0 zh0  w200 h30 CWcf9797 cbBlack,No Link Avaliable
Sleep, 1500
Progress, off
return
}
Link:= chr(34) . Link . chr(34)
RegExMatch(Incoming, "(?i)(?<=user-agent=)(.*?)(?=&|""|$)", Uagent0)
if (Uagent0)
Uagent:= "--user-agent " . chr(34) . Uagent0 . chr(34)

RegExMatch(Incoming, "(?i)(?<=Referer=)(.*?)(?=&|""|$)", Referer0)
if (Referer0)
Referer:= "--referer " . chr(34) . Referer0 . chr(34)
PathFile := chr(34) . outputfolder . "\" . FileName . ".%(ext)s" . chr(34)
Recorder := chr(34) . youtube . chr(34)
Clipboard := Link
Run, %Recorder% %Link% -o %PathFile% %Uagent% %Referer%

return

GuiClose:
FileDelete, %IniName%
ExitApp

^F1::
IniRead, YTupdate, youtube-dl.ini, UpdateUrl, YTupdate
IniRead, youtube, youtube-dl.ini, Init, youtube
FileGetVersion, Version, %youtube%
Progress,B2 fs18 c0 zh0  w310 h30 CW90cf8c cbBlack,Old Version: %Version%
Sleep, 3000
Progress, off
SetTimer, uProgress, 150
totalFileSize := HttpQueryInfo(url, 5)
UrlDownloadToFile, %YTupdate%, %youtube%
SetTimer, uProgress, off
Progress, Off
FileGetVersion, Version, %youtube%
Progress,B2 fs18 c0 zh0  w310 h30 CW90cf8c cbBlack,New Version: %Version%
Sleep, 3000
Progress, off
return

uProgress:
   FileGetSize, fs, %youtube% ,K
   a := Floor(fs/totalFileSize * 100*1024)
   b := Floor(fs/totalFileSize * 10000*1024)/100
   SetFormat, float, 0.2
   b += 0
Progress,%a% ,      downloaded: %fs% Kb. ,,Download
return

uProgress2:
   FileGetSize, fs, %save% ,K
   a := Floor(fs/totalFileSize * 100*1024)
   b := Floor(fs/totalFileSize * 10000*1024)/100
   SetFormat, float, 0.2
   b += 0
Progress,%a% ,      downloaded: %fs% Kb. ,,Download
return

F4::
Progress,B2 fs18 c0 zh0  w320 h30 CWcf9797 cbBlack,Closing youtube-dl Recorder
Sleep, 1500
Progress, off
ExitApp



