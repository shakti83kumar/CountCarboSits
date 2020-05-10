#!/user/bin/perl
use strict;
use warnings;
my($line, $flag, @lineArray, $protid);
my(%protidArray, $id, @proteinlines, $protdesc, %protid_desc);
my $csvFile = $ARGV[0];
my @csvFileArray = split(/\./, $csvFile);
my $outfile = $csvFileArray[0]."_uniq."."csv";
$flag = 0;
open(OUTFILE, ">$outfile")||die("\nERROR!!!!!!!!\nCould not open $outfile\n");
open(INFILE, $csvFile)||die("\nERROR!!!!!!!!\nCould not open $csvFile\n");;
while($line = <INFILE>)
 {
    if($line !~ /^\s+/)
      {
         if($line =~ /^prot_hit_num/)
          {
            #print OUTFILE $line;
            $flag = 1;
            next;
          }
         if($flag == 0)
          {
            #print OUTFILE $line;
          }
         else
          { 
            push(@proteinlines, $line);
            @lineArray = &parse_csv($line); #parsing csv file by parse_csv subrutine  
            $protid = $lineArray[1];
            $protid =~ s/^\s+|\s+$//;
            $protid =~ s/\"//g;
            $protdesc = $lineArray[2];
            $protdesc =~ s/^\s+|\s+$//;
            $protdesc =~ s/\"//g;
            $protidArray{$protid} += 1; 
            $protid_desc{$protid}  = $protdesc;      
          }
      }
 }
#print(@proteinlines);
my($pt, @ptArray, $pt_seq, $pt_modi);
my($key);
print OUTFILE ("#prot_acc\t#prot_desc\t#pep_seq\t#pep_var_mod\n");
foreach $id (sort keys(%protidArray))
 {
   #print $id, "\n";
   my %pt_seq_modi;
   my @subpart;
   my $pep_seq_modi;
   my @key_array;
   foreach $pt (@proteinlines)
    {
       if($pt =~ /$id/g)
         {
            @ptArray = &parse_csv($pt); #parsing csv file by parse_csv subrutine  
            $pt_seq = $ptArray[22];
            $pt_seq =~ s/^\s+|\s+$//;
            $pt_seq =~ s/\"//g;
            $pt_modi = $ptArray[24];
            $pt_modi =~ s/^\s+|\s+$//;
            $pt_modi =~ s/\"//g;
            #print ($pt_seq, "\t", "$pt_modi", "\n");
            $pep_seq_modi = $id."\t".$pt_seq."\t".$pt_modi;
            $pt_seq_modi{$pep_seq_modi} += 1;
            push(@subpart, $pt);
         }
    }
   foreach $key (keys %pt_seq_modi)
     {
        #print $key,"\t",$pt_seq_modi{$key},"\n"; 
        @key_array = split(/\t/, $key);
        print OUTFILE ($id,"\t",$protid_desc{$id},"\t",$key_array[1],"\t",$key_array[2],"\n");
     }
   undef(@subpart);
   undef(%pt_seq_modi);
   undef(@key_array);
   unlink(@subpart);
   unlink(%pt_seq_modi);
   unlink(@key_array);
 }
close(INFILE);
close(OUTFILE); 
undef(%protidArray);
undef(@proteinlines);
undef(@lineArray);
unlink(%protidArray);
unlink(@proteinlines);
unlink(@lineArray);
###.................parsing csv file subrutine.................................
sub parse_csv 
  {
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
       return @new;
       undef(@new);
       unlink(@new); 
  }
  




