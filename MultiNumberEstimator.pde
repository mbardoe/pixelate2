class MultiNumberEstimator
{
  FloatList data;
  FloatList estimators;
  IntList nearestEstimators;
  int numberOfEstimators;
  float stepSize=.001;
  FloatList gradient;
  boolean maxSet=false;
  boolean minSet=false;
  float dataMax, dataMin;
  boolean estimateCreated=false;
  float threshold=0.00000005;
  float oldCostFunction=-1.0;
  
  
  
   MultiNumberEstimator(FloatList data, int numEstimators){
     // constructor method
     this.data=data;
     this.estimators= new FloatList();
     this.gradient = new FloatList();
     this.nearestEstimators = new IntList();
     this.numberOfEstimators = numEstimators;
     for (int i=0;i<this.numberOfEstimators; i++)
     {
       //println("here2");
       //println(i);
       this.estimators.append(0.0);
       this.gradient.append(0.0);
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
        println(currentCost);
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
     println("Here3");
     return this.estimators;
   }
   
  void changeEstimate(){
     // assume that the costFunction has been run...
     for (int i=0;i<this.estimators.size();i++){
       // because we want to get smaller we need to subtract...
       this.estimators.sub(i, this.gradient.get(i)*.01);
       if (this.estimators.get(i)<dataMin){
         this.estimators.set(i, dataMin);
       }
       if (this.estimators.get(i)>dataMax){
         this.estimators.set(i, dataMax);
       }
     }
     
  }
  void findNearestEstimator(){
    float currentEstimator;
    int nearest;
    this.resetNearest();
    for (int i=0; i<this.data.size(); i++)
    {
       for (int j = 1; j<this.estimators.size(); j++)
       
       {
        currentEstimator=this.estimators.get(j);
        nearest=this.nearestEstimators.get(i);
        if (abs(this.data.get(i)-this.estimators.get(nearest))> abs(this.data.get(i)-this.estimators.get(j)))
        {
          this.nearestEstimators.set(i,j);
        }
       }
    }
    
  }
   
   float costFunction(){
     float value, datum;
     this.findNearestEstimator();
     // this is the costFunction of the list
     int index=0;
     FloatList answers= new FloatList();
     FloatList gradAnswers= new FloatList();
     for (int i=0; i<this.numberOfEstimators; i++){
       answers.append(0.0);
       gradAnswers.append(0.0);
     }
     
     //for (float value:this.estimators){
     for (int i=0; i<this.estimators.size();i++){
       float answer=0.0;
       float gradAnswer=0.0;
       value=this.estimators.get(i);
       //for(float datum:this.data){
       for(int j=0;j<this.data.size();j++){
         datum=this.data.get(j);
         if (this.nearestEstimators.get(j)==i){
           answer+=sq(value-datum);
           gradAnswer+=sq(value+this.stepSize-datum);
         }
       }
       answers.set(index,answer);
       gradAnswers.set(index,gradAnswer);
       // do I need to worry about floating point issues...
       this.gradient.set(index, (gradAnswer-answer)/stepSize);
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
}
  