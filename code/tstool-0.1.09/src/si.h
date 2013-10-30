/* bruin, 2002/03/27 */

#ifndef __SI_H__
#define __SI_H__

/* only PSI/SI standards related data structure and utility 
   routines are defined within this file. i.e., user defined 
   data structures to facilitate analysing/storing si info 
   are out of the scope of this file.
*/

#pragma pack(1)

typedef unsigned char                           u8;
typedef unsigned short                          u16;
typedef unsigned int                            u32;


#define CRC_32_SIZE                             4

/*** DVB A038 rev,1, May 2000 ***/

/* packet id allocation for SI tables(totally 13):
   4 PSI tables: PAT/CAT/PMT/NIT
   9 SI tables: BAT/SDT/EIT/RST/TDT/TOT/ST/SIT/DIT

   while pid for PMTs are not static, they are specified in PAT;

   noted(bruin, 2003.01.19): for mhp 1.1, we have anther table AIT, whose 
   pid is also not static, but specified in PMT.
   
   pid is a 13-bit nr, with the maximum value 0x1fff for NULL packets 
 */
 
#define PID_PAT                                 0x0000
#define PID_CAT                                 0x0001
#define PID_TSDT                                0x0002
                                                /* 0x0003 to 0x000f: reserved */
#define PID_NIT                                 0x0010
#define PID_SDT                                 0x0011
#define PID_BAT                                 0x0011
#define PID_EIT                                 0x0012
#define PID_RST                                 0x0013
#define PID_TDT                                 0x0014
#define PID_TOT                                 0x0014
                                                /* 0x0015: network synchronization */
                                                /* 0x0016 to 0x001b: reserved */
                                                /* 0x001c: inband signalling (note: sis-12) */
                                                /* 0x001d: measurement (note: sis-10) */
#define PID_DIT                                 0x001e
#define PID_SIT                                 0x001f
#define PID_NUL                                 0x1fff


/* table id allocation */

#define TID_PAT                                 0x00
#define TID_CAT                                 0x01
#define TID_PMT                                 0x02
                                                /* 0x03: transport_stream_description_section */
                                                /* 0x04 to 0x3f: reserved */
#define TID_NIT_ACT                             0x40
#define TID_NIT_OTH                             0x41
#define TID_SDT_ACT                             0x42
                                                /* 0x43 to 0x45: reserved */
#define TID_SDT_OTH                             0x46
                                                /* 0x47 to 0x49: reserved */
#define TID_BAT                                 0x4a
                                                /* 0x4b to 0x4d: reserved */
#define TID_EIT_ACT                             0x4e
#define TID_EIT_OTH                             0x4f
#define TID_EIT_ACT_SCH                         0x50 /* to 0x5f */
#define TID_EIT_OTH_SCH                         0x60 /* to 0x6f */
#define TID_TDT                                 0x70
#define TID_RST                                 0x71
#define TID_ST                                  0x72
#define TID_TOT                                 0x73
/* 0x74-0x7d: reserved */
/* 0x7e: discontinuity_information_section */
/* 0x7f: selection_information_section */
/* 0x80 to 0xfe: USER DEFINED */
/* 0xff: reserved for stuffing */


/* added(bruin, 2003.01.13): mhp 1.1, table 107: table id on AIT pid */
/* 0x00-0x73: reserved to mhp for future use */
#define TID_AIT                                0x74
/* 0x75-0x7f: reserved to mhp for future use */
/* 0x80-0xff: reserved to private use */


/* added(bruin, 2003.02.17): dvb-rcs table ids (ETSI EN 301 790 v1.2.2 table 10) */
#define TID_RMT                                0x41  /* same as TID_NIT_OTH, but may only appear in specific PID? */
#define TID_SCT                                0xa0  /* superframe composition table */
#define TID_FCT                                0xa1  /* frame compostion table */
#define TID_TCT                                0xa2  /* time-slot composition table */
#define TID_SPT                                0xa3  /* satellite position table */ 
#define TID_CMT                                0xa4  /* correction message table */
#define TID_TBTP                               0xa5  /* terminal burst time plan */
#define TID_PCR                                0xa6  /* pcr packet payload */
#define TID_TIM                                0xb0  /* terminal information msg */



/*** descriptor id allocation ***/

/* iso/iec 13818-1 */
/* 0x00, 0x01, 0x19-0x3f are reserved */
#define DESC_VIDEO_STREAM                       0x02
#define DESC_AUDIO_STREAM                       0x03
#define DESC_HIERARCHY                          0x04
#define DESC_REGISTRATION                       0x05
#define DESC_DATA_STREAM_ALIGNMENT              0x06
#define DESC_TARGET_BACKGROUND_GRID             0x07
#define DESC_VIDEO_WINDOW                       0x08
#define DESC_CA                                 0x09
#define DESC_ISO_639_LANGUAGE                   0x0A
#define DESC_SYSTEM_CLOCK                       0x0B
#define DESC_MULTIPLEX_BUFFER_UTILIZATION       0x0C
#define DESC_COPYRIGHT                          0x0D
#define DESC_MAXIMUM_BITRATE                    0x0E
#define DESC_PRIVATE_DATA_INDICATOR             0x0F
#define DESC_SMOOTHING_BUFFER                   0x10
#define DESC_STD                                0x11
#define DESC_IBP                                0x12

