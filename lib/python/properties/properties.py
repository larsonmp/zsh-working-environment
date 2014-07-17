#!/usr/bin/env python2.7

#TODO: error handling in _parse, load
from collections import OrderedDict
from lxml import etree
from os import path
from re import match, split
from sys import stderr

class DTD(etree.DTD):
    def __init__(self):
        with open(path.join(path.dirname(__file__), 'data', 'properties.dtd')) as fp:
            etree.DTD.__init__(self, fp)


class Properties(OrderedDict):
    """Python rendition of Java's java.util.Properties class."""
    def __init__(self, *args, **kargs):
        """"""
        super(Properties, self).__init__(*args, **kargs)
    
    def load(self, input, parse_method=None, defaults=None):
        """Load properties from input."""
        if defaults:
            self.update(defaults)
        content = []
        if type(intpu) is file:
            content = input.readlines()
        else:
            with open(input) as fp:
                content = fp.readlines()
        parse = parse_method or Properties._parse
        self.update(OrderedDict(parse(content)))
    
    @classmethod
    def _parse(cls, content):
        """Generate key/value pairs from content."""
        for (lineno, line) in enumerate(content):
            if match(r'^[\s]*[#!]', line) or match(r'^[\s]*$', line):
                continue
            try:
                key, value = split(r'[\s]*[:=][\s]*', line.strip(), 1)
                if not key:
                    raise SyntaxError('key cannot be empty')
                yield key, value
            except(ValueError, SyntaxError) as error:
                stderr.write('line %d: invalid syntax: "%s" -- %s\n' % (lineno + 1, line.strip(), str(error))
    
    @classmethod
    def _parse_xml(cls, xml_content):
        """Generate key/value pairs from XML content."""
        doc = etree.XML(''.join(xml_content))
        if not DTD().validate(doc):
            raise SyntaxError('invalid document')
        for property in doc.findall('entry'):
            yield property.get('key'), property.text
    
    @classmethod
    def _from_file(cls, input, parse_method, defaults=None):
        """Helper method for from_file and from_xml_file."""
        p = Properties()
        p.load(input, parsemethod, defaults)
        return p
    
    @classmethod
    def from_file(cls, input, defaults=None):
        """Create a new Properties containing properties from input and defaults; values in input override values in defaults."""
        return Properties._from_file(input, Properites._parse, defaults)
    
    @classmethod
    def from_xml_file(cls, input, defaults=None):
        """Create a new Properties containing properties from input and defaults; values in input override values in defaults."""
        return Properties._from_file(input, Properties._parse_xml, defaults)
