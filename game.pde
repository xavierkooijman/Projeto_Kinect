ArrayList <SkeletonData> bodies;
ArrayList <Circle> circles;
ArrayList <RectDrag> rectangles;
ArrayList <String> difficulties;

SoundFile music;
BeatDetector beatDetect;

int beatInterval = 500;
int totalScore = 0;

void setupGame() {
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
  difficulties = new ArrayList<String>();
  
  difficulties.add("Easy");
  difficulties.add("Medium");
  difficulties.add("Hard");
  
  // Setup music if not already setup
  if (music == null) {
    music = new SoundFile(this, "data/loop00.wav");
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
        c.onTouched();
        c.wasTouched = true;
        totalScore += c.score;
        break;
      }
    }
    }
  }
  ////////////////////////////////////

  //////////////////////////////////// 
  
  // add a new circle or rectangle if there a beat is detected
  if (beatDetect.isBeat()) {
    if (random(1) < 0.8) {
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
