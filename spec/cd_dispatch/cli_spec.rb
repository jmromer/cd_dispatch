# frozen_string_literal: true

require "spec_helper"

RSpec.describe CdDispatch::CLI do
  describe "instance interface" do
    it { should respond_to(:list) }
    it { should respond_to(:sync) }
    it { should respond_to(:save_entry) }
    it { should respond_to(:build_label) }
    it { should respond_to(:parse_path) }
  end

  describe "#list"
  describe "#sync"
  describe "#save_entry"
  describe "#build_label"
  describe "#parse_path"
end
