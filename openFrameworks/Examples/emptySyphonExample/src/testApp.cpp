#include "testApp.h"

const int width = 800;
const int height = 600;

//--------------------------------------------------------------
void testApp::setup(){	
    ofSetWindowTitle("syphon example");
    
	mainOutputSyphonServer.setName("Screen Output");
    tex.allocate(width, height, GL_RGBA); // allocate textures before we use them
    
	ofSetFrameRate(60); // if vertical sync is off, we can go a bit fast... this caps the framerate at 60fps.
}

//--------------------------------------------------------------
void testApp::update(){
}

//--------------------------------------------------------------
void testApp::draw(){
	
    // 1.
    // openGL stuff
    // Clear with alpha, so we can capture via syphon and composite elsewhere should we want.
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    
    // 2.
    // draw the things we want to send to syphon here!
    // draw static into our one texture.
    unsigned char pixels[200*100*4];
    
    for (int i = 0; i < 200*100*4; i++)
    {
        pixels[i] = (int)(255 * ofRandomuf());
    }
    tex.loadData(pixels, 200, 100, GL_RGBA);
    tex.draw(50, 50);
    
    
    // 3.
	// Syphon Stuff
    ofSetColor(255, 255, 255);
    ofEnableAlphaBlending();
    
	mainOutputSyphonServer.publishScreen(); // sends a grab of the entire screen to syphon
    individualTextureSyphonServer.publishTexture(&tex); // just sends a specific texture
    
}


//--------------------------------------------------------------
void testApp::keyPressed  (int key){

}
