cd

/*I obtain march CPS data (ASEC) for survey years 1964-2020 */

use "..\Data\cps"
describe
summarize

/*I address missing observations */

replace region=. if region==97
replace race=. if race== 999 // blank 
replace sex=. if sex ==0
replace ahrsworkt=. if ahrsworkt==999 // Missing
replace classwkr = . if inlist(classwkr, 99) // NIU, Missing
replace uhrsworkly = . if uhrsworkly == 999   // NIU, Missing
replace classwly=. if inlist(classwly, 00, 99) & inrange(year, 1964, 1975) // NIU, Missing/Unknown
replace classwly=. if classwly==0 & year>=1976 // ensuring year is not missing
replace wkswork1=. if wkswork1==0 & year>=1976
replace wkswork2 = . if inlist(wkswork2, 0, 9) // NIU, Missing data
replace fullpart = . if inlist(fullpart, 0, 9) // NIU, Unknown
replace educ=. if inlist(educ, 000, 999) // NIU or no schooling, NIU or blank, Missing/Unknown
replace higrade = . if inlist(higrade, 0, 999) // NIU, Missing/Unknown

replace incwage=. if incwage==99999998 & year==1964
replace incwage=. if incwage==99999999 & year>=1965 // N.I.U. (Not in Universe)/ Missing (1962-1966 only)
replace inclongj=. if inclongj==99999999
replace oincwage=. if oincwage==99999999

/* FTFY, defined as as those who work 35-plus hours per week, and forty-plus weeks in the prior year. 

I create a variable for full time workers defined as as those who work 35-plus hours per week in 
the last year. */

gen fulltime = fullpart == 1 
label value fulltime FULLTIME
label variable fulltime "usually worked 35+ hours per week last year"

/* I create a variable for workers who worked forty-plus weeks in the prior year (fullyear). We note
that from 1964 to 1975, weeks worked last year (wkswork1) were not recorded, but were recorde in an 
intervalled manner, in variable (wkswork2) and so we impute these values from wkswork2 1964 to 1975. */ 

tabstat wkswork1 if year>=1976 [w=asecwt], by(wkswork2) statistics(mean) format(%8.2fc) save
return list
  scalar m1=r(Stat1)[1,1]
  scalar m2=r(Stat2)[1,1]
  scalar m3=r(Stat3)[1,1]
  scalar m4=r(Stat4)[1,1]
  scalar m5=r(Stat5)[1,1]
  scalar m6=r(Stat6)[1,1]
  
  replace wkswork1=m1 if wkswork2==1 & year<=1975
  replace wkswork1=m2 if wkswork2==2 & year<=1975
  replace wkswork1=m3 if wkswork2==3 & year<=1975
  replace wkswork1=m4 if wkswork2==4 & year<=1975
  replace wkswork1=m5 if wkswork2==5 & year<=1975
  replace wkswork1=m6 if wkswork2==6 & year<=1975


  tab year wkswork1 if year<=1975
  
  scalar drop _all

gen fullyear = wkswork1 >= 40 & wkswork1 <= 52  
label value fullyear FULYEAR
label variable fullyear  "workers~40-plus weeks worked"


/* Individuals in the armed forces are dropped, I keep individuals who are at least 
17 years of age (during the earning year they were 16) and worked 1 to 52 weeks */

keep if popstat==1 & wkswork1 >= 1 & wkswork1 <= 52 & age >=17 

/* age is top coded at 90 or 99 through the years, I create a consistent measure */

replace age=90 if age >90 



/* We create region dummies */ 

gen northeast = region == 11 | region ==12
gen midwest = region == 21 | region == 22
gen south = region == 31 | region == 32 | region == 33
gen west = region == 41 | region == 42 


/* Race dummies */

generate black = (race ==200)
label value black BLACK
label variable black "black race"


generate white = (race ==100)
label value white WHITE
label variable white "white race"

generate other_race = race >=300
label value other_race OTHER_RACE
label variable other_race "other race"


/* Sex dummies */
generate female = (sex==2)
label value female FEMALE
label variable female "female"



