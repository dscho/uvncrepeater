; CLW file contains information for the MFC ClassWizard

[General Info]
Version=1
LastClass=IdDialog
LastTemplate=CDialog
NewFileInclude1=#include "stdafx.h"
NewFileInclude2=#include "winvnc.h"
LastPage=0

ClassCount=1

ResourceCount=8
Resource1=IDD_PROPERTIES
Resource2=IDD_ENTERID (Neutral)
Resource3=IDD_ABOUT
Resource4=IDD_TEXTCHAT_DLG
Resource5=IDC_TITLEWINDOW
Resource6=IDC_TITLEWINDOW_SMALL
Resource7=IDD_PROPERTIES1
Class1=IdDialog
Resource8=IDR_TRAYMENU

[DLG:IDC_TITLEWINDOW_SMALL]
Type=1
Class=?
ControlCount=3
Control1=IDC_CONNECT,button,1342242816
Control2=IDC_CLOSE,button,1342242816
Control3=IDC_TEXTMIDDLE,static,1342308353

[DLG:IDC_TITLEWINDOW]
Type=1
Class=?
ControlCount=11
Control1=IDC_LIST,SysListView32,1350680965
Control2=65535,button,1342177415
Control3=IDC_LOGO,static,1342177294
Control4=IDC_TEXTTOP,static,1342308353
Control5=IDC_TEXTMIDDLE,static,1342308353
Control6=IDC_TEXTBOTTOM,static,1342308353
Control7=IDC_HELPWEB,button,1342242816
Control8=IDC_TEXTRICHTTOP,static,1342308352
Control9=IDC_TEXTRIGHTBOTTOM,static,1342308352
Control10=IDC_CLOSE,button,1342242816
Control11=IDC_TEXTRIGHTMIDDLE,static,1342308352

[DLG:IDD_ENTERID (Neutral)]
Type=1
Class=?
ControlCount=4
Control1=IDC_IDCODE,edit,1342185472
Control2=IDOK,button,1342242817
Control3=IDCANCEL,button,1342242816
Control4=IDC_STATICIDCODE,static,1342308353

[DLG:IDD_ABOUT]
Type=1
Class=?
ControlCount=9
Control1=IDOK,button,1342242817
Control2=IDC_VNCLOGO,static,1342181902
Control3=IDC_VERSION,static,1342308352
Control4=IDC_NAME,static,1342308352
Control5=IDC_WWW,static,1342308352
Control6=IDC_BUILDTEXT,static,1342308352
Control7=IDC_BUILDTIME,static,1342308352
Control8=IDC_STATIC,static,1342308352
Control9=IDC_STATIC,static,1342308352

[DLG:IDD_PROPERTIES]
Type=1
Class=?
ControlCount=13
Control1=IDCANCEL,button,1342242816
Control2=IDOK,button,1342242817
Control3=IDC_UPDATE_BORDER,button,1342177287
Control4=IDC_POLL_FULLSCREEN,button,1342242819
Control5=IDC_CONSOLE_ONLY,button,1342251011
Control6=IDC_POLL_FOREGROUND,button,1342242819
Control7=IDC_POLL_UNDER_CURSOR,button,1342242819
Control8=IDC_ONEVENT_ONLY,button,1342251011
Control9=IDC_APPLY,button,1342242816
Control10=IDC_DRIVER,button,1342242819
Control11=IDC_HOOK,button,1342242819
Control12=IDC_TURBOMODE,button,1342242819
Control13=IDC_CHECKDRIVER,button,1342242816

[DLG:IDD_PROPERTIES1]
Type=1
Class=?
ControlCount=1
Control1=IDOK,button,1342242817

[DLG:IDD_TEXTCHAT_DLG]
Type=1
Class=?
ControlCount=6
Control1=IDC_INPUTAREA_EDIT,edit,1344344132
Control2=IDC_SEND_B,button,1342251008
Control3=IDC_HIDE_B,button,1342242816
Control4=IDCANCEL,button,1342242816
Control5=IDC_CHATAREA_EDIT,RICHEDIT,1344346180
Control6=IDOK,button,1073807360

[MNU:IDR_TRAYMENU]
Type=1
Class=?
Command1=ID_PROPERTIES
Command2=ID_ABOUT
Command3=ID_CLOSE
CommandCount=3

[CLS:IdDialog]
Type=0
HeaderFile=IdDialog.h
ImplementationFile=IdDialog.cpp
BaseClass=CDialog
Filter=D
LastObject=ID_ABOUT

