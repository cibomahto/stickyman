// Hero person
   import java.lang.reflect.*;
   
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
  float jump_frames = 0;
  float max_jump_frames = 5;

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
    makeBody(new Vec2(x,y),w,h);
  }

  // This function removes the particle from the box2d world
  void killBody() {
    box2d.destroyBody(body);
  }

  boolean contains(float x, float y) {
    Vec2 worldPoint = box2d.coordPixelsToWorld(x, y);
    Shape s = body.getShapeList();
    boolean inside = s.testPoint(body.getMemberXForm(),worldPoint);
    return inside;
  }
  
  void update(int direction) {
    if ((direction & KEY_RIGHT) > 0) {
      if (body.getLinearVelocity().x < max_speed) //if we haven't reached the max speed in this direction
        body.applyImpulse(new Vec2(20,0), body.getPosition());
        facing_direction = true;
    }
    if ((direction & KEY_LEFT) > 0) {
      if (body.getLinearVelocity().x > - max_speed) //if we haven't reached the max speed in this direction
        body.applyImpulse(new Vec2(-20,0), body.getPosition());
        facing_direction = false;
    }
    
    if ((direction & KEY_SPACE) > 0) {
      if (body.getLinearVelocity().y < max_speed) //if we haven't reached the max speed in this direction
        body.applyImpulse(new Vec2(0,80), body.getPosition());
    }
  }

  // Drawing the box
  void display() {
    // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    float a = body.getAngle();

    rectMode(PConstants.CENTER);
    pushMatrix();
      translate(pos.x,pos.y);
      rotate(a);
      if (facing_direction == false) {
        scale(-1,1);
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

}



