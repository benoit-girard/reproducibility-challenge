#!/usr/bin/perl -w
# Author        : Pedro Velho
# last modified : 04/11/2008


$workingdir="/home/velho/Development/projet-simgrid/simgrid/examples/msg/gtnets";
if($workingdir eq ""){
    print "Please edit me with a correct work directory, use absolut path is mandatory!\n";
    exit 1;
}
$thisdir= `pwd`;
chomp $thisdir;

# ****** 1- Parameter Message Size (S) ******
# in BYTES
@message_size_list = ("1000","1180","1360","1540","1720","1900","2080","2260","2440","2620","2800","2980","3160","3340","3520","3700","3880","4060","4240","4420","4600","4780","4960","5140","5320","5500","5680","5860","6040","6220","6400","6580","6760","6940","7120","7300","7480","7660","7840","8000","8300","8600","8900","9200","9500","9800","10100","10400","10700","11000","11300","11600","11900","12200","12500","12800","13100","13400","13700","14000","14300","14600","14900","15200","15500","15800","16100","16400","16700","17000","17300","17600","17900","18200","18500","18800","19100","19400","19700","20000","26140","32280","38420","44560","50700","56840","62980","69120","75260","81400","87540","93680","99820","105960","112100","118240","124380","130520","136660","142800","148940","155080","161220","167360","173500","179640","185780","191920","198060","204200","210340","216480","222620","228760","234900","241040","247180","253320","259460","268000","528000","788000","1048000","1308000","1568000","1828000","2088000","2348000","2608000","2868000","3128000","3388000","3648000","3908000","4168000","4428000","4688000","4948000","5208000","5468000","5728000","5988000","6248000","6508000","6768000","7028000","7288000","7548000","7808000","8068000","8328000","8588000","8848000","9108000","9368000","9628000","9888000","10000000","16000000","32000000","64000000","128000000","256000000","512000000","600000000");

# ****** 2- Parameter Latency (L) ****** 
# in SECONDS
@latency_list=("0.00001","0.00002","0.00004","0.00008","0.00016","0.00032","0.00064","0.00100","0.00400","0.00800","0.01600","0.03200","0.06400","0.12800","0.25600","0.50000");

# ****** 3- Bandwidth (B) ******
# in BYTESperSECOND
@bandwidth_list=("1.000000e+05","1.000000e+06","1.000000e+07","1.000000e+08","1.000000e+09","1.000000e+04","1.333521e+04","1.778279e+04","2.371374e+04","3.162278e+04","4.216965e+04","5.623413e+04","7.498942e+04","1.333521e+05","1.778279e+05","2.371374e+05","3.162278e+05","4.216965e+05","5.623413e+05","7.498942e+05","1.000000e+06","1.333521e+06","1.778279e+06","2.371374e+06","3.162278e+06","4.216965e+06","5.623413e+06","7.498942e+06","1.000000e+07","1.333521e+07","1.778279e+07","2.371374e+07","3.162278e+07","4.216965e+07","5.623413e+07","7.498942e+07","1.000000e+08","1.333521e+08","1.778279e+08","2.371374e+08","3.162278e+08","4.216965e+08","5.623413e+08");

# ****** 4- Model (M) ******
@model_list=("CM02","GTNets","LegrandVelho");

