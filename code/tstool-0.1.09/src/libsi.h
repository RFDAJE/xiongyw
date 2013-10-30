#ifndef __LIBSI_H__
#define __LIBSI_H__

#include "si.h"
#include "tree.h"


/* opentv header struct */

typedef struct{
    char  otv_magic[8]; /* "OTV :-) " */
    u8    data_size[4]; /* network byte order */
    u8    *data;        /* data size should be data_size */
}OTV_HEADER;                


/* struct to hold packets of same pid */

#define PID_NODE_STEP         32

typedef struct _PID_NODE{

    /* elementary data */

    u16     pid;
    u32     packet_nr;
    u32     size;       /* increase by PID_NODE_STEP */
    u32     *index;     /* array of index of each packet of the pid */
    u8      stream_type;

    /* link */

    struct _PID_NODE *pre;
    struct _PID_NODE *next;
}PID_NODE;


typedef struct{
    int               pid_nr;
    PID_NODE          *head;
}PID_LIST;


typedef struct{
    u8  index;      /* section index */
    u8  *data;      /* the whole section data */
    int size;       /* total section size */
}SECTION;

#define MAX_SECTION_NR    256
typedef struct{
    u8        tid;
    u8        section_nr;
    SECTION   sections[MAX_SECTION_NR];
}TABLE;



#define MAX_PMT_NR    64
typedef struct{
    u16    pmt_nr;
    u16    pmt_pid[MAX_PMT_NR];
    u16    prog_nr[MAX_PMT_NR];
}PMT_LIST;

/* added(bruin, 2003.01.13) */
#define MAX_AIT_NR   64
typedef struct{
    u16   ait_nr;
    u16   ait_pid[MAX_AIT_NR];
    u16   prog_nr[MAX_AIT_NR];
}AIT_LIST;

/* added(bruin, 2003.02.17): dvb-rcs */
typedef struct{
    u16   rmt_pid, sct_pid, fct_pid, tct_pid, spt_pid, cmt_pid, tbtp_pid, pcr_pid, tim_pid;
    TABLE *tbl_rmt, *tbl_sct, *tbl_fct, *tbl_tct, *tbl_spt, *tbl_cmt, *tbl_tbtp, *tbl_pcr, *tbl_tim;
}RCS_TABLES;

/* added(bruin, 2003.01.18): decouple analysis part from UI part, which is
     platform dependent. */
typedef struct{

    /*** basic data about the ts */
	char*          file_path;
    u8*            file_data;      /* point to the beginning of the file */
    u32            file_size;      /* file size to processed */
    u8*            ts_data;        /* point to the beginning of the TS */
    u32            ts_size;    
    u8             is_otv_header;  /* is there otv header */
    OTV_HEADER     otv_header;     /* the otv header */
    u8             packet_size;    /* 188 or 204 */
    u32            packet_nr;      /* total packet nr */

    /*** analysis result */

    /* pid list sorted in increasing order */
    PID_LIST*      pid_list;
    
    /* tables */
    TABLE*         tbl_pat;
    TABLE*         tbl_cat;
    TABLE*         tbl_nit_act;
    TABLE*         tbl_nit_oth;
    TABLE*         tbl_sdt_act;
    TABLE*         tbl_sdt_oth;
    TABLE*         tbl_bat;
    TABLE*         tbl_eit_act;
    TABLE*         tbl_eit_oth;
    TABLE*         tbl_eit_act_sch;
    TABLE*         tbl_eit_oth_sch;
    TABLE*         tbl_tdt;
    TABLE*         tbl_tot;
    TABLE*         tbl_rst;
    TABLE*         tbl_st;

    /* pmt/ait are different: they are arrays of tables */
    PMT_LIST       pmt_list;
    AIT_LIST       ait_list;   
    
    TABLE**        tbl_pmts;
    TABLE**        tbl_aits; 

    /* added(bruin, 2003.02.17) */
    RCS_TABLES     rcs;     /* set to zero by calloc() in "build_tsr_result()" */

    /* a tree ready to be mapped to UI system */
    TNODE*         root;
}TSR_RESULT;




#ifdef __cplusplus
extern "C"{
#endif

PID_LIST* build_pid_list(u8* ts, u32 packet_nr, u8 packet_size);
int delete_pid_list(PID_LIST* pid_list);

TABLE* build_table(u16 pid, u8 tid, PID_LIST* pid_list, u8* p_ts, u8 packet_size);
int delete_table(TABLE* tbl);

int set_pmt_list_by_pat_sect(SECTION* pat_sect, PMT_LIST* pmt_list);
int set_ait_list_by_pmts(TABLE** tbl_pmts, int pmt_nr, AIT_LIST* ait_list); /* added(bruin, 2003.01.13) */
int set_rcs_tables_by_pmts(TABLE** tbl_pmts, int pmt_nr, RCS_TABLES* rcs_tbls); /* added(bruin, 2003.02.17) */
    
TSR_RESULT* build_tsr_result(const char* file_path, u8* file_data, u32 file_size, int is_verbose);
int delete_tsr_result(TSR_RESULT* result);

u16 get_packet_offset_and_size(u8 *data, int data_size);
PACKET_HEADER* get_packet_by_index(u8* p_ts, int index, int packet_size);
u32 check_otv_header(u8 *p_file, OTV_HEADER* p_otv_header);

void summarize_result(FILE* fp, TSR_RESULT* result);



#ifdef __cplusplus
}
#endif



#endif /* __LIB_SI__ */

