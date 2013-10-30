/* created(bruin, 2007-07-17) */
#include <stdio.h>
#include "elf.h"
#include "brn.h"

#define DEBUG_TRACE

#define STACK_SECTION_NAME ".stack"   /* this should be a safe assumption */
#define NO_HEADER          "-n"       /* command line option */

/* endianness as in elf header: 1=little_endian, 2=big_endian */
static char s_host_endian; 
static char s_file_endian; /* "byteorder" as indicated in elf header */


void usage(void);
unsigned char  is_big_endian(void);

/* todo: swap short/int if host endian is different from elf file endian */

int main(int argc, void* argv[])
{
	int ret = 0, i;

	FILE *fp_in = NULL;
	FILE *fp_out = NULL;
	unsigned int in_size;
	unsigned char* input = NULL;


	/* input elf file specific */
	elf_hdr_t         *elf_hdr;
	elf_program_hdr_t *prg_hdr; /* point to the start of the array */
	elf_section_hdr_t *sec_hdr; /* point to the start of the array */

	/* output BRN file specific */
	int no_header = 0;
	unsigned int flash_offset = BRN_FILE_START_ADDRESS_IN_FLASH + 256;
	brn_loader_info_t brn_loader_info = {0, 0, 0, 0};
	brn_segment_hdr_t brn_segment_hdr[MAX_SEGMENTS];

	memset(brn_segment_hdr, 0, sizeof(brn_segment_hdr));

	/* get host endian first */
	if(is_big_endian)
		s_host_endian = 2;
	else
		s_host_endian = 1;

	if(argc < 3 || argc > 4){
		usage();
		return -1;
	}

	if(argc == 4)
			no_header = 1;

	printf("Input  file: %s\n", argv[1]);
	printf("Output file: %s\n", argv[2]);
	printf("Converting: %s --> %s\n\n", argv[1], argv[2]);

	fp_in = fopen(argv[1], "rb");
	if(NULL == fp_in){
			printf("ERR: can not open input file for binary reading.\n");
			ret = -1;
			goto EXIT;
	}

	fp_out = fopen(argv[2], "wb");
	if(NULL == fp_out){
			printf("ERR: can not open output file for binary writting.\n");
			ret = -1;
			goto EXIT;
	}

	fseek(fp_in, 0, SEEK_END);
	in_size = ftell(fp_in);
	fseek(fp_in, 0, SEEK_SET);
	
	/* allocate the memory, or better mmap()? */
	input = (unsigned char *)malloc(in_size);
	if(input == NULL){
			printf("ERR: can not allocate memory for reading input file\n");
			ret = -1;
			goto EXIT;
	}

	if(in_size != fread(input, 1, in_size, fp_in)){
			printf("fread() return size is not desired\n");
			ret = -1;
			goto EXIT;
	}

	/* now input file content is in memory */
	fclose(fp_in);
	fp_in = NULL;

	elf_hdr = (elf_hdr_t*)input;
	s_file_endian = elf_hdr->byteorder;
	printf("ELF header information :\n");
	printf("------------------------\n");
	printf("magic[4]=0x%02x%02x%02x%02x\n", elf_hdr->magic[0], 
					                        elf_hdr->magic[1],
					                        elf_hdr->magic[2],
					                        elf_hdr->magic[3]);
	printf("class=%d (1=32bit, 2=64bit)\n", elf_hdr->class);
	printf("byteorder=%d (1=little-endian, 2=big-endian)\n", elf_hdr->byteorder);
	printf("hversion=%d\n", elf_hdr->hversion);
	printf("pad[9]= %02x %02x %02x %02x %02x %02x %02x %02x %02x\n", elf_hdr->pad[0],
					elf_hdr->pad[1], elf_hdr->pad[2], elf_hdr->pad[3], elf_hdr->pad[4],
					elf_hdr->pad[5], elf_hdr->pad[6], elf_hdr->pad[7], elf_hdr->pad[8]);
	printf("filetype=%d(1=relocatable, 2=executable, 3=shared object, 4=core image\n", elf_hdr->filetype);
	printf("archtype=%d(2=SPARC, 3=x86, 4=68k, 42=SH40, etc)\n", elf_hdr->archtype);
	printf("fversion=%d\n", elf_hdr->fversion);
	printf("entry=0x%08x (executable entry point)\n", elf_hdr->entry);
	printf("phdrpos=0x%x (program header offset, or 0)\n", elf_hdr->phdrpos);
	printf("shdrpos=0x%x (section header offset, or 0)\n", elf_hdr->shdrpos);
	printf("flags=%d (architecture specific flags)\n", elf_hdr->flags);
	printf("hdrsize=%d (size of elf header); sizeof(elf_hdr_t)=%d\n", elf_hdr->hdrsize, sizeof(elf_hdr_t));
	printf("phdrent=%d (entry size of program header); sizeof(elf_program_hdr_t)=%d\n", elf_hdr->phdrent, sizeof(elf_program_hdr_t));
	printf("phdrcnt=%d (number of entries in program header)\n", elf_hdr->phdrcnt);
	printf("shdrent=%d (entry size of section header); sizeof(elf_section_hdr_t)=%d\n", elf_hdr->shdrent, sizeof(elf_section_hdr_t));
	printf("shdrcnt=%d (number of entries in section header)\n", elf_hdr->shdrcnt);
	printf("strsec=%d (index of the section contains section name strings\n", elf_hdr->strsec);

	if(elf_hdr->filetype != 2){
			printf("ERR: input file is not an executable (elf_hdr->filetype!=2).\n");
			goto EXIT;
	}
	else{
		/* store the entry */
		brn_loader_info.entry = elf_hdr->entry;
	}

	/* section headers */
	sec_hdr = (elf_section_hdr_t*)(input + elf_hdr->shdrpos);
	printf("\nsection table:\n");
	printf("[idx]             name type     flags address off  size link     info   align entsize\n");
	printf("-------------------------------------------------------------------------------------\n");
	for(i = 0; i < elf_hdr->shdrcnt; i ++){
			char* sect_name = input + sec_hdr[elf_hdr->strsec].sh_offset + sec_hdr[i].sh_name; 
			printf("[%2d]  ", i);
			printf("%16s ", sect_name);
			printf("%08x ", sec_hdr[i].sh_type);
			printf("%04x ", sec_hdr[i].sh_flags);
			printf("%08x ", sec_hdr[i].sh_addr);
			printf("%04x ", sec_hdr[i].sh_offset);
			printf("%04x ", sec_hdr[i].sh_size);
			printf("%08x ", sec_hdr[i].sh_link);
			printf("%08x ", sec_hdr[i].sh_info);
			printf("%02x  ", sec_hdr[i].sh_align);
			printf("%04x\n", sec_hdr[i].sh_entsize);

			/* check if it's the ".stack" section, if, then store the stack pointer */
			if(0 == strcmp(STACK_SECTION_NAME, sect_name))
					brn_loader_info.stack = sec_hdr[i].sh_addr;
	}


	/* program headers */
	prg_hdr = (elf_program_hdr_t*)(input + elf_hdr->phdrpos);
	printf("\nsegment table:\n");
	printf("[idx]  type     off      vaddr    paddr    fsize    msize    flags    align\n");
	printf("------------------------------------------------------------------------------\n");
	for(i = 0; i < elf_hdr->phdrcnt; i ++){
			printf("%2d     ", i);
			printf("%08x ", prg_hdr[i].type);
			printf("%08x ", prg_hdr[i].offset);
			printf("%08x ", prg_hdr[i].virtaddr);
			printf("%08x ", prg_hdr[i].physaddr);
			printf("%08x ", prg_hdr[i].filesize);
			printf("%08x ", prg_hdr[i].memsize);
			printf("%08x ", prg_hdr[i].flags);
			printf("%08x\n", prg_hdr[i].align);

			brn_segment_hdr[i].src_addr_in_flash = flash_offset;
			brn_segment_hdr[i].dest_addr_in_ram = prg_hdr[i].virtaddr;
			brn_segment_hdr[i].segment_size = prg_hdr[i].filesize;
			brn_segment_hdr[i].flag = 0;
			flash_offset += prg_hdr[i].filesize;

			/* check if this segment contains BSS section */
			if(prg_hdr[i].filesize != prg_hdr[i].memsize){
					brn_loader_info.bss_start = prg_hdr[i].virtaddr + prg_hdr[i].filesize;
					brn_loader_info.bss_size = prg_hdr[i].memsize - prg_hdr[i].filesize;
			}
	}

	/*********************************/
	/* write to the output .brn file */
	/*********************************/
	/* the header first */
	if(!no_header){
		fwrite(&brn_loader_info, sizeof(brn_loader_info_t), 1, fp_out);
		fwrite(brn_segment_hdr, sizeof(brn_segment_hdr), 1, fp_out);
	}
	/* write out the segments by go through them again (the same sequence) */
	for(i = 0; i < elf_hdr->phdrcnt; i ++)
			fwrite(input + prg_hdr[i].offset, 1, prg_hdr[i].filesize, fp_out);

	/* print the output file header */
	fseek(fp_out, 0, SEEK_SET);
	fread(&brn_loader_info, sizeof(brn_loader_info_t), 1, fp_out);
	fread(brn_segment_hdr, sizeof(brn_segment_hdr), 1, fp_out);
	printf("\nBRN loader info:\n");
	printf("--------------\n");
	printf("entry = 0x%08x\n", brn_loader_info.entry);
	printf("stack = 0x%08x\n", brn_loader_info.stack);
	printf("bss_start = 0x%08x\n", brn_loader_info.bss_start);
	printf("bss_size  = 0x%08x\n", brn_loader_info.bss_size);
	printf("\nBRN segment info:\n");
	printf("idx   src_addr dest_addr size    flag\n");
	printf("-----------------------------------------\n");
	for(i = 0; i < MAX_SEGMENTS; i ++){
			printf("[%2d]  ", i);
			printf("%08x ", brn_segment_hdr[i].src_addr_in_flash);
			printf("%08x ", brn_segment_hdr[i].dest_addr_in_ram);
			printf("%08x ", brn_segment_hdr[i].segment_size);
			printf("%08x ", brn_segment_hdr[i].flag);
			printf("\n");
	}
			


EXIT:
	if(input)
		free(input);
	if(fp_in)
		fclose(fp_in);
	if(fp_out)
		fclose(fp_out);

	return ret;
}

void usage(void)
{
	printf("usage: elf2bin <inputfile> <outputfile> [%s]\n", NO_HEADER);
	printf("       %s  :     no header\n", NO_HEADER);
}

unsigned char is_big_endian(void)
{
		short s = 0x0100;
		return ((unsigned char*)&s)[0];
}
