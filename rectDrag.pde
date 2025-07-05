class RectDrag {
  float rectX, rectY, lifespan, fadeAlpha, rectFading, rotation, margin;
  boolean isShowing; 
  String direction;
  PImage arrowImg;
  float arrowOffset;
  
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
    arrowOffset = 0;
    
    String[] options = {"left", "right"};
    direction = options[int(random(options.length))];
    arrowImg = loadImage("data/arrow.png");
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
      
      // Define the arrow's direction and rotation
      float baseRotation = HALF_PI; // Rotação base para apontar para cima
      switch(direction) {
        case "right": baseRotation = HALF_PI; break;
        case "left": baseRotation = -HALF_PI; break;
      }
      
      // Suave animação das setas
      arrowOffset += 0.05;
      if (arrowOffset > 15) arrowOffset = 0;
      
      // Posições das setas dentro do retângulo
      float[] arrowPositions = {-120, -60, 0, 60, 120};
      
      // Draw the arrows
      imageMode(CENTER);
      
      for (int i = 0; i < 5; i++) {
        float yPos = arrowPositions[i] + arrowOffset;
        // Fade individual por seta
        float arrowAlpha = fadeAlpha * (1 - abs(yPos/150));
        tint(255, arrowAlpha);
        
        // Tamanho menor para as setas nas extremidades
        float arrowSize = map(abs(yPos), 0, 120, 25, 20);
        
        pushMatrix();
        translate(0, yPos);
        rotate(baseRotation); // Agora as setas apontarão para cima
        image(arrowImg, 0, 0, arrowSize, arrowSize);
        popMatrix();
      }
      
      popMatrix();
    }
  }
  
}