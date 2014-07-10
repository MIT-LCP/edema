#!/usr/bin/perl -w

use Test::More tests => 10;
use Data::Dumper;
use ProcessMIMICText;

my @admission_drugs = [
          'VANCOMYCIN',
          'LEVOFLOXACIN',
          'METRONIDAZOLE',
          'HEPARIN',
          'SIMVASTATIN',
          'LISINOPRIL',
          'FUROSEMIDE',
          'ATENOLOL',
          'PANTOPRAZOLE',
          'ASCORBIC',
          'INSULIN',
          'BISACODYL',
          'DOCUSATE',
          'PERCOCET',
          'ASPIRIN',
          'METOPROLOL'
        ];

open (MYFILE, 'test_discharge_summaries/1.txt');
my $dc_sum = "";
while (<MYFILE>) {
    $dc_sum .= $_;
}

my $ref = {};

$ref->{'text'} = $dc_sum;
$ref->{'subject_id'} = 3;
$ref->{'hadm_id'} = 2075;

my %disch_sum_results = proc_disch_sum($ref);

is($disch_sum_results{'subject_id'}, 3, 'Subject ID correct' );

#print Dumper(%disch_sum_results);

is_deeply( \@{$disch_sum_results{'admission_drugs'}}, @admission_drugs, 'Admission drugs match' );

my @discharge_drugs = [
           'AMIODARONE',
           'METOPROLOL',
           'CAPTOPRIL',
           'ASPIRIN',
           'PANTOPRAZOLE',
           'HEPARIN',
           'ZINC',
           'SULFATE',
           'IPRATROPIUM',
           'NEBULIZERS',
           'ACETAMINOPHEN',
           'MICONAZOLE',
           'SANTYL',
           'INSULIN'
         ];

is_deeply( \@{$disch_sum_results{'discharge_drugs'}}, @discharge_drugs, 'Discharge drugs match' );

my $admission_drugs_section_text = 'MEDICATIONS ON ADMISSION:
 1.  Vancomycin 1 g intravenously q.24h. for a level of less
than 15 (started on [**2682-8-22**]).
 2.  Levofloxacin 250 mg p.o. q.d. (started on [**2682-8-22**]).
 3.  Metronidazole 500 mg p.o. q.8h. (started on [**2682-8-22**]).
 4.  Heparin 5000 units subcutaneous b.i.d.
 5.  Simvastatin 40 mg p.o. q.d.
 6.  Lisinopril 5 mg p.o. q.d.
 7.  Furosemide 40 mg p.o. q.d.
 8.  Vitamin E 400 IU p.o. q.d.
 9.  Atenolol 25 mg p.o. q.d.
10.  Pantoprazole 40 mg p.o. q.d.
11.  Ascorbic acid 500 mg p.o. b.i.d.
12.  NPH 17 units b.i.d.
13.  Regular insulin sliding-scale.
14.  Bisacodyl 10 mg p.o./p.r. as needed.
15.  Docusate 100 mg p.o. b.i.d.
16.  Percocet 5/325 mg one tablet p.o. q.4-6h. as needed for
pain.
17.  Aspirin 81 mg p.o. q.d.
18.  Metoprolol 75 mg p.o. b.i.d.

';

is( $disch_sum_results{'admission_medications_section_text'}, $admission_drugs_section_text, 'Admission drugs section extraction' );

my $discharge_drugs_section_text = 'MEDICATIONS ON DISCHARGE:
 1.  Amiodarone 400 mg p.o. b.i.d. (through [**2682-9-20**]), then 400 mg p.o. q.d. (times one week), then 200 mg
p.o. q.d.
 2.  Metoprolol 50 mg p.o. b.i.d.
 3.  Captopril 6.25 mg p.o. t.i.d.
 4.  Aspirin 325 mg p.o. q.d.
 5.  Pantoprazole 40 mg p.o. q.d.
 6.  Heparin 5000 units subcutaneously b.i.d.
 7.  Multivitamin one tablet p.o. q.d.
 8.  Zinc sulfate 220 mg p.o. q.d.
 9.  Vitamin C 500 mg p.o. q.d.
10.  Ipratropium nebulizers q.4-6h. as needed (for wheezing).
11.  Acetaminophen 325 mg to 650 mg p.o. q.4-6h. as needed
(for pain).
12.  Miconazole 2% powder to groin b.i.d.
13.  Santyl lotion to heels b.i.d.
14.  Regular insulin sliding-scale.

';

is( $disch_sum_results{'discharge_medications_section_text'}, $discharge_drugs_section_text, 'Discharge drugs section extraction' );

is( $disch_sum_results{'transfer_medications_section_text'}, undef, 'Transfer drugs section extraction' );

is( $disch_sum_results{'num_sections'}, 26, 'Number of sections matches' );

