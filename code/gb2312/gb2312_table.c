/* 
 * The following is taken from <http://www.herongyang.com/gb2312/overview.html> with slight modification.
 *
 * GB2312-80 Character Set
 * ----------------------- 
 *
 * GB: An abbreviation of Guojia Biaozhun, or Guo Biao, meaning "National Standard" in Chinese. 
 * GB2312: A coded character set established by the government of People's Republic of China in 1980. 
 * 
 * Main features of GB2312: 
 * It contains 7445 characters, including 6763 Hanzi and 682 non-Hanzi characters. 
 * It is for simplified Chinese characters only. The traditional Chinese characters
 * are included in Big5 character set. It is used mainly in mainland China and Singapore. 
 *
 * GB2312 arranges characters into a matrix of 94 rows and 94 columns based on the following rules: 
 *
 * Row_#    Nr_of_Characters
 * -----    ----------------
 *    1        94   Special symbols
 *    2        72   Paragraph numbers
 *    3        94   Latin characters
 *    4        83   Hiragana characters
 *    5        86   Katakana characters
 *    6        48   Greek characters
 *    7        66   Cyrillic characters
 *    8        63   Pinyin accented vowels and zhuyin symbols
 *    9        76   Box and table drawing symbols
 *   10-15          Not defined
 *   16-55   3755   Hanzi level 1, ordered by pinyin
 *   56-87   3008   Hanzi level 2, ordered by radical, then stroke
 *
 * Be noted that the matrix is also called "Qu Wei" in Chinese ("Tuken" in Japanese), while "Qu" is
 * corresponding to rows, and "Wei" corresponding to columns in each row. So a code point is uniquely
 * identified by the combination of its "Qu" and "Wei" (i.e, row and column). The values of Qu/Wei 
 * start from 1 (instead of 0).
 *
 *
 * GB2312 Codes 
 *
 * GB2312 assigns a 2-byte native code for each character. The first byte is called the high byte, 
 * containing the row number plus 32; the second byte is called the low byte, containing the column 
 * number plus 32. For example, if a character is located at Qu/Wei (16/1), its high byte will be 
 * 16 + 32 = 48 (0x30), and the low byte will be 1 + 32 = 33 (0x21). Put them together, its native 
 * code will be 0x3021 (Big Endian). 
 *
 * The reason to add 32 on both row and column is related to "G0" encoding as defined in "ISO 2022",
 * where the 1st 32 points in ASCII are reserved for Control Characters (called C0 zone), and the 
 * rest 96 points are for Graphic Characters (called GL zone). "G0" encoding excludes two points, 
 * namely the first (33) and the last (128), thus we have 94 points in G0.
 *
 * The byte values of GB2312 native codes collide with ASCII codes. To resolve this problem, a value 
 * of 128 is added to both bytes of the native codes. For example, if a character is located at Qu/Wei 
 * (16/1), its native code will be 0x3021, and its modified code will be 0xB0A1. The modified code 
 * is called the Internal Code (NeiMa), which is EUC-CN (Extended Unix Coding, China).
 *
 * GB2312 vs. Unicode 
 *
 * GB2312 character set is sub set of Unicode character set. This means that every character defined 
 * in GB2312 is also defined in Unicode. However, GB2312 codes and Unicode codes are totally un-related. 
 * For example, GB2312 character with Internal Code 0xB0A1 has an Unicode code value of 0x554A. 
 * There no mathematical formula to convert a GB2312 code to a Unicode code of the same character. A look
 * up table is needed for mapping between these two.
 * 
 * created(bruin, 2002-11-12)
 * last updated(bruin, 2008-12-08)
 */

#include <stdlib.h>
#include <stdio.h>

#include "gb2312_unicode.h"  /* map from gb2312 to unicode */

/* the numbers are includsive */
#define MIN_ROW                    1
#define MAX_ROW                   87
#define MIN_ROW_NO                10
#define MAX_ROW_NO                15

#define MIN_COL                    1
#define MAX_COL                   94

/* values to added when converting QuWei to Native */
#define QUWEI_TO_NATIVE  (0x20)
/* values to added when converting Native to NeiMa */
#define NATIVE_TO_NEIMA  (0x80)
/* values to added when converting QuWei to NeiMa */
#define QUWEI_TO_NEIMA  (QUWEI_TO_NATIVE + NATIVE_TO_NEIMA)

static unsigned short gb2uni(unsigned char gb[2]);

int main(void){

	unsigned char row, col;  /* row is for Qu, col is for Wei */
	unsigned char code[3] = { '\0', '\0', '\0'};
	

	/* print the table header */
	printf("<html>\n");
	printf("<head><title>GB2312-80 Code Table</title>\n");
	printf("<meta http-equiv=\"Content-Type\" content=\"text/html; charset=gb2312\">\n");
	printf("<style type=\"text/css\">a {text-decoration:none}</style>\n");
	printf("</head>\n");
	printf("<body>\n");
	printf("<H2><center>GB2312-80: Code Table of Graphic Characters</center></H2>\n");
	printf("<H>Values in the first column is the 1st byte, representing Qu #, ranges from %d-%d, %d-%d, inclusive</H><br>\n", MIN_ROW, MIN_ROW_NO-1, MAX_ROW_NO+1, MAX_ROW);
	printf("<H>Values in the first row is the 2nd byte, representing Wei #, ranges from %d-%d, inclusive</H>\n", MIN_COL, MAX_COL);
	printf("<br>\n");
	printf("<br>\n");
	printf("<H>Qu Wei code (ÇøÎ»Âë) -> Internal Code (ÄÚÂë): (Qu, Wei) -> (Qu + 0xA0, Wei + 0xA0)</H>\n");
	printf("<br>\n");
	printf("<br>\n");
	printf("<table border=1 cellpadding=1 cellspacing=0>\n");
	
	printf("<tr bgcolor=\"#ffff00\"><td>&nbsp;&nbsp</td>");
	for(col = MIN_COL; col <= MAX_COL; col ++)
		printf("<td>%02d</td>", col);
	printf("</tr>\n");

	for(row = MIN_ROW; row <= MAX_ROW; row ++){
		printf("<tr><td bgcolor=\"#ffff00\">%02d</td>", row);
		for(col = MIN_COL; col <= MAX_COL; col ++){
			if(row >= MIN_ROW_NO && row <= MAX_ROW_NO)
				printf("<td>&nbsp;&nbsp</td>");
			else{
				code[0] = row + QUWEI_TO_NEIMA;
				code[1] = col + QUWEI_TO_NEIMA;
				printf("<td><a href=\"\" title=\"0X%02X%02X; U+%04X\">%s</a></td>", code[0], code[1], gb2uni(code), code);  /* big endian */
			}
		}
		printf("</tr>\n");
	}
	printf("<table>\n");
	printf("</body></html>\n");
	return 0;
}



/*
 * return the unicode corresponding to the gb code
 * parameter: gb[2]: gb[2] is the NeiMa 
 * return: the unicode. return 0 means not hit
 */
static unsigned short gb2uni(unsigned char gb[2])
{
	int i;
	unsigned short native = (gb[0] - NATIVE_TO_NEIMA) * 256 + (gb[1] - NATIVE_TO_NEIMA);
	//printf("neima: %02x%02x; native: %04x\n", gb[0], gb[1], native);
	for(i = 0; i < CODE_NUMBER; i ++){
		if(GB_Unicode_Map[i][0] == native) 
			return GB_Unicode_Map[i][1];
	}
	return 0;
}
