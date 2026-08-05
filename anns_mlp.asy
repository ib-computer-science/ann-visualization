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
    real r = 0.35;

    pair[][] positions = new pair[nLayers][];
    real maxCount = 0;
    for (int l = 0; l < nLayers; ++l) {
        positions[l] = layerPositions(layerSizes[l], l*xSpacing, ySpacing, 0);
        if (layerSizes[l] > maxCount) maxCount = layerSizes[l];
    }

    // Connections drawn first so node fills sit cleanly on top of them.
    for (int l = 0; l < nLayers - 1; ++l) {
        connectLayers(pic, positions[l], r, positions[l+1], r, theme);
    }

    for (int l = 0; l < nLayers; ++l) {
        string[] labels = new string[layerSizes[l]];
        for (int i = 0; i < layerSizes[l]; ++i) labels[i] = "";
        if (l == 0) {
            for (int i = 0; i < layerSizes[l]; ++i) labels[i] = "$x_{" + string(i+1) + "}$";
        } else if (l == nLayers - 1) {
            for (int i = 0; i < layerSizes[l]; ++i) labels[i] = "$y_{" + string(i+1) + "}$";
        }
        drawLayer(pic, positions[l], r, theme, labels);
    }

    real captionY = -((maxCount - 1)*ySpacing)/2 - 1.0;
    for (int l = 0; l < nLayers; ++l) {
        string cap = (l == 0) ? "Input" : (l == nLayers - 1) ? "Output" : ("Hidden " + string(l));
        label(pic, cap, (l*xSpacing, captionY), theme.text);
    }

    real titleY = ((maxCount - 1)*ySpacing)/2 + 1.2;
    drawTitle(pic, "Multi-Layer Network", ((nLayers - 1)*xSpacing/2, titleY), theme);
}

void renderMLP(string prefix, string themeName, int[] layerSizes) {
    Theme theme = getTheme(themeName);
    picture pic;
    drawMLP(pic, theme, layerSizes);
    renderTheme(pic, prefix, theme);
}

int[] layerSizes = {4,5,5,3};
renderMLP("anns_mlp", "dark", layerSizes);
