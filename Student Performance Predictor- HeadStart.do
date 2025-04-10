capture log close		// Clear logs
set more off            // Disable partitioned output
clear all               // Start with a clean slate
set linesize 80         // Line size limit to make output more readable
macro drop _all         // clear all macros

*********************************
** Changing Computer Directory **
*********************************

// Note: cd stands for "change directory"

// Note: backslashes ("/") are for Macs; forward slashes ("\") are for PCs

// Note: find what working directory you are already in by typing pwd into your command line **you should ALWAYS put everything you code in your do file - except for some things like this...**

cd "/Users/sosinatilahun/Downloads/PersonalProject/"

import delimited "StudentsPerformance.csv" , clear
save "StudentsPerformance.csv.dta", replace


********************
** Load a dataset **
********************

// Note: Stata data files are in ".dta" format

// AUTH: Sosina Tilahun
// DATE: 4/8/25
// FILE: Student_Performance_Predictor

// Check for duplicates
duplicates report

// Count of unique values in each variable 
foreach var in mathscore readingscore writingscore {
    quietly levelsof `var', local(levels)
    local nvals: word count `levels'
    display "Unique values in `var': `nvals'"
}


// 2. Create a new variable: Average score
gen average = (mathscore + readingscore + writingscore) / 3

// 3. Histogram by race/ethnicity
twoway (kdensity average if raceethnicity=="group A", lcolor(blue)) ///
       (kdensity average if raceethnicity=="group B", lcolor(green)) ///
       (kdensity average if raceethnicity=="group C", lcolor(orange)) ///
       (kdensity average if raceethnicity=="group D", lcolor(red)) ///
       (kdensity average if raceethnicity=="group E", lcolor(purple)), ///
       legend(order(1 "Group A" 2 "Group B" 3 "Group C" 4 "Group D" 5 "Group E")) ///
       title("Race/Ethnicity vs Average Score") ///
       xtitle("Average Score") ytitle("Density")
	   
//4. Average Score by Test Preparation

graph bar (mean) average, over(testpreparationcourse, label(angle(0))) ///
    bar(1, color(blue)) ///
    title("Average Score by Test Preparation") ///
    ytitle("Average Score") ///
    blabel(bar)

//5. Average Score vs Parental Education Level

graph bar (mean) average, over(parentallevelofeducation, label(angle(45))) ///
    bar(1, color(green)) ///
    title("Average Score vs Parental Education Level") ///
    ytitle("Average Score") ///
    blabel(bar)

// Encode the parental education and test prep variables for ordering
encode parentallevelofeducation, gen(parent_edu)
encode testpreparationcourse, gen(test_prep)

// Sort values to ensure ordered plotting
gsort parent_edu test_prep

// Collapse to get mean math score by group
collapse (mean) mathscore, by(parent_edu test_prep)

// Create the interaction line plot
twoway (connected mathscore parent_edu if test_prep==1, ///
           msymbol(o) lpattern(solid) lcolor(blue) ///
           mlabel(mathscore) mlabposition(12)) ///
       (connected mathscore parent_edu if test_prep==2, ///
           msymbol(s) lpattern(dash) lcolor(green) ///
           mlabel(mathscore) mlabposition(12)), ///
       legend(order(1 "None" 2 "Completed")) ///
       xtitle("Parental Education Level") ///
       ytitle("Mean Math Score") ///
       title("Interaction Between Parent Education and Test Prep Course") ///
       xlabel(1 "Some high school" 2 "High school" 3 "Some college" 4 "Associate's degree" 5 "Bachelor's degree" 6 "Master's degree")

// Reload Data 
	   
use "StudentsPerformance.csv.dta", clear

// Encode categorical variables
encode parentallevelofeducation, gen(parent_edu)
encode testpreparationcourse, gen(test_prep)

// Collapse to get mean reading score
collapse (mean) readingscore, by(parent_edu test_prep)



// Plot with rotated and clean x-axis labels
twoway (connected readingscore parent_edu if test_prep==1, ///
           msymbol(o) lpattern(solid) lcolor(blue)) ///
       (connected readingscore parent_edu if test_prep==2, ///
           msymbol(s) lpattern(dash) lcolor(green)), ///
       legend(order(1 "None" 2 "Completed") title("Test Preparation Course")) ///
       xtitle("Parental Education Level") ///
       ytitle("Mean Reading Score") ///
       title("Interaction Between Parent Education and Test Prep Course") ///
       xlabel(1 "Some HS" 2 "HS" 3 "Some College" 4 "Associate" 5 "Bachelor" 6 "Master", angle(45))
	   
// Regression Model 


use "StudentsPerformance.csv.dta", clear

// Encode test preparation course for regression
encode testpreparationcourse, gen(test_prep)

// MODEL 1: Effect on Math Score
regress mathscore i.test_prep

// MODEL 2: Effect on Reading Score
regress readingscore i.test_prep

// MODEL 3: Effect on Writing Score
regress writingscore i.test_prep


***Outcome	Effect of Not Completing Test Prep	Interpretation
//Math Score	    −11.57 points	Test prep has the strongest effect on math. 	    						Students who didn't do it score much lower.

//Reading Score	−6.92 points	Still significant. Test prep helps in reading too.

//Writing Score	−7.42 points	Similar to reading. Writing benefits from prep***




// Collapse mean scores by test_prep
collapse (mean) mathscore readingscore writingscore, by(test_prep)

// Create a grouped bar chart manually
graph bar mathscore readingscore writingscore, ///
    over(test_prep, label(angle(0))) ///
    bar(1, color(navy)) bar(2, color(teal)) bar(3, color(maroon)) ///
    legend(order(1 "Math" 2 "Reading" 3 "Writing") title("Test Type")) ///
    title("Average Scores by Test Preparation") ///
    ytitle("Mean Score") blabel(bar)