/* Recode grade variable */
*drop if educ == .
generate grade=.
*** 1964-1991
  replace grade=0  if educ==2 & year<=1991 // none or preschool
  replace grade=1  if educ==11 & year<=1991 // grade 1
  replace grade=2  if educ==12 & year<=1991 // grade 2
  replace grade=3  if educ==13 & year<=1991 // grade 3
  replace grade=4  if educ==14 & year<=1991 // grade 4
  replace grade=5  if educ==21 & year<=1991 // grade 5
  replace grade=6  if educ==22 & year<=1991 // grade 6
  replace grade=7  if educ==31 & year<=1991 // grade 7
  replace grade=8  if educ==32 & year<=1991 // grade 8 
  replace grade=9  if educ==40 & year<=1991 // grade 9
  replace grade=10 if educ==50 & year<=1991 // grade 10
  replace grade=11 if educ==60 & year<=1991 // grade 11
  replace grade=12 if (educ==72 | educ==73) & year<=1991 // 12th grade, diploma unclear, high school diploma
  replace grade=13 if educ==80 & year<=1991 // 1 year of college
  replace grade=14 if educ==90 & year<=1991 // 2 years of college
  replace grade=15 if educ==100 & year<=1991 // 3 years of college
  replace grade=16 if educ==110 & year<=1991 // 4 years of college
  replace grade=17 if educ==121 & year<=1991 // 5 years of college
  replace grade=18 if educ==122 & year<=1991 // 6 years of college or more

** We have to add (Park 1994) values to calculate experience

* men, white
replace grade = .32  if (white==1 & female==0 & educ==1 | educ == 2) & year>=1992
replace grade = 3.19 if (white==1 & female==0 & educ ==10) & year>=1992
replace grade = 7.24 if (white==1 & female==0 & (educ ==20 | educ==30)) & year>=1992
replace grade = 8.97 if (white==1 & female==0 & educ == 40) & year>=1992
replace grade = 9.92 if (white==1 & female==0 & educ == 50) & year>=1992
replace grade = 10.86 if (white==1 & female==0 & educ ==60) & year>=1992
replace grade = 11.58 if (white==1 & female==0 & educ ==71) & year>=1992
replace grade = 11.99 if (white==1 & female==0 & educ ==73) & year>=1992
replace grade = 13.48 if (white==1 & female==0 & educ ==81) & year>=1992
replace grade = 14.23 if (white==1 & female==0 & (educ ==91 | educ==92)) & year>=1992
replace grade = 16.17 if (white==1 & female==0 & educ ==111) & year>=1992
replace grade = 17.68 if (white==1 & female==0 & educ ==123) & year>=1992
replace grade = 17.71 if (white==1 & female==0 & educ ==124) & year>=1992
replace grade = 17.83 if (white==1 & female==0 & educ ==125) & year>=1992


* female, white
replace grade = 0.62 if (white==1 & female==1 & educ==1 | educ == 2) & year>=1992
replace grade = 3.15 if (white==1 & female==1 & educ ==10) & year>=1992
replace grade = 7.23 if (white==1 & female==1 & (educ ==20 | educ==30)) & year>=1992
replace grade = 8.99 if (white==1 & female==1 & educ == 40) & year>=1992
replace grade = 9.95 if (white==1 & female==1 & educ == 50) & year>=1992
replace grade = 10.87 if (white==1 & female==1 & educ ==60) & year>=1992
replace grade = 11.73 if (white==1 & female==1 & educ ==71) & year>=1992
replace grade = 12.00 if (white==1 & female==1 & educ ==73) & year>=1992
replace grade = 13.35 if (white==1 & female==1 & educ ==81) & year>=1992
replace grade = 14.22 if (white==1 & female==1 & (educ ==91 | educ==92)) & year>=1992
replace grade = 16.15 if (white==1 & female==1 & educ ==111) & year>=1992
replace grade = 17.64 if (white==1 & female==1 & educ ==123) & year>=1992
replace grade = 17.00 if (white==1 & female==1 & educ ==124) & year>=1992
replace grade = 17.76 if (white==1 & female==1 & educ ==125) & year>=1992

