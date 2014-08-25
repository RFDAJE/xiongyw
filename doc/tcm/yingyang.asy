import math;

int i;
int n=12;
pair ss=(0,-1), nn=(0,1), ww=(-1,0), ee=(1,0);
pair[]  roots;
pair[] inters;
size(200,0);
for(i=0;i<n;++i){
    roots[i] = unityroot(n,i);
    //write(roots[i]);
}

/*
 * 据《周髀算经》，八尺表杆正午晷长:
 * - 冬至 (winter solstice): 1.35丈
 * - 夏至 (summer solstice): 0.16丈
 * - 24节气的晷长为等差数列，公差为：(1.3-0.16)/12=0.0991666666丈，亦即 9.9分1小分
 *
 * 注：1丈=10尺=3.33333米；1尺=10寸；1寸=10分；1分=6小分
 */

real[] gui24;
real summer = 0.16;
real winter = 1.35;
real common_difference = 0.099 + 0.001/6;
for(i = 0; i < 12; ++ i)
    gui24[i] = summer + common_difference * i;
for(i = 12; i < 24; ++ i)
    gui24[i] = winter - common_difference * (i - 12);

for(i = 0; i < 24; ++ i)
    write(gui24[i]); 

real[] gui24_norm;  // set summer=0 and then normalize the array
for(i = 0; i < 24; ++ i){
    gui24_norm[i] = (gui24[i] - summer) / (winter - summer);
    write(gui24_norm[i]);
}



for(i=1; i<4;++i){

                inters[i]=extension((0,0),roots[i], nn, roots[i-1]);

                write(inters[i]);

}

 

 

draw(unitcircle);

draw(inters[1]--inters[2]--inters[3]);