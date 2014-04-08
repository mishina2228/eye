require File.dirname(__FILE__) + '/../spec_helper'

describe "sub procs" do
  it "include lambda" do
    conf = <<-E
      proc = lambda do |proxy|
        proxy.working_dir "/tmp"
      end

      Eye.application("bla") do
        include proc
      end
    E
    Eye::Dsl.parse_apps(conf).should == {"bla" => {:working_dir=>"/tmp", :name => "bla"}}
  end

  it "include lambda with arg" do
    conf = <<-E
      proc = lambda do |proxy, arg|
        proxy.working_dir arg
      end

      Eye.application("bla") do
        include proc, "1"
      end
    E
    Eye::Dsl.parse_apps(conf).should == {"bla" => {:name=>"bla", :working_dir=>"1"}}
  end

  it "include proc" do
    conf = <<-E
      proc = Proc.new do
        working_dir "/tmp"
      end

      Eye.application("bla") do
        include proc
      end
    E
    Eye::Dsl.parse_apps(conf).should == {"bla" => {:working_dir=>"/tmp", :name => "bla"}}
  end

  it "include proc with arg" do
    conf = <<-E
      proc = Proc.new do |proxy, arg|
        proxy.working_dir arg
      end

      Eye.application("bla") do
        include proc, "1"
      end
    E
    Eye::Dsl.parse_apps(conf).should == {"bla" => {:name=>"bla", :working_dir=>"1"}}
  end

  it "include method" do
    pending if RUBY_ENGINE == 'rbx'
    conf = <<-E
      def add_process(proxy)
        working_dir "/tmp"
      end

      Eye.application("bla") do
        include method(:add_process)
      end
    E
    Eye::Dsl.parse_apps(conf).should == {"bla" => {:working_dir=>"/tmp", :name => "bla"}}
  end

  it "include method with arg" do
    conf = <<-E
      def add_process(proxy, arg)
        working_dir arg
      end

      Eye.application("bla") do
        include method(:add_process), "1"
      end
    E
    Eye::Dsl.parse_apps(conf).should == {"bla" => {:name=>"bla", :working_dir=>"1"}}
  end

  it "include part of code" do
    Eye::Dsl.parse_apps(nil, fixture("dsl/include_test.eye")).should == {
      "test" => {:name=>"test", :environment=>{"a"=>"b"},
      :groups=>{"__default__"=>{:name=>"__default__", :environment=>{"a"=>"b"}, :application=>"test",
      :processes=>{"bla"=>{:name=>"bla", :environment=>{"a"=>"b"}, :application=>"test", :group=>"__default__", :pid_file=>"10"}}}}}}
  end

  it "include part of code 2 times" do
    Eye::Dsl.parse_apps(nil, fixture("dsl/include_test2.eye")).should == {"test2" => {:name=>"test2", :groups=>{"ha"=>{:name=>"ha", :application=>"test2", :environment=>{"a"=>"b"}, :processes=>{"bla"=>{:name=>"bla", :application=>"test2", :environment=>{"a"=>"b"}, :group=>"ha", :pid_file=>"10"}}}}}}
  end

end