/* dvb-si */
#define DESC_NETWORK_NAME                       0x40
#define DESC_SERVICE_LIST                       0x41
#define DESC_STUFFING                           0x42
#define DESC_SATELLITE_DELIVERY_SYSTEM          0x43
#define DESC_CABLE_DELIVERY_SYSTEM              0x44
#define DESC_VBI_DATA                           0x45
#define DESC_VBI_TELETEXT                       0x46
#define DESC_BOUQUET_NAME                       0x47
#define DESC_SERVICE                            0x48
#define DESC_COUNTRY_AVAILABILITY               0x49
#define DESC_LINKAGE                            0x4a
#define DESC_NVOD_REFERENCE                     0x4b
#define DESC_TIME_SHIFTED_SERVICE               0x4c
#define DESC_SHORT_EVENT                        0x4d
#define DESC_EXTENDED_EVENT                     0x4e
#define DESC_TIME_SHIFTED_EVENT                 0x4f
#define DESC_COMPONENT                          0x50
#define DESC_MOSAIC                             0x51
#define DESC_STREAM_IDENTIFIER                  0x52
#define DESC_CA_IDENTIFIER                      0x53
#define DESC_CONTENT                            0x54
#define DESC_PARENTAL_RATING                    0x55
#define DESC_TELETEXT                           0x56
#define DESC_TELEPHONE                          0x57
#define DESC_LOCAL_TIME_OFFSET                  0x58
#define DESC_SUBTITLING                         0x59
#define DESC_TERRESTRIAL_DELIVERY_SYSTEM        0x5a
#define DESC_MULTILINGUAL_NETWORK_NAME          0x5b
#define DESC_MULTILINGUAL_BOUQUET_NAME          0x5c
#define DESC_MULTILINGUAL_SERVICE_NAME          0x5d
#define DESC_MULTILINGUAL_COMPONENT             0x5e
#define DESC_PRIVATE_DATA_SPECIFIER             0x5f
#define DESC_SERVICE_MOVE                       0x60
#define DESC_SHORT_SMOOTHING_BUFFER             0x61
#define DESC_FREQUENCY_LIST                     0x62
#define DESC_PARTIAL_TRANSPORT_STREAM           0x63
#define DESC_DATA_BROADCAST                     0x64
#define DESC_CA_SYSTEM                          0x65
#define DESC_DATA_BROADCAST_ID                  0x66
#define DESC_TRANSPORT_STREAM                   0x67
#define DESC_DSNG                               0x68
#define DESC_PDC                                0x69
#define DESC_AC_3                               0x6a
#define DESC_ANCILLARY_DATA                     0x6b
#define DESC_CELL_LIST                          0x6c
#define DESC_CELL_FREQUENCY_LINK                0x6d
#define DESC_ANNOUNCEMENT_SUPPORT               0x6e

/* 0x6f - 0x7f are reserved */
/* 0x80 - 0xfe are user defined */
/* 0xff is forbidden */

/* opentv private descriptors */
#define DESC_OPENTV_MODULE_TRACK                0x90
#define DESC_OPENTV_TRACK_TAG                   0xfe

#define DESC_APPLICATION_SIGNALLING             0x6f  /* 2003.01.13: mhp 1.1 table 107 */
#define DESC_SERVICE_IDENTIFIER                 0x71  /* 2003.01.21: mhp 1.1 table 107 */

#define DESC_LOGICAL_CHANNEL                    0x83  /* 2003.12.18: LCN draft from <CSevior@nine.com.au> */

/* ait local descriptors: mhp1.1, table 107 "registry of constant values" */
#define MHP_DESC_APPLICATION                    0x00
#define MHP_DESC_APPLICATION_NAME               0x01
#define MHP_DESC_TRANSPORT_PROTOCOL             0x02
#define MHP_DESC_DVB_J_APPLICATION              0x03
#define MHP_DESC_DVB_J_APPLICATION_LOCATION     0x04
#define MHP_DESC_EXTERNAL_APPLICATION_AUTHORIZATION 0x05
#define MHP_DESC_IPV4_ROUTING                   0x06
#define MHP_DESC_IPV6_ROUTING                   0x07
#define MHP_DESC_DVB_HTML_APPLICATION           0x08
#define MHP_DESC_DVB_HTML_APPLICATION_LOCATION  0x09
#define MHP_DESC_DVB_HTML_APPLICATION_BOUNDARY  0x0a
#define MHP_DESC_APPLICATION_ICONS              0x0b
#define MHP_DESC_PREFETCH                       0x0c
#define MHP_DESC_DLL_LOCATION                   0x0d
#define MHP_DESC_DELEGATED_APPLICATION          0x0e
#define MHP_DESC_PLUG_IN                        0x0f
/* 0x10-0x5e: reserved to mhp futuer use */
#define MHP_DESC_PRIVATE_DATA_SPECIFIER         0x5f
/* 0x60-0x7f: reserved to mhp futuer use */
/* 0x80-0xfe: user defined               */



