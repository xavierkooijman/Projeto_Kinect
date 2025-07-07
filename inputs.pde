void keyPressed() {
  //if ( keyCode == UP ) {
  //  threshold += 0.01;
  //}
  
  //if ( keyCode == DOWN ) {
  //  threshold -= 0.01;
  //}
  
  //// restricts the treshold variable between 0 and 1;
  //threshold = constrain(threshold, 0.0, 1.0);
  
  //// IMPORTTANT FOR CALIBRATION
  //println("Threshold:" + threshold);
  
  //if ( key == 'f' ) {
  //  erodeDilate = !erodeDilate;
  //}
  
  //if ( key == 'b') {
  //  boundingBoxes = !boundingBoxes;
  //}
  
  //if ( key == 'c') {
  //  countours = !countours;
  //}
  
  if (key == ' ') {
    if (menu.currentState == GameState.TUTORIAL) {
      menu.currentState = GameState.MENU;
    } else if (showProject) {
      // Reset game state
      showProject = false;
      if (music != null && music.isPlaying()) {
        music.stop();
      }
      setupGame();
      totalScore = 0;
      circles.clear();
      rectangles.clear();
      
      // Força limpar a tela ao voltar ao menu
      background(0);
    }
  }
} 

void mousePressed() {
  if (!showProject) {
    if(menu.currentState == GameState.MENU) {
      if(menu.playButton.isMouseOver()) {
        // Em vez de começar o jogo, vai para a tela de seleção de música
        menu.currentState = GameState.MUSIC_SELECT;
      } else if(menu.tutorialButton.isMouseOver()) {
        menu.currentState = GameState.TUTORIAL;
      } else if(menu.quitButton.isMouseOver()) {
        exit();
      }
    } else if(menu.currentState == GameState.MUSIC_SELECT) {
      if(menu.playButton.isMouseOver()) {
        // Se houver música selecionada
        if (menu.musicFiles.size() > 0) {
          // Recarregar a música se mudou
          if (music != null) {
            music.stop();
            music = null;
          }
          showProject = true;
          
          countdownRunning = true;
          countdownTimer = millis();
          gameStarted = false;
          
          setupGame();
        }
      } else if(menu.backButton.isMouseOver()) {
        menu.currentState = GameState.MENU;
      } else if(menu.prevSongButton.isMouseOver()) {
        menu.currentMusicIndex--;
        if (menu.currentMusicIndex < 0) {
          menu.currentMusicIndex = menu.musicFiles.size() - 1;
        }
      } else if(menu.nextSongButton.isMouseOver()) {
        menu.currentMusicIndex++;
        if (menu.currentMusicIndex >= menu.musicFiles.size()) {
          menu.currentMusicIndex = 0;
        }
      }
    } else if(menu.currentState == GameState.TUTORIAL) {
      if(menu.backButton.isMouseOver()) {
        menu.currentState = GameState.MENU;
      }
    }
  }
  
  // If game is over
    if (showEndScreen) {
      boolean isMouseInsideButton1 = mouseX >= width / 2 - 120 && mouseX <= width / 2 - 120 + 180
      && mouseY >= height / 2 + 80 && mouseY <= height / 2 + 80 + 50;
      if (isMouseInsideButton1) {
        showEndScreen = false;
        goToMenu();
      }
      
      boolean isMouseInsideButton2 = mouseX >= width / 2 + 120 && mouseX <= width / 2 + 120 + 180
      && mouseY >= height / 2 + 80 && mouseY <= height / 2 + 80 + 50;
      if (isMouseInsideButton2) {
        showEndScreen = false;
        restartCurrentSong();
      }
    }
}

void goToMenu() {
  showProject = false;
  showEndScreen = false;
  
  loadRecords();
  menu = new Menu(records);
  menu.currentState = GameState.MENU;
  
  totalScore = 0;
  bestCombo = 0;
  circles.clear();
  rectangles.clear();
    
  // Garante que o fundo está limpo
  background(0);
}
 
void restartCurrentSong() {
  showProject = true;
  countdownRunning = true;
  countdownTimer = millis();
  gameStarted = false;
  
  setupGame();
}
