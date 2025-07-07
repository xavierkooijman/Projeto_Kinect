import processing.sound.*; 
import processing.core.PFont;

PFont gameFont;
Menu menu;
boolean showProject;

void setup() {
  size(1920, 1080);
  frameRate(40);
  
  gameFont = createFont("data/Minecraft.ttf", 48);
  
  //setupCV(); 
  setupGame();
  showProject = false;
  loadRecords();
  menu = new Menu(records);
}

void draw() {
  // Clear screen first
  background(0);
  
  if (showProject) {
    drawGame();
  } else {
    menu.draw();
  }
}