/* added(bruin, 2003.02.17): dvb-rcs descriptors (ETSI EN 301 790 v1.2.2 table 29) */
#define DESC_NETWORK_LAYER_INFO                 0xa0
#define DESC_CORRECTION_MESSAGE                 0xa1
#define DESC_LOGON_INITIALIZE                   0xa2
#define DESC_ACQ_ASSIGN                         0xa3
#define DESC_SYNC_ASSIGN                        0xa4
#define DESC_ENCRYPTED_LOGON_ID                 0xa5
#define DESC_ECHO_VALUE                         0xa6
/* #define DESC_LINKAGE                         0x4a */ /* private extension to existing dvb descriptor */
#define DESC_RCS_CONTENT                        0xa7    /* in PMT */
#define DESC_SATELLITE_FORWARD_LINK             0xa8
#define DESC_SATELLITE_RETURN_LINK              0xa9
#define DESC_TABLE_UPDATE                       0xaa
#define DESC_CONTENTION_CONTROL                 0xab
#define DESC_CORRECTION_CONTROL                 0xac





/*** stream type definition: iso/iec 13818-1 table 2-36 ***/

#define STREAMTYPE_11172_VIDEO                  0x01
#define STREAMTYPE_13818_VIDEO                  0x02
#define STREAMTYPE_11172_AUDIO                  0x03
#define STREAMTYPE_13818_AUDIO                  0x04
#define STREAMTYPE_13818_PRIVATE                0x05
#define STREAMTYPE_13818_PES_PRIVATE            0x06
#define STREAMTYPE_13522_MHPEG                  0x07
#define STREAMTYPE_13818_DSMCC                  0x08
#define STREAMTYPE_ITU_222_1                    0x09
#define STREAMTYPE_13818_A                      0x0a
#define STREAMTYPE_13818_B                      0x0b
#define STREAMTYPE_13818_C                      0x0c
#define STREAMTYPE_13818_D                      0x0d
#define STREAMTYPE_13818_AUX                    0x0e
/* 0x00, 0x0f - 0x7f are iso/iec 13818-1 reserved */
/* 0x80 - 0xFF: user private */


/* TS packet header */

#define TS_HEADER_LEN                        4
typedef struct{
#ifdef WORDS_BIGENDIAN
    u8 sync_byte                            :8;   /* always be 0x47 */
    u8 transport_error_indicator            :1;   
    u8 payload_unit_start_indicator         :1;   /* if a PES-packet starts in the TS-packet */
    u8 transport_priority                   :1;   /* meanless to IRD, can be ignored */
    u8 pid_hi                               :5;
    u8 pid_lo                               :8;
    u8 transport_scrambling_control         :2;   /* 00: no scramble, 01: reserved, 
                                                           10: even key scrambled, 11: odd key scrambled */
    u8 adaptation_field_control             :2;   /* 00: reserved
                                                           01: no adaptation field, payload only
                                                           10: adaptation field only, no payload
                                                           11: adaptation field followed by payload */
    u8 continuity_counter                   :4;
#else
    u8 sync_byte                            :8;
    u8 pid_hi                               :5;
    u8 transport_priority                   :1;
    u8 payload_unit_start_indicator         :1;
    u8 transport_error_indicator            :1;
    u8 pid_lo                               :8;
    u8 continuity_counter                   :4;
    u8 adaptation_field_control             :2;
    u8 transport_scrambling_control         :2;
#endif
}PACKET_HEADER;
    

/* NIT section header */

#define NIT_SECT_HEADER_LEN                  10
typedef struct{
#ifdef WORDS_BIGENDIAN
    u8 table_id                             :8;
    u8 section_syntax_indicator             :1;
    u8                                      :3;
    u8 section_length_hi                    :4;
    u8 section_length_lo                    :8;
    u8 network_id_hi                        :8;
    u8 network_id_lo                        :8;
    u8                                      :2;
    u8 version_number                       :5;
    u8 current_next_indicator               :1;
    u8 section_number                       :8;
    u8 last_section_number                  :8;
    u8                                      :4;
    u8 network_descriptors_length_hi        :4;
    u8 network_descriptors_length_lo        :8;
    /* descriptors */
#else
    u8 table_id                             :8;
    u8 section_length_hi                    :4;
    u8                                      :3;
    u8 section_syntax_indicator             :1;
    u8 section_length_lo                    :8;
    u8 network_id_hi                        :8;
    u8 network_id_lo                        :8;
    u8 current_next_indicator               :1;
    u8 version_number                       :5;
    u8                                      :2;
    u8 section_number                       :8;
    u8 last_section_number                  :8;
    u8 network_descriptors_length_hi        :4;
    u8                                      :4;
    u8 network_descriptors_length_lo        :8;
    /* descriptors */
#endif
}NIT_SECT_HEADER;


/* PAT section header */

