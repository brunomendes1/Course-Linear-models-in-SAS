data women;
input diet $ post_chol pre_chol;
datalines;
1 174 221
1 208 298
1 210 232
1 192 182
1 200 258
1 164 153
1 208 293
1 193 283
2 211 203
2 211 223
2 201 164
2 199 194
2 209 248
2 172 268
2 224 249
2 222 297
3 199 249
3 229 178
3 198 166
3 233 223
3 233 274
3 221 234
3 199 271
3 236 207
4 224 297
4 209 279
4 214 212
4 218 192
4 253 151
4 246 191
4 201 284
4 234 168
;
run;

# The interaction term is usually not included in these models 
according to Kutner (double-check). Marasinghe uses it

proc glm data=women;
class diet;
model post_chol = diet pre_chol pre_chol*diet;
title 'Covariance Analysis of Cholesterol-Diet Data';
run;

/* Comparing treatment levels at predefined values of the covariate 
(190 and 250) */

proc glm data=women;
class diet;
model post_chol = diet pre_chol pre_chol*diet/noint solution;
lsmeans diet/cl tdiff adjust=bon at pre_chol=190;
lsmeans diet/cl tdiff adjust=bon at pre_chol=250;
title 'Covariance Analysis of Cholesterol-Diet Data';
run;