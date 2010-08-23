#!/usr/bin/perl -w

use strict;
use Spreadsheet::ParseExcel;

my $oExcel = new Spreadsheet::ParseExcel;

die "You must provide a filename to $0 to be parsed as an Excel file" unless @ARGV;

my $oBook = $oExcel->Parse($ARGV[0]);
my($iR, $iC, $oWkS, $oWkC);
print "FILE  :", $oBook->{File} , "\n";
print "COUNT :", $oBook->{SheetCount} , "\n";

for(my $iSheet=0; $iSheet < $oBook->{SheetCount} ; $iSheet++)
{
 $oWkS = $oBook->{Worksheet}[$iSheet];
 print "--------- SHEET:", $oWkS->{Name}, "\n";
 open FILE, ">", "$oWkS->{Name}.csv" or die $!;
 for(my $iR = $oWkS->{MinRow} ; defined $oWkS->{MaxRow} && $iR <= $oWkS->{MaxRow} ; $iR++)
 {
  for(my $iC = $oWkS->{MinCol} ; defined $oWkS->{MaxCol} && $iC <= $oWkS->{MaxCol} ; $iC++)
  {
   $oWkC = $oWkS->get_cell($iR,$iC);
   print  FILE $oWkC->value()  if($oWkC);
   if($iC < $oWkS->{MaxCol})
   {
   print FILE ",";
   }
  }
  print FILE "\n";
 }
 close FILE;
}
