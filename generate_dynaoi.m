function [dynaoi,landmarks]=generate_dynaoi(input_openface,options)
%function [dynaoi,landmarks]=generate_dynaoi(input_openface,options)
% 
% Generate dynamic areas areas of interest (AOIs) based on OpenFace
% face landmarks, with seven output AOIs. Assumes a single face covers
% most of the video/image area. Created especially for eye tracking
% experiments for defining dynamic video stimuli AOIs.
% 
% The AOIs are defined as Matlab polyshape variables, with the same pixel
% spacing as the input image / OpenFace output. The basic AOI definition is 
% based on OpenFace facial metrics. The eyebrow/eye area definitions use
% fixed values (default options.eye_top = 20, options.eyebrow_radius = 30)
% which were good for FullHD resolution (1920x1080) input video used 
% in the testing phase.
% 
% Output variables in dynaoi struct (defined for each input frame)
% aoi_leye, aoi_reye            - left and right eye AOI
% aoi_l_eyebrow, aoi_r_eyebrow  - left and right eyebrow AOI
% aoi_mouth                     - mouth AOI
% aoi_nose                      - nose AOI, triangle shaped
% aoi_forehead                  - forehead AOI
% 
% Optional landmarks output (eyes, forehead, mouth, nose), contains center
% points used in defining the AOIs. This might be good for debugging.
%
% Example function call:
%
% options.input_fps=50;
% [dynaoi,dynlm]=generate_dynaoi(['openface_output_for_vid1.csv'],options);
%
% Tested with Matlab R2020a & R2023b under Windows 11
%
% 2024-2025 Iterated code to work with several input videos
%           Code by Jaakko Kauramäki (jaakko.kauramaki@helsinki.fi)
% 
% License: GPL-3.0 (https://www.gnu.org/licenses/gpl-3.0.en.html)

if nargin<1
    error('openface input missing')
end

if nargin<2
    options.input_fps=25; % default FPS in case nothing is set
end

% some defaults in case not set (iterated good for 1920x1080 video)
% default eyebrow radius in pixels
if ~isfield(options,'eyebrow_radius'), options.eyebrow_radius = 30; end 
% default eye top "safe area"  (required especially in case face is tilted
% forward, so that eye brow AOIs do not overlap these)
if ~isfield(options,'eye_top'), options.eye_top = 20; end 

% read openface input (should result wide Nx714 table)
of_csv=readtable(input_openface);

dynaoi=struct();
landmarks=struct();

nframes=size(of_csv,1);
video_t=0;
video_fps=options.input_fps;

for f=1:nframes % loop through frames (if any)
    if of_csv.confidence(f)>0.5
        aoi_available=true;

        % eye, nose and mouth landmarks based on openface
        lm_l_eye=[mean([of_csv.x_37(f) of_csv.x_38(f) of_csv.x_40(f) of_csv.x_41(f)]) mean([of_csv.y_37(f) of_csv.y_38(f) of_csv.y_40(f) of_csv.y_41(f)])];
        lm_r_eye=[mean([of_csv.x_43(f) of_csv.x_44(f) of_csv.x_46(f) of_csv.x_47(f)]) mean([of_csv.y_43(f) of_csv.y_44(f) of_csv.y_46(f) of_csv.y_47(f)])];
        lm_nose=[of_csv.x_30(f) of_csv.y_30(f)];
        lm_mouth=[mean([of_csv.x_62(f) of_csv.x_66(f)]) mean([of_csv.y_62(f) of_csv.y_66(f)])];

        % forehead landmark calculated based on openface metrics
        lm_forehead=[of_csv.x_27(f)+0.75*(of_csv.x_27(f)-of_csv.x_33(f)) of_csv.y_27(f)+0.75*(of_csv.y_27(f)-of_csv.y_33(f))]; 

        %[vx,vy]=voronoi([lm_l_eye(1) lm_r_eye(1) lm_nose(1) lm_mouth(1)],[lm_l_eye(2) lm_r_eye(2) lm_nose(2) lm_mouth(2)]);
        face_width=sqrt((of_csv.x_16(f)-of_csv.x_0(f))^2+(of_csv.y_16(f)-of_csv.y_0(f))^2); % calculate metrics
        %eye_dist=sqrt((lm_l_eye(1)-lm_r_eye(1))^2+(lm_l_eye(2)-lm_r_eye(2))^2); % calculate metrics
        % proportional face_height to help calculations
        face_height=sqrt((of_csv.x_8(f)-of_csv.x_27(f))^2+(of_csv.y_8(f)-of_csv.y_27(f))^2); % calculate metrics
        topface_height=sqrt((of_csv.x_33(f)-of_csv.x_27(f))^2+(of_csv.y_33(f)-of_csv.y_27(f))^2); % calculate metrics
        aoi_radius=0.33*face_width; % metrics based on face width
        face_angle=atan2(lm_r_eye(2)-lm_l_eye(2),lm_r_eye(1)-lm_l_eye(1));

        n = 100;
        theta = (0:n-1)*(2*pi/n);

        x = lm_l_eye(1) + aoi_radius*cos(theta);
        y = lm_l_eye(2) + aoi_radius*sin(theta);
        ps_leyec = polyshape(x,y);

        x = lm_r_eye(1) + aoi_radius*cos(theta);
        y = lm_r_eye(2) + aoi_radius*sin(theta);
        ps_reyec = polyshape(x,y);

        x = lm_mouth(1) + aoi_radius*cos(theta);
        y = lm_mouth(2) + aoi_radius*sin(theta);
        ps_mouth = polyshape(x,y);

        aoi_nose=polyshape([(of_csv.x_3(f)+of_csv.x_31(f))/2 (of_csv.x_27(f)+of_csv.x_28(f))/2 (of_csv.x_13(f)+of_csv.x_35(f))/2],...
            [(of_csv.y_3(f)+of_csv.y_31(f))/2 (of_csv.y_27(f)+of_csv.y_28(f))/2 (of_csv.y_13(f)+of_csv.y_35(f))/2]);
        aoi_tmp_leye=polyshape([(of_csv.x_27(f)+of_csv.x_28(f))/2 (of_csv.x_3(f)+of_csv.x_31(f))/2 (of_csv.x_3(f)+of_csv.x_31(f))/2-face_width (of_csv.x_3(f)+of_csv.x_31(f))/2-face_width (of_csv.x_27(f)+of_csv.x_28(f))/2+(of_csv.x_27(f)-of_csv.x_8(f))],...
            [(of_csv.y_27(f)+of_csv.y_28(f))/2 (of_csv.y_3(f)+of_csv.y_31(f))/2 of_csv.y_0(f)+face_height*1.5 of_csv.y_27(f)-(of_csv.y_8(f)-of_csv.y_27(f)) of_csv.y_27(f)-(of_csv.y_8(f)-of_csv.y_27(f))]);
        aoi_tmp_reye=polyshape([(of_csv.x_13(f)+of_csv.x_35(f))/2 (of_csv.x_27(f)+of_csv.x_28(f))/2 (of_csv.x_27(f)+of_csv.x_28(f))/2+(of_csv.x_27(f)-of_csv.x_8(f)) (of_csv.x_13(f)+of_csv.x_35(f))/2+face_width (of_csv.x_13(f)+of_csv.x_35(f))/2+face_width ],...
            [(of_csv.y_13(f)+of_csv.y_35(f))/2 (of_csv.y_27(f)+of_csv.y_28(f))/2 of_csv.y_27(f)-(of_csv.y_8(f)-of_csv.y_27(f)) of_csv.y_27(f)-(of_csv.y_8(f)-of_csv.y_27(f)) of_csv.y_16(f)+face_height*1.5 ]);
        aoi_tmp_mouth=polyshape([(of_csv.x_3(f)+of_csv.x_31(f))/2 (of_csv.x_13(f)+of_csv.x_35(f))/2 (of_csv.x_13(f)+of_csv.x_35(f))/2+face_width (of_csv.x_3(f)+of_csv.x_31(f))/2-face_width],...
            [(of_csv.y_3(f)+of_csv.y_31(f))/2 (of_csv.y_13(f)+of_csv.y_35(f))/2 of_csv.y_16(f)+face_height*1.5 of_csv.y_0(f)+face_height*1.5]);

        aoi_leye=intersect(ps_leyec,aoi_tmp_leye);
        aoi_reye=intersect(ps_reyec,aoi_tmp_reye);
        aoi_mouth=intersect(ps_mouth,aoi_tmp_mouth);

        % create AOIs for left and right eyebrows vs. eye

        l_eyebrow_points=[17 18 19 20 21]; % l eyebrow
        r_eyebrow_points=[22 23 24 25 26]; % r eyebrow
        l_eye_points=[36 37 38 39 40 41]; % contour of l eye
        r_eye_points=[42 43 44 45 46 47]; % contour of r eye
        % left eyebrow
        x=zeros(1,numel(l_eyebrow_points)); y=zeros(1,numel(l_eyebrow_points));
        for jj=1:numel(l_eyebrow_points)
            eval(['x(jj)=of_csv.x_' num2str(l_eyebrow_points(jj)) '(f);']);
            eval(['y(jj)=of_csv.y_' num2str(l_eyebrow_points(jj)) '(f);']);
        end
        aoi_tmp_l_eyebrow=polybuffer([x' y'],'lines',options.eyebrow_radius); % fixed width, default 30 px
        aoi_eyebrow_top_x=[x(1)-face_width/4 x(1)-face_width/4 x]; 
        aoi_eyebrow_top_y=[y(1)-round(options.eyebrow_radius/2)-face_height/2 y(1)-round(options.eyebrow_radius/2) y-round(options.eyebrow_radius/2)]; 

        x=zeros(1,numel(l_eye_points)); y=zeros(1,numel(l_eye_points));
        for jj=1:numel(l_eye_points)
            eval(['x(jj)=of_csv.x_' num2str(l_eye_points(jj)) '(f);']);
            eval(['y(jj)=of_csv.y_' num2str(l_eye_points(jj)) '(f);']);
        end
        aoi_tmp_l_eye_points=polybuffer([x' y'],'lines',options.eye_top); % fixed width for top of the eye, default 20 px
        aoi_l_eyebrow=subtract(aoi_tmp_l_eyebrow,aoi_tmp_l_eye_points); % subtract eye area just to be on the safe side
        aoi_l_eyebrow=subtract(aoi_l_eyebrow,aoi_reye); % subtract eye area just to be on the safe side

        % right eyebrow
        x=zeros(1,numel(r_eyebrow_points)); y=zeros(1,numel(r_eyebrow_points));
        for jj=1:numel(r_eyebrow_points)
            eval(['x(jj)=of_csv.x_' num2str(r_eyebrow_points(jj)) '(f);']);
            eval(['y(jj)=of_csv.y_' num2str(r_eyebrow_points(jj)) '(f);']);
        end
        aoi_tmp_r_eyebrow=polybuffer([x' y'],'lines',options.eyebrow_radius); % fixed width, default 30 px

        aoi_eyebrow_top_x=[aoi_eyebrow_top_x x x(end)+face_width/4 x(end)+face_width/4]; 
        aoi_eyebrow_top_y=[aoi_eyebrow_top_y y-round(options.eyebrow_radius/2) y(end)-round(options.eyebrow_radius/2) y(end)-round(options.eyebrow_radius/2)-face_height/2]; 
        aoi_eyebrow_top=polyshape(aoi_eyebrow_top_x,aoi_eyebrow_top_y);

        x=zeros(1,numel(r_eye_points)); y=zeros(1,numel(r_eye_points));
        for jj=1:numel(r_eye_points)
            eval(['x(jj)=of_csv.x_' num2str(r_eye_points(jj)) '(f);']);
            eval(['y(jj)=of_csv.y_' num2str(r_eye_points(jj)) '(f);']);
        end
        aoi_tmp_r_eye_points=polybuffer([x' y'],'lines',options.eye_top); % fixed width for top of the eye, default 20 px
        aoi_r_eyebrow=subtract(aoi_tmp_r_eyebrow,aoi_tmp_r_eye_points); % subtract eye area just to be on the safe side
        aoi_r_eyebrow=subtract(aoi_r_eyebrow,aoi_leye); % subtract eye area just to be on the safe side
        aoi_radius1=face_width/2;
        aoi_radius2=0.9*topface_height;
        n = 100;
        theta = (0:n-1)*(2*pi/n);

        x = lm_forehead(1) + aoi_radius1*cos(theta);
        y = lm_forehead(2) + aoi_radius2*sin(theta);
        aoi_forehead_tmp = polyshape(x,y);
        aoi_forehead=rotate(aoi_forehead_tmp,rad2deg(face_angle),lm_forehead);

        % update eye AOI based on these, subtract eyebrow AOIs
        aoi_leye=subtract(aoi_leye,aoi_l_eyebrow);
        aoi_reye=subtract(aoi_reye,aoi_r_eyebrow);

        % update eye AOIs based on top eyebrow here
        aoi_leye=subtract(aoi_leye,aoi_eyebrow_top);
        aoi_reye=subtract(aoi_reye,aoi_eyebrow_top);

        aoi_forehead=subtract(aoi_forehead,aoi_leye);
        aoi_forehead=subtract(aoi_forehead,aoi_l_eyebrow);
        aoi_forehead=subtract(aoi_forehead,aoi_reye);
        aoi_forehead=subtract(aoi_forehead,aoi_r_eyebrow);
        aoi_forehead=subtract(aoi_forehead,aoi_nose);

        dynaoi(f).aoi_leye=aoi_leye;
        dynaoi(f).aoi_reye=aoi_reye;
        dynaoi(f).aoi_l_eyebrow=aoi_l_eyebrow;
        dynaoi(f).aoi_r_eyebrow=aoi_r_eyebrow;
        dynaoi(f).aoi_mouth=aoi_mouth;
        dynaoi(f).aoi_nose=aoi_nose;
        dynaoi(f).aoi_forehead=aoi_forehead;

        % optional landmarks for plotting
        landmarks(f).lm_l_eye=lm_l_eye;
        landmarks(f).lm_r_eye=lm_r_eye;
        landmarks(f).lm_nose=lm_nose;
        landmarks(f).lm_mouth=lm_mouth;
        landmarks(f).lm_forehead=lm_forehead;
    else
        aoi_available=false;
    end
    dynaoi(f).aoi_available=aoi_available;
    dynaoi(f).video_t=video_t;
    video_t=video_t+1/video_fps;

end
