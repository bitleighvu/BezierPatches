//BitLeigh Vu
// Sample code for starting the Bezier patches project

int display_option = 1;  // 1 = four corners, 2 = nine quads, 3 = detailed polygons

float time = 0;                 // keep track of passing of time

boolean rotate_flag = true;     // automatic rotation of model?
boolean normal_flag = false;    // use smooth surface normals?  (optional)
boolean color_flag = false;     // random colors?

ArrayList<Patch> patches = new ArrayList<Patch>();

// object-specific translation and scaling
PVector obj_center = new PVector (0,0,0);
float obj_scale = 1.0;

// initialize stuff
void setup() {
  size(750, 750, OPENGL);
}

// Draw the scene
void draw() {
  
  resetMatrix();  // set the transformation matrix to the identity

  background (100, 100, 230);  // clear the screen to sky blue
  
  // set up for perspective projection
  perspective (PI * 0.333, 1.0, 0.01, 1000.0);
  
  // place the camera in the scene
  camera (0.0, 0.0, 5.0, 0.0, 0.0, -1.0, 0.0, 1.0, 0.0);
    
  // create an ambient light source
  ambientLight (102, 102, 102);
  
  // create two directional light sources
  lightSpecular (204, 204, 204);
  directionalLight (102, 102, 102, -0.7, -0.7, -1);
  directionalLight (152, 152, 152, 0, 0, -1);
  
  pushMatrix();

  // set the material color
  fill (200, 200, 200);
  ambient (200, 200, 200);
  specular(0, 0, 0);
  shininess(1.0);
  noStroke();
  
  // rotate based on time
  rotate (time, 0.0, 1.0, 0.0);
  
  translate (0.0, 0.8, 0.0);
  rotate (PI * 0.5, 1.0, 0.0, 0.0);

  // translate and scale on a per-object basis
  scale (obj_scale);
  translate (-obj_center.x, -obj_center.y, -obj_center.z);
  strokeWeight (1.0 / obj_scale);  // make sure lines don't change thickness
  
  // THIS IS WHERE YOU SHOULD DRAW THE PATCHES
  if (display_option == 1) {
    fourCorners();
  } else if (display_option == 2) {
    controlPoints();
  } else if (display_option == 3) {
    detailPoly();
  }
  
  //// placeholder square
  //beginShape();
  //normal (0.0, 0.0, 1.0);
  //vertex (-1.0, -1.0, 0.0);
  //vertex ( 1.0, -1.0, 0.0);
  //vertex ( 1.0,  1.0, 0.0);
  //vertex (-1.0,  1.0, 0.0);
  //endShape(CLOSE);

  popMatrix();
 
  // maybe step forward in time (for object rotation)
  if (rotate_flag)
    time += 0.02;
}

// handle keystroke inputs
void keyPressed() {
  if (key == '1') {
    set_obj_center_and_scale (1, 1.5, 1.5, 0);
    read_patches ("simple.txt");
  }
  else if (key == '2') {
    set_obj_center_and_scale (1.5, 0, 0, -0.75);
    read_patches ("sphere.txt");
  }
  else if (key == '3') {
    set_obj_center_and_scale (0.6, 0, 0, 0);
    read_patches ("teapot.txt");
  }
  else if (key == '4') {
    set_obj_center_and_scale (0.15, 10.0, 7.0, 4.0);
    read_patches ("gumbo.txt");
  }
  else if (key == 'a') {
    // set the display of each patch to an outline of one quad
    display_option = 1;
  }
  else if (key == 's') {
    // set the display of each patch to outlines of nine quads
    display_option = 2;
  }
  else if (key == 'd') {
    // set the display of each patch to be a detailed set of filled polygons (10 x 10 or more)
    display_option = 3;
  }
  else if (key == 'r') {
    // toggle random color here
    color_flag = !color_flag;
  }
  else if (key == 'n') {
    // toggle surface normals (optional)
    normal_flag = !normal_flag;
  }
  else if (key == ' ') {
    // rotate the model?
    rotate_flag = !rotate_flag;
  }
  else if (key == 'q' || key == 'Q') {
    exit();
  }
}

// adjust the size and position of an object when it is drawn
void set_obj_center_and_scale (float sc, float x, float y, float z) {
  obj_scale = sc;
  obj_center = new PVector (x, y, z);
}

