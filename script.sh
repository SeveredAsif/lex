# flex 2105131.l
# g++ lex.yy.c -lfl
# ./a.out
flex -o 2105131.cpp 2105131.l
g++ 2105131.cpp -lfl -o 2105131.out
./2105131.out input2.txt