// anns_cnn.asy
// Diagram 3: a convolutional neural network -- input volume, alternating
// convolutional / pooling feature-map stacks, a flatten step into fully
// connected layers, and an output layer.

import anns_theme;
import anns_primitives;

struct CNNBlock {
    int depth;       // number of stacked feature maps drawn for this block
    real size;        // width = height of each feature map square
    string caption;    // label drawn under the block
    string opLabel;    // label on the arrow feeding INTO this block (ignored for block 0)
}

CNNBlock cnnBlock(int depth, real size, string caption, string opLabel="") {
    CNNBlock b = new CNNBlock;
    b.depth = depth;
    b.size = size;
    b.caption = caption;
    b.opLabel = opLabel;
    return b;
}

// Visual hint for what a convolution actually does: a small dashed
// "kernel window" on the input block's front face, connected by an arrow
// to a single highlighted cell on the output block's front face -- one
// small patch of input producing one value in the output feature map.
void drawConvHint(picture pic, pair inBase, real inSize, pair outBase, real outSize,
                   Theme theme, real kernelFrac=0.32) {
    real kSize = inSize*kernelFrac;
    pair kCorner = inBase + (0, inSize - kSize);
    // A dashed outline breaks up unreadably at this small a scale, so the
    // kernel window uses a heavier solid outline instead -- these diagrams
    // are black/white only, so weight (not color) is what sets it apart
    // from the block's own outline.
    draw(pic, box(kCorner, kCorner + (kSize, kSize)), theme.stroke + linewidth(1.6));

    real cellSize = outSize*0.16;
    pair oCorner = outBase + (0, outSize - cellSize);
    filldraw(pic, box(oCorner, oCorner + (cellSize, cellSize)), theme.stroke, theme.stroke);

    pair kCenter = kCorner + (kSize/2, kSize/2);
    pair oCenter = oCorner + (cellSize/2, cellSize/2);
    draw(pic, kCenter--oCenter, theme.stroke + linewidth(0.8), Arrow(4));
}

void drawCNN(picture pic, Theme theme, CNNBlock[] blocks, int[] fcSizes,
             real xStep=3.6, real skew=0.10) {
    // --- convolutional / pooling stacks ---
    // Operation arrows are routed along a common horizontal line above all
    // the blocks (flowY), independent of each block's own size, so their
    // captions never collide with the per-block captions drawn underneath.
    real[] leftX = new real[blocks.length];
    real[] rightX = new real[blocks.length];
    real blockHalfExtent = 0;
    real x = 0;
    for (int i = 0; i < blocks.length; ++i) {
        CNNBlock b = blocks[i];
        real ext = (b.depth - 1)*skew;
        leftX[i] = x;
        rightX[i] = x + b.size + ext;
        blockHalfExtent = max(blockHalfExtent, b.size/2 + ext);
        if (i < blocks.length - 1) x += xStep;
    }
    real lastBlockX = x;
    real flowY = blockHalfExtent + 0.6;

    pair[] basePos = new pair[blocks.length];
    for (int i = 0; i < blocks.length; ++i) basePos[i] = (leftX[i], -blocks[i].size/2);

    int pixN = 7;
    for (int i = 0; i < blocks.length; ++i) {
        CNNBlock b = blocks[i];
        if (i == 0) {
            // The input is real pixel data, not an abstract feature-map
            // stack, so it's drawn as an actual (stylized) pixel grid
            // rather than a plain square.
            real pixCell = b.size/pixN;
            drawGrid(pic, basePos[i], pixCell, pixN, pixN, theme);
            label(pic, b.caption, basePos[i] + (b.size/2, -0.4), theme.text);
        } else {
            drawFeatureStack(pic, basePos[i], b.size, b.size, b.depth, theme, b.caption, skew);
        }
        if (i > 0) {
            drawFlowArrow(pic, (rightX[i-1], flowY), (leftX[i], flowY), theme, b.opLabel);
            if (find(b.opLabel, "conv") >= 0) {
                if (i == 1) {
                    // The first convolution acts on real pixels, so it's
                    // worth spelling out concretely what "6 kernels of
                    // 5x5" means: two example kernels, drawn the same way
                    // as the input, sitting in the gap between the two.
                    int kN = 5;
                    real kCell = 0.13;
                    real kWidth = kN*kCell;
                    pair gapCenter = ((rightX[i-1] + leftX[i])/2, 0);
                    pair centerA = gapCenter - (kWidth/2 + 0.15, 0);
                    pair centerB = gapCenter + (kWidth/2 + 0.15, 0);
                    drawGrid(pic, centerA - (kWidth/2, kWidth/2), kCell, kN, kN, theme);
                    drawGrid(pic, centerB - (kWidth/2, kWidth/2), kCell, kN, kN, theme);
                } else {
                    drawConvHint(pic, basePos[i-1], blocks[i-1].size, basePos[i], b.size, theme);
                }
            }
        }
    }

    // --- flatten into fully connected layers ---
    real ySpacing = 0.75;
    real fcR = 0.3;
    real fcXStep = 2.0;
    real fcStartX = lastBlockX + xStep;

    real fcMaxCount = 0;
    for (int l = 0; l < fcSizes.length; ++l) fcMaxCount = max(fcMaxCount, (real) fcSizes[l]);
    real fcHalfExtent = (fcMaxCount - 1)*ySpacing/2;

    pair[][] fcPos = new pair[fcSizes.length][];
    for (int l = 0; l < fcSizes.length; ++l) {
        fcPos[l] = layerPositions(fcSizes[l], fcStartX + l*fcXStep, ySpacing, 0);
    }

    drawFlowArrow(pic, (rightX[blocks.length-1], 0), (fcStartX - fcR - 0.3, 0), theme, "flatten");

    for (int l = 0; l < fcSizes.length - 1; ++l) {
        connectLayers(pic, fcPos[l], fcR, fcPos[l+1], fcR, theme);
    }
    for (int l = 0; l < fcSizes.length; ++l) {
        string[] labels = new string[fcSizes[l]];
        for (int i = 0; i < fcSizes[l]; ++i) labels[i] = "";
        if (l == fcSizes.length - 1) {
            for (int i = 0; i < fcSizes[l]; ++i) labels[i] = "$y_{" + string(i+1) + "}$";
        }
        drawLayer(pic, fcPos[l], fcR, theme, labels);
    }

    real fcCaptionY = -fcHalfExtent - 0.6;
    for (int l = 0; l < fcSizes.length; ++l) {
        string cap = (l == fcSizes.length - 1) ? "Output" : ("FC " + string(l+1));
        label(pic, cap, (fcPos[l][0].x, fcCaptionY), theme.text);
    }
}

void renderCNN(string themeName) {
    Theme theme = getTheme(themeName);
    picture pic;

    CNNBlock[] blocks = {
        cnnBlock(1,  1.8, "Input (28x28x1)"),
        cnnBlock(6,  1.5, "Conv1 (24x24x6)",  "5x5 conv"),
        cnnBlock(6,  1.0, "Pool1 (12x12x6)",  "2x2 max pool"),
        cnnBlock(12, 0.8, "Conv2 (8x8x12)",   "5x5 conv"),
        cnnBlock(12, 0.5, "Pool2 (4x4x12)",   "2x2 max pool")
    };
    int[] fcSizes = {8, 10};

    drawCNN(pic, theme, blocks, fcSizes);
    renderTheme(pic, theme);
}

renderCNN("dark");
