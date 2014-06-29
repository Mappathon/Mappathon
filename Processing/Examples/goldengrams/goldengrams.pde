import http.requests.*; // processing library for http requests
import codeanticode.syphon.*; // syphon
import controlP5.*; // interface
import java.util.Collections; // for array shufflin'
import java.util.Arrays; // more shufflin'
import java.io.File; // directory stuff

// das do:
// fix alpha bug
// switch to p5 timers
// multiple tag support
// design mode

GetRequest getRequest; // to call up Instagram
ControlP5 cp5; // UI
SyphonServer syphon;
PGraphics canvas; // syphon canvas

// initialize
JSONObject configData;       // our settings object
String tag1, tag2 = "";      // our instagram tags to load
String url1, url2;           // urls to poll for instagram API
String clientId;             // instagram client ID
String appState = "loading"; // keep track of what our app is doing
float imageScale = 0.5;      // scaling our images by 1/2 to fit on our screen

ArrayList<File>localImagesList;    // list of images locally
ArrayList<File>remoteImagesList;   // images from json
InstagramImage[] displayImages = new InstagramImage[8]; // eight of em to display onscreen
ArrayList<Integer> rndShuffle = new ArrayList<Integer>();
boolean enableTransition = true;   // do we have fading in

// messing around with UI
boolean showUI = true;
int speed = 3;

int speed1, speed2, speed3,
    speed4, speed5, speed6,
    speed7, speed8;

Knob swapKnob;
Knob[] swapKnobs = new Knob[8];

// timers
Timer swapTimer, requestTimer;
int swapTime;

Timer[] swapTimers = new Timer[8];
int[] swapTimes = new int[8];

// debug
PFont loadingFont;

// setup
void setup() {
  size(1224, 612, P3D); // 4x2 grid at 0.5X image scale 
  frame.setTitle("loading...");

  // loading info
  loadingFont = createFont("Georgia", 128);
  textFont(loadingFont);
  textAlign(CENTER, CENTER);
  text("mappathon", width/2, height/2);

  createInterface(); // create UI
  loadConfig();      // load config from file
  initialize();      // init 

  // syphon stuff
  syphon = new SyphonServer(this, "Processsing Syphon");
  canvas = createGraphics(width, height, P3D);
}

void loadConfig() {  
  // load our config file in the data folder
  String configPath = sketchPath("config.json");
  configData = loadJSONObject(configPath);
  println("configPath: " + configPath);

  clientId = configData.getString("client-id");
  tag1 = configData.getString("tag1");
  swapTime = configData.getInt("transition-time");
  enableTransition = configData.getBoolean("show-transition");
  
  // create url based on incoming tag
  url1 = "https://api.instagram.com/v1/tags/" + tag1 + "/media/recent?callback=?&amp;client_id=" + clientId;
  
}

void initialize() {

  // setup local files and generate local image array
  println("listing local images");
  localImagesList = imagesToArrayList();
  for (File f : localImagesList) {
    println("local imageId: " + f.getName());
  }

  generateShuffle();
  createTimers();

  cp5.get(Textfield.class,"tag1").setText(tag1);
  frame.setTitle("downloading images for #" + tag1);
  
  // grab em
  getImagesForUrl(url1);
  pickDisplayImages();
}

void generateShuffle() {
  
  // generate our random shuffle so we don't have repeating numbers
  rndShuffle = new ArrayList<Integer>();
  for (int r = 0; r < 8; r++) {
    rndShuffle.add(int(r));
  }
  Collections.shuffle(rndShuffle);

  for (int r = 0; r < rndShuffle.size (); r++) {
    println("shufflin: " + rndShuffle.get(r));
  }  
}

// draw loop
void draw() {
  
  //background(0);
  //fill(0, 0, 0, 10);
  //rect(0, 0, width, height);

  // rows, cols
  int rows = 2;
  int cols = 4;
  int scale = 306; // size really

  canvas.beginDraw();

  int count = 0;
  for (int i = 0; i < cols; i++) {

    for (int j = 0; j < rows; j++) {

      int x = i * scale;
      int y = j * scale;

      //rect(x, y, 306, 306);
      if (enableTransition) {
        canvas.tint(255, 50);
      }

      if (count < displayImages.length) {
        canvas.image(displayImages[count].image, x, y, 306, 306);
      }


      count ++;
    }
  } 

  canvas.endDraw();

  image(canvas, 0, 0);
  syphon.sendImage(canvas);

  doTimers();


  if (showUI) {
    drawDebug(); // debug info window
    cp5.get(Textfield.class, "tag1").setVisible(true);
  } else {
    cp5.get(Textfield.class, "tag1").setVisible(false);
  }
  //syphon.sendImage(get());


  frame.setTitle("#" + tag1 + "     " + "total images:"  + localImagesList.size());
}

