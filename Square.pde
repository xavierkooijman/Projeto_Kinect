class Square {
  float squareX, squareY, squareSize, lifespan, fadeAlpha, rotation, margin, holdProgress;
  int score, counter, threshold, frameEffect, framesOutside;
  boolean isShowing, wasHeld, handInside;
  ArrayList<SquareParticle> squareParticles;
  ArrayList<PVector> handTrail;
  color hitColor = color(160, 32, 240);
  float rotationAngle = 0;
  
  Square() {
    margin = sqrt(50*50 + 300*300) / 2;
    
    squareX = random(margin, width - margin);
    squareY = random(margin, height - margin);
    squareSize = random(80, 120);
    rotation = random(-PI/4, PI/4);
    isShowing = true;
    
    handTrail = new ArrayList<PVector>();
    counter = 0;
    threshold = 40;
    wasHeld = false;
    framesOutside = 0;
    holdProgress = 0;
    
    score = 200;
    frameEffect = 0;
    lifespan = random(600, 800);
    fadeAlpha = lifespan;
    squareParticles = new ArrayList<SquareParticle>();
  }
  
  void drawSquare() {
    if (!isShowing && frameEffect <= 0) return;
    
    // update and draw particles
    for (int i = squareParticles.size() - 1; i >= 0; i--) {
      SquareParticle p = squareParticles.get(i);
      if (p.isDead()) squareParticles.remove(i);
      else {
        p.update();
        p.display();
      }
    }
    
    // showing visually that a hand is being detected inside the square
    if (!handTrail.isEmpty() && isShowing) {
      pushMatrix();
      translate(squareX, squareY);
      rotate(rotation);
      
      noFill();
      stroke(0, 0, 255, 128);
      strokeWeight(4);
      rectMode(CENTER);
      rect(0, 0, squareSize, squareSize);
      popMatrix();
      
      PVector last = handTrail.get(handTrail.size()-1);
      fill(0, 255, 255);
      noStroke();
      ellipse(last.x, last.y, 10, 10);
    }
    
    // draw square with new animations
    if (isShowing) {
      rotationAngle += 0.02; // Continuous rotation for decorative elements
      
      pushMatrix();
      translate(squareX, squareY);
      rotate(rotation);
      
      // Pulsating outline effect
      float pulse = sin(frameCount * 0.1) * 5;
      
      // Outer square with pulse
      noFill();
      stroke(hitColor, fadeAlpha * 0.5);
      strokeWeight(2);
      rectMode(CENTER);
      rect(0, 0, squareSize + pulse, squareSize + pulse);
      
      // Rotating decorative dots at corners
      pushMatrix();
      rotate(rotationAngle);
      float cornerOffset = squareSize * 0.35; // Distance from center to corner dots
      for (int i = 0; i < 4; i++) {
        float angle = TWO_PI * i / 4;
        float x = cos(angle) * cornerOffset;
        float y = sin(angle) * cornerOffset;
        fill(hitColor, fadeAlpha);
        noStroke();
        circle(x, y, 5);
      }
      popMatrix();
      
      // Main square
      noFill();
      stroke(hitColor, fadeAlpha);
      strokeWeight(3);
      rect(0, 0, squareSize, squareSize);
      
      popMatrix();
      
      if (!handInside) {
         lifespan -= 2;
         fadeAlpha -= 2; 
      } 
      
      if (lifespan <= 0) {
        isShowing = false;
        combo = 0;
        
        // final particles with more variety
        for (int i = 0; i < 20; i++) {
          squareParticles.add(new SquareParticle(squareX, squareY, hitColor));
        }
      }
      
      drawHoldProgression();
    } else if (frameEffect > 0) {
      holdEffect();
    }
    
  }
  
  void updateGesture(float handX, float handY) {
    if (!isShowing || wasHeld) return;
    
    float margin = 50;
    
    // transform the hand coordinates into a square frame to verify if its inside the square
    PVector squareFrame = new PVector(handX - squareX, handY - squareY);
    squareFrame.rotate(-rotation);
    
    handInside = abs(squareFrame.x) < (squareSize / 2 + margin) && abs(squareFrame.y) < (squareSize / 2 + margin);
   
    // check if the hand's "square frame" is inside the square
    if (handInside) {
      
      framesOutside = 0;
      
      if (squareParticles.size() < 30) squareParticles.add(new SquareParticle(squareX, squareY, hitColor));
   
      handTrail.add(squareFrame);
      
      if (handTrail.size() > 20) handTrail.remove(0);
      isShowing = true;
      
      // create a max distance that the player can hold for
      float maxDistance = 0;
      for (int i = 0; i < handTrail.size(); i++) {
        for (int j = i + 1; j <handTrail.size(); j++) {
          float distance = PVector.dist(handTrail.get(i), handTrail.get(j));
          if (distance > maxDistance) maxDistance = distance;
        }
      }
      
      if (maxDistance < 50) counter++;  
      else counter = 0;
      
      if (counter > threshold) {
        onHold();
        handTrail.clear(); 
        counter = 0;  
      }
     
    } else {
      framesOutside++;
      
      if (framesOutside > 3) {
        if (handTrail.size() > 0) 
          handTrail.clear();
          counter = 0;
      }
    }
      
  }
  
  void onHold() {
    wasHeld = true;
    isShowing = false;
    handInside = false;
    frameEffect = 30;
    
    // create particles
    for (int i = 0; i < 30; i++) {
      squareParticles.add(new SquareParticle(squareX, squareY, hitColor));
    }
    
    // add score
    totalScore += score;
    combo++;
    bestCombo();
  }
  
  void holdEffect() {
    float progress = map(frameEffect, 30, 0, 0, 1);
    float scale = 1 + sin(progress * PI) * 0.5;
    
    pushMatrix();
    translate(squareX, squareY);
    rotate(rotation);
    
    // Expanding outline
    noFill();
    stroke(hitColor, 255 * (1 - progress));
    strokeWeight(3);
    rectMode(CENTER);
    rect(0, 0, squareSize * scale, squareSize * scale);
    
    // Central flash effect
    fill(hitColor, 255 * (1 - progress));
    noStroke();
    rect(0, 0, squareSize * 0.3 * (1 - progress), squareSize * 0.3 * (1 - progress));
    
    // Decorative corner flashes
    float cornerFlashSize = squareSize * 0.15 * (1 - progress);
    float cornerDist = squareSize * 0.35;
    for (int i = 0; i < 4; i++) {
      float angle = TWO_PI * i / 4;
      float x = cos(angle) * cornerDist;
      float y = sin(angle) * cornerDist;
      circle(x, y, cornerFlashSize);
    }
    
    // Score text with better positioning
    pushMatrix();
    rotate(-rotation); // Counter-rotate to keep text readable
    textAlign(CENTER, CENTER);
    textSize(24);
    fill(255, 255 * (1 - progress));
    text("PERFECT!", 0, -squareSize/2);
    
    int scoreTotal = (combo > 0) ? score + combo * 5 : score;
    text("+" + scoreTotal, 0, squareSize/2);
    popMatrix();
    
    popMatrix();
    
    frameEffect--;
    if (frameEffect <= 0) {
      isShowing = false;
    }
  }
  
  void drawHoldProgression() {
    if (!isShowing) return;
    
     // draw a new square next to the square's border to show how much longer the player needs to hold their hand inside the hand 
     holdProgress = map(counter, 0, threshold, 0, 1);
     
     pushMatrix();
     translate(squareX, squareY);
     rotate(rotation);
     
     stroke(255, 105, 180);
     strokeWeight(6);
     noFill();
     rectMode(CENTER);
     
     float perimeter = squareSize * 4;
     
     float borderLength = perimeter * holdProgress;
     
     float leftEdge = -squareSize / 2;
     float rightEdge = squareSize / 2;
     float topEdge = -squareSize / 2;
     float bottomEdge = squareSize / 2;
     
     float timeRemaining = borderLength;
     
     // top edge
     if (timeRemaining > 0) {
      float len = min(timeRemaining, squareSize);
      line(leftEdge, topEdge, leftEdge + len, topEdge);
      timeRemaining -= len;
    }
          
    // right edge 
    if (timeRemaining > 0) {
      float len = min(timeRemaining, squareSize);
      line(rightEdge, topEdge, rightEdge, topEdge + len);
      timeRemaining -= len;
    }
    
    // bottom edge
    if (timeRemaining > 0) {
      float len = min(timeRemaining, squareSize);
      line(rightEdge, bottomEdge, rightEdge - len, bottomEdge);
      timeRemaining -= len;
    }
    
    // left edge
    if (timeRemaining > 0) {
      float len = min(timeRemaining, squareSize);
      line(leftEdge, bottomEdge, leftEdge, bottomEdge - len);
      timeRemaining -= len;
    }
     
     popMatrix();
  }
}


