#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "font16.h"
#include "sim_hei_24.h"

inline int
get_bit(unsigned char *p, int offset)
{
    int nr_byte, off;
    nr_byte = offset / 8;
    off = offset % 8;

    p += nr_byte;

    return (*p & (0x80 >> off));
}

void
print_glyph(glyph_t * g)
{
    int i, j, offset;
    int line_size;
    unsigned char *p;

    line_size = FONT16_GLYPH_LINE_SIZE(g);

    p = g->bitmap;
    for (i = 0; i < FONT16_GLYPH_HEIGHT(g); i++) {
        for (j = 0; j < FONT16_GLYPH_WIDTH(g); j++) {
            printf("%c", get_bit(p, j) ? '0' : ' ');
        }
        p += line_size;
        printf("\n");
    }

}

int
main(void)
{
    font16_handle_t font16 = 0;
    int i, ret;
    unsigned short text[] = { 0x3084, 0xffe5, 0x9edc, 0x0034, 0x0035 };
    unsigned char *p;
    unsigned char width, height, ascent;
    unsigned char line_size;
    glyph_t *glyph = NULL;

    font16 = font16_install(sim_hei_24_ucs2_codetable, sim_hei_24_ucs2_fontdata, GLYPH_COUNT);

#if(0)
    for (i = 0; i < sizeof (text) / sizeof (short); i++) {
        ret = font16_get_glyph(font16, text[i], &glyph);
        if (0 == ret) {
            printf("i=%d, code=0x%04x, p=0x%08x, width=%d, height=%d, ascent=%d\n",
                   i, text[i], glyph, glyph->width, glyph->height, glyph->ascent);
            print_glyph(glyph);
        } else {
            printf("i=%d, code=0x%04x, missing\n", i, text[i]);
        }
    }

#else
    for (i = 0; i < GLYPH_COUNT; i++) {
        ret = font16_get_glyph(font16, sim_hei_24_ucs2_codetable[i], &glyph);
        if (0 == ret) {
            printf("\ni=%d, code=0x%04x, width=%d, height=%d, ascent=%d\n\n",
                   i, sim_hei_24_ucs2_codetable[i], glyph->width, glyph->height, glyph->ascent);
            print_glyph(glyph);
        } else {
            printf("########i=%d, code=0x%04x, missing\n", i, sim_hei_24_ucs2_codetable[i]);
        }
    }
#endif

    font16_uninstall(font16);

    return 0;
}
