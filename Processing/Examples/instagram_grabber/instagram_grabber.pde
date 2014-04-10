import http.requests.*;
import codeanticode.syphon.*;

SyphonServer server;

// time to poll
int savedTime;
int totalTime = 600000; // 30 seconds

// time to switch images
int savedTimeShow;
int totalTimeShow = 30000; // 10 seconds

ArrayList<String> imageUrls;
ArrayList<PImage> imageFiles;
ArrayList<PImage> imageFiles2;
ArrayList<PImage> luckySeven1;
ArrayList<PImage> luckySeven2;

GetRequest getTag1;
GetRequest getTag2;

String[] hashTag;
String[] tags;

public void setup() 
{
  size(960, 295, P3D);

  // load settings
  hashTag = loadStrings("data.txt");
  tags = split(hashTag[0], "," );
  println("tags: " + tags);
  totalTimeShow = int(hashTag[1]) * 1000;
  println("current hashtag: " + hashTag[0] + " currentTime: " + hashTag[1]);

  // timers
  savedTime = millis();
  savedTimeShow = millis();

  imageFiles = new ArrayList<PImage>();
  imageFiles2 = new ArrayList<PImage>();
  luckySeven1 = new ArrayList<PImage>();
  luckySeven2 = new ArrayList<PImage>(); 
  imageUrls = new ArrayList<String>(); 

  server = new SyphonServer(this, "Processsing Syphon");

  grabImages1();
}

void draw() {
  background(0);
  
  int passedTime = millis() - savedTime;
  int passedTime2 = millis() - savedTimeShow;

  // Has our seconds passed?
  if (passedTime > totalTime) {
    grabImages1();
    savedTime = millis(); // Save the current time to restart the timer!
  }


  // Has our show timer passed?
  if (passedTime2 > totalTimeShow) {
    if (imageUrls.size() > 0)
      displayNextImage();
    savedTimeShow = millis(); // Save the current time to restart the timer!
  }

  if (luckySeven1.size() > 0) {

    //pushMatrix();
    //scale(1.0, -1.0);
    for (int d = 0; d < luckySeven1.size(); d++) {
      PImage tmpGrab = luckySeven1.get(d);
      image(tmpGrab, d * 137, 0, width/7, 137);
    }
    //popMatrix();


  }
  
  if (luckySeven2.size() > 0) {

    //pushMatrix();
    //scale(1.0, -1.0);
    for (int e = 0; e < luckySeven2.size(); e++) {
      PImage tmpGrab = luckySeven2.get(e);
      image(tmpGrab, e * 137, 147, width/7, 137);
    }
    //popMatrix();

 
  }
  
    PImage sender = get();
    server.sendImage(sender);
} 

void grabImages1() {

  println("grabbing images1");

  getTag1 = new GetRequest("https://api.instagram.com/v1/tags/" + tags[0] + "/media/recent?callback=?&amp;client_id=a307c0d0dada4b77b974766d71b72e0e");
  getTag1.send(); // program will wait untill the request is completed

  JSONObject response = parseJSONObject(getTag1.getContent());
  JSONArray data = response.getJSONArray("data");

  for (int j = 0; j <= data.size() - 1; j++) {
    JSONObject obj = data.getJSONObject(j);    
    JSONObject images = obj.getJSONObject("images");
    JSONObject params = images.getJSONObject("standard_resolution");
    String url = params.getString("url");

    if (!imageUrls.contains(url)) {
      println("adding url: " + url);
      imageUrls.add(url);
      PImage tmpImg = loadImage(url, "png");
      imageFiles.add(tmpImg);
    }
  }

  grabImages2();
}

void grabImages2() {

  println("grabbing images 2");

  getTag2 = new GetRequest("https://api.instagram.com/v1/tags/" + tags[1] + "/media/recent?callback=?&amp;client_id=a307c0d0dada4b77b974766d71b72e0e");
  getTag2.send(); // program will wait untill the request is completed

  JSONObject response = parseJSONObject(getTag2.getContent());
  JSONArray data = response.getJSONArray("data");

  for (int j = 0; j <= data.size() - 1; j++) {
    JSONObject obj = data.getJSONObject(j);    
    JSONObject images = obj.getJSONObject("images");
    JSONObject params = images.getJSONObject("standard_resolution");
    String url = params.getString("url");

    if (!imageUrls.contains(url)) {
      println("adding url: " + url);
      imageUrls.add(url);
      PImage tmpImg = loadImage(url, "png");
      imageFiles2.add(tmpImg);
    }
  }
}

void displayNextImage() {

  luckySeven1 = new ArrayList<PImage>();  // Create an empty ArrayList
  luckySeven2 = new ArrayList<PImage>();  // Create an empty ArrayList
  
  for (int l = 0; l < 7; l++) {
    int indexR = int(random(0, imageFiles.size()));
    PImage rndImage = imageFiles.get(indexR);   
    luckySeven1.add(rndImage);
  }
 
  for (int k = 0; k < 7; k++) {
    int indexK = int(random(0, imageFiles2.size()));
    PImage rndImage2 = imageFiles2.get(indexK);   
    luckySeven2.add(rndImage2);
  } 
  
}

