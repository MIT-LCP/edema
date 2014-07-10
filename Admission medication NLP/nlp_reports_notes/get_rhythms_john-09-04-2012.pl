#!/usr/bin/perl -w
#-*- perl -*-

use strict;
use warnings;

use ProcessMIMICText;
use Term::ReadPassword;
use DBI;

use Log::Log4perl qw(:easy);
Log::Log4perl->easy_init($INFO);

# Setup DB connection
my $dsn = "dbi:Oracle:MIMIC2.TESLA.MIMIC.CSAIL.MIT.EDU";
my $username = "djscott";

my $password = read_password("Password for $username: ");

my $dbh = DBI->connect($dsn, $username, $password);
$dbh->{LongReadLen} = 1024 * 1024; # 1MB
if (!defined($dbh)) {
    die("Failed to connect to database")
}

my $sth = $dbh->prepare("select subject_id, hadm_id, icustay_id, note_id, text from mimic2v25.noteevents where category = 'ECG_REPORT'") or die $dbh->errstr;
#my $sth = $dbh->prepare("select subject_id, hadm_id, icustay_id, note_id, text from mimic2v25.noteevents where category = 'ECG_REPORT' and subject_id < 10") or die $dbh->errstr;
$sth->execute;
while( my $ref = $sth->fetchrow_hashref('NAME_lc')) {
    my $line_count = 0;
    my $logger = get_logger();
    $logger->error("Processing subject ID:" . $ref->{'subject_id'} . " HADM ID:" . $ref->{'hadm_id'} . " ICU Stay ID:" . $ref->{'icustay_id'} . " Note ID:" . $ref->{'note_id'});
    my $hadm_id = $ref->{'hadm_id'};
    my $subject_id = $ref->{'subject_id'};
    my $icustay_id = $ref->{'icustay_id'};
    my $note_id = $ref->{'note_id'};

    my $radiology_report_rhythms = get_rhythm_from_radiology_report($ref);

    my $insert_rhythm = $dbh->prepare("insert into djscott.ecg_rhythms (subject_id, hadm_id, icustay_id, note_id, rhythm) values (?,?,?,?,?)") or die $dbh->errstr;
    $insert_rhythm->bind_param(1, $subject_id);
    $insert_rhythm->bind_param(2, $hadm_id);
    $insert_rhythm->bind_param(3, $icustay_id);
    $insert_rhythm->bind_param(4, $note_id);
    foreach my $rhythm (@$radiology_report_rhythms) {
        $insert_rhythm->bind_param(5, uc $rhythm);
        $insert_rhythm->execute || $logger->error($insert_rhythm->errstr);
    }
}
