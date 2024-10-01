import random
import time

def modpow(base, exp, mod):
    """
    Efficient modular exponentiation using the optimized modular multiplication.
    This function computes (a^b) % n using repeated squaring and interleaved reduction.
    """
    C = 1
    P = base  # Initialize P

    while exp > 0:
        if exp % 2 == 1:  # If the current bit of b is 1
            C = modular_multiplication(C, P, mod)  # Use modular multiplication instead of direct multiplication
        P = modular_multiplication(P, P, mod)  # Square P for the next iteration
        exp //= 2  # Shift b to the right to process the next bit

    return C

def modular_multiplication(a, b, n):
    """
    Efficient modular multiplication using the paper and pencil method.
    This function computes (a * b) % n using interleaved reduction.
    """
    R = 0  # Initial value for partial sum
    k = b.bit_length()  # Number of bits in b

    for i in range(k - 1, -1, -1):  # Iterate from the most significant bit to the least
        R = R << 1  # Double the current result using left shift
        if (b >> i) & 1:  # If the i-th bit of b is 1
            R = R + a
        
        # Perform reduction: keep R in the range [0, N-1] with at most two subtractions
        if R >= n:
            R = R - n
        if R >= n:
            R = R - n

    return R



def encodeBlock(m, e, n):
    """Encodes a message block m using the public exponent e and modulus n."""
    return modpow(m, e, n)

def decodeBlock(c, d, n):
    """Decodes a cryptogram block c using the private exponent d and modulus n."""
    return modpow(c, d, n)

def encodeMessage(message, bytes_per_block, exponent, modulus):
    """Encodes the message using the public key (exponent, modulus) block by block."""
    encoded = []
    size = len(message)
    for i in range(0, size, bytes_per_block):
        block = message[i:i+bytes_per_block]
        # Convert the block of bytes into an integer for encryption
        x = sum(block[j] * (1 << (7 * j)) for j in range(len(block)))
        encoded_value = encodeBlock(x, exponent, modulus)
        encoded.append(encoded_value)

    return encoded

def decodeMessage(cryptogram, bytes_per_block, exponent, modulus):
    """Decodes the cryptogram using the private key (exponent, modulus) block by block."""
    decoded = []
    for c in cryptogram:
        # Decode the integer back into the original byte block
        x = decodeBlock(c, exponent, modulus)
        decoded_block = [(x >> (7 * j)) % 128 for j in range(bytes_per_block)]
        decoded.extend(decoded_block)
    # Convert decoded bytes back to a string, ignoring non-printable characters
    decoded_message = bytes(decoded).decode('utf-8', errors='ignore')
    return decoded_message

def main():
    # We have a 
    # M - message 
    # e - public exponent
    # n - modulus
    # d - private exponent

    e = 379
    n = 67742959
    d = 36096899


    # Determine the block size for encoding based on modulus size
    if n >> 21:
        bytes_per_block = 3
    elif n >> 14:
        bytes_per_block = 2
    else:
        bytes_per_block = 1

    M = "This is a 256-bit long message!".encode('utf-8')

    # Encode the message using the public key
    encoded = encodeMessage(M, bytes_per_block, e, n)
    print("\nEncoded message successfully!")

    # Decode the message using the private key
    decoded = decodeMessage(encoded, bytes_per_block, d, n)
    print(f"Decoded message: {decoded}")  # Print the decoded message

    print("\nFinished RSA demonstration!")




if __name__ == "__main__":
    main()
