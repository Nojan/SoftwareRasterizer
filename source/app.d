import loadobj;
import mesh;
import linearAlgebra;
import raster;
import surface;
import numeric_alias;
import derelict.sdl2.sdl;
import std.stdio;
import std.conv;
import std.math;

void main()
{
    auto libSDLName = "external\\SDL2\\lib\\x64\\SDL2.dll";
	DerelictSDL2.load(libSDLName);
    if(0 != SDL_Init(SDL_INIT_VIDEO))
    {
        assert(0, "Failed to initialize sdl!");
    }
    scope(exit) SDL_Quit();

    int width = 400;
    int height = 250;

    auto window = SDL_CreateWindow(
            "An SDL2 window",
            25,
            35,
            width,
            height,
            SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE);
    if(window is null)
    {
        assert(0, "Failed to create SDL window!");
    }
    scope(exit) SDL_DestroyWindow(window);

    auto renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_PRESENTVSYNC);
    scope(exit) SDL_DestroyRenderer(renderer);

    Mesh mesh = LoadFromFile("model/2triangle.obj");

    Raster raster;
    raster.SetModel(mesh);
    Surface surface;

    bool run = true;
    int posX, posY;
    while(run) {
        SDL_GetMouseState(&posX, &posY);

        SDL_GetWindowSize(window, &width, &height);
        surface.SetSize(width, height);
        raster.SetSize(width, height);
        const float rX = (cast(float)(posX) / cast(float)(width)  - 0.5f) * (PI - 0.00001f);
        const float rY = (cast(float)(posY) / cast(float)(height) - 0.5f) * (PI - 0.00001f);
        const float d = 3.0f;
        const Float3 cameraPosition = Float3(sin(rX), -sin(rY), cos(rX) * cos(rY)) * d;
        raster.Render(cameraPosition, surface);
        auto texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_STREAMING, width, height);
        scope(exit) SDL_DestroyTexture(texture);
        SDL_UpdateTexture(texture, null, surface.m_data.ptr, to!int(width * u32.sizeof));
        SDL_RenderClear(renderer);
        SDL_RenderCopy(renderer, texture, null, null);
        SDL_RenderPresent(renderer);
        SDL_Event event;
        while(SDL_PollEvent(&event))
        {
			switch(event.type)
            {
            case SDL_QUIT:
                run = false;
                break;
			default:
                break;
			}
		}
	}

}
