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

    real maxCount = 0;
    for (int l = 0; l < nLayers; ++l) if (layerSizes[l] > maxCount) maxCount = layerSizes[l];

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
            label(pic, "$\cdots$", (c*xSpacing, 0), theme.text);
            continue;
        }
        int l = colLayerIdx[c];
        if (l == 0) {
            drawDottedLayer(pic, positions[c], layerSizes[l], r, theme, "x");
        } else if (l == nLayers - 1) {
            drawDottedLayer(pic, positions[c], layerSizes[l], r, theme, "y");
        } else {
            drawLayer(pic, positions[c], r, theme);
        }
    }

    real captionY = -((maxCount - 1)*ySpacing)/2 - 1.0;
    for (int c = 0; c < nCols; ++c) {
        if (colLayerIdx[c] < 0) continue;
        int l = colLayerIdx[c];
        string cap;
        if (l == 0) cap = "Input";
        else if (l == nLayers - 1) cap = "Output";
        else if (useDots && l == nLayers - 2) cap = "Hidden L";
        else cap = "Hidden " + string(l);
        label(pic, cap, (c*xSpacing, captionY), theme.text);
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
