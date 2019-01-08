PImage img; //<>// //<>//
boolean running;
int iterations;
String imgString;
int xOffset;
int yOffset;

void setup() {

  // CHOOSE YOUR IMAGE HERE

  imgString = "empire_small.jpg";
  // See the "data" folder for available images, or add your own there.

  img = loadImage(imgString);

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
// SYNTAX:
// maskVecSort(String maskString, int vecX, int vecY, boolean dir)
// maskVecMove(String maskString, int vecX, int vecY)
// maskPolSort(String maskString, PolarCoordinate vec)

// NOTE PolSort behaves weirdly for 0-vectors :)

void draw() {
  background(0);
  image(img, 0, 0);
  if (running) {
    // WRITE YOUR SORTS HERE:
    
    PolarCoordinate cord1 = new PolarCoordinate(0, -0.04);
    PolarCoordinate cord2 = new PolarCoordinate(100, 0.5);
    maskPolSort("00808080", cord1);
    maskPolSort("00080808", cord2);

    /* Fun, never ending:
     iterations++;
     maskVecSort(hex(iterations), 0,-1, true);
     maskVecSort(hex(iterations<<5), 0,1, false);
     maskVecSort(hex(iterations<<11), 0,1, false);
     maskVecSort(hex(iterations<<16), 0,-1, true);
     */

    // Necessary, updates the image
    img.updatePixels();
  }
}

// INPUT HANDLING
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

// Sorts masked color values.
// The vector decides which pixel to compare to when sorting, 
//  so that you can steer the direction of the sorting
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

// A wrapping version of maskVecSort. 
// Since the sorting goes all the way around, it doesn't really bundle the sorted colors anywhere
// The entire image just moves, hence the name
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

// Like maskVecSort, but in polar coordinates
//  This means that you can sort around or towards a point instead of xy
//  This point is defind by xOffset and yOffset
void maskPolSort(String maskString, PolarCoordinate vec) {
  int pixelA;
  int pixelB;

  int mask = unhex(maskString);

  int w = img.width;
  int h = img.height;

  //Go through the image pixel by pixel
  for (int i=0; i<(h*w); i++) {
    // index of A and B in img
    int iA, iB;

    CartesianCoordinate A_c, B_c;
    PolarCoordinate A_p;

    iA = i;

    A_c = IndexToCartesian(iA);
    A_p = CartesianToPolar(A_c);
    PolarCoordinate B_p = A_p.add(vec);
    B_c = PolarToCartesian(B_p);
    
    CartesianCoordinate B_cb = GetCoordinateInBounds_wrap(B_c);

    iB = CartesianToIndex(B_cb);

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
  return result;
}

int GetNewIndex() {
  return int(random(0, 99999999));
  // Files not overwriting each other secured by faith alone
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

int CartesianToIndex(CartesianCoordinate cord) {
  return (cord.y * img.width) + cord.x;
}

CartesianCoordinate IndexToCartesian(int index) {
  CartesianCoordinate result = new CartesianCoordinate();
  result.x = index % img.width;
  result.y = index / img.width;
  return result;
}

// UNUSED COMPARISON FUNCTIONS (For future functionality)

// Is A > B?
boolean maskCompare(int A, int B, String maskString) {
  int mask = unhex(maskString);

  A &= mask;
  B &= mask;

  if (A > B) return true;
  return false;
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
