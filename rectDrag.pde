class RectDrag {
  float rectX, rectY, lifespan, fadeAlpha, rectFading, rotation, margin;
  int frameEffect, score, dragStartIndex, scoreTotal;
  boolean isShowing, dragging, activateEffect, wasDragged; 
  String direction;
  PImage arrowImg;
  
  PVector dragStart;
  float arrowOffset;
  float [] arrowCoorY = new float[5];
  ArrayList<PVector> handTrail = new ArrayList<PVector>();
  
  float ringScale = 1.0;
  ArrayList<RectParticle> rectParticles;
  color hitColor, strokeColor;
  float rotationAngle = 0;
  
  RectDrag() {
    // Make sure the rectangle isn't drawn outside the screen
    margin = sqrt(50*50 + 300*300) / 2;
    
    rectX = random(margin, width - margin);
    rectY = random(margin, height - margin);
    rotation = random(-PI/4, PI/4);
    
    lifespan = random(600, 800);
    rectFading = 1;
    fadeAlpha = lifespan;
    isShowing = true;
    
    wasDragged = false;
    arrowOffset = 0;
    dragStartIndex = -1;
    
    String[] options = {"left", "right"};
    direction = options[int(random(options.length))];
    arrowImg = loadImage("data/arrow.png");
    
    rectParticles = new ArrayList<RectParticle>();
    
    frameEffect = 0;
    activateEffect = false;
    score = 300;
    strokeColor = color(228, 237, 52);
    hitColor = strokeColor;
  }
  
  void drawRect() {
      if (!isShowing) return;
      
      if (!activateEffect) {
        pushMatrix();
        translate(rectX, rectY);
        rotate(rotation);
        
        // pulsating outline
        float pulse = sin(frameCount * 0.1) * 5;
        noFill();
        stroke(strokeColor, fadeAlpha * 0.5);
        strokeWeight(2);
        rectMode(CENTER);
        rect(0, 0, 70 + pulse, 300 + pulse);
        
        // internal rectangle
        noFill();
        stroke(strokeColor, fadeAlpha);
        strokeWeight(3);
        rect( 0, 0, 70, 300);
        popMatrix();
      }
      
      // updates and draws the particles
      for (int i = rectParticles.size() - 1; i >= 0; i--) {
        RectParticle p = rectParticles.get(i);
        if (p.isDead()) rectParticles.remove(i);
        else {
          p.update();
          p.display();
        }
      }
      
      // drag effect
      if (activateEffect) dragEffect();
      
      
      // final fading out
      lifespan -= 2;
      fadeAlpha -= 2;
      if (lifespan <= 0) {
        isShowing = false;
        combo = 0;
        
        // final particles
        for (int i = 0; i < 20; i++) {
          rectParticles.add(new RectParticle(rectX, rectY, strokeColor));
        }
      }
     
      // Color Properties
      noFill();
      stroke(color(228, 237, 52), fadeAlpha);
      strokeWeight(1.5);
      
      // Draw the rectangle with rotation
      pushMatrix();
      translate(rectX, rectY);
      rotate(rotation);
      rectMode(CENTER);
      rect(0, 0, 70, 300);
      
      // Define the arrow's direction and rotation
      float baseRotation = HALF_PI; 
      if (direction.equals("left")) baseRotation = -HALF_PI;
      
      // Suave animação das setas
      arrowOffset += 0.05;
      
      // Posições das setas dentro do retângulo
      float[] arrowPositions = {-120, -60, 0, 60, 120};
      
      // Draw the arrows
      imageMode(CENTER);
      
      for (int i = 0; i < 5; i++) {
        float yPos = arrowPositions[i] + arrowOffset;
        arrowCoorY[i] = yPos;
        
        // Fade individual por seta
        float arrowAlpha = fadeAlpha * (1 - abs(yPos / 150));
        tint(255, arrowAlpha);
        
        // smaller size for the arrows on the sides
        float arrowSize = map(abs(yPos), 0, 120, 40, 30);
        
        pushMatrix();
        translate(0, yPos);
        rotate(baseRotation); // Agora as setas apontarão para cima
        image(arrowImg, 0, 0, arrowSize, arrowSize);
        popMatrix();
      }
      
      popMatrix();
    }
  
  
  void updateHandTrail(float handX, float handY) {
    PVector newTrail = new PVector(handX - rectX, handY - rectY);
    newTrail.rotate(-rotation);
    
    handTrail.add(newTrail);
    
    //limit the array's size
    if (handTrail.size() > 50) handTrail.remove(0);
  }
  
  boolean checkDragDirection() {
    if (handTrail.size() < 10) return false;
    
    if (direction.equals("left")) {
      reverse(arrowCoorY);
    }
    
    int currentIndex = 0;
    
    for (PVector pos : handTrail) {
      
      // if the hand passed by the current arrow
      if (abs(pos.y - arrowCoorY[currentIndex]) < 50) {
        
        // if it did, move on to the next arrow and so on
        currentIndex++;
        if (currentIndex >= arrowCoorY.length) break;
      }
    }
    
    return currentIndex >= arrowCoorY.length;
  }
  
  void onDragged() {
    activateEffect = true;
    frameEffect = 30;
    
    // Explosão de partículas
    for (int i = 0; i < 30; i++) {
      rectParticles.add(new RectParticle(rectX, rectY, hitColor));
    }
  }
  
    
  void dragEffect() {
      float progress = map(frameEffect, 30, 0, 0, 1);
      float scaleX = 1 + sin(progress * PI) * 0.5;
      float scaleY = 1 + sin(progress * PI) * 0.2;
      
      pushMatrix();
      translate(rectX, rectY);
      
      // contour expanding
      noFill();
      stroke(hitColor, 255 * (1 - progress));
      strokeWeight(3);
      rectMode(CENTER);
      rect(0, 0, 70 * scaleX, 300 * scaleY);
      
      // Central flash
      fill(hitColor, 255 * (1 - progress));
      noStroke();
      rect(0, 0, 70 * 0.3 * (1 - progress), 300 * 0.3 * (1 - progress));
      
      textAlign(CENTER, CENTER);
      textSize(24);
      fill(255, 255 * (1-progress));
      text("PERFECT!", 35, -150);
      
      if (combo > 0) scoreTotal = score + combo * 5;
      else scoreTotal = score;
      text("+" + scoreTotal,  0, 50);
      popMatrix();
      
      frameEffect--;
      if (frameEffect <= 0) {
        isShowing = false;
      }
    }
}



class RectParticle {
  PVector position;
  PVector velocity;
  color particleColor;
  float lifespan;
  float size;
  
  RectParticle(float x, float y, color c) {
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
