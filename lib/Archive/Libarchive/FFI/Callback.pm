package Archive::Libarchive::FFI::Callback;

use strict;
use warnings;

# ABSTRACT: Libarchive callbacks
# VERSION

package
  Archive::Libarchive::FFI;

use FFI::Sweet;
use FFI::Util qw( deref_ptr_set );

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

my $myread = FFI::Raw::Callback->new(sub
{
  my($archive, $null, $optr) = @_;
  my($status, $buffer) = eval {
    $callbacks{$archive}->[CB_READ]->($archive, $callbacks{$archive}->[CB_DATA]);
  };
  if($@)
  {
    warn $@;
    return ARCHIVE_FATAL();
  }
  my($ptr, $size) = scalar_to_buffer($buffer);
  deref_ptr_set($optr, $ptr);
  $size;
}, _uint64, _ptr, _ptr, _ptr);

my $myskip = FFI::Raw::Callback->new(sub
{
  my($archive, $null, $request) = @_;
  my $status = eval {
    $callbacks{$archive}->[CB_SKIP]->($archive, $callbacks{$archive}->[CB_DATA], $request);
  };
  if($@)
  {
    warn $@;
    return ARCHIVE_FATAL();
  }
  $status;
}, _uint64, _ptr, _ptr, _uint64);

my $myseek = FFI::Raw::Callback->new(sub
{
  my($archive, $null, $offset, $whence) = @_;
  my $status = eval {
    $callbacks{$archive}->[CB_SEEK]->($archive, $callbacks{$archive}->[CB_DATA], $offset, $whence);
  };
  if($@)
  {
    warn $@;
    return ARCHIVE_FATAL();
  }
  $status;
}, _uint64, _ptr, _ptr, _uint64, _int);

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
  $cb->($archive, 0, $open||0, $write||0, $close||0);
};

sub archive_read_open ($$$$$)
{
  my($archive, $data, $open, $read, $close) = @_;
  archive_read_open2($archive, $data, $open, $read, undef, $close);
}

attach_function 'archive_read_open2', [ _ptr, _ptr, _ptr, _ptr, _ptr, _ptr ], _int, sub
{
  my($cb, $archive, $cd, $open, $read, $skip, $close) = @_;
  $callbacks{$archive}->[CB_DATA] = $cd;
  if(defined $open)
  {
    $callbacks{$archive}->[CB_OPEN] = $open;
    $open = $myopen;
  }
  if(defined $read)
  {
    $callbacks{$archive}->[CB_READ] = $read;
    $read = $myread;
  }
  if(defined $skip)
  {
    $callbacks{$archive}->[CB_SKIP] = $skip;
    $skip = $myskip;
  }
  if(defined $close)
  {
    $callbacks{$archive}->[CB_CLOSE] = $close;
    $close = $myclose;
  }
  $cb->($archive, 0, $open||0, $read||0, $skip||0, $close||0);
};

sub archive_read_set_callback_data ($$)
{
  my($archive, $data) = @_;
  $callbacks{$archive}->[CB_DATA] = $data;
  ARCHIVE_OK();
}

foreach my $name (qw( open read skip close seek ))
{
  my $const = 'CB_' . uc $name;
  my $wrapper = eval '# line '. __LINE__ . ' "' . __FILE__ . "\n" . qq{
    sub
    {
      my(\$cb, \$archive, \$callback) = \@_;
      \$callbacks{\$archive}->[$const] = \$callback;
      \$cb->(\$archive, \$my$name);
    }
  };die $@ if $@;
  
  attach_function "archive_read_set_$name\_callback", [ _ptr, _ptr ], _int;
}

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

__END__

=head1 SYNOPSIS

 use Archive::Libarchive::FFI qw( :all );
 
 # read
 my $archive = archive_read_new();
 archive_read_open($archive, $data, \&myopen, \&myread, \&myclose);
 
 # write
 my $archive = archive_write_new();
 archive_write_open($archive, $data, \&myopen, \&mywrite, \&myclose);

=head1 DESCRIPTION

This document provides information of callback routines for writing
custom input/output interfaces to the libarchive perl bindings.  The
first two arguments passed into all callbacks are:

=over 4

=item $archive

The archive object (actually a pointer to the C structure that managed
the archive object).

=item $data

The callback data object (any legal Perl data structure).

=back

For the variable name / types conventions used in this document, see
L<Archive::Libarchive::FFI::Function>.

The expected return value for all callbacks EXCEPT the read callback
is a standard integer libarchive status value (example: C<ARCHIVE_OK>
or C<ARCHIVE_FATAL>).

If your callback dies (throws an exception), it will be caught at the
Perl level.  The error will be sent to standard error via L<warn|perlfunc#warn>
and C<ARCHIVE_FATAL> will be passed back to libarchive.

=head2 data

