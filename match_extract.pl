#!/usr/bin/perl -w

#match certain columns of two files and output specified content
#intended for one-to-one correspondence; still working in n-to-1 or 1-to-n scenario, but output non-uniform row length 
#author: Xinwei Han
#input:
#0, the name of file 1 (text)
#1, the column to be matched in file 1 (a number, 0-based)
#2, the separation mark in file 1 ('comma' or 'tab')
#3, which columns to output for file 1 ('all' ,'none' or '-'-delimited numbers, 0-based)
#4, first line to be removed or not in file 1('T' or 'F')
#5, the name of file 2 (text)
#6, the column to be matched in file 2 (a number, 0-based)
#7, the separation mark in file 2 ('comma' or 'tab')
#8, which columns to output for file 2 ('all', 'none' or comma-delimited numbers, 0-based)
#9, first line to be removed or not in file 2('T' or 'F')
#output:
#10, the name of output file (text)

my (%file1,%file2); #certain columns to match => specified content for output
my %matched;

#read file1
open(FILE1, "$ARGV[0]") or die "cannot read $ARGV[0]: $!";
chomp(my @lines1 = <FILE1>);
chomp(my $header1 = shift @lines1) if $ARGV[4] eq 'T'; #store the column info for file1
foreach my $line (@lines1){
    #separation by columns
    my @field; 
    if ($ARGV[2] eq 'comma' ){
        @field = split /,/,$line;
    }elsif($ARGV[2] eq 'tab'){
        @field = split /\t/, $line;
    }else{
        die "unexpected separation mark for file1!\n";
    }
    
    #read related file1 content into memory
    if ($ARGV[3] eq 'all') {
        $file1{$field[$ARGV[1]]} .= "\t$_" foreach @field;
    }elsif($ARGV[3] =~ /\d\-\d/){
        my @output_column = split /\-/,$ARGV[3];
        $file1{$field[$ARGV[1]]} .= "\t$field[$_]" foreach @output_column;
    }elsif($ARGV[3] eq 'none'){
        $file1{$field[$ARGV[1]]} = 'NA';
    }else{
        die  "unexpected output specification for file1!\n";
    } 
}
close FILE1;

#read file2
open(FILE2, "$ARGV[5]") or die "cannot read $ARGV[5]: $!";
chomp(my @lines2 = <FILE2>);
chomp(my $header2 = shift @lines2) if $ARGV[9] eq 'T'; #store the column info for file2
foreach my $line (@lines2){
    #separation by columns
    my @field; 
    if ($ARGV[7] eq 'comma' ){
        @field = split /,/,$line;
    }elsif($ARGV[7] eq 'tab'){
        @field = split /\t/, $line;
    }else{
        die "unexpected separation mark for file2!\n";
    }
    
    #read related file1 content into memory
    if ($ARGV[8] eq 'all') {
        $file2{$field[$ARGV[6]]} .= "\t$_" foreach @field;
    }elsif($ARGV[8] =~ /\d\-\d/){
        my @output_column = split /\-/,$ARGV[8];
        $file2{$field[$ARGV[6]]} .= "\t$field[$_]" foreach @output_column;
    }elsif($ARGV[8] eq 'none'){
        $file2{$field[$ARGV[6]]} = 'NA';
    }else{
        die  "unexpected output specification for file2!\n";
    } 
}
close FILE2;

#match file1 and file2
foreach my $key (keys %file1){
    if ($file2{$key}) {
        $matched{$key} = 1;
    }  
}

#######output#########
open(OUTPUT, ">$ARGV[10]") or die "cannot write to $ARGV[10]: $!";
#output the header info
unless ($ARGV[4] eq 'F' && $ARGV[9] eq 'F') {
    print OUTPUT "match";
    if ($ARGV[4] eq 'T') {
        if ($ARGV[3] eq 'all'){
            print OUTPUT "\t$header1";
        }elsif($ARGV[3] =~ /\d\-\d/){
            my @output_header1 = split /\-/,$ARGV[3];
            
            my @field; 
            if ($ARGV[2] eq 'comma' ){
                @field = split /,/,$header1;
            }elsif($ARGV[2] eq 'tab'){
                @field = split /\t/, $header1;
            }else{
                die "unexpected separation mark for file1!\n";
            }
            
            print OUTPUT "\t$field[$_]" foreach @output_header1;
        }elsif($ARGV[3] eq 'none'){
            print OUTPUT "\tno_output_column_file1";
        }else{
            die  "unexpected output specification for file1!\n";
        }
    }elsif($ARGV[4] eq 'F'){
        print OUTPUT "\tno_columun_name_file1";
    }else{
        die "unexpected indication of first line type for file1!\n"
    }
    
    if ($ARGV[9] eq 'T') {
        if ($ARGV[8] eq 'all'){
            print OUTPUT "\t$header2";
        }elsif($ARGV[8] =~ /\d\-\d/){
            my @output_header2 = split /\-/,$ARGV[8];
            
            my @field; 
            if ($ARGV[7] eq 'comma' ){
                @field = split /,/,$header2;
            }elsif($ARGV[7] eq 'tab'){
                @field = split /\t/, $header2;
            }else{
                die "unexpected separation mark for file2!\n";
            }
            
            print OUTPUT "\t$field[$_]" foreach @output_header2;
        }elsif($ARGV[8] eq 'none'){
            print OUTPUT "\tno_output_column_file2";
        }else{
            die  "unexpected output specification for file2\n";
        }
    }elsif($ARGV[9] eq 'F'){
        print OUTPUT "\tno_columun_name_file2";
    }else{
        die "unexpected indication of first line type for file2!\n"
    }
    
    print OUTPUT "\n";
}
#output the matched entries
foreach my $matchedkey (sort keys %matched){
    print OUTPUT "$matchedkey";
    print OUTPUT "$file1{$matchedkey}" if $file1{$matchedkey} ne 'NA';
    print OUTPUT "$file2{$matchedkey}" if $file2{$matchedkey} ne 'NA';
    print OUTPUT "\n";
}