* men, black
replace grade = .92  if (black==1 & female==0  & educ==1 | educ == 2) & year>=1992
replace grade = 3.28 if (black==1 & female==0 & educ ==10) & year>=1992
replace grade = 7.04 if (black==1 & female==0 & (educ ==20 | educ==30)) & year>=1992
replace grade = 9.02 if (black==1 & female==0 & educ == 40) & year>=1992
replace grade = 9.91 if (black==1 & female==0 & educ == 50) & year>=1992
replace grade = 10.90 if (black==1 & female==0 & educ ==60) & year>=1992
replace grade = 11.41 if (black==1 & female==0 & educ ==71) & year>=1992
replace grade = 11.98 if (black==1 & female==0 & educ ==73) & year>=1992
replace grade = 13.57 if (black==1 & female==0 & educ ==81) & year>=1992
replace grade = 14.33 if (black==1 & female==0 & (educ ==91 | educ==92)) & year>=1992
replace grade = 16.13 if (black==1 & female==0 & educ ==111) & year>=1992
replace grade = 17.51 if (black==1 & female==0 & educ ==123) & year>=1992
replace grade = 17.83 if (black==1 & female==0 & educ ==124) & year>=1992
replace grade = 18.00 if (black==1 & female==0 & educ ==125) & year>=1992

* female, black
replace grade = 0.00 if (black==1 & female==1 & educ==1 | educ == 2) & year>=1992
replace grade = 2.90 if (black==1 & female==1 & educ ==10) & year>=1992
replace grade = 7.03 if (black==1 & female==1 & (educ ==20 | educ==30)) & year>=1992
replace grade = 9.05 if (black==1 & female==1 & educ == 40) & year>=1992
replace grade = 9.99 if (black==1 & female==1 & educ == 50) & year>=1992
replace grade = 10.85 if (black==1 & female==1 & educ ==60) & year>=1992
replace grade = 11.64 if (black==1 & female==1 & educ ==71) & year>=1992
replace grade = 12.00 if (black==1 & female==1 & educ ==73) & year>=1992
replace grade = 13.43 if (black==1 & female==1 & educ ==81) & year>=1992
replace grade = 14.33 if (black==1 & female==1 & (educ ==91 | educ==92)) & year>=1992
replace grade = 16.04 if (black==1 & female==1 & educ ==111) & year>=1992
replace grade = 17.69 if (black==1 & female==1 & educ ==123) & year>=1992
replace grade = 17.40 if (black==1 & female==1 & educ ==124) & year>=1992
replace grade = 18.00 if (black==1 & female==1 & educ ==125) & year>=1992

* men, other
replace grade = .62  if (other_race==1 & female==0 & educ==1 | educ == 2) & year>=1992
replace grade = 3.24 if (other_race==1 & female==0 & educ ==10) & year>=1992
replace grade = 7.14 if (other_race==1 & female==0 & (educ ==20 | educ==30)) & year>=1992
replace grade = 9.00 if (other_race==1 & female==0 & educ == 40) & year>=1992
replace grade = 9.92 if (other_race==1 & female==0 & educ == 50) & year>=1992
replace grade = 10.88 if (other_race==1 & female==0 & educ ==60) & year>=1992
replace grade = 11.50 if (other_race==1 & female==0 & educ ==71) & year>=1992
replace grade = 11.99 if (other_race==1 & female==0 & educ ==73) & year>=1992
replace grade = 13.53 if (other_race==1 & female==0 & educ ==81) & year>=1992
replace grade = 14.28 if (other_race==1 & female==0 & (educ ==91 | educ==92)) & year>=1992
replace grade = 16.15 if (other_race==1 & female==0 & educ ==111) & year>=1992
replace grade = 17.60 if (other_race==1 & female==0 & educ ==123) & year>=1992
replace grade = 17.77 if (other_race==1 & female==0 & educ ==124) & year>=1992
replace grade = 17.92 if (other_race==1 & female==0 & educ ==125) & year>=1992

