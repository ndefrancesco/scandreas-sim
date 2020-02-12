class Source {
  Ray[] rays;
  PVector pos; // position of the source
  Float len; // length of the whole trace, excluding the last ray
  int maxRef = 20; // Limits the number of bounces to avoid problems
  int id = nmr;
  
  boolean moving;
  boolean rotating;
  
  float scan_min = 0;
  float scan_max = 0;
  
  Source(float x, float y, float a){
    pos = new PVector(x, y);
    PVector ray_dir = PVector.fromAngle(a/180*PI);
    rays = new Ray[1];
    rays[0] = new Ray(pos.x, pos.y, ray_dir);
    moving = false;
    rotating = false;
  }
  
  void trace(){
    float far;
    rays = (Ray[]) expand(rays, 1);
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
  
  len = rays[rays.length-1].accLen;

  }
  
  void update(){
    if (mousePressed && !buttonPressed && enabled == 1) {
      PVector mpos = new PVector (mouseX, mouseY);
      PVector delta = PVector.sub(mpos, pos);
      if((delta.mag()< 100 * su && !rotating) || moving){ // moving the source
         moving = true;
         pos = mpos;
         rays[0].pos  = pos;
      }
      else { // just changing the direction
        rotating = true;
        rays[0].dir = delta.normalize();
      }
    } else {
      moving = false;
      rotating = false;
    }
    
    trace(); // check if it hits something and reflect accordingly
   
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
    text("exit angle (deg): " + roundTo(-degrees(rays[rays.length-1].dir.heading()), 4) + " ("+ roundTo(degrees(acos(PVector.dot(rays[rays.length-1].dir, rays[0].dir))), 4) +")", width * 0.7, height * 0.9);
    text("path length (mm): " + roundTo(rays[rays.length-1].len * rs, 4) , width * 0.7, height * 0.9 + 50*su);
    text("scan width (mm): " + roundTo(abs(scan_min - scan_max) * rs, 4) , width * 0.7, height * 0.9 + 100*su);
  }
  
  float roundTo(float v, int decimals){
    float r = round(v * pow(10, decimals))/pow(10, decimals);
    return r;
  }
}