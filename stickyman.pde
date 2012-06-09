import pbox2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;

final static int KEY_UP = 1;
final static int KEY_DOWN = 2;
final static int KEY_LEFT = 4;
final static int KEY_RIGHT = 8;
final static int KEY_SPACE = 16;
int player_direction = 0;

// A reference to our box2d world
PBox2D box2d;

// A list we'll use to track fixed objects
ArrayList boundaries;

Hero hero;

void setup() {
  size(640,480);
  smooth();

  // Initialize box2d physics and create the world
  box2d = new PBox2D(this);
  box2d.createWorld();

  // Add a bunch of fixed boundaries
  boundaries = new ArrayList();
  boundaries.add(new Boundary(width/2,height-5,width,10));
  boundaries.add(new Boundary(width/2,5,width,10));
  boundaries.add(new Boundary(width-5,height/2,10,height));
  boundaries.add(new Boundary(5,height/2,10,height));
  
  // Make the box
  hero = new Hero(25,25);
  
}

void draw() {
  background(255);

  // We must always step through time!
  box2d.step();

  pushMatrix();

    // Draw the boundaries
    for (int i = 0; i < boundaries.size(); i++) {
      Boundary wall = (Boundary) boundaries.get(i);
      wall.display();
    }
    
    hero.update(player_direction);
    
    // Draw the box
    hero.display();
  
  popMatrix();

}

void keyPressed(){

  if (key == CODED) {
    switch(keyCode) {
      case(UP):   player_direction |=KEY_UP;   break;
      case(RIGHT):player_direction |=KEY_RIGHT;break;
      case(DOWN): player_direction |=KEY_DOWN; break;
      case(LEFT): player_direction |=KEY_LEFT; break;
    }
  }
  else {
   switch(key) {
     case(' '): player_direction |=KEY_SPACE; break;
   } 
  }
}
 
void keyReleased(){
  if (key == CODED) { 
    switch(keyCode) {
      case(UP):   player_direction ^=KEY_UP;   break;
      case(RIGHT):player_direction ^=KEY_RIGHT;break;
      case(DOWN): player_direction ^=KEY_DOWN; break;
      case(LEFT): player_direction ^=KEY_LEFT; break;
    }
  }
  else {
   switch(key) {
     case(' '): player_direction ^=KEY_SPACE; break;
   } 
  }
}
