ArrayList <SkeletonData> bodies;
ArrayList <Circle> circles;
ArrayList <RectDrag> rectangles;
ArrayList <Square> squares;
ArrayList <String> difficulties;
PVector leftHand, rightHand;
String selectedMusic;

SoundFile music;
BeatDetector beatDetect;

int beatInterval = 650;
int totalScore = 0;
int combo = 0;
int bestCombo = 0;
int countdownStart = 3;
int countdownTimer;
boolean gameStarted;
boolean countdownRunning;
boolean showEndScreen;
int finalCombo;

void setupGame() {
  loadRecords();
  background(0);

  textAlign(LEFT, TOP);
  textSize(12);
  fill(255);
  stroke(255);
  strokeWeight(1);
  
  kinect = new Kinect(this);
  smooth();
  
  // Reset all game collections
  bodies = new ArrayList<SkeletonData>();
  circles = new ArrayList<Circle>();
  rectangles = new ArrayList<RectDrag>();
  squares = new ArrayList<Square>();
  difficulties = new ArrayList<String>();
  
  difficulties.add("Easy");
  difficulties.add("Medium");
  difficulties.add("Hard");
    
  // Setup music if not already setup
  // Setup music if not already setup and menu is initialized
  if (music == null && menu != null && menu.musicFiles != null && menu.musicFiles.size() > 0) {
    selectedMusic = menu.musicFiles.get(menu.currentMusicIndex);
    music = new SoundFile(this, "data/" + selectedMusic);
    beatDetect = new BeatDetector(this);
    beatDetect.input(music);
    beatDetect.sensitivity(beatInterval);
  }
}

// Adicionar este método novo
void startGameAudio() {
  if (!music.isPlaying()) {
    music.loop();
  }
}

void showCountdown() {
  int timeElapsed = (millis() - countdownTimer) / 1000;
  int count = countdownStart - timeElapsed;
  
  textAlign(CENTER, CENTER);
  textSize(100);
  fill(255);
  textFont(gameFont);
  
  if (count > 0) {
    text(str(count), width / 2, height / 2);
  } else {
    countdownRunning = false;
    gameStarted = true;
    totalScore = 0;
    combo = 0;
    startGameAudio();
    startTimer();
  }
}

