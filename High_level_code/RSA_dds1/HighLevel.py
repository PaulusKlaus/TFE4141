def rsa_encrypt(M, e, n):
    # Encrypt the message M using the public key (e, n)
    C = pow(M, e, n) # (M^e) % n
    return C

def rsa_decrypt(C, d, n):
    # Decrypt the message C using the private key (d, n)
    M = pow(C, d, n) #(C^d) % n
    return M

# Example usage
if __name__ == "__main__":
    M = 23      # Example message
    e = 5       # Example public exponent
    d = 77      # Example private exponent (this should be calculated properly in a real scenario)
    n = 119     # Example modulus

    encrypted_message = rsa_encrypt(M, e, n)
    print(f"Encrypted message: {encrypted_message}")

    decrypted_message = rsa_decrypt(encrypted_message, d, n)
    print(f"Decrypted message: {decrypted_message}")