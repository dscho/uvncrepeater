///////////////////////////////////////////////////////////////////////
// Copyright (C) 2006 Lokkju, Inc. lokkju@lokkju.com
// Copyright (C) 2006 Jari Korhonen. jarit1.korhonen@dnainternet.net.
// All Rights Reserved.
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307,
// USA.
//
//
// If the source code for the program is not available from the place
// from which you received this file, check
// http://koti.mbnet.fi/jtko
//
//////////////////////////////////////////////////////////////////////
#ifdef EVENTS_ENABLE

#include <stdio.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>

#ifdef EVENTS_USE_MYSQL
#include <mysql.h> 
#endif //EVENTS_USE_MYSQL

#include "readini.h"
#include "repeaterevents.h"
#include "openbsd_stringfuncs.h"
#include "repeater.h"

//Local data
//Local data
//Local data
#define MAX_EVENT_MSG_LEN 200
#define MAX_EVENT_SQL_LEN 5000

//This variable is used for keeping track of child process running doEventWork 
//(routine posting various repeater "events" to outside world)
//and cleaning up after its exit
static pid_t eventProc;
static repeaterEvent eventFifo[MAX_FIFO_EVENTS];
static int fifoHeadInd;
static int fifoTailInd;
static int itemsInFifo;

//Local functions
//Local functions
//Local functions

static int advanceFifoIndex(int index)
{
    if (index < (MAX_FIFO_EVENTS-1)) 
        index++;
    else
        index = 0;
    
    return index;
}

static bool isFifoFull(void)
{
    return (MAX_FIFO_EVENTS == itemsInFifo);
}

static bool isFifoEmpty(void)
{
    return (0 == itemsInFifo);
}


//Clear Fifo indexes. Parent process (repeater itself) needs to call this after 
//forking event-sending process, otherwise it will fork handler for same old events forever. 
//I did this --> 100 % cpu load until I killed repeater process ;-)
void clearFifo(void)
{
    fifoHeadInd = 0;
    fifoTailInd = 0;
    itemsInFifo = 0;
}

