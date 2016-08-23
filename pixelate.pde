
PImage img;
Pixelize pxz;

 
void setup() {
  size(580, 380);
  img = loadImage("CRH_BG_580x390.jpg");
  //img = loadImage("watch.jpg");
  
  pxz = new Pixelize(img);
  pxz.sample();
  background(0);
  smooth();
  noLoop();
}
 
void draw() {
 
  pxz.draw();
  delay(2000);
  pxz.evenColors();
  pxz.draw();
}