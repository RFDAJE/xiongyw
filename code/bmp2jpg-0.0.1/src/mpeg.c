#if (0)
/*
** Copyright (C) 2004 Yuwu (Bruin) Xiong <xiongyw@hotmail.com>
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

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif


/* created(bruin, 2002.12.03) */

/* default luminance quantization table for intra coding */
static unsigned char s_std_lumin_qt[8][8] = {
    { 8, 16, 19, 22, 26, 27, 29, 34},
    {16, 16, 22, 24, 27, 29, 34, 37},
    {19, 22, 26, 27, 29, 34, 34, 38},
    {22, 22, 26, 27, 29, 34, 37, 40},
    {22, 26, 27, 29, 32, 35, 40, 48},
    {26, 27, 29, 32, 35, 40, 48, 58},
    {26, 27, 29, 34, 38, 46, 56, 69},
    {27, 29, 35, 38, 46, 56, 69, 83}
};

/* DC code tables for luminance and chrominance */
static HUFF_ENTRY s_lumin_dc[12] = {
    { 3, 0x0004}, /*              100 */
    { 2, 0x0000}, /*               00 */
    { 2, 0x0001}, /*               01 */
    { 3, 0x0005}, /*              101 */
    { 3, 0x0006}, /*              110 */
    { 4, 0x000e}, /*             1110 */
    { 5, 0x001e}, /*            11110 */
    { 6, 0x003e}, /*           111110 */
    { 7, 0x007e}, /*          1111110 */
    { 8, 0x00fe}, /*         11111110 */
    { 9, 0x01fe}, /*        111111110 */
    { 9, 0x01ff}  /*        111111111 */
};

static HUFF_ENTRY s_chrom_dc[12] = {
    { 2, 0x0000}, /*               00 */
    { 2, 0x0001}, /*               01 */
    { 2, 0x0002}, /*               10 */
    { 3, 0x0006}, /*              110 */
    { 4, 0x000e}, /*             1110 */
    { 5, 0x001e}, /*            11110 */
    { 6, 0x003e}, /*           111110 */
    { 7, 0x007e}, /*          1111110 */
    { 8, 0x00fe}, /*         11111110 */
    { 9, 0x01fe}, /*        111111110 */
    {10, 0x03fe}, /*       1111111110 */
    {11, 0x03ff}  /*       1111111111 */
};


/* AC huffman code table for luminance and chrominance */
/* TBD */




/* start codes for MPEG system syntax:
   the system and video layers contain unique 4-byte start codes,
   which start certain high-level segments of the bitstream.
   the start codes all have a 3-byte prefix "0x00, 0x00, 0x01",
   the final byte (called start code value) then identifies the
   particular start code.
*/

/* video start code values */
#define PICTURE_START_CODE           0x00
#define SLICE_START_CODE_FIRST       0x01 /* 0x01-0xaf are all slice start code values */
#define SLICE_START_CODE_LAST        0xaf
/* 0xb0, 0xb1 are reserved */     
#define USER_DATA_START_CODE         0xb2
#define SEQUENCE_HEADER_CODE         0xb3
#define SEQUENCE_ERROR_CODE          0xb4
#define EXTENSION_START_CODE         0xb5
/* 0xb6 is reserved */
#define SEQUENCE_END_CODE            0xb7
#define GROUP_START_CODE             0xb8

/* system start code values */
#define ISO_11172_END_CODE           0xb9
#define PACK_START_CODE              0xba
#define SYSTEM_HEADER_START_CODE     0xbb

/* packet start code values: stream_id */
/* 0xbc is for reserved stream */
#define PRIVATE_STREAM_1             0xbd
#define PADDING_STREAM               0xbe
#define PRIVATE_STREAM_2             0xbf
#define AUDIO_STREAM_FIRST           0xc0 /* 0xc0-0xdf are all for audio streams */
#define AUDIO_STREAM_LAST            0xdf
#define VIDEO_STREAM_FIRST           0xe0 /* 0xe0-0xef are all for video streams */
/* 0xf0-0xff are for reserved stream */


