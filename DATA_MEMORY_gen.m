%This script reads from file "matlab_examples-inventory.xlsx" informations
%about each test sequence and creats the memory file for each test sequence

firstfileNum=3;
lastfileNum=29;

examplesTab=readtable("./examples-tracking/matlab_examples-inventory.xlsx");

fid_top=fopen("../AME_Architecture/tb/memory/DATA_MEMORY_top.vhd");
fid_bottom=fopen("../AME_Architecture/tb/memory/DATA_MEMORY_bottom.vhd");
top_string=fscanf(fid_top,"%c");
bottom_string=fscanf(fid_bottom,"%c");

for curfileNum=firstfileNum:lastfileNum

    curExample_idx=curfileNum-fistfileNum+1;
    fid_mem=fopen(strcat("../AME_Architecture/tb/memory/DATA_MEMORY_ex",num2str(curfileNum),".vhd"),'W');    
    fprintf(fid_mem,"%c",top_string);
    fprintf(fid_mem,"\tconstant frame_w : integer := %d;\n",examplesTab.frame_w(curExample_idx));
    fprintf(fid_mem,"\tconstant frame_h : integer := %d;\n",examplesTab.frame_h(curExample_idx));
    fprintf(fid_mem,"\tconstant x0 : integer := %d;\n",examplesTab.x0(curExample_idx));
    fprintf(fid_mem,"\tconstant y0 : integer := %d;\n",examplesTab.y0(curExample_idx));
    fprintf(fid_mem,"%c",bottom_string);
    fclose(fid_mem);

end