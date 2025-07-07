enum GameState {
  MENU,
  MUSIC_SELECT,
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
  Button prevSongButton, nextSongButton;
  GameState currentState;
  ArrayList<String> musicFiles;
  int currentMusicIndex;
  HashMap<String,Record> records;
  
Menu(HashMap<String,Record> records) {
    currentState = GameState.MENU;
    currentMusicIndex = 0;
    this.records = records;
    
    float buttonWidth = 300;
    float buttonHeight = 60;
    float centerX = width/2 - buttonWidth/2;
    float startY = height/2 - buttonHeight;
    
    playButton = new Button(centerX, startY, buttonWidth, buttonHeight, "Jogar");
    tutorialButton = new Button(centerX, startY + buttonHeight + 20, buttonWidth, buttonHeight, "Como Jogar");
    quitButton = new Button(centerX, startY + (buttonHeight + 20) * 2, buttonWidth, buttonHeight, "Sair");
    backButton = new Button(20, 20, 150, 50, "Voltar");
    
    // Botões para navegação entre músicas
    prevSongButton = new Button(centerX - 50, startY - 80, 40, 40, "<");
    nextSongButton = new Button(centerX + buttonWidth + 10, startY - 80, 40, 40, ">");
    
    // Carregar músicas disponíveis
    loadAvailableMusic();
  }
  
  void loadAvailableMusic() {
    musicFiles = new ArrayList<String>();
    File dataFolder = new File(sketchPath() + "/data");
    File[] files = dataFolder.listFiles();
    
    if (files != null) {
      for (File file : files) {
        String name = file.getName().toLowerCase();
        if (name.endsWith(".wav") || name.endsWith(".mp3")) {
          musicFiles.add(file.getName());
        }
      }
    }
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
        case MUSIC_SELECT:
          drawMusicSelection();
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
  
  // Recalculate button positions
  float buttonWidth = 300;
  float buttonHeight = 60;
  float centerX = width/2 - buttonWidth/2;
  float startY = height/2;
  
  // Update button positions
  playButton = new Button(centerX, startY, buttonWidth, buttonHeight, "Jogar");
  tutorialButton = new Button(centerX, startY + buttonHeight + 20, buttonWidth, buttonHeight, "Como Jogar");
  quitButton = new Button(centerX, startY + (buttonHeight + 20) * 2, buttonWidth, buttonHeight, "Sair");
  
  // Draw buttons
  playButton.draw();
  tutorialButton.draw();
  quitButton.draw();
}

void drawMusicSelection() {
  // Título com efeito de brilho
  textSize(72);
  
  // Efeito de brilho exterior
  for(int i = 4; i > 0; i--) {
    fill(255, 255, 255, 30);
    text("Selecione a Musica", width/2 + i, height/4 + i);
  }
  
  // Texto principal
  fill(255);
  text("Selecione a Musica", width/2, height/4);
  
  if (musicFiles.size() > 0) {
    // Display current music with box background
    float boxWidth = width * 0.6;
    float boxHeight = 80;
    float boxX = width/2 - boxWidth/2;
    float boxY = height/2 - boxHeight/2;
    
    // Draw box background with glow effect
    for(int i = 3; i > 0; i--) {
      noStroke();
      fill(52, 235, 216, 20);
      rect(boxX - i, boxY - i, boxWidth + i*2, boxHeight + i*2, 15);
    }
    
    // Main box
    fill(0, 150);
    stroke(52, 235, 216);
    strokeWeight(2);
    rect(boxX, boxY, boxWidth, boxHeight, 15);
    
    // Music name
    textSize(32);
    fill(255);
        
    String currentMusic = musicFiles.get(currentMusicIndex);
    text(currentMusic, width/2, height/2);
    
    String findMusic = currentMusic;
    if (findMusic.lastIndexOf('.') != -1) {
      findMusic = findMusic.substring(0, findMusic.lastIndexOf('.'));
    };
    
    Record r = records.get(findMusic);
    if (r != null) {
      textFont(gameFont);
      textSize(24);
      fill(255, 200);
      textAlign(CENTER, TOP);
      text("Recorde: " + r.score + "pts   /    Combo: " + r.combo,
      width / 2, boxY - 40);
    }
    
    // Navigation buttons with updated positions
    float buttonSpacing = 60;
    prevSongButton = new Button(boxX - buttonSpacing, boxY + boxHeight/2 - 20, 40, 40, "<");
    nextSongButton = new Button(boxX + boxWidth + buttonSpacing - 40, boxY + boxHeight/2 - 20, 40, 40, ">");
    
    prevSongButton.draw();
    nextSongButton.draw();
    
    // Play button with new style
    float playButtonWidth = 200;
    float playButtonHeight = 50;
    playButton = new Button(width/2 - playButtonWidth/2, height/2 + boxHeight + 40, 
                          playButtonWidth, playButtonHeight, "Jogar");
    playButton.draw();
    
    // Back button
    backButton = new Button(20, 20, 150, 50, "Voltar");
    backButton.draw();
  } else {
    textSize(24);
    fill(255, 100);
    text("Nenhuma música encontrada na pasta data", width/2, height/2);
  }
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
    "Toque nos retangulos para arrasta-los no sentido das setas!",
    "Retangulos valem 300 pontos!",
    "Fique com a mao nos quadrados durante breves momentos!",
    "Quadrados valem 200 pontos!",
    "Aumente o seu combo ao nao perder nenhuma figura!"
  };
  
  for(int i = 0; i < instructions.length; i++) {   
    if (i < 4) {
      // Sombra suave
      fill(0, 100);
      text(instructions[i], width/2 + 2, height/3 + i * 50 + 2);
      // Texto principal
      fill(255);
      text(instructions[i], width/2, height/3 + i * 50);
    } else if (i >= 4 && i < 6) {
      // Sombra suave
      fill(0, 100);
      text(instructions[i], width/2 + 2, height/3 + i * 60 + 2);
      // Texto principal
      fill(255);
      text(instructions[i], width/2, height/3 + i * 60);
    } else if (i >= 6 && i < 8) {
      // Sombra suave
      fill(0, 100);
      text(instructions[i], width/2 + 2, height/3 + i * 70 + 2);
      // Texto principal
      fill(255);
      text(instructions[i], width/2, height/3 + i * 70);
    } else {
      // Sombra suave
      fill(0, 100);
      text(instructions[i], width/2 + 2, height/3 + i * 80 + 2);
      // Texto principal
      fill(255);
      text(instructions[i], width/2, height/3 + i * 80);
    }
  }
  
  backButton.draw();
}
}
