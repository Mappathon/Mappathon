#include "testApp.h"


//--------------------------------------------------------------
void testApp::setup() {
    ofEnableAlphaBlending();
    ofSetFrameRate(60);
    
    // setup FBO
    srcImg.loadImage("blueNoise.png");
    dstImg.loadImage("grayNoise.png");
    
    // load our emitter
    if (!m_emitter.loadFromXml("ohSnap2.pex")){
		ofLog( OF_LOG_ERROR, "testApp::setup() - failed to load emitter config" );
	}
    
    int width = srcImg.getWidth();
    int height = srcImg.getHeight();
    fbo.allocate(width,height);
    maskFbo.allocate(width,height);
    sourceFbo.allocate(width,height);
    sourceImage.allocate(width, height, OF_IMAGE_COLOR_ALPHA);

    // setup shader
    shader.setupShaderFromFile(GL_FRAGMENT_SHADER, "Shader/alphashade.frag");
    shader.linkProgram();
    
    // Let's clear our FBO's
    maskFbo.begin();
    ofClear(0,0,0,255);
    maskFbo.end();
    
    fbo.begin();
    ofClear(0,0,0,255);
    fbo.end();
    
    sourceFbo.begin();
    ofClear(0,0,0,255);
    sourceFbo.end();
    
    // Now setup kinect stuff
	kinect.setRegistration(true);
	kinect.init();
	//kinect.init(true); // shows infrared instead of RGB video image
	//kinect.init(false, false); // disable video image (faster fps)
	kinect.open();
	
	colorImg.allocate(kinect.width, kinect.height); // kinect rgb
	grayImage.allocate(kinect.width, kinect.height); // kinect gray
	grayThreshNear.allocate(kinect.width, kinect.height); // near thresh
	grayThreshFar.allocate(kinect.width, kinect.height); // far thresh (ghetto z-clip)
	
	nearThreshold = 230;
	farThreshold = 70;
	bThreshWithOpenCV = true;
	angle = 0; // zero the tilt on startup
	kinect.setCameraTiltAngle(angle);
	
	bDrawPointCloud = false; // start from the front
    
    
    setupGUI();
}

void testApp::setupGUI() {
    //set some sketch parameters
    //Background Color
    drawFill = true;
    backgroundColor = ofColor(30, 30, 30, 255);
    
    float dim = 16;
	float xInit = OFX_UI_GLOBAL_WIDGET_SPACING;
    float length = 320-xInit;
    length = 180; // hack
	
    gui = new ofxUICanvas(0,0,200,400);
	gui->addWidgetDown(new ofxUILabel("HM GUI", OFX_UI_FONT_SMALL));
    
    gui->addSpacer(length, 2);
    gui->setWidgetPosition(OFX_UI_WIDGET_POSITION_DOWN);
    gui->addSlider("NEAR", 0.0, 255.0, nearThreshold, length,dim);
	gui->addSlider("FAR", 0.0, 255.0, farThreshold, length,dim);
	gui->addSlider("ANGLE", -30.0, 30.0, farThreshold, length,dim);
    gui->addSpacer(length, 2);
    
    //gui->addWidgetDown(new ofxUILabelToggle(drawFill, "POINTCLOUD", OFX_UI_FONT_SMALL));
    gui->addSpacer(length, 2);
    gui->addWidgetDown(new ofxUILabel("HIDE & SHOW GUI BY PRESSING 'g'", OFX_UI_FONT_SMALL));
    
    ofAddListener(gui->newGUIEvent,this,&testApp::guiEvent);
	ofBackground(backgroundColor);
    gui->setTheme(OFX_UI_THEME_GRAYRED);
    gui->loadSettings("GUI/guiSettings.xml"); // save it

}

