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

HttpQueryInfo(URL, QueryInfoFlag=21, Proxy="", ProxyBypass="") {
hModule := DllCall("LoadLibrary", "str", "wininet.dll")
If (Proxy != "")
AccessType=3
Else
AccessType=1
io_hInternet := DllCall("wininet\InternetOpenA"
, "str", "" ;lpszAgent
, "uint", AccessType
, "str", Proxy
, "str", ProxyBypass
, "uint", 0) ;dwFlags
If (ErrorLevel != 0 or io_hInternet = 0) {
DllCall("FreeLibrary", "uint", hModule)
return, -1
}
iou_hInternet := DllCall("wininet\InternetOpenUrlA"
, "uint", io_hInternet
, "str", url
, "str", "" ;lpszHeaders
, "uint", 0 ;dwHeadersLength
, "uint", 0x80000000 ;dwFlags: INTERNET_FLAG_RELOAD = 0x80000000 // retrieve the original item
, "uint", 0) ;dwContext
If (ErrorLevel != 0 or iou_hInternet = 0) {
DllCall("FreeLibrary", "uint", hModule)
return, -1
}
VarSetCapacity(buffer, 1024, 0)
VarSetCapacity(buffer_len, 4, 0)
Loop, 5
{
  hqi := DllCall("wininet\HttpQueryInfoA"
  , "uint", iou_hInternet
  , "uint", QueryInfoFlag ;dwInfoLevel
  , "uint", &buffer
  , "uint", &buffer_len
  , "uint", 0) ;lpdwIndex
  If (hqi = 1) {
    hqi=success
    break
  }
}
IfNotEqual, hqi, success, SetEnv, res, timeout
If (hqi = "success") {
p := &buffer
Loop
{
  l := DllCall("lstrlen", "UInt", p)
  VarSetCapacity(tmp_var, l+1, 0)
  DllCall("lstrcpy", "Str", tmp_var, "UInt", p)
  p += l + 1
  res := res  . "`n" . tmp_var
  If (*p = 0)
  Break
}
StringTrimLeft, res, res, 1
}
DllCall("wininet\InternetCloseHandle",  "uint", iou_hInternet)
DllCall("wininet\InternetCloseHandle",  "uint", io_hInternet)
DllCall("FreeLibrary", "uint", hModule)
return, res
}