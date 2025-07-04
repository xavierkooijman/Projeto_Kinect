class Circle{
  color strokeColor;
  float centerX, centerY, lifespan, fadeAlpha, circleFading;
  int radius, score, frameEffect;
  String difficulty;
  boolean isShowing, activateEffect, wasTouched;
  
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
    wasTouched = false;
    activateEffect = false;
    
    // Define a circle's color, radius and lifespan based on the difficulty given
    if (difficulty == "Easy") {
      radius = int(random(125, 150));
      lifespan = random(800, 1000);
      strokeColor = color(52, 235, 73);
      circleFading = 1;
      score = 50;
      
    } else if (difficulty == "Medium") {
      radius = int(random(75, 125));
      lifespan = random(500, 800);
      strokeColor = color(228, 237, 52);
      circleFading = 2.5;
      score = 100;
      
    } else if (difficulty == "Hard") {
      radius = int(random(25, 75));
      lifespan = random(250, 500);
      strokeColor = color(245, 64, 44);
      circleFading = 5;
      score = 150;
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
    
    if (activateEffect && frameEffect > 0) {
      touchEffect();
      frameEffect--;
      
      if (frameEffect == 0) {
        isShowing = false;
      }
      return;
    }
    
    // Draw the circle
    noFill();
    stroke(strokeColor, fadeAlpha);
    strokeWeight(3);
    circle(centerX, centerY, radius);
  }
  
  void onTouched() {
    activateEffect = true;
    frameEffect = 20;
  }
  
  void touchEffect() {
    float alpha = map(frameEffect, 0, 20, 0, 255);
    stroke(strokeColor, alpha);
    strokeWeight(2);
    int spikes = 12;
    float outer = radius / 2 + 20;
    
    for (int i = 0; i < spikes; i++) {
      float angle = TWO_PI * i / spikes;
      float x1 = centerX + cos(angle) * (radius / 2);
      float y1 = centerY + sin(angle) * (radius / 2); 
      float x2 = centerX + cos(angle) * outer;
      float y2 = centerY + sin(angle) * outer;
      line(x1, y1, x2, y2);

    }
  }
}
