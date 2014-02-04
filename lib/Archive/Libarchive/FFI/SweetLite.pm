package
  Archive::Libarchive::FFI::SweetLite;

use strict;
use warnings;
use FFI::Raw;
use Text::ParseWords qw( shellwords );
use Exporter::Tidy
  default => [qw(
    ffi_lib attach_function
    _void _int _uint _long _ulong _int64 _uint64
    _short _ushort _char _uchar _float _double _str _ptr
  )];

# This is intended for use with Archive::Libarchive::FFI ONLY until
# FFI::Sweet makes it to CPAN

my @libs;

sub ffi_lib ($)
{
  my $lib = shift;
  if(ref $lib)
  {
    if(eval { $lib->isa('Alien::Libarchive') })
    {
      if($lib->install_type eq 'share')
      {
        if($^O eq 'MSWin32')
        {
          die 'fixme';
        }
        elsif($^O eq 'cygwin')
        {
          die 'fixme';
        }
      }
      push @libs, DynaLoader::dl_findfile(shellwords $lib->libs);
    }
    else
    {
      push @libs, $$lib;
    }
  }
}

sub attach_function ($$$;$)
{
  my($name, $arg_types, $rv_type, $wrapper ) = @_;
  my $pkg = caller;
  $arg_types //= [];
  my $install_name = $name;
  ( $name, $install_name ) = @{ $name } if ref $name;
  
  foreach my $lib (@libs)
  {
    my $ffi = eval { FFI::Raw->new($lib, $name, $rv_type, @$arg_types) };
    next if $@;
    
    no strict 'refs';
    *{join '::', $pkg, $install_name} = $wrapper ? sub { $wrapper->($ffi, @_) } : $ffi->coderef;
    return;
  }
  
  die "unable to find $name\n";
}

foreach my $type (qw( void int uint long ulong int64 uint64 short ushort char uchar float double str ptr ))
{
  no strict 'refs';
  eval qq{ sub _$type { FFI::Raw::$type\() } };
  die $@ if $@;
}

1;
