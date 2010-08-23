#!/usr/bin/perl -w
=pod

create following table in the db

CREATE TABLE db_versions(
    PATCH_ID integer( 11 ) NOT NULL AUTO_INCREMENT PRIMARY KEY ,
    PATCH_NAME varchar( 56 ) NOT NULL ,
    PATCH_TIMESTAMP timestamp
) ENGINE = InnoDB,CHARSET = utf8;


Errors are not handled only where required 

=cut

use strict;
use Getopt::Long;
use DBI;
use File::Basename;

my $patchname="";

my $user;
my $password="";
my $dbname;
my $hostname="localhost";
my $isforced=0;
 
my $result=GetOptions(
		"patch=s" =>\$patchname,
		"user=s"=> \$user,
		"password=s" => \$password,
		"db=s" => \$dbname,
		"host=s" => \$hostname,
		"force" => sub {$isforced=1},
		"help" => sub {printhelp();exit(0);}
	);

sub printhelp(){
    print qq {$0 -u <db_username>  -d <db_name> --patch <patch_file_name> [ --password <db_password> -h <db_shotname>  --force|-f ]\n};
}

sub checkArgs(){
	if(!(defined $patchname && defined $user && defined $dbname)){
		printhelp();
		exit(0);
	} 
}


#main
checkArgs();
my $dsn="dbi:mysql:$dbname:$hostname";
my $DB = DBI->connect($dsn,$user,$password)
    or die "Connecting from perl to MySQL database failed: $DBI::errstr";

my $patch_id=basename($patchname);
my $checkIfAlreadyApplied="select * from db_versions where PATCH_NAME='$patch_id'";
my $qh=$DB->prepare($checkIfAlreadyApplied);
my $res=$qh->execute();
if($res==0 || $isforced ){
	my $insertq="insert into db_versions(PATCH_NAME,PATCH_TIMESTAMP) values('$patch_id',CURRENT_TIMESTAMP)";
        my $iqh=$DB->prepare($insertq);	
	my $res=$iqh->execute();
        $iqh->finish;	

	my $applypatch = qq { mysql -u $user -p$password -h $hostname $dbname  < $patchname };
	print `$applypatch`  	
} else {
	print "Patch is already applied use --force to apply again \n";
}

$qh->finish;
$DB->disconnect;
