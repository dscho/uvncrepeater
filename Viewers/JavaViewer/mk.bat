@ECHO OFF
PATH=%PATH%;C:\Program Files\Java\jdk1.5.0_05\bin;
javac.exe *.java
jar.exe cf VncViewer.jar *.class
