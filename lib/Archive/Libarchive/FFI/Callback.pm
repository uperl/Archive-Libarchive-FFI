package Archive::Libarchive::FFI::Callback;

use strict;
use warnings;

# ABSTRACT: Libarchive callbacks
# VERSION

package
  Archive::Libarchive::FFI;

use FFI::Sweet;

use constant {
  CB_DATA        => 0,
  CB_READ        => 1,
  CB_CLOSE       => 2,
  CB_OPEN        => 3,
  CB_WRITE       => 4,
  CB_SKIP        => 5,
  CB_SEEK        => 6,
  CB_SWITCH      => 7,
  CB_BUFFER      => 8,
};

my %callbacks;

my $myopen = FFI::Raw::Callback->new(sub {
  my($archive) = @_;
  my $status = eval {
    $callbacks{$archive}->[CB_OPEN]->($archive, $callbacks{$archive}->[CB_DATA]);
  };
  if($@)
  {
    warn $@;
    return ARCHIVE_FATAL();
  }
  $status;
}, _int, _ptr, _ptr);

my $mywrite = FFI::Raw::Callback->new(sub 
{
  my($archive, $null, $ptr, $size) = @_;
  my $buffer = buffer_to_scalar($ptr, $size);
  my $status = eval {
    $callbacks{$archive}->[CB_WRITE]->($archive, $callbacks{$archive}->[CB_DATA], $buffer);
  };
  if($@)
  {
    warn $@;
    return ARCHIVE_FATAL();
  }
  $status;
}, _int, _ptr, _ptr, _ptr, _int64);

my $myclose = FFI::Raw::Callback->new(sub
{
  my($archive) = @_;
  my $status = eval {
    $callbacks{$archive}->[CB_CLOSE]->($archive, $callbacks{$archive}->[CB_DATA]);
  };
  if($@)
  {
    warn $@;
    return ARCHIVE_FATAL();
  }
  $status;
}, _int, _ptr, _ptr);

my $null = FFI::Raw::MemPtr->new_from_ptr(0);

attach_function 'archive_write_open', [ _ptr, _ptr, _ptr, _ptr, _ptr ], _int, sub
{
  my($cb, $archive, $cd, $open, $write, $close) = @_;
  $callbacks{$archive}->[CB_DATA] = $cd;
  if(defined $open)
  {
    $callbacks{$archive}->[CB_OPEN] = $open;
    $open = $myopen;
  }
  if(defined $write)
  {
    $callbacks{$archive}->[CB_WRITE] = $write;
    $write = $mywrite;
  }
  if(defined $close)
  {
    $callbacks{$archive}->[CB_CLOSE] = $close;
    $close = $myclose;
  }
  my $ret = $cb->($archive, $null, $open||$null, $write||$null, $close||$null);
  print "ret = $ret\n";
  $ret;
};

attach_function 'archive_read_open_memory', [ _ptr, _ptr, _int ], _int, sub # FIXME: third argument is actually a size_t
{
  my($cb, $archive, $buffer) = @_;
  my $length = do { use bytes; length $buffer };
  my $ptr = FFI::Raw::MemPtr->new_from_buf($buffer, $length);
  $callbacks{$archive}->[CB_BUFFER] = $ptr;  # TODO: CB_BUFFER or CB_DATA (or something else?)
  $cb->($archive, $ptr, $length);
};

attach_function 'archive_read_free', [ _ptr ], _int, sub
{
  my($cb, $archive) = @_;
  my $ret = $cb->($archive);
  delete $callbacks{$archive};
  $ret;
};

attach_function 'archive_write_free', [ _ptr ], _int, sub
{
  my($cb, $archive) = @_;
  my $ret = $cb->($archive);
  delete $callbacks{$archive};
  $ret;
};

1;