/*  

  ISO/IEC 11172-2 video syntax (MPEG-1)
  =====================================

                  +----------------+
                  | video_sequence |
                  +----------------+
                 /                  \________________________________________________
                /                         (optional)                                 \
               +----------+---+---+------+- - - - - +---------------/ /--+------------+
sequence layer |seq_header|gop|gop|......|seq_header|gop|gop|....../ /   |seq_end_code| 
               +----------+---+---+------+- - - - - +---+---+-----/ /----+------------+
                 ________/     \_____________________________         
                /                                            \
               +----------+-------+-------+-------/ /-+-------+
gop layer      |gop_header|picture|picture|....../ /  |picture|
               +----------+-------+-------+-----/ /---+-------+
                 ________/         \_________________________
                /                                            \
               +----------+-------+-------+-------/ /-+-------+
picture layer  |pic_header| slice | slice |....../ /  | slice |
               +----------+-------+-------+-----/ /---+-------+
                 ________/         \______________________________
                /                                                 \
               +------------+--------+--------+-------/ /-+--------+
slice layer    |slice_header|macroblk|marcoblk|....../ /  |macroblk|
               +------------+--------+--------+-----/ /---+--------+
                 __________/          \_________________________________
                /                                                       \
               +---------------+------+------+------+------+------+------+
macroblk layer |macroblk_header|blk(0)|blk(1)|blk(2)|blk(3)|blk(4)|blk(5)|
               +---------------+------+------+------+------+------+------+
                 _____________/        \___________________________________
                /                                                          \
               +- - - - - - -+-------+-------+-------/ /-+-------+----------+
block layer    |delta_dc_coef|rle_vlc|rle_vlc|....../ /  |rle_vlc|end_of_blk|
               +- - - - - - -+-------+-------+-----/ /---+-------+----------+
              (I-picture only)



  ISO/IEC 13818-2 video syntax (MPEG-2)
  =====================================

                  +----------------+
                  | video_sequence |
                  +----------------+
                 /                  \______________________________________________
                /                                                                  \
               +----------+-------+------------+- - - - - +- - - - - - +------------+
sequence layer |seq_header|seq_ext|gop_and_pics|seq_header|gop_and_pics|seq_end_code| 
               +----------+-------+------------+- - - - - +- - - - - - +------------+
                 ________________/              \_____________________         
                /                                                     \
               +- - - - - +- - - - +-------+-------+-------/ /-+-------+
gop layer      |gop_header|usr_data|picture|picture|....../ /  |picture|
               +- - - - - +- - - - +-------+-------+-----/ /---+-------+
                 _________________/         \_______________________________________
                /                                                                   \
               +----------+--------------+----------------+------+-------/ /-+-------+
picture layer  |pic_header|pic_coding_ext|ext_and_usr_data|slice |....../ /  | slice |
               +----------+--------------+----------------+------+-----/ /---+-------+
                 ________________________________________/       \
                /                                                 \
               +------------+--------+--------+-------/ /-+--------+
slice layer    |slice_header|macroblk|marcoblk|....../ /  |macroblk|
               +------------+--------+--------+-----/ /---+--------+
                 __________/          \_________________________________
                /                                                       \
               +---------------+------+------+------+------+------+------+
macroblk layer |macroblk_header|blk(0)|blk(1)|blk(2)|blk(3)|blk(4)|blk(5)|
               +---------------+------+------+------+------+------+------+
                 _____________/        \___________________________________
                /                                                          \
               +- - - - - - -+-------+-------+-------/ /-+-------+----------+
block layer    |delta_dc_coef|rle_vlc|rle_vlc|....../ /  |rle_vlc|end_of_blk|
               +- - - - - - -+-------+-------+-----/ /---+-------+----------+
              (I-picture only)
 
*/

#endif
