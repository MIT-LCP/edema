#!/usr/bin/perl -w

use Test::More tests => 2;
use Data::Dumper;
use ProcessMIMICText;

my @rhythms = [
          'supraventricular_rhythm',
          'ventricular_rhythm'
        ];

my $report = "SUPRAVENTRICULAR RHYTHM";

my $ref = {};

$ref->{'text'} = $report;
$ref->{'subject_id'} = 3;
$ref->{'hadm_id'} = 2075;

my $report_rhythms = get_rhythm_from_radiology_report($ref);
is_deeply( $report_rhythms, @rhythms, 'Rhythm correctly extracted' );

$report = "
Atrial fibrillation with a mean ventricular response rate 108. Compared to the
previous tracing of [**2012-06-10**] atrial fibrillation is now present.
TRACING #2


";

$ref->{'text'} = $report;
@rhythms = [
    'atrial_fibrilation'
    ];

@report_rhythms = get_rhythm_from_radiology_report($ref);
is_deeply( @report_rhythms, @rhythms, 'Atrial fibrilation correctly extracted' );
