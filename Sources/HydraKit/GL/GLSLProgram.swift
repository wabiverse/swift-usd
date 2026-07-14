/* ----------------------------------------------------------------
 * :: :  O  P  E  N  U  S  D  :                                  ::
 * ----------------------------------------------------------------
 * Licensed under the terms set forth in the LICENSE.txt file, this
 * file is available at https://openusd.org.
 *
 *                   Copyright (C) 2016 Pixar. All Rights Reserved.
 *                              Copyright (C) 2024 Wabi Foundation.
 * ----------------------------------------------------------------
 *  . x x x . o o o . x x x . : : : .    o  x  o    . : : : .
 * ---------------------------------------------------------------- */

#if canImport(OpenGL)
  import OpenGL.CGLCurrent
  import OpenGL.GL

  class GLSLProgram
  {
    var glMajorVersion: Int
    var glMinorVersion: Int

    var useVAO: Bool
    var useSampleAlphaToCoverage: Bool
    var program: GLuint
    var uniformLocations: [GLchar: GLint]

    init()
    {
      // versionString = <version_number><space><vendor_specific_information>
      let versionString = "\(glGetString(GLenum(GL_VERSION)))"
      // <version_number> = <major_number>.<minor_number>[.<release_number>]
      let versionNumberString = versionString.split(separator: " ")[0]
      glMajorVersion = Int(versionNumberString.split(separator: ".")[0]) ?? 0
      glMinorVersion = Int(versionNumberString.split(separator: ".")[1]) ?? 0

      useVAO = glMajorVersion >= 3
      useSampleAlphaToCoverage = glMajorVersion >= 4

      program = glCreateProgram()
      let vertexShader = glCreateShader(GLenum(GL_VERTEX_SHADER))
      let fragmentShader = glCreateShader(GLenum(GL_FRAGMENT_SHADER))

      var VS3 = """
      #version 140
      uniform vec4 rect;
      in vec2 st;
      void main() {
        gl_Position = vec4(rect.x + rect.z*st.x, rect.y + rect.w*st.y, 0, 1); 
      }
      """
      var FS3 = """
      #version 140
      out vec4 fragColor;
      uniform vec4 color;
      void main() { 
        fragColor = color; 
      }
      """

      var VS2 = """
      #version 120
      uniform vec4 rect;
      attribute vec2 st;
      void main() {
        gl_Position = vec4(rect.x + rect.z*st.x, rect.y + rect.w*st.y, 0, 1); 
      }
      """
      var FS2 = """
      #version 120
      uniform vec4 color;
      void main() { 
        gl_FragColor = color; 
      }
      """

      var vsSource: UnsafePointer<GLchar>?
      var fsSource: UnsafePointer<GLchar>?
      // requires OpenGL 3.1 or greater for version 140 shader source
      if (glMajorVersion, glMinorVersion) >= (3, 1)
      {
        vsSource = VS3.withCString { $0 }
        fsSource = FS3.withCString { $0 }
      }
      else
      {
        vsSource = VS2.withCString { $0 }
        fsSource = FS2.withCString { $0 }
      }

      glShaderSource(vertexShader, 1, &vsSource, nil)
      glCompileShader(vertexShader)
      glShaderSource(fragmentShader, 1, &fsSource, nil)
      glCompileShader(fragmentShader)
      glAttachShader(program, vertexShader)
      glAttachShader(program, fragmentShader)
      glLinkProgram(program)

      var ok = GL_FALSE
      glGetProgramiv(program, GLenum(GL_LINK_STATUS), &ok)

      if ok == GL_FALSE
      {
        // print(glGetShaderInfoLog(vertexShader))
        // print(glGetShaderInfoLog(fragmentShader))
        // print(glGetProgramInfoLog(self.program))
        glDeleteShader(vertexShader)
        glDeleteShader(fragmentShader)
        glDeleteProgram(program)
        program = 0
      }

      glDeleteShader(vertexShader)
      glDeleteShader(fragmentShader)

      // TODO: set me.
      let uniformDict = [GLchar: GLint]()

      uniformLocations = [GLchar: GLint]()
      for (k, v) in uniformDict
      {
        var param = k
        uniformLocations[param] = glGetUniformLocation(self.program, &param)
      }
    }

    func uniform4f(param: GLchar, x: GLfloat, y: GLfloat, z: GLfloat, w: GLfloat)
    {
      if let location = uniformLocations[param]
      {
        glUniform4f(location, x, y, z, w)
      }
    }
  }
#endif // canImport(OpenGL)
