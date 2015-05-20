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

#ifndef __TABLE_ID_H__
#define __TABLE_ID_H__

typedef struct {
    PRIV_SECT_HEADER value;
    PRIV_SECT_HEADER mask;
} SECT_FILTER;


#endif 

