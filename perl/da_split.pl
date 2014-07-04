#!/usr/bin/env perl
# use: perl script.pl -i G:\Pictures\deviantArt -s -l 25

use 5.010;
use warnings;
use strict;

use File::Copy;
use File::Path qw{make_path};
use File::Spec::Functions;
use Getopt::Std;
use Path::Class;

my %options = ();
unless (getopts("i:o:l:s", \%options)) {
    print "Arguments unrecognized.\n";
    exit;
}

my $source = defined $options{i} ? $options{i} : ".";
unless (-e $source) {
    print "Source '$source' does not exist.\n";
    exit;
}

my $workingDirectory;

if (-d $source) {
    $workingDirectory = $source;
} elsif (-f $source) {
    $workingDirectory = file($source)->dir->absolute;
} else {
    print "'$source' is not even a valid source.\n";
    exit;
}

my $outputDirectory = defined $options{o} ? file($options{o})->absolute : $workingDirectory;

unless (-d -e $workingDirectory && -d -e $outputDirectory) {
    print "Working Directory is not a valid directory: $workingDirectory\n";
    print "Output Directory is not a valid directory: $outputDirectory\n";
    exit;
}

print "Source: $source\n" if defined $options{s};
print "Working Directory: $workingDirectory\n" if defined $options{s};
print "Output Directory: $outputDirectory\n" if defined $options{s};
print "\n" if defined $options{s};

my $workingDir = dir($workingDirectory);
my $outputDir = dir($outputDirectory);
my $counter = 0;
my $skiped = 0;

while (my $file = $workingDir->next) {
    next if $file eq $workingDir->parent || $file eq $workingDirectory;

    my $startPos = rindex $file->basename, "_by_";
    $startPos = $startPos >= 0 ? $startPos : rindex $file->basename, " by ";
    unless ($startPos >= 0) {
        $skiped++;
        print $file->basename . "skiped\n" if defined $options{s};
        next;
    }
    $startPos += 4;

    my $daUser = substr $file->basename, $startPos;

    unless ($file->is_dir()) {
        my $endPos = rindex $daUser, "-";
        $endPos = $endPos >= 0 ? $endPos : rindex $daUser, ".";
        unless ($endPos >= 0) {
            $skiped++;
            print $file->basename . " skiped\n" if defined $options{s};
            next;
        }
        $daUser = substr $daUser, 0, $endPos;
    }

    my $daUserDirectory = catfile $outputDirectory, $daUser;

    unless (-e -d $daUserDirectory) {
        make_path($daUserDirectory, {
            verbose => defined $options{s} ? 1 : 0
        });
    }

    my $newLocation = catfile $daUserDirectory, $file->basename;

    if (-e $newLocation) {
        print $file->basename . " file already exists in '$daUser' folder.\n" if defined $options{s};
        $skiped++;
        next;
    }

    move $file, $newLocation;
    print $file->basename . " -> $daUser\n" if defined $options{s};

    $counter ++;
    last if defined $options{l} && $counter >= $options{l};
}

print "    $counter element(s) moved.\n";
print "    $skiped element(s) skiped.\n";