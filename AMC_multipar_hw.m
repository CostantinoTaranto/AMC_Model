%% AMC for canditates choice multiparameter model
%This model chooses between the different candidates the one whose SAD is
%lower than the others

close all
clear

%Add the scripts folder to the MATLAB path
addpath '.\YUV'
addpath '.\myMatlabLib'

%Acquire example name from input 
prompt = {'Enter example file path:'};
dlgtitle = 'Example file';
dims = [5 100];
definput = {'.\AMC_examples_data\AMC_examples_data_ex26.xlsx'};
examplefile = inputdlg(prompt,dlgtitle,dims,definput);

%Load example data
data=readtable(char(examplefile));

%fame parameters
frame_h=data.frame_h(1);
frame_w=data.frame_w(1);
sixPar=data.sixPar(1);

%Block parameters
w=data.w(1);
h=data.h(1);
x0=data.x0(1);
y0=data.y0(1);

%Raw image extraction
numfrm=1;%Extract just one frame
startfrm=data.startfrm_cur(1);  %POC of the current frame
[Y]=yuv_import( char(data.file_cur(1)),[frame_w frame_h],numfrm,startfrm);
Curframe=cell2mat(Y);
figure('Name','Frame to be encoded (original file)')
colormap('gray');
image(Curframe)
%CU to be encoded
%NOTA: In Matlab le immagini, se indicate come matrici di pixel, hanno gli
%indici che si riferiscono prima alla coordinata y e poi alla x. Questo
%perche' si mette sempre prima l'indice della riga e poi quello della
%colonna!
CurCu=Curframe((y0+1):(y0+h),(x0+1):(x0+w));
figure('Name','CU to be encoded (original file)')
colormap('gray');
image(CurCu)

%Reference frame extraction
numfrm=1;
startfrm=data.startfrm_ref(1);
[Y]=yuv_import( char(data.file_ref(1)),[frame_w frame_h],numfrm,startfrm);
Refframe=cell2mat(Y);
figure('Name','Reference frame (prev. frame from the encoded file)')
colormap('gray');
image(Refframe)
%Same CU but from the reference frame
% RefCu=Refframe((y0+1):(y0+h),(x0+1):(x0+w));
% figure('Name','Same CU but from the reference frame')
% colormap('gray');
% image(RefCu)

%Representative Blocks
figure('Name','Reference blocks highlighted (original file)')
colormap('gray');
image(CurCu)
hold on

for j=0:floor((h-1)/16) %Vertical control
    for i=0:floor((w-1)/16) %Horizontal control
        rectangle('Position',[0.5+16*i 0.5+16*j 4 4],'EdgeColor','r')   %Plot the first representative 4x4 block in a 16x16 block
        rectangle('Position',[(0.5+12)+16*i 0.5+16*j 4 4],'EdgeColor','r') %Plot the second representative 4x4 block in a 16x16 block
        rectangle('Position',[0.5+16*i (0.5+12)+16*j 4 4],'EdgeColor','r') %Plot the third representative 4x4 block in a 16x16 block
        rectangle('Position',[(0.5+12)+16*i (0.5+12)+16*j 4 4],'EdgeColor','r') %Plot the fourth representative 4x4 block in a 16x16 block
    end
end

%Plot the 16x16 blocks
for j=0:floor((h-1)/16) %Vertical control
    for i=0:floor((w-1)/16) %Horizontal control
        rectangle('Position',[0.5+16*i 0.5+16*j 16 16],'EdgeColor','b')   %Plot the first 4x4 block in a representative 16x16 block
    end
end

%Applico trasformazione affine "semplificata"

cand_num=data.cand_num(1); %Number of candidates

