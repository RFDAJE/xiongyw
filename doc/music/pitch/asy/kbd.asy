/* created(bruin, 2007-01-31): piano keyboard in one octave.
 *
 * $Id: kbd.asy 2 2007-03-22 12:54:39Z Administrator $
 */

unitsize(10);
//defaultpen(basealign(1));

real wd_wt = 2;   // width of white key
real wd_bk = 1.4; // width of black key
real ht_wt = 5;   // height of white key
real ht_bk = 3;   // height of black key, N align with white key
real rd_wt = .2;  // round size of white key
real rd_bk = .1;  // round size of black key
real off_x = wd_wt-wd_bk/2.; // x offset of black key from left
real off_y = ht_wt - ht_bk;  // y offset of black key from bottom

int i;

/* white keys */
for(i = 1; i <= 8; ++ i){
	draw((i*wd_wt,rd_wt)--(i*wd_wt+rd_wt,0)--((i+1)*wd_wt-rd_wt,0)--((i+1)*wd_wt,rd_wt)--((i+1)*wd_wt,ht_wt)--(i*wd_wt,ht_wt)--cycle);
	if(i == 1)
		label("$\mathrm{c}$", (i*wd_wt+wd_wt/2,.3), N);
	else if(i == 2)
		label("$\mathrm{d}$", (i*wd_wt+wd_wt/2,.3), N);
	else if(i == 3)
		label("$\mathrm{e}$", (i*wd_wt+wd_wt/2,.3), N);
	else if(i == 4)
		label("$\mathrm{f}$", (i*wd_wt+wd_wt/2,.3), N);
	else if(i == 5)
		label("$\mathrm{g}$", (i*wd_wt+wd_wt/2,.3), N);
	else if(i == 6)
		label("$\mathrm{a}$", (i*wd_wt+wd_wt/2,.3), N);
	else if(i == 7)
		label("$\mathrm{b}$", (i*wd_wt+wd_wt/2,.3), N);
	else
		label("$\mathrm{c}^1$", (i*wd_wt+wd_wt/2,.3), N);
}

/* black keys */
for(i = 1; i <= 7; ++i){
	if(i == 3)
		continue;
		
	if(i == 7){
		filldraw((8*wd_wt+off_x,off_y+rd_bk)--(8*wd_wt+off_x+rd_bk,off_y)--(8*wd_wt+off_x+wd_bk/2,off_y)--(8*wd_wt+off_x+wd_bk/2,ht_wt)--(8*wd_wt+off_x,ht_wt)--cycle);	
	}
	else{
		filldraw((i*wd_wt+off_x,off_y+rd_bk)--(i*wd_wt+off_x+rd_bk,off_y)--(i*wd_wt+off_x+wd_bk-rd_bk,off_y)--(i*wd_wt+off_x+wd_bk,off_y+rd_bk)--(i*wd_wt+off_x+wd_bk,ht_wt)--(i*wd_wt+off_x,ht_wt)--cycle);
		/*
		if(i == 1)
			label("$^\sharp\mathrm{c}$", ((i+1)*wd_wt,ht_wt-ht_bk+.3), N, gray(1));
		else if(i == 2)
			label("$^\sharp\mathrm{d}$", ((i+1)*wd_wt,ht_wt-ht_bk+.3), N, white);
		else if(i == 4)
			label("$^\sharp\mathrm{f}$", ((i+1)*wd_wt,ht_wt-ht_bk+.3), N, white);
		else if(i == 5)
			label("$^\sharp\mathrm{g}$", ((i+1)*wd_wt,ht_wt-ht_bk+.3), N, white);
		else
			label("$^\sharp\mathrm{a}$", ((i+1)*wd_wt,ht_wt-ht_bk+.3), N, white);
		*/
	}
}
