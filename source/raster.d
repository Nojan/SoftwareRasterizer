import loadobj;
import mesh;
import numeric_alias;
import std.stdio;
import std.math;
import std.algorithm.mutation;

struct Surface
{
    @property ulong width() const { return m_width; }
    @property ulong height() const { return m_data.length / m_width; }

    void SetSize(uint w, uint h)
    {
        m_data.length = w*h;
        m_width = w;
    }

    void SetPixel(uint x, uint y, u32 value)
    in
    {
        assert(x <= width);
        assert(y <= height);
    }
    do
    {
        m_data[y * m_width + x] = value;
    }

    u32[] m_data;
    uint m_width = 0;

    invariant
    {
        assert(m_width <= m_data.length);
    }
}

void line(ref Surface surface, int x0, int y0, int x1, int y1) { 
    bool steep = false; 
    if (abs(x0-x1)<abs(y0-y1)) { 
        swap(x0, y0); 
        swap(x1, y1); 
        steep = true; 
    } 
    if (x0>x1) { 
        swap(x0, x1); 
        swap(y0, y1); 
    } 
    int dx = x1-x0; 
    int dy = y1-y0; 
    int derror2 = abs(dy)*2; 
    int error2 = 0; 
    int y = y0; 
    for (int x=x0; x<=x1; x++) { 
        if (steep) { 
            surface.SetPixel(y, x, 0); 
        } else { 
            surface.SetPixel(x, y, 0); 
        } 
        error2 += derror2; 
        if (error2 > dx) { 
            y += (y1>y0?1:-1); 
            error2 -= dx*2; 
        } 
    } 
} 

Float3 barycentricCoord(const ref Float3 p, const ref Float3 v0, const ref Float3 v1, const ref Float3 v2)
{
    Float3 result = Float3(-1, 0, 0);
    Float3 v0v1 = v1 - v0; 
    Float3 v0v2 = v2 - v0; // no need to normalize 
    Float3 N = v0v1.cross(v0v2); // N 
    const float area2 = N.length();

    Float3 C; // vector perpendicular to triangle's plane // edge 0 
    Float3 edge0 = v1 - v0; 
    Float3 vp0 = p - v0; 
    C = edge0.cross(vp0); 
    if (N.dot(C) <= 0.0) 
        return result; // P is on the right side // edge 1 
    Float3 edge1 = v2 - v1; 
    Float3 vp1 = p - v1; 
    C = edge1.cross(vp1); 
    result.y = C.length() / area2; 
    if (N.dot(C) <= 0.0) 
        return result; // P is on the right side // edge 2 
    Float3 edge2 = v0 - v2; 
    Float3 vp2 = p - v2; 
    C = edge2.cross(vp2); 
    result.z = C.length() / area2; 
    if (N.dot(C) <= 0.0) 
        return result; // P is on the right side; 
    result.x = 1;
    return result; // this ray hits the triangle
}

struct Raster {
    void Render(ref Surface surface, float[] zbuffer)
    in
    {
        assert(surface.m_data.length == m_width * m_height);
        assert(surface.m_data.length == zbuffer.length);
    }
    do
    {
        //todo
        foreach(y; 0..m_height)
        {
            int yOffset = m_width*y;
            foreach(x; 0..m_width)
            {
                int pixCoord = x + yOffset;
                surface.m_data[pixCoord] = 0xFFFFFFFF;
            }
        }

        line(surface, 10, 10, 25, 25);
        line(surface, 25, 25, 25, 50);
        line(surface, 25, 50, 50, 50);

        Float3 v1 = Float3(56, 56, 0);
        Float3 v2 = Float3(65, 70, 0);
        Float3 v0 = Float3(60, 90, 0);
        foreach(y; 0..m_height)
        {
            foreach(x; 0..m_width)
            {
                Float3 pixel = Float3(x, y, 0);
                Float3 bary = barycentricCoord(pixel, v0, v1, v2);
                if(0 < bary.x)
                    surface.SetPixel(x,y,0);
            }
        }
    }

    void SetSize(int width, int height)
    in
    {
        assert(0 <= width);
        assert(0 <= height);
    }
    do
    {
        m_width = width;
        m_height = height;
    }

    void SetModel(Mesh mesh)
    {
        m_mesh = mesh;
    }

    int m_width, m_height;
    Mesh m_mesh;
}
