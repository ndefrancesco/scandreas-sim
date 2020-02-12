class Ray {
  PVector dir; // direction of propagation
  PVector pos; // position of the source
  Float len; // length of the ray
  Float accLen; // accumulated length (from source)
  int fromMirror;
  
  Ray(float x, float y, PVector ray_dir) {
    pos = new PVector(x, y);
    dir = ray_dir;
    len = max(width, height) * 2.0;
    accLen = 0.0;
    fromMirror = -1;
  }
  
  void update(){
    stroke(color(0, 200, 100));
    strokeWeight(5 * su);
    line(pos.x, pos.y, pos.x + dir.x * len, pos.y + dir.y * len);
    
    PVector perp = new PVector (-dir.y, dir.x).mult(15 * su);
    stroke(color(0, 200, 100));
    strokeWeight(su);
    float lpos;
    float step = 20 * su;
    for(int i =1; i <= (len+ accLen % step)/step; i++){
      lpos = i * step - accLen % step;
      line(pos.x + dir.x * lpos + perp.x,  pos.y + dir.y * lpos + perp.y, pos.x + dir.x * lpos - perp.x,  pos.y + dir.y * lpos - perp.y);
    }
  }
  
  PVector intersect(Mirror m){
    PVector diff = PVector.sub(pos, m.pos);
    float det = m.par.x * dir.y - m.par.y * dir.x ;
    float t = (m.par.y * diff.x - m.par.x * diff.y) / det;
    float u = (  dir.y * diff.x -    dir.x * diff.y) / det;
    PVector intersect = new PVector (t, u);
    return intersect;
  }
  
  Ray reflect(Mirror m){
    PVector ref_dir = PVector.add(m.par.copy().mult(m.par.dot(dir)), m.norm.copy().mult( - m.norm.dot(dir))); 
    Ray ref_ray = new Ray(pos.x + dir.x * len, pos.y + dir.y * len, ref_dir);
    return ref_ray;
  } 
}
