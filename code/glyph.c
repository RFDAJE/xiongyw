/* created(bruin, 2012-11-26): parse svg font file.
 */

#include <string.h>
#include <stdio.h>

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


int main(void)
{

	unsigned short ucs2;
	char* glyph_start;
	size_t size;

	int r;

	printf("fontfile=\n%s\n", TEST_FONT);

	r = get_next_glyph(TEST_FONT, &ucs2, &glyph_start, &size);

	printf("r=%d\n", r);
	printf("ucs2=0x%04x\n", ucs2);
	for(r = 0; r < size; r ++)
		printf("%c", glyph_start[r]);

	printf("\n\n\n");
	return 0;
}
