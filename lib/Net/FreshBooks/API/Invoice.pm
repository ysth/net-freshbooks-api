package Net::FreshBooks::API::Invoice;
use base 'Net::FreshBooks::API::Base';

use strict;
use warnings;

use Net::FreshBooks::API::InvoiceLine;
use Net::FreshBooks::API::Links;

__PACKAGE__->mk_accessors( __PACKAGE__->field_names );

sub fields {
    return {
        invoice_id => { mutable => 0, },
        client_id  => { mutable => 1, },

        number             => { mutable => 1, },
        amount             => { mutable => 0, },
        amount_outstanding => { mutable => 0, },
        status             => { mutable => 1, },
        date               => { mutable => 1, },
        po_number          => { mutable => 1, },
        discount           => { mutable => 1, },
        notes              => { mutable => 1, },
        terms              => { mutable => 1, },

        links => {
            mutable      => 0,
            made_of      => 'Net::FreshBooks::API::Links',
            presented_as => 'single',
        },

        recurring_id => { mutable => 0, },

        organization => { mutable => 1, },
        first_name   => { mutable => 1, },
        last_name    => { mutable => 1, },
        p_street1    => { mutable => 1, },
        p_street2    => { mutable => 1, },
        p_city       => { mutable => 1, },
        p_state      => { mutable => 1, },
        p_country    => { mutable => 1, },
        p_code       => { mutable => 1, },

        lines => {
            mutable      => 1,
            made_of      => 'Net::FreshBooks::API::InvoiceLine',
            presented_as => 'array',
        },
    };
}

=head2 add_line

    my $bool = $invoice->add_line(
        {   name         => "Yard Work",          # (Optional)
            description  => "Mowed the lawn.",    # (Optional)
            unit_cost    => 10,                   # Default is 0
            quantity     => 4,                    # Default is 0
            tax1_name    => "GST",                # (Optional)
            tax2_name    => "PST",                # (Optional)
            tax1_percent => 8,                    # (Optional)
            tax2_percent => 6,                    # (Optional)
        }
    );

Create a new L<Net::FreshBooks::API::InvoiceLine> object and add it to the end
of the list of lines.

=cut

sub add_line {
    my $self      = shift;
    my $line_args = shift;

    push @{ $self->{lines} ||= [] },
        Net::FreshBooks::API::InvoiceLine->new($line_args);

    return 1;
}

=head2 send_by_email, send_by_snail_mail

  my $result = $self->send_by_email();
  my $result = $self->send_by_snail_mail();

Send the invoice either by email or by snail mail.

=cut

sub send_by_email {
    my $self = shift;
    $self->_send_using('sendByEmail');
}

sub send_by_snail_mail {
    my $self = shift;
    $self->_send_using('sendBySnailMail');
}

sub _send_using {
    my $self = shift;
    my $how  = shift;

    my $method   = $self->method_string($how);
    my $id_field = $self->id_field;

    my $res = $self->send_request(
        {   _method   => $method,
            $id_field => $self->$id_field,
        }
    );
    
    # refetch the invoice so that the flags are updated.
    $self->get({ invoice_id => $self->invoice_id });

    return 1;
}

1;