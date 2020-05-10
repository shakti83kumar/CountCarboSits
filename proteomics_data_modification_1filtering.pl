#!/user/bin/perl
use strict;
use warnings;
###...................................................................
my %modifications = 
   (
      "Argbiotinhydrazide" => 0,
      "Lysbiotinhydrazide" => 0,
      "probiotinhydrazide" => 0,
      "Thrbiotinhydrazide" => 0,
   );
###...................................................................
my @modifications_array = keys(%modifications);
my $modification_line = join("|", @modifications_array);
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
my $outFolder =  $folderName."_filtered";
mkdir($outFolder, 0755);
foreach my $csvFile (@fileArray)
 {
    my @csvFileArray = split(/\./, $csvFile);
    $csvFile = './'.$folderName.'/'.$csvFile;
    print($csvFile, "\n");
    my $outfile = './'.$outFolder.'/'.$csvFileArray[0].'_filtered.csv';
    my $flag = 0;
    #print($modification_line, "\n");
    open(OUTFILE, ">$outfile");
    open(INFILE, $csvFile);
    while(my $line = <INFILE>)
         {
            if($line !~ /^\s+/)
              {
                 if($line =~ /^prot_hit_num/) ## pattern to select peptide hit afterwards. User can change as 
                   {                           ## per his/her convenients.
                      print OUTFILE $line;
                      $flag = 1;
                      next;
                   }
                 if($flag == 0)
                   {
                      #print OUTFILE $line;
                   }
                 else
                   {
                      $line = &Strip($line);
                      my @fields = &parse_csv($line); #parsing csv file by parse_csv subrutine  
                      if($fields[24]=~ /$modification_line/)
                        {
                            print OUTFILE ($line, "\n");
                        }
                   }
              }
         }
         close(OUTFILE);
         close(INFILE);
         undef(@csvFileArray);
         unlink(@csvFileArray);
 }
undef(%modifications);
undef(@modifications_array);
undef(@fileArray);
unlink(%modifications);
unlink(@modifications_array);
unlink(@fileArray);
closedir(DIR);
###.................parsing csv file subrutine.................................
sub parse_csv {
    my $text = shift;      # record containing comma-separated values
    my @new  = ();
    push(@new, $+) while $text =~ m{
        # the first part groups the phrase inside the quotes.
        # see explanation of this pattern in MRE
        "([^\"\\]*(?:\\.[^\"\\]*)*)",?
           |  ([^,]+),?
           | ,
       }gx;
       push(@new, undef) if substr($text, -1,1) eq ',';
       return @new;      # list of values that were comma-separated
       unlink(@new);
}
###........Removing either spaces or newline characters........................
sub Strip
 {
    my $stripVal = shift;
    $stripVal =~ s/^\s+|\s+$//;
    return($stripVal);
 }
