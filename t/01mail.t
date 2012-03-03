use strict;
use warnings;
use Digest::MD5 qw/md5_hex/;
use File::Temp qw/tempfile/;
use Test::More tests => 5;

my ($fh, $conffile)=tempfile(UNLINK => 0);

my $conf = <<'CONF';
from: admin@example.net
realm: example.net
subject: Your account on example.net
template: |
    Hello [% fullname %], here are your credentials on [% realm %] :

    Username : [% username %]
    Password : [% password %]
users:
  michel:
    fullname: 'Michel Demichel'
    email: 'michel.demichel@example.net'
  joe:
    fullname: 'Joe Lagachette'
    email: 'joe.lagachette@example.net'
CONF

print $fh $conf;
close $fh or die "Cannot close $conffile";

system("./gemapass -c $conffile");

ok(-e 'htpasswd.out');
ok(-d 'mail.out');
ok(-e 'mail.out/michel.mail');
ok(-e 'mail.out/joe.mail');

open HTPASSWD, 'htpasswd.out';
my $joeline = (grep /joe/, <HTPASSWD>)[0];
$joeline =~ /^joe:example\.net:([a-fA-F0-9]+)/
  or die 'Parse error';
my $md5 = $1;
close HTPASSWD;

open JOEMAIL, 'mail.out/joe.mail';
my $passline= (grep /Password : /,<JOEMAIL>)[0];
$passline =~ /^Password : (\w+)$/
  or die 'Parse error';
my $pass = $1;
close JOEMAIL;

is ($md5, md5_hex("joe:example.net:$pass"), 'MD5 match');

unlink 'mail.out/joe.mail';
unlink 'mail.out/michel.mail';
rmdir  'mail.out';
unlink 'htpasswd.out';

unlink $conffile;
