use strict;
use warnings;
use v5.10;
use Archive::Libarchive::XS;
use Path::Class qw( file dir );

do { # constants.pm

  my $file = file(__FILE__)->parent->parent->file(qw( lib Archive Libarchive FFI constants.pm ));
  
  $file->parent->mkpath(0,0755);
  
  my $fh = $file->openw;
  
  print $fh "package Archive::Libarchive::FFI;\n\n";
  print $fh "use strict;\n";
  print $fh "use warnings;\n\n";
  
  print $fh "use constant {\n";
  foreach my $const (sort @{ $Archive::Libarchive::XS::EXPORT_TAGS{const} })
  {
    my $value = eval qq{ Archive::Libarchive::XS::$const() };
    print $fh "  $const => $value,\n";
  }
  print $fh "};\n\n";
  
  print $fh "push \@{ \$Archive::Libarchive::FFI::EXPORT_TAGS{const} }, qw(\n";
  
  foreach my $const (sort @{ $Archive::Libarchive::XS::EXPORT_TAGS{const} })
  {
    print $fh "  $const\n";
  }
  
  print $fh ");\n\n";
  
  print $fh "1;\n";
  
  close $fh;
};

do { # import examples from XS version

  my $source = file(__FILE__)->parent->parent->parent->subdir('Archive-Libarchive-XS')->subdir('example');
  
  unless(-d $source)
  {
    die "first checkout Archive::Libarchive::XS";
  }
  my $dest = file(__FILE__)->parent->parent->subdir('example');
  
  foreach my $example ($source->children)
  {
    say $example->absolute;
    if($example->basename =~ /\.pl$/)
    {
      my $pl = join '', map { s/XS/FFI/g; $_ } $example->slurp;
      $dest->file($example->basename)->spew($pl);
    }
    else
    {
      $dest->file($example->basename)->spew(scalar $example->slurp);
    }
  }

};

do { # import tests from XS version

  my $source = file(__FILE__)->parent->parent->parent->subdir('Archive-Libarchive-XS')->subdir('t');
  my $dest = file(__FILE__)->parent->parent->subdir('t');

  foreach my $archive ($source->children)
  {
    next if $archive->is_dir;
    next unless $archive->basename =~ /^foo\./;
    say $archive->absolute;
    $dest->file($archive->basename)->spew(scalar $archive->slurp);
  }
  
  foreach my $test ($source->children)
  {
    next if $test->is_dir;
    next unless $test->basename =~ /^common_.*\.t$/;
    say $test->absolute;
    my $pl = join '', map { s/XS/FFI/g; $_ } $test->slurp;
    $dest->file($test->basename)->spew($pl);
  }

};
