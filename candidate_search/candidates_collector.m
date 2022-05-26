%% Inventory update
%Questo script scansiona tutti i file degli esempi nella cartella
%"infinite_precision_constructor" e memorizza alcune informazioni in un unico file, il
%file "constructor_examples-inventory.xlsx"

clear all

%Acquire the last example number
prompt = {'Enter the last example number:'};
dlgtitle = 'Example file limit';
dims = [5 100];
definput = {'29'};
inputdata = inputdlg(prompt,dlgtitle,dims,definput);

%Load example data
lastFileNum=str2num(cell2mat(inputdata));

datastructCurIdx=1; %Indipendentemente dal numero del primo file, la struttura datastruct parte sempre da indice 1


for curFile=1:lastFileNum
    
    try
        [mv0_h,mv0_v,mv1_h,mv1_v,mv2_h,mv2_v,y,w,C]=runner(curFile);
        %Estrai informazioni dal file corrente e aggiungile alla struttura
        datastruct(datastructCurIdx).ExampleNum=curFile;
        datastruct(datastructCurIdx).mv0_h=mv0_h;
        datastruct(datastructCurIdx).mv0_v=mv0_v;
        datastruct(datastructCurIdx).mv1_h=mv1_h;
        datastruct(datastructCurIdx).mv1_v=mv1_v;
        datastruct(datastructCurIdx).mv2_h=mv2_h;
        datastruct(datastructCurIdx).mv2_v=mv2_v;
        datastruct(datastructCurIdx).h=y;
        datastruct(datastructCurIdx).w=w;
        %Estratte le informazioni, aumenta gli indici e passa al prossimo
        %file
        datastructCurIdx=datastructCurIdx+1;
        fprintf("Data of the File number %d extracted.\n",curFile);
    catch
        fprintf("File number %d missing.\n",curFile);
    end
end

fprintf("Scansione terminata, sono stati scansionati %d files.\n",datastructCurIdx-1);
datatable=struct2table(datastruct);
writetable(datatable,"construction_examples-inventory.xlsx");
