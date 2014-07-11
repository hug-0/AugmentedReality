//
//  Shader.fsh
//  AugmentedReality
//
//  Created by Hugo Nordell on 7/11/14.
//  Copyright (c) 2014 hugo. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
