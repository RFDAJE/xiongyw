/*
** Copyright (C) 2015 Yuwu Xiong <5070319@qq.com>
**  
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
** (at your option) any later version.
** 
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
** 
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software 
** Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
*/

/* 
 * created(bruin, 2015/05/20): utility for filtering sections
 */
#include "si.h"
#include "section_filter.h"

#define STMT(stuff)            do { stuff } while(0)

#define SETUP_SECT_FILETER(filter, field, value) STMT(\
    filter.value.field = value; \
    filter.mask.field = -1; )

/*
 * added(bruin, 2015-05-19): subtable extra ids (to be verified):
 *
 *       | table_id_extension |
 *       |    (16 bit)        | after the generic section header
 * ------+--------------------+---------------------------------------
 *  NIT  |  network id        |
 * ------+--------------------+---------------------------------------
 *  BAT  |  bouquet id        |
 * ------+--------------------+---------------------------------------
 *  SDT  |  ts id             | onid (16bit)
 * ------+--------------------+---------------------------------------
 *  EIT  |  svc id            | tsid (16bit) + onid (16bit)
 * ------+--------------------+---------------------------------------
 *
 * ------+--------------------+---------------------------------------
 *  PAT  |  ts id             |
 * ------+--------------------+---------------------------------------
 *  PMT  |  prog_nr           |
 * ------+--------------------+---------------------------------------
 *  AIT  |  app_type          |
 * ------+--------------------+---------------------------------------
 *
 * ------+--------------------+---------------------------------------
 * DSM-CC| transaction id     | if tid=0x3B
 * ------+--------------------+---------------------------------------
 * DSM-CC| module id          | if tid=0x3C
 * ------+--------------------+---------------------------------------
 */


//int section_filter_setup_for_nit(SECT_FILTER* filter, u16 nid)
//{
//}




/*
 * compare *buf with *value, masking out bit indicated in *mask.
 * all three buffers should of length 'len'.
 *
 * - buf: the buffer to check
 * - value: the desired the values to compare with
 * - mask: the mask for both buf and value
 * - len: length for 3 buffers (buf,mask,value)
 *
 * return 0 if match, otherwise not match
 */
int filter_buffer(u8* value, u8* buf, u8* mask, int len)
{
    int i;
    
    for (i = 0; i < len; i ++) {
        if ((buf[i] & mask[i]) != (value[i] & mask[i]))
            return 1;
    }

    return 0;
}

