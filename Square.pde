class Square {
  float squareX, squareY, squareSize, lifespan, fadeAlpha, rotation, margin, holdProgress;
  int score, counter, threshold, frameEffect, framesOutside;
  boolean isShowing, wasHeld, handInside;
  ArrayList<SquareParticle> squareParticles;
  ArrayList<PVector> handTrail;
  color hitColor = color(160, 32, 240);
  
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
    fadeAlpha = 300;
    lifespan = random(600, 800);
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
    
    // draw square
    if (isShowing) {
    pushMatrix();
    translate(squareX, squareY);
    rotate(rotation);
    
    noFill();
    stroke(160, 32, 240, fadeAlpha);
    strokeWeight(2);
    
    rectMode(CENTER);
    rect(0, 0, squareSize, squareSize);
    popMatrix();
    
    if (!handInside) {
       lifespan -= 3;
       fadeAlpha--; 
    } 
   
    
    if (lifespan <= 0) {
      isShowing = false;
      combo = 0;
      
      // final particles
      for (int i = 0; i < 20; i++) {
        squareParticles.add(new SquareParticle(squareX, squareY, color(160, 32, 240)));
      }
    }
    
    drawHoldProgression();
    } else if (frameEffect > 0) {
      holdEffect();
    }
    
  }
  
  void updateGesture(float handX, float handY) {
    if (!isShowing || wasHeld) return;
    
    float margin = 20;
    
    // transform the hand coordinates into a square frame to verify if its inside the square
    PVector squareFrame = new PVector(handX - squareX, handY - squareY);
    squareFrame.rotate(-rotation);
    
    //println("Hand: " + handX + ", " + handY);
    //println("Square @ " + squareX + ", " + squareY + " | halfSize " + squareSize / 2);
    
    handInside = abs(squareFrame.x) < (squareSize / 2 + margin) && abs(squareFrame.y) < (squareSize / 2 + margin);
    
    println("handX: " + handX + ", handY: " + handY);
    //println("handInside? " + handInside);
    //println("handTrail size: " + handTrail.size());
    // check if the hand's "square frame" is inside the square
    if (handInside) {
      //println("Square TOUCHED!");
      
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
      
      println("Counter: " + counter + " | maxDistance: " + maxDistance);
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
        if (handTrail.size() > 0) println("Clearing handTrail due to hand outside area");
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
  }
  
  void holdEffect() {
    float progress = map(frameEffect, 30, 0, 0, 1);
    float scale = 1 + sin(progress * PI) * 0.5;
    
    pushMatrix();
    translate(squareX, squareY);
    noFill();
    stroke(hitColor, 255 * (1 - progress));
    strokeWeight(3);
    rectMode(CENTER);
    rect(0, 0, squareSize * scale, squareSize * scale);
    
    fill(hitColor, 255 * (1 - progress));
    noStroke();
    rect(0, 0, squareSize * 0.3 * (1 - progress), squareSize * 0.3 * (1 - progress));
    
    textAlign(CENTER, CENTER);
    textSize(24);
    fill(255, 255 * (1 - progress));
    text("PERFECT!", 0, -squareSize);
    
    int scoreTotal = (combo > 0) ? score + combo * 5 : score;
    text("+" + scoreTotal, 0, squareSize * 0.3);
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
     
     println("check");
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
  PVector position, velocity;
  color particleColor;
  float lifespan, size;
  
  SquareParticle(float x, float y, color c) {
    position = new PVector(x, y);
    float angle = random(TWO_PI);
    float speed = random(2, 8);
    velocity = new PVector(cos(angle) * speed, sin(angle) * speed);
    
    particleColor = c;
    lifespan = 255;
    size = random(3, 8);
  }
  
  void update() {
    position.add(velocity);
    velocity.mult(0.95);
    lifespan -= 10;
  }
  
  void display() {
    noStroke();
    fill(particleColor, lifespan);
    rect(position.x, position.y, size, size * 4);
  }
  
  boolean isDead() {
    return lifespan < 0;
  }
}
