import graph;
size(200,IgnoreAspect);
//size(200);
file f=binput("prime.db");
int total=f;
write(total);
int i = 0;
pair[] p1, p2, p3, p4;
// read in p1
while(true) {
  int p=f;
  if(eof(f)) break;
  if(p==0) continue;
  p1.push((i, p));
  //  write(i, p);
  ++ i;
}

// construct p2
for(i = 0; i < total && p1[i].y < total; ++ i){
  p2.push((i, p1[(int)(p1[i].y)].y));
    write(p2[i]);
}

// construct p3
for(i = 0; i < p1.length && p1[i].y < p2.length; ++ i){
  p3.push((i, p2[(int)(p1[i].y)].y));
  write(p3[i]);
}

// construct p4
for(i = 0; i < p1.length && p1[i].y < p3.length; ++ i){
  p4.push((i, p3[(int)(p1[i].y)].y));
  write(p4[i]);
}




draw(graph(p1),red);
draw(graph(p2),blue);
draw(graph(p3),green);
draw(graph(p4),cyan);

//dot(db);
