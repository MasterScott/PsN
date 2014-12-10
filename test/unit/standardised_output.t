#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use FindBin qw($Bin);
use lib "$Bin/.."; #location of includes.pm
use includes; #file with paths to PsN packages

use standardised_output;
use XML::LibXML;

sub get_xml
{
    my $filename = shift;

    my $doc = XML::LibXML->load_xml(location => $filename);
    my $xpc = XML::LibXML::XPathContext->new($doc);
    $xpc->registerNs('x' => 'http://www.pharmml.org/2013/03/StandardisedOutput');

    return $xpc;
}

sub test_number_of_children
{
    my $xpc = shift;
    my $xpath = shift;
    my $number = shift;
    my $text = shift;

    my @nodes = $xpc->findnodes($xpath);
    is (scalar(@nodes), $number, $text);
}


our $tempdir = create_test_dir('unit_standardised_output');
copy_test_files($tempdir,
    [ "output/special_mod/data_missing.lst", "output/special_mod/missingmodel.lst", "output/special_mod/psnmissingdata.out", "output/special_mod/psnmissingmodel.out", "SO/bootstrap_results.csv" ]);

chdir $tempdir;

# non existing lst file
my $so = standardised_output->new(lst_files => [ "this_file_is_missing.lst" ]);
$so->parse;
my $xpc = get_xml("this_file_is_missing.SO.xml");
(my $node) = $xpc->findnodes('/x:SO/x:SOBlock/x:Estimation/x:TargetToolMessages/x:Errors');
ok (defined $node, "missing lst file");
test_number_of_children($xpc, '/x:SO/x:SOBlock/x:Estimation/*', 1, "missing lst file nothing more than TargetToolMessages");

# non existing multiple lst file
my $so = standardised_output->new(lst_files => [ "this_file_is_missing.lst", "this_too.lst" ]);
$so->parse;
my $xpc = get_xml("this_file_is_missing.SO.xml");
(my $node1, my $node2) = $xpc->findnodes('/x:SO/x:SOBlock/x:Estimation/x:TargetToolMessages/x:Errors');
ok (defined $node1, "multiple non existing lst files 1");
ok (defined $node2, "multiple non existing lst files 2");
test_number_of_children($xpc, '/x:SO/x:SOBlock/x:Estimation/*', 2, "multiple non existing lst files more than TargetToolMessages");

# missingdata.lst
my $so = standardised_output->new(lst_files => [ "missingdata.lst" ]);
$so->parse;
my $xpc = get_xml("missingdata.SO.xml");
(my $node) = $xpc->findnodes('/x:SO/x:SOBlock/x:Estimation/x:TargetToolMessages/x:Errors');
ok (defined $node, "missingdata.lst");
test_number_of_children($xpc, '/x:SO/x:SOBlock/x:Estimation/*', 1, "missingdata.lst nothing more than TargetToolMessages"); 

# missingmodel.lst
my $so = standardised_output->new(lst_files => [ "missingmodel.lst" ]);
$so->parse;
my $xpc = get_xml("missingmodel.SO.xml");
(my $node) = $xpc->findnodes('/x:SO/x:SOBlock/x:Estimation/x:TargetToolMessages/x:Errors');
ok (defined $node, "missingmodel.lst");
test_number_of_children($xpc, '/x:SO/x:SOBlock/x:Estimation/*', 1, "missingmodel.lst nothing more than TargetToolMessages"); 

# psnmissingdata.out
my $so = standardised_output->new(lst_files => [ "psnmissingdata.out" ]);
$so->parse;
my $xpc = get_xml("psnmissingdata.SO.xml");
(my $node) = $xpc->findnodes('/x:SO/x:SOBlock/x:Estimation/x:TargetToolMessages/x:Errors');
ok (defined $node, "psnmissingdata.out");
test_number_of_children($xpc, '/x:SO/x:SOBlock/x:Estimation/*', 1, "psnmissingdata.out nothing more than TargetToolMessages");

# psnmissingmodel.out
my $so = standardised_output->new(lst_files => [ "psnmissingmodel.out" ]);
$so->parse;
my $xpc = get_xml("psnmissingmodel.SO.xml");
(my $node) = $xpc->findnodes('/x:SO/x:SOBlock/x:Estimation/x:TargetToolMessages/x:Errors');
ok (defined $node, "psnmissingmodel.out");
test_number_of_children($xpc, '/x:SO/x:SOBlock/x:Estimation/*', 1, "psnmissingmodel.out nothing more than TargetToolMessages");

# bootstrap_results with no lst-files
my $so = standardised_output->new(bootstrap_results => "bootstrap_results.csv");
$so->parse;
my $xpc = get_xml("bootstrap.SO.xml");
(my $node) = $xpc->findnodes('/x:SO/x:SOBlock/x:Estimation/x:PrecisionPopulationEstimates/x:Bootstrap');
ok (defined $node, "lone bootstrap");
test_number_of_children($xpc, '/x:SO/x:SOBlock/x:Estimation/*', 1, "lone bootstrap nothing more than Bootstrap");

remove_test_dir($tempdir);

done_testing();
