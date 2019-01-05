PImage img;
boolean running;
int iterations;
String imgString;
int xOffset;
int yOffset;


// We check for out of bounds in one sense, bot not L-R. This causes assymetry.
void setup() {

  imgString = "image.jpg";
  // fall, image, cover, glacier, nasa

  img = loadImage(imgString);

  // Set the rotational center of polar coordinates relative to the cartesian coordinates.
  int xOffset = img.width / 2;
  int yOffset = img.height / 2;
  println("xOffset: " + xOffset);
  println("yOffset: " + yOffset);

  translate(xOffset, yOffset);

  size(100, 100);
  surface.setResizable(true);
  surface.setSize(img.width, img.height);
  println("width: " + img.width + " Height: " + img.height + " Total: " + img.width*img.height);
  running = false;
  iterations = 1;
}

void draw() {
  background(0);
  image(img, -xOffset, -yOffset); //Corrected for the offset
  if (running) {

    maskPolSort("000000FF", 1, 0);


    //maskVecMove(2,4,"000F0FFF");

    //maskVecSort("0000FFFF", 2, 2, true);
    //maskVecSort("00FFFF00", -2, -2, false);
    //maskVecSort("00FF00FF", -4, -1, false);
    //maskVecSort("00FFFF00", -6, -2, false);
    //maskVecSort("00FF0000", 0, -1);


    //maskVecSort(img.width/2-1,img.height/2-1,"FFFFFFFF");
    //maskVecSort(int(random(-10,10)),int(random(-10,10)),hex(int(random(0,16777215))));
    //maskSort("00FFFF00", false, true);
    //maskVecSort(-2,4,"000000FF");
    //maskVecSort(7,-3,"00FF00FF");

    //This one's cool
    //maskSort("00FFFF00", true, true);
    //maskSort("0000FFFF", false, false);

    //maskSort("00808080", true, false);

    //Straight chromatic abberation
    //maskSort("00FF0000", false, false);
    //maskSort("000000FF", false, true);

    //Weird, never-ending

    /*
    iterations++;
    maskSort(hex(iterations), false, true);
    maskSort(hex(iterations<<5), true, false);
    maskSort(hex(iterations<<11), false, false);
    maskSort(hex(iterations<<16), true, true);
    */

    // Necessary, updates the image
    img.updatePixels();
  }
}

void keyPressed() {

  if (key == ' ') {
    running = !running;
    if (running) println("running");
    else println("stopped");
  } else if (key == 's') {
    int i = GetNewIndex();
    img.save("capture" + i + ".png");
    println("image saved as capture" + i + ".png");
  } else if (key == 'r') {
    img = loadImage(imgString);
  }
}

int GetNewIndex()
{
  return int(random(0, 999999));
}

void maskVecMove(String maskString, int vecX, int vecY) {

  int pixelA;
  int pixelB;

  int mask = unhex(maskString);

  int w = img.width;
  int h = img.height;
  int max = w*h;

  //Go through the image pixel by pixel
  for (int x=0; x<(h*w); x++) {

    //Calculating the second pixel.

    int bval = x + vecX + (vecY*w);
    if (bval < 0) bval += max;
    if (bval >= max) bval %= max;

    pixelA = img.pixels[x];
    pixelB = img.pixels[bval];

    pixelA &= mask;
    pixelB &= mask;

    if (pixelA > pixelB) {
      img.pixels[x] &= ~mask;
      img.pixels[x] |= pixelB;

      img.pixels[bval] &= ~mask;
      img.pixels[bval] |= pixelA;
    }
  }
}

void maskVecSort(String maskString, int vecX, int vecY, boolean dir) {

  int pixelA;
  int pixelB;

  int mask = unhex(maskString);

  int w = img.width;
  int h = img.height;

  //Go through the image pixel by pixel
  for (int i=0; i<(h*w); i++) {

    int iA = dir ? i : (h*w)-i-1;

    int xA = iA % w;
    int yA = iA / w;

    int xB = xA + vecX;
    int yB = yA + vecY;

    if (xB >= w) xB = w-1;
    if (xB < 0) xB = 0;

    if (yB >= h) yB = h-1;
    if (yB < 0) yB = 0;

    int iB = (yB * w) + xB;

    pixelA = img.pixels[iA];
    pixelB = img.pixels[iB];

    pixelA &= mask;
    pixelB &= mask;

    if (pixelA > pixelB) {
      img.pixels[iA] &= ~mask;
      img.pixels[iA] |= pixelB;

      img.pixels[iB] &= ~mask;
      img.pixels[iB] |= pixelA;
    }
  }
}

