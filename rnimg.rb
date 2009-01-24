#!/usr/bin/ruby -w

require 'rubygems'
require 'exifr'
require 'date'

class Rnimg
    def initialize(file = File, exif = EXIFR::JPEG, dir = Dir)
        @file = file
        @exif = exif
        @dir = dir
    end

    def rename(*paths)
        paths.each do |path|
            if @file.directory? path then 
                @dir.entries(path).each { |file|
                    rename(@file.join(path, file)) unless file =~ /^(\.|\.\.)/
                }
            else
                begin
                    modified = @exif.new(path).date_time
                rescue RuntimeError
                else
                    newName = @file.join(@file.dirname(path), formatDate(modified))
                    @file.rename(path, newName)
                end
            end
        end
    end

    private
    def formatDate(date)
        "#{date.strftime('%Y%m%d_%H%M%S')}.jpg"
    end
end

