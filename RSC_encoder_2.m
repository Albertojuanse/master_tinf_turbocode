function [Output_bits] = RSC_encoder_2(Input_bits)
%RSC_ENCODER_1 Ecoders a matrix of 1xn input bits using a recursive
%sistematic convolutional encoder

Output_bits = mod( filter([1 1 0 1], [1 0 1 1], Input_bits),2 );

end