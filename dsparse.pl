###NOTES:
## -1 = no mention, 0 = negative mention, +1 = positive mention 
#$ds_fname = "topractice.txt";#debugging mode
$ds_fname = "4.8DS_set.txt";
$hadmid = -1;
$debug = 0;
open FILE, "$ds_fname" || die "Cant open $ds_fname $!";  #discharge summaries

while ($line = <FILE>) {
    	chomp($line);
	$line =~ s/\"/ /g;
	$total.=$line." ";# "\n"; #removed the newline so the code would read everything as one string (can add in for readability if necessary, but will need workaround)
	if ($line =~ /(\d+)_:-:_(\d+)_:-:_/) {
	    if ($hadmid != -1){
	#	if ($alltextlen <= 10){ #for short physical exams
		    if (($hasperipheraledema == -1)&& $total =~ /[^a-zA-Z](physical exam(ination)?|initial physical exam(ination)?|exam(ination)|exam (up)?on admission|exam (up)?on presentation)\:/i){
		#	print "Inner Loop\n";
		     	my $start = length($`);
			my $str = substr $total,$start,10000;
			$alltext = $str; #extend physical exam section
			if ($alltext =~ /(pertinent results|laboratory data|laboratories|hospital course|labs(:)? |medications )/i){
			    my $start = length($`);
			    my $str = substr $alltext,0,$start;
			    $alltext = $str; #but remove intrusion into other known sections
			}
	    if ($alltext =~ /((no [^.:]{1,20}|without[^.:]{1,20}|free of[^.:]{1,20}|no |negative[^.:]{1,10})+(pulmonary edema|crackles|rales))/i){
		$haspulmonaryedema = 0;
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
		$debug= "1";
#		print "\n $str \n";
	    } 
	    elsif ($alltext =~ /(pulmonary edema|(bibasilar)? crackle(s)?)/i){
		$haspulmonaryedema = 1;
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
		$debug= "2";
#		print "\n $str \n";
	    }
	    elsif ($alltext =~ /(chest|lungs|pulm.)[^.]{1,50}(rales|crackles)/i){#####
	        $haspulmonaryedema = 1;
		$debug= "3";
	    }
	    elsif ($alltext =~ /(rales|crackles)[^.]{1,50}(chest|lung(s)?|pulm)/i){#####
	        $haspulmonaryedema = 1;
		$debug= "4";
	    }
	    elsif ($alltext =~ /( rales|crackles)/i){
	        $haspulmonaryedema = 1;
		$debug= "4c";
	    }
	    elsif ($alltext =~ /clear to auscultation/i){
	        $haspulmonaryedema = 0;
	    }
	    elsif ($alltext =~ /(decreased|reduced)[^.]{1,10}(BS |breath sounds|lung sounds)/i){
		$haspulmonaryedema = 0;
		$debug= "5";
	    }
	    elsif ($alltext =~ /((lung(s)?|pulm(.)?(onary)?|res(p(iratory)?| |.)|chest)[^.]{1,40}clear)/i){
		$haspulmonaryedema = 0;
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
		$debug=  "6";
#		print "\n $str \n";
	    }
	    elsif ($alltext =~ /( BS |breath sounds|lung sounds)[^.0-9]{1,40}(equal|clear)?( bilateral(ly))?/i){
		$haspulmonaryedema = 0;
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
		$debug="7";
#		print "\n $str \n";
	    }
	    elsif ($alltext =~ /(:| |\.|-)(CTA|CTA B|CTAB|CTBLA)/i){
		$haspulmonaryedema = 0;
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
		 $debug= "8";
#		print "\n $str \n";
	    }

	    elsif ($alltext =~ /pulm(onary)?|lung| BS .{1,3}^(?!rate)[^0-9]{15}/i){
		$haspulmonaryedema = 0;
		$debug=  "9";
	    }
	    elsif ($alltext =~ /wheeze|wheezing|rhonchi|respiration[^0-9]{15}/i){
		$haspulmonaryedema = 0;
		$debug=  "10";
	    }
	    elsif ($alltext =~ /pulm|pul-|pul |pulmonary[^0-9]{15}(?!rate)/i){
		$haspulmonaryedema = 0;
	    }
	    elsif ($alltext =~ /breath sounds/i){
		$haspulmonaryedema  = 0;
	    }
	    elsif (($alltext =~ /(pul(.)? |chest|res(p(iratory)?| |p.{1,2} )|breath (sounds)?(?!per minute)| BS |lung|pulm(onary)?).{1,3}^(?!rate)^[0-9]/i)){#catch all
	        $haspulmonaryedema = 0;
		$debug=  "11";
	    }
	    if ($alltext =~ /ext(rem(ities)?|.{1,3} |remity|\s)(.{1,60})?(with|\+(1|2)|(1|2)\+)( trace | pitting | )edema/i){#I dont like this clause
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
#		print "\n $str \n";
		$debug=  "1a";
		$hasperipheraledema = 1;
	    }
	    elsif ($alltext =~ /ext(rem(ities)?|.{1,3} |remity|\s)(.{1,70})?(\+).( trace | pitting | )edema/i){#I dont like this clause
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
#		print "\n $str \n";
		$debug=  "1a";
		$hasperipheraledema = 1;
	    }
	    elsif($alltext =~ /skin[^.]{1,15}(devoid|without)[^.]{1,50}edema/i){
		 $debug= "2a";
		$hasperipheraledema = 0;
	    }
	    elsif($alltext =~ /(hand(s)?|feet)[^.]{1,10}(trace)? (edema|swelling)/i){
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
		 $debug= "3a";
#		print "\n $str \n";
	        $hasperipheraledema = 1;
	    }
	    elsif ($alltext =~/(\+).{1,3}( re | le | leg(s)? )edema/i){
		$debug= "4a";
		$hasperipheraledema = 1;
	    }
	    elsif ($alltext =~/(\+).{1,3}edema/i){
#		print "4b";
		$hasperipheraledema = 1;
	    }		
	    elsif ($alltext =~ /ext(rem(ities)?|.{1,3} |remity|\s)([^.]{1,60})?(without([^.]{1,30})?|free [^.]{1,40}|-)(edema|c.c.e|cce|swelling)/i){ #i should leave swelling here so that it still catches and marks as 0, not -1
		$hasperipheraledema = 0;
		$debug=  "5a";
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
#		print "\n $str \n";
	    }
	     elsif  ($alltext =~ /(ext(rem(ities)?| |.{1,3} )+[^.]{1,30})?+nonedematous/i){ 
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
		$debug= "6a";
#		print "\n $str \n";
		 $hasperipheraledema = 0;
	     }
	    elsif ($alltext =~ /((no [^.]{1,20}|no )(ext(.{1,3} |rem(ities)?|remity| )|peripheral|pedal)([^.:]{1,30})?(edema|cce|c.c.e|swelling))/i){ 
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
		$debug=  "6b";
#		print "\n $str \n";
		$hasperipheraledema = 0;
	    }
	    elsif ($alltext =~ /((no [^.]{1,20}|no )((ext |extr |extrem(ities)?|extremity| )|peripheral|pedal)([^.:]{1,30})?(edema|cce|c.c.e|swelling))/i){ 
	        $hasperipheraledema = 0;
		$debug= "7a";
	    }
	    elsif ($alltext =~/ext(.{1,3}|remity|rem(ities)?| )no [^.]{1,20}(edema|cce|c.c.e|swelling)/i){
		$hasperipheraledema = 0;
		 $debug= "8a";
	    }
	    elsif ($alltext =~ /ext(.{1,3} |remity|rem(ities)?| )[^.]{0,60}(no [^.]{1,20}|no |non)[^.]{0,30}(edema|cce|c.c.e|swelling)/i){ #new
		$hasperipheraledema = 0;
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
		$debug=  "9a";
#		print "\n $str \n";
	    }
	    elsif ($alltext =~ /(without[^.]{1,30}|free [^.]{1,40})(ext(rem(ities)?|.{1,3} |remity| )|peripheral|pedal)([^.]{1,30})?(edema|cce|c.c.e|swelling)/i){ #new
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
		$debug=  "10a";
#		print "\n $str \n";
		$hasperipheraledema = 0;
	    }
	    elsif  ($alltext =~ /((ext(.{1,3}\s|rem(ities)?|remity|\s)|pedal|peripheral)+([^.]{1,65})?edema)/i){
		$hasperipheraledema = 1;
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
		$debug=  "11a";
#		print "\n $str \n";
	    }
	    elsif ($alltext =~ /((ext(.{1,3}\s|rem(ities)?|remity|\s)|pedal|peripheral)+([^.]{1,30})?swelling)/i){#new for swelling catch
		$hasswelling = 1;
		$debug=  "12a";
	    }
	    elsif ($alltext =~ /anasarca/i){
		$hasperipheraledema = 1;
		$debug=  "13a";
	    }
	    elsif ($alltext =~/( re | le )edema/i){
		$debug=  "14a";
		$hasperipheraledema = 1;
	    }
	    elsif ($alltext =~ /well.perfused/i){#make this specific!!
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
#		print "\n $str \n";
		$debug= "15a";
		$hasperipheraledema = 0;
	    }
	    elsif ($alltext =~ /(\+)?.{1,5}(DP|PT).{1,10}pulses( intact)?/i){
		$hasperipheraledema = 0;
		$debug= "16a";
	    }
	    elsif ($alltext =~ /(\+)?[^0-9]{1,10}(pulses|distals)( intact| present| equal)?[^0-9]{10}/i){##must have 5 chars following with no numbers
		$hasperipheraledema = 0;
		$debug=  "16b";
	    }
	    elsif ($alltext =~ /pulses[^0-9.]{1,20}(DP|PT).{1,20}?(\+)?/i){
		 $debug= "17a";
	        $hasperipheraledema = 0;
	    }
	    elsif ($alltext =~ /(no [^.]{1,20}|no )edema|cce|c.c.e/i){
	        $hasperipheraledema = 0;
		$debug=  "18a";
	    }
	    elsif ($alltext =~ /no clubbing. cyanosis. or edema/i){
		$hasperipheraledema = 0;
		 $debug= "19a";
	    }
	    elsif ($alltext =~ /(without|free of)[^.]{1,30}edema|cce|c.c.e/i){
		$hasperipheraledema = 0;
		$debug= "20a";
	    }
	    elsif ($alltext =~ /(peripheral|ext(.{1,3} |rem(ities)?|remity| )|pedal|[^0-9]{5}feet )/i){
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
#		print "\n $str \n";
		$debug= "21a";
		$hasperipheraledema = 0;
	    }
#		    }
		}
#	    print "$hadmid,$haspulmonaryedema,$hasperipheraledema,$hasswelling,$historyfound,\"$total\", \n";#order of printed variables
# 		print "$hadmid, $haspulmonaryedema,$hasperipheraledema,$hasswelling,$historyfound,\n,$alltext,\n"; #debugging mode
		    print "$hadmid, $haspulmonaryedema, $hasperipheraledema, $hasswelling,$historyfound,\n";#normal mode
	    }
	    $hadmid = $1;
	    $case = $2; 
	    $alltext="";
	    $total = "";
	    $debug = 0;
	    $haspulmonaryedema = -1;
	    $hasperipheraledema = -1;
	    $hasswelling = -1;
	    $historyfound = -1;
	    $alltextlen = 0;
        }
	if (($prev_line_blank && ($line =~ /^((\d|[A-Z])(\.|\)))?\s*([a-zA-Z',\.\-\*\d\[\]\(\) ]+)(:|;|WERE| IS |INCLUDED|INCLUDING|were| is | included|including)/)) ||  ($line =~ /^((\d|[A-Z])(\.|\)))?\s*(A-Z[a-zA-Z',\.\-\*\d\[\]\(\) ]+)(:|;|WERE| IS |INCLUDED|INCLUDING|were| is | included|including)/)) {
	    $sect = $4;
	    if (($sect =~ /^[^a-zA-Z]*physical exam(ination)?/i)&& $sect !~ /discharge/i) {
		    $inexam=1;
		    $historyfound = 1;
	    }
	    else{$inexam=0;}
	}
