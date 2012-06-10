// Hero person

float CalculateMagnitudeInDirection(Vec2 vector, float angle) {
  return pow(pow(vector.x*cos(angle),2)+ pow(vector.y*sin(angle),2), .5);
}

float c2a (Vec2 v){
  float angle = (atan2(v.y,v.x));
  return angle;
} 


class Hero {

  // We need to keep track of a Body and a width and height
  Body body;

  PImage run_image;

  float w;
  float h;

  Boolean facing_direction = true; // Direction we are facing. right is True

  float max_speed = 20;

  // If we aren't jumping and are on a platform, we can start a jump
  // If we started a jump, we might be able to continue adding force
  // If we finished starting a jump, we are just ballistic
  final static int JUMP_NOT_JUMPING = 0;
  final static int JUMP_STARTING    = 1;
  final static int JUMP_LANDING     = 2;

  float jump_state = 0;


  // We can only rotate once per up press
  Boolean can_rotate = true;

  // Constructor
  Hero(float x_, float y_) {
    float x = x_;
    float y = y_;
    w = 24;
    h = 24;

    // Reset the jump state
    jump_state = 0;

    run_image = loadImage("man_run.png");
    run_image.resize(int(w), int(h));

    // Add the box to the box2d world
    makeBody(new Vec2(x, y), w, h);
    
    body.setUserData(this);
  }

  // This function removes the particle from the box2d world
  void killBody() {
    box2d.destroyBody(body);
  }

  boolean contains(float x, float y) {
    Vec2 worldPoint = box2d.coordPixelsToWorld(x, y);
    Shape s = body.getShapeList();
    boolean inside = s.testPoint(body.getMemberXForm(), worldPoint);
    return inside;
  }

  void update(int direction) {

       
    // We want to apply force in character space, which is rotated by the gravity rotation.
    if ((direction & KEY_RIGHT) > 0) {
      //if (body.getLinearVelocity().x < max_speed) //if we haven't reached the max speed in this direction
      if(CalculateMagnitudeInDirection(body.getLinearVelocity(), gravity_rotation-PI/2) < max_speed) {
        body.applyImpulse(
          new Vec2(-20*cos(gravity_rotation-PI/2),
                   -20*sin(gravity_rotation-PI/2)),
          body.getPosition()
        );
      }
      facing_direction = true;
    }
    if ((direction & KEY_LEFT) > 0) {
      if(CalculateMagnitudeInDirection(body.getLinearVelocity(), gravity_rotation+PI/2) < max_speed) {
        body.applyImpulse(
          new Vec2(20*cos(gravity_rotation-PI/2),
                   20*sin(gravity_rotation-PI/2)),
          body.getPosition()
        );
          }
      facing_direction = false;
    }

    // Effect different behavior here, based on the jump state
    // Note that this is a trashy, framerate-based implementation.
    if (JUMP_NOT_JUMPING == jump_state) {
      if ((direction & KEY_UP) > 0) {
        if(CalculateMagnitudeInDirection(body.getLinearVelocity(), gravity_rotation+PI) < max_speed) {
          body.applyImpulse(
            new Vec2(80*cos(gravity_rotation-PI),
                     80*sin(gravity_rotation-PI)),
            body.getPosition()
          );
        }
          
        // We can jump until we hit max velocity
        jump_state = JUMP_STARTING;
      }
    }
    else if (JUMP_STARTING == jump_state) {
      if ((direction & KEY_UP) > 0) {
        if(CalculateMagnitudeInDirection(body.getLinearVelocity(), gravity_rotation+PI) < max_speed) {
          body.applyImpulse(
            new Vec2(80*cos(gravity_rotation-PI),
                     80*sin(gravity_rotation-PI)),
            body.getPosition()
          );
        }
        else {
          jump_state = JUMP_LANDING;
        }
      }
      else {
        jump_state = JUMP_LANDING;
      }
    }
    else if (JUMP_LANDING == jump_state) {
      // We hit something
      // TODO: check if it was the ground or not.
      // TODO: Walk through all contacts, not just the first.
      if (body.getContactList() != null) {
//        println(body.getContactList().contact);
        jump_state = JUMP_NOT_JUMPING;
      }
    }
  }

  // Drawing the box
  void display() {
    // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(body);

    rectMode(PConstants.CENTER);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate( - PI/2 - gravity_rotation);
    if (facing_direction == false) {
      scale(-1, 1);
    }

    image(run_image, -w/2, -h/2);
    //      fill(8,134,86);
    //      stroke(255);
    //      rect(0,0,w,h);
    popMatrix();
  }

  // This function adds the rectangle to the box2d world
  void makeBody(Vec2 center, float w_, float h_) {
    // Define and create the body
    BodyDef bd = new BodyDef();
    bd.position.set(box2d.coordPixelsToWorld(center));
    bd.fixedRotation = true;
    body = box2d.createBody(bd);

    // Define the shape -- a polygon (this is what we use for a rectangle)
    PolygonDef sd = new PolygonDef();
    float box2dW = box2d.scalarPixelsToWorld(w_/2);
    float box2dH = box2d.scalarPixelsToWorld(h_/2);
    sd.setAsBox(box2dW, box2dH);

    // Parameters that affect physics
    sd.density = 4.0f;
    sd.friction = 0.5f;
    sd.restitution = 0.1f;

    // Attach that shape to our body!
    body.createShape(sd);
    body.setMassFromShapes();
  }
  
  void hitBoundary(Body b) {
    // If we hit something to the right or left of us, then rotate gravity to reflect that.
    
    Vec2 diff = body.getPosition().sub(b.getPosition());

    // magic
    if(CalculateMagnitudeInDirection(diff, gravity_rotation) > 1.8) {
      println("rotating!");
//      println(body.getLinearVelocity().x);
      float velocity_angle = c2a(body.getLinearVelocity());
      println(velocity_angle);
      println(gravity_rotation);
      println(velocity_angle - (gravity_rotation%(2*PI)));
      if ((abs(velocity_angle - gravity_rotation)%(2*PI)) < PI) {
        doRotate(-PI/2);        
      }
      else {
        doRotate(PI/2);
      }
      
      // are we going left or right?
      // left is this:
      //        body.applyImpulse(
      //    new Vec2(20*cos(gravity_rotation-PI/2),
      //             20*sin(gravity_rotation-PI/2)),
      //doRotate(PI/2);
    }
     
//    Vec2 diff = body.getPosition().sub(b.getPosition());
//    if (diff.x > 0 && diff.y < 0) {
//      print("rotating!");
//      println(diff);
//      doRotate(-PI/2);
//    }
//    else if (diff.x > 0 && diff.y < 0) {
//      print("rotating!");
//      println(diff);
//      doRotate(PI/2);
//    }
  }
  
  void doRotate(float rotation) {
    // only support 90 degree rotations and gravity
    gravity_rotation += rotation;
    update_gravity();
  }
}


