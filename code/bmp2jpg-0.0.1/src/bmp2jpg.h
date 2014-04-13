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


/* created(bruin, 2002.11.24) */

#ifndef __BMP2JPG_H__
#define __BMP2JPG_H__

#include <stdio.h>

/*--------------------------------------------------------------------+
 |                                                                    |
 | type/structure definitions                                         |
 |                                                                    |
 +--------------------------------------------------------------------*/
 
#pragma pack(1)



/*--------------------------------------------------------------------+
 | COMMON data type                                                   |
 +--------------------------------------------------------------------*/
 
typedef unsigned char  BYTE;
typedef unsigned short WORD;
typedef unsigned long  DWORD;
typedef long           LONG;

#ifndef FALSE
#define FALSE		   0
#endif

#ifndef TRUE
#define TRUE		   (!FALSE)
#endif

#define MAX(a, b)      ((a > b)? (a) : (b))
#define MIN(a, b)      ((a > b)? (b) : (a))

/*--------------------------------------------------------------------+
 | BMP stuff                                                          |
 +--------------------------------------------------------------------*/

/* BMP stuff: some BMP HEADER structure definitions are just copied 
   from windows and redefined, for portability on other platforms */
typedef struct{
    WORD    bfType;
    DWORD   bfSize;
    WORD    bfReserved1;
    WORD    bfReserved2;
    DWORD   bfOffBits;
}xBITMAPFILEHEADER;

typedef struct{
    BYTE    rgbBlue;
    BYTE    rgbGreen;
    BYTE    rgbRed;
    BYTE    rgbReserved;
}xRGBQUAD;

typedef struct{
    DWORD  biSize;
    LONG   biWidth;
    LONG   biHeight;
    WORD   biPlanes;
    WORD   biBitCount;
    DWORD  biCompression;
    DWORD  biSizeImage;
    LONG   biXPelsPerMeter;
    LONG   biYPelsPerMeter;
    DWORD  biClrUsed;
    DWORD  biClrImportant;
}xBITMAPINFOHEADER;

typedef struct{
    xBITMAPINFOHEADER bmiHeader;
    xRGBQUAD          bmiColors[1];
}xBITMAPINFO;

/* constants for the biCompression field */
#define xBI_RGB        0L
#define xBI_RLE8       1L
#define xBI_RLE4       2L
#define xBI_BITFIELDS  3L



typedef enum{
    BMP_NO_ERROR = 0x00,
    BMP_FORMAT_ERROR,
    BMP_X_OUT_OF_RANGE,
    BMP_Y_OUT_OF_RANGE,
    BMP_WRONG_BITCOUNT,
    BMP_NOT_SUPPORT
}BMP_ERROR_CODE;


/*--------------------------------------------------------------------+
 | JPEG stuff                                                         |
 +--------------------------------------------------------------------*/

/* NOTE: almost every JPEG file uses sequential jpeg with huffman 
         encoding and 8-bit sample data 

   JPEG modes:
   +-------------------------------------------------------------------------+
   |                                 JPEG                                    | 
   +---------------------+---------------------+----------------+------------+
   |     sequential      |   progressive       |     lossless   |hierarchical|
   +----------+----------+----------+----------+--------+-------+            |
   | huffman  |arithmetic| huffman  |arithmetic|original|jpeg-ls|            |
   +----+-----+----+-----+----+-----+----+-----+lossless|       |            |
   |8bit|12bit|8bit|12bit|8bit|12bit|8bit|12bit|        |       |            |
   +----+-----+----+-----+----+-----+----+-----+--------+-------+------------+
*/

/* MARKERs in jpeg file format, all in 2 bytes with the first byte 0xFF */
/* Start Of Frame markers, for huffman coding */
#define   SOF0   0xc0       /* baseline DCT */
#define   SOF1   0xc1       /* extended sequential DCT */
#define   SOF2   0xc2       /* progressive DCT */
#define   SOF3   0xc3       /* spatial(sequential) lossless */
#define   SOF5   0xc5       /* differential sequential DCT */
#define   SOF6   0xc6       /* differential progressive DCT */
#define   SOF7   0xc7       /* differential spatial lossless */
/* Start Of Frame markers, for arithmetic coding */
#define   JPG    0xc8       /* reserved for jpeg extensions */
#define   SOF9   0xc9       /* extended sequential DCT */
#define   SOF10  0xca       /* progressive DCT */
#define   SOF11  0xcb       /* spatial(sequential) lossless */
#define   SOF13  0xcd       /* differential sequential DCT */
#define   SOF14  0xce       /* differential progressive DCT */
#define   SOF15  0xcf       /* differential spatial lossless */