%Candidates MV and Refframe initialization
Refframe_AMC=zeros(frame_h,frame_w,cand_num);
mv0_v=zeros(cand_num,1);
mv0_h=zeros(cand_num,1);
mv1_v=zeros(cand_num,1);
mv1_h=zeros(cand_num,1);
mv2_v=zeros(cand_num,1);
mv2_h=zeros(cand_num,1);
for i=1:cand_num
    Refframe_AMC(:,:,i)=Refframe;	%Affine compensated reference frame
	%CPMV 4-parameter 
	mv0_v(i)=data.mv0_v(i);
	mv0_h(i)=data.mv0_h(i);
	mv1_v(i)=data.mv1_v(i);
	mv1_h(i)=data.mv1_h(i);
    %If CMPV 6-parameter, add MV2 too
    if sixPar==1
	    mv2_v(i)=data.mv2_v(i);
	    mv2_h(i)=data.mv2_h(i);
    end 
end


%Number of representatives in a 16x16 block
rep_num=4;
%Number of 16x16 blocks
block_num=(w*h)/256; %(Total n of pixels)/(pixels in a 16x16 block)
%SAD(n) contains the SAD for the n-th candidate
SAD=zeros(cand_num,1);
%Relative mv's (mvr) matrix
%First index: Candidate identifier (da 1 a cand_num)
%Second index: Representative identifier (da 1 a rep_num, typ: rep_num=4)
%Third index: 16x16 block identifier (da 1 a block_num)
%Fourth index: First coordinate: y [v], second coordinate: x [h]
mvr=zeros(cand_num,rep_num,block_num,2);
%Exact values
mvr_ex=mvr;

fxp_prec=4;%Alla fine 4 è la precisione totale, non ho approssimato
%con 3 anche se avrei potuto per motivi spiegati nel datapath


for curcand=1:cand_num
    curbloc=0; %Current block index
    %Motion vector matrices
    for j=1:(h/16) %Vertical control
        for i=1:(w/16) %Horizontal control
            curbloc=curbloc+1;
            for currep=1:rep_num
                %Compute x and y coordinates of the current block
                offset_x=0;
                if mod(currep,2)==0
                    offset_x=12;
                end
                offset_y=0;
                if currep>2
                    offset_y=12;
                end
                x=16*(i-1)+offset_x;
                y=16*(j-1)+offset_y;
                a_1=bitshift((mv1_v(curcand)-mv0_v(curcand)),-(log2(w)-4),'int16')/16; %a_v_hw
                a_2=bitshift((mv1_h(curcand)-mv0_h(curcand)),-(log2(w)-4),'int16')/16; %a_h_hw
                if sixPar==0
                    b_1=bitshift(+(mv1_h(curcand)-mv0_h(curcand)),-(log2(w)-4),'int16')/16; %b_v_hw
                    b_2=-bitshift((mv1_v(curcand)-mv0_v(curcand)),-(log2(w)-4),'int16')/16; %b_h_hw
                else
                    b_1=bitshift(+(mv2_v(curcand)-mv0_v(curcand)),-(log2(h)-4),'int16')/16; %b_v_hw
                    b_2=bitshift(+(mv2_h(curcand)-mv0_h(curcand)),-(log2(h)-4),'int16')/16; %b_h_hw
                end
                mvr_ex(curcand,currep,curbloc,1)=x*a_1 + y*b_1 + mv0_v(curcand); %mv_v exact_hw
                mvr_ex(curcand,currep,curbloc,2)=x*a_2 + y*b_2 + mv0_h(curcand); %mv_h exact_hw
                mvr(curcand,currep,curbloc,1)=round(mvr_ex(curcand,currep,curbloc,1)/16); %mv_v_hw
                mvr(curcand,currep,curbloc,2)=round(mvr_ex(curcand,currep,curbloc,2)/16); %mv_h_hw
                SAD(curcand)=SAD(curcand)+ sum( abs(Refframe((y0+1+y+mvr(curcand,currep,curbloc,1)):(y0+1+y+mvr(curcand,currep,curbloc,1)+3),(x0+1+x+mvr(curcand,currep,curbloc,2)):(x0+1+x+mvr(curcand,currep,curbloc,2)+3)) - CurCu(y+1:(y+4),x+1:(x+4))),'all');
                %Copy the original position of each block (graphical
                %reference)
                Refframe_AMC((y0+1+y):(y0+1+y+3),(x0+1+x):(x0+1+x+3),curcand)=CurCu(y+1:(y+4),x+1:(x+4));
            end
        end
    end
