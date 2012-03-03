/* created(bruin, 2008-05-16): library for drawing maps.
   $Id$
 */
import three;
import surface;
import math;
import patterns;


/*------------------------------------
 * constant definitions 
 *-----------------------------------*/
 
real EARTH_RADIUS = 6371004.00;  /* average earth radius in meters */

/* type of tracks */
int DEFAULT_TRACK  = 0;
int EXPRESSWAY     = 1;
int NATION_ROAD    = 2;
int PROVINCE_ROAD  = 3;
int COUNTY_ROAD    = 4; 
int VILLAGE_ROAD   = 5;
int URBAN_EXPRESS  = 6;
int URBAN_AVENUE   = 7;
int URBAN_STREET   = 8;
int URBAN_LANE     = 9;
int RAILWAY        = 10;
int RIVER          = 11;
int LAKE           = 12;
int LAST_TRACK_TYPE = 13;  /* beyond this (inclusive) are not defined, use DEFAULT_TRACK */

/*------------------------------------
 * function definitions 
 *-----------------------------------*/

triple mydir(real latitude, real longitude)
{
	return dir(90.-latitude, longitude);
}

triple mypoint(real latitude, real longitude, real elevation)
{
	return EARTH_RADIUS * mydir(latitude, longitude) + (0, 0, elevation);
}

void draw_railway(real[] track)
{
	guide3 gc, gc2, gl, gr, go;  /* center, new center, left, right, outline */
	triple pc, pl, pr;
	triple tang, direct;
	real dx, dy, dz = 0;
  real width = 1.435;  /* 中国铁轨大多为1435毫米 */
  real seg_len = width * 4;   
	
	/* get gc */
	for(int i = 0; i < track.length / 3; ++ i){
		pc = mypoint(track[3*i], track[3*i+1], track[3*i+2]);
		gc=gc..pc;
	}
	
	/* get gc2 (with evenly distributed nodes) */
	gc2=gc2..point(gc, 0);
	for(int i = 0; i < arclength(gc) / seg_len; ++ i){
		real idx = arctime(gc, seg_len * (i + 1));
		triple p = point(gc, idx);
		gc2=gc2..p;
	}

	/* calculate gl and gr */
	width /= 2.;
	for(int i = 0; i < size(gc2); ++ i){
		pc = point(gc2, i);
		tang = dir(gc2, i, 0);
		direct = cross(unit(pc), tang);
		dx = width * direct.x;
		dy = width * direct.y;
		dz = width * direct.z;
		pl = pc - (dx, dy, dz);
		pr = pc + (dx, dy, dz);
		gl = gl..pl;
		gr = gr..pr;
	}

	/* cycle gl & gr */	
	go=gl--reverse(gr)--cycle;

	/* draw the outline */
	draw(go, linewidth(0.01) + black + linecap(0));

	/* fill even segments with black */	
	for(int i = 0; i < size(gc2); i += 2){
		guide3 blackl = subpath(gl, i, i + 1);
		guide3 blackr = subpath(gr, i, i + 1);
		guide3 segment = blackl--reverse(blackr)--cycle;
		filldraw(segment, black, invisible);
	}	
}

void draw_track(real[] track, real width, bool is_circle, int type)
{
	guide3 gc, gl, gr;  /* center, left, right */
	triple pc, pl, pr;
	triple tang, direct;
	real dx, dy, dz = 0;
	
	if(type == RAILWAY){
		draw_railway(track);
		return;
	}
	
	/* get gc */
	for(int i = 0; i < track.length / 3; ++ i){
		pc = mypoint(track[3*i], track[3*i+1], track[3*i+2]);
		gc=gc..pc;
	}
	
	if(is_circle){
		gc=gc..cycle;
	}
	
	/* calculate gl and gr */
	width /= 2.;
	for(int i = 0; i < size(gc); ++ i){
		pc = point(gc, i);
		tang = dir(gc, i, 0);
		direct = cross(unit(pc), tang);
		dx = width * direct.x;
		dy = width * direct.y;
		dz = width * direct.z;
		pl = pc - (dx, dy, dz);
		pr = pc + (dx, dy, dz);
		gl = gl..pl;
		gr = gr..pr;
	}
	
	if(is_circle){
		gl=gl..cycle;
		gr=gr..cycle;
	}
	else{
		/* cycle gl & gr */	
		gl=gl--reverse(gr)--cycle;
	}
	
	/*
	 * determine pens for each track type;
	 */

	/* default pens */
  pen penc = linewidth(0.01) + linecap(0); /* pen for center line */
  pen peno = penc; /* pen for outline */
  pen penf = grey; /* pen for fill */

  /* pen for cirle denoting nodes in the path */
  pen pend = linewidth(0.01) + grey + linecap(0); 

	if(type < 0 || type >= LAST_TRACK_TYPE){
		type = DEFAULT_TRACK;
	}
	
	if(type == EXPRESSWAY){
			penc = linewidth(0.01) + red + linecap(0); /* square cap */
			peno = penc;
			penf = yellow;
	}
	else if(type == NATION_ROAD){
			peno = linewidth(0.01) + black + linecap(0); 
			penf = brown;
	}
	else if(type == PROVINCE_ROAD){
			peno = linewidth(0.01) + darkgreen + linecap(0); 
			penf = green;
	}
	else if(type == COUNTY_ROAD){
			peno = linewidth(0.01) + brown + linecap(0); 
			penf = orange;
	}
	else if(type == URBAN_EXPRESS){
			peno = linewidth(0.01) + orange + linecap(0); 
			penf = yellow;
	}	
	else if(type == RIVER || type == LAKE){
			peno = linewidth(0.01) + royalblue + linecap(0); 
			penf = lightcyan;
	}
	else{
		;
	}


	/*
	 * start drawing 
	 */

	if(is_circle){
		if(type == LAKE){
			filldraw(gc, penf, peno);
		}
		else{
	  	filldraw(gr^^gl,evenodd+penf, peno);
		}
	}
	else{
		filldraw(gl, penf, peno);
	}

	if(type == EXPRESSWAY){
		draw(gc, penc);
	}
	
	/*
	for(int i = 0; i < size(gc); ++ i){
			draw(circle(point(gc,i), 0.5));
	}
	*/
}