#define PAT_SECT_HEADER_LEN                  8
typedef struct{
#ifdef WORDS_BIGENDIAN
    u8 table_id                             :8;
    u8 section_syntax_indicator             :1;
    u8                                      :3;
    u8 section_length_hi                    :4;
    u8 section_length_lo                    :8;
    u8 transport_stream_id_hi               :8;
    u8 transport_stream_id_lo               :8;
    u8                                      :2;
    u8 version_number                       :5;
    u8 current_next_indicator               :1;
    u8 section_number                       :8;
    u8 last_section_number                  :8;
#else   
    u8 table_id                             :8;
    u8 section_length_hi                    :4;
    u8                                      :3;
    u8 section_syntax_indicator             :1;
    u8 section_length_lo                    :8;
    u8 transport_stream_id_hi               :8;
    u8 transport_stream_id_lo               :8;
    u8 current_next_indicator               :1;
    u8 version_number                       :5;
    u8                                      :2;
    u8 section_number                       :8;
    u8 last_section_number                  :8;
#endif
}PAT_SECT_HEADER;

/* CAT section header */

#define CAT_SECT_HEADER_LEN                  8
typedef struct{
#ifdef WORDS_BIGENDIAN
    u8 table_id                             :8;
    u8 section_syntax_indicator             :1;
    u8                                      :3;
    u8 section_length_hi                    :4;
    u8 section_length_lo                    :8;
    u8                                      :8;
    u8                                      :8;
    u8                                      :2;
    u8 version_number                       :5;
    u8 current_next_indicator               :1;
    u8 section_number                       :8;
    u8 last_section_number                  :8;
#else
    u8 table_id                             :8;
    u8 section_length_hi                    :4;
    u8                                      :3;
    u8 section_syntax_indicator             :1;
    u8 section_length_lo                    :8;
    u8                                      :8;
    u8                                      :8;
    u8 current_next_indicator               :1;
    u8 version_number                       :5;
    u8                                      :2;
    u8 section_number                       :8;
    u8 last_section_number                  :8;
#endif
}CAT_SECT_HEADER;
    
/* PMT section header */

#define PMT_SECT_HEADER_LEN                  12
typedef struct{
#ifdef WORDS_BIGENDIAN
    u8 table_id                             :8;
    u8 section_syntax_indicator             :1;
    u8                                      :3;
    u8 section_length_hi                    :4;
    u8 section_length_lo                    :8;
    u8 program_number_hi                    :8;
    u8 program_number_lo                    :8;
    u8                                      :2;
    u8 version_number                       :5;
    u8 current_next_indicator               :1;
    u8 section_number                       :8;
    u8 last_section_number                  :8;
    u8                                      :3;
    u8 pcr_pid_hi                           :5;
    u8 pcr_pid_lo                           :8;
    u8                                      :4;
    u8 program_info_length_hi               :4;
    u8 program_info_length_lo               :8;
#else   
    u8 table_id                             :8;
    u8 section_length_hi                    :4;
    u8                                      :3;
    u8 section_syntax_indicator             :1;
    u8 section_length_lo                    :8;
    u8 program_number_hi                    :8;
    u8 program_number_lo                    :8;
    u8 current_next_indicator               :1;
    u8 version_number                       :5;
    u8                                      :2;
    u8 section_number                       :8;
    u8 last_section_number                  :8;
    u8 pcr_pid_hi                           :5;
    u8                                      :3;
    u8 pcr_pid_lo                           :8;
    u8 program_info_length_hi               :4;
    u8                                      :4;
    u8 program_info_length_lo               :8;
#endif
}PMT_SECT_HEADER;


/* BAT section header */

#define BAT_SECT_HEADER_LEN                  10
typedef struct{
#ifdef WORDS_BIGENDIAN
    u8 table_id                             :8;
    u8 section_syntax_indicator             :1;
    u8                                      :3;
    u8 section_length_hi                    :4;
    u8 section_length_lo                    :8;
    u8 bouquet_id_hi                        :8;
    u8 bouquet_id_lo                        :8;
    u8                                      :2;
    u8 version_number                       :5;
    u8 current_next_indicator               :1;
    u8 section_number                       :8;
    u8 last_section_number                  :8;
    u8                                      :4;
    u8 bouquet_descriptors_length_hi        :4;
    u8 bouquet_descriptors_length_lo        :8;
#else
    u8 table_id                             :8;
    u8 section_length_hi                    :4;
    u8                                      :3;
    u8 section_syntax_indicator             :1;
    u8 section_length_lo                    :8;
    u8 bouquet_id_hi                        :8;
    u8 bouquet_id_lo                        :8;
    u8 current_next_indicator               :1;
    u8 version_number                       :5;
    u8                                      :2;
    u8 section_number                       :8;
    u8 last_section_number                  :8;
    u8 bouquet_descriptors_length_hi        :4;
    u8                                      :4;
    u8 bouquet_descriptors_length_lo        :8;
#endif
}BAT_SECT_HEADER;


/* SDT section header */

#define SDT_SECT_HEADER_LEN                  11
typedef struct{
#ifdef WORDS_BIGENDIAN
    u8 table_id                             :8;
    u8 section_syntax_indicator             :1;
    u8                                      :3;
    u8 section_length_hi                    :4;
    u8 section_length_lo                    :8;
    u8 transport_stream_id_hi               :8;
    u8 transport_stream_id_lo               :8;
    u8                                      :2;
    u8 version_number                       :5;
    u8 current_next_indicator               :1;
    u8 section_number                       :8;
    u8 last_section_number                  :8;
    u8 original_network_id_hi               :8;
    u8 original_network_id_lo               :8;
    u8                                      :8;
#else
    u8 table_id                             :8;
    u8 section_length_hi                    :4;
    u8                                      :3;
    u8 section_syntax_indicator             :1;
    u8 section_length_lo                    :8;
    u8 transport_stream_id_hi               :8;
    u8 transport_stream_id_lo               :8;
    u8 current_next_indicator               :1;
    u8 version_number                       :5;
    u8                                      :2;
    u8 section_number                       :8;
    u8 last_section_number                  :8;
    u8 original_network_id_hi               :8;
    u8 original_network_id_lo               :8;
    u8                                      :8;
#endif
}SDT_SECT_HEADER;


