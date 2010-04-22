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

import java.io.ByteArrayInputStream;
import java.io.DataInputStream;
import java.io.IOException;
import java.net.Socket;
import java.security.GeneralSecurityException;
import java.security.cert.X509Certificate;
import java.security.cert.CertificateException;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.util.Collection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSocket;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

/**
 * Establishes a client ssl session.
 */
class SSLClientSocketFactory implements SocketFactory {
    private SocketFactory factory;

    public SSLClientSocketFactory(SocketFactory nextFactory) {
        factory = nextFactory;
    }

    /**
     * Create an ssl socket to the given host and port. The following parameters
     * are read from <var>params</var>:
     * <dl>
     *   <dt>USESSL
     *   <dd>If not set a plain socket is created
     *   <dt>SERVERCERT
     *   <dd>the server certificate to expect (in standard PEM format); if set,
     *       any other server certificate is rejected
     *   <dt>TRUSTALL
     *   <dd>don't check the server certificate at all
     * </dl>
     *
     * @param host   the id to use
     * @param port   ignored
     * @param params the parameters
     */
    public Socket createSocket(String host, int port, Parameters params)
        throws IOException {
        if (params.get("USESSL") == null)
            return factory.createSocket(host, port, params);

        /* set up our trust management */
        SSLContext sslContext;
        try {
            TrustManager[] tm = null;
            if (params.get("SERVERCERT") != null || params.get("TRUSTALL") != null)
                tm = new TrustManager[] { new MyX509TrustManager(params) };

            sslContext = SSLContext.getInstance("SSL");
            sslContext.init(null, tm, null);
        } catch (GeneralSecurityException gse) {
            gse.printStackTrace();
            throw new IOException("Error setting ssl context: " + gse);
        }

        /* create the socket */
        Socket sock = factory.createSocket(host, port, params);
        System.out.println("Starting SSL with " + host + " port " + port);
        SSLSocket sslsock = (SSLSocket)
            sslContext.getSocketFactory().createSocket(sock, host, port, true);
        sslsock.startHandshake();

        return sslsock;
    }


    private static class MyX509TrustManager implements X509TrustManager {
        private X509Certificate trustedCert;

        public MyX509TrustManager(Parameters params) throws IOException {
            /* see if there's a trusted cert */
            String certStr = params.get("SERVERCERT");
            if (certStr != null) {
                try
                {
                    CertificateFactory fac = CertificateFactory.getInstance("X.509");
                    Collection certs = fac.generateCertificates(
                            new ByteArrayInputStream(certStr.getBytes("ISO-8859-1")));
                    if (!certs.isEmpty())
                        trustedCert = (X509Certificate) certs.iterator().next();
                }
                catch (CertificateException ce)
                {
                    ce.printStackTrace();
                }
            }
        }

        public X509Certificate[] getAcceptedIssuers() {
            return null;
        }

        public void checkClientTrusted(X509Certificate[] chain, String str) {
        }

        public void checkServerTrusted(X509Certificate[] chain, String str)
            throws CertificateException {
            if (trustedCert != null && !trustedCert.equals(chain[0]))
                throw new CertificateException("Untrusted server certificate: " + chain[0]);
        }
    }
}
