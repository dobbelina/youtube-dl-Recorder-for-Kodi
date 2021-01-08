UrlDecode(str) {
    Loop
 If RegExMatch(str, "i)(?<=%)[\da-f]{1,2}", hex)
    StringReplace, str, str, `%%hex%, % Chr("0x" . hex), All
    Else Break
 Return, str
}

download_to_file(u,s){
	static r:=false,request:=comobjcreate("WinHttp.WinHttpRequest.5.1")
	if(!r||request.option(1)!=u)
		request.open("GET",u)
	request.send()
	if(request.responsetext="failed"||request.status!=200||comobjtype(request.responsestream)!=0xd)
		return false
	p:=comobjquery(request.responsestream,"{0000000c-0000-0000-C000-000000000046}")
	f:=fileopen(s,"w")
	loop{
		varsetcapacity(b,8192)
		r:=dllcall(numget(numget(p+0)+3*a_ptrsize),ptr,p,ptr,&b,uint,8192, "ptr*",c)
		f.rawwrite(&b,c)
	}until (c=0)
	objrelease(p)
	f.close()
	return request.responsetext
}

Fader(){
Iterations =
 Loop, 7
{
 Iterations +=36.42
    WinSet, Transparent, %Iterations%, YT-DL_Recorder-Notification
    Sleep, 60
}
WinSet, TransColor, Off, YT-DL_Recorder-Notification
Sleep, 1215
 Loop, 7
{
 Iterations -= 36.42
    WinSet, Transparent, %Iterations%, YT-DL_Recorder-Notification
    Sleep, 30
}
Progress, off
WinSet, TransColor, Off, YT-DL_Recorder-Notification
return
}

b64Encode(string)
{
    VarSetCapacity(bin, StrPut(string, "UTF-8")) && len := StrPut(string, &bin, "UTF-8") - 1
    if !(DllCall("crypt32\CryptBinaryToString", "ptr", &bin, "uint", len, "uint", 0x1, "ptr", 0, "uint*", size))
        throw Exception("CryptBinaryToString failed", -1)
    VarSetCapacity(buf, size << 1, 0)
    if !(DllCall("crypt32\CryptBinaryToString", "ptr", &bin, "uint", len, "uint", 0x1, "ptr", &buf, "uint*", size))
        throw Exception("CryptBinaryToString failed", -1)
    return StrGet(&buf)
}

Counter(elapsed){
   FileGetSize, fs, %elapsed% ,K
   a := Floor(fs/totalFileSize * 100*1024)
   b := Floor(fs/totalFileSize * 10000*1024)/100
   SetFormat, float, 0.2
   b += 0
Progress,%a% ,      downloaded: %fs% Kb. ,,Download
return
}