function coeffReq=dctCoeffNum(image,perc)

P=image;

%Compute the discrete cosine transform of the image data. Operate first along the rows and then along the columns.
Q = dct(P,[],1);
R = dct(Q,[],2);

%Find what fraction of DCT coefficients contain perc% of the energy in the image.
X = R(:);

[~,ind] = sort(abs(X),'descend');
coeffs = 1;
while norm(X(ind(1:coeffs)))/norm(X) < (perc/100)
   coeffs = coeffs + 1;
end

%The total number of coefficients in the dct
coeffNum=numel(R);
%The number of coefficients required to contain perc% of the energy in the image.
coeffReq=coeffs;
%fprintf('%d of %d coefficients are sufficient\n',coeffs,numel(R))