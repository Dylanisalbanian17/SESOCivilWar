Public Const RESIZEWIDTH_FAG = 82
Public Const RESIZEHEIGHT_FAG = 52
Public Const RESIZEWIDTH_MED = 41
Public Const RESIZEHEIGHT_MED = 26
Public Const RESIZEWIDTH_SMA = 10
Public Const RESIZEHEIGHT_SMA = 7

'Place this file into your main \gfx\flags folder. It will convert all PNG files into properly sized TGA files then save it to all three folders.

 
Dim spath
' Searches WScript.ScriptFullName for a \ starting at -1. vbBinaryCompare just means it compares with binary.
spath = Mid(WScript.ScriptFullName, 1, InStrRev(WScript.ScriptFullName, "\", -1, vbBinaryCompare))
 
Dim fso
Set fso = CreateObject("Scripting.FileSystemObject")
 
Dim foldero
Set foldero = fso.GetFolder(spath)
 
Dim fileo
Dim sfile
 
For Each fileo In foldero.Files
    'only modify png files
    sfile = fileo.Name
    If InStrRev(sfile, ".png", -1, vbTextCompare) = Len(sfile) - 3 Then
        resize spath & sfile, sfile
    End If
Next

MsgBox "Complete."
 
Sub resize(sfilename, sfile)
 
    Set WshShell = WScript.CreateObject("WScript.Shell")
    Set colProcessList = GetObject("Winmgmts:").ExecQuery("Select * from Win32_Process")
 
    Dim found
    found = False
 
    For Each objProcess In colProcessList
        If StrComp(objProcess.Name, "photoshop.exe", vbTextCompare) = 0 Then
            found = True
            Exit For
        End If
    Next
 
    Dim appRef
    If found Then
        Set appRef = GetObject(, "Photoshop.Application")
    Else
        Set appRef = CreateObject("Photoshop.Application")
    End If
 
    Do While appRef.documents.Count
       appRef.activeDocument.Close 2 'dont' save
    Loop
 
    Dim originalRulerUnits
    originalRulerUnits = appRef.Preferences.RulerUnits
    appRef.Preferences.RulerUnits = 1 'pixels
 
    Dim tgaSaveOptions
    Set tgaSaveOptions = CreateObject("Photoshop.TargaSaveOptions")
    tgaSaveOptions.resolution = 32
    tgaSaveOptions.rleCompression = false

    Dim docRef_FAG, docRef_MED, docRef_SMA, newfilename_FAG, newfilename_MED, newfilename_SMA

    sfile = Mid(sfile, 1, Len(sfile) - 4) & ".tga"
    Set docRef_FAG = appRef.Open(sfilename)
    docRef_FAG.ResizeImage RESIZEWIDTH_FAG, RESIZEHEIGHT_FAG
    newfilename_FAG = Mid(sfilename, 1, Len(sfilename) - 4) & ".tga"
    docRef_FAG.SaveAs newfilename_FAG, tgaSaveOptions, True, 2
    docRef_FAG.Close 2


    Set docRef_MED = appRef.Open(sfilename)
    docRef_MED.ResizeImage RESIZEWIDTH_MED, RESIZEHEIGHT_MED
    newfilename_MED = Mid(sfilename, 1, Len(sfilename) - 4) & ".tga"
    newfilename_MED = Replace(newfilename_MED, sfile, "\medium\" & sfile)
    docRef_MED.SaveAs newfilename_MED, tgaSaveOptions, True, 2 
    docRef_MED.Close 2


    Set docRef_SMA = appRef.Open(sfilename)
    docRef_SMA.ResizeImage RESIZEWIDTH_SMA, RESIZEHEIGHT_SMA
    newfilename_SMA = Mid(sfilename, 1, Len(sfilename) - 4) & ".tga"
    newfilename_SMA = Replace(newfilename_SMA, sfile, "\small\" & sfile)
    docRef_SMA.SaveAs newfilename_SMA, tgaSaveOptions, True, 2
    docRef_SMA.Close 2

    appRef.Preferences.RulerUnits = originalRulerUnits
 
End Sub