// anns_convolution.asy
// Diagram: how a single convolution works in isolation -- a kernel slides
// over an input grid, and each position it stops at collapses (via an
// elementwise multiply and sum) into one value in the output grid.

import anns_theme;
import anns_primitives;

void drawConvolution(picture pic, Theme theme, int inputRows=6, int inputCols=6, int k=3) {
    real cellSize = 0.55;
    real gap = 1.6;
    int outputRows = inputRows - k + 1;
    int outputCols = inputCols - k + 1;

    pair kernelBase = (0, -k*cellSize/2);
    pair inputBase = (kernelBase.x + k*cellSize + gap, -inputRows*cellSize/2);
    pair outputBase = (inputBase.x + inputCols*cellSize + gap, -outputRows*cellSize/2);

    // A small, concrete kernel (a vertical-edge-detecting filter) so the
    // grid isn't just an abstract empty matrix.
    string[][] kernelLabels = {{"1","0","-1"},{"2","0","-2"},{"1","0","-1"}};
    drawGrid(pic, kernelBase, cellSize, k, k, theme, kernelLabels);
    label(pic, "Kernel", kernelBase + (k*cellSize/2, -0.4), theme.text);

    // Input/output are drawn as faint dotted grids -- with only black and
    // white available, a solid-lined highlight is what makes the active
    // kernel window and output cell read as "different" from the rest.
    drawGrid(pic, inputBase, cellSize, inputRows, inputCols, theme, new string[][], true);
    label(pic, "Input", inputBase + (inputCols*cellSize/2, -0.4), theme.text);

    drawGrid(pic, outputBase, cellSize, outputRows, outputCols, theme, new string[][], true);
    label(pic, "Output", outputBase + (outputCols*cellSize/2, -0.4), theme.text);

    // The kernel window shown at two positions -- thick solid on the left,
    // thin solid on the right (slid all the way across) -- each producing
    // one output cell in the corresponding spot of the output grid.
    int colB = inputCols - k;
    highlightGridRegion(pic, inputBase, cellSize, inputRows, 0, 0, k, k, theme.stroke + linewidth(1.5));
    highlightGridRegion(pic, inputBase, cellSize, inputRows, 0, colB, k, k, theme.stroke + linewidth(0.7));

    highlightGridCell(pic, outputBase, cellSize, outputRows, 0, 0, theme.stroke);
    pair outCellBCorner = gridCellCorner(outputBase, cellSize, outputRows, 0, outputCols-1);
    draw(pic, box(outCellBCorner, outCellBCorner + (cellSize, cellSize)), theme.stroke + linewidth(1.0));

    pair winA = gridRegionCenter(inputBase, cellSize, inputRows, 0, 0, k, k);
    pair winB = gridRegionCenter(inputBase, cellSize, inputRows, 0, colB, k, k);

    // Arcs run from the top of each kernel window to the top of the output
    // cell it produces, rather than side-to-side, and bow upward so the
    // two (which would otherwise be collinear, since both windows sit in
    // the same input row) read as distinct paths.
    pair winATop = gridRegionTopCenter(inputBase, cellSize, inputRows, 0, 0, k, k);
    pair winBTop = gridRegionTopCenter(inputBase, cellSize, inputRows, 0, colB, k, k);
    pair cellATop = gridCellTopCenter(outputBase, cellSize, outputRows, 0, 0);
    pair cellBTop = gridCellTopCenter(outputBase, cellSize, outputRows, 0, outputCols-1);
    pair ctrlA = (winATop + cellATop)/2 + (0, 0.35);
    pair ctrlB = (winBTop + cellBTop)/2 + (0, 0.18);
    draw(pic, winATop..ctrlA..cellATop, theme.stroke + linewidth(1.2), Arrow(6));
    draw(pic, winBTop..ctrlB..cellBTop, theme.stroke + linewidth(0.6), Arrow(4));

    // An arrow above the input grid showing the kernel sliding from its
    // first position all the way to its second.
    real slideY = inputBase.y + inputRows*cellSize + 0.9;
    draw(pic, (winA.x, slideY)--(winB.x, slideY), theme.edge, Arrow(6));
    label(pic, "slide", ((winA.x + winB.x)/2, slideY + 0.32), theme.text);
}

void renderConvolution(string themeName) {
    Theme theme = getTheme(themeName);
    picture pic;
    drawConvolution(pic, theme);
    renderTheme(pic, theme);
}

renderConvolution("dark");
