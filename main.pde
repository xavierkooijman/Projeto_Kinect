import processing.sound.*; 
import processing.core.PFont;

PFont gameFont;
Menu menu;
boolean showProject;

void setup() {
  size(1280, 720);
  
  gameFont = createFont("data/Minecraft.ttf", 48);
  setupCV(); 
  setupGame();
  showProject = false;
  menu = new Menu();
}

void draw() {
  if (showProject) {
    drawGame();
  } else {
    menu.draw();
  }
}