* female, other
replace grade = 0.31 if (other_race==1 & female==1 & educ==1 | educ == 2) & year>=1992
replace grade = 3.03 if (other_race==1 & female==1 & educ ==10) & year>=1992
replace grade = 7.13 if (other_race==1 & female==1 & (educ ==20 | educ==30)) & year>=1992
replace grade = 9.02 if (other_race==1 & female==1 & educ == 40) & year>=1992
replace grade = 9.97 if (other_race==1 & female==1 & educ == 50) & year>=1992
replace grade = 10.86 if (other_race==1 & female==1 & educ ==60) & year>=1992
replace grade = 11.69 if (other_race==1 & female==1 & educ ==71) & year>=1992
replace grade = 12.00 if (other_race==1 & female==1 & educ ==73) & year>=1992
replace grade = 13.47 if (other_race==1 & female==1 & educ ==81) & year>=1992
replace grade = 14.28 if (other_race==1 & female==1 & (educ ==91 | educ==92)) & year>=1992
replace grade = 16.10 if (other_race==1 & female==1 & educ ==111) & year>=1992
replace grade = 17.67 if (other_race==1 & female==1 & educ ==123) & year>=1992
replace grade = 17.20 if (other_race==1 & female==1 & educ ==124) & year>=1992
replace grade = 17.88 if (other_race==1 & female==1 & educ ==125) & year>=1992

** We label grade
  label value grade GRADE
  label variable grade  "highest grade completed"

/*Generate experience variable */ 

gen experience = max(age-grade-7,0) if year <= 1991
replace experience = max(min(age-grade-7,age-17),0) if year >=1992
label value experience EXPERIENCE
label variable experience "experience"


/* Generate educational categories according to AKK 2008 5 schooling categories */

drop if educ ==.
generate schooling1 = educ <= 60 if year <=1991 // high school dropout
generate schooling2 = educ == 72 if year <=1991 // high school diploma
generate schooling3 = (educ >= 80 & educ <= 100) | educ ==73 if year <=1991  // some college 
generate schooling4 =  (educ==110 | educ==121) if year <=1991 // college graduate
generate schooling5 =  educ >= 122 if year <=1991 // post-college

replace schooling1 =  educ <= 60 if year >=1992 // high school dropout
replace schooling2 =  (educ==71 | educ==73) if year >=1992 // high school diploma
replace schooling3 =  (educ >= 81 & educ <= 92) if year >=1992  // some college 
replace schooling4 =  educ == 111 if year >=1992 // college graduate 
replace schooling5 =  educ >=123 if year >=1992 // post-college

assert schooling1 + schooling2 + schooling3 + schooling4 + schooling5 == 1

gen schooling = schooling1 + 2*schooling2 + 3*schooling3 + 4*schooling4 + 5*schooling5
label define schooling 1 "HS Dropout" 2 "HS Diploma" 3 "Some College" 4 "College Grad" 5 "College-Plus"
label value schooling SCHOOLING
assert schooling > 0 

tab schooling 

/* Top code hours */

replace ahrsworkt = 0 if ahrsworkt == 99 & inrange(year, 1964, 1967)
replace ahrsworkt = 98 if ahrsworkt == 99 & inrange(year, 1968, 2020)
replace uhrsworkly = 98 if uhrsworkly == 99 & inrange(year, 1968, 2020)


/*Exclude negative weights. */
keep if asecwt >=0 & asecwt~=.


/* Impute missing hours for ahrswort from 1964 to 1975, based on sex, fulltime/partime statu, 
According to Katz and Murphy (1992) */

egen sex_fullpart_year = group(female fullpart year) if year <=1975, label


tabstat ahrsworkt if year <= 1975 [w=asecwt], by (sex_fullpart_year) statistics(mean) format(%8.2fc) save
return list
scalar m1=r(Stat1)[1,1]
scalar m2=r(Stat2)[1,1]
scalar m3=r(Stat3)[1,1]
scalar m4=r(Stat4)[1,1]
scalar m5=r(Stat5)[1,1]
scalar m6=r(Stat6)[1,1]
scalar m7=r(Stat7)[1,1]
scalar m8=r(Stat8)[1,1]
scalar m9=r(Stat9)[1,1]
scalar m10=r(Stat10)[1,1]
scalar m11=r(Stat11)[1,1]
scalar m12=r(Stat12)[1,1]
scalar m13=r(Stat13)[1,1]
scalar m14=r(Stat14)[1,1]
scalar m15=r(Stat15)[1,1]
scalar m16=r(Stat16)[1,1]
scalar m17=r(Stat17)[1,1]
scalar m18=r(Stat18)[1,1]
scalar m19=r(Stat19)[1,1]
scalar m20=r(Stat20)[1,1]
scalar m21=r(Stat21)[1,1]
scalar m22=r(Stat22)[1,1]
scalar m23=r(Stat23)[1,1]
scalar m24=r(Stat24)[1,1]
scalar m25=r(Stat25)[1,1]
scalar m26=r(Stat26)[1,1]
scalar m27=r(Stat27)[1,1]
scalar m28=r(Stat28)[1,1]
scalar m29=r(Stat29)[1,1]
scalar m30=r(Stat30)[1,1]
scalar m31=r(Stat31)[1,1]
scalar m32=r(Stat32)[1,1]
scalar m33=r(Stat33)[1,1]
scalar m34=r(Stat34)[1,1]
scalar m35=r(Stat35)[1,1]
scalar m36=r(Stat36)[1,1]
scalar m37=r(Stat37)[1,1]
scalar m38=r(Stat38)[1,1]
scalar m39=r(Stat39)[1,1]
scalar m40=r(Stat40)[1,1]
scalar m41=r(Stat41)[1,1]
scalar m42=r(Stat42)[1,1]
scalar m43=r(Stat43)[1,1]
scalar m44=r(Stat44)[1,1]
scalar m45=r(Stat45)[1,1]
scalar m46=r(Stat46)[1,1]
scalar m47=r(Stat47)[1,1]
scalar m48=r(Stat48)[1,1]

