#!/usr/bin/perl -w
$output=0;
while(<>) {
    if($_=~ /begin\{document\}/) { $output=1; next; }
    if($_=~ /end\{document\}/) { $output=0; next; }
    if($output) { print $_; }
}
