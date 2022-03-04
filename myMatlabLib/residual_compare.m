function [coeffReq,nonZero] = residual_compare(Refframe,CurCu, sixPar, mv0_h, mv0_v, mv1_h, mv1_v, mv2_h, mv2_v)

%mvi_(v,h) sono i CPMV del
% 1: Miglior candidato secondo il mio algoritmo
% 2: Miglior candidato secondo il VTM

if sixPar==0
    mv2_h=zeros(2,1);
    mv2_v=zeros(2,1);
end

%Convert the CurCu into image in order to transform it
CurCu_imm=mat2gray(CurCu,[0 255]);
[CurCu_h,CurCu_w]=size(CurCu_imm);

for i=1:2
    movingpoints=[1 1; CurCu_w 1; 1 CurCu_h]; %Dove si trova la coda dei CPMV (ordine [x y])
    fixedpoints=[1+mv0_h(i)/16 1+mv0_v(i)/16; CurCu_w+mv1_h(i)/16 1+mv1_v(i)/16; 1+mv2_h(i)/16 CurCu_h+mv2_v(i)/16]; %Dove si trova la punta dei CPMV
    
    tform = fitgeotrans(movingpoints,fixedpoints,"affine");
    
    CurCu_tran_imm=imwarp(CurCu_imm,tform);
    %Memorize separatedly the two CurCu tranformed. I cannot use
    %a 3-D matrix because the dimension of the two immages may be different
    if i==1
        CurCu_tran_1=CurCu_tran_imm*255;
    else
        CurCu_tran_2=CurCu_tran_imm*255;
    end
end

%% Matlab candidate residual computation
figure('Name','Transformation with Matlab Candidate')
colormap('gray')
image(CurCu_tran_1)

%Fill the black squares with the values from the reference frame
[CurCu_AMC_1_h,CurCu_AMC_1_w]=size(CurCu_tran_1);
CurCu_AMC_1=CurCu_tran_1;
RefCu_1=zeros(CurCu_AMC_1_h,CurCu_AMC_1_w);

for j=1:(CurCu_AMC_1_h)%Scorri righe
    for i=1:(CurCu_AMC_1_w)%Scorri colonne
        if CurCu_AMC_1(j,i)==0
            CurCu_AMC_1(j,i)=Refframe(j+89,i+203);
        end
            RefCu_1(j,i)=Refframe(j+89,i+203);
    end
end

figure('Name','AMC with Matlab Candidate')
colormap('gray')
image(CurCu_AMC_1)

%Compute the residual
Residual_1=abs(CurCu_AMC_1-RefCu_1);
figure('Name','Residual with Matlab Candidate')
colormap('gray')
image(Residual_1)

%Compute what fraction of DCT coefficients contain 99% of the energy in the image
coeffReq(1)=dctCoeffNum(Residual_1,99);
%Number of nonzero elements
nonZero(1)=nnz(Residual_1);

%% VTM candidate residual computation
figure('Name','Transformation with VTM Candidate')
colormap('gray')
image(CurCu_tran_2)

%Fill the black squares with the values from the reference frame
[CurCu_AMC_2_h,CurCu_AMC_2_w]=size(CurCu_tran_2);
CurCu_AMC_2=CurCu_tran_2;
RefCu_2=zeros(CurCu_AMC_2_h,CurCu_AMC_2_w);

for j=1:(CurCu_AMC_2_h)%Scorri righe
    for i=1:(CurCu_AMC_2_w)%Scorri colonne
        if CurCu_AMC_2(j,i)==0
            CurCu_AMC_2(j,i)=Refframe(j+88,i+204);
        end
            RefCu_2(j,i)=Refframe(j+88,i+204);
    end
end

figure('Name','AMC with VTM Candidate')
colormap('gray')
image(CurCu_AMC_2)

%Compute the residual
Residual_2=abs(CurCu_AMC_2-RefCu_2);
figure('Name','Residual with VTM Candidate')
colormap('gray')
image(Residual_2)

%Compute what fraction of DCT coefficients contain 99% of the energy in the image
coeffReq(2)=dctCoeffNum(Residual_2,99);
nonZero(2)=nnz(Residual_2);

        