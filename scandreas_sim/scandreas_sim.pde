Mirror[] mr;
Source sc;
Button[] bt;

int nmr = 3; // number of mirrors
float su; // screen units (to adjust for smaller screens, e.g. cellphone using APDE)
float rs; // real scale: screen unit size (mm)
int typeInUse; // type of object currently being modified
int activeObject; // object that is selected for editing
boolean doScan = true; // scan mirrors that are enabled to do so
PGraphics canvas;

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
  canvas = createGraphics(width, height);
  canvas.beginDraw();
  canvas.background(255);
  canvas.endDraw();
}
  
void draw() {
  background(255);
  imageMode(CORNER);
  image(canvas, 0, 0, width, height);
  
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

float roundTo(float v, int decimals){
  float r = round(v * pow(10, decimals))/pow(10, decimals);
  return r;
}
