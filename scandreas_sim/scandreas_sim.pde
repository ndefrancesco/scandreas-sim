Mirror[] mr;
Source sc;
Button[] bt;

int nmr = 3; // number of mirrors
float su; // screen units (to adjust for smaller screens, e.g. cellphone using APDE)
float rs; // real scale: screen unit size (mm)
int typeInUse; // type of object currently being modified
int activeObject; // object that is selected for editing
boolean doScan = true; // scan mirrors that are enabled to do so
float gridSpacing = 20; // grid spacing (mm)

final int TYPE_SOURCE = 1;
final int TYPE_MIRROR = 2;
final int TYPE_BUTTON = 3;
final int TYPE_NONE = -1;

void setup() {
  // fullScreen();
  size(1200,800);
  su = height/1500.0; // px/su
  rs = 0.16667; // mm/su
 
  sc = new Source( 934, 377, 155, nmr);

  mr = new Mirror[nmr];
  bt = new Button[1];
  

  mr[0] = new Mirror(600, 533, 90, 0);
  mr[0].scan = true; // scanning mirror
  mr[1] = new Mirror(390, 447, 0, 1);
  mr[2] = new Mirror(711, 283, -135, 2);
  

  bt[0] = new Button(width*0.1, height * 0.9, color(200, 100, 100), true, TYPE_NONE, "Scan");
  
  activeObject = nmr;
  sc.trace();
  
  typeInUse = TYPE_NONE;
  
}
  
void draw() {
  background(255);
  makeGrid(gridSpacing/rs*su);
  noStroke();
  fill(255);
  rect(0, height*0.74, width, height*0.3);
  
  for(int i = 0; i < bt.length; i++) {
    bt[0].update();
    }
  
  doScan = bt[0].statusOn;
  
  for(int i=0; i<nmr; i++) {
    mr[i].update();
    println("m" + i, mr[i].pos, degrees(mr[i].norm.heading()));
  }
  sc.update();
  println("r", sc.rays[0].pos, degrees(sc.rays[0].dir.heading()));
  println();
  
}


void makeGrid(float spacing){
  stroke(220);
  strokeWeight(2 * su);
  for(float x = 0; x < width/2 ; x += spacing){
    line(width/2 + x, 0, width/2 + x, height);
    line(width/2 - x, 0, width/2 - x, height);   
  }
  
  for(float y = 0; y < height/2; y += spacing){
    line(0, height/2 + y, width, height/2 + y);
    line(0, height/2 - y, width, height/2 - y);    
  }
}


float roundTo(float v, int decimals){
  float r = round(v * pow(10, decimals))/pow(10, decimals);
  return r;
}
