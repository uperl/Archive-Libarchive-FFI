package Archive::Libarchive::FFI::Common;

use strict;
use warnings;

# ABSTRACT: Libarchive private package
# VERSION

package
  Archive::Libarchive::FFI;

use Encode qw( encode decode );

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

sub archive_version_string {
  decode(archive_perl_codeset(), _archive_version_string());
}
sub archive_format_name {
  decode(archive_perl_codeset(), _archive_format_name($_[0], ));
}
sub archive_error_string {
  decode(archive_perl_codeset(), _archive_error_string($_[0], ));
}
sub archive_read_open_filename {
  _archive_read_open_filename($_[0], encode(archive_perl_codeset(), $_[1]), $_[2], );
}
sub archive_read_support_filter_program {
  _archive_read_support_filter_program($_[0], encode(archive_perl_codeset(), $_[1]), );
}
sub archive_read_set_filter_option {
  _archive_read_set_filter_option($_[0], encode(archive_perl_codeset(), $_[1]), encode(archive_perl_codeset(), $_[2]), encode(archive_perl_codeset(), $_[3]), );
}
sub archive_read_set_format_option {
  _archive_read_set_format_option($_[0], encode(archive_perl_codeset(), $_[1]), encode(archive_perl_codeset(), $_[2]), encode(archive_perl_codeset(), $_[3]), );
}
sub archive_read_set_option {
  _archive_read_set_option($_[0], encode(archive_perl_codeset(), $_[1]), encode(archive_perl_codeset(), $_[2]), encode(archive_perl_codeset(), $_[3]), );
}
sub archive_read_set_options {
  _archive_read_set_options($_[0], encode(archive_perl_codeset(), $_[1]), );
}
sub archive_read_set_format {
  _archive_read_set_format($_[0], encode(archive_perl_codeset(), $_[1]), encode(archive_perl_codeset(), $_[2]), encode(archive_perl_codeset(), $_[3]), );
}
sub archive_filter_name {
  decode(archive_perl_codeset(), _archive_filter_name($_[0], $_[1], ));
}
sub archive_write_add_filter_by_name {
  _archive_write_add_filter_by_name($_[0], encode(archive_perl_codeset(), $_[1]), );
}
sub archive_write_add_filter_program {
  _archive_write_add_filter_program($_[0], encode(archive_perl_codeset(), $_[1]), );
}
sub archive_write_set_format_by_name {
  _archive_write_set_format_by_name($_[0], encode(archive_perl_codeset(), $_[1]), );
}
sub archive_write_open_filename {
  _archive_write_open_filename($_[0], encode(archive_perl_codeset(), $_[1]), );
}
sub archive_write_set_filter_option {
  _archive_write_set_filter_option($_[0], encode(archive_perl_codeset(), $_[1]), encode(archive_perl_codeset(), $_[2]), encode(archive_perl_codeset(), $_[3]), );
}
sub archive_write_set_format_option {
  _archive_write_set_format_option($_[0], encode(archive_perl_codeset(), $_[1]), encode(archive_perl_codeset(), $_[2]), encode(archive_perl_codeset(), $_[3]), );
}
sub archive_write_set_option {
  _archive_write_set_option($_[0], encode(archive_perl_codeset(), $_[1]), encode(archive_perl_codeset(), $_[2]), encode(archive_perl_codeset(), $_[3]), );
}
sub archive_write_set_options {
  _archive_write_set_options($_[0], encode(archive_perl_codeset(), $_[1]), );
}
sub archive_write_disk_gid {
  _archive_write_disk_gid($_[0], encode(archive_perl_codeset(), $_[1]), $_[2], );
}
sub archive_write_disk_uid {
  _archive_write_disk_uid($_[0], encode(archive_perl_codeset(), $_[1]), $_[2], );
}
sub archive_entry_fflags_text {
  decode(archive_perl_codeset(), _archive_entry_fflags_text($_[0], ));
}
sub archive_read_disk_open {
  _archive_read_disk_open($_[0], encode(archive_perl_codeset(), $_[1]), );
}
sub archive_read_disk_gname {
  decode(archive_perl_codeset(), _archive_read_disk_gname($_[0], $_[1], ));
}
sub archive_read_disk_uname {
  decode(archive_perl_codeset(), _archive_read_disk_uname($_[0], $_[1], ));
}
sub archive_entry_acl_add_entry {
  _archive_entry_acl_add_entry($_[0], $_[1], $_[2], $_[3], $_[4], encode(archive_perl_codeset(), $_[5]), );
}
sub archive_entry_acl_text {
  decode(archive_perl_codeset(), _archive_entry_acl_text($_[0], $_[1], ));
}

1;

=head1 SEE ALSO

=over 4

=item L<Archive::Libarchive::FFI>

=back

=cut