void drawGame() {
  if (showEndScreen) {
    drawEndScreen();
    return;
  }
  
  // Clear screen first
  background(0);
  
  if (countdownRunning) {
    showCountdown();
    return;
  }
  
  if (gameStarted){
    drawTimerDisplay();
    
    // Salva o estado atual do texto
    pushStyle();
    
    // iterates through all bodies/skeletons that were detected
    for (int i = 0; i < bodies.size(); i++) {
      // Draws the nºi skeleton
      drawSkeleton(bodies.get(i));
      // Draws the nºi skeletons position
      drawPosition();
    }
  
    // Score display com configurações isoladas
    pushStyle();
    textFont(gameFont);
    fill(255);
    textSize(24);
    textAlign(RIGHT, TOP);
    text("Pontuacao: " + totalScore, width - 20, 20);
    text("Combo: " + combo, width - 20, 60);
    popStyle();
    
    ////////////////////////////////////
  
    ////////////////////////////////////  
    
    // Tracks the skeleton's hands position to detect if a hand "touched" a circle
    ArrayList<PVector> hands = new ArrayList<PVector>();
    for (SkeletonData s : bodies) {
      PVector left  = new PVector(s.skeletonPositions[Kinect.NUI_SKELETON_POSITION_HAND_LEFT ].x * width,
                                s.skeletonPositions[Kinect.NUI_SKELETON_POSITION_HAND_LEFT ].y * height);
      PVector right = new PVector(s.skeletonPositions[Kinect.NUI_SKELETON_POSITION_HAND_RIGHT].x * width,
                                s.skeletonPositions[Kinect.NUI_SKELETON_POSITION_HAND_RIGHT].y * height);
                                
    hands.add(left);
    hands.add(right);
    }
    
    
    // If a hand is detected, the circle disappears
    for (Circle c : circles) {
      if (!c.wasTouched) {
      for (PVector h : hands) {
        if (PVector.dist(h, new PVector(c.centerX, c.centerY)) < c.radius / 2) {
          combo++;
          bestCombo();
          c.onTouched();
          c.wasTouched = true;
          totalScore += c.score + combo * 5;
          break;
        }
      }
      }
    }
    
    // Detects if there's a hand inside the rectangle area, and if the user drags their harnd
    // through the rectangle in the correct direction
    for (RectDrag r : rectangles) {
      for (PVector h : hands) {
        PVector rectCoordinates = new PVector(h.x - r.rectX, h.y - r.rectY);
        
        PVector handCoordinates = new PVector(rectCoordinates.x * cos(-r.rotation) - rectCoordinates.y * sin(-r.rotation),
        rectCoordinates.x * sin(-r.rotation) + rectCoordinates.y * cos(-r.rotation));
        
        // checks if the hand is inside the rectangle
        if (!r.dragging && abs(handCoordinates.x) <= 70 && abs(handCoordinates.y) <= 300) {
            r.dragging = true;
            
            r.handTrail.add(new PVector(handCoordinates.x, handCoordinates.y));
          // if the hand left the rectangle
        } 
        
        // updates the hand's coordinates during the dragging
        if (r.dragging) {
          r.updateHandTrail(h.x, h.y);
        }
        
        if (r.dragging && (abs(handCoordinates.x) > 35 || abs(handCoordinates.y) > 150)) {
        r.dragging = false;
  
        // Verifica se o gesto foi correto com base nas setas
        if (!r.wasDragged && r.checkDragDirection()) {
          combo++;
          bestCombo();
          r.onDragged();
          r.wasDragged = true;
          totalScore += r.score + combo * 5;
        }
      }
       
       
    }
    }
    
    // detects a hand gesture
    for (Square s : squares) {
      for (PVector h : hands) {
        s.updateGesture(h.x, h.y);
      }
    }
    ////////////////////////////////////
  
    //////////////////////////////////// 
    
    // add a new circle or rectangle if there a beat is detected
    if (beatDetect.isBeat()) {
      float r = random(1);
      if (r < 0.65){
        newCircle();
      } else if (r < 0.85){
        newRect();
      } else {
        newSquare();
      }
    }
    
    // Draw circles
    for (Circle c : circles) c.drawCircle();
    
    // Draw rectangles
    for (RectDrag r : rectangles) r.drawRect();
    
    // Draw squares
    for (Square s : squares) s.drawSquare();
    
    // Remove the elements that are no longer showing up
    circles.removeIf(c -> !c.isShowing);
    rectangles.removeIf(r -> !r.isShowing);
    squares.removeIf(s -> !s.isShowing && s.frameEffect <= 0);
  
      popStyle();
  }
}

// checks if two elements might be overlapped
boolean elementsOverlap(float x1, float y1, float r1, float x2, float y2, float r2) {
  float distanceX = x1 - x2;
  float distanceY = y1 - y2;
  
  return distanceX * distanceX + distanceY * distanceY < sq(r1/2 + r2/2);
}

// Draws the nºi skeletons position
void drawPosition() {
  noStroke();
  fill(0, 100, 255);
}

// Verifies if a circle will overlap another element
// If it does, it will try another position
void newRect() {
  float rectRad = sqrt(50 * 50 + 300 * 300);
  float tries = 8;
  
  for (int i = 0; i < tries; i++) {
    RectDrag rect = new RectDrag();
    boolean overlap = false;
    
    // Checks if the new rectangle will overlap a circle
    for (Circle c : circles) {
      if (!overlap){
        if (elementsOverlap(c.centerX, c.centerY, c.radius, rect.rectX, rect.rectY, rectRad)) {
          overlap = true;
          break;
        }
      }
    }
    
    // Checks for other rectangles as well
    if (!overlap) {
      for (RectDrag r : rectangles) {
        if (elementsOverlap(r.rectX, r.rectY, rectRad, rect.rectX, rect.rectY, rectRad)) {
          overlap = true;
          break;
        }
      }
    }
    
    // verifies colision with other squares
    if (!overlap) {
      for (Square s : squares) {
        float halfDiag = sqrt(2) * s.squareSize / 2;
        if (elementsOverlap(s.squareX, s.squareY, halfDiag * 2, rect.rectX, rect.rectY, rectRad)) {
          overlap = true;
          break;
        }
      }
    }
    
    if (!overlap) {
      rectangles.add(rect);
      break;
    }
  }
}

