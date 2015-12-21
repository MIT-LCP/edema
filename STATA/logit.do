drop if gender==""
drop if first_icustay_admit_saps ==.
drop if home_ccbs ==.
drop if aids ==.

// covert categorical varialbes into numbers

gen hosp_mort=0
replace hosp_mort=1 if hosp_mort_first_admission=="Y"

gen edem_num=0
replace edem_num=1 if edemacategory == "PeriE_only"
replace edem_num=2 if edemacategory == "PulE_only"
replace edem_num=3 if edemacategory == "PeriE_PulE"

gen gender_num=0
replace gender_num=1 if gender =="M"

gen race_num=0
replace race_num=1 if race_simple=="ASIAN"
replace race_num=2 if race_simple=="BLACK"
replace race_num=3 if race_simple=="HISPANIC"
replace race_num=4 if race_simple=="OTHER"
replace race_num=5 if race_simple=="UNKNOWN"

gen service_num=0
replace service_num=1 if icustay_first_service=="CCU"
replace service_num=1 if icustay_first_service=="SICU"
replace service_num=1 if icustay_first_service=="CSRU"

// Hosptial mortality as primary outcome, edema category as the investigating variable

logit hosp_mort ///
i.edem_num ///
age_first_icustay ///
i.gender_num ///
i.race_num ///
i. service_num ///
first_icustay_admit_saps ///
i.dm_comorbidity_combinedelixm ///
i.chf_comorbidity_combinedelix ///
i.cardiac_arrhythmias ///
i.valvular_disease ///
i.pulmonary_circulation ///
i.peripheral_vascular ///
i.hypertension ///
i.paralysis ///
i.other_neurological ///
i.chronic_pulmonary ///
i.hypothyroidism ///
i.renal_failure ///
i.liver_disease ///
i.peptic_ulcer ///
i.aids ///
i.lymphoma ///
i.metastatic_cancer ///
i.solid_tumor ///
i.rheumatoid_arthritis ///
i.coagulopathy ///
i.obesity ///
i.weight_loss ///
i.fluid_electrolyte ///
i.deficiency_anemias ///
i.alcohol_abuse ///
i.drug_abuse ///
i.psychoses ///
i.depression ///
i.home_ccbs ///
i.home_diuretics ///
, or

lroc, nograph
estat gof, group(50) table

predict phat

nri1 hosp_mort ///
age_first_icustay ///
gender_num ///
race_num ///
service_num ///
first_icustay_admit_saps ///
dm_comorbidity_combinedelixm ///
chf_comorbidity_combinedelix ///
cardiac_arrhythmias ///
valvular_disease ///
pulmonary_circulation ///
peripheral_vascular ///
hypertension ///
paralysis ///
other_neurological ///
chronic_pulmonary ///
hypothyroidism ///
renal_failure ///
liver_disease ///
peptic_ulcer ///
aids ///
lymphoma ///
metastatic_cancer ///
solid_tumor ///
rheumatoid_arthritis ///
coagulopathy ///
obesity ///
weight_loss ///
fluid_electrolyte ///
deficiency_anemias ///
alcohol_abuse ///
drug_abuse ///
psychoses ///
depression ///
home_ccbs ///
home_diuretics ///
, prvars(edem_num) cut(50)

idi hosp_mort ///
age_first_icustay ///
gender_num ///
race_num ///
service_num ///
first_icustay_admit_saps ///
dm_comorbidity_combinedelixm ///
chf_comorbidity_combinedelix ///
cardiac_arrhythmias ///
valvular_disease ///
pulmonary_circulation ///
peripheral_vascular ///
hypertension ///
paralysis ///
other_neurological ///
chronic_pulmonary ///
hypothyroidism ///
renal_failure ///
liver_disease ///
peptic_ulcer ///
aids ///
lymphoma ///
metastatic_cancer ///
solid_tumor ///
rheumatoid_arthritis ///
coagulopathy ///
obesity ///
weight_loss ///
fluid_electrolyte ///
deficiency_anemias ///
alcohol_abuse ///
drug_abuse ///
psychoses ///
depression ///
home_ccbs ///
home_diuretics ///
, prvars(edem_num)

// ARF as primary outcome, edema category as the investigating variable

logit arf ///
i.edem_num ///
age_first_icustay ///
i.gender_num ///
i.race_num ///
i. service_num ///
first_icustay_admit_saps ///
i.dm_comorbidity_combinedelixm ///
i.chf_comorbidity_combinedelix ///
i.cardiac_arrhythmias ///
i.valvular_disease ///
i.pulmonary_circulation ///
i.peripheral_vascular ///
i.hypertension ///
i.paralysis ///
i.other_neurological ///
i.chronic_pulmonary ///
i.hypothyroidism ///
i.renal_failure ///
i.liver_disease ///
i.peptic_ulcer ///
i.aids ///
i.lymphoma ///
i.metastatic_cancer ///
i.solid_tumor ///
i.rheumatoid_arthritis ///
i.coagulopathy ///
i.obesity ///
i.weight_loss ///
i.fluid_electrolyte ///
i.deficiency_anemias ///
i.alcohol_abuse ///
i.drug_abuse ///
i.psychoses ///
i.depression ///
i.home_ccbs ///
, or

