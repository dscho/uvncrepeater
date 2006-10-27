//
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

import java.io.DataInputStream;
import java.io.IOException;
import java.net.Socket;

/**
 * Creates a socket via an rfb repeater.
 */
class RFBRepeaterSocketFactory implements SocketFactory {
    private SocketFactory factory;

    public RFBRepeaterSocketFactory(SocketFactory nextFactory) {
        factory = nextFactory;
    }

    /**
     * Create a socket to the given host and port. The following parameters are
     * read from <var>params</var>:
     * <dl>
     *   <dt>REPEATERHOST
     *   <dd>the hostname of the repeater to contact; if null, a direct
     *       connection is established
     *   <dt>REPEATERPORT
     *   <dd>the port of the repeater to contact
     * </dl>
     *
     * @param host   the id to use
     * @param port   ignored
     * @param params the parameters
     */
    public Socket createSocket(String host, int port, Parameters params)
        throws IOException {

        /* look up the configured proxy info */
        String repHost    = params.get("REPEATERHOST");
        String repPortStr = params.get("REPEATERPORT");

        /* parse the port */
        int repPort = 0;
        if (repPortStr != null) {
            try {
                repPort = Integer.parseInt(repPortStr);
            } catch (NumberFormatException e) {
                System.err.println("Error parsing repeater port string '" +
                                   repPortStr + "'");
                e.printStackTrace();
            }
        } else
            repPort = 443;

        /* check for invalid config */
        if (repHost != null && repPort == 0) {
            System.out.println("Incomplete repeater parameter list (missing port)");
            repHost = null;
        }

        /* create the socket */
        Socket sock;

        if (repHost != null) {
            sock = factory.createSocket(repHost, repPort, params);
            System.out.println("Connecting to repeater " + repHost +
                               " port " + repPort);
            doRepeater(sock, host);
        } else {
            sock = factory.createSocket(host, port, params);
        }

        return sock;
    }

    private void doRepeater(Socket sock, String id) throws IOException {
        // Read the RFB protocol version
        final String buf2 = "";
        sock.getOutputStream().write(buf2.getBytes());

        DataInputStream is = new DataInputStream(sock.getInputStream());
        String line = is.readLine();

        // Write the ID
        if (!id.startsWith("ID:"))
            id = "ID:" + id;

        byte[] buf = new byte[250];
        System.arraycopy(id.getBytes("ISO-8859-1"), 0, buf, 0, id.length());

        sock.getOutputStream().write(buf);
    }
}
