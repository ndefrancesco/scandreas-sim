class Source {
  Ray[] rays;
  PVector pos; // position of the source
  Float len; // length of the whole trace, excluding the last ray
  int maxRef = 20; // Limits the number of bounces to avoid problems
  int id;
  
  boolean moving;
  boolean rotating;
  boolean clicked;
  boolean moff;

  float scan_latPos = 0;
  float scan_minLat = 0;
  float scan_maxLat = 0;
  float scan_minPath = 1e6;
  float scan_maxPath = 0;
  float scan_lminP = Float.NaN; // last scan min
  float scan_lmaxP = Float.NaN; // las scan max
  
  Source(float x, float y, float a, int source_id){
    pos = new PVector(x, y);
    PVector ray_dir = PVector.fromAngle(a/180*PI);
    rays = new Ray[1];
    rays[0] = new Ray(pos.x, pos.y, ray_dir);
    moving = false;
    rotating = false;
    clicked = false;
    moff = false;
    id = source_id;
  }
  
  void trace(){
    float far;
    rays = (Ray[]) expand(rays, 1); // delete current ray tracing except first segment
    int rindex = 0;
    int hit = 0;
    
    while(hit > -1){
      hit = -1;
      far = (width + height) * 2;
      for(int i=0; i<nmr; i++) {
        PVector irm = rays[rindex].intersect(mr[i]);
        if (  irm.x < far && irm.x >= 0 // crossed a mirror plane closer than those of previous checks
              && abs(irm.y) <= mr[i].mrw/2 // within the mirror width
              && rays[rindex].fromMirror != i // is not the mirror where it comes from
              ){
          far = irm.x;
          hit = i;
        }
      }
      
      rays[rindex].len = far;
      
      if (hit > -1){ // ray hit something
        if (PVector.dot(mr[hit].norm, rays[rindex].dir) < 0){ // hit mirror on the shiny side, add ray reflected from the hit point
          Ray ref_ray = rays[rindex].reflect(mr[hit]);
          ref_ray.fromMirror = hit;
          ref_ray.accLen = rays[rindex].accLen + rays[rindex].len; 
          rays = (Ray[]) append(rays, ref_ray);
        }
        else { // stop bouncing rays around
          hit = -1;
        }
      } else { // set a fixed-distance, off-screen, perpendicular target
        // The math simulates a target that is (width+height)/2 away [i.e. always off-screen] 
        // from the center and perpendicular to the exit beam direction
        
        float target_dist = (width + height)/2.0;
        PVector target = PVector.add(new PVector(width/2, height/2), rays[rindex].dir.copy().mult(target_dist)); 
        rays[rindex].len = PVector.dot(PVector.sub(target, rays[rindex].pos), rays[rindex].dir);
      }
      
      rindex++;
      if(rindex > maxRef) hit = -1;
    }
  
  len = rays[rays.length-1].accLen + rays[rays.length-1].len;

  }
  
  void update(){
    if (mousePressed && (typeInUse == TYPE_NONE || typeInUse == TYPE_SOURCE)) {
      PVector mpos = new PVector (mouseX, mouseY);
      PVector delta = PVector.sub(mpos, pos);
      
      if(activeObject == id && delta.mag() > 50 * su && !clicked) moving = true;
      if((delta.mag()< 25 * su && !rotating && !moff) || moving) { // moving the source
        if(activeObject == id && (moving || clicked)) { // move the mirror
            pos = mpos;
            rays[0].pos  = pos;
            moving = true;
          }
        if(activeObject == -1){
          activeObject = id;
          typeInUse = TYPE_SOURCE;
        }  
      }
      else if (abs(PVector.dot(delta, rays[0].dir)) > delta.mag() * .99 || rotating) {
        if(activeObject == id){
          typeInUse = TYPE_SOURCE;
          if(abs(delta.mag())< rays[0].len + 25 * su && abs(PVector.dot(delta, rays[0].norm)) < 25 * su ) rotating = true;
          if(rotating && delta.mag() > 50 * su){
            rays[0].dir = delta.normalize();
            rays[0].norm = new PVector(rays[0].dir.y, -rays[0].dir.x);
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
      if (typeInUse == TYPE_SOURCE) typeInUse = TYPE_NONE;
    }
    
    trace(); // check if it hits something and reflect accordingly
   
    if (doScan) { // to keep the ray scan statistics after tracing
      scan_minPath =  min(scan_minPath, len);
      scan_maxPath =  max(scan_maxPath, len);
      
      float lat_pos =  PVector.dot(rays[rays.length - 1].pos, new PVector(- rays[rays.length - 1].dir.y, rays[rays.length - 1].dir.x)); 
      scan_latPos = lat_pos;
      
      if (mr[0].scan_index == 0 ) {
        scan_minLat = lat_pos;
      }
      if (mr[0].scan_index == mr[0].scan_range - 1) {
        scan_maxLat  = lat_pos;      
        
        scan_lminP = scan_minPath;
        scan_lmaxP = scan_maxPath;
        scan_minPath = Float.NaN;
        scan_maxPath = Float.NaN;
      }  
    }
   
    for (int i=0; i < rays.length; i++){
      rays[i].update();
    }

    fill(color(0, 200, 100));
    ellipse(pos.x, pos.y, 10 * su, 10 * su);
    if (activeObject == id) {
      noFill();
      stroke(200, 100, 100);
      strokeWeight(5 * su);
      ellipse(pos.x, pos.y, 25 * su, 25 * su);
    }
    
    fill(0);
    textAlign(LEFT);
    textSize(32 * su);
    float textH = height * 0.84;
    float textW = width * 0.68;
    float dH = 50 * su;
    text("exit angle (deg): " + roundTo(-degrees(rays[rays.length-1].dir.heading()), 4) + " ("+ roundTo(degrees(acos(PVector.dot(rays[rays.length-1].dir, rays[0].dir))), 4) +")", textW, textH);
    text("path len diff (mm): " + roundTo((len - scan_lminP) / su * rs, 4) + " ["+ nfp(degrees(- mr[0].scan_pos), 1, 2)+"°]", textW, textH + dH);
    text("scan pos (mm): " + roundTo(abs(scan_latPos - scan_minLat - (scan_maxLat - scan_minLat)/2) / su * rs, 4) , textW, textH + 2 * dH);
    text("max path diff (mm): " + roundTo((scan_lmaxP - scan_lminP) / su * rs, 4) + "  (" + roundTo((scan_lmaxP - scan_lminP)/(scan_maxLat - scan_minLat) * 100,2) + "% sw)", textW, textH + 3.2 * dH);
    text("scan width (mm): " + roundTo(abs(scan_maxLat - scan_minLat) / su * rs, 4), textW, textH + 4.2 * dH);
  }
}
