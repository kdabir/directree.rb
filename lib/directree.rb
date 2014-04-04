require "directree/version"
require 'fileutils'
require 'pathname'

module Directree

  def self.create name, opts={}, &block
    tree = build(name,opts,&block)
    tree.create
    tree
  end

  def self.build name, opts={}, &block
    DirTree.new(name, opts, &block)
  end

  class DirTree
    attr_reader :path, :opts, :children

    def initialize name, opts={}, &block
      @path = name
      @opts = opts
      @children ||= []
      self.instance_eval &block if block_given?
    end

    def dir name, opts={}, &block
      @children << DirTree.new(join_path(@path, name), opts, &block)
    end

    def file name, opts={}, &block
      @children << WritableFile.new(join_path(@path, name), opts, &block)
    end

    def create
      FileUtils::mkdir_p @path
      @children.each{ |child| child.create}
    end

    def [](index_or_name)
      if index_or_name.is_a? Integer
        @children[index_or_name]
      else
        @children.find {|p| File.basename(p.path) == index_or_name}
      end
    end

    def walk &block
      [block.call(self), children.collect {|child|
        if child.respond_to?(:walk)
          child.walk(&block)
        else
          block.call(child)
        end
      }].flatten
    end

    private
    def join_path parent, child
      (Pathname(parent) + child).to_s
    end
  end


  class WritableFile
    attr_reader :path, :opts

    def initialize name, opts={}, &block
      @path = name
      @opts = opts
      @block = block if block_given?
    end

    def create
      File.open(@path, 'w') {|f| f.write(content) }
    end

    def content
      @block.call(@path, @opts) if @block
    end

  end

end
