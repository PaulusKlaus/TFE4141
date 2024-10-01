#include <stdio.h>
#include <math.h>

// Function to compute (base^exp) % mod using modular exponentiation
unsigned long long mod_exp(unsigned long long base, unsigned long long exp, unsigned long long mod) {
    unsigned long long result = 1;
    base = base % mod;
    while (exp > 0) {
        if (exp % 2 == 1) {
            result = (result * base) % mod;
        }
        exp = exp >> 1;   // Divide exp by 2
        base = (base * base) % mod;
    }
    return result;
}


// RSA encryption: C = (M^e) % n
unsigned long long rsa_encrypt(unsigned long long M, unsigned long long e, unsigned long long n) {
    return mod_exp(M, e, n);
}

// RSA decryption: M = (C^d) % n
unsigned long long rsa_decrypt(unsigned long long C, unsigned long long d, unsigned long long n) {
    return mod_exp(C, d, n);
}

int main() {
    unsigned long long M = 23456789;  // Example message
    unsigned long long e = 139;   // Example public exponent
    unsigned long long d = 5149171;  // Example private exponent (this should be calculated properly)
    unsigned long long n = 34094323; // Example modulus

    // Encrypt the message
    unsigned long long encrypted_message = rsa_encrypt(M, e, n);
    printf("Encrypted message: %llu\n", encrypted_message);

    // Decrypt the message
    unsigned long long decrypted_message = rsa_decrypt(encrypted_message, d, n);
    printf("Decrypted message: %llu\n", decrypted_message);

    return 0;
}
