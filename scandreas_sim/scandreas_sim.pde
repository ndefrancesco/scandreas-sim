Mirror[] mr;
Source sc;
Button[] bt;

int nmr = 3; // number of mirrors
float su; // screen units (to adjust for smaller screens, e.g. cellphone using APDE)
float rs; // real scale: screen unit size (mm)
int enabled; // type of object that is enabled for selection/editing
boolean buttonPressed; //
int activeObject; // object that is selected for editing
boolean doScan = true; // scan mirrors that are enabled to do so
PGraphics canvas;

final int TYPE_RAY = 1;
final int TYPE_MIRROR = 2;
final int TYPE_NONE = -1;

void setup() {
  // fullScreen();
  size(1200,800);
  su = height/1500.0; // px/su
  rs = 0.16667; // mm/su
 
  sc = new Source( 934, 377, 155, nmr);

  mr = new Mirror[nmr];
  bt = new Button[3];
  

  mr[0] = new Mirror(600, 533, 90, 0);
  mr[0].scan = true; // scanning mirror
  mr[1] = new Mirror(390, 447, 0, 1);
  mr[2] = new Mirror(711, 283, -135, 2);
  
  bt[0] = new Button(width*0.1, height * 0.9, color(0, 200, 100), TYPE_RAY, "Ray");
  bt[1] = new Button(width*0.2, height * 0.9, color(100, 100, 100), TYPE_MIRROR, "Mirrors");
  bt[2] = new Button(width*0.3, height * 0.9, color(200, 100, 100), TYPE_NONE, "Scan");
  
  activeObject = nmr;
  enabled = 1;
  buttonPressed = false;
  sc.trace();
  
  canvas = createGraphics(width, height);
  canvas.beginDraw();
  canvas.background(255);
  canvas.endDraw();
}
  
void draw() {
  background(255);
  buttonPressed = false;
  imageMode(CORNER);
  image(canvas, 0, 0, width, height);
  
  for(int i = 0; i < bt.length; i++) {
    bt[i].update();
    }
  
  
  for(int i=0; i<nmr; i++) {
    mr[i].update();
    println("m" + i, mr[i].pos, degrees(mr[i].norm.heading()));
  }
  sc.update();
  println("r", sc.rays[0].pos, degrees(sc.rays[0].dir.heading()));
  println();
  
}
