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
    } else {
      showProject = !showProject;
    }
    println(showProject);
  }
} 
