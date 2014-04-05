require 'spec_helper'
require 'fileutils'
require 'tmpdir'

describe Directree do

  it "should give current version" do
    (Directree::VERSION).should == "0.0.1"
  end

  it "should build tree from Module helper method" do
    d = Directree.build("a", append:true) {
      file("LICENSE.txt")
      dir("bin")
      dir("lib")
      dir("spec") {
        file("spec_helper.rb") {
          <<-EOF
          RSpec.configure do |config|
            config.color_enabled = true
          end
          EOF
        }
      }

    }
    d.path.should == "a"
    d["spec"]["spec_helper.rb"].path.should == "a/spec/spec_helper.rb"
    d["spec"]["spec_helper.rb"].content.should include("RSpec.configure")
  end

  describe Directree::WritableFile do
    context "new" do
      it "should initialize with a File with name" do
        f = Directree::WritableFile.new "a.txt"
        f.path.should == "a.txt"
      end

      it "should init with dir name and options" do
        f = Directree::WritableFile.new "a.txt", append:true
        f.path.should == "a.txt"
        f.opts.should == {append:true}
      end

      it "should init with dir name and block" do
        f = Directree::WritableFile.new "a", overwrite:true do
          "this will be the content of file"
        end
        f.path.should == "a"
        f.opts.should == {overwrite:true}
      end

      it "should not call the block when initializing" do
        called = false
        Directree::WritableFile.new "a.txt", overwrite:true do
          called = true
        end
        called.should be(false)
      end
    end

    context "content" do

      it "should be able to get content returned from block" do
        f = Directree::WritableFile.new "a.txt", overwrite:true do |path, opts|
          "this should be content"
        end
        f.content.should == "this should be content"
      end

      it "should call block with path and opts" do
        called = false
        f = Directree::WritableFile.new "a.txt", overwrite:true do |path, opts|
          called = true
          path.should == "a.txt"
          opts.should == {overwrite:true}
        end
        f.content
        called.should be(true)
      end
    end

  end

  describe Directree::DirTree do

    context "new" do

      it "should initialize with a directory name" do
        d = Directree::DirTree.new "a"
        d.path.should == "a"
      end

      it "should init with dir name and options" do
        d = Directree::DirTree.new "a", overwrite:true
        d.path.should == "a"
        d.opts.should == {overwrite:true}
      end

      it "should init with dir name and block" do
        d = Directree::DirTree.new "a", overwrite:true do
          a = "something that doesn't matter"
        end
        d.path.should == "a"
        d.opts.should == {overwrite:true}
      end

      it "should init with a block that can call method on self" do
        called = false
        Directree::DirTree.new "a", overwrite:true do
          called = true
          path.should == "a"
          opts.should == {overwrite:true}
        end
        called.should be(true)
      end
    end

    context "nesting" do

      it "should be able to represent nested dir inside dir" do
        d = Directree::DirTree.new("a")
        d.dir("b", overwrite:true)
        d.children.first.path.should == "a/b"
      end

      it "should be able to represent nested file inside dir" do
        d = Directree::DirTree.new("a")
        d.file("b.txt", append:true)
        d.children.first.path.should == "a/b.txt"
      end

      it "should be able to represent n level nested dir inside dir" do
        a = Directree::DirTree.new("a")
        a.dir("b", overwrite:true) {
          dir("c") {
            dir("d")
          }
        }
        a.children.first.path.should == "a/b"
        a['b']['c']['d'].path.should == "a/b/c/d"
      end

      it "should be able to represent n level nested files and dir inside dir" do
        a = Directree::DirTree.new("a")
        a.dir("b", overwrite:true) {
          dir("c") {
            dir("d")
            file('e.txt')
          }
          file "f.txt", create:false do
            "this would be file's content"
          end
        }
        a['b']['c']['d'].path.should == "a/b/c/d"
        a['b']['c']['e.txt'].path.should == "a/b/c/e.txt"
        a['b']['f.txt'].path.should == "a/b/f.txt"
      end
    end

    context "access" do
      a = Directree::DirTree.new("a") {
        dir("b") {
          dir("c")
          file("d")
        }
      }

      it "should be able to access by array index" do
        a[0].path.should == "a/b"
        a[0][0].path.should == "a/b/c"
        a[0][1].path.should == "a/b/d"
      end

      it "should be able to access by name" do
        a['b'].path.should == "a/b"
        a['b']['c'].path.should == "a/b/c"
        a['b']['d'].path.should == "a/b/d"
      end
    end


    context "traversal" do
      a = Directree::DirTree.new("a") {
        dir("b") {
          dir("c", required:true) {
            file("1.txt")
          }
          dir("d")
          file("2.txt", create:false)
        }
      }

      it "should traverse every file" do
        files = []
        a.walk { |f| files << f.path }
        files.should match_array(["a", "a/b", "a/b/c", "a/b/c/1.txt", "a/b/d", "a/b/2.txt"])
      end

      it "should traverse every file and get its opts" do
        files = []
        a.walk { |f| files << f.opts }
        files.should match_array( [{}, {}, {:required=>true}, {}, {}, {:create=>false}])
      end
    end
  end

  context "integration-testing" do

    before(:each) do
      @path = Dir.mktmpdir + "/directest"
      FileUtils.mkdir_p(@path)
      Dir.chdir(@path)
      #puts "using #{@path} for integration tests"
    end

    after(:each) do
      FileUtils.rm_rf("directest")
    end

    it "should create directories and files" do
      a = Directree::DirTree.new("a") {
        dir("b") {
          dir("c", required:true) {
            file("1.txt") {
              "hello world"
            }
          }
          dir("d")
          file("2.txt", create:false)
        }
      }
      a.create

      Dir["**/*/"].should match_array(["a/", "a/b/", "a/b/c/", "a/b/d/"]) # for directories
      File.read("a/b/c/1.txt").should == "hello world"
      File.read("a/b/2.txt").should == ""
    end

    it "should create from module" do
      Directree.create("x") {
        file "y.txt" do
          "content of y.txt"
        end
      }
      File.read("x/y.txt").should == "content of y.txt"
    end
  end

end