//--------------------------------------------------------------
void testApp::update() {
	
	ofBackground(200, 200, 200);
    
	kinect.update();
    m_emitter.update();

    
    // Magical Kinect stuff
	// There is a new frame and we are connected
	if(kinect.isFrameNew()) {
        
		// load grayscale depth image from the kinect source
		grayImage.setFromPixels(kinect.getDepthPixels(), kinect.width, kinect.height);
		
		// we do two thresholds - one for the far plane and one for the near plane
		// we then do a cvAnd to get the pixels which are a union of the two thresholds
		if(bThreshWithOpenCV) {
			grayThreshNear = grayImage;
			grayThreshFar = grayImage;
			grayThreshNear.threshold(nearThreshold, true);
			grayThreshFar.threshold(farThreshold);
			cvAnd(grayThreshNear.getCvImage(), grayThreshFar.getCvImage(), grayImage.getCvImage(), NULL);
		} else {
			
			// or we do it ourselves - show people how they can work with the pixels
			unsigned char * pix = grayImage.getPixels();
			
			int numPixels = grayImage.getWidth() * grayImage.getHeight();
			for(int i = 0; i < numPixels; i++) {
				if(pix[i] < nearThreshold && pix[i] > farThreshold) {
					pix[i] = 255;
				} else {
					pix[i] = 0;
				}
			}
		}
        
		// update the cv images
        grayImage.mirror(false, true);
        
		grayImage.flagImageChanged();
		
		// find contours which are between the size of 20 pixels and 1/3 the w*h pixels.
		// also, find holes is set to true so we will get interior contours as well....
		contourFinder.findContours(grayImage, 10, (kinect.width*kinect.height)/2, 20, false);
	}
    
    
    // FBO stuff
    // Cleaning everthing with alpha mask on 0 in order to make it transparent for default
    // Still don't totally understand the clearing+blending, but managed to get it going
    
    // emitter FBO
    sourceFbo.begin();
    ofClear(0,0,0,0);
    ofSetColor(0, 0, 0,255);
    m_emitter.draw(0,0);
    sourceFbo.end();
    
    // This lets us getColorAt(x,y) and render to the point cloud
    ofPixels *srcPixels;
    sourceFbo.readToPixels(sourceImage.getPixelsRef());
    sourceImage.update();
    
    // Mask yo!
    maskFbo.begin();
    ofSetColor(255, 255, 255,255);
    grayImage.draw(0, 0,ofGetWidth(), ofGetHeight());
    maskFbo.end();
    
    // Results shader FBO
    fbo.begin();
    ofClear(255, 255, 255, 255);
    shader.begin();
    shader.setUniformTexture("maskTex", maskFbo.getTextureReference(), 1 );
    sourceFbo.draw(0,0);
    shader.end();
    fbo.end();
}

//--------------------------------------------------------------
void testApp::draw() {
    
	ofSetColor(255, 255, 255,255);
	
	if(bDrawPointCloud) {
		easyCam.begin();
		drawPointCloud();
		easyCam.end();
	} else {
        
        // for speed, only draw debug info if gui is visible
        if (gui->isVisible()) {
            kinect.drawDepth(1030, 10, 200, 150);
            kinect.draw(1030, 165, 200, 150);
            grayImage.draw(1030, 320, 200, 150);
            contourFinder.draw(1030, 475, 200, 150);
        }
	}
    
	
	// draw instructions
	ofSetColor(0, 0, 0, 255);
	stringstream reportStream;
	reportStream << "accel is: " << ofToString(kinect.getMksAccel().x, 2) << " / "
	<< ofToString(kinect.getMksAccel().y, 2) << " / "
	<< ofToString(kinect.getMksAccel().z, 2) << endl
	<< "press p to switch between images and point cloud, rotate the point cloud with the mouse" << endl
	<< "using opencv threshold = " << bThreshWithOpenCV <<" (press spacebar)" << endl
	<< "set near threshold " << nearThreshold << " (press: + -)" << endl
	<< "set far threshold " << farThreshold << " (press: < >) num blobs found " << contourFinder.nBlobs
	<< ", fps: " << ofGetFrameRate() << endl
	<< "press c to close the connection and o to open it again, connection is: " << kinect.isConnected() << endl
	<< "press UP and DOWN to change the tilt angle: " << angle << " degrees" << endl;
	ofDrawBitmapString(reportStream.str(),20,652);
    
    
    // our projection
    if(!bDrawPointCloud) {
        // draw from the live kinect
        ofSetColor(0);
        ofNoFill();
        ofRect(220,10,800,600);
        ofSetColor(255, 255, 255,255);
        ofFill();
        fbo.draw(220, 10, 800, 600);
    }
    
    
}

