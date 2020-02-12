class Button{
  color bcolor;
  float bx;
  float by;
  int enableType;
  float diam;
  String label;
  
  Button(float x, float y, color col, int enable, String lbl){
    bx = x;
    by = y;
    bcolor = col;
    enableType = enable;
    diam = 50 * su;
    label = lbl;
  }
  
  void update(){
    boolean pressed = false;
    if (mousePressed) {
      float dst = PVector.dist(new PVector (mouseX, mouseY), new PVector (bx, by));
      if (dst < diam/2){ // clicked on button
        buttonPressed = true;
        enabled = enableType;
        if(enableType != TYPE_NONE) {
          if(enableType == TYPE_RAY) activeObject = nmr;
          else activeObject = TYPE_NONE;        
        }
        pressed = true;
      } 
    }
    
    int alpha;
    if(pressed) alpha = 64; else alpha = 128;
    fill(color(red(bcolor), green(bcolor), blue(bcolor), alpha));
    stroke(bcolor);
    float w = 8 * su;
    if(enabled == enableType) w *= 1.5;
    strokeWeight(w);
    ellipse(bx, by, diam, diam);
    
    fill(0);
    textAlign(CENTER);
    textSize(32 * su);
    text(label, bx, by + 1.5 * diam );
  }
}
