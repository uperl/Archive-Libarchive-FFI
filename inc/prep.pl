use strict;
use warnings;
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