void testApp::drawPointCloud() {
	int w = 640;
	int h = 480;
	ofMesh mesh;
	mesh.setMode(OF_PRIMITIVE_POINTS);
	int step = 2;
	for(int y = 0; y < h; y += step) {
		for(int x = 0; x < w; x += step) {
			if(kinect.getDistanceAt(x, y) > 0) {
				mesh.addColor(sourceImage.getColor(x,y)); // modded to accept a source image
				mesh.addVertex(kinect.getWorldCoordinateAt(x, y));
			}
		}
	}
	glPointSize(3);
	ofPushMatrix();
	// the projected points are 'upside down' and 'backwards' 
	ofScale(1, -1, -1);
	ofTranslate(0, 0, -1000); // center the points a bit
	glEnable(GL_DEPTH_TEST);
	mesh.drawVertices();
	glDisable(GL_DEPTH_TEST);
	ofPopMatrix();
}

//--------------------------------------------------------------
void testApp::guiEvent(ofxUIEventArgs &e)
{
	string name = e.widget->getName();
	int kind = e.widget->getKind();
	
	if(name == "NEAR")
	{
		ofxUISlider *slider = (ofxUISlider *) e.widget;
		nearThreshold = slider->getScaledValue();
	}
	else if(name == "FAR")
	{
		ofxUISlider *slider = (ofxUISlider *) e.widget;
		farThreshold = slider->getScaledValue();
	}
	else if(name == "ANGLE")
	{
		ofxUISlider *slider = (ofxUISlider *) e.widget;
		angle = slider->getScaledValue();
	}
    else if(name == "POINTCLOUD")
	{
        ofxUILabelToggle *toggle = (ofxUILabelToggle *) e.widget;
        bDrawPointCloud = toggle->getValue();
	}
    
}

//--------------------------------------------------------------
void testApp::exit() {
	kinect.setCameraTiltAngle(0); // zero the tilt on exit
	kinect.close();
    
    gui->saveSettings("GUI/guiSettings.xml");
    delete gui;
}

//--------------------------------------------------------------
void testApp::keyPressed (int key) {
    
    // our UI/CONTROLS
    
	switch (key) {
		case ' ':
			bThreshWithOpenCV = !bThreshWithOpenCV;
			break;
			
		case'p':
			bDrawPointCloud = !bDrawPointCloud;
			break;
			
		case '>':
		case '.':
			farThreshold ++;
			if (farThreshold > 255) farThreshold = 255;
			break;
			
		case '<':
		case ',':
			farThreshold --;
			if (farThreshold < 0) farThreshold = 0;
			break;
			
		case '+':
		case '=':
			nearThreshold ++;
			if (nearThreshold > 255) nearThreshold = 255;
			break;
			
		case '-':
			nearThreshold --;
			if (nearThreshold < 0) nearThreshold = 0;
			break;
			
		case 'w':
			kinect.enableDepthNearValueWhite(!kinect.isDepthNearValueWhite());
			break;
			
		case 'o':
			kinect.setCameraTiltAngle(angle); // go back to prev tilt
			kinect.open();
			break;
			
		case 'c':
			kinect.setCameraTiltAngle(0); // zero the tilt
			kinect.close();
			break;
            
        case 'x':
            maskFbo.begin();
            ofClear(0,0,0,255);
            maskFbo.end();
            break;
			
		case OF_KEY_UP:
			angle++;
			if(angle>30) angle=30;
			kinect.setCameraTiltAngle(angle);
			break;
			
		case OF_KEY_DOWN:
			angle--;
			if(angle<-30) angle=-30;
			kinect.setCameraTiltAngle(angle);
			break;
            
        case 'g':
            gui->toggleVisible();
            break;
	}
    
    
    // Load up different FX and shtuff
    switch (key) {
        case '1':
            m_emitter.loadFromXml("ohSnap2.pex");
            break;
        case '2':
            m_emitter.loadFromXml("2.pex");
            break;
        case '3':
            m_emitter.loadFromXml("3.pex");
            break;
        case '4':
            m_emitter.loadFromXml("4.pex");
            break;
        case '5':
            m_emitter.loadFromXml("5.pex");
            break; 
    }
    
}

//--------------------------------------------------------------
void testApp::mouseDragged(int x, int y, int button)
{}

//--------------------------------------------------------------
void testApp::mousePressed(int x, int y, int button)
{}

//--------------------------------------------------------------
void testApp::mouseReleased(int x, int y, int button)
{}

//--------------------------------------------------------------
void testApp::windowResized(int w, int h)
{}
