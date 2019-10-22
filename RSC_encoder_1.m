function [P0, P1] = RSC_encoder_1(N, X, X_pi, Interleaver)
%RSC_ENCODER_1 Ecoders a matrix of 1xn input bits using a recursive
%sistematic convolutional encoder

X_pi(1:N)=X(Interleaver(1:N));  %Interleaving input bits for RSC-1 encoder
C0=zeros(1,N);                  % Code Bit for encoder RSC-0
C1=zeros(1,N);                  % Code Bit for encoder RSC-1
for i=1:N                       % Convolution
    k = i;
    while (k >= 1)
        C0(i) = xor ( C0(i),X(k) );
        C1(i) = xor ( C1(i),X_pi(k) );
        k=k-2;
    end
end
P0 = xor (X,[0,C0(1:end-1)]);
P1 = xor (X_pi,[0,C1(1:end-1)]);
end