%% AMC for canditates choice comparison 
%This scripts generates the output of the extimator to be used by the
%testbench

close all
clear

%Add the scripts folder to the MATLAB path
addpath '.\YUV'
addpath '.\myMatlabLib'

firstFile=3;
lastFile=32;

for curFile=firstFile:lastFile 
    
    %Load example data
    data=readtable(strcat('.\AMC_examples_data\AMC_examples_data_ex',num2str(curFile),'.xlsx'));
    
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
    writematrix(Curframe,strcat("C:\Users\costa\Desktop\5.2\Tesi\git\AME_Architecture\tb\memory_data\Curframe_ex",num2str(curFile),".txt"),'Delimiter',' ');
    %CU to be encoded
    %NOTA: In Matlab le immagini, se indicate come matrici di pixel, hanno gli
    %indici che si riferiscono prima alla coordinata y e poi alla x. Questo
    %perche' si mette sempre prima l'indice della riga e poi quello della
    %colonna!
    CurCu=Curframe((y0+1):(y0+h),(x0+1):(x0+w));
    
    %Reference frame extraction
    numfrm=1;
    startfrm=data.startfrm_ref(1);
    [Y]=yuv_import( char(data.file_ref(1)),[frame_w frame_h],numfrm,startfrm);
    Refframe=cell2mat(Y);
    writematrix(Refframe,strcat("C:\Users\costa\Desktop\5.2\Tesi\git\AME_Architecture\tb\memory_data\Refframe_ex",num2str(curFile),".txt"),'Delimiter',' ');
    %Same CU but from the reference frame
    % RefCu=Refframe((y0+1):(y0+h),(x0+1):(x0+w));
    % figure('Name','Same CU but from the reference frame')
    % colormap('gray');
    % image(RefCu)
    
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
    SAD_hw=zeros(cand_num,1);
    %Relative mv's (mvr) matrix
    %First index: Candidate identifier (da 1 a cand_num)
    %Second index: Representative identifier (da 1 a rep_num, typ: rep_num=4)
    %Third index: 16x16 block identifier (da 1 a block_num)
    %Fourth index: First coordinate: y [v], second coordinate: x [h]
    mvr=zeros(cand_num,rep_num,block_num,2);
    mvr_hw=zeros(cand_num,rep_num,block_num,2);
    %Exact values
    mvr_ex=mvr;
    mvr_ex_hw=mvr;

    fxp_prec=4;%Alla fine 4 ?? la precisione totale, non ho approssimato
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
                    a_1=(mv1_v(curcand)-mv0_v(curcand))/w; %a_v
                    a_2=(mv1_h(curcand)-mv0_h(curcand))/w; %a_h
                    a_1_hw=bitshift((mv1_v(curcand)-mv0_v(curcand)),-(log2(w)-4),'int16')/16; %a_v_hw
                    a_2_hw=bitshift((mv1_h(curcand)-mv0_h(curcand)),-(log2(w)-4),'int16')/16; %a_h_hw
                    if sixPar==0
                        b_1=+(mv1_h(curcand)-mv0_h(curcand))/w; %b_v
                        b_2=-(mv1_v(curcand)-mv0_v(curcand))/w; %b_h
                        b_1_hw=bitshift(+(mv1_h(curcand)-mv0_h(curcand)),-(log2(w)-4),'int16')/16; %b_v_hw
                        b_2_hw=-bitshift((mv1_v(curcand)-mv0_v(curcand)),-(log2(w)-4),'int16')/16; %b_h_hw
                    else
                        b_1=+(mv2_v(curcand)-mv0_v(curcand))/h; %b_v
                        b_2=+(mv2_h(curcand)-mv0_h(curcand))/h; %b_h
                        b_1_hw=bitshift(+(mv2_v(curcand)-mv0_v(curcand)),-(log2(h)-4),'int16')/16; %b_v_hw
                        b_2_hw=bitshift(+(mv2_h(curcand)-mv0_h(curcand)),-(log2(h)-4),'int16')/16; %b_h_hw
                    end
                    mvr_ex(curcand,currep,curbloc,1)=x*a_1 + y*b_1 + mv0_v(curcand); %mv_v exact
                    mvr_ex(curcand,currep,curbloc,2)=x*a_2 + y*b_2 + mv0_h(curcand); %mv_h exact
                    mvr_ex_hw(curcand,currep,curbloc,1)=x*a_1_hw + y*b_1_hw + mv0_v(curcand); %mv_v exact_hw
                    mvr_ex_hw(curcand,currep,curbloc,2)=x*a_2_hw + y*b_2_hw + mv0_h(curcand); %mv_h exact_hw
                    mvr(curcand,currep,curbloc,1)=round(mvr_ex(curcand,currep,curbloc,1)/16); %mv_v
                    mvr(curcand,currep,curbloc,2)=round(mvr_ex(curcand,currep,curbloc,2)/16); %mv_h
                    mvr_hw(curcand,currep,curbloc,1)=round(mvr_ex_hw(curcand,currep,curbloc,1)/16); %mv_v_hw
                    mvr_hw(curcand,currep,curbloc,2)=round(mvr_ex_hw(curcand,currep,curbloc,2)/16); %mv_h_hw
                    SAD(curcand)=SAD(curcand)+ sum( abs(Refframe((y0+1+y+mvr(curcand,currep,curbloc,1)):(y0+1+y+mvr(curcand,currep,curbloc,1)+3),(x0+1+x+mvr(curcand,currep,curbloc,2)):(x0+1+x+mvr(curcand,currep,curbloc,2)+3)) - CurCu(y+1:(y+4),x+1:(x+4))),'all');
                    SAD_hw(curcand)=SAD_hw(curcand)+ sum( abs(Refframe((y0+1+y+mvr_hw(curcand,currep,curbloc,1)):(y0+1+y+mvr_hw(curcand,currep,curbloc,1)+3),(x0+1+x+mvr_hw(curcand,currep,curbloc,2)):(x0+1+x+mvr_hw(curcand,currep,curbloc,2)+3)) - CurCu(y+1:(y+4),x+1:(x+4))),'all');
                end
            end
        end
    end
    
    %Results computation
    [SAD_min,Best_candidate]=min(SAD(1:2));
    SAD_max=max(SAD(1:2));
    SAD_adv=(1-SAD_min/SAD_max)*100;

    %Results computation (hardware)
    [SAD_min_hw,Best_candidate_hw]=min(SAD_hw(1:2));
    SAD_max_hw=max(SAD_hw(1:2));
    SAD_adv_hw=(1-SAD_min_hw/SAD_max_hw)*100;

    fid=fopen(strcat("C:\Users\costa\Desktop\5.2\Tesi\git\AME_Architecture\tb\extimator_out\extimator_out_ex",num2str(curFile),".txt"),'W');
    fprintf(fid,"%d %d\n",SAD_hw(1), SAD_hw(2));
	fprintf(fid,"%d %d\n%d %d\n", mv0_h(Best_candidate_hw),mv0_v(Best_candidate_hw),mv1_h(Best_candidate_hw),mv1_v(Best_candidate_hw));
    if sixPar==1
           fprintf(fid,"%d %d", mv2_h(Best_candidate_hw),mv2_v(Best_candidate_hw));
    end
	fclose(fid);

    if Best_candidate==Best_candidate_hw
        fprintf("Motion Estimation match in example %d.\tBest_candidate=%d\tBest_candidate_hw=%d.\n",curFile,Best_candidate,Best_candidate_hw);
    else
        fprintf("Motion Estimation MISmatch in example %d!!!\tBest_candidate=%d\tBest_candidate_hw=%d.\n",curFile,Best_candidate,Best_candidate_hw);
    end
end
