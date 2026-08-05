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
// labelSide flips which side of the line the label sits on (1 or -1),
// for cases where the automatic perpendicular placement lands awkwardly.
void drawEdge(picture pic, pair fromPt, real rFrom, pair toPt, real rTo, Theme theme,
              string label="", bool accent=false, real labelSide=1) {
    pair d = unit(toPt - fromPt);
    pair p1 = fromPt + rFrom*d;
    pair p2 = toPt - rTo*d;
    pen usePen = accent ? theme.accent : theme.edge;
    draw(pic, p1--p2, usePen, Arrow(6));
    if (label != "") {
        pair mid = (p1 + p2)/2;
        pair perp = rotate(90)*d;
        label(pic, label, mid + labelSide*0.18*perp, theme.text);
    }
}

// A dashed line from A to B with a gap around x=gapX (of half-width
// gapHalfWidth) left clear for a label -- used for the "elided layers"
// connectors in the MLP diagram, but works for any A/B, not just
// horizontal ones, since the gap is carved out by interpolating along the
// line rather than assuming a particular orientation.
void drawGappedDashedLine(picture pic, pair A, pair B, real gapX, real gapHalfWidth,
                           Theme theme, string labelText="", bool arrow=true) {
    real t1 = (gapX - gapHalfWidth - A.x) / (B.x - A.x);
    real t2 = (gapX + gapHalfWidth - A.x) / (B.x - A.x);
    pair p1 = A + t1*(B - A);
    pair p2 = A + t2*(B - A);
    draw(pic, A--p1, theme.edge + dashed);
    if (arrow) draw(pic, p2--B, theme.edge + dashed, Arrow(6));
    else draw(pic, p2--B, theme.edge + dashed);
    if (labelText != "") {
        pair mid = A + 0.5*(B - A);
        label(pic, labelText, mid, theme.text);
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

// Positions for a layer using ellipsis notation when n > 3: node 1, node 2,
// then node n, with the gap between node 2 and node n left open for a
// vertical-dots placeholder (see drawDottedLayer) and spaced more tightly
// than the n<=3 case so it reads as a compressed continuation rather than a
// genuine gap. Returns only the positions of the nodes actually drawn (3 of
// them when n>3), so the array is ready to hand to connectLayers/drawEdge.
pair[] dottedLayerPositions(int n, real x, real spacing) {
    if (n <= 3) return layerPositions(n, x, spacing, 0);
    real tailGap = spacing*0.6;
    pair[] pos = new pair[3];
    pos[0] = (x, spacing);
    pos[1] = (x, 0);
    pos[2] = (x, -2*tailGap);
    return pos;
}

// Draws the nodes for a dottedLayerPositions() layout, labeled
// labelPrefix_1, labelPrefix_2, ..., labelPrefix_{countSymbol} (using the
// literal index when n<=3, since then every node is shown). countSymbol
// names the layer's node count (e.g. "n" for one layer, "m" for another),
// so two differently-sized dotted layers in the same diagram don't both
// read as ending at "_n" -- which would visually imply equal sizes even
// when they're not.
void drawDottedLayer(picture pic, pair[] pos, int n, real r, Theme theme, string labelPrefix,
                      string countSymbol="n") {
    if (n <= 3) {
        string[] labels = new string[n];
        for (int i = 0; i < n; ++i) labels[i] = "$" + labelPrefix + "_{" + string(i+1) + "}$";
        drawLayer(pic, pos, r, theme, labels);
        return;
    }
    drawNode(pic, pos[0], r, theme, "$" + labelPrefix + "_1$");
    drawNode(pic, pos[1], r, theme, "$" + labelPrefix + "_2$");
    // \vdots renders with its visual center noticeably below its LaTeX
    // anchor point (measured ~0.1 of a unitsize(1cm) unit), so nudge the
    // anchor up to compensate and land the dots symmetrically in the gap.
    pair dotsPos = (pos[1].x, (pos[1].y + pos[2].y)/2 + 0.1);
    label(pic, "$\vdots$", dotsPos, theme.text);
    drawNode(pic, pos[2], r, theme, "$" + labelPrefix + "_" + countSymbol + "$");
}

// ---------------------------------------------------------------- grids ---
// A grid of unit cells (a small matrix), used to show the mechanics of a
// convolution: row 0 is the top row, matching how matrices are normally
// read/written, and basePos is the grid's overall lower-left corner.

pair gridCellCorner(pair basePos, real cellSize, int rows, int row, int col) {
    return basePos + (col*cellSize, (rows - 1 - row)*cellSize);
}

pair gridCellCenter(pair basePos, real cellSize, int rows, int row, int col) {
    return gridCellCorner(basePos, cellSize, rows, row, col) + (cellSize/2, cellSize/2);
}

// A pen for a grayscale pixel value (0 = background/blank, 1 = fully
// theme.stroke-colored ink), interpolated between the theme's own
// background and stroke pens so it inverts correctly between light and
// dark themes instead of hardcoding literal gray levels.
pen grayscalePen(Theme theme, real value) {
    real v = min(max(value, 0), 1);
    return (1 - v)*theme.background + v*theme.stroke;
}

// Draws every cell's outline; labels[row][col], if present, is drawn
// centered in that cell (labels may be a ragged/partial array, or omitted).
// values[row][col], if present, shades that cell as a grayscale pixel (see
// grayscalePen) before the outline is drawn on top.
// dottedLines draws a faint dotted grid instead of solid outlines, so a
// solid-outlined highlight (see highlightGridRegion/highlightGridCell)
// stands out from the background grid using line style alone -- these
// diagrams are black/white only, so this stands in for color emphasis.
void drawGrid(picture pic, pair basePos, real cellSize, int rows, int cols, Theme theme,
              string[][] labels=new string[][], bool dottedLines=false,
              real[][] values=new real[][]) {
    pen linePen = dottedLines ? theme.stroke + dotted : theme.stroke;
    for (int rIdx = 0; rIdx < rows; ++rIdx) {
        for (int cIdx = 0; cIdx < cols; ++cIdx) {
            pair corner = gridCellCorner(basePos, cellSize, rows, rIdx, cIdx);
            path cellBox = box(corner, corner + (cellSize, cellSize));
            if (rIdx < values.length && cIdx < values[rIdx].length) {
                filldraw(pic, cellBox, grayscalePen(theme, values[rIdx][cIdx]), linePen);
            } else {
                draw(pic, cellBox, linePen);
            }
            if (rIdx < labels.length && cIdx < labels[rIdx].length && labels[rIdx][cIdx] != "") {
                label(pic, labels[rIdx][cIdx], corner + (cellSize/2, cellSize/2), theme.text);
            }
        }
    }
}

// Outlines the regionRows x regionCols block of cells whose top-left
// corner is (row, col) -- e.g. where a kernel currently sits on an input
// grid.
void highlightGridRegion(picture pic, pair basePos, real cellSize, int rows, int row, int col,
                          int regionRows, int regionCols, pen p) {
    pair corner = gridCellCorner(basePos, cellSize, rows, row + regionRows - 1, col);
    draw(pic, box(corner, corner + (regionCols*cellSize, regionRows*cellSize)), p);
}

// Fills a single cell, e.g. to mark the one output value a kernel position
// produced.
void highlightGridCell(picture pic, pair basePos, real cellSize, int rows, int row, int col,
                        pen p) {
    pair corner = gridCellCorner(basePos, cellSize, rows, row, col);
    filldraw(pic, box(corner, corner + (cellSize, cellSize)), p, p);
}

// Center point of the regionRows x regionCols block of cells whose
// top-left corner is (row, col) -- matches highlightGridRegion, so an
// arrow can be drawn from/to the same block it outlines.
pair gridRegionCenter(pair basePos, real cellSize, int rows, int row, int col,
                       int regionRows, int regionCols) {
    pair corner = gridCellCorner(basePos, cellSize, rows, row + regionRows - 1, col);
    return corner + (regionCols*cellSize/2, regionRows*cellSize/2);
}

// Top-edge midpoint of that same region -- an anchor for arrows that
// should leave from the top of a highlighted block rather than its center.
pair gridRegionTopCenter(pair basePos, real cellSize, int rows, int row, int col,
                          int regionRows, int regionCols) {
    pair corner = gridCellCorner(basePos, cellSize, rows, row, col);
    return corner + (regionCols*cellSize/2, cellSize);
}

// Top-edge midpoint of a single cell.
pair gridCellTopCenter(pair basePos, real cellSize, int rows, int row, int col) {
    pair corner = gridCellCorner(basePos, cellSize, rows, row, col);
    return corner + (cellSize/2, cellSize);
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
