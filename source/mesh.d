
struct Float2 {
    float[2] data;

    @property float x() const { return data[0]; }
    @property ref float x() { return data[0]; }
    @property float x(float value) { data[0] = value; return value; }

    @property float y() const { return data[1]; }
    @property ref float y() { return data[1]; }
    @property float y(float value) { data[1] = value; return value; }
}

struct Float3 {
    float[3] data;

    @property float x() const { return data[0]; }
    @property ref float x() { return data[0]; }
    @property float x(float value) { data[0] = value; return value; }

    @property float y() const { return data[1]; }
    @property ref float y() { return data[1]; }
    @property float y(float value) { data[1] = value; return value; }

    @property float z() const { return data[2]; }
    @property ref float z() { return data[2]; }
    @property float z(float value) { data[2] = value; return value; }
}

struct Face {
    int[3] vertices;
    int[3] uv;
    int[3] normals;
}

struct Mesh {
    Float3[] vertices;
    Float3[] normals;
    Float2[] uv;
    Face[] face;
}
