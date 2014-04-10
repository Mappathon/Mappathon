// Include the Syphon library
import codeanticode.syphon.*;

// image
PImage img1;

// create an instance of the SyphonServer
SyphonServer server;

void setup() {
  // everything will be rendered to a 3D context
  size(200,200, P3D);
  
  // Create syhpon server to send frames out
  server = new SyphonServer(this, "Processing Syphon");
  
  img1 = loadImage("img1.jpg");

}

void draw() {
  
  // Syphon inverts our image on output
  // so here we flip our image
  pushMatrix();
  scale(1.0, -1.0);
  image(img1,0,-img1.height);
  popMatrix();

  // hack to capture a screenshot of the flipped image
  PImage flippedImage = get();
  
  server.sendImage(flippedImage);
}

