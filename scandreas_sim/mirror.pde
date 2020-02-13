class Mirror {
  PVector pos; // position
  PVector norm; // normal unit vector
  PVector par; // parallel unit vector 
  int id; // internal object id
  
  boolean moving;
  boolean rotating;
  boolean clicked;
  boolean moff;

  float mrw; // mirror width
  boolean scan;
  float scan_delta = radians(0.1);
  float scan_amp = radians(2);
  float scan_pos = 0;
  
  Mirror (float x, float y, float a, int mirror_id){
    pos = new PVector (x, y);
    norm = PVector.fromAngle(-a * PI/180);
    par = new PVector (-norm.y, norm.x);
    mrw = 50 / rs * su;
    id = mirror_id;
    rotating = false;
    moving = false;
    clicked = false;
    moff = false;
    scan = false;
  }
  
  void scanStep(){
    scan_pos += scan_delta;
    float heading = norm.heading();
    norm = PVector.fromAngle(heading + scan_delta);
    par = new PVector (-norm.y, norm.x);    
    if(abs(scan_pos) >= scan_amp) {
      float extreme =  PVector.dot(sc.rays[sc.rays.length-1].pos, new PVector(- sc.rays[sc.rays.length-1].dir.y, sc.rays[sc.rays.length-1].dir.x)); 
      if(scan_delta > 0){
        sc.scan_max  = extreme;
      } else {
        sc.scan_min = extreme;
      }
      scan_delta *= -1;
    }
  }
  
  void update() {
    if (mousePressed && !buttonPressed && enabled == 2) {
      
      PVector mpos =  new PVector(mouseX, mouseY);
      PVector delta = PVector.sub(mpos, pos);
      
      if(activeObject == id && delta.mag() > 50 * su && !clicked) moving = true;
      if ((delta.mag()< 25 * su && !rotating && !moff) || moving) { // moving the source
        if(activeObject == id && (moving || clicked)) {
            pos = mpos;
            moving = true;
          }
        if(activeObject == -1) activeObject = id;
      }
      else if (abs(PVector.dot(delta, par)) > delta.mag() * .99 || rotating) { // rotate mirror
        if(activeObject == id){
          if(abs(delta.mag() - mrw/2)< 25 * su) rotating = true;
          if(rotating && delta.mag() > 50 * su){
            par = delta.mult(PVector.dot(delta, par)).normalize();
            norm = new PVector(par.y, -par.x);
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
      if(activeObject == id) clicked = true;
      rotating = false;
      moving = false;
      moff = false;
    } 
    
    if(scan) scanStep();
    
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
