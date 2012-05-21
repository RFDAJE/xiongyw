#ifndef __FONT16_H__
#define __FONT16_H__

typedef unsigned int font16_handle_t;

/*
 * - each glyph is represented by three bytes describing its width, height, 
 *   and ascent followed by a 1-bit per pixel bitmap: {width, height, ascent,bitmap[]}
 * - the bitmap is arranged from top line to bottom line. 
 * - bitmap for each line is rounded at an  one-byte boundary (e.g., a glyph 
 *   of 22 pixels width has a 3 byte boundary), so the size of a line (of a 
 *   glyph) in bytes is ((width+7)/8), and the size  of a glyph in bytes is:
 *           (((width+7)/8)*height)
 * - the most significant bit represent the left-most pixel.
 */
typedef struct _glyph_t {
    unsigned char width, height, ascent;    /* in pixel */
    unsigned char bitmap[0];    /* start of the bitmap */
} glyph_t;

#define FONT16_GLYPH_WIDTH(g)     (g->width)
#define FONT16_GLYPH_HEIGHT(g)    (g->height)
#define FONT16_GLYPH_ASCENT(g)    (g->ascent)
#define FONT16_GLYPH_LINE_SIZE(g) ((FONT16_GLYPH_WIDTH(g) + 7) / 8)
#define FONT16_GLYPH_SIZE(g)      (FONT16_GLYPH_LINE_SIZE(g) * FONT16_GLYPH_HEIGHT(g))

font16_handle_t font16_install(const unsigned short *unicode, const unsigned char *glyph, int count);
int font16_uninstall(font16_handle_t font16_hdl);
/* return 0 for hit, 1 for miss */
int font16_get_glyph(font16_handle_t font16_hdl, unsigned short unicode, glyph_t ** glyph);
/* get the place keeper glyph for not-supported code point. return 0 for ok, otherwise failure */
int font16_get_default_glyph(font16_handle_t font16_hdl, glyph_t ** glyph);

#endif                          /* __FONT16_H__ */
