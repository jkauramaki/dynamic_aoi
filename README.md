# dynamic_aoi
Dynamic areas of interest (AOI) based on OpenFace

To use dynamic areas of interest (AOIs) suitable for video stimuli for high quality gaze tracking, we quantified AOIs frame-by-frame using an automated labeling algorithm. The basis for this was usage of facial landmarks obtained by running OpenFace (Baltrusaitis et al., 2018; available from https://github.com/TadasBaltrusaitis/OpenFace ) for each stimulus video. This way, we could relatively efficiently quantify seven AOIs, depicted in Figure 1A. The AOI quantification was inspired by Voronoi tessellation-based AOI quantification (Hessels et al., 2016), but here we aimed specifically to have more specific AOIs for eyebrows besides only eye-based AOIs. 
