//
//  Copyright (C) 2005 Ultr@VNC Team.  All Rights Reserved.
//  Copyright (C) 2002 Constantin Kaplinsky, Inc.  All Rights Reserved.
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

//
// HTTPConnectSocketFactory.java together with HTTPConnectSocket.java
// implement an alternate way to connect to VNC servers via one or two
// HTTP proxies supporting the HTTP CONNECT method.
//

import java.io.DataInputStream;
import java.io.IOException;
import java.net.Socket;

/**
 * Creates a socket via an http proxy. The CONNECT method is used to get the proxy
 * to create a tunnel for us.
 */
class HTTPConnectSocketFactory implements SocketFactory {
    private SocketFactory factory;

    public HTTPConnectSocketFactory(SocketFactory nextFactory) {
        factory = nextFactory;
    }

    /**
     * Create a socket to the given host and port. The following parameters are
     * read from <var>params</var>:
     * <dl>
     *   <dt>PROXYHOST
     *   <dd>the hostname of the proxy to use; if null, a direct connection is
     *       established
     *   <dt>PROXYPORT
     *   <dd>the port of the proxy to use
     *   <dt>PROXYUSER
     *   <dd>the username to use to authenticate to the proxy
     *   <dt>PROXYPASS
     *   <dd>the password to use to authenticate to the proxy
     * </dl>
     *
     * @param host   the host to connect to
     * @param port   the port to connect to
     * @param params the parameters
     */
    public Socket createSocket(String host, int port, Parameters params)
        throws IOException {

        /* look up the configured proxy info */
        String proxyHost    = params.get("PROXYHOST");
        String proxyPortStr = params.get("PROXYPORT");

        /* if no proxy info, check the system parameters */
        if (proxyHost == null) {
            try {
                proxyHost    = System.getProperty("http.proxyHost");
                proxyPortStr = System.getProperty("http.proxyPort");
            } catch (SecurityException se) {
                // in unsigned applet - oh well
            }
        }

        /* parse the port */
        int proxyPort = 0;
        if (proxyPortStr != null) {
            try {
                proxyPort = Integer.parseInt(proxyPortStr);
            } catch (NumberFormatException e) {
                System.err.println("Error parsing proxy port string '" +
                                   proxyPortStr + "'");
                e.printStackTrace();
            }
        } else
            proxyPort = 80;

        /* check for invalid config */
        if (proxyHost != null && proxyPort == 0) {
            System.out.println("Incomplete proxy parameter list (missing port)");
            proxyHost = null;
        }

        /* create the socket */
        Socket sock;

        if (proxyHost != null) {
            sock = factory.createSocket(proxyHost, proxyPort, params);

            System.out.println("HTTP CONNECT to " + host + " port " + port +
                               " via proxy " + proxyHost + " port " + proxyPort);

            String user = params.get("PROXYUSER");
            String pass = params.get("PROXYPASS");
            doConnect(sock, host, port, user, pass);
        } else {
            sock = factory.createSocket(host, port, params);
        }

        return sock;
    }

    private void doConnect(Socket sock, String host, int port, String user,
                           String pass) throws IOException {

        // Send the CONNECT request
        String req = "CONNECT " + host + ":" + port + " HTTP/1.0\r\n";
        if (user != null && pass != null)
            req += "Proxy-Authorization: Basic " + Base64.encode(user + ":" + pass) + "\r\n";
        req += "\r\n";

        sock.getOutputStream().write(req.getBytes("ISO-8859-1"));

        // Read the first line of the response
        DataInputStream is = new DataInputStream(sock.getInputStream());
        String line = is.readLine();

        // Check the HTTP response code
        int spc = line.indexOf(' ');
        if (!line.startsWith("HTTP/1.") || spc < 0)
            throw new IOException("Invalid proxy response \"" + line + "\"");

        String str = line.substring(spc + 1).trim();
        spc = str.indexOf(' ');
        if (spc < 0)
            throw new IOException("Invalid proxy response \"" + line + "\"");

        String sts = str.substring(0, spc);
        if (!sts.equals("200"))
            throw new IOException("Proxy reports \"" + str + "\"");

        // Success -- skip remaining HTTP headers
        do {
            line = is.readLine();
        } while (line.length() != 0);
    }
}
