import processing.sound.*; 
import processing.core.PFont;

PFont gameFont;
Menu menu;
boolean showProject;

void setup() {
  size(1280, 720);
  gameFont = createFont("data/Minecraft.ttf", 48);
  showProject = false;
  menu = new Menu();  // Create menu first
  setupGame();        // Then call setupGame
}

void draw() {
  // Clear screen first
  background(0);
  
  // Draw either game or menu
  if (showProject) {
    // Draw main game
    drawGame();
  } else {
    // Draw menu system
    menu.draw(); // This line expects Menu to have a draw() method
  }
}