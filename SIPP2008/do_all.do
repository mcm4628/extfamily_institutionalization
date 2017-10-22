
global first_wave 1
global final_wave 15
global second_wave = ${first_wave} + 1
global penultimate_wave = ${final_wave} - 1

global adult_age 18

global refmon 4


do "$childhh_base_code/do_and_log" merge_waves