// What is the unit of aVec? I think it's currently radians.

void maskPolSort(String maskString, int rVec, int aVec) {
  int pixelA;
  int pixelB;

  int mask = unhex(maskString); //<>//

  int w = img.width;
  int h = img.height;

  //Go through the image pixel by pixel
  for (int i=0; i<(h*w); i++) {
    // index of A and B in img
    int iA, iB;

    // Cartesian coordinates of A and B
    int xA, yA, xB, yB;

    // Polar coordinates of A and B
    float rA, aA, rB, aB;

    iA = i;

    // Cartesian coordinate of A
    xA = iA % w;
    yA = iA / w;

    // Polar coordinate of A
    rA = sqrt(xA^2 + yA^2);
    aA = atan2(yA, xA);

    // Add only the radius:
    rB = rA + rVec;
    aB = aA;

    xB = int(rB * cos(aB));
    yB = int(rB * sin(aB));

    //This is to check for OOB

    // Add the angle
    aB = aA + aVec;

    xB = int(rB * cos(aB));
    yB = int(rB * sin(aB));

    //Is there a case where it rotates completely out?
    for (int j=0; j<4; j++) { //If it rotates four times it's just fucked.
      // If out of bounds
      if (xB>w || xB<0 || yB>h || yB<0) {
        if (rVec>0) {
          aB += HALF_PI;
        } else if (rVec<0) {
          aB -= HALF_PI;
        } else {
          println("Your OOB calculation is fucked!");
        }
        xB = int(rB * cos(aB));
        yB = int(rB * sin(aB));
      } else break;
    }

    iB = (yB * w) + xB;

    pixelA = img.pixels[iA];
    pixelB = img.pixels[iB];

    pixelA &= mask;
    pixelB &= mask;

    if (pixelA > pixelB) {
      img.pixels[iA] &= ~mask;
      img.pixels[iA] |= pixelB;

      img.pixels[iB] &= ~mask;
      img.pixels[iB] |= pixelA;
    }
  }
}

//Direction, orientation.
void maskSort(String maskString, boolean dir, boolean or) {

  int pixelA;
  int pixelB;

  int mask = unhex(maskString);

  int w = img.width;
  int h = img.height;

  //Go through the image by columns
  for (int x=0; x<w; x++) {
    //Go through the column
    for (int y= or ? 0 : h-2; or ? y<h-2 : y>0; y += or ? 1 : -1) {

      pixelA = (dir ? img.pixels[w*y+x] : img.pixels[w*(y+1)+x]) & mask;
      pixelB = (dir ? img.pixels[w*(y+1)+x] : img.pixels[w*y+x]) & mask;

      if (pixelA > pixelB) {
        img.pixels[w*y+x] &= ~mask;
        img.pixels[w*(y+1)+x] &= ~mask;
        img.pixels[w*y+x] |= dir ? pixelB : pixelA;
        img.pixels[w*(y+1)+x] |= dir ? pixelA : pixelB;
      }
    }
  }
}

// Is A > B?
boolean maskCompare(int A, int B, String maskString) {
  int mask = unhex(maskString);

  A &= mask;
  B &= mask;

  if(A > B) return true;

  return false;

  // Should i make a int-pair class, and move these function into it?

}

// Does A contain more ones than B?
boolean onesCompare(int A, int B) {

  int onesA = countSetBits(A);
  int onesB = countSetBits(B);

  if (onesA > onesB) return true;

  return false;
}

// Helper function of onesCompare
int countSetBits(int n) {
  if (n == 0) return 0;
  else return 1 + countSetBits(n & (n-1));
}

// Is A brighter than B? (r+g+b)
boolean brightCompare(int A, int B) {

  int redA = (A >> 16) & 0xFF;
  int greenA = (A >> 8) & 0xFF;
  int blueA = (A >> 0) & 0xFF;
  int brightnessA = redA + greenA + blueA;

  int redB = (B >> 16) & 0xFF;
  int greenB = (B >> 8) & 0xFF;
  int blueB = (B >> 0) & 0xFF;
  int brightnessB = redB + greenB + blueB;

  if (brightnessA > brightnessB) return true;

  return false;
}
