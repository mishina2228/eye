require File.dirname(__FILE__) + '/../spec_helper'

describe "Eye::Dsl::Chain" do

  it "should understand chain options" do
    conf = <<-E
      Eye.application("bla") do
        chain :grace => 5.seconds

        process("3") do
          pid_file "3"
        end
      end
    E
    
    h = {
      "bla" => {
        :chain=>{
          :start=>{:grace=>5, :action=>:start}, 
          :restart=>{:grace=>5, :action=>:restart}}, 
        :groups=>{
          "__default__"=>{
            :chain=>{
              :start=>{:grace=>5, :action=>:start}, 
              :restart=>{:grace=>5, :action=>:restart}}, 
            :processes=>{
              "3"=>{
                :chain=>{:start=>{:grace=>5, :action=>:start}, 
                :restart=>{:grace=>5, :action=>:restart}}, 
                :pid_file=>"3", 
                :application=>"bla", 
                :group=>"__default__", 
                :name=>"3"}}}}}}

    Eye::Dsl.load(conf).should == h
  end

  it "one option" do
    conf = <<-E
      Eye.application("bla") do
        chain :grace => 5.seconds, :action => :start, :type => :async

        process("3") do
          pid_file "3"
        end
      end
    E
    
    h = {"bla" => {
      :chain=>{
        :start=>{:grace=>5, :action=>:start, :type=>:async}}, 
      :groups=>{
        "__default__"=>{
          :chain=>{:start=>{:grace=>5, :action=>:start, :type=>:async}}, 
          :processes=>{"3"=>{:chain=>{:start=>{:grace=>5, :action=>:start, :type=>:async}}, :pid_file=>"3", :application=>"bla", :group=>"__default__", :name=>"3"}}}}}}

    Eye::Dsl.load(conf).should == h
  end

  it "group can rewrite part of options" do
    conf = <<-E
      Eye.application("bla") do
        chain :grace => 5.seconds

        group "gr" do
          chain :grace => 10.seconds, :action => :start, :type => :sync

          process("3") do
            pid_file "3"
          end
        end
      end
    E
    
    h = {"bla" => {
      :chain=>{
        :start=>{:grace=>5, :action=>:start}, 
        :restart=>{:grace=>5, :action=>:restart}}, 
      :groups=>{
        "gr"=>{
          :chain=>{
            :start=>{:grace=>10, :action=>:start, :type=>:sync}, 
            :restart=>{:grace=>5, :action=>:restart}}, 
        :processes=>{"3"=>{:chain=>{:start=>{:grace=>10, :action=>:start, :type=>:sync}, :restart=>{:grace=>5, :action=>:restart}}, :pid_file=>"3", :application=>"bla", :group=>"gr", :name=>"3"}}}}}}

    Eye::Dsl.load(conf).should == h
  end


end