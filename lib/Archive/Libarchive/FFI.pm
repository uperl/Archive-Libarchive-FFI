package Archive::Libarchive::FFI;

use strict;
use warnings;
use Alien::Libarchive;
use FFI::Raw::PtrPtr;
use FFI::Sweet qw( ffi_lib :types );
use base qw( Exporter );

# ABSTRACT: Perl bindings to libarchive via FFI
# VERSION

ffi_lib \$_ for map { print "$_\n" if 0; $_ } DynaLoader::dl_findfile(split /\s+/, Alien::Libarchive->new->libs);

our %EXPORT_TAGS = ( all => [], const => [], func => [] );

require Archive::Libarchive::FFI::constants;
require Archive::Libarchive::FFI::functions;

sub attach_function ($$$)
{
  my ( $name, $arg, $rv ) = @_;
  push @{ $EXPORT_TAGS{func} }, $name;
  FFI::Sweet::attach_function($name, $arg, $rv);
}

attach_function 'archive_read_new',                    undef, _ptr;
attach_function 'archive_read_support_filter_all',     [ _ptr ], _int;
attach_function 'archive_read_support_format_all',     [ _ptr ], _int;
attach_function 'archive_read_open_filename',          [ _ptr, _str, _int ], _int;
attach_function 'archive_read_free',                   [ _ptr ], _int;
attach_function 'archive_error_string',                [ _ptr ], _str;
attach_function 'archive_entry_pathname',              [ _ptr ], _str;
attach_function 'archive_read_data_skip',              [ _ptr ], _int;
attach_function 'archive_clear_error',                 [ _ptr ], _void;
attach_function 'archive_copy_error',                  [ _ptr ], _int;
attach_function 'archive_filter_code',                 [ _ptr, _int ], _int;
attach_function 'archive_filter_count',                [ _ptr ], _int;
attach_function 'archive_filter_name',                 [ _ptr, _int ], _str;
attach_function 'archive_errno',                       [ _ptr ], _int;
attach_function 'archive_file_count',                  [ _ptr ], _int;
attach_function 'archive_format',                      [ _ptr ], _int;
attach_function 'archive_format_name',                 [ _ptr ], _str;
attach_function 'archive_read_support_filter_program', [ _ptr, _str ], _int;
attach_function 'archive_read_support_format_by_code', [ _ptr, _int ], _int;
attach_function 'archive_version_number',              undef, _int;
attach_function 'archive_version_string',              undef, _str;

attach_function "archive_read_support_filter_$_",  [ _ptr ], _int for qw( bzip2 compress gzip grzip lrzip lzip lzma lzop none );
attach_function "archive_read_support_format_$_",  [ _ptr ], _int for qw( 7zip ar cab cpio empty gnutar iso9660 lha mtree rar raw tar xar zip );

push @{ $EXPORT_TAGS{func} }, qw( archive_read_next_header archive_read_open_memory );

sub archive_read_next_header
{
  my $entry = FFI::Raw::PtrPtr->new;  
  my $ret = Archive::Libarchive::FFI::functions::archive_read_next_header($_[0], $entry);
  $_[1] = $entry->dereference;
  $ret;
}

sub archive_read_open_memory
{
  my($archive, $buffer) = @_;
  my $length = do { use bytes; length($buffer) }; # TODO: what is the "right" way to do this?
  my $ptr = FFI::Raw::MemPtr->new_from_buf($buffer, $length);
  Archive::Libarchive::FFI::functions::archive_read_open_memory($archive, $ptr, $length);
}

@{ $EXPORT_TAGS{func} } = sort @{ $EXPORT_TAGS{func} };

our @EXPORT_OK = (map { @{ $EXPORT_TAGS{$_} } } qw( const func ));
$EXPORT_TAGS{all} = \@EXPORT_OK;

1;
