// Learning Processing
// Daniel Shiffman
// http://www.learningprocessing.com

// Example 10-5: Object-oriented timer

void createTimers() {
  // setup our timers
  swapTime *= 1000;
  swapTimer = new Timer(swapTime);
  swapTimer.start();

  
  // create the array of swap timers
  for (int s = 0; s < swapTimers.length; s++) {
   
    swapTimes[s] = 3000;
    swapTimers[s] = new Timer(swapTimes[s]);
    swapTimers[s].start();
    
  }

  requestTimer = new Timer(10000);
  requestTimer.start(); 
}

void setSwapTimer(int seconds) {
  // update the swap timer based on UI
  swapTime = seconds;
  
  seconds *= 1000;
  swapTimer = new Timer(seconds);
  swapTimer.start();
}

void setSwapTimerAtIndex(int index, int seconds) {
  
  int newSwapTime = seconds;
  seconds *= 1000;
  swapTimers[index] = new Timer(seconds);
  swapTimers[index].start();
}

class Timer {
 
  int savedTime; // When Timer started
  int totalTime; // How long Timer should last
  
  Timer(int tempTotalTime) {
    totalTime = tempTotalTime;
  }
  
  // Starting the timer
  void start() {
    // When the timer starts it stores the current time in milliseconds.
    savedTime = millis(); 
  }
  
  // The function isFinished() returns true if 5,000 ms have passed. 
  // The work of the timer is farmed out to this method.
  boolean isFinished() { 
    // Check how much time has passed
    int passedTime = millis()- savedTime;
    if (passedTime > totalTime) {
      return true;
    } else {
      return false;
    }
  }
}
