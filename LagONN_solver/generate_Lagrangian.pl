#!/usr/bin/perl
use warnings;
# This script writes the LagONN lagrangian function given a cnf 3-SAT formula

#input file defining the cnf instance
our @L=<>;
=our @L=$ARGV[0];
our $N_var=$ARGV[1];
our $N_clause=$ARGV[2];
=cut

#extracting number of variables and clauses

our $index=0;
my $first_letter='c';
while($first_letter eq 'c'){
	my $line=$L[$index];
   	my @letters= split //, $line;

	$first_letter=$letters[0];
	++$index;
}
my $prev_line=$L[$index-1];
my @letters= split / /, $prev_line;
my $N_var=$letters[2];
my $N_clause=$letters[4];


push @netlist,"N=$N_var;M=$N_clause;\n";

push @netlist, "syms X [1 $N_var]; syms L [1 $N_clause]; \n";

#Creating the sym Matlab command
our $instance_num=0;

push @netlist,"\n";
push @netlist,"sym Lag";
#{
#my @index_list=(1..$N_var);
#for my $i (@index_list){
#	push @netlist," X$i";
#}
#}

#{
#my @index_list=(1..$N_clause);
#for my $i (@index_list){
#	push @netlist," L$i";
#}
#}


#Mapping each clause to a local Lagrangian function
push @netlist, "\n Lag=";
for my $c (@L[$index..$N_clause+$index-1])
{
    #print($c);
	++$instance_num;
	#print("$c\n");
	#my $N_minus=()=$c=~/\Q-/g; #counting the number of - to get the number of negative literals
	my $N_minus=0;

	#0=AVBVC; 1=AbVBVC; 2=AbVBbVC; 3=AbVBbVCb
	
	my @operand=split / /, $c;
	my @neg_terms=();
	my @pos_terms=();

	if ($instance_num>1){

	if ($operand[0]<0){
	++$N_minus;
	push @neg_terms, @{[-$operand[0]]};
	}else{
	push @pos_terms, @{[$operand[0]]};
	}

	if ($operand[1]<0){
	++$N_minus;
	push @neg_terms, @{[-$operand[1]]};
	}else{
	push @pos_terms, @{[$operand[1]]};
	}

	if ($operand[2]<0){
	++$N_minus;
	push @neg_terms, @{[-$operand[2]]};
	}else{
	push @pos_terms, @{[$operand[2]]};
	}
	}
	else { # due to additional space in cnf files
	#print("$operand[1]\n");
	#print("$operand[2]\n");
	#print("$operand[3]\n");
	
	if ($operand[1]<0){
	++$N_minus;
	push @neg_terms, @{[-$operand[1]]};
	}else{
	push @pos_terms, @{[$operand[1]]};
	}

	if ($operand[2]<0){
	++$N_minus;
	push @neg_terms, @{[-$operand[2]]};
	}else{
	push @pos_terms, @{[$operand[2]]};
	}

	if ($operand[3]<0){
	++$N_minus;
	push @neg_terms, @{[-$operand[3]]};
	}else{
	push @pos_terms, @{[$operand[3]]};

	}
	}

	if ($N_minus==0){
	push @netlist,"+cos(L$instance_num)-cos(X$pos_terms[0]-L$instance_num)-cos(X$pos_terms[1]-L$instance_num)-cos(X$pos_terms[2]-L$instance_num)+cos(X$pos_terms[0]-X$pos_terms[1]-L$instance_num)+cos(X$pos_terms[0]-X$pos_terms[2]-L$instance_num)+cos(X$pos_terms[2]-X$pos_terms[1]-L$instance_num)-cos(X$pos_terms[0]-X$pos_terms[1]+X$pos_terms[2]-L$instance_num)";
	}
	if ($N_minus==1){
    push @netlist,"+cos(L$instance_num)+cos(X$neg_terms[0]-L$instance_num)-cos(X$pos_terms[0]-L$instance_num)-cos(X$pos_terms[1]-L$instance_num)-cos(X$neg_terms[0]-X$pos_terms[0]-L$instance_num)-cos(X$neg_terms[0]-X$pos_terms[1]-L$instance_num)+cos(X$pos_terms[1]-X$pos_terms[0]-L$instance_num)+cos(X$neg_terms[0]-X$pos_terms[0]+X$pos_terms[1]-L$instance_num)";
	}
	if ($N_minus==2){
	push @netlist,"+cos(L$instance_num)+cos(X$neg_terms[0]-L$instance_num)+cos(X$neg_terms[1]-L$instance_num)-cos(X$pos_terms[0]-L$instance_num)+cos(X$neg_terms[0]-X$neg_terms[1]-L$instance_num)-cos(X$neg_terms[0]-X$pos_terms[0]-L$instance_num)-cos(X$pos_terms[0]-X$neg_terms[1]-L$instance_num)-cos(X$neg_terms[0]-X$neg_terms[1]+X$pos_terms[0]-L$instance_num)";
    }
	if ($N_minus==3){
    push @netlist,"+cos(L$instance_num)+cos(X$neg_terms[0]-L$instance_num)+cos(X$neg_terms[1]-L$instance_num)+cos(X$neg_terms[2]-L$instance_num)+cos(X$neg_terms[0]-X$neg_terms[1]-L$instance_num)+cos(X$neg_terms[0]-X$neg_terms[2]-L$instance_num)+cos(X$neg_terms[2]-X$neg_terms[1]-L$instance_num)+cos(X$neg_terms[0]-X$neg_terms[1]+X$neg_terms[2]-L$instance_num)";
	}
	

}

print(@netlist);
