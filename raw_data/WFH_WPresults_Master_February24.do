********************************************************************************
********************************************************************************
********************************************************************************
* This .do file REPRODUCES EXACT VERSIONS of the figures, tables, and estimates 
* in the 28 April 2021 version of our "Why Working from Home Will Stick" working
* paper by Jose Maria Barrero, Nick Bloom, and Steven J. Davis.
*
* The data files include data from April 2021 and later survey waves that were 
* not part of the 28 April 2021 working paper. However, weighting observations
* with the variable `cratio100_2021m3' we restrict attention to the exact sample
* used in the 28 April 2021 working paper.
*
* To produce UPDATED results that put nonzero weight on April 2021 and later waves
* of the SWAA, please see the .do file called `WFH_updatedresults_Master_February24.do' 
* in this replication package.
*
* This version: March 2024
********************************************************************************
********************************************************************************
********************************************************************************



********************************************************************************
********************************************************************************
********************************************************************************
* Set up the directory where you have the data and run in that directory

* Other preliminary statements to make the code run (i.e. installing reghdfe and
* binscatter commands)
********************************************************************************
********************************************************************************
********************************************************************************

version 17
cap ssc install binscatter
cap ssc install reghdfe
cap ssc install winsor2, replace



********************************************************************************
********************************************************************************
********************************************************************************
* Label variable names and the values of categorical variables
* Import the CSV
********************************************************************************
********************************************************************************
********************************************************************************

clear

import delimited WFHdata_February24.csv, varnames(1)

********************************************************************************
* Dates are being imported as string, make them dates

foreach var in date quit_date {
	
	rename `var' `var'string

	gen `var' = monthly(`var',"20YM")
	format `var' %tm

	drop `var'string
	
}


********************************************************************************
* Label variable names and rename some variables to conform with the code below.
*
* This code will be particularly helpful to get an idea of the nature of each variable
********************************************************************************

label variable cratio100 "Weights to match CPS on {age x sex x education x earnings}, modified so that the relative weight of a given observation is 5" 
label variable icratio100 "Weights to match CPS on {age x sex x education x earnings} x earnings}, where the weights are modified before multiplying with earnings so that the relative weight of a given observation is 5" 

label variable cratio100_2021m3 "Weights to match CPS on {age x sex x education x earnings} using data only up to March 2021 (all subsequent waves have a weight of zero)"
label variable icratio100_2021m3 "Weights to match CPS on {age x sex x education x earnings} x earnings, using data only up to March 2021 (all subsequent waves have a weight of zero)"

label variable cratio100_nw "Weights to match CPS on {age x sex x education x earnings} - raw weights"
label variable icratio100_nw "Weights to match CPS on {age x sex x education x earnings} x earnings - raw earnings weights"

label variable date "YYYYmM - survey wave"
label variable income "2019 Earnings, $ Thousand"
label variable age_quant "Age in years"
label variable agebin "Age - categorical bins"
label variable educ_years "Years of education"
label variable education "Education - categorical"
label variable education_s "Education (simplified) - categorical"
label variable wfhcovid "100 x 1(WFH this week, i.e. during COVID)"
label variable wfhcovid_ever "100 x 1(Ever WFH during COVID)" 
label variable wfhcovid_frac "Share of paid working days WFH this week (%), i.e. during COVID"
rename numwfh_days_postcovid_s_u numwfh_days_postCOVID_s_u
label variable numwfh_days_postCOVID_s_u "Desired share of paid working days WFH after COVID (%)"

rename numwfh_days_postcovid_boss_s_u numwfh_days_postCOVID_boss_s_u
label variable numwfh_days_postCOVID_boss_s_u "Employer planned share of paid working days WFH after COVID (%)"
label variable commutetime_quant "Commute time (mins)"
label variable wfh_feel_quant "How much of a raise/pay cut would you value WFH 2 to 3 days per week? (%)"
label variable wfh_expect_quant "Relative to expectations before COVID, how productive are you WFH during COVID? (%)"
label variable wfh_expect "Relative to expectations before COVID, how productive are you WFH during COVID? - categorical"
label variable wfh_able_quant "How efficient are you at working from home? (%)"
rename wfh_eff_covid_quant wfh_eff_COVID_quant
label variable wfh_eff_COVID_quant "How efficient are you WFH during COVID, relative to on business premises before COVID (%)"
label variable wfh_invest_quant "Money you & your employer invested in equipment/infrastructure to help you WFH effectively"
label variable wfh_hoursinvest "Hours invested in learning how to WFH effectively"
label variable work_spend_total "Total weekly spending on meals, shopping and entertainment near workplace, pre-COVID"
label variable female "100 x 1(Female)"
label variable redstate "100 x 1(Red State)"
label variable workstatus_current "Current working status - categorical"
label variable income_cat "2019 Earnings, $ Thousand - categorical (detailed)"
label variable incomebin "2019 Earnings, $ Thousand - categorical (coarse), string form"
label variable iincomebin "2019 Earnings, $ Thousand - categorical (coarse)"
label variable ratio "Raw data weights, equal for all observations"
label variable work_industry "Industry of current or most recent job"
label variable censusdivision "Census Division of residence"
label variable region "State of residence"
label variable gender "Sex (binary)"
label variable gender_d "Sex, including 'Other or prefer not to say'"

rename wfh_days_postcovid_s wfh_days_postCOVID_s
label variable wfh_days_postCOVID_s "Desired number of paid WFH days after COVID - categorical"
rename wfh_days_postcovid_boss wfh_days_postCOVID_boss
label variable wfh_days_postCOVID_boss "Employer's planned number of paid WFH days after COVID - categorical"

rename wfh_days_postcovid_ss wfh_days_postCOVID_ss
label variable wfh_days_postCOVID_ss "Desired number of paid WFH days after COVID - categorical, bundling together rarely and never"
rename wfh_days_postcovid_boss_ss wfh_days_postCOVID_boss_ss
label variable wfh_days_postCOVID_boss_ss "Employer's planned number of paid WFH days after COVID - categorical, bundling together rarely and never"


label variable wfh_able "Are you able to do your job from home? - categorical bins, only for May 2020, July 2020 survey waves"
label variable wfh_able_qual  "Are you able to do your job from home (at least partially)? - categorical Yes/No, only for October 2020 and subsequent survey waves"
rename wfh_dperception wfh_Dperception 
label variable wfh_Dperception "How have perceptions of WFH changed among people you know since the start of the pandemic? - categorical"

label variable wfh_feel "How much of a raise/pay cut would you value WFH 2 to 3 days per week? - categorical"
label variable wfh_feel_detailed "How much of a raise/pay cut would you value WFH 2 to 3 days per week? - categorical, this version is most disaggregated and includes data from Sept. 2020 to Feb. 2021"
label variable wfh_feel_legacy "How much of a raise/pay cut would you value WFH 2 to 3 days per week? - categorical, based on legacy question"

label variable wfh_feel_quant_actual "Raise/pay cut value of WFH 2 or 3 days per week x Employer planned post-COVID WFH"

rename logpop_den_job_precovid logpop_den_job_preCOVID
label variable logpop_den_job_preCOVID "Log(Population density of the ZIP code of pre-COVID Job)"
rename logpop_den_feb20 logpop_den_Feb20 
label variable logpop_den_Feb20 "Log(Population density of the ZIP code of February 2020 residence)"
label variable logpop_den_current "Log(Population density of the ZIP code of current residence)"
label variable logpop_den_job_current "Log(Population density of the ZIP code of current job business premises)"
label variable logpop_den_live_future  "Log(Population density of the ZIP code of future (post-move) residence"

rename wfh_eff_covid wfh_eff_COVID
label variable wfh_eff_COVID  "How efficient are you WFH during COVID, relative to on business premises before COVID - categorical"
rename  wfh_eff_covid_legacy wfh_eff_COVID_legacy
label variable wfh_eff_COVID_legacy  "How efficient are you WFH during COVID, relative to on business premises before COVID - categorical, based on legacy question"

label variable wfh_ownroom_notbed "100 x 1(Has their own room (not bedroom) to work in while WFH during COVID)"
label variable goodservices "Industry of current/most recent job is GOODS or SERVICES? - categorical"
label variable redblue_cook "State of residence Red (Republican) or Blue (Democrat)? - categorical"
rename dem_share_frac Dem_share_frac
label variable Dem_share_frac "Joe Biden vote share in 2020 GE - measured as of 12 Nov 2020 (%)"
label variable haschildren "1(Living with children under 18)"
label variable logincome "log(2019 labor earnings $'000s)"
label variable internet_quality_quant "Internet quality - Fraction of time that internet works"
rename habits_postcovid habits_postCOVID
label variable habits_postCOVID "If a COVID vaccine is discovered and made widely available, which of the following would best fit your views on social distancing?"

label variable concern_vaccine "100 x 1(Would not return to pre-COVID activities completely out of concerns with vaccine safety/effectiveness/take-up) - select all that apply question"
label variable concern_socdist "100 x 1(Would not return to pre-COVID activities completely, gotten used to social distancing) - select all that apply question"
label variable concern_otherdisease "100 x 1(Would not return to pre-COVID activities completely out of concerns about other diseases) - select all that apply question"
label variable concern_none "100 x (No concerns preventing the return to pre-COVID activities)"

forvalues i = 1(1)8 {
	label variable child`i'_age "Age of child `i' - missing if fewer than `i' children. Only asked from 9/20 onwards"
}

label variable live_adults "Do you currently live with a partner or other adults"
label variable live_children "Do you currently live with children under 18? -- categorical by youngest's age"
label variable hours_cc_you "Currently, how many hours of childcare each week are provided by you?"
label variable hours_cc_partner "Currently, how many hours of childcare each week are provided by your partner?"
label variable hours_cc_other "Currently, how many hours of childcare each week are provided by others, e.g. grandparents, babysitters?"
label variable hours_cc_you_precovid "Before COVID, how many hours of childcare each week were provided by you?"
label variable hours_cc_partner_precovid "Before COVID, how many hours of childcare each week were provided by your partner?"
label variable hours_cc_other_precovid "Before COVID, how many hours of childcare each week were provided by others, e.g. grandparents, babysitters?"

label variable wfh_invest_burs "Percent of money invested in equipment or infrastructure enabling WFH that was paid for or reimbursed by employer. Missing if no WFH or zero investment"

label variable occupation "Occupation (self-reported)"
label variable occupation_other "User description when selecting 'Other' occupation"

label variable race_ethnicity "Race/ethnicity -- categorical"
label variable race_ethnicity_s "Race/ethnicity -- categorical combines several small categories into 'Other'"

label variable hourly_wage "Hourly wage = (2019 income)/(pre-COVID weekly work hours * 50 weeks per year)"

label variable wfh_extraeff_comm_qual "Is time saved by not commuting part of your extra efficiency when working from home? - categorical"

label variable  wfh_extraeff_comm_quant "How much of your extra efficiency when working from home is due to the time you save by not commuting? -- This equals zero if commuting time savings are not included, or if relative efficiency of WFH is negative "

rename workhours_precovid workhours_preCOVID
label variable workhours_preCOVID "Hours worked per week pre-COVID"
rename workhours_duringcovid workhours_duringCOVID
label variable workhours_duringCOVID "Hours worked per week at the time of the survey (during COVID) -- if currently working, otherwise missing"

label variable extratime_1stjob "Percent of commute time savings spent working on primary or current job"
label variable extratime_2ndjob "Percent of commute time savings spent on a second or new secondary job"
label variable extratime_childcare "Percent of commute time savings spent on childcare"
label variable extratime_chores "Percent of commute time savings spent on home improvement, chores, or shopping"
label variable extratime_indoorleisure "Percent of commute time savings spent on leisure indoors (e.g. reading, watching TV and movies)"
label variable extratime_outdoorexercise "Percent of commute time savings spent on exercise or outdoor leisure"
label variable extratime_sleep "Percent of commute time savings spent on sleep"

label variable wfh_feel_new_qual "Assuming it doesn’t matter for your pay, which working arrangements would you prefer after COVID is under control? - categorical"
label variable wfh_feel_pr_bp_quant0 "How much extra pay would it take for you to prefer working 5 days a week on your employer’s premises after COVID is under control? - For those who prefer 2 days WFH and 3 days on premises. Equals zero if they already prefer 5 days per week on premises"

label variable wfh_feel_pr_hyb_quant0 "How much extra pay would it take for you to prefer working 3 days a week on your employer’s premises and 2 days at home after COVID is under control? - For those who prefer 5 days on premises. Equals zero if they already prefer 2 days WFH and 3 on premises." 

label variable vaccine_req_boss "Does or will your employer require you to be vaccinated to work on business premises? - categorical"
label variable vaccine_req_should_gen "Should employers require vaccination before letting workers return to the employer’s worksite? - categorical"
label variable vaccine_req_should_myboss "Should your employer require vaccination before letting you and your co-workers return to the worksite? - categorical"
 
label variable prom_eff_1day_qual "If you were to work from home one more day per week than your co-workers, how might this affect your chance of a promotion in the next 3 years? - categorical"
label variable prom_eff_5day_qual "If you were to work from home 5+ days a week and your co-workers work on the business premises 5+ days a week, how might this affect your chance of a promotion in the next 3 years? - categorical"

label variable prom_eff_1day_quant "How much of an increase in your chance of a promotion would working from home one more day per week than your co-workers cause?"
label variable prom_eff_5day_quant "How much of an increase in your chance of a promotion would working from home 5+ days a week while your co-workers work on the business premises 5+ days a week cause?"

rename wfh_able_qual_may21 wfh_able_qual_May21
label variable wfh_able_qual_May21 "Do you need to be physically present on business premises to perform your job (current or most recent)? - categorical"

rename wfh_dow_preferm wfh_dow_preferM
rename wfh_dow_prefert wfh_dow_preferT
rename wfh_dow_preferw wfh_dow_preferW
rename wfh_dow_preferr wfh_dow_preferR
rename wfh_dow_preferf wfh_dow_preferF
rename wfh_dow_preferna wfh_dow_preferNA

label variable wfh_dow_preferM "Would choose Monday as one of 2 WFH days"
label variable wfh_dow_preferT "Would choose Tuesday as one of 2 WFH days"
label variable wfh_dow_preferW "Would choose Wednesday as one of 2 WFH days"
label variable wfh_dow_preferR "Would choose Thursday as one of 2 WFH days"
label variable wfh_dow_preferF "Would choose Friday as one of 2 WFH days"
label variable wfh_dow_preferNA "No preference for 2 WFH days"

label variable offer_employed_wfh1days "Would you be more or less likely  to take the new job if it let you work from home 1 day a week? - categorical, employed respondents"
label variable offer_employed_wfh23days "Would you be more or less likely  to take the new job if it let you work from home 2 to 3 day a week? - categorical, employed respondents"
label variable offer_employed_wfh45days "Would you be more or less likely  to take the new job if it let you work from home 4 to 5 day a week? - categorical, employed respondents"

label variable offer_unemployed_wfh1days "Would you be more or less likely  to take the job if it let you work from home 1 day a week? - categorical, unemployed respondents"
label variable offer_unemployed_wfh23days "Would you be more or less likely  to take the job if it let you work from home 2 to 3 day a week? - categorical, unemployed respondents"
label variable offer_unemployed_wfh45days "Would you be more or less likely  to take the job if it let you work from home 4 to 5 day a week? - categorical, unemployed respondents"

label variable wbp_react_qual "How would you respond if your employer announced that all employees must return to worksite 5+ days a week starting [month-after-next]?"

label variable videocall_small_qual "How does the efficiency of video calls for one-on-one and small group meetings (up to 4 people) compare to the efficiency of in-person meetings? - categorical"
label variable videocall_small_quant "How does the efficiency of video calls for one-on-one and small group meetings (up to 4 people) compare to the efficiency of in-person meetings? - quantitative"
	
label variable videocall_med_qual "How does the efficiency of video calls for medium sized group meetings (up to 5 to 10 people) compare to the efficiency of in-person meetings? - categorical"
label variable videocall_med_quant "How does the efficiency of video calls for medium sized group meetings (up 5 to 10 people) compare to the efficiency of in-person meetings? - quantitative"

label variable videocall_large_qual "How does the efficiency of video calls for large sized group meetings (10 or more people) compare to the efficiency of in-person meetings? - categorical"
label variable videocall_large_quant "How does the efficiency of video calls for large sized group meetings (10 or more people) compare to the efficiency of in-person meetings? - quantitative"

label variable wfh_able_intcount "How much would your efficiency working from home increase if you had perfect high-speed internet?"

label variable employer_arr_qual "What plans does your employer have for working arrangements of full-time employees after COVID, in 2022 or later?"

label variable who_decides_wfhdays "Who decides which days and how many days employees work remotely?"

label variable employer_return_when "When does your employer anticipate that most of their full-time employees will return to working one or more days per week on business premises?"

rename wfh_days_postcovid_boss_ty wfh_days_postCOVID_boss_ty
label variable wfh_days_postCOVID_boss_ty "After COVID, in 2022 and later, how many days a week will that typical employee work on business premises? - categorical"

rename wfh_days_postcovid_boss_ty_ss wfh_days_postCOVID_boss_ty_ss
label variable wfh_days_postCOVID_boss_ty_ss "After COVID, in 2022 and later, how many days a week will that typical employee work on business premises? - caterogical bundling together rarely and never"

label variable choice_prefer "Which of the following would you prefer? a) Being able to choose which days you work from home (if any) b) Your employer sets a policy..."

rename handshake_postcovid handshake_postCOVID
rename handshake_precovid handshake_preCOVID
label variable handshake_postCOVID "When you return to work in person, and you are introduced to somebody will you...?"
label variable handshake_preCOVID "Before COVID (in 2019), when you were introduced to somebody at work what did you do?"

label variable downloadspeed "Internet download speed from speed test. Winsorized at the 1st and 90th percentiles within each category of the `internet_quality' variable"
label variable uploadspeed "Internet download speed from speed test. Winsorized at the 1st and 90th percentiles within each category from `internet_quality' variable"

label variable self_employment "Which of the following best describes your current employment situation? - categorical"

label variable ownbusiness_sizecat "Excluding yourself but including employees and independent contractors, how many staff members are part of your business?"
label variable employer_sizecat "Counting all locations where your primary employer operates, what is the total number of persons who work for your employer?"

label variable workstatus_current_new "Currently (this week) what is your work status? - categorical. Version of the question asked since November 2020"

rename numwfh_days_postcovid_boss_pre numwfh_days_postCOVID_boss_pre
label variable numwfh_days_postCOVID_boss_pre "Employer planned share of paid working days WFH after COVID, before the most recent announcement made in the past 6 months (%)" 

rename wfh_postcovid_boss_ann wfh_postCOVID_boss_ann
label variable wfh_postCOVID_boss_ann "In the last six months, has your employer announced new plans about working from home after the pandemic ends, in 2022 or later? - categorical"

rename wfh_eff_covid_qual wfh_eff_COVID_qual
label variable wfh_eff_COVID_qual "How does your efficiency working from home during the COVID-19 pandemic compare to your efficiency working on business premises before the pandemic? - categorical"

rename wfh_eff_covid_neg_d wfh_eff_COVID_neg_d
label variable wfh_eff_COVID_neg_d "How much less efficient are you while working from home than at the office - if less efficient"

rename wfh_eff_covid_pos_d wfh_eff_COVID_pos_d
label variable wfh_eff_COVID_pos_d "How much more efficient are you while working from home than at the office - if more efficient"

rename wfh_eff_nocovid_qual wfh_eff_noCOVID_qual
label variable wfh_eff_noCOVID_qual "How does your efficiency working from home compare to your efficiency working on business premises? - categorical"

rename wfh_eff_nocovid_neg_d wfh_eff_noCOVID_neg_d
label variable wfh_eff_noCOVID_neg_d "How much less efficient are you while working from home than at the office - if less efficient & got the question that doesn't mention COVID"

rename wfh_eff_nocovid_pos_d wfh_eff_noCOVID_pos_d
label variable wfh_eff_noCOVID_pos_d "How much more efficient are you while working from home than at the office - if more efficient & got the question that doesn't mention COVID'"

rename wfh_eff_covid_question wfh_eff_COVID_question
label variable wfh_eff_COVID_question "Equals 1 if the respondent received the efficiency question that mentions COVID, 0 if they got the question that doesn't mention COVID"

label variable employer_sizecat "Counting all locations where your primary employer operates, what is the total number of persons who work for your employer?"

label variable lesseff_reasons_noroom "Why are you less efficient when working from home? - I don't have a quiet room to work in"
label variable lesseff_reasons_kidsinterr "Why are you less efficient when working from home? - I am frequently interrupted by my kids"
label variable lesseff_reasons_adultsinterr "Why are you less efficient when working from home? - I  am frequently interrupted by my partner or other adults I live with"
label variable lesseff_reasons_internet  "Why are you less efficient when working from home? - I don't have an adequate internet connection"
label variable lesseff_reasons_equipment "Why are you less efficient when working from home? - I need specialized equipment to do my job"

label variable lesseff_reasons_homecomputer "Why are you less efficient when working from home? - My home computer is not good enough"
label variable lesseff_reasons_tasks "Why are you less efficient when working from home? - My job involves many tasks that cannot be done remotely"
label variable lesseff_reasons_other "Why are you less efficient when working from home? - Other"

label variable moreeff_reasons_quieter "Apart from saving time by not commuting, why are you more efficient when working from home? - My home is quieter and has fewer interruptions "
label variable moreeff_reasons_shortmeet "Apart from saving time by not commuting, why are you more efficient when working from home? - I have fewer or shorter meetings when working from home"
label variable moreeff_reasons_choreseff "Apart from saving time by not commuting, why are you more efficient when working from home? - Mealtimes, chores, and/or childcare are more efficient when I work from home"
label variable moreeff_reasons_internet "Apart from saving time by not commuting, why are you more efficient when working from home? - My internet connection is better at home"
label variable moreeff_reasons_equip "Apart from saving time by not commuting, why are you more efficient when working from home? - I have better equipment at home than at work"
label variable moreeff_reasons_lessstress "Apart from saving time by not commuting, why are you more efficient when working from home? - I feel less stressed at home"
label variable moreeff_reasons_other "Apart from saving time by not commuting, why are you more efficient when working from home? - Other"

