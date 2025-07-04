import processing.sound.*; 
boolean showProject;

////////////////////////////////////////////

////////////////////////////////////////////
void setup() {
  size(1280, 720);
  
  setupCV(); 
  setupGame();
  showProject = true;
}

void draw() {
  if (showProject == false) {
    //updateCV();
    drawCV(); 
  } else {
    drawGame();
  }
}
