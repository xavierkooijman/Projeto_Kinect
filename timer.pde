int gameDuration = 20 * 1000;
int gameStartTime = 0;
boolean timerActive = false;

void startTimer() {
  
  // start timer
  gameStartTime = millis();
  timerActive = true;
}

void resetTimer() {
  
  // reset timer
  timerActive = false;
  gameStartTime = 0;
}

int getTimeLeft() {
  
  // get the time left (in seconds)
  if (!timerActive) return gameDuration;
  
  int elapsed = millis() - gameStartTime;
  return max(0, gameDuration - elapsed);
}

boolean isTimeUp() {
  
  // verify if the time is up
  return timerActive && millis() - gameStartTime >= gameDuration;
}

void drawTimerDisplay() {
  
  // draw the timer in mm:ss format
  if (!gameStarted || !timerActive) return;
  
  int timeLeft = getTimeLeft();
  int seconds = (timeLeft / 1000) % 60;
  int minutes = (timeLeft / 1000) / 60;
  
  String timerText = nf(minutes, 2) + ":" + nf(seconds, 2);
  
  pushStyle();
  
  textFont(gameFont);
  textSize(24);
  fill(255);
  textAlign(LEFT, TOP);
  text("Tempo restante: " + timerText, 20, 20);
  
  popStyle();
  
  if (isTimeUp()) {
    gameStarted = false;
    timerActive = false;
    endGame();
    if (music != null && music.isPlaying()) music.stop(); 
  }
}
