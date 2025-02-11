def factorial(n, method="iterative"):
<<<<<<< HEAD
    if method == "iterative":
        result = 1
        for i in range(1, n + 1):
            result *= i
        return result
    elif method == "recursive":
        if n == 0 or n == 1:
            return 1
        else:
            return n * factorial(n - 1, method="recursive")
    
if __name__ == "__main__":
    number = 5
    method = input("Choose method (iterative/recursive): ").strip().lower()
    print(f"Factorial of {number} is {factorial(number, method)}")
