ArrayList <SkeletonData> bodies;
ArrayList <Circle> circles;
ArrayList <RectDrag> rectangles;
ArrayList <String> difficulties;

SoundFile music;
BeatDetector beatDetect;

int beatInterval = 450;

void setupGame() {
  background(0);
  
  //kinect = new Kinect(this);
  smooth();
  
  // empty array for the skeletons/bodies
  bodies = new ArrayList<SkeletonData>();
  
  circles = new ArrayList<Circle>();
  rectangles = new ArrayList<RectDrag>();
  difficulties = new ArrayList<String>();
  
  
  difficulties.add("Easy");
  difficulties.add("Medium");
  difficulties.add("Hard");
  
  music = new SoundFile(this, "loop00.wav");
  music.loop();
  
  beatDetect = new BeatDetector(this);
  beatDetect.input(music);
  beatDetect.sensitivity(beatInterval);
}

void drawGame() {
  background(0);
  
  // draws the grey scale (rgb) camera for the kinect's depth
  //image(kinect.GetDepth(), 640, 360, 640, 360);
  
  // iterates through all bodies/skeletons that were detected
  //for (int i  = 0; i < bodies.size(); i++){
    
  //  // Draws the nºi skeleton
  //  drawSkeleton(bodies.get(i));
    
  //  // Draws the nºi skeletons position
  //  drawPosition();
  //}
  
  ////////////////////////////////////

  ////////////////////////////////////  
  
  // add a new circle or rectangle if there a beat is detected
  if (beatDetect.isBeat()) {
    if (random(1) < 0.8) {
      circles.add(new Circle(difficulties.get(int(random(difficulties.size())))));
    } else {
      rectangles.add(new RectDrag());
    }
  }
  
  // Draw circles
  for (Circle c : circles) c.drawCircle();
  
  // Draw rectangles
  for (RectDrag r : rectangles) r.drawRect();
  
  // Remove the circles that are no longer showing up
  for (int i = circles.size() - 1; i >= 0; i--) {
    if (!circles.get(i).isShowing) {
      circles.remove(i);
    }
  }
  
  // Remove the rectangles that are no longer showing up
  for (int i = rectangles.size() - 1; i >= 0; i--) {
    if (!rectangles.get(i).isShowing) {
      rectangles.remove(i);
    }
  }
}

// Draws the nºi skeletons position
//void drawPosition() {
//  noStroke();
//  fill(0, 100, 255);
//}

//// Draws the nºi skeleton
//void drawSkeleton(SkeletonData _s) {
//  // Body
//  // A funcao DrawBone recebe o nome de 2 articulações 
//  // para desenha uma linha entre estas
//  DrawBone(_s, 
//    Kinect.NUI_SKELETON_POSITION_HEAD, 
//    Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER);
//  DrawBone(_s, 
//    Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER, 
//    Kinect.NUI_SKELETON_POSITION_SHOULDER_LEFT);
//  DrawBone(_s, 
//    Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER, 
//    Kinect.NUI_SKELETON_POSITION_SHOULDER_RIGHT);
//  DrawBone(_s, 
//    Kinect.NUI_SKELETON_POSITION_SHOULDER_CENTER, 
//    Kinect.NUI_SKELETON_POSITION_SPINE);
//  DrawBone(_s, 
//    Kinect.NUI_SKELETON_POSITION_SHOULDER_LEFT, 
//    Kinect.NUI_SKELETON_POSITION_SPINE);
//  DrawBone(_s, 
//    Kinect.NUI_SKELETON_POSITION_SHOULDER_RIGHT, 
//    Kinect.NUI_SKELETON_POSITION_SPINE);
//  DrawBone(_s, 
//    Kinect.NUI_SKELETON_POSITION_SPINE, 
//    Kinect.NUI_SKELETON_POSITION_HIP_CENTER);
//  DrawBone(_s, 
//    Kinect.NUI_SKELETON_POSITION_HIP_CENTER, 
//    Kinect.NUI_SKELETON_POSITION_HIP_LEFT);
//  DrawBone(_s, 
//    Kinect.NUI_SKELETON_POSITION_HIP_CENTER, 
//    Kinect.NUI_SKELETON_POSITION_HIP_RIGHT);
//  DrawBone(_s, 
//    Kinect.NUI_SKELETON_POSITION_HIP_LEFT, 
//    Kinect.NUI_SKELETON_POSITION_HIP_RIGHT);

