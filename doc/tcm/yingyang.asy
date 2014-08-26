/*
 * created(bruin, 2014-08-25)
 * last updated(bruin, 2014-08-25)
 *
 * 据《周髀算经》，八尺表杆正午晷长:
 * - 冬至 (winter solstice): 1.35丈
 * - 夏至 (summer solstice): 0.16丈
 * - 24节气的晷长为等差数列，公差为：(1.3-0.16)/12=0.0991666666丈，亦即 9.9分1小分
 * 注：1丈=10尺=3.33333米；1尺=10寸；1寸=10分；1分=6小分
 *
 * 若“标准化”晷长，即以夏至为0，冬至为1，则公差为1/12。
 * 取上北下南左西右东，即冬至为北、夏至为南、春分为东、秋分为西，则以冬至为首以顺时针
 * 为序，各节气的标准化晷长为：
 * 冬至，小寒，大寒，立春，雨水，惊蛰，春分，清明，谷雨，立夏，小满，芒种：1 ~  1/12
 * 夏至，小暑，大暑，立秋，处暑，白露，秋分，寒露，霜降，立冬，小雪，大雪：0 ~ 11/12
 *
 * 但等差数列得出的并不是传统的阴阳图。若采用cos()函数计算晷长序列，得出的图更符合惯例。
 * 这里分别定义两种计算晷长序列。
 */

 
import math;

size(1000,0);

int n5 = 5, n8 = 8, n12 = 12, n24 = 24, n64 = 64;
pair O=0, S=(0,-1), N=(0,1), W=(-1,0), E=(1,0);
int i;


// return the length of the shadow of GUI, as an arithmetic progression.
// radius range: (0, pi), where,
// - 0 present winter soltice, with fixed value 1.0,
// - pi present summer soltice, with fixed value 0; 
// and this function provides other values in between.
// notes: why pi not 2 pi? because the rest half circle is just a mirror;
real gui_arithmetic(real radius)
{
	if(radius < 0 || radius > pi){
		return 0;
	}
	
	return (1. -radius / pi);
}

// return the length of the shadow of GUI, employing cos() function.
real gui_sine(real radius)
{
	if(radius < 0 || radius > pi){
		return 0;
	}
	
	return cos(radius / 2.);
}

// this function returns a cyclic guide for the fish curve, which starts from winter soltice (0, 1),
// goes through the circle, passing through the summer soltice (0, -1), and then goes back to 
// the winter soltice by following the left part of the circumference of the circle.
// the nodes in the guide are in CW order.
// n: 1/4 of the number of points around the circle. 
guide fish(int n, real gui_interp(real)) 
{
	int i;
	
	// 1. determine the array of shadow length, starting from winter solstice, in CW order
	real[] gui;  
	for(i = 0; i < n * 4; ++ i){
		real rad = radians(90. / n * i);
		if(rad > pi){
			rad = rad - pi;
		}
    	gui[i] = gui_interp(rad);
		//write(gui[i]);
	}

	// 2. obtain the direction for each point, respective to the shadow array.
	pair[] roots;
	for(i = 0; i < n * 4; ++ i){
		roots[i] = unityroot(n * 4, i);  // starting from (1,0), in CCW order
	}
	
	// make it starts from winter soltice and in CW order, by indexing an array by an array
	//int[] index24 = {6, 5, 4, 3, 2, 1, 0, 23, 22, 21, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7};
	int[] index = reverse(n + 1);
	index.append(reverse(n * 4));
	index = index[:n * 4];
	roots = roots[index];  
	
	// make it cyclic
	//roots.cyclic = true;

	// 3. the interior part of the "fish" curve.
	guide fish;
	// right-hand half: in CW order
	for(i = 0; i < n * 2; ++ i){
		pair p = O + gui[i] * dir(roots[i]);
		fish = fish..p;
		//dot(" ", p);
	}
	// the center of the circle
	fish = fish..(0, 0);
	// left-hand half: in CCW order, not including the summer soltice
	for(i = n * 4 - 1; i > n * 2; -- i){
		pair p = O + gui[i] * dir(roots[i]);
		fish = fish..p;
		//dot(" ", p);
	}
	// the summer soltice: need special treatment as its shadow length is zero.
	fish = fish..{E}(0, -1){W};

	// 4. add the exterior part, to make it cyclic.
	for(i = n * 2 + 1; i < n * 4; ++ i){
		fish = fish..roots[i];
	}
	fish = fish..{E}cycle;
	
	return fish;
}


/*
 * draw stuff now 
 */
 
draw(unitcircle);
//draw(W--E, grey+linewidth(0.2));
//draw(N--S, grey+linewidth(0.2));

filldraw(fish(6, gui_sine));
//draw(fish(6, gui_arithmetic), grey);



