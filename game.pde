// Remove Kinect-related variable
// ArrayList <SkeletonData> bodies;
ArrayList <Circle> circles;
ArrayList <RectDrag> rectangles;
ArrayList <String> difficulties;

SoundFile music;
BeatDetector beatDetect;

int beatInterval = 500;
int totalScore = 0;
int combo = 0;

void setupGame() {
  background(0);
  
  textAlign(LEFT, TOP);
  textSize(12);
  fill(255);
  stroke(255);
  strokeWeight(1);
  
  smooth();
  
  // Reset all game collections
  circles = new ArrayList<Circle>();
  rectangles = new ArrayList<RectDrag>();
  difficulties = new ArrayList<String>();
  
  difficulties.add("Easy");
  difficulties.add("Medium");
  difficulties.add("Hard");
  
  // Setup music if not already setup and menu is initialized
  if (music == null && menu != null && menu.musicFiles != null && menu.musicFiles.size() > 0) {
    String selectedMusic = menu.musicFiles.get(menu.currentMusicIndex);
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

void drawGame() {
  // Clear screen first
  background(0);
  
  // Salva o estado atual do texto
  pushStyle();
  
  // Remove Kinect skeleton drawing code
  // for (int i = 0; i < bodies.size(); i++) {
  //   drawSkeleton(bodies.get(i));
  //   drawPosition();
  // }

  // Score display com configurações isoladas
  pushStyle();
  textFont(gameFont);
  fill(255);
  textSize(24);
  textAlign(RIGHT, TOP);
  text("Pontuacao: " + totalScore, width - 20, 20);
  text("Combo: " + combo, width - 20, 60);
  popStyle();
  
  // Replace Kinect hand tracking with mouse position
  ArrayList<PVector> hands = new ArrayList<PVector>();
  PVector mouseHand = new PVector(mouseX, mouseY);
  hands.add(mouseHand);
  
  // Check circles with mouse position instead of hands
  for (Circle c : circles) {
    if (!c.wasTouched) {
      for (PVector h : hands) {
        if (PVector.dist(h, new PVector(c.centerX, c.centerY)) < c.radius / 2) {
          combo++;
          c.onTouched();
          c.wasTouched = true;
          totalScore += c.score + combo * 5;
          break;
        }
      }
    }
  }
  
  // Check rectangles with mouse position
  for (RectDrag r : rectangles) {
    for (PVector h : hands) {
      PVector rectCoordinates = new PVector(h.x - r.rectX, h.y - r.rectY);
      
      PVector handCoordinates = new PVector(
        rectCoordinates.x * cos(-r.rotation) - rectCoordinates.y * sin(-r.rotation),
        rectCoordinates.x * sin(-r.rotation) + rectCoordinates.y * cos(-r.rotation)
      );
      
      // Check if mouse is inside rectangle
      if (!r.dragging && abs(handCoordinates.x) <= 35 && abs(handCoordinates.y) <= 150) {
        r.dragging = true;
        r.handTrail.add(new PVector(handCoordinates.x, handCoordinates.y));
      }
      
      // Update trail during drag
      if (r.dragging) {
        r.updateHandTrail(h.x, h.y);
      }
      
      if (r.dragging && (abs(handCoordinates.x) > 35 || abs(handCoordinates.y) > 150)) {
        r.dragging = false;
        
        // Check if drag was in correct direction
        if (!r.wasDragged && r.checkDragDirection()) {
          combo++;
          r.onDragged();
          r.wasDragged = true;
          totalScore += r.score + combo * 5;
        }
      }
    }
  }
  
  // add a new circle or rectangle if there a beat is detected
  if (beatDetect.isBeat()) {
    if (random(1) < 0.35) {
      newCircle();
    } else {
      newRect();
    }
  }
  
  // Draw circles
  for (Circle c : circles) c.drawCircle();
  
  // Draw rectangles
  for (RectDrag r : rectangles) r.drawRect();
  
  // Remove the elements that are no longer showing up
  circles.removeIf(c -> !c.isShowing);
  rectangles.removeIf(r -> !r.isShowing);
  
  popStyle();
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
  float tries = 5;
  
  for (int i = 0; i < tries; i++) {
    RectDrag rect = new RectDrag();
    boolean overlap = true;
    
    // Checks if the new rectangle will overlap a circle
    for (Circle c : circles) {
      if (elementsOverlap(c.centerX, c.centerY, c.radius, rect.rectX, rect.rectY, rectRad)) {
        overlap = false;
        break;
      }
    }
    
    // Checks for other rectangles as well
    if (overlap) {
      for (RectDrag r : rectangles) {
        if (elementsOverlap(r.rectX, r.rectY, rectRad, rect.rectX, rect.rectY, rectRad)) {
          overlap = false;
          break;
        }
      }
    }
    
    if (overlap) {
      rectangles.add(rect);
      break;
    }
  }
}

void newCircle() {
  float rectRad = sqrt(50 * 50 + 300 * 300);
  float tries = 5;
  
  for (int i = 0; i < tries; i++) {
    Circle circle = new Circle(difficulties.get(int(random(difficulties.size()))));
    boolean overlap = true;
    
    // Checks if the new rectangle will overlap a circle
    for (Circle c : circles) {
      if (elementsOverlap(c.centerX, c.centerY, c.radius, circle.centerX, circle.centerY, rectRad)) {
        overlap = false;
        break;
      }
    }
    
    // Checks for other rectangles as well
    if (overlap) {
      for (RectDrag r : rectangles) {
        if (elementsOverlap(r.rectX, r.rectY, rectRad, circle.centerX, circle.centerY, rectRad)) {
          overlap = false;
          break;
        }
      }
    }
    
    if (overlap) {
      circles.add(circle);
      break;
    }
  }
}
