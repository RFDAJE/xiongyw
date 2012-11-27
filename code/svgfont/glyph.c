/* created(bruin, 2012-11-26): parse svg font file.
 */

#include <sys/types.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#include "gb2312_in_ucs2.h"

#define TEST_FONT  "<glyph glyph-name=\"imacron\" unicode=\"&#x12b;\" horiz-adv-x=\"128\" d=\"M64 4h-20v116h20v-116zM90 155v-16h-70v16h70z\" />"

#define GLYPH_START   "<glyph "
#define GLYPH_END     "/>"
#define UNICODE_POINT "unicode=\"&#x"




/* return 0 if not found; 1 otherwise */
int get_next_glyph(const char* start,     /* input */
                   unsigned short* ucs2,   /* output, 0xffff means not convertable */
                   char** glyph_start,     /* the exact start addr of the glyph */
                   size_t* glyph_size)    /* the size in bytes of the glyph */
{

	 char* unicode;
	 char* end;


	 /* where the glyph starts? */
	 *glyph_start = strstr(start, GLYPH_START);
	 if(!*glyph_start) return 0;

	 /* determine the ucs2 value */
	 unicode = strstr(*glyph_start, UNICODE_POINT);
	 if(!unicode) 
		 *ucs2= 0xffff;

	 if(1 != sscanf(unicode+sizeof(UNICODE_POINT)-1, "%x\"", ucs2))
		 *ucs2 = 0xffff;

	 /* where the glyph ends? */
	 end = strstr(*glyph_start, GLYPH_END);
	 if(!end) return 0;

	 *glyph_size = end - *glyph_start + sizeof(GLYPH_END);
	 return 1;
}

/* return 1 when hit, 0 otherwise */
static int s_is_hit(unsigned short ucs2)
{
	int i;
	for(i = 0; i < GLYPH_COUNT; i ++)
		if(ucs2 == gb2312_in_ucs2_codetable[i])
			return 1;
	return 0;
}

int main(int argc, char* argv[])
{

	unsigned short ucs2;
	char* glyph_start;
	size_t size;
	int r, i;


 struct stat input_stat; /* stat of input file */
 int input_fd = - 1;     /* descriptor of input file */
 char* p_input_file = 0;   /* point to begining of input file memory */
 char* p;

	

	if(argc != 2){
		printf("Usage: %s <svg_font_file_name>\n\n", argv[0]);
		return 1;
	}


	/* 
         * open the file and mmap it 
         */
        if(stat(argv[1], &input_stat)){
                printf("stat(%s) failed, errno=%d, abort.\n", argv[1], errno);
                return 1;
        }

        if((input_fd = open(argv[1], O_RDONLY)) == - 1){
                printf("cann't open file %s, errno=%d, abort.\n", argv[1], errno);
                return 1;
        }

        if((p_input_file = (char*)mmap(0, input_stat.st_size, PROT_READ, MAP_SHARED, input_fd, 0)) == MAP_FAILED){
                printf("mmap file %s failed, errno=%d, abort.\n", argv[1], errno);
		close(input_fd);
		return 1;
        }
	
	p = p_input_file;


	/* print the header upto the first <glyph... */
	r = get_next_glyph(p_input_file, &ucs2, &glyph_start, &size);
	for(i = 0; i < glyph_start - p_input_file; i ++)
		printf("%c", p[i]);
	
	for(p=p_input_file;;){
		r = get_next_glyph(p, &ucs2, &glyph_start, &size);
		if (0 == r){
			/* we reach the end of the glyphs, print the rest */
			for(i = 0; i < input_stat.st_size - (p - p_input_file); i ++)
				printf("%c", p[i]);
			printf("\n\n\n");
			return 0;
		}
		
		/* check if the ucs2 is in the range */
		if(ucs2 == 0xffff || s_is_hit(ucs2)){
			for(i = 0; i < size; i ++)
				printf("%c", glyph_start[i]);
		}

		p += size;

	}
}
