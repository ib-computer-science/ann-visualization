// anns_neuron.asy
// Diagram: a biological neuron's anatomy, labeled alongside the
// perceptron concept each part motivates -- dendrites collecting inputs,
// the cell body integrating them, the axon propagating the result, and
// axon terminals passing the output on to the next neuron.

import anns_theme;
import anns_primitives;

pair ellipsePoint(pair c, real rx, real ry, real thetaDeg) {
    real th = thetaDeg*pi/180;
    return c + (rx*cos(th), ry*sin(th));
}

void drawNeuron(picture pic, Theme theme) {
    pen p = theme.stroke;
    pair somaCenter = (5.2, 0);
    real somaRx = 0.9, somaRy = 0.55;

    // --- dendrites: branching lines converging into the soma, each
    // carrying a signal inward (an input to the cell) ---
    pair[] entries = {
        ellipsePoint(somaCenter, somaRx, somaRy, 150),
        ellipsePoint(somaCenter, somaRx, somaRy, 170),
        ellipsePoint(somaCenter, somaRx, somaRy, 190),
        ellipsePoint(somaCenter, somaRx, somaRy, 210)
    };
    pair[] tips = {(0.0, 1.7), (-0.3, 0.6), (-0.3, -0.6), (0.0, -1.7)};
    for (int i = 0; i < entries.length; ++i) {
        draw(pic, tips[i]..entries[i], p, Arrow(5));
    }

    // --- cell body (soma), integrating the incoming signals, with a
    // nucleus drawn inside ---
    filldraw(pic, ellipse(somaCenter, somaRx, somaRy), theme.nodeFill, p);
    filldraw(pic, circle(somaCenter, 0.22), theme.nodeFill, p);

    // --- axon: propagates the cell's output signal, with a myelin
    // sheath drawn as thick segments separated by gaps (nodes of
    // Ranvier) ---
    pair axonStart = somaCenter + (somaRx, 0);
    pair axonEnd = (11.2, 0);
    draw(pic, axonStart--axonEnd, p);
    real segLen = 0.5, gapLen = 0.3;
    real sx = axonStart.x + 0.25;
    while (sx + segLen < axonEnd.x - 0.3) {
        draw(pic, (sx, 0)--(sx + segLen, 0), p + linewidth(4));
        sx += segLen + gapLen;
    }

    // --- axon terminals: branching output endings, each passing the
    // signal on (a synaptic terminal / bouton) ---
    pair[] termTips = {(12.2, 0.8), (12.4, 0), (12.2, -0.8)};
    for (int i = 0; i < termTips.length; ++i) {
        draw(pic, axonEnd..termTips[i], p, Arrow(5));
        filldraw(pic, circle(termTips[i], 0.09), p, p);
    }

    // --- labels: biological name paired with the perceptron role it
    // motivates, sharing one baseline the way the other diagrams do.
    // The axon caption sits two-thirds of the way along it (not
    // centered) so it doesn't crowd the cell-body caption next to it.
    real captionY = -2.8;
    label(pic, "\shortstack{dendrites\\(inputs)}", (0.9, captionY), N, theme.text);
    label(pic, "\shortstack{cell body\\(activation)}", (somaCenter.x, captionY), N, theme.text);
    label(pic, "\shortstack{axon\\(carries signal)}",
          (axonStart.x + 0.65*(axonEnd.x - axonStart.x), captionY), N, theme.text);
    label(pic, "\shortstack{axon terminals\\(output)}", (12.3, captionY), N, theme.text);
}

void renderNeuron(string themeName) {
    Theme theme = getTheme(themeName);
    picture pic;
    drawNeuron(pic, theme);
    renderTheme(pic, theme);
}

renderNeuron("dark");
