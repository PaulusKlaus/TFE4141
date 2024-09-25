#include <stdio.h>
#include <math.h>
#include <string.h>

#define MAX_BITS 64
typedef unsigned long long bits_64;

bits_64 rsa_encrypt(bits_64 M, bits_64 e, bits_64 n);
bits_64 rsa_decrypt(bits_64 C, bits_64 d, bits_64 n);
bits_64 mod_exp(bits_64 base, bits_64 exp, bits_64 mod);
bits_64 multiply_mod(bits_64 A, bits_64 B, bits_64 n);

// RSA encryption: C = (M^e) % n
bits_64 rsa_encrypt(bits_64 M, bits_64 e, bits_64 n) {
    return mod_exp(M, e, n);
}

// RSA decryption: M = (C^d) % n
bits_64 rsa_decrypt(bits_64 C, bits_64 d, bits_64 n) {
    return mod_exp(C, d, n);
}

bits_64 mod_exp(bits_64 base, bits_64 exp, bits_64 mod) {
    bits_64 C = 1;
    bits_64 P = base;
    while (exp > 0) {
        if (exp & 1) {  // Check if the lowest bit is 1
            C = multiply_mod(C,P,mod);
        }
        P = multiply_mod(P,P,mod);
        exp >>= 1;      // Right shift exp by 1 to process the next bit
    }
    return C;
}

bits_64 multiply_mod(bits_64 A, bits_64 B, bits_64 n){
   bits_64 R = 0;
    for(int i = MAX_BITS-1; i >= 0; i--){
        R = (R << 1);  // Equivalent to 2R
   
        // Check if the i-th bit of B is set
        if (B & (1ULL << i)) {
            R = R + A;
        }

        // Perform interleaved reduction
        if(R > n){
            R = R - n;
        }
        if(R > n){
            R = R - n;
        }
    }
    return R;
}


int main() {
    bits_64 M = 2235;  
    bits_64 e = 17;              
    bits_64 d = 8293;             
    bits_64 n = 141913;           

    // Encrypt the message
    bits_64 encrypted_message = rsa_encrypt(M, e, n);
    printf("Encrypted message: %llu\n", encrypted_message);

    // Decrypt the message
    bits_64 decrypted_message = rsa_decrypt(encrypted_message, d, n);
    //printf("Decrypted message: %s\n", (char*)decrypted_message);    // String, not working
    //printf("Decrypted message: %c\n", (char)decrypted_message);   // Character
    printf("Decrypted message: %llu\n", decrypted_message); // Number

    return 0;
}