//For each event in FIFO, build a message line for repeatereventlistener and send it
//This procedure accesses eventFifo, but there is no need for synchronization (with main repeater process)
//because we got our own copy of memory when kernel started us  
static int doEventWork(void)
{
    connectionEvent *connEv;
    sessionEvent *sessEv;
    startEndEvent *seEv;
    int eventNum;
    repeaterEvent ev;
    int msgLen;
    
    #ifdef EVENTS_USE_LISTENER
    int connection;
    char eventMessageToListener[MAX_EVENT_MSG_LEN];
    char eventListenerIp[MAX_IP_LEN];
    if (strcmp(eventHandlerType,"eventlistener") == 0) {
		connection = openConnectionToEventListener(eventListenerHost, eventListenerPort, eventListenerIp, MAX_IP_LEN);  
		if (-1 != connection) {
			while(!isFifoEmpty()) {
				ev = eventFifo[fifoTailInd];
				itemsInFifo--;
				fifoTailInd = advanceFifoIndex(fifoTailInd);
				
				eventNum = ev.eventNum;
				
				switch (eventNum) {
					case VIEWER_CONNECT:
					case VIEWER_DISCONNECT:
					case SERVER_CONNECT:
					case SERVER_DISCONNECT:
						connEv = (connectionEvent *) ev.extraInfo;
						msgLen = snprintf(eventMessageToListener, MAX_EVENT_MSG_LEN, 
							"EvMsgVer:%d,EvNum:%d,Time:%ld,Pid:%d,TblInd:%d,Code:%ld,Mode:%d,Ip:%d.%d.%d.%d\n",
							REP_EVENT_VERSION, eventNum, ev.timeStamp, ev.repeaterProcessId, 
							connEv -> tableIndex, connEv -> code, connEv -> connMode, 
							connEv->peerIp.a,connEv->peerIp.b,connEv->peerIp.c,connEv->peerIp.d);  
						break;
					
					case VIEWER_SERVER_SESSION_START:
					case VIEWER_SERVER_SESSION_END:
						sessEv = (sessionEvent *) ev.extraInfo;
						msgLen = snprintf(eventMessageToListener, MAX_EVENT_MSG_LEN, 
							"EvMsgVer:%d,EvNum:%d,Time:%ld,Pid:%d,SvrTblInd:%d,VwrTblInd:%d,"
							"Code:%ld,Mode:%d,SvrIp:%d.%d.%d.%d,VwrIp:%d.%d.%d.%d\n",
							REP_EVENT_VERSION, eventNum, ev.timeStamp, ev.repeaterProcessId, 
							sessEv -> serverTableIndex, sessEv -> viewerTableIndex, sessEv -> code, sessEv -> connMode, 
							sessEv->serverIp.a, sessEv->serverIp.b, sessEv->serverIp.c, sessEv->serverIp.d,
							sessEv->viewerIp.a, sessEv->viewerIp.b, sessEv->viewerIp.c, sessEv->viewerIp.d);  
						break;
					
					case REPEATER_STARTUP:
					case REPEATER_SHUTDOWN:
					case REPEATER_HEARTBEAT:
						seEv = (startEndEvent *) ev.extraInfo;
						msgLen = snprintf(eventMessageToListener, MAX_EVENT_MSG_LEN, 
							"EvMsgVer:%d,EvNum:%d,Time:%ld,Pid:%d,MaxSessions:%d\n",
							REP_EVENT_VERSION, eventNum, ev.timeStamp, ev.repeaterProcessId, seEv -> maxSessions);  
						break;
					
					default:
						msgLen = 0;
						strlcpy(eventMessageToListener, "\n", MAX_EVENT_MSG_LEN);
						break;
				}
				
				if (msgLen > 0) { 
					writeExact(connection, eventMessageToListener, 
						strlen(eventMessageToListener), TIMEOUT_5SECS);
				        
				    debug(LEVEL_3, "%s", eventMessageToListener);
				}
			}
			close(connection);
		}
	}
	#endif //EVENTS_USE_LISTENER
	#ifdef EVENTS_USE_MYSQL
	char eventMessageSQL[MAX_EVENT_SQL_LEN];
	debug(LEVEL_3,"Event handler type: %s, length: %i, strcmp: %i\n",eventHandlerType,strlen(eventHandlerType),strcmp(eventHandlerType,"mysql"));
	if (strcmp(eventHandlerType,"mysql") == 0) {
		int status = 0;
		MYSQL mysql;
		mysql_init(&mysql);
		if (!mysql_real_connect(&mysql,mysqlHost,mysqlUser,mysqlPass,mysqlDb,0,NULL,0))
		{
			debug(LEVEL_1, "Failed to connect to database (%s:%i, %s): Error: %s\n",mysqlHost,mysqlPort,mysqlDb,mysql_error(&mysql));
		}
		else
		{
			debug(LEVEL_3,"Connected to MySQL Database\n");
			while(!isFifoEmpty()) {
				ev = eventFifo[fifoTailInd];
				itemsInFifo--;
				fifoTailInd = advanceFifoIndex(fifoTailInd);
				
				eventNum = ev.eventNum;
				char cuid_str[36];
				char puid_str[36];
				char cuid_str2[36];
				memset(cuid_str, 0, 36);
				memset(puid_str, 0, 36);
    		memset(cuid_str2, 0, 36);
    
				switch (eventNum) {
					case VIEWER_CONNECT:
						status = 1;
						connEv = (connectionEvent *) ev.extraInfo;
		    		uuid_unparse(connEv->uid,cuid_str);
		    		uuid_unparse(process_uid,puid_str);
						msgLen = snprintf(eventMessageSQL, MAX_EVENT_SQL_LEN,
							"INSERT INTO viewers (uid,repeater_uid,lasttime,status,table_index,code,mode,ip) VALUES ('%s','%s',%ld,%d,%d,%ld,%d,'%d.%d.%d.%d');\n",
							cuid_str,puid_str, ev.timeStamp, status,connEv->tableIndex,connEv->code,connEv->connMode, 
							connEv->peerIp.a,connEv->peerIp.b,connEv->peerIp.c,connEv->peerIp.d);  
						break;
					case VIEWER_DISCONNECT:
						status = 0;
						connEv = (connectionEvent *) ev.extraInfo;
		    		uuid_unparse(connEv->uid,cuid_str);
						msgLen = snprintf(eventMessageSQL, MAX_EVENT_SQL_LEN,
							"UPDATE viewers SET lasttime = %ld,status = %d WHERE uid = '%s';\n",
							ev.timeStamp, status,cuid_str);
						break;
					case SERVER_CONNECT:
						status = 1;
						connEv = (connectionEvent *) ev.extraInfo;
		    		uuid_unparse(connEv->uid,cuid_str);
		    		uuid_unparse(process_uid,puid_str);
						msgLen = snprintf(eventMessageSQL, MAX_EVENT_SQL_LEN,
							"INSERT INTO servers (uid,repeater_uid,lasttime,status,table_index,code,mode,ip) VALUES ('%s','%s',%ld,%d,%d,%ld,%d,'%d.%d.%d.%d');\n",
							cuid_str,puid_str,ev.timeStamp, status,connEv->tableIndex,connEv->code,connEv->connMode, 
							connEv->peerIp.a,connEv->peerIp.b,connEv->peerIp.c,connEv->peerIp.d);  
						break;
					case SERVER_DISCONNECT:
						status = 0;
						connEv = (connectionEvent *) ev.extraInfo;
		    		uuid_unparse(connEv->uid,cuid_str);
						msgLen = snprintf(eventMessageSQL, MAX_EVENT_SQL_LEN,
							"UPDATE servers SET lasttime = %ld,status = %d WHERE uid = '%s';\n",
							ev.timeStamp, status,cuid_str);
						break;
					
					case VIEWER_SERVER_SESSION_START:
						status = 1;
						sessEv = (sessionEvent *) ev.extraInfo;
				 		uuid_unparse(sessEv->server_uid,cuid_str);
    				uuid_unparse(sessEv->viewer_uid,cuid_str2);
    				uuid_unparse(process_uid,puid_str);
						msgLen = snprintf(eventMessageSQL, MAX_EVENT_SQL_LEN, 
							"INSERT INTO sessions (repeater_uid,status,lasttime,server_index,server_ip,server_uid,viewer_index,viewer_ip,viewer_uid,code,mode) "
							"VALUES ('%s',%d,%ld,%d,'%d.%d.%d.%d','%s',%d,'%d.%d.%d.%d','%s',%ld,%d);\n",
							puid_str,status,ev.timeStamp,
							sessEv -> serverTableIndex,sessEv->serverIp.a, sessEv->serverIp.b, sessEv->serverIp.c, sessEv->serverIp.d,cuid_str,
							sessEv -> viewerTableIndex,sessEv->viewerIp.a, sessEv->viewerIp.b, sessEv->viewerIp.c, sessEv->viewerIp.d,cuid_str2,
							sessEv -> code, sessEv -> connMode);  
						break;
					
					case VIEWER_SERVER_SESSION_END:
						status = 0;
						sessEv = (sessionEvent *) ev.extraInfo;
						uuid_unparse(process_uid,puid_str);
				 		uuid_unparse(sessEv->server_uid,cuid_str);
    				uuid_unparse(sessEv->viewer_uid,cuid_str2);
						msgLen = snprintf(eventMessageSQL, MAX_EVENT_SQL_LEN, 
							"UPDATE sessions SET status=%d,lasttime=%ld WHERE repeater_uid='%s' AND server_uid='%s' AND viewer_uid='%s';\n",
							status,ev.timeStamp,puid_str,cuid_str,cuid_str2);
						break;
					
					case REPEATER_STARTUP:
						status = 1;
						seEv = (startEndEvent *) ev.extraInfo;
						uuid_unparse(process_uid,puid_str);
						msgLen = snprintf(eventMessageSQL, MAX_EVENT_SQL_LEN, 
							"INSERT INTO repeaters (uid,process_id,lasttime,status,maxsessions,ip,server_port,viewer_port) VALUES ('%s',%d,%ld,%d,%d,'%s',%d,%d);\n",
							puid_str,ev.repeaterProcessId,ev.timeStamp, status, seEv -> maxSessions, ownIpAddress,serverPort,viewerPort);  
						break;
					case REPEATER_SHUTDOWN:
						status = 0;
						seEv = (startEndEvent *) ev.extraInfo;
						uuid_unparse(process_uid,puid_str);
						msgLen = snprintf(eventMessageSQL, MAX_EVENT_SQL_LEN, 
							"UPDATE repeaters SET lasttime=%ld,status=%d WHERE uid='%s';\n",
							ev.timeStamp, status, puid_str);
						break;
					case REPEATER_HEARTBEAT:
						uuid_unparse(process_uid,puid_str);
						msgLen = snprintf(eventMessageSQL, MAX_EVENT_SQL_LEN, 
							"UPDATE repeaters SET lasttime=%ld WHERE uid='%s';\n",
							ev.timeStamp, puid_str);
						break;
					default:
						msgLen = 0;
						strlcpy(eventMessageSQL, "\n", MAX_EVENT_SQL_LEN);
						break;
				}
				
				if (msgLen > 0) { 
					mysql_query(&mysql,eventMessageSQL);
					if(mysql_errno(&mysql))
					{
						debug(LEVEL_1,"MYSQL ERROR: %s\n",mysql_error(&mysql));
					}
					debug(LEVEL_1, "%s", eventMessageSQL);
				}
			}
			mysql_close(&mysql);
		}		
	}
	#endif //EVENTS_USE_MYSQL
	return 0;
}

