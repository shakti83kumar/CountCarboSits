#!/usr/bin/perl -w
use strict;
my $file;
my %fileHashArray;
my @fileArray;
my $fileName;
my @inputs = @ARGV;
if($#inputs < 0)
 {
   die("\n\nERROR!!!!!!!!\n you have not entered folder Name and having file.\n\n");
 }
my $folderName = $inputs[0];
my $protfile = $inputs[1];
$folderName =~ s/^\s+|\s+$//;
$protfile =~ s/^\s+|\s+$//;
opendir (DIR, './'.$folderName) or die "Couldn't open directory\n";
while ($file = readdir DIR) 
 {
   next if($file =~ /^\.+/);
   #print "$file\n";
   @fileArray = split(/\_/, $file);
   $fileHashArray{$fileArray[0]} = $file;
 }
foreach $fileName (sort(keys %fileHashArray))
 {
   print $fileName,"\t",$fileHashArray{$fileName},"\n";
 }

# Get a city name from the user  
print "\nEnter the nonrepeated sample with corresponding repeated sample by adding '+' symbol.
For example: F009347STR16+F009348STR16R 
             F009368STR37+F009369STR37R 
             ............+.............
             ............+.............\n"; 
print "\n<Ctrl>+D to Terminate Entering Sample Name for Merging\n"; 
my @Rsamples = <STDIN>; 
my @toDelSample;
my $toDelElmnt;
foreach my $eachRsample (@Rsamples)
  {
     $eachRsample =~ s/^\s+|\s+$//;
     my @eachRsampleArray = split(/\+/, $eachRsample);
     my @SampleMerging;
     my $SampleMergedLine;
     for(my $i = 0; $i<=$#eachRsampleArray; $i++)
       {
           push(@SampleMerging, $fileHashArray{$eachRsampleArray[$i]}); 
       }
     $SampleMergedLine = join('+', @SampleMerging);
     $fileHashArray{$eachRsample} = $SampleMergedLine;
     push(@toDelSample, @eachRsampleArray);
     #print ($SampleMergedLine, "\n");
     #print ($eachRsampleArray[0], "\n");
     undef(@SampleMerging);
     #print "\nCities visited by you are: \n$Rsamples[0]\n"; 
  }
foreach $toDelElmnt (@toDelSample)
 {
    delete($fileHashArray{$toDelElmnt});
 }
my @totfile = keys(%fileHashArray);
my $totalfile = @totfile;
my @protfileArray = split(/\./, $protfile);
my $outfile = $protfileArray[0].'_sample.csv';
open(INFILE, $protfile);
open(OUTFILE, ">$outfile");
while (my $line = <INFILE>)
  {
     $line =~ s/^\s+|\s+$//;
     if($line !~ /^\s+/)
       {
          if($line =~ /^\#/)
            {
               print OUTFILE ($line."\t"."#Sample_Number". "\t"."#Sample_Name"."\n");
            }
          else
            {   
               my @lineArray = split(/\t/, $line);
               my $protid = $lineArray[0];
               my $count = 0;
               my @sampleArray;
               my @protidArray;
               my $ct;
               my $eachFilePath;
               my $fileName;             
               foreach $fileName (sort(keys %fileHashArray))
                 {   
                     if($fileName =~ /\+/g)
                       {
                          my @combineProtidArray;
                          my @fileNameArray = split(/\+/, $fileHashArray{$fileName});
                          foreach my $eachFile (@fileNameArray)
                             {
                                  $eachFilePath = './'.$folderName.'/'.$eachFile;
                                  @protidArray = &FileOpen($eachFilePath);
                                  push(@combineProtidArray, @protidArray);
                             }
                          $ct = &MatchingProt($protid, \@combineProtidArray);
                          print ("+","\t",$protid,"\t",$ct,"\n");
                          if($ct == 1)
                            {
                               push(@sampleArray, $fileName);
                               $count = $count + 1;
                            }
                          undef(@combineProtidArray); 
                          undef(@fileNameArray); 
                       }
                     else
                       {
                         $eachFilePath = './'.$folderName.'/'.$fileHashArray{$fileName};
                         @protidArray = &FileOpen($eachFilePath);
                         $ct = &MatchingProt($protid, \@protidArray);
                         print ("-","\t",$protid,"\t",$ct,"\n");
                         if($ct == 1)
                           {
                              push(@sampleArray, $fileName);
                              $count = $count + 1;
                           }
                       }
                 }
             print OUTFILE $line."\t".$count."/$totalfile"."\t".join(';', @sampleArray)."\n";
             undef(@sampleArray);
             undef(@lineArray); 
             undef(@protidArray);           
            }
       }

  }
undef(@totfile);
undef(@protfileArray);
undef(@toDelSample);
undef(@fileArray);
unlink(%fileHashArray);
unlink(@fileArray);
unlink(@totfile);
unlink(@protfileArray);
closedir DIR;
close(INFILE);
close(OUTFILE);
###....................opening file and making array..........
sub FileOpen
 {
    my $File = shift;
    my @lineArray1;
    #print($File, "\n");
    open(INFILE1, $File)||die("Couldn't open file: $File\n");
    while(my $line1 = <INFILE1>)
       {
         push(@lineArray1, $line1);
       }
    return(@lineArray1); 
    undef(@lineArray1);
    close(INFILE1);
 }
###...............Matching protein Id.........................
sub MatchingProt
 {
    my($id, $Array) = @_;
    my @Arry = @{$Array}; 
    my $flag = 0; 
    #print("$id\n");
    foreach my $ln (@Arry) 
      {
         if($ln =~ /$id/g)
           {
             $flag = 1;
             last;
           }   
      }
   return($flag);
   undef(@Arry);
 }        

                       
                    

