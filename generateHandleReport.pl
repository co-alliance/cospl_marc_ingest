#!/usr/bin/perl
#
#   gen2 generate handle reoport for cospl -ekf 2013-0415
#
use strict;
use warnings;
no warnings qw(uninitialized);
use URI::Escape;
use LWP::Simple;
use POSIX qw(strftime);

if ( $#ARGV != 0 ) {
    print STDERR "\n Usage is $0 <PID list file>\n\n";
    exit(8);
}

my $UserName   = "fedoraAdmin";
my $PassWord   = 'PASSWORD';
my $ServerCall = "http://FQDN:8080/fedora/objects";
my $pidFile    = $ARGV[0];

my ( $filePrefix, $fileExtension ) = split( /\./, $pidFile );

my $timeStamp = POSIX::strftime( "%Y-%m%d-%H%M-%S", localtime );
my $updateHandleOut = "$filePrefix-updateHandleServer-$timeStamp.csv";
open my $updateHandleFH, ">", $updateHandleOut
    or die "could not open file $!";
my $handleReportOut = "$filePrefix-handleReport-$timeStamp.csv";
open my $handleReportFH, ">", $handleReportOut
    or die "could not open file $!";

open my $PIDfh, "<", $pidFile or die "could not open $pidFile: $!";
while ( my $line = <$PIDfh> ) {
    chomp $line;
    my ( $PID, $xmlFileName, $pdfFileName ) = split( /,/, $line );
    $PID =~ s/^\s+|\s+$//g;    # remove both leading and trailing whitespace
    my $recordId
        = qx(curl -s -u  $UserName:$PassWord -X GET "$ServerCall/$PID/datastreams/MODS/content" |tidy -xml -wrap 0 -f Error.tidy.txt | grep recordIdentifier );

    $recordId =~ s#<mods:recordIdentifier source="OCoLC">##g;
    $recordId =~ s#</mods:recordIdentifier>##g;
    $recordId =~ s#^\s+##g;
    $recordId =~ s#\s+$##g;

    my $title
        = qx(curl -s -u  $UserName:$PassWord -X GET "$ServerCall/$PID/datastreams/DC/content" |tidy -xml -wrap 0 -f Error.tidy.txt | grep dc:title );
    $title =~ s#<dc:title>##g;
    $title =~ s#</dc:title>##g;
    $title =~ s#^\s+##g;
    $title =~ s#\s+$##g;
    chomp $recordId;
    chomp $title;

    ##   API-M     http://$ServerCall/$PID/datastreams/DC/content
    my @allDatastreams
        = qx(curl -s -u  $UserName:$PassWord -X GET '$ServerCall/$PID/datastreams/MARC/content' |tidy -xml -wrap 0  -f Error.tidy.txt );
    my @desiredDatastreams;
    my $fileName;
    foreach my $line (@allDatastreams) {
        chomp $line;
        if ( $line =~ m#<marc:subfield code="u">http# ) {
            $line =~ s#<marc:subfield code="u">##g;
            $line =~ s#</marc:subfield>##g;
            $line =~ s#^\s+##g;
            $line =~ s#\s+$##g;
            my ( $beginningStringSplit, $endingStringSplit )
                = split( /\=/, $line );
            $endingStringSplit =~ s#http://www.cde.state.co.us/artemis/##g;
            ( my $ss1, my $ss2, $fileName )
                = split( /\//, $endingStringSplit );
        }
    }
    print $updateHandleFH "$PID,$fileName\n";
    print $handleReportFH
        "$PID,$recordId,$fileName,http://hdl.handle.net/10176/"
        . $PID . "_"
        . $fileName
        . ",$title\n";
}

print "\n";
