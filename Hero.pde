// Hero person
   import java.lang.reflect.*;
   
class Hero {

  // We need to keep track of a Body and a width and height
  Body body;
  float w;
  float h;
  
  float max_speed = 20;

  float jump_frames = 0;
  float max_jump_frames = 5;

  // Constructor
  Hero(float x_, float y_) {
    float x = x_;
    float y = y_;
    w = 24;
    h = 24;
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
    print(direction);
    if ((direction & KEY_RIGHT) > 0) {
      if (body.getLinearVelocity().x < max_speed) //if we haven't reached the max speed in this direction
        body.applyImpulse(new Vec2(10,0), body.getPosition());
    }
    if ((direction & KEY_LEFT) > 0) {
      if (body.getLinearVelocity().x > - max_speed) //if we haven't reached the max speed in this direction
        body.applyImpulse(new Vec2(-10,0), body.getPosition());
    }
    
    if ((direction & KEY_SPACE) > 0) {
      if (body.getLinearVelocity().y < max_speed) //if we haven't reached the max speed in this direction
        body.applyImpulse(new Vec2(0,20), body.getPosition());
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
    fill(175);
    stroke(0);
    rect(0,0,w,h);
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
    sd.friction = 0.3f;
    sd.restitution = 0.5f;

    // Attach that shape to our body!
    body.createShape(sd);
    body.setMassFromShapes();
  }

}



