#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "font16.h"

typedef struct _hash_info_t {
    short size, shift, mask;
} hash_info_t;

#define    FONT16_HASH_GET_ATTR(_sz_,_sht_,_msk_)    switch(_sz_){\
  case  64:   _sht_=8; _msk_=64-1; break;\
  case  128:  _sht_=8; _msk_=128-1; break;\
  case  256:  _sht_=8; _msk_=256-1; break;\
  case  512:  _sht_=7; _msk_=512-1; break;\
  case  1024: _sht_=6; _msk_=1024-1; break;\
  case  2048: _sht_=5; _msk_=2048-1; break;\
  case  4096: _sht_=4; _msk_=4096-1; break;\
  case  8192: _sht_=3; _msk_=8192-1; break;\
  }

#define    FONT16_HASH_GET_SIZE(_ct_)  \
  ((_ct_) <  256) ?  128 : \
  ((_ct_) < 1024) ?  512 : \
  ((_ct_) < 2048) ? 1024 : \
  ((_ct_) < 8192) ? 4096 : 8192

#define FONT16_HASH( ucode,_sht_,_msk_ ) (((( ucode) >> (_sht_) ) ^ ucode) & (_msk_))

/*
 * ---------------------------------------------------------------------------
 *  notes on the data structures for hashing:
 * ---------------------------------------------------------------------------
 * - keys (n) ---> (1) buckets (1) ---> (1) overflows;
 * - unicodes are the keys, which hash into indices of buckets;
 * - a bucket contains only a collision count and a pointer to overflow array;
 * - for each unicode/key there is an overflow entry;
 * - all overflow entries are arranged into a single big array;
 * - overflow entries for each bucket form a small array, which 
 *   is a continous subset of the big array;
 * ---------------------------------------------------------------------------
 */

typedef struct _overflow_t {
    unsigned int unicode;       /* unicode value of the glyph */
    unsigned char *bitmap;      /* points to glyph bitmap */
} overflow_t;

typedef struct _bucket_t {
    overflow_t *overflows;      /* array of overflow entries */
    unsigned int clash_cnt;     /* nr of entries in overflow array */
} bucket_t;

typedef struct _font16_t {
    /*
     * original resource data is arranged into to two arrays:
     *
     * - the code table is an array of code point values
     * - the glyph data is an array of glyph bitmaps
     * - each glyph is represented by three bytes describing its width, height, 
     *   and ascent followed by a 1-bit per pixel bitmap: {width, height, ascent,bitmap[]}
     * - the bitmap is arranged from top line to bottom line. 
     * - bitmap for each line is rounded at an  one-byte boundary (e.g., a glyph 
     *   of 22 pixels width has a 3 byte boundary), so the size of a line (of a 
     *   glyph) in bytes is ((width+7)/8), and the size  of a glyph in bytes is:
     *           (((width+7)/8)*height)
     * - the most significant bit represent the left-most pixel.
     * - the glyphs must be described continuously and in the same order as the code array.
     */
    const unsigned short *code;
    const unsigned char *glyph;

    /* 
     * generated hash table structures 
     */
    hash_info_t hash_info;      /* nr of buckets */
    bucket_t *buckets;          /* buckets array */
    overflow_t *overflows;      /* the big overflow array */
} font16_t;

/*
 * fontdata is: [width,height,ascent,bitmap[..]]
 */
#define    FONT16_WIDTH_OFFSET    0
#define    FONT16_HEIGHT_OFFSET    1
#define    FONT16_ASCENT_OFFSET    2
#define    FONT16_BITMAP_OFFSET    3

#define    INVALID_UCODE    0xffff

/*
 *---------------------------------------------------
 * local function forward declarations
 *---------------------------------------------------
 */
static font16_t *s_font16_create_font(const unsigned short *codes, const unsigned char *glyphs, int count);
static int s_font16_get_glyph(font16_t * font16, unsigned short uc, glyph_t ** glyph);

/*
 *---------------------------------------------------
 * public functions implementation
 *---------------------------------------------------
 */
inline font16_handle_t
font16_install(const unsigned short *codes, const unsigned char *glyphs, int count)
{
    return (font16_handle_t) s_font16_create_font(codes, glyphs, count);
}

int
font16_uninstall(font16_handle_t font16_hdl)
{
    font16_t *font16 = (font16_t *) font16_hdl;

    if (!font16)
        return 1;

    if (font16->buckets)
        free(font16->buckets);

    if (font16->overflows)
        free(font16->overflows);

    free(font16);

    return 0;
}

inline int
font16_get_glyph(font16_handle_t font16_hdl, unsigned short unicode, glyph_t ** glyph)
{
    return s_font16_get_glyph((font16_t *) font16_hdl, unicode, glyph);
}

int
font16_get_default_glyph(font16_handle_t font16_hdl, glyph_t ** glyph)
{
    return 1;
}

/*
 *---------------------------------------------------
 * local functions implementation
 *---------------------------------------------------
 */
static font16_t *
s_font16_create_font(const unsigned short *code, const unsigned char *glyph, int count)
{
    font16_t *new_font16 = NULL;
    bucket_t *buckets = NULL;
    overflow_t *overflows = NULL;
    short h_size, h_shift, h_mask;  /* hash_info */
    int i, bucket_idx, over_idx, glyph_size, offset;
    unsigned char *p;

    /* 
     * determine hash_info 
     */
    h_size = FONT16_HASH_GET_SIZE(count);
    FONT16_HASH_GET_ATTR(h_size, h_shift, h_mask);

    /* 
     * allocate font16_t 
     */
    new_font16 = (font16_t *) malloc(sizeof (font16_t));
    if (new_font16 == NULL)
        return NULL;
    memset(new_font16, 0, sizeof (font16_t));

    /* 
     * allocate buckets 
     */
    buckets = (bucket_t *) malloc(sizeof (bucket_t) * h_size);
    if (buckets == NULL) {
        free(new_font16);
        return NULL;
    }

    memset(buckets, 0, sizeof (bucket_t) * h_size);

    /*
     * allocate overflows
     */
    overflows = (overflow_t *) malloc(sizeof (overflow_t) * count);
    if (overflows == NULL) {
        free(buckets);
        free(new_font16);
        return NULL;
    }

    memset(overflows, 0, sizeof (overflow_t) * count);
    for (i = 0; i < count; i++) {
        overflows[i].unicode = INVALID_UCODE;
    }

    /*
     * prepare buckets
     */
    for (i = 0; i < count; i++) {
        bucket_idx = FONT16_HASH(code[i], h_shift, h_mask);
        buckets[bucket_idx].clash_cnt++;
    }

    over_idx = 0;
    for (i = 0; i < h_size; i++) {
        if (buckets[i].clash_cnt) {
            buckets[i].overflows = (overflow_t *) over_idx; /* save the idx temporarily here */
            over_idx += buckets[i].clash_cnt;
        }
    }

    /*
     * fill overflows
     */
    p = (unsigned char *) glyph;
    offset = 0;
    for (i = 0; i < count; i++) {
        bucket_idx = FONT16_HASH(code[i], h_shift, h_mask);
        over_idx = (int) (buckets[bucket_idx].overflows);
        while (overflows[over_idx].unicode != INVALID_UCODE) {
            over_idx++;
        }
        overflows[over_idx].unicode = code[i];
        overflows[over_idx].bitmap = (unsigned char *) glyph + offset;
        glyph_size = ((p[FONT16_WIDTH_OFFSET] + 7) / 8) * p[FONT16_HEIGHT_OFFSET];
        offset += glyph_size + FONT16_BITMAP_OFFSET;
        p += glyph_size + FONT16_BITMAP_OFFSET;
    }

    /*
     * convert buckets[i].overflow for index to pointer
     */
    for (i = 0; i < h_size; i++) {
        buckets[i].overflows = overflows + (int) (buckets[i].overflows);
    }

    /* 
     * ready to return 
     */
    new_font16->code = code;
    new_font16->glyph = glyph;

    new_font16->buckets = buckets;
    new_font16->overflows = overflows;

    new_font16->hash_info.size = h_size;
    new_font16->hash_info.shift = h_shift;
    new_font16->hash_info.mask = h_mask;

    return new_font16;

}

/* 
 * return 0 for hit; 1 for miss;
 */
static int
s_font16_get_glyph(font16_t * font16, unsigned short uc, glyph_t ** glyph)
{
    int i, hit, mask, shift;
    bucket_t *bucket = NULL;
    overflow_t *over = NULL;
    unsigned char *ret = NULL;

    FONT16_HASH_GET_ATTR(font16->hash_info.size, shift, mask);

    bucket = font16->buckets + FONT16_HASH(uc, shift, mask);
    over = bucket->overflows;

    hit = 0;
    for (i = 0; i < bucket->clash_cnt; i++) {
        if (over[i].unicode == uc) {
            hit = 1;
            *glyph = (glyph_t *) (over[i].bitmap);
            break;
        }
    }

    return hit ? 0 : 1;
}
