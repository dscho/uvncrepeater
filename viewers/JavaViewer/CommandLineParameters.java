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

import java.util.HashMap;
import java.util.Map;

/**
 * This represents a set of parameters from the command line.
 */
public class CommandLineParameters implements Parameters {
    private final Map params;

    /**
     * Create a new set of parameters from the given command line. The arguments
     * are assumed to come in pairs, name followed by value. If an odd number of
     * arguments is given, the last argument is dropped.
     *
     * @param args the command line
     */
    public CommandLineParameters(String[] args) {
        params = new HashMap();

        int num = (args.length & 1) == 1 ? args.length - 1 : args.length;
        for (int idx = 0; idx < num; idx += 2) {
            params.put(args[idx].toLowerCase(), args[idx + 1]);
        }
    }

    public String get(String name) {
        return (String) params.get(name.toLowerCase());
    }
}
