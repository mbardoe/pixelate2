class PixMultiNumberEstimator
{
  FloatList data;
  FloatList estimators;
  IntList nearestEstimators;
  int numberOfEstimators;
  float stepSize=.001;
  // going to need 3 gradients for red, green and blue
  FloatList redGradient, greenGradient, blueGradient;
  boolean maxSet=false;
  boolean minSet=false;
  float dataMax, dataMin;
  boolean estimateCreated=false;
  float threshold=4;
  float oldCostFunction=-1.0;
  
  
  
   PixMultiNumberEstimator(FloatList data, int numEstimators){
     // constructor method
     this.data=data;
     this.estimators= new FloatList();
     this.redGradient = new FloatList();
     this.greenGradient = new FloatList();
     this.blueGradient = new FloatList();
     this.nearestEstimators = new IntList();
     this.numberOfEstimators = numEstimators;
     for (int i=0;i<this.numberOfEstimators; i++)
     {
       //println("here2");
       //println(i);
       this.estimators.append(0.0);
       this.redGradient.append(0.0);
       this.greenGradient.append(0.0);
       this.blueGradient.append(0.0);
       this.nearestEstimators.append(0);
     }
     
     this.estimate();
   }
   void resetNearest()
   {
     for (int i=0; i<this.data.size(); i++)
     {
       this.nearestEstimators.set(i,0);
     }
   }
   
   void estimate(){
     float currentCost;
     if (!estimateCreated){
       //create the first estimate
       // determine the max and the min necessary for the random selection
       this.createFirstEstimate();
     }
     // calculate the current cost and the gradient
      currentCost = this.costFunction();
      println("about to start the loop");
      println(this.estimators);
      while ((abs(currentCost-this.oldCostFunction))>this.threshold)
      {
        this.changeEstimate();
        println(this.estimators);
        this.oldCostFunction=currentCost;
        currentCost = this.costFunction();
        println("current cost:"+currentCost);
        println(currentCost-this.oldCostFunction);
      }
      
      println("finished the loop"); 
    
   
   }
   void createFirstEstimate(){
     println("here4");
     println(this.numberOfEstimators);
    // create the first estimate
    // find out if the max is set
    
    if (!maxSet){
      this.setMax(this.data.max());
    }
    if (!minSet){
      this.setMin(this.data.min());
      
    }
    // create the rest of the estimates by randomization....
    // if more than one estimator fill the rest in randomly...
    if (this.numberOfEstimators>2){
      println("here5");
      for (int i=1;i<this.numberOfEstimators-1;i++)
      {
        this.estimators.set(i,random(this.dataMin,this.dataMax));
        println("Hello"+this.estimators.get(i));
      }
    }
    else if (this.numberOfEstimators==2)
    // if only one estimator then it should be a random number.
    {
      this.estimators.set(0,random(this.dataMin, this.dataMax));
    }
    this.estimateCreated=true;
   }
   
   void calculateGradient(){
     this.costFunction(); 
   }
   /* 
   * setMax is a helper function that sets the max of the starting estimates
   */
   void setMax(float newMax)
   {
       this.maxSet=true;
       this.dataMax=newMax;
       this.estimators.set(this.estimators.size()-1,newMax);
   }
   
   /* 
   * setMin is a helper function that sets the min of the starting estimates
   */
   void setMin(float newMin)
   {
       this.minSet=true;
       this.dataMin=newMin;
       this.estimators.set(0,newMin);
   }
   
   /* 
   * estimators returns the current FloatList of estimates
   */
   
   FloatList getEstimators(){
     //println("Here3");
     return this.estimators;
   }
   
  void changeEstimate(){
     // assume that the costFunction has been run...
     int derivative;
     for (int i=0;i<this.estimators.size();i++){
       // because we want to get smaller we need to subtract...
       derivative=createValue(floor(redGradient.get(i)), floor(greenGradient.get(i)), floor(blueGradient.get(i)));
       this.estimators.sub(i, derivative*.05);
       if (this.estimators.get(i)<dataMin){
         this.estimators.set(i, dataMin);
       }
       if (this.estimators.get(i)>dataMax){
         this.estimators.set(i, dataMax);
       }
     }
     
  }
  void findNearestEstimator(){
    
    int nearest;
    this.resetNearest();
    for (int i=0; i<this.data.size(); i++)
    {
       for (int j = 1; j<this.estimators.size(); j++)
       
       {
        nearest=this.nearestEstimators.get(i);
        //if (abs(this.data.get(i)-this.estimators.get(nearest))> abs(this.data.get(i)-this.estimators.get(j)))
        if (colorDistance(this.data.get(i), this.estimators.get(nearest))>colorDistance(this.data.get(i), this.estimators.get(j)))
        {
          this.nearestEstimators.set(i,j);
        }
       }
    }
    
  }
   
   float costFunction(){
     /* must change this to create weighting for the different values of a color. 
     */
     int vred, vgreen, vblue; // the components of a estimate value
     int dred, dgreen, dblue; // the components of a data value
     int redshift =256*256;
     int greenshift =256;
     
     float value, datum;
     this.findNearestEstimator();
     // this is the costFunction of the list
     int index=0;
     // set up places to store total errors. 
     FloatList answers= new FloatList();
     FloatList rgradAnswers= new FloatList();
     FloatList ggradAnswers= new FloatList();
     FloatList bgradAnswers= new FloatList();
     // initialize those.
     for (int i=0; i<this.numberOfEstimators; i++){
       answers.append(0.0);
       rgradAnswers.append(0.0);
       ggradAnswers.append(0.0);
       bgradAnswers.append(0.0);
     }
     
     //for (float value:this.estimators){
     for (int i=0; i<this.estimators.size();i++){
       float answer=0.0;
       float rgradAnswer=0.0;
       float ggradAnswer=0.0;
       float bgradAnswer=0.0;
       value=this.estimators.get(i);
       vred=redPart(floor(value));
       vgreen=greenPart(floor(value));
       vblue=bluePart(floor(value));
       
       //for(float datum:this.data){
       for(int j=0;j<this.data.size();j++){
         datum=this.data.get(j);
         dred=redPart(floor(datum));
         dgreen=greenPart(floor(datum));
         dblue=bluePart(floor(datum));
         if (this.nearestEstimators.get(j)==i){
           //answer+=sq(value-datum);
           answer+=sq(vred-dred)+sq(vgreen-dgreen)+sq(vblue-dblue);
           rgradAnswer+=sq(vred+1-dred);
           ggradAnswer+=sq(vgreen+1-dgreen);
           bgradAnswer+=sq(vblue+1-dblue);
           
           
         }
       }
       answers.set(index,answer);
       rgradAnswers.set(index,rgradAnswer);
       ggradAnswers.set(index,ggradAnswer);
       bgradAnswers.set(index,bgradAnswer);
       // do I need to worry about floating point issues...
       this.redGradient.set(index, (rgradAnswer-answer)/1 );
       this.greenGradient.set(index, (ggradAnswer-answer)/1 );
       this.blueGradient.set(index, (bgradAnswer-answer)/1 );
       index++;
       
       
     }
     
     return answers.sum();
   }
     
   float estimate(float value){
     float currentMinDistance =abs(value-estimators.get(0));
     float currentEstimator=estimators.get(0);
     for (int i=1;i<estimators.size();i++){
       if (abs(value-estimators.get(i))<currentMinDistance){
         currentMinDistance =abs(value-estimators.get(i));
         currentEstimator=estimators.get(i);
       }
     }
     return currentEstimator;
   }
   
   int redPart(int value){
     return value/(256*256);
   }
   int greenPart(int value){
     return (value-redPart(value)*256*256)/256;
   }
   int bluePart(int value){
     return value - redPart(value) - greenPart(value);
   }
   
   int createValue(int red, int green, int blue){
     return 256*256*red+256*green+blue;
   }
   
   float colorDistance(float a, float b){
    int ra, ga, ba, rb, gb, bb;
    ra=redPart(floor(a));
    ga=greenPart(floor(a));
    ba=bluePart(floor(a));
    rb=redPart(floor(b));
    gb=greenPart(floor(b));
    bb=bluePart(floor(b));
    return sq(ra-rb)+sq(ga-gb)+sq(ba-bb);
   }
}
  