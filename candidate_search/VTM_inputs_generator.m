%This script

clear all

ThereAreFiles=1;
firstfileNum=3;%Nella mia cartella il primo file ha indice 3
curfileNum=firstfileNum;%The indentifier of the current file to be scanned
datastructCurIdx=curfileNum-firstfileNum+1; %Indipendentemente dal numero del primo file, la struttura datastruct parte sempre da indice 1
pathHead="..\AMC_examples_data\AMC_examples_data_ex";
pathTail=".xlsx";
curConstructed=0;%Informs if for the current example the constructor must be used or not

%Constructor data files
constrfileTab=readtable(".\construction_examples-hardware.xlsx");

while ThereAreFiles
    curfileName=strcat(pathHead,num2str(curfileNum),pathTail);
    try curfileTab=readtable(curfileName);
        fid=fopen(strcat("C:\Users\costa\Desktop\5.2\Tesi\git\AME_Architecture\tb\VTM_inputs\VTM_inputs_ex",num2str(curfileNum),".txt"),'W');
        fprintf(fid,"%d %d\n",curfileTab.w(1),curfileTab.h(1));
        %Check if the current example needs the constructor or not
        [needsConstructor,constrTab_idx]=ismember(curfileNum,constrfileTab.ExampleNum');
        if needsConstructor
            curConstructed=1;
        else
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
            fprintf(fid,"%d %d\n",constrfileTab.mv0_h_1(constrTab_idx),constrfileTab.mv0_v_1(constrTab_idx));
            fprintf(fid,"%d %d\n",constrfileTab.mv0_h_2(constrTab_idx),constrfileTab.mv0_v_2(constrTab_idx));
            fprintf(fid,"%d %d\n",constrfileTab.mv0_h_3(constrTab_idx),constrfileTab.mv0_v_3(constrTab_idx));
            fprintf(fid,"%d %d\n",constrfileTab.mv1_h_1(constrTab_idx),constrfileTab.mv1_v_1(constrTab_idx));
            fprintf(fid,"%d %d\n",constrfileTab.mv1_h_2(constrTab_idx),constrfileTab.mv1_v_2(constrTab_idx));
            fprintf(fid,"%d %d\n",constrfileTab.mv2_h_1(constrTab_idx),constrfileTab.mv2_v_1(constrTab_idx));
            fprintf(fid,"%d %d\n",constrfileTab.mv2_h_2(constrTab_idx),constrfileTab.mv2_v_2(constrTab_idx));
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