%% Turbo Code 
% Encoder: RSC (Recursive Systematic Convolution)
% Decoder: BCJR iterative decoder
% Author: Yogesh Soniwal
% Email: yogeshsoniwal@gmail.com
% Last Modified : 22nd October, 2013
% Architecture available on : 
% http://home.iitk.ac.in/~ysoniwal/Term_Paper_Reports/EE624.pdf

%% Parameter declaration
close all;clear all;clc;
N=1E4;                          %Block length
X=floor(2*rand(1,N));     	    %Information bit generation
Interleaver=randperm(N);   	    %Interleaver(random permutation of first N integers)
SNRdB=0:0.5:9;                  %SNR in dB
SNR=10.^(SNRdB/10);       	    %SNR in linear scale
Iteration=4;
ber=zeros(length(SNR),Iteration);     %Simulated BER(Each column corresponds to one iteration)
%% Encoding 
X_pi(1:N)=X(Interleaver(1:N));  %Interleaving input bits for RSC-1 encoder

C0=zeros(1,N);                  %Code Bit for encoder RSC-0
C1=zeros(1,N);                  %Code Bit for encoder RSC-1
for i=1:N
    k = i;
    while (k >= 1)
        C0(i) = xor ( C0(i),X(k) );
        C1(i) = xor ( C1(i),X_pi(k) );
        k=k-2;
    end
end
P0 = xor (X,[0,C0(1:end-1)]);
P1 = xor (X_pi,[0,C1(1:end-1)]);

Input_matrix=2*[0,1;0,1;0,1;0,1]-1;            %First column represents input=0 and second column represents input=1
%Each row represents state 00,10,01 and 11 respectively
Parity_bit_matrix=2*[0,1;1,0;0,1;1,0]-1;       %Parity bits corresponding to inputs of above matrix

mod_code_bit0=2*X-1;        %Modulating Code Bits using BPSK Modulation
mod_code_bit1=2*P0-1;
mod_code_bit2=2*P1-1;

% dlg = ProgressDialog();
% dlg.FractionComplete = 0;
% dlg.StatusMessage = sprintf('Encoding completed...');
%% Decoding
for k = 1:length(SNR)         %Simulation starts here
    R0=sqrt(SNR(k))*mod_code_bit0+randn(1,N);   % Received Codebits Corresponding to input bits
    R1=sqrt(SNR(k))*mod_code_bit1+randn(1,N);   % Received Codebits Corresponding to parity bits of RSC-0
    R2=sqrt(SNR(k))*mod_code_bit2+randn(1,N);   % Received Codebits Corresponding to parity bits of RSC-1
    
    R0_pi(1:N)=R0(Interleaver(1:N));              %Interleaving received codebits corresponding to input bits to be used by RSC-1
    
    BCJR=0;                     %First iteration will be done by BCJR-0
    
    Apriori=ones(2,N);          %First row for prob. of i/p 0 and second row for prob. of i/p 1
    Apriori=Apriori*0.5;        %Initializing all apriori to 1/2
    
    for iter=1:Iteration        %Iterative process starts here
        
        if BCJR==0      %If BCJR is 0 then pass R0 and R1 to calculate GAMMA
            GAMMA=gamma_1(Apriori,N,Input_matrix,Parity_bit_matrix,R0,R1,SNR(k));
        else            %If BCJR is 1 then pass R0_pi and R2 to calculate GAMMA
            GAMMA=gamma_1(Apriori,N,Input_matrix,Parity_bit_matrix,R0_pi,R2,SNR(k));
        end
        
        ALPHA=alpha_1(GAMMA,N); %Calculation of ALPHA at each stage using GAMMA and ALPHA of previous stage
        BETA=beta_1(GAMMA,N);   %Calculation of BETA at each stage using GAMMA and BETA of next stage
        
        %Calculating LAPPR using ALPHA,BETA and GAMMA
        [~,~,LAPPR_1]=lappr(ALPHA,BETA,GAMMA,N);
        
        decoded_bits=zeros(1,N);
        decoded_bits(LAPPR_1>0)=1;  %Decoding is done using LAPPR values
        
        if BCJR==0      %If the decoder is BCJR-0 then
            ber(k,iter)=sum(abs((decoded_bits-X)));     %calculate BER using input X
            lappr_2(1:N)=LAPPR_1(Interleaver(1:N));     %Interleave the LAPPR values and pass to BCJR-1
        else               %If the decoder is BCJR-1 then
            ber(k,iter)=sum(abs((decoded_bits-X_pi)));  %calculate BER using input X_pi
            lappr_2(Interleaver(1:N))=LAPPR_1(1:N);     %Re-interleave the LAPPR values and pass to BCJR-0
        end
        LAPPR_1=lappr_2;
        ber(ber==1)=0;                                   %Ignoring 1 bit error
        Apriori(1,1:N)=1./(1+exp(LAPPR_1));              %Apriori corresponding to input 0
        Apriori(2,1:N)=exp(LAPPR_1)./(1+exp(LAPPR_1));   %Apriori corresponding to input 1
        
        BCJR=~BCJR;   %Changing the state of the decoder for the next iteration
        
    end               %One iteration ends here
    u = round(k/length(SNR) * 100);
    % dlg.FractionComplete = k/length(SNR);
    % dlg.StatusMessage = sprintf('%d%% Decoding completed',u);
end
ber=ber/N;
figure;
%% Plots for simulated BER
% dlg.StatusMessage = sprintf('Done!');
semilogy(SNRdB,ber(:,1),'k--','linewidth',2.0);
hold on
semilogy(SNRdB,ber(:,2),'m-o','linewidth',2.0);
hold on
semilogy(SNRdB,ber(:,3),'b-<','linewidth',2.0);
hold on
semilogy(SNRdB,ber(:,4),'r-<','linewidth',2.0);
%% Theoretical expression for BER for corresponding convolution code
BER=zeros(1,length(SNR));
for j=1:10
    BER=BER+(2^j)*(j)*qfunc(sqrt((j+4)*SNR));
end
semilogy(SNRdB,BER,'c-','linewidth',2.0)
title('Turbo decoder performance over AWGN channel for BPSK modulated symbols');
xlabel('SNR(dB)');ylabel('BER');
legend('1st Iteration','2nd Iteration','3rd Iteration','4th Iteration','Theoretical Bound');
grid on
axis tight