// Based on Daniel Shiffmans Kinect Point Cloud example
// Use a, s, d to change between different styles. 

import org.openkinect.freenect.*;
import org.openkinect.processing.*;
import codeanticode.syphon.*;

// Kinect Library object
Kinect kinect;
// Syphon library object
SyphonServer server;


// Angle for rotation
float a = 0;
float c = 0.3;
float increment=0.5;

// We'll use a lookup table so that we don't have to repeat the math over and over
float[] depthLookUp = new float[2048];


void setup() {

  fullScreen(P3D);
  kinect = new Kinect(this);
  kinect.initDepth();
  server = new SyphonServer(this, "Processing Syphon");
  colorMode(HSB);

  // Lookup table for the depth you want the kinect to read at.
  for (int i = 0; i < 900; i++) {
    depthLookUp[i] = rawDepthToMeters(i);
  }

}

void draw() {

  background(0);

  // Get the raw depth as array of integers
  int[] depth = kinect.getRawDepth();

  // Amount of pixel to skip
  int skip = 4;

  // Translate and rotate
  translate(width/2, height/2, -50);
  //rotate
  //rotateY(a);

  for (int x = 0; x < kinect.width; x += skip) {
    for (int y = 0; y < kinect.height; y += skip) {
      int offset = x + y*kinect.width;

      // Convert kinect data to world xyz coordinate
      int rawDepth = depth[offset];
      PVector v = depthToWorld(x-20, y, rawDepth);
      
      //Coloring based on depth
      
      stroke( rawDepth*2%255,255,255,255);
      
    
      
      //stroke(random(255,rawDepth*10%255));
      strokeWeight(10);
      pushMatrix();
     
      // Scale 
      float factor = 900;
      translate(-v.x*factor, v.y*factor, factor-v.z*factor/1.5);
    
      //Point
      if (key == 'a'){
        point(0, 0);
      }
      
      //Lines
      if (key == 's'){
        rotateY(c);
        line(0,0,rawDepth/50,rawDepth/50);
      }
      
      //Quads
      if (key == 'd'){
        quad(c+40,c, 42+c,c, 69+c, c, 30+c, c+10);
      }
        rotateX(-.5);
        rotateY(-.5);
      popMatrix();
  }
    
  }


  //Pulsating value
  c=c+increment;
  if(c>50) {            //Max value
  increment=increment*-1;
  } 
  if(c<5) {            //Min value
  increment=+0.02;
  }
  
  //Sends screen
  server.sendScreen();
  a += 0.015f;
}

// These functions come from: http://graphics.stanford.edu/~mdfisher/Kinect.html
float rawDepthToMeters(int depthValue) {
  if (depthValue < 2047) {
    return (float)(1.0 / ((double)(depthValue) * -0.0030711016 + 3.3309495161));
  }
  return 0.0f;
}

PVector depthToWorld(int x, int y, int depthValue) {

  final double fx_d = 1.0 / 5.9421434211923247e+02;
  final double fy_d = 1.0 / 5.9104053696870778e+02;
  final double cx_d = 3.3930780975300314e+02;
  final double cy_d = 2.4273913761751615e+02;

  PVector result = new PVector();
  double depth =  depthLookUp[depthValue];//rawDepthToMeters(depthValue);
  result.x = (float)((x - cx_d) * depth * fx_d);
  result.y = (float)((y - cy_d) * depth * fy_d);
  result.z = (float)(depth);
  return result;
}