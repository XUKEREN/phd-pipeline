/*pm511a - HOW CAN I COMPARE REGRESSION COEFFICIENTS ACROSS THREE (OR MORE) GROUPS?*/
DATA htwt;
  INPUT id age height weight ;
CARDS;
 1 1  56 140   
 2 1  60 155   
 3 1  64 143   
 4 1  68 161   
 5 1  72 139   
 6 1  54 159   
 7 1  62 138   
 8 1  65 121   
 9 1  65 161   
10 1  70 145   
11 2  56 117   
12 2  60 125   
13 2  64 133   
14 2  68 141   
15 2  72 149   
16 2  54 109   
17 2  62 128   
18 2  65 131   
19 2  65 131   
20 2  70 145   
21 3  64 211   
22 3  68 223   
23 3  72 235   
24 3  76 247   
25 3  80 259   
26 3  62 201   
27 3  69 228   
28 3  74 245   
29 3  75 241   
30 3  82 269   
;
RUN; 

/*run model stratified by age*/
PROC REG DATA=htwt;
   BY age ;
   MODEL weight = height ;
RUN; 

/*The parameter estimates (coefficients) for the young, middle age, and senior citizens are shown below. */
/*below, and the results do seem to suggest that height is a stronger predictor of weight for seniors (3.18) */
/*than for the middle aged (2.09). */
/*The results also seem to suggest that height does not predict weight as strongly for the young (-.37) */
/*as for the middle aged and seniors. */
/*However, we would need to perform specific significance tests to be able to make claims about */
/*the differences among these regression coefficients.*/


/*we want to know if the coefficient of height in each stratum of age is different*/
data htwt2;
  set htwt; 
  age1 = . ;
  age2 = . ;
  IF age = 1 then age1 = 1; ELSE age1 = 0 ;
  IF age = 2 then age2 = 1; ELSE age2 = 0 ;
  age1ht = age1*height ;
  age2ht = age2*height ;
RUN;

PROC REG DATA=htwt2 ;
  MODEL weight = age1 age2 height age1ht age2ht ;
  TEST age1ht=0, age2ht=0 ;
RUN; 

/*same as the procedure in proc mixed*/
proc mixed data = htwt2;
class age (ref='1');
model weight = age|height;
run;

/*the third approach using proc glm*/
PROC GLM DATA=htwt2 ;
  CLASS age ;
  MODEL weight = age height age*height / SOLUTION ;
  CONTRAST 'test equal slopes' age*height 1 -1  0,
                               age*height 0  1 -1 ;
RUN;

/*The second contrast compares the regression coefficients of the young vs. middle aged and seniors.*/
/*
young 1 0 0
md 0 1 0
senior 0 0 1
2B1-B2-B3 = 0
0 1 0 + 0 0 1 - 2*(1 0 0)
*/
/*Ho: B1 = (B2 + B3)/2*/
PROC GLM DATA=htwt2 ;
  CLASS age ;
  MODEL weight = age height age*height ;
  CONTRAST 'Mid Age vs. Sen.  ' age*height  0  1 -1 ;
  CONTRAST 'Yng vs (Mid & Sen)' age*height -2  1  1 ;
RUN;
