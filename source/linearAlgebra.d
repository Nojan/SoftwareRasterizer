import std.math;

struct Float2 {
    @nogc pure:
    float[2] data;

    this(float x, float y)
    in
    {
        assert(isFinite(x));
        assert(isFinite(y));
    }
    do
    {
        data[0] = x;
        data[1] = y;
    }

    @property float x() const { return data[0]; }
    @property ref float x() { return data[0]; }
    @property float x(float value) { data[0] = value; return value; }

    @property float y() const { return data[1]; }
    @property ref float y() { return data[1]; }
    @property float y(float value) { data[1] = value; return value; }
}

struct Float3 {
    @nogc pure:
    float[3] data;

    this(float x, float y, float z)
    in
    {
        assert(isFinite(x));
        assert(isFinite(y));
        assert(isFinite(z));
    }
    out
    {
        assert(isValid());
    }
    do
    {
        data[0] = x;
        data[1] = y;
        data[2] = z;
    }

    bool isValid() const
    {
        bool result = true;
        foreach (i; 0 .. 3)
        {
            result = result && isFinite(data[i]);
        }
        return result;
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
        mixin("result.data[]" ~ op ~ "=rhs;");
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

    ref Float3 normalize()
    {
        const float invLength = 1.0f / length(this);
        data[] *= invLength;
        return this;
    }
}

@nogc pure:

float dot(const Float3 a, const Float3 b) 
{
    float result = 0;
    foreach(i; 0..3)
    {
        result += a.data[i] * b.data[i];
    }
    return result;
}

float length(const Float3 v)
{
    return sqrt(dot(v, v));
}

Float3 cross(const Float3 a, const Float3 b)
{
    Float3 result;
    result.x = a.y * b.z - a.z * b.y;
    result.y = a.z * b.x - a.x * b.z;
    result.z = a.x * b.y - a.y * b.x;
    return result;
}

bool approxEqual(T: Float3, U: Float3) (Float3 lhs, Float3 rhs)
{
    bool result = true;
    foreach(i; 0..3)
    {
        result = result && std.math.approxEqual!(float, float)(lhs.data[i], rhs.data[i]);
    }
    return result;
}

unittest {
    const Float3 vec1 = Float3(1., 0., 2.);
    assert(vec1.x() == 1. && vec1.y() == 0. && vec1.z() == 2.);
    const Float3 vec2 = Float3(-1., 0., -2.);
    assert(vec2.x() == -1. && vec2.y() == 0. && vec2.z() == -2.);
    const Float3 vec3 = vec1 + vec2;
    assert(approxEqual!(Float3, Float3)(vec3, Float3(0, 0, 0)));

    immutable float smallEpsilon = 0.0001;
    Float3 unit1 = Float3(1., 0., 0.);
    assert(abs(unit1.length() - 1.) < smallEpsilon);
    Float3 unit2 = Float3(1., 1., 0.);
    assert(abs(unit2.length() - 1.) > smallEpsilon);
    unit2 /= unit2.length();
    assert(abs(unit2.length() - 1.) < smallEpsilon);


    assert(approxEqual!(Float3, Float3)(Float3(-1, 0, 0), (cross(Float3(0, 0, 1), Float3(0, 1, 0))).normalize()));
}


struct Float4 {
    @nogc pure:
    float[4] data;

    this(float x, float y, float z, float w)
    in
    {
        assert(isFinite(x));
        assert(isFinite(y));
        assert(isFinite(z));
        assert(isFinite(w));
    }
    out
    {
        assert(isValid());
    }
    do
    {
        data[0] = x;
        data[1] = y;
        data[2] = z;
        data[3] = w;
    }

    this(const Float3 v)
    in
    {
        assert(v.isValid());
    }
    out
    {
        assert(isValid());
    }
    do
    {
        data[0] = v.x;
        data[1] = v.y;
        data[2] = v.z;
        data[3] = 1;
    }

