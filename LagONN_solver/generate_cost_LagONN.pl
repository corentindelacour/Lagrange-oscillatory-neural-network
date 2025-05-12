#!/usr/bin/perl
use warnings;
# This script writes the LagONN lagrangian function given a cnf 3-SAT formula

#input file defining the cnf instance
our @L=<>;
#print(@L);

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

#Creating the sym Matlab command
our $instance_num=0;

push @netlist,"\n";
push @netlist,"sym cost";

#Mapping each clause to a local cost function
push @netlist, "\n cost=";
for my $c (@L[$index..$N_clause+$index-1])
{
    #print($c);
	++$instance_num;
	#print("$c\n");
	#my $N_minus=()=$c=~/\Q-/g; #counting the number of - to get the number of negative literals
	my $N_minus=0;

	#0=AVBVC; 1=AbVBVC; 2=AbVBbVC; 3=AbVBbVCb
	#if ($instance_num>1){
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
    else {

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
	push @netlist,"+0.5*(1-tanh(beta*cos(X$pos_terms[0])))*0.5*(1-tanh(beta*cos(X$pos_terms[1])))*0.5*(1-tanh(beta*cos(X$pos_terms[2])))";
	}
	if ($N_minus==1){
    push @netlist,"+0.5*(1+tanh(beta*cos(X$neg_terms[0])))*0.5*(1-tanh(beta*cos(X$pos_terms[0])))*0.5*(1-tanh(beta*cos(X$pos_terms[1])))";
	}
	if ($N_minus==2){
	push @netlist,"+0.5*(1+tanh(beta*cos(X$neg_terms[0])))*0.5*(1+tanh(beta*cos(X$neg_terms[1])))*0.5*(1-tanh(beta*cos(X$pos_terms[0])))";
    }
	if ($N_minus==3){
    push @netlist,"+0.5*(1+tanh(beta*cos(X$neg_terms[0])))*0.5*(1+tanh(beta*cos(X$neg_terms[1])))*0.5*(1+tanh(beta*cos(X$neg_terms[2])))";
	}
}




print(@netlist);
