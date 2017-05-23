use strict;
use warnings;
package RT::Extension::CustomiseMenus;

our $VERSION = '0.01';

=head1 NAME

RT-Extension-CustomiseMenus - enables easy modification of RT menus

=head1 DESCRIPTION

This extension for RT allows a administrator to easily add/remove/rename
the RT menus.

=head1 RT VERSION

Works with RT 4.4

=head1 INSTALLATION

=over

=item C<perl Makefile.PL>

=item C<make>

=item C<make install>

May need root permissions

=item Edit your F</opt/rt4/etc/RT_SiteConfig.pm>

Adding this line:

    Plugin('RT::Extension::CustomiseMenus');

=item Clear your mason cache

    rm -rf /opt/rt4/var/mason_data/obj

=item Restart your webserver

=back

=head1 CONFIGURATION

A RT menu can be manipluated by adding a simple configuration
array of hashes as shown below:

    Set($PrivilegedMenus, [
                {
                        'id'     => 'corporate',
                        'action' => 'add',
                        'path'   => 'http://bestpractical.com',
                        'title'  => 'Corporate',
                        'menu'   => 'main',
                        'after'  => 'home',
                },
                {
                        'id'     => 'wiki',
                        'action' => 'add',
                        'path'   => 'http://wiki.bestpractical.com',
                        'title'  => 'Wiki',
                        'menu'   => 'main',
                        'parent' => 'corporate',
                },
                {
                        'id'     => 'newitem',
                        'action' => 'add',
                        'path'   => '/new/thing/here',
                        'title'  => 'New Action',
                        'menu'   => 'tabs',
                        'parent' => 'actions',
                },
                {
                        'id'     => 'tools',
                        'action' => 'remove',
                        'menu'   => 'main',
                },
    ]);

    Set($SelfServiceMenus, [

    ]);

=head1 AUTHOR

Martin Wheldon E<lt>martin.wheldon@greenhills-it.co.ukE<gt>

=head1 BUGS

All bugs should be reported via email to

    L<bug-RT-Extension-CustomiseMenus@greenhills-it.co.uk|mailto:bug-RT-Extension-CustomiseMenus@greenhills-it.co.uk>

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2017 by Greenhills IT Ltd.

This is free software, licensed under:

  The GNU General Public License, Version 2, June 1991

=cut

use Exporter 'import';

our @EXPORT = qw/ add_menu_item remove_menu_item /;

sub load_menu
{
    my ($config) = shift;

    my $menu = {};

    # Load the appropriate submenu
    if (exists $config->{parent}) {
        my $parent = $config->{parent};

        $menu = HTML::Mason::Commands::Menu()->child($parent) if $config->{menu} eq "main";
        $menu = HTML::Mason::Commands::PageMenu()->child($parent) if $config->{menu} eq "tabs";
    }
    # Load the appropriate root menu
    else {
        $menu = HTML::Mason::Commands::Menu() if $config->{menu} eq "main";
        $menu = HTML::Mason::Commands::PageMenu() if $config->{menu} eq "tabs";
    }

    return $menu;

}

sub add_menu_item
{
    my ($config) = shift;

    my $id = $config->{id};
    my $menu = &load_menu($config);

    # FIXME: Could be add permissions here???
    #        was thinking of adding those to the anonymous hash
    # If we have a valid menu object then try to add the new menu item
    if ($menu) {
        if ( not $menu->child($id,
                                title   => HTML::Mason::Commands::loc($config->{title}),
                                path    => HTML::Mason::Commands::loc($config->{path}),
                                )) {
            $RT::Logger->error("Failed to add menu item $id");
        }
    }
    else {
        $RT::Logger->error("Failed to load parent menu of item $id");
    }

}

sub remove_menu_item
{
    my ($config) = shift;

    my $id = $config->{id};
    my $menu = &load_menu($config);

    # If we have a valid menu object then try to delete the menu item
    if ($menu) {
        if (not $menu->delete($id)) {
            $RT::Logger->error("Failed to remove menu item $id");
        }
    }
    else {
        $RT::Logger->error("Failed to load parent menu of item $id");
    }

}

1;
