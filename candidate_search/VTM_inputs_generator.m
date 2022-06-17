%This script

clear all

ThereAreFiles=1;
firstfileNum=3;%Nella mia cartella il primo file ha indice 3
curfileNum=firstfileNum;%The indentifier of the current file to be scanned
datastructCurIdx=curfileNum-firstfileNum+1; %Indipendentemente dal numero del primo file, la struttura datastruct parte sempre da indice 1
pathHead="..\AMC_examples_data\AMC_examples_data_ex";
pathTail=".xlsx";
curConstructed=0;%Informs if for the current example the constructor must be used or not

while ThereAreFiles
    curfileName=strcat(pathHead,num2str(curfileNum),pathTail);
    try curfileTab=readtable(curfileName);
        fid=fopen(strcat("C:\Users\costa\Desktop\5.2\Tesi\git\AME_Architecture\tb\VTM_inputs\VTM_inputs_ex",num2str(curfileNum),".txt"),'W');
        fprintf(fid,"%d %d\n",curfileTab.w(1),curfileTab.h(1));
        try
            [cMV0_h,cMV0_v,cMV1_h,cMV1_v,cMV2_h,cMV2_v,y,w,C]=runner(curFile);
            curConstructed=1;
        catch
            curConstructed=0;
        end
        curfilesixPar=curfileTab.sixPar(1);
        fprintf(fid,"%d %d\n",curConstructed,curfilesixPar);
        %IMPORTANTE, PRIMA DI ANDARE AVANTI
        %Assumo che nel file excel il primo candidato sia sempre quello del
        %VTM. Ho passato un'ora a sistemare i file excel, spero non mi sia
        %scappato nulla
        fprintf(fid,"%d %d\n",curfileTab.mv0_h(1),curfileTab.mv0_v(1));
        fprintf(fid,"%d %d\n",curfileTab.mv1_h(1),curfileTab.mv1_v(1));
        if curfilesixPar==1
            fprintf(fid,"%d %d\n",curfileTab.mv2_h(1),curfileTab.mv2_v(1));
        end
        if curConstructed==1 %If the constructor is need, write the cMVx
            for i=1:3
                fprintf(fid,"%d %d\n",cMV0_h(i),cMV0_v(i));
            end
            for i=1:2
                fprintf(fid,"%d %d\n",cMV1_h(i),cMV1_v(i));
            end
            for i=1:2
                fprintf(fid,"%d %d\n",cMV2_h(i),cMV2_v(i));
            end
        else%Otherwise, wrtie the other VTM candidate
            fprintf(fid,"%d %d\n",curfileTab.mv0_h(2),curfileTab.mv0_v(2));
            fprintf(fid,"%d %d\n",curfileTab.mv1_h(2),curfileTab.mv1_v(2));
            if curfilesixPar==1
                fprintf(fid,"%d %d\n",curfileTab.mv2_h(2),curfileTab.mv2_v(2));
            end
        end
        fclose(fid);
        curfileNum=curfileNum+1;
    catch
        ThereAreFiles=0;
    end
end