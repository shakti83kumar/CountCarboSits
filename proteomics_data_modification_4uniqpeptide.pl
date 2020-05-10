#!/user/bin/perl
use strict;
use warnings;
my($line, $flag, @lineArray, $protid, $protdesc, %protid_desc);
my(%protidArray, @proteinlines, %modifications, $csvFile);
###..................................
%modifications = 
   (
      "Argbiotinhydrazide (R)" => 0,
      "Lysbiotinhydrazide (K)" => 0,
      "probiotinhydrazide (P)" => 0,
      "Thrbiotinhydrazide (T)" => 0,
   );
$csvFile = $ARGV[0];
$flag = 0;
my @csvFileArray = split(/\./, $csvFile);
my $outfile = $csvFileArray[0]."_peptide."."csv";
open(INFILE, $csvFile);
open(OUTFILE1, ">$outfile");
while($line = <INFILE>)
 {
    if(($line !~ /^\s+/)&&($line !~ /^\#/))
      {
        push(@proteinlines, $line);
        @lineArray = split(/\t/, $line);
        $protid = $lineArray[0];
        $protid =~ s/^\s+|\s+$//;
        $protdesc = $lineArray[1];
        $protdesc =~ s/^\s+|\s+$//;
        $protidArray{$protid} += 1;
        $protid_desc{$protid} = $protdesc;        
      }
 }
############################################################
my($pt, $pt_seq, $pt_modi, $key, $id);
print OUTFILE1 ("#prot_acc\t#prot_desc\t#pep_seq\t#pep_var_mod\n");
foreach $id (sort keys(%protidArray))
 {
#  print OUTFILE1 $id,"\t",$protidArray{$id},"\n";
   my %pt_seq_modi;
   my @ptArray;
   my(@pepid_array, @modi_array, %diferpepid, $elmnt, @uniq_pep);
   foreach $pt (@proteinlines)
    {
       if($pt =~ /$id/g)
         {
            @ptArray =  split(/\t/, $pt);
            $pt_seq =   $ptArray[2];
            $pt_seq =~  s/^\s+|\s+$//;
            $pt_modi =  $ptArray[3];
            $pt_modi =~ s/^\s+|\s+$//;
            push(@pepid_array, $pt_seq);
            push(@modi_array, $pt_modi);
            #$pt_seq_modi{$pt_modi} = $pt_seq;
         }
    }
   foreach $elmnt (@pepid_array)
     {
        $diferpepid{$elmnt} += 1;
     }
   @uniq_pep = keys(%diferpepid);
##............................................................................
   if((scalar(@pepid_array) == 1)&&(scalar(@uniq_pep) == 1))
     {
       print OUTFILE1 ("$id\t$protid_desc{$id}\t$pepid_array[$#pepid_array]\t$modi_array[$#modi_array]\n");
     }
##............................................................................
   if((scalar(@pepid_array) > 1)&&(scalar(@uniq_pep) < scalar(@pepid_array)))
     {
       my (@same_pep_modi, $pep_modi, %modificationsHash, $final_mod, @modificationsHashArray);
       foreach my $uniq_pept (@uniq_pep) 
          {
            %modificationsHash = %modifications;
            for(my $i = 0; $i<=$#pepid_array; $i++)
              {
                 if($pepid_array[$i] eq $uniq_pept)
                   {
                      #print ($pepid_array[$i], "\t", $uniq_pept, "\n");
                      push(@same_pep_modi, $modi_array[$i]);
                   }
              }
            #print("$uniq_pept\t @same_pep_modi\n");
            my (@modi_lists, $modi_lists_elmnt, @modi_lists_elmnt_array);
            foreach $pep_modi (@same_pep_modi)
              {
                #print("$uniq_pept\t$pep_modi\n");
                if($pep_modi =~ /\;/g)
                  {
                     @modi_lists = split(/\;/, $pep_modi);
                     #print("@modi_lists\n");
                     foreach $modi_lists_elmnt (@modi_lists)
                       {
                         $modi_lists_elmnt =~ s/^\s+|\s+$//;
                         @modi_lists_elmnt_array = split(/ /, $modi_lists_elmnt);
                         if($#modi_lists_elmnt_array == 2)
                           {
                              %modificationsHash = &Eql_pepid_and_eql_modi22(\@modi_lists_elmnt_array, \%modificationsHash);   
                           }
                         if($#modi_lists_elmnt_array == 1)
                           {
                              %modificationsHash = &Eql_pepid_and_eql_modi21($modi_lists_elmnt, \%modificationsHash);   
                           }
                       } 
                  }
                else
                  {
                     $modi_lists_elmnt = $pep_modi; 
                     $modi_lists_elmnt =~ s/^\s+|\s+$//;
                     @modi_lists_elmnt_array = split(/ /, $modi_lists_elmnt);
                     if($#modi_lists_elmnt_array == 2)
                        {
                          %modificationsHash = &Eql_pepid_and_eql_modi22(\@modi_lists_elmnt_array, \%modificationsHash);   
                        }
                     if($#modi_lists_elmnt_array == 1)
                        {
                          %modificationsHash = &Eql_pepid_and_eql_modi21($modi_lists_elmnt, \%modificationsHash);   
                        }
                  }
               @modi_lists = ();
               @modi_lists_elmnt_array = ();
              }
              unlink(@modi_lists);
              unlink(@modi_lists_elmnt_array);
              print OUTFILE1 ($id,"\t",$protid_desc{$id},"\t",$uniq_pept,"\t");
              foreach $final_mod (keys %modificationsHash)
                 { 
                   if($modificationsHash{$final_mod} == 0)
                     {
                       next;
                     } 
                   else
                     {
                       #print ($modificationsHash{$final_mod}." ".$final_mod,";");
                       push (@modificationsHashArray, $modificationsHash{$final_mod}." ".$final_mod);
                     }
                 }
               print OUTFILE1 (join(";", @modificationsHashArray), "\n"); 
               @modificationsHashArray = ();
               @same_pep_modi = ();       
          }
      unlink(@modificationsHashArray);
      unlink(%modificationsHash);
      unlink(@same_pep_modi); 
     }
##....................................................................................................
   if((scalar(@pepid_array) > 1)&&(scalar(@uniq_pep) == scalar(@pepid_array)))
     { 
        my($i);
        for($i = 0; $i <= $#pepid_array; $i++)
         { 
           print OUTFILE1 ("$id\t$protid_desc{$id}\t$pepid_array[$i]\t$modi_array[$i]\n");
         }
     }
  @pepid_array = ();
  @modi_array = ();
  unlink(%diferpepid);
  unlink(@uniq_pep);
  unlink(%pt_seq_modi);
  unlink(@ptArray);
  unlink(@pepid_array);
  unlink(@modi_array);
 }
unlink(@lineArray);
unlink(%protid_desc);
unlink(%protidArray);
unlink(@proteinlines);
unlink(%modifications);
##.............Eql_pepid_and_eql_modi22 subrutine.........................................
sub Eql_pepid_and_eql_modi22
  {
    my($ary2, $mod) = @_;
    my(@array2, %mod_2_Hash, $mod_num2, $mod_type, $key_modi);
    @array2 = @{$ary2};
    %mod_2_Hash  = %{$mod};
    #print(@array2, "\n");
    $mod_num2 = $array2[0];
    $mod_num2 =~ s/^\s+|\s+$//;
    #print(@array2[1, $#array2],"\n");
    $mod_type = join(" ", @array2[1..$#array2]); 
    foreach $key_modi (keys %mod_2_Hash)
     {
        if($mod_type eq $key_modi)
          {
            if($mod_2_Hash{$key_modi} < $mod_num2)
              {
                 #print ("Eql_pepid_and_eql_modi22:\t$mod_2_Hash{$key_modi}\t$mod_num2\n");
                 $mod_2_Hash{$key_modi} = $mod_num2;
              }
          }
     }
   return(%mod_2_Hash);
   unlink(@array2);
   unlink(%mod_2_Hash);                                
  }
##..............Eql_pepid_and_eql_modi21 subrutine.....................................
sub Eql_pepid_and_eql_modi21
 {
   my($arr1, $mod) = @_;
   my($key_modi, %mod_1_Hash );
   %mod_1_Hash = %{$mod};
   $arr1 =~ s/^\s+|\s+$//;
   foreach $key_modi (keys %mod_1_Hash)
     {
        if($arr1 eq $key_modi)
          {
            if($mod_1_Hash{$key_modi} > 1)
              {
                 #print ("Eql_pepid_and_eql_modi21:\t$mod_1_Hash{$key_modi}\n");
                 next;
              }
            else
              {
                 $mod_1_Hash{$key_modi} = 1;
              }
          }
     }
  return(%mod_1_Hash);
  unlink(%mod_1_Hash);
 }

