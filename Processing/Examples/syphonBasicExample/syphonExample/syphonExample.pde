// This example code demonstrates how a basic "boincing ball"
// can be sent out as a syphon server

// Include the Syphon library
import codeanticode.syphon.*;

// create an offscreen graphics buffer
PGraphics canvas;
// create an instance of the SyphonServer
SyphonServer server;

// variables for our ball
float x = 200;
float y = 200;
float xspeed = 1;
float yspeed = 3.3;

void setup() {
// everything will be rendered to a 3D context
size(400,400, P3D);

// create new PGraphics object.
// This is where you'll do all your drawing
canvas = createGraphics(400, 400, P3D);

// Create syhpon server to send frames out
server = new SyphonServer(this, "Processing Syphon");

}

void draw() {
// Add the current speed to the location.
x = x + xspeed;
y = y + yspeed;

// Check for bouncing

if ((x > width) || (x < 0)) {
xspeed = xspeed * -1;
}
if ((y > height) || (y < 0)) {
yspeed = yspeed * -1;
}

// you must call beginDraw() to render to the server
canvas.beginDraw();

// all drawing calls are part of the PGraphics context
canvas.background(255);
canvas.stroke(0);
canvas.fill(175);
canvas.ellipse(x,y,32,32);

// it's necessary to end the renderer with endDraw()
canvas.endDraw();
// draw the buffer in your processing window
image(canvas, 0, 0);
//send the buffer via syphon
server.sendImage(canvas);

}
