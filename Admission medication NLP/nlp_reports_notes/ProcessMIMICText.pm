#!/usr/bin/perl -w
#-*- perl -*-

package ProcessMIMICText;
use strict;
use warnings;

# Dependencies
# perl-Log-Log4perl

# Test dependencies
# perl-Test-Simple

# Changes/Bug fixes:
# 04/12/12, djscott@mit.edu
#  Process radiology reports
# 03/30/12, djscott@mit.edu
#  Modify to read discharge summaries directly from DB
#  Process all drugs
# 12/13/11, lilehman@mit.edu
#  fixed parsing bugs that caused program to miss patterns such as "-omeprazole"
#  fixed bugs that missed the medications that are on the same line as the header
#  Added "Maternal" (medications) as a indicator for home medications
#  Change "transfer" medications to "other" instead of admission/home medications
# 12/19/2011, lilehman@mit.edu
#  Section heading such as "Medications:" or "Meds:" are now considered  as home/admission meds.

# Notes/Assumptions:
#  Section heading such as "Medications:" or "Meds:" are now considered  as home/admission meds.
#  "ethacrynic" is considred to refer to "ethacrynic acid"

use Exporter;
our @ISA= qw( Exporter );
our @EXPORT = qw(proc_disch_sum get_rhythm_from_radiology_report);

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($INFO);

use Storable qw(dclone);

