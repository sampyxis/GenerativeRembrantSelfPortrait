/* 

Really happy with the squares now.

Somethings to try:
  Get the intenstiy of the area (pixel) - if it is light, then run the line drawing - smaller lines for more intesnsity.
  For the first 1000 loops, use big squares - to fully cover the image

*/
  
import processing.pdf.*;
import java.util.Calendar;

// GUI
import java.awt.Frame;
import java.awt.BorderLayout;
import controlP5.*;

private ControlP5 cp5;

CheckBox lineBox;
CheckBox smLineBox;
CheckBox curveBox;
CheckBox bigBox;
CheckBox smallCurveBox;
CheckBox smallLineBox;
Slider numOppSlider;

ControlFrame cf;
ImageFrame imageFrame;


boolean savePDF = false;

PImage img;

int x,y;
int curvePointX = 0;
int curvePointY = 0;
int pointCount = 1;
int loopNum = 0;
int numOpp = 100;
int loopNumLine = 0;
int numOppLine = 100;
int numRuns = 10;
float lineWeight = 0;
float diffusion = 50;
int sliderNumOpp=0;
float brightness = 0;

boolean save = false;
boolean pause = false;
boolean drawLines = false;
boolean drawSmLines = false;
boolean drawCurves = false;
boolean bigBoxes = false;
boolean smCurves = false;
boolean smLines = false;

boolean showTint = false;

void setup() {
  
  textSize(32);
  img = loadImage("Rembrant.jpg");
  size(img.width, img.height);
  x = width/2;
  y = height/2;

//  getMaxBrightness();
  setUpImage();
 
 // Control frame
 cp5 = new ControlP5(this);
 cf = addControlFrame("Tools", 250,450);
 
 // Image Frame
 imageFrame = addImageFrame("Original", img.width, img.height);
 
 save = false;
 pause = false;
}

void draw() {
  colorMode(HSB, 360,100,100);    
  smooth();
  noFill();
  
  // Draw the original window
  imageFrame.draw();
  
// The code below doesn't reverse the image - yay!
  int pixelIndex = ( x+ (y*img.width ));
  color c = img.pixels[pixelIndex];
  color(c,random(1,255));
  // The last random function adds more thickness to the line
  lineWeight = hue(c)/(int)random(30,50) * random(1,5);  
  strokeWeight(lineWeight/2);
  
  // Every 100 times - get the opposite color
  if( loopNum == numOpp) {
    loopNum = 0;
    float R = red(c);
    float G = green(c);
    float B = blue(c);
    float minRGB = min(R,min(G,B));
    float maxRGB = max(R,max(G,B));
    float minPlusMax = minRGB + maxRGB;
    color complement = color(minPlusMax-R, minPlusMax-G, minPlusMax-B);
    stroke(complement);
    c = complement;
  } else {
    stroke(c);
    loopNum ++;
  }
  
  // how to draw
  // Default all to true to start
 //  drawLines = true;
//  drawSmLines = true;
//  drawCurves = true;
/*
  if(!pause) {
    if( drawLines ) {
      drawLines();
    }
    if(drawSmLines) {
      drawSmallLines();
    }
    if(drawCurves) {
      drawCurves();
    }
  }
  */
  
  drawSquares(c);
  
  // change the size
  pointCount = (int)random(1,5);
}

float getMaxBrightness() {
  //runs through all the pixels in the image and returns the max brightness
  float maxB = 0.0;
  float brightness = 0.0;
  float average = 0.0;
  loadPixels();
  for (int i = 0; i < pixels.length; i++) {
    color c = img.pixels[i];
    brightness = brightness(c);
    average = average + brightness;
    if (brightness > maxB){
      maxB = brightness;
    }
    
  }
  println("Max Brightness = " + maxB);
  println("Average Brightness = " + (average / pixels.length));
  return maxB;
}

