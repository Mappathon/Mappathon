  // based off the Scratch example from Processing by Andres Colubri

import processing.video.*;
import codeanticode.syphon.*;

Movie mov;

// create an instance of the SyphonServer
SyphonServer server;

void setup() {
  size(480, 270, P3D);
  background(0);
  
  mov = new Movie(this, "fx.m4v");
  
  // Create syhpon server to send frames out
  server = new SyphonServer(this, "Processing Syphon");
  
  // Pausing the video at the first frame. 
  mov.play();
  mov.jump(0);
  mov.pause();
}

void draw() {

  // we make the movie interactive by scrubbing based
  // on the mouse location
  if (mov.available()) {
    mov.read();
    // A new time position is calculated using the current mouse location:
    //float f = map(mouseX, 0, width, 0, 1);
    //float t = mov.duration() * f;
    mov.play();
    //mov.jump(t);
    //mov.pause();
  }  

  // draw our movie so we know what we are working with
  image(mov,0,0);

  // we create an image based on the current frame
  PImage newImg;
  newImg = mov;
  
  // images and videos appear flipped when Syphoned...
  // this is to flip each frame so they render correctly in MadMapper
  pushMatrix();
  scale(1.0, -1.0);
  image(newImg,0,-newImg.height);
  popMatrix();
  
  // then we send our final result
  server.sendImage(newImg);
}

