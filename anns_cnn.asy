// anns_cnn.asy
// Diagram 3: a convolutional neural network -- input volume, alternating
// convolutional / pooling feature-map stacks, a flatten step into fully
// connected layers, and an output layer.

import anns_theme;
import anns_primitives;

struct CNNBlock {
    int depth;          // number of stacked feature maps drawn for this block
    real size;          // width = height of each feature map square
    string caption;     // label drawn under the block
    string opLabel;     // label on the arrow feeding INTO this block (ignored for block 0)
    real captionExtra;  // additional downward shift for the caption (default 0)
}

CNNBlock cnnBlock(int depth, real size, string caption, string opLabel="", real captionExtra=0) {
    CNNBlock b = new CNNBlock;
    b.depth = depth;
    b.size = size;
    b.caption = caption;
    b.opLabel = opLabel;
    b.captionExtra = captionExtra;
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
             real xStep=4.2, real skew=0.10) {
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
            // stack, so it's drawn as an actual (stylized) pixel grid with
            // shaded pixel values -- here, a blocky "7" (fitting, since the
            // classifier at the end has 10 outputs) rather than an
            // abstract gradient.
            real pixCell = b.size/pixN;
            real ink = 0.85;
            real blank = 0.05;
            real[][] pixelValues = {
                {ink,  ink,  ink,  ink,  ink,  ink,  ink },
                {blank,blank,blank,blank,blank,ink,  blank},
                {blank,blank,blank,blank,ink,  blank,blank},
                {blank,blank,blank,ink,  blank,blank,blank},
                {blank,blank,ink,  blank,blank,blank,blank},
                {blank,blank,ink,  blank,blank,blank,blank},
                {blank,blank,ink,  blank,blank,blank,blank}
            };
            drawGrid(pic, basePos[i], pixCell, pixN, pixN, theme, new string[][], false, pixelValues);
            label(pic, b.caption, basePos[i] + (b.size/2, -0.4), theme.text);
        } else {
            drawFeatureStack(pic, basePos[i], b.size, b.size, b.depth, theme, b.caption, skew, b.captionExtra);
        }
        if (i > 0) {
            // A wrapped (shortstack) label is two lines tall, so it needs
            // more clearance above the arrow than a single-line one.
            real labelOffset = (find(b.opLabel, "shortstack") >= 0) ? 0.5 : 0.28;
            drawFlowArrow(pic, (rightX[i-1], flowY), (leftX[i], flowY), theme, b.opLabel, labelOffset);
            if (find(b.opLabel, "convolution") >= 0) {
                if (i == 1) {
                    // The first convolution acts on real pixels, so it's
                    // worth spelling out concretely what "6 kernels of
                    // 5x5" means: two example kernels, shaded the same
                    // way as the input pixels, stacked vertically as
                    // kernel, ..., kernel -- echoing the x1, x2, ..., xn
                    // convention used for eliding nodes elsewhere, but
                    // with the "..." between the two shown kernels rather
                    // than after them, reading as first-kernel-through-
                    // last-kernel with the middle ones elided.
                    int kN = 5;
                    real kCell = 0.12;
                    real kWidth = kN*kCell;
                    real ink = 0.85, mid = 0.5, blank = 0.05;
                    // Two patterns representative of what trained
                    // first-layer digit-classifier filters actually look
                    // like: a plus/cross (a Laplacian-style blob/stroke
                    // detector) and a diagonal edge/gradient detector --
                    // real filters are dominated by oriented edges and
                    // stroke detectors, not high-frequency patterns like a
                    // checkerboard (which a trained network essentially
                    // never learns).
                    int kMid = (int)(kN/2);
                    real[][] kernelCross = new real[kN][kN];
                    real[][] kernelDiag = new real[kN][kN];
                    for (int r = 0; r < kN; ++r) {
                        for (int c = 0; c < kN; ++c) {
                            kernelCross[r][c] = (r == kMid || c == kMid) ? ink : blank;
                            int s = r + c;
                            kernelDiag[r][c] = (s < kN-1) ? ink : (s == kN-1 ? mid : blank);
                        }
                    }
                    real vspacing = kWidth + 0.3;
                    pair gapCenter = ((rightX[i-1] + leftX[i])/2, 0);
                    pair centerTop = gapCenter + (0, vspacing);
                    pair centerBot = gapCenter - (0, vspacing);
                    drawGrid(pic, centerTop - (kWidth/2, kWidth/2), kCell, kN, kN, theme,
                             new string[][], false, kernelCross);
                    drawGrid(pic, centerBot - (kWidth/2, kWidth/2), kCell, kN, kN, theme,
                             new string[][], false, kernelDiag);
                    // Nudged up slightly: \vdots renders with its visual
                    // center below its LaTeX anchor point (see the same
                    // fix in drawDottedLayer, anns_primitives.asy).
                    label(pic, "$\vdots$", gapCenter + (0, 0.1), theme.text);
                } else {
                    drawConvHint(pic, basePos[i-1], blocks[i-1].size, basePos[i], b.size, theme);
                }
            }
        }
    }

    // --- flatten into fully connected layers ---
    real ySpacing = 1.0;
    real fcR = 0.3;
    real fcXStep = 2.0;
    real fcStartX = lastBlockX + xStep;

    // Bottom node in a dotted layer sits at -2*(ySpacing*0.6) = -1.2*ySpacing;
    // add fcR so the caption clears the node's lower edge.
    real fcHalfExtent = 1.2*ySpacing + fcR;

    pair[][] fcPos = new pair[fcSizes.length][];
    for (int l = 0; l < fcSizes.length; ++l) {
        fcPos[l] = dottedLayerPositions(fcSizes[l], fcStartX + l*fcXStep, ySpacing);
    }

    drawFlowArrow(pic, (rightX[blocks.length-1], 0), (fcStartX - fcR - 0.3, 0), theme, "flatten");

    for (int l = 0; l < fcSizes.length - 1; ++l) {
        connectLayers(pic, fcPos[l], fcR, fcPos[l+1], fcR, theme);
    }
    // countSymbols for the two layers: use distinct letters so the diagram
    // doesn't imply the hidden and output layer sizes are equal.
    string[] countSymbols = {"p", "m"};
    for (int l = 0; l < fcSizes.length; ++l) {
        if (l == fcSizes.length - 1) {
            drawDottedLayer(pic, fcPos[l], fcSizes[l], fcR, theme, "y", countSymbols[l]);
        } else {
            drawDottedLayer(pic, fcPos[l], fcSizes[l], fcR, theme, "", countSymbols[l]);
        }
    }

    real fcCaptionY = -fcHalfExtent - 0.6;
    for (int l = 0; l < fcSizes.length; ++l) {
        string cap = (l == fcSizes.length - 1) ? "Output" : ("FC " + string(l+1));
        label(pic, cap, (fcPos[l][0].x, fcCaptionY), theme.text);
    }

    real fcMidX = (fcPos[0][0].x + fcPos[fcSizes.length-1][0].x)/2;
    real fcTopY = ySpacing + fcR + 0.4;
    label(pic, "MLP", (fcMidX, fcTopY), theme.text);
}

void renderCNN(string themeName, int[] fcSizes = {8, 10}) {
    Theme theme = getTheme(themeName);
    picture pic;

    CNNBlock[] blocks = {
        cnnBlock(1,  1.8, "$28\times28$ input"),
        cnnBlock(6,  1.5, "\shortstack{$n$ $24\times24$\\feature maps}",
                 "\shortstack{convolution with\\$n$ $5\times5$ kernels}", 0.3),
        cnnBlock(6,  1.0, "\shortstack{$n$ $12\times12$\\feature maps}",  "$2\times2$ max pool", 0.3),
        cnnBlock(12, 0.5, "final feature maps",
                 "\shortstack{additional conv\\+ pool stages}")
    };

    drawCNN(pic, theme, blocks, fcSizes);
    renderTheme(pic, theme);
}

renderCNN("dark");