void drawSquares(color c) {
  strokeWeight(random(.1,3));
  fill(c);
  if(bigBoxes){
    rect(x,y, x+random(-width, width), y+random(-height, height));
  } else {
    // Get brightness
    brightness = brightness(c); // 0 black 255 white
    println( brightness);
    if(brightness > 20) { // For this image (Rembrant) the average brightness is 42 - 
      print("Found a brightness: " + brightness);
      // if its bright, use a really small square to get more detail
      // changed - if bright  - do a quick random walk around the bright spot with small rectangles
      rect(x,y, random(-width, width)/brightness, random(-height, height)/brightness);
      println("Color: " + c);
      for(int i=0; i< numRuns; i++){
        x = x + int(random(-10,10));
        y = y + int(random(-10,10));
        if( (x > img.width) || (x < 0)) { x = x + int(random(-10,10)); }
        if( (y > img.height) || (y < 0)) { y = y + int(random(-10,10)); } 
          int pixelIndex = ( x+ (y*img.width ));
          loadPixels();
          if(pixelIndex > pixels.length) { pixelIndex = pixels.length-1;}
          if(pixelIndex < 0) { pixelIndex = 0;}
          println("Pixel length: " + pixels.length);
          println("Pixel Index: " + pixelIndex);
          color newc = img.pixels[pixelIndex];
          color(newc,random(1,255));
          println("Color Now: " + newc);
          stroke(newc);
          fill(newc);
          rect(x, y, random(-width, width)/brightness, random(-height, height)/brightness);
      }
      //drawCurves();
      //drawLines();
      //drawSmallLines();
    } else {    
      rect( x,y, random(-width, width)/16, random(-height, height)/16);
    }
  }
  //rect( x,y, random(-.5,.5), random(-.5,.5));
  x = (int)random(0, width);
  y  = (int)random(0, height);
}

void drawSmallLines(){
  strokeWeight(random(.1,3));
  if (loopNumLine >= numOppLine) {
    if(smLines){
      line(x,y, x+ random(-width, width)/8, y + random(-height, height)/8);
    } else {
      line(x,y, x+ random(-width, width)/2, y + random(-height, height)/2);
    }
    loopNumLine = 0;
  } else {
    line(x, y, x+ random(3,30), y+ random(3,30));
    loopNumLine = loopNumLine + (int)random(-1,5);
    x = (int)random(0, width);
    y  = (int)random(0, height);
  }
}

void drawCurves() {
    // every numOpp times - do a stright line
  if( loopNumLine >= numOppLine ) {
    if(smLines){
      line(x,y, x+ random(-width, width)/8, y + random(-height, height)/8);
    } else {
      line( x, y, x + random(-width,width)/2, y + random(-height,height)/2);
    }
    loopNumLine = 0;
    //printText("Line!!!!!!!!!!!!!!!!!!!!!",10,20);
  } else {
    beginShape();
    curveVertex(x,y);
    curveVertex(x,y);
    for( int i = 0; i<pointCount; i++) {
      if(smCurves) {
        curvePointX = (int)constrain(x+random(-10, 10), 0, width-1);
        curvePointY = (int)constrain(y+random(-10,10),0, height-1);        
      } else {
        curvePointX = (int)constrain(x+random(-50, 50), 0, width-1);
        curvePointY = (int)constrain(y+random(-50,50),0, height-1);
      }
      curveVertex(curvePointX, curvePointY);
    }   
    curveVertex(curvePointX, curvePointY);
    endShape();
    x = curvePointX;
    y = curvePointY;
    loopNumLine = loopNumLine + (int)random(-1,5);
  }
}

void drawLines() {
  if (loopNumLine >= numOppLine) {
    if(smLines){
      line(x,y, x+ random(-width, width)/8, y + random(-height, height)/8);
    } else {
      line(x,y, x+ random(-width, width)/2, y + random(-height, height)/2);
    }
    loopNumLine = 0;
  } else {
    line(x, y, x+ random(1,10), y+ random(1,10));
    loopNumLine = loopNumLine + (int)random(-1,5);
    x = (int)random(0, width);
    y  = (int)random(0, height);
  }
  
}

void printText(String text, int locationX, int locationY) {
  //text(text, locationX, locationY);
  println(text);
}

void keyReleased(){
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
  
  if (key == 'r' || key == 'R'){  
    background(360);
    beginRecord(PDF, timestamp()+".pdf");
  }
  if (key == 'e' || key == 'E'){  
    endRecord();
  }

  if (key == 'q' || key == 'S') noLoop();
  if (key == 'w' || key == 'W') loop();
  
  if (keyCode == UP) pointCount = min(pointCount+1, 30);
  if (keyCode == DOWN) pointCount = max(pointCount-1, 1); 

}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}

void setUpImage(){
  //pushMatrix();
  //scale(-1.0, 1.0);
  //if(showTint){
  //  tint(255,255);
 // }
//  image(img,-img.width,0);
//  image(img,0,0);
  //popMatrix();
}


