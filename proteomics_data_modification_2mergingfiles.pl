#!usr/bin/perl -w
use strict;
#reading input files by arguments
my $inFolder = $ARGV[0];
my @fileArray;
my $folderName = &Strip($inFolder);
opendir (DIR, './'.$folderName) or die "Couldn't open directory\n";
while (my $file = readdir DIR) 
 {
   next if($file =~ /^\.+/);
   #print "$file\n";
   push(@fileArray, $file);
 }
##### fining the headerlines in all files
my %headerlines;
my $line;
foreach my $fileName (@fileArray)
 {
   my $fileNamePath = './'.$folderName.'/'.$fileName;
   print ($fileNamePath, "\n");
   open(INFILE, $fileNamePath)or die "Couldn't open $fileNamePath\n";
   while($line = <INFILE>)
     {
        if($line !~ /^\s+/)
          {
             if($line =~ /^prot_hit_num/)
               {
                 $headerlines{$line} += 1;
               }
          } 
     }
   close(INFILE)
 }
my $outFileName = $folderName.'_mergedfiles.csv';
open(OUTFILE, ">$outFileName")or die "Couldn't open $outFileName\n";
my @header = keys(%headerlines);
if($#header == 0)
 {
    print OUTFILE ($header[$#header]);
 }
elsif($#header < 0)
 {
    die("\n\nERROR!!!!!!!!!!!\nNo header line in files\n\n");
 }
else
 {
   die("\n\nERROR!!!!!!!!!!!\n there are two are more that two header lines in files\n\n"); 
 }
foreach my $fileName (@fileArray)
 {
   my $fileNamePath = './'.$folderName.'/'.$fileName;
   open(INFILE, $fileNamePath)or die "Couldn't open $fileNamePath\n";
   while($line = <INFILE>)
     {
        if(($line !~ /^\s+/)&&($line !~ /^prot_hit_num/))
          {
             print OUTFILE ($line);
          } 
     }
   close(INFILE);
 }
undef(@ARGV);
undef(@fileArray);
undef(%headerlines);
undef(@header);
unlink(@ARGV);
unlink(@fileArray);
unlink(%headerlines);
unlink(@header);
###........Removing either spaces or newline characters........................
sub Strip
 {
    my $stripVal = shift;
    $stripVal =~ s/^\s+|\s+$//;
    return($stripVal);
 }
