class Circle{
  color strokeColor;
  float centerX, centerY, lifespan, fadeAlpha, circleFading;
  int radius;
  String difficulty;
  boolean isShowing;
  
  Circle(String difficulty) {
    
    // Decide if a circle will spawn on the right or left side
    if (random(1) < 0.5) {
      centerX = random(100, 500);
    } else {
      centerX = random(880, 1180);
    }
    centerY =random(150, height - 150);
    isShowing = true;
    fadeAlpha = 255;
    
    // Define a circle's color, radius and lifespan based on the difficulty given
    if (difficulty == "Easy") {
      radius = int(random(150, 200));
      lifespan = random(800, 1000);
      strokeColor = color(52, 235, 73);
      circleFading = 1;
      
    } else if (difficulty == "Medium") {
      radius = int(random(100, 150));
      lifespan = random(500, 800);
      strokeColor = color(228, 237, 52);
      circleFading = 2.5;
      
    } else if (difficulty == "Hard") {
      radius = int(random(50, 100));
      lifespan = random(250, 500);
      strokeColor = color(245, 64, 44);
      circleFading = 5;
    }
  } 
  
  void drawCircle() {
    if (isShowing) {
      lifespan -= 2;
      fadeAlpha -= 2;
      
      if (lifespan < 0) {
        isShowing = false;
        return;
      }
    }
    
    // Draw the circle
    noFill();
    stroke(strokeColor, fadeAlpha);
    strokeWeight(3);
    circle(centerX, centerY, radius);
  }
}
