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
    // independent of nInputs. The dots/xn tail is spaced more tightly than
    // x1/x2 so it reads as a compressed continuation rather than a genuine
    // gap in the layer.
    bool useDots = nInputs > 3;
    int nRows = useDots ? 4 : nInputs;

    pair[] rowPos;
    if (useDots) {
        real tailGap = spacing*0.6;
        rowPos = new pair[4];
        rowPos[0] = (0, spacing);
        rowPos[1] = (0, 0);
        rowPos[2] = (0, -tailGap);
        rowPos[3] = (0, -2*tailGap);
    } else {
        rowPos = layerPositions(nRows, 0, spacing, 0);
    }
    pair sumPos = (4, 0);
    pair actPos = (6.5, 0);
    pair outputEnd = (9, 0);
    // Directly above the sum node, so its connecting edge is vertical.
    pair biasPos = (sumPos.x, rowPos[0].y + spacing);

    if (useDots) {
        drawNode(pic, rowPos[0], r, theme, "$x_1$");
        drawEdge(pic, rowPos[0], r, sumPos, r, theme, "$w_1$");

        drawNode(pic, rowPos[1], r, theme, "$x_2$");
        drawEdge(pic, rowPos[1], r, sumPos, r, theme, "$w_2$");

        label(pic, "$\vdots$", rowPos[2], theme.text);

        drawNode(pic, rowPos[3], r, theme, "$x_n$");
        drawEdge(pic, rowPos[3], r, sumPos, r, theme, "$w_n$", false, -1);
    } else {
        for (int i = 0; i < nInputs; ++i) {
            drawNode(pic, rowPos[i], r, theme, "$x_{" + string(i+1) + "}$");
            drawEdge(pic, rowPos[i], r, sumPos, r, theme, "$w_{" + string(i+1) + "}$");
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
