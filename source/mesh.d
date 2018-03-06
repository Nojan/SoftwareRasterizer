import linearAlgebra;

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
