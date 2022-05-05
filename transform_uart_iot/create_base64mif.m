ADDR_WIDTH=6;
DATA_WIDTH=7;
depth=2^ADDR_WIDTH;
x=linspace(0,63,64);
y=zeros(1,64);
for i=1:64
   if(x(i)<=25)
       y(i)=x(i)+65;
   elseif(x(i)>25&&x(i)<=51)
       y(i)=x(i)+71;
   elseif(x(i)>51&&x(i)<=61)
       y(i)=x(i)-4;
   elseif(x(i)==62)
       y(i)=43;
   elseif(x(i)==63)
       y(i)=47;
   end
end
fid=fopen('base64_rom.mif','w');
fprintf(fid,'width=%d;\n',DATA_WIDTH);
fprintf(fid,'depth=%d;\n',depth);
fprintf(fid,'address_radix=uns;\n');
fprintf(fid,'data_radix=uns;\n');
fprintf(fid,'Content Begin\n');
for k=1:depth
    fprintf(fid,'%d:%d;\n',k-1,y(k));
end
fprintf(fid,'end;');