import random
import time

# Constants for accuracy of prime testing and limits for prime generation
ACCURACY = 5
SINGLE_MAX = 10000
EXPONENT_MAX = 1000
BUF_SIZE = 1024

def modpow(a, b, c):
    """Computes (a^b) % c using an efficient iterative method (modular exponentiation)."""
    res = 1
    while b > 0:
        # If the lowest bit of b is set, multiply result by a
        if b & 1:
            res = (res * a) % c
        b = b >> 1  # Shift b to the right (divide by 2)
        a = (a * a) % c  # Square a and take mod c
    return res

def jacobi(a, n):
    """Computes the Jacobi symbol (a/n), which is used in primality testing."""
    twos, temp = 0, 0
    mult = 1
    while a > 1 and a != n:
        a = a % n
        if a <= 1 or a == n:
            break
        twos = 0
        # Factor out powers of 2
        while a % 2 == 0:
            twos += 1
            a //= 2
        # Adjust the multiplier based on how many 2s were factored out
        if twos > 0 and twos % 2 == 1:
            mult *= (1 if n % 8 in [1, 7] else -1)
        if a <= 1 or a == n:
            break
        # Flip coefficient based on properties of Jacobi symbols
        if n % 4 != 1 and a % 4 != 1:
            mult *= -1
        temp = a
        a = n
        n = temp
    # Return the appropriate value based on the final state
    if a == 0:
        return 0
    elif a == 1:
        return mult
    else:
        return 0

def solovay_prime(a, n):
    """Checks if a is an Euler witness for n using the Solovay-Strassen primality test."""
    x = jacobi(a, n)
    if x == -1:
        x = n - 1
    # Check the congruence condition to determine primality
    return x != 0 and modpow(a, (n - 1) // 2, n) == x

def probable_prime(n, k):
    """Tests if n is probably prime using k Solovay-Strassen primality tests."""
    if n == 2:
        return True  # 2 is prime
    elif n % 2 == 0 or n == 1:
        return False  # Even numbers and 1 are not prime
    # Perform k tests with random witnesses
    for _ in range(k):
        if not solovay_prime(random.randint(2, n - 2), n):
            return False  # Found a witness indicating n is composite
    return True  # Likely prime

def rand_prime(n):
    """Finds a random probable prime between 3 and n - 1."""
    prime = random.randint(0, n)
    n += n % 2  # Ensure n is even
    prime += 1 - prime % 2  # Make sure prime is odd
    while True:
        # Keep testing numbers until a probable prime is found
        if probable_prime(prime, ACCURACY):
            return prime
        prime = (prime + 2) % n  # Move to the next odd number

def gcd(a, b):
    """Computes the greatest common divisor of a and b using the Euclidean algorithm."""
    while b != 0:
        a, b = b, a % b
    return a

def rand_exponent(phi, n):
    """Finds a random exponent e between 3 and n - 1 such that gcd(e, phi) = 1."""
    e = random.randint(0, n)
    while True:
        # Ensure e is coprime with phi (i.e., gcd(e, phi) == 1)
        if gcd(e, phi) == 1:
            return e
        e = (e + 1) % n
        if e <= 2:
            e = 3  # Reset e if it gets too small

def inverse(n, modulus):
    """Computes the modular inverse of n mod modulus using the Extended Euclidean method."""
    a, b = n, modulus
    x, y, x0, y0 = 0, 1, 1, 0
    while b != 0:
        q = a // b
        a, b = b, a % b
        x, x0 = x0 - q * x, x
        y, y0 = y0 - q * y, y
    if x0 < 0:
        x0 += modulus
    return x0




def main():
    # Seed the random number generator for reproducibility
    random.seed(time.time())
    
    # Generate two random prime numbers p and q
    while True:
        p = rand_prime(SINGLE_MAX)
        print(f"Got first prime factor, p = {p} ... ")

        q = rand_prime(SINGLE_MAX)
        print(f"Got second prime factor, q = {q} ... ")

        n = p * q  # Calculate modulus n
        print(f"Got modulus, n = pq = {n} ... ")
        if n < 128:
            print("Modulus is less than 128, cannot encode single bytes. Trying again ... ")
        else:
            break
    
    # Calculate totient (phi) of n
    phi = (p - 1) * (q - 1)
    print(f"Got totient, phi = {phi} ... ")

    # Choose a random public exponent e that is coprime with phi
    e = rand_exponent(phi, EXPONENT_MAX)
    print(f"Chose public exponent, e = {e}\nPublic key is ({e}, {n}) ... ")

    # Calculate the private exponent d as the modular inverse of e mod phi
    d = inverse(e, phi)
    print(f"Calculated private exponent, d = {d}\nPrivate key is ({d}, {n}) ... ")


    # We have a 
    # M - message 
    # e - public exponent
    # n - modulus
    # d - private exponent