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

# freq (in Hz) of notes in C1 octave
@g_freq = (
  1.000, # mute
261.626, # do
293.665, # re
329.628, # mi
349.228, # fa
391.995, # so
440.000, # la
493.883, # ti
);

# freq ratio of 100 cent: 2^(1/12).
$g_cent100=1.059463;



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
### print_header
#####################################################################
sub print_header
{
	print "G91X0Y0Z0\n";
	print "#1=1. (k; feed-rate=freq*k)\n";
	print "#2=1. (duration of a beat in seconds)\n";
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
	#print "$song\n";

	# build the note array
	@notes = $song =~ /([\+\-b#]*\d[\.>=]*)/g;

	& print_header;

	# convert each note into g-code
	foreach $note (@notes) {
		#print "($note)\n";
		
		#################################
		### pitch: freq in Hz
		#################################

		# get the digit and the base freq
		$_ = $note;
		/([0-7])/;  # now $1 is the digit, used as index below
		my $freq = $g_freq[$1];

		if ($1 != 0) {
			# get the octave shift, how many '+' and '-':
		        my $plus = ($note =~ tr/\+//);
			my $minus = ($note =~ tr/\-//);
			$freq = $freq * (2 ** ($plus - $minus));

			# get the b/#
			my $below = ($note =~ tr/b//);
			my $sharp = ($note =~ tr/#//);
			$freq = $freq * ($g_cent100 ** ($sharp - $below));
		}

		#print "$1, $freq, $plus, $minus, $sharp, $below^\n";

		#################################
		### duration: nr of beat. 
		###    '=' and '.' are processed first, followed by '>'
		#################################
		
		my $duration = 1.0;
		my $equal = ($note =~ tr/=//);
		$duration = 1.0 / (2 ** $equal);
		my $dot =  ($note =~ tr/\.//);
		if ($dot > 0) {
			$duration = $duration *1.5;
		}
		my $great = ($note =~ tr/>//);
		$duration = $duration + $great;
		#print "$note: $equal, $dot, $great, $duration^\n";

		#################################
		### output g-code:
		### #1: k, feedrate = freq * k;
		### #2: seconds per beat
		#################################
		my $feedrate = $freq;   # mm/min
		my $distance = $feedrate * $duration / 60.;
		printf("X[%7.3f*#2*#1] F[%$5.3f*#1]\n", $distance, $feedrate);
	}

	# end the g-code
	print "M2 (stop)\n";	
}
