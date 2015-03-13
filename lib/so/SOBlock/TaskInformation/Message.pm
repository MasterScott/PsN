package so::SOBlock::TaskInformation::Message;

use strict;
use warnings;
use Moose;
use MooseX::Params::Validate;
use include_modules;
use XML::LibXML;

has 'type' => ( is => 'rw', isa => 'Str' );
has 'Toolname' => ( is => 'rw', isa => 'Str' );
has 'Name' => ( is => 'rw', isa => 'Str' );
has 'Content' => ( is => 'rw', isa => 'Str' );
has 'Severity' => ( is => 'rw', isa => 'Int' );

sub xml
{
    my $self = shift;

    my $message = XML::LibXML::Element->new("Message");
    $message->setAttribute('type', $self->type);

    my $toolname = XML::LibXML::Element->new("Toolname");
    my $tool_str = XML::LibXML::Element->new("ct:String");
    $tool_str->appendTextNode($self->Toolname);
    $toolname->appendChild($tool_str);

    my $name = XML::LibXML::Element->new("Name");
    my $name_str = XML::LibXML::Element->new("ct:String");
    $name_str->appendTextNode($self->Name);
    $name->appendChild($name_str);

    my $content = XML::LibXML::Element->new("Content");
    my $content_str = XML::LibXML::Element->new("ct:String");
    $content_str->appendTextNode($self->Content);
    $content->appendChild($content_str);

    my $severity = XML::LibXML::Element->new("Severity");
    my $severity_str = XML::LibXML::Element->new("ct:Int");
    $severity_str->appendTextNode($self->Severity);
    $severity->appendChild($severity_str);

    $message->appendChild($toolname);
    $message->appendChild($name);
    $message->appendChild($content);
    $message->appendChild($severity);

    return $message;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
