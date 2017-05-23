use strict;
use warnings;

use RT::Extension::CustomiseMenus::Test tests => undef;

# Load the General Queue
my $queue = RT::Test->load_or_create_queue( Name => 'General' );
ok( $queue->id, "loaded the General queue" );

my ($base, $m) = RT::Test->started_ok;

$m->login;

my $ticket = RT::Test->create_ticket(
    Queue   => $queue->id,
    Subject => 'a test ticket',
);
ok $ticket && $ticket->id, "Created ticket";

# Build Display.html link
my $DisplayUrl = "/Ticket/Display.html?id=" . $ticket->id;

# open ticket "Basics" page
$m->get_ok($DisplayUrl, "Fetched $DisplayUrl");
ok( $m->find_link( text => 'Home' ), 'Home link found' );
ok( $m->find_link( text => 'Customised Menu Foo' ), 'Customised Menu Foo link found' );
ok( !$m->find_link( text => 'Tools' ), 'Tools link not found' );

undef $m;

done_testing;
