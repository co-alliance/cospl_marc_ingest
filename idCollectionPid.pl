#!/usr/bin/perl
#                find collection PID from cospl MARC     -ekf 2014-0827
#
use strict;
use warnings;
use XML::XPath;

my $xmlFile = $ARGV[0];
open my $fh, "<", $xmlFile
    or die "\n     Unable to open \n\n";    # read marcxml file

my %collectionList = (
    ADM  => 7552,
    AG   => 3,
    CR   => 3055,
    ED   => 7,
    GA   => 9,
    GO   => 11,
    GOV  => 10,
    HCP  => 14,
    HE   => 15,
    HED  => 16,
    HU   => 17,
    LAW  => 19,
    LBE  => 20,
    LOC  => 3145,
    NR   => 3147,
    PA   => 3148,
    PS   => 4541,
    REG  => 4542,
    REV  => 4543,
    SC   => 3151,
    S    => 3150,
    TRA  => 4544,
    UCB  => 4545,
    UCD  => 3153,
    UCSM => 10005,
    UCSU => 3156,
);

#xPath query string

my $xPathQueryForDatastream
    = '//marc:datafield[@tag="086"][1]/marc:subfield[@code="a"]/text()';

my $datastreamXpath = XML::XPath->new( xml => $fh )
    ;    # create an object to parse $xml and field XPath queries
my $datastreamNodeset = $datastreamXpath->find($xPathQueryForDatastream)
    ;    # apply the path and get back a list matches

# print each node in the list
foreach my $node ( $datastreamNodeset->get_nodelist ) {

    #print XML::XPath::XMLParser::as_string( $node ) . "\n";
    my $datastreamResult = XML::XPath::XMLParser::as_string($node);
    print $datastreamResult;
    print "\n";
    my $collectionName = $datastreamResult;
    $collectionName =~ /^(\D+)/;
    my $name      = $1;
    my $pidNumber = find_key( \%collectionList, $name );
    my $pid       = "co:" . $pidNumber;
    print "Name: $name         PID: $pid\n";
}

sub find_key {
    my ( $h, $value ) = @_;
    while ( my ( $k, $v ) = each %$h ) {
        return $v if $k eq $value;
    }
    return;
}
