import graph;

size(200,IgnoreAspect);
//size(200);
//scale(Linear, Log);
file f=binput("prime.db");
f.singleint(false);  // 64-bit 
f.signedint(false);  // unsigned 
int total=f;
write(total);
int i = 0;
pair[] p1, p2, p3, p4;
// read in p1
while(true) {
  int p=f;
  if(eof(f)) break;
  //  if(p==0) continue;
  p1.push((i+1, p));
  write(p1[i]);
  ++ i;
}

// construct p2
for(i = 0; i < total && p1[i].y < total; ++ i){
  p2.push((i+1, p1[(int)(p1[i].y)].y));
    write(p2[i]);
}

// construct p3
for(i = 0; i < p1.length && p1[i].y < p2.length; ++ i){
  p3.push((i+1, p2[(int)(p1[i].y)].y));
  write(p3[i]);
}

// construct p4
for(i = 0; i < p1.length && p1[i].y < p3.length; ++ i){
  p4.push((i+1, p3[(int)(p1[i].y)].y));
  write(p4[i]);
}



draw(graph(p1),red);
draw(graph(p2),blue);
draw(graph(p3),green);
draw(graph(p4),cyan);

draw((0,0)--(total,total));

//dot(db);
