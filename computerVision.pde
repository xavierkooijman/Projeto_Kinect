import kinect4WinSDK.*;

Kinect kinect;
PImage depthImg;
PImage maskImg;

int imgWidth = 640;
int imgHeight = 480;

int nearThreshold = 80;   // on scale 0–255 (closer = brighter)
int farThreshold = 160;   // tweak as needed

void setupCV() {
  size(1280, 720);
  kinect = new Kinect(this);
  depthImg = createImage(imgWidth, imgHeight, RGB);
  maskImg = createImage(imgWidth, imgHeight, RGB);
}

void drawCV() {
  background(0);

  depthImg = kinect.GetDepth(); // likely returns PImage

  if (depthImg == null) return;

  depthImg.loadPixels();
  maskImg.loadPixels();

  // Create binary mask based on depth thresholds
  for (int i = 0; i < depthImg.pixels.length; i++) {
    float b = brightness(depthImg.pixels[i]);

    if (b > nearThreshold && b < farThreshold) {
      maskImg.pixels[i] = color(0); // white for body
    } else {
      maskImg.pixels[i] = color(192);   // black elsewhere
    }
  }

  maskImg.updatePixels();

  // Optional: smooth the edges
  maskImg.filter(BLUR, 0.1);
  maskImg.filter(THRESHOLD, 0.1);

  // Show the silhouette fullscreen
  image(maskImg, 0, 0, width, height);

  // Optional: draw a dashed outline like your image
  drawDashedOutline(maskImg, width / (float)imgWidth, height / (float)imgHeight);
}

void drawDashedOutline(PImage img, float scaleX, float scaleY) {
  img.loadPixels();
  stroke(255, 255, 255);
  strokeWeight(2);
  noFill();

  int step = 10; // controls dash size
  for (int y = 0; y < img.height; y += step) {
    for (int x = 0; x < img.width; x += step) {
      int i = y * img.width + x;
      if (img.pixels[i] == color(255)) {
        if ((x / step + y / step) % 2 == 0) {
          // draw a small dash
          line(x * scaleX, y * scaleY, (x + step / 2) * scaleX, y * scaleY);
        }
      }
    }
  }
}