class SquareParticle {
  PVector pos, vel;
  float size, alpha, rotationSpeed, angle;
  color particleColor;
  boolean isSquare;
  
  SquareParticle(float x, float y, color c) {
    pos = new PVector(x, y);
    float speed = random(2, 6);
    float angle = random(TWO_PI);
    vel = new PVector(cos(angle) * speed, sin(angle) * speed);
    size = random(5, 15);
    alpha = 255;
    rotationSpeed = random(-0.2, 0.2);
    angle = random(TWO_PI);
    particleColor = c;
    isSquare = random(1) > 0.5; // Randomly choose between square and circle particles
  }
  
  void update() {
    pos.add(vel);
    vel.mult(0.95); // Add slight deceleration
    alpha *= 0.92;
    angle += rotationSpeed;
    size *= 0.95;
  }
  
  void display() {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(angle);
    
    if (isSquare) {
      rectMode(CENTER);
      noStroke();
      fill(particleColor, alpha);
      rect(0, 0, size, size);
      // Add a subtle glow effect
      noFill();
      stroke(particleColor, alpha * 0.5);
      strokeWeight(2);
      rect(0, 0, size * 1.2, size * 1.2);
    } else {
      noStroke();
      fill(particleColor, alpha);
      circle(0, 0, size);
      // Add a subtle glow effect
      noFill();
      stroke(particleColor, alpha * 0.5);
      strokeWeight(2);
      circle(0, 0, size * 1.2);
    }
    
    popMatrix();
  }
  
  boolean isDead() {
    return alpha < 5;
  }
}
