#!/usr/bin/perl
#
# ekf 2013-0403
# read MARCxml
# find datastream name in 856u
# check if exists datastream, if not write to log and continue with next file
# else  get nextPid,
#       determine collection PID from datastream name
#       create RELS-EXT and attach
#       tidy marcxml file for attachment
#       XSLT MODS and DC and attach
#       attach PDF
#

use strict;
use warnings;
use File::Find;
use URI::Escape;
use XML::Tidy;
use File::Basename;
use XML::Twig;
use URI::Escape;
use POSIX qw(strftime);
#### local settings to configure
my ($ServerName,              $ServerPort,
    $UserName,                $PassWord,
    $datastreamsDir,          $fedoraNamespace,
    $contentModel,            $dataStreamLocation,
    $datastreamFileExtension, $errorLogPrefix,
    $noDatastreamLogPrefix,   $xPathQueryForDatastream,
    $completedDirectory,      $logDirectory,
    $ingestLogPrefix,         $counterForSpecialCharacters,
    $collectionPID
);

my ( $marcOrgCode, $metaDataDirectory, $dataStreamDirectory );
## end of configuration section

if ( $#ARGV != 0 ) {
    print "\n Usage is $0 <configuration file> \n\n";
    exit(8);
}

my $configFile = $ARGV[0];
open my $configFH, "<", "$configFile"
    or die "\n\n   Program $0 stopping, couldn't open the configuration file '$configFile' $!.\n\n";
my $config = join "", <$configFH>;
close $configFH;
eval $config;
die "Couldn't interpret the configuration file ($configFile) that was given.\nError details follow: $@\n" if $@;

my $timeStamp = POSIX::strftime( "%Y-%m%d-%H%M-%S", localtime );
my $ingestLog = $logDirectory . $ingestLogPrefix . "-" . $timeStamp . ".log";
open my $log, ">", $ingestLog
    or die "\n     Unable to open $ingestLog\n\n";    # create error log
my $ingestErrorLog = $logDirectory . $errorLogPrefix . "-" . $timeStamp . ".log";
open my $errorLog, ">", $ingestErrorLog
    or die "\n     Unable to open $ingestErrorLog\n\n" ;    # create missing datastream log
my $SpecialCharacterErrorLog
    = $logDirectory
    . "SpecialCharacter-"
    . $errorLogPrefix . "-"
    . $timeStamp . ".log";
open my $specialErrorLog, ">", $SpecialCharacterErrorLog
    or die "\n     Unable to open $SpecialCharacterErrorLog\n\n" ;    # create missing datastream log

## end of configuration section
my $MagentaText = "\e[1;35m";
my $RedText     = "\e[1;31m";
my $GreenText   = "\e[1;32m";

my $BlueText   = "\e[0;44m";
my $NormalText = "\e[0m";
my ($dcTitle,               $dcCreator,
    $dcDate,                $dcDateCaptured,
    $dcDateCreated,         $qualifiedDcDescription,
    $dcDescriptionPlayback, $dcSubject,
    $dcSource,              $dcRelation,
    $dcIdentifier
);

# directory of MARC XML files
my @files
    = glob('*.xml'); #my @files = glob('/cdp/cdpsm/ColoradoCollege/dc/*.xml');
