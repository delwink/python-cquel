##
##  python-cquel - Python bindings for Delwink's cquel
##  Copyright (C) 2014 Delwink, LLC
##
##  This program is free software: you can redistribute it and/or modify
##  it under the terms of the GNU Affero General Public License as published by
##  the Free Software Foundation.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU Affero General Public License for more details.
##
##  You should have received a copy of the GNU Affero General Public License
##  along with this program.  If not, see <http://www.gnu.org/licenses/>.
##

import cython
cimport cquelso as so

def u8(s):
    return s.encode('utf-8')

class ConnectionError(Exception):
    pass

def init(qlen, fmaxlen):
    so.cq_init(qlen, fmaxlen)

cdef class DatabaseConnection:
    cdef so.dbconn _con
    def __cinit__(self, host, user, passwd, database):
        self._con = so.cq_new_connection(u8(host), u8(user), u8(passwd),
                u8(database))

    def connect(self):
        rc = so.cq_connect(cython.address(self._con))
        if rc:
            raise ConnectionError('Failed to connect to the database.')

    def close(self):
        so.cq_close_connection(cython.address(self._con))

    def test(self):
        try:
            self.connect()
        except:
            return False
        self.close()
        return True