/* EIT section header */

#define EIT_SECT_HEADER_LEN                  14
typedef struct{
#ifdef WORDS_BIGENDIAN
    u8 table_id                             :8;
    u8 section_syntax_indicator             :1;
    u8                                      :3;
    u8 section_length_hi                    :4;
    u8 section_length_lo                    :8;
    u8 service_id_hi                        :8;
    u8 service_id_lo                        :8;
    u8                                      :2;
    u8 version_number                       :5;
    u8 current_next_indicator               :1;
    u8 section_number                       :8;
    u8 last_section_number                  :8;
    u8 transport_stream_id_hi               :8;
    u8 transport_stream_id_lo               :8;
    u8 original_network_id_hi               :8;
    u8 original_network_id_lo               :8;
    u8 segment_last_section_number          :8;
    u8 last_table_id                        :8;
#else
    u8 table_id                             :8;
    u8 section_length_hi                    :4;
    u8                                      :3;
    u8 section_syntax_indicator             :1;
    u8 section_length_lo                    :8;
    u8 service_id_hi                        :8;
    u8 service_id_lo                        :8;
    u8 current_next_indicator               :1;
    u8 version_number                       :5;
    u8                                      :2;
    u8 section_number                       :8;
    u8 last_section_number                  :8;
    u8 transport_stream_id_hi               :8;
    u8 transport_stream_id_lo               :8;
    u8 original_network_id_hi               :8;
    u8 original_network_id_lo               :8;
    u8 segment_last_section_number          :8;
    u8 last_table_id                        :8;
#endif
}EIT_SECT_HEADER;


/* TDT section */

typedef struct{
#ifdef WORDS_BIGENDIAN
    u8 table_id                             :8;
    u8 section_syntax_indicator             :1;
    u8                                      :3;
    u8 section_length_hi                    :4;
    u8 section_length_lo                    :8;
    u8 utc_time[5];
#else
    u8 table_id                             :8;
    u8 section_length_hi                    :4;
    u8                                      :3;
    u8 section_syntax_indicator             :1;
    u8 section_length_lo                    :8;
    u8 utc_time[5];
#endif
}TDT_SECTION;


/* TOT section header */

#define TOT_SECT_HEADER_LEN                  10
typedef struct{
#ifdef WORDS_BIGENDIAN
    u8 table_id                             :8;
    u8 section_syntax_indicator             :1;
    u8                                      :3;
    u8 section_length_hi                    :4;
    u8 section_length_lo                    :8;
    u8 utc_time[5];
    u8                                      :4;
    u8 descriptors_loop_length_hi           :4;
    u8 descriptors_loop_length_lo           :8;
#else
    u8 table_id                             :8;
    u8 section_length_hi                    :4;
    u8                                      :3;
    u8 section_syntax_indicator             :1;
    u8 section_length_lo                    :8;
    u8 utc_time[5];
    u8 descriptors_loop_length_hi           :4;
    u8                                      :4;
    u8 descriptors_loop_length_lo           :8;
#endif
}TOT_SECT_HEADER;

/* RST section header */

#define RST_SECT_HEADER_LEN                  3
typedef struct{
#ifdef WORDS_BIGENDIAN
    u8 table_id                             :8;
    u8 section_syntax_indicator             :1;
    u8                                      :3;
    u8 section_length_hi                    :4;
    u8 section_length_lo                    :8;
#else
    u8 table_id                             :8;
    u8 section_length_hi                    :4;
    u8                                      :3;
    u8 section_syntax_indicator             :1;
    u8 section_length_lo                    :8;
#endif
}RST_SECT_HEADER;

#define RST_OF_EVENT_SIZE                    9;
typedef struct{
#ifdef WORDS_BIGENDIAN
    u8 transport_stream_id_hi               :8;
    u8 transport_stream_id_lo               :8;
    u8 original_network_id_hi               :8;
    u8 original_network_id_lo               :8;
    u8 service_id_hi                        :8;
    u8 service_id_lo                        :8;
    u8 event_id_hi                          :8;
    u8 event_id_lo                          :8;
    u8                                      :5;
    u8 running_status                       :3;
#else
    u8 transport_stream_id_hi               :8;
    u8 transport_stream_id_lo               :8;
    u8 original_network_id_hi               :8;
    u8 original_network_id_lo               :8;
    u8 service_id_hi                        :8;
    u8 service_id_lo                        :8;
    u8 event_id_hi                          :8;
    u8 event_id_lo                          :8;
    u8 running_status                       :3;
    u8                                      :5;
#endif
}RST_OF_EVENT;



/* AIT section header */   /* added(bruin, 2003.01.13) */

