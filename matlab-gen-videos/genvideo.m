data = h5read('sub075_2drt_08_grandfather2_r1_recon.h5', '/recon');

FRAMERATE = 1000/(2*6.004);
v = VideoWriter("test_video.mj2", 'Motion JPEG 2000');
open(v)
for idx = 1:size(data,3)
   
    %writeVideo(v, flipud(transpose(data(:,:,idx))) / max(max(data(:,:,idx))));
    writeVideo(v, uint8(flipud(transpose(data(:,:,idx))) ./ max(max(data(:,:,idx))) * 255));
end
close(v)