label variable commutetime_towork "How long do you usually spend commuting to work (in minutes)?"
label variable commutetime_fromwork "How long do you usually spend commuting from work (in minutes)?"

label variable coworker_interactions "How much do you enjoy your personal interactions with coworkers at your employer's worksite?"

label variable client_interactions "How much do you enjoy your personal interactions with customers, clients, or patients at your employer's worksite?"

rename wfh_days_postcovid_boss_pre_ss wfh_days_postCOVID_boss_pre_ss
label variable wfh_days_postCOVID_boss_pre_ss "Before the latest announcement, how often did your employer plan for you to work from home after COVID, in 2022 and later?"

label variable disability_qual "Do you have a health problem or a disability which prevents work or which limits the kind or amount of work you do?"

label variable workteam_tasks_percent "To perform your job, what percentage of your tasks require collaboration as part of a team?"
label  variable workteam_npeople "How many people belong to your main work team? (Top-coded at 50)"

rename videocalls_precovid_percent videocalls_preCOVID_percent
label variable videocalls_preCOVID_percent "Before the pandemic, what percentage of your normal working day did you spend in video calls?"

label variable videocalls_current_percent "Currently, what percentage of your normal working day do you spend in video calls?"

label variable workteam_current_nmeetings "Currently, how many times does your main work team meet in a typical week? Include in-person, telephonic, and video meetings. (Top-coded at 30)"

rename workteam_precovid_nmeetings workteam_preCOVID_nmeetings
label variable workteam_preCOVID_nmeetings "Before the pandemic, how many times did your main work team meet in a typical week? Include in-person, telephonic, and video meetings. (Top-coded at 30)"

label variable boss_wfh_samedays "Will your manager work from home on the same days as you after the pandemic is over?"
label variable boss_wfh_unravel "If your manager starts coming into your employer's place of business on some of your work-from-home days, what will you do?"

label variable coworkers_wfh_samedays "Will most of your coworkers work from home on the same days as you after the pandemic is over?"
label variable coworkers_wfh_unravel "If your coworkers start coming into your employer's place of business on some of your work-from-home days, what will you do?"

label variable commutemode "Before COVID how did you typically commute to work? - categorical"

label variable commutemode_s "Before COVID how did you typically commute to work? - categorical and simplified"

label variable wbp_return_anxious "On a scale of 0 to 10, how anxious are you about returning to work on business premises?"


label variable quit_qual "Have you quit or voluntarily left a job in the past 6 months? - categorical"

label variable quit_date "Month (within the past 6) when you most recently quit a job - date format"

label variable wfh_less_stress "How much do you agree: While working from home I am less stressed because I don't feel like I am constantly under supervision."



rename drivealone_precovid_pct drivealone_preCOVID_pct 
rename carpool_precovid_pct carpool_preCOVID_pct
rename publictr_precovid_pct publictr_preCOVID_pct
rename bicycle_precovid_pct bicycle_preCOVID_pct 
rename walk_precovid_pct walk_preCOVID_pct  
rename taxi_precovid_pct taxi_preCOVID_pct 
rename nocommute_precovid_pct nocommute_preCOVID_pct
rename leavetime_precovid_quant leavetime_preCOVID_quant 
rename leavetime_precovid leavetime_preCOVID 

label variable groomtime_commute "How much time do you spend on grooming and getting ready for work when you commute to your employer's or client's worksite?"
label variable groomtime_wfh "How much time do you spend on grooming and getting ready for work when you work from home?"

label variable drivealone_preCOVID_pct "Driving alone: percent of commuting trips in 2019"
label variable carpool_preCOVID_pct "Carpool: percent of commuting trips in 2019"
label variable publictr_preCOVID_pct "Public transit: percent of commuting trips in 2019"
label variable bicycle_preCOVID_pct "Bicycle: percent of commuting trips in 2019" 
label variable walk_preCOVID_pct "Walking: percent of commuting trips in 2019"
label variable taxi_preCOVID_pct "Taxi/ride hailing: percent of commuting trips in 2019" 
label variable nocommute_preCOVID_pct "Did not commute pre-COVID (0 o 100)"


label variable drivealone_current_pct "Driving alone: percent of commuting trips currently"
label variable carpool_current_pct "Carpool: percent of commuting trips currently"
label variable publictr_current_pct "Public transit: percent of commuting trips currently"
label variable bicycle_current_pct "Bicycle: percent of commuting trips currently" 
label variable walk_current_pct "Walking: percent of commuting trips currently"
label variable taxi_current_pct "Taxi/ride hailing: percent of commuting trips currently" 
label variable nocommute_current_pct "Do not commute currently (0 o 100)"

label variable leavetime_preCOVID "In 2019 (before COVID), when you traveled to your employer's worksite, approximately what time did you leave for work (e.g. 8:30am)? - categorical"
label variable leavetime_current "Currently, when you traveled to your employer's worksite, approximately what time did you leave for work (e.g. 8:30am)? - categorical"

label variable leavetime_preCOVID_quant "In 2019 (before COVID), when you traveled to your employer's worksite, approximately what time did you leave for work (e.g. 8:30am)? - quantitative"
label variable leavetime_current_quant "Currently, when you traveled to your employer's worksite, approximately what time did you leave for work (e.g. 8:30am)? - quantitative"

label variable worktime_curr_home_pct "What percentage of your total working time do you currently spend at your home?"
label variable  worktime_curr_ebp_pct "What percentage of your total working time do you currently spend at your employer's worksite"
label variable worktime_curr_client_pct "What percentage of your total working time do you currently spend at a client or customer's worksite?"
label variable worktime_curr_faf_pct "What percentage of your total working time do you currently spend at a friend or family member's home"
label variable worktime_curr_cowork_pct "What percentage of your total working time do you currently spend at a co-working space?"
label variable worktime_curr_public_pct "What percentage of your total working time do you currently spend at a public space (cafe library, etc.)?"


label variable worktime_des_home_pct "After COVID, in 2022 and later, what percentage of your total working time would you like to spend at your home?"
label variable  worktime_des_ebp_pct "After COVID, in 2022 and later, what percentage of your total working time would you like to spend at your employer's worksite"
label variable worktime_des_client_pct "After COVID, in 2022 and later, what percentage of your total working time would you like to spend at a client or customer's worksite?"
label variable worktime_des_faf_pct "After COVID, in 2022 and later, what percentage of your total working time would you like to spend at a friend or family member's home"
label variable worktime_des_cowork_pct "After COVID, in 2022 and later, what percentage of your total working time would you like to spend at a co-working space?"
label variable worktime_des_public_pct "After COVID, in 2022 and later, what percentage of your total working time would you like to spend at a public space (cafe library, etc.)?"

label variable worktime_des_nowork "I don't plan to work in 2022'"

label variable worktime_plan_home_pct "After COVID, in 2022 and later, what percentage of your total working time do you and your employer plan for you to spend at your home?"
label variable  worktime_plan_ebp_pct "After COVID, in 2022 and later, what percentage of your total working time do you and your employer plan for you to spend at your employer's worksite"
label variable worktime_plan_client_pct "After COVID, in 2022 and later, what percentage of your total working time do you and your employer plan for you to spend at a client or customer's worksite?"
label variable worktime_plan_faf_pct "After COVID, in 2022 and later, what percentage of your total working time do you and your employer plan for you to spend at a friend or family member's home"
label variable worktime_plan_cowork_pct "After COVID, in 2022 and later, what percentage of your total working time do you and your employer plan for you to spend at a co-working space?"
label variable worktime_plan_public_pct "After COVID, in 2022 and later, what percentage of your total working time do you and your employer plan for you to spend at a public space (cafe library, etc.)?"

label variable worktime_plan_nowork "I don't plan to work in 2022'"

label variable worksite_option "Do you currently have the option to work at more than one employer worksite?"

label variable worktime_remoteable_pct "What percentage of your total working time do you usually spend on tasks that can be done remotely?"

label variable worktime_nonremotable_why "Why can't you work remotely 100% of the time?"


label variable choice_dow_prefer "If your employer requires you to work on premises 3 days a week, which would you prefer?"

rename wbp_dow_preferm wbp_dow_preferM
rename wbp_dow_prefert wbp_dow_preferT
rename wbp_dow_preferw wbp_dow_preferW
rename wbp_dow_preferr wbp_dow_preferR
rename wbp_dow_preferf wbp_dow_preferF

label variable wbp_dow_preferM "Would choose Monday as 1 of 3 on-premises days"
label variable wbp_dow_preferT "Would choose Tuesday as 1 of 3 on-premises days"
label variable wbp_dow_preferW "Would choose Wednesday as 1 of 3 on-premises days"
label variable wbp_dow_preferR "Would choose Thursday as 1 of 3 on-premises days"
label variable wbp_dow_preferF "Would choose Friday as 1 of 3 on-premises days"

label variable wfanywhere_qual "In 2022 and later, will your employer allow you to work from anywhere for one month each year?"

label variable cities_attn "In how many big cities with more than 500.000 inhabitants have you lived? Please insert the number *33* ."

label variable who_decides_wfhdays "For employees who work from home, who decides their work-from-home schedule?"

label variable worktime_nonremotable_f2fcl "Can't work remotely: need face-to-face interactions with clients/customers"
label variable worktime_nonremotable_f2fco "Can't work remotely: need face-to-face interactions with colleagues"
label variable worktime_nonremotable_equip "Can't work remotely: need to interact with physical equipment on premises"
label variable worktime_nonremotable_other "Can't work remotely: other"

label variable workstatus_monday "Monday of last week, did you work a full day (6+ hours), and if so where?"
label variable workstatus_tuesday "Tuesday of last week, did you work a full day (6+ hours), and if so where?"
label variable workstatus_wednesday "Wednesday of last week, did you work a full day (6+ hours), and if so where?"
label variable workstatus_thursday "Thursday of last week, did you work a full day (6+ hours), and if so where?"
label variable workstatus_friday "Friday of last week, did you work a full day (6+ hours), and if so where?"
label variable workstatus_saturday "Saturday of last week, did you work a full day (6+ hours), and if so where?"
label variable workstatus_sunday "Sunday of last week, did you work a full day (6+ hours), and if so where?"

label variable wfhcovid_fracmat "Share of paid working days WFH this week (%), i.e. during COVID - from `matrix' days-of-week question"

label variable grass_color_attnfull "What color is grass? Make sure that you select purple as an answer so we know you are paying attention."


label variable who_sets_wfhsched "Who sets your work-from-home schedule?"

label variable factors_wfhsched_cow "Coordinating with coworkers is a factor to consider when setting your WFH schedule"
label variable factors_wfhsched_spouse "Coordinating with spouse is a factor to consider when setting your WFH schedule"
label variable factors_wfhsched_client "Coordinating with customers/clients is a factor to consider when setting your WFH schedule"
label variable factors_wfhsched_traffic "Commuting when there's less traffic/congestion is a factor to consider when setting your WFH schedule"

label variable common_varying_sched "What type of work-from-home schedule does your manager or employer set?"

label variable wfh_handle_chores "How often do you work from home to handle matters that require your presence (e.g., to be there for a plumber, a repair person, or deliveries)?"

label variable showerbathe_wbp "Do you shower/bathe each morning when you travel to work?"
label variable brushteeth_wbp "Do you brush your teeth each morning when you travel to work?"
label variable deodorant_wbp "Do you use deodorant each morning when you travel to work?"
label variable makeup_wbp "Do you put on makeup each morning when you travel to work?"
label variable shave_wbp "Do you shave each morning when you travel to work?"
label variable freshclothes_wbp "Do you wear fresh clothes each morning when you travel to work?"
label variable alarm_wbp "Do you set an alarm each morning when you travel to work?"

label variable showerbathe_wfh "Do you shower/bathe each morning when you work from home?"
label variable brushteeth_wfh "Do you brush your teeth each morning when you work from home?"
label variable deodorant_wfh "Do you use deodorant each morning when you work from home?"
label variable makeup_wfh "Do you put on makeup each morning when you work from home?"
label variable shave_wfh "Do you shave each morning when you work from home?"
label variable freshclothes_wfh "Do you wear fresh clothes each morning when you work from home?"
label variable alarm_wfh "Do you set an alarm each morning when you work from home?"

label variable commute_mode_faf    "Commuting mode to the friends and family home"
label variable commute_mode_cowork "Commuting mode to the co-working space"
label variable commute_mode_public "Commuting mode to the public space"

label variable commutetime_to_faf    "Commuting time to the friends and family home (mins)"
label variable commutetime_to_cowork "Commuting time to the co-working space (mins)"
label variable commutetime_to_public "Commuting time to the public space (mins)"

label variable commutetime_from_faf    "Commuting time from the friends and family home (mins)"
label variable commutetime_from_cowork "Commuting time from the co-working space (mins)"
label variable commutetime_from_public "Commuting time from the public space (mins)"

label variable party_affiliation "Do you usually think of yourself as a Republican, Democrat, Independent, or what?"

label variable party_affiliation_s "Do you usually think of yourself as a Republican, Democrat, Independent, or what? (simplified variable)"

rename leandem leanDem
rename leanrep leanRep
rename leanind leanInd

rename dem_self Dem_self
rename rep_self Rep_self
rename ind_self Ind_self

label variable leanDem "100 x 1(Democrat or Independent, close to Democrat)"
label variable leanRep "100 x 1(Republican or Independent, close to Republican)"
label variable leanInd "100 x 1(Independent, neither party)"

label variable Dem_self "100 x 1(Democrat)"
label variable Rep_self "100 x 1(Republican)"
label variable Ind_self "100 x 1(Independent)"

rename numwfh_days_postcovid_boss_s_u_l numwfh_days_postCOVID_boss_s_u_l

label variable numwfh_days_postCOVID_boss_s_u_l "Employer planned share of paid working days WFH after COVID (%) - this version does not reclassify workers w/o clear indications from their employers based on current working status"



label variable infection_labsearch_avoid "In my job search, I avoid jobs with high infection risk"
label variable infection_labsearch_highpay "In my job search, I require higher pay for jobs with high infection risk"
label variable infection_labsearch_benefits "In my job search, I require higher benefits for jobs with high infection risk" 
label variable infection_labsearch_wfhpref "In my job search, I prefer jobs allowing me to work from home" 
label variable infection_labsearch_no "Worries about infection don't affect my job search'"

label variable labsearch_qual "Which of the following best describes your job search (with respect to WFH)?"

label variable infection_lfp "Are worries about catching COVID or other infectious diseases a factor in your decision not to seek work at this time?"
label variable wfh_lfp "Would you start seeking work if you were guaranteed to find a job allowing you to work from home?"

label variable coworkers_samedays_pref "Would you like your co-workers to come into work on the same days as you?"
label variable wfh_coordinate_eff "Which of the following would make your job more efficient?"
label variable wfh_coordinate_pref "Which of the following would you prefer?"
label variable wbp_smallmeet_pref "When you are working on your employer's premises, how would you like to hold small meetings with your coworkers?"


label variable wfh_top3benefits_commute "Top 3 benefits of WFH include: No commute"
label variable wfh_top3benefits_groom "Top 3 benefits of WFH include: Less time getting ready"
label variable wfh_top3benefits_flex "Top 3 benefits of WFH include: Flexibility on when I work"
label variable wfh_top3benefits_meetings "Top 3 benefits of WFH include: Fewer meetings"
label variable wfh_top3benefits_quiet  "Top 3 benefits of WFH include: Individual quiet time"
label variable wfh_top3benefits_family  "Top 3 benefits of WFH include: More time with family/friends"
label variable wfh_top3benefits_other  "Top 3 benefits of WFH include: Other"
label variable wfh_top3benefits_num "Number of benefits of WFH chosen"

label variable wbp_top3benefits_collab "Top 3 benefits of WBP include: Face-toface collaboration" 
label variable wbp_top3benefits_social "Top 3 benefits of WBP include: Socializing" 
label variable wbp_top3benefits_facetime "Top 3 benefits of WBP include: Face time with manager"
label variable wbp_top3benefits_equip "Top 3 benefits of WBP include: Better equipment"
label variable wbp_top3benefits_quiet "Top 3 benefits of WBP include: Quiet"
label variable wbp_top3benefits_bound "Top 3 benefits of WBP include: Work/personal time boundaries"
label variable wbp_top3benefits_other  "Top 3 benefits of WBP include: Other"
label variable wbp_top3benefits_num "Number of benefits of WBP chosen"

label variable wfhcovid_cpsq "100 x (At any time in the last 4 weeks, did you telework or work at home for pay because of the coronavirus pandemic?) - numeric"

label variable wfhcovid_fracmat_all "Share of paid working days WFH this week (%), i.e. during COVID - from `matrix' days-of-week question. This version for ALL respondents (not just those currently working)"



label variable whfcovid_cpsq_posend "Equals 1 if CPS question about telework appears at the end of the survey. 0 otherwise."

label variable freq_nonwork_car "How frequently do you use a car for non-work trips? - qualitative"
label variable freq_nonwork_taxi "How frequently do you use a taxi/rideshare for non-work trips? - qualitative" 
label variable freq_nonwork_transit  "How frequently do you use public transit for non-work trips? - qualitative"
label variable freq_nonwork_bike "How frequently do you use a bicycle for non-work trips? - qualitative"
label variable freq_nonwork_walk "How frequently do you walk for non-work trips? - qualitative"

label variable worktime_nonremoteable_pct "What percentage of your total working time do you usually spend on tasks that cannot be done remotely?"

label variable workstatus_current_d "Currently (this week) what is your work status - detailed version prior to November 2020"

label variable income_year "Year corresponding to the main labor earnings question used to construct weights for the respondent."

label variable infectionfear_car "On a scale of 0 to 4, how concerned are you about getting infected with a serious illness (e.g. COVID-19) each time you travel by car?"
label variable infectionfear_taxi "On a scale of 0 to 4, how concerned are you about getting infected with a serious illness (e.g. COVID-19) each time you travel by taxi/rideshare?" 
label variable infectionfear_bus "On a scale of 0 to 4, how concerned are you about getting infected with a serious illness (e.g. COVID-19) each time you travel by bus?" 
label variable infectionfear_subway "On a scale of 0 to 4, how concerned are you about getting infected with a serious illness (e.g. COVID-19) each time you travel by subway?" 
label variable infectionfear_train "On a scale of 0 to 4, how concerned are you about getting infected with a serious illness (e.g. COVID-19) each time you travel by commuter train?" 
label variable infectionfear_bikewalk "On a scale of 0 to 4, how concerned are you about getting infected with a serious illness (e.g. COVID-19) each time you travel by bicycle or walking?" 

label variable forcedchoice_prefer "If your employer said you need to come to work in person two days a week, which would you prefer?"

label variable wfh_interviewing "Has working from home made it easier or harder to interview for prospective new jobs?"

label variable work_facility "What type of facility best describes where you work (or worked in your most recent job)?"

label variable mask_indoorsatwork "In the past week, how often did you wear a face mask indoors at work?"
label variable mask_outdoorsleisure "In the past week, how often did you wear a face mask outdoors for leisure?" 
label variable mask_whendriving "In the past week, how often did you wear a face mask when driving your own car?"
label variable mask_home "In the past week, how often did you wear a face mask in your own house?"
label variable mask_indoorsleisure "In the past week, how often did you wear a face mask indoors for leisure?"

label variable work_computer_pct "When working, what percentage of the time are you using a laptop or desktop computer?"

label variable occupation_clean "Occupation (self-reported and reassigning 'Other' occupations based on description)"

label variable sum3plus4 "What is 3 + 4?"


label variable boss_plan_implement "Are you already following your employer's plan for post-COVID working arrangements?"

label variable interview_time_remote "How many hours does it take to interview for a prospective job via an online interview?"
label variable interview_time_inperson "How many hours does it take to interview for a prospective job via an in-person interview?"

label variable employer_days_meet "Last week, did you come into work as many days as your employer wanted you to come in?"

label variable wbp_days_comein "Days came into work last week"
label variable wbp_days_empwant "Days employer wanted you to come into work"

label variable fewerdays_punishment "How has your employer responded to employees who work on business premises fewer days than requested?"

label variable handshake_current "Currently, when you are introduced to somebody at work, what do you do?"




label variable fewerdays_nothing "Nothing - if come into work less than employer requests"
label variable fewerdays_verbal "Verbal reprimand - if come into work less than employer requests"
label variable fewerdays_perfrev "Negative performance review - if come into work less than employer requests" 
label variable fewerdays_lesspay "Pay cut or bonus - if come into work less than employer requests" 
label variable fewerdays_threat "Threat to terminate - if come into work less than employer requests"
label variable fewerdays_terminate "Termination - if come into work less than employer requests"
label variable fewerdays_other "Other - if come into work less than employer requests" 
label variable fewerdays_dontknow "Don't know - if come into work less than employer requests"
label variable fewerdays_user "User input for other - if come into work less than employer requests"


label variable failcomplete_nothing "Nothing - if consistently fail to complete work on time"
label variable failcomplete_verbal "Verbal reprimand - if consistently fail to complete work on time"
label variable failcomplete_perfrev "Negative performance review - if consistently fail to complete work on time" 
label variable failcomplete_lesspay "Pay cut or bonus - if consistently fail to complete work on time" 
label variable failcomplete_threat "Threat to terminate - if consistently fail to complete work on time"
label variable failcomplete_terminate "Termination - if consistently fail to complete work on time"
label variable failcomplete_other "Other - if consistently fail to complete work on time" 
label variable failcomplete_dontknow "Don't know - if consistently fail to complete work on time"
label variable failcomplete_user "User input for other - if consistently fail to complete work on time"

