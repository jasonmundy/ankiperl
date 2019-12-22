#!/usr/bin/perl

# story2anki.pl
# 
#


$fn = shift || die "Use filename when starting script.\n";

$verbose = 0; #default to not verbose
$nocheck = 0; #default to checking words with la simpla vortaro.

### A list of words i was having trouble sparcing from the avortaro file
$worddef{"a"} = "termination of adjectives";
$worddef{"as"} = "ending of the present tense in verbs";
$worddef{"e"} = "ending of adverbs";
$worddef{"i"} = "termination of the infinitive in verbs";
$worddef{"is"} = "ending of past tense in verbs";
$worddef{"j"} = "sign of the plural";
$worddef{"n"} = "ending of the objective; also marks direction";
$worddef{"o"} = "ending of nouns (substantive)";
$worddef{"os"} = "ending of future tense in verbs";
$worddef{"u"} = "ending of the imperative in verbs";
$worddef{"us"} = "ending of the conditional in verbs";
$worddef{"ŝi"} = " she";
$worddef{"tamen"} = " however, nevertheless";
$worddef{"tia"} = " such, that kind of";
$worddef{"tial"} = " therefore, for that reason";
$worddef{"tiam"} = " then";
$worddef{"tie"} = " there";
$worddef{"tiel"} = " thus, so; in that way";
$worddef{"ties"} = " that one's";
$worddef{"tio"} = " that (thing)";
$worddef{"tiom"} = " so much, that quantity";
$worddef{"tiu"} = " that (one) (person or thing)";
$worddef{"tra"} = " through (place)";
$worddef{"trans"} = " across";
$worddef{"tre"} = " very";
$worddef{"tri"} = " three";
$worddef{"tro"} = " too";
$worddef{"tuj"} = " immediately";
$worddef{"Turk"} = " [popolnomo] Turk";
$worddef{"ul"} = " [sufikso] person noted for…";
$worddef{"unu"} = " one";
$worddef{"ve"} = " woe!";
$worddef{"vi"} = " you";
$worddef{"ĉu"} = " Start of a question, whether";


## Check the arguements on the command line
foreach $option (@ARGV) {
		$verbose = 1 if $option eq "--verbose";
		$nocheck = 1 if $option eq "--nocheck";
		}


#open my local dictionary file
# and put it into @voratro

open(FILE,"avortaro.txt") || die;
@vortaro = <FILE>;
close (FILE);

