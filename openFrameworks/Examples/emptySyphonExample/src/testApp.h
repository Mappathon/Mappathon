#ifndef _TEST_APP
#define _TEST_APP


#include "ofMain.h"
#include "ofxSyphon.h"

class testApp : public ofBaseApp{
	
public:
	
	void setup();
	void update();
	void draw();
	
	void keyPressed(int key);
	
    ofTexture tex; // our beautiful texture
    
	ofxSyphonServer mainOutputSyphonServer; // server to output the whole screen
	ofxSyphonServer individualTextureSyphonServer; // server to output just a texture
	    
};

#endif

