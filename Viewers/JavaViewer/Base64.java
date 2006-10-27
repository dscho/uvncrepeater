//  Copyright (C) 2005 Ultr@VNC Team.  All Rights Reserved.
//
//  This is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This software is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this software; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307,
//  USA.
//

import java.io.UnsupportedEncodingException;

/**
 * A simple base-64 codec.
 */
public class Base64 {
    private static final byte[] map = {
        (byte)'A', (byte)'B', (byte)'C', (byte)'D', (byte)'E', (byte)'F',
        (byte)'G', (byte)'H', (byte)'I', (byte)'J', (byte)'K', (byte)'L',
        (byte)'M', (byte)'N', (byte)'O', (byte)'P', (byte)'Q', (byte)'R',
        (byte)'S', (byte)'T', (byte)'U', (byte)'V', (byte)'W', (byte)'X',
        (byte)'Y', (byte)'Z',
        (byte)'a', (byte)'b', (byte)'c', (byte)'d', (byte)'e', (byte)'f',
        (byte)'g', (byte)'h', (byte)'i', (byte)'j', (byte)'k', (byte)'l',
        (byte)'m', (byte)'n', (byte)'o', (byte)'p', (byte)'q', (byte)'r',
        (byte)'s', (byte)'t', (byte)'u', (byte)'v', (byte)'w', (byte)'x',
        (byte)'y', (byte)'z',
        (byte)'0', (byte)'1', (byte)'2', (byte)'3', (byte)'4', (byte)'5',
        (byte)'6', (byte)'7', (byte)'8', (byte)'9', (byte)'+', (byte)'/'
    };

    /**
     * Not meant to be instantiated.
     */
    private Base64() {
    }

    public static String encode(String str) {
        try
            { return new String(encode(str.getBytes("ISO-8859-1")), "ISO-8859-1"); }
        catch (UnsupportedEncodingException uee)
            { throw new Error(uee.toString()); }
    }

    public static byte[] encode(byte[] data) {
        int sidx, didx;
        byte dest[] = new byte[((data.length+2)/3)*4];

        // 3-byte to 4-byte conversion + 0-63 to ascii printable conversion
        for (sidx=0, didx=0; sidx < data.length-2; sidx += 3) {
            dest[didx++] = map[(data[sidx] >>> 2) & 077];
            dest[didx++] = map[(data[sidx+1] >>> 4) & 017 |
                               (data[sidx] << 4) & 077];
            dest[didx++] = map[(data[sidx+2] >>> 6) & 003 |
                               (data[sidx+1] << 2) & 077];
            dest[didx++] = map[data[sidx+2] & 077];
        }

        if (sidx < data.length) {
            dest[didx++] = map[(data[sidx] >>> 2) & 077];
            if (sidx < data.length-1) {
                dest[didx++] = map[(data[sidx+1] >>> 4) & 017 |
                                   (data[sidx] << 4) & 077];
                dest[didx++] = map[(data[sidx+1] << 2) & 077];
            } else
                dest[didx++] = map[(data[sidx] << 4) & 077];
        }

        // add padding
        for ( ; didx < dest.length; didx++)
            dest[didx] = (byte) '=';

        return dest;
    }
}
