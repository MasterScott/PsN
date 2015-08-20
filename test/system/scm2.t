#!/etc/bin/perl

use strict;
use warnings;
use Test::More tests=>11;
use Test::Exception;
use File::Path 'rmtree';
use FindBin qw($Bin);
use lib "$Bin/.."; #location of includes.pm
use includes; #file with paths to PsN packages and $path variable definition

use data;
use file;
use tool::scm::config_file;
use tool::scm;
use common_options;

our $tempdir = create_test_dir('system_scm2');
our $dir = "$tempdir/scm_test2";
our $scm_file_dir = $includes::testfiledir . '/scm';
our $file_dir = $includes::testfiledir;

my @config_files = qw (
config_alternative_parameterizations.scm
config_centering_bivariate.scm
config_different_parameterizations_different_covariates.scm
config_emax.scm
config_foce_backward.scm
config_foce_prop.scm
config_foce_prop_upd.scm
config_foce.scm
config_foce_upd.scm
config_grouping_categorical.scm
config_hockey.scm
);

foreach my $cfile (@config_files) {
	my $file = file -> new( name => $cfile, path => $scm_file_dir );
	my $config_file = 'tool::scm::config_file' -> new ( file => $file );
	my $modfile = $config_file->model();
	my $lstfile = $modfile;
	$lstfile =~ s/mod$/lst/;
	$lstfile = $scm_file_dir.'/'.$lstfile;
	$lstfile = undef unless ($config_file->linearize());

	my $models_array = [ model -> new ( filename           => $scm_file_dir.'/'.$modfile,
			target             => 'disk' ) ] ;

	my %options;
	$options{'nmfe'}=1;
	$options{'directory'}=$dir;
	common_options::setup( \%options, 'scm' ); 

	my $scm = tool::scm ->  new ( nmfe =>1,
		models	=> $models_array,
		directory => $dir,
		lst_file => $lstfile,
		config_file => $config_file,
		both_directions => 0);

	lives_ok {$scm->run()} "Running $cfile";

	rmtree([$dir]);
}

remove_test_dir($tempdir);

done_testing();