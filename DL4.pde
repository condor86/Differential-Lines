int ptnum = 85;
float randomspeed = 0.1;
float initialR = 200;
float r0 = 20;
float r1 = 50;
float kmax = 1.2;
float kmin = 0.4;
float dAv;


ArrayList<Pt> pts = new ArrayList<>();

//Pt[] pts = new Pt[ptnum];

class Pt{
    float ptx;
    float pty;
    float ptxadd;
    float ptyadd;
    
    Pt(float tx, float ty){
        ptx = tx;
        pty = ty;

    }

    float x(){
        return ptx;
    }

    float y(){
        return pty;
    }
    
    void brmotion(){
        ptxadd += random(-randomspeed, randomspeed);
        ptyadd += random(-randomspeed, randomspeed);
    }

    void attrmotion(){
        int fnum;
        PVector fav, fadd;
        fav = new PVector (0, 0);
        fadd = new PVector (0, 0);
        fnum = 0;
        for(int a = 0; a < ptnum; a++){
            if  ((ptx != pts.get(a).x()) && (pty != pts.get(a).y()) && (ptx != pts.get((a+1) % ptnum).x()) && (pty != pts.get((a+1) % ptnum).y())) {
                fadd = force(ptx, pty, pts.get(a).x(), pts.get(a).y(), pts.get((a+1) % ptnum).x(), pts.get((a+1) % ptnum).y());
                fav = fav.add(fadd);
                if (fadd.mag() > 0.1){
                    fnum++;
                }              
            }
        }
        if (fnum == 0){
            fnum++;
        }
        fav = fav.div(fnum);
        ptxadd += fav.x;
        ptyadd += fav.y;
    }

    void move(){
        ptx += ptxadd;
        pty += ptyadd;
        ptxadd = 0;
        ptyadd = 0;
    }
    
    void boundarydetect(){
        if (ptx < 0){
            ptx = -ptx;
        }else if (ptx > width) {
            ptx = 2 * width - ptx;
        }
        if (pty < 0){
            pty = -pty;
        }else if (pty > height) {
            pty = 2 * height - pty;
        }
    }

    float delta(){
        return (1.0);
    }
    
}

void display(int i){
    stroke(0, 0, 0, 90);
    line(pts.get(i).x(), pts.get(i).y(), pts.get((i+1)%ptnum).x(), pts.get((i+1)%ptnum).y());
    noStroke();
    fill(0, 0, 0, 90);
    ellipse(pts.get(i).x(), pts.get(i).y(), 10, 10);
}

PVector force(float ptx1, float pty1, float ptx2, float pty2, float ptx3, float pty3){
    // Pt lspt = ln.spt();
    // Pt lept = ln.ept();
    PVector v1, v2, v3;
    PVector f;
    PVector zerovect;

    v1 = new PVector(ptx3 - ptx2, pty3 - pty2);
    v2 = new PVector(ptx1 - ptx2, pty1 - pty2);
    v3 = new PVector(ptx1 - ptx3, pty1 - pty3);

    float sintheta = v1.cross(v2).mag() / (v1.mag() * v2.mag());
    float d1 = dist(ptx1, pty1, ptx2, pty2);
    float d2 = dist(ptx1, pty1, ptx3, pty3);
    float d3 = v2.mag() * sintheta;

    float dots = v1.dot(v2);
    float dote = v1.div(-1).dot(v3);
    if (dots < 0){
        f = new PVector (v2.x , v2.y);
    }else if (dote < 0) {
        f = new PVector (v3.x , v3.y);
    }else{
        f = v1.normalize().mult(dots / v1.mag()).sub(v2);
    }

    float d = f.mag();
    // print(d);
    float sigma = (pow((r0 / d), 12) - pow((r0 / d), 6)) * pow(10,-3);
    //float sigma = 0.001 * (d - r0) * (d - r1);
    if ((d > r0) || (d < 8)){
        sigma = 0;
    }

    f = f.normalize().mult(sqrt(sigma));
    return(f);

}

float caldAv(){
    float dAvSum = 0;
    for (int j=0; j<ptnum; j++){
        dAvSum += dist(pts.get(j).x(), pts.get(j).y(), pts.get((j+1) % ptnum).x(), pts.get((j+1) % ptnum).y());
    }
    return(dAvSum / ptnum) ;
}


void addpt(){
    Pt ptadd;
    float dis;
    
    for (int j=0; j<ptnum; j++){
        dis = dist(pts.get(j).x(), pts.get(j).y(), pts.get((j+1) % ptnum).x(), pts.get((j+1) % ptnum).y());
        if( dis > kmax * dAv * (pts.get(j).delta() + pts.get((j+1) % ptnum).delta()) / 2.0){
            ptadd = new Pt((pts.get(j).x() + pts.get((j+1) % ptnum).x()) / 2, (pts.get(j).y() + pts.get((j+1) % ptnum).y()) / 2);
            pts.add(j+1, ptadd);
            ptnum++;
        }
    }
}

void delpt(){
    float dis;
    for (int j=0; j<ptnum; j++){
        dis = dist(pts.get(j).x(), pts.get(j).y(), pts.get((j+1) % ptnum).x(), pts.get((j+1) % ptnum).y());
        if( dis < kmin * dAv * (pts.get(j).delta() + pts.get((j+1) % ptnum).delta()) / 2.0){
            pts.remove(j+1);
            ptnum--;
        }
    }
}

void setup(){
    size(960, 960);
    smooth();
    strokeWeight(5);
 //   frameRate(30);
    Pt ptsin;
    for (int i=0; i<ptnum; i++){
        
        ptsin = new Pt(width/2 + initialR * cos(2 * PI / ptnum * i), height/2 + initialR * sin(2 * PI / ptnum * i));
        pts.add(ptsin);
        //if (i<ptnum - 1){
            //lns[i] = new LnSegment(pts[i], pts[i+1]);
        //}else{
            //lns[i] = new LnSegment(pts[i], pts[0]);
        //}
    }
}


void draw(){ //<>//
  background(255);   //<>// //<>// //<>//
  for (int i=0; i<ptnum; i++){
        display(i);
        pts.get(i).brmotion();
        pts.get(i).attrmotion();
        pts.get(i).move();
        pts.get(i).boundarydetect();
//        lns[i].addpt();
        dAv = caldAv();
        addpt();
        delpt();
        println(ptnum);
    }
}