foreach var in infection_labsearch_avoid_nofi infection_labsearch_highpay_nofi infection_labsearch_benef_nofi infection_labsearch_wfhpref_nofi infection_labsearch_no_nofi labsearch_qual_nofi infection_lfp_nofi wfh_lfp_nofi {
	
	label variable `var' "Indicator equal to 1 if 'No' option shown first for `var' question"
	
}

label variable npeople_engage_work_cat "During a typical workday, how many coworkers, customers, and clients do you engage in person or by video?"

label variable meetings_workday_pct "What percentage of your typical workday do you spend meeting or talking to people?"
label variable meetings_cow_pct "What percentage of your typical workday do you spend in meetings that include coworkers?"
   


   
rename nilf_mainreason_hps_clean nilf_mainreason_HPS_clean   
label variable nilf_mainreason_HPS_clean "What is your main reason for not working for pay or profit?"

label variable big5_vividimagination "Big 5: I have a vivid imagination"
label variable big5_sympathize "Big 5: I sympathize with others' feelings"
label variable big5_makeamess "Big 5: I make a mess of things"
label variable big5_lifeoftheparty "Big 5: I am the life of the party"
label variable big5_moodswings "Big 5: I have frequent mood swings"
label variable big5_donttalk "Big 5: I don't talk a lot"
label variable big5_notabstract "Big 5: I am not interested in abstract ideas"
label variable big5_forgetputback "Big 5: I often forget to put things back in their proper place"
label variable big5_seldomblue  "Big 5: I seldom feel blue"
label variable big5_notinterestedothers "Big 5: I am not really interested in others"
label variable big5_feelothersemotions "Big 5: I feel others' emotions"
label variable big5_getupseteasily "Big 5: I get upset easily"
label variable big5_getchoresdone "Big 5: I get chores done right away"
label variable big5_notgoodimagination "Big 5: I do not have a good imagination"
label variable big5_keepinbackground "Big 5: I keep in the background"
label variable big5_diffabstract "Big 5: I have difficulty understanding abstract ideas"
label variable big5_relaxed "Big 5: I am relaxed most of the time"
label variable big5_nototherproblems "Big 5: I am not interested in other people's problems" 
label variable big5_talktodiffpeople "Big 5: I talk to a lot of different people at parties"
label variable big5_likeorder "Big 5: I like order"

label variable job_att_rank_advance "Job attributes rank: chances for advancement (1 = Most important)"
label variable job_att_rank_important "Job attributes rank: important and feeling of accomplishment (1 = Most important)"
label variable job_att_rank_nofire "Job attributes rank: No danger of being fired (1 = Most important)"
label variable job_att_rank_income "Job attributes rank: High income (1 = Most important)"
label variable job_att_rank_hours "Job attributes rank: Short working hours, lots of free time (1 = Most important)"


label variable life_rank_family "Life priorities: Family (1 = Most important)"
label variable life_rank_friends "Life priorities: Friends (1 = Most important)"
label variable life_rank_work "Life priorities: Work (1 = Most important)"
label variable life_rank_politics "Life priorities: Politics (1 = Most important)"
label variable life_rank_leisure "Life priorities: Leisure time (1 = Most important)"
label variable life_rank_religion "Life priorities: Religion/spirituality (1 = Most important)"

label variable work_firm_succeed "I am willing to work harder to help the firm I work for succeed."   


label variable wfh_top3benefits_gaslunch "Top 3 benefits of WFH include: Saving on gas and lunch costs"
label variable wbp_top3benefits_mentoring "Top 3 benefits of WBP include: Better professional development, learning, mentoring"

rename csa_job_curr CSA_job_curr
label variable CSA_job_curr "Combined Statistical Area (City) of current job's business premises"
rename csa_live_curr CSA_live_curr
label variable CSA_live_curr "Combined Statistical Area (City) of current residence"

rename wfh_eff_nocovid_randi wfh_eff_noCOVID_randi
label variable wfh_eff_noCOVID_randi "Binary indicator for whether we randomized response options in the efficiency question"



label variable work_industry_tech "Is your current (or most recent) job in the tech sector?"

rename habitsrev_postcovid habitsrev_postCOVID
label variable habitsrev_postCOVID "Same as habits_postCOVID but with reverse order of response options"

label variable jobsearch_changes_order "Order of response options: infection_labsearch_* questions"
label variable jobsearch_wfh_order "Order of response options: labsearch_qual question"
label variable notlooking_reasons_order "Order of response options: infection_lfp"      
label variable start_looking_order "Order of response options: wfh_lfp"

rename wfh_eff_nocovid_order wfh_eff_noCOVID_order
label variable wfh_eff_noCOVID_order "Order of options shown in wfh_eff_noCOVID_qual" 



label variable manage_employees_qual "Do you directly manage or supervise other employees in your organization?"
label variable manage_employees_quant "How many employees do you directly manage or supervise?"


label variable mycamera_on_2to4person "During 2 to 4 person work meetings on video-conferencing platforms, how often do you have your camera on?"
label variable mycamera_on_5to10person "During 5 to 10 person work meetings on video-conferencing platforms, how often do you have your camera on?"
label variable mycamera_on_10to30person "During 10 to 30 person work meetings on video-conferencing platforms, how often do you have your camera on?"
label variable mycamera_on_30plusperson "During >30 person work meetings on video-conferencing platforms, how often do you have your camera on?"

label variable othcamera_on_2to4person "During 2 to 4 person work meetings on video-conferencing platforms, how often do others have their camera on?"
label variable othcamera_on_5to10person "During 5 to 10 person work meetings on video-conferencing platforms, how often do others have their camera on?"
label variable othcamera_on_10to30person "During 10 to 30 person work meetings on video-conferencing platforms, how often do others have their camera on?"
label variable othcamera_on_30plusperson "During >30 person work meetings on video-conferencing platforms, how often do others have their camera on?"

label variable mycamera_eff_2to4person "During 2 to 4 person work meetings on video-conferencing platforms, how does having your camera on (showing your face) impact your engagement?"
label variable mycamera_eff_5to10person "During 5 to 10 person work meetings on video-conferencing platforms, how does having your camera on (showing your face) impact your engagement?"
label variable mycamera_eff_10to30erson "During 10 to 30 person work meetings on video-conferencing platforms, how does having your camera on (showing your face) impact your engagement?"
label variable mycamera_eff_30plusperson "During >30 person work meetings on video-conferencing platforms, how does having your camera on (showing your face) impact your engagement?" 

label variable othcamera_eff_2to4person "During 2 to 4 person work meetings on video-conferencing platforms, how does having their camera on (showing their face) impact others' engagement?"
label variable othcamera_eff_5to10person "During 5 to 10 person work meetings on video-conferencing platforms, how does having their camera on (showing their face) impact others' engagement?"
label variable othcamera_eff_10to30person "During 10 to 30 person work meetings on video-conferencing platforms, how does having their camera on (showing their face) impact others' engagement?"
label variable othcamera_eff_30plusperson "During >30 person work meetings on video-conferencing platforms, how does having their camera on (showing their face) impact others' engagement?"

label variable camera_column_order "Order of responses shown for camera questions - low_to_high or high_to_low"


label variable random_day_of_week "Day of week reference for interaction question"
label variable work_random_dow "Last random_day_of_week did you: WFH, come into work, or not work?"
label variable work_random_dow_d "Last random_day_of_week which of the following did you do? - DETAILED VERSION of work_random_dow"

label variable mins_getting_mentored  "Interaction: getting mentored (mins)"
label variable mins_mentoring_others "Interaction: mentoring others (mins)"
label variable mins_disc_ownperform "Interaction: discussing your performance w/ supervisor (mins)"
label variable mins_disc_othperform "Interaction: discussing performance of managees (mins)"
label variable mins_training "Interaction: training (mins)"
label variable mins_profdev "Interaction: professional development and learning (mins)"

label variable limit_vigorous "Does your health currently limit you in doing vigorous activities?"
label variable limit_moderate "Does your health currently limit you in doing moderate activities?"
label variable limit_lifting "Does your health currently limit you in lifting/carrying groceries?"
label variable limit_severalflights "Does your health currently limit you in climbing several flights of stairs?"
label variable limit_oneflight "Does your health currently limit you in climbing one flight of stairs?"
label variable limit_kneeling "Does your health currently limit you in bending, kneeling, or stopping?"
label variable limit_mileplus "Does your health currently limit you in walking more than one mile?"
label variable limit_severalblocks "Does your health currently limit you in walking several blocks?"
label variable limit_oneblock "Does your health currently limit you in walking one block?"
label variable limit_bathdress "Does your health currently limit you in bathing or dressing yourself?"

label variable subj_wellbeing "Subjective wellbeing ladder - best life at 10 worst at 0, on which step do you currently stand?"



label variable children_household_yesno "Are there children under 18 living in your household?"

label variable covid_test_positive "Have you had a positive diagnosis for COVID-19?"
label variable covid_believe_positive "Despite not testing positive, do you believe you have had COVID-19?"
label variable covid_long_qual "Did you have any symptoms lasting 3 months or longer that you did not have prior to having COVID?"
label variable covid_long_close_qual "Have any close friends or family members experienced COVID symptoms lasting 3 months or longer?" 
label variable covid_vuln_care_qual "Do you live with or care for someone who would be more vulnerable than the general population to COVID or other infectious diseases? "





label variable ever_meet_coworkers "Do you ever meet with your coworkers in person?"
label variable long_meet_coworkers "When you do meet your coworkers, for how long do you meet?"

label variable workday_exercise "Last [random day of the week] EXERCISED during the workday"
label variable workday_readleisure "Last [random day of the week] READ FOR LEISURE during the workday"
label variable workday_gaming "Last [random day of the week] PLAYED A PHONE/COMPUTER GAME during the workday"
label variable workday_chores "Last [random day of the week] DID CHORES during the workday"
label variable workday_childcare "Last [random day of the week] DID CHILDCARE during the workday"
label variable workday_errands "Last [random day of the week] DID PERSONAL ERRANDS during the workday"
label variable workday_other "Last [random day of the week] DID OTHER during the workday"
label variable workday_none "Last [random day of the week] DID NONE OF THE ABOVE during the workday"
label variable workday_alcohol "Last [random day of the week] DRANK ALCOHOL during the workday"

label variable workcomm_email "Uses EMAIL to communicate for work purposes"
label variable workcomm_slack "Uses SLACK to communicate for work purposes"
label variable workcomm_textpersonal "Uses MESSAGING ON PERSONAL PHONE to communicate for work purposes"
label variable workcomm_zoom "Uses ZOOM to communicate for work purposes"
label variable workcomm_teams "Uses MICROSOFT TEAMS to communicate for work purposes"
label variable workcomm_officephone "Uses OFFICE PHONE CALLS to communicate for work purposes"
label variable workcomm_personalphone "Uses HOME/PERSONAL PHONE CALLS to communicate for work purposes"
label variable workcomm_none "Uses NONE OF THE ABOVE to communicate for work purposes"

label variable workcomm_freq_email "How often do you use EMAIL to communicate for work purposes?"
label variable workcomm_freq_slack "How often do you use SLACK to communicate for work purposes?"
label variable workcomm_freq_textpersonal "How often do you use MESSAGING ON PERSONAL PHONE to communicate for work purposes?"
label variable workcomm_freq_zoom "How often do you use ZOOM to communicate for work purposes?"
label variable workcomm_freq_teams "How often do you use MICROSOFT TEAMS to communicate for work purposes?"
label variable workcomm_freq_officephone "How often do you use OFFICE PHONE CALLS to communicate for work purposes?"
label variable workcomm_freq_personalphone "How often do you use PERSONAL PHONE CALLS to communicate for work purposes?"

label variable overlook_email "How often do you overlook work-related EMAIL communications?"
label variable overlook_slack "How often do you overlook work-related SLACK communications?"
label variable overlook_textpersonal "How often do you overlook work-related TEXT MESSAGES ON YOUR PERSONAL PHONE?"
label variable overlook_zoom "How often do you overlook work-related ZOOM communications?"
label variable overlook_teams "How often do you overlook work-related MICROSOFT TEAMS communications?"
label variable overlook_officephone "How often do you overlook work-related CALLS ON YOUR OFFICE PHONE"
label variable overlook_personalphone "How often do you overlook work-related CALLS ON YOUR PERSONAL PHONE?"

label variable afterhours_email "How often do you respond to work-related EMAIL communications after hours or on weekends?" 
label variable afterhours_slack "How often do you respond to work-related SLACK communications after hours or on weekends?"
label variable afterhours_textpersonal "How often do you respond to work-related TEXT MESSAGES ON YOUR PERSONAL PHONE after hours or on weekends?" 
label variable afterhours_zoom "How often do you respond to work-related ZOOM communications after hours or on weekends?" 
label variable afterhours_teams "How often do you respond to work-related MICROSOFT TEAMS communications after hours or on weekends?" 
label variable afterhours_officephone "How often do you respond to work-related CALLS ON YOUR OFFICE PHONE after hours or on weekends?" 
label variable afterhours_personalphone "How often do you respond to work-related CALLS ON YOUR PERSONAL PHONE after hours or on weekends?" 


label variable workday_split_indiv "Individual Work % Split of Last Random Day of Week"
label variable workday_split_meet2to4 "2 to 4 Person Meetings % Split of Last Random Day of Week"
label variable workday_split_meet5plus "5 or More Person Meetings % Split of Last Random Day of Week"
label variable workday_split_lunch "Lunch % Split of Last Random Day of Week"
label variable workday_split_downtime "Downtime % Split of Last Random Day of Week"

label variable sick_lastweek_qual "Were you feeling sick, ill, or injured on any days last week?"
label variable sick_lastweek_quant "On how many workdays did you feel sick, ill or injured last week?"
label variable sick_lastweek_workanyway "Sick/Ill/Injured Days Last Week You WORKED ANYWAY"
label variable sick_lastweek_wfh "Sick/Ill/Injured Days Last Week You WORKED FROM HOME"
label variable sick_lastweek_notwork "Sick/Ill/Injured Days Last Week You DIDN'T WORK"



label variable usual_days_perweek "Usual number of days worked per week (categorical)"

label variable ioneyearahead "Saw version of worker desires/employer plans saying `one year ahead'"
label variable iextratime_new "Saw version of extratime question saying `while you WFH'"

label variable onewaytrip_fullremote "How long would it take to travel (one-way) from your home to your employer's location?"


label variable compress_feel_hoursconst "How would you feel about compressing your workweek into 4 days, while continuing to work the same number of hours over the week?"
label variable compress_feel_workconst "How would you feel about compressing your workweek into 4 days, while doing the same amount of work over the week?"
label variable compress_feel_hoursconst_qual "How much of a pay raise/cut do you value compressing your workweek into 4 days, while continuing to work the same number of hours over the week?"
label variable compress_feel_workconst_qual "How much of a pay raise/cut do you value compressing your workweek into 4 days, while doing the same amount of work over the week?"
label variable compress_feel_hoursconst_quant "How much of a pay raise/cut do you value compressing your workweek into 4 days, while continuing to work the same number of hours over the week?"
label variable compress_feel_workconst_quant "How much of a pay raise/cut do you value compressing your workweek into 4 days, while doing the same amount of work over the week?"

label variable prefer_4d10h_5d8h "Which do you prefer: working 4-days per week for 10 hours or 5 day per week for 8 hours?"
label variable manager_4day_shift "In the past 12 months, has your manager spoken to you about shifting to a 4-day workweek?"

label variable wfh_able_intcount_cont "How much would your efficiency working from home increase if you had perfect high-speed internet?"

label variable work_alldays_mat "Total number of days working 6+hours last week - from matrix question w/o restricting by work status"
label variable work_wfhdays_mat "Total number of days working from home last week - from matrix question w/o restricting by work status"
label variable work_wbpdays_mat "Total number of days working on employer/client premises last week - from matrix question w/o restricting by work status"

label variable birth_year "What year were you born?"   

label variable employer_emp_cat "Counting all of its locations, how many employees work for your primary employer?"

label variable live_adults_partner "Binary indicator for whether living with a spouse/domestic partner"





label variable employer_censusbirth_cat_d "When did your your employer hire its first employee (at any location)? - Breakdown pre-2006"
label variable employer_mylocbirth_cat_d "When did your employer start operations at the location you are assigned to? - Breakdown pre-2006"

label variable fullremote_payvary "As a fully remote employee, does your pay depend on where you live?"

label variable sick_lastweek_type "Last week, when you felt sick/ill/injured were you: sick/ill contagious, sick/ill NOT contagious, or injured?"

label variable two_video_calls "Have you ever been on two video calls at the same time?"
label variable talktext_during_calls "How often do you talk to or text your family or friends while on a work call on Zoom/Teams/Webex or similar?"
label variable multitask_during_calls_num "When you are on work calls on Zoom/Teams/Webex what share of the time are you multi-tasking? - numerical"
label variable multitask_during_calls_cat "When you are on work calls on Zoom/Teams/Webex what share of the time are you multi-tasking? - categorical"
label variable multitask_during_calls_catq "When you are on work calls on Zoom/Teams/Webex what share of the time are you multi-tasking? - quantitative from cat"

label variable howlong_resi_current "How long have you lived in your current residence?"

label variable manager_4day_ntimes "How many times in the past 12 months has your manager spoken to you about shifting to a 4-day workweek?"
label variable manager_4day_recent "When did your manager speak to you most recently about shifting to a 4-day workweek?"
label variable manager_4day_message "What was your manager's message when they most recently spoke to you about shifting to a 4-day workweek?"

label variable commknow_ftjobs "Do any of your employers know you have another full-time job?"
label variable num_ftjobs "How many full-time jobs do you currently have? - qualitative"




label variable cps_telework23_yesno "At any time LAST WEEK did you telework or work at home for pay?"
label variable cps_telework20_yesno "Did you telework or work at home for pay in February 2020 before the COVID-19 pandemic started?"
label variable cpsalt_telework23_yesno "Did you spend any time LAST WEEK working at home for your job?"
label variable cpsalt_telework20_yesno "Did you spend any time working at home for your job in February 2020 before the COVID-19 pandemic started?"


label variable cps_telework23_hours "Last week, you worked N hours. How many of these hours did you telework or work at home for pay?"
label variable cpsalt_telework23_hours "Last week, you worked N hours. How many of these hours did you work at home (or at a friends place, coffee shop, or the like)?"

label variable cps_telework20_moreless "LAST WEEK, did you do more, less, or the same amount of telework or work at home for pay as in February 2020 (before the COVID-19 pandemic)?"
label variable cpsalt_telework20_moreless "LAST WEEK did you do more, less or the same amount of work at home for your job as in February 2020 (before the COVID-19 pandemic)?"

label variable cps_remote_hours_pct "Percent of hours worked last week that you teleworked or worked at home for pay"
label variable cpsalt_remote_hours_pct "Percent of hours worked last week that you worked at home (or a friend's place, coffee shop, or other location)"

label variable ilowquality "Indicator for low quality data."

label variable education_ss "Education - categorical with only 4 values"


label variable pets_no "Do you live with any pets? - No"
label variable pets_dogs "Do you live with any pets? - Yes, dog(s)"
label variable pets_cats "Do you live with any pets? - Yes, cat(s)"
label variable pets_fish "Do you live with any pets? - Yes, fish"
label variable pets_rabbits "Do you live with any pets? - Yes, rabbit(s)"
label variable pets_rodents "Do you live with any pets? - Yes, hamster(s)/rats(s)/guinea pig(s)"
label variable pets_reptiles "Do you live with any pets? - Yes, lizard(s), turtle(s), or snake(s)"
label variable pets_birds "Do you live with any pets? - Yes, owl(s), falcon(s), or other bird(s)"
label variable pets_other "Do you live with any pets? - Yes, other"


label variable workday_hours_videocall "Hours in video or phone calls last random_day_of_week"
label variable workday_hours_f2fmeeting "Hours in face-to-face meetings last random_day_of_week" 
label variable workday_hours_textemail  "Hours in text or email conversations last random_day_of_week"
label variable workday_hours_indivwork  "Hours doing individual work last random_day_of_week" 
label variable workday_hours_downtime  "Hours of downtime last random_day_of_week"

label variable workday_pct_videocall "Percent of workday in video or phone calls last random_day_of_week"
label variable workday_pct_f2fmeeting "Percent of workday in video call or phone last random_day_of_week" 
label variable workday_pct_textemail "Percent of workday in text or email conversations last random_day_of_week"
label variable workday_pct_indivwork "Percent of workday doing individual work last random_day_of_week"
label variable workday_pct_downtime "Percent of workday on downtime last random_day_of_week"

label variable wfh_ideal_physical_health "If you worked 5 days/week, how many WFH days/week would be best for your physical health?"
label variable wfh_ideal_mental_health "If you worked 5 days/week, how many WFH days/week would be best for your mental health?"


* For some reason Stata loads some variables twice so dropping the duplicates
cap drop v181
cap drop v182
cap drop v246
cap drop v247
cap drop v374
cap drop v428
cap drop v375

cap drop v535 
cap drop v536 
cap drop v537 
cap drop v538 
cap drop v539

cap drop v540 
cap drop v541 
cap drop v542 
cap drop v543

cap drop v429
cap drop v550

cap drop v248

********************************************************************************
* Label the values of categorical variables
********************************************************************************

********************************************************************************
* Age
label define agebin_lbl 1 "Under 20"
label define agebin_lbl 2 "20 - 29", add
label define agebin_lbl 3 "30 - 39", add
label define agebin_lbl 4 "40 - 49", add
label define agebin_lbl 5 "50 - 64", add
label define agebin_lbl 6 "65+", add
label values agebin agebin_lbl

