#pragma once

#include "ofMain.h"
#include "ofxOpenCv.h"
#include "ofxKinect.h"
#include "ofxParticleEmitter.h" // FX
#include "ofxUI.h" // GUI

class testApp : public ofBaseApp {
public:
	
	void setup();
	void update();
	void draw();
	void exit();
	
	void drawPointCloud();
    void setupGUI();
    //void loadEmitter(string inEmitter); // load FX from the particle designer
	
	void keyPressed(int key);
	void mouseDragged(int x, int y, int button);
	void mousePressed(int x, int y, int button);
	void mouseReleased(int x, int y, int button);
	void windowResized(int w, int h);
	
    // Kinect + CV
	ofxKinect kinect;
	ofxCvColorImage colorImg;
	ofxCvGrayscaleImage grayImage;      // grayscale depth image
	ofxCvGrayscaleImage grayThreshNear; // the near thresholded image
	ofxCvGrayscaleImage grayThreshFar;  // the far thresholded image
	ofxCvContourFinder contourFinder;   // blobs
	
	bool bThreshWithOpenCV;
	bool bDrawPointCloud;
	int nearThreshold;
	int farThreshold;
	int angle; // Kinect angle
    
	// Used for viewing the point cloud
	ofEasyCam easyCam;
    
    // FBO + Particles
    ofImage     srcImg;
    ofImage     dstImg;
    
    ofFbo       maskFbo;
    ofFbo       fbo;
    ofFbo       sourceFbo;
    ofImage     sourceImage;
    
    ofFbo       emitterFbo;
    ofShader    shader;
    
    // The Emitter (moved from protected)
    ofxParticleEmitter		m_emitter;

    
    // GUI
    ofxUICanvas *gui;
	void guiEvent(ofxUIEventArgs &e);
    bool drawFill;
    ofColor backgroundColor;
    
protected:
	

};