    bool isValid() const
    {
        bool result = true;
        foreach (i; 0 .. 4)
        {
            result = result && isFinite(data[i]);
        }
        return result;
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

    @property float w() const { return data[3]; }
    @property ref float w() { return data[3]; }
    @property float w(float value) { data[3] = value; return value; }

    Float4 opBinary(string op)(const Float4 rhs) const
    {
        static assert (op == "+" || op == "-" || op == "*" || op == "/" || op == "%", "Operator "~op~" not implemented");
        Float4 result;
        result.data = data[];
        mixin("result.data[]" ~ op ~ "=rhs.data[];");
        return result;
    }

    Float4 opBinary(string op)(float rhs) const
    {
        static assert (op == "+" || op == "-" || op == "*" || op == "/" || op == "%", "Operator "~op~" not implemented");
        Float4 result;
        result.data = data[];
        mixin("result.data[]" ~ op ~ "=rhs.data;");
        return result;
    }

    void opOpAssign(string op)(const Float4 rhs)
    {
        static assert (op == "+" || op == "-" || op == "*" || op == "/" || op == "%", "Operator "~op~" not implemented");
        mixin("data[]" ~ op ~ "=rhs.data[];");
    }

    void opOpAssign(string op)(float rhs)
    {
        static assert (op == "+" || op == "-" || op == "*" || op == "/" || op == "%", "Operator "~op~" not implemented");
        mixin("data[]" ~ op ~ "=rhs;");
    }

}

@nogc pure:

bool approxEqual(T: Float4, U: Float4) (Float4 lhs, Float4 rhs)
{
    bool result = true;
    foreach(i; 0..4)
    {
        result = result && std.math.approxEqual!(float, float)(lhs.data[i], rhs.data[i]);
    }
    return result;
}

struct Matrix4 
{
    @nogc pure:
    float[4][4] data;

    void identity()
    {
        foreach (i; 0 .. 4) {
            foreach (j; 0 .. 4) {
                if(i == j)
                    data[i][j] = 1;
                else
                    data[i][j] = 0;
            }
        }
    }

    Matrix4 opBinary(string op)(const ref Matrix4 rhs) const
    {
        static assert (op == "*", "Operator "~op~" not implemented");
        Matrix4 result;
        foreach (i; 0 .. 4) {
            foreach (j; 0 .. 4) {
                result.data[i][j] = 0;
                foreach (k; 0 .. 4) {
                    result.data[i][j] += data[i][k] * rhs.data[k][j];
                }
            }
        }
        return result;
    }

    void opOpAssign(string op)(const Matrix4 rhs)
    {
        static assert (op == "*", "Operator "~op~" not implemented");
        data = (this * rhs).data;
    }

    void opOpAssign(string op)(const float rhs)
    {
        static assert (op == "+" || op == "-" || op == "*" || op == "/" || op == "%", "Operator "~op~" not implemented");
        foreach (i; 0 .. 4) {
            foreach (j; 0 .. 4) {
               mixin("data[i][j]" ~ op ~ "=rhs;");
            }
        }
    }

    bool opEquals()(auto ref const Matrix4 rhs) const 
    { 
        return data[] == rhs.data[];
    }

