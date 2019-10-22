function [Output_bits] = RSC_encoder_1(Input_bits)
%RSC_ENCODER_1 Ecoders a matrix of 1xn input bits using a recursive
%sistematic convolutional encoder

N = size(Input_bits, 2);
C0=zeros(1,N);                  % Code Bit for encoder RSC-0
for i=1:N                       % Convolution
    k = i;
    while (k >= 1)
        C0(i) = xor ( C0(i),Input_bits(k) );
        k=k-2;
    end
end
Output_bits = xor (Input_bits,[0,C0(1:end-1)]);
end