void newCircle() {
  float rectRad = sqrt(50 * 50 + 300 * 300);
  float tries = 8;
  
  for (int i = 0; i < tries; i++) {
    Circle circle = new Circle(difficulties.get(int(random(difficulties.size()))));
    boolean overlap = false;
    
    // Checks if the new rectangle will overlap a circle
    for (Circle c : circles) {
      if (!overlap) {
        if (elementsOverlap(c.centerX, c.centerY, c.radius, circle.centerX, circle.centerY, rectRad)) {
          overlap = true;
          break;
        }
      }
    }
    
    // Checks for other rectangles as well
    if (!overlap) {
      for (RectDrag r : rectangles) {
        if (elementsOverlap(r.rectX, r.rectY, rectRad, circle.centerX, circle.centerY, rectRad)) {
          overlap = true;
          break;
        }
      }
    }
    
    // verifies colision with other squares
      if (!overlap) {
        for (Square s : squares) {
          float halfDiag = sqrt(2) * s.squareSize / 2;
          if (elementsOverlap(s.squareX, s.squareY, halfDiag * 2, circle.centerX, circle.centerY, rectRad)) {
            overlap = true;
            break;
          }
        }
      }
    
    if (!overlap) {
      circles.add(circle);
      break;
    }
  }
}

void newSquare() {
  float tries = 8;
  float rectRad = sqrt(50 * 50 + 300 * 300);
  
  for (int i = 0; i < tries; i++) {    
    Square s = new Square();
    float halfDiag = sqrt(2) * s.squareSize / 2;
    boolean overlap = false;
    
    // verifies colision with circles
    for (Circle c : circles) {
      if (!overlap){
        if (elementsOverlap(c.centerX, c.centerY, c.radius, s.squareX, s.squareY, halfDiag * 2)) {
          overlap = true;
          break;
        }
      }
    }
    
    // verifies colision with rectangles
      if (!overlap) {
        for (RectDrag r : rectangles) {
          if (elementsOverlap(r.rectX, r.rectY, rectRad, s.squareX, s.squareY, halfDiag * 2)) {
            overlap = true;
            break;
          }
        }
      }
      
      // verifies colision with other squares
      if (!overlap) {
        for (Square s2 : squares) {
          float halfDig2 = sqrt(2) * s2.squareSize / 2;
          if (elementsOverlap(s2.squareX, s2.squareY, halfDig2 * 2, s.squareX, s.squareY, halfDiag * 2)) {
            overlap = true;
            break;
          }
        }
      }
      
      if (!overlap) {
        squares.add(s);
        break;
      }
  }
}

void bestCombo() {
  if (combo > bestCombo) {
    bestCombo = combo;
  }
}

void endGame() {
  showEndScreen = true;
  finalCombo = bestCombo;
  drawEndScreen();
}

void drawEndScreen() {
  String findMusic = selectedMusic;
    if (findMusic.lastIndexOf('.') != -1) {
      findMusic = findMusic.substring(0, findMusic.lastIndexOf('.'));
    };
  
  updateRecord(findMusic, totalScore, finalCombo);
  
  background(0, 180);
  
  // main box
  fill(255);
  stroke(0);
  strokeWeight(4);
  rect(width / 2 - 500 / 2, height / 2 - 300 / 2, 500, 300, 20);
    
  // Title
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(32);
  text("Tempo terminou!", width / 2, height / 2 - 100);
  
  // Score and best combo
  textSize(24);
  text("Pontuacao: " + totalScore, width / 2, height / 2 - 40);
  text("Melhor combo: " + bestCombo, width / 2, height / 2);
  
  Button goBackButton = new Button(width / 2 - 220, height / 2 + 80, 180, 50, "Voltar");
  Button tryAgainButton = new Button(width / 2 + 40, height / 2 + 80, 180, 50, "Repetir");
  
  goBackButton.draw();
  tryAgainButton.draw();
}

////////////////////////////////////

// FUNCOES KINECT
  
////////////////////////////////////  
    