sub proc_disch_sum {
    my $ref = $_[0];
    my @admission_drug_names;
    my $admission_drug_section_text;
    my @discharge_drug_names;
    my $discharge_drug_section_text;
    my @transfer_drug_names;
    my $transfer_drug_section_text;
    my %return_data;
    $return_data{'subject_id'} = $ref->{'subject_id'};
    $return_data{'hadm_id'} = $ref->{'hadm_id'};
    $return_data{'num_sections'} = 0;
    $return_data{'sections'} = ();
    my @discharge_summary_array = split /^/m, $ref->{'text'};
    my $line_count;
    my $prev_line_blank; # Previous line is blank, possible indicator of new section
    my $sect; # Section header
    my $type; # Section type (admission/discharge/transfer)
    my $sect_head_line_index;
    my $meds; # Flag to indicate if we are in a meds section
    my $logger = get_logger();
    foreach (@discharge_summary_array) {
        my $line = $_;
        $line_count++;

        # Attempt to find a section heading
        if (($prev_line_blank && ($line =~ /^((\d|[A-Z])(\.|\)))?\s*([a-zA-Z',\.\-\*\d\[\]\(\) ]+)(:|;|WERE| IS |INCLUDED|INCLUDING|were| is | included|including)/)) ||  ($line =~ /^((\d|[A-Z])(\.|\)))?\s*(A-Z[a-zA-Z',\.\-\*\d\[\]\(\) ]+)(:|;|WERE| IS |INCLUDED|INCLUDING|were| is | included|including)/)) {
            $logger->info("potential section heading:$line");
            $sect = $4;
            $type= ""; ## Reset section type
            $return_data{'num_sections'}++;
            push (@{$return_data{'sections'}}, $line);

            if ($meds) { ## med section ended, now in non-meds section

                #if this section header starts with meds or medications and it's immediately below another header,
                #then treat this as part of the previous section
                # this is for catching the following types of scenarios:
                #Medications on Admission:
                #Meds: Furosemide 10mg qday, metoprolol 12.5mg bid, MVI,

                if ($sect =~ /^[^a-zA-Z]*med(ication)?(s)?/i  && ($line_count == $sect_head_line_index+1) && ($type eq 'admission_medications') && ($sect !~ /discharge|transfer/i) ) {
                    #treat this as part of the previous meds section
                    $logger->info("Treat As Same Section $sect");
                } else {  #this is start of a new section
                    $meds = "";
                    $logger->info("meds section ended:$line");
                }
            }
            $sect_head_line_index = $line_count;

            if ( $sect =~ /medication|meds/i) { ## new meds section of some type
                $logger->info("meds section started:$sect");
                $meds = $sect;
                #first criteria does pattern matching on $line (instead of just on $meds)
                #IF previous line is blank and this line starts with something like Meds: or Medications: (potentially followed by some other words on the same line
                #or IF this line consists of just Meds or Medications or Meds: Medications: or Medication: (and nothing else following it), then we declare this as a HOME medication section
                if ($prev_line_blank && ($line=~  /\A\s*(\d)*.?\s*med(ication)?s?:\s*/i) ||
                    $line =~  /\A\s*(\d)*.?\s*med(ication)?s?:?\s*\Z/i) {
                    $type = 'admission_medications';
                }
                elsif ($meds =~ /admission|admitting/i){$type = 'admission_medications';}
                elsif ($meds =~ /presentation|baseline/i){$type = 'admission_medications';}
                elsif ($meds =~ /home|nh|nmeds/i){$type = 'admission_medications';}
                elsif ($meds =~ /pre(\-|\s)?(hosp|op)/i){$type = 'admission_medications';}
                elsif ($meds =~ /current|previous|outpatient|outpt|outside/i){$type = 'admission_medications';}
                #elsif ($meds =~ /^[^a-zA-Z]*med(ication)?(s)?/i){$type = 'admission';}
                elsif ($meds =~ /^Maternal/i){$type = 'admission_medications';}
                elsif ($meds =~ /transfer|xfer/i){$type = 'transfer_medications';}
                elsif ($meds =~ /discharge/i){$type = 'discharge_medications';}
                else{$type = $meds;} ## type other

                $return_data{$type . '_drugs_section'} = 1;

            } elsif ($sect =~ /chief complaint/i) { ##
                $logger->warn("Chief complaint section:$line");
                $type = 'chief_complaint';
            } elsif ($sect =~ /history of present illness/i) { ##
                $logger->warn("History section:$line");
                $type = 'history';
            } elsif ($sect =~ /past medical history/i) { ##
                $logger->warn("Past medical history section:$line");
                $type = 'history';
            } elsif ($sect =~ /social history/i) { ##
                $logger->warn("Social history section:$line");
                $type = 'history';
            } elsif ($sect =~ /allergies/i) { ##
                $logger->warn("Allergies section:$line");
                $type = 'allergies';
            } elsif ($sect =~ /physical examination on presentation/i) { ##
                $logger->warn("Physical examination section:$line");
                $type = 'physical_exam';
            } elsif ($sect =~ /laboratory data on presentation/i) { ##
                $logger->warn("Laboratory data section:$line");
                $type = 'laboratory';
            } elsif ($sect =~ /radiology/i) { ##
                $logger->warn("Radiology section:$line");
                $type = 'radiology';
            } elsif ($sect =~ /service/i) { ##
                $logger->warn("Service section:$line");
                $type = 'service';
            } elsif ($sect =~ /condition at discharge/i) { ##
                $logger->warn("Condition at discharge section:$line");
                $type = 'discharge_condition';
            } elsif ($sect =~ /discharge status/i) { ##
                $logger->warn("Discharge status section:$line");
                $type = 'discharge_status';
            } elsif ($sect =~ /discharge diagnoses/i) { ##
                $logger->warn("Discharge diagnoses section:$line");
                $type = 'discharge_diagnosis';
            } elsif ($sect =~ /code status/i) { ##
                $logger->warn("Code status section:$line");
                $type = 'code_status';
            } else {
                $logger->warn("Unidentified section:$line");
                $type = 'unidentified';
            }
        } elsif ($line =~ /medication|meds/i && $line =~ /admission/i) {  #else if this is not a section header but contains the words admission/medications, output to the log file
            # Attempt to catch invalid section headings in med section
            $logger->warn("$ref->{'subject_id'} matches admission medication|meds, but not section heading:$sect");
        }

        $return_data{$type . '_section_text'} .= $line;

        # if ($meds) { ## in meds section, look at line

        #     my @drugs = proc_disch_sum_line($line);

        #     if($type eq 'admission_medications') {
        #         $admission_drug_section_text .= $line;
        #         push (@admission_drug_names, @drugs);
        #     } elsif ($type eq 'discharge_medications') {
        #         $discharge_drug_section_text .= $line;
        #         push (@discharge_drug_names, @drugs);
        #     } elsif ($type eq 'transfer_medications') {
        #         $transfer_drug_section_text .= $line;
        #         push (@transfer_drug_names, @drugs);
        #     }
        # } # end of if ($meds)
	#check if this is a blank line
	if ($line =~ /^$/ || length(chomp($line))==0 || $line !~ /[a-zA-Z\d]/) {
	    $prev_line_blank = 1;
	} else {
	    $prev_line_blank = 0;
	}
    } # END while each line

    ## Process the sections
    @{$return_data{'code_status'}} = proc_code_status_section($return_data{'code_status_section_text'});
    $return_data{'service'} = proc_service_section($return_data{'service_section_text'});
    @{$return_data{'admission_drugs'}} = proc_medications_section($return_data{'admission_medications_section_text'});
    @{$return_data{'discharge_drugs'}} = proc_medications_section($return_data{'discharge_medications_section_text'});
    @{$return_data{'transfer_drugs'}} = proc_medications_section($return_data{'transfer_medications_section_text'});

    use Data::Dumper;
#    print Data::Dumper->Dump($return_data{'code_status'});

    return %return_data;
}

