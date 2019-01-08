class PolarCoordinate {
  float radius;
  float angle;
  
  PolarCoordinate(float radius, float angle) {
    this.radius = radius;
    this.angle = angle;
  }
  
  PolarCoordinate() {
  }

  public String toString() {
    return "(" + radius + ", " + angle + ")";
  }

  PolarCoordinate add(PolarCoordinate that) {
    PolarCoordinate result = new PolarCoordinate();
    result.radius = this.radius + that.radius;
    result.angle += this.angle + that.angle;
    return result;
  }
}
