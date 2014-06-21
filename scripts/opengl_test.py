
from OpenGL.GLUT import *
from OpenGL.GLU import *
from OpenGL.GL import *

import wx
from wx.glcanvas import GLCanvas
from wx import PySimpleApp, Frame, DefaultPosition, Size, PaintDC

class TestCanvas(GLCanvas):
    def __init__(self, parent):
        GLCanvas.__init__(self, parent, -1)
        self.Bind(wx.EVT_PAINT, self.OnPaint)
        self.Bind(wx.EVT_SIZE, self.OnSize)
        self.init = False
        return

    def InitGL(self):
        light_diffuse = [1.0, 1.0, 1.0, 1.0]
        light_position = [1.0, 1.0, 1.0, 0.0]

        glLightfv(GL_LIGHT0, GL_DIFFUSE, light_diffuse)
        glLightfv(GL_LIGHT0, GL_POSITION, light_position)

        glEnable(GL_LIGHTING)
        glEnable(GL_LIGHT0)
        glEnable(GL_DEPTH_TEST)
        glClearColor(0.0, 0.0, 0.0, 1.0)
        glClearDepth(1.0)

        glMatrixMode(GL_PROJECTION)
        glLoadIdentity()
        gluPerspective(40.0, 1.0, 1.0, 30.0)

        glMatrixMode(GL_MODELVIEW)
        glLoadIdentity()
        gluLookAt(0.0, 0.0, 10.0,
                  0.0, 0.0,  0.0,
                  0.0, 1.0,  0.0)
        return

    def OnDraw(self):
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
        glPushMatrix()
        color = [1.0, 0.0, 0.0, 1.0]
        glMaterialfv(GL_FRONT, GL_DIFFUSE, color)
        glutSolidSphere(2, 50, 50)
        glPopMatrix()
        self.SwapBuffers()
        return

    def OnPaint(self, event):
        dc = PaintDC(self)
        self.SetCurrent()
        if not self.init:
            self.InitGL()
            self.init = True
        self.OnDraw()
        return

    def OnSize(self, event):
        size = self.GetClientSize()
        if self.GetContext():
            self.SetCurrent()
            glViewport(0, 0, size.width, size.height)
        event.Skip()

def main():
    glutInit()
    glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_DEPTH)
    app = PySimpleApp()
    frame = Frame(None, -1, 'OpenGL Test', DefaultPosition, Size(400, 400))
    canvas = TestCanvas(frame)
    frame.Show()
    app.MainLoop()


if __name__ == '__main__': main()