#	if ($inexam){$alltext.= $line."\n";}
	if ($inexam){$alltext.= $line." ";
#	    if($line =~ /.{1,50}\[/){#remove blotted out names when reviewing text
#		print "\n \n \n \n \n HEY \n";
#		$start = length($`);
#		$str = substr $line,0,$start;
#		$alltext.= $str." "; 
#	    }
	    $alltextlen += 1;
	}


	$line_count++;
	if ($line =~ /^$/ || length(chomp($line))==0 || $line !~ /[a-zA-Z\d]/) {
	    $prev_line_blank = 1; 
	    $inexam = 0;
	    if ($alltext =~ /((no [^.:]{1,20}|without[^.:]{1,20}|free of[^.:]{1,20}|no |negative[^.:]{1,10})+(pulmonary edema|crackles|rales))/i){
		$haspulmonaryedema = 0;
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
#		print "1";
#		print "\n $str \n";
	    } 
	    elsif ($alltext =~ /(pulmonary edema|(bibasilar)? crackle(s)?)/i){
		$haspulmonaryedema = 1;
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
#		print "2";
#		print "\n $str \n";
	    }
	    elsif ($alltext =~ /(chest|lungs|pulm.)[^.]{1,50}(rales|crackles)/i){
	        $haspulmonaryedema = 1;
#		print "3";
	    }
	    elsif ($alltext =~ /(rales|crackles)[^.]{1,50}(chest|lung(s)?|pulm)/i){
	        $haspulmonaryedema = 1;
#		print "4";
	    }
	    elsif ($alltext =~ /( rales|crackles)/i){
	        $haspulmonaryedema = 1;
#		print "4c";
	    }
	    elsif ($alltext =~ /clear to auscultation/i){
	        $haspulmonaryedema = 0;
		}
	    elsif ($alltext =~ /(decreased|reduced)[^.:]{1,10}(BS |breath sounds|lung sounds)[^0-9]{5}/i){
		$haspulmonaryedema = 0;
#		print "5";
	    }
	    elsif ($alltext =~ /((lung(s)?|pulm(.)?(onary)?|res(p(iratory)?| |.)|chest)[^.]{1,40}clear)/i){
		$haspulmonaryedema = 0;
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
#		print "6";
##		print "\n $str \n";
	    }
	    elsif ($alltext =~ /( BS |breath sounds|lung sounds)[^0-9.]{1,40}(equal|clear)?( bilateral(ly))?/i){#could be big change removing numbers from this
		$haspulmonaryedema = 0;
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
#		print "7";
#		print "\n $str \n";
	    }
	    elsif ($alltext =~ /(:| |\.|-)(CTA|CTA B|CTAB|CTBLA)/i){
		$haspulmonaryedema = 0;
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
#		print "8";
#		print "\n $str \n";
	    }
	    elsif ($alltext =~ /pulm(onary)?|lung| BS .{1,3}^(?!rate)[^0-9]{15}/i){
		$haspulmonaryedema = 0;
		$debug=  "9";
	    }
	    elsif ($alltext =~ /wheeze|wheezing|rhonchi|respiration[^0-9]{15}/i){
		$haspulmonaryedema = 0;
#		print "10";
	    }
	    elsif ($alltext =~ /pulm|pul-|pul |pulmonary[^0-9]{15}(?!rate)/i){
		$haspulmonaryedema = 0;
	    }
	    elsif ($alltext =~ /breath sounds/i){
		$haspulmonaryedema  = 0;
	    }
	    elsif ($alltext =~ /(pul(-|m) |chest|res(p(iratory)?| |p.{1,2} )|breath (sounds)?(?!per minute)| BS |lung|pulm(onary)?).{1,3}^(?!rate)^[0-9]/i){#catch all
	        $haspulmonaryedema = 0;
#		print "11";
	    }
	    if ($alltext =~ /ext(rem(ities)?|.{1,3} |remity|\s)(.{1,60})?(with|\+(1|2)|(1|2)\+)( trace | pitting | )edema/i){#I dont like this clause
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
#		print "\n $str \n";
#		print "\n1a\n";
		$hasperipheraledema = 1;
	    }
	    elsif ($alltext =~ /ext(rem(ities)?|.{1,3} |remity|\s)(.{1,70})?(\+).( trace | pitting | )edema/i){#7.2.14
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
#		print "\n $str \n";
		$debug=  "1a";
		$hasperipheraledema = 1;
	    }
	    elsif($alltext =~ /skin[^.]{1,15}(devoid|without)[^.]{1,50}edema/i){
#		print "2a";
		$hasperipheraledema = 0;
	    }
	    elsif($alltext =~ /(hand(s)?|feet)[^.]{1,10}(trace)? (edema|swelling)/i){
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
#		print "3a";
#		print "\n $str \n";
	        $hasperipheraledema = 1;
	    }
	    elsif ($alltext =~/(\+).{1,15}( re | le | leg(s)? )edema/i){
#		print "4a";
		$hasperipheraledema = 1;
	    }
	    elsif ($alltext =~/(\+).{1,3}edema/i){
#		print "4b";
		$hasperipheraledema = 1;
	    }
	    elsif ($alltext =~ /ext(rem(ities)?|.{1,3} |remity|\s)([^.]{1,60})?(without([^.]{1,30})?|free [^.]{1,40}|-)(edema|c.c.e|cce|swelling)/i){ #i should leave swelling here so that it still catches and marks as 0, not -1
		$hasperipheraledema = 0;
#		print "5a";
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
#		print "\n $str \n";
	    }
	     elsif  ($alltext =~ /(ext(rem(ities)?| |.{1,3} )+[^.]{1,30})?+nonedematous/i){ 
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
#		print "6a";
#		print "\n $str \n";
		 $hasperipheraledema = 0;
	     }
	    elsif ($alltext =~ /((no [^.]{1,20}|no )(ext(.{1,3} |rem(ities)?|remity| )|peripheral|pedal)([^.:]{1,30})?(edema|cce|c.c.e|swelling))/i){ 
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
#		print "6b";
#		print "\n $str \n";
		$hasperipheraledema = 0;
	    }
	    elsif ($alltext =~ /((no [^.]{1,20}|no )((ext |extr |extrem(ities)?|extremity| )|peripheral|pedal)([^.:]{1,30})?(edema|cce|c.c.e|swelling))/i){ 
	        $hasperipheraledema = 0;
#		print "7a";
	    }
	    elsif ($alltext =~/ext(.{1,3}|remity|rem(ities)?| )no [^.]{1,20}(edema|cce|c.c.e|swelling)/i){
		$hasperipheraledema = 0;
#		print "8a";
	    }
	    elsif ($alltext =~ /ext(.{1,3} |remity|rem(ities)?| )[^.]{0,60}(no [^.]{1,20}|no |non)[^.]{0,30}(edema|cce|c.c.e|swelling)/i){ #new
		$hasperipheraledema = 0;
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
#		print "9a";
#		print "\n $str \n";
	    }
	    elsif ($alltext =~ /(without[^.]{1,30}|free [^.]{1,40})(ext(rem(ities)?|.{1,3} |remity| )|peripheral|pedal)([^.]{1,30})?(edema|cce|c.c.e|swelling)/i){ #new
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
#		print "10a";
#		print "\n $str \n";
		$hasperipheraledema = 0;
	    }
	    elsif  ($alltext =~ /((ext(.{1,3}\s|rem(ities)?|remity|\s)|pedal|peripheral)+([^.]{1,65})?edema)/i){
		$hasperipheraledema = 1;
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
#		print "11a";
#		print "\n $str \n";
	    }
	    elsif ($alltext =~ /((ext(.{1,3}\s|rem(ities)?|remity|\s)|pedal|peripheral)+([^.]{1,30})?swelling)/i){#new for swelling catch
		$hasswelling = 1;
#		print "12a";
	    }
	    elsif ($alltext =~ /anasarca/i){
		$hasperipheraledema = 1;
#		print "13a";
	    }
	    elsif ($alltext =~/( re | le )edema/i){
#		print "14a";
		$hasperipheraledema = 1;
	    }
	    elsif ($alltext =~ /well.perfused/i){#make this specific!!
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
##		print "\n $str \n";
#		print "15a";
		$hasperipheraledema = 0;
	    }
	    elsif ($alltext =~ /(\+)?.{1,5}(DP|PT).{1,10}pulses( intact)?/i){
		$hasperipheraledema = 0;
#		print "16a";
	    }
	    elsif ($alltext =~ /(\+)?[^0-9]{1,10}(pulses|distals)( intact| present| equal)?[^0-9]{10}/i){##must have 5 chars following with no numbers
		$hasperipheraledema = 0;
		$debug=  "16b";
	    }
	    elsif ($alltext =~ /pulses[^0-9.]{1,20}(DP|PT).{1,20}?(\+)?/i){
		 $debug= "17a";
	        $hasperipheraledema = 0;
	    }
	    elsif ($alltext =~ /(no [^.]{1,20}|no )edema|cce|c.c.e/i){
	        $hasperipheraledema = 0;
#		print "18a";
	    }
	    elsif ($alltext =~ /no clubbing. cyanosis. or edema/i){
		$hasperipheraledema = 0;
#		print "19a";
	    }
	    elsif ($alltext =~ /(without|free of)[^.]{1,30}edema|cce|c.c.e/i){
		$hasperipheraledema = 0;
#		print "20a";
	    }
	    elsif ($alltext =~ /!(extreme(ly)?)(peripheral|ext(.{1,3} |rem(ities)?|remity| )|pedal| [^0-9]{5}feet )/i){#SOMEthing weird here
		my $start = length($`);
		my $str = substr $alltext,$start-50,100;
#		print "\n $str \n";
#		print "21a";
		$hasperipheraledema = 0;
	    }

	}
	else {
	    $prev_line_blank = 0;
	}

}



#print"$hadmid,$haspulmonaryedema,$hasperipheraledema,$hasswelling,$historyfound,\"$total\", \n";#order of printed variables
print "$hadmid, $haspulmonaryedema ,$hasperipheraledema,$hasswelling,$historyfound,\n";