#define AIT_SECT_HEADER_LEN                  10
typedef struct{
#ifdef WORDS_BIGENDIAN
    u8 table_id                             :8;
    u8 section_syntax_indicator             :1;
    u8                                      :3;
    u8 section_length_hi                    :4;
    u8 section_length_lo                    :8;
    u8 application_type_hi                  :8;
    u8 application_type_lo                  :8;
    u8                                      :2;
    u8 version_number                       :5;
    u8 current_next_indicator               :1;
    u8 section_number                       :8;
    u8 last_section_number                  :8;
    u8                                      :4;
    u8 common_descriptors_length_hi         :4;
    u8 common_descriptors_length_lo         :8;
#else   
    u8 table_id                             :8;
    u8 section_length_hi                    :4;
    u8                                      :3;
    u8 section_syntax_indicator             :1;
    u8 section_length_lo                    :8;
    u8 application_type_hi                  :8;
    u8 application_type_lo                  :8;
    u8 current_next_indicator               :1;
    u8 version_number                       :5;
    u8                                      :2;
    u8 section_number                       :8;
    u8 last_section_number                  :8;
    u8 common_descriptors_length_hi         :4;
    u8                                      :4;
    u8 common_descriptors_length_lo         :8;
#endif
}AIT_SECT_HEADER;


                                               
/*** struct of descriptors ***/

/* 13818 descriptors */
typedef struct{
#ifdef WORDS_BIGENDIAN
    u8 descriptor_tag                       :8;
    u8 descriptor_length                    :8;
    u8 multiple_frame_rate_flag             :1;
    u8 frame_rate_code                      :4;
    u8 mpeg_1_only_flag                     :1;
    u8 constrained_parameter_flag           :1;
    u8 still_picture_flag                   :1;
    /* only if(mpeg_1_only_flag == 0) */        
    u8 profile_and_level_indication         :8;
    u8 chroma_format                        :2;
    u8 frame_rate_extension_flag            :1;
    u8                                      :5;
#else
    u8 descriptor_tag                       :8;
    u8 descriptor_length                    :8;
    u8 still_picture_flag                   :1;
    u8 constrained_parameter_flag           :1;
    u8 mpeg_1_only_flag                     :1;
    u8 frame_rate_code                      :4;
    u8 multiple_frame_rate_flag             :1;
    /* only if(mpeg_1_only_flag == 0) */        
    u8 profile_and_level_indication         :8;
    u8                                      :5;
    u8 frame_rate_extension_flag            :1;
    u8 chroma_format                        :2;
#endif
}VIDEO_STREAM_DESC;

typedef struct{
#ifdef WORDS_BIGENDIAN
    u8 descriptor_tag                       :8;
    u8 descriptor_length                    :8;
    u8 free_format_flag                     :1;
    u8 id                                   :1;
    u8 layer                                :2;
    u8 variable_rate_audio_indicator        :1;
    u8                                      :3;
#else
    u8 descriptor_tag                       :8;
    u8 descriptor_length                    :8;
    u8                                      :3;
    u8 variable_rate_audio_indicator        :1;
    u8 layer                                :2;
    u8 id                                   :1;
    u8 free_format_flag                     :1;
#endif
}AUDIO_STREAM_DESC;

typedef struct{
#ifdef WORDS_BIGENDIAN
    u8 descriptor_tag                       :8;
    u8 descriptor_length                    :8;
    u8                                      :4;
    u8 hierarchy_type                       :4;
    u8                                      :2;
    u8 hierarchy_layer_index                :6;
    u8                                      :2;
    u8 hierarchy_embedded_layer             :6;
    u8                                      :2;
    u8 hierarchy_priority                   :6;
#else
    u8 descriptor_tag                       :8;
    u8 descriptor_length                    :8;
    u8 hierarchy_type                       :4;
    u8                                      :4;
    u8 hierarchy_layer_index                :6;
    u8                                      :2;
    u8 hierarchy_embedded_layer             :6;
    u8                                      :2;
    u8 hierarchy_priority                   :6;
    u8                                      :2;
#endif
}HIERARCHY_DESC;

typedef struct{
    u8 descriptor_tag;
    u8 descriptor_length;
    u8 format_identifier[4];
}REGISTRATION_DESC_HEADER;

typedef struct{
    u8 descriptor_tag;
    u8 descriptor_length;
    u8 alignment_type;          
}DATA_STREAM_ALIGNMENT_DESC;

typedef struct{
#ifdef WORDS_BIGENDIAN
    u8 descriptor_tag                       :8;
    u8 descriptor_length                    :8;
    u8 horizontal_size_hi                   :8;
    u8 horizontal_size_lo                   :6;
    u8 vertical_size_hi                     :2;
    u8 vertical_size_mi                     :8;
    u8 vertical_size_lo                     :4;
    u8 aspect_ratio_information             :4;
#else
    u8 descriptor_tag                       :8;
    u8 descriptor_length                    :8;
    u8 horizontal_size_hi                   :8;
    u8 vertical_size_hi                     :2;
    u8 horizontal_size_lo                   :6;
    u8 vertical_size_mi                     :8;
    u8 aspect_ratio_information             :4;
    u8 vertical_size_lo                     :4;
#endif
}TARGET_BACKGROUND_GRID_DESC;