//Clean up after event-sending processes is finished
static void cleanUpAfterEventProc(void)
{
    pid_t pid;
    
    if (eventProc != 0) {
        pid = waitpid(eventProc, NULL, WNOHANG);
        if (pid > 0) {
            debug(LEVEL_3, "cleanUpAfterEventProc(): Removing event posting process (pid=%d)\n", pid);
            eventProc = 0;
        }
    } 
}



//Global functions
//Global functions
//Global functions
void initRepeaterEventInterface(void)
{
    clearFifo();
    memset(eventFifo, 0, MAX_FIFO_EVENTS * sizeof(repeaterEvent));
    eventProc = 0;
}


//Send event from repeater to event FIFO
//Return true if success, false if failure
bool sendRepeaterEvent(repeaterEvent ev)
{
    if (!isFifoFull()) {
        //Add timestamp
        ev.timeStamp = time(NULL);
        
        eventFifo[fifoHeadInd] = ev;
        
        fifoHeadInd = advanceFifoIndex(fifoHeadInd);
        
        itemsInFifo++;
        
        return true;
    }
    return false;
}


//Send event from repeater to outside world by forking an event-sending process
//If event-sending process is running, check if it finished and clean up
void handleRepeaterEvents(void)
{
    pid_t pid;
    
    if (0 == eventProc) {
        //Event posting process is not running, create one if events in fifo
        if (!isFifoEmpty()) {
            //fork doEvent
            pid = fork();
            if (-1 == pid) {
                //fork failed. This is so unfair. Exit and blame Linus ;-)
                fatal(LEVEL_0, "handleRepeaterEvents(): fork() failed. Linus, this is *so* unfair\n");
            }
            else if (0 == pid) {
                //child code
                debug(LEVEL_3, "handleRepeaterEvents(): in child process, starting doEventWork()\n");
                exit(doEventWork());
            }
            else {
                //parent code
                //Store child pid to variable eventProc so we can
                //properly clean up after child has exited
                eventProc = pid;
                
                //Clean parent process' fifo
                clearFifo();
            }
        }
    }
    else {
        //Event-sending process is running, check if run has ended
        cleanUpAfterEventProc();
    }
}

#endif //EVENTS_ENABLE
