#!/usr/bin/ruby

require 'rubygems'
require 'exifr'
require 'date'
require 'test/unit'
require 'mocha'

require 'rnimg'

class RenameImageTests < Test::Unit::TestCase
    def test_JpegFileShouldCallRenameOnce
        dir = mock()
        file = mock()
        exifr = mock()
        exifobj = mock()

        jpgFile = '/home/ahj/file.jpg'
        modified = DateTime.new(2008, 2, 27, 10, 55, 12)

        file.expects(:directory?).with('/home/ahj/file.jpg').returns(false)
        exifr.expects(:new).with(jpgFile).returns(exifobj)
        exifobj.expects(:date_time).returns(modified)
        file.expects(:dirname).with(jpgFile).returns('/home/ahj')
        file.expects(:join).with('/home/ahj', '20080227_105512.jpg').returns('/home/ahj/20080227_105512.jpg')
        file.expects(:rename).with(jpgFile,'/home/ahj/20080227_105512.jpg')

        renamer = Rnimg.new(file, exifr, dir)
        renamer.rename(jpgFile)
    end

    def test_TwoJpegFilesShouldCallRenameTwice
        dir = mock()
        file = mock()
        exifr = mock()
        exifobj1 = mock()
        exifobj2 = mock()


        jpgFiles = ['/home/ahj/file.jpg', '/home/ahj/file2.jpg']
        mod1 = DateTime.new(2001, 01, 01, 01, 01, 12)
        mod2 = DateTime.new(2002, 02, 02, 02, 02, 12)

        file.expects(:directory?).with('/home/ahj/file.jpg').returns(false)
        file.expects(:directory?).with('/home/ahj/file2.jpg').returns(false)

        exifr.expects(:new).with(jpgFiles[0]).returns(exifobj1)
        exifr.expects(:new).with(jpgFiles[1]).returns(exifobj2)

        exifobj1.expects(:date_time).returns(mod1)
        exifobj2.expects(:date_time).returns(mod2)

        file.expects(:dirname).with(jpgFiles[0]).returns('/home/ahj0')
        file.expects(:dirname).with(jpgFiles[1]).returns('/home/ahj1')

        file.expects(:join).with('/home/ahj0', '20010101_010112.jpg').returns('/home/ahj0/20010101_010112.jpg')
        file.expects(:join).with('/home/ahj1', '20020202_020212.jpg').returns('/home/ahj1/20020202_020212.jpg')

        file.expects(:rename).with(jpgFiles[0],'/home/ahj0/20010101_010112.jpg')
        file.expects(:rename).with(jpgFiles[1],'/home/ahj1/20020202_020212.jpg')
        
        renamer = Rnimg.new(file, exifr)
        renamer.rename(*jpgFiles)
    end

    def test_FolderShouldRenameEachFileInIt
        dir = mock()
        file = mock()
        exifr = mock()
        exifobj = mock()

        file.expects(:directory?).with('/home/ahj').returns(true)
        file.expects(:directory?).with('/home/ahj/file.jpg').returns(false)
        dir.expects(:entries).with('/home/ahj').returns(['.', '..', 'file.jpg'])
        file.expects(:join).with('/home/ahj', 'file.jpg').returns('/home/ahj/file.jpg')

        jpgDir = '/home/ahj'
        jpgFile = '/home/ahj/file.jpg'

        modified = DateTime.new(2009, 1, 23, 22, 40, 12)
        exifr.expects(:new).with(jpgFile).returns(exifobj)
        exifobj.expects(:date_time).with().returns(modified)
        file.expects(:dirname).with(jpgFile).returns('/home/ahj')
        file.expects(:join).with('/home/ahj', '20090123_224012.jpg').returns('/home/ahj/20090123_224012.jpg')
        file.expects(:rename).with(jpgFile,'/home/ahj/20090123_224012.jpg')

        renamer = Rnimg.new(file, exifr, dir)
        renamer.rename(jpgDir)
    end

    def test_fileIsntJpgShouldDoNoting
        dir = mock()
        file = mock()
        exifr = mock()
        exifobj = mock()

        jpgFile = '/home/ahj/file.jpg'
        modified = DateTime.new(2008, 2, 27, 10, 55, 12)

        file.expects(:directory?).with('/home/ahj/file.jpg').returns(false)
        exifr.expects(:new).with(jpgFile).raises(RuntimeError)

        renamer = Rnimg.new(file, exifr, dir)
        renamer.rename(jpgFile)

    end
end
