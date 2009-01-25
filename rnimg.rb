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
        map = getFilesToRename(*paths)
        makeNewNamesUnique!(map)
        renameFiles(map)
    end

    private
    def formatDate(date)
        "#{date.strftime('%Y%m%d_%H%M%S')}.jpg"
    end

    def getFilesToRename(*paths)
        renameMap = Hash.new
        paths.each do |path|
            if @file.directory? path then 
                @dir.entries(path).each { |file|
                    unless file =~ /^(\.|\.\.)/ then
                        joinedPath = @file.join(path, file)
                        filesToRename = getFilesToRename(joinedPath)
                        renameMap.merge!(filesToRename)
                    end
                }
            else
                begin
                    modified = @exif.new(path).date_time
                rescue RuntimeError
                else
                    newName = @file.join(@file.dirname(path), formatDate(modified))
                    renameMap[path] = newName
                end
            end
        end
        renameMap
    end

    def makeNewNamesUnique!(map)
        inverted = {}
        map.each {|old, new|
            inverted[new] = inverted[new] || []
            inverted[new] << old
        }
        map.clear
        inverted.each {|newName, oldNames|
            if oldNames.count == 1 then map[oldNames[0]] = newName; next end
            oldNames.sort!

            newName =~ /^(.*)\.(.*)$/
            match = Regexp.last_match
            file, extension = match[1,2]

            postfixValue = 1
            oldNames.each { |oldName|
               map[oldName] = "%s_%02d.%s" % [file, postfixValue, extension]
                postfixValue += 1
            }
        }
    end

    def renameFiles(map)
       map.each {|old, new|
            @file.rename(old, new)
        } 
    end
end

