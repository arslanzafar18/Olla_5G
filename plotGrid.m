function plotGrid(M, xl, yl, ttl, fmt)
% Annotated heat-map (imagesc + text), safe inside tiledlayout.
imagesc(M); colorbar; colormap(gca, 0.4 + 0.6*flipud(gray(64)));
xticks(1:numel(xl)); xticklabels(string(xl));
yticks(1:numel(yl)); yticklabels(string(yl));
for i = 1:size(M,1)
    for j = 1:size(M,2)
        text(j, i, sprintf(fmt, M(i,j)), 'HorizontalAlignment','center', 'FontWeight','bold');
    end
end
title(ttl);
end
