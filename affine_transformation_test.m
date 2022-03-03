%% Affine transformation test

I = checkerboard;

movingpoints=[1 1; 80 1; 1 80];
fixedpoints=[1 1; 40 20; 1 80];

tform = fitgeotrans(movingpoints,fixedpoints,"affine");

J=imwarp(I,tform);

imshow(J)