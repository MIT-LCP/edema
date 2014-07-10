-- Sample queries for validation of NLP on admission medications

-- All rows
select * from DJSCOTT.med_dc;

-- All admission medications
select * from DJSCOTT.med_dc where type = 'admission';

-- All admission medications for subjects in a range (sorted by subject_id)
select * from DJSCOTT.med_dc where type = 'admission' and subject_id between 1 and 1000 order by subject_id;

-- Discharge summary for a patient. (The 'TEXT' column contains the actual text)
select * from mimic2v26.noteevents where category = 'DISCHARGE_SUMMARY' and subject_id = 3;