// -------------------------------------------------
void doTimers() {
  // swapout timer
  if (swapTimer.isFinished()) {
    //swapOutImage();
    //swapTimer.start();
  }
  
  // swapout index timer
  for (int s = 0; s < swapTimers.length; s++) {
    if (swapTimers[s].isFinished()) {
      swapOutImageAtIndex(s);
      swapTimers[s].start();
    }
  }

  // polling timer
  if (requestTimer.isFinished()) {
    getImagesForUrl(url1);
    requestTimer.start();
  }
}

// -------------------------------------------------
ArrayList imagesToArrayList() {

  ArrayList<File> localImagesList = new ArrayList<File>();
  //String folderPath = sketchPath + "/data/images";

  println("creating images to arrayList with tag: " + tag1);  

  File checkFolder = new File(sketchPath("images/" + tag1));
  String folderPath = "";

  if (checkFolder.exists()) {
    folderPath = sketchPath("images/" + tag1);
  } else {

    // if it doesnt exist we create it
    println("folder does not exist, creating...");    
    File newDirectory = new File(sketchPath("images/" + tag1));
    newDirectory.mkdir();
    folderPath = sketchPath("images/" + tag1);
  }

  if (folderPath != null) {
    File file = new File(folderPath);
    File[] files = file.listFiles();
    for (int i = 0; i < files.length; i++) {
      println("found this file locally: " + files[i].getName());
      if (!files[i].getName().equals(".DS_Store")) { // make sure it's not the hidden file
        localImagesList.add(files[i]);
      }
    }
  }

  return(localImagesList);
}

// -------------------------------------------------
void swapOutImage() {
  
  // called out periodically to swap out/in a new image
  println("swapping out an image");

  String fileName;
  int luckyNumber;
  int indexToReplace = int(random(displayImages.length));
  displayImages[indexToReplace].fadingOut = true;

  
  // this is an array of existing filenames so we don't pick duplicates
  ArrayList<String>checkArray = new ArrayList<String>(); 
  for (int d = 0; d < displayImages.length; d++) {
    checkArray.add(displayImages[d].fileName);
  }

  // keep generating random numbers untill we get a unique one
  if (displayImages.length >= 8) {
    do
    {
      // find a random index
      luckyNumber = int(random(localImagesList.size()));
      fileName = localImagesList.get(luckyNumber).getName();
      println("luckyNum: " + luckyNumber + "   toReplace: " + displayImages[indexToReplace].fileName + " fileName: " + fileName);
    } 
    while (checkArray.contains (fileName));
    
  } else {
    // find a random index
    luckyNumber = int(random(localImagesList.size()));
    fileName = localImagesList.get(luckyNumber).getName();
  }

  // replace it
  String swapPath = sketchPath("images/" + tag1 + "/" + fileName);
  PImage newImage = loadImage(swapPath);
  InstagramImage newImg = new InstagramImage(newImage, fileName);
  displayImages[indexToReplace] = newImg;
  displayImages[indexToReplace].fadingIn = true;
}

// -------------------------------------------------
void swapOutImageAtIndex(int index) {
  
  // called out periodically to swap out/in a new image
  println("swapping out an image");

  String fileName;
  int luckyNumber;
  int indexToReplace = index;
  displayImages[indexToReplace].fadingOut = true;

  
  // this is an array of existing filenames so we don't pick duplicates
  ArrayList<String>checkArray = new ArrayList<String>(); 
  for (int d = 0; d < displayImages.length; d++) {
    checkArray.add(displayImages[d].fileName);
  }

  // keep generating random numbers untill we get a unique one
  if (displayImages.length >= 8) {
    do
    {
      // find a random index
      luckyNumber = int(random(localImagesList.size()));
      fileName = localImagesList.get(luckyNumber).getName();
      println("luckyNum: " + luckyNumber + "   toReplace: " + displayImages[indexToReplace].fileName + " fileName: " + fileName);
    } 
    while (checkArray.contains (fileName));
    
  } else {
    // find a random index
    luckyNumber = int(random(localImagesList.size()));
    fileName = localImagesList.get(luckyNumber).getName();
  }

  // replace it
  String swapPath = sketchPath("images/" + tag1 + "/" + fileName);
  PImage newImage = loadImage(swapPath);
  InstagramImage newImg = new InstagramImage(newImage, fileName);
  displayImages[indexToReplace] = newImg;
  displayImages[indexToReplace].fadingIn = true;
}

// -------------------------------------------------
void pickDisplayImages() {

  println("picking images to display out of " + localImagesList.size() + " images");
  // we are going to be cool and pick from our
  // sweet shuffled array

  //int[] luckyNumbers = new int[8]; // these will be the indexs of images we are picking
  int max = localImagesList.size();

  int maxCheck;
  if (max < 8) {
    maxCheck = max;
  } else {
    maxCheck = 8;
  }

  displayImages = new InstagramImage[maxCheck]; // clear em out
  println ("maxCheck : " + maxCheck);

  generateShuffle();

  // pick the images
  for (int l = 0; l < maxCheck; l++) {
    //int num = int(random(max)); // int it

    int num = rndShuffle.get(l);
    println("random num " + num);

    String fileName = localImagesList.get(num).getName();
    String pickPath = sketchPath("images/" + tag1 + "/" + fileName);
    println("picking this one: " + pickPath);

    PImage newImage = loadImage(pickPath);
    InstagramImage newImg = new InstagramImage(newImage, fileName);
    displayImages[l] = newImg;
    println("new gram image ok count: " + l);
  }

  println("done with loop");
}