my @sortedFiles         = sort @files;
my $fileCounter         = '0';
my $noDatastreamCounter = '0';
foreach my $file (@sortedFiles) {
    $fileCounter++;
    chomp $file;

#my ( $beginningDirectoryStuff, $subdirectoryName, $fileName ) = split( /\//, $file );
    my $fileName = $file;    # print "(filename) $fileName\n";

    ##TODO test for special characters in MARC XML file
    open my $fhtidy, "<", $file
        or die "\n     Unable to open $file\n\n";    # read marcxml file
    my $fileOut = "marcTidyXml.out";
    open my $fhTidyOut, ">", $fileOut
        or die "\nError: Unable to write to temp file ' $fileOut' $! \n";
    while ( my $line = <$fhtidy> ) {
        print $fhTidyOut "$line";
    }
    my $fileTidy = "marcTidy.in";
    system("tidy -xml -wrap 0 -indent -f tidyError.error $fileOut > $fileTidy ");

    open my $fh0, "<", $fileTidy
        or die "\n     Unable to open $fileOut\n\n";  # read tidy marcxml file

    my ( $data, $length );
    my $problemLine;
    while ( chomp( $data = <$fh0> ) ) {
        $counterForSpecialCharacters++;
        $length = length($data);    # print "(data) " .  $data;
        my $i;
        for ( $i = 0; $i < $length; $i++ ) {
            if ( ord( substr( $data, $i, 1 ) ) > 127 ) {
                $problemLine
                    .= "\n-- Filename: $file -- Line Number: $counterForSpecialCharacters -- Column: $i -- \n";
                $problemLine .= "$data\n";
                last;
            }
        }
    }
    close($fh0);
    if ($problemLine) {    #not empty line, contains special character error
        print $specialErrorLog "$problemLine";
        next;
    }

##TODO get collection from  MARC XML file
#    my $collectionPIDcode = $collectionPID;   ### see also line 223 collectionPID
#    $collectionPIDcode =~ s#:#_#g;

    open my $fh, "<", $file
        or die "\n     Unable to open $file\n\n";    # read marcxml file

    ##################################################################
    #test if datastream exits
    my $datastream;
    my $datastreamXpath = XML::XPath->new( xml => $fh )
        ;    # create an object to parse $xml and field XPath queries
    my $datastreamNodeset = $datastreamXpath->find($xPathQueryForDatastream)
        ;    # apply the path and get back a list matches
    my $fileNameResult;
    my $noDatastreamCheck = 0;
    my @pdfDatastreams;
    my $locationOfDatastream;

    # print each node in the list
    foreach my $node ( $datastreamNodeset->get_nodelist ) {
        my $datastreamResult = XML::XPath::XMLParser::as_string($node);
        # split string only on last occurrence of separator
        my $i = rindex( $datastreamResult, "/" );
        my $partB = substr( $datastreamResult, $i + 1 ) ;    # print "\$partA:$partA, \$partB: $partB\n";
        $fileNameResult = $partB;
        find sub {
            /$fileNameResult/ && push @pdfDatastreams, $File::Find::name
                if -f;
        }, "$datastreamsDir";
        foreach (@pdfDatastreams) {
            if ( -e $_ ) {
                $locationOfDatastream = $_;
            }
            else {
                print $errorLog
                    "File $fileNameResult referenced in $file does not exist\n";
                print
                    "\nFile $fileNameResult referenced in $file does not exist\n";
                $noDatastreamCheck = 1;
            }
        }
    }
    if ( $noDatastreamCheck == 1 ) {
        $noDatastreamCounter++;
        next;
    }

    my $mimeTypeCode;
    ### getNextPid in Fedora
    # getNextPid using REST POST: /objects/new?namespace=demo to automatically get Next PID when ingesting FOXML
    my $PID = qx(curl -s -u ${UserName}:$PassWord -X POST "${ServerName}:${ServerPort}/fedora/objects/new?namespace=$fedoraNamespace");

    chomp $PID;
    # create a place to store the datastreams to attach
    my $directoryName = $PID;
    $directoryName =~ s#:#_#g;
    mkdir "$directoryName", 0777
        unless -d "$directoryName" ;    #make TMP directory unless it already exists
    print "\n[PID] $PID\n";
    $file =~ s#.\/##g;
    print $log "$PID,$file,$fileNameResult\n";
##################################################################
    # tidy MARCXML file
    open my $fh2, "<", $file
        or die "\n     Unable to open $file\n\n";    # read marcxml file
    my $tidy_doc = XML::Tidy->new( xml => $fh2 );
    $tidy_doc->tidy();
    my $tidyString = $tidy_doc->toString();

    my $xPathQuery = '//marc:record';                       # xPath query
    my $marcXpath = XML::XPath->new( xml => $tidyString ) ;    # create an object to parse $xml and field XPath queries
    my $marcNodeset = $marcXpath->find($xPathQuery) ;    # apply the path and get back a list matches
    # print each node in the list
    my $marcXmlFileTmp = "MARCXMLtmp";
    open my $marcXmlTmp, ">", "./$directoryName/$marcXmlFileTmp"
        or die "\n     Unable to open $marcXmlFileTmp\n\n"
        ;    # create human readable MARC XML
    my $marcResult;
    foreach my $node ( $marcNodeset->get_nodelist ) {
        $marcResult = XML::XPath::XMLParser::as_string($node);
        print $marcXmlTmp "$marcResult ";
    }
    close $marcXmlTmp;

    my $temp3 = "MARC";
    open( my $tmp3, ">", "./$directoryName/$temp3" )
        or die "\n     Unable to open $temp3\n\n";
    open( my $tempFile, ">", "tempFile.XML" )
        or die "\n     Unable to open tempFile\n\n";
    open( $marcXmlTmp, "<", "./$directoryName/$marcXmlFileTmp" )
        or die "\n     Unable to open $marcXmlFileTmp\n\n";
    while ( my $lineTmp = <$marcXmlTmp> ) {
        if ( $lineTmp =~ m#<marc:record># ) {
            print $tmp3
                q(<marc:record xmlns:marc="http://www.loc.gov/MARC21/slim">);
            print $tempFile
                q(<marc:record xmlns:marc="http://www.loc.gov/MARC21/slim">);
            print $tmp3 qq(\n);
            print $tempFile qq(\n);
        }
        else {
            print $tmp3 "$lineTmp";
            print $tempFile "$lineTmp";
        }
    }
    close $tempFile;

    #attach MARC XML datastream
    my $marcXmlFedoraId = "MARC";
    $mimeTypeCode = "xml";
    my $marcxmlDataStream = "./$directoryName/MARC";
    attach_datastream( $PID, $marcxmlDataStream, $file, $marcXmlFedoraId,
        $mimeTypeCode );

    my $prefixWavFileName;
    my $prefixPdfFileName;
    my $catalogNumber;
    my @dcSubject;
##################################################################
    my $relsExt;    #add RELS-EXT
    open( my $relsExtFH, ">", "./$directoryName/RELS-EXT" )
        or die "Cannot open: RELS-EXT\n";

    print $relsExtFH
        q(<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:fedora="info:fedora/fedora-system:def/relations-external#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:fedora-model="info:fedora/fedora-system:def/model#"> <rdf:Description rdf:about="info:fedora/)
        . $PID
        . q("> <fedora:isMemberOfCollection rdf:resource="info:fedora/)
        . $collectionPID
        . q("></fedora:isMemberOfCollection>
            <fedora-model:hasModel rdf:resource="info:fedora/)
        . $contentModel . q("></fedora-model:hasModel>
     </rdf:Description>
</rdf:RDF>);

    my $relsExtCode    = "./$directoryName/RELS-EXT";
    my $typeDatastream = "RELS-EXT";
    attach_datastream( $PID, $relsExtCode, $typeDatastream, $typeDatastream,
        $typeDatastream );

##################################################################
    #  attach XACML

    my $policyFile = "/home/ed/coIngestTool/POLICY";
    $typeDatastream = "POLICY";
    open( my $policyFileFH, "<", "$policyFile" ) or die "Cannot open: $policyFile  $!.\n\n";
    attach_datastream( $PID, $policyFile, $typeDatastream, $typeDatastream, $typeDatastream );

##################################################################
# MARC XML to DC transformation # really should be MODS to DC transformation
    my $marcXmlToTransform = "tempFile.XML";
    use XML::LibXSLT;
    use XML::LibXML;
    #use Encode;
    my $xslFile1     = "./XSL/MARC21slim2SRWDC-ADR-CSPL_12apr10.xsl";
    my $xml_parser1  = XML::LibXML->new;
    my $xslt_parser1 = XML::LibXSLT->new;

    #my $modsContent = encode('utf-8', $marcXmlToTransform);
    my $xml        = $xml_parser1->parse_file($marcXmlToTransform);
    my $xsl        = $xml_parser1->parse_file($xslFile1);
    my $stylesheet = $xslt_parser1->parse_stylesheet($xsl);
    my $results    = $stylesheet->transform($xml);
    my $output     = $stylesheet->output_string($results);

    # To save the output to a file, use output_file:
    my $dcOUT = "./$directoryName/DCout";
    print $stylesheet->output_file( $results, $dcOUT );

    my $DCfinal = "./$directoryName/DC";
    open( my $DCfh,    ">", $DCfinal ) or die " cannot open file $! ";
    open( my $dcOUTfh, "<", $dcOUT )   or die " cannot open file $! ";
    while ( my $line = <$dcOUTfh> ) {
        chomp $line;
        if ( $line =~ m#  <dc:type xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">#
            )
        {
            $line =~ s#  <dc:type xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">#  <dc:type>#g;
            print $DCfh "$line";
        }
        elsif ( $line =~ /dc:title/ ) {
            print $DCfh "$line\n";
            $dcTitle = $line;
            $dcTitle =~ s#<dc:title>##g;
            $dcTitle =~ s#</dc:title>##g;
            $dcTitle =~ s/^\s+//g;          #  strip white space before string
            $dcTitle =~ s/\s+$//g;          #  strip white space after string
                                            #print "$dcTitle\n";
        }
        else {
            print $DCfh "$line\n";
        }
    }
    close($DCfh);

    my $fedoraId = "DC";
    $mimeTypeCode = "xml";
    my $dcDataStream = "./$directoryName/DC";
    attach_datastream( $PID, $dcDataStream, $file, $fedoraId, $mimeTypeCode );
##################################################################
# create MODS from MARC XML file   using  ./XSL/CSPL_MARC2MODS_adrb-2012-0413-rbd.xsl

# MARC XML to MODS transformation    ( use tidy-ed MARCXML instead of original MARCXML file )
    my $modsXslt = "./XSL/COSPL_MARC2MODS_2013-10-08.xsl";
    my $modsOUT  = "./$directoryName/outputMODS";
    my $marcXml  = "./$directoryName/MARC";

#example command:  saxonb-xslt -xsiloc:on -ext:on -o:./adr_333/outMODS.XML -xsl:CSPL_MARC2MODS_adrb-2012-0413-rbd.xsl  -s:./adr_333/$marcXml
    my $modsCommand
        = "saxonb-xslt -xsiloc:on -ext:on -o:./$directoryName/outputMODS -xsl:$modsXslt -s:$marcXml"
        . q( 2>/dev/null);

    system($modsCommand);    # run marc2mods transformation
    if ( $? == -1 ) {
        print $log "failed to execute: $!\n";
    }
    elsif ( $? & 127 ) {
        printf $log "child died with signal %d, %s coredump\n",
            ( $? & 127 ), ( $? & 128 ) ? 'with' : 'without';
    }
    else {
        printf $log "child exited with value %d\n", $? >> 8;
    }

    my $modsTidyOUT = "./$directoryName/modsTidyOUT";
    my $tidyModsCommand = "tidy -xml -wrap 0 --output-file $modsTidyOUT -f tidyError.error $modsOUT";
    system($tidyModsCommand);    # run tidy transformation
    my $modsTidyOUT2 = "./$directoryName/modsTidyOUT2";
    open( my $modsTidyOUT2fh, ">", $modsTidyOUT2 )
        or die " cannot open file $! ";
    open( my $modsXMLin, "<", $modsTidyOUT ) or die " cannot open file $! ";
    while ( my $line = <$modsXMLin> ) {
        if ( $line =~ m#<mods:subject authority="lcsh">\n# ) {
            $line
                =~ s#<mods:subject authority="lcsh">\n#<mods:subject authority="lcsh">#g;
            print $modsTidyOUT2fh "$line";
        }
        else {
            chomp $line;
            print $modsTidyOUT2fh "$line\n";
        }
    }
    close($modsTidyOUT2fh);

    my $modsTidyOUT3 = "./$directoryName/modsTidyOut3";
    open( my $modsTidyOUT3fh, ">", $modsTidyOUT3 )
        or die " cannot open file $! ";
    my $modsTidyOUT2File = "./$directoryName/modsTidyOUT2";
    open( my $modsTidyIn2fh, "<", $modsTidyOUT2File )
        or die " cannot open file $! ";
    while ( my $line = <$modsTidyIn2fh> ) {
        chomp $line;    ###### print "$line\n";
        if ( $line =~ m#<mods:subject authority="lcsh"><mods:topic># ) {
            $line
                =~ s#--#</mods:topic>\n</mods:subject>\n <mods:subject authority="lcsh">\n<mods:topic>#g;
            print $modsTidyOUT3fh "$line\n";
        }
        elsif ( $line =~ m#^<mods:topic># ) {
            $line =~ s#--#</mods:topic>\n<mods:topic>#g;
            print $modsTidyOUT3fh "$line\n";
        }
        else {
            print $modsTidyOUT3fh "$line\n";
        }
    }
    close($modsTidyOUT3fh);

    my $outModsXML3 = "./$directoryName/modsTidyOut3";
    open( my $modsOUTFILEfh, "<", $outModsXML3 )
        or die " cannot open file $! ";
    my @modsDeDupe;
    while ( my $line = <$modsOUTFILEfh> ) {
        chomp $line;
        $line
            =~ s#<mods:mods xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:mods="http://www.loc.gov/mods/v3">#<mods:mods xmlns:mods="http://www.loc.gov/mods/v3">#g;
        $line =~ s/install$//g;
        $line =~ s/^\s+//g;       #  strip white space before string
        $line =~ s/\s+$//g;       #  strip white space after string
                                  # print if $line =~ m#^<topic#;
        push( @modsDeDupe, $line );
    }
    my %seen = ();
    my @modsSubjectDeduped;
    foreach my $item (@modsDeDupe) {
        push( @modsSubjectDeduped, $item )

#unless ( $seen{$item}++ and $item =~ m#^<mods:subject authority="lcsh"><mods:topic># );
            unless ( $seen{$item}++ and $item =~ m#<mods:topic># );
    }
    my $modsOUTdeduped = "./$directoryName/MODSdeduped";
    open( my $modsOUTfh, ">", $modsOUTdeduped )
        or die " cannot open file $! ";
    foreach my $item (@modsSubjectDeduped) {
        print $modsOUTfh "$item\n";
    }
    close($modsOUTfh);

    my $modsFinal    = "./$directoryName/MODSdeduped";
    my $modsFinalOUT = "./$directoryName/MODS";
    my $tidyModsFinalCommand
        = "tidy -xml -indent -wrap 0 --output-file $modsFinalOUT -f tidyError.error $modsFinal"
        ;    # print "$tidyModsFinalCommand\n";
    system($tidyModsFinalCommand);    # run tidy transformation

####################

    open my $modsFile, '<', $modsFinalOUT
        or die "\n     Unable to open $modsFinalOUT\n\n";    # read xml file
    my $xPathQueryForModsTitle
        = "/mods:mods/mods:titleInfo[1]/mods:title/text()"
        ;    # xPath query for first mods:title
    my $modsTitleXpath = XML::XPath->new( xml => $modsFile )
        ;    # create an object to parse $xml and field XPath queries
    my $modsTitle = $modsTitleXpath->find($xPathQueryForModsTitle)
        ;    # apply the path and get back a list matches

####################

    #    open( my $modsOUTfh, ">", $modsOUT ) or die " cannot open file $! ";
    #    print $stylesheet->output_file( $results2, $modsOUT );
    my ( $dataStreamName, $modsFedoraId );
    $modsFedoraId = "MODS";
    $mimeTypeCode = "xml";
    my $modsDataStream = "./$directoryName/MODS";
    attach_datastream( $PID, $modsDataStream, $file, $modsFedoraId,
        $mimeTypeCode );
##################################################################

    my @attachPdfDatastreams;
    find sub {
        /$prefixPdfFileName/ && push @attachPdfDatastreams, $File::Find::name
            if -f;
    }, ".";
    foreach my $pdfDatastream (@attachPdfDatastreams) {
        my $dataStream = $pdfDatastream;
        $dataStream =~ s#\ #\\ #g;    #TODO escape spaces
        my ( $dataStreamName, $fedoraMp3DSId );
        my $dataStreamWithoutSpaces = $pdfDatastream;
        $dataStreamWithoutSpaces
            =~ s#,##g;    # fedora-ize filename of MP3 need to remove commas
        $dataStreamWithoutSpaces
            =~ s# #_#g;    # fedora-ize filename of MP3 need to remove spaces
        my ( $filename, $dir, $ext )
            = fileparse( $dataStream, qr/\.[^.]*/ )
            ;              # split argument from commandline into components
        my ( $firstPartFilename, $theRestFilename )
            = split( /\\/, $filename, 2 );

    }
    my $pdfDSId       = "$fileNameResult";
    my $pdfDatastream = "$locationOfDatastream";
    $mimeTypeCode = "PDF";
    attach_datastream( $PID, $pdfDatastream, $pdfDSId, $pdfDSId,
        $mimeTypeCode );    # attach datastreams


# attach datastreams
##################################################################
    #TODO limit Fedora Label to 250 characters to remain below Fedora limit

    #  insert fedora label from MODS title
    my $modsTitleForLabel = uri_escape($modsTitle);
    my $labelUriEncoded = substr( $modsTitleForLabel, 0, 250 );
    my $labelCommand
        = qq(curl -s -u  $UserName:$PassWord -X PUT "${ServerName}:${ServerPort}/fedora/objects/)
        . $PID
        . q(?label=)
        . $labelUriEncoded . q(");

    system($labelCommand);
    use File::Copy;

    #print qq(move - $file to $completedDirectory);           #
    move( $file, $completedDirectory );

    #print qq(move - $fileNameResult to $completedDirectory);   #
    move( $fileNameResult, $completedDirectory );
}

##################################################################
print "\n\nNumber of MARC files processed: ";
print scalar(@files);
print
    "\n   Number of lines with Special Characters:  $counterForSpecialCharacters";
print
    "\n   Number of MARC XML files referencing datastreams which are NOT found:  $noDatastreamCounter\n";

unlink("tidyError.error");    # delete temp file
unlink("tempFile.XML");       # delete temp file

sub attach_datastream {

    my ( $pid, $fileName, $baseFileName, $datastreamID, $mimeTypeCode ) = @_;
    chomp $mimeTypeCode;
    my ( $contentType, $controlGroup, $datastreamLabel, $mimeType );

    #    print "[zero]: $MagentaText$pid$NormalText";
    #    print "[one]: $BlueText$fileName$NormalText";
    #    print "[two]: $MagentaText$oaiDcFileName$NormalText";
    #    print "[three]: $BlueText$datastreamID $NormalText";
    #    print "[four]: $MagentaText$mimeTypeCode $NormalText\n";
    if ( $datastreamID eq "RELS-EXT" ) {
        $contentType     = "text/xml";
        $mimeType        = "application%2Frdf%2Bxml";
        $controlGroup    = "controlGroup=X&versionalble=true";
        $datastreamLabel = 'Relationships%20to%20other%20objects';
    }
    elsif ( $datastreamID eq "MARC" ) {
        $contentType     = "text/xml";
        $mimeType        = "text/xml";
        $controlGroup    = "controlGroup=X&versionalble=true";
        $datastreamLabel = 'MARC';
    }
    elsif ( $mimeTypeCode eq "PDF" ) {
        $contentType     = "application/pdf";
        $mimeType        = "application/pdf";
        $controlGroup    = "controlGroup=M";
        $datastreamLabel = "$baseFileName";

    }
    elsif ( $datastreamID eq "MODS" ) {
        $contentType     = "text/xml";
        $mimeType        = "text/xml";
        $controlGroup    = "controlGroup=X&versionalble=true";
        $datastreamLabel = 'Metadata%20Object%20Description%20Schema';
    }
    elsif ( $datastreamID eq "DCBUILDER" ) {
        $contentType     = "text/xml";
        $mimeType        = "text/xml";
        $controlGroup    = "controlGroup=X";
        $datastreamLabel = 'harvested%20from%20DCBuilder%20metadata';
    }
    elsif ( $datastreamID eq "POLICY" ) {
        $contentType     = "text/xml";
        $mimeType        = "text/xml";
        $controlGroup    = "controlGroup=X&versionalble=true";
        $datastreamLabel = 'XACML%20Policy%20Stream';
    }
    elsif ( $datastreamID eq "DC" ) {
        $contentType     = "text/xml";
        $mimeType        = "text/xml";
        $controlGroup    = "controlGroup=X&versionalble=true";
        $datastreamLabel = 'Dublin%20Core%20Record';
    }
    elsif ( $datastreamID eq "RELS-INT" ) {
    }
    else {
        if ( $mimeTypeCode eq "wav" ) {
            $contentType     = "audio/x-wav";
            $mimeType        = "audio/x-wav";
            $controlGroup    = "controlGroup=M";
            $datastreamLabel = $datastreamID;
        }
        elsif ( $mimeTypeCode eq "TIF" ) {
            $contentType     = "image/tif";
            $mimeType        = "image/tif";
            $controlGroup    = "controlGroup=M";
            $datastreamLabel = $datastreamID;
        }
        elsif ( $mimeTypeCode eq "mp3" ) {
            $contentType     = "audio/mpeg";
            $mimeType        = "audio/mpeg";
            $controlGroup    = "controlGroup=M";
            $datastreamLabel = $datastreamID;
        }
        else {
            $contentType     = "text/xml";
            $mimeType        = "text/xml";
            $controlGroup    = "controlGroup=M";
            $datastreamLabel = '';
        }
    }

    my $curlCommand
        = "curl -s -u $UserName:$PassWord --data-binary \@$fileName -H \"Content-type:"
        . $contentType
        . qq(" -X POST '${ServerName}:${ServerPort}/fedora/objects/)
        . $pid
        . qq(/datastreams/$datastreamID?$controlGroup&dsLabel=$datastreamLabel&mimeType=$mimeType' 1>/dev/null);

    #print "$curlCommand \n" ; # debugging       otherwise
    system($curlCommand);    #post datastream
}

