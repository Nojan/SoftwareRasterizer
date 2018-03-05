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

Float3 Barycentric(const ref Float3 p, const ref Float3 a, const ref Float3 b, const ref Float3 c)
{
    Float3 result;
    Float3 v0 = b - a, v1 = c - a, v2 = p - a;
    float d00 = dot(v0, v0);
    float d01 = dot(v0, v1);
    float d11 = dot(v1, v1);
    float d20 = dot(v2, v0);
    float d21 = dot(v2, v1);
    float denom = d00 * d11 - d01 * d01;
    result.y = (d11 * d20 - d01 * d21) / denom;
    result.z = (d00 * d21 - d01 * d20) / denom;
    result.x = 1.0f - result.y - result.z;
    return result;
}

Float3 project(Float3 point, Matrix4 view, Matrix4 proj, Float4 viewport)
in
{
    assert(point.isValid());
}
out(result)
{
    assert(result.isValid());
}
do
{
    Float4 p = Float4(point);
    p = transform(view, p);
    p = transform(proj, p);
    p.data[] /= p.w;
    p.y = -p.y;
    p *= 0.5f;
    p += 0.5f;
    p.data[0] = p.data[0] * viewport.data[2] + viewport.data[0];
    p.data[1] = p.data[1] * viewport.data[3] + viewport.data[1];
    return Float3(p.x, p.y, p.z);
}

unittest
{  
    const Float3 original = Float3(0.0f, 0.25f, 0.0f);
    const float width = 200.0f;
    const float height = 150.0f;
    const Matrix4 model = lookAt(Float3(0, 0, -1), Float3(0, 0, 0), Float3(0, 1, 0));
    const Matrix4 modelCmp = Matrix4([[-1, 0, 0, 0], [0, 1, 0, 0], [0, 0, -1, 0], [0, 0, -1, 1]]);
    assert(mesh.approxEqual!(Matrix4, Matrix4)(model, modelCmp));
    const float ratio = width / height;
    const Matrix4 projection = perspective(PI_4, ratio, 0.1f, 10.0f);
    const Matrix4 projectionCmp = Matrix4([[1.81066012, 0, 0, 0], [0, 2.41421342, 0, 0], [0, 0, -1.02020204, -1], [0, 0, -0.202020213, 0]]);
    assert(mesh.approxEqual!(Matrix4, Matrix4)(projection, projectionCmp));
    const Float4 viewport = Float4(0, 0, width, height);

    //Float3 projected = project(original, model, projection, viewport);
    //assert(mesh.approxEqual!(Float3, Float3)(projected, Float3(100.000000f, 120.266495f, 0.909090877f)) );
}


struct Raster {
    void Render(const Float3 cameraPosition, ref Surface surface, float[] zbuffer)
    in
    {
        assert(surface.m_data.length == m_width * m_height);
        assert(surface.m_data.length == zbuffer.length);
        assert(cameraPosition.isValid());
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

        const Matrix4 view = lookAt(cameraPosition, Float3(0, 0, 0), Float3(0, 1, 0));
        const float ratio = cast(float)m_width / cast(float)m_height;
        const Matrix4 proj = perspective(PI_4, ratio, 0.1f, 10.0f);
        const Float4 viewport = Float4(0, 0, m_width, m_height);

        Float3[3] triangleWS = [ Float3(0, 0.25f, 0), Float3(-0.25f, -0.25f, 0), Float3(0.25f, -0.25f, 0) ];
        Float3[3] triangle;
        foreach(i; 0..3)
        {
            triangle[i] = project(triangleWS[i], view, proj, viewport);
        }
        foreach(y; 0..m_height)
        {
            foreach(x; 0..m_width)
            {
                Float3 pixel = Float3(x, y, 0);

                immutable Float3 bary = Barycentric(pixel, triangle[0], triangle[1], triangle[2]);
                if(0 <= bary.x && bary.x <= 1 && 0 <= bary.y && bary.y <= 1 && 0 <= bary.z && bary.z <= 1)
                {
                    int blue = cast(int)(bary.y * 255.0f);
                    int green = cast(int)(bary.z * 255.0f) << 8;
                    int red = cast(int)(bary.x * 255.0f) << 16;
                    int color = 0xFF000000 | red | green | blue;
                    surface.SetPixel(x,y,color);
                }
                    
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
