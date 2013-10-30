/*
** Copyright (C) 2004 Yuwu (Bruin) Xiong <xiongyw@hotmail.com>
**  
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
** (at your option) any later version.
** 
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
** 
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software 
** Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
*/

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <malloc.h>
#include <string.h>
#include <math.h>
#include <stdio.h>

#include "bmp2jpg.h"


void version(void){
	printf("bmp2jpg version 0.1.0 from 2002.11.24\n");
	printf("by Yuwu Xiong, xiongyw@hotmail.com\n\n");
}

void usage(void){
	printf("usage: bmp2jpg -i bmp_file_name -o jpg_file_name\n\n");
}

int main(int argc, char* argv[]){

	BYTE  *p;
	FILE  *fi, *fo;
	int   bmpsize;

	version();

	if(argc != 5){
		usage();
		return - 1;
	}

	/* read the whole bmp file into memory */
	fi = fopen(argv[2], "rb");
	if(!fi){
		printf("input bmp file %s can not be opened.\n",  argv[2]);
		return - 1;
	}

	fseek(fi, 0, SEEK_END);
	bmpsize = ftell(fi);
	fseek(fi, 0, SEEK_SET);
	printf("input bmp file %s size=%d\n", argv[2], bmpsize);

	p = (BYTE*)malloc(bmpsize);
	if(!p){
		printf("malloc error\n");
		return - 1;
	}
	if(1 != fread(p, bmpsize, 1, fi)){
		printf("read file error.\n");
		free(p);
		fclose(fi);
		return - 1;
	}
	fclose(fi);


	/* open output file */
	fo = fopen(argv[4], "wb");
	if(!fo){
		printf("can not open file %s for saving jpeg image\n", argv[4]);
		return - 1;
	}

	bmp2jpeg(p, fo);
	free(p);
	fclose(fo);
	return 0;

}
