Mirror[] mr;
Source sc;
Button[] bt;
Plot[] plt;

int nmr = 3; // number of mirrors, can be increased to automatically create extra mirrors to play with
int nextObject = 0; // a counter for new object id's
float su; // screen units (to adjust for smaller screens, e.g. cellphone using APDE)
float rs; // real scale: screen unit size (mm)
float pannelTop;

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
  pannelTop = height*0.74;
  
  sc = new Source( 934, 377, 155);

  mr = new Mirror[nmr];
  bt = new Button[2];
  plt = new Plot[3];

  mr[0] = new Mirror(600, 533, 90);
  mr[0].scan = true; // scanning mirror
  mr[1] = new Mirror(393, 436, 0);
  mr[2] = new Mirror(711, 283, -135);
  
  for(int i = 0; i<nmr; i++){
    if(mr[i] == null) mr[i] = new Mirror(100, 50*(nmr-i), 90);
  }

  bt[0] = new Button(width*0.72, height * 0.78, color(100, 100, 200), true, TYPE_NONE, "toggle scan");
  bt[1] = new Button(width*0.87, height * 0.78, color(200, 100, 100), true, TYPE_NONE, "reset scan");
  
  plt[0] = new Plot(width*0.05, height * 0.75, color(200, 100, 0), "path len diff", int(mr[0].scan_range));
  plt[1] = new Plot(width*0.35, height * 0.75, color(0, 100, 200), "lateral scan pos", int(mr[0].scan_range));
 
  for(int i = 0; i<plt[0].nvalues; i++){
    plt[0].xvalues[i] = (float(2 * i)/(mr[0].scan_range - 1) - 1) * degrees(-mr[0].scan_amp);
    plt[1].xvalues[i] = (float(2 * i)/(mr[0].scan_range - 1) - 1) * degrees(-mr[0].scan_amp);
  }
  
  activeObject = 0;
  sc.trace();
  
  typeInUse = TYPE_NONE;
  
}
  
void draw() {
  background(255);
  makeGrid(gridSpacing/rs*su);
  
  for(int i = 0; i < bt.length; i++) {
    bt[i].check();
    }
  
  doScan = bt[0].statusOn;
  if (bt[1].statusOn){
    bt[1].statusOn = false;
    mr[0].scan_index = (mr[0].scan_range-1) / 2 - 1;
    mr[0].scan_step = 1;
    mr[0].scanStep();
  }
  
  for(int i=0; i<nmr; i++) {
    mr[i].update();
    println("m" + i, mr[i].pos, degrees(-mr[i].center_angle));
  }
  sc.update();
  println("r", sc.rays[0].pos, degrees(-sc.rays[0].dir.heading()));
  println();
  
  // painting bottom pannel
  noStroke();
  fill(255);
  rect(0, pannelTop, width, height*0.3);
 
  for(int i = 0; i < bt.length; i++) {
    bt[i].update();
  }
  sc.showMeasurements();
  
  plt[0].yvalues[mr[0].scan_index] = (sc.len - sc.scan_lminP) / su * rs;
  plt[1].yvalues[mr[0].scan_index] = (sc.scan_latPos - sc.scan_minLat - (sc.scan_maxLat - sc.scan_minLat)/2) / su * rs;
  
  plt[0].currIndex = mr[0].scan_index;
  plt[1].currIndex = mr[0].scan_index;
  
  plt[0].update();
  plt[1].update();
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