    unittest 
    {
        Matrix4 a,b;
        a.identity();
        b.identity();
        assert(a == b);
        Matrix4 c = a*b;
        assert(a == c);
        Float3 v = Float3(1, 1, 1);
        assert(v == c.transform(v));
    }
}

bool approxEqual(T: Matrix4, U: Matrix4) (Matrix4 lhs, Matrix4 rhs)
{
    bool result = true;
    foreach(i; 0..4)
    {
        foreach(j; 0..4)
        {
            result = result && std.math.approxEqual!(float, float)(lhs.data[i][j], rhs.data[i][j]);
        }   
    }
    return result;
}

Float3 transform(const ref Matrix4 m, const Float3 v)
in
{
    assert(v.isValid());
}
out(result)
{
    assert(result.isValid());
}
do
{
    Float4 r4 = transform(m, Float4(v));
    Float3 result = Float3(r4.x, r4.y, r4.z);
    result *= (1.0 / r4.w);
    return result;
}

Float4 transform(const ref Matrix4 m, const Float4 v)
in
{
    assert(v.isValid());
}
out(result)
{
    assert(result.isValid());
}
do
{
    Float4 result;
    foreach (i; 0 .. 4) {
        result.data[i] = 0;
        foreach (k; 0 .. 4) {
            result.data[i] += m.data[k][i] * v.data[k];
        }
    }
    return result;
}

unittest 
{
    const Matrix4 model = Matrix4([[-1, 0, 0, 0], [0, 1, 0, 0], [0, 0, -1, 0], [0, 0, -1, 1]]);
    const Float4 vertex = Float4(0, 0.25, 0, 1);
    const Float4 vertexTransformed = transform(model, vertex);
    assert(approxEqual!(Float4, Float4)(vertexTransformed, Float4(0, 0.25, -1, 1)));
}

Matrix4 viewport(int x, int y, int w, int h, int depth) {
    Matrix4 m;
    m.identity();

    m.data[0][3] = x+w/2.0f;
    m.data[1][3] = y+h/2.0f;
    m.data[2][3] = depth/2.0f;

    m.data[0][0] = w/2.0f;
    m.data[1][1] = h/2.0f;
    m.data[2][2] = depth/2.0f;
    return m;
}

Matrix4 lookAt(Float3 eye, Float3 center, Float3 up)
{
    const Float3 f = (center - eye).normalize();
    const Float3 s = (cross(f, up)).normalize();
    const Float3 u = cross(s, f);

    Matrix4 result;
    result.identity();
    result.data[0][0] = s.x;
    result.data[1][0] = s.y;
    result.data[2][0] = s.z;
    result.data[0][1] = u.x;
    result.data[1][1] = u.y;
    result.data[2][1] = u.z;
    result.data[0][2] =-f.x;
    result.data[1][2] =-f.y;
    result.data[2][2] =-f.z;
    result.data[3][0] =-dot(s, eye);
    result.data[3][1] =-dot(u, eye);
    result.data[3][2] = dot(f, eye);
    return result;
}

Matrix4 perspective(float fovy, float aspect, float zNear, float zFar)
in
{
    assert(aspect > 0);
}
do
{
    const float tanHalfFovy = tan(fovy / 2.0f);
    Matrix4 result;
    result.identity();
    result.data[0][0] = 1.0f / (aspect * tanHalfFovy);
    result.data[1][1] = 1.0f / (tanHalfFovy);
    result.data[2][2] = - (zFar + zNear) / (zFar - zNear);
    result.data[3][2] = - (2.0f * zFar * zNear) / (zFar - zNear);
    result.data[2][3] = - 1.0f;
    result.data[3][3] = 0;
    return result;
}

unittest
{  
    const float width = 200.0f;
    const float height = 150.0f;
    const Matrix4 model = lookAt(Float3(0, 0, -1), Float3(0, 0, 0), Float3(0, 1, 0));
    const Matrix4 modelCmp = Matrix4([[-1, 0, 0, 0], [0, 1, 0, 0], [0, 0, -1, 0], [0, 0, -1, 1]]);
    assert(approxEqual!(Matrix4, Matrix4)(model, modelCmp));
    const float ratio = width / height;
    const Matrix4 projection = perspective(PI_4, ratio, 0.1f, 10.0f);
    const Matrix4 projectionCmp = Matrix4([[1.81066012, 0, 0, 0], [0, 2.41421342, 0, 0], [0, 0, -1.02020204, -1], [0, 0, -0.202020213, 0]]);
    assert(approxEqual!(Matrix4, Matrix4)(projection, projectionCmp));
}

T lerp(T)(float t, T a, T b) {
    return a * (cast(T)1 - t) + b * t;
}
