use strict;
use warnings;

use File::Temp qw/tempfile/;
use Test::More tests => 5;

my ($fh, $conffile)=tempfile(UNLINK => 0);

my $conf = <<'CONF';
from: admin@example.net
realm: example.net
subject: Your account on example.net
bcc: bcc@example.net
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

system("./gemapass -c $conffile -u michel");

ok(-e 'htpasswd.out');

open HTOUT, 'htpasswd.out' or die 'Cannot open htpasswd.out';
my @htpass = <HTOUT>;
is(scalar @htpass, 1, 'htpasswd.out has only one line');
close HTOUT or die 'Cannot close htpasswd.out';

ok(-d 'mail.out');
ok(-e 'mail.out/michel.mail');
ok(not (-e 'mail.out/joe.mail'));

unlink 'mail.out/michel.mail';
unlink 'mail.out/joe.mail';
rmdir  'mail.out';
unlink 'htpasswd.out';
unlink $conffile;
