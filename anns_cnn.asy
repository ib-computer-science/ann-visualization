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

    for (int i = 0; i < blocks.length; ++i) {
        CNNBlock b = blocks[i];
        pair basePos = (leftX[i], -b.size/2);
        drawFeatureStack(pic, basePos, b.size, b.size, b.depth, theme, b.caption, skew);
        if (i > 0) {
            drawFlowArrow(pic, (rightX[i-1], flowY), (leftX[i], flowY), theme, b.opLabel);
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

    real titleY = max(flowY, fcHalfExtent) + 0.7;
    drawTitle(pic, "Convolutional Neural Network", (fcStartX/2, titleY), theme);
}

void renderCNN(string prefix, string themeName) {
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
    renderTheme(pic, prefix, theme);
}

renderCNN("anns_cnn_light", "light");
renderCNN("anns_cnn_dark", "dark");
