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
 
 /* RFBReflectionProtocol.as
  * Copyright (C) 2006 Lokkju, Inc
  */
package fvnc.rfb
{

import flash.events.*;
import flash.net.Socket;
import flash.utils.ByteArray;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.ui.*;
import com.darronschall.utils.StringUtil;
import com.darronschall.utils.ByteArrayUtil;
import fvnc.errors.ConnectionError;
import fvnc.events.*;
import fvnc.rfb.constants.*;
import fvnc.rfb.PixelFormat;

/**
 * The RFBProtocol implements the RFB specification to connect
 * to a remote RFB server
 */
public class RFBReflectionProtocol extends RFBProtocol {
	/** The id of the server we're connecting to */
	private var id:uint;
	
	public function RFBReflectionProtocol( host:String, port:uint, id:uint )
	{
		super( host, port);
		this.id = id;
	}
		/**
	 * Writes the id to the reflector, if using one
	 */
	public override function writeId():void {
		var id:String = "ID:" + this.id.toString();
		var ba:ByteArray = StringUtil.toByteArray(id);
		ba.writeByte(0);
		writeBytes(ba,0,ba.length);
		flush();
    }
}

}