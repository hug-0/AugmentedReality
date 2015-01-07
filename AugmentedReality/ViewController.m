//
//  ViewController.m
//  AugmentedReality
//
//  Created by Hugo Nordell on 7/11/14.
//  Copyright (c) 2014 hugo. All rights reserved.
//

#import "ViewController.h"
//#import "Church_Floored.h"
#import "bohus_small_new.h"
//#import "bohus_small_new.h" // TRIAL
#import <OpenGLES/ES2/glext.h> // NEW FOR iOS8. FIXES OPEN GL ES 2 LINKS

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

GLfloat gCubeVertexData[216] = 
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,          1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    
    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
    
    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,
    
    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
    
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
    
    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
};

@interface ViewController () {
    GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    float _rotation;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    
    // STRING SPECIFICS
    int _numMarkers;
    // info of detected marker
    struct MarkerInfoMatrixBased _markerInfoArray[1];
    // For drawing
    GLKMatrix4 _projectionMatrix;

}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

// STRING SPECIFIC
@property (strong, nonatomic) StringOGL *stringOGL;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context.");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self setupGL];
    
    // String
    self.stringOGL = [[StringOGL alloc] initWithLeftHanded:NO];
    [self.stringOGL setNearPlane:0.1f farPlane:100.0f];
    [self.stringOGL loadMarkerImageFromMainBundle:@"Scanax_Marker_2.png"];
}

- (void)dealloc
{    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    self.effect = [[GLKBaseEffect alloc] init];
//    self.effect.light0.enabled = GL_TRUE;
//    self.effect.light0.position = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
//    self.effect.light0.ambientColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
//    self.effect.lightingType = GLKLightingTypePerPixel;
    
    glEnable(GL_DEPTH_TEST);

//    [self setMatrices];
    
    // Positions
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, bohus_small_newPositions);
    
    // Texels
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, bohus_small_newTexels);
    
    // Normals
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 0, bohus_small_newNormals);
    
//    glGenVertexArraysOES(1, &_vertexArray);
//    glBindVertexArrayOES(_vertexArray);
//
//    glGenBuffers(1, &_vertexBuffer);
//    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
//    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
//    
//    glEnableVertexAttribArray(GLKVertexAttribPosition);
//    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
//    glEnableVertexAttribArray(GLKVertexAttribNormal);
//    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
//    
//    glBindVertexArrayOES(0);
    
//    [self setMatrices];
    // Add textures
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft: @YES};
    NSError *error;
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"iOS_Church.jpg" ofType:nil];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"bohus_small.jpg" ofType:nil];

    GLKTextureInfo *texture = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
    
    if (texture == nil) {
        NSLog(@"Error loading texture %@", [error localizedDescription]);
    }
    
    _effect.texture2d0.name = texture.name;
    _effect.texture2d0.enabled = true;
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    
    self.effect = nil;
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    [self.stringOGL process];
    
    // Draw the model
    [self.stringOGL getProjectionMatrix:_projectionMatrix.m];
    _numMarkers = [self.stringOGL getMarkerInfoMatrixBased:_markerInfoArray maxMarkerCount:1];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [self.stringOGL render];
    
//    glBindVertexArrayOES(_vertexArray);
    
    _effect.transform.projectionMatrix = _projectionMatrix;
    
    for (int i = 0; i < _numMarkers; i++) {
        _modelViewProjectionMatrix = GLKMatrix4MakeWithArray(_markerInfoArray[i].transform);
        _modelViewProjectionMatrix = GLKMatrix4Scale(_modelViewProjectionMatrix, 0.1f, 0.1f, 0.1f); // 0.6 0.6 0.6 SCALE TEST CHURCH BOHUS
        _modelViewProjectionMatrix = GLKMatrix4RotateX(_modelViewProjectionMatrix, GLKMathDegreesToRadians(270.0f));
        _modelViewProjectionMatrix = GLKMatrix4RotateY(_modelViewProjectionMatrix, GLKMathDegreesToRadians(0.0f));
        _modelViewProjectionMatrix = GLKMatrix4Translate(_modelViewProjectionMatrix, 0.0f, 0.0f, 0.0f);
        _effect.transform.modelviewMatrix = _modelViewProjectionMatrix;
        
        float diffuse[4] = {0,0,0,1};
        diffuse[_markerInfoArray[i].imageID % 3] = 1;
//        _effect.light0.diffuseColor = GLKVector4MakeWithArray(diffuse);
        
        // Materials - And render model
        for (int j = 0; j < bohus_small_newMaterials; j++) {
            // Get materials
            self.effect.material.diffuseColor = GLKVector4Make(bohus_small_newKDs[j][0], bohus_small_newKDs[j][1], bohus_small_newKDs[j][2], 1.0f);
            self.effect.material.specularColor = GLKVector4Make(bohus_small_newKSs[j][0], bohus_small_newKSs[j][1], bohus_small_newKSs[j][2], 1.0f);
            
            // Prepare effect
            [_effect prepareToDraw];
            
            // Draw vertices
            glDrawArrays(GL_TRIANGLES, bohus_small_newFirsts[j], bohus_small_newCounts[j]);
        }
//        [_effect prepareToDraw];
//        glDrawArrays(GL_TRIANGLES, 0, 36);
    }
}

- (void)setMatrices {
    // Projection matrix
    const GLfloat aspectRatio = (GLfloat)(self.view.bounds.size.width) / (GLfloat)(self.view.bounds.size.height);
    const GLfloat fieldView = GLKMathDegreesToRadians(90.0f);
    const GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(fieldView, aspectRatio, 0.1f, 10.0f);
    self.effect.transform.projectionMatrix = _projectionMatrix;
    
    // ModelView Matrix
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0.0f, -0.0f, -20.0f);
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, 0.1f, 0.1f, 0.1f); // 0.1 0.1 0.1 Church
    modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, GLKMathDegreesToRadians(90.0f));
    //    modelViewMatrix = GLKMatrix4RotateZ(modelViewMatrix, GLKMathDegreesToRadians(_rotate));
    self.effect.transform.modelviewMatrix = _modelViewProjectionMatrix;
}


@end
