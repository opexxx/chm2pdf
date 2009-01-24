#!/usr/bin/env ruby
#
# chm2pdf.rb -- Convert CHM to PDF files.
#
# (Requires chmlib and htmldoc installed.)
#
# Copyright 2008-2009 Stateful Labs <mark@stateful.net>
# All rights reserved.

require 'fileutils'
require 'tempfile'

VER = '1.0'

chm_bin = `which extract_chmLib`.gsub("\n","")
pdf_bin = `which htmldoc`.gsub("\n","")

def banner
	puts "chm2pdf #{VER}"
	puts "Copyright (c) 2008-2009, Stateful Labs. All rights reserved."
end

def help
  puts "\nusage: #{__FILE__} chm_file pdf_file"
end

if ARGV.empty?
	banner
  help
  exit
else
  target = ARGV.join( ' ' )
  banner
	puts "\nConverting #{ARGV[0]} to #{ARGV[1]}..."
end

chm_file = ARGV[0]
pdf_file = ARGV[1]
seed = Time.now.to_i
tmpdir = "/tmp/chm2pdf-#{seed}"
Dir.mkdir(tmpdir)

# Unpack chm file to a temporary directory
%x{#{chm_bin} "#{chm_file}" #{tmpdir}}

# Find the HHC file since there is no predefined filename, just extension,
# and there's only one of them.
files = Array.new
files = Dir.entries(tmpdir)
hhc_file = ""
files.each {
  |filename| hhc_file = "#{tmpdir}/#{filename}" if filename =~ /.hhc/
}

# Dynamically generate the list of pages for htmldoc from the
# scraped CHM sitemap.
stuff = IO.readlines("#{hhc_file}")
hits=""
stuff.each {
  |line| hits += "\"#{tmpdir}/" + \
    "#{line}".gsub(/.*value\=\"(.*)\"\>/, '\1').chop + "\" " \
    if line =~ /name\=\"Local\"/
}

# Create the PDF
%x{#{pdf_bin} --webpage -f "#{pdf_file}" #{hits}}

# Cleanup
FileUtils.remove_entry_secure(tmpdir)
