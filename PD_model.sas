libname RL 'C:\Users\Mateusz\Desktop\credit-default-prediction-ai-big-data';
/*Zawartość zbiorów danowych*/
proc import datafile = 'C:\Users\Mateusz\Desktop\credit-default-prediction-ai-big-data\train.csv'
     out = RL.CreditDefaultTrain
     dbms=dlm
     replace;
     delimiter=',';
     getnames=yes;
run;
proc import datafile = 'C:\Users\Mateusz\Desktop\credit-default-prediction-ai-big-data\test.csv'
     out = RL.CreditDefaultTest
     dbms=dlm
     replace;
     delimiter=',';
     getnames=yes;
run;
proc contents data=RL.CreditDefaultTrain;
run;
proc contents data=RL.CreditDefaultTest;
run;
/*Rozważane zmienne celu*/
/*proc freq data=RL.CreditDefaultTrain;*/
/*tables CreditDefault;*/
/*run;*/
/*Przekodowanie zmiennej celu na zmienną 0-1*/
data RL.Wybpr1Train(DROP = Id);
set RL.CreditDefaultTrain;
if 'Years in current job'n='10+ years' then
'Years in current job'n = 10;
if 'Years in current job'n='9 years' then
'Years in current job'n = 9;
if 'Years in current job'n='8 years' then
'Years in current job'n = 8;
if 'Years in current job'n='7 years' then
'Years in current job'n = 7;
if 'Years in current job'n='6 years' then
'Years in current job'n = 6;
if 'Years in current job'n='5 years' then
'Years in current job'n = 5;
if 'Years in current job'n='4 years' then
'Years in current job'n = 4;
if 'Years in current job'n='3 years' then
'Years in current job'n = 3;
if 'Years in current job'n='2 years' then
'Years in current job'n = 2;
if 'Years in current job'n='1 year' then
'Years in current job'n = 1;
if 'Years in current job'n='< 1 year' then
'Years in current job'n = 0;
if 'Current Loan Amount'n=99999999.0 then
'Current Loan Amount'n =.;
if 'Credit Score'n > 1000 then
'Credit Score'n = 'Credit Score'n / 10;
run;
data RL.Wybpr1Test(DROP = Id);
set RL.CreditDefaultTest;
if 'Years in current job'n='10+ years' then
'Years in current job'n = 10;
if 'Years in current job'n='9 years' then
'Years in current job'n = 9;
if 'Years in current job'n='8 years' then
'Years in current job'n = 8;
if 'Years in current job'n='7 years' then
'Years in current job'n = 7;
if 'Years in current job'n='6 years' then
'Years in current job'n = 6;
if 'Years in current job'n='5 years' then
'Years in current job'n = 5;
if 'Years in current job'n='4 years' then
'Years in current job'n = 4;
if 'Years in current job'n='3 years' then
'Years in current job'n = 3;
if 'Years in current job'n='2 years' then
'Years in current job'n = 2;
if 'Years in current job'n='1 year' then
'Years in current job'n = 1;
if 'Years in current job'n='< 1 year' then
'Years in current job'n = 0;
if 'Current Loan Amount'n=99999999.0 then
'Current Loan Amount'n =.;
if 'Credit Score'n > 1000 then
'Credit Score'n = 'Credit Score'n / 10;
run;
proc mi data = RL.Wybpr1Train out = RL.POST_1_Train nimpute = 1 seed = 35399; 
class 'Home Ownership'n Purpose Term; 
var  'Home Ownership'n 'Annual Income'n 'Purpose'n 'Term'n 'Current Loan Amount'n 'Monthly Debt'n 'Credit Score'n; 
fcs logistic('Home Ownership'n Purpose Term); 
run; 
proc mi data = RL.Wybpr1Test out = RL.POST_1_Test nimpute = 1 seed = 35399; 
class 'Home Ownership'n Purpose Term; 
var  'Home Ownership'n 'Annual Income'n 'Purpose'n 'Term'n 'Current Loan Amount'n 'Monthly Debt'n 'Credit Score'n; 
fcs logistic('Home Ownership'n Purpose Term); 
run; 
ods output ParameterEstimates=lgparms; 

/*proc surveyselect data=RL.POST_1 method=srs seed=2 outall samprate=0.7 out=RL.data_subset;*/
/**/
/*data RL.training;*/
/*set RL.data_subset;*/
/*if selected = 1;*/
/*run;*/
/**/
/*data RL.testing;*/
/*set RL.data_subset;*/
/*if selected = 0;*/
/*run;*/

ods graphics on;
proc logistic data=RL.POST_1_Train descending plots=roc;
class 'Home Ownership'n Purpose Term;
model 'Credit Default'n = 'Home Ownership'n 'Annual Income'n 'Purpose'n 'Term'n 'Current Loan Amount'n 'Monthly Debt'n 'Credit Score'n / link=logit; 
score data=RL.POST_1_Test out=RL.logisticOutput;
run;
ods graphics off;
data RL.SampleSubmission;
set RL.logisticOutput;
if P_1 > 0.27 then
'I_Credit Default'n = 1;
else 'I_Credit Default'n = 0;
run;
proc export data=RL.SampleSubmission
outfile='C:/Users/Mateusz/Desktop/credit-default-prediction-ai-big-data/SampleSubmissionSAS.csv'
dbms=csv
replace;
run;