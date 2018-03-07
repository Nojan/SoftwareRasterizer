import loadobj;
import mesh;
import surface;
import linearAlgebra;
import numeric_alias;
import std.stdio;
import std.math;
import std.algorithm.mutation;

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

Float3 Barycentric(const ref Float3 p, const ref Float3 a, const ref Float3 b, const ref Float3 c) @nogc pure
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

Float3 project(Float3 point, Matrix4 view, Matrix4 proj, Float4 viewport) @nogc pure
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

struct Raster {
    void Render(const Float3 cameraPosition, ref Surface surface, float[] zbuffer) @nogc pure
    in
    {
        assert(surface.m_data.length == m_width * m_height);
        assert(surface.m_data.length == zbuffer.length);
        assert(cameraPosition.isValid());
    }
    do
    {
        // clear
        foreach(y; 0..m_height)
        {
            immutable int yOffset = m_width*y;
            foreach(x; 0..m_width)
            {
                int pixCoord = x + yOffset;
                surface.m_data[pixCoord] = 0xFFFFFFFF;
                zbuffer[pixCoord] = float.max;
            }
        }

        immutable Matrix4 view = lookAt(cameraPosition, Float3(0, 0, 0), Float3(0, 1, 0));
        immutable float ratio = cast(float)m_width / cast(float)m_height;
        immutable Matrix4 proj = perspective(PI_4, ratio, 0.1f, 10.0f);
        immutable Float4 viewport = Float4(0, 0, m_width, m_height);

        immutable Float3[6] triangleWS = [ Float3(0, 0.25f, 0), Float3(-0.25f, -0.25f, 0), Float3(0.25f, -0.25f, 0), Float3(0, 0.1f, -0.5f), Float3(-0.1f, -0.1f, -0.5f), Float3(0.1f, -0.1f, -0.5f) ];
        Float3[6] triangle;
        foreach(i; 0..triangle.length)
        {
            triangle[i] = project(triangleWS[i], view, proj, viewport);
        }
        foreach(y; 0..m_height)
        {
            foreach(x; 0..m_width)
            {
                immutable Float3 pixel = Float3(x, y, 0);
                for(int idxTriangle = 0; idxTriangle < triangleWS.length; idxTriangle += 3)
                {
                    immutable Float3 bary = Barycentric(pixel, triangle[idxTriangle+0], triangle[idxTriangle+1], triangle[idxTriangle+2]);
                    if(0 <= bary.x && bary.x <= 1 && 0 <= bary.y && bary.y <= 1 && 0 <= bary.z && bary.z <= 1)
                    {
                        immutable float z = bary.x * triangle[idxTriangle+0].z + bary.y * triangle[idxTriangle+1].z + bary.z * triangle[idxTriangle+2].z;
                        if(z < zbuffer[y*m_width+x])
                        {
                            zbuffer[y*m_width+x] = z;
                            immutable int blue = cast(int)(bary.y * 255.0f);
                            immutable int green = cast(int)(bary.z * 255.0f) << 8;
                            immutable int red = cast(int)(bary.x * 255.0f) << 16;
                            immutable int color = 0xFF000000 | red | green | blue;
                            surface.SetPixel(x,y,color);
                        }
                    } 
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
        m_vertices.length = m_mesh.vertices.length;
    }

    int m_width, m_height;
    Mesh m_mesh;
    Float3[] m_vertices;

    invariant
    {
        assert(m_vertices.length == m_mesh.vertices.length);
    }
}
