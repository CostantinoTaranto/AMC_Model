%% Inventory update
%Questo script scansiona tutti i file degli esempi nella carte
%"AMC_examples_data" e memorizza alcune informazioni in un unico file, il
%file "matlab_examples-inventory.xlsx"

clear all

ThereAreFiles=1;
firstfileNum=3;%Nella mia cartella il primo file ha indice 3
curfileNum=firstfileNum;%The indentifier of the current file to be scanned
datastructCurIdx=curfileNum-firstfileNum+1; %Indipendentemente dal numero del primo file, la struttura datastruct parte sempre da indice 1
pathHead="..\AMC_examples_data\AMC_examples_data_ex";
pathTail=".xlsx";

while ThereAreFiles
    curfileName=strcat(pathHead,num2str(curfileNum),pathTail);
    try curfileTab=readtable(curfileName);
        %Estrai informazioni dal file corrente e aggiungile alla struttura
        datastruct(datastructCurIdx).ExampleNum=curfileNum;
        datastruct(datastructCurIdx).Stream=curfileTab.file_cur(1);
        datastruct(datastructCurIdx).POC_Cur=curfileTab.startfrm_cur(1);
        datastruct(datastructCurIdx).x0=curfileTab.x0(1);
        datastruct(datastructCurIdx).y0=curfileTab.y0(1);
        datastruct(datastructCurIdx).Par=4+2*curfileTab.sixPar(1);
        %Estratte le informazioni, aumenta gli indici e passa al prossimo
        %file
        datastructCurIdx=datastructCurIdx+1;
        curfileNum=curfileNum+1;
    catch
        ThereAreFiles=0;
    end
end

fprintf("Scansione terminata, sono stati scansionati %d files.\n",datastructCurIdx-1);
datatable=struct2table(datastruct);
writetable(datatable,"matlab_examples-inventory.xlsx");
