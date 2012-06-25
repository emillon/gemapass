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

my $gemout = qx#./gemapass -c $conffile -E -u michel#;

is($?, 0, "gemapass could be run with -E");
ok(not (-e 'htpasswd.out'));
ok(not (-f 'mail.out'));

my $expected_re = 
    qr/
    Hello\ Michel\ Demichel,\ here\ are\ your\ credentials\ on\ example.net\ :\n
    \n
    Username\ :\ michel\n
    Password\ :\ \w+
    /x;

like ($gemout, qr/^michel:example.net:[a-z\d]{32}\n/, 'Output contains htpasswd line');
like ($gemout, $expected_re, 'Output conforms to expected_re');

unlink $conffile;
