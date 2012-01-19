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

my $count = 0;       # image counter to get unique image file names
my $depth = 0;       # number of tildes if inside a code block
my $justcode;        # true if inside a non-ditaa code block
my $ditaaopts = "";  # ditaa command line options for the current image
my $alt = "";        # alt text of current image
my $caption = "";    # caption of current image

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
            if ($justcode) {
                $justcode = 0;
                print OUT $_;
            } else {
                close IMG;
                my $img = $format eq 'png' ? "$file.png" : "$file.eps";
                system join ' ', 'java', '-jar', $ditaa{$format}, @ARGV, "$ditaaopts", "$file.ditaa", $img, ">/dev/null";
                system "epstopdf", "-o", "$file.$format", $img if $format eq 'pdf';
                my $md = "![$alt]($file.$format";
                $caption = " \"$caption\"" if $caption;
                $md .= "$caption)";
                $md .= '\ ' unless $alt;
                print OUT "$md\n";
            }
		} else {
            if ($justcode) {
    			print OUT $_;
            } else {
    			print IMG $_;
            }
		}
	} else {
    	if ( $blank and /^(~{3,})(\s+\{(.*)\})/ ) {
            $depth = length($1);
            my $args = $3;
            if ($args and $args =~ /^\.ditaa(\s+(.*))?/) { # ~~~ {.ditaa <opts>}
#                $2 ||= "";
                my @classes = $2 ? grep /\.[^ ]+/, split(/\s+/, "$2") : ();
                $ditaaopts = join ' ', map { s/^\.//; s/:/ /; "--$_"; } @classes;
	    		$count++;
		    	$file = "image-$count";
    			open (IMG, ">", "$file.ditaa") or die "failed to open $file.ditaa";
            } else {
                $justcode = 1;
            }
		} else {
			$blank = ($_ =~ /^\s*$/);
			print OUT $_;
		}
	}
}