sub proc_medications_section {
    my $section_text = $_[0];
    my @section_text_array = split /^/m, $section_text;
    my @drugs = ();
    foreach (@section_text_array) {
        my $line = $_;
        push (@drugs, proc_disch_sum_line($line));
    }
    return @drugs;
}

sub proc_service_section {
    my $section_text = $_[0];
    my $servicetype;
    if ($section_text =~ /medicine/i) {
        $servicetype = 'medical';
    } else {
        $servicetype = 'unknown';
    }
    print $section_text;
    return $servicetype;
}

sub proc_code_status_section {
    my $section_text = $_[0];
    my @code_status_list = ();
    if ($section_text =~ /do not intubate/i) {
        push (@code_status_list, 'DNI');
    }
    if ($section_text =~ /do not resuscitate/i) {
        push (@code_status_list, 'DNR');
    }
    if ($section_text =~ /comfort measures/i) {
        push (@code_status_list, 'CMO');
    }
#    print Dumper(@code_status_list);
    return @code_status_list;
}


sub proc_disch_sum_line {
    my $ref = $_[0];
    my @drug_list = ();
    my @words = split (/[ ,\.\d\)_\W\s]+/ ,$ref);  #LL 12/13/11 added \W \s as a separator
    foreach my $word (@words) {
        $word =~ tr/[a-z]/[A-Z]/;
#                print "$word\n";

        # Need to add a regexp to detect drug names
        if ($word =~ /\w{4,}/i && $word !~ /ARTIFICIAL|TEAR|WITH|OINTMENT|APPL|OPHTHALMIC|MEDICATIONS|ADMISSION|INTRAVENOUSLY|LEVEL|LESS|STARTED|UNITS|REGULAR|TABLET|NEEDED|PAIN|DISCHARGE|THROUGH|THEN|TIMES|WHEEZING|POWDER|LOTION|GROIN|SLIDING|SCALE|THAN|SUBCUTANEOUS|WEEK|DIRECTED|TWICE|DAYS|SYRUP|MORNING|MOUTH|ONCE|NAME|NAMEPATTERN|NUMBER|UNKNOWN|HOUR|DOCTOR|LAST|FOUR|THREE|EVERY|HEELS|VITAMIN|ACID/i) {
            push (@drug_list, $word);
        }
    }
    return @drug_list;
}

