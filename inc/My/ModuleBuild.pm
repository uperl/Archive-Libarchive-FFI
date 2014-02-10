package My::ModuleBuild;

use strict;
use warnings;
use FFI::Raw;
use Alien::Libarchive;
use Text::ParseWords qw( shellwords );

use base qw( Module::Build::FFI );

sub new
{
  my($class, %args) = @_;
  
  my $alien = Alien::Libarchive->new;

  my $cflags = $alien->cflags;

  # TODO: this won't work for cygwin or MSWin32
  my $so = DynaLoader::dl_findfile(shellwords $alien->libs);
  
  foreach my $symbol (qw( archive_read_disk_set_gname_lookup archive_read_disk_set_uname_lookup ))
  {
    if(eval { FFI::Raw->new($so, $symbol, FFI::Raw::void); 1 })
    {
      $cflags .= " -DHAS_$symbol";
    }
  }

  $args{extra_compiler_flags} = $cflags;
  $args{extra_linker_flags}   = $alien->libs;

  foreach my $key (qw( extra_compiler_flags extra_linker_flags ))
  {
    print "$key = $args{$key}\n";
  }

  $class->SUPER::new(%args);
}

1;
