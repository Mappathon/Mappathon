class InstagramImage {

  String id; 
  String fileName;
  String url;
  boolean hasDownloaded;
  boolean existsLocally;

  PImage image; // our actual image file
  int x, y; // x and y position
  int imgW = 612; // default instagram image width
  int imgH = 612; // image height
  
  float alpha = 255;
  boolean fadingIn = false;
  boolean fadingOut = false;

  InstagramImage(PImage _theImage, String _fileName) {

    image = _theImage;
    fileName = _fileName;
  }

  void checkIfExists() {
  }

  void download() {
  }

  void render(int x, int y) {
    
    //tint(255, alpha);
    image(image, x, y);
    
    if (fadingIn) {
      fadeIn();
      fadingOut = false;
    }
    if (fadingOut) {
      fadeOut();
      fadingIn = false;
    }
      
  }
  
  void fadeOut() {
    do 
    {
      alpha --;
    } while (alpha > 0);
  }
  
  void fadeIn() {
    do
    {
      alpha ++;
    } while (alpha < 255);
  }
  
}