#########################################
# Print error and exit
#########################################
sub printError {
    my($errorMsg) = $_[0];
    print "Error : ".$errorMsg."\n";
    print "Parse usage:\n";
    print "\tsweap_analyze parse\n\n";
    print "Sweep usage:\n";
    print "\tsweap_analyze sweep <task_begin> <task_end>\n\n";
    print "Examples\n";
    print "\tsweap_analyze 1 1 # executes task 1 (fix bandwidth[0] parameter)\n";
    print "\tsweap_analyze 1 3 # executes task from 1 up to 3\n\n";
    print "\nIn this program you have ".($#bandwidth_list+1)." tasks to parallelize.\n\n";
    exit 1;
}

if(scalar(@ARGV) < 1){ 
    printError("Needs at least one parameter sweep or parse");
}

if($ARGV[0] ne "sweep" && $ARGV[0] ne "parse"){
    printError("First argument should be sweep or parse");
}

if($ARGV[0] eq "sweep"){
    if(scalar(@ARGV) != 3){
	printError("Option sweep must be followed by two integers in task range.");
    }else {
	executeApplication();
    }
}

if($ARGV[0] eq "parse"){
    parseResults();
}


#########################################
# Parse and verify arguments range
#########################################
sub parseParameters() {
    #adjust to perl parameters (arrays are from 0 up size-1)
    $task_begin=$ARGV[1]-1;
    $task_end=$ARGV[2]-1;

    if($task_begin < 0){
	print "Starting from a not valuable array index aborting...\n";
	print "Check the correctness of first parameter.\n";
	exit 1;
    }
    print "Bandiwthd array size is : ",scalar(@bandwidth_list),"\n";
    if($task_end >= scalar(@bandwidth_list)){
	print "Error doing more tasks than we have to do aborting...\n";
	print "Check the correctness of second parameter.\n";
	exit 1;
    }
    if($task_begin > $task_end){
	print "Error starting point is greater then end point...\n";
	print "Second parameter must be greater.\n";
	exit 1;
    }
}




#########################################
# Execute application only once
#########################################
sub executeApplication {
    parseParameters();
    
    print "Changing working directory to ".$workingdir."\n";
    chdir($workingdir);

    $tmpoutputxmlpla = $thisdir."/tmp/plateforme-".($task_begin+1)."-".($task_end+1).".xml";
    $tmpoutputxmldep = $thisdir."/tmp/deployment-".($task_begin+1)."-".($task_end+1).".xml";
    $tmpoutputlog    = $thisdir."/tmp/tempotrace-".($task_begin+1)."-".($task_end+1).".log";

    open(LOGOUTPUT, ">" , $thisdir."/log/trace-file-".($task_begin+1)."-".($task_end+1).".log") ||
	die "Sorry, couldn't open file ".$thisdir."/log/trace-file-".($task_begin+1)."-".($task_end+1).".log for writting...\n";

    print LOGOUTPUT "\n";

    $it=0;
    for($it=$task_begin; $it <= $task_end; $it++) 
    {
	$bandwidth = $bandwidth_list[$it];
	print ">=============================================================<\n";
	print "========> Bandwidth (B) : ",$bandwidth," B/s (Bytes per second)\n";
	foreach $latency (@latency_list)
	{
	    print "========> Latency   (L) : ",$latency," s (seconds)\n";

	    foreach $size (@message_size_list)
	    {
		print "========> Size      (S) : ",$size," B (Bytes) \n";		
		foreach $model (@model_list)
		{
		    print "========> Model     (M) : ",$model,"\n";

		    # Log some stuff into the file to know used parameters
		    print LOGOUTPUT ">==================================================<\n";
		    print LOGOUTPUT "========> Bandwidth (B) : ",$bandwidth," B/s (Bytes per second)\n";
		    print LOGOUTPUT "========> Latency   (L) : ",$latency," s (seconds)\n";
		    print LOGOUTPUT "========> Size      (S) : ",$size," B (Bytes) \n";
		    print LOGOUTPUT "========> Model     (M) : ",$model,"\n";
		    
		    
		    # Set parameters

		    system ("sed -e s/bw/".$bandwidth."/g -e s/lt/".$latency."/g ".$thisdir."/onelink-p-template.xml > ".$tmpoutputxmlpla);
		    system ("sed -e s/size/".$size."/g ".$thisdir."/onelink-d-template.xml > ".$tmpoutputxmldep);
		    
		    # Run with parameters
		    system ("./gtnets ".$tmpoutputxmlpla." ".$tmpoutputxmldep." --cfg=workstation_model:compound --cfg=cpu_model:Cas01 --cfg=network_model:".$model."  2>&1 &> ".$tmpoutputlog);
		    
		    # Open temporary output file
		    open(TMPOUTPUT, "<".$tmpoutputlog) || 
			die "Sorry, could't open temporary result file...\n";
		    
		    # Copy execution trace into global trace file
		    while(<TMPOUTPUT>)
		    {
			my $line = $_;
			chomp $line;
			print LOGOUTPUT $line."\n";
		    }
		    print LOGOUTPUT "=========================><=========================\n";
		}
	    }
	}
	print "==============================><=============================\n";
    }
    
    close(LOGOUTPUT);
}



#########################################
# Parse resulting values
# Genarate input file for R
#########################################
sub parseResults {

    open(RAWOUTPUT, ">".$thisdir."/dat/raw.data") ||
	die "Sorry, couldn't open file ".$thisdir."/dat/raw.data for writting...\n";

    print RAWOUTPUT "Bandwidth Latency Size Model Time\n";

    my($B, $L ,$S, $Model, $Time);
    my($counter);
    $counter=1;

    $it=1;
    for($it=1; $it <= scalar(@bandwidth_list); $it++) 
    {
     
    open(LOGOUTPUT, "<".$thisdir."/log/trace-file-".($it)."-".($it).".log")||
	die "Sorry, I coundn't open file ".$thisdir."/log/trace-file-".($it)."-".($it).".log for reading...";

    # Copy execution trace into global trace file
    while(<LOGOUTPUT>)
    {
	my $line = $_;
	chomp $line;
	
	# Find bandwidth parameter
	if($line =~ /Bandwidth/){
	    $B = get_value($line);
	    next;
	}

	# Find latency parameter
	if($line =~ /Latency/){
	    $L = get_value($line);
	    next;
	}

	# Find size parameter
	if($line =~ /Size/){
	    $S = get_value($line);
	    next;
	}

	# Find model parameter
	if($line =~ /Model/){
	    $Model = $line;
	    $Model =~ s/.*:\s+(.*)\s*$/$1/x;
	    next;
	}

	# Find time
	if($line =~ /C1\stime:/){
	    $Time=get_value($line);
	    print RAWOUTPUT $counter++," ",$B," ",$L," ",$S," ",$Model," ",$Time,"\n";
	    next;
	}
    }
    close(LOGOUTPUT);
    }
    close(RAWOUTPUT);
}

#########################################
# Parse numerical value within a line
#########################################
sub get_value {
    my($line)=shift;
    $line=" $line";
    $line =~ s/^
                .*[^\d\.+-eE]+         # anything except something in a number
                (
                   [+-]?\ *          # first, match an optional sign
                   (                 # then match integers or f.p. mantissas:
                      \d+            # start out with a ...
                      (
                          \.\d*      # mantissa of the form a.b or a.
                      )?             # ? takes care of integers of the form a
                      |\.\d+         # mantissa of the form .b
                   )
                   ([eE][+-]?\d+)?  # finally, optionally match an exponent
		 )
                \D*$/$1/x;
    return $line;
}
