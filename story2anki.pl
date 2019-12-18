

#open my local dictionary file
# and put it into @voratro

#verbose is used for troubleshooting.  Set to 1 for additional lines to be printed.
$verbose = 0;

open(FILE,"avortaro.txt") || die;

@vortaro = <FILE>;


# search through the lines for @vortaro
foreach $line (@vortaro) {

    #checking to see if the line looks like: root/ definition <new line>
	if ($line =~ /([a-zA-ZŝĝĉĵĥŭŜĜŬĴĤZĈ]+)\/([\s\w,]+)\n/) { 
			# $1  is the root
			# $2 is the definition/meaning
			
			$word = $1; $meaning = $2;  
			print "verbose--- word:$word     definition:$meaning\n" if $verbose; 
			
			#remove trailing white space
			$meaning =~ s/\s+$//;

			$worddef{$word} = $meaning;
			}
}




foreach $line (sort keys %worddef) {
	$meaning = $worddef{$line};
	print "verbose --- $line\\ - meaning $meaning\n" if $verbose;
	}
	
# name of the store that will be inputed into the script
$fn = "GerdaMalaperis.txt";

	open(FILE,$fn) || die;
    print "**************** Reading $fn\n";
	@text = <FILE>;
	
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
				$wordline{$word} = $line;
				
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
			if ($count ne "lep") {
			        #pull the web page from the simpla vortaro for the word.
					$url = "http://www.simplavortaro.org/api/v1/trovi/$word";
					my $page = `wget -q -O - "$url"`; 

					#find the place on the page where the word is broken out and save it
					$page =~ /\"rezulto\":\s\"(\S*)\"/i;
					$brokeout = $1;

					#web pages mangle the special characters.  change them back.
					$brokeout =~ s/\\u0109/ĉ/;
					$brokeout =~ s/\\u015d/ŝ/;
					$brokeout =~ s/\\u0125/ĥ/;
					$brokeout =~ s/\\u011d/ĝ/;
					$brokeout =~ s/\\u016d/ŭ/;
					$brokeout =~ s/\\u0135/ĵ/;
					
					#see if we can find the definition of our roots that are broken out...
					(@bo) = split/-/,$brokeout;
					
					$hold = "";
					
					foreach $part (@bo) {
							#put the different root definitions into $hold
							if (length ($worddef{$part})) { $hold = $hold ."$part - $worddef{$part}<br>";} 
							}
					
					
					#print out our line for the csv file.  Using pipe as the delimiter
		            # $word - the word...
					# $count - where it was found in the story
					# $brokeout - the roots of the compound word
					# $wordline{$word} - The line of the story where the word came from
					# $hold - definition of roots if available
					
					print "$word|".$count."|$brokeout|$wordline{$word}|$hold\n";
					
				
					
					# Be kind and pause one second between each request to la simpla vortaro
					
					sleep(1);
					}
			}

# I usually type perl getwords3.pl >> filename.csv to execute and save output

# I open with libre office.  I will cut and paste 100 line blocks of words into translate.google.com to get translations.... 
# ... then paste the results back into libre office into a new column.
# you may need to create a card type in ANKI that will support the number of fields that we are using.
# the first column should be the word... if the first field is a dupe in anki in any deck... it will ignore it.

			
		
 
