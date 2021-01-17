# This file extends the Kernel's require function and adds the
# AutoReload module which allows to reload files once they have changed
# on the disk.
#
# Basically, you just require your files as usual, and if you want to update
# the files, either call AutoReload.reload(file) or AutoReload.reload_all.
#
# Usage:
#   irb -rautoload
#
# Then type 'reload' on the prompt to reload require'd files which have
# changed in the meantime.
#
# Written by Mikio L. Braun, March 16, 2008, edited Jan 15, 2010
# https://gist.githubusercontent.com/mikiobraun/278117/raw/a1359417a3ad6e6f8492e84230a660313ba916ac/autoreload.rb

# dcrosby: I'm plunking this down inside my Cedar framework but not namespacing it beneath Cedar::

require "pp"
require "set"

# This module tracks loaded files and their timestamps and allows to reload
# files which have changed automatically by calling reload.
module AutoReload
  # stores the normalized filenames and their File.mtime timestamps
  @timestamps = Hash.new
  @notfound = Set.new
  @verbose = false
  @prefix = nil

  def self.verbose=(flag)
    @verbose = flag
  end

  def self.path_prefix=(prefix)
    @prefix = prefix
  end

  # find the full path to a file
  def self.locate(file)
    return nil if @notfound.include? file
    $:.each do |dir|
      fullpath = File.join(dir, file)
      if File.exist?(fullpath) && !File.directory?(fullpath)
        return fullpath
      elsif File.exist?(fullpath + ".rb")
        return fullpath + ".rb"
      elsif File.exist?(fullpath + ".so")
        return fullpath + ".so"
      end
    end
    # puts "[AutoReload] File #{file} not found!"
    @notfound.add file
    return nil
  end

  # store the time stamp of a file
  def self.timestamp(file)
    path = locate(file)
    if path
      file = normalize(path, file)
      @timestamps[file] = File.mtime(path)
    end
  end

  # put the extension on a filename
  def self.normalize(path, file)
    if File.extname(file) == ""
      return file + File.extname(path)
    else
      return file
    end
  end

  # show all stored files and their timestamp
  def self.dump
    pp @timestamps
  end

  # reload a file
  def self.reload(file, force = false)
    path = locate(file)
    file = normalize(path, file)
    # puts "reload path=#{path} file=#{file} force=#{force} File.mtime()=#{File.mtime(path)} tstamp=#{@timestamps[file]}"
    # puts "  #{force or (path and File.mtime(path) > @timestamps[file])}"

    current_mtime = File.mtime(path)

    if force or (path and current_mtime > @timestamps[file])
      # Old: (doesn't work in modern ruby?)
      # delete file from list of loaded modules, and reload
      # $".delete file
      # require file
      # New: (dcrosby 2020-12-24)
      verbose_was = $VERBOSE
      begin
        $VERBOSE = nil # suppress constant initialization warnings
        load file
        @timestamps[file] = current_mtime # dcrosby 2020-12-24: need to keep this updated
        puts "[AutoReload] OK: autoreload #{file}" if @verbose
        return true
      rescue Exception => e
        puts "[AutoReload] FAIL: autoreload #{file} - #{e}"
      ensure
        $VERBOSE = verbose_was
      end
    end
    false
  end

  # reload all files which were required
  def self.reload_all(force = false)
    any = false
    @timestamps.each_key do |file|
      if self.reload(file, force)
        any = true
      end
    end
    any
  end

  def self.should_track?(file)
    return true if @prefix.nil?
    found = locate(file)
    found and found.start_with?(@prefix)
  end
end

# Overwrite 'require' to register the time stamps instead.
module Kernel # :nodoc:
  alias old_require require

  def require(file)
    AutoReload.timestamp(file) if AutoReload.should_track?(file)
    old_require(file)
  end

  # dcrosby: nah, let's just call AutoReload.reload_all
  # def reload
  #   AutoReload.reload_all
  #   return
  # end
end
