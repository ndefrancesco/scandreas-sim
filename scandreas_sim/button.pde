class Button{
  color bcolor;
  float bx;
  float by;
  int enableType;
  boolean statusOn;
  boolean clicked;
  float diam;
  String label;
  boolean pressed;
  
  Button(float x, float y, color col, boolean status, int enable, String lbl){
    bx = x;
    by = y;
    bcolor = col;
    enableType = enable;
    statusOn = status;
    clicked = false;
    diam = 40 * su;
    label = lbl;
  }
  
  void check(){
    pressed = false;
    if (mousePressed && (typeInUse == TYPE_NONE || typeInUse == TYPE_BUTTON)) {
      float dst = PVector.dist(new PVector (mouseX, mouseY), new PVector (bx, by));
      if (dst < diam/2){ // clicked on button
        if(!clicked) {
          statusOn = !statusOn;
        }
        typeInUse = TYPE_BUTTON;
        pressed = true;
        clicked = true;
      } 
    } else {
      clicked = false;
      if (typeInUse == TYPE_BUTTON) typeInUse = TYPE_NONE;
    }
  } 
  
  void update(){ 
    int alpha;
    if(statusOn) alpha = 180; else alpha = 64;
    fill(color(red(bcolor), green(bcolor), blue(bcolor), alpha));
    stroke(bcolor);
    float w = 8 * su;
    if(pressed) w *= 1.5;
    strokeWeight(w);
    ellipse(bx, by, diam, diam);
    
    fill(0);
    textAlign(LEFT);
    textSize(32 * su);
    text(label, bx + diam, by + 0.5 * diam - 10 * su);
  }
}
