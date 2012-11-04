import processing.video.*;
Movie myMovie;

// static vars
Land[] land = new Land[256];
Person[] person = new Person[4];
int pace = 5;
int counter;

void setup() {
  size(400,400);
  
  // make landscape
    for (int i=0;i<16;i++) {
      for (int j=0;j<16;j++) {
        int rand = int(random(0,3));
        land[counter] = new Land(i*25, j*25, rand);
        counter++;
      }
    }
  
    // make People
          person[0] = new Person(63, 63, 1);
          person[1] = new Person(337, 337, 1);
          person[2] = new Person(337, 63, 1);
          person[3] = new Person(63, 337, 1);
}

void draw() {
// pace control
if (counter % pace == 0) {  
  
 /* LAND LOOP */
 for (int j=0;j<256;j++) {
   land[j].display();
 }
 
 /* PPL LOOP */
 for (int i=0;i<4;i++) {
   if (person[i].alive()) {
   // 1. move
   person[i].move();
   // 2. interact with other ppl
   person[i].others(i);
   // 3. examine food
   person[i].food();
   // 4. display
   person[i].display();
   }
 }

}
// saveFrame(); 
counter++;
}

class Person { 
  float xpos;
  float ypos;
  int currency;

  // 0. Constructor
  Person(float tempxpos, float tempypos, int tempcurrency) { 
    xpos = tempxpos;
    ypos = tempypos;
    currency = 20;
  }

  // 1. move
    void move() {
      
    // figure out square its on
    int square = int(((xpos-13)/25*16)+((ypos-13)/25));
    
    // say goodbye
    land[square].imHere(-1);
    
    // get # of surr squares
    int[] nswe = new int[4];
    nswe[0] = square-1;
    nswe[1] = square+1;
    nswe[2] = square-16;
    nswe[3] = square+16;
    
    // if edge case 
    if (xpos == 13 || xpos == 388 || ypos == 13 || ypos == 388) {
      if (ypos == 13) nswe[0] = square+15;
      if (ypos == 388) nswe[1] = square-15;
      if (xpos == 13) nswe[2] = square+240;
      if (xpos == 388) nswe[3] = square-240;
    }
    
    // declare msg array
    int[] choosefrom = new int[4];
    choosefrom[0] = nswe[0];
    int count = 1;
    
    int[] money = new int[4];
    // get $ of surr squares
    for (int i=0;i<4;i++) {
      money[i] = land[nswe[i]].returnCurrency();
    }

    // figure out what has most $
    for (int i=0;i<3;i++) {
      if (money[i] < money[i+1]) {
        
        // reset choices array 
        choosefrom[0] = nswe[i+1];
        for (int j=1;j<4;j++) 
        {choosefrom[j] = -1;}
        count = 1;
    }
      else if (money[i] == money[i+1]) {
        
        // add to choices array
        choosefrom[count] = nswe[i+1];
        count++;
      }
    }
      
    // choose from random array
    int rand = int(random(0,count));
    int goTo = choosefrom[rand];
    
    // go to sq goTo  
    xpos = land[goTo].xpos + 13;
    ypos = land[goTo].ypos + 13;
  }
  
  // 2. food
  void food() {
    
    // figure out square its on
    int square = int(((xpos-13)/25*16)+((ypos-13)/25));
    
    // get currency
    int addme = land[square].returnCurrency();
    
    // if not empty, eat it
    land[square].eatMe();
    
    // augment own currency
    currency = currency + addme;
  } 

  // 3. others
  void others(int i) {
    
    // figure out square its on
    int square = int(((xpos-13)/25*16)+((ypos-13)/25));
    
    // figure out if other people on it
      if (land[square].personHere > -1) {
        int otherPersonNumber = land[square].anyoneHere();
        int otherPersonCurrency = person[otherPersonNumber].returnCurrency();
        if (otherPersonCurrency > currency) {
          die(); 
          println(i + " gets eaten by "+ otherPersonNumber);
        } 
        else {
          person[otherPersonNumber].die();
          println(i + " eats "+ otherPersonNumber);
          land[square].imHere(i);
        }
      }
      
      // if not, say hi to square
      else land[square].imHere(i);
  } 
    
  // 4. Display
   void display() {
      stroke(128);
      if (currency < 10) fill(255, 0, 0);
      else if (currency >= 10 && currency < 20) fill(255, 255, 0);
      else fill(0, 255, 0);
    ellipseMode(CENTER);
    ellipse(xpos,ypos,currency,currency);
  }
  
  boolean alive() {
   if (currency > 5) return true;
  else return false; 
  }
  
  void die() {
    currency = 0;
  }
  
  //
  int returnCurrency() {
    return currency;
  }
}

class Land { 
  float xpos;
  float ypos;
  int currency;
  int personHere;

  // 0. Constructor
  Land(float tempxpos, float tempypos, int tempcurrency) { 
    xpos = tempxpos;
    ypos = tempypos;
    currency = tempcurrency;
    personHere = -1;
  }

  // 1. Display
   void display() {
     stroke(128);
      if (currency == -1) fill(0);
      else if (currency == 0) fill(180, 240, 51);
      else if (currency == 1) fill(129, 235, 112);
      else fill(27, 67, 21);
    rect(xpos, ypos, 25, 25, 5);
  }
  
  // 2. currency
  int returnCurrency() {
    return currency;
  }
  
  // 3. method for eaten
  void eatMe() {
    if (currency != -1) currency = -1;
  }

  // 4. someone here
  int anyoneHere() {
    return personHere;
  }
  
  // 5. im here
  void imHere(int person) {
    personHere = person;
  }
}