lroc, nograph
estat gof, group(50) table

predict phat

nri1 arf ///
age_first_icustay ///
gender_num ///
race_num ///
service_num ///
first_icustay_admit_saps ///
dm_comorbidity_combinedelixm ///
chf_comorbidity_combinedelix ///
cardiac_arrhythmias ///
valvular_disease ///
pulmonary_circulation ///
peripheral_vascular ///
hypertension ///
paralysis ///
other_neurological ///
chronic_pulmonary ///
hypothyroidism ///
renal_failure ///
liver_disease ///
peptic_ulcer ///
aids ///
lymphoma ///
metastatic_cancer ///
solid_tumor ///
rheumatoid_arthritis ///
coagulopathy ///
obesity ///
weight_loss ///
fluid_electrolyte ///
deficiency_anemias ///
alcohol_abuse ///
drug_abuse ///
psychoses ///
depression ///
home_ccbs ///
, prvars(edem_num) cut(50)

idi arf ///
age_first_icustay ///
gender_num ///
race_num ///
service_num ///
first_icustay_admit_saps ///
dm_comorbidity_combinedelixm ///
chf_comorbidity_combinedelix ///
cardiac_arrhythmias ///
valvular_disease ///
pulmonary_circulation ///
peripheral_vascular ///
hypertension ///
paralysis ///
other_neurological ///
chronic_pulmonary ///
hypothyroidism ///
renal_failure ///
liver_disease ///
peptic_ulcer ///
aids ///
lymphoma ///
metastatic_cancer ///
solid_tumor ///
rheumatoid_arthritis ///
coagulopathy ///
obesity ///
weight_loss ///
fluid_electrolyte ///
deficiency_anemias ///
alcohol_abuse ///
drug_abuse ///
psychoses ///
depression ///
home_ccbs ///
, prvars(edem_num)


// Hosptial mortality as primary outcome, edema grade as the investigating variable

drop if peripheraledemagrade=="trace"

gen peri_grade_num=0
replace peri_grade_num=1 if peripheraledemagrade == "1+"
replace peri_grade_num=2 if peripheraledemagrade == "2+"
replace peri_grade_num=3 if peripheraledemagrade == "3+"

logit hosp_mort ///
i.peri_grade_num ///
age_first_icustay ///
i.gender_num ///
i.race_num ///
i. service_num ///
first_icustay_admit_saps ///
i.dm_comorbidity_combinedelixm ///
i.chf_comorbidity_combinedelix ///
i.cardiac_arrhythmias ///
i.valvular_disease ///
i.pulmonary_circulation ///
i.peripheral_vascular ///
i.hypertension ///
i.paralysis ///
i.other_neurological ///
i.chronic_pulmonary ///
i.hypothyroidism ///
i.renal_failure ///
i.liver_disease ///
i.peptic_ulcer ///
i.aids ///
i.lymphoma ///
i.metastatic_cancer ///
i.solid_tumor ///
i.rheumatoid_arthritis ///
i.coagulopathy ///
i.obesity ///
i.weight_loss ///
i.fluid_electrolyte ///
i.deficiency_anemias ///
i.alcohol_abuse ///
i.drug_abuse ///
i.psychoses ///
i.depression ///
i.home_ccbs ///
, or

lroc, nograph
estat gof, group(50) table

predict phat

nri1 hosp_mort ///
age_first_icustay ///
gender_num ///
race_num ///
service_num ///
first_icustay_admit_saps ///
dm_comorbidity_combinedelixm ///
chf_comorbidity_combinedelix ///
cardiac_arrhythmias ///
valvular_disease ///
pulmonary_circulation ///
peripheral_vascular ///
hypertension ///
paralysis ///
other_neurological ///
chronic_pulmonary ///
hypothyroidism ///
renal_failure ///
liver_disease ///
peptic_ulcer ///
aids ///
lymphoma ///
metastatic_cancer ///
solid_tumor ///
rheumatoid_arthritis ///
coagulopathy ///
obesity ///
weight_loss ///
fluid_electrolyte ///
deficiency_anemias ///
alcohol_abuse ///
drug_abuse ///
psychoses ///
depression ///
home_ccbs ///
, prvars(peri_grade_num) cut(50)

idi hosp_mort ///
age_first_icustay ///
gender_num ///
race_num ///
service_num ///
first_icustay_admit_saps ///
dm_comorbidity_combinedelixm ///
chf_comorbidity_combinedelix ///
cardiac_arrhythmias ///
valvular_disease ///
pulmonary_circulation ///
peripheral_vascular ///
hypertension ///
paralysis ///
other_neurological ///
chronic_pulmonary ///
hypothyroidism ///
renal_failure ///
liver_disease ///
peptic_ulcer ///
aids ///
lymphoma ///
metastatic_cancer ///
solid_tumor ///
rheumatoid_arthritis ///
coagulopathy ///
obesity ///
weight_loss ///
fluid_electrolyte ///
deficiency_anemias ///
alcohol_abuse ///
drug_abuse ///
psychoses ///
depression ///
home_ccbs ///
, prvars(peri_grade_num)

