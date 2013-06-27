import graph;

//size(200,IgnoreAspect);
size(200);
//scale(Linear, Log);
file f=binput("prime.db");
f.singleint(false);  // 64-bit 
f.signedint(false);  // unsigned 
int total=f;
write(total);
int i = 0;
pair[] p1, p2, p3, p4;
pair[] P1, P2, P3, P4;
// read in p1
while(true) {
  int p=f;
  if(eof(f)) break;
  //  if(p==0) continue;
  p1.push((i+1, p));
  P1.push((p, i+1));
  write(p1[i]);
  write(P1[i]);
  ++ i;
}

// construct p2
for(i = 0; i < total && p1[i].y < total; ++ i){
  p2.push((i+1, p1[(int)(p1[i].y)].y));
  P2.push((p2[i].y, p2[i].x));
  write(p2[i]);
  write(P2[i]);
}

// construct p3
for(i = 0; i < p1.length && p1[i].y < p2.length; ++ i){
  p3.push((i+1, p2[(int)(p1[i].y)].y));
  P3.push((p3[i].y, p3[i].x));
  write(p3[i]);
  write(P3[i]);
}

// construct p4
for(i = 0; i < p1.length && p1[i].y < p3.length; ++ i){
  p4.push((i+1, p3[(int)(p1[i].y)].y));
  P4.push((p4[i].y, p4[i].x));
  write(p4[i]);
  write(P4[i]);
}



draw(graph(p1),red);
draw(graph(p2),blue);
draw(graph(p3),green);
draw(graph(p4),yellow);

draw(graph(P1),red);
draw(graph(P2),blue);
draw(graph(P3),green);
draw(graph(P4),yellow);

draw((0,0)--(p1[total-1].y,p1[total-1].y));

//dot(db);