typedef struct{
#ifdef WORDS_BIGENDIAN
    u8 descriptor_tag                       :8;
    u8 descriptor_length                    :8;
    u8 horizontal_offset_hi                 :8;
    u8 horizontal_offset_lo                 :6;
    u8 vertical_offset_hi                   :2;
    u8 vertical_offset_mi                   :8;
    u8 vertical_offset_lo                   :4;
    u8 window_priority                      :4;
#else
    u8 descriptor_tag                       :8;
    u8 descriptor_length                    :8;
    u8 horizontal_offset_hi                 :8;
    u8 vertical_offset_hi                   :2;
    u8 horizontal_offset_lo                 :6;
    u8 vertical_offset_mi                   :8;
    u8 window_priority                      :4;
    u8 vertical_offset_lo                   :4;
#endif
}VIDEO_WINDOW_DESC;

typedef struct{
#ifdef WORDS_BIGENDIAN
    u8 descriptor_tag                       :8;
    u8 descriptor_length                    :8;
    u8 ca_system_id_hi                      :8;
    u8 ca_system_id_lo                      :8;
    u8                                      :3; 
    u8 ca_pid_hi                            :5;
    u8 ca_pid_lo                            :8;
#else
    u8 descriptor_tag                       :8;
    u8 descriptor_length                    :8;
    u8 ca_system_id_hi                      :8;
    u8 ca_system_id_lo                      :8;
    u8 ca_pid_hi                            :5;
    u8                                      :3; 
    u8 ca_pid_lo                            :8;
#endif
}CA_DESC_HEADER;

typedef struct{
    u8 descriptor_tag                       :8;
    u8 descriptor_length                    :8;
}ISO_639_LANGUAGE_DESC_HEADER;

typedef struct{
#ifdef WORDS_BIGENDIAN
    u8 descriptor_tag                       :8;
    u8 descriptor_length                    :8;
    u8 external_clock_reference_indicator   :1;
    u8                                      :1;
    u8 clock_accuracy_integer               :6;
    u8 clock_accuracy_exponent              :3;
    u8                                      :5;
#else
    u8 descriptor_tag                       :8;
    u8 descriptor_length                    :8;
    u8 clock_accuracy_integer               :6;
    u8                                      :1;
    u8 external_clock_reference_indicator   :1;
    u8                                      :5;
    u8 clock_accuracy_exponent              :3;
#endif
}SYSTEM_CLOCK_DESC;

typedef struct{
#ifdef WORDS_BIGENDIAN
    u8 descriptor_tag                       :8;
    u8 descriptor_length                    :8;
    u8 bound_valid_flag                     :1;
    u8 ltw_offset_lower_bound_hi            :7;
    u8 ltw_offset_lower_bound_lo            :8;
    u8                                      :1;
    u8 ltw_offset_upper_bound_hi            :7;
    u8 ltw_offset_upper_bound_lo            :8;
#else
    u8 descriptor_tag                       :8;
    u8 descriptor_length                    :8;
    u8 ltw_offset_lower_bound_hi            :7;
    u8 bound_valid_flag                     :1;
    u8 ltw_offset_lower_bound_lo            :8;
    u8 ltw_offset_upper_bound_hi            :7;
    u8                                      :1;
    u8 ltw_offset_upper_bound_lo            :8;
#endif
}MULTIPLEX_BUFFER_UTILIZATION_DESC;

typedef struct{
    u8 descriptor_tag                       :8;
    u8 descriptor_length                    :8;
    u8 copyright_identifier[4];
}COPYRIGHT_DESC_HEADER;

typedef struct{
#ifdef WORDS_BIGENDIAN
    u8 descriptor_tag                       :8;
    u8 descriptor_length                    :8;
    u8                                      :2;
    u8 maximum_bitrate_hi                   :6; /* unit: 50 bps */
    u8 maximum_bitrate_mi                   :8;
    u8 maximum_bitrate_lo                   :8;
#else
    u8 descriptor_tag                       :8;
    u8 descriptor_length                    :8;
    u8 maximum_bitrate_hi                   :6;
    u8                                      :2;
    u8 maximum_bitrate_mi                   :8;
    u8 maximum_bitrate_lo                   :8;
#endif
}MAXIMUM_BITRATE_DESC;

typedef struct{
    u8 descriptor_tag                       :8;
    u8 descriptor_length                    :8;
    u8 private_data_indicator[4];
}PRIVATE_DATA_INDICATOR_DESC;

typedef struct{
#ifdef WORDS_BIGENDIAN
    u8 descriptor_tag                       :8;
    u8 descriptor_length                    :8;
    u8                                      :2;
    u8 sb_leak_rate_hi                      :6;  /* unit: 400 bps */
    u8 sb_leak_rate_mi                      :8;
    u8 sb_leak_rate_lo                      :8;
    u8                                      :2;
    u8 sb_size_hi                           :6;  /* unit: 1 byte */
    u8 sb_size_mi                           :8;
    u8 sb_size_lo                           :8;
#else
    u8 descriptor_tag                       :8;
    u8 descriptor_length                    :8;
    u8 sb_leak_rate_hi                      :6;  /* unit: 400 bps */
    u8                                      :2;
    u8 sb_leak_rate_mi                      :8;
    u8 sb_leak_rate_lo                      :8;
    u8 sb_size_hi                           :6;  /* unit: 1 byte */
    u8                                      :2;
    u8 sb_size_mi                           :8;
    u8 sb_size_lo                           :8;
#endif
}SMOOTHING_BUFFER_DESC;

