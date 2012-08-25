#!/usr/bin/perl

use File::Basename;
use strict;


################################################################
# ref: "Perl 5 Complete", $7.5 example 3.
#
# notes on the data structure:

# here is a sample tree on file system:
#
# test
#  |
#  |- dir1
#  |   |
#  |   |- file1
#  |   \- file2
#  |- dir2
#  |   |
#  |   |- file3
#  |   \- file4
#  |- file5
#  \- file6
#
# it should be represented in perl as hash tables illustrated below:
#
#
#  {"test" => {"dir1" => {"file1"=>"FILE", 
#                         "file2"=>"FILE"
#                        },
#              "dir2" => {"file3"=>"FILE",
#	                  "file4"=>"FILE"
#			 },
#               "file5"=>"FILE",
#               "file6"=>"FILE"
#              }
#  }
#
################################################################

my $head = 
    "import fontsize;\n".
    "import \"../node/node.asy\" as node;\n\n". 
    "settings.tex = \"xelatex\";\n".
    "texpreamble(\"\\usepackage{xeCJK}\");\n".
    "texpreamble(\"\\setCJKmainfont{SimHei}\");\n".
    "texpreamble(\"\\setmonofont[Path=../fonts/]{andalemo.ttf}\");\n\n";

# hash value for file type keys are the same:
my $FILE = "__FILE__";  

################################################################
# it takes 3 arguments: path, level, and flag
# path: should be a directory, not accept a file
# level: 
#   - if level > 0, recursively call itself with level=(level-1);
#   - if level == 0, stop recursive calls.
# flag is either zero or non-zero:
#   - 0 means dir only
#   - otherwise, means dir and files
#
# it returns a ref to a hash contains the entries under path, the
# basename of the path itself is not included.
################################################################
sub build_tree
{
	my ($path, $level, $flag) = @_;
	my ($file, $kids) = ('', {});
	
	# sanity checks
	if(!(-e $path)){
		die "$path does not exist.\n";
	}

	if(!(-d $path)){
		die "$path is not a directory\n";
	}
		
	opendir(FD, $path);
	my @files = readdir(FD);
	closedir(FD);
		
	chdir($path);

	foreach $file (@files){

		next if ($file eq '.' || $file eq '..');

		if(-f $file){
			if($flag != 0){
				$kids->{$file} = $FILE;
			}
		}
		elsif (-d $file){

			if($level > 0){
				$level -= 1;
				$kids->{$file} = build_tree($file, $level, $flag);
			}
		}
	}

	chdir("..");
	
	#$dad->{basename($path)} = $kids;
	#return $dad;
	return $kids;
}

###############################################################
# it takes one argument: the REF to the dir or file name
# it converts a dir/file name into an unique node name which also
# obeys asymptote variable naming rules
###############################################################
sub get_node_asy_name
{
	my ($name) = (@_);
	my $node_name = $$name.'_'.$name;
	$node_name =~ s/SCALAR|HASH//g;
	$node_name =~ s/[-+.&() ]/_/g;
	return $node_name;
}

###############################################################
# it takes 2 arguments: the key and the value of the ndoe
# it outputs the node definition in asymptote, such as:
#   node my_node = node("my node name", "f");
###############################################################
sub define_asy_node
{
	my ($key, $value) = (@_);
	my $type;

	if($value eq $FILE){
		$type = "f";
	}
	else{
		$type = "d";
	}

	print "node ";
        print get_node_asy_name(\$key);
	print " = node(\"".$key."\", \"";
	print "$type\");\n";
}
		

###############################################################
# it takes 2 arguments: the REFs to the dad and kid node name
###############################################################
sub attach_asy_node
{
	my ($dad, $kid) = (@_);
	print get_node_asy_name($dad);
	print ".attach(";
	print get_node_asy_name($kid);
	print ");\n";
}

################################################################
# it takes 2 argument: REF to the root key, and
# REF to the value of the root key:
#  - $rootkey: its assumed that the asy node of the rootkey is already created,
#    it's provided here for its kids to attach to it.
#  - $rootvalue: hashref to the content of the root. cann't be $FILE, as the
#    sanity test excludes this case
#
################################################################
sub output_tree
{
	my ($dad, $kids) = @_;
	my $dad_node;
	my $key;

	$dad_node = get_node_asy_name(\$dad);

	foreach $key (keys %$kids){
		define_asy_node(\$key);

		if(ref $kids->{$key}){
			output_tree(\$key, $kids->{$key});
		}
		else{
			attach_asy_node(\$dad, \$key);
		}
	}
}
my $tree = {};
$tree->{"test"} = build_tree("test", 10, 1);
output_tree($tree);

