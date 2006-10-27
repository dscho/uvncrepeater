/*
 * FVNC: A VNC Client for Flash Player 9 and above
 * Copyright (C) 2005-2006 Darron Schall <darron@darronschall.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
 * 02111-1307 USA
 */
package fvnc.events 
{

import flash.events.Event;

/**
 * A ConnectEvent is used to signal that an RFB connection
 * needs to be made to a specific host on a specific port.
 */
public class ConnectEvent extends Event
{
	/** Static constant for the event type to avoid typos with strings */
	public static const CONNECT_EVENT_TYPE:String = "connectEvent";

	/** The host that needs to be connected to */
	public var host:String;
	
	/** The port over which to contact the host */
	public var port:Number;
	
	public var id:Number;

	/**
	 * Constructor, create a new ConnectEvent with a specific host and port
	 */
	public function ConnectEvent( host:String = "", port:int = 5900, id:int = 0 )
	{
		super( CONNECT_EVENT_TYPE );
		
		this.host = host;
		this.port = port;
		this.id = id;
	}

} // end class
} // end package