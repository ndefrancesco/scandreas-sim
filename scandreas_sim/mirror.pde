class Mirror {
  PVector pos; // position
  PVector norm; // normal unit vector
  PVector par; // parallel unit vector
  float center_angle;
  int id; // internal object id
  
  boolean moving;
  boolean rotating;
  boolean clicked;
  boolean moff;

  float mrw; // mirror width
  boolean scan;
  int scan_range = 81; // should be odd
  int scan_step = 1;
  int scan_index;
  float scan_pos;
  float scan_amp = radians(-0.8);
  
  Mirror (float x, float y, float a){
    pos = new PVector (x, y);
    center_angle = radians(-a);
    norm = PVector.fromAngle(center_angle);
    par = new PVector (-norm.y, norm.x);
    mrw = 50 / rs * su;
    id = nextObject;
    nextObject++;
    rotating = false;
    moving = false;
    clicked = false;
    moff = false;
    scan = false;
    scan_pos = 0.0;
    scan_index = (scan_range-1) / 2 ; //center position
  }
  
  void scanStep(){
    scan_index += scan_step;
    
    scan_pos = (float(2 * scan_index)/(scan_range - 1) - 1) * scan_amp;
    
    norm = PVector.fromAngle(center_angle + scan_pos);
    par = new PVector (-norm.y, norm.x);
    
    if (scan_index == 0 ) {
      scan_step = 1;
      }
    if (scan_index == scan_range-1) {
      scan_step = -1;       
    }
  }
  
  void update() {
    if (mousePressed && (typeInUse == TYPE_NONE || typeInUse == TYPE_MIRROR) && mouseY < pannelTop-10) {
      
      PVector mpos =  new PVector(mouseX, mouseY);
      PVector delta = PVector.sub(mpos, pos);
      
      if(activeObject == id && delta.mag() > 50 * su && !clicked) moving = true;
      if ((delta.mag()< 25 * su && !rotating && !moff) || moving) { // select mirror
        if(activeObject == id && (moving || clicked)) { // move the mirror
            pos = mpos;
            moving = true;
          }
        if(activeObject == -1) {
          activeObject = id;
          typeInUse = TYPE_MIRROR;
        }
      }
      else if (abs(PVector.dot(delta, par)) > delta.mag() * .99 || rotating) { // rotate mirror
        if(activeObject == id){
          typeInUse = TYPE_MIRROR;
          if(abs(delta.mag() - mrw/2)< 25 * su) rotating = true;
          if(rotating && delta.mag() > 50 * su){
            par = delta.mult(PVector.dot(delta, par)).normalize();
            norm = new PVector(par.y, -par.x);
            center_angle = norm.heading() - scan_pos;
          }
        }
      }
      else {
        if(activeObject == id && !rotating && clicked){
          activeObject = -1;
          clicked = false;
        }
        moff = true;
      }
    } else {
      if(activeObject == id) {
        clicked = true;
        if (typeInUse == TYPE_MIRROR) typeInUse = TYPE_NONE;
      }
      rotating = false;
      moving = false;
      moff = false;

    } 
    
    if(scan && doScan) {
      scanStep();
    }
    
    noStroke();
    fill(0);
    quad( pos.x - par.x * mrw/2,                     pos.y - par.y * mrw/2,
          pos.x + par.x * mrw/2,                     pos.y + par.y * mrw/2,
          pos.x + par.x * mrw/2 - norm.x * 20 * su , pos.y + par.y * mrw/2 - norm.y * 20 * su,
          pos.x - par.x * mrw/2 - norm.x * 20 * su , pos.y - par.y * mrw/2 - norm.y * 20 * su  );
    
    stroke(150);
    fill(150);
    strokeWeight(6 * su);
    line(pos.x - par.x * mrw/2, pos.y - par.y * mrw/2, pos.x + par.x * mrw/2, pos.y + par.y * mrw/2);
    if(scan) fill(200, 100, 100);
    noStroke();
    ellipse(pos.x, pos.y, 15 * su, 15 * su);
    if (activeObject == id) {
      noFill();
      stroke(200, 100, 100);
      strokeWeight(5 * su);
      ellipse(pos.x, pos.y, 25 * su, 25 * su);
    }
  }


}
