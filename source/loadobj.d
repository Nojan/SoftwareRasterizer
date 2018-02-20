import mesh;

Mesh LoadFromFile(string filename)
{
    import std.stdio;
    import std.string;
    import std.format;

    Mesh mesh;
    auto file = File(filename);
	foreach (l; file.byLine())
    {
        string line = l.idup;
        if(startsWith(line, "v "))
        {
            Float3 vertex;
            line.formattedRead!"v %f %f %f"(vertex.x, vertex.y, vertex.z);
            mesh.vertices ~= vertex; 
        }
        else if(startsWith(line, "vn "))
        {
            Float3 normal;
            line.formattedRead!"vn %f %f %f"(normal.x, normal.y, normal.z);
            mesh.normals ~= normal; 
        }
        else if(startsWith(line, "vt "))
        {
            Float2 coord;
            line.formattedRead!"vt %f %f"(coord.x, coord.y);
            mesh.uv ~= coord; 
        }
        else if(startsWith(line, "f "))
        {
            int[9] idx;
            line.formattedRead!"f %d/%d/%d %d/%d/%d %d/%d/%d"(idx[0], idx[1], idx[2], idx[3], idx[4], idx[5], idx[6], idx[7], idx[8]);
            idx[] -= 1;
            Face f;
            f.vertices[0] = idx[0];
            f.uv[0] = idx[1];
            f.normals[0] = idx[2];
            f.vertices[1] = idx[3];
            f.uv[1] = idx[4];
            f.normals[1] = idx[5];
            f.vertices[2] = idx[6];
            f.uv[1] = idx[7];
            f.normals[2] = idx[8];
            mesh.face ~= f; 
        }
    }
    return mesh;
}