*** Males-Fulltime
replace ahrsworkt=m1 if ahrsworkt == . & female==0 & fullpart == 1 & year ==1964
replace ahrsworkt=m2 if ahrsworkt == . & female==0 & fullpart == 1 & year ==1965
replace ahrsworkt=m3 if ahrsworkt == . & female==0 & fullpart == 1 & year ==1966
replace ahrsworkt=m4 if ahrsworkt == . & female==0 & fullpart == 1 & year ==1967
replace ahrsworkt=m5 if ahrsworkt == . & female==0 & fullpart == 1 & year ==1968
replace ahrsworkt=m6 if ahrsworkt == . & female==0 & fullpart == 1 & year ==1969
replace ahrsworkt=m7 if ahrsworkt == . & female==0 & fullpart == 1 & year ==1970
replace ahrsworkt=m8 if ahrsworkt == . & female==0 & fullpart == 1 & year ==1971
replace ahrsworkt=m9 if ahrsworkt == . & female==0 & fullpart == 1 & year ==1972
replace ahrsworkt=m10 if ahrsworkt == . & female==0 & fullpart == 1 & year ==1973
replace ahrsworkt=m11 if ahrsworkt == . & female==0 & fullpart == 1 & year ==1974
replace ahrsworkt=m12 if ahrsworkt == . & female==0 & fullpart == 1 & year ==1975

*** Males-Partime
replace ahrsworkt=m13 if ahrsworkt == . & female==0 & fullpart == 2 & year ==1964
replace ahrsworkt=m14 if ahrsworkt == . & female==0 & fullpart == 2 & year ==1965
replace ahrsworkt=m15 if ahrsworkt == . & female==0 & fullpart == 2 & year ==1966
replace ahrsworkt=m16 if ahrsworkt == . & female==0 & fullpart == 2 & year ==1967
replace ahrsworkt=m17 if ahrsworkt == . & female==0 & fullpart == 2 & year ==1968
replace ahrsworkt=m18 if ahrsworkt == . & female==0 & fullpart == 2 & year ==1969
replace ahrsworkt=m19 if ahrsworkt == . & female==0 & fullpart == 2 & year ==1970
replace ahrsworkt=m20 if ahrsworkt == . & female==0 & fullpart == 2 & year ==1971
replace ahrsworkt=m21 if ahrsworkt == . & female==0 & fullpart == 2 & year ==1972
replace ahrsworkt=m22 if ahrsworkt == . & female==0 & fullpart == 2 & year ==1973
replace ahrsworkt=m23 if ahrsworkt == . & female==0 & fullpart == 2 & year ==1974
replace ahrsworkt=m24 if ahrsworkt == . & female==0 & fullpart == 2 & year ==1975

