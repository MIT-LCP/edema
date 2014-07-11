#!/usr/bin/perl -w
#-*- perl -*-
#usage: perl find-drugs2.pl ALL_DRUGS.LIST MIMIC2V26_DS.txt

#Output Files:
#     ALL_PT_WITH_HOME_MEDS_HEADER.list: list of pt (<subject_id> <hadm_id>) with admission meds sections (we will limit our study to this pt cohort)
#     TRANSFER_SID.list:  list of pt with transfer meds section in their discharge summaries
#     nlp_found_admission_drugs.txt:  this is the main output containing list of pt with drugs (PPI/H2/DIU) in admission medications. Format <subject_id> <hadm_id> <drug_name>
#     nlp.log: potential section headings
 
#Changes/Bug fixes:
#12/13/11, lilehman@mit.edu
#fixed parsing bugs that caused program to miss patterns such as "-omeprazole"
#fixed bugs that missed the medications that are on the same line as the header
#Added "Maternal" (medications) as a indicator for home medications
#Change "transfer" medications to "other" instead of admission/home medications
#12/19/2011, lilehman@mit.edu
# Section heading such as "Medications:" or "Meds:" are now considered  as home/admission meds.

#Notes/Assumptions:
# Section heading such as "Medications:" or "Meds:" are now considered  as home/admission meds.
# "ethacrynic" is considred to refer to "ethacrynic acid" 


#use strict;
use Data::Dumper;

#open drug file output
open (DRUGFILE, ">nlp_found_admission_drugs.txt") || die "output nlp_found_admission_drugs.txt $!";

#open nlp log file
open (LOGFILE, ">nlp.log") || die "output nlp.log $!";
 
#open  file output for pt that had transfer meds 
open (TFILE, "> TRANSFER_SID.list") || die "output TRANSFER_SID.list $!";

#open pt cohort file output (list of patients with home/admission medication in their discharge summaries)
open (ALL_PT_WITH_HOME_MEDS_FILE, ">ALL_PT_WITH_HOME_MEDS_HEADER.list") || die "output ALL_PT_WITH_HOME_MEDS_HEADER.list $!";


$drug_list_fname = $ARGV[0];  #list of drugs we are interested in
$ds_fname = $ARGV[1];         #discharge summary txt file

open DFILE, $drug_list_fname or die "Cannot open $drug_list_fname";
open FILE, "$ds_fname" || die "Cant open $ds_fname $!";  #discharge summaries

%drugs=();
&load_drugs();

&find_drugs();

#@drugs=<DFILE>;
#print @drugs;


close DRUGFILE;
close TFILE;
close ALL_PT_WITH_HOME_MEDS_FILE;




#===================================================
# load the list of drugs that we are looking for...
sub load_drugs {

    while ($line = <DFILE>) {
	#print $line;
	$line = &remcr($line);
	if (length($line) > 1) {
	    $line =~ tr/[a-z]/[A-Z]/;  # Convert the line to upper case.
            # PPIs:
            if ($line =~ /omeprazole|prilosec|esomeprazole|nexium|pantoprazole|protonix|lansoprazole|prevacid|rabeprazole|aciphex/i ) {
                $drugs{$line} = 0b1000;
                # H2-blockers:
            } elsif ( $line =~ /ranitidine|zantac|famotidine|pepcid|cimetidine|tagamet|axid|nizatidine/i ) {
                $drugs{$line} = 0b0100;
                # Diuretics
            #} elsif ( $line =~ /furosemide|lasix|hydrochlorothiazide|hctz|spironolactone|aldactone|torsemide|demadex|acetazolamide|diamox|nizatidine|triamterene|dyrenium|bumetanide|bumex|ethacrynic acid|edecrin|eplerenone|inspra|amiloride|midamor|metolazone|mykrox|zaroxolyn|chlorthalidone|hygroton|thalitone/i ) {
	    } elsif ( $line =~ /furosemide|lasix|hydrochlorothiazide|hctz|spironolactone|aldactone|torsemide|demadex|acetazolamide|diamox|nizatidine|triamterene|dyrenium|bumetanide|bumex|ethacrynic|edecrin|eplerenone|inspra|amiloride|midamor|metolazone|mykrox|zaroxolyn|chlorthalidone|hygroton|thalitone/i ) {

                $drugs{$line} = 0b0010;
            } else {  #should never happen
                print "drugs list does not match what's in perl code '$line' \n";
		print "$line \n";
                die;
            }
        }
    }
    close DFILE;
}

