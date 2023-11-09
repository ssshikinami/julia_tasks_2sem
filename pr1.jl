#1. Написать функцию, вычисляющую НОД двух чисел.
function GCD(a::T, b::T) where T
    while b != 0
        a, b = b, (a % b)
    end
    return a
end

#2. Написать функцию, реализующую расширенный алгоритм Евклида, вычисляющий не только НОД, но и коэффициенты его линейного представления.
function gcdx_(a::T,b::T)::Tuple{T,T,T} where T
        a,b = max(a,b),min(a,b) # Эта строка обменивает значения a и b, чтобы a было больше или равно b
        u,v = 1,0
        u1,v1 = 0,1  # Здесь (u, v) будет представлять текущие коэффициенты Безу, а (u1, v1) - предыдущие коэффициенты Безу

        while b > 0
            k, r = divrem(a,b); # возвращает частное и остаток от деления a на b. Здесь k - частное, а r - остаток.
            a,b = b, a - r #  r = k * b # Это шаг алгоритма Евклида для нахождения НОД.
            u,v = v,u - k * v
            u1,v1 = v1,u1 - k * v1
        end

        s = sign(a) # Вычисление знака a и сохранение его в переменной s

        return (a * s, u * s, u1 * s) # Возврат кортежа с результатами вычислений. Значение a * s представляет наибольший общий делитель gcd(a, b), а u * s и u1 * s представляют соответствующие коэффициенты Безу.
    end
   
#3. С использованием функции gcdx_ реализовать функцию invmod_(a::T, M::T) where T, которая бы возвращала бы обратное значение инвертируемого элемента (a) кольца вычетов по модулю M, а для необращаемых элементов возвращала бы nothing.
function invmod(a::T, M::T) where T
    gcd, x, y = gcdx_(a, M)
    if gcd != 1 # Если это условие выполняется, значит a и M не являются взаимно простыми числами, и обратного значения по модулю не существует.
        return ("Nothing")
    else
        return (x % M) # возврат обратного значения
    end
end

#4. С использованием функции gcdx_ реализовать функцию diaphant_solve(a::T,b::T,c::T) where T, которая бы возвращала решение диафантового уравнения ax+by=c, если уравнение разрешимо, и значение nothing - в противном случае.
function diaphant_solve(a::Integer, b::Integer, c::Integer)
    gcd, x, y = gcdx_(a, b)
    if c % gcd != 0 # остаток от деления c на gcd не равен нулю. Если это условие выполняется, значит диофантово уравнение не имеет целочисленных решений, так как c не делится на gcd без остатка
        return (0, 0) # решения отсутствуют
    else
        k = c / gcd # k представляет множитель, который нужно умножить на коэффициенты Безу, чтобы получить решения.
        return (x * k, y * k) # решения диофантова уравнения, полученные путем умножения коэффициентов Безу на k.
    end
end

#5. Для вычислений в кольце вычетов по модулю M определить специальный тип и определить для этого типа следующие операци и функции: +, -, унарный минус, *, ^, inverse (обращает обратимые элементы), display (определяет, в каком виде значение будет выводиться в REPL)
struct Residue{T, M}
    a::T
    Residue{T, M}(a) where {T, M} = new(mod(a, M)) # Определение конструктора Residue, который принимает значение a, применяет операцию mod(a, M) и создает новый объект типа Residue с полученным вычетом.
end

import Base: +, -, *, ^, inv, show

# Перегрузки операторов
+(x::Residue, y::Residue) = Residue(x.a + y.a)
-(x::Residue, y::Residue) = Residue(x.a - y.a)
-(x::Residue) = Residue(-x.a)
*(x::Residue, y::Residue) = Residue(x.a * y.a)
^(x::Residue, n::Integer) = n == 0 ? Residue(1) : x * x^(n-1) # перегрузка оператора ^ для возведения вычета x в целую степень n. Если n равно 0, возвращается вычет 1. В противном случае, рекурсивно вызывается x^(n-1) и производится умножение вычета x на результат этого вызова.

# Обратный элемент
inv(x::Residue) = Residue(invmod(x.a, M))


# 6 Реализовать тип Polynom{T}

struct Polynomial{T<:Number}
    coeffs::Vector{T} # поле
end

import Base: +, -, *, show

# Определение операций для многочленов
+(p::Polynomial, q::Polynomial) = Polynomial([p.coeffs[i] + q.coeffs[i] for i in 1:length(p.coeffs)]) # + и - просто складывают или вычитают соответствующие коэффициенты многочленов p и q
-(p::Polynomial, q::Polynomial) = Polynomial([p.coeffs[i] - q.coeffs[i] for i in 1:length(p.coeffs)])
-(p::Polynomial) = Polynomial([-p.coeffs[i] for i in 1:length(p.coeffs)]) # - также перегружена для унарного минуса, что позволяет получить многочлен с противоположными коэффициентами
*(p::Polynomial, q::Polynomial) = begin # * производит умножение двух многочленов. Вначале создается новый вектор r нулевой длины, который будет содержать коэффициенты результирующего многочлена.
# Затем в двойном цикле происходит умножение каждой пары коэффициентов многочленов p и q, и результаты суммируются в соответствующих позициях вектора r
    m, n = length(p.coeffs), length(q.coeffs)
    r = zeros(T, m+n-1)
    for i in 1:m, j in 1:n
        r[i+j-1] += p.coeffs[i] * q.coeffs[j]
    end
    Polynomial(r)
end

# Определение функции вывода многочлена
show(io::IO, p::Polynomial) = begin
    m = length(p.coeffs)
    if m == 1
        print(io, p.coeffs[1])
    else
        for i in 1:m-1
            print(io, p.coeffs[i], "x^", m-i, " + ")
        end
        print(io, p.coeffs[m], "x^0")
    end
end

function remdiv(a::Polynom, b::Polynom)
    return rem(a,b), div(a,b)
end