*** Females-Fulltime
replace ahrsworkt=m25 if ahrsworkt == . & female==1 & fullpart == 1 & year ==1964
replace ahrsworkt=m26 if ahrsworkt == . & female==1 & fullpart == 1 & year ==1965
replace ahrsworkt=m27 if ahrsworkt == . & female==1 & fullpart == 1 & year ==1966
replace ahrsworkt=m28 if ahrsworkt == . & female==1 & fullpart == 1 & year ==1967
replace ahrsworkt=m29 if ahrsworkt == . & female==1 & fullpart == 1 & year ==1968
replace ahrsworkt=m30 if ahrsworkt == . & female==1 & fullpart == 1 & year ==1969
replace ahrsworkt=m31 if ahrsworkt == . & female==1 & fullpart == 1 & year ==1970
replace ahrsworkt=m32 if ahrsworkt == . & female==1 & fullpart == 1 & year ==1971
replace ahrsworkt=m33 if ahrsworkt == . & female==1 & fullpart == 1 & year ==1972
replace ahrsworkt=m34 if ahrsworkt == . & female==1 & fullpart == 1 & year ==1973
replace ahrsworkt=m35 if ahrsworkt == . & female==1 & fullpart == 1 & year ==1974
replace ahrsworkt=m36 if ahrsworkt == . & female==1 & fullpart == 1 & year ==1975

*** Females-Partime
replace ahrsworkt=m37 if ahrsworkt == . & female==1 & fullpart == 2 & year ==1964
replace ahrsworkt=m38 if ahrsworkt == . & female==1 & fullpart == 2 & year ==1965
replace ahrsworkt=m39 if ahrsworkt == . & female==1 & fullpart == 2 & year ==1966
replace ahrsworkt=m40 if ahrsworkt == . & female==1 & fullpart == 2 & year ==1967
replace ahrsworkt=m41 if ahrsworkt == . & female==1 & fullpart == 2 & year ==1968
replace ahrsworkt=m42 if ahrsworkt == . & female==1 & fullpart == 2 & year ==1969
replace ahrsworkt=m43 if ahrsworkt == . & female==1 & fullpart == 2 & year ==1970
replace ahrsworkt=m44 if ahrsworkt == . & female==1 & fullpart == 2 & year ==1971
replace ahrsworkt=m45 if ahrsworkt == . & female==1 & fullpart == 2 & year ==1972
replace ahrsworkt=m46 if ahrsworkt == . & female==1 & fullpart == 2 & year ==1973
replace ahrsworkt=m47 if ahrsworkt == . & female==1 & fullpart == 2 & year ==1974
replace ahrsworkt=m48 if ahrsworkt == . & female==1 & fullpart == 2 & year ==1975


/* Generate hours worked per week last year */

generate weekly_hours_workedly = ahrsworkt if inrange(year, 1964, 1975)
replace weekly_hours_workedly = uhrsworkly if inrange(year, 1976, 2020)
label value weekly_hours_workedly HOURSWLY
label variable weekly_hours_workedly "usual hours worked per week last year "

/* Workers whose class of work last year was private or government 
wage/salary employment. */ 

generate wageworker = classwly ==22 | classwly == 24 if inrange(year, 1964, 1975)
replace wageworker = classwly >= 22 & classwly <= 28 if inrange(year, 1976,2020)

generate selfemployed = classwly == 10 if inrange(year, 1964, 1975) 
replace selfemployed = classwly >=13 & classwly <= 14 if inrange(year, 1976,2020)

label value wageworker WAGEWORKER
label variable wageworker "class of work was private or gov't wage"

label value selfemployed SELFEMP
label variable selfemployed "class of work was selfemployed wage"

keep if wageworker==1 | selfemployed==1


/* We exclude allocated earnings */ 

replace qinclong = inlist(qinclong, 1, 3)
gen allocated_earnings = 0 
replace allocated_earnings = 1 if qincwage == 1 & inrange(year, 1968, 1975)
replace allocated_earnings = 1 if qincwage >= 1 & qincwage <= 3 & inrange(year, 1976, 1987)
replace allocated_earnings = 1 if qinclong == 1 & inrange(year, 1988, 2020) & srcearn == 1
replace allocated_earnings = 1 if qoincwage == 1  & inrange(year, 1988, 2020) & srcearn == 1 
tab allocated_earnings
label variable allocated_earnings "allocated_earnings"


/* We top code wage */