sub remcr {
    my ($line) = @_;
    while ($line =~ /[\n\r]$/){chop($line);}
    return ($line);
}

sub find_drugs {

    my $meds = ""; # Contains the section header which indicates that we're still in a medications section
    my $sect = "";
    my $type = "";
    my $ty = 0;
    my $medgroup = 0;
    my $found = 0;
    my $group = 0;
    my $admit = 'unk';
    my $disch = 'unk';
    my $other = 'unk';
    my @words = ();


    my $sect_head_line_index = 0;
    my $line_count = 0;
    $admit = 'unk'; $disch = 'unk'; $other = 'unk'; $ty = 0;
    my $prev_line_blank = 0;
    my $found_home_meds = 0;

 
    while ($line = <FILE>) {
    
	if ($line =~ /(\d+)_:-:_(\d+)_:-:_/) {
	    $hadmid = $1; $case = $2; 
	    #print "$hadmid\n"; 
	    $found_home_meds = 0;next;
        }

	chomp($line);
	$line_count++;


	#$line = &remcr($line);
	#$line =~ tr/[a-z]/[A-Z]/;  # Convert the line to upper case. commented out on 12/18/11

	## section head in ds
	#if ($line =~ /^((\d|[A-Z])(\.|\)))?\s*([a-zA-Z][a-zA-Z',\.\-\*\d\[\] ]+)(:|;|WERE|IS|INCLUDED|INCLUDING)/)
        #if ($line =~ /^((\d|[A-Z])(\.|\)))?\s*([a-zA-Z',\.\-\*\d\[\]\(\) ]+)(:|;|WERE| IS |INCLUDED|INCLUDING)/) {
	#if ($prev_line_blank & ($line =~ /^((\d|[A-Z])(\.|\)))?\s*([a-zA-Z',\.\-\*\d\[\]\(\) ]+)(:|;|WERE| IS |INCLUDED|INCLUDING|were| is | included|including)/)) {
      
	if (($prev_line_blank && ($line =~ /^((\d|[A-Z])(\.|\)))?\s*([a-zA-Z',\.\-\*\d\[\]\(\) ]+)(:|;|WERE| IS |INCLUDED|INCLUDING|were| is | included|including)/)) ||  ($line =~ /^((\d|[A-Z])(\.|\)))?\s*(A-Z[a-zA-Z',\.\-\*\d\[\]\(\) ]+)(:|;|WERE| IS |INCLUDED|INCLUDING|were| is | included|including)/)) {
            print LOGFILE "$case potential section heading:$line\n";
	    $sect = $4;
	    #print "$sect\n";
	    if ($meds) { ## med section ended, now in non-meds section

		#if this section header starts with meds or medications and it's immediately below another header,
                #then treat this as part of the previous section
		# this is for catching the following types of scenarios:
                #Medications on Admission:
                #Meds: Furosemide 10mg qday, metoprolol 12.5mg bid, MVI, 

		if ($sect =~ /^[^a-zA-Z]*med(ication)?(s)?/i  && ($line_count == $sect_head_line_index+1) && ($type eq 'admission') && ($sect !~ /discharge|transfer/i) ) {
		    #treat this as part of the previous meds section
		    print "Treat As Same Section $sect\n";
		} else {  #this is start of a new section
		    $meds = "";	
		    $type= "";
		    print LOGFILE "$case meds section ended:$line\n";
		}
	    }
	    $sect_head_line_index = $line_count; 
#	    print "---->$3\n";

	    #if $type is "" (i.e. $type is not already set) and the section header contains medications or meds
	    if ( !$type &&  $sect =~ /medication|meds/i) { ## new meds section of some type
                print LOGFILE "$case meds section started:$sect\n";
		$meds = $sect;
		$found = 0;
		
                #first criteria does pattern matching on $line (instead of just on $meds)
		#IF previous line is blank and this line starts with something like Meds: or Medications: (potentially followed by some other words on the same line
		#or IF this line consists of just Meds or Medications or Meds: Medications: or Medication: (and nothing else following it), then we declare this as a HOME medication section
		if ($prev_line_blank && ($line=~  /\A\s*(\d)*.?\s*med(ication)?s?:\s*/i) ||
		    $line =~  /\A\s*(\d)*.?\s*med(ication)?s?:?\s*\Z/i) {
		    $type = 'admission'; $ty = 1; 
		} 
		elsif ($meds =~ /admission|admitting/i){$type = 'admission'; $ty = 1;}
		elsif ($meds =~ /presentation|baseline/i){$type = 'admission'; $ty = 1;}
		elsif ($meds =~ /home|nh|nmeds/i){$type = 'admission'; $ty = 1;}
		elsif ($meds =~ /pre(\-|\s)?(hosp|op)/i){$type = 'admission'; $ty = 1;}
		elsif ($meds =~ /current|previous|outpatient|outpt|outside/i){$type = 'admission'; $ty = 1;}
		#elsif ($meds =~ /^[^a-zA-Z]*med(ication)?(s)?/i){$type = 'admission'; $ty = 1;}
		elsif ($meds =~ /^Maternal/i){$type = 'admission'; $ty = 1;}
		elsif ($meds =~ /transfer|xfer/i){$type = 'transfer'; $ty = 4;}  #we don't want transfer meds LL, 12/13/11
		elsif ($meds =~ /discharge/i){$type = 'discharge'; $ty = 2;}
		else{$type = $meds; $ty = 3;} ## type other

		if (($ty == 1) && ($admit eq 'unk')){$admit = 'no';} ## unk -> no -> yes
		elsif (($ty == 2) && ($disch eq 'unk')){$disch = 'no';}
		elsif (($ty == 3) && ($other eq 'unk')){$other = 'no';}

		if  ($type eq 'admission' && !$found_home_meds) {
		    print ALL_PT_WITH_HOME_MEDS_FILE  "$case $hadmid\n";  #output the subject id of all patients
		    $found_home_meds = 1;
		}
		
		if ($ty == 4) {
		    print TFILE "$case\n";
		}
	    } #end if section is medication|meds


	#} elsif ($line =~ /medication|meds/i && $line =~ /admission|discharge|transfer/i) {
	}    elsif ($line =~ /medication|meds/i && $line =~ /admission/i) {  #else if this is not a section header but contains the words admission/medications, output to the log file
            print LOGFILE "$case matches admission medication|meds, but not section heading:$sect\n";

        }

	if ($meds)	{ 	## in meds section, look at line

	    #@words = split (/[- ,\.\d\)]+/,$line); 
	    @words = split (/[ ,\.\d\)_\W\s]+/ ,$line);  #LL 12/13/11 added \W \s as a separator
	    foreach $word (@words) {
		$word =~ tr/[a-z]/[A-Z]/;
#                print "$word\n";

		if ($drugs{$word}) {
		    if ($type eq 'admission') { #only print if it is home/admission meds
			#print DRUGFILE "$case|$type|$word\n";
			print DRUGFILE "$case\t$hadmid\t$word\n";
		    }

		    #Add to the meds group if you haven't already
		    $medgroup = $medgroup | $drugs{$word};
		    if ($ty == 1){$admit = 'yes';}
		    elsif ($ty == 2){$disch = 'yes';}
		    elsif ($ty == 3){$other = 'yes';}
		    #print OFILE "$case|$type|$line\n";
		    $found = 1;
		}
	    }
	}  #end of if ($meds)
 
	#check if this is a blank line
	if ($line =~ /^$/ || length(chomp($line))==0 || $line !~ /[a-zA-Z\d]/) {
	    $prev_line_blank = 1;
	    #print "this is blank $line\n";
	} else {
	    $prev_line_blank = 0;
	    #$len = length($line);
	    #print "NOT BLANK:  $line\n";
	}

    } #END while each line

} #END SUB