// -------------------------------------------------
void getImagesForUrl(String _inUrl) {

  getRequest = new GetRequest(_inUrl);
  getRequest.send();

  // start parsing
  JSONObject response = parseJSONObject(getRequest.getContent());
  JSONArray data = response.getJSONArray("data");

  println("listing remote images");
  for (int j = 0; j <= data.size () - 1; j++) {

    JSONObject obj = data.getJSONObject(j);    
    JSONObject images = obj.getJSONObject("images");
    String imageId = obj.getString("id");
    JSONObject params = images.getJSONObject("standard_resolution");
    String url = params.getString("url");

    //println("fetched imageId: " + imageId);

    // check if exists locally, if not then download
    // and add to local images list
    boolean doWeHaveIt = checkIfExists(imageId);

    if (doWeHaveIt) {
      // we have it not downloading
      println("found match for: " + imageId);
    } else {

      println("new image found now downloading: " + imageId);
      // now save it to the images folder
      PImage tmpImg = loadImage(url, "png");
      String doPath = sketchPath("images/" + tag1 + "/" + imageId + ".png");
      String filePath = doPath;
      tmpImg.save(filePath);

      // should add it to the local image array too
      File file = new File(filePath);
      localImagesList.add(file);
    }
  } // end json parse
}

// -------------------------------------------------
boolean checkIfExists(String inId) {

  //println("checking if: " + inId + " exists");

  boolean matchFound = false;
  for (File f : localImagesList) {

    String pngFileName = inId + ".png";
    //println("checking: " + pngFileName + " with: " + f.getName());

    if (pngFileName.equals(f.getName())) {
      matchFound = true;
    }
  }

  return matchFound;
}

// -------------------------------------------------
void drawDebug() {
  fill(0, 100);
  rect(0, 0, width, 55);
}

// -------------------------------------------------
void mousePressed() { 
  swapOutImage();
}

// -------------------------------------------------
void keyPressed() {
  if (key == '`' || key == '~') {
    showUI = !showUI;
  }
  
  if (key=='s' || key == 'S') {
    cp5.saveProperties(("supergrams.properties"));
  } 
  else if (key=='l' || key == 'L') {
    cp5.loadProperties(("supergrams.properties"));
  }
}


// -------------------------------------------------
void speed(int theValue) {
  println("a knob event. setting transition to " + theValue);
  setSwapTimer(theValue);
}

// -------------------------------------------------
void speed1(int theValue) {
  println("adjusting speed1");
  setSwapTimerAtIndex(0, theValue);
}
// -------------------------------------------------
void speed2(int theValue) {
  println("adjusting speed1");
  setSwapTimerAtIndex(1, theValue);  
}
// -------------------------------------------------
void speed3(int theValue) {
   println("adjusting speed1");
  setSwapTimerAtIndex(2, theValue); 
}
// -------------------------------------------------
void speed4(int theValue) {
  println("adjusting speed1");
  setSwapTimerAtIndex(3, theValue); 
}
// -------------------------------------------------
void speed5(int theValue) {
  println("adjusting speed1");
  setSwapTimerAtIndex(4, theValue); 
}
// -------------------------------------------------
void speed6(int theValue) {
  println("adjusting speed1");
  setSwapTimerAtIndex(5, theValue); 
}
// -------------------------------------------------
void speed7(int theValue) {
  println("adjusting speed1");
  setSwapTimerAtIndex(6, theValue);
}
// -------------------------------------------------
void speed8(int theValue) {
  println("adjusting speed1");
  setSwapTimerAtIndex(7, theValue); 
}

// -------------------------------------------------
void controlEvent(ControlEvent theEvent) {
  if (theEvent.isAssignableFrom(Textfield.class)) {
    println("controlEvent: accessing a string from controller '"
      +theEvent.getName()+"': "
      +theEvent.getStringValue()
      );

    tag1 = cp5.get(Textfield.class, "tag1").getText();
    url1 = "https://api.instagram.com/v1/tags/" + tag1 + "/media/recent?callback=?&amp;client_id=" + clientId;  
    initialize();
    cp5.get(Textfield.class,"tag1").setText(tag1);

  }

  //println("starting new feed for tag: " + theEvent.getStringValue());
}

// -------------------------------------------------
public void input(String theText) {
  // automatically receives results from controller input
  println("a textfield event for controller 'input' : "+theText);
}

// -------------------------------------------------
//cp5.get(Textfield.class,"textValue").clear();

