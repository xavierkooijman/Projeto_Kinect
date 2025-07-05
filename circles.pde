class Circle{
  color strokeColor;
  float centerX, centerY, lifespan, fadeAlpha, circleFading;
  int radius, score, frameEffect;
  String difficulty;
  boolean isShowing, activateEffect, wasTouched;

  float ringScale = 1.0;
  ArrayList<Particle> particles;
  color hitColor;
  boolean perfectHit;
  float rotationAngle = 0;
  
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

    particles = new ArrayList<Particle>();
    perfectHit = false;
    
    // Define a circle's color, radius and lifespan based on the difficulty given
    if (difficulty == "Easy") {
      radius = int(random(125, 150));
      lifespan = random(800, 1000);
      strokeColor = color(52, 235, 73);
      circleFading = 1;
      score = 50;
      hitColor = color(52, 235, 73);
      
    } else if (difficulty == "Medium") {
      radius = int(random(75, 125));
      lifespan = random(500, 800);
      strokeColor = color(228, 237, 52);
      circleFading = 2.5;
      score = 100;
      hitColor = color(228, 237, 52);
      
    } else if (difficulty == "Hard") {
      radius = int(random(25, 75));
      lifespan = random(250, 500);
      strokeColor = color(245, 64, 44);
      circleFading = 5;
      score = 150;
      hitColor = color(245, 64, 44);
    }
  } 
  
void drawCircle() {
    if (isShowing) {
      if (!activateEffect) {
        rotationAngle += 0.02;
        
        // Círculo principal
        pushMatrix();
        translate(centerX, centerY);
        rotate(rotationAngle);
        
        // Efeito de pulso
        float pulse = sin(frameCount * 0.1) * 5;
        
        // Círculo externo com rotação
        noFill();
        stroke(strokeColor, fadeAlpha * 0.5);
        strokeWeight(2);
        circle(0, 0, radius + pulse);
        
        // Pontos decorativos rotacionando
        for (int i = 0; i < 8; i++) {
          float angle = TWO_PI * i / 8;
          float x = cos(angle) * (radius/2);
          float y = sin(angle) * (radius/2);
          fill(strokeColor, fadeAlpha);
          noStroke();
          circle(x, y, 5);
        }
        
        // Círculo interno
        noFill();
        stroke(strokeColor, fadeAlpha);
        strokeWeight(3);
        circle(0, 0, radius);
        popMatrix();
      }
      
      // Atualiza partículas
      for (int i = particles.size()-1; i >= 0; i--) {
        Particle p = particles.get(i);
        if (p.isDead()) {
          particles.remove(i);
        } else {
          p.update();
          p.display();
        }
      }
      
      if (activateEffect) {
        touchEffect();
      }
      
      lifespan -= 2;
      fadeAlpha -= 2;
      
      if (lifespan < 0) {
        isShowing = false;
        // Efeito de desaparecimento
        for (int i = 0; i < 20; i++) {
          particles.add(new Particle(centerX, centerY, strokeColor));
        }
      }
    }
  }
  
  void onTouched() {
    activateEffect = true;
    frameEffect = 30;
    perfectHit = true;
    
    // Explosão de partículas
    for (int i = 0; i < 30; i++) {
      particles.add(new Particle(centerX, centerY, hitColor));
    }
  }
  
void touchEffect() {
    float progress = map(frameEffect, 30, 0, 0, 1);
    float scale = 1 + sin(progress * PI) * 0.5;
    
    pushMatrix();
    translate(centerX, centerY);
    
    // Anel expandindo
    noFill();
    stroke(hitColor, 255 * (1-progress));
    strokeWeight(3);
    circle(0, 0, radius * scale);
    
    // Flash central
    fill(hitColor, 255 * (1-progress));
    noStroke();
    circle(0, 0, radius * 0.3 * (1-progress));
    
    if (perfectHit) {
      textAlign(CENTER, CENTER);
      textSize(24);
      fill(255, 255 * (1-progress));
      text("PERFECT!", 0, -radius/2);
      text("+" + score, 0, radius/2);
    }
    
    popMatrix();
    
    frameEffect--;
    if (frameEffect <= 0) {
      isShowing = false;
    }
  }
}

class Particle {
  PVector position;
  PVector velocity;
  color particleColor;
  float lifespan;
  float size;
  
  Particle(float x, float y, color c) {
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
    circle(position.x, position.y, size);
  }
  
  boolean isDead() {
    return lifespan < 0;
  }
}