sub get_rhythm_from_radiology_report {
    my $ref = $_[0];
    my $logger = get_logger();
    my @rhythm_list = ();
    my $radiology_report = $ref->{'text'};
#    $logger->warn("Processing radiology report:" . $radiology_report);
    if ($radiology_report =~ /supraventricular[ \s]rhythm/im) {
        push (@rhythm_list, 'supraventricular_rhythm');
    }
    if ($radiology_report =~/supraventricular\stachycardia/im) {
        push (@rhythm_list, 'supraventricular_tachycardia');
	}
    if ($radiology_report =~/supraventricular\stachy-?arrhythmia/im) {
        push (@rhythm_list, 'supraventricular_tachy_arrhythmia');
    }
    if ($radiology_report =~/supraventricular\sbradycardia/im) {
	push (@rhythm_list, 'supraventricular_bradycardia');
    }
    if ($radiology_report =~/junctional\srhythm/im) {
	push (@rhythm_list, 'junctional');
    }
    if ($radiology_report =~/a-v\sjunctional\sbradycardia/im) {
	push (@rhythm_list, 'a_v_junctional_brady');
    }
    if ($radiology_report =~/junctional\stachycardia/im) {
	push (@rhythm_list, 'junctional_tachy');
    }
    if ($radiology_report =~/junctional\sbradycardia/im) {
	push (@rhythm_list, 'junctional_brady');
    }
    if ($radiology_report =~/a-?v\s(paced|pacing)/im) {
	push (@rhythm_list, 'a_v_paced');
    }
    if ($radiology_report =~/a-v\ssequential[ly]?\s(paced|pacing|pacemaker)/im) {
	push (@rhythm_list, 'a_v_sequentially_paced');
    }
    if ($radiology_report =~/a-v\sdissociation/im) {
	push (@rhythm_list, 'a_v_dissociation');
    }

    if ($radiology_report =~/ectopic\satrial\sbradycardia/im) {
	push (@rhythm_list, 'ectopic_atrial_bradycardia');
    }
    if ($radiology_report =~/ectopic\satrial\stachycardia/im) {
	push (@rhythm_list, 'ectopic_atrial_tachycardia');
    }
    if ($radiology_report =~/ectopic\satrial\srhytt?hm/im) {
	push (@rhythm_list, 'ectopic_atrial_rhythm');
    }
    if ($radiology_report =~/left\sbundle[ -]branch\sblock/im) {
	push (@rhythm_list, 'left_bundle_branch_block');
    }
    if ($radiology_report =~/right\sbundle[ -]branch\sblock/im) {
	push (@rhythm_list, 'right_bundle_branch_block');
    }

    if ($radiology_report =~/atrial\sfibril[l]ation/im) {
	push (@rhythm_list, 'atrial_fibrilation');
    }
    if ($radiology_report =~/atrial\sflutter/im) {
	push (@rhythm_list, 'atrial_flutter');
    }
    if ($radiology_report =~/atrial\stachycardia/im) {
	push (@rhythm_list, 'atrial_tachycardia');
    }
    if ($radiology_report =~/atrial\sbradycardia/im) {
	push (@rhythm_list, 'atrial_bradycardia');
    }
    if ($radiology_report =~/atrial\spac(ing|ed)/im) {
	push (@rhythm_list, 'atrial_pacing');
    }
    if ($radiology_report =~/atrial\srhythm/im) {
	push (@rhythm_list, 'atrial_rhythm');
    }

    if ($radiology_report =~/ventricular\spac(ing|ed)/im) {
	push (@rhythm_list, 'ventricular_pacing');
    }
    if ($radiology_report =~/ventricular\stachycardia/im) {
	push (@rhythm_list, 'ventricular_tachycardia');
    }
    if ($radiology_report =~/ventricular\srhythm/im) {
	push (@rhythm_list, 'ventricular_rhythm');
    }

    if ($radiology_report =~/atrial\spacemaker/im) {
	push (@rhythm_list, 'atrial_pacemaker');
	}
    if ($radiology_report =~/ventricular\spacemaker/im) {
	push (@rhythm_list, 'ventricular_pacemaker');
    }
    if ($radiology_report =~/pacemaker\srhythm/im) {
	push (@rhythm_list, 'pacemaker_rhythm');
    }
    if ($radiology_report =~/dual\schamber\spacemaker/im) {
	push (@rhythm_list, 'dual_chamber_pacemaker');
    }
    if ($radiology_report =~/dual\schamber\selectronic\spacemaker/im) {
	push (@rhythm_list, 'dual_chamber_electronic_pacemaker');
    }
    if ($radiology_report =~/electronic\spacemaker/im) {
	push (@rhythm_list, 'electronic_pacemaker');
    }
    if ($radiology_report =~/imdionodal\srhythm/im) {
	push (@rhythm_list, 'idionodal_rhythm');
    }

    if ($radiology_report =~/sinus\stachycardia/im) {
	push (@rhythm_list, 'sinus_tachycardia');
    }
    if ($radiology_report =~/sinus\sbradyca?rdia/im) {
	push (@rhythm_list, 'sinus_bradycardia');
    }
    if ($radiology_report =~/sinus\sarrh?ythmia/im) {
        push (@rhythm_list, 'sinus_arrhythmia');
    }
    if ($radiology_report =~/sinus\srhythm?/im) {
	push (@rhythm_list, 'sinus_rhythm');
    }

    if ($radiology_report =~/paced\srhythm/im) {
	push (@rhythm_list, 'paced');
    }
    if ($radiology_report =~/regular\srhythm/im) {
	push (@rhythm_list, 'regular_rhythm');
    }

    use Data::Dumper;
    $logger->error(Dumper(@rhythm_list));
    return \@rhythm_list;
}

1;
