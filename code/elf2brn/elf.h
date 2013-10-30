/* created(bruin, 2007-07-18) */
#ifndef __ELF_H__
#define __ELF_H__

/*******************************************************/
/* the following is referencing L&L and ELF_format.pdf */
/*******************************************************/

/* elf header */
typedef struct{
		char magic[4];  /* "\177ELF" */
		char class;     /*  address size: 1 = 32, 2 = 64 bit */
		char byteorder; /* 1 = little-endian, 2 = big-endian */
		char hversion;  /* header version, always 1 */
		char pad[9];

		short filetype; /* 1 = relocatable, 2 = executable, 3 = shared, 4 = core image */
		short archtype; /* 2 = SPARC, 3 = x86, 4 = 68k, 42=SH40, etc */
		int   fversion; /* file version, always 1 */
		unsigned int   entry;    /* entry point if file type is executable */
		unsigned int   phdrpos;  /* program header file offset, or 0 */
		unsigned int   shdrpos;  /* section header file offset, or 0 */
		int   flags;    /* architecutre flags, usually 0 */
		short hdrsize;  /* size of this ELF header */
		short phdrent;  /* size of one entry of program header */
		short phdrcnt;  /* number of entries in program header, or 0 */
		short shdrent;  /* size of one entry of section header */
		short shdrcnt;  /* number of entries in section header, or 0 */
		short strsec;   /* section number that contains section name strings */
}elf_hdr_t;

/* elf section header */
typedef struct{
		int sh_name;    /* name, index into the string table */
		int sh_type;    
		int sh_flags;
		int sh_addr;    /* base memory address if loadable, or 0 */
		int sh_offset;  /* file offset of this section */
		int sh_size; 
		int sh_link;    /* section number with related info, or 0 */
		int sh_info;    /* more section specific info */
		int sh_align;   /* alignment granularity if section is moved */
		int sh_entsize; /* size of entries if section is an array */
}elf_section_hdr_t;

/* elf program header: for executable */
typedef struct{
		int type;       /* loadable code or data, dynamic linking info, etc. see below */
		int offset;     /* file offset of segment */
		int virtaddr;   /* virtual address to map segment */
		int physaddr;   /* physical address, not used */
		int filesize;   /* size of segment in file */
		int memsize;    /* size of segment in memory (bigger if contains BSS) */
		int flags;      /* read/write/executable bits */
		int align;      /* required alignment, invariably hardware page size */
}elf_program_hdr_t;

/* section type */
#define SECT_TYPE_NULL      0
#define SECT_TYPE_PROGBITS  1   /* program contents including code/data, and debug info */
#define SECT_TYPE_SYMTAB    2   /* all symbols and is intended for the linker */
#define SECT_TYPE_STRTAB    3   /* string table for section names, symbol names, etc */
#define SECT_TYPE_RELA      4   /* relocation information */
#define SECT_TYPE_HASH      5   /* run-time symbol hash table */ 
#define SECT_TYPE_DYNAMIC   6   /* dynmaic linking information */
#define SECT_TYPE_NOTE      7
#define SECT_TYPE_NOBITS    8    /* BSS */
#define SECT_TYPE_REL       9
#define SECT_TYPE_SHLIB     10
#define SECT_TYPE_DYNSYM    11   /* symbol for dynamic linking */
#define SECT_TYPE_LOPROC    0x70000000
#define SECT_TYPE_HIPROC    0x7fffffff
#define SECT_TYPE_LOUSER    0x80000000
#define SECT_TYPE_HIUSER    0xffffffff



#endif /* __ELF_H__ */
