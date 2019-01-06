PImage img; //<>//
boolean running;
int iterations;
String imgString;
int xOffset;
int yOffset;


// We check for out of bounds in one sense, bot not L-R. This causes assymetry.
void setup() {

  imgString = "fall.jpg";
  // fall, image, cover, glacier, nasa

  img = loadImage(imgString);

  // Set the rotational center of polar coordinates relative to the cartesian coordinates.
  xOffset = img.width / 2;
  yOffset = img.height / 2;
  println("xOffset: " + xOffset);
  println("yOffset: " + yOffset);

  size(100, 100);
  surface.setResizable(true);
  surface.setSize(img.width, img.height);
  println("width: " + img.width + " Height: " + img.height + " Total: " + img.width*img.height);
  running = false;
  iterations = 1;
  
  
}

void draw() {
  background(0);
  image(img, 0, 0);
  if (running) {
    // NOTE PolSort behaves weirdly for 0-vectors :)
    
    PolarCoordinate cord = new PolarCoordinate(-3,0.1);
    maskPolSort("0000FFFF", cord);
    maskVecSort("00FFFF00", 3, 1, false);

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

CartesianCoordinate PolarToCartesian(PolarCoordinate cord) {

  CartesianCoordinate result = new CartesianCoordinate();

  result.x = int(cord.radius * cos(cord.angle)) + xOffset;
  result.y = int(cord.radius * sin(cord.angle)) + yOffset;
  return result;
}

PolarCoordinate CartesianToPolar(CartesianCoordinate cord) {
  CartesianCoordinate coordinate = new CartesianCoordinate(cord.x - xOffset, cord.y - yOffset);

  PolarCoordinate result = new PolarCoordinate();
  result.radius = sqrt((coordinate.x*coordinate.x) + (coordinate.y*coordinate.y));
  result.angle = atan2(coordinate.y, coordinate.x);

  //OBS! atan2
  return result;
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

void maskPolSort(String maskString, PolarCoordinate vec) {
  int pixelA;
  int pixelB;

  int mask = unhex(maskString);

  int w = img.width;
  int h = img.height;

  //Go through the image pixel by pixel
  for (int i=0; i<(h*w); i++) {
    // index of A and B in img
    int iA, iB; //<>//
    
    CartesianCoordinate A_c, B_c;
    PolarCoordinate A_p;

    iA = i;

    // Cartesian coordinate of A
    A_c = IndexToCartesian(iA);

    // Polar coordinate of A
    A_p = CartesianToPolar(A_c);

    PolarCoordinate B_p = A_p.add(vec);

    B_c = PolarToCartesian(B_p);

    
    CartesianCoordinate B_cb = GetCoordinateInBounds_wrap(B_c);

    iB = CartesianToIndex(B_cb);

    pixelA = img.pixels[iA];
    //println(B_c);
    //println(B_cb);
    pixelB = img.pixels[iB]; ////
   //img.pixels[iA] = pixelB;
   //img.pixels[iB] = pixelA;
    
   
    pixelA &= mask;
    pixelB &= mask;

    if (pixelA > pixelB) {
      img.pixels[iA] &= ~mask;
      img.pixels[iA] |= pixelB;

      img.pixels[iB] &= ~mask;
      img.pixels[iB] |= pixelA;
    }
    //println("iA, iB: ", iA, ", ", iB);
    
  }
}

// Is A > B?
boolean maskCompare(int A, int B, String maskString) {
  int mask = unhex(maskString);

  A &= mask;
  B &= mask;

  if (A > B) return true;

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

CartesianCoordinate GetCoordinateInBounds_wrap(CartesianCoordinate cord) {
  CartesianCoordinate result = new CartesianCoordinate();
  int xmax = img.width;
  int ymax = img.height;

  result.x = cord.x;
  result.y = cord.y;

  if (result.x < 0) result.x += xmax;
  if (result.x >= xmax) result.x -= xmax;
  
  if (result.y < 0) result.y += ymax;
  if (result.y >= ymax) result.y -= ymax;

  return result;
}

int CartesianToIndex(CartesianCoordinate cord){
  return (cord.y * img.width) + cord.x;
}

CartesianCoordinate IndexToCartesian(int index){
    CartesianCoordinate result = new CartesianCoordinate();
    result.x = index % img.width;
    result.y = index / img.width;
    return result;
}
