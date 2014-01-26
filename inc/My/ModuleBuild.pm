package My::ModuleBuild;

use strict;
use warnings;
use Alien::Libarchive;
use base qw( Module::Build::FFI );

sub new
{
  my($class, %args) = @_;
  
  my $alien = Alien::Libarchive->new;

  $args{extra_compiler_flags} = $alien->cflags;
  $args{extra_linker_flags}   = $alien->libs;

  $class->SUPER::new(%args);
}

1;