gen topcode_incwage = .
replace topcode_incwage = 0 if incwage != . & inrange(year, 1964,1987)
replace topcode_incwage = 1 if incwage == 99999 & inrange(year, 1964, 1975)
replace topcode_incwage = 1 if incwage == 50000 & inrange(year, 1976, 1981)
replace topcode_incwage = 1 if incwage == 75000 & inrange(year, 1982, 1984)
replace topcode_incwage = 1 if incwage == 99999 & inrange(year, 1985, 1987)
tab year topcode_incwage, missing

gen topcode_inclongj = .
replace topcode_inclongj = 0 if inclongj !=. & inrange(year, 1988,2020)
replace topcode_inclongj = 1 if inclongj >=99999  & inrange(year, 1988, 1995)
replace topcode_inclongj = 1 if inclongj >=150000 & inrange(year, 1996, 2002)
replace topcode_inclongj=1 if inclongj >=200000 & inrange(year, 2003, 2010)
replace topcode_inclongj=1 if inclongj >=250000 & inrange(year, 2011, 2014)
replace topcode_inclongj=1 if inclongj >=280000 & year==2015
replace topcode_inclongj=1 if inclongj >=300000 & inrange(year, 2016, 2018)
replace topcode_inclongj=1 if inclongj >=310000 & year==2019
replace topcode_inclongj=1 if inclongj >=360000 & year==2020
tab year topcode_inclongj, missing

gen topcode_oincwage = .
replace topcode_oincwage = 0 if oincwage !=. & inrange(year, 1988,2020)
replace topcode_oincwage = 1 if oincwage >=99999  & inrange(year, 1988, 1995)
replace topcode_oincwage = 1 if oincwage >=25000  & inrange(year, 1996, 2002)
replace topcode_oincwage = 1 if oincwage>=35000 & inrange(year, 2003, 2010)
replace topcode_oincwage = 1 if oincwage>=47000 & inrange(year, 2011, 2014)
replace topcode_oincwage = 1 if oincwage>=56000 & year==2015
replace topcode_oincwage = 1 if oincwage>=55000 & inrange(year, 2016, 2017)
replace topcode_oincwage = 1 if oincwage>=56000 & year==2018
replace topcode_oincwage = 1 if oincwage>=60000 & year==2019
replace topcode_oincwage = 1 if oincwage>=70000 & year==2020
tab year topcode_inclongj, missing

generate topcode= topcode_incwage if year<=1987
replace  topcode=1 if (topcode_inclongj==1 | topcode_oincwage==1) & year>=1988
replace  topcode=0 if (topcode_inclongj==0 & topcode_oincwage==0) & year>=1988
label variable topcode "Top Coded Values of Wages" // To rename variable labels
label define TOPCODE 0 "0-Not Top Coded" 1 "1-Top Coded" // To rename labels, so it's not just 1 and 0 
label value topcode TOPCODE
tab year topcode, missing 


/* Replace wage with 1.5* the top coded threshold if its topcoded */

replace incwage = 99999*1.5 if topcode_incwage == 1 & inrange(year, 1962, 1975) 
replace incwage = 50000*1.5 if topcode_incwage == 1 & inrange(year, 1976, 1981)
replace incwage = 75000*1.5 if topcode_incwage == 1 & inrange(year, 1982, 1984) 
replace incwage = 99999*1.5 if topcode_incwage == 1 & inrange(year, 1985, 1987)

replace inclongj = 99999* 1.5 if topcode_inclongj == 1 & inrange(year, 1988, 1995)
replace inclongj = 150000* 1.5 if topcode_inclongj == 1 & inrange(year, 1996, 2002)
replace inclongj = 200000* 1.5 if topcode_inclongj == 1 & inrange(year, 2003, 2010)
replace inclongj = 250000* 1.5 if topcode_inclongj == 1 & inrange(year, 2011, 2014)
replace inclongj = 280000* 1.5 if topcode_inclongj == 1 & year==2015
replace inclongj = 300000* 1.5 if topcode_inclongj == 1 & inrange(year, 2016, 2018)
replace inclongj = 310000* 1.5 if topcode_inclongj == 1 & year==2019
replace inclongj = 360000* 1.5 if topcode_inclongj == 1 & year==2020

