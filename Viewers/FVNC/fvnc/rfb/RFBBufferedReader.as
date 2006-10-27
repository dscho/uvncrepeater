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
package fvnc.rfb
{

import flash.events.*;
import flash.net.Socket;
import flash.utils.ByteArray;
import flash.geom.Point;
import flash.geom.Rectangle;
import com.darronschall.utils.*;
import fvnc.events.*;

/**
 * The RFBBufferedReader is necessary due to the asynchronous nature
 * of Flash's Socket class.  It is used because the ByteArray has an
 * interface very similar to Socket except that we can use the position
 * property to "go back in time" if we need to.
 *
 * The basic idea is that the RFBProtocol is used for handshaking and
 * for sending messages from the Flash client to the RFB server.  Whenever
 * data comes from the server, it gets transferred into an RFBBufferedReader
 * so that we can process it.  Theres a good chance that when data comes
 * across, not all of the data is going to be available.  Thus, if we try
 * to process is via Socket we'll get EOFError's without the ability to 
 * rewind and try again when more data comes through.  By storing the
 * socket data into this buffered reader, if we reach the end of the buffer
 * before we can "finish" processing a server message, we can simply
 * reset the position and try again when more data becomes available.
 */
public class RFBBufferedReader extends ByteArray
{
	
	/** Store the number of bytes per pixel for reading pixel data */
	public var bytesPerPixel:uint;
	
	/** Determine how the pixel value is read (endian-ness is important!) */
	public var pixelEndian:String;
	
	/**
	 * Reads the type of the message coming from the 
	 * server and returns an int corresponding
	 * to one of the constants in the <code>Server</code>
	 * class.
	 */
	public function readServerMessageType():int
	{
		return readUnsignedByte();	
	}
	
	/**
	 * Reads a frameBufferUpdate server message
	 *
	 * @return The number of rectangles to update
	 */
	public function readFrameBufferUpdate():int
	{
		//skip padding
		readByte();	
		return readUnsignedShort();
	}
	
	/**
	 * Reads a rectangle location and dimensions 
	 * from the server
	 */
	public function readRectangle():Rectangle
	{
		var rect:Rectangle = new Rectangle();
		rect.x = readUnsignedShort();
		rect.y = readUnsignedShort();
		rect.width = readUnsignedShort();
		rect.height = readUnsignedShort();
		return rect;
	}
	
	/**
	 * Reads the encoding type for the pixel data in the frame
	 * buffer update rectangle.  Returns an int corresponding
	 * to one of the constants in the <code>Encoding</code> class.
	 */
	public function readFrameBufferUpdateRectangleEncoding():int
	{
		return readInt();
	}
	
	/**
	 * Reads the pixel data for a raw encoded frame buffer
	 * update message.
	 */
	public function readPixelData():uint
	{
		var bytes:ByteArray = new ByteArray();
		readBytes( bytes, 0, bytesPerPixel );
		bytes.endian = pixelEndian;
		switch ( bytesPerPixel ) 
		{
			case 1: return bytes.readByte();
			case 2: return bytes.readShort();
			case 4: return bytes.readInt();
			default:
				throw new Error( "Invalid bytesPerPixel: " + bytesPerPixel );
		}
	}
	
	/**
	 * Reads the compressed pixel data for a raw encoded frame 
	 * buffer update message.
	 */
	public function readCompressedPixelData():uint
	{
		var bytes:ByteArray = new ByteArray();
		readBytes( bytes, 0, bytesPerPixel );
		bytes.endian = pixelEndian;
		switch ( bytesPerPixel ) 
		{
			case 1: return bytes.readByte();
			case 2: return bytes.readShort();
			case 4: return bytes.readInt();
			default:
				throw new Error( "Invalid bytesPerPixel: " + bytesPerPixel );
		}
	}
	
	/**
	 * Reads a point from the server
	 */
	public function readPoint():Point
	{
		var p:Point = new Point();
		p.x = readUnsignedShort();
		p.y = readUnsignedShort();
		return p;
	}
	
	/** 
	 * The start of RRE Encoding, read the number
	 * of subrectangles
	 */
	public function readRreSubRectangles():uint
	{
		return readUnsignedInt();
	}
	
	/**
	 * Reads the subencoding-mask used for tiles during
	 * HexTile encoding of a FrameBufferUpdate
	 */
	public function readHexTileSubEncodingMask():int
	{
		return readUnsignedByte();	
	}
	
	/** 
	 * Read the number of subrectangles for hextile
	 * encoding
	 */
	public function readHexTileSubRectangles():int
	{
		return readUnsignedByte();
	}
	
	/**
	 * Reads a sub rectangle for hextile encoding
	 */
	public function readHexTileSubRectangle():Rectangle
	{
		var rect:Rectangle = new Rectangle();
		
		// first byte is x and y position
		var first:int = readUnsignedByte();
		// second byte is width minus 1 and height minus 1
		var second:int = readUnsignedByte();
		
		rect.x = first >> 4;
		rect.y = first & 0x0F;
		rect.width = ( second >> 4 ) + 1;
		rect.height = ( second & 0x0F ) + 1;
		
		return rect;	
	}
	
	/**
	 * Reads a set color map entries message from the server.
	 *
	 * @return An object with the following properties:
	 *		firstColor	int
	 *		numColors	int
	 */
	public function readSetColorMapEntries():Object
	{
		// skip padding
		readByte();	
		
		var o:Object = new Object();
		o.firstColor = readUnsignedShort();
		o.numColors = readUnsignedShort();
		
		return 0;
	}
	
	/**
	 * Reads a color entry from the server
	 *
	 * @return An object with the following properties:
	 *		red		int
	 *		green	int
	 *		blue	int
	 */
	public function readColorEntry():Object
	{
		var o:Object = new Object();
		o.red = readUnsignedShort();
		o.green = readUnsignedShort();
		o.blue = readUnsignedShort();
		return o;
	}
	
	/**
	 * Reads a server cut text message from the server
	 *
	 * @return The string that was cut
	 */
	public function readServerCutText():String
	{
		// skip padding
		readByte();
		readByte();
		readByte();
		
		var length:uint = readUnsignedInt();
		var text:ByteArray = new ByteArray();
		readBytes( text, 0, length );
		return text.toString();
	}
	
} // end class
} // end package