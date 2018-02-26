import loadobj;
import mesh;
import raster;
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

    int width = 200;
    int height = 150;

    auto window = SDL_CreateWindow(
            "An SDL2 window",
            15,
            25,
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
    int posX, posY;
    while(run) {
        SDL_GetMouseState(&posX, &posY);

        SDL_GetWindowSize(window, &width, &height);

        const float phi = cast(float)(posX) / cast(float)(width) * PI;
        const float theta = cast(float)(posY) / cast(float)(height) * 2.0f * PI;
        const float d = 1.0f;
        const Float3 cameraPosition = Float3(d * sin(phi) * cos(theta), d * sin(phi) * sin(theta), d * cos(theta));
        raster.Render(cameraPosition, surface, zbuffer);

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
