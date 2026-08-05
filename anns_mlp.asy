// anns_mlp.asy
// Diagram 2: a fully-connected multi-layer network with an input layer, a
// variable number of hidden layers, and an output layer. Layer sizes are
// given as an array, e.g. {4,5,5,3} = 4 inputs, two hidden layers of 5
// units each, 3 outputs -- the number of hidden layers is whatever the
// array's length dictates.

import anns_theme;
import anns_primitives;

void drawMLP(picture pic, Theme theme, int[] layerSizes, real xSpacing=2.5, real ySpacing=1.1) {
    int nLayers = layerSizes.length;
    int nHidden = nLayers - 2;
    real r = 0.35;

    // For more than 2 hidden layers, only the input, first two hidden
    // layers, last hidden layer, and output are drawn -- the layers in
    // between are elided with a "..." column, so the diagram's width stays
    // independent of how many hidden layers there are. colLayerIdx maps
    // each drawn column to its index in layerSizes, or -1 for the ellipsis.
    bool useDots = nHidden > 2;
    int nCols;
    int[] colLayerIdx;
    if (useDots) {
        nCols = 6;
        colLayerIdx = new int[6];
        colLayerIdx[0] = 0;
        colLayerIdx[1] = 1;
        colLayerIdx[2] = 2;
        colLayerIdx[3] = -1;
        colLayerIdx[4] = nLayers-2;
        colLayerIdx[5] = nLayers-1;
    } else {
        nCols = nLayers;
        colLayerIdx = new int[nLayers];
        for (int c = 0; c < nLayers; ++c) colLayerIdx[c] = c;
    }

    // Input and output columns also use ellipsis notation when they have
    // more than 3 neurons, the same convention as the perceptron diagram.
    pair[][] positions = new pair[nCols][];
    for (int c = 0; c < nCols; ++c) {
        if (colLayerIdx[c] < 0) continue;
        int l = colLayerIdx[c];
        if (l == 0 || l == nLayers - 1) {
            positions[c] = dottedLayerPositions(layerSizes[l], c*xSpacing, ySpacing);
        } else {
            positions[c] = layerPositions(layerSizes[l], c*xSpacing, ySpacing, 0);
        }
    }

    // Connections drawn first so node fills sit cleanly on top of them.
    // Only adjacent columns that are both real layers get connected -- the
    // ellipsis column represents a break in the fully-connected chain.
    for (int c = 0; c < nCols - 1; ++c) {
        if (colLayerIdx[c] >= 0 && colLayerIdx[c+1] >= 0) {
            connectLayers(pic, positions[c], r, positions[c+1], r, theme);
        }
    }

    for (int c = 0; c < nCols; ++c) {
        if (colLayerIdx[c] < 0) {
            // Dashed lines through the ellipsis stand in for the elided
            // layers' connections, one per node row (spanning the taller
            // of the two neighboring hidden layers) so the chain reads as
            // many parallel connections continuing rather than a single
            // broken link. Each is split into two segments with a gap for
            // its dots label so the dashes don't run through the dots.
            int prevL = colLayerIdx[c-1];
            int nextL = colLayerIdx[c+1];
            int nRows = max(layerSizes[prevL], layerSizes[nextL]);
            pair[] rows = layerPositions(nRows, 0, ySpacing, 0);

            real midX = c*xSpacing;
            real labelGap = 0.55;
            real fromX = (c-1)*xSpacing + r;
            real toX = (c+1)*xSpacing - r;

            // Diagonal dashed lines to neighboring rows hint that the
            // elided layers are still fully connected rather than a
            // simple row-to-row pass-through; every line (horizontal or
            // diagonal) gets its own gap and dots label so none of them
            // read as a solid, unbroken connection.
            for (int i = 0; i < nRows; ++i) {
                pair rowStart = (fromX, rows[i].y);
                if (i-1 >= 0) drawGappedDashedLine(pic, rowStart, (toX, rows[i-1].y), midX, labelGap, theme, "$\cdots$");
                if (i+1 < nRows) drawGappedDashedLine(pic, rowStart, (toX, rows[i+1].y), midX, labelGap, theme, "$\cdots$");
                drawGappedDashedLine(pic, rowStart, (toX, rows[i].y), midX, labelGap, theme, "$\cdots$");
            }
            continue;
        }
        int l = colLayerIdx[c];
        if (l == 0) {
            drawDottedLayer(pic, positions[c], layerSizes[l], r, theme, "x", "n");
        } else if (l == nLayers - 1) {
            drawDottedLayer(pic, positions[c], layerSizes[l], r, theme, "y", "m");
        } else {
            drawLayer(pic, positions[c], r, theme);
        }
    }
}

void renderMLP(string themeName, int[] layerSizes) {
    Theme theme = getTheme(themeName);
    picture pic;
    drawMLP(pic, theme, layerSizes);
    renderTheme(pic, theme);
}

int[] layerSizes = {6,5,5,5,5,8};
renderMLP("dark", layerSizes);
