#!/usr/bin/perl
#
# j2g means jianpu to g-code.
#
# created(bruin, 2012-07-20)
#

#####################################################################
# the following is the format for jianpu format of the input file
# simple rules for recording a song in ascii format
# adopted from: http://wenku.baidu.com/view/efe83633ee06eff9aef80737.html###
# 
# song     = [note]+
# note     = pitch duration
# pitch    = [-+b#]*[1-7], where
#     '-' means one negative octave distance from "normal" octave. multiple '-' means multiple of octave distances; 
#     '+' means the opposite to '-';
#     'b' means half negative note distance; multiple 'b' is allowed.
#     '#' means the opposite to 'b';
#     1-7 means do, re, mi, fa, so, la, ti respectively.
# duration = [.>=]*, where
#     '>' means adding one beat, multiple '>' is allowed.
#     '.' means adding half beat, multiple '.' is not allowed.
#     '=' means divided by 2, i.e, 1/2 beat. multiple '=' is allowed, e.g. '==' means 1/4 beat.
#     if nothing follows the digit [1-7], it means one beat duration of the note.
#
# an example of a fragment: 1.2=3=5=5=6=
#
#####################################################################


# all lines from the input file are joined into a single string, CR/LF removed
$song = '';
# the note array of the song, to be built from the input file
@notes = [];

&main;

#####################################################################
##### main
#####################################################################
sub main
{
	&parse_options;
	&open_file;
	&convert_to_gcode;
}


#####################################################################
### parse_options
#####################################################################
sub parse_options
{
	if (1 != scalar(@ARGV)){
		&usage_and_exit;
	}
	else{
		$input_filename = @ARGV[0];
	}
}	


#####################################################################
#### print usage
#####################################################################
sub usage_and_exit
{
	print "\nusage: \n\tj2g.pl <inputfile>\n";
	exit(1);
}

#####################################################################
### open_file
#####################################################################
sub open_file
{
	if (!open(IN,$input_filename)) {
		print stderr "Error: could not open input file: $input_filename\n";
		&usage_and_exit;
	}
}


#####################################################################
### convert_to_gcode
#####################################################################
sub convert_to_gcode
{
	# read all lines into memory
	$song = join("", <IN>);
	close IN;

	#removing all white spaces, if any
	$song =~ s/\s+//g;
	print "$song\n";

	# build the note array
	@notes = $song =~ /([\+\-b#]*\d[\.>=]*)/g;

	# convert each note into g-code
	foreach $note (@notes) {
		print "($note)\n";
		$_ = $note;
		/([1-7])/;
		my $p = $1;

		# pitch: only support +/- for now
		# how many '+', '=':
		my $plus = ($note =~ tr/\+//);
		my $minus = ($note =~ tr/\-//);

		print "$p, $plus, $minus^\n";
	}
	
}