# search through the lines for @vortaro
foreach $line (@vortaro) {

    $flag = 0;
	
    print "# verbose--- checking $line";
    #checking to see if the line looks like: root/ definition <new line>
	if ($line =~ /([a-zA-ZŝĝĉĵĥŭŜĜŬĴĤZĈ]+)\/([\s\w,\(\)\;=\.\-\'\/]+)\n/) { 
			# $1  is the root
			# $2 is the definition/meaning
			
			$word = $1; $meaning = $2;  
			print "# verbose--- word:$word     definition:$meaning\n" if $verbose; 
			
			#remove trailing white space
			$meaning =~ s/\s+$//;

			$worddef{$word} = $meaning;
			$flag = 1;
			
			}
			
   #checking to see if the line looks like: root/ definition <new line>
   #aĉ/ [sufikso] contemptible, wretched
	if ($line =~ /([a-zA-ZŝĝĉĵĥŭŜĜŬĴĤZĈ\ -]+)\/ \[(sufikso|prefikso|finaĵo)\]([\s\w,-]+)\n/) { 
			# $1  is the root
			# $3 is the definition/meaning
			
			$word = $1; $meaning = $3;  
			print "# verbose--- word:$word     definition:$meaning\n" if $verbose; 
			
			#remove trailing white space
			$meaning =~ s/\s+$//;

			$worddef{$word} = $meaning;
			$flag = 1;
			}
			
			print "#*** no match *** $line" if $flag == 0;
}


foreach $line (sort keys %worddef) {
	$meaning = $worddef{$line};
	print "verbose --- $line\\ - meaning $meaning\n" if $verbose;
	}

###
### Read our database of words from La Simpla Vortaro
###
$lsv = "lasimplavortaro.txt";

open (FILE, $lsv) || die;
@lsv = <FILE>;
close (FILE);

foreach $line (@lsv) {

			#remove trailing white space
			$line =~ s/\s+$//;
			
			($word, $brokenword) = split /\|/,$line;
			
			$lsv{$word} = $brokenword;

}


open(FILE,$fn) || die;
print "\n# **************** Reading $fn\n";
@text = <FILE>;
close (FILE);
	

	foreach $line (@text) {
		 print "verbose--- $line" if $verbose; 
		
		## Take a look at one line of text from the story.  Split it up into multiple words.
		## We are splitting the line by means of spaces . , ; ! " : ? " ( ) 
				
		@array = split(/\s+|\.|\;|\,|\!|\"|\:|\?|\;|\“|\(|\)/,$line);
		
		## look through all the words that were in that one line...
		
		foreach $word (@array) {
				    
			$word = lc $word; # make it lower case
			$word = $1 if ($word =~ /(.*)jn\z/); # remove jn ending
			$word = $1 if ($word =~ /(.*)j\z/); # remove j ending
			$word = $1 if ($word =~ /(.*)n\z/); # remove n ending
			$word = "$1i" if ($word =~ /(.*)as\z/); #change as ending to i
			$word = "$1i" if ($word =~ /(.*)os\z/); #change os ending to i
			$word = "$1i" if ($word =~ /(.*)is\z/); #change is ending to i
			$word = "$1i" if ($word =~ /(.*)us\z/); #change us ending to i
			$word = "$1i" if ($word =~ /(.*)u\z/); #change u ending to i
			
			$word =~ s/Ŝ/ŝ/; #make it lower case
			$word =~ s/Ĝ/ĝ/; #make it lower case
			$word =~ s/Ĉ/ĉ/; #make it lower case
			$word =~ s/Ŭ/ŭ/; #make it lower case
			$word =~ s/Ĥ/ĥ/; #make it lower case
			$word =~ s/Ĵ/ĵ/; #make it lower case
			

			#every time a word is seen.  $x is incremented.  This helps to keep the words in order for anki
			#I append the position of the word to a string... $wl{$word}.  I'll come back and clean up the $wl{$word} string later...

				$wl{$word} = $wl{$word}.$x++.","; 
				
				#I store the text the word was found from in $wordline{$word}
				$wordline{$word} = $line if length($wordline{$word}) < 1;
				
				#Remove white space from the front and back of the text.
			    $wordline{$word} =~ s/^\s+|\s+$//g;
			
			}
		}
	
	#all of the unique words have now been captured.  The array of the words is keys %wl
	#$wl{$word} = word position. (still needs to be cleaned up)
	#$wordline{$word} = the text from the book the word came from
	
	
	# Now we are going to query la simpla vortaro
	# can it split our word up into its seperate parts?
	
#set our count to zero	
	$y = 0;
	
	#search through our word list.
	foreach $word ( keys %wl) {
	        #This is where we clean up $wl{$word}.  Now the string will only have the word count where the word was first seen.
			($count,@hold) = split /,/,$wl{$word};
			
			#lep is old code.... should always be true...
			if ($nocheck  == 0) {
			        
					$brokeout = ElRompo($word);
					
					$signifoj = RompoSignifo($brokeout);
					} else {
					
					$brokeout = "";
					$signifoj = "";
					
					}
					
					
					#print out our line for the csv file.  Using pipe as the delimiter
		            # $word - the word...
					# $count - where it was found in the story
					# $brokeout - the roots of the compound word
					# $wordline{$word} - The line of the story where the word came from
					# $hold - definition of roots if available
					
					print "$word|".$count."|$brokeout|$wordline{$word}|$signifoj\n";
					print "#\n" if $verbose;
				
					
					
					
			}

# I usually type perl getwords3.pl >> filename.csv to execute and save output

# I open with libre office.  I will cut and paste 100 line blocks of words into translate.google.com to get translations.... 
# ... then paste the results back into libre office into a new column.
# you may need to create a card type in ANKI that will support the number of fields that we are using.
# the first column should be the word... if the first field is a dupe in anki in any deck... it will ignore it.

sub RompoSignifo {
		my $brokeout = shift;
		
		
		
					(@bo) = split/-/,$brokeout;
					
					$hold = "";
					
					foreach $part (@bo) {
							#put the different root definitions into $hold
							if (length ($worddef{$part})) { $hold = $hold ."$part - $worddef{$part}<br>";} 
							}
							
			        return $hold;
		}

			
sub ElRompo {
			my $word = shift;
			
			## Return what was in the db if we have it.
			print "***** $lsv{$word}\n" if length($lsv{$word})>0;
			return $lsv{$word} if length($lsv{$word})>0;
			
			
			#Looks like we have to query the web...
			
					my $url = "http://www.simplavortaro.org/api/v1/trovi/$word";
					my $page = `wget -q -O - "$url"`; 

					# Be kind and pause one second between each request to la simpla vortaro
					sleep (1);

					#find the place on the page where the word is broken out and save it
					$page =~ /\"rezulto\":\s\"(\S*)\"/i;
					my $brokeout = $1;

					#web pages mangle the special characters.  change them back.
					$brokeout =~ s/\\u0109/ĉ/;
					$brokeout =~ s/\\u015d/ŝ/;
					$brokeout =~ s/\\u0125/ĥ/;
					$brokeout =~ s/\\u011d/ĝ/;
					$brokeout =~ s/\\u016d/ŭ/;
					$brokeout =~ s/\\u0135/ĵ/;
					
			$brokeout = "???" if length( $brokeout ) <1;
			
			open (FILE,">>",$lsv) || die;
			print FILE "$word|$brokeout\n";
			close (FILE);
			
			
					return $brokeout;

			}