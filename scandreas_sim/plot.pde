class Plot{
  float px;
  float py;
  float xmax;
  float xmin;
  float ymax;
  float ymin;
  
  color plotCol;
  String title;
  String xLabel;
  String yLabel;
  
  int nvalues;
  float[] xvalues;
  float[] yvalues;
  int currIndex;
  
  float pw = width * 0.28;
  float ph = height * 0.24;
  float lmargin = 0.2 * pw;
  float rmargin = 0.95 * pw;
  float tmargin = 0.2 * ph;
  float bmargin = 0.8 * ph;
  
  
  Plot(float x, float y, color col, String plotTitle, int nval){
    px = x;
    py = y;
    plotCol = col;
    title = plotTitle;
    nvalues = nval;
    xvalues = new float[nvalues];
    yvalues = new float[nvalues];
  }
  
  void update (){
    xmax = max(xvalues);
    xmin = min(xvalues);
    ymax = max(yvalues);
    ymin = min(yvalues);
    
    float deltax = xmax-xmin + 1e-4;
    float deltay = ymax-ymin + 1e-4;
    float x, y;
    
    // canvas
    fill(240);
    noStroke();
    rect(px, py, pw, ph);
    
    // curve
    stroke(plotCol);
    strokeWeight(3*su);
    noFill();
    beginShape();
    for(int i = 0; i < nvalues; i++){
      x = px + lerp(lmargin, rmargin, 0.05 + 0.9 * (xvalues[i] - xmin)/deltax);
      y = py + lerp(bmargin, tmargin, 0.05 + 0.9 * (yvalues[i] - ymin)/deltay);
      vertex(x, y);      
    }
    endShape();
    fill(plotCol);
    ellipse( px + lerp(lmargin, rmargin, 0.05 + 0.9 * (xvalues[currIndex] - xmin)/deltax), py + lerp(bmargin, tmargin, 0.05 + 0.9 * (yvalues[currIndex] - ymin)/deltay), 12 * su, 12 * su);
    
    
    // axes
    stroke(0);
    fill(0);
    
    line(px + lmargin, py + bmargin, px + rmargin, py + bmargin);
    line(px + lmargin, py + tmargin, px + lmargin, py + bmargin);
    
    textSize(ph * 0.12 * su);
    for(int i = 0; i < 5; i++) {
      float q = 0.05 + float(i)/4 * 0.9;
      
      float dx = lerp(lmargin, rmargin, q);
      float dy = lerp(bmargin, tmargin, q);
      
      line(px + dx, py + bmargin, px + dx, py + bmargin + 10 * su);
      line(px + lmargin - 10 * su, py + dy, px + lmargin, py + dy);
      
      textAlign(CENTER);
      text(nf(lerp(xmin, xmax, float(i)/4), 1, 2), px + dx, py + bmargin + ph * 0.19 * su);
      textAlign(RIGHT);
      text(nf(lerp(ymin, ymax, float(i)/4), 1, 3), px + lmargin - ph * 0.12 * su, py + dy);
    }
    
    // title
    textAlign(CENTER);
    textSize(ph * 0.18 * su);
    text(title, px + (lmargin + rmargin)/2, py + tmargin * 0.7);
  }
}