replace oincwage = 99999* 1.5 if topcode_oincwage == 1 & inrange(year, 1988, 1995)
replace oincwage = 25000* 1.5 if topcode_oincwage == 1 & inrange(year, 1996, 2002)
replace oincwage = 35000* 1.5 if topcode_oincwage == 1 & inrange(year, 2003, 2010)
replace oincwage = 47000* 1.5 if topcode_oincwage == 1 & inrange(year, 2011, 2014)
replace oincwage = 56000* 1.5 if topcode_oincwage == 1 & year==2015
replace oincwage = 55000* 1.5 if topcode_oincwage == 1 & inrange(year, 2016, 2017)
replace oincwage = 56000* 1.5 if topcode_oincwage == 1 & year==2018
replace oincwage = 60000* 1.5 if topcode_oincwage == 1 & year==2019
replace oincwage = 70000* 1.5 if topcode_oincwage == 1 & year==2020

replace incwage= inclongj + oincwage if topcode_inclongj == 1 | topcode_oincwage == 1


/* We create top codes for weekly wages */

gen top_code_wwage = 0
replace top_code_wwage=1 if (incwage/wkswork1)>(99999*1.5/40) & inrange(year, 1964, 1975)
replace top_code_wwage=1 if (incwage/wkswork1)>(50000*1.5/40) & inrange(year, 1976, 1981)
replace top_code_wwage=1 if (incwage/wkswork1)>(75000*1.5/40) & inrange(year, 1982, 1984)
replace top_code_wwage=1 if (incwage/wkswork1)>(99999*1.5/40) & inrange(year, 1985, 1987)
replace top_code_wwage=1 if (incwage/wkswork1)>((99999+99999)*1.5/40) & inrange(year, 1988, 1995)
replace top_code_wwage=1 if (incwage/wkswork1)>((150000+25000)*1.5/40) & inrange(year, 1996, 2002)
replace top_code_wwage=1 if (incwage/wkswork1)>((200000+35000)*1.5/40) & inrange(year, 2003, 2010)
replace top_code_wwage=1 if (incwage/wkswork1)>((250000+47000)*1.5/40) & inrange(year, 2011, 2014)
replace top_code_wwage=1 if (incwage/wkswork1)>((280000+56000)*1.5/40) & year==2015
replace top_code_wwage=1 if (incwage/wkswork1)>((300000+55000)*1.5/40) & year>=2016 & year<=2017
replace top_code_wwage=1 if (incwage/wkswork1)>((300000+56000)*1.5/40) & year==2018
replace top_code_wwage=1 if (incwage/wkswork1)>((310000+60000)*1.5/40) & year==2019
replace top_code_wwage=1 if (incwage/wkswork1)>((360000+70000)*1.5/40) & year==2020

label variable top_code_wwage "Top Coded Values of Weekly Wages" // To rename variable labels
label define WWTOPCODE 0 "0-Not Top Coded" 1 "1-Top Coded" // To rename labels, so it's not just 1 and 0 
label value topcode WWTOPCODE
tab year top_code_wwage, missing 


/* Import PCE data */

replace year = year-1
sort year
merge m:1 year using "../Data/pce", keep(match) nogenerate
replace year = year + 1 
describe
summarize

/* Create weekly wages */

gen weekly_wage = incwage/wkswork1 if wageworker == 1 & incwage>0 
label value weekly_wage WEEKLY_WAGE
label variable weekly_wage "weekly wage of wage and salary workers"


/*Generate deflated wages */

summarize pce if inlist(year, 2001), meanonly // 2001 survey year = 2000 pce year
scalar pce2000=r(mean)
scalar list pce2000

summarize pce if inlist(year, 1983), meanonly // 1983 survey year = 1982 pce year
scalar pce1982=r(mean)
scalar list pce1982


generate real_weekly_wage = ((pce2000*weekly_wage)/pce) // deflated to 2000 year dollars
label variable real_weekly_wage "real weekly wage in 2000$, using PCE deflator"

/* Generate bottom weekley wages in 1982 dollars */

generate weekly_wage_less_than_sixtyseven = ((pce2000*weekly_wage)/pce) < ((67*78.235)/47.456) 
label variable weekly_wage_less_than_sixtyseven "bottom weekly wages in 1982$, using PCE deflator"



/* Keep workers ages 16 to 64 */

keep if age>=17 & age<=65 

/* Drop 3/8 file in order to better compare income estimates from ASEC 2014 and prior */ 

drop if hflag == 1

save "../Data/cleaned_cps", replace


