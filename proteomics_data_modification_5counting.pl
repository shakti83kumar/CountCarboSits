#!/user/bin/perl
use strict;
use warnings;
my($line, $flag, @lineArray, $protid, $protdesc, %protid_desc);
my(%protidArray, $id, @proteinlines, %modifications, $csvFile);
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
my $outfile = $csvFileArray[0]."_counting."."csv";
open(OUTFILE1, ">$outfile");
##...........................................................
open(INFILE, $csvFile);
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
my($pt, $pt_seq, $pt_modi);
print OUTFILE1 ("#prot_acc\t#prot_desc\t#pep_seq_num\t#pep_var_mod\n");
foreach $id (sort keys(%protidArray))
 {
   my (@ptArray, @pepid_array, @modi_array);
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
         }
    }
   my($elmnt, @uniq_pep, %diferpepid);
   foreach $elmnt (@pepid_array)
     {
        $diferpepid{$elmnt} += 1;
     }
   @uniq_pep = keys(%diferpepid);
##............................................................................
   if(scalar(@pepid_array) == scalar(@uniq_pep))
     {
       my($each_mod, @modi_lists, $modi_lists_elmnt, @modi_lists_elmnt_array, %modificationsHash);
       my($final_mod, @modificationsHashArray);
       %modificationsHash = %modifications;
       foreach $each_mod (@modi_array)
         {
            if($each_mod =~ /\;/g)
              {
                  @modi_lists = split(/\;/, $each_mod);
                  #print("@modi_lists\n");
                  foreach $modi_lists_elmnt (@modi_lists)
                    {
                      $modi_lists_elmnt =~ s/^\s+|\s+$//;
                      @modi_lists_elmnt_array = split(/ /, $modi_lists_elmnt);
                      if($#modi_lists_elmnt_array == 2)
                        {
                           %modificationsHash = &Not_Eql_pepid_modi22(\@modi_lists_elmnt_array, \%modificationsHash);   
                         }
                       if($#modi_lists_elmnt_array == 1)
                         {
                            %modificationsHash = &Not_Eql_pepid_modi21($modi_lists_elmnt, \%modificationsHash);   
                         }
                    } 
              }
            else
              {
                 $modi_lists_elmnt = $each_mod; 
                 $modi_lists_elmnt =~ s/^\s+|\s+$//;
                 @modi_lists_elmnt_array = split(/ /, $modi_lists_elmnt);
                 if($#modi_lists_elmnt_array == 2)
                   {
                      %modificationsHash = &Not_Eql_pepid_modi22(\@modi_lists_elmnt_array, \%modificationsHash);   
                   }
                 if($#modi_lists_elmnt_array == 1)
                   {
                      %modificationsHash = &Not_Eql_pepid_modi21($modi_lists_elmnt, \%modificationsHash);   
                   }
              } 
             
         }
        ##print associative array.....
        print OUTFILE1 ($id,"\t",$protid_desc{$id},"\t",scalar(@uniq_pep),"\t");
        foreach $final_mod (keys %modificationsHash)
          { 
            if($modificationsHash{$final_mod} == 0)
              {
                 next;
              } 
            else
              {
                 push (@modificationsHashArray, $modificationsHash{$final_mod}." ".$final_mod);
              }
          }
        print OUTFILE1 (join(";", @modificationsHashArray), "\n");    
        unlink(@modi_lists_elmnt_array);
        unlink(%modificationsHash);
        unlink(@modificationsHashArray);          
     }
   else
    {
       die("\nERROR!!!!!!!!!!\nthere are repeated peptides in input file\n\n");
    }
   unlink(@ptArray);
   unlink(@pepid_array);
   unlink(@modi_array);         
  }
unlink(@lineArray);
unlink(%protid_desc);
unlink(%protidArray);
unlink(@proteinlines);
unlink(%modifications);
unlink(%protid_desc);
##..............Not_Eql_pepid_modi22 subrutine.........................................
sub Not_Eql_pepid_modi22
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
             $mod_2_Hash{$key_modi} =  $mod_2_Hash{$key_modi} + $mod_num2;
         }
     }
   return(%mod_2_Hash);
   unlink(@array2);
   unlink(%mod_2_Hash);   
 }
##................Not_Eql_pepid_modi21 subrutine.......................................
sub Not_Eql_pepid_modi21
 {
    my($ary2, $mod) = @_;
    my(%mod_2_Hash, $key_modi);
    %mod_2_Hash  = %{$mod};
    $ary2 =~ s/^\s+|\s+$//;
    #print($ary2, "\n");
    foreach $key_modi (keys %mod_2_Hash)
     {
        if($ary2 eq $key_modi)
          {
             print($ary2, "\n");
             $mod_2_Hash{$key_modi} =  $mod_2_Hash{$key_modi} + 1;
          }
     }
   return(%mod_2_Hash);
   unlink(%mod_2_Hash);   
 }