is( $disch_sum_results{'code_status_section_text'}, 'CODE STATUS:  Do not resuscitate/do not intubate.

', 'Code status section');

my @code_status = [
           'DNI',
           'DNR',
];

is_deeply( \@{$disch_sum_results{'code_status'}}, @code_status, 'Code status matches' );

#print Dumper(\@{$disch_sum_results{'code_status'}});

is( $disch_sum_results{'service'}, 'medical', 'Service type matches');

open (MYFILE, 'test_discharge_summaries/10057.txt');
my $dc_sum = "";
while (<MYFILE>) {
    $dc_sum .= $_;
}

my $ref = {};

$ref->{'text'} = $dc_sum;

my %disch_sum_results = proc_disch_sum($ref);

is($disch_sum_results{'num_sections'}, 32, 'Number of sections matches' );

is($disch_sum_results{'service'}, 'medical', 'Service type matches' );

@discharge_drugs = [
           'SENNA',
           'LANOLIN',
           'DOCUSATE',
           'MICONAZOLE',
           'LANSOPRAZOLE',
           'METOCLOPRAMIDE',
           'CAMPHOR-MENTHOL',
           'MUPIROCIN',
           'DULOXETINE',
           'FENTANYL',
           'ENOXAPARIN',
           'CALCIUM CARBONATE',
           'CHOLECALCIFEROL',
           'SIMETHICONE',
           'TRAMADOL',
           'ACETAMINOPHEN',
           'METOPROLOL TARTRATE',
           'ASPIRIN',
           'OXYCODONE-ACETAMINOPHEN',
           'IBUPROPHEN',
           'DIPHENHYDRAMINE',
           'LORAZEPAM',
           'PREDNISONE',
           'VANCOMYCIN',
           'HEPARIN',
           'SODUIM CHLORIDE'
         ];

# Discharge Medications:
# 1. Senna 8.6 mg Tablet Sig: One (1) Tablet PO BID (2 times a 
# day) as needed.  
# 2. Artificial Tear with Lanolin 0.1-0.1 % Ointment Sig: One (1) 
# Appl Ophthalmic PRN (as needed).  
# 3. Docusate Sodium 100 mg Capsule Sig: One (1) Capsule PO BID (2 
# times a day).  
# 4. Miconazole Nitrate 2 % Powder Sig: One (1) Appl Topical QID 
# (4 times a day) as needed.  
# 5. Lansoprazole 30 mg Tablet,Rapid Dissolve, DR [**Last Name (STitle) 481**]: One (1) 
# Tablet,Rapid Dissolve, DR [**Last Name (STitle) **] DAILY (Daily).  
# 6. Metoclopramide 10 mg Tablet Sig: One (1) Tablet PO QIDACHS (4 
# times a day (before meals and at bedtime)).  
# 7. Camphor-Menthol 0.5-0.5 % Lotion Sig: One (1) Appl Topical 
# DAILY (Daily) as needed.  
# 8. Mupirocin Calcium 2 % Cream Sig: One (1) Appl Topical BID (2 
# times a day).  
# 9. Duloxetine 20 mg Capsule, Delayed Release(E.C.) Sig: Three 
# (3) Capsule, Delayed Release(E.C.) PO DAILY (Daily) as needed 
# for chronic pain.  
# 10. Fentanyl 100 mcg/hr Patch 72HR Sig: One (1)  Transdermal 
# Q72H (every 72 hours).  
# 11. Enoxaparin 30 mg/0.3 mL Syringe Sig: One (1)  Subcutaneous 
# Q12H (every 12 hours).  
# 12. Calcium Carbonate 500 mg Tablet, Chewable Sig: One (1) 
# Tablet, Chewable PO TID W/MEALS (3 TIMES A DAY WITH MEALS).  
# 13. Cholecalciferol (Vitamin D3) 400 unit Tablet Sig: Two (2) 
# Tablet PO DAILY (Daily).  
# 14. Simethicone 80 mg Tablet, Chewable Sig: One (1) Tablet, 
# Chewable PO QID (4 times a day) as needed for gassy pain.  
# 15. Tramadol 50 mg Tablet Sig: One (1) Tablet PO QID (4 times a 
# day).  
# 16. Acetaminophen 650 mg Suppository Sig: One (1) Suppository 
# Rectal Q6H (every 6 hours) as needed for T>101.4.  
# 17. Metoprolol Tartrate 25 mg Tablet Sig: Three (3) Tablet PO 
# TID (3 times a day).  
# 18. Aspirin 325 mg Tablet Sig: One (1) Tablet PO DAILY (Daily).  

# 19. Oxycodone-Acetaminophen 5-325 mg Tablet Sig: One (1) Tablet 
# PO Q4-6H (every 4 to 6 hours) as needed.  
# 20. Ibuprofen 600 mg Tablet Sig: One (1) Tablet PO TID W/MEALS 
# (3 TIMES A DAY WITH MEALS).  
# 21. Diphenhydramine HCl 25 mg Capsule Sig: One (1) Capsule PO HS 
# (at bedtime) as needed.  
# 22. Lorazepam 0.5-2 mg IV Q4H:PRN 
# 23. Prednisone 5 mg Tablet Sig: Three (3) Tablet PO DAILY 
# (Daily).  
# 24. Vancomycin in Dextrose 1 g/200 mL Piggyback Sig: One (1)  
# Intravenous Q18HR () for 7 weeks.  
# 25. Heparin Flush PICC (100 units/ml) 2 ml IV DAILY:PRN 
# 10 ml NS followed by 2 ml of 100 Units/ml heparin (200 units 
# heparin) each lumen Daily and PRN.  Inspect site every shift. 
# 26. Sodium Chloride 0.9%  Flush 3 ml IV DAILY:PRN 
# Peripheral IV - Inspect site every shift 


is_deeply( \@{$disch_sum_results{'discharge_drugs'}}, @discharge_drugs, 'Discharge drugs match' );

#print Dumper(%disch_sum_results);