#define   DHT    0xc4       /* Define Huffman Table */
#define   DAC    0xcc       /* Define Arithmetic Conditioning Table */

#define   RST0   0xd0       /* Restart Markers, rarely used */
#define   RST1   0xd1
#define   RST2   0xd2
#define   RST3   0xd3
#define   RST4   0xd4
#define   RST5   0xd5
#define   RST6   0xd6
#define   RST7   0xd7
#define   SOI    0xd8       /* Start Of Image */
#define   EOI    0xd9       /* End Of Image */
#define   SOS    0xda       /* Start Of Scan */
#define   DQT    0xdb       /* Define Quantization Table */
#define   DNL    0xdc       /* Define Number of Lines */
#define   DRI    0xdd       /* Define Restart Interval */
#define   DHP    0xde       /* Define Hierarchical Progress */
#define   EXP    0xdf       /* Expand Reference image(s) */

/* markers reserved for application use: 0xffe0 - 0xffef */
#define   APP0   0xe0       /* JPG file uses the JFIF specification */
/* markers reserved for JPEG extensions: 0xfff0 - 0xfffd */
#define   JPG0   0xf0
#define   COM    0xfe       /* Comment */


/* structure holding Y/U/V components of an image, which use fixed
   sampling factor 2x2 for Y (luminance), and 1x1 for U/V (chrominance).
   this is also the standard sampling scheme used in MPEG. using this
   sampling scheme, each pixel will only require 12 bit to record the color,
   so we name it YUV12.

   for each component, a DU (data unit) in JPEG represents a 8x8 byte matrix,
   by using huffman coding the zigzaged 64 FDCT coefficients; 

   by using the YUV12 sampling scheme, a MCU (minium coded unit) in JPEG 
   represents a 16x16 (pixel) image block, by using 6 DUs in this sequence: 
   YDU, YDU, YDU, YDU, UDU, VDU.  
   
   a 16x16 image block is also called a "macroblock" in MPEG standard.
*/
typedef struct{
    WORD row0;  /* original size */
    WORD col0;
    
    WORD row;   /* new size can be MCU (16x16) dividable */
    WORD col;
    
    /* two dimensional array holding each components.*/
    char** y;
    char** u;
    char** v;
}YUV12;



/* entry in huffman table: the entry index is the symbol value */
typedef struct{
    BYTE  size;  /* number of bits of the huffman code. <= 16 */
    WORD  code;  /* huffman code in the least signficant bits */
}HUFF_ENTRY;





/*--------------------------------------------------------------------+
 |                                                                    |
 | exported routines' declarations                                    |
 |                                                                    |
 +--------------------------------------------------------------------*/

#ifdef __cplusplus
extern "C"{
#endif

/*--------------------------------------------------------------------+
 | bmp2jpeg.c                                                         |
 +--------------------------------------------------------------------*/

DWORD  bmp_get_rgb_of_pixel(BYTE* pbmp, WORD row, WORD col);
YUV12* bmp_rgb_to_yuv12(BYTE* pbmp); 
void   free_yuv12(YUV12* yuv);
int    util_get_coord_map(WORD row0, WORD col0, WORD row, WORD col, WORD** prow, WORD** pcol);
int    fwd_dct(char** array, WORD row_start, WORD col_start, int* vector);
int    encode_du(char is_lumin, int pre_dc, int vector[64], BYTE du[128]);
void   quantise(int* vector, BYTE is_lumin);
BYTE*  get_std_segment(BYTE marker, int *size, WORD p1, WORD p2);
int    cal_dht(BYTE bits[16], BYTE* huffval, HUFF_ENTRY* dht);
void   re_cal_dht(void);
void   write_bits_to_file(int size, BYTE* p, FILE* fp, int if_flush);
int    bmp2jpeg(BYTE* pbmp, FILE* fp);

/*--------------------------------------------------------------------+
 | fwd_dct.c                                                          |
 +--------------------------------------------------------------------*/
void   j_fwd_dct (short* data);

#ifdef __cplusplus
}
#endif


#endif /* __BMP2JPG_H__ */
