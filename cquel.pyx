##
##  python-cquel - Python bindings for Delwink's cquel
##  Copyright (C) 2014-2015 Delwink, LLC
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

from cython import address
from libc.stdlib cimport calloc, free
from libc.stdio cimport snprintf
cimport cquelso as so

QLEN = 0
FMAXLEN = 0

def tou8(s):
    return s.encode('utf-8')

def fromu8(b):
    return b.decode('utf-8')

cdef char **alloc_strarr(in_arr, blen=0):
    size = len(in_arr)
    cdef char **out_arr = <char **>calloc(size, sizeof(char *))
    cdef char *tempb
    if out_arr is NULL:
        raise MemoryError()
    fail = 0
    for i in range(0, size):
        b = tou8(in_arr[i])
        if blen:
            out_arr[i] = <char *>calloc(blen, sizeof(char))
            if out_arr[i] is NULL:
                fail = i
                break
            tempb = b
            rc = snprintf(out_arr[i], blen, b'%s', tempb)
            if rc >= blen:
                fail = i
                break
        else:
            out_arr[i] = b
    if fail:
        for i in range(0, fail):
            free(out_arr[i])
        free(out_arr)
        raise MemoryError()
    return out_arr

cdef void free_all(char **arr, arrlen):
    for i in range(0, arrlen):
        free(arr[i])
    free(arr)

class ConnectionError(Exception):
    pass

def init(qlen, fmaxlen):
    so.cq_init(qlen, fmaxlen)
    QLEN = qlen
    FMAXLEN = fmaxlen

cdef class DataList:
    cdef so.dlist *_list
    def __cinit__(self, fieldc, fieldnames, primkey=''):
        cdef char **cfields = alloc_strarr(fieldnames, blen=FMAXLEN)
        cprimkey = tou8(primkey)
        self._list = so.cq_new_dlist(fieldc, cfields, cprimkey)
        free_all(cfields, len(fieldnames))
        if self._list is NULL:
            raise Exception('Memory or value error creating DataList')

    def __dealloc__(self):
        so.cq_free_dlist(self._list)

    def size(self):
        return so.cq_dlist_size(self._list)

    def add_row(self, values):
        cdef so.drow *row = so.cq_new_drow(self._list.fieldc)
        if row is NULL:
            raise MemoryError()
        cdef char **cvals
        try:
            cvals = alloc_strarr(values, blen=FMAXLEN)
        except:
            so.cq_free_drow(row)
            raise MemoryError()
        so.cq_drow_set(row, cvals)
        so.cq_dlist_add(self._list, row)
        free_all(cvals, len(values))

    def remove_field_str(self, key):
        ckey = tou8(key)
        rc = so.cq_dlist_remove_field_str(self._list, ckey)
        if rc:
            raise KeyError('Field not found in this list')

    def remove_field_at(self, index):
        rc = so.cq_dlist_remove_field_at(self._list, index)
        if rc:
            raise IndexError()

    def row_at(self, index):
        cdef so.drow *row
        row = so.cq_dlist_at(self._list, index)
        if row is NULL:
            raise IndexError()
        values = []
        for i in range(0, row.fieldc):
            pyval = fromu8(row.values[i])
            values.append(pyval)
        return values

cdef class DatabaseConnection:
    cdef so.dbconn _con
    def __cinit__(self, host, user, passwd, database):
        self._con = so.cq_new_connection(tou8(host), tou8(user), tou8(passwd),
                tou8(database))

    def connect(self):
        rc = so.cq_connect(address(self._con))
        if rc:
            raise ConnectionError('Failed to connect to the database.')

    def close(self):
        so.cq_close_connection(address(self._con))

    def test(self):
        try:
            self.connect()
        except:
            return False
        self.close()
        return True
