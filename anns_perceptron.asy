// anns_perceptron.asy
// Diagram 1: a single perceptron -- inputs, weights, bias, weighted sum,
// activation function, output.

import anns_theme;
import anns_primitives;

void drawPerceptron(picture pic, Theme theme, int nInputs=5) {
    real r = 0.4;
    real spacing = 1.4;

    // For more than 3 inputs, only x1, x2, ..., xn are drawn -- the middle
    // ones are elided with a vertical-dots row so the diagram's size stays
    // independent of nInputs.
    bool useDots = nInputs > 3;
    pair[] inputPos = dottedLayerPositions(nInputs, 0, spacing);
    drawDottedLayer(pic, inputPos, nInputs, r, theme, "x");

    pair sumPos = (4, 0);
    pair actPos = (6.5, 0);
    pair outputEnd = (9, 0);
    // Directly above the sum node, so its connecting edge is vertical.
    pair biasPos = (sumPos.x, inputPos[0].y + spacing);

    if (useDots) {
        drawEdge(pic, inputPos[0], r, sumPos, r, theme, "$w_1$");
        drawEdge(pic, inputPos[1], r, sumPos, r, theme, "$w_2$");
        drawEdge(pic, inputPos[2], r, sumPos, r, theme, "$w_n$", false, -1);
    } else {
        for (int i = 0; i < nInputs; ++i) {
            drawEdge(pic, inputPos[i], r, sumPos, r, theme, "$w_{" + string(i+1) + "}$");
        }
    }

    drawNode(pic, biasPos, r, theme, "$b$");
    drawSumNode(pic, sumPos, r, theme);
    drawActivationNode(pic, actPos, r, theme);

    drawEdge(pic, biasPos, r, sumPos, r, theme);
    drawEdge(pic, sumPos, r, actPos, r, theme);
    drawEdge(pic, actPos, r, outputEnd, 0, theme);
    label(pic, "$y$", outputEnd + (0.4,0), theme.text);
}

void renderPerceptron(string themeName, int nInputs=5) {
    Theme theme = getTheme(themeName);
    picture pic;
    drawPerceptron(pic, theme, nInputs);
    renderTheme(pic, theme);
}

renderPerceptron("dark");
