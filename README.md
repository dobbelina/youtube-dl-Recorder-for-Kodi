# youtube-dl-Recorder-for-Kodi
I present the youtube-dl Recorder for Kodi.
<p align="center">
<img width="283" alt="youtube-dl" src="https://user-images.githubusercontent.com/46063764/103497326-794f1a00-4e41-11eb-83c3-838f9c263d17.png"></p>

It can download almost anything you throw at it, and the thumbnails as well.
It communicates with kodi via it's web server, so make sure you enable it here:
System=>Services=>Control=>Allow remote control via HTTP


If you don't have youtube-dl installed, it can install it for you as it's needed.
I also recommend that you download ffmpeg and put in the samme folder as
youtube-dl.exe, as some media require it.
If you're into live streams, also download rtmpdump and put in the same folder.
No need to add any path to the system environment variables, as long as the files are
in the same folder as youtube-dl.exe.

After setup, just press the shortcut key to start a download from playing media, 
(must be playing).
You can start as many concurrent downloads as you wish, if your internet connection
can handle it.

To close the recorder press F4.
To update youtube-dl, press Ctrl + F1 
or delete the  youtube-dl.ini to restart setup and download from there.

A desktop shortcut will be created to start the recorder.

Created in Autohotkey

Download here:

This is version 1.0

For those that want to compile it for themselves, here's the source files:
