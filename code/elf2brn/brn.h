/* created(bruin, 2007-07-18): this file format is called BRN (BuRN), not BIN which is ambigious */
#ifndef __BRN_H__
#define __BRN_H__

#define BRN_FILE_START_ADDRESS_IN_FLASH   0xA0020000 /* starting from the 2nd block */

typedef struct{
		unsigned int stack;
		unsigned int entry;
		unsigned int bss_start; /* need to zero out the BSS section at loading */
		unsigned int bss_size;
}brn_loader_info_t;

#define MAX_SEGMENTS  15 
typedef struct{
		unsigned int src_addr_in_flash; /* start from 0xA0000000 */
		unsigned int dest_addr_in_ram;  /* start from 0x84000000 */
		unsigned int segment_size;      /* file size , this is not for BSS */
		unsigned int flag;              /* 1 for zipped; 0 for non-zip */
}brn_segment_hdr_t;

/* noted(bruin, 2007-07-18): 
 * - the BRN file will be stored in flash start from a hard-coded address as define here BIN_FLASH_START_ADDRESS_IN_FLASH
 * - the first 16 bytes is one instance of loader_info_t;
 * - the next 240 bytes are 15 segment_hdr_t; the end of the segment is indicated by src_addr_in_flash = 0.
 * - the segments are follows...
 */


#endif /* __BRN_H__ */
