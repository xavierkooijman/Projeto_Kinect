enum GameState {
  MENU,
  GAME,
  TUTORIAL
}

class Button {
  float x, y, w, h;
  String label;
  color buttonColor;
  
  Button(float x, float y, float w, float h, String label) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
    this.buttonColor = color(52, 235, 216); // Azul ciano característico do MaiMai
  }
  
void draw() {
    boolean isHovered = isMouseOver();
    
    // Efeito de brilho
    for(int i = 3; i > 0; i--) {
      noStroke();
      fill(255, 255, 255, isHovered ? 40 : 20);
      rect(x - i, y - i, w + i*2, h + i*2, 10);
    }
    
    // Button background
    fill(buttonColor);
    stroke(255);
    strokeWeight(2);
    rect(x, y, w, h, 10);
    
    // Button text
    textAlign(CENTER, CENTER);
    fill(255);
    textSize(24);
    text(label, x + w/2, y + h/2);
  }
  
  boolean isMouseOver() {
    return mouseX >= x && mouseX <= x + w && 
           mouseY >= y && mouseY <= y + h;
  }
  
  boolean isClicked() {
    return isMouseOver() && mousePressed;
  }
}

class Menu {
  Button playButton, tutorialButton, quitButton, backButton;
  GameState currentState;
  
Menu() {
    currentState = GameState.MENU;
    
    float buttonWidth = 300;
    float buttonHeight = 60;
    float centerX = width/2 - buttonWidth/2;
    float startY = height/2 - buttonHeight;
    
    playButton = new Button(centerX, startY, buttonWidth, buttonHeight, "Jogar");
    tutorialButton = new Button(centerX, startY + buttonHeight + 20, buttonWidth, buttonHeight, "Como Jogar");
    quitButton = new Button(centerX, startY + (buttonHeight + 20) * 2, buttonWidth, buttonHeight, "Sair");
    backButton = new Button(20, 20, 150, 50, "Voltar");
  }
  void draw() {
    // Draw the menu only when not in game
    if (!showProject) {
      // Draw gradient background
      drawGradientBackground();
      
      textFont(gameFont);
      textAlign(CENTER, CENTER);
      
      switch(currentState) {
        case MENU:
          drawMainMenu();
          break;
        case TUTORIAL:
          drawTutorial();
          break;
      }
    }
  }
  
void drawGradientBackground() {
    // Draw gradient manually from top to bottom
    noSmooth();
    for (int y = 0; y < height; y++) {
      float inter = map(y, 0, height, 0, 1);
      color c = lerpColor(color(52, 235, 216), color(0), inter);
      stroke(c);
      line(0, y, width, y);
    }
    smooth();
  }
  
  void drawMainMenu() {
    // Título com efeito de brilho
    textSize(72);
    
    // Efeito de brilho exterior
    for(int i = 4; i > 0; i--) {
      fill(255, 255, 255, 30);
      text("Maimai Game", width/2 + i, height/4 + i);
    }
    
    // Texto principal
    fill(255);
    text("Maimai Game", width/2, height/4);
    
    // Subtítulo
    textSize(24);
    fill(255, 200);
    text("Use seu corpo para jogar!", width/2, height/4 + 60);
    
    // Draw buttons
    playButton.draw();
    tutorialButton.draw();
    quitButton.draw();
  }
  
  void drawTutorial() {
    // Tutorial text com efeito de brilho
    textSize(48);
    
    // Efeito de brilho
    for(int i = 3; i > 0; i--) {
      fill(255, 255, 255, 30);
      text("Como Jogar", width/2 + i, height/6 + i);
    }
    
    fill(255);
    text("Como Jogar", width/2, height/6);
    
    // Instruções com estilo melhorado
    textSize(28);
    String[] instructions = {
      "Use seus bracos para tocar nos circulos",
      "Circulos verdes valem 50 pontos",
      "Circulos amarelos valem 100 pontos",
      "Circulos vermelhos valem 150 pontos",
      "Toque nos retangulos para arrasta-los"
    };
    
    for(int i = 0; i < instructions.length; i++) {
      // Sombra suave
      fill(0, 100);
      text(instructions[i], width/2 + 2, height/3 + i * 50 + 2);
      // Texto principal
      fill(255);
      text(instructions[i], width/2, height/3 + i * 50);
    }
    
    backButton.draw();
  }
}
