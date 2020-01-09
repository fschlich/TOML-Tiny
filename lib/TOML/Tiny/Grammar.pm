package TOML::Tiny::Grammar;

use strict;
use warnings;

use parent 'Exporter';

our @EXPORT = qw(
  $TOML
);

our $TOML = qr{

(?(DEFINE)
  #-----------------------------------------------------------------------------
  # Misc
  #-----------------------------------------------------------------------------
  (?<Value>
      (?&Boolean)
    | (?&DateTime)
    | (?&Float)
    | (?&Integer)
    | (?&String)
    | (?&Array)
    | (?&InlineTable)
  )

  (?<NLSeq> \x0A | (?: \x0D \x0A))
  (?<NL> (?&NLSeq) | (?&Comment))

  (?<WSChar> [ \x20 \x09 ])       # (space, tab)
  (?<WS> (?&WSChar)*)

  (?<Comment> \x23 .* (?&NLSeq))

  #-----------------------------------------------------------------------------
  # Array of tables
  #-----------------------------------------------------------------------------
  (?<ArrayOfTables>
    (?m)
    (?s)

    \[\[ (?&Key) \]\] \n
    (?:
        (?: (?&KeyValuePair) \n )
      | (?&ArrayOfTables)
      | (?&Table)
    )*

    (?-s)
    (?-m)
  )

  #-----------------------------------------------------------------------------
  # Table
  #-----------------------------------------------------------------------------
  (?<KeyValuePair> (?&Key) (?&WS) = (?&WS) (?&Value))
  (?<KeyValuePairDecl> (?&Key) (?&WS) = (?&WS) (?&Value) (?&WS) (?&NL))

  (?<InlineTableSep>
    (?&WS)
    [,]
    (?&WS)
    (?&NLSeq)?
    (?&WS)
  )

  (?<KeyValuePairList>
      (?&KeyValuePair) (?&InlineTableSep) (?&KeyValuePairList)?
    | (?&KeyValuePair)
  )

  (?<InlineTable>
    (?s)

    {
      (?&WS) (?&NLSeq)? (?&WS)

      (?&KeyValuePairList)

      (?&WS) (?&NLSeq)? (?&WS)
    }

    (?-s)
  )

  (?<TableDecl>
    \[ (?&Key) \] \n
  )

  (?<Table>
    (?&TableDecl)
    (?:
        (?&KeyValuePairDecl)
      | (?&ArrayOfTables)
    )*
  )

  #-----------------------------------------------------------------------------
  # Array
  #-----------------------------------------------------------------------------
  (?<ListSep>
    (?&WS)
    [,]
    (?&WS)
    (?&NLSeq)?
    (?&WS)
  )

  (?<List>
      (?&Value) (?&ListSep) (?&List)?
    | (?&Value)
  )

  (?<Array>
    \[

    (?&WS) (?&NLSeq)? (?&WS)

    (?&List)

    (?&WS) (?&NLSeq)? (?&WS)

    \]
  )

  #-----------------------------------------------------------------------------
  # Key
  #-----------------------------------------------------------------------------
  (?<BareKey> [-_a-zA-Z0-9]+)
  (?<QuotedKey> (?&BasicString) | (?&StringLiteral))
  (?<DottedKey>
    (?: (?&BareKey) | (?&QuotedKey) )
    (?: (?&WS) [.] (?&WS) (?: (?&BareKey) | (?&QuotedKey) ) )+
  )
  (?<Key> (?&DottedKey) | (?&BareKey) | (?&QuotedKey) )

  #-----------------------------------------------------------------------------
  # Boolean
  #-----------------------------------------------------------------------------
  (?<Boolean> \b(?:true)|(?:false))\b

  #-----------------------------------------------------------------------------
  # Integer
  #-----------------------------------------------------------------------------
  (?<Dec> [-+]? [_0-9]+)
  (?<Hex> 0x[_0-9a-fA-F]+)
  (?<Oct> 0o[_0-7]+)
  (?<Bin> 0b[_01]+)
  (?<Integer> (?&Hex) | (?&Oct) | (?&Bin) | (?&Dec))

  #-----------------------------------------------------------------------------
  # Float
  #-----------------------------------------------------------------------------
  (?<Exponent> [eE] (?&Dec))
  (?<SpecialFloat> [-+]?  (?:inf) | (?:nan))
  (?<Fraction> [.] [_0-9]+)

  (?<Float>
    (?:
        (?: (?&Dec) (?&Fraction) (?&Exponent) )
      | (?: (?&Dec) (?&Exponent) )
      | (?: (?&Dec) (?&Fraction) )
    )
    |
    (?&SpecialFloat)
  )

  #-----------------------------------------------------------------------------
  # String
  #-----------------------------------------------------------------------------
  (?<EscapeChar>
    \x5C                        # leading \
    (?:
        [\x5C/"btnfr]           # escapes: \\ \/ \b \t \n \f \r
      | (?: u [_0-9a-fA-F]{4} ) # unicode (4 bytes)
      | (?: U [_0-9a-fA-F]{8} ) # unicode (8 bytes)
    )
  )

  (?<StringLiteral>
    (?: ' [^']* ')            # single quoted string (no escaped chars allowed)
  )

  (?<MultiLineStringLiteral>
    (?m)
    (?s)
    '''                       # opening triple-quote
    .*?
    '''                       # closing triple-quote
    (?-s)
    (?-m)
  )

  (?<BasicString>
    (?:
      "                       # opening quote
      (?:                     # escape sequences or any char except " or \
          (?: (?&EscapeChar) )
        | [^"\\]
      )*
      "                       # closing quote
    )
  )

  (?<MultiLineString>
    (?s)
    """                       # opening triple-quote
    (?:
      (?: (?&EscapeChar) )    # escaped char
      | .
    )*?
    """                       # closing triple-quote
    (?-s)
  )

  (?<String>
      (?&MultiLineString)
    | (?&BasicString)
    | (?&MultiLineStringLiteral)
    | (?&StringLiteral)
  )

  #-----------------------------------------------------------------------------
  # Dates (RFC 3339)
  #   1985-04-12T23:20:50.52Z
  #-----------------------------------------------------------------------------
  (?<Date> \d{4}-\d{2}-\d{2})

  (?<Offset>
      (?: [-+] \d{2}:\d{2} )
    | [Z]
  )

  (?<SimpleTime>
    \d{2}:\d{2}:\d{2}
    (?: [.] \d+ )?
  )

  (?<Time>
    (?&SimpleTime)
    (?&Offset)?
  )

  (?<DateTime>
      (?: (?&Date) [T ] (?&Time) )
    | (?&Date)
    | (?&Time)
  )
)

}x;

1;