There is a data field for callbacks associated with each $archive object.
It can be any native Perl type (example: scalar, hashref, coderef, etc).
You can set this by calling 
L<archive_read_set_callback_data|Archive::Libarchive::FFI::Function#archive_read_set_callback_data>,
or by passing the data argument when you "open" the archive using
L<archive_read_open|Archive::Libarchive::FFI::Function#archive_read_open>,
L<archive_read_open2|Archive::Libarchive::FFI::Function#archive_read_open2> or
L<archive_write_open|Archive::Libarchive::FFI::Function#archive_write_open>.

The data field will be passed into each callback as its second argument.

=head2 open

 my $status1 = archive_read_set_open_callback($archive, sub {
   my($archive, $data) = @_;
   ...
   return $status2;
 });

According to the libarchive, this is never needed, but you can register
a callback to happen when you open.

Can also be set when you call 
L<archive_read_open|Archive::Libarchive::FFI::Function#archive_read_open>,
L<archive_read_open2|Archive::Libarchive::FFI::Function#archive_read_open2> or
L<archive_write_open|Archive::Libarchive::FFI::Function#archive_write_open>.

=head2 read

 my $status1 = archive_read_set_read_callback($archive, sub {
   my($archive, $data) = @_;
   ...
   return ($status2, $buffer)
 });

This callback is called whenever libarchive is ready for more data to
process.  It doesn't take in any additional arguments, but it expects
two return values, a status and a buffer containing the data.

Can also be set when you call 
L<archive_read_open|Archive::Libarchive::FFI::Function#archive_read_open> or
L<archive_read_open2|Archive::Libarchive::FFI::Function#archive_read_open2>.

=head2 write

 my $mywrite = sub {
   my($archive, $data, $buffer) = @_;
   ...
   return $status1;
 };
 my $status2 = archive_write_open($archive, undef, $mywrite, undef);

This callback is called whenever libarchive has data it wants to send
to output.  The callback itself takes one additional argument, a 
buffer containing the data to write.

=head2 skip

 my $status1 = archive_read_set_skip_callback($archive, sub {
   my($archive, $data, $request) = @_;
   ...
   return $status2;
 });

The skip callback takes one additional argument, $request.

Can also be set when you call 
L<archive_read_open2|Archive::Libarchive::FFI::Function#archive_read_open2>.

=head2 seek

 my $status1 = archive_read_set_seek_callback($archive, sub {
   my($archive, $data, $offset, $whence) = @_;
   ...
   return $status2;
 });

The seek callback should implement an interface identical to the UNIX
C<fseek> function.

=head2 close

 my $status1 = archive_read_set_close_callback($archive, sub {
   my($archive, $data) = @_;
   ...
   return $status2;
 });

Called when the archive (either input or output) should be closed.

Can also be set when you call 
L<archive_read_open|Archive::Libarchive::FFI::Function#archive_read_open>,
L<archive_read_open2|Archive::Libarchive::FFI::Function#archive_read_open2> or
L<archive_write_open|Archive::Libarchive::FFI::Function#archive_write_open>.

=head2 user id lookup

 my $status = archive_write_disk_set_user_lookup($archive, $data, sub {
   my($data, $name, $uid) = @_;
   ... # should return the UID for $name or $uid if it can't be found
 }, undef);

Called by archive_write_disk_uid to determine appropriate UID.

=head2 group id lookup

 my $status = archive_write_disk_set_group_lookup($archive, $data, sub {
   my($data, $name, $gid) = @_;
   ... # should return the GID for $name or $gid if it can't be found
 }, undef);

Called by archive_write_disk_gid to determine appropriate GID.

=head2 user name lookup

 my $status = archive_read_disk_set_uname_lookup($archive, $data, sub 
   my($data, $uid) = @_;
   ... # should return the name for $uid, or undef
 }, undef);

Called by archive_read_disk_uname to determine appropriate user name.

=head2 group name lookup

 my $status = archive_read_disk_set_gname_lookup($archive, $data, sub 
   my($data, $gid) = @_;
   ... # should return the name for $gid, or undef
 }, undef);

Called by archive_read_disk_gname to determine appropriate group name.

=head2 lookup cleanup

 sub mycleanup
 {
   my($data) = @_;
   ... # any cleanup necessary
 }
 
 my $status = archive_write_disk_set_user_lookup($archive, $data, \&mylookup, \&mcleanup);
 
 ...
 
 archive_write_disk_set_user_lookup($archive, undef, undef, undef); # mycleanup will be called here

Called when the lookup is registered (can also be passed into
L<archive_write_disk_set_group_lookup|Archive::Libarchive::FFI::Function#archive_write_disk_set_group_lookup>,
L<archive_read_disk_set_uname_lookup|Archive::Libarchive::FFI::Function#archive_read_disk_set_uname_lookup>,
and
L<archive_read_disk_set_gname_lookup|Archive::Libarchive::FFI::Function#archive_read_disk_set_gname_lookup>.


=head1 SEE ALSO

=over 4

=item L<Archive::Libarchive::FFI>

=item L<Archive::Libarchive::FFI::Constant>

=item L<Archive::Libarchive::FFI::Function>

=back

=cut
