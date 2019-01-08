class CartesianCoordinate {
  int x;
  int y;
  
  CartesianCoordinate(int x, int y) {
    this.x = x;
    this.y = y;
  }
  
  CartesianCoordinate() {
  }
  
  public String toString() {
    return "(" + x + ", " + y + ")";
  }
}
