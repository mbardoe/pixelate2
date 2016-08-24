class Pixelize {
  PImage img;
  int rectWidth =30;
  int rectHeight =30;
  int pixWidth, pixHeight;
  int numRows=10;
  int numCols=10;
  FloatList reds, greens, blues, totalColor;
  PixMultiNumberEstimator est;

  Pixelize(PImage image) {
    this.img=image;
  }
  void setDimensions(int rectWidth, int rectHeight) {

    this.rectWidth=rectWidth;
    this.rectHeight=rectHeight;
  }

  void sample() {
    int curRed=0;
    int curGreen=0;
    int curBlue=0;
    //load pixels
    loadPixels();


    // find dimensions
    int  loc;

    pixWidth=this.img.width;
    pixHeight=this.img.height;
    // find the number of rect

    // create new FloatLists.... for red 
    reds=new FloatList(numRows*numCols);
    greens = new FloatList(numRows*numCols);
    blues = new FloatList(numRows*numCols);
    numRows = pixHeight/rectHeight;
    numCols = pixWidth/rectWidth;
    for (int y=0; y<numRows; y++) {
      for (int x=0; x<numCols; x++) {
        curRed=0;
        curGreen=0;
        curBlue=0;
        for (int curY=y*rectHeight; curY<(y+1)*rectHeight; curY++) {
          for (int curX=x*rectWidth; curX<(x+1)*rectWidth; curX++) {
            loc = curX + curY*img.width;
            curRed+=red(img.pixels[loc]);
            curGreen+=green(img.pixels[loc]);
            curBlue+=blue(img.pixels[loc]);
          }
        }
        curRed/=rectWidth*rectHeight;
        curGreen/=rectWidth*rectHeight;
        curBlue/=rectWidth*rectHeight;
        println(curRed, curGreen, curBlue);
        reds.set(x+numCols*y, curRed);
        greens.set(x+numCols*y, curGreen);
        blues.set(x+numCols*y, curBlue);
      }
    }
  }

  void draw() {
    int numRows, numCols;
    numRows = pixHeight/rectHeight;
    numCols = pixWidth/rectWidth;
    for (int y=0; y<numRows; y++) {
      for (int x=0; x<numCols; x++) {
        fill(reds.get(x+numCols*y), greens.get(x+numCols*y), blues.get(x+numCols*y));
        rect(x*rectWidth, y*rectHeight, rectWidth, rectHeight);
      }
    }
  }
  
  void evenColors(){
    int ered, egreen, eblue;
    int redshift=256*256;
    int greenshift=256;
   // create a FloatList of colors in the picture
   totalColor = new FloatList(numRows*numCols);
   for (int i=0; i<numRows*numCols; i++){
     totalColor.set(i,redshift*reds.get(i)+greenshift*greens.get(i)+blues.get(i));
   }
   println("Starting estimating colors");
   est= new PixMultiNumberEstimator(totalColor,12);
   est.estimate();
   println("Done estimating the colors");
   // now replace 
   for (float estimate:est.getEstimators()){
     int newEst=floor(estimate);
     ered=newEst/redshift;
     egreen=(floor(estimate)-ered*redshift)/greenshift;
     eblue=floor(estimate)-ered*redshift-egreen*greenshift;
     print("Red: ", ered);
     print("Green: ", egreen);
     println("Blue: ", eblue);
   }
     
   for (int i=0; i<numRows*numCols; i++){
     totalColor.set(i,floor(est.estimate(totalColor.get(i))));
     reds.set(i,floor(totalColor.get(i))/redshift);
     greens.set(i,floor(floor(totalColor.get(i))-reds.get(i)*redshift)/greenshift);
     blues.set(i,floor(totalColor.get(i))-reds.get(i)*redshift-greens.get(i)*greenshift);
     println(reds.get(i),greens.get(i),blues.get(i));
   }
   
   
  }
}