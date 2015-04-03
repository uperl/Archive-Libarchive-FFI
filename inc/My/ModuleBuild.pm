package My::ModuleBuild;

use strict;
use warnings;
use Alien::Libarchive::Installer;
use base qw( Module::Build );

sub new
{
  my($class, %args) = @_;
  
  unless(eval { Alien::Libarchive::Installer->system_install( test => 'ffi', alien => 1 ) })
  {
    $args{requires}->{'Alien::Libarchive'} = '0.21';
  }
  
  my $self = $class->SUPER::new(%args);
  
  $self;
}

sub ACTION_test
{
  my $self = shift;
  
  local $ENV{ARCHIVE_LIBARCHIVE_FFI_DLL};
  ($ENV{ARCHIVE_LIBARCHIVE_FFI_DLL}) = Alien::Libarchive::Installer->system_install( test => 'ffi', alien => 1 )->dlls;
  
  $self->SUPER::ACTION_test(@_);
}

1;
