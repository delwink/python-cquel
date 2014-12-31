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

cdef extern from "cquel.h":
    void cq_init(size_t qlen, size_t fmaxlen)

    struct dbconn:
        pass

    dbconn cq_new_connection(const char *host, const char *user,
            const char *passwd, const char *database)

    int cq_connect(dbconn *con)

    void cq_close_connection(dbconn *con)

    int cq_test(dbconn con)

    struct drow:
        size_t fieldc
        char **values
        drow *next
        drow *prev

    drow *cq_new_drow(size_t fieldc)

    void cq_free_drow(drow *row)

    int cq_drow_set(drow *row, char * const *values)

    struct dlist:
        size_t fieldc
        char **fieldnames
        char *primkey
        drow *first
        drow *last

    dlist *cq_new_dlist(size_t fieldc, char * const *fieldnames,
            const char *primkey)

    size_t cq_dlist_size(const dlist *list)

    void cq_free_dlist(dlist *list)

    void cq_dlist_add(dlist *list, drow *row)

    dlist *cq_dlist_append(dlist **dest, dlist *src)

    void cq_dlist_remove(dlist *list, drow *row)

    int cq_dlist_remove_field_str(dlist *list, const char *field)

    int cq_dlist_remove_field_at(dlist *list, size_t index)

    drow *cq_dlist_at(const dlist *list, size_t index)

    int cq_field_to_index(const dlist *list, const char *field, size_t *out)

    int cq_insert(dbconn con, const char *table, const dlist *list)

    int cq_select_query(dbconn con, dlist **out, const char *query)

    int cq_select_all(dbconn con, const char *table, dlist **out,
            const char *conditions)

    int cq_select_func_arr(dbconn con, const char *func, char * const *args,
            size_t num_args, dlist **out)

    int cq_select_func_drow(dbconn con, const char *func, drow row, dlist **out)

    int cq_get_primkey(dbconn con, const char *table, char *out, size_t len)

    int cq_get_fields(dbconn con, const char *table, size_t *out_fieldc,
            char **out_names, size_t nblen)

    int cq_proc_arr(dbconn con, const char *proc, size_t num_args)

    int cq_proc_drow(dbconn con, const char *proc, drow row)

    int cq_grant(dbconn con, const char *perms, const char *table,
            const char *user, const char *host, const char *extra)

    int cq_revoke(dbconn con, const char *perms, const char *table,
            const char *user, const char *host, const char *extra)
