#!/usr/bin/perl
# This file has been licensed under GPL by Jakob Voss

use strict;
use warnings;
use Pod::Usage;
use File::Basename;
use Cwd 'abs_path';

=head1 NAME

ditaa-markdown - preprocess ditaa diagrams embedded in pandoc markdown

=head1 SYNOPSIS

ditaa-markdown [-png|-pdf] [ditaa-options] input [output]

=cut

my $loc = dirname(abs_path($0));
my %ditaa = ( png => "$loc/ditaa0_6b.jar", pdf => "$loc/DitaaEps.jar" );
my ($file, $format, $blank);
my $count = 0;
my $depth = 0;
my $ditaaopts = "";

pod2usage(1) if grep /^-(help|h)$/, @ARGV;

if (@ARGV and $ARGV[0] =~ /^-(pdf|png)$/) {
	$format = $1;
	shift @ARGV;
} else {
	$format = 'png';
}

my $infile = shift @ARGV;
open (IN, "<", $infile) or die "failed to open $infile";

if (@ARGV and $ARGV[0] !~ /^-/) {
	my $outfile = shift @ARGV;
	open (OUT, ">", $outfile) or die "failed to open $outfile";
} else {
	*OUT = *STDOUT;
}

pod2usage("unknown format") unless $ditaa{$format};
pod2usage("missing ".$ditaa{$format}) unless -f $ditaa{$format}; 

while (<IN>) {
	if ($depth) {
		if ( /^(~{3,})\s*$/ and length($1) >= $depth ) {
			$depth = 0;
			close IMG;
			my $img = $format eq 'png' ? "$file.png" : "$file.eps";
			system join ' ', 'java', '-jar', $ditaa{$format}, @ARGV, "$ditaaopts", "$file.ditaa", $img, ">/dev/null";
			system "epstopdf", "-o", "$file.$format", $img if $format eq 'pdf';
			print OUT "![]($file.$format)\\ \n";
		} else {
			print IMG $_;
		}
	} else {
		if ( $blank and /^(~{3,})\s+\{\.ditaa(.*?)\}/ ) { # ~~~ {.ditaa <opts>}
			$depth = length($1);
            $ditaaopts = "$2";
			$count++;
			$file = "image-$count";
			open (IMG, ">", "$file.ditaa") or die "failed to open $file.ditaa";
		} else {
			$blank = ($_ =~ /^\s*$/);
			print OUT $_;
		}
	}
}
