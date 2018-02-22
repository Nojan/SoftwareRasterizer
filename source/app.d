import loadobj;
import mesh;
import raster;
import numeric_alias;
import derelict.sdl2.sdl;
import std.stdio;
import std.conv;

void main()
{
    auto libSDLName = "external\\SDL2\\lib\\x64\\SDL2.dll";
	DerelictSDL2.load(libSDLName);
    if(0 != SDL_Init(SDL_INIT_VIDEO))
    {
        assert(0, "Failed to initialize sdl!");
    }
    scope(exit) SDL_Quit();

    auto window = SDL_CreateWindow(
            "An SDL2 window",
            15,
            25,
            800,
            600,
            SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE);
    if(window is null)
    {
        assert(0, "Failed to create SDL window!");
    }
    scope(exit) SDL_DestroyWindow(window);

    auto renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_PRESENTVSYNC);
    scope(exit) SDL_DestroyRenderer(renderer);

    int width = 160;
    int height = 144;

    auto texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_STREAMING, width, height);
    scope(exit) SDL_DestroyTexture(texture);

    Mesh mesh = LoadFromFile("model/saria.obj");

    Raster raster;
    raster.SetModel(mesh);
    raster.SetSize(width, height);

    Surface surface;
    surface.SetSize(width, height);
    float[] zbuffer;
    zbuffer.length = width*height;

    bool run = true;
    while(run) {
        raster.Render(surface, zbuffer);

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
