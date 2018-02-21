import std.math;

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

    this(float x, float y, float z)
    {
        data[0] = x;
        data[1] = y;
        data[2] = z;
    }

    @property float x() const { return data[0]; }
    @property ref float x() { return data[0]; }
    @property float x(float value) { data[0] = value; return value; }

    @property float y() const { return data[1]; }
    @property ref float y() { return data[1]; }
    @property float y(float value) { data[1] = value; return value; }

    @property float z() const { return data[2]; }
    @property ref float z() { return data[2]; }
    @property float z(float value) { data[2] = value; return value; }

    Float3 opBinary(string op)(const Float3 rhs) const
    {
        static assert (op == "+" || op == "-" || op == "*" || op == "/" || op == "%", "Operator "~op~" not implemented");
        Float3 result;
        result.data = data[];
        mixin("result.data[]" ~ op ~ "=rhs.data[];");
        return result;
    }

    Float3 opBinary(string op)(float rhs) const
    {
        static assert (op == "+" || op == "-" || op == "*" || op == "/" || op == "%", "Operator "~op~" not implemented");
        Float3 result;
        result.data = data[];
        mixin("result.data[]" ~ op ~ "=rhs.data;");
        return result;
    }

    void opOpAssign(string op)(const Float3 rhs)
    {
        static assert (op == "+" || op == "-" || op == "*" || op == "/" || op == "%", "Operator "~op~" not implemented");
        mixin("data[]" ~ op ~ "=rhs.data[];");
    }

    void opOpAssign(string op)(float rhs)
    {
        static assert (op == "+" || op == "-" || op == "*" || op == "/" || op == "%", "Operator "~op~" not implemented");
        mixin("data[]" ~ op ~ "=rhs;");
    }

    float dot(Float3 rhs) const
    {
        return x * rhs.x + y * rhs.y + z * rhs.z;
    }

    float length() const
    {
        return sqrt(dot(this));
    }

    Float3 cross(const Float3 rhs) const
    {
        Float3 result;
        result.x = y * rhs.z - z * rhs.y;
        result.y = z * rhs.x - x * rhs.z;
        result.z = x * rhs.y - y * rhs.x;
        return result;
    }

}

unittest {
    const Float3 vec1 = Float3(1., 0., 2.);
    assert(vec1.x() == 1. && vec1.y() == 0. && vec1.z() == 2.);
    const Float3 vec2 = Float3(-1., 0., -2.);
    assert(vec2.x() == -1. && vec2.y() == 0. && vec2.z() == -2.);
    const Float3 vec3 = vec1 + vec2;
    assert(vec3.x() == 0. && vec3.y() == 0. && vec3.z() == 0.);

    immutable float smallEpsilon = 0.0001;
    Float3 unit1 = Float3(1., 0., 0.);
    assert(abs(unit1.length() - 1.) < smallEpsilon);
    Float3 unit2 = Float3(1., 1., 0.);
    assert(abs(unit2.length() - 1.) > smallEpsilon);
    unit2 /= unit2.length();
    assert(abs(unit2.length() - 1.) < smallEpsilon);
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
