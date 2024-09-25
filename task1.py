import random
import time



# def modpow1(a, b, c):
#     """Computes (a^b) % c using an efficient iterative method (modular exponentiation)."""
#     res = 1
#     while b > 0:
#         # If the lowest bit of b is set, multiply result by a
#         if b & 1:
#             res = (res * a) % c
#         b = b >> 1  # Shift b to the right (divide by 2)
#         a = (a * a) % c  # Square a and take mod c
#     return res

# def modpow2(base, exponent, modulus):
#     """
#     Computes (base^exponent) % modulus using an efficient method called modular exponentiation.
    
#     This method uses an iterative approach to perform the exponentiation, which 
#     prevents overflow and speeds up the computation by reducing the number of 
#     multiplications required.
    
#     Args:
#     - base (int): The base number that is raised to the power of the exponent.
#     - exponent (int): The power to which the base is raised.
#     - modulus (int): The modulus used to keep the results within a certain range.
    
#     Returns:
#     - int: The result of (base^exponent) % modulus.
#     """
#     # Initialize the result to 1, since any number raised to the power of 0 is 1.
#     result = 1
    
#     # Continue looping while the exponent is greater than 0.
#     while exponent > 0:
#         # If the current exponent is odd, multiply the result by the current base value.
#         # This checks if the last bit of the exponent is 1 (meaning it is odd).
#         if exponent % 2 == 1:
#             result = (result * base) % modulus  # Update the result with (result * base) mod modulus
        
#         # Update the exponent by dividing it by 2 (shifting bits to the right).
#         # This effectively reduces the problem size by halving the exponent.
#         exponent = exponent // 2
        
#         # Square the base and take modulus to keep the value manageable.
#         # This prepares the base for the next loop iteration.
#         base = (base * base) % modulus
    
#     # Return the final computed result after all iterations.
#     return result

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

def modpow(a, b, n):
    """
    Efficient modular exponentiation using the optimized modular multiplication.
    This function computes (a^b) % n using repeated squaring and interleaved reduction.
    """
    C = 1
    P = a % n  # Initialize P as a mod n to keep it within the bounds

    while b > 0:
        if b % 2 == 1:  # If the current bit of b is 1
            C = modular_multiplication(C, P, n)  # Use modular multiplication instead of direct multiplication
        P = modular_multiplication(P, P, n)  # Square P for the next iteration
        b //= 2  # Shift b to the right to process the next bit

    return C





def gcd(a, b):
    """Computes the greatest common divisor of a and b using the Euclidean algorithm."""
    while b != 0:
        a, b = b, a % b
    return a

def read_file(file_path, bytes_per_block):
    """Reads the file into a byte array, padded to fit encryption block size."""
    with open(file_path, 'rb') as f:
        buffer = f.read()
    len_buffer = len(buffer)
    padded_length = len_buffer + (bytes_per_block - (len_buffer % bytes_per_block)) % bytes_per_block
    return buffer.ljust(padded_length, b'\0')  # Pad with zeros

def encode(m, e, n):
    """Encodes a message block m using the public exponent e and modulus n."""
    return modpow(m, e, n)

def decode(c, d, n):
    """Decodes a cryptogram block c using the private exponent d and modulus n."""
    return modpow(c, d, n)

def encode_message(message, bytes_per_block, exponent, modulus):
    """Encodes the message using the public key (exponent, modulus) block by block."""
    encoded = []
    for i in range(0, len(message), bytes_per_block):
        block = message[i:i+bytes_per_block]
        # Convert the block of bytes into an integer for encryption
        x = sum(block[j] * (1 << (7 * j)) for j in range(len(block)))
        encoded_value = encode(x, exponent, modulus)
        encoded.append(encoded_value)

    return encoded

def decode_message(cryptogram, bytes_per_block, exponent, modulus):
    """Decodes the cryptogram using the private key (exponent, modulus) block by block."""
    decoded = []
    for c in cryptogram:
        # Decode the integer back into the original byte block
        x = decode(c, exponent, modulus)
        decoded_block = [(x >> (7 * j)) % 128 for j in range(bytes_per_block)]
        decoded.extend(decoded_block)
    # Convert decoded bytes back to a string, ignoring non-printable characters
    decoded_message = bytes(decoded).decode('utf-8', errors='ignore')
    print(f"Decoded message: {decoded_message}")  # Print the decoded message
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

    buffer = "This is a 256-bit long message!".encode('utf-8')

    len_buffer = len(buffer)

    # Encode the message using the public key
    encoded = encode_message(buffer, bytes_per_block, e, n)
    print("\nEncoding finished successfully ... ")

    # Decode the message using the private key
    print("Decoding encoded message ... ")
    decoded = decode_message(encoded, bytes_per_block, d, n)

    print("\nFinished RSA demonstration!")




if __name__ == "__main__":
    main()
