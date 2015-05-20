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
    filter.mask.field = -1; \
    )

/*
 * added(bruin, 2015-05-19): subtable extra ids:
 *
 *       | table_id_extension |
 *       |    (16 bit)        | payload part
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

#define SETUP_SECT_FILTER_4_NIT_ACT(filter, nid) STMT( \
	memset(&filter, 0, sizeof(SECT_FILTER)); \
	// todo: if nid==0, not check nid \
	SETUP_SECT_FILETER(filter, table_id, TID_NIT_ACT); \
	SETUP_SECT_FILETER(filter, table_id_extension_hi, (nid >> 8)); \
	SETUP_SECT_FILETER(filter, table_id_extension_lo, (nid & 0x00ff)); \
	) 

#define SETUP_SECT_FILTER_4_NIT_OTH(filter, nid) STMT( \
	memset(&filter, 0, sizeof(SECT_FILTER)); \
	// todo: if nid==0, not check nid \
	SETUP_SECT_FILETER(filter, table_id, TID_NIT_OTH); \
	SETUP_SECT_FILETER(filter, table_id_extension_hi, (nid >> 8)); \
	SETUP_SECT_FILETER(filter, table_id_extension_lo, (nid & 0x00ff)); \
	) 

#define SETUP_SECT_FILTER_4_BAT(filter, bid) STMT( \
	memset(&filter, 0, sizeof(SECT_FILTER)); \
	SETUP_SECT_FILETER(filter, table_id, TID_BAT); \
	SETUP_SECT_FILETER(filter, table_id_extension_hi, (bid >> 8)); \
	SETUP_SECT_FILETER(filter, table_id_extension_lo, (bid & 0x00ff)); \
	) 

#define SETUP_SECT_FILTER_4_SDT_ACT(filter, onid, tsid) STMT( \
	memset(&filter, 0, sizeof(SECT_FILTER)); \
	SETUP_SECT_FILETER(filter, table_id, TID_SDT_ACT); \
	SETUP_SECT_FILETER(filter, table_id_extension_hi, (tsid >> 8)); \
	SETUP_SECT_FILETER(filter, table_id_extension_lo, (tsid & 0x00ff)); \
	SETUP_SECT_FILETER(filter, payload_bytes[0], (onid >> 8)); \
	SETUP_SECT_FILETER(filter, payload_bytes[1], (onid & 0x00ff)); \
	) 

#define SETUP_SECT_FILTER_4_SDT_OTH(filter, onid, tsid) STMT( \
	memset(&filter, 0, sizeof(SECT_FILTER)); \
	SETUP_SECT_FILETER(filter, table_id, TID_SDT_OTH); \
	SETUP_SECT_FILETER(filter, table_id_extension_hi, (tsid >> 8)); \
	SETUP_SECT_FILETER(filter, table_id_extension_lo, (tsid & 0x00ff)); \
	SETUP_SECT_FILETER(filter, payload_bytes[0], (onid >> 8)); \
	SETUP_SECT_FILETER(filter, payload_bytes[1], (onid & 0x00ff)); \
	) 

#define SETUP_SECT_FILTER_4_EIT_ACT(filter, onid, tsid, svcid) STMT( \
	memset(&filter, 0, sizeof(SECT_FILTER)); \
	SETUP_SECT_FILETER(filter, table_id, TID_EIT_ACT); \
	SETUP_SECT_FILETER(filter, table_id_extension_hi, (svcid >> 8)); \
	SETUP_SECT_FILETER(filter, table_id_extension_lo, (svcid & 0x00ff)); \
	SETUP_SECT_FILETER(filter, payload_bytes[0], (tsid >> 8)); \
	SETUP_SECT_FILETER(filter, payload_bytes[1], (tsid & 0x00ff)); \
	SETUP_SECT_FILETER(filter, payload_bytes[2], (onid >> 8)); \
	SETUP_SECT_FILETER(filter, payload_bytes[3], (onid & 0x00ff)); \
	) 

#define SETUP_SECT_FILTER_4_EIT_OTH(filter, onid, tsid, svcid) STMT( \
	memset(&filter, 0, sizeof(SECT_FILTER)); \
	SETUP_SECT_FILETER(filter, table_id, TID_EIT_OTH); \
	SETUP_SECT_FILETER(filter, table_id_extension_hi, (svcid >> 8)); \
	SETUP_SECT_FILETER(filter, table_id_extension_lo, (svcid & 0x00ff)); \
	SETUP_SECT_FILETER(filter, payload_bytes[0], (tsid >> 8)); \
	SETUP_SECT_FILETER(filter, payload_bytes[1], (tsid & 0x00ff)); \
	SETUP_SECT_FILETER(filter, payload_bytes[2], (onid >> 8)); \
	SETUP_SECT_FILETER(filter, payload_bytes[3], (onid & 0x00ff)); \
	) 

#define SETUP_SECT_FILTER_4_EIT_ACT_SCH(filter, onid, tsid, svcid) STMT( \
	memset(&filter, 0, sizeof(SECT_FILTER)); \
	SETUP_SECT_FILETER(filter, table_id, TID_EIT_ACT_SCH); \
	SETUP_SECT_FILETER(filter, table_id_extension_hi, (svcid >> 8)); \
	SETUP_SECT_FILETER(filter, table_id_extension_lo, (svcid & 0x00ff)); \
	SETUP_SECT_FILETER(filter, payload_bytes[0], (tsid >> 8)); \
	SETUP_SECT_FILETER(filter, payload_bytes[1], (tsid & 0x00ff)); \
	SETUP_SECT_FILETER(filter, payload_bytes[2], (onid >> 8)); \
	SETUP_SECT_FILETER(filter, payload_bytes[3], (onid & 0x00ff)); \
	) 

#define SETUP_SECT_FILTER_4_EIT_OTH_SCH(filter, onid, tsid, svcid) STMT( \
	memset(&filter, 0, sizeof(SECT_FILTER)); \
	SETUP_SECT_FILETER(filter, table_id, TID_EIT_OTH_SCH); \
	SETUP_SECT_FILETER(filter, table_id_extension_hi, (svcid >> 8)); \
	SETUP_SECT_FILETER(filter, table_id_extension_lo, (svcid & 0x00ff)); \
	SETUP_SECT_FILETER(filter, payload_bytes[0], (tsid >> 8)); \
	SETUP_SECT_FILETER(filter, payload_bytes[1], (tsid & 0x00ff)); \
	SETUP_SECT_FILETER(filter, payload_bytes[2], (onid >> 8)); \
	SETUP_SECT_FILETER(filter, payload_bytes[3], (onid & 0x00ff)); \
	) 


#define SETUP_SECT_FILTER_4_PAT(filter, tsid) STMT( \
	memset(&filter, 0, sizeof(SECT_FILTER)); \
	SETUP_SECT_FILETER(filter, table_id, TID_PAT); \
	SETUP_SECT_FILETER(filter, table_id_extension_hi, (tsid >> 8)); \
	SETUP_SECT_FILETER(filter, table_id_extension_lo, (tsid & 0x00ff)); \
	) 

#define SETUP_SECT_FILTER_4_PMT(filter, progid) STMT( \
	memset(&filter, 0, sizeof(SECT_FILTER)); \
	SETUP_SECT_FILETER(filter, table_id, TID_PMT); \
	SETUP_SECT_FILETER(filter, table_id_extension_hi, (progid >> 8)); \
	SETUP_SECT_FILETER(filter, table_id_extension_lo, (progid & 0x00ff)); \
	) 

#define SETUP_SECT_FILTER_4_AIT(filter, apptype) STMT( \
	memset(&filter, 0, sizeof(SECT_FILTER)); \
	SETUP_SECT_FILETER(filter, table_id, TID_AIT); \
	SETUP_SECT_FILETER(filter, table_id_extension_hi, (apptype >> 8)); \
	SETUP_SECT_FILETER(filter, table_id_extension_lo, (apptype & 0x00ff)); \
	) 


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

