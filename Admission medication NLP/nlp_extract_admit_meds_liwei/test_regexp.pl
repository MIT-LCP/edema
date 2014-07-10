#!/usr/bin/perl

$line = " blah ";
if ($line =~ /^((\d|[A-Z])(\.|\)))?\s*([a-zA-Z',\.\-\*\d\[\]\(\) ]+)(:|;|WERE| IS |INCLUDED|INCLUDING)/) {
    print "$line matches\n";
}
