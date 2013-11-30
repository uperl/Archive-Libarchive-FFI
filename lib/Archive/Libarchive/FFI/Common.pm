package Archive::Libarchive::FFI::Common;

use strict;
use warnings;

# ABSTRACT: Libarchive private package
# VERSION

package
  Archive::Libarchive::FFI;

#

sub archive_read_open_fh ($$;$)
{
  my($archive, $fh, $bs) = @_;
  $bs ||= 10240;
  my $data = { bs => $bs, fh => $fh };
  archive_read_open($archive, $data, undef, \&_archive_read_open_fh_read, undef);
}

sub _archive_read_open_fh_read
{
  my($archive, $data) = @_;
  my $br = read $data->{fh}, my $buffer, $data->{bs};
  if(defined $br)
  {
    return (ARCHIVE_OK(), $buffer);
  }
  else
  {
    warn 'read error';
    return ARCHIVE_FAILED();
  }
}

sub archive_write_open_fh ($$)
{
  my($archive, $fh) = @_;
  my $data = { fh => $fh };
  archive_write_open($archive, $data, undef, \&_archive_write_open_fh_write, undef);
}

sub _archive_write_open_fh_write
{
  my($archive, $data, $buffer) = @_;
  $DB::single = 1;
  my $bw = syswrite $data->{fh}, $buffer;
  if(defined $bw)
  {
    return $bw;
  }
  else
  {
    warn 'write error';
    return ARCHIVE_FATAL();
  }
}

1;

=head1 SEE ALSO

=over 4

=item L<Archive::Libarchive::FFI>

=back

=cut