end

%Plot the CurCu and the AMC connected by a red line
for curcand=1:cand_num
    curbloc=0;
    s1='AMC for candidate number:';
    s2=num2str(curcand);
    figure('Name',strcat(s1,s2))
    colormap('gray')
    image(Refframe_AMC(:,:,curcand))
    rectangle('Position',[(x0+0.5),(y0+0.5) w h],'EdgeColor','b')   %Plot the first 4x4 block in a representative 16x16 block
    for j=0:floor((h-1)/16) %Vertical control
        for i=0:floor((w-1)/16) %Horizontal control
			curbloc=curbloc+1;
			for currep=1:rep_num
				offset_x=0;
                if mod(currep,2)==0
                    offset_x=12;
                end
				offset_y=0;
                if currep>2
                    offset_y=12;
                end
				%First representative 4x4 block in a 16x16 block
				first_edge_x=0.5+offset_x+16*i+x0;   %First (in alto a sx) edge of the Refframe's CurCu coordinates
				first_edge_y=0.5+offset_y+16*j+y0;
				first_edge_AMC_x=first_edge_x+mvr(curcand,currep,curbloc,2); %First (in alto a sx) edge of the Refframe's CurCu coordinates when AMC is applied
				first_edge_AMC_y=first_edge_y+mvr(curcand,currep,curbloc,1);
				rectangle('Position',[first_edge_x first_edge_y 4 4],'EdgeColor','r')
				rectangle('Position',[first_edge_AMC_x first_edge_AMC_y 4 4],'EdgeColor','g')   
				line([first_edge_x+2,first_edge_AMC_x+2],[first_edge_y+2,first_edge_AMC_y+2],'Color','red')
			end
        end
    end
end

%Results computation
[SAD_min,Best_candidate]=min(SAD(1:2));
SAD_max=max(SAD(1:2));
SAD_adv=(1-SAD_min/SAD_max)*100;

msgbox({'Best Candidate';num2str(Best_candidate);'SAD Advantage';strcat(num2str(SAD_adv,'%.2f'),'%')})

%Check if the VQ_best is different from the Matlab chosen one. If yes,
%perform the comparison
if isfield(table2struct(data),'VQ_best')
    VQ_best=data.VQ_best(1);
    if VQ_best~=Best_candidate

        comp_offs_y(1)=data.comp_offs_y(Best_candidate);
        comp_offs_x(1)=data.comp_offs_x(Best_candidate);
        comp_offs_y(2)=data.comp_offs_y(VQ_best);
        comp_offs_x(2)=data.comp_offs_x(VQ_best); 

        mv0_h_comp=[mv0_h(Best_candidate) mv0_h(VQ_best)];
        mv0_v_comp=[mv0_v(Best_candidate) mv0_v(VQ_best)];
        mv1_h_comp=[mv1_h(Best_candidate) mv1_h(VQ_best)];
        mv1_v_comp=[mv1_v(Best_candidate) mv1_v(VQ_best)];
        mv2_h_comp=[mv2_h(Best_candidate) mv2_h(VQ_best)];
        mv2_v_comp=[mv2_v(Best_candidate) mv2_v(VQ_best)];
        
        [coeffReq,nonZero,nonZero_gt10] = residual_compare(Refframe,CurCu,sixPar,mv0_h_comp, mv0_v_comp,mv1_h_comp, mv1_v_comp,mv2_h_comp, mv2_v_comp, comp_offs_x, comp_offs_y)
        SAD_Ratio=SAD(Best_candidate)/SAD(VQ_best)
    end
end 