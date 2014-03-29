#
# Making the VNC applet.
#

CP = cp
JC = javac
JAR = jar
ARCHIVE = VncViewer.jar
PAGES = index.vnc shared.vnc noshared.vnc hextile.vnc zlib.vnc tight.vnc
INSTALL_DIR = /usr/local/vnc/classes

CLASSES = VncViewer.class RfbProto.class AuthPanel.class VncCanvas.class \
	  OptionsFrame.class ClipboardFrame.class ButtonPanel.class \
	  DesCipher.class RecordingFrame.class SessionRecorder.class \
	  AppletParameters.class Base64.class CommandLineParameters.class \
	  DH.class DirectSocketFactory.class FTPFrame.class Parameters.class \
	  HTTPConnectSocketFactory.class RFBRepeaterSocketFactory.class \
	  SocketFactory.class SSLClientSocketFactory.class

SOURCES = VncViewer.java RfbProto.java AuthPanel.java VncCanvas.java \
	  OptionsFrame.java ClipboardFrame.java ButtonPanel.java \
	  DesCipher.java RecordingFrame.java SessionRecorder.java \
	  AppletParameters.java Base64.java CommandLineParameters.java \
	  DH.java DirectSocketFactory.java FTPFrame.java Parameters.java \
	  HTTPConnectSocketFactory.java RFBRepeaterSocketFactory.java \
	  SocketFactory.java SSLClientSocketFactory.java

all: $(CLASSES) $(ARCHIVE)

$(CLASSES): $(SOURCES)
	$(JC) -O $(SOURCES)

$(ARCHIVE): MANIFEST.MF $(CLASSES)
	$(JAR) cfm $(ARCHIVE) MANIFEST.MF $(CLASSES)

install: $(CLASSES) $(ARCHIVE)
	$(CP) $(CLASSES) $(ARCHIVE) $(PAGES) $(INSTALL_DIR)

export:: $(CLASSES) $(ARCHIVE) $(PAGES)
	@$(ExportJavaClasses)

clean::
	$(RM) *.class *.jar
