class RectDrag{
  float rectX, rectY, lifespan, fadeAlpha, rectFading, rotation, margin;
  boolean isShowing; 
  String direction;
  PImage arrowImg;
  
  
  RectDrag() {
    // Make sure the rectangle isn't drawn outside the screen
    margin = sqrt(50*50 + 300*300) / 2;
    
    rectX = random(margin, width - margin);
    rectY = random(margin, height - margin);
    rotation = random(-PI/4, PI/4);
    
    lifespan = random(800, 1000);
    rectFading = 1;
    fadeAlpha = 255;
    isShowing = true;
    
    String[] options = {"left", "right"};
    direction = options[int(random(options.length))];
    arrowImg = loadImage("arrow.png");
  }
  
  void drawRect() {
    if (isShowing) {
      lifespan -= 2;
      fadeAlpha -= 2;
      
      if (lifespan < 0) {
        isShowing = false;
        return;
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
    rect(0, 0, 50, 300);
    
    // Define the arrow's direction
    float rotationOffset = 0;
    switch(direction) {
      case "right": rotationOffset = HALF_PI; break;
      case "left": rotationOffset = -HALF_PI; break;
    }

    // X positions for the arrows
    float[] arrowX = { -120, -60, 0, 60, 120};

    // Draw the arrows
    pushMatrix();
    rotate(rotationOffset);
    imageMode(CENTER);
    tint(255, fadeAlpha);
    for (int i = 0; i < 5; i++) {
       image(arrowImg, arrowX[i], 0, 30, 30);
    }
    popMatrix(); 

    popMatrix();
    }
  }
}
