# Dynamic areas of interest (AOIs) based on OpenFace

To use dynamic areas of interest (AOIs) suitable for video stimuli for high quality gaze tracking, we quantified AOIs frame-by-frame using an automated labeling algorithm. The basis for this was usage of facial landmarks obtained by running OpenFace ([Baltrusaitis et al., 2018](#baltrusaitis-et-al); available from https://github.com/TadasBaltrusaitis/OpenFace ) for each stimulus video. This way, we could relatively efficiently quantify seven AOIs, depicted in Figure 1A. The AOI quantification was inspired by Voronoi tessellation-based AOI quantification ([Hessels et al., 2016](#hessels-et-al)), but here we aimed specifically to have more specific AOIs for eyebrows besides only eye-based AOIs. 

![Dynamic AOIs and openface landmarks overlaid on input stimuli](https://github.com/jkauramaki/dynamic_aoi/blob/main/figure1.png?raw=true)
Figure 1 A) Dynamic AOIs depicted in different colours, quantified for each frame. B) AOIs overlaid with OpenFace landmark points were used as the basis for AOI calculations. Based on landmark points, some additional temporary features and landmark points were quantified to aid AOI calculations.

![Example of dynamic AOIs on video stimuli](https://github.com/jkauramaki/dynamic_aoi/blob/main/output_with_overlay.gif?raw=true)

Tested with Matlab R2020a & R2023b under Windows 11. Usage: clone or download repository, run `example_singleframe.m` to test with the provided example frame, or alternatively run `example_video.m` to read an example input video and write the output (with AOIs and landmarks ovarlaid) to mp4 video file as well. To modify to work with your own stimuli, first run OpenFace on your stimulus file, load up resulting .csv file by passing it to `generate_dynaoi.m` (see code and examples for syntax).

## References
- <a name="baltrusaitis-et-al"></a>Baltrusaitis, T., Zadeh, A., Lim, Y. C., & Morency, L.-P. (2018). OpenFace 2.0: Facial Behavior Analysis Toolkit. 2018 13th IEEE International Conference on Automatic Face & Gesture Recognition (FG 2018), 59–66. https://doi.org/10.1109/FG.2018.00019
- <a name="hessels-et-al"></a>Hessels, R. S., Kemner, C., van den Boomen, C., & Hooge, I. T. C. (2016). The area-of-interest problem in eyetracking research: A noise-robust solution for face and sparse stimuli. Behavior Research Methods, 48(4), 1694–1712. https://doi.org/10.3758/s13428-015-0676-y