// Draws the nºi skeleton
void drawSkeleton(SkeletonData _s) {
  // Body
  // A funcao DrawBone recebe o nome de 2 articulações 
  // para desenha uma linha entre estas
  
  DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_HEAD, 
    Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER);
  DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER, 
    Kinect.NUI_SKELETON_POSITION_SHOULDER_LEFT);
  DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER, 
    Kinect.NUI_SKELETON_POSITION_SHOULDER_RIGHT);
  DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER, 
    Kinect.NUI_SKELETON_POSITION_SPINE);
  DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_SHOULDER_LEFT, 
    Kinect.NUI_SKELETON_POSITION_SPINE);
  DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_SHOULDER_RIGHT, 
    Kinect.NUI_SKELETON_POSITION_SPINE);
  DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_SPINE, 
    Kinect.NUI_SKELETON_POSITION_HIP_CENTER);
  DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_HIP_CENTER, 
    Kinect.NUI_SKELETON_POSITION_HIP_LEFT);
  DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_HIP_CENTER, 
    Kinect.NUI_SKELETON_POSITION_HIP_RIGHT);
  DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_HIP_LEFT, 
    Kinect.NUI_SKELETON_POSITION_HIP_RIGHT);

  // Left Arm
  DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_SHOULDER_LEFT, 
    Kinect.NUI_SKELETON_POSITION_ELBOW_LEFT);
  DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_ELBOW_LEFT, 
    Kinect.NUI_SKELETON_POSITION_WRIST_LEFT);
  DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_WRIST_LEFT, 
    Kinect.NUI_SKELETON_POSITION_HAND_LEFT);

  // Right Arm
  DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_SHOULDER_RIGHT, 
    Kinect.NUI_SKELETON_POSITION_ELBOW_RIGHT);
  DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_ELBOW_RIGHT, 
    Kinect.NUI_SKELETON_POSITION_WRIST_RIGHT);
  DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_WRIST_RIGHT, 
    Kinect.NUI_SKELETON_POSITION_HAND_RIGHT);

  // Left Leg
  DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_HIP_LEFT, 
    Kinect.NUI_SKELETON_POSITION_KNEE_LEFT);
  DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_KNEE_LEFT, 
    Kinect.NUI_SKELETON_POSITION_ANKLE_LEFT);
  DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_ANKLE_LEFT, 
    Kinect.NUI_SKELETON_POSITION_FOOT_LEFT);

  // Right Leg
  DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_HIP_RIGHT, 
    Kinect.NUI_SKELETON_POSITION_KNEE_RIGHT);
  DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_KNEE_RIGHT, 
    Kinect.NUI_SKELETON_POSITION_ANKLE_RIGHT);
  DrawBone(_s, 
    Kinect.NUI_SKELETON_POSITION_ANKLE_RIGHT, 
    Kinect.NUI_SKELETON_POSITION_FOOT_RIGHT);
}

  // Draws a line between 2 articulations
void DrawBone(SkeletonData _s, int _j1, int _j2) 
{
  noFill();
  stroke(255, 255, 0);
  if (_s.skeletonPositionTrackingState[_j1] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED &&
    _s.skeletonPositionTrackingState[_j2] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED) {
    line(_s.skeletonPositions[_j1].x*width, 
      _s.skeletonPositions[_j1].y*height, 
      _s.skeletonPositions[_j2].x*width, 
      _s.skeletonPositions[_j2].y*height);
  }
}

// Manage skeletons/bodies identification
void appearEvent(SkeletonData _s) 
{
  if (_s.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) 
  {
    return;
  }
  synchronized(bodies) {
    bodies.add(_s);
  }
}

void disappearEvent(SkeletonData _s) 
{
  synchronized(bodies) {
    for (int i=bodies.size ()-1; i>=0; i--) 
    {
      if (_s.dwTrackingID == bodies.get(i).dwTrackingID) 
      {
        bodies.remove(i);
      }
    }
  }
}

void moveEvent(SkeletonData _b, SkeletonData _a) 
{
  if (_a.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) 
  {
    return;
  }
  synchronized(bodies) {
    for (int i=bodies.size ()-1; i>=0; i--) 
    {
      if (_b.dwTrackingID == bodies.get(i).dwTrackingID) 
      {
        bodies.get(i).copy(_a);
        break;
      }
    }
  }
} 
