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

ProcessCloseAll(PIDOrName)
{
    While ProcessExist(PIDOrName)
        ProcessClose PIDOrName
}

GameCachePath := "C:\Users\" A_UserName "\AppData\LocalLow\VRChat\VRChat\Cache-WindowsPlayer"
LINKGCP := A_ScriptDir "\Cache-WindowsPlayer"
RUNPATH := "powershell New-Item -ItemType SymbolicLink -Path " GameCachePath " -Target " LINKGCP

MyGui := Gui("+Resize")
MyGui.SetFont(, "Segoe UI")
MyGui.Add("Button", "default Center", "更改模型缓存路径`n（将关闭VRChat程序，并更改模型缓存路径到此工具所在目录的子目录下）").OnEvent("Click", MKLINK)
MyGui.Add("Button", "Center" , "恢复模型缓存路径`n（将关闭VRChat程序，并将模型缓存路径恢复成默认）").OnEvent("Click", REMK)
MyGui.Add("Text",, "使用说明：将此工具放在一个空间充足的磁盘或目录中，这样工具会将缓存路径更改到工具所在的目录中。")
MyGui.Add("Text",, "⚠️注意请严格按照使用说明使用本程序，如因使用不当出现问题，本程序概不负责。⚠️")
MyGui.Add("Button", "Center", "清除保留缓存`n（恢复模型缓存路径后，原来使用过的缓存路径内容依然会保留，`n通过此操作可以清除）").OnEvent("Click", CLEARN)
MyGui.Add("Link",, '@<a href="https://github.com/Nelocompne">作者链接</a>')
MyGui.Show()

MKLINK(*){
    ProcessCloseAll "VRChat.exe"
    If DirExist(GameCachePath) {
        DirCopy GameCachePath, LINKGCP, 1
        DirDelete GameCachePath , true
        Run RUNPATH
        MsgBox "Yes"
    } else {
        DirCreate LINKGCP
        Run RUNPATH
        MsgBox "None"
    }
}

REMK(*){
    ProcessCloseAll "VRChat.exe"
    If DirExist(GameCachePath) {
        DirDelete GameCachePath
        DirCopy LINKGCP, GameCachePath 
        MsgBox "Yes"
    } else {
        MsgBox "None"
    }
}

CLEARN(*){
    DirDelete LINKGCP , true
}

; Run A_ComSpec "mklink /d \MyFolder \Users\User1\Documents"