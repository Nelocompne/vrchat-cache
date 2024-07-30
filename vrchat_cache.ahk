; V2 Script
#SingleInstance Force

full_command_line := DllCall("GetCommandLine", "str")

if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    try
    {
        if A_IsCompiled
            Run '*RunAs "' A_ScriptFullPath '" /restart'
        else
            Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
    }
    ExitApp
}

; 循环杀死某个进程
ProcessCloseAll(PIDOrName)
{
    While ProcessExist(PIDOrName)
        ProcessClose PIDOrName
}

; 游戏默认缓存路径，目标转移路径，动态链接powershell实现
GameCachePath := "C:\Users\" A_UserName "\AppData\LocalLow\VRChat\VRChat\Cache-WindowsPlayer"
LINKGCP := A_ScriptDir "\Cache-WindowsPlayer"
RUNPATH := "powershell New-Item -ItemType SymbolicLink -Path " GameCachePath " -Target " LINKGCP

; 计算目录文件占用大小，单位GB
CLASIZE(CLAPATH){
    FolderSize := 0
    WhichFolder := CLAPATH
    Loop Files, WhichFolder "\*.*", "R"
        FolderSize += A_LoopFileSize
    return Format("{:.2f}", FolderSize/1073741824)
}

; 如果缓存目录存在则计算，否则计算默认缓存目录
If DirExist(LINKGCP) {
    GCPSize := CLASIZE(LINKGCP)
} else {
    GCPSize := CLASIZE(GameCachePath)
}

; 判断程序当前是否在默认缓存目录，如果是则阻止继续运行
If (GameCachePath = LINKGCP){
    MsgBox "不能这样做！请将此工具放在其他目录中运行。"
    ExitApp
} else {
    MsgBox "
    (
    ⚠️注意请严格按照使用说明使用本程序，如因使用不当出现问题，本程序概不负责。⚠️
    使用说明：使用前将此工具放在一个空间充足的磁盘或目录中，这样工具会将缓存路径更改到工具所在的目录中。
    )", "使用警告", "icon!"
}

Titlecla := "VRChat Cache：当前模型缓存文件占用大小 " GCPSize " GB"
MyGui := Gui("+Resize", Titlecla)
MyGui.SetFont(, "Segoe UI")
MyGui.Add("Button", "default Center w650", "退出").OnEvent("Click", EXITAPPP)
MyGui.Add("Text","Center R3 XM+1", "使用说明：使用前将此工具放在一个空间充足的磁盘或目录中，这样工具会将缓存路径更改到工具所在的目录中。").SetFont("S12", )
MyGui.Add("Button", "Center XM+100", "更改模型缓存路径`n（将关闭VRChat程序，并更改模型缓存路径到此工具所在目录的子目录下）").OnEvent("Click", MKLINK)
MyGui.Add("Button", "Center XP+50 YP+50" , "恢复模型缓存路径`n（将关闭VRChat程序，并将模型缓存路径恢复成默认）").OnEvent("Click", REMK)
MyGui.Add("Text","Center XM+60 R3", "⚠️注意请严格按照使用说明使用本程序，如因使用不当出现问题，本程序概不负责。⚠️").SetFont("S12", )
MyGui.Add("Button", "Center XM+120", "清除保留缓存`n（恢复模型缓存路径后，原来使用过的缓存路径内容依然会保留，`n通过此操作可以清除）").OnEvent("Click", CLEARN)
MyGui.Add("Link", "XM+1", '@<a href="https://github.com/Nelocompne">作者链接</a>')
MyGui.Show()

; 默认退出
EXITAPPP(*){
    ExitApp
}

; 关闭VRCHAT进程并判断默认缓存目录是否存在，否则提醒用户并创建
MKLINK(*){
    ProcessCloseAll "VRChat.exe"
    If DirExist(GameCachePath) {
        DirCopy GameCachePath, LINKGCP, 1
        DirDelete GameCachePath , true
        Run RUNPATH
        MsgBox "完成！"
    } else {
        DirCreate LINKGCP
        Run RUNPATH
        MsgBox "您貌似还没有启动过VRChat，但也已经为您转移了模型缓存。"
    }
}

; 关闭VRCHAT进程并判断默认缓存目录是否存在，如果存在则转移为默认目录
REMK(*){
    ProcessCloseAll "VRChat.exe"
    If DirExist(GameCachePath) {
        DirDelete GameCachePath
        DirCopy LINKGCP, GameCachePath 
        MsgBox "完成！"
    } else {
        MsgBox "您不需要完成此操作。"
    }
}

; 清除目标缓存目录
CLEARN(*){
    If DirExist(LINKGCP) {
        DirDelete LINKGCP , true
        MsgBox "完成！"
    } else {
        MsgBox "您不需要完成此操作。"
    }
}

; 以下为windows cmd的动态链接实现
; Run A_ComSpec "mklink /d \MyFolder \Users\User1\Documents"
;
; 本脚本采用powershell实现
; Run powershell New-Item -ItemType SymbolicLink -Path .\link -Target .\Notice.txt