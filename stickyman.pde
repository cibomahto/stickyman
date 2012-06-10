import pbox2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;

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

// our gravity direction
float gravity_rotation = PI*3/2;
float gravity_amount = 40;

// for animation to a new direction
float previous_gravity_rotation = gravity_rotation;


void setup() {
  size(700,700);
  frameRate(60);
  smooth();

  // Initialize box2d physics and create the world
  box2d = new PBox2D(this);
  box2d.createWorld();
  
  box2d.listenForCollisions();

  // Add a bunch of fixed boundaries
  boundaries = new ArrayList();
  boundaries.add(new Boundary(width/2,height-5,width,10));
  boundaries.add(new Boundary(width/2,5,width,10));
  boundaries.add(new Boundary(width-5,height/2,10,height));
  boundaries.add(new Boundary(5,height/2,10,height));

  // inside c
  boundaries.add(new Boundary(150,100,99,10));
  boundaries.add(new Boundary(350,600,509,10));
  boundaries.add(new Boundary(100,350,10,509));
  boundaries.add(new Boundary(600,550,10,99));

  // steps 1
  boundaries.add(new Boundary(250,200,99,10));
  boundaries.add(new Boundary(350,300,99,10));
  boundaries.add(new Boundary(450,400,99,10));
  boundaries.add(new Boundary(550,500,99,10));
  
//  boundaries.add(new Boundary(170,390,150,10));
//  boundaries.add(new Boundary(270,390,150,10));
  
  // Make the box
  hero = new Hero(25,25);
  
  update_gravity();
}

void update_gravity() {
  box2d.setGravity(gravity_amount*cos(gravity_rotation), gravity_amount*sin(gravity_rotation));
}

void draw() {
  background(8,134,86);

  // We must always step through time!
  box2d.step();

  // If we just change rotation, we should animate to it.
  if (gravity_rotation != previous_gravity_rotation) {
    if(previous_gravity_rotation < gravity_rotation) {
      previous_gravity_rotation += PI/20;
    }
    else {
      previous_gravity_rotation -= PI/20;
    }
  }
  if (abs(gravity_rotation - previous_gravity_rotation) < .005) {
    previous_gravity_rotation = gravity_rotation;
  }

  pushMatrix();
    // rotate the screen so it makes sense
    translate(width/2, height/2);
      rotate(previous_gravity_rotation - PI*3/2);
      // and zoom out if we aren't in the center
      scale(1-.15*abs(sin(2*previous_gravity_rotation)));
    translate(-width/2, -height/2);
    
    fill(255);
    rect(width/2,height/2,width,height);

    // Draw the boundaries
    for (int i = 0; i < boundaries.size(); i++) {
      Boundary wall = (Boundary) boundaries.get(i);
      wall.display();
    }
    
    hero.update(player_direction);
    
    // Draw the box
    hero.display();
  
  popMatrix();

//  println(frameRate);
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

// Collision event functions!
void addContact(ContactPoint cp) {
  // Get both shapes
  Shape s1 = cp.shape1;
  Shape s2 = cp.shape2;
  // Get both bodies
  Body b1 = s1.getBody();
  Body b2 = s2.getBody();
  // Get our objects that reference these bodies
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();

  // What class are they?  Box or Particle?
  String c1 = o1.getClass().getName();
  String c2 = o2.getClass().getName();

  // Why does only c2 ever have the hero? we added him last?
  if (c2.contains("Hero")) {
    Hero h = (Hero) o2;
    
      if (c1.contains("Boundary")) {
//        Boundary b = (Boundary) o1;
        h.hitBoundary(b1);
      }
  }
}

// Contacts continue to collide - i.e. resting on each other
void persistContact(ContactPoint cp) {
}

// Objects stop touching each other
void removeContact(ContactPoint cp) {
}

// Contact point is resolved into an add, persist etc
void resultContact(ContactResult cr) {
}