********************************************************************************
* Education (there are two similar variables)
label define education_lbl 1 "Less than high-school graduation"
label define education_lbl 2 "High-school graduation", add
label define education_lbl 3 "1 to 3-years of college", add
label define education_lbl 4 "4 years of college degree", add
label define education_lbl 5 "Masters or Professional Degree", add
label define education_lbl 6 "PhD", add
label values education education_lbl

label define education_s_lbl 1 "Less than high-school degree"
label define education_s_lbl 2 "High-school degree", add
label define education_s_lbl 3 "1 to 3-years of college", add
label define education_s_lbl 4 "4-year college degree", add
label define education_s_lbl 5 "Graduate degree", add
label values education_s education_s_lbl

********************************************************************************
* Efficiency WFH during COVID relative to expectations
label define wfh_expect_lbl 1 "Hugely better, 20%+ "
label define wfh_expect_lbl 2 "Substantially better - 10 to 20% ", add
label define wfh_expect_lbl 3 "Better -- up to 10% ", add
label define wfh_expect_lbl 4 "About the same ", add
label define wfh_expect_lbl 5 "Worse - up to 10% ", add
label define wfh_expect_lbl 6 "Substantially worse - 10 to 20% ", add
label define wfh_expect_lbl 7 "Hugely worse, 20%+ ", add
label values wfh_expect wfh_expect_lbl

********************************************************************************
* Current working status
label define workstatus_current_lbl 1 "Working on my business premises"
label define workstatus_current_lbl 2 "Working from home", add
label define workstatus_current_lbl 3 "Not working", add
label values workstatus_current workstatus_current_lbl 

********************************************************************************
* Income categories (coarse and fine)
label define iincomebin_lbl 0 "$10k to $20k" 1 "$20k to $50k" 2 "$50k to $100k" 3 "$100k to $150k" 4 "$150k+"
label values iincomebin iincomebin_lbl

label define income_cat_lbl 2 "10k - 20k"
label define income_cat_lbl 3 "20k - 30k", add
label define income_cat_lbl 4 "30k - 40k", add
label define income_cat_lbl 5 "40k - 50k", add
label define income_cat_lbl 6 "50k - 60k", add
label define income_cat_lbl 7 "60k - 70k", add
label define income_cat_lbl 8 "70k - 80k", add
label define income_cat_lbl 9 "80k - 100k", add
label define income_cat_lbl 10 "100k - 125k", add
label define income_cat_lbl 11 "125k - 150k", add
label define income_cat_lbl 12 "150k - 200k", add
label define income_cat_lbl 13 "200k - 500k", add
label define income_cat_lbl 14 "500k +", add
label values income_cat income_cat_lbl

********************************************************************************
* Census division (broad region) of residence
label define censusdiv_lbl 1 "New England" 2 "Mid-Atlantic" 3 "East North Central" 4 "West North Central" 5 "South Atlantic" 6 "East South Central" 7 "West South Central" 8 "Mountain" 9 "Pacific"
label values censusdivision censusdiv_lbl

********************************************************************************
* Industry of current job
label define work_industry_lbl 1 "Agriculture", 
label define work_industry_lbl 2 "Arts & Entertainment", add 
label define work_industry_lbl 3 "Finance & Insurance", add 
label define work_industry_lbl 4 "Construction", add 
label define work_industry_lbl 5 "Education", add
label define work_industry_lbl 6 "Health Care & Social Assistance", add
label define work_industry_lbl 7 "Hospitality & Food Services", add
label define work_industry_lbl 8 "Information", add
label define work_industry_lbl 9 "Manufacturing", add
label define work_industry_lbl 10 "Mining", add
label define work_industry_lbl 11 "Professional & Business Services", add
label define work_industry_lbl 12 "Real Estate", add
label define work_industry_lbl 13 "Retail Trade", add
label define work_industry_lbl 14 "Transportation and Warehousing", add
label define work_industry_lbl 15 "Utilities", add
label define work_industry_lbl 16 "Wholesale Trade", add
label define work_industry_lbl 17 "Government", add
label define work_industry_lbl 18 "Other", add
label values work_industry work_industry_lbl

********************************************************************************
* Sex
* Note: gender_d includes the "Other/prefer not to say option" while gender
*       focuses on male/female (sex only)
label define gender_lbl 1 "Female"
label define gender_lbl 2 "Male", add
label define gender_lbl 3 "Other/prefer not to say", add
label values gender_d gender_lbl

label values gender gender_lbl

********************************************************************************
* Desired post-COVID working from home days, for both categorical versions
* (bundled and unbundled "Rarely" and "Never" categories)
* 
* In December 2021 we began a transition to question text that says "After the pandemic ends," instead of "After COVID, in 2022 and later". The transition to the new wording will be complete in January 2022.

foreach var in wfh_days_postCOVID {
	
	label define `var'_s_lbl 1 "Never"
	label define `var'_s_lbl 2 "Rarely (e.g. monthly)", add
	label define `var'_s_lbl 3 "1 day per week", add
	label define `var'_s_lbl 4 "2 days per week", add
	label define `var'_s_lbl 5 "3 days per week", add
	label define `var'_s_lbl 6 "4 days per week", add
	label define `var'_s_lbl 7 "5 days per week", add
	label values `var'_s `var'_s_lbl
	
}

label define wfh_days_postCOVID_ss_lbl 1 "Rarely or never"
label define wfh_days_postCOVID_ss_lbl 2 "1 day per week", add
label define wfh_days_postCOVID_ss_lbl 3 "2 days per week", add
label define wfh_days_postCOVID_ss_lbl 4 "3 days per week", add
label define wfh_days_postCOVID_ss_lbl 5 "4 days per week", add
label define wfh_days_postCOVID_ss_lbl 6 "5 days per week", add
label values wfh_days_postCOVID_ss wfh_days_postCOVID_ss_lbl


********************************************************************************
* Employer planned post-COVID working from home days, for both categorical versions
* (bundled and unbundled "Rarely" and "Never" categories)
*
* Also for the question of "Before the latest announcement, how often did your 
* employer plan for you to work from home after COVID, in 2022 and later?"
* 
* In December 2021 we began a transition to question text that says "After the pandemic ends," instead of "After COVID, in 2022 and later". The transition to the new wording will be complete in January 2022.

foreach var in wfh_days_postCOVID_boss {
	
	label define `var'_lbl 1 "Never"
	label define `var'_lbl 2 "Rarely", add
	label define `var'_lbl 3 "1 day per week", add
	label define `var'_lbl 4 "2 days per week", add
	label define `var'_lbl 5 "3 days per week", add
	label define `var'_lbl 6 "4 days per week", add
	label define `var'_lbl 7 "5 day per week", add
	label define `var'_lbl 8 "No clear plans from employer", add
	label define `var'_lbl 9 "No employer", add
	label values `var' `var'_lbl
	
}

label define wfh_days_postCOVID_boss_ss_lbl 1 "Rarely or never"
label define wfh_days_postCOVID_boss_ss_lbl 2 "1 day per week", add
label define wfh_days_postCOVID_boss_ss_lbl 3 "2 days per week", add
label define wfh_days_postCOVID_boss_ss_lbl 4 "3 days per week", add
label define wfh_days_postCOVID_boss_ss_lbl 5 "4 days per week", add
label define wfh_days_postCOVID_boss_ss_lbl 6 "5 day per week", add
label define wfh_days_postCOVID_boss_ss_lbl 7 "No clear plans from employer", add
label define wfh_days_postCOVID_boss_ss_lbl 8 "No employer", add
label values wfh_days_postCOVID_boss_ss wfh_days_postCOVID_boss_ss_lbl

label values wfh_days_postCOVID_boss_pre_ss wfh_days_postCOVID_boss_ss_lbl



********************************************************************************
* Ability to work from home
* Note: wfh_able is based on a question asked prior to August 2020
*       wfh_able_qual is based on a question asked from November 2020
label define wfh_able_lbl 1 "Completely, 100%+ efficient"
label define wfh_able_lbl 2 "Mostly, 80% to 90% efficient", add
label define wfh_able_lbl 3 "Partly, 50% to 70% efficient", add
label define wfh_able_lbl 4 "Barely, less than 50% efficient", add
label define wfh_able_lbl 5 "No, I cannot do my job at home", add
label values wfh_able wfh_able_lbl

label define wfh_able_qual_lbl 1 "No"
label define wfh_able_qual_lbl 2 "Yes", add
label values wfh_able_qual wfh_able_qual_lbl

********************************************************************************
* Stigma associated with working from home
label define wfh_Dperception_lbl 1 "Improved among almost all"
label define wfh_Dperception_lbl 2 "Improved among most", add
label define wfh_Dperception_lbl 3 "Improved among some", add
label define wfh_Dperception_lbl 4 "No change", add
label define wfh_Dperception_lbl 5 "Worsened among some", add
label define wfh_Dperception_lbl 6 "Worsened among most", add
label define wfh_Dperception_lbl 7 "Worsened among almost all", add
label values wfh_Dperception wfh_Dperception_lbl

********************************************************************************
* Value of working from home
* Note: wfh_feel_legacy is based on a question asked prior to August 2020
*
*       wfh_feel is based on a question asked from August 2020 to February 2021
*
*		wfh_feel_detailed uses data from September 2020 to February 2021 and uses
*		a more granular set of responses that were used during those months
*
*       The numerical variable wfh_feel_quant uses data from the underlying questions
* 

label define wfh_feel_lbl 1 "Incredibly positive, >25% raise"
label define wfh_feel_lbl 2 "Strongly positive, 15-25% raise", add
label define wfh_feel_lbl 3 "Positive, <15% raise ", add
label define wfh_feel_lbl 4 "Neutral", add
label define wfh_feel_lbl 5 "Negative, <15% paycut", add
label define wfh_feel_lbl 6 "Strongly negative, 15-25% paycut", add
label define wfh_feel_lbl 7 "Incredibly negative, >25% paycut", add
label values wfh_feel wfh_feel_lbl
label values wfh_feel wfh_feel_lbl

label define wfh_feel_detailed_lbl 1 "More than 35% raise" 2 "25 to 35% raise" 3 "15 to 25% raise" 4 "10 to 15% raise" 5 "5 to 10% raise" 6 "Less than 5% raise" 7 "Neutral" 8 "Less than 5% pay cut" 9 "5 to 10% pay cut" 10 "10 to 15% pay cut" 11 "15 to 25% pay cut" 12 "25 to 35% pay cut" 13 "More than 35% pay cut"
label values wfh_feel_detailed wfh_feel_detailed_lbl


label define wfh_feel_legacy_lbl 1 "Incredibly positive, >20% raise"
label define wfh_feel_legacy_lbl 2 "Strongly Positive, 10-20%+ raise", add
label define wfh_feel_legacy_lbl 3 "Moderately Positive, <10% raise ", add
label define wfh_feel_legacy_lbl 4 "Neutral", add
label define wfh_feel_legacy_lbl 5 "Moderately Negative, <10% paycut", add
label define wfh_feel_legacy_lbl 6 "Strongly Negative, 10-20% paycut", add
label define wfh_feel_legacy_lbl 7 "Incredibly Negative, >20% paycut", add
label values wfh_feel_legacy wfh_feel_legacy_lbl

********************************************************************************
* Efficiency while working from home
* Note: wfh_eff_COVID_legacy is based on a question asked prior to August 2020
*       wfh_eff_COVID is based on a question asked from August 2020
*       The numerical variable wfh_eff_COVID_quant uses data from both questions
label define wfh_eff_lbl 1 "Much more, >35% "
label define wfh_eff_lbl 2 "Substantially more, 15-25% ", add
label define wfh_eff_lbl 3 "More, <15%  ", add
label define wfh_eff_lbl 4 "About the same", add
label define wfh_eff_lbl 5 "Less, <15%", add
label define wfh_eff_lbl 6 "Substantially less, 15-25%", add
label define wfh_eff_lbl 7 "Much less, >35%", add
label values wfh_eff_COVID wfh_eff_lbl

label define wfh_eff_COVID_legacy_lbl 1 "Better"
label define wfh_eff_COVID_legacy_lbl 2 "About the same", add
label define wfh_eff_COVID_legacy_lbl 3 "Slightly lower -- 5 to 15%", add
label define wfh_eff_COVID_legacy_lbl 4 "Somewhat lower -- 20 to 40%", add
label define wfh_eff_COVID_legacy_lbl 5 "Much lower -- >40%", add
label values wfh_eff_COVID_legacy wfh_eff_COVID_legacy_lbl

********************************************************************************
* Goods vs. services industries
label define goodservices_lbl 1 "Goods" 2 "Services" 
label values goodservices goodservices_lbl

