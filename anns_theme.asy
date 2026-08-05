// anns_theme.asy
// Color theme definitions shared by all ANN visualization diagrams.
// Supports black-on-white and white-on-black output via a single Theme
// struct that every drawing primitive consults instead of hardcoding pens.

struct Theme {
    pen background;   // canvas background
    pen stroke;       // default line/outline color
    pen nodeFill;      // default node fill
    pen text;          // label color
    pen accent;        // highlight color (e.g. bias, weights)
    pen edge;           // connection line color

    void operate(void f(pen)) {}
}

Theme newTheme(pen background, pen stroke, pen nodeFill, pen text, pen accent, pen edge) {
    Theme t = new Theme;
    t.background = background;
    t.stroke = stroke;
    t.nodeFill = nodeFill;
    t.text = text;
    t.accent = accent;
    t.edge = edge;
    return t;
}

// Black-on-white: dark ink on a white page.
Theme lightTheme() {
    return newTheme(
        white,           // background
        black,           // stroke
        white,           // nodeFill
        black,           // text
        rgb(0.70,0.15,0.15), // accent (muted red)
        gray(0.35)        // edge
    );
}

// White-on-black: light ink on a dark page.
Theme darkTheme() {
    return newTheme(
        black,             // background
        white,             // stroke
        black,             // nodeFill
        white,             // text
        rgb(0.95,0.45,0.45), // accent
        gray(0.75)          // edge
    );
}

Theme getTheme(string name) {
    if (name == "light") return lightTheme();
    if (name == "dark") return darkTheme();
    abort("getTheme: unknown theme name '" + name + "' (expected 'light' or 'dark')");
    return lightTheme(); // unreachable, keeps the compiler happy
}

// Renders the current picture to disk with the theme's background baked in,
// using shipout(bbox(...)) so exported bitmaps aren't left transparent. No
// filename is passed to shipout, so Asymptote falls back to its own
// default (the calling script's base name). `unit` fixes the physical size
// of one drawing-coordinate unit (default 1cm), since diagrams are laid
// out in plain coordinate units and would otherwise be shipped out at
// native point scale (1 unit = 1bp) and come out illegibly small.
void renderTheme(picture pic, Theme theme, real margin=6, real unit=1cm) {
    unitsize(pic, unit);
    frame f = bbox(pic, margin, margin, invisible, Fill(theme.background));
    shipout(f);
}
