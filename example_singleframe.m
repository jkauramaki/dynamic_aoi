% Overlay example image with AOIs and landmarks, second image with original
% openface landmarks

[dynaoi,dynlm]=generate_dynaoi(['openface_examples' filesep 'singleframe.csv']);

inputimg=imread(['openface_examples' filesep 'singleframe.png']);

figure(1); clf; imshow(inputimg);
hold on;
f=1;
% show all 7 AOIs
plot(dynaoi(f).aoi_leye);
plot(dynaoi(f).aoi_reye);
plot(dynaoi(f).aoi_l_eyebrow);
plot(dynaoi(f).aoi_r_eyebrow);
plot(dynaoi(f).aoi_nose);
plot(dynaoi(f).aoi_mouth);
plot(dynaoi(f).aoi_forehead);
% plot also landmarks
h=plot(dynlm(f).lm_l_eye(1),dynlm(f).lm_l_eye(2),'.'); h.MarkerSize=10; h.Color='yellow';
h=plot(dynlm(f).lm_r_eye(1),dynlm(f).lm_r_eye(2),'.'); h.MarkerSize=10; h.Color='yellow';
h=plot(dynlm(f).lm_nose(1),dynlm(f).lm_nose(2),'.'); h.MarkerSize=10; h.Color='yellow';
h=plot(dynlm(f).lm_mouth(1),dynlm(f).lm_mouth(2),'.'); h.MarkerSize=10; h.Color='yellow';
h=plot(dynlm(f).lm_forehead(1),dynlm(f).lm_forehead(2),'.'); h.MarkerSize=10; h.Color='yellow';

% read and plot openface landmarks
of=readtable(['openface_examples' filesep 'singleframe.csv']);
figure(2); clf; imshow(inputimg); hold on;
f=1;
for idx=0:67 % openface indexing for 68 landmark points
    eval(['x=of.x_' num2str(idx) '(f);']);
    eval(['y=of.y_' num2str(idx) '(f);']);
    h=plot(x,y,'.'); h.MarkerSize=10; h.Color='yellow';
end
