#!/usr/bin/perl

#Usage:
#> ls -l | ls_to_octal

@ls = <STDIN>;

foreach (@ls) {
  if (! /[-dscb]/) {
    print;
    next;
  }
  $mode = $owner = $group = $other = 0;
  ($perms, $foo) = split(/ /,$_,2);
  ($type, @perms) = split(//,$perms);
  $owner += 4 if($perms[0] eq "r");
  $group += 4 if($perms[3] eq "r");
  $other += 4 if($perms[6] eq "r");
  $owner += 2 if($perms[1] eq "w");
  $group += 2 if($perms[4] eq "w");
  $other += 2 if($perms[7] eq "w");
  $owner += 1 if($perms[2] eq "x" or $perms[2] eq "s");
  $group += 1 if($perms[5] eq "x" or $perms[5] eq "s");
  $other += 1 if($perms[8] eq "x" or $perms[8] eq "s" or $perms[8] eq "t");
  $mode += 1 if($perms[8] eq "t");
  $mode += 2 if($perms[5] eq "s");
  $mode += 4 if($perms[2] eq "s");
  $perms = "$mode" . "$owner" . "$group" . "$other";
  print "$perms" . " " . "$foo";
}
