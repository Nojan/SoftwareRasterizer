import loadobj;
import mesh;
import numeric_alias;
import std.stdio;

struct Raster {
    void Render(u32[] surface)
    in
    {
        assert(surface.length == m_width * m_height);
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
                if(0 == y % 2)
                    surface[pixCoord] = 0xFFFFFFFF;
                else
                    surface[pixCoord] = 0xFFFF0000;
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
