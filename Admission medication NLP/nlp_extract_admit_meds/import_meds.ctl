--options (skip=5)
load data
infile 'drugs.txt'
replace into table djscott.med_dc_sum
fields terminated by "|"
trailing nullcols  (
    SUBJECT_ID,
    TYPE,
    MEDICATION
)
