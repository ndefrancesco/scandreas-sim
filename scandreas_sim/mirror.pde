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
  float scan_delta = radians(0.05);
  float scan_amp = radians(2);
  float scan_pos;
  
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
    scan_pos = 0.0;
  }
  
  void scanStep(){
    scan_pos += scan_delta;
    float heading = norm.heading();
    norm = PVector.fromAngle(heading + scan_delta);
    par = new PVector (-norm.y, norm.x);
    sc.scan_minPath =  min(sc.scan_minPath, sc.len);
    sc.scan_maxPath =  max(sc.scan_maxPath, sc.len);
    if(abs(scan_pos) >= scan_amp) {
      float extreme =  PVector.dot(sc.rays[sc.rays.length-1].pos, new PVector(- sc.rays[sc.rays.length-1].dir.y, sc.rays[sc.rays.length-1].dir.x)); 
      if(scan_delta > 0){
        sc.scan_maxLat  = extreme;
      } else {
        sc.scan_minLat = extreme;
        
        sc.scan_lminP = sc.scan_minPath;
        sc.scan_lmaxP = sc.scan_maxPath;
        sc.scan_minPath = 1e6;
        sc.scan_maxPath = 0;
      }
      scan_delta *= -1;
    }
  }
  
  void update() {
    if (mousePressed && (typeInUse == TYPE_NONE || typeInUse == TYPE_MIRROR)) {
      
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