// Read Bezier patches from a text file
//
// You should modify this routine to store all of the patch data
// into your data structure instead of printing it to the screen.
void read_patches (String filename) {
  int i,j,k;
  String[] words;
    
  String lines[] = loadStrings(filename);
  
  words = split (lines[0], " ");
  int num_patches = int(words[0]);
  // println ("number of patches = " + num_patches);
  patches = new ArrayList<Patch>(num_patches);
    
  // which line of the file are we reading?
  int count = 1;
  
  // read in the patches
  for (i = 0; i < num_patches; i++) {
    count += 1;  // skip over the lines that say "3 3"
    ArrayList<float[]> patchTemp =  new ArrayList<float[]>();
    
    for (j = 0; j < 4; j++) {
      for (k = 0; k < 4; k++) {
        words = split (lines[count], " ");
        count += 1;
        float x = float(words[0]);
        float y = float(words[1]);
        float z = float(words[2]);
        float[] controlPoint = {x, y, z};
        patchTemp.add(controlPoint);
      }
    }
    patches.add(new Patch(patchTemp));
  }
}

class Patch {
  PVector[][] controlPoints = new PVector[4][4];
  PVector[][] bezPoints = new PVector[11][11];
  PVector colorAssigned = new PVector(random(255), random(255), random(255));
  
  Patch(ArrayList<float[]> patch) {
    controlPoints[0][0] = new PVector(patch.get(0)[0], patch.get(0)[1], patch.get(0)[2]); // 
    controlPoints[0][1] = new PVector(patch.get(1)[0], patch.get(1)[1], patch.get(1)[2]);
    controlPoints[0][2] = new PVector(patch.get(2)[0], patch.get(2)[1], patch.get(2)[2]);
    controlPoints[0][3] = new PVector(patch.get(3)[0], patch.get(3)[1], patch.get(3)[2]); //
    controlPoints[1][0] = new PVector(patch.get(4)[0], patch.get(4)[1], patch.get(4)[2]); 
    controlPoints[1][1] = new PVector(patch.get(5)[0], patch.get(5)[1], patch.get(5)[2]);
    controlPoints[1][2] = new PVector(patch.get(6)[0], patch.get(6)[1], patch.get(6)[2]);
    controlPoints[1][3] = new PVector(patch.get(7)[0], patch.get(7)[1], patch.get(7)[2]); //
    controlPoints[2][0] = new PVector(patch.get(8)[0], patch.get(8)[1], patch.get(8)[2]); 
    controlPoints[2][1] = new PVector(patch.get(9)[0], patch.get(9)[1], patch.get(9)[2]);
    controlPoints[2][2] = new PVector(patch.get(10)[0], patch.get(10)[1], patch.get(10)[2]);
    controlPoints[2][3] = new PVector(patch.get(11)[0], patch.get(11)[1], patch.get(11)[2]); //
    controlPoints[3][0] = new PVector(patch.get(12)[0], patch.get(12)[1], patch.get(12)[2]);
    controlPoints[3][1] = new PVector(patch.get(13)[0], patch.get(13)[1], patch.get(13)[2]);
    controlPoints[3][2] = new PVector(patch.get(14)[0], patch.get(14)[1], patch.get(14)[2]); 
    controlPoints[3][3] = new PVector(patch.get(15)[0], patch.get(15)[1], patch.get(15)[2]); //
    
    // calc bezier patches 
    float t = 0;
    float tIncrement = 0.1;
    PVector[][] tempBez = new PVector[4][11];
    
    for (int i = 0; i < 4; i++) {
      int j = 0;
      while (t <= 1.01) {
        PVector temp = bezCurve(controlPoints[i][0], controlPoints[i][1], controlPoints[i][2], controlPoints[i][3], t);
        tempBez[i][j] = temp;
        t = t + tIncrement;
        j++;
      }
      t = 0;
    }
    
    t = 0;
    PVector[][] tempBez2 = new PVector[11][11];
    for (int i = 0; i < 11; i++) {
      int j = 0; 
      while (t <= 1.01) {
        PVector temp = bezCurve(tempBez[0][i], tempBez[1][i], tempBez[2][i], tempBez[3][i], t);
        tempBez2[i][j] = temp;
        t = t + tIncrement;
        j++;
      }
      t = 0;
    }
    
    bezPoints = tempBez2;
  }
}

