%% Affine transformation test

I = checkerboard;

movingpoints=[1 1; 80 1; 1 80]; %Dove si trova la coda dei CPMV (ordine [x y])
fixedpoints=[1.5 1; 40 20; 1 80]; %Dove si trova la punta dei CPMV

tform = fitgeotrans(movingpoints,fixedpoints,"affine");

J=imwarp(I,tform);

imshow(J)