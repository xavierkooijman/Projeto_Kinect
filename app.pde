import blobDetection.*;
import kinect4WinSDK.*;

Kinect kinect;
BlobDetection myBlobDetection;
PImage depthImg, maskImg;
int blobNumber, biggestBlobNum;
int imgWidth = 640;
int imgHeight = 480;

int nearThreshold = 80;   // on scale 0–255 (closer = brighter)
int farThreshold = 160;   // tweak as needed

float threshold = 0.5;
boolean erodeDilate, boundingBoxes, countours;

void setupCV() {
  smooth();
  
  // Kinect
  kinect = new Kinect(this);
  depthImg = createImage(imgWidth, imgHeight, RGB);
  maskImg = createImage(imgWidth, imgHeight, RGB);
  
  // Blob Detection
  myBlobDetection = new BlobDetection(imgWidth, imgHeight);
  myBlobDetection.setThreshold(threshold);
}

void drawCV() {
  background(127, 0, 0);
  
  // normal image
  image(depthImg, 0, 0, imgWidth, imgHeight);
  
  
  int offsetX, offsetY;
  offsetX = imgWidth;
  offsetY = imgHeight;
  // shows mask
  image(maskImg, offsetX, 0, width, height);
      
  int x1, y1, x2, y2, xCenter, yCenter;
  
  // goes through all the blobs
  for (int i = 0; i < blobNumber; i++) {
    Blob b = myBlobDetection.getBlob(i);
    
    x1 = offsetX + int(b.xMin * imgWidth);
    y1 = offsetY + int (b.yMin * imgHeight);
    x2 = offsetX + int(b.xMax * imgWidth);
    y2 = offsetY + int(b.yMax * imgHeight);

    xCenter = int((x1 + x2) / 2.0);
    yCenter = int((y1 + y2) / 2.0);
    
    // bounding box
    if (boundingBoxes) {
      noFill();
      stroke(255, 0, 0);
      rect(x1, y1, x2, y2);
    }
    
    // draws the blob's center
    noStroke();
    fill(255, 255, 0);
    circle(xCenter, yCenter, 20);
    
    noFill();
    stroke(0, 255, 0);
    strokeWeight(2);
    
    if (countours == true) {
      // get the blob's edges number
      int edgesNum = b.getEdgeNb();
      EdgeVertex vA, vB;
      
      for (int m = 0; m < edgesNum; m++) {
        // get the vertex A from the "m" edge from the "b" blob
        vA = b.getEdgeVertexA(m);
        vB = b.getEdgeVertexB(m);

        // the edges vertex's have values between 0 and 1
        // so we need to multiply them by the imgWidth & imgHeight
        line(offsetX + vA.x * imgWidth, offsetY + vA.y  * imgHeight, offsetX + vB.x  * imgWidth, offsetY + vB.y * imgHeight);
      }
    }
  
  
  }
  
  // Optional: draw a dashed outline like your image
  drawDashedOutline(maskImg, width / (float)imgWidth, height / (float)imgHeight);
}

void updateCV() {
  background(0);

  depthImg = kinect.GetDepth(); // likely returns PImage

  if (depthImg == null) return;

  depthImg.copy(depthImg, 0, 0, depthImg.width, depthImg.height, 0, 0, imgWidth, imgHeight);

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
  
  if (erodeDilate) {
    maskImg.filter(DILATE);
    maskImg.filter(ERODE);
  }
  
  // Optional: smooth the edges
  maskImg.filter(BLUR, 0.2);
  maskImg.filter(THRESHOLD, 0.3);

  // Blob Detection for the maskImg
  myBlobDetection.computeBlobs(maskImg.pixels);
  
  // GET BIGGEST BLOB
  blobNumber = myBlobDetection.getBlobNb();
  biggestBlobNum = -1;
  float biggestArea = -1;
  for (int i = 0; i < blobNumber; i++) {
    Blob b = myBlobDetection.getBlob(i);
    float area = (b.xMax - b.xMin) * (b.yMax - b.yMin);
    if (area > biggestArea) {
      biggestArea = area;
      biggestBlobNum = i;
    }
  }
}

void drawDashedOutline(PImage img, float scaleX, float scaleY) {
  img.loadPixels();
  stroke(255);
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

void GetBiggestBlob() {
  biggestBlobNum = -1;
  rectMode(CORNERS);
  float blobArea, biggestArea = 0;

  // iterates through all blobs
  for (int i = 0; i < blobNumber; i++) {
    Blob b = myBlobDetection.getBlob(i);

    // calculates the blob's area
    blobArea = (b.xMax - b.xMin) * (b.yMax - b.yMin);

    // if the current blob's area is bigger than the biggest one
    if (blobArea > biggestArea) {
      // a new blob is defined
      biggestArea = blobArea;
      biggestBlobNum = i;
    }
  }

}
