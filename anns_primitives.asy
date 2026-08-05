// anns_primitives.asy
// Shared drawing primitives for all ANN visualization diagrams: nodes,
// edges/connections, layers of nodes, and the small iconography (sum,
// activation curve) reused across perceptron / MLP / CNN diagrams.
// Every function takes a Theme (see anns_theme.asy) so the same code
// renders identically in light and dark variants.

import anns_theme;

// ---------------------------------------------------------------- nodes ---

// Plain circular unit (input / output / hidden node).
void drawNode(picture pic, pair pos, real r, Theme theme, string label="") {
    filldraw(pic, circle(pos, r), theme.nodeFill, theme.stroke);
    if (label != "") label(pic, label, pos, theme.text);
}

// Circular unit stroked with the accent color, for special nodes such as
// a bias / +1 input.
void drawAccentNode(picture pic, pair pos, real r, Theme theme, string label="") {
    filldraw(pic, circle(pos, r), theme.nodeFill, theme.accent + linewidth(1.2));
    if (label != "") label(pic, label, pos, theme.text);
}

// Node decorated with a "sum" symbol, representing a weighted-sum unit.
void drawSumNode(picture pic, pair pos, real r, Theme theme) {
    drawNode(pic, pos, r, theme);
    label(pic, "$\Sigma$", pos, theme.text);
}

// Node decorated with a small S-curve icon, representing an activation
// function unit.
void drawActivationNode(picture pic, pair pos, real r, Theme theme) {
    drawNode(pic, pos, r, theme);
    path sig = (-0.6,-0.55){dir(25)} .. (-0.15,-0.45) .. (0,0) .. (0.15,0.45) .. (0.6,0.55){dir(25)};
    draw(pic, shift(pos)*scale(r*0.7)*sig, theme.stroke + linewidth(1.0));
}

// ---------------------------------------------------------------- edges ---

// Connection between two circular nodes, trimmed to the node boundaries so
// arrowheads land on the circle edge rather than its center. Set accent=true
// to draw it in the theme's accent color (e.g. a bias connection).
void drawEdge(picture pic, pair fromPt, real rFrom, pair toPt, real rTo, Theme theme,
              string label="", bool accent=false) {
    pair d = unit(toPt - fromPt);
    pair p1 = fromPt + rFrom*d;
    pair p2 = toPt - rTo*d;
    pen usePen = accent ? theme.accent : theme.edge;
    draw(pic, p1--p2, usePen, Arrow(6));
    if (label != "") {
        pair mid = (p1 + p2)/2;
        pair perp = rotate(90)*d;
        label(pic, label, mid + 0.18*perp, theme.text);
    }
}

// ---------------------------------------------------------------- layers --

// Positions for a vertical column of n nodes at horizontal offset x,
// evenly spaced by `spacing` and centered on ycenter.
pair[] layerPositions(int n, real x, real spacing, real ycenter=0) {
    pair[] pos = new pair[n];
    real totalHeight = (n - 1)*spacing;
    real yStart = ycenter + totalHeight/2;
    for (int i = 0; i < n; ++i) {
        pos[i] = (x, yStart - i*spacing);
    }
    return pos;
}

// Draws a full layer of plain nodes; labels[i], if present, is drawn inside
// node i (labels may be shorter than positions, or omitted entirely).
void drawLayer(picture pic, pair[] positions, real r, Theme theme, string[] labels=new string[]) {
    for (int i = 0; i < positions.length; ++i) {
        string lab = (i < labels.length) ? labels[i] : "";
        drawNode(pic, positions[i], r, theme, lab);
    }
}

// Fully connects every node in one layer to every node in the next.
void connectLayers(picture pic, pair[] fromPos, real rFrom, pair[] toPos, real rTo, Theme theme) {
    for (int i = 0; i < fromPos.length; ++i) {
        for (int j = 0; j < toPos.length; ++j) {
            drawEdge(pic, fromPos[i], rFrom, toPos[j], rTo, theme);
        }
    }
}

// ------------------------------------------------------- CNN box/volume --

// Draws a stack of `depth` overlapping rectangles (a common shorthand for a
// stack of feature maps / channels), back-to-front so the front face is on
// top. basePos is the lower-left corner of the frontmost rectangle.
void drawFeatureStack(picture pic, pair basePos, real w, real h, int depth, Theme theme,
                       string label="", real skew=0.12) {
    for (int i = depth - 1; i >= 0; --i) {
        pair offset = (i*skew, i*skew);
        filldraw(pic, shift(basePos + offset)*box((0,0), (w,h)), theme.nodeFill, theme.stroke);
    }
    if (label != "") {
        label(pic, label, basePos + (w/2, -0.4), theme.text);
    }
}

// Arrow flowing from one CNN block to the next, with an optional caption
// (e.g. "3x3 conv", "2x2 max pool") drawn above the arrow.
void drawFlowArrow(picture pic, pair fromPt, pair toPt, Theme theme, string label="",
                    real labelOffset=0.28) {
    draw(pic, fromPt--toPt, theme.edge, Arrow(6));
    if (label != "") {
        label(pic, label, (fromPt + toPt)/2 + (0, labelOffset), theme.text);
    }
}

// ---------------------------------------------------------------- misc ----

void drawTitle(picture pic, string title, pair pos, Theme theme) {
    label(pic, "\textbf{" + title + "}", pos, theme.text);
}
