import numeric_alias;

struct Surface
{
    ulong width() const @nogc pure @property { return m_width; }
    ulong height() const  @nogc pure @property { return m_data.length / m_width; }

    void SetSize(uint w, uint h)
    {
        m_data.length = w*h;
        m_width = w;
    }

    void SetPixel(uint x, uint y, u32 value) @nogc pure
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
