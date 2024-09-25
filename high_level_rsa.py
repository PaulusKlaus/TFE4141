def modular_multiply(x, y, modulus):
    """
    Efficient modular multiplication using the paper and pencil method.
    This function computes (a * b) % n using interleaved reduction.
    """
    R = 0  # Initial value for partial sum
    k = y.bit_length()  # Number of bits in b

    for i in range(k - 1, -1, -1):  # Iterate from the most significant bit to the least
        R = R << 1  # Double the current result
        if (y >> i) & 1:  # If the i-th bit of b is 1
            R = R + x
        
        # Perform reduction: keep R in the range [0, N-1] with at most two subtractions
        if R >= modulus:
            R = R - modulus
        if R >= modulus:
            R = R - modulus

    return R

def modular_exponentiation(base, exponent, modulus):
    """
    Efficient modular exponentiation using the square-and-multiply algorithm.
    This function computes (base^exponent) % modulus.
    """
    if (base >= modulus):
        return modular_exponentiation(base - modulus, exponent, modulus)

    result = 1

    binary_exponent = bin(exponent)[2:]  # Convert exponent to binary

    for bit in binary_exponent[::-1]: # Iterate over bits of exponent from right to left
        if bit == '1':  # If the least significant bit of exponent is 1
            result = modular_multiply(result, base, modulus)
        base = modular_multiply(base, base, modulus)  # Square the base

    return result

# RSA key generation
p = 6247
q = 7919
n = p * q
phi = (p - 1) * (q - 1)
e = 999331
d = pow(e, -1, phi)
print(f'Private key (n, d): ({n}, {d})')
print(f'Public key (n, e): ({n}, {e})')

# Message to encrypt
message = "Hello from the other side!"  # Plaintext message
message_as_int = [int.from_bytes(char.encode(), 'big') for char in message]
print(f'Original message: {message}')

ciphertext = []

for number in message_as_int:
    ciphertext.append(modular_exponentiation(number, e, n))

print(f'Encrypted message: {ciphertext}')

decrypted_message = ""

for number in ciphertext:
    decrypted_number = modular_exponentiation(number, d, n)
    decrypted_character = int.to_bytes(decrypted_number, 1, 'big').decode()
    decrypted_message += decrypted_character

print(f'Decrypted message: {decrypted_message}')