typedef struct{
#ifdef WORDS_BIGENDIAN
    u8 descriptor_tag                       :8;
    u8 descriptor_length                    :8;
    u8                                      :7;
    u8 leak_valid_flag                      :1;
#else
    u8 descriptor_tag                       :8;
    u8 descriptor_length                    :8;
    u8 leak_valid_flag                      :1;
    u8                                      :7;
#endif
}STD_DESC;

typedef struct{
#ifdef WORDS_BIGENDIAN
    u8 descriptor_tag                       :8;
    u8 descriptor_length                    :8;
    u8 closed_gop_flag                      :1;
    u8 identical_gop_flag                   :1;
    u8 max_gop_length_hi                    :6;
    u8 max_gop_length_lo                    :8;
#else
    u8 descriptor_tag                       :8;
    u8 descriptor_length                    :8;
    u8 max_gop_length_hi                    :6;
    u8 identical_gop_flag                   :1;
    u8 closed_gop_flag                      :1;
    u8 max_gop_length_lo                    :8;
#endif
}IBP_DESC;

/* dvb-si descriptors */
/* TBD */




/* opentv private descriptors */

typedef struct{
    u8 descriptor_tag                       :8;
    u8 descriptor_length                    :8;
    u8 track_tag[4];
}OPENTV_TRACK_TAG_DESC;



/* macro to access packet header fields */

#define packet_sync_byte(x)    (((PACKET_HEADER*)(x))->sync_byte)
#define packet_transport_error_indicator(x) (((PACKET_HEADER*)(x))->transport_error_indicator)
#define packet_payload_unit_start_indicator(x)    (((PACKET_HEADER*)(x))->payload_unit_start_indicator)
#define packet_transport_priority(x) (((PACKET_HEADER*)(x))->transport_priority)
#define packet_pid(x) (((PACKET_HEADER*)(x))->pid_hi * 256 + ((PACKET_HEADER*)(x))->pid_lo)
#define packet_transport_scrambling_control(x) (((PACKET_HEADER*)(x))->transport_scrambling_control)
#define packet_adaptation_field_control(x) (((PACKET_HEADER*)(x))->adaptation_field_control)
#define packet_continuity_counter(x) (((PACKET_HEADER*)(x))->continuity_counter)


/* misc routines */

#ifdef __cplusplus
extern "C"{
#endif

const char* get_pid_name_by_id(u16 pid);
const char* get_tid_name_by_id(u8 table_id);
const char* get_desc_name_by_id(u8 desc_id);
const char* get_stream_type_name_by_id(u8 type_id);
const char* get_frame_rate_by_code(u8 code);
const char* get_chroma_format_by_code(u8 code);
const char* get_video_profile_by_code(u8 code);
const char* get_video_level_by_code(u8 code);
const char* get_audio_type_by_code(u8 code);
const char* get_aspect_ratio_information_by_code(u8 code);
const char* get_running_status_by_code(u8 code);
char* get_string_by_utc_time(u8 utc_time[5]);
const char* get_outer_fec_scheme_by_code(u8 code);
const char* get_inner_fec_scheme_by_code(u8 code);
const char* get_cable_modulation_scheme_by_code(u8 code);
const char* get_satellite_modulation_scheme_by_code(u8 code);
const char* get_polariztion_by_code(u8 code);
const char* get_service_type_by_code(u8 code);
const char* get_linkage_type_by_code(u8 code);
const char* get_hand_over_type_by_code(u8 code);
const char* get_content_nibble_name_by_code(u8 code, int is_level_1);
const char* get_minimum_age_by_rating(u8 rating);
const char* get_application_id_name_by_id(u16 id);
const char* get_transport_protocol_id_name_by_id(u16 id);

/* added(bruin, 2003.01.13): mhp 1.1 AIT */
const char* get_application_type_by_code(u16 type); 
const char* get_application_control_code_name(u16 application_type, u8 control_code);

u16 get_pid_of_tid(u8 tid);

const char* get_mhp_desc_name_by_id(u8 desc_id);

/* added(bruin, 2003.02.17): dvb-rcs */
const char* get_rcs_desc_name_by_id(u8 desc_id);
const char* get_rcs_tid_name_by_id(u8 tid);

/* added(bruin, 2003.12.19): terrestrial_delivery_system_descriptor */
const char* get_terrestrial_bandwidth_by_code(u8 code);
const char* get_terrestrial_constellation_pattern_by_code(u8 code);
const char* get_terrestrial_hierarchy_information_by_code(u8 code);
const char* get_terrestrial_code_rate_by_code(u8 code);
const char* get_terrestrial_guard_interval_by_code(u8 code);
const char* get_terrestrial_transmission_mode_by_code(u8 code);

#ifdef __cplusplus
}
#endif




#endif   /* __SI_H__ */
