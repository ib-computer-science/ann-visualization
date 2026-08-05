// anns_perceptron.asy
// Diagram 1: a single perceptron -- inputs, weights, bias, weighted sum,
// activation function, output.

import anns_theme;
import anns_primitives;

void drawPerceptron(picture pic, Theme theme, int nInputs=3) {
    real r = 0.4;
    real spacing = 1.4;

    pair[] inputPos = layerPositions(nInputs, 0, spacing, 0);
    pair biasPos = (0, inputPos[0].y + spacing);
    pair sumPos = (4, 0);
    pair actPos = (6.5, 0);
    pair outputEnd = (9, 0);

    string[] inputLabels = new string[nInputs];
    for (int i = 0; i < nInputs; ++i) inputLabels[i] = "$x_{" + string(i+1) + "}$";
    drawLayer(pic, inputPos, r, theme, inputLabels);

    drawAccentNode(pic, biasPos, r, theme, "$+1$");
    drawSumNode(pic, sumPos, r, theme);
    drawActivationNode(pic, actPos, r, theme);

    for (int i = 0; i < nInputs; ++i) {
        drawEdge(pic, inputPos[i], r, sumPos, r, theme, "$w_{" + string(i+1) + "}$");
    }
    drawEdge(pic, biasPos, r, sumPos, r, theme, "$b$", true);

    drawEdge(pic, sumPos, r, actPos, r, theme);
    drawEdge(pic, actPos, r, outputEnd, 0, theme);
    label(pic, "$y$", outputEnd + (0.4,0), theme.text);

    drawTitle(pic, "Single Perceptron", (sumPos.x, biasPos.y + spacing), theme);
}

void renderPerceptron(string prefix, string themeName, int nInputs=3) {
    Theme theme = getTheme(themeName);
    picture pic;
    drawPerceptron(pic, theme, nInputs);
    renderTheme(pic, prefix, theme);
}

renderPerceptron("output/anns_perceptron_light", "light");
renderPerceptron("output/anns_perceptron_dark", "dark");