void fourCorners() {
  for (Patch p : patches) {
    noFill();
    stroke(255);
    beginShape();
    vertex(p.controlPoints[0][0].x, p.controlPoints[0][0].y, p.controlPoints[0][0].z);
    vertex(p.controlPoints[0][3].x, p.controlPoints[0][3].y, p.controlPoints[0][3].z);
    vertex(p.controlPoints[3][3].x, p.controlPoints[3][3].y, p.controlPoints[3][3].z);
    vertex(p.controlPoints[3][0].x, p.controlPoints[3][0].y, p.controlPoints[3][0].z);
    endShape(CLOSE);
  }
}

void controlPoints() {
  for (Patch p : patches) {
    for (int i = 0; i < 3; i++) {
      int j = i + 1;
      noFill();
      stroke(255);
      beginShape();
      vertex(p.controlPoints[i][0].x, p.controlPoints[i][0].y, p.controlPoints[i][0].z);
      vertex(p.controlPoints[i][1].x, p.controlPoints[i][1].y, p.controlPoints[i][1].z);
      vertex(p.controlPoints[j][1].x, p.controlPoints[j][1].y, p.controlPoints[j][1].z);
      vertex(p.controlPoints[j][0].x, p.controlPoints[j][0].y, p.controlPoints[j][0].z);
      endShape(CLOSE);
      
      noFill();
      stroke(255);
      beginShape();
      vertex(p.controlPoints[i][1].x, p.controlPoints[i][1].y, p.controlPoints[i][1].z);
      vertex(p.controlPoints[i][2].x, p.controlPoints[i][2].y, p.controlPoints[i][2].z);
      vertex(p.controlPoints[j][2].x, p.controlPoints[j][2].y, p.controlPoints[j][2].z);
      vertex(p.controlPoints[j][1].x, p.controlPoints[j][1].y, p.controlPoints[j][1].z);
      endShape(CLOSE);
      
      noFill();
      stroke(255);
      beginShape();
      vertex(p.controlPoints[i][2].x, p.controlPoints[i][2].y, p.controlPoints[i][2].z);
      vertex(p.controlPoints[i][3].x, p.controlPoints[i][3].y, p.controlPoints[i][3].z);
      vertex(p.controlPoints[j][3].x, p.controlPoints[j][3].y, p.controlPoints[j][3].z);
      vertex(p.controlPoints[j][2].x, p.controlPoints[j][2].y, p.controlPoints[j][2].z);
      endShape(CLOSE);
    }
  }
}

PVector bezCurve(PVector c1, PVector c2, PVector c3, PVector c4, float t) {
  PVector point = new PVector(0, 0 ,0);
  
  float p1 = pow(1 - t, 3);
  float p2 = 3 * pow(1 - t, 2) * t;
  float p3 = 3 * (1 - t) * pow(t, 2);
  float p4 = pow(t, 3);
  
  point = PVector.mult(c1, p1).add(PVector.mult(c2, p2)).add(PVector.mult(c3, p3)).add(PVector.mult(c4, p4));
  return point;
}

void detailPoly() {
  for (Patch p : patches) {
    if (color_flag) {
      fill(p.colorAssigned.x, p.colorAssigned.y, p.colorAssigned.z);
    } else {
      fill(200, 200, 200);
    }
    for (int i = 0; i < 10; i++) {
      for (int j = 0; j < 10; j++) {
         beginShape();
         vertex(p.bezPoints[i][j].x, p.bezPoints[i][j].y, p.bezPoints[i][j].z);
         vertex(p.bezPoints[i][j + 1].x, p.bezPoints[i][j + 1].y, p.bezPoints[i][j + 1].z);
         vertex(p.bezPoints[i + 1][j + 1].x, p.bezPoints[i + 1][j + 1].y, p.bezPoints[i + 1][j + 1].z);
         vertex(p.bezPoints[i+ 1][j].x, p.bezPoints[i + 1][j].y, p.bezPoints[i + 1][j].z);
         endShape(CLOSE);
      }
    }
  }
}