//  // Left Arm
//  DrawBone(_s, 
//    Kinect.NUI_SKELETON_POSITION_SHOULDER_LEFT, 
//    Kinect.NUI_SKELETON_POSITION_ELBOW_LEFT);
//  DrawBone(_s, 
//    Kinect.NUI_SKELETON_POSITION_ELBOW_LEFT, 
//    Kinect.NUI_SKELETON_POSITION_WRIST_LEFT);
//  DrawBone(_s, 
//    Kinect.NUI_SKELETON_POSITION_WRIST_LEFT, 
//    Kinect.NUI_SKELETON_POSITION_HAND_LEFT);

//  // Right Arm
//  DrawBone(_s, 
//    Kinect.NUI_SKELETON_POSITION_SHOULDER_RIGHT, 
//    Kinect.NUI_SKELETON_POSITION_ELBOW_RIGHT);
//  DrawBone(_s, 
//    Kinect.NUI_SKELETON_POSITION_ELBOW_RIGHT, 
//    Kinect.NUI_SKELETON_POSITION_WRIST_RIGHT);
//  DrawBone(_s, 
//    Kinect.NUI_SKELETON_POSITION_WRIST_RIGHT, 
//    Kinect.NUI_SKELETON_POSITION_HAND_RIGHT);

//  // Left Leg
//  DrawBone(_s, 
//    Kinect.NUI_SKELETON_POSITION_HIP_LEFT, 
//    Kinect.NUI_SKELETON_POSITION_KNEE_LEFT);
//  DrawBone(_s, 
//    Kinect.NUI_SKELETON_POSITION_KNEE_LEFT, 
//    Kinect.NUI_SKELETON_POSITION_ANKLE_LEFT);
//  DrawBone(_s, 
//    Kinect.NUI_SKELETON_POSITION_ANKLE_LEFT, 
//    Kinect.NUI_SKELETON_POSITION_FOOT_LEFT);

//  // Right Leg
//  DrawBone(_s, 
//    Kinect.NUI_SKELETON_POSITION_HIP_RIGHT, 
//    Kinect.NUI_SKELETON_POSITION_KNEE_RIGHT);
//  DrawBone(_s, 
//    Kinect.NUI_SKELETON_POSITION_KNEE_RIGHT, 
//    Kinect.NUI_SKELETON_POSITION_ANKLE_RIGHT);
//  DrawBone(_s, 
//    Kinect.NUI_SKELETON_POSITION_ANKLE_RIGHT, 
//    Kinect.NUI_SKELETON_POSITION_FOOT_RIGHT);
//}

//  // Draws a line between 2 articulations
//void DrawBone(SkeletonData _s, int _j1, int _j2) 
//{
//  noFill();
//  stroke(255, 255, 0);
//  if (_s.skeletonPositionTrackingState[_j1] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED &&
//    _s.skeletonPositionTrackingState[_j2] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED) {
//    line(_s.skeletonPositions[_j1].x*width, 
//      _s.skeletonPositions[_j1].y*height, 
//      _s.skeletonPositions[_j2].x*width, 
//      _s.skeletonPositions[_j2].y*height);
//  }
//}

//// Manage skeletons/bodies identification
//void appearEvent(SkeletonData _s) 
//{
//  if (_s.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) 
//  {
//    return;
//  }
//  synchronized(bodies) {
//    bodies.add(_s);
//  }
//}

//void disappearEvent(SkeletonData _s) 
//{
//  synchronized(bodies) {
//    for (int i=bodies.size ()-1; i>=0; i--) 
//    {
//      if (_s.dwTrackingID == bodies.get(i).dwTrackingID) 
//      {
//        bodies.remove(i);
//      }
//    }
//  }
//}

//void moveEvent(SkeletonData _b, SkeletonData _a) 
//{
//  if (_a.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) 
//  {
//    return;
//  }
//  synchronized(bodies) {
//    for (int i=bodies.size ()-1; i>=0; i--) 
//    {
//      if (_b.dwTrackingID == bodies.get(i).dwTrackingID) 
//      {
//        bodies.get(i).copy(_a);
//        break;
//      }
//    }
//  }
//} 
