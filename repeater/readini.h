// Copyright (C) 2006 Lokkju, Inc. lokkju@lokkju.com

#ifndef _READINI_H_
#define _READINI_H_

#include "commondefines.h"

//variables
extern int viewerPort;
extern int serverPort;
extern int allowedModes;
extern int loggingLevel;
extern int allowedMode1ServerPort; 
extern int requireListedId;
extern int maxSessions;
extern int idList[];
extern int requireListedServer;
extern addrParts srvListAllow[];
extern addrParts srvListDeny[];
extern char ownIpAddress[];
extern char runAsUser[];

#ifdef EVENTS_ENABLE
extern bool useEventInterface;
extern char eventHandlerType[];

#ifdef EVENTS_USE_LISTENER
extern char eventListenerHost[];
extern int eventListenerPort;
#endif

#ifdef EVENTS_USE_MYSQL
extern char mysqlHost[];
extern char mysqlUser[];
extern char mysqlPass[];
extern char mysqlDb[];
extern int mysqlPort;
#endif

#ifdef EVENTS_USE_SQLITE
extern char sqliteDbPath[];
#endif

#endif
//functions
bool readIniFile(char *iniFilePathAndName);

#endif
