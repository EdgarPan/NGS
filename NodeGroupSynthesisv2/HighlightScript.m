%Quick Script to Generate the Highlighted Similarity Graph
load('ChainResult 20200915.mat')

SelectedIndex = [2,3,5,6,11,12,13,14]

a = ((GR2{1}>0)-eye(16))~=0;
g2 = graph(a);
f = plot(g2);
highlight(f,SelectedIndex,'NodeColor','r');