********************************************************************************
* Red vs blue states (based on Cook Political Report's Partisan Voting Index using the 2012/2016 elections)
label define redblue_lbl 1 "Red (Republican-leaning)" 2 "Blue (Democratic-leaning)"
label values redblue_cook redblue_lbl

********************************************************************************
* Return to pre-COVID activities
label define habits_postCOVID_lbl 1 "Completely"
label define habits_postCOVID_lbl 2 "Substantially", add
label define habits_postCOVID_lbl 3 "Partially", add
label define habits_postCOVID_lbl 4 "None", add
label values habits_postCOVID habits_postCOVID_lbl

********************************************************************************
* Living with other adults?
label define live_adults_lbl 1 "No"
label define live_adults_lbl 2 "Yes, partner/adult children", add
label define live_adults_lbl 3 "Yes, roommates/other", add
label values live_adults live_adults_lbl

********************************************************************************
* Living with children?
label define live_children_lbl 1 "No"
label define live_children_lbl 2 "Yes, youngest in pre-/primary", add
label define live_children_lbl 3 "Yes, youngest in ES ", add
label define live_children_lbl 4 "Yes, youngest is in MS", add
label define live_children_lbl 5 "Yes, youngest is in HS", add
label values live_children live_children_lbl

********************************************************************************
* Occupation (Note: this requires significant cleaning)

label define occupation_lbl 1 "Armed Forces", 
label define occupation_lbl 2 "Construction and Extraction", add 
label define occupation_lbl 3 "Farming, Fishing and Forestry", add 
label define occupation_lbl 4 "Installation, Maintenance and Repair", add 
label define occupation_lbl 5 "Management, Business and Financial", add 
label define occupation_lbl 6 "Office and Administrative Support", add 
label define occupation_lbl 7 "Production", add 
label define occupation_lbl 8 "Professional and related", add 
label define occupation_lbl 9 "Sales and related", add 
label define occupation_lbl 10 "Service", add 
label define occupation_lbl 11 "Transportation and material moving", add 
label define occupation_lbl 12 "Other", add 
label values occupation occupation_lbl
label values occupation_clean occupation_lbl

********************************************************************************
* Race ethnicity

label define race_ethnicity_lbl 1 "Black or African American"
label define race_ethnicity_lbl 2 "Hispanic (of any race)", add
label define race_ethnicity_lbl 3 "Asian", add
label define race_ethnicity_lbl 4 "Native American or Alaska Native", add
label define race_ethnicity_lbl 5 "Native Hawaiian or Pacific Islander", add
label define race_ethnicity_lbl 6 "White (non-Hispanic)", add
label define race_ethnicity_lbl 7 "Other", add
label values race_ethnicity race_ethnicity_lbl

label define race_ethnicity_s_lbl 1 "Black or African American"
label define race_ethnicity_s_lbl 2 "Hispanic (of any race)", add
label define race_ethnicity_s_lbl 3 "Other", add
label define race_ethnicity_s_lbl 4 "White (non-Hispanic)", add

label values race_ethnicity_s race_ethnicity_s_lbl

********************************************************************************
* Is time saved by not commuting part of your extra efficiency when working 
* from home? 

label define wfh_extraeff_comm_qual_lbl 1 "Yes" 2 "No"
label values wfh_extraeff_comm_qual wfh_extraeff_comm_qual_lbl

********************************************************************************
* Assuming it doesn’t matter for your pay, which working arrangements would you 
* prefer after COVID is under control?


label define  wfh_feel_new_qual_lbl 1 "Prefer 5 days/wk on employer premises" 2 "Prefer 2 days/wk WFH" 3 "About the same"
label values wfh_feel_new_qual wfh_feel_new_qual_lbl

********************************************************************************
* Does or will your employer require you to be vaccinated to work on business 
* premises?
label define vaccine_req_boss_lbl 1 "Yes" 2 "No" 3 "Employer has not announced a policy"
label values vaccine_req_boss vaccine_req_boss_lbl

********************************************************************************
* Should employers require vaccination before letting workers return to the 
* employer’s worksite?

label define vaccine_req_should_gen_lbl 1 "Yes, for all" 2 "Yes, exc. w/ medical exemptions" 3 "Yes, when job involves proximity" 4 "No, but should encourage" 5 "No, workers should decide"
label values vaccine_req_should_gen vaccine_req_should_gen_lbl

********************************************************************************
* Should your employer require vaccination before letting you and your co-workers 
* return to the worksite?

label values vaccine_req_should_myboss vaccine_req_should_gen_lbl

********************************************************************************
* If you were to work from home one more day per week than your co-workers, 
* how might this affect your chance of a promotion in the next 3 years?

label define prom_eff_lbl 1 "It would reduce my chance of a promotion" 2 "No effect" 3 "It would increase my chance of a promotion"
label values prom_eff_1day_qual prom_eff_lbl


********************************************************************************
* If you were to work from home 5+ days a week and your co-workers work on the
* business premises 5+ days a week, how might this affect your chance of a 
* promotion in the next 3 years?

label values prom_eff_5day_qual prom_eff_lbl

********************************************************************************
* Do you need to be physically present on business premises to perform your job 
* (current or most recent)?
* This is a question first asked in May 2021 instead of the previous questions
* about ability to WFH (see wfh_able and wfh_able_qual above)

label define wfh_able_qual_May_lbl 1 "Yes, for all of my job"
label define wfh_able_qual_May_lbl 2 "Yes, for part of my job", add
label define wfh_able_qual_May_lbl 3 "No", add
label values wfh_able_qual_May21 wfh_able_qual_May_lbl

********************************************************************************
* Versions of the following question asked in June 2021:
*
* For unemployed respondents:
* 	You stated that you are currently (un)employed (looking for work or awaiting recall to 	
*	your old job).
*	Suppose you got a new job offer. 
*	For a given pay, would you be more or less likely to take the job if it allowed you to 
*	work from home [ 1 / 2 to 3 / 4 to 5] day[s] a week?

* For employed respondents:
* 	You stated that you are currently employed.
* 	Suppose you got an offer for a new job with the same pay as your current job. 
* 	Would you be more or less likely  to take the new job if it let you work from home [ 1 / 2 to 3 / 4 to 5/  day[s] a week?

label define offer_lbl 1 "More likely to consider" 2 "No effect" 3 "Less likely to consider"

foreach var in offer_employed_wfh1days offer_employed_wfh23days offer_employed_wfh45days offer_unemployed_wfh1days offer_unemployed_wfh23days offer_unemployed_wfh45days {
	label values `var' offer_lbl
}

********************************************************************************
* Versions of the following question asked in June 2021.
*
* How does the efficiency of video calls for [ one-on-one and small / medium sized 
* / large ] group meetings (up to 4 people) compare to the efficiency of in-person meetings?

label define videocall_lbl 1 "Hugely better - 50+% more eff." 2 "Substantially better - 20-50% more eff." 3 "Better - up to 20+ more eff." 4 "About the same" 5 "Worse - up to 20% less eff." 6 "Substantially worse - 20-50% less eff." 7 "Hugely worse - 50+% less eff" 8 "Not applicable - no work video calls"

label values videocall_small_qual videocall_lbl
label values videocall_med_qual videocall_lbl
label values videocall_large_qual videocall_lbl


********************************************************************************
* How would you respond if your employer announced that all employees must return to worksite 5+ days a week starting on August 1, 2021?

label define wbp_react_qual_lbl 1 "Comply & return" 2 "Return & look for a WFH job" 3 "Quit, even without another job", modify

label values wbp_react_qual wbp_react_qual_lbl

********************************************************************************
* How much would your efficiency working from home increase if you had perfect high-speed internet?"

label define wfh_able_intcount_lbl 1 "None, my internet is fast enough"
label define wfh_able_intcount_lbl 2 "A little, about 5% increase", add
label define wfh_able_intcount_lbl 3 "Somewhat, about 10% increase", add
label define wfh_able_intcount_lbl 4 "Substantially, about 20% increase", add
label define wfh_able_intcount_lbl 5 "Massively, 30% or more", add
label values wfh_able_intcount wfh_able_intcount_lbl

********************************************************************************
* What plans does your employer have for working arrangements of full-time 
* employees after COVID, in 2022 or later?

label define employer_arr_qual_lbl 1 "Fully on-site" 2 "Hybrid: 1 to 4 days WFH" 3 "Fully remote" 4 "No clear plans from employer" 5 "Other"

label values employer_arr_qual employer_arr_qual_lbl


********************************************************************************
* Who decides which days and how many days employees work remotely?
* 
* For employees who work from home, who decides their work-from-home schedule? (Starting December 2021)

label define who_decides_wfhdays_lbl 1 "Each employee" 2 "Each team" 3 "Company-wide common schedule" 4 "Company-wide varying schedule" 5 "No clear plans from employer" 6 "Other"

label values who_decides_wfhdays who_decides_wfhdays_lbl


********************************************************************************
* When does your employer anticipate that most of their full-time employees 
* will return to working one or more days per week on business premises?

label define employer_return_when_lbl 1 "Already back" 2 "July 2021" 3 "August 2021" 4 "September 2021" 5 "2021Q4" 6 "2022Q1" 7 "2022Q2 or later"

label values employer_return_when employer_return_when_lbl

********************************************************************************
* After COVID, in 2022 and later, how many days a week will that typical 
* employee work on business premises?

label values wfh_days_postCOVID_boss_ty wfh_days_postCOVID_boss_lbl
label values wfh_days_postCOVID_boss_ty_ss wfh_days_postCOVID_boss_ss_lbl

********************************************************************************
* Which of the following would you prefer? a) Being able to choose which days 
* you work from home (if any) b) Your employer sets a policy...

label define choice_prefer_lbl 1 "I choose which days to WFH (if any)" 2 "My employer sets a policy on WFH days"
label values choice_prefer choice_prefer_lbl

********************************************************************************
* When you return to work in person, and you are introduced to somebody will you...?
*
* Before COVID (in 2019), when you were introduced to somebody at work what did you do?
*
* Currently, when you are introduced to somebody at work, what do you do?

label define handshake_lbl 1 "Shake hands" 2 "Fist bump" 3 "Elbow bump" 4 "Not touch (verbally greet)" 5 "Other"

label values handshake_preCOVID handshake_lbl
label values handshake_postCOVID handshake_lbl
label values handshake_current handshake_lbl

********************************************************************************
* Which of the following best describes your current employment situation?

label define self_employment_lbl 1 "Wage/salary employee - primarily" 2 "Wage/salary employee - side jobs" 3 "Self employed - own business" 4 "Independent contractor/ gig worker"
label values self_employment self_employment_lbl


********************************************************************************
* Counting all locations where your primary employer operates, what is the total
* number of persons who work for your employer?
*
* Excluding yourself but including employees and independent contractors, how 
* many staff members are part of your business?

label define employer_sizecat_lbl 1 "1 to 9 staff" 2 "10 to 49 staff" 3 "50 to 99 staff" 4 "100 to 499 staff" 5 "500+ staff"
label values employer_sizecat employer_sizecat_lbl

label define ownbusiness_sizecat_lbl 1 "0 staff" 2 "1 to 9 staff" 3 "10 to 49 staff" 4 "50 to 99 staff" 5 "100+ staff"
label values ownbusiness_sizecat ownbusiness_sizecat_lbl

********************************************************************************
* Currently (this week) what is your work status? - categorical version of the 
* question asked since November 2020. 
*
* Note: `workstatus_current' uses the answers to this question in November 2020
*        and later to produce a simplified variable that conforms to earlier
*        working status questions

label define workstatus_current_new_lbl 1 "Working for pay" 2 "Employed and paid, but not working" 3 "Unemployed, searching" 4 "Unemployed, awaiting recall" 5 "Out of the labor force"

label values workstatus_current_new workstatus_current_new_lbl

********************************************************************************
* In the last six months, has your employer announced new plans about working 
* from home after the pandemic ends, in 2022 or later? - categorical

label define wfh_postCOVID_boss_ann_lbl 1 "No" 2 "Yes"
label values wfh_postCOVID_boss_ann wfh_postCOVID_boss_ann_lbl

********************************************************************************
* How does your efficiency working from home during the COVID-19 pandemic 
* compare to your efficiency working on business premises before the pandemic? - categorical
*
* How does your efficiency working from home compare to your efficiency working
* on business premises? - categorical

label define wfh_eff_COVID_qual_lbl 1 "Better" 2 "About the same" 3 "Worse"
label values wfh_eff_COVID_qual wfh_eff_COVID_qual_lbl
label values wfh_eff_noCOVID_qual wfh_eff_COVID_qual_lbl

********************************************************************************
* The variables corresponding to the following questions are not used in the 
* analysis, only for cleaning some variables in the updated results code so we 
* will drop them here
*
* How much less efficient are you while working from home than at the office 
* - if less efficient
* How much more efficient are you while working from home than at the office 
* - if more efficient
*
* How much less efficient are you while working from home than at the office
* - if less efficient & got the question that doesn't mention COVID
* How much more efficient are you while working from home than at the office 
* - if more efficient & got the question that doesn't mention COVID

drop wfh_eff_COVID_neg_d wfh_eff_COVID_pos_d wfh_eff_noCOVID_neg_d wfh_eff_noCOVID_pos_d

********************************************************************************
* How much do you enjoy your personal interactions with coworkers at your 
* employer's worksite?
*
* How much do you enjoy your personal interactions with customers, clients, or 
* patients at your employer's worksite?

label define interactions_lbl 0 "0 - not at all" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10 - very much" 11 "N/A"
label values coworker_interactions interactions_lbl
label values client_interactions interactions_lbl

********************************************************************************
* Do you have a health problem or a disability which prevents work or which 
* limits the kind or amount of work you do?
label define disability_qual_lbl 1 "Yes" 2 "No" 3 "Prefer not to answer"
label values disability_qual disability_qual_lbl

********************************************************************************
* Will your manager work from home on the same days as you after the pandemic 
* is over?
*
* Will most of your coworkers work from home on the same days as you after 
* the pandemic is over?

label define boss_wfh_samedays_lbl 1 "Yes" 2 "No" 3 "No manager"

label values boss_wfh_samedays boss_wfh_samedays_lbl

label values coworkers_wfh_samedays boss_wfh_samedays_lbl


********************************************************************************
* If your manager starts coming into your employer's place of business on some 
* of your work-from-home days, what will you do?
*
* If your coworkers start coming into your employer's place of business on some 
* of your work-from-home days, what will you do?


label define boss_wfh_unravel_lbl 1 "Keep WFH those days" 2 "Work on premises some of those days" 3 "Work on premises whenever my manager does"
label values boss_wfh_unravel boss_wfh_unravel_lbl

label define coworkers_wfh_unravel_lbl 1 "Keep WFH those days" 2 "Work on premises some of those days" 3 "Work on premises whenever my coworkers do"
label values coworkers_wfh_unravel coworkers_wfh_unravel_lbl


********************************************************************************
* Before COVID how did you typically commute to work?

label define commutemode_lbl 1 "Car"
label define commutemode_lbl 2 "Subway", add
label define commutemode_lbl 3 "Train", add
label define commutemode_lbl 4 "Bus", add
label define commutemode_lbl 5 "Walk", add
label define commutemode_lbl 6 "Bicyle", add
label define commutemode_lbl 7 "Taxi/Ride-share", add
label values commutemode commutemode_lbl 

label define commutemode_s_lbl 1 "Car"
label define commutemode_s_lbl 2 "Subway/Train/Bus/Taxi/Rideshare", add
label define commutemode_s_lbl 3 "Walk/Bicycle",add
label values commutemode_s commutemode_s_lbl


********************************************************************************
* On a scale of 0 to 10, how anxious are you about returning to work 
* on business premises?

label values wbp_return_anxious interactions_lbl

********************************************************************************
* Have you quit or voluntarily left a job in the past 6 months?

label define quit_qual_lbl 1 "Yes" 2 "No"
label values quit_qual quit_qual_lbl

********************************************************************************
* On a scale of 0 to 10, how much do you agree with the following statement?
*
* "While working from home I am less stressed because I don't feel like I am 
* constantly under supervision."

label values wfh_less_stress interactions_lbl

********************************************************************************
* In 2019 (before COVID), when you traveled to your employer's worksite, 
* approximately what time did you leave for work (e.g. 8:30am)?
*
* Currently, when you traveled to your employer's worksite, approximately what 
* time did you leave for work (e.g. 8:30am)?

label define leavetime_lbl 1 "Before 6:00am" 2 "6:00am" 3 "6:30am" 4 "7:00am" 5 "7:30am" 6 "8:00am" 7 "8:30am" 8 "9:00am" 9 "9:30am" 10 "10:00am" 11 "10:30am" 12 "After 10:30am"

label values leavetime_preCOVID leavetime_lbl
label values leavetime_current leavetime_lbl

********************************************************************************
* Do you currently have the option to work at more than one employer worksite?

label define worksite_option_lbl 1 "Yes" 2 "No"
label values worksite_option worksite_option_lbl

********************************************************************************
* Why can't you work remotely 100% of the time?

label define nonremotable_why_lbl 1 "In-person meetings w/ clients/customers" 2 "Collaborate in-person w/ colleagues" 3 "Interact physically w/ equipment" 4 "Other"
label values worktime_nonremotable_why nonremotable_why_lbl

********************************************************************************
* If your employer requires you to work on premises 3 days a week, which would you prefer?
*	Being able to choose which days you work from home (if any)
*	Your employer sets a policy that determines who works from home on which days

label define choice_dow_prefer_lbl 1 "Each person chooses which 3 days" 2 "Employer sets the same 3 days for all"
label values choice_dow_prefer choice_dow_prefer_lbl

********************************************************************************
* In 2022 and later, will your employer allow you to work from anywhere (e.g. from Hawaii without the expectation of coming into work) for one month each year?

label define wfanywhere_lbl 1 "Yes" 2 "No"
label values wfanywhere_qual wfanywhere_lbl

********************************************************************************
* For each day last week, did you work a full day (6 or more hours), and if so where (i.e. from home, on employer or client premises)?

label define workstatus_days_lbl 1 "Did not work" 2 "Worked from home" 3 "Worked on employer or client premises"

foreach day in monday tuesday wednesday thursday friday saturday sunday {
	label values workstatus_`day' workstatus_days_lbl
}

********************************************************************************
* What color is grass? The fresh, uncut grass, not leaves or hay. Make sure that you select purple as an answer so we know you are paying attention.

label define grass_color_attnfull_lbl 1 "Magenta" 2 "Green" 3 "Purple" 4 "Blue" 5 "Black" 6 "White" 7 "Brown"
label values grass_color_attn grass_color_attnfull_lbl

********************************************************************************
* Who sets your work-from-home schedule?

label define who_sets_wfhsched_lbl 1 "Self" 2 "Manager or employer" 3 "No employer policy"
label values who_sets_wfhsched who_sets_wfhsched_lbl


********************************************************************************
* What type of work-from-home schedule does your manager or employer set?

label define common_varying_sched_lbl 1 "Common schedule" 2 "Varying schedule"
labe values common_varying_sched common_varying_sched_lbl

********************************************************************************
* How often do you work from home to handle matters that require your presence 
* (e.g., to be there for a plumber, a repair person, or deliveries)?

label define wfh_handle_chores_lbl 1 "Once per week or more" 2 "Once or twice a month" 3 "Rarely or never"
label values wfh_handle_chores wfh_handle_chores_lbl


********************************************************************************
* Which of the following would you do each morning when you travel to work?
* 		Shower/bathe, Brush teeth, Use deodorant, Put on makeup, Shave, 
*		Wear fresh clothes, Set an alarm to wake up

label define groom_tasks_lbl 100 "Yes" 0 "No"

foreach var in showerbathe brushteeth deodorant makeup shave freshclothes alarm {
	
	label values `var'_wbp groom_tasks_lbl
	label values `var'_wfh groom_tasks_lbl
	
}

********************************************************************************
* What is your primary transportation mode for commuting to the 
* friend or family member's home/public space (cafe, library etc.)/co-working space 
* where you usually work?

label define commuting_modes_new_lbl 1 "Drive alone" 2 "Carpool" 3 "Public transit" 4 "Bicycle" 5 "Walk" 6 "Taxi/Ridehailing" 7 "NA"
foreach var in faf cowork public {
	label values commute_mode_`var' commuting_modes_new_lbl
}

********************************************************************************
* Generally speaking, do you usually think of yourself as a Republican, 
* Democrat, Independent, or what?

label define party_affiliation_lbl 1 "Strong Democrat" 2 "Not very strong Democrat" 3 "Independent close to Democrat" 4 "Independent (Neither party)" 5 "Independent, close to Republican" 6 "Not very strong Republican" 7 "Strong Republican" 8 "Other party" 9 "Don't know or rather not say'"
label values party_affiliation party_affiliation_lbl

label define party_affiliation_s_lbl 1 "Democrat" 2 "Independent/Other" 3 "Republican"
label values party_affiliation_s party_affiliation_s_lbl


********************************************************************************
* Which of the following best describes your job search (with respect to WFH)?

label define labsearch_qual_lbl 1 "Only considering WFH jobs" 2 "Prefer jobs allowing WFH" 3 "No preference about WFH"
label values labsearch_qual labsearch_qual_lbl 


********************************************************************************
* Are worries about catching COVID or other infectious diseases a factor in 
* your decision not to seek work at this time?"

label define infection_lfp_lbl 1 "Yes, the main reason" 2 "Yes a secondary reason" 3 "No"
label values infection_lfp infection_lfp_lbl 


********************************************************************************
* Would you start seeking work if you were guaranteed to find a job allowing 
* you to work from home?

label define wfh_lfp_lbl 1 "Yes, definitely" 2 "Yes, possibly" 3 "No"
label values wfh_lfp wfh_lfp_lbl 

********************************************************************************
* Would you like your co-workers to come into work on the same days as you?

label define coworkers_samedays_pref_lbl 1 "Yes" 2 "No"
label values coworkers_samedays_pref coworkers_samedays_pref_lbl


********************************************************************************
* Which of the following would make your job more efficient?
*	- Coworkers coordinate to come in
*	- Each coworker decides when to come in 
*	- No difference

label define wfh_coordinate_eff_lbl 1 "Coworkers coordinate to come in" 2 "Each coworker decides when to come in" 3 "No difference"
label values wfh_coordinate_eff wfh_coordinate_eff_lbl
label variable wfh_coordinate_eff "Which of the following would make your job more efficient?"

********************************************************************************
* Which of the following would you prefer?
*	- Coworkers coordinate to come in
*	- Each coworker decides when to come in 
*	- No difference

label values wfh_coordinate_pref wfh_coordinate_eff_lbl

********************************************************************************
* When you are working on your employer's premises, how would you like to hold 
* small meetings with your coworkers?

label define wbp_smallmeet_pref_lbl 1 "In person" 2 "Video call" 3 "No preference"
label values wbp_smallmeet_pref wbp_smallmeet_pref_lbl 


********************************************************************************
* How frequently do you use the following modes of transportation for non-work 
* trips (e.g. shopping, socializing, recreation)?

label define freq_nonwork_transport_lbl 1 "5+ times per week" 2 "2 to 4 times per week" 3 "Once per week" 4 "Rarely or never"

foreach var in freq_nonwork_car freq_nonwork_taxi freq_nonwork_transit freq_nonwork_bike freq_nonwork_walk {
	label values `var' freq_nonwork_transport_lbl
}

********************************************************************************
* Current working status - detailed question from prior to November 2020

label define workstatus_current_d_lbl 1 "Working on my business premises"
label define workstatus_current_d_lbl 2 "Working from home", add
label define workstatus_current_d_lbl 3 "Employed & paid, but not working", add
label define workstatus_current_d_lbl 4 "Unemployed", add
label define workstatus_current_d_lbl 5 "Not working or looking for work", add


********************************************************************************
* If your employer said you need to come to work in person two days a week, 
* which would you prefer?
*		- Come in on Tuesday and Thursday with all of my colleagues
* 		- Choose the days I come in, but with only about half of my colleagues 
*         in on any given day

label define forcedchoice_lbl 1 "Come in T/Th with all coworkers" 2 "Choose which days - no coordination"
label values forcedchoice_prefer  forcedchoice_lbl


********************************************************************************
* Has working from home made it easier or harder to interview for prospective 
* new jobs?

label define interviewing_lbl 1 "Easier" 2 "Harder" 3 "No difference" 4 "I haven't been seeking a new job"
label values wfh_interviewing interviewing_lbl


********************************************************************************
* What type of facility best describes where you work (or worked in your most 
* recent job)?
 
label define work_facility_lbl 1 "Office" 2 "Factory/warehouse" 3 "Retail/entertainment" 4 "Food/accommodation" 5 "Construction/agriculture/mining" 6 "School/university" 7 "Hospital/healthcare"
label values work_facility work_facility_lbl
 
********************************************************************************
* In the past week, how often did you wear a face mask in the following situations?
 
label define masking_lbl 1 "Never/Rarely" 2 "Ocassionally" 3 "Mostly" 4 "Always" 5 "Not relevant for me"
foreach var in mask_indoorsatwork mask_outdoorsleisure mask_whendriving mask_home mask_indoorsleisure {
	label values `var' masking_lbl
}


********************************************************************************
* Are you already following your employer's plan for post-COVID working 
* arrangements?

label define boss_plan_implement_lbl 1 "Yes" 2 "No, some/all is not yet implemented"
label values boss_plan_implement boss_plan_implement_lbl

********************************************************************************
* Last week, did you come into work as many days as your employer wanted you 
* to come in?

label define employer_days_meet_lbl 1 "Yes" 2 "No"
label values employer_days_meet employer_days_meet_lbl

********************************************************************************
* How has your employer responded to employees who work on business premises 
* fewer days than requested?

label define fewerdays_punishment_lbl 1 "Nothing" 2 "Verbal reprimand" 3 "Negative performance review" 4 "Reduction in pay/bonus" 5 "Threat to terminate" 6 "Termination" 7 "Other" 8 "Don't know"
label values fewerdays_punishment fewerdays_punishment_lbl

********************************************************************************
* During a typical workday, how many coworkers, customers, and clients do you 
* engage in person or by video? (categorical version)

label define npeople_engage_work_cat_lbl 1 "None" 2 "1 to 10" 3 "11 to 50" 4 "51 to 100" 5 "101 to 500" 6 "500 or more"
label values npeople_engage_work_cat npeople_engage_work_cat_lbl


********************************************************************************
* What is your main reason for not working for pay or profit? 
* (Question from the Household Pulse Survey)

label define nilf_mainreason_HPS_lbl 1 "Don't want to be employed" 2 "Sick/caring for someone w/ COVID" 3 "Caring for children" 4 "Caring for elderly person" 5 "Concern about catching/spreading COVID" 6 "Sick/disabled but not w/ COVID" 7 "Retired" 8 "Laid off/furloughed due to COVID pandemic" 9 "Employer out of business b/c of COVID pandemic" 10 "No transportation to work" 11 "Other reason"
label values nilf_mainreason_HPS nilf_mainreason_HPS_lbl

********************************************************************************
* Labels for the big-5 personality traits questions

label define big5_lbl 1 "Very inaccurate" 2 "Moderately inaccurate" 3 "Neither accurate nor inaccurate" 4 "moderately accurate" 5 "Very accurate"

foreach var in big5_vividimagination big5_sympathize big5_makeamess big5_lifeoftheparty big5_moodswings big5_donttalk big5_notabstract big5_forgetputback big5_seldomblue big5_notinterestedothers big5_feelothersemotions big5_getupseteasily big5_getchoresdone big5_notgoodimagination big5_keepinbackground big5_diffabstract big5_relaxed big5_nototherproblems big5_talktodiffpeople big5_likeorder {
	label values `var' big5_lbl
}


********************************************************************************
* Please indicate the extent to which you agree or disagree with the following 
* statement: "I am willing to work harder than I have to in order to help the 
* firm or organization I work for succeed."

label define work_firm_succeed_lbl 1 "Strongly agree" 2 "Agree" 3 "Neither agree nor disagree" 4 "Disagree" 5 "Strongly disagree"
label values work_firm_succeed work_firm_succeed_lbl


********************************************************************************
* Is your current (or most recent) job in the tech sector?
*
* We only asked this question to persons who reported working in the "Information"
* "Professional and Business Services" and "Other" industries.

label define work_industry_tech_lbl 1 "Yes" 2 "No"
label values work_industry_tech work_industry_tech_lbl 

********************************************************************************
* As the COVID-19 pandemic ends, which of the following would best fit your 
* views on social distancing?
*
* The variable below corresponds to a version of the question that reverses the
* order of responses

label values habitsrev_postCOVID habits_postCOVID_lbl


********************************************************************************
* Do you directly manage or supervise other employees in your organization?

label define manage_employees_lbl 1 "Yes" 2 "No" 3 "Yes, but only rarely"
label values manage_employees_qual manage_employees_lbl

********************************************************************************
* During X person work meetings on video-conferencing platforms, how often do 
* you/others have your/their camera on?

label define camera_freq_lbl 5 "Never" 4 "Occasionaly (10 - 30% of time)" 3 "Sometimes (40 - 60% of time)" 2 "Mostly (70 - 90% of time)" 1 "Always (>90% of time)" 6 "Does not apply"

label values mycamera_on_2to4person mycamera_on_5to10person mycamera_on_10to30person mycamera_on_30plusperson othcamera_on_2to4person othcamera_on_5to10person othcamera_on_10to30person othcamera_on_30plusperson camera_freq_lbl

********************************************************************************
* During X person work meetings on video-conferencing platforms, how does having
* your/others' camera on (showing your face) impact your/their engagement?

label define camera_eff_lbl 5 "Very negatively (down >50%)" 4 "Negatively (down 10 - 40%)" 3 "No impact" 2 "Positively (up 10 - 40%)" 1 "Very positively (up >50%)" 6 "Does not apply"

label values mycamera_eff_2to4person mycamera_eff_5to10person mycamera_eff_10to30erson mycamera_eff_30plusperson  othcamera_eff_2to4person othcamera_eff_5to10person othcamera_eff_10to30person othcamera_eff_30plusperson camera_eff_lbl 


********************************************************************************
* Last random_day_of_week which of the following did you do?

label define work_random_dow_lbl 1 "Worked from home" 2 "Worked on premises" 3 "Did not work"
label values work_random_dow work_random_dow_lbl

********************************************************************************
* The following items are about activities you might do during a typical day. 
* Does your health currently limit you in these activities?

label define limit_lbl 1 "Limited a lot" 2 "Limited a little" 3 "Not limited at all"
foreach var in limit_vigorous limit_moderate limit_lifting limit_severalflights limit_oneflight limit_kneeling limit_mileplus limit_severalblocks limit_oneblock limit_bathdress {
	
	label values `var' limit_lbl
}

********************************************************************************
* Are there children under 18 living in your household?

label define children_household_yesno_lbl 1 "No" 2 "Yes, 1 child" 3 "Yes, 2 children" 4 "Yes, 3 children" 5 "Yes, 4 or more children"
label values children_household_yesno children_household_yesno_lbl

********************************************************************************
* Have you had a positive diagnosis for COVID-19?

label define covid_test_positive_lbl 1 "Yes, I tested positive" 2 "No" 3 "Prefer not to say"
label values covid_test_positive covid_test_positive_lbl


********************************************************************************
* Despite not testing positive, do you believe you have had COVID-19?

label define covid_believe_positive_lbl 1 "Yes" 2 "No" 3 "Unsure"
label values covid_believe_positive covid_believe_positive_lbl

********************************************************************************
* Did you have any symptoms lasting 3 months or longer that you did not have 
* prior to having COVID?

label define covid_long_qual_lbl 1 "Yes" 2 "No" 3 "Prefer not to say"
label values covid_long_qual covid_long_qual_lbl

********************************************************************************
* Have any close friends or family members experienced COVID symptoms lasting 
* 3 months or longer?
* AND
* Do you live with or care for someone who would be more vulnerable than the general population to COVID or other infectious diseases?

label define covid_close_lbl 1 "Yes" 2 "No" 3 "Don't know/Prefer not to say"
label values covid_long_close_qual covid_vuln_care_qual covid_close_lbl


********************************************************************************
* Do you ever meet with your coworkers in person?

label define ever_meet_coworkers_lbl 1 "Never" 2 "About once per year" 3 "Once per quarter" 4 "Once per month" 5 "Twice or more per month" 6 "I don't have any coworkers"
label values ever_meet_coworkers ever_meet_coworkers_lbl

********************************************************************************
* When you do meet your coworkers, for how long do you meet?

label define long_meet_coworkers_lbl 1 "A few hours" 2 "One day" 3 "Multiple days" 4 "One workweek or more"
label values long_meet_coworkers long_meet_coworkers_lbl

********************************************************************************
* In your current job, how often do you use each of these work-related 
* communications?

label define workcomm_freq_lbl 1 "Hourly" 2 "Daily" 3 "Weekly" 4 "Once or twice per month"

foreach var in workcomm_freq_email workcomm_freq_slack workcomm_freq_textpersonal workcomm_freq_zoom workcomm_freq_teams workcomm_freq_officephone workcomm_freq_personalphone {
	label values `var' workcomm_freq_lbl
}

********************************************************************************
* In your current job, how often do you overlook work-related communications 
* on each of the following?

label define overlook_lbl 1 "Often, 1+ times per week" 2 "Sometimes, 1 or 2 times per month" 3 "Rarely or never"

foreach var in overlook_email overlook_slack overlook_textpersonal overlook_zoom overlook_teams overlook_officephone overlook_personalphone {
	
	label values `var' overlook_lbl

}

********************************************************************************
* In your current job, do you respond to work-related communications after hours
* or on weekends on any of the following?

label define afterhours_lbl 1 "Daily" 2 "Weekly" 3 "Monthly" 4 "Once or twice per year" 5 "Never"

foreach var in afterhours_email afterhours_slack afterhours_textpersonal afterhours_zoom afterhours_teams afterhours_officephone afterhours_personalphone {
	
	label values `var' afterhours_lbl
	
}	

********************************************************************************
* Last random day of week which of the following did you do? [Detailed version
* where respondents can give the location of work away from premises]

label define work_random_dow_d_lbl 1 "Worked from home" 2 "Worked on premises" 3 "Worked at a co-working space" 4 "Worked at a public space (e.g. cafe)" 5 "Worked at a friend/family member's home" 6 "Did not work" 
label values work_random_dow_d work_random_dow_d_lbl

********************************************************************************
* Were you feeling sick, ill, or injured on any days last week?"

label define sick_lastweek_lbl 1 "Yes" 2 "No"
label values sick_lastweek_qual sick_lastweek_lbl


********************************************************************************
* Usual days Worked Per Week

label define usual_days_lbl 1 "1 day per week" 2 "2 day per week" 3 "3 day per week" 4 "4 day per week" 5 "5+ day per week"
label values usual_days_perweek usual_days_lbl


********************************************************************************
* How would you feel about compressing your workweek into 4 days, while 
* [continuing to work the same number of hours] OR [doing the same amount of work]
* over the week?

label define compress_feel_lbl 1 "I would like to compress my workweek" 2 "No preference" 3 "I would not like to compress my workweek"
label values compress_feel_hoursconst compress_feel_workconst compress_feel_lbl

label define compress_feel_qual_lbl -5 ">15% pay cut" -4 "11 to 15% pay cut" -3 "6 to 10% pay cut" -2 "3 to 5% pay cut" -1 "1 to 2% pay cut" 0 "Indifferent" 1 "1 to 2% pay raise" 2 "3 to 5% pay raise" 3 "6 to 10% pay raise" 4 "11 to 15% pay raise" 5 ">15% pay raise"

foreach var in compress_feel_hoursconst compress_feel_workconst{
	
	label values `var'_qual compress_feel_qual_lbl
	
}

********************************************************************************
* Which do you prefer: working 4-days per week for 10 hours or 5 day per week 
* for 8 hours?

label define prefer_4d10h_5d8h_lbl 1 "Work 4 days/week for 10 hours/day" 2 "Work 5 days/week for 8 hours/day" 
label values prefer_4d10h_5d8h prefer_4d10h_5d8h_lbl

********************************************************************************
* In the past 12 months, has your manager spoken to you about shifting to a 
* 4-day workweek?

label define manager_4day_shift_lbl 1 "Yes" 2 "No"
label values manager_4day_shift manager_4day_shift_lbl


********************************************************************************
* Counting all of its locations, how many employees work for your primary 
* employer?

label define employer_emp_cat_lbl 1 "Fewer than 10" 2 "10 to 49" 3 "50 to 99" 4 "100 to 499" 5 "500 to 4999" 6 "5000+"
label values employer_emp_cat employer_emp_cat_lbl


********************************************************************************
* When did your your employer hire its first employee (at any location)? - 
* version with detailed breakdown for pre-2006 data
* 
* When did your employer start operations at the location you are assigned to? - 
* version with detailed breakdown for pre-2006 data

label define employer_censusbirth_cat_d_lbl 0 "2023" 1 "2022" 2 "2021" 3 "2020" 4 "2019" 5 "2018" 6 "2017" 7 "2016" 8 "2011 to 2015" 9 "2006 to 2010" 10 "2000 to 2005" 11 "1990 to 1999" 12 "1980 to 1989" 13 "Before 1980"

label define employer_mylocbirth_cat_d_lbl 0 "2023" 1 "2022" 2 "2021" 3 "2020" 4 "2019" 5 "2018" 6 "2017" 7 "2016" 8 "2011 to 2015" 9 "2006 to 2010" 10 "2000 to 2005" 11 "1990 to 1999" 12 "1980 to 1989" 13 "Before 1980" 14 "NA: Not assigned to a location"

label values employer_mylocbirth_cat_d employer_mylocbirth_cat_d_lbl
label values employer_censusbirth_cat_d employer_censusbirth_cat_d_lbl


********************************************************************************
* As a fully remote employee, does your pay depend on where you live?	

label define fullremote_payvary_lbl 1 "Yes, by location" 2 "No, same pay across the US" 
label values fullremote_payvary fullremote_payvary_lbl
	

********************************************************************************
* Last week, when you felt sick/ill/injured were you: sick/ill contagious, 
* sick/ill NOT contagious, or injured?

label define sick_lastweek_type_lbl 1 "Sick/ill: potentially contagious" 2 "Sick/ill: NOT contagious" 3 "Injured"
label values sick_lastweek_type sick_lastweek_type_lbl

********************************************************************************
* Have you ever been on two video calls at the same time?

label define two_video_calls_lbl 1 "No" 2 "Yes, once" 3 "Yes, 2 to 5 times" 4 "Yes, 6 or more times"
label values two_video_calls two_video_calls_lbl

********************************************************************************
* How often do you talk to or text your family or friends while on a work call 
* on Zoom/Teams/Webex or similar?

label define talktext_during_calls_lbl 1 "Never" 2 "Rarely, for emergencies" 3 "Once per month" 4 "Once per week" 5 "Daily"
label values talktext_during_calls talktext_during_calls_lbl

********************************************************************************
* When you are on work calls on Zoom/Teams/Webex what share of the time are you 
* multi-tasking? - categorical

label define multitask_during_calls_cat_lbl 1 "0 to 20%" 2 "20 to 40%" 3 "40 to 60%" 4 "60 to 80%" 5 "80 to 100%"
label values multitask_during_calls_cat multitask_during_calls_cat_lbl

********************************************************************************
* How long have you lived in your current residence?

label define howlong_resi_current_lbl 1 "Under 2 months" 2 "2 to 6 months" 3 "7 to 12 months" 4 "1 to 5 years" 5 "Over 5 years"
label values howlong_resi_current howlong_resi_current_lbl

********************************************************************************
* How many times in the past 12 months has your manager spoken to you about 
* shifting to a 4-day workweek?

label define manager_4day_ntimes_lbl 1 "Once" 2 "Twice" 3 "Three times" 4 "Four or more times"
label values manager_4day_ntimes manager_4day_ntimes_lbl

********************************************************************************
* When did your manager speak to you most recently about shifting to a 4-day workweek?

label define manager_4day_recent_lbl 1 "This month" 2 "Last month" 3 "2 to 6 months ago" 4 "More than 6 months ago"
label values manager_4day_recent manager_4day_recent_lbl

********************************************************************************
* What was your manager's message when they most recently spoke to you about shifting to a 4-day workweek?

label define manager_4day_message_lbl 1 "Ruled out" 2 "Under consideration" 3 "Likely, but not yet planned" 4 "Underway with plans in place"
label values manager_4day_message manager_4day_message_lbl


********************************************************************************
* How many full-time jobs do you currently have? - qualitative
* Do any of your employers know you have another full-time job?

label define num_ftjobs_lbl 1 "1 job" 2 "2 jobs" 3 "3 or more jobs"
label values num_ftjobs num_ftjobs_lbl

label define commknow_ftjobs_lbl 1 "Yes" 2 "No"
label values commknow_ftjobs commknow_ftjobs_lbl


********************************************************************************
* CPS and Modified CPS Questions:
* 	At any time LAST WEEK did you telework or work at home for pay?
*
*	Did you telework or work at home for pay in February 2020 before the 
*   COVID-19 pandemic started?
*
*
*	Did you spend any time LAST WEEK working at home for your job?
*
* 	Did you spend any time working at home for your job in February 2020 before 
*   the COVID-19 pandemic started?


label define cps_telework_lbl 1 "Yes" 2 "No"

label values cps_telework23_yesno cps_telework20_yesno cpsalt_telework23_yesno cpsalt_telework20_yesno cps_telework_lbl


********************************************************************************
* CPS and Modified CPS Questions:
* 	LAST WEEK, did you do more, less, or the same amount of telework or work at 
*	home for pay as in February 2020 (before the COVID-19 pandemic)?
* 	
*	LAST WEEK did you do more, less or the same amount of work at home for your 
*	job as in February 2020 (before the COVID-19 pandemic)?


label define cps_moreless_telework_lbl 1 "More" 2 "Less" 3 "About the same"

label values cps_telework20_moreless cpsalt_telework20_moreless cps_moreless_telework_lbl


********************************************************************************
* If you worked 5 days/week, how many WFH days/week would be best for your physical health?
*
* If you worked 5 days/week, how many WFH days/week would be best for your mental health?


label define wfh_ideal_lbl 1 "0 days (fully in person)" 2 "1 day" 3 "2 days" 4 "3 days" 5 "4 days" 6 "5 days (fully remote)"
label values wfh_ideal_physical_health wfh_ideal_mental_health wfh_ideal_lbl


	
********************************************************************************
* Save
********************************************************************************

save WFHdata_fromCSV, replace







********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
* THE REST OF THIS FILE PRODUCES REPRODUCES EXACT RESULTS FROM THE APRIL 28, 2021 VERSION
* OF OUR PAPER.
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************


********************************************************************************
********************************************************************************
********************************************************************************
* Figure 1: Extent of working from home during, before, and after COVID
********************************************************************************
********************************************************************************
********************************************************************************

use WFHdata_fromCSV, clear

keep if date<=ym(2021,3)

********************************************************************************
* Create dates for pre- and post-COVID times
insobs 1
quietly sum date
replace date = ym(2021,3) + 3 if date==.

insobs 1
replace date = ym(2020,3) if date==.

********************************************************************************
* Estimate the share of post-COVID WFH days the EMPLOYERS are PLANNING. 
* 
* The baseline estimate in the paper uses only the most recent month of data, 
* but here we include code that uses data from all survey waves. Users may replace
* the full estimate in the code for the figure below.

sum date
local maxdate = `r(max)'
local maxsurveydate = `maxdate' - 3

reg numwfh_days_postCOVID_boss_s_u if date==`maxsurveydate' [aw=cratio100_2021m3],  

gen wfh_days_postcovid = _b[_cons] if date==`maxdate'
gen wfh_days_postcovid_se = _se[_cons] if date==`maxdate'

reg numwfh_days_postCOVID_boss_s_u [aw=cratio100_2021m3], 
gen wfh_days_postcovid_full = _b[_cons] if date==`maxdate'
gen wfh_days_postcovid_full_se = _se[_cons] if date==`maxdate'



********************************************************************************
* Estimate the share of post-COVID WFH days that EMPLOYEES DESIRE.
*
* This estimate does not appear in the figure, only in the paper 

reg numwfh_days_postCOVID_s_u [aw=cratio100_2021m3], r 

gen wfh_days_postcovid_des = _b[_cons] if date==`maxdate'
gen wfh_days_postcovid_des_se = _se[_cons] if date==`maxdate'

********************************************************************************
* Code in the pre-COVID share of WFH days. See the paper for details on how we
* estimate this from the 2017-2018 American Time Use Survey

gen atus_wfhdays = 4.8 if date==ym(2020,3)

********************************************************************************
* Since we already have the pre- and post-COVID estimates, we need to give them
* weights before doing the collapse using a weighted mean
replace cratio100_2021m3 = 1 if date==ym(2020,3)|date==`maxdate'

********************************************************************************
* Estimate the share of workers whose EMPLOYER is PLANNING for them to WFH at
* least 1 full day per week post-COVID. (The EXTENSIVE margin.)
*
* This estimate does not appear in the figure, only in the paper 

gen wfh_postcovid_ext = 100*(numwfh_days_postCOVID_boss_s_u>0) if numwfh_days_postCOVID_boss_s_u~=.

reg wfh_postcovid_ext [aw=cratio100_2021m3],r
gen wfh_postcovid_ext_b = _b[_cons] if date==`maxdate'
gen wfh_postcovid_ext_se = _se[_cons] if date==`maxdate'

********************************************************************************
* Collapse the data to a time series

collapse (mean) wfhcovid_frac wfh_days_postcovid wfh_days_postcovid_se wfh_days_postcovid_full wfh_days_postcovid_full_se atus_wfhdays wfh_days_postcovid_des wfh_days_postcovid_des_se wfh_postcovid_ext_b wfh_postcovid_ext_se (semean) wfhcovid_se = wfhcovid_frac [aw=cratio100_2021m3], by(date)

rename wfhcovid_frac wfhcovid

tsset date

********************************************************************************
* Compute 95% Confidence Intervals for several variables of interest

gen cihi = wfhcovid + 2*wfhcovid_se
gen cilo = wfhcovid - 2*wfhcovid_se

gen ciposthi = wfh_days_postcovid + 2*wfh_days_postcovid_se
gen cipostlo = wfh_days_postcovid - 2*wfh_days_postcovid_se


gen cipostdeshi = wfh_days_postcovid_des + 2*wfh_days_postcovid_des_se
gen cipostdeslo = wfh_days_postcovid_des - 2*wfh_days_postcovid_des_se

gen cipostexthi = wfh_postcovid_ext_b + 2*wfh_postcovid_ext_se
gen cipostextlo = wfh_postcovid_ext_b - 2*wfh_postcovid_ext_se


********************************************************************************
* The time series graph plots each survey's estimates on the days that it was in
* the field. So we create one daily observation for each DAY that the survey was
* in the field and assign dates to each daily observation.
*
* These dates are: 
*	May 21 to 25, 
*	June 30 to July 9, 
*	August 21 to 28, 
*	September 29 to October 2, 
*	October 28 to November 3
*	November 17 to 20
* 	December 12 to 28
*	January 19 to 27
*	February 16 to March 1
*   March 16 to 22

* We plot the pre-COVID estimate on 1 March 2020
* We plot the post-COVID estimate on 1 March 2021


expand 20 , 

sort date

egen seqnum = seq(), by(date)

drop if seqnum>=2 & date==ym(2020,3)
drop if seqnum>=6 & date==ym(2020,5)
drop if seqnum>=10 & date==ym(2020,7)
drop if seqnum>=9 & date==ym(2020,8)
drop if seqnum>=5 & date==ym(2020,9)
drop if seqnum>=8 & date==ym(2020,10)
drop if seqnum>=5 & date==ym(2020,11)
drop if seqnum>=5 & date==ym(2020,11)
drop if seqnum>=18 & date==ym(2020,12)
drop if seqnum>=10 & date==ym(2021,1)
drop if seqnum>=14 & date==ym(2021,2)
drop if seqnum>=7 & date==ym(2021,3)


replace wfh_days_postcovid = . if seqnum>=2 & date==`maxdate'
replace ciposthi = . if seqnum>=2 & date==`maxdate'
replace cipostlo = . if seqnum>=2 & date==`maxdate'

replace wfh_days_postcovid_des = . if seqnum>=2 & date==`maxdate'
replace cipostdeshi = . if seqnum>=2 & date==`maxdate'
replace cipostdeslo = . if seqnum>=2 & date==`maxdate'

replace wfh_postcovid_ext_b = . if seqnum>=2 & date==`maxdate'
replace cipostexthi = . if seqnum>=2 & date==`maxdate'
replace cipostextlo = . if seqnum>=2 & date==`maxdate'

gen datedaily = td(1Mar2020) + seqnum - 1 if date==ym(2020,3)
replace datedaily = td(21May2020) + seqnum - 1 if date==ym(2020,5)
replace datedaily = td(30Jun2020) + seqnum - 1 if date==ym(2020,7)
replace datedaily = td(21Aug2020) + seqnum - 1 if date==ym(2020,8)
replace datedaily = td(29Sep2020) + seqnum - 1 if date==ym(2020,9)
replace datedaily = td(28Oct2020) + seqnum - 1 if date==ym(2020,10)
replace datedaily = td(17Nov2020) + seqnum - 1 if date==ym(2020,11)
replace datedaily = td(12Dec2020) + seqnum - 1 if date==ym(2020,12)
replace datedaily = td(19Jan2021) + seqnum - 1 if date==ym(2021,1)
replace datedaily = td(16Feb2021) + seqnum - 1 if date==ym(2021,2)
replace datedaily = td(16Mar2021) + seqnum - 1 if date==ym(2021,3)
replace datedaily = dofm(`maxdate') + seqnum - 1 if date==`maxdate'
format datedaily %td

tsset datedaily

********************************************************************************
* Create variables that will form the line connecting consecutive surveys
 
egen preline = rowtotal(atus_wfhdays wfhcovid) if date>=ym(2020,3) & date<=ym(2020,5)
egen currentline = rowtotal(atus_wfhdays wfhcovid) if date>=ym(2020,5) & date<=`maxsurveydate'
egen postline = rowtotal(wfhcovid wfh_days_postcovid) if date>=`maxsurveydate' & datedaily<=dofm(`maxdate')

********************************************************************************
* These variables are not used in the figure, but may be used to create variables 
* that form lines connecting the last survey date to the EXTENSIVE MARGIN and 
* EMPLOYEE DESIRED post-COVID WFH estimates

egen postline_des = rowtotal(wfhcovid wfh_days_postcovid_des) if date>=`maxsurveydate' & datedaily<=dofm(`maxdate')
egen postline_ext = rowtotal(wfhcovid wfh_postcovid_ext_b) if date>=`maxsurveydate' & datedaily<=dofm(`maxdate')

********************************************************************************
* You may stop running in one go here
********************************************************************************

********************************************************************************
* Eport the data required to reproduce Figure 1 to Excel, if needed
* 
* The command is commented out by default, so just remove the comment to obtain the result.

//export excel wfhcovid cihi cilo atus_wfhdays wfh_days_postcovid ciposthi cipostlo date datedaily using WFHtimeseries.xlsx, replace firstrow(variables)


********************************************************************************
* Plot the main figure in the paper WITHOUT Confidence Intervals
twoway (scatter wfhcovid atus_wfhdays wfh_days_postcovid datedaily, msymbol(o o o) msize(medium medium medium) mcolor(black gs5 navy) ) (line preline currentline postline datedaily, lpattern(solid solid longdash) lcolor(gs3 black black) lwidth(medthick medthick medthick)), legend(order(6) label(6 Employer planned) size(medlarge) position(5) ring(0) region(fcolor(%0) color(white)) symxsize(6pt) ) title("Percentage of paid full days worked from home") xtitle("") ylabel(0(10)65) ytick(0(5)65,grid gstyle(minor)) xtick( 21975 "Pre-COVID" 22036 "May20" 22067 "Jun20" 22097 "Jul20" 22128 "Aug20" 22159 "Sep20" 22189 "Oct20" 22220 "Nov20" 22432 "Post-COVID" 22250 "Dec20" 22281 "Jan21" 22312 "Feb21" 22340 "Mar21" 22371 "Apr21", labsize(9.0pt) grid gstyle(minor) ) xlabel( 21975 "Pre-COVID" 22036 "May20" 22097 "Jul20" 22159 "Sep20" 22220 "Nov20" 22432 "Post-COVID"  22281 "Jan21" 22340 "Mar21", labsize(10.0pt) grid gstyle(minor) ) yline(0, lcolor(gs12)) caption("*Pre-COVID estimate taken from the 2017-2018 American Time Use Survey", size(small))


********************************************************************************
* Legacy Code: Plot the main figure in the paper WITH Confidence Intervals
* 
* The command is commented out by default, so just remove the comment to obtain the graph.

//twoway (scatter wfhcovid cihi cilo atus_wfhdays wfh_days_postcovid ciposthi cipostlo datedaily, msymbol(o d d o o d d) msize(medium vsmall vsmall medium medium vsmall vsmall) mcolor(black red red gs5 navy red red) ) (line preline currentline postline datedaily, lpattern(longdash_dot solid longdash) lcolor(gs3 black black) lwidth(medthick medthick medthick)), legend(order(1 2 10) label(1 Estimate) label(2 95% Confidence Interval) label(10 Employer planned) size(medlarge) position(5) ring(0) region(fcolor(%0) color(white)) symxsize(6pt) ) title("Percentage of paid full days worked from home") xtitle("") ylabel(0(10)65) ytick(0(5)65,grid gstyle(minor)) xtick( 21975 "Pre-COVID" 22036 "May20" 22067 "Jun20" 22097 "Jul20" 22128 "Aug20" 22159 "Sep20" 22189 "Oct20" 22220 "Nov20" 22432 "Post-COVID" 22250 "Dec20" 22281 "Jan21" 22312 "Feb21" 22340 "Mar21" 22371 "Apr21", labsize(9.0pt) grid gstyle(minor) ) xlabel( 21975 "Pre-COVID" 22036 "May20" 22097 "Jul20" 22159 "Sep20" 22220 "Nov20" 22432 "Post-COVID"  22281 "Jan21" 22340 "Mar21", labsize(10.0pt) grid gstyle(minor) ) yline(0, lcolor(gs12)) caption("*Pre-COVID estimate taken from the 2017-2018 American Time Use Survey", size(small))




********************************************************************************
********************************************************************************
********************************************************************************
* Figure 3: Most workers want to work from home two or more days per week
********************************************************************************
********************************************************************************
********************************************************************************

use WFHdata_fromCSV, clear

* Focus on a sample of individuals who report ever working from home during COVID
* or who report to be at least partially able to work from home

cap drop cratio100desbase
sum cratio100_2021m3 if wfh_days_postCOVID_ss~=. 
local bigN = r(N)
sum cratio100_2021m3 if wfh_days_postCOVID_ss~=. & (wfhcovid_ever==100|wfh_able<5|wfh_able_qual==2)
local littleNshare = round(r(sum),.1)
gen cratio100desbase = cratio100_2021m3/r(sum)*100 if wfh_days_postCOVID_ss~=. & (wfhcovid_ever==100|wfh_able<5|wfh_able_qual==2)

graph hbar (sum) cratio100_2021m3 cratio100desbase, over(wfh_days_postCOVID_ss) blabel(bar, format(%12.1f))  bar(1, color(black) fcolor(black)) bar(2, color(red) fcolor(red) fintensity(70)) ylabel(0(5)35.55) ytitle(Percent of respondents, size(medlarge)) legend(label(1 All respondents) label(2 Respondents able to WFH*) cols(2) span size(medlarge)) caption(" *`littleNshare'% of the full sample meets this criterion", span size(small))



********************************************************************************
********************************************************************************
********************************************************************************
* Figure 4: Most workers value the option to work from home
********************************************************************************
********************************************************************************
********************************************************************************

use WFHdata_fromCSV, clear

* Focus on a sample from September 2020 and later, when we harmonized the more 
* dosaggregated answer choices for this question
sum cratio100_2021m3 if wfh_feel_detailed~=.
gen cratio100feel = cratio100_2021m3/r(sum)*100 if wfh_feel~=. 

graph hbar (sum) cratio100feel, over(wfh_feel_detailed, label(labsize(medium))) blabel(bar, format(%12.1f)) ytitle(Percent of respondents) bar(1, color(black) fcolor(black)) ylabel(0(5)32) title("Value of the option to WFH 2 - 3 days/wk, % of current pay?", span)	




********************************************************************************
********************************************************************************
********************************************************************************
* Figure 5: The WFH experience has exceeded expectations
********************************************************************************
********************************************************************************
********************************************************************************

use WFHdata_fromCSV, clear

sum cratio100_2021m3 if wfh_expect~=.
gen cratio100expect = cratio100_2021m3/r(sum)*100 if wfh_expect~=.
graph hbar (sum) cratio100expect, over(wfh_expect) blabel(bar, format(%12.1f)) ytitle(Percent of respondents) bar(1, color(black) fcolor(black)) ylabel(0(5)30) title("Relative to expectations, how has WFH turned out?", span)



********************************************************************************
********************************************************************************
********************************************************************************
* Figure 6: Desired and planned levels of WFH after the pandemic increase with 
*          WFH productivity surprises during the pandemic

********************************************************************************
********************************************************************************
********************************************************************************

use WFHdata_fromCSV, clear

binscatter numwfh_days_postCOVID_s_u numwfh_days_postCOVID_boss_s_u  wfh_expect_quant [aw=cratio100_2021m3], discrete msymbol(O T) mcolor(black red) lcolor(black red) xtitle("WFH productivity during COVID relative to expectations, percent", size(medlarge)) ytitle(Percent of full workdays at home, size(medlarge)) legend(label(1 Employee desired) label(2 Employer planned) ring(0) position(10) size(medlarge)) xlabel(-25(5)25) ylabel(0(10)65)  ytick(0(5)65) reportreg yline(0, lcolor(gs10))



********************************************************************************
********************************************************************************
********************************************************************************
* Figure 7: WFH stigma has fallen sharply
********************************************************************************
********************************************************************************
********************************************************************************

use WFHdata_fromCSV, clear

sum cratio100_2021m3 if wfh_Dperception~=.
gen cratio100Dpercept = cratio100_2021m3/r(sum)*100 if wfh_Dperception~=.
graph hbar (sum) cratio100Dpercept, over(wfh_Dperception,) blabel(bar, format(%12.1f)) ytitle(Percent of respondents) bar(1, color(black) fcolor(black)) ylabel(0(5)32) title(Change in WFH Perceptions Among People You Know, span) 



********************************************************************************
********************************************************************************
********************************************************************************
* Figure 8: Worker desires for WFH increase modestly with earnings, but employer
*           plans for WFH increase steeply with earnings.
********************************************************************************
********************************************************************************
********************************************************************************

use WFHdata_fromCSV, clear

replace income = 250 if income==1000 // puts the 500+ with 250 at 250+ rather than 1,000

keep if income>=25

collapse (mean) numwfh_days_postCOVID_s_u numwfh_days_postCOVID_boss_s_u (rawsum) cratio100_2021m3 [aw=cratio100_2021m3], by(income)

replace numwfh_days_postCOVID_s_u = numwfh_days_postCOVID_s_u/20
replace numwfh_days_postCOVID_boss_s_u = numwfh_days_postCOVID_boss_s_u/20

twoway (scatter numwfh_days_postCOVID_s_u numwfh_days_postCOVID_boss_s_u income [aw=cratio100_2021m3], xscale(log) mcolor(black red) ylabel(0(1)3) ytick(0(0.5)3) xlabel(20 50 100 200 250 "250+") lcolor(black red) mfcolor(%90 %70) msymbol(O T) xtitle(Annual Earnings in 2019 ($'000s), size(medlarge)) ytitle(Number of paid WFH days post-COVID, size(medlarge)) legend(label(1 Employee desired) label(2 Employer planned) size(medlarge) position(5) ring(0)) caption(Note: Marker size is proportional to the number of respondents per income level.) ), yline(0, lcolor(gs10))




********************************************************************************
********************************************************************************
********************************************************************************
* Figure 9: Spatial reallocation of worker spending away from dense city centers
********************************************************************************
********************************************************************************
********************************************************************************

********************************************************************************
* Figure 9a: Expenditure near work vs. population density
********************************************************************************

use WFHdata_fromCSV, clear

reg work_spend_total logpop_den_job_preCOVID [aw=cratio100_2021m3], r
local bhat = round(_b[logpop_den_job_preCOVID],.01)
local sehat = round(_se[logpop_den_job_preCOVID],.01)
local captionf = "Coef = `bhat'"  + " (" + substr("`sehat'",1, 3) + "), " + " N = " + "`e(N)'"
binscatter work_spend_total logpop_den_job_preCOVID [aw=cratio100_2021m3], mcolor(black) lcolor(black) xtitle("Population Density of Job Location, persons/sq. mile", size(medlarge)) ytitle(Weekly expenditure near work, size(medlarge)) caption("`captionf'", size(medlarge) position(5) ring(0)) xlabel( 4.61 "100" 6.91 "1000" 9.21 "10,000" 11.51 "100,000  ")


********************************************************************************
* Figure 9b: Employer planned WFH days (%) vs. population density
********************************************************************************

use WFHdata_fromCSV, clear

reg numwfh_days_postCOVID_boss_s_u logpop_den_job_preCOVID [aw=cratio100_2021m3], r
local bhat = round(_b[logpop_den_job_preCOVID],.01)
local sehat = round(_se[logpop_den_job_preCOVID],.01)
local captionf = "Coef = `bhat'"  + " (`sehat'), " + " N = " + "`e(N)'"
binscatter numwfh_days_postCOVID_boss_s_u logpop_den_job_preCOVID [aw=cratio100_2021m3], mcolor(red) lcolor(red) msymbol(T) xtitle("Population Density of Job Location, persons/sq. mile", size(medlarge)) ytitle(Employer planned WFH days post-COVID (%), size(medlarge)) caption("`captionf'", size(medlarge) position(5) ring(0)) xlabel( 4.61 "100" 6.91 "1000" 9.21 "10,000" 11.51 "100,000  ")




********************************************************************************
********************************************************************************
********************************************************************************
* Figure 10: Efficiency of WFH vs. working on business premises
********************************************************************************
********************************************************************************
********************************************************************************

use WFHdata_fromCSV, clear

sum cratio100_2021m3 if wfh_eff_COVID~=. 
gen cratio100effCOVID = cratio100_2021m3/r(sum)*100 if wfh_eff_COVID~=. 
graph hbar (sum) cratio100effCOVID, over(wfh_eff_COVID) blabel(bar, format(%12.1f)) ytitle(Percent of respondents, size(large)) bar(1, color(black) fcolor(black)) ylabel(0(5)48)



********************************************************************************
********************************************************************************
********************************************************************************
* Table 1: Share of respondents mainly WFH during COVID-19
********************************************************************************
********************************************************************************
********************************************************************************

use WFHdata_fromCSV, clear

* Table wfh during COVID 
mean wfhcovid [aw=cratio100_2021m3], 
mean wfhcovid_ever [aw=cratio100_2021m3], 
mean wfhcovid [aw=cratio100_2021m3], over(gender)
mean wfhcovid [aw=cratio100_2021m3], over(agebin)
mean wfhcovid [aw=cratio100_2021m3], over(education_s)
mean wfhcovid [aw=cratio100_2021m3], over(iincomebin)
mean wfhcovid [aw=cratio100_2021m3], over(goodservices)
mean wfhcovid [aw=cratio100_2021m3], over(haschildren)
mean wfhcovid [aw=cratio100_2021m3], over(redblue_cook)


********************************************************************************
********************************************************************************
********************************************************************************
* Table 2: What predicts working from home during the COVID pandemic?
********************************************************************************
********************************************************************************
********************************************************************************

use WFHdata_fromCSV, clear

keep if cratio100_2021m3~=.

********************************************************************************
* Standardize the continuous explanatory variables
foreach var in age_quant educ_years logincome Dem_share_frac internet_quality_quant {
	
	clonevar `var'_std = `var'
	quietly sum `var'
	replace `var'_std = (`var' - r(mean))/r(sd)
	
}

********************************************************************************
* Select the sample
reghdfe wfhcovid educ_years_std logincome_std i.gender##i.haschildren Dem_share_frac_std internet_quality_quant_std [aw=cratio100_2021m3], vce(robust) absorb(date work_industry)
gen samp_std = (e(sample))


********************************************************************************
* Now create the table.
* 
* The first command computes the mean share of respondents WFH during COVID.
* The rest estimate columns 1 to 7 of the table.

reghdfe wfhcovid if samp [aw=cratio100_2021m3], vce(robust) noabsorb

reghdfe wfhcovid educ_years_std if samp [aw=cratio100_2021m3], vce(robust) absorb(date)
reghdfe wfhcovid educ_years_std logincome_std if samp [aw=cratio100_2021m3], vce(robust) absorb(date)
reghdfe wfhcovid educ_years_std logincome_std i.gender##i.haschildren if samp [aw=cratio100_2021m3], vce(robust) absorb(date)
reghdfe wfhcovid educ_years_std logincome_std i.gender##i.haschildren Dem_share_frac_std if samp [aw=cratio100_2021m3], vce(robust) absorb(date)
reghdfe wfhcovid educ_years_std logincome_std i.gender##i.haschildren Dem_share_frac_std internet_quality_quant_std if samp [aw=cratio100_2021m3], vce(robust) absorb(date)
reghdfe wfhcovid educ_years_std logincome_std i.gender##i.haschildren Dem_share_frac_std internet_quality_quant_std if samp [aw=cratio100_2021m3], vce(robust) absorb(date agebin)
reghdfe wfhcovid educ_years_std logincome_std i.gender##i.haschildren Dem_share_frac_std internet_quality_quant_std if samp [aw=cratio100_2021m3], vce(robust) absorb(date agebin work_industry)

********************************************************************************
********************************************************************************
********************************************************************************
* Table 3: Worker-desired WFH is fairly uniform. Employer plans are not.
********************************************************************************
********************************************************************************
********************************************************************************

use WFHdata_fromCSV, clear

mean numwfh_days_postCOVID_s_u numwfh_days_postCOVID_boss_s_u [aw=cratio100_2021m3]
mean numwfh_days_postCOVID_s_u numwfh_days_postCOVID_boss_s_u [aw=cratio100_2021m3], over(gender)
mean numwfh_days_postCOVID_s_u numwfh_days_postCOVID_boss_s_u [aw=cratio100_2021m3], over(agebin)
mean numwfh_days_postCOVID_s_u numwfh_days_postCOVID_boss_s_u [aw=cratio100_2021m3], over(education_s)
mean numwfh_days_postCOVID_s_u numwfh_days_postCOVID_boss_s_u [aw=cratio100_2021m3], over(iincomebin)
mean numwfh_days_postCOVID_s_u numwfh_days_postCOVID_boss_s_u [aw=cratio100_2021m3], over(goods)
mean numwfh_days_postCOVID_s_u numwfh_days_postCOVID_boss_s_u [aw=cratio100_2021m3], over(haschildren)
mean numwfh_days_postCOVID_s_u numwfh_days_postCOVID_boss_s_u [aw=cratio100_2021m3], over(redblue_cook)




********************************************************************************
********************************************************************************
********************************************************************************
* Table 4: Residual fear of proximity to other people
********************************************************************************
********************************************************************************
********************************************************************************

use WFHdata_fromCSV, clear

forvalues i = 1(1)4 {
		
	gen habits`i' = (habits_postCOVID==`i')*100 if habits_postCOVID~=.
	
}

mean habits1 habits2 habits3 habits4 [aw=cratio100_2021m3], 	
	


********************************************************************************
********************************************************************************
********************************************************************************
* Table 5: Working from home is a valuable perk. The benefits of a shift towards
*          WFH are unevenly distributed across demographic groups
********************************************************************************
********************************************************************************
********************************************************************************

use WFHdata_fromCSV, clear

mean wfh_feel_quant_actual wfh_feel_quant [aw=cratio100_2021m3], 
mean wfh_feel_quant_actual wfh_feel_quant [aw=cratio100_2021m3], over(gender)
mean wfh_feel_quant_actual wfh_feel_quant [aw=cratio100_2021m3], over(agebin)
mean wfh_feel_quant_actual wfh_feel_quant  [aw=cratio100_2021m3], over(education_s)
mean wfh_feel_quant_actual wfh_feel_quant [aw=cratio100_2021m3], over(iincomebin)
mean wfh_feel_quant_actual wfh_feel_quant [aw=cratio100_2021m3], over(goodservices)
mean wfh_feel_quant_actual wfh_feel_quant [aw=cratio100_2021m3], over(haschildren)
mean wfh_feel_quant_actual wfh_feel_quant [aw=cratio100_2021m3], over(redblue_cook)



********************************************************************************
********************************************************************************
********************************************************************************
* Figure A.2 Higher income workers have longer commutes
********************************************************************************
********************************************************************************
********************************************************************************

use WFHdata_fromCSV, clear


* Again collapse the 500+ into the 250+ category and plot at 250
replace income = 250 if income==1000
keep if income>20

collapse (mean) commutetime_quant (rawsum) cratio100_2021m3 [aw=cratio100_2021m3], by(income)


twoway (scatter commutetime_quant income [aw=cratio100_2021m3], xscale(log) mcolor(black red) ylabel(20(10)50) ytick(15(5)50) xlabel(20 50 100 200 250 "250+") lcolor(black) mfcolor(%90) msymbol(O) xtitle(Annual Earnings in 2019 ($'000s), size(medlarge)) ytitle(Minutes, size(medlarge)) )  , title(Average one-way commute length, size(large) ) caption(Note: Marker size is proportional to the number of respondents by earnings level.) 


********************************************************************************
********************************************************************************
********************************************************************************
* Figure A.3 Desired post-COVID WFH days by sex among the college-educated
********************************************************************************
********************************************************************************
********************************************************************************

use WFHdata_fromCSV, clear

egen min=rmin(child1 child2 child3 child4)
keep if haschildren==1&education_s>=3&(min<12|live_children==2|live_children==3)&gender~=.

egen nratio=sum(cratio100_2021m3),by(gender)
gen newratio100=100*cratio100_2021m3/nratio

keep numwfh_days_postCOVID_s_u gender newratio100 date
*keep num*boss*  gender newratio100

replace numwfh=5*numwfh/100
*replace num=0 if num==1
replace num=2 if num>=2&num<=4

tab date

collapse (sum) newratio100, by(numwfh gender)
replace newratio=round(newratio,.1)
reshape wide newratio100,i(numwfh) j(gender)
label define num_lbl 0 "0 days" 1 "1 day" 2 "2 to 4 days" 5 "5 days"
label values num num_lbl

graph bar (sum) newratio1001 newratio1002,over(numwfh)  legend(label(1 Women) label(2 Men)) caption("Sample: Respondents with at least some college and children under 12", size(small)) blabel(bar) ylabel(0(10)40)  graphregion(color(white)) bar(1, color(black) fcolor(black)) bar(2, color(red) fcolor(red) fintensity(70)) title(Percent of respondents by desired WFH days)


********************************************************************************
********************************************************************************
********************************************************************************
* Figure A.4 Post-COVID: Percent of full workdays at home (desired + planned)
********************************************************************************
********************************************************************************
** ******************************************************************************

use WFHdata_fromCSV, clear

* Figure A.4a: During COVID: Percent of full workdays at home (desired + planned)
binscatter wfhcovid wfh_eff_COVID_quant if wfh_eff_COVID~=.  [aw=cratio100_2021m3], mcolor(black) msymbol(O) lcolor(black) xtitle(Self-assessed efficiency while WFH during COVID, size(medlarge)) title(During COVID: Percent of respondents mainly WFH, size(large)) ytitle("")


* Figure A.4b: Post-COVID: Percent of full workdays at home (desired + planned)
binscatter numwfh_days_postCOVID_boss_s_u numwfh_days_postCOVID_s_u wfh_eff_COVID_quant if wfh_eff_COVID~=.  [aw=cratio100_2021m3], discrete mcolor(black red) msymbol(O T) lcolor(black red) xtitle(Self-assessed efficiency while WFH during COVID, size(medlarge)) title(Post-COVID: Percent of full workdays at home, size(large)) legend(label(1 Worker desired) label(2 Employer planned) position(5) ring(0) size(medlarge)) ytitle("")

********************************************************************************
********************************************************************************
********************************************************************************
* Table A.1 Summary statistics
********************************************************************************
********************************************************************************
********************************************************************************

use WFHdata_fromCSV, clear

keep cratio100_2021m3 income age_quant educ_years wfhcovid wfhcovid_ever numwfh_days_postCOVID_s_u numwfh_days_postCOVID_boss_s_u commutetime_quant wfh_feel_quant wfh_expect_quant wfh_able_quant wfh_eff_COVID_quant wfh_invest_quant wfh_hoursinvest work_spend_total female redstate date


rename numwfh_days_postCOVID_boss_s_u numwfh_days_postCOVID_boss

foreach var in income age_quant educ_years wfhcovid wfhcovid_ever numwfh_days_postCOVID_s_u numwfh_days_postCOVID_boss commutetime_quant wfh_feel_quant wfh_expect_quant wfh_able_quant wfh_eff_COVID_quant wfh_invest_quant wfh_hoursinvest work_spend_total female redstate {
	
	
	foreach stat in sd p25 p50 p75 N {
		clonevar `var'_`stat' = `var'
	}
	
	rename `var' `var'_mean

}

collapse (mean) *_mean (sd) *_sd (p25) *_p25 (p50) *_p50 (p75) *_p75 (count) *_N [aw=cratio100_2021m3]

order income* age_quant* educ_years* wfhcovid_ever* wfhcovid* numwfh_days_postCOVID_s_u* numwfh_days_postCOVID_boss* commutetime_quant* wfh_feel_quant* wfh_expect_quant* wfh_able_quant* wfh_eff_COVID_quant* wfh_invest_quant* wfh_hoursinvest* work_spend_total* female* redstate*


* To export the summary stats, use the following command (commented out by default)
//export excel using summarystats_fortable.xlsx, firstrow(variables) replace


********************************************************************************
********************************************************************************
********************************************************************************
* Table A.2 Productivity of WFH during COVID relative to expectations
********************************************************************************
********************************************************************************
********************************************************************************

use WFHdata_fromCSV, clear

mean wfh_expect_quant  [aw=cratio100_2021m3]
mean wfh_expect_quant  [aw=cratio100_2021m3], over(gender)
mean wfh_expect_quant  [aw=cratio100_2021m3], over(agebin)
mean wfh_expect_quant  [aw=cratio100_2021m3], over(education_s)
mean wfh_expect_quant  [aw=cratio100_2021m3], over(iincomebin)
mean wfh_expect_quant  [aw=cratio100_2021m3], over(haschildren)
mean wfh_expect_quant  [aw=cratio100_2021m3], over(goodservices)
mean wfh_expect_quant  [aw=cratio100_2021m3], over(redblue_cook)



********************************************************************************
********************************************************************************
********************************************************************************
* Table A.3 Investments enabling work from home
********************************************************************************
********************************************************************************
********************************************************************************

use WFHdata_fromCSV, clear

mean wfh_hoursinvest wfh_invest_quant  [aw=cratio100_2021m3],
mean wfh_hoursinvest wfh_invest_quant  [aw=cratio100_2021m3], over(gender)
mean wfh_hoursinvest wfh_invest_quant  [aw=cratio100_2021m3], over(agebin)
mean wfh_hoursinvest wfh_invest_quant  [aw=cratio100_2021m3], over(education_s)
mean wfh_hoursinvest wfh_invest_quant  [aw=cratio100_2021m3], over(iincomebin)
mean wfh_hoursinvest wfh_invest_quant  [aw=cratio100_2021m3], over(goodservices)
mean wfh_hoursinvest wfh_invest_quant  [aw=cratio100_2021m3], over(haschildren)
mean wfh_hoursinvest wfh_invest_quant  [aw=cratio100_2021m3], over(redblue_cook)

********************************************************************************
********************************************************************************
********************************************************************************
* Table A.4 WFH stigma has diminished
********************************************************************************
********************************************************************************
********************************************************************************

use WFHdata_fromCSV, clear

gen wfh_Dperception_pos = 100*(wfh_Dperception<4) if wfh_Dperception~=.
gen wfh_Dperception_neg = 100*(wfh_Dperception>4) if wfh_Dperception~=.

gen wfh_Dperception_net = wfh_Dperception_pos - wfh_Dperception_neg


mean wfh_Dperception_net wfh_Dperception_pos [aw=cratio100_2021m3]
mean wfh_Dperception_net wfh_Dperception_pos [aw=cratio100_2021m3], over(gender)
mean wfh_Dperception_net wfh_Dperception_pos [aw=cratio100_2021m3], over(agebin)
mean wfh_Dperception_net wfh_Dperception_pos [aw=cratio100_2021m3], over(education_s)
mean wfh_Dperception_net wfh_Dperception_pos [aw=cratio100_2021m3], over(iincomebin)
mean wfh_Dperception_net wfh_Dperception_pos [aw=cratio100_2021m3], over(goodservices)
mean wfh_Dperception_net wfh_Dperception_pos [aw=cratio100_2021m3], over(haschildren)
mean wfh_Dperception_net wfh_Dperception_pos [aw=cratio100_2021m3], over(redblue_cook)

********************************************************************************
********************************************************************************
********************************************************************************
* Table A.5 Residual fear of proximity to other people, across demographics
********************************************************************************
********************************************************************************
********************************************************************************

use WFHdata_fromCSV, clear

forvalues i = 1(1)4 {
	
	gen habits`i' = (habits_postCOVID==`i')*100 if habits_postCOVID~=.
	
}

mean habits1  [aw=cratio100_2021m3], 
mean habits1  [aw=cratio100_2021m3], over(gender)
mean habits1  [aw=cratio100_2021m3], over(agebin)
mean habits1  [aw=cratio100_2021m3], over(education_s)
mean habits1  [aw=cratio100_2021m3], over(iincomebin)
mean habits1  [aw=cratio100_2021m3], over(goodservices)
mean habits1  [aw=cratio100_2021m3], over(haschildren)
mean habits1  [aw=cratio100_2021m3], over(redblue_cook)



********************************************************************************
********************************************************************************
********************************************************************************
* Table A.6: Residual fear of proximity to other people (reasons cited)
********************************************************************************
********************************************************************************
********************************************************************************

use WFHdata_fromCSV, clear

foreach var in concern_vaccine concern_socdist concern_otherdisease {
	replace `var' = `var'
}

mean concern_vaccine concern_socdist concern_otherdisease if concern_none==0 [aw=cratio100_2021m3]


********************************************************************************
********************************************************************************
********************************************************************************
* Table A.7 Employer plans and employee desires for post-COVID WFH versus change 
*           in perceptions about WFH
********************************************************************************
********************************************************************************
********************************************************************************

use WFHdata_fromCSV, clear

clonevar wfh_Dperception_s = wfh_Dperception
replace wfh_Dperception_s = 5 if wfh_Dperception_s>5 & wfh_Dperception_s~=.

label define wfh_Dperception_lbl 5 "Worsened", modify


mean numwfh_days_postCOVID_s_u numwfh_days_postCOVID_boss_s_u [aw=cratio100_2021m3], over(wfh_Dperception_s)

tab wfh_Dperception_s


********************************************************************************
********************************************************************************
********************************************************************************
* Table A.8 Vaccine concerns across demographics
********************************************************************************
********************************************************************************
********************************************************************************

use WFHdata_fromCSV, clear

mean concern_vaccine if habits>1  [aw=cratio100_2021m3], 
mean concern_vaccine  if habits>1 [aw=cratio100_2021m3], over(gender)
mean concern_vaccine if habits>1 [aw=cratio100_2021m3], over(agebin)
mean concern_vaccine if habits>1 [aw=cratio100_2021m3], over(education_s)
mean concern_vaccine if habits>1 [aw=cratio100_2021m3], over(iincomebin)
mean concern_vaccine if habits>1 [aw=cratio100_2021m3], over(goodservices)
mean concern_vaccine if habits>1 [aw=cratio100_2021m3], over(haschildren)
mean concern_vaccine if habits>1 [aw=cratio100_2021m3], over(redblue_cook)


********************************************************************************
********************************************************************************
********************************************************************************
* Table A.9 Efficiency of WFH vs. working on business premises
********************************************************************************
********************************************************************************
********************************************************************************

use WFHdata_fromCSV, clear

mean wfh_eff_COVID_quant [aw=cratio100_2021m3], 
mean wfh_eff_COVID_quant [aw=cratio100_2021m3], over(gender)
mean wfh_eff_COVID_quant [aw=cratio100_2021m3], over(agebin)
mean wfh_eff_COVID_quant [aw=cratio100_2021m3], over(education_s)
mean wfh_eff_COVID_quant [aw=cratio100_2021m3], over(iincomebin)
mean wfh_eff_COVID_quant [aw=cratio100_2021m3], over(goodservices)
mean wfh_eff_COVID_quant [aw=cratio100_2021m3], over(haschildren)
mean wfh_eff_COVID_quant [aw=cratio100_2021m3], over(redblue_cook)



********************************************************************************
********************************************************************************
********************************************************************************
* Table A.10 What predicts desired and planned WFH post-COVID?
********************************************************************************
********************************************************************************
********************************************************************************

use WFHdata_fromCSV, clear

keep if cratio100_2021m3~=.

********************************************************************************
* Standardize the continuous explanatory variables
foreach var in age_quant educ_years logincome Dem_share_frac internet_quality_quant {
	
	clonevar `var'_std = `var'
	quietly sum `var'
	replace `var'_std = (`var' - r(mean))/r(sd)
	
}

********************************************************************************
* Worker desires for post-COVID WFH
********************************************************************************

* Select the sample
cap drop samp
reghdfe numwfh_days_postCOVID_s_u educ_years_std logincome_std i.gender##i.haschildren Dem_share_frac_std internet_quality_quant_std [aw=cratio100_2021m3], vce(robust) absorb(date work_industry)
gen samp_std = (e(sample))

* The first command computes the mean of worker desired post-COVID WFH
* The rest estimate columns 1 to 7 of the table.
reghdfe numwfh_days_postCOVID_s_u if samp [aw=cratio100_2021m3], vce(robust) noabsorb

reghdfe numwfh_days_postCOVID_s_u educ_years_std if samp [aw=cratio100_2021m3], vce(robust) absorb(date)
reghdfe numwfh_days_postCOVID_s_u educ_years_std logincome_std if samp [aw=cratio100_2021m3], vce(robust) absorb(date)
reghdfe numwfh_days_postCOVID_s_u educ_years_std logincome_std i.gender##i.haschildren if samp [aw=cratio100_2021m3], vce(robust) absorb(date)
reghdfe numwfh_days_postCOVID_s_u educ_years_std logincome_std i.gender##i.haschildren Dem_share_frac_std if samp [aw=cratio100_2021m3], vce(robust) absorb(date)
reghdfe numwfh_days_postCOVID_s_u educ_years_std logincome_std i.gender##i.haschildren Dem_share_frac_std internet_quality_quant_std if samp [aw=cratio100_2021m3], vce(robust) absorb(date)
reghdfe numwfh_days_postCOVID_s_u educ_years_std logincome_std i.gender##i.haschildren Dem_share_frac_std internet_quality_quant_std if samp [aw=cratio100_2021m3], vce(robust) absorb(date agebin)
reghdfe numwfh_days_postCOVID_s_u educ_years_std logincome_std i.gender##i.haschildren Dem_share_frac_std internet_quality_quant_std if samp [aw=cratio100_2021m3], vce(robust) absorb(date agebin work_industry)

********************************************************************************
* Employer plans for post-COVID WFH

* Select the sample
cap drop samp
reghdfe numwfh_days_postCOVID_boss_s_u educ_years_std logincome_std i.gender##i.haschildren Dem_share_frac_std internet_quality_quant_std [aw=cratio100_2021m3], vce(robust) absorb(date work_industry)
gen samp_std = (e(sample))

* The first command computes the mean of employer planned post-COVID WFH
* The rest estimate columns 1 to 7 of the table.
reghdfe numwfh_days_postCOVID_boss_s_u if samp [aw=cratio100_2021m3], vce(robust) noabsorb

reghdfe numwfh_days_postCOVID_boss_s_u educ_years_std if samp [aw=cratio100_2021m3], vce(robust) absorb(date)
reghdfe numwfh_days_postCOVID_boss_s_u educ_years_std logincome_std if samp [aw=cratio100_2021m3], vce(robust) absorb(date)
reghdfe numwfh_days_postCOVID_boss_s_u educ_years_std logincome_std i.gender##i.haschildren if samp [aw=cratio100_2021m3], vce(robust) absorb(date)
reghdfe numwfh_days_postCOVID_boss_s_u educ_years_std logincome_std i.gender##i.haschildren Dem_share_frac_std if samp [aw=cratio100_2021m3], vce(robust) absorb(date)
reghdfe numwfh_days_postCOVID_boss_s_u educ_years_std logincome_std i.gender##i.haschildren Dem_share_frac_std internet_quality_quant_std if samp [aw=cratio100_2021m3], vce(robust) absorb(date)
reghdfe numwfh_days_postCOVID_boss_s_u educ_years_std logincome_std i.gender##i.haschildren Dem_share_frac_std internet_quality_quant_std if samp [aw=cratio100_2021m3], vce(robust) absorb(date agebin)
reghdfe numwfh_days_postCOVID_boss_s_u educ_years_std logincome_std i.gender##i.haschildren Dem_share_frac_std internet_quality_quant_std if samp [aw=cratio100_2021m3], vce(robust) absorb(date agebin work_industry)


********************************************************************************
********************************************************************************
********************************************************************************
* Table A.11 What predicts self-assessed efficiency while WFH during COVID?
********************************************************************************
********************************************************************************
********************************************************************************

use WFHdata_fromCSV, clear

keep if cratio100_2021m3~=.

********************************************************************************
* Standardize the continuous explanatory variables
foreach var in age_quant educ_years logincome Dem_share_frac internet_quality_quant {
	
	clonevar `var'_std = `var'
	quietly sum `var'
	replace `var'_std = (`var' - r(mean))/r(sd)
	
}

********************************************************************************
* Select the sample
cap drop samp
reghdfe wfh_eff_COVID_quant educ_years_std logincome_std i.gender##i.haschildren Dem_share_frac_std internet_quality_quant_std if date>=ym(2020,8) [aw=cratio100_2021m3], vce(robust) absorb(date work_industry)
gen samp_std = (e(sample))


* The first command computes the mean of self-assessed efficiency
* The rest estimate columns 1 to 7 of the table.

reghdfe wfh_eff_COVID_quant if samp [aw=cratio100_2021m3], vce(robust) noabsorb

reghdfe wfh_eff_COVID_quant educ_years_std if samp [aw=cratio100_2021m3], vce(robust) absorb(date)
reghdfe wfh_eff_COVID_quant educ_years_std logincome_std if samp [aw=cratio100_2021m3], vce(robust) absorb(date)
reghdfe wfh_eff_COVID_quant educ_years_std logincome_std i.gender##i.haschildren if samp [aw=cratio100_2021m3], vce(robust) absorb(date)
reghdfe wfh_eff_COVID_quant educ_years_std logincome_std i.gender##i.haschildren Dem_share_frac_std if samp [aw=cratio100_2021m3], vce(robust) absorb(date)
reghdfe wfh_eff_COVID_quant educ_years_std logincome_std i.gender##i.haschildren Dem_share_frac_std internet_quality_quant_std if samp [aw=cratio100_2021m3], vce(robust) absorb(date)
reghdfe wfh_eff_COVID_quant educ_years_std logincome_std i.gender##i.haschildren Dem_share_frac_std internet_quality_quant_std if samp [aw=cratio100_2021m3], vce(robust) absorb(date agebin)
reghdfe wfh_eff_COVID_quant educ_years_std logincome_std i.gender##i.haschildren Dem_share_frac_std internet_quality_quant_std if samp [aw=cratio100_2021m3], vce(robust) absorb(date agebin work_industry)


********************************************************************************
********************************************************************************
********************************************************************************
* Other estimates in paper but not in tables/figures
********************************************************************************
********************************************************************************
********************************************************************************

use WFHdata_fromCSV, clear

* Work status in May 2020 and March 2021
tab workstatus_current if date==ym(2020,5) [aw=cratio100_2021m3]
tab workstatus_current if date==ym(2021,3) [aw=cratio100_2021m3]


* Share of paid days spent working from home, overall and in each wave
mean wfhcovid_frac [aw=cratio100_2021m3]
mean wfhcovid_frac [aw=cratio100_2021m3], over(date)

* Percent of respondents with WFH experience during COVID
mean wfhcovid_ever [aw=cratio100_2021m3]

* Mean employer planned WFH days in March 2021
mean numwfh_days_postCOVID_boss_s_u if date==ym(2021,3) [aw=cratio100_2021m3],

* Percent of workers who will WFH 1+ days post-COVID
gen wfh_postcovid = 100*(numwfh_days_postCOVID_boss_s_u>0) if numwfh_days_postCOVID_boss_s_u~=.
mean wfh_postcovid if date==ym(2021,3) [aw=cratio100_2021m3],

* Mean worker desired WFH days post-COVID among those ABLE TO WFH
sum numwfh_days_postCOVID_s_u if (wfhcovid_ever==100|wfh_able<5|wfh_able_qual==2) [aw=cratio100_2021m3],d

* Mean productivity surprise relative to expectations
mean wfh_expect_quant [aw=cratio100_2021m3]

* Mean reimbursement
replace wfh_invest_burs = . if wfh_invest_quant<=0
mean wfh_invest_burs [aw=cratio100_2021m3]


********************************************************************************
********************************************************************************
********************************************************************************
* Investment as a percent of GDP
********************************************************************************
********************************************************************************
********************************************************************************

use WFHdata_fromCSV, clear

* Means in January 2021 and overall
mean wfh_hoursinvest wfh_invest_quant if date==ym(2021,1) [aw=cratio100_2021m3]
mean wfh_hoursinvest wfh_invest_quant [aw=cratio100_2021m3]

* Generate total investment
gen wfh_invest_total = wfh_hoursinvest*hourly_wage + wfh_invest_quant

* Mean total investment overall and in January 2021
*mean wfh_invest_total if date==ym(2020,12) [aw=cratio100_2021m3]
mean wfh_invest_total [aw=cratio100_2021m3]

* Adjust for selection into WFH and thus into investing
replace wfh_invest_total = 0 if wfhcovid_ever==0 & date>=ym(2020,8) & date<=ym(2021,1)
replace wfh_invest_total = 0 if workstatus_current~=2 & date==ym(2020,7)

* Translate into units of dollars not '000s of dollars
replace income = income*1000

* Keep the appropriate sample
keep if wfh_invest_total~=. & income~=.

* Collapse by month of overall
*collapse (sum) wfh_invest_total income [aw=cratio100_2021m3], by(date)
collapse (sum) wfh_invest_total income [aw=cratio100_2021m3],

gen wfh_invest_total_pc = wfh_invest_total/income*100

gen  wfh_invest_total_pcGDP = wfh_invest_total_pc*0.593



********************************************************************************
********************************************************************************
********************************************************************************
* Productivity estimates: in paper but not in a table/figure
********************************************************************************
********************************************************************************
********************************************************************************

use WFHdata_fromCSV, clear

********************************************************************************
* Commuting time savings
********************************************************************************

* WFH days pre-COVID equal 5% of 5 = (.05*5 = 0.25) if they plan to do at least
* some WFH post-COVID and zero otherwise.
gen wfhdays_preCOVID = 0.25*(numwfh_days_postCOVID_boss_s_u>0) + 0*(numwfh_days_postCOVID_boss_s_u<=0) if numwfh_days_postCOVID_boss_s_u~=.


* Work hours including commuting time
gen workhours_inclcomm = workhours_preCOVID + (2*commutetime_quant/60)*(5 - wfhdays_preCOVID) if workhours_preCOVID>=35


* Number of planned days WFH post-COVID (i.e. expressed in days and not as a % of all days)
gen numwfh_days_postCOVID_boss_day = numwfh_days_postCOVID_boss_s_u/20


* How much of commuting time savings get reallocated to work?
gen extratime_work = extratime_1stjob + extratime_2ndjob


* Total time saving from commuting
gen timesaved = (numwfh_days_postCOVID_boss_day - wfhdays_preCOVID)*(2*commutetime_quant/60)*(1 - extratime_work/100)


* Productivity gian implied by commuting time savings
gen gain_implied = 100*timesaved/workhours_inclcomm //if workhours_inclcomm>=20 & workhours_inclcomm~=.
winsor2 gain_implied, cuts(1 99) replace


* Adjust self-assessed efficiency while WFH during COVID for selection into WFH
* by giving zeros to those who are unable to WFH during COVID but are currently working
gen wfh_eff_COVID_qselect = wfh_eff_COVID_quant
replace wfh_eff_COVID_qselect = 0 if wfh_eff_COVID_quant==. & (wfh_able_quant==0|workstatus_current==1)


* Does the self-assessed productivity include commuting time gains?
* We assume 15% of those with negative self assessed productivity exclude the 
* commuting time gains, i.e the same proportion as those postitive self-assessed
* productivity
gen gain_excl_comm = (wfh_extraeff_comm_qual==2) if wfh_extraeff_comm_qual~=. & wfh_extraeff_comm_quant~=.
replace gain_excl_comm = 0.15*(wfh_extraeff_comm_quant<=0) if wfh_extraeff_comm_quant~=. & gain_excl_comm==.


* Total gains adding self-assessed productivity and implied gains from commuting (when excluded)
	
	* This is the simple version
	gen total_gain_1 = wfh_eff_COVID_qselect*(numwfh_days_postCOVID_boss_day - wfhdays_preCOVID)/5 + gain_implied*gain_excl_comm
	
	* Our preferred version assume those who have negative self-assessed WFH productivity won't WFH post-COVID
	gen total_gain_2 = total_gain_1*(wfh_eff_COVID_qselect>0) if wfh_eff_COVID_qselect~=.

* Conventional productivity gain. We impute that efficiency gains are 75% from commuting
* for 85 percent of respondents for whom that information is missing.

gen wfh_extraeff_comm_quant_2 = wfh_extraeff_comm_quant
replace wfh_extraeff_comm_quant_2 = 85*0.75 if wfh_extraeff_comm_qual==. & wfh_extraeff_comm_quant~=.

gen gain_conv_2 = (1 - wfh_extraeff_comm_quant_2/100)*wfh_eff_COVID_qselect*(numwfh_days_postCOVID_boss_day - wfhdays_preCOVID)/5


********************************************************************************
* Now compute the means
********************************************************************************

* Commuting time savings
mean gain_implied if date==ym(2021,2)|date==ym(2021,3) [aw=cratio100_2021m3]
mean gain_implied if date==ym(2021,2)|date==ym(2021,3) [aw=icratio100_2021m3]

* True productivity gains

mean total_gain_2 if date==ym(2021,2)|date==ym(2021,3) [aw=cratio100_2021m3]
mean total_gain_2 if date==ym(2021,2)|date==ym(2021,3) [aw=icratio100_2021m3] // There is a slight discrepancy between the mean here of 4.6% and the 4.8% reported in the April 21, 2021 version of the paper due to a minor coding error.

* Conventional productivity gains
mean gain_conv_2 if date==ym(2021,2)|date==ym(2021,3) [aw=cratio100_2021m3]
mean gain_conv_2 if date==ym(2021,2)|date==ym(2021,3)  [aw=icratio100_2021m3]


