% Overlay example video with AOIs and landmarks, show video time on top
% left corner, write output to output_with_overlay.mp4

options.input_fps=50;
[dynaoi,dynlm]=generate_dynaoi(['openface_examples' filesep 'video.csv'],options);

vidObj = VideoReader(['openface_examples' filesep 'video.mp4']);

vOut = VideoWriter('output_with_overlay.mp4','MPEG-4');
vOut.FrameRate=options.input_fps;
open(vOut)

for f=1:numel(dynaoi)
    if hasFrame(vidObj)
        figure(1); clf;
        vidFrame=readFrame(vidObj);
        imshow(vidFrame);
        hold on;
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
        ht=text(50,50,sprintf('t=%.2f s',(f-1)*1/options.input_fps)); ht.Color='white'; ht.FontSize=20;
        pause(0.1); % longer than real input video frame
        frame = getframe(gcf);
        writeVideo(vOut,frame)
    else
        disp('no more frames in the video')
    end
end

close(vOut);